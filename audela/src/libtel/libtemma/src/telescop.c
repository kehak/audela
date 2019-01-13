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

void mytel_logConsole(struct telprop *tel, char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   int result;
   
   // j'assemble la commande 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
   va_end (mkr);

   if ( strcmp(tel->telThreadId,"") == 0 ) {
      sprintf(ligne,"::console::disp \"Telescope: %s\" ",message); 
   } else {
      sprintf(ligne,"::thread::send -async %s { ::console::disp \"Telescope: %s\" } " , tel->mainThreadId, message); 
   }
   result = Tcl_Eval(tel->interp,ligne);
}

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"Temma",    /* telescope name */
    "Temma",    /* protocol name */
    "temma",    /* product */
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
/* 'A' : mouvement demande en mode Temma (radec goto)   */
/*                                                      */
/********************************************************/
char sate_move_radec;

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
   int i;
   double longitude,altitude;
   char ligne[256],ew[3];
  
   tel->consoleLog = 0;

   /*
   FILE *f;
   f=fopen("mouchard_temma.txt","wt");
   fclose(f);
   */
   // j'initialise à vide la position de l'observatoire 
   strcpy(tel->homePosition,"");

   // je recupere la position  de l'observatoire 
   for (i=3;i<argc-1;i++) {
      if (strcmp(argv[i],"-home")==0) {
         strncpy(tel->homePosition, argv[i+1],sizeof(tel->homePosition));
      }
      if (strcmp(argv[i],"-consolelog")==0) {
         tel->consoleLog = atoi( argv[i+1]);
      }
   }

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
   sprintf(s,"fconfigure %s -mode \"19200,e,8,1\" -buffering none -blocking 0",tel->channel); mytel_tcleval(tel,s);
   tel->tempo=250;
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   strcpy(tel->v_firmware,"");
   temma_v_firmware(tel);
   tel->ra_play=(double)0.;
   tel->dec_play=(double)0.;
   tel->slewpathindex=0;
   tel->encoder=(int)1;
   sate_move_radec=' ';

   if (strcmp(tel->homePosition,"")!= 0) {
      /* je calcule la longitude */
      sprintf(ligne,"lindex {%s} 1",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      longitude=(double)atof(Tcl_GetStringResult(tel->interp));
      sprintf(ligne,"string toupper [lindex {%s} 2]",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      if (strcmp(Tcl_GetStringResult(tel->interp),"W")==0) {
         strcpy(ew,"w");
      } else {
         strcpy(ew,"e");
      }
      /* je calcule la latitude */
      sprintf(ligne,"lindex {%s} 3",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      tel->latitude=(double)atof(Tcl_GetStringResult(tel->interp));
      /* extrait l'altitude */
      sprintf(ligne,"lindex {%s} 4",tel->homePosition);
      Tcl_Eval(tel->interp,ligne);
      altitude=(double)atof(Tcl_GetStringResult(tel->interp));

      /* send  latitude to mount*/
      mytel_home_set(tel, longitude, ew, tel->latitude, altitude);

      /* update site for local sideral time */
      temma_settsl(tel);
   }

   /* update E/W for the german mount */
   temma_coord(tel,ssres);
   
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   char  s[1024];
   char ss[1024];

   //--- interroge "automatic Introduction motion" juste pour savoir si la monture est connectee 
   sprintf(s,"puts -nonewline %s \"s\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);

   //--- Lit la chaine de resultat
   sprintf(s,"gets %s",tel->channel); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));

   // si la chaine est vide, la monture n'est pas connectee
   if (strcmp(ss,"")==0) {
      return 0;
   }

   return 1;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   temma_delete(tel);
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
   return temma_match(tel);
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int state;
   temma_stategoto(tel,&state);
   if (temma_motorstate(tel)==1) {
      // Cas du moteur RA en marche
      if (state==1) {
         strcpy(result,"tracking");
      } else if (state==2) {
         strcpy(result,"pointing");
      } else {
         strcpy(result,"unknown");
      }
   } else if (temma_motorstate(tel)==0) {
      // Cas du moteur RA arretes
      strcpy(result,"stopped");
   } else {
      // Cas du GOTO ou l'etat du moteur RA est indetermine
      strcpy(result,"pointing");
   }
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024];
   char coord0[50],coord1[50];
   int time_in=0,time_out=1000;
   double ra00,dec00,dra,ddec;
   int nbgoto=1,old;
   int result;

   if ((tel->ra_play==0.)&&(tel->dec_play==0.)) {
      result = temma_goto(tel);
      if (result == 0) {
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
      }
   } else {
      /* --- rattrapage de jeux ---*/
      /* on est obligatoirement en mode bloquant */
      ra00=tel->ra0;
      dec00=tel->dec0;
      temma_coord(tel,coord0);
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
      /* slewpathindex=0 :                       ra0=ra00-tel->ra_play  */
      /*                   ra0=ra00              ra0=ra00               */
      /* slewpathindex=1 : ra0=ra00-tel->ra_play                        */
      /*                   ra0=ra00              ra0=ra00               */
      nbgoto=1;
      if ((dra<0)&&(tel->slewpathindex==0)) {
         tel->ra0=ra00+tel->ra_play;
         sprintf(s,"mc_angle2deg \"[mc_angle2hms %7f 360] h\"",tel->ra0); mytel_tcleval(tel,s);
         tel->ra0=(double)atof(Tcl_GetStringResult(tel->interp));
         nbgoto=2;
      }
      if ((dra>0)&&(tel->slewpathindex==1)) {
         tel->ra0=ra00+tel->ra_play;
         sprintf(s,"mc_angle2deg \"[mc_angle2hms %7f 360] h\"",tel->ra0); mytel_tcleval(tel,s);
         tel->ra0=(double)atof(Tcl_GetStringResult(tel->interp));
         nbgoto=2;
      }
      if ((ddec<0)&&(tel->slewpathindex==0)) {
         tel->dec0=dec00-tel->dec_play;
         sprintf(s,"mc_angle2deg [mc_angle2dms %7f 90]",tel->dec0); mytel_tcleval(tel,s);
         tel->dec0=(double)atof(Tcl_GetStringResult(tel->interp));
         nbgoto=2;
      }
      if ((ddec>0)&&(tel->slewpathindex==1)) {
         tel->dec0=dec00-tel->dec_play;
         sprintf(s,"mc_angle2deg [mc_angle2dms %7f 90]",tel->dec0); mytel_tcleval(tel,s);
         tel->dec0=(double)atof(Tcl_GetStringResult(tel->interp));
         nbgoto=2;
      }
      /* --- premier goto ---*/
      result = temma_goto(tel);
      if (result == 0) {
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
         tel->dec0=dec00;
         /* --- second goto eventuel ---*/
         if (nbgoto==2) {
            old=tel->slewpathindex;
            tel->slewpathindex=0;
            result = temma_goto(tel);
            if (result == 0) {
               tel->slewpathindex=old;
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
            }
         }
      }
   }
   return result;
}

