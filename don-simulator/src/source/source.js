if (secrets.apiKey === "salam") {
  return Functions.encodeUint256(0.4 * 100);
} else {
  return Functions.encodeUint256(0.6 * 100);
}
