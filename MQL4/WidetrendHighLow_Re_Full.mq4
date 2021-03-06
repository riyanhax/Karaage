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

   // 決済(1時間足の開始直後30秒未満)
   if( Minute() == 0 && Seconds() < 30 ) {
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
                     // オープンから50分を超えているオーダーを決済
                     if( OrderOpenTime() < TimeCurrent()-1*50*60 ) {
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
                     // オープンから50分を超えているオーダーを決済
                     if( OrderOpenTime() < TimeCurrent()-1*50*60 ) {
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
   }

   return(0);
}

int deinit() {
   return(0);
}