/* move e|w|s|n */
/*
* There are two type of speeds: Normal (N) and High (H)
* Normal speed can be parametrized by a value between 10 and 90%
*  on each axes (LA99 for RA and LB99 for DEC).
*
* The libtel parameter -rate is related to Temma speeds by the
* following rule :
* -rate >.90  => High speed mode is activated on each axes
* -rate <=.90 => Normal speed mode is activated on each axes
*               with the same parameters for  LA and LB
*
* Command M is following by an ASCII character which is defined
* by its 8-bits significance:
* Bit: Value = 0 Value = 1
*  1 y=1 Low Speed High Speed
*  2 d=2 RA Right
*  4 c=3 RA Left
*  8 b=4 DEC Up
* 16 a=5 DEC Down
* 32   6 Value = 0 : Encoder On (here always On) ; Encoder Off Value = 1
* 64   7 Always 1
*128   8 Always 0
*
*/
int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   int p,total,y=0,a=0,b=0,c=0,d=0;
   total=64; /* 010abcdy */

   /*tel1 encoder 1|0 ; attention : 0=encoder on, 1=encoder off*/
   if (tel->encoder==0) {
      total+=32; 
   }

   if (tel->radec_move_rate>0.9) {
      y=1;
   } else if (tel->radec_move_rate<0.1) {
   } else {
      p=(int)(tel->radec_move_rate*100);
      if (p>90) {p=90;}
      if (p<10) {p=10;}
      temma_LA(tel,p);
      temma_LB(tel,p);
   }

   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));

   if (strcmp(tel->ew,"W")==0) {
      if (strcmp(direc,"N")==0) {
         b=1;
      } else if (strcmp(direc,"S")==0) {
         a=1;
      } else if (strcmp(direc,"E")==0) {
         c=1;
      } else if (strcmp(direc,"W")==0) {
         d=1;
      }
   } else {
      /* inversion du sens N/S si tube a l'Est */
      if (strcmp(direc,"N")==0) {
         a=1;
      } else if (strcmp(direc,"S")==0) {
         b=1;
      } else if (strcmp(direc,"E")==0) {
         c=1;
      } else if (strcmp(direc,"W")==0) {
         d=1;
      }
   }
   total+=(16*a+8*b+4*c+2*d+y);
   sprintf(s,"puts -nonewline %s \"M%c\r\n\"",tel->channel,total); mytel_tcleval(tel,s);
   /* pas de reponse sur le port serie */
   return 0;
}

