#property copyright "Copyright(C) 2021 Studiogadget Inc."

#import "user32.dll"
int GetAncestor(int,int);
#import

#include <WinUser32.mqh>

extern bool NarrowDownByMagic = false;
extern int Magic = 0;
extern bool NarrowDownByComment = false;
extern string Comment = "";
extern double MaxLots = 1.0;
extern bool DeleteLimitOrder = true;
extern bool StopAutoTrade = true;
extern bool MailAlert = true;
extern string ServerName = "ServerName";

bool tradeOn;
datetime lastAlert;

void OnInit() {
  if(StopAutoTrade == true && IsDllsAllowed() == false) {
    Alert("Check Allow DLL imports.");
    return;
  }

  if(IsTradeAllowed()) {
    tradeOn = true;
    Print( "Auto Trade Allowed." );
  } else {
    tradeOn = false;
    Print( "Auto Trade Not Allowed." );
  }

  return;
}

void OnTick() {
  bool overMaxLots;
  int i;
  int errChk;
  bool alreadyEntered;
  double tmpLots = 0.0;
  int limitOrderCnt = 0;
  int deletedOrderCnt = 0;
  int enteriedOrderCnt = 0;

  // ロット数を監視
  overMaxLots = false;
  alreadyEntered = false;
  if(OrdersTotal() > 0) {
    for(i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS) == true) {
        if(!NarrowDownByMagic || OrderMagicNumber() == Magic) {
          if(!NarrowDownByComment || StringFind(OrderComment(), Comment, 0) >= 0) {
            if(OrderLots() > MaxLots) {
              overMaxLots = true;
              if(tmpLots < OrderLots()) {
                tmpLots = OrderLots();
              }
              if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP
                || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) {
                limitOrderCnt++;
                if(DeleteLimitOrder) {
                  // オーダー取り消し
                  while( !IsStopped() ) {
                    errChk = 0;
                    if(!OrderDelete(OrderTicket(), CLR_NONE)) {
                      errChk = 1;
                    }
                    if( errChk == 0 ) {
                      deletedOrderCnt++;
                      break;
                    }
                    Print( "Order Delete Failure" );
                    Print( GetLastError() );
                    Sleep(500);
                    RefreshRates();
                  }
                }
              } else {
                alreadyEntered = true;
                enteriedOrderCnt++;
              }
            }
          }
        }
      }
    }
  }

  if(StopAutoTrade && overMaxLots) {
    if(tradeOn) {
      FuncSwitchAutoTrade();
      tradeOn = false;
    }
  }

  if(MailAlert && overMaxLots && lastAlert != Time[0]) {
    string mailSubject;
    string mailBody;
    mailSubject = "[Over Max Lots (" + tmpLots + ")] " + ServerName;
    mailBody = "LimitOrder: " + limitOrderCnt + "\n" + "EntriedOrder: " + enteriedOrderCnt + "\n" + "DeletedOrder: " + deletedOrderCnt + "\n" + TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
    SendMail( mailSubject, mailBody );

    lastAlert = Time[0];
  }
}

void FuncSwitchAutoTrade() {
   int hwnd = GetAncestor( WindowHandle( Symbol(), Period() ), 2 );
   PostMessageW(hwnd, WM_COMMAND, 33020, 0);
}
