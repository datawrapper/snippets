# Automatic Updates for Live Data

This script is using the Alpha Vantage and Datawrapper API to update charts with new data and republish them. 
A guide can be found here: https://developer.datawrapper.de/docs/automatic-updates-for-live-data.

To run the script you need Node.js and `got` from npm.

Before the first run replace the following values:

* `API_KEY` - This is your Alpha Vantage API key. You can create a free one here https://www.alphavantage.co/support/#api-key.
* `CHART_ID` - The ID of the chart you want to update.
* `DW_TOKEN` - Your Datawrapper API Token. Check out how to create one here: https://developer.datawrapper.de/docs/getting-started#section-authentication

If you replaced these values you can run `node script.js`.
