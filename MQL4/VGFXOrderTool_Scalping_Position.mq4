#property copyright "Copyright(C) 2015 Studiogadget Inc."

extern int PositionCheckIntervalSec = 10;
extern bool MinMax = false;
extern double DayInterestPercent = 1.8; // 0は制限なし
extern int DayInterestResetHour = 1; // TimeCurrentで指定(1以上を使用)
extern string DayInterestPercentUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/karaage/day_interrest_percent.txt";

int tickets_old[1] = {0};
int tickets_now[1] = {0};
int tickets_added[1] = {0};
int tickets_deleted[1] = {0};
int ut_old = 0;
int orderNumbers[1] = {0};
double maxPrices[1] = {0.0};
double minPrices[1] = {0.0};
int dayInterestResetDayOfYear = 999;
double startBalance;
double stopBalance;
double dayInterestPercent;
double stopMailSendBalance;

int init(){
   // 目標残高の設定
   // 日利の取得
   string tmp = "";
   GrabWeb( DayInterestPercentUrl, tmp );
   int length = StringLen( tmp );
   if( length == 0 || length > 10 ) {
      dayInterestPercent = DayInterestPercent;
   } else {
      dayInterestPercent = StrToDouble( tmp );
   }

   if( dayInterestPercent == 0 ) {
      stopBalance = 0.0;
   } else {
      startBalance = AccountBalance();
      stopBalance = AccountBalance()*(1.0+dayInterestPercent/100);
      string msg = "Balance:"+AccountBalance()+"\r\nSettingInterest:"+dayInterestPercent+"%"+"\r\nTargetProfit:"+( stopBalance-startBalance )+"\r\nTime:"+TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
      SendMail( "[SET GOAL] ScalpingTool", msg );
   }

   return(0);
}

