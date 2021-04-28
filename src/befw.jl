### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 58837362-4ea9-11eb-203b-c1ddc9983e1c
using Plots, DataFrames, Distributions, Random, EcologicalNetworks, BioEnergeticFoodWebs, DelimitedFiles, CSV, JLD2

# ╔═╡ c0ebcd72-4185-11eb-1f7a-495100d90da7
md"# Intro to BioEnergeticFoodWebs

*by Chris Griffiths, Eva Delmas and Andrew Beckerman, Dec. 2020.*"

# ╔═╡ 02d42d26-4ea9-11eb-0037-29e78216697e
md"
This doc follows on from 'Using Julia in VS code #1' and 'Using Julia in VS code #2' and assumes that your still working from your directory.

Before we start, make a folder in the directory called out_objects (right click>New Folder)

This doc aims to introduce the BioEnergeticFoodWebs package and recreate the first example in [Delmas et al. 2017 MEE](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713). Check out the paper before we start.
"

# ╔═╡ 4d456ac8-4ea9-11eb-24be-3181d81cea4e
md"## Load the packages"

# ╔═╡ 6ff71d64-4ea9-11eb-3e32-1fa7bfeef163
md"
- `Plots` for... plotting
- `DataFrames` for using and manipulating data frames
- `Distributions` to define various distributions
- `Random` for added randomness (and for setting the seed) 
- `EcologicalNetworks` for building, manipulating and analysing food webs
- `BioEnergeticFoodWebs` for simulatimng biomass dynamics in food webs
- `DelimitedFiles` for reading and writing delimited files 
- `CSV` for reading and writing CSV
- `JLD2` for saving and loading Julia object in their native format
"

# ╔═╡ 38e8575e-4eaa-11eb-2843-cbefb55fb1f9
md"Let's set a random seed for reproducibility"

# ╔═╡ 44e9c512-4eaa-11eb-2a1a-53b024da1311
Random.seed!(21)

# ╔═╡ e20123b4-4ea9-11eb-3e7c-570c8c04e3ec
md"
## Reproduce figure 1

The aim of this first example is to investigate the effect of increasing the carrying capacity of the resource (K) on food web diversity, also we're going to vary alpha (the amount of interspecific competition relative to intraspecific competition) and repeat the simulations 5 times (with 5 different food web networks). See [figuer 1 of the paper](https://besjournals.onlinelibrary.wiley.com/cms/asset/bd3b7b2a-4528-47d7-9f9b-57af19e2c0c0/mee312713-fig-0001-m.png).

First, we want to define the experimental design: 
"

# ╔═╡ 76a28a94-4eaa-11eb-3677-0bce632c9572
# create arrays for alpha and K
a = [0.92, 1.0, 1.08] # Alpha array
# 0.92 = promotes coexistence of producer species through "facilitation"
# 1.0 = Neutral 
# 1.08 = promotes competitive exclusion among producer species

# ╔═╡ af85ded0-4eaa-11eb-0434-df7f39a2172a
K = exp10.(range(-1, 1, length=10)) # K array - log scale from 0.1 to 10

# ╔═╡ bc148726-4eaa-11eb-103e-0d40e15d7b95
reps = 5 # Number of unique food web networks

# ╔═╡ bf4f56be-4eaa-11eb-1487-f1747aab8d4e
md"Then, we create a data frame to store the outputs"

# ╔═╡ cec73ec2-4eaa-11eb-223d-c3f6707a8ba3
df = DataFrame(alpha = [], K = [], network = [], diversity = [], stability = [], biomass = [])

# ╔═╡ d332dcee-4eaa-11eb-0cf5-33bd128825cd
md"If you have not already created the `out_objects` folder, creae it now by using:"

# ╔═╡ f1213a72-4eaa-11eb-2117-49e624afa4fe
mkdir("out_objects/")

# ╔═╡ f9545abc-4eaa-11eb-3ef5-a7c1f1d61b62
md"Now we generate our 5 food webs using [the niche model](https://www.nature.com/articles/35004572?cacheBust=1510239451067). Each food web has 20 species and a [connectance](https://en.wikipedia.org/wiki/Ecological_network) of 0.15"

# ╔═╡ 5a71c630-4eac-11eb-3acd-b173c3cae180
global networks = [] #this array will store the generated food webs

# ╔═╡ 8102aed6-4eac-11eb-1779-418c7480b59c
begin
	global l = length(networks) #this global variable will monitore the number of food webs generated
	while l < reps # make sure we get 5 networks with the right connectance value (connectance can vary dramatically)
    	A_bool = EcologicalNetworks.nichemodel(20, 0.15) # Use the niche model from the Ecological Networks package to create a random network with 20 species and a connectance of 0.15
   		A = Int.(A_bool.A) # Convert the UnipartiteNetwork object that is created into a matrix of 1s and 0s
    	co = sum(A)/(size(A,1)^2) # Calculate connectance of the network A
    	if co == 0.15
        	push!(networks, A) # Save network if connectance = 0.15
    	end
    	global l = length(networks) # Keep count 
	end
