#property copyright "Copyright(C) 2020 Studiogadget Inc."

extern int Magic = 10001;
extern double Lots = 0.01;
extern double TakeProfitPips = 5.0;

bool firstOrder = false;
datetime firstOrderTime;
double pipsRate;
double unitParPips;
int ticket;
int count;

int init(){
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   unitParPips = currencyUnitPerPips( Symbol() );

   return(0);
}

int start(){
   int i;
   int errChk;
   double profitPips;
   bool closeFlg = false;

   // 初回両建て
   if( !firstOrder ) {
     Print( "FirstOrder Long and Short." );
     if( doubleOrder() ) {
       firstOrder = true;
       firstOrderTime = TimeCurrent();
     } else {
        return(0);
     }
   }

   // TakeProfitPips以上の利益が出ているポジションが存在する場合、
   // その利益が出ているポジションと、
   // firstOrderTimeより後のポジションを全て決済して両建てを持ち直す。
   if( OrdersTotal() > 0) {
     for( i=0; i<OrdersTotal(); i++ ) {
       if( OrderSelect( i, SELECT_BY_POS) == true ) {
         if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
           profitPips = OrderProfit() * pipsRate;
           if( profitPips >= TakeProfitPips ) {
             // このポジションを決済
             Print( "Close Profit Order." );
             if( OrderType() == OP_BUY ) {
               while( !IsStopped() ) {
                 errChk = 0;
                 if( !OrderClose( OrderTicket(),OrderLots(),Bid,3,Green ) ){
                    errChk = 1;
                 }
                 if( errChk == 0 ) {
                    closeFlg = true;
                    break;
                 }
                 Print( "Order Close Failure Long." );
                 Sleep(500);
                 RefreshRates();
              }
            } else if( OrderType() == OP_SELL ) {
               while( !IsStopped() ) {
                 errChk = 0;
                 if( !OrderClose( OrderTicket(),OrderLots(),Ask,3,Green ) ){
                    errChk = 1;
                 }
                 if( errChk == 0 ) {
                    closeFlg = true;
                    break;
                 }
                 Print( "Order Close Failure Short." );
                 Sleep(500);
                 RefreshRates();
               }
             }
           }
         }
       }
     }
   }
   // firstOrderTimeより後のポジションを全て決済
   if( closeFlg ) {
      if( OrdersTotal() > 0) {
       for( i=0; i<OrdersTotal(); i++ ) {
         if( OrderSelect( i, SELECT_BY_POS) == true ) {
           if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
             if( OrderOpenTime() > firstOrderTime ) {
               // このポジションを決済
               Print( "Close Profitless Order." );
               if( OrderType() == OP_BUY ) {
                 while( !IsStopped() ) {
                   errChk = 0;
                   if( !OrderClose( OrderTicket(),OrderLots(),Bid,3,Green ) ){
                      errChk = 1;
                   }
                   if( errChk == 0 ) {
                      closeFlg = true;
                      break;
                   }
                   Print( "Order Close Failure Long." );
                   Sleep(500);
                   RefreshRates();
                }
              } else if( OrderType() == OP_SELL ) {
                 while( !IsStopped() ) {
                   errChk = 0;
                   if( !OrderClose( OrderTicket(),OrderLots(),Ask,3,Green ) ){
                      errChk = 1;
                   }
                   if( errChk == 0 ) {
                      closeFlg = true;
                      break;
                   }
                   Print( "Order Close Failure Short." );
                   Sleep(500);
                   RefreshRates();
                 }
               }
             }
           }
         }
       }
     }
     // 両建てを持ち直す
     Print( "Order Long and Short." + ++count );
     doubleOrder();
     closeFlg = false;
   }

   return(0);
}

int deinit(){
   return(0);
}

bool doubleOrder() {
  // Long Order
  ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, 0, 0, "Order Long", Magic, 0, Blue);
  if( ticket < 0 ) {
    Print( "Error Opening Order Long." );
    Print( GetLastError() );
    return false;
  } else {
    Print( "Opening Order Long." );
  }
  // Short Order
  ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, 0, 0, "Order Short", Magic, 0, Red);
  if( ticket < 0 ) {
    Print( "Error Opening Order Short." );
    Print( GetLastError() );
    return false;
  } else {
    Print( "Opening Order Short." );
  }

  return true;
}

// 小数点を2桁に切る
double dts2(double val) {
   return(StrToDouble((DoubleToStr(val,2))));
}

//+------------------------------------------------------------------+
//|【関数】1pips当たりの価格単位を計算する                           |
//|                                                                  |
//|【引数】 IN OUT  引数名             説明                          |
//|        --------------------------------------------------------- |
//|         ○      aSymbol            通貨ペア                      |
//|                                                                  |
//|【戻値】1pips当たりの価格単位                                     |
//|                                                                  |
//|【備考】なし                                                      |
//+------------------------------------------------------------------+
double currencyUnitPerPips(string aSymbol)
{
  // 通貨ペアに対応する小数点数を取得
  double digits = MarketInfo(aSymbol, MODE_DIGITS);

  // 通貨ペアに対応するポイント（最小価格単位）を取得
  // 3桁/5桁のFX業者の場合、0.001/0.00001
  // 2桁/4桁のFX業者の場合、0.01/0.0001
  double point = MarketInfo(aSymbol, MODE_POINT);

  // 価格単位の初期化
  double currencyUnit = 0.0;

  // 3桁/5桁のFX業者の場合
  if(digits == 3.0 || digits == 5.0){
    currencyUnit = point * 10.0;
  // 2桁/4桁のFX業者の場合
  }else{
    currencyUnit = point;
  }

  return(currencyUnit);
}
