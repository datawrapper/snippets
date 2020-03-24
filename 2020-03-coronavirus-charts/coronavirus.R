# ---------------------
# This is the R script that generates the charts, maps and tables for the Datawrapper blog post http://blog.datawrapper.de/coronavirus-charts, written by Lisa Charlotte Rost.

# This is NOT great R code. It works, but much of it could have been achieved with shorter code, more elegant, more efficiently, less confusing and without so many libraries; especially the further you go down the script (I got better in the process, among others thanks to my coworker Gregor Aisch who's still a R pro). Please don't use this code to learn R.


# ---------------------
# load libraries
needs(dplyr, readr, reshape2, jsonlite, data.table, tidyr, htmltab, zoo)
# ^ if this command fails, run
# source("./needs.R")

# disable scientific notation
options(scipen = 999)

setwd('./data/coronavirus/')

options(tz="Europe/London")
Sys.setenv(TZ="Europe/London")
Sys.setlocale("LC_CTYPE", "en_US.UTF-8")



# -------------------------------------------
# C  O  L  U  M  N    C  H  A  R  T  S 
# -------------------------------------------
message("column charts") 

# with data by 
# J O H N S  H O P K I N S 

# --------------------
# Column chart functions

download_data_and_filter <- function(case_type, shown_country) {
  read_csv(url(sprintf("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_%s_global.csv", case_type))) %>%
    filter(`Country/Region` == shown_country) %>%
    rename(country = `Country/Region`,
           province = `Province/State`) %>%
    select(-Lat, -Long) %>%
    pivot_longer(-c(country, province), names_to = "date", values_to = case_type) %>%
    mutate(date = as.Date(date, "%m/%d/%y")) %>%
    group_by(date) %>%
    arrange(date) %>%
    summarise_at(case_type, sum) %>%
    mutate_at(case_type, ~ifelse(date == "2020-03-12", lag(.) + (lead(.)-lag(.))/2, .))
}

download_data_and_filter_multiple <- function(case_type, shown_country) {
  read_csv(url(sprintf("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_%s_global.csv", case_type))) %>%
    filter(`Country/Region` %in% shown_country) %>%
    rename(country = `Country/Region`,
           province = `Province/State`) %>%
    select(-Lat, -Long) %>%
    pivot_longer(-c(country, province), names_to = "date", values_to = case_type) %>%
    mutate(date = as.Date(date, "%m/%d/%y")) %>%
    group_by(date) %>%
    arrange(date) %>%
    summarise_at(case_type, sum) %>%
    mutate_at(case_type, ~ifelse(date == "2020-03-12", lag(.) + (lead(.)-lag(.))/2, .))
}

download_data <- function(case_type) {
  read_csv(url(sprintf("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_%s_global.csv", case_type))) %>%
    rename(country = `Country/Region`,
           province = `Province/State`) %>%
    select(-Lat, -Long) %>%
    pivot_longer(-c(country, province), names_to = "date", values_to = case_type) %>%
    mutate(date = as.Date(date, "%m/%d/%y")) %>%
    group_by(date) %>%
    arrange(date) %>%
    summarise_at(case_type, sum) %>%
    mutate_at(case_type, ~ifelse(date == "2020-03-12", lag(.) + (lead(.)-lag(.))/2, .))
}

join_and_export <- function(country_name_for_csv) {
  full_join(confirmed, deaths, by="date") %>%
    arrange(date) %>%
    mutate(`new confirmed cases` = confirmed - lag(confirmed),
           `deaths` = deaths - lag(deaths)) %>%
    select(date, `new confirmed cases`, deaths) %>%
    mutate(`new confirmed cases` = case_when(
      date == "2020-03-12" ~ (lead(`new confirmed cases`)+`new confirmed cases`)*0.44,
      date == "2020-03-13" ~ (lag(`new confirmed cases`) +`new confirmed cases`)*0.56,
      date != "2020-03-12" & date != "2020-03-13" ~ `new confirmed cases`)) %>%
    write_csv(sprintf("%s-current-recov-death-per-day.csv", country_name_for_csv))
}

join_and_correct <- function(data) {
  data %>%
    arrange(date) %>%
    mutate(confirmed = confirmed - lag(confirmed)) %>%
    select(date, confirmed) %>%
    mutate(confirmed = case_when(
      date == "2020-03-12" ~ (lead(confirmed)+confirmed)*0.44,
      date == "2020-03-13" ~ (lag(confirmed) +confirmed)*0.56,
      date != "2020-03-12" & date != "2020-03-13" ~ confirmed))
}

