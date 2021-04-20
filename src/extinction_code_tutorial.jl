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

# Make sure you are using the right BEFW! (dev-1.3.0)
Pkg.status()

# Set seed
import Random.seed!
seed!(5436) # setting a seed makes it possible to replicate exactly the same results, even when there is randomness involved

#=
Step 1: Import or generate a food web
You can use an empirical food web or use a model (niche model, ADBM...)
    to generate realistic food webs
We start by creating a food web using the niche model
- we initialize with 100 species and a connectance of 0.2
=#
S = 100 # number of species
con = 0.2 # connectance
A = nichemodel(S,con) # use niche model to generate network

#=
Step 2: Set the model parameters
Here we are running a very basic simulation, with:
- h (hill exponent) = 2 (Type III functional response - stabilising)
- K (carrying capacity for basal species / producers) = 10
- Z = (consumer-resource size ratio) = 10.0 (consumers are 10x bigger than resources)
=#
p = model_parameters(A, h = 2.0, K = [10.0], Z = 10.0)

#=
Step 3: Run a burn-in
Run a burn-in phase to remove some structurally doomed species and achieve equilibrium dynamics
We've also provided the code to save some information about each species
(TL, in and out degree) and the community (total biomass, persistence) in two seperate dataframes
=#
b0 = rand(S) # set some initial biomasses at random
s = simulate(p, b0, stop = 2000) # simulate
plot(s[:B], legend = false) # plot

#=
Step 3a
Below, we've created a dataframe that stores species level information for all species in the network,
including their TL, indegree (number species that eat them) and outdegree (number of species that they eat),
as well as information about when some of those species went extinct (which timestep) and
during which simulation (0 = burn-in and 1 = second simulation post perturbation)
To provide some biological context, a specialist species will have a small outdegree value
(the consumer has few prey species), whereas a generalist species will have a large outdegree value
(they consume many prey species). Also, a basal species might be expected to have a large indegree value
(a lot of species consume them), whereas a large predator near the top of the food web will have a small
indegree value (few species consume them)
=#

# we first create a dataframe of S rows (100) by preallocating the column names and size of the dataframe,
# and filling it with NaNs (same as NAs in R)
species_data = DataFrame(fill(NaN,S,7), [:ID, :TL, :M, :indegree, :outdegree, :extinction_time, :extinction_sim])

# Here we fill in some of the details from the end of the burnin

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

# This one line is really valuable:
# view the dataframe for species that went extinct during the burn-in (38 species went extinct)
# NOTE THAT species extinsions_time is filled in AFTER everthing is done (see the very end)

species_data[p[:extinctions], :]

# here we construct a dataframe for community level metrics by preallocating the type and name of each column
# note that R_x is the Rvalue as exinctions arise....

community_data = DataFrame([Int64, Float64, Float64, Float64, Float64],[:sim, :total_biomass, :persistence, :richness, :R_x])

# populate community_data using push!
# again, we've used 0 for this first simulation (sim column) which is the burn in phase
# we could also have calculated stability or diversity, or some other out of the box metrics

# like network height (max TL) or size structure (the realised Z value of the community)
push!(community_data, [0, total_biomass(s, last = 500), species_persistence(s, last = 500), species_richness(s, last = 500), species_richness(s, last = 500)/S])

#=
Step 4: Save the biomass of each species at equilibrium
Basically, extract biomass of each species at the end of the first simulation
=#
b1 = s[:B][end,:] # b1 will serve as a starting point for our next simulation

#=
Step 5: Using a while loop, lets us loop through primary extinction events
 ---> until 50% (R50) of all species have gone extinct!!!!  Wooohoo!
Here, we will remove species in decending order from the largest to the smallest based on TL
The catch here is we can only remove species that are persistent in the community and
        have to take this into account when looping.
After each simulation/loop our databases (species_data and community_data) will be updated
and our i counter will be updated based on the species richness of the community
=#

