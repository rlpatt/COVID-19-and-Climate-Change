# co2.data <- read.delim("GLB.Ts+dSST.csv", skip = 1, header = TRUE)
# Data is not entirely in R-readable format
# There are random lines interspersed that are headers, not data
# Try to use awk to separate the data into files - didn't work
co2.data <- read.csv("test.csv", header = TRUE)

# Set dir to project dir
# NOTE: CHANGE THIS TO YOUR PROJECT DIRECTORY!
sproject.dir <- "C:/Users/jvons/Documents/NCF/Data_Munging_EDA/Project/"
data.dir <- "Datasets"
setwd(file.path(project.dir, data.dir))

# Read files using awk to parse data for only 2003 - present
# gas.data <- lapply(1:length(gas.files), function(x) system(paste("awk '{if ($1 > 2002) print $0}'", gas.files[[x]]), intern = TRUE))
# Note that trying to read.delim() from pipe was not working, and output can only be captured as a character vector with system()
    # pipe() was interpreting $1 > 2002 as a redirect

# Instead, used awk from the terminal:
# prefix=$(ls | sed -r "s/[.]txt//"); for name in ${prefix}; do awk '{if ($1 > 2002) print $0}' "${name}.txt" > "${name}-filtered.txt"; done

# Get list of gases of interest for which we have data
gas.list <- c("ch4", "n2o", "sf6")
gas.files <- lapply(gas.list, function(x) list.files(path = ".", pattern = paste0(x, ".*filtered\\.txt")))

# Read files into df
gas.data <- lapply(gas.files, fread)
names(gas.data) <- gas.list

# CH4 is in ppm, N2O is in ppb, SF6 is in ppt - standardize entries to ppb and rename entries
gas.colnames <- c("Year",
                  "Month",
                  "Year_Day_decimal",
                  "Average_ppb",
                  "Uncertainty_avg",
                  "Trend",
                  "Uncertainty_trend")
gas.data <- lapply(gas.data, function(x) setNames(x, gas.colnames))
gas.data$ch4$Average_ppb <- gas.data$ch4$Average_ppb * 1000
gas.data$sf6$Average_ppb <- gas.data$sf6$Average_ppb / 1000

# To do time-series analysis, we probably want to convert the Year/month cols into a single date col, e.g.,
# as.Date("2002-1-1", format = "%Y-%m-%d")
