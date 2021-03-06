#property copyright "Copyright(C) 2015 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lots = 0.01;
extern bool CompoundInterest = false; // 複利
extern int AllPosition = 99;
extern double ProfitPips = 5.0;
extern double StopPips = 5.0;
extern double DayInterestPercent = 0; // 0は制限なし
extern int DayInterestResetHour = 1; // TimeCurrentで指定(1以上を使用)
extern bool MarketTimeStop = false;
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/stop_list_dummy.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定
extern string TestUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/test.txt";
extern string DayInterestPercentUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/day_interrest_percent_dummy.txt";
extern string AllPositionUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/all_position_dummy.txt";

double lots;
double pipsRate;
int executedDayOfYear = 999;
int dayInterestResetDayOfYear = 999;
int lastError = 0;
datetime lastErrorTime = 0;
double support;
double resistance;
datetime stopStart[1] = {0};
datetime stopEnd[1] = {0};
int diffHour;
double stopBalance;
double dayInterestPercent;
int allPosition;
bool bootTest;
bool bootErrorMail;

int init() {
   bootTest = false;
   bootErrorMail = false;

   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   // 目標残高の設定
   if( DayInterestPercent == 0 ) {
      stopBalance = 0.0;
   } else {
      stopBalance = AccountBalance()*(1.0+DayInterestPercent/100);
   }

   return(0);
}

