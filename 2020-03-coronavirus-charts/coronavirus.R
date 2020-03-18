# ---------------------
# This is the R script that generates the charts, maps and tables for the Datawrapper blog post http://blog.datawrapper.de/coronavirus-charts, written by Lisa Charlotte Rost.

# This is NOT great R code. It works, but much of it could have been achieved with shorter code, more elegant, more efficiently, less confusing and without so many libraries; especially the further you go down the script (I got better in the process, among others thanks to my coworker Gregor Aisch who's still a R pro). Please don't use this code to learn R.


# ---------------------
# load libraries
needs(dplyr, readr, reshape2, jsonlite, data.table, tidyr, htmltab)
# ^ if this command fails, run
# source("./needs.R")

# disable scientific notation
options(scipen = 999)

setwd('./data/coronavirus/')

options(tz="Europe/London")
Sys.setenv(TZ="Europe/London")
Sys.setlocale("LC_CTYPE", "en_US.UTF-8")



# ---------------------
# Cumulative for all states
# plus exponential data
# for Weekly Chart

# european_countries <- c("Aland", "Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Faroe Islands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey", "Hungary", "Iceland", "Ireland", "Isle of Man", "Italy", "Jersey", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "North Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Republic of Serbia", "Romania", "San Marino", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "United Kingdom", "Vatican")
# selected_countries = c("Switzerland", "Norway", "China", "Hong Kong", "United Kingdom", "Korea, South", "US", "Germany", "France", "Spain", "Germany", "Italy", "Iran", "South Korea", "Japan")

# all <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
#   rename(country = `Country/Region`,
#          province = `Province/State`) %>%
#   select(-Lat, -Long) %>%
#   pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
#   mutate(date = as.Date(date, "%m/%d/%y")) %>%
#   mutate(country = ifelse(country == "China" & province == "Hong Kong", "Hong Kong", country),
#          continent = ifelse(country %in% european_countries, "Europe", ""))
# 
# selected <- all %>%
#   select(-province, -continent) %>%
#   filter(country %in% selected_countries) %>%
#   arrange(date) %>%
#   group_by(date, country) %>%
#   mutate(confirmed = sum(confirmed)) %>%
#   distinct() %>%
#   ungroup() %>%
#   pivot_wider(names_from = "country", values_from = "confirmed") %>%
#   write_csv("test_data.csv")
# 
# europe <- all %>%
#   select(-province, -country) %>%
#   arrange(date) %>%
#   filter(continent == "Europe") %>%
#   group_by(date, continent) %>%
#   mutate(confirmed = sum(confirmed)) %>%
#   distinct() %>%
#   ungroup() %>%
#   pivot_wider(names_from = "continent", values_from = "confirmed") %>%
#   write_csv("test_data_europe.csv")




# ---------------------
# R O B E R T  K O C H
# Germany, cases per state
# for symbol map

# load data from Robert Koch Institute
RKI_cases <- htmltab(doc = "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html", which = "//th[text() = 'Bundesland']/ancestor::table") %>%
  rename(german_name = Bundesland)

# load German population from Wikipedia
german_population <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=1965358030"))

symbolmap <- merge(RKI_cases,german_population,by="german_name") %>%
  rename(cases = 2) %>%
  mutate(cases = gsub('([0-9]+) .*', '\\1',cases)) %>%
  mutate(cases = gsub(".", "", cases, fixed = TRUE)) %>%
  select(german_name, english_name, lat, long, cases, population) %>%
  mutate(cases = as.numeric(cases),
         relative = format(round((100 / population * cases),digits=5), nsmall = 5),
         rel_nice = floor(population / cases / 1000) * 1000,
         rel_nice = format(round(as.numeric(rel_nice), 0), big.mark=","),
         no_in_million = format(round(((cases*1000000)/population),digits=1), nsmall = 1),
         population = format(round(as.numeric(population), 0), big.mark=",")) %>%
  write_csv("germany-symbolmap-per-state.csv")



# ---------------------
# New cases, recoveries and deaths per day, WORLDWIDE
# AND new cases, recoveries and deaths YESTERDAY
# for column chart https://app.datawrapper.de/chart/7o2fN/visualize

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long) %>%
  pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(date) %>%
  mutate(confirmed = ifelse(date == "2020-03-12",lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, confirmed))

