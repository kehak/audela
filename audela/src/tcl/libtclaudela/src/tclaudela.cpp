/* libstd.cpp
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

#define __DLL__
#include <abaudela.h>
using namespace abaudela;
#include "tclaudela.h"
#include "audela.h"
#include "libtt.h"            // for TFLOAT, LONG_IMG, TT_PTR_...
#include "tclBuf.h"
#include "tclCam.h"
#include "tclTel.h"
#include "tclLink.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "setip.h"

#ifdef __cplusplus
}
#endif



#if defined(OS_LIN) || defined(OS_UNX) || defined(OS_MACOS)
   #include <sys/timeb.h>
   #include <stdlib.h>
   #include <string.h>
   #include <dlfcn.h>
   #include <unistd.h>
   #include <stdio.h>
   #include <sys/types.h>
   #include <sys/socket.h>
   #include <netinet/in.h>
   #include <netdb.h>
#endif
#if defined(OS_UNX) || defined(OS_MACOS)
   #include <sys/time.h>
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
   #include <time.h>
#endif

#if defined(OS_WIN)
   #include <windows.h>
   #include <dos.h>
   #include <stdarg.h>    /* pour les vaarg */
   #if defined(_MSC_VER)
      #include <sys/timeb.h>
      #include <time.h>
   #endif
   #include <winsock.h>
   #include <porttalk_interface.h>
#endif

//------------------------------------------------------------------------------
// Prototypes
//
static char default_log_filename[] = "libstd.log";
char *libstd_log_filename;
void LogFile(char*s);
void vlogfile(char *fmt, ...);


