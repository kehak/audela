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
 *   structure pour les fonctions ?tendues
 */


/*
 *   Envoie une commande
 */
int cmdTelPut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s command",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=eqmod_put(tel,argv[2]);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Lit une reponse
 */
int cmdTelRead(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   res=eqmod_read(tel,ligne);
   if (res==1) {
      result = TCL_ERROR;
   } else {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/*
 *   Envoie une commande et retourne la reponse
 */
int cmdTelPutread(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s command",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=eqmod_putread(tel,argv[2],ligne);
      if (res==1) {
         Tcl_SetResult(interp,"connection problem",TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Decode l'hexa
 */
int cmdTelDecode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res,num;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s hexa ?-|+?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=eqmod_decode(tel,argv[2],&num);
		if (argc>=4) {
			if (strcmp(argv[3],"+")==0) {
				// --- force un resultat positif
			   if (num<0) { num= num + (1<<24); }
			}
		}
		sprintf(ligne,"%d",num);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Encode l'hexa
 */
int cmdTelEncode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res,num;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s integer",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		num=atoi(argv[2]);
      res=eqmod_encode(tel,num,ligne);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Valeurs des vitesses de pointage (deg/s)
 */
int cmdTelSpeedslew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?speed_slew_ra speed_slew_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      value=atof(argv[2]);
      if (value<-3.) { value=-3.; }
      if (value>3.)  { value=3.; }
      tel->speed_slew_ra=value;
      value=atof(argv[3]);
      if (value<-3.) { value=-3.; }
      if (value>3.)  { value=3.; }
      tel->speed_slew_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_slew_ra,tel->speed_slew_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Valeurs des vitesses de suivi (deg/s)
 */
int cmdTelSpeedtrack(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?speed_track_ra|diurnal speed_track_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      if (strcmp(argv[2],"diurnal")==0) {
         value=tel->track_diurnal;
      } else {
         value=atof(argv[2]);
      }
      if (value<-5.) { value=-5.; }
      if (value>5.)  { value=5.; }
      tel->speed_track_ra=value;
      value=atof(argv[3]);
      if (value<-5.) { value=-5.; }
      if (value>5.)  { value=5.; }
      tel->speed_track_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_track_ra,tel->speed_track_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Retourne le temps sideral actuel
 */
int cmdTelLst(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   struct telprop *tel;
   double lst,sec;
   int h,m;
   Tcl_DString dsptr;

   tel = (struct telprop *)clientData;
   if (argc<2) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   Tcl_DStringInit(&dsptr);
   /* --- Lecture AXE 1 (horaire) --- */
   lst=eqmod_tsl(tel,&h,&m,&sec);
   sprintf(ligne,"%.5f",lst);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- --- */
   Tcl_DStringResult(tel->interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   return result;
}

/*
 *   Pointage en coordonnees horaires
 */
int cmdTelHaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],texte[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   int h,m;
   double sec;
   double lst;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         // --- init --- //
         if (argc>=4) {
            // - call the pointing model if exists - //
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
            if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
            }
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,Tcl_GetStringResult(interp));
            // - end of pointing model - //
            libtel_Getradec(interp,argv[3],&tel->ra0,&tel->dec0);
				eqmod_hadec_match(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init {angle_ha angle_dec}",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         // --- coord --- //
         eqmod_hadec_coord(tel,texte);
         // - call the pointing model if exists - //
         sprintf(ligne,"set libtel(radec) {%s}",texte);
         Tcl_Eval(interp,ligne);
         sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_tel2cat,texte);
         Tcl_Eval(interp,ligne);
         Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
         strcpy(ligne,Tcl_GetStringResult(interp));
         // - end of pointing model- //
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"state")==0) {
         // --- state --- //
         tel_radec_state(tel,texte);
         Tcl_SetResult(interp,texte,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         // --- goto --- //
         if (argc>=4) {
            strcpy(ligne,argv[3]);
            // - end of pointing model - //
            libtel_Getradec(interp,ligne,&tel->ha0,&tel->dec0);
            if (argc>=5) {
               for (k=4;k<=argc-1;k++) {
                  if (strcmp(argv[k],"-rate")==0) {
                     tel->radec_goto_rate=atof(argv[k+1]);
                  }
                  if (strcmp(argv[k],"-blocking")==0) {
                     tel->radec_goto_blocking=atoi(argv[k+1]);
                  }
               }
            }
            // Conversion de l'AH (dans tel->ra0) en vrai RA
				// le goto fera l'operation inverse: ca permet d'utiliser la meme fonction
            lst=eqmod_tsl(tel,&h,&m,&sec);
            lst=lst+0./86400*360.; // ajout empirique de 4 secondes pour tenir compte du temps mort de reponse de la monture
            tel->ra0=lst-tel->ha0+360*5;
            tel->ra0=fmod(tel->ra0,360.);
            if (tel->ra0>180) tel->ra0 -= 360.;
            tel->ha_pointing = 1;
            eqmod2_action_goto(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s goto {angle_ha angle_dec} ?-rate value? ?-blocking boolean?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         // --- move --- //
         if (argc>=4) {
            if (argc>=5) {
               tel->radec_move_rate=atof(argv[4]);
            }
            tel_radec_move(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s move n|s|e|w ?rate?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         // --- stop --- //
			if (argc>=4) {
            tel_radec_stop(tel,argv[3]);
         } else {
            tel_radec_stop(tel,"");
         }
      } else if (strcmp(argv[2],"motor")==0) {
         // --- motor --- //
         if (argc>=4) {
            tel->radec_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->radec_motor=1;
            }
            tel_radec_motor(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else {
         // --- sub command not found --- //
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 *   Limites pour retournements (deg)
 Exemple :
#init avec tube ? l'ouest et pole nord => hadec = {18h 90d}
tel1 limits 23h20m 00h40 ; # default
tel1 hadec goto {02h30m 40d} -blocking 1 ; # tube ? l'est (? l'endroit)
#Si le tube est ? l'est et que le HA ? pointer (22h30) est < ? la limite East alors on retourne le tube ? l'ouest
tel1 hadec goto {22h30m 40d} -blocking 1 ; # tube ? l'ouest (? l'endroit)
#Si le tube est ? l'ouest et que le HA ? pointer (02h30m) est > ? la limite West alors on retourne le tube ? l'est
tel1 hadec goto {02h30m 40d} -blocking 1 ; # tube ? l'est (? l'endroit)
#
tel1 limits 18h 00h40 ; Eastern limit=18h Western limit=0h40m
tel1 hadec goto {02h30m 40d} -blocking 1 ; # tube ? l'est (? l'endroit)
tel1 hadec goto {22h30m 40d} -blocking 1 ; # tube ? l'est (? l'envers)
 */
int cmdTelLimits(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048],s[2048],le[30],lw[30];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?limit_ha_east limit_ha_west?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      sprintf(s,"mc_angle2deg %s",argv[2]); mytel_tcleval(tel,s);
      value=atof(Tcl_GetStringResult(tel->interp));
      if (value<90) {
         sprintf(ligne,"Error, Eastern limit asked = %f degrees (must be in the range 180-360)",value);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }
      value-=360;
      value*=fabs(tel->adu4deg_ha);
		tel->coord_adu_ha_emin = (int)value;
      sprintf(s,"mc_angle2deg %s",argv[3]); mytel_tcleval(tel,s);
      value=atof(Tcl_GetStringResult(tel->interp));
      if (value>270) {
         sprintf(ligne,"Error, Western limit asked = %f degrees (must be in the range 0-270)",value);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }
      value*=fabs(tel->adu4deg_ha);
		tel->coord_adu_ha_wmax = (int)value;
		// ---
		// mise à jour des domaines de pointages pour les deux positions de tube
		tel->coord_adu_ha_wmax = tel->coord_adu_ha0 + (tel->coord_deg_ha_wmax - tel->coord_deg_ha0) * tel->adu4deg_ha;
		tel->coord_adu_ha_emin = tel->coord_adu_ha0 + (tel->coord_deg_ha_emin - tel->coord_deg_ha0) * tel->adu4deg_ha;
   }
   sprintf(s,"mc_angle2hms %.8f 360 zero 2 auto string",tel->coord_adu_ha_emin/fabs(tel->adu4deg_ha)); mytel_tcleval(tel,s);
   strcpy(le,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2hms %.8f 360 zero 2 auto string",tel->coord_adu_ha_wmax/fabs(tel->adu4deg_ha)); mytel_tcleval(tel,s);
   strcpy(lw,Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"%s %s",le,lw);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}


/*
 *  Orientation initiale du tube
 */
int cmdTelOrientation(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[100];
	struct telprop *tel;
	char comment[]="Usage: %s %s";
	
	if (argc!=2) {
		sprintf(s,comment,argv[0],argv[1]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	tel = (struct telprop*)clientData;
	if (tel->tube_current_side== 0) {
		Tcl_SetResult(interp,"west",TCL_STATIC);
	} else {
		Tcl_SetResult(interp,"east",TCL_STATIC);
	}
	return TCL_OK;
}

/*
 *  Temporisation pour les acces au port serie
 */
int cmdTelTempo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[100];
	struct telprop *tel;
	char comment[]="Usage: %s %s ?ms?";
	
	if (argc>3) {
		sprintf(s,comment,argv[0],argv[1]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	tel = (struct telprop*)clientData;
	if (argc == 3) {
		tel->tempo=atoi(argv[2]);
	}
	sprintf(s,"%d",tel->tempo);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

/*
 *  Temporisation pour les appels aux goto bloquants
 */
int cmdTelTempoGoto(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[100];
	struct telprop *tel;
	char comment[]="Usage: %s %s ?dead_ms read_ms?";
	
	if (argc>4) {
		sprintf(s,comment,argv[0],argv[1]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	tel = (struct telprop*)clientData;
	if ((argc>=3)&&(argc<=4)) {
		tel->gotodead_ms=atoi(argv[2]);
		tel->gotoread_ms=atoi(argv[3]);
	}
	sprintf(s,"%d %d",tel->gotodead_ms,tel->gotoread_ms);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

/*
 *   delai en secondes estime pour un slew sans bouger
 */
int cmdTelDeadDelaySlew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {   
      tel->dead_delay_slew=atof(argv[2]);
   }
   sprintf(s,"%f",tel->dead_delay_slew);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   retourne l'etat logique de tracking
 */
int cmdTelState(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   sprintf(s,"%s",state2string(tel->state));
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   retourne les parametres de la monture
 */
int cmdTelReadparams(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ss[2048];
   char sss[248];
   char s[12048];
	int res,num,num2;
	double v;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
	strcpy(s,"");
	sprintf(ss,"{a1 %d {ADU/360deg} {microsteps/360deg}} {a2 %d {ADU/360deg} {microsteps/360deg}} ",tel->param_a1,tel->param_a2); strcat(s,ss);
	sprintf(ss,"{b1 %d {ADU^2/sec} {velocity parameter i1 = (1|g1) * b1 / speedtrackHA(deg/s) / (a1/360)}} {b2 %d {ADU^2/sec} {velocity_parameter i2 = (1|g2) * b2 / speedtrackDEC(deg/s) / (a2/360)}} ",tel->param_b1,tel->param_b2); strcat(s,ss);
	//
   sprintf(sss,":c1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{c1 %d {ADU} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":c2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{c2 %d {ADU} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
   sprintf(sss,":d1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{d1 %d {ADU} {motorRA initial position j1 when the mount is just switched on}} ",num); strcat(s,ss);
   sprintf(sss,":d2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{d2 %d {ADU} {motorDEC initial position j2 when the mount is just switched on}} ",num); strcat(s,ss);
	//
   sprintf(sss,":e1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{e1 %d {ADU} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":e2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{e2 %d {ADU} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
   sprintf(sss,":f1"); res=eqmod_putread(tel,sss,ss); num=atoi(ss) ;tel->param_f1=num;
	sprintf(ss,"{f1 %d {integers} {motorRA slewing state 0|1|2|3|5|7=jog_slow+|stop+|jog_slow-|stop-|jog_fast+|jog_fast- 0|1=Stoped|Jogging 0|1=PB?|OK?}} ",tel->param_f1); strcat(s,ss);
   sprintf(sss,":f2"); res=eqmod_putread(tel,sss,ss); num=atoi(ss) ;tel->param_f2=num;
	sprintf(ss,"{f2 %d {integers} {motorDEC slewing state 0|1|2|3|5|7=jog_slow+|stop+|jog_slow-|stop-|jog_fast+|jog_fast- 0|1=Stoped|Jogging 0|1=PB?|OK?}} ",tel->param_f1); strcat(s,ss);
	//
   sprintf(sss,":g1"); res=eqmod_putread(tel,sss,ss); num=atoi(ss);
	sprintf(ss,"{g1 %d {integers} {motorRA fast tracking speed multiplier (set with :G13x)} } ",num); strcat(s,ss);
   sprintf(sss,":g2"); res=eqmod_putread(tel,sss,ss); num=atoi(ss);
	sprintf(ss,"{g2 %d {integers} {motorDEC fast tracking speed multiplier (set with :G13x)} } ",num); strcat(s,ss);
	//
   sprintf(sss,":h1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{h1 %d {ADU} {motorRA Next position to reach = %f degs (set with :H1)}} ",num,360.*num/tel->param_a1); strcat(s,ss);
   sprintf(sss,":h2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{h2 %d {ADU} {motorDEC Next position to reach = %f degs (set with :H2)}} ",num,360.*num/tel->param_a2); strcat(s,ss);
	//
   sprintf(sss,":i1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	num2=(num==0)?1:num;
	v=tel->param_b1*360./num2/tel->param_a1;
	sprintf(ss,"{i1 %d {ADU} {motorRA Next tracking speed = %f deg/s or %f deg/s (set with :I1, start with :J1)}} ",num,v,tel->param_g1*v); strcat(s,ss);
   sprintf(sss,":i2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	num2=(num==0)?1:num;
	v=tel->param_b2*360./num2/tel->param_a2;
	sprintf(ss,"{i2 %d {ADU} {motorDEC Next tracking speed = %f deg/s or %f deg/s (set with :I2, start with :J2)}} ",num,v,tel->param_g2*v); strcat(s,ss);
	//
   sprintf(sss,":j1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(sss,"{j1 %d {ADU} {motorRA Current encoder position = %s Hex = %f degs (set with :E1)}} ",num,ss,360.*num/tel->param_a1); strcat(s,sss);
   sprintf(sss,":j2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(sss,"{j2 %d {ADU} {motorDEC Current encoder position = %s Hex = %f degs (set with :E2)}} ",num,ss,360.*num/tel->param_a2); strcat(s,sss);
	//
	/*
   sprintf(sss,":k1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{k1 %d {string} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":k2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{k2 %d {string} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
   sprintf(sss,":l1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{l1 %d {string} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":l2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{l2 %d {string} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
	*/
   sprintf(sss,":m1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{m1 %d {ADU} {motorRA start braking position with GOTO = %f degs (set with :M1)}} ",num,360.*num/tel->param_a1); strcat(s,ss);
   sprintf(sss,":m2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{m2 %d {ADU} {motorDEC start braking position with GOTO = %f degs (set with :M2)}} ",num,360.*num/tel->param_a2); strcat(s,ss);
	//
	/*
   sprintf(sss,":n1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{n1 %d {string} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":n2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{n2 %d {string} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
   sprintf(sss,":o1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{o1 %d {string} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":o2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{o2 %d {string} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
   sprintf(sss,":p1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{p1 %d {string} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":p2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{p2 %d {string} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
   sprintf(sss,":q1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{q1 %d {string} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":q2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{q2 %d {string} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
   sprintf(sss,":r1"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{r1 %d {string} {motorRA unidentified parameter}} ",num); strcat(s,ss);
   sprintf(sss,":r2"); res=eqmod_putread(tel,sss,ss); eqmod_decode(tel,ss,&num);
	sprintf(ss,"{r2 %d {string} {motorDEC unidentified parameter}} ",num); strcat(s,ss);
	//
	*/
	sprintf(ss,"{s1 %d {ADU/turn} {microsteps to a complete turnover of worm}} {s2 %d {ADU/turn} {microsteps to a complete turnover of worm}} ",tel->param_s1,tel->param_s2); strcat(s,ss);
	sprintf(ss,"{speed_track_ra %f {deg/s} {motorRA track speed}} {speed_track_dec %f {deg/s} {motorDEC track speed}} ",tel->speed_track_ra,tel->speed_track_dec); strcat(s,ss);
	sprintf(ss,"{speed_slew_ra %f {deg/s} {motorRA slew speed}} {speed_slew_dec %f {deg/s} {motorDEC slew speed}} ",tel->speed_slew_ra,tel->speed_slew_dec); strcat(s,ss);
	sprintf(ss,"{adu4deg_ha %f {ADU/deg} {motorRA position conversion}} ",tel->adu4deg_ha); strcat(s,ss);
	sprintf(ss,"{adu4deg_dec %f {ADU/deg} {motorDEC position conversion}} ",tel->adu4deg_dec); strcat(s,ss);
	sprintf(ss,"{track_diurnal %f {deg/s} {motorRA theoretical diurnal track}} ",tel->track_diurnal); strcat(s,ss);
	sprintf(ss,"{coord_adu_ha_wmax %d {ADU} {motorRA western stop}} {coord_adu_ha_emin %d {ADU} {motorRA eastern stop}} ",(int)tel->coord_adu_ha_wmax,(int)tel->coord_adu_ha_emin); strcat(s,ss);
	sprintf(ss,"{radec_move_rate_max %f {deg/s} {motorRA and motorDEC maximum authorized move speed}} ",tel->radec_move_rate_max); strcat(s,ss);
	sprintf(ss,"{slew_axis %d {integer} {motorRA and motorDEC motion states. 0: none, 1: RA, 2: DEC, 3: RA+DEC}} ",tel->slew_axis); strcat(s,ss);
	sprintf(ss,"{tube_prefered_side %d {binary} {0|1=tube position preference (W|E)}} ",tel->tube_prefered_side); strcat(s,ss);
	sprintf(ss,"{tube_current_side %d {binary} {0|1=tube current side (W|E)}} ",tel->tube_current_side); strcat(s,ss);
	sprintf(ss,"{gotodead_ms %d {ms} {waiting delay for a complete slew}} ",tel->gotodead_ms); strcat(s,ss);
	sprintf(ss,"{gotoread_ms %d {ms} {waiting delay for a answer}} ",tel->gotoread_ms); strcat(s,ss);
	sprintf(ss,"{dead_delay_slew %f {s} {delay for a GOTO at the same place}} ",tel->dead_delay_slew); strcat(s,ss);
	sprintf(ss,"{tempo %d {ms} {delay before to read a command}} ",tel->tempo); strcat(s,ss);
	sprintf(ss,"{problem_motor %d {binary} {0=no pb 1=pb encoders}} ",tel->problem_motor); strcat(s,ss);
	sprintf(ss,"{park_deg_ha %f {deg} {motorRA Parking hour angle}} {park_deg_dec %f {deg} {motorDEC Parking declination}} ",tel->park_deg_ha,tel->park_deg_dec); strcat(s,ss);
	sprintf(ss,"{park_adu_ha %f {ADU} {motorRA Parking hour angle}} {park_adu_dec %f {ADU} {motorDEC Parking declination}} ",tel->park_adu_ha,tel->park_adu_dec); strcat(s,ss);
	sprintf(ss,"{gotoblocking %d {binary} {default GOTO blocking 0|1=non_blocking|blocking}} ",tel->gotoblocking); strcat(s,ss);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   Goto parking
 */
int cmdTelGotoparking(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
	tel->flag_gotoparking=1;
	sprintf(s,"tel%d hadec goto {%f %f} -blocking 0",tel->telno,tel->park_deg_ha,tel->park_deg_dec);
   Tcl_Eval(interp,s);
   strcpy(s,Tcl_GetStringResult(interp));
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   HaDec parking
 */
int cmdTelHaDecparking(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[100],ligne[200];
	int tube_side;
   double deg_ha,deg_dec,adu_ha,adu_dec;
	struct telprop *tel;
	char comment[]="Usage: %s %s {Angle_ha Angle_dec} Tube_Side(E|W)";
	tel = (struct telprop*)clientData;
	if (argc!=2) {
		if (argc!=4) {
			sprintf(s,comment,argv[0],argv[1]);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		strcpy(ligne,argv[2]);
		libtel_Getradec(interp,ligne,&deg_ha,&deg_dec);
		strcpy(ligne,argv[3]);
		if ((ligne[0]=='e')||(ligne[0]=='E')) {
			tube_side=TUBE_EST;
		} else {
			tube_side=TUBE_OUEST;
		}
		if (tel->latitude >= 0.0 ) {
			if (tube_side == TUBE_OUEST) {
				adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			} else {
				adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			}
		} else {
			if (tube_side == TUBE_OUEST) {
				adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			} else {
				adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			}
		}
		tel->park_deg_ha=deg_ha;
		tel->park_deg_dec=deg_dec;
		tel->park_adu_ha=adu_ha;
		tel->park_adu_dec=adu_dec;
	}
	sprintf(s,"{%f %f deg} {%f %f ADU}",tel->park_deg_ha,tel->park_deg_dec,tel->park_adu_ha,tel->park_adu_dec);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

/*
 *   GotoBlocking
 */
int cmdTelGotoblocking(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {
      tel->gotoblocking=atoi(argv[2]);
   }
   sprintf(s,"%d",tel->gotoblocking);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}
