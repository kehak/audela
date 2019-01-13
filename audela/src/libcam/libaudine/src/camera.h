/* camera.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    /* --- pour Audine --- */
    /* --- pour l'amplificateur des Kaf-401 --- */
    int ampliindex;
    int nbampliclean;
    /* --- pour l'obturateur Audine --- */
    int shutteraudinereverse;
    /* --- pour le type de CAN --- */
    int cantypeindex;
    /* --- pour l'obturateur a Pierre Thierry --- */
    int shuttertypeindex;	/* 0=audine 1=thierry */
    short InfoPierre_a;
    short InfoPierre_b;
    short InfoPierre_c;
    short InfoPierre_d;
    short InfoPierre_e;
    short InfoPierre_t;
    short InfoPierre_v;
    short InfoPierre_v1;
    short InfoPierre_flag;
    /* --- flag pour updatelog --- */
    int updatelogindex;
    /* --- octets a emettre vers le CCD (cas 3200 vs autres CCD) */
    unsigned char *bytes;
};


void audine_fast_vidage_inv(struct camprop *cam);
unsigned char audine_kafinv(struct camprop *cam, unsigned char value);
void audine_zi_zh_inv(struct camprop *cam);
void audine_read_pel_fast_inv(struct camprop *cam);
void audine_read_pel_fast2_inv(struct camprop *cam);
void audine_read_win_inv(struct camprop *cam, float *buf);
void audine_fast_line_inv(struct camprop *cam);
void audine_fast_line2_inv(struct camprop *cam);
void audine_ampli_off(struct camprop *cam);
void audine_ampli_on(struct camprop *cam);
void audine_shutter_off(struct camprop *cam);
void audine_shutter_on(struct camprop *cam);

void audine_set0(struct camprop *cam);
void audine_set255(struct camprop *cam);
void audine_test(struct camprop *cam, int number);
void audine_test2(struct camprop *cam, int number);
int audine_read_line(struct camprop *cam, int width, int offset, int binx, int biny, unsigned short *buf);

/* --- obturateur de Pierre Thierry ---*/
void audine_g_obtu_on(struct camprop *cam);
void audine_g_obtu_off(struct camprop *cam);
short audine_obtu_pierre(short base, short t1, short v);
short audine_obtu_off(short base);
short audine_obtu_on(short base);

void audine_cam_test_out(struct camprop *cam, unsigned long nb_out);
void audine_updatelog(struct camprop *cam, const char *filename, const char *comment);


#endif
