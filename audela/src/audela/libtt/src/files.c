/* files.c
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
/* files.c     : appel general par le seul point d'entree                  */
/* fs_fsio1.c  : fonctions elementaires                                    */
/* fs_fsio2.c                                                              */
/* fs_macr1.c  : macrofonctions utilitaires                                */
/***************************************************************************/

#include "files.h"
#include "tt.h"

/***************************************************************************/
/* Seul point d'entree de la DLL                                           */
/***************************************************************************/

#ifdef OS_WIN_VCPP_DLL
int __stdcall libfiles_main(int service,...)
#endif

#ifdef OS_WIN_BORLB_DLL
__declspec(dllexport) int __stdcall libfiles_main(int service,...)
#endif

#ifdef OS_WIN_BORL_DLL
__declspec(dllexport) int __stdcall libfiles_main(int service,...)
#endif

#ifdef OS_LINUX_GCC_SO
extern int libfiles_main(int service, ...)
#endif

#ifdef OS_UNIX_CC
int libfiles_main(int service, ...)
#endif

#ifdef OS_UNIX_CC_HP_SL
extern int libfiles_main(int service, ...)
#endif

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
extern int libfiles_main(va_alist)
va_dcl
#endif

#ifdef OS_UNIX_GCC_LINUX
extern int libfiles_main(int service, ...)
#endif

#ifdef OS_UNIX_GCC_DEC_SO
extern int libfiles_main(int service, ...)
#endif

#ifdef OS_DOS_WATC
int libfiles_main(int service, ...)
#endif

#ifdef OS_DOS_WATC_LIB
extern int libfiles_main(int service, ...)
#endif

#ifdef OS_WIN_VCPP
int libfiles_main(int service, ...)
#endif