# ---------------------
# New cases and deaths per day, WORLDWIDE
# AND new cases, recoveries and deaths YESTERDAY
# for column chart https://app.datawrapper.de/chart/7o2fN/visualize

confirmed <- download_data("confirmed")
deaths <- download_data("deaths")

full_join(confirmed, deaths, by="date") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  arrange(date) %>%
  select(date, confirmed, deaths) %>%
  write_csv("worldwide_cumulative-current-recov-death-per-day.csv")

yesterday <- join_and_export("worldwide") %>%
  write_csv("worldwide-cases-per-day.csv") %>%

  # New cases and deaths YESTERDAY
  filter(row_number()==n()) %>%
  select(date, `new confirmed cases`, deaths) %>%
  mutate(date = as.Date(date, "%Y-%m-%d")) %>%
  mutate(date = format(date, "Numbers for yesterday, %A, %B %d"))

yesterday = as.data.frame(t(yesterday))
yesterday = setDT(yesterday, keep.rownames = TRUE)[] %>%
  mutate(rn=recode(rn, "date"=" "),
         rn=recode(rn, "new confirmed cases" = "Yesterday, this many new people <b>got tested positive</b> for COVID-19:"),
         rn=recode(rn, "deaths"="And at least this number of people <b>died from the virus</b>:")) %>%
  write_csv("worlwide-current-recov-death-yesterday.csv")


# ---------------------
# New cases, recoveries and deaths per day, Spain, for column chart
confirmed <- download_data_and_filter("confirmed", "Spain")
deaths <- download_data_and_filter("deaths", "Spain")
join_and_export("spain")

# ---------------------
# New cases, recoveries and deaths per day, US, for column chart
confirmed <- download_data_and_filter("confirmed", "US")
deaths <- download_data_and_filter("deaths", "US")
join_and_export("us")

# ---------------------
# New cases, recoveries and deaths per day, Germany, for column chart
confirmed <- download_data_and_filter("confirmed", "Germany")
deaths <- download_data_and_filter("deaths", "Germany")
join_and_export("germany")

# ---------------------
# New cases, recoveries and deaths per day, China, for column chart
confirmed <- download_data_and_filter("confirmed", "China")
deaths <- download_data_and_filter("deaths", "China")
join_and_export("china")

# ---------------------
# New cases, recoveries and deaths per day, Italy, for column chart
confirmed <- download_data_and_filter("confirmed", "Italy")
deaths <- download_data_and_filter("deaths", "Italy")
join_and_export("italy")


# ---------------------
# New cases, recoveries and deaths per day, for seleced countries, for column chart

