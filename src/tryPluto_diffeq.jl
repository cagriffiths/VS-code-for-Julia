### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ be48ce4c-4164-11eb-1c2a-33a950344740
using DifferentialEquations, Plots

# ╔═╡ 0f899f22-4163-11eb-19e5-63175fab4bf5
md"# Differential Equations with Julia

*by Chris Griffiths, Eva Delmas and Andrew Beckerman, Dec. 2020.*"

# ╔═╡ f316e6b4-4163-11eb-0340-e92f9ace2386
md"This tutorial is adapted from a R script provided by Andrew Beckerman. 

This doc follows on from 'Using Julia in VS code' #1, #2 and #3 and assumes that your still working from your directory.

Here we will illustrate how to use `DifferentialEquation.jl` to solve differential equations. In particular we are interested in how to model a two species Lotka Volterra like (predator and prey) system. After that, we modify the activity to inlcude a contaminant effect on foraging. We assume that the effect of the contaminant follows a dose response like relationship whereby increasing levels of contaminaton results in a reduced rate of ingestion."

# ╔═╡ 82967eda-4164-11eb-2b6a-dde5704f3497
md"## Packages

For this tutorial we will need two packages: 
- `DifferentialEquations` to solve the differential equations (same 'engine' that the one being used for the `BioEnergeticFoodWebs` model)
- `Plots` to visualise the results.

This will be very similar to using deSolve in R."

# ╔═╡ eed95432-4164-11eb-3a2b-637217b14f49
md"## The model"

# ╔═╡ 10721016-4165-11eb-3724-4f656be470c7
md"This is a simple Lotka Volterra predator prey model
- Resource dynamics: $\frac{dR}{dt} = r R (1-\frac{R}{K}) - \alpha R C$
- Consumer dynamics: $\frac{dC}{dt} = e \alpha R C - m C$

where $R$ and $C$ are the abundances of the resource and consumer respectively, $r$ is the resource growth rate, $K$ is the system carrying capacity, $\alpha$ is the ingestion rate, $e$ is the assimilation efficiency and $m$ is the consumer mortality rate.

There are 3 major steps involved in solving a differential equation in Julia: 
1. Define a function for your system of differential equations (that is, transform the above equations in a function formatted in a way that it can be read by the solver), this function tell the solver how your variables (here $R$ and $C$ change over time)
2. Define the problem. The problem is defined by the function, potentially the parameters (here $r$, $\alpha$, $e$ and $m$), the initial condition and the time constraint. In this step you provide all the details the solbver will need to find the solution for a particular case.
3. Solve!
"

# ╔═╡ e537957a-4168-11eb-13f0-d969b7397595
md"
### Step 1. Define the function

All models take:
- `du` : derivatives - will hold a vector with du/dt values (derivative - change in abundance through time)
- `u` : variables values through time - will hold a vector of abundance (u) (abundance through time)
- `p` : parameters 
- `t` : time
"

# ╔═╡ 19fc1444-4168-11eb-1198-a351b833a5e0
function LV(du,u,p,t)
    GrowthP = p.growthrate * u[1] * (1 - u[1]/p.K)# logistic resource growth
    IngestC = p.ingestrate * u[1] * u[2] # type I FR by consumer on resource
    MortC = p.mortrate * u[2] # density independent mortality of consumer
    du[1] = GrowthP - IngestC
    du[2] = p.assimeff * IngestC - MortC
  end

# ╔═╡ 0f9cd950-416a-11eb-2d48-6b5f3e4a6f01
md"
### Step 2. Define the problem

- **Parameters**:  
Here we could have used another object type to store the parameters such as a vector or a dictionnary but I usually chose a named tuple (similar to R lists) because it's unmutable (meaning that the values it holds can't be changed), which makes sense in this situation and also allows us to use explicit names. 
"

# ╔═╡ 7b807ffc-416a-11eb-1af2-e929f50f7286
p = (
    growthrate = 1.0   # /day, growth rate of prey 
    , ingestrate = 0.2 # /day, rate of ingestion
    , mortrate = 0.2   # /day, mortality rate of consumer
    , assimeff = 0.5   # -, assimilation efficiency
    , K = 10           # mmol/m3, carrying capacity
    )

