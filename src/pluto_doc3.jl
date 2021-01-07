### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 0bcdf87e-4f7a-11eb-0730-33c955c3992b
using DifferentialEquations, Plots

# ╔═╡ 0f899f22-4163-11eb-19e5-63175fab4bf5
md"# Differential Equations in Julia

*by Chris Griffiths, Eva Delmas and Andrew Beckerman, Dec. 2020.*"

# ╔═╡ f316e6b4-4163-11eb-0340-e92f9ace2386
md"This tutorial is adapted from an R script provided by Andrew Beckerman. 

This document follows on from 'Getting started' and 'Basic Julia commands' and assumes that you're still working from your active project. 

This document illustrates how to construct and solve differential equations in Julia using the `DifferentialEquations.jl` package. In particular, we are interested in modelling a two species Lotka-Volterra like (predator-prey/consumer-resource) system. Such systems are fundamental in ecology and form the building blocks of complex networks and the models that represent them."

# ╔═╡ 806150da-4f7a-11eb-0481-937f8e83ab8c
md"
## Load packages

For this tutorial you'll need the following two packages: 
- `DifferentialEquations.jl` to solve the differential equations (same 'engine' as the one used by the `BioEnergeticFoodWebs.jl` model)
- `Plots.jl` to visualise the results"

# ╔═╡ eed95432-4164-11eb-3a2b-637217b14f49
md"## Differential equations"

# ╔═╡ 10721016-4165-11eb-3724-4f656be470c7
md"Differential equations are frequently used to model the change in variables of interest through time. These changes are often referred to as derivatives (or `du/dt`). In this case, we are interested in modelling changes in the abundance of a consumer and its resource as a function of the system's key processes (growth, ingestion and mortality) and its parameters.

This type of model can be formalised as a simple Lotka-Volterra predator prey model, consisting of a set of differential equations:
- Resource dynamics: $\frac{dR}{dt} = r R (1-\frac{R}{K}) - \alpha R C$
- Consumer dynamics: $\frac{dC}{dt} = e \alpha R C - m C$

where $R$ and $C$ are the abundances of the resource and consumer respectively, $r$ is the resource's growth rate, $K$ is the system's carrying capacity, $\alpha$ is the consumer's ingestion rate, $e$ is the assimilation efficiency and $m$ is the consumer's mortality rate.

There are 3 major steps involved in constructing and solving this model in Julia: 
1. Define a function for your model (i.e., transform the above differential equations into a function that can be read by the solver). This function tells the solver how the variables of interest (here $R$ and $C$) change over time.
2. Define the problem. Here, the problem is defined by the function, the parameters ($r$, $\alpha$, $e$ and $m$), the initial conditions and the timespan of the simulation. In this step you provide the solver with all the details it needs to find the solution.
3. Solve!
"

# ╔═╡ e537957a-4168-11eb-13f0-d969b7397595
md"
### Step 1. Define the function

Here we construct a function for our model. The function needs to accept the following:
- `du` (derivatives) - a vector of changes in abundance for each species 
- `u` (values) - a vector of abundance for each species
- `p` (parameters) - a list of parameter values 
- `t` (time) - timespan
"

# ╔═╡ 19fc1444-4168-11eb-1198-a351b833a5e0
function LV_model(du,u,p,t)
   # growth rate of the resource (modelled as a logistic growth function)
   GrowthR = p.growthrate * u[1] * (1 - u[1]/p.K) 
   # rate of resource ingestion by consumer (modelled as a type I functional response)
   IngestC = p.ingestrate * u[1] * u[2]
   # mortality of consumer (modelled as density independent)
   MortC = p.mortrate * u[2]
   # calculate and store changes in abundance (du/dt):
   # change in resource abundance
   du[1] = GrowthR - IngestC
   # change in consumer abundance
   du[2] = p.assimeff * IngestC - MortC
end

# ╔═╡ 0f9cd950-416a-11eb-2d48-6b5f3e4a6f01
md"
### Step 2. Define the problem

To define the problem we first have to fix the system's parameters, the initial values and the timespan of the simulation:

- **Parameters**:  "

# ╔═╡ 7b807ffc-416a-11eb-1af2-e929f50f7286
p = (
    growthrate = 1.0, # growth rate of resource (per day)
    ingestrate = 0.2, # rate of ingestion (per day)
    mortrate = 0.2,   # mortality rate of consumer (per day)
    assimeff = 0.5,   # assimilation efficiency
    K = 10            # carrying capacity of the system (mmol/m3)
    )

# ╔═╡ e2c7c84e-4f7f-11eb-1801-55c75a3a47c4
md"Here, we have chosen to define p as a named tuple (similar to a list in R). A vector or dictionary would also work, however, named tuples are advantageous because they allow us to use explicit names and are unmutable meaning that once it's created you can't change it."

