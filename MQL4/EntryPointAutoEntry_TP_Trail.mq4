#property copyright "Copyright(C) 2021 Studiogadget Inc."

enum trailingMethod {
  Parabolic = 0,
  TrendLine = 1,
};

enum trendSetting {
  None_ = 0,
  TrendFollow = 1,
  TrendAgainst = 2,
  Detail = 3,
};

enum trend {
  None = 0,
  Follow = 1,
  Against = 2,
};

extern string Explanation1 = "/////// ENTRY SETTINGS ///////";
extern int TPMagic = 120;
extern string TPComm = "Entry Point Auto TP";
extern int BalanceParLot = 20000;
extern int MaxSpreadPoints = 6;
extern bool Delay = false;
extern int DelayPercent = 20;
extern bool Reverse = false; // 逆に動いている場合にエントリーする
extern bool StopEntry = false;
extern int LimitCandle = 1;
extern double TPx = 1.0;
extern double SLx = 1.0;
extern bool ManualSL = false;
extern int SLPoints = 0;
extern bool ReverseEntry = false; // BuyとSellを逆にする
extern string Explanation2 = "/////// TRAILING SETTINGS ///////";
extern bool TrailEntry = true;
extern int TrailMagic = 130;
extern string TrailComm = "Entry Point Auto Trail";
extern trailingMethod Method = TrendLine;
extern double ParabolicStep = 0.02;
extern double ParabolicMax = 0.2;
extern int TPPoints = 0;
extern string Explanation3 = "/////// EA (EntryPointPro) SETTINGS ///////";
extern int MaxSizeOfSignalCandlePoints = 1000;
extern bool UseDEMA = false;
extern string StartTime = "00:00";
extern string EndTime = "23:59";
extern string Explanation4 = "/////// TREND SETTINGS ///////";
extern trendSetting Trend = None_;
extern string Explanation5 = "↓↓↓ Detail ↓↓↓";
extern trend TrendM1 = None;
extern trend TrendM5 = None;
extern trend TrendM15 = None;
extern trend TrendM30 = None;
extern trend TrendH1 = None;
extern trend TrendH4 = None;
extern trend TrendD1 = None;
extern trend TrendW1 = None;
extern trend TrendMN = None;
extern string Explanation6 = "/////// OTHER SETTINGS ///////";
extern bool BackTest = false;

datetime lastEntry1 = 0;
datetime lastEntry2 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;
datetime lastErrorLog3 = 0;
datetime lastErrorLog4 = 0;
double lots;
bool firstSL = true;

void OnInit(){
  lots = AccountBalance() / BalanceParLot;
}

