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
#if defined(OS_LIN)
#include <ctype.h>
#endif

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"EQMOD",    /* telescope name */
    "EQMOD",    /* protocol name */
    "eqmod",    /* product */
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
   int k,num,res, i, j, start_motor;
   char s[1024],ssres[1024];
   char ss[1024],ssusb[1024];
	char portnum[128];
   double ha, dec;
	int j1,j2;
	int mode_debug = 0,tempo;
   FILE *f;

   tel->state               = EQMOD_STATE_NOT_INITIALIZED;
   tel->old_state           = tel->state;
	tel->tube_prefered_side  = TUBE_OUEST;
   tel->track_diurnal       = 360.0/86164.; // 0.00417807901212 (deg/s)
   tel->speed_track_ra      = tel->track_diurnal; // (deg/s)
   tel->speed_track_dec     = 0.;  // (deg/s)
   tel->speed_slew_ra       = 2.;  // (deg/s)
   tel->speed_slew_dec      = 2.;  // (deg/s)
   tel->radec_move_rate_max = 1.0; // deg/s
   tel->tempo=50;
   tel->ha_pointing=0; // type de pointage, RADEC=0 HADEC=1
   tel->mouchard=0; // 0=pas de fichier log
   tel->latitude=43.75203;
   sprintf(tel->home,"GPS 6.92353 E %+.6f 1320.0",tel->latitude);
	tel->gotoblocking=0;
	tel->flag_gotoparking=0;

   start_motor = 0; // On ne demarre pas le moteur par défaut
   ha = 0.0;
   dec = 0.0;
   
   // transcode a port argument into comX or into /dev...
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

   // Open the port and record the channel name
	strcpy(portnum,ss);
   sprintf(s,"open \"%s\" r+",ss);
   if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
      strcpy(ssres,Tcl_GetStringResult(tel->interp));
      Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
      strcpy(s,Tcl_GetStringResult(tel->interp));
      if (strcmp(s,"Linux")==0) {
         // if ttyS not found, we test ttyUSB
			strcpy(portnum,ssusb);
         sprintf(s,"open \"%s\" r+",ssusb);
         if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
				sprintf(tel->msg,"Problem to opening the COM ports %s and %s. %s",ss,ssusb,Tcl_GetStringResult(tel->interp));
            return 1;
         }
         strcpy(ss,ssusb);
      } else {
			sprintf(tel->msg,"Problem to opening the COM port %s. %s",ss,ssres);
         return 1;
      }
   }
   strcpy(tel->channel,Tcl_GetStringResult(tel->interp));   
   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); mytel_tcleval(tel,s);
   sprintf(s,"flush %s",tel->channel); mytel_tcleval(tel,s);

   for (i=0;i<argc;i++) {
      if ( ! strcmp(argv[i],"-mouchard") ) {
         tel->mouchard = 1;
      }
      if ( ! strcmp(argv[i],"-east") ) {
			tel->tube_prefered_side= TUBE_EST;
      }
      if ( (strcmp(argv[i],"-gps")==0)&&(i<=(argc-2)) ) {
         sprintf(tel->home,"%s",argv[i+1]);
			sprintf(s,"lindex {%s} 3",tel->home);
			if (mytel_tcleval(tel,s)==TCL_OK) {
				tel->latitude = atof(Tcl_GetStringResult(tel->interp));
			} else {
				tel->latitude = 48;
			}
      }
      if ( ! strcmp(argv[i],"-startmotor") ) {
         start_motor = 1;
      }
      if ( ! strcmp(argv[i],"-debug") ) {
         mode_debug = 1;
      }
   }

