#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern double Lots = 0.01;
extern double ProfitPips = 0.0;
extern double StopLossPips = 10.0;
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
   int ticket;
   int allCnt;
   double trendCci;
   double entryCci;
   double rsi;
   double stopLoss;
   double takeProfit;
   int heikinashi; // Up:1 Down:-1 Unknown:0
   double heikinashi1;
   double heikinashi2;
   double heikinashi3;
   double heikinashi4;
   int errChk;

   // Check Position
   if( OrdersTotal() > 0){
      for( i=0; i<OrdersTotal(); i++ ){
         if( OrderSelect(i, SELECT_BY_POS) == true && OrderMagicNumber() == Magic ){
            allCnt++;
         }
      }
   }

   // 決済
   trendCci = iCustom( Symbol(), PERIOD_CURRENT, "DoublecciWoody", 170, 34, 2, 1000, false, 2, 3, 2, 4, 1 );
   heikinashi1 = iCustom( Symbol(), PERIOD_CURRENT, "Heiken_Ashi_Smoothed", 2, 6, 3, 2, 0, 1 );
   heikinashi2 = iCustom( Symbol(), PERIOD_CURRENT, "Heiken_Ashi_Smoothed", 2, 6, 3, 2, 1, 1 );
   heikinashi3 = iCustom( Symbol(), PERIOD_CURRENT, "Heiken_Ashi_Smoothed", 2, 6, 3, 2, 2, 1 );
   heikinashi4 = iCustom( Symbol(), PERIOD_CURRENT, "Heiken_Ashi_Smoothed", 2, 6, 3, 2, 3, 1 );
   if( heikinashi1 < heikinashi2 ) {
      heikinashi = 1;
   } else if( heikinashi1 > heikinashi2 ) {
      heikinashi = -1;
   } else {
      heikinashi = 0;
   }
   if( allCnt > 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         if( OrdersTotal() > 0){
            for( i=0; i<OrdersTotal(); i++ ){
               if( OrderSelect(i, SELECT_BY_POS) == true ){
                  if( OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
                     // 買いポジション決済
                     if( OrderType() == OP_BUY ) {
                        if( heikinashi == -1 || trendCci <= 0 ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                              errChk = 1;
                           } else {
                              allCnt--;
                           }
                        }
                     // 売りポジション決済
                     } else {
                        if( heikinashi == 1 || trendCci >= 0 ) {
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

   // 同じ足ではエントリーしない
   if( Time[0] == lastExeFoot ) {
      return(0);
   }

   entryCci = iCustom( Symbol(), PERIOD_CURRENT, "DoublecciWoody", 170, 34, 2, 1000, false, 2, 3, 2, 5, 1 );
   rsi = iRSI( Symbol(), PERIOD_CURRENT, 8, PRICE_CLOSE, 1 );

   // SELL
   if( trendCci < 0 && entryCci < 0 && rsi < 45 && heikinashi != 1 ) {
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

   // BUY
   if( trendCci >0 && entryCci > 0 && rsi > 55 && heikinashi != -1 ) {
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
