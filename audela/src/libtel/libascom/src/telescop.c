/* telescop.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <stdio.h>
#include "telescop.h"
#include <libtel/util.h>

extern void logConsole(struct telprop *tel, char *messageFormat, ...);
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"ASCOM",    /* telescope name */
    "Ascom",    /* protocol name */
    "ascom",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};


/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage du telescope      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque telescope.   */
/* et sont appelees par libtel.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{
   char s[1024];

   strcpy(s,"package require tcom");
   if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
      return 1;
   }
   strcpy(s,"package require registry");
   if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
      return 2;
   }
   if (argc>=7) {
      sprintf(s,"::registry get \"HKEY_LOCAL_MACHINE\\\\Software\\\\ASCOM\\\\Telescope Drivers\\\\%s\" \"\"",argv[6]);
      if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
         /* unknown scope */
         return 3;
      }
   } else {
      return 4;
   } 
   sprintf(s,"set ::ascom_variable(1) [ ::tcom::ref createobj %s ]",argv[6]);
   if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
      return 5;
   }
   strcpy(s,"set telcmd $::ascom_variable(1)"); mytel_tcleval(tel,s);
   strcpy(s,"$telcmd Connected 1"); mytel_tcleval(tel,s);
   strcpy(s,"::registry get \"HKEY_USERS\\\\.default\\\\Control Panel\\\\International\" sDecimal"); mytel_tcleval(tel,s);
   if (Tcl_Eval(tel->interp,s)==TCL_OK) {
      tel->sDecimal=tel->interp->result[0];
   } else {
      tel->sDecimal='.';
   }
   strcpy(s,"$telcmd Tracking 1"); mytel_tcleval(tel,s);
   tel->rateunity=0.1;           //  deg/s when rate=1   
   strcpy(s,"$telcmd Unpark"); mytel_tcleval(tel,s);
   tel_home_get(tel,tel->homePosition);
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   return 0;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   char s[1024];
   strcpy(s,"set telcmd $::ascom_variable(1)"); 
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   strcpy(s,"$telcmd Connected 0"); mytel_tcleval(tel,s);
   sprintf(s,"unset telcmd"); mytel_tcleval(tel,s);
   sprintf(s,"unset ::ascom_variable(1)"); mytel_tcleval(tel,s);
   return 0;
}

// ---------------------------------------------------------------------------
// ascomcamSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return void
//    
// ---------------------------------------------------------------------------

void mytel_setupDialog(struct telprop *tel)
{
   char s[1024];
   strcpy(s,"after idle $::ascom_variable(1) SetupDialog"); mytel_tcleval(tel,s);
}


