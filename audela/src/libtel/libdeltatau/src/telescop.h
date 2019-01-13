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
	int type; /* =0:UMAC =1:PMAC-PCI */
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
   double radec_position_ra_conversion; /* (UC)/(deg) */
   double radec_position_dec_conversion; /* (UC)/(deg) */
   double track_diurnal; /* (deg/s) */
   int stop_e_uc; /* butee mecanique est */
   int stop_w_uc; /* butee mecanique ouest */
   double radec_move_rate_max; /* vitesse max (deg/s) pour move -rate 1 */
   double radec_tol; /* tolerance en arcsec pour le goto -blocking 1 toutes les 350 ms */
	int simultaneus; /* =1 pour lancer un GOTO simultane sur les deux axes */
#if defined(OS_WIN)
	HINSTANCE hPmacLib; /* handler Pmac */
	int PmacDevice;
	char pmac_response[990];
#endif
	double dead_delay_slew; /* delai en secondes estime pour un slew sans bouger */
	double refrac_delay; /* delai pour tenir compte de la refraction differentielle */
	double refrac_div; /* coef diviseur pour tenir compte de la refraction differentielle =1 */
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

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);

int deltatau_put(struct telprop *tel,char *cmd);
int deltatau_read(struct telprop *tel,char *res);
int deltatau_delete(struct telprop *tel);

int deltatau_position_tube(struct telprop *tel,char *sens);
int deltatau_setlatitude(struct telprop *tel,double latitude);
int deltatau_getlatitude(struct telprop *tel,double *latitude);
int deltatau_gettsl(struct telprop *tel,double *tsl);
int deltatau_LA (struct telprop *tel, int value);
int deltatau_LB (struct telprop *tel, int value);
int deltatau_lg (struct telprop *tel, int *vra, int *vdec);
int deltatau_v_firmware (struct telprop *tel) ;
int deltatau_arret_pointage(struct telprop *tel) ;
int deltatau_suivi_arret (struct telprop *tel);
int deltatau_suivi_marche (struct telprop *tel);
int deltatau_coord(struct telprop *tel,char *result);
int deltatau_match(struct telprop *tel);
int deltatau_goto(struct telprop *tel);
int deltatau_initzenith(struct telprop *tel);
int deltatau_stopgoto(struct telprop *tel);
int deltatau_stategoto(struct telprop *tel,int *state);
int deltatau_positions12(struct telprop *tel,int *p1,int *p2);
int deltatau_hadec_coord(struct telprop *tel,char *result);
int deltatau_hadec_goto(struct telprop *tel);

int deltatau_angle_ra2hms(char *in, char *out);
int deltatau_angle_dec2dms(char *in, char *out);
int deltatau_angle_hms2ra(struct telprop *tel, char *in, char *out);
int deltatau_angle_dms2dec(struct telprop *tel, char *in, char *out);

int deltatau_setderive(struct telprop *tel,int var,int vdec);
int deltatau_getderive(struct telprop *tel,int *var,int *vdec);

int deltatau_settsl(struct telprop *tel);
int deltatau_home(struct telprop *tel, char *home_default);
double deltatau_tsl(struct telprop *tel,int *h, int *m,double *sec);


#ifdef __cplusplus

}

#endif      // __cplusplus


#endif
