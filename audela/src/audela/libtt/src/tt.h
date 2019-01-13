/* tt.h
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
/* Ce programme permet l'acces aux fonctions de la bibliotheque de         */
/* traitement de donnees (images et autres) pour l'astronomie.             */
/***************************************************************************/
/* Ce programme peut etre compile selon diverses possibilites :            */
/***************************************************************************/
/* Il n'y a qu'un seul point d'entree pour acceder a l'ensemble des        */
/* fonctions. De cette facon, le programme appelant n'a besoin de definir  */
/* Uniquement que la fonction d'entree definie comme suit :                */
/*                                                                         */
/* int libtt_main(int service, ...)                                        */
/*                                                                         */
/* En entree :                                                             */
/*  service : est un nombre entier qui designe la fonction                 */
/* En entree/sortie                                                        */
/*  ... : une suite de parametres d'entree ou de sortie suivant le cas     */
/* En sortie :                                                             */
/*  int : retourne un code d'erreur ou zero si tout c'est bien passe       */
/***************************************************************************/
#pragma once

#ifdef WIN32
#include <windows.h>
#undef FAR
#define HAVE_BOOLEAN
#endif

/* --- definition de l'operating systeme (OS) employe pour compiler    ---*/
#include "sysexp.h"

/* --- definition communes a tous les OS ---*/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
#include <varargs.h>
#else
#include <stdarg.h>
#endif

#include "libtt.h"
#define libtt_main0 libtt_main

#ifndef __FILESH__
#include "files.h"
#endif
#ifndef __TTUSER1H__
#include "tt_user1.h"
#endif
#ifndef __TTUSER2H__
#include "tt_user2.h"
#endif
#ifndef __TTUSER3H__
#include "tt_user3.h"
#endif
#ifndef __TTUSER4H__
#include "tt_user4.h"
#endif
#ifndef __TTUSER5H__
#include "tt_user5.h"
#endif

#define TT_MAX_CHAR 127
#define TT_MAX_UNSIGNEDCHAR (unsigned char)255
#define TT_MAX_UNSIGNEDSHORT (unsigned short)65535
#define TT_MAX_SHORT 32767
#define TT_MAX_UNSIGNEDINT (unsigned int)4294967295UL
#define TT_MAX_INT 2147483647
#define TT_MAX_FLOAT 3.402823466e+38
/*
#define TT_MAX_UNSIGNEDINT 4294967295F
#define TT_MAX_INT 2147483647L
#define TT_MAX_FLOAT 3.402823466e+38F
*/
#define TT_MAX_DOUBLE 1.79769313486231500e+308
#define TT_MIN_CHAR -128
#define TT_MIN_UNSIGNEDCHAR 0
#define TT_MIN_UNSIGNEDSHORT 0
#define TT_MIN_SHORT -32768
#define TT_MIN_UNSIGNEDINT 0
#define TT_MIN_INT -2147483648
#define TT_MIN_FLOAT -3.402823466e+38
/*
#define TT_MIN_INT (-2147483647L-1)
#define TT_MIN_FLOAT -3.402823466e+38F
*/
#define TT_MIN_DOUBLE -1.79769313486231499e+308
#define TT_EPS_DOUBLE 2.225073858507203e-308


#define TT_MAXPTYPE TT_MAX_FLOAT
#define TT_MINPTYPE TT_MIN_FLOAT
#define TT_DATATYPE TFLOAT
#define TT_NO 1
#define TT_YES 0
#define TT_MAXKEYS 100
#define TT_MAXLIGNE 1024
#define TT_QSORT 10000
#define TT_LEN_VARNAME 255
#define TT_MAGNULL 999.
#define TT_LEN_SHORTFILENAME 30

#define TT_DUMMY 0
#define TT_SATYES -1
#define TT_SATNO 1
#define TT_STAR 1
#define TT_COSMIC 2
#define TT_SATURATED -3

#define TT_IMASERIES_SUB 1
#define TT_IMASERIES_ADD 2
#define TT_IMASERIES_OFFSET 3
#define TT_IMASERIES_COPY 4
#define TT_IMASERIES_DIV 5
#define TT_IMASERIES_FILTER 6
#define TT_IMASERIES_OPT 7
#define TT_IMASERIES_TRANS 8
#define TT_IMASERIES_STAT 9
#define TT_IMASERIES_DELETE 10
#define TT_IMASERIES_NORMGAIN 11
#define TT_IMASERIES_NORMOFFSET 12
#define TT_IMASERIES_OBJECTS 13
#define TT_IMASERIES_CATCHART 14
#define TT_IMASERIES_HEADERFITS 15
#define TT_IMASERIES_REGISTER 16
#define TT_IMASERIES_ASTROMETRY 17
#define TT_IMASERIES_UNSMEARING 18
#define TT_IMASERIES_INVERT 19
#define TT_IMASERIES_CONV 20
#define TT_IMASERIES_SUBDARK 21
#define TT_IMASERIES_RGRADIENT 22
#define TT_IMASERIES_HOUGH 23
#define TT_IMASERIES_BACK 24
#define TT_IMASERIES_TEST 25
#define TT_IMASERIES_RESAMPLE 26
#define TT_IMASERIES_CUTS 27
#define TT_IMASERIES_MULT 28
#define TT_IMASERIES_SORTX 29
#define TT_IMASERIES_SORTY 30
#define TT_IMASERIES_UNTRAIL 31
#define TT_IMASERIES_GEOSTAT 32
#define TT_IMASERIES_TILT 33
#define TT_IMASERIES_RADIAL 34
#define TT_IMASERIES_SMILEX 35
#define TT_IMASERIES_SMILEY 36
#define TT_IMASERIES_HOUGH_MYRTILLE 37
#define TT_IMASERIES_REGISTERFINE 38
#define TT_IMASERIES_PROD 39
#define TT_IMASERIES_FITELLIP 40
#define TT_IMASERIES_REPAIR_HOTPIXEL 41
#define TT_IMASERIES_REPAIR_COSMIC   42
#define TT_IMASERIES_RESIZE 43
#define TT_IMASERIES_CORNERS 44
#define TT_IMASERIES_CORONASUN 45

#define TT_KERNELTYPE_FH 0
#define TT_KERNELTYPE_FB 1
#define TT_KERNELTYPE_MED 2
#define TT_KERNELTYPE_MIN 3
#define TT_KERNELTYPE_MAX 4
#define TT_KERNELTYPE_MEAN 5
#define TT_KERNELTYPE_GRAD_LEFT 6
#define TT_KERNELTYPE_GRAD_RIGHT 7
#define TT_KERNELTYPE_GRAD_UP 8
#define TT_KERNELTYPE_GRAD_DOWN 9
#define TT_KERNELTYPE_MORLET 100
#define TT_KERNELTYPE_MEXICAN 101
#define TT_KERNELTYPE_GAUSSIAN 102

