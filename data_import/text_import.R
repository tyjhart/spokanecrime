files = list.files(path = "./data_files/Spokane/", pattern = "\\.txt$", full.names = TRUE)
df.crimes = lapply(files, read.delim, header = FALSE, stringsAsFactors = FALSE) %>% bind_rows()

# Upper-case all entries
df.crimes$V1 <- toupper(df.crimes$V1)

### Headers, badge numbers(?) ###
df.crimes$V1 <- gsub("^SR.*:$", NA, df.crimes$V1)
df.crimes$V1 <- gsub("^SP.*:$", NA, df.crimes$V1)
df.crimes$V1 <- gsub("*IBR PURPOSES*", NA, df.crimes$V1)

# Remove newly-empty rows
df.crimes <- df.crimes %>% filter(!is.na(.$V1))

# Export raw text for auditing to make sure I'm not losing my mind
write.table(df.crimes, file = './raw_data.txt', sep = "\t", row.names = FALSE)


### A/C ###
df.crimes$ac <- NA
df.crimes[grep("^C\\s", df.crimes$V1),]$ac <- "C"
df.crimes[grep("^A\\s", df.crimes$V1),]$ac <- "A"
df.crimes[grep("^U\\s", df.crimes$V1),]$ac <- "U"
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
### End districts###


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
### End dates ###


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
### End addresses ###


### Offenses ###
df.crimes$offense <- NA

# Parse offense names
offense_pattern_vec <- c(
  'ARSON',
  'ASSAULT',
  'BURGLARY',
  'DRIVE BY SHOOTING',
  'HARASSMENT',
  'HOMICIDE',
  'INTIMIDATE',
  'MANSLAUGHTER',
  'MURDER',
  'POISON',
  'RAPE',
  'ROBBERY',
  'TAKING MOTOR VEHICLE',
  'PET ANIMALS TAKING CONCEALING',
  'THEFT',
  'THEFT OF MOTOR VEHICLE',
  'TMVWOP',
  'VEHICLE PROWLING',
  'VEHICLE TRESPASS'
)

