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
   {"ETEL",    /* telescope name */
    "Etel",    /* protocol name */
    "etel",    /* product */
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

// tel::create etel USB -driver USB -axis 2 -axis 1
// tel1 get_register_s 0 ML 7 
// tel1 radec goto [tel1 radec coord]
int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{
	char s[200], ss[200],err_msg[256];
	int k, kk, kkk, err;
	int startmotor = 0;
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	char value[256];
	char result[256];
   char ipstring[50],portstring[50];
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_tel->etel.txt","wt");
   fprintf(f,"Demarre une init\n");
	fclose(f);
#endif
	strcpy(tel->telname,"tre");
	strcpy(portstring,"1129");
	strcpy(ipstring,"localhost");
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		tel->etel.axis[k] = AXIS_STATE_CLOSED;
		tel->etel.drv[k] = NULL;
	}
	strcpy(tel->etel.etel_driver, "DSTEB3");
	if (argc >= 1) {
		kkk = 0;
		for (kk = 0; kk < argc - 1; kk++) {
			if (strcmp(argv[kk], "-driver") == 0) {
				strcpy(tel->etel.etel_driver, argv[kk + 1]);
			}
			if (strcmp(argv[kk], "-axis") == 0) {
				if (kkk<ETEL_NAXIS_MAXI) {
					tel->etel.axis[kkk] = AXIS_STATE_TO_BE_OPENED;
					tel->etel.axisno[kkk] = atoi(argv[kk + 1]);
					kkk++;
				}
			}
			if (strcmp(argv[kk], "-startmotor") == 0) {
				startmotor = 1;
			}
			if (strcmp(argv[kk], "-telname") == 0) {
				if ((kk + 1) <= (argc - 1)) {
					strcpy(tel->telname, argv[kk + 1]);
				}
			}
			if (strcmp(argv[kk], "-port") == 0) {
				if ((kk + 1) <= (argc - 1)) {
					strcpy(portstring, argv[kk + 1]);
					tel->port = atoi(portstring);
				}
			}
			if (strcmp(argv[kk], "-ip") == 0) {
				if ((kk + 1) <= (argc - 1)) {
					strcpy(ipstring, argv[kk + 1]);
				}
			}
		}
	}
	/* --- boucle de creation des axes ---*/
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		if (tel->etel.axis[k] != AXIS_STATE_TO_BE_OPENED) {
			continue;
		}
		tel->etel.drv[k] = NULL;
		/* create drive */
		if (err = dsa_create_drive(&tel->etel.drv[k])) {
			etel_error(tel, k, err);
			sprintf(s, "Error axis=%d dsa_create_drive %s", k, tel->etel.msg);
			strcpy(tel->msg,s);
			return TCL_ERROR;
		}
		sprintf(ss, "etb:%s:%d", tel->etel.etel_driver, tel->etel.axisno[k]);
		if (err = dsa_open_u(tel->etel.drv[k], ss)) {
			etel_error(tel,k, err);
			sprintf(s, "Error axis=%d dsa_open_u(%s) %s", tel->etel.axisno[k], ss, tel->etel.msg);
			strcpy(tel->msg,s);
			return TCL_ERROR;
		} 
		tel->etel.axis[k] = AXIS_STATE_OPENED;
	}
	/* initialisation des types de registres*/
	// int32
	k = 0;
	strcpy(tel->typs[k].type_symbol, "X");
	tel->typs[k].typ = DMD_TYP_USER_INT32;
	tel->typs[k].ctype = ETEL_VAL_INT32;
	k++;
	strcpy(tel->typs[k].type_symbol, "K");
	tel->typs[k].typ = DMD_TYP_PPK_INT32;
	tel->typs[k].ctype = ETEL_VAL_INT32;
	k++;
	strcpy(tel->typs[k].type_symbol, "M");
	tel->typs[k].typ = DMD_TYP_MONITOR_INT32;
	tel->typs[k].ctype = ETEL_VAL_INT32;
	k++;
	strcpy(tel->typs[k].type_symbol, "C");
	tel->typs[k].typ = DMD_TYP_COMMON_INT32;
	tel->typs[k].ctype = ETEL_VAL_INT32;
	k++;
	strcpy(tel->typs[k].type_symbol, "P");
	tel->typs[k].typ = DMD_TYP_MAPPING_INT32;
	tel->typs[k].ctype = ETEL_VAL_INT32;
	// Long
	k++;
	strcpy(tel->typs[k].type_symbol, "XL");
	tel->typs[k].typ = DMD_TYP_USER_INT64;
	tel->typs[k].ctype = ETEL_VAL_INT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "KL");
	tel->typs[k].typ = DMD_TYP_PPK_INT64;
	tel->typs[k].ctype = ETEL_VAL_INT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "ML");
	tel->typs[k].typ = DMD_TYP_MONITOR_INT64;
	tel->typs[k].ctype = ETEL_VAL_INT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "CL");
	tel->typs[k].typ = DMD_TYP_COMMON_INT64;
	tel->typs[k].ctype = ETEL_VAL_INT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "EL");
	tel->typs[k].typ = DMD_TYP_TRIGGER_INT64;
	tel->typs[k].ctype = ETEL_VAL_INT64;
	// Float
	k++;
	strcpy(tel->typs[k].type_symbol, "XF");
	tel->typs[k].typ = DMD_TYP_USER_FLOAT32;
	tel->typs[k].ctype = ETEL_VAL_FLOAT32;
	k++;
	strcpy(tel->typs[k].type_symbol, "KF");
	tel->typs[k].typ = DMD_TYP_PPK_FLOAT32;
	tel->typs[k].ctype = ETEL_VAL_FLOAT32;
	k++;
	strcpy(tel->typs[k].type_symbol, "MF");
	tel->typs[k].typ = DMD_TYP_MONITOR_FLOAT32;
	tel->typs[k].ctype = ETEL_VAL_FLOAT32;
	k++;
	strcpy(tel->typs[k].type_symbol, "CF");
	tel->typs[k].typ = DMD_TYP_COMMON_FLOAT32;
	tel->typs[k].ctype = ETEL_VAL_FLOAT32;
	// Double
	k++;
	strcpy(tel->typs[k].type_symbol, "XD");
	tel->typs[k].typ = DMD_TYP_USER_FLOAT64;
	tel->typs[k].ctype = ETEL_VAL_FLOAT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "KD");
	tel->typs[k].typ = DMD_TYP_USER_FLOAT64;
	tel->typs[k].ctype = ETEL_VAL_FLOAT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "MD");
	tel->typs[k].typ = DMD_TYP_USER_FLOAT64;
	tel->typs[k].ctype = ETEL_VAL_FLOAT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "CD");
	tel->typs[k].typ = DMD_TYP_COMMON_FLOAT64;
	tel->typs[k].ctype = ETEL_VAL_FLOAT64;
	k++;
	strcpy(tel->typs[k].type_symbol, "LD");
	tel->typs[k].typ = DMD_TYP_LKT_FLOAT64;
	tel->typs[k].ctype = ETEL_VAL_FLOAT64;
	// --- Home ---
	if (strcmp(tel->telname,"tre")==0) {
		// --- site
		tel->latitude = -21.199569;
		sprintf(tel->home0, "GPS 55.41 E %+.6f 992.0", tel->latitude);
		if (tel->latitude>=0) {
			tel->signlat=1;
		} else {
			tel->signlat=-1;
		}
		// --- general axis parameters
		// --- Mount type
		strcpy(tel->MecTyp,"hadec");
		// --- Polar axis
		tel->MecPolAduMot = tel->signlat*-536870912/2 ; //inc/tour_moteur
		tel->MecPolAduDeg = tel->signlat*-10939341.35524/2 ; //inc/deg
		//tel->MecPolVel = tel->signlat*-311.16349/2 ; // inc / arcsec / sec  TRE
		//tel->MecPolAcc = 10000000 ; // inc / arcsec / sec2  TRE
		tel->MecPolRed =  tel->MecPolAduDeg*360 /  tel->MecPolAduMot;
		tel->MecPolLimSup = 2335388467; // 6285428384;
		tel->MecPolLimInf = 0;
		tel->MecPolAdu0 = 1899319776.0000000;
		tel->MecPolAng0 = -116.46685613400000;//déclinaison -90 mecanique de la monture
		tel->MecPolSide = SIDE_REGULAR;
		tel->MecPolAduMotVel = 54975581/2 ;  // inc / (tour_moteur/s)
		tel->MecPolAduMotAcc = 5629500/2 ;  // inc / (tour_moteur/s2)
		// --- Basis axis
		tel->MecBasAduMot = tel->signlat*536870912/2 ; //inc/tour_moteur
		tel->MecBasAduDeg = tel->signlat*10949183.98862/2 ; //inc/deg
		//tel->MecBasVel = tel->signlat*-311.44345 ; // inc / arcsec / sec  TRE
		//tel->MecBasAcc = 10000000; // inc / arcsec / sec2  TRE
		tel->MecBasRed =  tel->MecBasAduDeg*360 /  tel->MecBasAduMot;
		tel->MecBasLimSup = 2979633563; // 6285428384;
		tel->MecBasLimInf = 751619277; // 1074890400;
		tel->MecBasAdu0 = 3733437856.0000000/2 ;
		tel->MecBasAng0 = 7.0102766336667628;
		tel->MecBasAngLimRis = -180 ; // Valeur limite au levant (est) de l'angle de base pour le retournement
		tel->MecBasAngLimSet = 180 ; //Valeur limite au couchant (ouest) de l'angle de base pour le retournement On a toujours MecBasLimRis < MecBasLimSet.
		tel->MecBasAduMotVel = 54975581/2 ;  // inc / (tour_moteur/s)
		tel->MecBasAduMotAcc = 5629500/2 ;  // inc / (tour_moteur/s2)
		// ---
		tel->acceleration_slew_ra   = 50.;  // (deg/s2)
		tel->acceleration_slew_dec  = 50.;  // (deg/s2)
		tel->speed_slew_ra          = 200; // (deg/s)
		tel->speed_slew_dec         = 200; // (deg/s)
		tel->acceleration_track_ra  = 90.;  // (deg/s2) 87
		tel->acceleration_track_dec = 90.;  // (deg/s2) 174
		tel->move_pulse             = 0; // 0=continue 1=pulse
		tel->slew_hiprecision       = 1; // 0=1slew 1=double_slew
		tel->dead_delay_slew       = 0.17; // (sec)
		tel->refrac_div            = 1;
		tel->refrac_delay          = 0;
	} else if (strcmp(tel->telname,"t60makes")==0) {
		// --- site
		tel->latitude = -21.199569;
		sprintf(tel->home0, "GPS 55.41 E %+.6f 992.0", tel->latitude);
		if (tel->latitude>=0) {
			tel->signlat=1;
		} else {
			tel->signlat=-1;
		}
		// --- general axis parameters
		// --- Mount type
		strcpy(tel->MecTyp,"hadec");
		// --- Polar axis (declinaison)
		tel->MecPolAduMot = tel->signlat*4294967296.0; //inc/tour_moteur
		tel->MecPolAduDeg = tel->signlat*5249404473.0; //inc/deg
		//tel->MecPolVel = tel->signlat*149316.39386 ; // inc / arcsec / sec  T60
		//tel->MecPolAcc = 100000000.0; // inc / arcsec / sec2  T60
		tel->MecPolRed =  tel->MecPolAduDeg*360 /  tel->MecPolAduMot;
		tel->MecPolLimSup = 816043786240;//816043786240
		tel->MecPolLimInf = 773094113280.0000;
		tel->MecPolAdu0 = 1634235056128.0000000;//inc pour l'angle MecPolAng0
		tel->MecPolAng0 = -180.0000;// angle polaire de reference (=dec-90)
		tel->MecPolSide = SIDE_REGULAR;
		tel->MecPolAduMotVel = 439804651 ;  // inc / (tour_moteur/s)
		tel->MecPolAduMotAcc = 45035996 ;  // inc / (tour_moteur/s2)
		// --- Basis axis (horaire)
		tel->MecBasAduMot = tel->signlat*8589934592.0 ; //inc/tour_moteur
		tel->MecBasAduDeg = tel->signlat*432001663.0365; //inc/deg ex430499580.25688 ex 431244279.86414 ex431044279.86414 ex430944279.86414 ex431244279.86414 ex431960107.74681 ex  431818660.50301 ex431097797.96423 ex431405603.95378 ex431477186.74205 ex431644213.24800         
		//tel->MecBasVel = tel->signlat*-12277.87984; // inc / arcsec / sec  T60 ex 12258.456997 ex12266.50396 ex12273.29107ex12280.07818 ex 12286.86528 ex 12293.65239 ex12286.86528  ex12282.84190 ex12262.33736 ex12271.09273 ex 12273.12886 
		//tel->MecBasAcc = 100000000.0; // inc / arcsec / sec2  T60
		tel->MecBasRed =  tel->MecBasAduDeg*360 /  tel->MecBasAduMot;
		tel->MecBasLimSup = 167503724544;
		tel->MecBasLimInf = 94489280512;
		tel->MecBasAdu0 = 131855518320.0000000 ;//inc pour l'angle MecBasAng0      
		tel->MecBasAng0 = 0.0000000000;// angle horaire de reference  (=ha)
		tel->MecBasAngLimRis = -180 ; // Valeur limite au levant (est) de l'angle de base pour le retournement
		tel->MecBasAngLimSet = 180 ; //Valeur limite au couchant (ouest) de l'angle de base pour le retournement On a toujours MecBasLimRis < MecBasLimSet.
		tel->MecBasAduMotVel = 879609302 ;  // inc / (tour_moteur/s)
		tel->MecBasAduMotAcc = 900719930 ;  // inc / (tour_moteur/s2)
		// ---
		tel->acceleration_slew_ra   = 1.;  // (deg/s2) 1.
		tel->acceleration_slew_dec  = 0.8;  // (deg/s2) 0.8
		tel->speed_slew_ra          = 10; // (deg/s) 4
		tel->speed_slew_dec         = 3.8; // (deg/s) 3.8
		tel->acceleration_track_ra  = 22.;  // (deg/s2) 22
		tel->acceleration_track_dec = 5.0;  // (deg/s2) 1.8
		tel->move_pulse             = 0; // 0=continue 1=pulse
		tel->slew_hiprecision       = 1; // 0=1slew 1=double_slew
		tel->dead_delay_slew        = 0.17; // (sec)
		tel->refrac_div             = 1;
		tel->refrac_delay          = 0;
	}
	// --- inits
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
			//nparams=0;
			//err = etel_ExecuteCommandXS(tel,k,79,params,nparams,value);
			nparams=0;
			params[nparams].conv=0;
			params[nparams].typ=0;
			params[nparams].vald=79;
			nparams++;
			err = etel_ExecuteCommandXS(tel,k,26,params,nparams,value);
		}
	}
	// --- limits
	etel_get_limits(tel,result);
	// --- defaults
   tel->track_diurnal         = 360.0/86164.; // 0.00417807901212 (deg/s)
   tel->speed_track_ra        = tel->track_diurnal; // (deg/s)
   tel->speed_track_dec       = 0.;  // (deg/s)
	// --- start motor or not
	tel->radec_motor=0;
	tel->ontrack=0;
	if (startmotor==1) {
      etel_suivi_marche(tel,err_msg);
	}
	return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
    /* Is the drive pointer valid ? */
    if(dsa_is_valid_drive(tel->etel.drv[0])) {
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
	char s[200];
	int k, err;
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	char value[256];
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
			nparams=0;
			params[nparams].conv=0;
			params[nparams].typ=0;
			params[nparams].vald=0;
			nparams++;
			err = etel_ExecuteCommandXS(tel,k,124,params,nparams,value);
		}
	}
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
			/* power off */
			if (err = dsa_power_off_s(tel->etel.drv[k], 10000)) {
				etel_error(tel, k, err);
				sprintf(s, "Error axis=%d dsa_power_off_s %s", k, tel->etel.msg);
				Tcl_SetResult(tel->interp, s, TCL_VOLATILE);
				return TCL_ERROR;
			}
			/* close and destroy */
			if (err = dsa_close(tel->etel.drv[k])) {
				etel_error(tel, k, err);
				sprintf(s, "Error axis=%d dsa_close %s", k, tel->etel.msg);
				Tcl_SetResult(tel->interp, s, TCL_VOLATILE);
				return TCL_ERROR;
			}
			if (err = dsa_destroy(&tel->etel.drv[k])) {
				etel_error(tel, k, err);
				sprintf(s, "Error axis=%d dsa_destroy %s", k, tel->etel.msg);
				Tcl_SetResult(tel->interp, s, TCL_VOLATILE);
				return TCL_ERROR;
			}
			tel->etel.axis[k] = AXIS_STATE_CLOSED;
		}
	}
	Tcl_SetResult(tel->interp, "", TCL_VOLATILE);
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

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {
      return 1;
   }
   return 0;
}