columnchart_countries <- c("Italy", "Spain", "Germany", "US", "United Kingdom", "Switzerland", "Austria", "China", "Iran", "France", "Korea, South", "Belgium", "Netherlands", "Canada")
columnchart_africa <- c("Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi", "Cabo Verde", "Cameroon", "Central African Republic", "Chad", "Comoros", "Côte d'Ivoire", "Congo (Kinshasa)", "Djibouti", "Egypt", "Equatorial Guinea", "Eritrea", "Ethiopia", "French Southern Territories", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Mayotte", "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria", "Congo (Brazzaville)", "Rwanda", "Réunion", "Saint Helena, Ascension and Tristan da Cunha", "Sao Tome and Principe", "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan", "Swaziland", "Tanzania", "Togo", "Tunisia", "Uganda", "Western Sahara", "Zambia", "Zimbabwe", "Eswatini")
columnchart_asia <- c("Afghanistan", "Armenia", "Azerbaijan", "Bahrain", "Bangladesh", "Bhutan", "British Indian Ocean Territory", "Brunei", "Cambodia", "Christmas Island", "Cocos (Keeling) Islands", "Georgia", "Hong Kong", "India", "Indonesia", "Iraq", "Israel", "Japan", "Jordan", "Kazakhstan", "Kuwait", "Kyrgyzstan", "Laos", "Lebanon", "Macau", "Malaysia", "Maldives", "Mongolia", "Myanmar", "Nepal", "North Korea", "Oman", "Pakistan", "Philippines", "Qatar", "Saudi Arabia", "Singapore", "Sri Lanka", "Palestine", "Syrian Arab Republic", "Taiwan", "Tajikistan", "Thailand", "Timor-Leste", "Turkey", "Turkmenistan", "United Arab Emirates", "Uzbekistan", "Vietnam", "Yemen", "Hubei, China", "China without Hubei", "Syria")
columnchart_oceania <- c("American Samoa", "Australia", "Cook Islands", "Federated States of Micronesia", "Fiji", "French Polynesia", "Guam", "Kiribati", "Marshall Islands", "Nauru", "New Caledonia", "New Zealand", "Niue", "Norfolk Island", "Northern Mariana Islands", "Palau", "Papua New Guinea", "Pitcairn", "Samoa", "Solomon Islands", "Tokelau", "Tonga", "Tuvalu", "Vanuatu", "Wallis and Futuna")
columnchart_southamerica <- c("Argentina", "Aruba", "Bolivia", "Bonaire, Sint Eustatius and Saba", "Brazil", "Chile", "Colombia", "Curaçao", "Ecuador", "Falkland Islands", "French Guiana", "Guyana", "Paraguay", "Peru", "Suriname", "Trinidad and Tobago", "Uruguay", "Venezuela")
columnchart_northamerica <- c("Anguilla", "Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Bermuda", "Cayman Islands", "Costa Rica", "Cuba", "Dominica", "Dominican Republic", "El Salvador", "Greenland", "Grenada", "Guadeloupe", "Guatemala", "Haiti", "Honduras", "Jamaica", "Martinique", "Mexico", "Montserrat", "Nicaragua", "Panama", "Puerto Rico", "Saint Barthelemy", "Saint Kitts and Nevis", "Saint Lucia", "St. Martin", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Sint Maarten", "Turks and Caicos Islands", "United States Minor Outlying Islands", "Virgin Islands (British)", "Virgin Islands (U.S.)")
columnchart_europe <- c("Aland Islands", "Albania", "Andorra", "Belarus", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Faroe Islands", "Finland", "Macedonia", "Gibraltar", "Greece", "Guernsey", "Holy See", "Hungary", "Iceland", "Ireland", "Isle of Man", "Jersey", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Malta", "Moldova", "Monaco", "Montenegro", "Norway", "Poland", "Portugal", "Romania", "Russia", "San Marino", "Serbia", "Slovakia", "Slovenia", "Svalbard and Jan Mayen", "Sweden", "Ukraine")

confirmed_africa <- download_data_and_filter_multiple("confirmed", columnchart_africa) %>%
  join_and_correct() %>%
  rename(`Africa` = confirmed)
confirmed_asia <- download_data_and_filter_multiple("confirmed", columnchart_asia) %>% 
  join_and_correct() %>%
  rename(`Other Asian countries` = confirmed)
confirmed_europe <- download_data_and_filter_multiple("confirmed", columnchart_europe) %>% 
  join_and_correct() %>%
  rename(`Other European countries` = confirmed)
confirmed_northamerica <- download_data_and_filter_multiple("confirmed", columnchart_northamerica) %>% 
  join_and_correct() %>%
  rename(`Other North-American countries` = confirmed)
confirmed_oceania <- download_data_and_filter_multiple("confirmed", columnchart_oceania) %>% 
  join_and_correct() %>%
  rename(`Australia & Oceania` = confirmed)
confirmed_southamerica <- download_data_and_filter_multiple("confirmed", columnchart_southamerica) %>% 
  join_and_correct() %>%
  rename(`South America` = confirmed)

confirmed <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")) %>%
  filter(`Country/Region` %in% columnchart_countries) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long, -province) %>%
  pivot_longer(-country, names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  group_by(country, date) %>%
  summarise(confirmed = sum(confirmed)) %>%
  arrange(country, date) %>%
  mutate(confirmed = ifelse(date == "2020-03-12", lag(confirmed) + (lead(confirmed)-lag(confirmed))/2, confirmed)) %>%
  mutate(new_cases = confirmed - lag(confirmed)) %>%
  select(date, new_cases) %>%
  mutate(new_cases = case_when(
    date == "2020-03-12" ~ (lead(new_cases)+ new_cases)*0.40,
    date == "2020-03-13" ~ (lag(new_cases) + new_cases)*0.50,
    date != "2020-03-12" & date != "2020-03-13" ~ new_cases)) %>%
  pivot_wider(names_from = "country", values_from = "new_cases") %>%
  rename("South Korea" = "Korea, South") %>%
  full_join(confirmed_africa, by="date") %>%
  full_join(confirmed_asia, by="date") %>%
  full_join(confirmed_europe, by="date") %>%
  full_join(confirmed_oceania, by="date") %>%
  full_join(confirmed_northamerica, by="date") %>%
  full_join(confirmed_southamerica, by="date") %>%
  select(date, China, `South Korea`, Iran, `Other Asian countries`, 
         Italy, Germany, France, Spain, Belgium, Netherlands, Austria, `United Kingdom`, Switzerland, `Other European countries`, 
         US, Canada, `Other North-American countries`, 
         `South America`, Africa, `Australia & Oceania`) %>%
  write_csv("cases-per-day-selected-countries.csv")


# ---------------------
message("New cases, recoveries and deaths per day, Europe, for column chart") 

european_countries <- c("Aland", "Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Faroe Islands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey", "Hungary", "Iceland", "Ireland", "Isle of Man", "Italy", "Jersey", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "North Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Republic of Serbia", "Romania", "San Marino", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "UK", "Vatican")

confirmed <- download_data_and_filter_multiple("confirmed", european_countries)
deaths <- download_data_and_filter_multiple("deaths", european_countries)
join_and_export("europe")



# -------------------------------------------
# S  Y  M  B  O  L     M  A  P  S 
# -------------------------------------------


# ---------------------
# R O B E R T  K O C H
message("Germany, cases per state, symbolmap") 

# old
# RKI_cases <- htmltab(doc = "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html"), which = "//th[text() = 'Bundesland']/ancestor::table") %>%

# load data from Robert Koch Institute
RKI_cases <- htmltab(doc = "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html") %>%
  rename(german_name = 1) %>%
  mutate(german_name = as.character(as.factor(german_name)))

# load German population from Wikipedia
RKI_german_population <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=1965358030")) %>%
  mutate(german_name = as.character(as.factor(german_name)))

merge(RKI_cases,RKI_german_population,by="german_name") %>%
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
# Get data from the John Hokins DASHBOARD for maps
# source: https://twitter.com/mathdroid/status/1234838261995950080
all_cases <- fromJSON("https://covid19.mathdro.id/api/confirmed", flatten=TRUE) %>%
  select(provinceState, countryRegion, lastUpdate, lat, long, confirmed, deaths, combinedKey) %>%
  mutate(countryRegion=recode(countryRegion, `Iran (Islamic Republic of)`="Iran"),
         countryRegion=recode(countryRegion, `Mainland China`="China"),
         countryRegion=recode(countryRegion, `UK`="United Kingdom"),
         countryRegion=recode(countryRegion, `North Macedonia`="Macedonia"),
         countryRegion=recode(countryRegion, `Bahamas, The`="Bahamas"),
         countryRegion=recode(countryRegion, `Cote d'Ivoire`="Côte d'Ivoire"),
         countryRegion=recode(countryRegion, `Taiwan*`="Taiwan"),
         countryRegion=recode(countryRegion, `Gambia, The`="Gambia"),
         countryRegion=recode(countryRegion, `Korea, South`="South Korea")) %>%
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


# --------------------
# Symbol map functions

convert_lastUpdate <- function(data) {
  data %>%
    mutate(lastUpdate = as.POSIXct(lastUpdate/1000, origin="1970-01-01 00:00")) %>%
    mutate(lastUpdate = as.Date(lastUpdate, "%m/%d/%y"))
}

select_columns <- function(data) {
  data %>%
    mutate(region = combinedKey) %>%
    select(-province, -country) %>%
    rename(cases = confirmed) %>%
    select(lat, long, region, cases, deaths, lastUpdate) %>%
    convert_lastUpdate()
}

merge_with_US_coordinates <- function(data) {
  data %>%
    full_join(add_US_states, by="region")  %>%
    drop_na(cases) %>%
    mutate(lat = ifelse(!is.na(lat2), lat2, lat),
           long = ifelse(!is.na(long2), long2, long)) %>%
    select(-lat2, -long2) %>%
    filter(lat != 0)
}


# ---------------------
message("Symbol map of CONFIRMED & RECOVERED cases worldwide") 

add_US_states <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=1343425558"))

all_cases %>%
  select(country, combinedKey, province, lastUpdate, lat, long, confirmed, deaths) %>%
  pivot_longer(-c(country, combinedKey, province, lastUpdate, lat, long), names_to = "type", values_to = "cases") %>%
  group_by(country, province, type) %>%
  mutate(cases = sum(cases)) %>%
  mutate(combinedKey = ifelse(country == "US", paste(province, country, sep = ", "), combinedKey)) %>%
  distinct(combinedKey, type, .keep_all = TRUE) %>%
  ungroup() %>%
  select(lat, long, combinedKey, cases, type, lastUpdate) %>%
  convert_lastUpdate() %>%
  rename(region = combinedKey) %>%
  merge_with_US_coordinates() %>%
  write_csv("worldwide-recov-conf-symbolmap.csv")


# ---------------------
# Symbol map of current confirmed cases in US

all_cases %>%
  filter(country == "US") %>%
  select_columns() %>%
  merge_with_US_coordinates() %>%
  write_csv("us-symbolmap.csv")


# ---------------------
# Symbol chart of current confirmed cases in CHINA

all_cases %>%
  filter(country == "China") %>%
  select_columns() %>%
  write_csv("china-symbolmap.csv")


# ---------------------
message("Symbol map of current confirmed cases in EUROPE") 

european_countries <- c("Aland", "Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Faroe Islands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey", "Hungary", "Iceland", "Ireland", "Isle of Man", "Italy", "Jersey", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Republic of Serbia", "Romania", "San Marino", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "United Kingdom", "Vatican")

all_cases %>%
  filter(combinedKey %in% european_countries) %>%
  select_columns() %>%
  write_csv("europe-symbolmap.csv")



# -------------------------------------------
# T  A  B  L  E  S 
# -------------------------------------------

# ---------------------
message("Table that shows the confirmed / deaths / current confirmed cases in the main infected areas and in the rest of the world, compared with the population") 
# Source for population data: https://population.un.org/wpp/Download/Standard/Population/

table <- all_cases %>%
  mutate(region = replace_na(region, "rest-of-world")) %>%
  select(region, confirmed, deaths) %>%
  pivot_longer(-region, names_to = "type", values_to = "cases") %>%
  group_by(region, type) %>%
  summarise(cases = sum(cases)) %>%
  pivot_wider(names_from = "type", values_from = "cases") %>%

  # sum up to get confirmed for the whole world
  ungroup() %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "World")))

