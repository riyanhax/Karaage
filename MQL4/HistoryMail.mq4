#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern string Trader = "AXIORY";
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/stop_list.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定

int executedDayOfYear = 999;

int init(){
   return(0);
}

int start() {
   int i;
   int dayOfYear;
   int current;
   int historyTotal;
   datetime now;
   string subject, header, field;
   int year, month, day;
   int ticket[];
   string stopList;
   int diffHour;
   string stopTime;
   string msg;

   // 当日実行済の場合はスキップ
   dayOfYear = DayOfYear();
   if( executedDayOfYear == dayOfYear ) {
      return(0);
   }
   // 当日23時59分まではスキップ
   current = Hour()*100+Minute();
   if( current < 2359 ) {
      return(0);
   }

   // Time Difference
   diffHour = TimeHour(TimeLocal()) - Hour();

   // 件名
   now = TimeCurrent();
   year = TimeYear(now);
   month = TimeMonth(now);
   day = TimeDay(now);

   subject = year;
   if( month < 10 ) {
      subject = subject+"0"+Month();
   } else {
      subject = subject+Month();
   }
   if( day < 10 ) {
      subject = subject+"0"+Day();
   } else {
      subject = subject+Day();
   }
   subject = subject+" DailyConfirmation "+Trader+"["+AccountInfoInteger(ACCOUNT_LOGIN)+"]";

   // 停止時間の取得
   stopTime = stopTime+"StopTime: "+"\r\n          ";
   GrabWeb(StopListUrl, stopList);
   int length = StringLen( stopList );
   if( length >= 13 ) {
      int index = length/13;
      int currentDay = TimeDay( TimeCurrent() );

      string tmp;
      int tmpDay;
      int diffDay;
      datetime stopStartDatetime;
      datetime stopEndDatetime;
      for( i = 0; i < index; i++ ) {
         tmp = StringSubstr( stopList, i*13, 12 );
         tmpDay = StrToInteger( StringSubstr( tmp, 2, 2 ) );
         diffDay = tmpDay-currentDay;
         stopStartDatetime = StrToTime( StringSubstr( tmp, 4, 2 )+":"+StringSubstr( tmp, 6, 2 ) )+diffDay*24*60*60;
         stopEndDatetime = StrToTime( StringSubstr( tmp, 8, 2 )+":"+StringSubstr( tmp, 10, 2 ) )+diffDay*24*60*60;
         stopTime = stopTime+TimeToStr( stopStartDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES )+" ~ "+TimeToStr( stopEndDatetime+diffHour*60*60, TIME_DATE|TIME_MINUTES )+"\r\n          ";
      }
   }

   // ヒストリーを取得
   historyTotal = OrdersHistoryTotal();
   if( historyTotal <= 0 ) {
      // メール送信
      msg = "No History Data."+"\r\n\r\nAccountBalance:"+AccountBalance()+"\r\n\r\n"+stopTime;
      SendMail( subject, msg );
      executedDayOfYear = dayOfYear;
      return(0);
   }
   ArrayResize(ticket, historyTotal);
   ArrayInitialize(ticket, -1);
   for(i = 0; i < historyTotal; i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         switch(OrderType()) {
            case OP_BUY:
            case OP_SELL:
               ticket[i] = OrderTicket();
               break;
            default:
               ticket[i] = -1;
         }
      }
   }

   // 本文
   // ヘッダ
   header = "Ticket,OpenTime,Type,Size,Item,OpenPrice,S/L,T/P,CloseTime,ClosePrice,Commission,Taxes,Swap,Profit,Comment"+"\r\n";
   // フィールド
   for( i = 0; i < historyTotal; i++ ) {
      if(ticket[i] == -1) {
         continue;
      }

      if(OrderSelect(ticket[i], SELECT_BY_TICKET, MODE_HISTORY)) {
         field = field+ticket[i]+",";                                                                    // Ticket
         field = field+TimeToStr(OrderOpenTime())+",";                                                   // OpenTime
         switch(OrderType()) {                                                                           // Type
            case OP_BUY:
               field = field+"BUY"+",";
               break;
            case OP_SELL:
               field = field+"SELL"+",";
               break;
            default:
               field = field+""+",";
         }
         field = field+OrderLots()+",";                                                                  // Size
         field = field+OrderSymbol()+",";                                                                // Item
         field = field+NormalizeDouble(OrderOpenPrice(), MarketInfo(OrderSymbol(), MODE_DIGITS))+",";    // OpenPrice
         field = field+NormalizeDouble(OrderStopLoss(), MarketInfo(OrderSymbol(), MODE_DIGITS))+",";     // S/L
         field = field+NormalizeDouble(OrderTakeProfit(), MarketInfo(OrderSymbol(), MODE_DIGITS))+",";   // T/P
         field = field+TimeToStr(OrderCloseTime())+",";                                                  // CloseTime
         field = field+NormalizeDouble(OrderClosePrice(), MarketInfo(OrderSymbol(), MODE_DIGITS))+",";   // ClosePrice
         field = field+NormalizeDouble(OrderCommission(), 2)+",";                                        // Commission
         field = field+""+",";                                                                           // Taxes
         field = field+NormalizeDouble(OrderSwap(), 2)+",";                                              // Swap
         field = field+OrderProfit()+",";                                                                // Profit
         field = field+OrderComment();                                                                   // Comment
         field = field+"\r\n";
      }
   }
   field = field+"\r\nAccountBalance:"+AccountBalance();                                          // AccountBalance
   field = field+"\r\n\r\n"+stopTime;

   // メール送信
   msg = header+field;
   SendMail( subject, msg );

   executedDayOfYear = dayOfYear;

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

