#property copyright "Copyright(C) 2016 Studiogadget Inc."


double pipsRate;
int lastError = 0;
datetime lastErrorTime = 0;

int init(){
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;
   return(0);
}

int start(){
   double currentProfitPips;
   int tempInt;
   int supportCount;
   double fixedProfitPips;
   double supportLine;
   bool res;
   int i;
   string msg;
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );

   // Check Position
   if( OrdersTotal() > 0){
      for( i=0; i<OrdersTotal(); i++ ){
         if( OrderSelect(i, SELECT_BY_POS) == true ){
            if( OrderSymbol() == Symbol() ) {
               // Support Line
               if( OrderType() == OP_BUY ){
                  currentProfitPips = ( Bid-OrderOpenPrice() )/pipsRate;
                  if( currentProfitPips >= 40 ) {
                     tempInt = (currentProfitPips-40)/10;
                     supportCount = tempInt-1;
                     fixedProfitPips = 40+supportCount*10;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 35 ) {
                     fixedProfitPips = 20;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 27 ) {
                     fixedProfitPips = 12;
                     supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                  }
                  if( supportLine > 0 && OrderStopLoss() < supportLine ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Blue );
                     if( !res ) {
                        msg = "Error Modify BuyOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                        if( lastErrorTime != Time[0] || lastError != GetLastError() ) {
                           SendMail( "[ERROR] ScalpingTool", msg );
                           lastError = GetLastError();
                           lastErrorTime = Time[0];
                        }
                        Print( msg );
                     } else {
                        if( fixedProfitPips > 0 ) {
                           msg = "MOD BUY ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] ScalpingTool", msg );
                           Print( msg );
                        }
                     }
                  }
               }else if( OrderType() == OP_SELL ){
                  currentProfitPips = ( OrderOpenPrice()-Ask )/pipsRate;
                  if( currentProfitPips >= 40 ) {
                     tempInt = (currentProfitPips-40)/10;
                     supportCount = tempInt-1;
                     fixedProfitPips = 40+supportCount*10;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 35 ) {
                     fixedProfitPips = 20;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  } else if( currentProfitPips >= 27 ) {
                     fixedProfitPips = 12;
                     supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                  }
                  if( supportLine > 0 && OrderStopLoss() > supportLine ) {
                     res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                     if( !res ) {
                        msg = "Error Modify SellOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                        if( lastErrorTime != Time[0] || lastError != GetLastError() ) {
                           SendMail( "[ERROR] ScalpingTool", msg );
                           lastError = GetLastError();
                           lastErrorTime = Time[0];
                        }
                        Print( msg );
                     } else {
                        if( fixedProfitPips > 0 ) {
                           msg = "MOD SELL ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                           SendMail( "[MOD] ScalpingTool", msg );
                           Print( msg );
                        }
                     }
                  }
               }
            }
         }
      }
   }

   return(0);
}

int deinit(){
   return(0);
}
