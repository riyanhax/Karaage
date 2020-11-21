#property copyright "Copyright(C) 2018 Studiogadget Inc."

extern int Magic = 37654321;
extern double RiskPercent = 1.0;
extern double Lots = 0.01;
extern string Explanation1 = "RiskPercentを0.0に設定した場合にLots有効";
extern double TakeProfitPips = 12.0;
extern double LossCutPips = 6.0;
extern int TimeSettlement = 0;
extern bool AutoSupport = false;
extern int MaxSpread = 9;
extern string Explanation2 = "MaxSpread: 0.5pips → 5, 1pips → 10";
extern bool Filter = true;
extern bool TimeControl = true;
extern int TimeDiff = 6;

datetime lastLog = 0;
double pipsRate;
double unitParPips;

int init(){
  ObjectDelete( "cross" );

   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   unitParPips = currencyUnitPerPips( Symbol() );
   //Print( "UnitPerPips: "+unitParPips );

   return(0);
}

int start(){
   int buyCnt;
   int sellCnt;
   int allCnt;
   int ticket;
   int i;
   int currentHour;
   double lots;
   double tp;
   double sl;
   // TP SL チェック
   CheckTPSL();

   // 時間制限
   if( TimeControl ) {
      currentHour = Hour()+TimeDiff;
      if( currentHour >= 24 ) {
         currentHour = currentHour-24;
      }

      if( 0 <= currentHour && currentHour <= 6 ) {
         return(0);
      }
      if( 11 <= currentHour && currentHour <= 12 ) {
         return(0);
      }
      if( 19 == currentHour ) {
         return(0);
      }
      if( 22 == currentHour ) {
         return(0);
      }
   }

   if( TimeSettlement ) {
      if( OrdersTotal() > 0){
        for( i=0; i<OrdersTotal(); i++ ){
           if( OrderSelect(i, SELECT_BY_POS) == true ){
              if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
                entryCnt++;
                 if( OrderOpenTime()+TimeSettlement*60 <= TimeCurrent() ) {
                    if( OrderType() == OP_BUY ) {
                       while( !IsStopped() ) {
                         errChk = 0;
                         if( !OrderClose( OrderTicket(),OrderLots(),Bid,3,Green ) ){
                            errChk = 1;
                         }
                         if( errChk == 0 ) {
                            entryCnt--;
                            break;
                         }
                         Print( "Order Close Failure." );
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
                            entryCnt--;
                            break;
                         }
                         Print( "Order Close Failure." );
                         Sleep(500);
                         RefreshRates();
                      }
                    }
                 }
              }
            }
         }
      }
   }

   // AutoSupport
   if( AutoSupport ) {
    current = iTime( Symbol(), timeframe, 0 );
     if( OrdersTotal() > 0){
        for( i=0; i<OrdersTotal(); i++ ){
           if( OrderSelect(i, SELECT_BY_POS) == true ){
              if( OrderSymbol() == Symbol() && Magic == OrderMagicNumber() ) {
                 // Support Line
                 if( OrderType() == OP_BUY ){
                    currentProfitPips = ( Bid-OrderOpenPrice() )/pipsRate;
                    if( currentProfitPips >= 10 ) {
                       orderModifyTime = current;
                       tempInt = (currentProfitPips-10)/5;
                       supportCount = tempInt-1;
                       fixedProfitPips = 10+supportCount*5;
                       supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                    } else if( currentProfitPips >= 3 ) {
                       orderModifyTime = current;
                       fixedProfitPips = 2;
                       supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                    } else if( currentProfitPips >= 2 ) {
                       orderModifyTime = current;
                       fixedProfitPips = 1;
                       supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                    } else if( currentProfitPips >= 1 ) {
                       orderModifyTime = current;
                       fixedProfitPips = 0.5;
                       supportLine = OrderOpenPrice()+fixedProfitPips*pipsRate;
                    }
                    if( supportLine > 0 && OrderStopLoss() < supportLine ) {
                       res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Blue );
                       if( fixedProfitPips > 0 ) {
                          if( !res  ) {
                             msg = "Error Modify BuyOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                             if( lastErrorTime != current || lastError != GetLastError() ) {
                                SendMail( "[ERROR] ScalpingTool", msg );
                                lastError = GetLastError();
                                lastErrorTime = current;
                             }
                             Print( msg );
                          } else {
                             msg = "MOD BUY ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                             SendMail( "[MOD] ScalpingTool", msg );
                             Print( msg );
                          }
                       }
                    }
                 }else if( OrderType() == OP_SELL ){
                    currentProfitPips = ( OrderOpenPrice()-Ask )/pipsRate;
                    if( currentProfitPips >= 10 ) {
                       orderModifyTime = current;
                       tempInt = (currentProfitPips-10)/5;
                       supportCount = tempInt-1;
                       fixedProfitPips = 10+supportCount*5;
                       supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                    } else if( currentProfitPips >= 3 ) {
                       orderModifyTime = current;
                       fixedProfitPips = 2;
                       supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                    } else if( currentProfitPips >= 2 ) {
                       orderModifyTime = current;
                       fixedProfitPips = 1;
                       supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                    } else if( currentProfitPips >= 1 ) {
                       orderModifyTime = current;
                       fixedProfitPips = 0.5;
                       supportLine = OrderOpenPrice()-fixedProfitPips*pipsRate;
                    }
                    if( supportLine > 0 && OrderStopLoss() > supportLine ) {
                       res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                       if( fixedProfitPips > 0 ) {
                          if( !res ) {
                             msg = "Error Modify SellOrder["+Symbol()+"]:"+GetLastError()+"\r\nTime:"+time;
                             if( lastErrorTime != current || lastError != GetLastError() ) {
                                SendMail( "[ERROR] ScalpingTool", msg );
                                lastError = GetLastError();
                                lastErrorTime = current;
                             }
                             Print( msg );
                          } else {
                             msg = "MOD SELL ORDER ["+Symbol()+"]"+"\r\nFixedProfitPips:"+fixedProfitPips+"\r\nTime:"+time;
                             SendMail( "[MOD] ScalpingTool", msg );
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

   // 1エントリーのみ
   if( OrdersTotal()>0 ) {
      for( i=0; i<OrdersTotal(); i++ ) {
         if( OrderSelect(i, SELECT_BY_POS) == true ) {
            if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
               allCnt++;
               if( OrderType() == OP_BUY ) {
                  buyCnt++;
               }else if( OrderType() == OP_SELL ) {
                  sellCnt++;
               }
            }
         }
      }
   }
   if( allCnt > 0 ) {
      return(0);
   }

   // ロット数計算
   if( RiskPercent > 0 ) {
      double balance = AccountBalance();
      double riskBalance = ( balance*RiskPercent )/100.0;
      lots = dts2( riskBalance/( 100000*unitParPips*LossCutPips ) );
   } else {
      lots = Lots;
   }

   // Get Parameters
   double up = iCustom( Symbol(), PERIOD_CURRENT, "1tap_scal_tool", -1*TimeDiff, 2000, false, false, false, false, TakeProfitPips, LossCutPips, White, Black, Lime, Black, Red, Lime, 0, 0 );
   double down = iCustom( Symbol(), PERIOD_CURRENT, "1tap_scal_tool", -1*TimeDiff, 2000, false, false, false, false, TakeProfitPips, LossCutPips, White, Black, Lime, Black, Red, Lime, 1, 0 );
   int spread = MarketInfo( Symbol(), MODE_SPREAD ); // 0.5pips → 5 1pips → 10
   string ema = ObjectDescription( "20EMA" ); // 「↑」 or 「↓」
   string stochas = ObjectDescription( "StochasResult" ); // 「√」
   string osma = ObjectDescription( "OsMAResult" ); // 「√」
   string estrangement = ObjectDescription( "MakairiResult" ); // 「√」

   // Highエントリー
   if( up != EMPTY_VALUE && up != 0 ) {
      if( spread > MaxSpread ) {
         if( lastLog != Time[0] ) {
            Print( "Spread Over.[" + spread + "]" );
            lastLog = Time[0];
         }
         return(0);
      }
      if( Filter ) {
        if( ema != "↑" ) {
           if( lastLog != Time[0] ) {
              Print( "Invalid EMA.["+ema+"]" );
              lastLog = Time[0];
           }
           return(0);
        }
        if( stochas != "√" && osma != "√" && estrangement != "√" ) {
           if( lastLog != Time[0] ) {
              Print( "All Conditions Unmatch.["+stochas+","+osma+","+estrangement+"]" );
              lastLog = Time[0];
           }
           return(0);
        }
      }
      // エントリー
      if( LossCutPips > 0 ) {
         sl = Ask-LossCutPips*pipsRate;
      } else {
         sl = 0;
      }
      if( TakeProfitPips > 0 ) {
         tp = Ask+TakeProfitPips*pipsRate;
      } else {
         tp = 0;
      }
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, "BreakOrder BUY", Magic, 0, Red);
      if( ticket < 0 ) {
        if( lastLog != Time[0] ) {
          Print( "Error Opening BuyOrder." );
          Print( GetLastError() );
          lastLog = Time[0];
        }
      } else {
        Print( "BuyOrder. " +Ask+" ["+spread+","+ema+","+stochas+","+osma+","+estrangement+"]" );
      }
   }

   // Lowエントリー
   if( down != EMPTY_VALUE && down != 0 ) {
      if( spread > MaxSpread ) {
         if( lastLog != Time[0] ) {
            Print( "Spread Over.[" + spread + "]" );
            lastLog = Time[0];
         }
         return(0);
      }
      if( Filter ) {
        if( ema != "↓" ) {
           if( lastLog != Time[0] ) {
              Print( "Invalid EMA.["+ema+"]" );
              lastLog = Time[0];
           }
           return(0);
        }
        if( stochas != "√" && osma != "√" && estrangement != "√" ) {
           if( lastLog != Time[0] ) {
              Print( "All Conditions Unmatch.["+stochas+","+osma+","+estrangement+"]" );
              lastLog = Time[0];
           }
           return(0);
        }
      }
      // エントリー
      if( LossCutPips > 0 ) {
         sl = Bid+LossCutPips*pipsRate;
      } else {
         sl = 0;
      }
      if( TakeProfitPips > 0 ) {
         tp = Bid-TakeProfitPips*pipsRate;
      } else {
         tp = 0;
      }
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, "BreakOrder SELL", Magic, 0, Blue);
      if( ticket < 0 ) {
        if( lastLog != Time[0] ) {
          Print( "Error Opening SellOrder." );
          Print( GetLastError() );
          lastLog = Time[0];
        }
      } else {
        Print( "SellOrder. " +Bid+" ["+spread+","+ema+","+stochas+","+osma+","+estrangement+"]" );
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


void CheckTPSL()
{
   double sl,tp,open_price;
   int type;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i, SELECT_BY_POS);
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != Magic) continue;
      type = OrderType();
      if(type > OP_SELL) continue;
      if((LossCutPips>0 && OrderStopLoss()==0) || (TakeProfitPips>0 && OrderTakeProfit()==0))
      {
         sl=0;
         tp=0;
         open_price=OrderOpenPrice();
         if(type==OP_BUY)
         {
            if(LossCutPips > 0) sl = open_price-LossCutPips*pipsRate;
            if(TakeProfitPips > 0) tp = open_price+TakeProfitPips*pipsRate;
         }
         else
         {
            if(LossCutPips>0) sl = open_price+LossCutPips*pipsRate;
            if(TakeProfitPips>0) tp = open_price-TakeProfitPips*pipsRate;
         }
         OrderModify(OrderTicket(),open_price,sl,tp,0);
      }
   }
}
