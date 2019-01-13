/* libtel.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

// $Id: libtel.cpp,v 1.2 2010-09-05 19:05:14 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#if defined(_MSC_VER)
#include <sys/timeb.h>
#include <time.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "telescop.h"

#include <libtel/libtel.h>
#include <libtel/util.h>
#include "teltcl.h"
#include "telcmd.h"

/* valeurs des structures tel_* privees */

char *tel_ports[] = {
   "com1",
   "com2",
   "com3",
   "com4",
   "com5",
   "com6",
   "com7",
   "com8",
   NULL
};

// fonctions appelees depuis libtel.c
struct tel_drv_t TEL_DRV = {  
   default_tel_sendPulseDuration, 
   default_tel_sendPulseDistance, 
   default_tel_getRadecGuidingState,
   default_tel_setRadecGuidingState,
   default_tel_getRadecPulseRate,
   default_tel_setRadecPulseRate
};

#if !defined(OS_WIN)
#define MB_OK 1
void MessageBox(void *handle, char *msg, char *title, int bof)
{
   fprintf(stderr,"%s: %s\n",title,msg);
}
#endif

#define BP(i) MessageBox(NULL,#i,"Libtel",MB_OK)

void logConsole(struct telprop *tel, char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   int result;
   
   // j'assemble la commande 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
   va_end (mkr);

   sprintf(ligne,"::thread::send -async %s { ::console::disp \"Telescope: %s\" } " , tel->mainThreadId, message); 
   result = Tcl_Eval(tel->interp,ligne);
}

/*
 * Prototypes des differentes fonctions d'interface Tcl/Driver. Ajoutez les
 * votres ici.
 */
/* === Common commands for all telescopes ===*/
int cmdTelCreate(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int cmdTel(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);

static struct telprop *telprops = NULL;

/*
 * Point d'entree de la librairie, appelle lors de la commande Tcl load.
 */
#if defined(OS_WIN)
int __cdecl TEL_ENTRYPOINT (Tcl_Interp *interp)
#else
extern "C" int TEL_ENTRYPOINT (Tcl_Interp *interp)
#endif
{
   struct cmditem *cmd;
   int i;

   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in " TEL_LIBNAME " (" TEL_LIBVER ").",TCL_VOLATILE);
      return TCL_ERROR;
   }

   Tcl_CreateCommand(interp,TEL_DRIVNAME,(Tcl_CmdProc *)cmdTelCreate,NULL,NULL);
   Tcl_PkgProvide(interp,TEL_LIBNAME,TEL_LIBVER);

   for(i=0,cmd=cmdlist;cmd->cmd!=NULL;cmd++,i++);

   return TCL_OK;
}

