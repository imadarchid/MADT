// // Discontinued because of API changes.
// // const bkamAPI = Functions.makeHttpRequest({
// //   url: `https://api.centralbankofmorocco.ma/cours/Version1/api/CoursVirement?libDevise=USD`,
// //   headers: { "Ocp-Apim-Subscription-Key": secrets.BKAM_KEY },
// // })

// if (secrets.exchangeRateApiKey.length === 0) {
//   throw Error("No valid EXCH_RATE_KEY was supplied");
// }

// if (secrets.currencyApiKey.length === 0) {
//   throw Error("No valid CURRENCY_KEY was supplied");
// }

// const exchRateAPI = Functions.makeHttpRequest({
//   url: `https://v6.exchangerate-api.com/v6/${secrets.exchangeRateApiKey}/pair/MAD/USD`,
// });

// const currencyAPI = Functions.makeHttpRequest({
//   url: `https://api.currencyapi.com/v3/latest?apikey=${secrets.currencyApiKey}&currencies=USD&base_currency=MAD`,
// });

// const [exchRateAPIResponse, currencyAPIResponse] = await Promise.all([
//   exchRateAPI,
//   currencyAPI,
// ]);

// const prices = [];
// if (!exchRateAPIResponse.error) {
//   prices.push(exchRateAPIResponse.data.conversion_rate);
// } else {
//   console.log("ExchangeRateAPI Error");
//   throw Error(JSON.stringify(exchRateAPIResponse));
// }
// if (!currencyAPIResponse.error) {
//   prices.push(currencyAPIResponse.data.data.USD.value);
// } else {
//   console.log("CurrencyAPI Error");
//   throw Error(JSON.stringify(currencyAPIResponse));
// }

// if (prices.length < 2) {
//   // If an error is thrown, it will be returned back to the smart contract
//   throw Error("More than 1 API failed");
// }

// const medianRate = prices.sort((a, b) => a - b)[Math.round(prices.length / 2)];
// console.log(`Median MAD rate: $${medianRate.toFixed(2)}`);

// return Functions.encodeUint256(Math.round(medianRate));
return Functions.encodeUint256(13);
