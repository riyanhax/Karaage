#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lot = 0.1;
extern double TpPips = 0.0;
extern double LcPips = 0.0;
extern bool Mod = false;
extern double AllClose = 0; // 0の場合は無効、0.01ロットで100円程度が適当か？
extern int HighLowClose = 0; // 時間を指定してクローズ
extern bool HighLowHourClose = false;
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/green_soybeans/stop_list_dummy.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定

double pipsRate;
int lastError = 0;
datetime lastErrorTime = 0;
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
   double currentProfitPips;
   int tempInt;
   int supportCount;
   double fixedProfitPips;
   double supportLine;
   bool res;
   int errChk;
   int i;
   string msg;
   string tmp;
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
   datetime current = iTime( Symbol(), PERIOD_M1, 0 );
   double tp;
   double lc;


   // 1日に1回のみ実行するタスク
   if( executedDayOfYear != dayOfYear ) {
      // Time Difference
      diffHour = TimeHour(TimeLocal()) - Hour();
      if( diffHour < 0) {
         diffHour = diffHour+24;
      }

      executedDayOfYear = dayOfYear;
   }

   // 全決済
   if( AllClose > 0 ) {
      if( AccountProfit() >= AllClose ) {
         while( !IsStopped() ) {
            errChk = 0;
            if( OrdersTotal() > 0){
               for( i=0; i<OrdersTotal(); i++ ){
                  if( OrderSelect(i, SELECT_BY_POS) == true ){
                     if( OrderMagicNumber() == Magic || OrderMagicNumber() == Magic+1 || OrderMagicNumber() == Magic+2 ) {
                        // 買いポジション決済
                        if( OrderType() == OP_BUY ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                              errChk = 1;
                           }
                        // 売りポジション決済
                        } else {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green ) ) ) {
                              errChk = 1;
                           }
                        }
                     }
                  }
               }
            }
            if( errChk == 0 ) {
               break;
            }
            Sleep(500);
            RefreshRates();
         }
      }
   }

   // 1時間足で決済
   if( HighLowHourClose && Minute() == 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         if( OrdersTotal() > 0){
            for( i=0; i<OrdersTotal(); i++ ){
               if( OrderSelect(i, SELECT_BY_POS) == true ){
                  if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
                     // ポジションを決済
                     if( OrderType() == OP_BUY ) {
                        if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                           errChk = 1;
                        }
                     } else {
                        if( !( OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green ) ) ) {
                           errChk = 1;
                        }
                     }
                  }
               }
            }
         }
         if( errChk == 0 ) {
            break;
         }
         Sleep(500);
         RefreshRates();
      }
   // 時間指定決済
   } else if( HighLowClose > 0 ) {
      while( !IsStopped() ) {
         errChk = 0;
         if( OrdersTotal() > 0){
            for( i=0; i<OrdersTotal(); i++ ){
               if( OrderSelect(i, SELECT_BY_POS) == true ){
                  if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
                     // 指定時間以上経過しているポジションを決済
                     if( OrderOpenTime()+HighLowClose*60 <= TimeCurrent() ) {
                        if( OrderType() == OP_BUY ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                              errChk = 1;
                           }
                        } else {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green ) ) ) {
                              errChk = 1;
                           }
                        }
                     }
                  }
               }
            }
         }
         if( errChk == 0 ) {
            break;
         }
         Sleep(500);
         RefreshRates();
      }
   } else {
      // 決済
      while( !IsStopped() ) {
         errChk = 0;
         if( OrdersTotal() > 0){
            for( i=0; i<OrdersTotal(); i++ ){
               if( OrderSelect(i, SELECT_BY_POS) == true ){
                  if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
                     // 買いポジション決済
                     if( OrderType() == OP_BUY ) {
                        // 5分
                        rci_5 = iCustom( Symbol(), PERIOD_M5, "RCIfrontier", 9, 0, 30, true, 0, 0 );
                        stc14_5 = iStochastic( Symbol(), PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                        stc5_5 = iStochastic( Symbol(), PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                        if( rci_5 >= 0.85 && stc14_5 >= 80 && stc5_5 >= 80 ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Bid, 3, Green ) ) ) {
                              errChk = 1;
                           }
                        }
                     // 売りポジション決済
                     } else {
                        // 5分
                        rci_5 = iCustom( Symbol(), PERIOD_M5, "RCIfrontier", 9, 0, 30, true, 0, 0 );
                        stc14_5 = iStochastic( Symbol(), PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                        stc5_5 = iStochastic( Symbol(), PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
                        if( rci_5 <= -0.85 && stc14_5 <= 20 && stc5_5 <= 20 ) {
                           if( !( OrderClose( OrderTicket(), OrderLots(), Ask, 3, Green ) ) ) {
                              errChk = 1;
                           }
                        }
                     }
                  }
               }
            }
         }
         if( errChk == 0 ) {
            break;
         }
         Sleep(500);
         RefreshRates();
      }
   }

   // Mod
   if( Mod ) {
      if( OrdersTotal() > 0){
         for( i=0; i<OrdersTotal(); i++ ){
            if( OrderSelect(i, SELECT_BY_POS) == true ){
               if( OrderSymbol() == Symbol() && ( OrderMagicNumber() == Magic || OrderMagicNumber() == Magic+1 || OrderMagicNumber() == Magic+2 ) ) {
                  // Support Line
                  supportLine = 0;
                  if( OrderType() == OP_BUY ){
                     currentProfitPips = ( Bid-OrderOpenPrice() )/pipsRate;
                     if( currentProfitPips > 60 ) {
                        tempInt = ( currentProfitPips-40 )/20;
                        supportCount = tempInt-1;
                        fixedProfitPips = 40+supportCount*20;
                        supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 20 ) {
                        tempInt = ( currentProfitPips-10 )/10;
                        supportCount = tempInt-1;
                        fixedProfitPips = 10+supportCount*10;
                        supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 10 ) {
                        fixedProfitPips = 2;
                        supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                     }
                     if( supportLine > 0 && OrderStopLoss() < supportLine ) {
                        res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Blue );
                        if( fixedProfitPips > 0 ) {
                           if( !res  ) {
                              msg = "Error Modify BuyOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                              if( lastErrorTime != current || lastError != GetLastError() ) {
                                 SendMail( "[ERROR] TrendsWavezOrder", msg );
                                 lastError = GetLastError();
                                 lastErrorTime = current;
                              }
                              Print( msg );
                           } else {
                              msg = "MOD BUY ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                              SendMail( "[MOD] TrendsWavezOrder", msg );
                              Print( msg );
                           }
                        }
                     }
                  }else if( OrderType() == OP_SELL ){
                     currentProfitPips = ( OrderOpenPrice()-Ask )/pipsRate;
                     if( currentProfitPips > 60 ) {
                        tempInt = ( currentProfitPips-40 )/20;
                        supportCount = tempInt-1;
                        fixedProfitPips = 40+supportCount*20;
                        supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 20 ) {
                        tempInt = ( currentProfitPips-10 )/10;
                        supportCount = tempInt-1;
                        fixedProfitPips = 10+supportCount*10;
                        supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                     } else if( currentProfitPips >= 10 ) {
                        fixedProfitPips = 2;
                        supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                     }
                     if( supportLine > 0 && OrderStopLoss() > supportLine ) {
                        res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                        if( fixedProfitPips > 0 ) {
                           if( !res ) {
                              msg = "Error Modify SellOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                              if( lastErrorTime != current || lastError != GetLastError() ) {
                                 SendMail( "[ERROR] TrendsWavezOrder", msg );
                                 lastError = GetLastError();
                                 lastErrorTime = current;
                              }
                              Print( msg );
                           } else {
                              msg = "MOD SELL ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                              SendMail( "[MOD] TrendsWavezOrder", msg );
                              Print( msg );
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
/*
   // 金曜日はエントリーしない
   if( DayOfWeek() == 5 ) {
      return(0);
   }
*/

   if( HighLowHourClose ) {
      // 毎時30分以降はエントリーしない
      if( Minute() >= 30 ) {
         return(0);
      }
   }

   // 1日の最初の30分はエントリーしない
   if( Hour() == 0 && Minute() < 30 ) {
      return(0);
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
               if( LcPips > 0.0 ) {
                  lc = Bid-LcPips*pipsRate;
               } else {
                  lc = 0;
               }
               if( TpPips > 0.0 ) {
                  tp = Bid+TpPips*pipsRate;
               } else {
                  tp = 0;
               }
               ticket = OrderSend( Symbol(), OP_BUY, Lot, Ask, 3, lc, tp, "", Magic, 0, Red );
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
               if( LcPips > 0.0 ) {
                  lc = Ask+LcPips*pipsRate;
               } else {
                  lc = 0;
               }
               if( TpPips > 0.0 ) {
                  tp = Ask-TpPips*pipsRate;
               } else {
                  tp = 0;
               }
               ticket = OrderSend( Symbol(), OP_SELL, Lot, Bid, 3, lc, tp, "", Magic, 0, Blue );
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
