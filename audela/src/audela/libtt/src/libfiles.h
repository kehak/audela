/* libfiles.h
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
/* Placer ce .h en include de vos fichiers appelant la fonction            */
/* libfiles_main                                                            */
/***************************************************************************/
/* Ceci permet l'acces aux fonctions de la bibliotheque Fitsio             */
/* developpees par Pence et al. et a des macrofonctions appelant Fitsio    */
/* destinees a effectuer des acces simplifies aux donnees dans un fichier  */
/* au format FITS                                                          */
/***************************************************************************/
/* Ce programme peut etre compile selon diverses possibilites :            */
/***************************************************************************/
/* Il n'y a qu'un seul point d'entree pour acceder a l'ensemble des        */
/* fonctions. De cette facon, le programme appelant n'a besoin de definir  */
/* Uniquement que la fonction d'entree definie comme suit :                */
/*                                                                         */
/* int libfiles_main(int service, ...)                                      */
/*                                                                         */
/* En entree :                                                             */
/*  service : est un nombre entier qui designe la fonction                 */
/* En entree/sortie                                                        */
/*  ... : une suite de parametres d'entree ou de sortie suivant le cas     */
/* En sortie :                                                             */
/*  int : retourne un code d'erreur ou zero si tout c'est bien passe       */
/***************************************************************************/
#ifndef __LIBFILESH__
#define __LIBFILESH__

/* --- definition de l'operating systeme (OS) employe pour compiler    ---*/
#include "sysexp.h"

/* --- definition communes a tous les OS ---*/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
#include <varargs.h>
#else
#include <stdarg.h>
#endif

/* --- definition communes a tous les OS ---*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
#include <varargs.h>
#else
#include <stdarg.h>
#endif

/* --- definitions specifiques a l'OS pour l'appel de la fonction d'entree  ---*/

#ifdef OS_WIN_BORLB_DLL
typedef int LIBFILES(int,...);
#define FILE_DOS
#include <windows.h>
int __export __stdcall libfiles_main(int,...);
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_WIN_BORL_DLL
typedef int LIBTT(int,...);
#define FILE_DOS
#include <windows.h>
int __export __stdcall libfiles_main(int,...);
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_WIN_VCPP_DLL
typedef int LIBFILES(int,...);
#define FILE_DOS
#include <windows.h>
#define PREFIXE __declspec(dllexport)
PREFIXE int __stdcall libfiles_main(int,...);
#undef FAR
#define HAVE_BOOLEAN
#endif

#ifdef OS_UNIX_CC
int libfiles_main(int service, ...);
#endif

#ifdef OS_UNIX_CC_HP_SL
extern int libfiles_main(int service, ...);
#endif

#ifdef OS_LINUX_GCC_SO
#include <dlfcn.h>
typedef int LIBFILES(int,...);
int libfiles_main(int service, ...);
#endif

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
extern int libfiles_main(...);
#endif

#ifdef OS_DOS_WATC
int libfiles_main(int service, ...);
#endif

#ifdef OS_DOS_WATC_LIB
extern int libfiles_main(int service, ...);
#endif

/***************************************************************************/
/****************** conventions d'ecriture pour TFORM **********************/
/***************************************************************************/
/*                               ASCII_TBL              BINARY_TBL         */
/* pour un type (char[w])       TFORM='Aw'                 "wA"            */
/* pour un type (unsigned char) TFORM='Aw'                 "1B"            */
/* pour un type (short)         TFORM='Iw.m'               "1I"            */
/* pour un type (int)           TFORM='Iw.m'               "1J"            */
/* pour un type (float)         TFORM="Ew.m" ou "Fw.m"     "1E"            */
/* pour un type (double)        TFORM="Dw.m" ou "Fw.m"     "1D"            */
/***************************************************************************/

/***************************************************************************/
/************** variables utiles pour les fonctions de FITSIO **************/
/***************************************************************************/

#ifndef FLEN_FILENAME 
#define FLEN_FILENAME 1025 /* max length of a filename  */
/*#define FLEN_FILENAME 161*/ /* max length of a filename  */
#endif

#ifndef FLEN_KEYWORD 
#define FLEN_KEYWORD   72  /* max length of a keyword (HIERARCH convention) */
/*#define FLEN_KEYWORD    9*/  /* max length of a keyword */
#endif

#define FLEN_CARD      81  /* length of a FITS header card */
#define FLEN_VALUE     71  /* max length of a keyword value string */
#define FLEN_COMMENT   73  /* max length of a keyword comment string */
#define FLEN_ERRMSG    81  /* max length of a FITSIO error message */
#define FLEN_STATUS    31  /* max length of a FITSIO status text string */

#define TBIT          1  /* codes for FITS table data types */
#define TBYTE        11
#define TLOGICAL     14
#define TSTRING      16
#define TUSHORT      20
#define TSHORT       21
#define TINT         31
#define TULONG       40
#define TLONG        41
#define TFLOAT       42
#define TDOUBLE      82
#define TCOMPLEX     83
#define TDBLCOMPLEX 163

#define BYTE_IMG      8  /* BITPIX code values for FITS image types */
#define SHORT_IMG    16
#define LONG_IMG     32
#define FLOAT_IMG   -32
#define DOUBLE_IMG  -64
			 /* The following 2 codes are not true FITS         */
			 /* datatypes; these codes are only used internally */
			 /* within cfitsio to make it easier for users      */
			 /* to deal with unsigned integers.                 */
#define USHORT_IMG   20
#define ULONG_IMG    40

#define IMAGE_HDU  0  /* Primary Array or IMAGE HDU */
#define ASCII_TBL  1  /* ASCII table HDU  */
#define BINARY_TBL 2  /* Binary table HDU */
#define ANY_HDU   -1  /* matches any HDU type */

