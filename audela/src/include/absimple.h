///@file absimple.h
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author Michel Pujol
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// @version $Id:  $

#pragma once

//=============================================================================
// export directive and import directive
//=============================================================================
#ifdef WIN32
#if defined(ABSIMPLE_EXPORTS) // inside DLL
#   define ABSIMPLE_API   __declspec(dllexport)
#else // outside DLL
#   define ABSIMPLE_API   __declspec(dllimport)
#endif 

#else 

#if defined(ABSIMPLE_EXPORTS) // inside DLL
#   define ABSIMPLE_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define ABSIMPLE_API 
#endif 

#endif

#include <abcommon2.h>


//=============================================================================
/// \namespace absimple
/// \brief astrobrick tutorial
///
/// absimple : astrobrick tutorial
///===============================
///
/// contains interface examples 
/// - example #1 : standalone fonctions interface absimple_processAdd() , absimple_processSub()
/// - example #2 : class interface ICalculator  with methods using built-in type parameters  to demonstrate how to export a simple class
/// - example #3 : class interface ICalendar  with methods using complex type parameters (structures)
namespace absimple {

   //=============================================================================
   /// example #1 :add two numbers 
   extern "C" ABSIMPLE_API int  absimple_processAdd(int a, int b); 

   /// example #1 : substract two numbers  
   extern "C" ABSIMPLE_API int  absimple_processSub(int a, int b); 

  

   /// callback error type. User program must implement a function with to capture exception. 
   typedef void (* ErrorCallbackType)(int code, const char * message);

   /// get last error code. 
   extern "C" ABSIMPLE_API int absimple_getLastErrorCode ();
   /// get last error message. 
   extern "C" ABSIMPLE_API const char * absimple_getLastErrorMessage ();

   /// release returned string created by absimple functions
   extern "C" ABSIMPLE_API void absimple_releaseCharArray(const char * charArray);




   //=============================================================================
   /// example #2 : ICalculator class convenient declaration for C++ users
   // 1) ICalculator class convenient declaration for C++ users
   class ICalculator  {
      public:
         /// \private default destrutor require by C++ compilator
         virtual ~ICalculator() {};          
         virtual void   Release() = 0;       ///< see ::ICalculator_deleteInstance
         virtual double add(double a)=0;     ///< see ::ICalculator_add
         virtual double sub(double a)=0;     ///< see ::ICalculator_sub 
         virtual double divide(double a)=0;  ///< see ::ICalculator_divide 
         virtual double set(double a)=0;     ///< see ::ICalculator_set 
         virtual double clear()=0;           ///< see ::ICalculator_clear    
         ErrorCallbackType errorCallback;    ///< \private internal error callback
   };

   // 2) ICalculator "C" functions declaration for other langages than C++
   /// Example #2 : create ICalculator instance. Returned ICalculator must be releases with ICalculator_deleteInstance()
   extern "C" ABSIMPLE_API ICalculator*  ICalculator_createInstance(ErrorCallbackType applicationCallback);
   /// Example #2 : release calculator instance 
   extern "C" ABSIMPLE_API void      ICalculator_deleteInstance(ICalculator* );
   /// Example #2 : add a to current value
   extern "C" ABSIMPLE_API double    ICalculator_add(ICalculator*, double a); 
   /// Example #2 : substract a from current value
   extern "C" ABSIMPLE_API double    ICalculator_sub(ICalculator*, double a); 
   /// Example #2 : divide current value by a . Returns IError#ErrorCode IError#ErrorCode.DivideByZero exception if a is null.
   extern "C" ABSIMPLE_API double    ICalculator_divide(ICalculator*, double a); 
   /// Example #2 : set current value 
   extern "C" ABSIMPLE_API double    ICalculator_set(ICalculator*, double a); 
   /// Example #2 : clear current value ( set 0 )
   extern "C" ABSIMPLE_API double    ICalculator_clear(ICalculator*); 

   //=============================================================================
   /// example #3 : struct DateTime interface 
   struct IDateTime { 
      int year;      ///< year (must be >= 1900) 
      int month;     ///< month of year from 1 to 12
      int day;       ///< day of month from 1 to 31
      int hour;      ///< hours of day from 0 to 24
      int minute;    ///< minutes of hour from 0 to 59
      int second;    ///< seconds of minutes from 0 to 59
   };


   /// Example #3: release IDateTime instance
   extern "C" ABSIMPLE_API void IDateTime_deleteInstance(IDateTime* dateTime);

