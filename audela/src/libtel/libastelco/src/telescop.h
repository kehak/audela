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
	int type; /* =0:TCP/IP */
   char portcom[100];
   char ip[50];
   char home0[60]; /* home used by tel1 home */
   char home[60]; /* home */
   double latitude; /* degrees */
   double speed_track_ra; /* (deg/s) */
   double speed_track_dec; /* (deg/s) */
   double track_diurnal; /* (deg/s) */
	int blockingmethod;
	/* ASTELCO */
	char tsi_version[12];
	//
	char telescope_info_name[12];
	float telescope_info_diameter;
	char telescope_info_cabinet[20];
	char telescope_info_manufacturer[20];
	//
	char telescope_info_dome_name[12];
	float telescope_info_dome_diameter;
	float telescope_info_dome_slitwidth;
	char telescope_info_dome_cabinet[20];
	//
	int telescope_config_capabilities; // bits: 0=altaz 1=hadec 2=altalt
	int telescope_config_mounttype; // 1=altaz 2=hadec 3=altalt
	//
	int telescope_config_local_syncmode; // set it to zero
	float telescope_config_local_latitude;
	float telescope_config_local_longitude;
	float telescope_config_local_height;
	float telescope_config_local_ut1utc; // ut1-utc
	float telescope_config_local_taiutc; // tai-utc
	//
	int telescope_config_environment_syncmode; // set it to zero
	float telescope_config_environment_temperature;
	float telescope_config_environment_pressure;
	//
	int telescope_config_cover_capabilities;
	//SYNCMODE
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

int astelco_connection(struct telprop *tel);
int astelco_put(struct telprop *tel,char *cmd);
int astelco_read(struct telprop *tel,char *res);
int astelco_delete(struct telprop *tel);

int astelco_position_tube(struct telprop *tel,char *sens);
int astelco_setlatitude(struct telprop *tel,double latitude);
int astelco_getlatitude(struct telprop *tel,double *latitude);
int astelco_gettsl(struct telprop *tel,double *tsl);
int astelco_LA (struct telprop *tel, int value);
int astelco_LB (struct telprop *tel, int value);
int astelco_lg (struct telprop *tel, int *vra, int *vdec);
int astelco_v_firmware (struct telprop *tel) ;
int astelco_arret_pointage(struct telprop *tel) ;
int astelco_suivi_arret (struct telprop *tel);
int astelco_suivi_marche (struct telprop *tel);
int astelco_coord(struct telprop *tel,char *result);
int astelco_match(struct telprop *tel);
int astelco_goto(struct telprop *tel);
int astelco_initzenith(struct telprop *tel);
int astelco_stopgoto(struct telprop *tel);
int astelco_stategoto(struct telprop *tel,int *state);
int astelco_hadec_coord(struct telprop *tel,char *result);
int astelco_hadec_goto(struct telprop *tel);

int astelco_angle_ra2hms(char *in, char *out);
int astelco_angle_dec2dms(char *in, char *out);
int astelco_angle_hms2ra(struct telprop *tel, char *in, char *out);
int astelco_angle_dms2dec(struct telprop *tel, char *in, char *out);

int astelco_setderive(struct telprop *tel,int var,int vdec);
int astelco_getderive(struct telprop *tel,int *var,int *vdec);

int astelco_settsl(struct telprop *tel);
int astelco_home(struct telprop *tel, char *home_default);
double astelco_tsl(struct telprop *tel,int *h, int *m,double *sec);

int astelco_stat(struct telprop *tel,char *result,char *bits);
int astelco_initfiducial(struct telprop *tel);
int astelco_movingdetect(struct telprop *tel,int hara, double *sepangledeg);

#ifdef __cplusplus
}
#endif      // __cplusplus

#endif

