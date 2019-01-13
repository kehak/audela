/* liblink.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

// $Id: liblink.cpp,v 1.6 2010-02-28 14:30:28 michelpujol Exp $


#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#if _MSC_VER < 1500
#define vsnprintf _vsnprintf
#endif
#endif
#if defined(_MSC_VER)
#include <sys/timeb.h>
#include <time.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <string>

#include <tcl.h>
#include "liblink/liblink.h"
#include "liblink/useitem.h"
#include "libname.h"
#include "linktcl.h"
#include "link.h"

//  protype pour l'utilisation pour un programme C
#if defined(OS_WIN)
extern "C" int __cdecl LINK_ENTRYPOINT(Tcl_Interp * interp);
#else
extern "C" int LINK_ENTRYPOINT(Tcl_Interp * interp);
#endif

extern struct link_drv_t LINK_DRV;
extern struct linkini LINK_INI[];


/*
* Prototypes des differentes fonctions d'interface Tcl/Driver. Ajoutez les
* votres ici.
*/
/* === Common commands for all linkeras ===*/
static int cmdLink(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdLinkClose(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdLinkCreate(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdLinkDriverName(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdLinkName(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdLinkUse(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);

#define COMMON_CMDLIST \
   {"drivername", (Tcl_CmdProc *)cmdLinkDriverName},\
   {"close", (Tcl_CmdProc *)cmdLinkClose}, \
   {"name", (Tcl_CmdProc *)cmdLinkName},\
   {"use", (Tcl_CmdProc *)cmdLinkUse},\
   

static struct cmditem cmdlist[] = {
   /* === Common commands for all linkeras === */
   COMMON_CMDLIST
      /* === Specific commands for that linkera === */
   SPECIFIC_CMDLIST
      /* === Last function terminated by NULL pointers === */
   {NULL, NULL}
};

#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4

static int debug_level = 4;

static void liblink_log(int level, const char *fmt, ...)
{
   va_list mkr;
   va_start(mkr, fmt);
   if (level <= debug_level) {
      switch (level) {
      case LOG_ERROR:
         printf("%s(%s) <ERROR> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      case LOG_WARNING:
         printf("%s(%s) <WARNING> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      case LOG_INFO:
         printf("%s(%s) <INFO> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      case LOG_DEBUG:
         printf("%s(%s) <DEBUG> : ", LINK_LIBNAME, LINK_LIBVER);
         break;
      }
      vprintf(fmt, mkr);
      printf("\n");
      va_end(mkr);
   }
}




/*
* Point d'entree de la librairie, appelle lors de la commande Tcl load.
*/
#if defined(OS_WIN)
int __cdecl LINK_ENTRYPOINT(Tcl_Interp * interp)
#else
int LINK_ENTRYPOINT(Tcl_Interp * interp)
#endif
{
   char s[256];
   struct cmditem *cmd;
   int i;
   
   liblink_log(LOG_INFO, "Calling entrypoint for driver %s LINK_ENTRYPOINT=%p", LINK_DRIVNAME, LINK_ENTRYPOINT);
   if (Tcl_InitStubs(interp, "8.3", 0) == NULL) {
      Tcl_SetResult(interp, (char*)"Tcl Stubs initialization failed in " LINK_LIBNAME " (" LINK_LIBVER ").", TCL_VOLATILE);
      liblink_log(LOG_ERROR, "Tcl Stubs initialization failed.");
      return TCL_ERROR;
   }
   
   liblink_log(LOG_DEBUG, "cmdLinkCreate = %p interp=%p", cmdLinkCreate, interp);
   liblink_log(LOG_DEBUG, "cmdLink = %p LINK_DRIVNAME=%s LINK_LIBNAME=%s LINK_LIBVER=%s", cmdLink, LINK_DRIVNAME, LINK_LIBNAME, LINK_LIBVER);
   
   Tcl_CreateCommand(interp, LINK_DRIVNAME, (Tcl_CmdProc *) cmdLinkCreate, NULL, NULL);
   Tcl_PkgProvide(interp, LINK_LIBNAME, LINK_LIBVER);
   
   for (i = 0, cmd = cmdlist; cmd->cmd != NULL; cmd++, i++);
   
#if defined(__BORLANDC__)
   sprintf(s, "Borland C (%s) ...nb commandes = %d", __DATE__, i);
#elif defined(OS_LIN)
   sprintf(s, "Linux (%s) ...nb commandes = %d", __DATE__, i);
#else
   sprintf(s, "VisualC (%s) ...nb commandes = %d", __DATE__, i);
#endif
   
   liblink_log(LOG_INFO, "Driver provides %d functions.", i);
   
   Tcl_SetResult(interp, s, TCL_VOLATILE);
   return TCL_OK;
}

/*
 * cmdLinkCreate
 *    seule commande visible en TCL
 *    drivername linkx       : cree le link numero x
 *    drivername available   : retourne la liste des link disponibles
 *    drivername genericname : retourne le prefixe du port du link
 */
static int cmdLinkCreate(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int result;
   char s[256];

   if (argc < 2) {
      sprintf(s, "%s linkx|available|genericname", argv[0]);
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      return TCL_ERROR;
   } else if (argc == 2 && strcmp(argv[1], "available") ==0) {
      char * ligne = NULL;
      DWORD numDevices;
      // ligne is allocated by available()
     if( LINK_CLASS::getAvailableLinks(&numDevices, &ligne) == LINK_OK) {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_OK;
      } else {
         result = TCL_ERROR;
      }
      free(ligne);
   } else if (argc == 2 && strcmp(argv[1], "genericname") ==0) {
         Tcl_SetResult(interp,(char*)LINK_CLASS::getGenericName(),TCL_VOLATILE);
         result = TCL_OK;
   } else if (argc >= 3 && strncmp(argv[1], "link",4) ==0) {
      CLink *link;
      int linkno;
      int err;
      // je cree l'objet c++
      link = new LINK_CLASS();

      link->setAuthorized(1);
      /*
      Tcl_Eval(interp, "set ::tcl_platform(os)");
      strcpy(s, Tcl_GetStringResult(interp));
      if ((strcmp(s, "Windows 95") == 0)
         || (strcmp(s, "Windows 98") == 0)
         || (strcmp(s, "Linux") == 0)) {
         link->setAuthorized(1);
      } else {
         link->setAuthorized(0);
      }
      */
      sscanf(argv[1], "link%d", &linkno);
      link->setLinkNo(linkno);
      link->setLastMessage("");
      if ((err = link->init_common(argc, argv)) != LINK_OK) {
         Tcl_SetResult(interp, link->getLastMessage(), TCL_VOLATILE);
         free(link);
         result = TCL_ERROR;
      } else {
         if ((err = link->openLink(argc, argv)) != 0) {
            Tcl_SetResult(interp, link->getLastMessage(), TCL_VOLATILE);
            delete link;
            result = TCL_ERROR;
         } else {
            Tcl_CreateCommand(interp, argv[1], (Tcl_CmdProc *) cmdLink, (ClientData) link, NULL);            
            liblink_log(LOG_DEBUG, "cmdLinkCreate: create link data at %p\n", link);
            result = TCL_OK;
         }
      }
   } else {      
      sprintf(s, "unknown option %s \n usage : %s linkx|available|genericname", argv[1], argv[0]);
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      return TCL_ERROR;
   }

   return result;
}

static int cmdLink(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char s[1024], ss[50];
   int retour = TCL_OK, k;
   struct cmditem *cmd;
   
   if (argc == 1) {
      sprintf(s, "%s choose sub-command among ", argv[0]);
      k = 0;
      while (cmdlist[k].cmd != NULL) {
         sprintf(ss, " %s", cmdlist[k].cmd);
         strcat(s, ss);
         k++;
      }
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      for (cmd = cmdlist; cmd->cmd != NULL; cmd++) {
         if (strcmp(cmd->cmd, argv[1]) == 0) {
            retour = (*cmd->func) (clientData, interp, argc, argv);
            break;
         }
      }
      if (cmd->cmd == NULL) {
         sprintf(s, "%s %s : sub-command not found among ", argv[0], argv[1]);
         k = 0;
         while (cmdlist[k].cmd != NULL) {
            sprintf(ss, " %s", cmdlist[k].cmd);
            strcat(s, ss);
            k++;
         }
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
}

/** 
 * cmdLinkDriverName
 *
 *  retourne le nom du driver
 *
 */
static int cmdLinkDriverName(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   sprintf(ligne, "%s", LINK_DRIVNAME);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/** 
 * cmdLinkName
 *
 *  retourne le nom du link
 * 
 * @exemple : "COM1"
 */
static int cmdLinkName(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   CLink * link = (CLink *) clientData;   
   Tcl_SetResult(interp, link->getName(), TCL_VOLATILE);
   return TCL_OK;
}

/** 
 * cmdLinkClose
 *
 *  ferme la liaison (libere les ressources
 *
 */

static int cmdLinkClose(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   CLink * link = (CLink *) clientData;
   link->closeLink();
   delete link;
   Tcl_ResetResult(interp);
   return TCL_OK;
}

/** 
 * cmdLinkUse
 *
 *  link1 use 
 *     retourne la liste des peripheriques qui utilisent cette liaison
 *     exemple : 
 *     link1 use get
 *      { { "cam1", "longuepose bit 1" } { "tel1", "bit 2 focus} }
 *
 *  link1 use add deviceId comment 
 *     ajoute un peripherique � la liste 
 *     exemple : 
 *      link1 use add "cam1"  "longuepose bit 1" 
 *
 *  link1 use remove deviceId 
 *     supprime un peripherique de la liste 
 *     exemple : 
 *      link1 remove "cam1"
 */
static int cmdLinkUse(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CLink * link = (CLink *) clientData;;
   
   ligne = (char*)calloc(200,sizeof(char));
   if(argc<3) {
      sprintf(ligne,"Usage: %s %s add|get|remove ?options?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if( strcmp(argv[2],"add")==0) {
         if(argc<6) {
            sprintf(ligne,"Usage: %s %s add deviceId usage comment \n example: link1 add \"cam1\" \"longuepose\"  \"bit 1\"",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            link->addUse( argv[3], argv[4], argv[5]);
            result = TCL_OK;
         }
      } else if( strcmp(argv[2],"remove")==0) {
         if(argc<5) {
            sprintf(ligne,"Usage: %s %s add deviceId \n example: link1 remove \"cam1\" \"longuepose\" ",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            link->removeUse(argv[3],argv[4]);
            result = TCL_OK;

         }

      } else if( strcmp(argv[2],"get")==0) {
         std::string useList = link->getUse();
         Tcl_SetResult(interp,(char*)useList.c_str(),TCL_VOLATILE);
      }
   }
   free(ligne);
   return result;
}

CLink::CLink()
{
   strcpy(name,"");
}


CLink::~CLink()
{
}


/**
 * init_common
 *    initalise les parametres du link
 * Return :
 * - LINK_OK    when success.
 * - LINK_ERROR when error occurred, error description in cam->msg.
*/
int CLink::init_common(int argc, const char **argv)
{
   int result;

   if(argc>2) {    
      unsigned int indexLen = strlen(argv[2]);
      unsigned int indexMaxLen = sizeof(name);
      if( indexLen > 0 && indexLen < indexMaxLen ) {
         strcpy(name, argv[2]);
         result = LINK_OK;   
      } else {
         setLastMessage("Usage: %s %s ?name?\nBad name=%d . length of name must be between 1 to %d",argv[0],argv[1],argv[2],indexMaxLen);
         result = LINK_ERROR;
      }
   } else {
         setLastMessage("Usage: %s %s ?name?\nname is mising",argv[0],argv[1]);
         result = LINK_ERROR;
   }

   return result;
}



char * CLink::getName() {
   return name;
}

char * CLink::getLastMessage() {
   return msg;
}

int CLink::addUse(const char* deviceId, const char *usage, const char *comment) {
   // je cree l'item et je l'ajoute à la liste
   CUseItem useItem(deviceId, usage, comment);
   useItemList.push_back( useItem );
   return 0;
}

std::string CLink::getUse() {
   // je concatene les informations des useItem
   ::std::string useList; 
   for (std::list<CUseItem>::iterator it=useItemList.begin(); it != useItemList.end(); ++it) {
      useList.append("{ ")
         .append((*it).getDeviceId())
         .append(" \"")
         .append((*it).getUsage())
         .append( "\" \"")
         .append((*it).getComment())
         .append("\" } ");
   }
   return useList;
}

int CLink::removeUse(const char* deviceId, const char* usage) {
   for (std::list<CUseItem>::iterator it=useItemList.begin(); it != useItemList.end(); ++it) {
      if( strcmp( deviceId, (*it).getDeviceId())==0 
          && strcmp( usage, (*it).getUsage())==0 ) {
         // je supprime l'item de la liste
          useItemList.erase(it);
         break;
      }
   }

   return 0;
}


void CLink::setAuthorized(int value) {
   authorized = value;
}

void CLink::setLinkNo(int value) {
   authorized = value;
}


void CLink::setLastMessage(const char *format, ...) {
	va_list val;
//   strcpy( msg , value);

	va_start(val, format);
   vsnprintf(msg,1024,format,val);
	va_end(val);

}

/*
void CError::setf(const char *f, ...) throw(){
	va_list val;

	va_start(val, f);
	vsetf(f,val);
	va_end(val);
}

void CError::vsetf(const char *f, va_list val) throw(){
	buf = new char[1024];
	if (buf) {
		buf[1023] = 0;
		//sprintf(buf, f, val);
      vsprintf(buf,f,val);

	}
}

  */
