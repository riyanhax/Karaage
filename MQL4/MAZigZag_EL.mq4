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

datetime lastAlert_el = 0;
double lastAlertZigzag_el;
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
  double maCurrentEma;
  double maCurrentSma;
  double maMiddleEma;
  double maMiddleSma;
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement_el;
  string alertText_el;
  string mailSubject_el;
  string mailBody_el;
  string direction_el;
  int handle;
  double lengthPoints12;
  double lengthPoints15;
  double lengthPoints25;
  double lengthPoints58;

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
    } else if(cnt == 7 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag8 = zigzagTmp;
      cnt = 8;
      break;
    }
  }

  requirement_el = 0;
  // Long_EL
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
      && zigzag5 > zigzag6 && zigzag6 < zigzag7 && zigzag7 > zigzag8
      && zigzag3 <= zigzag5 && zigzag4 >= zigzag6 && zigzag5 >= zigzag7 && zigzag6 >= zigzag8
      && zigzag2 >= zigzag6) {
    alertText_el = alertText_el + "Long_EL " + Symbol() + " " + periodText + "\n";
    mailSubject_el = "[Long_EL] " + Symbol() + " " + periodText + " " + Time[0];
    direction_el = "long_el";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma < maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "①Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_el++;
      alertText_el = alertText_el + "②Middle MA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "③EMA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_el = alertText_el + "④Long MA: Golden Cross" + "\n";
    }
    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_el = alertText_el + "⑤ALL EMA: Golden Cross" + "\n";
    }
  }
  // Short_EL
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
      && zigzag5 < zigzag6 && zigzag6 > zigzag7 && zigzag7 < zigzag8
      && zigzag3 >= zigzag5 && zigzag4 <= zigzag6 && zigzag5 <= zigzag7 && zigzag6 <= zigzag8
      && zigzag2 <= zigzag6) {
    alertText_el = alertText_el + "Short_EL " + Symbol() + " " + periodText + "\n";
    mailSubject_el = "[Short_EL] " + Symbol() + " " + periodText + " " + Time[0];
    direction_el = "short_el";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma > maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "①Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_el++;
      alertText_el = alertText_el + "②Middle MA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_el++;
      alertText_el = alertText_el + "③EMA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_el = alertText_el + "④Long MA: Dead Cross" + "\n";
    }
    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_el = alertText_el + "⑤ALL EMA: Dead Cross" + "\n";
    }
  }

  if(requirement_el >= AlertRequirementCount && lastAlert_el != Time[0] && lastAlertZigzag_el != zigzag2) {
    Alert(alertText_el);
    if(MailAlert) {
      mailBody_el = mailBody_el + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody_el = mailBody_el + alertText_el; // ロング or ショート、通貨ペア、時間足
      mailBody_el = mailBody_el + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints15 = MathAbs( zigzag1 - zigzag5 ) / Point();
      lengthPoints25 = MathAbs( zigzag2 - zigzag5 ) / Point();
      lengthPoints58 = MathAbs( zigzag5 - zigzag8 ) / Point();
      mailBody_el = mailBody_el + "FiboPoints: " + DoubleToStr( lengthPoints25, 0 ) + " / " + DoubleToStr( lengthPoints58, 0 ) + " [" + DoubleToStr( (lengthPoints25 / lengthPoints58) * 100, 1 ) + "%]\n";
      mailBody_el = mailBody_el + "E3Percent: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints58, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints58) * 100, 1 ) + "%]\n";
      if(lengthPoints12 < lengthPoints15) {
        mailBody_el = mailBody_el + "5RRPoints: " + DoubleToStr( lengthPoints15, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( (lengthPoints15 / lengthPoints12) * 100, 1 ) + "%]\n";
      } else {
        mailBody_el = mailBody_el + "5RRPoints: None\n";
      }
      if(lengthPoints12 < lengthPoints58) {
        mailBody_el = mailBody_el + "3RRPoints: " + DoubleToStr( lengthPoints58 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints58 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
      } else {
        mailBody_el = mailBody_el + "3RRPoints: None\n";
      }
      mailBody_el = mailBody_el + "\nShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_el = mailBody_el + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_el = mailBody_el + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_el, mailBody_el );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_EL_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_el, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_el = Time[0];
    lastAlertZigzag_el = zigzag2;
  }

  return(0);
}
