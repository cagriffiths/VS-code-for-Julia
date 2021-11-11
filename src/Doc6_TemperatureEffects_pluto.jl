### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 036d2e96-f6bc-4ed4-8af7-10b851997f0c
import Pkg

# ╔═╡ a6b80b5a-3951-4b5b-975f-d37b138a1a95
Pkg.activate("../")

# ╔═╡ f24bfe29-f548-47e0-8940-cfc6ae08c8b6
using BioEnergeticFoodWebs, EcologicalNetworks, CSV, Random, Plots, DataFrames, Statistics 

# ╔═╡ 67f58315-b8ec-4ddd-b841-32335d7595cd
md"
Import package manager `Pkg` and activate:
"

# ╔═╡ 0d6531d4-3578-11ec-3262-9b9f32d140c6
md"# Temperature Effects

*by Chris Griffiths, Eva Delmas and Andrew Beckerman, Oct. 2021.*"

# ╔═╡ db358daf-087d-4f27-ba4c-f782fef1a595
md"
Global temperature is expected to increase by 1-4$^{\circ}$C in the next century, a change that could have drastic impacts on ecological systems and the services they provide ([IPCC 2021](https://www.ipcc.ch/report/ar6/wg1/)). Temperature enters ecological systems at the level of the individual, driving biological rates of metabolism, growth and consumption ([Simmons et al. 2021](https://www.nature.com/articles/s41559-021-01547-4)). Despite this, the effects of increasing temperature are often felt at a range of ecological scales through reductions in individual fitness, changes in population-level traits (e.g. body size distributions), species-level extinctions, and the loss of ecological complexity (e.g. [Dell et al. 2011](https://doi.org/10.1073/pnas.1015178108); [Pawar et al. 2016](https://www.journals.uchicago.edu/doi/10.1086/684590); [Fussmann et al. 2016](https://www.nature.com/articles/nclimate2134); [Tabi et al. 2019](https://doi.org/10.1111/ele.13262)). 

In previous versions of the BEFW model, biological rates are modelled as a function of mass, and are therefore temperature independent, limiting the utility of the model to investigate temperature effects ([Delmas et al. 2016](https://doi.org/10.1111/2041-210X.12713)). In this tutorial, we will explain how this limitation is overcome, and how, via Boltzmann Arrhenius terms and the Metabolic Theory of Ecology ([Gillooly et al. 2001](DOI: 10.1126/science.1061967
); [Brown et al. 2004](https://doi.org/10.1890/03-9000); [Savage et al. 2004](https://www.journals.uchicago.edu/doi/10.1086/381872)), biological rates in the BEFW model can be altered to account for temperature effects. As in previous tutorials, we will first explain the theory (including maths and plots), then provide a worked example that is explicity designed to demonstrate how the BEFW model can be used to investigate the effects of temperature on population and community dynamics.
"

# ╔═╡ 7fa93dec-0317-48c1-9071-1e51f6aadd32
md"## Load packages"

# ╔═╡ 87e8a62f-0f37-43eb-bca6-a0466f0c687b
md"
You'll need the following packages for this tutorial:
"

# ╔═╡ fbbe5be4-1d66-4fd8-bb9a-c8a6ad4060a8
Random.seed!(37)

# ╔═╡ 7d9d7f53-bca3-4009-9c4b-21d54c1cd0f6
md"## Quick version check"

# ╔═╡ 4f27eaac-1d21-48d3-9919-d436d835f6b5
md"
Again, we recommend quickly checking that you are using the current developmental branch  of the BEFW model. To do this, execute `Pkg.status()` in the REPL, you should see 

`[9b49b652] BioEnergeticFoodWebs v1.2.0 https://github.com/PoisotLab/BioEnergeticFoodWebs.jl.git#dev-2.0.0` 

If you don't see the above, use `Pkg.rm('BioEnergeticFoodWebs')` and `Pkg.add('BioEnergeticFoodWebs#dev-2.0.0')` to remove and reinstall the correct version of the package. A future you will thank you :)! 
"

# ╔═╡ 7e80e739-c27e-4e67-9f0e-777e4fc8dcb4
md"## The theory"

# ╔═╡ 461cab06-221e-46c0-9cd8-e7d3a100d47f
md"
The BEFW model, and many other ecological models, lean heavily on the assumption that biological rates scale allometrically with body mass. By assuming this, the BEFW model simpifies the estimation of biological rates and allows complex dynamics to be simulated with relative ease. Alongside mass, we also expect biological rates to vary as a function of temperature ([Brown et al. 2004](https://doi.org/10.1890/03-9000)). The inclusion of this dependency can be achieved in several ways (see [BEFW documentation](https://poisotlab.github.io/BioEnergeticFoodWebs.jl/latest/man/temperature/#Temperature-dependence-for-biological-rates-1)), however, the most common is via the Boltzmann Arrhenius equation:

$q_i(T) = q_0 * M_i^{\beta} * exp(E-\frac{T_0 - T}{kT_0T})$

This equation can be spilt into two parts: (1) an allometric relation between the mass $M$ of species $i$ and a given rate $q$ and (2) an added term (the Boltzmann term) that describes how this relation is influenced by changes in temperature $T$. Here, $q_0$ is the intercept of the allometric relationship and $\beta$ is the exponent. Both parameters are often based on empirical observations (e.g. [Ehnes et al. 2011]( https://doi.org/10.1111/j.1461-0248.2011.01660.x)) with $\beta$ describing the effect of $M$ on $q$ independent of $T$. The parameters for the Boltzmann term include $k$ the Boltzmann's constant, $E$ the mean activation energy of $q$ and $T_0$ which is the reference temperature (20$^{\circ}$C = 293K). All parameter values are listed in Table 1: 

**Table 1**. Boltzmann Arrhenius parameters (see also [Binzer et al. 2012](https://doi.org/10.1098/rstb.2012.0230) & [Binzer et al. 2016](https://doi.org/10.1111/gcb.13086)).  

 .    | $r_i$  | $K_i$ | $x_i$  | $ar_{ij}$ | $ht_{ij}$
:---- | -----: | ----: | -----: | -------: | --------:
  $q_0$ | -15.68 |       | -16.54 | -13.1    | 9.66      
  $\beta_i$ | -0.25  | 0.28  | -0.31  | 0.25     | -0.45     
  $\beta_j$ |        |       |        | -0.8     | 0.47      
  $E$ | -0.84  | 0.71  | -0.69  | -0.38    | 0.26  

Here, $r$ is growth rate, $x$ is metabolic rate, and $ar$ and $ht$ are attack rates and handling times, respectively. $K$ signifies the carrying capacity of the system, which can also be described as a function of $M$ and $T$. See the next tutorial *Enrichment in the BEFW* for more details. 

When using the Boltzmann-Arrhenius equations to estimate biological rates, we usually use the classical version of the functional response (`:classical`, see tutorial *Functional response*). This is because it is often easier to find empiricaly derived values for $ar_{ij}$ and $ht_{ij}$ than it is to find values for $y$ (consumer-specific maximum consumption rates) and $B0$ (half saturation densities). It is important to remember that both attack rates and handling times describe an interaction between a consumer ($j$) and a resource ($i$), so the Boltzmann-Arrhenius equation for these two rates becomes:

$q_ji(T) = q_0 * M_i^{\beta_i} * M_j^{\beta_j} * exp(E-\frac{T_0 - T}{kT_0T})$

where $M_i$ and $M_j$ are the masses of the resource species and the consumer species, respectively. 
"

# ╔═╡ 5ec9d6e1-18e0-466c-ae41-d461c8e19bb3
md"## Temperature effects in the BEFW

In BEFW model, four biological rates ($x$, $r$, $ar$ and $ht$) can be modelled using Boltzmann Arrhenius equations. To illistrate the joint effects of mass and temperature on these rates, we first generate a range of temperatures in Kelvin (1$^{\circ}$C = 273K):
"

# ╔═╡ b0eebaf5-c0ef-4a38-a2a0-36fb0370a648
T = [0:1:40;] .+ 273.15 # units = Kelvin

# ╔═╡ 24f272b1-8184-4f71-b6aa-da40879af132
md"
a range of masses:
"

# ╔═╡ b1dce82b-d7ec-411e-9a20-b6490d5366cb
M = [10, 10000, 20000] # units = grams 

# ╔═╡ da5dc205-d6ef-400c-b4fc-3dedf19ac821
md"
and implement/plot on a rate by rate basis. 
"

# ╔═╡ ad288381-b0bb-4759-a4e1-151b8d737f6b
md"##### (1) Metabolic rate ($x$)"

# ╔═╡ a64cdfc4-5f6f-4001-82ac-7dfc08990515
function ScaleMetabolism(M, T)
    x0 = exp(-16.54) # intercept
    sx = -0.31 # allometric exponent (mass-dependence)
    Ex = -0.69 # activation energy
    T0 = 293.15 # 20 Celsius in Kelvins (reference temperature)
    k = 8.617e-5 # Boltzman constant 
	# return metabolic rate vector in 1/s
    return x0 .* (M .^ sx) .* exp(Ex .* ((T0 .- T) ./ (k .* T .* T0)))
end

# ╔═╡ 614c8820-5d69-4f82-bdfc-7b750479bd91
x = fill(NaN, length(T), length(M)) # preallocate an empty array

# ╔═╡ de5a5807-86db-4293-8f93-6ee9cc9be99c
for (i,t) in enumerate(T)
	for (j,m) in enumerate(M)
		x[i,j] = ScaleMetabolism(m,t)
	end
end

# ╔═╡ a6f116cf-9cc1-45d1-9df0-7d80c0338df5
plot(T .- 273.15, log10.(x), markershape = [:rect :circle :utriangle], ms = 3, mc = :black, labels = ["1g" "10kg" "20kg"], lc = :grey, legend = :topleft, xlabel = "Temperature (C)", ylabel = "log10(x) in [s-1]") # plot

# ╔═╡ 11de05dc-a9a3-4bb6-9fe6-f1ac41bf9126
md"##### (2) Growth rate ($r$)"

# ╔═╡ 358170d2-23b0-4eaf-9f74-db019f87b038
function ScaleGrowth(M, T)
    r0 = exp(-15.68) # intercept
    βr = -0.25 # allometric exponent (mass-dependence)
    Er = -0.84 # activation energy
    T0 = 293.15 # 20 Celsius in Kelvins (reference temperature)
    k = 8.617e-5 # Boltzman constant 
	# return growth rate vector in 1/s
    return r0 .* (M .^ βr) .* exp(Er .* ((T0 .- T) ./ (k .* T .* T0)))
end

# ╔═╡ c5c3b446-1d7f-4206-8c81-d36f073b12f8
r = fill(NaN, length(T), length(M)) # preallocate an empty array

# ╔═╡ b05b6a35-cfac-46de-b4ec-a85cfc65fec5
for (i,t) in enumerate(T)
	for (j,m) in enumerate(M)
		r[i,j] = ScaleGrowth(m,t)
	end
end

# ╔═╡ 4c8fe11a-d23b-4080-a1f9-0a76e1b1b24b
plot(T .- 273.15, r, markershape = [:rect :circle :utriangle], ms = 3, mc = :black, labels = ["1g" "10kg" "20kg"], lc = :grey, legend = :topleft, xlabel = "Temperature (C)", ylabel = "Intrinsic growth rate in [s-1]")

# ╔═╡ 9e6d97dd-dfa3-4d45-8a0e-71d7e3201df1
md"
It's often easier to plot $r$ on the log scale:
"

# ╔═╡ daa18ea3-1a48-444c-9ed7-e3381f8b52b6
plot(T .- 273.15, log10.(r), markershape = [:rect :circle :utriangle], ms = 3, mc = :black, labels = ["1g" "10kg" "20kg"], lc = :grey, legend = :topleft, xlabel = "Temperature (C)", ylabel = "log10(r) in [s-1]")

# ╔═╡ f3af73dd-94c2-4e3b-8686-3630182f47b0
md"##### (3) Attack rates ($ar$)"

# ╔═╡ e4f51993-49ce-4a82-86be-58c4ab17149e
function ScaleAttack(m, T)
    a0 = exp(-13.1) # intercept
    βres = 0.25 # resource allometric exponent (mass-dependence for the resource)
    βcons = -0.8 # consumer allometric exponent (mass-dependence for the consumer)
    Ea = -0.38 # activation energy
    T0 = 293.15 # 20 Celsius in Kelvins (reference temperature)
    k = 8.617E-5 # Boltzman constant 
    boltz = exp(Ea * ((T0-T)/(k*T*T0))) # calculate the Boltzman term (temperature dependence term)
	
    aij = zeros(length(m), length(m))
    for i in eachindex(m) # i = rows => consumers
      for j in eachindex(m) # j = cols => resources
        mcons = m[i] ^ βcons # mass scaling for consumers
        mres = m[j] ^ βres # mass scaling for resources
        aij[i,j] = a0 * mres * mcons * boltz
      end
    end
	# return attack rate matrix in m2/s
    return aij
end

# ╔═╡ 48f6cd5b-87e6-49ee-a2fd-1ebedf6f56a7
md"
Remember, attack rates ($ar$) are defined for a consumer-resource interaction, so they depend on the masses of both species: 
"

# ╔═╡ b60c0f8b-f5a8-44d2-b825-c33d79e3a776
ar = fill(NaN, length(T), length(M)) # preallocate an empty array

# ╔═╡ de46dc6b-8990-4172-81ac-1ce4e18a2255
for (i,t) in enumerate(T)
	ar_t = ScaleAttack(M, t) # returns a matrix with an attack rate value for all possible interactions
	# fix interactions (who eats who):
	ar[i,1] = ar_t[2,1] # sp. 2 eats sp. 1
	ar[i,2] = ar_t[3,2] # sp. 3 eats sp. 2
	ar[i,3] = ar_t[3,1] # sp. 3 eats sp. 1
end

# ╔═╡ 2e93c0a9-ad4c-4109-80b1-3b73a6eb5dc3
plot(T .- 273.15, log10.(ar), markershape = [:rect :circle :utriangle], ms = 3, mc = :black, labels = ["10kg eats 1g (ratio = 100)" "20 kg eats 10kg (ratio = 2)" "20kg eats 1g (ratio = 200)"], lc = :grey, legend = :topleft, xlabel = "Temperature (C)", ylabel = "log10(ar) in [m2/s]")

# ╔═╡ e9ce68b6-181c-4a4d-93fe-4dd9c4e9134b
md"##### (5) Handling times ($ht$)"

# ╔═╡ d1dcacd3-6540-42ec-8e1c-405631d8d9e7
md"
Below we describe the implementation of the *power* method for estimating handling time. When working with the ADBM model (for food web generation or rewiring) you may want to use the *ratio* method instead. See [Petchey et al. 2008](https://www.pnas.org/content/105/11/4191.short) for more details on the two methods.
"

# ╔═╡ 9683e0d4-07f9-4fc9-9c83-2163ec50865c
function ScaleHandling(m, T)
    h0 = exp(9.66) # intercept
    βres = -0.45 # resource allometric exponent (mass-dependence for the resource)
    βcons = 0.47 # consumer allometric exponent (mass-dependence for the consumer)
    Eh = 0.26 # activation energy
    T0 = 293.15 # 20 Celsius in Kelvins (reference temperature)
    k = 8.617E-5 # Boltzman constant 
    boltz = exp(Eh * ((T0-T)/(k*T*T0))) # calculate the Boltzman term (temperature dependence term)

    hij = zeros(length(m), length(m))
	
    for i in eachindex(m) # i = rows => consumers
        for j in eachindex(m) # j = cols => resources
            mcons = m[i] ^ βcons # mass scaling for consumers
            mres = m[j] ^ βres # mass scaling for resources
            hij[i,j] = h0 * mres * mcons * boltz
        end
    end
	
    #return handling time matrix in [s]
    return hij
end

# ╔═╡ a805265a-ef6f-4a12-b11a-5b9a9b205dad
ht = fill(NaN, length(T), length(M)) # preallocate an empty array

# ╔═╡ ceef5978-a1d9-46a1-9027-0f3dc255d67e
for (i,t) in enumerate(T)
	ht_t = ScaleHandling(M, t) # returns a matrix with a handling time value for all possible interactions
	# fix interactions (who eats who):
	ht[i,1] = ht_t[2,1] # sp. 2 eats sp. 1
	ht[i,2] = ht_t[3,2] # sp. 3 eats sp. 2
	ht[i,3] = ht_t[3,1] # sp. 3 eats sp. 1
end

# ╔═╡ 9635d601-8722-4f01-9de0-4c0cb6fb3f17
plot(T .- 273.15, log10.(ht), markershape = [:rect :circle :utriangle], ms = 3, mc = :black, labels = ["10kg eats 1g (ratio = 100)" "20 kg eats 10kg (ratio = 2)" "20kg eats 1g (ratio = 200)"], lc = :grey, legend = :left, xlabel = "Temperature (C)", ylabel = "log10(ht) in  in [s]")

# ╔═╡ 2225f354-465d-4310-a2f8-57e2f5c30995
md"## ScaleRates!()
Each of the above functions (e.g. `ScaleHandling()`) provide the code neccessary to scale biological rates by mass and temperature. Each of these functions produce a vector or matrix which can be supplied directly to a `model_parameters` object using the following code:
"

# ╔═╡ d6df00e9-8db9-4bd9-acc3-61b34bf0f5d5
begin
	A = BioEnergeticFoodWebs.nichemodel(20,0.15) # propose a network
	Z = 10.0 # assign mass based on Z
	T20 = 293.15 # fix temperature at 20C
	p = model_parameters(A, Z = Z, T = T20)
	M20 = p[:bodymass] # assign body mass vector to M
	p[:x] = ScaleMetabolism(M20, T20)
	p[:r] = ScaleGrowth(M20, T20)
	p[:ar] = ScaleAttack(M20, T20)
	p[:ht] = ScaleHandling(M20,T20)
end

# ╔═╡ 40a22973-a6f2-470d-a552-9c508a8f5311
begin
	include("common_utils.jl") # loads the content of the common_utils.jl script 
	p_new = model_parameters(A, Z = Z, T = T20, functional_response = :classical)
	ScaleRates!(p_new, 10.0) # k0 = 10.0
end

# ╔═╡ c1dc3810-6904-445f-863e-3f820129a402
md"
`p` will now contain updated values for the four biological rates each of which have been scaled to a temperature of 20$^{\circ}$C (e.g. the value of $T20$). 

To make this process easier, we've parcelled up the above functions into a larger function called `ScaleRates!()`. `ScaleRates!` takes the `p` object as an input and requires a value for the carrying capacity $k0$ to be specified (details can be found in the next tutorial *Enrichment in the BEFW*): 
"

# ╔═╡ aeafdb2e-4a65-46fd-8e41-69d1c4723cf3
md"
`ScaleRates!` acts by directly transforming the biological rates within `p` based on `p[:bodymass]` and `p[:T]`. You'll notice the addition of a `!` at the end of the function name, this is a Julia thing and means that the function transforms the input object instead of creating a new object. This function and several others have been compiled into a utility script called `common_utils.jl` which is available via the [github repo](https://github.com/cagriffiths/VS-code-for-Julia). The idea is that the lab will all work from, update, and share the `common_utils.jl` script and therefore work with the same toolbox. 
"

# ╔═╡ 6cb0ded3-ae15-4968-8f82-09f73a1e5423
md"## Timesteps/Units
In previous versions of the BEFW, the timestep of the model is normalised to the growth rate of smallest producer. This means that the `start` and `stop` arguments in the `simulate()` function are somewhat arbitary and the critical aspect is to ensure that model runs for sufficent timesteps (e.g. `stop = 2000`) to achieve steady-state dynamics (i.e. an equilibrium). 

Above, we have demonstrated that biological rates can be scaled by $M$ and $T$ based on empirical derived parameters. The units of these rates are detailed in Table 2:

**Table 2**. Units of temperature scaled biological rates. 

 .     | $unit$  
:----  | -----: 
  $x$  | 1/s     
  $r$  | 1/s       
  $ar$ | m2/s             
  $ht$ | s    


By including these rates in the BEFW model directly and not normalising, the newest version of the BEFW model simulates biomass (g/m2) dynamics in real time, whereby one timestep = one second (s). The dynamics of the BEFW model are slow, and as a result we recommend simulating for approximately three thousand years:
"

# ╔═╡ 125e1a65-bcf3-4f55-ba4d-b9d8e2287726
begin
	p_new[:h] = 2.0 # Type III functional response to stabilise dynamics
	out = simulate(p_new, rand(20), stop = Int(60*60*24*365.25*3000), interval_tkeep = 	   Int(60*60*24*365.25)) # simulate for 3000 years and save every year
end

# ╔═╡ bbf4d20b-fb31-4658-a08c-2bcd34abdceb
md"
The `interval_tkeep` argument sets the saving frequency of the dynamics. In theory, you could save every second, however, it will probably cause memory issues and will slow down the simulation. Consequently, we recommend saving at a time step that is reasonable and scales appropriately with the total length of the simulation. For instance, above we have simulated for 3000 years and saved every year. 

"

# ╔═╡ ab74a390-275d-4597-a2af-bb28233868a9
plot(out[:t] ./ Int(60*60*24*365.25), out[:B], legend = false)

# ╔═╡ dabca806-888d-4a8c-8b79-6feae3031aee
md"""
## Worked example 
"""

# ╔═╡ 80e220f9-5737-4c52-9230-96c4872cc7c8
md"
To demonstrate how the scaling of biological rates with mass and temperature can be utilised in the BEFW model, we are going explore the joint effects of Z and T on population and community dynamics. We will first propose a range temperatures and Z values, initiate a network, and simulate. For simplicity, we're only going to use one network (`A` defined above) but this code could be easily extended to included multiple networks (see previous tutorials). Moreover, instead of outputting multiple metrics, we have chosen to output only total biomass and species persistence:
"

# ╔═╡ f38dd22d-9d2e-44d3-b7c2-1b5d3b4d2248
T_range = [0:1:40;] .+ 273.15 # temperature ranging from 0 to 40C

# ╔═╡ ea75bd06-a85f-4235-9a1e-152b2225bb9f
Z_range = 10.0 .^ [1:1:5;] # consumer-resource mass ratio ranging from 10 to 100000

# ╔═╡ 7249092e-45de-436d-94a6-4faae8e975df
year = Int(60*60*24*364.25) # 1 year in seconds

# ╔═╡ 5536031c-4065-4240-9e9a-fcc7a889f0b3
df = DataFrame(T = [], Z = [], biomass = [], persistence = []) # initialize outputs data frame

# ╔═╡ 66ada38e-a029-4e2f-ad1d-9d95a128903e
for z in Z_range 
	for t in T_range
		println("T = $t and log(z) = $(log10(z))")
		p_tmp = model_parameters(A, Z = z, T = t, h = 2.0, functional_response = :classical)
		ScaleRates!(p_tmp, 10.0) 
		s = simulate(p_tmp, rand(20), stop = year*3000, interval_tkeep = year)
		tmp = (T = t, Z = z, biomass = total_biomass(s, last = 500), persistence = species_persistence(s, last = 500))
		push!(df, tmp)
	end
end

# ╔═╡ f9aa0c53-cb30-4432-84be-5a6ff7a59b12
md"""
In order to visualize our results as heatmaps (or a contour plots), we first reshape `df` to two 2D arrays:
"""

# ╔═╡ ccdf70b2-e541-4179-8c6b-26614348f7c6
TZ_array_biomass = fill(NaN, length(Z_range), length(T_range)) #preallocate a 2d array for biomass values

# ╔═╡ 48027a52-ce6b-443b-9e14-c9f0e94410f3
TZ_array_persistence = fill(NaN, length(Z_range), length(T_range)) #preallocate a 2d array for persistence values

# ╔═╡ 1e90b39b-361a-462e-9ec8-74d012f82abc
for (i,z) in enumerate(Z_range) 
	for (j,t) in enumerate(T_range)
		tmp = df[(df.Z .== z) .& (df.T .== t),:]
		TZ_array_biomass[i,j] = tmp.biomass[1]
		TZ_array_persistence[i,j] = tmp.persistence[1]
	end
end

# ╔═╡ 806387d9-9d20-4ff2-8f56-ac0ddc65c12a
md"
and plot:
"

# ╔═╡ 8c6b2062-67ef-4c4e-811d-01f8752bc5e3
p1 = heatmap(string.(T_range .- 273.15), string.(log10.(Z_range)), log10.(TZ_array_biomass), title  = "log10(Total biomass) - Heatmap", xlabel = "Temperature (C)", ylabel = "log10(Z)") 

# ╔═╡ 69cd4f02-d2c3-400c-86e2-404176b4c69e
p1b = contour(T_range .- 273.15, log10.(Z_range), log10.(TZ_array_biomass), fill = true, title  = "log10(Total biomass) - Contour", xlabel = "Temperature (C)", ylabel = "log10(Z)")

# ╔═╡ 2f627073-adf2-4a57-a1da-1af1602ab3a8
p2 = heatmap(string.(T_range .- 273.15), string.(log10.(Z_range)), TZ_array_persistence, title  = "Persistence - Heatmap", xlabel = "Temperature (C)", ylabel = "log10(Z)")

# ╔═╡ c410cc91-ed62-497d-84aa-aececeb2f57a
md"
Above we see that total biomass reduces as temperature increases, and that this relationship appears more pronouced at smaller Z values. We also see that species persistence drops off at very high temperatures, especially when Z is high. This suggests that increases in temperature can cause species extinctions and results in communities with lower total biomass. It also shows that a relationship between Z and T is evident but that the nature of this relationship might differ based on the metric under investigation. 

**Questions** to think about:

(1) Why does increasing temperature cause reductions in total biomass? Remember that body size is fixed in the BEFW model. 

(2) When Z and T are high, why do species go extinct more often?

(3) How could this experiment be extended to gain further inference? 

"

# ╔═╡ Cell order:
# ╟─67f58315-b8ec-4ddd-b841-32335d7595cd
# ╠═036d2e96-f6bc-4ed4-8af7-10b851997f0c
# ╠═a6b80b5a-3951-4b5b-975f-d37b138a1a95
# ╟─0d6531d4-3578-11ec-3262-9b9f32d140c6
# ╟─db358daf-087d-4f27-ba4c-f782fef1a595
# ╟─7fa93dec-0317-48c1-9071-1e51f6aadd32
# ╟─87e8a62f-0f37-43eb-bca6-a0466f0c687b
# ╠═f24bfe29-f548-47e0-8940-cfc6ae08c8b6
# ╠═fbbe5be4-1d66-4fd8-bb9a-c8a6ad4060a8
# ╟─7d9d7f53-bca3-4009-9c4b-21d54c1cd0f6
# ╟─4f27eaac-1d21-48d3-9919-d436d835f6b5
# ╟─7e80e739-c27e-4e67-9f0e-777e4fc8dcb4
# ╟─461cab06-221e-46c0-9cd8-e7d3a100d47f
# ╟─5ec9d6e1-18e0-466c-ae41-d461c8e19bb3
# ╠═b0eebaf5-c0ef-4a38-a2a0-36fb0370a648
# ╟─24f272b1-8184-4f71-b6aa-da40879af132
# ╠═b1dce82b-d7ec-411e-9a20-b6490d5366cb
# ╟─da5dc205-d6ef-400c-b4fc-3dedf19ac821
# ╟─ad288381-b0bb-4759-a4e1-151b8d737f6b
# ╠═a64cdfc4-5f6f-4001-82ac-7dfc08990515
# ╠═614c8820-5d69-4f82-bdfc-7b750479bd91
# ╠═de5a5807-86db-4293-8f93-6ee9cc9be99c
# ╠═a6f116cf-9cc1-45d1-9df0-7d80c0338df5
# ╟─11de05dc-a9a3-4bb6-9fe6-f1ac41bf9126
# ╠═358170d2-23b0-4eaf-9f74-db019f87b038
# ╠═c5c3b446-1d7f-4206-8c81-d36f073b12f8
# ╠═b05b6a35-cfac-46de-b4ec-a85cfc65fec5
# ╠═4c8fe11a-d23b-4080-a1f9-0a76e1b1b24b
# ╟─9e6d97dd-dfa3-4d45-8a0e-71d7e3201df1
# ╠═daa18ea3-1a48-444c-9ed7-e3381f8b52b6
# ╟─f3af73dd-94c2-4e3b-8686-3630182f47b0
# ╠═e4f51993-49ce-4a82-86be-58c4ab17149e
# ╟─48f6cd5b-87e6-49ee-a2fd-1ebedf6f56a7
# ╠═b60c0f8b-f5a8-44d2-b825-c33d79e3a776
# ╠═de46dc6b-8990-4172-81ac-1ce4e18a2255
# ╠═2e93c0a9-ad4c-4109-80b1-3b73a6eb5dc3
# ╟─e9ce68b6-181c-4a4d-93fe-4dd9c4e9134b
# ╟─d1dcacd3-6540-42ec-8e1c-405631d8d9e7
# ╠═9683e0d4-07f9-4fc9-9c83-2163ec50865c
# ╠═a805265a-ef6f-4a12-b11a-5b9a9b205dad
# ╠═ceef5978-a1d9-46a1-9027-0f3dc255d67e
# ╠═9635d601-8722-4f01-9de0-4c0cb6fb3f17
# ╟─2225f354-465d-4310-a2f8-57e2f5c30995
# ╠═d6df00e9-8db9-4bd9-acc3-61b34bf0f5d5
# ╟─c1dc3810-6904-445f-863e-3f820129a402
# ╠═40a22973-a6f2-470d-a552-9c508a8f5311
# ╟─aeafdb2e-4a65-46fd-8e41-69d1c4723cf3
# ╟─6cb0ded3-ae15-4968-8f82-09f73a1e5423
# ╠═125e1a65-bcf3-4f55-ba4d-b9d8e2287726
# ╟─bbf4d20b-fb31-4658-a08c-2bcd34abdceb
# ╠═ab74a390-275d-4597-a2af-bb28233868a9
# ╟─dabca806-888d-4a8c-8b79-6feae3031aee
# ╟─80e220f9-5737-4c52-9230-96c4872cc7c8
# ╠═f38dd22d-9d2e-44d3-b7c2-1b5d3b4d2248
# ╠═ea75bd06-a85f-4235-9a1e-152b2225bb9f
# ╠═7249092e-45de-436d-94a6-4faae8e975df
# ╠═5536031c-4065-4240-9e9a-fcc7a889f0b3
# ╠═66ada38e-a029-4e2f-ad1d-9d95a128903e
# ╟─f9aa0c53-cb30-4432-84be-5a6ff7a59b12
# ╠═ccdf70b2-e541-4179-8c6b-26614348f7c6
# ╠═48027a52-ce6b-443b-9e14-c9f0e94410f3
# ╠═1e90b39b-361a-462e-9ec8-74d012f82abc
# ╟─806387d9-9d20-4ff2-8f56-ac0ddc65c12a
# ╠═8c6b2062-67ef-4c4e-811d-01f8752bc5e3
# ╠═69cd4f02-d2c3-400c-86e2-404176b4c69e
# ╠═2f627073-adf2-4a57-a1da-1af1602ab3a8
# ╟─c410cc91-ed62-497d-84aa-aececeb2f57a
