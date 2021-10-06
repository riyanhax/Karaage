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
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement;
  string alertText;
  string mailSubject;
  string mailBody;
  string direction;
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
    } else if(cnt == 6 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag7 = zigzagTmp;
      cnt = 7;
      break;
    }
  }

  // 条件
  requirement = 0;
  // Long 切り替わり
  if(zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6 && zigzag6 < zigzag7
      && zigzag5 <= zigzag7 && zigzag3 >= zigzag5 && zigzag2 >= zigzag4) {
    if(zigzag4 <= zigzag6) {
      alertText = alertText + "Long_MW_HS " + Symbol() + " " + periodText + "\n";
      mailSubject = "[Long_MW_HS] " + Symbol() + " " + periodText + " " + Time[0];
      direction = "long_mw_hs";
    } else {
      alertText = alertText + "Long_HS_TR " + Symbol() + " " + periodText + "\n";
      mailSubject = "[Long_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
      direction = "long_hs_tr";
    }
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
  // Short 切り替わり
  if(zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6 && zigzag6 > zigzag7
      && zigzag5 >= zigzag7 && zigzag3 <= zigzag5 && zigzag2 <= zigzag4) {
    if(zigzag4 >= zigzag6) {
      alertText = alertText + "Short_MW_HS " + Symbol() + " " + periodText + "\n";
      mailSubject = "[Short_MW_HS] " + Symbol() + " " + periodText + " " + Time[0];
      direction = "short_mw_hs";
    } else {
      alertText = alertText + "Short_HS_TR " + Symbol() + " " + periodText + "\n";
      mailSubject = "[Short_HS_TR] " + Symbol() + " " + periodText + " " + Time[0];
      direction = "short_hs_tr";
    }
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

  // 条件を満たした数によってアラート
  if(requirement >= AlertRequirementCount && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    Alert(alertText);
    if(MailAlert) {
      mailBody = mailBody + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Price: " + Close[0];
      mailBody = mailBody + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + "\n";
      double lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      double lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      double lengthPercent_rr = (lengthPoints13 / lengthPoints12) * 100;
      mailBody = mailBody + "RRPoints: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( lengthPercent_rr, 1 ) + "%]\n";
      double lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      double lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      double lengthPercent_fibo = (lengthPoints23 / lengthPoints34) * 100;
      mailBody = mailBody + "FiboPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( lengthPercent_fibo, 1 ) + "%]\n";
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

  return(0);
}