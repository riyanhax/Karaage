#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern int Magic = 37654321;
extern double Lots = 0.01;
extern bool Entry1 = false;
extern bool Entry2 = true;
extern bool OnlyWin = false;
extern double StopLossPips = 10.0;
extern int SkipSec = 60;
extern int Period = 5;
extern string ActiveHoursStr = "8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,0,1,2,3,4,5";
extern double RsiL = 10;
extern double RsiU = 90;
extern bool CciLimit = true;
extern int CciPosition = 1;
extern bool Envelopes = true;
extern int EnvelopesTerm = 3;
extern double EnvelopesDeviation = 0.05;
extern bool EnvelopesOutSigma3 = false;
extern bool EnvelopesOutSigma2 = false;
extern bool EnvelopesInSigma2 = false;
extern bool CkSpeed_trend = false;
extern bool CkSpeed_correction = false;
extern bool CkSpeed_sleep = false;
extern double MinSigma = 2.0;
extern double MinLength = 0.0;
extern bool Deeply = true;
extern bool Reverse = false;
extern string LogName = "SigmaHighLow1";
extern string LogHeader = "SIGMA_HIGH_LOW";
extern string StopListUrl = "http://s3-us-west-2.amazonaws.com/studiogadget-fx/green_soybeans/stop_list_dummy.txt";
// 121115001559,121116301429,   MMddHHmmHHmm, ※カンマで終わること、TimeCurrentで指定

datetime lastEntry1 = 0;
datetime lastEntry2 = 0;
int executedDayOfYear = 999;
datetime stopStart[1] = {0};
datetime stopEnd[1] = {0};
bool offFlg = false;
int diffHour;
int handle;
double lastSigma = 99.9;
string activeHoursStr[];
int activeHours[];
double pipsRate;

int init() {
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   handle = FileOpen( LogName+"_"+Symbol()+"_"+Period+".log", FILE_SHARE_READ|FILE_WRITE );
   if(handle < 0) {
      Alert("Output File Open Error!!");
      return(-1);
   } else {
      Print( "File Open.["+LogName+"_"+Symbol()+".log"+"]" );
   }

   // 実行時間帯
   StringSplit( ActiveHoursStr, StringGetCharacter( ",", 0 ), activeHoursStr );
   ArrayResize( activeHours, ArraySize( activeHoursStr ) );
   for( int idx=0; idx<ArraySize( activeHoursStr ); idx++ ) {
      Print( "ActiveHour: "+activeHoursStr[idx] );
      activeHours[idx] = StrToInteger( activeHoursStr[idx] );
   }

   Print( "SkipSec: "+SkipSec );
   Print( "ActiveHoursStr: "+ActiveHoursStr );
   Print( "RsiL: "+RsiL );
   Print( "RsiU: "+RsiU );
   Print( "CciLimit: "+CciLimit );
   Print( "Envelopes: "+Envelopes );
   Print( "EnvelopesOutSigma3: "+EnvelopesOutSigma3 );
   Print( "EnvelopesOutSigma2: "+EnvelopesOutSigma2 );
   Print( "EnvelopesInSigma2: "+EnvelopesInSigma2 );
   Print( "CkSpeed_trend: "+CkSpeed_trend );
   Print( "CkSpeed_correction: "+CkSpeed_correction );
   Print( "CkSpeed_sleep: "+CkSpeed_sleep );
   Print( "MinSigma: "+MinSigma );
   Print( "LogName: "+LogName );
   Print( "LogHeader: "+LogHeader );
   Print( "StopListUrl: "+StopListUrl );

   return(0);
}

