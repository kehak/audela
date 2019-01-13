/* telescop.h
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

#ifndef __TELESCOP_H__
#define __TELESCOP_H__

#include <tcl.h>
#include <libtel/libstruc.h>

/*
 * Donnees propres a chaque telescope.
 */
//#include <stdint.h>
#ifdef EBADMSG   
#undef EBADMSG  // etb40.h redefinit EBADMSG
#endif
#include <etb40.h>
#include <dsa40.h>
#include <dmd40.h>

#ifdef __cplusplus
extern "C" {      
#endif             // __cplusplus */

#define ETEL_NAXIS_MAXI 10
int etel_nbaxis;

typedef struct {
	char etel_driver[50];
	char msg[200];
	int axis[ETEL_NAXIS_MAXI];
	int axisno[ETEL_NAXIS_MAXI];
	DSA_DRIVE *drv[ETEL_NAXIS_MAXI];
} struct_etel;

typedef struct {
	char type_symbol[10];
	int typ;
	int ctype;
	int *func_get;
	int *func_set;
} struct_etel_type;

#define NB_TYP 19

#define ETEL_VAL_INT32   0
#define ETEL_VAL_INT64   1
#define ETEL_VAL_FLOAT32 2
#define ETEL_VAL_FLOAT64 3

#define AXIS_STATE_CLOSED       0
#define AXIS_STATE_TO_BE_OPENED 1
#define AXIS_STATE_OPENED       2

#define NB_PARAMS_MAXI 5

typedef struct {
	int typ;
	int conv;
	double vald;
} cmd_param;

//#define MOUCHARD

typedef struct {
   int type;
   int incr_per_deg;
	int posinit;
	double angleinit;
	int sens;
} axis_params;

#define SIDE_REGULAR 0
#define SIDE_REVERSED 1

/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
	struct_etel etel;
	struct_etel_type typs[NB_TYP];
	DSA_COMMAND_PARAM params[NB_PARAMS_MAXI]; // = { { 0,0,0 },{ 0,0,0 },{ 0,0,0 },{ 0,0,0 },{ 0,0,0 } };
   axis_params axis_param[3];
	//
	int type; /* =0:CSI */
	char ip[50];
	char home0[60]; // home used by tel1 home
	char home[60]; // home
	double latitude; // degrees
	char MecTyp[255];
	int signlat;
	//
	double MecPolAduMot ; //inc/tour
	double MecPolAduDeg ; //inc/deg
	//double MecPolVel ; // inc / arcsec / sec
	//double MecPolAcc ; // inc / arcsec / sec2
	double MecPolRed ;
	double MecPolLimSup ;
	double MecPolLimInf ;
	double MecPolAdu0 ;
	double MecPolAng0 ;
	double MecPolAdu ;
	double MecPolAng ;
	double MecPolAduMotVel;
	double MecPolAduMotAcc;
	int MecPolSide ;
	// --- Basis axis
	double MecBasAduMot ; //inc/tour
	double MecBasAduDeg ; //inc/deg
	//double MecBasVel ; // inc / arcsec / sec  
	//double MecBasAcc ; // inc / arcsec / sec2
	double MecBasRed ;
	double MecBasLimSup ;
	double MecBasLimInf ;
	double MecBasAdu0 ;
	double MecBasAng0 ;
	double MecBasAdu ;
	double MecBasAng ;
	double MecBasAngLimRis ; // Valeur limite au levant (est) de l'angle de base pour le retournement
	double MecBasAngLimSet ; //Valeur limite au couchant (ouest) de l'angle de base pour le retournement On a toujours MecBasLimRis < MecBasLimSet.
	double MecBasAduMotVel;
	double MecBasAduMotAcc;
	// --- Rotation axis;
	double MecRotAdu ;
	// ---
	double track_diurnal;
	double acceleration_track_ra;  // (deg/s2)
	double acceleration_track_dec;  // (deg/s2)
   double speed_track_ra; /* (deg/s) */
   double speed_track_dec; /* (deg/s) */
   double acceleration_slew_ra; /* (deg/s2) */
   double acceleration_slew_dec; /* (deg/s2) */
	double speed_slew_ra; /* (deg/s) */
	double speed_slew_dec; /* (deg/s) */
	double dead_delay_slew; // sec
	double refrac_delay; //sec
	double refrac_div;
	// ---
	int move_pulse; // 0=continu 1=pulse
	int slew_hiprecision; // 0=1slew 1=double_slew
	//
	int ontrack;
   char telname[200];
};

