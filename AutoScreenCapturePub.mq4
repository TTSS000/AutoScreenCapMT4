//+------------------------------------------------------------------+
//|                                            AutoScreenCapture.mq4 |
//|                                          Copyright 2022, ttss000 |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, ttss000"
#property link      "https://twitter.com/ttss000"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#import "user32.dll"
int IsIconic(int hWnd);
int GetParent(int hWnd);
int GetAncestor(int,int);
#import

ulong g_ul_SumOrderNum = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
  g_ul_SumOrderNum = 0;
  int orders_total = OrdersTotal();

  for(int order_index = orders_total - 1 ; 0 <= order_index ; order_index--) {
    if(OrderSelect(order_index, SELECT_BY_POS, MODE_TRADES)) {
      g_ul_SumOrderNum += OrderTicket();
    }
  }

//---
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---

  ulong ul_SumOrderNum_tmp = 0;

  int orders_total = OrdersTotal();

  for(int order_index = orders_total - 1 ; 0 <= order_index ; order_index--) {
    if(OrderSelect(order_index, SELECT_BY_POS, MODE_TRADES)) {
      if(OP_BUY == OrderType() ||OP_SELL == OrderType()) {
        ul_SumOrderNum_tmp += OrderTicket();
      }
    }
  }
  if(ul_SumOrderNum_tmp != g_ul_SumOrderNum) {
    Print("g_ul_SumOrderNum, ul_SumOrderNum_tmp="
          +IntegerToString(g_ul_SumOrderNum)+","+IntegerToString(ul_SumOrderNum_tmp));
    if(!bMinimizeOrBack()) {
      takePicture();
    }
    g_ul_SumOrderNum = ul_SumOrderNum_tmp;
  }
//--- return value of prev_calculated for next call
  return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---

}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---

}
//+------------------------------------------------------------------+
void      modify_lot_disp(void)
{

  string obj_name = "";
  obj_name = "SetTpSlPtQckCloseButtonBuy";
  if(0<=ObjectFind(0, obj_name)){
    ObjectSetString(0, obj_name, OBJPROP_TEXT, "---");
  }

  obj_name = "SetTpSlPtQckCloseButtonSell";
  if(0<=ObjectFind(0, obj_name)){
    ObjectSetString(0, obj_name, OBJPROP_TEXT, "---");
  }

  obj_name = "CalcLotFrom2Lines";
  if(0<=ObjectFind(0, obj_name)){
    ObjectSetString(0, obj_name, OBJPROP_TEXT, "---");
  }

}
//+------------------------------------------------------------------+
bool takePicture(string file_name=NULL)
{
  int width = 0;
  int height = 0;
  int subwindow_height = 0;
  int sub_count = 1;
  datetime dtlocal = TimeLocal();

  //デフォルトファイル名 通貨ペア名_時刻.png
  if(file_name == NULL) {
    //file_name  = Symbol() + "_";
    //file_name += IntegerToString(Year());
    //if(Month() < 10) file_name += "0";
    //file_name += IntegerToString(Month());
    //if(Day() < 10) file_name += "0";
    //file_name += IntegerToString(Day());
    //if(Hour() < 10) file_name += "0";
    //file_name += IntegerToString(Hour());
    //if(Minute() < 10) file_name += "0";
    //file_name += IntegerToString(Minute());
    //if(Seconds() < 10) file_name += "0";
    //file_name += IntegerToString(Seconds());
    //file_name += ".png";

    file_name += (IntegerToString(TimeYear(dtlocal))+".");
    if(TimeMonth(dtlocal) < 10) file_name += "0";
    file_name += (IntegerToString(TimeMonth(dtlocal))+".");
    if(TimeDay(dtlocal) < 10) file_name += "0";
    file_name += (IntegerToString(TimeDay(dtlocal))+" ");
    if(TimeHour(dtlocal) < 10) file_name += "0";
    file_name += (IntegerToString(TimeHour(dtlocal))+"-");
    if(TimeMinute(dtlocal) < 10) file_name += "0";
    file_name += (IntegerToString(TimeMinute(dtlocal))+"-");
    if(TimeSeconds(dtlocal) < 10) file_name += "0";
    file_name += (IntegerToString(TimeSeconds(dtlocal))+"JST ");
    file_name += (Symbol()+".png");
  }

  //サブウィンドウの合計高さを取得
  while(true) {
    if(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, sub_count) > 0) {
      subwindow_height += (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, sub_count);
    } else break;
    sub_count++;
  }

  //画像の横幅と高さを設定
  width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0) + 45;
  height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0) + subwindow_height + 20;

  ChartRedraw();
  if(ChartScreenShot(0, file_name, width, height, ALIGN_RIGHT) == false) {
    Print(__FUNCTION__ + " ErrorCode:" + IntegerToString(GetLastError()));
    return(false);
  }

  //PlaySound("news.wav");
  return(true);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool bMinimizeOrBack(void)
{
  bool bRetCode = true;
  if(ChartGetInteger(0,CHART_BRING_TO_TOP)
      && (!IsIconic(GetParent((int)ChartGetInteger(0,CHART_WINDOW_HANDLE))))
      && (!IsIconic(GetAncestor((int)ChartGetInteger(0,CHART_WINDOW_HANDLE),2)))
    ) {
    bRetCode = false;
  }
  return bRetCode;
}
//+------------------------------------------------------------------+