/* stop a goto or a move*/
/* la direction n'a aucune importance puisqu'on arrete */
int mytel_radec_stop(struct telprop *tel,char *direction)
{
   int total;
   char s[1024];
   if (sate_move_radec=='A') {
      /* on arrete un GOTO */
      temma_stopgoto(tel);
      sate_move_radec=' ';
   } else {
      /* on arrete un MOVE */
      total=64; /* 010abcdy with a=b=c=d=y=0*/
      /*tel1 encoder 1|0 ; attention : 0=encoder on, 1=encoder off*/
      if (tel->encoder==0) {
         total+=32; 
      }
      sprintf(s,"puts -nonewline %s \"M%c\r\n\"",tel->channel,total); mytel_tcleval(tel,s);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      /* --- pas de reponse sur le port serie */
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"after 20"); mytel_tcleval(tel,s);
   if (tel->radec_motor==1) {
      /* stop the motor */
      temma_suivi_arret(tel);
   } else {
      /* start the motor */
      temma_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   temma_coord(tel,result);
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
   libtel_GetCurrentUTCDate(tel->interp,ligne);
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,tel->homePosition);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   longitude=(double)fabs(longitude);
   if (longitude>360.) { longitude=0.; }
   if ((ew[0]!='w')&&(ew[0]!='W')&&(ew[0]!='e')&&(ew[0]!='E')) {
      ew[0]='E';      
   }
   if (latitude>90.) {latitude=90.;}
   if (latitude<-90.) {latitude=-90.;}
   temma_setlatitude(tel,latitude);
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
   /*
   FILE *f;
   f=fopen("mouchard_temma.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   */
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {return 1;}
   /*
   fprintf(f,"RESU <%s>\n",Tcl_GetStringResult(tel->interp));
   fclose(f);
   */
   return 0;
}

int temma_delete(struct telprop *tel)
{
   char s[1024];
   /* --- Fermeture du port com */
   sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage TEMMA   -----------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

/* Put latitude to microcontroller */
int temma_setlatitude(struct telprop *tel,double latitude)
{
   char s[1024];
   char slat[256];
   /* --- transforme en latitude en +/-SDDMMZ */
   sprintf(s,"%f",latitude);
   temma_angle_dms2dec(tel,s,slat);
   /* --- */
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "Set latitude=I%s\n", slat);
   }
   sprintf(s,"puts -nonewline %s \"I%s\r\n\"",tel->channel,slat); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- pas de reponse sur le port serie */
   return 0;
}

