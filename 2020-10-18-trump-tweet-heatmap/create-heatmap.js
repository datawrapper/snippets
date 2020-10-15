const fs = require('fs');
const chalk = require('chalk');
const { argv } = require('yargs');

const { interpolateLab } =require('d3-interpolate');
const { scaleLinear } =require('d3-scale');
const { color } =require('d3-color');

const { createChart, publishChart } = require('./utils/dw-api-utils');
const { getMax, tooltip, notes, annotations, hlRange } = require('./utils/utils');

const dailyTweets = JSON.parse(fs.readFileSync('./data/daily-tweets.json'));

const allData = [];
const toPlot = 'total';
let valueMax;

const defaultColors = ['#ffffff', '#bee4fb', '#7ec9f8', '#3daef4', '#1996e6', '#1180cd', '#0869b4', '#00539b'];

const updateChart = argv.id;
const colors = argv.colors ? argv.colors.split(',') : defaultColors;

if (['metadata','data'].includes(argv.update) && !argv.id) {
    console.log(chalk.yellow(`make sure to specify id of chart you want to update the ${argv.update} for`));
    return;
}

const colorCount = colors.length;

const props = Object.keys(dailyTweets['2017-1']['1']).filter(prop => isFinite(dailyTweets['2017-1']['1'][prop]));
const mostPopularProps = Object.keys(dailyTweets['2017-1']['1'].mostPopular);



/*============ Prepare Gradients ============*/
const gradients = props.reduce((acc,prop) => {
    const max = getMax(prop,dailyTweets);
    if (prop === toPlot) valueMax = max;

    const domain = [...Array(colors.length + 1).keys()]
        .map(i => i*(max/colors.length));

    acc[prop] = scaleLinear()
        .domain(domain)
        .range(colors)
        .interpolate(interpolateLab);
    return acc;
},{});
/*========================================*/



/*========== Construct table header ======*/
const header = ['month','day'];
props.forEach(prop => {
    header.push(prop)
    header.push(prop+'-color');
    header.concat(['most-popular-text','most-popular-id'])
});
mostPopularProps.forEach(prop => {
    header.push('most-popular-'+prop);
})

allData.push(header);
/*========================================*/




/*============ Prepare Dataset ============*/
console.log(chalk.grey('Constructing csv dataset...'));

const customColors = {};

Object.keys(dailyTweets).forEach(yearMonth => {
    Object.keys(dailyTweets[yearMonth]).forEach(day => {
        const tweet = dailyTweets[yearMonth][day];
        const rowData = [];
        const split = yearMonth.split('-');
        const date = `${split[0]}-${split[1] < 10 ? ('0' + split[1]) : split[1]}-01`;

        rowData.push(date);
        rowData.push(day);
        props.forEach(prop => {
            const val = tweet[prop];
            const c = color(gradients[prop](val)).formatHex();
            rowData.push(val);
            rowData.push(c);
            if (!customColors[c]) {
                customColors[c] = c;
            }
        });
        mostPopularProps.forEach(prop => {
            let val = tweet.mostPopular[prop];
            if (prop === 'text') {
                val = '"'+val.replace(/,/gm,"&#44;").replace(/"/gm,'&#34;')+'"';
            }
            rowData.push(val)
        });
        allData.push(rowData);
    });
})
/*========================================*/




/*============ Array to CSV ==============*/
const csv = allData.map(row => row.join(',')).join('\n');
/*========================================*/





/*============ Save CSV file ==============*/
fs.writeFileSync('./data/chart-data.csv', csv);
console.log(chalk.green('Saved dataset to chart-data.csv'));
/*=========================================*/




/*======== Define chart metadata ==========*/
const metadata = {
    title: `<span style="font-weight:lighter;color:rgb(29, 161, 242)">In the past year, @realDonaldTrump has broken all his tweet records</span>`,
    type:'d3-scatter-plot',
    theme:'datawrapper',
    metadata: {
        "describe":{
            "intro":"<span style='color:rgb(101, 119, 134)'>@realDonaldTrump tweets from 2017 until today</span>",
            "byline":"Elana Levin Schtulberg / Datawrapper",
            "source-name":"Trump Twitter Archive",
            "source-url":"http://www.trumptwitterarchive.com/"
        },
        data: {
            changes:[{"row":0,"time":1602425700285,"value":"<b>","column":0,"ignored":false,"previous":"month"}],
            'column-format':{
                'most-popular-id':{
                    'type':'text'
                }
            }
        },
        visualize: {
            "shape": "fixed",
            "size": "fixed",
            "fixed-symbol": "symbolSquare",
            "fixed-size": "16.7",
            "color-base": 0,
            "auto-labels": false,
            "show-color-key": false,
            "outlines": false,
            "tooltip":tooltip,
            "custom-colors":customColors,
            "text-annotations":annotations,
            "highlight-range":hlRange,
            "show-tooltips": true,
            'sticky-tooltips': true,
            "y-grid-lines": "just-labels",
            "y-format": "MMM",
            "y-axis": {
                "range":["01-2021","11-2016"],
                "ticks":[]
            },
            "x-axis":{
                "range": [0,34],
                "ticks": [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31]
            },
            "x-grid-lines": "just-labels",
            "x-pos": "zero"
        },
        "annotate":{
            "notes":notes(colors,94,15,valueMax)
        },
        "axes": {
            "x": "day",
            "y": "month",
            "color": toPlot+'-color'
        },
        "publish":{
            "embed-width": 640,
            "embed-height": 1105,
            "text": "#333333",
            "background": "#ffffff",
            "chart-height": 845
        }
    }
};
/*=========================================*/



/*============= Create Chart ==============*/
console.log(chalk.grey('Creating new chart...'));

createChart({metadata,data:csv, id:updateChart, update:argv.update}).then(res => {
    if (!res.error) {
        const chartId = updateChart || res.id;
        console.log(chalk.green(`Finished ${updateChart ? 'updating' : 'creating'} chart with id ${chartId}`));
        console.log(chalk.bgBlue(`Check out your chart at https://app.datawrapper.de/chart/${chartId}/visualize`));
        if (argv.publish) {
            console.log(chalk.grey(`Publishing ${chartId}...`));
            publishChart(chartId).then(res =>{
                console.log(chalk.green(`Published ${chartId}`));
            }).catch(err => {
                console.log(chalk.red(`Failed to publish ${updateChart || res.id}`));
            })
        }
    } else {
        console.log(chalk.red(`Failed while trying to ${res.failedAt}`));
        console.log(res.error);
    }
})
.catch(err => {
    console.log(chalk.red(`Failed to ${updateChart ? 'update' : 'create'} chart`));
    console.log(JSON.parse(err.error));
});

/*=========================================*/