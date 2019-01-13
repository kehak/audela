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
   int attente;
   char v_firmware[10];
   int slewpathindex;
   int langageindex;
   int boostindex;
   double ra_backlash;
   double dec_backlash;
   char home[50];
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

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);

int kauf_set_natif (struct telprop *tel) ;
int kauf_echo_supprime (struct telprop *tel) ;
int kauf_echo_ok (struct telprop *tel) ;
int kauf_echo_supprime_lx200(struct telprop *tel) ;
int kauf_echo_ok_lx200(struct telprop *tel) ;
int kauf_reset_tel(struct telprop *tel) ;
int kauf_reset_carte(struct telprop *tel); 
int kauf_v_firmware (struct telprop *tel) ;
int kauf_arret_pointage(struct telprop *tel) ;
int kauf_arret_pointage1(struct telprop *tel) ;
int kauf_suivi_arret (struct telprop *tel);
int kauf_suivi_marche (struct telprop *tel);
int kauf_lx200(struct telprop *tel) ;
int kauf_mode_telescope_lx200(struct telprop *tel,char *ack) ;
int kauf_format_lx200(struct telprop *tel,char *ack) ;
int kauf_goto_lx200(struct telprop *tel) ;
int kauf_match_lx200(struct telprop *tel);
int kauf_coord(struct telprop *tel,char *result);
int kauf_match(struct telprop *tel);
int kauf_goto(struct telprop *tel);

int kauf_vit_maxi_ar(struct telprop *tel,int speed);
int kauf_vit_maxi_dec(struct telprop *tel,int speed);

int kauf_angle_ra2hms(char *in, char *out);
int kauf_angle_dec2dms(char *in, char *out);
int kauf_angle_hms2ra(struct telprop *tel, char *in, char *out);
int kauf_angle_dms2dec(struct telprop *tel, char *in, char *out);
int kauf_delete(struct telprop *tel);

int kauf_foc_zero(struct telprop *tel);
int kauf_foc_vit(struct telprop *tel, int vfoc);
int kauf_foc_coord(struct telprop *tel,char *result);
int kauf_foc_goto(struct telprop *tel);

int kauf_nb_tics_ad(struct telprop *tel,int *ticks);
int kauf_nb_tics_dec(struct telprop *tel,int *ticks);
int kauf_derive_ar(struct telprop *tel,int var);
int kauf_derive_dec(struct telprop *tel,int vdec);
int kauf_king(struct telprop *tel,int vking);
int kauf_active_boost(struct telprop *tel);
int kauf_inhibe_boost(struct telprop *tel);
int kauf_largeur_impulsion(struct telprop *tel,int limp);
int kauf_inhibe_pec(struct telprop *tel);
int kauf_periode_pec(struct telprop *tel,int ppec);
int kauf_pointeur_pec(struct telprop *tel,int *indexpec);
int kauf_pointe_case_pec(struct telprop *tel,int pcpec);
int kauf_lit_vit_pec(struct telprop *tel,int *vitpec);
int kauf_ecrit_vit_pec(struct telprop *tel,int evpec);

int audecom_home(struct telprop *tel, char *home_default);

#ifdef __cplusplus
}
#endif      // __cplusplus

#endif

