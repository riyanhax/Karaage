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

datetime lastAlert = 0;
double lastAlertZigzag;
datetime lastAlert_mwhs = 0;
double lastAlertZigzag_mwhs;
datetime lastAlert_tr = 0;
double lastAlertZigzag_tr;
datetime lastAlert_mw = 0;
double lastAlertZigzag_mw;
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
  double maCurrentEma;
  double maCurrentSma;
  double maCurrentEma2;
  double maCurrentSma2;
  double maCurrentEma3;
  double maCurrentSma3;
  double maCurrentEma4;
  double maCurrentSma4;
  double maMiddleEma;
  double maMiddleSma;
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement;
  string alertText;
  string mailSubject;
  string mailBody;
  string direction;
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
  int requirement_mw;
  string alertText_mw;
  string mailSubject_mw;
  string mailBody_mw;
  string direction_mw;
  int handle;

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
      cnt = 2;
    } else if(cnt == 2 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag3 = zigzagTmp;
      maCurrentSma3 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma3 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      cnt = 3;
    } else if(cnt == 3 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag4 = zigzagTmp;
      maCurrentSma4 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma4 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      cnt = 4;
    } else if(cnt == 4 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag5 = zigzagTmp;
      cnt = 5;
    } else if(cnt == 5 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag6 = zigzagTmp;
      cnt = 6;
    } else if(cnt == 6 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag7 = zigzagTmp;
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
  requirement = 0;
  // Long 切り替わり
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag5 <= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4
      && zigzag4 > zigzag6 && zigzag7 > zigzag8 && zigzag8 < zigzag9
      && zigzag7 <= zigzag9 && zigzag6 <= zigzag8
      && zigzag3 > zigzag7 && zigzag5 < zigzag7) {
    alertText = alertText + "Long_hs_TR " + Symbol() + " " + periodText + "\n";
    alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject = "[Long_hs_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "long_hs_tr";

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
  }
  // Short 切り替わり
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag5 >= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4
      && zigzag4 < zigzag6 && zigzag7 < zigzag8 && zigzag8 > zigzag9
      && zigzag7 >= zigzag9 && zigzag6 >= zigzag8
      && zigzag3 < zigzag7 && zigzag5 > zigzag7) {
    alertText = alertText + "Short_hs_TR " + Symbol() + " " + periodText + "\n";
    alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject = "[Short_hs_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "short_hs_tr";

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
  }

  requirement_mwhs = 0;
  // Long 切り替わり
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag5 <= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4
      && zigzag4 <= zigzag6) {
    alertText_mwhs = alertText_mwhs + "Long_HS " + Symbol() + " " + periodText + "\n";
    alertText_mwhs = alertText_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_mwhs = "[Long_HS] " + Symbol() + " " + periodText + " " + Time[0];
    direction_mwhs = "long_hs";

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
  }
  // Short 切り替わり
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag5 >= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4
      && zigzag4 >= zigzag6) {
    alertText_mwhs = alertText_mwhs + "Short_HS " + Symbol() + " " + periodText + "\n";
    alertText_mwhs = alertText_mwhs + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_mwhs = "[Short_HS] " + Symbol() + " " + periodText + " " + Time[0];
    direction_mwhs = "short_hs";

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
  }

  requirement_tr = 0;
  // Long 切り替わり
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag7 > zigzag8 && zigzag8 < zigzag9
      && zigzag5 >= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4 && zigzag4 >= zigzag6 && zigzag6 <= zigzag8
      && zigzag7 <= zigzag9) {
    alertText_tr = alertText_tr + "Long_HS_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Long_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "long_hs_tr";
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
  }
  // Short 切り替わり
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag7 < zigzag8 && zigzag8 > zigzag9
      && zigzag5 <= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4 && zigzag4 <= zigzag6 && zigzag6 >= zigzag8
      && zigzag7 >= zigzag9) {
    alertText_tr = alertText_tr + "Short_HS_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Short_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "short_hs_tr";
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
  }
  // MW
  requirement_mw = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
    && zigzag5 >= zigzag3 && zigzag2 >= zigzag4) {
    if(zigzag4 < maCurrentSma4 && zigzag4 < maCurrentEma4 && zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3
      && zigzag2 < maCurrentSma2 && zigzag2 < maCurrentEma2 && zigzag1 > maCurrentEma && zigzag1 > maCurrentSma
      && iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 陽線
      && iClose( Symbol(), MATimeframe, 1 ) > maCurrentEma && iClose( Symbol(), MATimeframe, 1 ) > maCurrentSma
      && zigzag1 != iHigh( Symbol(), MATimeframe, 0 ) ) {

      alertText_mw = alertText_mw + "Long_MW " + Symbol() + " " + periodText + "\n";
      alertText_mw = alertText_mw + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailSubject_mw = "[Long_MW] " + Symbol() + " " + periodText + " " + Time[0];
      direction_mw = "long_mw";

      if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
        alertText_mw = alertText_mw + "①ALL EMA: Golden Cross" + "\n";
      }
      if(maMiddleEma < maCurrentEma) {
        requirement_mw++;
        alertText_mw = alertText_mw + "②EMA: Golden Cross" + "\n";
      }
      if(maCurrentSma < maCurrentEma) {
        requirement_mw++;
        alertText_mw = alertText_mw + "③Short MA: Golden Cross" + "\n";
      }
      if(maMiddleSma < maMiddleEma) {
        requirement_mw++;
        alertText_mw = alertText_mw + "④Middle MA: Golden Cross" + "\n";
      }
      if(maLongSma < maLongEma) {
        alertText_mw = alertText_mw + "⑤Long MA: Golden Cross" + "\n";
      }
    }
  }
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
    && zigzag5 <= zigzag3 && zigzag2 <= zigzag4) {
    if(zigzag4 > maCurrentSma4 && zigzag4 > maCurrentEma4 && zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3
      && zigzag2 > maCurrentSma2 && zigzag2 > maCurrentEma2 && zigzag1 < maCurrentEma && zigzag1 < maCurrentSma
      && iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 陰線
      && iClose( Symbol(), MATimeframe, 1 ) < maCurrentEma && iClose( Symbol(), MATimeframe, 1 ) < maCurrentSma
      && zigzag1 != iLow( Symbol(), MATimeframe, 0 ) ) {

      alertText_mw = alertText_mw + "Short_MW " + Symbol() + " " + periodText + "\n";
      alertText_mw = alertText_mw + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailSubject_mw = "[Short_MW] " + Symbol() + " " + periodText + " " + Time[0];
      direction_mw = "short_mw";

      if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
        alertText_mw = alertText_mw + "①ALL EMA: Dead Cross" + "\n";
      }
      if(maMiddleEma > maCurrentEma) {
        requirement_mw++;
        alertText_mw = alertText_mw + "②EMA: Dead Cross" + "\n";
      }
      if(maCurrentSma > maCurrentEma) {
        requirement_mw++;
        alertText_mw = alertText_mw + "③Short MA: Dead Cross" + "\n";
      }
      if(maMiddleSma > maMiddleEma) {
        requirement_mw++;
        alertText_mw = alertText_mw + "④Middle MA: Dead Cross" + "\n";
      }
      if(maLongSma > maLongEma) {
        alertText_mw = alertText_mw + "⑤Long MA: Dead Cross" + "\n";
      }
    }
  }

  // 条件を満たした数によってアラート
  // HS_TR
  if(StringLen(alertText) > 0 && requirement >= AlertRequirementCount && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    Alert(alertText);
    if(MailAlert) {
      mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Price: " + Close[0] + "\n";
      double lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      double lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      double lengthPoints14 = MathAbs( zigzag1 - zigzag4 ) / Point();
      double lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      double lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints36 = MathAbs( zigzag3 - zigzag6 ) / Point();
      double lengthPoints45 = MathAbs( zigzag4 - zigzag5 ) / Point();
      double lengthPoints56 = MathAbs( zigzag5 - zigzag6 ) / Point();
      mailBody = mailBody + "3-1´FiboPts: " + DoubleToStr( lengthPoints45, 0 ) + " / " + DoubleToStr( lengthPoints56, 0 ) + " [" + DoubleToStr( (lengthPoints45 / lengthPoints56) * 100, 1 ) + "%]\n";
      mailBody = mailBody + "3-3 FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody = mailBody + "3-3´FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints36, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints36) * 100, 1 ) + "%]\n";
      // mailBody = mailBody + "E3Percent: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints34) * 100, 1 ) + "%]\n";

      mailBody = mailBody + "\n";
      if(lengthPoints12 < lengthPoints23) {
        mailBody = mailBody + "55RRPts: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( (lengthPoints13 / lengthPoints12) * 100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "5RRPts: None\n";
      }
      if(lengthPoints14 < lengthPoints56) {
        mailBody = mailBody + "3-1´RRPts: " + DoubleToStr( lengthPoints56 - lengthPoints14, 0 ) + " / " + DoubleToStr( lengthPoints14, 0 ) + " [" + DoubleToStr((((lengthPoints56 - lengthPoints14) / lengthPoints14))*100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "3-1´RRPts: None\n";
      }
      if(lengthPoints12 < lengthPoints34) {
        mailBody = mailBody + "3-3 RRPts: " + DoubleToStr( lengthPoints34 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "3-3 RRPts: None\n";
      }
      if(lengthPoints12 < lengthPoints36) {
        mailBody = mailBody + "3-3´RRPts: " + DoubleToStr( lengthPoints36 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints36 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "3-3´RRPts: None\n";
      }
      // mailBody = mailBody + "SWPoint: " + DoubleToStr((zigzag7 - zigzag6)/Point, 0) + ", " + DoubleToStr((zigzag6 - zigzag5)/Point, 0) + ", " + DoubleToStr((zigzag5 - zigzag4)/Point, 0) + "\n";

      mailBody = mailBody + "\n";
      mailBody = mailBody + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody = mailBody + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody = mailBody + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject, mailBody );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzagTrendSwitch_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert = Time[0];
    lastAlertZigzag = zigzag2;
  }
  // MW_HS
  if(StringLen(alertText_mwhs) > 0 && requirement_mwhs >= AlertRequirementCount && lastAlert_mwhs != Time[0] && lastAlertZigzag_mwhs != zigzag2) {
    Alert(alertText_mwhs);
    if(MailAlert) {
      mailBody_mwhs = mailBody_mwhs + alertText_mwhs; // ロング or ショート、通貨ペア、時間足
      mailBody_mwhs = mailBody_mwhs + "Price: " + Close[0] + "\n";

      double lengthPoints12_mwhs = MathAbs( zigzag1 - zigzag2 ) / Point();
      double lengthPoints13_mwhs = MathAbs( zigzag1 - zigzag3 ) / Point();
      double lengthPoints23_mwhs = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34_mwhs = MathAbs( zigzag3 - zigzag4 ) / Point();
      mailBody_mwhs = mailBody_mwhs + "FiboPoints: " + DoubleToStr( lengthPoints23_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints34_mwhs, 0 ) + " [" + DoubleToStr( (lengthPoints23_mwhs / lengthPoints34_mwhs) * 100, 1 ) + "%]\n";
      mailBody_mwhs = mailBody_mwhs + "E3Percent: " + DoubleToStr( lengthPoints12_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints34_mwhs, 0 ) + " [" + DoubleToStr( (lengthPoints12_mwhs / lengthPoints34_mwhs) * 100, 1 ) + "%]\n";
      if(lengthPoints12_mwhs < lengthPoints23_mwhs) {
        mailBody_mwhs = mailBody_mwhs + "5RRPoints: " + DoubleToStr( lengthPoints13_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints12_mwhs, 0 ) + " [" + DoubleToStr( (lengthPoints13_mwhs / lengthPoints12_mwhs) * 100, 1 ) + "%]\n";
      } else {
        mailBody_mwhs = mailBody_mwhs + "5RRPoints: None\n";
      }
      if(lengthPoints12_mwhs < lengthPoints34_mwhs) {
        mailBody_mwhs = mailBody_mwhs + "3RRPoints: " + DoubleToStr( lengthPoints34_mwhs - lengthPoints12_mwhs, 0 ) + " / " + DoubleToStr( lengthPoints12_mwhs, 0 ) + " [" + DoubleToStr((((lengthPoints34_mwhs - lengthPoints12_mwhs) / lengthPoints12_mwhs))*100, 1 ) + "%]\n";
      } else {
        mailBody_mwhs = mailBody_mwhs + "3RRPoints: None\n";
      }
      mailBody_mwhs = mailBody_mwhs + "SWPoint: " + DoubleToStr((zigzag7 - zigzag6)/Point, 0) + ", " + DoubleToStr((zigzag6 - zigzag5)/Point, 0) + ", " + DoubleToStr((zigzag5 - zigzag4)/Point, 0) + "\n";

      mailBody_mwhs = mailBody_mwhs + "\n";
      mailBody_mwhs = mailBody_mwhs + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_mwhs = mailBody_mwhs + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_mwhs = mailBody_mwhs + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_mwhs, mailBody_mwhs );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzagTrendSwitch_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_mwhs = Time[0];
    lastAlertZigzag_mwhs = zigzag2;
  }
  // MW_HS_TR
  if(StringLen(alertText_tr) > 0 && requirement_tr >= AlertRequirementCount && lastAlert_tr != Time[0] && lastAlertZigzag_tr != zigzag2) {
    Alert(alertText_tr);
    if(MailAlert) {
      mailBody_tr = mailBody_tr + alertText_tr; // ロング or ショート、通貨ペア、時間足
      mailBody_tr = mailBody_tr + "Price: " + Close[0] + "\n";
      double lengthPoints12_tr = MathAbs( zigzag1 - zigzag2 ) / Point();
      double lengthPoints13_tr = MathAbs( zigzag1 - zigzag3 ) / Point();
      double lengthPoints14_tr = MathAbs( zigzag1 - zigzag4 ) / Point();
      double lengthPoints23_tr = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34_tr = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints36_tr = MathAbs( zigzag3 - zigzag6 ) / Point();
      double lengthPoints45_tr = MathAbs( zigzag4 - zigzag5 ) / Point();
      double lengthPoints56_tr = MathAbs( zigzag5 - zigzag6 ) / Point();
      mailBody_tr = mailBody_tr + "3-1´FiboPts: " + DoubleToStr( lengthPoints45_tr, 0 ) + " / " + DoubleToStr( lengthPoints56_tr, 0 ) + " [" + DoubleToStr( (lengthPoints45_tr / lengthPoints56_tr) * 100, 1 ) + "%]\n";
      mailBody_tr = mailBody_tr + "3-3 FiboPts: " + DoubleToStr( lengthPoints23_tr, 0 ) + " / " + DoubleToStr( lengthPoints34_tr, 0 ) + " [" + DoubleToStr( (lengthPoints23_tr / lengthPoints34_tr) * 100, 1 ) + "%]\n";
      mailBody_tr = mailBody_tr + "3-3´FiboPts: " + DoubleToStr( lengthPoints23_tr, 0 ) + " / " + DoubleToStr( lengthPoints36_tr, 0 ) + " [" + DoubleToStr( (lengthPoints23_tr / lengthPoints36_tr) * 100, 1 ) + "%]\n";
      // mailBody_tr = mailBody_tr + "E3Percent: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints34) * 100, 1 ) + "%]\n";

      mailBody_tr = mailBody_tr + "\n";
      if(lengthPoints12_tr < lengthPoints23_tr) {
        mailBody_tr = mailBody_tr + "5RRPoints: " + DoubleToStr( lengthPoints13_tr, 0 ) + " / " + DoubleToStr( lengthPoints12_tr, 0 ) + " [" + DoubleToStr( (lengthPoints13_tr / lengthPoints12_tr) * 100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "5RRPoints: None\n";
      }
      if(lengthPoints14_tr < lengthPoints56_tr) {
        mailBody_tr = mailBody_tr + "3-1´RRPts: " + DoubleToStr( lengthPoints56_tr - lengthPoints14_tr, 0 ) + " / " + DoubleToStr( lengthPoints14_tr, 0 ) + " [" + DoubleToStr((((lengthPoints56_tr - lengthPoints14_tr) / lengthPoints14_tr))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3-1´RRPts: None\n";
      }
      if(lengthPoints12_tr < lengthPoints34_tr) {
        mailBody_tr = mailBody_tr + "3-3 RRPts: " + DoubleToStr( lengthPoints34_tr - lengthPoints12_tr, 0 ) + " / " + DoubleToStr( lengthPoints12_tr, 0 ) + " [" + DoubleToStr((((lengthPoints34_tr - lengthPoints12_tr) / lengthPoints12_tr))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3-3 RRPts: None\n";
      }
      if(lengthPoints12_tr < lengthPoints36_tr) {
        mailBody_tr = mailBody_tr + "3-3´RRPts: " + DoubleToStr( lengthPoints36_tr - lengthPoints12_tr, 0 ) + " / " + DoubleToStr( lengthPoints12_tr, 0 ) + " [" + DoubleToStr((((lengthPoints36_tr - lengthPoints12_tr) / lengthPoints12_tr))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3-3´RRPts: None\n";
      }

      // mailBody = mailBody + "SWPoint: " + DoubleToStr((zigzag9 - zigzag8)/Point, 0) + ", " + DoubleToStr((zigzag8 - zigzag7)/Point, 0) + ", " + DoubleToStr((zigzag7 - zigzag6)/Point, 0) + "\n";
      mailBody_tr = mailBody_tr + "\n";
      mailBody_tr = mailBody_tr + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_tr = mailBody_tr + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_tr = mailBody_tr + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_tr, mailBody_tr );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzagTrendSwitch_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_tr, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_tr = Time[0];
    lastAlertZigzag_tr = zigzag2;
  }
  // MW
  if(StringLen( alertText_mw ) > 0 && lastAlert_mw != Time[0] && lastAlertZigzag_mw != zigzag2) {
    Alert(alertText_mw);
    if(MailAlert) {
      mailBody_mw = mailBody_mw + alertText_mw; // ロング or ショート、通貨ペア、時間足
      mailBody_mw = mailBody_mw + "Price: " + Close[0] + "\n";
      double lengthPoints23_mw = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34_mw = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints1C2_mw = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      double lengthPoints1C3_mw = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      double lengthPoints1C4_mw = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag4 ) / Point();

      mailBody_mw = mailBody_mw + "FiboPts: " + DoubleToStr( lengthPoints23_mw, 0 ) + " / " + DoubleToStr( lengthPoints34_mw, 0 ) + " [" + DoubleToStr( (lengthPoints23_mw / lengthPoints34_mw) * 100, 1 ) + "%]\n";
      mailBody_mw = mailBody_mw + "E3Percent: " + DoubleToStr( lengthPoints1C2_mw, 0 ) + " / " + DoubleToStr( lengthPoints34_mw, 0 ) + " [" + DoubleToStr( (lengthPoints1C2_mw / lengthPoints34_mw) * 100, 1 ) + "%]\n";

      mailBody_mw = mailBody_mw + "\n";
      if(lengthPoints1C2_mw < lengthPoints23_mw) {
        mailBody_mw = mailBody_mw + "5RRPts: " + DoubleToStr( lengthPoints1C3_mw, 0 ) + " / " + DoubleToStr( lengthPoints1C2_mw, 0 ) + " [" + DoubleToStr( (lengthPoints1C3_mw / lengthPoints1C2_mw) * 100, 1 ) + "%]\n";
      } else {
        mailBody_mw = mailBody_mw + "5RRPts: None\n";
      }
      if(lengthPoints1C2_mw < lengthPoints34_mw) {
        mailBody_mw = mailBody_mw + "3RRPts: " + DoubleToStr( lengthPoints34_mw - lengthPoints1C2_mw, 0 ) + " / " + DoubleToStr( lengthPoints1C2_mw, 0 ) + " [" + DoubleToStr((((lengthPoints34_mw - lengthPoints1C2_mw) / lengthPoints1C2_mw))*100, 1 ) + "%]\n";
      } else {
        mailBody_mw = mailBody_mw + "3RRPts: None\n";
      }

      mailBody_mw = mailBody_mw + "\n";
      if(lengthPoints1C2_mw < lengthPoints34_mw) {
        mailBody_mw = mailBody_mw + "MWRRPts: " + DoubleToStr( lengthPoints34_mw - lengthPoints1C2_mw, 0 ) + " / " + DoubleToStr( lengthPoints1C4_mw, 0 ) + " [" + DoubleToStr((((lengthPoints34_mw - lengthPoints1C2_mw) / lengthPoints1C4_mw))*100, 1 ) + "%]\n";
      } else {
        mailBody_mw = mailBody_mw + "MWRRPts: None\n";
      }

      mailBody_mw = mailBody_mw + "\n";
      mailBody_mw = mailBody_mw + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_mw = mailBody_mw + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_mw = mailBody_mw + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_mw, mailBody_mw );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_YK_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_mw, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_mw = Time[0];
    lastAlertZigzag_mw = zigzag2;
  }

  return(0);
}
