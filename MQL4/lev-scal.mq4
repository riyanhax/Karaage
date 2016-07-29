
//+------------------------------------------------------------------+
//|                                                    lev-scal .mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2015, "lev-scal
#property link      ""
#property version   "5.2"
#property strict

//------------------------------------------
//---License判断
//------------------------------------------
//---最大持单数量
#define MAX 190
//---测试模式？
bool IsDebug=false;
//---用户自定义？
bool IsCustmize=false;
//---License信息
#define ISSUPERUSER true  //超级用户不检查账户ID和名字
#define ACCOUNTID 0       //不是超级用户，则检查ID  （ID和名字都不符合则包账户不合法）
#define ACCOUNTNAME ""    //不是超级用户，则检查名字（ID和名字都不符合则包账户不合法）
#define YEAR   9999
#define MONTH  12
#define DAY    31
#define XM "Trading Point Of Financial Instruments Ltd"
bool   IsUser=true;//判断用户是否是合法用户，默认合法然后通过不合法的判断基准将其变为不合法
//+------------------------------------------------------------------+

//------------------------------------------
//---Custmize限制：
//---true： 可以在Demo账户中运行,可以是XM以外的外汇公司
//---false：不可以在Demo账户中运行,不可以是XM意外的公司
//------------------------------------------
double UserDefineLots= 0.01;
int UserStopLossPoint=100;
int UserTakeProfitPoint=100;

//------------------------------------------
//---赚取交易量策略参数设置
//------------------------------------------
bool IsP2TEA=false;
double EA_Blance=35.0;
double EA_GtUse20EA=3.0;
double EA_GtUseP2T=5.0;
double EA_P2TLots=0.5;
int EA_HoldTime=300;//EA_HoldTime(second)
//------------------------------------------

//------------------------------------------
//---自动平仓参数设置
//------------------------------------------
//--- input parameters
//指定0以外的时候检查
//input int      EA_MagicNumber=7777;
//指定0以外的时候检查
double   EA_TakeProfit=0.01;
//指定0以外的时候检查
double   EA_Lots=0.01;
//指定0以外的时候检查
double   EA_TakeProfit_2=0.02;
//指定0以外的时候检查
double   EA_Lots_2=0.02;
//指定“”以外的时候检查
string   EA_Symbol=Symbol();

//+------------------------------------------------------------------+
//---买卖区间参数设置 0.01
#define SELL_RANGE_DOWN_PARAM 55
#define SELL_RANGE_UP_PARAM   95
#define BUY_RANGE_UP_PARAM    45
#define BUY_RANGE_DOWN_PARAM   5
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//---买卖区间参数设置0.02
#define SELL_RANGE_DOWN_PARAM_2 79  //0.00075
#define SELL_RANGE_UP_PARAM_2   99  //0.00099
#define BUY_RANGE_UP_PARAM_2    20  //0.00024
#define BUY_RANGE_DOWN_PARAM_2   5  //0.00005
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//---EA外部参数设置
extern int magic=7777;
extern int SellOrBuyControl= 0;//0:Long or Short,1:OnlyLong,2:onlyShort
extern int MyMaxPositions= 100;//MaxPositions(Max:190,Default:150)
                               //extern int MyTradeCountSleep=5;
extern bool IsSetTakeProtite=false;
//extern int MyTradeCountSleepTime=5;
extern bool MyUse10EA = true;
extern bool MyUse20EA = false;
//---如果对应的FX公司不支持下单同时止损止盈则将下面的值设置为true
bool UseOrderModify=false;
bool IsUseTimeUSD=false;//使用USD的双建逻辑？
int EA_Timer=1;//5 minute
int EA_Times=1;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//---交易控制
double MyAccountBalance = 0.0;  //账号余额监视参数
int MyTradeCount = 0;           //为了控制交易频率，监视目前已经下单的个数从而判断EA是否需要休息了
int MySlippage=4;               //注文時のスリッページの指定
int MyOrderTime=0;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//---用来判断是否满足EA的运行条件
double MySpread = 40.0;//このスプレッド以下だったらこのEAを使用可能
double SysSpread = 0.0;//該当通貨ペアのスプレッド
int StopLevel=(int)MarketInfo(Symbol(),MODE_STOPLEVEL);
//bool IsPairControl = true;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//---6个重要的全局变量的声明
double MyAsk = 0;//売り価格
double MyBid = 0;//買い価格
double MyStopLoss=0.0;//損切り価格
double MyTakeProfit=0.0;//利益確定価格
double MyAskRoundDown = 0.0;//売り価格の小数点2桁目以降を切り捨てて
double MyBidRoundDown = 0.0;//買い価格の小数点2桁目以降を切り捨てて
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//---全局变量声明
int OrderResult=0;
bool IsTest=false;// テストの場合にしか出さないメッセージを出すようにコントロールする
bool IsStarted=false;//
//+------------------------------------------------------------------+

//------------------------------------------
//重要的经济指标发表的时候不做交易（目前好像不起作用）
string NoTradingStartDate = "15:20";//日本時間21:20、中国時間20:20
string NoTradingEndDate   = "15:40";//日本時間21:40、中国時間22:40
//------------------------------------------

