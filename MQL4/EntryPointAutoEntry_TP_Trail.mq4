#property copyright "Copyright(C) 2021 Studiogadget Inc."

enum trailingMethod {
  Parabolic = 0,
  TrendLine = 1,
};

extern int TPMagic = 120;
extern int TrailMagic = 130;
extern int BalanceParLot = 20000;
extern int MaxSpreadPoints = 6;
extern int MaxSizeOfSignalCandlePoints = 1000;
extern bool UseDEMA = false;
extern string StartTime = "00:00";
extern string EndTime = "23:59";
extern string TrendSetting = "0:ALL, 1:TrendFollow, 2:TrendAgainst";
extern int Trend = 0;
extern bool Delay = true;
extern int DelayPercent = 20;
extern bool Reverse = true;
extern bool StopEntry = false;
extern int LimitCandle = 1;
extern trailingMethod Method = Parabolic;
extern double ParabolicStep = 0.02;
extern double ParabolicMax = 0.2;
extern int TPPoints = 0;
extern string TPComm = "Entry Point Auto TP";
extern string TrailComm = "Entry Point Auto Trail";

datetime lastEntry1 = 0;
datetime lastEntry2 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;
datetime lastErrorLog3 = 0;
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
  if(lastEntry1 == Time[0] && lastEntry2 == Time[0]){
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
  if(Trend != 0) {
    trendLineUp = iCustom( Symbol(), PERIOD_CURRENT, "Market\\FX Trend", "", 6, 3.0, "", false, 1.0, true, false, true, true, true, Lime, DeepPink, 0, Black, 5000, "", 0, false, 80.0, false, false, false, false, false, "alert.wav", "", false, false, false, false, false, false, false, false, false, 12, 1 );
    trendLineDown = iCustom( Symbol(), PERIOD_CURRENT, "Market\\FX Trend", "", 6, 3.0, "", false, 1.0, true, false, true, true, true, Lime, DeepPink, 0, Black, 5000, "", 0, false, 80.0, false, false, false, false, false, "alert.wav", "", false, false, false, false, false, false, false, false, false, 13, 1 );
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
    if(Trend == 1) {
      if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
        Print( "SKIP Buy [Trend Down]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == 2) {
      if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
        Print( "SKIP Buy [Trend Up]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    }
    sl = upArrow;
    tp = Ask + (Ask - upArrow);
    // entry 1
    if(StopEntry) {
      ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TPComm, TPMagic, 0, Blue );
    } else {
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, TPComm, TPMagic, 0, Blue );
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
    if(Trend == 1) {
      if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
        Print( "SKIP Buy [Trend Down]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == 2) {
      if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
        Print( "SKIP Buy [Trend Up]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    }
    sl = upArrow;
    // entry 2
    if(StopEntry) {
      ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TrailComm, TrailMagic, 0, Blue );
    } else {
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, 0, TrailComm, TrailMagic, 0, Blue );
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
    if(Trend == 1) {
      if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
        Print( "SKIP Sell [Trend Up]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == 2) {
      if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
        Print( "SKIP Sell [Trend Sell]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    }
    sl = downArrow;
    tp = Bid - (downArrow - Bid);
    // entry 1
    if(StopEntry) {
      ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TPComm, TPMagic, 0, Red );
    } else {
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, TPComm, TPMagic, 0, Red );
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
    if(Trend == 1) {
      if(trendLineDown == EMPTY_VALUE || trendLineDown == 0) {
        Print( "SKIP Sell [Trend Up]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    } else if(Trend == 2) {
      if(trendLineUp == EMPTY_VALUE || trendLineUp == 0) {
        Print( "SKIP Sell [Trend Sell]" );
        lastEntry1 = Time[0];
        lastEntry2 = Time[0];
        return;
      }
    }
    sl = downArrow;
    // entry 2
    if(StopEntry) {
      ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-MarketInfo( Symbol(), MODE_SPREAD )*Point, 3, sl, 0, TrailComm, TrailMagic, 0, Red );
    } else {
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, 0, TrailComm, TrailMagic, 0, Red );
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
