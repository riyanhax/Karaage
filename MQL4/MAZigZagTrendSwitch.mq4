#property copyright "Copyright(C) 2021 Studiogadget Inc."

#property indicator_chart_window

input string ZigZagSetting = "/////// ZigZagSetting ///////";
input int Depth = 7;
input int Deviation = 5;
input int Backstep = 1;
input string MovingAverageSetting = "/////// MovingAverageSetting ///////";
input int MACurrentPeriod = 20;
input int MALongPeriod = 80;
input string AlertSetting = "/////// AlertSetting ///////";
input int AlertRequirementCount = 3;
input bool MailAlert = true;
input bool FileOutput = true;

datetime lastAlert_2 = 0;
double lastAlertZigzag_2;
string periodText;


int OnInit() {
  if(Period() == 1) {
    periodText = "M1";
  } else if(Period() == 5) {
    periodText = "M5";
  } else if(Period() == 15) {
    periodText = "M15";
  } else if(Period() == 30) {
    periodText = "M30";
  } else if(Period() == 60) {
    periodText = "H1";
  } else if(Period() == 240) {
    periodText = "H4";
  } else if(Period() == 1440) {
    periodText = "D1";
  } else if(Period() == 10080) {
    periodText = "W1";
  } else if(Period() == 43200) {
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
  double maCurrentEma;
  double maCurrentSma;
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement_2;
  string alertText_2;
  string mailSubject_2;
  string mailBody_2;
  string direction_2;
  int handle;

  // ZigZag取得
  cnt = 0;
  for(i=0; i<iBars( Symbol(), PERIOD_CURRENT); i++) {
    zigzagTmp = iCustom(Symbol(), PERIOD_CURRENT, "ZigZag", Depth, Deviation, Backstep, 0, i);
    if(cnt == 0 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag1 = zigzagTmp;
      cnt = 1;
    } else if(cnt == 1 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag2 = zigzagTmp;
      cnt = 2;
    } else if(cnt == 2 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag3 = zigzagTmp;
      cnt = 3;
    } else if(cnt == 3 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag4 = zigzagTmp;
      cnt = 4;
    } else if(cnt == 4 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag5 = zigzagTmp;
      cnt = 5;
      break;
    }
  }

  // 条件
  requirement_2 = 0;
  // Long 切り替わり
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag3 <= zigzag5) {
    if(zigzag3 < Close[1]) {
      // MovingAverage取得
      maCurrentSma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maCurrentEma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
      maLongSma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maLongEma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

      if(zigzag2 <= zigzag4) {
        alertText_2 = alertText_2 + "Long_HS " + Symbol() + " " + periodText + "\n";
        mailSubject_2 = "[Long_HS] " + Symbol() + " " + periodText + " " + Time[0];
        direction_2 = "long_hs";

        if(maCurrentSma < maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Short MA: Golden Cross" + "\n";
        }
        if(maLongSma < maLongEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Long MA: Golden Cross" + "\n";
        }
        if(maLongEma < maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "EMA: Golden Cross" + "\n";
        }
      } else if(zigzag2 > zigzag4) {
        alertText_2 = alertText_2 + "Long_MW " + Symbol() + " " + periodText + "\n";
        mailSubject_2 = "[Long_MW] " + Symbol() + " " + periodText + " " + Time[0];
        direction_2 = "long_mw";

        if(maCurrentSma < maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Short MA: Golden Cross" + "\n";
        }
        if(maLongSma < maLongEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Long MA: Golden Cross" + "\n";
        }
        if(maLongEma < maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "EMA: Golden Cross" + "\n";
        }
      }
    }
  }
  // Short 切り替わり
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag3 >= zigzag5) {
    if(zigzag3 > Close[1]) {
      // MovingAverage取得
      maCurrentSma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maCurrentEma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
      maLongSma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maLongEma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

      if(zigzag2 >= zigzag4) {
        alertText_2 = alertText_2 + "Short_HS " + Symbol() + " " + periodText + "\n";
        mailSubject_2 = "[Short_HS] " + Symbol() + " " + periodText + " " + Time[0];
        direction_2 = "short_hs";

        if(maCurrentSma > maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Short MA: Dead Cross" + "\n";
        }
        if(maLongSma > maLongEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Long MA: Dead Cross" + "\n";
        }
        if(maLongEma > maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "EMA: Dead Cross" + "\n";
        }
      } else if(zigzag2 < zigzag4) {
        alertText_2 = alertText_2 + "Short_MW " + Symbol() + " " + periodText + "\n";
        mailSubject_2 = "[Short_MW] " + Symbol() + " " + periodText + " " + Time[0];
        direction_2 = "short_mw";

        if(maCurrentSma > maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Short MA: Dead Cross" + "\n";
        }
        if(maLongSma > maLongEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "Long MA: Dead Cross" + "\n";
        }
        if(maLongEma > maCurrentEma) {
          requirement_2++;
          alertText_2 = alertText_2 + "EMA: Dead Cross" + "\n";
        }
      }
    }
  }

  // 条件を満たした数によってアラート
  if(requirement_2 >= AlertRequirementCount && lastAlert_2 != Time[0] && lastAlertZigzag_2 != zigzag2) {
    Alert(alertText_2);
    if(MailAlert) {
      mailBody_2 = mailBody_2 + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody_2 = mailBody_2 + alertText_2; // ロング or ショート、通貨ペア、時間足
      mailBody_2 = mailBody_2 + "Price: " + Close[0];
      mailBody_2 = mailBody_2 + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + ", " + zigzag5 + "\n";
      double lengthPoints23_2 = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints34_2 = MathAbs( zigzag4 - zigzag5 ) / Point();
      double lengthPercent_2 = (lengthPoints23_2 / lengthPoints34_2) * 100;
      mailBody_2 = mailBody_2 + "LengthPoints: " + DoubleToStr( lengthPoints23_2, 0 ) + " / " + DoubleToStr( lengthPoints34_2, 0 ) + " [" + DoubleToStr( lengthPercent_2, 1 ) + "%]\n";
      SendMail( mailSubject_2, mailBody_2 );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzagTrendSwitch_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_2, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_2 = Time[0];
    lastAlertZigzag_2 = zigzag2;
  }

  return(0);
}
