#property copyright "Copyright(C) 2021 Studiogadget Inc."

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
extern double FiboPercentMin = 31.8;
extern double FiboPercentMax = 68.2;

datetime lastAlert_nc_hstr = 0;
double lastAlertZigzag_nc_hstr;
datetime lastAlert_nc_mwhs = 0;
double lastAlertZigzag_nc_mwhs;
datetime lastAlert_nc_mwhstr = 0;
double lastAlertZigzag_nc_mwhstr;
datetime lastAlert_trnc = 0;
datetime lastError_trnc = 0;
double lastAlertZigzag_trnc;
datetime lastAlert_nc_elhstr = 0;
double lastAlertZigzag_nc_elhstr;
datetime lastAlert_nc_elmwhs = 0;
double lastAlertZigzag_nc_elmwhs;
datetime lastAlert_nc_elmwhstr = 0;
double lastAlertZigzag_nc_elmwhstr;
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
  double zigzag5;
  double zigzag6;
  double zigzag7;
  double zigzag8;
  double zigzag9;
  double macd1;
  double macd2;
  double macd3;
  double macd4;
  double macd5;
  double macd7;
  double rsi1;
  double rsi2;
  double maCurrentEma;
  double maCurrentSma;
  double maMiddleEma;
  double maMiddleSma;
  double maLongEma;
  double maLongSma;
  int i;
  int cnt;
  int requirement_nc_mwhs;
  string alertText_nc_mwhs;
  string mailSubject_nc_mwhs;
  string mailBody_nc_mwhs;
  string direction_nc_mwhs;
  string macdRsi_nc_mwhs;
  int requirement_nc_mwhstr;
  string alertText_nc_mwhstr;
  string mailSubject_nc_mwhstr;
  string mailBody_nc_mwhstr;
  string direction_nc_mwhstr;
  string macdRsi_nc_mwhstr;
  int requirement_nc_hstr;
  string alertText_nc_hstr;
  string mailSubject_nc_hstr;
  string mailBody_nc_hstr;
  string direction_nc_hstr;
  string macdRsi_nc_hstr;
  int requirement_trnc;
  string alertText_trnc;
  string mailSubject_trnc;
  string mailBody_trnc;
  string direction_trnc;
  string macdRsi_trnc;
  int requirement_nc_elmwhs;
  string alertText_nc_elmwhs;
  string mailSubject_nc_elmwhs;
  string mailBody_nc_elmwhs;
  string direction_nc_elmwhs;
  string macdRsi_nc_elmwhs;
  int requirement_nc_elmwhstr;
  string alertText_nc_elmwhstr;
  string mailSubject_nc_elmwhstr;
  string mailBody_nc_elmwhstr;
  string direction_nc_elmwhstr;
  string macdRsi_nc_elmwhstr;
  int requirement_nc_elhstr;
  string alertText_nc_elhstr;
  string mailSubject_nc_elhstr;
  string mailBody_nc_elhstr;
  string direction_nc_elhstr;
  string macdRsi_nc_elhstr;
  int ticket;
  double sl;
  double tp;
  double calcTpPerSl;
  double sl2;
  double tp2;
  double calcTp2PerSl2;
  double fiboPercent;
  double lengthPoints12;
  double lengthPoints23;

  // ZigZag??????
  cnt = 0;
  for(i=0; i<iBars( Symbol(), ZigzagTimeframe); i++) {
    zigzagTmp = iCustom(Symbol(), ZigzagTimeframe, "ZigZag", Depth, Deviation, Backstep, 0, i);
    if(cnt == 0 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag1 = zigzagTmp;
      macd1 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      rsi1 = iRSI( Symbol(), ZigzagTimeframe, 20, PRICE_CLOSE, i );
      cnt = 1;
    } else if(cnt == 1 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag2 = zigzagTmp;
      macd2 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      rsi2 = iRSI( Symbol(), ZigzagTimeframe, 20, PRICE_CLOSE, i );
      cnt = 2;
    } else if(cnt == 2 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag3 = zigzagTmp;
      macd3 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 3;
    } else if(cnt == 3 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag4 = zigzagTmp;
      macd4 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 4;
    } else if(cnt == 4 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag5 = zigzagTmp;
      macd5 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 5;
    } else if(cnt == 5 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag6 = zigzagTmp;
      cnt = 6;
    } else if(cnt == 6 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag7 = zigzagTmp;
      macd7 = iMACD( Symbol(), ZigzagTimeframe, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i );
      cnt = 7;
    } else if(cnt == 7 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag8 = zigzagTmp;
      cnt = 8;
    } else if(cnt == 8 && zigzagTmp != EMPTY_VALUE && zigzagTmp != 0) {
      zigzag9 = zigzagTmp;
      cnt = 9;
      break;
    }
  }

  // ??????
  // ST_TR_NC
  requirement_trnc = 0;
  // Long_ST_TR_NC
  if(zigzag1 < zigzag2 && zigzag2 > zigzag3 && zigzag3 < zigzag4 && zigzag4 > zigzag5
     && zigzag2 >= zigzag4 && zigzag3 >= zigzag5 && zigzag1 > zigzag3
     && iOpen(Symbol(), ZigzagTimeframe, 1) < zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) >= zigzag4) {
    alertText_trnc = alertText_trnc + "Long_ST_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_trnc = alertText_trnc + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // ??????
    mailSubject_trnc = "[Long_ST_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "long_st_tr_nc";
    // MovingAverage??????
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma > maMiddleEma && maMiddleEma > maLongEma) {
      alertText_trnc = alertText_trnc + "???ALL EMA: Golden Cross" + "\n";
    }
    if(maMiddleEma < maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "???EMA: Golden Cross" + "\n";
    }
    if(maCurrentSma < maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "???Short MA: Golden Cross" + "\n";
    }
    if(maMiddleSma < maMiddleEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "???Middle MA: Golden Cross" + "\n";
    }
    if(maLongSma < maLongEma) {
      alertText_trnc = alertText_trnc + "???Long MA: Golden Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi_trnc = macdRsi_trnc + "Div: Long";
    } else {
      macdRsi_trnc = macdRsi_trnc + "Div: Short";
    }
  }
  // Short_ST_TR_NC
  if(zigzag1 > zigzag2 && zigzag2 < zigzag3 && zigzag3 > zigzag4 && zigzag4 < zigzag5
     && zigzag2 <= zigzag4 && zigzag3 <= zigzag5 && zigzag1 < zigzag3
     && iOpen(Symbol(), ZigzagTimeframe, 1) > zigzag4 && iClose(Symbol(), ZigzagTimeframe, 1) <= zigzag4) {
    alertText_trnc = alertText_trnc + "Short_ST_TR_NC " + Symbol() + " " + periodText + "\n";
    alertText_trnc = alertText_trnc + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) + " (" + TimeToStr( Time[0], TIME_DATE|TIME_MINUTES ) + ")\n"; // ??????
    mailSubject_trnc = "[Short_ST_TR_NC] " + Symbol() + " " + periodText + " " + Time[0];
    direction_trnc = "Short_ST_tr_nc";
    // MovingAverage??????
    maCurrentSma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maCurrentEma = iMA( Symbol(), MATimeframe, MACurrentPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maMiddleSma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maMiddleEma = iMA( Symbol(), MATimeframe, MAMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );
    maLongSma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
    maLongEma = iMA( Symbol(), MATimeframe, MALongPeriod, 0, MODE_EMA, PRICE_CLOSE, 1 );

    if(maCurrentEma < maMiddleEma && maMiddleEma < maLongEma) {
      alertText_trnc = alertText_trnc + "???ALL EMA: Dead Cross" + "\n";
    }
    if(maMiddleEma > maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "???EMA: Dead Cross" + "\n";
    }
    if(maCurrentSma > maCurrentEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "???Short MA: Dead Cross" + "\n";
    }
    if(maMiddleSma > maMiddleEma) {
      requirement_trnc++;
      alertText_trnc = alertText_trnc + "???Middle MA: Dead Cross" + "\n";
    }
    if(maLongSma > maLongEma) {
      alertText_trnc = alertText_trnc + "???Long MA: Dead Cross" + "\n";
    }

    if(macd2 > macd4) {
      macdRsi_trnc = macdRsi_trnc + "Div: Long";
    } else {
      macdRsi_trnc = macdRsi_trnc + "Div: Short";
    }
  }


  // ???????????????????????????????????????????????????
  // ST_TR_NC
  if(StringLen(alertText_trnc) > 0 && requirement_trnc >= EntryRequirementCount && lastAlert_trnc != Time[0] && lastAlertZigzag_trnc != zigzag2) {
    if(Entry) {
      lengthPoints12 = MathAbs( zigzag1 - zigzag2 ) / Point();
      lengthPoints23 = MathAbs( zigzag2 - zigzag3 ) / Point();
      fiboPercent = (lengthPoints12 / lengthPoints23) * 100;

      if(fiboPercent >= FiboPercentMin && fiboPercent <= FiboPercentMax) {
        if(StringFind( alertText_trnc, "Long_ST_TR_NC", 0 ) >= 0) {
          sl = Ask - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ); // 1c3
          tp = Ask + MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ); // 1c2
          calcTpPerSl = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 );
          if(calcTpPerSl >= TPPerSL) {
            ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, sl, tp, "", Magic, 0, Blue );
            if(ticket < 0) {
              if(lastError_trnc != Time[0]) {
                Print( "ERROR Buy_1 ST_TR_NC" );
                Print( GetLastError() );
                lastError_trnc = Time[0];
              }
            } else {
              Print( "Buy_1 ST_TR_NC [" + calcTpPerSl + "]");
              lastAlert_trnc = Time[0];
              lastAlertZigzag_trnc = zigzag2;
            }
          } else {
            if(lastError_trnc != Time[0]) {
              Print("Skip Buy_1 ST_TR_NC [" + calcTpPerSl + "]");
              lastError_trnc = Time[0];
            }
          }

          sl2 = Ask - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ); // 1c3
          tp2 = Ask + MathAbs( zigzag2 - zigzag5 ); // 25
          if(calcTpPerSl >= TPPerSL) { // ?????????sl1???tp1?????????
            ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, sl2, tp2, "", Magic, 0, Blue );
            if(ticket < 0) {
              if(lastError_trnc != Time[0]) {
                Print( "ERROR Buy_2 ST_TR_NC" );
                Print( GetLastError() );
                lastError_trnc = Time[0];
              }
            } else {
              Print( "Buy_2 ST_TR_NC [" + calcTp2PerSl2 + "]");
              lastAlert_trnc = Time[0];
              lastAlertZigzag_trnc = zigzag2;
            }
          } else {
            if(lastError_trnc != Time[0]) {
              Print("Skip Buy_2 ST_TR_NC [" + calcTp2PerSl2 + "]");
              lastError_trnc = Time[0];
            }
          }
        } else if(StringFind( alertText_trnc, "Short_ST_TR_NC", 0 ) >= 0) {
          sl = Bid + MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ); // 1c3
          tp = Bid - MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ); // 1c2
          calcTpPerSl = MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag2 ) / MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 );
          if(calcTpPerSl >= TPPerSL) {
            ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, sl, tp, "", Magic, 0, Red );
            if(ticket < 0) {
              if(lastError_trnc != Time[0]) {
                Print( "ERROR Sell_1 ST_TR_NC" );
                Print( GetLastError() );
                lastError_trnc = Time[0];
              }
            } else {
              Print( "Sell_1 ST_TR_NC [" + calcTpPerSl + "]");
              lastAlert_trnc = Time[0];
              lastAlertZigzag_trnc = zigzag2;
            }
          } else {
            if(lastError_trnc != Time[0]) {
              Print("Skip Sell_1 ST_TR_NC [" + calcTpPerSl + "]");
              lastError_trnc = Time[0];
            }

          }

          sl2 = Bid + MathAbs( iClose(Symbol(), ZigzagTimeframe, 1) - zigzag3 ); // 1c3
          tp2 = Bid - MathAbs( zigzag2 - zigzag5 ); // 25
          if(calcTpPerSl >= TPPerSL) { // ?????????sl1???tp1?????????
            ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, sl2, tp2, "", Magic, 0, Red );
            if(ticket < 0) {
              if(lastError_trnc != Time[0]) {
                Print( "ERROR Sell_2 ST_TR_NC" );
                Print( GetLastError() );
                lastError_trnc = Time[0];
              }
            } else {
              Print( "Sell_2 ST_TR_NC [" + calcTp2PerSl2 + "]");
              lastAlert_trnc = Time[0];
              lastAlertZigzag_trnc = zigzag2;
            }
          } else {
            if(lastError_trnc != Time[0]) {
              Print("Skip Sell_2 ST_TR_NC [" + calcTp2PerSl2 + "]");
              lastError_trnc = Time[0];
            }

          }
        }
      }
    }
  }

  return(0);
}
