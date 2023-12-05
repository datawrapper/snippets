# R script from the _Datawrapper API: A beginner's guide with R_ webinar
You'll find the R script to replicate the demo example [here](https://github.com/datawrapper/snippets/blob/master/2023-11-R-demo/R-script).

The script shows how to install the necessary packages and build a function `create_line_chart` that does the following:
1. load, clean and prepare data from the [German Weather Service](https://bookdown.org/brry/rdwd/#usage)
2. create a line chart
3. add data to the chart
4. edit the chart
5. publish the chart

Use that function to create multiple charts at once through a list of cities.

An example of the chart that's created by this function is shown below.

![Line chart of max and min temperatures in Potsdam](https://github.com/datawrapper/snippets/blob/master/2023-11-R-demo/daily-temperatures-potsdam.png)

You can read more about our API documentation [here](https://developer.datawrapper.de/docs/getting-started).
