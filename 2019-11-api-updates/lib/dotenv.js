export function dotenv () {
  const env = Deno.env()
  const decoder = new TextDecoder('utf-8')
  let data = Deno.readFileSync('.env')
  data = decoder
    .decode(data)
    .trim()
    .split('\n')
    .map(line => line.split('='))
    .forEach(([key, value]) => { env[key.trim()] = value.trim() })
}

