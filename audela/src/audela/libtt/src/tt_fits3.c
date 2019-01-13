/* tt_fits3.c
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

#include "tt.h"

int tt_tblpixbuilder(TT_TBL_PIXELIST *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int len,msg,nombre,taille;
   /* -------------------------------------------------------------------------- */
   /* --- premiere partie. On initialise les valeurs et les pointeurs a NULL --- */
   /* -------------------------------------------------------------------------- */
   /* --- image de travail a charger ---*/
   strcpy(p->load_path,"");
   sprintf(p->load_name,"#0");
   sprintf(p->load_suffix,".fit");
   sprintf(p->load_fullname,"%s%s%s",p->load_path,p->load_name,p->load_suffix);
   p->load_typehdu=BINARY_TBL;
   p->load_hdunum=1;
   /* --- image de travail a sauver ---*/
   strcpy(p->save_path,"");
   sprintf(p->save_name,"#0");
   sprintf(p->save_suffix,".fit");
   sprintf(p->save_fullname,"%s%s%s",p->save_path,p->save_name,p->save_suffix);
   p->save_typehdu=BINARY_TBL;
   p->save_hdunum=0;
   /* --- pour la description de la table ---*/
   strcpy(p->extname,"PIXELIST");
   p->extver=1;
   /* --- pour la description des champs de la table ---*/
   p->tfields=TT_TBLPIX_TFIELDS;     /* nombre de colonnes (=nombre de champ) */
   p->tform=NULL;
   p->ttype=NULL;
   p->tunit=NULL;
   p->datatypes=NULL;
   /* --- pour la description des donnees de la table ---*/
   p->nrows=0;
   p->x=NULL;
   p->y=NULL;
   p->ident=NULL;

   /* ------------------------------------------------------------ */
   /* --- deuxieme partie. On alloue la memoire des pointeurs  --- */
   /* ------------------------------------------------------------ */
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->ttype,&p->tfields,&len,"p->ttype"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblpixbuilder for pointer ttype");
      tt_tblpixdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->tunit,&p->tfields,&len,"p->tunit"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblpixbuilder for pointer tunit");
      tt_tblpixdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=p->tfields;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->datatypes,&nombre,&taille,"p->datatypes"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblpixbuilder for pointer datatypes");
      tt_tblpixdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }

   /* --------------------------------------------------------------- */
   /* --- troisieme partie. On remplit les valeurs des pointeurs  --- */
   /* --------------------------------------------------------------- */
   sprintf(p->ttype[TT_TBLPIX_X],"x coordinate");
   sprintf(p->ttype[TT_TBLPIX_Y],"y coordinate");
   sprintf(p->ttype[TT_TBLPIX_IDENT],"pixel identification");

   sprintf(p->tunit[TT_TBLPIX_X],"pixels");
   sprintf(p->tunit[TT_TBLPIX_Y],"pixels");
   sprintf(p->tunit[TT_TBLPIX_IDENT],"identification symbol");

   p->datatypes[TT_TBLPIX_X]=TDOUBLE;
   p->datatypes[TT_TBLPIX_Y]=TDOUBLE;
   p->datatypes[TT_TBLPIX_IDENT]=TBYTE;
   return(OK_DLL);
}

int tt_tblpixcreater(TT_TBL_PIXELIST *p,int nrows)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int msg,nombre,taille;
   if (p->nrows!=0) {
      /* code-erreur sur pointeurs deja alloues ---*/
      return(TT_ERR_PTR_ALREADY_ALLOC);
   }
   if (nrows<1) {
      return(PB_DLL);
   }
   p->nrows=nrows;
   nombre=p->nrows;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->x,&nombre,&taille,"p->x"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblpixcreater for pointer x");
      tt_tblpixdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->y,&nombre,&taille,"p->y"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblpixcreater for pointer y");
      tt_tblpixdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=p->nrows;
   taille=sizeof(short);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->ident,&nombre,&taille,"p->ident"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblpixcreater for pointer ident");
      tt_tblpixdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   return(OK_DLL);
}

int tt_tblpixdestroyer(TT_TBL_PIXELIST *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   p->nrows=0;
   /* --- pour la description des champs de la table ---*/
   tt_util_free_ptrptr2((void***)&p->tform,"p->tform");
   tt_util_free_ptrptr2((void***)&p->ttype,"p->ttype");
   tt_util_free_ptrptr2((void***)&p->tunit,"p->tunit");
   tt_free2((void**)&p->datatypes,"p->datatypes");
   /* --- pour la description des donnees de la table ---*/
   tt_free2((void**)&p->x,"p->x");
   tt_free2((void**)&p->y,"p->y");
   tt_free2((void**)&p->ident,"p->ident");
   return(OK_DLL);
}
