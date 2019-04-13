# Factorize districts
df.crimes$district <- factor(df.crimes$district, c("P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "Oth"))

# Factorize offenses
df.crimes$offense <- stri_trans_totitle(df.crimes$offense)
df.crimes$offense <-as.factor(df.crimes$offense)