#property copyright "Copyright(C) 2018 Studiogadget Inc."

#property indicator_chart_window

extern int DiffHour = 6;

datetime lastAlertTime = 0;
datetime lastLongTime = 0;
datetime lastShortTime = 0;
datetime lastMttOffTime = 0;
string timeShift;

double buyOrder = 0.0;
double sellOrder = 0.0;
double mttUp = 0.0;
double mttDown = 0.0;
double mttUp2 = 0.0;
double mttDown2 = 0.0;
double mttUp3 = 0.0;
double mttDown3 = 0.0;

int init() {
   int ts = Period();
   if( ts == PERIOD_M1 ) {
      timeShift = "M1";
   } else if( ts == PERIOD_M5 ) {
      timeShift = "M5";
   } else if( ts == PERIOD_M15 ) {
      timeShift = "M15";
   } else if( ts == PERIOD_M30 ) {
      timeShift = "M30";
   } else if( ts == PERIOD_H1 ) {
      timeShift = "H1";
   } else if( ts == PERIOD_H4 ) {
      timeShift = "H4";
   } else if( ts == PERIOD_D1 ) {
      timeShift = "D1";
   } else if( ts == PERIOD_W1 ) {
      timeShift = "W1";
   }

   return(0);
}

int start() {
   string time = TimeToStr( TimeCurrent()+DiffHour*60*60, TIME_DATE|TIME_SECONDS );

   // パラメータ
   if( lastAlertTime != Time[0] ) {
      lastAlertTime = Time[0];
      buyOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",2,1);
      sellOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",3,1);
      mttUp = iCustom(Symbol(),PERIOD_CURRENT,"MTT",4,1);
      mttDown = iCustom(Symbol(),PERIOD_CURRENT,"MTT",5,1);
      mttUp2 = iCustom(Symbol(),PERIOD_CURRENT,"MTT",4,2);
      mttDown2 = iCustom(Symbol(),PERIOD_CURRENT,"MTT",5,2);
      mttUp3 = iCustom(Symbol(),PERIOD_CURRENT,"MTT",4,3);
      mttDown3 = iCustom(Symbol(),PERIOD_CURRENT,"MTT",5,3);
   }

   // VGFX Long
   if( buyOrder != EMPTY_VALUE && buyOrder != 0 && lastLongTime != Time[0] ) {
      lastLongTime = Time[0];
      if( mttUp != EMPTY_VALUE && mttUp != 0 ) {
         SendMail( "VGFX Alert ["+Symbol()+"_"+timeShift+"]", "Symbol: "+Symbol()+"\r\n"+"TimeShift: "+timeShift+"\r\n"+"VGFX: Long"+"\r\n"+"MTT: Long"+"\r\n"+"Time: "+time );
      } else if( mttDown != EMPTY_VALUE && mttDown != 0 ) {
         SendMail( "VGFX Alert ["+Symbol()+"_"+timeShift+"]", "Symbol: "+Symbol()+"\r\n"+"TimeShift: "+timeShift+"\r\n"+"VGFX: Long"+"\r\n"+"MTT: Short"+"\r\n"+"Time: "+time );
      } else {
         SendMail( "VGFX Alert ["+Symbol()+"_"+timeShift+"]", "Symbol: "+Symbol()+"\r\n"+"TimeShift: "+timeShift+"\r\n"+"VGFX: Long"+"\r\n"+"MTT: None"+"\r\n"+"Time: "+time );
      }
   }

   // VGFX Short
   if( sellOrder != EMPTY_VALUE && sellOrder != 0 && lastShortTime != Time[0] ) {
      lastShortTime = Time[0];
      if( mttUp != EMPTY_VALUE && mttUp != 0 ) {
         SendMail( "VGFX Alert ["+Symbol()+"_"+timeShift+"]", "Symbol: "+Symbol()+"\r\n"+"TimeShift: "+timeShift+"\r\n"+"VGFX: Short"+"\r\n"+"MTT: Long"+"\r\n"+"Time: "+time );
      } else if( mttDown != EMPTY_VALUE && mttDown != 0 ) {
         SendMail( "VGFX Alert ["+Symbol()+"_"+timeShift+"]", "Symbol: "+Symbol()+"\r\n"+"TimeShift: "+timeShift+"\r\n"+"VGFX: Short"+"\r\n"+"MTT: Short"+"\r\n"+"Time: "+time );
      } else {
         SendMail( "VGFX Alert ["+Symbol()+"_"+timeShift+"]", "Symbol: "+Symbol()+"\r\n"+"TimeShift: "+timeShift+"\r\n"+"VGFX: Short"+"\r\n"+"MTT: None"+"\r\n"+"Time: "+time );
      }
   }

   // MTT Off
   if( ( ( mttUp3 != EMPTY_VALUE && mttUp3 != 0 ) || ( mttDown3 != EMPTY_VALUE && mttDown3 != 0 ) )
      && ( mttUp2 == EMPTY_VALUE || mttUp2 == 0 )
      && ( mttDown2 == EMPTY_VALUE || mttDown2 == 0 )
      && ( mttUp == EMPTY_VALUE || mttDown == 0 )
      && ( mttDown == EMPTY_VALUE || mttDown == 0 )
      && lastMttOffTime != Time[0] ) {
      lastMttOffTime = Time[0];
      SendMail( "MTT Range Alert ["+Symbol()+"_"+timeShift+"]", "Symbol: "+Symbol()+"\r\n"+"TimeShift: "+timeShift+"\r\n"+"Time: "+time );
   }

   return(0);
}

int deinit() {
   return(0);
}
