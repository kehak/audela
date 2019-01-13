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

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>

#include <libcam/util.h>

/*
 * Donnees propres a chaque camera.
 */

/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
	
	//Variables a Leandro et Luis pour CEMES
	boolean HV;
	unsigned int vitesse;
	boolean debug;	
	unsigned int sizeX;
	unsigned int sizeY;
	boolean ampliautoman;
	boolean obtuautoman;
	boolean amplionoff;
	boolean obtuonoff;
	unsigned int obtumode;
	int status;

    /* --- flag pour updatelog --- */
    int updatelogindex;
};


#include "alims.h"
#include "controleur.h"


void AlimsInit(void);
void AlimsStop(void);
void ControleurInit(void);
void ControleurStop(void);

unsigned int SetBasseTension(int onoff);
unsigned int GetTemperature(int n, double *temp);
unsigned int SetSupply(int on);
unsigned int SetModeTension(int HR, unsigned int binning);
unsigned int SetModeBinning(int HV, unsigned int binning, unsigned int vitesse, int debug);
unsigned int SetTempsExposition(double pose, unsigned int *erreur);
unsigned int GetTempsExposition(double *pose, unsigned int *erreur);
unsigned int SetArea(unsigned short x0, unsigned short y0, unsigned short xb, unsigned short yb);
unsigned int SetImageSize(unsigned long sx, unsigned long sy);
unsigned int GetImageSize(unsigned long *sx, unsigned long *sy);
unsigned int Start(void);
unsigned int Stop(int stp);
unsigned int Abort(int abrt);
unsigned int SerialDownload(void);
unsigned int Reset(void);
void Initialise(int initls);
unsigned int GetStatusCamera(int est0, int est1);
unsigned int SetPeltier(int on);
unsigned int SetPeltierConsigne(int temp);
unsigned int GetStatusAmplis(int comG, int comBP, int comL, int ampliam, int ampliof);
unsigned int GetStatusObtu(int onoff, int am, int ouvfer);
unsigned int SetAmplisObtu(int onoff, int onoff2, int onoff3, int onoff4, int onoff5);
unsigned int SetDECALAGE(unsigned int n, unsigned int val);
unsigned int SetConfCalcul(short ConfCalcul);
void equilibrer(unsigned int stat_dina);
void SetDebugLevel(int level);

unsigned int ResetADLINK();


void cemes_updatelog(struct camprop *cam, char *filename, char *comment);


#endif
