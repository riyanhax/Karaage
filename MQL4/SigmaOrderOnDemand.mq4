#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lots = 0.01;
extern bool CompoundInterest = false; // 複利
extern int AllPosition = 999;
extern double MaxSpread = 99.0;
extern double ProfitPips = 80.0;
extern double OrderDelaySec = 0.0;
extern int MinusSleepMin = 0; // 0は制限なし
extern int TimeupMin = 60;
extern double DayInterestPercent = 0; // 0は制限なし
extern int DayInterestResetHour = 1; // TimeCurrentで指定(1以上を使用)
extern bool MarketTimeStop = false;
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/stop_list_dummy.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定
extern string TestUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/test.txt";
extern string DayInterestPercentUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/day_interrest_percent_dummy.txt";
extern string AllPositionUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/all_position_dummy.txt";

double lots;
double pipsRate;
int executedDayOfYear = 999;
int dayInterestResetDayOfYear = 999;
int lastCloseMin = 0;
datetime lastErrorTime = 0;
datetime stopStart[1] = {0};
datetime stopEnd[1] = {0};
int diffHour;
double stopBalance;
double dayInterestPercent;
int allPosition;
bool bootTest;
bool bootErrorMail;
datetime position30;
datetime position35;
datetime position40;
datetime position45;
datetime position50;
datetime position55;
datetime position60;
datetime position65;
datetime position70;

int init() {
   bootTest = false;
   bootErrorMail = false;

   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   // 目標残高の設定
   if( DayInterestPercent == 0 ) {
      stopBalance = 0.0;
   } else {
      stopBalance = AccountBalance()*(1.0+DayInterestPercent/100);
   }

   return(0);
}

