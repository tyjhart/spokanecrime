library(forecast)
library(tseries)

# Total Offenses by date
model_data <- df.crimes %>%
  filter(category == "BUARGLARY") %>%
  group_by(date) %>%
  summarize(offenses = n())

# Calculate start, end numerical dates
start_date <- as.numeric(as.Date("2017-09-03") - as.Date("2017-01-01")) # First 2017 observed date
end_date <- as.numeric(as.Date("2020-04-18") - as.Date("2020-01-01")) # Last 2020 observed date
freq <- 365 # Time series frequency

### All data time series ###
ts.crimes <- ts(model_data, start = c(2017,start_date), end = c(2020,end_date), frequency = freq)

### Time series stationary? (p < 0.05) ###
# adf.test(ts.crimes[,2])
# kpss.test(ts.crimes[,2])

# Decompose time series
ts.crime_stl <- stl(ts.crimes[,2],"periodic") # Decompose time series
plot(ts.crime_stl, main = "Burglary Seasonal Decomposition")

ts.crime_sa <- seasadj(ts.crime_stl) # Adjust for seasonality
plot(ts.crime_sa, main = "Burglaries, Seasonally Adjusted")