# add population numbers
simple_table <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv")) %>%
  mutate(population = as.integer(population)) %>%
  full_join(table, by="region", keep=TRUE) %>%
  drop_na(confirmed) %>%
  mutate(population = ifelse(region == "rest-of-world", 5679690897, population),
         population = ifelse(region == "World", 7794798739, population),
         confirmed_rel = population/confirmed,
         confirmed_rel_nice = floor(confirmed_rel / 10) * 10) %>%
  select(-confirmed_rel, -population) %>%
  arrange(as.numeric(confirmed_rel_nice)) %>%
  rename(`Total confirmed cases` = confirmed, 
         `One in ... people is confirmed to have or have had the virus` = confirmed_rel_nice) %>%
  arrange(desc(region))

table <- simple_table %>%
  select(region, `Total confirmed cases`, deaths,`One in ... people is confirmed to have or have had the virus`)

table$region[table$region == "Hubei, China"] <- ":cn: Hubei ^Province in China^"
table$region[table$region == "China without Hubei"] <- ":cn: China ^without Hubei^"
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
message("Overview table showing just current / deaths") 

simple_table2 <- subset(simple_table, region=="World") %>%
  rename(rel = `One in ... people is confirmed to have or have had the virus`,
         Deaths = deaths) %>%
  select(-rel, -region) %>%
  mutate(extracolumn = 1) %>%
  pivot_longer(-extracolumn, names_to = "type", values_to = "cases") %>%
  select(-extracolumn) %>%
  mutate(relative = 100 / 7794798739 * cases,
         rel_nice = floor(7794798739 / cases / 1000) * 1000) %>%
  mutate(cases = format(round(as.numeric(cases), 0), big.mark=","),
         relative = format(round(as.numeric(relative), 4), big.mark=","),
         rel_nice = format(round(as.numeric(rel_nice), 0), big.mark=","),
         relative = paste0("that's <b>", relative, "%</b> of humanity"),
         rel_nice = paste0("or one in <b>",rel_nice, "</b> humans"))

