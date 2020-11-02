###################################################################################################################################################################
# Date - 6th October 2020
# Authors - Chris Griffiths and Eva Delmas
# Title - Using Julia in VS code #2
###################################################################################################################################################################
# This doc follows on from "Using Julia in VS code #1" and assumes that your still working from your directory
import Pkg
using Plots, DataFrames, Distributions, Random, EcologicalNetworks, BioEnergeticFoodWebs, DelimitedFiles, CSV # Reload packages if needed
Pkg.status() # Check packages and versions

# This doc covers the following:
# (1) Arrays and Matrices
# (2) DataFrames and CSVs
# (3) Functions
# (4) Loops
# (5) Plots
# (6) Scoping
# There is also a section at the end with some "Quick tips"

## (1) Arrays and Matrices
# (a) A one-dimensional array (list of ordered data with a shared type) can be specified using:
ar = [1,2,3,4,5] # square brackets act like c() in R
br = ["Pint", "of", "moonshine", "please"]
# You can then access the members of an array using indexing"
ar[1]
br[3]
# You can use some function to pre-allocate vectors wit a certain value
# Pre-allocating vector is very helpful to speed things up in Julia
emptyvec = zeros(10) #this create a vector of length 10 filled with 0. 
onesvec = ones(10) #can be done with ones
boolvec = trues(10) #or true/false (with falses(10))
# (b) You can also use built in commands to construct sequences of numbers (same as seq() or range() in R)
range_array = range(0, 10, length = 11) # sequence from 0-10 with length 11 
range_array2 = [0:1:10] #alternative
typeof(range_array) #note that this produces an object of type StepRange and note a vector
# you can turn it into a vector by "collecting" 
range_collected = collect(range_array)
range_collected2 = [0:1:10;] #Alternatively you can use the ';' as a last argument here to automatically collect
# Note that one of these method produces an array of Integers, the other of Floats
typeof(range_collected2)
convert(Array{Float64,1}, range_collected) # conversion from Integers to floats
# To apply a function over a vector (or matrix), use the "." operator:
exp_array = exp10.(range_array) # Here, the . maps the exp10 function to all elements of range_array - also known as 'Broadcasting'
# Both collect() and range() are useful when constructing a loop, as are the length() and unique() commands. Both length() and unique() operate the same way they do in R. 
# (c) You can bind elements to an array (useful when constructing a parameter matrix for BEFW simulations):
dr = append!(ar, 6:10)
# (d) You can also initialise an array that can contain any amount values using:
I_array = [] 
J_array = Float16[] #you can also pass the type you want to store
# You don't have to provide a nrow or size argument like you would you R. 
# It is also worth noting that this I_array object behaves very similar to list() in R and can handle many different forms - for example it can store matrices or text
# For example:
I_array_2 = []
for i in 1:1000 
    array_test = rand((1,2)) # pick the number 1 or 2 at random
    array_test_2 = rand(Int, 2) # Pick 2 integers at random
    push!(I_array, array_test) # Here the output array_test is being pushed and stored in the array I_array. Julia is smart enough to do this iteratively. 
    push!(I_array_2, array_test_2) # Here the a 2-element array is being pushed and stored in each slot of I_array_2 - this is useful when pre-constructing species by species networks using the niche model 
    # push! is a super useful tool! 
end
I_array
I_array_2
# Example using points c and d:
tab = []
for k in 1:4
    for j in 1:3
        for i in 1:2
            append!(tab,[[i,j,k]])
        end
    end
end
tab
# you can also use 'eachindex', 'eachcol', etc. or 'enumerate' to loop over objects: 
vec1 = ["a", "b"]
vec2 = [2:2:6;]
for i in eachindex(vec2)
    for (j,k) in enumerate(vec1)
        println("i = $i - j = $j iterates over vec2's indexes and k = $k over its values")
    end
end

# (e) Matrices are specified using:
mat = [1 2 3; 4 5 6] # The rows are seperated by ; and columns by spaces
# And can be indexed in the same way as above:
mat[1,2] # first row of the second column
mat[1:2, 3] # first two rows of the third column
mat[5] # if you provide 1 value, it reads the matrix rowise and then columnwise, columns have priority in operation in Julia, they represent vectors
# (f) N-dimensional Arrays - sometimes you might want an object with more than 2 dimensions
# This can achieved by creating an empty array (using the zeros command) and filling it either manually or using a loop:
table = zeros(2,3,4) # rows, columns and dimensions
# Fill with a loop:
for k in 1:4
    for j in 1:3
        for i in 1:2
            table[i,j,k] = i*j*k
        end
    end
end
table

## (2) DataFrames and CSVs
# (a) Dataframes rely on the DataFrames package and are initialised using:
dat = DataFrame(col1=[], col2=[], col3=[]) 
# You can also specify the type in each column if required:
dat1 = DataFrame(col1=Float64[], col2=Int64[], col3=Float64)
# (b) Writing to a dataframe is easy, you just use the push! command (as above)
for i in 1:10
    x = rand((1.0,6.5))
    y = rand((5,7))
    z = rand((3.0,33.0))
    push!(dat,[x,y,z])