end

# ╔═╡ 94947bdc-4eac-11eb-0659-afb90ebc53db
md"**Important note**: In the packages used here, the interactions matrices are directed from i to j (i eats j), describing the direction of the interaction, not of the biomass flow!"

# ╔═╡ 590f9e6a-4ead-11eb-31f1-2718dd772637
md"We can now run the simulations:"

# ╔═╡ 73952ad4-4ead-11eb-20a2-c5fe4d7636f9
for h in 1:reps # Loop over networks
    A = networks[h] # Use network h
    # Here you might want to save a copy of the intial matrix structure, this can done using writedlm()

    for i in 1:length(a) # Loop over a and K
        for j in 1:length(K)
            
            # Create model parameters object:
            p = model_parameters(A, α = a[i], K = [K[j]], productivity = :competitive) # here you specify any non-default parameters of interest and provide the network matrix (A)
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
            #@save "out_objects/model_output, network = $h, alpha = $a_num, K = $K_num.jld2" out # save model object in out_objects folder

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

# ╔═╡ 9ad396b2-4ead-11eb-3397-27deb2fac788
md"
Now we can explore the outputs.

The simulation objects are stored asDictionnaries called `out`. You can read in an model object (feel free to pick an out object in your `out_objects` folder).
"

# ╔═╡ 8eff0720-4ead-11eb-0162-23d98c504782
@load "out_objects/model_output, network = 1, alpha = 0.92, K = 0.1.jld2" # Will load the out object
# The out object has 3 slots:
# (1) :p - lists the model parameters
# (2) :B - estimated biomass (species * time)
# (3) :t - time steps of the model (this won't be 1,2,3.... because 'time steps' refers to the time step of the ODE solver - usually steps of 0.25)

# ╔═╡ 186967da-4eae-11eb-3c46-69fc62e62802
bio = out[:B] # extract biomass

# ╔═╡ 25553156-4eae-11eb-1a1d-33a9342a65fa
time = out[:t] # extract time steps

# ╔═╡ 2b6ab07a-4eae-11eb-1202-2987cf72b5bc
plot(time, bio, legend = false, ylabel = "biomass", xlabel = "time", ylims = (0,0.5)) # plot species biomass throught time - typically the biomass will either flatline (stable dynamics) or will enter transient dynamics (up and downs etc)

# ╔═╡ fbcd149c-4eb0-11eb-0745-1b5d4c48cfee
sp = out[:p][:S] # Number of species in the system - should be 20

# ╔═╡ 39102932-4eae-11eb-36ac-534ef3f4fd77
# Some species reach a biomass of approx. 0 during the simulations and are considered as extinct at the end of the simulations
extinct = out[:p][:extinctions] # Identity of extinct species?

# ╔═╡ 3d233c30-4eae-11eb-36e9-83e20800c624
pers = 1 - length(extinct) / sp # Persistence = proportion of species remaining

# ╔═╡ 5e80eb3c-4eae-11eb-3177-db8b9c53fec8
describe(df) # prints the dataframe

# ╔═╡ 65256c38-4eae-11eb-110f-fbf4b36e3bff
last(df,6) # last 6 rows

# ╔═╡ 6a3d6b62-4eae-11eb-2d0a-4ba8bbe18ad8
first(df, 6) # first 6 rows

# ╔═╡ 71f39ac0-4eae-11eb-22bd-8537a3283cc1
md"
Now that we know more about the simulations and the outputs, let's reproduce fig. 1.
- y = foodweb diversity measured as their evenness (which quantifies how close in biomass each species in a food web is)
- x = carrying capacity 
- by = strength of inter- vs intraspecific competition
"

# ╔═╡ a0b4edd4-4eae-11eb-3d1e-5f7f1f5cda75
p = plot([NaN], [NaN]
	, label = ""
	, ylims = (0,1.1)
	, leg = :bottomright
	, foreground_color_legend = nothing
	, xticks = (log10.(K), string.(round.(K, digits = 1)))
	, xlabel = "Carrying capacity"
	, ylabel = "Food web diversity (evenness)") #initialize an empty plot

# ╔═╡ a58679b6-4eae-11eb-2dcd-0f94734e4a90
shp = [:square, :diamond, :utriangle] #shapes of the markers

# ╔═╡ 27a6e230-4eb1-11eb-3fbd-a14ae81f4431
md"Note that when we define colors in Julia, they are printed, that's pretty cool:"

# ╔═╡ af03b18e-4eae-11eb-1de9-51286ad67174
clr = [RGB(174/255, 139/255, 194/255), RGB(188/255, 188/255, 188/255), RGB(124/255, 189/255, 122/255)] #define the colors (you can see the Colors package for more information on how to define colors, or the palettes available)

