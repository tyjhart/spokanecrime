### Prune old / incomplete data ###
df.crimes <- df.crimes %>%
  filter(date >= "2017-08-01")

### Summarized daily offenses ###
daily_offenses <- df.crimes %>%
  group_by(date) %>%
  summarize(offenses = n())

write.csv(daily_offenses, file = "daily_offenses.csv")

daily_offenses_violence <- df.crimes %>%
  group_by(date, violence) %>%
  summarize(offenses = n())

write.csv(daily_offenses_violence, file = "daily_offenses_violence.csv")

# Summarized daily offenses by month
summarized_crimes <- df.crimes %>%
  group_by(year, num.month, num.day) %>%
  summarize(daily_offenses = n()) %>%
  group_by(year, num.month) %>%
  summarize(
    avg.daily_offenses = mean(daily_offenses), 
    sum.monthly_offenses = sum(daily_offenses)
  )

summarized_crimes$date <- with(summarized_crimes, paste(year, num.month, "01" ,sep="-"))
summarized_crimes$date <- as.Date(summarized_crimes$date, format = "%Y-%m-%d")
summarized_crimes <- subset(summarized_crimes, select = c(date, avg.daily_offenses, sum.monthly_offenses))

### Data for Modeling ###
model_data <- df.crimes %>%
  filter(date >= "2018-01-01") %>%
  group_by(date) %>%
  summarize(offenses = n())

# Modeling start, end numerical dates
start_date <- as.numeric(as.Date("2017-08-01") - as.Date("2017-01-01")) # First 2017 observed date
end_date <- as.numeric(max(model_data$date) - as.Date("2021-01-01")) # Last 2021 observed date

# Time series frequency
freq <- 365

# Time series data
ts.crimes <- ts(model_data, start = c(2018,1), end = c(2021,end_date), frequency = freq)