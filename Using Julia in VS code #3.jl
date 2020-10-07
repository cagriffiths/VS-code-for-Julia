###################################################################################################################################################################
# Date - 6th October 2020
# Authors - Chris Griffiths and Eva Delmas
# Title - Using Julia in VS code #3
###################################################################################################################################################################
# This doc follows on from "Using Julia in VS code #1" and "Using Julia in VS code #2"
import Pkg
using Plots, DataFrames, Distributions, Random, EcologicalNetworks, BioEnergeticFoodWebs, DelimitedFiles # Reload packages if needed
Pkg.status() # Check packages and versions

# This doc aims to introduce the EcologicalNetworks and BioEnergeticFoodWebs packages and recreate the first example in Delmas et al. 2017 MEE 
# Check out the paper before we start - https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713

# Aim of example 1 - investigate the effect of increasing the carrying capacity of the resource (K) on food web diversity
# Also going to vary alpha (the amount of interspecific competition relative to intraspecific competition) and repeat the simulations 10 times (with 10 different food web networks)

Random.seed!(21)

# (1) Step one - create arrays for alpha and K
a = [0.92, 1.0, 1.08] # Alpha array
# 0.92 = 
# 1.0 = 
# 1.08 = 
K = exp10.(range(-1, 1, length=10)) # K array - log scale from 0.1 to 10

reps = 10 # Number of unique food web networks

# (2) Step two - create a dataframe to store output
df = DataFrame(alpha = [], K = [], network = [], diversity = [], stability = [], biomass = [])

# (3) Construct 10 random networks with 20 species and an connectance of 0.15
global networks = []
global l = length(networks)
while l < reps # make sure we get 10 networks with the right connectance value (connectance can vary dramatically)
    A_bool = EcologicalNetworks.nichemodel(20, 0.15) # Use the niche model from the Ecological Networks package to create a random network with 20 species and a connectance of 0.15
    A = Int.(A_bool.A) # Convert the UnipartiteNetwork object that is created into a matrix of 1s and 0s
    co = sum(A)/(size(A,1)^2) # Calculate connectance of the network A
    if co == 0.15
        push!(networks, A) # Save network if connectance = 0.15
    end
    global l = length(networks) # Keep count 
end

# (4) Run simulation 
for h in 1:length(reps) # Loop over networks
    A = networks[h] # Use network h

    for i in 1:length(a) # Loop over a and K
        for j in 1:length(K)

            p = model_parameters(A, α = a[i], K = K[j], productivity = :competitive) # Create the models parameters - within this find all the parameters in the model - further putting ?model_parameters in the REPL and giving it a read

            bm = rand(size(A,1))
            out = simulate(p, bm, start=0, stop = 2000)

            # Calculate output metrics
            diversity = foodweb_evenness(out, last=1000) 
            stability = population_stability(out, last=1000)
            biomass = total_biomass(out, last=1000)

            push!(df, [a[i], K[j], h, diversity, stability, biomass])

            a_num = a[i]
            K_num = K[j]
            println(("alpha = $a_num", "carrying capacity = $K_num", "network no: $h"))
        end
    end
end

# (5) Output data and explore



- use the niche model to propose a network 