/* files.h
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
/* Ce programme permet l'acces aux fonctions de la bibliotheque Fitsio     */
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
/* int libfiles_main(int service, ...)                                     */
/*                                                                         */
/* En entree :                                                             */
/*  service : est un nombre entier qui designe la fonction                 */
/* En entree/sortie                                                        */
/*  ... : une suite de parametres d'entree ou de sortie suivant le cas     */
/* En sortie :                                                             */
/*  int : retourne un code d'erreur ou zero si tout c'est bien passe       */
/***************************************************************************/
#ifndef __FILESH__
#define __FILESH__

/* --- definition de l'operating systeme (OS) employe pour compiler    ---*/
#ifdef OS_WIN_BORL_DLL
#ifdef _Windows
#   include "sysexp.h"
#else
#   include "sysexp.h"
#endif
#else
#   include "sysexp.h"
#endif

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

/*
#define TSTRINGS   1000

#define OK_DLL 0
#define PB_DLL -1
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
*/

/* --- definitions specifiques a l'OS pour l'appel de la fonction d'entree  ---*/
#ifndef __LIBFILESH__
#include "libfiles.h"
#endif

#ifdef OS_WIN_BORL_DLL
#define FILE_DOS
#undef FAR
#define HAVE_BOOLEAN
#endif

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

#ifdef OS_UNIX_GCC_DEC_SO
#define FILE_UNIX
#endif

#ifdef OS_WIN_VCPP
#define FILE_DOS
#endif


/* --- a jeter
#ifdef OS_WIN_BORLB_DLL
#include <windows.h>
int __export __stdcall libfiles_main(int,...);
#endif

#ifdef OS_WIN_VCPP_DLL
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

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
extern int libfiles_main(...);
#endif

#ifdef OS_DOS_WATC
int libfiles_main(int service, ...);
#endif

#ifdef OS_UNIX_GCC_LINUX
extern int libfiles_main(int service, ...);
#endif

#ifdef OS_DOS_WATC_LIB
extern int libfiles_main(int service, ...);
#endif

#ifdef OS_WIN_VCPP
int libfiles_main(int service, ...);
#endif

---*/

/* --- definition des includes des librairies exterieures ---*/

#include <fitsio.h>
#define XMD_H  //pour eviter le warning "benign redefinition of type"
#include <jpeglib.h>
#include "setjmp.h"

/* ======================================================================== */
/* ===== definitions associees aux structures internes de 'dll_fits' ====== */
/* ======================================================================== */

/* --- definitions des valeurs pour l'element 'type' de arrays2d_struct ---*/
/* --- definitions des valeurs pour l'element 'typematrix' de datainfo_struct ---*/
#define FULL_2D   0
#define SPARSE_2D 1

/* --- definitions des valeurs pour l'element 'type' de datainfo_struct ---*/
#define ARRAY_2D   0
#define LISTE_PIX  1

/* ======================================================================== */
/* ================ structures internes de 'dll_fits' ===================== */
/* ======================================================================== */

/* --- informations sur la nature des images 2D dans le fichier Fits --- */
typedef struct {
   int indice;
   int hdunum;
   int type;
   int bitpix;
   int x;
   int y;
} arrays2d_struct;

/* --- informations sur l'image ou la liste (/a) charge(e/r) --- */
typedef struct {
   int indice;      /* indice-ieme array/liste dans la liste d'entree de *_choise */
   int hdunum;      /* numero du HDU dans lequel on va lire les datas */
   int type;        /* type de data : array2d/liste/... */
   char date_obs[FLEN_VALUE];   /* instant de depart de la prise de vue */
   double exptime;  /* temps d'integration a la lumiere */
   int typematrix;
   int datatype;    /* type du pointeur qui contien(t/dra) l'image en memoire */
   int bitpix;      /* type de l'image enregistree dans le fichier Fits */
   int naxis1;
   int naxis2;
} datainfo_struct;

/* ======================================================================== */
/* ======================== declaration des fonctions ===================== */
/* ======================================================================== */

int macr_arrays_in_file(void *arg1,void *arg2,void **arg3);
int macr_arrays2d2datainfo(void *arg1,void *arg2,void **arg3);
int macr_array_read(void *arg1,void *arg2,void **arg3,void **arg4);
int macr_write(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8,void *arg9,void *arg10,void *arg11);
int macr_read(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8,void *arg9,void *arg10);
int macr_write_keys(void *arg1);
int macr_read_keys(void *arg1);
int macr_rename_keys(void *arg1);

