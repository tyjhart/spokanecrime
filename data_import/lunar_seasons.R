# Lunar phase
df.crimes$lunar_phase <- lunar.phase(df.crimes$date, name = 8, shift = -8)
df.crimes$lunar_phase <- as.factor(df.crimes$lunar_phase) 

# Season
df.crimes$season <- terrestrial.season(df.crimes$date)
df.crimes$season <- as.factor(df.crimes$season)

# Moon phase abbreviations
levels(df.crimes$lunar_phase)[levels(df.crimes$lunar_phase)=="Waning gibbous"] <- "Waning Gibb."
levels(df.crimes$lunar_phase)[levels(df.crimes$lunar_phase)=="Waning crescent"] <- "Waning Cres."
levels(df.crimes$lunar_phase)[levels(df.crimes$lunar_phase)=="Waxing crescent"] <- "Waxing Cres."
levels(df.crimes$lunar_phase)[levels(df.crimes$lunar_phase)=="Waxing gibbous"] <- "Waxing Gibb."
