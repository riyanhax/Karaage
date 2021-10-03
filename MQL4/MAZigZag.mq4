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
input int MALongPeriod = 80;
input string AlertSetting = "/////// AlertSetting ///////";
input int AlertRequirementCount = 3;
input bool MailAlert = true;
input bool FileOutput = true;

datetime lastAlert = 0;
double lastAlertZigzag;
datetime lastAlert_tr = 0;
double lastAlertZigzag_tr;
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
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement;
  string alertText;
  string mailSubject;
  string mailBody;
  string direction;
  int requirement_tr;
  string alertText_tr;
  string mailSubject_tr;
  string mailBody_tr;
  string direction_tr;
  int handle;
  double lengthPoints12;
  double lengthPoints13;
  double lengthPoints23;
  double lengthPoints34;
  double lengthPercent_rr;
  double lengthPercent_fibo;

  // ZigZag取得
  cnt = 0;
  for(i=0; i<iBars( Symbol(), ZigzagTimeframe); i++) {
    zigzagTmp = iCustom(Symbol(), ZigzagTimeframe, "ZigZag", Depth, Deviation, Backstep, 0, i);
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
    } else if(cnt == 5 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag6 = zigzagTmp;
      cnt = 6;
      break;
    }
  }

  // 条件
  requirement = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag2 >= zigzag4) {
    alertText = alertText + "Long " + Symbol() + " " + periodText + "\n";
    mailSubject = "[Long] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "long";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

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
  // Short
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag2 <= zigzag4) {
    alertText = alertText + "Short " + Symbol() + " " + periodText + "\n";
    mailSubject = "[Short] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "short";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

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

  requirement_tr = 0;
  // Long_TR
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
    && zigzag3 > zigzag5 && zigzag2 >= zigzag5 && zigzag4 >= zigzag6 && zigzag2 >= zigzag4) {
    alertText_tr = alertText_tr + "Long_TR " + Symbol() + " " + periodText + "\n";
    mailSubject_tr = "[Long_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "long_tr";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma < maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "Short MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "Long MA: Golden Cross" + "\n";
    }
    if(maLongEma < maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "EMA: Golden Cross" + "\n";
    }
  }
  // Short_TR
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
    && zigzag3 < zigzag5 && zigzag2 <= zigzag5 && zigzag4 <= zigzag6 && zigzag2 <= zigzag4) {
    alertText_tr = alertText_tr + "Short_TR " + Symbol() + " " + periodText + "\n";
    mailSubject_tr = "[Short_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "short_tr";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma > maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "Short MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "Long MA: Dead Cross" + "\n";
    }
    if(maLongEma > maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "EMA: Dead Cross" + "\n";
    }
  }

  // 条件を満たした数によってアラート
  if(requirement_tr < AlertRequirementCount) {
    if(requirement >= AlertRequirementCount && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
      Alert(alertText);
      if(MailAlert) {
        mailBody = mailBody + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
        mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
        mailBody = mailBody + "Price: " + Close[0];
        mailBody = mailBody + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + "\n";
        lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
        lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
        lengthPercent_rr = (lengthPoints13 / lengthPoints12) * 100;
        mailBody = mailBody + "RRPoints: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( lengthPercent_rr, 1 ) + "%]\n";
        lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
        lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
        lengthPercent_fibo = (lengthPoints23 / lengthPoints34) * 100;
        mailBody = mailBody + "FiboPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( lengthPercent_fibo, 1 ) + "%]\n";
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
  }
  if(requirement_tr >= AlertRequirementCount && lastAlert_tr != Time[0] && lastAlertZigzag_tr != zigzag2) {
    Alert(alertText_tr);
    if(MailAlert) {
      mailBody_tr = mailBody_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody_tr = mailBody_tr + alertText_tr; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Price: " + Close[0];
      mailBody_tr = mailBody_tr + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPercent_rr = (lengthPoints13 / lengthPoints12) * 100;
      mailBody_tr = mailBody_tr + "RRPoints: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( lengthPercent_rr, 1 ) + "%]\n";
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      lengthPercent_fibo = (lengthPoints23 / lengthPoints34) * 100;
      mailBody_tr = mailBody_tr + "FiboPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( lengthPercent_fibo, 1 ) + "%]\n";
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

  return(0);
}
