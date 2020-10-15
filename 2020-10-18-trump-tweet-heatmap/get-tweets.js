const rp = require('request-promise');
const fs = require('fs');
const chalk = require('chalk');
const yearTweets = [];

console.log(chalk.grey('Downloading tweets...'));

const haveOldData = fs.existsSync('./data/previous-year-tweets.json');

let allTweets = haveOldData ? JSON.parse(fs.readFileSync('./data/previous-year-tweets.json')) : [];

const years = haveOldData ? [2020] : [2017,2018,2019,2020];

const options = (year) => {
    const root = year !== 2020 ?
        'http://d5nxcu7vtzvay.cloudfront.net/data/realdonaldtrump' :
        'http://www.trumptwitterarchive.com/data/realdonaldtrump'
    return {
        method:'GET',
        uri:`${root}/${year}.json`,
        json:true
    }
}

function getTweets(year) {
    return rp(options(year)).then(res => {
        yearTweets.push([...res]);
        console.log(chalk.yellow(`Got ${year === 2020 ? 'latest' : ''} tweets from ${year}`));
    }).catch(err => {
        console.log(chalk.red(`Failed to get data for ${year}`));
    })
}
const getAllTweets = async function() {

    for (i = 0; i < years.length ; i++) {
        await getTweets(years[i]);
    }

    yearTweets.forEach(year => {
        year.forEach(tweet => {
            var date = new Date(tweet.created_at);
            tweet.year = date.getFullYear();
            tweet.day = date.getDate();
            tweet.month = date.getMonth() + 1;
        });
        year = year.sort((a,b) => {
            return new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
        });
    });

    if (!haveOldData) {
        const latestTweets = yearTweets.pop();
        yearTweets.forEach(year => {
            allTweets.push(...year);
        });
        fs.writeFileSync('./data/previous-year-tweets.json', JSON.stringify(allTweets , null,'\t'));
        allTweets.push(...latestTweets);
    } else {
        allTweets.push(...yearTweets[0]);
    }

    fs.writeFileSync('./data/all-tweets.json', JSON.stringify(allTweets,null,'\t'));
    console.log(chalk.green(`Downloaded ${haveOldData ? 'latest' : 'all'} tweets and saved to all-tweets.json`));
}

getAllTweets();