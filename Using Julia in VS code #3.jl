###################################################################################################################################################################
# Date - 6th October 2020
# Authors - Chris Griffiths and Eva Delmas
# Title - Using Julia in VS code #3
###################################################################################################################################################################
# This doc follows on from "Using Julia in VS code #1" and "Using Julia in VS code #2" and assumes that your still working from your directory
import Pkg
Pkg.add("JLD2") # Installing the JLD2 package
using Plots, DataFrames, Distributions, Random, EcologicalNetworks, BioEnergeticFoodWebs, DelimitedFiles, CSV, JLD2 # Reload packages if needed
Pkg.status() # Check packages and versions

# Before we start, make a folder in the directory called out_objects (right click>New Folder)

# This doc aims to introduce the EcologicalNetworks and BioEnergeticFoodWebs packages and recreate the first example in Delmas et al. 2017 MEE 
# Check out the paper before we start - https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713

# Aim of example 1 - investigate the effect of increasing the carrying capacity of the resource (K) on food web diversity
# Also we're going to vary alpha (the amount of interspecific competition relative to intraspecific competition) and repeat the simulations 5 times (with 5 different food web networks)

Random.seed!(21)

# (1) Step one - create arrays for alpha and K
a = [0.92, 1.0, 1.08] # Alpha array
# 0.92 = promotes coexistence of producer species through "facilitation"
# 1.0 = Neutral 
# 1.08 = promotes competitive exclusion among producer species
K = exp10.(range(-1, 1, length=10)) # K array - log scale from 0.1 to 10

reps = 5 # Number of unique food web networks

# (2) Step two - create a dataframe to store output
df = DataFrame(alpha = [], K = [], network = [], diversity = [], stability = [], biomass = [])
# and the out_objects folder (if you have already manually created it): 
mkdir("out_objects/")

# (3) Construct 5 random networks with 20 species and an connectance of 0.15
global networks = []
global l = length(networks)
while l < reps # make sure we get 5 networks with the right connectance value (connectance can vary dramatically)
    A_bool = EcologicalNetworks.nichemodel(20, 0.15) # Use the niche model from the Ecological Networks package to create a random network with 20 species and a connectance of 0.15
    A = Int.(A_bool.A) # Convert the UnipartiteNetwork object that is created into a matrix of 1s and 0s
    co = sum(A)/(size(A,1)^2) # Calculate connectance of the network A
    if co == 0.15
        push!(networks, A) # Save network if connectance = 0.15
    end
    global l = length(networks) # Keep count 
end
#In the packages used here, the interactions matrices are directed from i to j (i eats j), describing the direction of the interaction, not of the biomass flow!

# (4) Run simulation 
for h in 1:reps # Loop over networks
    A = networks[h] # Use network h
    # Here you might want to save a copy of the intial matrix structure, this can done using writedlm()

    for i in 1:length(a) # Loop over a and K
        for j in 1:length(K)
            
            # Create model parameters object:
            p = model_parameters(A, α = a[i], K = K[j], productivity = :competitive) # here you specify any non-default parameters of interest and provide the network matrix (A)
            # The possible arguments that can be passed into model_parameters are many, make sure you type ?model_parameters in the REPL and review the text, alternatively visit: 
            # NOTE - In the MEE paper, the following argument is used (productivity = :competitive) to specify that species compete with themselves at a rate of 1.0, and with one another at a rate of α - unfortuntely, this is producing a strange error at the moment - we'll look into it.

            # We start every simualtion by assigning starting biomasses to each species
            bm = rand(size(A,1)) # Select biomass at random between ]0:1[
            
            # Run model using the simulate
            #use=:stiff says you want to use a stiff algorithm to solve the equation, you can also use :nonstiff, it's faster but less accurate
            #you can change the extinction threshold, here we use the same as in the paper, the default is 1e-6, you shouldn't go lower that 1e-16, which is close to the machine epsilon (type eps() for the exact value) 
            out = simulate(p, bm, start=0, stop = 2000, use = :stiff, extinction_threshold = eps()) # Requires the model_parameters object and the biomass object. The start and stop arguments are pretty self explanatory.
            # Again, we advised typing ?simulate into the REPL. 
            # Here, it might be useful to write out your model object, the best way to do this is using the JDL2 package. JDL2 is a Julia file type that can be read back into Julia easily using the @load macro and can be handled by other coding platform e.g. R. 
            # You can write out JLD2s file using the @save macro:
            a_num = a[i] # dummy for alpha - naming purposes
            K_num = K[j] # dummy for K - naming purposes
            @save "out_objects/model_output, network = $h, alpha = $a_num, K = $K_num.jld2" out # save model object in out_objects folder

            # Calculate output metrics
            diversity = foodweb_evenness(out, last=1000) # 
            stability = population_stability(out, last=1000)
            biomass = total_biomass(out, last=1000)

            push!(df, [a[i], K[j], h, diversity, stability, biomass]) # Push each line to our dataframe

            # Print some stuff... (I like to know how my simualtion is going!)
            println(("alpha = $a_num", "carrying capacity = $K_num", "network no: $h")) # The $ function is great here. 
        end
    end
