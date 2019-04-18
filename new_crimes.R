# Empty data frame for parsed offense lines
df.crimes <- data.frame(stringsAsFactors = FALSE)

text_file_list <- list.files(path = "./text_files/", pattern = "\\.txt$", full.names = TRUE)

for (file_name in text_file_list) {
  text.crime <- readLines(file_name)
  
  for (line in text.crime) {
    line <- str_to_lower(line) # Lowercase for easier comparison
    exploded_line <- strsplit(line, " ") # Explode the text line
    
    # A/C (or U)
    ifelse(
      exploded_line[[1]][1] %in% c("a", "c", "u"),
      ac <- exploded_line[[1]][1],
      {
        exploded_line[[1]] <- shift(exploded_line[[1]], n=1, type="lag")
        ac <- "U"
        }
    )
    
    # District
    police_districts <- c("p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "spa", "spb", "spc", "spd", "oth", "unk")
    
    ifelse(
      tail(exploded_line[[1]], n=1) %in% police_districts,
      district <- tail(exploded_line[[1]], n=1),
      {
        exploded_line[[1]] <- shift(exploded_line[[1]], n=1, type="lead")
        district <- "unk"
      }
    )
    
    # Get total line length
    line_length <- length(exploded_line[[1]]) 
      
    # Date
    date <- as.Date(exploded_line[[1]][line_length-1], "%m/%d/%Y") # Offense Date
    
    # Paste offense name and address back together
    offense_location_string <- paste(
      exploded_line[[1]][2:as.numeric(line_length - 2)], 
      collapse = " "
    )
    
    # Match offense name to defined vector
    # offense <- ifelse(
    #   TRUE %in% str_detect(offense_location_string, offense_list) == TRUE,
    #   offense_list[str_detect(offense_location_string, offense_list) == TRUE],
    #   "unknown"
    # )
    
    offense <- ifelse(
      TRUE %in% str_detect(offense_location_string, df.offenses$string),
      df.offenses$summary[str_detect(offense_location_string, df.offenses$string) == TRUE],
      "unknown"
    )
    
    # Match degree to defined vector
    degree <- ifelse(
      TRUE %in% str_detect(offense_location_string, df.degrees$name.degree) == TRUE,
      df.degrees$number.degree[str_detect(offense_location_string, df.degrees$name.degree) == TRUE],
      NA
    )

    offense_line <- data.frame(
      ac = ac, 
      date = date,
      offense = offense,
      degree = degree,
      district = district,
      location = offense_location_string,
      line = line,
      stringsAsFactors = FALSE
    )
    
    df.crimes <- rbind(df.crimes, offense_line)
  }
}

# Isolate locations
df.crimes$location <- str_replace_all(df.crimes$location, paste(offense_names, collapse = "|"), "")
