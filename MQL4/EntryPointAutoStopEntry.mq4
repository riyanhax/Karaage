#property copyright "Copyright(C) 2021 Studiogadget Inc."

extern int Magic = 0;
extern double Lots = 0.01;
extern int LimitCandle = 1;
extern int MaxSizeOfSignalCandlePoints = 1000;
extern bool DuplicateEntry = true;
extern bool OnlyDelete = false;
extern bool Delay = true;

datetime lastStopEntry1 = 0;
datetime lastStopEntry2 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;

void OnInit(){
}

void OnTick(){
  int i;
  int ticket;
  int errChk;
  int delay;

  // 一定時間経過した逆指値注文を取り消す
  if(OrdersTotal() > 0) {
    for(i=0; i<OrdersTotal(); i++){
      if(OrderSelect( i, SELECT_BY_POS) == true){
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic
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

  // 取り消しのみの場合
  if(OnlyDelete) {
    return;
  }

  // 足が変わってすぐの期間(10%)はエントリーしない場合
  if(Delay) {
    delay = (Period() * 60) / 10;
    if(TimeCurrent() < (Time[0] + delay)) {
      return;
    }
  }

  // 同じ足で1回のみ実行
  if(lastStopEntry1 == Time[0] && (!DuplicateEntry || lastStopEntry2 == Time[0])){
    return;
  }

  // パラメータ取得
  double upArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", true, true, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 2, 1 ); // Blue Arrow
  double downArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", true, true, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 3, 1 ); // Red Arrow

  // buy stop
  if(upArrow != EMPTY_VALUE && upArrow != 0) {
    // entry 1
    if(lastStopEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_BUYSTOP, Lots, High[1], 3, 0, 0, "Entry Point Auto", Magic, 0, Blue );
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]) {
          Print( "ERROR BuyStop_1 [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
      } else {
        Print( "SUCCESS BuyStop_1 [" + TimeToStr( Time[0] ) + "]" );
        lastStopEntry1 = Time[0];
        if(lastStopEntry1 == Time[0] && lastStopEntry2 == Time[0]){
          Alert( Symbol() + "_"+ Period() + " Auto_BuyStop" );
        }
      }
    }
    // entry 2
    if(DuplicateEntry && lastStopEntry2 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_BUYSTOP, Lots, High[1], 3, 0, 0, "Entry Point Auto", Magic, 0, Blue );
      if(ticket < 0) {
        if(lastErrorLog2 != Time[0]) {
          Print( "ERROR BuyStop_2 [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog2 = Time[0];
        }
      } else {
        Print( "SUCCESS BuyStop_2 [" + TimeToStr( Time[0] ) + "]" );
        lastStopEntry2 = Time[0];
        if(lastStopEntry1 == Time[0] && lastStopEntry2 == Time[0]){
          Alert( Symbol() + "_"+ Period() + " Auto_BuyStop" );
        }
      }
    }
  }

  // sell stop
  if(downArrow != EMPTY_VALUE && downArrow != 0) {
    // entry 1
    if(lastStopEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_SELLSTOP, Lots, Low[1], 3, 0, 0, "Entry Point Auto", Magic, 0, Red );
      if(ticket < 0) {
        if(lastErrorLog1 != Time[0]){
          Print( "ERROR SellStop_1 [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog1 = Time[0];
        }
      } else {
        Print( "SUCCESS SellStop_1 [" + TimeToStr( Time[0] ) + "]" );
        lastStopEntry1 = Time[0];
        if(lastStopEntry1 == Time[0] && lastStopEntry2 == Time[0]){
          Alert( Symbol() + "_"+ Period() + " Auto_SellStop" );
        }
      }
    }
    // entry 2
    if(DuplicateEntry && lastStopEntry2 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_SELLSTOP, Lots, Low[1], 3, 0, 0, "Entry Point Auto", Magic, 0, Red );
      if(ticket < 0) {
        if(lastErrorLog2 != Time[0]){
          Print( "ERROR SellStop_2 [" + TimeToStr( Time[0] ) + "]" );
          Print( GetLastError() );
          lastErrorLog2 = Time[0];
        }
      } else {
        Print( "SUCCESS SellStop_2 [" + TimeToStr( Time[0] ) + "]" );
        lastStopEntry2 = Time[0];
        if(lastStopEntry1 == Time[0] && lastStopEntry2 == Time[0]){
          Alert( Symbol() + "_"+ Period() + " Auto_SellStop" );
        }
      }
    }
  }
}
