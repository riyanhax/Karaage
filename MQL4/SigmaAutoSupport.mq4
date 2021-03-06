#property copyright "Copyright(C) 2016 Studiogadget Inc."

double pipsRate;
int lastError = 0;
datetime lastErrorTime = 0;
int executedDayOfYear = 999;
int diffHour;
int timeframe;
string timeframeStr;
bool modComplete;

int init() {
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   timeframe = Period();
   TimeframeToStr();
   modComplete = false;

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
   int symbolOrder;
   datetime current;

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
   }

   // Check Position
   symbolOrder = 0;
   current = iTime( Symbol(), timeframe, 0 );
   if( OrdersTotal() > 0){
      for( i=0; i<OrdersTotal(); i++ ){
         if( OrderSelect(i, SELECT_BY_POS) == true ){
            if( OrderSymbol() == Symbol() ) {
               symbolOrder++;
               // Support Line
               if( OrderType() == OP_BUY ){
                  currentProfitPips = ( Bid-OrderOpenPrice() )/pipsRate;
                  if( currentProfitPips >= 10 ) {
                     tempInt = (currentProfitPips-10)/5;
                     supportCount = tempInt-1;
                     fixedProfitPips = 10+supportCount*5;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 7 ) {
                     fixedProfitPips = 4;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 3 ) {
                     fixedProfitPips = 2;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 2 ) {
                     fixedProfitPips = 1;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 1 ) {
                     fixedProfitPips = 0.5;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  }
                  if( supportLine > 0 && OrderStopLoss() < supportLine ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Blue );
                     if( fixedProfitPips > 0 ) {
                        if( !res  ) {
                           msg = "Error Modify BuyOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                           if( lastErrorTime != current || lastError != GetLastError() ) {
                              SendMail( "[ERROR] SigmaOrder", msg );
                              lastError = GetLastError();
                              lastErrorTime = current;
                           }
                           Print( msg );
                        } else {
                           msg = "MOD BUY ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] SigmaOrder", msg );
                           Print( msg );
                        }
                     }
                  }
               }else if( OrderType() == OP_SELL ){
                  currentProfitPips = ( OrderOpenPrice()-Ask )/pipsRate;
                  if( currentProfitPips >= 10 ) {
                     tempInt = (currentProfitPips-10)/5;
                     supportCount = tempInt-1;
                     fixedProfitPips = 10+supportCount*5;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 7 ) {
                     fixedProfitPips = 4;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 3 ) {
                     fixedProfitPips = 2;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 2 ) {
                     fixedProfitPips = 1;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 1 ) {
                     fixedProfitPips = 0.5;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  }
                  if( supportLine > 0 && OrderStopLoss() > supportLine ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                     if( fixedProfitPips > 0 ) {
                        if( !res ) {
                           msg = "Error Modify SellOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                           if( lastErrorTime != current || lastError != GetLastError() ) {
                              SendMail( "[ERROR] SigmaOrder", msg );
                              lastError = GetLastError();
                              lastErrorTime = current;
                           }
                           Print( msg );
                        } else {
                           msg = "MOD SELL ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] SigmaOrder", msg );
                           Print( msg );
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

void TimeframeToStr() {
   switch( timeframe ) {
      case PERIOD_M1:
         timeframeStr = "M1";
         break;
      case PERIOD_M5:
         timeframeStr = "M5";
         break;
      case PERIOD_M15:
         timeframeStr = "M15";
         break;
      case PERIOD_M30:
         timeframeStr = "M30";
         break;
      case PERIOD_H1:
         timeframeStr = "H1";
         break;
      case PERIOD_H4:
         timeframeStr = "H4";
         break;
      case PERIOD_D1:
         timeframeStr = "D1";
         break;
      default:
         break;
   }
}
