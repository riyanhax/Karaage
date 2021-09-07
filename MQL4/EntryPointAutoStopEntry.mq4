#property copyright "Copyright(C) 2021 Studiogadget Inc."

enum trailingMethod {
  Parabolic = 0,
  TrendLine = 1,
};

extern int Magic = 0;
extern int BalanceParLot = 10000;
extern int LimitCandle = 1;
extern int MaxSizeOfSignalCandlePoints = 1000;
extern bool UseDEMA = false;
extern bool DuplicateEntry = true;
extern double ShiftPips = 0.0;
extern bool OnlyDelete = false;
extern bool Delay = true;
extern int DelayPercent = 20;
extern double ParabolicStep = 0.02;
extern double ParabolicMax = 0.2;
extern string Comm = "Entry Point Auto";

datetime lastStopEntry1 = 0;
datetime lastStopEntry2 = 0;
datetime lastErrorLog1 = 0;
datetime lastErrorLog2 = 0;
bool immediately = false;
string buttonImmed = "immediately";
bool trailing = false;
string buttonTrail = "trailing";
trailingMethod method = Parabolic;
string buttonMethod = "trailingMethod";
double lots;
string textLots = "lots";
double pipsRate;

void OnInit(){
  lots = AccountBalance() / BalanceParLot;

  pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

  ObjectDelete( buttonImmed );
  ObjectCreate(0, buttonImmed, OBJ_BUTTON, 0, 0, 0); // ボタン作成
  ObjectSetInteger(0, buttonImmed, OBJPROP_XDISTANCE, 10); // X座標
  ObjectSetInteger(0, buttonImmed, OBJPROP_YDISTANCE, 15); // Y座標
  ObjectSetInteger(0, buttonImmed, OBJPROP_XSIZE, 70); // 横サイズ
  ObjectSetInteger(0, buttonImmed, OBJPROP_YSIZE, 30); // 縦サイズ
  ObjectSetString(0, buttonImmed, OBJPROP_FONT, "Arial Bold"); // 文字フォント
  ObjectSetString(0, buttonImmed, OBJPROP_TEXT, "IMMED"); // 文字
  ObjectSetInteger(0, buttonImmed, OBJPROP_FONTSIZE, 12); // 文字サイズ
  ObjectSetInteger(0, buttonImmed, OBJPROP_COLOR, DeepPink); // 文字色
  ObjectSetInteger(0, buttonImmed, OBJPROP_BGCOLOR, LightCyan); // ボタン色
  Print( "Immediately = " + immediately );

  ObjectDelete( buttonTrail );
  ObjectCreate(0, buttonTrail, OBJ_BUTTON, 0, 0, 0); // ボタン作成
  ObjectSetInteger(0, buttonTrail, OBJPROP_XDISTANCE, 92); // X座標
  ObjectSetInteger(0, buttonTrail, OBJPROP_YDISTANCE, 15); // Y座標
  ObjectSetInteger(0, buttonTrail, OBJPROP_XSIZE, 70); // 横サイズ
  ObjectSetInteger(0, buttonTrail, OBJPROP_YSIZE, 30); // 縦サイズ
  ObjectSetString(0, buttonTrail, OBJPROP_FONT, "Arial Bold"); // 文字フォント
  ObjectSetString(0, buttonTrail, OBJPROP_TEXT, "TRAIL"); // 文字
  ObjectSetInteger(0, buttonTrail, OBJPROP_FONTSIZE, 12); // 文字サイズ
  ObjectSetInteger(0, buttonTrail, OBJPROP_COLOR, DeepPink); // 文字色
  ObjectSetInteger(0, buttonTrail, OBJPROP_BGCOLOR, LightYellow); // ボタン色
  Print( "Trailing = " + trailing );

  ObjectDelete( buttonMethod );
  ObjectCreate(0, buttonMethod, OBJ_BUTTON, 0, 0, 0); // ボタン作成
  ObjectSetInteger(0, buttonMethod, OBJPROP_XDISTANCE, 92); // X座標
  ObjectSetInteger(0, buttonMethod, OBJPROP_YDISTANCE, 50); // Y座標
  ObjectSetInteger(0, buttonMethod, OBJPROP_XSIZE, 70); // 横サイズ
  ObjectSetInteger(0, buttonMethod, OBJPROP_YSIZE, 30); // 縦サイズ
  ObjectSetString(0, buttonMethod, OBJPROP_FONT, "Arial"); // 文字フォント
  ObjectSetString(0, buttonMethod, OBJPROP_TEXT, "Parabolic"); // 文字
  ObjectSetInteger(0, buttonMethod, OBJPROP_FONTSIZE, 9); // 文字サイズ
  ObjectSetInteger(0, buttonMethod, OBJPROP_COLOR, DeepPink); // 文字色
  ObjectSetInteger(0, buttonMethod, OBJPROP_BGCOLOR, LightYellow); // ボタン色
  Print( "Trailing Method = Parabolic" );

  ObjectDelete( textLots );
  ObjectCreate( textLots, OBJ_EDIT, 0, 0, 0 );
  ObjectSetInteger(0, textLots, OBJPROP_XDISTANCE, 10); // X座標
  ObjectSetInteger(0, textLots, OBJPROP_YDISTANCE, 50); // Y座標
  ObjectSetInteger(0, textLots, OBJPROP_XSIZE, 70); // 横サイズ
  ObjectSetInteger(0, textLots, OBJPROP_YSIZE, 30); // 縦サイズ
  ObjectSetString(0, textLots, OBJPROP_FONT, "Arial Bold"); // 文字フォント
  ObjectSetString(0, textLots, OBJPROP_TEXT, BalanceParLot ); // 文字
  ObjectSetInteger(0, textLots, OBJPROP_FONTSIZE, 12); // 文字サイズ
  ObjectSetInteger(0, textLots, OBJPROP_COLOR, Black); // 文字色
  ObjectSetInteger(0, textLots, OBJPROP_BGCOLOR, White); // 背景色
  Print( "BalanceParLot = " + BalanceParLot );
  Print( "Lots = " + lots );
}

