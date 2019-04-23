# Factorize districts
df.crimes$district <- str_to_upper(df.crimes$district)
df.crimes$district <- factor(
  df.crimes$district, 
  c("P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "SPA", "SPB", "SPC", "SPD", "OTH", "UNK")
  )

# Factorize offenses
df.crimes$offense <- str_to_upper(df.crimes$offense)
df.crimes$offense <-as.factor(df.crimes$offense)