/* Get latitude from microcontroller*/
int temma_getlatitude(struct telprop *tel,double *latitude)
{
   char s[1024];
   char slat[256];

   sprintf(s,"puts -nonewline %s \"i\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 10",tel->channel); mytel_tcleval(tel,s);
   // --- transforme iSDDMMZ en latitude en degré
   // exemple : "i+43559" => mc_angle2deg { +43 55.9 }=> +43.93...
   strcpy(slat,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2deg {%c%c%c %c%c.%c}",slat[1],slat[2],slat[3],slat[4],slat[5],slat[6]); mytel_tcleval(tel,s);
   *latitude=atof(Tcl_GetStringResult(tel->interp));
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "reponse=%s latitude=%f\n", slat,*latitude);
   }   
   return 0;
}

/* Get TSL from microcontroller */
int temma_gettsl(struct telprop *tel,double *tsl)
{
   char s[1024];
   char slat[256];
   
   /* update local sideral time */
   temma_settsl(tel);
   
   /* --- */
   sprintf(s,"puts -nonewline %s \"g\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 10",tel->channel); mytel_tcleval(tel,s);
   /* --- transforme HHMMSS en tsl */
   strcpy(slat,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2deg \"%c%ch%c%cm%c%cs\"",slat[1],slat[2],slat[3],slat[4],slat[5],slat[6]); mytel_tcleval(tel,s);
   *tsl=atof(Tcl_GetStringResult(tel->interp));
   return 0;
}

/* Set Stellar rate */
int temma_stellar_rate(struct telprop *tel)
{
   char s[1024];
 
   sprintf(s,"puts -nonewline %s \"LL\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- pas de reponse sur le port serie */
   mytel_logConsole(tel, "Sideral traking\n");
   return 0;
}

/* Put RA-move speed (normal speed) to microcontroller */
int temma_LA (struct telprop *tel, int value)
{
   char s[1024];

   if (value<10) {value=10;}
   if (value>90) {value=90;}
   sprintf(s,"puts -nonewline %s \"LA%02d\r\n\"",tel->channel,value); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- pas de reponse sur le port serie */
   return 0;
}

/* Put DEC-move speed (normal speed) to microcontroller */
int temma_LB (struct telprop *tel, int value)
{
   char s[1024];

   if (value<10) {value=10;}
   if (value>90) {value=90;}
   sprintf(s,"puts -nonewline %s \"LB%02d\r\n\"",tel->channel,value); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- pas de reponse sur le port serie */
   return 0;
}

/* Read RA-move & DEC-move speed (normal speed) from microcontroller */
int temma_lg (struct telprop *tel, int *vra, int *vdec)
{
   char s[1024];
   char ss[256];

   sprintf(s,"puts -nonewline %s \"lg\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   /* decode le retour */
   strcpy(s,Tcl_GetStringResult(tel->interp));
   *vra=0;
   *vdec=0;
   if (strcmp(s,"")!=0) {
      sprintf(ss,"%c%c",s[2],s[3]);
      *vra=(int)atoi(ss);
      sprintf(ss,"%c%c",s[5],s[6]);
      *vdec=(int)atoi(ss);
   }
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "vra=%d vdec=%d\n",*vra,*vdec);
   }
   return 0;
}

/* Set Solar tracking */
int temma_solar_tracking(struct telprop *tel)
{
   char s[1024];
 
   sprintf(s,"puts -nonewline %s \"LK\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- pas de reponse sur le port serie */
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "Solar traking\n");
   }
   return 0;
}

