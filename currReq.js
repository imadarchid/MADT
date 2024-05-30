if ((secrets.bkamKey = "")) {
  throw Error("No valid BKAM_KEY was supplied")
}

const bkamAPI = Functions.makeHttpRequest({
  url: `https://api.centralbankofmorocco.ma/cours/Version1/api/CoursVirement?libDevise=USD`,
  headers: { "Ocp-Apim-Subscription-Key": secrets.BKAM_KEY },
})

const exchRateAPI = Functions.makeHttpRequest({
  url: `https://v6.exchangerate-api.com/v6/${secrets.EXCH_RATE_KEY}/pair/USD/MAD`,
})

const currencyAPI = Functions.makeHttpRequest({
  url: `https://api.currencyapi.com/v3/latest?apikey=${secrets.CURRENCY_KEY}&currencies=MAD`,
})

const [bkamRequestResponse, exchRateAPIResponse, currencyAPIResponse] = await Promise.all([
  bkamAPI,
  exchRateAPI,
  currencyAPI,
])

const prices = []

console.log(bkamRequestResponse)

if (!bkamRequestResponse.error) {
  if (bkamRequestResponse.data.length > 0) {
    prices.push(bkamRequestResponse.data[0].moyen)
  }
} else {
  console.log("BKAM Error")
}
if (!exchRateAPIResponse.error) {
  prices.push(exchRateAPIResponse.data.conversion_rate)
} else {
  console.log("ExchangeRateAPI Error")
}
if (!currencyAPIResponse.error) {
  prices.push(currencyAPIResponse.data.data.MAD.value)
} else {
  console.log("CurrencyAPI Error")
}

if (prices.length < 2) {
  // If an error is thrown, it will be returned back to the smart contract
  throw Error("More than 1 API failed")
}

const medianRate = prices.sort((a, b) => a - b)[Math.round(prices.length / 2)]
console.log(`Median MAD rate: $${medianRate.toFixed(2)}`)

return Functions.encodeUint256(Math.round(medianRate * 100))
