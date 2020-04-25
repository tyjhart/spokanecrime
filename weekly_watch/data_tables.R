### Data Tables ###
# Functionality to export table images. Kable "as_image" takes forever to run,
# so this functionality has been moved to a separate file.

# Data table source note
boilerplate_caption <- "SOURCE: Spokane Police Department CompStat"
cc_by_sa <- "Licensed CC-BY-SA 4.0, Tyler Hart"
boilerplate_caption <- paste(boilerplate_caption, cc_by_sa, sep = "\n")

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
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./weekly_watch/figures/table.annual_totals.png")



### Totals by category ###
df.annual_category_totals <- df.crimes %>%
  group_by(year,category) %>%
  {table(.$year,.$category)}

df.annual_category_totals <- df.annual_category_totals[-1,]

kable(
  df.annual_category_totals,
  caption = "Annual Totals"
) %>%
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
  ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./weekly_watch/figures/table.annual_category_totals.png")



### Totals by violence ###
df.annual_violence_totals <- df.crimes %>%
  group_by(year,violence) %>%
  {table(.$year,.$violence)}

df.annual_violence_totals <- df.annual_violence_totals[-1,]

kable(
  df.annual_violence_totals,
  caption = "Annual Non-Violent, Violent Offense Totals"
) %>%
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
  ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./weekly_watch/figures/table.annual_violence_totals.png")



### Districts ###
df.district_summary <- df.crimes %>%
  filter(date >= "2020-01-01") %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(
  df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3
  ) * 100

# Districts 2020 YTD
kable(
  df.district_summary[order(-df.district_summary$dist_sum),], 
  col.names = c("District", "Offenses", "Percentage"), 
  caption = "Police District Offenses, 2020 YTD"
  ) %>% 
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
    ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
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
  caption = "Police Districts, All Years"
  ) %>%
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, 
    font_size=12
    ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./weekly_watch/figures/table.district_stats_total.png")

# District non-violent, violent percentages
kable(
  df.crimes %>% 
    {table(.$district,.$violence)} %>% 
    prop.table(margin = 2) %>% `*` (100) %>% round(2),
  col.names = c("Non-Violent (%)", "Violent (%)"),
  caption = "Police District Violence Percentages"
) %>% 
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
  ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./weekly_watch/figures/table.district_violence_proportion.png")

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
    add_footnote(boilerplate_caption, notation = "none") %>%
    as_image(file = filename)
}

for (table_year in table_year_vec) {
  
  filename <- paste0("./weekly_watch/figures/table.",tolower(table_year),"_district_violence_proportion.png")
  
  kable(
    df.crimes %>% 
      filter(year == table_year) %>% 
      {table(.$district,.$violence)} %>% 
      prop.table(margin = 2) %>% `*` (100) %>% round(2)
  ) %>% 
    kable_styling(
      bootstrap_options = c("bordered", "condensed", "striped"), 
      full_width=FALSE, font_size=12
    ) %>%
    add_footnote(boilerplate_caption, notation = "none") %>%
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
  add_footnote(boilerplate_caption, notation = "none") %>%
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
  'VEH. PROWL'
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
    add_footnote(boilerplate_caption, notation = "none") %>%
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
    add_footnote(boilerplate_caption, notation = "none") %>%
    as_image(file = filename)
}