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
#include <libtel/libtel.h>
#include <libtel/util.h>


 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"AudeCom",    /* telescope name */
    "AudeCom",    /* protocol name */
    "audecom",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

/********************************************************/
/* sate_move_radec                                      */
/* ' ' : pas de mouvement                               */
/* 'L' : mouvement demande en mode LX200 (radec move)   */
/* 'A' : mouvement demande en mode Audecom (radec goto) */
/*                                                      */
/* sate_move_focus                                      */
/* ' ' : pas de mouvement                               */
/* 'L' : mouvement demande en mode LX200 (focus move)   */
/* 'A' : mouvement demande en mode Audecom (focus goto) */
/********************************************************/
char sate_move_radec;
char sate_move_focus;

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
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -blocking 0",tel->channel); mytel_tcleval(tel,s);
   tel->tempo=150;
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   kauf_set_natif(tel);
   strcpy(tel->v_firmware,"");
   kauf_v_firmware(tel);
   tel->slewpathindex=0;
   tel->langageindex=0;
   sate_move_radec=' ';
   sate_move_focus=' ';
   tel->boostindex=0;
   tel->ra_backlash=(double)0.;
   tel->dec_backlash=(double)0.;
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   char s[1024];
   int result=0;
   /* --- Demande ra */
   sprintf(s,"puts -nonewline %s \"A \r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie HHMMSS */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"")==0) {
      result=0;
   } else {
      result=1;
   }
   return result;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   kauf_delete(tel);
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
/* it corresponds to the "match" function of an LX200 */
{
   kauf_match(tel);
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   char s[1024];
   char coord0[50],coord1[50];
   tel_radec_coord(tel,coord0);
   sprintf(s,"after 350"); mytel_tcleval(tel,s);
   tel_radec_coord(tel,coord1);
   if (strcmp(coord0,coord1)==0) {strcpy(result,"tracking");}
   else {strcpy(result,"pointing");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024];
   char coord0[50],coord1[50];
   int time_in=0,time_out=1000;
   double ra00,dec00,dra,ddec;

   if ( tel->active_backlash == 0 ) {
      kauf_goto(tel);
      sate_move_radec='A';
      if (tel->radec_goto_blocking==1) {
         /* A loop is actived until the telescope is stopped */
         tel_radec_coord(tel,coord0);
         while (1==1) {
      	   time_in++;
            sprintf(s,"after 350"); mytel_tcleval(tel,s);
            tel_radec_coord(tel,coord1);
            if (strcmp(coord0,coord1)==0) {break;}
            strcpy(coord0,coord1);
	         if (time_in>=time_out) {break;}
         }
         sate_move_radec=' ';
      }
   } else {
      /* --- rattrapage de jeux ---*/
      /* on est obligatoirement en mode bloquant */
      ra00=tel->ra0;
      dec00=tel->dec0;
      kauf_coord(tel,coord0);
      /* --- dra<0 si on doit aller vers l'est */
      /* --- dra>0 si on doit aller vers l'ouest */
      sprintf(s,"expr [mc_anglescomp [lindex {%s} 0] + 360]-%f",coord0,tel->ra0); mytel_tcleval(tel,s);
      dra=(double)atof(Tcl_GetStringResult(tel->interp));
      if (dra>=360.) { dra=dra-360.; }
      if (dra>=360.) { dra=dra-360.; }
      if (dra>180.) { dra=dra-360.; }
      /* --- ddec<0 si on doit aller vers le nord */
      /* --- ddec>0 si on doit aller vers le sud */
      sprintf(s,"expr [mc_angle2deg [lindex {%s} 1] ]-%f",coord0,tel->dec0); mytel_tcleval(tel,s);
      ddec=(double)atof(Tcl_GetStringResult(tel->interp));
      /* --- on considere qu'il y a un jeu a             */
      /*     rattraper lorsque le raliement met          */
      /*     en jeu un mouvement vers l'est (dra<0) et   */
      /*     un mouvement vers le nord (ddec<0)          */
      /* Table des raliements :                                         */
      /*                     dra>0                 dra<0                */
      /* slewpathindex=0 :                       ra0=ra00-tel->ra_backlash  */
      /*                   ra0=ra00              ra0=ra00               */
      /* slewpathindex=1 : ra0=ra00-tel->ra_backlash                        */
      /*                   ra0=ra00              ra0=ra00               */
      //nbgoto=1;
      if ((dra<0)&&(tel->slewpathindex==0)) {
         tel->ra0=ra00+tel->ra_backlash;
         sprintf(s,"mc_angle2deg \"[mc_angle2hms %7f 360] h\"",tel->ra0); mytel_tcleval(tel,s);
         tel->ra0=(double)atof(Tcl_GetStringResult(tel->interp));
      }
      if ((dra>0)&&(tel->slewpathindex==1)) {
         tel->ra0=ra00+tel->ra_backlash;
         sprintf(s,"mc_angle2deg \"[mc_angle2hms %7f 360] h\"",tel->ra0); mytel_tcleval(tel,s);
         tel->ra0=(double)atof(Tcl_GetStringResult(tel->interp));
      }
      if ((ddec<0)&&(tel->slewpathindex==0)) {
         tel->dec0=dec00-tel->dec_backlash;
         sprintf(s,"mc_angle2deg [mc_angle2dms %7f 90]",tel->dec0); mytel_tcleval(tel,s);
         tel->dec0=(double)atof(Tcl_GetStringResult(tel->interp));
      }
      if ((ddec>0)&&(tel->slewpathindex==1)) {
         tel->dec0=dec00-tel->dec_backlash;
         sprintf(s,"mc_angle2deg [mc_angle2dms %7f 90]",tel->dec0); mytel_tcleval(tel,s);
         tel->dec0=(double)atof(Tcl_GetStringResult(tel->interp));
      }
      /* --- premier goto ---*/
      kauf_goto(tel);

      if (tel->radec_goto_blocking==1) {
      
         sate_move_radec='A';
         /* A loop is actived until the telescope is stopped */
         tel_radec_coord(tel,coord0);
         while (1==1) {
            time_in++;
            sprintf(s,"after 350"); mytel_tcleval(tel,s);
            tel_radec_coord(tel,coord1);
            if (strcmp(coord0,coord1)==0) {break;}
            strcpy(coord0,coord1);
	         if (time_in>=time_out) {break;}
         }
         sate_move_radec=' ';
         tel->ra0=ra00;
      }
      tel->dec0=dec00;      
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   /* passage en mode LX200 */
   kauf_lx200(tel);
   /* LX200 protocol has 4 motion rates */
   if ((tel->radec_move_rate<=0.25)) {
      /* Guide */
      sprintf(s,"puts -nonewline %s \"#:RG#\"",tel->channel); mytel_tcleval(tel,s);
   } else if ((tel->radec_move_rate>0.25)&&(tel->radec_move_rate<=0.5)) {
      /* Center */
      sprintf(s,"puts -nonewline %s \"#:RC#\"",tel->channel); mytel_tcleval(tel,s);
   } else if ((tel->radec_move_rate>0.5)&&(tel->radec_move_rate<=0.75)) {
      /* Find */
      sprintf(s,"puts -nonewline %s \"#:RM#\"",tel->channel); mytel_tcleval(tel,s);
   } else if ((tel->radec_move_rate>0.75)) {
      /* Slew */
      sprintf(s,"puts -nonewline %s \"#:RS#\"",tel->channel); mytel_tcleval(tel,s);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
   if (strcmp(direc,"N")==0) {
      sprintf(s,"puts -nonewline %s \"#:Mn#\"",tel->channel); mytel_tcleval(tel,s);
      sate_move_radec='L';
   } else if (strcmp(direc,"S")==0) {
      sprintf(s,"puts -nonewline %s \"#:Ms#\"",tel->channel); mytel_tcleval(tel,s);
      sate_move_radec='L';
   } else if (strcmp(direc,"E")==0) {
      sprintf(s,"puts -nonewline %s \"#:Me#\"",tel->channel); mytel_tcleval(tel,s);
      sate_move_radec='L';
   } else if (strcmp(direc,"W")==0) {
      sprintf(s,"puts -nonewline %s \"#:Mw#\"",tel->channel); mytel_tcleval(tel,s);
      sate_move_radec='L';
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   /* passage en mode natif */
   kauf_set_natif(tel);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   if (sate_move_radec=='L') {
      /* passage en mode LX200 */
      kauf_lx200(tel);
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,Tcl_GetStringResult(tel->interp));
      if (strcmp(direc,"N")==0) {
         sprintf(s,"puts -nonewline %s \"#:Qn#\"",tel->channel); mytel_tcleval(tel,s);
         sate_move_radec=' ';
      } else if (strcmp(direc,"S")==0) {
         sprintf(s,"puts -nonewline %s \"#:Qs#\"",tel->channel); mytel_tcleval(tel,s);
         sate_move_radec=' ';
      } else if (strcmp(direc,"E")==0) {
         sprintf(s,"puts -nonewline %s \"#:Qe#\"",tel->channel); mytel_tcleval(tel,s);
         sate_move_radec=' ';
      } else if (strcmp(direc,"W")==0) {
         sprintf(s,"puts -nonewline %s \"#:Qw#\"",tel->channel); mytel_tcleval(tel,s);
         sate_move_radec=' ';
      } else {
         sprintf(s,"puts -nonewline %s \"#:Q#\"",tel->channel); mytel_tcleval(tel,s);
         sprintf(s,"after 50"); mytel_tcleval(tel,s);
         sprintf(s,"puts -nonewline %s \"#:Qn#\"",tel->channel); mytel_tcleval(tel,s);
         sprintf(s,"after 50"); mytel_tcleval(tel,s);
         sprintf(s,"puts -nonewline %s \"#:Qs#\"",tel->channel); mytel_tcleval(tel,s);
         sprintf(s,"after 50"); mytel_tcleval(tel,s);
         sprintf(s,"puts -nonewline %s \"#:Qe#\"",tel->channel); mytel_tcleval(tel,s);
         sprintf(s,"after 50"); mytel_tcleval(tel,s);
         sprintf(s,"puts -nonewline %s \"#:Qw#\"",tel->channel); mytel_tcleval(tel,s);
         sprintf(s,"after 50"); mytel_tcleval(tel,s);
         sate_move_radec=' ';
      }
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      /* passage en mode natif */
      kauf_set_natif(tel);
   } else {
      kauf_arret_pointage(tel);
      sate_move_radec=' ';
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"after 20"); mytel_tcleval(tel,s);
   if (tel->radec_motor==1) {
      /* stop the motor */
      kauf_suivi_arret(tel);
   } else {
      /* start the motor */
      kauf_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   kauf_coord(tel,result);
   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   kauf_foc_zero(tel);
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   char s[1024];
   char coord0[50],coord1[50];
   int time_in=0,time_out=1000;

   kauf_foc_goto(tel);
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      tel_radec_coord(tel,coord0);
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
         tel_focus_coord(tel,coord1);
         if (strcmp(coord0,coord1)==0) {break;}
         strcpy(coord0,coord1);
	     if (time_in>=time_out) {break;}
      }
   }
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   /* passage en mode LX200 */
   kauf_lx200(tel);
   /* LX200 protocol has 2 motion rates */
   if (tel->focus_move_rate<=0.5) {
      /* Slow */
      sprintf(s,"puts -nonewline %s \"#:FS#\"",tel->channel); mytel_tcleval(tel,s);
   } else if (tel->focus_move_rate>0.5) {
      /* Fast */
      sprintf(s,"puts -nonewline %s \"#:FF#\"",tel->channel); mytel_tcleval(tel,s);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
   if (strcmp(direc,"+")==0) {
      sprintf(s,"puts -nonewline %s \"#:F+#\"",tel->channel); mytel_tcleval(tel,s);
      sate_move_focus='L';
   } else if (strcmp(direc,"-")==0) {
      sprintf(s,"puts -nonewline %s \"#:F-#\"",tel->channel); mytel_tcleval(tel,s);
      sate_move_focus='L';
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   /* passage en mode natif */
   kauf_set_natif(tel);
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   char s[1024];
   if (sate_move_focus=='L') {
      /* passage en mode LX200 */
      kauf_lx200(tel);
      sprintf(s,"puts -nonewline %s \"#:FQ#\"",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"after 50"); mytel_tcleval(tel,s);
      /* passage en mode natif */
      kauf_set_natif(tel);
      sate_move_focus=' ';
   } else {
      sate_move_focus=' ';
   }
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   kauf_foc_coord(tel,result);
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   libtel_GetCurrentUTCDate(tel->interp,ligne);
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,tel->home);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   return 0;
}
/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {return 1;}
   return 0;
}


/* ================================================================ */
/* Ces fonctions etaient ecrites par en Tcl par Robert Delmas.      */
/* ================================================================ */

int kauf_delete(struct telprop *tel)
{
   char s[1024];
   /* --- passage en mode LX200 */
   kauf_lx200(tel);
   /* --- Fermeture du port com */
   sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage AUDECOM -----------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int kauf_set_natif (struct telprop *tel)
{
   char s[1024];
   /* --- Passe en mode natif */
   sprintf(s,"puts -nonewline %s \"#:Lx#\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Inihibe l'echo des commandes entrantes */
   sprintf(s,"puts -nonewline %s \"E\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit le port serie pour supprimer l'echo de E */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Deuxieme lecture -- supprime une anomalie lors du passage de E --> e --> E */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_echo_supprime (struct telprop *tel)
{
   char s[1024];
   /* --- Inihibe l'echo des commandes entrantes */
   sprintf(s,"puts -nonewline %s \"E\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit le port serie pour supprimer l'echo de E */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Deuxieme lecture -- supprime une anomalie lors du passage de E --> e --> E */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_echo_ok (struct telprop *tel)
{
   char s[1024];
   /*--- Active l'echo des commandes entrantes */
   sprintf(s,"puts -nonewline %s \"e\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_reset_tel(struct telprop *tel)
{
   char s[1024];
   /* --- Reset telescope sur gamma Cas ou epsilon UMa */
   sprintf(s,"puts -nonewline %s \"z\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_reset_carte(struct telprop *tel)
{
   char s[1024];
   /*--- Reset carte AudeCom */
   sprintf(s,"puts -nonewline %s \"o\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}


int kauf_v_firmware (struct telprop *tel)
{
   char s[1024];
   /* --- Retourne la version du firmware du microcontroleur */
   /* --- Demande le numero de la version */
   sprintf(s,"puts -nonewline %s \"V\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la version sur le port serie */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(tel->v_firmware,Tcl_GetStringResult(tel->interp));
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_arret_pointage(struct telprop *tel)
{
   char s[1024];
   /*--- Arret pointage */
   sprintf(s,"puts -nonewline %s \"s\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_arret_pointage1(struct telprop *tel)
{
   char s[1024];
   /*--- Arret pointage */
   sprintf(s,"puts -nonewline %s \"s\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_lx200(struct telprop *tel)
{
   char s[1024];
   /*--- Passe en mode lx200 */
   sprintf(s,"puts -nonewline %s \"x\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_coord(struct telprop *tel,char *result)
{
   char s[1024];
   char ss[256];
   /* --- Demande ra */
   sprintf(s,"puts -nonewline %s \"A \r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la version sur le port serie HHMMSS */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"")==0) { strcpy(s,"000000"); }
   /* --- transforme en HHhMMmSSs */
   kauf_angle_ra2hms(s,ss);
   sprintf(result,"%s ",ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Demande dec */
   sprintf(s,"puts -nonewline %s \"D \r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la version sur le port serie SDDMMSS */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"")==0) { strcpy(s,"000000"); }
   /* --- transforme en SDDdMMmSSs */
   kauf_angle_dec2dms(s,ss);
   strcat(result,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_match(struct telprop *tel)
{
   char s[1024];
   char ss[256];
   /* --- transforme en tel->ra0 en HHMMSS */
   sprintf(s,"%f",tel->ra0);
   kauf_angle_hms2ra(tel,s,ss);
   /* --- envoie la mise a jour de ra */
   sprintf(s,"puts -nonewline %s \"w%s\r\"",tel->channel,ss); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- transforme en tel->dec0 en SDDMMSS */
   sprintf(s,"%f",tel->dec0);
   kauf_angle_dms2dec(tel,s,ss);
   /* --- envoie la mise a jour de dec */
   sprintf(s,"puts -nonewline %s \"y%s\r\"",tel->channel,ss); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_goto(struct telprop *tel)
{
   char s[1024];
   char ss[256];
   char signe[256];
   /* --- transforme en tel->ra0 en HHMMSS */
   sprintf(s,"%f",tel->ra0);
   kauf_angle_hms2ra(tel,s,ss);
   if (tel->slewpathindex==0) {
      strcpy(signe,"");
   } else {
      strcpy(signe,"-");
   }
   /* --- envoie du goto de ra */
   sprintf(s,"puts -nonewline %s \"a%s%s\r\"",tel->channel,signe,ss); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- transforme en tel->dec0 en SDDMMSS */
   sprintf(s,"%f",tel->dec0);
   kauf_angle_dms2dec(tel,s,ss);
   /* --- envoie la mise a jour de dec */
   sprintf(s,"puts -nonewline %s \"d%s\r\"",tel->channel,ss); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_vit_maxi_ar(struct telprop *tel,int speed)
{
   char s[1024];
   /* ---  */
   if (speed<4) {speed=4;}
   if (speed>16) {speed=16;}
   sprintf(s,"puts -nonewline %s \"m%02d\r\"",tel->channel,speed); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_vit_maxi_dec(struct telprop *tel,int speed)
{
   char s[1024];
   /* ---  */
   if (speed<4) {speed=4;}
   if (speed>16) {speed=16;}
   sprintf(s,"puts -nonewline %s \"n%02d\r\"",tel->channel,speed); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_suivi_arret (struct telprop *tel)
{
   char s[1024];
   /* ---  */
   sprintf(s,"puts -nonewline %s \"p\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_suivi_marche (struct telprop *tel)
{
   char s[1024];
   /* ---  */
   sprintf(s,"puts -nonewline %s \"P\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_angle_ra2hms(char *in, char *out)
{
   sprintf(out,"%c%ch%c%cm%c%cs",in[0],in[1],in[2],in[3],in[4],in[5]);
   return 0;
}

int kauf_angle_dec2dms(char *in, char *out)
{
   /* --- transforme SDDMMSS en +DDdMMmSSs */
   if (in[0]=='-') {
      sprintf(out,"-%c%cd%c%cm%c%cs",in[1],in[2],in[3],in[4],in[5],in[6]);
   } else {
      sprintf(out,"+%c%cd%c%cm%c%cs",in[0],in[1],in[2],in[3],in[4],in[5]);
   }
   return 0;
}

int kauf_angle_hms2ra(struct telprop *tel, char *in, char *out)
{
   char s[1024];
   /* --- transforme Angle en HHhMMmSSs0 */
   sprintf(s,"mc_angle2hms %s 360 zero 0 auto string",in); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   /* --- transforme HHhMMmSSs0 en HHMMSS */
   sprintf(out,"%c%c%c%c%c%c",s[0],s[1],s[3],s[4],s[6],s[7]);
   return 0;
}

int kauf_angle_dms2dec(struct telprop *tel, char *in, char *out)
{
   char s[1024];
   /* --- transforme Angle en +DDdMMmSSs0 */
   sprintf(s,"mc_angle2dms %s 90 zero 0 + string",in); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   /* --- transforme +DDdMMmSSs0 en +DDMMSS */
   if (s[0]=='-') {
      sprintf(out,"-%c%c%c%c%c%c",s[1],s[2],s[4],s[5],s[7],s[8]);
   } else {
      sprintf(out,"%c%c%c%c%c%c",s[1],s[2],s[4],s[5],s[7],s[8]);
   }
   return 0;
}

int kauf_nb_tics_ad(struct telprop *tel,int *ticks)
{
   char s[1024];
   /* --- Demande le nombre de tics en AD */
   sprintf(s,"puts -nonewline %s \"W\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit le nombre renvoye par le microcontroleur */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"")==0) { strcpy(s,"00000000"); }
   *ticks=(int)atoi(s);
   return 0;
}

int kauf_nb_tics_dec(struct telprop *tel,int *ticks)
{
   char s[1024];
   /* --- Demande le nombre de tics en Dec */
   sprintf(s,"puts -nonewline %s \"Y\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit le nombre renvoye par le microcontroleur */
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"")==0) { strcpy(s,"00000000"); }
   *ticks=(int)atoi(s);
   return 0;
}

int kauf_foc_zero(struct telprop *tel)
{
   char s[1024];
   /* --- Met le compteur FOC a zero */
   sprintf(s,"puts -nonewline %s \"g\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_foc_vit(struct telprop *tel, int vfoc)
{
   char s[1024];
   /* --- Vitesse moteur de focalisation */
   sprintf(s,"puts -nonewline %s \"h%d\r\"",tel->channel,vfoc); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_foc_coord(struct telprop *tel,char *result)
{
   char s[1024];
   /*--- Lit la position courante de la FOC*/
   /*--- Demande foc */
   sprintf(s,"puts -nonewline %s \"F\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /*--- Lit foc sur le port serie*/
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(result,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"")==0) { strcpy(s,"00000000"); }
   return 0;
}

int kauf_foc_goto(struct telprop *tel)
{
   char s[1024];
   int focus0;
   /* --- envoie du goto de focus */
   focus0=(int)(tel->focus0);
   sprintf(s,"puts -nonewline %s \"f%d\r\"",tel->channel,focus0); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_derive_ar(struct telprop *tel,int var)
{
   char s[1024];
   /*--- Derive du suivi en ar*/
   sprintf(s,"puts -nonewline %s \"u%d\r\"",tel->channel,var); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_derive_dec(struct telprop *tel,int vdec)
{
   char s[1024];
   /*--- Derive du suivi en dec*/
   sprintf(s,"puts -nonewline %s \"v%d\r\"",tel->channel,vdec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_king(struct telprop *tel,int vking)
{
   char s[1024];
   /*--- Derive du suivi en ar*/
   sprintf(s,"puts -nonewline %s \"k%d\r\"",tel->channel,vking); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_active_boost(struct telprop *tel)
{
   char s[1024];
   /*--- Active accelerateur du micocontroleur seulement pour la marque TEMIC*/
   sprintf(s,"puts -nonewline %s \"b\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_inhibe_boost(struct telprop *tel)
{
   char s[1024];
   /*--- Inhibe accelerateur du micocontroleur seulement pour la marque TEMIC*/
   sprintf(s,"puts -nonewline %s \"b\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_largeur_impulsion(struct telprop *tel,int limp)
{
   char s[1024];
   /*--- Reglage de la largeur de l'impulsion de commande des moteurs pas a pas en petite vitesse seulement*/
   sprintf(s,"puts -nonewline %s \"l%d\r\"",tel->channel,limp); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_inhibe_pec(struct telprop *tel)
{
   char s[1024];
   /*--- Inhibe le pec et met son index a 0, on pointe sur la premiere case du tableau*/
   sprintf(s,"puts -nonewline %s \"R\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_periode_pec(struct telprop *tel,int ppec)
{
   char s[1024];
   /* --- Ecrit la periodicite du pec, active et initialise le pec (valeur de 1 a 360) */
   sprintf(s,"puts -nonewline %s \"r%d\r\"",tel->channel,ppec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_pointeur_pec(struct telprop *tel,int *indexpec)
{
   char s[1024];
   /*--- Retourne la valeur du pointeur du tableau du pec*/
   /*--- Demande l'index du tableau du pec*/
   sprintf(s,"puts -nonewline %s \"I\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /*--- Lit l'index sur le port serie*/
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strcmp(s,"")==0) { strcpy(s,"0"); }
   *indexpec=(int)(atoi(s));
   return 0;
}

int kauf_pointe_case_pec(struct telprop *tel,int pcpec)
{
   char s[1024];
   /*--- Pointe la case pcpec du tableau du pec, tableau de 20 cases (0 a 19)*/
   sprintf(s,"puts -nonewline %s \"i%d\r\"",tel->channel,pcpec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_lit_vit_pec(struct telprop *tel,int *vitpec)
{
   char s[1024];
   /*--- Retourne la vitesse de suivi courante et incremente l'index*/
   /*--- Demande la vitesse de correction du pec*/
   sprintf(s,"puts -nonewline %s \"T\r\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /*--- Lit la vitesse de correction sur le port serie*/
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   if (strcmp(s,"")==0) { strcpy(s,"0"); }
   *vitpec=(int)(atoi(Tcl_GetStringResult(tel->interp)));
   return 0;
}

int kauf_ecrit_vit_pec(struct telprop *tel,int evpec)
{
   char s[1024];
   /*--- Ecrit la correction de la vitesse de suivi et incremente automatiquement le pointeur evpec dans le tableau*/
   sprintf(s,"puts -nonewline %s \"t%d\r\"",tel->channel,evpec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* -----------------  langage LX200  -----------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int kauf_echo_supprime_lx200(struct telprop *tel)
{
   char s[1024];
   /* --- Inihibe l'echo des commandes lx200 entrantes */
   sprintf(s,"puts -nonewline %s \"#:LE#\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}


int kauf_echo_ok_lx200(struct telprop *tel)
{
   char s[1024];
   /*--- Active l'echo des commandes lx200 entrantes */
   sprintf(s,"puts -nonewline %s \"#:Le#\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_mode_telescope_lx200(struct telprop *tel,char *ack)
{
   char s[1024];
   /*--- Interroge le mode du telescope : seule reponse possible --> P pour Polaire (monture equatoriale) */
   sprintf(s,"set ascii_ack \"\6\""); mytel_tcleval(tel,s);
   sprintf(s,"puts -nonewline %s $ascii_ack",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /*--- Lit la reponse sur le port serie*/
   sprintf(s,"read %s 8",tel->channel); mytel_tcleval(tel,s);
   strcpy(ack,Tcl_GetStringResult(tel->interp));
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_format_lx200(struct telprop *tel,char *ack)
{
   char s[1024];
   /*--- Bascule format court --> format long  ou format long --> format court*/
   sprintf(s,"puts -nonewline %s \"#:U#\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_goto_lx200(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"mc_angle2lx200ra %f -format short",tel->ra0); mytel_tcleval(tel,s);
   /* Send Sr */
   sprintf(s,"puts -nonewline %s \"#:Sr %s#\"",tel->channel,Tcl_GetStringResult(tel->interp)); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"mc_angle2lx200dec %f -format short",tel->dec0); mytel_tcleval(tel,s);
   /* Send Sd */
   sprintf(s,"puts -nonewline %s \"#:Sd %s#\"",tel->channel,Tcl_GetStringResult(tel->interp)); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* Send MS */
   sprintf(s,"puts -nonewline %s \"#:MS#\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}

int kauf_match_lx200(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"mc_angle2lx200ra %f -format short",tel->ra0); mytel_tcleval(tel,s);
   /* Send Sr */
   sprintf(s,"puts -nonewline %s \"#:Sr %s#\"",tel->channel,Tcl_GetStringResult(tel->interp)); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   sprintf(s,"mc_angle2lx200dec %f -format short",tel->dec0); mytel_tcleval(tel,s);
   /* Send Sd */
   sprintf(s,"puts -nonewline %s \"#:Sd %s#\"",tel->channel,Tcl_GetStringResult(tel->interp)); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* Send MS */
   sprintf(s,"puts -nonewline %s \"#:CM#\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}
