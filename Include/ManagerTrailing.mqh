//+------------------------------------------------------------------+
//|                                              ManagerTrailing.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>

//-- Classe base para implementações de outras classes para Trailing Stop
//-- de acordo com cada técnica de Trailing
class ManagerTrailing
  {
protected:
   CSymbolInfo       *m_symbol;         // pointer to the object-symbol
public:
   void              Init(ENUM_TIMEFRAMES period, CSymbolInfo *symbol);

   //--
   virtual bool      CheckTrailingStopBuy(CPositionInfo *position,double &sl,double &tp)  { return(false); }
   virtual bool      CheckTrailingStopSell(CPositionInfo *position,double &sl,double &tp) { return(false); }
  };
//-- Inicialização
void ManagerTrailing::Init(ENUM_TIMEFRAMES period,CSymbolInfo *symbol)
  {
   m_symbol = symbol;
  }
//+------------------------------------------------------------------+
