#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lots = 0.01;
extern datetime OpenTime = D'22:29:59';
extern int OrderEffectiveSec = 5;
extern double LossCutPips = 10; // スプレッドは自動的に考慮される
extern double ProfitPips = 108.0;

double pipsRate;
datetime endTime;
bool buyExecuted;
bool sellExecuted;

int init(){
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point*10;

   endTime = OpenTime+OrderEffectiveSec;
   buyExecuted = false;
   sellExecuted = false;

   return(0);
}

int start(){
   datetime current;
   double limit;
   double support;
   int spread;
   double spreadTemp;
   double spreadDouble;
   int ticket;

   // BUY ORDER
   if( !buyExecuted ) {
      current = TimeLocal();
      if( OpenTime <= current && current <= endTime ) {
         // spread
         spread = MarketInfo(Symbol(),MODE_SPREAD); // 0.5pips → 5 1pips → 10
         spreadTemp = spread;
         spreadDouble = spreadTemp/10;
         // Order
         limit = Ask+ProfitPips*pipsRate;
         support = Ask-(LossCutPips+spreadDouble)*pipsRate;
         ticket = OrderSend( Symbol(),OP_BUY,Lots,Ask,3,support,limit,"BUY ORDER",Magic,0,Red );
         if( ticket > 0 ) {
            buyExecuted = true;
         }
      }
   }
   // SELL ORDER
   if( !sellExecuted ) {
      current = TimeLocal();
      if( OpenTime <= current && current <= endTime ) {
         // spread
         spread = MarketInfo(Symbol(),MODE_SPREAD); // 0.5pips → 5 1pips → 10
         spreadTemp = spread;
         spreadDouble = spreadTemp/10;
         // Order
         limit = Bid-ProfitPips*pipsRate;
         support = Bid+(LossCutPips+spreadDouble)*pipsRate;
         ticket = OrderSend( Symbol(),OP_SELL,Lots,Bid,3,support,limit,"SELL ORDER",Magic,0,Blue );
         if( ticket > 0 ) {
            sellExecuted = true;
         }
      }
   }

   return(0);
}

int deinit(){
   return(0);
}
