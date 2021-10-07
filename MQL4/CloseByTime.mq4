#property copyright "Copyright(C) 2021 Studiogadget Inc."

extern int CloseMin = 120;
extern string CloseSymbol = "ALL"; // ALLの場合はすべて
extern int MagicNumber = 0; // 0の場合はすべて
extern string Comment = "ALL"; // ALLの場合はすべて
extern bool OnlyIfProfitable = true;
extern double ProfitMargin = 0.9;

void OnTick(){
  int errChk;
  int i;

  // 決済処理
  if( OrdersTotal() > 0) {
    for( i=0; i<OrdersTotal(); i++ ) {
       if( OrderSelect(i, SELECT_BY_POS) == true ) {
          if( CloseSymbol == "ALL" || OrderSymbol() == CloseSymbol ) {
            if( MagicNumber == 0 || OrderMagicNumber() == MagicNumber ) {
              if( Comment == "ALL" || StringFind( OrderComment(), Comment, 0 ) >= 0 ) {
                if( OrderOpenTime() + ( CloseMin * 60 ) < TimeCurrent() ) {
                  if(OnlyIfProfitable) {
                    if(OrderProfit()*ProfitMargin + OrderSwap() + OrderCommission() <= 0) {
                      return;
                    }
                  }
                  // Ordedr Close
                  if( OrderType() == OP_BUY ) {
                     while( !IsStopped() ) {
                       errChk = 0;
                       if( !OrderClose( OrderTicket(),OrderLots(),Bid,3,CLR_NONE ) ) {
                          errChk = 1;
                       }
                       if( errChk == 0 ) {
                        break;
                       }
                       Print( "Order Close Failure." );
                       Sleep(500);
                       RefreshRates();
                    }
                  } else if( OrderType() == OP_SELL ) {
                     while( !IsStopped() ) {
                       errChk = 0;
                       if( !OrderClose( OrderTicket(),OrderLots(),Ask,3,CLR_NONE ) ) {
                          errChk = 1;
                       }
                       if( errChk == 0 ) {
                         break;
                       }
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

