### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 644db7b5-5a4f-4793-af0e-a02ee64d756a
import Pkg

# ╔═╡ b4ce21f5-a3e2-4740-9d7a-8de4afdf1afc
Pkg.activate(".")

# ╔═╡ d0b44a9c-c581-4cf5-83ec-193456853e36
using BioEnergeticFoodWebs

# ╔═╡ 70faa907-0196-4195-b64c-5a0cfcd6ab0c
using Plots, DataFrames

# ╔═╡ 444b7113-dfbe-4675-8e40-031391f44e4f
md"""
# Manipulating the functional response in the BEFWM
"""

# ╔═╡ 02138185-5386-482d-85c9-afbeffcaf0d6
import Statistics.mean, Statistics.std

# ╔═╡ 071b4dab-2310-4510-82cf-defdd441416f
md"""
## The "original" functional response VS the "classical" functional response
"""

# ╔═╡ 0c980fe5-db0b-4e6c-8e41-05c5abad5e8f
md"""
In the bioenergetic food web model, species gain and/or lose biomass through consumption. Gains and losses depends on the focus species biomass, a functional response and an interaction-specific assimilation efficiency. 
In the original bio-energetic model (as developped by Yodzis and Innes, 1992), the functional response 
is a function of **consumer-specific maximum consumption rates and half-saturation densities**. However, it is sometimes more convenient to be able to work with a more classical functional response with **interaction-specific attack rates and handling times**. You can switch between the two implementation by setting the argument `functional_response` (`model_parameters` function) to either `:bioenergetic` (default, alternatively called `:original`) or `:classical`. The function will take care of calculating the various rates using allometric scaling. You can still modify the arguments or modify the rates values afterwards if needed.

Here is a list of the parameters that are common to the two implementations: 
- `e_carnivore` is the carnivores assimilation efficiency (default = `0.85`)
- `e_herbivore` is the herbivores assimilation efficiency (default = `0.45`)
- `c` is the value of the predator interference (Beddington-DeAngelis functional response). Either one value, common for all consumers or a vector of consumer-specific values can be passed (default = `0.0.)
- `h` is the Hill exponent. It controls the shape of the functional response (default = `1`.)
- `y_invertebrate`and `y_vertebrate` are the maximum consumption rates for the invertebrates and ectotherm vertebrates respectively. 
- `Γ` is the half saturation density ($B_0$)

If you chose a `:bioenergetic` functional response, the following equations are used: 

$$gains_i = \sum_{j \in resources} B_i x_i y_i FR_{ij}$$

$$losses_i = \sum_{j \in consumers} \frac{B_j x_j y_j FR_{ji}}{e_{ji}}$$

where 

$$FR_{ij} = \frac {\omega_{ij}B_{j}^{h}}{B_{0}^{h}+c_iB_iB_{0}^{h}+\sum_{k=resources}\omega_{ik}B_{k}^{h}}$$

$\omega_{ij}$ (`w`) is the consumer $i$ preference for resource $j$, by default it is calculated as $1/n$ where $n$ is the number of resource for $i$ (homogenous consumption effort).
"""

# ╔═╡ 3eee9483-0adf-4e59-aefc-1b5e134dbd20
md"""
If a `:classical` functional response is more suited for your project, then the consumer-specific maximum consumption rate and half saturation density will be transformed into interaction-specific attack rates and handling times using the following substitutions: 

- $ht_{ij} = 1/y_{i}$
- $ar_{ij} = 1/(B_0 ht_{ij})$

And the following equations are used for gains and losses linked to consumption: 

$$gains_i = \sum_{j \in resources} e_{ij} B_i FR_{ij}$$

$$losses_i = \sum_{j \in consumers} B_j FR_{ji}$$

with 

$$FR_{ij} = \frac {ar_{ij} B_{j}^{h}} {1 + c_iB_i + \sum_{k=resources} ht_{ik} ar_{ik}B_{k}^{h}}$$
"""

# ╔═╡ dd38cf1a-cc52-4279-9178-f6a10b01b14a
md"""
## Using the original functional response
"""

# ╔═╡ 20d4d499-44e4-4b12-8568-2b862378378c
A = [0 1 0 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]

# ╔═╡ ff424e7a-e1ab-48aa-9f4f-4a25df057690
p_original = model_parameters(A, functional_response = :bioenergetic, h = 2.0)

# ╔═╡ 6c44772b-f368-4d81-8002-594e8c635b0b
b0 = rand(size(A,1)) #initial biomass

# ╔═╡ d431deb3-7afd-4925-8b80-a6761e192025
begin #don't worry about the begin/end statement, you won't need it, it's just to be able to make multiple statements cells in Pluto notebook
	sim_original = simulate(p_original, b0, stop = 500)
	sim_original[:B][:,end]
end

# ╔═╡ 6e6421f6-297b-4903-88bd-ad5dca85805a
plot(sim_original[:t], sim_original[:B], xlabel = "time", ylabel = "population biomass", ylims = (0,1.1))

# ╔═╡ 3efbb4c0-2dee-11ec-0972-233b19920a73
md"""
## Using the classical functional response
"""

# ╔═╡ 652db699-86db-422f-a955-45b31da7acc4
p_classical = model_parameters(A, functional_response = :classical, h = 2.0)

# ╔═╡ d995dd5c-f695-4020-b3de-ba28755c1ddc
begin #don't worry about the begin/end statement, you won't need it, it's just to be able to make multiple statements cells in Pluto notebook
	sim_classical = simulate(p_classical, b0, stop = 500)
	sim_classical[:B][:,end]
end