end
# Look at your dataframe:
print(dat)
first(dat, 6) # First 6 rows
last(dat) # Last row
dat[2,:] # : means all columns
dat[:,3] # or all columns
# you can also use 'end' as an index: 
dat.col1[end-6:end] # this shows the last 7 elements of the col1 column
# Alternatively, you can select columns using :name:
dat[1:3, :col2] # useful when extracting parameters out of the BEFW model_parameters object
# (c) You can then write out as a CSV using:
CSV.write("my_data.csv", dat)
# (d) Or read in a CSV using 
dat_in = CSV.read("my_data.csv", DataFrame) # "path where your CSV is stored/File name.csv
# You can also write out and read in text files using the following commands:
writedlm(join(["testing_", dat[1,3], "_my_data.txt"]), tab, "\t") # join does what it says on the tin
dat_txt = readdlm("testing_3.0_my_data.txt") 
#Usually, it's best to use CSV for DataFrames and delimited files (txt, etc) for matrices

## (3) Functions 
# (a) Functions work exactly like they do in R however there are two fundamental differences: (a) There is no need for {} brackets and (b) scoping (we'll attempt to explain this below)
# A Function starts with the word function and ends with the word end. To store an output you use return.
function plus_two(x)
    return x + 2 # The body of the function will be automatically intended 
end
x = 1
z = plus_two(x)
# (b) Functions can also be written to take no arguments:
function pub_time()
    println("Surely it's time for Interval!")
    return
end
pub_time()
# (c) Positional arguments - unlike in R, input parameters have to be specified in a fixed order unless they have a default value which can be specified. For instance, we can build a function that measures body weight on different planets:
function bodyweight(BW_earth, g = 9.81)
    return BW_earth*g/9.81
end
# If you type bodyweight(60) and don't specify g, you get your body weight as measured on Earth (because g is fixed at a default value of 9.81):
bodyweight(80)
# Alternatively, you can change g and get your weight on another planet:
bodyweight(80, 3.72)
# Note - you also can't change the order of input parameters even if you specify the name of the parameter (like you can in R or Python). If you would rather use optional parameters with no fixed position, you need to use keyword parameters:
function key_word(a, b=2; c, d=2) # Here, b and d are fixed, a is positional and c is a keyword parameter
    return a + b + c + d
end
# Here, the addition of ; before c means that c is an optional parameter and can be specified in any order. However, you do have to specify it by name:
key_word(1, c=3) # You might get a blue wavy line under this line of code - you can get more details of the 'possible error' by hovering over the line and clicking Peak Problem or navigating to the 'PROBLEMS' tap in the terminal. Here, the error is not important but it might be a useful tool in the future.
key_word(1, 6, c=7)
key_word(1, 8, d=4) # ERROR: UndefKeywordError: keyword argument c not assigned - as c is a keyword parameter, it must always be specified. 

## (4) Loops
# (a) We've introduced for loops above - pretty much the same as R. Here's one last example:
persons = ["Alice", "Alice", "Bob", "Bob2", "Carl", "Dan"]
for person in unique(persons)
    println("Hello $person")
end
# (b) If and else loops, and the break command:
for i in 1:100
    if i>10
        break # breaks the loop when i surpasses 10
    else
        println(i^2)
    end
end
# (c) Continue command - opposite of break
for i in 1:30
    if i % 3 == 0
        continue # forces the loop to skip a given iteration - here the loop prints all the numbers from 1 to 30 but doesn't print any multiples of 3
    else println(i)
    end
end
# (d) While loops - allows a loop to continue until a certain condition is met
function while_test()
    i=0
    while(i<30)
        println(i) # prints i until i>=30
        i += 1
    end
end
while_test()

## (5) Plots
#=
In R you would probably use one of these two options: base plots or ggplot2
If you're more of a base plots person, you'll probably feel more comfortable with the Plots plackage, 
alternatively, if you prefer ggplot2, the Gadfly package is the closest thing you can find. 

As Julia is based on a 'Just In Time' compiler (or JIT) the first time you call a function 
it needs to compile, and takes a longer time than expected. This is especially true for plots. 
The first plot you make will take some time, but it gets faster after that.
=#

