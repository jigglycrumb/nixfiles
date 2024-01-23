#!/usr/bin/env node

// this script requires node.js

// Moon phase calculations taken from https://github.com/tingletech/moon-phase
Date.prototype.getJulian = function () {
  return this / 86400000 - this.getTimezoneOffset() / 1440 + 2440587.5;
};

function moon_day(today) {
  var GetFrac = function (fr) {
    return fr - Math.floor(fr);
  };
  var thisJD = today.getJulian();
  var year = today.getFullYear();
  var degToRad = 3.14159265 / 180;
  var K0, T, T2, T3, J0, F0, M0, M1, B1, oldJ;
  K0 = Math.floor((year - 1900) * 12.3685);
  T = (year - 1899.5) / 100;
  T2 = T * T;
  T3 = T * T * T;
  J0 = 2415020 + 29 * K0;
  F0 =
    0.0001178 * T2 -
    0.000000155 * T3 +
    (0.75933 + 0.53058868 * K0) -
    (0.000837 * T + 0.000335 * T2);
  M0 =
    360 * GetFrac(K0 * 0.08084821133) +
    359.2242 -
    0.0000333 * T2 -
    0.00000347 * T3;
  M1 =
    360 * GetFrac(K0 * 0.07171366128) +
    306.0253 +
    0.0107306 * T2 +
    0.00001236 * T3;
  B1 =
    360 * GetFrac(K0 * 0.08519585128) +
    21.2964 -
    0.0016528 * T2 -
    0.00000239 * T3;
  var phase = 0;
  var jday = 0;
  while (jday < thisJD) {
    var F = F0 + 1.530588 * phase;
    var M5 = (M0 + phase * 29.10535608) * degToRad;
    var M6 = (M1 + phase * 385.81691806) * degToRad;
    var B6 = (B1 + phase * 390.67050646) * degToRad;
    F -= 0.4068 * Math.sin(M6) + (0.1734 - 0.000393 * T) * Math.sin(M5);
    F += 0.0161 * Math.sin(2 * M6) + 0.0104 * Math.sin(2 * B6);
    F -= 0.0074 * Math.sin(M5 - M6) - 0.0051 * Math.sin(M5 + M6);
    F += 0.0021 * Math.sin(2 * M5) + 0.001 * Math.sin(2 * B6 - M6);
    F += 0.5 / 1440;
    oldJ = jday;
    jday = J0 + 28 * phase + Math.floor(F);
    phase++;
  }

  // 29.53059 days per lunar month
  return (thisJD - oldJ) / 29.53059;
}

function phase_text(phase) {
  var txt_phase;
  if (phase <= 0.0625 || phase > 0.9375) {
    txt_phase = "phase_new";
  } else if (phase <= 0.1875) {
    txt_phase = "phase_waxing_crescent";
  } else if (phase <= 0.3125) {
    txt_phase = "phase_first_quarter";
  } else if (phase <= 0.4375) {
    txt_phase = "phase_waxing_gibbous";
  } else if (phase <= 0.5625) {
    txt_phase = "phase_full";
  } else if (phase <= 0.6875) {
    txt_phase = "phase_waning_gibbous";
  } else if (phase <= 0.8125) {
    txt_phase = "phase_third_quarter";
  } else if (phase <= 0.9375) {
    txt_phase = "phase_waning_crescent";
  }

  return txt_phase;
}

var phaseLabels = {
  phase_new: "New moon",
  phase_waxing_crescent: "Waxing crescent moon",
  phase_first_quarter: "First quarter moon",
  phase_waxing_gibbous: "Waxing gibbous moon",
  phase_full: "Full moon",
  phase_waning_gibbous: "Waning gibbous moon",
  phase_third_quarter: "Third quarter moon",
  phase_waning_crescent: "Waning crescent moon",
};

function phaseEmoji(phase) {
  switch (phase) {
    case "phase_new":
      return "🌑";
    case "phase_waxing_crescent":
      return "🌒";
    case "phase_first_quarter":
      return "🌓";
    case "phase_waxing_gibbous":
      return "🌔";
    case "phase_full":
      return "🌕";
    case "phase_waning_gibbous":
      return "🌖";
    case "phase_third_quarter":
      return "🌗";
    case "phase_waning_crescent":
      return "🌘";
  }
}

function main() {
  const phase = moon_day(new Date());
  const phaseStr = phase_text(phase);
  const phaseLabel = phaseLabels[phaseStr];
  const cycleProgress = `Completed ${Math.round(phase * 100)}% of lunar cycle`;

  const tooltip =
    "<span>" +
    ["<b>" + phaseLabel + "</b>", cycleProgress]
      .filter(output => output !== "")
      .join("\n\n") +
    "</span>";

  const data = {
    text: phaseEmoji(phaseStr),
    tooltip,
  };

  const output = JSON.stringify(data);

  console.log(output);
}

main();
