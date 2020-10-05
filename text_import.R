files = list.files(path = "./csv_files/", pattern = "\\.txt$", full.names = TRUE)
df.crimes = lapply(files, read.delim, header = FALSE, stringsAsFactors = FALSE) %>% bind_rows()

### Headers, badge numbers(?) ###
df.crimes$V1 <- gsub("^SR.*:$", NA, df.crimes$V1)
df.crimes$V1 <- gsub("^SP.*:$", NA, df.crimes$V1)
df.crimes$V1 <- gsub("*IBR Purposes*", NA, df.crimes$V1, ignore.case = TRUE)

# Remove newly-empty rows
df.crimes <- df.crimes %>% filter(!is.na(.$V1))

# Upper-case all entries
df.crimes$V1 <- toupper(df.crimes$V1)

### A/C ###
df.crimes$ac <- NA
df.crimes[grep("^C", df.crimes$V1),]$ac <- "C"
df.crimes[grep("^A", df.crimes$V1),]$ac <- "A"
df.crimes$ac <- as.factor(toupper(df.crimes$ac)) # Factorize

### Police districts ###
df.crimes$district <- NA

district_grep_vec <- c(
  'P[[:digit:]]{1}$',
  'Oth$',
  'OTH$',
  'SP[A|B|C|D]$'
  )

for (district_name in district_grep_vec) {
  district_parsing_index <- grepl(district_name, df.crimes$V1)
  districts <- regexpr(district_name, df.crimes$V1)
  districts <- regmatches(df.crimes$V1, districts)
  try(df.crimes[district_parsing_index,]$district <- districts)
}

df.crimes <- df.crimes %>% mutate(district = replace(district, district %in% c("SPA","SPB","SPC","SPD"),'OTH'))

# Factorize
df.crimes$district <- as.factor(toupper(df.crimes$district))  


### Dates ###
df.crimes$date <- NA

# Parsing date
date_grep_patterns <- '[[:digit:]]+/+[[:digit:]]+/+[[:digit:]]+'
date_parsing_index <- grep(date_grep_patterns, df.crimes$V1)
date <- regexpr(date_grep_patterns, df.crimes$V1)
date <- regmatches(df.crimes$V1, date)
df.crimes[date_parsing_index,]$date <- date

# Format dates
df.crimes$date <- as.Date(df.crimes$date, "%m/%d/%Y")
df.crimes$year <- format(df.crimes$date, format = "%Y") # Year numbers for comparison
df.crimes$num.month <- format(df.crimes$date, format = "%m") # Month numbers for comparison
df.crimes$num.week <- format(df.crimes$date, "%V") # Week numbers for comparison
df.crimes$num.day <- format(df.crimes$date, "%d") # Day numbers for comparison

# Day of the week
df.crimes$dow <- as.factor(weekdays(df.crimes$date))

# Week of the year
df.crimes$week <- as.factor(format(df.crimes$date, "%Y-%V"))

# Factorize dates
df.crimes$num.week <- as.factor(df.crimes$num.week)
df.crimes$num.month <- as.factor(df.crimes$num.month)
df.crimes$year <- as.factor(df.crimes$year)

### Addresses ###
df.crimes$address <- NA
street_addr_grep_pattern <- '[[:digit:]]{1,5} [N|S|E|W] \\w+ \\w+ ?[[:upper:]]{,4}'
intersection_grep_pattern <- '(?:[A-Za-z0-9]+\\s){2}[A-Za-z]+ / (?:[A-Za-z0-9]+\\s){2}[A-Za-z]+ ?[[:upper:]]{,4}'

# Typical street addresses
address_parsing_index <- grep(street_addr_grep_pattern, df.crimes$V1, ignore.case = TRUE)
addresses <- regexpr(street_addr_grep_pattern, df.crimes$V1)
addresses <- regmatches(df.crimes$V1, addresses)
df.crimes[address_parsing_index,]$address <- addresses 

