library(tidyverse)
library(readr)

files = list.files(path = "./csv_files/", pattern = "\\.csv$", full.names = TRUE)
df.crimes = lapply(files, read_csv) %>% bind_rows()

df.crimes$date <- as.Date(df.crimes$date, "%m/%d/%Y")
df.crimes$ac <- as.factor(toupper(df.crimes$ac))
df.crimes$district <- as.factor(toupper(df.crimes$district))
df.crimes$offense <- as.factor(tolower(df.crimes$offense))

# Generate address list CSV
# df.crimes$city <- "Spokane"
# df.crimes$state <- "WA"
# df.crimes$zip <- ""
# 
# df.crimes %>%
#   filter(!is.na(address)) %>%
#   distinct() %>%
#   select(address, city, state, zip) %>%
#   write.csv(., 'addresses.csv')

table(df.crimes$district)
table(df.crimes$ac)
table(df.crimes$offense)