# ╔═╡ 852c1816-416a-11eb-3dfb-7bf3c3625ee1
md"
- **Time span**
"

# ╔═╡ 9bb650f6-416a-11eb-27dc-b7acedc26b0f
tspan = (0.0,100.0) #you have to use a Pair (tuple with 2 values) of floating point numbers.

# ╔═╡ b5b59912-416a-11eb-26ac-5bcbdbed74da
md"
- **Initial values**

We start with $R = C = 1$
"

# ╔═╡ cddb48ac-416a-11eb-3ecd-d14bcaf14bb9
u0 = [1.0; 1.0] #this needs to be an array

# ╔═╡ 67a6b9f0-416c-11eb-1819-753421406b22
md"
- **Formally define the problem**
"

# ╔═╡ 76195ee0-416c-11eb-03f9-e9d7733872b2
prob = ODEProblem(LV, u0, tspan, p)

# ╔═╡ 8b6156c2-416c-11eb-1f01-7fcafd014e27
md"### Step 3. Solve

Here we use the default algorithm because it's a simple problem but there are many you can use. Check the `DifferentialEquations.jl` [documentation](https://diffeq.sciml.ai/v2.0/) for more informations."

# ╔═╡ cbc0d5c6-416c-11eb-002d-c3c826aefe93
sol = solve(prob)

# ╔═╡ f5edc520-416c-11eb-3547-41c229104d1e
md"This gives 2 objects: `sol.t` and `sol.u` that respectively store the time steps and the variables values through time. Let's have a look."

# ╔═╡ 169ab594-416d-11eb-2e5b-df6c65717a0b
md"## Visualise the outputs"

# ╔═╡ 1fd1e8a8-416d-11eb-1c15-973a12fee426
plot(sol
	, linestyle = [:dash :dot]
	, labels = ["Prey" "Predator"]
	, c = :black
	, lw = 2
	, ylabel = "Abundance", xlabel = "Time") 

# ╔═╡ 368947a8-416d-11eb-29a9-3b7508eb7c13
md"## Let's do an experiment

This is an example of how we can do an experiment with a model.
The idea is that you create a gradient of some environmental variable like a contaminant or temperature. This gradient can be linear - like temperature at 0, 10, 20 and 30 degrees, or it could have some pattern - it might affect a parameter like foraging in a particular way for example, foraging rate may decline sigmoidally with a contaminant because of the way dose-response curves work.

This example describes that, with the model above

We modify ingestion rate by sigmoid function of contaminant by building our dose response relationship (a declining sigmoid function). 

$\alpha(d) = 1 - \frac{1}{1+10^{-5d}}$

where $\alpha$ is the still the ingestion rate from the Lotka Volterra model defined above and $d$ is the contaminant dose.
"

# ╔═╡ e2955b28-416e-11eb-2b27-ed9d10bc166d
# First we define the dose-response function
alpha(d) = (1-(1/(1+10^(-5*(d)))))

# ╔═╡ 902b9098-416f-11eb-30ef-271d762f3c9c
# Then the range of dose values
dose_range = [-1:0.1:1;]

# ╔═╡ 902bde7e-416f-11eb-1ebb-89565c1f72f8
# So we can have a range of ingestion rate values by broadcasting our dose-response function on each dose value:
αd = alpha.(dose_range)

# ╔═╡ f5519edc-416e-11eb-0188-d758dedce041
md"Let's see what it looks like:"

# ╔═╡ 5b85b698-416f-11eb-0df2-077afa2d7486
scatter(dose_range, 0.2 .* αd, xlabel = "Contaminant dose", ylabel = "Ingestion rate", c = :black, leg = false) #values of αd are shifted by 0.2 

# ╔═╡ 7a1e3b50-416f-11eb-3fac-e775f4a0458b
# This array will store the equilbrium densities for R and c
# it's always a good idea to preallocate objects with the right type and size to speed things up
eqN = zeros(length(αd), 2) 

