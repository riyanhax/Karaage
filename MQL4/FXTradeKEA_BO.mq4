#property copyright "Copyright(C) 2018 Studiogadget Inc."

extern int Magic = 37654321;
//extern double RiskPercent = 0.0;
extern double BalanceForLot = 1000000.0;
extern double Lots = 0.01;
extern string Explanation1 = "BalanceForLotを0.0に設定した場合にLots有効";
extern double TakeProfitPips = 6.0;
extern double LossCutPips = 6.0;
extern int TimeSettlement = 0;
extern bool AutoSupport = false;
extern int MaxSpread = 9;
extern string Explanation2 = "MaxSpread: 0.5pips → 5, 1pips → 10";
extern int MaxEntry = 999;
extern double RsiL = 30;
extern double RsiU = 70;
extern int RsiTerm = 8;
extern bool CciLimit = true;
extern int CciTerm = 14;
extern double CciAbs = 100.0;
extern bool Envelopes = true;
extern double EnvelopesDeviation = 0.05;
extern int EnvelopesTerm = 3;
extern bool Sto = true;
extern int StoKPeriod = 5;
extern int StoDPeriod = 2;
extern int StoSlowing = 2;
extern int StoLevelLower = 10;
extern int StoLevelUpper = 90;
extern bool Vgfx = false;
extern bool HiLoBands = false;
extern int CountBars = 4000;
extern int Bandlen = 9;
extern bool BreakOrder = false;
extern bool BOFilter = false;
extern int TimeDiff = 6;
extern double MinSigma = 2.0;
extern double MinLength = 0.0;
extern bool Reverse = false;

datetime lastLog = 0;
double pipsRate;
double unitParPips;
datetime lastOrderTime = 0;
datetime lastTestTime = 0;
int lastError = 0;
datetime lastErrorTime = 0;
datetime orderModifyTime = 0;
int timeframe;

int init(){
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   unitParPips = currencyUnitPerPips( Symbol() );
   //Print( "UnitPerPips: "+unitParPips );

   timeframe = Period();

   return(0);
}

