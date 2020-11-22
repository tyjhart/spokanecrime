violent_crimes <- c("ASSAULT","HOMICIDE","ROBBERY","RAPE","MURDER")

df.crimes$violence <- NA

df.crimes[which(df.crimes$offense %in% violent_crimes),]$violence <- "Violent"
df.crimes[which(!df.crimes$offense %in% violent_crimes),]$violence <- "Non-Violent"
