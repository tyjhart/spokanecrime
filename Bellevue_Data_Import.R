library(readr)

# See https://bellevuewa.gov/city-government/departments/police/police-data for updated data

df.bellevue_crimes <- read_csv("data_files/Bellevue/Crime_Cases_By_100_Block.csv")

# Clean, parse datetime and dates
df.bellevue_crimes$Occurred_From_Date <- gsub("\\+00","",df.bellevue_crimes$Occurred_From_Date)
df.bellevue_crimes$Occurred_From_Date <- as.POSIXlt(df.bellevue_crimes$Occurred_From_Date, format = "%Y/%m/%d %H:%M:%S")
df.bellevue_crimes$date <- as.Date(df.bellevue_crimes$Occurred_From_Date)
df.bellevue_crimes$dow <- as.factor(weekdays(df.bellevue_crimes$date))

# Normalize offenses
df.bellevue_crimes$Keyword <- gsub("MV theft", "Theft of Motor Vehicle", df.bellevue_crimes$Keyword)
df.bellevue_crimes$Keyword <- gsub("MV prowl", "Motor Vehicle Prowling", df.bellevue_crimes$Keyword)
df.bellevue_crimes$Keyword <- gsub("Drugs/VUCSA", "Drugs", df.bellevue_crimes$Keyword)
df.bellevue_crimes$Keyword <- gsub("Public morals; offenses against", "Indecency", df.bellevue_crimes$Keyword)

# Daily summary data
Bellevue_Daily_Offenses <- df.bellevue_crimes %>%
  filter(date >= "2017-01-01") %>%
  group_by(date) %>%
  summarize(offenses = n())
