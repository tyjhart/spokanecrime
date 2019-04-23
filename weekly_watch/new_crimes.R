# Empty data frame for parsed offense lines
df.crimes <- data.frame(stringsAsFactors = FALSE)

text_file_list <- list.files(path = "./text_files/", pattern = "\\.txt$", full.names = TRUE)

# District
police_districts <- c("p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "spa", "spb", "spc", "spd", "oth", "unk")

# Line header A/C/U
line_start_letter <- c("a", "c", "u")

for (file_name in text_file_list) {
  text.crime <- readLines(file_name)
  
  line_parsed <- foreach(
    line_num = 1:length(text.crime), 
    .combine = rbind,
    .packages = c("stringr", "data.table", "tidyverse")
    ) %dopar% {
    line <- str_to_lower(text.crime[line_num]) # Lowercase for easier comparison
    exploded_line <- strsplit(line, " ") # Explode the text line
    line_length <- length(exploded_line[[1]]) # Length of exploded elements
    
    # A/C (or U)
    ifelse(
      exploded_line[[1]][1] %in% line_start_letter,
      ac <- exploded_line[[1]][1],
      {
        exploded_line[[1]] <- shift(exploded_line[[1]], n=1, type="lag")
        ac <- "u"
      }
    )
    
    # Police districts
    ifelse(
      tail(exploded_line[[1]], n=1) %in% police_districts,
      district <- tail(exploded_line[[1]], n=1),
      {
        exploded_line[[1]] <- shift(exploded_line[[1]], n=1, type="lead")
        district <- "unk"
      }
    )
    
    # Date
    raw_date <- exploded_line[[1]][line_length-1]
    epoch_days_date <- as.Date(raw_date, "%m/%d/%Y") # Offense Date
    
    # Return parsed line
    return(c(ac, district, epoch_days_date, line))
  }
  
  df.crimes <- rbind(df.crimes, data.frame(line_parsed, stringsAsFactors = FALSE))
}

colnames(df.crimes) <- c("ac", "district", "date", "line")

df.crimes$ac <- factor(df.crimes$ac, levels = line_start_letter)
df.crimes$district <- factor(df.crimes$district, levels = police_districts)
df.crimes$date <- as.Date(as.integer(df.crimes$date), origin = "1970-01-01")
