const fs = require('fs');
const top100 = require('./output_top100_post.json');
const monthly = require('./output_monthly_posts.json');

const json = [...top100, ...monthly];

json.map((item) => (item.price = parseFloat(item.price)));
json.sort((a, b) => b.price - a.price);
const final100 = json.slice(0, 100);

fs.writeFile('final100.json', JSON.stringify(final100), (error) => {
    if (error) throw error;
    console.log('File written!');
});