int mytel_radec_init(struct telprop *tel)
/* it corresponds to the "match" function of an LX200 */
{
	char err_msg[256];
	double ang0,ang1,ang2;
	int h,m;
	double sec,lst,ha;
   lst=etel_tsl(tel,&h,&m,&sec);
   ha=lst-tel->ra0+360*5;
	ha=fmod(ha,360);
	if (ha>180) {
		ha-=360;
	}
	ang0 = ha;
	ang1 = tel->dec0;
	ang2 = 0;
	etel_init_coord(tel,err_msg,ang0,ang1,ang2); 
	return 0;
}

int mytel_hadec_init(struct telprop *tel)
{
	char err_msg[256];
	double ang0,ang1,ang2;
	double ha;
	ha=fmod(tel->ra0+5*360,360);
	if (ha>180) {
		ha-=360;
	}
	ang0 = ha;
	ang1 = tel->dec0;
	ang2 = 0;
	etel_init_coord(tel,err_msg,ang0,ang1,ang2); 
	return 0;
}

int mytel_radec_state(struct telprop *tel, char *result)
{
	return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
	int err=0;
	char err_msg[256];
	char value[256];
	double ang0,ang1,ang2;
	double MecBasAdu, MecPolAdu, MecRotAdu;
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	int h,m,kgoto,ngoto;
	double sec,lst,ha;
	if (tel->slew_hiprecision==0) {
		ngoto=1;
	} else {
		ngoto=2;
	}
	for (kgoto=1 ; kgoto<=ngoto ; kgoto++) { 
		double app_drift_HA, app_drift_DEC;
		lst=etel_tsl(tel,&h,&m,&sec);
		ha=lst-tel->ra0+360*5;
		ang0 = ha;
		ang1 = tel->dec0;
		ang2 = 0;
		etel_set_coord(tel,err_msg,ang0,ang1,ang2,&MecBasAdu,&MecPolAdu,&MecRotAdu);
		if (strcmp(err_msg,"")==0) {
			double Amax_HA, Amax_DEC, Vmax_HA, Vmax_DEC;
			// --- set drift speed after pointing
			app_drift_HA  = tel->speed_track_ra ; // deg/sec
			app_drift_DEC = tel->speed_track_dec ; // deg/sec
			set_drift_speed(tel,err_msg,app_drift_HA,app_drift_DEC);
			// --- set accelerations
			Amax_HA  = tel->acceleration_slew_ra ; // deg/s2
			Amax_DEC = tel->acceleration_slew_dec ; // deg/s2
			set_slew_acceleration(tel,err_msg,Amax_HA,Amax_DEC);
			// --- set velocities
			Vmax_HA  = tel->speed_slew_ra ; // deg/s
			Vmax_DEC = tel->speed_slew_dec  ; // deg/s
			set_slew_velocity(tel,err_msg,Vmax_HA,Vmax_DEC);
			// --- set positions
			sprintf(value,"%.0lf",MecBasAdu);
			err = etel_SetRegisterS(tel,0,"XL",4,0,value);
			sprintf(value,"%.0lf",MecPolAdu);
			err = etel_SetRegisterS(tel,1,"XL",4,0,value);
			// --- start slew
			// etel_execute_command_x_s 0 26 1 0 0 7
			nparams=0;
			params[nparams].conv=0;
			params[nparams].typ=0;
			if (app_drift_HA==0) {
				params[nparams].vald=11;
			} else {
				params[nparams].vald=7;
			}
			nparams++;
			err = etel_ExecuteCommandXS(tel,0,26,params,nparams,value);
			if (app_drift_DEC==0) {
				params[nparams-1].vald=11;
			} else {
				params[nparams-1].vald=7;
			}
			
			err = etel_ExecuteCommandXS(tel,1,26,params,nparams,value);
		}

		if ( (kgoto<ngoto) || (tel->radec_goto_blocking==1)) {
			int time_in=0,time_out=600; // units of 1/10s
			long clk_tck = CLOCKS_PER_SEC;
			double suivi0=0,suivi1=0,poin0=1,poin1=1;
			char s[256];
			char result[256];
			int endslew=0;
			time_in=0;
			while (1==1) {
				time_in++;
				sprintf(s,"after 100"); mytel_tcleval(tel,s);
				if (time_in>=time_out) {break;}
				err = etel_GetRegisterS(tel,0,"X",51,0,result);
				if (err==0) { suivi0 = atof(result); }
				err = etel_GetRegisterS(tel,1,"X",51,0,result);
				if (err==0) { suivi1 = atof(result); }
				err = etel_GetRegisterS(tel,0,"X",50,0,result);
				if (err==0) { poin0 = atof(result); }
				err = etel_GetRegisterS(tel,1,"X",50,0,result);
				if (err==0) { poin1 = atof(result); }
				endslew=0;
				if (app_drift_HA==0) {
					if (poin0==0) {
						endslew+=1;
					}
				} else {
					if ((poin0==0)&&(suivi0==1)) {
						endslew+=1;
					}
				}
				if (app_drift_DEC==0) {
					if (poin1==0) {
						endslew+=2;
					}
				} else {
					if ((poin1==0)&&(suivi1==1)) {
						endslew+=2;
					}
				}
				if (endslew==3) {
					/* start the motor */
					etel_suivi_marche(tel,err_msg);
					break;
				}
			}
		}
	}
	tel->radec_motor=1; // demarrage des moteurs dans le controleur automatiquement
	tel->ontrack = 1;
	return(err);
}

