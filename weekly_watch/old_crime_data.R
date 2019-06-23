# Import CSV data
df.old_crime_2013 <- read.csv("./csv_files/legacy/Crime%202013.csv", stringsAsFactors = FALSE)
df.old_crime_2014 <- read.csv("./csv_files/legacy/Crime%202014.csv", stringsAsFactors = FALSE)
df.old_crime_2015 <- read.csv("./csv_files/legacy/Crime%202015.csv", stringsAsFactors = FALSE)

df.old_crime <- rbind(df.old_crime_2013, df.old_crime_2014, df.old_crime_2015)
rm(df.old_crime_2013, df.old_crime_2014, df.old_crime_2015)

# Format dates as YEAR-MONTH-DAY, no time
df.old_crime$BeginDate <- as.Date(df.old_crime$BeginDate, "%Y-%m-%d", tz = "UTC")
df.old_crime$EndDate <- NULL # Not used

# Rename column
colnames(df.old_crime)[colnames(df.old_crime) == 'BeginDate'] <- 'date'
colnames(df.old_crime)[colnames(df.old_crime) == 'OffGen'] <- 'offense'
colnames(df.old_crime)[1] <- 'latitude'
colnames(df.old_crime)[2] <- 'longitude'