/* Set Comete rate
LM+/-99999,+/-999 ### exemple envoi : LM+12345,-123\r\n
RA : Adjust Sidereal time by seconds per Day ### val RA min=-21541 max=+21541 (de 0.75X à 1.25X tracking sideral)
DEC : Adjust DEC tracking by Minutes Per Day ### val DEC min=-600 max=+600 (+/-10 deg par jour)
Example:
LM-120,+30 would slow the RA speed by 86164/86284
and the Dec would track at 30 Minutes a day.*/
int temma_set_comet_rate(struct telprop *tel,int ra_speed, int dec_speed)
{
   char s[1024];

   if (ra_speed<-99999) {ra_speed=-99999;}
   if (ra_speed>99999) {ra_speed=99999;}
   if (dec_speed<-9999) {dec_speed=-9999;}
   if (dec_speed>9999) {dec_speed=9999;}
   sprintf(s,"puts -nonewline %s \"LM%+d,%+d\r\n\"",tel->channel,ra_speed,dec_speed); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- pas de reponse sur le port serie */
   return 0;
}

/* Get Comet Speed
lm Note: This is a lower case "L"
Reply Structure:
0          1
12345  6789012  3456
lmLM+/-99999,+/-9999
RA Speed Adjustment,Dec Speed Adjustment

Note: RA Speed adjustment is how many RA seconds are added/subtracted per 24 hour period,
DEC adjustment is how many Minutes per 24 hour period.
*/
int temma_get_comet_rate(struct telprop *tel,int *ra_speed,int *dec_speed)
{
   char s[1024],ss[1024];
   int k,kdeb,kfin;
   int len,kf1,kd1,kf2,kd2;

   /* --- Demande radec */
   sprintf(s,"puts -nonewline %s \"lm\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   /* --- */
   len=(int)strlen(s);
   if (len<5) {
      *ra_speed=0;
      *dec_speed=0;
   } else {
      kd1=4;
      kf1=kd1;
      kd2=kd1;
      kf2=kd1;
      for (k=kd1;k<len;k++) {
         if (s[k]==',') {
            kf1=k-1;
            kd2=k+1;
            kf2=len;
            break;
         }
      }
      /* --- extrait dRA en sec/day */
      kdeb=kd1;
      kfin=kf1;
      for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
      ss[k-kdeb]='\0';
      *ra_speed=atoi(ss);
      /* --- extrait dDEC en arcmin/day */
      kdeb=kd2;
      kfin=kf2;
      for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
      ss[k-kdeb]='\0';
      *dec_speed=atoi(ss);
   }
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "Comete speed ra=%d seconds/24h dec=%d arcmin/24h\n",*ra_speed,*dec_speed);
   }
   return 0;
}

