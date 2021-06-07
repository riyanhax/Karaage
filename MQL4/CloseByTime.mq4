#property copyright "Copyright(C) 2021 Studiogadget Inc."

extern int CloseMin = 10;
extern string CloseSymbol = "ALL"; // ALLの場合はすべて
extern int MagicNumber = 0; // 0の場合はすべて
extern string Comment = "";

void OnTick(){
  int errChk;
  int i;

  // 決済処理
  if( OrdersTotal() > 0){
    for( i=0; i<OrdersTotal(); i++ ){
       if( OrderSelect(i, SELECT_BY_POS) == true ){
          if( CloseSymbol == "ALL" || OrderSymbol() == CloseSymbol ) {
            if( MagicNumber == 0 || OrderMagicNumber() == MagicNumber ) {
              if( OrderOpenTime() + ( CloseMin * 60 ) < TimeCurrent() ) {
                if( OrderType() == OP_BUY ) {
                   while( !IsStopped() ) {
                     errChk = 0;
                     if( !OrderClose( OrderTicket(),OrderLots(),Bid,3,Green ) ){
                        errChk = 1;
                     }
                     if( errChk == 1 ) {
                      Print( "Order Close Failure." );
                       Sleep(500);
                       RefreshRates();
                     }
                  }
                } else if( OrderType() == OP_SELL ) {
                   while( !IsStopped() ) {
                     errChk = 0;
                     if( !OrderClose( OrderTicket(),OrderLots(),Ask,3,Green ) ){
                        errChk = 1;
                     }
                     if( errChk == 1 ) {
                      Print( "Order Close Failure." );
                       Sleep(500);
                       RefreshRates();
                     }
                  }
                }
              }
            }
          }
        }
     }
  }
}

