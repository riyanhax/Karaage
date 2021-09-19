#property copyright "Copyright(C) 2021 Studiogadget Inc."

extern int Magic = 0;
extern int BalanceParLot = 10000;
extern int MaxSpreadPoints = 6;
extern int MaxSizeOfSignalCandlePoints = 1000;
extern bool UseDEMA = false;
extern string StartTime = "00:00";
extern string EndTime = "23:59";
extern bool Delay = true;
extern int DelayPercent = 20;
extern string Comm = "Entry Point Auto TP";

datetime lastEntry1 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;
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

  // buy stop
  if(upArrow != EMPTY_VALUE && upArrow != 0) {
    spread = MarketInfo( Symbol(), MODE_SPREAD );
    if(spread > MaxSpreadPoints) {
      if(lastErrorLog2 != Time[0]) {
        Print( "SKIP Buy [SpreadPoints = " + spread + "]" );
        lastErrorLog2 = Time[0];
      }
      return;
    }
    sl = upArrow;
    tp = Ask + (Ask - upArrow);
    // entry 1
    if(lastEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, Comm, Magic, 0, Blue );
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

  // sell stop
  if(downArrow != EMPTY_VALUE && downArrow != 0) {
    spread = MarketInfo( Symbol(), MODE_SPREAD );
    if(spread > MaxSpreadPoints) {
      if(lastErrorLog2 != Time[0]) {
        Print( "SKIP Sell [SpreadPoints = " + spread + "]" );
        lastErrorLog2 = Time[0];
      }
      return;
    }
    sl = downArrow;
    tp = Bid - (downArrow - Bid);
    // entry 1
    if(lastEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, Comm, Magic, 0, Red );
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
