#property copyright "Copyright(C) 2021 Studiogadget Inc."

enum method {
  SMA = MODE_SMA,
  EMA = MODE_EMA,
};

enum timeframe {
  M1 = PERIOD_M1,
  M5 = PERIOD_M5,
  M15 = PERIOD_M15,
  M30 = PERIOD_M30,
  H1 = PERIOD_H1,
  H4 = PERIOD_H4,
  D1 = PERIOD_D1,
  W1 = PERIOD_W1,
  MN1 = PERIOD_MN1,
};

extern int Magic = 10906;
extern string TrendSettings = "↓↓↓↓↓ TREND SETTINGS ↓↓↓↓↓";
extern timeframe TrandTimeframe = H1;
extern int TrendTimeShift = 0;
extern method MAMethod  = SMA;
extern int LongMAPeriod = 22;
extern int MiddleMAPeriod = 11;
extern int ShortMAPeriod = 5;
extern string EntrySettings = "↓↓↓↓↓ ENTRY SETTINGS ↓↓↓↓↓";
extern timeframe EntryTimeframe = M5;
extern int EntryTimeShift = 0;
extern int BBPeriod = 20;
extern double BBDeviation = 3.0;
extern string OrderSetting = "↓↓↓↓↓ ORDER SETTINGS ↓↓↓↓↓";
extern int BalanceParLot = 10000;
extern int MaxOrder = 1;
extern string Comm = "MovingAverageTrendEntry";

datetime lastEntry = 0;
datetime lastErrorLog = 0;
double lots;
int trend; // even:0 long:1 short:2
string textTrend = "trend";
int currentTrend; // even:0 long:1 short:2

void OnInit(){
  lots = AccountBalance() / BalanceParLot;
  Print( "TrandTimeframe = " + TrandTimeframe );
  Print("MAMethod = " + MAMethod);
  Print( "EntryTimeframe = " + EntryTimeframe );

  ObjectDelete( textTrend );
  ObjectCreate(0, textTrend, OBJ_BUTTON, 0, 0, 0); // ボタン作成
  ObjectSetInteger(0, textTrend, OBJPROP_XDISTANCE, 10); // X座標
  ObjectSetInteger(0, textTrend, OBJPROP_YDISTANCE, 15); // Y座標
  ObjectSetInteger(0, textTrend, OBJPROP_XSIZE, 70); // 横サイズ
  ObjectSetInteger(0, textTrend, OBJPROP_YSIZE, 30); // 縦サイズ
  ObjectSetString(0, textTrend, OBJPROP_FONT, "Arial Bold"); // 文字フォント
  ObjectSetString(0, textTrend, OBJPROP_TEXT, "EVEN"); // 文字
  ObjectSetInteger(0, textTrend, OBJPROP_FONTSIZE, 12); // 文字サイズ
  ObjectSetInteger(0, textTrend, OBJPROP_COLOR, Black); // 文字色
  ObjectSetInteger(0, textTrend, OBJPROP_BGCOLOR, White); // ボタン色
  Print( "Trend = EVEN" );
  currentTrend = 0;
}

