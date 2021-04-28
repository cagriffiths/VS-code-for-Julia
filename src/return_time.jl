#=============================================================================================
                                        SET-UP
=============================================================================================#
import Pkg
using BioEnergeticFoodWebs
using Distributions
using Plots
using DataFrames

function ScaleRates!(par, k0; prod_metab = false)
    T = par[:T]
    M = par[:bodymass]
    ri = ScaleGrowth(M, T)
    r = ri .* par[:is_producer]
    xi = ScaleMetabolism(M, T)
    x = prod_metab ? xi : xi .* .!par[:is_producer]
    ar = ScaleAttack(M, T)
    ht = ScaleHandling(M, T)
    K = carrying(M, k0, T)
    par[:r] = r
    par[:x] = x
    par[:ar] = ar
    par[:ht] = ht
    par[:K] = K
end
#Growth rate (producers)
function ScaleGrowth(M, T)
    r0 = exp(-15.68)
    βr = -0.25
    Er = -0.84
    T0 = 293.15 #20 celsius
    k = 8.617e-5
    return r0 .* (M .^ βr) .* exp(Er .* ((T0 .- T) ./ (k .* T .* T0)))
end
#Metabolic rate
function ScaleMetabolism(M, T)
    x0 = exp(-16.54)
    sx = -0.31
    Ex = -0.69
    T0 = 293.15
    k = 8.617e-5
    return x0 .* (M .^ sx) .* exp(Ex .* ((T0 .- T) ./ (k .* T .* T0)))
end
#Handling time
function ScaleHandling(m, T)
    h0 = exp(9.66)
    βres = -0.45
    βcons = 0.47
    Eh = 0.26
    T0 = 293.15
    k = 8.617E-5
    boltz = exp(Eh * ((T0-T)/(k*T*T0)))
    hij = zeros(length(m), length(m))
    for i in eachindex(m) #i = rows => consumers
        for j in eachindex(m) #j = cols => resources
          mcons = m[i] ^ βcons #mass scaled for cons
          mres = m[j] ^ βres #mass scaled for res
          hij[i,j] = h0 * mres * mcons * boltz
        end
      end
    return hij
end
#Attack rate
function ScaleAttack(m, T)
    a0 = exp(-13.1)
    βres = 0.25 #resource
    βcons = -0.8 #consumer
    Ea = -0.38
    T0 = 293.15
    k = 8.617E-5
    boltz = exp(Ea * ((T0-T)/(k*T*T0)))
    aij = zeros(length(m), length(m))
    for i in eachindex(m) #i = rows => consumers
      for j in eachindex(m) #j = cols => resources
        mcons = m[i] ^ βcons #mass scaled for cons
        mres = m[j] ^ βres #mass scaled for res
        aij[i,j] = a0 * mres * mcons * boltz
      end
    end
    return aij
end
#Carrying capacity
function carrying(m, k0, T)
    βk = 0.28
    Ek = 0.71 
    return k0 .* (m .^ βk) .* exp.(Ek .* (293.15 .- T ) ./ (8.617e-5 .* T .* 293.15))
end

# Set seed
import Random.seed!
seed!(22)

#include("masters tutorials/utils harvesting.jl")

S = 100 # number of species
con = 0.2 # connectance
A = nichemodel(S,con) # use niche model to generate network 
p = model_parameters(A, h = 2.0, Z = 10.0, T = 293.15)
ScaleRates!(p, 10.0) #here 10.0 is a parameter to calculate the scaled carrying capacity
tstop_burnin = Int(60*60*24*364.25*1500) # we're going to run the burn in for 3000 years 
tkeep_burnin = Int(60*60*24*364.25) # and save the data every year
b0 = rand(S) # set some initial biomasses at random
s = simulate(p, b0, stop = tstop_burnin, interval_tkeep = tkeep_burnin) # simulate
#Plot burn-in
lst = fill(:solid, 1, S)
lst[p[:is_producer]'] .= :dash
clr = fill(:black, 1, S)
clr[p[:extinctions]'] .= :grey80
plt = plot(s[:B], leg = false, linestyle = lst, c = clr, xlabel = "time (days)", ylabel = "species biomass (g.m-2)")
cv = round(population_stability(s, last = 100), digits = 3)
vline!([size(s[:B], 1) - 100], c = :grey, linestyle = :dot)
annotate!(size(s[:B], 1) - 50, 1.75, text("cv = $cv", 8, rotation = 90))
#eq. biomass
b1 = s[:B][end,:]
b0 = deepcopy(b1)
#harvesting rule
M = p[:bodymass] #extract body mass values for all species
harvest_rule = median(M) #calculate the median - this is act as our harvesting rule
harvest_rate = 0.95 # set the rate of harvesting 
#harvesting and sampling frequencies
tstop_harvesting = tstop_burnin #1 harvesting event followed by 1500 years of recovery
tkeep_harvesting = tkeep_burnin #sample every year
#track extinctions after burn-in
is_extinct_0 = falses(S) # make a vector of 0's (falses) the size of S
is_extinct_0[p[:extinctions]] .= true # set extinction species to 1 (true)
#id target species 
to_harvest_all = M .> harvest_rule 
to_harvest_nonextinct = (to_harvest_all) .& (.!is_extinct_0)
#harvesting
b1[to_harvest_nonextinct] = b1[to_harvest_nonextinct] .* harvest_rate 
s1 = simulate(p, b1, stop = tstop_harvesting, interval_tkeep = tkeep_harvesting) #run the simulation
B = s1[:B][2:end,:] #we get rid of the first time step because it's the initial condition (t = 0)
extinct = falses(S)
extinct[p[:extinctions]] .= true

#How many species went extinct after the harvesting event 
idext = findall(is_extinct_0 .!= extinct) #NONE! YAY!
#have species reached a steady state? 
Bsub = B[end-99:end,:]
cvall = [BioEnergeticFoodWebs.coefficient_of_variation(Bsub[:,i]) for i in 1:S]
idsteady = findall((cvall .< 5e-3) .& (.!extinct))
unsteady = findall((cvall .>= 5e-3) .& (.!extinct))

#return time
B = s1[:B][2:end,:] #we get rid of the first time step because it's the initial condition (t = 0)
rt = []
nrt = [] 
absvec = [1e-3, 1e-5, 1e-7, 1e-9]
for i in absvec
  abs_tolerance = i
  return_time = [findfirst(isapprox.(B[:,s], b0[s], atol = abs_tolerance)) for s in 1:S]
  rt_tmp = return_time[.!isnothing.(return_time)]
  rt_tmp = convert(Array{Int64,1}, rt_tmp)
  isnot = sum(isnothing.(return_time))
  push!(rt, unique(rt_tmp))
  push!(nrt, isnot)
end
#return times VS abs. tolerance 
plt = scatter([NaN], [NaN], ylims = (-0.1,3.5), xlims = (-10,0), leg = false)
for i in 1:length(absvec)
  scatter!(plt, log10.(repeat([absvec[i]], length(rt[i]))), log10.(rt[i]), c = :black) 
end
ylabel!("log10(return time)")
display(plt)
#number of species that don't return to equilibrium
plt2 = scatter(log10.(absvec), nrt, ylims = (-1,25), xlims = (-10,0), c = :black, leg = false)
ylabel!("Total no return to eq.")
xlabel!("log10(precision)")
plot(plt, plt2, layout = grid(2,1), size = (500, 500))
savefig("ReturnTime.png")