   /// Example #3: see IDateTime::year
   extern "C" ABSIMPLE_API void IDateTime_year_set(IDateTime* dateTime,int value);
   /// Example #3: see IDateTime::year
   extern "C" ABSIMPLE_API int  IDateTime_year_get(IDateTime* dateTime);
   /// Example #3: see IDateTime::month
   extern "C" ABSIMPLE_API void IDateTime_month_set(IDateTime* dateTime,int value);
   /// Example #3: see IDateTime::month
   extern "C" ABSIMPLE_API int  IDateTime_month_get(IDateTime* dateTime);
   /// Example #3: see IDateTime::day
   extern "C" ABSIMPLE_API void IDateTime_day_set(IDateTime* dateTime,int value);
   /// Example #3: see IDateTime::day
   extern "C" ABSIMPLE_API int  IDateTime_day_get(IDateTime* dateTime);
   /// Example #3: see IDateTime::hour
   extern "C" ABSIMPLE_API void IDateTime_hour_set(IDateTime* dateTime,int value);
   /// Example #3: see IDateTime::hour
   extern "C" ABSIMPLE_API int  IDateTime_hour_get(IDateTime* dateTime);
   /// Example #3: see IDateTime::minute
   extern "C" ABSIMPLE_API void IDateTime_minute_set(IDateTime* dateTime,int value);
   /// Example #3: see IDateTime::minute
   extern "C" ABSIMPLE_API int  IDateTime_minute_get(IDateTime* dateTime);
   /// Example #3: see IDateTime::second
   extern "C" ABSIMPLE_API void IDateTime_second_set(IDateTime* dateTime,int value);
   /// Example #3: see IDateTime::second
   extern "C" ABSIMPLE_API int  IDateTime_second_get(IDateTime* dateTime);

   //=============================================================================
   /// example #3 : ICalendar interface with functions which return structure instance 
   // 1) ICalendar class convenient declaration for C++ users
   class ICalendar
   {
   public:
      virtual ~ICalendar() {};

      /// release Calendar instance created with ICalendar_createInstance()
      virtual void Release() = 0;
      
      /// converts date elements to ISO 8601 string. Returned string must released with absimple_releaseCharArray()
      virtual const char* convertIntToString(int year, int month, int day, int hour, int minute, int second)=0;
      
      /// converts date elements to IDateTime . Returned IDateTime must released with IDateTime_deleteInstance()
      virtual IDateTime* convertIntToStruct(int year, int month, int day, int hour, int minute, int second)=0;
      
      /// converts ISO 8601 string to IDateTime . Returned IDateTime instance must be released with IDateTime_deleteInstance()
      virtual IDateTime* convertStringToStruct(const char* stringDate)=0;

      ///
      virtual abcommon::IArray* getDayList ()=0;

      /// \private internal error callback
      ErrorCallbackType errorCallback;
   };

   // functions declaration for other langages than C++
   extern "C" ABSIMPLE_API ICalendar*  ICalendar_createInstance(ErrorCallbackType applicationCallback);
   extern "C" ABSIMPLE_API void        ICalendar_deleteInstance(ICalendar*);
   extern "C" ABSIMPLE_API const char* ICalendar_convertIntToString(ICalendar* calendar, int year, int month, int day, int hour, int minute, int second); 
   extern "C" ABSIMPLE_API IDateTime*  ICalendar_convertIntToStruct(ICalendar* calendar, int year, int month, int day, int hour, int minute, int second); 
   extern "C" ABSIMPLE_API IDateTime*  ICalendar_convertStringToStruct(ICalendar* calendar, const char * charDate);
   extern "C" ABSIMPLE_API abcommon::IArray* ICalendar_getDayList(ICalendar* calendar);

   //=============================================================================
   /// example #5

   extern "C" ABSIMPLE_API double               absimple_getPlanetMass(const char * planetName);
   
   extern "C" ABSIMPLE_API abcommon::IArray*    absimple_getPlanetNameList();
   //extern "C" ABSIMPLE_API const char*          absimple_getPlanetName_at(abcommon::IArray* dataArray, int index);

   extern "C" ABSIMPLE_API abcommon::IArray*    absimple_getPlanetMassList();
   //extern "C" ABSIMPLE_API double               absimple_getPlanetMass_at(abcommon::IArray* dataArray, int index);
   