int mytel_hadec_goto(struct telprop *tel)
{
	int err=0;
	char err_msg[256];
	char value[256];
	double ang0,ang1,ang2;
	double MecBasAdu, MecPolAdu, MecRotAdu;
	double app_drift_HA, app_drift_DEC;
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	ang0 = tel->ra0;
	ang1 = tel->dec0;
	ang2 = 0;
	etel_set_coord(tel,err_msg,ang0,ang1,ang2,&MecBasAdu,&MecPolAdu,&MecRotAdu);
	etel_set_coord(tel,err_msg,ang0,ang1,ang2,&MecBasAdu,&MecPolAdu,&MecRotAdu);
	if (strcmp(err_msg,"")==0) {
		double Amax_HA, Amax_DEC, Vmax_HA, Vmax_DEC;
		// --- set drift speed after pointing
		app_drift_HA  = 0; // deg/sec
		app_drift_DEC = 0; // deg/sec
		set_drift_speed(tel,err_msg,app_drift_HA,app_drift_DEC);
		// --- set accelerations
		Amax_HA  = tel->acceleration_slew_ra ; // deg/s2
		Amax_DEC = tel->acceleration_slew_dec ; // deg/s2
		set_slew_acceleration(tel,err_msg,Amax_HA,Amax_DEC);
		// --- set velocities
		Vmax_HA  = tel->speed_slew_ra ; // deg/s
		Vmax_DEC = tel->speed_slew_dec  ; // deg/s
		set_slew_velocity(tel,err_msg,Vmax_HA,Vmax_DEC);
		// --- set positions
		sprintf(value,"%.0lf",MecBasAdu);
		err = etel_SetRegisterS(tel,0,"XL",4,0,value);
		sprintf(value,"%.0lf",MecPolAdu);
		err = etel_SetRegisterS(tel,1,"XL",4,0,value);
		// --- start slew
		// etel_execute_command_x_s 0 26 1 0 0 7
		nparams=0;
		params[nparams].conv=0;
		params[nparams].typ=0;
		if (app_drift_HA==0) {
			params[nparams].vald=11;
		} else {
			params[nparams].vald=7;
		}
		nparams++;
		err = etel_ExecuteCommandXS(tel,0,26,params,nparams,value);
		if (app_drift_DEC==0) {
			params[nparams-1].vald=11;
		} else {
			params[nparams-1].vald=7;
		}
		err = etel_ExecuteCommandXS(tel,1,26,params,nparams,value);
	}
   if (tel->radec_goto_blocking==1) {
		int time_in=0,time_out=600; // units of 1/10s
		long clk_tck = CLOCKS_PER_SEC;
		double suivi0=0,suivi1=0,poin0=1,poin1=1;
		char s[256];
		char result[256];
		int endslew=0;
		time_in=0;
		while (1==1) {
			time_in++;
			sprintf(s,"after 100"); mytel_tcleval(tel,s);
			if (time_in>=time_out) {break;}
			err = etel_GetRegisterS(tel,0,"X",51,0,result);
			if (err==0) { suivi0 = atof(result); }
			err = etel_GetRegisterS(tel,1,"X",51,0,result);
			if (err==0) { suivi1 = atof(result); }
			err = etel_GetRegisterS(tel,0,"X",50,0,result);
			if (err==0) { poin0 = atof(result); }
			err = etel_GetRegisterS(tel,1,"X",50,0,result);
			if (err==0) { poin1 = atof(result); }
			endslew=0;
			if (app_drift_HA==0) {
				if (poin0==0) {
					endslew+=1;
				}
			} else {
				if ((poin0==0)&&(suivi0==1)) {
					endslew+=1;
				}
			}
			if (app_drift_DEC==0) {
				if (poin1==0) {
					endslew+=2;
				}
			} else {
				if ((poin1==0)&&(suivi1==1)) {
					endslew+=2;
				}
			}
			if (endslew==3) {
				tel->radec_motor=0;
				tel->ontrack = 0;
				break;
			}
		}
	}
	tel->radec_motor=0; 
	tel->ontrack = 0;
	return(err);
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
	char err_msg[256];
	double speed_track_ra0, speed_track_dec0;
	double r,d,r1,r2,d1,d2;
	double dha=0, ddec=0;
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	char value[256];
	int err;
	double app_drift_HA,app_drift_DEC;
   char s[1024],direc[10];
   int duration_ms;
	// --- check the speed of the move
   if (tel->radec_move_rate>1.0) {
      tel->radec_move_rate=1;
   } else if (tel->radec_move_rate<0.) {
      tel->radec_move_rate=0.;
   }
	duration_ms=1000;
	// --- determine the sense of the move
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
	// --- store the current speed track
	if (tel->ontrack==1) {
		speed_track_ra0 = tel->speed_track_ra ; // deg/sec
		speed_track_dec0 = tel->speed_track_dec ; // deg/sec
	} else {
		speed_track_ra0 = 0 ; // deg/sec
		speed_track_dec0 = 0 ; // deg/sec
	}
	// --- set the track speed for moving
	// rate = [0;0.25]   ]0.25;0.5]        ]0.5;0.75] ]0.75;1.00]
	// degs = [0 5/3600] ]5/3600;60/3600] ]60/3600;0.25] ]0.25:2]
	r = tel->radec_move_rate;
	if (strcmp(tel->telname,"tre")==0) {
		if (tel->radec_move_rate<=0.25) {
			r1=0; r2=0.25;
			d1=0; d2=5/3600.;
		} else if (tel->radec_move_rate<=0.5) {
			r1=0.25; r2=0.5;
			d1=5/3600.; d2=1./60.;
		} else if (tel->radec_move_rate<=0.75) {
			r1=0.5; r2=0.75;
			d1=1./60.; d2=15./60;
		} else {
			r1=0.75; r2=1.0;
			d1=15./60; d2=120./60;
		}
	} else {
		if (tel->radec_move_rate<=0.25) {
			r1=0; r2=0.25;
			d1=0; d2=5/3600.;
		} else if (tel->radec_move_rate<=0.5) {
			r1=0.25; r2=0.5;
			d1=5/3600.; d2=1./60.;
		} else if (tel->radec_move_rate<=0.75) {
			r1=0.5; r2=0.75;
			d1=1./60.; d2=2./60;
		} else {
			r1=0.75; r2=1.0;
			d1=2./60; d2=15./60;
		}
	}
	d = (r-r1)/(r2-r1)*(d2-d1)+d1;
   if (strcmp(direc,"N")==0) {
		dha = 0 ; ddec = -d ;
   } else if (strcmp(direc,"S")==0) {
		dha = 0 ; ddec = d ;
   } else if (strcmp(direc,"E")==0) {
		dha = -d ; ddec = 0 ;
   } else if (strcmp(direc,"W")==0) {
		dha = d ; ddec = 0 ;
	}
	app_drift_HA = speed_track_ra0 + dha ; // deg/sec
	app_drift_DEC = speed_track_dec0 + ddec ; // deg/sec
	set_drift_speed(tel,err_msg,app_drift_HA,app_drift_DEC);
	// --- start drift
	nparams=0;
	params[nparams].conv=0;
	params[nparams].typ=0;
	params[nparams].vald=10;
	nparams++;
	err = etel_ExecuteCommandXS(tel,0,26,params,nparams,value);
	err = etel_ExecuteCommandXS(tel,1,26,params,nparams,value);
	if (tel->move_pulse==1) {
		// --- wait
		libtel_sleep(duration_ms);
		// --- stop the moving and come back to the current track
		if (tel->radec_motor==0) {
			/* stop the motor */
			etel_suivi_arret(tel,err_msg);
		} else {
			/* start the motor */
			etel_suivi_marche(tel,err_msg);
		}
	}
   return 0;
}

