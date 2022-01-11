### Data Tables ###
# Functionality to export table images. Kable "as_image" takes forever to run,
# so this functionality has been moved to a separate file.

# Data table source note
boilerplate_caption <- "Data Source: Spokane Police Department CompStat"
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
  save_kable(., file = "./figures/table.annual_totals.png")


### Annual totals by offense ###
df.annual_offense_totals <- df.crimes %>%
  group_by(year,offense) %>%
  {table(.$year,.$offense)}

df.annual_offense_totals <- df.annual_offense_totals[-1,]

kable(
  df.annual_offense_totals,
  caption = "Annual Totals"
) %>%
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
  ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./figures/table.annual_offense_totals.png")



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
  as_image(file = "./figures/table.annual_violence_totals.png")



### Districts ###

# Districts 2022 YTD
df.district_summary <- df.crimes %>%
  filter(date >= "2022-01-01") %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(
  df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3
) * 100

kable(
  df.district_summary[order(-df.district_summary$dist_sum),], 
  col.names = c("District", "Offenses", "Percentage"), 
  caption = "Police District Offenses, 2021 YTD"
  ) %>% 
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
    ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./figures/table.district_stats_ytd.png")



# Districts total, all years
df.district_summary <- df.crimes %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(
  df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3
) * 100

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
  as_image(file = "./figures/table.district_stats_total.png")

# District non-violent, violent percentages
kable(
  df.crimes %>% 
    {table(.$district,.$violence)} %>% 
    prop.table(margin = 2) %>% `*` (100) %>% round(2),
  col.names = c("Non-Violent %", "Violent %"),
  caption = "Police District Violence Percentages"
) %>% 
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, font_size=12
  ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./figures/table.district_violence_proportion.png")

# District, offense proportion tables by year
# See https://stackoverflow.com/questions/45385897/how-to-round-all-the-values-of-a-prop-table-in-r-in-one-line,
# https://stackoverflow.com/questions/44528173/using-table-in-dplyr-chain

table_year_vec <- c(2022,2021,2020,2019,2018,2017)

for (table_year in table_year_vec) {
  
  filename <- paste0("./figures/table.",tolower(table_year),"_district_offense_proportion.png")
  
  kable(
    df.crimes %>% 
      filter(year == table_year) %>% 
      {table(.$district,.$offense)} %>% 
      prop.table(margin = 2) %>% `*` (100) %>% round(2),
    caption = paste(table_year,"Police District Violence Percentages",sep = " ")
  ) %>% 
    kable_styling(
      bootstrap_options = c("bordered", "condensed", "striped"), 
      full_width=FALSE, font_size=12
    ) %>%
    add_footnote(boilerplate_caption, notation = "none") %>%
    as_image(file = filename)
}

for (table_year in table_year_vec) {
  
  filename <- paste0("./figures/table.",tolower(table_year),"_district_violence_proportion.png")
  
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



### All Offenses by year, month ###
df.monthly_summary <- df.crimes %>% 
  group_by(year, num.month) %>%
  summarize(total.offenses = n())

kable(
  spread(df.monthly_summary, key = year, value = total.offenses), 
  col.names = c("Month", 2017, 2018, 2019, 2020, 2021, 2022), 
  caption = "Total Offenses"
  ) %>% 
  kable_styling(
    bootstrap_options = c("bordered", "condensed", "striped"), 
    full_width=FALSE, 
    font_size=12
    ) %>%
  add_footnote(boilerplate_caption, notation = "none") %>%
  as_image(file = "./figures/table.offenses.png") 



### By offense ###
table_offense_vec <- c(
  'ARSON',
  'ASSAULT',
  'BURGLARY',
  'DRIVE-BY',
  'MURDER',
  'RAPE',
  'ROBBERY',
  'TAKING VEH.',
  'THEFT',
  'VEH. THEFT'
)

for (table_offense in table_offense_vec) {
  
  filename <- paste0("./figures/table.",tolower(table_offense),".png")

  df.monthly_summary <- df.crimes %>% 
    filter(offense == table_offense) %>%
    group_by(year, num.month) %>%
    summarize(total_count = n())
  
  tryCatch(
    kable(
      spread(df.monthly_summary, key = year, value = total_count), 
      col.names = c("Month", 2017, 2018, 2019, 2020, 2021, 2022), 
      caption = str_to_title(table_offense, locale = "en")
    ),
    error = function(e) kable(
      spread(df.monthly_summary, key = year, value = total_count), 
      col.names = c("Month", 2017, 2018, 2019, 2020, 2021), 
      caption = str_to_title(table_offense, locale = "en")
    ) 
  ) %>%
    kable_styling(
      bootstrap_options = c("bordered", "condensed", "striped"), 
      full_width=FALSE, 
      font_size=12
    ) %>%
    add_footnote(boilerplate_caption, notation = "none") %>%
    as_image(file = filename)
}
