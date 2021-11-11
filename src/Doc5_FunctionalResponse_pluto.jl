### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ f86afb85-8de1-45b9-92cb-c5607e11c69e
import Pkg

# ╔═╡ 0b834f4b-4469-4bea-a011-fa27b428bf64
Pkg.activate("../")

# ╔═╡ a24bb9d0-4ce5-418e-a7e8-402d951e6136
using BioEnergeticFoodWebs, EcologicalNetworks, CSV, Random, Plots, DataFrames, Statistics 

# ╔═╡ d760e9c0-a734-4fc6-a9dd-0e7f8d9c27c2
md"
First off we import our package manager `Pkg` and activate:
"

# ╔═╡ 583decf5-25ec-44a4-a2d7-28dc88768b2b
md"
This step is not essential but is good practice when coding in Julia. Here, we've used the `../` notation to ensure that we are working in correct project directory (`Julia - VS code - how to`) and not a subfolder of that directory. 
"

# ╔═╡ 339cd854-3247-11ec-3995-1d6205a38a71
md"# Functional Response 

*by Chris Griffiths, Eva Delmas and Andrew Beckerman, Oct. 2021.*"

# ╔═╡ 4bb401d5-d37f-469b-a00b-1517b650c786
md"
This document builds on the previous tutorials, in particular, 'Intro to BioEnergeticFoodWebs' and introduces the functional response, the theory (and maths) behind it, and how it is used in the BEFW. The aim of this tutorial, and those that follow, is to delve deeper into the inner workings of the BEFW model and demonstrate its utility. Specifically, they will highlight how certain processes can be manipulated and adapted to investigate biological questions of interest. Moreover, via coded examples, the tutorials will show how the BEFW model can be used to test the response of ecological systems to one, or many, anthropogenic stressors. 

We again recommend reading the [MEE paper](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713) before starting this tutorial.
"

# ╔═╡ 10e673d6-43f8-4080-b21a-daab82e29805
md"## Load packages"

# ╔═╡ e38fa2c1-10db-4e58-9019-cc845637e91c
md"
You'll need the following packages for this tutorial:
"

# ╔═╡ bb1e404e-eed8-4ba7-9b96-2aec820f647d
Random.seed!(37)

# ╔═╡ a1f32d6d-43f6-4645-a191-db401f487795
md"
## The theory

