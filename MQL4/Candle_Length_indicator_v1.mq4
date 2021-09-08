//+------------------------------------------------------------------+
//|                                      wajdyss_H_L_C_indicator.mq4 |
//|                                           Copyright 2008 Wajdyss |
//|                                                wajdyss@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2008 Wajdyss"
#property link      "wajdyss@yahoo.com"

#property indicator_chart_window
extern int Candle=1;
extern int TextSize=9;
extern color TextColor=White;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  Comment("");
  ObjectDelete("d label");
  ObjectDelete("e label");

  return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  double H=iHigh(Symbol(),PERIOD_D1,0);
  int H2=H;

  // if (Period()>1440) return(0);
  double A=((iHigh(Symbol(),0,Candle)-iLow(Symbol(),0,Candle))/Point);
  int AA=A;

  ObjectDelete("d label");
  ObjectCreate("d label", OBJ_LABEL, 0,0,0);
  ObjectSetText("d label","Candle Length = " + AA, TextSize, "Arial Bold", TextColor);
  ObjectSet("d label", OBJPROP_XDISTANCE,230);
  ObjectSet("d label", OBJPROP_YDISTANCE,15);

  ObjectDelete("e label");
  ObjectCreate("e label", OBJ_LABEL, 0,0,0);
  ObjectSetText("e label","Current Spread = " + MarketInfo( Symbol(), MODE_SPREAD ) , TextSize, "Arial Bold", TextColor);
  ObjectSet("e label", OBJPROP_XDISTANCE,230);
  ObjectSet("e label", OBJPROP_YDISTANCE,30);

  return(0);
}

