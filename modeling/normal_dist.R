library(forecast)

a <- df.crimes %>%
  mutate(month = format(date, "%m"), year = format(date, "%Y"), day = format(date, "%d")) %>%
  group_by(year, month, day) %>%
  summarise(total.day = n())

hist(a$total.day) # Plot a histogram
gghistogram(a$total.day, add.normal = TRUE)
shapiro.test(a$total.day) # Normal dist if p > 0.5
qqnorm(a$total.day) # Plot a QQPlot