/* Read RA, DEC, Handbox state, Mount Side & Automatic introduction from microcontroller 
Reply structure:
0          1
12345678  901234    5
E999999+/-99999E/W/FH
H = Handbox (operational?)
E/W = Side of mount telescope is on
F = Automatic introduction complete after goto operation retour F F F
*/
int temma_coord(struct telprop *tel,char *result)
{
   char s[1024],ss[1024];
   char sra[256],sdec[256];
   int k,kdeb,kfin;

   /* --- Demande radec */
   sprintf(s,"puts -nonewline %s \"E\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));

   /* --- transforme RA en HHhMMmSSs */
   kdeb=1;
   kfin=6;
   for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
   ss[k-kdeb]='\0';
   temma_angle_ra2hms(ss,sra);

   /* --- transforme DEC en SDDdMMmSSs */
   kdeb=7;
   kfin=12;
   for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
   ss[k-kdeb]='\0';
   temma_angle_dec2dms(ss,sdec);

   /* -- decoder ici le sens E/W */
   if (s[13]=='E') {
      strcpy(tel->ew,"E");
   } else if (s[13]=='W') {
      strcpy(tel->ew,"W");
   } /* sinon c'est F et on ne modifie rien */
   kdeb=7;
   kfin=12;
   for (k=kdeb;k<=kfin;k++) { ss[k-kdeb]=s[k]; }
   ss[k-kdeb]='\0';

   if (tel->encoder==1) {
      /* --- update local sideral time */
      temma_settsl(tel);
      sprintf(s,"mc_angle2hms [mc_anglescomp %s + [expr %f - %f]] 360 zero 0 auto string",sra,tel->tsl00,tel->tsl); mytel_tcleval(tel,s);
      strcpy(sra,Tcl_GetStringResult(tel->interp));
   }
   sprintf(result,"%s %s",sra,sdec);
   return 0;
}

/* Do MATCH */
int temma_match(struct telprop *tel)
{
   char s[1024];
   char sra[256];
   char sdec[256];
   int result=0,len;

   /* --- transforme en tel->ra0 en HHMMZZ */
   sprintf(s,"%f",tel->ra0);
   temma_angle_hms2ra(tel,s,sra);

   /* --- transforme en tel->dec0 en +/-SDDMMZ */
   sprintf(s,"%f",tel->dec0);
   temma_angle_dms2dec(tel,s,sdec);

   /* --- update local sideral time */
   temma_settsl(tel);
   /* update last TSL Match */
   tel->tsl00=tel->tsl;
   
   /* --- set Zenith (bug of temma for resync) ---*/
   sprintf(s,"puts -nonewline %s \"Z\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);

   /* --- update radec */
   sprintf(s,"puts -nonewline %s \"D%s%s\r\n\"",tel->channel,sra,sdec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "Error Code Match=|%s|\n",s);
   }
   len=(int)strlen(s);
   if (len>=2) {
      if (strncmp(s,"R0",2)==0) {
         // OK
         strcpy(tel->msg, "");
         result=0;
      } else if (strncmp(s,"R1",2)==0) {
         // error synchro RA
         strcpy(tel->msg, "Error Synchro RA");
         result=1;
      } else if (strncmp(s,"R2",2)==0) {
         // error synchro DEC
         strcpy(tel->msg, "Error Synchro DEC");
         result=2;
      } else if (strncmp(s,"R3",2)==0) {
         // error too many digits
         result=3;
         strcpy(tel->msg, "Error too many Digits");
      } else if (strncmp(s,"R4",2)==0) {
         // error object under horizon
         result=4;
         strcpy(tel->msg, "Object below Horizon");
      }
   }
   if (tel->encoder==0) {
      tel->ha00=tel->ra0;
   }
   return result;
}

/* Do GOTO */
int temma_goto(struct telprop *tel)
{
   char s[1024];
   char sra[256];
   char sdec[256];
   int result;
   int len;

   /* --- transforme en tel->ra0 en HHMMZZ */
   sprintf(s,"%f",tel->ra0);
   temma_angle_hms2ra(tel,s,sra);

   /* --- transforme en tel->dec0 en +/-SDDMMZ */
   sprintf(s,"%f",tel->dec0);
   temma_angle_dms2dec(tel,s,sdec);

   /* --- envoie la mise a jour de radec */
   temma_settsl(tel);
   sprintf(s,"puts -nonewline %s \"P%s%s\r\n\"",tel->channel,sra,sdec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "Error Code Goto=|%s|\n",s);
   }
   len=(int)strlen(s);
   if (len>=2) {
      if (strncmp(s,"R0",2)==0) {
         strcpy(tel->msg, "");
         // OK
         result=0;
      } else if (strncmp(s,"R1",2)==0) {
         // error synchro RA
         strcpy(tel->msg, "Error GOTO RA");
         result=1;
      } else if (strncmp(s,"R2",2)==0) {
         // error synchro DEC
         strcpy(tel->msg, "Error GOTO DEC");
         result=2;
      } else if (strncmp(s,"R3",2)==0) {
         // error too many digits
         result=3;
         strcpy(tel->msg, "Error too many Digits");
      } else if (strncmp(s,"R4",2)==0) {
         // error object under horizon
         result=4;
         strcpy(tel->msg, "Object below Horizon");
      } else if (strncmp(s,"R5",2)==0) {
         // sate standby ON
         result=5;
         strcpy(tel->msg, "State Standby ON");
      }
   }
   return result;
}