int x_file(void *arg1,void *arg2,void *arg3,void **arg4, void *arg5,void **arg6, void **arg7);
void internal_erreur(int msg);

int macr_fits2gif(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7);
int GIFGetPixel(int x,int y,short imax,short *buf);
void GIFBumpPixel();
int GIFNextPixel(short imax,short *buf);
void GIFEncode(FILE *fp,int GWidth,int GHeight,int GInterlace,
	       int Background,int BitsPerPixel,
	       int *Red,int *Green,int *Blue,short *buf);
void GIFPutword(int w,FILE *fp);
void GIFCompress(int init_bits,FILE *outfile,short imax,short *buf);
void GIFOutput(int code);
void GIFCl_block ();
void GIFCl_hash(long hsize);
void GIFChar_init();
void GIFChar_out(int c );
void GIFFlush_char();

int macr_short2jpg(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7);
int macr_fits2jpg(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8);
int macr_write_jpg(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6);
int macr_read_jpg(void *arg1,void *arg2,void **arg3,void *arg4,void *arg5);
GLOBAL(int) write_JPEG_file (char * filename, int color_space, JSAMPLE *image_buffer,int image_width,int image_height,int quality);
GLOBAL(int) read_JPEG_file (char * filename, int *color_space, JSAMPLE **image_buffer,int *image_width,int *image_height);

int util_calloc_ptrptr_char(void **arg1,void *arg2,void *arg3);
int util_calloc_ptr_datatype(void **arg1,void *arg2,void *arg3);
int util_calloc_ptr_image2d(void **arg1,void *arg2);
int util_put_arrays2d(void *arg1,void *arg2,void *arg3,void *arg4);
int util_get_arrays2d(void *arg1,void *arg2,void *arg3,void *arg4);
int util_get_datainfo(void *arg1,void *arg2,void *arg3);
int util_put_datainfo(void *arg1,void *arg2,void *arg3);
int util_free_ptr(void *arg1);
int util_put_datatype(void *arg1,void *arg2,void *arg3);
int util_bitpix2datatype(void *arg1,void *arg2);
int util_match_reserved_key(void *arg1, void *arg2);
int util_datatype_bytes(void *arg1, void *arg2);
int fs_util_free_ptrptr(void **ptr,char *name);
void fs_free(void *ptr,char *name);
void *fs_calloc(int nombre,int taille);
void *fs_malloc(int taille);

int fts_get_errstatus(void *arg1,void *arg2);
int fts_delete_(void *arg1,void *arg2,void *arg3);
int fts_modify_name(void *arg1,void *arg2,void *arg3);
int fts_read_imghdr(void **argu);
int fts_read_atblhdr(void **argu);
int fts_read_btblhdr(void **argu);
int fts_find_nextkey(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6);
int fts_read_keyn(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5);
int fts_read_record(void *arg1,void *arg2,void *arg3);
int fts_write_record(void *arg1,void *arg2);
int fts_insert_(void **argu);
int fts_create_hdu(void *arg1);
int fts_insert_img(void *arg1,void *arg2,void *arg3,void *arg4);
int fts_resize_img(void *arg1,void *arg2,void *arg3,void *arg4);
int fts_copy_header(void *arg1,void *arg2);
int fts_read_key_unit(void *arg1,void *arg2,void *arg3);
int fts_read_keys_(void *arg0,void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6);
int fts_read_col(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8,void *arg9);
int fts_read_key_(void *arg0,void *arg1,void *arg2,void *arg3,void *arg4);
int fts_create_tbl(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8);
int fts_write_col(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7);
int fts_read_img(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7);
int fts_create_file(void *arg1,void *arg2);
int fts_update_key(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5);
int fts_get_num_hdus(void *arg1,void *arg2);
int fts_get_hdrspace(void *arg1,void *arg2,void *arg3);
int fts_write_key_unit(void *arg1,void *arg2,void *arg3);
int fts_create_img(void *arg1,void *arg2,void *arg3,void *arg4);
int fts_write_img(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5);
int fts_read_img_(void *arg0,void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7);
int fts_open_file(void *arg1,void *arg2,void *arg3);
int fts_close_file(void *arg1);
int fts_read_keyword(void *arg1,void *arg2,void *arg3,void *arg4);
int fts_get_num_hdus(void *arg1,void *arg2);
int fts_read_tdim(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5);
int fts_movabs_hdu(void *arg1,void *arg2,void *arg3);
int fts_get_keytype(void *arg1,void *arg2);

#endif
