## Download and process excess mortality data

A set of simple R scripts for processing excess mortality data from two different sources for use in Datawrapper:

- [Short-term Mortality Fluctuations (STMF) from The Human Mortality Database](https://mortality.org)
- [The NYT repo of data on excesss death during the coronavirus pandemic](https://github.com/nytimes/covid-19-data/tree/master/excess-deaths)

The scripts were used for creating the charts in the following blog post: [The coronavirus death toll](https://blog.datawrapper.de/weekly-chart-covid19-excess-mortality/).

### How to use the scripts: 

- There's one script per region
- Run them in R-Studio to prepare wide table CSV files for the respective regions
- CSV files get stored into `./data`. 
- Upload those files to [Datawrapper](https://datawrapper.de) to create charts
