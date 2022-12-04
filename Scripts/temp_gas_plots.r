# Mess around and find out - I want to do clustering
require(corrplot)
require(ComplexHeatmap)

# Test correlation between gas data
cor(gas.data.converted$ch4$Average_ppm, gas.data$n2o$Average_ppb)

# Create a function that will select only the "Year", "Month", and "Average_molefrac" columns
select_fun <- function(df) {
    return(df %>%
        select(contains(c("Year", "Month", "Average"))) %>%
        select(!contains("Day")))
}

# Subset each data frame, then use reduce from purr with left_join
# This will combine all the data frames by the common cols listed with "by"
# What reduce() does is apply a binary function .f that has a singl return value
# To join elements of a vector/list into a single value/object
# E.g., to reduce a vector 1:3, reduce() performs f(f(1,2), 3)
gas.data.list2 <- lapply(gas.data, select_fun)
combin.gas.df <- gas.data.list2 %>% purrr::reduce(left_join, by = c("Year", "Month"))

# Get columns which have the "Average" statistic using grep
# grep() will return the indices for which vector elements contain the target string
avg.cols <- grep("Average", colnames(combin.df))
colnames(combin.gas.df)[avg.cols] <- paste(colnames(combin.gas.df)[avg.cols], c("ch4", "n2o", "sf6"), sep = "_")



#------Combined temp data------#
# Get the average temperature anomaly per period
# For each df in each list, take the mean of "Temp_diff"
period.means <- lapply(temp.data.windowed.dfs, function(list.obj)
                                               lapply(list.obj, function(df)
                                                                mean(df[, "Temp_diff"])))

# Get the info from each df in each list of Month and Temp_diff
extract.avg.temp <- lapply(temp.data.windowed.dfs, function(list.obj)
                                                   lapply(list.obj, function(df)
                                                                    df %>% select(Month, Temp_diff)))

# This is giving weird behavior when I try and concat the dfs into one
# combin.temp.df <- lapply(extract.avg.temp, function(list.obj) list.obj %>% purrr::reduce(left_join, by = "Month"))

# Let's make a test run - I think maybe setting months to factor will help?
test.airsv6 <- extract.avg.temp[[1]]

# Use lapply() with data.table::set() to modify the df in-place to convert months from num to factor
# test.airsv6.factor <- lapply(test.airsv6, function(df) df %>% data.table::set(j = "Month", value = as.factor(df[, "Month"])))

# Still giving weird behavior. Let me try renaming the "Temp_diff" columns
# test.airsv6.combin <- test.airsv6.factor %>% purrr::reduce(left_join, by = "Month")
# temp.years <- names(test.airsv6)
# year.names <- paste("Temp_diff", temp.years, sep = "_")
# test.airsv6.rnmd <- lapply(seq_len(length(year.names)), function(i) setNames(test.airsv6[[i]], c("Month", year.names[i])))

# test.airsv6.combin <- test.airsv6.rnmd %>% purrr::reduce(left_join)

# Trying to ust left join above was not working well at all - will try a different, more dirty approach instead
temp.years <- names(test.airsv6)
year.names <- paste("Temp_diff", temp.years, sep = "_")
test.airsv6.rnmd <- lapply(seq_len(length(year.names)), function(i) setNames(test.airsv6[[i]], c("Month", year.names[i])))


test.airsv6.combin <- lapply(test.airsv6.rnmd, function(df) select(df, contains("Temp_diff"))) %>% as.data.frame()
test.airsv6.combin.month <- add_column(test.airsv6.combin, Month = test.airsv6[[1]]$Month, .before = "Temp_diff_2003.2005")

# Do some correlation plots - let's see what we find
test.airsv6.combin %>%
    cor() %>%
    corrplot(method = "shade", addCoef.col = "white", tl.col = "black")

test.airsv6.combin %>%
    cor(method = "spearman") %>%
    corrplot(method = "shade", addCoef.col = "white", tl.col = "black")

# Try heatmap
test.airsv6.z <- t(apply(test.airsv6.combin, 1, scale))
colnames(test.airsv6.z) <- colnames(test.airsv6.combin)

Heatmap(test.airsv6.z, cluster_rows = FALSE, cluster_columns = TRUE, column_labels = colnames(test.airsv6.z),
        name = "Z-score", row_labels = test.airsv6.combin.month$Month)

unname(unlist(test.airsv6.combin[1, , drop = TRUE])) %>% hist()


# Try to combine all temp data together into one df for corr analysis b/w tools
temp.combin <- lapply(temp.data.converted.long, select_fun) %>% purrr::reduce(left_join, by = c("Year", "Month"))
temp.combin %>%
    select_if(is.numeric) %>%
    select(!Year) %>%
    cor(use = "pairwise.complete.obs") %>%
    corrplot(method = "shade",
             type = "lower",
             diag = FALSE,
             addCoef.col = "white",
             tl.col = "black",
             order = "hclust")

# Heatmap with the OG converted data frames
# Make the rownames years so it's easier to keep track of them
temp.data.monthly <- lapply(temp.data.converted, function(df) df %>% select(contains(c(month.abb))))
for (i in 1:length(temp.data.monthly)) {
    rownames(temp.data.monthly[[i]]) <- temp.data.converted[[1]]$"Year"
}

# Use scale on the *columns* of temp.data.monthly since this data is in wide format
    # Want z-score of each year by month, not each month by year
t(apply(temp.data.monthly[[3]], 2, scale)) %>%
    Heatmap(cluster_columns = TRUE,
            cluster_rows = FALSE,
            row_labels = month.abb,
            column_labels = 2002:2022,
            name = "Z-score")

# Get Euclidean distances from each year
# dist() will take an array-like obj and return the pair-wise euclidean distance b/w each column
euc.dist.v4 <- dist(temp.data.monthly[["ghcnv4"]])
euc.dist.v4.mat <- as.matrix(euc.dist.v4)
euc.dist.v4.mat["2021", ][order(euc.dist.v4.mat["2021", ])]

# It seems that by Euclidean distance, 2018 is the closest year to 2021 by temp

# For each year, get nearest neighbor by Euclidean distance
# To do this, take the distance matrix, take each row and order from least to greatest
# Then, take the 2nd element (since the 1st element will always be the same year, with dist 0)
closest.year <- lapply(seq_len(nrow(euc.dist.v4.mat)), 
                       function(x) euc.dist.v4.mat[x, ][order(euc.dist.v4.mat[x, ])][2])
names(closest.year) <- 2002:2022
