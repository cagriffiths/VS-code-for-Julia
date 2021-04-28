#=
Harvesting tutorial
This script shows how to
- initialize the BEFWm with a food web and your choice of parameters
- run a burn-in to remove structurally doomed species (to avoid detecting them as false secondary extinctions) and achieve equilibrium dynamics
- target a species or a group of species for harvesting at a given rate (e.g. 40% removal of biomass)
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
seed!(5436) # setting a seed makes it possible to replicate exactly the same results, even when there is randomness involved

#=
Step 1: Import some functions that we've made earlier
These functions allow you to use the temperature scaled version of the BEFW which is resolved in real time
=#
include("masters tutorials/utils harvesting.jl") # use include to add these pre-made functions

#=
Step 2: Import or generate a food web
You can use an empirical food web or use a model (niche model, ADBM...) to generate realistic food webs
We start by creating a food web using the niche model
- we initialize with 100 species and a connectance of 0.2
=#
S = 100 # number of species
con = 0.2 # connectance
A = nichemodel(S,con) # use niche model to generate network

#=
Step 3: Set the model parameters
Here we are running a very basic simulation, with:
- h (hill exponent) = 2
- Z = (consumer-resource size ratio) = 10.0
# As we are using the temperature scaled version of the BEFW, there are two notable differences:
- we have to provide a temperature (T) in Kelvin (0C = 273.15K), i.e., 20c = 20+273.15
- we have to scale the biological rates (growth, metabolism and feeding rates as well as carrying capacity) by T
    using a pre-made function called ScaleRates!
- this means that biomass is now in grams per meter squared (g/m2)
- and that the model now runs in real time, where 1 timestep = 1 seconds, therefore we have to
    fix a stopping point that is biologically meaningful (e.g., 50 years) and
    include an interval at which we want to save the data
- don't make the interval too small or the computer will struggle (we'd recommend somewhere between one day and one month)
=#
p = model_parameters(A, h = 2.0, Z = 10.0, T = 293.15)
ScaleRates!(p, 10.0) #here 10.0 is a parameter to calculate the scaled carrying capacity
tstop_burnin = Int(60*60*24*364.25*50) # we're going to run the burn in for 50 years
tkeep_burnin = Int(60*60*24) # and save the data every day

#=
Step 4: Run a burn-in
Run a burn-in phase to remove some structurally doomed species and achieve equilibrium dynamics
We've also provided the code to save some information about each species (TL, in and out degree) and
    the community (total biomass, persistence) in two seperate dataframes
=#
b0 = rand(S) # set some initial biomasses at random
s = simulate(p, b0, stop = tstop_burnin, interval_tkeep = tkeep_burnin) # simulate
plot(s[:B], legend = false) # plot
xlabel!("time (day)")
ylabel!("species biomass (g/m2)")

#= Below, we've created a dataframe that stores species level information for all species in the network,
    including their TL, body mass, indegree (number of species that eat them) and outdegree (number of species that they eat),
    as well as information about when some of those species went extinct (which timestep) and during which simulation
    (0 = burn-in and 1 = second simulation post perturbation), as well as the biomass of each species averaged over the last week (7 days)
    of the simulation
To provide some biological context, a specialist species will have a small outdegree value
    (they consume few prey species), whereas a generalist species will have a large outdegree value (they consume many prey species).
    Also, a basal species might be expected to have a large indegree value (a lot of species consume them), whereas a large predator near
    the top of the food web will have a small indegree value (few species consume them)
=#

# here we create a dataframe of S rows (100) by preallocating the column names and size of the dataframe,
# and filling it with NaNs (same as NAs in R)
species_data = DataFrame(fill(NaN,S,8), [:ID, :TL, :M, :indegree, :outdegree, :extinction_time, :extinction_sim, :biomass0])
species_data.ID = collect(1:100)
species_data.TL .= p[:trophic_rank]
species_data.M .= p[:bodymass]
species_data.indegree .= vec(sum(A, dims = 1))
species_data.outdegree .= vec(sum(A, dims = 2))
species_data[p[:extinctions],:extinction_sim] .= Int.(zeros(length((p[:extinctions]))))
species_data[p[:extinctions], :] # view the dataframe for species that went extinct during the burn-in (38 species went extinct)
species_data.biomass0 = population_biomass(s, last = 7) #average population biomass over the last year

# here we construct a dataframe for community level metrics by preallocating the type and name of each column
community_data = DataFrame([Int64, Float64, Float64, Float64],[:harvesting_event, :total_biomass, :persistence, :richness])
# populate community_data using push!
push!(community_data, [0, total_biomass(s, last = 500), species_persistence(s, last = 500), species_richness(s, last = 500)])
# again, we've used 0 to indicate the burn in phase
# we could also have calculated stability or diversity, or some other out of the box metrics like network height (max TL)
# or size structure (the realised Z value of the community)

#=
Step 5: Save/update the biomass of each species so that it matches their biomasses at equilibrium
Basically, extract biomass of each species at the end of the first simulation
=#
b1 = s[:B][end,:] # b1 will serve as a starting point for our next simulation

#=
Step 6: Set harvesting rule and harvesting rate

Here, we set a rule for the harvesting of a species or a group of species in the model
As an example we're going to harvest species that have a body mass greater than the median body mass of the
    community (we are selecting the largest species)
We're going to fix the harvesting rate at 0.6 per simulation, i.e., we remove 40% of the biomass
    of those selected species at the start of each simulation, where one simulation can be considered as a single harvesting event
