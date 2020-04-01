import { dotenv } from './lib/dotenv.js'
dotenv()

const API_KEY = Deno.env('API_KEY')
const CHART_ID = Deno.env('CHART_ID')
const DW_TOKEN = Deno.env('DW_TOKEN')

const FAANG = ["FB", "AMZN", "AAPL", "NFLX", "GOOG"];

async function main() {
  /* Function that loads CSV stock data from external data source */
  const stocks = await getStockData();

  console.log(`[${CHART_ID}] Fetched new data.`);

  await request(
    `https://api.datawrapper.de/v3/charts/${CHART_ID}/data`,
    {
      method: "PUT",
      headers: {
        "content-type": "text/csv"
      },
      body: stocks
    }
  );

  console.log(`[${CHART_ID}] Data updated.`);

  /* Update chart note with current date to reflect the change */
  await request(
    `https://api.datawrapper.de/v3/charts/${CHART_ID}`,
    {
      method: "PATCH",
      json: true,
      body: {
        metadata: {
          annotate: {
            notes: `Last update: ${new Date().toLocaleString()}`
          }
        }
      }
    }
  );

  console.log(`[${CHART_ID}] Last update time updated.`);

  /* Republish the chart to make the new data available */
  const publishResponse = await request(
    `https://api.datawrapper.de/charts/${CHART_ID}/publish`,
    {
      json: true,
      method: "POST"
    }
  );

  console.log(`[${CHART_ID}] Chart published.

https:${publishResponse.data.publicUrl}`);
}

main();

function api(stock) {
  const query = new URLSearchParams([
    ["apikey", API_KEY],
    ["function", "TIME_SERIES_DAILY"],
    ["symbol", stock],
    ["interval", "1min"],
    ["datatype", "json"]
  ]);

  return request(`https://www.alphavantage.co/query?${query.toString()}`, {
    headers: { "content-type": "application/json" },
    json: true
  });
}

async function getStockData() {
  const responses = await Promise.all(FAANG.map(stock => api(stock)));

  let data = responses.map((d, i) =>
    Object.entries(d["Time Series (Daily)"]).map(e => ({
      date: e[0],
      val: e[1]["4. close"],
      [e[0]]: e[1]["4. close"],
      stock: FAANG[i]
    })
    )
  );

  const dates = data[0].map(d => d.date);

  data = data.map(d =>
    d.reduce((coll, s) => {
      coll[s.date] = s;
      return coll;
    }, {})
  );

  data = dates.reduce(
    (coll, date) => {
      coll.push(
        [date, ...data.map(d => (d[date] ? d[date].val : undefined))].join("|")
      );

      return coll;
    },
    [["Date", FAANG.join("|")].join("|")]
  );

  return data.join("\n");
}

async function request(
  url,
  { json, headers, body, ...options } = { headers: {} }
) {
  const response = await fetch(url, {
    headers: {
      authorization: `Bearer ${DW_TOKEN}`,
      ...headers,
      "content-type": json ? "application/json" : headers["content-type"]
    },
    body: json ? JSON.stringify(body) : body,
    ...options
  });

  if (json) return response.json();
  return response;
}