recovered <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long) %>%
  pivot_longer(-c(country, province), names_to = "date", values_to = "recovered") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(date) %>%
  summarise(recovered = sum(recovered)) %>%
  arrange(date) %>%
  mutate(recovered = ifelse(date == "2020-03-12",lag(recovered)+(lead(recovered)-lag(recovered))/2, recovered))

deaths <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long) %>%
  pivot_longer(-c(country, province), names_to = "date", values_to = "deaths") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(date) %>%
  summarise(deaths = sum(deaths)) %>%
  arrange(date) %>%
  mutate(deaths = ifelse(date == "2020-03-12",lag(deaths)+(lead(deaths)-lag(deaths))/2, deaths))

confirmed_recovered = merge(confirmed, recovered, by="date")


# --------------------
# New cases, recoveries and deaths CUMULATIVE, WORLDWIDE
# for area chart https://app.datawrapper.de/chart/tIwSC/visualize

merge(confirmed_recovered, deaths, by="date") %>%
  mutate(`current confirmed cases` = confirmed - deaths - recovered) %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  arrange(date) %>%
  select(date, `current confirmed cases`, recovered, deaths) %>%
  write_csv("worldwide_cumulative-current-recov-death-per-day.csv")

yesterday = merge(confirmed_recovered, deaths, by="date") %>%
  arrange(date) %>%
  mutate(`new confirmed cases` = confirmed - lag(confirmed),
         `recoveries` = recovered - lag(recovered),
         `deaths` = deaths - lag(deaths)) %>%
  select(date, `new confirmed cases`, recoveries, deaths) %>%
  mutate(confirmed_with_fake = ifelse(date == "2020-03-12",(lead(`new confirmed cases`)+`new confirmed cases`)*0.44, `new confirmed cases`)) %>%
  mutate(confirmed_with_fake = ifelse(date == "2020-03-13",(`new confirmed cases`+lag(`new confirmed cases`))*0.56, `new confirmed cases`)) %>%
  select(date, confirmed_with_fake, recoveries, deaths) %>%
  rename(`new confirmed cases` = confirmed_with_fake) %>%
  write_csv("worlwide-current-recov-death-per-day.csv") %>%

  # New cases, recoveries and deaths YESTERDAY
  filter(row_number()==n()) %>%
  select(date, `new confirmed cases`, deaths, recoveries) %>%
  mutate(date = as.Date(date, "%Y-%m-%d")) %>%
  mutate(date = format(date, "Numbers for yesterday, %A, %B %d"))

yesterday = as.data.frame(t(yesterday))
yesterday = setDT(yesterday, keep.rownames = TRUE)[] %>%
  mutate(rn=recode(rn, "date"=" "),
         rn=recode(rn, "new confirmed cases" = "Yesterday, this many new people <b>got tested positive</b> for COVID-19:"),
         rn=recode(rn, "deaths"="And at least this number of people <b>died from the virus</b>:"),
         rn=recode(rn, "recoveries"="But we also know that this many people <b>recovered</b> from the virus:")) %>%
  write_csv("worlwide-current-recov-death-yesterday.csv")




