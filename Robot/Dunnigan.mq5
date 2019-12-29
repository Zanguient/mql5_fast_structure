//+------------------------------------------------------------------+
//|                                                     Dunnigan.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <..\Experts\NewRobot\Include\ManagerExpert.mqh>
#include <..\Experts\NewRobot\Include\ManagerTrailing.mqh>
#include <..\Experts\NewRobot\Include\ManagerSignal.mqh>
#include <..\Experts\NewRobot\Include\ManagerRisk.mqh>

#include <..\Experts\NewRobot\Include\Signal\SignalDunnigan.mqh>
#include <..\Experts\NewRobot\Include\Trailing\TrailingNone.mqh>

ManagerExpert *manager;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
  ChartSetInteger(0, CHART_SHOW_GRID, false); // false to remove grid
  
   manager = new ManagerExpert;
   manager.Init(PERIOD_M1, 123456);
   manager.SetExpiration(1);
   manager.SetHoursLimits("09:05", "17:00", "17:30");

//-- entradas parciais
   manager.SetInputPartial1(2, 100);
   manager.SetInputPartial2(2, 150);
   manager.SetInputPartial3(2, 200);

//-- saídas parciais
   manager.SetOutputPartial1(1, 100);
   manager.SetOutputPartial2(1, 150);
   manager.SetOutputPartial3(1, 200);

//-- break even
   manager.SetBreakEven1(250, 5);
   manager.SetBreakEven2(300, 50);
   manager.SetBreakEven3(350, 100);

//-- sinal de negociação
   SignalDunnigan *signal = new SignalDunnigan;
   signal.SetNumberBars(3);
   signal.SetPriceLevel(5);
   signal.SetStopLoss(300);
   signal.SetTakeProfit(500);
   manager.InitSignal(signal);

//-- trailing stop
   ManagerTrailing *trailing = new ManagerTrailing;
   manager.InitTrailing(trailing);

//-- gerenciamento de risco
   ManagerRisk *risk = new ManagerRisk;
   risk.SetLots(2);
   risk.SetMaximumInputs(10);
   risk.SetMaximumLoss(10000);
   risk.SetMaximumProfit(10000);
   manager.InitRisk(risk);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   manager.Execute();
  }
//+------------------------------------------------------------------+
