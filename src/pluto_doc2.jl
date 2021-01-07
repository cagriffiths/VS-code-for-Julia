### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ e9598c62-4ed3-11eb-1e5d-b94608ebba88
using Plots, DataFrames, Distributions, Random, DelimitedFiles, RDatasets, Gadfly, CSV

# ╔═╡ ca066c34-4eb5-11eb-0100-b9e31a7c206a
md"# Basic Julia commands

*by Chris Griffiths, Eva Delmas and Andrew Beckerman, Dec. 2020.*"

# ╔═╡ 00b46e28-4ed3-11eb-0e21-438510d77100
md"""
This document follows on from "Getting started" and assumes that you're still working in your active project. 

This document covers the following:
- Arrays and Matrices
- DataFrames and CSVs
- Functions
- Loops
- Plots
- Scoping
There is also a section at the end with some "Quick tips". 
"""

# ╔═╡ cc6b8f9a-4ed3-11eb-1585-a54395c39dab
md"## Load packages

You'll need a few packages for this tutorial:
"

# ╔═╡ fb80c0ea-4ed3-11eb-370b-53a2b1e6f267
# Random.seed - important for consistency. Sets the starting number used to generate a sequence of random numbers - ensures that you get the same result if you start with that same seed each time you run the same process. 
Random.seed!(33)

# ╔═╡ fcd90288-4ed3-11eb-394e-672d687ce0b1
md"""
All of these packages are listed in the tutorial's `Manifest.toml` and `Project.toml` files, if you're having problems, head back to the script at the bottom of "Using Julia in VS Code #1" and rerun. If you're unsure, remember to use the status command `] st` to check what packages are currently active in your project. 

Before we move on, one helpful thing to note are the help files and how to access them. As in R, the help files assiocated with a given package, function or command can be accessed using `?` followed by the function name (e.g. type `? pi` in the REPL). Similar to when you entered Julia's package manager (using `]`) you'll notice that the `?` command causes a change in the REPL with `help?>` replacing `julia>`, this informs you that you've entered the help mode. As an exercise, use the help mode to find the difference between `print` and `println`.
"""

# ╔═╡ 09474d84-4ed4-11eb-0a59-07e43bd38bc2
md"""
## Preamble
Before we start creating arrays and matrices, we'd like to demonstrate how you allocate numbers and strings to objects in Julia and check an object's type. We'd also like to highlight some simple mathematical operations. 

### Allocating objects
Allocating in Julia is useful as it means that variables can be stored and used elsewhere. You allocate numbers to objects using the following:

"""

# ╔═╡ 12c044e2-4ed4-11eb-03a3-c552dd5ff647
# allocate an Integer:
nu = 5

# ╔═╡ 2255e6fa-4ed4-11eb-3f88-131a0aa28bf9
# allocate a Floating point number:
pi_sum = 3.1415

# ╔═╡ 2de8d950-4ed4-11eb-139d-1ff1bf7d473f
# pi can also be called using pi or π (type \pi and tab to transform into the unicode symbol)
pi_sum2 = pi

# ╔═╡ 4498f5ae-4ed4-11eb-3e49-bdca153c4af0
pi_sum3 = π

# ╔═╡ 4a2e609e-4ed4-11eb-3a60-4187543a7e01
# you can also use unicode symbols directly in Julia, this can be useful for naming parameters following standards: 
λ = 4

# ╔═╡ 4fa7c9a2-4ed4-11eb-3294-192f0d3080ac
# and you can attribute multiple variables at the same time, useful when outputing from a function: 
αi, βi, γi = 1.3, 2.1, exp(39)

# ╔═╡ 531f3304-4ed4-11eb-14cb-e38f96153f66
αi

# ╔═╡ 5447e2f6-4ed4-11eb-083c-67fbd626c7ba
md"""
### Strings
You can also allocate strings (text) to objects:
"""

# ╔═╡ 5cd5ce62-4ed4-11eb-09ce-3d5299f2edb3
aps = "Animal and Plant Sciences" # must use "" and not ''

# ╔═╡ 626db3d0-4ed4-11eb-0f67-1d03634bfac7
tp, tp2 = typeof(pi_sum), typeof(pi_sum2)

# ╔═╡ 6668fcc4-4ed4-11eb-3524-8905522a7c19
println("While pi_sum is a $tp" * ", pi_sum2 is an $tp2")

# ╔═╡ 9fd4ada2-4ed4-11eb-2faa-6f6da9a455e9
# you can also print an object (useful when running simulations) using:
print(aps) # prints in the same line

# ╔═╡ a5e1c282-4ed4-11eb-0c87-81a97d416161
println(aps) # prints on the next line (useful for printing in loops, etc)

# ╔═╡ abc54e12-4ed4-11eb-0db3-1d74c9d88d65
md"""
### Checking object types
As in R, Julia has a range of object types depending on the type of variable being stored:
"""

# ╔═╡ b66175da-4ed4-11eb-1453-df631402d6ed
# to check the type of any object use:
typeof(nu)

# ╔═╡ bd58f630-4ed4-11eb-0201-6db324add33c
md"Note - Julia is like R and Python, it can infer the type of object (Integer, Float, etc) on the left hand side of the equals sign, you don't have to justify it like you do in C. However, you can if needed e.g."

# ╔═╡ d7d77a8e-4ed4-11eb-2c79-f58ad22e8e5d
pi_sum1 = Float64(3.141592)

# ╔═╡ ddd93238-4ed4-11eb-1ce1-338db5b20cb4
# you can then check the object type using:
typeof(pi_sum), typeof(pi_sum2) # note here that by using the preallocated variable pi, you are actually using an object of type Irrational (a specific type of Float)

# ╔═╡ e5e82af6-4ed4-11eb-013e-8b521851fbae
md"""
### Converting
It might also be useful to convert the type of an object from one type to another (when possible). This is done using the `convert` function. 
"""

# ╔═╡ f07a815a-4ed4-11eb-38e2-03d0037bdef5
# allocate an Integer:
a = 2 

# ╔═╡ f3f32b00-4ed4-11eb-0e5c-7fb8069cdadd
# convert to a Float:
b = convert(Float64, a)

# ╔═╡ fa595adc-4ed4-11eb-2155-754e431a8269
# or:
b2 = Float64(a) 

# ╔═╡ 058b854c-4ed5-11eb-1c2d-09f617781b7a
md"### Simple mathematical operations"

# ╔═╡ 13326490-4ed5-11eb-06f9-b1d90c5e0dee
c = 2

# ╔═╡ 17b0539c-4ed5-11eb-054f-a748fb450869
d = 3

# ╔═╡ 1b157a26-4ed5-11eb-38c6-6d7df3ca082f
# plus:
sumcd = c + d

