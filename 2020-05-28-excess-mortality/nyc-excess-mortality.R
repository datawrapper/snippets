needs(tidyverse)

mortality <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/excess-deaths/deaths.csv", 
                   col_types = cols(baseline = col_double(), 
                                    excess_deaths = col_double(), expected_deaths = col_double(), 
                                    placename = col_character()))

past_years <- c("2017", "2018", "2019") 

output <- mortality %>% 
  filter(placename == "New York City") %>%
  select(placename, year, week, deaths) %>% # select relevant columns
  pivot_wider(names_from = year, values_from = deaths) %>% 
  mutate(
    average = rowMeans(select(., past_years)), # calculate mean
    date = as.Date(paste(2020, week-1, 1, sep="-"), "%Y-%U-%u")
  )  

View(output)

output %>% write_csv('data/nyc.csv', na = '')
