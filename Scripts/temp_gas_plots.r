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