#define TT_IMASTACK_MOY 1
#define TT_IMASTACK_ADD 2
#define TT_IMASTACK_MED 3
#define TT_IMASTACK_SORT 4
#define TT_IMASTACK_KS 5
#define TT_IMASTACK_SIG 6
#define TT_IMASTACK_SHUTTER 7
#define TT_IMASTACK_PROD 8
#define TT_IMASTACK_PYTHAGORE 9
#define TT_IMASTACK_DRIZZLEWCS 10

#define TT_TBLPIX_X 0
#define TT_TBLPIX_Y 1
#define TT_TBLPIX_IDENT 2
#define TT_TBLPIX_TFIELDS 3 /* toujours en dernier */

#define TT_USNO 0
#define TT_USNOCOMP 1
#define TT_USNOPERSO 2


#define TT_REGITRANS_ONLY 0
#define TT_REGITRANS_BEFORE 1
#define TT_REGITRANS_AFTER 2
#define TT_REGITRANS_NEVER 3

#define TT_TBLOBJ_X 0
#define TT_TBLOBJ_Y 1
#define TT_TBLOBJ_IDENT 2
#define TT_TBLOBJ_FLUX 3
#define TT_TBLOBJ_RA 4
#define TT_TBLOBJ_DEC 5
#define TT_TBLOBJ_MAG 6
#define TT_TBLOBJ_BACKGROUND 7
#define TT_TBLOBJ_FWHMX 8
#define TT_TBLOBJ_FWHMY 9
#define TT_TBLOBJ_INTENSITY 10
#define TT_TBLOBJ_AB 11
#define TT_TBLOBJ_POSANGLE 12
#define TT_TBLOBJ_TFIELDS 13 /* toujours en dernier */

#define TT_TBLCAT_X 0
#define TT_TBLCAT_Y 1
#define TT_TBLCAT_IDENT 2
#define TT_TBLCAT_RA 3
#define TT_TBLCAT_DEC 4
#define TT_TBLCAT_MAGB 5
#define TT_TBLCAT_MAGV 6
#define TT_TBLCAT_MAGR 7
#define TT_TBLCAT_MAGI 8
#define TT_TBLCAT_TFIELDS 9 /* toujours en dernier */

#define TT_NBDIGITS_SHORT 6
#define TT_NBDIGITS_INT 11
#define TT_NBDIGITS_LONG 20
#define TT_NBDIGITS_FLOAT 15
#define TT_NBDIGITS_DOUBLE 23

#define TT_PI 3.1415926535897932384626433832795
#define TT_LN10 2.3025850929940456840179914546844

#define TT_SHUTTER_MODE_CLOSED 0
#define TT_SHUTTER_MODE_SYNCHRO 1
#define TT_SHUTTER_MODE_OPENED 2
#define TT_SHUTTER_MODE_SYNCHRO_WITHOUT_STARS 3

#define TT_FLAT_TYPE_NONE 0
#define TT_FLAT_TYPE_SIMPLE_VIGNETTING 1

#define TT_NEWSTAR_NONE 0
#define TT_NEWSTAR_ADD 1
#define TT_NEWSTAR_REPLACE 2

#define TT_SPLITMODE_ZONES 0
#define TT_SPLITMODE_NOZONE 1



/* --- definitions specifiques a l'OS pour l'appel de la fonction d'entree  ---*/
//#ifdef OS_WIN_VCPP_DLL
//#define libtt_main0 _libtt_main
//#else
//#define libtt_main0 libtt_main
//#endif

#ifdef OS_WIN_BORLB_DLL
#define FILE_DOS
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_WIN_VCPP_DLL
#define FILE_DOS
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_UNIX_CC
#define FILE_UNIX
#endif

#ifdef OS_UNIX_CC_HP_SL
#define FILE_UNIX
#endif

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
#define FILE_UNIX
#endif

#ifdef OS_DOS_WATC
#define FILE_DOS
#endif

#ifdef OS_DOS_WATC_LIB
#define FILE_DOS
#endif

#ifdef OS_LINUX_GCC_SO
#define FILE_UNIX
#endif

#ifdef OS_WIN_VCPP
#define FILE_DOS
#endif

/* --- defines de retour a la ligne des textes en fonction des OS ---*/
#ifdef FILE_UNIX
#define ENDFILE_JUMP -2
#else
#define ENDFILE_JUMP -3
#endif



/* --- derniers includes places ici pour ne pas interferer avec les OS ---*/
#include <math.h>

/* ======================================================================== */
/* ================ structures internes de 'dll_fits' ===================== */
/* ======================================================================== */

/* --- Switch pour compiler avec ou sans la distorsion pour l'astrometrie ---*/
/* --- Active par RZ selon indication RD ---*/
#define TT_OLD_ASTROM

/* --- Switch pour compiler avec ou sans la distorsion pour l'astrometrie ---*/
/* --- #define TT_DISTORASTROM ---*/

/* --- Mouchard de pointeurs pour le debug ---*/
//#define TT_MOUCHARDPTR

#ifdef TT_MOUCHARDPTR
typedef struct {
   char varname[100];
   int nballoc;
   unsigned int address;
} TT_MOUCHARD;
#endif

/* --- lecture des fichiers d'etoiles .lst ---*/
typedef struct {
   double x;
   double y;
   double mag;
   short flag;
} TT_XYMAG;

/* --- lecture du catalogue Sextractor  Thiebaut ---*/
typedef struct {
	short flag;
	double flux;
	double errflux;
	double mag;
	double errmag;
	double backgnd;
	double x;
	double y;
	double x2;
	double y2;
	double xy;
	double a_ellipse;
	double b_ellipse;
	double theta;
	double fwhm;
	double flag_sext;
	double classstar;
} TT_LISTSEXT;

/* --- lecture du catalogue USNO ---*/
typedef struct {
   unsigned long ra;
   unsigned long dec;
   unsigned long divers;
} usnotype;

/* --- lecture du catalogue USNO compresse ---*/
typedef struct {
   unsigned long ra;
   unsigned long dec;
   unsigned char magr;
   unsigned char magb;
} usnocomptype;

typedef struct {
   double a[6];
} TT_COEFA;

/* --- Lecture USNO methode Buil */
typedef struct {
   int flag;
   int indexRA;
   int indexSPD;
   int offset;
   int nbObjects;
} TT_USNO_INDEX;

