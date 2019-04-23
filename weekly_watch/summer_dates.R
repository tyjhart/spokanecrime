# Beginning, end dates for summer
summer_start <- c("2013-06-21","2014-06-21", "2015-06-20", "2016-06-20", "2017-06-20", "2018-06-21")
summer_end <-   c("2013-09-21","2014-09-21", "2015-09-23", "2016-09-22", "2017-09-22", "2018-09-22")
summer_year <-  c(2013, 2014, 2015, 2016, 2017, 2018)

summer_dates <- data.frame(
  summer_start = as.Date(summer_start), 
  summer_end = as.Date(summer_end), 
  year = summer_year
)
