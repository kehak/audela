// absimple.cpp
// 

//

#include <iostream>  // pour cin cout
#include <stdexcept> // pour runtime_error
#include <string> 

#include <absimple.h>
using namespace absimple;
#include <abcommon.h>

#include "CCalculator.h"
#include "CCalendar.h"
#include "planet.h"
#include "CWorkItemProducer.h"
#include "CStation.h"


//=============================================================================
// macros to intercept C++ exceptions in C function
//  code aned meassage are return with the callback method
//=============================================================================


#define CALL_AND_HANDLE(func, instance)      \
   try {                                    \
      return (func);                       \
   } catch (IError &exception) {                \
      instance->errorCallback(exception.getCode(), exception.getMessage());   \
      return 0;                                       \
   }  


#define CALL_AND_HANDLE_VOID(func, instance)      \
   try {                                    \
      func;                       \
   } catch (IError &exception) {                \
      instance->errorCallback(exception.getCode(), exception.getMessage());   \
      return;                                       \
   }  




//=============================================================================
// example #1 : standalone fonctions implementation  
//=============================================================================

int ::absimple::absimple_processAdd(int a, int b) {
   return a + b; 
}

int ::absimple::absimple_processSub(int a, int b) {
   return a - b; 
}


//=============================================================================
// fonction utilitaire 
//=============================================================================

void ::absimple::absimple_releaseCharArray(const char * charArray) {
   delete [] charArray; 
};


//=============================================================================
// example #2 
// class ICalculator implementation 
//=============================================================================

ICalculator*  absimple::ICalculator_createInstance(ErrorCallbackType errorCallback)
{
   ICalculator* calculator = new CCalculator();
   calculator->errorCallback = errorCallback;
   return calculator;
}

void absimple::ICalculator_deleteInstance(ICalculator* calculator) {
   calculator->Release();
}

double absimple::ICalculator_add(ICalculator* calculator, double x) {
   return calculator->add(x);
}

double absimple::ICalculator_sub(ICalculator* calculator, double x) {
   return calculator->sub(x);
}

double absimple::ICalculator_divide(ICalculator* calculator, double a) {
   CALL_AND_HANDLE( calculator->divide(a), calculator);
}
double absimple::ICalculator_set(ICalculator* calculator, double x) {
   return calculator->set(x);
}

double absimple::ICalculator_clear(ICalculator* calculator) {
   return calculator->clear();
}



//=============================================================================
// example #3 
// class ICalculator & struct DateTime implementations
//=============================================================================
ICalendar*  absimple::ICalendar_createInstance(ErrorCallbackType errorCallback) {
   ICalendar* calendar = new CCalendar();
   calendar->errorCallback = errorCallback;
   return calendar;
}

void absimple::ICalendar_deleteInstance(ICalendar* calendar) {
   calendar->Release();
}

const char * absimple::ICalendar_convertIntToString(ICalendar* calendar, int year, int month, int day, int hour, int minute, int second) {
   CALL_AND_HANDLE( calendar->convertIntToString(year, month, day, hour, minute, second), calendar);
}

IDateTime* absimple::ICalendar_convertIntToStruct(ICalendar* calendar, int year, int month, int day, int hour, int minute, int second) {   
   CALL_AND_HANDLE( calendar->convertIntToStruct(year, month, day, hour, minute, second), calendar);
}

IDateTime* absimple::ICalendar_convertStringToStruct(ICalendar* calendar, const char * charDate) {
   CALL_AND_HANDLE( calendar->convertStringToStruct(charDate), calendar);
}


IArray* absimple::ICalendar_getDayList( ICalendar* calendar ) {
   CALL_AND_HANDLE( calendar->getDayList() , calendar);
} 


//=============================================================================
// example #3
// IDateTimeStruc
//=============================================================================

void absimple::IDateTime_deleteInstance(IDateTime* dateTime) {
   delete dateTime; 
}

void absimple::IDateTime_year_set(IDateTime* dateTime,int value) {   
   dateTime->year = value;
}

int  absimple::IDateTime_year_get(IDateTime* dateTime) {
   return dateTime->year;
}

void absimple::IDateTime_month_set(IDateTime* dateTime,int value) {   
   dateTime->month = value;
}

int  absimple::IDateTime_month_get(IDateTime* dateTime) {
   return dateTime->month;
}

