#property copyright "Copyright(C) 2021 Studiogadget Inc."

#property indicator_chart_window

extern string ZigZagSetting = "/////// ZigZagSetting ///////";
extern ENUM_TIMEFRAMES ZigzagTimeframe = PERIOD_CURRENT;
extern int Depth = 7;
extern int Deviation = 5;
extern int Backstep = 1;
extern string MovingAverageSetting = "/////// MovingAverageSetting ///////";
extern ENUM_TIMEFRAMES MATimeframe = PERIOD_CURRENT;
extern int MACurrentPeriod = 20;
extern int MAMiddlePeriod = 80;
extern int MALongPeriod = 320;
extern string EntrySetting = "/////// EntrySetting ///////";
extern int EntryRequirementCount = 3;
extern bool Entry = false;
extern double Lots = 0.01;
extern int Magic = 123;
extern double TPPerSL = 1.0;
extern double FiboPercentMin = 0.0;
extern double FiboPercentMax = 100.0;

datetime lastAlert = 0;
datetime lastError = 0;
double lastAlertZigzag;
int period;
string periodText;

void OnInit() {
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

void OnTick() {
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
  int ticket;
  double sl;
  double tp;
  double calcTpPerSl;
  double sl2;
  double tp2;
  double calcTp2PerSl2;
  double fiboPercent;

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
  // YK_S、YK_M、YK_L
  requirement = 0;
  // Long
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3
    && zigzag1 >= zigzag3) {
    if(zigzag3 < maCurrentSma3 && zigzag3 < maCurrentEma3 && zigzag2 > maCurrentSma2 && zigzag2 > maCurrentEma2
      && zigzag1 < maCurrentSma && zigzag1 < maCurrentEma
      && iClose( Symbol(), MATimeframe, 1 ) > iOpen( Symbol(), MATimeframe, 1 ) // 陽線
      && iClose( Symbol(), MATimeframe, 1 ) > maCurrentSma && iClose( Symbol(), MATimeframe, 1 ) > maCurrentEma
      && zigzag1 != iLow( Symbol(), MATimeframe, 0 ) ) {

      if(zigzag3 < maMiddleSma3 && zigzag3 < maMiddleEma3 && zigzag2 > maMiddleSma2 && zigzag2 > maMiddleEma2
        && zigzag1 < maMiddleSma && zigzag1 < maMiddleEma) {
        if(zigzag3 < maLongSma3 && zigzag3 < maLongEma3 && zigzag2 > maLongSma2 && zigzag2 > maLongEma2
          && zigzag1 < maLongSma && zigzag1 < maLongEma) {
          alertText = alertText + "Long_YK_L " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Long_YK_L] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "long_yk_l";
        } else {
          alertText = alertText + "Long_YK_M " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Long_YK_M] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "long_yk_m";
        }
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
      && iClose( Symbol(), MATimeframe, 1 ) < iOpen( Symbol(), MATimeframe, 1 ) // 陰線
      && iClose( Symbol(), MATimeframe, 1 ) < maCurrentSma && iClose( Symbol(), MATimeframe, 1 ) < maCurrentEma
      && zigzag1 != iHigh( Symbol(), MATimeframe, 0 ) ) {

      if(zigzag3 > maMiddleSma3 && zigzag3 > maMiddleEma3 && zigzag2 < maMiddleSma2 && zigzag2 < maMiddleEma2
        && zigzag1 > maMiddleSma && zigzag1 > maMiddleEma) {
        if(zigzag3 > maLongSma3 && zigzag3 > maLongEma3 && zigzag2 < maLongSma2 && zigzag2 < maLongEma2
          && zigzag1 > maLongSma && zigzag1 > maLongEma) {
          alertText = alertText + "Short_YK_L " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Short_YK_L] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "short_yk_l";
        } else {
          alertText = alertText + "Short_YK_M " + Symbol() + " " + periodText + "\n";
          alertText = alertText + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // 時間
          mailSubject = "[Short_YK_M] " + Symbol() + " " + periodText + " " + Time[0];
          direction = "short_yk_m";
        }
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

  // 条件を満たした数によってエントリー
  // YK_S、YK_M、YK_L
  if(StringLen( alertText ) > 0 && lastAlert != Time[0] && lastAlertZigzag != zigzag2) {
    if(Entry) {
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      fiboPercent = (lengthPoints12 / lengthPoints23) * 100;

      if(fiboPercent >= FiboPercentMin && fiboPercent <= FiboPercentMax) {
        if(StringFind( alertText, "Long_YK", 0 ) >= 0) {
          sl = Ask - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 ); // C1
          tp = Ask + MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ); // C2
          calcTpPerSl = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 );
          if(calcTpPerSl >= TPPerSL) {
            ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, sl, tp, "", Magic, 0, Blue );
            if(ticket < 0) {
              if(lastError != Time[0]) {
                Print( "ERROR Buy_1 YK" );
                Print( GetLastError() );
                lastError = Time[0];
              }
            } else {
              Print( "Buy_1 YK [" + calcTpPerSl + "]");
              lastAlert = Time[0];
              lastAlertZigzag = zigzag2;
            }
          } else {
            if(lastError != Time[0]) {
              Print("Skip Buy_1 YK [" + calcTpPerSl + "]");
              lastError = Time[0];
            }
          }

          sl2 = Ask - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 ); // C1
          tp2 = Ask + MathAbs(MathAbs( zigzag2 - zigzag3 ) - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 )); // 23-C1
          calcTp2PerSl2 = MathAbs(MathAbs( zigzag2 - zigzag3 ) - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 )) / MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 );
          if(calcTp2PerSl2 >= TPPerSL) {
            ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, sl2, tp2, "", Magic, 0, Blue );
            if(ticket < 0) {
              if(lastError != Time[0]) {
                Print( "ERROR Buy_2 YK" );
                Print( GetLastError() );
                lastError = Time[0];
              }
            } else {
              Print( "Buy_2 YK [" + calcTp2PerSl2 + "]");
              lastAlert = Time[0];
              lastAlertZigzag = zigzag2;
            }
          } else {
            if(lastError != Time[0]) {
              Print("Skip Buy_2 YK [" + calcTp2PerSl2 + "]");
              lastError = Time[0];
            }
          }
        } else if(StringFind( alertText, "Short_YK", 0 ) >= 0) {
          sl = Bid + MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 ); // C1
          tp = Bid - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ); // C2
          calcTpPerSl = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 );
          if(calcTpPerSl >= TPPerSL) {
            ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, sl, tp, "", Magic, 0, Red );
            if(ticket < 0) {
              if(lastError != Time[0]) {
                Print( "ERROR Sell_1 YK" );
                Print( GetLastError() );
                lastError = Time[0];
              }
            } else {
              Print( "Sell_1 YK [" + calcTpPerSl + "]");
              lastAlert = Time[0];
              lastAlertZigzag = zigzag2;
            }
          } else {
            if(lastError != Time[0]) {
              Print("Skip Sell_1 YK [" + calcTpPerSl + "]");
              lastError = Time[0];
            }
          }
          sl2 = Bid + MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 ); // C1
          tp2 = Bid - MathAbs(MathAbs( zigzag2 - zigzag3 ) - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 )); // 23-C1
          calcTp2PerSl2 = MathAbs(MathAbs( zigzag2 - zigzag3 ) - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 )) / MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag1 );
          if(calcTp2PerSl2 >= TPPerSL) {
            ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, sl2, tp2, "", Magic, 0, Red );
            if(ticket < 0) {
              if(lastError != Time[0]) {
                Print( "ERROR Sell_2 YK" );
                Print( GetLastError() );
                lastError = Time[0];
              }
            } else {
              Print( "Sell_2 YK [" + calcTp2PerSl2 + "]");
              lastAlert = Time[0];
              lastAlertZigzag = zigzag2;
            }
          } else {
            if(lastError != Time[0]) {
              Print("Skip Sell_2 YK [" + calcTp2PerSl2 + "]");
              lastError = Time[0];
            }
          }
        }
      }
    }
  }

  return(0);
}
