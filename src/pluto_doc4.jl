### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 58837362-4ea9-11eb-203b-c1ddc9983e1c
using BioEnergeticFoodWebs, EcologicalNetworks, JLD2, Statistics, Plots, CSV, DataFrames, Random

# ╔═╡ c0ebcd72-4185-11eb-1f7a-495100d90da7
md"# Intro to BioEnergeticFoodWebs

*by Chris Griffiths, Eva Delmas and Andrew Beckerman, Dec. 2020.*"

# ╔═╡ 02d42d26-4ea9-11eb-0037-29e78216697e
md"
This document follows on from 'Getting started', 'Basic Julia commands' and 'Differential Equations in Julia' and assumes that you're still working in your active project.

This document introduces the `BioEnergeticFoodWebs.jl` and `EcologicalNetworks.jl` packages. It demonstrates how to run the BioEnergetic Food Web (BEFW) model, how to vary variables of interest (e.g., productivity) and construct experiments designed to investigate the effect of different variables on population and community dynamics. 

For those that are unfamilar with the BEFW and it's application in Julia, we advise checking out the [MEE paper](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713) before we start. Remember, the BEFW model is also based on a system of differential equations and is solved using the same engine as the `DifferentialEquations.jl` package.
"

# ╔═╡ 4d456ac8-4ea9-11eb-24be-3181d81cea4e
md"## Load packages"

# ╔═╡ 6ff71d64-4ea9-11eb-3e32-1fa7bfeef163
md"
You'll need the following packages for this tutorial:
"

# ╔═╡ 38e8575e-4eaa-11eb-2843-cbefb55fb1f9
md"The `JLD2.jl` package will be useful later as it allows you to directly export and load a BEFW output object. Let's also set a random seed for reproducibility:"

# ╔═╡ 44e9c512-4eaa-11eb-2a1a-53b024da1311
Random.seed!(21)

# ╔═╡ e20123b4-4ea9-11eb-3e7c-570c8c04e3ec
md"
## Preamble

One of main advantages of running food web models in Julia is that simulations are fast and can be readily stored in your active project. With this in mind, make a new folder in your project called `out_objects` (right click > New Folder). Alternatively, you can create an `out_objects` folder directly using `mkdir()`."

# ╔═╡ 932cc4ca-654a-11eb-1601-0f772477529f
# We've already create a folder called out_objects in our project but an example of mkdir() would be:
mkdir("example_folder")
# if you haven't created an out_objects folder yet, simply replace "example_folder" with "out_objects". 

# ╔═╡ daa5d4c8-50fe-11eb-3ced-29c48292f7b2
md"
## Running the BEFW

There are four major steps when running the BioEnergetic Food Web model in Julia:
1. Generate an initial network 
2. Fix parameters
3. Simulate
4. Explore output and plot

