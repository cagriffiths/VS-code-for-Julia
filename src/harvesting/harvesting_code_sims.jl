#=
Harvesting simulations 
This script shows how to
- initialize the BEFWm with a food web and your choice of parameters (S, C and Z)
- run a burn-in to remove structurally doomed species (to avoid detecting them as false secondary extinctions) and achieve equilibrium dynamics - burnin runs for 50 years
- target a species or a group of species for harvesting at a given rate (e.g. % removal of biomass)
- run the model for 10 years 
- detect effects of harvesting (changes in total biomass, persistence, temporal stability and trophic structure)
=#

# Packages
import Pkg
using BioEnergeticFoodWebs
using Distributions
using Plots
using DataFrames
using EcologicalNetworks
using StatsBase

Pkg.status()

# Set seed
import Random.seed!
seed!(7678) # setting a seed makes it possible to replicate exactly the same results, even when there is randomness involved

#=
Step 1: Import some functions that we've made earlier
These functions allow you to use the temperature scaled version of the BEFW which is resolved in real time
=#
include("masters tutorials/utils harvesting.jl") # use include to add these pre-made functions

#=
Step 2: Generate a list of networks
We start by creating a food web using the niche model using a set of S and C values
=#
S = [20, 50, 100] # number of species
con = [0.1, 0.2, 0.3] # connectance
nrep = 10 # number of replicates

networks = []

for s in S
    for c in con
        for r in 1:nrep
            A_bool = EcologicalNetworks.nichemodel(s, c) # use niche model to generate network
            A = adjacency(A_bool)
            A = Int.(A) # Convert the unipartiteNetwork into a matrix of 1s and 0s
            push!(networks, A)
            println("$s _ $c _ $r")
        end
    end
end

networks # Will contain 90 unique networks

#=
Step 3: Make data table
Lists our simulation parameters (z and harvesting target) 
=#

z = [10.0,100.0]
target_harvest = [:IQR, :median, :no_fishing_y, :no_fishing_m]
years = 10 # fix the number of years over which harvesting events occur
input_table = []

for z in z
    for t in target_harvest
        if t == :IQR
            frequency = Int.(60*60*24*364.25) # per year
            rate = 0.2 # 80% removal of biomass
            sims = deepcopy(years) # 10 years
            input_tmp = (frequency = frequency, rate = rate, sims = sims)

        elseif t == :median
            frequency = Int.(60*60*24*30) # per month 
            rate = 0.8 # 20% removal of biomass
            sims = deepcopy(years)*12 # 10 years/monthly
            input_tmp = (frequency = frequency, rate = rate, sims = sims)

        elseif t == :no_fishing_y
            frequency = Int.(60*60*24*364.25) # per year
            rate = 1.0 # no fishing - 0% removal of biomass
            sims = deepcopy(years) # 10 years
            input_tmp = (frequency = frequency, rate = rate, sims = sims)

        elseif t == :no_fishing_m
            frequency = Int.(60*60*24*30) # per month
            rate = 1.0 # no fishing - 0% removal of biomass
            sims = deepcopy(years)*12 # # 10 years/monthly
            input_tmp = (frequency = frequency, rate = rate, sims = sims)
        end
        for a in networks
            input_tmp = (Z = z, target = t, A = a, frequency = frequency, rate = rate, sims = sims)
            push!(input_table, input_tmp)
        end
        
    end
end

input_table # 720 element array

#=
Step 5: build dataframes
Only considered community level metrics at the moment
=#

community_data = [] # will fill below

#=
Step 6: simulations
Look over each unique row in input_table
=#

for (i, in_tab) in enumerate(input_table)
    
    # Store A and S so we can use them later
    A = in_tab.A
    S = size(in_tab.A, 1)

    #=
    Step 6a = Burn-in
    =#
    p = model_parameters(A, h = 2.0, Z = in_tab.Z, T = 293.15)
    ScaleRates!(p, 10.0)
    b0 = rand(S) # set some initial biomasses at random
    sim = simulate(p, b0, stop = Int(60*60*24*364.25*50), interval_tkeep = Int(60*60*24)) # simulate for 50 years
    b1 = sim[:B][end,:] # extract biomassses

    #=
    Step 6b = Set harvesting parameters
    =#
    M = p[:bodymass] # bodymass vector
    years = 10 # number of years of simulation - can be changed

    # if loops to define harvesting targets
    if in_tab.target == :IQR # if target is IQR 
        
        harvest_rule_25, harvest_rule_75 = quantile(M,[0.25,0.75]) # define harvesting rule
        target_M = (M .> harvest_rule_25) .& (M .< harvest_rule_75) # identify species 

    elseif in_tab.target == :median # if target is median

        harvest_rule = median(M) # define harvesting rule
        target_M = (M .> harvest_rule) # identify species 
    
    elseif in_tab.target == :no_fishing_y
        
        target_M = trues(length(M))
    
    elseif in_tab.target == :no_fishing_m

        target_M = trues(length(M))

    end

    #=
    Step 6b = Run harvesting simulations
    =#

    for h in 1:in_tab.sims # remember we've fixed sims as 10 years (either at the yearly or monthly time step)
        
        # impose harvesting on non extinct species
        is_extinct_0 = falses(S) # make a vector of 0's (falses) the size of S
        is_extinct_0[p[:extinctions]] .= true # set extinction species to 1 (true)
        to_harvest_nonextinct = (target_M) .& (.!is_extinct_0)

        # remove biomass based on our chosen harvesting rate
        b1[to_harvest_nonextinct] = b1[to_harvest_nonextinct] .* in_tab.rate

        # simulate
        sim1 = simulate(p, b1, stop = in_tab.frequency, interval_tkeep = Int(60*60*24))

        # store biomasses
        b1 = sim1[:B][end,:]

        # calculate trophic rank
        tr = p[:trophic_rank][.!is_extinct_0]

        # calculate and store data
        out_data = (harvest_event = h
            , biomass = total_biomass(sim1, last = 7)
            , persistence = species_persistence(sim1, last = 7)
            , richness = species_richness(sim1, last = 7)
            , stability = population_stability(sim1, last = 7)
            , avg_trophicrank = mean(tr)
            , max_trophicrank = maximum(tr))
        
        # calculate realised connectance
        con = sum(A) / (S*S)
        
        # store S, C and harvesting frequency (once per year or once per month)
        nk_parameters = (S = S, C = con)
        
        # merge the 3 databases
        data_tmp = merge(nk_parameters, in_tab, out_data)

        # push
        push!(community_data, data_tmp)

    end

    # print percentage completion - put the kettle on...
    println(round(i / length(input_table) * 100))
    
end

# turn output into a dataframe
community_df = DataFrame(community_data)

# and view
community_df

using Plots, StatsPlots
df = deepcopy(community_df)

# effect of harvesting on persistence
plt_pers = []
for i in target_harvest
    for k in z
        plt = plot([NaN], [NaN], legend = false, ylims = (0,1.01))
        title!("$i (z = $k)")
        for j in networks
            sub = ([a == j for a in df.A]) .& (df.Z .== k) .& (df.target .== i)
            tmp = df[sub,:]
            δpers = tmp.persistence[1] .- tmp.persistence[end]
            plot!(tmp.harvest_event, tmp.persistence, c = :black, la = 0.4, linestyle = :solid)
        end
        push!(plt_pers, plt)
    end
end

plot(plt_pers..., layout = grid(2,4), size = (1000,300))



