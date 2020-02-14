### Data Tables ###
# Functionality to export table images. Kable "as_image" takes forever to run,
# so this functionality has been moved to a separate file.

### Annual totals ###
df.annual_totals <- df.crimes %>%
  filter(year != 2017) %>%
  group_by(year) %>%
  summarize(annual_total = n())

kable(
  df.annual_totals,
  col.names = c("Year", "Total"), 
  caption = "Annual Totals"
  ) %>%
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
  ) %>%
  as_image(file = "./weekly_watch/figures/table.annual_totals.png")

# Totals by category
df.annual_category_totals <- df.crimes %>%
  group_by(year,category) %>%
  {table(.$year,.$category)}

kable(
  df.annual_category_totals,
  caption = "Annual Totals"
) %>%
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
  ) %>%
  as_image(file = "./weekly_watch/figures/table.annual_category_totals.png")







### Districts ###
df.district_summary <- df.crimes %>%
  filter(date >= "2020-01-01") %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(
  df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3
  ) * 100

# Districts 2019 YTD
kable(
  df.district_summary[order(-df.district_summary$dist_sum),], 
  col.names = c("District", "Offenses", "Percentage"), 
  caption = "Districts, 2020 YTD"
  ) %>% 
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
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
  caption = "Districts, All Years"
  ) %>%
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, 
    font_size=12
    ) %>%
  as_image(file = "./weekly_watch/figures/table.district_stats_total.png")

# District, category proportion tables by year
# See https://stackoverflow.com/questions/45385897/how-to-round-all-the-values-of-a-prop-table-in-r-in-one-line,
# https://stackoverflow.com/questions/44528173/using-table-in-dplyr-chain

table_year_vec <- c(2020,2019,2018,2017)

for (table_year in table_year_vec) {
  
  filename <- paste0("./weekly_watch/figures/table.",tolower(table_year),"_district_category_proportion.png")
  
  kable(
    df.crimes %>% 
      filter(year == table_year) %>% 
      {table(.$district,.$category)} %>% 
      prop.table(margin = 2) %>% `*` (100) %>% round(2)
  ) %>% 
    kable_styling(
      bootstrap_options = c("bordered", "condensed", "striped"), 
      full_width=FALSE, font_size=12
    ) %>%
    as_image(file = filename)
}

### All Offenses ###
df.monthly_summary <- df.crimes %>% 
  group_by(year, num.month) %>%
  summarize(total.offenses = n())

kable(
  spread(df.monthly_summary, key = year, value = total.offenses), 
  col.names = c("Month", 2017, 2018, 2019, 2020), 
  caption = "Total Offenses"
  ) %>% 
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
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
  'TAKING VEH.',
  'THEFT',
  'VEH. THEFT',
  'VEH. PROWLING'
)

for (table_category in table_category_vec) {
  
  filename <- paste0("./weekly_watch/figures/table.",tolower(table_category),".png")

  df.monthly_summary <- df.crimes %>% 
    filter(category == table_category) %>%
    group_by(year, num.month) %>%
    summarize(total_count = n())
  
  tryCatch(
    kable(
      spread(df.monthly_summary, key = year, value = total_count), 
      col.names = c("Month", 2017, 2018, 2019, 2020), 
      caption = str_to_title(table_category, locale = "en")
    ),
    error = function(e) kable(
      spread(df.monthly_summary, key = year, value = total_count), 
      col.names = c("Month", 2017, 2018, 2019), 
      caption = str_to_title(table_category, locale = "en")
    ) 
  ) %>%
    kable_styling(
      bootstrap_options = c("bordered", "condensed", "striped"), 
      full_width=FALSE, 
      font_size=12
    ) %>%
    as_image(file = filename)
  
  # tryCatch(lm(formula1, data), error = function(e) lm(formula2, data))
  # 
  # kable(
  #   spread(df.monthly_summary, key = year, value = total_count), 
  #   col.names = c("Month", 2017, 2018, 2019, 2020), 
  #   caption = str_to_title(table_category, locale = "en")
  # ) %>% 
  #   kable_styling(
  #     bootstrap_options = c("bordered", "condensed", "striped"), 
  #     full_width=FALSE, 
  #     font_size=12
  #   ) %>%
  #   as_image(file = filename)
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
    col.names = c("Month", 2017, 2018, 2019, 2020), 
    caption = paste0(str_to_title(table_subcategory, locale = "en"), " Thefts")
  ) %>% 
    kable_styling(
      bootstrap_options = c("bordered", "condensed", "striped"), 
      full_width=FALSE, 
      font_size=12
    ) %>%
    as_image(file = filename)
}