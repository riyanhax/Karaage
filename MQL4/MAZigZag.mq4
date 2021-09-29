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

datetime lastAlert = 0;
datetime lastAlert_2 = 0;
double lastAlertZigzag;
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
  int requirement;
  int requirement_2;
  string alertText;
  string alertText_2;
  string mailSubject;
  string mailSubject_2;
  string mailBody;
  string mailBody_2;
  string direction;
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
  requirement = 0;
  requirement_2 = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag2 >= zigzag4) {
    alertText = alertText + "Long " + Symbol() + " " + periodText + "\n";
    mailSubject = "[Long] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "long";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma < maCurrentEma) {
      requirement++;
      alertText = alertText + "Short MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      requirement++;
      alertText = alertText + "Long MA: Golden Cross" + "\n";
    }
    if(maLongEma < maCurrentEma) {
      requirement++;
      alertText = alertText + "EMA: Golden Cross" + "\n";
    }
  }
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag3 <= zigzag5) {
    if(zigzag3 < Close[1]) {
      // MovingAverage取得
      maCurrentSma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maCurrentEma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
      maLongSma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maLongEma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

      if(zigzag2 <= zigzag4) {
        alertText_2 = alertText_2 + "Long_2 " + Symbol() + " " + periodText + "\n";
        mailSubject_2 = "[Long_2] " + Symbol() + " " + periodText + " " + Time[0];
        direction_2 = "long_2";

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
        // 後ほど実装
      }
    }
  }
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag2 <= zigzag4) {
    alertText = alertText + "Short " + Symbol() + " " + periodText + "\n";
    mailSubject = "[Short] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "short";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma > maCurrentEma) {
      requirement++;
      alertText = alertText + "Short MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      requirement++;
      alertText = alertText + "Long MA: Dead Cross" + "\n";
    }
    if(maLongEma > maCurrentEma) {
      requirement++;
      alertText = alertText + "EMA: Dead Cross" + "\n";
    }
  }
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag3 >= zigzag5) {
    if(zigzag3 > Close[1]) {
      // MovingAverage取得
      maCurrentSma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maCurrentEma = iMA( Symbol(), PERIOD_CURRENT, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
      maLongSma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maLongEma = iMA( Symbol(), PERIOD_CURRENT, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

      if(zigzag2 >= zigzag4) {
        alertText_2 = alertText_2 + "Short_2 " + Symbol() + " " + periodText + "\n";
        mailSubject_2 = "[Short_2] " + Symbol() + " " + periodText + " " + Time[0];
        direction_2 = "short_2";

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
        // 後ほど実装
      }
    }
  }

  // 条件を満たした数によってアラート
  if(requirement >= AlertRequirementCount && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    Alert(alertText);
    if(MailAlert) {
      mailBody = mailBody + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + "\n";
      double lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPercent = (lengthPoints23 / lengthPoints34) * 100;
      mailBody = mailBody + "LengthPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( lengthPercent, 1 ) + "%]\n";
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
  if(requirement_2 >= AlertRequirementCount && lastAlert_2 != Time[0] && lastAlertZigzag_2 != zigzag2) {
    Alert(alertText_2);
    if(MailAlert) {
      mailBody_2 = mailBody_2 + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody_2 = mailBody_2 + alertText_2; // ロング or ショート、通貨ペア、時間足
      mailBody_2 = mailBody_2 + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + ", " + zigzag5 + "\n";
      double lengthPoints23_2 = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPoints34_2 = MathAbs( zigzag4 - zigzag5 ) / Point();
      double lengthPercent_2 = (lengthPoints23 / lengthPoints34) * 100;
      mailBody_2 = mailBody_2 + "LengthPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( lengthPercent, 1 ) + "%]\n";
      SendMail( mailSubject_2, mailBody_2 );
    }

    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_2, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_2 = Time[0];
    lastAlertZigzag_2 = zigzag2;
  }

  return(0);
}