/* --- informations sur la transformation carte-image --- */
typedef struct {
   int valid;
	/* === public ===*/
   /* ----- coordinates --- */
   double crpix1; // "X pole along NAXIS1" "pix"
   double crpix2; // "Y pole along NAXIS2" "pix"
   double crval1; // "alpha pole" "deg"
   double crval2; // "delta pole" "deg"
	char equinox[20];  // J2000
	char radecsys[20]; // FK5
   /* ----- scale --- */
   double cdelt1; // "X scale" "deg/pix"
   double cdelt2; // "Y scale" "deg/pix"
   double crota2; // "rotation" "deg"
   double cd11; // "CD matrix 11" "deg/pix"
   double cd12; // "CD matrix 12" "deg/pix"
   double cd21; // "CD matrix 21" "deg/pix"
   double cd22; // "CD matrix 22" "deg/pix"
	/* --- public+ ---*/
	int wcsaxes; // "WCS dimensionality" ""
	double lonpole; // "Long. of the celest.NP in native coor.syst." deg
	char ctype1[20]; // "Gnomonic projection" ""
	char ctype2[20]; // "Gnomonic projection" ""
	char cunit1[20]; // "Angles are degrees always" ""
	char cunit2[20]; // "Angles are degrees always" ""
	/* === private ===*/
	double pi; // "Pi number" ""
	double dr; // "deg->rad factor" ""
	double phip; // "Phi pole gnomonic" "rad"
	double r1; // "X pole along NAXIS1" "pix"
	double r2; // "Y pole along NAXIS2" "pix"
	double rap; // "alpha pole" "rad"
	double decp; // "delta pole" "rad"
	double cosdecp; // "cos delta pole" ""
	double sindecp; // "sin delta pole" ""
	double sm11; // "CD matrix 11" "rad/pix"
	double sm12; // "CD matrix 12" "rad/pix"
	double sm21; // "CD matrix 21" "rad/pix"
	double sm22; // "CD matrix 22" "rad/pix"
	/* --- apparent parameters --- */
	char date[30]; // "Date of mid exposure" "JD"
	char home[30]; // home  $home private "Home" "GPS"
	double pressure_Pa; // "Atm. Pressure" "Pa"
	double temperature_K; // "Atm. Temperature" "K"
	double humidity_percent; // "Atm. humidity" "percent"
	double wavelength_nm; // "Wavelength" "nm"
	/* --- optic ---*/
   double foclen; /* focale en m*/
   double pixsize1;     /* pixel en m */
   double pixsize2;
   double dec0;
   double ra0;
   /*-----*/
   int pv_valid;
   double pv[3][11];
} TT_WCS;

typedef struct {
   double foclen; /* focale en m*/
   double px;     /* pixel en m */
   double py;
   double crota2;
   double cd11;
   double cd12;
   double cd21;
   double cd22;
   double crpix1;
   double crpix2;
   double crval1;
   double crval2;
   double cdelta1;
   double cdelta2;
   double dec0;
   double ra0;
   int pv_valid;
   double pv[3][11];
	TT_WCS wcs;
} TT_ASTROM;

/* --- informations sur la nature d'une table de pixels --- */
typedef struct {
   /* --- table a ete chargee ---*/
   char load_path[FLEN_FILENAME];
   char load_name[FLEN_FILENAME];
   char load_suffix[FLEN_FILENAME];
   char load_fullname[FLEN_FILENAME];
   int load_typehdu;
   int load_hdunum;
   /* --- table qui a ete sauvee ---*/
   char save_path[FLEN_FILENAME];
   char save_name[FLEN_FILENAME];
   char save_suffix[FLEN_FILENAME];
   char save_fullname[FLEN_FILENAME];
   int save_typehdu;
   int save_hdunum;
   /* --- pour la description de la table ---*/
   char extname[FLEN_VALUE];
   double extver;
   /* --- pour la description des champs de la table ---*/
   int tfields;     /* nombre de colonnes (=nombre de champ) */
   char **tform;    /* formatage de chaque colonne (=de chaque champ) */
   char **ttype;    /* intitule de chaque colonne (=de chaque champ) */
   char **tunit;    /* unite physique de chaque colonne (=de chaque champ) */
   /* --- pour la description des donnees de la table ---*/
   long nrows;      /* nombre de lignes dans chaque colonne (=champ) */
   int *datatypes;  /* type des donnees de chaque colonne (=champ) */
   double *x;       /* liste des coordonnees x */
   double *y;       /* liste des coordonnees y */
   short *ident;    /* liste d'identification */
			 /* <0 saturated */
			 /* =0 dummy TT_DUMMY */
			 /* =1 star  TT_STAR TT_SATSTAR */
			 /* =2 cosmic TT_COSMIC TT_SATCOSMIC */
} TT_TBL_PIXELIST ;

/* --- informations sur la nature d'une table d'objets --- */
typedef struct {
   /* --- table a ete chargee ---*/
   char load_path[FLEN_FILENAME];
   char load_name[FLEN_FILENAME];
   char load_suffix[FLEN_FILENAME];
   char load_fullname[FLEN_FILENAME];
   int load_typehdu;
   int load_hdunum;
   /* --- table qui a ete sauvee ---*/
   char save_path[FLEN_FILENAME];
   char save_name[FLEN_FILENAME];
   char save_suffix[FLEN_FILENAME];
   char save_fullname[FLEN_FILENAME];
   int save_typehdu;
   int save_hdunum;
   /* --- pour la description de la table ---*/
   char extname[FLEN_VALUE];
   double extver;
   /* --- pour la description des champs de la table ---*/
   int tfields;     /* nombre de colonnes (=nombre de champ) */
   char **tform;    /* formatage de chaque colonne (=de chaque champ) */
   char **ttype;    /* intitule de chaque colonne (=de chaque champ) */
   char **tunit;    /* unite physique de chaque colonne (=de chaque champ) */
   /* --- pour la description des donnees de la table ---*/
   long nrows;      /* nombre de lignes dans chaque colonne (=champ) */
   int *datatypes;  /* type des donnees de chaque colonne (=champ) */
   double *x;       /* liste des coordonnees x */
   double *y;       /* liste des coordonnees y */
   short *ident;    /* liste d'identification */
   double *flux;
   double *ra;      /* liste des coordonnees ra 2000 */
   double *dec;     /* liste des coordonnees dec 2000 */
   double *mag;     /* magnitude */
   double *background;
   double *fwhmx;
   double *fwhmy;
   double *intensity;
   double *ab;
   double *posangle;
} TT_TBL_OBJELIST ;