# offense_pattern_vec <- c(
#   'ARSON\\s?-?[[:digit:]]D',
#   'ARSON\\s?-?[[:digit:]]ND DEG',
#   'ASSAULT\\s?-?[[:digit:]]D',
#   'ASSAULT [[:digit:]]D WEAPON OR NEGLIGENT INJURY',
#   'ASSAULT OF A CHILD-[[:digit:]]D',
#   'ASSAULT OF A CHILD [[:digit:]]D [WEAPON OR NEGLIGENT INJURY]?',
#   'BURGLARY\\-?\\s?[[:digit:]][N,R]?D',
#   'BURGLARY-[[:digit:]][N,R]?D DEG',
#   'BURGLARY [[:digit:]][N,R]?D (COMMERCIAL|GARAGE|FENCED AREA|FROM RESIDENCE|RESIDENTIAL)',
#   'BURGLARY-RESIDENTIAL',
#   'CHILD\\s?\\s?ASSAULT\\s?-?[[:digit:]][N,R,S]?D?T?\\(CRIM NEG\\)DVCA',
#   'CUSTODIAL ASSAULT \\(AGGRAVATED ASSAULT\\)',
#   'DRIVE BY SHOOTING',
#   'HARASSMENT (FELONY\\s)?WEAPON INVOLVED',
#   'HOMICIDE BY ABUSE',
#   'MAIL THEFT',
#   'MALICIOUS HARASSMENT SERIOUS INJURY \\(HATE BIAS\\)',
#   'MURDER\\s?[-]?[[:digit:]]D',
#   'ORGANIZED RETAIL THEFT',
#   'ORGANIZED RETAIL THEFT [[:digit:]]D',
#   'PET ANIMALS TAKING CONCEALING',
#   'POISON/HARMFUL OBJECT FOOD DRINK OR MED',
#   'RAPE\\s?-?[[:digit:]][N,R,S]?D?T?',
#   'RAPE OF A CHILD [[:digit:]]D',
#   'RAPE OF A CHILD-[[:digit:]]D \\((SODOMY|RAPE)\\)',
#   'RAPE-[[:digit:]]D \\(RAPE\\)',
#   'RAPE [[:digit:]]D USING OBJECT',
#   'RESIDENTIAL BURGLARY',
#   'RETAIL THEFT (WITH|W/) SPECIAL CIRCUMSTANCES',
#   'RETAIL THEFT WITH SPECIAL CIRCUMSTANCES [[:digit:]][N,R]?D',
#   'ROBBERY-?[[:digit:]]D \\(?(ALL EXCEPT\\s)?PURSE SNATCHING\\)?',
#   'ROBBERY [[:digit:]]D (ALL EXCEPT PURSE SNATCHING|PURSE SNATCHING|PERSON|CARJACKING|COMMERCIAL)',
#   'TAKING MOTOR VEHICLE WITHOUT PERMISSION [[:digit:]][N,R]?D',
#   'TMVWOP-[[:digit:]][N,R]?D',
#   'THEFT [[:digit:]][N,R]?D CITY (ALL OTHER|FROM BUILDING|FROM MOTOR VEHICLE|SHOPLIFTING|VEHICLE PARTS AND ACCESSORIES)',
#   'THEFT [[:digit:]][N,R]?D FROM (BUILDING|COIN OPERATED DEVICE|MOTOR VEHICLE)',
#   'THEFT-[[:digit:]][N,R]?D \\((FROM BUILDING|FROM COIN OPERATED MACHINE OR DEVICE)\\)',
#   'THEFT [[:digit:]][N,R]?D ALL OTHER',
#   'THEFT\\-?\\s?[[:digit:]][N,R]?D \\(?POCKET PICKING\\)?',
#   'THEFT [[:digit:]][N,R]?D SHOPLIFTING',
#   'THEFT [[:digit:]][N,R]?D VEHICLE PARTS (AND|OR) ACCESSORIES',
#   'THEFT-[[:digit:]][N,R]?D \\((MOTOR VEHICLE PARTS OR ACCESSORIES|ALL OTHER THEFTS|FROM MOTOR VEHICLE|SHOPLIFTING)\\)',
#   'THEFT OF A FIREARM ALL OTHER LOCATIONS',
#   'THEFT OF A FIREARM FROM [A]?\\s?BUILDING',
#   'THEFT\\(FIREARM\\) \\(FROM BUILDING\\)',
#   'THEFT FIREARM FROM BUILDING',
#   'THEFT OF A FIREARM (FROM MOTOR VEHICLE|SHOPLIFTING)',
#   'THEFT\\s?\\(?FIREARM\\)? \\(?FROM MOTOR VEHICLE\\)?',
#   'THEFT\\s?\\(FIREARM\\)\\s?\\(ALL OTHER\\)',
#   'THEFT OF MOTOR VEHICLE',
#   'THEFT OF SUBSCRIPTION TELEVISION SERVICES',
#   'THEFT-CITY ALL OTHER THEFTS',
#   'THEFT-CITY \\(ALL OTHER THEFTS\\)',
#   'THEFT-CITY \\(?FROM (BUILDING|MOTOR VEHICLE)\\)?',
#   'THEFT-CITY \\(SHOPLIFTING\\)',
#   'THEFT-CITY \\(?MOTOR VEHICLE PARTS OR ACCESSORIES\\)?',
#   'THEFT-CITY \\(FROM COIN OPERATED MACHINE OR DEVICE\\)',
#   'THEFT CITY FROM MOTOR VEHICLE',
#   'THEFT FROM A VULNERABLE ADULT [[:digit:]][N,R]?D',
#   'THEFT WITH INTENT TO RESELL \\(SHOPLIFTING|FROM BUILDING\\)?',
#   'THEFT WITH INTENT TO RESELL',
#   'THEFT OF RENT\\s?/\\s?LEASE (PROP|PROPERTY) \\(?FROM (BUILDING|YARD)\\)?',
#   'VEH\\(THEFT OF FUEL\\)',
#   'VEHICULAR ASSAULT',
#   'VEHICLE PROWLING\\s?-?[[:digit:]][N,R]?D[/NO THEFT]?',
#   'VEHICLE TRESPASS',
#   'WEAPON\\s?\\(INTIMIDATE WITH\\)'
#   )

