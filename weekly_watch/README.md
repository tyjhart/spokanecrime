# Project Overview

Spokane Crime Analysis Project (CAP) is dedicated to discovering, analyzing, and visualizing crime data in Spokane, WA. Informed residents can make better decisions about where to live, raise families, work, and play in our wonderful city with up-to-date information on crime. With data in-hand, residents can engage actively and factually with local leaders and law enforcement. Using Computer Statistics (CompStat) [data provided by Spokane Police Department (SPD)](https://my.spokanecity.org/police/prevention/compstat/) we're able to analyze crime that has already happened, discover trends in the data, and make predictions.

Currently, the Spokane Police Department (SPD) makes weekly CompStat reports available each Monday. Reports cover reported crime for the prior week in PDF format, broken down by policing districts. We crawl the PDF files, extract data, and transform it into a format useful for analysis.

## Data Limitations

There are limitations to the analysis that's possible using data provided by the city. The location of sexual assault offenses is not included in CompStat reports in order to protect the victim's privacy. While we know how many sexual assaults are reported and the general policing district that they occurred, it's not possible to correlate that type of assault with specific locations.

When locations are included in weekly CompStat reports, they are sometimes documented only as an intersection of two roads, with no street numbers or direction. If an address is included in CompStat data, the street number is rounded - a robbery at "1215 E. Main Street" may become "1200 E. Main Street". Sometimes low-numbered locations are documented as "0 E. Main Street". This makes density or "heat" mapping difficult, and the resulting graphics somewhat unreliable.

It is well-known that many crimes are not reported to the authorities. This phenomena occurs for a number of reasons depending on the community - social pressures, negative law enforcement encounters in the past, prior criminal history of potential reporters, etc. It would be naive to think that all crime committed in Spokane is documented in the CompStat reports. Assumptions about the percentage of crimes that go unreported depend on complex, interconnected variables that change over time. For that reason, we'll only do analysis and reporting on the data at-hand, without making additional assumptions about unreported crime.

## Data Availability

Spokane's reporting of crime data has undergone multiple transformations in the last decade. CompStat data is available on the SpokaneCity.org portal from 2019 all the way back to 2015. On October 4, 2016 the SPD moved from one crime reporting standard (UCR) to another (NIBRS). Current CompStat reports state on the first page,

> Numbers on CompStat reports prior to this date should not be used as a comparison to those on this report.

Unfortunately, we're not able to make true "apples-to-apples" comparisons across the full timespan of availalble crime data.

## Overall Statistics

Looking at overall statistics gives us a good starting point from which to explore crime over time and specific types of offenses. From September 12, 2017 onward we see an overall downward trend in reported crime:

![CompStat Total Offenses](./figures/plot.offenses_over_time-1.svg)

Offenses tend to spike during the summer months, shown in dashed lines. The seasonality is demonstrated very clearly in the 2013-2016 data at the end of this report.

![Thefts](./figures/plot.theft_over_time-1.svg)

![Shoplifting](./figures/plot.shoplifting_over_time-1.svg)

![Burglaries](./figures/plot.burglaries_over_time-1.svg)

![Thefts of Motor Vehicles](./figures/plot.tomv_over_time-1.svg)

## Police District Statistics

The city is divided among eight policing districts, with four (P1, P2, P3, P4) in the "North Police Service Area" and the other four (P5, P6, P7, P8) in the "South". Geographically, the north and south service areas are separated by the Spokane River. In CompStat reports some offenses are noted as occurring in an "OTH" district with no amplifying information given. Periodically an offense will also be listed with no district at all in the weekly reports, and those are shown here as "UNK". Districts designated "SPA", "SPB", "SPC", and "SPD" had been used at one point, but no information is given in the CompStat reports indicating what areas these designations represented.

```{r 2019_offenses_by_police_district, fig.cap = "Offenses by Police District, 2019 YTD"}
df.crimes %>%
  filter(date >= "2019-01-01") %>%
  count(district) %>%
  ggplot(aes(reorder(district, -n), n, label = n)) +
  geom_col() +
  geom_text(vjust = -0.5) +
  scale_y_continuous("Offenses", labels = comma, expand = c(.1, .1)) +
  xlab("Police Districts") +
  ggtitle("Offenses by Police District, 2019 YTD")
```

So far in 2019 most crime occurred in districts P1, P2, P3, and P4 - all north of the Spokane River. Districts P4 and P3 are both located north of the river and east of Division, and have the highest overall counts.

```{r table.district_stats}
# District statistics
df.district_summary <- df.crimes %>%
  filter(date >= "2019-01-01") %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3) * 100

kable(df.district_summary[order(-df.district_summary$dist_sum),], col.names = c("Police District", "Offenses", "Percentage"), caption = "Statistics by District, 2019 YTD")
```

Districts P1-P4 have the highest overall counts of reported crimes from September 2017 onward.

```{r offenses_by_police_district, fig.cap = "Offenses by Police District"}
df.crimes %>%
  count(district) %>%
  ggplot(aes(reorder(district, -n), n, label = n)) +
  geom_col() +
  geom_text(vjust = -0.5) +
  scale_y_continuous("Offenses", labels = comma, expand = c(.1, .1)) +
  xlab("Police Districts") +
  ggtitle("Offenses by Police District, September 12, 2017 Onward")
```

```{r tab.district_summary}
# District statistics
df.district_summary <- df.crimes %>%
  group_by(district) %>%
  summarize(dist_sum = n())

df.district_summary$percentage <- round(df.district_summary$dist_sum / sum(df.district_summary$dist_sum), 3) * 100

kable(df.district_summary[order(-df.district_summary$dist_sum),], "latex", booktabs = T, col.names = c("Police District", "Offenses", "Percentage"), caption = "Statistics by District, September 12, 2017 Onward") 
```

## Types of Offenses

General theft (or larceny), burglary, shoplifting, and theft of motor vehicles continue to be top reported crimes so far in 2019. This follows the trend that's been recorded since mid-2017.

```{r offenses_by_type_ytd, fig.cap = "Types of Offenses, 2019 YTD"}
df.crimes %>%
  filter(date >= "2019-01-01") %>%
  count(category) %>%
  ggplot(aes(reorder(category, -n), n, label = n)) +
  geom_col() +
  geom_text(vjust = -0.5) +
  scale_y_continuous(expand = c(.1, .1)) +
  xlab("Category") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.25, hjust=1)) +
  xlab("") +
  ylab("Offenses") +
  ggtitle("Types of Offenses, 2019 YTD")
```

```{r offenses_by_type, fig.cap = "Types of Offenses"}
df.crimes %>%
  count(category) %>%
  ggplot(aes(reorder(category, -n), n, label = n)) +
  geom_col() +
  geom_text(angle = 90, vjust = 0.2, hjust = -0.2) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.25, hjust=1)) +
  xlab("") +
  scale_y_continuous("Offenses", limits = c(0, 8000)) +
  ggtitle("Types of Offenses, September 12, 2017 Onward")
```

## Month-Over-Month Statistics

While looking at data week-over-week is often not useful due to how "jumpy" crime statistics can be, month-over-month data can tell a story. Any field in the tables with "NA" value indicates that data either was not or is not yet available.

```{r}
# All Offenses
df.monthly_summary <- df.crimes %>% 
  group_by(year, num.month) %>%
  summarize(total.offenses = n())

kable(spread(df.monthly_summary, key = year, value = total.offenses), col.names = c("Month", 2017, 2018, 2019), caption = "Total Offenses")

# Thefts
df.monthly_summary <- df.crimes %>% 
  filter(category %in% c("Shoplifting", "Theft")) %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Total Thefts")

# All Burglaries
df.monthly_summary <- df.crimes %>%
  filter(category %in% c("Residential Burglary", "Commercial Burglary", "Garage Burglary", "Fenced Area Burglary")) %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "All Burglaries")
```

### Theft

The highest-count crimes of a non-violent nature in Spokane include theft (or "larceny") and burglary. There are special classifications of theft:

1. Retail theft
1. Retail theft with special circumstances
1. Shoplifting
1. Theft of a motor vehicle
1. Mail theft

```{r}
df.monthly_summary <- df.crimes %>% 
  filter(category == "Shoplifting") %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Shoplifting")
```

```{r}
# Mail Theft
df.monthly_summary <- df.crimes %>% 
  filter(category == "Mail Theft") %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Mail Theft")
```

```{r}
# Motor Vehicle Theft
df.monthly_summary <- df.crimes %>% 
  filter(category == "Theft of Motor Vehicle") %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Motor Vehicle Thefts") 
```

### Burglary

Burglary also has special classifications as well:

1. Residential burglary
1. Commercial burglary
1. Garage burglary
1. Fenced area burglary

```{r}
# Residential Burglaries
df.monthly_summary <- df.crimes %>%
  filter(category %in% c("Residential Burglary")) %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Residential Burglaries")
```

```{r}
# Commercial Burglaries
df.monthly_summary <- df.crimes %>%
  filter(category %in% c("Commercial Burglary")) %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Commercial Burglaries")
```

```{r}
# Fenced Area & Garage Burglaries
df.monthly_summary <- df.crimes %>%
  filter(category %in% c("Garage Burglary", "Fenced Area Burglary")) %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Fenced Area and Garage Burglaries")
```

## Violent Crime
Violent crime includes assault, sexual assault, robbery, intimidation with a weapon, and carjacking:

```{r}
# Robbery
df.monthly_summary <- df.crimes %>% 
  filter(category == "Robbery") %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Robberies") 
```

```{r}
# Assault
df.burglary_monthly_summary <- df.crimes %>% 
  filter(category == "Assault") %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.burglary_monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Assaults")
```

```{r}
# Rape
df.burglary_monthly_summary <- df.crimes %>% 
  filter(category == "Rape") %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.burglary_monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Sexual Assaults (Rape)") 
```

```{r}
# Intimidate with Weapon
df.burglary_monthly_summary <- df.crimes %>% 
  filter(category == "Intimidate With Weapon") %>%
  group_by(year, num.month) %>%
  summarize(total.thefts = n())

kable(spread(df.burglary_monthly_summary, key = year, value = total.thefts), col.names = c("Month", 2017, 2018, 2019), caption = "Intimidation with Weapon")
```

## Legacy Data

Crime data for 2013-2016 is available on the City of Spokane's GIS portal. Unfortunately, it doesn't use the same reporting standard as recent CompStat reports. However, the data is consistent and we can observe a downward trend in overall crime. We also note seasonality in crimes, with offenses peaking during the summer periods denoted by hashed lines.

![Legacy Data, 2013-2016](./figures/plot.2013_2016_offenses-1.png)