int mytel_radec_stop(struct telprop *tel, char *direction)
{
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	char value[256];
	int k, err;
   char s[1024],direc[10];
	char err_msg[256];
	// --- determine the sense of the move
   sprintf(s,"lindex [string toupper \"%s\"] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
   if ((strcmp(direc,"N")==0)||(strcmp(direc,"W")==0)||(strcmp(direc,"E")==0)||(strcmp(direc,"S")==0)) {
		// This is a move stop
		if (tel->radec_motor==1) {
			/* start the motor */
			etel_suivi_marche(tel,err_msg);
		} else {
			for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
				if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
					nparams=0;
					err = etel_ExecuteCommandXS(tel,k,70,params,nparams,value);
				}
			}
			tel->radec_motor=0;
			tel->ontrack=0;
		}
	} else {
		// This is an all axes stop
		for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
			if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
				nparams=0;
				err = etel_ExecuteCommandXS(tel,k,70,params,nparams,value);
			}
		}
		tel->radec_motor=0;
		tel->ontrack=0;
	}
	return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
	char err_msg[256];
   if (tel->radec_motor==1) {
      /* stop the motor */
      etel_suivi_arret(tel,err_msg);
   } else {
      /* start the motor */
      etel_suivi_marche(tel,err_msg);
   }
   return 0;
}