/* MATCH at Zenith */
int temma_initzenith(struct telprop *tel)
{
   /* --- update local sideral time */
   temma_settsl(tel);
   tel->ra0=tel->tsl;
   
   /* update last TSL Match */
   tel->tsl00=tel->tsl;
   
   tel->dec0 = tel->latitude;
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "zenith tsl=%f\n", tel->tsl);
      mytel_logConsole(tel, "zenith dec0=%f\n", tel->dec0);
      mytel_logConsole(tel, "zenith ra0=%f\n", tel->ra0);
   }
  
   /* --- do MATCH */
   return temma_match(tel);
}

/* Do STOP (GOTO) */
int temma_stopgoto(struct telprop *tel)
{
   char s[1024];

   sprintf(s,"puts -nonewline %s \"PS\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* pas de reponse sur le port serie */
   return 0;
}

/* GOTO state*/
int temma_stategoto(struct telprop *tel,int *state)
{
   char s[1024];
   int result=0,len;

   sprintf(s,"puts -nonewline %s \"s\r\n\"",tel->channel); mytel_tcleval(tel,s);
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "State=s\n");
   }
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   // --- Lit la reponse sur le port serie
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "State result=|%s|\n", s);
   }
   len=(int)strlen(s);
   if (len>=2) {
      if (strncmp(s,"s0",2)==0) {
         // tracking
         result=1;
      } else if (strncmp(s,"s1",2)==0) {
         // pointing
         result=2;
      }
   }
   *state=result;
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "Result=|%d|\n", result);
   }
   return result;
}

