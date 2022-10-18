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

// TODO Use double or enum for 24hr value (to limit EA operating times)
// input datetime StartTime= 
// input datetime FinishTime=

int OnInit()
  {
   // TODO Refactor OnInit into smaller functions
   Print("Starting fantastic-garbanzo EA on server ", account.Server());
   Print("Balance=", account.Balance()," Profit=", account.Profit()," Equity=", account.Equity());
   // Allow executing only on demo accounts for now.
   if(account.TradeMode() == ACCOUNT_TRADE_MODE_REAL)
     {
      Alert("This is not production ready, detected real account, exiting.");
      return(INIT_FAILED);
     }
   // set global MagicNumber to isolate current EA orders.
   trade.SetExpertMagicNumber(1337);
   // set global allowed slippage in points when buying/selling TODO test with different values.
   trade.SetDeviationInPoints(5);
   // TODO needs testing, blocking might be good if we only allow one trade at a time.
   trade.SetAsyncMode(false);
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   // TODO test and profile OrderOpen() VS Buy() for execution time.
   // TODO does including Trade.mqh affect performance, does tree shaking exist on includes? 
   // TODO use % SL and TP from input parameters.
   // TODO move out as much calculations as possible from OnTick().
   int    digits = (int) SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); // amount of digits (3 as in 1.000)
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);          // point value (1 as in 1.000)
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);              // current price for closing long.
   double sl = bid - 1000 * point;                                  // unnormalized stop loss value.
   sl = NormalizeDouble(sl, digits);                                // normalizing stop loss.
   double tp = bid + 1000 * point;                                  // unnormalized take profit value.
   tp = NormalizeDouble(tp, digits);                                // normalizing take profit.

   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK); // For long position.
   
   // TODO implement candle tracking.
   double rsi = iRSI(_Symbol, _Period, RsiPeriod, PRICE_CLOSE);
   if(rsi <= RsiBottomLevel && OrdersTotal() < 1)
   {
    if(!trade.Buy(Lots, _Symbol, price, sl, tp, ""))
     {
      Print("Buy() method failed. Return code=", trade.ResultRetcode(),
            ". Code description: ", trade.ResultRetcodeDescription());
     }
   else
     {
      Print("Buy() method executed successfully. Return code=", trade.ResultRetcode(),
            " (", trade.ResultRetcodeDescription(),")");
     }  
   }
  }

void OnTimer()
  {
   
  }

void OnTrade()
  {
   
  }

