# Get location of scripts folder and wrangle script
script.loc <- "C:/Users/jvons/Documents/NCF/Data_Munging_EDA/Project/Scripts"
script.name <- "gas_temp_wrangle.r"

# Source script file
source(file.path(script.loc, script.name))

# Run wrangle functions to obtain lists of data frames
gas.list.df <- wrangle_gasdata()
temp.list.df <- wrangle_tempdata()

print(getSrcDirectory(function(x) {x}))

# Mess around and find out - I want to do clustering
require(corrplot)
cor(gas.data$ch4$Average_ppb, gas.data$n2o$Average_ppb)
test1 <- gas.data[[1]]

select_fun <- function(df) {
    return(df %>%
        select(contains(c("Year", "Month", "Average"))) %>%
        select(!contains("Day")))
}

gas.data.list2 <- lapply(gas.data, select_fun)
combin.df <- gas.data.list2 %>% purrr::reduce(left_join, by = c("Year", "Month"))
combin.df