/* --- informations sur la nature des tables Ascii --- */
typedef struct {
   /* --- table de travail qui a ete chargee ---*/
   char load_path[FLEN_FILENAME];
   char load_name[FLEN_FILENAME];
   char load_suffix[FLEN_FILENAME];
   char load_fullname[FLEN_FILENAME];
   int load_typehdu;
   int load_hdunum;
   /* --- table de travail qui a ete sauvee ---*/
   char save_path[FLEN_FILENAME];
   char save_name[FLEN_FILENAME];
   char save_suffix[FLEN_FILENAME];
   char save_fullname[FLEN_FILENAME];
   int save_typehdu;
   int save_hdunum;
   /* --- table de reference pour l'entete ---*/
   char ref_path[FLEN_FILENAME];
   char ref_name[FLEN_FILENAME];
   char ref_suffix[FLEN_FILENAME];
   char ref_fullname[FLEN_FILENAME];
   int ref_typehdu;
   int ref_hdunum;
   /* --- mots cles dans la table de travail ---*/
   int keyused; /* flag qui signale si les pointeurs ont ete alloues */
   int nbkeys;
   char **keynames;
   char **values;
   char **comments;
   char **units;
   int *datatypes;
   /* --- mots cles dans la table de reference pour l'entete ---*/
   int ref_keyused; /* flag qui signale si les pointeurs ont ete alloues */
   int ref_nbkeys;
   char **ref_keynames;
   char **ref_values;
   char **ref_comments;
   char **ref_units;
   int *ref_datatypes;
   /* --- nouveaux mots cles a ajouter dans la table de travail ---*/
   int new_keyused; /* flag qui signale si les pointeurs ont ete alloues */
   int new_nbkeys;
   char **new_keynames;
   char **new_values;
   char **new_comments;
   char **new_units;
   int *new_datatypes;
   /* --- valeur de la derniere de l'indice du mot cle TT ---*/
   int last_tt;
   /* --- definition de la table ---*/
   char **p; /* table ascii contenant les donnees */
   int *tbldatatypes; /* datatype du type : TDOUBLE, etc... */
   int tfields;
   int naxis2;
   long firstelem;
   long nelements;
   char **tform; /* idem que la norme Fits */
   char **tunit; /* idem que la norme Fits */
   char **ttype; /* idem que la norme Fits */
} TT_TBL;

/* --- informations sur la nature d'une table de catalogue --- */
typedef struct {
   /* --- table a ete chargee ---*/
   char load_path[FLEN_FILENAME];
   char load_name[FLEN_FILENAME];
   char load_suffix[FLEN_FILENAME];
   char load_fullname[FLEN_FILENAME];
   int load_typehdu;
   int load_hdunum;
   /* --- table qui a ete sauvee ---*/
   char save_path[FLEN_FILENAME];
   char save_name[FLEN_FILENAME];
   char save_suffix[FLEN_FILENAME];
   char save_fullname[FLEN_FILENAME];
   int save_typehdu;
   int save_hdunum;
   /* --- pour la description de la table ---*/
   char extname[FLEN_VALUE];
   double extver;
   /* --- pour la description des champs de la table ---*/
   int tfields;     /* nombre de colonnes (=nombre de champ) */
   char **tform;    /* formatage de chaque colonne (=de chaque champ) */
   char **ttype;    /* intitule de chaque colonne (=de chaque champ) */
   char **tunit;    /* unite physique de chaque colonne (=de chaque champ) */
   /* --- pour la description des donnees de la table ---*/
   long nrows;      /* nombre de lignes dans chaque colonne (=champ) */
   int *datatypes;  /* type des donnees de chaque colonne (=champ) */
   double *x;       /* liste des coordonnees x */
   double *y;       /* liste des coordonnees y */
   short *ident;    /* liste d'identification */
   double *ra;      /* liste des coordonnees ra 2000 */
   double *dec;     /* liste des coordonnees dec 2000 */
   double *magb;    /* magnitude b*/
   double *magv;    /* magnitude v*/
   double *magr;    /* magnitude r*/
   double *magi;    /* magnitude i*/
} TT_TBL_CATALIST ;

/* --- informations pour fitellip LAPS --- */
typedef struct {
   double surmag;
   double r25;
   double xce;
   double yce;
   double csa;
   double a;
   double angp;
   double x2;
   double y2;
   double xy;
   double xmn;
   double ap2;
   double ag2;
   double xmn2;
   double xce1;
   double yce1;
   double al;
   double poww;
   int    isoph;
   long   ncount;
   double base[34];
} TT_LAPS;

/* --- informations sur la nature des images --- */
typedef struct {
   /* --- image de travail qui a ete chargee ---*/
   char load_path[FLEN_FILENAME];
   char load_name[FLEN_FILENAME];
   char load_suffix[FLEN_FILENAME];
   char load_fullname[FLEN_FILENAME];
   int load_typehdu;
   int load_hdunum;
   /* --- image de travail qui a ete sauvee ---*/
   char save_path[FLEN_FILENAME];
   char save_name[FLEN_FILENAME];
   char save_suffix[FLEN_FILENAME];
   char save_fullname[FLEN_FILENAME];
   int save_typehdu;
   int save_hdunum;
   /* --- image de reference pour l'entete ---*/
   char ref_path[FLEN_FILENAME];
   char ref_name[FLEN_FILENAME];
   char ref_suffix[FLEN_FILENAME];
   char ref_fullname[FLEN_FILENAME];
   int ref_typehdu;
   int ref_hdunum;
   /* --- mots cles dans l'image de travail ---*/
   int keyused; /* flag qui signale si les pointeurs ont ete alloues */
   int nbkeys;
   char **keynames;
   char **values;
   char **comments;
   char **units;
   int *datatypes;
   /* --- mots cles dans l'image de reference pour l'entete ---*/
   int ref_keyused; /* flag qui signale si les pointeurs ont ete alloues */
   int ref_nbkeys;
   char **ref_keynames;
   char **ref_values;
   char **ref_comments;
   char **ref_units;
   int *ref_datatypes;
   /* --- nouveaux mots cles a ajouter dans l'image de travail ---*/
   int new_keyused; /* flag qui signale si les pointeurs ont ete alloues */
   int new_nbkeys;
   char **new_keynames;
   char **new_values;
   char **new_comments;
   char **new_units;
   int *new_datatypes;
   /* --- valeur de la derniere de l'indice du mot cle TT ---*/
   int last_tt;
   /* --- definition de l'image ---*/
   TT_PTYPE *p;
   int datatype;
   int naxis;
   int naxis1;
   int naxis2;
   int naxis3;
   long firstelem;
   long nelements;
   long *naxes;
   int load_bitpix;
   int save_bitpix;
   /* --- definition de la liste d'objets ---*/
   char objekey[FLEN_VALUE];
   char objelist_fullname[FLEN_FILENAME];
   TT_TBL_OBJELIST *objelist;
   /* --- definition de la liste de pixels ---*/
   char pixekey[FLEN_VALUE];
   char pixelist_fullname[FLEN_FILENAME];
   TT_TBL_PIXELIST *pixelist;
   /* --- definition de la liste de catalogue ---*/
   char catakey[FLEN_VALUE];
   char catalist_fullname[FLEN_FILENAME];
   TT_TBL_CATALIST *catalist;
} TT_IMA;

