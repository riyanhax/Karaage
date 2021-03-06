#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern bool Steps = true;

double pipsRate;
int lastError = 0;
datetime lastErrorTime = 0;
datetime orderModifyTime = 0;
datetime lastPassTime = 0;
int executedDayOfYear = 999;
int diffHour;
MqlRates mqlrates_array[];
double yesterday_high;
double yesterday_low;
double yesterday_close;
double pivot;
double support1;
double support2;
double support3;
double resistance1;
double resistance2;
double resistance3;
double support;
double resistance;
int timeframe;
string timeframeStr;
int passCount;
int unpassCount;
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
   int errChk;
   int symbolOrder;
   datetime current;
   double previousOpen;
   double previousClose;

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0 ) {
         diffHour = diffHour+24;
      }
      // ピボット等の計算
      res = ArrayCopyRates(mqlrates_array,(Symbol()), PERIOD_D1);
      if(res < 0) {
         msg = "Error Calc Pivot["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
         SendMail( "[ERROR] AutoSupport", msg );
      }
      yesterday_high = mqlrates_array[1].high;
      yesterday_low = mqlrates_array[1].low;
      yesterday_close = mqlrates_array[1].close;
      pivot = ((yesterday_close+yesterday_high+yesterday_low)/3);
      support1 = (2*pivot)-yesterday_high;
      resistance1 = (2*pivot)-yesterday_low;
      support2 = pivot-(resistance1-support1);
      resistance2 = pivot+(resistance1-support1);
      support3 = (yesterday_low - (2*(yesterday_high-pivot)));
      resistance3 = (yesterday_high + (2*(pivot-yesterday_low)));
      // Support Line
      support = support2;
      resistance = resistance2;
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
                  if( orderModifyTime != 0 && orderModifyTime != current ) {
                     if( Steps && lastPassTime != current ) {
                        previousOpen = iOpen( Symbol(), timeframe, 1 );
                        previousClose = iClose( Symbol(), timeframe, 1 );
                        if( previousOpen > previousClose ) {
                           unpassCount++;
                           lastPassTime = current;
                           if( unpassCount >= 1 ) {
                              while( !IsStopped() ) {
                                 errChk = 0;
                                 if( OrderClose( OrderTicket(),OrderLots(),Bid,3,Green ) ){
                                    SendMail( "[PROFIT] ScalpingTool", "["+Symbol()+"] "+Bid+"\r\nProfitPips:"+( (Bid-OrderOpenPrice())/pipsRate )+"\r\nTime:"+time );
                                    Print( "Execute profit." );
                                 } else {
                                    errChk = 1;
                                 }
                                 if( errChk == 0 ) {
                                    passCount = 0;
                                    unpassCount = 0;
                                    orderModifyTime = 0;
                                    lastPassTime = 0;
                                    timeframe = PERIOD_CURRENT;
                                    TimeframeToStr();
                                    break;
                                 }
                                 SendMail( "[ERROR] ScalpingTool", "["+Symbol()+"] "+Bid+"\r\nExecute profit failure." );
                                 Print( "Execute profit failure." );
                                 Sleep(500);
                                 RefreshRates();
                              }
                           } else {
                              SendMail( "[UNSTEP] ScalpingTool", "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( Close[1]-OrderOpenPrice() )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                           }
                        } else if( previousOpen == previousClose ) {
                           lastPassTime = current;
                           SendMail( "[HOLD] ScalpingTool", "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( Close[1]-OrderOpenPrice() )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        } else {
                           passCount++;
                           unpassCount = 0;
                           lastPassTime = current;
                           SendMail( "[STEP] ScalpingTool", "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( Close[1]-OrderOpenPrice() )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        }
                     } else {
                        if( currentProfitPips >= 15 ) {
                           tempInt = ( currentProfitPips-15 )/10;
                           supportCount = tempInt-1;
                           fixedProfitPips = 15+supportCount*10;
                           supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                        }
                     }
                  } else if( currentProfitPips >= 10 ) {
                     orderModifyTime = current;
                     tempInt = (currentProfitPips-10)/5;
                     supportCount = tempInt-1;
                     fixedProfitPips = 10+supportCount*5;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 3 ) {
                     orderModifyTime = current;
                     fixedProfitPips = 2;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 2 ) {
                     orderModifyTime = current;
                     fixedProfitPips = 1;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 1 ) {
                     orderModifyTime = current;
                     fixedProfitPips = 0.5;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  }
                  if( supportLine > 0 && OrderStopLoss() < supportLine ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Blue );
                     if( fixedProfitPips > 0 ) {
                        if( !res  ) {
                           msg = "Error Modify BuyOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                           if( lastErrorTime != current || lastError != GetLastError() ) {
                              SendMail( "[ERROR] ScalpingTool", msg );
                              lastError = GetLastError();
                              lastErrorTime = current;
                           }
                           Print( msg );
                        } else {
                           msg = "MOD BUY ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] ScalpingTool", msg );
                           Print( msg );
                        }
                     }
                  }
               }else if( OrderType() == OP_SELL ){
                  currentProfitPips = ( OrderOpenPrice()-Ask )/pipsRate;
                  if( orderModifyTime != 0 && orderModifyTime != current ) {
                     if( Steps && lastPassTime != current ) {
                        previousOpen = iOpen( Symbol(), timeframe, 1 );
                        previousClose = iClose( Symbol(), timeframe, 1 );
                        if( previousOpen < previousClose ) {
                           unpassCount++;
                           lastPassTime = current;
                           if( unpassCount >= 1 ) {
                              while( !IsStopped() ) {
                                 errChk = 0;
                                 if( OrderClose( OrderTicket(),OrderLots(),Ask,3,Green ) ){
                                    SendMail( "[PROFIT] ScalpingTool", "["+Symbol()+"] "+Ask+"\r\nProfitPips:"+( (OrderOpenPrice()-Ask)/pipsRate )+"\r\nTime:"+time );
                                    Print( "Execute profit." );
                                 } else {
                                    errChk = 1;
                                 }
                                 if( errChk == 0 ) {
                                    passCount = 0;
                                    unpassCount = 0;
                                    orderModifyTime = 0;
                                    lastPassTime = 0;
                                    timeframe = PERIOD_CURRENT;
                                    TimeframeToStr();
                                    break;
                                 }
                                 SendMail( "[ERROR] ScalpingTool", "["+Symbol()+"] "+Ask+"\r\nExecute profit failure." );
                                 Print( "Execute profit failure." );
                                 Sleep(500);
                                 RefreshRates();
                              }
                           } else {
                              SendMail( "[UNSTEP] ScalpingTool", "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( OrderOpenPrice()-Close[1] )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                           }
                        } else if( previousOpen == previousClose ) {
                           lastPassTime = current;
                           SendMail( "[HOLD] ScalpingTool", "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( OrderOpenPrice()-Close[1] )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        } else {
                           passCount++;
                           unpassCount = 0;
                           lastPassTime = current;
                           SendMail( "[STEP] ScalpingTool", "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( OrderOpenPrice()-Close[1] )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        }
                     } else {
                        if( currentProfitPips >= 15 ) {
                           tempInt = ( currentProfitPips-15 )/10;
                           supportCount = tempInt-1;
                           fixedProfitPips = 15+supportCount*10;
                           supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                        }
                     }
                  } else if( currentProfitPips >= 10 ) {
                     orderModifyTime = current;
                     tempInt = (currentProfitPips-10)/5;
                     supportCount = tempInt-1;
                     fixedProfitPips = 10+supportCount*5;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 3 ) {
                     orderModifyTime = current;
                     fixedProfitPips = 2;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 2 ) {
                     orderModifyTime = current;
                     fixedProfitPips = 1;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 1 ) {
                     orderModifyTime = current;
                     fixedProfitPips = 0.5;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  }
                  if( supportLine > 0 && OrderStopLoss() > supportLine ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                     if( fixedProfitPips > 0 ) {
                        if( !res ) {
                           msg = "Error Modify SellOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                           if( lastErrorTime != current || lastError != GetLastError() ) {
                              SendMail( "[ERROR] ScalpingTool", msg );
                              lastError = GetLastError();
                              lastErrorTime = current;
                           }
                           Print( msg );
                        } else {
                           msg = "MOD SELL ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] ScalpingTool", msg );
                           Print( msg );
                        }
                     }
                  }
               }
            }
         }
      }
   }

   // ポジションが無い場合は初期化
   if( symbolOrder == 0 ) {
      passCount = 0;
      unpassCount = 0;
      orderModifyTime = 0;
      lastPassTime = 0;
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
