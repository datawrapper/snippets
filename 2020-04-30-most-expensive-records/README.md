# Top 100 most expensive records sold on Discogs

This is a collection of node.js scripts used to scrape the Discogs blog to get a list of top 100 most expensive records sold on its marketplace.

The scripts need to be executed in the following order and do the following:

1. [get_top100_post.js](https://github.com/datawrapper/snippets/blob/master/2020-04-30-most-expensive-records/get_top100_post.js) outputs a list of releases in JSON format by scraping the top 100 blog post from March 2019
2. [get_monthly_posts.js](https://github.com/datawrapper/snippets/blob/master/2020-04-30-most-expensive-records/get_monthly_posts.js) outputs a list of releases in JSON format by scraping monthly top 30 posts from March 2019 to February 2020
3. [create_final100.js](https://github.com/datawrapper/snippets/blob/master/2020-04-30-most-expensive-records/create_final100.js) combines the two lists from above, sorts them by price and outputs the final top 100 list in JSON format
4. [download_images.js](https://github.com/datawrapper/snippets/blob/master/2020-04-30-most-expensive-records/download_images.js) downloads and resizes images from the final list
5. [export.js](https://github.com/datawrapper/snippets/blob/master/2020-04-30-most-expensive-records/export.js) formats final list and outputs the dataset in CSV format (you need to enter a path where you will host your images here)

The following table was created using the dataset:

![Top 100 most expensive music records sold on Discogs](https://img.datawrapper.de/klGf1/full.png)

### Related links

* [Interactive table](https://www.datawrapper.de/_/klGf1/)
* [Weekly chart article](https://blog.datawrapper.de/weekly-chart-top-100-expensive-music-records/)

### Notes

You need to have [node.js](https://nodejs.org/en/) and [npm](https://www.npmjs.com/) installed on your system in order to run these scripts. Install required packages first by running `npm i`. Execute the scripts by running `node [scriptname].js`.
