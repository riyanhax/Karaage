#property copyright "Copyright(C) 2015 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lots = 1.00;
extern int MttLimit = 1; // MTTの制限 1 < 2 < 3
extern double ProfitPips = 0.0;

double pipsRate;
datetime lastOrderTime = 0;
datetime lastLossCutTime = 0;

int init(){
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   return(0);
}

int start(){
   int buyCnt;
   int sellCnt;
   int allCnt;
   string mtt;
   double shortLimit;
   double support;
   double resistance;
   int ticket;
   int errChk;
   int i;
   int dayOfYear = DayOfYear();
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );

   // Check Position
   if( OrdersTotal() > 0){
      for( i=0; i<OrdersTotal(); i++ ){
         if( OrderSelect(i, SELECT_BY_POS) == true && OrderMagicNumber() == Magic ){
            allCnt++;
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

   // 決済
   double buySign = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",false,false,false,false,false,false,"XRT7-949X-E1S6","5F67-G69W-5929",1,1);
   double sellSign = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",false,false,false,false,false,false,"XRT7-949X-E1S6","5F67-G69W-5929",0,1);
   if( allCnt > 0 && lastOrderTime != Time[0] && lastLossCutTime != Time[0] ) {
      if( ( buySign != EMPTY_VALUE && buySign != 0 ) || ( sellSign != EMPTY_VALUE && sellSign != 0 ) ) {
         while( !IsStopped() ) {
            errChk = 0;
            for( i=OrdersTotal()-1; i>=0; i-- ) {
               if( OrderSelect(i, SELECT_BY_POS) == true ) {
                  if( OrderType() == OP_BUY && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Bid,3,Green)) ) {
                        // 決済成功
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
         while( !IsStopped() ) {
            errChk = 0;
            for( i=OrdersTotal()-1; i>=0; i-- ) {
               if( OrderSelect(i, SELECT_BY_POS) == true ) {
                  if( OrderType() == OP_SELL && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
                     if( (OrderClose(OrderTicket(),OrderLots(),Ask,3,Green)) ){
                        // 決済成功
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
      lastLossCutTime = Time[0];
   }

   // MTT
   double mttUp = iCustom(Symbol(),PERIOD_CURRENT,"MTT",4,1);
   double mttDown = iCustom(Symbol(),PERIOD_CURRENT,"MTT",5,1);
   if( mttUp != EMPTY_VALUE && mttUp != 0 ) {
      mtt = "UP";
   } else if(mttDown != EMPTY_VALUE && mttDown != 0) {
      mtt = "DOWN";
   } else {
      mtt = "PLAIN";
   }

   // BUY ORDER
   if( lastOrderTime != Time[0] ) {
      double buyOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",false,false,false,false,false,false,"XRT7-949X-E1S6","5F67-G69W-5929",2,1);
      if( buyOrder != EMPTY_VALUE && buyOrder != 0 ) {
         if( MttLimit == 1 || ( MttLimit == 2 && mtt != "DOWN" ) || ( MttLimit == 3 && mtt == "UP" ) ) {
            support = 0;
            if( ProfitPips == 0.0 ) {
               shortLimit = 0;
            } else {
               shortLimit = Ask+ProfitPips*pipsRate;
            }
            ticket = OrderSend( Symbol(),OP_BUY,Lots,Ask,3,support,shortLimit,"BUY ORDER",Magic,0,Red);
            lastOrderTime = Time[0];
         }
      }
   }

   // SELL ORDER
   if( lastOrderTime != Time[0] ) {
      double sellOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",false,false,false,false,false,false,"XRT7-949X-E1S6","5F67-G69W-5929",3,1);
      if( sellOrder != EMPTY_VALUE && sellOrder != 0 ) {
         if( MttLimit == 1 || ( MttLimit == 2 && mtt != "UP" ) || ( MttLimit == 3 && mtt == "DOWN" ) ) {
            resistance = 0;
            if( ProfitPips == 0.0 ) {
               shortLimit = 0;
            } else {
               shortLimit = Bid-ProfitPips*pipsRate;
            }
            ticket = OrderSend( Symbol(),OP_SELL,Lots,Bid,3,resistance,shortLimit,"SELL ORDER",Magic,0,Blue);
            lastOrderTime = Time[0];
         }
      }
   }

   return(0);
}

int deinit(){
   return(0);
}

// 小数点を2桁に切る
double dts2(double val) {
   return(StrToDouble((DoubleToStr(val,2))));
}
