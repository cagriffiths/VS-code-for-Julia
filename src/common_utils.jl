#=
This file contains some functions that are common to multiple projects in the lab
- Biological rates temperature scaling (Boltzman-Arrhenius)
- Random draw of ADBM parameters 
- Generating ADBM food webs 
- Plotting a foob web interaction matrix
- Updating the matrix based on simulation outputs (with BioEnergeticFoodWebs)
- Alternative measure for calculating trophic rank

Author: Eva Delmas
Date: July 9th 2021
=#

using Statistics
import BioEnergeticFoodWebs.trophic_rank
using LinearAlgebra
using Distributions
using Plots
using EcologicalNetworksPlots

#BODYMASS 
#(these functions are used to perform the same calculations for trophic rank and body mass as Binzer et al., 2016)

function normalize_matrix(A)
    A2 = transpose(A)
    colsum = sum(A2, dims = 1)
    colsum[colsum .== 0] .= 1
    normA = (A2'./vec(colsum))'
    return normA
end

function trophic_position(A)
    S = size(A,1)
    if S < 3
        return trophic_rank(A)
    else
        Mt = normalize_matrix(A)
        m = Int.(zeros(S,S))
        [m[i,i] = 1 for i in 1:S] #fill diag with 1
        detM = det(m .- Mt')
        if detM != 0
            tp = \(m .- Mt', repeat([1], S))
        else
            tmp = m 
            for i in 1:9
                tmp = tmp * Mt' .+ m
            end
            tp = tmp * repeat([1], S)
        end
        return tp
    end
end

function bodymass_calc_position(Z, A)
    trophiclevel = trophic_position(A)
    dist_eps = Normal(0, 1)
    eps_L = rand(dist_eps, size(A,1)) #we don't want all the species of a trophic level having exactly the same mass
    m = 0.01 .* Z .^ (trophiclevel .- 1 .+ eps_L)
    return m
end

function bodymass_calc_rank(Z, A)
    trophiclevel = trophic_rank(A)
    dist_eps = Normal(0, 1)
    eps_L = rand(dist_eps, size(A,1)) #we don't want all the species of a trophic level having exactly the same mass
    m = 0.01 .* (Z .^ ((trophiclevel .- 1) .+ eps_L))
    return m
end

#METABOLIC RATES - TEMPERATURE SCALING

"""
Scale rates
This function modifies the BEFWM parameter object with temperature scaled biological rates 
using Boltzman Arrhenius equation (and same parameterization an Binzer et al., 2016)
- par = parameter object 
- k0 = intercept for the scaling of the carrying capacity
- Ea = activation energy for attack rate 
- Eh = activation energy for handling time
- prod_metab (Bool) = do basla species have metabolic losses? 
- Hmethod = method for calculating handling time (:ratio or :power)
"""
function ScaleRates!(par, k0; Ea = -0.38, Eh = 0.26, prod_metab = false, Hmethod = :ratio, use_adbmpar = false, infvalues = false)
    T = par[:T]
    M = par[:bodymass]
    ri = ScaleGrowth(M, T)
    r = ri .* par[:is_producer]
    xi = ScaleMetabolism(M, T)
    x = prod_metab ? xi : xi .* .!par[:is_producer]
    if use_adbmpar
        ht = ScaleHandling(par, Eh, infvalues = infvalues)
        ar = ScaleAttack(par, Ea)
    else
        ht = ScaleHandling(M, T, method = Hmethod, infvalues = infvalues)
        ar = ScaleAttack(M, T)
    end
    K = carrying(M, k0, T)
    par[:r] = r
    par[:x] = x
    par[:ar] = ar
    par[:ht] = ht
    par[:K] = K
end

function pass_adbm_to_befwm!(befwm_par, adbm_par)
    befwm_par[:e] = adbm_par.e
    befwm_par[:a_adbm] = adbm_par.a
    befwm_par[:ai] = adbm_par.ai
    befwm_par[:aj] = adbm_par.aj
    befwm_par[:b] = adbm_par.b
    befwm_par[:h_adbm] = adbm_par.h
    befwm_par[:n] = adbm_par.n
    befwm_par[:ni] = adbm_par.ni
    #befwm_par[:hi] = adbm_par.hi
    #befwm_par[:hj] = adbm_par.hj
end

#Growth rate (producers)
function ScaleGrowth(M, T)
    r0 = exp(-15.68)
    βr = -0.25
    Er = -0.84
    T0 = 293.15 #20 celsius
    k = 8.617e-5
    return r0 .* (M .^ βr) .* exp(Er .* ((T0 .- T) ./ (k .* T .* T0)))
end

#Metabolic rate
function ScaleMetabolism(M, T)
    x0 = exp(-16.54)
    sx = -0.31
    Ex = -0.69
    T0 = 293.15
    k = 8.617e-5
    return x0 .* (M .^ sx) .* exp(Ex .* ((T0 .- T) ./ (k .* T .* T0)))
end

#Handling time
function ScaleHandling(m::Array{Float64,1}, T::Number; method = :ratio, infvalues = true)

    h0 = exp(9.66)
    βres = -0.45
    βcons = 0.47
    Eh = 0.26
    T0 = 293.15
    k = 8.617E-5
    boltz = exp(Eh * ((T0-T)/(k*T*T0)))
    b = 0.401
    h = 1.0
    S = length(m)

    hij = zeros(length(m), length(m))

    if method == :power

        for i in eachindex(m) #i = rows => consumers
            for j in eachindex(m) #j = cols => resources
              mcons = m[i] ^ βcons #mass scaled for cons
              mres = m[j] ^ βres #mass scaled for res
              hij[i,j] = h0 * mres * mcons * boltz
            end
          end

    elseif method == :ratio

        ratios = (m ./ m')' #PREDS IN ROWS : PREY IN COLS
        if infvalues
            for i = 1:S 
                for j = 1:S
                    if ratios[j,i] < b
                        hij[j,i] =  h / (b - ratios[j,i])
                    else
                        hij[j,i] = Inf
                    end
                end    
            end
        else
            for i in 1:S
                for j in 1:S
                    hij[j,i] =  h / (b - ratios[j,i])
                end
            end
        end

    else
        error("Wrong method, method should be either :power or :ratio")
    end
    
    return hij
end

function ScaleHandling(par::Dict{Symbol,Any}, E::Float64; infvalues = true)

    m = par[:bodymass]
    h0 = par[:h_adbm]
    #βres = par[:hi]
    #βcons = par[:hj]
    Eh = E
    T0 = 293.15
    T = par[:T]
    k = 8.617E-5
    boltz = exp(Eh * ((T0-T)/(k*T*T0)))
    b = par[:b]
    S = length(m)
    method = par[:Hmethod]

    hij = zeros(length(m), length(m))

    if method == :power

        for i in eachindex(m) #i = rows => consumers
            for j in eachindex(m) #j = cols => resources
              mcons = m[i] ^ βcons #mass scaled for cons
              mres = m[j] ^ βres #mass scaled for res
              hij[i,j] = h0 * mres * mcons * boltz
            end
          end

    elseif method == :ratio

        ratios = (m ./ m')' #PREDS IN ROWS : PREY IN COLS
        if infvalues
            for i = 1:S 
                for j = 1:S
                    if ratios[j,i] < b
                        hij[j,i] =  h0 / (b - ratios[j,i])
                    else
                        hij[j,i] = Inf
                    end
                end    
            end
        else
            for i in 1:S
                for j in 1:S
                    hij[j,i] =  h0 / (b - ratios[j,i])
                end
            end
        end

    else
        error("Wrong method, method should be either :power or :ratio")
    end
    
    return hij
end

#Attack rate
function ScaleAttack(m::Array{Float64,1}, T::Number)
    a0 = exp(-13.1)
    βres = 0.25 #resource
    βcons = -0.8 #consumer
    Ea = -0.38
    T0 = 293.15
    k = 8.617E-5
    boltz = exp(Ea * ((T0-T)/(k*T*T0)))
    aij = zeros(length(m), length(m))
    for i in eachindex(m) #i = rows => consumers
      for j in eachindex(m) #j = cols => resources
        mcons = m[i] ^ βcons #mass scaled for cons
        mres = m[j] ^ βres #mass scaled for res
        aij[i,j] = a0 * mres * mcons * boltz
      end
    end
    return aij
end

function ScaleAttack(par::Dict{Symbol,Any}, E::Float64)

    m = par[:bodymass]
    a0 = par[:a_adbm]
    βres = par[:ai] #resource
    βcons = par[:aj] #consumer
    Ea = E
    T0 = 293.15
    T = par[:T]
    k = 8.617E-5
    boltz = exp(Ea * ((T0-T)/(k*T*T0)))
    aij = zeros(length(m), length(m))
    for i in eachindex(m) #i = rows => consumers
      for j in eachindex(m) #j = cols => resources
        mcons = m[i] ^ βcons #mass scaled for cons
        mres = m[j] ^ βres #mass scaled for res
        aij[i,j] = a0 * mres * mcons * boltz
      end
    end
    return aij
end

#Maximum consumption
function MaxCons(ht, x)
    y = 1 ./ ht
    y_norm = y ./ x
    y_norm[y_norm .== Inf] .= 0.0
    return y_norm
end

#Half saturation density
function HalfSaturation(ht, ar)
    hs = 1 ./ (ht .* ar)
    hs[hs .== Inf] .= 0.0
    return hs
end

#Carrying capacity
function carrying(m, k0, T)
    βk = 0.28
    Ek = 0.71 
    return k0 .* (m .^ βk) .* exp.(Ek .* (293.15 .- T ) ./ (8.617e-5 .* T .* 293.15))
end

#initial biomass
function B0(par)
    A = par[:A]
    kcap = par[:K]
    b0 = zeros(size(A,1))
    is_producer = sum(A, dims = 2) .== 0
    carrying_prod = kcap[vec(is_producer)]
    kmean = mean(carrying_prod)
    b0[vec(is_producer)] .= kcap[vec(is_producer)]
    b0[vec(.!is_producer)] .= kmean/8
    return b0
end

"""
Random ADBmodel parameters
    'random_adbm_parameters(S::Int)'

Arguments:
- S (Int64): Species richness

Returns:
- a named tuple with parameters value that can be directly passed to the 'generateADBM' function

This function generates the set of parameters necessary to run the 
allometric diet breadth model (ADBm) with the "ratio" method for 
handling time. 
The range of variation for each parameter is set based on Owen Petchey's 
shiny app sliders (see https://owenpetchey.shinyapps.io/ADBM_shiny/)
(some range have been reduced after investigating their effect on structure)
"""
function random_adbm_parameters(S)
    μM = Uniform(1,15) #modif
    σM = Uniform(1,10)
    mM = rand(μM)
    sM = rand(σM)
    dM = LogNormal(mM, sM)
    M = rand(dM, S)
    ar_cst = Uniform(-10,-5)
    ar_expi = Uniform(-1,1)
    ar_expj = Uniform(-1,1)
    Ea = Uniform(-0.4,-0.2)
    ht_cst = Uniform(1,2)
    ht_threshold = Uniform(0.1,1) #modif
    ht_expi = Uniform(-1,1) 
    ht_expj = Uniform(-1,1)
    Eh = Uniform(0.2, 0.4)
    e_cst = Uniform(1,2)
    e_expi = 1
    n_cst = 1
    n_expi = Uniform(-1,-0.5)
    return (S = S, M = sort(M), e = rand(e_cst), a = 10^(rand(ar_cst)), ai = rand(ar_expi), aj = rand(ar_expj), Ea = rand(Ea), b = rand(ht_threshold), h = rand(ht_cst), hi = rand(ht_expi), hj = rand(ht_expj), Eh = rand(Eh), n = rand(n_cst), ni = rand(n_expi))
end

function empirical_adbm_parameters(S)
    μM = Uniform(1,15) #modif
    σM = Uniform(1,10)
    mM = rand(μM)
    sM = rand(σM)
    dM = LogNormal(mM, sM)
    M = rand(dM, S)
    ar_cst = exp(-13.1)
    ar_expi = 0.25 #resource
    ar_expj = -0.8 #consumer
    Ea = -0.38
    ht_cst = exp(9.66)
    ht_threshold = Uniform(0.1,1) #modif
    ht_expi = -0.45 #resource
    ht_expj = 0.47 #consumer
    Eh = 0.26
    e_cst = Uniform(1,2)
    e_expi = 1
    n_cst = 1
    n_expi = Uniform(-1,-0.5)

    return (S = S, M = sort(M), e = e_cst, a = 10^(ar_cst), ai = ar_expi, aj = ar_expj, Ea = Ea, b = rand(ht_threshold), h = ht_cst, hi = ht_expi, hj = ht_expj, Eh = Eh, n = n_cst, ni = rand(n_expi))

end
"""
Food web generation with the ADB model (ratio method)
    'generateADBM(p::NamedTuple)'

Arguments:
- p (NamedTuple): parameter set (see outputs of 'random_adbm_parameters')

Returns:
- a food web's interaction matrix (consumers as rows, resources as columns)

This function generates an interaction matrix using the allometric diet
breadth model (ratio method for the handling time)
"""
function generateADBM(p::NamedTuple)

    #get feeding rates 
    E = p.e .* p.M
    A = p.a .* (p.M' .^ p.ai) .* (p.M .^ p.aj) # a * prey * pred
    ratios = (p.M ./ p.M')' #PREDS IN ROWS : PREY IN COLS
    S = p.S
    H = zeros(Float64,(S,S))
    for i = 1:S , j = 1:S
      if ratios[j,i] < p.b
        H[j,i] =  p.h / (p.b - ratios[j,i])
      else
        H[j,i] = Inf
      end
    end
    N = p.n .* (p.M .^ p.ni)
    L = zeros(Float64, (S,S))
    for i = 1:S #for each prey
        L[:,i] = A[:,i] * N[i]
    end

    #get feeding links
    mat = zeros(Int64, (S,S))
    for i in 1:S
        profit = E ./ H[i,:]
      
        profs = sortperm(profit,rev = true)
      
        LSort = L[i,profs]
        HSort = H[i,profs]
        ESort = E[profs]
      
        LH = cumsum(LSort .* HSort)
        EL = cumsum(ESort .* LSort)
      
        LH[isnan.(LH)] .= Inf
        EL[isnan.(EL)] .= Inf
      
        cumulativeProfit = EL ./ (1 .+ LH)
      
        if all(0 .== cumulativeProfit)
            feeding = []
        else
            feeding = profs[1:maximum(findall(cumulativeProfit .== maximum(cumulativeProfit)))]
        end
        mat[i,feeding] .= 1
    end
    return mat
end

function profitability(p::NamedTuple)
        #get feeding rates 
        E = p.e .* p.M
        A = p.a .* (p.M' .^ p.ai) .* (p.M .^ p.aj) # a * prey * pred
        ratios = (p.M ./ p.M')' #PREDS IN ROWS : PREY IN COLS
        S = p.S
        H = zeros(Float64,(S,S))
        for i = 1:S , j = 1:S
          if ratios[j,i] < p.b
            H[j,i] =  p.h / (p.b - ratios[j,i])
          else
            H[j,i] = Inf
          end
        end
        N = p.n .* (p.M .^ p.ni)
        L = zeros(Float64, (S,S))
        for i = 1:S #for each prey
            L[:,i] = A[:,i] * N[i]
        end
    
        #get feeding links
        mat = zeros(S,S)
        for i in 1:S
            for j in 1:S
                mat[i,j] = (L[i,j]*E[i]) / (1+(L[i,j]*H[i,j]))
            end
        end
        return mat
end

"""
Generate a food web with the ADBM that has 
- at least 1 producer 
- a connectance below 0.5
- no species with a mass > 2 tons
- parameters: :random or :empirical
"""
function ADBM_foodweb(S ; parameters = :random)
    co = 1.0
    np = 0
    m = 1e7
    #=
    The goal of this while loop is to get rid of any food web that 
    we would find unrealistic (a connectance higher that 0.5, no 
    producers or species with a mass > 2 tons).  
    =#
    A = fill(0, S,S) #preallocate A
    if parameters == :random
        adbm_p = random_adbm_parameters(S) #preallocate the parameter object
    elseif parameters == :empirical
        adbm_p = empirical_adbm_parameters(S)
    else
        println("parameters must be either :random or :empirical")
    end
    while (co >= 0.5) | (np < 1) | (m > 200e6)
        #the adbm needs to be parameterized, we use random parameters that fall in a realistic range for that
        if parameters == :random
            adbm_p = random_adbm_parameters(S) #preallocate the parameter object
        elseif parameters == :empirical
            adbm_p = empirical_adbm_parameters(S)
        end
        #we check the mass of the largest species to check that it's reasonable
        m = maximum(adbm_p.M)
        #we generate teh food web
        A = generateADBM(adbm_p)
        #check connectance
        co = sum(A / (S^2))
        #check number of producers
        np = sum(sum(A, dims = 2) .== 0)
    end
    return A, adbm_p
end

"""
This function is used internally by the webplot function, it just transform 
an interaction matrix into a list of interaction.
"""
function matrix_to_list(A)
    idx = findall(A .== 1)
    from_sp = (i->i[1]).(idx)
    to_sp = (i->i[2]).(idx)
    return hcat(from_sp, to_sp)
end

"""
This function is also used internally by the webplot function. 
"""
function invert(v, S)
    1 .+ (S .- v)
end

"""
Updates the interaction matrix based on the vector of extinct species 

    `updateA(out)`

- `out` is the BEFWM simulation output

Returns a matrix of dimension S where S is the number of persistent species. This function also
checks for disconnected consumers. If it detect any, it will print a message and return a vector
with the list of disconnected species instead of the updated matrix.
"""
function updateA(out)
    A = out[:p][:A]
    S = size(A,1)
    id_alive = trues(S)
    id_alive[out[:p][:extinctions]] .= false
    Anew = A[id_alive, id_alive]
    #check for status change (consumers can't become producers)
    id_th_prod = sum(A, dims = 2) .== 0
    alive_prod = findall((id_th_prod) .& (id_alive))
    alive_prod = [i[1] for i in alive_prod]
    discosp = []
    for i in alive_prod
        if i ∉ findall(out[:p][:is_producer])
            println("/!\\ disconnected consumer $i identified as producer")
            push!(discosp, i)
        end
    end
    toreturn = length(discosp) == 0 ? Anew : discosp
    return toreturn
end

"""
Plot the interaction matrix :tada: with consumer as either rows or columns :tada: 
whichever you prefer! 

    `plot(A, consasrow)`

- use `plot(A, true)` to have consumers in rows
- use `plot(A, false)` to have consumers in columns
"""
function webplot(A::Array{Int64,2}; consasrow = true)
    S = size(A,1)
    if !consasrow
        floatA = Float64.(A)
        listA = matrix_to_list(floatA')
        plt = scatter(listA[:,2], invert(listA[:,1], S)
            , ms = 3, c = :black
            , size = (300,300), leg = false
            , framestyle = :box, ticks = ([1.5:1:S;], repeat([""], S)), foreground_color_axis = :white
            , xlims = (0.5,S+0.5), ylims = (0.5,S+0.5))    
        plot!([1,S], [S,1], c = :black, linestyle = :dash)
        xlabel!("consumers")
        ylabel!("resources")
    else
        floatA = Float64.(A)
        listA = matrix_to_list(floatA)
        plt = scatter(listA[:,2], invert(listA[:,1],S)
        , ms = 3, c = :black
        , size = (300,300), leg = false
        , framestyle = :box, ticks = ([1.5:1:S;], repeat([""], S)), foreground_color_axis = :white
        , xlims = (0.5,S+0.5), ylims = (0.5,S+0.5))    
        plot!([1,S], [S,1], c = :black, linestyle = :dash)
        ylabel!("consumers")
        xlabel!("resources")
    end
    return plt
end

function webplot(out::Dict{Symbol,Any}; consasrow = true, z = [], plotextinct = true, clr = :heat)
    par = out[:p]
    S = par[:S]
    if plotextinct
        A = par[:A]
    else
        ispersist = trues(par[:S])
        idextinct = par[:extinctions]
        A = updateA(par)
    end
    length(z) != 0 &&  @assert size(z) == (S, S)
    if length(z) != 0
        plt = heatmap(z[end:-1:1,:], c = clr, fillalpha = 0.6)
    else
        z = fill(NaN, S, S)
        plt = heatmap(z[end:-1:1,:], c = clr)
    end
    if !consasrow
        floatA = Float64.(A)
        listA = matrix_to_list(floatA')
        scatter!(plt, listA[:,2], invert(listA[:,1], S)
            , ms = 3, c = :black
            , size = (300,300), leg = false
            , framestyle = :box, ticks = ([1.5:1:S;], repeat([""], S)), foreground_color_axis = :white
            , xlims = (0.5,S+0.5), ylims = (0.5,S+0.5))    
        plot!([1,S], [S,1], c = :black, linestyle = :dash)
        xlabel!("consumers")
        ylabel!("resources")
    else
        floatA = Float64.(A)
        listA = matrix_to_list(floatA)
        scatter!(plt, listA[:,2], invert(listA[:,1],S)
        , ms = 3, c = :black
        , size = (325,300), leg = false
        , framestyle = :box, ticks = ([1.5:1:S;], repeat([""], S)), foreground_color_axis = :white
        , xlims = (0.5,S+0.5), ylims = (0.5,S+0.5), margin=8Plots.mm)    
        plot!([0.5,S+0.5], [S+0.5,0.5], c = :black, linestyle = :dash)
        ylabel!("consumers")
        xlabel!("resources")
    end
    return plt
end 