# ---------------------
# J O H N S  H O P K I N S 
# New cases, recoveries and deaths per day, Spain
# for column chart 

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  filter(country == "Spain") %>%
  select(-country, -Lat, -Long) %>%
  pivot_longer(-province, names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(date)

recovered <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  filter(country == "Spain") %>%
  select(-country, -Lat, -Long) %>%
  pivot_longer(-province, names_to = "date", values_to = "recovered") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(date) %>%
  summarise(recovered = sum(recovered)) %>%
  arrange(date)

deaths <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  filter(country == "Spain") %>%
  select(-country, -Lat, -Long) %>%
  pivot_longer(-province, names_to = "date", values_to = "deaths") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  mutate(deaths = ifelse(grepl(",",province) & date > "2020-03-09", 0, deaths)) %>%
  group_by(date) %>%
  summarise(deaths = sum(deaths)) %>%
  arrange(date)

confirmed_recovered = merge(confirmed, recovered, by="date")

merge(confirmed_recovered, deaths, by="date") %>%
  arrange(date) %>%
  mutate(`new confirmed cases` = confirmed - lag(confirmed),
         `recoveries` = recovered - lag(recovered),
         `deaths` = deaths - lag(deaths)) %>%
  select(date, `new confirmed cases`, recoveries, deaths) %>%
  mutate(`new confirmed cases` = case_when(
    date == "2020-03-12" ~ (lead(`new confirmed cases`)+`new confirmed cases`)*0.44, 
    date == "2020-03-13" ~ (lag(`new confirmed cases`) +`new confirmed cases`)*0.56, 
    date != "2020-03-12" & date != "2020-03-13" ~ `new confirmed cases`)) %>%
  write_csv("spain-current-recov-death-per-day.csv")




# ---------------------
# J O H N S  H O P K I N S 
# New cases, recoveries and deaths per day, US
# for column chart 

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  filter(country == "US") %>%
  select(-country, -Lat, -Long) %>%
  pivot_longer(-province, names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(date)

recovered <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  filter(country == "US") %>%
  select(-country, -Lat, -Long) %>%
  pivot_longer(-province, names_to = "date", values_to = "recovered") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(date) %>%
  summarise(recovered = sum(recovered)) %>%
  arrange(date)

deaths <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  filter(country == "US") %>%
  select(-country, -Lat, -Long) %>%
  pivot_longer(-province, names_to = "date", values_to = "deaths") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  mutate(deaths = ifelse(grepl(",",province) & date > "2020-03-09", 0, deaths)) %>%
  group_by(date) %>%
  summarise(deaths = sum(deaths)) %>%
  arrange(date)

confirmed_recovered = merge(confirmed, recovered, by="date")

merge(confirmed_recovered, deaths, by="date") %>%
  arrange(date) %>%
  mutate(`new confirmed cases` = confirmed - lag(confirmed),
         `recoveries` = recovered - lag(recovered),
         `deaths` = deaths - lag(deaths)) %>%
  select(date, `new confirmed cases`, recoveries, deaths) %>%
  mutate(`new confirmed cases` = case_when(
    date == "2020-03-12" ~ (lead(`new confirmed cases`)+`new confirmed cases`)*0.44, 
    date == "2020-03-13" ~ (lag(`new confirmed cases`) +`new confirmed cases`)*0.56, 
    date != "2020-03-12" & date != "2020-03-13" ~ `new confirmed cases`)) %>%
  write_csv("us-current-recov-death-per-day.csv")


# ---------------------
# W H O - D A T A
# New cases, recoveries and deaths per day, GERMANY
# for column chart

# read_csv(url("https://covid.ourworldindata.org/data/full_data.csv")) %>%
#   rename(country = location) %>%
#   filter(country == "Germany") %>%
#   select(date, new_cases) %>%
#   mutate(date = as.Date(date, "%m/%d/%y")) %>%
#   rename(`new confirmed cases` = new_cases) %>%
#   write_csv("germany-current-recov-death-per-day-who.csv")


# ---------------------
# J O H N S  H O P K I N S 
# New cases, recoveries and deaths per day, GERMANY
# for column chart

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country == "Germany") %>%
  group_by(date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(date) %>%
  mutate(confirmed = ifelse(date == "2020-03-12",lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, confirmed))

recovered <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "recovered") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country == "Germany") %>%
  group_by(date) %>%
  summarise(recovered = sum(recovered)) %>%
  arrange(date) %>%
  mutate(recovered = ifelse(date == "2020-03-12",lag(recovered)+(lead(recovered)-lag(recovered))/2, recovered))

deaths <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "deaths") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country == "Germany") %>%
  group_by(date) %>%
  summarise(deaths = sum(deaths)) %>%
  arrange(date) %>%
  mutate(deaths = ifelse(date == "2020-03-12",lag(deaths)+(lead(deaths)-lag(deaths))/2, deaths))

confirmed_recovered = merge(confirmed, recovered, by="date")

merge(confirmed_recovered, deaths, by="date") %>%
  arrange(date) %>%
  mutate(`new confirmed cases` = confirmed - lag(confirmed),
         `recoveries` = recovered - lag(recovered),
         `deaths` = deaths - lag(deaths)) %>%
  select(date, `new confirmed cases`, recoveries, deaths) %>%
  mutate(`new confirmed cases` = case_when(
    date == "2020-03-12" ~ (lead(`new confirmed cases`)+`new confirmed cases`)*0.44, 
    date == "2020-03-13" ~ (lag(`new confirmed cases`) +`new confirmed cases`)*0.56, 
    date != "2020-03-12" & date != "2020-03-13" ~ `new confirmed cases`)) %>%
  write_csv("germany-current-recov-death-per-day.csv")


# ---------------------
# J O H N S  H O P K I N S
# New cases, recoveries and deaths per day, CHINA
# for column chart

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "confirmed") %>%
  filter(country == "China") %>%
  group_by(date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(date)

recovered <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "recovered") %>%
  filter(country == "China") %>%
  group_by(date) %>%
  summarise(recovered = sum(recovered)) %>%
  arrange(date)

