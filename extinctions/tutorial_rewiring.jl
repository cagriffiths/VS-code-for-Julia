#=
How to use the rewirinh methods in BioEnergeticFoodWebs
author: Eva Delmas
date: April 25th, 2021
=#

# Set up

using BioEnergeticFoodWebs
using EcologicalNetworks
include("extinctions/utils.jl") 
import Random.seed!
seed!(22)

# Generate a food web

S = 30
C = 0.25
A = EcologicalNetworks.nichemodel(S, C).edges 
A = Int.(Array(A))
#we can calculate species mass based on their trophic rank and Z, the consumer resource mass ratio
Z = 10 #consumers are in average 10 times bigger than their prey
M = Z .^ (trophic_rank(A) .- 1)
#now for visualisation purposes let's order the matrix by increasing body mass
M_order = sortperm(M)
M = M[M_order]
A = A[M_order, M_order]
#and we can visualize the interaction matrix 
pltA = webplot(A, true) #true means that we want to have consumers plotted as rows(i) and resources as columns (j)
#the resulting plot shows the interaction matrix A[i,j] = 1 is represented by a black dot and 
#means that i eats j. Dots on the diagonal indicate canibalism (i eats i).
# niche model food webs will look messy because their generation is not based on mass

# Generate the sets of parameters

#no rewiring is the default, technically you don't need to specify rewire_method in that case
p_none = model_parameters(A, bodymass = M, h = 2.0, rewire_method = :none) 
#ADBM rewiring is the trickiest one, there are many arguments that you can change, we'll see what 
#these arguments are later, for now, let's use the default set
p_adbm = model_parameters(A, bodymass = M, h = 2.0, rewire_method = :ADBM) 
#DO stands for diet overlap, that's from Staniczencko's paper
p_do = model_parameters(A, bodymass = M, h = 2.0, rewire_method = :DO)
#DS stands for diet similarity, from Gilljam's paper 
p_ds = model_parameters(A, bodymass = M, h = 2.0, rewire_method = :DS)

# Set up simulations

tstop = 3000 #simulation time
ϵ = 1e-10 #extinction threshold
#when a species biomass reaches the extinction threshold, it's considered as
#extinct. It's important to know the extinction threshold when using rewiring because 
#rewiring will be triggered at each extinction event during the simulations. 
# (We'll see later how this can be different for the ADBM)
b0 = rand(S)

# Simulate biomass dynamics for each

#no rewiring
s_none = simulate(p_none, b0, stop = tstop, extinction_threshold = ϵ)
#ADBM
s_adbm = simulate(p_adbm, b0, stop = tstop, extinction_threshold = ϵ)
#diet overlap
s_do = simulate(p_do, b0, stop = tstop, extinction_threshold = ϵ)
#diet similarity 
s_ds = simulate(p_ds, b0, stop = tstop, extinction_threshold = ϵ)

# Visualize the results
plt_dyn_none = plot(s_none[:B], leg = false, c = :black, ylims = (-0.01,3), xlabel = "time", ylabel = "biomass")
plt_dyn_adbm = plot(s_adbm[:B], leg = false, c = :black, ylims = (-0.01,3), xlabel = "time", ylabel = "biomass")
plt_dyn_do = plot(s_do[:B], leg = false, c = :black, ylims = (-0.01,3), xlabel = "time", ylabel = "biomass")
plt_dyn_ds = plot(s_ds[:B], leg = false, c = :black, ylims = (-0.01,3), xlabel = "time", ylabel = "biomass")
plt_mat_none = webplot(p_none[:A], true)
plt_mat_adbm = webplot(p_adbm[:A], true)
plt_mat_do = webplot(p_do[:A], true)
plt_mat_ds = webplot(p_ds[:A], true)

plot(plt_dyn_none, plt_dyn_adbm, plt_dyn_do, plt_dyn_ds, 
    plt_mat_none, plt_mat_adbm, plt_mat_do, plt_mat_ds
    , layout = grid(2,4), size = (1000,400))

#=
Viz. idea
- color unchanged interaction in grey
- color "removed" links in white + black stroke
- color new links in black
- area (line i + column i) = transparent light grey for extinct species 

Trouver une façon de mettre à jour la matrice en enlevant 
les espèces éteintes + les espèces déconnectée pour 
pouvoir recalculer les mesures de structure.
=#
