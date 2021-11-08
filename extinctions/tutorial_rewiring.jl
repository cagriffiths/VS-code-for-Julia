using Distributions: isapprox, minimum
#=
How to use the rewirinh methods in BioEnergeticFoodWebs
author: Eva Delmas
date: April 25th, 2021
=#

# Set up

#we will nee a different version of BEFWM with the newest features 
#so start my removing the package with rm and reinstalling with 
#add BioEnergeticFoodWebs#dev-2.0.0
using BioEnergeticFoodWebs
using Distributions, DataFrames, StatsPlots
include("extinctions/utils.jl") 
import Random.seed!
seed!(657)

# Generate a food web
#=
Because we are going to use the ADBM as one of the rewiring models, 
we are going to also use the ADBM as a generative model (instead of
the niche model). This is because the ADBM rewire on a more global
scale than the other two, as a consequence, if we start with a niche 
model, the first rewiring event will reorganize the whole food web, 
and the ADBM will work with a different food web than the Diet 
Overlap and DIet Generality models. 
=#

S = 30
#we don't need to specify connectance anymore - connectance is an 
#output of the network generation process with ADBM
#C = 0.25 

niche_res = []
adbm_res = []
nrep = 20

for i in 1:nrep
     println("$i / $nrep")

     An = nichemodel(S, rand(Uniform(0.05, 0.45))) 
     co_n = sum(An) / S^2
     np_n = sum(sum(An, dims = 2) .== 0)
     tln = trophic_rank(An)
     Hn = maximum(tln)
     diff_co = true
     diff_np = true
     diff_height = true
     jcount = true
     global j = 0
     global A, adbm_p = ADBM_foodweb(S)
     while (diff_co | diff_np | diff_height) & jcount
          global j = j+1
          global A, adbm_p = ADBM_foodweb(S)
          co = sum(A) / S^2
          np = sum(sum(A, dims = 2) .== 0)
          tl = trophic_rank(A)
          H = maximum(tl)
          diff_co = !isapprox(co, co_n, atol = 0.05)
          diff_np = np != np_n
          diff_height = Hn != H
          jcount = j < 1e5
     end
     if j >= 1e6 
          continue
     else
          #scale bodymass
          ap_d = Dict([x => getindex(adbm_p, x) for x in keys(adbm_p)])
          ap_d[:M] = ap_d[:M] ./ minimum(ap_d[:M]) #activation energy for handling time
          adbm_p = NamedTuple{Tuple(keys(ap_d))}(values(ap_d))
          Z = mean(Array(adbm_p.M ./ adbm_p.M') .* A) #predator prey mass ratio
          Mn = Z .^ (trophic_rank(An) .- 1) #use same ppmr than adbm to have a similar size structure

          #You can check the food web with webplot
          #pltA = webplot(A, true) #true means that we want to have consumers plotted as rows(i) and resources as columns (j)
          #the resulting plot shows the interaction matrix A[i,j] = 1 is represented by a black dot and 
          #means that i eats j. Dots on the diagonal indicate canibalism (i eats i).

          # Set up simulations

          # /!\ You'll need to change the simulation time because we have changed the units of the biological rates
          tstop = Int.(60*60*24*364.25*100) #simulation time = 100 years
          Δt = Int.(60*60*24*30) #sample every month
          Δtadbm = Int.(60*60*24*30) #rewire every month
          ϵ = 1e-10 #extinction threshold
          #when a species biomass reaches the extinction threshold, it's considered as
          #extinct. It's important to know the extinction threshold when using rewiring because 
          #rewiring will be triggered at each extinction event during the simulations. 
          # (We'll see later how this can be different for the ADBM)
          b0 = rand(S)

          # Generate the sets of parameters for the BEFWM
          #no rewiring is the default, technically you don't need to specify rewire_method in that case
          p_none = model_parameters_modif(A, adbm_p, :none, Δtadbm)
          #DO stands for diet overlap, that's from Staniczencko's paper
          p_do = model_parameters_modif(A, adbm_p, :DO, Δtadbm)
          #DS stands for diet similarity, from Gilljam's paper 
          p_ds = model_parameters_modif(A, adbm_p, :DS, Δtadbm)
          #ADBM stands for Allometric Diet Breadth Model, from Petchey's paper
          p_adbm = model_parameters_modif(A, adbm_p, :ADBM, Δtadbm)

          pn_none = model_parameters(An, bodymass = Mn, h = 2.0, T = 293.15
               , functional_response = :classical, scale_bodymass = false)
          ScaleRates!(pn_none, adbm_p)
          #DO stands for diet overlap, that's from Staniczencko's paper
          pn_do = model_parameters(An, bodymass = Mn, h = 2.0, T = 293.15
               , functional_response = :classical, scale_bodymass = false, rewire_method = :DO)
          ScaleRates!(pn_do, adbm_p)
          #DS stands for diet similarity, from Gilljam's paper 
          pn_ds = model_parameters(An, bodymass = Mn, h = 2.0, T = 293.15
               , functional_response = :classical, scale_bodymass = false, rewire_method = :DS)
          ScaleRates!(pn_ds, adbm_p)
          #ADBM stands for Allometric Diet Breadth Model, from Petchey's paper
          pn_adbm =  model_parameters(An, bodymass = Mn, h = 2.0, T = 293.15
               , functional_response = :classical, scale_bodymass = false
               , rewire_method = :ADBM, adbm_trigger = :interval, adbm_interval = Δtadbm)
          ScaleRates!(pn_adbm, adbm_p)

          # Simulate biomass dynamics for each

          println("ADBM")

          #Burnin
          pBI = deepcopy(p_none)
          sBI = simulate(p_none, b0, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
          Bm_afterburnin = sBI[:B][end,:]

          #no rewiring
          s_none = simulate(p_none, Bm_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
          #diet overlap
          s_do = simulate(p_do, Bm_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
          #diet similarity 
          s_ds = simulate(p_ds, Bm_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
          #ADBM
          s_adbm = simulate(p_adbm, Bm_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)

          push!(adbm_res, [s_none, s_do, s_ds, s_adbm])

          println("Niche")

          pnBI = deepcopy(pn_none)
          snBI = simulate(pn_none, b0, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
          Bmn_afterburnin = snBI[:B][end,:]
          if snBI[:t][end] != 3.146688e9
               continue
          else
               #no rewiring
               sn_none = simulate(pn_none, Bmn_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
               #diet overlap
               sn_do = simulate(pn_do, Bmn_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
               #diet similarity 
               sn_ds = simulate(pn_ds, Bmn_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)
               #ADBM
               sn_adbm = simulate(pn_adbm, Bmn_afterburnin, stop = tstop, interval_tkeep = Δt, extinction_threshold = ϵ)

               push!(niche_res, [sn_none, sn_do, sn_ds, sn_adbm])
          end

          # Visualize the results
          #plt_dyn_none = plot(s_none[:B], leg = false, c = :black, ylims = (0,8), xlabel = "time", ylabel = "biomass")
          #plt_dyn_do = plot(s_do[:B], leg = false, c = :black, ylims = (0,8),xlabel = "time", ylabel = "biomass")
          #plt_dyn_ds = plot(s_ds[:B], leg = false, c = :black, ylims = (0,8),xlabel = "time", ylabel = "biomass")
          #plt_dyn_adbm = plot(s_adbm[:B], leg = false, c = :black, ylims = (0,8),xlabel = "time", ylabel = "biomass")
          #plt_mat_none = webplot(updateA(s_none), true)
          #plt_mat_do = webplot(updateA(s_do), true)
          #plt_mat_ds = webplot(updateA(s_ds), true)
          #plt_mat_adbm = webplot(updateA(s_adbm), true)

          #plt = [plt_dyn_none, plt_dyn_do, plt_dyn_ds, plt_dyn_adbm
          #     , plt_mat_none, plt_mat_do, plt_mat_ds, plt_mat_adbm]

          #plot(plt..., layout = grid(2,4), size = (1000,400))

     end

end

idx = [2,4,6,7,9,11,12,13,14,15,16]
adbm_res2 = adbm_res[idx]

df = DataFrame()
for i in 1:length(idx)
     pers_adbm = species_persistence.(adbm_res2[i], last = 1)
     pers_niche = species_persistence.(niche_res[i], last = 1)
     #this is used to check that the simulation hasn't aborted due to instabilities
     noinstab_adbm = [x[:t][end] == 3.146688e9 for x in adbm_res[i]]
     noinstab_niche = [x[:t][end] == 3.146688e9 for x in niche_res[i]]
     #rewiring and food web models
     mods = repeat(["none", "dietoverlap", "dietsim", "adbm"], outer = 2)
     fwmods = repeat(["adbm", "niche"], inner = 4)
     #push to data frame
     tmp = DataFrame(rewiringmodel = mods, foodwebmodel = fwmods, pers = vcat(pers_adbm, pers_niche), stable = vcat(noinstab_adbm, noinstab_niche)) 
     append!(df, tmp)
end 

#remove aborted simulations (and NaNs)
df = df[(df.stable .== 1) .& (.!isnan.(df.pers)), :]
@df df groupedboxplot(:foodwebmodel, :pers, group = :rewiringmodel
     , legend = :bottomright, legendtitlefontsize = 7, legendfontsize = 7, legendtitle = "rewiring model"
     , xlabel = "food web model", ylabel = "persistence")
savefig("extinctions/persistence_matched_noaborted.png")

plt = []
clr = 
for j in 1:4
     ptmp = plot([NaN], [NaN], label = ""
          , ylims = (0,1.1), xticks = ([1,2], ["Niche", "ADBM"])
          , xlims = (0.7, 2.3), legend = false)
     for i in 1:length(niche_res)
          adbm = adbm_res2[i]
          niche = niche_res[i]
          lbl = string(niche[j][:p][:rewire_method])
          plot!(ptmp, [1,2]
               , [species_persistence(niche[j]), species_persistence(adbm[j])]
               , line = (:dash, 1, :black)
               , marker = (:circle, :black, 3)
               )
     end
     ylabel!("persistence")
     title!(lbl)
     push!(plt, ptmp)
end
plot(plt..., size = (600,400))
