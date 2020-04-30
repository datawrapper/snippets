const cheerio = require('cheerio');
const axios = require('axios');
const fs = require('fs');

const all = [];

function getMonthlyItems(urls) {
    setTimeout(() => {
        const url = urls[0];
        console.log(`get: ${url}`);
        axios
            .get(url)
            .then((response) => {
                const html = response.data;
                const $ = cheerio.load(html);
                const items = [];
                $('.post-entry-content > ol > li').each((index, item) => {
                    const $item = $(item);

                    const $artistTitle = $item.find('h4 > a');
                    const artistTitle = $artistTitle.text().split('–');
                    const artist = artistTitle[0].trim();
                    const title = artistTitle[1].trim();
                    let url = $artistTitle.attr('href');
                    url = url.replace('/sell', '');
                    if (url.includes('?')) {
                        url = url.substring(0, url.indexOf('?'));
                    }

                    const $p = $item.find('div > p');
                    const pText = $p.text();

                    const priceStartIndex = pText.indexOf('$');
                    const price = pText.substring(
                        priceStartIndex + 1,
                        pText.indexOf(' ', priceStartIndex)
                    );

                    const dateSearchString = 'Released: ';
                    let date = null;
                    if (pText.includes(dateSearchString)) {
                        const dateStartIndex =
                            pText.indexOf(dateSearchString) + dateSearchString.length;
                        date = parseInt(
                            pText.substring(dateStartIndex, pText.indexOf('\n', dateStartIndex)),
                            10
                        );
                    }

                    const imageUrl = $item.find('a > img').attr('src');

                    items.push({ artist, title, price, url, imageUrl, date });
                });

                all.push(...items);

                urls.shift();
                if (urls.length === 0) return writeFile();
                getMonthlyItems(urls);
            })
            .catch((error) => {
                console.log(error);
            });
    }, 500);
}

function writeFile() {
    fs.writeFile('output_monthly_posts.json', JSON.stringify(all), (error) => {
        if (error) throw error;
        console.log('File written!');
    });
}

const urls = [
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-february-2020/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-january-2020/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-december-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-november-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-october-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-september-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-august-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-july-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-june-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-may-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-april-2019/',
    'https://blog.discogs.com/en/top-30-most-expensive-items-sold-in-discogs-marketplace-for-march-2019/',
];

getMonthlyItems(urls);
