require('dotenv').config();
const rp = require('request-promise');
const chalk = require('chalk');

const options = ({id, method, endpoint, body, type}) => {
    const api = 'https://api.datawrapper.de';
    const token = process.env.API_TOKEN;

    const opts = {
        'method': method,
        'url': `${api}/v3/charts${id ? '/'+ id : ''}${endpoint ? '/' + endpoint : ''}`,
        'headers': {
            'Authorization': `Bearer ${token}`,
            'Accept': '*/*'
        }
    };

    if (type) opts.headers["Content-Type"] = type === 'csv' ? 'text/csv' : 'application/json';
    if (body) opts.body = type === 'json' ? JSON.stringify(body) : body;

    return opts;
};

function addMetadata({metadata,data,id}) {
    const opts = {
        method: id ? "PATCH" : "POST",
        body:metadata,
        type:'json'
    };
    if (id) opts.id = id;

    return rp(options(opts))
        .then(response => {
            const chartId = JSON.parse(response).id;
            console.log(chalk.yellow(`${id ? 'Updated metadata for' : 'Created'} chart ${chartId}`));
            return {id:chartId, data,update: id ? true : false};
        })
        .catch(err => {
            return {failedAt: id ? 'create chart' : 'update chart metadata',error:JSON.parse(err.error)};
        });
}

function addData({data,id,failedAt,error,update}) {
    if (error) return {error,failedAt};

    return rp(options({id:id,method:"PUT", body:data, type:'csv', endpoint:'data'}))
        .then(response => {
            console.log(chalk.yellow(`${update ? 'Updated data for' : 'Uploaded data to'} ${id}`));
            return {id:id}
        })
        .catch(err => {
            return {failedAt:'add data',error:JSON.parse(err.error)};
        })
}

function publishChart(id) {
    return rp(options({id,method:'POST',endpoint:'publish'}));
}

function createChart({metadata,data,id,update}) {
    if (update === 'metadata') {
        return addMetadata({metadata,id})
    } else if (update === 'data') {
        return addData({data,id});
    } else {
        return addMetadata({metadata,data,id}).then(addData);
    }
}

exports.createChart = createChart;
exports.publishChart = publishChart;