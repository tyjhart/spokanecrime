# Lunar phase
df.crimes$lunar_phase <- lunar.phase(df.crimes$date, name = 8, shift = -8)
df.crimes$lunar_phase <- as.factor(df.crimes$lunar_phase) 

# Season
df.crimes$season <- terrestrial.season(df.crimes$date)
df.crimes$season <- as.factor(df.crimes$season)