int CmdGetBitApp(ClientData , Tcl_Interp *interp, int , char *);
int CmdTestGetClicks(ClientData , Tcl_Interp *interp, int , char *);
int CmdHistory(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdLibstdId(ClientData , Tcl_Interp *interp, int , char *);
int CmdAudelaVersion(ClientData , Tcl_Interp *interp, int , char *);
int ping(char * hostName, int nbTry, int receivedTimeOut, char *result);
extern int CmdCfa2rgb(ClientData , Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdGuide(ClientData , Tcl_Interp *interp, int argc, const char *argv[]);

//------------------------------------------------------------------------------
// Gestion du fichier journal.
//
#define LOG vlogfile
//#define LOG
#define LOGDEBUG LOG
//#define LOGDEBUG
void LogFile(char*s)
{
   FILE *f;
   char s1[27];
   #if defined(OS_WIN)
      #if defined(_MSC_VER)
         /* cas special a Microsoft C++ pour avoir les millisecondes */
         struct _timeb timebuffer;
         char message[50];
         time_t ltime;
         _ftime( &timebuffer );
         time( &ltime );
         strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
         sprintf(s1,"%s.%02d : ",message,(int)(timebuffer.millitm/10));
      #else
         struct time t1;
         struct date d1;
         getdate(&d1);
         gettime(&t1);
         sprintf(s1,"%04d-%02d-%02dT%02d:%02d:%02d.%02d : ",
            d1.da_year,d1.da_mon,d1.da_day,t1.ti_hour,t1.ti_min,t1.ti_sec,t1.ti_hund);
      #endif
   #elif defined(OS_LIN)
      struct timeb timebuffer;
      char message[50];
      time_t ltime;
      ftime( &timebuffer );
      time( &ltime );
      strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
      sprintf(s1,"%s.%02d : ",message,(int)(timebuffer.millitm/10));
   #elif defined(OS_MACOS)
      struct timeval t;
      char message[50];
	  gettimeofday(&t,NULL);
	  strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime((const time_t*)(&t.tv_sec)));
      sprintf(s1,"%s.%02d : ",message,(t.tv_usec)/10000);
   #else
      sprintf(s1,"[No time functions available]");
   #endif
   f = fopen(libstd_log_filename,"at+");
   if(f!=NULL) {
      fprintf(f, "%s\n", s1);
      fprintf(f, "%s\n", s);
      fflush(f);
      fclose(f);
   }
}
void vlogfile(char *fmt, ...)
{
   char s[256];
   va_list va;

   va_start(va,fmt);
   vsprintf(s,fmt,va);
   va_end(va);
   LogFile(s);
}

//------------------------------------------------------------------------------
//
//
int CmdTestGetClicks(ClientData , Tcl_Interp *interp, int , char *)
{
   char s[256];
   sprintf(s,"%lu",audela_getms());
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

//------------------------------------------------------------------------------
//
//
int CmdGetBitApp(ClientData , Tcl_Interp *interp, int , char *)
{
   char s[256];
   sprintf(s,"%d",8*sizeof(void*));
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

//------------------------------------------------------------------------------
//
//
int CmdHostaddress(ClientData , Tcl_Interp *interp, int , char *)
{
   char ip[256];
   char result[256];
   char s[256],*ss;
   unsigned char a0,a1,a2,a3;
   int k;
   struct hostent *p;
   strcpy(result,"{0 0 0 0} {}");
#if defined(OS_WIN)
   WORD        wVer ;
   WSADATA     wsaData ;
   wVer = MAKEWORD(1,1) ;                  // request WinSock version 1.1
   if (WSAStartup(wVer,&wsaData) != 0)  {  // if startup failed
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_OK;
   }
#endif
if (gethostname(ip,sizeof(ip))==0) {
      p=gethostbyname(ip);
      strcpy(result,"");
      if (p!=NULL) {
         k=0;
         while (p->h_addr_list[k]!=NULL) {
            ss=p->h_addr_list[k];
            a0=(unsigned char)ss[0];
            a1=(unsigned char)ss[1];
            a2=(unsigned char)ss[2];
            a3=(unsigned char)ss[3];
            sprintf(s,"{%u %u %u %u} ",a0,a1,a2,a3);
            strcat(result,s);
            k++;
         }
      } else {
         strcpy(result,"{127 0 0 1} ");
      }
      sprintf(s,"{%s}",ip);
      strcat(result,s);
   }
   Tcl_SetResult(interp,result,TCL_VOLATILE);
   return TCL_OK;
}

//------------------------------------------------------------------------------
//
//
int CmdPing(ClientData , Tcl_Interp *interp, int argc, char *argv[])
{
   char s[256],ip[256];
   char result[256];
   int res,timeout=1;
   if (argc<2) {
	   sprintf(s,"usage : %s IPAddress ?timeout_sec?",argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
	   strcpy(ip,argv[1]);
      if (argc>=3) {
         timeout=atoi(argv[2]);
         if (timeout<1) { timeout=1; }
         if (timeout>60) {timeout=60;}
      }
      res=ping(ip,1,timeout,s);
      sprintf(result,"{%d} {%s}",res,s);
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_OK;
   }
}

//------------------------------------------------------------------------------
// CmdSetIP
//
// envoie une demande de chagement d'adresse IP (au format ethernaude)
//
// @param  : ipaddress  , exemple 192.168.1.33
// @return : {code} {message}
//    si OK alors code = 0 et message= chaine vide
//------------------------------------------------------------------------------
int CmdSetIP(ClientData , Tcl_Interp *interp, int argc, char *argv[])
{
   char result[256];

   if (argc<2) {
	   sprintf(result,"usage : %s IPAddress",argv[0]);
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      int res;
      char errorMessage[1024];
      // j'initalise le message d'erreur a vide
      strcpy(errorMessage,"");
      // j'envoi la commande sur la liaison reseau ethernet
      res = setip(argv[1],    // szClientIP nouvelle adresse IP
         "11:22:33:44:55:66", // adresse MAC (non utilisee par l'ethernaude)
         "0.0.0.0",           // masque de sous reseau (filtre nul)
         "255.255.255.1",     // addresse de gateway (non utilise );
         errorMessage);
      sprintf(result,"{%d} {%s}",res,errorMessage);
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_OK;
   }
}

//------------------------------------------------------------------------------
//
//
int CmdPortTalk(ClientData , Tcl_Interp *interp, int argc, char *argv[])
{
   char result[256];
#if defined(OS_WIN)
   int res;
   int i;
   char **ptargv;

   if(argc<2) {
      sprintf(result,"Usage: %s open|close|grant",argv[0]);
      Tcl_SetResult(interp,result,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if(strcmp(argv[1],"open")==0) {
      if(argc<3) {
         sprintf(result,"Usage: %s %s {all | ports address}",argv[0],argv[1]);
         Tcl_SetResult(interp,result,TCL_VOLATILE);
         return TCL_ERROR;
      } else {

         char inputDirectory [1024];
         ptargv = (char**) calloc(argc - 2,sizeof(char*));
         // je copie les arguments
         for( i = 0; i<(argc-2); i++ ) {
            //strcpy(ptemp+(256*i), argv[i+2] );
            ptargv[i]= argv[i+2];
         }
         strcpy(inputDirectory, Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY));
         res = OpenPortTalk(argc-2, ptargv, inputDirectory, result);
         //res =-1;
         //strcpy(result," test");
         free(ptargv);

         if( res == 0 ) {
            Tcl_SetResult(interp,result,TCL_VOLATILE);
         } else {
            Tcl_SetResult(interp,result,TCL_VOLATILE);
            return TCL_ERROR;
         }

      }
   } else if(strcmp(argv[1],"grant")==0) {
      if(argc!=4) {
         sprintf(result,"Usage: %s %s port",argv[0],argv[1]);
         Tcl_SetResult(interp,result,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         char inputDirectory [1024];
         strcpy(inputDirectory, Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY));
         GrantPort( argv[2], inputDirectory, result);
         Tcl_SetResult(interp,"result",TCL_VOLATILE);
      }
   } else if(strcmp(argv[1],"close")==0) {
      if(argc!=2) {
         sprintf(result,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,result,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         ClosePortTalk();
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      }
   }
   return TCL_OK;

#else
   strcpy(result,"Error : not Windows OS");
   Tcl_SetResult(interp,result,TCL_VOLATILE);
   return TCL_ERROR;
#endif
}


//------------------------------------------------------------------------------
// history --
//   Management d'un historique de chaines de caracteres.
//   Syntaxe : history option ...
//      option = add chaine -> ajoute une chaine de caracteres.
//      option = before     -> renvoie la chaine avant la pos. courante.
//      option = after      -> renvoie la chaine apres la pos. courante.
//      option = synchro    -> synchro du pt courant sur le pt d'insertion et de lecajoute une chaine de caracteres.
//      option = list       -> renvoie la liste des commandes entrees.
//   Reste a faire :
//      option = get num    -> recupere le nieme element relatif.
//      option = dim n      -> dimensionne le buffer.
//      option = clear      -> reinitialise le buffer.
//

#define HISTORYCLASS CHistoryLC
HISTORYCLASS *History=NULL;

int CmdHistory(ClientData , Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];

   if(History==NULL) History = new HISTORYCLASS;

   if(argc<2||argc>3) {
      sprintf(ligne,"Usage: %s add|before|after|synchro|list",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if(strcmp(argv[1],"add")==0) {
      if(argc!=3) {
         sprintf(ligne,"Usage: %s %s chaine",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         History->Add(argv[2]);
      }
   } else if(strcmp(argv[1],"before")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         Tcl_SetResult(interp,History->Backward(),TCL_VOLATILE);
      }
   } else if(strcmp(argv[1],"after")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         Tcl_SetResult(interp,History->Forward(),TCL_VOLATILE);
      }
   } else if(strcmp(argv[1],"synchro")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         History->Synchro();
      }
   } else if(strcmp(argv[1],"list")==0) {
      if(argc!=2) {
         sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         int i = History->List(NULL);
         char *s = (char*)calloc(i,sizeof(char));
         History->List(s);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(s);
      }
   }
   return TCL_OK;
}

int CmdLibstdId(ClientData , Tcl_Interp *interp, int , char *)
{
   Tcl_SetResult(interp,(char*)__DATE__,TCL_VOLATILE);
   return TCL_OK;
}


void audelaInit(Tcl_Interp *interp)
{
   //char s[256];
   //LOGDEBUG("interp=0x%p\n",interp);

   // Chargement de libtt
   //load_libtt();

   // libstd.cpp : Fonctions de traitement par lots
   Tcl_CreateCommand(interp,"libstd_id",(Tcl_CmdProc *)CmdLibstdId,NULL,NULL);
   Tcl_CreateCommand(interp,"historik",(Tcl_CmdProc *)CmdHistory,NULL,NULL);

   // tt.cpp : Fonctions de traitement par lots
   //Tcl_CreateCommand(interp,"ttscript",(Tcl_CmdProc *)CmdTtScript3,NULL,NULL);
   //Tcl_CreateCommand(interp,"ttscript2",(Tcl_CmdProc *)CmdTtScript2,NULL,NULL);

   //Tcl_CreateCommand(interp,"fits2colorjpeg",(Tcl_CmdProc *)CmdFits2ColorJpg,NULL,NULL);
   //Tcl_CreateCommand(interp,"fitsheader",(Tcl_CmdProc *)CmdFitsHeader,NULL,NULL);
   //Tcl_CreateCommand(interp,"fitsconvert3d",(Tcl_CmdProc *)CmdFitsConvert3d,NULL,NULL);

   Tcl_CreateCommand(interp,"getbitapp",(Tcl_CmdProc *)CmdGetBitApp,NULL,NULL);
   Tcl_CreateCommand(interp,"getclicks",(Tcl_CmdProc *)CmdTestGetClicks,NULL,NULL);
   Tcl_CreateCommand(interp,"hostaddress",(Tcl_CmdProc *)CmdHostaddress,NULL,NULL);
   Tcl_CreateCommand(interp,"ping",(Tcl_CmdProc *)CmdPing,NULL,NULL);
   Tcl_CreateCommand(interp,"setip",(Tcl_CmdProc *)CmdSetIP,NULL,NULL);

   // file_tcl.cpp : Gestion des fichiers RAW
   Tcl_CreateCommand(interp,"cfa2rgb",(Tcl_CmdProc *)CmdCfa2rgb,NULL,NULL);

   // autoguider_tcl.cpp : 
   Tcl_CreateCommand(interp,"guide",(Tcl_CmdProc *)CmdGuide,NULL,NULL);

   // Access aux port parallele et serie pour Windows NT, 2000, XP
   Tcl_CreateCommand(interp,"porttalk",(Tcl_CmdProc *)CmdPortTalk,NULL,NULL);

   // pool_tcl.cpp : Gestion de la liste des buffers
   Tcl_CreateCommand(interp,"::buf::create",(Tcl_CmdProc *)tclBufferCreate, NULL, NULL);
   Tcl_CreateCommand(interp,"::buf::delete",(Tcl_CmdProc *)tclBufferDelete, NULL,NULL);
   Tcl_CreateCommand(interp,"::buf::list",(Tcl_CmdProc *)tclBufferList, NULL,NULL);

   // pool_tcl.cpp : Gestion de la liste des cameras
   Tcl_CreateCommand(interp,"::cam::create",(Tcl_CmdProc *)tclCameraCreate, NULL,NULL);
   Tcl_CreateCommand(interp,"::cam::delete",(Tcl_CmdProc *)tclCameraDelete, NULL,NULL);
   Tcl_CreateCommand(interp,"::cam::list",  (Tcl_CmdProc *)tclCameraList,  NULL,NULL);
   Tcl_CreateCommand(interp, "::cam::available", (Tcl_CmdProc *)tclCameraAvailable, NULL, NULL);
   
   // pool_tcl.cpp : Gestion de la liste des telescopes
   Tcl_CreateCommand(interp,"::tel::create",(Tcl_CmdProc *)tclTelescopeCreate,NULL,NULL);
   Tcl_CreateCommand(interp,"::tel::delete",(Tcl_CmdProc *)tclTelescopeDelete,NULL,NULL);
   Tcl_CreateCommand(interp,"::tel::list",(Tcl_CmdProc *)tclTelescopeList,NULL,NULL);
   
   // pool_tcl.cpp : Gestion de la liste des liaisons
   Tcl_CreateCommand(interp,"::link::create",(Tcl_CmdProc *)tclLinkCreate,NULL,NULL);
   Tcl_CreateCommand(interp,"::link::delete",(Tcl_CmdProc *)tclLinkDelete,NULL,NULL);
   Tcl_CreateCommand(interp,"::link::list",(Tcl_CmdProc *)tclLinkList,NULL,NULL);
   Tcl_CreateCommand(interp,"::link::available",(Tcl_CmdProc *)tclLinkAvailableList,NULL,NULL);

}

//------------------------------------------------------------------------------
// Point d'entree de libaudela en tant que librairie TCL.
//
#if defined(OS_WIN)
extern "C" __declspec(dllexport) int __cdecl Tclaudela_Init(Tcl_Interp*interp)
#else
extern "C" __attribute__((visibility ("default"))) int Tclaudela_Init(Tcl_Interp*interp)
#endif
{
   char *s;

   if(interp==NULL) return TCL_ERROR;

   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,(char*)"Tcl Stubs initialization failed in libaudela.",TCL_STATIC);
      return TCL_ERROR;
   }
   if((s=(char*)Tcl_GetVar(interp,"audelog_filename",0))==NULL) s = default_log_filename;
   //libstd_log_filename = (char*)calloc(sizeof(char),strlen(s)+1);
   //strcpy(libstd_log_filename,s);

   
   //LOGDEBUG("-----------------------\n");
   //LOGDEBUG("Entering libstd library\n");

   audelaInit(interp);

   //LOGDEBUG("End of libstd init.\n");

   return TCL_OK;
}

