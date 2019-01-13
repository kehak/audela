/* camera.h
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

#include <libfli.h>
#include <string>
#include <vector>

using namespace std;

/*
 *   structure pour les fonctions étendues
 */


/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    /* --- pour FingerLakes --- */
    flidev_t device;
    int nb_flushes;
    int pendingStop;    // 1= une demande d'arret est en cours  0= pas de demande d'arret en cours
	int simulation;
};

struct filtprop {
	flidev_t device;
	long filter_number;
	long WhereIAm;
	int position[12];
	//string name[12];
	string short_name[13];
};


extern flidebug_t flidebuglevel;
extern int flilogactivated;
int fingerlakes_read_line(struct camprop *cam, int width, int offset,
			  int bin, unsigned short *buf);
int fingerlakes_nbflushes(struct camprop *cam, int nb);
int fingerlakes_cooler_power(struct camprop *cam, double *power);
int fingerlakes_getTempPower(struct camprop *cam, double *internalTemp, double *externalTemp, double *coolerPower);

#endif
