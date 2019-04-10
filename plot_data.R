# Tally offenses by date
df.offenses_daily_totals <- setNames(
  data.frame(table(df.crimes$date)), 
  c("date", "total")
  )