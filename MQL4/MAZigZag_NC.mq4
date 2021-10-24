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

datetime lastAlert_nc_hstr = 0;
double lastAlertZigzag_nc_hstr;
datetime lastAlert_nc_mwhs = 0;
double lastAlertZigzag_nc_mwhs;
datetime lastAlert_nc_mwhstr = 0;
double lastAlertZigzag_nc_mwhstr;
datetime lastAlert_trnc = 0;
double lastAlertZigzag_trnc;
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
  double macd1;
  double macd2;
  double macd3;
  double macd4;
  double macd5;
  double macd7;
  double rsi1;
  double rsi2;
  double maCurrentEma;
  double maCurrentSma;
  double maMiddleEma;
  double maMiddleSma;
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement_nc_mwhs;
  string alertText_nc_mwhs;
  string mailSubject_nc_mwhs;
  string mailBody_nc_mwhs;
  string direction_nc_mwhs;
  int requirement_nc_mwhstr;
  string alertText_nc_mwhstr;
  string mailSubject_nc_mwhstr;
  string mailBody_nc_mwhstr;
  string direction_nc_mwhstr;
  int requirement_nc_hstr;
  string alertText_nc_hstr;
  string mailSubject_nc_hstr;
  string mailBody_nc_hstr;
  string direction_nc_hstr;
  int requirement_trnc;
  string alertText_trnc;
  string mailSubject_trnc;
  string mailBody_trnc;
  string direction_trnc;
  int handle;
  double lengthPoints12;
  double lengthPoints13;
  double lengthPoints23;
  double lengthPoints25;
  double lengthPoints34;
  double lengthPoints1c2;
  double lengthPoints1c3;
  string macdRsi;

  // ZigZag取得
  cnt = 0;
  for(i=0; i<iBars( Symbol(), ZigzagTimeframe); i++) {
    zigzagTmp = iCustom(Symbol(), ZigzagTimeframe, "ZigZag", Depth, Deviation, Backstep, 0, i);
    if(cnt == 0 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag1 = zigzagTmp;
      macd1 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      rsi1 = iRSI( Symbol(), ZigzagTimeframe, 20, PRICE_CLOSE, i );
      cnt = 1;
    } else if(cnt == 1 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag2 = zigzagTmp;
      macd2 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      rsi2 = iRSI( Symbol(), ZigzagTimeframe, 20, PRICE_CLOSE, i );
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
      cnt = 6;
    } else if(cnt == 6 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag7 = zigzagTmp;
      macd7 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 7;
    } else if(cnt == 7 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag8 = zigzagTmp;
      cnt = 8;
    } else if(cnt == 8 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag9 = zigzagTmp;
      cnt = 9;
      break;
    }
  }

  // 条件
  // MW_HS_NC
  requirement_nc_mwhs = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
      && zigzag2 >= zigzag4 && zigzag3 <= zigzag5 && zigzag4 <= zigzag6 && zigzag1 > zigzag3
      && iOpen(Symbol(), ZigzagTimeframe, 1) < zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) >= zigzag4) {
    alertText_nc_mwhs = alertText_nc_mwhs + "Long_MW_HS_NC " + Symbol() + " " + periodText + "\n";
    alertText_nc_mwhs = alertText_nc_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_mwhs = "[Long_MW_HS_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_mwhs = "long_mw_hs_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_nc_mwhs = alertText_nc_mwhs + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_nc_mwhs++;
      alertText_nc_mwhs = alertText_nc_mwhs + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_nc_mwhs++;
      alertText_nc_mwhs = alertText_nc_mwhs + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_nc_mwhs++;
      alertText_nc_mwhs = alertText_nc_mwhs + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_nc_mwhs = alertText_nc_mwhs + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd3 < macd5) {
      macdRsi = macdRsi + "Div: Short";
    } else {
      macdRsi = macdRsi + "Div: Long";
    }
  }
  // Short
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
      && zigzag2 <= zigzag4 && zigzag3 >= zigzag5 && zigzag4 >= zigzag6 && zigzag1 < zigzag3
      && iOpen(Symbol(), ZigzagTimeframe, 1) > zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) <= zigzag4) {
    alertText_nc_mwhs = alertText_nc_mwhs + "Short_MW_HS_NC " + Symbol() + " " + periodText + "\n";
    alertText_nc_mwhs = alertText_nc_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_mwhs = "[Short_MW_HS_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_mwhs = "short_mw_hs_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_nc_mwhs = alertText_nc_mwhs + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_nc_mwhs++;
      alertText_nc_mwhs = alertText_nc_mwhs + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_nc_mwhs++;
      alertText_nc_mwhs = alertText_nc_mwhs + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_nc_mwhs++;
      alertText_nc_mwhs = alertText_nc_mwhs + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_nc_mwhs = alertText_nc_mwhs + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd3 > macd5) {
      macdRsi = macdRsi + "Div: Short";
    } else {
      macdRsi = macdRsi + "Div: Long";
    }
  }
  // MW_HS_TR_NC
  requirement_nc_mwhstr = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
      && zigzag5 < zigzag6 && zigzag6 > zigzag7 && zigzag7 < zigzag8
      && zigzag2 >= zigzag4 && zigzag3 >= zigzag5 && zigzag4 >= zigzag6 && zigzag1 > zigzag3
      && zigzag5 <= zigzag7 && zigzag6 <= zigzag8
      && iOpen(Symbol(), ZigzagTimeframe, 1) < zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) >= zigzag4) {
    alertText_nc_mwhstr = alertText_nc_mwhstr + "Long_MW_HS_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_nc_mwhstr = alertText_nc_mwhstr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_mwhstr = "[Long_MW_HS_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_mwhstr = "long_mw_hs_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_nc_mwhstr = alertText_nc_mwhstr + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_nc_mwhstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_nc_mwhstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_nc_mwhstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_nc_mwhstr = alertText_nc_mwhstr + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi = macdRsi + "DivA: Long";
    } else {
      macdRsi = macdRsi + "DivA: Short";
    }
    macdRsi = macdRsi + "\n";
    if(macd7 > macd5) {
      macdRsi = macdRsi + "DivB: Short";
    } else {
      macdRsi = macdRsi + "DivB: Long";
    }
  }
  // Short
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
      && zigzag5 > zigzag6 && zigzag6 < zigzag7 && zigzag7 > zigzag8
      && zigzag2 <= zigzag4 && zigzag3 <= zigzag5 && zigzag4 <= zigzag6 && zigzag1 < zigzag3
      && zigzag5 >= zigzag7 && zigzag6 >= zigzag8
      && iOpen(Symbol(), ZigzagTimeframe, 1) > zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) <= zigzag4) {
    alertText_nc_mwhstr = alertText_nc_mwhstr + "Short_MW_HS_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_nc_mwhstr = alertText_nc_mwhstr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_mwhstr = "[Short_MW_HS_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_mwhstr = "short_mw_hs_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_nc_mwhstr = alertText_nc_mwhstr + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_nc_mwhstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_nc_mwhstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_nc_mwhstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_nc_mwhstr = alertText_nc_mwhstr + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd2 < macd4) {
      macdRsi = macdRsi + "DivA: Long";
    } else {
      macdRsi = macdRsi + "DivA: Short";
    }
    macdRsi = macdRsi + "\n";
    if(macd7 < macd5) {
      macdRsi = macdRsi + "DivB: Short";
    } else {
      macdRsi = macdRsi + "DivB: Long";
    }
  }
  // HS_TR_NC
  requirement_nc_hstr = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
      && zigzag5 < zigzag6 && zigzag6 > zigzag7 && zigzag7 < zigzag8
      && zigzag2 >= zigzag4 && zigzag3 >= zigzag5 && zigzag4 <= zigzag6 && zigzag1 > zigzag3
      && zigzag5 <= zigzag7 && zigzag6 <= zigzag8 && zigzag2 >= zigzag6
      && iOpen(Symbol(), ZigzagTimeframe, 1) < zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) >= zigzag4) {
    alertText_nc_hstr = alertText_nc_hstr + "Long_HS_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_nc_hstr = alertText_nc_hstr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_hstr = "[Long_HS_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_hstr = "long_hs_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_nc_mwhstr = alertText_nc_mwhstr + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_nc_hstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_nc_hstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_nc_hstr++;
      alertText_nc_mwhstr = alertText_nc_mwhstr + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_nc_mwhstr = alertText_nc_mwhstr + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi = macdRsi + "DivA: Long";
    } else {
      macdRsi = macdRsi + "DivA: Short";
    }
    macdRsi = macdRsi + "\n";
    if(macd7 > macd5) {
      macdRsi = macdRsi + "DivB: Short";
    } else {
      macdRsi = macdRsi + "DivB: Long";
    }
  }
  // Short
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
      && zigzag5 > zigzag6 && zigzag6 < zigzag7 && zigzag7 > zigzag8
      && zigzag2 <= zigzag4 && zigzag3 <= zigzag5 && zigzag4 >= zigzag6 && zigzag1 < zigzag3
      && zigzag5 >= zigzag7 && zigzag6 >= zigzag8 && zigzag2 <= zigzag6
      && iOpen(Symbol(), ZigzagTimeframe, 1) > zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) <= zigzag4) {
    alertText_nc_hstr = alertText_nc_hstr + "Short_HS_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_nc_hstr = alertText_nc_hstr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_hstr = "[Short_HS_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_hstr = "short_hs_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_nc_hstr = alertText_nc_hstr + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_nc_hstr++;
      alertText_nc_hstr = alertText_nc_hstr + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_nc_hstr++;
      alertText_nc_hstr = alertText_nc_hstr + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_nc_hstr++;
      alertText_nc_hstr = alertText_nc_hstr + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_nc_hstr = alertText_nc_hstr + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd2 < macd4) {
      macdRsi = macdRsi + "DivA: Long";
    } else {
      macdRsi = macdRsi + "DivA: Short";
    }
    macdRsi = macdRsi + "\n";
    if(macd7 < macd5) {
      macdRsi = macdRsi + "DivB: Short";
    } else {
      macdRsi = macdRsi + "DivB: Long";
    }
  }
  // ST_TR_NC
  requirement_trnc = 0;
  // Long_TR_NC
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
     && zigzag2 >= zigzag4 && zigzag3 >= zigzag5 && zigzag1 > zigzag3
     && iOpen(Symbol(), ZigzagTimeframe, 1) < zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) >= zigzag4) {
    alertText_trnc = alertText_trnc + "Long_ST_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_trnc = alertText_trnc + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_trnc = "[Long_ST_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "long_st_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_trnc = alertText_trnc + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_trnc = alertText_trnc + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi = macdRsi + "Div: Long";
    } else {
      macdRsi = macdRsi + "Div: Short";
    }
    //macdRsi = macdRsi + "RSI: " + DoubleToStr( rsi1, 2 ) + ", " + DoubleToStr( rsi2, 2 );
  }
  // Short_TR_NC
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
     && zigzag2 <= zigzag4 && zigzag3 <= zigzag5 && zigzag1 < zigzag3
     && iOpen(Symbol(), ZigzagTimeframe, 1) > zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) <= zigzag4) {
    alertText_trnc = alertText_trnc + "Short_ST_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_trnc = alertText_trnc + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_trnc = "[Short_ST_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "Short_ST_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_trnc = alertText_trnc + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_trnc = alertText_trnc + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd2  < macd4) {
      macdRsi = macdRsi + "Div: Short";
    } else {
      macdRsi = macdRsi + "Div: Long";
    }
    //macdRsi = macdRsi + "RSI: " + DoubleToStr( rsi1, 2 ) + ", " + DoubleToStr( rsi2, 2 );
  }


  // 条件を満たした数によってアラート
  // MW_HS_NC
  if(StringLen(alertText_nc_mwhs) > 0 && requirement_nc_mwhs >= AlertRequirementCount && lastAlert_nc_mwhs != Time[0] && lastAlertZigzag_nc_mwhs != zigzag2) {
    Alert(alertText_nc_mwhs);
    if(MailAlert) {
      mailBody_nc_mwhs = mailBody_nc_mwhs + alertText_nc_mwhs; // ロング or ショート、通貨ペア、時間足
      mailBody_nc_mwhs = mailBody_nc_mwhs + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints1c2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1c3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      mailBody_nc_mwhs = mailBody_nc_mwhs + "FiboPoints: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + "NCRRPoints: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + "3RRPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints25 / lengthPoints1c3))*100, 1 ) + "%]\n";

      mailBody_nc_mwhs = mailBody_nc_mwhs + "\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + macdRsi + "\n";

      mailBody_nc_mwhs = mailBody_nc_mwhs + "\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_nc_mwhs, mailBody_nc_mwhs );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_nc_mwhs, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_nc_mwhs = Time[0];
    lastAlertZigzag_nc_mwhs = zigzag2;
  }
  // MW_HS_TR_NC
  if(StringLen(alertText_nc_mwhstr) > 0 && requirement_nc_mwhstr >= AlertRequirementCount && lastAlert_nc_mwhstr != Time[0] && lastAlertZigzag_nc_mwhstr != zigzag2) {
    Alert(alertText_nc_mwhstr);
    if(MailAlert) {
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + alertText_nc_mwhstr; // ロング or ショート、通貨ペア、時間足
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints1c2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1c3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "FiboPoints: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "NCRRPoints: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "3RRPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints25 / lengthPoints1c3))*100, 1 ) + "%]\n";

      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "\n";
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + macdRsi + "\n";

      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "\n";
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_nc_mwhstr = mailBody_nc_mwhstr + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_nc_mwhstr, mailBody_nc_mwhstr );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_nc_mwhstr, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_nc_mwhstr = Time[0];
    lastAlertZigzag_nc_mwhstr = zigzag2;
  }
  // HS_TR_NC
  if(StringLen(alertText_nc_hstr) > 0 && requirement_nc_hstr >= AlertRequirementCount && lastAlert_nc_hstr != Time[0] && lastAlertZigzag_nc_hstr != zigzag2) {
    Alert(alertText_nc_hstr);
    if(MailAlert) {
      mailBody_nc_hstr = mailBody_nc_hstr + alertText_nc_hstr; // ロング or ショート、通貨ペア、時間足
      mailBody_nc_hstr = mailBody_nc_hstr + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints1c2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1c3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      mailBody_nc_hstr = mailBody_nc_hstr + "FiboPoints: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody_nc_hstr = mailBody_nc_hstr + "NCRRPoints: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_nc_hstr = mailBody_nc_hstr + "3RRPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints25 / lengthPoints1c3))*100, 1 ) + "%]\n";

      mailBody_nc_hstr = mailBody_nc_hstr + "\n";
      mailBody_nc_hstr = mailBody_nc_hstr + macdRsi + "\n";

      mailBody_nc_hstr = mailBody_nc_hstr + "\n";
      mailBody_nc_hstr = mailBody_nc_hstr + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_nc_hstr = mailBody_nc_hstr + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_nc_hstr = mailBody_nc_hstr + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_nc_hstr, mailBody_nc_hstr );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_nc_hstr, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_nc_hstr = Time[0];
    lastAlertZigzag_nc_hstr = zigzag2;
  }
  // ST_TR_NC
  if(StringLen(alertText_trnc) > 0 && requirement_trnc >= AlertRequirementCount && lastAlert_trnc != Time[0] && lastAlertZigzag_trnc != zigzag2) {
    Alert(alertText_trnc);
    if(MailAlert) {
      mailBody_trnc = mailBody_trnc + alertText_trnc; // ロング or ショート、通貨ペア、時間足
      mailBody_trnc = mailBody_trnc + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints1c2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1c3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      mailBody_trnc = mailBody_trnc + "FiboPoints: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody_trnc = mailBody_trnc + "NCRRPoints: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_trnc = mailBody_trnc + "3RRPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints25 / lengthPoints1c3))*100, 1 ) + "%]\n";

      mailBody_trnc = mailBody_trnc + "\n";
      mailBody_trnc = mailBody_trnc + macdRsi + "\n";

      mailBody_trnc = mailBody_trnc + "\n";
      mailBody_trnc = mailBody_trnc + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_trnc = mailBody_trnc + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_trnc = mailBody_trnc + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_trnc, mailBody_trnc );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_trnc, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_trnc = Time[0];
    lastAlertZigzag_trnc = zigzag2;
  }


  return(0);
}
