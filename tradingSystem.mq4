//+------------------------------------------------------------------+
//|                                                tradingSystem.mq4 |
//+------------------------------------------------------------------+
#property strict

#include "type.mqh"

//extern double stoplossInPercent; // Размер стопа в процентах.
double Lot = 1.0;

datetime checkUnique[100]; // Массив, который позволит отсеивать рассмотренные фракталы и не дублировать одни и теже события.
type tEvents[100]; // Массив самих событий.

// Expert initialization function:
int OnInit()
  { 
   // Инициализация массивов в "пустоту":
   for(int i = 0; i < 100; i++)
   {
     checkUnique[i] = 0;    
     tEvents[i].setNULL();
   }
   return(INIT_SUCCEEDED);
  }

// Expert tick function:
void OnTick()
  {   
            // SELL - СЦЕНАРИЙ НА КАЖДЫЙ ТИК:
            bool bFirstFractal = false; 
            for(int i=0; bFirstFractal != true; i++) // SELL СЦЕНАРИЙ:
            {
               double dVar = iFractals(NULL, 0, MODE_UPPER, i);
               if(dVar != 0)
               {
                  bFirstFractal = true;
                  if(Bid > dVar)
                  {
                     double differenceH = High[0] - High[i]; // Высота пробоя от уровня пробоя.
                     double maxLow = Low[i+2];
                     for(int j=i+1; j > i - 2; j--)
                     {       
                        if(Low[j] > maxLow){maxLow = Low[j];}  
                     } 
                     
                     if(/*differenceH >= (High[i] - maxLow) ||*/ Low[1] > High[i])
                     {
                        bool rec = true; // Флаг записи в событие.
                        int k = 0;
                        while(k<100)
                        {
                           if(Time[i] == checkUnique[k]){rec = false; break;}  
                           k++;
                        }k=0;
                        if(rec)
                        {
                           while(checkUnique[k] != 0){k++;} // Пропускаем зарезервированные места.
                           checkUnique[k] = Time[i];
                           double cancelLevel = Low[i];
                           double tempcancelMKB = High[i];
                           double tempForBetween;
                           k = i-1;
                           while(k>=0)
                           {
                              if(Low[k] < cancelLevel){cancelLevel = Low[k];}
                              if(High[k] < tempcancelMKB){tempcancelMKB = High[k];}
                              k--;
                           }k=0;
                           tempForBetween = cancelLevel;
                           cancelLevel = cancelLevel - tempcancelMKB + cancelLevel; // Уровень отмены определен!!!
                           
                           while(tEvents[k].getBusy() == true){k++;}
                           tEvents[k].setDatasfirstevent(true, "SELL", High[i], maxLow, Time[i]);
                           tEvents[k].setBarCrashTime(Time[0]);
                           tEvents[k].setBetweenExstremums(tempForBetween);
                           tEvents[k].setFlag(1);                
                        }  
                     }
                  }
               }
            }
            
            // BUY - СЦЕНАРИЙ НА КАЖДЫЙ ТИК:
            bFirstFractal = false; 
            for(int i=0; bFirstFractal != true; i++) // BUY СЦЕНАРИЙ:
            {
               double dVar = iFractals(NULL, 0, MODE_LOWER, i);
               if(dVar != 0)
               {
                  bFirstFractal = true;
                  if(Bid < dVar)
                  {
                     double differenceH = Low[i] - Low[0]; // Высота пробоя от уровня пробоя.
                     double minHigh = High[i+2];
                     for(int j=i+1; j > i - 2; j--)
                     {       
                        if(High[j] < minHigh){minHigh = High[j];}  
                     } 
                     
                     if(/*differenceH >= (minHigh - Low[i]) ||*/ High[1] < Low[i])
                     {
                        bool rec = true; // Флаг записи в событие.
                        int k = 0;
                        while(k<100)
                        {
                           if(Time[i] == checkUnique[k]){rec = false; break;}  
                           k++;
                        }k=0;
                        if(rec)
                        {
                           while(checkUnique[k] != 0){k++;} // Пропускаем зарезервированные места.
                           checkUnique[k] = Time[i];
                           double cancelLevel = High[i];
                           double tempcancelMKB = Low[i];
                           double tempForBetween;
                           k = i-1;
                           while(k>=0)
                           {
                              if(High[k] > cancelLevel){cancelLevel = High[k];}
                              if(Low[k] > tempcancelMKB){tempcancelMKB = Low[k];}
                              k--;
                           }k=0;
                           tempForBetween = cancelLevel;
                           cancelLevel = cancelLevel + cancelLevel - tempcancelMKB; // Уровень отмены определен!!!
                           
                           while(tEvents[k].getBusy() == true){k++;}
                           tEvents[k].setDatasfirstevent(true, "BUY", Low[i], minHigh, Time[i]);
                           tEvents[k].setBarCrashTime(Time[0]);
                           tEvents[k].setBetweenExstremums(tempForBetween);
                           tEvents[k].setFlag(1);              
                        }  
                     }
                  }
               }
            }
            
            
      // ОБРАБОТКА СОБЫТИЙ ДЛЯ SELL:
      for(int z = 0; z < 100; z++)
      {
         if(tEvents[z].getBusy() == true)
         {
            if(tEvents[z].getFlag() == 1)
            {
               if(tEvents[z].getOrder() == "SELL")
               {
                  int k = 0;
                  double newFractal;
                  while(k<1000)
                  {
                     newFractal = iFractals(NULL, 0, MODE_UPPER, k);
                     if(newFractal != 0)
                     {
                        break;
                     }
                     k++;
                  }
                  
                  if(High[k] != tEvents[z].getLevel() && Bid > High[k])
                  {
                     clean(z);
                     break;
                  }k = 0;

                  if(Bid <= tEvents[z].getLevel() - (10.0/pow(10, Digits)))
                  {
                        // Рассчет стоплосса:
                        int indexTime = 0;
                        while(tEvents[z].getFirstFractalBar() != Time[indexTime]){indexTime++;}
                        double stoploss = High[indexTime];
                        for(int m = indexTime - 1; m >= 0; m--)
                        {
                           if(High[m] > stoploss){stoploss = High[m];}
                        }
                        stoploss += 10.0/pow(10, Digits);
                        // Расчет условного убытка:
                        double diffLoss = stoploss - tEvents[z].getLevel(); 
                        // Рассчет тейк-профита:
                        double dProfit = tEvents[z].getBetweenExstremums();
                        
                        tEvents[z].setDatassecondaryevent(stoploss, dProfit);
                        tEvents[z].setFlag(11);
                  }
               }
            }
            else if(tEvents[z].getFlag() == 11)
            {
               if(tEvents[z].getOrder() == "SELL")
               {
                  if(Bid >= tEvents[z].getLevel())
                  { // ПРОДАЕМ ПО РЫНКУ !!!
                        int Rezult = OrderSend(Symbol(), OP_SELL, Lot, Bid, 2, NormalizeDouble(tEvents[z].getStop(), Digits), NormalizeDouble(tEvents[z].getTarget(), Digits));
                        if(Rezult == -1)
                        {
                           Comment("SELL - операция не прошла !!!");
                        }
                        // ОТМЕНА И ОЧИЩЕНИЕ ФЛАГОВ:
                        clean(z);
                  }
               }    
            }
         }   
      }
      
      // ОБРАБОТКА СОБЫТИЙ ДЛЯ BUY:
      for(int z = 0; z < 100; z++)
      {
         if(tEvents[z].getBusy() == true)
         {
            if(tEvents[z].getFlag() == 1)
            {
               if(tEvents[z].getOrder() == "BUY")
               {
                  int k = 0;
                  double newFractal;
                  while(k<1000)
                  {
                     newFractal = iFractals(NULL, 0, MODE_LOWER, k);
                     if(newFractal != 0) {break;}
                     k++;
                  }
                  if(Low[k] != tEvents[z].getLevel() && Bid < Low[k])
                  {
                     clean(z);
                     break;
                  }

                  if(Bid >= tEvents[z].getLevel() + (10.0/pow(10, Digits)))
                  {
                        // Рассчет стоплосса:
                        int indexTime = 0;
                        while(tEvents[z].getFirstFractalBar() != Time[indexTime]){indexTime++;}
                        double stoploss = Low[indexTime];
                        for(int m = indexTime - 1; m >= 0; m--)
                        {
                           if(Low[m] < stoploss){stoploss = Low[m];}
                        }
                        stoploss -= 10.0/pow(10, Digits);
                        // Расчет условного убытка:
                        double diffLoss = tEvents[z].getLevel() - stoploss; 
                        // Рассчет тейк-профита:
                        double dProfit = tEvents[z].getBetweenExstremums();
                        
                        tEvents[z].setDatassecondaryevent(stoploss, dProfit);
                        tEvents[z].setFlag(11);
                  }
               }   
            }
            else if(tEvents[z].getFlag() == 11)
            {
                 if(tEvents[z].getOrder() == "BUY")
                 {
                     if(Bid <= tEvents[z].getLevel())
                     { // ПОКУПАЕМ ПО РЫНКУ !!!
                           int Rezult = OrderSend(Symbol(), OP_BUY, Lot, Ask, 2, NormalizeDouble(tEvents[z].getStop(), Digits), NormalizeDouble(tEvents[z].getTarget(), Digits));
                           if(Rezult == -1)
                           {
                              Comment("BUY - операция не прошла !!!");
                           }
                           // ОТМЕНА И ОЧИЩЕНИЕ ФЛАГОВ:
                           clean(z);
                     }
                 }
             }
        }
   }
}

void clean(int z)
{
   int k = 0;
   while(k<100)
   {
      if(tEvents[z].getFirstFractalBar() == checkUnique[k]){checkUnique[k] = 0; break;}
      k++;
   }
   tEvents[z].deleteBusy();
}