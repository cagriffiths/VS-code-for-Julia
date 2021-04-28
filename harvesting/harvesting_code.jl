#=
Harvesting tutorial
This script shows how to 
- initialize the BEFWm with a food web and your choice of parameters 
- run a burn-in to remove structurally doomed species (to avoid detecting them as false secondary extinctions) and achieve equilibrium dynamics
- target a species or a group of species for harvesting at a given rate (e.g. 20% removal of biomass)
- run the model 
- detect effects of harvesting (changes in species and/or community)
=#

# Packages
import Pkg
using BioEnergeticFoodWebs
using Distributions
using Plots
using DataFrames

Pkg.status()

# Set seed
import Random.seed!
seed!(22) # setting a seed makes it possible to replicate exactly the same results, even when there is randomness involved

#=
Step 1: Import or generate a food web
You can use an empirical food web or use a model (niche model, ADBM...) to generate realistic food webs
We start by creating a food web using the niche model
- we initialize with 100 species and a connectance of 0.2 
=#
S = 100 # number of species
con = 0.2 # connectance
A = nichemodel(S,con) # use niche model to generate network 

#=
Step 2: Set the model parameters 
Here we are running a very basic simulation, with:
- h (hill exponent) = 2
- K (carrying capacity for basal species / producers) = 10 
- Z = (consumer-resource size ratio) = 10.0
=#
p = model_parameters(A, h = 2.0, K = [10.0], Z = 10.0)

#=
Step 3: Run a burn-in
Run a burn-in phase to remove some structurally doomed species and achieve equilibrium dynamics
We've also provided the code to save some information about each species (TL, in and out degree) and the community (total biomass, persistence) in two seperate dataframes
=#
b0 = rand(S) # set some initial biomasses at random
s = simulate(p, b0, stop = 2000) # simulate
plot(s[:B], legend = false) # plot

# Below, we've created a dataframe that stores species level information for all species in the network, including their TL, indegree (number of species that eat them) and outdegree (number of species that they eat), as well as information about when some of those species went extinction (which timestep) and during which simulation (0 = burn-in and 1 = second simulation post perturbation), as well as the biomass of each species
# To provide some biological context, a specialist species will have a small outdegree value (they consume few prey species), whereas a generalist species will have a large outdegree value (they consume many prey species). Also, a basal species might be expected to have a large indegree value (a lot of species consume them), whereas a large predator near the top of the food web will have a small indegree value (few species consume them) 

# here we create a dataframe of S rows (100) by preallocating the column names and size of the dataframe, and filling it with NaNs (same as NAs in R)
species_data = DataFrame(fill(NaN,S,7), [:ID, :TL, :indegree, :outdegree, :extinction_time, :extinction_sim, :biomass0])
species_data.ID = collect(1:100)
species_data.TL .= p[:trophic_rank]
species_data.indegree .= vec(sum(A, dims = 1))
species_data.outdegree .= vec(sum(A, dims = 2))
species_data[p[:extinctions],:extinction_sim] .= Int.(zeros(length((p[:extinctions]))))
species_data[p[:extinctions], :] # view the dataframe for species that went extinct during the burn-in (38 species went extinct)
species_data.biomass0 = population_biomass(s, last = 500) 

# here we construct a dataframe for community level metrics by preallocating the type and name of each column
df = DataFrame([Int64, Float64, Float64, Float64],[:sim, :total_biomass, :persistence, :richness]) 
# populate df using push!
push!(df, [0, total_biomass(s, last = 500), species_persistence(s, last = 500), species_richness(s, last = 500)]) 
# again, we've used 0 to indicate the burn in phase
# we could also have calculated stability or diversity, or some other out of the box metrics like network height (max TL) or size structure (the realised Z value of the community)

#=
Step 4: Save/update the biomass of each species so that it matches their biomasses at equilibrium 
Basically, extract biomass of each species at the end of the first simulation
=#
global b1 = s[:B][end,:] # b1 will serve as a starting point for our next simulation

