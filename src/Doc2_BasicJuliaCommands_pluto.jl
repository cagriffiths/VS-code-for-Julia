### A Pluto.jl notebook ###
# v0.16.2

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

Just a heads up, a feature of the markdown notebook (Pluto) we have used to construct these tutorial documents is that the code output appears above the code chunk. 
"""

# ╔═╡ cc6b8f9a-4ed3-11eb-1585-a54395c39dab
md"## Load packages

You'll need a few packages for this tutorial (this might take a few minutes, don't panic):
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

# ╔═╡ 6202905e-64b5-11eb-1efc-6945db996844
md"For those of you that are interested, a floating-point object (a Float) is a number that has a decimal place. An Int object is an integer, a number without a decimal place, whereas an Irrational object is a specific type of Float used only for representing some irrational numbers of special significance (e.g. π and γ). The 64 purely refers to 64-bit which is the type of processor your computer uses, most modern computers are 64-bit." 

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
# trues or falses may also appear as 0's and 1's - they are interchangable. 

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
begin
	# alternative:
	range_array2 = [0:1:10] # start:step:end
	typeof(range_array2)
	# note that this produces an object of type StepRange and not a vector. An object of type StepRange is a special type of an array where the step between each element is constant, and the range is defined in terms of a start and a stop.
end

# ╔═╡ 0c22754a-4ed6-11eb-39c8-9de32eb01c17
# you can turn range_array into a vector by "collecting": 
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
mat[5] 
# it reads the matrix row-wise and then column-wise, so it reads row1col1, row2col1, row1col2, row2col2, etc. Hence mat[5] = 3 and not 5. 

# ╔═╡ 6781a78a-4ed6-11eb-1e83-510e7be00459
md"""
## DataFrames and CSVs
Dataframes and CSVs are also easy to use in Julia and can help when storing, inputting and outputting data in a ready to use format. 

### Creating a dataframe
To initialise a dataframe you use the `DataFrame` function from the `DataFrames` package:

"""

# ╔═╡ 8768a652-4ed6-11eb-1f63-17c25554bc88
# create a dataframe with three columns
dat = DataFrame(col1=[], col2=[], col3=[]) # as in section 1.7, we use [] to specify an empty column of any type and size. 

# ╔═╡ 8e10b7f6-4ed6-11eb-09b0-4d4815d99155
# you can also specify column type using:
dat1 = DataFrame(col1=Float64[], col2=Int64[], col3=Float64)
# Try hovering over the above image to reveal the column type. 

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
push!(dat, [x2,y2,z2])

# ╔═╡ bf7ef97e-4ed6-11eb-384f-cb1767c18946
# look at a dataframe:
println(dat2)

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
dat2[1,:species]

# ╔═╡ df818ea6-64bd-11eb-2ccf-ff6ed64195ef
md"""
You can view your dataframes and any other variables of interest by clickling on the `Julia explorer: Julia workspace` symbol in the activity bar (three circles). You can then look at them in more detail by clicking the sideways arrow (when allowed). The explorer is very similar to R's workspace and global environment (top right hand panel in RStudio). 
"""

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
begin
	# simple function:
	x_new = 33.0 
	function plus_two(x)
	    return x + 2
	end
end

# ╔═╡ 91dda1c2-4ed7-11eb-3a53-7b126c8c99e6
# run functions:
z3 = plus_two(x_new)

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
# if you execute bodyweight() and don't specify g, you get body weight as measured on Earth (because g is fixed at a default value of 9.81):
bodyweight(80)

# ╔═╡ a6dfca2a-4ed7-11eb-3f50-6d4e4b63c5e2
# alternatively, you can change g and get your weight on another planet:
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

In the above code, you might have spotted the word `global`. Variables can exist in the `local` or `global` scope. If a variable exists inside a loop or function it is `local` and if you want to save it beyond the loop (i.e., in your workspace) you have to make it `global` - more on this later.

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

Quick note here, Penelope got the following error when plotting the first plot:
Error showing value of type Plots.Plot{Plots.GRBackend}: ERROR: could not load library "libGR.so"

If this happens, run these two lines in your REPL:

ENV["GRDIR"]=""

Pkg.build("GR")
"""