void OnTick(){
  int i;
  int ticket;
  int errChk;
  int delay;
  int tmp;
  double sl;

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

  // トレーリング
  if(trailing){
    // ストップロスを算出
    sl = 0.0;
    if(method == Parabolic){
      sl = iSAR( Symbol(), PERIOD_CURRENT, ParabolicStep, ParabolicMax, 0 );
    } else if(method == TrendLine){
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
              if(NormalizeDouble(NormalizeDouble( sl, Digits() ) - NormalizeDouble( OrderStopLoss(), Digits() ), Digits()) > 0){
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderModify( OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), OrderExpiration(), CLR_NONE )) {
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
              if(NormalizeDouble(NormalizeDouble( OrderStopLoss(), Digits() ) - NormalizeDouble( sl, Digits() ), Digits()) > 0){
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderModify( OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), OrderExpiration(), CLR_NONE )) {
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
      ObjectSetInteger(0, buttonImmed, OBJPROP_COLOR, DeepPink); // 文字色
      ObjectSetInteger(0, buttonImmed, OBJPROP_BGCOLOR, LightCyan); // ボタン色
      Print( "immediately = " + immediately );
    }
    return;
  }

  // パラメータ取得
  double upArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, false, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 2, 1 ); // Blue Arrow
  double downArrow = iCustom( Symbol(), PERIOD_CURRENT, "Market\\Entry Points Pro", MaxSizeOfSignalCandlePoints, true, "", UseDEMA, true, 500, "", true, "", "00:00", "23:59", "", false, 0, Red, LightCyan, White, 9, "", false, false, false, "alert2.wav", 3, 1 ); // Red Arrow

  // buy stop
  if(upArrow != EMPTY_VALUE && upArrow != 0) {
    sl = upArrow;
    // entry 1
    if(lastStopEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+ShiftPips*pipsRate, 3, sl, 0, Comm, Magic, 0, Blue );
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
      ticket = OrderSend( Symbol(), OP_BUYSTOP, lots, High[1]+ShiftPips*pipsRate, 3, sl, 0, Comm, Magic, 0, Blue );
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
    sl = downArrow;
    // entry 1
    if(lastStopEntry1 != Time[0]) {
      ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-ShiftPips*pipsRate, 3, sl, 0, Comm, Magic, 0, Red );
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
      ticket = OrderSend( Symbol(), OP_SELLSTOP, lots, Low[1]-ShiftPips*pipsRate, 3, sl, 0, Comm, Magic, 0, Red );
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
    bool isSelected;

    if(clickedChartObject == buttonImmed){
      isSelected = ObjectGetInteger(0, buttonImmed, OBJPROP_STATE);
      if(isSelected){
        immediately = true;
        ObjectSetInteger(0, buttonImmed, OBJPROP_COLOR, LightCyan); // 文字色
        ObjectSetInteger(0, buttonImmed, OBJPROP_BGCOLOR, DeepPink); // ボタン色
        Print( "Immediately = " + immediately );
        OnTick();
      } else {
        immediately = false;
        ObjectSetInteger(0, buttonImmed, OBJPROP_COLOR, DeepPink); // 文字色
        ObjectSetInteger(0, buttonImmed, OBJPROP_BGCOLOR, LightCyan); // ボタン色
        Print( "Immediately = " + immediately );
      }
    }

    if(clickedChartObject == buttonTrail){
      isSelected = ObjectGetInteger(0, buttonTrail, OBJPROP_STATE);
      if(isSelected){
        trailing = true;
        ObjectSetInteger(0, buttonTrail, OBJPROP_COLOR, LightYellow); // 文字色
        ObjectSetInteger(0, buttonTrail, OBJPROP_BGCOLOR, DeepPink); // ボタン色
        Print( "Trailing = " + trailing );
        OnTick();
      } else {
        trailing = false;
        ObjectSetInteger(0, buttonTrail, OBJPROP_COLOR, DeepPink); // 文字色
        ObjectSetInteger(0, buttonTrail, OBJPROP_BGCOLOR, LightYellow); // ボタン色
        Print( "Trailing = " + trailing );
      }
    }

    if(clickedChartObject == buttonMethod){
      isSelected = ObjectGetInteger(0, buttonMethod, OBJPROP_STATE);
      if(isSelected){
        method = TrendLine;
        ObjectSetString(0, buttonMethod, OBJPROP_TEXT, "TrendLine"); // 文字
        Print( "Trailing Method = TrendLine" );
        OnTick();
      } else {
        method = Parabolic;
        ObjectSetString(0, buttonMethod, OBJPROP_TEXT, "Parabolic"); // 文字
        Print( "Trailing Method = Parabolic" );
        OnTick();
      }
    }
  }

  if(id == CHARTEVENT_OBJECT_ENDEDIT ){
    string editedChartObject = sparam;

    if(editedChartObject == textLots){
      int balanceParLot = StrToInteger( ObjectGetString(0, textLots, OBJPROP_TEXT, 0) );
      lots = AccountBalance() / balanceParLot;
      Print( "BalanceParLot = " + balanceParLot );
      Print( "Lots = " + lots );
    }
  }
}
