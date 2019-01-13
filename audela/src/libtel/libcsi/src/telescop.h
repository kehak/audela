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

#if defined(_MSC_VER)
#include <sys/types.h>
#include <sys/timeb.h>
#endif

#ifdef __cplusplus
extern "C" {      
#endif             // __cplusplus */


/*
 * Donnees propres a chaque telescope.
 */
/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
   int tempo;
	int type; /* =0:CSI */
   char ip[50];
   char home0[60]; /* home used by tel1 home */
   char home[60]; /* home */
   double latitude; /* degrees */
   double ha00; /* ha (degrees) at a given roth00 */
   double dec00; /* dec (degrees) at a given rotd00 */
   int roth00; /* (uc) */
   int rotd00; /* (uc) */
   double speed_track_ra; /* (deg/s) */
   double speed_track_dec; /* (deg/s) */
   double speed_slew_ra; /* (deg/s) */
   double speed_slew_dec; /* (deg/s) */
   double radec_speed_ra_conversion; /* (UC)/(deg/s) */
   double radec_speed_dec_conversion; /* (UC)/(deg/s) */
   double radec_position_conversion; /* (UC)/(deg) */
   double track_diurnal; /* (deg/s) */
   int stop_e_uc; /* butee mecanique est */
   int stop_w_uc; /* butee mecanique ouest */
   double radec_move_rate_max; /* vitesse max (deg/s) pour move -rate 1 */
   double radec_tol; /* tolerance en arcsec pour le goto -blocking 1 toutes les 350 ms */
	int simultaneus; /* =1 pour lancer un GOTO simultane sur les deux axes */
	int ontrack; /* =0 if no track, =1 if tracking activated */
#if defined(OS_WIN)
	HINSTANCE hPmacLib; /* handler Pmac */
	int PmacDevice;
	char pmac_response[990];
#endif
	double dead_delay_slew; /* delai en secondes estime pour un slew sans bouger */
	double refrac_delay; /* delai pour tenir compte de la refraction differentielle */
	double refrac_div; /* coef diviseur pour tenir compte de la refraction differentielle =1 */
	// CSI specific values
	int ra_maxvel;
	int dec_maxvel;
	int dome_maxvel;
	int foc_maxvel;
	int enable_dome;
	int tempo_exe;
   int security;
   double trackingduration;
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
int mytel_radec_goto(struct telprop *tel);
int mytel_radec_state(struct telprop *tel,char *result);
int mytel_radec_coord(struct telprop *tel,char *result);
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
int mytel_hadec_coord(struct telprop *tel,char *result);
int mytel_hadec_goto(struct telprop *tel);
int mytel_motor_coord(struct telprop *tel, char *result);
int mytel_encoder_coord(struct telprop *tel, char *result);


int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);

int csi_put(struct telprop *tel,char *cmd);
int csi_read(struct telprop *tel,char *res);
int csi_delete(struct telprop *tel);

int csi_position_tube(struct telprop *tel,char *sens);
int csi_setlatitude(struct telprop *tel,double latitude);
int csi_getlatitude(struct telprop *tel,double *latitude);
int csi_gettsl(struct telprop *tel,double *tsl);
int csi_LA (struct telprop *tel, int value);
int csi_LB (struct telprop *tel, int value);
int csi_lg (struct telprop *tel, int *vra, int *vdec);
int csi_v_firmware (struct telprop *tel) ;
int csi_arret_pointage(struct telprop *tel) ;
int csi_suivi_arret (struct telprop *tel);
int csi_suivi_marche (struct telprop *tel);
int csi_coord(struct telprop *tel,char *result);
int csi_init(struct telprop *tel);
int csi_goto(struct telprop *tel);
int csi_initzenith(struct telprop *tel);
int csi_stopgoto(struct telprop *tel);
int csi_stategoto(struct telprop *tel,int *state);
int csi_positions12(struct telprop *tel,int *p1,int *p2);
int csi_hadec_coord(struct telprop *tel,char *result);
int csi_motor_coord(struct telprop *tel,char *result);
int csi_encoder_coord(struct telprop *tel,char *result);
int csi_hadec_goto(struct telprop *tel);
int csi_compute_tracking(struct telprop *tel,int *De_ra, int *De_dec,int *dur);
int csi_supergoto(struct telprop *tel,int type_coord);

int csi_angle_ra2hms(char *in, char *out);
int csi_angle_dec2dms(char *in, char *out);
int csi_angle_hms2ra(struct telprop *tel, char *in, char *out);
int csi_angle_dms2dec(struct telprop *tel, char *in, char *out);

int csi_setderive(struct telprop *tel,int var,int vdec);
int csi_getderive(struct telprop *tel,int *var,int *vdec);

int csi_settsl(struct telprop *tel);
int csi_home(struct telprop *tel, char *home_default);
double csi_tsl(struct telprop *tel,int *h, int *m,double *sec,double dt);

long csi_dome_compute_azimuth (struct telprop *tel,int type_coord);
int csi_dome_rotate (struct telprop *tel);
int csi_dome_close(struct telprop *tel);
int csi_dome_open(struct telprop *tel);
int csi_dome_invert(struct telprop *tel);
long csi_dome_locate(struct telprop *tel);
int csi_dome_enable(struct telprop *tel);
int csi_dome_disable(struct telprop *tel);
int csi_dome_get_azimuth (struct telprop *tel, double *az, int *adu);

void csi_hd2ah(double ha, double dec, double latitude, double *az, double *h);
double csi_asin(double x);
int csi_decode_date(Tcl_Interp *interp, double *jj);
void csi_date_jd(int annee, int mois, double jour, double *jj);

int csi_focus_move(struct telprop *tel, char *direction);
int csi_focus_goto(struct telprop *tel);
int csi_focus_coord(struct telprop *tel, char *result);
int csi_focus_init(struct telprop *tel);

// Global variables for the dome
static const long encoder = 6518400; // encoder steps per complete rotation
static const double dome_zero = 6.19592; // radians

#define TYPE_ALTAZ 0
#define TYPE_HADEC 1
#define TYPE_RADEC 2

// global variable for the angles
#define PI 3.141592654
#define PISUR2 1.570796327

#ifdef __cplusplus
}
#endif      // __cplusplus

#endif