# create a simple 2-row table and finalize it
simple_table3 <- simple_table2 %>%
  select(type, cases)
as.data.frame(t(simple_table3)) %>%
  write_csv("worldwide-simple-table-2rows.csv")

# finalize the 4-row table
as.data.frame(t(simple_table2)) %>%
  write_csv("worldwide-simple-table.csv")


# ---------------------
message("Stacked bar chart that shows the cases all over the world") 

stacked_bar_data <- all_cases

stacked_bar_data$region[is.na(stacked_bar_data$region)] <- stacked_bar_data$country[is.na(stacked_bar_data$region)]

stacked_bar_data = stacked_bar_data %>%
  select(region, confirmed, deaths) %>%
  pivot_longer(-region, names_to = "type", values_to = "cases") %>%
  group_by(region, type) %>%
  summarise(cases = sum(cases)) %>%
  pivot_wider(names_from = "type", values_from = "cases")

table_per_capita <- stacked_bar_data

# filter cases over 1000 outside of China
stacked_bar = stacked_bar_data %>%
  filter(confirmed > 1000 & region != "Others") %>%
  rename(`total confirmed cases` = confirmed) %>%
  select(region, `total confirmed cases`, deaths) %>%
  write_csv("countries-over-50-stackedbar.csv")


# ---------------------
message("Table worldwide with all per-capita-casese") 