deaths <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "deaths") %>%
  filter(country == "China") %>%
  group_by(date) %>%
  summarise(deaths = sum(deaths)) %>%
  arrange(date)

confirmed_recovered = merge(confirmed, recovered, by="date")

merge(confirmed_recovered, deaths, by="date") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  arrange(date) %>%
  mutate(`new confirmed cases` = confirmed - lag(confirmed),
         `recoveries` = recovered - lag(recovered),
         `deaths` = deaths - lag(deaths)) %>%
  select(date, `new confirmed cases`, recoveries, deaths) %>%
  write_csv("china-current-recov-death-per-day.csv")



# ---------------------
# W H O - D A T A
# New cases, recoveries and deaths per day, ITALY
# for column chart

# read_csv(url("https://covid.ourworldindata.org/data/full_data.csv")) %>%
#   rename(country = location) %>%
#   filter(country == "Italy") %>%
#   select(date, new_cases) %>%
#   mutate(date = as.Date(date, "%m/%d/%y")) %>%
#   rename(`new confirmed cases` = new_cases) %>%
#   write_csv("italy-current-recov-death-per-day.csv")


# ---------------------
# J O H N S  H O P K I N S
# New cases, recoveries and deaths per day, ITALY
# for column chart

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country == "Italy") %>%
  group_by(date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(date) %>%
  mutate(confirmed = ifelse(date == "2020-03-12",lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, confirmed))

recovered <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "recovered") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country == "Italy") %>%
  group_by(date) %>%
  summarise(recovered = sum(recovered)) %>%
  arrange(date) %>%
  mutate(recovered = ifelse(date == "2020-03-12",lag(recovered)+(lead(recovered)-lag(recovered))/2, recovered))

deaths <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "deaths") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country == "Italy") %>%
  group_by(date) %>%
  summarise(deaths = sum(deaths)) %>%
  arrange(date) %>%
  mutate(deaths = ifelse(date == "2020-03-12",lag(deaths)+(lead(deaths)-lag(deaths))/2, deaths))

confirmed_recovered = merge(confirmed, recovered, by="date")

merge(confirmed_recovered, deaths, by="date") %>%
  arrange(date) %>%
  mutate(`new confirmed cases` = confirmed - lag(confirmed),
         `recoveries` = recovered - lag(recovered),
         `deaths` = deaths - lag(deaths)) %>%
  select(date, `new confirmed cases`, recoveries, deaths) %>%
  mutate(`new confirmed cases` = case_when(
    date == "2020-03-12" ~ (lead(`new confirmed cases`)+`new confirmed cases`)*0.44, 
    date == "2020-03-13" ~ (lag(`new confirmed cases`) +`new confirmed cases`)*0.56, 
    date != "2020-03-12" & date != "2020-03-13" ~ `new confirmed cases`)) %>%
  write_csv("italy-current-recov-death-per-day.csv")


# ---------------------
# W H O - D A T A 
# New cases, recoveries and deaths per day, EUROPE
# for column chart 

# european_countries_who <- c("Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Faeroe Islands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey", "Vatican", "Hungary", "Iceland", "Ireland", "Italy", "Jersey", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Malta", "Monaco", "Netherlands", "Macedonia", "Norway", "Poland", "Portugal", "Moldova", "Romania", "Russia", "Reunion", "Saint Barthlemy", "Saint Martin (French part)", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom", "Ukraine")
# 
# read_csv(url("https://covid.ourworldindata.org/data/full_data.csv")) %>%
#   rename(country = location) %>%
#   filter(country %in% european_countries_who) %>%
#   select(date, new_cases) %>%
#   drop_na(new_cases) %>%
#   group_by(date) %>%
#   summarise(new_cases = sum(new_cases)) %>%
#   mutate(date = as.Date(date, "%m/%d/%y")) %>%
#   rename(`new confirmed cases` = new_cases) %>%
#   write_csv("europe-current-recov-death-per-day.csv")


# ---------------------
# J O H N S  H O P K I N S
# New cases, recoveries and deaths per day, EUROPE
# for column chart https://app.datawrapper.de/chart/sXXHM/visualize