int mytel_radec_coord(struct telprop *tel, char *result)
{
	int err=0;
	char err_msg[256];
	double ang0,ang1,ang2;
	int h,m;
	double lst,ra,sec;
	etel_get_coord(tel,err_msg,&ang0,&ang1,&ang2);
   lst=etel_tsl(tel,&h,&m,&sec);
	ra = lst - ang0 + 360*5;
	if (strcmp(err_msg,"")==0) {
		sprintf(result,"%f %f",ra,ang1);
	}
	return(err);
}

int mytel_focus_init(struct telprop *tel)
{
	return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
	return 0;
}

int mytel_focus_move(struct telprop *tel, char *direction)
{
	return 0;
}

int mytel_focus_stop(struct telprop *tel, char *direction)
{
	return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
	return 0;
}

int mytel_focus_coord(struct telprop *tel, char *result)
{
	return 0;
}

int mytel_date_get(struct telprop *tel, char *ligne)
{
	etel_GetCurrentUTCDate(tel->interp, ligne);
	return 0;
}

int mytel_date_set(struct telprop *tel, int y, int m, int d, int h, int min, double s)
{
	return 0;
}

int mytel_home_get(struct telprop *tel, char *ligne)
{
	strcpy(ligne, tel->home0);
	return 0;
}

int mytel_home_set(struct telprop *tel, double longitude, char *ew, double latitude, double altitude)
{
	longitude = (double)fabs(longitude);
	if (longitude>360.) { longitude = 0.; }
	if ((ew[0] != 'w') && (ew[0] != 'W') && (ew[0] != 'e') && (ew[0] != 'E')) {
		ew[0] = 'E';
	}
	if (latitude>90.) { latitude = 90.; }
	if (latitude<-90.) { latitude = -90.; }
	sprintf(tel->home0, "GPS %f %c %f %f", longitude, ew[0], latitude, altitude);
	tel->latitude = latitude;
	return 0;
}

