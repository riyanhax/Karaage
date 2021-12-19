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

datetime lastAlert_tr = 0;
double lastAlertZigzag_tr;
datetime lastAlert = 0;
double lastAlertZigzag;
double sttrLongFlg = 0;
double sttrShortFlg = 0;
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
  double macd2;
  double macd3;
  double macd4;
  double macd5;
  double rsi2;
  double rsi3;
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
  double maMiddleEma2;
  double maMiddleSma2;
  double maMiddleEma3;
  double maMiddleSma3;
  double maMiddleEma4;
  double maMiddleSma4;
  double maLongEma;
  double maLongSma;
  double maLongEma2;
  double maLongSma2;
  double maLongEma3;
  double maLongSma3;
  double maLongEma4;
  double maLongSma4;
  int i;
  int cnt;
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
  double lengthPoints13;
  double lengthPoints14;
  double lengthPoints23;
  double lengthPoints34;
  double lengthPoints36;
  double lengthPoints45;
  double lengthPoints56;
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
      macd2 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      rsi2 = iRSI( Symbol(), ZigzagTimeframe, 20, PRICE_CLOSE, i );
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
      rsi3 = iRSI( Symbol(), ZigzagTimeframe, 20, PRICE_CLOSE, i );
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
      macd5 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 5;
    } else if(cnt == 5 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag6 = zigzagTmp;
      cnt = 6;
      break;
    }
  }

  // 条件
  requirement_tr = 0;
  // Long_TR
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
    && zigzag3 > zigzag5 && zigzag2 >= zigzag5 && zigzag4 >= zigzag6 && zigzag2 >= zigzag4) {
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(zigzag3 >= maCurrentSma3 && zigzag3 >= maCurrentEma3
      && zigzag2 <= maCurrentSma2 && zigzag2 <= maCurrentEma2
      && zigzag1 >= maCurrentSma && zigzag1 >= maCurrentEma ) {
      return(0);
    }

    alertText_tr = alertText_tr + "Long_ST_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Long_ST_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "long_st_tr";
    sttrLongFlg = zigzag2;

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
      macdRsi = "Div: Long";
    } else {
      macdRsi = "Div: Short";
    }

  }
  // Short_TR
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
    && zigzag3 < zigzag5 && zigzag2 <= zigzag5 && zigzag4 <= zigzag6 && zigzag2 <= zigzag4) {

    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(zigzag3 <= maCurrentSma3 && zigzag3 <= maCurrentEma3
      && zigzag2 >= maCurrentSma2 && zigzag2 >= maCurrentEma2
      && zigzag1 <= maCurrentSma && zigzag1 <= maCurrentEma ) {
      return(0);
    }

    alertText_tr = alertText_tr + "Short_ST_TR " + Symbol() + " " + periodText + "\n";
    alertText_tr = alertText_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
    mailSubject_tr = "[Short_ST_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "short_st_tr";
    sttrShortFlg = zigzag2;


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
      macdRsi = "Div: Long";
    } else {
      macdRsi = "Div: Short";
    }
  }

  requirement = 0;
  // Long_ST_TR_sml
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
    && zigzag2 >= zigzag4 && zigzag3 >= zigzag5 && zigzag4 >= zigzag6) {

    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(zigzag4 < maCurrentSma4 && zigzag4 < maCurrentEma4 && zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3
      && zigzag2 < maCurrentSma2 && zigzag2 < maCurrentEma2 && zigzag1 > maCurrentEma && zigzag1 > maCurrentSma
      && iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 陽線
      && iClose( Symbol(), MATimeframe, 1 ) > maCurrentEma && iClose( Symbol(), MATimeframe, 1 ) > maCurrentSma
      && zigzag1 != iHigh( Symbol(), MATimeframe, 0 ) ) {

      if(zigzag4 < maMiddleSma4 && zigzag4 < maMiddleEma4 && zigzag3 > maMiddleSma3 && zigzag3 > maMiddleEma3
        && zigzag2 < maMiddleSma2 && zigzag2 < maMiddleEma2 && zigzag1 > maMiddleSma && zigzag1 > maMiddleEma) {

        if(zigzag4 < maLongSma4 && zigzag4 < maLongEma4 && zigzag3 > maLongSma3 && zigzag3 > maLongEma3
          && zigzag2 < maLongSma2 && zigzag2 < maLongEma2 && zigzag1 > maLongSma && zigzag1 > maLongEma) {
          alertText = alertText + "Long_ST_TR_l " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Long_ST_TR_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "long_st_tr_l";
        } else {
          alertText = alertText + "Long_ST_TR_m " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Long_ST_TR_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "long_st_tr_m";
        }

      } else {
        alertText = alertText + "Long_ST_TR_s " + Symbol() + " " + periodText + "\n";
        alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject = "[Long_ST_TR_s] " + Symbol() + " " + periodText + " " + Time[0];
        direction = "long_st_tr_s";
      }

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
  }
  // Short_ST_TR_sml
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
    && zigzag2 <= zigzag4 && zigzag3 <= zigzag5 && zigzag4 <= zigzag6) {

    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(zigzag4 > maCurrentSma4 && zigzag4 > maCurrentEma4 && zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3
      && zigzag2 > maCurrentSma2 && zigzag2 > maCurrentEma2 && zigzag1 < maCurrentEma && zigzag1 < maCurrentSma
      && iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 陰線
      && iClose( Symbol(), MATimeframe, 1 ) < maCurrentEma && iClose( Symbol(), MATimeframe, 1 ) < maCurrentSma
      && zigzag1 != iLow( Symbol(), MATimeframe, 0 ) ) {

      if(zigzag4 > maMiddleSma4 && zigzag4 > maMiddleEma4 && zigzag3 < maMiddleSma3 && zigzag3 < maMiddleEma3
        && zigzag2 > maMiddleSma2 && zigzag2 > maMiddleEma2 && zigzag1 < maMiddleSma && zigzag1 < maMiddleEma) {

        if(zigzag4 > maLongSma4 && zigzag4 > maLongEma4 && zigzag3 < maLongSma3 && zigzag3 < maLongEma3
          && zigzag2 > maLongSma2 && zigzag2 > maLongEma2 && zigzag1 < maLongSma && zigzag1 < maLongEma) {
          alertText = alertText + "Short_ST_TR_l " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Short_ST_TR_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "short_st_tr_l";
        } else {
          alertText = alertText + "Short_ST_TR_m " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Short_ST_TR_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "short_st_tr_m";
        }

      } else {
        alertText = alertText + "Short_ST_TR_s " + Symbol() + " " + periodText + "\n";
        alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject = "[Short_ST_TR_s] " + Symbol() + " " + periodText + " " + Time[0];
        direction = "short_st_tr_s";
      }

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
  }

  // 条件を満たした数によってアラート
  // ST_TR
  if(StringLen(alertText_tr) > 0 && requirement_tr >= AlertRequirementCount && lastAlert_tr != Time[0] && lastAlertZigzag_tr != zigzag2) {
    Alert(alertText_tr);
    if(MailAlert) {
      mailBody_tr = mailBody_tr + alertText_tr; // ロング or ショート、通貨ペア、時間足
      mailBody_tr = mailBody_tr + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints14 = MathAbs( zigzag1 - zigzag4 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints36 = MathAbs( zigzag3 - zigzag6 ) / Point();
      lengthPoints45 = MathAbs( zigzag4 - zigzag5 ) / Point();
      lengthPoints56 = MathAbs( zigzag5 - zigzag6 ) / Point();
      mailBody_tr = mailBody_tr + "3-1´FiboPts: " + DoubleToStr( lengthPoints45, 0 ) + " / " + DoubleToStr( lengthPoints56, 0 ) + " [" + DoubleToStr( (lengthPoints45 / lengthPoints56) * 100, 1 ) + "%]\n";
      mailBody_tr = mailBody_tr + "3-3 FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_tr = mailBody_tr + "3-3´FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints36, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints36) * 100, 1 ) + "%]\n";

      mailBody_tr = mailBody_tr + "\n";
      if(lengthPoints12 < lengthPoints23) {
        mailBody_tr = mailBody_tr + "5RRPts: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( (lengthPoints13 / lengthPoints12) * 100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "5RRPts: None\n";
      }
      if(lengthPoints14 < lengthPoints56) {
        mailBody_tr = mailBody_tr + "3-1´RRPts: " + DoubleToStr( lengthPoints56 - lengthPoints14, 0 ) + " / " + DoubleToStr( lengthPoints14, 0 ) + " [" + DoubleToStr((((lengthPoints56 - lengthPoints14) / lengthPoints14))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3-1´RRPts: None\n";
      }
      if(lengthPoints12 < lengthPoints34) {
        mailBody_tr = mailBody_tr + "3-3 RRPts: " + DoubleToStr( lengthPoints34 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3-3 RRPts: None\n";
      }
      if(lengthPoints12 < lengthPoints36) {
        mailBody_tr = mailBody_tr + "3-3´RRPts: " + DoubleToStr( lengthPoints36 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints36 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
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
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_tr, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_tr = Time[0];
    lastAlertZigzag_tr = zigzag2;
  }
  // ST_TR_sml
  if(StringLen(alertText) > 0 && requirement >= AlertRequirementCount && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    Alert(alertText);
    if(MailAlert) {
      mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints14 = MathAbs( zigzag1 - zigzag4 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints36 = MathAbs( zigzag3 - zigzag6 ) / Point();
      lengthPoints45 = MathAbs( zigzag4 - zigzag5 ) / Point();
      lengthPoints56 = MathAbs( zigzag5 - zigzag6 ) / Point();
      mailBody = mailBody + "3-1´FiboPts: " + DoubleToStr( lengthPoints45, 0 ) + " / " + DoubleToStr( lengthPoints56, 0 ) + " [" + DoubleToStr( (lengthPoints45 / lengthPoints56) * 100, 1 ) + "%]\n";
      mailBody = mailBody + "3-3 FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody = mailBody + "3-3´FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints36, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints36) * 100, 1 ) + "%]\n";

      mailBody = mailBody + "\n";
      if(lengthPoints12 < lengthPoints23) {
        mailBody = mailBody + "5RRPts: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( (lengthPoints13 / lengthPoints12) * 100, 1 ) + "%]\n";
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
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert = Time[0];
    lastAlertZigzag = zigzag2;
  }

  return(0);
}