# ╔═╡ 852c1816-416a-11eb-3dfb-7bf3c3625ee1
md"
- **Initial values:**

For simplicity, we start with $R = C = 1$:
"

# ╔═╡ 37629064-4f80-11eb-1db1-adb736b32d25
u0 = [1.0; 1.0] # this needs to be an array

# ╔═╡ 47d31e28-4f80-11eb-1a4a-1949eb62f6c8
md"
- **Timespan:**
"

# ╔═╡ 9bb650f6-416a-11eb-27dc-b7acedc26b0f
tspan = (0.0,100.0) # you have to use a Pair (tuple with 2 values) of floating point numbers.

# ╔═╡ 67a6b9f0-416c-11eb-1819-753421406b22
md"
We then formally define the problem by passing the function, the parameters, the initial values and the timespan to `ODEProblem()`:
"

# ╔═╡ 76195ee0-416c-11eb-03f9-e9d7733872b2
prob = ODEProblem(LV_model, u0, tspan, p)

# ╔═╡ 8b6156c2-416c-11eb-1f01-7fcafd014e27
md"### Step 3. Solve

To solve the problem, we pass the `ODEProblem` object to the solver. 

Here we have chosen to use the default algorithm because it's a simple problem, however there are several available - see [here](https://diffeq.sciml.ai/dev/solvers/ode_solve/) for more information. These two final steps (define and solve the problem) are analogous to using the `deSolve` package in R."

# ╔═╡ cbc0d5c6-416c-11eb-002d-c3c826aefe93
sol = solve(prob)

# ╔═╡ f5edc520-416c-11eb-3547-41c229104d1e
md"The solver produces 2 objects: `sol.t` and `sol.u` that respectivley store the time steps and the variables of interest through time. Let's have a look."

# ╔═╡ 169ab594-416d-11eb-2e5b-df6c65717a0b
md"## Visualise the outputs"

# ╔═╡ 6697a486-4f81-11eb-091d-6bcc2bbc3db3
md"
Once the problem has been solved, the results can be explored and plotted. In fact, the `DifferentialEquations.jl` package has its own built in plotting recipe that provides a very fast and conventient way of visualing the abundance of the two species through time:
"

# ╔═╡ 1fd1e8a8-416d-11eb-1c15-973a12fee426
plot(sol, 
	ylabel = "Abundance", 
	xlabel = "Time", 
	title = "Lotka-Volterra", 
	label = ["prey" "predator"], 
	linestyle = [:dash :dot], 
	lw = 2) 

# ╔═╡ 99adc35a-4f81-11eb-07f3-7b9b6598c13d
md"
You could also plot the data manually using `Plots.jl` or `Gadfly.jl`, manipulate it or store it in your active project. For a recap on plotting, manipulation and visualation head back to 'Julia in VS Code' #2. 
"

# ╔═╡ Cell order:
# ╟─0f899f22-4163-11eb-19e5-63175fab4bf5
# ╟─f316e6b4-4163-11eb-0340-e92f9ace2386
# ╟─806150da-4f7a-11eb-0481-937f8e83ab8c
# ╠═0bcdf87e-4f7a-11eb-0730-33c955c3992b
# ╟─eed95432-4164-11eb-3a2b-637217b14f49
# ╟─10721016-4165-11eb-3724-4f656be470c7
# ╟─e537957a-4168-11eb-13f0-d969b7397595
# ╠═19fc1444-4168-11eb-1198-a351b833a5e0
# ╟─0f9cd950-416a-11eb-2d48-6b5f3e4a6f01
# ╠═7b807ffc-416a-11eb-1af2-e929f50f7286
# ╟─e2c7c84e-4f7f-11eb-1801-55c75a3a47c4
# ╟─852c1816-416a-11eb-3dfb-7bf3c3625ee1
# ╠═37629064-4f80-11eb-1db1-adb736b32d25
# ╟─47d31e28-4f80-11eb-1a4a-1949eb62f6c8
# ╠═9bb650f6-416a-11eb-27dc-b7acedc26b0f
# ╟─67a6b9f0-416c-11eb-1819-753421406b22
# ╠═76195ee0-416c-11eb-03f9-e9d7733872b2
# ╟─8b6156c2-416c-11eb-1f01-7fcafd014e27
# ╠═cbc0d5c6-416c-11eb-002d-c3c826aefe93
# ╟─f5edc520-416c-11eb-3547-41c229104d1e
# ╟─169ab594-416d-11eb-2e5b-df6c65717a0b
# ╟─6697a486-4f81-11eb-091d-6bcc2bbc3db3
# ╠═1fd1e8a8-416d-11eb-1c15-973a12fee426
# ╟─99adc35a-4f81-11eb-07f3-7b9b6598c13d
