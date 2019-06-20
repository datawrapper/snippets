needs(rjson, dplyr)

years = seq(1979, 2019)
out = data_frame(days=seq(91,304))

for (year in years) {
  print(year)
  d1 <- fromJSON(readLines(paste0('https://nsidc.org/api/greenland/melt_area/', year)))
  d2 <- data_frame(time=as.Date(names(unlist(d1))), x=unlist(d1)) %>%
    rename_at(c('x'), function(x) { year }) %>%
    mutate(days=as.numeric(time - as.Date(paste0(year,'-01-01'))+1)) %>%
    select(-time)
  out <- out %>% left_join(d2, by = 'days')
}

write.csv(out, "greenland-ice.csv")