for (offense_pattern in offense_pattern_vec) {
  offense_index <- grepl(offense_pattern, df.crimes$V1)
  offense <- regexpr(offense_pattern, df.crimes$V1)
  offense <- regmatches(df.crimes$V1, offense)
  try(df.crimes[offense_index,]$offense <- offense, silent = TRUE)
}

df.crimes$offense[grep("TMVWOP", df.crimes$offense)] <- "TAKING MOTOR VEHICLE"
df.crimes$offense[grep("PET ANIMALS TAKING CONCEALING", df.crimes$offense)] <- "THEFT"

df.crimes$offense <- as.factor(df.crimes$offense)

# Abbrev. offense names
levels(df.crimes$offense)[levels(df.crimes$offense)=="THEFT OF MOTOR VEHICLE"] <- "VEH. THEFT"
levels(df.crimes$offense)[levels(df.crimes$offense)=="TAKING MOTOR VEHICLE"] <- "TAKING VEH."
levels(df.crimes$offense)[levels(df.crimes$offense)=="VEHICLE PROWLING"] <- "VEH. PROWL"
levels(df.crimes$offense)[levels(df.crimes$offense)=="DRIVE BY SHOOTING"] <- "DRIVE-BY"
levels(df.crimes$offense)[levels(df.crimes$offense)=="VEHICLE TRESPASS"] <- "VEH. TRESPASS"

### Offense Subcategories ###

# df.crimes$subcategory <- NA
# 
# # Selected offense subcategories
# offense_pattern <- c(
#   'BURGLARY [[:digit:]][N,R]?D COMMERCIAL',
#   'BURGLARY [[:digit:]][N,R]?D FROM RESIDENCE',
#   'BURGLARY [[:digit:]][N,R]?D RESIDENTIAL',
#   'BURGLARY-RESIDENTIAL',
#   'RESIDENTIAL BURGLARY',
#   'BURGLARY [[:digit:]][N,R]?D GARAGE',
#   'BURGLARY [[:digit:]][N,R]?D FENCED AREA',
#   'THEFT [[:digit:]][N,R]?D CITY SHOPLIFTING',
#   'THEFT [[:digit:]][N,R]?D SHOPLIFTING',
#   'THEFT-CITY \\(SHOPLIFTING\\)',
#   'THEFT WITH INTENT TO RESELL \\(SHOPLIFTING\\)',
#   'THEFT OF A FIREARM ALL OTHER LOCATIONS',
#   'THEFT OF A FIREARM FROM [A]?\\s?BUILDING',
#   'THEFT FIREARM FROM BUILDING',
#   'THEFT OF A FIREARM FROM MOTOR VEHICLE',
#   'THEFT FIREARM FROM MOTOR VEHICLE',
#   'THEFT\\s?\\(FIREARM\\)\\s?\\(ALL OTHER\\)'
# )
# 
# subcategory <- c(
#   'Commercial',
#   'Residential',
#   'Residential',
#   'Residential',
#   'Residential',
#   'Garage',
#   'Fenced Area',
#   'Shoplifting',
#   'Shoplifting',
#   'Shoplifting',
#   'Shoplifting',
#   'Firearm',
#   'Firearm',
#   'Firearm',
#   'Firearm',
#   'Firearm',
#   'Firearm'
# )
# 
# offense_subcategories <- data.frame(
#   offense = offense_pattern, 
#   subcategory = subcategory,
#   stringsAsFactors = FALSE
# )
# 
# for (row in 1:nrow(offense_subcategories)) {
#   subcat_match_index <- grep(
#     offense_subcategories[row,"offense"], 
#     df.crimes$V1, 
#     ignore.case = TRUE
#     )
#   df.crimes$subcategory[subcat_match_index] <- offense_subcategories[row,"subcategory"]
# }
# 
# df.crimes$subcategory <- as.factor(df.crimes$subcategory)



### Write CSV ###
compstat_example_incidents <- c("BURGLARY","ROBBERY","TAKING VEH.","THEFT","VEH. THEFT")
compstat_examples <- df.crimes[which(df.crimes$offense %in% compstat_example_incidents),]
write.csv(compstat_examples[c("district","date","offense")], './compstat_export.csv', row.names = FALSE)
