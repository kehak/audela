/* aktcl.h
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

/***************************************************************************/
/* Ce fichier d'inclusion contient                                         */
/* - l'interfacage avec Tcl/Tk et initialise                               */
/* - l'initialisation la librairie                                         */
/* - les fonctions d'interfacage entre Tcl et le C                         */
/***************************************************************************/
#ifndef __AKTCLH__
#define __AKTCLH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libak.c     */
/***************************************************************************/
/***************************************************************************/

#include "libak.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers aktcl_*.c */
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
   /* rajout Yassine*/
   float dmag;
   unsigned char flag;
   /*fin*/
} struct_htmfile ;

typedef struct {
   int indexref;
   int nbmes;
   double ra;
   double dec;
   unsigned char codecat[4];
   unsigned char codefiltre[4];
   float mag[4];
} struct_htmref ;

typedef struct {
   int indexzmg;
   double jd;
   /*rajout Yassine : ca peut etre util*/
   unsigned char codecam;
   /*fin*/
   unsigned char codefiltre;
   float cmag;
   float exposure;
   float airmass;
} struct_htmzmg ;

typedef struct {
   int indexref;
   int indexzmg;
   double jd;
   unsigned char codecam;
   unsigned char codefiltre;
   float maginst;
   float magcali;
   /* rajout Yassine*/
   float dmag;
   unsigned char flag;
   /*fin*/
} struct_htmmes ;

/*Modif Yassine
#define AK_FLTMES 5*/
#define AK_FLTMES 7
/*fin*/
#define AK_NJD    0
#define AK_MAGMOY 1
#define AK_SIGMOY 2
#define AK_ALLJD  3
#define AK_SIGJD  4
/*Rajout Yassine*/
#define AK_AMPLI  5
#define AK_FIT    6
/*fin*/

/*rajout Yassine*/
#define MAG_PHOTO  13.5
#define MAG_BACKG  15.5
/*En prenant XMOYFIT=1.5 ca revient a prendre XMOY=(environ)1.5 */
#define XMOY       1.5
#define XMOYFIT1   1.0
#define XMOYFIT2   3.0
#define NB_ITER    5
/*Voici les pentes des fit obtenues sous matlab*/
/*Cam 2 */
#define pente_photo 0.20
#define pente_backg 0.60
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

#define AK_HISTOMAG 100
#define AK_HISTOSIG 3
#define AK_NSTAR    0
#define AK_MOYSIG   1
#define AK_SIGSIG   2

typedef struct {
	double x;
	double y;
	double flux;
	double fwhm;
	double coord1;
	double coord2;
	int id;
	int flag;
} focas_sources;

/***************************************************************************/
/*      Prototypes des fonctions d'extension C appelables par Tcl          */
/***************************************************************************/
/*--- Les prototypes sont tous les memes */
int Cmd_aktcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_bugbias(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_addcol(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_radec2healpix(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_healpix2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_sizeofrefzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_radec2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_htm2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_refzmgmes2vars(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_updatezmg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_sortmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_refzmgmes2ascii(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_filehtm2refzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_file2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_radecinrefzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_photometric_parallax(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_photometric_parallax_avmap(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_cour_finalbis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_reduceusno(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_splitcfht(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_aster1(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_fitspline(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int Cmd_aktcl_focas_catastars2pairs(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/*int Cmd_aktcl_rectification(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);*/

int Cmd_aktcl_bayestar2galaxies(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/***************************************************************************/
/*      Prototypes des fonctions utiles qui melangent C et Tcl             */
/***************************************************************************/
int aktcl_getinfoimage(Tcl_Interp *interp,int numbuf, ak_image *image);
char *ak_d2s(double val);

#endif