int mytel_hadec_coord(struct telprop *tel, char *result)
{
	int err=0;
	char err_msg[256];
	double ang0,ang1,ang2;
	etel_get_coord(tel,err_msg,&ang0,&ang1,&ang2);
	if (strcmp(err_msg,"")==0) {
		sprintf(result,"%f %f",ang0,ang1);
	}
	return(err);
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

//#define MOUCHARD_EVAL

void mytel_error(struct telprop *tel,int axisno, int err)
{
   DSA_DRIVE *drv;
   drv=tel->etel.drv[axisno];
   sprintf(tel->msg,"error %d: %s.\n", err, dsa_translate_error(err));
}

/* ================================================================ */
/* ================================================================ */
/* ===                 Langage ETEL                             === */
/* ================================================================ */
/* ================================================================ */
/*                                                                  */
/* ================================================================ */

void set_drift_speed(struct telprop *tel, char *err_msg, double app_drift_HA, double app_drift_DEC)
{
	double v1,v2, app_via, app_vih, dirad, dirdec;
	char value[256];
	int err;
	//app_drift_HA ; // deg/sec
	//app_drift_DEC ; // deg/sec
	/*
	v1 = tel->MecBasVel;
	v2 = tel->MecPolVel;
	//v1 = tel->signlat*-311.44345 ; // inc / arcsec / sec   TRE
	//v2 = tel->signlat*-311.16349/2 ; // inc / arcsec / sec  TRE
	//v1 = tel->signlat*-12277.87984 ; // inc / arcsec / sec  T60
	//v2 = tel->signlat*-149316,39386 ; // inc / arcsec / sec  T60
	app_via = app_drift_HA*3600*v1;
	app_vih = app_drift_DEC*3600*v2;
	*/
	app_via = app_drift_HA /360*tel->MecBasRed*tel->MecBasAduMotVel;
	app_vih = app_drift_DEC/360*tel->MecPolRed*tel->MecPolAduMotVel;
	sprintf(value,"%.0lf",fabs(app_via));
	err = etel_SetRegisterS(tel,0,"X",11,0,value);
	sprintf(value,"%.0lf",fabs(app_vih));
	err = etel_SetRegisterS(tel,1,"X",11,0,value);
	// --- acceleration
	/*
	v1 = tel->MecBasAcc;
	v2 = tel->MecPolAcc;
	//v1 = 10000000;
	//v2 = v1;
	*/
	v1 = tel->acceleration_track_ra /360*tel->MecBasRed*tel->MecBasAduMotAcc;
	v2 = tel->acceleration_track_dec/360*tel->MecPolRed*tel->MecPolAduMotAcc;
	sprintf(value,"%.0lf",fabs(v1));
	err = etel_SetRegisterS(tel,0,"X",12,0,value);
	sprintf(value,"%.0lf",fabs(v2));
	err = etel_SetRegisterS(tel,1,"X",12,0,value);
	/*
	// --- deceleration
	v1 = tel->MecBasAcc;
	v2 = tel->MecPolAcc;
	//v1 = 10000000;
	//v2 = v1;
	sprintf(value,"%.0lf",fabs(v1));
	err = etel_SetRegisterS(tel,0,"X",13,0,value);
	sprintf(value,"%.0lf",fabs(v2));
	err = etel_SetRegisterS(tel,1,"X",13,0,value);
	*/
	// ---
	if (app_via<0) {
		dirad = tel->MecBasLimSup;
	} else {
		dirad = tel->MecBasLimInf;
	}
	sprintf(value,"%.0lf",dirad);
	err = etel_SetRegisterS(tel,0,"XL",2,0,value);
	if (app_vih<0) {
		dirdec = tel->MecPolLimInf;
	} else {
		dirdec = tel->MecPolLimSup;
	}
	sprintf(value,"%.0lf",dirdec);
	err = etel_SetRegisterS(tel,1,"XL",2,0,value);
}

void set_slew_acceleration(struct telprop *tel, char *err_msg, double Amax_HA, double Amax_DEC)
{
	double aadu;
	char value[256];
	int err;
	//Amax_HA ; // deg/sec2
	//Amax_DEC; // deg/sec2
	aadu = Amax_HA/360*tel->MecBasRed*tel->MecBasAduMotAcc;
	sprintf(value,"%.0lf",aadu);
	err = etel_SetRegisterS(tel,0,"X",2,0,value);
	aadu = Amax_DEC/360*tel->MecPolRed*tel->MecPolAduMotAcc;
	sprintf(value,"%.0lf",aadu);
	err = etel_SetRegisterS(tel,1,"X",2,0,value);
}

void set_slew_velocity(struct telprop *tel, char *err_msg, double Vmax_HA, double Vmax_DEC)
{
	double vadu;
	char value[256];
	int err;
	//Vmax_HA ; // deg/sec
	//Vmax_DEC; // deg/sec
	vadu = Vmax_HA/360*tel->MecBasRed*tel->MecBasAduMotVel;
	sprintf(value,"%.0lf",vadu);
	err = etel_SetRegisterS(tel,0,"X",1,0,value);
	vadu = Vmax_DEC/360*tel->MecPolRed*tel->MecPolAduMotVel;
	sprintf(value,"%.0lf",vadu);
	err = etel_SetRegisterS(tel,1,"X",1,0,value);
}

void etel_suivi_marche(struct telprop *tel, char *err_msg) 
{
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	char value[256];
	int err,k;
	double app_drift_HA,app_drift_DEC,app_drift;
   char s[1024],ss[1024];
   double speed_track_ra,speed_track_dec,dradif,ddecdif;
	// differential refraction
	speed_track_ra=tel->speed_track_ra;
	speed_track_dec=tel->speed_track_dec;
	if (tel->refrac_delay>0) {
		libtel_altitude2tp(tel);
	   libtel_GetCurrentUTCDate(tel->interp,ss);
		sprintf(s,"mc_refraction_difradec %f %f {%s} %s %f %d %d",tel->ra0,tel->dec0,tel->home,ss,tel->refrac_delay,tel->radec_model_temperature,tel->radec_model_pressure); 
		if (mytel_tcleval(tel,s)==TCL_OK) {
			strcpy(ss,Tcl_GetStringResult(tel->interp));
			sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
			dradif=atof(Tcl_GetStringResult(tel->interp))/tel->refrac_delay;
			sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
			ddecdif=atof(Tcl_GetStringResult(tel->interp))/tel->refrac_delay;
			speed_track_ra-=(dradif/tel->refrac_div);
			speed_track_dec+=(ddecdif/tel->refrac_div);
		}
	}
	// track speed
	app_drift_HA = tel->speed_track_ra ; // deg/sec
	app_drift_DEC = tel->speed_track_dec ; // deg/sec
	set_drift_speed(tel,err_msg,app_drift_HA,app_drift_DEC);
	for (k=0;k<2;k++) {
		if (k==0) { app_drift=app_drift_HA; }
		else { app_drift=app_drift_DEC; }
		nparams=0;
		params[nparams].conv=0;
		params[nparams].typ=0;
		params[nparams].vald=10;
		if (app_drift==0) {
			// 70 = BRK
			err = etel_ExecuteCommandXS(tel,k,70,params,nparams,value);
		} else {
			// --- start drift
			// etel_execute_command_x_s 0 26 1 0 0 10
			// 26 = JMP (execute sequence)
			nparams++;
			err = etel_ExecuteCommandXS(tel,k,26,params,nparams,value);
		}
	}
	tel->radec_motor=1;
	tel->ontrack=1;
}

void etel_suivi_arret(struct telprop *tel, char *err_msg) 
{
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
	char value[256];
	int k, err;
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
			nparams=0;
			// 70 = BRK
			err = etel_ExecuteCommandXS(tel,k,70,params,nparams,value);
		}
	}
	tel->radec_motor=0;
	tel->ontrack=0;
}

