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

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

/*enum TObtu {OBTU_SYNCHRO, OBTU_OUVERT, OBTU_FERME};*/

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    char ip[50];
	 char channel[20];
	 int tempo;
	 char pathimraw[2048];
	 int simulation;
};

int mycam_tcleval(struct camprop *cam,char *ligne);
int cagire_put(struct camprop *cam, const char *cmd);
int cagire_read(struct camprop *cam,char *res);
int cagire_initialize(struct camprop *cam);
int cagire_lastimage(struct camprop *cam, char *lastimage);

#endif