int start(){
   int ticket;
   int i;
   double lots;
   double sigma00;
   double sigma05U;
   double sigma10U;
   double sigma15U;
   double sigma20U;
   double sigma25U;
   double sigma30U;
   double sigma35U;
   double sigma40U;
   double sigma45U;
   double sigma50U;
   double sigma05L;
   double sigma10L;
   double sigma15L;
   double sigma20L;
   double sigma25L;
   double sigma30L;
   double sigma35L;
   double sigma40L;
   double sigma45L;
   double sigma50L;
   double sigma;
   double price;
   double lengthD;
   double doubleTemp;
   double rsi;
   double cci;
   double envelopesUp;
   double envelopesDown;
   int errChk;
   double currentProfitPips;
   int tempInt;
   int supportCount;
   double fixedProfitPips;
   double supportLine;
   bool res;
   string msg;
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
   datetime current;
   double vgfxBuy;
   double vgfxSell;
   double tp;
   double sl;
   int entryCnt;
   int spread;
   double stoValue;
   bool stochastic;
   double hiBand;
   double loBand;
   double boUp;
   double boDown;
   string ema;
   string stochas;
   string osma;
   string estrangement;

   // TP SL チェック
   //CheckTPSL();

  if( OrdersTotal() > 0){
    for( i=0; i<OrdersTotal(); i++ ){
       if( OrderSelect(i, SELECT_BY_POS) == true ){
          if( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) {
             entryCnt++;
             if( TimeSettlement > 0 ) {
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
                      if( OrderTakeProfit() > 0 ) {
                         res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, OrderTakeProfit(), 0, Red );
                      } else {
                         res = OrderModify( OrderTicket(), OrderOpenPrice(), supportLine, 0, 0, Red );
                      }
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


   // ロット数計算
  /**
   if( RiskPercent > 0 ) {
      double balance = AccountBalance();
      double riskBalance = ( balance*RiskPercent )/100.0;
      lots = dts2( riskBalance/( 100000*unitParPips*LossCutPips ) );
   } else {
      lots = Lots;
   }
**/
   if( BalanceForLot > 0 ) {
      lots = dts2(AccountBalance()/BalanceForLot);
   } else {
      lots = Lots;
   }

   // 同時エントリー制限
   if( entryCnt >= MaxEntry ) {
    return(0);
   }

   // 同じ足でのエントリーを避ける
   if( lastOrderTime == Time[0] ) {
      return(0);
   }

   // σ値(絶対値)算出
   price = Close[1];
   lengthD = MathAbs( Open[1]-Close[1] )/pipsRate;
   sigma00 = iBands( Symbol(), PERIOD_CURRENT, 20, 0, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma05U = iBands( Symbol(), PERIOD_CURRENT, 20, 0.5, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma05L  = iBands( Symbol(), PERIOD_CURRENT, 20, 0.5, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma10U = iBands( Symbol(), PERIOD_CURRENT, 20, 1.0, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma10L  = iBands( Symbol(), PERIOD_CURRENT, 20, 1.0, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma15U = iBands( Symbol(), PERIOD_CURRENT, 20, 1.5, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma15L  = iBands( Symbol(), PERIOD_CURRENT, 20, 1.5, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma20U = iBands( Symbol(), PERIOD_CURRENT, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma20L  = iBands( Symbol(), PERIOD_CURRENT, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma25U = iBands( Symbol(), PERIOD_CURRENT, 20, 2.5, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma25L  = iBands( Symbol(), PERIOD_CURRENT, 20, 2.5, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma30U = iBands( Symbol(), PERIOD_CURRENT, 20, 3.0, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma30L  = iBands( Symbol(), PERIOD_CURRENT, 20, 3.0, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma35U = iBands( Symbol(), PERIOD_CURRENT, 20, 3.5, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma35L  = iBands( Symbol(), PERIOD_CURRENT, 20, 3.5, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma40U = iBands( Symbol(), PERIOD_CURRENT, 20, 4.0, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma40L  = iBands( Symbol(), PERIOD_CURRENT, 20, 4.0, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma45U = iBands( Symbol(), PERIOD_CURRENT, 20, 4.5, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma45L  = iBands( Symbol(), PERIOD_CURRENT, 20, 4.5, 0, PRICE_CLOSE, MODE_LOWER, 1 );
   sigma50U = iBands( Symbol(), PERIOD_CURRENT, 20, 5.0, 0, PRICE_CLOSE, MODE_UPPER, 1 );
   sigma50L  = iBands( Symbol(), PERIOD_CURRENT, 20, 5.0, 0, PRICE_CLOSE, MODE_LOWER, 1 );

   if( price >= sigma50U ) { // +5.0σ以上は5.0とする
      sigma = 5.0;
   } else if( price >= sigma45U ) {
      doubleTemp = ( ( price-sigma45U )/( sigma50U-sigma45U ) )*0.5;
      sigma = dt1( 4.5+doubleTemp );
   } else if( price >= sigma40U ) {
      doubleTemp = ( ( price-sigma40U )/( sigma45U-sigma40U ) )*0.5;
      sigma = dt1( 4.0+doubleTemp );
   } else if( price >= sigma35U ) {
      doubleTemp = ( ( price-sigma35U )/( sigma40U-sigma35U ) )*0.5;
      sigma = dt1( 3.5+doubleTemp );
   } else if( price >= sigma30U ) {
      doubleTemp = ( ( price-sigma30U )/( sigma35U-sigma30U ) )*0.5;
      sigma = dt1( 3.0+doubleTemp );
   } else if( price >= sigma25U ) {
      doubleTemp = ( ( price-sigma25U )/( sigma30U-sigma25U ) )*0.5;
      sigma = dt1( 2.5+doubleTemp );
   } else if( price >= sigma20U ) {
      doubleTemp = ( ( price-sigma20U )/( sigma25U-sigma20U ) )*0.5;
      sigma = dt1( 2.0+doubleTemp );
   } else if( price >= sigma15U ) {
      doubleTemp = ( ( price-sigma15U )/( sigma20U-sigma15U ) )*0.5;
      sigma = dt1( 1.5+doubleTemp );
   } else if( price >= sigma10U ) {
      doubleTemp = ( ( price-sigma10U )/( sigma15U-sigma10U ) )*0.5;
      sigma = dt1( 1.0+doubleTemp );
   } else if( price >= sigma05U ) {
      doubleTemp = ( ( price-sigma05U )/( sigma10U-sigma05U ) )*0.5;
      sigma = dt1( 0.5+doubleTemp );
   } else if( price >= sigma00 ) {
      doubleTemp = ( ( price-sigma00 )/( sigma05U-sigma00 ) )*0.5;
      sigma = dt1( 0.0+doubleTemp );
   } else if( price <= sigma50L ) { // -5.0σ以下は-5.0とする
      sigma = 5.0;
   } else if( price <= sigma45L ) {
      doubleTemp = ( ( sigma45L-price )/( sigma45L-sigma50L ) )*0.5;
      sigma = dt1( 4.5+doubleTemp );
   } else if( price <= sigma40L ) {
      doubleTemp = ( ( sigma40L-price )/( sigma40L-sigma45L ) )*0.5;
      sigma = dt1( 4.0+doubleTemp );
   } else if( price <= sigma35L ) {
      doubleTemp = ( ( sigma35L-price )/( sigma35L-sigma40L ) )*0.5;
      sigma = dt1( 3.5+doubleTemp );
   } else if( price <= sigma30L ) {
      doubleTemp = ( ( sigma30L-price )/( sigma30L-sigma35L ) )*0.5;
      sigma = dt1( 3.0+doubleTemp );
   } else if( price <= sigma25L ) {
      doubleTemp = ( ( sigma25L-price )/( sigma25L-sigma30L ) )*0.5;
      sigma = dt1( 2.5+doubleTemp );
   } else if( price <= sigma20L ) {
      doubleTemp = ( ( sigma20L-price )/( sigma20L-sigma25L ) )*0.5;
      sigma = dt1( 2.0+doubleTemp );
   } else if( price <= sigma15L ) {
      doubleTemp = ( ( sigma15L-price )/( sigma15L-sigma20L ) )*0.5;
      sigma = dt1( 1.5+doubleTemp );
   } else if( price <= sigma10L ) {
      doubleTemp = ( ( sigma10L-price )/( sigma10L-sigma15L ) )*0.5;
      sigma = dt1( 1.0+doubleTemp );
   } else if( price <= sigma05L ) {
      doubleTemp = ( ( sigma05L-price )/( sigma05L-sigma10L ) )*0.5;
      sigma = dt1( 0.5+doubleTemp );
   } else if( price <= sigma00 ) {
      doubleTemp = ( ( sigma00-price )/( sigma00-sigma05L ) )*0.5;
      sigma = dt1( 0.0+doubleTemp );
   }

   spread = MarketInfo( Symbol(), MODE_SPREAD );

   rsi = iRSI( Symbol(), PERIOD_CURRENT, RsiTerm, PRICE_CLOSE, 1 );
   cci = iCustom( Symbol(), PERIOD_CURRENT, "CCI", CciTerm, 0, 1 );
   envelopesUp = iEnvelopes( Symbol(), PERIOD_CURRENT, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_UPPER, 1 );
   envelopesDown = iEnvelopes( Symbol(), PERIOD_CURRENT, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_LOWER, 1 );
   if( Vgfx ) {
      vgfxBuy = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",2,1);
      vgfxSell = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",3,1);
   }
   if( Sto ) {
      stoValue = iStochastic( Symbol(), PERIOD_CURRENT, StoKPeriod, StoDPeriod, StoSlowing, MODE_SMA, 0, MODE_MAIN, 1 );
      if( stoValue <= StoLevelLower || StoLevelUpper <= stoValue ) {
         stochastic = true;
      } else {
         stochastic = false;
      }
   }
   if( HiLoBands ) {
      hiBand = iCustom( Symbol(), PERIOD_CURRENT, "HiLoBands", CountBars, Bandlen, 0, 1 );
      loBand = iCustom( Symbol(), PERIOD_CURRENT, "HiLoBands", CountBars, Bandlen, 1, 1 );
   }
   if( BreakOrder ) {
      boUp = iCustom( Symbol(), PERIOD_CURRENT, "1tap_scal_tool", -1*TimeDiff, 2000, false, false, false, false, TakeProfitPips, LossCutPips, White, Black, Lime, Black, Red, Lime, 0, 0 );
      boDown = iCustom( Symbol(), PERIOD_CURRENT, "1tap_scal_tool", -1*TimeDiff, 2000, false, false, false, false, TakeProfitPips, LossCutPips, White, Black, Lime, Black, Red, Lime, 1, 0 );
      ema = ObjectDescription( "20EMA" ); // 「↑」 or 「↓」
      stochas = ObjectDescription( "StochasResult" ); // 「√」
      osma = ObjectDescription( "OsMAResult" ); // 「√」
      estrangement = ObjectDescription( "MakairiResult" ); // 「√」
      if( BOFilter ) {
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
   }

   // Highエントリー
   if( price <= sigma00 && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci <= -CciAbs ) &&  ( !Envelopes || price <= envelopesDown ) && lengthD >= MinLength && ( !Vgfx || ( vgfxBuy != 0 && vgfxBuy != EMPTY_VALUE ) ) && ( !Sto || stochastic ) && ( !HiLoBands || ( High[1] >= hiBand ) ) && ( !BreakOrder || ( boUp != EMPTY_VALUE && boUp != 0 ) ) ) {
      if( spread > MaxSpread ) {
         if( lastLog != Time[0] ) {
            Print( "Invalid Spread.["+spread+"]" );
            lastLog = Time[0];
         }
         return(0);
      }
      // エントリー
      if( Reverse ) {
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
        ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, "SELL ORDER", Magic, 0, Blue);
        if( ticket < 0 ) {
          if( lastLog != Time[0] ) {
            Print( "Error Opening SellOrder." );
            Print( GetLastError() );
            lastLog = Time[0];
          }
        } else {
          Print( "SELL_ORDER "+price+" "+sigma+" "+rsi+" "+cci+" "+envelopesUp+" "+envelopesDown+" "+lengthD+" "+spread );
          lastOrderTime = Time[0];
        }
      } else {
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
        ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, "BUY ORDER", Magic, 0, Red );
        if( ticket < 0 ) {
          if( lastLog != Time[0] ) {
            Print( "Error Opening BuyOrder." );
            Print( GetLastError() );
            lastLog = Time[0];
          }
        } else {
          Print( "BUY_ORDER "+price+" "+sigma+" "+rsi+" "+cci+" "+envelopesUp+" "+envelopesDown+" "+lengthD+" "+spread);
          lastOrderTime = Time[0];
        }
      }
   }

   // Lowエントリー
   if( price >= sigma00 && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci >= CciAbs ) && ( !Envelopes || price >= envelopesUp ) && lengthD >= MinLength && ( !Vgfx || ( vgfxSell != 0 && vgfxSell != EMPTY_VALUE ) ) && ( !Sto || stochastic ) && ( !HiLoBands || ( Low[1] <= loBand ) ) && ( !BreakOrder || ( boDown != EMPTY_VALUE && boDown != 0 ) ) ) {
      if( spread > MaxSpread ) {
         if( lastLog != Time[0] ) {
            Print( "Invalid Spread.["+spread+"]" );
            lastLog = Time[0];
         }
         return(0);
      }
      // エントリー
      if( Reverse ) {
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
        ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, sl, tp, "BUY ORDER", Magic, 0, Red );
        if( ticket < 0 ) {
          if( lastLog != Time[0] ) {
            Print( "Error Opening BuyOrder." );
            Print( GetLastError() );
            lastLog = Time[0];
          }
        } else {
          Print( "BUY_ORDER "+price+" "+sigma+" "+rsi+" "+cci+" "+envelopesUp+" "+envelopesDown+" "+lengthD+" "+spread);
          lastOrderTime = Time[0];
        }
      } else {
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
        ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, sl, tp, "SELL ORDER", Magic, 0, Blue);
        if( ticket < 0 ) {
          if( lastLog != Time[0] ) {
            Print( "Error Opening SellOrder." );
            Print( GetLastError() );
            lastLog = Time[0];
          }
        } else {
          Print( "SELL_ORDER "+price+" "+sigma+" "+rsi+" "+cci+" "+envelopesUp+" "+envelopesDown+" "+lengthD+" "+spread );
          lastOrderTime = Time[0];
        }
      }
   }

   return(0);
}

int deinit(){
   return(0);
}

// 小数点を1桁に切る
double dt1( double val ) {
   return( StrToDouble( ( DoubleToStr( val, 1 ) ) ) );
}

// 小数点を2桁に切る
double dts2( double val ) {
   return( StrToDouble ( ( DoubleToStr( val, 2 ) ) ) );
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
