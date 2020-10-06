###################################################################################################################################################################
# Date - 6th October 2020
# Authors - Chris Griffiths and Eva Delmas
# Title - Using Julia in VS code #3
###################################################################################################################################################################
# This doc follows on from "Using Julia in VS code #1" and "Using Julia in VS code #2"
import Pkg
using Plots, DataFrames, Distributions, Random, EcologicalNetworks, BioEnergeticFoodWebs, DelimitedFiles # Reload packages if needed
Pkg.status() # Check packages and versions

# This doc aims to introduce the EcologicalNetworks and BioEnergeticFoodWebs packages and recreate the first example in Delmas et al. 2017 MEE
# Check out the paper before we start - https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713