{
  static int status;
  va_list marqueur;
  void *pointeur;
  void **argu;
  int k,nb_argumin=50,nb_argus,nb_argu;

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
  int service,nb;
#endif

   /* === analyse et decodage des arguments variables === */

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
   va_start(marqueur);
   service=va_arg(marqueur,int);
#else
   va_start(marqueur,service);
#endif
   nb_argu=va_arg(marqueur,int);
   if (nb_argu<nb_argumin) {nb_argus=nb_argumin;} else {nb_argus=nb_argu;}
   argu=NULL;
   if ((argu=(void**)calloc(nb_argus+1,sizeof(void*)))==NULL) {
      return(FS_ERR_PB_MALLOC);
   }
   for (k=1;k<=nb_argu;k++) {
      pointeur=va_arg(marqueur,void*);
      argu[k]=(void*)pointeur;
   }
   va_end(marqueur);
  
   /* === appels aux differentes fonctions === */
   status=OK_DLL;

   /* --- macro fonctions ---*/
   if      (service==FS_MACR_ARRAYS_IN_FILE) { status=macr_arrays_in_file(argu[1],argu[2],argu[3]); }
   else if (service==FS_MACR_ARRAYS2D2DATAINFO) { status=macr_arrays2d2datainfo(argu[1],argu[2],argu[3]); }
   else if (service==FS_MACR_ARRAY_READ) { status=macr_array_read(argu[1],argu[2],argu[3],argu[4]); }
   else if (service==FS_MACR_WRITE) { status=macr_write(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7],argu[8],argu[9],argu[10],argu); }
   else if (service==FS_MACR_READ) { status=macr_read(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7],argu[8],argu[9],argu); }
   else if (service==FS_MACR_WRITE_KEYS) { status=macr_write_keys(argu); }
   else if (service==FS_MACR_READ_KEYS) { status=macr_read_keys(argu); }
   else if (service==FS_MACR_RENAME_KEYS) { status=macr_rename_keys(argu); }
   else if (service==FS_MACR_FITS2GIF) { status=macr_fits2gif(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7]); }
   else if (service==FS_MACR_FITS2JPG) { status=macr_fits2jpg(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7],argu[8]); }

   else if (service==FS_MACR_WRITE_JPG) { status=macr_write_jpg(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6]); }
   else if (service==FS_MACR_READ_JPG) { status=macr_read_jpg(argu[1],argu[2],argu[3],argu[4],argu[5]); }
   else if (service==FS_MACR_SHORT2JPG) { status=macr_short2jpg(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7]); }

   /* --- fonctions utilitaires ---*/
   else if (service==FS_UTIL_PUT_ARRAYS2D) { status=util_put_arrays2d(argu[1],argu[2],argu[3],argu[4]); }
   else if (service==FS_UTIL_GET_ARRAYS2D) { status=util_get_arrays2d(argu[1],argu[2],argu[3],argu[4]); }
   else if (service==FS_UTIL_PUT_DATAINFO) { status=util_put_datainfo(argu[1],argu[2],argu[3]); }
   else if (service==FS_UTIL_GET_DATAINFO) { status=util_get_datainfo(argu[1],argu[2],argu[3]); }
   else if (service==FS_UTIL_PUT_DATATYPE) { status=util_put_datatype(argu[1],argu[2],argu[3]); }
   else if (service==FS_UTIL_BITPIX2DATATYPE) { status=util_bitpix2datatype(argu[1],argu[2]); }
   else if (service==FS_UTIL_CALLOC_PTR_DATATYPE) { status=util_calloc_ptr_datatype(argu[1],argu[2],argu[3]); }
   else if (service==FS_UTIL_CALLOC_PTR_IMAGE2D) { status=util_calloc_ptr_image2d(argu[1],argu[2]); }
   else if (service==FS_UTIL_CALLOC_PTRPTR_CHAR) { status=util_calloc_ptrptr_char(argu[1],argu[2],argu[3]); }
   else if (service==FS_UTIL_FREE_PTR) { status=util_free_ptr(argu[1]); }
   else if (service==FS_UTIL_MATCH_RESERVED_KEY) { status=util_match_reserved_key(argu[1],argu[2]); }
   else if (service==FS_UTIL_DATATYPE_BYTES) { status=util_datatype_bytes(argu[1],argu[2]); }

   /* --- fitsio fonctions ---*/

   else if (service==FS_FITS_GET_ERRSTATUS) { status=fts_get_errstatus(argu[1],argu[2]); }

   else if (service==FS_FITS_OPEN_FILE) { status=fts_open_file(argu[1],argu[2],argu[3]); }
   else if (service==FS_FITS_CREATE_FILE) { status=fts_create_file(argu[1],argu[2]); }
   else if (service==FS_FITS_CLOSE_FILE) { status=fts_close_file(argu[1]); }

   else if (service==FS_FITS_MOVABS_HDU) { status=fts_movabs_hdu(argu[1],argu[2],argu[3]); }
   else if (service==FS_FITS_GET_NUM_HDUS) { status=fts_get_num_hdus(argu[1],argu[2]); }
   else if (service==FS_FITS_CREATE_IMG) { status=fts_create_img(argu[1],argu[2],argu[3],argu[4]); }
   else if (service==FS_FITS_CREATE_TBL) { status=fts_create_tbl(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7],argu[8]); }

   else if (service==FS_FITS_GET_HDRSPACE) { status=fts_get_hdrspace(argu[1],argu[2],argu[3]); }
   else if (service==FS_FITS_UPDATE_KEY) { status=fts_update_key(argu[1],argu[2],argu[3],argu[4],argu[5]); }
   else if (service==FS_FITS_WRITE_RECORD) { status=fts_write_record(argu[1],argu[2]); }
   else if (service==FS_FITS_WRITE_KEY_UNIT) { status=fts_write_key_unit(argu[1],argu[2],argu[3]); }
   else if (service==FS_FITS_MODIFY_NAME) { status=fts_modify_name(argu[1],argu[2],argu[3]); }
   else if (service==FS_FITS_READ_RECORD) { status=fts_read_record(argu[1],argu[2],argu[3]); }
   else if (service==FS_FITS_READ_KEY_UNIT) { status=fts_read_key_unit(argu[1],argu[2],argu[3]); }
   else if (service==FS_FITS_DELETE_) { status=fts_delete_(argu[1],argu[2],argu[3]); }

   else if (service==FS_FITS_WRITE_IMG) { status=fts_write_img(argu[1],argu[2],argu[3],argu[4],argu[5]); }
   else if (service==FS_FITS_READ_IMG) { status=fts_read_img(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7]); }

   else if (service==FS_FITS_WRITE_COL) { status=fts_write_col(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7]); }
   else if (service==FS_FITS_READ_COL) { status=fts_read_col(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7],argu[8],argu[9]); }

   else if (service==FS_FITS_CREATE_HDU) { status=fts_create_hdu(argu[1]); }
   else if (service==FS_FITS_INSERT_IMG) { status=fts_insert_img(argu[1],argu[2],argu[3],argu[4]); }
   else if (service==FS_FITS_INSERT_) { status=fts_insert_(argu); }
   else if (service==FS_FITS_RESIZE_IMG) { status=fts_resize_img(argu[1],argu[2],argu[3],argu[4]); }
   else if (service==FS_FITS_COPY_HEADER) { status=fts_copy_header(argu[1],argu[2]); }

   else if (service==FS_FITS_READ_IMGHDR) { status=fts_read_imghdr(argu); }
   else if (service==FS_FITS_READ_ATBLHDR) { status=fts_read_atblhdr(argu); }
   else if (service==FS_FITS_READ_BTBLHDR) { status=fts_read_btblhdr(argu); }

   else if (service==FS_FITS_READ_KEYN) { status=fts_read_keyn(argu[1],argu[2],argu[3],argu[4],argu[5]); }
   else if (service==FS_FITS_FIND_NEXTKEY) { status=fts_find_nextkey(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6]); }
   else if (service==FS_FITS_READ_KEYWORD) { status=fts_read_keyword(argu[1],argu[2],argu[3],argu[4]); }
   else if (service==FS_FITS_READ_KEY_) { status=fts_read_key_(argu[1],argu[2],argu[3],argu[4],argu[5]); }
   else if (service==FS_FITS_READ_KEYS_) { status=fts_read_keys_(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7]); }

   else if (service==FS_FITS_READ_IMG_) { status=fts_read_img_(argu[1],argu[2],argu[3],argu[4],argu[5],argu[6],argu[7],argu[8]); }

   else if (service==FS_FITS_READ_TDIM) { status=fts_read_tdim(argu[1],argu[2],argu[3],argu[4],argu[5]); }

   else if (service==FS_FITS_GET_KEYTYPE) { status=fts_get_keytype(argu[1],argu[2]); }

   /* --- fonction non reconnue ---*/

   else {status=FS_ERR_SERVICE_NOT_FOUND;}

   free(argu);
   return(status);
}

void internal_erreur(int msg)
{
   if (msg>0) {
   /*
      printf("Erreur (%d) detectee dans Fitsio\n",msg);
   } else {
      printf("Erreur (%d) detectee dans Fits.dll\n",msg);
   */
   }
}
