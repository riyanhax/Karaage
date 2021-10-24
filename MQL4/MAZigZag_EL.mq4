#property copyright "Copyright(C) 2021 Studiogadget Inc."

#property indicator_chart_window

input string ZigZagSetting = "/////// ZigZagSetting ///////";
input ENUM_TIMEFRAMES ZigzagTimeframe = PERIOD_CURRENT;
input int Depth = 7;
input int Deviation = 5;
input int Backstep = 1;
input string MovingAverageSetting = "/////// MovingAverageSetting ///////";
input ENUM_TIMEFRAMES MATimeframe = PERIOD_CURRENT;
input int MACurrentPeriod = 20;
input int MAMiddlePeriod = 80;
input int MALongPeriod = 320;
input string AlertSetting = "/////// AlertSetting ///////";
input int AlertRequirementCount = 3;
input bool MailAlert = true;
input bool FileOutput = true;

datetime lastAlert_el = 0;
double lastAlertZigzag_el;
datetime lastAlert_mwhs = 0;
double lastAlertZigzag_mwhs;
datetime lastAlert_tr = 0;
double lastAlertZigzag_tr;
datetime lastAlert = 0;
double lastAlertZigzag;
int period;
string periodText;

int OnInit() {
  if(ZigzagTimeframe == PERIOD_CURRENT) {
    period = Period();
  } else {
    period = ZigzagTimeframe;
  }
  if(period == 1) {
    periodText = "M1";
  } else if(period == 5) {
    periodText = "M5";
  } else if(period == 15) {
    periodText = "M15";
  } else if(period == 30) {
    periodText = "M30";
  } else if(period == 60) {
    periodText = "H1";
  } else if(period == 240) {
    periodText = "H4";
  } else if(period == 1440) {
    periodText = "D1";
  } else if(period == 10080) {
    periodText = "W1";
  } else if(period == 43200) {
    periodText = "MN";
  }

  return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]) {
  double zigzagTmp;
  double zigzag1;
  double zigzag2;
  double zigzag3;
  double zigzag4;
  double zigzag5;
  double zigzag6;
  double zigzag7;
  double zigzag8;
  double zigzag9;
  double zigzag10;
  double macd2;
  double macd3;
  double macd4;
  double macd5;
  double macd6;
  double macd7;
  double macd8;
  double maCurrentEma;
  double maCurrentSma;
  double maMiddleEma;
  double maMiddleSma;
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement_el;
  string alertText_el;
  string mailSubject_el;
  string mailBody_el;
  string direction_el;
  int requirement_mwhs;
  string alertText_mwhs;
  string mailSubject_mwhs;
  string mailBody_mwhs;
  string direction_mwhs;
  int requirement_tr;
  string alertText_tr;
  string mailSubject_tr;
  string mailBody_tr;
  string direction_tr;
  int requirement;
  string alertText;
  string mailSubject;
  string mailBody;
  string direction;
  int handle;
  double lengthPoints12;
  double lengthPoints15;
  double lengthPoints25;
  double lengthPoints58;
  string macdRsi;

  // ZigZag取得
  cnt = 0;
  for(i=0; i<iBars( Symbol(), ZigzagTimeframe); i++) {
    zigzagTmp = iCustom(Symbol(), ZigzagTimeframe, "ZigZag", Depth, Deviation, Backstep, 0, i);
    if(cnt == 0 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag1 = zigzagTmp;
      cnt = 1;
    } else if(cnt == 1 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag2 = zigzagTmp;
      macd2 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 2;
    } else if(cnt == 2 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag3 = zigzagTmp;
      macd3 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 3;
    } else if(cnt == 3 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag4 = zigzagTmp;
      macd4 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 4;
    } else if(cnt == 4 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag5 = zigzagTmp;
      macd5 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 5;
    } else if(cnt == 5 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag6 = zigzagTmp;
      macd6 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 6;
    } else if(cnt == 6 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag7 = zigzagTmp;
      macd7 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 7;
    } else if(cnt == 7 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag8 = zigzagTmp;
      macd8 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 8;
    } else if(cnt == 8 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag9 = zigzagTmp;
      cnt = 9;
    } else if(cnt == 9 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag10 = zigzagTmp;
      cnt = 10;
      break;
    }
  }

  requirement_el = 0;
  // Long_EL
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
      && zigzag5 > zigzag6 && zigzag6 < zigzag7 && zigzag7 > zigzag8
      && zigzag3 <= zigzag5 && zigzag4 >= zigzag6 && zigzag5 >= zigzag7 && zigzag6 >= zigzag8
      && zigzag2 >= zigzag6) {
    alertText_el = alertText_el + "Long_EL " + Symbol() + " " + periodText + "\n";
    alertText_el = alertText_el + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_el = "[Long_EL] " + Symbol() + " " + periodText + " " + Time[0];
    direction_el = "long_el";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_el = alertText_el + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_el++;
      alertText_el = alertText_el + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_el = alertText_el + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd2 < macd4) {
      macdRsi = macdRsi + "DivA: Short";
    } else {
      macdRsi = macdRsi + "DivA: Long";
    }
    if(macd5 > macd7) {
      macdRsi = macdRsi + "DivB: Long";
    } else {
      macdRsi = macdRsi + "DivB: Short";
    }
  }
  // Short_EL
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
      && zigzag5 < zigzag6 && zigzag6 > zigzag7 && zigzag7 < zigzag8
      && zigzag3 >= zigzag5 && zigzag4 <= zigzag6 && zigzag5 <= zigzag7 && zigzag6 <= zigzag8
      && zigzag2 <= zigzag6) {
    alertText_el = alertText_el + "Short_EL " + Symbol() + " " + periodText + "\n";
    alertText_el = alertText_el + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_el = "[Short_EL] " + Symbol() + " " + periodText + " " + Time[0];
    direction_el = "short_el";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_el = alertText_el + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_el++;
      alertText_el = alertText_el + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_el = alertText_el + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi = macdRsi + "DivA: Short";
    } else {
      macdRsi = macdRsi + "DivA: Long";
    }
    if(macd5 < macd7) {
      macdRsi = macdRsi + "DivB: Long";
    } else {
      macdRsi = macdRsi + "DivB: Short";
    }
  }

  requirement_mwhs = 0;
  // Long_EL_MW_HS
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7 && zigzag7 > zigzag8
      && zigzag5 <= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4
      && zigzag4 <= zigzag6 && zigzag4 >= zigzag8) {
    alertText_mwhs = alertText_mwhs + "Long_EL_MW_HS " + Symbol() + " " + periodText + "\n";
    alertText_mwhs = alertText_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_mwhs = "[Long_EL_MW_HS] " + Symbol() + " " + periodText + " " + Time[0];
    direction_mwhs = "long_el_mw_hs";

    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_mwhs = alertText_mwhs + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_mwhs++;
      alertText_mwhs = alertText_mwhs + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_mwhs++;
      alertText_mwhs = alertText_mwhs + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_mwhs++;
      alertText_mwhs = alertText_mwhs + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_mwhs = alertText_mwhs + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd6 > macd4) {
      macdRsi = macdRsi + "Div: Short";
    } else {
      macdRsi = macdRsi + "Div: Long";
    }
  }
  // Short_EL_MW_HS
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7 && zigzag7 < zigzag8
      && zigzag5 >= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4
      && zigzag4 >= zigzag6 && zigzag4 <= zigzag8) {
    alertText_mwhs = alertText_mwhs + "Short_EL_MW_HS " + Symbol() + " " + periodText + "\n";
    alertText_mwhs = alertText_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_mwhs = "[Short_EL_MW_HS] " + Symbol() + " " + periodText + " " + Time[0];
    direction_mwhs = "short_el_mw_hs";

    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_mwhs = alertText_mwhs + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_mwhs++;
      alertText_mwhs = alertText_mwhs + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_mwhs++;
      alertText_mwhs = alertText_mwhs + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_mwhs++;
      alertText_mwhs = alertText_mwhs + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_mwhs = alertText_mwhs + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd6 < macd4) {
      macdRsi = macdRsi + "Div: Short";
    } else {
      macdRsi = macdRsi + "Div: Long";
    }
  }
  requirement_tr = 0;
  // Long 切り替わり
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag7 > zigzag8 && zigzag8 < zigzag9 && zigzag9 > zigzag10
      && zigzag5 >= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4 && zigzag4 >= zigzag6 && zigzag6 <= zigzag8
      && zigzag7 <= zigzag9 && zigzag6 >= zigzag10) {
    alertText_tr = alertText_tr + "Long_EL_MW_HS_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Long_EL_MW_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "long_el_mw_hs_tr";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_tr = alertText_tr + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_tr = alertText_tr + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd2 < macd4) {
      macdRsi = macdRsi + "DivA: Short";
    } else {
      macdRsi = macdRsi + "DivA: Long";
    }
    if(macd5 > macd7) {
      macdRsi = macdRsi + "DivB: Long";
    } else {
      macdRsi = macdRsi + "DivB: Short";
    }
  }
  // Short 切り替わり
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag7 < zigzag8 && zigzag8 > zigzag9 && zigzag9 < zigzag10
      && zigzag5 <= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4 && zigzag4 <= zigzag6 && zigzag6 >= zigzag8
      && zigzag7 >= zigzag9 && zigzag6 <= zigzag10) {
    alertText_tr = alertText_tr + "Short_EL_MW_HS_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Short_EL_MW_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "short_el_mw_hs_tr";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_tr = alertText_tr + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_tr = alertText_tr + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi = macdRsi + "DivA: Short";
    } else {
      macdRsi = macdRsi + "DivA: Long";
    }
    if(macd5 < macd7) {
      macdRsi = macdRsi + "DivB: Long";
    } else {
      macdRsi = macdRsi + "DivB: Short";
    }
  }
  requirement = 0;
  // Long 切り替わり
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag5 <= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4
      && zigzag4 > zigzag6 && zigzag7 > zigzag8 && zigzag8 < zigzag9 && zigzag9 > zigzag10
      && zigzag7 <= zigzag9 && zigzag6 <= zigzag8
      && zigzag3 > zigzag7 && zigzag5 < zigzag7 && zigzag6 >= zigzag10) {
    alertText = alertText + "Long_EL_HS_TR " + Symbol() + " " + periodText + "\n";
    alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject = "[Long_EL_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "long_el_hs_tr";

    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText = alertText + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement++;
      alertText = alertText + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement++;
      alertText = alertText + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement++;
      alertText = alertText + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText = alertText + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd2 < macd4) {
      macdRsi = macdRsi + "DivA: Short";
    } else {
      macdRsi = macdRsi + "DivA: Long";
    }
    if(macd5 > macd7) {
      macdRsi = macdRsi + "DivB: Long";
    } else {
      macdRsi = macdRsi + "DivB: Short";
    }
  }
  // Short 切り替わり
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag5 >= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4
      && zigzag4 < zigzag6 && zigzag7 < zigzag8 && zigzag8 > zigzag9 && zigzag9 < zigzag10
      && zigzag7 >= zigzag9 && zigzag6 >= zigzag8
      && zigzag3 < zigzag7 && zigzag5 > zigzag7 && zigzag6 <= zigzag10) {
    alertText = alertText + "Short_EL_HS_TR " + Symbol() + " " + periodText + "\n";
    alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject = "[Short_EL_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "short_el_hs_tr";

    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText = alertText + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement++;
      alertText = alertText + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement++;
      alertText = alertText + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement++;
      alertText = alertText + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText = alertText + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi = macdRsi + "DivA: Short";
    } else {
      macdRsi = macdRsi + "DivA: Long";
    }
    if(macd5 < macd7) {
      macdRsi = macdRsi + "DivB: Long";
    } else {
      macdRsi = macdRsi + "DivB: Short";
    }
  }

  if(StringLen(alertText_el) > 0 && requirement_el >= AlertRequirementCount && lastAlert_el != Time[0] && lastAlertZigzag_el != zigzag2) {
    Alert(alertText_el);
    if(MailAlert) {
      mailBody_el = mailBody_el + alertText_el; // ロング or ショート、通貨ペア、時間足
      mailBody_el = mailBody_el + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints15 = MathAbs( zigzag1 - zigzag5 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints58 = MathAbs( zigzag5 - zigzag8 ) / Point();
      mailBody_el = mailBody_el + "FiboPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints58, 0 ) + " [" + DoubleToStr( (lengthPoints25 / lengthPoints58) * 100, 1 ) + "%]\n";
      mailBody_el = mailBody_el + "E3Percent: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints58, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints58) * 100, 1 ) + "%]\n";
      if(lengthPoints12 < lengthPoints25) {
        mailBody_el = mailBody_el + "5RRPoints: " + DoubleToStr( lengthPoints15, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( (lengthPoints15 / lengthPoints12) * 100, 1 ) + "%]\n";
      } else {
        mailBody_el = mailBody_el + "5RRPoints: None\n";
      }
      if(lengthPoints12 < lengthPoints58) {
        mailBody_el = mailBody_el + "3RRPoints: " + DoubleToStr( lengthPoints58 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints58 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
      } else {
        mailBody_el = mailBody_el + "3RRPoints: None\n";
      }

      mailBody_el = mailBody_el + "\n";
      mailBody_el = mailBody_el + macdRsi + "\n";

      mailBody_el = mailBody_el + "\n";
      mailBody_el = mailBody_el + "\nShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_el = mailBody_el + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_el = mailBody_el + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_el, mailBody_el );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_EL_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_el, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_el = Time[0];
    lastAlertZigzag_el = zigzag2;
  }
  // EL_MW_HS
  if(StringLen(alertText_mwhs) > 0 && requirement_mwhs >= AlertRequirementCount && lastAlert_mwhs != Time[0] && lastAlertZigzag_mwhs != zigzag2) {
    Alert(alertText_mwhs);
    if(MailAlert) {
      mailBody_mwhs = mailBody_mwhs + alertText_mwhs; // ロング or ショート、通貨ペア、時間足
      mailBody_mwhs = mailBody_mwhs + "Price: " + Close[0] + "\n";

      double lengthPoints13_mwhs = MathAbs( zigzag1 - zigzag3 ) / Point();
      double lengthPoints14_mwhs = MathAbs( zigzag1 - zigzag4 ) / Point();
      double lengthPoints17_mwhs = MathAbs( zigzag1 - zigzag7 ) / Point();
      double lengthPoints23_mwhs = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34_mwhs = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints47_mwhs = MathAbs( zigzag4 - zigzag7 ) / Point();
      double lengthPoints78_mwhs = MathAbs( zigzag7 - zigzag8 ) / Point();
      mailBody_mwhs = mailBody_mwhs + "FiboPoints: " + DoubleToStr( lengthPoints47_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints78_mwhs, 0 ) + " [" + DoubleToStr( (lengthPoints47_mwhs / lengthPoints78_mwhs) * 100, 1 ) + "%]\n";
      mailBody_mwhs = mailBody_mwhs + "E3Percent: " + DoubleToStr( lengthPoints14_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints78_mwhs, 0 ) + " [" + DoubleToStr( (lengthPoints14_mwhs / lengthPoints78_mwhs) * 100, 1 ) + "%]\n";
      if(lengthPoints14_mwhs < lengthPoints47_mwhs) {
        mailBody_mwhs = mailBody_mwhs + "5RRPoints: " + DoubleToStr( lengthPoints17_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints14_mwhs, 0 ) + " [" + DoubleToStr( (lengthPoints17_mwhs / lengthPoints14_mwhs) * 100, 1 ) + "%]\n";
      } else {
        mailBody_mwhs = mailBody_mwhs + "5RRPoints: None\n";
      }
      if(lengthPoints14_mwhs < lengthPoints78_mwhs) {
        mailBody_mwhs = mailBody_mwhs + "3RRPoints: " + DoubleToStr( lengthPoints78_mwhs - lengthPoints14_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints14_mwhs, 0 ) + " [" + DoubleToStr((((lengthPoints78_mwhs - lengthPoints14_mwhs) / lengthPoints14_mwhs))*100, 1 ) + "%]\n";
      } else {
        mailBody_mwhs = mailBody_mwhs + "3RRPoints: None\n";
      }

      mailBody_mwhs = mailBody_mwhs + "\n";
      mailBody_mwhs = mailBody_mwhs + macdRsi + "\n";

      mailBody_mwhs = mailBody_mwhs + "\n";
      mailBody_mwhs = mailBody_mwhs + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_mwhs = mailBody_mwhs + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_mwhs = mailBody_mwhs + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_mwhs, mailBody_mwhs );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_EL_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_mwhs = Time[0];
    lastAlertZigzag_mwhs = zigzag2;
  }
  // EL_MW_HS_TR
  if(StringLen(alertText_tr) > 0 && requirement_tr >= AlertRequirementCount && lastAlert_tr != Time[0] && lastAlertZigzag_tr != zigzag2) {
    Alert(alertText_tr);
    if(MailAlert) {
      mailBody_tr = mailBody_tr + alertText_tr; // ロング or ショート、通貨ペア、時間足
      mailBody_tr = mailBody_tr + "Price: " + Close[0] + "\n";
      double lengthPoints12_tr = MathAbs( zigzag1 - zigzag2 ) / Point();
      double lengthPoints13_tr = MathAbs( zigzag1 - zigzag3 ) / Point();
      double lengthPoints14_tr = MathAbs( zigzag1 - zigzag4 ) / Point();
      double lengthPoints16_tr = MathAbs( zigzag1 - zigzag6 ) / Point();
      double lengthPoints19_tr = MathAbs( zigzag1 - zigzag9 ) / Point();
      double lengthPoints23_tr = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34_tr = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints36_tr = MathAbs( zigzag3 - zigzag6 ) / Point();
      double lengthPoints45_tr = MathAbs( zigzag4 - zigzag5 ) / Point();
      double lengthPoints56_tr = MathAbs( zigzag5 - zigzag6 ) / Point();
      double lengthPoints69_tr = MathAbs( zigzag6 - zigzag9 ) / Point();
      double lengthPoints910_tr = MathAbs( zigzag9 - zigzag10 ) / Point();
      mailBody_tr = mailBody_tr + "FiboPoints: " + DoubleToStr( lengthPoints69_tr, 0 ) + " / " + DoubleToStr( lengthPoints910_tr, 0 ) + " [" + DoubleToStr( (lengthPoints69_tr / lengthPoints910_tr) * 100, 1 ) + "%]\n";
      mailBody_tr = mailBody_tr + "E3Percent: " + DoubleToStr( lengthPoints16_tr, 0 ) + " / " + DoubleToStr( lengthPoints910_tr, 0 ) + " [" + DoubleToStr( (lengthPoints16_tr / lengthPoints910_tr) * 100, 1 ) + "%]\n";
      if(lengthPoints14_tr < lengthPoints69_tr) {
        mailBody_tr = mailBody_tr + "5RRPoints: " + DoubleToStr( lengthPoints19_tr, 0 ) + " / " + DoubleToStr( lengthPoints14_tr, 0 ) + " [" + DoubleToStr( (lengthPoints19_tr / lengthPoints14_tr) * 100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "5RRPoints: None\n";
      }
      if(lengthPoints14_tr < lengthPoints910_tr) {
        mailBody_tr = mailBody_tr + "3RRPoints: " + DoubleToStr( lengthPoints910_tr - lengthPoints14_tr, 0 ) + " / " + DoubleToStr( lengthPoints14_tr, 0 ) + " [" + DoubleToStr((((lengthPoints910_tr - lengthPoints14_tr) / lengthPoints14_tr))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3RRPoints: None\n";
      }

      mailBody_tr = mailBody_tr + "\n";
      mailBody_tr = mailBody_tr + macdRsi + "\n";

      mailBody_tr = mailBody_tr + "\n";
      mailBody_tr = mailBody_tr + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_tr = mailBody_tr + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_tr = mailBody_tr + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_tr, mailBody_tr );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_EL_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_tr, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_tr = Time[0];
    lastAlertZigzag_tr = zigzag2;
  }
  // EL_HS_TR
  if(StringLen(alertText) > 0 && requirement >= AlertRequirementCount && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    Alert(alertText);
    if(MailAlert) {
      mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Price: " + Close[0] + "\n";
      double lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      double lengthPoints14 = MathAbs( zigzag1 - zigzag4 ) / Point();
      double lengthPoints16 = MathAbs( zigzag1 - zigzag6 ) / Point();
      double lengthPoints19 = MathAbs( zigzag1 - zigzag9 ) / Point();
      double lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints36 = MathAbs( zigzag3 - zigzag6 ) / Point();
      double lengthPoints45 = MathAbs( zigzag4 - zigzag5 ) / Point();
      double lengthPoints56 = MathAbs( zigzag5 - zigzag6 ) / Point();
      double lengthPoints69 = MathAbs( zigzag6 - zigzag9 ) / Point();
      double lengthPoints910 = MathAbs( zigzag9 - zigzag10 ) / Point();
      mailBody = mailBody + "FiboPoints: " + DoubleToStr( lengthPoints69, 0 ) + " / " + DoubleToStr( lengthPoints910, 0 ) + " [" + DoubleToStr( (lengthPoints69 / lengthPoints910) * 100, 1 ) + "%]\n";
      mailBody = mailBody + "E3Percent: " + DoubleToStr( lengthPoints16, 0 ) + " / " + DoubleToStr( lengthPoints910, 0 ) + " [" + DoubleToStr( (lengthPoints16 / lengthPoints910) * 100, 1 ) + "%]\n";
      if(lengthPoints14 < lengthPoints69) {
        mailBody = mailBody + "5RRPoints: " + DoubleToStr( lengthPoints19, 0 ) + " / " + DoubleToStr( lengthPoints14, 0 ) + " [" + DoubleToStr( (lengthPoints19 / lengthPoints14) * 100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "5RRPoints: None\n";
      }
      if(lengthPoints14 < lengthPoints910) {
        mailBody = mailBody + "3RRPoints: " + DoubleToStr( lengthPoints910 - lengthPoints14, 0 ) + " / " + DoubleToStr( lengthPoints14, 0 ) + " [" + DoubleToStr((((lengthPoints910 - lengthPoints14) / lengthPoints14))*100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "3RRPoints: None\n";
      }

      mailBody = mailBody + "\n";
      mailBody = mailBody + macdRsi + "\n";

      mailBody = mailBody + "\n";
      mailBody = mailBody + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody = mailBody + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody = mailBody + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject, mailBody );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_EL_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert = Time[0];
    lastAlertZigzag = zigzag2;
  }

  return(0);
}
