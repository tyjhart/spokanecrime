# Import CSV data
df.old_crime_2013 <- read_csv("Crime%202013.csv", 
                              col_types = cols(Location = col_skip(), 
                                               OBJECTID = col_skip(), Offense = col_skip()))

df.old_crime_2014 <- read_csv("Crime%202014.csv", 
                              col_types = cols(Location = col_skip(), 
                                               OBJECTID = col_skip(), Offense = col_skip()))


df.old_crime_2015 <- read_csv("Crime%202015.csv", 
                              col_types = cols(Location = col_skip(), 
                                               OBJECTID = col_skip(), Offense = col_skip()))

df.old_crime <- rbind(df.old_crime_2013, df.old_crime_2014, df.old_crime_2015)

# Format dates as YEAR-MONTH-DAY, no time
df.old_crime$BeginDate <- as.Date(df.old_crime$BeginDate, "%Y-%m-%d", tz = "UTC")
df.old_crime$EndDate <- NULL # Not used

# Rename column
colnames(df.old_crime)[colnames(df.old_crime) == 'BeginDate'] <- 'date'
colnames(df.old_crime)[colnames(df.old_crime) == 'OffGen'] <- 'offense'
colnames(df.old_crime)[colnames(df.old_crime) == 'X'] <- 'lat'
colnames(df.old_crime)[colnames(df.old_crime) == 'Y'] <- 'long'

# Add "ac" column with "U" data
df.old_crime$ac <- "U"

# All "location" column with LAT, LONG, then remove old columns
df.old_crime$location <- paste(df.old_crime$lat, df.old_crime$long, sep = ",")
df.old_crime$lat <- NULL
df.old_crime$long <- NULL

# Remove "Day" column
df.old_crime$Day <- NULL

# Add filler columns that need to have parsing fixed
df.old_crime$degree <- NA
df.old_crime$district <- "Unk"

# Motor vehicle involvement
df.old_crime$motor_vehicle_involved <- ifelse(
  TRUE %in% str_detect(offense, motor_veh_terms) == TRUE,
  1,
  0
)
df.old_crime$motor_vehicle_involved <- 0

# Add old crime data to new data
df.crimes <- rbind(df.crimes, df.old_crime)
