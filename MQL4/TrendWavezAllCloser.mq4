#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double AllClose = 0; // 0の場合は無効、0.01ロットで100円程度が適当か？

double pipsRate;
int executedDayOfYear = 999;
int diffHour;

int init() {
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;
   return(0);
}

int start() {
   int i;
   int dayOfYear = DayOfYear();
   int errChk;

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0 ) {
         diffHour = diffHour+24;
      }

      executedDayOfYear = dayOfYear;
   }

   // 全決済
   if( AllClose > 0 ) {
      if( AccountProfit() >= AllClose ) {
         while( !IsStopped() ) {
            errChk = 0;
            if( OrdersTotal() > 0){
               for( i=0; i<OrdersTotal(); i++ ){
                  if( OrderSelect(i, SELECT_BY_POS) == true ){
                     if( OrderMagicNumber() == Magic || OrderMagicNumber() == Magic+1 || OrderMagicNumber() == Magic+2 ) {
                        // 買いポジション決済
                        if( OrderType() == OP_BUY ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                              errChk = 1;
                           }
                        // 売りポジション決済
                        } else {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green ) ) ) {
                              errChk = 1;
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
   }

   return(0);
}

int deinit() {
   return(0);
}