This type of harvesting is analogous to the use of a knife-edge fishing scenario via which fishing
    pressure is imposed at a constant rate above a certain size threshold
Knife-edge fishing scenarios are commonly used to recreate bottom trawling, where large fish
    are targetted and nets are designed to allow small fish to escape (mesh size restrictions
    are a common fisheries management tool)
=#
M = p[:bodymass] #extract body mass values for all species

#calculate the median - this helps define the rule for the size based harvesting
harvest_rule = median(M)

# set the % loss value for the harvesting
# this might be high for infrequent pelagic trawling
# or low for frequent bottom trawling
harvest_rate = 0.6 # set the rate of harvesting

#=
Step 7: Loop through simulations of several harvesting events
=#

sims = 10 # number of simulations/harvesting events

# Set the frequency of harvesting events - here, we're harvesting once per year
# harvesting once per year might be more reflective of pelagic trawling,
# where fishing is infrequent but at very high rates
# harvesting 1/month might be more reflective of bottom trawling,
# where fishing is frequent but at a lower rate
tstop_harvesting = Int(60*60*24*364.25)

# Set the frequency to collect biomass data 
tkeep_harvesting = Int(60*60*24) # again, save data every day

# the Loop
for i in 1:sims

    #=
    Step 7a: create a vector of already extinct species from the Burn-in.
    =#
    is_extinct_0 = falses(S) # make a vector of 0's (falses) the size of S
    is_extinct_0[p[:extinctions]] .= true # set extinction species to 1 (true)

    #=
    Step 7b: create a vector of the species that will be subject to harvesting based on our
        chosen harvesting rule and then impose harvesting
    =#

    # here we identify species that will be targeted with harvesting:
    # - 1. they have a mass defined by the harvesting rule
        # (> than the median size in this example)
    # - 2. they are not already extinct from the burn-in
    to_harvest_all = M .> harvest_rule
    to_harvest_nonextinct = (to_harvest_all) .& (.!is_extinct_0)

    # NOW: reduce the biomass of our selected species by harvest_rate
    b1[to_harvest_nonextinct] = b1[to_harvest_nonextinct] .* harvest_rate

    #=
    Step 7c: Simulate forward
    =#

    #run the simulation for another year == another harvesting event in this example
    s1 = simulate(p, b1, stop = tstop_harvesting, interval_tkeep = tkeep_harvesting)

    #=
    Step 7d: update biomasses
    =#
    b1 = s1[:B][end,:]

    #=
    Step 7e: Update the community level dataframe
    =#
    # using push!
    # average metrics over the last week of the year (7 days)
    push!(community_data, [i, total_biomass(s1, last = 7), species_persistence(s1, last = 7), species_richness(s1, last = 7)])

    #=
    Step 6f: Update the species level dataframe
    =#

    # first identify any newly extinct species (this year) in response to harvesting
    # is_extinct_1 is global so we can use it outside of the loop
    global is_extinct_1 = falses(S)
    global is_extinct_1[p[:extinctions]] .= true

    # these are the new extinctions
    new_extinct = findall(is_extinct_1 .!= is_extinct_0)

    # for newly extinct species, specify that they went extinct during the ith simualtion
    # by setting :extinction_sim in species_data as i
    species_data[new_extinct,:extinction_sim] .= fill(float(i),length(new_extinct))

    # get the biomass of all species at the end of simulation i
    # again, biomass averaged over the last 7 days
    bi = population_biomass(s1, last = 7)

    # create a new column and append to the species_data dataframe
    # this the new equilibrium after harvesting in year i
    col_name = Symbol("biomass$i")
    insertcols!(species_data, (col_name => bi))

    println("harvesting event = $i")
end

#=
Step 8 - update information in species data to include extiction times
- for all extinct species, we specify the time step at which they went extinct
- this can be done at the end of all runs because p[:extinctionstime] is not
    overwritten and keeps records of extinction times
=#

# all the extinction times for all years and all events
#this vector is ordered by time of extinction and not species id so we need to reorder it
ext_time = p[:extinctionstime]

#extract species identity from this object
ext_time_sp = [i[2] for i in ext_time]

#create a vector to order by identity
sort_extinct = sortperm(ext_time_sp)

# reorder by identity rather than time so we can add to data frame
ext_time_ts = [i[1] for i in ext_time[sort_extinct]]

#pass extinction times to the species_data dataframe
species_data[is_extinct_1,:"extinction_time"] .= ext_time_ts

#=
Step 9 - Make some pictures
=#

community_data
species_data

#  biomass and species richness versus harvest event (n = 10 events)
p1=plot(community_data[!,"harvesting_event"], community_data[!,"total_biomass"], legend = false)
    xlabel!("Harvest Event")
    ylabel!("Total Biomass")
p2=plot(community_data[!,"harvesting_event"], community_data[!,"richness"], legend = false)
    xlabel!("Harvest Event")
    ylabel!("Species Richness")
plot(p1, p2, layout=(1,2))

# extinction time versis Mass and Out-degree
p3=plot(log10.(species_data[!,"M"]), log10.(species_data[!,"extinction_time"]),
    seriestype = :scatter, legend = false)
    xlabel!("log10(Mass)")
    ylabel!("log10(Extinction Time")
p4=plot(species_data[!,"outdegree"], log10.(species_data[!,"extinction_time"]),
    seriestype = :scatter, legend = false)
    xlabel!("Out-degree")
    ylabel!("log10(Extinction Time")

plot(p3, p4, layout=(1,2))

# all 4
plot(p1,p2, p3, p4, layout=(2,2))

# THE END #