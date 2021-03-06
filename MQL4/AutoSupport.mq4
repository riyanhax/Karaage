#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern double FirstLossCutPips = 10.0;
extern double FirstModProfitPips = 3.0;
extern double FirstModPips = 0.5;
extern double SecondModProfitPips = 5.0;
extern double SecondModPips = 2.0;
extern double ThirdModProfitPips = 10.0;
extern double ThirdModPips = 5.0;
extern double ModProfitPips = 10.0;
extern double ModPips = 10.0;
extern bool Steps = false;
extern int SettlementUnpassCount = 1;

double pipsRate;
int lastError = 0;
datetime lastErrorTime = 0;
datetime orderModifyTime = 0;
datetime lastPassTime = 0;
int executedDayOfYear = 999;
int diffHour;
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
                  if( Steps ) {
                     if( lastPassTime != current ) {
                        previousOpen = iOpen( Symbol(), timeframe, 1 );
                        previousClose = iClose( Symbol(), timeframe, 1 );
                        if( previousOpen > previousClose ) {
                           unpassCount++;
                           lastPassTime = current;
                           if( unpassCount >= SettlementUnpassCount ) {
                              while( !IsStopped() ) {
                                 errChk = 0;
                                 if( OrderClose( OrderTicket(),OrderLots(),Bid,3,Green ) ){
                                    SendMail( "[PROFIT] "+Symbol(), "["+Symbol()+"] "+Bid+"\r\nProfitPips:"+( (Bid-OrderOpenPrice())/pipsRate )+"\r\nTime:"+time );
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
                                 SendMail( "[ERROR] "+Symbol(), "["+Symbol()+"] "+Bid+"\r\nExecute profit failure." );
                                 Print( "Execute profit failure." );
                                 Sleep(500);
                                 RefreshRates();
                              }
                           } else {
                              SendMail( "[UNSTEP] "+Symbol(), "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( Close[1]-OrderOpenPrice() )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                           }
                        } else if( previousOpen == previousClose ) {
                           lastPassTime = current;
                           SendMail( "[HOLD] "+Symbol(), "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( Close[1]-OrderOpenPrice() )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        } else {
                           passCount++;
                           unpassCount = 0;
                           lastPassTime = current;
                           SendMail( "[STEP] "+Symbol(), "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( Close[1]-OrderOpenPrice() )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        }
                     }
                  } else if( currentProfitPips >= ModProfitPips ) {
                     orderModifyTime = current;
                     tempInt = (currentProfitPips-ModProfitPips)/ModPips;
                     supportCount = tempInt-1;
                     fixedProfitPips = ModProfitPips+supportCount*ModPips;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= ThirdModProfitPips ) {
                     orderModifyTime = current;
                     fixedProfitPips = ThirdModPips;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= SecondModProfitPips ) {
                     orderModifyTime = current;
                     fixedProfitPips = SecondModPips;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= FirstModProfitPips ) {
                     orderModifyTime = current;
                     fixedProfitPips = FirstModPips;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else {
                     fixedProfitPips = FirstLossCutPips;
                     supportLine = OrderOpenPrice()-FirstLossCutPips*pipsRate;
                  }
                  if( supportLine > 0 && ( OrderStopLoss() < supportLine || OrderStopLoss() == 0 ) ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Blue );
                     if( fixedProfitPips > 0 ) {
                        if( !res  ) {
                           msg = "Error Modify BuyOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                           if( lastErrorTime != current || lastError != GetLastError() ) {
                              SendMail( "[ERROR] "+Symbol(), msg );
                              lastError = GetLastError();
                              lastErrorTime = current;
                           }
                           Print( msg );
                        } else {
                           msg = "MOD BUY ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] "+Symbol(), msg );
                           Print( msg );
                        }
                     }
                  }
               }else if( OrderType() == OP_SELL ){
                  currentProfitPips = ( OrderOpenPrice()-Ask )/pipsRate;
                  if( Steps ) {
                     if( lastPassTime != current ) {
                        previousOpen = iOpen( Symbol(), timeframe, 1 );
                        previousClose = iClose( Symbol(), timeframe, 1 );
                        if( previousOpen < previousClose ) {
                           unpassCount++;
                           lastPassTime = current;
                           if( unpassCount >= SettlementUnpassCount ) {
                              while( !IsStopped() ) {
                                 errChk = 0;
                                 if( OrderClose( OrderTicket(),OrderLots(),Ask,3,Green ) ){
                                    SendMail( "[PROFIT] "+Symbol(), "["+Symbol()+"] "+Ask+"\r\nProfitPips:"+( (OrderOpenPrice()-Ask)/pipsRate )+"\r\nTime:"+time );
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
                                 SendMail( "[ERROR] "+Symbol(), "["+Symbol()+"] "+Ask+"\r\nExecute profit failure." );
                                 Print( "Execute profit failure." );
                                 Sleep(500);
                                 RefreshRates();
                              }
                           } /* else {
                              SendMail( "[UNSTEP] "+Symbol(), "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( OrderOpenPrice()-Close[1] )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                           } */
                        } else if( previousOpen == previousClose ) {
                           lastPassTime = current;
                           SendMail( "[HOLD] "+Symbol(), "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( OrderOpenPrice()-Close[1] )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        } else {
                           passCount++;
                           unpassCount = 0;
                           lastPassTime = current;
                           SendMail( "[STEP] "+Symbol(), "["+Symbol()+"] "+Close[1]+"\r\nProfitPips:"+( ( OrderOpenPrice()-Close[1] )/pipsRate )+"\r\nPeriod:"+timeframeStr+"*"+passCount+"\r\nPassTime:"+TimeToStr( iTime( Symbol(), timeframe, 1 )+diffHour*60*60, TIME_DATE|TIME_MINUTES ) +"\r\nTime:"+time );
                        }
                     }
                  } else if( currentProfitPips >= ModProfitPips ) {
                     orderModifyTime = current;
                     tempInt = (currentProfitPips-ModProfitPips)/ModPips;
                     supportCount = tempInt-1;
                     fixedProfitPips = ModProfitPips+supportCount*ModPips;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= ThirdModProfitPips ) {
                     orderModifyTime = current;
                     fixedProfitPips = ThirdModPips;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= SecondModProfitPips ) {
                     orderModifyTime = current;
                     fixedProfitPips = SecondModPips;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= FirstModProfitPips ) {
                     orderModifyTime = current;
                     fixedProfitPips = FirstModPips;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else {
                     fixedProfitPips = FirstLossCutPips;
                     supportLine = OrderOpenPrice()+FirstLossCutPips*pipsRate;
                  }
                  if( supportLine > 0 && ( OrderStopLoss() > supportLine || OrderStopLoss() == 0 ) ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                     if( fixedProfitPips > 0 ) {
                        if( !res ) {
                           msg = "Error Modify SellOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                           if( lastErrorTime != current || lastError != GetLastError() ) {
                              SendMail( "[ERROR] "+Symbol(), msg );
                              lastError = GetLastError();
                              lastErrorTime = current;
                           }
                           Print( msg );
                        } else {
                           msg = "MOD SELL ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] "+Symbol(), msg );
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