# (a) Make a basic plot - there are a lot of example of the documentation that can help you (https://docs.juliaplots.org/latest/tutorial/):
x = 1:100
y = rand(100)
plot(x,y,label="bla", title = "Rubbish plot", lw = 3) # Will open a plot in a new tab
# (b) Mutating a plot:
z = rand(100)
plot!(x,z,label="bla2") # You can add a second line to the plot by mutating the plot object - using !
xlabel!("x") # adds an x axis label
ylabel!("random") # adds a y axis label
# (c) Changing the plotting series
plot(x,y, title = "Rubbish scatter plot", seriestype = :scatter, label = "y") # seriestype allows you to change up the type of plot
# Alternatively, for each built-in series type, there is a shorthand version:
scatter(x, z, title = "Rubbish scatter plot 2", label = "z")
#You can call different "series types" : 
plot(x,y,label="bla", title = "Rubbish plot", lw = 3) # Will open a plot in a new tab
plot!(z, seriestype = [:line :scatter], lc = :orange, mc = :black, msc = :orange, label = "bla2", markershape = :diamond)
# (d) Outputing/saving a plot
#the savefig function saves the last plot created
plot(x,y,label="bla", title = "Rubbish plot", lw = 3) 
savefig("plot.png") # saves a plot using the file type detailed in the extension
# or you can use a shorthand version (works for png, svg and PDF)
p1 = scatter(x, z, title = "Rubbish scatter plot 2", label = "z")
png(p1,"plot2") 
#now if you look at the list of varaibles created (click on the 3 dots on the left side of your screen - the Julia explorer)
#you can see the p1 plot, and you can click on it to make it reappear after you have closed the plotting window
# The different series types and keyword arguments are listed here https://docs.juliaplots.org/latest/generated/supported/#supported
# Julia can also make the most of different applications e.g. Plotly and GR - see here for further details https://docs.juliaplots.org/latest/tutorial/
# Full disclaimer - I (Chris) don't plot in Julia, I run simulations in Julia and revert back R and ggplot for data analysis, data manipulation and visualisation
# For more plot recipes (histograms, violin plots, etc.) see also StatsPlots: https://github.com/JuliaPlots/StatsPlots.jl

#=
Now we can try to do the same using Gadfly
Gadfly can be useful to work with data frames
See the docs here: http://gadflyjl.org/stable/index.html
=#

using RDatasets, Gadfly
# Let's start by querying a dataset: 
crabs = dataset("MASS", "crabs") #https://stat.ethz.ch/R-manual/R-devel/library/MASS/html/crabs.html
# What's in this dataset?
describe(crabs) #this gives a quick description of the data frame content
# Now we can try plotting crabs carapace lengths by body depths: 
# NB: Here we explicitly call Gadfly because plot is also exported by Plots, if you ha
Gadfly.plot(crabs, x = :CL, y = :FL)
#we can color by crab 'species' B is for blue crabs and O for orange
Gadfly.plot(
    crabs, x = :CL, y = :FL
    , color = :Sp
    , Guide.xlabel("Carapace length (mm)")
    , Guide.ylabel("Frontal lobe size (mm)")
    , Guide.colorkey(title="Species")
    , Scale.color_discrete_manual("blue", "orange")
    ) 

## (6) Scoping (pain in the arse)
# Scoping refers to accessibility of a variable in the code i.e. the scope of a variable is the region of code where a variable is known and accessible. 
# A variable may be in a global scope or a local scope
# (a) Global - A variable in the global scope is accessible everywhere and can be modfied by any part of your code. When you define a variable in the REPL or outside of a function or loop you create a global variable:
A = zeros(1:10)
# you can force a variable to be global by using the global macro: 
global B = 7
# (b) Local - A variable in the local scope is only accessible in that scope and in other scopes eventually defined inside it. When you define a variable in a function/loop that isn't returned you create a local variable:
for i in 1:10
    local_a = 2 # local_a is only accessible within the loop
    A[i] = local_a*i # A is global and is accessible everywhere
end
local_a # gives an error - ERROR: UndefVarError: local_a not defined
A

#if you want to modify a global variable with a loop, you need to use the global macro: 
global j = 1
for i in 1:1:5
    global j = j+1
end
j

## Quick tips
# In the REPL, you can use the direction up arrow to scroll through past code
# you can even filter by typing the first letter of a line previously executed in the REPL and then using the arrow to see it, e.g. type plo and then use the up arrow, you should see the last plot command you used 
# Toggle word wrap via View>Toggle Word Wrap or alt-Z
# As in R, you can get help by typing ? and then subject matter in the REPL - for example, try ?model_parameter
# Red wavy line under code - error in code 
# As in R, indexing is ordered by row and then by column
# Julia gets a bit funny about indenting - when writing a loop or a function, make sure the code enclosed in the loop or function is indented. VS code typically does this for you. 
# You can view your current variables (similar to the top right hand panel in RStudio) by clickling on the 'Julia explorer: Julia workspace' symbol in the activity bar (final/5th symbol). You can then look at them in more detail by clicking the sideways arrow. 
# Julia has strange aspect where if a=b, a change in b will automatically cause a change in a. For example:
a = [1,2,3]
b = a
print(b)
b[2] = 41
print(a)
# This is useful as it lets Julia save memory, however, it is not ideal. As a result, we might instead want c to be an independent copy of a:
c = deepcopy(a) 
c[3] = 101
print(c)
print(a)
# You can view a .csv or .txt file by clicking on a file name in the directory (left) - opens a viewing window. CSV's also have a 'Preview' option - right click>Open Preview