# ╔═╡ 875320be-64bd-11eb-19eb-8540b1ee4cd7
md"""
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
Once you've created a plot it can be viewed or reopened in VS Code by navigating to the `Julia explorer: Julia workspace` symbol in the activity bar (three circles) and clicking on the plot object (e.g., p1). We advise that you always name and assign your plots (e.g. p1, p2, etc). The `Plots` package also has it's own [tutorial](https://docs.juliaplots.org/latest/tutorial/) for plotting in Julia.

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

Don't be alarmed if your Gadfly plots have a different background colour, it's simply because you've chosen a funky theme for VS Code and you haven't specified a background colour. The plot background can changed by passing a `Theme` object to the `plot` function - see [here](http://gadflyjl.org/v0.4/man/themes.html) for more details.

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
local_varb # returns a 'not defined' error

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
RDatasets = "ce6b1742-4840-55fa-b093-852dadbb1d8b"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
CSV = "~0.8.5"
DataFrames = "~1.2.2"
Distributions = "~0.25.20"
Gadfly = "~1.3.4"
Plots = "~1.22.6"
RDatasets = "~0.7.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
git-tree-sha1 = "bdf73eec6a88885256f282d48eafcad25d7de494"
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[Artifacts]]
deps = ["Pkg"]
git-tree-sha1 = "c30985d8821e0cd73870b17b0ed0ce6dc44cb744"
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.3.0"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e2f47f6d8337369411569fd45ae5753ca10394c6"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.0+6"

[[CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "fbc5c413a005abdeeb50ad0e54d85d000a1ca667"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "d9e40e3e370ee56c5b57e0db651d8f92bce98fea"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.10.1"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8e695f735fca77e9708e795eda62afdb869cbb70"
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.3.4+0"

[[Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "c6461fc7c35a4bb8d00905df7adafcff1fe3a6bc"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CoupledFields]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "6c9671364c68c1158ac2524ac881536195b7e7bc"
uuid = "7ad07ef1-bdf2-5661-9d2b-286fd4296dac"
version = "0.2.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "9f46deb4d4ee4494ffb5a40a27a2aced67bdd838"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.4"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "9809cf6871ca006d5a4669136c09e77ba08bf51a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.20"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
git-tree-sha1 = "135bf1896be424235eadb17474b2a78331567f08"
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.5.1"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "1402e52fcda25064f51c77a9655ce8680b76acf0"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.7+6"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "LibVPX_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3cc57ad0a213808473eafef4845a74766242e05f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.3.1+4"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "IntelOpenMP_jll", "Libdl", "LinearAlgebra", "MKL_jll", "Reexport"]
git-tree-sha1 = "1b48dbde42f307e48685fa9213d8b9f8c0d87594"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.3.2"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "3c041d2ac0a52a12a27af2782b34900d9c3ee68c"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.1"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "35895cf184ceaab11fd778b4590144034a167a2f"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.1+14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0d20aed5b14dd4c9a2453c1b601d08e1149679cc"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.5+6"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "a199aefead29c3c2638c3571a9993b564109d45a"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.4+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "d189c6d2004f63fd3c91748c458b09f26de0efaa"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.61.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d59e8320c2747553788e4fc42231489cc602fa50"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.58.1+0"

[[Gadfly]]
deps = ["Base64", "CategoricalArrays", "Colors", "Compose", "Contour", "CoupledFields", "DataAPI", "DataStructures", "Dates", "Distributions", "DocStringExtensions", "Hexagons", "IndirectArrays", "IterTools", "JSON", "Juno", "KernelDensity", "LinearAlgebra", "Loess", "Measures", "Printf", "REPL", "Random", "Requires", "Showoff", "Statistics"]
git-tree-sha1 = "13b402ae74c0558a83c02daa2f3314ddb2d515d3"
uuid = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
version = "1.3.4"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "8c14294a079216000a0bdca5ec5a447f073ddc9d"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.20.1+7"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "04690cc5008b38ecbdfede949220bc7d9ba26397"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.59.0+4"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[Hexagons]]
deps = ["Test"]
git-tree-sha1 = "de4a6f9e7c4710ced6838ca906f81905f7385fd6"
uuid = "a1b4810d-1bce-5fbd-ac56-80944d57a21f"
version = "0.2.0"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "f0c6489b12d28fb4c2103073ec7452f3423bd308"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.1"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9aff0587d9603ea0de2c6f6300d9f9492bbefbd3"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.0.1+3"

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "df381151e871f41ee86cee4f5f6fd598b8a68826"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.0+3"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f128cd6cd05ffd6d3df0523ed99b90ff6f9b349a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.0+3"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "669315d963863322302137c4591ffce3cb5b8e68"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.8"

[[LazyArtifacts]]
deps = ["Pkg"]
git-tree-sha1 = "4bb5499a1fc437342ea9ab7e319ede5a457c0968"
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"
version = "1.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
git-tree-sha1 = "cdbe7465ab7b52358804713a53c7fe1dac3f8a3f"
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[LibCURL_jll]]
deps = ["LibSSH2_jll", "Libdl", "MbedTLS_jll", "Pkg", "Zlib_jll", "nghttp2_jll"]
git-tree-sha1 = "897d962c20031e6012bba7b3dcb7a667170dad17"
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.70.0+2"

[[LibGit2]]
deps = ["Printf"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Libdl", "MbedTLS_jll", "Pkg"]
git-tree-sha1 = "717705533148132e5466f2924b9a3657b16158e8"
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.9.0+3"

[[LibVPX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "85fcc80c3052be96619affa2fe2e6d2da3908e11"
uuid = "dd192d2f-8180-539f-9fb4-cc70b1dcf69a"
version = "1.9.0+1"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a2cd088a88c0d37eef7d209fd3d8712febce0d90"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.1+4"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "b391a18ab1170a2e568f9fb8d83bc7c780cb9999"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.5+4"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ec7f2e8ad5c9fa99fc773376cdbc86d9a5a23cb7"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.36.0+3"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cba7b560fcc00f8cd770fa85a498cbc1d63ff618"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.0+8"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51ad0c01c94c1ce48d5cad629425035ad030bfd5"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.34.0+3"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "291dd857901f94d683973cdf679984cdf73b56d0"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.1.0+2"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f879ae9edbaa2c74c922e8b85bb83cc84ea1450b"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.34.0+7"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "b5254a86cf65944c68ed938e575f5c81d5dfe4cb"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.3"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "6193c3815f13ba1b78a51ce391db8be016ae9214"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.4"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0eef589dd1c26a3ac9d753fe1a8bcad63f956fa6"
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.16.8+1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "29714d0a7a8083bba8427a4fbfb00a540c681ce7"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.3"

[[MozillaCACerts_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f1662575f7bf53c73c2bbc763bace4b024de822c"
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2021.1.19+0"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
git-tree-sha1 = "ed3157f48a05543cce9b241e1f2815f7e843d96e"
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c0e9e582987d36d5a61e650e6e543b9e44d9914b"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.7"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a42c0f138b9ebe8b58eba2271c5053773bde52d0"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.4+2"

[[OpenLibm_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "d22054f66695fe580009c09e765175cbf7f13031"
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.7.1+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "71bbbc616a1d710879f5a1021bcba65ffba6ce58"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.1+6"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9db77584158d0ab52307f8c04f8e7c08ca76b5b3"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.3+4"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f9d57f4126c39565e05a2b0264df99f497fc6f37"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.1+3"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "1b556ad51dceefdbf30e86ffa8f528b73c7df2bb"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.42.0+4"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6a20a83c1ae86416f0a5de605eaea08a552844a3"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.0+0"

[[Pkg]]
deps = ["Dates", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "UUIDs"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "ba43b248a1f04a9667ca4a9f782321d9211aa68e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.6"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "16626cfabbf7206d60d84f2bf4725af7b37d4a77"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.2+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[RData]]
deps = ["CategoricalArrays", "CodecZlib", "DataFrames", "Dates", "FileIO", "Requires", "TimeZones", "Unicode"]
git-tree-sha1 = "19e47a495dfb7240eb44dc6971d660f7e4244a72"
uuid = "df47a6cb-8c03-5eed-afd8-b6050d6c41da"
version = "0.8.3"

[[RDatasets]]
deps = ["CSV", "CodecZlib", "DataFrames", "FileIO", "Printf", "RData", "Reexport"]
git-tree-sha1 = "06d4da8e540edb0314e88235b2e8f0429404fdb7"
uuid = "ce6b1742-4840-55fa-b093-852dadbb1d8b"
version = "0.7.5"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "86c5647b565873641538d8f812c04e4c9dbeb370"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.6.1"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "1b7bf41258f6c5c9c31df8c1ba34c1fc88674957"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.2.2+2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "54f37736d8934a12a200edea2f9206b03bdf3159"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.7"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2d57e14cd614083f132b6224874296287bfa3979"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "95072ef1a22b057b1e80f73c2a89ad238ae4cfff"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.12"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
git-tree-sha1 = "44aaac2d2aec4a850302f9aa69127c74f0c3787e"
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Test]]
deps = ["Distributed", "InteractiveUtils", "Logging", "Random"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimeZones]]
deps = ["Dates", "Future", "LazyArtifacts", "Mocking", "Pkg", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "a5688ffdbd849a98503c6650effe79fe89a41252"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.5.9"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "dc643a9b774da1c2781413fd7b6dcd2c56bb8056"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.17.0+4"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9398e8fefd83bde121d5127114bd3b6762c764a6"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.4"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "be0db24f70aae7e2b89f2f3092e93b8606d659a6"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.10+3"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "2b3eac39df218762d2d005702d601cd44c997497"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.33+4"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "320228915c8debb12cb434c59057290f0834dbf6"
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.11+18"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "2c1332c54931e83f8f94d310fa447fd743e8d600"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.4.8+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "acc685bcf777b2202a904cdcb49ad34c2fa1880c"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.14.0+4"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7a5780a0d9c6864184b3a2eeeb833a0c871f00ab"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "0.1.6+4"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "6abbc424248097d69c0c87ba50fcb0753f93e0ee"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.37+6"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "fa14ac25af7a4b8a7f61b287a124df7aab601bcd"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.6+6"

[[nghttp2_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "8e2c44ab4d49ad9518f359ed8b62f83ba8beede4"
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.40.0+2"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d713c1ce4deac133e3334ee12f4adff07f81778f"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2020.7.14+2"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "487da2f8f2f0c8ee0e83f39d13037d6bbf0a45ab"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.0.0+3"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
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
# ╟─6202905e-64b5-11eb-1efc-6945db996844
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
# ╟─df818ea6-64bd-11eb-2ccf-ff6ed64195ef
# ╟─bdcb817e-4ed6-11eb-2cc2-331edb5aae22
# ╠═d1d274ca-4ed6-11eb-0a11-6d334548f77a
# ╠═d867329e-4ed6-11eb-0739-4dada7e2f3dc
# ╠═d8695718-4ed6-11eb-2728-07d16a440e76
# ╠═d87ba9fe-4ed6-11eb-1872-57f5931c928f
# ╟─d88efdec-4ed6-11eb-01ce-a50f7f9e6c6e
# ╟─d78a2264-4ed6-11eb-252a-814789e778d2
# ╠═768349ea-4ed7-11eb-1b9b-2ff91e39460e
# ╠═91dda1c2-4ed7-11eb-3a53-7b126c8c99e6
# ╠═91efdebe-4ed7-11eb-1918-433e8e3112f3
# ╠═92022338-4ed7-11eb-0965-dd858836e038
# ╟─90e56af2-4ed7-11eb-1836-0ba5da4b3799
# ╠═9f09e8c4-4ed7-11eb-3df7-b91b7decd4c0
# ╠═a6dd5c16-4ed7-11eb-3974-67e79c8c6b8d
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
# ╟─875320be-64bd-11eb-19eb-8540b1ee4cd7
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
