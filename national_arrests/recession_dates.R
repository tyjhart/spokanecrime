recession_start <- c("1990-07-01","2001-03-01","2007-12-01")
recession_end <- c("1991-03-01","2001-11-01","2009-06-01")
recession_dates <- data.frame(
  recession_start = as.Date(recession_start),
  recession_end = as.Date(recession_end)
)