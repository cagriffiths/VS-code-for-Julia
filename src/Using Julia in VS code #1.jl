###################################################################################################################################################################
# Date - 5th October 2020
# Authors - Chris Griffiths and Eva Delmas
# Title - Using Julia in VS code #1
###################################################################################################################################################################
# Before we start - make sure you've downloaded and installed Julia on your device - https://julialang.org/downloads/. We're currently using version 1.5.

# This doc covers the following:
# (1) Installing Julia and adding extensions - i.e. setting up your computer
# (2) Installing and loading packages
# (3) Basic Julia commands

## First off, check out the Introductory videos on the visual studio webpage - https://code.visualstudio.com/docs/getstarted/introvideos. 
# These will help explain some of the terminology used below. 
 #They'll also show you how to change the colour theme and icon symbols (by far the most important part of any coding tutorial...)

## (1) Setting up your computer:
# Note - VSCode extensions are higher level packages that allow you to use different coding languages, 
# edit your VS code themes and icons, or provide helpful applications like spell checker or Bracket Pair Colorizer (colours pairs of brackets)
# (a) Create a folder in your documents/GoogleDrive/Dropbox (or some other location) and name it.  
# This is your Project Folder
# (b) Open VS code - you'll see the VS code Welcome page

# (c) To install Julia in VS code (only need to do this once), navigate to the marketplace 
# (fourth symbol down in the activity bar - vertical panel on the left), search for Julia and 
# install the Julia language support (you might need to restart VS code)
# (d) Also install any other required extensions - e.g. Julia Formatter (ARE THERE MORE?)

# (e) Next we open our project folder: click on explorer symbol (top symbol on the activity bar) and click Open Folder
# (f) Navigate to your folder you made in step (1) and click open - this becomes the location of your working directory (same as an RProject). 
# Your directory will appear as a vertical pane on the left hand side of the screen. 
# (g) You can then create a new file (a script) using (cmd-N, File>New File or left click>New File in the directory) and save it with .jl extension 
# (tells VS code you want to use the Julia language)

# (h) Now, open a new REPL (stands for - read, execute, print and loop)
# the REPL is like the console in R.  It's VSCodes using Julia for a brain
# do this by typing Alt-J Alt-O or by typing Start REPL in the command palette (accessed using F1, cmd-shift-P or View>Command Palette). 

# (i) Type 'println(Hello world)' in your new script.

println("Hello world")

# --> To Send code from your Script to the REPL, you can use ctrl-enter to run line by line or shift-enter to run a block of code <--


## (2) As in R, Julia relies on packages to run precompliled functions and commands, 
# however, it does require a little more leg work than install.packages().  Here we review
# how to install packages 

# (1) Activite the project directory (ensures that you're are always using the same version of the packages when you're working within a specified project)
import Pkg
Pkg.activate(".") # Activites the directory and points to the Manifest.toml and Project.toml files that are automatically created. 
Pkg.instantiate() # Instantiate ensures that right version of all packages are being installed - key when you want to work from a different computer and need to install packages, or for other users of your code.
# There are two ways to check that you are actually working into the right environment: 
# - check/click the 'Julia env:...' on the bottom left of your screen, it should match your folder name
# - enter the package manager by typing ] in the Julia REPL, you should see '(your-folder-name) pkg>' instead of 'julia>'. Exit it using backspace.

# (2) To install a new package you use:
Pkg.add("CSV")
# or you can type the following directly in to the REPL: ] add CSV (if you use this approach, make sure you backspace out of the project directory). You can also remove a package this way using ] rm CSV

# (3) You then use 'using' to tell Julia that you want to use a given package (same as required or library in R):
using CSV
# Other useful packages include:
Pkg.add("Plots")
Pkg.add("DataFrames")
Pkg.add("Distributions")
Pkg.add("Random")
Pkg.add("EcologicalNetworks")
Pkg.add("BioEnergeticFoodWebs")
Pkg.add("DelimitedFiles")
Pkg.add("RDatasets")
Pkg.add("Gadfly")
using Plots, DataFrames, Distributions, Random, EcologicalNetworks, BioEnergeticFoodWebs, DelimitedFiles, RDatasets, Gadfly # This might take a while to compile
# (4) You can then check the packages and versions that are currently active in your directory using:
Pkg.status() # useful when using the BioEnergeticFoodWebs package as Eva has a ton of versions...

## (3) Basic commands 
# (1) Set a random seed:
Random.seed!(33)
# (2) Allocate a string:
aps = "Animal and Plant Sciences" # must use "" and not ''
# (3) Allocate an integer:
number = 5
# Note that you can easily insert variables into strings using $ and concatenate strings using * : 
t = typeof(number) #you can use typeof to identify the type of an object
println("This is a number: $number" * " - type: $t")
# (4) Allocate a floating point number:
pi_sum = 3.1415
# note: pi can also be called using pi or π (type \pi and tab to transform into the unicode symbol)
pi_sum2 = pi
pi_sum3 = π
# you can actually use unicode symbols in Julia, this can be useful for naming parameters following standards: 
λ = 4
# and you can attribute multiple variables at the same time: 
αi, βi, γi = 1.3, 2.1, exp(39)
αi
# Note - Julia is like R and Python, it can infer the type of object (Integer, Float) on the left hand side of the equals sign, you don't have to justify it like you do in C. 
# However, you can if needed e.g.
pi_sum1 = Float64(3.141592)
# (5) You can then check the object type using:
typeof(pi_sum), typeof(pi_sum2) # note here that by using the preallocated variable pi, we are actually using an object of type Irrational (a specific type of float)
# (6) You can print an object (useful when running simulations) using:
print(aps) 
print(aps) # prints in the same line or
println(aps) # prints on the next line (useful for printing in loops, etc)
# (7) and convert between object types using:
a = 2 
b = convert(Float64, a) 
b = Float64(a) #also works
# (8) It's also very easy to perform simple mathematical operations:
c = 2
d = 3
sumcd = c + d
diffcd = c - d
productcd = c * d
divcd = c / d
powcd = c^2
# For a complete list of all mathematical operations see https://docs.julialang.org/en/v1/manual/mathematical-operations/index.html
# We also recommend reading more about Julia's type system - it really helps you understand more about its behaviour: 

