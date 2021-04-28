using Plots

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
