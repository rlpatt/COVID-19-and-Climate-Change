###################################################
# Author: Saurav Kiri
# Date: 2022-11-30
# Description: Does the following functions:
    # 1) Loads NOAA gas and NASA GISTEMP data from a local repository
    # 2) Performs basic wrangling on data structures
    # 3) Returns the individual data frames and subsetted dfs in list to global directory
# Requires:
    # NOAA gas and NASA GISTEMP data on local machine
    # Necessary scripts for wrangling data
    # To obtain the above, use "git clone https://github.com/rlpatt/Data_Munging" on the command line
###################################################

# Load required packages
library(tidyverse)
library(data.table)
library(corrplot)       # Make correlation plots
library(ComplexHeatmap) # For making heatmaps
library(ggfortify)      # For using autoplot() with prcomp()
library(ClusterR)       # For k-means clustering
library(factoextra)     # For elbow plots to determine optimal k

# Set up top-level project directory
# Note that this assumes one of the following:
    #1) You have cloned the git repo with git clone
    #2) You have a file system as defined in the GitHub repository
        # I.e., similar to ~/Project/Datasets and ~/Project/Scripts

# Code from https://stackoverflow.com/questions/47044068/
getCurrentFileLocation <-  function() {
    this_file <- commandArgs() %>%
    tibble::enframe(name = NULL) %>%
    tidyr::separate(col = value,
                    into = c("key", "value"),
                    sep = "=",
                    fill = "right") %>%
    dplyr::filter(key == "--file") %>%
    dplyr::pull(value)
    if (length(this_file) == 0) {
        this_file <- rstudioapi::getSourceEditorContext()$path
    }
    return(dirname(this_file))
}

# Alternative is to use here() (from "here" package)
    # Walks up dir hierarchy starting from wd during loading until it finds a dir satisfying either:
    # 1) Contains file matching [.]Rproj$
    # 2) Contains a .git directory
# Disadvantage is that it only works if you're in a directory *within* root

# Get directory of current file, which should be in Scripts sub-dir
current.dir <- file.path(getCurrentFileLocation())
setwd(current.dir)
setwd("../")    # The directory immediately above should be project root
rm(current.dir)

# Setup project, scripts, and data directories
project.dir <- getwd()
scripts.dir <- "Scripts"
data.dir <- "Datasets"

# Set directory to datasets
setwd(file.path(project.dir, data.dir))

# Source import and wrangle files
source(file.path(project.dir, scripts.dir, "importdata.r"))
source(file.path(project.dir, scripts.dir, "gas_temp_wrangle.r"))

# Read in data
gas.data <- read_gas_data()
temp.data <- read_temp_data()

# Convert the data-specific null values to NA for QC
gas.data.converted <- gasdata.convert.na(gas.data)
temp.data.converted <- tempdata.convert.na(temp.data)

# Also include a "long" version of the temp.data.converted for convenience
temp.data.converted.long <- lapply(temp.data.converted, function(df) df %>%
                            pivot_longer(cols = "Jan":"Dec",
                                         names_to = "Month",
                                         values_to = "Temp_diff"))

# Wrangle the data to produce the desired moving subset dfs
gas.data.windowed.dfs <- wrangle_gasdata(gas.data)
temp.data.windowed.dfs <- wrangle_tempdata(temp.data)
