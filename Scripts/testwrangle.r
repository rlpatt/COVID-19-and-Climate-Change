library(tidyverse)
library(reshape)

# Source import file
file.loc <- "C:/Users/jvons/Documents/NCF/Data_Munging_EDA/Project/Scripts"
file.name <- "importgas.r"
source(file.path(file.loc, file.name))

test <- as.data.frame(temp.data[[1]])

# Need to convert asterisk values to NA in order to convert the data to long format
# pivot_longer() cannot combine columns that are of diff atomic types
test <- as.data.frame(lapply(test, function(x) gsub(x, pattern = "\\*.*", replacement = NA)))

# First convert data to long format
test.long <- test %>%
              pivot_longer(cols = "Jan":"Dec",
                           names_to = "Month",
                           values_to = "Temp_diff")

# Converting month abbv to numeric
test.long$"Month" <- match(test.long$"Month", month.abb)

# Create "moving window" - Dec year X to Jul year X + 2
moving.dfsub.list <- list()
init.year.wind <- 2003
wind.size <- 2
final.init.year <- 2019

while (init.year.wind <= final.init.year) {
    end.year.wind <- init.year.wind + wind.size
    moving.df <- test.long %>%
                    filter(Year >= init.year.wind & Year <= end.year.wind) %>%
                    filter(!((Year == init.year.wind & Month < 12) | (Year == end.year.wind & Month > 7)))
    moving.dfsub.list[[paste(init.year.wind, end.year.wind, sep = "-")]] <- as.data.frame(moving.df)
    init.year.wind <- init.year.wind + wind.size
}

# Use month and year column to instead create a date format
test.long.date <- test.long %>%
                    mutate(Date = as.Date(paste(Year, Month, "1", sep = "-"),
                                                      format = "%Y-%m-%d"),
                           .keep = "unused")