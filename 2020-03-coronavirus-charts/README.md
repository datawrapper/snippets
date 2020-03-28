# Edits 

Here you can find our latest changes to the charts, maps, and tables in the Datawrapper article ["17 (or so) responsible live visualizations about the coronavirus, for you to use"](https://blog.datawrapper.de/coronaviruscharts/). (We don't mention when we fix obvious bugs that appear because the data source changes e.g. how it formats data.)

The R script might always not up to date; we'll push it every few days to this repo. 

#### March 28
- Added a line chart of the growth rate of deaths. 
- Did some housecleaning, so that the article doesn't load too long: 
	- Removed the chart showing doubling times of confirmed _cases_ and the chart showing growth rates on confirmed _cases_, but linked to them in case readers are still interested. They still get updated 	every day. 
	- Removed the map of confirmed cases in Chinese regions, because it doesn't add much new information anymore. It still gets updated and you can find it [here](https://www.datawrapper.de/_/5ASge/) and [in the River](https://river.datawrapper.de/_/5ASge) if you want to re-use it.
	- Replaced the US county map with an US state map. You can still find the US county map [here](https://www.datawrapper.de/_/WmR3P/) and [in the River](https://river.datawrapper.de/_/WmR3P).

#### March 25
- Updated all maps & map tooltips to only show confirmed cases and deaths, not recoveries anymore.  

#### March 24
- Changed the area chart "New confirmed COVID–19 cases, per day" to an area chart "New confirmed COVID–19 _deaths_, per day".

#### March 24

- Today is a sad day: Johns Hopkins university [decided](https://github.com/CSSEGISandData/COVID-19/issues/1250) to **not track recovered cases anymore**, so we removed them from all our visualizations. (You can still find the historical number of recoveries [here](https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv).) Many countries (e.g. Germany) haven't properly reported recovered cases, so these numbers were likely too low anyway. But now our visualizations look like there are no recoveries at all – so we added bold text over some of them stating that lots of people recovered already. The following three changes were made due to the change in the Johns Hopkins data:
	- Changed the stacked bar charts to split bar charts.
	- Removed the area chart showing current cases, deaths and recoveries worldwide, since it's too similar to the line chart now. 
	- Removed the table "Current cases, recoveries and deaths in selected countries", since it's now too similar to the sorted table "Current cases, recoveries and deaths in all countries"

- In addition: Added the line chart "Growth rate of confirmed cases in selected countries" 
- Added the area chart "New confirmed COVID–19 cases, per day"
- Added a chart showing doubling times of _deaths_.


#### March 23

- Replaced table at the top with the table from [the last Weekly Chart](/weekly-chart-coronavirus-doublingtimes/) because it gives a more nuanced view on doubling times and new confirmed cases. 
- Deleted the two outdated maps from Germany. You can still find them here: symbol map of individual confirmed cases](https://www.datawrapper.de/_/iSPw2/) / [confirmed cases in Berlin](https://www.datawrapper.de/_/E23mz/).
- We now show US cases on the county level, not the state level.
- The line chart showing doubling rates at the top of this article now includes more countries and updates automatically.

#### March 20

- Added a stacked bar chart of the number of confirmed cases, deaths & recoveries by continent 

#### March 18

- Moved the most interesting charts and tables to the top, so that it's easier to see them when loading the page.
- Added a column chart showing confirmed current cases, recoveries and deaths over time for **Spain**.
- Added a table showing doubling times of cases.
- Changed the title from "17 responsible live visualizations about the coronavirus, for you to use" to "17 (or so) responsible live visualizations about the coronavirus, for you to use".


#### March 16

- Changed the charts showing cases over time in Europe, Italy and Germany back from WHO data to Johns Hopkins data with an annotation & note that the March 12 and March 13 data is unreliable. Added the same annotation for the area and line chart showing cases worldwide. Unfortunately, Johns Hopkins still didn't change the incorrect data for the two dates, but they've added reliable-looking data since then; and they're still one of the few sources showing recovered cases. Now that the charts themselves point out the wrong data, we removed the disclaimers in the article.

#### March 15

- Changed the stacked bar chart to show countries with more than 300 cases instead of countries with more than 50 cases. (The stacked bar chart had become too long.)
- Added Spain to the table "Coronavirus COVID-19 cases in selected countries"

#### March 14

- Added a disclaimer at the top of the article: "Johns Hopkins university, the source of almost all of the charts, maps and tables below, is [currently experiencing technical issues](https://github.com/CSSEGISandData/COVID-19/issues/650). **The visualizations that show cases in the US, in China and worldwide over time are therefore incorrect.** If you're using them in your articles, please inform your readers about the issue. The charts that show cases in Europe, Italy and Germany over time now use [WHO data](https://experience.arcgis.com/experience/685d0ace521648f8a5beeeee1b9125cd)."
- Changed the source from Johns Hopkins data to WHO data for charts showing cases over time in Europe, Italy and Germany. Unfortunately, the WHO data doesn't give us the number of recovered people. We will switch back to Johns Hopkins data as soon as they resolved their technical issues. 
- Added a disclaimer that the maps with individual cases in Germany are not updated anymore.

#### March 13

- Included the Czech Republic to the symbol map of Europe (finally).
- Brought back the column chart of Chinese cases, deaths & recoveries over time.
- The Johns Hopkins University [didn't properly update](https://github.com/CSSEGISandData/COVID-19/issues/619) the numbers for **73 countries** for March 12. Our maps and charts heavily rely on them, since we don't have the capacity to research all these cases ourselves. We hope they'll offer the correct numbers again, soon, and will update you if they don't. 
- The Robert Koch Institute keeps changing the format in which they show the [official numbers](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html) for **Germany**. We try to keep up and change our scraper, but we can't monitor it all the time. If the symbol map for Germany looks weird, please get in contact with us on Twitter at [@datawrapper](https://twitter.com/datawrapper). Thank you. 
- We also published a [Weekly Chart yesterday](/weekly-chart-coronavirus-growth/) that explains why #FlattenTheCurve is so important. Feel free to re-use it, too. You can find it at the top of this article.


#### March 11

- Added a map of Berlin.
- Symbol maps now state the number of recovered and died COVID–19 patients in the tooltip.

#### March 9

- Fixed a bug that disabled the live updates when clicking on "Edit this chart".
- Added Schleswig-Holstein to the map of German cases by state.
- Added another very simple table without the relative terms.
- Added a table with all countries.
- Added a column chart with cases in Italy.
- Added links to other data visualization designer who have thought about visualizing the coronavirus.
- Added information about the licensing of Johns Hopkins data.
- Edited information about the source of German maps.