# ╔═╡ 1e7e50de-4ed5-11eb-11af-eb1a5d4fa201
# minus:
diffcd = c - d

# ╔═╡ 223c912c-4ed5-11eb-111f-b18edb8a8d0f
# multiplication:
productcd = c * d

# ╔═╡ 25b18c7c-4ed5-11eb-363e-0152fb15f9e3
# division:
divcd = c / d

# ╔═╡ 28b8b7e2-4ed5-11eb-2e17-99888ea9f715
# exponent:
powcd = c^2

# ╔═╡ 2cf9902e-4ed5-11eb-3938-a3618865f350
md"For a complete list of all mathematical operations see [the Julia manual](https://docs.julialang.org/en/v1/manual/mathematical-operations/index.html).
"

# ╔═╡ 362fe602-4ed5-11eb-042e-e7a8330ee7f1
md"## Arrays
Once you've mastered simple allocation, the next step is to create and store objects in arrays:
"

# ╔═╡ 43838ebc-4ed5-11eb-2ef8-fd5c2f2c6a32
# a one-dimensional array (or vector, a list of ordered data with a shared type) can be created using:
ar = [1,2,3,4,5] # square brackets act like c() in R

# ╔═╡ 489dfc66-4ed5-11eb-17ee-dd5970ad26c6
# or:
br = ["Pint", "of", "moonshine", "please"]

# ╔═╡ 4b9c9454-4ed5-11eb-0b00-37948aec595e
md"### Indexing
You can then access the different elements of an array by indexing: 
"

# ╔═╡ 52c63320-4ed5-11eb-0f1b-63f41d328e7b
# first position:
ar[1]

# ╔═╡ 559025de-4ed5-11eb-3730-c759efb8bec4
# third position:
br[3]

# ╔═╡ 59e357d2-4ed5-11eb-37d0-1fc1081ebb88
# second and fourth postion:
ar[[2,4]]

# ╔═╡ 5dd3b58a-4ed5-11eb-132d-49120926de15
# third and fourth position:
br[3:4]

# ╔═╡ 627ff148-4ed5-11eb-07dd-7d82d0d4a423
md"### Pre-allocation
You can also use some of the built in functions to pre-allocate vectors with a certain value. Pre-allocating vectors with the right dimension and type helps to speed things up in Julia:
"

# ╔═╡ 7425d48c-4ed5-11eb-1209-c391a15b6136
# create a vector of length 10 filled with 0's:
emptyvec = zeros(10)  

# ╔═╡ 7b4f4872-4ed5-11eb-294b-a79cc798d67f
# can also be done with ones:
onesvec = ones(10)

# ╔═╡ 7e8ae1a4-4ed5-11eb-1dce-dd19cf048667
# or boolean values (TRUE or FALSE):
boolvec1 = falses(10)

# ╔═╡ 8111e134-4ed5-11eb-27a8-0f16a5031f34
boolvec2 = trues(10)

# ╔═╡ 840e1588-4ed5-11eb-35a1-cb1441dbdcab
md"""
### Empty arrays
You can also initialise an empty array that can contain any amount of values:
"""

# ╔═╡ 8aef9066-4ed5-11eb-26bf-bd1f40f803cb
# empty array of any type:
I_array = [] 

# ╔═╡ 8ecebedc-4ed5-11eb-22c7-8df16247f704
# you can also justify the type if needed:
J_array = Float16[]

# ╔═╡ 929584a6-4ed5-11eb-1863-5be0ecc9cadc
md"What's nice about Julia is that you don't have to provide an nrow or size argument like you would in R. This comes in very handy when looping and allocating.  It is also worth noting that the I_array object you've just created behaves very similar to a `list()` in R and can handle many different data forms - for example, it can used to store n dimensional matrices or text. 
"

# ╔═╡ 9a147c82-4ed5-11eb-3232-d38aa3bf64c1
# sequence from 0-10 with length 11:
range_array = range(0, 10, length = 11) 

# ╔═╡ 9e0fb8b0-4ed5-11eb-157c-6f6666db78e5
# alternative:
range_array2 = [0:1:10]

# ╔═╡ 07c1f304-4ed6-11eb-18f7-bf1d4a5d6317
typeof(range_array) # note that this produces an object of type StepRange and not a vector

# ╔═╡ 0c22754a-4ed6-11eb-39c8-9de32eb01c17
# you can turn range_array2 into a vector by "collecting": 
range_collected = collect(range_array)

# ╔═╡ 12f07ca0-4ed6-11eb-1cf1-3150bd2167b5
# or you can use the ';' as a last argument in the [] to automatically collect:
range_collected2 = [0:1:10;]

# ╔═╡ 153a680e-4ed6-11eb-040d-2da830d34767
# note that one of these methods produces an array of type Integer, the other of type Float:
typeof(range_collected2)

# ╔═╡ 18405e14-4ed6-11eb-19ed-a9c287a4c2f2
# you can also convert the type of an array:
convert(Array{Float64,1}, range_collected2) # conversion from Int to Float

# ╔═╡ 1b27583a-4ed6-11eb-31ef-bd2025d2c2a8
md"Both the `collect()` and `range()` are useful when setting up an experiment or looping over a variable of interest, as are the `length()` and `unique()` commands. Both `length()` and `unique()` operate the same way they do in R.
"

# ╔═╡ 25cb1c0e-4ed6-11eb-3ab8-19f3d2437ee0
md"
### Broadcasting
To apply a built in function to all elements of a vector (or matrix), use the `.` operator. This is called broadcasting:

"

# ╔═╡ 31c1d00a-4ed6-11eb-35e8-d731257d1f94
# map the exp10 function to all elements of range_array:
exp_array = exp10.(range_array)

# ╔═╡ 375fe878-4ed6-11eb-1461-71dec97c90f6
# map the log function:
log_array = log.(range_array)

# ╔═╡ 46d0a3e2-4ed6-11eb-1537-51f40c607203
md"
### Appending

You can also bind new elements to an array using the `append!` command:
"

# ╔═╡ 53a6a4f4-4ed6-11eb-131a-87870659cf62
# appending:
dr = append!(ar, 6:10) 

# ╔═╡ 5a61030c-4ed6-11eb-30f1-6d36d11ab24b
md"""
## Matrices
Matrices are created in a very similar way to arrays. In fact, it is easy to think of matrices as multi-dimensional arrays:

"""

# ╔═╡ 6259852a-4ed6-11eb-13cc-59b3ade439be
# create a two-dimensional matrix:
mat = [1 2 3; 4 5 6] # rows are seperated by ; and columns by spaces

# ╔═╡ 687f598e-4ed6-11eb-2623-b7865d01dfc0
# create a three-dimensional matrix filled with 0's:
mat2 = zeros(2,3,4) # number of rows, columns and dimensions