int start() {
   int dayOfYear = DayOfYear();
   string stopList;
   int length;
   int i;
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
   double ma0;
   double ma1;
   string ema;
   int currentHour;
   bool active;
   double trend;
   double correction;
   double sleep;
   double envelopesUp;
   double envelopesDown;
   double lengthD;
   bool deeplyHigh;
   bool deeplyLow;
   int ticket;

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

   // 経済指標時間帯は停止
   now = TimeCurrent();
   for( i=0; i < ArraySize( stopStart )-1; i++ ){
      if( stopStart[i] <= now && now < stopEnd[i] ) {
         if( !offFlg ) {
            FileWrite( handle, LogHeader+" ALL RELEASE"+" Time:"+TimeToStr( TimeLocal(), TIME_DATE|TIME_SECONDS ) );
            FileFlush( handle );
            offFlg = true;
         }
         return(0);
      }
   }
   offFlg = false;

   // 指定時間のみ実行
   currentHour = TimeHour( TimeLocal() );
   active = false;
   for( i=0; i<ArraySize( activeHours ); i++ ) {
      if( activeHours[i] == currentHour ) {
         active = true;
         break;
      }
   }
   if( !active ) {
      return(0);
   }

   // 1つ前の足をチェック
   if( lastEntry1 != Time[0] && Entry1 ) {
      lastEntry1 = Time[0];

      price = Close[1];
      lengthD = MathAbs( Open[1]-Close[1] )/pipsRate;
      // σ値(絶対値)算出
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

      rsi = iRSI( Symbol(), PERIOD_CURRENT, 8, PRICE_CLOSE, 1 );
      if( CciLimit ) {
         cci = iCustom( Symbol(), PERIOD_CURRENT, "CCI", 14, 0, CciPosition+1 );
      }

      ma0 = iMA( Symbol(), PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 1 );
      ma1 = iMA( Symbol(), PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 2 );
      ema = DoubleToStr( sigma20U, 5 )+"%%"+DoubleToStr( sigma20L, 5 )+"%%"+DoubleToStr( ma0-ma1, 10 )+"%%"+DoubleToStr( rsi, 3 );
      if( CkSpeed_trend ) {
         trend = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 0, 1 );
      }
      if( CkSpeed_correction ) {
         correction = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 1, 1 );
      }
      if( CkSpeed_sleep ) {
         sleep = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 2, 1 );
      }
      if( Envelopes ) {
         envelopesUp = iEnvelopes( Symbol(), PERIOD_CURRENT, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_UPPER, 1 );
         envelopesDown = iEnvelopes( Symbol(), PERIOD_CURRENT, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_LOWER, 1 );
      }
      if( Deeply ) {
         deeplyHigh = false;
         deeplyLow = false;
         if( iOpen( Symbol(), PERIOD_M1, 1 ) >= iOpen( Symbol(), PERIOD_M1, 0 ) ) {
            deeplyHigh = true;
         }
         if( iOpen( Symbol(), PERIOD_M1, 1 ) <= iOpen( Symbol(), PERIOD_M1, 0 ) ) {
            deeplyLow = true;
         }
      }

      // Long
      if( price > sigma00 && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci >= 100.0 ) && ( !CkSpeed_trend || ( trend > 0 || correction > 0 || sleep > 0 ) ) && ( !CkSpeed_correction || ( correction > 0 || sleep > 0 ) ) && ( !CkSpeed_sleep || sleep > 0 ) && ( !Envelopes || price >= envelopesUp ) && ( !EnvelopesOutSigma3 || envelopesUp >= sigma30U ) && ( !EnvelopesOutSigma2 || envelopesUp >= sigma20U ) && ( !EnvelopesInSigma2 || envelopesUp <= sigma20U )  && lengthD >= MinLength && ( !Deeply || deeplyLow ) ) {
         ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, Ask-StopLossPips*pipsRate, 0, "", Magic, 0, Red);

      }
      // Short
      if( price < sigma00 && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci <= -100.0 ) && ( !CkSpeed_trend || ( trend > 0 || correction > 0 || sleep > 0 ) ) && ( !CkSpeed_correction || ( correction > 0 || sleep > 0 ) ) && ( !CkSpeed_sleep || sleep > 0 ) && ( !Envelopes || price <= envelopesDown ) && ( !EnvelopesOutSigma3 || envelopesDown <= sigma30L ) && ( !EnvelopesOutSigma2 || envelopesDown <= sigma20L ) && ( !EnvelopesInSigma2 || envelopesDown >= sigma20L ) && lengthD >= MinLength && ( !Deeply || deeplyHigh ) ) {
         ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, Bid+StopLossPips*pipsRate, 0, "", Magic, 0, Blue);
      }

   }

   // 2つ前の足をチェック
   if( lastEntry2 != Time[0] && Entry2 ) {
      lastEntry2 = Time[0];

      price = Close[2];
      lengthD = MathAbs( Open[2]-Close[2] )/pipsRate;
      // σ値(絶対値)算出
      sigma00 = iBands( Symbol(), PERIOD_CURRENT, 20, 0, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma05U = iBands( Symbol(), PERIOD_CURRENT, 20, 0.5, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma05L  = iBands( Symbol(), PERIOD_CURRENT, 20, 0.5, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma10U = iBands( Symbol(), PERIOD_CURRENT, 20, 1.0, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma10L  = iBands( Symbol(), PERIOD_CURRENT, 20, 1.0, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma15U = iBands( Symbol(), PERIOD_CURRENT, 20, 1.5, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma15L  = iBands( Symbol(), PERIOD_CURRENT, 20, 1.5, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma20U = iBands( Symbol(), PERIOD_CURRENT, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma20L  = iBands( Symbol(), PERIOD_CURRENT, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma25U = iBands( Symbol(), PERIOD_CURRENT, 20, 2.5, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma25L  = iBands( Symbol(), PERIOD_CURRENT, 20, 2.5, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma30U = iBands( Symbol(), PERIOD_CURRENT, 20, 3.0, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma30L  = iBands( Symbol(), PERIOD_CURRENT, 20, 3.0, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma35U = iBands( Symbol(), PERIOD_CURRENT, 20, 3.5, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma35L  = iBands( Symbol(), PERIOD_CURRENT, 20, 3.5, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma40U = iBands( Symbol(), PERIOD_CURRENT, 20, 4.0, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma40L  = iBands( Symbol(), PERIOD_CURRENT, 20, 4.0, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma45U = iBands( Symbol(), PERIOD_CURRENT, 20, 4.5, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma45L  = iBands( Symbol(), PERIOD_CURRENT, 20, 4.5, 0, PRICE_CLOSE, MODE_LOWER, 2 );
      sigma50U = iBands( Symbol(), PERIOD_CURRENT, 20, 5.0, 0, PRICE_CLOSE, MODE_UPPER, 2 );
      sigma50L  = iBands( Symbol(), PERIOD_CURRENT, 20, 5.0, 0, PRICE_CLOSE, MODE_LOWER, 2 );

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

      rsi = iRSI( Symbol(), PERIOD_CURRENT, 8, PRICE_CLOSE, 2 );
      if( CciLimit ) {
         cci = iCustom( Symbol(), PERIOD_CURRENT, "CCI", 14, 0, CciPosition+2 );
      }

      ma0 = iMA( Symbol(), PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 2 );
      ma1 = iMA( Symbol(), PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 3 );
      ema = DoubleToStr( sigma20U, 5 )+"%%"+DoubleToStr( sigma20L, 5 )+"%%"+DoubleToStr( ma0-ma1, 10 )+"%%"+DoubleToStr( rsi, 3 );
      if( CkSpeed_trend ) {
         trend = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 0, 2 );
      }
      if( CkSpeed_correction ) {
         correction = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 1, 2 );
      }
      if( CkSpeed_sleep ) {
         sleep = iCustom( Symbol(), PERIOD_CURRENT, "CK_Speed", 20, 50.0, 2, 2 );
      }
      if( Envelopes ) {
         envelopesUp = iEnvelopes( Symbol(), PERIOD_CURRENT, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_UPPER, 2 );
         envelopesDown = iEnvelopes( Symbol(), PERIOD_CURRENT, EnvelopesTerm, MODE_SMMA, 0, PRICE_CLOSE, EnvelopesDeviation, MODE_LOWER, 2 );
      }
      if( Deeply ) {
         deeplyHigh = false;
         deeplyLow = false;
         if( iOpen( Symbol(), PERIOD_M1, 2 ) >= iOpen( Symbol(), PERIOD_M1, 1 ) ) {
            deeplyHigh = true;
         }
         if( iOpen( Symbol(), PERIOD_M1, 2 ) <= iOpen( Symbol(), PERIOD_M1, 1 ) ) {
            deeplyLow = true;
         }
      }

      // Long
      if( price > sigma00 && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci >= 100.0 ) && ( !CkSpeed_trend || ( trend > 0 || correction > 0 || sleep > 0 ) ) && ( !CkSpeed_correction || ( correction > 0 || sleep > 0 ) ) && ( !CkSpeed_sleep || sleep > 0 ) && ( !Envelopes || price >= envelopesUp ) && ( !EnvelopesOutSigma3 || envelopesUp >= sigma30U ) && ( !EnvelopesOutSigma2 || envelopesUp >= sigma20U ) && ( !EnvelopesInSigma2 || envelopesUp <= sigma20U )  && lengthD >= MinLength && ( !Deeply || deeplyLow ) ) {
         if( !OnlyWin || Open[1] > Close[1] ) {
            ticket = OrderSend( Symbol(), OP_BUY, Lots, Ask, 3, Ask-StopLossPips*pipsRate, 0, "", Magic, 0, Red);
         }
      }
      // Short
      if( price < sigma00 && sigma >= MinSigma && ( rsi <= RsiL || RsiU <= rsi ) && ( !CciLimit || cci <= -100.0 ) && ( !CkSpeed_trend || ( trend > 0 || correction > 0 || sleep > 0 ) ) && ( !CkSpeed_correction || ( correction > 0 || sleep > 0 ) ) && ( !CkSpeed_sleep || sleep > 0 ) && ( !Envelopes || price <= envelopesDown ) && ( !EnvelopesOutSigma3 || envelopesDown <= sigma30L ) && ( !EnvelopesOutSigma2 || envelopesDown <= sigma20L ) && ( !EnvelopesInSigma2 || envelopesDown >= sigma20L ) && lengthD >= MinLength && ( !Deeply || deeplyHigh ) ) {
         if( !OnlyWin || Open[1] < Close[1] ) {
            ticket = OrderSend( Symbol(), OP_SELL, Lots, Bid, 3, Bid+StopLossPips*pipsRate, 0, "", Magic, 0, Blue);
         }
      }

   }

   return(0);
}

int deinit() {
   return(0);
}

// 小数点を1桁に切る
double dt1( double val ) {
   return( StrToDouble( ( DoubleToStr( val,1 ) ) ) );
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