/* --- pour la fonction ima/stack --- */
typedef struct {
   TT_IMA *p_in;
   TT_IMA *p_tmp;
   TT_IMA *p_tmpout;
   TT_IMA *p_out;
   char tmp_dir[FLEN_FILENAME];
   long firstelem;
   long nelements;
   long nelem;
   long nelem0;
   int nbima;
   int bitpix;
   //int nbkeys;
   int splitmode;
   int kima;
   TT_ASTROM p_ast;
   int numfct; /* numero de la fonction */
   double *poids;
   double *exptimes;
   double percent;
   double kappa;
   int nullpix_exist;
   double nullpix_value;
   char jpegfile[FLEN_FILENAME];
   int jpegfile_make;
   int jpeg_qualite;
   int powernorm;
   int *hotPixelList;
   double drop_pixsize;
   double oversampling;
   double xcenter;
   double ycenter;
   double radius;
   TT_PTYPE cosmicThreshold;
   TT_USER1_IMA_STACK user1;
   TT_USER2_IMA_STACK user2;
   TT_USER3_IMA_STACK user3;
   TT_USER4_IMA_STACK user4;
   TT_USER5_IMA_STACK user5;
} TT_IMA_STACK;



/* --- pour la fonction ima/series --- */
typedef struct {
   /* --- parametres communs accessibles a l'utilisateur (public) ---*/
   TT_IMA *p_in;
   TT_IMA *p_tmp1;
   TT_IMA *p_tmp2;
   TT_IMA *p_tmp3;
   TT_IMA *p_tmp4;
   TT_IMA *p_out;
   char tmp_dir[FLEN_FILENAME];
   double *jj;
   double *poids;
   double *exptime;
   double exptime_stack;
   double jj_stack;
   long firstelem;
   long nelements;
   int nbima;
   int bitpix;
   //int nbkeys;
   int index;
   int numfct; /* numero de la fonction */
   long naxis1_1;
   long naxis2_1;
   char fullname0[FLEN_FILENAME];
   /* --- parametres specifiques accessibles a l'utilisateur (public) ---*/
   double offset;
   char catafile[FLEN_FILENAME];
   char jpegfile[FLEN_FILENAME];
   char jpegfile_chart[FLEN_FILENAME];
   char jpegfile_chart2[FLEN_FILENAME];
   char objefile[FLEN_FILENAME];
   char objefiletype[50];
   char pixefile[FLEN_FILENAME];
   char file[FLEN_FILENAME];
   char dark[FLEN_FILENAME];
   char bias[FLEN_FILENAME];
   char flat[FLEN_FILENAME];
   char file_ascii[FLEN_FILENAME];
   char centroide[20];
   double constant;
   double threshold;
   double exposure;
   char nom_trait[20];
   char struct_elem[20];
   int type_threshold;
   int kernel_width;
   int kernel_type;
   double kernel_coef;
   double therm_kappa;
   double trans_x;
   double trans_y;
   double pixelsat_value;
   int pixelsat_compute;
   int fwhm_compute;
   int skylevel_compute;
   double normgain_value;
   double normoffset_value;
   char path_astromcatalog[FLEN_FILENAME];
   char astromcatalog[FLEN_FILENAME];
   int pixel_list;
   int object_list;
   int catalog_list;
   int regitrans;
   int nullpix_exist;
   double nullpix_value;
   int jpegfile_make;
   int jpegfile_chart_make;
   int jpegfile_chart2_make;
   int sigma_given;
   double sigma_value;
   double epsilon;
   double delta;
   char key_exptime[FLEN_KEYWORD];
   char key_dexptime[FLEN_KEYWORD];
   double xcenter;
   double ycenter;
   double radius;
   double angle;
   int back_kernel;
   double back_threshold;
   int sub_yesno;
   int div_yesno;
   double normaflux;
   char paramresample[TT_PARAMRESAMPLE];
   int jpeg_qualite;
   double magrlim;
   double magblim;
   int nbsubseries;
   char keyhicut[FLEN_KEYWORD];
   char keylocut[FLEN_KEYWORD];
   char keytype[FLEN_KEYWORD];
   double hifrac;
   double lofrac;
   double cutscontrast;
   double percent;
   int x1;
   int x2;
   int y1;
   int y2;
   int width;
   int height;
   int pixint;
   int length;
   int matchwcs;
   double coef_smile2;
   double coef_smile4;
   int oversampling;
   double background;
   int fitorder6543;
	int simulimage;
	char colfilter[20];
	double fwhmx;
	double fwhmy;
	double quantum_efficiency;
	double sky_brightness;
	double gain;
	double teldiam;
	double readout_noise;
	double tatm;
	double topt;
	double elecmult;
	int shuttermode;
	double biaslevel;
	int flattype;
	int shutter_mode;
	double bias_level;
	int flat_type;
	double thermic_response;
	int newstar;
	double ra;
	double dec;
	double mag;
   /* --- parametres internes (private) ---*/
   double binary_yesno;
   double val_exptime;
   double val_dexptime;
   double therm_mean;
   double therm_sigma;
   double coef_therm;
   int nbpix_therm;
   double mean;
   double sigma;
   double mini;
   double maxi;
   int nbpixsat;
   double bgmean;
   double bgsigma;
   double hicut;
   double locut;
   double contrast;
   int nbstars;
   double power;
   double fwhm;
   double d_fwhm;
   TT_COEFA *coefa;
   TT_ASTROM p_ast;
   int nbmatched;
   double coef_unsmearing;
   double detect_kappa;
   double bordure;
   int invert_flip;
   int invert_mirror;
   int invert_xy;
   int outnaxis1;
   int outnaxis2;
   int index_out;
   //int nbimages;
   double fwhmsat;
   int *hotPixelList;
   TT_PTYPE cosmicThreshold;
   TT_USER1_IMA_SERIES user1;
   TT_USER2_IMA_SERIES user2;
   TT_USER3_IMA_SERIES user3;
   TT_USER4_IMA_SERIES user4;
   TT_USER5_IMA_SERIES user5;
} TT_IMA_SERIES;

/* ======================================================================== */
/* ======================== declaration des fonctions ===================== */
/* ======================================================================== */
void tt_fitgauss2d(int sizex, int sizey,double **y,double *p,double *ecart);

int tt_ptr_loadima(void *args);
int tt_ptr_freekeys(void *args);
int tt_ptr_freeptr(void *args);
int tt_ptr_savejpg(void *args);
int tt_ptr_savejpgcolor(void *args);
int tt_ptr_saveima(void *args);
int tt_ptr_savekeys(void *args);
int tt_ptr_statima(void *args);
int tt_ptr_cutsima(void *args);
int tt_ptr_allokeys(void *args);
int tt_ptr_loadkeys(void *args);
int tt_ptr_saveima3d(void *args);
int tt_ptr_loadima3d(void *args);
int tt_ptr_saveima1d(void *args);
int tt_ptr_saveimakeydim(void *args);

