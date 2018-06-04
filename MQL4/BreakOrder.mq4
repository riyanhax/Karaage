#property copyright "Copyright(C) 2018 Studiogadget Inc."

extern int Magic = 37654321;
extern double RiskPercent = 1.0;
extern double Lots = 0.01;
extern string Explanation1 = "RiskPercentを0.0に設定した場合にLots有効";
extern double TakeProfitPips = 12.0;
extern double LossCutPips = 6.0;
extern int MaxSpread = 9;
extern string Explanation2 = "MaxSpread: 0.5pips → 5, 1pips → 10";
extern bool TimeControl = true;
extern int TimeDiff = 9;

double zigzagHigh = 0.0;
double zigzagLow = 0.0;
datetime lastZigzagYamaTani = 0;
datetime lastLog = 0;
double pipsRate;
double unitParPips;

int init(){
  ObjectDelete( "cross" );

   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   // 直近のZigZagの最大値、最小値を取得
   zigzagYamaTani("ZigZag", PERIOD_CURRENT, 7, 5, 3, 300);
   lastZigzagYamaTani = Time[0];
   //Print( "Zigzag H:"+zigzagHigh+" L:"+zigzagLow );

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

   // 各足で一回だけ直近のZigZagの最大値、最小値を取得
   if( Time[0] != lastZigzagYamaTani ) {
      zigzagYamaTani( "ZigZag", PERIOD_CURRENT, 7, 5, 3, 300 );
      lastZigzagYamaTani = Time[0];
      //Print( "Zigzag H:"+zigzagHigh+" L:"+zigzagLow );
   }

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
   int spread = MarketInfo( Symbol(), MODE_SPREAD ); // 0.5pips → 5 1pips → 10
   string ema = ObjectDescription( "20EMA" ); // 「↑」 or 「↓」
   string stochas = ObjectDescription( "StochasResult" ); // 「√」
   string osma = ObjectDescription( "OsMAResult" ); // 「√」
   string estrangement = ObjectDescription( "MakairiResult" ); // 「√」
   //double zigzag = iCustom( Symbol(), PERIOD_CURRENT, "ZigZag", 7, 5, 3, 0, 0 );

   // Highエントリー
   if( Close[1] <= zigzagHigh && zigzagHigh < Close[0] ) {
      if( spread > MaxSpread ) {
         if( lastLog != Time[0] ) {
            Print( "Spread Over.[" + spread + "]" );
            lastLog = Time[0];
         }
         return(0);
      }
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
      // エントリー
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, Bid-LossCutPips*pipsRate, Bid+TakeProfitPips*pipsRate, "BUY ORDER", Magic, 0, Red);
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
   if( Close[1] >= zigzagLow && zigzagLow > Close[0] ) {
      if( spread > MaxSpread ) {
         if( lastLog != Time[0] ) {
            Print( "Spread Over.[" + spread + "]" );
            lastLog = Time[0];
         }
         return(0);
      }
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
      // エントリー
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, Ask+LossCutPips*pipsRate, Ask-TakeProfitPips*pipsRate, "SELL ORDER", Magic, 0, Blue);
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
//|【関数】ZigZagの直近の山・谷取得                                  |
//|                                                                  |
//|【引数】 IN OUT  引数名             説明                          |
//|        --------------------------------------------------------- |
//|         ○      aZIGZAG            インジケーターファイル名      |
//|         ○      tf                 時間足                        |
//|         ○      aExtDepth          インジケーター引数１          |
//|         ○      aExtDeviation      インジケーター引数２          |
//|         ○      aExtBackstep       インジケーター引数３          |
//|         ○      aMaxLoopCount      最大ループカウント            |
//|            ○   aYama              山                            |
//|            ○   aTani              谷                            |
//|                                                                  |
//|【戻値】なし                                                      |
//|                                                                  |
//|【備考】なし                                                      |
//+------------------------------------------------------------------+
void zigzagYamaTani(string aZIGZAG, int aTf, int aExtDepth, int aExtDeviation, int aExtBackstep, int aMaxLoopCount)
{
  bool yamaFlg = false;
  bool taniFlg = false;
  zigzagHigh = 0.0;
  zigzagLow = 0.0;

  for(int i = 0; i < aMaxLoopCount; i++){
    double zigzag  = NormalizeDouble(iCustom(NULL, aTf, aZIGZAG, aExtDepth, aExtDeviation, aExtBackstep, 0, i), Digits);
    double zigzagH = NormalizeDouble(iCustom(NULL, aTf, aZIGZAG, aExtDepth, aExtDeviation, aExtBackstep, 1, i), Digits);
    double zigzagL = NormalizeDouble(iCustom(NULL, aTf, aZIGZAG, aExtDepth, aExtDeviation, aExtBackstep, 2, i), Digits);

    if(zigzag == 0){
      continue;
    }

    // 最初に出現する山または谷は無視する（取得する山と谷は２本の線の頂点として構成されているものだけ）
    if(zigzag == zigzagH){
      if(yamaFlg || (yamaFlg == false && taniFlg)){
        zigzagHigh = zigzag;
      }
      yamaFlg = true;
    }else if(zigzag == zigzagL){
      if(taniFlg || (taniFlg == false && yamaFlg)){
        zigzagLow = zigzag;
      }
      taniFlg = true;
    }

    if(zigzagHigh != 0.0 && zigzagLow != 0.0){
      break;
    }
  }
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