int start() {
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
   int dayOfYear = DayOfYear();
   string stopList;
   int buyCnt;
   int sellCnt;
   double spreadTemp;
   double spreadDouble;
   int ticket;
   string msg;
   int errChk;
   int i;
   int length;
   string tmp;
   int index;
   string today;
   int month;
   int day;
   datetime stopStartDatetime;
   datetime stopEndDatetime;
   double stop;
   double limit;
   double StopPips;

   // 起動テスト
   if( !bootTest ) {
      tmp = "";
      GrabWeb( TestUrl, tmp );
      if( tmp == "test" ) {
         bootTest = true;
         if( bootErrorMail ) {
            SendMail( "[RECOVERY] SigmaOrder", "["+Symbol()+"] Reboot Success." );
         }
      } else {
         if( !bootErrorMail ) {
            bootErrorMail = true;
            SendMail( "[ERROR] SigmaOrder", "["+Symbol()+"] Reboot Failure." );
         }
         Sleep( 1*60*1000 );
         return(0);
      }
   }

   // 1日に1回特定の時間に実行するタスク(目標残高の設定)
   if( dayInterestResetDayOfYear != dayOfYear ) {
      // 日利の取得
      tmp = "";
      GrabWeb( DayInterestPercentUrl, tmp );
      length = StringLen( tmp );
      if( length == 0 || length > 10 ) {
         dayInterestPercent = DayInterestPercent;
      } else {
         dayInterestPercent = StrToDouble( tmp );
      }

      if( DayInterestResetHour <= TimeHour( TimeCurrent() ) ) {
         if( dayInterestPercent == 0 ) {
            stopBalance = 0.0;
         } else {
            stopBalance = AccountBalance()*(1.0+dayInterestPercent/100);
         }
         dayInterestResetDayOfYear = dayOfYear;
      }
   }

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();

      // 単利複利の設定
      tmp = "";
      GrabWeb( AllPositionUrl, tmp );
      length = StringLen( tmp );
      if( length == 0 || length > 10 ) {
         allPosition = AllPosition;
      } else {
         allPosition = StrToInteger( tmp );
      }
      if( CompoundInterest ) {
         lots = dts2( AccountBalance()*AccountLeverage()/( 40000000*allPosition ) );
      } else {
         lots = Lots;
      }

      // 停止時間の取得
      // 配列を初期化
      ArrayInitialize( stopStart, 0 );
      ArrayInitialize( stopEnd, 0 );
      ArrayResize( stopStart, 1 );
      ArrayResize( stopEnd, 1 );
      // メイン
      GrabWeb( StopListUrl, stopList );
      length = StringLen( stopList );
      if( length == 0 ) {
         msg = "Error Load StopList["+Symbol()+"]"+"\r\nTime:"+time;
         SendMail( "[ERROR] SigmaOrder", msg );
      }
      if( length >= 13 ) {
         index = length/13;

         month = TimeMonth( TimeCurrent() );
         day = TimeDay( TimeCurrent() );
         if( month < 10 ) {
            today = today+"0"+Month();
         } else {
            today = today+Month();
         }
         if( day < 10 ) {
            today = today+"0"+Day();
         } else {
            today = today+Day();
         }
         Print( "Today: "+today );

         for( i = 0; i < index; i++ ) {
            tmp = StringSubstr( stopList, i*13, 12 );
            if( StringSubstr( tmp, 0, 4 ) == today ) {
               stopStartDatetime = StrToTime( StringSubstr( tmp, 4, 2 )+":"+StringSubstr( tmp, 6, 2 ) );
               stopEndDatetime = StrToTime( StringSubstr( tmp, 8, 2 )+":"+StringSubstr( tmp, 10, 2 ) );
               stopStart[ArraySize( stopStart )-1] = stopStartDatetime;
               stopEnd[ArraySize( stopEnd )-1] = stopEndDatetime;
               ArrayResize( stopStart, ArraySize( stopStart )+1 );
               ArrayResize( stopEnd, ArraySize( stopEnd )+1 );
               Print( "StopStart: "+TimeToStr( stopStartDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES ) );
               Print( "StopEnd: "+TimeToStr( stopEndDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES ) );
            }
         }
      }
      // マーケット時間
      if( MarketTimeStop ) {
         ArrayResize( stopStart, ArraySize( stopStart )+4 );
         ArrayResize( stopEnd, ArraySize( stopEnd )+4 );
         if( diffHour == 7 ) {
            // 通常時間
            stopStart[ArraySize( stopStart )-4] = StrToTime( "00:00" );  // 07:00~12:00
            stopEnd[ArraySize( stopEnd )-4] = StrToTime( "05:00" );
            stopStart[ArraySize( stopStart )-3] = StrToTime( "09:00" );  // 16:00~20:00
            stopEnd[ArraySize( stopEnd )-3] = StrToTime( "13:00" );
            stopStart[ArraySize( stopStart )-2] = StrToTime( "14:00" );  // 21:00~25:00
            stopEnd[ArraySize( stopEnd )-2] = StrToTime( "18:00" );
            stopStart[ArraySize( stopStart )-1] = StrToTime( "21:00" );  // 04:00~06:59
            stopEnd[ArraySize( stopEnd )-1] = StrToTime( "23:59" );
         } else {
            // サマータイム
            stopStart[ArraySize( stopStart )-4] = StrToTime( "00:00" );  // 06:00~12:00
            stopEnd[ArraySize( stopEnd )-4] = StrToTime( "06:00" );
            stopStart[ArraySize( stopStart )-3] = StrToTime( "09:00" );  // 15:00~19:00
            stopEnd[ArraySize( stopEnd )-3] = StrToTime( "13:00" );
            stopStart[ArraySize( stopStart )-2] = StrToTime( "14:00" );  // 20:00~24:00
            stopEnd[ArraySize( stopEnd )-2] = StrToTime( "18:00" );
            stopStart[ArraySize( stopStart )-1] = StrToTime( "23:00" );  // 05:00~05:59
            stopEnd[ArraySize( stopEnd )-1] = StrToTime( "23:59" );
         }
      }

      executedDayOfYear = dayOfYear;
   }

   // Check Position
   if( OrdersTotal() > 0){
      for( i=0; i<OrdersTotal(); i++ ){
         if( OrderSelect(i, SELECT_BY_POS) == true && OrderMagicNumber() == Magic ){
            if( OrderSymbol() == Symbol() ) {
               if( OrderType() == OP_BUY ){
                  buyCnt++;
               }else if( OrderType() == OP_SELL ){
                  sellCnt++;
               }
            }
         }
      }
   }

   // Timeup
   if( buyCnt > 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         for( i=OrdersTotal()-1; i>=0; i-- ) {
            if( OrderSelect(i, SELECT_BY_POS) == true ) {
               if( OrderType() == OP_BUY && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
                  // MODに入っている(StopLossがプラス)場合は決済しない
                  if( OrderStopLoss() != 0 && OrderStopLoss() >= OrderOpenPrice() ) {
                     continue;
                  }
                  // オープンから指定時間を超えているオーダーを決済
                  if( OrderOpenTime()+TimeupMin*60 < TimeCurrent() ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Bid,3,Green)) ) {
                        SendMail( "[TIMEUP] SigmaOrder", "["+Symbol()+"] "+Bid+"\r\nTime:"+time );
                     } else {
                        errChk = 1;
                     }
                  }
               }
            }
         }
         if( errChk == 0 ) {
            break;
         }
         SendMail( "[ERROR] SigmaOrder", "["+Symbol()+"] "+Bid+"\r\nExecute timeup failure." );
         Sleep(500);
         RefreshRates();
      }
   }
   if( sellCnt > 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         for( i=OrdersTotal()-1; i>=0; i-- ) {
            if( OrderSelect(i, SELECT_BY_POS) == true ) {
               if( OrderType() == OP_SELL && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
                  // MODに入っている(StopLossがプラス)場合は決済しない
                  if( OrderStopLoss() != 0 && OrderStopLoss() <= OrderOpenPrice() ) {
                     continue;
                  }
                  // オープンから指定時間を超えているオーダーを決済
                  if( OrderOpenTime()+TimeupMin*60 < TimeCurrent() ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Ask,3,Green)) ){
                        SendMail( "[TIMEUP] SigmaOrder", "["+Symbol()+"] "+Ask+"\r\nTime:"+time );
                     } else {
                        errChk = 1;
                     }
                  }
               }
            }
         }
         if( errChk == 0 ) {
            break;
         }
         SendMail( "[ERROR] SigmaOrder", "["+Symbol()+"] "+Ask+"\r\nExecute timeup failure." );
         Sleep(500);
         RefreshRates();
      }
   }

   // 直前の決済がマイナスの場合は一定時間新規注文停止
   if( MinusSleepMin > 0 ) {
      for( i=OrdersHistoryTotal()-1; i>=0; i-- ) {
         if( OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) == false ) {
            break;
         }
         if( OrderMagicNumber() != Magic || OrderSymbol() != Symbol() ){
            continue;
         }
         int type = OrderType();
         if( type == OP_BUY || type == OP_SELL ) {
            double profit = OrderProfit();
            if( profit < 0 ) {
               if( OrderCloseTime()+MinusSleepMin*60 > TimeCurrent() ) {
                  return(0);
               }
            }
            break;
         }
      }
   }

   // スプレッドが条件に合わない場合はスキップ
   int spread = MarketInfo(Symbol(),MODE_SPREAD); // 0.5pips → 5 1pips → 10
   if(spread > MaxSpread*10) {
      return(0);
   } else {
      spreadTemp = spread;
      spreadDouble = spreadTemp/10;
   }
   StopPips = spreadDouble*5;

   // ボリンジャーバンド
   double sigma30U = iBands( Symbol(), PERIOD_CURRENT, 25, 3.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma35U = iBands( Symbol(), PERIOD_CURRENT, 25, 3.5, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma40U = iBands( Symbol(), PERIOD_CURRENT, 25, 4.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma45U = iBands( Symbol(), PERIOD_CURRENT, 25, 4.5, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma50U = iBands( Symbol(), PERIOD_CURRENT, 25, 5.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma55U = iBands( Symbol(), PERIOD_CURRENT, 25, 5.5, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma60U = iBands( Symbol(), PERIOD_CURRENT, 25, 6.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma65U = iBands( Symbol(), PERIOD_CURRENT, 25, 6.5, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma70U = iBands( Symbol(), PERIOD_CURRENT, 25, 7.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   double sigma30L = iBands( Symbol(), PERIOD_CURRENT, 25, 3.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma35L = iBands( Symbol(), PERIOD_CURRENT, 25, 3.5, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma40L = iBands( Symbol(), PERIOD_CURRENT, 25, 4.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma45L = iBands( Symbol(), PERIOD_CURRENT, 25, 4.5, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma50L = iBands( Symbol(), PERIOD_CURRENT, 25, 5.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma55L = iBands( Symbol(), PERIOD_CURRENT, 25, 5.5, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma60L = iBands( Symbol(), PERIOD_CURRENT, 25, 6.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma65L = iBands( Symbol(), PERIOD_CURRENT, 25, 6.5, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   double sigma70L = iBands( Symbol(), PERIOD_CURRENT, 25, 7.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );

   // BUY ORDER
   if( Close[0] <= sigma30L && position30 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",30",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position30 = Time[0];
      }
   }
   if( Close[0] <= sigma35L && position35 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",35",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position35 = Time[0];
      }
   }
   if( Close[0] <= sigma40L && position40 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",40",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position40 = Time[0];
      }
   }
   if( Close[0] <= sigma45L && position45 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",45",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position45 = Time[0];
      }
   }
   if( Close[0] <= sigma50L && position50 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",50",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position50 = Time[0];
      }
   }
   if( Close[0] <= sigma55L && position55 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",55",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position55 = Time[0];
      }
   }
   if( Close[0] <= sigma60L && position60 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",60",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position60 = Time[0];
      }
   }
   if( Close[0] <= sigma65L && position65 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",65",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position65 = Time[0];
      }
   }
   if( Close[0] <= sigma70L && position70 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Ask-StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Ask+ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,stop,limit,spreadDouble+",70",Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Ask+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position70 = Time[0];
      }
   }
   // SELL ORDER
   if( Close[0] >= sigma30U && position30 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",30",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position30 = Time[0];
      }
   }
   if( Close[0] >= sigma35U && position35 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",35",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position35 = Time[0];
      }
   }
   if( Close[0] >= sigma40U && position40 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",40",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position40 = Time[0];
      }
   }
   if( Close[0] >= sigma45U && position45 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",45",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position45 = Time[0];
      }
   }
   if( Close[0] >= sigma50U && position50 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",50",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position50 = Time[0];
      }
   }
   if( Close[0] >= sigma55U && position55 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",55",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position55 = Time[0];
      }
   }
   if( Close[0] >= sigma60U && position60 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",60",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position60 = Time[0];
      }
   }
   if( Close[0] >= sigma65U && position65 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",65",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position65 = Time[0];
      }
   }
   if( Close[0] >= sigma70U && position70 != Time[0] ) {
      if( StopPips == 0) {
         stop = 0;
      } else {
         stop = Bid+StopPips*pipsRate;
      }
      if( ProfitPips == 0 ) {
         limit = 0;
      } else {
         limit = Bid-ProfitPips*pipsRate;
      }
      Sleep( OrderDelaySec*1000 ); // オーダー遅延
      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,stop,limit,spreadDouble+",70",Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
            SendMail( "[ERROR] SigmaOrder", msg );
            lastErrorTime = Time[0];
         }
      } else {
         msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Bid+"\r\nLimit:"+limit+" ("+ProfitPips+")"+"\r\nRLimit:"+stop+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
         SendMail( "[OPEN] SigmaOrder", msg );
         position70 = Time[0];
      }
   }

   return(0);
}

