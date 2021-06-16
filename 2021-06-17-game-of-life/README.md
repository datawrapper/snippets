# Game of Life

Includes the following Node.js scripts used in the Game of Life weekly chart:

- `csv_script.js`: takes an initial state and number of steps as inputs and outputs CSV data files for each step
- `api_script.js`: uses CSV data files to upload data and export a PNG image for each step. You will need to enter your own (existing) chart ID and an API token for this to work

### Notes

You need to have [Node.js](https://nodejs.org/en/) installed on your system in order to run these scripts. Install dependencies first by running `npm i`. Execute the script by running `node script.js`.
