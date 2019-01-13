///@file abcommon.h
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
// $Id:$

#pragma once

#include <time.h>
#include <string>
#include <vector>
#include <string.h>

#include <abcommon2.h>

// declaration gettimeofday sous Windows pour avoir l'equivalent de la fonction 
//   gettimeofday sous Linux (fournie dans <sys/time.h> )
// Remarque: gettimeofday  n'est pas dans le namespace abcommon sous Windows 
//   pour qu'elle puisse être utilisée dans les memes condition que sous Linux 
#ifdef WIN32
#include <Winsock.h> // pour struct timeval 
void  gettimeofday ( struct timeval * start, void * foo);
#else
#include <sys/time.h> // pour gettimeofday
#endif


//=============================================================================
// macros to intercept C++ exceptions in C function
//=============================================================================

#define CATCH_ERROR(func, returnValue )            \
   try {                                           \
      abcommon::lastErrorCode = 0;       \
      return (func);                               \
   } catch (abcommon::IError &ex) {                \
      abcommon::setLastError(ex);          \
      return returnValue;                          \
   }  

#define CATCH_ERROR_VOID(func)                     \
   try {                                           \
      abcommon::lastErrorCode = 0;       \
      func;                                        \
   } catch (abcommon::IError &ex) {                \
      abcommon::setLastError(ex);          \
   }



namespace abcommon {

//============================================================================
// manipulation de chaines
//============================================================================
//// utils for strings
   std::string utils_trim(std::string str);
   std::vector<std::string> utils_split(const std::string s, char seperator);
   void utils_strupr(const std::string& input, std::string& ouput);
   int utils_stod(const std::string& input, double *ouput);
   std::string utils_dost(double val);

   double utils_st2d(const std::string& input);
   std::string utils_d2st(double val);

   //string utils_format(const char *fmt, ...);
   bool utils_caseInsensitiveStringCompare( const std::string& str1, const std::string& str2 );


//============================================================================
// manipulation des dates
//============================================================================


void getutc_ymdhhmmss(int *y,int *m,int *d,int *hh,int *mm,double *sec);


//============================================================================
// manipulation des tableaux
//============================================================================

template <typename  T>
class CDataArray : public IArray  {

   public:
      virtual ~CDataArray() {};

      void release(){
         delete this;
      }

      int size(){
         return datas.size();
      }

      T at(int index){
         return datas.at(index);
      }

      void append(T item){
         datas.push_back(item);
      }

   private:
      std::vector<T> datas;

};

class CIntArray : public IIntArray  {

   public:
      virtual ~CIntArray() {};

      void release(){
         delete this;
      }

      int size(){
         return datas.size();
      }

      int at(int index){
         return datas.at(index);
      }

      void append(int item){
         datas.push_back(item);
      }

   private:
      std::vector<int> datas;

};


class CStringArray : public IStringArray  {

   public:
      virtual ~CStringArray() {};

      void release(){
         delete this;
      }

      int size(){
         return datas.size();
      }

      const char* at(int index){
         return datas.at(index).c_str();
      }

      void append(std::string item){
         datas.push_back(item);
      }

   private:
      std::vector<std::string> datas;

};

template <typename  T>
class CStructArray : public IStructArray  {

   public:
      virtual ~CStructArray() {};

      void release(){
         //delete all elements
         for(int index=0; index < (int) datas.size(); index++ ) {
            T item = datas.at(index);
            if( item != NULL) {
               delete item;
            }
         }
         // delete container
         delete this;
      }

      int size(){ 
         return datas.size();
      }

      void* at(int index){
         return datas.at(index);
      }

      T atType(int index){
         return datas.at(index);
      }
   
      void append(T item){
         datas.push_back(item);
      }

      void assign(std::vector<T>* itemVector){
         datas = *itemVector;
      }

   private:
      std::vector<T> datas;

};

//=============================================================================
// CError 
//=============================================================================

class CError : public IError {
public:
   CError(IError::ErrorCode code, const char *f, ...) throw();
   CError(int code, const char *f, ...) throw();
   ~CError() throw();
   const char* getMessage(void);
   unsigned long  getCode(void);

   
protected:
   CError();
   // attributs accessible uniquement par les classs filles
	char buf[2048];
   int errorCode;


};

extern void setLastError(abcommon::IError &exception);
extern int  lastErrorCode;
extern std::string lastErrorMessage;


//=============================================================================
// CLogger
//=============================================================================
class CLogger : public ILogger {
public:
  
   CLogger();
   ~CLogger();
   void set(const char* defaultFileName, int argc, const char *argv[]);

   LogLevel		getLogLevel();
   void			log(LogLevel level, const char *fmt, ...);
   void			logDebug(const char *fmt, ...);
   void			logInfo(const char *fmt, ...);
   void			logError(const char *fmt, ...);
   void			setLogFileName(std::string logFileName);
   void			setLogLevel(LogLevel level);
   LogLevel    convertToLogLevel(int level);

private:
   std::string m_logFileName;
   LogLevel m_logLevel;

   char *getlogdate(char *buf, size_t size);
};



//=============================================================================
// CPool
//=============================================================================
class CPool  {
public:
   CPool() { };
   ~CPool() { };

   int  add(abcommon::IPoolInstance* item);
   void remove(abcommon::IPoolInstance* item);
   abcommon::IPoolInstance * getInstance(int itemNo);
   abcommon::CIntArray* getIntanceNoList();
   int getInstanceNo(abcommon::IPoolInstance * producer);

private:
   //char *getlogdate(char *buf, size_t size);
   std::vector<abcommon::IPoolInstance*> items;
};


class SAvailable : public IAvailable {
public:
   SAvailable(std::string id, std::string name) {
      m_id.assign(id);
      m_name.assign(name);
   };
   virtual ~SAvailable() {};
   const char* getId() {
      return m_id.c_str();
   };
   const char* getName() {
      return m_name.c_str();
   };
private:
   std::string m_id;
   std::string m_name;
};


//=============================================================================
// utils
//=============================================================================

std::string utils_format(const char *fmt, ...);


bool        argumentToBool(const char *argv, const char * paramName);
double      argumentToDouble(const char *argv, const char * paramName);
float       argumentToFloat(const char *argv, const char * paramName);
int         argumentToInt(const char *argv, const char * paramName);
long        argumentToLong(const char *argv, const char * paramName);
long double argumentToLongDouble(const char *argv, const char * paramName);
long long   argumentToLongLong(const char *argv, const char * paramName);

} // namespace end