int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return mytel_radec_init(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return mytel_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   return mytel_radec_state(tel,result);
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
   return mytel_radec_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
   return mytel_radec_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
   return mytel_radec_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return mytel_radec_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return mytel_focus_init(tel);
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return mytel_focus_coord(tel,result);
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return mytel_focus_goto(tel);
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return mytel_focus_move(tel,direction);
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
   return mytel_focus_stop(tel,direction);
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return mytel_focus_motor(tel);
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   return mytel_date_get(tel,ligne);
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return mytel_date_set(tel,y,m,d,h,min,s);
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   return mytel_home_get(tel,ligne);
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {PGS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   return mytel_home_set(tel,longitude,ew,latitude,altitude);
}



/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_radec_init(struct telprop *tel)
/* it corresponds to the "match" function of an LX200 */
{
   char s[1024];
   char ra[100];
   char dec[100];
   strcpy(s,"set telcmd $::ascom_variable(1)"); 
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   strcpy(s,"$telcmd CamSync"); 
   if ( mytel_tcleval(tel,s)==0) {
      return 1;
   }
   strcpy(ra,"");
   strcpy(dec,"");
   sprintf(s,"expr [mc_angle2deg %f]/15.",tel->ra0); mytel_tcleval(tel,s);
   strcpy(ra,tel->interp->result);
   mytel_decimalsymbol(ra,'.',tel->sDecimal,ra);
   sprintf(s,"expr [mc_angle2deg %f 90]",tel->dec0); mytel_tcleval(tel,s);
   strcpy(dec,tel->interp->result);
   mytel_decimalsymbol(dec,'.',tel->sDecimal,dec);
   sprintf(s,"$telcmd SyncToCoordinates %s %s",ra,dec); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_init_additional(struct telprop *tel)
 {
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   char s[1024];
   int slewing=0,tracking=0,connected=0;
   strcpy(s,"set telcmd $::ascom_variable(1)");
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   strcpy(s,"$telcmd Connected"); mytel_tcleval(tel,s);
   if (strcmp(tel->interp->result,"1")==0) {
      connected=1;
	}
   strcpy(s,"$telcmd Slewing"); mytel_tcleval(tel,s);
   if (strcmp(tel->interp->result,"1")==0) {
      slewing=1;
	}
   strcpy(s,"$telcmd Tracking"); mytel_tcleval(tel,s);
   if (strcmp(tel->interp->result,"1")==0) {
      tracking=1;
	}
   sprintf(result,"{connected %d} {slewing %d} {tracking %d} ",connected,slewing,tracking);
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024];
   char ra[100];
   char dec[100];
   strcpy(s,"set telcmd $::ascom_variable(1)"); 
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   strcpy(s,"$telcmd CanSlew"); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   if (strcmp(tel->interp->result,"0")==0) {
      /*error "Telescope can't slew"*/
      return 2;
   }
   strcpy(ra,"");
   strcpy(dec,"");
   sprintf(s,"expr [mc_angle2deg %f]/15.",tel->ra0); mytel_tcleval(tel,s);
   strcpy(ra,tel->interp->result);
   mytel_decimalsymbol(ra,'.',tel->sDecimal,ra);
   sprintf(s,"expr [mc_angle2deg %f 90]",tel->dec0); mytel_tcleval(tel,s);
   strcpy(dec,tel->interp->result);
   mytel_decimalsymbol(dec,'.',tel->sDecimal,dec);
   strcpy(s,"$telcmd Tracking 1"); mytel_tcleval(tel,s);
   if (tel->radec_goto_blocking==1) {
      sprintf(s,"$telcmd SlewToCoordinates %s %s",ra,dec); mytel_tcleval(tel,s);
   } else {
      sprintf(s,"$telcmd SlewToCoordinatesAsync %s %s",ra,dec); mytel_tcleval(tel,s);
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10],ratestr[500];
   double rate;
   rate=tel->rateunity*tel->radec_move_rate;
   /*sprintf(s,"after 50"); mytel_tcleval(tel,s);*/
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   strcpy(s,"set telcmd $::ascom_variable(1)");
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   if ((strcmp(direc,"S")==0)||(strcmp(direc,"W")==0)) {
      rate*=-1;
   }
   sprintf(ratestr,"%f",rate);
   mytel_decimalsymbol(ratestr,'.',tel->sDecimal,ratestr);
   if (strcmp(direc,"N")==0) {
      sprintf(s,"$telcmd MoveAxis 1 %s",ratestr); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"S")==0) {
      sprintf(s,"$telcmd MoveAxis 1 %s",ratestr); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"E")==0) {
      sprintf(s,"$telcmd MoveAxis 0 %s",ratestr); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"W")==0) {
      sprintf(s,"$telcmd MoveAxis 0 %s",ratestr); mytel_tcleval(tel,s);
   }
   /*sprintf(s,"after 50"); mytel_tcleval(tel,s);*/
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10],ratestr[500];
   double rate=0.;
   /*sprintf(s,"after 50"); mytel_tcleval(tel,s);*/
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,tel->interp->result);
   strcpy(s,"set telcmd $::ascom_variable(1)");
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   if ((strcmp(direc,"S")==0)||(strcmp(direc,"W")==0)) {
      rate*=-1;
   }
   sprintf(ratestr,"%f",rate);
   mytel_decimalsymbol(ratestr,'.',tel->sDecimal,ratestr);
   if (strcmp(direc,"N")==0) {
      sprintf(s,"$telcmd MoveAxis 1 %s",ratestr); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"S")==0) {
      sprintf(s,"$telcmd MoveAxis 1 %s",ratestr); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"E")==0) {
      sprintf(s,"$telcmd MoveAxis 0 %s",ratestr); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"W")==0) {
      sprintf(s,"$telcmd MoveAxis 0 %s",ratestr); mytel_tcleval(tel,s);
   } else {
      strcpy(s,"$telcmd AbortSlew"); mytel_tcleval(tel,s);
      sprintf(s,"$telcmd MoveAxis 0 %s",ratestr); mytel_tcleval(tel,s);
      sprintf(s,"$telcmd MoveAxis 1 %s",ratestr); mytel_tcleval(tel,s);
      /*sprintf(s,"after 50"); mytel_tcleval(tel,s);*/
   }
   /*sprintf(s,"after 50"); mytel_tcleval(tel,s);*/
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];
   /*sprintf(s,"after 20"); mytel_tcleval(tel,s);*/
   if (tel->radec_motor==1) {
      /* stop the motor */
      strcpy(s,"$telcmd Tracking 0"); mytel_tcleval(tel,s);
   } else {
      /* start the motor */
      strcpy(s,"$telcmd Unpark"); mytel_tcleval(tel,s);
      strcpy(s,"$telcmd Tracking 1"); mytel_tcleval(tel,s);
   }
   /*sprintf(s,"after 50"); mytel_tcleval(tel,s);*/
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   char s[1024];
   char ss[1024];
   strcpy(s,"set telcmd $::ascom_variable(1)");
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }

   strcpy(s,"$telcmd RightAscension"); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      strcpy(result,tel->interp->result);
      return 1;
   }
   sprintf(s,"mc_angle2hms {%s h} 360 zero 2 auto string",tel->interp->result); mytel_tcleval(tel,s);
   strcpy(ss,tel->interp->result);
   strcpy(s,"$telcmd Declination"); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      strcpy(result,tel->interp->result);
      return 1;
   }
   sprintf(s,"mc_angle2dms %s 90 zero 1 + string",tel->interp->result); mytel_tcleval(tel,s);
   sprintf(result,"%s %s",ss,tel->interp->result);
   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   char s[1024];
   strcpy(s,"set telcmd $::ascom_variable(1)"); 
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }

   strcpy(s,"mc_date2ymdhms [expr [mc_date2jd 1899-12-30T00:00:00]+[$telcmd UTCDate]]"); mytel_tcleval(tel,s);
   sprintf(ligne,"%s",tel->interp->result);
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   char ss[1024];
   strcpy(ss,"set telcmd $::ascom_variable(1)");
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,ss)!=TCL_OK) {
      return 1;
   }
   sprintf(ss,"$telcmd UTCDate [expr [mc_date2jd [list %d %d %d %d %d %f]]-[mc_date2jd 1899-12-30T00:00:00]]",y,m,d,h,min,s); mytel_tcleval(tel,ss);
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   char s[1024];
   double longitude;
   char ew[2];
   double latitude;
   double altitude;
   strcpy(s,"set telcmd $::ascom_variable(1)");
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }

   strcpy(s,"$telcmd SiteElevation"); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   altitude=(double)atof(tel->interp->result);
   strcpy(s,"$telcmd SiteLatitude "); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 2;
   }
   latitude=(double)atof(tel->interp->result);
   strcpy(s,"$telcmd SiteLongitude "); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 3;
   }
   longitude=(double)atof(tel->interp->result);
   if (longitude>0) {
      strcpy(ew,"E");
   } else {
      strcpy(ew,"W");
   }
   longitude=fabs(longitude);
   sprintf(ligne,"GPS %f %s %f %f",longitude,ew,latitude,altitude);   
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   /* conf(posobs,observateur,gps) */
   char s[1024],ss[1024];
   strcpy(s,"set telcmd $::ascom_variable(1)"); 
   // je verifie que le telescope n'a pas ete arrete (existence de la variable ::ascom_variable(1) )
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   sprintf(ss,"%f",altitude);
   mytel_decimalsymbol(ss,'.',tel->sDecimal,ss);
   sprintf(s,"$telcmd SiteElevation %s",ss); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 1;
   }
   sprintf(ss,"%f",latitude);
   mytel_decimalsymbol(ss,'.',tel->sDecimal,ss);
   sprintf(s,"$telcmd SiteLatitude %s",ss); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 2;
   }
   longitude=fabs(longitude);
   if (strcmp(ew,"W")==0) {
      longitude=-longitude;
   }
   sprintf(ss,"%f",longitude);
   mytel_decimalsymbol(ss,'.',tel->sDecimal,ss);
   sprintf(s,"$telcmd SiteLongitude %s",ss); 
   if ( mytel_tcleval(tel,s)!=TCL_OK) {
      return 3;
   }
   return 0;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */


//#define MOUCHARD

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_ascom.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD)
   fprintf(f,"# [%d] = %s\n", result, tel->interp->result);
   fclose(f);
#endif
   return result;
}

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout)
{
   int len,k;
   char car;
   len=(int)strlen(strin);
   if (len==0) {
      strout[0]='\0';
      return;
   }
   for (k=0;k<len;k++) {
      car=strin[k];
      if (car==decin) {
         car=decout;
      }
      strout[k]=car;
   }
   strout[k]='\0';
}
