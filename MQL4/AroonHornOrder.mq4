#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern double Lots = 0.01;
extern int AroonHornPeriod = 10;
extern double ProfitPips = 0.0;
extern double StopLossPips = 0.0;
extern bool CkSpeed_sleep = false;
extern bool CkSpeed_correction = true;
extern bool CkSpeed_trend = true;
extern int MaxEntry = 1;
extern int Magic = 37654321;

double pipsRate;
datetime lastExeFoot = 0;

int init() {
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   return(0);
}

int start() {
   int i;
   int errChk;
   int ticket;
   int allCnt;
   double stopLoss;
   double takeProfit;
   double aroonHornUp;
   double aroonHornDown;
   double trend;
   double correction;
   double sleep;

   // 同じ足では決済・エントリーしない
   if( Time[0] == lastExeFoot ) {
      return(0);
   }

   // Check Position
   if( OrdersTotal() > 0){
      for( i=0; i<OrdersTotal(); i++ ){
         if( OrderSelect(i, SELECT_BY_POS) == true && OrderMagicNumber() == Magic ){
            allCnt++;
         }
      }
   }

   // 決済
   aroonHornUp = iCustom( Symbol(), PERIOD_CURRENT, "Aroon Horn", AroonHornPeriod, 0, 0 );
   aroonHornDown = iCustom( Symbol(), PERIOD_CURRENT, "Aroon Horn", AroonHornPeriod, 1, 0 );
   if( allCnt > 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         if( OrdersTotal() > 0){
            for( i=0; i<OrdersTotal(); i++ ){
               if( OrderSelect(i, SELECT_BY_POS) == true ){
                  if( OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
                     // 買いポジション決済
                     if( OrderType() == OP_BUY ) {
                        if( aroonHornUp <= 70 || ( aroonHornUp < 100 && aroonHornDown >= 100 ) ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                              errChk = 1;
                           } else {
                              allCnt--;
                           }
                        }
                     // 売りポジション決済
                     } else {
                        if( aroonHornDown <= 70 || ( aroonHornDown < 100 && aroonHornUp >= 100 ) ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green ) ) ) {
                              errChk = 1;
                           } else {
                              allCnt--;
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
   }

   // エントリー数制限
   if( allCnt >= MaxEntry ) {
      return(0);
   }

   // パラメータ取得
   if( CkSpeed_trend ) {
      trend = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 0, 0 );
   }
   if( CkSpeed_correction ) {
      correction = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 1, 0 );
   }
   if( CkSpeed_sleep ) {
      sleep = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 2, 0 );
   }

   // BUY
   if( aroonHornUp >= 100  && ( !CkSpeed_trend || trend > 0 ) && ( !CkSpeed_correction || ( correction > 0 || trend > 0 ) ) && ( !CkSpeed_sleep || ( sleep > 0 || correction > 0 || trend > 0 ) ) ) {
      if( StopLossPips > 0 ) {
         stopLoss = Ask-StopLossPips*pipsRate;
      } else {
         stopLoss = 0;
      }
      if( ProfitPips > 0 ) {
         takeProfit = Ask+ProfitPips*pipsRate;
      } else {
         takeProfit = 0;
      }

      ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, stopLoss, takeProfit, "", Magic, 0, Red );
      lastExeFoot = Time[0];
   }
   // SELL
   if( aroonHornDown >= 100  && ( !CkSpeed_trend || ( trend > 0 || correction > 0 || sleep > 0 ) ) && ( !CkSpeed_correction || ( correction > 0 || sleep > 0 ) ) && ( !CkSpeed_sleep || sleep > 0 ) ) {
      if( StopLossPips > 0 ) {
         stopLoss = Bid+StopLossPips*pipsRate;
      } else {
         stopLoss = 0;
      }
      if( ProfitPips > 0 ) {
         takeProfit = Bid-ProfitPips*pipsRate;
      } else {
         takeProfit = 0;
      }

      ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, stopLoss, takeProfit, "", Magic, 0, Blue );
      lastExeFoot = Time[0];
   }

   return(0);
}

int deinit() {
   return(0);
}

// 小数点を0桁に切る
double dt0( double val ) {
   return( StrToDouble( ( DoubleToStr( val,0 ) ) ) );
}
// 小数点を1桁に切る
double dt1( double val ) {
   return( StrToDouble( ( DoubleToStr( val,1 ) ) ) );
}
// 小数点を2桁に切る
double dt2( double val ) {
   return( StrToDouble( ( DoubleToStr( val,2 ) ) ) );
}
