library(readr)

# See https://geohub.cityoftacoma.org/datasets/tacoma-crime/explore for updated data

df.tacoma_crimes <- read_csv("data_files/Tacoma/Tacoma_Crime.csv")

# Date
df.tacoma_crimes$date <- as.POSIXct(df.tacoma_crimes$Occurred_On, format = "%Y/%m/%d")

# Daily summary data
Tacoma_Daily_Offenses <- df.tacoma_crimes %>%
  group_by(date) %>%
  summarize(offenses = n())