end
# NOTE - if you remove the @save command the code gets alot faster

# (5) Output data and explore
# Mess around with the simulate object (stored as a dictionary called out)
# Read in an model object (feel free to pick an out object in your out_objects folder)
@load "out_objects/model_output, network = 1, alpha = 0.92, K = 0.1.jld2" # Will load the out object
# The out object has 3 slots:
# (1) :p - lists the model parameters
# (2) :B - estimated biomass (species * time)
# (3) :t - time steps of the model (this won't be 1,2,3.... because 'time steps' refers to the time step of the ODE solver - usually steps of 0.25)
bio = out[:B] # extract biomass
time = out[:t] # extract time 
plot(time, bio, legend = false, ylabel = "biomass", xlabel = "time", ylims = (0,0.5)) # plot species biomass throught time - typically the biomass will either flatline (stable dynamics) or will enter transient dynamics (up and downs etc)
sp = out[:p][:S] # Number of species in the system - should be 20
extinct = out[:p][:extinctions] # Identity of extinct species?
pers = 1 - length(extinct) / sp # Persistence = proportion of species remaining

# Look at the dataframe:
describe(df) # prints the dataframe
last(df,6) # last 6 rows
first(df, 6) # first 6 rows

#=
Let's reproduce fig.1 of the paper
y = foodweb diversity measured as their evenness (which quantifies how close in biomass each species in a food web is)
x = carrying capacity 
by = strength of inter- vs intraspecific competition
=#
p = plot([NaN], [NaN], label = "", ylims = (0,1.1), leg = :bottomright, foreground_color_legend = nothing) #initialize a plot
shp = [:square, :diamond, :utriangle]
clr = [RGB(174/255, 139/255, 194/255), RGB(188/255, 188/255, 188/255), RGB(124/255, 189/255, 122/255)]
ls = [:solid, :dash, :dot]
lbl = ["Coexistence", "Neutral", "Exclusion"]
for (i, α) in enumerate(a)
    tmp = df[df.alpha .== α,:] #subset values of interest
    tmp = tmp[.!(isnan.(tmp.diversity)),:] #remove NaN values
    meandf = by(tmp, :K, :diversity => mean)
    plot!(p, log10.(meandf.K), meandf.diversity_mean
        , msc = clr[i], mc = :white, msw = 3, markershape = shp[i]
        , linestyle = ls[i], lc =  clr[i], lw = 2
        , label = lbl[i]
        , seriestype = [:line :scatter])
end
xticks!(log10.(K), string.(round.(K, digits = 1)))
xlabel!("Carrying capacity")
ylabel!("Food web diversity (evenness)")
plot(p)

# Write out your data
CSV.write("My_data.csv", df)