int deinit() {
   return(0);
}

// 小数点を2桁に切る
double dts2(double val) {
   return(StrToDouble((DoubleToStr(val,2))));
}

//=================================================================================================
//=================================================================================================
//====================================   GrabWeb Functions   ======================================
//=================================================================================================
//=================================================================================================
// Main Webscraping function
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// bool GrabWeb(string strUrl, string& strWebPage)
// returns the text of any webpage. Returns false on timeout or other error
//
// Parsing functions
// ~~~~~~~~~~~~~~~~~
// string GetData(string strWebPage, int nStart, string strLeftTag, string strRightTag, int& nPos)
// obtains the text between two tags found after nStart, and sets nPos to the end of the second tag
//
// void Goto(string strWebPage, int nStart, string strTag, int& nPos)
// Sets nPos to the end of the first tag found after nStart

bool bWinInetDebug = true;

int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig = 0;
int Internet_Open_Type_Direct = 1;
int Internet_Open_Type_Proxy = 3;
int Buffer_LEN = 1000;

#import "wininet.dll"

#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 // Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 // Does not add the returned entity to the cache.
#define INTERNET_FLAG_RELOAD            0x80000000 // Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.

int InternetOpenW(
   string   sAgent,
   int      lAccessType,
   string   sProxyName="",
   string   sProxyBypass="",
   int   lFlags=0
);

