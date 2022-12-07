# How did the COVID-19 Lockdown Affect Markers of Climate Change?

### Authors
Saurav Kiri, Logan Patterson, Aaron Spielman, Sujit Sivadanam

## Overview

This GitHub repository contains the data and scripts used to analyze changes in average monthly greenhouse gas atmospheric concentrations (CH<sub>4</sub>, N<sub>2</sub>O, and SF<sub>6</sub>) as well as average monthly temperature anomalies during the COVID-19 period (defined as **December 2019 - July 2021**) relative to comparable windows of time.

## Getting started

To begin, first clone this GitHub repository. Open a Windows command prompt (or shell, for *nix/macOS users) and use `git clone` to create a local copy of this repository on your machine. Optionally, you may first use `cd` to change into a directory of choice:

```
cd <directory of choice>
git clone https://github.com/rlpatt/Data_Munging
```

This will create a folder called "Data_Munging" in the current directory of the terminal. Inside of these folders are a "Datasets" folder, containing the data required to load into R, as well as a "Scripts" folder which will contain all the necessary scripts for reproducing our analyses.

Already cloned this repository, but looking to update to the newest version? Use `git pull` from the "Data_Munging" directory:

```
git pull origin main
```

## Setting up in R

After cloning the repository, open the "setup.r" file and run this file. You should not need to make any edits for this file to run successfully. This file will do a number of things:

* Load any required packages
* Set up the working directory on your machine
* Source the `importdata.r` and `gas_temp_wrangle.r` files to set-up the data for analysis
* Utilize the functions in each file to:
    + Load the data into the working directory as a list of data frames
    + Re-factor the data frames so that specially encoded null values are set to `NA` and return these data frames to your global environment
    + Add the split-windowed data frames to your local directory (see `gas_temp_wrangle.r` for more details)

All objects can be called from any other script following the exectuion of `setup.r`. Refer to the variable names in `setup.r` for your specific use.

## Plotting notebooks
Some plotting notebooks are available for viewing in the "Reports" folder. These notebooks include figures used in the final report as well as some basic discussion of methods and interpretations. To run these interactive notebooks, ensure that when launching the `.Rmd` file, the `setup.RData` file is in the same directory as the notebook. This `.RData` file is loaded by the notebook, and allows for simplification of the notebook at the source level. Some plots are freely interactive, as is the nearest neighbor table at the end of the `temp_plots.Rmd` file.