#define READONLY  0    /* options when openning a file */
#define READWRITE 1

/*
#define FLOATNULLVALUE -9.11912E-36F
#define DOUBLENULLVALUE -9.1191291391491E-36
*/

/***************************************************************************/
/******************** variables utiles supplementaires *********************/
/***************************************************************************/

#define TSTRINGS   1000 /* decalage pour datatype afin d'indiquer le nombre de caracteres d'une chaine */


#define FS_ERR_SERVICE_NOT_FOUND -2
#define FS_ERR_PB_MALLOC -3
#define FS_ERR_MEMBER_NOT_FOUND -4
#define FS_ERR_BAD_DATATYPE -5
#define FS_ERR_BAD_BITPIX   -6
#define FS_ERR_HDUNUM_OVER -7
#define FS_ERR_HDU_NOT_SAME_TYPE -8
#define FS_ERR_TYPEHDU_NOT_KNOWN -9
#define FS_ERR_REMOVE_FILE -10
#define FS_ERR_PTR_NULL -11
#define FS_ERR_BAD_NBKEYS -12
#define FS_ERR_BAD_NUMKEY -13
#define FS_ERR_JPEG_FILE_NOT_FOUND -14
#define FS_ERR_JPEG_READ -15

/* --- definition des types d'encodage des images JPEG ---*/
#ifndef __FILESH__
typedef enum {
   JCS_UNKNOWN,            /* error/unspecified */
   JCS_GRAYSCALE,          /* monochrome */
   JCS_RGB,                /* red/green/blue */
   JCS_YCbCr,              /* Y/Cb/Cr (also known as YUV) */
   JCS_CMYK,               /* C/M/Y/K */
   JCS_YCCK                /* Y/Cb/Cr/K */
} J_COLOR_SPACE;
#endif

/***************************************************************************/
/******* numeros de services associes aux fonctions ************************/
/***************************************************************************/

#define FS_MACR_ARRAYS_IN_FILE        10001
#define FS_MACR_ARRAYS2D2DATAINFO     10002
#define FS_MACR_ARRAY_READ            10003
#define FS_MACR_WRITE                 10004
#define FS_MACR_READ                  10005
#define FS_MACR_WRITE_KEYS            10006
#define FS_MACR_READ_KEYS             10007
#define FS_MACR_RENAME_KEYS           10008
#define FS_MACR_FITS2GIF              10009
#define FS_MACR_FITS2JPG              10010

#define FS_MACR_WRITE_JPG             11001
#define FS_MACR_READ_JPG              11002
#define FS_MACR_SHORT2JPG             11003

#define FS_UTIL_PUT_ARRAYS2D          20001
#define FS_UTIL_GET_ARRAYS2D          20002
#define FS_UTIL_GET_DATAINFO          20003
#define FS_UTIL_PUT_DATAINFO          20004
#define FS_UTIL_PUT_DATATYPE          20005
#define FS_UTIL_BITPIX2DATATYPE       20101
#define FS_UTIL_CALLOC_PTR_DATATYPE   20201
#define FS_UTIL_CALLOC_PTR_IMAGE2D    20202
#define FS_UTIL_FREE_PTR              20203
#define FS_UTIL_CALLOC_PTRPTR_CHAR    20204
#define FS_UTIL_MATCH_RESERVED_KEY    20301
#define FS_UTIL_DATATYPE_BYTES        20302

#define FS_FITS_GET_ERRSTATUS       5010001

#define FS_FITS_OPEN_FILE           5020001
#define FS_FITS_CREATE_FILE         5020002
#define FS_FITS_CLOSE_FILE          5020004

#define FS_FITS_MOVABS_HDU          5030001
#define FS_FITS_GET_NUM_HDUS        5030006
#define FS_FITS_CREATE_IMG          5030007
#define FS_FITS_CREATE_TBL          5030008

#define FS_FITS_GET_HDRSPACE        5040001
#define FS_FITS_UPDATE_KEY          5040002
#define FS_FITS_WRITE_RECORD        5040007
#define FS_FITS_WRITE_KEY_UNIT      5040008
#define FS_FITS_MODIFY_NAME         5040009
#define FS_FITS_READ_RECORD         5040011
#define FS_FITS_READ_KEY_UNIT       5040014
#define FS_FITS_DELETE_             5040015

#define FS_FITS_WRITE_IMG           5060001
#define FS_FITS_READ_IMG            5060004

#define FS_FITS_WRITE_COL           5070301
#define FS_FITS_READ_COL            5070304

#define FS_FITS_CREATE_HDU          6020002
#define FS_FITS_INSERT_IMG          6020003
#define FS_FITS_INSERT_             6020004
#define FS_FITS_RESIZE_IMG          6020005
#define FS_FITS_COPY_HEADER         6020006

#define FS_FITS_READ_IMGHDR         6030204
#define FS_FITS_READ_ATBLHDR        6030205
#define FS_FITS_READ_BTBLHDR        6030206

#define FS_FITS_READ_KEYN           6030501
#define FS_FITS_FIND_NEXTKEY        6030502
#define FS_FITS_READ_KEYWORD        6030503
#define FS_FITS_READ_KEY_           6030504
#define FS_FITS_READ_KEYS_          6030505

#define FS_FITS_READ_IMG_           6050009

#define FS_FITS_READ_TDIM           6060003
#define FS_FITS_READ_KEYWORD        6030503

#define FS_FITS_READ_IMG_           6050009

#define FS_FITS_READ_TDIM           6060003

#define FS_FITS_GET_KEYTYPE         6090011

#endif
