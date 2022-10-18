#property copyright "Garbanzos S.A"
#property link      "https://github.com/ms0uto/fantastic-garbanzo"
#property version   "0.01"

input double   StopLoss=0.1;
input double   TakeProfit=1.0;
input double   Lots=1.0;
input datetime StartTime=D'2022.10.18 12:46:49'; // TODO Use double or enum for 24hr value
input datetime FinishTime=D'2022.10.18 12:47:03';
input int      RsiPeriod=14;
input int      RsiTopLevel=80;
input int      RsiBottomLevel=20;
input double   TakeProfit=1.0;
input double   DailyLoss=0.5;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   
  }

void OnTimer()
  {
   
  }

void OnTrade()
  {
   
  }

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
   // Skip for now.
  }

