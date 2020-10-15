const fs = require('fs');
const moment = require('moment');
const chalk = require('chalk');

const { getLetters } = require('./utils/utils');

let tweetData = JSON.parse(fs.readFileSync('./data/all-tweets.json'));

console.log(chalk.grey('Processing tweet data...'));

const dailyTweets = {};

const startDate = moment('2017-01-01');
const endDate = moment(new Date(tweetData[tweetData.length - 1].created_at));
const totalDays = endDate.diff(startDate,'days') + 1;

for (let i = 0; i < totalDays; i++) {
    const date = startDate.format('YYYY-M-D').split('-').map(d => +d);
    const tweets = tweetData.filter(tweet => {
        return tweet.year === date[0] && tweet.month === date[1] && tweet.day === date[2];
    });
    const retweets = tweets.filter(tweet => tweet.is_retweet).length;
    const highestLikes = Math.max(...tweets.map(t => t.favorite_count));
    const highestRetweets = Math.max(...tweets.map(t => t.retweet_count));

    const totalLikes = tweets.reduce((acc,tweet) => {
            acc += tweet.favorite_count;
            return acc;
        },0);
    const totalRetweets = tweets.reduce((acc,tweet) => {
            acc += tweet.retweet_count;
            return acc;
        },0);

    const letters = getLetters(tweets,'[a-zA-Z]');
    const capitalLetters = getLetters(tweets,'[A-Z]');
    const mostPopular = tweets.length ? tweets.filter(t => t.favorite_count === highestLikes)[0] : false;
    const mostRetweeted = tweets.length ? tweets.filter(t => t.retweet_count === highestRetweets)[0] : false;

    const data = {
        total: tweets.length,
        retweets: retweets,
        original: tweets.length - retweets,
        highestLikes,
        highestRetweets,
        totalLikes,
        letters,
        capitalLetters,
        loudness: 100*capitalLetters/letters,
        likeRate:totalLikes/tweets.length,
        totalRetweets,
        retweetRate:totalRetweets/tweets.length,
        mostPopular: {
            text: mostPopular ? mostPopular.text : '',
            id: mostPopular ? mostPopular.id_str : '',
            date: moment(new Date(mostPopular ? mostPopular.created_at : startDate)).format('YYYY-MM-DD hh:mm')
        },
        mostRetweeted: {
            text: mostRetweeted ? mostRetweeted.text : '',
            id: mostRetweeted ? mostRetweeted.id_str : '',
            date: moment(new Date(mostRetweeted ? mostRetweeted.created_at : startDate)).format('YYYY-MM-DD hh:mm')
        }
    };

    const yearMonth = [date[0],date[1]].join('-');

    if (!dailyTweets[yearMonth]) dailyTweets[yearMonth] = {};

    dailyTweets[yearMonth][date[2]] = data;
    startDate.add(1,'day');
}

fs.writeFileSync('./data/daily-tweets.json', JSON.stringify(dailyTweets, null, '\t'))
console.log(chalk.green('Summarised tweets and saved to daily-tweets.json'));

