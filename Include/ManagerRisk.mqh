//+------------------------------------------------------------------+
//|                                                 ManagerMoney.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>

//-- Classe base para implementação de novas classe de Gerenciamento de Risco
class ManagerRisk
  {
private:
   double            m_lots;
   double            m_maximum_loss_day;
   double            m_maximum_profit_day;
   int               m_maximum_inputs;

   double            dayProfit;
   double            dayLoss;
   double            dayHistProfit;
   int               dayQtPos;

public:
                     ManagerRisk();

   //-- funções para injetar valores dentro da classe/objeto
   void              SetLots(double value)                 {  m_lots = value; }
   void              SetMaximumInputs(int value)           {  m_maximum_inputs = value; }
   void              SetMaximumLoss(double value)          {  m_maximum_loss_day = value; }
   void              SetMaximumProfit(double value)        {  m_maximum_profit_day = value; }

   //-- funções virtuais para serem implementadas pela nova classe de gerenciamento de risco
   virtual double    Lots()                                {  return m_lots; }
   virtual bool      CheckClose(CPositionInfo *position);

   //-- funções auxiliares
   bool              CheckLimits(bool &max_profit, bool &max_loss, bool &max_inputs);
   void              ResetLimits() {dayHistProfit = dayLoss = dayProfit = dayQtPos = 0;};
protected:
   void              Test();

private:
   void              BalanceDay();
  };
//-- Construtor
ManagerRisk::ManagerRisk()
  {
   m_lots = 0;
   m_maximum_loss_day = 0;
   m_maximum_profit_day = 0;
   m_maximum_inputs = 0;
   dayHistProfit = 0;
  }
//-- Check se é necessário o fechamento da posição
bool ManagerRisk::CheckClose(CPositionInfo *position)
  {
   return(false);

//-- dependente; em testes na demo o bicho acabou abrindo uma posição e fechando
//-- logo após ter sido fechada no stop, ou seja, bug
   if(position.StopLoss() > 0)
      return(false);

   if(m_maximum_loss_day > 0)
     {
      double dayLimit = dayHistProfit+position.Profit();
      if((0-m_maximum_loss_day)>=dayLimit)
         return(true);
     }
   return(false);
  }
//-- Check os limites definidos
bool ManagerRisk::CheckLimits(bool &max_profit, bool &max_loss, bool &max_inputs)
  {
   BalanceDay();

   if(m_maximum_loss_day > 0 && (0-m_maximum_loss_day)>=dayHistProfit)
      max_loss = true;
   if(m_maximum_profit_day > 0 && dayHistProfit >= m_maximum_profit_day)
      max_profit = true;
   if(m_maximum_inputs > 0 && dayQtPos >= m_maximum_inputs)
      max_inputs = true;

   return (max_loss || max_profit || max_inputs);
  }
//-- Check o histórico para levantar informações de Take Profit, Stop Loss, Quantidade de entradas e outros
void ManagerRisk::BalanceDay()
  {
   datetime todayStart=StringToTime(TimeToString(TimeCurrent(),TIME_DATE));
   dayLoss = 0;
   dayProfit=0;
   dayQtPos=0;
   dayHistProfit=0;
   long  old_pos_id=0;

   if(HistorySelect(todayStart,INT_MAX))
     {
      for(int hd=0; hd<HistoryDealsTotal(); hd++)
        {
         ulong histDealInTicket=HistoryDealGetTicket(hd);
         long  dealType=(ENUM_DEAL_TYPE) HistoryDealGetInteger(histDealInTicket,DEAL_TYPE);
         datetime dealtime   = (datetime) HistoryDealGetInteger(histDealInTicket, DEAL_TIME);
         double   dealProfit = HistoryDealGetDouble(histDealInTicket, DEAL_PROFIT);
         long  dealEntry;
         long  dealIdPos=0;

         switch((ENUM_DEAL_TYPE) dealType)
           {
            case DEAL_TYPE_BUY:
            case DEAL_TYPE_SELL:
               // Operacoes realizadas
               dealEntry=(ENUM_DEAL_ENTRY) HistoryDealGetInteger(histDealInTicket,DEAL_ENTRY);
               dealIdPos=HistoryDealGetInteger(histDealInTicket,DEAL_POSITION_ID);

               if(dealIdPos!=old_pos_id)
                 {
                  dayQtPos++;
                  old_pos_id=dealIdPos;
                 }

               if((dealEntry==DEAL_ENTRY_OUT) || (dealEntry==DEAL_ENTRY_INOUT) || (dealEntry==DEAL_ENTRY_OUT_BY))
                 {
                  dayHistProfit += dealProfit;

                  if(dealProfit > 0)
                     dayProfit+=dealProfit;
                  if(dealProfit < 0)
                     dayLoss+=dealProfit;
                 }
               break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
