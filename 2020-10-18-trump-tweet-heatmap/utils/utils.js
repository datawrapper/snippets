const ttBody = `<style>
    .tweet-block:hover {
        box-shadow: 0px 0px 7px -1px #1da1f259;
        transition:box-shadow 0.2s;
    }
</style>
<div style="font-size: 120%;color:rgb(101, 119, 134);font-weight: lighter;transform: translate(0px, -10px);"> {{ most_popular_date.split(' - ')[0] }}, {{month.split('/')[2]}} </div>
{% if (most_popular_text) { %}<a href="https://twitter.com/realDonaldTrump/status/{{ most_popular_id }}" target="_blank">
<div style="font-size: 12px;color: rgb(29, 161, 242);margin-bottom: 4px;">Most liked tweet:</div>
<div class="tweet-block" style='color: initial;font-size:125%;border:1px solid rgb(204, 214, 221); border-radius:15px;padding:15px;font-family:system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Ubuntu, "Helvetica Neue", sans-serif;'>
    <div class="card-header" style="display:inline-flex;align-items: center;">
        <img src="https://pbs.twimg.com/profile_images/874276197357596672/kUuht00m_bigger.jpg" style="width:30px;border-radius:50%;margin-right:7px;"/>
        <div>
            <span> <b>Donald J. Trump</b></span>
            <span class="handle" style="color:rgb(101, 119, 134)">@realDonaldTrump</span>
        </div>
    </div>
    <div class="card-body" style="line-height:1.35; margin:12px 0px 9px 0px">{{ most_popular_text }}</div>
    <div class="card-footer" style="color:rgb(101, 119, 134); font-size:80%;">
        <div>{{ most_popular_date.split(' - ')[1] }} · {{ most_popular_date.split(' - ')[0] }}, {{month.split('/')[2]}}</div>
        <div class="tweet-likes" style="margin-top:4px; display:flex;align-items: center;">
            <div class="heart-icon" style="margin-right:5px; height:15px;width:15px;">
                <svg viewBox="0 0 24 24"><g><path style="fill:#657786;" d="M12 21.638h-.014C9.403 21.59 1.95 14.856 1.95 8.478c0-3.064 2.525-5.754 5.403-5.754 2.29 0 3.83 1.58 4.646 2.73.814-1.148 2.354-2.73 4.645-2.73 2.88 0 5.404 2.69 5.404 5.755 0 6.376-7.454 13.11-10.037 13.157H12zM7.354 4.225c-2.08 0-3.903 1.988-3.903 4.255 0 5.74 7.034 11.596 8.55 11.658 1.518-.062 8.55-5.917 8.55-11.658 0-2.267-1.823-4.255-3.903-4.255-2.528 0-3.94 2.936-3.952 2.965-.23.562-1.156.562-1.387 0-.014-.03-1.425-2.965-3.954-2.965z"></path></g></svg>
            </div>
            <span >{{ fmt("0,0",highestLikes) }}</span>
        </div>
    </div>
</div>
</a>
{% } %}`;

exports.tooltip  = {
    "body": ttBody,
    "title": '<b style="color:rgb(29, 161, 242);font-size:150%">{{ total }} tweets</b>',
    "fields": {
        "day": "day",
        "month": "month",
        "total": "total",
        "likeRate": "likeRate",
        "original": "original",
        "retweets": "retweets",
        "totalLikes": "totalLikes",
        "total_color": "total-color",
        "highestLikes": "highestLikes",
        "totalRetweets": "totalRetweets",
        "likeRate_color": "likeRate-color",
        "original_color": "original-color",
        "retweets_color": "retweets-color",
        "most_popular_id": "most-popular-id",
        "totalLikes_color": "totalLikes-color",
        "most_popular_date": "most-popular-date",
        "most_popular_text": "most-popular-text",
        "highestLikes_color": "highestLikes-color",
        "totalRetweets_color": "totalRetweets-color"
    }
};