# ╔═╡ adf73b34-417b-11eb-194a-c357b58212c1
for (i,a) in enumerate(αd) 
	# i is the index (1:1:length(αd)) and a is the corresponding value in the vector
    #parameters: the consumer rate of ingestion is modified
    parameters = (
        growthrate = 1.0   # /day, growth rate of prey 
        , ingestrate = a*0.2   # /day, rate of ingestion
        , mortrate = 0.2   # /day, mortality rate of consumer
        , assimeff = 0.5   # -, assimilation efficiency
        , K = 10
        )
    #initial values and time span are the same as above
    u0 = [1.0 ; 1.0]
    tspan = (0.0, 100.0)
    # define the problem
    prob = ODEProblem(LV, u0, tspan, parameters)
    # solve
    sol = solve(prob) #here we use the default algorithm, because it's a simple problem, see more info on how to chose your algorithm here: https://diffeq.sciml.ai/dev/solvers/ode_solve/
    # store the results 
    eqN[i,1] = sol.u[end][1] 
    eqN[i,2] = sol.u[end][2] 
end

# ╔═╡ f1acd44e-417b-11eb-05bc-b99f760a8285
md"And now we can visualise the result of our experiment: "

# ╔═╡ 0c6b7ba0-417c-11eb-1283-1daaa83a36e2
plot(dose_range, eqN
    , seriestype = [:scatter, :line]
    , label = ["" "" "Prey" "Predator"], leg = :right
    , ylabel = "Abundance at t = 100"
    , xlabel = "Dose of contaminant"
    , markershape = [:diamond :circle], mc = [:white :white]
	, msc = [:black :grey50], msw = 2
    , lw = 2, linestyle = [:dash :dot], lc = [:black :grey50])

# ╔═╡ Cell order:
# ╠═0f899f22-4163-11eb-19e5-63175fab4bf5
# ╟─f316e6b4-4163-11eb-0340-e92f9ace2386
# ╟─82967eda-4164-11eb-2b6a-dde5704f3497
# ╠═be48ce4c-4164-11eb-1c2a-33a950344740
# ╟─eed95432-4164-11eb-3a2b-637217b14f49
# ╟─10721016-4165-11eb-3724-4f656be470c7
# ╟─e537957a-4168-11eb-13f0-d969b7397595
# ╠═19fc1444-4168-11eb-1198-a351b833a5e0
# ╟─0f9cd950-416a-11eb-2d48-6b5f3e4a6f01
# ╠═7b807ffc-416a-11eb-1af2-e929f50f7286
# ╟─852c1816-416a-11eb-3dfb-7bf3c3625ee1
# ╠═9bb650f6-416a-11eb-27dc-b7acedc26b0f
# ╟─b5b59912-416a-11eb-26ac-5bcbdbed74da
# ╠═cddb48ac-416a-11eb-3ecd-d14bcaf14bb9
# ╟─67a6b9f0-416c-11eb-1819-753421406b22
# ╠═76195ee0-416c-11eb-03f9-e9d7733872b2
# ╟─8b6156c2-416c-11eb-1f01-7fcafd014e27
# ╠═cbc0d5c6-416c-11eb-002d-c3c826aefe93
# ╟─f5edc520-416c-11eb-3547-41c229104d1e
# ╟─169ab594-416d-11eb-2e5b-df6c65717a0b
# ╠═1fd1e8a8-416d-11eb-1c15-973a12fee426
# ╟─368947a8-416d-11eb-29a9-3b7508eb7c13
# ╠═e2955b28-416e-11eb-2b27-ed9d10bc166d
# ╠═902b9098-416f-11eb-30ef-271d762f3c9c
# ╠═902bde7e-416f-11eb-1ebb-89565c1f72f8
# ╟─f5519edc-416e-11eb-0188-d758dedce041
# ╠═5b85b698-416f-11eb-0df2-077afa2d7486
# ╠═7a1e3b50-416f-11eb-3fac-e775f4a0458b
# ╠═adf73b34-417b-11eb-194a-c357b58212c1
# ╟─f1acd44e-417b-11eb-05bc-b99f760a8285
# ╠═0c6b7ba0-417c-11eb-1283-1daaa83a36e2
