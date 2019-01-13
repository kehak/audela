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
   {"LX200",    /* telescope name */
    "Lx200",    /* protocol name */
    "lx200",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
  	 1.        /* default focal lenght of optic system */
   },
};

// fonctions locales
void mytel_logConsole(struct telprop *tel, char *messageFormat, ...);

// types de retour du protocole lx200
#define RETURN_NONE   0
#define RETURN_CHAR  1
#define RETURN_STRING   2

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
   tel->tempo = 50;
   tel->consoleLog = 0; 
   tel->suiviOnFS2 = 1;
   tel->waitResponse = 1;
   
   // j'ouvre le port serie 
   //  # 9600 : vitesse de transmission (bauds)
   //  # 0 : 0 bit de parité
   //  # 8 : 8 bits de données
   //  # 1 : 1 bits de stop
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); mytel_tcleval(tel,s);
   mytel_flush(tel);

   // je recupere RA pour vérifier si le telescope est present
   if ( mytel_sendLX(tel, RETURN_STRING, s, "#:GR#",6) == 1 ) {
      // le telescope est present, j'active l'attente des reponses aux requetes
      tel->waitResponse = 1;
   } else {
      // le telescope n'est pas present, mais je continue quand meme pour permettre 
      // de faire des tests sans monture.
      // je desactive l'attente des reponses aux requetes 
      tel->waitResponse = 0;
   }

	//mytel_sendLXTempo(tel, RETURN_NONE, s, 5, "#:AP#");

   // je recupere le mode d'alignement (altaz ou polaire) 
   // j'envoie la chaine 0x06  et j'attend la réponse A=Altaz mode P=Polar mode L=land mode
   if ( mytel_sendLX(tel, RETURN_CHAR, s, "%c",6) == 1 ) {
      switch(s[0]) {
         case 'A' : 
            strcpy(tel->alignmentMode,"ALTAZ");
            break;
         case 'L' : 
            strcpy(tel->alignmentMode,"EQUATORIAL");
            break;
         case 'P' : 
            strcpy(tel->alignmentMode,"EQUATORIAL");
            break;
      }
   } else {
      // le telescope ne connait pas cette commande, je suppose qu'il est en mode equatorial
      strcpy(tel->alignmentMode,"EQUATORIAL");
   }

   // je configure la temporisation minimale entre l'envoi d'une commande 
   // et le retour du premier caractere de la réponse
   tel->tempo=50;

   strcpy(tel->autostar_char," ");
   tel->is_autostar=0;
   mytel_set_format(tel,0);

   if (strcmp(tel->name,"LX200") == 0  ) {
      // --- identify a LX200 GPS ---
      mytel_sendLXTempo(tel, RETURN_STRING, s, 5000, "#:GVP#");
      k=(int)strlen(s);
      if (k>=7) {
         // if (strcmp(s+k-7,"LX2001#")==0) { // remarque : la chaine retournee par mytel_sendLX ne contient pas #
         if (strcmp(s+k-7,"LX2001#")==0) {
            strcpy(tel->autostar_char,"");
            tel->tempo=800;
         }
	  }
	  if (strcmp(s,"Autostar")==0) {
		   tel->is_autostar=1;
		   tel->tempo=800;
		   strcpy(tel->autostar_char,"");
	  }
   }

   // je configure la correction de la refraction
   if ( strcmp(tel->name,"AudeCom") == 0 || strcmp(tel->name,"Ite-lente") == 0 ) {
      tel->refractionCorrection = 0; // la monture n'assure pas la correction de la refraction
   } else {
      tel->refractionCorrection = 1; // la monture assure la correction de la refraction
   }

   // je configure au protocole LX200 du FS2, different du protocole LX200 officiel
   if ( strcmp(tel->name,"FS2") == 0 ) {
      tel->reponseSRSD = RETURN_NONE; // ne pas attendre de reponse a une commande Sr, Sd ou MS
   } else {
      tel->reponseSRSD = RETURN_CHAR; // attendre la reponse d'un caractere a une commande Sr, Sd ou MS
   }

   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   if (mytel_get_format(tel)==1) {
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
/* it corresponds to the "match" function of an LX200 */
{
   char s[1024],ls[100],ss[1024];
   int nbcar_1,nbcar_2;
   /* get the short|long format */
   mytel_get_format(tel);
   if (tel->longformatindex==0) {
      strcpy(ls,"-format long");
      nbcar_1=9;
      nbcar_2=10;
   } else {
      strcpy(ls,"-format short");
      nbcar_1=8;
      nbcar_2=7;
   }

   
   // Send Sr
   sprintf(s,"mc_angle2lx200ra %f %s",tel->ra0,ls); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
   mytel_sendLX(tel, tel->reponseSRSD, s, "#:Sr%s%s#",tel->autostar_char,ss);
   // Send Sd 
   sprintf(s,"mc_angle2lx200dec %f %s",tel->dec0,ls); mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
    mytel_sendLX(tel, tel->reponseSRSD, s, "#:Sd%s%s#",tel->autostar_char,ss);
   // match
   mytel_sendLX(tel, RETURN_STRING, s, "#:CM#");
   return 0;
}

int mytel_radec_init_additional(struct telprop *tel)
/* it corresponds to the "additional synchonize for Losmandy Gemini */
/* sends :Cm# instead of :CM# for calculating the pointing model parameters and */
/* synchronizing to the position given.*/
 {
   char s[1024],ls[100];
   int nbcar_1,nbcar_2;
   /* get the short|long format */
   mytel_get_format(tel);
   if (tel->longformatindex==0) {
      strcpy(ls,"-format long");
      nbcar_1=9;
      nbcar_2=10;
   } else {
      strcpy(ls,"-format short");
      nbcar_1=8;
      nbcar_2=7;
   }
   
   sprintf(s,"mc_angle2lx200ra %f %s",tel->ra0,ls); mytel_tcleval(tel,s);
   // Send Sr 
   mytel_sendLX(tel, tel->reponseSRSD, s, "#:Sr%s%s#", tel->autostar_char, Tcl_GetStringResult(tel->interp));

   sprintf(s,"mc_angle2lx200dec %f %s",tel->dec0,ls); mytel_tcleval(tel,s);
   // Send Sd 
   mytel_sendLX(tel, tel->reponseSRSD, s, "#:Sd%s%s#", tel->autostar_char, Tcl_GetStringResult(tel->interp));

   // Send Cm 
   mytel_sendLX(tel, RETURN_STRING, s, "#:Cm#");

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
   char s[1024],ls[100],ss[1024];
   char coord0[50],coord1[50];
   int nbcar_1,nbcar_2,time_in=0,time_out=240;
   /* get the short|long format */
   mytel_get_format(tel);
   if (tel->longformatindex==0) {
      strcpy(ls,"-format long");
      nbcar_1=9;
      nbcar_2=10;
   } else {
      strcpy(ls,"-format short");
      nbcar_1=8;
      nbcar_2=7;
   }

   // Send Sr
   sprintf(s,"mc_angle2lx200ra %f %s",tel->ra0,ls); mytel_tcleval(tel,s);
   mytel_sendLX(tel, tel->reponseSRSD, s, "#:Sr%s%s#", tel->autostar_char, Tcl_GetStringResult(tel->interp));

   // Send Sd
   sprintf(s,"mc_angle2lx200dec %f %s",tel->dec0,ls); mytel_tcleval(tel,s);
   mytel_sendLX(tel, tel->reponseSRSD, s, "#:Sd%s%s#", tel->autostar_char, Tcl_GetStringResult(tel->interp));

   // Send MS
   mytel_sendLX(tel, tel->reponseSRSD, ss, "#:MS#");
   // mytel_logConsole(tel, "Goto reponse |%s|",ss);
   if (ss[0]=='1' ) {
      /* The telescope can not complete the slew and tells something*/
      strcpy(tel->msg, "Object below Horizon");
      mytel_flush(tel);
      return 1;
   }
   if (ss[0]=='2') {
      /* The telescope can not complete the slew and tells something*/
      strcpy(tel->msg, "Object below Higher");
      mytel_flush(tel);
      return 1;
   }
   /*sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);*/
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
      tel_radec_coord(tel,coord0);
      while (1==1) {
         time_in++;
         if ((strcmp(tel->autostar_char,"")==0)&&(time_in==1)) {
            sprintf(s,"after 3000"); mytel_tcleval(tel,s);
         } else {
            sprintf(s,"after 350"); mytel_tcleval(tel,s);
         }
         tel_radec_coord(tel,coord1);
         if (strcmp(coord0,coord1)==0) {break;}
         strcpy(coord0,coord1);
         if (time_in>=time_out) {break;}
      }
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   // Pour le FS2 il faut mettre le moteur en marche si le suivi est arrete
   if (strcmp(tel->name,"FS2")==0 && tel->suiviOnFS2 == 0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Q#");
   }
   /* LX200 protocol has 4 motion rates */
   if ((tel->radec_move_rate<=0.25)) {
      /* Guide */
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:RG#");
   } else if ((tel->radec_move_rate>0.25)&&(tel->radec_move_rate<=0.5)) {
      /* Center */
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:RC#");
   } else if ((tel->radec_move_rate>0.5)&&(tel->radec_move_rate<=0.75)) {
      /* Find */
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:RM#");
   } else if ((tel->radec_move_rate>0.75)) {
      /* Slew */
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:RS#");
   }
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
   if (strcmp(direc,"N")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Mn#");
   } else if (strcmp(direc,"S")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Ms#");
   } else if (strcmp(direc,"E")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Me#");
   } else if (strcmp(direc,"W")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Mw#");
   }
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];

   //sprintf(s,"after 50"); mytel_tcleval(tel,s);
   // remarque : je mets des accolades autour de %s pour eviter de provoquer une erreur TCL
   //            si la variable "direction" est vide
   sprintf(s,"lindex [string toupper {%s} ] 0",direction); ;
   if ( mytel_tcleval(tel,s) == TCL_ERROR ) {
      printf("mytel_radec_stop: %s\n",Tcl_GetStringResult(tel->interp));
      return 1;
   } else if ( strlen(Tcl_GetStringResult(tel->interp)) >= sizeof(direc) ) {
      // je verifie que le resultat n'est pas plus long que la variable "direct" 
      // pour eviter un debordement de variable quand on va copier le resultat dans "direct"
      printf("mytel_radec_stop: direction too long: %s\n",Tcl_GetStringResult(tel->interp));
      return 1;
   }
   strcpy(direc,Tcl_GetStringResult(tel->interp));
   if (strcmp(direc,"N")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qn#");
   } else if (strcmp(direc,"S")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qs#");
   } else if (strcmp(direc,"E")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qe#");
   } else if (strcmp(direc,"W")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qw#");
   } else {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Q#");
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qn#");
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qs#");
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qe#");
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Qw#");
   }
   // Pour le FS2 il faut arreter le moteur si le suivi etait arrete
   if (strcmp(tel->name,"FS2")==0 && tel->suiviOnFS2 == 0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:RC#");
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:Me#");
   }
   //sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];

   sprintf(s,"after 20"); mytel_tcleval(tel,s);
   if (tel->radec_motor==1) {
      /* stop the motor */
      if (strcmp(tel->name,"FS2")==0) {
         //The speed rate 2 must be set to exactly 1.00x.
         //For stopping the motor, you must first send the :RC# command. This command selects speed rate 2.
         //Then you must send the :Me# command, and the motor will immediately stop.
         mytel_sendLX(tel, RETURN_NONE, NULL, "#:RC#");
         mytel_sendLX(tel, RETURN_NONE, NULL, "#:Me#");
         tel->suiviOnFS2 = 0;
      } else if (strcmp(tel->autostar_char,"")==0) {
         //mytel_sendLX(tel, RETURN_NONE, NULL, "#:hW#");
      } else {
         mytel_sendLX(tel, RETURN_NONE, NULL, "#:AL#");
      }
   } else {
      /* start the motor */
      if (strcmp(tel->name,"FS2")==0) {
         //If you send a :Q# command, the motor will continue to run.
         //I restore the initial speed to send it to the FS2 Hand Controller.
         mytel_sendLX(tel, RETURN_NONE, NULL, "#:Q#");
         tel->suiviOnFS2 = 1;
         if ((tel->radec_move_rate<=0.25)) {
            /* Guide */
            mytel_sendLX(tel, RETURN_NONE, NULL, "#:RG#");
         } else if ((tel->radec_move_rate>0.25)&&(tel->radec_move_rate<=0.5)) {
            /* Center */
            mytel_sendLX(tel, RETURN_NONE, NULL, "#:RC#");
         } else if ((tel->radec_move_rate>0.5)&&(tel->radec_move_rate<=0.75)) {
            /* Find */
            mytel_sendLX(tel, RETURN_NONE, NULL, "#:RM#");
         } else if ((tel->radec_move_rate>0.75)) {
            /* Slew */
            mytel_sendLX(tel, RETURN_NONE, NULL, "#:RS#");
         }
      } else if (strcmp(tel->autostar_char,"")==0) {
         //mytel_sendLX(tel, RETURN_NONE, NULL, "#:hN#");
      } else {
         mytel_sendLX(tel, RETURN_NONE, NULL, "#:AP#");
      }
   }
   //sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   char s[1024],ss[1024],signe[2];
   int h,d,m,sec;
   int len, k;
   strcpy(result,"");

   /* Send GR */
   mytel_sendLX(tel, RETURN_STRING, ss, "#:GR#");

   //mytel_get_format(tel);
   len=(int)strlen(ss);
   k=0;
   /* 12:34:45# ou 12:34.7# */
   if (len>=7) {
      if (ss[5]=='.') {
         tel->longformatindex=1;
         k=1;
      } else if (ss[5]==':') {
         tel->longformatindex=0;
         k=1;
         sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
      }
   }

   sprintf(s,"string range \"%s\" 0 1",ss); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   h=atoi(s);
   sprintf(s,"string range \"%s\" 3 4",ss); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   m=atoi(s);
   if (tel->longformatindex==0) {
      sprintf(s,"string range \"%s\" 6 7",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      sec=atoi(s);
      sprintf(s,"%02dh%02dm%02ds",h,m,sec);
   } else {
      sprintf(s,"string range \"%s\" 6 6",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      sec=atoi(s);
      /*sprintf(s,"%02ldh%02ld.%01ldm",h,m,sec);*/
      sprintf(s,"%02dh%02dm%02ds",h,m,sec*6);
   }
   sprintf(result,"%s ",s);
   
   /* Send GD */
   mytel_sendLX(tel, RETURN_STRING, ss, "#:GD#");
   sprintf(s,"string range \"%s\" 0 0",ss); mytel_tcleval(tel,s);
   strcpy(signe,Tcl_GetStringResult(tel->interp));
   if ((strcmp(signe,"-")!=0)&&(strcmp(signe,"+")!=0)) {
      strcpy(signe,"+");
   }
   sprintf(s,"string range \"%s\" 1 2",ss); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   d=atoi(s);
   sprintf(s,"string range \"%s\" 4 5",ss); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   m=atoi(s);
   if (tel->longformatindex==0) {
      sprintf(s,"string range \"%s\" 7 8",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      sec=atoi(s);
      sprintf(s,"%s%02dd%02dm%02ds",signe,d,m,sec);
   } else {
      /*sprintf(s,"%s%02ldh%02ldm",signe,d,m);*/
      sprintf(s,"%s%02dd%02dm%02ds",signe,d,m,sec=0);
   }
   strcat(result,s);
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
   char s[1024],direc[10];
   /* LX200 protocol has 2 motion rates */
   if (tel->focus_move_rate<=0.5) {
      /* Slow */
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:FS#");
   } else if (tel->focus_move_rate>0.5) {
      /* Fast */
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:FF#");
   }
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
   if (strcmp(direc,"+")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:F+#");
   } else if (strcmp(direc,"-")==0) {
      mytel_sendLX(tel, RETURN_NONE, NULL, "#:F-#");
   }
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   mytel_sendLX(tel, RETURN_NONE, NULL, "#:FQ#");
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
   int result;
   char s[1024],ss[1024];
   int y,m,d,h,min;
   int sec;
   /* Get the time */
   mytel_sendLX(tel, RETURN_STRING, ss, "#:GL#");
   sprintf(s,"string range \"%s\" 0 1",ss); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   h=atoi(s);
   sprintf(s,"string range \"%s\" 3 4",ss); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   min=atoi(s);
   sprintf(s,"string range \"%s\" 6 7",ss); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
   sec=atoi(s);

   /* Get the date */
   if ( mytel_sendLX(tel, RETURN_STRING, ss, "#:GC#") == 1 ) {
      sprintf(s,"string range \"%s\" 0 1",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      m=atoi(s);
      sprintf(s,"string range \"%s\" 3 4",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      d=atoi(s);
      sprintf(s,"string range \"%s\" 6 7",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      y=atoi(s);
      if (y>91) {
         y=y+1900;
      } else {
         y=y+2000;
      }
   } else {
     result = 1;

   }
   
   /* Returns the result */
   sprintf(ligne,"%d %d %d %d %d %d.0",y,m,d,h,min,sec); 
   return 0;
}

/**
 * mytel_date_set : send a command to the telescop
 * @param tel  
 * @param returntype : type of string returned by LX
 *    0 (return nothing)
 *    1 (return one char)
 *    2 (return string terminated by #)
 * @param response  pointeur sur une chaine de caractere dans laquelle sera copiée la reponse 
 * @param commandFormat  commande LX200
 *   exemple "xxxxx#" 
 *
 * @return 0= OK ,  1=error with error message in tel->msg 
 */

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   char ligne[1024];
   int sec;

   // Set the time 
   mytel_flush(tel);
   sec=(int)(s);   
   mytel_sendLX(tel, RETURN_CHAR, ligne, "#:SL%02d:%02d:%02d#", h,min,sec);
   // Set the number of hours added to local time to yield UTC
   // We chose local time = UTC
   if (tel->is_autostar==0) {
		mytel_sendLX(tel, RETURN_CHAR, ligne, "#:SG+00.0#");
	} else {
		mytel_sendLX(tel, RETURN_CHAR, ligne, "#:SG+00#");
	}
   // Set the date 
   if (y<1992) {y=1992;}
   if (y>2091) {y=2091;}
   if (y<2000) {
      y=y-1900;
   } else {
      y=y-2000;
   }
   mytel_sendLX(tel, RETURN_CHAR, ligne, "#:SC%02d/%02d/%02d#", m,d,y);
   // si ligne=1 il faut lire la chaine supplémentaire "Updating Planetary Data#"  
   // je lis la suite en faisant un flush
   mytel_flush(tel); 
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   char s[1024],ss[1024],signe[3],ew[3];
   int d1,m1,d2,m2;
   double longitude,latitude;
   /* Get the longitude */

   if ( strcmp(tel->name,"FS2") != 0 ) {
      mytel_sendLX(tel, RETURN_STRING, ss, "#:Gg#");
      sprintf(s,"string range \"%s\" 0 2",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      d1=atoi(s);
      sprintf(s,"string range \"%s\" 4 5",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      m1=atoi(s);
      longitude=(double)d1+(double)m1/60.;
      if (longitude>180) {
         longitude=360.-longitude;
         strcpy(ew,"e");
      } else {
         strcpy(ew,"w");
      }
      /* Get the latitude */
      mytel_sendLX(tel, RETURN_STRING, ss, "#:Gt#");   
      sprintf(s,"string range \"%s\" 1 2",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      d2=atoi(s);
      sprintf(s,"string range \"%s\" 4 5",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      m2=atoi(s);
      sprintf(s,"string range \"%s\" 0 0",ss); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      if (strcmp(s,"-")==0) {
         strcpy(signe,"-");
      } else {
         strcpy(signe,"+");
      }
      latitude=fabs((double)d2)+(double)m2/60.;
      /* Returns the result */
      sprintf(ligne,"GPS %f %s %s%f 0",longitude,ew,signe,latitude);
   } else {
      // le modele FS2 ne possede pas de commande pour recupere la longitude et la latitude.
      // A la place, je retourne la valeur qui est dans la variable tel->homePosition
      sprintf(ligne, tel->homePosition);
   }
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   char ligne[1024],ligne2[1024];
   // Set the longitude
   //   cas particulier du modele FS2 : je n'envoie pas cette commmande si c'est un FS2 car elle n'est pas reconnue par FS2
   if ( strcmp(tel->name,"FS2") != 0 ) {
      mytel_flush(tel);
      if ((strcmp(ew,"E")==0)||(strcmp(ew,"e")==0)) {
         longitude=360.-longitude;
      }
      sprintf(ligne,"mc_angle2dms %f 360 zero 0 + list",longitude); mytel_tcleval(tel,ligne);
      strcpy(ligne2,Tcl_GetStringResult(tel->interp));
      sprintf(ligne,"string range \"[string range [lindex {%s} 0] 1 3]\xDF[string range [lindex {%s} 1] 0 1]\" 0 6",ligne2,ligne2); mytel_tcleval(tel,ligne);
      strcpy(ligne2,Tcl_GetStringResult(tel->interp));
      mytel_sendLX(tel, RETURN_CHAR, ligne, "#:Sg%s#", ligne2);

      /* Set the latitude */
      sprintf(ligne,"mc_angle2dms %f 90 zero 0 + list",latitude); mytel_tcleval(tel,ligne);
      strcpy(ligne2,Tcl_GetStringResult(tel->interp));
	   if (tel->is_autostar==0) {
	      sprintf(ligne,"string range \"[string range [lindex {%s} 0] 0 0][string range [lindex {%s} 0] 1 2]\xDF[string range [lindex {%s} 1] 0 1]\" 0 6",ligne2,ligne2,ligne2); mytel_tcleval(tel,ligne);
		} else {
			sprintf(ligne,"string range \"[string range [lindex {%s} 0] 0 0][string range [lindex {%s} 0] 1 2]\xDF[string range [lindex {%s} 1] 0 1]:[string range [lindex {%s} 2] 0 1]\" 0 9",ligne2,ligne2,ligne2,ligne2); mytel_tcleval(tel,ligne);
		}
      strcpy(ligne2,Tcl_GetStringResult(tel->interp));
      mytel_sendLX(tel, RETURN_CHAR, ligne, "#:St%s#", ligne2);
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

int mytel_get_format(struct telprop *tel)
{
   char s[1024];
   int len,k;

   mytel_sendLX(tel, RETURN_STRING, s, "#:GR#");
   len=(int)strlen(s);
   k=0;
   /* 12:34:45# ou 12:34.7# */
   if (len>=7) {
      if (s[5]=='.') {
         tel->longformatindex=1;
         k=1;
      } else if (s[5]==':') {
         tel->longformatindex=0;
         k=1;
         sprintf(s,"read %s 1",tel->channel); mytel_tcleval(tel,s);
      }
   }
   return k;
}

int mytel_set_format(struct telprop *tel,int longformatindex)
{
   int k=0;
   if (mytel_get_format(tel)==1) {
      if (longformatindex!=tel->longformatindex) {
         mytel_sendLX(tel, RETURN_NONE, NULL, "#:U#");
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
      //sprintf(s,"read -nonewline %s 1",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"read -nonewline %s",tel->channel); mytel_tcleval(tel,s);
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
   f=fopen("mouchard_lx200.txt","at");
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
   mytel_sendLX(tel, RETURN_NONE, NULL, "#:Mg%s%04d#", direction, duration);
   return 0;
}


int mytel_sendLX(struct telprop *tel, int returnType, char *response, char *commandFormat, ...) {
   va_list mkr;
   char command[1024];

   // j'assemble la commande 
   va_start(mkr, commandFormat);
   vsprintf(command, commandFormat, mkr);
   va_end (mkr);

   return mytel_sendLXTempo( tel, returnType, response, 100, command);
}


/**
 * sendLX : send a command to the telescop
 * @param tel  
 * @param returntype : type of string returned by LX
 *    0 (return nothing)
 *    1 (return one char)
 *    2 (return string terminated by #)
 * @param response  pointeur sur une chaine de caractere dans laquelle sera copiée la reponse 
 * @param commandFormat  commande LX200
 *   exemple "xxxxx#" 
 *
 * return :
 *    1= OK
 *       if returnType = 0  response = ""
 *       if returnType = 1  response = "0" or "1"
 *       if returnType = 2  response = "...#"
 *    0= error , with error message in tel->msg 
 *  return cr
 */
int mytel_sendLXTempo(struct telprop *tel, int returnType, char *response, int nbLoopMax, char *commandFormat, ...) {
   char command[1024];
   char s[1024];
   int cr = 0;
   va_list mkr;

   // j'assemble la commande 
   va_start(mkr, commandFormat);
   vsprintf(command, commandFormat, mkr);
   va_end (mkr);

   mytel_flush(tel);
   // j'envoie la commande
   sprintf(s,"puts -nonewline %s \"%s\"",tel->channel,command); mytel_tcleval(tel,s);
   // je temporise avant de lire la reponse
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);

   // je purge la variable de la reponse
   if ( response != NULL) {
      strcpy(response,"");
      strcpy(tel->msg, "");
   }
   // je lis la reponse
   if ( returnType == RETURN_NONE ) {
      // je n'attends pas de réponse
      cr = 1;
   } else if ( returnType == RETURN_CHAR ) {
      // j'attend la reponse d'un caractere ("1" ou "0" ou "P" ou ...)
      int k = 0;
      cr = 0;
      // j'attend un caractere
      do {
         sprintf(s,"read %s 1",tel->channel); 
         if ( mytel_tcleval(tel,s) == TCL_OK ) {
            if ( strlen(Tcl_GetStringResult(tel->interp)) > 0 ) {
               strcpy(response,Tcl_GetStringResult(tel->interp));
               cr = 1;
            } else {
               // si pas de caractere recu , j'attends 1 milliseconde
               libtel_sleep(1) ;
            }
         } else {
            // je copie le message d'erreur 
            strcpy(tel->msg, Tcl_GetStringResult(tel->interp));
         }
      } while ( k++ < nbLoopMax && cr==0 && tel->waitResponse==1);
      if ( k >= nbLoopMax ) {
         sprintf(tel->msg, "No response for %s",command);
         if ( tel->waitResponse == 1 ) {
            mytel_logConsole(tel, "No char reponse for %s after %d ms",command,nbLoopMax);
         }
      }
   }  else if ( returnType == RETURN_STRING ) {
      // j'attend une chaine qui se termine par diese
      int k = 0;
      cr = 0;
      do {
         sprintf(s,"read %s 1",tel->channel); 
         if ( mytel_tcleval(tel,s) == TCL_OK ) {
            if (strcmp(Tcl_GetStringResult(tel->interp),"") == 0 ) {
               // si pas de caractere recu , j'attends 1 milliseconde
               // (insdispensable pour les ordinateurs rapides)
               libtel_sleep(1) ;
            } else if ( strcmp(Tcl_GetStringResult(tel->interp),"#") == 0 ) {
               // c'est un diese
               cr =1;
            } else {
               // si ce n'est pas un diese j'ajoute le caractere lu dans le resultat
               strcat(response,Tcl_GetStringResult(tel->interp));
               // je remet la temporisation a zero
               k = 0;
            }
         } else {
            // erreur, je copie le message d'erreur dans la variable tel->msg
            strcpy(tel->msg, Tcl_GetStringResult(tel->interp));
         }
      } while ( k++ < nbLoopMax && cr==0 && tel->waitResponse==1);
      if ( k >= nbLoopMax ) {
         sprintf(tel->msg, "No string response for %s after %d ms",command, nbLoopMax);
         if ( tel->waitResponse == 1 ) {
            mytel_logConsole(tel, "No # reponse for %s after %d ms",command,nbLoopMax);
         }
      }
   }

   if ( tel->consoleLog == 1 ) {
      mytel_logConsole(tel, "command=%s response=%s\n",command, response);
   }

   return cr;
}

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
      sprintf(ligne,"after 0 { ::console::disp \"liblx200: %s\n\"}",message); 
   } else {
      sprintf(ligne,"::thread::send -async %s { ::console::disp \"liblx200: %s \n\" } " , tel->mainThreadId, message); 
   }
   result = Tcl_Eval(tel->interp,ligne);   
}

