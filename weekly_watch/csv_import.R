files = list.files(path = "./csv_files/", pattern = "\\.csv$", full.names = TRUE)
df.crimes = lapply(files, read_csv) %>% bind_rows()

# Attempted / Committed
df.crimes$ac <- as.factor(toupper(df.crimes$ac))

# Police Districts
df.crimes$district <- as.factor(toupper(df.crimes$district))

### Dates ###
df.crimes$date <- as.Date(df.crimes$date, "%m/%d/%Y")
df.crimes$year <- format(df.crimes$date, format = "%Y") # Year numbers for comparison
df.crimes$num.month <- format(df.crimes$date, format = "%m") # Month numbers for comparison
df.crimes$num.week <- format(df.crimes$date, format = "%U") # Week numbers for comparison

df.crimes$num.week <- as.factor(df.crimes$num.week)
df.crimes$num.month <- as.factor(df.crimes$num.month)
df.crimes$year <- as.factor(df.crimes$year)

### Clean up offense names ###
df.crimes$str.offense <- df.crimes$offense

# "CITY" designation
df.crimes$str.offense <- gsub("THEFT-CITY", "THEFT (CITY)", df.crimes$str.offense, fixed = TRUE)

# Standardize offense degrees
df.crimes$str.offense <- gsub("*-1D", " 1D", df.crimes$str.offense)
df.crimes$str.offense <- gsub("*-1ST", " 1D", df.crimes$str.offense)

df.crimes$str.offense <- gsub("*-2D", " 2D", df.crimes$str.offense)
df.crimes$str.offense <- gsub("*-2ND", " 2D", df.crimes$str.offense)

df.crimes$str.offense <- gsub("*-3D", " 3D", df.crimes$str.offense)
df.crimes$str.offense <- gsub("*-3RD", " 3D", df.crimes$str.offense)

df.crimes$str.offense <- gsub("*-4D", " 4D", df.crimes$str.offense)
df.crimes$str.offense <- gsub("*-4TH", " 4D", df.crimes$str.offense)

# Types of burglary
df.crimes$str.offense <- gsub("BURGLARY-RESIDENTIAL", "BURGLARY RESIDENTIAL", df.crimes$str.offense, fixed = TRUE)

# Factorize offenses
df.crimes$offense <- as.factor(tolower(df.crimes$str.offense))

### Categorize offenses ###
df.crimes$category <- NA
offense_cat_rows <- grep("*ARSON*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Arson"

offense_cat_rows <- grep("*ASSAULT*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Assault"

offense_cat_rows <- grep("^BURGLARY RESIDENTIAL$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Residential Burglary"

offense_cat_rows <- grep("^RESIDENTIAL BURGLARY$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Residential Burglary"

offense_cat_rows <- grep("^BURGLARY [1-3]D FROM RESIDENCE$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Residential Burglary"

offense_cat_rows <- grep("^BURGLARY [1-3]D GARAGE$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Garage Burglary"

offense_cat_rows <- grep("^BURGLARY [1-3]D FENCED AREA$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Fenced Area Burglary"

offense_cat_rows <- grep("^BURGLARY [1-3]D COMMERCIAL$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Commercial Burglary"

offense_cat_rows <- grep("*DRIVE BY SHOOTING*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Drive By Shooting"

offense_cat_rows <- grep("*HARASSMENT*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Harassment"

offense_cat_rows <- grep("*HOMICIDE*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Homicide"

offense_cat_rows <- grep("*INTIMIDATE WITH*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Intimidate With Weapon"

offense_cat_rows <- grep("*MURDER*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Murder"

offense_cat_rows <- grep("*RAPE*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Rape"

offense_cat_rows <- grep("*ROBBERY*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Robbery"

offense_cat_rows <- grep("*THEFT*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Theft"

offense_cat_rows <- grep("^THEFT [1-3]D FROM MOTOR VEHICLE$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Theft from Motor Vehicle"

offense_cat_rows <- grep("^THEFT [1-3]D FROM BUILDING$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Theft from Building"

offense_cat_rows <- grep("^THEFT [1-3]D ALL OTHER$", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Theft (All Other)"

offense_cat_rows <- grep("*THEFT OF MOTOR VEHICLE*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Theft of Motor Vehicle"

offense_cat_rows <- grep("*RETAIL THEFT*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Retail Theft"

offense_cat_rows <- grep("*MAIL THEFT*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Mail Theft"

offense_cat_rows <- grep("*SHOPLIFTING*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Shoplifting"

offense_cat_rows <- grep("*TMVWOP*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Taking Motor Vehicle"

offense_cat_rows <- grep("*TAKING MOTOR VEHICLE*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Taking Motor Vehicle"

offense_cat_rows <- grep("*VEHICLE PROWLING*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Vehicle Prowling"

offense_cat_rows <- grep("*VEHICLE TRESPASS*", df.crimes$str.offense)
df.crimes$category[offense_cat_rows] <- "Vehicle Trespass"

df.crimes$category <- as.factor(df.crimes$category)

# Generate address list CSV
df.crimes$city <- "Spokane"
df.crimes$state <- "WA"
df.crimes$zip <- ""

df.crimes[1:10000,] %>%
  filter(!is.na(address)) %>%
  distinct() %>%
  select(address, city, state, zip) %>%
  write.csv(., 'addresses.csv')

table(df.crimes$district)
table(df.crimes$ac)
table(df.crimes$offense)

df.crimes %>% write.csv(., 'compstat.csv')