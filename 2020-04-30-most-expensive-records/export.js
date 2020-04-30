const fs = require('fs');
const json = require('./final100.json');

let output = 'Artist;Title;Sold for (in USD);Released in;Image\n';

json.forEach((item) => {
    const title = `[${item.title}](${item.url})`;

    // you need to enter a path where you will host images
    const path = 'https://your/path';
    const imageUrl = `${path}/${item.imageUrl
        .substring(item.imageUrl.lastIndexOf('/') + 1)
        .replace('.jpeg', '')}`;
    const image = `![${item.artist} – ${item.title}](${imageUrl})`;

    const date = date || 'Unknown';

    output += `${item.artist};${title};${item.price};${item.date};${image}\n`;
});

fs.writeFile('final.csv', output, (error) => {
    if (error) throw error;
    console.log('File written!');
});
