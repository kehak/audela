///@file CLogger.cpp
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author : Michel PUJOL
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
// $Id: CLogger.cpp 13677 2016-04-10 10:49:00Z michelpujol $

#include <algorithm>  // std::replace
#include <stdio.h>  // pour NULL
#include <stdarg.h>    // va_start
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */

#include <abcommon.h>
using namespace abcommon;


#if defined(WIN32) || defined(_WIN32) 
#define PATH_SEPARATOR '\\'
#else 
#define PATH_SEPARATOR '/' 
#endif 

abcommon::CLogger::CLogger() {
   m_logLevel= CLogger::LOG_NONE;
   m_logFileName="";
}

void abcommon::CLogger::set(const char* defaultFileName, int argc, const char *argv[] ) {
   std::string logDirectory = "";
   std::string logFileName = defaultFileName;
   m_logLevel = CLogger::LOG_ERROR;

   // je copie le nom du port en limitant le nombre de caractères à la taille maximal de this->portname
   for (int kk = 1; kk < argc - 1; kk++) {
      if (strcmp(argv[kk], "-log_level") == 0) {
         if (kk + 1 <  argc) {
            m_logLevel = convertToLogLevel(atoi(argv[kk + 1]));
         }
      }

      if (strcmp(argv[kk], "-log_directory") == 0) {
         if (kk + 1 <  argc) {
            logDirectory = argv[kk + 1];
         }
      }

      if (strcmp(argv[kk], "-log_file") == 0) {
         if (kk + 1 <  argc) {
            logFileName = argv[kk + 1];
         }
      }
   }

   // je concatene un PATH_SEPARATOR a la fin du repertoire s'il n'y est pas deja
   if (logDirectory.size() != 0 && logDirectory[logDirectory.size() - 1] != PATH_SEPARATOR) {
      logDirectory += PATH_SEPARATOR;
   }

   m_logFileName.clear();
   m_logFileName.append(logDirectory).append(logFileName);

#ifdef WIN32
   std::replace(m_logFileName.begin(), m_logFileName.end(), '/', PATH_SEPARATOR);
#endif


}

abcommon::CLogger::~CLogger() {
}

abcommon::CLogger::LogLevel abcommon::CLogger::getLogLevel() {
   return m_logLevel;
}

void abcommon::CLogger::setLogLevel(LogLevel level) {
   this->m_logLevel = level;
}

void abcommon::CLogger::setLogFileName(std::string logFileName) {
	this->m_logFileName = logFileName;
}

void abcommon::CLogger::logDebug(const char *fmt, ...) {
   if (LOG_DEBUG <= this->m_logLevel) {
      FILE *f = fopen(m_logFileName.c_str(), "at+");
      if (f != NULL) {
         char buf[100];
         getlogdate(buf, 100);
         fprintf(f, "%s - <DEBUG> : ", buf);
         va_list mkr;
         va_start(mkr, fmt);
         vfprintf(f, fmt, mkr);
         va_end(mkr);
         fprintf(f, "\n");
         fclose(f);
      }
   }

}

void abcommon::CLogger::logInfo(const char *fmt, ...) {
   if (LOG_INFO <= this->m_logLevel) {
      FILE *f = fopen(m_logFileName.c_str(), "at+");
      if (f != NULL) {
         char buf[100];
         getlogdate(buf, 100);
         fprintf(f, "%s - <INFO> : ", buf);
         va_list mkr;
         va_start(mkr, fmt);
         vfprintf(f, fmt, mkr);
         fprintf(f, "\n");
         va_end(mkr);
         fclose(f);
      }
   }

}

void abcommon::CLogger::logError(const char *fmt, ...) {
   if (LOG_ERROR <= this->m_logLevel) {
      FILE *f = fopen(m_logFileName.c_str(), "at+");
      if (f != NULL) {
         char buf[100];
         getlogdate(buf, 100);
         fprintf(f, "%s - <ERROR> : ", buf);
         va_list mkr;
         va_start(mkr, fmt);
         vfprintf(f, fmt, mkr);
         fprintf(f, "\n");
         va_end(mkr);
         fclose(f);
      }
   }

}

void abcommon::CLogger::log(LogLevel level, const char *fmt, ...)
{
   if (level <= this->m_logLevel) {
      char buf[100];

      FILE *f = fopen(m_logFileName.c_str(),"at+");
      if (f != NULL) {
         getlogdate(buf, 100);
         switch (level) {
         case LOG_ERROR:
            fprintf(f,"%s - <ERROR> : ", buf);
            break;
         case LOG_WARNING:
            fprintf(f,"%s - <WARNING> : ", buf);
            break;
         case LOG_INFO:
            fprintf(f,"%s - <INFO> : ", buf);
            break;
         case LOG_DEBUG:
            fprintf(f,"%s - <DEBUG> : ", buf);
            break;
         }
         va_list mkr;
         va_start(mkr, fmt);
         vfprintf(f,fmt, mkr);
         va_end(mkr);
         fprintf(f,"\n");
         fclose(f);
      }
   }
}

/*
 * char* getlogdate(char *buf, size_t size)
 *   Generates a FITS compliant string into buf representing the date at which
 *   this function is called. Returns buf.
 */
char *abcommon::CLogger::getlogdate(char *buf, size_t size)
{
#ifdef _WIN32
  #ifdef _MSC_VER
    /* cas special a Microsoft C++ pour avoir les millisecondes */
    struct _timeb timebuffer;
    time_t ltime;
    _ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
  #else
    struct time t1;
    struct date d1;
    getdate(&d1);
    gettime(&t1);
    sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d.%02d : ", d1.da_year,
        d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec,
        t1.ti_hund);
  #endif
#else
    struct timeb timebuffer;
    time_t ltime;
    ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
//#elif defined(OS_MACOS)
//    struct timeval t;
//    char message[50];
//    char s1[27];
//    gettimeofday(&t,NULL);
//    strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime((const time_t*)(&t.tv_sec)));
//    sprintf(s1,"%s.%02d : ",message,(t.tv_usec)/10000);

#endif

    return buf;
}

///@brief verifie et convertit une valeur int en enum LogLevel
//
// @return m_logLevel si verification OK, sinon CError()
abcommon::CLogger::LogLevel abcommon::CLogger::convertToLogLevel(int level) {
   abcommon::CLogger::LogLevel logLevel= static_cast<abcommon::CLogger::LogLevel>(level);
   switch (level) {
      case LOG_ERROR:
      case LOG_WARNING:
      case LOG_INFO:
      case LOG_DEBUG:
         return logLevel;
      default:
         throw CError(CError::ErrorInput, "error convertToLogLevel %d ", level);
   }

}

   


