# install.packages('devtools')
# library('devtools')
# devtools::install_github("retostauffer/Rmosmix")
# library("mosmix")
library(readr)
library(dplyr)
library(weathermetrics)
library(mosmix)

station_id <- 'C720' # Berlin-Tempelhof

# url <- paste0('https://opendata.dwd.de/weather/local_forecasts/mos/MOSMIX_L/single_stations/', station_id, '/kml/MOSMIX_L_LATEST_',station_id,'.kmz')
url <- 'https://opendata.dwd.de/weather/local_forecasts/mos/MOSMIX_S/all_stations/kml/MOSMIX_S_LATEST_240.kmz'

kmz   <- tempfile("mosmix_demo_", fileext = ".kmz")
check <- download.file(url, kmz)

if ( inherits(check, "try-error") ) stop("Problems downloading the file!")
kml   <- unzip(kmz)

doc <- XML::xmlParse(kml)
datetime <- get_datetime(doc)
meta     <- get_meta_info(doc)


if (file.exists('out/stations.csv')) {
  good.stations <- read_csv('out/stations.csv')
} else {
  stations <- read_fwf('https://www.dwd.de/EN/ourservices/met_application_mosmix/mosmix_stations.cfg;jsessionid=6A47F126BB1F3B5383F07B7CC03595E9.live31092?view=nasPublication&nn=495490',
                       col_positions = fwf_widths(c(5,6,6,5,21,7,8,6,7,5),
                                                  col_names = c('clu','CofX','id','ICAO', 'name','lat','lon','elev','Hmod-H', 'type')), skip = 4)
  good.stations <- stations %>% filter(!is.na(as.numeric(id)) & type=='LAND')  
}


final_stations <- c()

dir.create('out', showWarnings=F)
dir.create('out/stations', showWarnings = F)

for (station_id in good.stations$id) {
  fcst <- get_forecasts(station_id, doc, datetime, meta, as.zoo = FALSE)
  if (!is.null(fcst) & !is.null(fcst$SunD1)) {
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
      write_csv(paste0('out/stations/forecast-', station_id, '.csv'))
    
    final_stations <- append(final_stations, station_id)
    print(station_id)
  }
}

if (!file.exists('out/stations.csv')) {
  good.stations %>% filter(id %in% final_stations) %>% write_csv('out/stations.csv')
}

f <- file('out/last-update.txt')
writeLines(as.character(Sys.time()), f)
close(f)



