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
input double FiboPtsPercentMax = 61.8;
input double FiboPtsPercentMin = 36.8;
input bool MailAlert = true;
input bool FileOutput = true;

datetime lastAlert_yks = 0;
double lastAlertZigzag_yks;
datetime lastAlert_2nd = 0;
double lastAlertZigzag_2nd;
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
  int i;
  int cnt;
  int requirement_yks;
  string alertText_yks;
  string mailSubject_yks;
  string mailBody_yks;
  string direction_yks;
  int requirement_2nd;
  string alertText_2nd;
  string mailSubject_2nd;
  string mailBody_2nd;
  string direction_2nd;
  int handle;
  double lengthPoints12;
  double lengthPoints13;
  double lengthPoints23;
  double lengthPoints34;
  double lengthPoints1C2;
  double lengthPoints1C3;
  double fiboPtsPercent;

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
    } else if(cnt == 4 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag5 = zigzagTmp;
      maCurrentSma5 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma5 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma5 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma5 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma5 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma5 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      cnt = 5;
      break;
    } else if(cnt == 5 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag6 = zigzagTmp;
      maCurrentSma6 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma6 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma6 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maMiddleEma6 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maLongSma6 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maLongEma6 = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      cnt = 6;
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

  // Fibo Point
  lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
  lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
  fiboPtsPercent = (lengthPoints23 / lengthPoints34) * 100;

  // 条件
  // 1st
  requirement_yks = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag2 >= zigzag4
    && fiboPtsPercent >= FiboPtsPercentMin && fiboPtsPercent <= FiboPtsPercentMax ) {
    if(zigzag4 < maCurrentSma4 && zigzag4 < maCurrentEma4 && zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3
      && iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 陽線
      ) {

      if(zigzag4 < maMiddleSma4 && zigzag4 < maMiddleEma4 && zigzag3 > maMiddleSma3 && zigzag3 > maMiddleEma3) {

        if(zigzag4 < maLongSma4 && zigzag4 < maLongEma4 && zigzag3 > maLongSma3 && zigzag3 > maLongEma3) {
          alertText_yks = alertText_yks + "Long_1st_l " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Long_1st_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "long_1st_l";
        } else {
          alertText_yks = alertText_yks + "Long_1st_m " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Long_1st_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "long_1st_m";
        }
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
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag2 <= zigzag4
    && fiboPtsPercent >= FiboPtsPercentMin && fiboPtsPercent <= FiboPtsPercentMax) {
    if(zigzag4 > maCurrentSma4 && zigzag4 > maCurrentEma4 && zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3
      && iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 陰線
      ) {

      if(zigzag4 > maMiddleSma4 && zigzag4 > maMiddleEma4 && zigzag3 < maMiddleSma3 && zigzag3 < maMiddleEma3) {

        if(zigzag4 > maLongSma4 && zigzag4 > maLongEma4 && zigzag3 < maLongSma3 && zigzag3 < maLongEma3) {
          alertText_yks = alertText_yks + "Short_1st_l " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Short_1st_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "short_1st_l";
        } else {
          alertText_yks = alertText_yks + "Short_1st_m " + Symbol() + " " + periodText + "\n";
          alertText_yks = alertText_yks + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_yks = "[Short_1st_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction_yks = "short_1st_m";
        }
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
  // 2nd
  requirement_2nd = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
    && zigzag2 <= zigzag4 && zigzag3 <= zigzag5 && zigzag2 >= zigzag6
    && fiboPtsPercent >= FiboPtsPercentMin && fiboPtsPercent <= FiboPtsPercentMax ) {
    if(zigzag4 < maCurrentSma4 && zigzag4 < maCurrentEma4 && zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3
      && iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 陽線
      ) {

      if(zigzag4 < maMiddleSma4 && zigzag4 < maMiddleEma4 && zigzag3 > maMiddleSma3 && zigzag3 > maMiddleEma3) {

        if(zigzag4 < maLongSma4 && zigzag4 < maLongEma4 && zigzag3 > maLongSma3 && zigzag3 > maLongEma3) {
          alertText_2nd = alertText_2nd + "Long_1st_l " + Symbol() + " " + periodText + "\n";
          alertText_2nd = alertText_2nd + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_2nd = "[Long_1st_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction_2nd = "long_1st_l";
        } else {
          alertText_2nd = alertText_2nd + "Long_1st_m " + Symbol() + " " + periodText + "\n";
          alertText_2nd = alertText_2nd + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_2nd = "[Long_1st_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction_2nd = "long_1st_m";
        }
      }

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
    }
  }
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
    && zigzag2 <= zigzag4 && zigzag3 >= zigzag5 && zigzag2 <= zigzag6
    && fiboPtsPercent >= FiboPtsPercentMin && fiboPtsPercent <= FiboPtsPercentMax) {
    if(zigzag4 > maCurrentSma4 && zigzag4 > maCurrentEma4 && zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3
      && iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 陰線
      ) {

      if(zigzag4 > maMiddleSma4 && zigzag4 > maMiddleEma4 && zigzag3 < maMiddleSma3 && zigzag3 < maMiddleEma3) {

        if(zigzag4 > maLongSma4 && zigzag4 > maLongEma4 && zigzag3 < maLongSma3 && zigzag3 < maLongEma3) {
          alertText_2nd = alertText_2nd + "Short_1st_l " + Symbol() + " " + periodText + "\n";
          alertText_2nd = alertText_2nd + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_2nd = "[Short_1st_l] " + Symbol() + " " + periodText + " " + Time[0];
          direction_2nd = "short_1st_l";
        } else {
          alertText_2nd = alertText_2nd + "Short_1st_m " + Symbol() + " " + periodText + "\n";
          alertText_2nd = alertText_2nd + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject_2nd = "[Short_1st_m] " + Symbol() + " " + periodText + " " + Time[0];
          direction_2nd = "short_1st_m";
        }
      }

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
    }
  }

  // 1st
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
      handle = FileOpen("MAZigzag_1st_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_yks, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_yks = Time[0];
    lastAlertZigzag_yks = zigzag2;
  }
  // 2nd
  if(StringLen( alertText_2nd ) > 0 && lastAlert_2nd != Time[0] && lastAlertZigzag_2nd != zigzag2) {
    Alert(alertText_2nd);
    if(MailAlert) {
      mailBody_2nd = mailBody_2nd + alertText_2nd; // ロング or ショート、通貨ペア、時間足
      mailBody_2nd = mailBody_2nd + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPoints1C2 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / Point();
      lengthPoints1C3 = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ) / Point();
      mailBody_2nd = mailBody_2nd + "FiboPts: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_2nd = mailBody_2nd + "E3Percent: " + DoubleToStr( lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints1C2 / lengthPoints34) * 100, 1 ) + "%]\n";

      mailBody_2nd = mailBody_2nd + "\n";
      if(lengthPoints1C2 < lengthPoints23) {
        mailBody_2nd = mailBody_2nd + "5RRPts: " + DoubleToStr( lengthPoints1C3, 0 ) + " / " + DoubleToStr( lengthPoints1C2, 0 ) + " [" + DoubleToStr( (lengthPoints1C3 / lengthPoints1C2) * 100, 1 ) + "%]\n";
      } else {
        mailBody_2nd = mailBody_2nd + "5RRPts: None\n";
      }
      if(lengthPoints1C2 < lengthPoints34) {
        mailBody_2nd = mailBody_2nd + "3RRPts: " + DoubleToStr( lengthPoints34 - lengthPoints1C2, 0 ) + " / " + DoubleToStr( lengthPoints1C2, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints1C2) / lengthPoints1C2))*100, 1 ) + "%]\n";
      } else {
        mailBody_2nd = mailBody_2nd + "3RRPts: None\n";
      }

      mailBody_2nd = mailBody_2nd + "\n";
      mailBody_2nd = mailBody_2nd + "ShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_2nd = mailBody_2nd + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_2nd = mailBody_2nd + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_2nd, mailBody_2nd );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_1st_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_2nd, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_2nd = Time[0];
    lastAlertZigzag_2nd = zigzag2;
  }

  return(0);
}
