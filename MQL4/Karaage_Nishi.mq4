#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lots = 0.01;

double pipsRate;
datetime lastBuyOrderTime = 0;
datetime lastSellOrderTime = 0;

int init(){
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point*10;

   return(0);
}

int start(){
   int spread;
   double spreadTemp;
   double spreadDouble;
   int ticket;
   int errChk;
   int i;
   int buyCnt;
   int sellCnt;

   // MT4時間の23:59に実行
   if( TimeHour( TimeCurrent() ) == 23 && TimeMinute( TimeCurrent() ) >= 59 ) {
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
                     // すべてのオーダーを決済
                     if( (OrderClose(OrderTicket(),OrderLots(),Bid,3,Green)) ) {
                        buyCnt--;
                     } else {
                        errChk = 1;
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
                  if( OrderType() == OP_SELL && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
                     // すべてのオーダーを決済
                     if( (OrderClose(OrderTicket(),OrderLots(),Ask,3,Green)) ){
                        sellCnt--;
                     } else {
                        errChk = 1;
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



   // BUY ORDER
   if( lastBuyOrderTime != Time[0] ) {
      // spread
      spread = MarketInfo(Symbol(),MODE_SPREAD); // 0.5pips → 5 1pips → 10
      spreadTemp = spread;
      spreadDouble = spreadTemp/10;
      ticket = OrderSend( Symbol(),OP_BUY,Lots,Ask,3,0,0,spreadDouble,Magic,0,Red );

      lastBuyOrderTime = Time[0];
   }
   // SELL ORDER
   if( lastSellOrderTime != Time[0] ) {
      // spread
      spread = MarketInfo(Symbol(),MODE_SPREAD); // 0.5pips → 5 1pips → 10
      spreadTemp = spread;
      spreadDouble = spreadTemp/10;
      ticket = OrderSend( Symbol(),OP_SELL,Lots,Bid,3,0,0,spreadDouble,Magic,0,Blue );

      lastSellOrderTime = Time[0];
   }

   return(0);
}

int deinit(){
   return(0);
}
