# Import CSVs from FBI NIBRS
nibrs_incident_2012 <- read_csv("nibrs_incident_2012.csv")
nibrs_incident_2013 <- read_csv("nibrs_incident_2013.csv")
nibrs_incident_2014 <- read_csv("nibrs_incident_2014.csv")
nibrs_incident_2015 <- read_csv("nibrs_incident_2015.csv")
nibrs_incident_2016 <- read_csv("nibrs_incident_2016.csv")
nibrs_incident_2017 <- read_csv("nibrs_incident_2017.csv")

# 2012
nibrs_incident_2012$incident_date <- as.Date(nibrs_incident_2012$incident_date, "%Y-%m-%d", tz = "America/Los_Angeles")
nibrs_incident_2012 <- nibrs_incident_2012 %>% select(incident_date, incident_hour)

# 2013
nibrs_incident_2013$incident_date <- as.Date(nibrs_incident_2013$incident_date, "%Y-%m-%d", tz = "America/Los_Angeles")
nibrs_incident_2013 <- nibrs_incident_2013 %>% select(incident_date, incident_hour)

# 2014
nibrs_incident_2014$incident_date <- as.Date(nibrs_incident_2014$incident_date, "%Y-%m-%d", tz = "America/Los_Angeles")
nibrs_incident_2014 <- nibrs_incident_2014 %>% select(incident_date, incident_hour)

# 2015
nibrs_incident_2015$incident_date <- as.Date(nibrs_incident_2015$incident_date, "%Y-%m-%d", tz = "America/Los_Angeles")
nibrs_incident_2015 <- nibrs_incident_2015 %>% select(incident_date, incident_hour)

# 2016
names(nibrs_incident_2016) <- tolower(names(nibrs_incident_2016))
nibrs_incident_2016$incident_date <- tolower(nibrs_incident_2016$incident_date)
nibrs_incident_2016$incident_date <- as.Date(nibrs_incident_2016$incident_date, "%d-%b-%y", tz = "America/Los_Angeles")
nibrs_incident_2016 <- nibrs_incident_2016 %>% select(incident_date, incident_hour)

# 2017
names(nibrs_incident_2017) <- tolower(names(nibrs_incident_2017))
nibrs_incident_2017$incident_date <- tolower(nibrs_incident_2017$incident_date)
nibrs_incident_2017$incident_date <- as.Date(nibrs_incident_2017$incident_date, "%d-%b-%y", tz = "America/Los_Angeles")
nibrs_incident_2017 <- nibrs_incident_2017 %>% select(incident_date, incident_hour)

# Combine into single df
df.crimes <- rbind(
  nibrs_incident_2012,
  nibrs_incident_2013,
  nibrs_incident_2014, 
  nibrs_incident_2015,
  nibrs_incident_2016,
  nibrs_incident_2017
)

df.crimes$incident_datetime <- paste0(df.crimes$incident_date, " ", df.crimes$incident_hour, ":00:00")
df.crimes$incident_datetime <- as.POSIXct(df.crimes$incident_datetime, tz = "America/Los_Angeles", "%Y-%m-%d %H:%M:%S")

# Clean up
rm(nibrs_incident_2012, nibrs_incident_2013, nibrs_incident_2014, nibrs_incident_2015, nibrs_incident_2016, nibrs_incident_2017)
