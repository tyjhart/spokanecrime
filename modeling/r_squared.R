### R-Squared ###
rsq <- function (x, y) cor(x, y) ^ 2
rsq(stlf_forecast$mean, tail(ts.crimes[,2],length(stlf_forecast$mean)))