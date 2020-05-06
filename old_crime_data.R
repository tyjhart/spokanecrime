# Import CSV data
df.old_crime_2013 <- read.csv("./csv_files/legacy/Crime%202013.csv", stringsAsFactors = FALSE)
df.old_crime_2014 <- read.csv("./csv_files/legacy/Crime%202014.csv", stringsAsFactors = FALSE)
df.old_crime_2015 <- read.csv("./csv_files/legacy/Crime%202015.csv", stringsAsFactors = FALSE)

df.old_crime <- rbind(df.old_crime_2013, df.old_crime_2014, df.old_crime_2015)

# Cleanup
rm(df.old_crime_2013, df.old_crime_2014, df.old_crime_2015)

# Format dates as YEAR-MONTH-DAY, no time
df.old_crime$BeginDate <- as.Date(df.old_crime$BeginDate, "%Y-%m-%d", tz = "UTC")
df.old_crime$EndDate <- NULL # Not used

# Rename columns
colnames(df.old_crime)[colnames(df.old_crime) == 'BeginDate'] <- 'date'
colnames(df.old_crime)[colnames(df.old_crime) == 'OffGen'] <- 'offense'
colnames(df.old_crime)[1] <- 'latitude'
colnames(df.old_crime)[2] <- 'longitude'

# Lunar phase
df.old_crime$lunar_phase <- lunar.phase(df.old_crime$date, name = 8, shift = -8)
df.old_crime$lunar_phase <- as.factor(df.old_crime$lunar_phase) 

# Season
df.old_crime$season <- terrestrial.season(df.old_crime$date)
df.old_crime$season <- as.factor(df.old_crime$season)