//+------------------------------------------------------------------+
//|  deinit                                                          |
//+------------------------------------------------------------------+
void deinit()
  {
//---删除屏幕提示
   Comment("");
//--- destroy timer
   EventKillTimer();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
//---License判断
   IsUser=checkAccount(IsDebug,IsCustmize,ACCOUNTID,ACCOUNTNAME,YEAR,MONTH,DAY);
   if(!IsUser)
     {
      Alert("Licence Error!!");
      return INIT_FAILED;
     }

//---如果不是Custmize账户不可以运行在Demo中
   if(IsDemo() && (IsCustmize==false && ISSUPERUSER==false))
     {
      Alert("This version is not custmize version.\n Can not runing in demo account.");
      return INIT_FAILED;
     }

//---资金状况初始化
   MyAccountBalance=AccountBalance();

//---验证止盈和止损参数的设置状况
   if(UserStopLossPoint!=0 && UserStopLossPoint<StopLevel)
     {
      Alert("UserStopLossPoint miss!! \n Please Set UserStopLossPoint > ",StopLevel);
      return INIT_FAILED;
     }
   if(UserTakeProfitPoint!=0 && UserTakeProfitPoint<StopLevel)
     {
      Alert("UserTakeProfitPoint miss!! \n Please Set UserTakeProfitPoint > ",StopLevel);
      return INIT_FAILED;
     }

//---账号持单数量过多
   if(MyMaxPositions>MAX)
     {
      Alert("Error!MyMaxPositions:",MyMaxPositions);
      return INIT_FAILED;
     }

//---账号交易频率过大
/*
   if(MyTradeCountSleep *(60.0/MyTradeCountSleepTime)>120)
     {
      Alert("Error!MyTradeCountSleep:",MyTradeCountSleep,",MyTradeCountSleepTime:",MyTradeCountSleepTime);
      return INIT_FAILED;
     }
*/
//--- create timer
   EventSetTimer(EA_Timer*60);

//---显示屏幕提示
   MyCommont("$10ScalPerPro 5.2",MyMaxPositions);

//---自动平仓参数设置
   if(AccountCurrency()=="JPY")
     {
      if(EA_TakeProfit!=0) EA_TakeProfit=1;
      if(EA_TakeProfit_2!=0) EA_TakeProfit_2=2;
     }

//---返回初始化正常
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  checkAccount                                                    |
//+------------------------------------------------------------------+
bool checkAccount(bool _IsDebug,bool _IsCustmize,int _UserID,string _UserName,int _Year,int _Month,int _Day)
  {
/*
   bool _IsUser=true;
//---如果不是SuperUser则检查名字，否则只检测日期
//---检查用户账户ID是否合法，不合法返回false
   if(ISSUPERUSER!=true)
     {
      if(AccountNumber()!=_UserID && AccountName()!=_UserName)
        {
         if(_IsDebug) Print("AccountID Error!!");
         _IsUser=false;
         return _IsUser;
        }
     }
//---检查使用期限是否合法，不合法返回false
   if(Year()>_Year)
     {
      if(_IsDebug) Print("Licence Error!!");
      _IsUser=false;
      return _IsUser;
     }
   else if(Year()==_Year && Month()>_Month)
     {
      if(_IsDebug) Print("Licence Error!!");
      _IsUser=false;
      return _IsUser;
     }
   else if(Year()==_Year && Month()==_Month && Day()>_Day)
     {
      if(_IsDebug) Print("Licence Error!!");
      _IsUser=false;
      return _IsUser;
     }
   else
     {
      if(_IsDebug) Print("EAOK");
     }
//---如果不是Custmize账户限制指定的XM交易商以外不能用
   if(_IsCustmize==false && AccountCompany()!=XM)
     {
      if(_IsDebug) Print("FX Broker Error!!");
      _IsUser=false;
      return _IsUser;
     }
   return _IsUser;
*/
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  start                                                           |
//+------------------------------------------------------------------+
void start()
  {

   if(!IsTradeAllowed())
     {
      return;
     }
//---如果账户不合法则返回Error
   if(!IsUser)
     {
      if(IsDebug) Print("Licence?!");
      Alert("Licence End !!");
      return;
     }

//---如果是Demo账户，并且不是CustMize账户则返回Error
   if(IsDemo() && (IsCustmize==false && ISSUPERUSER==false))
     {
      if(IsDebug) Print("Account ID error!");
      return;
     }

//---显示屏幕提示
   MyCommont("$10ScalPerPro 5.2",MyMaxPositions);

//---计算系统的点差
   SysSpread=MarketInfo(Symbol(),MODE_SPREAD);

//---毎月の第一金曜日の服务器时间15:20～15:40の間注文しない
   if((DayOfWeek()==5) /* 5：金曜日 */
      && (Day()<=7)
      &&(MathFloor(TimeCurrent()) >= StrToTime(TimeToStr(TimeCurrent(), TIME_DATE) + " " + NoTradingStartDate))
      &&(MathFloor(TimeCurrent()) <= StrToTime(TimeToStr(TimeCurrent(), TIME_DATE) + " " + NoTradingEndDate)))
     {
      if(IsDebug) Print("有重要经济指标发表此期间不交易不给人家服务器添堵");
      return;
     }

//---为了防止周一不必要的损失而在周五自动平仓
//---每周六上午3:00-4:00点（服务器时间应该是周五晚上23:00)，不交易开始自动平仓
   if((DayOfWeek()==5) /* 5：金曜日 */
      && (StrToInteger(DoubleToStr(Hour(),0))>=22))
     {
      CloseAll(Symbol(),magic,10);
      return;
     }

//---防止start()函数同时启动多个这个好像是多余的。。。
   if(IsStarted)
     {
      if(IsDebug) Print("すでに注文処理中であるため、次へ進みません");
      return;
     }
   else
     {
      IsStarted=true;//処理中...

      //---对没有设置止盈止损的订单进行止盈止损设置
      if(UseOrderModify)
        {
         ModifyOrder();
        }

      //---运行EA策略
      if(MyUse10EA)
        {
         D10EA(magic);
        }
      if(MyUse20EA)
        {
         D20EA(magic);
        }

      //---DoTakeProfit
      //---将已经达到目标盈利额度的订单平掉
      if(checkAccount(IsDebug,IsCustmize,ACCOUNTID,ACCOUNTNAME,YEAR,MONTH,DAY))
        {
         if(EA_Lots!=0.0 && EA_TakeProfit!=0.0)
           {
            DoTakeProfit(magic,EA_Lots,EA_Symbol,EA_TakeProfit);
           }
         if(EA_Lots_2!=0.0 && EA_TakeProfit_2!=0.0)
           {
            DoTakeProfit(magic,EA_Lots_2,EA_Symbol,EA_TakeProfit_2);
           }
         //---将持单超过一定时间的刷单订单平掉
         //---如果魔术号码=本EA的号码，手数=刷单订单手数，订单的时间超过刷单的时间则将对应的订单平掉
         if(IsP2TEA)
           {
            CloseOrderByTakeProfiteOrTime(magic,EA_P2TLots,"",0,EA_HoldTime);
           }
        }

      //---运行USD账户相的USDJPYmicro的另外一个双建策略

      //---运行XM的双建策略赚取佣金策略

      //---运行XM的分割策略
      IsStarted=false;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  $10买卖策略买卖信号计算~下单                                     |
//+------------------------------------------------------------------+
void D10EA(int MagicNumber)
  {
//---下单手数计算
   double MyLots=0.01;
   if(IsCustmize)
     {
      MyLots=NormalizeDouble(UserDefineLots,2);//0.01;//この戦略の注文LOTSは0.01とする
     }

//---局部参数初始化
   double MySellRangeDown=0.0;
   double MySellRangeUp=0.0;
   string MyBidString="";
   double MyBuyRangeDown=0.0;
   double MyBuyRangeUp= 0.0;
   string MyAskString = "";

/*
#define SELL_RANGE_DOWN_PARAM 55
#define SELL_RANGE_UP_PARAM   95
#define BUY_RANGE_UP_PARAM    45
#define BUY_RANGE_DOWN_PARAM   5
*/

//---卖出价格范围
//---(XXXJPY Sell 0.055~0.095 )
//---(XXXUSD Sell 0.00055~0.00095 )
   double MySellRangeDownParam=NormalizeDouble(SELL_RANGE_DOWN_PARAM*GetPointPerPrice()*Point,Digits);
   double MySellRangeUpParam=NormalizeDouble(SELL_RANGE_UP_PARAM*GetPointPerPrice()*Point,Digits);

//---买入价格范围
//---(XXXJPY Buy  0.005~0.045 )
//---(XXXUSD Buy  0.00005~0.00045 )
   double MyBuyRangeUpParam=NormalizeDouble(BUY_RANGE_UP_PARAM*GetPointPerPrice()*Point,Digits);
   double MyBuyRangeDownParam=NormalizeDouble(BUY_RANGE_DOWN_PARAM*GetPointPerPrice()*Point,Digits);

//---6个重要的全局变量的初始化
   MyAsk = 0.0;//売り価格初期化
   MyBid = 0.0;//買い価格初期化
   MyStopLoss=0.0;//損切り価格初期化
   MyTakeProfit=0.0;//利益確定価格初期化
   MyAskRoundDown = 0.0;//売り価格の小数点2桁目以降を切り捨てて
   MyBidRoundDown = 0.0;//買い価格の小数点2桁目以降を切り捨てて

//---更新价格
   RefreshRates();

   MyBid=Bid;
   MyAsk=Ask;

//---对计算下单范围时用到的价格的前半部分进行编辑
//---MyBidString=DoubleToStr(MyBid,2);//XXXJPY小数点1桁目が四捨五入されないように
//---MyAskString=DoubleToStr(MyAsk,2);//XXXJPY小数点1桁目が四捨五入されないように
//---MyBidString=DoubleToStr(MyBid,4);//XXXUSD小数点1桁目が四捨五入されないように
//---MyAskString=DoubleToStr(MyAsk,4);//XXXUSD小数点1桁目が四捨五入されないように
   if(Digits%2==0)
     {
      MyBidString=DoubleToStr(MyBid,Digits);//小数点1桁目が四捨五入されないように
      MyAskString=DoubleToStr(MyAsk,Digits);//小数点1桁目が四捨五入されないように
     }
   else
     {
      MyBidString=DoubleToStr(MyBid,Digits - 1);//小数点1桁目が四捨五入されないように
      MyAskString=DoubleToStr(MyAsk,Digits - 1);//小数点1桁目が四捨五入されないように
     }

//---売り注文判断用変数計算
//---Sell   121.050 121.140 121.040
//---Sell   1.21050 1.21140 1.21040
   MyBidRoundDown=StrToDouble(StringSubstr(MyBidString,0,StringLen(MyBidString)-1));//121.050->121.0  1.21050->1.210
   if(IsDebug) Alert("MyBidRoundDown:",MyBidRoundDown);
   MySellRangeDown = MyBidRoundDown + MySellRangeDownParam;//121.0 + 0.050->121.050  1.210 + 0.00050->1.21050
   MySellRangeUp =   MyBidRoundDown + MySellRangeUpParam;  //121.0 + 0.070->121.070  1.210 + 0.00070->1.21070

//---買い注文判断用変数計算
//---Buy       121.040  120.960 121.060
//---Buy       1.21040  1.20960 1.21060
   MyAskRoundDown=StrToDouble(StringSubstr(MyAskString,0,StringLen(MyAskString)-1));//121.029->121.0  1.21029->1.210
   if(IsDebug) Alert("MyAskRoundDown:",MyAskRoundDown);
   MyBuyRangeDown = MyAskRoundDown + MyBuyRangeDownParam;//121.0 + 0.029->121.029  1.210 + 0.00029->1.21029
   MyBuyRangeUp =   MyAskRoundDown + MyBuyRangeUpParam;  //121.0 + 0.049->121.049  1.210 + 0.00049->1.21049

//---[売り価格の小数点2桁目以降を切り捨てて+0.050, 売り価格の小数点2桁目以降を切り捨てて+0.070] 売
//---121.055    ～ 121.075
//---1.21055    ～ 1.21075
   if(MyBid>=MySellRangeDown && MyBid<=MySellRangeUp)
     {
      D10StopLossTakeProfit(OP_SELL,MagicNumber);
      if(SellOrBuyControl==0 || SellOrBuyControl==2)
        {
         SendSellOrder(MyLots,10,MagicNumber);
        }
     }

//--------------------------------------------------------------
//---[買い価格の小数点2桁目以降を切り捨てて+0.029,買い価格の小数点2桁目以降を切り捨てて+0.049] 買
//---121.025    ～ 121.045
//---1.21025    ～ 1.21045
//--------------------------------------------------------------
   if(MyAsk>=MyBuyRangeDown && MyAsk<=MyBuyRangeUp)
     {
      D10StopLossTakeProfit(OP_BUY,MagicNumber);
      if(SellOrBuyControl==0 || SellOrBuyControl==1)
        {
         SendBuyOrder(MyLots,10,MagicNumber);
        }
     }
  }
//+------------------------------------------------------------------+
//|  損切り利益確定価格計算                                            |
//+------------------------------------------------------------------+
void D10StopLossTakeProfit(int MyOrderType,int MagicNumber)
  {
//---计算STOPLEVEL
   double MyStopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*GetPointPerPrice()*Point;

//---止损止盈价格初始化
   MyStopLoss=0.0;
   MyTakeProfit=0.0;

//---XM.com JPY账户 XXXJPYmicro 0.01手 止盈止损 设置（45logic）
   if(AccountCurrency()=="JPY" && AccountCompany()==XM && StringFind(Symbol(),"JPY")!=-1 && UserDefineLots==0.01)
     {
      double MyRiskPrice=0.01;//10Point(1Pips)自分に不利な方向に調整する。目的は指値のスリッページによりプラスになるべきところが0になってしまい、0になるべきところをマイナスになってしまう。
      double MyStopLevelRisk=0.002;//TakeProfit滑るのを防ぐために

      //---更新价格
      RefreshRates();

      //---卖单时的止损和止盈的值的计算
      if(MyOrderType==OP_SELL)
        {
         MyStopLoss=MyBidRoundDown+0.100+(0.050-MyRiskPrice)+0.100;
         MyTakeProfit=MathMin(Ask-MyStopLevel-MyStopLevelRisk,MyBidRoundDown+(0.05-MyRiskPrice));
        }
      //---买单时的止损和止盈的值的计算
      if(MyOrderType==OP_BUY)
        {
         MyStopLoss=MyAskRoundDown-0.100+(0.050+MyRiskPrice)-0.100;
         MyTakeProfit=MathMax(Bid+MyStopLevel+MyStopLevelRisk,MyAskRoundDown+(0.050+MyRiskPrice));
        }
     }

//---XM.com USD账户 USDJPYmicro 0.01手 止盈止损 设置（美金账户中的USDJPYmicro逻辑）
   else if(AccountCurrency()=="USD" && AccountCompany()==XM && StringFind(Symbol(),"USDJPY")!=-1 && UserDefineLots==0.01)
     {
      //---卖单时的止损和止盈的值的计算
      if(MyOrderType==OP_SELL)
        {
         MyStopLoss=NormalizeDouble(Bid+NormalizeDouble(MathMax(MyStopLevel,0.0015*MarketInfo(Symbol(),MODE_BID)-0.021),3),Digits);
         MyTakeProfit=NormalizeDouble(Bid-NormalizeDouble(MathMax(MyStopLevel,0.0005*MarketInfo(Symbol(),MODE_ASK)+0.011),3),Digits);
        }
      //---买单时的止损和止盈的值的计算
      if(MyOrderType==OP_BUY)
        {
         MyStopLoss=NormalizeDouble(Ask-NormalizeDouble(MathMax(MyStopLevel,0.0015*MarketInfo(Symbol(),MODE_BID)-0.021),3),Digits);
         MyTakeProfit=NormalizeDouble(Ask+NormalizeDouble(MathMax(MyStopLevel,0.0005*MarketInfo(Symbol(),MODE_ASK)+0.011),3),Digits);
        }
     }

//---XM.com USD账户 XXXUSDmicro 0.01手 止盈止损 设置（45logic）
   else if(AccountCurrency()=="USD" && AccountCompany()==XM && StringFind(Symbol(),"USD")!=-1 && UserDefineLots==0.01)
     {
      double MyRiskPrice=0.0001;//10Point(1Pips)自分に不利な方向に調整する。目的は指値のスリッページによりプラスになるべきところが0になってしまい、0になるべきところをマイナスになってしまう。
      double MyStopLevelRisk=0.00002;//TakeProfit滑るのを防ぐために

      //---更新价格
      RefreshRates();

      //---卖单时的止损和止盈的值的计算
      if(MyOrderType==OP_SELL)
        {
         MyStopLoss=MyBidRoundDown+0.00230;
         MyTakeProfit=MathMin(Ask-MyStopLevel-MyStopLevelRisk,MyBidRoundDown+(0.0005-MyRiskPrice));
        }
      //---买单时的止损和止盈的值的计算
      if(MyOrderType==OP_BUY)
        {
         MyStopLoss=MyAskRoundDown-0.00100+(0.00050+MyRiskPrice)-0.00090;
         MyTakeProfit=MathMax(Bid+MyStopLevel+MyStopLevelRisk,MyAskRoundDown+(0.00050+MyRiskPrice));
        }
     }

//---XM.com GBP账户 XXXGBPmicro 0.01手 止盈止损 设置（45logic）
   else if(AccountCurrency()=="GBP" && AccountCompany()==XM && StringFind(Symbol(),"GBP")!=-1 && UserDefineLots==0.01)
     {
      double MyRiskPrice=0.0001;//10Point(1Pips)自分に不利な方向に調整する。目的は指値のスリッページによりプラスになるべきところが0になってしまい、0になるべきところをマイナスになってしまう。
      double MyStopLevelRisk=0.00002;//TakeProfit滑るのを防ぐために

      //---更新价格
      RefreshRates();

      //---卖单时的止损和止盈的值的计算
      if(MyOrderType==OP_SELL)
        {
         MyStopLoss=MyBidRoundDown+0.00230;
         MyTakeProfit=MathMin(Ask-MyStopLevel-MyStopLevelRisk,MyBidRoundDown+(0.0005-MyRiskPrice));
        }
      //---买单时的止损和止盈的值的计算
      if(MyOrderType==OP_BUY)
        {
         MyStopLoss=MyAskRoundDown-0.00100+(0.00050+MyRiskPrice)-0.00090;
         MyTakeProfit=MathMax(Bid+MyStopLevel+MyStopLevelRisk,MyAskRoundDown+(0.00050+MyRiskPrice));
        }
     }

//---XM.com之外的任何账户 止盈止损 设置
   else
     {
      //---更新价格
      RefreshRates();

      //---卖单时的止损和止盈的值的计算
      if(MyOrderType==OP_SELL)
        {
         if(UserStopLossPoint!=0)
           {
            MyStopLoss=Bid+UserStopLossPoint*GetPointPerPrice()*Point;
           }
         if(UserTakeProfitPoint!=0)
           {
            MyTakeProfit=Bid-UserTakeProfitPoint*GetPointPerPrice()*Point;
           }
        }

      //---买单时的止损和止盈的值的计算
      if(MyOrderType==OP_BUY)
        {
         if(UserStopLossPoint!=0)
           {
            MyStopLoss=Ask-UserStopLossPoint*GetPointPerPrice()*Point;
           }
         if(UserTakeProfitPoint!=0)
           {
            MyTakeProfit=Ask+UserTakeProfitPoint*GetPointPerPrice()*Point;
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 買い注文
//+------------------------------------------------------------------+
void SendBuyOrder(double MyLots,int Doller,int MagicNumber)
  {

//---如果由于最大下单量或者资金问题不能下单则返回
   if(IsCanNotOrder(MyLots)) return;

//---下买单
   if(IsSetTakeProtite)
     {
      OrderResult=OrderSend(Symbol(),OP_BUY,MyLots,NormalizeDouble(Ask,3),MySlippage,NormalizeDouble(MyStopLoss,3),NormalizeDouble(MyTakeProfit,3),"",MagicNumber,0,CLR_NONE);
     }
   else
     {
      OrderResult=OrderSend(Symbol(),OP_BUY,MyLots,NormalizeDouble(Ask,3),MySlippage,NormalizeDouble(MyStopLoss,3),0,"",MagicNumber,0,CLR_NONE);
     }

//---降低交易频率
//   MySleep();
   Sleep(60000);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 売り注文
//+------------------------------------------------------------------+
void SendSellOrder(double MyLots,int Doller,int MagicNumber)
  {

//---如果由于最大下单量或者资金问题不能下单则返回
   if(IsCanNotOrder(MyLots)) return;//如果由于最大下单量或者资金问题不能下单则返回

//---下卖单
   if(IsSetTakeProtite)
     {
      OrderResult=OrderSend(Symbol(),OP_SELL,MyLots,NormalizeDouble(Bid,3),MySlippage,NormalizeDouble(MyStopLoss,3),NormalizeDouble(MyTakeProfit,3),"",MagicNumber,0,CLR_NONE);
     }
   else
     {
      OrderResult=OrderSend(Symbol(),OP_SELL,MyLots,NormalizeDouble(Bid,3),MySlippage,NormalizeDouble(MyStopLoss,3),0,"",MagicNumber,0,CLR_NONE);
     }

//---降低交易频率
//   MySleep();
   Sleep(60000);
  }
//+------------------------------------------------------------------+
//| IsCanNotOrder
//| true:不可以在下订单了， false：还可以下订单
//+------------------------------------------------------------------+
bool IsCanNotOrder(double MyLots)
  {
//---点差太大不下单
   if(SysSpread>MySpread)
     {
      return true;
     }
//---订单总数在最大订单以上则不下单
   if(MyMaxPositions-OrdersTotal()<=0)
     {
      return true;
     }
//---保证金不足则不下单
   else if(AccountFreeMarginCheck(Symbol(),OP_SELL,MyLots)<=0 || GetLastError()==134)
     {
      return true;
     }
//---上述以外可以下单
   else
     {
      return false;//还可以下单
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 降低交易频率
//| 如果交易数量达到MyTradeCountSleep的值则让程序休息MyTradeCountSleepTime分钟
//+------------------------------------------------------------------+
/*
void MySleep()
  {
   MyTradeCount=MyTradeCount+1;
   if(MyTradeCount==MyTradeCountSleep)
     {
      MyTradeCount=0;

      //---反正接下来EA要休息了，不妨在此在判断一下License是否可以
      IsUser=checkAccount(IsDebug,IsCustmize,ACCOUNTID,ACCOUNTNAME,YEAR,MONTH,DAY);

      //---Sleep的时候也想执行的策略要写在这里，
      //---防止停顿的时候交易不频繁的RSI方法错过下单机会
      for(int i=1; i<=(60000*MyTradeCountSleepTime)/5000; i++)
        {
         Sleep(5000);//停顿5秒
        }
     }
  }
*/
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CountTrades
//+------------------------------------------------------------------+
int CountTrades(string _symbol,int _magic)
  {
   int count=0;
   bool result=false;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      result=OrderSelect(pos,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=_symbol || OrderMagicNumber()!=_magic) continue;
      if(OrderSymbol()==_symbol && OrderMagicNumber()==_magic)
         if(OrderType()==OP_SELL || OrderType()==OP_BUY) count++;
     }
   return (count);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CloseAll
//+------------------------------------------------------------------+
void CloseAll(string _symbol,int _magic,int _slippage)
  {
   bool result=false;
   while(CountTrades(_symbol,_magic)>0)
     {
      for(int pos=OrdersTotal()-1; pos>=0; pos--)
        {
         result=OrderSelect(pos,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==_symbol && OrderMagicNumber()==_magic)
           {
            if(OrderType()==OP_BUY)
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),_slippage,Blue);
              }
            else if(OrderType()==OP_SELL)
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),_slippage,Red);
              }
            else
              {
               result=OrderDelete(OrderTicket(),clrNONE);
              }
           }
         //Sleep(1000);
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| MyCommont
//+------------------------------------------------------------------+
void MyCommont(string eaName,int MaxPositions)
  {
   Comment(
           +eaName
           +"\n"
           +"________________________________"
           +"\n"
           +"Broker:         "+AccountCompany()
           +"\n"
           +"Brokers Time:  "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)
           +"\n"
           +"________________________________"
           +"\n"
           +"Name:                  "+AccountName()
           +"\n"
           +"Account Number:        "+(string)AccountNumber()
           +"\n"
           +"Account Currency:      "+AccountCurrency()
           +"\n"
           +"_______________________________"
           +"\n"
           +"MAX ORDERS:             "+(string)MaxPositions
           +"\n"
           +"OrdersTotal:               "+(string)OrdersTotal()
           +"\n"
           +"MyEA ORDERS:               "+(string)CountTrades(Symbol(),magic)
           +"\n"
           +"_______________________________"
           +"\n"
           +"Account BALANCE:     "+DoubleToStr(AccountBalance(),2)
           +"\n"
           +"Account EQUITY:      "+DoubleToStr(AccountEquity(),2)
           +"\n"
           +"________________________________"
           +"\n");
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| GetPointPerPrice                                                 |
//+------------------------------------------------------------------+
double GetPointPerPrice()
  {
   string _symbol_suffix=Symbol();

   if(StringLen(_symbol_suffix)>6)
      _symbol_suffix=StringSubstr(_symbol_suffix,6);
   else
      _symbol_suffix="";

   int digits_jpy = (int)MarketInfo("USDJPY" + _symbol_suffix, MODE_DIGITS);
   int digits_usd = (int)MarketInfo("EURUSD" + _symbol_suffix, MODE_DIGITS);

   if(digits_jpy==2 || digits_usd==4)
     {
      return 0.1;
     }
   if(digits_jpy==3 || digits_usd==5)
     {
      return 1.0;
     }
   if(digits_jpy==4 || digits_usd==6)
     {
      return 10.0;
     }
   if(digits_jpy==0 && digits_usd==0)
     {
      if(Digits==3 || Digits==5)
        {
         return 1.0;
        }
      return 0.1;
     }
   return 1.0;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ModifyOrder                                                                 |
//+------------------------------------------------------------------+
void ModifyOrder()
  {
   bool result=false;
   double _StopLoss=0.0;
   double _TakeProfit=0.0;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      result=OrderSelect(pos,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         //---更新价格
         RefreshRates();

         //---计算卖单的止盈止损
         if(OrderType()==OP_SELL && OrderStopLoss()==0.0 && UserStopLossPoint>0)
           {
            _StopLoss=Bid+UserStopLossPoint*GetPointPerPrice()*Point;
           }
         if(OrderType()==OP_SELL && OrderTakeProfit()==0.0 && UserTakeProfitPoint>0)
           {
            _TakeProfit=Bid-UserTakeProfitPoint*GetPointPerPrice()*Point;
           }

         //---计算买的止盈止损
         if(OrderType()==OP_BUY && OrderStopLoss()==0.0 && UserStopLossPoint>0)
           {
            _StopLoss=Ask-UserStopLossPoint*GetPointPerPrice()*Point;
           }
         if(OrderType()==OP_BUY && OrderTakeProfit()==0.0 && UserTakeProfitPoint>0)
           {
            _TakeProfit=Ask+UserTakeProfitPoint*GetPointPerPrice()*Point;
           }

         //---根据止盈止损的设置状况修改订单
         //---如果止盈止损都没有被设置则同时更新这两个值
         if(_StopLoss!=0.0 && _TakeProfit!=0.0)
           {
            result=OrderModify(OrderTicket(),OrderOpenPrice(),_StopLoss,_TakeProfit,0,clrNONE);
           }
         //---如果只有止损没有被设置，则更新止损
         else if(_StopLoss!=0.0 && _TakeProfit==0.0)
           {
            result=OrderModify(OrderTicket(),OrderOpenPrice(),_StopLoss,OrderTakeProfit(),0,clrNONE);
           }
         //---如果只有止盈没有被设置，则更新止盈
         else if(_StopLoss==0.0 && _TakeProfit!=0.0)
           {
            result=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),_TakeProfit,0,clrNONE);
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| USD_USDJPYmicroEA
//+------------------------------------------------------------------+
//void USD_USDJPYmicroEA(int times=1,bool IsDebug=false,double MyLots=0.01,int MySlippage=20,int MagicNumber=9999)
void USD_USDJPYmicroEA(int times=1,double MyLots=0.01,int MagicNumber=7777)
  {
//---限制只有在XM的美金账户的USDJPYmicro条件下才可以执行此策略
   if(AccountCompany()==XM && AccountCurrency()=="USD" && Symbol()=="USDJPY")
     {
      //---判断自动交易是否开启
      if(!IsTradeAllowed()) return;

      //---判断License
      if(!IsUser)
        {
         Alert("License End!!");
         return;
        }

      //---判断是否可以交易
      if(IsCanNotOrder(0.01)) return;

      if(OrdersTotal()<=MyMaxPositions -2)
        {
         double _take_profit= NormalizeDouble(0.0005 * MarketInfo("USDJPY",MODE_ASK)+0.011,3);
         double _stop_loss  =  NormalizeDouble(0.0015 * MarketInfo("USDJPY",MODE_BID)-0.011,3);
         if(IsDebug) Print("_take_profit:",NormalizeDouble(_take_profit,3));
         if(IsDebug) Print("_stop_loss:",NormalizeDouble(_stop_loss,3));

         //下买单
         for(int i=0; i<times; i++)
           {
            OrderResult=OrderSend("USDJPY",OP_BUY,MyLots,NormalizeDouble(Ask,Digits),MySlippage,NormalizeDouble(Ask-_stop_loss,Digits),NormalizeDouble(Ask+_take_profit,Digits),"",MagicNumber,0,CLR_NONE);
           }
         //下卖单
         for(int i=0; i<times; i++)
           {
            OrderResult=OrderSend("USDJPY",OP_SELL,MyLots,NormalizeDouble(Bid,Digits),MySlippage,NormalizeDouble(Bid+_stop_loss,Digits),NormalizeDouble(Bid-_take_profit,Digits),"",MagicNumber,0,CLR_NONE);
           }
        }
     }
//---显示屏幕提示
   MyCommont("$10ScalPerPro 5.2",MyMaxPositions);

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(IsUseTimeUSD)
     {
      //---如果账户不合法则返回Error
      if(!IsUser)
        {
         if(IsDebug) Print("Licence?!");
         return;
        }
      //---如果是Demo账户，并且不是CustMize账户则返回Error
      if(IsDemo() && IsCustmize==false)
        {
         if(IsDebug) Print("Account ID error!");
         return;
        }
      //---下双建订单
      if(((DayOfWeek()==5) && (StrToInteger(DoubleToStr(Hour(),0))<=22)) || (DayOfWeek()<=4))
        {
         USD_USDJPYmicroEA(EA_Times,0.01,magic);
         return;
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 课题：Trap分割策略                                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  $20买卖策略买卖信号计算~下单                                     |
//+------------------------------------------------------------------+
void D20EA(int MagicNumber)
  {
//---XM.com USD账户 XXXUSDmicro 0.01手 止盈止损 设置（45logic）
   if(AccountCurrency()=="USD" && AccountCompany()==XM && StringFind(Symbol(),"USD")!=-1)
     {
     }
   else
     {
      return;
     }
//---下单手数计算
   double MyLots=0.02;
   if(IsCustmize)
     {
      MyLots=NormalizeDouble(UserDefineLots,2);//0.02;//この戦略の注文LOTSは0.01とする
     }

//---局部参数初始化
   double MySellRangeDown=0.0;
   double MySellRangeUp=0.0;
   string MyBidString="";
   double MyBuyRangeDown=0.0;
   double MyBuyRangeUp= 0.0;
   string MyAskString = "";

/*
#define SELL_RANGE_DOWN_PARAM_2 79  //0.00075
#define SELL_RANGE_UP_PARAM_2   99  //0.00099
#define BUY_RANGE_UP_PARAM_2    24  //0.00024
#define BUY_RANGE_DOWN_PARAM_2   5  //0.00005
*/

//---卖出价格范围
//---(XXXUSD Sell 0.00075~0.00099 )
   double MySellRangeDownParam=NormalizeDouble(SELL_RANGE_DOWN_PARAM_2*GetPointPerPrice()*Point,Digits);
   double MySellRangeUpParam=NormalizeDouble(SELL_RANGE_UP_PARAM_2*GetPointPerPrice()*Point,Digits);

//---买入价格范围
//---(XXXUSD Buy  0.00005~0.00024 )
   double MyBuyRangeUpParam=NormalizeDouble(BUY_RANGE_UP_PARAM_2*GetPointPerPrice()*Point,Digits);
   double MyBuyRangeDownParam=NormalizeDouble(BUY_RANGE_DOWN_PARAM_2*GetPointPerPrice()*Point,Digits);

//---6个重要的全局变量的初始化
   MyAsk = 0.0;//売り価格初期化
   MyBid = 0.0;//買い価格初期化
   MyStopLoss=0.0;//損切り価格初期化
   MyTakeProfit=0.0;//利益確定価格初期化
   MyAskRoundDown = 0.0;//売り価格の小数点2桁目以降を切り捨てて
   MyBidRoundDown = 0.0;//買い価格の小数点2桁目以降を切り捨てて

//---更新价格
   RefreshRates();

   MyBid=Bid;
   MyAsk=Ask;

//---对计算下单范围时用到的价格的前半部分进行编辑
//---MyBidString=DoubleToStr(MyBid,2);//XXXJPY小数点1桁目が四捨五入されないように
//---MyAskString=DoubleToStr(MyAsk,2);//XXXJPY小数点1桁目が四捨五入されないように
//---MyBidString=DoubleToStr(MyBid,4);//XXXUSD小数点1桁目が四捨五入されないように
//---MyAskString=DoubleToStr(MyAsk,4);//XXXUSD小数点1桁目が四捨五入されないように
   if(Digits%2==0)
     {
      MyBidString=DoubleToStr(MyBid,Digits);//小数点1桁目が四捨五入されないように
      MyAskString=DoubleToStr(MyAsk,Digits);//小数点1桁目が四捨五入されないように
     }
   else
     {
      MyBidString=DoubleToStr(MyBid,Digits - 1);//小数点1桁目が四捨五入されないように
      MyAskString=DoubleToStr(MyAsk,Digits - 1);//小数点1桁目が四捨五入されないように
     }

//---売り注文判断用変数計算
//---Sell   1.13375     1.13399
   MyBidRoundDown=StrToDouble(StringSubstr(MyBidString,0,StringLen(MyBidString)-1));//121.050->121.0  1.21050->1.210
   if(IsDebug) Print(__LINE__,"MyBidRoundDown:",MyBidRoundDown);
   MySellRangeDown = MyBidRoundDown + MySellRangeDownParam;//121.0 + 0.050->121.050  1.210 + 0.00050->1.21050
   MySellRangeUp =   MyBidRoundDown + MySellRangeUpParam;  //121.0 + 0.070->121.070  1.210 + 0.00070->1.21070

//---買い注文判断用変数計算
//---Buy    1.13305     1.13324
   MyAskRoundDown=StrToDouble(StringSubstr(MyAskString,0,StringLen(MyAskString)-1));//121.029->121.0  1.21029->1.210
   if(IsDebug) Print(__LINE__,"MyAskRoundDown:",MyAskRoundDown);
   MyBuyRangeDown = MyAskRoundDown + MyBuyRangeDownParam;//121.0 + 0.029->121.029  1.210 + 0.00029->1.21029
   MyBuyRangeUp =   MyAskRoundDown + MyBuyRangeUpParam;  //121.0 + 0.049->121.049  1.210 + 0.00049->1.21049

//---[売り価格の小数点2桁目以降を切り捨てて+0.050, 売り価格の小数点2桁目以降を切り捨てて+0.070] 売
//---Sell   1.13379     1.13399
   if(IsDebug) Print(__LINE__,"MySellRangeDown:",MySellRangeDown);
   if(IsDebug) Print(__LINE__,"MySellRangeUp:",MySellRangeUp);
   if(IsDebug) Print(__LINE__,"MyBuyRangeDown:",MyBuyRangeDown);
   if(IsDebug) Print(__LINE__,"MyBuyRangeUp:",MyBuyRangeUp);
   if(IsDebug) Print(__LINE__,"MODE_STOPLEVEL:",MarketInfo(Symbol(),MODE_STOPLEVEL));

   if(MyBid>=MySellRangeDown && MyBid<=MySellRangeUp)
     {
      D20StopLossTakeProfit(OP_SELL,MagicNumber);
      if(SellOrBuyControl==0 || SellOrBuyControl==2)
        {
         SendSellOrder(MyLots,10,MagicNumber);
        }
     }

//--------------------------------------------------------------
//---[買い価格の小数点2桁目以降を切り捨てて+0.029,買い価格の小数点2桁目以降を切り捨てて+0.049] 買
//---Buy    1.13305     1.13324
//--------------------------------------------------------------
   if(MyAsk>=MyBuyRangeDown && MyAsk<=MyBuyRangeUp)
     {
      D20StopLossTakeProfit(OP_BUY,MagicNumber);
      if(SellOrBuyControl==0 || SellOrBuyControl==1)
        {
         SendBuyOrder(MyLots,10,MagicNumber);
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  損切り利益確定価格計算                                            |
//+------------------------------------------------------------------+
void D20StopLossTakeProfit(int MyOrderType,int MagicNumber)
  {
//---计算STOPLEVEL
   double MyStopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*GetPointPerPrice()*Point;
//---止损止盈价格初始化
   MyStopLoss=0.0;
   MyTakeProfit=0.0;

//---XM.com USD账户 XXXUSDmicro 0.02手 止盈止损 设置（45logic）
   if(AccountCurrency()=="USD" && AccountCompany()==XM && StringFind(Symbol(),"USD")!=-1)
     {
      double MyRiskPrice=0.0001;//10Point(1Pips)自分に不利な方向に調整する。
      double MyStopLevelRisk=0.00002;//TakeProfit滑るのを防ぐために

      //---卖单时的止损和止盈的值的计算
      if(MyOrderType==OP_SELL)
        {
         MyStopLoss=MathMin(Bid-MyStopLevel-MyStopLevelRisk,MyBidRoundDown+0.00214);
         //MyTakeProfit=MyBidRoundDown+0.00020;
         MyTakeProfit=0.0;

         if(IsDebug) Print(__LINE__,"MyBidRoundDown:",MyBidRoundDown);
         if(IsDebug) Print(__LINE__,"MyStopLoss:",MyStopLoss);
         if(IsDebug) Print(__LINE__,"MyTakeProfit:",MyTakeProfit);
        }
      //---买单时的止损和止盈的值的计算
      if(MyOrderType==OP_BUY)
        {
         MyStopLoss=MyAskRoundDown-0.00120;
         //MyTakeProfit=MathMax(Ask+MyStopLevel+MyStopLevelRisk,MyAskRoundDown+0.00080);
         MyTakeProfit=0.0;

         if(IsDebug) Print(__LINE__,"MyBidRoundDown:",MyBidRoundDown);
         if(IsDebug) Print(__LINE__,"MyStopLoss:",MyStopLoss);
         if(IsDebug) Print(__LINE__,"MyTakeProfit:",MyTakeProfit);
        }
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 盈利平仓策略
//+------------------------------------------------------------------+
void DoTakeProfit(int _EA_MagicNumber,double _EA_Lots,string _EA_Symbol,double _EA_TakeProfit)
  {
   int orderCounts=OrdersTotal();
   bool result=false;

   for(int position=0; position<orderCounts; position++)
     {
      result=OrderSelect(position,SELECT_BY_POS,MODE_TRADES);
      //---如果参数有设置则只平掉参数设置的Magic
      if(_EA_MagicNumber!=0)
        {
         if(OrderMagicNumber()!=_EA_MagicNumber) continue;//不是这个EA下的订单，continue
        }
      //---如果参数有设置则指平掉对应的手数
      if(_EA_Lots!=0)
        {
         if(OrderLots()!=_EA_Lots) continue;//不是0.01手，continue
        }
      //---如果参数有设置则指平掉对应的货币对
      if(_EA_Symbol!="")//USDJPYmicro，EURUSDmicro，AUDUSDmicro,GBPUSDmicro
        {
         if(OrderSymbol()!=_EA_Symbol) continue;//跟图上的货币对儿不同时，continue。
        }
      //---赢利到EA_TakeProfit的时候
      if(_EA_TakeProfit>0.0)
        {
         RefreshRates();
         if(OrderProfit()>=_EA_TakeProfit)
           {
            //---买单时获利平仓处理
            if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,DarkOrange);
              }
            //---卖单时获利平仓处理
            else
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,DarkOrange);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 持单超过一定时间的平仓策略
//+------------------------------------------------------------------+
//---功能1：循环各个订单如果满足指定手数，满足盈利额度则平仓
//---功能2：循环各个订单如果持单时间大于等于time秒时则删除挂单
void CloseOrderByTakeProfiteOrTime(int _EA_MagicNumber,double _EA_Lots,string _EA_Symbol,double _EA_TakeProfit,int _EA_HoldTime)
  {
   int orderCounts=OrdersTotal();
   bool result=false;

   for(int position=0; position<orderCounts; position++)
     {
      result=OrderSelect(position,SELECT_BY_POS,MODE_TRADES);
      //---如果参数有设置则只平掉参数设置的Magic
      if(_EA_MagicNumber!=0)
        {
         if(OrderMagicNumber()!=_EA_MagicNumber) continue;//不是这个EA下的订单，continue
        }
      //---如果参数有设置则指平掉对应的手数
      if(_EA_Lots!=0)
        {
         if(OrderLots()!=_EA_Lots) continue;//不是0.01手，continue
        }
      //---如果参数有设置则指平掉对应的货币对
      if(_EA_Symbol!="")//USDJPYmicro，EURUSDmicro，AUDUSDmicro,GBPUSDmicro
        {
         if(OrderSymbol()!=_EA_Symbol) continue;//跟图上的货币对儿不同时，continue。
        }
      //---赢利到EA_TakeProfit的时候
      if(_EA_TakeProfit>0.0)
        {
         RefreshRates();
         if(OrderProfit()>=_EA_TakeProfit)
           {
            //---买单时获利平仓处理
            if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,DarkOrange);
              }
            //---卖单时获利平仓处理
            else
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,DarkOrange);
              }
           }
        }
      //---当前时间-对应的挂单的开单时间 >= time分钟则删除对应的挂单
      if(_EA_HoldTime!=0 && MathFloor(TimeCurrent())-MathFloor(OrderOpenTime())>=_EA_HoldTime)
        {
         result=OrderDelete(OrderTicket());
        }
     }
  }
//+------------------------------------------------------------------+
