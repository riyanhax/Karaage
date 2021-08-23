#property copyright "Copyright(C) 2021 Studiogadget Inc."

extern int Magic = 0;
extern double Lots = 0.01;
extern int LimitCandle = 1;
extern int MaxSizeOfSignalCandlePoints = 1000;
extern bool UseDEMA = false;
extern bool DuplicateEntry = true;
extern bool OnlyDelete = false;
extern bool Delay = true;
extern int DelayPercent = 100;

datetime lastStopEntry1 = 0;
datetime lastStopEntry2 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;
bool immediately = false;
string buttonID = "immediately";

void OnInit(){
  ObjectDelete( buttonID );
  ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0); // ボタン作成
  ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 10); // X座標
  ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 15); // Y座標
  ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, 70); // 横サイズ
  ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, 30); // 縦サイズ
  ObjectSetString(0, buttonID, OBJPROP_FONT, "Arial Bold"); // 文字フォント
  ObjectSetString(0, buttonID, OBJPROP_TEXT, "IMMED"); // 文字
  ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, 12); // 文字サイズ
  ObjectSetInteger(0, buttonID, OBJPROP_COLOR, DeepPink); // 文字色
  ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, LightCyan); // ボタン色
}

void OnTick(){
  int i;
  int ticket;
  int errChk;
  int delay;
  int tmp;

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

  // 足が変わってからの一定期間(指定%)はエントリーしない場合
  if(!immediately && Delay) {
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
  if(lastStopEntry1 == Time[0] && (!DuplicateEntry || lastStopEntry2 == Time[0])){
    if(immediately){
      immediately = false;
      ObjectSetInteger(0, buttonID, OBJPROP_COLOR, DeepPink); // 文字色
      ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, LightCyan); // ボタン色
      Print( "immediately = " + immediately );
    }
    return;
  }

  // パラメータ取得
  double upArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, false, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 2, 1 ); // Blue Arrow
  double downArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, true, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 3, 1 ); // Red Arrow

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

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam){
  if(id == CHARTEVENT_OBJECT_CLICK){
    string clickedChartObject = sparam;
    if(clickedChartObject == buttonID){
      bool isSelected = ObjectGetInteger(0, buttonID, OBJPROP_STATE);
      if(isSelected){
        immediately = true;
        ObjectSetInteger(0, buttonID, OBJPROP_COLOR, LightCyan); // 文字色
        ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, DeepPink); // ボタン色
        Print( "immediately = " + immediately );
      } else {
        immediately = false;
        ObjectSetInteger(0, buttonID, OBJPROP_COLOR, DeepPink); // 文字色
        ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, LightCyan); // ボタン色
        Print( "immediately = " + immediately );
      }
    }
  }
}
