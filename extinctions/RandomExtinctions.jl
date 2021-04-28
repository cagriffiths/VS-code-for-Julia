#=
Extinction cascade tutorial
This script shows how to
- initialize the BEFWm with a food web and your choice of parameters
- run a burn-in to remove structurally doomed species
    (to avoid detecting them as false secondary extinctions) and achieve equilibrium dynamics
- target a species for primary extinction
- run the model
- detect secondary extinctions / measure things
=#

# Packages
import Pkg
using BioEnergeticFoodWebs
using Distributions
using Plots, StatsPlots
using DataFrames
using EcologicalNetworks

# Make sure you are using the right BEFW! (dev-1.3.0)
Pkg.status()

# Set seed
import Random.seed!
seed!(5436) # setting a seed makes it possible to replicate exactly the same results, even when there is randomness involved

#=
## STEP 1: GENERATE FOOD WEB  ##
- using the niche model    
- we initialize with 100 species and a connectance of 0.2
=#
S = 100 # number of species
con = 0.2 # connectance
A_bool = EcologicalNetworks.nichemodel(S,con) # use niche model to generate network
A = adjacency(A_bool)
A = Int.(A)
A_id = hash(A)
#=
## STEP 2: SET MODEL PARAMETERS ##
Here we are running a very basic simulation, with:
- h (hill exponent) = 2 (Type III functional response - stabilising)
- K (carrying capacity for basal species / producers) = 10
- Z = (consumer-resource size ratio) = 10.0 (consumers are 10x bigger than resources)
=#
p = model_parameters(A, rewire_method = :DS, h = 2.0, K = [10.0], Z = 10.0)

#=
## STEP 3: THE BURN IN ##
Removes the structurally doomed species and achieve equilibrium dynamics
=#

## Running the burn in
b0 = rand(S) # set some initial biomasses at random
s = simulate(p, b0, stop = 2000) # simulate
plot(s[:B], legend = false) # plot


## STEP 4: CREATE DATAFRAMES TO STORE DATA ##
#=
4a) making and filling a dataframe for species level info such as:
    - trophic level
    - in degree (number of species that eat them)
    - out degree (number of species they eat)
    - time step (when they went extinct)
    - simulation (which simulation they went extinct in e.g. 0 = burn in and 1 = second simulation post pertubation)
=#
# 1) make an empty data frame with S rows (100, same as the S - the number of species)
    # Done by preallocating the column names and size of the dataframe and filling it with NaNs (same as NAs in R)
species_data = DataFrame(fill(NaN,S,7), [:ID, :TL, :M, :indegree, :outdegree, :extinction_time, :extinction_sim]) # s = no. of rows, 7 = no. of columns

# 2) Fill in some of the empty dataframe with the details from the end of the burn in
    # write the name of the data frame and then .column name to specify which column you want the info to go into
# species names
species_data.ID = collect(1:S) # note that S is the number of Species (at this point 100)
# species Trophic Level (their rank)
species_data.TL .= p[:trophic_rank]
# species mass
species_data.M .= p[:bodymass]
# species indegree
species_data.indegree .= vec(sum(A, dims = 1))
# species outdegree
species_data.outdegree .= vec(sum(A, dims = 2))
# species extinsions_sim
species_data[p[:extinctions],:extinction_sim] .= Int.(zeros(length((p[:extinctions]))))

# View the dataframe for species that went extinct during the burn-in (38 species went extinct)
    # NOTE THAT species extinsions_time is filled in AFTER everthing is done (see the very end)
species_data[p[:extinctions], :]

#=
4b) making and filling a dataframe for comunity level info such as:
    - Total biomass
    - Species persistence
    - Species richess
    - Rx (the proportion of species left after an extinction out of the orrigional number of S)
=#
# 1) make the empty dataframe
community_data = DataFrame([Int64, Float64, Float64, Float64, Float64],[:sim, :total_biomass, :persistence, :richness, :R_x])

# 2) populate some of the empty dataframe with data from the burn in using push!
    # 0 = the first simulation (sim column) which is the burn in phase
    # uses an average of the last 500 time steps of the burn in phase 
    # a new line will be added for each simulation 
push!(community_data, [0, total_biomass(s, last = 500), species_persistence(s, last = 500), species_richness(s, last = 500), species_richness(s, last = 500)/S])

#=
## STEP 5: SAVE BIOMASSES FROM BURN IN ##
Extracts biomass of each species at the end of the first simulation (burn in) so that we can start the next simulation from that point
=#
b1 = s[:B][end,:] # b1 will serve as a starting point for our next simulation

#=
## STEP 6: CREATE PRIMARY EXTINCTION ##
- Using a while loop, loop through primary extinction events until 50% (R50) of all species have gone extinct
- Here, we will remove species in decending order from the largest to the smallest based on TL
- We can only remove species that are persistent in the community and have to take this into account when looping.
- After each simulation/loop our databases (species_data and community_data) will be updated
    and our i counter will be updated based on the species richness of the community
=#

#=
Step 6a:
- Estimate species richness at the end of the burnin as our reference point for R50.
- we calcuate that with the species_richness function applied to the burnin simulations
=#
global i = species_richness(s, last = 500) #we need the global macro to be able to use that variable in the while loop
global j = 1.0 # set j to 1 and this will increase for each primary extinction as a way to keep track of them

