### Categorize offenses ###
df.crimes$category <- NA

offense_category_pattern_vec <- c(
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

for (offense_category in offense_category_pattern_vec) {
  category_index <- grep(offense_category, df.crimes$offense, ignore.case = TRUE)
  try(df.crimes[category_index,]$category <- offense_category, silent = TRUE)
}

df.crimes$category[grep("TMVWOP", df.crimes$category)] <- "TAKING MOTOR VEHICLE"
df.crimes$category[grep("PET ANIMALS TAKING CONCEALING", df.crimes$category)] <- "THEFT"

# Factorize categories
df.crimes$category <- as.factor(df.crimes$category)