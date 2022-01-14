### Categorize crimes by violence ###
# Reference https://app.leg.wa.gov/rcw/default.aspx?cite=9.94A.030

violent_crimes <- c("ASSAULT","HOMICIDE","ROBBERY","RAPE","MURDER","DRIVE-BY")

df.crimes$violence <- NA

df.crimes[which(df.crimes$offense %in% violent_crimes),]$violence <- "Violent"
df.crimes[which(!df.crimes$offense %in% violent_crimes),]$violence <- "Non-Violent"
