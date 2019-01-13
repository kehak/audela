/* tt_seri2.c
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

int tt_ima_series_saver_end(TT_IMA_SERIES *pseries,char *fullname)
/***************************************************************************/
/* Sauvegarde de l'image traitee et eventuellement des listes              */
/***************************************************************************/
/***************************************************************************/
{
   int msg,del_objname,del_pixname,del_catname;
   char message[TT_MAXLIGNE];
   char path[FLEN_FILENAME];
   char name[FLEN_FILENAME];
   char suffix[FLEN_FILENAME];
   char fullname2[FLEN_FILENAME];
   int hdunum,dimx,dimy,choix,qualite;
   char sb[]="MIPS-LO";
   char sh[]="MIPS-HI";
   double bgmean,bgsigma;

   if (pseries->numfct==TT_IMASERIES_DELETE) {
      return(OK_DLL);
   }
   /* --- prepare les mots cle des fichiers lies a l'image ---*/
   del_objname=TT_NO;
   if (pseries->object_list==TT_YES) {
      tt_imadelnewkey(pseries->p_out,"OBJEFILE");
      if ((strcmp(pseries->objefile,"")==0)||(strcmp(pseries->objefile,".")==0)) {
         strcpy(pseries->objefile,".");
         del_objname=TT_YES;
      }
      if (strlen(pseries->objefile) >= FLEN_VALUE ) {
         sprintf(message,"OBJEFILE %s too long (maxlen=%d)",pseries->objefile, FLEN_VALUE);
         msg = TT_ERR_FILENAME_TOO_LONG;
         tt_errlog(pseries->tmp_dir,msg,message);
         return(msg);
      }
      tt_imanewkey(pseries->p_out,"OBJEFILE",pseries->objefile,TSTRING,"Filename of objects list","");
   }
   del_pixname=TT_NO;
   if (pseries->pixel_list==TT_YES) {
      tt_imadelnewkey(pseries->p_out,"PIXEFILE");
      if ((strcmp(pseries->pixefile,"")==0)||(strcmp(pseries->pixefile,".")==0)) {
	 strcpy(pseries->pixefile,".");
	 del_pixname=TT_YES;
      }
      tt_imanewkey(pseries->p_out,"PIXEFILE",pseries->pixefile,TSTRING,"Filename of pixels list","");
   }
   del_catname=TT_NO;
   if (pseries->catalog_list==TT_YES) {
      tt_imadelnewkey(pseries->p_out,"CATAFILE");
      if ((strcmp(pseries->catafile,"")==0)||(strcmp(pseries->catafile,".")==0)) {
	 strcpy(pseries->catafile,".");
	 del_catname=TT_YES;
      }
      tt_imanewkey(pseries->p_out,"CATAFILE",pseries->catafile,TSTRING,"Filename of catalog list","");
   }

   /* --- calcule eventuellement le skylevel ---*/
   if (pseries->skylevel_compute==TT_YES) {
      tt_util_bgk(pseries->p_in,&bgmean,&bgsigma);
      tt_imanewkey(pseries->p_out,"SKYLEVEL",&bgmean,TDOUBLE,"Sky level for photometric use","adu");
   }
   /* --- on force le nombres d'axes a celui de l'image entrante ---*/
   pseries->p_out->naxis=pseries->p_in->naxis;

   /* --- on force les mots cle des dimension en sortie ---*/
   tt_imanewkey(pseries->p_out,"NAXIS1",&pseries->p_out->naxis1,TINT,"","");
   if (pseries->p_out->naxis>1) {
      tt_imanewkey(pseries->p_out,"NAXIS2",&pseries->p_out->naxis2,TINT,"","");
   }

   /* --- sauve l'image ---*/
   if ((msg=tt_imasaver(pseries->p_out,fullname,pseries->bitpix))!=0) {
      sprintf(message,"File %s cannot be saved",fullname);
      tt_errlog(pseries->tmp_dir,msg,message);
      return(msg);
   }
   tt_imadelnewkey(pseries->p_out,"OBJEFILE");
   tt_imadelnewkey(pseries->p_out,"PIXEFILE");
   tt_imadelnewkey(pseries->p_out,"CATAFILE");

   /* --- sauve les tables ---*/
   if (del_objname==TT_YES) { strcpy(pseries->objefile,fullname); }
   if (del_pixname==TT_YES) { strcpy(pseries->pixefile,fullname); }
   if (del_catname==TT_YES) { strcpy(pseries->catafile,fullname); }
   if (pseries->object_list==TT_YES) {
      if ((msg=tt_tblobjsaver(pseries->p_out,pseries->objefile))!=OK_DLL) {
	 sprintf(message,"File %s cannot be saved",pseries->objefile);
	 tt_errlog(pseries->tmp_dir,msg,message);
	 return(msg);
      }
   }

   if (pseries->catalog_list==TT_YES) {
      if ((msg=tt_tblcatsaver(pseries->p_out,pseries->catafile))!=OK_DLL) {
	 sprintf(message,"File %s cannot be saved",pseries->catafile);
	 tt_errlog(pseries->tmp_dir,msg,message);
	 return(msg);
      }
   }
   if (del_objname==TT_YES) { strcpy(pseries->objefile,"."); }
   if (del_pixname==TT_YES) { strcpy(pseries->pixefile,"."); }
   if (del_catname==TT_YES) { strcpy(pseries->catafile,"."); }

   /* --- sauve eventuellement une image JPEG ---*/
   if (pseries->jpegfile_make==TT_NO) {return(OK_DLL);}
   strcpy(fullname2,pseries->jpegfile);
   if (strcmp(pseries->jpegfile,"")==0) {
      /* --- identification du nom de fichier ---*/
      if ((msg=tt_imafilenamespliter(fullname,path,name,suffix,&hdunum))!=0) { return(msg); }
      strcpy(suffix,".jpg");
      strcpy(fullname2,tt_imafilecater(path,name,suffix));
   }
   choix=0;dimx=dimy=0;
   qualite=(int)(pseries->jpeg_qualite);
   if (qualite>100) {qualite=100;}
   if (qualite<5) {qualite=5;}
   /*if ((msg=libfiles_main(FS_MACR_FITS2JPG,7,fullname,fullname2,&choix,&sb,&sh,&dimx,&dimy))!=OK_DLL) {*/
   if ((msg=libfiles_main(FS_MACR_FITS2JPG,8,fullname,fullname2,&choix,sb,sh,&dimx,&dimy,&qualite))!=OK_DLL) {
      sprintf(message,"Problem concerning creation of JPEG file %s ",fullname2);
      tt_errlog(pseries->tmp_dir,msg,message);
      return(msg);
   }

   return(OK_DLL);
}

