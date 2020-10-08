###################################################################################################################################################################
# Date - 5th October 2020
# Authors - Chris Griffiths and Eva Delmas
# Title - Using Julia in VS code #1
###################################################################################################################################################################
# Before we start - make sure you've downloaded and installed Julia on your device - https://julialang.org/downloads/. We're currently using version 1.5.

# This doc covers the following:
# (1) Installing Julia and adding extensions - setting up your computer
# (2) Installing and loading packages in your directory
# (3) Basic Julia commands

## First off, check out the Introductory videos on the visual studio webpage - https://code.visualstudio.com/docs/getstarted/introvideos. These will help explain some of the terminology used below. They'll also show you how to change the colour theme and icon symbols (by far the most important part of any coding tutorial...)

## (1) Setting up your computer:
# Note - extensions are higher level packages that allow you to use different coding languages, edit your VS code themes and icons, or provide helpful applications like spell checker or Bracket Pair Colorizer (colours pairs of brackets)
# (1) Create a folder in your documents (or some other location) and name it
# (2) Open VS code - you'll see the Welcome page
# (3) To install Julia in VS code (only need to do this once), navigate to the marketplace (fourth symbol down in the activity bar - vertical panel on the left), search for Julia and install the Julia language support (you might need to restart VS code)
# (4) Also install any other required extensions - e.g. Julia Formatter.
# (5) Then click on explorer symbol (top symbol on the activity bar) and click Open Folder
# (6) Navigate to our folder of choice and click open - this will then form the location of your directory (same as an RProject). Your directory will appear as a vertical pane on the left hand side of the screen. 
# (4) You can then create a new file (a script) using (cmd-N, File>New File or left click>New File in the directory) and save it with .jl extension (tells VS code you want to use the Julia language)
# (5) Open a new REPL (stands for - read, execute, print and loop) by typing Start REPL in the command palette (accessed using F1, cmd-shift-P or View>Command Palette). The REPL is the console/terminal that you run Julia code in. 
# (6) Type 'Hello world' in your new script and run (ctrl-enter to run line by line or shift-enter to run a block of code):
println("Hello world")

## (2) As in R, Julia relies on packages to run precompliled functions and commands, however, it does require a little more leg work than install.packages().
# (1) Activite the project directory (ensure that you are always using the same version of the packages when you're working with a specified project)
import Pkg
Pkg.activate(".") # Activites the directory and points to the Manifest.toml and Project.toml files that are automatically created. 
Pkg.instantiate() # Instantiate ensures that right version of all packages are being installed - key when you want to work from a different computer and need to install packages, or for other users of your code.
# (2) To install a new package you use:
Pkg.add("CSV")
# or you can type the following directly in to the REPL: ] add CSV (if you use this approach, make sure you backspace out of the project directory). You can also remove a package this way using ] rm CSV
# (3) You then use 'using' to tell Julia that you want to use a given package:
using CSV
# Other useful packages include:
Pkg.add("Plots")
Pkg.add("DataFrames")
Pkg.add("Distributions")
Pkg.add("Random")
Pkg.add("EcologicalNetworks")
Pkg.add("BioEnergeticFoodWebs")
Pkg.add("DelimitedFiles")
using Plots, DataFrames, Distributions, Random, EcologicalNetworks, BioEnergeticFoodWebs, DelimitedFiles # This might take a while to compile
# (4) You can then check the packages and versions that are currently active in your directory using:
Pkg.status() # useful when using the BioEnergeticFoodWebs package as Eva has a ton of versions...

## Eva - Should we put something hear about linking to GitHub? Third symbol down in the activity bar... 

## (3) Basic commands 
# (1) Set a random seed:
Random.seed!(33)
# (2) Allocate a string:
aps = "Animal and Plant Sciences" # must use "" and not ''
# (3) Allocate an integer:
number = 5
# Note that you can easily insert variables into strings using $ and concatenate strings using * : 
println("This is a number: $number" * " - type: Integer")
# (4) Allocate a floating point number:
pi_sum = 3.1415
# note: pi can also be called using pi or π (type \pi and tab to transform into the unicode symbol)
pi_sum2 = pi
pi_sum3 = π
# you can actually use unicode symbols in Julia, this can be useful for naming parameters following standards: 
λ = 4
# and you can attribute multiple variables at the same time: 
αi, βi, γi = 1.3, 2.1, exp(39)
# Note - Julia is like R and Python, it can infer the type of object (Integer, Float) on the left hand side of the equals sign, you don't have to justify it like you do in C. 
# However, you can if needed e.g.
pi_sum1 = Float64(3.141592)
# (5) You can then check the object type using:
typeof(number)
typeof(pi_sum), typeof(pi_sum2) #note here that by using the preallocated variable pi, we are actually using an object of type Irrational (a specific type of float)
# (6) You can print an object (useful when running simulations) using:
print(aps) 
print(aps) # prints in the same line or
println(aps) # prints on the next line
# (7) and convert between object types using:
a = 2 
b = convert(Float64, a) 
b = Float64(a) #also works
# (8) It's also very easy to perform simple mathematical operations:
c = 2
d = 3
sum = c + d
diff = c - d
product = c * d
div = c / d
pow = c^2
# For a complete list of all mathematical operations see https://docs.julialang.org/en/v1/manual/mathematical-operations/index.html