european_countries <- c("Aland", "Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Faroe Islands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey", "Hungary", "Iceland", "Ireland", "Isle of Man", "Italy", "Jersey", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "North Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Republic of Serbia", "Romania", "San Marino", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "UK", "Vatican")

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country %in% european_countries) %>%
  group_by(date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(date) %>%
  mutate(confirmed = ifelse(date == "2020-03-12",lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, confirmed))

recovered <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "recovered") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country %in% european_countries) %>%
  group_by(date) %>%
  summarise(recovered = sum(recovered)) %>%
  arrange(date) %>%
  mutate(recovered = ifelse(date == "2020-03-12",lag(recovered)+(lead(recovered)-lag(recovered))/2, recovered))

deaths <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")) %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(country = `Country/Region`) %>%
  pivot_longer(-country, names_to = "date", values_to = "deaths") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  filter(country %in% european_countries) %>%
  group_by(date) %>%
  summarise(deaths = sum(deaths)) %>%
  arrange(date) %>%
  mutate(deaths = ifelse(date == "2020-03-12",lag(deaths)+(lead(deaths)-lag(deaths))/2, deaths))

confirmed_recovered = merge(confirmed, recovered, by="date")

merge(confirmed_recovered, deaths, by="date") %>%
  arrange(date) %>%
  mutate(`new confirmed cases` = confirmed - lag(confirmed),
         `recoveries` = recovered - lag(recovered),
         `deaths` = deaths - lag(deaths)) %>%
  select(date, `new confirmed cases`, recoveries, deaths) %>%
  mutate(`new confirmed cases` = case_when(
    date == "2020-03-12" ~ (lead(`new confirmed cases`)+`new confirmed cases`)*0.44, 
    date == "2020-03-13" ~ (lag(`new confirmed cases`) +`new confirmed cases`)*0.56, 
    date != "2020-03-12" & date != "2020-03-13" ~ `new confirmed cases`)) %>%
  write_csv("europe-current-recov-death-per-day.csv")


# ---------------------
# R E N E  E N G E L M A N  (not up-to-date anymore)
# Germany, detailed cases
# for symbol map

symbolmap <- read_csv("https://raw.githubusercontent.com/iceweasel1/COVID-19-Germany/master/germany_with_source.csv") %>%
  filter(Latitude != "N/A")

row_count <- nrow(symbolmap)

symbolmap <- symbolmap %>%
  # add a bit of jitter to the coordinates
  mutate(Latitude = runif(row_count, min=-0.03, max=0.03) + as.numeric(Latitude), Longitude = runif(row_count, min=-0.05, max=0.05) + as.numeric(Longitude)) %>%
  write_csv("germany-symbolmap-detailed.csv")


# ---------------------
# R E N E  E N G E L M A N  (not up-to-date anymore)
# Berlin, detailed cases
# for symbol map

berlin_coordinates <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=574682889"))

berlin_data <- read_csv("https://raw.githubusercontent.com/iceweasel1/COVID-19-Germany/master/germany_with_source.csv") %>%
  filter(`Federated state`== "Berlin") %>%
  mutate(District=recode(District, `Neuköln`="Neukölln")) 

berlin_symbolmap <- merge(berlin_data, berlin_coordinates, by="District") %>%
  group_by(District, lat, lon, population) %>%
  summarise(cases = n()) %>%
  mutate(no_in_100000 = format(round(((cases*100000)/population),digits=1), nsmall = 1)) %>%
  write_csv("berlin-symbolmap.csv")


# ---------------------
# Get data from the John Hokins DASHBOARD for maps
# source: https://twitter.com/mathdroid/status/1234838261995950080
all_cases <- fromJSON("https://covid19.mathdro.id/api/confirmed", flatten=TRUE) %>%
  select(-iso2, -iso3) %>%
  mutate(countryRegion=recode(countryRegion, `Iran (Islamic Republic of)`="Iran"),
         countryRegion=recode(countryRegion, `Mainland China`="China"),
         countryRegion=recode(countryRegion, `UK`="United Kingdom"),
         countryRegion=recode(countryRegion, `North Macedonia`="Macedonia"),
         countryRegion=recode(countryRegion, `Korea, South`="South Korea"),
         current_cases = confirmed-deaths-recovered) %>%
  rename(country = countryRegion,
         province = provinceState)