# Parsing addresses as intersections
intersection_parsing_index <- grep(intersection_grep_pattern, df.crimes$V1, ignore.case = TRUE)
intersection <- regexpr(intersection_grep_pattern, df.crimes$V1)
intersection <- regmatches(df.crimes$V1, intersection)
df.crimes[intersection_parsing_index,]$address <- intersection 

### Offenses ###
df.crimes$offense <- NA

# Parse offense names
offense_pattern_vec <- c(
  'ARSON\\s?-?[[:digit:]]D',
  'ARSON\\s?-?[[:digit:]]ND DEG',
  'ASSAULT\\s?-?[[:digit:]]D',
  # 'ASSAULT [[:digit:]]D',
  # 'ASSAULT-[[:digit:]]D',
  'ASSAULT [[:digit:]]D WEAPON OR NEGLIGENT INJURY',
  'ASSAULT OF A CHILD-[[:digit:]]D',
  'ASSAULT OF A CHILD [[:digit:]]D [WEAPON OR NEGLIGENT INJURY]?',
  'BURGLARY\\-?\\s?[[:digit:]][N,R]?D',
  'BURGLARY-[[:digit:]][N,R]?D DEG',
  'BURGLARY [[:digit:]][N,R]?D (COMMERCIAL|GARAGE|FENCED AREA|FROM RESIDENCE|RESIDENTIAL)',
  # 'BURGLARY [[:digit:]][N,R]?D COMMERCIAL',
  # 'BURGLARY [[:digit:]][N,R]?D GARAGE',
  # 'BURGLARY [[:digit:]][N,R]?D FENCED AREA',
  # 'BURGLARY [[:digit:]][N,R]?D FROM RESIDENCE',
  # 'BURGLARY [[:digit:]][N,R]?D RESIDENTIAL',
  'BURGLARY-RESIDENTIAL',
  'CHILD\\s?\\s?ASSAULT\\s?-?[[:digit:]][N,R,S]?D?T?\\(CRIM NEG\\)DVCA',
  'CUSTODIAL ASSAULT \\(AGGRAVATED ASSAULT\\)',
  'DRIVE BY SHOOTING',
  # 'HARASSMENT WEAPON INVOLVED',
  'HARASSMENT (FELONY\\s)?WEAPON INVOLVED',
  'HOMICIDE BY ABUSE',
  'MAIL THEFT',
  'MALICIOUS HARASSMENT SERIOUS INJURY \\(HATE BIAS\\)',
  'MURDER\\s?[-]?[[:digit:]]D',
  'ORGANIZED RETAIL THEFT',
  'ORGANIZED RETAIL THEFT [[:digit:]]D',
  'PET ANIMALS TAKING CONCEALING',
  'POISON/HARMFUL OBJECT FOOD DRINK OR MED',
  'RAPE\\s?-?[[:digit:]][N,R,S]?D?T?',
  'RAPE OF A CHILD [[:digit:]]D',
  'RAPE OF A CHILD-[[:digit:]]D \\((SODOMY|RAPE)\\)',
  # 'RAPE OF A CHILD-[[:digit:]]D \\(RAPE\\)',
  'RAPE-[[:digit:]]D \\(RAPE\\)',
  'RAPE [[:digit:]]D USING OBJECT',
  'RESIDENTIAL BURGLARY',
  'RETAIL THEFT (WITH|W/) SPECIAL CIRCUMSTANCES',
  'RETAIL THEFT WITH SPECIAL CIRCUMSTANCES [[:digit:]][N,R]?D',
  'ROBBERY-?[[:digit:]]D \\(?(ALL EXCEPT\\s)?PURSE SNATCHING\\)?',
  'ROBBERY [[:digit:]]D (ALL EXCEPT PURSE SNATCHING|PURSE SNATCHING|PERSON|CARJACKING|COMMERCIAL)',
  # 'ROBBERY [[:digit:]]D PURSE SNATCHING',
  # 'ROBBERY [[:digit:]]D PERSON',
  # 'ROBBERY [[:digit:]]D CARJACKING',
  # 'ROBBERY [[:digit:]]D COMMERCIAL',
  'TAKING MOTOR VEHICLE WITHOUT PERMISSION [[:digit:]][N,R]?D',
  'TMVWOP-[[:digit:]][N,R]?D',
  'THEFT-[[:digit:]][N,R]?D \\(FROM BUILDING\\)',
  'THEFT [[:digit:]][N,R]?D ALL OTHER',
  'THEFT [[:digit:]][N,R]?D CITY (ALL OTHER|FROM BUILDING|FROM MOTOR VEHICLE|SHOPLIFTING|VEHICLE PARTS AND ACCESSORIES)',
  # 'THEFT [[:digit:]][N,R]?D CITY FROM BUILDING',
  # 'THEFT [[:digit:]][N,R]?D CITY FROM MOTOR VEHICLE',
  # 'THEFT [[:digit:]][N,R]?D CITY SHOPLIFTING',
  # 'THEFT [[:digit:]][N,R]?D CITY VEHICLE PARTS AND ACCESSORIES',
  'THEFT [[:digit:]][N,R]?D FROM (BUILDING|COIN OPERATED DEVICE|MOTOR VEHICLE)',
  # 'THEFT [[:digit:]][N,R]?D FROM COIN OPERATED DEVICE',
  'THEFT-[[:digit:]][N,R]?D \\(FROM COIN OPERATED MACHINE OR DEVICE\\)',
  # 'THEFT [[:digit:]][N,R]?D FROM MOTOR VEHICLE',
  'THEFT\\-?\\s?[[:digit:]][N,R]?D \\(?POCKET PICKING\\)?',
  'THEFT [[:digit:]][N,R]?D SHOPLIFTING',
  'THEFT [[:digit:]][N,R]?D VEHICLE PARTS (AND|OR) ACCESSORIES',
  # 'THEFT [[:digit:]][N,R]?D VEHICLE PARTS OR ACCESSORIES',
  'THEFT-[[:digit:]][N,R]?D \\((MOTOR VEHICLE PARTS OR ACCESSORIES|ALL OTHER THEFTS|FROM MOTOR VEHICLE|SHOPLIFTING)\\)',
  # 'THEFT-[[:digit:]][N,R]?D \\(ALL OTHER THEFTS\\)',
  # 'THEFT-[[:digit:]][N,R]?D \\(FROM MOTOR VEHICLE\\)',
  # 'THEFT-[[:digit:]][N,R]?D \\(SHOPLIFTING\\)',
  'THEFT OF A FIREARM ALL OTHER LOCATIONS',
  'THEFT OF A FIREARM FROM [A]?\\s?BUILDING',
  'THEFT\\(FIREARM\\) \\(FROM BUILDING\\)',
  'THEFT OF A FIREARM SHOPLIFTING',
  'THEFT FIREARM FROM BUILDING',
  'THEFT OF A FIREARM FROM MOTOR VEHICLE',
  'THEFT\\s?\\(?FIREARM\\)? \\(?FROM MOTOR VEHICLE\\)?',
  'THEFT\\s?\\(FIREARM\\)\\s?\\(ALL OTHER\\)',
  'THEFT OF MOTOR VEHICLE',
  'THEFT OF SUBSCRIPTION TELEVISION SERVICES',
  'THEFT-CITY ALL OTHER THEFTS',
  'THEFT-CITY \\(ALL OTHER THEFTS\\)',
  'THEFT-CITY \\(?FROM (BUILDING|MOTOR VEHICLE)\\)?',
  # 'THEFT-CITY \\(?FROM BUILDING\\)?',
  # 'THEFT-CITY \\(?FROM MOTOR VEHICLE\\)?',
  'THEFT-CITY \\(SHOPLIFTING\\)',
  'THEFT-CITY \\(?MOTOR VEHICLE PARTS OR ACCESSORIES\\)?',
  'THEFT-CITY \\(FROM COIN OPERATED MACHINE OR DEVICE\\)',
  'THEFT CITY FROM MOTOR VEHICLE',
  'THEFT FROM A VULNERABLE ADULT [[:digit:]][N,R]?D',
  'THEFT WITH INTENT TO RESELL \\(SHOPLIFTING|FROM BUILDING\\)?',
  'THEFT WITH INTENT TO RESELL',
  # 'THEFT OF RENT/LEASE PROPERTY FROM BUILDING',
  'THEFT OF RENT\\s?/\\s?LEASE (PROP|PROPERTY) \\(?FROM (BUILDING|YARD)\\)?',
  # 'THEFT OF RENT / LEASE PROPERTY \\(FROM YARD\\)',
  'VEH\\(THEFT OF FUEL\\)',
  'VEHICULAR ASSAULT',
  'VEHICLE PROWLING\\s?-?[[:digit:]][N,R]?D[/NO THEFT]?',
  'VEHICLE TRESPASS',
  'WEAPON\\s?\\(INTIMIDATE WITH\\)'
  )

