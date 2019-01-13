/* ydtcl.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine DAMERDJI <damerdji@obs-hp.fr>
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

/***************************************************************************/
/* Ce fichier d'inclusion contient                                         */
/* - l'interfacage avec Tcl/Tk et initialise                               */
/* - l'initialisation la librairie                                         */
/* - les fonctions d'interfacage entre Tcl et le C                         */
/***************************************************************************/
#ifndef __YDTCLH__
#define __YDTCLH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libyd.c     */
/***************************************************************************/
/***************************************************************************/

#include "libyd.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers ydtcl_*.c */
/***************************************************************************/
/***************************************************************************/
#ifndef max
#   define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#   define min(a,b) (((a)<(b))?(a):(b))
#endif

typedef struct {
   double ra;
   double dec;
   double jd;
   unsigned char codecam;
   unsigned char codefiltre;
   float maginst;
   float exposure;
   float airmass;
   float dmag;
   unsigned char flag;
} struct_htmfile ;

typedef struct {
   unsigned short int indexref;
   unsigned int nbmes;
   double ra;
   double dec;
   unsigned char codecat[4];
   unsigned char codefiltre[4];
   float mag[4];
} struct_htmref ;

typedef struct {
   double jd;
   float cmag;
   float exposure;
   float airmass;
   unsigned short int indexzmg;
   unsigned char codecam;
   unsigned char codefiltre;
} struct_htmzmg ;

typedef struct {
   double jd;
   float maginst;
   float magcali;
   float dmag;
   unsigned short int indexref;
   unsigned short int indexzmg;
   unsigned char codecam;
   unsigned char codefiltre;
   unsigned char flag;
} struct_htmmes ;

/*Modif Yassine
#define YD_FLTMES 5*/
#define YD_FLTMES 7
/*fin*/
#define YD_NJD    0
#define YD_MAGMOY 1
#define YD_SIGMOY 2
#define YD_ALLJD  3
#define YD_SIGJD  4
/*Rajout Yassine*/
#define YD_AMPLI  5
#define YD_FIT    6
/*fin*/

/*rajout Yassine*/
#define MAG_PHOTO  13.5
#define MAG_BACKG  16.
/*En prenant XMOYFIT=1.5 ca revient a prendre XMOY=(environ)1.5 */
#define XMOY       1.5
#define XMOYFIT    2.0
#define NB_ITER    3
/*Voici les pentes des fit obtenues sous matlab*/
/*Cam 2 */
#define pente_photo 0.25
#define pente_backg 0.80
/*#define pente_photo_B 0.252
#define pente_backg_B 0.271
#define pente_photo_C 0.145
#define pente_backg_C 0.290
#define pente_photo_I 0.170
#define pente_backg_I 0.410
#define pente_photo_R 0.110
#define pente_backg_R 0.299
#define pente_photo_V 0.217
#define pente_backg_V 0.334*/
/*Cam1
#define pente_photo_B 0.282
#define pente_backg_B 0.324
#define pente_photo_C 0.228
#define pente_backg_C 0.274
#define pente_photo_I 0.258
#define pente_backg_I 0.258
#define pente_photo_R 0.274
#define pente_backg_R 0.310
#define pente_photo_V 0.282
#define pente_backg_V 0.324*/
/*fin*/

#define YD_HISTOMAG 100
#define YD_HISTOSIG 3
#define YD_NSTAR    0
#define YD_MOYSIG   1
#define YD_SIGSIG   2

/***************************************************************************/
/*      Prototypes des fonctions d'extension C appelables par Tcl          */
/***************************************************************************/
/*--- Les prototypes sont tous les memes */
int Cmd_ydtcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_bugbias(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_addcol(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_ydtcl_radec2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_htm2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_refzmgmes2vars(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_updatezmg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_sortmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_refzmgmes2ascii(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_filehtm2refzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_file2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_radecinrefzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_photometric_parallax(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_photometric_parallax_avmap(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_cour_finalbis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_reduceusno(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_refzmgmes2vars_stetson(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_ref2field(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_cal2ref(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_mes2mes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/***************************************************************************/
/*      Prototypes des fonctions utiles qui melangent C et Tcl             */
/***************************************************************************/
int ydtcl_getinfoimage(Tcl_Interp *interp,int numbuf, yd_image *image);

#endif

