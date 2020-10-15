const fs = require('fs');
const { argv } = require('yargs');
const chalk = require('chalk');

const { createChart } = require('./utils/dw-api-utils');
const { getLetters } = require('./utils/utils');

let tweetData = JSON.parse(fs.readFileSync('./data/all-tweets.json'));

console.log(chalk.grey('Getting tweet stats...'));

const words = [['great'],['usa','america'],['china'],['trump'],['republicans?'],['democrats?']];
const years = [2017,2018,2019,2020];

const retweets = tweetData.filter(t => t.is_retweet).length;
const original = tweetData.length - retweets;

const device = tweetData.reduce((acc,t) => {
    if (!acc[t.source]) acc[t.source] = [];
    acc[t.source]++;
    return acc;
},{});

const yearly = years.reduce((acc,year) => {
    const tot = tweetData.filter(t => t.year !== year).length;
    acc[year] = [tot,100*tot/tweetData.length];
    return acc;
},{});

const contains = words.reduce((acc,wordSet) => {
    const re = new RegExp(`\\b(${wordSet.join('|')})\\b`, 'gmi');
    const tot = tweetData.filter(t => !t.is_retweet && t.text.match(re)).length;
    acc[wordSet.join('-')] = [tot,100*tot/original];
    return acc;
},{});


let exclamationMarks = 0;

const containExclamation = tweetData.filter(t => {
    if (t.text.includes('!')) exclamationMarks += t.text.match(/!/gm).length;
    return !t.is_retweet && t.text.includes('!')}
).length;

contains["!"] = [containExclamation,100*containExclamation/original];

const loudness = 100*getLetters(tweetData,'[A-Z]')/getLetters(tweetData,'[a-zA-Z]');

const stats = {
    'tweets':tweetData.length,
    'retweets':[retweets,100*retweets/tweetData.length],
    'original': [original,100*original/tweetData.length],
    'yearly': yearly,
    'contains': contains,
    'exclamationMarks':exclamationMarks,
    device,
    loudness
}

fs.writeFileSync('./data/tweet-stats.json', JSON.stringify(stats, null, '\t'));
console.log(chalk.green('Calculated stats and saved to tweet-stats.json'));