int start() {
   string stopList;
   int buyCnt;
   int sellCnt;
   int allCnt;
   double shortLimit;
   double spreadTemp;
   double spreadDouble;
   string mtt;
   int ticket;
   string msg;
   int i;
   int dayOfYear = DayOfYear();
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
   datetime now;
   int length;
   string tmp;
   int index;
   string today;
   int month;
   int day;
   datetime stopStartDatetime;
   datetime stopEndDatetime;

   // 起動テスト
   if( !bootTest ) {
      tmp = "";
      GrabWeb( TestUrl, tmp );
      if( tmp == "test" ) {
         bootTest = true;
         if( bootErrorMail ) {
            SendMail( "[RECOVERY] SpreadZero", "["+Symbol()+"] Reboot Success." );
         }
      } else {
         if( !bootErrorMail ) {
            bootErrorMail = true;
            SendMail( "[ERROR] SpreadZero", "["+Symbol()+"] Reboot Failure." );
         }
         Sleep( 1*60*1000 );
         return(0);
      }
   }

   // 当日の1時間経過まではスキップ(サーバ再起動用)
   if( TimeHour( TimeCurrent() ) < 1 ) {
      return(0);
   }

   // 1日に1回特定の時間に実行するタスク(目標残高の設定)
   if( dayInterestResetDayOfYear != dayOfYear ) {
      // 日利の取得
      tmp = "";
      GrabWeb( DayInterestPercentUrl, tmp );
      length = StringLen( tmp );
      if( length == 0 || length > 10 ) {
         dayInterestPercent = DayInterestPercent;
      } else {
         dayInterestPercent = StrToDouble( tmp );
      }

      if( DayInterestResetHour <= TimeHour( TimeCurrent() ) ) {
         if( dayInterestPercent == 0 ) {
            stopBalance = 0.0;
         } else {
            stopBalance = AccountBalance()*(1.0+dayInterestPercent/100);
         }
         dayInterestResetDayOfYear = dayOfYear;
      }
   }

   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0) {
         diffHour = diffHour+24;
      }

      // 単利複利の設定
      tmp = "";
      GrabWeb( AllPositionUrl, tmp );
      length = StringLen( tmp );
      if( length == 0 || length > 10 ) {
         allPosition = AllPosition;
      } else {
         allPosition = StrToInteger( tmp );
      }
      if( CompoundInterest ) {
         lots = dts2( AccountBalance()*AccountLeverage()/( 40000000*allPosition ) );
      } else {
         lots = Lots;
      }

      // 停止時間の取得
      // 配列を初期化
      ArrayInitialize( stopStart, 0 );
      ArrayInitialize( stopEnd, 0 );
      ArrayResize( stopStart, 1 );
      ArrayResize( stopEnd, 1 );
      // メイン
      GrabWeb( StopListUrl, stopList );
      length = StringLen( stopList );
      if( length == 0 ) {
         msg = "Error Load StopList["+Symbol()+"]"+"\r\nTime:"+time;
         SendMail( "[ERROR] SpreadZero", msg );
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
         Print( "Today: "+today );

         for( i = 0; i < index; i++ ) {
            tmp = StringSubstr( stopList, i*13, 12 );
            if( StringSubstr( tmp, 0, 4 ) == today ) {
               stopStartDatetime = StrToTime( StringSubstr( tmp, 4, 2 )+":"+StringSubstr( tmp, 6, 2 ) );
               stopEndDatetime = StrToTime( StringSubstr( tmp, 8, 2 )+":"+StringSubstr( tmp, 10, 2 ) );
               stopStart[ArraySize( stopStart )-1] = stopStartDatetime;
               stopEnd[ArraySize( stopEnd )-1] = stopEndDatetime;
               ArrayResize( stopStart, ArraySize( stopStart )+1 );
               ArrayResize( stopEnd, ArraySize( stopEnd )+1 );
               Print( "StopStart: "+TimeToStr( stopStartDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES ) );
               Print( "StopEnd: "+TimeToStr( stopEndDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES ) );
            }
         }
      }
      // マーケット時間
      if( MarketTimeStop ) {
         ArrayResize( stopStart, ArraySize( stopStart )+4 );
         ArrayResize( stopEnd, ArraySize( stopEnd )+4 );
         if( diffHour == 7 ) {
            // 通常時間
            stopStart[ArraySize( stopStart )-4] = StrToTime( "00:00" );  // 07:00~12:00
            stopEnd[ArraySize( stopEnd )-4] = StrToTime( "05:00" );
            stopStart[ArraySize( stopStart )-3] = StrToTime( "09:00" );  // 16:00~20:00
            stopEnd[ArraySize( stopEnd )-3] = StrToTime( "13:00" );
            stopStart[ArraySize( stopStart )-2] = StrToTime( "14:00" );  // 21:00~25:00
            stopEnd[ArraySize( stopEnd )-2] = StrToTime( "18:00" );
            stopStart[ArraySize( stopStart )-1] = StrToTime( "21:00" );  // 04:00~06:59
            stopEnd[ArraySize( stopEnd )-1] = StrToTime( "23:59" );
         } else {
            // サマータイム
            stopStart[ArraySize( stopStart )-4] = StrToTime( "00:00" );  // 06:00~12:00
            stopEnd[ArraySize( stopEnd )-4] = StrToTime( "06:00" );
            stopStart[ArraySize( stopStart )-3] = StrToTime( "09:00" );  // 15:00~19:00
            stopEnd[ArraySize( stopEnd )-3] = StrToTime( "13:00" );
            stopStart[ArraySize( stopStart )-2] = StrToTime( "14:00" );  // 20:00~24:00
            stopEnd[ArraySize( stopEnd )-2] = StrToTime( "18:00" );
            stopStart[ArraySize( stopStart )-1] = StrToTime( "23:00" );  // 05:00~05:59
            stopEnd[ArraySize( stopEnd )-1] = StrToTime( "23:59" );
         }
      }

      executedDayOfYear = dayOfYear;
   }

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

   // 目標残高に達している場合はスキップ
   if( stopBalance != 0 ) {
      if( stopBalance <= AccountBalance() ) {
         return(0);
      }
   }

   // 停止時間の場合はスキップ
   now = TimeCurrent();
   for( i=0; i < ArraySize( stopStart )-1; i++ ){
      if( stopStart[i] <= now && now <= stopEnd[i] ) {
         return(0);
      }
   }

   // Get Parameters
   double mttUp = iCustom(Symbol(),PERIOD_CURRENT,"MTT",4,1);
   double mttDown = iCustom(Symbol(),PERIOD_CURRENT,"MTT",5,1);
   double middleLine = iBands( Symbol(), PERIOD_CURRENT, 25, 2.0, 0, PRICE_CLOSE, 0, 0 );
   double upperLine = iBands(Symbol(), PERIOD_CURRENT, 25, 2.0, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double lowerLine = iBands(Symbol(), PERIOD_CURRENT, 25, 2.0, 0, PRICE_CLOSE, MODE_LOWER, 0);

   // MTT
   if( mttUp != EMPTY_VALUE && mttUp != 0 ) {
      mtt = "UP";
   } else if(mttDown != EMPTY_VALUE && mttDown != 0) {
      mtt = "DOWN";
   } else {
      mtt = "PLAIN";
   }

   // スプレッドが条件に合わない場合はスキップ
   int spread = MarketInfo(Symbol(),MODE_SPREAD); // 0.5pips → 5 1pips → 10
   if(spread > 0.0) {
      return(0);
   } else {
      spreadTemp = spread;
      spreadDouble = spreadTemp/10;
   }

   // BUY ORDER
   if( mtt == "UP" && Close[0] < middleLine && Close[0] < ( middleLine-( ( middleLine-lowerLine )/2 ) ) ) {
      if( buyCnt < 1 && allCnt < allPosition ) {
         support = Ask-StopPips*pipsRate;
         shortLimit = Ask+ProfitPips*pipsRate;
         ticket = OrderSend( Symbol(),OP_BUY,lots,Close[0],3,support,shortLimit,Close[0]+","+Ask+","+middleLine,Magic,0,Red);
         if( ticket < 0 ) {
            if( lastErrorTime != Time[0] ) {
               msg = "Error Opening BuyOrder["+Symbol()+"]:"+GetLastError();
               SendMail( "[ERROR] SpreadZero", msg );
               lastErrorTime = Time[0];
            }
         } else {
            msg = "BUY ORDER"+"\r\n["+Symbol()+"] "+Close[0]+"\r\nLimit:"+shortLimit+" ("+ProfitPips+")"+"\r\nRLimit:"+support+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
            SendMail( "[OPEN] SpreadZero", msg );
         }
      }
   }

   // SELL ORDER
   if( mtt == "DOWN" && Close[0] > middleLine && Close[0] > middleLine+( ( upperLine-middleLine )/2 ) ) {
      if( sellCnt < 1 && allCnt < allPosition ) {
         resistance = Bid+StopPips*pipsRate;
         shortLimit = Bid-ProfitPips*pipsRate;
         ticket = OrderSend( Symbol(),OP_SELL,lots,Close[0],3,resistance,shortLimit,Close[0]+","+Bid+","+middleLine,Magic,0,Blue);
         if( ticket < 0 ) {
            if( lastErrorTime != Time[0] ) {
               msg = "Error Opening SellOrder["+Symbol()+"]:"+GetLastError();
               SendMail( "[ERROR] SpreadZero", msg );
               lastErrorTime = Time[0];
            }
         } else {
            msg = "SELL ORDER"+"\r\n["+Symbol()+"] "+Close[0]+"\r\nLimit:"+shortLimit+" ("+ProfitPips+")"+"\r\nRLimit:"+resistance+" ("+StopPips+")"+"\r\nSpread:"+spreadDouble+"\r\nTime:"+time;
            SendMail( "[OPEN] SpreadZero", msg );
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
