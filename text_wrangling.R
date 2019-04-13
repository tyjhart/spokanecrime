# Empty data frame for parsed offense lines
df.crimes <- data.frame(stringsAsFactors = FALSE)

text_file_list <- list.files(path = "./text_files/", pattern = "\\.txt$", full.names = TRUE)

for (file_name in text_file_list) {
  text.crime <- readLines(file_name)
  
  for (line in text.crime) {
    exploded_line <- strsplit(line, " ") # Explode the text line
    line_length <- length(exploded_line[[1]]) # Get total line length
    
    ac <- exploded_line[[1]][1] # Offense A/C
    date <- as.Date(exploded_line[[1]][line_length-1], "%m/%d/%Y") # Offense Date
    district <- exploded_line[[1]][line_length] # Offense District
    
    # Paste offense name and address back together
    offense_location_string <- paste(
      exploded_line[[1]][2:as.numeric(line_length - 2)], 
      collapse = " "
    )
    
    # Match offense name to defined vector
    offense <- ifelse(
      TRUE %in% str_detect(offense_location_string, offense_list) == TRUE,
      offense_list[str_detect(offense_location_string, offense_list) == TRUE],
      "UNKNOWN"
    )
    
    # Match degree to defined vector
    degree <- ifelse(
      TRUE %in% str_detect(offense_location_string, df.degrees$name.degree) == TRUE,
      df.degrees$number.degree[str_detect(offense_location_string, df.degrees$name.degree) == TRUE],
      NA
    )
    
    # Motor vehicle involvement
    motor_vehicle_involved <- ifelse(
      TRUE %in% str_detect(offense_location_string, motor_veh_terms) == TRUE,
      1,
      0
    )

    offense_line <- data.frame(
      ac = ac, 
      date = date,
      offense = str_to_lower(offense),
      degree = degree,
      district = district, 
      motor_vehicle_involved = motor_vehicle_involved,
      location = str_to_lower(offense_location_string),
      stringsAsFactors = FALSE
    )
    
    df.crimes <- rbind(df.crimes, offense_line)
  }
}

# Isolate locations
df.crimes$location <- str_replace_all(df.crimes$location, paste(offense_names, collapse = "|"), "")
