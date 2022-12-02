# Moving window function, which will subset a df into a list of dfs by desired month cycle
df_window_subset <- function(df, init.year.wind = 2003, wind.size = 2, final.init.year = 2019) {
    moving.dfsub.list <- list()
    while (init.year.wind <= final.init.year) {
        end.year.wind <- init.year.wind + wind.size
        # Filter for only years in the current window
        # Then filter for only December, year X to Jul, year X + 2
        moving.df <- df %>%
                        filter(Year >= init.year.wind & Year <= end.year.wind) %>%
                        filter(!((Year == init.year.wind & Month < 12) | (Year == end.year.wind & Month > 7)))
        moving.dfsub.list[[paste(init.year.wind, end.year.wind, sep = "-")]] <- as.data.frame(moving.df)
        init.year.wind <- init.year.wind + wind.size
    }
    return(moving.dfsub.list)
}

# Adds a column of Date objects to a df from cols named Year and Month. Assumes day is constant (1 by default)
add_date_col <- function(df, day = 1) {
    df <- df %>% mutate(Date = as.Date(paste(Year, Month, day, sep = "-"),
                                       format = "%Y-%m-%d"))
    return(df)
}

tempdata.convert.na <- function(data.list) {
    # For each data frame of temp.data, take each column and replace ***** with NA
    data.list.na <- lapply(data.list,
                        function(df) as.data.frame(lapply(df, function(x) as.numeric(gsub(x, pattern = "\\*.*",
                                                                                     replacement = NA)))))
    return(data.list.na)
}

wrangle_tempdata <- function(temp.data) {
    # Need to convert asterisk values to NA in order to convert the data to long format
    # pivot_longer() cannot combine columns that are of diff atomic types
    # Use defined tempdata.convert.na above to accomplish this
    temp.data.na <- tempdata.convert.na(temp.data)

    # Convert data to long format to allow for date-based time series plot
    temp.data.long <- lapply(temp.data.na, function(df) df %>%
                            pivot_longer(cols = "Jan":"Dec",
                                         names_to = "Month",
                                         values_to = "Temp_diff"))

    # Converting month abbv to numeric
    # Use data.table::set() to modify col j of the df in place for use in lapply - avoids requiring for loop
    # Sets the value of col j to that given by the value argument
    lapply(temp.data.long, function(df) set(df, j = "Month", value = match(df$"Month", month.abb)))

    # Add Date object column for time series analysis
    temp.data.date <- lapply(temp.data.long, add_date_col)

    # For each data frame in temp.data.long, create the windowed subset df
    # This produces for each df, a list of sub-dfs
    # Sub-dfs can be indexed by, e.g., list$airsv6$"2003-2005"
    windowed.df.list <- lapply(temp.data.date, df_window_subset)
    return(windowed.df.list)
}

gasdata.convert.na <- function(data.list) {
    # Use replace_with_na() from  packagenaniar to replace values of -9.99 with NA
    # See https://cran.r-project.org/web/packages/naniar/vignettes/replace-with-na.html
    if (!require(naniar)) {
        install.packages("naniar", quietly = TRUE)
    }
    data.list.na <- lapply(data.list, function(df) df %>%
                            replace_with_na(replace = list(Uncertainty_avg = -9.99,
                                                           Uncertainty_trend = -9.99)))
    return(data.list.na)
}

wrangle_gasdata <- function(gas.data) {
    # Replace -9.99 values with NA using gasdata.convert.na() function above
    gas.data.na <- gasdata.convert.na(gas.data)
    gas.data.date <- lapply(gas.data.na, add_date_col)
    gas.data.windowed.list <- lapply(gas.data.date, df_window_subset)
    return(gas.data.windowed.list)
}