void OnTick(){
  int i;
  int ticket;
  double sl;
  int entryCnt;
  double upperBB;
  double lowerBB;
  int errChk;

  // 同じ通貨ペアのエントリー数をカウント
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

  // 決済
  if(entryCnt > 0) {
    if(OrdersTotal() > 0) {
      for(i=0; i<OrdersTotal(); i++) {
        if(OrderSelect( i, SELECT_BY_POS) == true){
          if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if(OrderType() == OP_BUY) {
              upperBB = iBands( Symbol(), EntryTimeframe, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, 0 );
              if(Bid > upperBB) {
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green )) {
                    errChk = 1;
                  }
                  if(errChk == 0) {
                    entryCnt--;
                    break;
                  }
                  Print( "BuyOrder Close Failure" );
                  Print( GetLastError() );
                  Sleep(500);
                  RefreshRates();
                }
              }
            } else if(OrderType() == OP_SELL) {
              lowerBB = iBands( Symbol(), EntryTimeframe, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, 0 );
              if(Ask < lowerBB) {
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green )) {
                    errChk = 1;
                  }
                  if(errChk == 0) {
                    entryCnt--;
                    break;
                  }
                  Print( "SellOrder Close Failure" );
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

  // エントリー数上限に達している場合はスキップ
  if(entryCnt >= MaxOrder) {
    return;
  }

  // 同じ足で1回のみエントリー
  if(lastEntry == iTime( Symbol(), EntryTimeframe, 0 ) ){
    return;
  }

  // パラメータ取得
  double longMA = iMA( Symbol(), TrandTimeframe, LongMAPeriod, 0, MAMethod, PRICE_CLOSE, TrendTimeShift );
  double middleMA = iMA( Symbol(), TrandTimeframe, MiddleMAPeriod, 0, MAMethod, PRICE_CLOSE, TrendTimeShift );
  double shortMA = iMA( Symbol(), TrandTimeframe, ShortMAPeriod, 0, MAMethod, PRICE_CLOSE, TrendTimeShift );

  // トレンド判定
  trend = 0;
  // Long
  if(shortMA > middleMA && middleMA > longMA) {
    trend = 1;
    if(currentTrend != 1) {
      ObjectSetString(0, textTrend, OBJPROP_TEXT, "LONG" ); // 文字
      ObjectSetInteger(0, textTrend, OBJPROP_COLOR, Lime); // 文字色
      ChartRedraw();
      Print( "LongMA = " + longMA + ", MiddleMA = " + middleMA + ", ShortMA = " + shortMA );
      Print( "Trend = LONG" );
      currentTrend = 1;
    }
  // Short
  } else if(longMA > middleMA && middleMA > shortMA) {
    trend = 2;
    if(currentTrend != 2) {
      ObjectSetString(0, textTrend, OBJPROP_TEXT, "SHORT" ); // 文字
      ObjectSetInteger(0, textTrend, OBJPROP_COLOR, DeepPink); // 文字色
      ChartRedraw();
      Print( "LongMA = " + longMA + ", MiddleMA = " + middleMA + ", ShortMA = " + shortMA );
      Print( "Trend = SHORT" );
      currentTrend = 2;
    }
  }
  if(trend == 0) {
    if(currentTrend != 0) {
      ObjectSetString(0, textTrend, OBJPROP_TEXT, "EVEN" ); // 文字
      ObjectSetInteger(0, textTrend, OBJPROP_COLOR, Black); // 文字色
      ChartRedraw();
      Print( "LongMA = " + longMA + ", MiddleMA = " + middleMA + ", ShortMA = " + shortMA );
      Print( "Trend = EVEN" );
      currentTrend = 0;
    }
    return;
  }

  // エントリー
  upperBB = iBands( Symbol(), EntryTimeframe, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, EntryTimeShift );
  lowerBB = iBands( Symbol(), EntryTimeframe, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, EntryTimeShift );
  // Long
  if(trend == 1) {
    if(Close[0] < lowerBB) {
      sl = Ask - ( upperBB - lowerBB );
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, 0, Comm, Magic, 0, Blue );
      if(ticket < 0) {
        if(lastErrorLog != iTime( Symbol(), EntryTimeframe, 0 )) {
          Print( "ERROR Buy [" + TimeToStr( TimeCurrent() ) + "]" );
          Print( GetLastError() );
          lastErrorLog = iTime( Symbol(), EntryTimeframe, 0 );
        }
      } else {
        Print( "SUCCESS Buy [" + TimeToStr( TimeCurrent() ) + "]" );
        lastEntry = iTime( Symbol(), EntryTimeframe, 0 );
      }
    }
  // Short
  } else if(trend == 2) {
    if(upperBB < Close[0]) {
      sl = Bid + ( upperBB - lowerBB );
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, 0, Comm, Magic, 0, Red );
      if(ticket < 0) {
        if(lastErrorLog != iTime( Symbol(), EntryTimeframe, 0 )) {
          Print( "ERROR Sell [" + TimeToStr( TimeCurrent() ) + "]" );
          Print( GetLastError() );
          lastErrorLog = iTime( Symbol(), EntryTimeframe, 0 );
        }
      } else {
        Print( "SUCCESS Sell [" + TimeToStr( TimeCurrent() ) + "]" );
        lastEntry = iTime( Symbol(), EntryTimeframe, 0 );
      }
    }
  }
}
