const axios = require('axios');
const sharp = require('sharp');
const fs = require('fs');
const json = require('./final100.json');

json.forEach((item) => {
    const url = item.imageUrl;
    const fileName = url.substring(url.lastIndexOf('/') + 1).replace('.jpeg', '');
    const resizer = sharp().resize(128, 128);

    axios({
        method: 'get',
        url,
        responseType: 'stream',
    })
        .then((response) => {
            console.log(`downloaded: ${fileName}`);
            response.data.pipe(resizer).pipe(fs.createWriteStream(`./img/${fileName}`));
        })
        .catch((error) => {
            console.log(error);
        });
});
