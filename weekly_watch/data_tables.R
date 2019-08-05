### Data Tables ###
# Functionality to export table images. Kable "as_image" takes forever to run,
# so this functionality has been moved to a separate file.

### Districts ###
df.district_summary <- df.crimes %>%
  filter(date >= "2019-01-01") %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(
  df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3
  ) * 100

# Districts 2019 YTD
kable(
  df.district_summary[order(-df.district_summary$dist_sum),], 
  col.names = c("District", "Offenses", "Percentage"), 
  caption = "Statistics by District, 2019 YTD"
  ) %>% 
  kable_styling(
    bootstrap_options = c("condensed", "striped"), 
    full_width=FALSE, font_size=12
    ) %>%
  as_image(file = "./weekly_watch/figures/table.district_stats_ytd.png")

df.district_summary <- df.crimes %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(
  df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3
  ) * 100

# Districts Total
kable(
  df.district_summary[order(-df.district_summary$dist_sum),], 
  col.names = c("District", "Offenses", "Percentage"), 
  caption = "Statistics by District, September 12, 2017 Onward"
  ) %>%
  kable_styling(
    bootstrap_options = c("condensed", "striped"), 
    full_width=FALSE, 
    font_size=12
    ) %>%
  as_image(file = "./weekly_watch/figures/table.district_stats_total.png")

### All Offenses ###
df.monthly_summary <- df.crimes %>% 
  group_by(year, num.month) %>%
  summarize(total.offenses = n())

kable(
  spread(df.monthly_summary, key = year, value = total.offenses), 
  col.names = c("Month", 2017, 2018, 2019), 
  caption = "Total Offenses"
  ) %>% 
  kable_styling(
    bootstrap_options = c("condensed", "striped"), 
    full_width=FALSE, 
    font_size=12
    ) %>%
  as_image(file = "./weekly_watch/figures/table.offenses.png") 

### By Category ###
table_category_vec <- c(
  'ARSON',
  'ASSAULT',
  'BURGLARY',
  'MURDER',
  'RAPE',
  'ROBBERY',
  'TAKING MOTOR VEHICLE',
  'THEFT',
  'THEFT OF MOTOR VEHICLE',
  'VEHICLE PROWLING'
)

for (table_category in table_category_vec) {
  
  filename <- paste0("./weekly_watch/figures/table.",tolower(table_category),".png")

  df.monthly_summary <- df.crimes %>% 
    filter(category == table_category) %>%
    group_by(year, num.month) %>%
    summarize(total_count = n())
  
  kable(
    spread(df.monthly_summary, key = year, value = total_count), 
    col.names = c("Month", 2017, 2018, 2019), 
    caption = table_category
  ) %>% 
    kable_styling(
      bootstrap_options = c("condensed", "striped"), 
      full_width=FALSE, 
      font_size=12
    ) %>%
    as_image(file = filename)
}

### By Theft Subcategory ###
table_subcategory_vec <- c(
  'Shoplifting',
  'Firearm'
)

for (table_subcategory in table_subcategory_vec) {
  
  filename <- paste0("./weekly_watch/figures/table.theft_",tolower(table_subcategory),".png")
  
  df.monthly_summary <- df.crimes %>% 
    filter(category == 'THEFT' & subcategory == table_subcategory) %>%
    group_by(year, num.month) %>%
    summarize(total_count = n())
  
  kable(
    spread(df.monthly_summary, key = year, value = total_count), 
    col.names = c("Month", 2017, 2018, 2019), 
    caption = paste0(table_subcategory, " Thefts")
  ) %>% 
    kable_styling(
      bootstrap_options = c("condensed", "striped"), 
      full_width=FALSE, 
      font_size=12
    ) %>%
    as_image(file = filename)
}