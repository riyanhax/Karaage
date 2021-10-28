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
  double maCurrentEma;
  double maCurrentSma;
  double maCurrentEma2;
  double maCurrentSma2;
  double maCurrentEma3;
  double maCurrentSma3;
  double maMiddleEma;
  double maMiddleSma;
  double maMiddleEma2;
  double maMiddleSma2;
  double maMiddleEma3;
  double maMiddleSma3;
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
  double lengthPoints12;
  double lengthPoints23;
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
      maMiddleSma2 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maMiddleEma2 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
      cnt = 2;
    } else if(cnt == 2 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag3 = zigzagTmp;
      maCurrentSma3 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, i );
      maCurrentEma3 = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, i );
      maMiddleSma3 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
      maMiddleEma3 = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
      cnt = 3;
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
  requirement = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3) {
    if(zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3 && zigzag2 > maCurrentSma2 && zigzag2 > maCurrentEma2
      && zigzag1 < maCurrentSma && zigzag1 < maCurrentEma
      && iClose( Symbol(), MACurrentPeriod, 0 ) > maCurrentSma && iClose( Symbol(), MACurrentPeriod, 0 ) > maCurrentEma) {

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
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3) {
    if(zigzag3 > maCurrentSma3 && zigzag3 > maCurrentEma3 && zigzag2 < maCurrentSma2 && zigzag2 < maCurrentEma2
      && zigzag1 > maCurrentSma && zigzag1 > maCurrentEma
      && iClose( Symbol(), MACurrentPeriod, 0 ) < maCurrentSma && iClose( Symbol(), MACurrentPeriod, 0 ) < maCurrentEma) {

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
  if(StringLen( alertText ) > 0 && requirement >= AlertRequirementCount && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    Alert(alertText);
    if(MailAlert) {
      mailBody = mailBody + alertText; // ロング or ショート、通貨ペア、時間足
      mailBody = mailBody + "Price: " + Close[0] + "\n";
      //mailBody = mailBody + "Zigzag: " + zigzag2 + ", " + zigzag3 + ", " + zigzag4 + "\n";
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
      //mailBody = mailBody + "MaxE3Points: " + DoubleToStr( lengthPoints34*1.618, 0 ) + " [" + DoubleToStr( lengthPoints34*1.618 - lengthPoints12, 0 ) + "]\n";
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
