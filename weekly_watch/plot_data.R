# Tally offenses by date
df.offenses_daily_totals <- setNames(
  data.frame(table(df.crimes$date)), 
  c("date", "total")
  )

# Total crime by district
total.crimes_district <- df.crimes %>%
  count(district) %>%
  mutate(
    "total" = n,
    "percentage" = (n / sum(n)) * 100
  )

# Total auto-involved crime by district
total.auto_district <-  aggregate(motor_vehicle_involved ~ district, df.crimes, sum)

# Total offenses by type
total.offense_types <- df.crimes %>%
  group_by(offense) %>%
  summarize(
    "total" = length(offense)
  )

df.plot_data <- df.crimes %>% 
  filter(!offense %in% c("Malicious Mischief", "Drugs"))