void etel_get_limits(struct telprop *tel, char *err_msg) 
{
	int err;
	char result[256];
	strcpy(err_msg,"");
	if (strcmp(tel->MecTyp,"hadec")==0) {
		err = etel_GetRegisterS(tel,0,"KL",34,0,result);
		if (err==0) {
			tel->MecBasLimInf = atof(result);
		}
		err = etel_GetRegisterS(tel,0,"KL",35,0,result);
		if (err==0) {
			tel->MecBasLimSup = atof(result);
		}
		err = etel_GetRegisterS(tel,1,"KL",34,0,result);
		if (err==0) {
			tel->MecPolLimInf = atof(result);
		}
		err = etel_GetRegisterS(tel,1,"KL",35,0,result);
		if (err==0) {
			tel->MecPolLimSup = atof(result);
		}
	}
}

void etel_get_coord(struct telprop *tel, char *err_msg, double *ang0, double *ang1, double *ang2) 
{
	int err;
	char result[256];
	double ha,dec;
	strcpy(err_msg,"");
	if (strcmp(tel->MecTyp,"hadec")==0) {
		err = etel_GetRegisterS(tel,0,"ML",7,0,result);
		if (err==0) {
			tel->MecBasAdu = atof(result);
		} else {
			strcpy(err_msg,result);
			return;
		}
		err = etel_GetRegisterS(tel,1,"ML",7,0,result);
		if (err==0) {
			tel->MecPolAdu = atof(result);
		} else {
			strcpy(err_msg,result);
			return;
		}
		tel->MecPolAng = (tel->MecPolAdu-tel->MecPolAdu0)/tel->MecPolAduDeg + tel->MecPolAng0;
		tel->MecBasAng = (tel->MecBasAdu-tel->MecBasAdu0)/tel->MecBasAduDeg + tel->MecBasAng0;
		if (tel->MecPolAng<0) {
			tel->MecPolSide = SIDE_REGULAR ;
			ha = tel->MecBasAng ;
			dec = tel->MecPolAng + 90 ;
		} else {
			tel->MecPolSide = SIDE_REVERSED ;
			ha = tel->MecBasAng + 180 ;
			dec = 90 - tel->MecPolAng ;
		}
		ha = fmod(ha+720,360);
		*ang0 = ha;
		*ang1 = dec;
		*ang2 = 0;
	}
}

void etel_set_coord(struct telprop *tel, char *err_msg, double ang0, double ang1, double ang2, double *MecBasAdu, double *MecPolAdu, double *MecRotAdu)
{
	int err;
	char result[256];
	double ha,dec;
	int pole_side_to_point;
	double MecBasAng,MecPolAng;
	strcpy(err_msg,"");
	if (strcmp(tel->MecTyp,"hadec")==0) {
		err = etel_GetRegisterS(tel,0,"ML",7,0,result);
		if (err==0) {
			tel->MecBasAdu = atof(result);
		} else {
			strcpy(err_msg,result);
			return;
		}
		err = etel_GetRegisterS(tel,1,"ML",7,0,result);
		if (err==0) {
			tel->MecPolAdu = atof(result);
		} else {
			strcpy(err_msg,result);
			return;
		}
		tel->MecPolAng = (tel->MecPolAdu-tel->MecPolAdu0)/tel->MecPolAduDeg + tel->MecPolAng0;
		tel->MecBasAng = (tel->MecBasAdu-tel->MecBasAdu0)/tel->MecBasAduDeg + tel->MecBasAng0;
		if (tel->MecPolAng<0) {
			tel->MecPolSide = SIDE_REGULAR ;
		} else {
			tel->MecPolSide = SIDE_REVERSED ;
		}
		ha = ang0;
		dec = ang1;
		ha = fmod(ha+720,360);
		if (ha>180) {
			ha-=360;
		}		
		if (ha < tel->MecBasAngLimRis) {
			pole_side_to_point = SIDE_REGULAR;
		} else if (ha > tel->MecBasAngLimSet) {
			pole_side_to_point = SIDE_REVERSED;
		} else {
			pole_side_to_point = tel->MecPolSide;
		}
		if (pole_side_to_point == SIDE_REGULAR) {
			MecBasAng = ha ;
			MecPolAng = dec-90 ;
		} else {
			MecBasAng = ha + 180 ;
			MecPolAng = -(dec-90);
		}
		*MecBasAdu = (MecBasAng-tel->MecBasAng0)*tel->MecBasAduDeg + tel->MecBasAdu0;
		*MecPolAdu = (MecPolAng-tel->MecPolAng0)*tel->MecPolAduDeg + tel->MecPolAdu0;
	}
	etel_get_limits(tel,result);
	if (*MecBasAdu > tel->MecBasLimSup) { 
		*MecBasAdu = tel->MecBasLimSup;
	}
	if (*MecBasAdu < tel->MecBasLimInf) { 
		*MecBasAdu = tel->MecBasLimInf;
	}
	if (*MecPolAdu > tel->MecPolLimSup) { 
		*MecPolAdu = tel->MecPolLimSup;
	}
	if (*MecPolAdu < tel->MecPolLimInf) { 
		*MecPolAdu = tel->MecPolLimInf;
	}
}

void etel_init_coord(struct telprop *tel, char *err_msg, double ang0, double ang1, double ang2) 
{
	int err;
	char result[256];
	strcpy(err_msg,"");
	if (strcmp(tel->MecTyp,"hadec")==0) {
		err = etel_GetRegisterS(tel,0,"ML",7,0,result);
		if (err==0) {
			tel->MecBasAdu0 = atof(result);
		} else {
			strcpy(err_msg,result);
			return;
		}
		err = etel_GetRegisterS(tel,1,"ML",7,0,result);
		if (err==0) {
			tel->MecPolAdu0 = atof(result);
		} else {
			strcpy(err_msg,result);
			return;
		}
		tel->MecPolAng0 = ang1-90;
		tel->MecBasAng0 = ang0;
		tel->MecPolSide = SIDE_REGULAR ;
	}
}

void etel_error(struct telprop *tel, int axisno, int err)
{
	DSA_DRIVE *drv;
	drv = tel->etel.drv[axisno];
	sprintf(tel->etel.msg, "error %d: %s.\n", err, dsa_translate_error(err));
}

int etel_symbol2type(struct telprop *tel, char *symbol)
{
	int k, kk = -1;
	for (k = 0; k<NB_TYP; k++) {
		if (strcmp(tel->typs[k].type_symbol, symbol) == 0) {
			kk = k;
			break;
		}
	}
	return kk;
}

uint64_t atoi64(const char *str, int radix)
{
	// on estime que la base est de la forme 0123456789abcdefghi....
	uint64_t n = 0;
	const char *c = str;
	while (*c) {
		if ((*c) >= '0' && (*c) <= '9')
			n = n*radix + (*c) - '0';
		else if (radix>10 && (*c) >= 'a' && (*c) <= ('a' + radix - 11))
			n = n*radix + (*c) - 'a' + 10;
		else if (radix>10 && (*c) >= 'A' && (*c) <= ('A' + radix - 11))
			n = n*radix + (*c) - 'A' + 10;
		else
			return 0;
		c++;
	}
	return n;
}

