#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern bool Mod = false;

double pipsRate;
int lastError = 0;
datetime lastErrorTime = 0;
int executedDayOfYear = 999;
int diffHour;

int init() {
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;
   return(0);
}

int start() {
   double currentProfitPips;
   int tempInt;
   int supportCount;
   double fixedProfitPips;
   double supportLine;
   bool res;
   int i;
   string msg;
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
   int dayOfYear = DayOfYear();
   int errChk;
   datetime current = iTime( Symbol(), PERIOD_M1, 0 );
   double rci_5;
   double rci_15;
   double rci_30;
   double stc14_5;
   double stc14_15;
   double stc14_30;
   double stc5_5;
   double stc5_15;
   double stc5_30;

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0 ) {
         diffHour = diffHour+24;
      }

      executedDayOfYear = dayOfYear;
   }

   // 決済
   while( !IsStopped() ) {
      errChk = 0;
      if( OrdersTotal() > 0){
         for( i=0; i<OrdersTotal(); i++ ){
            if( OrderSelect(i, SELECT_BY_POS) == true ){
               if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
                  // 買いポジション決済
                  if( OrderType() == OP_BUY ) {
                     rci_5 = iCustom( Symbol(), PERIOD_M5, "RCIfrontier", 9, 0, 30, true, 0, 0 );
                     stc14_5 = iStochastic( Symbol(), PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                     stc5_5 = iStochastic( Symbol(), PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                     if( rci_5 >= 0.85 && stc14_5 >= 80 && stc5_5 >= 80 ) {
                        if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                           errChk = 1;
                        }
                     }
                  // 売りポジション決済
                  } else {
                     rci_5 = iCustom( Symbol(), PERIOD_M5, "RCIfrontier", 9, 0, 30, true, 0, 0 );
                     stc14_5 = iStochastic( Symbol(), PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                     stc5_5 = iStochastic( Symbol(), PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                     if( rci_5 <= -0.85 && stc14_5 <= 20 && stc5_5 <= 20 ) {
                        if( !( OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green ) ) ) {
                           errChk = 1;
                        }
                     }
                  }
               }
            }
         }
      }
      if( errChk == 0 ) {
         break;
      }
      Sleep(500);
      RefreshRates();
   }

   // Mod
   if( Mod ) {
      if( OrdersTotal() > 0){
         for( i=0; i<OrdersTotal(); i++ ){
            if( OrderSelect(i, SELECT_BY_POS) == true ){
               if( OrderSymbol() == Symbol() && ( OrderMagicNumber() == Magic || OrderMagicNumber() == Magic+1 || OrderMagicNumber() == Magic+2 ) ) {
                  // Support Line
                  supportLine = 0;
                  if( OrderType() == OP_BUY ){
                     currentProfitPips = ( Bid-OrderOpenPrice() )/pipsRate;
                     if( currentProfitPips > 60 ) {
                        tempInt = ( currentProfitPips-40 )/20;
                        supportCount = tempInt-1;
                        fixedProfitPips = 40+supportCount*20;
                        supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 20 ) {
                        tempInt = ( currentProfitPips-10 )/10;
                        supportCount = tempInt-1;
                        fixedProfitPips = 10+supportCount*10;
                        supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 10 ) {
                        fixedProfitPips = 2;
                        supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                     }
                     if( supportLine > 0 && OrderStopLoss() < supportLine ) {
                        res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Blue );
                        if( fixedProfitPips > 0 ) {
                           if( !res  ) {
                              msg = "Error Modify BuyOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                              if( lastErrorTime != current || lastError != GetLastError() ) {
                                 //SendMail( "[ERROR] TrendsWavezOrder", msg );
                                 lastError = GetLastError();
                                 lastErrorTime = current;
                              }
                              Print( msg );
                           } else {
                              msg = "MOD BUY ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                              //SendMail( "[MOD] TrendsWavezOrder", msg );
                              Print( msg );
                           }
                        }
                     }
                  }else if( OrderType() == OP_SELL ){
                     currentProfitPips = ( OrderOpenPrice()-Ask )/pipsRate;
                     if( currentProfitPips > 60 ) {
                        tempInt = ( currentProfitPips-40 )/20;
                        supportCount = tempInt-1;
                        fixedProfitPips = 40+supportCount*20;
                        supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 20 ) {
                        tempInt = ( currentProfitPips-10 )/10;
                        supportCount = tempInt-1;
                        fixedProfitPips = 10+supportCount*10;
                        supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 10 ) {
                        fixedProfitPips = 2;
                        supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                     }
                     if( supportLine > 0 && OrderStopLoss() > supportLine ) {
                        res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                        if( fixedProfitPips > 0 ) {
                           if( !res ) {
                              msg = "Error Modify SellOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                              if( lastErrorTime != current || lastError != GetLastError() ) {
                                 //SendMail( "[ERROR] TrendsWavezOrder", msg );
                                 lastError = GetLastError();
                                 lastErrorTime = current;
                              }
                              Print( msg );
                           } else {
                              msg = "MOD SELL ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                              //SendMail( "[MOD] TrendsWavezOrder", msg );
                              Print( msg );
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }

   return(0);
}

int deinit() {
   return(0);
}
