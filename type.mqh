#ifndef _TYPE_
#define _TYPE_

class type
{
   private:
   
   datetime barCrashTime;
   double betweenExstremums;
   // ------------
   bool busy; // Флаг занятости.
   string order; // BUY or SELL
   double level; // Уровень предполагаемого входа
   double innerLevel; // Внутренний уровень
   double cancelLevel; // Противоположный уровень отмены модели.
   datetime firstFractalBar; // Дата и время пробитого фрактала
   // ------------
   double stop; // Уровень стопа.
   double target; // Уровень профит.
   
   int flag; // Флаг текущего события 1 11 или 111
   
   public:
   
   type();
   ~type();
   void setNULL(void);
   void setBarCrashTime(datetime);
   datetime getBarCrashTime(void);
   void setBetweenExstremums(double);
   double getBetweenExstremums(void);
   
   void setDatasfirstevent (bool, string, double, double, datetime);
   void setDatassecondaryevent (double, double);
   void setFlag(int);
   
   void deleteBusy();
   
   bool getBusy();
   string getOrder(); 
   double getLevel();
   double getInnerLevel();
   double getCancelLevel();
   datetime getFirstFractalBar();
   double getStop();
   double getTarget();
   int getFlag();
};

#endif 