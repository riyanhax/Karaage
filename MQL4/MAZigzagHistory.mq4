#property copyright   "Copyright(C) 2021 Studiogadget Inc."
#property strict
#property show_inputs

void OnStart() {
  string objectId_long = "arrowUp_";
  int idCnt_long = 0;
  string objectId_short = "arrowDown_";
  int idCnt_short = 0;
  string periodText;
  int handle;
  string symbol;
  string period;
  string direction;
  string timeString;
  datetime time;
  datetime objectTime;
  int barShift;

  // パラメータ設定
  if(Period() == 1) {
    periodText = "M1";
  } else if(Period() == 5) {
    periodText = "M5";
  } else if(Period() == 15) {
    periodText = "M15";
  } else if(Period() == 30) {
    periodText = "M30";
  } else if(Period() == 60) {
    periodText = "H1";
  } else if(Period() == 240) {
    periodText = "H4";
  } else if(Period() == 1440) {
    periodText = "D1";
  } else if(Period() == 10080) {
    periodText = "W1";
  } else if(Period() == 43200) {
    periodText = "MN";
  }

  // ファイル読込
  handle = FileOpen("MAZigzag_"+Symbol()+".csv", FILE_CSV|FILE_READ,",");
  while(!FileIsEnding( handle )) {
    // パラメータ取得
    symbol = FileReadString( handle );
    period = FileReadString( handle );
    direction = FileReadString( handle );
    timeString = FileReadString( handle );
    time = FileReadDatetime( handle );
    Print( "[csv] " + symbol + "," + period + "," + direction + "," + timeString + "," + IntegerToString(time) );
    // 通貨ペアと時間足が一致するもののみ
    if(symbol != Symbol()) {
      Print( "Symbol Mismatch.[" + Symbol() + " / " + symbol + "]" );
      continue;
    }
    if(period != periodText) {
      Print( "Period Mismatch.[" + periodText + " / " + period + "]" );
      continue;
    }
    // バーが表示されているもののみ
    objectTime = StringToTime(timeString);
    barShift = iBarShift( Symbol(), PERIOD_CURRENT, objectTime, true );
    Print( "BarShift: " + IntegerToString(barShift) );
    if(barShift == -1) {
      continue;
    }

    // 矢印描写
    if(direction == "long") {
      ObjectCreate( 0, objectId_long + IntegerToString(idCnt_long), OBJ_ARROW_UP, 0, objectTime, Low[barShift] - Point*10*5);
      ObjectSetInteger(0, objectId_long + IntegerToString(idCnt_long), OBJPROP_COLOR, Blue); // 色設定
      ObjectSetInteger(0, objectId_long + IntegerToString(idCnt_long), OBJPROP_WIDTH, 3); // 幅設定
      idCnt_long++;
    } else if(direction == "short") {
      ObjectCreate( 0, objectId_short + IntegerToString(idCnt_short), OBJ_ARROW_DOWN, 0, objectTime, High[barShift] + Point*10*5);
      ObjectSetInteger(0, objectId_short + IntegerToString(idCnt_short), OBJPROP_COLOR, Red); // 色設定
      ObjectSetInteger(0, objectId_short + IntegerToString(idCnt_short), OBJPROP_WIDTH, 3); // 幅設定
      idCnt_short++;
    }
  }

  ChartRedraw(0);
  FileClose(handle);
}
