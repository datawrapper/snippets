Read the Article [Visualizing my musical journey](https://blog.datawrapper.de/musical-genre-timeline/) on the Datawrapper blog.

---

# Historic Tag Timeline

Generate a ranking of top tags for each year based on the nr. 1 tag of artists you listend to.

WARNING: this script is quite hacky. maybe I'll create a user-friendly website for directly generating the graph from a last.fm user name.

PREREQUISITE: You need to have [Node.JS](https://nodejs.org/) installed on your system

## getting the data

1. clone the repo
1. export a CSV of all your scrobbles from https://mainstream.ghan.nl/export.html and put it somewhere in this folder
1. update the `SCROBBLES_CSV` variable inside `index.js` to match your downloaded filename
1. ???
1. run `npm install`
1. run `node index.js > out.csv` to get your tag ranking

## visualizing the data with Datawrapper

1. go to https://app.datawrapper.de/create/chart and paste the .csv file contents there or upload it
1. proceed to step 3
1. select "Lines" as Chart type and click "transpose the data" below, then proceed.
1. under "Vertical axis" set a "Custom range" of "30 - 1" to make first place appear on top. you can also set "Number format" to "1st" and create custom ticks like "1,2,3,4,5,10,20,30"
1. under "Customize lines" you can set "Interpolation" to "curved" to recreate the vibe of the original tag timeline
1. under "Labeling" click "Show advanced options" and tick "Customize tooltip formats" then for "dates (x)" select "2015, 2016" and for "values (y)" select "1st"
