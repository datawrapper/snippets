needs(tidyverse)
needs(readxl)

raw_data <- read_excel("2020-05-26_stmf_raw.xlsx",  sheet = "SWE", col_types = c("text", 
          "numeric", "numeric", "text", "numeric", 
          "numeric", "numeric", "numeric", 
          "numeric", "numeric", "skip", "skip", 
          "skip", "skip", "skip", "skip", "numeric", 
          "numeric", "numeric"), skip = 2)

past_years <- c(as.character(2010:2019)) 

output <- raw_data %>% 
  filter(Sex == "b") %>% # do not differentiate by gender
  head(-1) %>% # remove last week, which may be incomplete
  select(Country, Year, Week, Total) %>% # select relevant columns
  pivot_wider(names_from = Year, values_from = Total) %>% # pivot to wide table
  mutate(
    Average = rowMeans(select(., past_years)), # calculate mean
    Date = as.Date(paste(2020, Week, 1, sep="-"), "%Y-%U-%u"),
    Baseline = 0
  ) 

View(output)

output %>% write_csv('data/swe.csv', na = '')