flag_icons <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=1821874908"))
german_names <-read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=1297230128"))
population <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=0"))

table_per_capita3 <- table_per_capita %>%
  full_join(flag_icons, by="region") %>%
  drop_na(confirmed) %>%
  filter(region != "Cruise Ship") %>%
  ungroup()

continents <- table_per_capita3 %>%
  group_by(continent) %>%
  summarize(confirmed=sum(confirmed),
            deaths=sum(deaths),
            code = "") %>%
  select(-code) %>%
  rename(Continent = continent,
         Deaths = deaths,
         `Total confirmed cases` = confirmed) %>%
  write_csv("continents.csv")

table_per_capita2 <- table_per_capita3 %>% 
  full_join(population, by="region") %>%
  full_join(german_names, by="region") %>%
  mutate(region = paste(code, region, sep=' ')) %>%
  mutate(region_de = paste(code, region_de, sep=' ')) %>%
  # filter(!grepl("China",region)) %>%
  filter(confirmed != 0) %>%
  mutate(no_in_million = format(round(((confirmed*1000000)/population),digits=0), nsmall = 0))

table_per_capita_en <- table_per_capita2 %>%
    unique() %>%
    select(region, confirmed, no_in_million, deaths, continent) %>%
    rename(Country = region,
         `Total confirmed cases` = confirmed,
         Deaths = deaths,
         `that's like ... out of a million inhabitants` = no_in_million) %>%
  write_csv("worldwide-top-countries.csv")

table_per_capita_de <- table_per_capita2 %>%
    unique() %>%
    select(region_de, confirmed, no_in_million, deaths, continent) %>%
    mutate(continent=recode(continent, `Europe`="Europa"),
          continent=recode(continent, `Africa`="Afrika"),
          continent=recode(continent, `Asia`="Asien"),
          continent=recode(continent, `North America`="Nordamerika"),
          continent=recode(continent, `South America`="Südamerika"),
          continent=recode(continent, `Oceania`="Ozeanien")) %>%
    rename(Country = region_de,
           `Total confirmed cases` = confirmed,
           Deaths = deaths,
           `that's like ... out of a million inhabitants` = no_in_million) %>%
  write_csv("worldwide-top-countries-de.csv")


# ---------------------
# G R O W T H   R A T E S
# for table
# ---------------------
message("growth rates for table") 

