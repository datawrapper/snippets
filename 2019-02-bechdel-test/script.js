const fs = require('fs');
const _ = require('underscore');

fs.readFile('data.json', (err, data) => {
    if (err) throw err;
    
    const json = JSON.parse(data);

    const decades = _.groupBy(json, film => {
        return film.year.substring(0, 3);
    });

    // write first line
    let csvText = 'Decade,3 of 3,2 of 3,1 of 3,0 of 3\n';

    Object.keys(decades).forEach(decade => {
        const films = decades[decade];
        const total = films.length;
        const ratings = _.countBy(films, film => {
            return film.rating;
        });

        Object.keys(ratings).map(rating => {
            ratings[rating] = (ratings[rating] / total * 100).toFixed(1);
        });

        const line = `${decade}0s,${ratings[3] || null},${ratings[2] || null},${ratings[1] || null},${ratings[0] || null}\n`;
        csvText += line;
    });

    // write to file
    fs.writeFile('bechdel.csv', csvText, (err) => {  
        if (err) throw err;
    });
});
