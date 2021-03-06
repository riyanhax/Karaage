#property copyright "Copyright(C) 2018 Studiogadget Inc."
// 1分足で動かすこと

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
extern double RsiL = 30;
extern double RsiU = 70;
extern double RsiPosition = 0;
extern int RsiTerm = 8;
extern bool CciLimit = true;
extern int CciTerm = 14;
extern double CciAbs = 100.0;
extern int CciPosition = 1;
extern bool Envelopes = true;
extern bool EnvelopesOutSigma3 = false;
extern bool EnvelopesOutSigma2 = false;
extern double EnvelopesDeviation = 0.05;
extern int EnvelopesTerm = 3;
extern bool KakumeiLine = false;
extern int KakumeiTerm = 60;
extern bool Stochastics = false;
extern int KPeriod = 8;
extern double MinSigma = 2.0;
extern int SigmaPosition = 0;
extern int BBTerm = 20;
extern bool Victoria5m = false;
extern bool Victoria10m = false;
extern bool Vgfx = false;
extern double MinLength = 0.0;
extern bool Deeply = false;
extern double DeeplyLength = 0.0;
extern int DeeplyPeriod = 1;
extern bool DeeplyF = true;
extern double DeeplyFLength = 0.0;
extern int DeeplyFPeriod = 1;
extern bool ForwardDirection = false;
extern double Spread = 0.3;
extern int CaseDownNum = 0;
extern int SetMin = 14;
extern int ResultPosition = 0;
extern int Period = 28800;
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/green_soybeans/stop_list_dummy.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定
extern string LogName = "";

bool alertableHigh_R = true;
bool alertableLow_R = true;
datetime lastHighAlertTime = 0;
datetime lastLowAlertTime = 0;
datetime lastArrawTime = 0;
datetime lastResultTime = 0;
int executedDayOfYear = 999;
datetime stopStart[1] = {0};
datetime stopEnd[1] = {0};
bool offFlg = false;
int diffHour;
double pipsRate;
int entryCnt;
int winCnt;
int firstWinCnt;
int handle;
int entryCnt00;
int winCnt00;
int entryCnt05;
int winCnt05;
int entryCnt10;
int winCnt10;
int entryCnt15;
int winCnt15;
int entryCnt20;
int winCnt20;
int entryCnt25;
int winCnt25;
int entryCnt30;
int winCnt30;
int entryCnt35;
int winCnt35;
int entryCnt40;
int winCnt40;
int entryCnt45;
int winCnt45;
int entryCnt50;
int winCnt50;
int entryCnt55;
int winCnt55;
int entryCnt00h;
int winCnt00h;
int entryCnt01h;
int winCnt01h;
int entryCnt02h;
int winCnt02h;
int entryCnt03h;
int winCnt03h;
int entryCnt04h;
int winCnt04h;
int entryCnt05h;
int winCnt05h;
int entryCnt06h;
int winCnt06h;
int entryCnt07h;
int winCnt07h;
int entryCnt08h;
int winCnt08h;
int entryCnt09h;
int winCnt09h;
int entryCnt10h;
int winCnt10h;
int entryCnt11h;
int winCnt11h;
int entryCnt12h;
int winCnt12h;
int entryCnt13h;
int winCnt13h;
int entryCnt14h;
int winCnt14h;
int entryCnt15h;
int winCnt15h;
int entryCnt16h;
int winCnt16h;
int entryCnt17h;
int winCnt17h;
int entryCnt18h;
int winCnt18h;
int entryCnt19h;
int winCnt19h;
int entryCnt20h;
int winCnt20h;
int entryCnt21h;
int winCnt21h;
int entryCnt22h;
int winCnt22h;
int entryCnt23h;
int winCnt23h;
int entryCntDay;
int winCntDay;
int entryCntMonth;
int winCntMonth;
//double hourWinRate;
double dayWinRate;
double winRate;
double rate;

//---- buffers
double HighArrowsBuffer[];
double LowArrowsBuffer[];
double WinBuffer[];
double LoseBuffer[];
double FWinBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

//---- indicators
   SetIndexStyle( 0, DRAW_ARROW );
   SetIndexArrow( 0, 233 );
   SetIndexBuffer( 0, HighArrowsBuffer );
   SetIndexEmptyValue( 0, EMPTY_VALUE );
   SetIndexStyle( 1, DRAW_ARROW );
   SetIndexArrow( 1, 234 );
   SetIndexBuffer( 1, LowArrowsBuffer );
   SetIndexEmptyValue( 1, EMPTY_VALUE );
   SetIndexStyle( 2, DRAW_ARROW );
   SetIndexArrow( 2, 164 );
   SetIndexBuffer( 2, WinBuffer );
   SetIndexEmptyValue( 2, EMPTY_VALUE );
   SetIndexStyle( 3, DRAW_ARROW );
   SetIndexArrow( 3, 251 );
   SetIndexBuffer( 3, LoseBuffer );
   SetIndexEmptyValue( 3, EMPTY_VALUE );
   SetIndexStyle( 4, DRAW_ARROW );
   SetIndexArrow( 4, 162 );
   SetIndexBuffer( 4, FWinBuffer );
   SetIndexEmptyValue( 4, EMPTY_VALUE );
//----

   ObjectDelete( "COLOR_R" );
   ObjectDelete( "TEMP_ARRAW_R" );
   ObjectDelete( "WINRATE_K_1" );
   ObjectDelete( "WINRATE_K_2" );
   ObjectDelete( "WINRATE_K_3" );
   ObjectDelete( "WINRATE_K_4" );
   ObjectDelete( "WINRATE_K_5" );
   ObjectDelete( "WINRATE_K_6" );

   if( LogName != "" ) {
      handle = FileOpen( LogName+"_"+Symbol()+".log", FILE_SHARE_READ|FILE_WRITE );
      if(handle < 0) {
         Alert("Output File Open Error!!");
         return(0);
      } else {
         Print( "File Open.["+LogName+"_"+Symbol()+".log"+"]" );
      }
   }

   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int dayOfYear = DayOfYear();
   string time = TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS );
   string stopList;
   int length;
   int i;
   int j;
   int k;
   string tmp;
   int index;
   string today;
   int month;
   int day;
   datetime stopStartDatetime;
   datetime stopEndDatetime;
   datetime now;
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
   double doubleTemp;
   double rsi;
   double cci;
   double envelopesUp;
   double envelopesDown;
   bool off;
   string win1;
   string win2;
   string win3;
   string win4;
   string win5;
   double profit;
   string timeTemp;
   double stochasticK_0;
   double stochasticK_1;
   double kakumeiMin;
   double kakumeiMax;
   int kakumeiHighFlg = 0;
   int kakumeiLowFlg = 0;
   double lengthD;
   double victoria5mHigh;
   double victoria5mLow;
   double victoria10mHigh;
   double victoria10mLow;
   double vgfxBuy;
   double vgfxSell;
   double deeplyLow;
   double deeplyHigh;
   double deeplyFLow;
   double deeplyFHigh;

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

   // 経済指標時間帯、00分付近、時間外は背景色を変更
   now = TimeCurrent();
   off = false;
   for( i=0; i < ArraySize( stopStart )-1; i++ ){
      if( stopStart[i] <= now && now < stopEnd[i] ) {
         off = true;
         break;
      }
   }