int tt_ptr_imaseries(void *args);

void tt_free(void *ptr,char *name);
void *tt_calloc(int nombre,int taille);
void *tt_malloc(int taille);
int tt_util_mouchard(char *nomptr,int increment,unsigned int address);
int tt_util_calloc_ptr2(void **args);
int tt_util_calloc_ptrptr_char2(void **args);
int tt_util_calloc_ptrptr_char(void **arg1,void *arg2,void *arg3);
int tt_util_calloc_ptr_datatype(void **arg1,void *arg2,void *arg3);
int tt_util_datatype_bytes(void *arg1, void *arg2);
int tt_util_put_datatype(void *arg1,void *arg2,void *arg3);
int tt_util_bitpix2datatype(void *arg1,void *arg2);
int tt_util_free_ptr(void *arg1);
int tt_util_free_ptrptr(void **ptr,char *name);
int tt_util_ttima2ptr(TT_IMA *p_in,void *array,int datatype,int iaxis3);
int tt_util_ptr2ttima(void *array,int datatype,TT_IMA *p_out);
void tt_free2(void **ptr,char *name);
int tt_util_free_ptrptr2(void ***ptr,char *name);
int tt_util_tmp_dir(void *arg1);

int tt_dateobs_convert(char *date_obs, char *time_obs, char *new_date_obs);
void tt_jd2dateobs(double jj, char *date);
void tt_dateobs2jd(char *date, double *jj);
void tt_jd2date(double jj, int *annee, int *mois, double *jour);
void tt_date2jd(int annee, int mois, double jour, double *jj);
int tt_dateobs_release(TT_IMA *p,int numlist);
int tt_ima2jd(TT_IMA *p,int numlist,double *jd);
int tt_ima2exposure(TT_IMA *p,int numlist,double *exposure);

int tt_fct_ima_series(void *arg1);


int tt_ima_series_saver_end(TT_IMA_SERIES *pseries,char *fullname);
int tt_ima_series_loader_0(TT_IMA_SERIES *pseries,char *fullname);
int tt_ima_series_sub_1(TT_IMA_SERIES *pseries);
int tt_ima_series_add_1(TT_IMA_SERIES *pseries);
int tt_ima_series_offset_1(TT_IMA_SERIES *pseries);
int tt_ima_series_copy_1(TT_IMA_SERIES *pseries);
int tt_ima_series_mult_1(TT_IMA_SERIES *pseries);
int tt_ima_series_div_1(TT_IMA_SERIES *pseries);
int tt_ima_series_filter_1(TT_IMA_SERIES *pseries);
int tt_ima_series_opt_1(TT_IMA_SERIES *pseries);
int tt_ima_series_unsmearing_1(TT_IMA_SERIES *pseries);
int tt_ima_series_untrail_1(TT_IMA_SERIES *pseries);
int tt_ima_series_trans_1(TT_IMA_SERIES *pseries);
int tt_ima_series_conv_1(TT_IMA_SERIES *pseries);
int tt_ima_series_invert_1(TT_IMA_SERIES *pseries);
int tt_ima_series_invert_2(TT_IMA_SERIES *pseries);
int tt_ima_series_subdark_1(TT_IMA_SERIES *pseries);
int tt_ima_series_rgradient_1(TT_IMA_SERIES *pseries);
int tt_ima_series_hough_1(TT_IMA_SERIES *pseries);
int tt_ima_series_back_1(TT_IMA_SERIES *pseries);
int tt_ima_series_test_1(TT_IMA_SERIES *pseries);
int tt_ima_series_resample_1(TT_IMA_SERIES *pseries);
int tt_ima_series_radial_1(TT_IMA_SERIES *pseries);
int tt_ima_series_prod_1(TT_IMA_SERIES *pseries);
int tt_ima_series_fitellip_1(TT_IMA_SERIES *pseries);
int tt_ima_series_hotpixel_1(TT_IMA_SERIES *pseries);
int tt_ima_series_cosmic_1(TT_IMA_SERIES *pseries);
int tt_ima_series_resize_1(TT_IMA_SERIES *pseries);
int tt_ima_series_corners_1(TT_IMA_SERIES *pseries);
int tt_ima_series_coronasun_1(TT_IMA_SERIES *pseries);

int tt_ima_series_tilt_1(TT_IMA_SERIES *pseries);
int tt_ima_series_smilex_1(TT_IMA_SERIES *pseries);
int tt_ima_series_smiley_1(TT_IMA_SERIES *pseries);
int tt_ima_series_register_1(TT_IMA_SERIES *pseries);
int tt_ima_series_registerfine_1(TT_IMA_SERIES *pseries);
int tt_ima_series_astrometry_1(TT_IMA_SERIES *pseries);
int tt_ima_series_stat_1(TT_IMA_SERIES *pseries);
int tt_ima_series_geostat_1(TT_IMA_SERIES *pseries);
int tt_ima_series_cuts_1(TT_IMA_SERIES *pseries);
int tt_ima_series_normgain_1(TT_IMA_SERIES *pseries);
int tt_ima_series_normoffset_1(TT_IMA_SERIES *pseries);
int tt_ima_series_objects_1(TT_IMA_SERIES *pseries);

int tt_ima_series_sortx_1(TT_IMA_SERIES *pseries);
int tt_ima_series_sorty_1(TT_IMA_SERIES *pseries);

int tt_ima_series_catchart_1(TT_IMA_SERIES *pseries);
int tt_ima_series_catchart_2(TT_IMA_SERIES *pseries);
void tt_ComputeUsnoIndexs(double ra,double de,int *indexSPD,int *indexRA);
int tt_Big2LittleEndianLong(int l);
double tt_GetUsnoRedMagnitude(int magL);
double tt_GetUsnoBleueMagnitude(int magL);
double tt_R2D(double a);
double tt_D2R(double a);
int tt_ima_series_headerfits_1(TT_IMA_SERIES *pseries);

