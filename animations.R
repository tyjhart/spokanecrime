library(gganimate)

### 2019 ###
data <- df.crimes %>%
  filter(year == 2019) %>%
  group_by(num.month, dow) %>%
  count(dow)

data$num.month <- as.numeric(as.character(data$num.month))

dow_2019_offenses <- ggplot(data, aes(fct_relevel(dow,"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"), n)) +
  geom_col() +
  labs(
    x = '', 
    y = 'Monthly Offenses',
    caption = "SOURCE: Spokane Police Department CompStat"
  ) +
  transition_time(num.month) +
  ease_aes('linear')

monthly_dow_anim <- animate(dow_2019_offenses, nframes = 120, fps = 10, end_pause = 30)
anim_save("dow_total_by_month_2019.gif", monthly_dow_anim, path = './figures/')
