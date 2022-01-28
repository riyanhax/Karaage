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
input bool MailAlert = true;
input bool FileOutput = true;

datetime lastAlert_yks = 0;
double lastAlertZigzag_yks;
datetime lastAlert_tr = 0;
double lastAlertZigzag_tr;
datetime lastAlert_mwhs = 0;
double lastAlertZigzag_mwhs;
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
  double maCurrentEma;
  double maCurrentSma;
  double maCurrentEma2;
  double maCurrentSma2;
  double maCurrentEma3;
  double maCurrentSma3;
  double maCurrentEma4;
  double maCurrentSma4;
  double maCurrentEma5;
  double maCurrentSma5;
  double maCurrentEma6;
  double maCurrentSma6;
  double maCurrentEma7;
  double maCurrentSma7;
  double maMiddleEma;
  double maMiddleSma;
  double maMiddleEma2;
  double maMiddleSma2;
  double maMiddleEma3;
  double maMiddleSma3;
  double maMiddleEma4;
  double maMiddleSma4;
  double maMiddleEma5;
  double maMiddleSma5;
  double maMiddleEma6;
  double maMiddleSma6;
  double maMiddleEma7;
  double maMiddleSma7;
  double maLongEma;
  double maLongSma;
  double maLongEma2;
  double maLongSma2;
  double maLongEma3;
  double maLongSma3;
  double maLongEma4;
  double maLongSma4;
  double maLongEma5;
  double maLongSma5;
  double maLongEma6;
  double maLongSma6;
  double maLongEma7;
  double maLongSma7;
  int i;
  int cnt;
  string alertText_yks;
  string mailSubject_yks;
  string mailBody_yks;
  string direction_yks;
  int requirement_tr;
  string alertText_tr;
  string mailSubject_tr;
  string mailBody_tr;
  string direction_tr;
  string alertText_mwhs;
  string mailSubject_mwhs;
  string mailBody_mwhs;
  string direction_mwhs;
  int handle;
  double lengthPoints23;
  double lengthPoints34;
  double lengthPoints36;
  double lengthPoints1C2;
  double macd3;
  double macd4;
  double macd5;
  double macd6;
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
      maCurrentSma2 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma2 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma2 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma2 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma2 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma2 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      cnt = 2;
    } else if(cnt == 2 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag3 = zigzagTmp;
      maCurrentSma3 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma3 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma3 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma3 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma3 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma3 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      macd3 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 3;
    } else if(cnt == 3 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag4 = zigzagTmp;
      maCurrentSma4 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma4 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma4 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma4 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma4 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma4 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      macd4 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 4;
    } else if(cnt == 4 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag5 = zigzagTmp;
      maCurrentSma5 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma5 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma5 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma5 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma5 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma5 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      macd5 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 5;
    } else if(cnt == 5 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag6 = zigzagTmp;
      maCurrentSma6 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma6 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma6 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma6 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma6 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma6 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      macd6 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 6;
    } else if(cnt == 6 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag7 = zigzagTmp;
      maCurrentSma7 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma7 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma7 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma7 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma7 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma7 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      cnt = 7;
      break;
    }
  }
  // MovingAverage取得
  maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
  maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
  maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
  maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
  maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
  maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

  // 条件
  // BR
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag2 >= zigzag4
    && zigzag1 > zigzag3) {
    if(iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 1本前が陽線
      && iOpen( Symbol(), MATimeframe, 1 ) < zigzag3 && iClose( Symbol(), MATimeframe, 1 ) >= zigzag3 // 1本前がzigzag3を跨ぐ
      ) {

      alertText_yks = alertText_yks + "Long_BR " + Symbol() + " " + periodText + "\n";
      alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailSubject_yks = "[Long_BR] " + Symbol() + " " + periodText + " " + Time[0];
      direction_yks = "long_br";

      if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
        alertText_yks = alertText_yks + "①ALL EMA: Golden Cross" + "\n";
      }
      if(maMiddleEma < maCurrentEma) {
        alertText_yks = alertText_yks + "②EMA: Golden Cross" + "\n";
      }
      if(maCurrentSma < maCurrentEma) {
        alertText_yks = alertText_yks + "③Short MA: Golden Cross" + "\n";
      }
      if(maMiddleSma < maMiddleEma) {
        alertText_yks = alertText_yks + "④Middle MA: Golden Cross" + "\n";
      }
      if(maLongSma < maLongEma) {
        alertText_yks = alertText_yks + "⑤Long MA: Golden Cross" + "\n";
      }
    }
  }
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag2 <= zigzag4
    && zigzag1 < zigzag3) {
    if(iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 1本前が陰線
      && iOpen( Symbol(), MATimeframe, 1 ) > zigzag3 && iClose( Symbol(), MATimeframe, 1 ) <= zigzag3 // 1本前がzigzag3を跨ぐ
      ) {

      alertText_yks = alertText_yks + "Short_BR " + Symbol() + " " + periodText + "\n";
      alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailSubject_yks = "[Short_BR] " + Symbol() + " " + periodText + " " + Time[0];
      direction_yks = "short_br";

      if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
        alertText_yks = alertText_yks + "①ALL EMA: Dead Cross" + "\n";
      }
      if(maMiddleEma > maCurrentEma) {
        alertText_yks = alertText_yks + "②EMA: Dead Cross" + "\n";
      }
      if(maCurrentSma > maCurrentEma) {
        alertText_yks = alertText_yks + "③Short MA: Dead Cross" + "\n";
      }
      if(maMiddleSma > maMiddleEma) {
        alertText_yks = alertText_yks + "④Middle MA: Dead Cross" + "\n";
      }
      if(maLongSma > maLongEma) {
        alertText_yks = alertText_yks + "⑤Long MA: Dead Cross" + "\n";
      }
    }
  }
  // BR_ST_TR
  // LONG
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
    && zigzag3 > zigzag5 && zigzag2 >= zigzag5 && zigzag4 >= zigzag6 && zigzag2 >= zigzag4
    && zigzag1 > zigzag3
    && iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 1本前が陽線
    && iOpen( Symbol(), MATimeframe, 1 ) < zigzag3 && iClose( Symbol(), MATimeframe, 1 ) >= zigzag3 // 1本前がzigzag3を跨ぐ
    ) {
    alertText_tr = alertText_tr + "Long_BR_ST_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Long_BR_ST_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "long_br_st_tr";
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

    if(macd3 > macd5) {
      macdRsi = macdRsi + "Div: Long";
    } else {
      macdRsi = macdRsi + "Div: Short";
    }

  }
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
    && zigzag3 < zigzag5 && zigzag2 <= zigzag5 && zigzag4 <= zigzag6 && zigzag2 <= zigzag4
    && zigzag1 < zigzag3
    && iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 1本前が陰線
    && iOpen( Symbol(), MATimeframe, 1 ) > zigzag3 && iClose( Symbol(), MATimeframe, 1 ) >= zigzag3 // 1本前がzigzag3を跨ぐ
    ) {
    alertText_tr = alertText_tr + "Short_BR_ST_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Short_BR_ST_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "short_br_st_tr";
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

    if(macd3 > macd5) {
      macdRsi = macdRsi + "Div: Long";
    } else {
      macdRsi = macdRsi + "Div: Short";
    }
  }
  // BR_HS
  // Long
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag5 <= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4
      && zigzag4 <= zigzag6 && zigzag1 > zigzag3
      && iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 1本前が陽線
      && iOpen( Symbol(), MATimeframe, 1 ) < zigzag3 && iClose( Symbol(), MATimeframe, 1 ) >= zigzag3 // 1本前がzigzag3を跨ぐ
      ) {
    alertText_mwhs = alertText_mwhs + "Long_BR_HS " + Symbol() + " " + periodText + "\n";
    alertText_mwhs = alertText_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_mwhs = "[Long_BR_HS] " + Symbol() + " " + periodText + " " + Time[0];
    direction_mwhs = "long_br_hs";

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
      alertText_mwhs = alertText_mwhs + "②EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      alertText_mwhs = alertText_mwhs + "③Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      alertText_mwhs = alertText_mwhs + "④Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_mwhs = alertText_mwhs + "⑤Long MA: Golden Cross" + "\n";
    }

    if(macd4 < macd6) {
      macdRsi = macdRsi + "DivSW: Short";
    } else {
      macdRsi = macdRsi + "DivSW: Long";
    }
  }
  // Short
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag5 >= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4
      && zigzag4 >= zigzag6 && zigzag1 < zigzag3
      && iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 1本前が陰線
      && iOpen( Symbol(), MATimeframe, 1 ) > zigzag3 && iClose( Symbol(), MATimeframe, 1 ) >= zigzag3 // 1本前がzigzag3を跨ぐ
      ) {
    alertText_mwhs = alertText_mwhs + "Short_BR_HS " + Symbol() + " " + periodText + "\n";
    alertText_mwhs = alertText_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_mwhs = "[Short_BR_HS] " + Symbol() + " " + periodText + " " + Time[0];
    direction_mwhs = "short_br_hs";

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
      alertText_mwhs = alertText_mwhs + "②EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      alertText_mwhs = alertText_mwhs + "③Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      alertText_mwhs = alertText_mwhs + "④Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_mwhs = alertText_mwhs + "⑤Long MA: Dead Cross" + "\n";
    }

    if(macd4 < macd6) {
      macdRsi = macdRsi + "DivSW: Short";
    } else {
      macdRsi = macdRsi + "DivSW: Long";
    }
  }

  // アラート
  // BR
  if(StringLen( alertText_yks ) > 0 && lastAlert_yks != Time[0] && lastAlertZigzag_yks != zigzag2
    && StringLen(alertText_tr) == 0 && StringLen(alertText_mwhs) == 0) {
    Alert(alertText_yks);
    if(MailAlert) {
      mailBody_yks = mailBody_yks + alertText_yks; // ロング or ショート、通貨ペア、時間足
      mailBody_yks = mailBody_yks + "Price: " + Close[0] + "\n";
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints1C2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      mailBody_yks = mailBody_yks + "FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_yks = mailBody_yks + "E3Percent: " + DoubleToStr( lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints1C2 / lengthPoints34) * 100, 1 ) + "%]\n";

      mailBody_yks = mailBody_yks + "\n";
      if(lengthPoints1C2 < lengthPoints34) {
        mailBody_yks = mailBody_yks + "3RRPts: " + DoubleToStr( lengthPoints34 - lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints1C2, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints1C2) / lengthPoints1C2))*100, 1 ) + "%]\n";
      } else {
        mailBody_yks = mailBody_yks + "3RRPts: None\n";
      }

      mailBody_yks = mailBody_yks + "\n";
      mailBody_yks = mailBody_yks + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_yks = mailBody_yks + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_yks = mailBody_yks + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_yks, mailBody_yks );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_BR_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_yks, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_yks = Time[0];
    lastAlertZigzag_yks = zigzag2;
  }
  // BR_ST_TR
  if(StringLen(alertText_tr) > 0 && lastAlert_tr != Time[0] && lastAlertZigzag_tr != zigzag2) {
    Alert(alertText_tr);
    if(MailAlert) {
      mailBody_tr = mailBody_tr + alertText_tr; // ロング or ショート、通貨ペア、時間足
      mailBody_tr = mailBody_tr + "Price: " + Close[0] + "\n";
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints36 = MathAbs( zigzag3 - zigzag6 ) / Point();
      lengthPoints1C2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      mailBody_tr = mailBody_tr + "3-3 FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_tr = mailBody_tr + "3-3´FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints36, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints36) * 100, 1 ) + "%]\n";

      mailBody_tr = mailBody_tr + "\n";
      if(lengthPoints1C2 < lengthPoints34) {
        mailBody_tr = mailBody_tr + "3-3 RRPts: " + DoubleToStr( lengthPoints34 - lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints1C2, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints1C2) / lengthPoints1C2))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3-3 RRPts: None\n";
      }
      if(lengthPoints1C2 < lengthPoints36) {
        mailBody_tr = mailBody_tr + "3-3´RRPts: " + DoubleToStr( lengthPoints36 - lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints1C2, 0 ) + " [" + DoubleToStr((((lengthPoints36 - lengthPoints1C2) / lengthPoints1C2))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3-3´RRPts: None\n";
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
      handle = FileOpen("MAZigzag_BR_ST_TR"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_tr, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_tr = Time[0];
    lastAlertZigzag_tr = zigzag2;
  }
  // BR_HS
  if(StringLen(alertText_mwhs) > 0 && lastAlert_mwhs != Time[0] && lastAlertZigzag_mwhs != zigzag2) {
    Alert(alertText_mwhs);
    if(MailAlert) {
      mailBody_mwhs = mailBody_mwhs + alertText_mwhs; // ロング or ショート、通貨ペア、時間足
      mailBody_mwhs = mailBody_mwhs + "Price: " + Close[0] + "\n";
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints1C2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      mailBody_mwhs = mailBody_mwhs + "FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_mwhs = mailBody_mwhs + "E3Percent: " + DoubleToStr( lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints1C2 / lengthPoints34) * 100, 1 ) + "%]\n";

      mailBody_mwhs = mailBody_mwhs + "\n";
      if(lengthPoints1C2 < lengthPoints34) {
        mailBody_mwhs = mailBody_mwhs + "3RRPts: " + DoubleToStr( lengthPoints34 - lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints1C2, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints1C2) / lengthPoints1C2))*100, 1 ) + "%]\n";
      } else {
        mailBody_mwhs = mailBody_mwhs + "3RRPts: None\n";
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
      handle = FileOpen("MAZigzag_BR_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_mwhs, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_mwhs = Time[0];
    lastAlertZigzag_mwhs = zigzag2;
  }

  return(0);
}
