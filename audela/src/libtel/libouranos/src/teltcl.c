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

int cmdTelAdjust(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* envoie la commande a l'interface ouranos pour ajuster lenombre de pas par tour       */
/***************************************************************************************/
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;

   // 
   tel->res_ra =65535;
   tel->res_dec=65535;
   ouranos_initcoder(tel, 0,0);

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

int cmdTelResolution(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Choix de la resolution sur les deux encordeurs                                      */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc<2)&&(argc>4)) {
      pb=1;
   } else if(argc==3) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      tel->res_ra=(int)fabs((double)atoi(argv[2]));
      tel->res_dec=(int)fabs((double)atoi(argv[3]));
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?resol_ra? ? resol_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d %d",tel->res_ra,tel->res_dec);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelInvert(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Choix de la resolution sur les deux encordeurs                                      */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK,pb=0;
   double res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc<2)&&(argc>4)) {
      pb=1;
   } else if(argc==3) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      res=atoi(argv[2]);
      if (res>=0) {
         tel->inv_ra=1;
      } else {
         tel->inv_ra=-1;
      }
      res=atoi(argv[3]);
      if (res>=0) {
         tel->inv_dec=1;
      } else {
         tel->inv_dec=-1;
      }
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?1|-1? ?1|-1?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d %d",tel->inv_ra,tel->inv_dec);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelNbticks(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Retourne les nb ticks sur les deux axes                                                  */
/***************************************************************************************/
   struct telprop *tel;
   char ligne[256];
   int hai=0,deci=0;
   tel = (struct telprop *)clientData;
   ouranos_readcoder(tel,&hai,&deci);
   sprintf(ligne,"%d %d",hai,deci);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}
