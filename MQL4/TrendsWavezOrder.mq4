#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lot = 0.01; // 100万円で0.01ロット
extern double TpPips = 0.0;
extern double LcPips = 0.0;
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/green_soybeans/stop_list_dummy.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定

double pipsRate;
int executedDayOfYear = 999;
datetime stopStart[1] = {0};
datetime stopEnd[1] = {0};
bool offFlg = false;
int diffHour;
datetime lastOrderTime5 = 0;

int init() {
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
   double rci_5;
   double rci_15;
   double rci_30;
   double stc14_5;
   double stc14_15;
   double stc14_30;
   double stc5_5;
   double stc5_15;
   double stc5_30;
   double price;
   datetime dt;
   int ticket;


   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0) {
         diffHour = diffHour+24;
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

   // 1日の最初の30分は停止
   if( Hour() == 0 && Minute() < 30 ) {
      return(0);
   }

   // 経済指標時間帯は背景色を変更
   now = TimeCurrent();
   for( i=0; i < ArraySize( stopStart )-1; i++ ){
      if( stopStart[i] <= now && now < stopEnd[i] ) {
         if( !offFlg ) {
            offFlg = true;
         }
         return(0);
      }
   }
   if( offFlg ) {
      offFlg = false;
   }

   price = Close[0];

   // エントリー
   dt = iTime( Symbol(), PERIOD_M5, 0 );
   if( lastOrderTime5 != dt ) {
      rci_5 = iCustom( Symbol(), PERIOD_M5, "RCIfrontier", 9, 0, 30, true, 0, 0 );
      stc14_5 = iStochastic( Symbol(), PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
      stc5_5 = iStochastic( Symbol(), PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );

      // BUY
      if( rci_5 <= -0.8 && stc14_5 <= 20 && stc5_5 <= 20 ) {
         rci_15 = iCustom( Symbol(), PERIOD_M15, "RCIfrontier", 9, 0, 30, true, 0, 0 );
         stc14_15 = iStochastic( Symbol(), PERIOD_M15, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
         stc5_15 = iStochastic( Symbol(), PERIOD_M15, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );

         if( rci_15 <= -0.8 && stc14_15 <= 20 && stc5_15 <= 20 ) {
            rci_30 = iCustom( Symbol(), PERIOD_M30, "RCIfrontier", 9, 0, 30, true, 0, 0 );
            stc14_30 = iStochastic( Symbol(), PERIOD_M30, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
            stc5_30 = iStochastic( Symbol(), PERIOD_M30, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );

            if( rci_30 <= -0.8 && stc14_30 <= 20 && stc5_30 <= 20 ) {
               ticket = OrderSend( Symbol(), OP_BUY, Lot, Ask, 3, Bid-LcPips*pipsRate, Bid+TpPips*pipsRate, "", Magic, 0, Red );
               lastOrderTime5 = dt;
            }
         }
      }
      // SELL
      if( rci_5 >= 0.8 && stc14_5 >= 80 && stc5_5 >= 80 ) {
         rci_15 = iCustom( Symbol(), PERIOD_M15, "RCIfrontier", 9, 0, 30, true, 0, 0 );
         stc14_15 = iStochastic( Symbol(), PERIOD_M15, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
         stc5_15 = iStochastic( Symbol(), PERIOD_M15, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );

         if( rci_15 >= 0.8 && stc14_15 >= 80 && stc5_15 >= 80 ) {
            rci_30 = iCustom( Symbol(), PERIOD_M30, "RCIfrontier", 9, 0, 30, true, 0, 0 );
            stc14_30 = iStochastic( Symbol(), PERIOD_M30, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
            stc5_30 = iStochastic( Symbol(), PERIOD_M30, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );

            if( rci_30 >= 0.8 && stc14_30 >= 80 && stc5_30 >= 80 ) {
               ticket = OrderSend( Symbol(), OP_SELL, Lot, Bid, 3, Ask+LcPips*pipsRate, Ask-TpPips*pipsRate, "", Magic, 0, Blue );
               lastOrderTime5 = dt;
            }
         }
      }
   }

   return(0);
}

int deinit() {
   return(0);
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
