require("dotenv").config();
const Location = {
  Inline: 0,
  Remote: 1,
  DONHosted: 2,
};

const CodeLanguage = {
  JavaScript: 0,
};

const ReturnType = {
  uint: "uint256",
  uint256: "uint256",
  int: "int256",
  int256: "int256",
  string: "string",
  bytes: "bytes",
};

// Configure the request by setting the fields below
const requestConfig = {
  // Location of source code (only Inline is currently supported)
  codeLocation: Location.Inline,
  // Optional. Secrets can be accessed within the source code with `secrets.varName` (ie: secrets.apiKey). The secrets object can only contain string values.
  secrets: {
    exchangeRateApiKey: process.env.EXCH_RATE_KEY ?? "",
    currencyApiKey: process.env.CURRENCY_KEY ?? "",
  },
  // Code language (only JavaScript is currently supported)
  codeLanguage: CodeLanguage.JavaScript,
  // Expected type of the returned value
  expectedReturnType: ReturnType.uint256,
};

module.exports = requestConfig;
