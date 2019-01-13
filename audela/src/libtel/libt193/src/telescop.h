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
#include <pthread.h>       // pcreate_thread()

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
	int choice_controler;
   void * outputTelescopTaskHandle;
   void * outputFilterTaskHandle;
   void * inputFilterTaskHandle;
   unsigned char outputTelescopNotification;
   unsigned char outputFilterNotification;
   double filterMaxDelay;    
   double filterCurrentDelay;
   int northRelay;
   int southRelay;
   int estRelay;
   int westRelay;
   int enabledRelay;
   int decreaseFilterRelay;
   int increaseFilterRelay;
   int minDetectorFilterInput;
   int maxDetectorFilterInput;
   double startTime;
   int filterCommand;
   Tcl_Channel telescopeCommandSocket;
   Tcl_Channel telescopeNotificationSocket;
   char telescopeHost[128];
   int  telescopeCommandPort;
   int  telescopeNotificationPort;
   void * telescopeNotificationThread;
   char raBrut[20] ;   // ascension droite courante
   char decBrut[20] ;  // declinaison courante
   //int radecNotification ; // 1=marche 0=arret des notifications des coordonnees radec
   int radecIsMoving ;   // 1=mouvement en cours 0=pas de mouvement en cours 
   int focusIsMoving ;   // 1=mouvement en cours 0=pas de mouvement en cours de la focalisation
   float focusCurrentPosition;  // position courante du focuser
   Tcl_Channel telescopeCoordServerSocket;
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
int tel_get_radec_guiding(struct telprop *tel, int *guiding);
int tel_set_radec_guiding(struct telprop *tel, int guiding);
int tel_radec_correct(struct telprop *tel,char alphaDirection, double alphaDistance, char deltaDirection, double deltaDistance);

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

int tel_filter_setMax(struct  telprop *tel, double filterMaxDelay);
int tel_filter_getMax(struct  telprop *tel, double *filterMaxDelay);
int tel_filter_coord(struct telprop *tel, char * coord);
int tel_filter_move(struct  telprop *tel, char * direction);
int tel_filter_stop(struct  telprop *tel);
int tel_filter_extremity(struct telprop *tel, char * extremity);

int mytel_tcleval(struct telprop *tel,char *ligne);

#ifdef __cplusplus
}
#endif      // __cplusplus

#endif

