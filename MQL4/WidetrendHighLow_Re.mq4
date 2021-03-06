#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;

int init() {
   return(0);
}

int start() {
   int buyCnt;
   int sellCnt;
   int errChk;
   int i;

   // Check Position
   if( OrdersTotal() > 0) {
      for( i=0; i<OrdersTotal(); i++ ) {
         if( OrderSelect(i, SELECT_BY_POS) == true && OrderMagicNumber() == Magic ) {
            if( OrderType() == OP_BUY ) {
               buyCnt++;
            } else if( OrderType() == OP_SELL ){
               sellCnt++;
            }
         }
      }
   }

   if( buyCnt > 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         for( i=OrdersTotal()-1; i>=0; i-- ) {
            if( OrderSelect(i, SELECT_BY_POS) == true ) {
               if( OrderType() == OP_BUY && OrderMagicNumber() == Magic ) {
                  // オープンから50分を超えているオーダーは1時間足の切り替わり時に決済
                  if( Minute() == 0 && Seconds() < 30 && OrderOpenTime() < TimeCurrent()-50*60 ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Bid,3,Green)) ) {
                        buyCnt--;
                     } else {
                        errChk = 1;
                     }
                  // 毎時15、30、45分にプラスが出ている場合は決済
                  } else if( ( Minute() == 15 && Seconds() < 10 || Minute() == 30 && Seconds() < 10 || Minute() == 45 && Seconds() < 10 ) && OrderProfit() > 0 ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Bid,3,Green)) ) {
                        buyCnt--;
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
         Sleep(500);
         RefreshRates();
      }
   }
   if( sellCnt > 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         for( i=OrdersTotal()-1; i>=0; i-- ) {
            if( OrderSelect(i, SELECT_BY_POS) == true ) {
               if( OrderType() == OP_SELL && OrderMagicNumber() == Magic ) {
                  // オープンから50分を超えているオーダーは1時間足の切り替わり時に決済
                  if( Minute() == 0 && Seconds() < 30 && OrderOpenTime() < TimeCurrent()-50*60 ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Ask,3,Green)) ){
                        sellCnt--;
                     } else {
                        errChk = 1;
                     }
                  // 毎時15、30、45分にプラスが出ている場合は決済
                  } else if( ( Minute() == 15 && Seconds() < 10 || Minute() == 30 && Seconds() < 10 || Minute() == 45 && Seconds() < 10 ) && OrderProfit() > 0 ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Ask,3,Green)) ){
                        sellCnt--;
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
         Sleep(500);
         RefreshRates();
      }
   }

   return(0);
}

int deinit() {
   return(0);
}
