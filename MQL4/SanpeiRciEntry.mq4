#property copyright "Copyright(C) 2021 Studiogadget Inc."

enum timeframe {
  M5_ = 5,
  H1_ = 60,
  H4_ = 240,
  D1_ = 1440,
  Point_ = 0,
};

extern string Explanation1 = "/////// ENTRY SETTINGS ///////";
extern int Magic = 520;
extern string Comm = "Sanpei RCI Entry";
extern double FixedLots = 0.01;
extern int BalanceParLot = 20000;
extern int MaxSpreadPoints = 100;
extern int EntryMax = 99;
extern int BarShift = 1;
extern string Explanation2 = "/////// TIME SCOPE SETTINGS ///////";
extern bool PerfectOrder_M5 = true;
extern bool TimeScope_H1 = true;
extern bool TimeScope_H4 = true;
extern bool TimeScope_D1 = true;
extern timeframe CloseTimeframe = M5_;
extern int SLPoints = 100;
extern int TPPoints = 100;
extern string Explanation3 = "/////// RCI SETTINGS ///////";
extern double RCILine = 0.7;
extern bool RCI_Low = true;
extern int RCIRange_Low = 9;
extern bool RCI_Middle = true;
extern int RCIRange_Middle = 24;
extern bool RCI_High = false;
extern int RCIRange_High = 48;
extern string Explanation4 = "/////// KUMO SETTINGS ///////";
extern double KumoAtsumiPips = 50.0; // 不明
extern double KumoKairiPips = 30.0; // 不明

double lots;
datetime lastEntry;
datetime lastErrorLog;

void OnInit() {
  if(FixedLots > 0) {
    lots = FixedLots;
    Print( "Fixed Lots: " + lots );
  } else {
    lots = AccountBalance() / BalanceParLot;
    Print( "Variable Lots[start = " + lots + "]" );
  }
}