int InternetOpenUrlW(
   int   hInternetSession,
   string   sUrl,
   string   sHeaders="",
   int   lHeadersLength=0,
   int   lFlags=0,
   int   lContext=0
);

int InternetReadFile(
   int   hFile,
   uchar&   sBuff[],
   int   lNumBytesToRead,
   int&  lNumberOfBytesRead[]
);

int InternetCloseHandle(
   int   hInet
);
#import


int hSession(bool Direct) {
   string InternetAgent;
   if (hSession_IEType == 0){
      InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
      hSession_IEType = InternetOpenW(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0);
      hSession_Direct = InternetOpenW(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
   }
   if (Direct) {
      return(hSession_Direct);
   }else {
      return(hSession_IEType);
   }
}


bool GrabWeb(string strUrl, string& strWebPage) {
   int   hInternet;
   int      iResult;
   int   lReturn[]   = {1};
   uchar   sBuff[];
   ArrayResize( sBuff, Buffer_LEN+1 );
   hInternet = InternetOpenUrlW(hSession(FALSE), strUrl, NULL, 0, INTERNET_FLAG_NO_CACHE_WRITE|INTERNET_FLAG_PRAGMA_NOCACHE|INTERNET_FLAG_RELOAD, 0);

   if (bWinInetDebug) Print("hInternet: " + hInternet);
   if (hInternet == 0) return(false);

   if (bWinInetDebug) Print("Reading URL: " + strUrl);
   iResult = InternetReadFile(hInternet, sBuff, Buffer_LEN, lReturn);
   strWebPage = CharArrayToString(sBuff, 0, lReturn[0], CP_UTF8);

   if (bWinInetDebug) Print("iResult: " + iResult);
   if (bWinInetDebug) Print("lReturn: " + lReturn[0]);
   if (bWinInetDebug) Print("strWebPage: " +  strWebPage);
   if (iResult == 0)  return(false);

   return(true);
}