# ╔═╡ ce0c078e-4eae-11eb-115a-356056716a9a
ls = [:solid, :dash, :dot] #line styles

# ╔═╡ d4b1b9bc-4eae-11eb-00d7-6735a961c377
lbl = ["Coexistence", "Neutral", "Exclusion"] #legend labels

# ╔═╡ da976854-4eae-11eb-0f53-25aca51dc56b
#now make the plot
for (i, α) in enumerate(a)
    tmp = df[df.alpha .== α,:] #subset values of interest
    tmp = tmp[.!(isnan.(tmp.diversity)),:] #remove NaN values
    meandf = by(tmp, :K, :diversity => mean)
	l = i == 1 ? lbl[i] : ""  
    plot!(p, log10.(meandf.K), meandf.diversity_mean
        , msc = clr[i], mc = :white, msw = 3, markershape = shp[i]
        , linestyle = ls[i], lc =  clr[i], lw = 2
        , label = lbl[i]
        , seriestype = [:line :scatter])
end

# ╔═╡ 6d6eb46c-4eb1-11eb-338a-ab3a47757826
# display the plot 
plot(p)

# ╔═╡ 7c28a770-4eb2-11eb-0f77-473cad356c6c
# Write out your data
CSV.write("My_data.csv", df)

# ╔═╡ Cell order:
# ╟─c0ebcd72-4185-11eb-1f7a-495100d90da7
# ╟─02d42d26-4ea9-11eb-0037-29e78216697e
# ╟─4d456ac8-4ea9-11eb-24be-3181d81cea4e
# ╟─6ff71d64-4ea9-11eb-3e32-1fa7bfeef163
# ╠═58837362-4ea9-11eb-203b-c1ddc9983e1c
# ╟─38e8575e-4eaa-11eb-2843-cbefb55fb1f9
# ╠═44e9c512-4eaa-11eb-2a1a-53b024da1311
# ╟─e20123b4-4ea9-11eb-3e7c-570c8c04e3ec
# ╠═76a28a94-4eaa-11eb-3677-0bce632c9572
# ╠═af85ded0-4eaa-11eb-0434-df7f39a2172a
# ╠═bc148726-4eaa-11eb-103e-0d40e15d7b95
# ╟─bf4f56be-4eaa-11eb-1487-f1747aab8d4e
# ╠═cec73ec2-4eaa-11eb-223d-c3f6707a8ba3
# ╟─d332dcee-4eaa-11eb-0cf5-33bd128825cd
# ╠═f1213a72-4eaa-11eb-2117-49e624afa4fe
# ╟─f9545abc-4eaa-11eb-3ef5-a7c1f1d61b62
# ╠═5a71c630-4eac-11eb-3acd-b173c3cae180
# ╠═8102aed6-4eac-11eb-1779-418c7480b59c
# ╟─94947bdc-4eac-11eb-0659-afb90ebc53db
# ╟─590f9e6a-4ead-11eb-31f1-2718dd772637
# ╠═73952ad4-4ead-11eb-20a2-c5fe4d7636f9
# ╟─9ad396b2-4ead-11eb-3397-27deb2fac788
# ╠═8eff0720-4ead-11eb-0162-23d98c504782
# ╠═186967da-4eae-11eb-3c46-69fc62e62802
# ╠═25553156-4eae-11eb-1a1d-33a9342a65fa
# ╠═2b6ab07a-4eae-11eb-1202-2987cf72b5bc
# ╠═fbcd149c-4eb0-11eb-0745-1b5d4c48cfee
# ╠═39102932-4eae-11eb-36ac-534ef3f4fd77
# ╠═3d233c30-4eae-11eb-36e9-83e20800c624
# ╠═5e80eb3c-4eae-11eb-3177-db8b9c53fec8
# ╠═65256c38-4eae-11eb-110f-fbf4b36e3bff
# ╠═6a3d6b62-4eae-11eb-2d0a-4ba8bbe18ad8
# ╟─71f39ac0-4eae-11eb-22bd-8537a3283cc1
# ╠═a0b4edd4-4eae-11eb-3d1e-5f7f1f5cda75
# ╠═a58679b6-4eae-11eb-2dcd-0f94734e4a90
# ╟─27a6e230-4eb1-11eb-3fbd-a14ae81f4431
# ╠═af03b18e-4eae-11eb-1de9-51286ad67174
# ╠═ce0c078e-4eae-11eb-115a-356056716a9a
# ╠═d4b1b9bc-4eae-11eb-00d7-6735a961c377
# ╠═da976854-4eae-11eb-0f53-25aca51dc56b
# ╠═6d6eb46c-4eb1-11eb-338a-ab3a47757826
# ╠═7c28a770-4eb2-11eb-0f77-473cad356c6c
