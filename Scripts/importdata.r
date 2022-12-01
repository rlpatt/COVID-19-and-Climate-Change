#-----Importing NOAA greenhouse gas data-----#
# Used awk (see filtergas.sh) to pre-filter NOAA greenhouse gas data for 2003 - present

read_gas_data <- function() {
    # Get list of gases of interest for which we have data
    gas.list <- c("ch4", "n2o", "sf6")
    gas.files <- lapply(gas.list, function(x) list.files(path = ".", pattern = paste0(x, ".*filtered\\.txt")))

    # Read files into df list
    gas.data <- lapply(gas.files, fread)
    names(gas.data) <- gas.list

    # CH4 is in ppm, N2O is in ppb, SF6 is in ppt - rename all colnames just to ppb first
    gas.colnames <- c("Year",
                    "Month",
                    "Year_Day_decimal",
                    "Average_ppb",
                    "Uncertainty_avg",
                    "Trend",
                    "Uncertainty_trend")
    gas.data <- lapply(gas.data, function(x) setNames(x, gas.colnames))

    # Now rename colnames for ch4 and sf6 
    ppb.col <- which(gas.colnames == "Average_ppb")
    colnames(gas.data$ch4)[ppb.col] <- "Average_ppm"
    colnames(gas.data$sf6)[ppb.col] <- "Average_ppt"
    return(gas.data)
}

#-----Importing NASA GISTEMP data-----#
# Used awk (see parsetemp.sh) to split the files into 3 sub-csv files

read_temp_data <- function() {
    temp.files <- list.files(path = ".", pattern = "nasa_gistemp_[123][.]csv")

    # Read files into df list - skip first line, which is string description
    temp.data <- lapply(temp.files, function(x) read.csv(x, skip = 1, header = TRUE))
    names(temp.data) <- c("airsv6", "airsv7", "ghcnv4")
    return(temp.data)
}