void OnTick() {
  double perfectOrder_M5_up;
  double perfectOrder_M5_down;
  double perfectOrder_M5_Y;
  double timeScope_H1_up;
  double timeScope_H1_down;
  double timeScope_H4_up;
  double timeScope_H4_down;
  double timeScope_D1_up;
  double timeScope_D1_down;
  double rci_low;
  double rci_middle;
  double rci_high;
  bool closeFlg;
  int i;
  int errChk;
  double signUp;
  double signDown;
  bool buyFlg;
  bool sellFlg;
  int ticket;
  int entryCnt;
  double kumoA;
  double kumoB;
  bool kumoUp;
  double kumoThicknessPips;
  double sl;
  double tp;

  // パラメータ取得
  if(TimeScope_H1 || CloseTimeframe == H1_) {
    timeScope_H1_up = iCustom( Symbol(), PERIOD_CURRENT, "Multi_time_Scope_1H", 5000, 1, 0, BarShift );
    timeScope_H1_down = iCustom( Symbol(), PERIOD_CURRENT, "Multi_time_Scope_1H", 5000, 1, 1, BarShift );
  }
  if(TimeScope_H4 || CloseTimeframe == H4_) {
    timeScope_H4_up = iCustom( Symbol(), PERIOD_CURRENT, "Multi_time_Scope_4H", 5000, 1, 0, BarShift );
    timeScope_H4_down = iCustom( Symbol(), PERIOD_CURRENT, "Multi_time_Scope_4H", 5000, 1, 1, BarShift );
  }
  if(TimeScope_D1 || CloseTimeframe == D1_) {
    timeScope_D1_up = iCustom( Symbol(), PERIOD_CURRENT, "Multi_time_Scope_1D", 5000, 1, 0, BarShift );
    timeScope_D1_down = iCustom( Symbol(), PERIOD_CURRENT, "Multi_time_Scope_1D", 5000, 1, 1, BarShift );
  }
  if(CloseTimeframe == M5_) {
    perfectOrder_M5_Y = iCustom( Symbol(), PERIOD_CURRENT, "Perfect_order_Tool_5M", 5000, 1, 2, BarShift );
  }

  // 決済
  closeFlg = false;
  if(CloseTimeframe != Point_) {
    if(OrdersTotal() > 0) {
      for(i=0; i<OrdersTotal(); i++) {
        if(OrderSelect(i, SELECT_BY_POS) == true) {
          if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if(OrderType() == OP_BUY) {
              if(CloseTimeframe == M5_) {
                if(perfectOrder_M5_Y != EMPTY_VALUE && perfectOrder_M5_Y != 0) {
                  closeFlg = true;
                }
              } else if(CloseTimeframe == H1_) {
                if(timeScope_H1_down != EMPTY_VALUE && timeScope_H1_down != 0) {
                  closeFlg = true;
                }
              } else if(CloseTimeframe == H4_) {
                if(timeScope_H4_down != EMPTY_VALUE && timeScope_H4_down != 0) {
                  closeFlg = true;
                }
              } else if(CloseTimeframe == D1_) {
                if(timeScope_D1_down != EMPTY_VALUE && timeScope_D1_down != 0) {
                  closeFlg = true;
                }
              }
              if(closeFlg) {
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderClose( OrderTicket(), OrderLots(), Bid, 3, CLR_NONE )) {
                    errChk = 1;
                  }
                  if( errChk == 0 ) {
                    break;
                  }
                  Print( "BuyOrder Close Failure." );
                  Print( GetLastError() );
                  Sleep(500);
                  RefreshRates();
                }
              }
            } else if(OrderType() == OP_SELL) {
              if(CloseTimeframe == M5_) {
                if(perfectOrder_M5_Y != EMPTY_VALUE && perfectOrder_M5_Y != 0) {
                  closeFlg = true;
                }
              } else if(CloseTimeframe == H1_) {
                if(timeScope_H1_up != EMPTY_VALUE && timeScope_H1_up != 0) {
                  closeFlg = true;
                }
              } else if(CloseTimeframe == H4_) {
                if(timeScope_H4_up != EMPTY_VALUE && timeScope_H4_up != 0) {
                  closeFlg = true;
                }
              } else if(CloseTimeframe == D1_) {
                if(timeScope_D1_up != EMPTY_VALUE && timeScope_D1_up != 0) {
                  closeFlg = true;
                }
              }
              if(closeFlg) {
                while( !IsStopped() ) {
                  errChk = 0;
                  if(!OrderClose( OrderTicket(), OrderLots(), Ask, 3, CLR_NONE )) {
                    errChk = 1;
                  }
                  if( errChk == 0 ) {
                    break;
                  }
                  Print( "SellOrder Close Failure." );
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
  // エントリー制限
  if(lastEntry == Time[0]) {
    return;
  }
  if(OrdersTotal() > 0) {
    for(i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS) == true) {
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
          if(OrderType() == OP_BUY || OrderType() == OP_SELL) {
            entryCnt++;
          }
        }
      }
    }
  }
  if(entryCnt >= EntryMax) {
    return;
  }

  // パラメータ取得
  signUp = iCustom( Symbol(), PERIOD_CURRENT, "TAKAHASHI_method_Sign", false, false, false, false, 0, BarShift );
  signDown = iCustom( Symbol(), PERIOD_CURRENT, "TAKAHASHI_method_Sign", false, false, false, false, 1, BarShift );
  if((signUp == EMPTY_VALUE || signUp == 0) && (signDown == EMPTY_VALUE || signDown == 0)) {
    return;
  }
  if(PerfectOrder_M5) {
    perfectOrder_M5_up = iCustom( Symbol(), PERIOD_CURRENT, "Perfect_order_Tool_5M", 5000, 1, 0, BarShift );
    perfectOrder_M5_down = iCustom( Symbol(), PERIOD_CURRENT, "Perfect_order_Tool_5M", 5000, 1, 1, BarShift );
  }
  if(RCI_Low) {
    rci_low = iCustom( Symbol(), PERIOD_CURRENT, "RCI", RCIRange_Low, 0, RCIRange_Low, true, 0, BarShift );
  }
  if(RCI_Middle) {
    rci_middle = iCustom( Symbol(), PERIOD_CURRENT, "RCI", RCIRange_Middle, 0, RCIRange_Middle, true, 0, BarShift );
  }
  if(RCI_High) {
    rci_high = iCustom( Symbol(), PERIOD_CURRENT, "RCI", RCIRange_High, 0, RCIRange_High, true, 0, BarShift );
  }
  kumoA = iCustom( Symbol(), PERIOD_H4, "KumoOnly", 9, 26, 52, 5, 0 );
  kumoB = iCustom( Symbol(), PERIOD_H4, "KumoOnly", 9, 26, 52, 6, 0 );
  if(kumoA > kumoB) {
    kumoUp = true;
  } else {
    kumoUp = false;
  }
  kumoThicknessPips = MathAbs( kumoA - kumoB ) / (Point*10);

  // Buy
  buyFlg = false;
  if(signUp != EMPTY_VALUE && signUp != 0) {
    buyFlg = true;
  }
  if(buyFlg && PerfectOrder_M5) {
    if(perfectOrder_M5_up == EMPTY_VALUE || perfectOrder_M5_up == 0) {
      buyFlg = false;
      return;
    }
  }
  if(buyFlg && TimeScope_H1) {
    if(timeScope_H1_up == EMPTY_VALUE || timeScope_H1_up == 0) {
      buyFlg = false;
      return;
    }
  }
  if(buyFlg && TimeScope_H4) {
    if(timeScope_H4_up == EMPTY_VALUE || timeScope_H4_up == 0) {
      buyFlg = false;
      return;
    }
  }
  if(buyFlg && TimeScope_D1) {
    if(timeScope_D1_up == EMPTY_VALUE || timeScope_D1_up == 0) {
      buyFlg = false;
      return;
    }
  }
  if(buyFlg && RCI_Low) {
    if(MathAbs(rci_low) <= RCILine) {
      buyFlg = false;
      return;
    }
  }
  if(buyFlg && RCI_Middle) {
    if(MathAbs(rci_middle) <= RCILine) {
      buyFlg = false;
      return;
    }
  }
  if(buyFlg && RCI_High) {
    if(MathAbs(rci_high) <= RCILine) {
      buyFlg = false;
      return;
    }
  }
  if(buyFlg && !kumoUp) {
    buyFlg = false;
    return;
  }
  if(buyFlg && kumoThicknessPips < KumoAtsumiPips) {
    buyFlg = false;
    return;
  }
  if(buyFlg && iClose( Symbol(), PERIOD_H4, 0 ) <= kumoA) {
    buyFlg = false;
    return;
  }
  if(buyFlg && MathAbs(iOpen( Symbol(), PERIOD_H4, 0 ) - kumoA)/(Point*10) < KumoKairiPips) {
    buyFlg = false;
    return;
  }
  if(buyFlg) {
    if(CloseTimeframe == Point_) {
      sl = Ask - SLPoints*Point;
      tp = Ask + TPPoints*Point;
    } else {
      sl = 0;
      tp = 0;
    }
    ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, Comm, Magic, 0, CLR_NONE );
    if(ticket < 0) {
      if(lastErrorLog != Time[0]) {
        Print( "ERROR Buy [" + TimeToStr( Time[0] ) + "]" );
        Print( GetLastError() );
        lastErrorLog = Time[0];
      }
      return;
    } else {
      Print( "SUCCESS Buy [" + TimeToStr( Time[0] ) + "]" );
      Print( iOpen( Symbol(), PERIOD_H4, 0 ) + "," + iClose( Symbol(), PERIOD_H4, 0 ) + "," + kumoA + "," + kumoB );
      lastEntry = Time[0];
    }
  }

  // Sell
  sellFlg = false;
  if(signDown != EMPTY_VALUE && signDown != 0) {
    sellFlg = true;
  }
  if(sellFlg && PerfectOrder_M5) {
    if(perfectOrder_M5_down == EMPTY_VALUE || perfectOrder_M5_down == 0) {
      sellFlg = false;
      return;
    }
  }
  if(sellFlg && TimeScope_H1) {
    if(timeScope_H1_down == EMPTY_VALUE || timeScope_H1_down == 0) {
      sellFlg = false;
      return;
    }
  }
  if(sellFlg && TimeScope_H4) {
    if(timeScope_H4_down == EMPTY_VALUE || timeScope_H4_down == 0) {
      sellFlg = false;
      return;
    }
  }
  if(sellFlg && TimeScope_D1) {
    if(timeScope_D1_down == EMPTY_VALUE || timeScope_D1_down == 0) {
      sellFlg = false;
      return;
    }
  }
  if(sellFlg && RCI_Low) {
    if(MathAbs(rci_low) <= RCILine) {
      sellFlg = false;
      return;
    }
  }
  if(sellFlg && RCI_Middle) {
    if(MathAbs(rci_middle) <= RCILine) {
      sellFlg = false;
      return;
    }
  }
  if(sellFlg && RCI_High) {
    if(MathAbs(rci_high) <= RCILine) {
      sellFlg = false;
      return;
    }
  }
  if(sellFlg && kumoUp) {
    sellFlg = false;
    return;
  }
  if(sellFlg && kumoThicknessPips < KumoAtsumiPips) {
    sellFlg = false;
    return;
  }
  if(sellFlg && iClose( Symbol(), PERIOD_H4, 0 ) >= kumoA) {
    sellFlg = false;
    return;
  }
  if(sellFlg && MathAbs(kumoA - iOpen( Symbol(), PERIOD_H4, 0 ))/(Point*10) < KumoKairiPips) {
    sellFlg = false;
    return;
  }
  if(sellFlg) {
    if(CloseTimeframe == Point_) {
      sl = Bid + SLPoints*Point;
      tp = Bid - TPPoints*Point;
    } else {
      sl = 0;
      tp = 0;
    }
    ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, Comm, Magic, 0, CLR_NONE );
    if(ticket < 0) {
      if(lastErrorLog != Time[0]) {
        Print( "ERROR Sell [" + TimeToStr( Time[0] ) + "]" );
        Print( GetLastError() );
        lastErrorLog = Time[0];
      }
      return;
    } else {
      Print( "SUCCESS Sell [" + TimeToStr( Time[0] ) + "]" );
      Print( iOpen( Symbol(), PERIOD_H4, 0 ) + "," + iClose( Symbol(), PERIOD_H4, 0 ) + "," + kumoA + "," + kumoB );
      lastEntry = Time[0];
    }
  }
}