//tel->mouchard=2; // 0=pas de fichier log
//mode_debug = 1;

   // Initialisation du fichier mouchard
   if (tel->mouchard>=1) {
      f=fopen("mouchard_eqmod.txt","wt");
		fprintf(f,"argc = %d",argc);
		for (j=0;j<argc;j++) {
			fprintf(f,"argv[%d] = %s\n",j,argv[j]);
		}
      fclose(f);
   }

	// Test de la connexion et optimisation de la temporisation de la reponse
	if (mode_debug == 0 ) {
		for (tempo=30;tempo<=300;tempo+=10) {
			tel->tempo=tempo;
			sprintf(s,":e1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
			if (num>0) {
				tel->param_e1=num;
				break;
			}
		}
		if ( strlen(ss) == 0 ) {
			sprintf(tel->msg,"EQMOD protocol error (:e1=%d). Verify: (1) cable connection, (2) serial port %s is not the good one, (3) the power supply of the mount.",num,portnum);
			sprintf(s,"close %s",tel->channel); mytel_tcleval(tel,s);
			return 1;
		}
		if (tempo<50) {
			tempo+=10;
		} else {
			tempo=(int)(tempo*1.2);
		}
		sprintf(s,":e2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_e2=num;

		// Initialisation de la communication avec la monture
		sprintf(s,":f1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		sprintf(s,":f2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);   

		sprintf(s,":a1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		if (num==0) { num=1 ; } ; // avoid division by zero
		tel->param_a1=num; // Microsteps per axis Revolution

		sprintf(s,":a2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		if (num==0) { num=1 ; } ; // avoid division by zero
		tel->param_a2=num; // Microsteps per axis Revolution

		sprintf(s,":b1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_b1=num;

		sprintf(s,":b2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_b2=num;

		sprintf(s,":g1"); res=eqmod_putread(tel,s,ss); num=atoi(ss);
		tel->param_g1=num;

		sprintf(s,":g2"); res=eqmod_putread(tel,s,ss); num=atoi(ss);
		tel->param_g2=num;

		sprintf(s,":s1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_s1=num; // Microsteps per Worm Revolution

		sprintf(s,":s2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_s2=num; // Microsteps per Worm Revolution

		sprintf(s,":f1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_f1=num;

		sprintf(s,":f2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_f2=num;

		sprintf(s,":d1"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_d1=num;

		sprintf(s,":d2"); res=eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&num);
		tel->param_d2=num;
	} else {
		tempo=30;
		// --- EQ6
		tel->param_a1=9024000;
		tel->param_a2=9024000;
		tel->param_b1=64935;
		tel->param_b2=64935;
		tel->param_e1=1026;
		tel->param_e2=1026;
		tel->param_g1=16;
		tel->param_g2=16;
		tel->param_s1=50133;
		tel->param_s2=50133;
		tel->param_d1=TOTAL_MICROSTEPS/2;
		tel->param_d2=TOTAL_MICROSTEPS/2;
	}

   // Facteur de conversion deg vers step: step = deg * tel->radec_position_conversion
	tel->adu4deg_ha=1.0 * tel->param_a1 / 360.;      // (ADU/deg)
	tel->adu4deg_dec=1.0 * tel->param_a2 / 360.;     // (ADU/deg)

	tel->coord_adu_ha0=0;
	tel->coord_deg_ha0=0;
	tel->coord_adu_dec0=0;
	tel->coord_deg_dec0=0;

   for (i=0;i<argc;i++) {
		// --- pointing direction of the parking|initial position
      if ( (strcmp(argv[i],"-point")==0)&&(i<=(argc-2)) ) {
         if ( ! strcmp(argv[i+1],"east") ) {
				tel->coord_adu_ha0=-90*tel->adu4deg_ha;
				tel->coord_deg_ha0=-90;
				tel->coord_adu_dec0=0*tel->adu4deg_dec;
				tel->coord_deg_dec0=0;
         } else if ( ! strcmp(argv[i+1],"west") ) {
				tel->coord_adu_ha0=-90*tel->adu4deg_ha;
				tel->coord_deg_ha0=90;
				tel->coord_adu_dec0=180*tel->adu4deg_dec;
				tel->coord_deg_dec0=0;
         } else if ( ! strcmp(argv[i+1],"south") ) {
				if ( tel->tube_prefered_side == TUBE_OUEST ) {
					tel->coord_adu_ha0=0*tel->adu4deg_ha;
					tel->coord_deg_ha0=0;
					tel->coord_adu_dec0=0*tel->adu4deg_dec;
					tel->coord_deg_dec0=0;
				} else {
					tel->coord_adu_ha0=-180*tel->adu4deg_ha;
					tel->coord_deg_ha0=0;
					tel->coord_adu_dec0=180*tel->adu4deg_dec;
					tel->coord_deg_dec0=0;
				}
         } else if ( ! strcmp(argv[i+1],"north") ) {
				tel->coord_adu_dec0=90*tel->adu4deg_dec;
				tel->coord_deg_dec0=90;
				if ( tel->tube_prefered_side == TUBE_OUEST ) {
					tel->coord_adu_ha0=0*tel->adu4deg_ha;
					tel->coord_deg_ha0=0;
				} else {
					tel->coord_adu_ha0=-180*tel->adu4deg_ha;
					tel->coord_deg_ha0=-180;
				}
         } else if ( ! strcmp(argv[i+1],"north_pole") ) {
				tel->coord_adu_ha0=-90*tel->adu4deg_ha;
				tel->coord_deg_ha0=-90;
				tel->coord_adu_dec0=90*tel->adu4deg_dec;
				tel->coord_deg_dec0=90;
         } else if ( ! strcmp(argv[i+1],"south_pole") ) {
				tel->coord_adu_ha0=-90*tel->adu4deg_ha;
				tel->coord_deg_ha0=-90;
				tel->coord_adu_dec0=-90*tel->adu4deg_dec;
				tel->coord_deg_dec0=-90;
         }
      }
   }
	// --- add the half of the microstep dynamic to avoid negative ADU values
	// so we put the (HA=0h,DEC=0d) position at (8388608,8388608) ADUs:
	tel->coord_adu_ha0+=TOTAL_MICROSTEPS/2;
	tel->coord_adu_dec0+=TOTAL_MICROSTEPS/2;
	// --- Be careful. 8388608 is the half range of the microsteps
	// but it is also the value given by :j1 and :j2 when one turn on
	// the power supply of the mount. This characteristic may cause a
	// problem in a very special case: When the astronomer let the
	// mount on (HA=0h,DEC=0d) and he restart the driver without 
	// "turn off-turn on" it becomes impossible to the software to
	// know if the mount is at position (HA=0h,DEC=0d) or in a another
	// parking position before the mount turn off. To avoid this problem
	// we add a very small quantity to shift the problem in a very
	// improbable position:
	tel->coord_adu_ha0+=-608;
	tel->coord_adu_dec0+=-608;

	tel->park_adu_ha=tel->coord_adu_ha0;
	tel->park_adu_dec=tel->coord_adu_dec0;
	tel->park_deg_ha=tel->coord_deg_ha0;
	tel->park_deg_dec=tel->coord_deg_dec0;

   // Init des positions moteurs
   sprintf(s,":j1"); eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&j1);
   sprintf(s,":j2"); eqmod_putread(tel,s,ss); eqmod_decode(tel,ss,&j2);
	if ( (j1==tel->param_d1)&&(j2==tel->param_d2) ) {
      // On vient d'allumer la monture. Les deux positions sont sur 000080 hexa (=8388608)
      eqmod_encode(tel,(int)tel->coord_adu_ha0,ss);
      sprintf(s,":E1%s",ss); eqmod_putread(tel,s,ss);
      eqmod_encode(tel,(int)tel->coord_adu_dec0,ss);
      sprintf(s,":E2%s",ss); eqmod_putread(tel,s,ss);
   }
   sprintf(s,":j1"); eqmod_putread(tel,s,ss);
   sprintf(s,":j2"); eqmod_putread(tel,s,ss);

	// Limites physiques de pointages pour les deux positions de tube
	tel->coord_adu_ha_max= TOTAL_MICROSTEPS-1; /* FFFFFF */
	tel->coord_adu_ha_min=0; /* 000000 */
	tel->coord_adu_dec_max= TOTAL_MICROSTEPS-1; /* FFFFFF */
	tel->coord_adu_dec_min=0; /* 000000 */
   tel->coord_deg_ha_wmin = tel->coord_deg_ha0 + (tel->coord_adu_ha_min  - tel->coord_adu_ha0) / tel->adu4deg_ha;
   tel->coord_deg_ha_emax = tel->coord_deg_ha0 + (tel->coord_adu_ha_max  - tel->coord_adu_ha0) / tel->adu4deg_ha;
	// Limites de retournement de pointages pour les deux positions de tube
	tel->coord_deg_ha_wmax =  30.0;
	tel->coord_deg_ha_emin = -30.0;
	tel->coord_adu_ha_wmax = tel->coord_adu_ha0 + (tel->coord_deg_ha_wmax - tel->coord_deg_ha0) * tel->adu4deg_ha;
	tel->coord_adu_ha_emin = tel->coord_adu_ha0 + (tel->coord_deg_ha_emin - tel->coord_deg_ha0) * tel->adu4deg_ha;

	tel->old_state = tel->state;
   tel->state = EQMOD_STATE_HALT;

   // Mise en route de l'alimentation des moteurs
   sprintf(s,":F1"); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":F2"); res=eqmod_putread(tel,s,NULL);

   // On ne sait pas a quoi ça sert
   sprintf(s,":P13"); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":P23"); res=eqmod_putread(tel,s,NULL);

	tel->problem_motor=PROBLEM_MOTOR_NOTHING;

   tel->old_state = tel->state;
   tel->state = EQMOD_STATE_STOPPED;

	if ( start_motor==1 ) {
		tel->radec_motor=0;
	} else {
		tel->radec_motor=1;
	}
	eqmod2_action_motor(tel);

	tel->dead_delay_slew=1.8; /* delai en secondes estime pour un slew sans bouger */
	tel->gotodead_ms=900;
	tel->gotoread_ms=350;

	if (strcmp(tel->home,"")==0) {
		strcpy(tel->home,"GPS 0 E 45 100");
	}
	strcpy(tel->homePosition,tel->home);
   eqmod_radec_coord(tel,NULL);

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
   return eqmod_delete(tel);
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return eqmod2_match(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return eqmod_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   sprintf(result,"%s %d",state2string(tel->state),tel->tube_current_side);
   return 0;
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
	tel->ha_pointing=0;
	tel->flag_gotoparking=0;
   return eqmod2_action_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
   return eqmod2_action_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
	tel->flag_gotoparking=0;
   return eqmod2_action_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return eqmod2_action_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return 0;
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return 0;
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
	return 0;
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
	return 0;
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   libtel_GetCurrentUTCDate(tel->interp,ligne);
	/*
   time_t ltime;
   double jd;
   char s[100];
	jd=mytel_sec2jd((int)time(&ltime));
	sprintf(s,"mc_date2iso8601 %f",jd);
	Tcl_Eval(tel->interp,s);
	strcpy(ligne,Tcl_GetStringResult(tel->interp));
	*/
   return 0;
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return 0;
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   strcpy(ligne,tel->home);
   return 0;
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {GPS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   longitude=(double)fabs(longitude);
   if (longitude>360.) { longitude=0.; }
   if ((ew[0]!='w')&&(ew[0]!='W')&&(ew[0]!='e')&&(ew[0]!='E')) {
      ew[0]='E';
   }
   if (latitude>90.) {latitude=90.;}
   if (latitude<-90.) {latitude=-90.;}
   sprintf(tel->home,"GPS %f %c %f %f",longitude,ew[0],latitude,altitude);
   tel->latitude=latitude;
   return 0;
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
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   FILE *f;
   if (tel->mouchard==1) {
      f=fopen("mouchard_eqmod.txt","at");
      fprintf(f,"EVAL <%s>\n",ligne);
      fclose(f);
   }
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {
      if (tel->mouchard==1) {
         f=fopen("mouchard_eqmod.txt","at");
         fprintf(f,"RESU-PB <%s>\n",Tcl_GetStringResult(tel->interp));
         fclose(f);
      }
      return 1;
   }
   if (tel->mouchard==1) {
      f=fopen("mouchard_eqmod.txt","at");
      fprintf(f,"RESU-OK <%s>\n",Tcl_GetStringResult(tel->interp));
      fclose(f);
   }
   return 0;
}

int eqmod_delete(struct telprop *tel)
{
   char s[1024];
   // --- Fermeture du port com
   sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
   return 0;
}

int eqmod_put(struct telprop *tel,char *cmd)
{
   char s[1024];
   sprintf(s,"read -nonewline %s ; puts -nonewline %s \"%s\\r\" ; flush %s",tel->channel,tel->channel,cmd,tel->channel);
   if (mytel_tcleval(tel,s)==1) {
      return 1;
   }
   return 0;
}

int eqmod_read(struct telprop *tel,char *res)
{
   char s[2048];
   const char *ss;
   strcpy(res,"");
   sprintf(s,"read %s",tel->channel);
   if (mytel_tcleval(tel,s)==1) {
      return 1;
   }
   ss=Tcl_GetStringResult(tel->interp);
   if ((int)strlen(ss)>1) {
      if (ss[0]=='!') {
         sprintf(res,"Error %s",ss+1);
      } else {
         strcpy(res,ss+1);
      }
   } else {
      strcpy(res,ss);
   }
   return 0;
}

int eqmod_putread(struct telprop *tel,char *cmd,char *res)
{
   char s[1024];
   const char *ss;
   if (res!=NULL)
      *res = 0;
   sprintf(s,"read -nonewline %s ; puts -nonewline %s \"%s\\r\" ; flush %s ; after %d ; read %s",tel->channel,tel->channel,cmd,tel->channel,tel->tempo,tel->channel);
   if (mytel_tcleval(tel,s)==1) {
      return 1;
   }
   if (res!=NULL) {
      ss=Tcl_GetStringResult(tel->interp);
      if ((int)strlen(ss)>1) {
         if (ss[0]=='!') {
            sprintf(res,"Error %s",ss+1);
         } else {
            strcpy(res,ss+1);
         }
      } else {
         strcpy(res,ss);
      }
   }
   strcpy(s,Tcl_GetStringResult(tel->interp));
   if (strlen(s)>0) s[strlen(s)-1] = 0;
   return 0;
}

int eqmod_decode(struct telprop *tel,char *chars,int *num)
{
   char s[2048];
	sprintf(s,"set n [string length [format %%0X -1]] ; set sig [expr int(0x[string index %s 4])] ; if {$sig<=7} { set sym 0 } else { set sym F } ; set comp [string repeat $sym [expr $n-6]] ; set deci [expr int(0x${comp}[ string range %s 4 5 ][ string range %s 2 3 ][ string range %s 0 1 ])] ; if {$deci<0} { set deci [expr 16777216+$deci] } ; expr $deci",chars,chars,chars,chars);
   if (mytel_tcleval(tel,s)==1) {
      *num=0;
      return 1;
   }
   *num=atoi(Tcl_GetStringResult(tel->interp));
   return 0;
}

int eqmod_encode(struct telprop *tel,int num,char *chars)
{
   char s[2048],ss[2048];
   sprintf(s,"string range [ format %%08X %d ] end-5 end",num);
   if (mytel_tcleval(tel,s)==1) {
      strcpy(chars,Tcl_GetStringResult(tel->interp));
      return 1;
   }
	strcpy(ss,Tcl_GetStringResult(tel->interp));
   sprintf(s,"subst [ string range %s 4 5 ][ string range %s 2 3 ][ string range %s 0 1 ]",ss,ss,ss);
   if (mytel_tcleval(tel,s)==1) {
      strcpy(chars,Tcl_GetStringResult(tel->interp));
      return 1;
   }
   strcpy(chars,Tcl_GetStringResult(tel->interp));
   return 0;
}

/*
 * Coordonnees en ADU
 */
int eqmod_positions12(struct telprop *tel,int *p1,int *p2)
{
   char s[1024],ss[1024],axe;
   int res;
	double pole_deg,pole_adu;

   // Vide le buffer
   res=eqmod_read(tel,s);

   // Lecture AXE 1 (axe horaire)
   axe='1';
   sprintf(ss,":j%c",axe);
   res=eqmod_putread(tel,ss,s);
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (res==0) {
      eqmod_decode(tel,s,&res);
      *p1=res;
		if (res==tel->param_d1) {
			// traiter le cas d'une panne de courant
			tel->problem_motor=PROBLEM_MOTOR_MINI_ENCODERS;
		}
		tel->coord_adu_ha=(double)(res);
   }

   // Lecture AXE 2 (axe declinaison)
   axe='2';
   sprintf(ss,":j%c",axe);
   res=eqmod_putread(tel,ss,s);
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (strcmp(s,"")==0) {
      res=eqmod_putread(tel,ss,s);
   }
   if (res==0) {
      eqmod_decode(tel,s,&res);
      *p2=res;
		if (res==tel->param_d2) {
			// traiter le cas d'une panne de courant
			tel->problem_motor=PROBLEM_MOTOR_MINI_ENCODERS;
		}
		tel->coord_adu_dec=(double)(res);
   }

	// Tube position
	if (tel->latitude >= 0.0 ) {
		pole_deg=90;
	} else {
		pole_deg=-90;
	}
	pole_adu = tel->coord_adu_dec0 + (pole_deg - tel->coord_deg_dec0) * tel->adu4deg_dec;

	if ( tel->coord_adu_dec <= pole_adu ) {
		tel->tube_current_side=TUBE_OUEST;
	} else {
		tel->tube_current_side=TUBE_EST;
	}

   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage EQMOD      --------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

void eqmod_codeur2skypos(struct telprop *tel, int hastep, int decstep, double *ha, double *ra, double *dec, int *flip, double *ha_raw, double *dec_raw)
{
   double lst;
	double deg_ha,deg_ra,deg_dec;

	if (tel->problem_motor==PROBLEM_MOTOR_NOTHING) {
		if (tel->latitude >= 0.0 ) {
			if (tel->tube_current_side == TUBE_OUEST) {
				*flip=0;
				tel->coord_deg_ha  = tel->coord_deg_ha0  + (tel->coord_adu_ha -tel->coord_adu_ha0 ) / tel->adu4deg_ha  ;
				tel->coord_deg_dec = tel->coord_deg_dec0 + (tel->coord_adu_dec-tel->coord_adu_dec0) / tel->adu4deg_dec ;
			} else {
				*flip=1;
				tel->coord_deg_ha  = tel->coord_deg_ha0  + (tel->coord_adu_ha -tel->coord_adu_ha0 ) / tel->adu4deg_ha  -180 ;
				tel->coord_deg_dec = tel->coord_deg_dec0 - (tel->coord_adu_dec-tel->coord_adu_dec0) / tel->adu4deg_dec ;
			}
		} else {
			if (tel->tube_current_side == TUBE_OUEST) {
				*flip=0;
				tel->coord_deg_ha  = tel->coord_deg_ha0  - (tel->coord_adu_ha -tel->coord_adu_ha0 ) / tel->adu4deg_ha  -180 ;
				tel->coord_deg_dec = tel->coord_deg_dec0 - (tel->coord_adu_dec-tel->coord_adu_dec0) / tel->adu4deg_dec ;
			} else {
				*flip=1;
				tel->coord_deg_ha  = tel->coord_deg_ha0  - (tel->coord_adu_ha -tel->coord_adu_ha0 ) / tel->adu4deg_ha  ;
				tel->coord_deg_dec = tel->coord_deg_dec0 + (tel->coord_adu_dec-tel->coord_adu_dec0) / tel->adu4deg_dec ;
			}
		}
		deg_dec = tel->coord_deg_dec ;
	}

   deg_ha = fmod(tel->coord_deg_ha+360*7,360.);
   // Recadrage de l'angle horaire entre -180°,180°.
   if ( deg_ha > 180.0 ) {
      deg_ha -= 360.0;
   }

   lst = eqmod_tsl(tel,NULL,NULL,NULL);
   deg_ra = lst - deg_ha + 360 * 7; // Remember: H=TSL-alpha => alpha=TSL-H
   deg_ra = fmod(deg_ra,360.);

   if (ha) {
      *ha = deg_ha;
   }
   if (ra) {
      *ra = deg_ra;
   }
   if (dec) {
      *dec = deg_dec;
   }

}

int eqmod_radec_coord(struct telprop *tel,char *result)
{
   char s[1024], ras[20], decs[20];
   int hastep, decstep;
   double ra, dec;
	int flip; 
	double ha_raw, dec_raw;

   eqmod_positions12(tel, &hastep, &decstep);
   eqmod_codeur2skypos(tel, hastep, decstep, NULL, &ra, &dec,&flip,&ha_raw,&dec_raw);

   // Elaboration de la chaine de caracteres en sortie, si besoin
   if ( NULL != result ) {
      sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ra); mytel_tcleval(tel,s);
      strcpy(ras,Tcl_GetStringResult(tel->interp));
      sprintf(s,"mc_angle2dms %f 90 zero 1 + string",dec); mytel_tcleval(tel,s);
      strcpy(decs,Tcl_GetStringResult(tel->interp));
      sprintf(result,"%s %s",ras,decs);
   }

   return 0;
}

int eqmod_hadec_coord(struct telprop *tel,char *result)
{
   char s[1024], ras[20], decs[20];
   int hastep, decstep;
   double ha, dec;
	int flip; 
	double ha_raw, dec_raw;

   eqmod_positions12(tel, &hastep, &decstep);
   eqmod_codeur2skypos(tel, hastep, decstep, &ha, NULL, &dec,&flip,&ha_raw,&dec_raw);

   // Elaboration de la chaine de caracteres en sortie, si besoin
   if ( NULL != result ) {
      sprintf(s,"mc_angle2hms %f 360 zero 2 auto string",ha); mytel_tcleval(tel,s);
      strcpy(ras,Tcl_GetStringResult(tel->interp));
      sprintf(s,"mc_angle2dms %f 90 zero 1 + string",dec); mytel_tcleval(tel,s);
      strcpy(decs,Tcl_GetStringResult(tel->interp));
      sprintf(result,"%s %s",ras,decs);
   }

   return 0;
}

/* Initialisation des codeurs, avec :
 *  ah passe par: tel->ra0
 *  dec passee par: tel->dec0
 */
int eqmod_hadec_match(struct telprop *tel)
{
   char s[1024],ss[1024];
   int p;
   double ha,deg_ha,deg_dec,adu_ha,adu_dec;
	int iha,idec;

   if ( ( tel->state != EQMOD_STATE_STOPPED ) && ( tel->state != EQMOD_STATE_TRACK ) ) {
      return -1;
   }
	if (tel->problem_motor!=PROBLEM_MOTOR_NOTHING) {
		return -2;
	}

   if ( tel->state == EQMOD_STATE_TRACK ) {
		tel->radec_motor=1;
      eqmod2_action_motor(tel);
   }

	eqmod_positions12(tel, &iha, &idec);
   
   // --- HA ---
   ha=tel->ra0+360*5;
   ha=fmod(ha,360.);
	if (ha>180) {
		ha-=360;
	}

	deg_ha=ha;
	deg_dec=tel->dec0;

	if (tel->latitude >= 0.0 ) {
		if (tel->tube_current_side == TUBE_OUEST) {
			adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		} else {
			adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		}
	} else {
		if (tel->tube_current_side == TUBE_OUEST) {
			adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		} else {
			adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		}
	}

   // --- Init AXE 1 (horaire) 0 UC pour HA = 0h ---
   p = ( int ) ( adu_ha );
   eqmod_encode(tel,p,s);
   sprintf(ss,":E1%s",s);
   if ( eqmod_putread(tel,ss,s) ) {
		return -1;
   }

   // --- Init AXE 2 (declinaison) 0 UC pour DEC = 0 deg ---
   p = ( int ) (  adu_dec );
   eqmod_encode(tel,p,s);
   sprintf(ss,":E2%s",s);
   if ( eqmod_putread(tel,ss,s) ) {
		return -2;
   }

   // --- ---
   return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage EQMOD    TOOLS ----------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

/***************************************************************************/
/* Return the julian day from seconds elapsed from Jan. 1st 1970           */
/***************************************************************************/
double mytel_sec2jd(time_t secs1970)
{
	return(2440587.5+(int)secs1970/86400.);
}

// eqmod_tsl
//  Calcule le temps sideral local.
//  Si non NULL, les parametres h, m, sec sont mis a jour.
//  La fonction renvoie le TSL en degres.
double eqmod_tsl(struct telprop *tel,int *h, int *m,double *sec)
{
   char s[1024];
   char ss[1024];
   double tsl;
   //time_t ltime;
   //double jd;
	double dt;

	dt=tel->dead_delay_slew/86400;
   libtel_GetCurrentUTCDate(tel->interp,ss);
   sprintf(s,"mc_date2lst [mc_datescomp %s + %f] {%s} -format deg",ss,dt,tel->home);
	//jd=mytel_sec2jd((int)time(&ltime));
   //sprintf(s,"mc_date2lst [expr %f + %f] {%s} -format deg",jd,dt,tel->home);
   mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
   tsl=atof(Tcl_GetStringResult(tel->interp)); /* en degres */
   return tsl;
}

int eqmod2_stopmotor(struct telprop *tel, int axe)
{
   int res;
   if ( axe & AXE_RA ) {
      res = eqmod_putread(tel,":K1",NULL);
   }
   if ( axe & AXE_DEC ) {
      res = eqmod_putread(tel,":K2",NULL);
   }
   return 0;
}

/******
:Gabc
a (axe number)
  1 = ra
  2 = dec
b (motion_type)
  0 = offset
  1 = mouvement infini lent (I1 > 9)
  2 = offset (=0)
  3 = mouvement infini rapide = lent * 16 (50 > I1 > 10)
c (sense)
  0 = ADU + (diurnal and toward pole for N hemisphere)
  1 = ADU -
******/
int eqmod2_track(struct telprop *tel)
{
   char s[1024],ss[1024],axe;
   int res,motion_type,motion_sense;
   double v;


   // Track Hour Axis
   axe='1';
   if (tel->speed_track_ra != 0) {
      v = fabs(((float)tel->param_b1) * 360.0 / ((float)tel->speed_track_ra) / ((float)tel->param_a1));
		motion_type=1;
		if (v<9) {
			motion_type=3;
			v=v*tel->param_g1; // g1=16
			if (v<10) { v=10; }
		}
		if (tel->latitude >= 0.0 ) {
			if (tel->speed_track_ra>0) {
				motion_sense=0;
			} else {
				motion_sense=1;
			}
		} else {
			if (tel->speed_track_ra>0) {
				motion_sense=1;
			} else {
				motion_sense=0;
			}
		}
		sprintf(s,":G%c%d%d",axe,motion_type,motion_sense);
		res=eqmod_putread(tel,s,NULL);
      eqmod_encode(tel,(int)v,ss);
      sprintf(s,":I%c%s",axe,ss);
      res=eqmod_putread(tel,s,NULL);
      sprintf(s,":J%c",axe);
      res=eqmod_putread(tel,s,NULL);
	} else {
      sprintf(s,":K%c",axe);
      res=eqmod_putread(tel,s,NULL);
	}

   // Track Declination Axis
   axe='2';
   if (tel->speed_track_dec != 0) {
      v = fabs(((float)tel->param_b2) * 360.0 / ((float)tel->speed_track_dec) / ((float)tel->param_a2));
		motion_type=1;
		if (v<9) {
			motion_type=3;
			v=v*tel->param_g2;
			if (v<10) { v=10; }
		}
		if (tel->latitude >= 0.0 ) {
			if (tel->speed_track_dec>0) {
				motion_sense=0;
			} else {
				motion_sense=1;
			}
		} else {
			if (tel->speed_track_dec>0) {
				motion_sense=1;
			} else {
				motion_sense=0;
			}
		}
		sprintf(s,":G%c%d%d",axe,motion_type,motion_sense);
		res=eqmod_putread(tel,s,NULL);
      eqmod_encode(tel,(int)v,ss);
      sprintf(s,":I%c%s",axe,ss);
      res=eqmod_putread(tel,s,NULL);
      sprintf(s,":J%c",axe);
      res=eqmod_putread(tel,s,NULL);
	} else {
      sprintf(s,":K%c",axe);
      res=eqmod_putread(tel,s,NULL);
	}
   return 0;
}

int eqmod2_move(struct telprop *tel, char direction)
{
   char s[1024],vc[20],axe;
   int res;
   double radec_move_rate;
	double g,a,b,i;
	int motion_type,motion_sense;

	if (direction>91) { direction-=32; } // minuscules -> Majuscules
	radec_move_rate=tel->radec_move_rate;
	if (tel->state == EQMOD_STATE_TRACK) {
		if (direction=='E') {
			radec_move_rate=tel->radec_move_rate - tel->track_diurnal;
			if (radec_move_rate<0) {
				radec_move_rate*=-1;
				direction='W';
			}
		} else if (direction=='W') {
			radec_move_rate=tel->radec_move_rate + tel->track_diurnal;
		}
	}

   if (radec_move_rate > tel->radec_move_rate_max) {
      radec_move_rate = tel->radec_move_rate_max;
   } else if (radec_move_rate < 0.) {
      radec_move_rate = 0.;
   }
	if (fabs(radec_move_rate) < 1e-10) {
		radec_move_rate = tel->track_diurnal/1000;
	}

	if ((direction=='E')||(direction=='W')) {
		axe='1';
		a=(double)tel->param_a1;
		b=(double)tel->param_b1;
		g=(double)tel->param_g1;
	} else {
		axe='2';
		a=(double)tel->param_a2;
		b=(double)tel->param_b2;
		g=(double)tel->param_g2;
	}

	// --- motion type
   if (radec_move_rate>0.25) {
      motion_type=3; // fast infinite
		i = g * b / (float)radec_move_rate / a * 360.0 ;
   } else {
      motion_type=1; // slow infinite
		i = b / (float)radec_move_rate / a * 360.0 ;
   }

	// --- motion sense
	if (direction=='W') {
		motion_sense=(tel->latitude >= 0.0 )? 0 : 1;
	} else if (direction=='E') {
		motion_sense=(tel->latitude >= 0.0 )? 1 : 0;
	} else {
		if (tel->latitude >= 0.0 ) {
			if (direction=='N') {
				motion_sense = (tel->tube_current_side == TUBE_OUEST )? 0 : 1;
			} else {
				motion_sense = (tel->tube_current_side == TUBE_OUEST )? 1 : 0;
			}
		} else {
			if (direction=='N') {
				motion_sense = (tel->tube_current_side == TUBE_OUEST )? 1 : 0;
			} else {
				motion_sense = (tel->tube_current_side == TUBE_OUEST )? 0 : 1;
			}
		}
	}

	// --- Avant n'importe quel move E ou W il faut arreter les moteurs
	if ((direction=='W')||(direction=='E')) {
		eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
	}

	sprintf(s,":G%c%d%d",axe,motion_type,motion_sense);
   res=eqmod_putread(tel,s,NULL); 

   eqmod_encode(tel,(int)i,vc);
   sprintf(s,":I%c%s",axe,vc);
	res=eqmod_putread(tel,s,NULL); 

   sprintf(s,":J%c",axe);
   res=eqmod_putread(tel,s,NULL); 

   return 0;
}

//#define SIMU

int eqmod2_goto(struct telprop *tel)
{
   char s[1024],ss[1024],axe,HAsense,DECsense;
   int res, k, nbcalc;
   double ha,lst,sec,dec;
   int h,m;
   int HA0, DEC0;
   int HA, DEC;
   double ha0, dec0, dha, ddec;
	double slewing_delay_ha,slewing_delay_dec,slewing_delay;
	int flip; 
	double ha_raw, dec_raw;
   double deg_ha,deg_dec,adu_ha,adu_dec;

   // Etape1: savoir ou on est en HADEC
   eqmod_positions12(tel,&HA0,&DEC0);
	if (tel->problem_motor!=PROBLEM_MOTOR_NOTHING) {
		return -2;
	}
   eqmod_codeur2skypos(tel, HA0, DEC0, &ha0, NULL, &dec0,&flip,&ha_raw,&dec_raw);

	slewing_delay=0;
	if (tel->ha_pointing==0) {
		nbcalc=2; // pointage en RADEC
		if (tel->old_state == EQMOD_STATE_STOPPED ) {
			nbcalc=1; // pointage avec moteurs stopés à la fin
			slewing_delay=-1.+0.06; // arrondis de la seconde
		}
	} else {
		nbcalc=1; // pointage en HADEC
	}

	// Boucle de calcul en tenant compte du delay de pointage
	for (k=0;k<nbcalc;k++) {

		// Etape2: Calculer le pointage a effectuer
		if (tel->ha_pointing==0) {
			lst = eqmod_tsl(tel,&h,&m,&sec) + slewing_delay/86164*360.;  // ajout empirique de slewing_delay secondes pour tenir compte du temps mort de reponse de la monture
			ha = fmod( lst-tel->ra0+360*5 , 360.0 );
		} else {
			ha = fmod( tel->ha0+360*5 , 360.0 );
		}
		dec = tel->dec0;
		if ( ha > 180.0 ) ha -= 360.;
		deg_ha=ha;
		deg_dec=dec;

		// Etape3: evaluer le prochain cote du tube
		if ( tel->tube_prefered_side == TUBE_EST ) {
			if ( ha>= tel->coord_deg_ha_emin ) {
				tel->tube_next_side=TUBE_EST;
			} else {
				tel->tube_next_side=TUBE_OUEST;
			}
		} else {
			if ( ha<= tel->coord_deg_ha_wmax ) {
				tel->tube_next_side=TUBE_OUEST;
			} else {
				tel->tube_next_side=TUBE_EST;
			}
		}
		if (tel->latitude < 0.0 ) {
			if (tel->tube_next_side==TUBE_EST) {
				tel->tube_next_side=TUBE_OUEST;
			} else {
				tel->tube_next_side=TUBE_EST;
			}
		}

		// Etape4: calcul des ADU a pointer
		if (tel->latitude >= 0.0 ) {
			if (tel->tube_next_side == TUBE_OUEST) {
				adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			} else {
				adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			}
		} else {
			if (tel->tube_next_side == TUBE_OUEST) {
				adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			} else {
				adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
				adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
			}
		}

		// Etape4b : cas particulier du GOTO parking
		if (tel->flag_gotoparking==1) {
			adu_ha = tel->park_adu_ha;
			adu_dec = tel->park_adu_dec;
		}

		// Etape 5: calcul du trajet a parcourir (en ADU)
		dha = adu_ha - tel->coord_adu_ha;
		ddec = adu_dec - tel->coord_adu_dec;

		// Etape 6: calcul des securites (ADU)
		if ( adu_ha > tel->coord_adu_ha_max) {
			dha=0;
			ddec=0;
		}
		if ( adu_ha < tel->coord_adu_ha_min) {
			dha=0;
			ddec=0;
		}
		if ( adu_dec > tel->coord_adu_dec_max) {
			dha=0;
			ddec=0;
		}
		if ( adu_dec < tel->coord_adu_dec_min) {
			dha=0;
			ddec=0;
		}

		slewing_delay_ha  = tel->dead_delay_slew + fabs(dha/tel->adu4deg_ha /tel->speed_slew_ra );
		slewing_delay_dec = tel->dead_delay_slew + fabs(ddec/tel->adu4deg_dec /tel->speed_slew_dec);
		slewing_delay = (slewing_delay_ha>slewing_delay_dec) ? slewing_delay_ha : slewing_delay_dec ;
	}

   // Etape 6: Pointage de la monture
	tel->flag_gotoparking=0;

	HA=(int)fabs(dha);
	HAsense=(dha>=0)?'0':'1';
	DEC=(int)fabs(ddec);
	DECsense=(ddec>=0)?'0':'1';
   
   axe='1';
   sprintf(s,":G%c0%c",axe,HAsense); res=eqmod_putread(tel,s,NULL);
   eqmod_encode(tel,HA,ss);
   sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL);

   axe='2';
   sprintf(s,":G%c0%c",axe,DECsense); res=eqmod_putread(tel,s,NULL);
   eqmod_encode(tel,DEC,ss);
   sprintf(s,":H%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);
   sprintf(s,":J%c",axe); res=eqmod_putread(tel,s,NULL);

   return 0;
   
}

int eqmod2_waitgoto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
   int nbgoto=2;
   int p10,p1,p20,p2,dp1,dp2;
   double tol;
	long clk_tck = CLOCKS_PER_SEC;
   clock_t clock0,clock00;
	double dt1,dt2;
	FILE *f;

   if (tel->radec_goto_blocking==1) {
      // A loop is actived until the telescope is stopped
      eqmod_positions12(tel,&p10,&p20);
      tol=(tel->adu4deg_ha)/3600.*10; // tolerance +/- 10 arcsec
		clock00 = clock();
      while (1==1) {
         time_in++;
         sprintf(s,"after %d",tel->gotodead_ms); mytel_tcleval(tel,s);
         eqmod_positions12(tel,&p1,&p2);
			dp1=p1-p10;
			dp2=p2-p20;
		   if (tel->mouchard==1) {
				f=fopen("mouchard_eqmod.txt","at");
				fprintf(f,"DP A dp1=%d dp2=%d tol=%f\n",dp1,dp2,tol);
				fclose(f);
			}
			if ((fabs(dp1)<tol)&&(fabs(dp2)<tol)) {break;}
         p10=p1;
         p20=p2;
         if (time_in>=time_out) {break;}
      }
		dt1=(double)(clock()-clock00)/(double)clk_tck;
		clock0 = clock();
      if (nbgoto>1) {
         eqmod2_goto(tel);
         // A loop is actived until the telescope is stopped
         eqmod_positions12(tel,&p10,&p20);
         while (1==1) {
            time_in++;
            sprintf(s,"after %d",tel->gotoread_ms); mytel_tcleval(tel,s);
            eqmod_positions12(tel,&p1,&p2);
				dp1=p1-p10;
				dp2=p2-p20;
			   if (tel->mouchard==1) {
					f=fopen("mouchard_eqmod.txt","at");
					fprintf(f,"DP B dp1=%d dp2=%d tol=%f\n",dp1,dp2,tol);
					fclose(f);
				}
				if ((fabs(dp1)<tol)&&(fabs(dp2)<tol)) {break;}
            p10=p1;
            p20=p2;
            if (time_in>=time_out) {break;}
         }
         sprintf(s,"after %d",tel->gotoread_ms); mytel_tcleval(tel,s);
      }
		dt2=(double)(clock()-clock0)/(double)clk_tck;
		if (tel->mouchard==1) {
			f=fopen("mouchard_eqmod.txt","at");
			fprintf(f,"dt1=%f (%d) dt2=%f\n",dt1,nbgoto,dt2);
			fprintf(f,"\n");
			fclose(f);
		}
   }
   return 0;
}


int eqmod2_match(struct telprop *tel)
{
   char s[1024],ss[1024],axe;
   int res;
   double ha, lst, dec, deg_ha,deg_dec, adu_ha,adu_dec;
	int iha,idec;
   int p;

   if ( ( tel->state != EQMOD_STATE_STOPPED ) && ( tel->state != EQMOD_STATE_TRACK ) ) {
      return -1;
   }
	if (tel->problem_motor!=PROBLEM_MOTOR_NOTHING) {
		return -2;
	}

	eqmod_positions12(tel, &iha, &idec);

   // Calcul de l'angle horaire correspondant a la position de match
   // Meme si le tube est retourne, on travaille toujours entre -180° et +180°.
   // Remember: H=TSL-alpha
   lst = eqmod_tsl(tel,NULL,NULL,NULL);
   ha = fmod(lst-tel->ra0+360*5,360.);
   if ( ha > 180.0 ) {
      ha -= 360;
   }
   dec = tel->dec0;

	deg_ha=ha;
	deg_dec=dec;

	if (tel->latitude >= 0.0 ) {
		if (tel->tube_current_side == TUBE_OUEST) {
			adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		} else {
			adu_ha  = tel->coord_adu_ha0  + ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		}
	} else {
		if (tel->tube_current_side == TUBE_OUEST) {
			adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 - 180 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 - ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		} else {
			adu_ha  = tel->coord_adu_ha0  - ( deg_ha  - tel->coord_deg_ha0 ) * tel->adu4deg_ha ;
			adu_dec = tel->coord_adu_dec0 + ( deg_dec - tel->coord_deg_dec0) * tel->adu4deg_dec ;
		}
	}

	// --- on arrete le moteur
   if ( tel->state == EQMOD_STATE_TRACK ) {
      eqmod2_stopmotor(tel,AXE_RA | AXE_DEC);
   }

   // Encodage axe horaire
   axe='1';
   p = (int)(adu_ha); 
   eqmod_encode(tel,p,ss);
   sprintf(s,":E%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);

   // Encodage declinaison
   axe='2';
   p = (int)(adu_dec);
   eqmod_encode(tel,p,ss);
   sprintf(s,":E%c%s",axe,ss); res=eqmod_putread(tel,s,NULL);

   if ( tel->state == EQMOD_STATE_TRACK ) {
      eqmod2_track(tel);
   }

   return 0;
}


/*****************************************************************************/
/* Les fonctions eqmod2_action_* correspondent aux commandes tel radec *.    */
/* Elles authorisent ou non l'action correspondante sur les moteurs en       */
/* fonction de l'etat actuel des moteurs, symbolise par une machine a etats. */
/* Les fonctions peripheriques (match, etc) se servent de l'etat des moteurs */
/* pour decider de la faisabitilite ou non de l'action.                      */
/*****************************************************************************/

int eqmod2_action_move(struct telprop *tel, char *direction)
{
   switch ( tel->state ) {
      case EQMOD_STATE_NOT_INITIALIZED:
         return -1;
      case EQMOD_STATE_HALT:
         return -1;
      case EQMOD_STATE_GOTO:
         return -1;
      case EQMOD_STATE_STOPPED:
         tel->old_state = tel->state;
         eqmod2_move(tel,direction[0]);
         tel->state = EQMOD_STATE_SLEW;
         break;
      case EQMOD_STATE_TRACK:
         tel->old_state = tel->state;
         //eqmod2_stopmotor(tel,AXE_RA|AXE_DEC);
         eqmod2_move(tel,direction[0]);
         tel->state = EQMOD_STATE_SLEW;
         break;
      case EQMOD_STATE_SLEW:
         if ( ( tel->slew_axis & AXE_RA ) == axe(direction[0]) ) {
            // L'axe RA est en slew, et on demande une modif sur cet axe
            eqmod2_stopmotor(tel,AXE_RA);
         }
         if ( ( tel->slew_axis & AXE_DEC ) == axe(direction[0]) ) {
            // L'axe DEC est en slew, et on demande une modif sur cet axe
            eqmod2_stopmotor(tel,AXE_DEC);
         }
         eqmod2_move(tel,direction[0]);
         break;
   }

   tel->slew_axis = tel->slew_axis | axe(direction[0]);

   return 0;
}

int eqmod2_action_stop(struct telprop *tel, char *direction)
{
   char s[80],ss[80];
   switch ( tel->state ) {
      case EQMOD_STATE_NOT_INITIALIZED:
         return -1;
      case EQMOD_STATE_HALT:
         return -1;
      case EQMOD_STATE_GOTO:
         // Tester s'il n'y avait pas un goto asynchrone en route...
         return -1;
      case EQMOD_STATE_STOPPED:
         // Monture deja arretee
         return -2;
      case EQMOD_STATE_TRACK:
         // Pour arreter le moteur, il faut faire action_motor
         return -1;
      case EQMOD_STATE_SLEW:
			// on arrete le jog en cours
         eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
			// attente de la fin de deceleration
			do {
				sprintf(s,":f1"); 
				eqmod_putread(tel,s,ss); 
			} while (ss[1]=='1');
			do {
				sprintf(s,":f2"); 
				eqmod_putread(tel,s,ss); 
			} while (ss[1]=='1');
			// arret complet
         if ( tel->old_state == EQMOD_STATE_TRACK ) {
            // On vient de track, il faut re-enclencher le moteur
            eqmod2_track(tel);
            tel->old_state = tel->state;
            tel->state = EQMOD_STATE_TRACK;
         } else {
            tel->old_state = tel->state;
            tel->state = EQMOD_STATE_STOPPED;
         }
         break;
   }


   return 0;
}

int eqmod2_action_motor(struct telprop *tel)
{
	if (tel->radec_motor==0) {
      eqmod2_track(tel);
      tel->old_state = tel->state;
      tel->state = EQMOD_STATE_TRACK;
	} else {
      eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
      tel->old_state = tel->state;
      tel->state = EQMOD_STATE_STOPPED;
	}

   return 0;
}


int eqmod2_action_goto(struct telprop *tel)
{
   // On impose toujours un goto bloquant sinon le moteur 
	// ne fait pas le suivi apres pointage.
   // tel->radec_goto_blocking = 1;

	// --- Ne fait rien si le système n'est pas initialisé
	if ( tel->state == EQMOD_STATE_NOT_INITIALIZED ) {
		return -1;
	}
	// --- Ne fait rien si le système est éteind
	if ( tel->state == EQMOD_STATE_HALT ) {
		return -1;
	}
	// --- Ne fait rien si le système est déjà en train de pointer (Ne devrait jamais arriver)
	if ( tel->state == EQMOD_STATE_GOTO ) {
		return -1;
	}
	// --- Ne fait rien si le système est déjà en train de pointer
	if ( tel->state == EQMOD_STATE_SLEW ) {
		return -1;
	}
	// --- Ne fait rien si le système de codeur est aux valeurs minis
	if (tel->problem_motor!=PROBLEM_MOTOR_NOTHING) {
		return -1;
	}
	// --- Avant n'importe quel GOTO il faut arreter les moteurs
	eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
	// --- Traite les 4 cas de pointages
	if ( ( tel->state == EQMOD_STATE_STOPPED ) && ( tel->ha_pointing == 1 ) ) {
		// --- Cas où les moteurs sont déjà sur OFF et pointage HADEC
		tel->old_state = tel->state;
      tel->state = EQMOD_STATE_GOTO;
      eqmod2_goto(tel);
		if (tel->radec_goto_blocking == 1) {
			eqmod2_waitgoto(tel);
		}
      tel->old_state = tel->state;
      tel->state = EQMOD_STATE_STOPPED;
	} else if ( ( tel->state == EQMOD_STATE_STOPPED ) && ( tel->ha_pointing == 0 ) ) {
		// --- Cas où les moteurs sont déjà sur OFF et pointage RADEC
		if (tel->gotoblocking==1) {
			tel->radec_goto_blocking = 1; // option qui on force les goto RADEC en  bloquant
		}
		tel->old_state = tel->state;
      tel->state = EQMOD_STATE_GOTO;
      eqmod2_goto(tel);
		if (tel->radec_goto_blocking == 1) {
			eqmod2_waitgoto(tel);
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_TRACK;
			eqmod2_track(tel);
		} else {
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_STOPPED;
		}
	} else if ( ( tel->state == EQMOD_STATE_TRACK ) && ( tel->ha_pointing == 1 ) ) {
		// --- Cas où les moteurs sont déjà sur ON et pointage HADEC
		tel->old_state = tel->state;
		tel->state = EQMOD_STATE_STOPPED;
		eqmod2_stopmotor(tel, AXE_RA | AXE_DEC);
      tel->state = EQMOD_STATE_GOTO;
      eqmod2_goto(tel);
		if (tel->radec_goto_blocking == 1) {
			eqmod2_waitgoto(tel);
		}
		tel->old_state = tel->state;
      tel->state = EQMOD_STATE_STOPPED;
	} else if ( ( tel->state == EQMOD_STATE_TRACK ) && ( tel->ha_pointing == 0 ) ) {
		// --- Cas où les moteurs sont déjà sur ON et pointage RADEC
		if (tel->gotoblocking==1) {
			tel->radec_goto_blocking = 1; // option qui force les goto RADEC en  bloquant
		}
      tel->old_state = tel->state;
      tel->state = EQMOD_STATE_GOTO;
      eqmod2_goto(tel);
		if (tel->radec_goto_blocking == 1) {
			eqmod2_waitgoto(tel);
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_TRACK;
			eqmod2_track(tel);
		} else {
			tel->old_state = tel->state;
			tel->state = EQMOD_STATE_STOPPED;
		}
	}

   return 0;
}