int tt_util_dellastchar(char *chaine);
int tt_util_listpixima(TT_IMA *p,TT_IMA_SERIES *pseries);
int tt_util_listpixima2(TT_IMA *p,TT_IMA_SERIES *pseries,int method,int *npix,int *nobj);
int tt_util_contrast(TT_IMA *p,double *contrast);
int tt_util_histocuts(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,double *mode,double *mini,double *maxi);
int tt_util_histocuts2b(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode,double *minim,double *maxim);
int tt_util_cuts(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,int dejastat);
int tt_util_cuts2(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode);
int tt_util_cuts2b(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode);
int tt_util_bgk(TT_IMA *p,double *bgmean,double *bgsigma);
int tt_util_statima(TT_IMA *p,double pixelsat_value,double *mean,double *sigma,double *mini,double *maxi,int *nbpixsat);
int tt_util_geostat(TT_IMA *p,char *filename,double fwhmsat,double seuil,double xc0, double yc0, double radius, int *nbsats, char centoide[10]);
int tt_util_qsort_double(double *x,int kdeb,int n,int *index);
int tt_util_qsort_verif(int index);
int tt_util_meansigma(double *x,int kdeb,int n,double *mean,double *sigma);
int tt_util_chercher_trainee(TT_IMA *pin,TT_IMA *pout,char *filename,double fwhmsat,double seuil,double seuila,double xc0, double yc0,double exposure);

int tt_util_putnewkey_astrometry(TT_IMA *p_ima,TT_ASTROM *p_ast);
int tt_util_getkey_astrometry(TT_IMA *p_ima,TT_ASTROM *p_ast);
int tt_util_getkey0_astrometry(TT_IMA *p_ima,TT_ASTROM *p_ast,int *valid);
int tt_astrom_release(TT_IMA *p);
int tt_wcs_update_optic(TT_WCS *wcs,int is_foclen,int is_pixsize1,int is_pixsize2);
int tt_wcs_cdelt2cd(TT_WCS *wcs);
int tt_wcs_cd2cdelt(TT_WCS *wcs); 
int tt_wcs_builder(TT_WCS *wcs);
int tt_util_set_pv(TT_IMA *p_out,double *a,double *b,TT_ASTROM *p_ast);
int tt_util_update_wcs(TT_IMA *p_in,TT_IMA *p_out,double *a,int method,TT_ASTROM *p_ast);
int tt_util_cd2cdelt_old(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2);
int tt_util_cd2cdelt_new(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2);
int tt_util_get_new_wcs_crval(TT_IMA *p_in,double *a,TT_ASTROM *p,int *valid);
int tt_util_get_new_wcs_crpix(TT_IMA *p_in,double *a,TT_ASTROM *p,int *valid);
int tt_util_astrom_xy2radec(TT_ASTROM *p, double x,double y,double *ra,double *dec);
int tt_util_astrom_radec2xy(TT_ASTROM *p,double ra,double dec, double *x,double *y);
int tt_util_astrom_radec2p(TT_ASTROM *p,double ra,double dec, double *x,double *y);
int tt_util_astrom_p2radec(TT_ASTROM *p, double x,double y,double *ra,double *dec);
int tt_util_astrom_zoneusno(double ra,double dec,char *numzone,int *num_ligne);
void tt_util_uswapbytes(unsigned long* ptr, int n);
int tt_util_transima1(TT_IMA_SERIES *pseries,double trans_x,double trans_y);
int tt_util_regima1(TT_IMA_SERIES *pseries);
int tt_util_match_translate(TT_IMA *p_ref,TT_IMA *p_in,double *a,int *nbmatched);
int tt_util_matrice_inverse_bilinaire(double *a, double *b);

int tt_laps_analyse(TT_IMA *p_in,TT_IMA *p_out,double xc,double yc,double ciel,double cmag,double scale,double forme,int ordre3,int ordre4,int ordre5,int ordre6,double pgposang,int xd,int xf,int yd,int yf,double saturation, char *file_out,double *radius_max_analyse, double *radius_coeur,double *radius_effective,double *magnitude_totale,double *magnitude_asymptotique,double *brillance_effective,double *brillance_centrale);

int tt_fct_ima_stack(void *arg1);


int tt_ima_stack_moy_1(TT_IMA_STACK *pstack);
int tt_ima_stack_sig_1(TT_IMA_STACK *pstack);
int tt_ima_stack_add_1(TT_IMA_STACK *pstack);
int tt_ima_stack_med_1(TT_IMA_STACK *pstack);
int tt_ima_stack_sort_1(TT_IMA_STACK *pstack);
int tt_ima_stack_sk_1(TT_IMA_STACK *pstack);
int tt_ima_stack_shutter_1(TT_IMA_STACK *pstack);
int tt_ima_stack_prod_1(TT_IMA_STACK *pstack);
int tt_ima_stack_pythagore_1(TT_IMA_STACK *pstack);
int tt_ima_stack_drizzlewcs_1(TT_IMA_STACK *pstack);

int tt_decodekeys(char *ligne,void ***outkeys,int *numkeys);
int tt_strupr(char *chaine);
int tt_valid_filename(char *filename);
int tt_verifargus_getFileNb(char *fileNames );
int tt_verifargus_getFileName(char *fileNames, int fileIndex , char* fileName);
int tt_verifargus_1indice(char **keys,int deb,int *level_index,int *indice_deb);
int tt_verifargus_2indices(char **keys,int deb,int *level_index,int *indice_deb,int *indice_fin);
char *tt_indeximafilecater(char *path, char *name, int index,char *suffix);
int tt_parseHotPixelList(char* sHotPixels,int **iHotPixels);
int tt_repairHotPixel(int *iHotPixels, TT_IMA *p);
int tt_repairCosmic(TT_PTYPE cosmicThreshold, TT_IMA *p);

int tt_script_2(void *arg1);
int tt_script_3(void *arg1);

int tt_test(void *arg1);

int tt_writelog(char *tmp_dir,char *message);
int tt_errlog(char *tmp_dir,int numerreur,char *messageFormat,...);
int tt_errmessage(void *args);
int tt_errmessage2(int numerreur,char *message);
int tt_lasterrmessage(void *args);
double tt_atan2(double y, double x);

int tt_imabuilder(TT_IMA *p);
int tt_imaloader(TT_IMA *p,char *fullname,long firstelem,long nelements);
int tt_imasaver(TT_IMA *p,char *fullname,int bitpix);
int tt_imacreater(TT_IMA *p,int naxis1,int naxis2);
int tt_imadestroyer(TT_IMA *p);
int tt_imafilenamespliter(char *fullname,char *path,char *name,char *suffix,int *hdunum);
int tt_values2values(char *value_string,char *value,int datatype);
char *tt_imafilecater(char *path, char *name, char *suffix);
int tt_imanewkey(TT_IMA *p,char *keyname,void *value,int datatype,char *comment,char *unit);
int tt_imanewkeychar(TT_IMA *p,char *keyname,char *value,int datatype,char *comment,char *unit);
int tt_imarefheader(TT_IMA *p,char *fullname);
int tt_imanewkeytt(TT_IMA *p,char *value,char *comment,char *unit);
int tt_imalistkeys(TT_IMA *p,int *nkeys,void ***pkeynames,void ***pvalues,void ***pcomments,void ***punits,void **pdatatypes);
int tt_imalistallkeys(TT_IMA *p,int *nkeys,void ***pkeynames,void ***pvalues,void ***pcomments,void ***punits,void **pdatatypes);
int tt_imadelnewkey(TT_IMA *p,char *keyname);
int tt_imareturnkeyvalue(TT_IMA *p,char *keyname,char *value,int *datatype,char *comment,char *unit);
int tt_imacreater3d(TT_IMA *p,int naxis1,int naxis2,int naxis3);
int tt_imacreater1d(TT_IMA *p,int naxis1);
int tt_imareallocnewkey(TT_IMA *p,int nbkeys2add);

