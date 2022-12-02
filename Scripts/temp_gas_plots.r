# Mess around and find out - I want to do clustering
require(corrplot)

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
combin.df <- gas.data.list2 %>% purrr::reduce(left_join, by = c("Year", "Month"))

# Get columns which have the "Average" statistic using grep
# grep() will return the indices for which vector elements contain the target string
avg.cols <- grep("Average", colnames(combin.df))
colnames(combin.df)[avg.cols] <- paste(colnames(combin.df)[avg.cols], c("ch4", "n2o", "sf6"), sep = "_")



#------Combined temp data------#
lapply(temp.data.windowed.dfs, function(list.obj)
                              lapply(list.obj, function(df)
                                                mean(df[, "Temp_diff"])))
