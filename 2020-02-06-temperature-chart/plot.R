needs(tidyverse, lubridate)

d <- read_csv('https://vis4.net/data/dwd/stations/00430.csv?x') %>% 
  mutate(day=format(date, '-%m-%d'))

normalMin <- 1980
normalMax <- normalMin + 30

contextDay <- d %>%
  filter(year(date) >= normalMin & year(date) < normalMax) %>% 
  mutate(date = as.Date(paste0('2020-', format(date, '%m-%d')))) %>% 
  group_by(date) %>% 
  summarise(TMK.base=mean(TMK),
            TNK.base=round(mean(TNK),2),
            TXK.base=round(mean(TXK),2)) %>% 
  mutate(day=format(date, '-%m-%d')) %>% 
  select(-date)
  
record <- d %>%
  filter(year(date) < 2020) %>% 
  mutate(date = as.Date(paste0('2020-', format(date, '%m-%d')))) %>% 
  group_by(date) %>% 
  summarise(TNK.min=min(TNK), TXK.max=max(TXK)) %>% 
  mutate(day=format(date, '-%m-%d')) %>% 
  select(-date)

january <- d %>%
  filter(date > as.Date('2019-12-31')) %>% 
  left_join(contextDay, 'day') %>% 
  left_join(record, 'day')


range.low <- january %>% 
  select(date, range=TNK,
         daily.mean=TMK,
         base.high=TXK.base,
         base.low=TNK.base,
         record.high=TXK.max, record.low=TNK.min) %>% 
  mutate(date=as_datetime(paste0(date, '12:00:00')))

range.high <- january %>% 
  select(date, range=TXK,
         base.high=TXK.base, base.low=TNK.base,
         record.high=TXK.max, record.low=TNK.min) %>% 
  mutate(date=as_datetime(paste0(date, '12:00:00')))

day.start <- january %>% 
  select(date,
         base.high=TXK.base, base.low=TNK.base,
         record.high=TXK.max, record.low=TNK.min) %>% 
  mutate(date=as_datetime(paste0(date, '00:00:00')),
         range=NA)
  
day.end <- january %>% 
  select(date, base.high=TXK.base, base.low=TNK.base,
         record.high=TXK.max, record.low=TNK.min) %>% 
  mutate(date=as_datetime(paste0(date, '23:59:59')),
         range=NA) 

all <- bind_rows(range.low,
                 range.high,
                 day.start,
                 day.end) %>% 
  arrange(date)  # we need to sort by date to fix order 

all %>% 
  write_csv('january-temp-range.csv')