### Initial network 
Before running the BEFW model, we have to construct an initial random network using [the niche model](https://www.nature.com/articles/35004572?cacheBust=1510239451067). The network is characterised by the number of species in the network and its [connectance](https://en.wikipedia.org/wiki/Ecological_network) value. Here, we generate a network of 20 species with a connectance value of 0.15:
"

# ╔═╡ bc148726-4eaa-11eb-103e-0d40e15d7b95
begin
	# generate network
	A_bool = EcologicalNetworks.nichemodel(20,0.15) 
	# convert the UnipartiteNetwork object into a matrix of 1s and 0s
	A = Int.(A_bool.A)
end

# ╔═╡ c8ca2428-654b-11eb-3f37-b112b0a6192c
md"
In the above code chunk, we are saving the output from running the `nichemodel` as `A_bool` and then using the `A` part of `A_bool` to construct our initial random network. Within `A`, 1s indicate an interaction among species and 0s no interaction. In the packages used here, the networks are directed from `i` (rows) to `j` (columns), describing the direction of the interaction (i eats j), not of the flow of biomass.
"

# ╔═╡ bf4f56be-4eaa-11eb-1487-f1747aab8d4e
md"You can check the connectance of A using:"

# ╔═╡ cec73ec2-4eaa-11eb-223d-c3f6707a8ba3
# calculate connectance
co = sum(A)/(size(A,1)^2)

# ╔═╡ a408e704-654c-11eb-27fc-2933d9e9515f
md"
Here, connectance is calculated as the number of realised links (sum of 1s in `A`) divided by the number of species in `A` squared. This end part (species^2) describes the maximum number of possible links in the network `A`. 
"

# ╔═╡ d332dcee-4eaa-11eb-0cf5-33bd128825cd
md"### Parameters

Prior to running the BEFW model, you have to create a vector of model parameters using the `model_parameters` function. Numerous parameter values can be specified within the `model_parameters` function, however, most of them have default values that are built into the `BioEnergeticFoodWebs.jl` package. For simplicity, we use the default values here:"

# ╔═╡ f1213a72-4eaa-11eb-2117-49e624afa4fe
# create model parameters
p = model_parameters(A)
# in the most simple case, the model_parameters function simply requires A

# ╔═╡ f9545abc-4eaa-11eb-3ef5-a7c1f1d61b62
md"For more information and a full list of the parameters and their defaults values type `?model_parameters` in the REPL. 

If you want to view, check or extract any of the parameter values in `p` use the `p[:name]` notation. For example, you can view a vector of each species' trophic rank using:"

# ╔═╡ c2f6b62c-654d-11eb-18c8-fde307cc05b1
# view trophic ranks:
p[:trophic_rank]

# ╔═╡ ab12997a-50ff-11eb-03a6-d952acc44eba
md"### Simulate
To run the BEFW model, we first assign biomasses at random to each species and then simulate the biomass dynamics forward using the `simulate` function:"

# ╔═╡ 5a71c630-4eac-11eb-3acd-b173c3cae180
begin
	# assign biomasses
	bm = rand(size(A,1)) 
	# select biomasses at random between ]0:1[
	# as an alternative, you could assign all species the same biomass of 1 using bm = ones(size(A,1)) 
	
	# simulate
	out = simulate(p, bm, start=0, stop=2000)
	# this might take a few seconds
end

# ╔═╡ 94947bdc-4eac-11eb-0659-afb90ebc53db
md"The `simulate` function requires the model parameters `p` and the species biomasses `bm`. In addition, you can specify the timespan of the simulation (using the `start` and `stop` arguments), fix a species extinction threshold (using `extinction_threshold`) and select a solver (using `use`). For more information type `?simulate` in the REPL. "

# ╔═╡ 590f9e6a-4ead-11eb-31f1-2718dd772637
md"### Output and plot
Once the simulation finishes, the output is stored as a dictionary called `out`. Within `out` there are three entries:
1. `out[:p]` - lists the parameters
2. `out[:B]` - biomass of each species through time
3. `out[:t]` - timesteps (these typically increase in 0.25 intervals)

The biomass dynamics of each species can then be plotted. Similar to the `DifferentialEquations.jl` package, the `BioEnergeticFoodWebs.jl` package also has it's own built in plotting recipe:"

# ╔═╡ 73952ad4-4ead-11eb-20a2-c5fe4d7636f9
# plot
Plots.plot(out[:t], out[:B], legend = true, ylabel = "Biomass", xlabel = "Time")
# this may take a minute to render

# ╔═╡ 6ffe793e-5100-11eb-1b27-a7c18b6a0130
md"You'll notice that the biomass dynamics are noisey during the first few hundred time steps, these are the system's transient dynamics. The dynamics then settle into a steady state where the system can be assumed to be at equilbirum. You'll also notice that some species go extinct and some persist, the initial number of species in the food web (20 in this case) can found using `out[:p][:S]` and the identity of those that went extinct using `out[:p][:extinctions]`. 

The `BioEnergeticFoodWebs.jl` package also has a range of built in functions that conveniently calculate some of the key metrics of the food web, these include the total biomass, the diversity, the species persistence and the temporal stability:"

# ╔═╡ 7da79804-5100-11eb-3d8a-e3ca0d4286be
# total biomass
biomass = total_biomass(out, last=1000)

# ╔═╡ 92731e52-5100-11eb-057e-413ff19270c1
# diversity
diversity = foodweb_evenness(out, last=1000)

# ╔═╡ 927357c8-5100-11eb-3beb-13e338673f05
# persistence
persistence = species_persistence(out, last=1000)

# ╔═╡ 92743f80-5100-11eb-0cba-7b59bceb520e
# stability 
stability = population_stability(out, last=1000)

# ╔═╡ 9cc857a0-5100-11eb-2b2c-d7b4230d0adb
md"Each of these functions will output a single value. This value is the average over the `last` 1000 time steps. For more information, use `?` to access the help files on each function in the REPL (e.g., `?species_persistence`)."

# ╔═╡ a2ce3d84-5100-11eb-0f0c-3be596225064
md"
## Variables

Once you've got the BEFW model running, the next step is to vary a variable of interest and rerun. For example, we might be interested in what affect a small change in Z (consumer-resource body mass ratio) has on the estimated food web and its biomass dynamics. The default value for Z is 1.0, but what happens if we increase it to 10.0: 
"

# ╔═╡ dc43aae2-5100-11eb-24dc-7bf09a6680c7
begin
	# set Z (has to be a floating number not an integer)
	Z = 10.0
	# create model parameters
	p_z = model_parameters(A, Z = Z)
	# assign biomasses
	bm_z = rand(size(A,1)) 
	# simulate
	out_z = simulate(p_z, bm_z, start=0, stop=2000)
	# plot
	Plots.plot(out_z[:t], out_z[:B], legend = true, ylabel = "Biomass", xlabel = "Time")
end

# ╔═╡ 04bce3aa-5101-11eb-1fd0-4bb18e4dcbf1
md"Similarly, what happens if we also increase the carrying capacity (K) of the resource from 1.0 (default) to 5.0:"

# ╔═╡ 0d4bd4c0-5101-11eb-3596-8d51003c1590
begin
	# set K (has to be a floating number not an integer)
	K = 5.0 
	# create model parameters
	p_K = model_parameters(A, Z = Z, K = K)
	# assign biomasses
	bm_K = rand(size(A,1)) 
	# simulate
	out_K = simulate(p_K, bm_K, start=0, stop=2000)
	# plot
	Plots.plot(out_K[:t], out_K[:B], legend = true, ylabel = "Biomass", xlabel = "Time")
end

# ╔═╡ 2f1c8dba-5101-11eb-2290-4dddd6bf44ef
md"As you've probably guessed, the main message here is that many variables can be changed in the BEFW model and it's super easy to do so. Some changes will have large effects and some not so much. In the next step, we take this one step further. "

# ╔═╡ 351c26a0-5101-11eb-1061-cb8cb0bc4c5b
md"

## Experiments 
The next step is to construct a computional experiment designed to investigate the effect of different variables on population and community dynamics. To do this we construct a gradient of variables as vectors and then simulate the BEFW model multiple times using a loop. To illustrate this, we're going to reproduce example 1 from [Delmas et al. 2016](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713). The aim of this example is to investigate the effect of increasing K on food web diversity. In addition, we're also going to allow α (interspecific competition relative to intraspecific competition) to vary and repeat the experiment 5 times with 5 different initial networks.

First, we define the experiment by creating vectors of our variables and fixing the number of repetitions:
"

# ╔═╡ 4b75b810-5101-11eb-2532-fdf9a68c5ba0
α = [0.92, 1.0, 1.08]
# 0.92 - the interspecific competition is smaller than the intraspecific competition promoting coexistence
# 1.0 - neutrally stable 
# 1.08 - the intraspecific competition is smaller the interspecific competition favouring competitive exclusion

# ╔═╡ 6a0665c2-5101-11eb-2cfe-213833c6bd9b
# vector of K
k = exp10.(range(-1,1,length=10))
# log scale from 0.1 to 10

# ╔═╡ 6a069dda-5101-11eb-3609-f77bf4d032e5
# number of reps
reps = 5

# ╔═╡ 83a3b522-5101-11eb-0d89-1dcead32bbd9
md"We then create a dataframe to store the outputs:"

# ╔═╡ 88f98950-5101-11eb-3c14-27934cdf75cb
# dataframe
df = DataFrame(α = [], K = [], network = [], diversity = [], stability = [], biomass = [])

# ╔═╡ 920259b4-5101-11eb-0992-e105ad8c093a
md"and construct a `while` loop to generate the 5 unique initial networks, each of which contains 20 species with a connectance value of 0.15:"

# ╔═╡ a3b42a0c-5101-11eb-0365-f3cb912347a0
begin
	# list to store networks
	global networks = []
	# monitoring variable 
	global l = length(networks)
	# while loop
	while l < reps
	    # generate network
	    A_bool = EcologicalNetworks.nichemodel(20,0.15) 
	    # convert the UnipartiteNetwork object into a matrix of 1s and 0s
	    A = Int.(A_bool.A)
	    # calculate connectance
	    co = sum(A)/(size(A,1)^2)
	    # ensure that connectance = 0.15
	    if co == 0.15
	        push!(networks, A)
	        # save network is co = 0.15
	    end
	    global l = length(networks)
	end
end

# ╔═╡ b487c396-5101-11eb-0d9c-751b85d44e2b
md"We can then run the simulations by looping, using nested `for` loops, over the unique values of α and K, as well as the 5 unique initial networks. After each simulation we will save each output object to our active project as a `JLD2` file and store any output metrics of interest in our dataframe:"

# ╔═╡ cc09f6f8-5101-11eb-0b54-c5f0ff76ce8a
# loop over networks
for h in 1:reps
    A = networks[h]
    # here, you might want to save a copy of the initial network using writedlm(A)

    # loop over α
    for i in 1:length(α) 
        # loop over K
        for j in 1:length(k)

        # create model parameters

        p = model_parameters(A, α = α[i], K = k[j])
        # assign biomasses
        bm = rand(size(A,1)) 
        # simulate
        out = simulate(p, bm, start=0, stop=2000)

        # dummy naming variables
        α_num = α[i]
        K_num = k[j]
        # save `out` as a JLD2 object using the @save macro:
        @save "out_objects/model_output, network = $h, alpha = $α_num, K = $K_num.jld2" out

        # calculate output metrics
        diversity = foodweb_evenness(out, last = 1000)
        stability = population_stability(out, last = 1000)
        biomass = total_biomass(out, last = 1000)

        # push to df
        push!(df, [α[i], k[j], h, diversity, stability, biomass])

        # print some stuff - see how the simulation is progressing
        println(("α = $α_num", "K = $K_num", "network = $h"))
        end
    end
end
# the code will be much faster if you remove the @save command

# ╔═╡ eacd9662-5101-11eb-2695-297466aed511
md"We can then explore the outputs and plot our results. Here, instead of using the built in plotting recipe, we will construct a plot that matches figure 1 in [Delmas et al. 2016](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713). Specifically, we will plot food web diversity (y-axis) as a function of K (x-axis) and α (colour):"

# ╔═╡ fdbf6606-5101-11eb-3315-f9b859e39453
# explore output
describe(df)

# ╔═╡ 0555ac2c-5102-11eb-2343-e5467d420ffe
first(df,6)

# ╔═╡ 0555e890-5102-11eb-3386-bd2f3d83635c
last(df,6)

# ╔═╡ 05574034-5102-11eb-3e96-0df48a0168ea
# plot
# initialise an empty plot
pl = Plots.plot([NaN], [NaN],
                label = "",
                ylims = (0,1.1),
                leg = :bottomright,
                foreground_colour_legend = nothing,
                xticks = (log10.(k), string.(round.(k, digits = 1))),
                xlabel = "Carrying capacity",
                ylabel = "Food web diversity (evenness)")

# ╔═╡ 0571ceb6-5102-11eb-1b80-235772412947
# set marker shapes
shp = [:square, :diamond, :utriangle]

# ╔═╡ 057304ea-5102-11eb-2c36-e368b5f92e3a
# set line types
ls = [:solid, :dash, :dot]

# ╔═╡ 05897ff2-5102-11eb-1c7b-fb51f3443175
# set colours
clr = [RGB(174/255, 139/255, 194/255), RGB(188/255, 188/255, 188/255), RGB(124/255, 189/255, 122/255)]
# when we define colours in Julia they are printed 

# ╔═╡ 05967216-5102-11eb-3c1f-4fa381ee8c5f
# set legend labels
lbl = ["Coexistence", "Neutral", "Exclusion"]

# ╔═╡ 05abd9a0-5102-11eb-0c9d-2de08b81bb42
# make the plot
for (i, α) in enumerate(α)
    # subset
    tmp = df[df.α .== α, :]
    # remove NaN values
    tmp = tmp[.!(isnan.(tmp.diversity)), :]
    # calculate mean across reps
    meandf = by(tmp, :K, :diversity => mean)
    # command to avoid printing legends multiple times
    l = i == 1 ? lbl[i] : ""
    # add to pl
    plot!(pl, log10.(meandf.K), meandf.diversity_mean,
              msc = clr[i],
              mc = :white,
              msw = 3,
              markershape = shp[i],
              linestyle = ls[i],
              lc = clr[i],
              lw = 2,
              label = lbl[i],
              seriestype = [:line :scatter])
end

# ╔═╡ 05bb7e6c-5102-11eb-3f77-83f95a11bfcc
# display plot
plot(pl)

# ╔═╡ 241d8080-5102-11eb-3c09-351c80043bd8
md"Finally, we can save our dataframe as a .csv file:"

# ╔═╡ 29440f14-5102-11eb-3a01-03d0ec68eeb7
# save
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
# ╠═932cc4ca-654a-11eb-1601-0f772477529f
# ╟─daa5d4c8-50fe-11eb-3ced-29c48292f7b2
# ╠═bc148726-4eaa-11eb-103e-0d40e15d7b95
# ╟─c8ca2428-654b-11eb-3f37-b112b0a6192c
# ╟─bf4f56be-4eaa-11eb-1487-f1747aab8d4e
# ╠═cec73ec2-4eaa-11eb-223d-c3f6707a8ba3
# ╟─a408e704-654c-11eb-27fc-2933d9e9515f
# ╟─d332dcee-4eaa-11eb-0cf5-33bd128825cd
# ╠═f1213a72-4eaa-11eb-2117-49e624afa4fe
# ╟─f9545abc-4eaa-11eb-3ef5-a7c1f1d61b62
# ╠═c2f6b62c-654d-11eb-18c8-fde307cc05b1
# ╟─ab12997a-50ff-11eb-03a6-d952acc44eba
# ╠═5a71c630-4eac-11eb-3acd-b173c3cae180
# ╟─94947bdc-4eac-11eb-0659-afb90ebc53db
# ╟─590f9e6a-4ead-11eb-31f1-2718dd772637
# ╠═73952ad4-4ead-11eb-20a2-c5fe4d7636f9
# ╟─6ffe793e-5100-11eb-1b27-a7c18b6a0130
# ╠═7da79804-5100-11eb-3d8a-e3ca0d4286be
# ╠═92731e52-5100-11eb-057e-413ff19270c1
# ╠═927357c8-5100-11eb-3beb-13e338673f05
# ╠═92743f80-5100-11eb-0cba-7b59bceb520e
# ╟─9cc857a0-5100-11eb-2b2c-d7b4230d0adb
# ╟─a2ce3d84-5100-11eb-0f0c-3be596225064
# ╠═dc43aae2-5100-11eb-24dc-7bf09a6680c7
# ╟─04bce3aa-5101-11eb-1fd0-4bb18e4dcbf1
# ╠═0d4bd4c0-5101-11eb-3596-8d51003c1590
# ╟─2f1c8dba-5101-11eb-2290-4dddd6bf44ef
# ╟─351c26a0-5101-11eb-1061-cb8cb0bc4c5b
# ╠═4b75b810-5101-11eb-2532-fdf9a68c5ba0
# ╠═6a0665c2-5101-11eb-2cfe-213833c6bd9b
# ╠═6a069dda-5101-11eb-3609-f77bf4d032e5
# ╟─83a3b522-5101-11eb-0d89-1dcead32bbd9
# ╠═88f98950-5101-11eb-3c14-27934cdf75cb
# ╟─920259b4-5101-11eb-0992-e105ad8c093a
# ╠═a3b42a0c-5101-11eb-0365-f3cb912347a0
# ╟─b487c396-5101-11eb-0d9c-751b85d44e2b
# ╠═cc09f6f8-5101-11eb-0b54-c5f0ff76ce8a
# ╟─eacd9662-5101-11eb-2695-297466aed511
# ╠═fdbf6606-5101-11eb-3315-f9b859e39453
# ╠═0555ac2c-5102-11eb-2343-e5467d420ffe
# ╠═0555e890-5102-11eb-3386-bd2f3d83635c
# ╠═05574034-5102-11eb-3e96-0df48a0168ea
# ╠═0571ceb6-5102-11eb-1b80-235772412947
# ╠═057304ea-5102-11eb-2c36-e368b5f92e3a
# ╠═05897ff2-5102-11eb-1c7b-fb51f3443175
# ╠═05967216-5102-11eb-3c1f-4fa381ee8c5f
# ╠═05abd9a0-5102-11eb-0c9d-2de08b81bb42
# ╠═05bb7e6c-5102-11eb-3f77-83f95a11bfcc
# ╟─241d8080-5102-11eb-3c09-351c80043bd8
# ╠═29440f14-5102-11eb-3a01-03d0ec68eeb7
