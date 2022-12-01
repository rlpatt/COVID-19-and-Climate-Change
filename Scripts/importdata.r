library(data.table)

#-----Importing NOAA greenhouse gas data-----#

# Set dir to project dir
project.dir <- "C:/Users/jvons/Documents/NCF/Data_Munging_EDA/Project/"
data.dir <- "Datasets"
setwd(file.path(project.dir, data.dir))

# Read files using awk to parse data for only 2003 - present
# gas.data <- lapply(1:length(gas.files), function(x) system(paste("awk '{if ($1 > 2002) print $0}'", gas.files[[x]]), intern = TRUE))
# Note that trying to read.delim() from pipe was not working, and output can only be captured as a character vector with system()
    # pipe() was interpreting $1 > 2002 as a redirect
# Instead, used awk from the terminal. See filtergas.sh
# prefix=$(ls | sed -r "s/[.]txt//"); for name in ${prefix}; do awk '{if ($1 > 2002) print $0}' "${name}.txt" > "${name}-filtered.txt"; done

# Get list of gases of interest for which we have data
gas.list <- c("ch4", "n2o", "sf6")
gas.files <- lapply(gas.list, function(x) list.files(path = ".", pattern = paste0(x, ".*filtered\\.txt")))

# Read files into df list
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

# To do time-series analysis, we probably want to convert the Year/month cols into a single date col
# as.Date("2002-1-1", format = "%Y-%m-%d")

#-----Importing NASA GISTEMP data-----
# Hacky way of doing it, but it works - this is based on the output of fread()
# Namely, fread() stopped at line 24 because of the presence of a string character
# Reverse-engineer the datasets to read separately into dfs
# test <- fread("GLB.Ts+dSST.csv", skip = 1, header = TRUE)
# test2 <- fread("GLB.Ts+dSST.csv", skip = 24)
# test3 <- fread("GLB.Ts+dSST.csv", skip = 48)

# Instead, used awk (see parsetemp.sh) to split the files into 3 sub-csv files

temp.files <- list.files(path = ".", pattern = "nasa_gistemp_[123][.]csv")

# Read files into df list - skip first line, which is string description
temp.data <- lapply(temp.files, function(x) read.csv(x, skip = 1, header = TRUE))
names(temp.data) <- c("airsv6", "airsv7", "ghcnv4")
