#property copyright "Copyright(C) 2016 Studiogadget Inc."

extern bool Diff = true;
extern bool Slope = false;
extern bool SigmaRsi = false;
extern bool Stochastic = false;
extern bool CaseDown = false;
extern double ProfitPips = 10.0;
extern double StopLossPips = 10.0;
extern int SkipSec = 60;
extern double RsiL = 20;
extern double RsiU = 80;
extern int MaxEntry = 1;
extern double MinSigma = 3.0;
extern int Magic = 37654321;

double pipsRate;
datetime lastExeTime = 0;
datetime lastExeFoot = 0;
int caseDown = 0;

int init() {
   pipsRate = Point;
   if( Digits==3 || Digits==5 ) pipsRate = Point * 10;

   return(0);
}

int start() {
   int i;
   double sigma20U;
   double sigma25U;
   double sigma30U;
   double sigma35U;
   double sigma40U;
   double sigma45U;
   double sigma50U;
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
   double ma0;
   double ma1;
   string ema;
   int ticket;
   double diff;
   double slope;
   double lots;
   double stc5;
   double stc14;
   double caseDownBuy = 0.0;
   double caseDownSell = 0.0;
   int allCnt;
   double buyOrder;
   double sellOrder;

   // Check Position
   if( OrdersTotal() > 0){
      for( i=0; i<OrdersTotal(); i++ ){
         if( OrderSelect(i, SELECT_BY_POS) == true && OrderMagicNumber() == Magic ){
            allCnt++;
         }
      }
   }

   // エントリー数制限
   if( allCnt >= MaxEntry ) {
      return(0);
   }

   // 最終実行時間から指定時間以内はスキップ
   if( TimeCurrent() <= lastExeTime+SkipSec+10 ) {
      return(0);
   }
   // 同じ足ではエントリーしない
   if( Time[0] == lastExeFoot ) {
      return(0);
   }

   rsi = iRSI( Symbol(), PERIOD_CURRENT, 8, PRICE_CLOSE, 0 );
   if( rsi >= 99.0 ) {
      rsi = 99.0;
   }
   // RSIが範囲外の場合はスキップ
   if( rsi <= RsiL || RsiU <= rsi ) {
      // 続行
   } else {
      return(0);
   }

   price = Close[0];
   sigma20U = iBands( Symbol(), PERIOD_CURRENT, 20, 2.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   sigma20L  = iBands( Symbol(), PERIOD_CURRENT, 20, 2.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   // 2.0σ未満-2.0σより大きい場合はスキップ
   if( sigma20L < price && price < sigma20U ) {
      return(0);
   }

   // σ値(絶対値)算出
   sigma25U = iBands( Symbol(), PERIOD_CURRENT, 20, 2.5, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   sigma25L  = iBands( Symbol(), PERIOD_CURRENT, 20, 2.5, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   sigma30U = iBands( Symbol(), PERIOD_CURRENT, 20, 3.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   sigma30L  = iBands( Symbol(), PERIOD_CURRENT, 20, 3.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   sigma35U = iBands( Symbol(), PERIOD_CURRENT, 20, 3.5, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   sigma35L  = iBands( Symbol(), PERIOD_CURRENT, 20, 3.5, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   sigma40U = iBands( Symbol(), PERIOD_CURRENT, 20, 4.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   sigma40L  = iBands( Symbol(), PERIOD_CURRENT, 20, 4.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   sigma45U = iBands( Symbol(), PERIOD_CURRENT, 20, 4.5, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   sigma45L  = iBands( Symbol(), PERIOD_CURRENT, 20, 4.5, 0, PRICE_CLOSE, MODE_LOWER, 0 );
   sigma50U = iBands( Symbol(), PERIOD_CURRENT, 20, 5.0, 0, PRICE_CLOSE, MODE_UPPER, 0 );
   sigma50L  = iBands( Symbol(), PERIOD_CURRENT, 20, 5.0, 0, PRICE_CLOSE, MODE_LOWER, 0 );

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
      doubleTemp = ( ( price-sigma30U )/( sigma45U-sigma30U ) )*0.5;
      sigma = dt1( 3.0+doubleTemp );
   } else if( price >= sigma25U ) {
      doubleTemp = ( ( price-sigma25U )/( sigma30U-sigma25U ) )*0.5;
      sigma = dt1( 2.5+doubleTemp );
   } else if( price >= sigma20U ) {
      doubleTemp = ( ( price-sigma20U )/( sigma25U-sigma20U ) )*0.5;
      sigma = dt1( 2.0+doubleTemp );
   } else if( price <= sigma50L ) { // -5.0σ以下は5.0とする
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
   }

   ma0 = iMA( Symbol(), PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 0 );
   ma1 = iMA( Symbol(), PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 1 );
   stc5 = iStochastic( Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
   stc14 = iStochastic( Symbol(), PERIOD_CURRENT, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0 );
   slope = ( ma0-ma1 )/pipsRate;
   diff = ( sigma20U-sigma20L )/pipsRate;
   ema = "";
   buyOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",2,1);
   sellOrder = iCustom(Symbol(),PERIOD_CURRENT,"VGFX",0,0,0,0,0,0,"XRT7-949X-E1S6","5F67-G69W-5929",3,1);

   // ロット設定
   if( Diff ) {
      lots = diff*0.1;
      if( lots < 0.01 ) {
         lots = 0.01;
      }
   } else if( Slope ) {
      if( slope >= 0 ) {
         lots = slope;
      } else if( slope < 0 ) {
         lots = slope*-1;
      }
      if( lots <= 0.01 ) {
         lots = 0.01;
      }
   } else if( SigmaRsi ) {
      lots = ( dt1( sigma-2 ) )*100+rsi*0.1;
      if( lots <= 0.01 ) {
         lots = 0.01;
      }
   } else if( Stochastic ) {
      if( stc5 >= 99 ) {
         lots = dt0( stc14 )+0.99;
      } else if( stc5 <= 1 ) {
         lots = dt0( stc14 )+0.01;
      } else {
         lots = dt0( stc14 )+dt0( stc5 )*0.01;
      }
      if( lots <= 0.01 ) {
         lots = 0.01;
      }
   } else if( CaseDown ) {
      lots = 1.00;
   } else {
      lots = 0.1;
   }

   // Sigmaが指定値以上かつVGFXのサインがでている場合
   if( price >= sigma20U && sigma >= MinSigma && sellOrder != EMPTY_VALUE && sellOrder != 0 ) {
      ticket = OrderSend( Symbol(), OP_SELL, lots, Bid, 3, Bid+StopLossPips*pipsRate, Bid-ProfitPips*pipsRate, ema, Magic, 0, Blue );
      lastExeTime = TimeCurrent();
      lastExeFoot = Time[0];
   }

   // Sigmaが指定値以下かつVGFXのサインがでている場合
   if( price <= sigma20L && sigma >= MinSigma && buyOrder != EMPTY_VALUE && buyOrder != 0 ) {
      ticket = OrderSend( Symbol(), OP_BUY, lots, Ask, 3, Ask-StopLossPips*pipsRate, Ask+ProfitPips*pipsRate, ema, Magic, 0, Red );
      lastExeTime = TimeCurrent();
      lastExeFoot = Time[0];
   }

   return(0);
}

int deinit() {
   return(0);
}

// 小数点を0桁に切る
double dt0( double val ) {
   return( StrToDouble( ( DoubleToStr( val,0 ) ) ) );
}
// 小数点を1桁に切る
double dt1( double val ) {
   return( StrToDouble( ( DoubleToStr( val,1 ) ) ) );
}
// 小数点を2桁に切る
double dt2( double val ) {
   return( StrToDouble( ( DoubleToStr( val,2 ) ) ) );
}