### Renaming
all_cases$region[all_cases$country == "China"] <- "China without Hubei"
all_cases$region[all_cases$country == "US"] <- "United States"
all_cases$region[all_cases$country == "Germany"] <- "Germany"
all_cases$region[all_cases$country == "Iran"] <- "Iran"
all_cases$region[all_cases$country == "United Kingdom"] <- "United Kingdom"
all_cases$region[all_cases$country == "Italy"] <- "Italy"
all_cases$region[all_cases$country == "South Korea"] <- "South Korea"
all_cases$region[all_cases$country == "France"] <- "France"
all_cases$region[all_cases$country == "Spain"] <- "Spain"
all_cases$region[all_cases$province == "Hubei"] <- "Hubei, China"

# Hubei_row <- all_cases %>% 
#   filter(region == "Hubei, China") %>%
#   mutate(region = "China")
# 
# all_cases <- rbind(all_cases, Hubei_row)


# ---------------------
# Symbol map of CONFIRMED & RECOVERED cases worldwide

all_cases %>%
  mutate(country=recode(country, `Mainland China`="China")) %>%
  mutate(region=ifelse(is.na(province), country, paste(province, country, sep=', '))) %>%
  select(-province, -country) %>%
  pivot_longer(-c(region, lastUpdate, lat, long, region), names_to = "type", values_to = "cases") %>%
  filter(type == "recovered" | type == "confirmed") %>%
  
  # convert unix timestamps
  mutate(lastUpdate=as.POSIXct(lastUpdate/1000, origin="1970-01-01 00:00")) %>%
  mutate(lastUpdate = as.Date(lastUpdate, "%m/%d/%y")) %>%
  
  # reordering columns
  select(lat, long, region, cases, type, lastUpdate) %>%
  
  # write CSV
  write_csv("worldwide-recov-conf-symbolmap.csv")


# ---------------------
# Symbol map of current confirmed cases in EUROPE

european_countries <- c("Aland", "Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Faroe Islands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey", "Hungary", "Iceland", "Ireland", "Isle of Man", "Italy", "Jersey", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Republic of Serbia", "Romania", "San Marino", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "United Kingdom", "Vatican")

all_cases %>%

  # filter out UK channel islands & Gibraltar
  mutate(country = ifelse(country == "United Kingdom" & province != "United Kingdom", "nope", country)) %>%

  # filter for european countries
  filter(country %in% european_countries) %>%
  mutate(region = country) %>%
  select(-province,-country) %>%
  
  # convert unix timestamps
  mutate(lastUpdate=as.POSIXct(lastUpdate/1000, origin="1970-01-01 00:00")) %>%
  mutate(lastUpdate = as.Date(lastUpdate, "%m/%d/%y")) %>%
  rename(cases = current_cases) %>%
  
  # reordering columns
  select(lat, long, region, cases, deaths, recovered, lastUpdate) %>%
  
  # write CSV
  write_csv("europe-symbolmap.csv")



# ---------------------
# Symbol chart of current confirmed cases in CHINA

all_cases %>%
  
  # filter for China
  filter(country == "China") %>%
  mutate(region = province) %>%
  select(-province, -country) %>%
  
  # convert unix timestamps
  mutate(lastUpdate=as.POSIXct(lastUpdate/1000, origin="1970-01-01 00:00")) %>%
  mutate(lastUpdate = as.Date(lastUpdate, "%m/%d/%y")) %>%
  rename(cases = current_cases) %>%
  
  # reordering columns
  select(lat, long, region, cases, deaths, recovered, lastUpdate) %>%
  
  # write CSV
  write_csv("china-symbolmap.csv")


# ---------------------
# Symbol map of current confirmed cases in US


all_cases %>%
  
  # filter for US
  filter(country == "US") %>%
  mutate(region = province) %>%
  select(-province, -country) %>%
  
  # convert unix timestamps
  mutate(lastUpdate=as.POSIXct(lastUpdate/1000, origin="1970-01-01 00:00")) %>%
  mutate(lastUpdate = as.Date(lastUpdate, "%m/%d/%y")) %>%
  rename(cases = current_cases) %>%
  
  # reordering columns
  select(lat, long, region, cases, deaths, recovered, lastUpdate) %>%
  # write CSV
  write_csv("us-symbolmap.csv")


# ---------------------
# Table that shows the confirmed / recovered / deaths / current confirmed cases in the main infected areas and in the rest of the world, compared with the population
# Source for population data: https://population.un.org/wpp/Download/Standard/Population/

table <- data.frame(matrix(ncol=0,nrow=0))

table <- all_cases %>%
  mutate(region = replace_na(region, "rest-of-world")) %>%
  select(region, current_cases, deaths, recovered) %>%
  pivot_longer(-region, names_to = "type", values_to = "cases") %>%
  group_by(region, type) %>%
  summarise(cases = sum(cases)) %>%
  pivot_wider(names_from = "type", values_from = "cases") %>%

  # sum up to get cases for the whole world	
  ungroup() %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "World")))