#=
Step 5a:
- we need to estimate species richness at the end of the burnin as our reference point for R50.
- we calcuate that with the species_richness function applied to the burnin simulations
=#

global i = species_richness(s, last = 500) #we need the global macro to be able to use that variable in the while loop
global j = 1.0

#=
Step 5b: the while loop
i is from above - the species richness after the burnin....
As long as species richness i is greater than S/2 (R50%), keep going
=#

while i >= S/2
    
    println("i = $i and j = $j") # keep track of loop

    #=
    Step 5c: Primary extinction
    =#

    # There are many options here: random extinctions, Large-Small, Top to Bottom.....
    # set a rule for targetting a species, here the consumer with the highest trophic rank
    # this is quite complicated but we've scattered it onto multiple lines to provide clarity (or sanity checks)
    # Basically, we had to make sure that the first species with maximum TL wasn't already extinct
    # and therefore that the removal of species was having the correct effect in our simulations
    
    is_extinct_0 = falses(S) # make a vector of 0's (falses) the size of S
    is_extinct_0[p[:extinctions]] .= true # set extinction species to 1 (true)
    tl = p[:trophic_rank] # calculate trophic rank of each species
    id_sorted = sortperm(tl, rev = true) # create a vector of species identity sorted by decreasing trophic level
    is_extinct_sorted = is_extinct_0[id_sorted] # reorder the extinct vector by species id
    id_primext = id_sorted[.!is_extinct_sorted][1] # select first species that fit our criterion that isn't already extinct
    
    #=
    Step 5d: Simulate forward (e.g. from where the burnin finished, but now with making an extinction!)
    =#
    
    b1[id_primext] = 0.0 #set biomass of primary extinct species to 0
    s1 = simulate(p, b1, stop = 2000) #run the simulation
   
    #=
    Step 5e: Update community dataframe
    =#

    # update community dataframe - easy using push!
    # this calcuates stuff caused by the extinction above
    push!(community_data, [j, total_biomass(s1, last = 500), species_persistence(s1, last = 500), species_richness(s1, last = 500),
        species_richness(s1, last = 500)/S])
    
        #=
    Step 5f: Update species dataframe
    =#

    # identify any newly extinct species
    global is_extinct_1 = falses(S)
    global is_extinct_1[p[:extinctions]] .= true
    new_extinct = findall(is_extinct_1 .!= is_extinct_0)
    
    # for newly extinct species, specify that they went extinct during the jth run by setting
    # :extinction_sim in species_data as j
    # add relevant information to the species_data data frame
    species_data[new_extinct,:extinction_sim] .= fill(j,length(new_extinct))
    
    #=
    Step 5g: Update biomasses again for when the next 1˚ extinction event occurs
    =#
    b1 = s1[:B][end,:]
    
    #=
    Step 5h: Update counters
    =#
    global i = minimum(community_data.richness)
    global j = j + 1.0

end

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

# one thing we can do is to identify primary extinction, secondary extinction and non extinct species
# this will help us with the visualisation
idprimary = findall(species_data.extinction_time .== 0)
idsecondary = findall(species_data.extinction_time .> 0)
idnonextinct = findall(isnan.(species_data.extinction_time))

#we can add this information to the data frame: 
species_data.extinction_type = fill("NaN", S)
species_data.extinction_type[idprimary] .= "Primary"
species_data.extinction_type[idsecondary] .= "Secondary"

# look at the distribution of extinction times
p1 = histogram(species_data[!,"extinction_time"], legend = false)
xlabel!("Extinction Times")

# mass versus extinction time
#extinctions_time is NaN for non extinct species, so they won't be plotted, we don't need to worry about them
p2 = plot(log10.(species_data[!, "M"]), species_data[!, "extinction_time"],
    seriestype = :scatter, legend = false, c = :black, msw = 0)
    xlabel!("log10(Mass)")
    ylabel!("Extinction Time")

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