/*
   if( 58 <= Minute() || Minute() <= 0 ) {
      off = true;
   }
*/
   if( ( 4 <= TimeHour( TimeLocal() ) && TimeHour( TimeLocal() ) <= 8 ) ) {
      off = true;
   }
   if( off ) {
      if( !offFlg ) {
         setBackground( "OFF" );
         offFlg = true;
      }
   } else {
      if( offFlg ) {
         defaultBackground();
         offFlg = false;
      }
   }

   // σ値(絶対値)算出
   price = Close[SigmaPosition];
   lengthD = MathAbs( Open[0]-Close[0] )/pipsRate;
   sigma00 = iBands( Symbol(), PERIOD_M15, BBTerm, 0, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma05U = iBands( Symbol(), PERIOD_M15, BBTerm, 0.5, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma05L  = iBands( Symbol(), PERIOD_M15, BBTerm, 0.5, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma10U = iBands( Symbol(), PERIOD_M15, BBTerm, 1.0, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma10L  = iBands( Symbol(), PERIOD_M15, BBTerm, 1.0, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma15U = iBands( Symbol(), PERIOD_M15, BBTerm, 1.5, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma15L  = iBands( Symbol(), PERIOD_M15, BBTerm, 1.5, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma20U = iBands( Symbol(), PERIOD_M15, BBTerm, 2.0, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma20L  = iBands( Symbol(), PERIOD_M15, BBTerm, 2.0, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma25U = iBands( Symbol(), PERIOD_M15, BBTerm, 2.5, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma25L  = iBands( Symbol(), PERIOD_M15, BBTerm, 2.5, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma30U = iBands( Symbol(), PERIOD_M15, BBTerm, 3.0, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma30L  = iBands( Symbol(), PERIOD_M15, BBTerm, 3.0, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma35U = iBands( Symbol(), PERIOD_M15, BBTerm, 3.5, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma35L  = iBands( Symbol(), PERIOD_M15, BBTerm, 3.5, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma40U = iBands( Symbol(), PERIOD_M15, BBTerm, 4.0, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma40L  = iBands( Symbol(), PERIOD_M15, BBTerm, 4.0, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma45U = iBands( Symbol(), PERIOD_M15, BBTerm, 4.5, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma45L  = iBands( Symbol(), PERIOD_M15, BBTerm, 4.5, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );
   sigma50U = iBands( Symbol(), PERIOD_M15, BBTerm, 5.0, 0, PRICE_CLOSE, MODE_UPPER, SigmaPosition );
   sigma50L  = iBands( Symbol(), PERIOD_M15, BBTerm, 5.0, 0, PRICE_CLOSE, MODE_LOWER, SigmaPosition );

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

   rsi = iRSI( Symbol(), PERIOD_M15, RsiTerm, PRICE_CLOSE, RsiPosition );
   if( CciLimit ) {
      cci = iCustom( Symbol(), PERIOD_M15, "CCI", CciTerm, 0, CciPosition );
   }
   if( Envelopes ) {
      envelopesUp = iEnvelopes( Symbol(), PERIOD_M15, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_UPPER, 0 );
      envelopesDown = iEnvelopes( Symbol(), PERIOD_M15, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_LOWER, 0 );
   }
   if( Stochastics ) {
      stochasticK_1 = iCustom( Symbol(), PERIOD_M15, "Stochastics4", KPeriod, 3, 3, 3, "", 0, "", 0, 0, 0, 1 );
      stochasticK_0 = iCustom( Symbol(), PERIOD_M15, "Stochastics4", KPeriod, 3, 3, 3, "", 0, "", 0, 0, 0, 0 );
   }
   if( KakumeiLine ) {
      // 期間の最大値、最小値を取得
      kakumeiMin = Low[2];
      kakumeiMax = High[2];
      for( i=3; i<=KakumeiTerm+2; i++ ) {
         if( kakumeiMin > Low[i] ) {
            kakumeiMin = Low[i];
         }
         if( kakumeiMax < High[i] ) {
            kakumeiMax = High[i];
         }
      }

      // 1本前で最大値(最小値)を更新して、1本前と現在の足が共に陽線(陰線)の場合エントリー準備
      kakumeiLowFlg = 0;
      kakumeiHighFlg = 0;
      if( kakumeiMin > Low[1] && Open[1] > Close[1] && Open[0] > Close[0] ) {
         kakumeiHighFlg = 1;
      }
      if( kakumeiMax < High[1] && Open[1] < Close[1] && Open[0] < Close[0] ) {
         kakumeiLowFlg = 1;
      }
   }
   if( Victoria5m ) {
      victoria5mLow = iCustom( Symbol(), PERIOD_M15, "Binary Victoria 5m", 0, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 0, 1 );
      victoria5mHigh = iCustom( Symbol(), PERIOD_M15, "Binary Victoria 5m", 0, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 1, 1 );
   }
   if( Victoria10m ) {
      victoria10mLow = iCustom( Symbol(), PERIOD_M15, "Binary Victoria 10m", 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 0, 1 );
      victoria10mHigh =iCustom( Symbol(), PERIOD_M15, "Binary Victoria 10m", 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 1, 1 );
   }
   if( Vgfx ) {
      vgfxBuy = iCustom(Symbol(),PERIOD_M15,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",2,1);
      vgfxSell = iCustom(Symbol(),PERIOD_M15,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",3,1);
   }

   // LOWトレンド
   if( ( Victoria5m || Victoria10m || price >= sigma00 ) && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci >= CciAbs ) && ( !Envelopes || price >= envelopesUp ) && ( !EnvelopesOutSigma3 || envelopesUp >= sigma30U ) && ( !EnvelopesOutSigma2 || envelopesUp >= sigma20U ) && ( !Stochastics || stochasticK_1 <= stochasticK_0 ) && ( !KakumeiLine || kakumeiLowFlg > 0 ) && ( !Victoria5m || ( victoria5mLow != 0 && victoria5mLow != EMPTY_VALUE ) ) && ( !Victoria10m || ( victoria10mLow != 0 && victoria10mLow != EMPTY_VALUE ) ) && ( !Vgfx || ( vgfxSell != 0 && vgfxSell != EMPTY_VALUE ) ) && lengthD >= MinLength ) {
      if( !ForwardDirection ) {
         if( alertableLow_R ) {
            setBackground( "LOW" );
            CreateTempArrawObject( OBJ_ARROW_SELL, Time[0], High[0]+2*pipsRate );
            if( lastLowAlertTime != Time[0] ) {
               alert( "LOW_R", time );
               lastLowAlertTime = Time[0];
            }
         }
         alertableLow_R = false;
      } else {
         if( alertableHigh_R ) {
            setBackground( "HIGH" );
            CreateTempArrawObject( OBJ_ARROW_BUY, Time[0], Low[0]-2*pipsRate );
            if( lastHighAlertTime != Time[0] ) {
               alert( "HIGH_R", time );
               lastHighAlertTime = Time[0];
            }
         }
         alertableHigh_R = false;
      }
   } else {
      if( !ForwardDirection ) {
         if( !alertableLow_R ) {
            defaultBackground();
            deleteTempArraw();
            alertableLow_R = true;
         }
      } else {
         if( !alertableHigh_R ) {
            defaultBackground();
            deleteTempArraw();
            alertableHigh_R = true;
         }
      }
   }

   // HIGHトレンド
   if( ( Victoria5m || Victoria10m || price <= sigma00 ) && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci <= -CciAbs ) &&  ( !Envelopes || price <= envelopesDown ) && ( !EnvelopesOutSigma3 || envelopesDown <= sigma30L ) && ( !EnvelopesOutSigma2 || envelopesDown <= sigma20L ) && (!Stochastics || stochasticK_1 >= stochasticK_0) && ( !KakumeiLine || kakumeiHighFlg > 0 ) && ( !Victoria5m || ( victoria5mHigh != 0 && victoria5mHigh != EMPTY_VALUE ) ) && ( !Victoria10m || ( victoria10mHigh != 0 && victoria10mHigh != EMPTY_VALUE ) ) && ( !Vgfx || ( vgfxBuy != 0 && vgfxBuy != EMPTY_VALUE ) ) && lengthD >= MinLength ) {
      if( !ForwardDirection ) {
         if( alertableHigh_R ) {
            setBackground( "HIGH" );
            CreateTempArrawObject( OBJ_ARROW_BUY, Time[0], Low[0]-2*pipsRate );
            if( lastHighAlertTime != Time[0] ) {
               alert( "HIGH_R", time );
               lastHighAlertTime = Time[0];
            }
         }
         alertableHigh_R = false;
      } else {
         if( alertableLow_R ) {
            setBackground( "LOW" );
            CreateTempArrawObject( OBJ_ARROW_SELL, Time[0], High[0]+2*pipsRate );
            if( lastLowAlertTime != Time[0] ) {
               alert( "LOW_R", time );
               lastLowAlertTime = Time[0];
            }
         }
         alertableLow_R = false;
      }
   } else {
      if( !ForwardDirection ) {
         if( !alertableHigh_R ) {
            defaultBackground();
            deleteTempArraw();
            alertableHigh_R = true;
         }
      } else {
         if( !alertableLow_R ) {
            defaultBackground();
            deleteTempArraw();
            alertableLow_R = true;
         }
      }
   }

   // 新たな足がある場合のみ計算
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (0);
   int limit = Bars-counted_bars;
   for( i=limit; i>14; i-- ) {
      k = iBarShift( Symbol(), PERIOD_M15, Time[i], FALSE );
      // 期間制限
      if( i>Period ) {
         continue;
      }
      // 足の最初でエントリー
      if( TimeMinute( Time[i] )%15 == 0 ) {
         // 続行
      } else {
         continue;
      }
      // 各足で1回のみ
      if( lastArrawTime >= Time[k] ) {
         continue;
      }
      lastArrawTime = Time[k];

      //price = Close[i];
      price = iClose( Symbol(), PERIOD_M15, k+SigmaPosition );
      //lengthD = MathAbs( Open[i]-Close[i] )/pipsRate;
      lengthD = MathAbs( iOpen( Symbol(), PERIOD_M15, k )-iClose( Symbol(), PERIOD_M15, k ) )/pipsRate;
      // RSIが範囲外の場合はスキップ
      rsi = iRSI( Symbol(), PERIOD_M15, RsiTerm, PRICE_CLOSE, k+RsiPosition );
      if( rsi <= RsiL || RsiU <= rsi ) {
         // σ値(絶対値)算出
         sigma00 = iBands( Symbol(), PERIOD_M15, BBTerm, 0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma05U = iBands( Symbol(), PERIOD_M15, BBTerm, 0.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma05L  = iBands( Symbol(), PERIOD_M15, BBTerm, 0.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma10U = iBands( Symbol(), PERIOD_M15, BBTerm, 1.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma10L  = iBands( Symbol(), PERIOD_M15, BBTerm, 1.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma15U = iBands( Symbol(), PERIOD_M15, BBTerm, 1.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma15L  = iBands( Symbol(), PERIOD_M15, BBTerm, 1.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma20U = iBands( Symbol(), PERIOD_M15, BBTerm, 2.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma20L  = iBands( Symbol(), PERIOD_M15, BBTerm, 2.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma25U = iBands( Symbol(), PERIOD_M15, BBTerm, 2.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma25L  = iBands( Symbol(), PERIOD_M15, BBTerm, 2.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma30U = iBands( Symbol(), PERIOD_M15, BBTerm, 3.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma30L  = iBands( Symbol(), PERIOD_M15, BBTerm, 3.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma35U = iBands( Symbol(), PERIOD_M15, BBTerm, 3.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma35L  = iBands( Symbol(), PERIOD_M15, BBTerm, 3.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma40U = iBands( Symbol(), PERIOD_M15, BBTerm, 4.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma40L  = iBands( Symbol(), PERIOD_M15, BBTerm, 4.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma45U = iBands( Symbol(), PERIOD_M15, BBTerm, 4.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma45L  = iBands( Symbol(), PERIOD_M15, BBTerm, 4.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
         sigma50U = iBands( Symbol(), PERIOD_M15, BBTerm, 5.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
         sigma50L  = iBands( Symbol(), PERIOD_M15, BBTerm, 5.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );

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

         if( CciLimit ) {
            cci = iCustom( Symbol(), PERIOD_M15, "CCI", CciTerm, 0, k+CciPosition );
         }
         if( Envelopes ) {
            envelopesUp = iEnvelopes( Symbol(), PERIOD_M15, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_UPPER, k );
            envelopesDown = iEnvelopes( Symbol(), PERIOD_M15, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_LOWER, k );
         }
         if( Stochastics ) {
            stochasticK_1 = iCustom( Symbol(), PERIOD_M15, "Stochastics4", KPeriod, 3, 3, 3, "", 0, "", 0, 0, 0, k+1 );
            stochasticK_0 = iCustom( Symbol(), PERIOD_M15, "Stochastics4", KPeriod, 3, 3, 3, "", 0, "", 0, 0, 0, k );
         }
         if( KakumeiLine ) {
            // 期間の最大値、最小値を取得
            kakumeiMin =   Low[k+2];
            kakumeiMax = High[k+2];
            for( j=k+3; j<=k+KakumeiTerm+1; j++ ) {
               if( kakumeiMin > Low[j] ) {
                  kakumeiMin = Low[j];
               }
               if( kakumeiMax < High[j] ) {
                  kakumeiMax = High[j];
               }
            }

            // 1本前で最大値(最小値)を更新して、1本前と現在の足が共に陽線(陰線)の場合エントリー
            kakumeiLowFlg = 0;
            kakumeiHighFlg = 0;
            if( kakumeiMin > Low[k+1] && Open[k+1] > Close[k+1] && Open[k] > Close[k] ) {
               kakumeiHighFlg = 1;
            }
            if( kakumeiMax < High[k+1] && Open[k+1] < Close[k+1] && Open[k] < Close[k] ) {
               kakumeiLowFlg = 1;
            }
         }
         victoria5mLow = 0;
         victoria5mHigh = 0;
         if( Victoria5m ) {
            victoria5mLow = iCustom( Symbol(), PERIOD_M15, "Binary Victoria 5m", 0, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 0, k );
            victoria5mHigh = iCustom( Symbol(), PERIOD_M15, "Binary Victoria 5m", 0, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 14, 1, 14, 0, 4, 0, 1, k );
         }
         victoria10mLow = 0;
         victoria10mHigh = 0;
         if( Victoria10m ) {
            victoria10mLow = iCustom( Symbol(), PERIOD_M15, "Binary Victoria 10m", 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 0, k );
            victoria10mHigh =iCustom( Symbol(), PERIOD_M15, "Binary Victoria 10m", 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 4, 1, 4, 1, 4, 0, 0, 0, 1, k );
         }
         vgfxBuy = 0;
         vgfxSell = 0;
         if( Vgfx ) {
            vgfxBuy = iCustom(Symbol(),PERIOD_M15,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",2,k);
            vgfxSell = iCustom(Symbol(),PERIOD_M15,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",3,k);
         }
         if( Deeply ) {
            deeplyHigh = false;
            deeplyLow = false;
            if( ( iOpen( Symbol(), PERIOD_M1, i-14+DeeplyPeriod-1 )-iClose( Symbol(), PERIOD_M1, i-14 ) )/pipsRate >= DeeplyLength ) {
               deeplyHigh = true;
            }
            if( ( iClose( Symbol(), PERIOD_M1, i-14 )-iOpen( Symbol(), PERIOD_M1, i-14+DeeplyPeriod-1 ) )/pipsRate  >= DeeplyLength ) {
               deeplyLow = true;
            }
         }
         if( DeeplyF ) {
            deeplyFHigh = false;
            deeplyFLow = false;
            if( ( iOpen( Symbol(), PERIOD_M1, i-15+DeeplyFPeriod-1 ) - iClose( Symbol(), PERIOD_M1, i-15 ) )/pipsRate >= DeeplyFLength ) {
               deeplyFHigh = true;
            }
            if( ( iClose( Symbol(), PERIOD_M1, i-15 ) - iOpen( Symbol(), PERIOD_M1, i-15+DeeplyFPeriod-1 ) )/pipsRate  >= DeeplyFLength ) {
               deeplyFLow = true;
            }
         }

         // 矢印描画
         // LOW矢印
         if( price > sigma00 && sigma >= MinSigma && ( !CciLimit || cci >= CciAbs ) && ( !Envelopes || price >= envelopesUp ) && ( !EnvelopesOutSigma3 || envelopesUp >= sigma30U ) && ( !EnvelopesOutSigma2 || envelopesUp >= sigma20U ) && ( !Stochastics || stochasticK_1 <= stochasticK_0 ) && ( !KakumeiLine || kakumeiLowFlg > 0 ) && ( !Victoria5m || ( victoria5mLow != 0 && victoria5mLow != EMPTY_VALUE ) ) && ( !Victoria10m || ( victoria10mLow != 0 && victoria10mLow != EMPTY_VALUE ) ) && ( !Vgfx || ( vgfxSell != 0 && vgfxSell != EMPTY_VALUE ) ) && lengthD >= MinLength && ( !Deeply || deeplyLow ) && ( !DeeplyF || deeplyFLow ) ) {
            if( !ForwardDirection ) {
               LowArrowsBuffer[i-15] = High[i-15]+1*pipsRate;
            } else {
               HighArrowsBuffer[i-15] = Low[i-15]-1*pipsRate;
            }
         } else {
            if( !ForwardDirection ) {
               LowArrowsBuffer[i-15] = EMPTY_VALUE;
            } else {
               HighArrowsBuffer[i-15] = EMPTY_VALUE;
            }
         }
         // HIGH矢印
         if( price < sigma00 && sigma >= MinSigma && ( !CciLimit || cci <= -CciAbs ) &&  ( !Envelopes || price <= envelopesDown ) && ( !EnvelopesOutSigma3 || envelopesDown <= sigma30L ) && ( !EnvelopesOutSigma2 || envelopesDown <= sigma20L ) && ( !Stochastics || stochasticK_1 >= stochasticK_0 ) && ( !KakumeiLine || kakumeiHighFlg > 0 ) && ( !Victoria5m || ( victoria5mHigh != 0 && victoria5mHigh != EMPTY_VALUE ) ) && ( !Victoria10m || ( victoria10mHigh != 0 && victoria10mHigh != EMPTY_VALUE ) ) && ( !Vgfx || ( vgfxBuy != 0 && vgfxBuy != EMPTY_VALUE ) ) && lengthD >= MinLength && ( !Deeply || deeplyHigh ) && ( !DeeplyF || deeplyFHigh ) ) {
            if( !ForwardDirection ) {
               HighArrowsBuffer[i-15] = Low[i-15]-1*pipsRate;
            } else {
               LowArrowsBuffer[i-15] = High[i-15]+1*pipsRate;
            }
         } else {
            if( !ForwardDirection ) {
               HighArrowsBuffer[i-15] = EMPTY_VALUE;
            } else {
               LowArrowsBuffer[i-15] = EMPTY_VALUE;
            }
         }
      }
   }
   // 結果確認
   for( i=limit+( 1+CaseDownNum )*5; i>( 1+CaseDownNum )*5; i-- ) {
      // 期間制限
      if( i>Period ) {
         continue;
      }
      // 各足で1回のみ
      if( lastResultTime >= Time[i] ) {
         continue;
      }
      lastResultTime = Time[i];

      // パラメータ取得
      k = iBarShift( Symbol(), PERIOD_M15, Time[i], FALSE );
      price = iClose( Symbol(), PERIOD_M15, k+SigmaPosition );
      lengthD = MathAbs( iOpen( Symbol(), PERIOD_M15, k )-iClose( Symbol(), PERIOD_M15, k ) )/pipsRate;
      rsi = iRSI( Symbol(), PERIOD_M15, RsiTerm, PRICE_CLOSE, k+RsiPosition );
      sigma00 = iBands( Symbol(), PERIOD_M15, BBTerm, 0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma05U = iBands( Symbol(), PERIOD_M15, BBTerm, 0.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma05L  = iBands( Symbol(), PERIOD_M15, BBTerm, 0.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma10U = iBands( Symbol(), PERIOD_M15, BBTerm, 1.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma10L  = iBands( Symbol(), PERIOD_M15, BBTerm, 1.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma15U = iBands( Symbol(), PERIOD_M15, BBTerm, 1.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma15L  = iBands( Symbol(), PERIOD_M15, BBTerm, 1.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma20U = iBands( Symbol(), PERIOD_M15, BBTerm, 2.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma20L  = iBands( Symbol(), PERIOD_M15, BBTerm, 2.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma25U = iBands( Symbol(), PERIOD_M15, BBTerm, 2.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma25L  = iBands( Symbol(), PERIOD_M15, BBTerm, 2.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma30U = iBands( Symbol(), PERIOD_M15, BBTerm, 3.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma30L  = iBands( Symbol(), PERIOD_M15, BBTerm, 3.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma35U = iBands( Symbol(), PERIOD_M15, BBTerm, 3.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma35L  = iBands( Symbol(), PERIOD_M15, BBTerm, 3.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma40U = iBands( Symbol(), PERIOD_M15, BBTerm, 4.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma40L  = iBands( Symbol(), PERIOD_M15, BBTerm, 4.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma45U = iBands( Symbol(), PERIOD_M15, BBTerm, 4.5, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma45L  = iBands( Symbol(), PERIOD_M15, BBTerm, 4.5, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
      sigma50U = iBands( Symbol(), PERIOD_M15, BBTerm, 5.0, 0, PRICE_CLOSE, MODE_UPPER, k+SigmaPosition );
      sigma50L  = iBands( Symbol(), PERIOD_M15, BBTerm, 5.0, 0, PRICE_CLOSE, MODE_LOWER, k+SigmaPosition );
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
      cci = iCustom( Symbol(), PERIOD_M15, "CCI", 14, 0, k+CciPosition );
      envelopesUp = iEnvelopes( Symbol(), PERIOD_M15, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_UPPER, k );
      envelopesDown = iEnvelopes( Symbol(), PERIOD_M15, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_LOWER, k );

      FWinBuffer[i] = EMPTY_VALUE;
      WinBuffer[i] = EMPTY_VALUE;
      LoseBuffer[i] = EMPTY_VALUE;
      if( LowArrowsBuffer[i] != EMPTY_VALUE && LowArrowsBuffer[i] != 0 ) {
         entryCnt++;
         //CountUpMinEntry( TimeMinute( Time[i] ) );
         CountUpHourEntry( TimeHour( Time[i] ) );
         CountUpDayEntry( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
         //CountUpMonthEntry( Time[i] );
         win1 = "NG";
         win2 = "NG";
         win3 = "NG";
         win4 = "NG";
         win5 = "NG";
         if( iClose( Symbol(), PERIOD_M1, i-1*SetMin ) < iOpen( Symbol(), PERIOD_M1, i-1 )-Spread*pipsRate && CaseDownNum >= 0 ) {
            firstWinCnt++;
            winCnt++;
            FWinBuffer[i] = High[i]+2*pipsRate;
            //CountUpMinWin( TimeMinute( Time[i] ) );
            CountUpHourWin( TimeHour( Time[i] ) );
            CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
            //CountUpMonthWin( Time[i] );
            win1 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-2 ) < iOpen( Symbol(), PERIOD_M1, k-2 )-Spread*pipsRate && CaseDownNum >= 1 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) >= iOpen( Symbol(), PERIOD_M1, k-1 )-Spread*pipsRate ) {
               firstWinCnt++;
               winCnt++;
               FWinBuffer[i] = High[i]+2*pipsRate;
               //CountUpMinWin( TimeMinute( Time[i] ) );
               CountUpHourWin( TimeHour( Time[i] ) );
               CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
               //CountUpMonthWin( Time[i] );
            }
            win2 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-3 ) < iOpen( Symbol(), PERIOD_M1, k-3 )-Spread*pipsRate && CaseDownNum >= 2 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) >= iOpen( Symbol(), PERIOD_M1, k-1 )-Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-2 ) >= iOpen( Symbol(), PERIOD_M1, k-2 )-Spread*pipsRate ) {
               firstWinCnt++;
               winCnt++;
               FWinBuffer[i] = High[i]+2*pipsRate;
               //CountUpMinWin( TimeMinute( Time[i] ) );
               CountUpHourWin( TimeHour( Time[i] ) );
               CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
               //CountUpMonthWin( Time[i] );
            }
            win3 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-4 ) < iOpen( Symbol(), PERIOD_M1, k-4 )-Spread*pipsRate && CaseDownNum >= 3 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) >= iOpen( Symbol(), PERIOD_M1, k-1 )-Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-2 ) >= iOpen( Symbol(), PERIOD_M1, k-2 )-Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-3 ) >= iOpen( Symbol(), PERIOD_M1, k-3 )-Spread*pipsRate ) {
               firstWinCnt++;
               winCnt++;
               FWinBuffer[i] = High[i]+2*pipsRate;
               //CountUpMinWin( TimeMinute( Time[i] ) );
               CountUpHourWin( TimeHour( Time[i] ) );
               CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
               //CountUpMonthWin( Time[i] );
            }
            win4 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-5 ) < iOpen( Symbol(), PERIOD_M1, k-5 )-Spread*pipsRate && CaseDownNum >= 4 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) >= iOpen( Symbol(), PERIOD_M1, k-1 )-Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-2 ) >= iOpen( Symbol(), PERIOD_M1, k-2 )-Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-3 ) >= iOpen( Symbol(), PERIOD_M1, k-3 )-Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-4 ) >= iOpen( Symbol(), PERIOD_M1, k-4 )-Spread*pipsRate ) {
               winCnt++;
               WinBuffer[i] = High[i]+2*pipsRate;
            }
            win5 = "OK";
         }
         if( win1 == "NG" && win2 == "NG" && win3 == "NG" && win4 == "NG" && win5 == "NG" ) {
            LoseBuffer[i] = High[i]+2*pipsRate;
         }
         if( LogName != "" ) {
            timeTemp = TimeToStr( Time[i], TIME_DATE|TIME_SECONDS );
            StringReplace( timeTemp, ".", "/" );
            FileWrite( handle, Symbol()+" "+timeTemp+" LOW "+win1+" "+win2+" "+win3+" "+win4+" "+win5 + " " + Open[i-1+5] + " " + Open[i-2+5] + " " + Open[i-3+5] + " " + Open[i-4+5] + " " + Open[i-5+5] + " " + Open[i-1] + " " + Open[i-2] + " " + Open[i-3] + " " + Open[i-4] + " " + Open[i-5] + " " + cci + " " + rsi + " " + envelopesUp + " " + sigma + " " + lengthD );
            FileFlush( handle );
         }
      }
      if( HighArrowsBuffer[i] != EMPTY_VALUE && HighArrowsBuffer[i] != 0 ) {
         entryCnt++;
         //CountUpMinEntry( TimeMinute( Time[i] ) );
         CountUpHourEntry( TimeHour( Time[i] ) );
         CountUpDayEntry( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
         //CountUpMonthEntry( Time[i] );
         win1 = "NG";
         win2 = "NG";
         win3 = "NG";
         win4 = "NG";
         win5 = "NG";
         if( iClose( Symbol(), PERIOD_M1, i-1*SetMin ) > iOpen( Symbol(), PERIOD_M1, i-1 )+Spread*pipsRate && CaseDownNum >= 0 ) {
            firstWinCnt++;
            winCnt++;
            FWinBuffer[i] = Low[i]-2*pipsRate;
            //CountUpMinWin( TimeMinute( Time[i] ) );
            CountUpHourWin( TimeHour( Time[i] ) );
            CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
            //CountUpMonthWin( Time[i] );
            win1 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-2 ) > iOpen( Symbol(), PERIOD_M1, k-2 )+Spread*pipsRate && CaseDownNum >= 1 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) <= iOpen( Symbol(), PERIOD_M1, k-1 )+Spread*pipsRate ) {
               firstWinCnt++;
               winCnt++;
               FWinBuffer[i] = Low[i]-2*pipsRate;
               //CountUpMinWin( TimeMinute( Time[i] ) );
               CountUpHourWin( TimeHour( Time[i] ) );
               CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
               //CountUpMonthWin( Time[i] );
            }
            win2 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-3 ) > iOpen( Symbol(), PERIOD_M1, k-3 )+Spread*pipsRate && CaseDownNum >= 2 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) <= iOpen( Symbol(), PERIOD_M1, k-1 )+Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-2 ) <= iOpen( Symbol(), PERIOD_M1, k-2 )+Spread*pipsRate ) {
               firstWinCnt++;
               winCnt++;
               FWinBuffer[i] = Low[i]-2*pipsRate;
               //CountUpMinWin( TimeMinute( Time[i] ) );
               CountUpHourWin( TimeHour( Time[i] ) );
               CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
               //CountUpMonthWin( Time[i] );
            }
            win3 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-4 ) > iOpen( Symbol(), PERIOD_M1, k-4 )+Spread*pipsRate && CaseDownNum >= 3 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) <= iOpen( Symbol(), PERIOD_M1, k-1 )+Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-2 ) <= iOpen( Symbol(), PERIOD_M1, k-2 )+Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-3 ) <= iOpen( Symbol(), PERIOD_M1, k-3 )+Spread*pipsRate ) {
               firstWinCnt++;
               winCnt++;
               FWinBuffer[i] = Low[i]-2*pipsRate;
               //CountUpMinWin( TimeMinute( Time[i] ) );
               CountUpHourWin( TimeHour( Time[i] ) );
               CountUpDayWin( TimeYear( Time[i] ), TimeDayOfYear( Time[i] ) );
               //CountUpMonthWin( Time[i] );
            }
            win4 = "OK";
         }
         if( iClose( Symbol(), PERIOD_M1, k-5 ) > iOpen( Symbol(), PERIOD_M1, k-5 )+Spread*pipsRate && CaseDownNum >= 4 ) {
            if( iClose( Symbol(), PERIOD_M1, k-1 ) <= iOpen( Symbol(), PERIOD_M1, k-1 )+Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-2 ) <= iOpen( Symbol(), PERIOD_M1, k-2 )+Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-3 ) <= iOpen( Symbol(), PERIOD_M1, k-3 )+Spread*pipsRate && iClose( Symbol(), PERIOD_M1, k-4 ) <= iOpen( Symbol(), PERIOD_M1, k-4 )+Spread*pipsRate ) {
               winCnt++;
               WinBuffer[i] = Low[i]-2*pipsRate;
            }
            win5 = "OK";
         }
         if( win1 == "NG" && win2 == "NG" && win3 == "NG" && win4 == "NG" && win5 == "NG" ) {
            LoseBuffer[i] = Low[i]-2*pipsRate;
         }
         if( LogName != "" ) {
            timeTemp = TimeToStr( Time[i], TIME_DATE|TIME_SECONDS );
            StringReplace( timeTemp, ".", "/" );
            FileWrite( handle, Symbol()+" "+timeTemp+" HIGH "+win1+" "+win2+" "+win3+" "+win4+" "+win5 + " " + Open[i-1+5] + " " + Open[i-2+5] + " " + Open[i-3+5] + " " + Open[i-4+5] + " " + Open[i-5+5] + " " + Open[i-1] + " " + Open[i-2] + " " + Open[i-3] + " " + Open[i-4] + " " + Open[i-5] + " " + cci + " " + rsi + " " + envelopesDown + " " + sigma + " " + lengthD );
            FileFlush( handle );
         }
      }
   }

   CreateWinRateObject();

   //----
   return(0);
}

int deinit() {
   ObjectDelete( "COLOR_R" );
   ObjectDelete( "TEMP_ARRAW_R" );
   ObjectDelete( "WINRATE_K_1" );
   ObjectDelete( "WINRATE_K_2" );
   ObjectDelete( "WINRATE_K_3" );
   ObjectDelete( "WINRATE_K_4" );
   ObjectDelete( "WINRATE_K_5" );
   ObjectDelete( "WINRATE_K_6" );
   return(0);
}

int alert( string hl, string time ) {
   if( Mail ) {
      SendMail( "TrendAlert", "["+Symbol()+"] "+hl+"\r\ntime: "+time );
   }
   if( Alert && ( hl == "HIGH_T" || hl == "LOW_T" ) ) {
      PlaySound("alert.wav");
   } else if( Alert && ( hl == "HIGH_R" || hl == "LOW_R" ) ) {
      PlaySound("news.wav");
   }
   return(0);
}

int setBackground( string hl ) {
   if( Color ) {
      ObjectCreate( "COLOR_R", OBJ_RECTANGLE, 0, 0, 0, TimeCurrent()+120*60, 200, 0, 0 );
      if( hl == "HIGH" ) {
         ObjectSet( "COLOR_R", OBJPROP_COLOR, LightCyan );
         } else if( hl == "LOW" ) {
         ObjectSet( "COLOR_R", OBJPROP_COLOR, MistyRose );
      } else if( hl == "OFF" ) {
         ObjectSet( "COLOR_R", OBJPROP_COLOR, Gray );
      }
   }
   return(0);
}

int defaultBackground() {
   if( Color ) {
      ObjectDelete( "COLOR_R" );
   }

   return(0);
}

int deleteTempArraw() {
   ObjectDelete( "TEMP_ARRAW_R" );

   return(0);
}

// 矢印オブジェクト(一時)を生成します
bool CreateTempArrawObject(
   ENUM_OBJECT objectType,  // オブジェクトの種類(OBJ_ARROW_BUY/OBJ_ARROW_SELL)
   datetime time,           // 表示時間(横軸)
   double price ) {         // 表示価格(縦軸)

   long chartId = ChartID();

   if( !ObjectCreate( chartId, "TEMP_ARRAW_R", objectType, 0, time, price) ) {
      return false;
   }
   ObjectSetInteger( chartId, "TEMP_ARRAW_R", OBJPROP_HIDDEN, true );
   ObjectSetInteger( chartId, "TEMP_ARRAW_R", OBJPROP_COLOR, objectType == OBJ_ARROW_BUY ? C'200,200,255' : C'255,128,128' );
   ObjectSetInteger( chartId, "TEMP_ARRAW_R", OBJPROP_ARROWCODE, objectType == OBJ_ARROW_BUY ? 233 : 234 );

   return true;
}
// 勝率オブジェクトを作成します
bool CreateWinRateObject() {

   long chartId = ChartID();
   ObjectDelete( "WINRATE_H_1" );
   ObjectDelete( "WINRATE_H_2" );
   ObjectDelete( "WINRATE_H_3" );
   ObjectDelete( "WINRATE_H_4" );
   ObjectDelete( "WINRATE_H_5" );
   ObjectDelete( "WINRATE_H_6" );
   if( !ObjectCreate( chartId, "WINRATE_H_1", OBJ_LABEL, 0, 0, 0) ) {
      return false;
   }
   if( !ObjectCreate( chartId, "WINRATE_H_2", OBJ_LABEL, 0, 0, 0) ) {
      return false;
   }
   if( !ObjectCreate( chartId, "WINRATE_H_3", OBJ_LABEL, 0, 0, 0) ) {
      return false;
   }
   if( !ObjectCreate( chartId, "WINRATE_H_4", OBJ_LABEL, 0, 0, 0) ) {
      return false;
   }
   if( !ObjectCreate( chartId, "WINRATE_H_5", OBJ_LABEL, 0, 0, 0) ) {
      return false;
   }
   if( !ObjectCreate( chartId, "WINRATE_H_6", OBJ_LABEL, 0, 0, 0) ) {
      return false;
   }

   // 勝率計算
   //double minEntry = GetMinEntry( Minute() );
   //double minWin = GetMinWin( Minute() );
   //double hourEntry = GetHourEntry( Hour() );
   //double hourWin = GetHourWin( Hour() );
   double dayEntry = GetDayEntry();
   double dayWin = GetDayWin();
   double allEntry = entryCnt;
   double allWin = winCnt;
   //double monthEntry = GetMonthEntry();
   //double monthWin = GetMonthWin();
   /*
   double minWinRate;
   if( minEntry != 0 ) {
      minWinRate = dt2( (  minWin/minEntry )*100 );
   } else {
      minWinRate = 0;
   }
   if( hourEntry != 0 ) {
      hourWinRate = dt2( ( hourWin/hourEntry )*100 );
   } else {
      hourWinRate = 0;
   }
   */
   if( dayEntry != 0 ) {
      dayWinRate = dt2( ( dayWin/dayEntry )*100 );
   } else {
      dayWinRate = 0;
   }
   if( allEntry != 0 ) {
      winRate = dt2( ( allWin/allEntry )*100 );
   } else {
      winRate = 0;
   }
   /*
   double monthWinRate;
   if( monthEntry != 0 ) {
      monthWinRate = dt2( ( monthWin/monthEntry )*100 );
   } else {
      monthWinRate = 0;
   }
   */

   // 描画
   ObjectSet( "WINRATE_H_1", OBJPROP_CORNER, 1 );
   ObjectSet( "WINRATE_H_1", OBJPROP_XDISTANCE, 10 );
   ObjectSet( "WINRATE_H_1", OBJPROP_YDISTANCE, 20 );
   ObjectSetText( "WINRATE_H_1", "E: "+allEntry, 10, "Times New Roman", Silver );
   ObjectSet( "WINRATE_H_2", OBJPROP_CORNER, 1 );
   ObjectSet( "WINRATE_H_2", OBJPROP_XDISTANCE, 10 );
   ObjectSet( "WINRATE_H_2", OBJPROP_YDISTANCE, 40 );
   ObjectSetText( "WINRATE_H_2", "U: "+( allWin-( allEntry-allWin ) ), 10, "Times New Roman", Silver );
   ObjectSet( "WINRATE_H_3", OBJPROP_CORNER, 1 );
   ObjectSet( "WINRATE_H_3", OBJPROP_XDISTANCE, 10 );
   ObjectSet( "WINRATE_H_3", OBJPROP_YDISTANCE, 60 );
   if( dayWinRate < 90.0 ) {
      ObjectSetText( "WINRATE_H_3", "W%: "+winRate+"%", 10, "Times New Roman", Red );
   } else {
      ObjectSetText( "WINRATE_H_3", "W%: "+winRate+"%", 10, "Times New Roman", Silver );
   }
   /*
   ObjectSet( "WINRATE_H_4", OBJPROP_CORNER, 1 );
   ObjectSet( "WINRATE_H_4", OBJPROP_XDISTANCE, 10 );
   ObjectSet( "WINRATE_H_4", OBJPROP_YDISTANCE, 80 );
   ObjectSetText( "WINRATE_H_4", "E: "+allEntry, 10, "Times New Roman", Silver );
   ObjectSet( "WINRATE_H_5", OBJPROP_CORNER, 1 );
   ObjectSet( "WINRATE_H_5", OBJPROP_XDISTANCE, 10 );
   ObjectSet( "WINRATE_H_5", OBJPROP_YDISTANCE, 100 );
   ObjectSetText( "WINRATE_H_5", "W: "+allWin, 10, "Times New Roman", Silver );
   ObjectSet( "WINRATE_H_6", OBJPROP_CORNER, 1 );
   ObjectSet( "WINRATE_H_6", OBJPROP_XDISTANCE, 10 );
   ObjectSet( "WINRATE_H_6", OBJPROP_YDISTANCE, 120 );
   if( winRate < 90.0 ) {
      ObjectSetText( "WINRATE_H_6", "W%: "+winRate+"%", 10, "Times New Roman", Red );
   } else {
      ObjectSetText( "WINRATE_H_6", "W%: "+winRate+"%", 10, "Times New Roman", Silver );
   }
   */

   return true;
}

bool CountUpMinEntry( int minute ) {
   if( minute < 5 ) {
      entryCnt00++;
   } else if( 5 <= minute && minute < 10 ) {
      entryCnt05++;
   } else if( 10 <= minute && minute < 15 ) {
      entryCnt10++;
   } else if( 15 <= minute && minute < 20 ) {
      entryCnt15++;
   } else if( 20 <= minute && minute < 25 ) {
      entryCnt20++;
   } else if( 25 <= minute && minute < 30 ) {
      entryCnt25++;
   } else if( 30 <= minute && minute < 35 ) {
      entryCnt30++;
   } else if( 35 <= minute && minute < 40 ) {
      entryCnt35++;
   } else if( 40 <= minute && minute < 45 ) {
      entryCnt40++;
   } else if( 45 <= minute && minute < 50 ) {
      entryCnt45++;
   } else if( 50 <= minute && minute < 55 ) {
      entryCnt50++;
   } else if( 55 <= minute ) {
      entryCnt55++;
   }
   return true;
}

int GetMinEntry( int minute ) {
   if( minute < 5 ) {
      return entryCnt00;
   } else if( 5 <= minute && minute < 10 ) {
      return entryCnt05;
   } else if( 10 <= minute && minute < 15 ) {
      return entryCnt10;
   } else if( 15 <= minute && minute < 20 ) {
      return entryCnt15;
   } else if( 20 <= minute && minute < 25 ) {
      return entryCnt20;
   } else if( 25 <= minute && minute < 30 ) {
      return entryCnt25;
   } else if( 30 <= minute && minute < 35 ) {
      return entryCnt30;
   } else if( 35 <= minute && minute < 40 ) {
      return entryCnt35;
   } else if( 40 <= minute && minute < 45 ) {
      return entryCnt40;
   } else if( 45 <= minute && minute < 50 ) {
      return entryCnt45;
   } else if( 50 <= minute && minute < 55 ) {
      return entryCnt50;
   } else if( 55 <= minute ) {
      return entryCnt55;
   }
}

bool CountUpMinWin( int minute ) {
   if( minute < 5 ) {
      winCnt00++;
   } else if( 5 <= minute && minute < 10 ) {
      winCnt05++;
   } else if( 10 <= minute && minute < 15 ) {
      winCnt10++;
   } else if( 15 <= minute && minute < 20 ) {
      winCnt15++;
   } else if( 20 <= minute && minute < 25 ) {
      winCnt20++;
   } else if( 25 <= minute && minute < 30 ) {
      winCnt25++;
   } else if( 30 <= minute && minute < 35 ) {
      winCnt30++;
   } else if( 35 <= minute && minute < 40 ) {
      winCnt35++;
   } else if( 40 <= minute && minute < 45 ) {
      winCnt40++;
   } else if( 45 <= minute && minute < 50 ) {
      winCnt45++;
   } else if( 50 <= minute && minute < 55 ) {
      winCnt50++;
   } else if( 55 <= minute ) {
      winCnt55++;
   }
   return true;
}

int GetMinWin( int minute ) {
   if( minute < 5 ) {
      return winCnt00;
   } else if( 5 <= minute && minute < 10 ) {
      return winCnt05;
   } else if( 10 <= minute && minute < 15 ) {
      return winCnt10;
   } else if( 15 <= minute && minute < 20 ) {
      return winCnt15;
   } else if( 20 <= minute && minute < 25 ) {
      return winCnt20;
   } else if( 25 <= minute && minute < 30 ) {
      return winCnt25;
   } else if( 30 <= minute && minute < 35 ) {
      return winCnt30;
   } else if( 35 <= minute && minute < 40 ) {
      return winCnt35;
   } else if( 40 <= minute && minute < 45 ) {
      return winCnt40;
   } else if( 45 <= minute && minute < 50 ) {
      return winCnt45;
   } else if( 50 <= minute && minute < 55 ) {
      return winCnt50;
   } else if( 55 <= minute ) {
      return winCnt55;
   }
}

bool CountUpHourEntry( int hour ) {
   if( hour == 0 ) {
      entryCnt00h++;
   } else if( hour == 1 ) {
      entryCnt01h++;
   } else if( hour == 2 ) {
      entryCnt02h++;
   } else if( hour == 3 ) {
      entryCnt03h++;
   } else if( hour == 4 ) {
      entryCnt04h++;
   } else if( hour == 5 ) {
      entryCnt05h++;
   } else if( hour == 6 ) {
      entryCnt06h++;
   } else if( hour == 7 ) {
      entryCnt07h++;
   } else if( hour == 8 ) {
      entryCnt08h++;
   } else if( hour == 9 ) {
      entryCnt09h++;
   } else if( hour == 10 ) {
      entryCnt10h++;
   } else if( hour == 11 ) {
      entryCnt11h++;
   } else if( hour == 12 ) {
      entryCnt12h++;
   } else if( hour == 13 ) {
      entryCnt13h++;
   } else if( hour == 14 ) {
      entryCnt14h++;
   } else if( hour == 15 ) {
      entryCnt15h++;
   } else if( hour == 16 ) {
      entryCnt16h++;
   } else if( hour == 17 ) {
      entryCnt17h++;
   } else if( hour == 18 ) {
      entryCnt18h++;
   } else if( hour == 19 ) {
      entryCnt19h++;
   } else if( hour == 20 ) {
      entryCnt20h++;
   } else if( hour == 21 ) {
      entryCnt21h++;
   } else if( hour == 22 ) {
      entryCnt22h++;
   } else if( hour == 23 ) {
      entryCnt23h++;
   }
   return true;
}

int GetHourEntry( int hour ) {
   if( hour == 0 ) {
      return entryCnt00h;
   } else if( hour == 1 ) {
      return entryCnt01h;
   } else if( hour == 2 ) {
      return entryCnt02h;
   } else if( hour == 3 ) {
      return entryCnt03h;
   } else if( hour == 4 ) {
      return entryCnt04h;
   } else if( hour == 5 ) {
      return entryCnt05h;
   } else if( hour == 6 ) {
      return entryCnt06h;
   } else if( hour == 7 ) {
      return entryCnt07h;
   } else if( hour == 8 ) {
      return entryCnt08h;
   } else if( hour == 9 ) {
      return entryCnt09h;
   } else if( hour == 10 ) {
      return entryCnt10h;
   } else if( hour == 11 ) {
      return entryCnt11h;
   } else if( hour == 12 ) {
      return entryCnt12h;
   } else if( hour == 13 ) {
      return entryCnt13h;
   } else if( hour == 14 ) {
      return entryCnt14h;
   } else if( hour == 15 ) {
      return entryCnt15h;
   } else if( hour == 16 ) {
      return entryCnt16h;
   } else if( hour == 17 ) {
      return entryCnt17h;
   } else if( hour == 18 ) {
      return entryCnt18h;
   } else if( hour == 19 ) {
      return entryCnt19h;
   } else if( hour == 20 ) {
      return entryCnt20h;
   } else if( hour == 21 ) {
      return entryCnt21h;
   } else if( hour == 22 ) {
      return entryCnt22h;
   } else if( hour == 23 ) {
      return entryCnt23h;
   }
}

bool CountUpHourWin( int hour ) {
   if( hour == 0 ) {
      winCnt00h++;
   } else if( hour == 1 ) {
      winCnt01h++;
   } else if( hour == 2 ) {
      winCnt02h++;
   } else if( hour == 3 ) {
      winCnt03h++;
   } else if( hour == 4 ) {
      winCnt04h++;
   } else if( hour == 5 ) {
      winCnt05h++;
   } else if( hour == 6 ) {
      winCnt06h++;
   } else if( hour == 7 ) {
      winCnt07h++;
   } else if( hour == 8 ) {
      winCnt08h++;
   } else if( hour == 9 ) {
      winCnt09h++;
   } else if( hour == 10 ) {
      winCnt10h++;
   } else if( hour == 11 ) {
      winCnt11h++;
   } else if( hour == 12 ) {
      winCnt12h++;
   } else if( hour == 13 ) {
      winCnt13h++;
   } else if( hour == 14 ) {
      winCnt14h++;
   } else if( hour == 15 ) {
      winCnt15h++;
   } else if( hour == 16 ) {
      winCnt16h++;
   } else if( hour == 17 ) {
      winCnt17h++;
   } else if( hour == 18 ) {
      winCnt18h++;
   } else if( hour == 19 ) {
      winCnt19h++;
   } else if( hour == 20 ) {
      winCnt20h++;
   } else if( hour == 21 ) {
      winCnt21h++;
   } else if( hour == 22 ) {
      winCnt22h++;
   } else if( hour == 23 ) {
      winCnt23h++;
   }
   return true;
}

int GetHourWin( int hour ) {
   if( hour == 0 ) {
      return winCnt00h;
   } else if( hour == 1 ) {
      return winCnt01h;
   } else if( hour == 2 ) {
      return winCnt02h;
   } else if( hour == 3 ) {
      return winCnt03h;
   } else if( hour == 4 ) {
      return winCnt04h;
   } else if( hour == 5 ) {
      return winCnt05h;
   } else if( hour == 6 ) {
      return winCnt06h;
   } else if( hour == 7 ) {
      return winCnt07h;
   } else if( hour == 8 ) {
      return winCnt08h;
   } else if( hour == 9 ) {
      return winCnt09h;
   } else if( hour == 10 ) {
      return winCnt10h;
   } else if( hour == 11 ) {
      return winCnt11h;
   } else if( hour == 12 ) {
      return winCnt12h;
   } else if( hour == 13 ) {
      return winCnt13h;
   } else if( hour == 14 ) {
      return winCnt14h;
   } else if( hour == 15 ) {
      return winCnt15h;
   } else if( hour == 16 ) {
      return winCnt16h;
   } else if( hour == 17 ) {
      return winCnt17h;
   } else if( hour == 18 ) {
      return winCnt18h;
   } else if( hour == 19 ) {
      return winCnt19h;
   } else if( hour == 20 ) {
      return winCnt20h;
   } else if( hour == 21 ) {
      return winCnt21h;
   } else if( hour == 22 ) {
      return winCnt22h;
   } else if( hour == 23 ) {
      return winCnt23h;
   }
}

bool CountUpDayEntry( int year, int dayOfYear ) {
   if( year == Year() && dayOfYear == DayOfYear() ) {
      entryCntDay++;
   }
   return true;
}

int GetDayEntry() {
   return entryCntDay;
}

bool CountUpDayWin( int year, int dayOfYear ) {
   if( dayOfYear == DayOfYear() && dayOfYear == DayOfYear() ) {
      winCntDay++;
   }
   return true;
}

int GetDayWin() {
   return winCntDay;
}

bool CountUpMonthEntry( datetime time ) {
   if( time < Time[0]-60*60*24*20 ) {
      entryCntMonth++;
   }
   return true;
}

int GetMonthEntry() {
   return entryCntMonth;
}

bool CountUpMonthWin( datetime time ) {
   if( time < Time[0]-60*60*24*20 ) {
      winCntMonth++;
   }
   return true;
}

int GetMonthWin() {
   return winCntMonth;
}

// 小数点を1桁に切る
double dt1( double val ) {
   return( StrToDouble( ( DoubleToStr( val,1 ) ) ) );
}

// 小数点を2桁に切る
double dt2( double val ) {
   return( StrToDouble( ( DoubleToStr( val,2 ) ) ) );
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
//+------------------------------------------------------------------+