int etel_ExecuteCommandXS(struct telprop *tel, int axisno , int cmd, cmd_param *params, int nparams,char *result)
/****************************************************************************/
/****************************************************************************/
{
	char ligne[256];
	int err = 0;
	int k;
	for (k = 0; k < nparams; k++) {
		tel->params[k].typ = params[k].typ; // =0 in general
		tel->params[k].conv = params[k].conv; // =0 if digital units
		if (tel->params[k].conv == 0) {
			tel->params[k].val.i = (int)params[k].vald;
		}
		else {
			tel->params[k].val.d = params[k].vald;
		}
	}
	for (k = nparams; k < NB_PARAMS_MAXI; k++) {
		tel->params[k].typ = 0; // =0 in general
		tel->params[k].conv = 0; // =0 if digital units
		tel->params[k].val.i = 0;
		tel->params[k].val.d = 0;
	}
	err = dsa_execute_command_x_s(tel->etel.drv[axisno], cmd, tel->params, nparams, FALSE, FALSE, DSA_DEF_TIMEOUT);
	if (err != 0) {
		etel_error(tel,axisno, err);
		sprintf(ligne, "%s", tel->etel.msg);
	}
	strcpy(result, ligne);
	return(err);
}

int etel_GetRegisterS(struct telprop *tel, int axisno, char *string_typ, int idx, int sidx, char *result)
/****************************************************************************/
/****************************************************************************/
{
	char ligne[1024];
	int err = 0;
	int typ, ks, ctype;
	long val;
	double vald;
	float valf;
	__int64 vall;
	ks = etel_symbol2type(tel, string_typ);
	if (ks == -1) {
		typ = atoi(string_typ);
	} else {
		typ = tel->typs[ks].typ;
		ctype = tel->typs[ks].ctype;
	}
	strcpy(ligne, "");
	if (ctype == ETEL_VAL_INT32) {
		err = dsa_get_register_int32_s(tel->etel.drv[axisno], typ, idx, sidx, &val, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%d", val);
	}
	else if (ctype == ETEL_VAL_INT64) {
		err = dsa_get_register_int64_s(tel->etel.drv[axisno], typ, idx, sidx, &vall, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%I64i", vall);
	}
	else if (ctype == ETEL_VAL_FLOAT32) {
		err = dsa_get_register_float32_s(tel->etel.drv[axisno], typ, idx, sidx, &valf, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%f", valf);
	}
	else if (ctype == ETEL_VAL_FLOAT64) {
		err = dsa_get_register_float64_s(tel->etel.drv[axisno], typ, idx, sidx, &vald, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%lf", vald);
	}
	if (err != 0) {
		etel_error(tel, axisno, err);
		sprintf(ligne, "%s", tel->etel.msg);
	}
	strcpy(result, ligne);
	return(err);
}

int etel_SetRegisterS(struct telprop *tel, int axisno, char *string_typ, int idx, int sidx, char *value)
/****************************************************************************/
/****************************************************************************/
{
	char ligne[1024];
	int result = TCL_OK, err = 0;
	int typ, ks, ctype;
	long val;
	double vald;
	float valf;
	__int64 vall;
#if defined(MOUCHARD)
	FILE *f;
#endif
	ks = etel_symbol2type(tel,string_typ);
	if (ks == -1) {
		typ = atoi(string_typ);
	}
	else {
		typ = tel->typs[ks].typ;
		ctype = tel->typs[ks].ctype;
	}
	strcpy(ligne, "");
	if (ctype == ETEL_VAL_INT32) {
		val = (long)atol(value);
		err = dsa_set_register_int32_s(tel->etel.drv[axisno], typ, idx, sidx, val, DSA_DEF_TIMEOUT);
	}
	else if (ctype == ETEL_VAL_INT64) {
		vall = (__int64)atoi64(value, 10);
		err = dsa_set_register_int64_s(tel->etel.drv[axisno], typ, idx, sidx, vall, DSA_DEF_TIMEOUT);
	}
	else if (ctype == ETEL_VAL_FLOAT32) {
		valf = (float)atof(value);
		err = dsa_set_register_float32_s(tel->etel.drv[axisno], typ, idx, sidx, valf, DSA_DEF_TIMEOUT);
	}
	else if (ctype == ETEL_VAL_FLOAT64) {
		vald = (double)atof(value);
		err = dsa_set_register_float64_s(tel->etel.drv[axisno], typ, idx, sidx, vald, DSA_DEF_TIMEOUT);
	}
	if (err != 0) {
		etel_error(tel, axisno, err);
		sprintf(ligne, "%s", tel->etel.msg);
	}
	strcpy(value, ligne);
	return(err);
}

/*
* Retourne l'heure UTC with the milliseconds
*/
void etel_GetCurrentUTCDate(Tcl_Interp *interp, char *s)
{
   Tcl_Eval(interp,"set t [clock milliseconds] ; format \"%s.%03d\" [clock format [expr {$t / 1000}] -format \"%Y %m %d %H %M %S\" -timezone :UTC] [expr {$t % 1000}]");
   strcpy(s,Tcl_GetStringResult(interp));
}

double etel_tsl(struct telprop *tel,int *h, int *m,double *sec)
{
   char s[1024];
   char ss[1024];
	double dt;
   static double tsl;
   /* --- temps sideral local */
	dt=tel->dead_delay_slew/86400;
   etel_home(tel,"");
   etel_GetCurrentUTCDate(tel->interp,ss);
	sprintf(s,"mc_date2lst [expr [mc_date2jd {%s}]+%f] {%s}",ss,dt,tel->home);
   mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 0",ss);
   mytel_tcleval(tel,s);
   *h=(int)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 1",ss);
   mytel_tcleval(tel,s);
   *m=(int)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 2",ss);
   mytel_tcleval(tel,s);
   *sec=(double)atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(Tcl_GetStringResult(tel->interp)); /* en degres */
   return tsl;
}

int etel_home(struct telprop *tel, char *home_default)
{
   char s[1024];
   if (strcmp(tel->home0,"")!=0) {
      strcpy(tel->home,tel->home0);
      strcpy(tel->homePosition,tel->home0);
      return 0;
   }
   sprintf(s,"info exists audace(posobs,observateur,gps)");
   mytel_tcleval(tel,s);
   if (strcmp(Tcl_GetStringResult(tel->interp),"1")==0) {
      sprintf(s,"set audace(posobs,observateur,gps)");
      mytel_tcleval(tel,s);
      strcpy(tel->home,Tcl_GetStringResult(tel->interp));
	} else {
      if (strcmp(home_default,"")!=0) {
         strcpy(tel->home,home_default);
      }
   }
   return 0;
}
