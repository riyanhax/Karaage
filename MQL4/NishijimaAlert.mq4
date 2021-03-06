#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern bool Mail = false;
extern bool Alert = true;
extern bool BackgroundColor = true;
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/green_soybeans/stop_list.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定

datetime lastHighExeTime = 0;
datetime lastLowExeTime = 0;
datetime lastAlertTime = 0;
int executedDayOfYear = 999;
datetime stopStart[1] = {0};
datetime stopEnd[1] = {0};
bool offFlg = false;
int diffHour;

int init() {
   ObjectDelete( "sigma" );
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

   // 経済指標時間帯は背景色を変更
   now = TimeCurrent();
   for( i=0; i < ArraySize( stopStart )-1; i++ ){
      if( stopStart[i] <= now && now < stopEnd[i] ) {
         if( !offFlg ) {
            setBackground( "OFF" );
            offFlg = true;
         }
         return(0);
      }
   }
   if( offFlg ) {
      defaultBackground();
      offFlg = false;
   }

   // パラメータ
   double buySign = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",1,1);
   double sellSign = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",0,1);
   double buyOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",2,1);
   double sellOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",3,1);
   double currentPrice = Close[0];

   // SIGN
   if( ( buySign != EMPTY_VALUE && buySign != 0 ) || ( sellSign != EMPTY_VALUE && sellSign != 0 ) ) {
      if( lastAlertTime != Time[0] ) {
         setBackground( "SIGN" );
         alert( "SIGN", currentPrice, time );
         lastAlertTime = Time[0];
      }
   }
   // ORDER
   if( ( buyOrder != EMPTY_VALUE && buyOrder != 0 ) || ( sellOrder != EMPTY_VALUE && sellOrder != 0)  ) {
      if( lastAlertTime != Time[0] ) {
         setBackground( "ORDER" );
         alert( "ORDER", currentPrice, time );
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

int alert( string sigma, double current, string time ) {
   if( Mail ) {
      SendMail( "SigmaAlert", "["+Symbol()+"] "+current+"\r\nsigma: "+sigma+"\r\ntime: "+time );
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