# add population numbers
population = read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv"))
population$population = as.integer(population$population)

# merge, keep all rows
table <- merge(table, population, by="region", all=TRUE) %>%
  drop_na(current_cases)

# BRUTE FORCE add world population besides countries stated
table$population[table$region == "rest-of-world"] <- 5679690897

# BRUTE FORCE add world population
table$population[table$region == "World"] <- 7794798739

table <- table %>%
  mutate(current_cases_rel = population / current_cases) %>%
  mutate(current_cases_rel_nice = floor(current_cases_rel / 1000) * 1000) %>%
  select(-current_cases_rel, -population) %>%
  arrange(as.numeric(current_cases_rel_nice)) %>%
  rename(`current confirmed cases` = current_cases, `Currently, one in ... people is confirmed to have the virus` = current_cases_rel_nice) %>%
  arrange(desc(region))

simple_table <- table

table <- table %>%
  select(region, `current confirmed cases`, deaths, recovered,`Currently, one in ... people is confirmed to have the virus`)

table$region[table$region == "Hubei, China"] <- ":cn: Hubei ^Province in China^"
table$region[table$region == "China"] <- ":cn: China ^without Hubei^"
table$region[table$region == "Germany"] <- ":de: Germany"
table$region[table$region == "France"] <- ":fr: France"
table$region[table$region == "United States"] <- ":us: United States"
table$region[table$region == "Iran"] <- ":ir: Iran"
table$region[table$region == "Italy"] <- ":it: Italy"
table$region[table$region == "United Kingdom"] <- ":uk: United Kingdom"
table$region[table$region == "South Korea"] <- ":kr: South Korea"
table$region[table$region == "Spain"] <- ":es: Spain"
table$region[table$region == "rest-of-world"] <- "Other countries"

write_csv(table, "country-comparison-table.csv")


# ---------------------
# Overview table showing just current / recoveries / deaths

simple_table2 <- subset(simple_table, region=="World") %>%
  rename(current_cases = `current confirmed cases`,  
         rel = `Currently, one in ... people is confirmed to have the virus`) %>%
  select(-rel, -region) %>%
  mutate(confirmed = deaths + recovered + current_cases) %>%
  rename(Recovered = recovered, 
         Deaths = deaths, 
         'Current confirmed cases' = current_cases ) %>%
  mutate(extracolumn = 1) %>%
  pivot_longer(-extracolumn, names_to = "type", values_to = "cases") %>%
  select(-extracolumn) %>%
  mutate(relative = 100 / 7794798739 * cases, 
         rel_nice = floor(7794798739 / cases / 1000) * 1000,
         share_of_confirmed = 100 / as.numeric(cases[type == "confirmed"]) * cases) %>%
  filter(type != "confirmed")

simple_table2$cases <- format(round(as.numeric(simple_table2$cases), 0), big.mark=",")
simple_table2$relative <- format(round(as.numeric(simple_table2$relative), 5), big.mark=",")
simple_table2$rel_nice <- format(round(as.numeric(simple_table2$rel_nice), 0), big.mark=",")
simple_table2$share_of_confirmed <- format(round(as.numeric(simple_table2$share_of_confirmed), 2), big.mark=",")

simple_table2$relative <- with(simple_table2, paste0("that's <b>", relative, "%</b> of humanity"))
simple_table2$rel_nice <- with(simple_table2, paste0("or one in <b>",rel_nice, "</b> humans"))
simple_table2$share_of_confirmed <- with(simple_table2, paste0("or <b>", share_of_confirmed, "%</b> of all people who ever got tested positive."))

# create a simple 2-row table and finalize it
simple_table3 <- simple_table2 %>% 
  select(type, cases)
simple_table3 <-  as.data.frame(t(simple_table3)) %>%
  select(V3,V1,V2) %>%
  rename(deaths = V2, current = V1, recovered = V3) %>%
  select(current, deaths, recovered) %>%
  rename(V1 = current, V2 = deaths, V3 = recovered) %>%
  write_csv("worldwide-simple-table-2rows.csv")

