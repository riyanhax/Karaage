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

datetime lastAlert = 0;
double lastAlertZigzag;
datetime lastAlert_tr = 0;
double lastAlertZigzag_tr;
datetime lastAlert_trnc = 0;
double lastAlertZigzag_trnc;
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
  double maMiddleEma;
  double maMiddleSma;
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  /**
  int requirement;
  string alertText;
  string mailSubject;
  string mailBody;
  string direction;
  */
  int requirement_tr;
  string alertText_tr;
  string mailSubject_tr;
  string mailBody_tr;
  string direction_tr;
  int requirement_trnc;
  string alertText_trnc;
  string mailSubject_trnc;
  string mailBody_trnc;
  string direction_trnc;
  int handle;
  double lengthPoints12;
  double lengthPoints13;
  double lengthPoints23;
  double lengthPoints34;

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
  /**
  requirement = 0;
  // Long
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag2 >= zigzag4) {
    alertText = alertText + "Long " + Symbol() + " " + periodText + "\n";
    mailSubject = "[Long] " + Symbol() + " " + periodText + " " + Time[0];
    direction = "long";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma < maCurrentEma) {
      requirement++;
      alertText = alertText + "Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement++;
      alertText = alertText + "Long MA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
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
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma > maCurrentEma) {
      requirement++;
      alertText = alertText + "Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement++;
      alertText = alertText + "Long MA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement++;
      alertText = alertText + "EMA: Dead Cross" + "\n";
    }
  }
  */

  requirement_tr = 0;
  // Long_TR
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5 && zigzag5 > zigzag6
    && zigzag3 > zigzag5 && zigzag2 >= zigzag5 && zigzag4 >= zigzag6 && zigzag2 >= zigzag4) {
    alertText_tr = alertText_tr + "Long_ST_TR " + Symbol() + " " + periodText + "\n";
    mailSubject_tr = "[Long_ST_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "long_st_tr";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma < maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "①Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "②Middle MA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "③EMA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_tr = alertText_tr + "④Long MA: Golden Cross" + "\n";
    }
    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_tr = alertText_tr + "⑤ALL EMA: Golden Cross" + "\n";
    }
  }
  // Short_TR
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5 && zigzag5 < zigzag6
    && zigzag3 < zigzag5 && zigzag2 <= zigzag5 && zigzag4 <= zigzag6 && zigzag2 <= zigzag4) {
    alertText_tr = alertText_tr + "Short_ST_TR " + Symbol() + " " + periodText + "\n";
    mailSubject_tr = "[Short_ST_TR] " + Symbol() + " " + periodText + " " + Time[0];
    direction_tr = "short_st_tr";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentSma > maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "①Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "②Middle MA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_tr++;
      alertText_tr = alertText_tr + "③EMA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_tr = alertText_tr + "④Long MA: Dead Cross" + "\n";
    }
    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_tr = alertText_tr + "⑤ALL EMA: Dead Cross" + "\n";
    }
  }
  requirement_trnc = 0;
  // Long_TR_NC
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
     && zigzag2 >= zigzag4 && zigzag3 >= zigzag5
     && Open[1] < zigzag4 && Close[1] >= zigzag4) {
    alertText_trnc = alertText_trnc + "Long_ST_TR_NC " + Symbol() + " " + periodText + "\n";
    mailSubject_trnc = "[Long_ST_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "long_st_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    requirement_trnc++;
    if(maCurrentSma < maCurrentEma) {
      alertText_trnc = alertText_trnc + "①Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      alertText_trnc = alertText_trnc + "②Middle MA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      alertText_trnc = alertText_trnc + "③EMA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_trnc = alertText_trnc + "④Long MA: Golden Cross" + "\n";
    }
    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_trnc = alertText_trnc + "⑤ALL EMA: Golden Cross" + "\n";
    }
  }
  // Short_TR_NC
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
     && zigzag2 <= zigzag4 && zigzag3 <= zigzag5
     && Open[1] > zigzag4 && Close[1] <= zigzag4) {
    alertText_trnc = alertText_trnc + "Short_ST_TR_NC " + Symbol() + " " + periodText + "\n";
    mailSubject_trnc = "[Short_ST_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "Short_ST_tr_nc";
    // MovingAverage取得
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    requirement_trnc++;
    if(maCurrentSma > maCurrentEma) {
      alertText_trnc = alertText_trnc + "①Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      alertText_trnc = alertText_trnc + "②Middle MA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      alertText_trnc = alertText_trnc + "③EMA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_trnc = alertText_trnc + "④Long MA: Dead Cross" + "\n";
    }
    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_trnc = alertText_trnc + "⑤ALL EMA: Dead Cross" + "\n";
    }
  }

  // 条件を満たした数によってアラート
  /**
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
  */
  if(StringLen(alertText_tr) > 0 && requirement_tr >= AlertRequirementCount && lastAlert_tr != Time[0] && lastAlertZigzag_tr != zigzag2) {
    Alert(alertText_tr);
    if(MailAlert) {
      mailBody_tr = mailBody_tr + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody_tr = mailBody_tr + alertText_tr; // ロング or ショート、通貨ペア、時間足
      mailBody_tr = mailBody_tr + "Price: " + Close[0] + "\n";
      //mailBody_tr = mailBody_tr + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      mailBody_tr = mailBody_tr + "FiboPoints: " + DoubleToStr( lengthPoints23, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints23 / lengthPoints34) * 100, 1 ) + "%]\n";
      mailBody_tr = mailBody_tr + "E3Percent: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints34, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints34) * 100, 1 ) + "%]\n";
      if(lengthPoints12 < lengthPoints23) {
        mailBody_tr = mailBody_tr + "5RRPoints: " + DoubleToStr( lengthPoints13, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr( (lengthPoints13 / lengthPoints12) * 100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "5RRPoints: None\n";
      }
      if(lengthPoints12 < lengthPoints34) {
        mailBody_tr = mailBody_tr + "3RRPoints: " + DoubleToStr( lengthPoints34 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints12, 0 ) + " [" + DoubleToStr((((lengthPoints34 - lengthPoints12) / lengthPoints12))*100, 1 ) + "%]\n";
      } else {
        mailBody_tr = mailBody_tr + "3RRPoints: None\n";
      }
      //mailBody_tr = mailBody_tr + "MaxE3Points: " + DoubleToStr( lengthPoints34*1.618, 0 ) + " [" + DoubleToStr( lengthPoints34*1.618 - lengthPoints12, 0 ) + "]\n";
      mailBody_tr = mailBody_tr + "\nShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
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
  if(StringLen(alertText_trnc) > 0 && requirement_trnc > 0 && lastAlert_trnc != Time[0] && lastAlertZigzag_trnc != zigzag2) {
    Alert(alertText_trnc);
    if(MailAlert) {
      mailBody_trnc = mailBody_trnc + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
      mailBody_trnc = mailBody_trnc + alertText_trnc; // ロング or ショート、通貨ペア、時間足
      mailBody_trnc = mailBody_trnc + "Price: " + Close[0] + "\n";
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints13 = MathAbs( zigzag1 - zigzag3 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      lengthPoints34 = MathAbs( zigzag3 - zigzag4 ) / Point();
      mailBody_trnc = mailBody_trnc + "FiboPoints: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints23, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints23) * 100, 1 ) + "%]\n";
      mailBody_trnc = mailBody_trnc + "NCRRPoints: " + DoubleToStr( lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints13, 0 ) + " [" + DoubleToStr( (lengthPoints12 / lengthPoints13) * 100, 1 ) + "%]\n";
      mailBody_trnc = mailBody_trnc + "3RRPoints: " + DoubleToStr( lengthPoints23 - lengthPoints12, 0 ) + " / " + DoubleToStr( lengthPoints13, 0 ) + " [" + DoubleToStr((((lengthPoints23 - lengthPoints12) / lengthPoints13))*100, 1 ) + "%]\n";
      mailBody_trnc = mailBody_trnc + "\nShortMADis: " + DoubleToStr(((Close[0] - maCurrentEma) / maCurrentEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maCurrentEma)/Point, 0) + "]\n";
      mailBody_trnc = mailBody_trnc + "MiddleMADis: " + DoubleToStr(((Close[0] - maMiddleEma) / maMiddleEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maMiddleEma)/Point, 0) + "]\n";
      mailBody_trnc = mailBody_trnc + "LongMADis: " + DoubleToStr(((Close[0] - maLongEma) / maLongEma)*100, 3) + "%[" + DoubleToStr((Close[0] - maLongEma)/Point, 0) + "]\n";
      SendMail( mailSubject_trnc, mailBody_trnc );
    }
    // ファイル出力
    if(FileOutput) {
      handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, Symbol(), periodText, direction_trnc, TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ), Time[0]);
      FileClose(handle);
    }

    lastAlert_trnc = Time[0];
    lastAlertZigzag_trnc = zigzag2;
  }

  return(0);
}
