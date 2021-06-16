const fs = require('fs');

const size = [36, 23]; // determines number of columns and rows in csv
const width = size[0];
const height = size[1];
const headers = [...Array(width).keys()];
const numSteps = 80;
let liveCells = [];

// following string is taken from https://www.conwaylife.com/patterns/gosperglidergun.cells
// more patterns can be found here: https://conwaylife.com/wiki/Category:Patterns
const data = `........................O
......................O.O
............OO......OO............OO
...........O...O....OO............OO
OO........O.....O...OO
OO........O...O.OO....O.O
..........O.....O.......O
...........O...O
............OO`;

function isLiveCell(pos) {
    return !!liveCells.find(cell => cell[0] === pos[0] && cell[1] === pos[1]);
}

function initLiveCells() {
    const dataRows = data.split('\n');
    for (let row = 0; row < dataRows.length; row++) {
        for (let col = 0; col < dataRows[row].length; col++) {
            const value = dataRows[row]?.[col];
            if (value === 'O') liveCells.push([col, row]);
        }
    }
}

function getNeighbors(pos) {
    const neighbors = [];
    for (let row = -1; row <= 1; row++) {
        for (let col = -1; col <= 1; col++) {
            if (!(row === 0 && col === 0)) neighbors.push([pos[0] + col, pos[1] + row]);
        }
    }
    return neighbors;
}

function updateLiveCells() {
    const positionsToCheckWithDupes = [];
    liveCells.forEach(liveCell => {
        const neighbors = getNeighbors(liveCell);
        positionsToCheckWithDupes.push(liveCell, ...neighbors);
    });
    const map = new Map();
    positionsToCheckWithDupes.forEach(item => map.set(item.join(), item));
    const positionsToCheck = Array.from(map.values());
    const newLiveCells = [];
    positionsToCheck.forEach(pos => {
        const neighbors = getNeighbors(pos);
        const numLiveNeighbors = neighbors.filter(neighborPos => isLiveCell(neighborPos)).length;
        if (numLiveNeighbors === 3 || (isLiveCell(pos) && numLiveNeighbors === 2)) {
            newLiveCells.push(pos);
        }
    });
    liveCells = newLiveCells;
}

function padWithZeros(step) {
    const stepDigits = step.toString().length;
    const totalStepsDigits = numSteps.toString().length;
    return '0'.repeat(totalStepsDigits - stepDigits);
}

function toCsv(step) {
    let text = headers.join(',');
    text += '\n';
    for (let row = 0; row < height; row++) {
        for (let col = 0; col < width; col++) {
            text += isLiveCell([col, row]) ? '1' : '0';
            if (col < width - 1) text += ',';
        }
        text += '\n';
    }
    const fname = `step-${padWithZeros(step)}${step}.csv`;
    fs.writeFile(`./${fname}`, text, err => {
        if (err) return console.log(err);
        console.log(`${fname} written`);
    });
}

for (let step = 0; step <= numSteps; step++) {
    if (step === 0) initLiveCells();
    else updateLiveCells();
    toCsv(step);
}