#=
Step 5: Set harvesting rule
=#
# set a rule for the harvesting of a species or a group of species
# as an example let's harvest species that have a body mass greater than the median body mass of the community at a rate of 0.8 per simulation, i.e., we remove 20% of the biomass of those selected species at the start of each simulation, where one simulation can be considered as a single harvesting event
# this type of harvesting is analogous to the use of a knife-edge fishing scenario via which fishing pressure is imposed at a constant rate above a certain size threshold
# knife-edge fishing scenarios are commonly used to recreate the effect of fishing practices that employ a net designed to allow small fish to escape (mesh size restrictions are a common fisheries management tool)
M = p[:bodymass] #extract body mass values for all species
harvest_rule = median(M) #calculate the median - this is act as our harvesting rule
harvest_rate = 0.6

#=
Step 6: Loop through simulations/harvesting events
=#

sims = 10 # number of simulations/harvesting events
global B = s[:B]

for i in 1:sims

    #=
    Step 6a: create a vector of already extinct species
    =#
    is_extinct_0 = falses(S) # make a vector of 0's (falses) the size of S
    is_extinct_0[p[:extinctions]] .= true # set extinction species to 1 (true)

    #=
    Step 6b: create a vector of the species that will be subject to harvesting based on our chosen harvesting rule and then impose harvesting
    =#
    # here we identify species that: 
    # - have a mass above the harvesting threshold
    # - are not already extinct 
    to_harvest_all = M .> harvest_rule 
    to_harvest_nonextinct = (to_harvest_all) .& (.!is_extinct_0)
    # reduce the biomass of our selected species by harvest_rate 
    global b1[to_harvest_nonextinct] .= b1[to_harvest_nonextinct] .* harvest_rate 

    #=
    Step 6c: Simulate forward
    =#
    s1 = simulate(p, b1, stop = 2000) #run the simulation

    #=
    Step 6d: update biomasses
    =#
    global b1 = s1[:B][end,:]
    
    #=
    Step 6e: Update the community level dataframe
    =#
    # using push!
    push!(df, [i, total_biomass(s1, last = 500), species_persistence(s1, last = 500), species_richness(s1, last = 500)])

    #=
    Step 6f: Update the species level dataframe
    =#
    # first identify any newly extinct species in response to harvesting
    is_extinct_1 = falses(S)
    is_extinct_1[p[:extinctions]] .= true
    new_extinct = findall(is_extinct_1 .!= is_extinct_0) 
    # for newly extinct species, specify that they went extinct during the ith simualtion by setting :extinction_sim in species_data as i
    species_data[new_extinct,:extinction_sim] .= fill(float(i),length(new_extinct)) 
    # get the biomass of all species at the end of simulation i
    bi = population_biomass(s1, last = 500)
    # create a new column and append to the species_data dataframe
    col_name = Symbol("biomass$i")
    insertcols!(species_data, (col_name => bi))
    
    println(i)
    global B = vcat(B, s1[:B])
end

plot(B, leg = false, grid = false)
vline!([8000:8000:88085;], c = :grey, linestyle = :dot)
xlabel!("time")
ylabel!("sp. biomass")
savefig("harvesting.png")

# then, for all extinct species, we specify the time step at which they went extinct
# this can be done at the end of all runs because p[:extinctionstime] is not overwritten and keeps records of extinction times 
ext_time = p[:extinctionstime] #this vector is ordered by time of extinction and not species id so we need to reorder it
ext_time_sp = [i[2] for i in ext_time] #extract species identity from this object
sort_extinct = sortperm(ext_time_sp) #create a vector to order by identity
ext_time_ts = [i[1] for i in ext_time[sort_extinct]] #use it to reorder extinction times
species_data[is_extinct_1,:extinction_time] .= ext_time_ts #pass extinction times to the data frame

# THE END #









