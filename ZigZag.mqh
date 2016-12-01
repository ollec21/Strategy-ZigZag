//+------------------------------------------------------------------+
//|                                                       ZigZag.mqh |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#property strict

#include <BasicTrade.mqh>

#define ZZ_BUFFERS  1
#define ZZ_VALUES   3

#define ZZ_NAME_MT4 "ZigZag"
#define ZZ_NAME_MT5 "Examples\\ZigZag"
//+------------------------------------------------------------------+
//|   CMovingTrade                                                   |
//+------------------------------------------------------------------+
class CZigZagTrade : public CBasicTrade
  {
private:
   int               m_handles[TFS];
   string            m_symbol;

   int               m_depth;
   int               m_deviation;
   int               m_backstep;

   double            m_val[ZZ_BUFFERS][TFS][ZZ_VALUES];
   int               m_last_error;

   //+------------------------------------------------------------------+
   bool  Update(const ENUM_TIMEFRAMES _tf=PERIOD_CURRENT)
     {
      int index=TimeframeToIndex(_tf);

#ifdef __MQL4__     
      for(int i=0;i<ZZ_BUFFERS;i++)
         for(int k=0;k<ZZ_VALUES;k++)
            m_val[i][index][k]=iCustom(NULL,
                                       _tf,
                                       ZZ_NAME_MT4,
                                       m_depth,
                                       m_deviation,
                                       m_backstep,
                                       i,
                                       k);
      return(true);
#endif

#ifdef __MQL5__
      double array[];

      if(CopyBuffer(m_handles[index],0,0,ZZ_VALUES,array)!=ZZ_VALUES)
         return(false);

      for(int i=0;i<ZZ_VALUES;i++)
         m_val[0][index][i]=array[ZZ_VALUES-1-i];

      return(true);
#endif

      return(false);
     }
public:

   //+------------------------------------------------------------------+
   void  CZigZagTrade()
     {
      m_symbol=_Symbol;
      m_depth=14;
      m_deviation=3;
      m_backstep=3;
      m_last_error=0;
      ArrayInitialize(m_handles,INVALID_HANDLE);
     }

   //+------------------------------------------------------------------+
   bool  SetParams(const string symbol,
                   const int depth,
                   const int deviation,
                   const int backstep)
     {
      m_symbol=symbol;
      m_depth=fmax(1,depth);
      m_deviation=fmax(1,deviation);
      m_backstep=fmax(1,backstep);

#ifdef __MQL5__
      for(int i=0;i<TFS;i++)
        {
         m_handles[i]=iCustom(m_symbol,
                              tf[i],
                              ZZ_NAME_MT5,
                              m_depth,
                              m_deviation,
                              m_backstep);
         if(m_handles[i]==INVALID_HANDLE)
            return(false);
        }
#endif
      return(true);
     }

   //+------------------------------------------------------------------+
   bool  Signal(const ENUM_TRADE_DIRECTION _cmd,const ENUM_TIMEFRAMES _tf,int _open_method,const int open_level)
     {

      if(!Update(_tf))
         return(false);

      //--- detect 'one of methods'
      bool one_of_methods=false;
      if(_open_method<0)
         one_of_methods=true;
      _open_method=fabs(_open_method);

      //---
      int index=TimeframeToIndex(_tf);
      double level=open_level*_Point;

      //---
      int result[OPEN_METHODS];
      ArrayInitialize(result,-1);

      for(int i=0; i<OPEN_METHODS; i++)
        {
         //---
         if(_cmd==TRADE_BUY)
           {
            switch(_open_method&(int)pow(2,i))
              {
               case OPEN_METHOD1: result[i]=false; break;
               case OPEN_METHOD2: result[i]=false; break;
               case OPEN_METHOD3: result[i]=false; break;
               case OPEN_METHOD4: result[i]=false; break;
               case OPEN_METHOD5: result[i]=false; break;
               case OPEN_METHOD6: result[i]=false; break;
               case OPEN_METHOD7: result[i]=false; break;
               case OPEN_METHOD8: result[i]=false; break;
              }
           }

         //---
         if(_cmd==TRADE_SELL)
           {
            switch(_open_method&(int)pow(2,i))
              {
               case OPEN_METHOD1: result[i]=false; break;
               case OPEN_METHOD2: result[i]=false; break;
               case OPEN_METHOD3: result[i]=false; break;
               case OPEN_METHOD4: result[i]=false; break;
               case OPEN_METHOD5: result[i]=false; break;
               case OPEN_METHOD6: result[i]=false; break;
               case OPEN_METHOD7: result[i]=false; break;
               case OPEN_METHOD8: result[i]=false; break;
              }
           }
        }

      //--- calc result
      bool res_value=false;
      for(int i=0; i<OPEN_METHODS; i++)
        {
         //--- true
         if(result[i]==1)
           {
            res_value=true;

            //--- OR logic
            if(one_of_methods)
               break;
           }
         //--- false
         if(result[i]==0)
           {
            res_value=false;

            //--- AND logic
            if(!one_of_methods)
               break;
           }
        }
      //--- done
      return(res_value);
     }
  };
//+------------------------------------------------------------------+