all <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long) %>%
  pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  mutate(country = ifelse(country == "China" & province == "Hong Kong", "Hong Kong", country)) %>%
  select(-province) %>%
  arrange(date) %>%
  group_by(date, country) %>%
  mutate(confirmed = sum(confirmed)) %>%
  distinct() %>%
  ungroup() %>%
  filter(confirmed > 100 & country != "Cruise Ship") %>%
  group_by(country) %>%
  filter(n() > 11) %>%
  arrange(country, date) %>%
  mutate(confirmed = ifelse(date == "2020-03-12",lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, confirmed)) %>%
  slice(n()-10, n()-5, n()) %>%
  mutate(pos = 1:n()) %>%
  select(-date) %>%
  pivot_wider(names_from = "pos", values_from = "confirmed") %>%
  mutate(first5days = (5*log(2))/(log(`2`/`1`)),
         last5days = (5*log(2))/(log(`3`/`2`)),
         difference = first5days - last5days,
         change = case_when(
           between(100/first5days*last5days, 95, 110) ~ "~",
           100/first5days*last5days < 50 ~ "▲▲",
           100/first5days*last5days < 95 ~ "▲",
           100/first5days*last5days > 200 ~ "▼▼",
           100/first5days*last5days > 110 ~ "▼"
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


# ---------------------
# summed up number of cases last five days vs before
# for table
message("summed up number of cases last five days vs before for table") 

summed_up <-  read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")) %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long) %>%
  pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  mutate(country = ifelse(country == "China" & province == "Hong Kong", "Hong Kong", country)) %>%
  select(-province) %>%
  arrange(country, date) %>%
  group_by(country, date) %>%
  mutate(confirmed = sum(confirmed)) %>%
  distinct() %>%
  ungroup() %>%
  group_by(country) %>%
  mutate(confirmed = ifelse(date == "2020-03-12",
                            lag(confirmed)+(lead(confirmed)-lag(confirmed))/2,
                            confirmed),
         new_cases = confirmed - lag(confirmed),
         last5days = sum(new_cases[between(row_number(), n()-4, n())]),
         beforethat = sum(new_cases[between(row_number(), n()-9, n()-5)]),
         total = sum(new_cases, na.rm=TRUE),
         yesterday = new_cases[n()],
         change = case_when(
           between(100/beforethat*last5days, 98, 105) ~ "~",
           100/beforethat*last5days < 50 ~ "▼▼",
           100/beforethat*last5days < 98 ~ "▼",
           100/beforethat*last5days > 200 ~ "▲▲",
           100/beforethat*last5days > 105 ~ "▲"
         )) %>%
  ungroup() %>%
  select(country, yesterday, last5days, beforethat, change, total) %>%
  distinct() %>%
  mutate(country=recode(country, `Korea, South`="South Korea"),
         country=recode(country, `US`="United States")) %>%
  filter(country != "Cruise Ship",
         total > 9) %>%
  rename(region = country,
         `new confirmed cases in the last five days` = last5days,
         `new confirmed cases in the five days before that` = beforethat,
         `total confirmed cases` = total,
         `new confirmed cases yesterday` = yesterday)

all_summed_up <- merge(summed_up, flag_icons, by="region") %>%
  mutate(region = paste(code, region, sep=' ')) %>%
  select(-code) %>%
  rename(country = region) %>%
  write_csv("summed-up.csv")

# for weekly chart
all_together = merge(all_summed_up, all_growthrates, by=c("country", "continent")) %>%
  select(country, continent,
         `doubling time in the last five days`,
         `doubling time in the five days before that`,
         change.y,
         `new confirmed cases in the last five days`,
         `new confirmed cases in the five days before that`,
         change.x) %>%
  rename(`change in doubling time` = change.y,
         `change in confirmed cases` = change.x) %>%
  write_csv("doubling-and-summed-up.csv")


# # ---------------------
# # G R O W T H   R A T E S   F O R   U S   S T A T E S
# # for line chart
#
us_states <- read_csv(url("https://docs.google.com/spreadsheets/d/1YmIQVgr8RSim_zZ0jmZRji-1rFYN5l-ta3XbkOgePME/export?format=csv&gid=1139743542"))
#
# all <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")) %>%
#   rename(country = `Country/Region`,
#          province = `Province/State`) %>%
#   select(-Lat, -Long) %>%
#   pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
#   separate(province, c("province","abbrev"), sep = ',')
#
# yay <- merge(all, us_states, by="abbrev", all = TRUE)
#
#   mutate(province = ifelse(!is.na(state), state, province))
#   pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
#   mutate(date = as.Date(date, "%m/%d/%y")) %>%
#   mutate(country = ifelse(country == "China" & province == "Hong Kong", "Hong Kong", country),
#          continent = ifelse(country %in% european_countries, "Europe", "")) %>%
#   select(-province, -continent) %>%
#   arrange(date) %>%
#   group_by(date, country) %>%
#   filter()
#   mutate(confirmed = sum(confirmed)) %>%
#   distinct() %>%
#   ungroup() %>%
#   filter(confirmed > 100 & country != "Cruise Ship") %>%
#   arrange(country, date) %>%
#   mutate(confirmed = ifelse(date == "2020-03-12",lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, confirmed)) %>%
#   group_by(country) %>%
#   mutate(days = row_number()) %>%
#   select(-date) %>%
#   pivot_wider(names_from = "country", values_from = "confirmed") %>%
#   mutate(first5days = (5*log(2))/(log(`2`/`1`)),
#          last5days = (5*log(2))/(log(`3`/`2`)),
#          difference = first5days - last5days,
#          change = case_when(
#            between(first5days - last5days, -0.5, 0.5)  ~ "~",
#            first5days - last5days < -3 ~ "▼▼",
#            first5days - last5days < -0.5 ~ "▼",
#            first5days - last5days > 3 ~ "▲▲",
#            first5days - last5days > 0.5 ~ "▲"
#          )) %>%
#   select(country, last5days, first5days, change, `3`, `2`) %>%
#   rename(region = country,
#          `confirmed cases 6 days ago` = `2`,
#          `confirmed cases yesterday` = `3`,
#          `doubling time in the last five days` = last5days,
#          `doubling time in the five days before that` = first5days) %>%
#   ungroup() %>%
#   mutate(region=recode(region, `Korea, South`="South Korea"),
#          region=recode(region, `US`="United States"))
#
# all_growthrates <- merge(all, flag_icons, by="region") %>%
#   mutate(region = paste(code, region, sep=' ')) %>%
#   select(-code) %>%
#   rename(country = region) %>%
#   write_csv("growth_rates.csv")





# ---------------------
# G R O W T H   R A T E S   O V E R   T I M E 
# for line chart
message("G R O W T H   R A T E S   O V E R   T I M E  for line chart") 

linechart_doubling <- function(kind_of_cases, cases_threshold, days_threshold, doubling_threshold){
  
  doubling_times_all <- read_csv(url(sprintf("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_%s_global.csv", kind_of_cases))) %>%
    rename(country = `Country/Region`,
           province = `Province/State`) %>%
    select(-Lat, -Long) %>%
    pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
    mutate(date = as.Date(date, "%m/%d/%y")) %>%
    mutate(country = ifelse(country == "China" & province == "Hong Kong", 
                            "Hong Kong", country)) %>%
    select(-province) %>%
    arrange(date)
 
  doubling_times_all2 <- doubling_times_all %>% 
    filter(country %in% european_countries) %>%
    group_by(date) %>%
    summarise(confirmed = sum(confirmed)) %>%
    mutate(country = "Europe") %>%
    select(country, date, confirmed) %>%
    bind_rows(doubling_times_all) %>%
    group_by(date, country) %>%
    mutate(confirmed = sum(confirmed)) %>%
    distinct() %>%
    ungroup() %>%
    filter(country != "Cruise Ship") %>%
    arrange(country, date) %>%
    group_by(country) %>%
    mutate(confirmed = ifelse(date == "2020-03-12",
                              lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, 
                              confirmed),
           closest_to_100 = ifelse(confirmed-cases_threshold >= 0, 
                                   confirmed-cases_threshold, abs(confirmed-cases_threshold)),
           confirmed = ifelse(closest_to_100 == min(closest_to_100) & country != "China", 
                              cases_threshold, confirmed)) %>%
    filter(confirmed >= cases_threshold, max(confirmed > cases_threshold)) %>%
    mutate(days = ifelse(country =="China", 5:(n()+5), 0:n())) %>%
    select(-closest_to_100, -date) %>%
    filter(max(days) > days_threshold & days < 38) %>%
    ungroup() %>%
    pivot_wider(names_from = country, values_from = confirmed) %>%
    arrange(days) %>%
    mutate(`doubles every day` = cases_threshold*(2^(days)),
           `doubles every 2 days` = cases_threshold*(1+((2^(1/2))-1))^(days),
           `doubles every 3 days` = cases_threshold*(1+((2^(1/3))-1))^(days),
           `doubles every week` = cases_threshold*(1+((2^(1/7))-1))^(days),
           `doubles every month` = cases_threshold*(1+((2^(1/30.42))-1))^(days),
           `doubles every day` = ifelse(`doubles every day` > doubling_threshold, NA, `doubles every day`),
           `doubles every 3 days` = ifelse(`doubles every 3 days` > doubling_threshold, NA, `doubles every 3 days`),
           `doubles every 2 days` = ifelse(`doubles every 2 days` > doubling_threshold, NA, `doubles every 2 days`)) %>%
    mutate(days = paste("day", days, sep=' ')) %>%
    rename("South Korea" = "Korea, South") %>%
    write_csv(sprintf("%s-doubling-times.csv", kind_of_cases))
}

linechart_doubling("confirmed", 100, 10, 103400) 
linechart_doubling("deaths", 10, 5, 30340) 
 


# -------------
# Gregor's growth rate comparison line chart

read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv") %>%
  rename(country = `Country/Region`,
         province = `Province/State`) %>%
  select(-Lat, -Long) %>%
  pivot_longer(-c(country, province), names_to = "date", values_to = "confirmed") %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  mutate(country = ifelse(country == "China" & province == "Hong Kong",
                          "Hong Kong", country)) %>%
  select(-province) %>%
  arrange(date) %>%
  group_by(date, country) %>%
  mutate(confirmed = sum(confirmed)) %>%
  distinct() %>%
  ungroup() %>%
  filter(confirmed > 100 & country != "Cruise Ship" & country != 'China') %>%
  group_by(country) %>%
  filter(n() > 11) %>%
  arrange(country, date) %>%
  # fix values for March 12 by averaging the days before and after
  mutate(confirmed = ifelse(date == "2020-03-12",lag(confirmed)+(lead(confirmed)-lag(confirmed))/2, confirmed)) %>%
  arrange(date) %>%
  # compute growth rate for past 5 days
  mutate(growth = 100 * (confirmed/lag(confirmed, n=5)-1)) %>%
  # and take a 3-day rolling average from it
  mutate(growth = rollapplyr(growth, 3, mean, fill=NA)) %>%
  select(-confirmed, -doubling) %>%
  pivot_wider(names_from = "country", values_from = "growth") %>%
  filter(date > '2020-02-29') %>%
  arrange(date) %>%
  write_tsv('growth-rates.csv')