   extern "C" ABSIMPLE_API abcommon::IIntArray* absimple_getSatelliteNbList();

   typedef struct {
      double i; 
      double a;
      double e;
   } SOrbit;

   extern "C" ABSIMPLE_API abcommon::IStructArray* absimple_getOrbitList();
 //  extern "C" ABSIMPLE_API SOrbit*              absimple_getOrbit_at(abcommon::IArray* dataArray, int index);

   //=============================================================================
   /// example #6.1
   
   class IWorkItemProducer 
   {

   public:
      virtual ~IWorkItemProducer() {};
      /// release Calendar instance created with ICalendar_createInstance()
      virtual void release() = 0;
      virtual void run(int iterations)=0;
   };

   extern "C" ABSIMPLE_API IWorkItemProducer* IWorkItemProducer_createInstance();
   extern "C" ABSIMPLE_API void               IWorkItemProducer_deleteInstance(IWorkItemProducer* producer);
   extern "C" ABSIMPLE_API void               IWorkItemProducer_run(IWorkItemProducer* producer, int iterations); 
   
   //=============================================================================
   /// example #7
   
   class IProducer : public abcommon::IPoolInstance
   {
   public:  // C++ method
      virtual           ~IProducer() {};
      virtual void      acq(int exptime)=0;
      virtual int       waitMessage()=0;
   };

   
   class IProducerPool
   {
   public: // C++ factorys
      ABSIMPLE_API static IProducer* createInstance();
      ABSIMPLE_API static void       deleteInstance(IProducer* producer);
      ABSIMPLE_API static int        getInstanceNo(IProducer* producer);
      ABSIMPLE_API static IProducer* getInstance(int producerNo);
      ABSIMPLE_API static abcommon::IIntArray* getIntanceNoList();
   };


   //  C factory
   extern "C" ABSIMPLE_API IProducer* IProducerPool_createInstance();
   extern "C" ABSIMPLE_API void              IProducerPool_deleteInstance(IProducer* producer);
   extern "C" ABSIMPLE_API int               IProducerPool_getInstanceNo(IProducer* producer);
   extern "C" ABSIMPLE_API IProducer* IProducerPool_getInstance(int producerNo);
   extern "C" ABSIMPLE_API abcommon::IIntArray* IProducerPool_getIntanceNoList();
   // C method
   extern "C" ABSIMPLE_API void              IProducer_acq(IProducer* producer, int exptime); 
   extern "C" ABSIMPLE_API int               IProducer_waitMessage(IProducer* producer); 


   //=============================================================================
   // IStation interface 
   //=============================================================================

   class Frame {
   public:
      enum Values { TR, CR };
      Frame(Values t) : m_value(t) {}
      operator Values () const {return m_value;}
   private:
      Values m_value;   
   };

   class Sense {
   public:
      enum Values { EAST, WEST };
      Sense(Values t) : m_value(t) {}
      operator Values () const {return m_value;}
   private:
      Values m_value;   
   };

   class IStation 
   {
   public:
      //typedef enum { TRF =0, CRF= 1 } Frame;
      //typedef enum { EAST = 'E', WEST= 'W' } Sense;

      virtual ~IStation() {}; // destructeur virtuel demande sous linux

      virtual const char *       get_GPS(Frame frame)=0;
      virtual Sense              getSense()=0;
      
      //static Sense convertToSense(const char* charSense);
      //static std::string toString(IStation::Sense sense);

   };

   /**
   @brief Create an instance of Station type from a string.
   @param home (formated as GPS abs(longitude_deg) E|W latitude_deg altitude_m)
   @return Pointer IStation 
   @code {.cpp}
   Ihome *home = abmc::IStation_createInstance_from_string("GPS 2 E 43 1345");
   ...
   IStation_releaseInstance(home); 
   @endcode
   */
   extern "C" ABSIMPLE_API IStation*         IStation_createInstance();
   extern "C" ABSIMPLE_API IStation*         IStation_createInstance_from_string(const char *home);
   extern "C" ABSIMPLE_API IStation*         IStation_createInstance_from_string2(const char * home, Sense sense);
   extern "C" ABSIMPLE_API void              IStation_deleteInstance(IStation* home);
   extern "C" ABSIMPLE_API const char *      IStation_get_GPS(IStation *home, Frame frame);
   extern "C" ABSIMPLE_API Sense::Values     IStation_getSense(IStation *home);


} // namespace end

