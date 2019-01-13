/* CLibraryLoader.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
#pragma once

#include <string>
#include <ltdl.h>    // pour lt_dlhandle
#include <abaudela.h>
using namespace ::abaudela;


//#ifdef WIN32
//#define lt_dlhandle                 HMODULE
//#define lt_dlinit()         
//#define lt_dlopenext(_filename)		LoadLibrary(_filename)
//#define lt_dlsym(_handle, _funcname)	GetProcAddress(_handle, _funcname)
//#define lt_dlclose(_handle)		FreeLibrary(_handle)
//#define lt_dlerror()			      "Windows Error"
//#define lt_dlexit() 
//#endif



#ifdef _WIN32 
#define PATH_SEPARATOR "\\" 
#define LIB_EXTENSION  ".dll" 
#else 
#define PATH_SEPARATOR "/" 
#define LIB_EXTENSION  ".so" 
#endif 


template <typename  TEMPLATE_LIB>
class CLibraryLoader {

public:
   CLibraryLoader() {
      lt_dlinit();
      m_lh = NULL;

   }

   ~CLibraryLoader(){
      if( m_lh != NULL) {
         lt_dlclose (m_lh);
      }
      lt_dlexit ();
   }

   ///@brief load a library file and create an instance
   //
   // @param librayPath  directory
   // @param prefix "cam" or "tel"
   // @param libraryShortName  short name of library . Example: "audine"  for library "libcamaudine.dll"
   // @param argc  
   // @param argv 
   // 
   // @return intance pointer
   TEMPLATE_LIB load(const char* librayPath, const char* prefix, const char * libraryShortName, const char * createFunctionName, int argc, const char *argv[]) {
      m_libraryName = libraryShortName;

      std::string libraryFileName ="lib";
      libraryFileName +=prefix;
      if(strcmp(libraryShortName,"ascomcam")==0 ) {
         libraryFileName +="ascom";
      } else {
         libraryFileName +=libraryShortName;
      }
      libraryFileName +=LIB_EXTENSION;
      
      // je charge la librairie
      std::string fullFileName;
      fullFileName.append(librayPath).append(PATH_SEPARATOR).append(libraryFileName);
      m_lh = lt_dlopen (fullFileName.c_str() );
      if( m_lh == NULL) {
         lt_dlexit ();
         throw CError(CError::ErrorGeneric, "cannot open %s : lt_dlopen error=%s", fullFileName.c_str(), lt_dlerror());
      };
      // je recupere le pointeurs des fonctions
      CreateFunc createFunc = (CreateFunc) lt_dlsym (m_lh, createFunctionName);
      if( createFunc == NULL ) {
         lt_dlclose (m_lh);
         lt_dlexit ();
         throw CError(CError::ErrorGeneric, "cannot found function %s in %s . lt_dlsym error=%s", createFunctionName, fullFileName.c_str(), lt_dlerror() );
      }; 


      // je cree une instance      
      TEMPLATE_LIB libcam = createFunc(argc, argv);

      if( libcam == NULL) {
         int(*getLastErrorCodeFunc)(void);
         const char *(*getLastErrorMessageFunc)(void);

         getLastErrorCodeFunc = (int(*)(void) ) lt_dlsym(m_lh, "getLastErrorCode");
         if (getLastErrorCodeFunc == NULL) {
            lt_dlclose(m_lh);
            lt_dlexit();
            throw CError(CError::ErrorGeneric, "%s %s in createInstance lt_dlsym getLastErrorCode", lt_dlerror(), fullFileName.c_str());
         };

         getLastErrorMessageFunc = (const char*(*)(void)) lt_dlsym(m_lh, "getLastErrorMessage");
         if (getLastErrorMessageFunc == NULL) {
            lt_dlclose(m_lh);
            lt_dlexit();
            throw CError(CError::ErrorGeneric, "%s %s in createInstance lt_dlsym getLastErrorMessageFunc", lt_dlerror(), fullFileName.c_str());
         };

         CError ex(getLastErrorCodeFunc(), getLastErrorMessageFunc());

         lt_dlclose (m_lh);
         lt_dlexit ();         
         throw ex;
      }

      return libcam;
      
   };

   const char * getLibraryName() {
      return m_libraryName.c_str();
   }




private:
   lt_dlhandle    m_lh;
   std::string    m_libraryName;
   typedef TEMPLATE_LIB (* CreateFunc)(int argc, const char *argv[]);
   typedef void   (* DeleteFunc)(TEMPLATE_LIB libcam);

   typedef int (*getCodeFunc)();
   typedef const char * (*getMessageFunc)();
      
};
