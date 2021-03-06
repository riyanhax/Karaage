#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lots = 0.01;
extern int AllPosition = 10;
extern double LossCutPips = 30.0;
extern bool CompoundInterest = true; // 複利
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/green_soybeans/stop_list_w.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定

double lots;
double pipsRate;
datetime lastAlertTime = 0;
int lastExeHour = 99;
int executedDayOfYear = 999;
datetime stopStart[1] = {0};
datetime stopEnd[1] = {0};
bool offFlg = false;
int diffHour;
int handle;
datetime lastErrorTime = 0;

int init() {
   ObjectDelete( "sigma" );

   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   return(0);
}

int start() {
   int dayOfYear = DayOfYear();
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
   string stopList;
   int length;
   int i;
   string tmp;
   int index;
   string today;
   int month;
   int day;
   datetime stopStartDatetime;
   datetime stopEndDatetime;
   datetime now;
   int ticket;
   string msg;
   double spreadTemp;
   double spreadDouble;
   int buyCnt;
   int sellCnt;
   int allCnt;

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0) {
         diffHour = diffHour+24;
      }

      // 単利複利の設定
      if( CompoundInterest ) {
         lots = dts2( AccountBalance()*AccountLeverage()/( 40000000*AllPosition ) );
      } else {
         lots = Lots;
      }

      // 停止時間の取得
      // 配列を初期化
      ArrayInitialize( stopStart, 0 );
      ArrayInitialize( stopEnd, 0 );
      ArrayResize( stopStart, 1 );
      ArrayResize( stopEnd, 1 );
      GrabWeb( StopListUrl, stopList );
      length = StringLen( stopList );
      if( length == 0 ) {
         Alert( "Error Load StopList" );
      }
      if( length >= 13 ) {
         index = length/13;

         month = TimeMonth( TimeCurrent() );
         day = TimeDay( TimeCurrent() );
         if( month < 10 ) {
            today = today+"0"+Month();
         } else {
            today = today+Month();
         }
         if( day < 10 ) {
            today = today+"0"+Day();
         } else {
            today = today+Day();
         }

         for( i = 0; i < index; i++ ) {
            tmp = StringSubstr( stopList, i*13, 12 );
            if( StringSubstr( tmp, 0, 4 ) == today ) {
               stopStartDatetime = StrToTime( Year()+"."+month+"."+day+" "+StringSubstr( tmp, 4, 2 )+":"+StringSubstr( tmp, 6, 2 ) );
               stopEndDatetime = StrToTime( Year()+"."+month+"."+day+" "+StringSubstr( tmp, 8, 2 )+":"+StringSubstr( tmp, 10, 2 ) );
               stopStart[ArraySize( stopStart )-1] = stopStartDatetime;
               stopEnd[ArraySize( stopEnd )-1] = stopEndDatetime;
               ArrayResize( stopStart, ArraySize( stopStart )+1 );
               ArrayResize( stopEnd, ArraySize( stopEnd )+1 );
               Print( "StopStart: "+TimeToStr( stopStartDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES ) );
               Print( "StopEnd: "+TimeToStr( stopEndDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES ) );
            }
         }
      }

      executedDayOfYear = dayOfYear;
   }

   // 経済指標時間帯は停止
   now = TimeCurrent();
   for( i=0; i < ArraySize( stopStart )-1; i++ ){
      if( stopStart[i] <= now && now < stopEnd[i] ) {
         return(0);
      }
   }

   // 6、7時代は停止
   if( TimeHour( TimeLocal() ) == 6 || TimeHour( TimeLocal() ) == 7 ) {
      return(0);
   }

   // 1時間足の開始直後30秒以降に1回のみ動作
   if( lastExeHour == Hour() ) {
      return(0);
   }
   if( Seconds() < 30 ) {
      return(0);
   }
   if( Minute() > 5 ) {
      return(0);
   }
   lastExeHour = Hour();

   // Check Position
   if( OrdersTotal() > 0) {
      for( i=0; i<OrdersTotal(); i++ ) {
         if( OrderSelect(i, SELECT_BY_POS) == true && OrderMagicNumber() == Magic ) {
            if( OrderType() == OP_BUY ) {
               buyCnt++;
            } else if( OrderType() == OP_SELL ){
               sellCnt++;
            }
         }
      }
   }
   allCnt = buyCnt+sellCnt;
   if( allCnt >= AllPosition ) {
      return(0);
   }

   // パラメータ
   double currentPrice = Close[0];
   double macd_H4 = iMACD(Symbol(),PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double macd_H1 = iMACD(Symbol(),PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_M30 = iMACD(Symbol(),PERIOD_M30,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_M15 = iMACD(Symbol(),PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_M5 = iMACD(Symbol(),PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_M1 = iMACD(Symbol(),PERIOD_M1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double signal_H4 = iMACD(Symbol(),PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   double signal_H1 = iMACD(Symbol(),PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double signal_M30 = iMACD(Symbol(),PERIOD_M30,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double signal_M15 = iMACD(Symbol(),PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double signal_M5 = iMACD(Symbol(),PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double signal_M1 = iMACD(Symbol(),PERIOD_M1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);

   int spread = MarketInfo(Symbol(),MODE_SPREAD); // 0.5pips → 5 1pips → 10
   spreadTemp = spread;
   spreadDouble = spreadTemp/10;

   // HIGH開始条件
   // MACDが上昇(H4~M1)
   if( macd_H4 > signal_H4 && macd_H1 > signal_H1 && macd_M30 > signal_M30 && macd_M15 > signal_M15 && macd_M5 > signal_M5 && macd_M1 > signal_M1 ) {

      ticket = OrderSend( Symbol(),OP_BUY,lots,Ask,3,Bid-LossCutPips*pipsRate,0,spreadDouble,Magic,0,Red);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            SendMail( "ErrorBuyOrder.["+Symbol()+"] "+GetLastError(), "Execution time: " + time );
            lastErrorTime = Time[0];
         }
      } else {
         SendMail( "BuyOrder.["+Symbol()+"] ", "Execution time: " + time );
      }
   }

   // LOW開始条件
   // MACDが下降(H4~M1)
   if( macd_H4 < signal_H4 && macd_H1 < signal_H1 && macd_M30 < signal_M30 && macd_M15 < signal_M15 && macd_M5 < signal_M5 && macd_M1 < signal_M1 ) {

      ticket = OrderSend( Symbol(),OP_SELL,lots,Bid,3,Ask+LossCutPips*pipsRate,0,spreadDouble,Magic,0,Blue);
      if( ticket < 0 ) {
         if( lastErrorTime != Time[0] ) {
            SendMail( "ErrorSellOrder.["+Symbol()+"] "+GetLastError(), "Execution time: " + time );
            lastErrorTime = Time[0];
         }
      } else {
         SendMail( "SellOrder.["+Symbol()+"] ", "Execution time: " + time );
      }
   }

   return(0);
}

int deinit() {
   return(0);
}

// 小数点を2桁に切る
double dts2(double val) {
   return(StrToDouble((DoubleToStr(val,2))));
}

//=================================================================================================
//=================================================================================================
//====================================   GrabWeb Functions   ======================================
//=================================================================================================
//=================================================================================================
// Main Webscraping function
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// bool GrabWeb(string strUrl, string& strWebPage)
// returns the text of any webpage. Returns false on timeout or other error
//
// Parsing functions
// ~~~~~~~~~~~~~~~~~
// string GetData(string strWebPage, int nStart, string strLeftTag, string strRightTag, int& nPos)
// obtains the text between two tags found after nStart, and sets nPos to the end of the second tag
//
// void Goto(string strWebPage, int nStart, string strTag, int& nPos)
// Sets nPos to the end of the first tag found after nStart

bool bWinInetDebug = true;

int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig = 0;
int Internet_Open_Type_Direct = 1;
int Internet_Open_Type_Proxy = 3;
int Buffer_LEN = 1000;

#import "wininet.dll"

#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 // Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 // Does not add the returned entity to the cache.
#define INTERNET_FLAG_RELOAD            0x80000000 // Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.

int InternetOpenW(
   string   sAgent,
   int      lAccessType,
   string   sProxyName="",
   string   sProxyBypass="",
   int   lFlags=0
);

int InternetOpenUrlW(
   int   hInternetSession,
   string   sUrl,
   string   sHeaders="",
   int   lHeadersLength=0,
   int   lFlags=0,
   int   lContext=0
);

int InternetReadFile(
   int   hFile,
   uchar&   sBuff[],
   int   lNumBytesToRead,
   int&  lNumberOfBytesRead[]
);

int InternetCloseHandle(
   int   hInet
);
#import


int hSession(bool Direct) {
   string InternetAgent;
   if (hSession_IEType == 0){
      InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
      hSession_IEType = InternetOpenW(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0);
      hSession_Direct = InternetOpenW(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
   }
   if (Direct) {
      return(hSession_Direct);
   }else {
      return(hSession_IEType);
   }
}


bool GrabWeb(string strUrl, string& strWebPage) {
   int   hInternet;
   int      iResult;
   int   lReturn[]   = {1};
   uchar   sBuff[];
   ArrayResize( sBuff, Buffer_LEN+1 );
   hInternet = InternetOpenUrlW(hSession(FALSE), strUrl, NULL, 0, INTERNET_FLAG_NO_CACHE_WRITE|INTERNET_FLAG_PRAGMA_NOCACHE|INTERNET_FLAG_RELOAD, 0);

   if (bWinInetDebug) Print("hInternet: " + hInternet);
   if (hInternet == 0) return(false);

   if (bWinInetDebug) Print("Reading URL: " + strUrl);
   iResult = InternetReadFile(hInternet, sBuff, Buffer_LEN, lReturn);
   strWebPage = CharArrayToString(sBuff, 0, lReturn[0], CP_UTF8);

   if (bWinInetDebug) Print("iResult: " + iResult);
   if (bWinInetDebug) Print("lReturn: " + lReturn[0]);
   if (bWinInetDebug) Print("strWebPage: " +  strWebPage);
   if (iResult == 0)  return(false);

   return(true);
}
