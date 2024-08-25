# https://download.bls.gov/pub/time.series/cu/
df.CPI <- read.delim('./cpi/cu.data.0.Current.txt', header = TRUE)

# Period (month)
df.CPI$period <- str_remove(df.CPI$period, 'M0')
df.CPI$period <- str_remove(df.CPI$period, 'M')

# Make a proper date
df.CPI$Date <- NA
df.CPI$Date <- as.Date(ISOdate(df.CPI$year, df.CPI$period, 1))

# CPI value
df.CPI$value <- trimws(df.CPI$value)
df.CPI$value <- as.numeric(df.CPI$value)

# Item ID
df.CPI$series_id <- trimws(df.CPI$series_id)

# Item codes of interest ####
# Energy, West: CUUR0400SA0E
# Recreation, West: CUUR0400SAR
# Snacks, All locations: CUUR0000SEFT03
# Primary shelter rent: CUUR0400SEHA

df.CPIPasta <- df.CPI %>%
  filter(series_id == "CUUR0000SEFA02" & Date >= "2017-08-01")


df.Theft <- df.crimes %>%
  filter(offense == "THEFT") %>%
  mutate(MonthDate = floor_date(date, unit = "months")) %>%
  group_by(MonthDate) %>%
  summarize(Incidents = n())

CorTemp <- merge(df.Theft, df.CPIPasta, by.x = "MonthDate", by.y = "Date")
CorTemp$LaggedIncidents <- lag(CorTemp$Incidents,12)
plot(CorTemp$LaggedIncidents, CorTemp$value)

cor(CorTemp$LaggedIncidents, CorTemp$value, use = "complete.obs")
