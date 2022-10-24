#property copyright "ms0uto"
#property link      "https://github.com/ms0uto/fantastic-garbanzo"
#property version   "1.0"

#include <Trade\Trade.mqh>
CTrade         trade; 
#include <Trade\AccountInfo.mqh>
CAccountInfo   account;


input double   StopLoss=0.1;
input double   TakeProfit=1.0;
input double   Lots=1.0;
input int      RsiPeriod=14;
input int      RsiTopLevel=80;
input int      RsiBottomLevel=20;
input double   DailyLoss=0.5;
input int      MaxSlippage=10;

// rsi handler
int rsi_handler;
// rsi array
double rsi[];
// init candle tracking
int prev_num_candles = 0;

// TODO Use double or enum for 24hr value (to limit EA operating times)
// input datetime StartTime= 
// input datetime FinishTime=

int OnInit() {
   // TODO Refactor OnInit into smaller functions
   Print("Starting fantastic-garbanzo EA on server ", account.Server());
   Print("Balance=", account.Balance()," Profit=", account.Profit()," Equity=", account.Equity());
   
   // Allow executing only on demo accounts for now.
   //if(account.TradeMode() == ACCOUNT_TRADE_MODE_REAL) {
   //   Alert("This is not production ready, detected real account, exiting.");
   //   return(INIT_FAILED);
   //  }
   
   // set global MagicNumber to isolate current EA orders.
   trade.SetExpertMagicNumber(1337);
   // set global allowed slippage in points when buying/selling TODO test with different values.
   trade.SetDeviationInPoints(MaxSlippage);
   // TODO needs testing, blocking might be good if we only allow one trade at a time.
   trade.SetAsyncMode(false);
   
   // Init RSI handling
   rsi_handler = iRSI(_Symbol, _Period, RsiPeriod, PRICE_CLOSE);
   ArraySetAsSeries(rsi, true);
   
   return(INIT_SUCCEEDED);
  }

void OnTick() {

   CopyBuffer(rsi_handler, 0, 1, 3, rsi);
   
   int num_candles = Bars(_Symbol, _Period);
   
   if(num_candles > prev_num_candles) {
      if(rsi[0] > RsiBottomLevel && rsi[1] <= RsiBottomLevel && PositionsTotal() < 1) {
         // TODO extract buy function
         // TODO test and profile OrderOpen() VS Buy() for execution time.
         // TODO does including Trade.mqh affect performance, does tree shaking exist on includes? 
         // TODO use % SL and TP from input parameters.
         // TODO move out as much calculations as possible from OnTick().
       
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK); // For long position.
         double sl = ask - 100 * _Point;
         double tp = ask + 100 * _Point;
         
         trade.Buy(Lots, _Symbol, ask, sl, tp, NULL);
         
      }
      
      if(rsi[0] < RsiTopLevel && rsi[1] >= RsiTopLevel && PositionsTotal() < 1) {
   
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID); // For short position.
         double sl = bid + 100 * _Point;
         double tp = bid - 100 * _Point;
         
         trade.Sell(Lots, _Symbol, bid, sl, tp, NULL);
      }
      prev_num_candles = num_candles;
   }
}

void OnTimer() {}

void OnTrade() {}

