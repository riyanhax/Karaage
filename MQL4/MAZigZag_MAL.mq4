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
input int AlertRequirementCount = 0;
input bool MailAlert = true;
input bool FileOutput = true;

datetime lastAlert_nc_mwhs = 0;
double lastAlertZigzag_nc_mwhs;
datetime lastAlert_trnc = 0;
double lastAlertZigzag_trnc;
datetime lastAlert_1st = 0;
double lastAlertZigzag_1st;
datetime lastAlert_nc_elmwhs = 0;
double lastAlertZigzag_nc_elmwhs;
datetime lastAlert_2nd = 0;
double lastAlertZigzag_2nd;
datetime lastAlert_2ndtr = 0;
double lastAlertZigzag_2ndtr;
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
  double ma1;
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
  string macdRsi_nc_mwhs;
  int requirement_trnc;
  string alertText_trnc;
  string mailSubject_trnc;
  string mailBody_trnc;
  string direction_trnc;
  string macdRsi_trnc;
  int requirement_1st;
  string alertText_1st;
  string mailSubject_1st;
  string mailBody_1st;
  string direction_1st;
  string macdRsi_1st;
  int requirement_nc_elmwhs;
  string alertText_nc_elmwhs;
  string mailSubject_nc_elmwhs;
  string mailBody_nc_elmwhs;
  string direction_nc_elmwhs;
  string macdRsi_nc_elmwhs;
  int requirement_2nd;
  string alertText_2nd;
  string mailSubject_2nd;
  string mailBody_2nd;
  string direction_2nd;
  string macdRsi_2nd;
  int handle;
  double lengthPoints12;
  double lengthPoints13;
  double lengthPoints23;
  double lengthPoints25;
  double lengthPoints34;
  double lengthPoints36;
  double lengthPoints67;
  double lengthPoints1c2;
  double lengthPoints1c3;

  // ZigZag取得
  cnt = 0;
  for(i=0; i<iBars( Symbol(), ZigzagTimeframe); i++) {
    zigzagTmp = iCustom(Symbol(), ZigzagTimeframe, "ZigZag", Depth, Deviation, Backstep, 0, i);
    if(cnt == 0 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag1 = zigzagTmp;
      macd1 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      rsi1 = iRSI( Symbol(), ZigzagTimeframe, 20, PRICE_CLOSE, i );
      ma1 = iMA( Symbol(), ZigzagTimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
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
  // HS_BB
  requirement_nc_mwhs = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
      && zigzag2 >= zigzag4 && zigzag3 <= zigzag5 && zigzag4 <= zigzag6 && zigzag1 > zigzag3
      && ma1 >= zigzag1 && zigzag2 >= ma1) {
    alertText_nc_mwhs = alertText_nc_mwhs + "Long_HS_L " + Symbol() + " " + periodText + "\n";
    alertText_nc_mwhs = alertText_nc_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_mwhs = "[Long_HS_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_mwhs = "long_hs_l";
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
      macdRsi_nc_mwhs = macdRsi_nc_mwhs + "DivSW: Short";
    } else {
      macdRsi_nc_mwhs = macdRsi_nc_mwhs + "DivSW: Long";
    }
  }
  // Short
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
      && zigzag2 <= zigzag4 && zigzag3 >= zigzag5 && zigzag4 >= zigzag6 && zigzag1 < zigzag3
      && ma1 <= zigzag1 && zigzag2 <= ma1) {
    alertText_nc_mwhs = alertText_nc_mwhs + "Short_HS_L " + Symbol() + " " + periodText + "\n";
    alertText_nc_mwhs = alertText_nc_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_mwhs = "[Short_HS_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_mwhs = "short_hs_l";
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

    if(macd3 < macd5) {
      macdRsi_nc_mwhs = macdRsi_nc_mwhs + "DivSW: Short";
    } else {
      macdRsi_nc_mwhs = macdRsi_nc_mwhs + "DivSW: Long";
    }
  }
  // ST_TR_BB
  requirement_trnc = 0;
  // Long_ST_TR_BB
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
     && zigzag2 >= zigzag4 && zigzag3 >= zigzag5 && zigzag1 > zigzag3
     && zigzag1 <= ma1 && zigzag2 >= ma1) {
    alertText_trnc = alertText_trnc + "Long_ST_TR_L " + Symbol() + " " + periodText + "\n";
    alertText_trnc = alertText_trnc + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_trnc = "[Long_ST_TR_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "long_st_tr_l";
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
      macdRsi_trnc = macdRsi_trnc + "Div: Long";
    } else {
      macdRsi_trnc = macdRsi_trnc + "Div: Short";
    }
  }
  // Short_ST_TR_BB
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
     && zigzag2 <= zigzag4 && zigzag3 <= zigzag5 && zigzag1 < zigzag3
     && zigzag1 >= ma1 && zigzag2 <= ma1) {
    alertText_trnc = alertText_trnc + "Short_ST_TR_L " + Symbol() + " " + periodText + "\n";
    alertText_trnc = alertText_trnc + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_trnc = "[Short_ST_TR_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "Short_st_tr_l";
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

    if(macd2 > macd4) {
      macdRsi_trnc = macdRsi_trnc + "Div: Long";
    } else {
      macdRsi_trnc = macdRsi_trnc + "Div: Short";
    }
  }
  // EL_BB
  requirement_nc_elmwhs = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag2 <= zigzag4 && zigzag3 >= zigzag5 && zigzag4 >= zigzag6 && zigzag1 <= zigzag3 && zigzag3 >= zigzag7 && zigzag1 >= zigzag5
      && zigzag1 <= ma1 && zigzag2 >= ma1) {
    alertText_nc_elmwhs = alertText_nc_elmwhs + "Long_EL_L " + Symbol() + " " + periodText + "\n";
    alertText_nc_elmwhs = alertText_nc_elmwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_elmwhs = "[Long_EL_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_elmwhs = "long_el_l";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_nc_elmwhs = alertText_nc_elmwhs + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_nc_elmwhs++;
      alertText_nc_elmwhs = alertText_nc_elmwhs + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_nc_elmwhs++;
      alertText_nc_elmwhs = alertText_nc_elmwhs + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_nc_elmwhs++;
      alertText_nc_elmwhs = alertText_nc_elmwhs + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_nc_elmwhs = alertText_nc_elmwhs + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd3 < macd5) {
      macdRsi_nc_elmwhs = macdRsi_nc_elmwhs + "DivSW: Short";
    } else {
      macdRsi_nc_elmwhs = macdRsi_nc_elmwhs + "DivSW: Long";
    }
  }
  // Short
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag2 >= zigzag4 && zigzag3 <= zigzag5 && zigzag4 <= zigzag6 && zigzag1 >= zigzag3 && zigzag3 <= zigzag7 && zigzag1 <= zigzag5
      && zigzag1 >= ma1 && zigzag2 <= ma1) {
    alertText_nc_elmwhs = alertText_nc_elmwhs + "Short_EL_L " + Symbol() + " " + periodText + "\n";
    alertText_nc_elmwhs = alertText_nc_elmwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_nc_elmwhs = "[Short_EL_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_nc_elmwhs = "short_el_l";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_nc_elmwhs = alertText_nc_elmwhs + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_nc_elmwhs++;
      alertText_nc_elmwhs = alertText_nc_elmwhs + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_nc_elmwhs++;
      alertText_nc_elmwhs = alertText_nc_elmwhs + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_nc_elmwhs++;
      alertText_nc_elmwhs = alertText_nc_elmwhs + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_nc_elmwhs = alertText_nc_elmwhs + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd3 < macd5) {
      macdRsi_nc_elmwhs = macdRsi_nc_elmwhs + "DivSW: Short";
    } else {
      macdRsi_nc_elmwhs = macdRsi_nc_elmwhs + "DivSW: Long";
    }
  }
  // 1st_BB
  requirement_1st = 0;
  // Long_1st_BB
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag1 > zigzag3
     && zigzag1 <= ma1 && zigzag2 >= ma1) {
    alertText_1st = alertText_1st + "Long_1st_L " + Symbol() + " " + periodText + "\n";
    alertText_1st = alertText_1st + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_1st = "[Long_1st_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_1st = "long_1st_l";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_1st = alertText_1st + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_1st++;
      alertText_1st = alertText_1st + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_1st++;
      alertText_1st = alertText_1st + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_1st++;
      alertText_1st = alertText_1st + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_1st = alertText_1st + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi_1st = macdRsi_1st + "Div: Long";
    } else {
      macdRsi_1st = macdRsi_1st + "Div: Short";
    }
  }
  // Short_1st_BB
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag1 < zigzag3
     && zigzag1 >= ma1 && zigzag2 <= ma1) {
    alertText_1st = alertText_1st + "Short_1st_L " + Symbol() + " " + periodText + "\n";
    alertText_1st = alertText_1st + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_1st = "[Short_1st_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_1st = "Short_1st_l";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_1st = alertText_1st + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_1st++;
      alertText_1st = alertText_1st + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_1st++;
      alertText_1st = alertText_1st + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_1st++;
      alertText_1st = alertText_1st + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_1st = alertText_1st + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi_1st = macdRsi_1st + "Div: Long";
    } else {
      macdRsi_1st = macdRsi_1st + "Div: Short";
    }
  }
  // 2nd_BB
  requirement_2nd = 0;
  // Long_2nd_BB
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
      && zigzag2 <= zigzag4 && zigzag3 >= zigzag5 && zigzag1 <= zigzag3 && zigzag1 >= zigzag5
      && zigzag1 <= ma1 && zigzag2 >= ma1) {
    alertText_2nd = alertText_2nd + "Long_2nd_L " + Symbol() + " " + periodText + "\n";
    alertText_2nd = alertText_2nd + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_2nd = "[Long_2nd_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_2nd = "long_2nd_l";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_2nd = alertText_2nd + "①ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_2nd++;
      alertText_2nd = alertText_2nd + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_2nd++;
      alertText_2nd = alertText_2nd + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_2nd++;
      alertText_2nd = alertText_2nd + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_2nd = alertText_2nd + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd3 < macd5) {
      macdRsi_2nd = macdRsi_2nd + "DivSW: Short";
    } else {
      macdRsi_2nd = macdRsi_2nd + "DivSW: Long";
    }
  }
  // Short_2nd_BB
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
      && zigzag2 >= zigzag4 && zigzag3 <= zigzag5 && zigzag1 >= zigzag3 && zigzag1 <= zigzag5
      && zigzag1 >= ma1 && zigzag2 <= ma1) {
    alertText_2nd = alertText_2nd + "Short_2nd_L " + Symbol() + " " + periodText + "\n";
    alertText_2nd = alertText_2nd + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_2nd = "[Short_2nd_L] " + Symbol() + " " + periodText + " " + Time[0];
    direction_2nd = "short_2nd_l";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_2nd = alertText_2nd + "①ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_2nd++;
      alertText_2nd = alertText_2nd + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_2nd++;
      alertText_2nd = alertText_2nd + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_2nd++;
      alertText_2nd = alertText_2nd + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_2nd = alertText_2nd + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd3 < macd5) {
      macdRsi_2nd = macdRsi_2nd + "DivSW: Short";
    } else {
      macdRsi_2nd = macdRsi_2nd + "DivSW: Long";
    }
  }

  // 条件を満たした数によってアラート
  // HS_BB
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

      mailBody_nc_mwhs = mailBody_nc_mwhs + "\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + "NCRRPoints: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + "3RRPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints23 / lengthPoints1c3))*100, 1 ) + "%]\n";

      mailBody_nc_mwhs = mailBody_nc_mwhs + "\n";
      mailBody_nc_mwhs = mailBody_nc_mwhs + macdRsi_nc_mwhs + "\n";

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
  // ST_TR_BB
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

      mailBody_trnc = mailBody_trnc + "\n";
      mailBody_trnc = mailBody_trnc + "NCRRPoints: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_trnc = mailBody_trnc + "3RRPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints25 / lengthPoints1c3))*100, 1 ) + "%]\n";

      mailBody_trnc = mailBody_trnc + "\n";
      mailBody_trnc = mailBody_trnc + macdRsi_trnc + "\n";

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
  // EL_BB
  if(StringLen(alertText_nc_elmwhs) > 0 && requirement_nc_elmwhs >= AlertRequirementCount && lastAlert_nc_elmwhs != Time[0] && lastAlertZigzag_nc_elmwhs != zigzag2) {
    Alert(alertText_nc_elmwhs);
    if(MailAlert) {
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + alertText_nc_elmwhs; // ロング or ショート、通貨ペア、時間足
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints36 = MathAbs( zigzag3 - zigzag6 ) / Point();
      lengthPoints67 = MathAbs( zigzag6 - zigzag7 ) / Point();
      lengthPoints1c2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1c3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "NCFiboPts: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "ELFiboPts: " + DoubleToStr( lengthPoints36, 0 ) + " / " + DoubleToStr( lengthPoints67, 0 ) + " [" + DoubleToStr( (lengthPoints36 / lengthPoints67) * 100, 1 ) + "%]\n";

      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "\n";
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "NCRRPts: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "3RRPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints23 / lengthPoints1c3))*100, 1 ) + "%]\n";
      if(lengthPoints67 > lengthPoints23) {
        mailBody_nc_elmwhs = mailBody_nc_elmwhs + "ELRRPts: " + DoubleToStr( lengthPoints67 - lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr((((lengthPoints67 - lengthPoints23) / lengthPoints1c3))*100, 1 ) + "%]\n";
      } else {
        mailBody_nc_elmwhs = mailBody_nc_elmwhs + "ELRRPts: None\n";
      }

      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "\n";
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + macdRsi_nc_elmwhs + "\n";

      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "\n";
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_nc_elmwhs = mailBody_nc_elmwhs + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_nc_elmwhs, mailBody_nc_elmwhs );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_nc_elmwhs, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_nc_elmwhs = Time[0];
    lastAlertZigzag_nc_elmwhs = zigzag2;
  }
  // 1st_BB
  if(StringLen(alertText_trnc) == 0 && StringLen(alertText_nc_mwhs) == 0 && StringLen(alertText_1st) > 0 && requirement_1st >= AlertRequirementCount && lastAlert_1st != Time[0] && lastAlertZigzag_1st != zigzag2) {
    Alert(alertText_1st);
    if(MailAlert) {
      mailBody_1st = mailBody_1st + alertText_1st; // ロング or ショート、通貨ペア、時間足
      mailBody_1st = mailBody_1st + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints1c2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1c3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      mailBody_1st = mailBody_1st + "FiboPoints: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";

      mailBody_1st = mailBody_1st + "\n";
      mailBody_1st = mailBody_1st + "NCRRPoints: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_1st = mailBody_1st + "3RRPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints25 / lengthPoints1c3))*100, 1 ) + "%]\n";

      mailBody_1st = mailBody_1st + "\n";
      mailBody_1st = mailBody_1st + macdRsi_1st + "\n";

      mailBody_1st = mailBody_1st + "\n";
      mailBody_1st = mailBody_1st + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_1st = mailBody_1st + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_1st = mailBody_1st + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_1st, mailBody_1st );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_1st, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_1st = Time[0];
    lastAlertZigzag_1st = zigzag2;
  }
  // 2nd_BB
  if(StringLen(alertText_nc_elmwhs) == 0 && StringLen(alertText_2nd) > 0 && requirement_2nd >= AlertRequirementCount && lastAlert_2nd != Time[0] && lastAlertZigzag_2nd != zigzag2) {
    Alert(alertText_2nd);
    if(MailAlert) {
      mailBody_2nd = mailBody_2nd + alertText_2nd; // ロング or ショート、通貨ペア、時間足
      mailBody_2nd = mailBody_2nd + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints36 = MathAbs( zigzag3 - zigzag6 ) / Point();
      lengthPoints67 = MathAbs( zigzag6 - zigzag7 ) / Point();
      lengthPoints1c2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1c3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      mailBody_2nd = mailBody_2nd + "NCFiboPts: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody_2nd = mailBody_2nd + "ELFiboPts: " + DoubleToStr( lengthPoints36, 0 ) + " / " + DoubleToStr( lengthPoints67, 0 ) + " [" + DoubleToStr( (lengthPoints36 / lengthPoints67) * 100, 1 ) + "%]\n";

      mailBody_2nd = mailBody_2nd + "\n";
      mailBody_2nd = mailBody_2nd + "NCRRPts: " + DoubleToStr( lengthPoints1c2, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr( (lengthPoints1c2 / lengthPoints1c3) * 100, 1 ) + "%]\n";
      mailBody_2nd = mailBody_2nd + "3RRPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr(((lengthPoints23 / lengthPoints1c3))*100, 1 ) + "%]\n";
      if(lengthPoints67 > lengthPoints23) {
        mailBody_2nd = mailBody_2nd + "ELRRPts: " + DoubleToStr( lengthPoints67 - lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints1c3, 0 ) + " [" + DoubleToStr((((lengthPoints67 - lengthPoints23) / lengthPoints1c3))*100, 1 ) + "%]\n";
      } else {
        mailBody_2nd = mailBody_2nd + "ELRRPts: None\n";
      }

      mailBody_2nd = mailBody_2nd + "\n";
      mailBody_2nd = mailBody_2nd + macdRsi_2nd + "\n";

      mailBody_2nd = mailBody_2nd + "\n";
      mailBody_2nd = mailBody_2nd + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_2nd = mailBody_2nd + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_2nd = mailBody_2nd + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_2nd, mailBody_2nd );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_2nd, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_2nd = Time[0];
    lastAlertZigzag_2nd = zigzag2;
  }

  return(0);
}