int cmdTelCreate(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[])
{
   char s[2048];
   int telno, err;
   struct telprop *tel, *tell;

#ifdef CMD_TEL_SELECT
   // ces commandes ne sont utilisables que par les telescopes qui
   // sont compilés avec l'option CMD_TEL_SELECT
   if ((argc ==2 || argc == 3) && strcmp(argv[1],"select") == 0) {
      return cmdTelSelect(clientData, interp, argc, argv);
   }
   if (argc == 3 && strcmp(argv[1],"setup") == 0) {
      return cmdTelSetupDialog(clientData, interp, argc, argv);
   }
#endif

   if(argc<3) {
      sprintf(s,"%s driver port ?options?",argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      
      const char *threaded;

      /*
       * On initialise le telescope sur le port. S'il y a une erreur, alors on
       * renvoie le message qui va bien, en supprimant la structure cree.
       * Si OK, la commande TCL est creee d'apres l'argv[1], et on garde
       * trace de la structure creee.
       */
      tel = (struct telprop*)calloc(1,sizeof(struct telprop));
      strcpy(tel->msg,"");
      
      // verify the platform 
      const char *platform;
      if((platform=Tcl_GetVar(interp,"tcl_platform(os)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdTelCreate: Global variable tcl_platform(os) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ((strcmp(platform,"Windows 95")==0)||(strcmp(platform,"Windows 98")==0)||(strcmp(platform,"Windows NT")==0)||(strcmp(platform,"Linux")==0)) {
         tel->authorized=1;
      } else {
         tel->authorized=0;
      }

      if((threaded=Tcl_GetVar(interp,"tcl_platform(threaded)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdTelCreate: Global variable tcl_platform(threaded) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      
      // je recupere l'identifiant du thread principal qui est dans le dernier argument
      strcpy(tel->mainThreadId, argv[argc-1]);
      // je recupere l'identitifiant du thread du telescope
      Tcl_Eval(interp, "thread::id");
      strcpy(tel->telThreadId, Tcl_GetStringResult(interp));

      tel->interp=interp;
     
      /* --- internal init ---*/
      if((err=tel_init_common(tel,argc,argv))!=0) {
         Tcl_SetResult(interp,"init error",TCL_VOLATILE);
         free(tel);
         return TCL_ERROR;
      }
      /* --- external init defined in the telescop.c file ---*/
      if((err=tel_init(tel,argc,(char**)argv))!=0) {
         Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
         free(tel);
         return TCL_ERROR;
      }
      /* --- record the telescope as a new AudeLA object ---*/
      sscanf(argv[1],"tel%d",&telno);
      tel->telno = telno;
      tell = telprops;
      if(tell==NULL) {
         telprops = tel;
      } else {
         while(tell->next!=NULL) tell = tell->next;
         tell->next = tel;
      }
      Tcl_CreateCommand(interp,argv[1],(Tcl_CmdProc *)cmdTel,(ClientData)tel,NULL);

   }
   return TCL_OK;
}

int cmdTel(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[])
{
   char s[1024],ss[50];
   int retour = TCL_OK,k;
   struct cmditem *cmd;
   if(argc==1) {
      sprintf(s,"%s choose sub-command among ",argv[0]);
      k=0;
      while (cmdlist[k].cmd!=NULL) {
         sprintf(ss," %s",cmdlist[k].cmd);
         strcat(s,ss);
         k++;
      }
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      struct telprop *tel;
      tel = (struct telprop *)clientData;

      for(cmd=cmdlist;cmd->cmd!=NULL;cmd++) {
         if(strcmp(cmd->cmd,argv[1])==0) {
            retour = (*cmd->func)(clientData, interp, argc, argv);
            break;
         }
      }
      if(cmd->cmd==NULL) {
         sprintf(s,"%s %s : sub-command not found among ",argv[0], argv[1]);
         k=0;
         while (cmdlist[k].cmd!=NULL) {
            sprintf(ss," %s",cmdlist[k].cmd);
            strcat(s,ss);
            k++;
         }
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
}

/* ========================= */
/* === Utility functions === */
/* ========================= */

/*
 * GetCurrentFITSDate(char s[23])
 *
 */
void libtel_GetCurrentFITSDate(Tcl_Interp *interp, char s[23])
{
   int clock=0;
	/*
#if defined(_Windows)
   // cas special a Borland Builder pour avoir les millisecondes
   struct time t1;
   struct date d1;
   clock=1;
   getdate(&d1);
   gettime(&t1);
   sprintf(s,"%04d-%02d-%02dT%02d:%02d:%02d.%02d",
      d1.da_year,d1.da_mon,d1.da_day,t1.ti_hour,t1.ti_min,t1.ti_sec,t1.ti_hund);
#endif
#if defined(_MSC_VER)
   // cas special a Microsoft C++ pour avoir les millisecondes
   struct _timeb timebuffer;
   char message[50];
   time_t ltime;
   clock=1;
   _ftime( &timebuffer );
   time( &ltime );
   strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
   sprintf(s,"%s.%02d",message,(int)(timebuffer.millitm/10));
#endif
	*/
   if (clock==0) {
		// This following line gives the millisecond date for any OS
		Tcl_Eval(interp,"set t [clock milliseconds] ; format \"%s.%03d\" [clock format [expr {$t / 1000}] -format \"%Y-%m-%dT%H:%M:%S\" -timezone :UTC] [expr {$t % 1000}]");
      //Tcl_Eval(interp,"clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.00\"");
      strcpy(s,Tcl_GetStringResult(interp));
   }
}

/*
* Retourne l'heure UTC
*/
void libtel_GetCurrentUTCDate(Tcl_Interp *interp, char *s)
{
   //Tcl_Eval(interp,"clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S\" -timezone :UTC");
	Tcl_Eval(interp,"set t [clock milliseconds] ; format \"%s.%03d\" [clock format [expr {$t / 1000}] -format \"%Y-%m-%dT%H:%M:%S\" -timezone :UTC] [expr {$t % 1000}]");
   strcpy(s,Tcl_GetStringResult(interp));
}
int libtel_Getradec(Tcl_Interp *interp,char *tcllist,double *ra,double *dec)
/*
 * Decode a Tcl list of two elements -> ra,dec (in float degrees)
 */
{
   char ligne[256];
   const char **listArgv;
   int listArgc;
   int result = TCL_OK;
   if(Tcl_SplitList(interp,tcllist,&listArgc,&listArgv)!=TCL_OK) {
      sprintf(ligne,"Angle struct not valid: must be {angle_ra angle_dec}");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(listArgc!=2) {
      sprintf(ligne,"Angle struct not valid: must be {angle_ra angle_dec}");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   if (result==TCL_OK) {
      sprintf(ligne,"mc_angle2deg %s",listArgv[0]);
      if (Tcl_Eval(interp,ligne)==TCL_OK) {
         *ra=atof(Tcl_GetStringResult(interp));
      }
      sprintf(ligne,"mc_angle2deg %s 90",listArgv[1]);
      if (Tcl_Eval(interp,ligne)==TCL_OK) {
         *dec=atof(Tcl_GetStringResult(interp));
      }
   }
   Tcl_Free((char*)listArgv);
   return result;
}

/* ================================================================= */
/* === Obsolete functions but used for old version compatibility === */
/* ================================================================= */

int cmdTelGoto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[1024];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec goto ");
   if (argc>=3) {
      strcat(ligne,argv[2]);
   }
   for (int i=2;i<argc;i++) {
      strcat(ligne," {");
      strcat(ligne,argv[i]);
   strcat(ligne,"}");
   }
   result=Tcl_Eval(interp,ligne);
   return result;
}

int cmdTelCoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   /*
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   result=tel_radec_coord(tel,ligne);
   if (result==0) {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result=TCL_OK;
   } else {
      Tcl_SetResult(interp,"",TCL_VOLATILE);
      result = TCL_ERROR;
   }
   */
   sprintf(ligne,"%s radec %s",argv[0],argv[1]);
   result=Tcl_Eval(interp,ligne);
   return result;
}

int cmdTelStop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec stop ");
   if (argc>=3) {
      strcat(ligne,argv[2]);
   }
   result=Tcl_Eval(interp,ligne);
   return result;
}

int cmdTelSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=3) {
      tel->speed=1.;
      Tcl_SetResult(interp,"slew",TCL_VOLATILE);
      if (strcmp(argv[2],"guide")==0) {
         tel->speed=0.25;
         Tcl_SetResult(interp,argv[2],TCL_VOLATILE);
      }
      if (strcmp(argv[2],"center")==0) {
         tel->speed=0.5;
         Tcl_SetResult(interp,argv[2],TCL_VOLATILE);
      }
      if (strcmp(argv[2],"find")==0) {
         tel->speed=0.75;
         Tcl_SetResult(interp,argv[2],TCL_VOLATILE);
      }
   } else {
      Tcl_SetResult(interp,"slew",TCL_VOLATILE);
      if (tel->speed<=0.25) {
         Tcl_SetResult(interp,"guide",TCL_VOLATILE);
      } else if ((tel->speed>0.25)&&(tel->speed<=0.5)) {
         Tcl_SetResult(interp,"center",TCL_VOLATILE);
      } else if ((tel->speed>0.5)&&(tel->speed<=0.75)) {
         Tcl_SetResult(interp,"find",TCL_VOLATILE);
      }
   }
   return TCL_OK;
}

int cmdTelMove(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[1024],ligne2[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec move ");
   strcpy(ligne2,"none");
   if (argc>=3) {
      strcpy(ligne2,argv[2]);
   }
   strcat(ligne,ligne2);
   sprintf(ligne2,"%s %f",ligne,tel->speed);
   result=Tcl_Eval(interp,ligne2);
   return result;
}

int cmdTelMatch(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=1) {
      strcpy(ligne,argv[0]);
   }
   strcat(ligne," radec init {");
   if (argc>=3) {
      strcat(ligne,argv[2]);
   }
   strcat(ligne,"}");
   result=Tcl_Eval(interp,ligne);
   return result;
}

/* ========================== */
/* === Official functions === */
/* ========================== */

int cmdTelAlignmentMode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   Tcl_SetResult(interp,tel->alignmentMode,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelRefraction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;
   struct telprop *tel;
   char ligne[256];
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?0|1?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      sprintf(ligne,"%d", tel->refractionCorrection);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_OK;
   } else {
      int refractionFlag = 0; 
      if(Tcl_GetInt(interp,argv[2],&refractionFlag)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?0|1?\ninvalid value '%s'. Must be 0 or 1",argv[0],argv[1],argv[2]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if ( refractionFlag != 0 && refractionFlag != 1 ) {
            sprintf(ligne,"Usage: %s %s ?0|1?\ninvalid value '%s'. Must be 0 or 1",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            tel->refractionCorrection = refractionFlag;
            Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         }
      }
   }
   return result;
}

int cmdTelDrivername(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   sprintf(ligne,"%s {%s}",TEL_LIBNAME,__DATE__);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelClose(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   tel_close(tel);

   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelName(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel_ini[tel->index_tel].name);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelProtocol(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel_ini[tel->index_tel].protocol);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelProduct(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel_ini[tel->index_tel].product);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelPort(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel->portname);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelChannel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%s",tel->channel);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelTestCom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   sprintf(ligne,"%d",tel_testcom(tel));
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

/* --- Action commands ---*/

int cmdTelFoclen(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   double d;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?focal_length_(meters)?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      tel = (struct telprop*)clientData;
      sprintf(ligne,"%f",tel->foclen);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      pb=0;
      if(Tcl_GetDouble(interp,argv[2],&d)!=TCL_OK) {
         pb=1;
      }
      if (pb==0) {
         if (d<=0.0) {
            pb=1;
         }
      }
      if (pb==1) {
         sprintf(ligne,"Usage: %s %s ?focal_length_(meters)?\nfocal_length : must be an float > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         tel = (struct telprop*)clientData;
         tel->foclen = d;
         sprintf(ligne,"%f",tel->foclen);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

int cmdTelDate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],ligne2[256];
   int result = TCL_OK;
   struct telprop *tel;
   int y,m,d,h,min;
   double s;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?Date?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      tel = (struct telprop*)clientData;
      /* returns a type hmdhms list */
      tel_date_get(tel,ligne);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      tel = (struct telprop*)clientData;
      sprintf(ligne,"mc_date2ymdhms {%s}",argv[2]);
      if (Tcl_Eval(interp,ligne)==TCL_OK) {
         strcpy(ligne2,Tcl_GetStringResult(interp));
      } else {
         strcpy(ligne2,"2000 1 1 0 0 0.0");
      }
      sprintf(ligne,"lindex {%s} 0",ligne2);
      Tcl_Eval(interp,ligne);
      y=(int)atoi(Tcl_GetStringResult(interp));
      sprintf(ligne,"lindex {%s} 1",ligne2);
      Tcl_Eval(interp,ligne);
      m=(int)atoi(Tcl_GetStringResult(interp));
      sprintf(ligne,"lindex {%s} 2",ligne2);
      Tcl_Eval(interp,ligne);
      d=(int)atoi(Tcl_GetStringResult(interp));
      sprintf(ligne,"lindex {%s} 3",ligne2);
      Tcl_Eval(interp,ligne);
      h=(int)atoi(Tcl_GetStringResult(interp));
      sprintf(ligne,"lindex {%s} 4",ligne2);
      Tcl_Eval(interp,ligne);
      min=(int)atoi(Tcl_GetStringResult(interp));
      sprintf(ligne,"lindex {%s} 5",ligne2);
      Tcl_Eval(interp,ligne);
      s=(double)atof(Tcl_GetStringResult(interp));
      tel_date_set(tel,y,m,d,h,min,s);
      /* returns a type hmdhms list */
      tel_date_get(tel,ligne);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelHome(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],ew[3];
   int result = TCL_OK;
   struct telprop *tel;
   double longitude,latitude,altitude;
   if((argc!=2)&&(argc!=3)&&(argc!=4)) {
      sprintf(ligne,"Usage: %s %s ?{GPS long e|w lat alt}? ?{-name xxx}",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      tel = (struct telprop*)clientData;
      /* returns a type {degrees degrees} list */
      /* result is a list : GPS long(deg) e|w lat(deg) alt(m) */
      tel_home_get(tel,ligne);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      // je memorise la position pour eviter d'envoyer une nouvelle requete au
      // telescope chaque fois qu'on utilise "tel radec coord" ou "tel radec goto"
      strcpy(tel->homePosition,ligne);
   } else {
      tel = (struct telprop*)clientData;
      if ( strcmp(argv[2],"name") == 0) {
         if ( argc == 3) {
            // je retoune le nom du site
            Tcl_SetResult(interp,tel->homeName,TCL_VOLATILE);
         } else {
            // je memorise le nom du site
            strncpy( tel->homeName, argv[3], sizeof(tel->homeName));
            Tcl_SetResult(interp,tel->homeName,TCL_VOLATILE);
         }
      } else {
         // je memorise la position
         sprintf(ligne,"lindex {%s} 1",argv[2]);
         Tcl_Eval(interp,ligne);
         longitude=(double)atof(Tcl_GetStringResult(interp));
         sprintf(ligne,"string toupper [lindex {%s} 2]",argv[2]);
         Tcl_Eval(interp,ligne);
         if (strcmp(Tcl_GetStringResult(interp),"W")==0) {
            strcpy(ew,"w");
         } else {
            strcpy(ew,"e");
         }
         sprintf(ligne,"lindex {%s} 3",argv[2]);
         Tcl_Eval(interp,ligne);
         latitude=(double)atof(Tcl_GetStringResult(interp));
         sprintf(ligne,"lindex {%s} 4",argv[2]);
         Tcl_Eval(interp,ligne);
         altitude=(double)atof(Tcl_GetStringResult(interp));
         tel_home_set(tel,longitude,ew,latitude,altitude);
         // je memorise la position pour eviter d'envoyer une nouvelle requete au
         // telescope chaque fois qu'on utilise "tel radec coord" ou "tel radec goto" 
         sprintf(tel->homePosition,"GPS %f %s %+f 0",longitude,ew,latitude);
         // attention : la fonction tel_home_get() de certains telescope (ex: FS2) retourne la valeur de 
         // tel->homePosition pour pallier à l'absence de commande pour lire la longitude et la latitude.
         // il est donc important d'appeler tel_home_get() apres avoir valorise tel->homePosition
         tel_home_get(tel,ligne);
         strcpy(tel->homePosition,ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

int cmdTelRaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],texte[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   char radec_model_coefficients[1024];
   char radec_model_symbols[255];
	double ha;
	int revert;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state|model|survey|guiding|pulse? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         char inputEquinox[20];
         strcpy(inputEquinox,"J2000.0");
         char mountside[20];
         strcpy(mountside,"auto");
         if (argc>=4) {
            for (k=4;k<=argc-1;k++) {
               if (strcmp(argv[k],"-equinox")==0) {
                  // je copie la valeur en verifiant a ne pas depasser la taille sizeof(inputEquinox)
                  char tempEquinox[20];
                  strncpy(tempEquinox,argv[k+1],sizeof(tempEquinox) -1);
                  tempEquinox[sizeof(tempEquinox) -1]=0;
                  // je convertis en majuscule
                  libtel_strupr(tempEquinox, inputEquinox);
               }
               if (strcmp(argv[k],"-mountside")==0) {
                  strncpy(mountside,argv[k+1], sizeof(mountside));
               }
            }
				strcpy(tel->mountside,mountside);
				/* - call the pointing model if exists -*/
            if (strcmp(tel->model_cat2tel,"")==0) {
               // je convertis les coordonnes en double
               libtel_Getradec(interp,argv[3],&tel->ra0,&tel->dec0);
               if ( result == TCL_OK) {
                  // je recupere la date courante TU
                  //result =  mytel_tcleval(tel,"clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC");
                  result =  mytel_tcleval(tel,"set t [clock milliseconds] ; format \"%s.%03d\" [clock format [expr {$t / 1000}] -format \"%Y-%m-%dT%H:%M:%S\" -timezone :UTC] [expr {$t % 1000}]");
                  if ( result == TCL_OK) {
                     char utDate[30];
                     char refractionOption[15];
                     strncpy(utDate, Tcl_GetStringResult(interp),sizeof(utDate)); 
                     if ( tel->refractionCorrection == 1 ) {
                        // mc_tel2cat doit pas corriger la refraction si la monture corrige la refraction.
                        strcpy(refractionOption, "-refraction 0");
                     } else {
                        strcpy(refractionOption,"");
                     }

                     // usage mc_hip2tel $hiprecord $date $home $pressure $temperature $modpoi_symbols $modpoi_coefs
                     // avec hipRecord = 
                     //   0 id   : identifiant hyparcos de l'etoile (nombre entier), si non utilisé =0  
                     //   1 mag  : magnitude , si non utilisé = 0.0  (nombre décimal)
                     //   2 ra   : ascension droite (en degrés décimaux)
                     //   3 dec  : declinaison (en degrés décimaux)
                     //   4 equinox : date de l'equinoxe , date du jour=now, ou foramt ISO8601
                     //   5 epoch   : date de l'epoque d'origine des mouvements propres , inutilise si mura et mudec sont nuls
                     //   6 mura : mouvement propre ra (en degré par an) 
                     //   7 mudec : mouvement propre dec (en degré par an)
                     //   8 plx   : parallaxe , =0 si inconnu (en mas=milliseconde d'arc)s

                     // ATTENTION: changement non documenté de hip2tel depuis le 08/06/2010 
                     // si identifiant hyparcos = 0 , alors 
                     //   0 id = indicateur type_liste 1
                     //   1 ha : angle horaire ?
                     //   2 dec : declinaison ?
                     //   3 ??  : parametre obligatoire non utilisé
                     //   4 ??  : parametre obligatoire non utilisé
                     //   5 ??  : parametre obligatoire non utilisé
                     //   6 ??  : parametre obligatoire non utilisé
                     //   7 ??  : parametre obligatoire non utilisé
                     //   8 ??  : parametre obligatoire non utilisé

                     if (tel->radec_model_enabled == 1 ) {
								libtel_altitude2tp(tel);
								// Cas d'un modele de pointage defini par 
								// tel1 radec model -symbols $symbols -coefficients $coefficients -enabled 1
								if ((tel->mmechanics==MS_GERMAN_LIKE)&&(strcmp(tel->radec_model_eastern_symbols,"")!=0)&&(strcmp(tel->radec_model_western_symbols,"")!=0)) {
									// special case of German like mounts with two pointing models
									// test the eastern model (=tube located on the eastern peer side)
									strcpy(radec_model_coefficients,tel->radec_model_eastern_coefficients);
									strcpy(radec_model_symbols,tel->radec_model_eastern_symbols);
									sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } {%s} {%s} %d %d {%s} {%s} %s", tel->ra0, tel->dec0, inputEquinox,utDate, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients,refractionOption);
	                        result =  mytel_tcleval(tel,ligne);
									if (result == TCL_OK) {
										const char **listArgv;
										int listArgc;
										// je recupere les coordonnees corrigees a partir des index 10 et 11 de la liste retournee par mc_hip2tel
										result = Tcl_SplitList(tel->interp,Tcl_GetStringResult(tel->interp),&listArgc,&listArgv) ;
										if(result == TCL_OK) {
											if ( listArgc >= 13 ) {
												ha = atof ( listArgv[12] ); 
												if (ha>180) { ha-=360; }
											}
										} else {
											result = TCL_ERROR;
										} 
										Tcl_Free((char*)listArgv);
									}
									// --- test the limit of back side
									// revert=0 for ptube=PT_EAST
									// revert=1 for ptube=PT_WEST
									if (ha>tel->halim_tube_east) {
										// The tube will be always in position East
										revert = 0; 
									} else if (ha<tel->halim_tube_west) {
										// The tube will be always in position West
										revert = 1;
									} else {
										// We are in the range [halim_tube_west ; halim_tube_east]
										// The tube will stay at the initial tube position.
										tel_get_position_tube(tel);
										if (tel->ptube==PT_EAST) {
											revert = 0;
										} else {
											revert = 1;
										}
									}
									if (revert==1) {
										// The eastern test was not good.
										// Choice the western model (=tube located on the western peer side)
										strcpy(radec_model_coefficients,tel->radec_model_western_coefficients);
										strcpy(radec_model_symbols,tel->radec_model_western_symbols);
									}
								} else {
									strcpy(radec_model_coefficients,tel->radec_model_coefficients);
									strcpy(radec_model_symbols,tel->radec_model_symbols);
								}
                        // correction avec le modele de pointage 
                        sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } {%s} {%s} %d %d {%s} {%s} %s", 
                           tel->ra0, tel->dec0, inputEquinox,
                           utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           radec_model_symbols, radec_model_coefficients,
                           refractionOption);
                        if ( tel->consoleLog >= 1 ) {
                           logConsole(tel, "radec goto: %s\n", ligne);
                        }
                        result =  mytel_tcleval(tel,ligne);

                        if (result == TCL_OK) {
                           const char **listArgv;
                           int listArgc;

                           // je recupere les coordonnees corrigees a partir des index 10 et 11 de la liste retournee par mc_hip2tel
                           result = Tcl_SplitList(tel->interp,Tcl_GetStringResult(tel->interp),&listArgc,&listArgv) ;
                           if(result == TCL_OK) {
                              if ( listArgc >= 11 ) {
                                 tel->ra0 = atof ( listArgv[10] ); 
                                 tel->dec0 = atof ( listArgv[11] ); 
                              } else { 
                                 sprintf(ligne,"radec goto error : mc_hip2tel doesn't return { ra0 dec0 } , returned value=%s",Tcl_GetStringResult(tel->interp));
                                 Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                                 result = TCL_ERROR;
                              }
                           } else {
                              // rien a faire car la fonction Tcl_SplitList a deja renseigne les message d'erreur
                              result = TCL_ERROR;
                           } 
                           Tcl_Free((char*)listArgv);
                        }
                     } else {
                        // si les coordonnées sont founies en J2000 et si la monture utilise l'equinoxe NOW                         
                        if ( strcmp( inputEquinox, "J2000.0" )==0 && strcmp(tel->equinox,"NOW")== 0 ) { 
                        // je convertis les coordonnees a la date du jour, sans appliquer de modele de pointage
                        //  mc_hip2tel {id mag ra dec equinox epoch mura mudec plx } dateTu home pressure temperature
                        // ATTENTION : il ne faut pas utiliser "now" pour la date (ou bien mettre l'ordinateur a l'heure TU)
								libtel_altitude2tp(tel);
                        sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } { %s } { %s } %d %d %s", 
                           tel->ra0, tel->dec0, inputEquinox, 
                           utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature,
                           refractionOption);
                     if ( tel->consoleLog >= 1 ) {
                        logConsole(tel, "radec goto: %s\n", ligne);
                     }
                     result =  mytel_tcleval(tel,ligne);

                     if (result == TCL_OK) {
                        const char **listArgv;
                        int listArgc;

                        // je recupere les coordonnees corrigees a partir des index 10 et 11 de la liste retournee par mc_hip2tel
                        result = Tcl_SplitList(tel->interp,Tcl_GetStringResult(tel->interp),&listArgc,&listArgv) ;
                        if(result == TCL_OK) {
                           if ( listArgc >= 11 ) {
                              tel->ra0 = atof ( listArgv[10] ); 
                              tel->dec0 = atof ( listArgv[11] ); 
                           } else { 
                              sprintf(ligne,"radec goto error : mc_hip2tel doesn't return { ra0 dec0 } , returned value=%s",Tcl_GetStringResult(tel->interp));
                              Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                              result = TCL_ERROR;
                           }
                        } else {
                           // rien a faire car la fonction Tcl_SplitList a deja renseigne les message d'erreur
                           result = TCL_ERROR;
                        } 
                        Tcl_Free((char*)listArgv);
                     }
                        }
                     }
                     
                  } else {
                     // erreur de la commande clock format ...
                     strcpy(ligne,Tcl_GetStringResult(interp));
                  }
               } else {
                  // erreur de libtel_Getradec()
                  // rien a faire car la fonction libtel_Getradec a deja renseigne les message d'erreur
               }
            } else {
               // j'applique le modele de pointage avec la procedure modpoi_cat2tel du TCL
               // ========================================================================
               sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
               mytel_tcleval(tel,ligne);
               sprintf(ligne,"set libtel(radec) [%s {%s}]",tel->model_cat2tel,argv[3]);
               mytel_tcleval(tel,ligne);
               mytel_tcleval(tel,"set libtel(radec) $libtel(radec)");
               strcpy(ligne,Tcl_GetStringResult(interp));
               libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
               result = TCL_OK;
               /* - end of pointing model-*/
            }

            if ( result == TCL_OK)  {
					if ( tel_radec_init(tel) == 0 ) {
						Tcl_SetResult(interp,"",TCL_VOLATILE);
						result = TCL_OK;
					} else {
						Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
						result = TCL_ERROR;
					}
				}

         } else {
            sprintf(ligne,"Usage: %s %s init {angle_ra angle_dec} ?-equinox Date? ?-mountside auto|W|E?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         /* --- coord ---*/
         char outputEquinox[20];
         strcpy(outputEquinox,"NOW");                  
         // je lis les parametres optionnels
         for (k=3;k<=argc-1;k++) {
            if (strcmp(argv[k],"-equinox")==0) {
               // je copie la valeur en verifiant a ne pas depasser la taille sizeof(inputEquinox)
               char tempEquinox[20];
               strncpy(tempEquinox,argv[k+1],sizeof(tempEquinox) -1);
               tempEquinox[sizeof(tempEquinox) -1]=0;
               // je convertis en majuscule
               libtel_strupr(tempEquinox, outputEquinox);
            }
         }
         if ( strcmp(tel->model_tel2cat,"") == 0 ) {
            // je recupere les coordonnnees du telescope
            if ( tel_radec_coord(tel,texte) == 0 ) {
               char utDate[30];
               // il n'y a pas d'erreur, je traite les coordonnees
               if ( tel->consoleLog >= 1 ) {
                  logConsole(tel, "radec coord: telescope coord(now)=%s\n", texte);
               }
               //--- je convertis les coordonnees HMS,DMS en degres 
               if ( result == TCL_OK) {
                  sprintf(ligne,"list [mc_angle2deg [lindex {%s} 0]] [mc_angle2deg [lindex {%s} 1] 90]",texte, texte); 
                  if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                     sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
                     result = TCL_ERROR; 
                  } else {
                     strcpy(texte,Tcl_GetStringResult(interp));
                  } 
               }
               // je recupere la date courante TU
               result =  mytel_tcleval(tel,"set t [clock milliseconds] ; format \"%s.%03d\" [clock format [expr {$t / 1000}] -format \"%Y-%m-%dT%H:%M:%S\" -timezone :UTC] [expr {$t % 1000}]");
               // result = mytel_tcleval(tel,"clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC");
               if ( result == TCL_OK) {
                  char refractionOption[15];
                  strncpy(utDate, Tcl_GetStringResult(interp),sizeof(utDate)); 
                  if ( tel->refractionCorrection == 1 ) {
                     // mc_tel2cat doit pas corriger la refraction si la monture corrige la refraction.
                     strcpy(refractionOption, "-refraction 0");
                  } else {
                     strcpy(refractionOption,"");
                  }

                  if (tel->radec_model_enabled == 1 ) {
                     if ( strcmp(outputEquinox,"NOW")==0 ) {
                        // j'applique le modèle de pointage inverse , pas de changement d'equinoxe a faire (modele seulement)
                        // usage: mc_tel2cat {12h 36d} EQUATORIAL 2010-06-03T20:10:00 {GPS 5 E 43 1230} 101325 290 { symbols } { values }
                        // ATTENTION : si on utilise utDate="now" , il faut d'abord mettre l'ordinateur a l'heure TU
								libtel_altitude2tp(tel);
                        sprintf(ligne, "mc_tel2cat {%s} {%s} {%s} {%s} %d %d {%s} {%s} -model_only 1 %s", 
                           texte, tel->alignmentMode, utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           tel->radec_model_symbols, tel->radec_model_coefficients,
                           refractionOption);
                     } else {
                        // j'applique le modèle de pointage inverse et je change d'equinoxe (equinoxe du jour -> J2000)
                        // usage: mc_tel2cat {12h 36d} EQUATORIAL 2010-06-03T20:10:00 {GPS 5 E 43 1230} 101325 290 { symbols } { values }
                        // ATTENTION : si on utilise utDate="now" , il faut d'abord mettre l'ordinateur a l'heure TU
								// Cas d'un modele de pointage defini par 
								// tel1 radec model -symbols $symbols -coefficients $coefficients -enabled 1
								if ((tel->mmechanics==MS_GERMAN_LIKE)&&(strcmp(tel->radec_model_eastern_symbols,"")!=0)&&(strcmp(tel->radec_model_western_symbols,"")!=0)) {
									// special case of German like mounts with two pointing models
									// Get hour angle to decide where is the tube
									// --- test the limit of back side
									tel_get_position_tube(tel);
									if (tel->ptube==PT_WEST) {
										// Choice the western model (=tube located on the western peer side)
										strcpy(radec_model_coefficients,tel->radec_model_western_coefficients);
										strcpy(radec_model_symbols,tel->radec_model_western_symbols);
									} else {
										// Choice the eastern model (=tube located on the eastern peer side)
										strcpy(radec_model_coefficients,tel->radec_model_eastern_coefficients);
										strcpy(radec_model_symbols,tel->radec_model_eastern_symbols);
									}
								} else {
									strcpy(radec_model_coefficients,tel->radec_model_coefficients);
									strcpy(radec_model_symbols,tel->radec_model_symbols);
								}
                        // correction avec le modele de pointage 
								libtel_altitude2tp(tel);
                        sprintf(ligne, "mc_tel2cat {%s} {%s} {%s} {%s} %d %d {%s} {%s} %s", 
                           texte, tel->alignmentMode, utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           radec_model_symbols, radec_model_coefficients,
                           refractionOption);
                     }
                     if ( tel->consoleLog >= 1 ) {
                        logConsole(tel, "radec coord: %s\n", ligne);
                     }
                     result = mytel_tcleval(tel,ligne);
                     if ( result == TCL_OK) {
                        // je convertis les angles en HMS et DMS
                        sprintf(ligne,"list [mc_angle2hms [lindex {%s} 0] 360 zero 0 auto string]  [mc_angle2dms [lindex {%s} 1] 90 zero 0 + string]",Tcl_GetStringResult(interp), Tcl_GetStringResult(interp)); 
                        if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                           sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
                           result = TCL_ERROR; 
                        } else {
                           // je copie les coordonnées dans la resultat de la commmande TCL
                           strcpy(ligne,Tcl_GetStringResult(interp));
                           result = TCL_OK; 
                        }
                     } else {
                        // erreur de mc_tel2cat 
                        strcpy(ligne, Tcl_GetStringResult(interp));
                        result = TCL_ERROR; 
                     }
                  } else {
                     if ( strcmp(outputEquinox,"NOW")==0 ) {
                        // pas de modele de pointage, pas de changement d'equinoxe
                        // je convertis les angles en HMS et DMS
                        sprintf(ligne,"list [mc_angle2hms [lindex {%s} 0] 360 zero 0 auto string]  [mc_angle2dms [lindex {%s} 1] 90 zero 0 + string]",texte, texte); 
                        if ( mytel_tcleval(tel,ligne) == TCL_OK) {
                           // je copie les coordonnées dans la resultat de la commmande TCL
                           strcpy(ligne,Tcl_GetStringResult(interp));
                           result = TCL_OK; 
                        } else {
                           sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
                           result = TCL_ERROR; 
                        }
                     } else {
                        // je convertis les coordonnes du telescope (equinox du jour) en coordonnes catalogue (equinox=J2000) 
                        // sans appliquer le modele de pointage (les parametres symbols et values sont absents) 
								libtel_altitude2tp(tel);                        
                        sprintf(ligne, "mc_tel2cat { %s } { %s } { %s } { %s } %d %d %s", 
                           texte, tel->alignmentMode, utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature,
                           refractionOption);
                        if ( tel->consoleLog >= 1 ) {
                           logConsole(tel, "radec coord: %s\n", ligne);
                        }
                        result = mytel_tcleval(tel,ligne);
                        if ( result == TCL_OK) {                               
                           // je convertis les angles en HMS et DMS
                           sprintf(ligne,"list [mc_angle2hms [lindex {%s} 0] 360 zero 0 auto string] [mc_angle2dms [lindex {%s} 1] 90 zero 0 + string]",Tcl_GetStringResult(interp), Tcl_GetStringResult(interp)); 
                           if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                              sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
                              result = TCL_ERROR; 
                           } else {
                              // je copie les coordonnées dans la resultat de la commmande TCL
                              strcpy(ligne,Tcl_GetStringResult(interp));
                              result = TCL_OK; 
                           }
                           /*
                           char raString[21];
                           char deString[21];
                           int scanResult = sscanf(Tcl_GetStringResult(interp),"%20s %20s",raString , deString);
                           if ( scanResult != 2 ) {
                              sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
                              result = TCL_ERROR; 
                           } else {
                              // je convertis les angles en HMS et DMS
                              sprintf(ligne,"mc_angle2hms %s 360 zero 0 auto string",raString); 
                              if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                                 sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
                                 result = TCL_ERROR; 
                              } else {
                                 strncpy(raString,Tcl_GetStringResult(interp),sizeof(raString)-1);
                                 sprintf(ligne,"mc_angle2dms %s 90 zero 0 + string",deString); 
                                 if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
                                    sprintf(tel->msg, "cmdTelRaDec %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
                                    result = TCL_ERROR; 
                                 } else {
                                    sprintf(ligne,"%s %s",raString, Tcl_GetStringResult(interp));
                                    result = TCL_OK; 
                                 } 
                              } 
                           }
                           */
                        } else {
                           // erreur de mc_tel2cat 
                           strcpy(ligne, Tcl_GetStringResult(interp));
                           result = TCL_ERROR; 
                        }                           
                     }
                  }
                  if ( result == TCL_OK ) {   
                     if ( tel->consoleLog >= 1 ) {
                        logConsole(tel, "radec coord: catalogue coord(%s): %s\n", outputEquinox,ligne);
                     }
                  }
               } else {
                  // erreur de clock format ...
                  strcpy(ligne, Tcl_GetStringResult(interp));
                  result = TCL_ERROR;
               }
            } else {
               // erreur de tel_radec_coord 
               strcpy(ligne, tel->msg);
               result = TCL_ERROR;
            }            
         } else {
            // j'applique le modele de pointage avec la procedure modpoi_tel2cat du TCL
            // ========================================================================
            if ( tel_radec_coord(tel,texte) == 0 ) {
					sprintf(ligne,"set libtel(radec) {%s}",texte);
					mytel_tcleval(tel,ligne);
					sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_tel2cat,texte);
					mytel_tcleval(tel,ligne);
					mytel_tcleval(tel,"set libtel(radec) $libtel(radec)");
                    // je copie les coordonnées dans la resultat de la commmande TCL
					strcpy(ligne,Tcl_GetStringResult(interp));
            } else {
               // erreur de tel_radec_coord 
               strcpy(ligne, tel->msg);
               result = TCL_ERROR;
            }            
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);

      } else if (strcmp(argv[2],"state")==0) {
         /* --- state ---*/
         tel_radec_state(tel,texte);
         Tcl_SetResult(interp,texte,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         /* --- goto ---*/
         char inputEquinox[20];
         strcpy(inputEquinox,"J2000.0");
         tel->active_backlash = 0;
         tel->radec_goto_blocking = 0;        
         if (argc>=4) {
            for (k=4;k<=argc-1;k++) {
               if (strcmp(argv[k],"-rate")==0) {
                  tel->radec_goto_rate=atof(argv[k+1]);
               }
               if (strcmp(argv[k],"-blocking")==0) {
                  tel->radec_goto_blocking=atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-backlash")==0) {
                  tel->active_backlash=atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-equinox")==0) {
                  strncpy(inputEquinox,argv[k+1], sizeof(inputEquinox));
               }
            }
            // j'affiche une trace des coordonnees du catalogue dans la console
            if ( tel->consoleLog >= 1 ) {
               logConsole(tel, "radec goto: catalog coord (%s): %s\n", inputEquinox, argv[3]);
            }
				// Cas d'un eventuel modele de pointage defini par 
				// tel1 radec model -symbols $symbols -coefficients $coefficients -enabled 1
            if (strcmp(tel->model_cat2tel,"")==0) {
               // je convertis les coordonnes en double
               libtel_Getradec(interp,argv[3],&tel->ra0,&tel->dec0);
               if ( result == TCL_OK) {
                  // je recupere la date courante TU
                  result =  mytel_tcleval(tel,"set t [clock milliseconds] ; format \"%s.%03d\" [clock format [expr {$t / 1000}] -format \"%Y-%m-%dT%H:%M:%S\" -timezone :UTC] [expr {$t % 1000}]");
                  //result =  mytel_tcleval(tel,"clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC");
                  if ( result == TCL_OK) {
                     char utDate[30];
                     char refractionOption[15];
                     strncpy(utDate, Tcl_GetStringResult(interp),sizeof(utDate)); 
                     if ( tel->refractionCorrection == 1 ) {
                        // mc_tel2cat doit pas corriger la refraction si la monture corrige la refraction.
                        strcpy(refractionOption, "-refraction 0");
                     } else {
                        strcpy(refractionOption,"");
                     }
                     // usage mc_hip2tel $hiprecord $date $home $pressure $temperature $modpoi_symbols $modpoi_coefs
                     // avec hipRecord = 
                     //   0 id   : identifiant hyparcos de l'etoile (nombre entier), si non utilisé =0  
                     //   1 mag  : magnitude , si non utilisé = 0.0  (nombre décimal)
                     //   2 ra   : ascension droite (en degrés décimaux)
                     //   3 dec  : declinaison (en degrés décimaux)
                     //   4 equinox : date de l'equinoxe , date du jour=now, ou foramt ISO8601
                     //   5 epoch   : date de l'epoque d'origine des mouvements propres , inutilise si mura et mudec sont nuls
                     //   6 mura : mouvement propre ra (en degré par an) 
                     //   7 mudec : mouvement propre dec (en degré par an)
                     //   8 plx   : parallaxe , =0 si inconnu (en mas=milliseconde d'arc)s

                     // ATTENTION: changement non documenté de hip2tel depuis le 08/06/2010 
                     // si identifiant hyparcos = 0 , alors 
                     //   0 id = indicateur type_liste 1
                     //   1 ha : angle horaire ?
                     //   2 dec : declinaison ?
                     //   3 ??  : parametre obligatoire non utilisé
                     //   4 ??  : parametre obligatoire non utilisé
                     //   5 ??  : parametre obligatoire non utilisé
                     //   6 ??  : parametre obligatoire non utilisé
                     //   7 ??  : parametre obligatoire non utilisé
                     //   8 ??  : parametre obligatoire non utilisé

                     if (tel->radec_model_enabled == 1 ) {
								libtel_altitude2tp(tel);
								// Cas d'un modele de pointage defini par 
								// tel1 radec model -symbols $symbols -coefficients $coefficients -enabled 1
								if ((tel->mmechanics==MS_GERMAN_LIKE)&&(strcmp(tel->radec_model_eastern_symbols,"")!=0)&&(strcmp(tel->radec_model_western_symbols,"")!=0)) {
									// special case of German like mounts with two pointing models
									// test the eastern model (=tube located on the eastern peer side)
									strcpy(radec_model_coefficients,tel->radec_model_eastern_coefficients);
									strcpy(radec_model_symbols,tel->radec_model_eastern_symbols);
									sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } {%s} {%s} %d %d {%s} {%s} %s", tel->ra0, tel->dec0, inputEquinox,utDate, tel->homePosition, tel->radec_model_pressure, tel->radec_model_temperature, tel->radec_model_symbols, tel->radec_model_coefficients,refractionOption);
	                        result =  mytel_tcleval(tel,ligne);
									if (result == TCL_OK) {
										const char **listArgv;
										int listArgc;
										// je recupere les coordonnees corrigees a partir des index 10 et 11 de la liste retournee par mc_hip2tel
										result = Tcl_SplitList(tel->interp,Tcl_GetStringResult(tel->interp),&listArgc,&listArgv) ;
										if(result == TCL_OK) {
											if ( listArgc >= 13 ) {
												ha = atof ( listArgv[12] ); 
												if (ha>180) { ha-=360; }
											}
										} else {
											result = TCL_ERROR;
										} 
										Tcl_Free((char*)listArgv);
									}
									// --- test the limit of back side									
									// tel->halim_tube_east = 30
									// tel->halim_tube_west = -25
									// revert=0 for ptube=PT_EAST
									// revert=1 for ptube=PT_WEST
									if (ha>tel->halim_tube_east) {
										// The tube will be always in position East
										revert = 0; 
									} else if (ha<tel->halim_tube_west) {
										// The tube will be always in position West
										revert = 1;
									} else {
										// We are in the range [halim_tube_west ; halim_tube_east]
										// The tube will stay at the initial tube position.
										tel_get_position_tube(tel);
										if (tel->ptube==PT_EAST) {
											revert = 0;
										} else {
											revert = 1;
										}
									}
									if (revert==1) {
										// The eastern test was not good.
										// Choice the western model (=tube located on the western peer side)
										strcpy(radec_model_coefficients,tel->radec_model_western_coefficients);
										strcpy(radec_model_symbols,tel->radec_model_western_symbols);
									}
								} else {
									strcpy(radec_model_coefficients,tel->radec_model_coefficients);
									strcpy(radec_model_symbols,tel->radec_model_symbols);
								}
                        // correction avec le modele de pointage 
                        sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } {%s} {%s} %d %d {%s} {%s} %s", 
                           tel->ra0, tel->dec0, inputEquinox,
                           utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           radec_model_symbols, radec_model_coefficients,
                           refractionOption);
                        if ( tel->consoleLog >= 1 ) {
                           logConsole(tel, "radec goto: %s\n", ligne);
                        }
                        result =  mytel_tcleval(tel,ligne);
                        if (result == TCL_OK) {
                           const char **listArgv;
                           int listArgc;
                           // je recupere les coordonnees corrigees a partir des index 10 et 11 de la liste retournee par mc_hip2tel
                           result = Tcl_SplitList(tel->interp,Tcl_GetStringResult(tel->interp),&listArgc,&listArgv) ;
                           if(result == TCL_OK) {
                              if ( listArgc >= 11 ) {
                                 tel->ra0 = atof ( listArgv[10] ); 
                                 tel->dec0 = atof ( listArgv[11] ); 
                              } else { 
                                 sprintf(ligne,"radec goto error : mc_hip2tel doesn't return { ra0 dec0 } , returned value=%s",Tcl_GetStringResult(tel->interp));
                                 Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                                 result = TCL_ERROR;
                              }
                           } else {
                              // rien a faire car la fonction Tcl_SplitList a deja renseigne les message d'erreur
                              result = TCL_ERROR;
                           } 
                           Tcl_Free((char*)listArgv);
                        }
                     } else {
                        // pas de modele de pointage
                        if ( strcmp( inputEquinox, "J2000.0" )==0 && strcmp(tel->equinox,"NOW")== 0 ) { 
                           // si les coordonnées sont founies en J2000 et si la monture utilise l'equinoxe NOW 
                        // je convertis les coordonnees a la date du jour, sans appliquer de modele de pointage
                        //  mc_hip2tel {id mag ra dec equinox epoch mura mudec plx } dateTu home pressure temperature
                        // ATTENTION : il ne faut pas utiliser "now" pour la date (ou bien mettre l'ordinateur a l'heure TU)
								libtel_altitude2tp(tel);
                        sprintf(ligne, "mc_hip2tel { 1 0 %f %f %s 0 0 0 0 } { %s } { %s } %d %d %s", 
                           tel->ra0, tel->dec0, inputEquinox, 
                           utDate, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature,
                           refractionOption);
                     if ( tel->consoleLog >= 1 ) {
                        logConsole(tel, "radec goto: %s\n", ligne);
                     }
                     result =  mytel_tcleval(tel,ligne);

                     if (result == TCL_OK) {
                        const char **listArgv;
                        int listArgc;

                        // je recupere les coordonnees corrigees a partir des index 10 et 11 de la liste retournee par mc_hip2tel
                        result = Tcl_SplitList(tel->interp,Tcl_GetStringResult(tel->interp),&listArgc,&listArgv) ;
                        if(result == TCL_OK) {
                           if ( listArgc >= 11 ) {
                              tel->ra0 = atof ( listArgv[10] ); 
                              tel->dec0 = atof ( listArgv[11] ); 
                           } else { 
                              sprintf(ligne,"radec goto error : mc_hip2tel doesn't return { ra0 dec0 } , returned value=%s",Tcl_GetStringResult(tel->interp));
                              Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                              result = TCL_ERROR;
                           }
                        } else {
                           // rien a faire car la fonction Tcl_SplitList a deja renseigne les message d'erreur
                           result = TCL_ERROR;
                        } 
                        Tcl_Free((char*)listArgv);
                     }
                        }
                     }
                     
                  } else {
                     // erreur de la commande clock format ...
                     strcpy(ligne,Tcl_GetStringResult(interp));
                  }
               } else {
                  // erreur de libtel_Getradec()
                  // rien a faire car la fonction libtel_Getradec a deja renseigne les message d'erreur
               }
            } else {
               // j'applique le modele de pointage avec la procedure modpoi_cat2tel du TCL
               // ========================================================================
               sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
               mytel_tcleval(tel,ligne);
               sprintf(ligne,"set libtel(radec) [%s {%s}]",tel->model_cat2tel,argv[3]);
               mytel_tcleval(tel,ligne);
               mytel_tcleval(tel,"set libtel(radec) $libtel(radec)");
               strcpy(ligne,Tcl_GetStringResult(interp));
               libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
               result = TCL_OK;
               /* - end of pointing model-*/
            }

            if ( result == TCL_OK)  {
               if ( tel_radec_goto(tel) == 0 ) {
                  Tcl_SetResult(interp,"",TCL_VOLATILE);
                  result = TCL_OK;
                  // j'affiche une trace dans la console
                  if ( tel->consoleLog >= 1 ) {
                      sprintf(ligne,"list [mc_angle2hms %f 360 zero 0 auto string]  [mc_angle2dms %f 90 zero 0 + string]",tel->ra0, tel->dec0); 
                       mytel_tcleval(tel,ligne);
                      logConsole(tel, "radec goto: catalog coord (now): %s \n", Tcl_GetStringResult(interp));                     
                  }
               } else {
                  Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
            }
         } else {
            sprintf(ligne,"Usage: %s %s goto {angle_ra angle_dec} ?-rate value? ?-blocking boolean? ?-backlash boolean? ?-equinox Jxxxx.x|now?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         /* --- move ---*/
         if (argc>=4) {
            if (argc>=5) {
               tel->radec_move_rate=atof(argv[4]);
            }
            if ( tel_radec_move(tel,argv[3]) == 0 ) {
               Tcl_SetResult(interp,"",TCL_VOLATILE);
               result = TCL_OK;
            } else {
               Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
               result = TCL_ERROR;
            }
         } else {
            sprintf(ligne,"Usage: %s %s move n|s|e|w ?rate?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"pulse")==0) {
         // gestion des impulsions de correction
         if(argc >= 4) {
            if (strcmp(argv[3],"rate")==0) {
               if (argc == 5 ) {
                  // je memorise la vitesse de impulsions
                  int pulseRate;
                  if (Tcl_GetInt(interp, argv[4], &pulseRate) != TCL_OK) {
                     sprintf(ligne,"Usage: %s %s pulse rate value(arsec/s)\nrate shall be an integer",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
                     if (TEL_DRV.tel_setRadecPulseRate(tel, pulseRate)==0) {
                        // je retoune la vitesse
                        Tcl_SetResult(interp,argv[4],TCL_VOLATILE);
                        result = TCL_OK; 
                     } else {
                        Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                        result = TCL_ERROR;
                     }                     
                  }
               } else {
                  // je retourne la vitesse de impulsions
                  int pulseRate;
                  if( TEL_DRV.tel_getRadecPulseRate(tel, &pulseRate) == 0 ) {
                     sprintf(ligne,"%d",pulseRate);
                     Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                     result = TCL_OK;
                  } else {
                     Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                     result = TCL_ERROR;
                  }
               }

            } else if (strcmp(argv[3],"duration")==0  && argc == 8 ) {
               // envoie d'une impulsion en donnant la durée en paramètre (en milliseconde)
               char   alphaDirection;
               double alphaDuration;
               char   deltaDirection;
               double deltaDuration;
               
               switch(argv[4][0]) {
            case 'e':
            case 'E':
                     alphaDirection = 'E';
               break;
            case 'w':
            case 'W':
                     alphaDirection = 'W';
               break;
            default:
                     sprintf(ligne,"Usage: %s %s pulse duration raDirection \nraDirection shall be e|w",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_ERROR;
            }
            
                
            if ( result == TCL_OK) {
                  if (Tcl_GetDouble(interp, argv[5], &alphaDuration) != TCL_OK) {
                     sprintf(ligne,"Usage: %s %s pulse duration raDuration \nraDuration shall be a decimal number",argv[0],argv[1]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  return TCL_ERROR;
               }
               }

               if ( result == TCL_OK) {
                  switch(argv[6][0]) {
               case 'n':
               case 'N':
                        deltaDirection = 'N';
                  break;
               case 's':
               case 'S':
                        deltaDirection= 'S';
                        break;
                     default:
                        sprintf(ligne,"Usage: %s %s pulse duration decDirection\ndecDirectionn shall be n|s",argv[0],argv[1]);
                        Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                        result =  TCL_ERROR;
                  }
               }

               if ( result == TCL_OK) {
                  if (Tcl_GetDouble(interp, argv[7], &deltaDuration) != TCL_OK) {
                     sprintf(ligne,"Usage: %s %s pulse duration decDuration \ndecDuration shall be a decimal number ",argv[0],argv[1]);
                     Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                     result =  TCL_ERROR;
                  }
               }
            
               // j'applique l'impulsion
               if ( result == TCL_OK) {
                  int correctResult = TEL_DRV.tel_sendPulseDuration(tel,alphaDirection,alphaDuration,deltaDirection,deltaDuration);
                  if ( correctResult == 0 ) {
                     // j'attends que le mouvement soit terminé
                     // je lance la surveillance des coordonnées si ce n'est pas déjà fait
                     bool previousState;
                     if ( tel->radecSurveyState == false) {
                        previousState = false;
                        libtel_startRadecSurvey(tel);
                     } else {
                        previousState = true;
                     }

                     // j'attends que le telescope ait fini de bouger
                     tel->radecSurveyIsMoving = true;
                     while ( tel->radecSurveyIsMoving == 1) {
                        Tcl_DoOneEvent(TCL_ALL_EVENTS);
                     }

                     // j'arrete la surveillance 
                     if ( previousState == false ) {
                        libtel_stopRadecSurvey(tel);
                     }

                     Tcl_SetResult(interp,"",TCL_VOLATILE);
                     result =  TCL_OK;
                  } else {
                     Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                     result =  TCL_ERROR;
                  }
               }
               // fin pulse delay
            } else if (strcmp(argv[3],"distance")==0  && argc == 8) {
               // envoie d'une impulsion en donnant la distance en paramètre (en arcsec)
               char   alphaDirection;
               double alphaDistance;
               char   deltaDirection;
               double deltaDistance;
               
               switch(argv[4][0]) {
                  case 'e':
                  case 'E':
                     alphaDirection = 'E';
                     break;
                  case 'w':
                  case 'W':
                     alphaDirection = 'W';
                  break;
               default:
                     sprintf(ligne,"Usage: %s %s pulse distance raDistance \nraDistance shall be e|w",argv[0],argv[1]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }

                
               if ( result == TCL_OK) {
                  if (Tcl_GetDouble(interp, argv[5], &alphaDistance) != TCL_OK) {
                     sprintf(ligne,"Usage: %s %s pulse distance raDistance \nraDistance shall be a decimal number",argv[0],argv[1]);
                     Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                     return TCL_ERROR;
                  }
            }

            if ( result == TCL_OK) {
                  switch(argv[6][0]) {
                     case 'n':
                     case 'N':
                        deltaDirection = 'N';
                        break;
                     case 's':
                     case 'S':
                        deltaDirection= 'S';
                        break;
                     default:
                        sprintf(ligne,"Usage: %s %s pulse distance decDiistance\ndecDistance shall be n|s",argv[0],argv[1]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }
            }

            if ( result == TCL_OK) {
                  if (Tcl_GetDouble(interp, argv[7], &deltaDistance) != TCL_OK) {
                     sprintf(ligne,"Usage: %s %s pulse distance decDistance \ndecDistance shall be a decimal number ",argv[0],argv[1]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }
            }

               // j'applique l'impulsion
            if ( result == TCL_OK) {
                  int correctResult = TEL_DRV.tel_sendPulseDistance(tel,alphaDirection,alphaDistance,deltaDirection,deltaDistance);
               if ( correctResult == 0 ) {
                     // j'attends que le mouvement soit terminé
                     // je lance la surveillance des coordonnées si ce n'est pas déjà fait
                     bool previousState;
                     if ( tel->radecSurveyState == false) {
                        previousState = false;
                        libtel_startRadecSurvey(tel);
                     } else {
                        previousState = true;
                     }

                     // j'attends que le telescope ait fini de bouger
                     tel->radecSurveyIsMoving = true;
                     while ( tel->radecSurveyIsMoving == 1) {
                        Tcl_DoOneEvent(TCL_ALL_EVENTS);
                     }

                     // j'arrete la surveillance 
                     if ( previousState == false ) {
                        libtel_stopRadecSurvey(tel);
                     }

                  Tcl_SetResult(interp,"",TCL_VOLATILE);
                  result =  TCL_OK;
               } else {
                  Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                  result =  TCL_ERROR;
               }
               } // fin pulse distance                  
            } else {               
               // argv[3] incorrect ou nombre de parametres incorrects
               sprintf(ligne,"Usage: %s %s %s { duration  e|w raDuration(ms) n|s decDuration(ms) } | { distance e|w raDistance(arsec) n|s decDistance(arsec) } | { rate value(arsec/s) }",argv[0],argv[1],argv[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            }
         } else {
            // argc  < 4                         
            sprintf(ligne,"Usage: %s %s %s { duration  e|w raDuration(ms) n|s decDuration(ms) } | { distance e|w raDistance(arsec) n|s decDistance(arsec) } | { rate value(arsec/s) }",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } // fin pulse 
      } else if (strcmp(argv[2],"model")==0) {
         /* --- model ---*/
         if (argc>=5) {
            Tcl_ResetResult(interp);
            result =  TCL_OK;
            for (k=3;k<argc-1;k++) {
               if (strcmp(argv[k],"-coefficients")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_coefficients) ) {
                     strcpy(tel->radec_model_coefficients, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_coefficients), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-eastern_coefficients")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_eastern_coefficients) ) {
                     strcpy(tel->radec_model_eastern_coefficients, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_eastern_coefficients), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-western_coefficients")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_western_coefficients) ) {
                     strcpy(tel->radec_model_western_coefficients, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_western_coefficients), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-enabled")==0) {
                  tel->radec_model_enabled =atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-name")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_name) ) {
                     strcpy(tel->radec_model_name, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_name), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-date")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_date) ) {
                     strcpy(tel->radec_model_date, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_date), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-pressure")==0) {
                  tel->radec_model_pressure =atoi(argv[k+1]);
               }
               if (strcmp(argv[k],"-symbols")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_symbols) ) {
                     strcpy(tel->radec_model_symbols, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_symbols), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-eastern_symbols")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_eastern_symbols) ) {
                     strcpy(tel->radec_model_eastern_symbols, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_eastern_symbols), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-western_symbols")==0) {
                  if ( strlen(argv[k+1]) < sizeof(tel->radec_model_western_symbols) ) {
                     strcpy(tel->radec_model_western_symbols, argv[k+1]);
                  } else {
                     sprintf(ligne,"error: value length>%d for %s %s",
                        sizeof(tel->radec_model_western_symbols), argv[k], argv[k+1]);
                     Tcl_AppendResult(interp, ligne, NULL);
                     result = TCL_ERROR;
                  }
               }
               if (strcmp(argv[k],"-temperature")==0) {
                  tel->radec_model_temperature =atoi(argv[k+1]);
               }
            }

         } else if (argc==4) {
            // je retourne les valeurs des parametres
            if (strcmp(argv[3],"-enabled")==0) {
               sprintf(ligne,"%d",tel->radec_model_enabled);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-coefficients")==0) {
               Tcl_SetResult(interp,tel->radec_model_coefficients,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-eastern_coefficients")==0) {
               Tcl_SetResult(interp,tel->radec_model_eastern_coefficients,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-western_coefficients")==0) {
               Tcl_SetResult(interp,tel->radec_model_western_coefficients,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-name")==0) {
               Tcl_SetResult(interp,tel->radec_model_name,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-date")==0) {
               Tcl_SetResult(interp,tel->radec_model_date,TCL_VOLATILE);  
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-pressure")==0) {
               sprintf(ligne,"%d",tel->radec_model_pressure);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_OK;
            } else if ( strcmp(argv[3],"-symbols")==0) {
               Tcl_SetResult(interp,tel->radec_model_symbols,TCL_VOLATILE); 
               result =  TCL_OK;
            } else if (strcmp(argv[3],"-temperature")==0) {
               sprintf(ligne,"%d",tel->radec_model_temperature);
               result =  TCL_OK;
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            } else {
               sprintf(ligne,"Usage: %s %s model -enabled 0|1 -name ?value? -date ?value? -symbols {IH ID ... } -coefficients ?values? -temperature ?value? -pressure ?value?",argv[0],argv[1]);            
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result =  TCL_ERROR;
            }

         } else {
            sprintf(ligne,"Usage: %s %s model -enabled 0|1 -name ?value? -date ?value? -symbols {IH ID ... } -coefficients ?values? -temperature ?value? -pressure ?value?",argv[0],argv[1]);            
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         // j'arrete le timer utilise par default_tel_sendPulse 
         tel->timeDone = 1; 
         if (argc>=4) {
            tel_radec_stop(tel,argv[3]);
         } else {
            tel_radec_stop(tel,"");
         }
      } else if (strcmp(argv[2],"motor")==0) {
         /* --- motor ---*/
         if (argc>=4) {
            tel->radec_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->radec_motor=1;
            }
            if ( tel_radec_motor(tel) == 0 ) {
               Tcl_SetResult(interp,"",TCL_VOLATILE);
            } else {
               Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
               result = TCL_ERROR;
            }
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"survey")==0) {
         // --- survey --
         // recupere les coordonnées J2000.0 toutes les secondes et les copie dans les 
         // variables globales audace(telescope,getra) et audace(telescope,getdec) 
         // du thread principal
         if (argc>=4) {
            if (strcmp(argv[3],"0")==0) {
               // j'arrete la surveillance
               libtel_stopRadecSurvey(tel);              
            } else {
               // je demarre la surveillance
               libtel_startRadecSurvey(tel);               
               }
            // je retourne l'état "0" ou "1" dans le resultat de la commande
            Tcl_SetResult(interp,argv[3],TCL_VOLATILE);
            result = TCL_OK;
         } else if (argc==3){
            // get coord survey state
            // je retourne l'état "0" ou "1" dans le resultat de la commande
            sprintf(ligne,"%d", tel->radecSurveyState);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            // print usage
            sprintf(ligne,"Usage: %s %s survey 0|1",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"guiding")==0) {
         if(argc!=3 && argc!=4) {
            sprintf(ligne,"Usage: %s %s %s {0|1}",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            if (argc == 3 ) {
               sprintf(ligne,"%d",tel->radecGuidingState);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_OK;
            } else {
               int guiding;
               if (Tcl_GetInt(interp, argv[3], &guiding) != TCL_OK) {
                  sprintf(ligne,"Usage: %s %s \nguiding shall be {0|1]}",argv[0],argv[1]);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result = TCL_ERROR;
               } else {
                  if ( guiding != 0 && guiding != 1 ) {
                     sprintf(ligne,"Usage: %s %s \nguiding shall be {0|1]}",argv[0],argv[1]);
                     Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                     result = TCL_ERROR;
                  } else {
                     result = TEL_DRV.tel_setRadecGuidingState(tel, guiding) ;
                     if ( result == 1 ) {
                        Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
                        result = TCL_ERROR;
                     } else {
                        // je memorise la nouvelle valeur 
                        tel->radecGuidingState = guiding;
                        // je retourne la nouvelle valeur au TCL
                        sprintf(ligne,"%d",tel->radecGuidingState);
                        Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                        result = TCL_OK;
                     }
                  }
               }
            }
         }
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdTelFocus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         if (argc>=4) {
            tel->focus0=atof(argv[3]);
            tel_focus_init(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         /* --- coord ---*/
         tel_focus_coord(tel,ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         /* --- goto ---*/
         if (argc>=4) {
            tel->focus0=atof(argv[3]);
            if (argc>=5) {
               for (k=4;k<=argc-1;k++) {
                  if (strcmp(argv[k],"-rate")==0) {
                     tel->focus_goto_rate=atof(argv[k+1]);
                  }
                  if (strcmp(argv[k],"-blocking")==0) {
                     tel->focus_goto_blocking=atoi(argv[k+1]);
                  }
               }
            }
            tel_focus_goto(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s goto number ?-rate value? ?-blocking boolean?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         /* --- move ---*/
         if (argc>=4) {
            if (argc>=5) {
               tel->focus_move_rate=atof(argv[4]);
            }
            tel_focus_move(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s move +|- ?rate?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         if (argc>=4) {
            tel_focus_stop(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            tel_focus_stop(tel,"");
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         }
      } else if (strcmp(argv[2],"motor")==0) {
         /* --- motor ---*/
         if (argc>=4) {
            tel->focus_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->focus_motor=1;
            }
            tel_focus_motor(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if(strcmp(argv[2],"out")==0) {
         /* obsolete function */
         sprintf(ligne,"%s focus move - %f",argv[0],tel->focus_move_rate);
         result=Tcl_Eval(interp,ligne);
      } else if(strcmp(argv[2],"in")==0) {
         /* obsolete function */
         sprintf(ligne,"%s focus move + %f",argv[0],tel->focus_move_rate);
         result=Tcl_Eval(interp,ligne);
      } else if(strcmp(argv[2],"fast")==0) {
         /* obsolete funstion */
         tel->focus_move_rate=1.;
      } else if(strcmp(argv[2],"slow")==0) {
         /* obsolete funstion */
         tel->focus_move_rate=0.;
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdTelModel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   if((argc!=2)&&(argc!=4)) {
      sprintf(ligne,"Usage: %s %s ?function_cat2tel function_tel2cat? ",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if(argc!=2) {
         sprintf(tel->model_cat2tel,"%s",argv[2]);
         sprintf(tel->model_tel2cat,"%s",argv[3]);
      }
      sprintf(ligne,"%s %s",tel->model_cat2tel,tel->model_tel2cat);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/* -----------------------------------------------------------------------------
 *  cmdTelThreadId()
 *
 *  retourne le numero du thread du telescope
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelThreadId(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   struct telprop *tel;
   tel = (struct telprop *) clientData;
   Tcl_SetResult(interp, tel->telThreadId, TCL_VOLATILE);
   return TCL_OK;
}

/* -----------------------------------------------------------------------------
 *  cmdTelConsoleLog()
 *
 *  active/desactive les traces dans la console
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelConsoleLog(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      tel->consoleLog=atoi(argv[2]);
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?0|1|2?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d",tel->consoleLog);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

//-------------------------------------------------------------
//
// FONCTIONS PAR DEFAUT de struct tel_drv_t TEL_DRV
//
//-------------------------------------------------------------

static void timerCallback(ClientData tel ) {
   ((struct telprop *)tel)->timeDone  = 1;
}

//-------------------------------------------------------------
// envoie une correction en ascension droite et en declinaison
// avec une distance donnee en arcseconde   
//
// @param tel   pointeur structure telprop
// @param direction direction de l'impulsion sur l'axe alpha E, W  
// @param distance  durée de l'impulsion sur l'axe alpha en milliseconde  
// @param direction direction de l'impulsion sur l'axe delta N ,S  
// @param distance  durée de l'impulsion sur l'axe delta en milliseconde  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_sendPulseDuration(struct telprop *tel, char alphaDirection, double alphaDuration, 
                      char deltaDirection, double deltaDuration)
{
   char alphaLog[1024];
   char deltaLog[1024];
   
   if ( alphaDuration > 0 ) { 
      int timerDelay = (int) alphaDuration;
      
      if ( timerDelay >= tel->radecPulseMinRadecDelay ) {
         int foundEvent= 1;
         Tcl_TimerToken timerToken;
         tel->timeDone = 0;

         // je cree un timer
         timerToken = Tcl_CreateTimerHandler(timerDelay, timerCallback, (ClientData) tel);
         // je demarre le mouvement
         char direction[2];
         direction[0] = alphaDirection;
         direction[1] = 0;
         tel_radec_move(tel,direction);
         
         // j'attends un evenement de fin du timer

         while ( tel->timeDone == 0) {
            foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            //if (Tcl_LimitExceeded(interp)) {
            //   break;
            //}
         }
         // j'arrete le mouvement
         tel_radec_stop(tel,direction);            
         // je ssupprime le timer
         Tcl_DeleteTimerHandler(timerToken);
         
         if ( tel->consoleLog >= 1 ) {
            sprintf(alphaLog, "%c %.3fs",  alphaDirection, (float)timerDelay/1000);
         }

      } else {
         if ( tel->consoleLog >= 1 ) {
            sprintf(alphaLog, "%c %.3fs ignored (<%.3fs)", alphaDirection, (float)timerDelay/1000,(float) tel->radecPulseMinRadecDelay/1000);
         }
      }
   } else {
      strcpy(alphaLog,"");
   }
   if ( deltaDuration > 0 ) { 
      int timerDelay = (int) deltaDuration;

      if ( timerDelay >= tel->radecPulseMinRadecDelay ) {
         int foundEvent= 1;
         Tcl_TimerToken timerToken;
         tel->timeDone = 0;

         // je cree un timer
         timerToken = Tcl_CreateTimerHandler(timerDelay, timerCallback, (ClientData) tel);
         // je demarre le mouvement
         char direction[2];
         direction[0] = deltaDirection;
         direction[1] = 0;
         tel_radec_move(tel,direction);

         // j'attends un evenement de fin du timer
         while (tel->timeDone == 0) {
            foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            //if (Tcl_LimitExceeded(interp)) {
            //   break;
            //}
         }
         // j'arrete le mouvement
         tel_radec_stop(tel,direction);
         // je ssupprime le timer
         Tcl_DeleteTimerHandler(timerToken);

         if ( tel->consoleLog >= 1 ) {
            sprintf(deltaLog, "%c %.3fs", deltaDirection, (float)timerDelay/1000);
         }

      } else {
         if ( tel->consoleLog >= 1 ) {
            sprintf(deltaLog, "%c %.3fs ignored (<%.3fs)", deltaDirection, (float)timerDelay/1000,(float) tel->radecPulseMinRadecDelay/1000);
         }
      }
   } else {
      strcpy(deltaLog,"");
   }

   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "move to %s %s\n", alphaLog, deltaLog);
   }
   return 0;
}
//-------------------------------------------------------------
// envoie une correction en ascension droite et en declinaison
// avec une distance donnee en arcseconde   
//
// @param tel   pointeur structure telprop
// @param direction direction de l'impulsion sur l'axe alpha E, W  
// @param distance  valeur de l'impulsion sur l'axe alpha en arseconde  
// @param direction direction de l'impulsion sur l'axe delta N ,S  
// @param distance  valeur de l'impulsion sur l'axe delta en arseconde  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_sendPulseDistance(struct telprop *tel, char alphaDirection, double alphaDistance, 
                      char deltaDirection, double deltaDistance)
{
   char alphaLog[1024];
   char deltaLog[1024];
   
   if ( alphaDistance > 0 ) { 
      // je calcule le delai de deplacement en milliseconde sur l'axe alpha
      // delai(miliseconde) = 1000 * distance(arcsec) * vitesse(arsec/seconde)
      int timerDelay = (int) (1000.0 * alphaDistance / tel->radecPulseRate);
      
      if ( timerDelay >= tel->radecPulseMinRadecDelay ) {
         int foundEvent= 1;
         Tcl_TimerToken timerToken;
         tel->timeDone = 0;

         // je cree un timer
         timerToken = Tcl_CreateTimerHandler(timerDelay, timerCallback, (ClientData) tel);
         // je demarre le mouvement
         char direction[2];
         direction[0] = alphaDirection;
         direction[1] = 0;
         tel_radec_move(tel,direction);
         
         // j'attends un evenement de fin du timer

         while ( tel->timeDone == 0) {
            foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            //if (Tcl_LimitExceeded(interp)) {
            //   break;
            //}
         }
         // j'arrete le mouvement
         tel_radec_stop(tel,direction);            
         // je ssupprime le timer
         Tcl_DeleteTimerHandler(timerToken);
         
         if ( tel->consoleLog >= 1 ) {
            sprintf(alphaLog, "%c %.3fs",  alphaDirection, (float)timerDelay/1000);
         }

      } else {
         if ( tel->consoleLog >= 1 ) {
            sprintf(alphaLog, "%c %.3fs ignored (<%.3fs)", alphaDirection, (float)timerDelay/1000,(float) tel->radecPulseMinRadecDelay/1000);
         }
      }
   } else {
      strcpy(alphaLog,"");
   }
   if ( deltaDistance > 0 ) { 
      // je calcule le delai de deplacement en milliseconde sur l'axe delta
      // delai(miliseconde) = 1000 * distance(arcsec) * vitesse(arsec/seconde)
      int timerDelay = (int) (1000.0 * deltaDistance / tel->radecPulseRate);

      if ( timerDelay >= tel->radecPulseMinRadecDelay ) {
         int foundEvent= 1;
         Tcl_TimerToken timerToken;
         tel->timeDone = 0;

         // je cree un timer
         timerToken = Tcl_CreateTimerHandler(timerDelay, timerCallback, (ClientData) tel);
         // je demarre le mouvement
         char direction[2];
         direction[0] = deltaDirection;
         direction[1] = 0;
         tel_radec_move(tel,direction);

         // j'attends un evenement de fin du timer
         while (tel->timeDone == 0) {
            foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            //if (Tcl_LimitExceeded(interp)) {
            //   break;
            //}
         }
         // j'arrete le mouvement
         tel_radec_stop(tel,direction);
         // je ssupprime le timer
         Tcl_DeleteTimerHandler(timerToken);

         if ( tel->consoleLog >= 1 ) {
            sprintf(deltaLog, "%c %.3fs", deltaDirection, (float)timerDelay/1000);
         }

      } else {
         if ( tel->consoleLog >= 1 ) {
            sprintf(deltaLog, "%c %.3fs ignored (<%.3fs)", deltaDirection, (float)timerDelay/1000,(float) tel->radecPulseMinRadecDelay/1000);
         }
      }
   } else {
      strcpy(deltaLog,"");
   }

   if ( tel->consoleLog >= 1 ) {
      logConsole(tel, "move to %s %s\n", alphaLog, deltaLog);
   }
   return 0;
}

//-------------------------------------------------------------
//  retourne l'etat de l'autoguidage 
//
// @param tel   pointeur structure telprop
// @param guiding  0 : auto guidage arrete, 1 : auto guidage actif
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_getRadecGuidingState(struct telprop *tel, int *guiding) {   
   *guiding = tel->radecGuidingState;   
   return 0;
}

//-------------------------------------------------------------
//  indique que l'auto guidage est en cours pour interdire d'autres mouvements inappropriés. 
//  Avertit l'interface de controle Audela est en auto-guidage (checkbox du bandeau sophie dans AudeLA)
//  pour inhiber les raquettes physiques au T193 pendant l'uto-guidage
//
// @param tel   pointeur structure telprop
// @param guiding  0 : auto guidage arrete, 1 : auto guidage actif
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_setRadecGuidingState(struct telprop *tel, int guiding) {
   tel->radecGuidingState = guiding;
   return 0;
}

//-------------------------------------------------------------
//  retourne la vitesse de guidage
//
// @param tel   pointeur structure telprop
// @param rate  vitesse de guidage en arcsec/s
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_getRadecPulseRate(struct telprop *tel, int *rate) {   
   *rate = tel->radecPulseRate;   
   return 0;
}

//-------------------------------------------------------------
//  memorise la vitesse de guidage
//  
// @param tel   pointeur structure telprop
// @param rate  vitesse de guidage en arcsec/s
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int default_tel_setRadecPulseRate(struct telprop *tel, int rate) {
   tel->radecPulseRate = rate;
   return 0;
}


//-------------------------------------------------------------
// Demarre la surveillance des coodonnées
// recupere les coordonnées J2000.0 de la monture toutes les secondes 
// et les copie dans les variables globales audace(telescope,getra) et audace(telescope,getdec) 
// du thread principal
// la surveillance continue tant que tel->radecSurveyState == true
// @return  void
//-------------------------------------------------------------
static void libtel_doRadecSurvey (ClientData clientData)
{
   char ligne[1024];
   char radec[1024];
   int result;
   struct telprop *tel = (struct telprop *)clientData;

      // je recupere les coordonnes du telescope
      sprintf(ligne,"tel%d radec coord -equinox J2000.0",tel->telno);
      result=Tcl_Eval(tel->interp,ligne);
      if ( result == TCL_OK ) {
      // les coordonnees sont au format "HHhMMmSSs +DDdMMmSSsddd"  
         strcpy(radec, Tcl_GetStringResult(tel->interp));
      double ra ;
      double dec; 

      // je memorise les coordonnées dans les variables tel->radecSurveyRa et tel->radecSurveyDec
      // cela servira pour savoir si le telescope bouge
      libtel_Getradec(tel->interp,radec, &ra, &dec);
      // je memorise l'etat du mouvement de la monture
      if ( ra != tel->radecSurveyRa || dec != tel->radecSurveyDec) {
         tel->radecSurveyIsMoving = true;
      } else {
         tel->radecSurveyIsMoving = false;
      }
      tel->radecSurveyRa = ra;
      tel->radecSurveyDec = dec;


         // j'envoie les nouvelles coordonnes au thread principal dans les variables audace(telescope,getra) et audace(telescope,getdec)
         sprintf(ligne,"::thread::send -async %s { set ::audace(telescope,getra) [lindex \"%s\" 0]; set ::audace(telescope,getdec) [lindex \"%s\" 1] ;  update} " , tel->mainThreadId, radec, radec); 

         Tcl_Eval(tel->interp,ligne);
      }

   if ( tel->radecSurveyState == 1 ) {
      // je cree un timer pour recuperer les coordonnees du telescope
      Tcl_TimerToken  timerToken = Tcl_CreateTimerHandler(1000, libtel_doRadecSurvey, (ClientData) tel);
   }
   return;
}



//-------------------------------------------------------------
// Demarre la surveillance des coodonnées
// recupere les coordonnées J2000.0 de la monture toutes les secondes 
// et les copie dans les variables globales audace(telescope,getra) et audace(telescope,getdec) 
// du thread principal
// la surveillance continue tant que tel->radecSurveyState == true
// @return  void
//-------------------------------------------------------------
static void libtel_startRadecSurvey (struct telprop* tel)
{
   if (tel->radecSurveyState == false ) {
      tel->radecSurveyState = true;
      Tcl_TimerToken  timerToken = Tcl_CreateTimerHandler(200, libtel_doRadecSurvey, (ClientData) tel);
   } else {
      // rien a faire car la surveillance est deja lancee
      return;
   }
}

//-------------------------------------------------------------
// arrete la surveillance des coordonnees
// @return  void
//-------------------------------------------------------------
static void libtel_stopRadecSurvey (struct telprop* tel)
{
   // j'arrete la surveillance
   tel->radecSurveyState = false;
}

//-------------------------------------------------------------
// --- Compute the theoretical local standard temperature and pressure
// Take account for the altitude (extracted from home)
//-------------------------------------------------------------
int libtel_altitude2tp (struct telprop *tel) {
   char s[2256];
   int result=TCL_OK;
	if (strcmp(tel->homePosition,"")!=0) {
		sprintf(s,"lindex [mc_altitude2tp [lindex {%s} 4] 101325] 0",tel->homePosition); 
		result =  mytel_tcleval(tel,s);
		if ( result == TCL_OK) {
			tel->radec_model_temperature = (int)atof(Tcl_GetStringResult(tel->interp));
			sprintf(s,"lindex [mc_altitude2tp [lindex {%s} 4] 101325] 1",tel->homePosition); 
			result =  mytel_tcleval(tel,s);
			if ( result == TCL_OK) {
				tel->radec_model_pressure = (int)atof(Tcl_GetStringResult(tel->interp));
			}
		}
	}
	return result;
}

int tel_init_common(struct telprop *tel, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --------------------------------------------------------- */
/* argv[2] : symbole du port (com1,etc.)                     */
/* argv[>=3] : optionnels : -protocol -name                  */
/* --------------------------------------------------------- */
{
   int k,kk;
   tel->speed=1;
   /* --- Decode les options de tel::create en fonction de argv[>=3] ---*/
   tel->index_tel=0;
   if (argc>=5) {
      for (kk=3;kk<argc-1;kk++) {
         if (strcmp(argv[kk],"-name")==0) {
            // je copie le nom dans tel->name pour determiner 
            // si la monture a l'impulsion de la refraction , 
            // meme si son nom n'est pas dans le tableau tel_ini[k].name
            strncpy(tel->name, argv[kk+1], sizeof(tel->name));
            // je cherche le nom dans le tableau tel_ini[k]
            k=0;
            while (strcmp(tel_ini[k].name,"")!=0) {
               if (strcmp(tel_ini[k].name,argv[kk+1])==0) {
                  tel->index_tel=k;
                  break;
               }
               k++;
            }
        }
      }
   }

   /* --- initialisation du numero de port du PC ---*/
   strcpy(tel->portname,"unknown");
   tel->portindex = 0;
   if (argc>=2) {
      if(strcmp(argv[2],tel_ports[1])==0) {
         tel->portindex = 1;
      }
      strcpy(tel->portname,argv[2]);
   }
   /* --- init of general variables for the telescope --- */
   strcpy(tel->alignmentMode,"EQUATORIAL");
   tel->refractionCorrection = 0 ;          // par defaut la monture n'a pas de correction de la refraction
   strcpy(tel->equinox,"NOW");       // par defaut les montures travaillent avec les coordonnées basées sur l'equinoxe du jour.
   tel->foclen=tel_ini[tel->index_tel].foclen;
   tel->ra0=0.;
   tel->dec0=0.;
   tel->radec_goto_rate=0.;
   tel->radec_goto_blocking=1;
   tel->radec_move_rate=0.;
   tel->focus0=0.;
   tel->focus_goto_rate=0;
   tel->focus_move_rate=0;
   tel->consoleLog = 0;    
   tel->radec_model_enabled = 0;
   strcpy(tel->radec_model_name,""); 
   strcpy(tel->radec_model_symbols,""); 
   strcpy(tel->radec_model_coefficients,"");
	tel->mstation=MS_UNKNOWN;
	tel->mmechanics=MM_UNKNOWN;
	tel->ptube=PT_UNKNOWN;
	tel->halim_tube_west=-25;
	tel->halim_tube_east=30;
   strcpy(tel->radec_model_eastern_symbols,""); 
   strcpy(tel->radec_model_eastern_coefficients,"");
   strcpy(tel->radec_model_western_symbols,""); 
   strcpy(tel->radec_model_western_coefficients,"");
   
   tel->radecGuidingState = 0;   // etat de la session de guidage par defaut
   tel->radecPulseRate = 5;   // vitesse de guidage par defaut (arcsec/seconde)
   tel->radecPulseMinRadecDelay = 0;
   
   tel->radec_model_temperature = 290;  // temperatature par defaut 
   tel->radec_model_pressure = 101325;  // pression par defaut

   strcpy(tel->model_cat2tel,"");
   strcpy(tel->model_tel2cat,"");
   strcpy(tel->homeName,"");
   strcpy(tel->homePosition,"");
   tel->radecSurveyState = false;    // la surveillance des coordonnées est arretée par defaut
   tel->radecSurveyRa = 0;           // derniere valeur de l'ascention doite recupérée par la commande survey
   tel->radecSurveyDec = 0;          // derniere declinaison recupérée par la commande survey
   tel->radecSurveyIsMoving = false; // denier etat du mouvement de la monture.
   return 0;
}
