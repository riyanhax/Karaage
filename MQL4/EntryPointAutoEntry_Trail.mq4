#property copyright "Copyright(C) 2021 Studiogadget Inc."

enum trailingMethod {
  Parabolic = 0,
  TrendLine = 1,
};

extern int Magic = 130;
extern int BalanceParLot = 10000;
extern int MaxSpreadPoints = 6;
extern int MaxSizeOfSignalCandlePoints = 1000;
extern bool UseDEMA = false;
extern string StartTime = "00:00";
extern string EndTime = "23:59";
extern bool Delay = true;
extern int DelayPercent = 20;
extern bool Reverse = true;
extern trailingMethod Method = Parabolic;
extern double ParabolicStep = 0.02;
extern double ParabolicMax = 0.2;
extern int TPPoints = 0;
extern string Comm = "Entry Point Auto Trail";

datetime lastEntry1 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;
datetime lastErrorLog3 = 0;
double lots;

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
  int entryCnt;

  // トレーリング
  // エントリー数をカウント
  entryCnt = 0;
  if(OrdersTotal() > 0) {
    for(i=0; i<OrdersTotal(); i++){
      if(OrderSelect( i, SELECT_BY_POS) == true){
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
          if(OrderType() == OP_BUY || OrderType() == OP_SELL){
            entryCnt++;
          }
        }
      }
    }
  }
  if(entryCnt > 0){
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
          if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            if(OrderType() == OP_BUY){
              tp = 0.0;
              if(TPPoints > 0) {
                tp = Bid + TPPoints * Point;
              }
              if(NormalizeDouble(NormalizeDouble( sl, Digits() ) - NormalizeDouble( OrderStopLoss(), Digits() ), Digits()) > 0){
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderModify( OrderTicket(), OrderOpenPrice(), sl, tp, OrderExpiration(), CLR_NONE )) {
                    errChk = 1;
                  }
                  if( errChk == 0 ) {
                    break;
                  }
                  Print( "Order Modify Failure" );
                  Print( GetLastError() );
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
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderModify( OrderTicket(), OrderOpenPrice(), sl, tp, OrderExpiration(), CLR_NONE )) {
                    errChk = 1;
                  }
                  if( errChk == 0 ) {
                    break;
                  }
                  Print( "Order Modify Failure" );
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
  if(lastEntry1 == Time[0]){
    return;
  }

  // パラメータ取得double upArrow
  double upArrow;
  double downArrow;
  upArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, false, 500, "", true, "", StartTime, EndTime, "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 2, 1 ); // Blue Arrow
  if(upArrow == EMPTY_VALUE || upArrow == 0) {
    downArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, true, 500, "", true, "", StartTime, EndTime, "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 3, 1 ); // Red Arrow
  }

  // buy
  if(upArrow != EMPTY_VALUE && upArrow != 0) {
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
    sl = upArrow;
    // entry 1
    if(lastEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, 0, Comm, Magic, 0, Blue );
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]) {
          Print( "ERROR Buy [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
      } else {
        Print( "SUCCESS Buy [" + TimeToStr( Time[0] ) + "]" );
        lastEntry1 = Time[0];
      }
    }
  }

  // sell
  if(downArrow != EMPTY_VALUE && downArrow != 0) {
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
    sl = downArrow;
    // entry 1
    if(lastEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, 0, Comm, Magic, 0, Red );
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]){
          Print( "ERROR Sell [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
      } else {
        Print( "SUCCESS Sell [" + TimeToStr( Time[0] ) + "]" );
        lastEntry1 = Time[0];
      }
    }
  }
}