#=
Step 6b: the while loop
i is from above - the species richness after the burnin....
As long as species richness i is greater than S/2 (R50%), keep going
=#

while i >= S/2 # this could be changed from 100/2 to S after the burn in/2

    println("i = $i and j = $j") # keep track of loop

    #=
    Step 6c: Primary extinction - Random
    =#

    # set a rule for targetting a species, here we are doing random extinctions
    # Make sure that the first species with maximum trait wasn't already extinct
    # and therefore that the removal of species was having the correct effect in our simulations
    
    is_extinct_0 = falses(S) # make a vector of 0's (falses) the size of S
    is_extinct_0[p[:extinctions]] .= true # set extinction species to 1 (true)
    id = species_data.ID
    id_primext = rand(id[.!is_extinct_0]) #randoly select species that are not extinct already

    #=
    Step 6d: Simulate forward (e.g. from where the burnin finished, but now with making an extinction)
    =#
    
    b1[id_primext] = 0.0 #set biomass of primary extinct species to 0
    s1 = simulate(p, b1, stop = 2000) #run the simulation
   
    #=
    Step 6e: Update community dataframe
    =#

    # update community dataframe - easy using push!
    # this calcuates stuff caused by the extinction above
    push!(community_data, [j, total_biomass(s1, last = 500), species_persistence(s1, last = 500), species_richness(s1, last = 500), species_richness(s1, last = 500)/S])
    
    #=
    Step 6f: Update species dataframe
    =#

    # identify any newly extinct species
    global is_extinct_1 = falses(S) # make a data frame the size of S of 0s
    global is_extinct_1[p[:extinctions]] .= true # set extinct species to 1s
    new_extinct = findall(is_extinct_1 .!= is_extinct_0) #find all species that are now extinct in is_extinct_1 that were not in is_extinct_0 as these are the newly extinct species
    
    # for newly extinct species, specify that they went extinct during the jth run by setting
    # :extinction_sim in species_data as j
    # add relevant information to the species_data data frame
    species_data[new_extinct,:extinction_sim] .= fill(j,length(new_extinct))
    
    #=
    Step 6g: Update biomasses again for when the next 1˚ extinction event occurs
    =#
    b1 = s1[:B][end,:]
    
    #=
    Step 6h: Update counters
    =#
    global i = minimum(community_data.richness)
    global j = j + 1.0 
end

## STEP 7: CALCULATE EXTINCT TIME ##
# Following our loop, for all extinct species, we can specify the time step at which they went extinct
# this can be done at the end of the loop because p[:extinctionstime] is not overwritten
# and keeps all records of extinction times

ext_time = p[:extinctionstime] #this vector is ordered by time of extinction and not species id so we need to reorder it
ext_time_sp = [i[2] for i in ext_time] #extract species identity from this object
sort_extinct = sortperm(ext_time_sp) #create a vector to order by identity
ext_time_ts = [i[1] for i in ext_time[sort_extinct]] #use it to reorder extinction times
species_data[is_extinct_1,:extinction_time] .= ext_time_ts #pass extinction times to the data frame

# look at the species data and the community data
# Check out community_data DataFrame
community_data
species_data

## STEP 8: IDENTIFY PRIMARY, SECONDARILY AND NON EXTINCT SPECIES ##
# Primary = ones we set extict
# Secondary = ones that went extinct because of the ones we set extinct 
# this will help with the visualisation
idprimary = findall(species_data.extinction_time .== 0) # find all species in the species_data matrix that have an extinction time of 0
idsecondary = findall(species_data.extinction_time .> 0) # find all species in the species_data matrix that have an extinction time of above 0
idnonextinct = findall(isnan.(species_data.extinction_time)) # find all species in the species_data matrix that have an NaN extinction time

#we can add this information to the data frame: 
species_data.extinction_type = fill("NaN", S) # add species type column to the data frame and fill with NaN
species_data.extinction_type[idprimary] .= "Primary" #rename all idprimary species to primary
species_data.extinction_type[idsecondary] .= "Secondary" # rename all idsecondary species to secondary

## PLOTS## 

# look at the distribution of extinction times
p1 = histogram(species_data[!,"extinction_time"], legend = false)
xlabel!("Extinction Times")

# mass versus extinction time
#extinctions_time is NaN for non extinct species, so they won't be plotted, we don't need to worry about them
p2 = plot((species_data[!, "M"]), log10.(species_data[!, "extinction_time"]),
    seriestype = :scatter, legend = false, c = :black, msw = 0)
    xlabel!("(Mass)")
    ylabel!("(Extinction Time")

#primary extinct VS secondary extinct VS non extinct species in-degree 
p3 = density(species_data.indegree, group = species_data.extinction_type
    , label = ["Non-extinct" "Primary extinctions" "Secondary extinctions"]
    , linestyle = [:dash :dot :solid], lw = 2, xlims = (0,50), leg = :topleft)
xlabel!("In-degree")

# look at richess declining with events
p4 = plot(community_data[!,"sim"], community_data[!,"richness"], legend = false)
xlabel!("Primary Extinction Event")
ylabel!("Richness")

plot(p1, p2, p3, p4, layout=(2,2), size = (700,700))

#Remember that you can save the data frames as csv files using the CSV package 
#and save the plots using the savefig function

# THE END #