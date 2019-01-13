// CCalendar.cpp
// sample of internal implementation of class with methods 
// returning structure
//

#include <ctime>
#include <cstdio> //pour sscanf
#include <cstring> //pour memset


#include <abcommon.h>
using namespace abcommon;

#include "CCalendar.h"


CCalendar::CCalendar()
{
}

void CCalendar::Release()
{
    delete this;
}

const char* CCalendar::convertIntToString(int year, int month, int day, int hour, int minute, int second)
{
   // std::tm  definition : 
   //int tm_sec;   // seconds of minutes from 0 to 61
   //int tm_min;   // minutes of hour from 0 to 59
   //int tm_hour;  // hours of day from 0 to 24
   //int tm_mday;  // day of month from 1 to 31
   //int tm_mon;   // month of year from 0 to 11
   //int tm_year;  // year since 1900
   //int tm_wday;  // days since sunday
   //int tm_yday;  // days since January 1st
   //int tm_isdst; // hours of daylight savings time
   std::tm timeDate ;

   if( second <0 || second>59 ) {
      throw CError(CError::ErrorInput,"second=%d not in range [0,59]", second);
   }

   // copy parameters to std::tm instance 
   timeDate.tm_sec = second;
   timeDate.tm_min = minute;
   timeDate.tm_hour = hour;
   timeDate.tm_mday = day;
   timeDate.tm_mon  = month -1;
   timeDate.tm_year = year -1900;

   // format int string
   char* charDate = new char[100];
   strftime(charDate, 99,"%Y-%m-%dT%H:%M:%S", &timeDate);
   return charDate;   
}

IDateTime* CCalendar::convertIntToStruct(int year, int month, int day, int hour, int minute, int second)
{

   IDateTime* dateTime = new IDateTime();

   dateTime->year = year;
   dateTime->month = month;
   dateTime->day =   day;
   dateTime->hour =  hour;
   dateTime->minute = minute;
   dateTime->second = second;
   
   return dateTime;   
}

IDateTime* CCalendar::convertStringToStruct(const char * stringDate)
{
   std::tm tm ;

   if( strlen(stringDate) == 0) {
      throw CError(CError::ErrorGeneric, "stringDate is empty");
   }

   sscanf(stringDate,"%4d-%2d-%2dT%2d:%2d:%2d",&tm.tm_year,&tm.tm_mon,&tm.tm_mday,
			&tm.tm_hour,&tm.tm_min,&tm.tm_sec);

   CDateTime* dateTime = new CDateTime();
   dateTime->year = tm.tm_year;
   dateTime->month = tm.tm_mon;
   dateTime->day = tm.tm_mday;
   dateTime->hour = tm.tm_hour;
   dateTime->minute = tm.tm_min;
   dateTime->second = tm.tm_sec;
   
   return dateTime;   
}


CDataArray<std::string>* CCalendar::getDayList () {
   
   CDataArray<std::string>*  days = new abcommon::CDataArray<std::string>(); 
   days->append("lundi");
   days->append("mardi");
   days->append("mercredi");

   return days;
}



//CDateTime::CDateTime() {
//      memset((char*)this,0,sizeof(CDateTime));
//}
//
//CDateTime::CDateTime(const IDateTime * dateTime) {
//   year = dateTime->year;
//   month = dateTime->month;
//   day = dateTime->day;
//   hour = dateTime->hour;
//   minute = dateTime->minute;
//   second = dateTime->second;
//}

//CArrayString* getMonthList ( ) {
//   
//   CArrayString*  months = new CArrayString(); 
//   months->push_back("janvier");
//   months->push_back("février");
//   months->push_back("mars");
//
//   return months;
//}

