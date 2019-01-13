///@file abcommon_export.h
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

#ifdef WIN32
#if defined(ABCOMMON_EXPORTS) // inside DLL
#   define ABCOMMON_API   __declspec(dllexport)
#else // outside DLL
#   define ABCOMMON_API   __declspec(dllimport)
#endif 

#else 

#if defined(ABCOMMON_EXPORTS) // inside DLL
#   define ABCOMMON_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define ABCOMMON_API 
#endif 

#endif

#ifdef _WIN32
// pour forcer l'export des fonctions de libabcommon dans les DLL des astrobricks
//#pragma comment(linker, "/include:_IArray_deleteInstance")
//#pragma comment(linker, "/include:_IArray_size")
//#pragma comment(linker, "/include:_IIntArray_at")
//#pragma comment(linker, "/include:_IStringArray_at")
//#pragma comment(linker, "/include:_IStructArray_at")
//#pragma comment(linker, "/include:_getLastErrorCode")
//#pragma comment(linker, "/include:_getLastErrorMessage")

#endif

namespace abcommon {

//=============================================================================
// IArray
//=============================================================================
class IArray {
   public:
      virtual ~IArray() {};
      virtual void release()=0;
      virtual int size()=0;
};

class IIntArray : public IArray {
   public:
      virtual int at(int index)=0;
};


class IStringArray : public IArray {
   public:
      virtual const char* at(int index)=0;
};

class IStructArray : public IArray {
   public:
      virtual void* at(int index)=0;
};


//extern "C" ABCOMMON_API void        IArray_deleteInstance(IArray* dataArray);
//extern "C" ABCOMMON_API int         IArray_size(IArray* dataArray);
//extern "C" ABCOMMON_API int         IIntArray_at(IIntArray* dataArray, int index);
//extern "C" ABCOMMON_API const char* IStringArray_at(IStringArray* dataArray, int index);
//extern "C" ABCOMMON_API void*       IStructArray_at(IStructArray* dataArray, int index);

//=============================================================================
// IError
//=============================================================================
class IError {
public:
   /// functionnal error code list
   typedef enum {
     OK                 = 0,
     ErrorGeneric       = 100,
     ErrorMemory        = 101,     
     ErrorDivideByZero  = 102,
     ErrorInput         = 103
   } ErrorCode;            

   /// error message 
   virtual const char * getMessage(void)=0;     
   /// functionnal error code
   virtual unsigned long  getCode(void)=0;   
};

extern "C" ABCOMMON_API int         getLastErrorCode();
extern "C" ABCOMMON_API const char* getLastErrorMessage();

//=============================================================================
// IPoolInstance
//=============================================================================
class IPoolInstance {
public:
   int getNo();
   void setNo(int itemNo);
protected:
   int m_itemNo;
};


//=============================================================================
// ILogger
//=============================================================================
class ILogger {
public:

   typedef enum {
      LOG_NONE=0,
      LOG_ERROR=1,
      LOG_WARNING=2,
      LOG_INFO=3,
      LOG_DEBUG=4
   } LogLevel;

   virtual             ~ILogger(){};
   virtual LogLevel    getLogLevel()=0;
   virtual void        setLogLevel(LogLevel level)=0;
   virtual void        log(LogLevel level, const char *fmt, ...)=0;
   virtual void        logDebug(const char *fmt, ...)=0;
   virtual void        logError(const char *fmt, ...)=0;
   virtual void        logInfo(const char *fmt, ...)=0;
};


class IAvailable {
public:
   virtual const char* getId()=0;
   virtual const char* getName()=0;
};



} // namespace end
