library(readr)
weather_geg <- read_csv("weekly_watch/weather_geg.csv", 
                        col_types = cols_only(DATE = col_date(format = "%Y-%m-%d"), 
                                              PRCP = col_guess(), TAVG = col_guess(), 
                                              TMAX = col_guess()))
View(weather_geg)

colnames(weather_geg) <- c("date","prcp","tavg","tmax")

df.crime_daily <- df.crimes %>% 
  filter(date >= "2018-01-01") %>%
  group_by(date) %>%
  summarize(offenses = n())

df.weather_crime <- left_join(df.crime_daily, weather_geg, by = "date")

cor.test(df.weather_crime$offenses, df.weather_crime$tavg)
plot(df.weather_crime$offenses, df.weather_crime$tavg)

cor.test(df.weather_crime$offenses, df.weather_crime$tmax)
plot(df.weather_crime$offenses, df.weather_crime$tmax)

cor.test(df.weather_crime$offenses, df.weather_crime$prcp)
plot(df.weather_crime$offenses, df.weather_crime$prcp)