for (offense_pattern in offense_pattern_vec) {
  offense_index <- grepl(offense_pattern, df.crimes$V1, ignore.case = TRUE)
  offense <- regexpr(offense_pattern, df.crimes$V1)
  offense <- regmatches(df.crimes$V1, offense)
  try(df.crimes[offense_index,]$offense <- offense, silent = TRUE)
}

### Offense Subcategories ###

df.crimes$subcategory <- NA

# Selected offense subcategories
offense_pattern <- c(
  'BURGLARY [[:digit:]][N,R]?D COMMERCIAL',
  'BURGLARY [[:digit:]][N,R]?D FROM RESIDENCE',
  'BURGLARY [[:digit:]][N,R]?D RESIDENTIAL',
  'BURGLARY-RESIDENTIAL',
  'RESIDENTIAL BURGLARY',
  'BURGLARY [[:digit:]][N,R]?D GARAGE',
  'BURGLARY [[:digit:]][N,R]?D FENCED AREA',
  'THEFT [[:digit:]][N,R]?D CITY SHOPLIFTING',
  'THEFT [[:digit:]][N,R]?D SHOPLIFTING',
  'THEFT-CITY \\(SHOPLIFTING\\)',
  'THEFT WITH INTENT TO RESELL \\(SHOPLIFTING\\)',
  'THEFT OF A FIREARM ALL OTHER LOCATIONS',
  'THEFT OF A FIREARM FROM [A]?\\s?BUILDING',
  'THEFT FIREARM FROM BUILDING',
  'THEFT OF A FIREARM FROM MOTOR VEHICLE',
  'THEFT FIREARM FROM MOTOR VEHICLE',
  'THEFT\\s?\\(FIREARM\\)\\s?\\(ALL OTHER\\)'
)

subcategory <- c(
  'Commercial',
  'Residential',
  'Residential',
  'Residential',
  'Residential',
  'Garage',
  'Fenced Area',
  'Shoplifting',
  'Shoplifting',
  'Shoplifting',
  'Shoplifting',
  'Firearm',
  'Firearm',
  'Firearm',
  'Firearm',
  'Firearm',
  'Firearm'
)

offense_subcategories <- data.frame(
  offense = offense_pattern, 
  subcategory = subcategory,
  stringsAsFactors = FALSE
)

for (row in 1:nrow(offense_subcategories)) {
  subcat_match_index <- grep(
    offense_subcategories[row,"offense"], 
    df.crimes$V1, 
    ignore.case = TRUE
    )
  df.crimes$subcategory[subcat_match_index] <- offense_subcategories[row,"subcategory"]
}

df.crimes$subcategory <- as.factor(df.crimes$subcategory)

### Write CSV ###
# df.crimes %>% write.csv(., './weekly_watch/csv_files/compstat.csv')
