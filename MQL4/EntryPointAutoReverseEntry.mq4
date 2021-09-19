#property copyright "Copyright(C) 2021 Studiogadget Inc."

extern int Magic = 0;
extern int BalanceParLot = 10000;
extern int MaxSpreadPoints = 6;
extern int StopLossPoints = 100;
extern int TakeProfitPoints = 100;
extern bool CandleSettlement = true;
extern int LimitCandle = 1;
extern int MinSizeOfSignalCandlePoints = 60;
extern int MaxSizeOfSignalCandlePoints = 10000;
extern bool UseDEMA = false;
extern double ShiftPips = 0.0;
extern bool Delay = false;
extern int DelayPercent = 30;
extern string Comm = "Entry Point Reverse";

datetime lastEntry1 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;
double lots;

void OnInit(){
  lots = AccountBalance() / BalanceParLot;
}

void OnTick(){
  int i;
  int ticket;
  int errChk;
  int delay;
  int tmp;
  int spreadPoints;
  double sl;
  double tp;

  // 一定時間経過した注文を決済する
  if(CandleSettlement) {
    if(OrdersTotal() > 0) {
      for(i=0; i<OrdersTotal(); i++){
        if(OrderSelect( i, SELECT_BY_POS) == true){
          if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic
            && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            if(iBarShift( Symbol(), PERIOD_CURRENT, OrderOpenTime(), false ) >= LimitCandle) {
              while( !IsStopped() ) {
                errChk = 0;
                if(OrderType() == OP_BUY) {
                  if(!OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green)) {
                    errChk = 1;
                  }
                } else if(OrderType() == OP_SELL) {
                  if(!OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green)) {
                    errChk = 1;
                  }
                }
                if( errChk == 0 ) {
                  break;
                }
                Print( "Order Close Failure" );
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

  // 直前の足の長さが指定未満の場合はエントリーしない
  double A=((iHigh(Symbol(),PERIOD_CURRENT,1)-iLow(Symbol(),PERIOD_CURRENT,1))/Point);
  int AA=A;
  if(AA < MinSizeOfSignalCandlePoints) {
    Print( "SKIP [LastCandleLengthPoints = " + AA + "]" );
    lastEntry1 = Time[0];
    return;
  } else if(AA > MaxSizeOfSignalCandlePoints) {
    Print( "SKIP [LastCandleLengthPoints = " + AA + "]" );
    lastEntry1 = Time[0];
    return;
  }

  // パラメータ取得
  double upArrow;
  double downArrow;
  upArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, false, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 2, 1 ); // Blue Arrow
  if(upArrow == EMPTY_VALUE || upArrow == 0) {
    downArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, true, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 3, 1 ); // Red Arrow
  }

  // buy
  if(downArrow != EMPTY_VALUE && downArrow != 0) {
    // entry
    if(lastEntry1 != Time[0]) {
      spreadPoints = MarketInfo( Symbol(), MODE_SPREAD );
      if(spreadPoints > MaxSpreadPoints) {
        if(lastErrorLog2 != Time[0]) {
          Print( "SKIP Buy [SpreadPoints = " + spreadPoints + "]" );
          lastErrorLog2 = Time[0];
        }
        return;
      }
      sl = Ask - StopLossPoints*Point;
      tp = Ask + TakeProfitPoints*Point;
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, Comm, Magic, 0, Blue );
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]) {
          Print( "ERROR Reverse_Buy [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
      } else {
        Print( "SUCCESS Reverse_Buy [" + TimeToStr( Time[0] ) + "]" );
        lastEntry1 = Time[0];
        if(lastEntry1 == Time[0]){
          Alert( Symbol() + "_"+ Period() + " Reverse_Buy" );
        }
      }
    }
  }

  // sell
  if(upArrow != EMPTY_VALUE && upArrow != 0) {
    // entry
    if(lastEntry1 != Time[0]) {
      spreadPoints = MarketInfo( Symbol(), MODE_SPREAD );
      if(spreadPoints > MaxSpreadPoints) {
        if(lastErrorLog2 != Time[0]) {
          Print( "SKIP Sell [SpreadPoints = " + spreadPoints + "]" );
          lastErrorLog2 = Time[0];
        }
        return;
      }
      sl = Bid + StopLossPoints*Point;
      tp = Bid - TakeProfitPoints*Point;
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, Comm, Magic, 0, Red );
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]){
          Print( "ERROR Reverse_Sell [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
      } else {
        Print( "SUCCESS Reverse_Sell [" + TimeToStr( Time[0] ) + "]" );
        lastEntry1 = Time[0];
        if(lastEntry1 == Time[0]){
          Alert( Symbol() + "_"+ Period() + " Reverse_Sell" );
        }
      }
    }
  }
}