void absimple::IDateTime_day_set(IDateTime* dateTime,int value) {   
   dateTime->day = value;
}

int  absimple::IDateTime_day_get(IDateTime* dateTime) {
   return dateTime->day;
}

void absimple::IDateTime_hour_set(IDateTime* dateTime,int value) {   
   dateTime->hour = value;
}

int  absimple::IDateTime_hour_get(IDateTime* dateTime) {
   return dateTime->hour;
}

void absimple::IDateTime_minute_set(IDateTime* dateTime,int value) {   
   dateTime->minute = value;
}

int  absimple::IDateTime_minute_get(IDateTime* dateTime) {
   return dateTime->minute;
}

void absimple::IDateTime_second_set(IDateTime* dateTime,int value) {   
   dateTime->second = value;
}

int  absimple::IDateTime_second_get(IDateTime* dateTime) {
   return dateTime->second;
}



//=============================================================================
// example #5  planet C interface
//=============================================================================
/// retourne la liste des noms des planetes
double absimple::absimple_getPlanetMass(const char * planetName) {
   CATCH_ERROR( getPlanetMass(planetName) , 0 );
}


/// retourne la liste des noms des planetes
IArray* absimple::absimple_getPlanetNameList() {
   CATCH_ERROR( getPlanetNameList() , NULL );
}

/// retourne la liste des noms des planetes
IArray* absimple::absimple_getPlanetMassList() {
   CATCH_ERROR( getPlanetMassList() , NULL );
}

/// retourne la liste du nombre de satellites
IIntArray* absimple::absimple_getSatelliteNbList() {
   CATCH_ERROR( getSatelliteNbList() , NULL );
}

/// retourne la liste des orbites
IStructArray* absimple::absimple_getOrbitList() {
   CATCH_ERROR( getOrbitList() , NULL );
}






//=============================================================================
// example #61  WorkItem producer
//=============================================================================
IWorkItemProducer*  absimple::IWorkItemProducer_createInstance() {
   CATCH_ERROR( new CWorkItemProducer(), NULL);
}

void absimple::IWorkItemProducer_deleteInstance(IWorkItemProducer* producer) {
   CATCH_ERROR_VOID(producer->release()) ;
}

void absimple::IWorkItemProducer_run(IWorkItemProducer* producer, int iterations) {
   CATCH_ERROR_VOID( producer->run(iterations) );
}

//=============================================================================
// example #7   Pool
//============================================================================


IProducer*  absimple::IProducerPool_createInstance() {
   CATCH_ERROR( absimple::IProducerPool::createInstance() , NULL);
}

void absimple::IProducerPool_deleteInstance(IProducer* producer) {
   CATCH_ERROR_VOID(absimple::IProducerPool::deleteInstance(producer) );
}

int absimple::IProducerPool_getInstanceNo(IProducer* producer) {
   CATCH_ERROR(absimple::IProducerPool::getInstanceNo(producer) , 0 );
}

IProducer* absimple::IProducerPool_getInstance(int producerNo) {
   CATCH_ERROR(absimple::IProducerPool::getInstance(producerNo) , NULL )
}

IIntArray* absimple::IProducerPool_getIntanceNoList() {
   CATCH_ERROR(absimple::IProducerPool::getIntanceNoList() , NULL );
}


//=============================================================================
// example #7  Message producer
//============================================================================
void absimple::IProducer_acq(IProducer* producer, int exptime) {
   CATCH_ERROR_VOID( producer->acq(exptime) );
}

int absimple::IProducer_waitMessage(IProducer* producer) {
   CATCH_ERROR( producer->waitMessage(), 0 );
}

//=============================================================================
// example #8  Station
//============================================================================

IStation* absimple::IStation_createInstance() {
    CATCH_ERROR(  new CStation()  , NULL ) ;
}

IStation* absimple::IStation_createInstance_from_string(const char * home) {
    CATCH_ERROR(  new CStation(home) , NULL);
}

IStation* absimple::IStation_createInstance_from_string2(const char * home, absimple::Sense sense) {
    CATCH_ERROR(  new CStation(home, sense) , NULL);
}

void absimple::IStation_deleteInstance(IStation* home) {
	CATCH_ERROR_VOID( delete home );
}

const char* absimple::IStation_get_GPS(IStation *home, Frame frame) {
    return home->get_GPS(frame);
}

Sense::Values absimple::IStation_getSense(IStation *home) {
   return home->getSense();
}