void OnTick(){
  int ticket;
  int delay;
  int tmp;
  double sl;
  double tp;
  int spread;
  int i;
  int errChk;
  int trailEntryCnt;
  int tpEntryCnt;
  int errCnt;


  // 一定時間経過した逆指値注文を取り消す
  if(StopEntry) {
    if(OrdersTotal() > 0) {
      for(i=0; i<OrdersTotal(); i++){
        if(OrderSelect( i, SELECT_BY_POS) == true){
          if(OrderSymbol() == Symbol() && (OrderMagicNumber() == TPMagic || OrderMagicNumber() == TrailMagic)
            && (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) ){
            if(iBarShift( Symbol(), PERIOD_CURRENT, OrderOpenTime(), false ) >= LimitCandle) {
              while( !IsStopped() ) {
                errChk = 0;
                if(!OrderDelete( OrderTicket(), Green )) {
                  errChk = 1;
                }
                if( errChk == 0 ) {
                  break;
                }
                Print( "StopOrder Delete Failure" );
                Print( GetLastError() );
                Sleep(500);
                RefreshRates();
              }
            }
          }
        }
      }
    }
  }

  if(TrailEntry) {
    // エントリー数をカウント
    tpEntryCnt = 0;
    if(OrdersTotal() > 0) {
      for(i=0; i<OrdersTotal(); i++){
        if(OrderSelect( i, SELECT_BY_POS) == true){
          if(OrderSymbol() == Symbol() && OrderMagicNumber() == TPMagic){
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){
              tpEntryCnt++;
            }
          }
        }
      }
    }
    trailEntryCnt = 0;
    if(OrdersTotal() > 0) {
      for(i=0; i<OrdersTotal(); i++){
        if(OrderSelect( i, SELECT_BY_POS) == true){
          if(OrderSymbol() == Symbol() && OrderMagicNumber() == TrailMagic){
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){
              trailEntryCnt++;
            }
          }
        }
      }
    }
    // トレーリング
    if(trailEntryCnt > 0 && tpEntryCnt == 0){
      // SLを算出
      sl = 0.0;
      if(Method == Parabolic){
        sl = iSAR( Symbol(), PERIOD_CURRENT, ParabolicStep, ParabolicMax, 0 );
      } else if(Method == TrendLine){
        sl = iCustom( Symbol(), PERIOD_CURRENT, "Market\\FX Trend", "", 6, 3.0, "", false, 1.0, true, false, true, true, true, Lime, DeepPink, 0, Black, 5000, "", 0, false, 80.0, false, false, false, false, false, "alert.wav", "", false, false, false, false, false, false, false, false, false, 12, 1 );
        if(sl == EMPTY_VALUE || sl == 0.0){
          sl = iCustom( Symbol(), PERIOD_CURRENT, "Market\\FX Trend", "", 6, 3.0, "", false, 1.0, true, false, true, true, true, Lime, DeepPink, 0, Black, 5000, "", 0, false, 80.0, false, false, false, false, false, "alert.wav", "", false, false, false, false, false, false, false, false, false, 13, 1 );
        }
      }
      // ストップロスを設定
      if(OrdersTotal() > 0) {
        for(i=0; i<OrdersTotal(); i++){
          if(OrderSelect( i, SELECT_BY_POS) == true){
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == TrailMagic){
              if(OrderType() == OP_BUY){
                tp = 0.0;
                if(TPPoints > 0) {
                  tp = Bid + TPPoints * Point;
                }
                if(NormalizeDouble(NormalizeDouble( sl, Digits() ) - NormalizeDouble( OrderStopLoss(), Digits() ), Digits()) > 0){
                  errCnt = 0;
                  while( !IsStopped() ) {
                    errChk = 0;
                    if(firstSL) {
                      if(!OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+(MarketInfo( Symbol(), MODE_SPREAD )+10)*Point, tp, OrderExpiration(), CLR_NONE )) {
                        errChk = 1;
                      } else {
                        firstSL = false;
                      }
                    } else {
                      if(!OrderModify( OrderTicket(), OrderOpenPrice(), sl, tp, OrderExpiration(), CLR_NONE )) {
                        errChk = 1;
                      }
                    }
                    if( errChk == 0 ) {
                      break;
                    }
                    Print( "Order Modify Failure" );
                    Print( GetLastError() );
                    errCnt++;
                    if(errCnt > 5) {
                      return;
                    }
                    Sleep(500);
                    RefreshRates();
                  }
                }
              }
              if(OrderType() == OP_SELL){
                tp = 0.0;
                if(TPPoints > 0) {
                  tp = Ask -TPPoints * Point;
                }
                if(NormalizeDouble(NormalizeDouble( OrderStopLoss(), Digits() ) - NormalizeDouble( sl, Digits() ), Digits()) > 0){
                  errCnt = 0;
                  while( !IsStopped() ) {
                    errChk = 0;
                    if(firstSL) {
                      if(!OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-(MarketInfo( Symbol(), MODE_SPREAD )+10)*Point, tp, OrderExpiration(), CLR_NONE )) {
                        errChk = 1;
                      } else {
                        firstSL = false;
                      }
                    } else {
                      if(!OrderModify( OrderTicket(), OrderOpenPrice(), sl, tp, OrderExpiration(), CLR_NONE )) {
                        errChk = 1;
                      }
                    }
                    if( errChk == 0 ) {
                      break;
                    }
                    Print( "Order Modify Failure" );
                    Print( GetLastError() );
                    errCnt++;
                    if(errCnt > 5) {
                      return;
                    }
                    Sleep(500);
                    RefreshRates();
                  }
                }
              }
            }
          }
        }
      }
    }

    // トレーリング中はエントリーしない
    if(trailEntryCnt > 0) {
      return;
    }
  }


  // 足が変わってからの一定期間(指定%)はエントリーしない場合
  if(Delay) {
    if(DelayPercent == 0) {
      delay = 0;
    } else {
      tmp = 100 / DelayPercent;
      delay = ((Period() * 60) / tmp);
    }
    if(TimeCurrent() < (Time[0] + delay)) {
      return;
    }
  }

  // 同じ足で1回のみ実行
  if(lastEntry1 == Time[0] && (!TrailEntry || lastEntry2 == Time[0])){
    return;
  }

  // パラメータ取得
  double upArrow;
  double downArrow;
  upArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, false, 500, "", true, "", StartTime, EndTime, "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 2, 1 ); // Blue Arrow
  if(upArrow == EMPTY_VALUE || upArrow == 0) {
    downArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, true, 500, "", true, "", StartTime, EndTime, "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 3, 1 ); // Red Arrow
  }
  double trendLineUp;
  double trendLineDown;
  string fxTrendM1;
  string fxTrendM5;
  string fxTrendM15;
  string fxTrendM30;
  string fxTrendH1;
  string fxTrendH4;
  string fxTrendD1;
  string fxTrendW1;
  string fxTrendMN;
  if(Trend == TrendFollow || Trend == TrendAgainst) {
    trendLineUp = iCustom( Symbol(), PERIOD_CURRENT, "Market\\FX Trend", "", 6, 3.0, "", false, 1.0, true, false, true, true, true, Lime, DeepPink, 0, Black, 5000, "", 0, false, 80.0, false, false, false, false, false, "alert.wav", "", false, false, false, false, false, false, false, false, false, 12, 1 );
    trendLineDown = iCustom( Symbol(), PERIOD_CURRENT, "Market\\FX Trend", "", 6, 3.0, "", false, 1.0, true, false, true, true, true, Lime, DeepPink, 0, Black, 5000, "", 0, false, 80.0, false, false, false, false, false, "alert.wav", "", false, false, false, false, false, false, false, false, false, 13, 1 );
  } else if(Trend == Detail) {
    if(BackTest) {
      iCustom( Symbol(), PERIOD_CURRENT, "Market\\FX Trend", "", 6, 3.0, "", false, 1.0, false, true, true, true, true, Lime, DeepPink, 0, Black, 5000, "", 0, false, 80.0, false, false, false, false, false, "alert.wav", "", true, true, true, true, true, true, true, true, true, 12, 1 );
      ChartRedraw(0);
    }
    fxTrendM1 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend1" ) ) ) ;
    fxTrendM5 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend2" ) ) );
    fxTrendM15 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend3" ) ) );
    fxTrendM30 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend4" ) ) );
    fxTrendH1 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend5" ) ) );
    fxTrendH4 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend6" ) ) );
    fxTrendD1 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend7" ) ) );
    fxTrendW1 = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend8" ) ) );
    fxTrendMN = StringTrimRight( StringTrimLeft( ObjectDescription( "FXTtrend9" ) ) );
  }

  // TP Buy
  if(upArrow != EMPTY_VALUE && upArrow != 0 && lastEntry1 != Time[0]) {
    if(Reverse && Close[0] >= Open[0]) {
      if(lastErrorLog3 != Time[0]) {
        Print( "SKIP Buy [Open:" + Open[0] + " <= Current:" + Close[0] + "]" );
        lastErrorLog3 = Time[0];
        return;
      }
    }
    spread = MarketInfo( Symbol(), MODE_SPREAD );
    if(spread > MaxSpreadPoints) {
      if(lastErrorLog2 != Time[0]) {
        Print( "SKIP Buy [SpreadPoints = " + spread + "]" );
        lastErrorLog2 = Time[0];
      }
      return;
    }
    if(Trend == TrendFollow) {
      if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
        Print( "SKIP Buy [Trend Down]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == TrendAgainst) {
      if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
        Print( "SKIP Buy [Trend Up]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == Detail){
      if(lastErrorLog4 != Time[0]) {
        Print( "Buy M1=" + fxTrendM1 + ", M5=" + fxTrendM5 + ", M15=" + fxTrendM15 + ", M30=" + fxTrendM30 + ", H1=" + fxTrendH1 + ", H4=" + fxTrendH4 + ", D1=" + fxTrendD1 + ", W1=" + fxTrendW1 + ", MN=" + fxTrendMN );
        lastErrorLog4 = Time[0];
      }
      // M1
      if(TrendM1 == Follow) {
        if(fxTrendM1 != "BUY") {
          return;
        }
      } else if(TrendM1 == Against) {
        if(fxTrendM1 != "SELL") {
          return;
        }
      }
      // M5
      if(TrendM5 == Follow) {
        if(fxTrendM5 != "BUY") {
          return;
        }
      } else if(TrendM5 == Against) {
        if(fxTrendM5 != "SELL") {
          return;
        }
      }
      // M15
      if(TrendM15 == Follow) {
        if(fxTrendM15 != "BUY") {
          return;
        }
      } else if(TrendM15 == Against) {
        if(fxTrendM15 != "SELL") {
          return;
        }
      }
      // M30
      if(TrendM30 == Follow) {
        if(fxTrendM30 != "BUY") {
          return;
        }
      } else if(TrendM30 == Against) {
        if(fxTrendM30 != "SELL") {
          return;
        }
      }
      // H1
      if(TrendH1 == Follow) {
        if(fxTrendH1 != "BUY") {
          return;
        }
      } else if(TrendH1 == Against) {
        if(fxTrendH1 != "SELL") {
          return;
        }
      }
      // H4
      if(TrendH4 == Follow) {
        if(fxTrendH4 != "BUY") {
          return;
        }
      } else if(TrendH4 == Against) {
        if(fxTrendH4 != "SELL") {
          return;
        }
      }
      // D1
      if(TrendD1 == Follow) {
        if(fxTrendD1 != "BUY") {
          return;
        }
      } else if(TrendD1 == Against) {
        if(fxTrendD1 != "SELL") {
          return;
        }
      }
      // W1
      if(TrendW1 == Follow) {
        if(fxTrendW1 != "BUY") {
          return;
        }
      } else if(TrendW1 == Against) {
        if(fxTrendW1 != "SELL") {
          return;
        }
      }
      // MN
      if(TrendMN == Follow) {
        if(fxTrendMN != "BUY") {
          return;
        }
      } else if(TrendMN == Against) {
        if(fxTrendMN != "SELL") {
          return;
        }
      }
    }

    if(ReverseEntry) {
      if(ManualSL) {
        if(SLPoints > 0) {
          if(StopEntry) {
            sl = Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point + SLPoints*Point;
          } else {
            sl = Bid + SLPoints*Point;
          }
        } else {
          sl = 0;
        }
      } else {
        if(StopEntry) {
          sl = Low[1] + (High[1] - upArrow)*SLx;
        } else {
          sl = Bid + (Ask - upArrow)*SLx;
        }
      }
      tp = Bid - (Ask - upArrow)*TPx;
    } else {
      if(ManualSL) {
        if(SLPoints > 0) {
          if(StopEntry) {
            sl = High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point - SLPoints*Point;
          } else {
            sl = Ask - SLPoints*Point;
          }
        } else {
          sl = 0;
        }
      } else {
        if(StopEntry) {
          sl = High[1] - (High[1] - upArrow)*SLx;
        } else {
          sl = Ask - (Ask - upArrow)*SLx;
        }
      }
      tp = Ask + (Ask - upArrow)*TPx;
    }
    // entry 1
    if(StopEntry) {
      if(ReverseEntry) {
        ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TPComm, TPMagic, 0, Red );
      } else {
        ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TPComm, TPMagic, 0, Blue );
      }
    } else {
      if(ReverseEntry) {
        ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, TPComm, TPMagic, 0, Red );
      } else {
        ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, TPComm, TPMagic, 0, Blue );
      }
    }
    if(ticket < 0) {
      if(lastErrorLog1 != Time[0]) {
        Print( "ERROR Buy [" + TimeToStr( Time[0] ) + "]" );
        Print( GetLastError() );
        lastErrorLog1 = Time[0];
      }
      return;
    } else {
      Print( "SUCCESS Buy [" + TimeToStr( Time[0] ) + "]" );
      lastEntry1 = Time[0];
    }
  }
  // Trail Buy
  if(TrailEntry) {
    if(upArrow != EMPTY_VALUE && upArrow != 0 && lastEntry2 != Time[0]) {
      if(Reverse && Close[0] >= Open[0]) {
        if(lastErrorLog3 != Time[0]) {
          Print( "SKIP Buy [Open:" + Open[0] + " <= Current:" + Close[0] + "]" );
          lastErrorLog3 = Time[0];
          return;
        }
      }
      spread = MarketInfo( Symbol(), MODE_SPREAD );
      if(spread > MaxSpreadPoints) {
        if(lastErrorLog2 != Time[0]) {
          Print( "SKIP Buy [SpreadPoints = " + spread + "]" );
          lastErrorLog2 = Time[0];
        }
        return;
      }
      if(Trend == TrendFollow) {
        if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
          Print( "SKIP Buy [Trend Down]" );
          lastEntry1 = Time[0];
          lastEntry2 = Time[0];
          return;
        }
      } else if(Trend == TrendAgainst) {
        if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
          Print( "SKIP Buy [Trend Up]" );
          lastEntry1 = Time[0];
          lastEntry2 = Time[0];
          return;
        }
      } else if(Trend == Detail){
        if(lastErrorLog4 != Time[0]) {
          Print( "Buy M1=" + fxTrendM1 + ", M5=" + fxTrendM5 + ", M15=" + fxTrendM15 + ", M30=" + fxTrendM30 + ", H1=" + fxTrendH1 + ", H4=" + fxTrendH4 + ", D1=" + fxTrendD1 + ", W1=" + fxTrendW1 + ", MN=" + fxTrendMN );
          lastErrorLog4 = Time[0];
        }
        // M1
        if(TrendM1 == Follow) {
          if(fxTrendM1 != "BUY") {
            return;
          }
        } else if(TrendM1 == Against) {
          if(fxTrendM1 != "SELL") {
            return;
          }
        }
        // M5
        if(TrendM5 == Follow) {
          if(fxTrendM5 != "BUY") {
            return;
          }
        } else if(TrendM5 == Against) {
          if(fxTrendM5 != "SELL") {
            return;
          }
        }
        // M15
        if(TrendM15 == Follow) {
          if(fxTrendM15 != "BUY") {
            return;
          }
        } else if(TrendM15 == Against) {
          if(fxTrendM15 != "SELL") {
            return;
          }
        }
        // M30
        if(TrendM30 == Follow) {
          if(fxTrendM30 != "BUY") {
            return;
          }
        } else if(TrendM30 == Against) {
          if(fxTrendM30 != "SELL") {
            return;
          }
        }
        // H1
        if(TrendH1 == Follow) {
          if(fxTrendH1 != "BUY") {
            return;
          }
        } else if(TrendH1 == Against) {
          if(fxTrendH1 != "SELL") {
            return;
          }
        }
        // H4
        if(TrendH4 == Follow) {
          if(fxTrendH4 != "BUY") {
            return;
          }
        } else if(TrendH4 == Against) {
          if(fxTrendH4 != "SELL") {
            return;
          }
        }
        // D1
        if(TrendD1 == Follow) {
          if(fxTrendD1 != "BUY") {
            return;
          }
        } else if(TrendD1 == Against) {
          if(fxTrendD1 != "SELL") {
            return;
          }
        }
        // W1
        if(TrendW1 == Follow) {
          if(fxTrendW1 != "BUY") {
            return;
          }
        } else if(TrendW1 == Against) {
          if(fxTrendW1 != "SELL") {
            return;
          }
        }
        // MN
        if(TrendMN == Follow) {
          if(fxTrendMN != "BUY") {
            return;
          }
        } else if(TrendMN == Against) {
          if(fxTrendMN != "SELL") {
            return;
          }
        }
      }

      if(ReverseEntry) {
        if(ManualSL) {
          if(SLPoints > 0) {
            if(StopEntry) {
              sl = Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point + SLPoints*Point;
            } else {
              sl = Bid + SLPoints*Point;
            }
          } else {
            sl = 0;
          }
        } else {
          if(StopEntry) {
            sl = High[1] + (High[1] - upArrow)*SLx;
          } else {
            sl = Bid + (Ask - upArrow)*SLx;
          }
        }
      } else {
        if(ManualSL) {
          if(SLPoints > 0) {
            if(StopEntry) {
              sl = High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point - SLPoints*Point;
            } else {
              sl = Ask - SLPoints*Point;
            }
          } else {
            sl = 0;
          }
        } else {
          if(StopEntry) {
            sl = High[1] - (High[1] - upArrow)*SLx;
          } else {
            sl = Ask - (Ask - upArrow)*SLx;
          }
        }
      }
      // entry 2
      if(StopEntry) {
        if(ReverseEntry) {
          ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TrailComm, TrailMagic, 0, Red );
        } else {
          ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TrailComm, TrailMagic, 0, Blue );
        }
      } else {
        if(ReverseEntry) {
          ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, 0, TrailComm, TrailMagic, 0, Red );
        } else {
          ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, 0, TrailComm, TrailMagic, 0, Blue );
        }
      }
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]) {
          Print( "ERROR Buy [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
        return;
      } else {
        Print( "SUCCESS Buy [" + TimeToStr( Time[0] ) + "]" );
        lastEntry2 = Time[0];
        firstSL = true;
      }
    }
  }

  // TP Sell
  if(downArrow != EMPTY_VALUE && downArrow != 0 && lastEntry1 != Time[0]) {
    if(Reverse && Close[0] <= Open[0]) {
      if(lastErrorLog3 != Time[0]) {
        Print( "SKIP Sell [Current:" + Close[0] + " <= Open:" + Open[0] + "]" );
        lastErrorLog3 = Time[0];
        return;
      }
    }
    spread = MarketInfo( Symbol(), MODE_SPREAD );
    if(spread > MaxSpreadPoints) {
      if(lastErrorLog2 != Time[0]) {
        Print( "SKIP Sell [SpreadPoints = " + spread + "]" );
        lastErrorLog2 = Time[0];
      }
      return;
    }
    if(Trend == TrendFollow) {
      if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
        Print( "SKIP Sell [Trend Up]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == TrendAgainst) {
      if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
        Print( "SKIP Sell [Trend Sell]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == Detail){
      if(lastErrorLog4 != Time[0]) {
        Print( "Sell M1=" + fxTrendM1 + ", M5=" + fxTrendM5 + ", M15=" + fxTrendM15 + ", M30=" + fxTrendM30 + ", H1=" + fxTrendH1 + ", H4=" + fxTrendH4 + ", D1=" + fxTrendD1 + ", W1=" + fxTrendW1 + ", MN=" + fxTrendMN );
        lastErrorLog4 = Time[0];
      }
      // M1
      if(TrendM1 == Follow) {
        if(fxTrendM1 != "SELL") {
          return;
        }
      } else if(TrendM1 == Against) {
        if(fxTrendM1 != "BUY") {
          return;
        }
      }
      // M5
      if(TrendM5 == Follow) {
        if(fxTrendM5 != "SELL") {
          return;
        }
      } else if(TrendM5 == Against) {
        if(fxTrendM5 != "BUY") {
          return;
        }
      }
      // M15
      if(TrendM15 == Follow) {
        if(fxTrendM15 != "SELL") {
          return;
        }
      } else if(TrendM15 == Against) {
        if(fxTrendM15 != "BUY") {
          return;
        }
      }
      // M30
      if(TrendM30 == Follow) {
        if(fxTrendM30 != "SELL") {
          return;
        }
      } else if(TrendM30 == Against) {
        if(fxTrendM30 != "BUY") {
          return;
        }
      }
      // H1
      if(TrendH1 == Follow) {
        if(fxTrendH1 != "SELL") {
          return;
        }
      } else if(TrendH1 == Against) {
        if(fxTrendH1 != "BUY") {
          return;
        }
      }
      // H4
      if(TrendH4 == Follow) {
        if(fxTrendH4 != "SELL") {
          return;
        }
      } else if(TrendH4 == Against) {
        if(fxTrendH4 != "BUY") {
          return;
        }
      }
      // D1
      if(TrendD1 == Follow) {
        if(fxTrendD1 != "SELL") {
          return;
        }
      } else if(TrendD1 == Against) {
        if(fxTrendD1 != "BUY") {
          return;
        }
      }
      // W1
      if(TrendW1 == Follow) {
        if(fxTrendW1 != "SELL") {
          return;
        }
      } else if(TrendW1 == Against) {
        if(fxTrendW1 != "BUY") {
          return;
        }
      }
      // MN
      if(TrendMN == Follow) {
        if(fxTrendMN != "SELL") {
          return;
        }
      } else if(TrendMN == Against) {
        if(fxTrendMN != "BUY") {
          return;
        }
      }
    }

    if(ReverseEntry) {
      if(ManualSL) {
        if(SLPoints > 0) {
          if(StopEntry) {
            sl = High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point - SLPoints*Point;
          } else {
            sl = Ask - SLPoints*Point;
          }
        } else {
          sl = 0;
        }
      } else {
        if(StopEntry) {
          sl = Low[1] - (downArrow - Low[1])*SLx;
        } else {
          sl = Ask - (downArrow - Bid)*SLx;
        }
      }
      tp = Ask + (downArrow - Bid)*TPx;
    } else {
      if(ManualSL) {
        if(SLPoints > 0) {
          if(StopEntry) {
            sl = Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point + SLPoints*Point;
          } else {
            sl = Bid + SLPoints*Point;
          }
        } else {
          sl = 0;
        }
      } else {
        if(StopEntry) {
          sl = Low[1] + (downArrow - Low[1])*SLx;
        } else {
          sl = Bid + (downArrow - Bid)*SLx;
        }
      }
      tp = Bid - (downArrow - Bid)*TPx;
    }
    // entry 1
    if(StopEntry) {
      if(ReverseEntry) {
        ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TPComm, TPMagic, 0, Blue );
      } else {
        ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TPComm, TPMagic, 0, Red );
      }
    } else {
      if(ReverseEntry) {
        ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, TPComm, TPMagic, 0, Blue );
      } else {
        ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, TPComm, TPMagic, 0, Red );
      }
    }
    if(ticket < 0) {
      if(lastErrorLog1 != Time[0]){
        Print( "ERROR Sell [" + TimeToStr( Time[0] ) + "]" );
        Print( GetLastError() );
        lastErrorLog1 = Time[0];
      }
      return;
    } else {
      Print( "SUCCESS Sell [" + TimeToStr( Time[0] ) + "]" );
      lastEntry1 = Time[0];
    }
  }
  // Trail Sell
  if(TrailEntry) {
    if(downArrow != EMPTY_VALUE && downArrow != 0 && lastEntry2 != Time[0]) {
      if(Reverse && Close[0] <= Open[0]) {
        if(lastErrorLog3 != Time[0]) {
          Print( "SKIP Sell [Current:" + Close[0] + " <= Open:" + Open[0] + "]" );
          lastErrorLog3 = Time[0];
          return;
        }
      }
      spread = MarketInfo( Symbol(), MODE_SPREAD );
      if(spread > MaxSpreadPoints) {
        if(lastErrorLog2 != Time[0]) {
          Print( "SKIP Sell [SpreadPoints = " + spread + "]" );
          lastErrorLog2 = Time[0];
        }
        return;
      }
      if(Trend == TrendFollow) {
        if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
          Print( "SKIP Sell [Trend Up]" );
          lastEntry1 = Time[0];
          lastEntry2 = Time[0];
          return;
        }
      } else if(Trend == TrendAgainst) {
        if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
          Print( "SKIP Sell [Trend Sell]" );
          lastEntry1 = Time[0];
          lastEntry2 = Time[0];
          return;
        }
      } else if(Trend == Detail){
        if(lastErrorLog4 != Time[0]) {
          Print( "Sell M1=" + fxTrendM1 + ", M5=" + fxTrendM5 + ", M15=" + fxTrendM15 + ", M30=" + fxTrendM30 + ", H1=" + fxTrendH1 + ", H4=" + fxTrendH4 + ", D1=" + fxTrendD1 + ", W1=" + fxTrendW1 + ", MN=" + fxTrendMN );
          lastErrorLog4 = Time[0];
        }
        // M1
        if(TrendM1 == Follow) {
          if(fxTrendM1 != "SELL") {
            return;
          }
        } else if(TrendM1 == Against) {
          if(fxTrendM1 != "BUY") {
            return;
          }
        }
        // M5
        if(TrendM5 == Follow) {
          if(fxTrendM5 != "SELL") {
            return;
          }
        } else if(TrendM5 == Against) {
          if(fxTrendM5 != "BUY") {
            return;
          }
        }
        // M15
        if(TrendM15 == Follow) {
          if(fxTrendM15 != "SELL") {
            return;
          }
        } else if(TrendM15 == Against) {
          if(fxTrendM15 != "BUY") {
            return;
          }
        }
        // M30
        if(TrendM30 == Follow) {
          if(fxTrendM30 != "SELL") {
            return;
          }
        } else if(TrendM30 == Against) {
          if(fxTrendM30 != "BUY") {
            return;
          }
        }
        // H1
        if(TrendH1 == Follow) {
          if(fxTrendH1 != "SELL") {
            return;
          }
        } else if(TrendH1 == Against) {
          if(fxTrendH1 != "BUY") {
            return;
          }
        }
        // H4
        if(TrendH4 == Follow) {
          if(fxTrendH4 != "SELL") {
            return;
          }
        } else if(TrendH4 == Against) {
          if(fxTrendH4 != "BUY") {
            return;
          }
        }
        // D1
        if(TrendD1 == Follow) {
          if(fxTrendD1 != "SELL") {
            return;
          }
        } else if(TrendD1 == Against) {
          if(fxTrendD1 != "BUY") {
            return;
          }
        }
        // W1
        if(TrendW1 == Follow) {
          if(fxTrendW1 != "SELL") {
            return;
          }
        } else if(TrendW1 == Against) {
          if(fxTrendW1 != "BUY") {
            return;
          }
        }
        // MN
        if(TrendMN == Follow) {
          if(fxTrendMN != "SELL") {
            return;
          }
        } else if(TrendMN == Against) {
          if(fxTrendMN != "BUY") {
            return;
          }
        }
      }

      if(ReverseEntry) {
        if(ManualSL) {
          if(SLPoints > 0) {
            if(StopEntry) {
              sl = High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point - SLPoints*Point;
            } else {
              sl = Ask - SLPoints*Point;
            }
          } else {
            sl = 0;
          }
        } else {
          if(StopEntry) {
            sl = Low[1] - (downArrow - Low[1])*SLx;
          } else {
            sl = Ask - (downArrow - Bid)*SLx;
          }
        }
      } else {
        if(ManualSL) {
          if(SLPoints > 0) {
            if(StopEntry) {
              sl = Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point + SLPoints*Point;
            } else {
              sl = Bid + SLPoints*Point;
            }
          } else {
            sl = 0;
          }
        } else {
          if(StopEntry) {
            sl = Low[1] + (downArrow - Low[1])*SLx;
          } else {
            sl = Bid + (downArrow - Bid)*SLx;
          }
        }
      }
      // entry 2
      if(StopEntry) {
        if(ReverseEntry) {
          ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TrailComm, TrailMagic, 0, Blue );
        } else {
          ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TrailComm, TrailMagic, 0, Red );
        }
      } else {
        if(ReverseEntry) {
          ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, 0, TrailComm, TrailMagic, 0, Blue );
        } else {
          ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, 0, TrailComm, TrailMagic, 0, Red );
        }
      }
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]){
          Print( "ERROR Sell [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
        return;
      } else {
        Print( "SUCCESS Sell [" + TimeToStr( Time[0] ) + "]" );
        lastEntry2 = Time[0];
        firstSL = true;
      }
    }
  }
}
