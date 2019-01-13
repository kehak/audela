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

char *tel_langage[] = {
   "audecom",
   "lx200",
   NULL
};

char *tel_boost[] = {
   "off",
   "on",
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

int cmdTelLangage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Choix du langage protcole (audecom|lx200)                                           */
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
      if (strcmp(argv[2],tel_langage[0])==0) {
         tel->langageindex=0;
         kauf_set_natif(tel); 
         pb=0;
      } else if (strcmp(argv[2],tel_langage[1])==0) {
         tel->langageindex=1;
         kauf_lx200(tel); 
         pb=0;
      } else {
         pb=1;
      }
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s %s|%s",argv[0],argv[1],tel_langage[0],tel_langage[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne,"");
      if (tel->langageindex==0) {
         sprintf(ligne,"%s",tel_langage[0]);
      } else if (tel->langageindex==1) {
         sprintf(ligne,"%s",tel_langage[1]);
      }
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

int cmdTelSlewspeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Fixe les vitesses de pointage sur RA et DEC (entre 4 et 16)                         */
/***************************************************************************************/
   int ra_speed,dec_speed;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc!=4) {
      sprintf(ligne,"Usage: %s %s ra_speed dec_speed",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      ra_speed=(int)atoi(argv[2]);
      dec_speed=(int)atoi(argv[3]);
      kauf_vit_maxi_ar(tel,ra_speed);
      kauf_vit_maxi_dec(tel,dec_speed);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return result;
}

/*
int kauf_nb_tics_ad(struct telprop *tel,int *ticks);
int kauf_nb_tics_dec(struct telprop *tel,int *ticks);
int kauf_active_boost(struct telprop *tel);
int kauf_inhibe_boost(struct telprop *tel);
int kauf_derive_ar(struct telprop *tel,int var);
int kauf_derive_dec(struct telprop *tel,int vdec);
int kauf_largeur_impulsion(struct telprop *tel,int limp);
*/

int cmdTelNbticks(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Retourne les nb ticks sur les deux axes                                                  */
/***************************************************************************************/
   struct telprop *tel;
   char ligne[256];
   int ta=0,td=0;
   tel = (struct telprop *)clientData;
   kauf_nb_tics_ad(tel,&ta);
   kauf_nb_tics_dec(tel,&td);
   sprintf(ligne,"%d %d",ta,td);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelBoost(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Boost du Temic                                                       */
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
      if (strcmp(argv[2],tel_boost[0])==0) {
         tel->boostindex=0;
         pb=0;
      } else if (strcmp(argv[2],tel_boost[1])==0) {
         tel->boostindex=1;
         pb=0;
      } else {
         pb=1;
      }
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s %s|%s",argv[0],argv[1],tel_boost[0],tel_boost[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne,"");
      if (tel->boostindex==0) {
         sprintf(ligne,"%s",tel_boost[0]);
      } else if (tel->boostindex==1) {
         sprintf(ligne,"%s",tel_boost[1]);
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelDriftspeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Fixe les vitesses de derive sur RA et DEC (unites ?)                         */
/***************************************************************************************/
   int ra_speed,dec_speed;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc!=4) {
      sprintf(ligne,"Usage: %s %s ra_drift dec_drift",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      ra_speed=(int)atoi(argv[2]);
      dec_speed=(int)atoi(argv[3]);
      kauf_derive_ar(tel,ra_speed);
      kauf_derive_dec(tel,dec_speed);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return result;
}

int cmdTelPulse(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/*--- Reglage de la largeur de l'impulsion de commande des moteurs pas a pas en petite vitesse seulement*/
/***************************************************************************************/
   int limp;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc!=3) {
      sprintf(ligne,"Usage: %s %s width",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      limp=(int)atoi(argv[2]);
      kauf_largeur_impulsion(tel,limp);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return result;
}

/*
int kauf_king(struct telprop *tel,int vking);
int kauf_inhibe_pec(struct telprop *tel);
int kauf_periode_pec(struct telprop *tel,int ppec);
int kauf_pointe_case_pec(struct telprop *tel,int pcpec);
int kauf_ecrit_vit_pec(struct telprop *tel,int evpec);

int kauf_pointeur_pec(struct telprop *tel,int *indexpec);
int kauf_lit_vit_pec(struct telprop *tel,int *vitpec);
*/

int cmdTelKing(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Fixe les vitesses de derive de King (unites ?)                         */
/***************************************************************************************/
   int vking;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc!=3) {
      sprintf(ligne,"Usage: %s %s king_drift",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      vking=(int)atoi(argv[2]);
      kauf_king(tel,vking);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return result;
}

int cmdTelPECPeriod(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/**************************************************************************/
/* ratio est le rapport de reduction entre moteur RA et la roue tangente. */
/* =1 a 360 : mise en route du PEC en definissant le ratio du PEC.        */
/* =0 : inhibe le PEC                                                     */
/**************************************************************************/
   int ppec;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc!=3) {
      sprintf(ligne,"Usage: %s %s ratio",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      ppec=(int)atoi(argv[2]);
      if (ppec<0) { ppec=0;}
      if (ppec>360) { ppec=360;}
      if (ppec==0) {
         kauf_inhibe_pec(tel);
      } else {
         kauf_periode_pec(tel,ppec);
      }
      sprintf(ligne,"%d",ppec);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;

}

int cmdTelPECIndex(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/******************************************************/
/* index est l'indice du tableau ou il faut se placer */
/* =0 a 19 : indice de l'index.                       */
/* rien : retourne l'index courant.                   */
/******************************************************/
   int pcpec;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc>3) {
      sprintf(ligne,"Usage: %s %s ?index?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if (argc>=3) {
         pcpec=(int)atoi(argv[2]);
         if (pcpec<0) { pcpec=0;}
         if (pcpec>19) { pcpec=19;}
         kauf_pointe_case_pec(tel,pcpec);
      } else {
         kauf_pointeur_pec(tel,&pcpec);
      }
      sprintf(ligne,"%d",pcpec);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelPECSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/******************************************************/
/* speed est l'indice du tableau ou il faut se placer */
/* =integer<=999 : vitesse.                       */
/* rien : retourne l'index courant.                   */
/******************************************************/
   int evpec;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc>3) {
      sprintf(ligne,"Usage: %s %s ?speed?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if (argc>=3) {
         evpec=(int)atoi(argv[2]);
         if (evpec<0) { evpec=0;}
         if (evpec>999) { evpec=999;}
         kauf_ecrit_vit_pec(tel,evpec);
      } else {
         kauf_lit_vit_pec(tel,&evpec);
      }
      sprintf(ligne,"%d",evpec);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelFocspeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/*--- Reglage de la vitesse de foc en mode rapide */
/***************************************************************************************/
   int vfoc;
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if(argc!=3) {
      sprintf(ligne,"Usage: %s %s speed",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      vfoc=(int)atoi(argv[2]);
      if (vfoc<5) { vfoc=5; }
      if (vfoc>255) { vfoc=255; }
      kauf_foc_vit(tel,vfoc);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return result;
}

int cmdTelInitcoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* --- Reset telescope sur gamma Cas ou epsilon UMa */
/***************************************************************************************/
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   kauf_reset_tel(tel);
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelReset(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* --- Reset general de la carte Audecom */
/***************************************************************************************/
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   kauf_reset_carte(tel);
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int cmdTelBacklash(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Valeurs des jeux mecaniques sur les axes (en degres) */
/***************************************************************************************/
   struct telprop *tel;
   char ligne[256];
   int result = TCL_OK;
   tel = (struct telprop *)clientData;
   if((argc!=4)&&(argc!=2)) {
      sprintf(ligne,"Usage: %s %s ra_backlash_deg dec_backlash_deg",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if (argc==4) {
         tel->ra_backlash=(double)atof(argv[2]);
         tel->dec_backlash=(double)atof(argv[3]);
      }
      sprintf(ligne,"%9f %9f",tel->ra_backlash,tel->dec_backlash);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}
