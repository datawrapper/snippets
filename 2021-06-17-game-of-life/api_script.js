const { createWriteStream } = require('fs');
const { pipeline } = require('stream');
const { promisify } = require('util');
const fetch = require('node-fetch');
const glob = require('glob');
const fs = require('fs');

const streamPipeline = promisify(pipeline);

// Datawrapper chart id
const id = 'XXXXX';
// Datawrapper API token. Needs to have chart read and write permissions
const token = 'Bearer XXXX';

const dataUrl = `https://api.datawrapper.de/v3/charts/${id}/data`;
const dataOptions = {
    method: 'PUT',
    headers: {
        Accept: '*/*',
        'Content-Type': 'text/csv',
        Authorization: token
    }
};

const exportUrl = `https://api.datawrapper.de/v3/charts/${id}/export/png?plain=true`;
const exportOptions = {
    method: 'GET',
    headers: {
        Accept: 'image/png',
        Authorization: token
    }
};

async function uploadDataAndExportPng(csvFiles) {
    if (!csvFiles.length) return console.log('finished');
    const csvFile = csvFiles[0];
    const csv = fs.readFileSync(csvFile, 'utf-8');
    const stepName = csvFile.substr(csvFile.lastIndexOf('/') + 1).replace('.csv', '');

    const dataOptionsWithBody = { ...dataOptions };
    dataOptionsWithBody.body = csv;
    const uploadRes = await fetch(dataUrl, dataOptionsWithBody);
    if (!uploadRes.ok) throw new Error(`unexpected upload response ${uploadRes.statusText}`);

    const exportRes = await fetch(exportUrl, exportOptions);
    if (!exportRes.ok) throw new Error(`unexpected export response ${exportRes.statusText}`);
    await streamPipeline(exportRes.body, createWriteStream(`./${stepName}.png`));
    console.log(`${stepName}.png written`);

    csvFiles.shift();
    uploadDataAndExportPng(csvFiles);
}

const csvFiles = glob.sync('./*.csv');
uploadDataAndExportPng(csvFiles);
