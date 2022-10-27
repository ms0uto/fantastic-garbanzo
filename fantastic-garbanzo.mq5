#property copyright "ms0uto"
#property link      "https://github.com/ms0uto/fantastic-garbanzo"
#property version   "1.0"

#include <Trade\Trade.mqh>
CTrade         trade; 
#include <Trade\AccountInfo.mqh>
CAccountInfo   account;

input double   StopLoss=1.0;
input double   TakeProfit=1.0;
input double   Lots=0.2;
input int      RsiPeriod=14;
input int      RsiTopLevel=80;
input int      RsiBottomLevel=20;
input double   MaxDailyDrawdown=2.0;
input int      MaxSlippage=10;
input int      MaxOpenPositions=1;

// rsi handler
int rsi_handler;
// rsi array
double rsi[];
// init candle tracking
int prev_num_candles = 0;
// init tracking for maximum daily drawdown
datetime newday;
MqlDateTime dt;
// init max allowed equity
double allowed_equity;
// control flag
bool dailyDrawDownReached;

// TODO Use double or enum for 24hr value (to limit EA operating times)
// input datetime StartTime= 
// input datetime FinishTime=

int OnInit() {

   Print("Starting fantastic-garbanzo EA on server ", account.Server());
   Print("Balance=", account.Balance()," Profit=", account.Profit()," Equity=", account.Equity());   
   Print("Point value=", PointValue());
   
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

   TimeToStruct(iTime(_Symbol, _Period, 0), dt);
   int current_day = dt.day;
   TimeToStruct(newday, dt);
   int new_day = dt.day;
   
   // Check for next day to set daily drawdawn. (inits first day)
   if(current_day != new_day) {
      newday = iTime(_Symbol, _Period, 0);
      allowed_equity = NormalizeDouble(account.Equity() - (account.Equity() * MaxDailyDrawdown/100), 1);
      Print("Equity=", account.Equity(), " MaxDailyDrawdown=", MaxDailyDrawdown, "% (minimum equity=", allowed_equity,")");
      dailyDrawDownReached = false;
   }
   
   // Close all positions as soon as account equity < allowed equity
   if(account.Equity() <= allowed_equity && !dailyDrawDownReached){
      dailyDrawDownReached = true;
      Print("Closing positions on ", _Symbol, " current equity=", account.Equity(), " minimum equity=", allowed_equity);
      for(int i=0; i < PositionsTotal(); i++) { 
         trade.PositionClose(PositionGetTicket(i));
      }
   }
   
   CopyBuffer(rsi_handler, 0, 1, 3, rsi);
   
   int num_candles = Bars(_Symbol, _Period);
   
   if(num_candles > prev_num_candles && !dailyDrawDownReached) {
   
      if(rsi[0] > RsiBottomLevel && rsi[1] <= RsiBottomLevel && PositionsTotal() < MaxOpenPositions) {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK); // For long position.
         double sl = ask - (CalculateStopLossPoints() * _Point);
         double tp = ask + (CalculateTakeProfitPoints() * _Point);
         trade.Buy(Lots, _Symbol, ask, sl, tp, NULL);
      }
      
      if(rsi[0] < RsiTopLevel && rsi[1] >= RsiTopLevel && PositionsTotal() < MaxOpenPositions) {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID); // For short position.   
         double sl = bid + CalculateStopLossPoints() * _Point;
         double tp = bid - CalculateTakeProfitPoints() * _Point;
         trade.Sell(Lots, _Symbol, bid, sl, tp, NULL);
      }
      prev_num_candles = num_candles;
   }
}

double CalculateStopLossPoints() {
   // Calculate risk from SL% in amount of base currency.
   double riskAmount = (StopLoss/100) * account.Equity();
   // Calculate stop loss points
   double stopLossPoints = NormalizeDouble(riskAmount/(PointValue() * Lots),1);
   Print("SL points=", stopLossPoints);
   return (stopLossPoints);
}

double CalculateTakeProfitPoints() {
   // Calculate profit from TP% in amount of base currency.
   double profitAmount = (TakeProfit/100) * account.Equity();
   // Calculate take profit points
   double takeProfitPoints = NormalizeDouble(profitAmount/(PointValue() * Lots),1);
   Print("TP points=", takeProfitPoints);
   return (takeProfitPoints);
}

// Calculate the value in base currency of 1 point move in price with 1 lot.
double PointValue() {
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ticksPerPoint = tickSize/_Point;
   double pointValue = tickValue/ticksPerPoint;
   return (pointValue);
}

void OnTimer() {}

void OnTrade() {}