const fs = require('fs');

// using `4` here so that end result looks close to the original artwork when chart is a square
const VERTICAL_GAP = 4;

fs.readFile('./pulsar_sorted.csv', 'utf8', (err, data) => {
    let csvText = '';
    const transformRows = [];
    const rows = data.split('\n');
    rows.forEach((row, rowIndex) => {
        transformValues = [];
        const values = row.split(',');
        values.forEach((value) => {
            // here we add increasing vertical distance to each new row
            const add = !rowIndex ? 0 : rowIndex * VERTICAL_GAP;
            // we use `Math.max(x, 0)` to ensure no negative values
            const newValue = Math.max(+value + add, 0);
            transformValues.push(+newValue.toFixed(2));
        });
        transformRows.push(transformValues);
    });

    let currentHighest = [];
    transformRows.forEach((row, rowIndex) => {
        const values = [];
        // populate `currentHighest` with values from first row if empty
        if (!currentHighest.length) currentHighest = row;
        currentHighest = currentHighest.map((value, i) => {
            // find the higher value between currently saved highest and row
            const maxValue = Math.max(value, row[i]);
            values.push(maxValue);
            // save this value to `currentHighest` array
            return maxValue;
        });

        csvText += `${values.join(',')}\n`;
    });

    // add one more row to fill the background to the top (+ add some padding)
    const highestValue = Math.max(...currentHighest) + 10;
    const topAreaRow = currentHighest.map((value) => highestValue);
    csvText += `${topAreaRow.join(',')}\n`;

    fs.writeFile('./output.csv', csvText, (err) => {
        if (err) throw err;
    });
});
