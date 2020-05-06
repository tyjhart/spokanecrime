library(lubridate)

# Weekly offense totals
totals.weekly <- df.crimes %>%
  group_by(week=floor_date(date, "week")) %>%
  summarize(total = n())

# plot(totals.weekly)
# totals.weekly %>% ggplot(aes(total)) +
  # geom_histogram(binwidth = 10)

# Average weekly offenses per year
avg.weekly <- totals.weekly %>%
  group_by(year=floor_date(week, "year")) %>%
  summarize(avg = round(mean(total)))

# SD of weekly offenses per year
sd.weekly <- totals.weekly %>%
  group_by(year=floor_date(week, "year")) %>%
  summarize(avg = round(sd(total)))