int start(){
   int i;
   double currentPrice;
   int orderNumber;
   int searchedIndex;
   int searchedNumber;
   double currentMaxPrice;
   double currentMinPrice;
   int newIndex;
   string msg;
   int timeZone;
   double pipsRate;
   double profitPips;
   int dayOfYear = DayOfYear();
   int length;
   string tmp;

   // Time Difference
   timeZone = TimeHour(TimeLocal()) - Hour();
   if( timeZone < 0 ) {
      timeZone = timeZone+24;
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
            startBalance = AccountBalance();
            stopBalance = AccountBalance()*(1.0+dayInterestPercent/100);
            msg = "Balance:"+AccountBalance()+"\r\nSettingInterest:"+dayInterestPercent+"%"+"\r\nTargetProfit:"+( stopBalance-startBalance )+"\r\nTime:"+TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
            SendMail( "[SET GOAL] ScalpingTool", msg );
         }
         dayInterestResetDayOfYear = dayOfYear;
      }
   }

   // Check Positon Change
   ArrayInitialize(tickets_now,0);
   ArrayInitialize(tickets_added,0);
   ArrayInitialize(tickets_deleted,0);
   ArrayResize(tickets_now,1);
   ArrayResize(tickets_added,1);
   ArrayResize(tickets_deleted,1);
   int ticket;
   int nowloccal_ut = TimeLocal();

   // Check Position
   if( MinMax ) {
      if( OrdersTotal() > 0){
         for( i=0; i<OrdersTotal(); i++ ){
            if( OrderSelect(i, SELECT_BY_POS) == true ){
               currentPrice = 0;
               if( OrderType() == OP_BUY ){
                  currentPrice = MarketInfo(OrderSymbol(),MODE_BID);
               } else if( OrderType() == OP_SELL ) {
                  currentPrice = MarketInfo(OrderSymbol(),MODE_ASK);
               }
               if(currentPrice > 0) {
                  orderNumber = OrderTicket();
                  searchedIndex = ArrayBsearch( orderNumbers, orderNumber, WHOLE_ARRAY, 0, MODE_ASCEND );
                  searchedNumber = orderNumbers[searchedIndex];
                  if( searchedNumber == orderNumber ) {
                     currentMaxPrice = maxPrices[searchedIndex];
                     currentMinPrice = minPrices[searchedIndex];
                     if( currentPrice > currentMaxPrice ) {
                        maxPrices[searchedIndex] = currentPrice;
                     } else if( currentPrice < currentMinPrice ) {
                        minPrices[searchedIndex] = currentPrice;
                     }
                  } else {
                     newIndex = ArraySize( orderNumbers );
                     ArrayResize( orderNumbers, newIndex+1 );
                     ArrayResize( maxPrices, newIndex+1 );
                     ArrayResize( minPrices, newIndex+1 );
                     orderNumbers[newIndex] = orderNumber;
                     maxPrices[newIndex] = currentPrice;
                     minPrices[newIndex] = currentPrice;
                  }
               }
            }
         }
      } else {
         ArrayInitialize( orderNumbers, 0 );
         ArrayInitialize( maxPrices, 0.0 );
         ArrayInitialize( minPrices, 0.0 );
         ArrayResize( orderNumbers, 1 );
         ArrayResize( maxPrices, 1 );
         ArrayResize( minPrices, 1 );
      }
   }

   if( (nowloccal_ut - ut_old) >= PositionCheckIntervalSec) {
      // Get Ticket Number
      for(i=0; i<OrdersTotal(); i++) {
         if(! OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         ticket = OrderTicket();
         push(tickets_now,ticket);
         // Check New Position
         if(tickets_old[0] > 0) {
            if(! in_array(ticket,tickets_old)) push(tickets_added,ticket);
         } else {
            push(tickets_added,ticket);
         }
      }
      // Check Deleted Position
      for(i=0; i<ArraySize(tickets_old); i++) {
         ticket = tickets_old[i];
         if(ticket == 0) continue;
         if(! in_array(ticket,tickets_now)) push(tickets_deleted,ticket);
      }
      // Has Change?
      if( tickets_deleted[0] > 0 ) {
         msg = "";
         // Order Close Detail
         if( tickets_deleted[0] > 0 ) {
            for(i=0; i<ArraySize(tickets_deleted); i++) {
               ticket = tickets_deleted[i];
               if(ticket == 0) break;
               if(! OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)) continue;
               msg = msg + "Symbol: "+OrderSymbol()+"\r\n";
               if( StringFind( OrderSymbol(),"JPY",0 ) == -1 ) {
                  pipsRate = 0.0001;
               } else {
                  pipsRate = 0.01;
               }
               msg = msg + "OrderType: "+ordertype2str(OrderType())+"\r\n";
               msg = msg + "Lots: "+DoubleToStr(OrderLots(),2)+"\r\n";
               msg = msg + "OpenPrice: "+dts2(OrderOpenPrice())+"\r\n";
               msg = msg + "ClosedPrice: "+dts2(OrderClosePrice())+"\r\n";
               if( OrderType() == OP_BUY ) {
                  profitPips = dts2((OrderClosePrice()-OrderOpenPrice())/pipsRate);
               } else if( OrderType() == OP_SELL ) {
                  profitPips = dts2((OrderOpenPrice()-OrderClosePrice())/pipsRate);
               } else {
                  profitPips = 0;
               }
               if( profitPips >= 0 ) {
                  msg = "+++ Close +++\r\n\r\n" + msg;
               } else {
                  msg = "--- Close ---\r\n\r\n" + msg;
               }
               msg = msg + "ProfitPips: "+profitPips+"\r\n";
               if( MinMax ) {
                  orderNumber = OrderTicket();
                  searchedIndex = ArrayBsearch( orderNumbers, orderNumber, WHOLE_ARRAY, 0, MODE_ASCEND );
                  searchedNumber = orderNumbers[searchedIndex];
                  if( searchedNumber == orderNumber ) {
                     msg = msg + "MaxPrice: "+maxPrices[searchedIndex]+" ("+dts2((maxPrices[searchedIndex]-OrderOpenPrice())/pipsRate)+")\r\n";
                     msg = msg + "MinPrice: "+minPrices[searchedIndex]+" ("+dts2((OrderOpenPrice()-minPrices[searchedIndex])/pipsRate)+")\r\n";
                  } else {
                     msg = msg + "MaxPrice: n/a"+"\r\n";
                     msg = msg + "MinPrice: n/a"+"\r\n";
                  }
               }
               msg = msg + "MagicNo.: "+OrderMagicNumber()+"\r\n";
               msg = msg + "OpenDatetime: "+TimeToStr(OrderOpenTime()+(timeZone*60*60),TIME_DATE|TIME_SECONDS)+"\r\n";
               msg = msg + "ClosedDatetime: "+TimeToStr(OrderCloseTime()+(timeZone*60*60),TIME_DATE|TIME_SECONDS)+"\r\n";
               msg = msg + "OrderNumber: "+orderNumber+"\r\n";
               msg = msg + "\r\n";
            }
            // Send Mail
            SendMail("[CLOSED] ScalpingTool", msg);
         }
      }

      // Update Tmp
      ArrayInitialize(tickets_old,0);
      ArrayResize(tickets_old,ArraySize(tickets_now));
      for(i=0; i<ArraySize(tickets_now); i++) tickets_old[i] = tickets_now[i];
      ut_old = nowloccal_ut;
   }

   // 目標残高に達している場合はメール送信(1回のみ)
   if( stopBalance != 0 ) {
      if( stopBalance <= AccountBalance() ) {
         if( stopMailSendBalance != AccountBalance() ) {
            msg = "Balance:"+AccountBalance()+"\r\nSettingInterest:"+dayInterestPercent+"%"+"\r\nActualInterest:"+dts2( ( AccountBalance()-startBalance )*100/startBalance)+"%"+"\r\nProfit:"+( AccountBalance()-startBalance )+"\r\nTime:"+TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
            if( SendMail( "[GOAL] ScalpingTool", msg ) ) {
               stopMailSendBalance = AccountBalance(); // 送信済フラグ
            }
         }
      }
   }

   return(0);
}

int deinit() {
   return(0);
}

// 配列の最後に値を追加する（0個目の値が0のときだけは上書きする）
int push(int& ary[],int val) {
   int k2 = 0;
   int len = ArraySize(ary);
   if((len >= 1) && (ary[0] != 0)) {
      ArrayResize(ary,(len+1));
      k2 = len;
   }
   ary[k2] = val;
   return(ArraySize(ary));
}

// 小数点を適切に切る
string dts2(double val) {
   if(val < 10) return(DoubleToStr(val,4));
   else return(DoubleToStr(val,2));
}

// OrderTypeの値を文字列で返す
string ordertype2str(int type) {
   if(type == OP_BUY)            return("BUY");
   else if(type == OP_SELL)      return("SELL");
   else if(type == OP_BUYLIMIT)  return("BUYLIMIT");
   else if(type == OP_SELLLIMIT) return("SELLLIMIT");
   else if(type == OP_BUYSTOP)   return("BUYSTOP");
   else if(type == OP_SELLSTOP)  return("SELLSTOP");
   else return("unknown");
}

// 配列内に指定した値が存在するか
bool in_array(int val,int ary[]) {
   bool res = false;
   for (int i=0; i<ArraySize(ary); i++) {
      if(ary[i] == val) {
         res = true;
         break;
      }
   }
   return(res);
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
