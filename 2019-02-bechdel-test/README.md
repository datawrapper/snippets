# Bechdel test

This [node.js script](https://github.com/datawrapper/snippets/blob/master/2019-02-bechdel-test/script.js) does the following:

1. takes data obtained through the [Bechdel test website API](https://bechdeltest.com/api/v1/doc) (data can be obtained by running `curl http://bechdeltest.com/api/v1/getAllMovies > data.json`)
2. groups films by decade
3. calculates the percentage of films that pass different number of Bechdel test criteria for each decade
4. converts data to `CSV`

The following chart was created using the output data:

![Percentage of films that pass the Bechdel test is rising](https://img.datawrapper.de/Ztmoc/full.png)

### Related links

* [Interactive chart](https://www.datawrapper.de/_/Ztmoc/)
* [Weekly chart article](https://blog.datawrapper.de/weeklychart-bechdel-test/)

### Notes

You need to have [node.js](https://nodejs.org/en/) and [npm](https://www.npmjs.com/) installed on your system in order to run this script. Install required packages first by running `npm i`. Execute the script by running `node script.js`.