// Retourne l'etat des moteurs
// 1  : Si les moteurs fonctionnent
// 0  : Si les moteurs sont hors tension
// -1 : Si Temma n'est pas connecte
int temma_motorstate(struct telprop *tel)
{
   char s[1024];
   int result;

   sprintf(s,"puts -nonewline %s \"STN-COD\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie */
   sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if ( tel->consoleLog >= 1 ) {
      mytel_logConsole(tel, "StateMotor=|%s|\n",s);
   }
   if ( strcmp(s,"stn-off\n") == 0 ) {
      result = 1;
   } else if ( strcmp(s,"stn-on\n") == 0 ) {
      result = 0;
   } else {
      result = -1;
   }
   return result;
}

/* Do tracking OFF */
int temma_suivi_arret (struct telprop *tel)
{
   char s[1024];

   sprintf(s,"puts -nonewline %s \"STN-ON\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie : stn_on*/
   /*sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   */
   return 0;
}

/* Do tracking ON */
int temma_suivi_marche (struct telprop *tel)
{
   char s[1024];

   sprintf(s,"puts -nonewline %s \"STN-OFF\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la reponse sur le port serie  : stn_off*/
   /*sprintf(s,"read %s 30",tel->channel); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));*/
   return 0;
}

/* Do manual MOUNTSIDESWITCH
 switch d'inversion de la position du telescope
si on fait PT depuis une position W la RA est augmentée de 12H
si on fait PT depuis une position E la RA est diminuée de 12H
*/
int temma_switchMountSide(struct telprop *tel,char *sens)
{
   char s[1024],ss[50];

   /* --- met a jour tel->ew */
   temma_coord(tel,s);

   sprintf(s,"lindex [string toupper %s] 0",sens); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
   if (ss[0]=='E') { 
      strcpy(ss,"E"); 
   } else { 
      strcpy(ss,"W"); 
   }
   if (strcmp(tel->ew,ss)!=0) {
      /*--- switch position W|E du tube */
      sprintf(s,"puts -nonewline %s \"PT\r\n\"",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      /* pas de reponse sur le port serie */
      mytel_logConsole(tel, "switch mount side from %s to %s\n", tel->ew,ss);
      strcpy(tel->ew,ss);
   }
   return 0;
}

/* Read firmware version from microntroller */
int temma_v_firmware (struct telprop *tel)
{
   char s[1024];

   /* --- Demande le numero de la version */
   sprintf(s,"puts -nonewline %s \"v\r\n\"",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Lit la version sur le port serie */
   sprintf(s,"read %s 35",tel->channel); mytel_tcleval(tel,s);
   strcpy(tel->v_firmware,Tcl_GetStringResult(tel->interp));
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage TEMMA TOOLS -------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

/* Set TSL */
int temma_settsl(struct telprop *tel)
{
   int h,m,sec;
   char s[1024];

   tel->tsl=temma_tsl(tel,&h,&m,&sec);
   sprintf(s,"puts -nonewline %s \"T%02d%02d%02d\r\n\"",tel->channel,h,m,sec); mytel_tcleval(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- pas de reponse sur le port serie */
   return 0;
}

/* Compute TSL */
double temma_tsl(struct telprop *tel,int *h, int *m,int *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;

   libtel_GetCurrentUTCDate(tel->interp,ss);
   sprintf(s,"mc_date2lst %s {%s}",ss,tel->homePosition); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
   *h=(int)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
   *m=(int)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 2",ss); mytel_tcleval(tel,s);
   *sec=(int)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss); mytel_tcleval(tel,s);
   tsl=atof(Tcl_GetStringResult(tel->interp)); /* en degres */
   return tsl;
}

/* Decode microcontroller RA */
int temma_angle_ra2hms(char *in, char *out)
{
   char ss[1024];
   int z;
   if ((int)strlen(in)<6) {
      strcpy(in,"000000");
   }
   sprintf(ss,"%c%c",in[4],in[5]);
   z=(int)floor(atof(ss)/100.*60.);
   sprintf(ss,"%02d",z);
   sprintf(out,"%c%ch%c%cm%c%cs",in[0],in[1],in[2],in[3],ss[0],ss[1]);
   return 0;
}

/* Decode microcontroller DEC  */
int temma_angle_dec2dms(char *in, char *out)
{
   char ss[1024];
   int z;
   if ((int)strlen(in)<6) {
      strcpy(in,"+00000");
   }
   sprintf(ss,"%c",in[5]);
   z=(int)floor(atof(ss)*6.);
   sprintf(ss,"%02d",z);
   /* --- transforme +SDDMMZ en +DDdMMmSSs */
   sprintf(out,"%c%c%cd%c%cm%c%cs",in[0],in[1],in[2],in[3],in[4],ss[0],ss[1]);
   return 0;
}

/* Encode RA for microcontroller */
int temma_angle_hms2ra(struct telprop *tel, char *in, char *out)
{
   char s[1024],ss[1024];
   int z;
   /* --- transforme Angle en HHhMMmSSs0 */
   sprintf(s,"mc_angle2hms %s 360 zero 0 auto string",in); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   /* --- transforme HHhMMmSSs0 en HHMMZZ ou ZZ sont min/100 */
   sprintf(ss,"%c%c",s[6],s[7]);
   z=(int)floor(atof(ss)/60.*100.);
   sprintf(ss,"%02d",z);
   sprintf(out,"%c%c%c%c%c%c",s[0],s[1],s[3],s[4],ss[0],ss[1]);
   return 0;
}

/* Encode DEC for microcontroller */
int temma_angle_dms2dec(struct telprop *tel, char *in, char *out)
{
   char s[1024],ss[1024];
   int z;

   /* --- transforme Angle en +DDdMMmSSs0 */
   sprintf(s,"mc_angle2dms %s 90 zero 0 + string",in); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   /* --- transforme +DDdMMmSSs0 en +DDMMZ ou Z sont arcmin/10 */
   sprintf(ss,"%c%c",s[7],s[8]);
   z=(int)floor(atof(ss)/60.*10.);
   sprintf(ss,"%01d",z);
   if (s[0]=='-') {
      sprintf(out,"-%c%c%c%c%c",s[1],s[2],s[4],s[5],ss[0]);
   } else {
      sprintf(out,"+%c%c%c%c%c",s[1],s[2],s[4],s[5],ss[0]);
   }
   return 0;
}
