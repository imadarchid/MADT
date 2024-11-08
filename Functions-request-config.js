const fs = require("fs")
const { Location, ReturnType, CodeLanguage } = require("@chainlink/functions-toolkit")

// Configure the request by setting the fields below
const requestConfig = {
  // String containing the source code to be executed
  source: fs.readFileSync("./currReq.js").toString(),
  // Location of source code (only Inline is currently supported)
  codeLocation: Location.Inline,
  // Optional. Secrets can be accessed within the source code with `secrets.varName` (ie: secrets.apiKey). The secrets object can only contain string values.
  secrets: {
    CURRENCY_KEY: process.env.CURRENCY_KEY ?? "",
    EXCH_RATE_KEY: process.env.EXCH_RATE_KEY ?? "",
    BKAM_KEY: process.env.BKAM_KEY ?? "",
  },
  // Optional if secrets are expected in the sourceLocation of secrets (only Remote or DONHosted is supported)
  secretsLocation: Location.DONHosted,
  // Code language (only JavaScript is currently supported)
  codeLanguage: CodeLanguage.JavaScript,
  // Expected type of the returned value
  expectedReturnType: ReturnType.uint256,
}

module.exports = requestConfig
