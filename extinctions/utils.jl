using Plots, Distributions, BioEnergeticFoodWebs

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
Plot the interaction matrix :tada: with consumer as either rows or columns :tada: 
whichever you prefer! 

    `plot(A, consasrow)`

- use `plot(A, true)` to have consumers in rows
- use `plot(A, false)` to have consumers in columns
"""
function webplot(A, consasrow = true)
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
Scale biological rates
"""
function ScaleRates!(p, p_adbm)
    M = p[:bodymass]
    T = p[:T]
    A = p[:A]
    isP = p[:is_producer]
    r = ScaleGrowth(M, T)
    r[.!isP] .= 0.0
    x = ScaleMetabolism(M, T)
    x[isP] .= 0.0
    ar = p_adbm.a .* (p_adbm.M' .^ p_adbm.ai) .* (p_adbm.M .^ p_adbm.aj) # a * prey * pred
    ratios = (p_adbm.M ./ p_adbm.M')' #PREDS IN ROWS : PREY IN COLS
    S = p_adbm.S
    ht = zeros(Float64,(S,S))
    for i = 1:S , j = 1:S
        ht[j,i] =  p_adbm.h / (p_adbm.b - ratios[j,i])
    end
    p[:r] = r
    p[:x] = x
    p[:ar] = ar
    p[:ht] = ht
end

"""
Growth rate with Bolzman Arrhenius 
"""
function ScaleGrowth(M, T)
    r0 = exp(-15.68)
    βr = -0.25
    Er = -0.84
    T0 = 293.15 #20 celsius
    k = 8.617e-5
    return r0 .* (M .^ βr) .* exp(Er .* ((T0 .- T) ./ (k .* T .* T0)))
end

"""
Metabolic rate with Bolzman Arrhenius 
"""
function ScaleMetabolism(M, T)
    x0 = exp(-16.54)
    sx = -0.31
    Ex = -0.69
    T0 = 293.15
    k = 8.617e-5
    return x0 .* (M .^ sx) .* exp(Ex .* ((T0 .- T) ./ (k .* T .* T0)))
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
"""
function random_adbm_parameters(S)
    μM = Uniform(1,15)
    σM = Uniform(1,10)
    mM = rand(μM)
    sM = rand(σM)
    dM = LogNormal(mM, sM)
    M = rand(dM, S)
    ar_cst = Uniform(-10,-5)
    ar_expi = Uniform(0.5,1)
    ar_expj = Uniform(0.5,1)
    ht_cst = Uniform(1,2)
    ht_threshold = Uniform(0.1,1)
    e_cst = Uniform(1,2)
    e_expi = 1
    n_cst = 1
    n_expi = Uniform(-1,0)
    return (S = S, M = sort(M), μM = mM, σM = sM, e = rand(e_cst), a = 10^(rand(ar_cst)), ai = rand(ar_expi), aj = rand(ar_expj), b = rand(ht_threshold), h = rand(ht_cst), n = rand(n_cst), ni = rand(n_expi))
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

"""
Generate a food web with the ADBM that has 
- at least 1 producer 
- a connectance below 0.5
- no species with a mass > 2 tons
"""
function ADBM_foodweb(S)
    co = 1.0
    np = 0
    m = 1e7
    #=
    The goal of this while loop is to get rid of any food web that 
    we would find unrealistic (a connectance higher that 0.5, no 
    producers or species with a mass > 2 tons).  
    =#
    A = fill(0, S,S) #preallocate A
    adbm_p = random_adbm_parameters(S) #preallocate the parameter object
    while (co >= 0.5) | (np < 1) | (m > 200e6)
        #the adbm needs to be parameterized, we use random parameters that fall in a realistic range for that
        adbm_p = random_adbm_parameters(S) 
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
Modified versuion of model parameters 
"""
function model_parameters_modif(A, p_adbm, rewire_method, Δtadbm)
    M = p_adbm.M
    isP = vec(sum(A, dims = 2) .== 0)
    gr = ScaleGrowth(M, 293.15)
    gr[.!isP] .= 0.0
    mr = ScaleMetabolism(M, 293.15)
    mr[isP] .= 0.0
    ar = p_adbm.a .* (p_adbm.M' .^ p_adbm.ai) .* (p_adbm.M .^ p_adbm.aj) # a * prey * pred
    ratios = (p_adbm.M ./ p_adbm.M')' #PREDS IN ROWS : PREY IN COLS
    S = p_adbm.S
    ht = zeros(Float64,(S,S))
    for i = 1:S , j = 1:S
        ht[j,i] =  p_adbm.h / (p_adbm.b - ratios[j,i])
    end
    if rewire_method == :ADBM
        p = model_parameters(A
            , r = gr
            , x = mr
            , ar = ar
            , ht = ht
            , bodymass = M
            , h = 2.0
            , rewire_method = :ADBM
            , functional_response = :classical
            , consrate_adbm = :befwm 
            , e = p_adbm.e
            , a_adbm = p_adbm.a
            , ai = p_adbm.ai
            , aj = p_adbm.aj
            , b = p_adbm.b
            , h_adbm = p_adbm.h
            , n = p_adbm.n[1]
            , ni = p_adbm.ni
            , scale_bodymass = false
            #, adbm_trigger = :interval, adbm_interval = Δtadbm
        )
    else
        p = model_parameters(A
            , r = gr
            , x = mr
            , ar = ar
            , ht = ht
            , bodymass = M
            , h = 2.0
            , rewire_method = rewire_method
            , functional_response = :classical
            , scale_bodymass = false
            #, adbm_trigger = :interval, adbm_interval = Δtadbm
        )

    end
    return p
end