int tel_init(struct telprop *tel, int argc, char **argv);
int tel_goto(struct telprop *tel);
int tel_coord(struct telprop *tel,char *result);
int tel_testcom(struct telprop *tel);
int tel_close(struct telprop *tel);
int tel_radec_init(struct telprop *tel);
int tel_radec_goto(struct telprop *tel);
int tel_radec_state(struct telprop *tel,char *result);
int tel_radec_coord(struct telprop *tel,char *result);
int tel_radec_move(struct telprop *tel,char *direction);
int tel_radec_stop(struct telprop *tel,char *direction);
int tel_radec_motor(struct telprop *tel);
int tel_focus_init(struct telprop *tel);
int tel_focus_goto(struct telprop *tel);
int tel_focus_coord(struct telprop *tel,char *result);
int tel_focus_move(struct telprop *tel,char *direction);
int tel_focus_stop(struct telprop *tel,char *direction);
int tel_focus_motor(struct telprop *tel);
int tel_date_get(struct telprop *tel,char *ligne);
int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int tel_home_get(struct telprop *tel,char *ligne);
int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);
int tel_get_position_tube(struct telprop *tel);

int mytel_radec_init(struct telprop *tel);
int mytel_hadec_init(struct telprop *tel);
int mytel_radec_init_additional(struct telprop *tel);
int mytel_radec_goto(struct telprop *tel);
int mytel_hadec_goto(struct telprop *tel);
int mytel_radec_state(struct telprop *tel,char *result);
int mytel_radec_coord(struct telprop *tel,char *result);
int mytel_hadec_coord(struct telprop *tel,char *result);
int mytel_radec_move(struct telprop *tel,char *direction);
int mytel_radec_stop(struct telprop *tel,char *direction);
int mytel_radec_motor(struct telprop *tel);
int mytel_focus_init(struct telprop *tel);
int mytel_focus_goto(struct telprop *tel);
int mytel_focus_coord(struct telprop *tel,char *result);
int mytel_focus_move(struct telprop *tel,char *direction);
int mytel_focus_stop(struct telprop *tel,char *direction);
int mytel_focus_motor(struct telprop *tel);
int mytel_date_get(struct telprop *tel,char *ligne);
int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int mytel_home_get(struct telprop *tel,char *ligne);
int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);
int mytel_init_mount_default(struct telprop *tel,int mountno);

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);
int mytel_correct(struct telprop *tel,char *direction, int duration);

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout);
void mytel_error(struct telprop *tel,int axisno, int err);
void etel_radec_coord(struct telprop *tel, int flagha, int *voidangles,double *angledegs,int *angleucs);

void etel_error(struct telprop *tel, int axisno, int err);
int etel_symbol2type(struct telprop *tel, char *symbol);
#ifndef uint64_t
typedef unsigned __int64     uint64_t;
#endif
uint64_t atoi64(const char *str, int radix);
int etel_ExecuteCommandXS(struct telprop *tel, int axisno , int cmd, cmd_param *params, int nparams,char *result);
int etel_SetRegisterS(struct telprop *tel, int axisno, char *string_typ, int idx, int sidx, char *value);
int etel_GetRegisterS(struct telprop *tel, int axisno, char *string_typ, int idx, int sidx, char *result);

void set_drift_speed(struct telprop *tel, char *err_msg, double app_drift_HA, double app_drift_DEC);
void set_slew_acceleration(struct telprop *tel, char *err_msg, double Amax_HA, double Amax_DEC);
void set_slew_velocity(struct telprop *tel, char *err_msg, double Vmax_HA, double Vmax_DEC);
void etel_suivi_marche(struct telprop *tel, char *err_msg) ;
void etel_suivi_arret(struct telprop *tel, char *err_msg) ;
void etel_get_limits(struct telprop *tel, char *err_msg) ;

void etel_get_coord(struct telprop *tel, char *err_msg, double *ang0, double *ang1, double *ang2);
void etel_set_coord(struct telprop *tel, char *err_msg, double ang0, double ang1, double ang2, double *MecBasAdu, double *MecPolAdu, double *MecRotAdu);
void etel_init_coord(struct telprop *tel, char *err_msg, double ang0, double ang1, double ang2);

void etel_GetCurrentUTCDate(Tcl_Interp *interp, char *s);
int etel_home(struct telprop *tel, char *home_default);
double etel_tsl(struct telprop *tel,int *h, int *m,double *sec);

#ifdef __cplusplus
}
#endif      // __cplusplus

#endif

