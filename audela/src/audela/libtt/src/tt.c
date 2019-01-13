/* tt.c
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
/* int libtt_main(int service, ...)                                     */
/*                                                                         */
/* En entree :                                                             */
/*  service : est un nombre entier qui designe la fonction                 */
/* En entree/sortie                                                        */
/*  ... : une suite de parametres d'entree ou de sortie suivant le cas     */
/* En sortie :                                                             */
/*  int : retourne un code d'erreur ou zero si tout c'est bien passe       */
/***************************************************************************/

#include "tt.h"

/* --- DM: passe en extern, et definit dans tt.c pour compil sous MacOS-X --- */
char tt_tmpfile_ext[255];
char tt_tmp_dir[FLEN_FILENAME];
int tt_tmp_dir_ok;

int libtt_main(int service,...)
{
   int status = 0;
   va_list marqueur;
   void *pointeur;
   void **argu=NULL;
   int k,nb_argumin=50,nb_argus,nb_argu;

#ifdef OS_UNIX_CC_DECBAG_SO_VADCL
   int service;
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
   if ((argu=(void**)tt_calloc(nb_argus+1,sizeof(void*)))==NULL) {
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
   if (service==TT_ERROR_MESSAGE) { status=tt_errmessage(argu); }
   else if (service==TT_LAST_ERROR_MESSAGE) { status=tt_lasterrmessage(argu); }
   else if (service==TT_SCRIPT_2) { status=tt_script_2(argu[1]); }
   else if (service==TT_SCRIPT_3) { status=tt_script_3(argu[1]); }

   /* --- fonctions elementaires ---*/
   else if (service==TT_FCT_IMA_STACK) { status=tt_fct_ima_stack(argu[1]); }
   else if (service==TT_FCT_IMA_SERIES) { status=tt_fct_ima_series(argu[1]); }

   /* --- fonctions utilitaires ---*/
   else if (service==TT_UTIL_CALLOC_PTRPTR_CHAR) {
      status=tt_util_calloc_ptrptr_char2(argu);
   }
   else if (service==TT_UTIL_CALLOC_PTR) { status=tt_util_calloc_ptr2(argu); }
   else if (service==TT_UTIL_FREE_PTR) { status=tt_util_free_ptr(argu[1]); }
   else if (service==TT_UTIL_TMP_DIR) { status=tt_util_tmp_dir(argu[1]); }

   /* --- fonctions de pointeurs ---*/
   else if (service==TT_PTR_LOADIMA) { status=tt_ptr_loadima(argu); }
   else if (service==TT_PTR_LOADKEYS) { status=tt_ptr_loadkeys(argu); }
   else if (service==TT_PTR_ALLOKEYS) { status=tt_ptr_allokeys(argu); }
   else if (service==TT_PTR_STATIMA) { status=tt_ptr_statima(argu); }
   else if (service==TT_PTR_CUTSIMA) { status=tt_ptr_cutsima(argu); }
   else if (service==TT_PTR_SAVEIMA) { status=tt_ptr_saveima(argu); }
   else if (service==TT_PTR_SAVEKEYS) { status=tt_ptr_savekeys(argu); }
   else if (service==TT_PTR_SAVEJPG) { status=tt_ptr_savejpg(argu); }
   else if (service==TT_PTR_SAVEJPGCOLOR) { status=tt_ptr_savejpgcolor(argu); }
   else if (service==TT_PTR_FREEPTR) { status=tt_ptr_freeptr(argu); }
   else if (service==TT_PTR_FREEKEYS) { status=tt_ptr_freekeys(argu); }
   else if (service==TT_PTR_IMASERIES) { status=tt_ptr_imaseries(argu); }
   else if (service==TT_PTR_FREETBL) { status=tt_ptr_freetbl(argu); }
   else if (service==TT_PTR_ALLOTBL) { status=tt_ptr_allotbl(argu); }
   else if (service==TT_PTR_SAVETBL) { status=tt_ptr_savetbl(argu); }
   else if (service==TT_PTR_SAVEIMA3D) { status=tt_ptr_saveima3d(argu); }
   else if (service==TT_PTR_LOADIMA3D) { status=tt_ptr_loadima3d(argu); }
   else if (service==TT_PTR_SAVEIMA1D) { status=tt_ptr_saveima1d(argu); }
   else if (service==TT_PTR_SAVEIMAKEYDIM) { status=tt_ptr_saveimakeydim(argu); }

   /* --- fonction non reconnue ---*/

   else {status=FS_ERR_SERVICE_NOT_FOUND;}
   tt_free(argu,NULL);
   return(status);
}

void tt_internal_erreur(int msg)
{
   if (msg>0) {
   /*
      printf("Erreur (%d) detectee dans Fitsio\n",msg);
   } else {
      printf("Erreur (%d) detectee dans Fits.dll\n",msg);
   */
   }
}




