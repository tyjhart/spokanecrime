### Data Tables ###
# Functionality to export table images. Kable "as_image" takes forever to run,
# so this functionality has been moved to a separate file.

# Variables
spokane_population <- 222050

# Data table source notes
boilerplate_caption <- "Data Source: Spokane Police Department CompStat"
cc_by_sa <- "Licensed CC-BY-SA 4.0, Tyler Hart"
boilerplate_caption <- paste(boilerplate_caption, cc_by_sa, sep = "\n")

### Annual totals ###
df.annual_totals <- df.crimes %>%
  filter(year != 2017) %>%
  group_by(year) %>%
  summarize(Total = n()) %>%
  mutate(`Percentage Change`=round(((Total - lag(Total,1)) / lag(Total,1)) * 100, 2),`Per Capita (100k)` = round((Total / spokane_population) * 100000)) %>%
  rename(Year = year, `Total Incidents` = Total)

# Void calculations for current year
df.annual_totals[which(df.annual_totals$Year == lubridate::year(Sys.Date())),]$`Percentage Change` <- NA
df.annual_totals[which(df.annual_totals$Year == lubridate::year(Sys.Date())),]$`Per Capita (100k)` <- NA

# Markdown table
kable(df.annual_totals, format = "markdown") %>%
  save_kable(., file = "./figures/markdown_table.annual_totals.md")

kable(
  df.annual_totals,
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

# Markdown table
kable(df.annual_offense_totals, format = "markdown") %>%
  save_kable(., file = "./figures/markdown_table.annual_offense_totals.md")

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

# Markdown table
kable(df.annual_violence_totals, format = "markdown") %>%
  save_kable(., file = "./figures/markdown_table.annual_violence_totals.md")

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
  summarize(dist_sum = n()) %>%
  mutate(percentage = round(dist_sum / sum(dist_sum),3) * 100) %>%
  rename(District = district, Total = dist_sum, Percentage = percentage) %>%
  arrange(desc(Total))

kable(df.district_summary, format = "markdown") %>%
  save_kable(., file = "./figures/markdown_table.district_stats_ytd.md")

kable(
  df.district_summary, 
  caption = "Police District Offenses, 2022 YTD"
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
  summarize(dist_sum = n()) %>%
  mutate(percentage = round(dist_sum / sum(dist_sum),3) * 100) %>%
  rename(District = district, Total = dist_sum, Percentage = percentage) %>%
  arrange(desc(Total))

kable(df.district_summary, format = "markdown") %>%
  save_kable(., file = "./figures/markdown_table.district_stats.md")

kable(
  df.district_summary, 
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

table_year_vec <- c(2022:2017)

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
#
# Offense vector for table creation
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

# Annual counts per offense
df.annual_offense_totals <- df.crimes %>%
  filter(year != 2017) %>%
  group_by(offense, year) %>%
  summarize(Total = n())

# Build monthly count table
offense_annual_month_counts <- df.crimes %>% 
  count(offense, num.month, year) %>% 
  spread(year, n, fill = NA)

names(offense_annual_month_counts)[names(offense_annual_month_counts) == "num.month"] <- "Month"

for (table_offense in table_offense_vec) {
  
  # File names
  filename <- paste0("./figures/table.",tolower(table_offense),".png")
  markdown_filename <- paste0("./figures/markdown_table_monthly.",tolower(table_offense),".md")
  markdown_filename_annual <- paste0("./figures/markdown_table_annual.",tolower(table_offense),".md")
  
  # Annual offense totals and change
  working_annual_offense_totals <- df.annual_offense_totals %>%
    filter(offense == table_offense) %>%
    mutate(Change=round(((Total - lag(Total,1)) / lag(Total,1)) * 100, 2), `Per Capita (100k)` = round((Total / spokane_population) * 100000)) %>%
    rename(Year = year, `Annual % Change` = Change, `Total Incidents` = Total) %>%
    ungroup() %>%
    select(., -c(offense)) 
  
  # Void percentage change calculation for current year
  working_annual_offense_totals[which(working_annual_offense_totals$Year == lubridate::year(Sys.Date())),]$`Annual % Change` <- NA
  working_annual_offense_totals[which(working_annual_offense_totals$Year == lubridate::year(Sys.Date())),]$`Per Capita (100k)` <- NA
  
  working_annual_offense_totals %>%
    kable(., format = "markdown") %>%
    save_kable(., file = markdown_filename_annual)
  
  # Filter for offense
  df.monthly_summary <- offense_annual_month_counts %>% 
    filter(offense == table_offense)
  
  # Markdown table
  kable(df.monthly_summary[-1], format = "markdown") %>%
    save_kable(., file = markdown_filename)
  
  kable(df.monthly_summary[-1], caption = str_to_title(table_offense, locale = "en")) %>%
    kable_styling(
      bootstrap_options = c("bordered", "condensed", "striped"), 
      full_width=FALSE, 
      font_size=12
    ) %>%
    add_footnote(boilerplate_caption, notation = "none") %>%
    as_image(file = filename)
}
