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

datetime lastAlert_yk = 0;
double lastAlertZigzag_yk;
datetime lastAlert_yks = 0;
double lastAlertZigzag_yks;
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
  int requirement_yk;
  string alertText_yk;
  string mailSubject_yk;
  string mailBody_yk;
  string direction_yk;
  int requirement_yks;
  string alertText_yks;
  string mailSubject_yks;
  string mailBody_yks;
  string direction_yks;
  int requirement;
  string alertText;
  string mailSubject;
  string mailBody;
  string direction;
  int handle;
  double lengthPoints12;
  double lengthPoints13;
  double lengthPoints23;
  double lengthPoints34;
  double lengthPoints1C2;
  double lengthPoints1C3;
  double lengthPointsC1;
  double lengthPointsC2;

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
      cnt = 3;
    } else if(cnt == 3 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag4 = zigzagTmp;
      maCurrentSma4 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma4 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma4 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma4 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma4 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma4 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      cnt = 4;
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
  // YK
  requirement_yk = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag2 >= zigzag4) {
    if(zigzag4 < maCurrentSma4 && zigzag4 < maCurrentEma4 && zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3
      && zigzag2 < maCurrentSma2 && zigzag2 < maCurrentEma2 && zigzag1 > maCurrentSma && zigzag1 > maCurrentEma) {

      alertText_yk = alertText_yk + "Long_YK " + Symbol() + " " + periodText + "\n";
      alertText_yk = alertText_yk + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailSubject_yk = "[Long_YK] " + Symbol() + " " + periodText + " " + Time[0];
      direction_yk = "long_yk";

      if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
        alertText_yk = alertText_yk + "①ALL EMA: Golden Cross" + "\n";
      }
      if(maMiddleEma < maCurrentEma) {
        requirement_yk++;
        alertText_yk = alertText_yk + "②EMA: Golden Cross" + "\n";
      }
      if(maCurrentSma < maCurrentEma) {
        requirement_yk++;
        alertText_yk = alertText_yk + "③Short MA: Golden Cross" + "\n";
      }
      if(maMiddleSma < maMiddleEma) {
        requirement_yk++;
        alertText_yk = alertText_yk + "④Middle MA: Golden Cross" + "\n";
      }
      if(maLongSma < maLongEma) {
        alertText_yk = alertText_yk + "⑤Long MA: Golden Cross" + "\n";
      }
    }
  }
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag2 <= zigzag4) {
    if(zigzag4 > maCurrentSma4 && zigzag4 > maCurrentEma4 && zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3
      && zigzag2 > maCurrentSma2 && zigzag2 > maCurrentEma2 && zigzag1 < maCurrentSma && zigzag1 < maCurrentEma) {

      alertText_yk = alertText_yk + "Short_YK " + Symbol() + " " + periodText + "\n";
      alertText_yk = alertText_yk + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailSubject_yk = "[Short_YK] " + Symbol() + " " + periodText + " " + Time[0];
      direction_yk = "short_yk";

      if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
        alertText_yk = alertText_yk + "①ALL EMA: Dead Cross" + "\n";
      }
      if(maMiddleEma > maCurrentEma) {
        requirement_yk++;
        alertText_yk = alertText_yk + "②EMA: Dead Cross" + "\n";
      }
      if(maCurrentSma > maCurrentEma) {
        requirement_yk++;
        alertText_yk = alertText_yk + "③Short MA: Dead Cross" + "\n";
      }
      if(maMiddleSma > maMiddleEma) {
        requirement_yk++;
        alertText_yk = alertText_yk + "④Middle MA: Dead Cross" + "\n";
      }
      if(maLongSma > maLongEma) {
        alertText_yk = alertText_yk + "⑤Long MA: Dead Cross" + "\n";
      }
    }
  }
  // YK_s
  requirement_yks = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag2 >= zigzag4) {
    if(zigzag4 < maCurrentSma4 && zigzag4 < maCurrentEma4 && zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3
      && zigzag2 < maCurrentSma2 && zigzag2 < maCurrentEma2 && zigzag1 > maCurrentEma
      && iClose( Symbol(), MATimeframe, 1 ) > maCurrentEma && iClose( Symbol(), MATimeframe, 1 ) > maCurrentSma) {

      if(zigzag4 < maMiddleSma4 && zigzag4 < maMiddleEma4 && zigzag3 > maMiddleSma3 && zigzag3 > maMiddleEma3
        && zigzag2 < maMiddleSma2 && zigzag2 < maMiddleEma2 && zigzag1 > maMiddleSma && zigzag1 > maMiddleEma) {

        if(zigzag4 < maLongSma4 && zigzag4 < maLongEma4 && zigzag3 > maLongSma3 && zigzag3 > maLongEma3
          && zigzag2 < maLongSma2 && zigzag2 < maLongEma2 && zigzag1 > maLongSma && zigzag1 > maLongEma) {
          alertText_yks = alertText_yks + "Long_YK_l " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Long_YK_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "long_yk_l";
        } else {
          alertText_yks = alertText_yks + "Long_YK_m " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Long_YK_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "long_yk_m";
        }

      } else {
        alertText_yks = alertText_yks + "Long_YK_s " + Symbol() + " " + periodText + "\n";
        alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject_yks = "[Long_YK_s] " + Symbol() + " " + periodText + " " + Time[0];
        direction_yks = "long_yk_s";
      }

      if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
        alertText_yks = alertText_yks + "①ALL EMA: Golden Cross" + "\n";
      }
      if(maMiddleEma < maCurrentEma) {
        requirement_yks++;
        alertText_yks = alertText_yks + "②EMA: Golden Cross" + "\n";
      }
      if(maCurrentSma < maCurrentEma) {
        requirement_yks++;
        alertText_yks = alertText_yks + "③Short MA: Golden Cross" + "\n";
      }
      if(maMiddleSma < maMiddleEma) {
        requirement_yks++;
        alertText_yks = alertText_yks + "④Middle MA: Golden Cross" + "\n";
      }
      if(maLongSma < maLongEma) {
        alertText_yks = alertText_yks + "⑤Long MA: Golden Cross" + "\n";
      }
    }
  }
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag2 <= zigzag4) {
    if(zigzag4 > maCurrentSma4 && zigzag4 > maCurrentEma4 && zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3
      && zigzag2 > maCurrentSma2 && zigzag2 > maCurrentEma2 && zigzag1 < maCurrentEma
      && iClose( Symbol(), MATimeframe, 1 ) < maCurrentEma && iClose( Symbol(), MATimeframe, 1 ) < maCurrentSma) {

      if(zigzag4 > maMiddleSma4 && zigzag4 > maMiddleEma4 && zigzag3 < maMiddleSma3 && zigzag3 < maMiddleEma3
        && zigzag2 > maMiddleSma2 && zigzag2 > maMiddleEma2 && zigzag1 < maMiddleSma && zigzag1 < maMiddleEma) {

        if(zigzag4 > maLongSma4 && zigzag4 > maLongEma4 && zigzag3 < maLongSma3 && zigzag3 < maLongEma3
          && zigzag2 > maLongSma2 && zigzag2 > maLongEma2 && zigzag1 < maLongSma && zigzag1 < maLongEma) {
          alertText_yks = alertText_yks + "Long_YK_l " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Long_YK_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "long_yk_l";
        } else {
          alertText_yks = alertText_yks + "Long_YK_m " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Long_YK_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "long_yk_m";
        }

      } else {
        alertText_yks = alertText_yks + "Long_YK_s " + Symbol() + " " + periodText + "\n";
        alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject_yks = "[Long_YK_s] " + Symbol() + " " + periodText + " " + Time[0];
        direction_yks = "long_yk_s";
      }

      if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
        alertText_yks = alertText_yks + "①ALL EMA: Dead Cross" + "\n";
      }
      if(maMiddleEma > maCurrentEma) {
        requirement_yks++;
        alertText_yks = alertText_yks + "②EMA: Dead Cross" + "\n";
      }
      if(maCurrentSma > maCurrentEma) {
        requirement_yks++;
        alertText_yks = alertText_yks + "③Short MA: Dead Cross" + "\n";
      }
      if(maMiddleSma > maMiddleEma) {
        requirement_yks++;
        alertText_yks = alertText_yks + "④Middle MA: Dead Cross" + "\n";
      }
      if(maLongSma > maLongEma) {
        alertText_yks = alertText_yks + "⑤Long MA: Dead Cross" + "\n";
      }
    }
  }
  // YK_S、YK_M
  requirement = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3
    && zigzag1 >= zigzag3) {
    if(zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3 && zigzag2 > maCurrentSma2 && zigzag2 > maCurrentEma2
      && zigzag1 < maCurrentSma && zigzag1 < maCurrentEma
      && iClose( Symbol(), MATimeframe, 1 ) > maCurrentSma && iClose( Symbol(), MATimeframe, 1 ) > maCurrentEma) {

      if(zigzag3 < maMiddleSma3 && zigzag3 < maMiddleEma3 && zigzag2 > maMiddleSma2 && zigzag2 > maMiddleEma2
        && zigzag1 < maMiddleSma && zigzag1 < maMiddleEma) {
        alertText = alertText + "Long_YK_M " + Symbol() + " " + periodText + "\n";
        alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject = "[Long_YK_M] " + Symbol() + " " + periodText + " " + Time[0];
        direction = "long_yk_m";
      } else {
        alertText = alertText + "Long_YK_S " + Symbol() + " " + periodText + "\n";
        alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject = "[Long_YK_S] " + Symbol() + " " + periodText + " " + Time[0];
        direction = "long_yk_s";
      }

      if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
        alertText = alertText + "①ALL EMA: Golden Cross" + "\n";
      }
      if(maMiddleEma < maCurrentEma) {
        alertText = alertText + "②EMA: Golden Cross" + "\n";
      }
      if(maCurrentSma < maCurrentEma) {
        requirement++;
        alertText = alertText + "③Short MA: Golden Cross" + "\n";
      }
      if(maMiddleSma < maMiddleEma) {
        alertText = alertText + "④Middle MA: Golden Cross" + "\n";
      }
      if(maLongSma < maLongEma) {
        alertText = alertText + "⑤Long MA: Golden Cross" + "\n";
      }
    }
  }
  // Short
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3
    && zigzag1 <= zigzag3) {
    if(zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3 && zigzag2 < maCurrentSma2 && zigzag2 < maCurrentEma2
      && zigzag1 > maCurrentSma && zigzag1 > maCurrentEma
      && iClose( Symbol(), MATimeframe, 1 ) < maCurrentSma && iClose( Symbol(), MATimeframe, 1 ) < maCurrentEma) {

      if(zigzag3 > maMiddleSma3 && zigzag3 > maMiddleEma3 && zigzag2 < maMiddleSma2 && zigzag2 < maMiddleEma2
        && zigzag1 > maMiddleSma && zigzag1 > maMiddleEma) {
        alertText = alertText + "Short_YK_M " + Symbol() + " " + periodText + "\n";
        alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject = "[Short_YK_M] " + Symbol() + " " + periodText + " " + Time[0];
        direction = "short_yk_m";
      } else {
        alertText = alertText + "Short_YK_S " + Symbol() + " " + periodText + "\n";
        alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailSubject = "[Short_YK_S] " + Symbol() + " " + periodText + " " + Time[0];
        direction = "short_yk_s";
      }

      if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
        alertText = alertText + "①ALL EMA: Dead Cross" + "\n";
      }
      if(maMiddleEma > maCurrentEma) {
        alertText = alertText + "②EMA: Dead Cross" + "\n";
      }
      if(maCurrentSma > maCurrentEma) {
        requirement++;
        alertText = alertText + "③Short MA: Dead Cross" + "\n";
      }
      if(maMiddleSma > maMiddleEma) {
        alertText = alertText + "④Middle MA: Dead Cross" + "\n";
      }
      if(maLongSma > maLongEma) {
        alertText = alertText + "⑤Long MA: Dead Cross" + "\n";
      }
    }
  }

  // 条件を満たした数によってアラート
  // YK
  if(requirement_yk >= AlertRequirementCount && lastAlert_yk != Time[0] && lastAlertZigzag_yk != zigzag2) {
    Alert(alertText_yk);
    if(MailAlert) {
      mailBody_yk = mailBody_yk + alertText_yk; // ロング or ショート、通貨ペア、時間足
      mailBody_yk = mailBody_yk + "Price: " + Close[0] + "\n";
      //mailBody = mailBody + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      mailBody_yk = mailBody_yk + "FiboPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_yk = mailBody_yk + "E3Percent: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints34) * 100, 1 ) + "%]\n";

      mailBody_yk = mailBody_yk + "\n";
      if(lengthPoints12 < lengthPoints23) {
        mailBody_yk = mailBody_yk + "5RRPoints: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( (lengthPoints13 / lengthPoints12) * 100, 1 ) + "%]\n";
      } else {
        mailBody_yk = mailBody_yk + "5RRPoints: None\n";
      }
      if(lengthPoints12 < lengthPoints34) {
        mailBody_yk = mailBody_yk + "3RRPoints: " + DoubleToStr( lengthPoints34 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
      } else {
        mailBody_yk = mailBody_yk + "3RRPoints: None\n";
      }

      mailBody_yk = mailBody_yk + "\n";
      //mailBody = mailBody + "MaxE3Points: " + DoubleToStr( lengthPoints34*1.618, 0 ) + " [" + DoubleToStr( lengthPoints34*1.618 - lengthPoints12, 0 ) + "]\n";
      mailBody_yk = mailBody_yk + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_yk = mailBody_yk + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_yk = mailBody_yk + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_yk, mailBody_yk );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_YK_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_yk, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_yk = Time[0];
    lastAlertZigzag_yk = zigzag2;
  }
  // YK_s
  if(StringLen( alertText_yks ) > 0 && lastAlert_yks != Time[0] && lastAlertZigzag_yks != zigzag2) {
    Alert(alertText_yks);
    if(MailAlert) {
      mailBody_yks = mailBody_yks + alertText_yks; // ロング or ショート、通貨ペア、時間足
      mailBody_yks = mailBody_yks + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints1C2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1C3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      mailBody_yks = mailBody_yks + "FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_yks = mailBody_yks + "E3Percent: " + DoubleToStr( lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints1C2 / lengthPoints34) * 100, 1 ) + "%]\n";

      mailBody_yks = mailBody_yks + "\n";
      if(lengthPoints1C2 < lengthPoints23) {
        mailBody_yks = mailBody_yks + "5RRPts: " + DoubleToStr( lengthPoints1C3, 0 ) + " / " + DoubleToStr( lengthPoints1C2, 0 ) + " [" + DoubleToStr( (lengthPoints1C3 / lengthPoints1C2) * 100, 1 ) + "%]\n";
      } else {
        mailBody_yks = mailBody_yks + "5RRPts: None\n";
      }
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
      handle = FileOpen("MAZigzag_YK_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_yks, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_yks = Time[0];
    lastAlertZigzag_yks = zigzag2;
  }
  // YK_S、YK_M
  if(StringLen( alertText ) > 0 && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    Alert(alertText);
    if(MailAlert) {
      mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPointsC1 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 ) / Point();
      lengthPointsC2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      mailBody = mailBody + "FiboPts: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody = mailBody + "E3Percent: " + DoubleToStr( lengthPointsC1, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPointsC1 / lengthPoints23) * 100, 1 ) + "%]\n";

      mailBody = mailBody + "\n";
      if(lengthPointsC1 < lengthPoints12) {
        mailBody = mailBody + "5RRPts: " + DoubleToStr( lengthPointsC2, 0 ) + " / " + DoubleToStr( lengthPointsC1, 0 ) + " [" + DoubleToStr( (lengthPointsC2 / lengthPointsC1) * 100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "5RRPts: None\n";
      }
      if(lengthPointsC1 < lengthPoints23) {
        mailBody = mailBody + "3RRPts: " + DoubleToStr( lengthPoints23 - lengthPointsC1, 0 ) + " / " + DoubleToStr( lengthPointsC1, 0 ) + " [" + DoubleToStr((((lengthPoints23 - lengthPointsC1) / lengthPointsC1))*100, 1 ) + "%]\n";
      } else {
        mailBody = mailBody + "3RRPts: None\n";
      }

      mailBody = mailBody + "\n";
      mailBody = mailBody + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody = mailBody + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody = mailBody + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject, mailBody );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_YK_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert = Time[0];
    lastAlertZigzag = zigzag2;
  }

  return(0);
}