exports.hlRange = `32,01/01/2017,33,01/01/2017,33,01/01/2018,32,01/01/2018 @stroke:#2fa3ee @width:1 @dashed @color:transparent @opacity:1

32,01/01/2018,33,01/01/2018,33,01/01/2019,32,01/01/2019 @stroke:#2fa3ee @width:1 @dashed @color:transparent @opacity:1

32,01/01/2019,33,01/01/2019,33,01/01/2020,32,01/01/2020 @stroke:#2fa3ee @width:1 @dashed @color:transparent @opacity:1

32,01/01/2020,33,01/01/2020,33,11/01/2020,32,11/01/2020 @stroke:#2fa3ee @width:1 @dashed @color:transparent @opacity:1

1,01/01/2017,1,01/01/2021 @color:#96d2f9 @dotted
2,01/01/2017,2,01/01/2021 @color:#96d2f9 @dotted
3,01/01/2017,3,01/01/2021 @color:#96d2f9 @dotted
4,01/01/2017,4,01/01/2021 @color:#96d2f9 @dotted
5,01/01/2017,5,01/01/2021 @color:#96d2f9 @dotted
6,01/01/2017,6,01/01/2021 @color:#96d2f9 @dotted
7,01/01/2017,7,01/01/2021 @color:#96d2f9 @dotted
8,01/01/2017,8,01/01/2021 @color:#96d2f9 @dotted
9,01/01/2017,9,01/01/2021 @color:#96d2f9 @dotted
10,01/01/2017,10,01/01/2021 @color:#96d2f9 @dotted
11,01/01/2017,11,01/01/2021 @color:#96d2f9 @dotted
12,01/01/2017,12,01/01/2021 @color:#96d2f9 @dotted
13,01/01/2017,13,01/01/2021 @color:#96d2f9 @dotted
14,01/01/2017,14,01/01/2021 @color:#96d2f9 @dotted
15,01/01/2017,15,01/01/2021 @color:#96d2f9 @dotted
16,01/01/2017,16,01/01/2021 @color:#96d2f9 @dotted
17,01/01/2017,17,01/01/2021 @color:#96d2f9 @dotted
18,01/01/2017,18,01/01/2021 @color:#96d2f9 @dotted
19,01/01/2017,19,01/01/2021 @color:#96d2f9 @dotted
20,01/01/2017,20,01/01/2021 @color:#96d2f9 @dotted
21,01/01/2017,21,01/01/2021 @color:#96d2f9 @dotted
22,01/01/2017,22,01/01/2021 @color:#96d2f9 @dotted
23,01/01/2017,23,01/01/2021 @color:#96d2f9 @dotted
24,01/01/2017,24,01/01/2021 @color:#96d2f9 @dotted
25,01/01/2017,25,01/01/2021 @color:#96d2f9 @dotted
26,01/01/2017,26,01/01/2021 @color:#96d2f9 @dotted
27,01/01/2017,27,01/01/2021 @color:#96d2f9 @dotted
28,01/01/2017,28,01/01/2021 @color:#96d2f9 @dotted
29,01/01/2017,29,01/01/2021 @color:#96d2f9 @dotted
30,01/01/2017,30,01/01/2021 @color:#96d2f9 @dotted
31,01/01/2017,31,01/01/2021 @color:#96d2f9 @dotted`

exports.annotations = [
    {
        "x": "33",
        "y": 1498100000000,
        "bg": false,
        "dx": "-7",
        "dy": 0,
        "bold": true,
        "size": 14,
        "text": "2\n0\n1\n7",
        "align": "mr",
        "color": "#3daef4",
        "italic": false,
        "underline": false,
        "showMobile": true,
        "showDesktop": true
    },
    {
        "x": "33",
        "y": 1529700000000,
        "bg": false,
        "dx": "-7",
        "dy": 0,
        "bold": true,
        "size": 14,
        "text": "2\n0\n1\n8",
        "align": "mr",
        "color": "#3daef4",
        "italic": false,
        "underline": false,
        "showMobile": true,
        "showDesktop": true
    },
    {
        "x": "33",
        "y": 1561300000000,
        "bg": false,
        "dx": "-7",
        "dy": 0,
        "bold": true,
        "size": 14,
        "text": "2\n0\n1\n9",
        "align": "mr",
        "color": "#3daef4",
        "italic": false,
        "underline": false,
        "showMobile": true,
        "showDesktop": true
    },
    {
        "x": "33",
        "y": 1589300000000,
        "bg": false,
        "dx": "-7",
        "dy": 0,
        "bold": true,
        "size": 14,
        "text": "2\n0\n2\n0",
        "align": "mr",
        "color": "#3daef4",
        "italic": false,
        "underline": false,
        "showMobile": true,
        "showDesktop": true
    }
];

exports.notes = (colors,width,height,max) => {
    const gradient = colors.map((col,i) => {
        return `${col} ${100*i/(colors.length-1)}%`
    }).join(', ');

    return `<span>
        <span style="display:flex;height:${height}px;margin-left:${(100 - width)/2}vw;">
            <span style="background: linear-gradient(90deg, ${gradient});padding: 0px ${width/2}vw;">
            </span>
        </span>
        <span style="margin-left:${(100 - width)/2}vw;padding-bottom:5px;font-style:normal;color:rgb(101, 119, 134);font-size:11px; width:${width}vw; display:flex; justify-content:space-between">
            <span>0</span><span>${Math.round(max/2)}</span><span>${Math.round(max)}</span>
        </span>
    </span>
    *includes retweets`;
}

exports.getMax = (prop,dailyTweets) => {
    let max = 0;
    Object.keys(dailyTweets).forEach(yearMonth => {
        Object.keys(dailyTweets[yearMonth]).forEach(day => {
            max = Math.max(dailyTweets[yearMonth][day][prop],max);
        })
    })
    return max;
}

exports.getLetters = (tweets,exp) => {
    const re = new RegExp(`${exp}`, 'gm');
    return tweets.reduce((acc,t) => {
        if (!t.is_retweet) {
            const letters = t.text.replace(/https:\/\/[^\s]+/gm,'').replace(/\\n/gm,'').match(re);
            if (letters) { acc += letters.length;}
        }
        return acc;
    },0);
}