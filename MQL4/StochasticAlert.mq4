#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern bool Mail = true;
extern bool Alert = true;
extern bool BackgroundColor = true;

datetime lastHighExeTime = 0;
datetime lastLowExeTime = 0;
datetime lastAlertTime = 0;
int executedDayOfYear = 999;
int diffHour;

int init() {
   ObjectDelete( "sigma" );
   return(0);
}

int start() {
   int dayOfYear = DayOfYear();
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0) {
         diffHour = diffHour+24;
      }

      executedDayOfYear = dayOfYear;
   }

   // パラメータ
   iStochastic( Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
   double buySign = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",1,1);
   double sellSign = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",0,1);
   double buyOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",2,1);
   double sellOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",3,1);
   double confirmedPrice = Close[1];

   // SIGN
   if( ( buySign != EMPTY_VALUE && buySign != 0 ) || ( sellSign != EMPTY_VALUE && sellSign != 0 ) ) {
      if( lastAlertTime != Time[0] ) {
         setBackground( "SIGN" );
         alert( "SIGN", confirmedPrice, time );
         lastAlertTime = Time[0];
      }
   }
   // ORDER
   if( ( buyOrder != EMPTY_VALUE && buyOrder != 0 ) || ( sellOrder != EMPTY_VALUE && sellOrder != 0)  ) {
      if( lastAlertTime != Time[0] ) {
         setBackground( "ORDER" );
         alert( "ORDER", confirmedPrice, time );
         lastAlertTime = Time[0];
      }
   }
   if( lastAlertTime != Time[0] ) {
      defaultBackground();
   }

   return(0);
}

int deinit() {
   return(0);
}

int alert( string sigma, double price, string time ) {
   if( Mail ) {
      SendMail( "SigmaAlert", "["+Symbol()+"] "+price+"\r\nsigma: "+sigma+"\r\ntime: "+time );
   }
   if( Alert ) {
      if( sigma == "SIGN" ) {
         PlaySound("manual.wav");
      } else if( sigma == "ORDER" ) {
         PlaySound("sigma.wav");
      } else if( sigma == "END" ) {
         PlaySound("timeout.wav");
      }
   }
   return(0);
}

int setBackground( string sigma ) {
   if( BackgroundColor ) {
      ObjectCreate( "sigma", OBJ_RECTANGLE, 0, 0, 0, TimeCurrent()+120*60, 200, 0, 0 );
      if( sigma == "SIGN" ) {
         ObjectSet( "sigma", OBJPROP_COLOR, Khaki );
      } else if( sigma == "ORDER" ) {
         ObjectSet( "sigma", OBJPROP_COLOR, Violet );
      } else if( sigma == "OFF" ) {
         ObjectSet( "sigma", OBJPROP_COLOR, Gray );
      }
   }
}

int defaultBackground() {
   if( BackgroundColor ) {
      ObjectDelete( "sigma" );
   }

   return(0);
}