int tt_tblobjloader(TT_IMA *p_ima,char *fullname);
int tt_tblobjbuilder(TT_TBL_OBJELIST *p);
int tt_tblobjcreater(TT_TBL_OBJELIST *p,int nrows);
int tt_tblobjdestroyer(TT_TBL_OBJELIST *p);
int tt_tblobjsaver(TT_IMA *p_ima,char *fullname);

int tt_tblpixbuilder(TT_TBL_PIXELIST *p);
int tt_tblpixcreater(TT_TBL_PIXELIST *p,int nrows);
int tt_tblpixdestroyer(TT_TBL_PIXELIST *p);

int tt_tblcatloader(TT_IMA *p_ima,char *fullname);
int tt_tblcatbuilder(TT_TBL_CATALIST *p);
int tt_tblcatcreater(TT_TBL_CATALIST *p,int nrows);
int tt_tblcatdestroyer(TT_TBL_CATALIST *p);
int tt_tblcatsaver(TT_IMA *p_ima,char *fullname);

int tt_util_focas0(TT_IMA *p_in,double epsilon, double delta, double threshold, double *a,double *b,int *nb,double *cmag0,double *d_cmag0,double *a2,double *b2,int *nb2);
int tt_util_focas1(TT_IMA *p_ref,TT_IMA *p_in,double *a,double *b,int *nb,int flagtrans);
int tt_util_fichs_comdif(TT_ASTROM *p_ast,double cmag, char *nomfic_all,char *nomfic_com,char *nomfic_dif,char *nomfic_ascii,char *typefic_com);

int tt_poissonian_cdf(double *repartitionps,int nk,int kmax,int nl,double lambdamax);
double tt_poissonian_rand(double lambda,double *repartitionps,int nk,int kmax,int nl,double lambdamax,double *repartitiongs,int n,double sigmax);
int tt_gaussian_cdf(double *repartitions,int n,double sigmax);
double tt_gaussian_rand(double *repartitions,int n,double sigmax);
int tt_thermic_signal(TT_PTYPE *p,long nelem,double response);
double tt_flat_response(int naxis1, int naxis2, double x, double y, int flat_type);

int tt_valid_dirname(char *dirname);

void tt_internal_erreur(int msg);

int tt_tbldatainfos(char **table,int tfields,int *naxis2,int *nbcars);
int tt_tbllistkeys(TT_TBL *p,int *nkeys,void ***pkeynames,void ***pvalues,void ***pcomments,void ***punits,void **pdatatypes);
int tt_tblsaver(TT_TBL *p,char *fullname,int binorascii);
int tt_tblnewkeychar(TT_TBL *p,char *keyname,char *value,int datatype,char *comment,char *unit);
int tt_tblcol_ascii2bin(TT_TBL *p,int colnum,void **colsk);
int tt_tblbuilder(TT_TBL *p);
int tt_tblsizeline(int tfields, int *tbldatatypes, int *size);
int tt_tbl_dtypes2tbldatatypes(char *dtypes,int *tfields,int **tbldatatypes);
int tt_tblcreater(TT_TBL *p,int tfields,int naxis2, int *tbldatatypes);
int tt_tbldestroyer(TT_TBL *p);

int tt_ptr_allotbl(void *args);
int tt_ptr_freetbl(void *args);
int tt_ptr_savetbl(void *args);

int tt_ima_series_builder(char* fonction, int nbima, TT_IMA_SERIES_OPTION* options,TT_IMA_SERIES *pseries);
int tt_ima_series_builder1(char* fonction,TT_IMA_SERIES *pseries);
int tt_ima_series_builder2(TT_IMA_SERIES_OPTION* options);
int tt_ima_series_builder3(int nbkeys, char **keys, char* tmp_dir, TT_IMA_SERIES_OPTION* options);
int tt_ima_series_dispatch(char* fonction, TT_IMA_SERIES *pseries);
int tt_ima_series_history(char* fonction, TT_IMA_SERIES *pseries);
int tt_ima_series_destroyer(TT_IMA_SERIES *pseries);

int tt_user1_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries);
int tt_user1_ima_series_builder2(TT_IMA_SERIES_OPTION* options);
int tt_user1_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options);
int tt_user1_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg);
int tt_user1_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack);
int tt_user1_ima_stack_builder2(TT_IMA_STACK *pstack);
int tt_user1_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack);
int tt_user1_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg);

int tt_user2_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries);
int tt_user2_ima_series_builder2(TT_IMA_SERIES_OPTION* options);
int tt_user2_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options);
int tt_user2_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg);
int tt_user2_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack);
int tt_user2_ima_stack_builder2(TT_IMA_STACK *pstack);
int tt_user2_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack);
int tt_user2_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg);

int tt_user3_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries);
int tt_user3_ima_series_builder2(TT_IMA_SERIES_OPTION* options);
int tt_user3_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options);
int tt_user3_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg);
int tt_user3_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack);
int tt_user3_ima_stack_builder2(TT_IMA_STACK *pstack);
int tt_user3_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack);
int tt_user3_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg);

int tt_user4_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries);
int tt_user4_ima_series_builder2(TT_IMA_SERIES_OPTION* options);
int tt_user4_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options);
int tt_user4_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg);
int tt_user4_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack);
int tt_user4_ima_stack_builder2(TT_IMA_STACK *pstack);
int tt_user4_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack);
int tt_user4_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg);

int tt_user5_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries);
int tt_user5_ima_series_builder2(TT_IMA_SERIES_OPTION* options);
int tt_user5_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options);
int tt_user5_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg);
int tt_user5_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack);
int tt_user5_ima_stack_builder2(TT_IMA_STACK *pstack);
int tt_user5_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack);
int tt_user5_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg);

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

/* --- variable globale pour le nom de fichiers temporaires ---*/
/* --- DM: passe en extern, et definit dans tt.c pour compil sous MacOS-X --- */
extern char tt_tmpfile_ext[255];

/* --- variable globale pour le dossier de fichiers temporaires ---*/
extern char tt_tmp_dir[FLEN_FILENAME];
extern int tt_tmp_dir_ok;
#define TT_TMP_DIR_OK 1638356

