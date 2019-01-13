/* teltcl.c
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
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "telescop.h"
#include <libtel/libtel.h>
#include "teltcl.h"
#include <libtel/util.h>

/*
 *   structure pour les fonctions étendues
 */

char *tel_slewpath[] = {
   "short",
   "long",
   NULL
};

int cmdTelSlewpath(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Choix du chemin long ou court                                                       */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK,pb=0,comok=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      comok=1;
      pb=0;
   } else {
      if (strcmp(argv[2],tel_slewpath[0])==0) {
         tel->slewpathindex=0;
         pb=0;
      } else if (strcmp(argv[2],tel_slewpath[1])==0) {
         tel->slewpathindex=1;
         pb=0;
      } else {
         pb=1;
      }
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s %s|%s",argv[0],argv[1],tel_slewpath[0],tel_slewpath[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne,"");
      if (tel->slewpathindex==0) {
         sprintf(ligne,"%s",tel_slewpath[0]);
      } else if (tel->slewpathindex==1) {
         sprintf(ligne,"%s",tel_slewpath[1]);
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelTempo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Choix de la tempo (en ms) entre deux ordres                                         */
/***************************************************************************************/
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
      tel->tempo=(int)fabs((double)atoi(argv[2]));
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?ms?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d",tel->tempo);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelFirmware(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Retourne le Firmware                                                                */
/***************************************************************************************/
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   Tcl_SetResult(interp,tel->v_firmware,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelSolarTracking(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Suivi solaire                                                                       */
/***************************************************************************************/
   int result;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   result = temma_solar_tracking(tel);
   if ( result == 0 ) {
      Tcl_SetResult(interp,"",TCL_VOLATILE);
      return TCL_OK;
   } else {
      return TCL_ERROR;
   }
}

int cmdTelInitZenith(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* init le tube au zenith                                                              */
/***************************************************************************************/
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   temma_initzenith(tel);
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelDriftspeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Fixe les vitesses de derive sur RA et DEC                                           */
/*
* Set Comet Tracking
LM+/-99999,+/-9999
RA : Adjust Sidereal time by seconds per Day
DEC : Adjust DEC tracking by Minutes Per Day
Example:
LM+120,+30 would slow the RA speed by 86164/86284 and
the Dec would track at 30 Minutes a day.
To stop tracking either send a LM0,0 (or a PS ?)

* Get Comet Speed
lm Note: This is a lower case "L"
Reply Structure:
lmLM+/-99999,+/-9999
RA Speed Adjustment,Dec Speed Adjustment

Note: RA Speed adjustment is how many RA seconds are added/subtracted per 24 hour period,
DEC adjustment is how many Minutes per 24 hour period.

*/
/***************************************************************************************/
   int ra_speed,dec_speed;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc!=4)) {
      sprintf(ligne,"Usage: %s %s ?ra_drift dec_drift?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (argc==4) {
      ra_speed=(int)atoi(argv[2]);
      dec_speed=(int)atoi(argv[3]);
      temma_set_comet_rate(tel,ra_speed,dec_speed);
   }
   temma_get_comet_rate(tel,&ra_speed,&dec_speed);
   sprintf(ligne,"%d %d",ra_speed,dec_speed);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdTelMechanicalplay(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Valeurs des jeux mecaniques sur les axes (en degres)                                */
/***************************************************************************************/
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if((argc!=4)&&(argc!=2)) {
      sprintf(ligne,"Usage: %s %s ra_play_deg dec_play_deg",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if (argc==4) {
         tel->ra_play=(double)atof(argv[2]);
         tel->dec_play=(double)atof(argv[3]);
      }
      sprintf(ligne,"%9f %9f",tel->ra_play,tel->dec_play);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelGetlatitude(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Valeurs de la latitude actuelle dans Temma (en degres)                              */
/***************************************************************************************/
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   double latitude=0.;
   tel = (struct telprop *)clientData;
   if((argc<=1)) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      temma_getlatitude(tel,&latitude);
      sprintf(ligne,"%9f",latitude);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelGetTsl(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Valeurs du TSL actuel dans Temma (en degres)                                        */
/***************************************************************************************/
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   double tsl=0.;
   tel = (struct telprop *)clientData;
   if((argc<=1)) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      temma_gettsl(tel,&tsl);
      sprintf(ligne,"%9f",tsl);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelMotorState(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Retourne l'etat des moteurs                                                         */
/***************************************************************************************/
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if((argc<=1)) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      int state;
      state = temma_motorstate(tel);
      sprintf(ligne,"%d",state);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}
int cmdTelGerman(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Valeurs du E/W actuel dans Temma (german mounts)                                    */
/***************************************************************************************/
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
      temma_switchMountSide(tel,argv[2]);
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?W|E?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      temma_coord(tel,ligne);
      sprintf(ligne,"%s",tel->ew);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}


int cmdTelEncoder(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Encoder =0 if no encoder installed, =1 if enconders are installed                   */
/***************************************************************************************/
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
      tel->encoder=(int)fabs(atof(argv[2]));
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?1|0?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d",tel->encoder);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelCorrectionSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Last Correction Speed values (taken into account if tel1 radec move N -rate 0       */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK,pb=0;
   int vra=0,vdec=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=4)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      vra=(int)fabs(atof(argv[2]));
      vdec=(int)fabs(atof(argv[3]));
      temma_LA(tel,vra);
      temma_LB(tel,vdec);
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?corRA corDEC?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      temma_lg(tel,&vra,&vdec);
      sprintf(ligne,"%d %d",vra,vdec);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return result;
   }
   return result;
}
