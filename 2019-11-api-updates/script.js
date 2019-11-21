const got = require('got')

const API_KEY = '<API_KEY>' // https://www.alphavantage.co/
const FAANG = ['FB', 'AMZN', 'AAPL', 'NFLX', 'GOOG']
const CHART_ID = '<ID>' // Chart you want to update
const DW_TOKEN = '<YOUR_API_TOKEN>' // Datawrapper API token

async function main() {
  /* Function that loads CSV stock data from external data source */
  const stocks = await getStockData()

  console.log(`[${CHART_ID}] Fetched new data.`)

  
  const dataResponse = await request(
    `https://api.datawrapper.de/v3/charts/${CHART_ID}/data`,
    {
      method: 'PUT',
      body: stocks
    }
  )

  console.log(`[${CHART_ID}] Data updated.`)

  /* Update chart note with current date to reflect the change */
  const chartResponse = await request(
    `https://api.datawrapper.de/v3/charts/${CHART_ID}`,
    {
      method: 'PATCH',
      json: true,
      body: {
        metadata: {
          annotate: {
            notes: `Last update: ${new Date().toLocaleString()}`
          }
        }
      }
    }
  )

  console.log(`[${CHART_ID}] Last update time updated.`)

  /* Republish the chart to make the new data available */
  const publishResponse = await request(
    `https://api.datawrapper.de/charts/${CHART_ID}/publish`,
    {
      json: true,
      method: 'POST'
    }
  )

  console.log(`[${CHART_ID}] Chart published.

https:${publishResponse.body.data.publicUrl}`)
}

main()

function api(stock) {
  return got('/', {
    json: true,
    baseUrl: 'https://www.alphavantage.co/query',
    query: new URLSearchParams([
      ['apikey', API_KEY],
      ['function', 'TIME_SERIES_DAILY'],
      ['symbol', stock],
      ['interval', '1min'],
      ['datatype', 'json']
    ])
  })
}

async function getStockData() {
  const responses = await Promise.all(FAANG.map(stock => api(stock)))
  let data = responses.map(res => res.body)

  data = data.map((d, i) =>
    Object.entries(d['Time Series (Daily)']).map(e => ({
      date: e[0],
      val: e[1]['4. close'],
      [e[0]]: e[1]['4. close'],
      stock: FAANG[i]
    }))
  )

  const dates = data[0].map(d => d.date)

  data = data.map(d =>
    d.reduce((coll, s) => {
      coll[s.date] = s
      return coll
    }, {})
  )

  data = dates.reduce(
    (coll, date) => {
      coll.push(
        [date, ...data.map(d => (d[date] ? d[date].val : undefined))].join('|')
      )

      return coll
    },
    [['Date', FAANG.join('|')].join('|')]
  )

  return data.join('\n')
}

function request(url, options) {
  return got(url, {
    headers: {
      authorization: `Bearer ${DW_TOKEN}`
    },
    ...options
  })
}
