# install.packages('devtools')
# library('devtools')
# devtools::install_github("retostauffer/Rmosmix")
# library("mosmix")

needs(dplyr, weathermetrics, mosmix, readr)

station_id <- '10147' # Berlin-Tempelhof

url <- paste0('https://opendata.dwd.de/weather/local_forecasts/mos/MOSMIX_L/single_stations/', station_id, '/kml/MOSMIX_L_LATEST_',station_id,'.kmz')

kmz   <- tempfile("mosmix_demo_", fileext = ".kmz")
check <- download.file(url, kmz)

if ( inherits(check, "try-error") ) stop("Problems downloading the file!")
kml   <- unzip(kmz)

doc <- XML::xmlParse(kml)
datetime <- get_datetime(doc)
meta     <- get_meta_info(doc)


fcst <- get_forecasts(station_id, doc, datetime, meta, as.zoo = FALSE)

by.day <- fcst %>%
  transmute(date=as.Date(datetime),
            temp=kelvin.to.celsius(TTT),
            sun=SunD1/60,
            rain=RR1c) %>%
  group_by(date) %>%
  filter(n()==24) %>% 
  summarise(temp.min=round(min(temp)), temp.max=round(max(temp)), sunshine.hours=round(sum(sun)/60,0), rain.mm=sum(rain))

by.day %>% 
  transmute(day=format(date, '%a.'),
         sun=paste0('![](https://vis4.net/i/sun', as.numeric(cut(sunshine.hours, breaks=c(-1,0.5,4,9,24)))-1,'.png) ', sunshine.hours, 'h'),
         rain=paste0('![](https://vis4.net/i/rain',as.numeric(cut(rain.mm, breaks=c(-1,0,2,6,100)))-1,'.png) ', round(rain.mm), 'mm'),
         temp=paste0(temp.max,'<span style="color:#888"> / ', temp.min,'°C</span>')) %>% 
  write_csv('forecast.csv')

