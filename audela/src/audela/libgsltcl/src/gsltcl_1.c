/* gsltcl_1.h
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
/* Ce fichier contient du C pur et dur sans une seule goute de Tcl.        */
/* Ainsi, ce fichier peut etre utilise pour d'autres applications C sans   */
/* rapport avec le Tcl.                                                    */
/***************************************************************************/
/* Le include gsltcl.h ne contient pas d'infos concernant Tcl.                */
/***************************************************************************/
#include "gsltcl.h"

int gsltcl_mcalloc(double **mat,int nlig,int ncol)
/***************************************************************************/
/* Allocation memoire pour une matrice                                     */
/***************************************************************************/
/***************************************************************************/
{
   double *m=NULL;
   if (*mat==NULL) {
	  if (nlig*ncol==0) {
		  return 2;
	  }
      m=(double*)calloc(nlig*ncol,sizeof(double));         
	  if (m==NULL) {
	     return 1;
	  }
   }
   *mat=m;
   return 0;
}

int gsltcl_mfree(double **mat)
/***************************************************************************/
/* Liberation memoire pour une matrice                                     */
/***************************************************************************/
/***************************************************************************/
{
   if (*mat==NULL) {
	   free(*mat);
   }
   return 0;
}

char *gsltcl_d2s(double val)
/***************************************************************************/
/* Double to String conversion with many digits                            */
/***************************************************************************/
/***************************************************************************/
{
   int kk,nn;
   static char s[200];
   sprintf(s,"%13.12g",val);
	nn=(int)strlen(s);
	for (kk=0;kk<nn;kk++) {
		if (s[kk]!=' ') {
			break;
		}
	}		
   return s+kk;
}

