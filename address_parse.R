library(tm)

df.test <- df.crimes
x <- df.test$line
x <- removeWords(x, offense_names)
x <- removeWords(x, police_districts)
df.test$parsed <- x