int tt_ima_series_loader_0(TT_IMA_SERIES *pseries,char *fullname)
/***************************************************************************/
/* chargement de l'image a traiter et eventuellement des listes            */
/***************************************************************************/
/***************************************************************************/
{
   long firstelem,nelem;
   int msg;
   char message[TT_MAXLIGNE];
   firstelem=(long)(1);
   nelem=(long)(0);
   /*tt_imabuilder(pseries->p_in);*/
   strcpy(pseries->p_in->load_fullname,fullname);

   /* --- efface le fichier si l'on a demande delete ---*/
   if (pseries->numfct==TT_IMASERIES_DELETE) {
      remove(fullname);
      return(OK_DLL);
   }
   if ((msg=tt_imaloader(pseries->p_in,fullname,firstelem,nelem))!=0) {
      sprintf(message,"Problem concerning file %s ",fullname);
      tt_errlog(pseries->tmp_dir,msg,message);
      return(msg);
   }

   /* --- verification des dimensions ---*/
   nelem=(pseries->p_in->naxis1)*(pseries->p_in->naxis2);
   if (pseries->index==1) {
      pseries->naxis1_1=pseries->p_in->naxis1;
      pseries->naxis2_1=pseries->p_in->naxis2;
      strcpy(pseries->fullname0,fullname);
      if (pseries->bitpix==0) {
         pseries->bitpix=pseries->p_in->load_bitpix;
      }
   } else {
      if (pseries->numfct!=TT_IMASERIES_REGISTER) {
         if ((pseries->naxis1_1!=pseries->p_in->naxis1)||(pseries->naxis2_1!=pseries->p_in->naxis2)) {
            sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",pseries->p_in->naxis1,pseries->p_in->naxis2,fullname,(int)pseries->naxis1_1,(int)pseries->naxis2_1,pseries->fullname0);
            tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
            return(TT_ERR_IMAGES_NOT_SAME_SIZE);
         }
      }
   }

   /* --- heritage des donnees pour la structure de pseries ---*/
   pseries->firstelem=(long)(1);
   pseries->nelements=nelem;

   /* --- remplit les dates et le temps de pose ---*/
   tt_ima2jd(pseries->p_in,2,&(pseries->jj[pseries->index-1]));
   tt_ima2exposure(pseries->p_in,2,&(pseries->exptime[pseries->index-1]));

   return(OK_DLL);
}