The functional response is a classic concept in food web ecology and considers the relationship between predation rate and prey density ([Real 1977](https://www.jstor.org/stable/2460064)). Specifically, it describes the number of prey that a predator consumes per unit of time as a function of the abundance or density of its prey ([Solomon 1949](https://www.jstor.org/stable/1578); [Holling 1959](https://doi.org/10.4039/Ent91293-5), [1965](https://doi.org/10.4039/entm9745fv), [1966](https://doi.org/10.4039/entm9848fv)). The functional response epitomises the density-dependent nature of trophic interactions and therefore acts as a key building block to several food web models including the BEFW. 

A predator's functional response can typically take one of three types. In all three, consumption rate typically increases with prey density, albeit the exact shape of this increase and at what point a maximum consumption rate is achieved will vary. Functional response types:

A. Type I: Consumption rate increases linearly until a threshold prey density is reached, beyond which consumption rate remains constant. In type I functional responses, it is assumed that the time needed to process prey is negligible, or that consumption doesn't interfere with prey searching. 

B. Type II: Consumption rate shows a curvilinear increase, such that the proportion of prey consumed declines as prey density increases. In type II functional responses, it is assumed that the consumer is limited by its capacity to process prey. 

C. Type III: Consumption rate exhibits a sigmoidal relationship with prey density, whereby the proportion of prey consumed peaks at intermediate prey densities and saturates at high prey densities. The superlinear part of a type III functional response is often justified by learning time, prey switching, or a combination, during which the efficiency of the predator increases. 

Type II functional responses are most frequently observed in the wild. For example, a review of individual functional responses by [Jeschke et al. (2004)](https://onlinelibrary.wiley.com/doi/abs/10.1017/S1464793103006286) found that the frequency of type II functional responses (77%) far exceeded that of type III (13%) and type I (3%). Type II functional responses are also commonly used in food web models, however, type IIIs are also employed as they are known to boost species persistence by increasing ecological stability (because predation is low when prey densities are also low; [Williams & Martinez 2004](https://link.springer.com/article/10.1140/epjb/e2004-00122-1)). 
"

# ╔═╡ 5766442e-75dd-4f2b-89e2-aff0f7e35933
md"
## FR in the BEFW (and the math)

The BEFW model describes the flow of biomass across trophic levels, whereby species (characterised by a given body mass and metabolic rate) gain and lose biomass based on consumer-resource interactions (i.e. consumption). Gains and losses depend on a species' current biomass, a functional response and an interaction-specific assimilation efficiency (see below). In the orginial bio-energetic model of [Yodzis and Innes (1992)](https://www.journals.uchicago.edu/doi/abs/10.1086/285380), the functional response is modelled as a function of **consumer-specific maximum consumption rates and half-saturation densities**. However, this isn't the only approach, and instead it is often convenient to use a classical approach which uses **interaction-specific attack rates and handling times**. Both of these approaches are available in the BEFW model, however, they do require slightly different arguments within the `model_parameters` function:

1. Bio-energetic: `functional_response = :bioenergetic`

2. Classical: `functional_response = :classical`

The bio-energetic approach is the **default**, however, as you'll see in the next few tutorials, we have shifted to using the classical approach, especially when incorporating the effects of temperature. 

The `model_parameters` function will take care of the rest, namely calculating various rates based on allometric scaling. However, you are able to manually change these rates using the `p[:rate] = new_value` notation.

The two approaches share multiple parameters:
- `e_carnivore` is a carnivore's assimilation efficiency (default value = `0.85`).
- `e_herbivore` is a herbivore's assimilation efficiency (default value = `0.45`).
- `c` quantifies the strength of intraspecific predator interference ([Beddington 1975](https://doi.org/10.2307/3866) and [DeAngelis et al. 1975](https://doi.org/10.2307/1936298)). Predator interference is the degree to which increases in a predator's biomass negatively affect its feeding rates. Changing `c` requires the specification of either one value that is common to all consumers or a vector of consumer-specific values (default value = `0.0` i.e. no predator interference).
- `h` is the Hill exponent. It controls the shape of the functional response and allows you to shift between the three types (default value = `1` i.e. type II). 
- `y_invertebrate`and `y_vertebrate` are the maximum consumption rates for the invertebrates and ectotherm vertebrates, respectively. 
- `Γ` is the half saturation density, also referred to as $B_0$ (defaut value = `0.5`)

When using the `:bioenergetic` functional response ($FR$), the following equations are used:

$$gains_i = \sum_{j \in resources} B_i x_i y_i FR_{ij}$$

$$losses_i = \sum_{j \in consumers} \frac{B_j x_j y_j FR_{ji}}{e_{ji}}$$

where $B$ is current biomass, $x$ and $y$ are metabolic rate and maximum consumption rate, respectively, $e$ is assimilation efficency of consumer $i$ when consuming resource $j$ and $FR$ is 

$$FR_{ij} = \frac {\omega_{ij}B_{j}^{h}}{B_{0}^{h}+c_iB_iB_{0}^{h}+\sum_{k=resources} \omega_{ik} B_{k}^{h}}$$

where $\omega_{ij}$ describes a consumer $i$'s preference for resource $j$. By default $\omega_{ij}$ is calculated as $1/n$ where $n$ is the number of resources that are available to consumer $i$ (i.e. we assume homogenous consumption effort across all possible resources).

In comparison, when the `:classical` functional response is used the consumer-specific maximum consumption rate $y_i$ and half saturation density $B_0$ are transformed into interaction-specific attack rates $ar_{ij}$ and handling times $ht_{ij}$ using the following substitutions: 

$ht_{ij} = 1/y_{i}$

$ar_{ij} = 1/(B_0 ht_{ij})$

and the following equations are used:

$$gains_i = \sum_{j \in resources} e_{ij} B_i FR_{ij}$$

$$losses_i = \sum_{j \in consumers} B_j FR_{ji}$$

where $FR$ is

$$FR_{ij} = \frac {ar_{ij} B_{j}^{h}} {1 + c_iB_i + \sum_{k=resources} ht_{ik} ar_{ik}B_{k}^{h}}$$
"


# ╔═╡ a682c9d7-1fe8-433b-899e-c26a02fa8dc1
md"""
## Quick version check

Before progressing, it is worth checking that you're using the most up-to-date version of the `BioEnergeticFoodWebs` package. Quickly run the following code in your REPL:
"""

# ╔═╡ 135eb100-656c-4920-88fa-5c6953a1ca94
Pkg.status()

# ╔═╡ e8ff952f-5505-4c94-bc16-e210447ac5ad
md"
You should see the following:

`[9b49b652] BioEnergeticFoodWebs v1.2.0 https://github.com/PoisotLab/BioEnergeticFoodWebs.jl.git#dev-2.0.0` 

which details the current developmental branch of the BEFW model. This version contains all the additional code and functionality needed to use the `:classical` functional response and incorporate the effects of temperature and enrichment. If you don't see the above, quickly remove the older version (probably v.1.2.0, i.e. without the #dev-2.0.0) using `Pkg.rm('BioEnergeticFoodWebs')` and reinstall using `Pkg.add('BioEnergeticFoodWebs#dev-2.0.0')`. Remember, you can also enter the package manager directly using `]` key. 
"

# ╔═╡ dd9bfef0-aa6e-431b-84f6-7aa49b8d6640
md"""
## Using `:bioenergetic`
"""

# ╔═╡ 27c9a18c-f790-4c0f-9b19-37166dab1961
md"
Define a simple network:
"

# ╔═╡ 82ebf2e9-e188-4205-b8db-ba304ee28357
A = [0 1 0 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]

# ╔═╡ 7c4c088d-fd0f-415f-99ab-39f67e36f96f
md"
fix parameters using `model_parameters`:
"

# ╔═╡ b9f4167e-6525-4016-888b-d9dea633120a
p_bio = model_parameters(A, functional_response = :bioenergetic, h = 1.0)

# ╔═╡ 05fb2839-6aff-47d6-b22c-f0583cacd6c1
md"
here we're using a type II functional response (`h = 1.0`). 
"

# ╔═╡ 0ad50cd9-7d3b-46aa-80e7-b74997709828
md"
We then define some initial biomasses `b0`, simulate and plot:
"

# ╔═╡ 3668ff94-80a9-4fa9-9996-5dfbd23cb502
begin
	b0 = rand(size(A,1))
	sim_bio = simulate(p_bio, b0, stop = 500)
	plot(sim_bio[:t], sim_bio[:B], xlabel = "time", ylabel = "species biomass", ylims = (0,1.1))
end

# ╔═╡ eff83b1e-a95d-47d9-938b-ffcf62a3b44c
md"""
## Using `:classical`
"""

# ╔═╡ 1a8f2cb4-6871-4719-8759-717e51060c48
md"
Fix parameters:
"

# ╔═╡ 102fa995-ec03-4cc1-bd53-e6f72a797e8e
p_classical = model_parameters(A, functional_response = :classical, h = 2.0)

# ╔═╡ 77b7e524-1d18-4fb2-a608-19b4430f60ae
md"
here we're using a type III functional response (`h = 2.0`), we then simulate and plot:
"

# ╔═╡ d2321fc7-fa43-4248-9e76-033e4cd05b13
begin
	sim_classical = simulate(p_classical, b0, stop = 500)
	plot(sim_classical[:t], sim_classical[:B], xlabel = "time", ylabel = "species biomass", ylims = (0,1.1)) # Dynamics are much more stable!
end

# ╔═╡ 5477f137-eaa2-4427-91b6-08e3ebed313a
md"""
## Worked example 
"""

# ╔═╡ aae507c2-8dd4-42d4-a4c8-86974e1d63fb
md"
To demonstrate how the BEFW model can be used to investigate the effect of different functional responses on population and community dynamics, we're going to provide a coded example. First we define some functional response types:
"

# ╔═╡ b177cbd6-0404-4579-99ea-dda589b7ccbb
fr_type = [(h = 1.0, c = 0.0, name = "Type II")
		 , (h = 2.0, c = 0.0, name = "Type III")
		 , (h = 1.0, c = 1.0, name = "Type II with predator interference")]
# Remember, the h and c parameters dictate the shape and the type of the functional response being used (e.g. type II: h = 1 and c = 0). 

# ╔═╡ 1833b584-ef1a-449d-aca5-4371abf5fa9f
md"
fix the number of repetitions:
"

# ╔═╡ 13b0fa2f-3016-4c8b-bac5-f10ab659f987
reps = 10

# ╔═╡ bd468e6b-f944-4816-9ce4-5ff47646165f
md"
and create an empty array object to store the outputs:
"

# ╔═╡ b53b33ec-adc1-43ef-bdfc-146f0e5ab4be
df_outputs = []

# ╔═╡ 23aa0456-ab7e-4fda-9eac-bbd71e3af0ee
md"
Moreover, to make things interesting we're going to add a range of consumer-resource body mass ratios (Z) to our experiment:
"

# ╔═╡ d629f147-05e4-4f9c-9396-524eb65f64e5
mass_ratio = [1.0, 10.0, 100.0]

# ╔═╡ a162a8e9-4d10-4931-80c5-41ef6de5c6f2
md"
We then generate some initial networks using the niche model, each of which contains 20 species with a connectance value of 0.2:
"

# ╔═╡ d5dc8184-b667-4b46-99ed-e1c083833a82
begin
	# list to store networks
	global networks = []
	# monitoring variable 
	global l = length(networks)
	# while loop
	while l < reps
	    # generate network
	    A_bool = EcologicalNetworks.nichemodel(20,0.2) 
	    # convert the UnipartiteNetwork object into a matrix of 1s and 0s
		Ad = adjacency(A_bool)
	    A = Int.(Ad)
	    # calculate connectance
	    co = sum(A)/(size(A,1)^2)
	    # ensure that connectance = 0.2
	    if co == 0.2
	        push!(networks, A)
	        # save network is co = 0.2
	    end
	    global l = length(networks)
	end
end

# ╔═╡ 156daa94-96d2-4f71-ae7a-a5ba82c3cabe
networks

# ╔═╡ 1ed8e7a3-4af5-41ff-9dcc-bdbb35b5e086
md"
We then use nested `for` loops to loop over our experimental design, `simulate` dynamics and store metrics (`biomass`, `species_persistence` and `population_stability`) of interest:
"

# ╔═╡ b4be2fe7-f8b8-4835-bb29-ad5d259cf864
for f in fr_type
	for z in mass_ratio
		for (i, a) in enumerate(networks)
			# fix model parameters
			p = model_parameters(a, h = f.h, c = [f.c], Z = z, functional_response = :bioenergetic)
			# provide some initial biomasses
			bio = rand(size(a,1))
			# simulate
			s = simulate(p, bio, stop = 1000)
			# calculate outputs
			out = (fr = f.name, Z = z, id = i, cv = population_stability(s, last = 250), persistence = species_persistence(s, last = 250), biomass = total_biomass(s, last = 250))
			# push! to store
			push!(df_outputs, out)
			# print some stuff - see how the simulation is progressing
			fr = f.name
        	println(("fr = $fr", "Z = $z", "network = $i"))
		end
	end
end

# ╔═╡ 96fb06b9-7264-4859-b480-795d5304c889
md"
Above, we've used the `:bioenergetic` approach but this could easily be changed to `:classical` and re-run. 

We then coerce `df_outputs` to be a dataframe:
"

# ╔═╡ 36d139d0-dbc1-42df-aa76-be978a0a205f
df = DataFrame(df_outputs)

# ╔═╡ 640ed2a6-2d94-4fd3-a85b-a8190564cb74
md"
and plot mean population stability by `mass_ratio` and `fr_type`:
"

# ╔═╡ b8220d95-a0a6-4707-ba67-55102debb375
plt = plot([NaN], [NaN], xlabel = "log10(Z)",
                ylabel = "Population stability", label = "") #prepare empty plot

# ╔═╡ e5cbd9ae-fa9b-4092-b277-43d34fd8b490
mtypes = [:circle, :rect, :utriangle]

# ╔═╡ 309910c4-0f93-4a05-84ee-ed5279b94d67
jitterZ = [-0.1, 0, 0.1]

# ╔═╡ 228ac8ae-74d3-4ed4-8b7e-3dd8c7362342
for (i,f) in enumerate(fr_type)
	mean_cv = []
	std_cv = []
	for z in mass_ratio
		tmp = df[(df.fr .== f.name) .& (df.Z .== z),:cv]
		tmp = tmp[.!isnan.(tmp)] 
		push!(mean_cv, mean(tmp))
		push!(std_cv, std(tmp))
	end
	scatter!(log10.(mass_ratio) .+ jitterZ[i], mean_cv, markershape = mtypes[i], label = f.name, yerror = std_cv, legend=:bottomright)
end

# ╔═╡ 13438ca4-e6a9-4eb8-8c29-11fdecbc0187
plt

# ╔═╡ bcb1ae6c-33d6-4d8d-8a0c-c8de5dc2fe1a
md"
Here we see that networks modelled with a type III functional response have high temporal stability (population stability $\approx$ 0), closely followed by a type II functional response with added predator interference. We also see that both of these are noticeably more stable than networks modelled with a type II functional response. Interestingly, type II leads to both a reduction in mean stability and an increase in observed variance. In addition, the results seem to be largely unaffected by changes in Z. 

**Questions** to think about:

(1) Do these results meet our expectations? 

(2) Why might a type III functional response be more stable than a type II? 

(3) Why does the addition of predator interference have such a stabilising effect on biomass dynamics?
" 

# ╔═╡ Cell order:
# ╟─d760e9c0-a734-4fc6-a9dd-0e7f8d9c27c2
# ╠═f86afb85-8de1-45b9-92cb-c5607e11c69e
# ╠═0b834f4b-4469-4bea-a011-fa27b428bf64
# ╟─583decf5-25ec-44a4-a2d7-28dc88768b2b
# ╟─339cd854-3247-11ec-3995-1d6205a38a71
# ╟─4bb401d5-d37f-469b-a00b-1517b650c786
# ╟─10e673d6-43f8-4080-b21a-daab82e29805
# ╟─e38fa2c1-10db-4e58-9019-cc845637e91c
# ╠═a24bb9d0-4ce5-418e-a7e8-402d951e6136
# ╠═bb1e404e-eed8-4ba7-9b96-2aec820f647d
# ╟─a1f32d6d-43f6-4645-a191-db401f487795
# ╟─5766442e-75dd-4f2b-89e2-aff0f7e35933
# ╟─a682c9d7-1fe8-433b-899e-c26a02fa8dc1
# ╠═135eb100-656c-4920-88fa-5c6953a1ca94
# ╟─e8ff952f-5505-4c94-bc16-e210447ac5ad
# ╟─dd9bfef0-aa6e-431b-84f6-7aa49b8d6640
# ╠═27c9a18c-f790-4c0f-9b19-37166dab1961
# ╠═82ebf2e9-e188-4205-b8db-ba304ee28357
# ╟─7c4c088d-fd0f-415f-99ab-39f67e36f96f
# ╠═b9f4167e-6525-4016-888b-d9dea633120a
# ╟─05fb2839-6aff-47d6-b22c-f0583cacd6c1
# ╟─0ad50cd9-7d3b-46aa-80e7-b74997709828
# ╠═3668ff94-80a9-4fa9-9996-5dfbd23cb502
# ╟─eff83b1e-a95d-47d9-938b-ffcf62a3b44c
# ╟─1a8f2cb4-6871-4719-8759-717e51060c48
# ╠═102fa995-ec03-4cc1-bd53-e6f72a797e8e
# ╟─77b7e524-1d18-4fb2-a608-19b4430f60ae
# ╠═d2321fc7-fa43-4248-9e76-033e4cd05b13
# ╟─5477f137-eaa2-4427-91b6-08e3ebed313a
# ╟─aae507c2-8dd4-42d4-a4c8-86974e1d63fb
# ╠═b177cbd6-0404-4579-99ea-dda589b7ccbb
# ╟─1833b584-ef1a-449d-aca5-4371abf5fa9f
# ╠═13b0fa2f-3016-4c8b-bac5-f10ab659f987
# ╟─bd468e6b-f944-4816-9ce4-5ff47646165f
# ╠═b53b33ec-adc1-43ef-bdfc-146f0e5ab4be
# ╟─23aa0456-ab7e-4fda-9eac-bbd71e3af0ee
# ╠═d629f147-05e4-4f9c-9396-524eb65f64e5
# ╟─a162a8e9-4d10-4931-80c5-41ef6de5c6f2
# ╠═d5dc8184-b667-4b46-99ed-e1c083833a82
# ╠═156daa94-96d2-4f71-ae7a-a5ba82c3cabe
# ╟─1ed8e7a3-4af5-41ff-9dcc-bdbb35b5e086
# ╠═b4be2fe7-f8b8-4835-bb29-ad5d259cf864
# ╟─96fb06b9-7264-4859-b480-795d5304c889
# ╠═36d139d0-dbc1-42df-aa76-be978a0a205f
# ╟─640ed2a6-2d94-4fd3-a85b-a8190564cb74
# ╠═b8220d95-a0a6-4707-ba67-55102debb375
# ╠═e5cbd9ae-fa9b-4092-b277-43d34fd8b490
# ╠═309910c4-0f93-4a05-84ee-ed5279b94d67
# ╠═228ac8ae-74d3-4ed4-8b7e-3dd8c7362342
# ╠═13438ca4-e6a9-4eb8-8c29-11fdecbc0187
# ╟─bcb1ae6c-33d6-4d8d-8a0c-c8de5dc2fe1a