# ╔═╡ f0de857e-c2f5-4fc4-abe2-f9fd2fe47883
plot(sim_classical[:t], sim_classical[:B], xlabel = "time", ylabel = "population biomass", ylims = (0,1.1))

# ╔═╡ 2d12bf48-8e4a-4f26-9076-646c3a23dabb
md"""
## Use case
"""

# ╔═╡ 2fb8e920-2c18-4670-b174-77f0027531c2
fr_type = [(h = 1.0, c = 0.0, name = "Holling, type 2")
		 , (h = 1.0, c = 1.0, name = "Predator interference")
		 , (h = 2.0, c = 0.0, name = "Holling, type 3")]

# ╔═╡ e617d1a1-d94b-4eb5-a504-7ad6759f6dc7
mass_ratio = [1.0, 10.0, 100.0]

# ╔═╡ 2319cc9c-b3ec-43f5-a2a9-f177a3c16f8b
nrep = 10

# ╔═╡ 345de49d-f4c0-4fb5-9057-a3bb010a0dd2
foodwebs = [nichemodel(20, 0.2) for i in 1:nrep]

# ╔═╡ 3a138caf-cae4-42d3-bd9e-df8bb94a1248
df_outputs = []

# ╔═╡ a39a3644-3a72-4e4a-be36-78d11d062fe0
for f in fr_type
	for z in mass_ratio
		for (i, a) in enumerate(foodwebs)
			p = model_parameters(a; h = f.h, c = [f.c], Z = z, functional_response = :bioenergetic)
			s = simulate(p, rand(p[:S]), stop = 1000)
			out = (fr = f.name, Z = z, id = i, cv = population_stability(s, last = 250), persistence = species_persistence(s, last = 250), biomass = total_biomass(s, last = 250))
			push!(df_outputs, out)
		end
	end
end

# ╔═╡ 1c6f2120-98db-4ef1-844b-4ea6c7e109af
df = DataFrame(df_outputs)

# ╔═╡ d63a25ac-39f0-499d-a3f9-c84deed86a3d
plt = plot([NaN], [NaN], label = "") #prepare empty plot

# ╔═╡ 4c20c889-5f2e-441d-8d8c-4ed5152ebd57
mtypes = [:circle, :rect, :utriangle]

# ╔═╡ c3dde2f4-5fb1-451f-87ef-c6ec2db8da3f
jitterZ = [-0.1, 0, 0.1]

# ╔═╡ 8781f4d1-04e3-4b01-9f2a-72f58efd73c9
for (i,f) in enumerate(fr_type)
	mean_cv = []
	std_cv = []
	for z in mass_ratio
		tmp = df[(df.fr .== f.name) .& (df.Z .== z),:cv]
		push!(mean_cv, mean(tmp))
		push!(std_cv, std(tmp))
	end
	scatter!(log10.(mass_ratio) .+ jitterZ[i], mean_cv, markershape = mtypes[i], label = f.name, yerror = std_cv)
end

# ╔═╡ b6d7906a-1cc8-48bc-b5ad-fe4b52e23bf9
plt

# ╔═╡ Cell order:
# ╟─444b7113-dfbe-4675-8e40-031391f44e4f
# ╠═644db7b5-5a4f-4793-af0e-a02ee64d756a
# ╠═b4ce21f5-a3e2-4740-9d7a-8de4afdf1afc
# ╠═d0b44a9c-c581-4cf5-83ec-193456853e36
# ╠═70faa907-0196-4195-b64c-5a0cfcd6ab0c
# ╠═02138185-5386-482d-85c9-afbeffcaf0d6
# ╟─071b4dab-2310-4510-82cf-defdd441416f
# ╟─0c980fe5-db0b-4e6c-8e41-05c5abad5e8f
# ╟─3eee9483-0adf-4e59-aefc-1b5e134dbd20
# ╟─dd38cf1a-cc52-4279-9178-f6a10b01b14a
# ╠═20d4d499-44e4-4b12-8568-2b862378378c
# ╠═ff424e7a-e1ab-48aa-9f4f-4a25df057690
# ╠═6c44772b-f368-4d81-8002-594e8c635b0b
# ╠═d431deb3-7afd-4925-8b80-a6761e192025
# ╠═6e6421f6-297b-4903-88bd-ad5dca85805a
# ╟─3efbb4c0-2dee-11ec-0972-233b19920a73
# ╠═652db699-86db-422f-a955-45b31da7acc4
# ╠═d995dd5c-f695-4020-b3de-ba28755c1ddc
# ╠═f0de857e-c2f5-4fc4-abe2-f9fd2fe47883
# ╟─2d12bf48-8e4a-4f26-9076-646c3a23dabb
# ╠═2fb8e920-2c18-4670-b174-77f0027531c2
# ╠═e617d1a1-d94b-4eb5-a504-7ad6759f6dc7
# ╠═2319cc9c-b3ec-43f5-a2a9-f177a3c16f8b
# ╠═345de49d-f4c0-4fb5-9057-a3bb010a0dd2
# ╠═3a138caf-cae4-42d3-bd9e-df8bb94a1248
# ╠═a39a3644-3a72-4e4a-be36-78d11d062fe0
# ╠═1c6f2120-98db-4ef1-844b-4ea6c7e109af
# ╠═d63a25ac-39f0-499d-a3f9-c84deed86a3d
# ╠═4c20c889-5f2e-441d-8d8c-4ed5152ebd57
# ╠═c3dde2f4-5fb1-451f-87ef-c6ec2db8da3f
# ╠═8781f4d1-04e3-4b01-9f2a-72f58efd73c9
# ╠═b6d7906a-1cc8-48bc-b5ad-fe4b52e23bf9