# finalize the 4-row table
as.data.frame(t(simple_table2)) %>%
  select(V3,V1,V2) %>%
  rename(deaths = V2, current = V1, recovered = V3) %>%
  select(current, deaths, recovered) %>%
  rename(V1 = current, V2 = deaths, V3 = recovered) %>%
  write_csv("worldwide-simple-table.csv")


# ---------------------
# Stacked bar chart that shows the cases all over the world

stacked_bar_data <- all_cases

stacked_bar_data$region[is.na(stacked_bar_data$region)] <- stacked_bar_data$country[is.na(stacked_bar_data$region)]

stacked_bar_data = stacked_bar_data %>%
  select(region, current_cases, deaths, recovered) %>%
  pivot_longer(-region, names_to = "type", values_to = "cases") %>%
  group_by(region, type) %>%
  summarise(cases = sum(cases)) %>%
  pivot_wider(names_from = "type", values_from = "cases")

table_per_capita <- stacked_bar_data

# filter cases over 300 outside of China
stacked_bar = stacked_bar_data %>%
  filter(current_cases > 300 & region != "Others") %>%
  rename(`current confirmed cases` = current_cases) %>%
  
  # reordering columns
  select(region, `current confirmed cases`, deaths, recovered)

write_csv(stacked_bar, "countries-over-50-stackedbar.csv")


# ---------------------
# Table worldwide with all per-capita-cases

flag_icons <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=1821874908"))

table_per_capita3 <- merge(table_per_capita, flag_icons, by="region")

# continents <- table_per_capita3 %>%
#   group_by(continent) %>%
#   summarize(cases=sum(current_cases), 
#             deaths=sum(deaths), 
#             recovered=sum(recovered),
#             code = "") %>%
#   mutate(region=continent)
# 
# table_per_capita3 <- rbind(table_per_capita3, continents)

 
table_per_capita2 <- merge(table_per_capita3, population, by="region") %>%
  mutate(region = paste(code, region, sep=' ')) %>%
  # filter(!grepl("China",region)) %>%
  filter(current_cases != 0) %>%
  mutate(no_in_million = format(round(((current_cases*1000000)/population),digits=1), nsmall = 1)) %>%
  select(region, current_cases, no_in_million, deaths, recovered, continent) %>%
  rename(Country = region, 
         `Current confirmed cases` = current_cases,
         Deaths = deaths,
         `Recovered` = recovered,
         `that's like ... out of a million inhabitants` = no_in_million) %>%
  write_csv("worldwide-top-countries.csv")
  


# ---------------------
# G R O W T H   R A T E S 
# for table

all <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long) %>%
  pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  mutate(country = ifelse(country == "China" & province == "Hong Kong", "Hong Kong", country),
         continent = ifelse(country %in% european_countries, "Europe", "")) %>%
  select(-province, -continent) %>%
  arrange(date) %>%
  group_by(date, country) %>%
  mutate(confirmed = sum(confirmed)) %>%
  distinct() %>%
  ungroup() %>%
  filter(confirmed > 100 & country != "Cruise Ship") %>%
  group_by(country) %>%
  mutate(count = n()) %>%
  filter(count > 10) %>%
  select(-count) %>%
  arrange(country, date) %>%
  mutate() %>%
  group_by(country) %>%
  slice(n()-11, n()-6, n()) %>%
  mutate(pos = 1:n()) %>%
  select(-date) %>%
  pivot_wider(names_from = "pos", values_from = "confirmed") %>%
  mutate(first5days = (5*log(2))/(log(`2`/`1`)),
         last5days = (5*log(2))/(log(`3`/`2`)),
         change = case_when(
           between(first5days - last5days, -0.5, 0.5)  ~ "~",
           first5days - last5days < -3 ~ "▼▼",
           first5days - last5days < -0.5 ~ "▼",
           first5days - last5days > 3 ~ "▲▲",
           first5days - last5days > 0.5 ~ "▲"
         )) %>%
  select(country, last5days, first5days, change, `3`, `2`) %>%
  rename(region = country,
         `confirmed cases 6 days ago` = `2`,
         `confirmed cases yesterday` = `3`,
         `doubling time in the last five days` = last5days,
         `doubling time in the five days before that` = first5days) %>%
  ungroup() %>%
  mutate(region=recode(region, `Korea, South`="South Korea"),
         region=recode(region, `US`="United States"))

all_growthrates <- merge(all, flag_icons, by="region") %>%
  mutate(region = paste(code, region, sep=' ')) %>%
  select(-code) %>%
  rename(country = region) %>%
  write_csv("growth_rates.csv")

