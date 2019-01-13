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


 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"Celestron",    /* telescope name */
    "Nexstar",    /* protocol name */
    "celestron",  /* product */
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
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   unsigned char a[10];
   int k;
   /* --- transcode a port argument into comX or into /dev... */
   strcpy(ss,argv[2]);
   sprintf(s,"string range [string toupper %s] 0 2",ss);
   Tcl_Eval(tel->interp,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"COM")==0) {
      sprintf(s,"string range [string toupper %s] 3 end",ss);
      Tcl_Eval(tel->interp,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      k=(int)atoi(s);
      Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
      strcpy(s,Tcl_GetStringResult(tel->interp));
      if (strcmp(s,"Linux")==0) {
         sprintf(ss,"/dev/ttyS%d",k-1);
         sprintf(ssusb,"/dev/ttyUSB%d",k-1);
      }
   }
   /* --- open the port and record the channel name ---*/
   sprintf(s,"open \"%s\" r+",ss);
   if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
      strcpy(ssres,Tcl_GetStringResult(tel->interp));
      Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      if (strcmp(ss,"Linux")==0) {
         /* if ttyS not found, we test ttyUSB */
         sprintf(ss,"open \"%s\" r+",ssusb);
         if (Tcl_Eval(tel->interp,ss)!=TCL_OK) {
            strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
            return 1;
         }
      } else {
         strcpy(tel->msg,ssres);
         return 1;
      }
   }
   strcpy(tel->channel,Tcl_GetStringResult(tel->interp));
   /*
   # 9600 : vitesse de transmission (bauds)
   # 0 : 0 bit de parité
   # 8 : 8 bits de données
   # 1 : 1 bits de stop
   */
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); mytel_tcleval(tel,s);
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   mytel_flush(tel);
   mytel_set_format(tel,1);
   tel->tempo=300;
   /* get the informations : initializations */
   tel->version_major=(unsigned char)0;
   tel->version_minor=(unsigned char)0;
   tel->version=(double)0;
   tel->device_azmra_motor_version_major=(unsigned char)0;
   tel->device_azmra_motor_version_minor=(unsigned char)0;
   tel->device_azmra_motor_version=(double)0;
   tel->device_altdec_motor_version_major=(unsigned char)0;
   tel->device_altdec_motor_version_minor=(unsigned char)0;
   tel->device_altdec_motor_version=(double)0;
   tel->device_gps_unit_version_major=(unsigned char)0;
   tel->device_gps_unit_version_minor=(unsigned char)0;
   tel->device_gps_unit_version=(double)0;
   tel->device_rtc_version_major=(unsigned char)0;
   tel->device_rtc_version_minor=(unsigned char)0;
   tel->device_rtc_version=(double)0;
   /* get the informations : version */
   sprintf(s,"puts -nonewline %s \"V\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after 150"); mytel_tcleval(tel,s);
   sprintf(s,"read %s 3",tel->channel); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
   sprintf(a,"%d.%d",ss[0],ss[1]);
   tel->version_major=(int)ss[0];
   tel->version_minor=(int)ss[1];
   tel->version=atof(a);
   /* get the informations : device versions */
   if (tel->version>=1.6) {
      sprintf(s,"read %s 20",tel->channel); mytel_tcleval(tel,s);
      a[0]=1;
      a[1]=16;
      a[2]=254;
      a[3]=0;
      a[4]=0;
      a[5]=0;
      a[6]=2;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
      sprintf(s,"after 150"); mytel_tcleval(tel,s);
      sprintf(s,"read %s 3",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      tel->device_azmra_motor_version_major=(int)ss[0];
      tel->device_azmra_motor_version_minor=(int)ss[1];
      sprintf(a,"%d.%d",ss[0],ss[1]);
      tel->device_azmra_motor_version=atof(a);
      a[1]=17;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
      sprintf(s,"after 150"); mytel_tcleval(tel,s);
      sprintf(s,"read %s 3",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      tel->device_altdec_motor_version_major=(int)ss[0];
      tel->device_altdec_motor_version_minor=(int)ss[1];
      sprintf(a,"%d.%d",ss[0],ss[1]);
      tel->device_altdec_motor_version=atof(a);
      a[1]=176;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
      sprintf(s,"after 150"); mytel_tcleval(tel,s);
      sprintf(s,"read %s 3",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      tel->device_gps_unit_version_major=(int)ss[0];
      tel->device_gps_unit_version_minor=(int)ss[1];
      sprintf(a,"%d.%d",ss[0],ss[1]);
      tel->device_gps_unit_version=atof(a);
      a[1]=178;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
      sprintf(s,"after 150"); mytel_tcleval(tel,s);
      sprintf(s,"read %s 3",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      tel->device_rtc_version_major=(int)ss[0];
      tel->device_rtc_version_minor=(int)ss[1];
      sprintf(a,"%d.%d",ss[0],ss[1]);
      tel->device_rtc_version=atof(a);
   }
	tel->raoff=0.;
	tel->decoff=0.;
   mytel_flush(tel);
   tel->refractionCorrection = 1; // la monture assure la correction de la refraction
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   char a[5],s[1024];
   a[0]='x';
   sprintf(s,"puts -nonewline %s \"K%c\"",tel->channel,a[0]); mytel_tcleval(tel,s);
   sprintf(s,"after 150"); mytel_tcleval(tel,s);
   sprintf(s,"read %s 2",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (s[0]==a[0]) {
      return 1;
   } else {
      return 0;
   }
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   char s[1024];
   sprintf(s,"close %s",tel->channel); mytel_tcleval(tel,s);
   return 0;
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

int tel_get_position_tube(struct telprop *tel)
/* ---------------------------------------------------- */
/* --- called by : tel1 position_tube               --- */
/* ---------------------------------------------------- */
{
	return PT_UNKNOWN;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_radec_init(struct telprop *tel)
/* it corresponds to the "sync" function of a Nexstar */
{
   char s[1024],command[5];
   char coord0[50];
   int nbits;
   if (tel->version<4.1) {
		tel->raoff=0.;
		tel->decoff=0.;
      tel_radec_coord(tel,coord0);
	   sprintf(s,"expr (%.7f)-[mc_angle2deg [lindex {%s} 0]]",tel->ra0,coord0); mytel_tcleval(tel,s);
		strcpy(s,Tcl_GetStringResult(tel->interp));
      tel->raoff=atof(s);
	   sprintf(s,"expr (%.7f)-[mc_angle2deg [lindex {%s} 1]]",tel->dec0,coord0); mytel_tcleval(tel,s);
		strcpy(s,Tcl_GetStringResult(tel->interp));
      tel->decoff=atof(s);
      return 0;
   }
   /* get the short|long format */
   mytel_get_format(tel);
   if (tel->longformatindex==0) {
      nbits=16;
      strcpy(command,"S");
   } else {
      nbits=24;
      strcpy(command,"s");
   }
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   sprintf(s,"mc_angles2nexstar %f %f %d",tel->ra0,tel->dec0,nbits); mytel_tcleval(tel,s);
   /* Send S or s */
   sprintf(s,"puts -nonewline %s \"%s%s\"",tel->channel,command,Tcl_GetStringResult(tel->interp)); mytel_tcleval(tel,s);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   /* Receive # if it is OK */
   sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
   /*mytel_flush(tel);*/
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   char s[1024];
   char coord0[50],coord1[50];
   tel_radec_coord(tel,coord0);
	sprintf(s,"after 350"); mytel_tcleval(tel,s);
	tel_radec_coord(tel,coord1);
	sprintf(s,"expr 3600.*[lindex [mc_anglesep [list %s %s]] 0]",coord0,coord1); mytel_tcleval(tel,s);
	strcpy(s,Tcl_GetStringResult(tel->interp));
   if (atof(s)<10.) {strcpy(result,"tracking");}
   else {strcpy(result,"pointing");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024],ss[100],command[5];
   char coord0[50],coord1[50];
   int time_in=0,time_out=240,nbits;
   char tracking_mode=0;
	double radeg,decdeg;
   /* get the tracking mode */
   sprintf(s,"puts -nonewline %s \"t\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after 150"); mytel_tcleval(tel,s);
   sprintf(s,"read %s 2",tel->channel); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
	if (strcmp(ss,"")==0) {
	   tracking_mode=1;
	} else {
	   tracking_mode=ss[0];
	}
   /* get the short|long format */
   mytel_get_format(tel);
   if ((tel->longformatindex==0)||(tel->version<2.2)) {
      nbits=16;
      if (tracking_mode==1) {
         strcpy(command,"R");
      } else {
         strcpy(command,"B");
      }
   } else {
      nbits=24;
      if (tracking_mode==1) {
         strcpy(command,"r");
      } else {
         strcpy(command,"b");
      }
   }
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
	radeg=tel->ra0-tel->raoff;
	if (radeg>360.) { radeg-=360.; }
	if (radeg<0.) { radeg+=360.; }
	decdeg=tel->dec0+tel->decoff;
	if (decdeg>90.) { decdeg=90.; }
	if (decdeg<-90.) { decdeg=-90.; }
   sprintf(s,"mc_angles2nexstar %.7f %.7f %d",radeg,decdeg,nbits); mytel_tcleval(tel,s);
   /* Send Goto */
   sprintf(s,"puts -nonewline %s \"%s%s\"",tel->channel,command,Tcl_GetStringResult(tel->interp)); mytel_tcleval(tel,s);
   sprintf(s,"after 150"); mytel_tcleval(tel,s);
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      tel_radec_coord(tel,coord0);
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         tel_radec_coord(tel,coord1);
		   sprintf(s,"expr 3600.*[lindex [mc_anglesep [list %s %s]] 0]",coord0,coord1); mytel_tcleval(tel,s);
			strcpy(s,Tcl_GetStringResult(tel->interp));
         if (atof(s)<10.) {break;}
         strcpy(coord0,coord1);
	     if (time_in>=time_out) {break;}
      }
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10],a[15];
   char rate;
   if (tel->version<1.6) {
      return 0;
   }
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   a[0]=2;
   if (strcmp(direc,"N")==0) {
      a[1]=17;
      a[2]=36;
   } else if (strcmp(direc,"S")==0) {
      a[1]=17;
      a[2]=37;
   } else if (strcmp(direc,"E")==0) {
      a[1]=16;
      a[2]=36;
   } else if (strcmp(direc,"W")==0) {
      a[1]=16;
      a[2]=37;
   }
   rate=(unsigned char)(tel->radec_move_rate/9);
   a[3]=rate;
   a[4]=0;
   a[5]=0;
   a[6]=0;
   if (rate>2) {
      /* Turn off the tracking */
      tel->radec_motor=1;
      mytel_radec_motor(tel);
   }
   sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   /* Receive # if it is OK */
   sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10],a[15];
   char rate;
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   /* Turn off the tracking */
   /*
   sprintf(s,"puts -nonewline %s \"t0\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   */
   if (tel->version<1.6) {
      return 0;
   }
   a[0]=2;
   rate=(unsigned char)(0);
   a[3]=rate;
   a[4]=0;
   a[5]=0;
   a[6]=0;
   if (strcmp(direc,"N")==0) {
      a[1]=17;
      a[2]=36;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"S")==0) {
      a[1]=17;
      a[2]=37;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"E")==0) {
      a[1]=16;
      a[2]=36;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
   } else if (strcmp(direc,"W")==0) {
      a[1]=16;
      a[2]=37;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
   } else {
      a[1]=17;
      a[2]=36;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      a[1]=17;
      a[2]=37;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      a[1]=16;
      a[2]=36;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      a[1]=16;
      a[2]=37;
      sprintf(s,"puts -nonewline %s \"P%c%c%c%c%c%c%c\"",tel->channel,a[0],a[1],a[2],a[3],a[4],a[5],a[6]); mytel_tcleval(tel,s);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   /* Receive # if it is OK */
   sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
   /* motors on */
   tel->radec_motor=0;
   mytel_radec_motor(tel);
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024],ss[100],latns='0';
   if (tel->version<1.6) {
      return 0;
   }
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   if (tel->radec_motor==1) {
      /* stop the motor */
      sprintf(s,"puts -nonewline %s \"T[format %%c 0]\"",tel->channel); mytel_tcleval(tel,s);
   } else {
      /* start the motor */
      mytel_flush(tel);
      if (tel->version>=2.3) {
         sprintf(s,"puts -nonewline %s \"w\"",tel->channel); mytel_tcleval(tel,s);
         sprintf(s,"after 150"); mytel_tcleval(tel,s);
         sprintf(s,"read %s 9",tel->channel); mytel_tcleval(tel,s);
         strcpy(ss,Tcl_GetStringResult(tel->interp));
         latns=ss[3];
      } else {
         latns=(char)0;
      }
      if (latns=='1') {
         sprintf(s,"puts -nonewline %s \"T[format %%c 3]\"",tel->channel); mytel_tcleval(tel,s);
      } else {
         sprintf(s,"puts -nonewline %s \"T[format %%c 2]\"",tel->channel); mytel_tcleval(tel,s);
      }
   }
   sprintf(s,"after 150"); mytel_tcleval(tel,s);
   mytel_flush(tel);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   char s[1024],ss[1024],ra[100],dec[100],command[5];
	double radeg,decdeg;
   int nbits;
   char tracking_mode=0;
   mytel_flush(tel);
   strcpy(result,"");
   if (tel->version<1.2) {
      return 0;
   }
   /* get the tracking mode */
   if (tel->version>=2.3) {
      sprintf(s,"puts -nonewline %s \"t\"",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"after 150"); mytel_tcleval(tel,s);
      sprintf(s,"read %s 2",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      tracking_mode=ss[0];
   }
   /* get the short|long format */
   mytel_get_format(tel);
   if ((tel->longformatindex==0)||(tel->version<2.2)) {
      nbits=16;
      if (tracking_mode==1) {
         strcpy(command,"Z");
      } else {
         strcpy(command,"E");
      }
   } else {
      nbits=24;
      if (tracking_mode==1) {
         strcpy(command,"z");
      } else {
         strcpy(command,"e");
      }
   }
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   /* Send E or e */
   sprintf(s,"puts -nonewline %s \"%s\"",tel->channel,command); mytel_tcleval(tel,s);
   sprintf(s,"after 200"); mytel_tcleval(tel,s);
   /* Receive results and # if it is OK */
   if (tel->longformatindex==0) {
      sprintf(s,"read %s 9",tel->channel); mytel_tcleval(tel,s);
   } else {
      sprintf(s,"read %s 17",tel->channel); mytel_tcleval(tel,s);
   }
   sprintf(s,"mc_nexstar2angles %s",Tcl_GetStringResult(tel->interp)); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
	
   sprintf(s,"mc_angle2deg [lindex {%s} 0]",ss); mytel_tcleval(tel,s);
	radeg=atof(Tcl_GetStringResult(tel->interp))+tel->raoff;
	if (radeg>360.) { radeg-=360.; }
	if (radeg<0.) { radeg+=360.; }

   sprintf(s,"mc_angle2deg [lindex {%s} 1]",ss); mytel_tcleval(tel,s);
	decdeg=atof(Tcl_GetStringResult(tel->interp))+tel->decoff;
	if (decdeg>90.) { decdeg=90.; }
	if (decdeg<-90.) { decdeg=-90.; }

   sprintf(s,"mc_angle2hms %.7f 360 zero 2 auto string",radeg); mytel_tcleval(tel,s);
   strcpy(ra,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2dms %.7f 90 zero 1 + string",decdeg); mytel_tcleval(tel,s);
   strcpy(dec,Tcl_GetStringResult(tel->interp));
   sprintf(result,"%s %s",ra,dec);
   sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
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
   char s[1024],ss[1024];
   /* Get the date & time */
   if (tel->version<2.3) {
      strcpy(ss,"000000");
   } else {
      mytel_flush(tel);
      sprintf(s,"puts -nonewline %s \"h\"",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"after 150"); mytel_tcleval(tel,s);
      sprintf(s,"read %s 9",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
   }
   /* Returns the result */
   sprintf(ligne,"20%02d %d %d %d %d %d.0",ss[5],ss[3],ss[4],ss[0],ss[1],ss[2]);
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   char ligne[1024],ligne2[1024];
   int sec,k=0;
   if (tel->version<2.3) {
      return 0;
   }
   /* Set the time */
   mytel_flush(tel);
   sec=(int)(s);
   sprintf(ligne2,"%c%c%c%c%c%c00",h,min,sec,m,d,y-2000);
   sprintf(ligne,"puts -nonewline %s \"H%s\"",tel->channel,ligne2); mytel_tcleval(tel,ligne);
   sprintf(ligne,"after 150"); mytel_tcleval(tel,ligne);
   sprintf(ligne,"read %s 1",tel->channel); mytel_tcleval(tel,ligne);
   sprintf(ligne,"after 50"); mytel_tcleval(tel,ligne);
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   char s[1024],ss[1024],signe[3],ew[3];
   double longitude,latitude;
   char lond,lonm,lons,lonew,latd,latm,lats,latns;
   /* Get the location */
   if (tel->version<2.3) {
      longitude=0.;
      latitude=0.;
      strcpy(signe,"");
      strcpy(ew,"e");
   } else {
      mytel_flush(tel);
      sprintf(s,"puts -nonewline %s \"w\"",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"after 150"); mytel_tcleval(tel,s);
      sprintf(s,"read %s 9",tel->channel); mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      latd=ss[0];
      latm=ss[1];
      lats=ss[2];
      latns=ss[3];
      lond=ss[4];
      lonm=ss[5];
      lons=ss[6];
      lonew=ss[7];
      latitude=(double)latd+(double)latm/60.+(double)lats/3600.;
      if (latns=='1') {
         strcpy(signe,"-");
      } else {
         strcpy(signe,"");
      }
      longitude=(double)lond+(double)lonm/60.+(double)lons/3600.;
      if (lonew=='1') {
         strcpy(ew,"w");
      } else {
         strcpy(ew,"e");
      }
   }
   /* Returns the result */
   sprintf(ligne,"GPS %f %s %s%f 0",longitude,ew,signe,latitude);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   char ligne[1024],ligne1[1024],ligne2[1024];
   char lond,lonm,lons,lonew,latd,latm,lats,latns;
   /* Set the longitude */
   if (tel->version<2.3) {
      return 0;
   }
   mytel_flush(tel);
   sprintf(ligne,"mc_angle2dms %f 360 nozero 0 auto list",longitude); mytel_tcleval(tel,ligne);
   strcpy(ligne1,Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"lindex %s 0",ligne1); mytel_tcleval(tel,ligne);
   lond=(unsigned char)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"lindex %s 1",ligne1); mytel_tcleval(tel,ligne);
   lonm=(unsigned char)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"lindex %s 2",ligne1); mytel_tcleval(tel,ligne);
   lons=(unsigned char)atoi(Tcl_GetStringResult(tel->interp));
   if ((strcmp(ew,"E")==0)||(strcmp(ew,"e")==0)) {
      lonew=(unsigned char)0;
   } else {
      lonew=(unsigned char)1;
   }
   /* Set the latitude */
   mytel_flush(tel);
   sprintf(ligne,"mc_angle2dms %f 360 nozero 0 auto list",fabs(latitude)); mytel_tcleval(tel,ligne);
   strcpy(ligne1,Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"lindex %s 0",ligne1); mytel_tcleval(tel,ligne);
   latd=(unsigned char)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"lindex %s 1",ligne1); mytel_tcleval(tel,ligne);
   latm=(unsigned char)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"lindex %s 2",ligne1); mytel_tcleval(tel,ligne);
   lats=(unsigned char)atoi(Tcl_GetStringResult(tel->interp));
   if (latitude>0) {
      latns=(unsigned char)0;
   } else {
      latns=(unsigned char)1;
   }
   sprintf(ligne2,"%c%c%c%c%c%c%c%c00",latd,latm,lats,latns,lond,lonm,lons,lonew);
   sprintf(ligne,"puts -nonewline %s \"W%s\"",tel->channel,ligne2); mytel_tcleval(tel,ligne);
   sprintf(ligne,"after 150"); mytel_tcleval(tel,ligne);
   sprintf(ligne,"read %s 1",tel->channel); mytel_tcleval(tel,ligne);
   sprintf(ligne,"after 50"); mytel_tcleval(tel,ligne);
   return 0;
}
/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_get_format(struct telprop *tel)
{
   int k;
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   if (tel->version>=2.2) {
      k=1;
      tel->longformatindex=1;
   } else {
      k=0;
      tel->longformatindex=0;
   }
   return k;
}

int mytel_set_format(struct telprop *tel,int longformatindex)
{
   int k=0;
   tel->longformatindex=0;
   if (mytel_get_format(tel)==1) {
      if (longformatindex==1) {
         tel->longformatindex=longformatindex;
         k=1;
      }
   }
   return k;
}

int mytel_flush(struct telprop *tel)
/* flush the input channel until nothing is received */
{
   char s[1024];
   int k=0;
   while (1==1) {
      sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      if (strcmp(s,"")==0) {
         return k;
      }
      k++;
   }
}

//#define MOUCHARD

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_celestron.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD)
   fprintf(f,"# [%d] = %s\n", result, Tcl_GetStringResult(tel->interp));
   fclose(f);
#endif
   return result;
}

int mytel_correct(struct telprop *tel,char *direction, int duration)
{
   char s[200];
   sprintf(s,"puts -nonewline %s \"#:Mg%s%04d#\"",tel->channel, direction, duration); mytel_tcleval(tel,s);
   return 0;
}
