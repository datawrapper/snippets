const cheerio = require('cheerio');
const axios = require('axios');
const fs = require('fs');

const itemsWithDates = [];

function getDate(items) {
    setTimeout(() => {
        const item = items[0];
        console.log(`get: ${item.url}`);
        axios
            .get(item.url)
            .then((response) => {
                const html = response.data;
                const $ = cheerio.load(html);
                const $profile = $('.profile');

                const $releasedHead = $('.profile .head').filter(function() {
                    return $(this).text() === 'Released:';
                });

                const date = $releasedHead
                    .next()
                    .find('a')
                    .text()
                    .trim();
                const d = new Date(date);
                item.date = d.getFullYear();
                itemsWithDates.push(item);

                items.shift();
                if (items.length === 0) return writeFile();
                getDate(items);
            })
            .catch((error) => {
                console.log(error);
            });
    }, 500);
}

function writeFile() {
    fs.writeFile('output_top100_post.json', JSON.stringify(itemsWithDates), (error) => {
        if (error) throw error;
        console.log('File written!');
    });
}

axios
    .get('https://blog.discogs.com/en/discogs-top-100-most-expensive-records/')
    .then((response) => {
        const html = response.data;
        const $ = cheerio.load(html);
        const items = [];
        $('.post-entry-content > ol > li').each((index, item) => {
            const $item = $(item);

            const $artistTitle = $item.find('.artist-title a');
            const artistTitle = $artistTitle.text().split('–');
            const artist = artistTitle[0].trim();
            const title = artistTitle[1].trim();
            const url = $artistTitle.attr('href');
            const price = $item
                .find('.price > h4')
                .text()
                .replace('$', '')
                .replace(',', '');
            const imageUrl = $item.find('.album-artwork img').attr('src');

            items.push({ artist, title, price, url, imageUrl });
        });

        getDate(items);
    })
    .catch((error) => {
        console.log(error);
    });
