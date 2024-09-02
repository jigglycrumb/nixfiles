#!/usr/bin/env node

// this script requires node.js and font-awesome

// you can edit these options to adjust currencies and hide sections of the tooltip
const CURRENCIES = ["USD", "EUR"];
const SHOW_MEMPOOL = true;
const SHOW_MOSCOW_TIME = true;
const SHOW_PRICE = true;

// do not edit below this line if you don't know what you're doing
let mempoolOutput = "";
let moscowTimeOutput = "";
let priceOutput = "";

async function main() {
  // MEMPOOL

  if (SHOW_MEMPOOL) {
    const mempoolData = await Promise.all([
      fetch("https://mempool.space/api/blocks/tip/height").then(height =>
        height.json()
      ),
      fetch("https://mempool.space/api/v1/fees/recommended").then(fees =>
        fees.json()
      ),
      fetch("https://mempool.space/api/v1/difficulty-adjustment").then(
        difficulty => difficulty.json()
      ),
    ]);

    const [blockheight, fees, period] = mempoolData;

    const difficultyPrefix = period.difficultyChange > 0 ? "+" : "";

    mempoolOutput = `<b>Block height</b> ${blockheight}

<b>Fees</b>
Eco\t${fees.economyFee} sat/vB
Fast\t${fees.fastestFee} sat/vB
60m\t${fees.hourFee} sat/vB
30m\t${fees.halfHourFee} sat/vB
Min\t${fees.minimumFee} sat/vB

<b>Period</b>
Progress ${period.progressPercent.toFixed(2)}%
Next difficulty ${difficultyPrefix}${period.difficultyChange.toFixed(2)}%`;
  }

  // PRICE
  if (SHOW_MOSCOW_TIME || SHOW_PRICE) {
    const priceUrl = "https://blockchain.info/ticker";

    const priceData = await fetch(priceUrl);
    const prices = await priceData.json();

    const moscowTime = Math.round(
      new Number(1 / prices.USD.last).toFixed(8) * 100 * 1000000
    );

    let pricesDisplay = [];

    CURRENCIES.map(currency => {
      const btcPrice = prices[currency]?.last?.toFixed(2);
      pricesDisplay.push(`${btcPrice} ${currency}`);
    });

    moscowTimeOutput = SHOW_MOSCOW_TIME
      ? `<b>Moscow time</b> ${moscowTime}`
      : "";

    priceOutput = SHOW_PRICE
      ? `<b>Price</b>
${pricesDisplay.join("\n")}`
      : "";
  }

  // OUTPUT
  const tooltip = [mempoolOutput, moscowTimeOutput, priceOutput]
    .filter(output => output !== "")
    .join("\n\n");

  const data = {
    text: "",
    tooltip,
  };

  const output = JSON.stringify(data);

  console.log(output);
}

main();
