library(forecast)
library(tseries)

### RUN ALL CHUNKS OF weekly_watch.Rmd FIRST ###

# Total Offenses by date
model_data <- df.crimes %>%
  group_by(date) %>%
  summarize(offenses = n())

# Calculate start, end numerical dates
start_date <- as.numeric(as.Date("2017-09-03") - as.Date("2017-01-01")) # First 2017 observed date
end_date <- as.numeric(as.Date("2020-03-21") - as.Date("2020-01-01")) # Last 2020 observed date
freq <- 365 # Time series frequency

### All data time series ###
ts.crimes <- ts(model_data, start = c(2017,start_date), end = c(2020,end_date), frequency = freq)

### Time series stationary? (p < 0.05) ###
adf.test(ts.crimes[,2])
kpss.test(ts.crimes[,2])

### 2017-2020 training data ###
train_start_date <- '2020-02-01'
train_end_date <- as.numeric(as.Date(train_start_date) - as.Date("2020-01-01"))
ts.crimes_train <- model_data %>% filter(date <= train_start_date)
ts.crimes_train <- ts(ts.crimes_train, start = c(2017,start_date), end = c(2020, train_end_date), frequency = freq)

### Modeling variables ###
forecast_days <- length(ts.crimes[,2]) - length(ts.crimes_train[,2])
forecast_levels <- c(0.8, 0.95, 0.99)



### Seasonal and Trend decomposition using Loess Forecasting (STLF) ###
# stlf_data <- stlf(ts.crimes_train[,2], h = forecast_days, level = forecast_levels)
# autoplot(stlf_data) + autolayer(ts.crimes[,2], series = "Observed") + xlim(c(2020.0, NA))

stlf_data <- stlf(ts.crimes_train[,2], level = forecast_levels) # Fit STLF
stlf_forecast <- forecast(stlf_data, h = forecast_days) # Forecast
autoplot(stlf_forecast, flwd = 1, fcol = "red") + 
  autolayer(ts.crimes[,2], series = "Observed") + 
  autolayer(stlf_forecast$mean, series = "Predicted") + 
  scale_color_manual(labels = c("Observed", "Predicted"),
                     values=c("black", "red")) +
  xlim(c(2020.0, NA))

# STLF model accuracy
accuracy(stlf_forecast, ts.crimes[,2])

# For Thiel's U see the following URL:
# https://docs.oracle.com/cd/E40248_01/epm.1112/cb_statistical/frameset.htm?ch07s02s03s04.html



### Holt Winters model ###
hw_data <- HoltWinters(ts.crimes_train[,2])
hw_forecast <- forecast(hw_data, h = forecast_days, findfrequency = TRUE, level = forecast_levels)
autoplot(hw_forecast, flwd = 1, fcol = "red") + 
  autolayer(ts.crimes[,2], series = "Observed") + 
  autolayer(hw_forecast$mean, series = "Predicted") + 
  scale_color_manual(labels = c("Observed", "Predicted"),
                     values=c("black", "red")) +
  xlim(c(2020.0, NA))

# HW model accuracy
accuracy(hw_forecast, ts.crimes[,2])



### Auto ARIMA model ###
auto_arima_data <- auto.arima(ts.crimes_train[,2], D=1)
arima.forecast <- forecast(auto_arima_data, h = forecast_days, level = forecast_levels)
autoplot(arima.forecast)

# Auto ARIMA model accuracy
accuracy(arima.forecast, ts.crimes[,2])
