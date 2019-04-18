# Motor vehicle involvement
motor_veh_terms <- c("vehicle", "vehicular", "veh-")

df.crimes$motor_vehicle_involved <- ifelse(
  TRUE %in% str_detect(df.crimes$offense, motor_veh_terms) == TRUE,
  1,
  0
)