# ╔═╡ 688505a0-4ed6-11eb-2054-75438854e56d
md"
Elements of a matrix can also be accessed by indexing. As in R, rows are indexed first and columns second [row, column]:
`"

# ╔═╡ 689593c0-4ed6-11eb-2b6b-05425ef7a8cd
# first row of the second column:
mat[1,2]

# ╔═╡ 68a6d3a6-4ed6-11eb-264d-9d3bb38f94ef
# first two rows of the third column:
mat[1:2,3]

# ╔═╡ 68b97d8a-4ed6-11eb-083e-75cc11fbb2a8
# if you provide 1 value:
mat[5] # it reads the matrix row-wise and then column-wise (hence mat[5] = 3 and not 5)

# ╔═╡ 6781a78a-4ed6-11eb-1e83-510e7be00459
md"""
## DataFrames and CSVs
Dataframes and CSVs are also easy to use in Julia and can help when storing, inputting and outputting data in a ready to use format. 

### Creating a dataframe
To initialise a dataframe you use the `DataFrame` function from the `DataFrames` package:

"""

# ╔═╡ 8768a652-4ed6-11eb-1f63-17c25554bc88
# create a dataframe with three columns
dat = DataFrame(col1=[], col2=[], col3=[]) # as in section 1.7, we use [] to specify an empty column of any type and size

# ╔═╡ 8e10b7f6-4ed6-11eb-09b0-4d4815d99155
# you can also specify column type using:
dat1 = DataFrame(col1=Float64[], col2=Int64[], col3=Float64)

# ╔═╡ 8e11fd14-4ed6-11eb-2e93-9936795dc0ca
# and provide informative column titles using:
dat2 = DataFrame(species=[], size=[], rate=[])

# ╔═╡ 9a43c252-4ed6-11eb-0e57-9dc066e8a1a2
md"""
### Allocating to a dataframe
Once you've created a dataframe, you can allocate to it easily using the `push!` command:
"""

# ╔═╡ a11829d8-4ed6-11eb-3dd3-2f23d2d0dfb8
# allocation using push! command:
x = rand((3.5, 33.0))

# ╔═╡ a6b61166-4ed6-11eb-01f0-955c156d14fc
y = rand((1,7))

# ╔═╡ a6b73e92-4ed6-11eb-0b43-9b2a2b300057
z = rand((100.0, 700.00))

# ╔═╡ a6c8e390-4ed6-11eb-2bac-c3fbd07ac74a
push!(dat, [x,y,z])

# ╔═╡ a6dc3bde-4ed6-11eb-1c75-2989b7adb7eb
# or 
species = "Atlantic cod"

# ╔═╡ a6ed7228-4ed6-11eb-370f-c7aa3f41f879
size = 86

# ╔═╡ a6ff7016-4ed6-11eb-28a9-fb7d764aa4c6
rate = 3.0

# ╔═╡ a7115030-4ed6-11eb-0fcb-7b1b2fb5ea06
push!(dat2, [species, size, rate])

# ╔═╡ a5c3313a-4ed6-11eb-20ee-e735e7ba92a0
md"### Exploring a dataframe"

# ╔═╡ b5e6047a-4ed6-11eb-2a56-17b75c5091a8
# add a second row to dat
x2 = rand((55.6, 77.1))

# ╔═╡ bf5a8c38-4ed6-11eb-2763-3f048a611cce
y2 = rand((9,11))

# ╔═╡ bf5c26b0-4ed6-11eb-244e-7d68ed2ffb55
z2 = rand((10.0, 80.00))

# ╔═╡ bf6dcb9a-4ed6-11eb-2135-918cfb78b9b3
push!(dat, [x,y,z])

# ╔═╡ bf7ef97e-4ed6-11eb-384f-cb1767c18946
# look at a dataframe:
print(dat2)

# ╔═╡ bf902b5e-4ed6-11eb-12ad-71cb85696690
# first row:
first(dat,1)

# ╔═╡ bfa18840-4ed6-11eb-115a-f393a5fe45ba
# last row:
last(dat)

# ╔═╡ bfb2f0b4-4ed6-11eb-2220-d7f2df285199
# you can also view or extract all rows or all columns using:
dat[1,:] # : all columns

# ╔═╡ bfc49670-4ed6-11eb-03f7-c92156c63514
dat[:,1] # : all rows

# ╔═╡ bfd5ee96-4ed6-11eb-3638-6b4bed3c63db
# alternatively, you can select columns using their names:
dat2[:species]

# ╔═╡ bdcb817e-4ed6-11eb-2cc2-331edb5aae22
md"""
### CSV files

Dataframes can be written out (stored/saved) into your active project directory as .csv files using the `CSV` package:
"""

# ╔═╡ d1d274ca-4ed6-11eb-0a11-6d334548f77a
# write out a CSV:
CSV.write("myfishdata.csv", dat2)

# ╔═╡ d867329e-4ed6-11eb-0739-4dada7e2f3dc
# read in a CSV:
dat_in = CSV.read("myfishdata.csv", DataFrame)

# ╔═╡ d8695718-4ed6-11eb-2728-07d16a440e76
# alternatively, files can be exported as text files:
writedlm(join(["testing_", dat2[1,1], "_rates.txt"]), mat, "\t") # join does what it says on the tin - it joins variables into a single string

# ╔═╡ d87ba9fe-4ed6-11eb-1872-57f5931c928f
# or imported as text files:
dat_txt = readdlm(join(["testing_", dat2[1,1], "_rates.txt"]))

# ╔═╡ d88efdec-4ed6-11eb-01ce-a50f7f9e6c6e
md"Usually, we tend to use CSV's for dataframes and delimited files for matrices but there is no hard and fast rule.

We also recommend naming your files as something memorable and informative. When you're running a experiment and outputing thousands of files, a future you will thank you for naming your files with care. If outputing many files, we would also recommend creating seperate folders for your output files. Folders are easier to read back into Julia or R and no one likes a cluttered project directory. "

# ╔═╡ d78a2264-4ed6-11eb-252a-814789e778d2
md"""
# Functions
Functions work exactly like they do in R, however, there are three fundamental differences:
- there is no need for `{}` brackets (thank god)
- indenting (Julia requires seperate parts of a function to be indented - don't worry, VS Code should do this for you)
- scoping (we'll attempt to explain this later)

Functions start with the word `function` and end with the word `end`. To store something that is calculated in a function, you use the `return` command. 
"""

# ╔═╡ 768349ea-4ed7-11eb-1b9b-2ff91e39460e
# simple function:
function plus_two(x)
    return x + 2
end

# ╔═╡ 91dc1438-4ed7-11eb-357a-e358200dee3a
# input variable:
x3 = 17

# ╔═╡ 91dda1c2-4ed7-11eb-3a53-7b126c8c99e6
# run functions:
z3 = plus_two(x)

# ╔═╡ 91efdebe-4ed7-11eb-1918-433e8e3112f3
# functions can also be witten to take no inputs:
function pub_time()
    println("Surely it's time for Interval")
    return
end

# ╔═╡ 92022338-4ed7-11eb-0965-dd858836e038
pub_time()

# ╔═╡ 90e56af2-4ed7-11eb-1836-0ba5da4b3799
md"""
### Positional arguments
Unlike in R, input variables for functions have to be specified in a fixed order unless they have a default value which is explictly specified. For instance, we can build a function that measures body weight on different planets:
"""

# ╔═╡ 9f09e8c4-4ed7-11eb-3df7-b91b7decd4c0
# weight function:
function bodyweight(BW_earth, g = 9.81)
    return BW_earth*g/9.81
end

# ╔═╡ a6dd5c16-4ed7-11eb-3974-67e79c8c6b8d
# if you execute:
bodyweight(80)

# ╔═╡ a5b34a80-4ed7-11eb-36be-5bdd564ce47c
md"And get your weight on another planet"

# ╔═╡ a6dfca2a-4ed7-11eb-3f50-6d4e4b63c5e2
# and don't specify g, you get body weight as measured on Earth (because g is fixed at a default value of 9.81)
# alternatively, you can change g
bodyweight(80, 3.72)

# ╔═╡ b9a0dcce-4ed7-11eb-0164-31afe37e67d0
md"""
### Keyword arguments
In Julia, you can't change the order of input variables for a function or circumvent the problem by specifing the name of an input variable (like you can in R or Python). To overcome this, you can use keyword arguments which have no fixed position:
"""

# ╔═╡ c4dc8c00-4ed7-11eb-18d6-7b23fd5cc6e6
# function with keyword arguments:
function key_word(a, b=2; c, d=2) # here, b and d are fixed, a is positional and c is a keyword argument
    return a + b + c + d
end

# ╔═╡ d63e6b62-4ed7-11eb-3157-67230869ddec
# the addition of ; before c means that c is an keyword argument and can be specified in any order
# however, you do have to specify it by name:
key_word(1, c=3)

# ╔═╡ d640e676-4ed7-11eb-151a-e72f6305087e
# or:
key_word(1, 6, c=7)

# ╔═╡ d653bd08-4ed7-11eb-1ab4-8daea5084b6b
# if you don't provide a c argument, Julia will return an error:
key_word(1, 8, d=4)

# ╔═╡ d667f0ea-4ed7-11eb-1635-7fa63407507e
md"keyword arguments must always be specified"

# ╔═╡ c162c9cc-4ed7-11eb-18ef-4fd0e8c909ae
md"""
## Loops 
Loops are useful tools in any programming language. Loops allow you to iterate over elements of a vector or matrix and calculate things of interest.

### For loops
For loops work by iterating over a specified range (e.g. 1-10) at specified intervals (e.g. 1,2,3...). For instance, we might use a for loop to fill an array: 

"""

# ╔═╡ f786dc5a-4ed7-11eb-3795-41591dce8cee
# create some arrays:
I_array2 = []

# ╔═╡ fef269c8-4ed7-11eb-1c6b-cb31a00302c7
tab = []

# ╔═╡ fef566f0-4ed7-11eb-0d85-b3568c5ff36c
# for loop to fill an array:
for i in 1:1000
    for_test = rand((1,2)) # pick from the number 1 or 2 at random 
    push!(I_array2, for_test) # push! and store for_test in I_array2 - Julia is smart enough to do this iteratively, you don't neccessarily have to indexed by `[i]` like you might do in R
end

# ╔═╡ ff07ec26-4ed7-11eb-0f44-d3a815231119
I_array2

# ╔═╡ ff1b85d8-4ed7-11eb-284b-cf9960c38c9f
# nested for loop to fill an array:
for k in 1:4
    for j in 1:3
        for i in 1:2
            append!(tab,[[i,j,k]]) # here we've use append! to allocate iteratively to the array as opposed to using push! - both work. 
        end
    end
end

# ╔═╡ ff342390-4ed7-11eb-1893-bf76669aa189
tab

# ╔═╡ ff48c8b8-4ed7-11eb-3aa4-096d1a8550d3
# you can also use for loops to allocate to a matrix:
table = zeros(2,3,4) # [2,3,4] matrix

# ╔═╡ ff5e8d88-4ed7-11eb-3ec6-cd69c74e33db
for k in 1:4
    for j in 1:3
        for i in 1:2
            table[i,j,k] = i*j*k # allocate i to rows, j to columns and k to dimensions
        end
    end
end

# ╔═╡ ff786c44-4ed7-11eb-3d46-7dcf1fd6fe4c
table

# ╔═╡ ff8daaf0-4ed7-11eb-2bb6-33cad9305363
# or play around with strings:
persons = ["Alice", "Alice", "Bob", "Bob2", "Carl", "Dan"]

# ╔═╡ ffa19e5c-4ed7-11eb-2108-7d276f219292
for person in unique(persons)
    println("Hello $person")
end

# ╔═╡ fdecca50-4ed7-11eb-1dff-edb237ec9d49
md"There are tons of different functions that can be helpful when building loops. Take a few minutes to look into `eachindex`, `eachcol`, `eachrow` and `enumerate`. They all provide slightly different ways of telling Julia how you want to loop over a problem. Also, remember that loops aren't just for allocation, they can also be very useful when doing calculations. 
"

# ╔═╡ 0bf354ac-4ed8-11eb-06b4-29e0464966dc
md"""
### If, else and break
When building a loop, it is often meaningful to stop or modify the looping process when a certain condition is met. For example, we can use the `break`, `if` and `else` statements to stop a for loop when `i` exceeds 10:
"""

# ╔═╡ 151e333a-4ed8-11eb-3676-7b2b7408e552
# if and break:
for i in 1:100
    println(i) # print i
    if i >10
        break # stop the loop with i >10
    end   
end

# ╔═╡ 1a127590-4ed8-11eb-0c19-0d9cd0684c67
# this loop can be modified using an if-else statement:
for j in 1:100
    println(j) # print i
    if j >10
        break # stop the loop with i >10
    else
        println(j^3)
    end
end

# ╔═╡ 19184552-4ed8-11eb-2741-e15dbb3ec9fa
md"You'll notice that every statement requires it's own start and `end` points, and is indented as per Julia's requirements. `if` and `else` statements can be very useful when building experiments, for example we might want to stop simulating a network `if` more than 50% of the species have gone extinct."


# ╔═╡ 28cc8288-4ed8-11eb-2b22-8d0b239404b8
md"""
### Continue
The `continue` command is the opposite to `break` and can be useful when you want to skip an iteration but not stop the loop:
"""

# ╔═╡ 2ebab296-4ed8-11eb-150e-dbf2fafcc53b
for i in 1:30
    if i % 3 == 0
        continue # makes the loop skip iterations that are a multiple of 3
    else println(i)
    end
end

# ╔═╡ 32d348e8-4ed8-11eb-3d75-c5e357111223
md"""
### While
`While` loops provide an alternative to `for` loops and allow you to iterate until a certain condition is met:
"""

# ╔═╡ 3fb8f698-4ed8-11eb-3f5b-9f5fda6445ee
begin #this is not needed in the REPL/VScode/Atom et al
	global i=0 # set a counter in the global scope
	while(i<30) # justify a condition
    	println(i) # prints i until i < 30
    	global i += 1 # count
	end
end

# ╔═╡ 9a6eaaba-4ed8-11eb-3589-213a28527443
md"""
While loops don't require you to specify a looping sequence (e.g. `i in 1:100`). This can be very useful because sometimes you simply don't know how many iterations you might need.

## Plots 
In R, the plotting of data is either done in base R or via the `ggplot2` package. If you're a base R person, you'll probably feel more comfortable with the `Plots` package. Alternatively, if you prefer `ggplot2`, the `Gadfly` package is the closest thing you'll find in Julia. We'll introduce both in the following sections. 

It is worth noting that Julia is based on a 'Just in Time' compiler (or JIT) so the first time you call a function it needs to compile, and can take longer than expected. This is especially true when rendering a plot. Consequently, the first plot you make might take some time but it gets significantly faster after that. 

### Plots 
Making a basic plot is pretty straightforward in Julia:
"""

# ╔═╡ b111565a-4ed8-11eb-1d0f-5fcf0b4f02c5
# basic plot:
x4 = 1:100

# ╔═╡ b6aa1ae8-4ed8-11eb-3948-436ffcb2a4b7
y4 = rand(100)

# ╔═╡ b6ade206-4ed8-11eb-2994-d784c0d2e507
# the plot will open in a new tab:
Plots.plot(collect(x4),y4,label="bla", title = "Rubbish plot", lw = 3)

# ╔═╡ b5c3c8a4-4ed8-11eb-35cd-1f0630bbef26
md"""
The `Plots.plot()` statement tells Julia that you want to use the `plot` function within the `Plots` package. We're using it here as the `Gadfly` package is also active and has it's own `plot` function.

To mutate a plot use `!`:
"""

# ╔═╡ 3e959ffc-4ed8-11eb-1c87-272963fe31da
z4 = rand(100)

# ╔═╡ ee7132ae-4ed8-11eb-2b39-cd1dddd0770b
# add a second line to your plot:
plot!(x4,z4,label="bla2")

# ╔═╡ ee76a64e-4ed8-11eb-3827-fffd9aa53158
# adds an x-axis label:
xlabel!("x")

# ╔═╡ ee8cd0a4-4ed8-11eb-0451-11379e47d9c6
# and y-axis label:
ylabel!("random")

# ╔═╡ ed895f94-4ed8-11eb-3f37-adffab630902
md"""
You can change the plot type using the `seriestype` argument or by using a built in plot macro (e.g. `scatter`):
"""

# ╔═╡ 1613f472-4ed9-11eb-0c1c-2505e46f8e75
# seriestype:
Plots.plot(x4,y4, title = "Rubbish scatter plot", seriestype = :scatter, label = "y")

# ╔═╡ 1ee6b0d0-4ed9-11eb-2488-d3cb62797c04
# or:
Plots.plot(x4,y4,label="bla", title = "Rubbish plot", lw = 3) # new plot

# ╔═╡ 1eea3a48-4ed9-11eb-206f-0b5bcf2d0852
plot!(z4, seriestype = [:line :scatter], lc = :orange, mc = :black, msc = :orange, label = "bla2", markershape = :diamond)

# ╔═╡ 1efe03fe-4ed9-11eb-0f41-d1800e2f339a
# scatter macro:
scatter(x4, z4, title = "Rubbish scatter plot 2", label = "z")

# ╔═╡ 363d76ce-4ed9-11eb-1548-71572c9631f3
md"""
`mc` is for marker colour and `lc`for line color.

Plots can be saved and outputted using `savefig` or by using an output marco (e.g. `png`)
"""

# ╔═╡ 5786cbf0-4ed9-11eb-15e9-8158397b3944
Plots.plot(x4,y4,label="bla", title = "Rubbish plot", lw = 3)

# ╔═╡ 5a03c5ea-4ed9-11eb-1068-d96a3ffbe749
# savefig saves the most recent plot:
savefig("plot.png")

# ╔═╡ 5a079120-4ed9-11eb-0ec4-71ca57a74a04
# here the file type is explicitly stated
# you could also the macro:
p1 = scatter(x4, z4, title = "Rubbish scatter plot 2", label = "z")

# ╔═╡ 5a1fbae8-4ed9-11eb-1fa1-05766d97901c
png(p1,"plot2")

# ╔═╡ 6af780da-4ed9-11eb-2ea1-e5e2e6fed2f4
md"""
Once you've created a plot it can be viewed or reopened in VS Code by navigating to the `Julia explorer: Julia workspace` symbol in the activity bar (three circles) and clicking on the plot object. We advise that you always name and assign your plots (e.g. p1, p2, etc). The `Plots` package also has it's own [tutorial](https://docs.juliaplots.org/latest/tutorial/) for plotting in Julia.

### Gadfly
You can also plot in Julia using the `Gadfly` package. `Gadfly` can be especially useful when working with dataframes. The documentation for the `Gadfly` package can be found [here](http://gadflyjl.org/stable/index.html).

Let's start by querying an online dataset:
"""

# ╔═╡ 7840a2da-4ed9-11eb-1d7c-c745e6d0d9b7
# data query from https://stat.ethz.ch/R-manual/R-devel/library/MASS/html/crabs.html
crabs = dataset("MASS", "crabs")

# ╔═╡ 83253d50-4ed9-11eb-13fc-af7c19cb1361
# explore data:
describe(crabs) # gives a quick decription of the data

# ╔═╡ 8329a188-4ed9-11eb-2271-c3c4ef768348
# plot crab carapace length by body depth:
Gadfly.plot(crabs, x = :CL, y = :FL)

# ╔═╡ 834cf520-4ed9-11eb-073e-bf708d994c0c
# colour by species:
Gadfly.plot(
    crabs, x = :CL, y = :FL
    , color = :Sp
    , Guide.xlabel("Carapace length (mm)") 
    , Guide.ylabel("Frontal lobe size (mm)")
    , Guide.colorkey(title="Species")
    , Scale.color_discrete_manual("blue", "orange")
    )

# ╔═╡ 74f8e3f8-4ed9-11eb-33f9-0543274627dc
md"""
B = blue crab and O = orange crab

Again, we've used the `Gadfly.plot()` function as both the `Plots` and `Gadfly` packages are active. If only one was active, we could just use `plot()`.  

## Scoping
Scoping refers to the accessibility of a variable within your project. The scope of a variable is defined as the region of code where a variable is known and accessible. A variable can be in the `global` or `local` scope. 

### Global
A variable in the `global` scope is accessible everywhere and can be modified by any part of your code. When you create (or allocate to) a variable in your script outside of a function or loop you're creating something that is `global`:
"""

# ╔═╡ 97b6c946-4ed9-11eb-36f6-936dae81e122
# global:
A = 7

# ╔═╡ be87d22e-4ed9-11eb-15cb-0d4005df2480
# global array:
B = zeros(1:10)

# ╔═╡ be8cf8ba-4ed9-11eb-1e34-e7e2767264ee
# you can also force a variable to be global using the global macro:
global C = 7

# ╔═╡ bd84966c-4ed9-11eb-10c7-5b521794125e
md"""
### Local

A variable in the `local` scope is only accessible in that scope or in scopes eventually defined inside it. When you define a variable within a function or loop that isn't returned then you create something that is `local`:

"""

# ╔═╡ f0a41a8e-4ed9-11eb-2467-e3e078fa7e5e
C2 = zeros(10) #pre-allocate

# ╔═╡ cfae468c-4ed9-11eb-2566-ebae1b48fd22
# local:
for i in 1:10
    local_varb = 2 # local_varb is defined inside the loop and is therefore local (only accessible within the loop)
    C2[i] = local_varb*i # in comparison, C is defined outside of the loop and is therefore global 
end

# ╔═╡ df1b7c46-4ed9-11eb-1498-b3b3bb77a094
local_a # returns a 'not defined' error

# ╔═╡ df1f5e10-4ed9-11eb-2045-1fdb51fde121
C2 # returns a vector

# ╔═╡ de23bfb0-4ed9-11eb-02f7-d9fec6d121be
md"""
## Quick tips 
Some quick tips that we've learnt the hard way...
1. In the REPL, you can use the up arrow to scroll through past code
2. You can even filter through your past code by typing the first letter of a line previously executed in the REPL. For example, try typing p in the REPL and using the up arrow to scroll through your code history, you should quickly find the last plot command you executed. 
3. Toggle word wrap via View>Toggle Word Wrap or alt-Z
4. Red wavy line under code in your script = error in code 
5. Blue wavy line under code in your script = possible error in code
6. Errors and possible erros can be viewed in the `PROBLEMS` section of the REPL
7. You can view your current variables (similar to the top right hand panel in RStudio) by clickling on the `Julia explorer: Julia workspace` symbol in the activity bar (three circles). You can then look at them in more detail by clicking the sideways arrow (when allowed).
8. Julia has a strange copying aspect where if `a=b`, any change in `b` will automatically cause the same change in `a`. For example:

"""

# ╔═╡ 2d1fe986-4eda-11eb-2388-d58f838ef171
aa = [1,2,3]

# ╔═╡ 44d3e55a-4eda-11eb-1d52-45f8c46e4f0a
bb = aa

# ╔═╡ 44d80068-4eda-11eb-0367-5f25e6b0f865
print(bb)

# ╔═╡ 44f2c434-4eda-11eb-151b-e9b4125d50c3
bb[2] = 41

# ╔═╡ 45103bf4-4eda-11eb-0337-b3aff5b73981
aa

# ╔═╡ 4d145f60-4eda-11eb-39c1-8d42103bee33
md"""
This approach is advantageous because it lets Julia save memory, however, it is not ideal. As a result we might want to force `c` to be an independent copy of `a` using the `deepcopy` function:
"""

# ╔═╡ 58fa0384-4eda-11eb-22b4-e1bf801bdec6
cc = deepcopy(aa)

# ╔═╡ 6426b0e0-4eda-11eb-23e6-8911d5417090
cc[3] = 101

# ╔═╡ 642dde24-4eda-11eb-32cb-efafacf34bec
cc

# ╔═╡ 6446e568-4eda-11eb-3a55-3341e80ba8da
aa

# ╔═╡ 6eb0852c-4eda-11eb-1a2f-f386f358ce00
md"""
9. You can view a .csv or .txt file by clicking on a file name in the project directory (left panel) - this opens a viewing window. CSV's also have a built in 'Preview' mode - try using right click>Open Preview on a .csv file and check it out. 
"""

# ╔═╡ Cell order:
# ╟─ca066c34-4eb5-11eb-0100-b9e31a7c206a
# ╟─00b46e28-4ed3-11eb-0e21-438510d77100
# ╟─cc6b8f9a-4ed3-11eb-1585-a54395c39dab
# ╠═e9598c62-4ed3-11eb-1e5d-b94608ebba88
# ╠═fb80c0ea-4ed3-11eb-370b-53a2b1e6f267
# ╟─fcd90288-4ed3-11eb-394e-672d687ce0b1
# ╟─09474d84-4ed4-11eb-0a59-07e43bd38bc2
# ╠═12c044e2-4ed4-11eb-03a3-c552dd5ff647
# ╠═2255e6fa-4ed4-11eb-3f88-131a0aa28bf9
# ╠═2de8d950-4ed4-11eb-139d-1ff1bf7d473f
# ╠═4498f5ae-4ed4-11eb-3e49-bdca153c4af0
# ╠═4a2e609e-4ed4-11eb-3a60-4187543a7e01
# ╠═4fa7c9a2-4ed4-11eb-3294-192f0d3080ac
# ╠═531f3304-4ed4-11eb-14cb-e38f96153f66
# ╟─5447e2f6-4ed4-11eb-083c-67fbd626c7ba
# ╠═5cd5ce62-4ed4-11eb-09ce-3d5299f2edb3
# ╠═626db3d0-4ed4-11eb-0f67-1d03634bfac7
# ╠═6668fcc4-4ed4-11eb-3524-8905522a7c19
# ╠═9fd4ada2-4ed4-11eb-2faa-6f6da9a455e9
# ╠═a5e1c282-4ed4-11eb-0c87-81a97d416161
# ╟─abc54e12-4ed4-11eb-0db3-1d74c9d88d65
# ╠═b66175da-4ed4-11eb-1453-df631402d6ed
# ╟─bd58f630-4ed4-11eb-0201-6db324add33c
# ╠═d7d77a8e-4ed4-11eb-2c79-f58ad22e8e5d
# ╠═ddd93238-4ed4-11eb-1ce1-338db5b20cb4
# ╟─e5e82af6-4ed4-11eb-013e-8b521851fbae
# ╠═f07a815a-4ed4-11eb-38e2-03d0037bdef5
# ╠═f3f32b00-4ed4-11eb-0e5c-7fb8069cdadd
# ╠═fa595adc-4ed4-11eb-2155-754e431a8269
# ╟─058b854c-4ed5-11eb-1c2d-09f617781b7a
# ╠═13326490-4ed5-11eb-06f9-b1d90c5e0dee
# ╠═17b0539c-4ed5-11eb-054f-a748fb450869
# ╠═1b157a26-4ed5-11eb-38c6-6d7df3ca082f
# ╠═1e7e50de-4ed5-11eb-11af-eb1a5d4fa201
# ╠═223c912c-4ed5-11eb-111f-b18edb8a8d0f
# ╠═25b18c7c-4ed5-11eb-363e-0152fb15f9e3
# ╠═28b8b7e2-4ed5-11eb-2e17-99888ea9f715
# ╟─2cf9902e-4ed5-11eb-3938-a3618865f350
# ╟─362fe602-4ed5-11eb-042e-e7a8330ee7f1
# ╠═43838ebc-4ed5-11eb-2ef8-fd5c2f2c6a32
# ╠═489dfc66-4ed5-11eb-17ee-dd5970ad26c6
# ╟─4b9c9454-4ed5-11eb-0b00-37948aec595e
# ╠═52c63320-4ed5-11eb-0f1b-63f41d328e7b
# ╠═559025de-4ed5-11eb-3730-c759efb8bec4
# ╠═59e357d2-4ed5-11eb-37d0-1fc1081ebb88
# ╠═5dd3b58a-4ed5-11eb-132d-49120926de15
# ╟─627ff148-4ed5-11eb-07dd-7d82d0d4a423
# ╠═7425d48c-4ed5-11eb-1209-c391a15b6136
# ╠═7b4f4872-4ed5-11eb-294b-a79cc798d67f
# ╠═7e8ae1a4-4ed5-11eb-1dce-dd19cf048667
# ╠═8111e134-4ed5-11eb-27a8-0f16a5031f34
# ╟─840e1588-4ed5-11eb-35a1-cb1441dbdcab
# ╠═8aef9066-4ed5-11eb-26bf-bd1f40f803cb
# ╠═8ecebedc-4ed5-11eb-22c7-8df16247f704
# ╟─929584a6-4ed5-11eb-1863-5be0ecc9cadc
# ╠═9a147c82-4ed5-11eb-3232-d38aa3bf64c1
# ╠═9e0fb8b0-4ed5-11eb-157c-6f6666db78e5
# ╠═07c1f304-4ed6-11eb-18f7-bf1d4a5d6317
# ╠═0c22754a-4ed6-11eb-39c8-9de32eb01c17
# ╠═12f07ca0-4ed6-11eb-1cf1-3150bd2167b5
# ╠═153a680e-4ed6-11eb-040d-2da830d34767
# ╠═18405e14-4ed6-11eb-19ed-a9c287a4c2f2
# ╟─1b27583a-4ed6-11eb-31ef-bd2025d2c2a8
# ╟─25cb1c0e-4ed6-11eb-3ab8-19f3d2437ee0
# ╠═31c1d00a-4ed6-11eb-35e8-d731257d1f94
# ╠═375fe878-4ed6-11eb-1461-71dec97c90f6
# ╟─46d0a3e2-4ed6-11eb-1537-51f40c607203
# ╠═53a6a4f4-4ed6-11eb-131a-87870659cf62
# ╟─5a61030c-4ed6-11eb-30f1-6d36d11ab24b
# ╠═6259852a-4ed6-11eb-13cc-59b3ade439be
# ╠═687f598e-4ed6-11eb-2623-b7865d01dfc0
# ╟─688505a0-4ed6-11eb-2054-75438854e56d
# ╠═689593c0-4ed6-11eb-2b6b-05425ef7a8cd
# ╠═68a6d3a6-4ed6-11eb-264d-9d3bb38f94ef
# ╠═68b97d8a-4ed6-11eb-083e-75cc11fbb2a8
# ╟─6781a78a-4ed6-11eb-1e83-510e7be00459
# ╠═8768a652-4ed6-11eb-1f63-17c25554bc88
# ╠═8e10b7f6-4ed6-11eb-09b0-4d4815d99155
# ╠═8e11fd14-4ed6-11eb-2e93-9936795dc0ca
# ╟─9a43c252-4ed6-11eb-0e57-9dc066e8a1a2
# ╠═a11829d8-4ed6-11eb-3dd3-2f23d2d0dfb8
# ╠═a6b61166-4ed6-11eb-01f0-955c156d14fc
# ╠═a6b73e92-4ed6-11eb-0b43-9b2a2b300057
# ╠═a6c8e390-4ed6-11eb-2bac-c3fbd07ac74a
# ╠═a6dc3bde-4ed6-11eb-1c75-2989b7adb7eb
# ╠═a6ed7228-4ed6-11eb-370f-c7aa3f41f879
# ╠═a6ff7016-4ed6-11eb-28a9-fb7d764aa4c6
# ╠═a7115030-4ed6-11eb-0fcb-7b1b2fb5ea06
# ╟─a5c3313a-4ed6-11eb-20ee-e735e7ba92a0
# ╠═b5e6047a-4ed6-11eb-2a56-17b75c5091a8
# ╠═bf5a8c38-4ed6-11eb-2763-3f048a611cce
# ╠═bf5c26b0-4ed6-11eb-244e-7d68ed2ffb55
# ╠═bf6dcb9a-4ed6-11eb-2135-918cfb78b9b3
# ╠═bf7ef97e-4ed6-11eb-384f-cb1767c18946
# ╠═bf902b5e-4ed6-11eb-12ad-71cb85696690
# ╠═bfa18840-4ed6-11eb-115a-f393a5fe45ba
# ╠═bfb2f0b4-4ed6-11eb-2220-d7f2df285199
# ╠═bfc49670-4ed6-11eb-03f7-c92156c63514
# ╠═bfd5ee96-4ed6-11eb-3638-6b4bed3c63db
# ╟─bdcb817e-4ed6-11eb-2cc2-331edb5aae22
# ╠═d1d274ca-4ed6-11eb-0a11-6d334548f77a
# ╠═d867329e-4ed6-11eb-0739-4dada7e2f3dc
# ╠═d8695718-4ed6-11eb-2728-07d16a440e76
# ╠═d87ba9fe-4ed6-11eb-1872-57f5931c928f
# ╟─d88efdec-4ed6-11eb-01ce-a50f7f9e6c6e
# ╟─d78a2264-4ed6-11eb-252a-814789e778d2
# ╠═768349ea-4ed7-11eb-1b9b-2ff91e39460e
# ╠═91dc1438-4ed7-11eb-357a-e358200dee3a
# ╠═91dda1c2-4ed7-11eb-3a53-7b126c8c99e6
# ╠═91efdebe-4ed7-11eb-1918-433e8e3112f3
# ╠═92022338-4ed7-11eb-0965-dd858836e038
# ╟─90e56af2-4ed7-11eb-1836-0ba5da4b3799
# ╠═9f09e8c4-4ed7-11eb-3df7-b91b7decd4c0
# ╠═a6dd5c16-4ed7-11eb-3974-67e79c8c6b8d
# ╠═a5b34a80-4ed7-11eb-36be-5bdd564ce47c
# ╠═a6dfca2a-4ed7-11eb-3f50-6d4e4b63c5e2
# ╟─b9a0dcce-4ed7-11eb-0164-31afe37e67d0
# ╠═c4dc8c00-4ed7-11eb-18d6-7b23fd5cc6e6
# ╠═d63e6b62-4ed7-11eb-3157-67230869ddec
# ╠═d640e676-4ed7-11eb-151a-e72f6305087e
# ╠═d653bd08-4ed7-11eb-1ab4-8daea5084b6b
# ╟─d667f0ea-4ed7-11eb-1635-7fa63407507e
# ╟─c162c9cc-4ed7-11eb-18ef-4fd0e8c909ae
# ╠═f786dc5a-4ed7-11eb-3795-41591dce8cee
# ╠═fef269c8-4ed7-11eb-1c6b-cb31a00302c7
# ╠═fef566f0-4ed7-11eb-0d85-b3568c5ff36c
# ╠═ff07ec26-4ed7-11eb-0f44-d3a815231119
# ╠═ff1b85d8-4ed7-11eb-284b-cf9960c38c9f
# ╠═ff342390-4ed7-11eb-1893-bf76669aa189
# ╠═ff48c8b8-4ed7-11eb-3aa4-096d1a8550d3
# ╠═ff5e8d88-4ed7-11eb-3ec6-cd69c74e33db
# ╠═ff786c44-4ed7-11eb-3d46-7dcf1fd6fe4c
# ╠═ff8daaf0-4ed7-11eb-2bb6-33cad9305363
# ╠═ffa19e5c-4ed7-11eb-2108-7d276f219292
# ╟─fdecca50-4ed7-11eb-1dff-edb237ec9d49
# ╟─0bf354ac-4ed8-11eb-06b4-29e0464966dc
# ╠═151e333a-4ed8-11eb-3676-7b2b7408e552
# ╠═1a127590-4ed8-11eb-0c19-0d9cd0684c67
# ╟─19184552-4ed8-11eb-2741-e15dbb3ec9fa
# ╟─28cc8288-4ed8-11eb-2b22-8d0b239404b8
# ╠═2ebab296-4ed8-11eb-150e-dbf2fafcc53b
# ╟─32d348e8-4ed8-11eb-3d75-c5e357111223
# ╠═3fb8f698-4ed8-11eb-3f5b-9f5fda6445ee
# ╟─9a6eaaba-4ed8-11eb-3589-213a28527443
# ╠═b111565a-4ed8-11eb-1d0f-5fcf0b4f02c5
# ╠═b6aa1ae8-4ed8-11eb-3948-436ffcb2a4b7
# ╠═b6ade206-4ed8-11eb-2994-d784c0d2e507
# ╟─b5c3c8a4-4ed8-11eb-35cd-1f0630bbef26
# ╠═3e959ffc-4ed8-11eb-1c87-272963fe31da
# ╠═ee7132ae-4ed8-11eb-2b39-cd1dddd0770b
# ╠═ee76a64e-4ed8-11eb-3827-fffd9aa53158
# ╠═ee8cd0a4-4ed8-11eb-0451-11379e47d9c6
# ╟─ed895f94-4ed8-11eb-3f37-adffab630902
# ╠═1613f472-4ed9-11eb-0c1c-2505e46f8e75
# ╠═1ee6b0d0-4ed9-11eb-2488-d3cb62797c04
# ╠═1eea3a48-4ed9-11eb-206f-0b5bcf2d0852
# ╠═1efe03fe-4ed9-11eb-0f41-d1800e2f339a
# ╟─363d76ce-4ed9-11eb-1548-71572c9631f3
# ╠═5786cbf0-4ed9-11eb-15e9-8158397b3944
# ╠═5a03c5ea-4ed9-11eb-1068-d96a3ffbe749
# ╠═5a079120-4ed9-11eb-0ec4-71ca57a74a04
# ╠═5a1fbae8-4ed9-11eb-1fa1-05766d97901c
# ╟─6af780da-4ed9-11eb-2ea1-e5e2e6fed2f4
# ╠═7840a2da-4ed9-11eb-1d7c-c745e6d0d9b7
# ╠═83253d50-4ed9-11eb-13fc-af7c19cb1361
# ╠═8329a188-4ed9-11eb-2271-c3c4ef768348
# ╠═834cf520-4ed9-11eb-073e-bf708d994c0c
# ╟─74f8e3f8-4ed9-11eb-33f9-0543274627dc
# ╠═97b6c946-4ed9-11eb-36f6-936dae81e122
# ╠═be87d22e-4ed9-11eb-15cb-0d4005df2480
# ╠═be8cf8ba-4ed9-11eb-1e34-e7e2767264ee
# ╟─bd84966c-4ed9-11eb-10c7-5b521794125e
# ╠═f0a41a8e-4ed9-11eb-2467-e3e078fa7e5e
# ╠═cfae468c-4ed9-11eb-2566-ebae1b48fd22
# ╠═df1b7c46-4ed9-11eb-1498-b3b3bb77a094
# ╠═df1f5e10-4ed9-11eb-2045-1fdb51fde121
# ╟─de23bfb0-4ed9-11eb-02f7-d9fec6d121be
# ╠═2d1fe986-4eda-11eb-2388-d58f838ef171
# ╠═44d3e55a-4eda-11eb-1d52-45f8c46e4f0a
# ╠═44d80068-4eda-11eb-0367-5f25e6b0f865
# ╠═44f2c434-4eda-11eb-151b-e9b4125d50c3
# ╠═45103bf4-4eda-11eb-0337-b3aff5b73981
# ╟─4d145f60-4eda-11eb-39c1-8d42103bee33
# ╠═58fa0384-4eda-11eb-22b4-e1bf801bdec6
# ╠═6426b0e0-4eda-11eb-23e6-8911d5417090
# ╠═642dde24-4eda-11eb-32cb-efafacf34bec
# ╠═6446e568-4eda-11eb-3a55-3341e80ba8da
# ╟─6eb0852c-4eda-11eb-1a2f-f386f358ce00
