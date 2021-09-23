#property copyright "Copyright(C) 2021 Studiogadget Inc."
#property strict
#property indicator_chart_window
//--- input parameters
input int      FontSize=12;
input color    FontColor=clrAqua;
input bool     Logging=true;

string Currencies[] = {"EURUSD","GBPUSD","USDCHF","USDJPY","USDCAD","EURJPY",
                       "EURGBP","EURCHF","EURCAD","EURAUD","GBPAUD","GBPCAD",
                       "GBPCHF","AUDCAD","CADCHF","CHFJPY","AUDJPY","AUDCHF",
                       "AUDUSD","GBPJPY"};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ObjectCreate("SpreadLabel", OBJ_LABEL, 0, 0, 0);
   ObjectSet("SpreadLabel", OBJPROP_CORNER, 1);
   ObjectSet("SpreadLabel", OBJPROP_XDISTANCE, 10);
   ObjectSet("SpreadLabel", OBJPROP_YDISTANCE, 15);
//---
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
   {
      ObjectDelete("SpreadLabel");
   }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int digit = Digits;
   if(digit == 3 || digit == 5)
   {
      digit -= 1;
   }

   double spreadTemp = (Ask - Bid) * MathPow(10,digit);
   string spreadValue = DoubleToStr(spreadTemp, 1);
   ObjectSetText("SpreadLabel", spreadValue, FontSize, "Arial", FontColor);

   string periodChar = "";
   string pair = Symbol();
   if(Logging)
   {
      if(StringFind(Symbol(),".",0) > 0)
      {
         periodChar = ".";
      }
      else
      {
         pair += ".";
      }

      int handle;
      string date = TimeToStr(TimeCurrent(), TIME_DATE);
      StringReplace(date, ".", "");
      for (int i = 0; i < ArraySize(Currencies); i++) {
        pair = Currencies[i];
        spreadTemp = MarketInfo(pair, MODE_SPREAD) / 10;
        handle = FileOpen("SpreadLog_"+pair+"_"+date+".csv", FILE_CSV|FILE_READ|FILE_WRITE,",");
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS), DoubleToStr(spreadTemp, 1), "1", "1", "1", "1", "1");
        FileClose(handle);
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
