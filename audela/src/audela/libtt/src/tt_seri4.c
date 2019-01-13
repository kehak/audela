/* tt_seri4.c
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
#include "focas.h"

int tt_ima_series_test_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Fonction pour faire des tests.                                          */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk;
   double transf_1vers2[20],transf_2vers1[20];
   int nbcom=0, msg;
   double epsilon=0.0,delta=0.0,threshold=0.0;
   if ((msg=focas_main("c:\\toto\\star1.lst",1,"c:\\toto\\star2.lst",1,0,0,0,"com.lst","dif.lst",&nbcom,transf_1vers2,transf_2vers1,NULL,NULL,NULL,epsilon,delta,threshold))!=OK_DLL) {
      msg=1*msg;
      return(msg);
   }
   /* --- fin pour assurer la compatibilite avec IMA/SERIES ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }
   return(OK_DLL);
}

int tt_ima_series_resize_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Coupe ou agrandit le cadre de l'image                                   */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int naxis1,naxis2,x,y,index;
	int naxis11,naxis22;

   /* --- fin pour assurer la compatibilite avec IMA/SERIES ---*/
   index=pseries->index;
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;
   naxis11=pseries->width;
   naxis22=pseries->height;
   tt_imacreater(p_out,naxis11,naxis22);
   for(x=0;x<naxis11;x++) {
      for(y=0;y<naxis22;y++) {
			if ((x>=naxis1)||(y>=naxis2)) {
	         p_out->p[y*naxis11+x]=(TT_PTYPE)(pseries->nullpix_value);
			} else {
	         p_out->p[y*naxis11+x]=(TT_PTYPE)(p_in->p[y*naxis1+x]);
			}
      }
   }
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];
   return(OK_DLL);
}

int tt_ima_series_tilt_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Translation de 'trans_y' pixels par colonne                             */
/* Translation de 'trans_x' pixels par ligne                               */
/* loadima vega-1 ; buf2 imaseries "TILT trans_y=-0.022 trans_y=0"        */
/* loadima vega-2 ; buf2 imaseries "TILT trans_y=0 trans_x=0.1" */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out,*p_tmp1;
   int naxis1,naxis2,x,y,y1,y2,x1,x2,index;
   double xcenter,ycenter,dx,dy,ddx,ddy;
   double alpha,beta;

   /* --- fin pour assurer la compatibilite avec IMA/SERIES ---*/
   index=pseries->index;
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   p_tmp1=pseries->p_tmp1;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;
   xcenter=naxis1/2;
   ycenter=naxis2/2;
   dx=pseries->trans_x;
   dy=pseries->trans_y;
   tt_imacreater(p_tmp1,naxis1,naxis2);
   tt_imacreater(p_out,naxis1,naxis2);
   for(x=0;x<naxis1;x++) {
      ddx=x-xcenter;
      for(y=0;y<naxis2;y++) {
         ddy=ddx*dy;
         alpha=ddy-floor(ddy);
         beta=1.-alpha;
         y1=(int)floor(ddy+y);
         y2=y1+1;
         if ((y1<0)||(y2>=naxis2)) {
            continue;
         }
         p_tmp1->p[y*naxis1+x]=(TT_PTYPE)(beta*p_in->p[y1*naxis1+x]+alpha*p_in->p[y2*naxis1+x]);
      }
   }
   for(y=0;y<naxis2;y++) {
      ddy=y-ycenter;
      for(x=0;x<naxis1;x++) {
         ddx=ddy*dx;
         alpha=ddx-floor(ddx);
         beta=1.-alpha;
         x1=(int)floor(ddx+x);
         x2=x1+1;
         if ((x1<0)||(x2>=naxis1)) {
            continue;
         }
         p_out->p[y*naxis1+x]=(TT_PTYPE)(beta*p_tmp1->p[y*naxis1+x1]+alpha*p_tmp1->p[y*naxis1+x2]);
      }
   }
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];
   return(OK_DLL);
}

int tt_ima_series_smilex_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Unsmile centre sur la ligne ycenter */
/* loadima vega-2 ; buf2 imaseries "SMILEX ycenter=100 coef_smile2=0.0003 coef_smile4=0.0"        */
/* Le parametre optionel Y1 permet d'indiquer l'ordonnees sur laquelle on souhaite recentre l'image horizontallement apres le traitement du smilex */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int naxis1,naxis2,x,y,x1,x2,index;
   double ycenter,ddx,ddy,ddy2,ddy4;
   double alpha,beta;
   double a2,a4;
   double ddy1;

   /* --- fin pour assurer la compatibilite avec IMA/SERIES ---*/
   index=pseries->index;
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;
   ycenter=pseries->ycenter;
   a2=pseries->coef_smile2;
   a4=pseries->coef_smile4;

   if ( pseries->y1 != 0 ) {
      ddy=pseries->y1 - ycenter;
      ddy2=ddy*ddy;
      ddy4=ddy2*ddy2;
      ddy1=a2*ddy2+a4*ddy4;      
   } else {
      ddy1 = 0.0;
   }

   tt_imacreater(p_out,naxis1,naxis2);
   for(y=0;y<naxis2;y++) {
      ddy=y-ycenter;
      ddy2=ddy*ddy;
      ddy4=ddy2*ddy2;
      ddx=a2*ddy2+a4*ddy4 -ddy1;
      alpha=ddx-floor(ddx);
      beta=1.-alpha;
      for(x=0;x<naxis1;x++) {
         x1=(int)floor(ddx)+x;
         x2=x1+1;
         if ((x1<0)||(x2>=naxis1)) {
            continue;
         }
         p_out->p[y*naxis1+x]=(TT_PTYPE)(beta*p_in->p[y*naxis1+x1]+alpha*p_in->p[y*naxis1+x2]);
      }
   }
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];
   return(OK_DLL);
}

int tt_ima_series_smiley_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Unsmile centre sur la colonne xcenter */
/* loadima vega-1 ; buf2 imaseries "SMILEY xcenter=100 coef_smile2=0.0003 coef_smile4=0.0"        */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int naxis1,naxis2,x,y,y1,y2,index;
   double xcenter,ddx,ddy,ddx2,ddx4;
   double alpha,beta;
   double a2,a4;

   /* --- fin pour assurer la compatibilite avec IMA/SERIES ---*/
   index=pseries->index;
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;
   xcenter=pseries->xcenter;
   a2=pseries->coef_smile2;
   a4=pseries->coef_smile4;
   tt_imacreater(p_out,naxis1,naxis2);
   for(x=0;x<naxis1;x++) {
      ddx=x-xcenter;
      ddx2=ddx*ddx;
      ddx4=ddx2*ddx2;
      ddy=a2*ddx2+a4*ddx4;
      alpha=ddy-floor(ddy);
      beta=1.-alpha;
      for(y=0;y<naxis2;y++) {
         y1=(int)floor(ddy)+y;
         y2=y1+1;
         if ((y1<0)||(y2>=naxis2)) {
            continue;
         }
         p_out->p[y*naxis1+x]=(TT_PTYPE)(beta*p_in->p[y1*naxis1+x]+alpha*p_in->p[y2*naxis1+x]);
      }
   }
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];
   return(OK_DLL);
}

int tt_ima_series_astrometry_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Calcul des parametres astrometriques d'une image                        */
/***************************************************************************/
/* le tableau a[6] contient la transformation :                            */
/*  x_cat = a[0]*x_obj + a[1]*y_obj + a[2]                                 */
/*  y_cat = a[3]*x_obj + a[4]*y_obj + a[5]                                 */
/* le tableau b[6] contient la transformation inverse :                    */
/*                                                                         */
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   char message[TT_MAXLIGNE];
   long nelem;
   int msg,index,k,kkk,nb,nb2=0;
   double flux,mag,a[6],b[6],dvalue,cmag,d_cmag,a2[40],b2[40];
   double epsilon,delta,threshold;
   /*double vald; Rajout Thiebaut*/
   FILE *fich;
   char ligne[TT_MAXLIGNE], texte[TT_MAXLIGNE], message_err[TT_MAXLIGNE];
   int nbobj,kk;
   double rien,bckgd,x,y,fwhm;
   char value[FLEN_VALUE];
   time_t ltime;/* Rajout Thiebaut*/
   char obsname[TT_LEN_SHORTFILENAME];
   char comname[TT_LEN_SHORTFILENAME];
   char difname[TT_LEN_SHORTFILENAME];
   int valid=0;
   char mise_enforme0[]="%5d %2d %7.2lf %7.2lf %+8.3lf %7.3lf %10.1lf %10.1lf %9.5lf %9.5lf %+8.4lf %+8.4lf %7.4lf %+8.4lf %7.4lf %3d %3d %10.1lf %7.2lf %7.2lf %7.2lf %7.2lf %7.2lf %7.1f %7.2lf %3d \n";
   int matchingindex;
   TT_ASTROM p_ast;

   sprintf(obsname,"obs%s.lst",tt_tmpfile_ext);
   sprintf(comname,"com%s.lst",tt_tmpfile_ext);
   sprintf(difname,"dif%s.lst",tt_tmpfile_ext);

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   epsilon=pseries->epsilon;
   delta=pseries->delta;
   threshold=pseries->threshold;

   /* --- charge la liste d'objets associee ---*/
   if (strcmp(pseries->objefile,"")==0) {
      if ((msg=tt_tblobjloader(p_in,p_in->load_fullname))!=0) {
		   sprintf(message,"Pb from tt_tblobjloader in tt_ima_series_astrometry_1");
	      tt_errlog(pseries->tmp_dir,msg,message);
		   return(msg);
		}
		/* --- calcule une magnitude relative ---*/
		for (k=0;k<p_in->objelist->nrows;k++) {
		   flux=p_in->objelist->flux[k];
		   mag=(flux>0)?-2.5*log(flux)/(TT_LN10):(double)(TT_MAGNULL);
		   p_in->objelist->mag[k]=mag;
		}
   } else { /* Rajout Thiebaut*/
      if (strcmp(pseries->objefiletype,"TAROTCAT1")==0) {
         /* 1ere etape : chargement du catalogue et calcul du nbre d'objets (nbobj)*/
	      if ((fich=fopen(pseries->objefile,"rt"))==NULL) {
            msg=TT_ERR_FILE_NOT_FOUND;
			   sprintf(message_err,"File %s not found in tt_imaseries_astrometry_1",pseries->objefile);
			   tt_errlog(pseries->tmp_dir,msg,message_err);
			   return(msg);
         }
		   nbobj=0;
         k=0;
		   do
         {	if (fgets(ligne,TT_MAXLIGNE,fich)!=NULL)
            {	strcpy(texte,"");
				   sscanf(ligne,"%s",texte);
				   if (strcmp(texte,"")!=0) {
                  k++;
                  if (valid>0) {
                     nbobj++;
                  }
                  if (strlen(texte)>15) {
                     texte[9]='\0';
                     if (strcmp(texte,"123456789")==0) {
                        valid=k; /* nb de lignes de l'entete a passer */
                     }
                  }
               }
			   }
		   }while (feof(fich)==0);
		   fclose(fich);
		   /* 2eme etape : On remplit p_in->objelist en scannant le catalogue Sextractor */
		   if (nbobj>0)
		   {	tt_tblobjcreater(p_in->objelist,nbobj);
   			if ((fich=fopen(pseries->objefile,"rt"))==NULL)
			   {	msg=TT_ERR_FILE_NOT_FOUND;
   				sprintf(message_err,"File catalog.cat (%d sources) not found in tt_imaseries_astrometry_1",nbobj);
				   tt_errlog(pseries->tmp_dir,msg,message_err);
				   return(msg);
			   }
			   k=0;
            kk=0;
			   do
			   {	if (fgets(ligne,TT_MAXLIGNE,fich)!=NULL)
   				{	strcpy(texte,"");
					   sscanf(ligne,"%s",texte);
                  if ((strcmp(texte,"")!=0)) {
                     kk++;
                     if (kk<valid) { continue; }
					      sscanf(ligne,mise_enforme0,
                        &rien,&matchingindex,&x,&y,&rien,
                        &rien,&flux,&rien,&rien,&rien,
                        &mag,&rien,&rien,&rien,&rien,
                        &rien,&rien,&bckgd,&rien,&rien,
                        &rien,&rien,&rien,&rien,&fwhm,
                        &rien);
   						p_in->objelist->x[k]=x-1.; /* -1 de sextractor */
						   p_in->objelist->y[k]=y-1.;
						   p_in->objelist->flux[k]=flux;
						   p_in->objelist->mag[k]=mag;
						   p_in->objelist->background[k]=bckgd;
						   p_in->objelist->fwhmx[k]=fwhm;
						   p_in->objelist->fwhmy[k]=fwhm;
						   p_in->objelist->ident[k]=(short)(TT_STAR);
						   p_in->objelist->intensity[k]=1.;
						   k++;
					   }
				   }
			   }while (feof(fich)==0);
			   fclose(fich);
		   for (k=0,kk=0;k<p_in->objelist->nrows;k++) {
   			if (p_in->objelist->mag[k]==99.) {
				   p_in->objelist->ident[k]=(short)(TT_DUMMY);
				   kk++;
			   }
		   }
   		pseries->nbstars=nbobj;
		   pseries->fwhm=fwhm;
		   pseries->d_fwhm=(short)0;
		   }
      } else {
         /* Rajout Thiebaut*/
         /* 1ere etape : chargement du catalogue Sextractor et calcul du nbre d'objets (nbobj)*/
	      if ((fich=fopen(pseries->objefile,"rt"))==NULL) {
            msg=TT_ERR_FILE_NOT_FOUND;
			   sprintf(message_err,"File %s not found in tt_imaseries_astrometry_1",pseries->objefile);
			   tt_errlog(pseries->tmp_dir,msg,message_err);
			   return(msg);
         }
		   nbobj=0;
		   do
         {	if (fgets(ligne,TT_MAXLIGNE,fich)!=NULL)
            {	strcpy(texte,"");
				   sscanf(ligne,"%s",texte);
				   if (strcmp(texte,"")!=0)
				   {nbobj++;}
			   }
		   }while (feof(fich)==0);
		   fclose(fich);
		   /* 2eme etape : On remplit p_in->objelist en scannant le catalogue Sextractor */
		   if (nbobj>0)
		   {	tt_tblobjcreater(p_in->objelist,nbobj);
   			if ((fich=fopen(pseries->objefile,"rt"))==NULL)
			   {	msg=TT_ERR_FILE_NOT_FOUND;
   				sprintf(message_err,"File catalog.cat (%d sources) not found in tt_imaseries_astrometry_1",nbobj);
				   tt_errlog(pseries->tmp_dir,msg,message_err);
				   return(msg);
			   }
			   k=0;
			   do
			   {	if (fgets(ligne,TT_MAXLIGNE,fich)!=NULL)
   				{	strcpy(texte,"");
					   sscanf(ligne,"%s",texte);
					   if ((strcmp(texte,"")!=0))
					   {	sscanf(ligne,"%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf",&rien,&flux,&rien,&mag,&rien,&bckgd,&x,&y,&rien,&rien,&rien,&rien,&rien,&rien,&fwhm,&rien,&rien);
   						p_in->objelist->x[k]=x-1.; /* -1 de sextractor */
                     /* test pour TAROT
                     if (x>1034) {
   						   p_in->objelist->x[k]=x-1.+4.;
                     }
                     */
						   p_in->objelist->y[k]=y-1.;
						   p_in->objelist->flux[k]=flux;
						   p_in->objelist->mag[k]=mag;
						   p_in->objelist->background[k]=bckgd;
						   p_in->objelist->fwhmx[k]=fwhm;
						   p_in->objelist->fwhmy[k]=fwhm;
						   p_in->objelist->ident[k]=(short)(TT_STAR);
						   p_in->objelist->intensity[k]=1.;
						   k++;
					   }
				   }
			   }while (feof(fich)==0);
			   fclose(fich);
		   for (k=0,kk=0;k<p_in->objelist->nrows;k++) {
   			if (p_in->objelist->mag[k]==99.) {
				   p_in->objelist->ident[k]=(short)(TT_DUMMY);
				   kk++;
			   }
		   }
   		pseries->nbstars=nbobj;
		   pseries->fwhm=fwhm;
		   pseries->d_fwhm=(short)0;
		   }
      }
   }

   /* --- charge la liste de catalogue associee ---*/
   if ((msg=tt_tblcatloader(p_in,p_in->load_fullname))!=0) {
      sprintf(message,"Pb from tt_tblcatloader in tt_ima_series_astrometry_1");
      tt_errlog(pseries->tmp_dir,msg,message);
      return(msg);
   }
   /* --- appel a focas ---*/
   if ((msg=tt_util_focas0(p_in,epsilon,delta,threshold,a,b,&nb,&cmag,&d_cmag,a2,b2,&nb2))!=OK_DLL) {
      return(msg);
   }

   /* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- on complete ou modifie l'entete ---*/
   tt_imanewkey(p_out,"CATASTAR",&(nb),TINT,"Number stars matched from catalog","");
   if (nb>0) {
      tt_imanewkey(p_out,"CMAGR",&(cmag),TDOUBLE,"m=CMAG-2.5*log(pseries->tmp_dir,Flux)","magR");
      tt_imanewkey(p_out,"D_CMAGR",&(d_cmag),TDOUBLE,"rms error for CMAGR","magR");
   }
   /* Rajout Thiebaut*/
   if (strcmp(pseries->objefile,"")!=0)
   {	tt_imanewkey(p_out,"NBSTARS",&(pseries->nbstars),TINT,"Number stars detected","");
		tt_imanewkey(p_out,"FWHM",&(pseries->fwhm),TDOUBLE,"Full Width at Half Maximum","pixels");
		tt_imanewkey(p_out,"D_FWHM",&(pseries->d_fwhm),TDOUBLE,"dispersion in FWHM","pixels");
		time( &ltime );
		strftime(value,FLEN_VALUE,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
		srand( (unsigned)time( NULL ) );
		sprintf(pseries->p_out->objekey,"%s:%d",value,rand());
		tt_imanewkey(p_out,"OBJEKEY",pseries->p_out->objekey,TSTRING,"Link key for objefile","");
		strcpy(pseries->p_out->objelist_fullname,pseries->objefile);
	}
   /* Rajout Thiebaut*/

   /* --- calcule les nouveaux parametres de projection ---*/
   tt_util_update_wcs(p_in,p_out,a,1,&p_ast);
   if (nb>50) {
      /* --- pour les parametres d'ordre 2, on met un garde fou a 50 etoiles */
#ifdef TT_DISTORASTROM
      tt_util_set_pv(p_out,a,a2,&p_ast);
#else
      /*tt_util_set_pv(p_out,a,a2,NULL);*/
#endif
   }
   /* --- cas ou l'on demande d'ecrire un fichier ASCII en sortie ---*/
   if (strcmp(pseries->file_ascii,"")!=0) {
		if (strcmp(pseries->objefile,"")==0)
		{tt_util_fichs_comdif(&p_ast,cmag,obsname,comname,difname,pseries->file_ascii,pseries->objefiletype);}
		else
		{tt_util_fichs_comdif(&p_ast,cmag,pseries->objefile,comname,difname,pseries->file_ascii,pseries->objefiletype);}
   }

	pseries->object_list=TT_NO;
	pseries->fwhm_compute=TT_NO;
	strcpy(pseries->objefile,"");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_ima_series_resample_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Anamorphose lineaire d'un lot d'images                                  */
/***************************************************************************/
/* le tableau a[6] contient la transformation :                            */
/*  x_in/tmp1 = a[0]*x_in/in + a[1]*y_in/in + a[2]                         */
/*  y_in/tmp1 = a[3]*x_in/in + a[4]*y_in/in + a[5]                         */
/*                                                                         */
/* - mots optionels utilisables et valeur par defaut :                     */
/* paramresample = "1 0 0 0 1 0"                                           */
/*              contient les coefficients a[].                             */
/*                                                                         */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   char message[TT_MAXLIGNE];
   int index,k;
   double a[6],b[6],delta,x[5],y[5],x0,y0;
   TT_COEFA *p_dum=NULL,*p_dum0=NULL;
   char **keys;
   int nbkeys;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;

   /* --- decodage des parametres de projection ---*/
   if (index>=1) {
      tt_decodekeys(pseries->paramresample,(void***)&keys,&nbkeys);
      if (nbkeys==6) {
         /* --- le nombre parametres est bon ---*/
         for (k=0;k<nbkeys;k++) {
            b[k]=(double)atof(keys[k]);
         }
         /* --- on effectue la transformation inverse ---*/
         delta=b[1]*b[3]-b[0]*b[4];
         if (fabs(delta)<=TT_EPS_DOUBLE) {
            /* --- le deteminant est nul ---*/
            tt_util_free_ptrptr((void**)keys,"keys");
	    strcpy(message,"Not a regular transformation. Determinant is zero.");
	    tt_errlog(pseries->tmp_dir,TT_ERR_PARAMRESAMPLE_IRREGULAR,message);
	    return(TT_ERR_PARAMRESAMPLE_IRREGULAR);
         }
         a[0]=-b[4]/delta;
         a[1]= b[1]/delta;
         a[2]=(b[2]*b[4]-b[1]*b[5])/delta;
         a[3]= b[3]/delta;
         a[4]=-b[0]/delta;
         a[5]=(b[0]*b[5]-b[2]*b[3])/delta;
         pseries->coefa[index-1]=pseries->coefa[0];
         p_dum=&(pseries->coefa[index-1]);
         /*p_dum=&(pseries->coefa[0]);*/
         for (k=0;k<6;k++) {
            p_dum->a[k]=a[k];
         }
         /* --- determine les dimensions de l'image de sortie ---*/
         x0=0;y0=0;
         x[0]=b[0]*x0+b[1]*y0+b[2];
         y[0]=b[3]*x0+b[4]*y0+b[5];
         x0=p_in->naxis1;y0=0;
         x[1]=b[0]*x0+b[1]*y0+b[2];
         y[1]=b[3]*x0+b[4]*y0+b[5];
         x0=0;y0=p_in->naxis2;
         x[2]=b[0]*x0+b[1]*y0+b[2];
         y[2]=b[3]*x0+b[4]*y0+b[5];
         x0=p_in->naxis1;y0=p_in->naxis2;
         x[3]=b[0]*x0+b[1]*y0+b[2];
         y[3]=b[3]*x0+b[4]*y0+b[5];
         tt_util_qsort_double(x,0,4,NULL);
         tt_util_qsort_double(y,0,4,NULL);
         /* --- on limite la taille de l'image de sortie a 10000x10000 ---*/
         if (x[3]<1.) {x[3]=1.;}
         if (x[3]>10000.) {x[3]=10000.;}
         if (y[3]<1.) {y[3]=1.;}
         if (y[3]>10000.) {y[3]=10000.;}
         pseries->outnaxis1=(int)(x[3]);
         pseries->outnaxis2=(int)(y[3]);
      } else {
         /* --- le nombre parametres n'est pas bon ---*/
         tt_util_free_ptrptr((void**)keys,"keys");
	 sprintf(message,"The number of parameters in option paramresample is %d instead of 6",nbkeys);
	 tt_errlog(pseries->tmp_dir,TT_ERR_PARAMRESAMPLE_NUMBER,message);
         return(TT_ERR_PARAMRESAMPLE_NUMBER);
      }
      tt_util_free_ptrptr((void**)keys,"keys");
      /* --- determination des dimensions de sortie (a faire) ---*/
      /* --- transformer les 4 coins et decider... */
   } else {
      p_dum0=&(pseries->coefa[0]);
      for (k=0;k<6;k++) {
         p_dum->a[k]=p_dum0->a[k];
      }
   }

   /* --- calcul de la fonction ---*/
   tt_imacreater(p_out,pseries->outnaxis1,pseries->outnaxis2);
   tt_util_regima1(pseries);

   /* --- calcule les nouveaux parametres de projection ---*/
   tt_util_update_wcs(p_in,p_out,a,2,NULL);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_ima_series_register_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Registration d'un lot d'images                                          */
/***************************************************************************/
/* le tableau a[6] contient la transformation :                            */
/*  x_in/tmp1 = a[0]*x_in/in + a[1]*y_in/in + a[2]                         */
/*  y_in/tmp1 = a[3]*x_in/in + a[4]*y_in/in + a[5]                         */
/*                                                                         */
/* - mots optionels utilisables et valeur par defaut :                     */
/* translate = only before after never  (before par defaut).               */
/*             contrainte sur les translations.                            */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_out;
   char message[TT_MAXLIGNE];
   long firstelem,nelem_tmp;
   int msg,index,trans_ok,k;
   double a[6],aa[6],bb[6],*b;
   int nbmatched_trans,nbmatched_focas;
   TT_COEFA *p_dum;
   int matchwcs;
   TT_ASTROM p_ast;
   double x[4],y[4],xp[4],yp[4],ra[4],dec[4],delta;
   int k1,k2;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_out=pseries->p_out;
   index=pseries->index;
   matchwcs=pseries->matchwcs;
   /* --- recopie l'image d'index 1 dans l'image de reference (tmp1) ---*/
   if (index==1) {
      /*tt_imabuilder(p_tmp1);*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      if ((msg=tt_imaloader(p_tmp1,p_in->load_fullname,firstelem,nelem_tmp))!=0) {
	 sprintf(message,"Problem concerning file %s",p_in->load_fullname);
	 tt_errlog(pseries->tmp_dir,msg,message);
	 return(msg);
      }
      /* --- verification des dimensions ---*/
      /*
      if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
	 sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
	 tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
	 return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
      */
      if (matchwcs==0) {
         /* --- charge la liste d'objets associee ---*/
         if ((msg=tt_tblobjloader(p_tmp1,p_tmp1->load_fullname))!=0) {
	    sprintf(message,"No OBJELIST %s associated to file %s",p_tmp1->objelist_fullname,p_tmp1->load_fullname);
	    tt_errlog(pseries->tmp_dir,msg,message);
	    return(msg);
         }
      }
   }

   /* --- matching des listes ---*/
   nbmatched_trans=0;
   nbmatched_focas=0;
   a[0]=a[4]=1.;
   a[1]=a[2]=a[3]=a[5]=0.;
   aa[0]=aa[4]=1.;
   aa[1]=aa[2]=aa[3]=aa[5]=0.;
   if (matchwcs==0) {
      if (index>1) {
         /* --- charge la liste d'objets associee ---*/
         if ((msg=tt_tblobjloader(p_in,p_in->load_fullname))!=0) {
   	    sprintf(message,"No OBJELIST %s associated to file %s",p_in->objelist_fullname,p_in->load_fullname);
	    tt_errlog(pseries->tmp_dir,msg,message);
	    return(msg);
         }
         /* --- calcule les coefficients de transformation ---*/
         nbmatched_trans=0;
         nbmatched_focas=0;
         if ((pseries->regitrans==TT_REGITRANS_ONLY)||(pseries->regitrans==TT_REGITRANS_BEFORE)) {
	    if ((msg=tt_util_match_translate(p_tmp1,p_in,a,&nbmatched_trans))!=OK_DLL) {
	       tt_errlog(pseries->tmp_dir,msg,"Problem in list matching");
	       return(msg);
            }
         }
         if ((pseries->regitrans==TT_REGITRANS_BEFORE)||(pseries->regitrans==TT_REGITRANS_AFTER)||(pseries->regitrans==TT_REGITRANS_NEVER)) {
	    if ((msg=tt_util_focas1(p_tmp1,p_in,aa,bb,&nbmatched_focas,0))!=OK_DLL) {
	       tt_errlog(pseries->tmp_dir,msg,"Problem in list matching");
	       return(msg);
            }
         }
         if (pseries->regitrans==TT_REGITRANS_AFTER) {
	    if ((msg=tt_util_match_translate(p_tmp1,p_in,a,&nbmatched_trans))!=OK_DLL) {
	       tt_errlog(pseries->tmp_dir,msg,"Problem in list matching");
	       return(msg);
            }
         }
      } else {
         nbmatched_trans=p_tmp1->objelist->nrows;
         nbmatched_focas=p_tmp1->objelist->nrows;
      }
   } else {
      /* --- on matche sur les WCS ---*/
      msg=tt_util_getkey_astrometry(p_in,&p_ast);
      if (index==1) {
         pseries->p_ast.crota2=p_ast.crota2;
         pseries->p_ast.foclen=p_ast.foclen;
         pseries->p_ast.px=p_ast.px;
         pseries->p_ast.py=p_ast.py;
         pseries->p_ast.crota2=p_ast.crota2;
         pseries->p_ast.cd11=p_ast.cd11;
         pseries->p_ast.cd12=p_ast.cd12;
         pseries->p_ast.cd21=p_ast.cd21;
         pseries->p_ast.cd22=p_ast.cd22;
         pseries->p_ast.crpix1=p_ast.crpix1;
         pseries->p_ast.crpix2=p_ast.crpix2;
         pseries->p_ast.crval1=p_ast.crval1;
         pseries->p_ast.crval2=p_ast.crval2;
         pseries->p_ast.cdelta1=p_ast.cdelta1;
         pseries->p_ast.cdelta2=p_ast.cdelta2;
         pseries->p_ast.dec0=p_ast.dec0;
         pseries->p_ast.ra0=p_ast.ra0;
         for (k1=1;k1<=2;k1++) {
            for (k2=0;k2<=10;k2++) {
               pseries->p_ast.pv[k1][k2]=p_ast.pv[k1][k2];
            }
         }
      }
      xp[1]=pseries->p_ast.crpix1;
      yp[1]=pseries->p_ast.crpix2;
      xp[2]=pseries->p_ast.crpix1+0.4*p_in->naxis1;
      yp[2]=pseries->p_ast.crpix2;
      xp[3]=pseries->p_ast.crpix1;
      yp[3]=pseries->p_ast.crpix2+0.4*p_in->naxis2;
      for (k=1;k<=3;k++) {
         tt_util_astrom_xy2radec(&pseries->p_ast,xp[k],yp[k],&ra[k],&dec[k]);
      }
      for (k=1;k<=3;k++) {
         tt_util_astrom_radec2xy(&p_ast,ra[k],dec[k],&x[k],&y[k]);
      }
      delta = (y[1]-y[2])*(x[3]-x[2]) - (y[3]-y[2])*(x[1]-x[2]);
      a[1] = ( (x[3]-x[2])*(xp[1]-xp[2]) - (x[1]-x[2])*(xp[3]-xp[2]) ) / delta;
      a[0] = ( - (y[3]-y[2])*(xp[1]-xp[2]) + (y[1]-y[2])*(xp[3]-xp[2]) ) / delta;
      a[2] = xp[1] - a[0]*x[1] - a[1]*y[1];
      a[4] = ( (x[3]-x[2])*(yp[1]-yp[2]) - (x[1]-x[2])*(yp[3]-yp[2]) ) / delta;
      a[3] = ( - (y[3]-y[2])*(yp[1]-yp[2]) + (y[1]-y[2])*(yp[3]-yp[2]) ) / delta;
      a[5] = yp[1] - a[3]*x[1] - a[4]*y[1];
      delta=a[1]*a[3]-a[0]*a[4];
      aa[0]=-a[4]/delta;
      aa[1]= a[1]/delta;
      aa[2]=-(a[1]*a[5]-a[2]*a[4])/delta;
      aa[3]= a[3]/delta;
      aa[4]=-a[0]/delta;
      aa[5]=-(a[2]*a[3]-a[0]*a[5])/delta;
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   /*tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);*/
   tt_imacreater(p_out,pseries->naxis1_1,pseries->naxis2_1);
   trans_ok=TT_YES;
   if (pseries->regitrans==TT_REGITRANS_NEVER) {
      trans_ok=TT_NO;
   } else if (pseries->regitrans==TT_REGITRANS_AFTER) {
      if (nbmatched_focas>2) {
	 trans_ok=TT_NO;
      } else {
	 trans_ok=TT_YES;
      }
   } else if (pseries->regitrans==TT_REGITRANS_BEFORE) {
      if ((nbmatched_trans<2)&&(nbmatched_focas>2)) {
	 trans_ok=TT_NO;
      } else {
	 trans_ok=TT_YES;
      }
   } else if (pseries->regitrans==TT_REGITRANS_ONLY) {
      trans_ok=TT_YES;
   }
   if (matchwcs==1) {
      trans_ok=TT_NO;
   }
   if (trans_ok==TT_YES) {
      b=a;
      pseries->nbmatched=nbmatched_trans;
   } else {
      b=aa;
      pseries->nbmatched=nbmatched_focas;
   }
   p_dum=&(pseries->coefa[index-1]);
   for (k=0;k<6;k++) {
      p_dum->a[k]=b[k];
   }
   tt_util_regima1(pseries);

   /* --- calcule les nouveaux parametres de projection ---*/
   tt_util_update_wcs(p_in,p_out,b,2,NULL);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_ima_series_registerfine_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Translation d'un lot d'images par autocorrelation spatiale              */
/***************************************************************************/
/*                                                                         */
/* - mots optionels utilisables et valeur par defaut :                     */
/* oversampling = 4                                                        */
/* delta = 1 pixel (+/- delta pixels)                                      */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_tmp2,*p_out;
   char fullname[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   long nelem,firstelem,nelem_tmp;
   double value,delta,trans_x,trans_y,trans_x0,trans_y0,dtrans;
   int msg,kkk,index,kx,ky,deltaint;
   int oversampling;
   double residumin,residu;
   double a[6];

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_tmp2=pseries->p_tmp2;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   oversampling=pseries->oversampling;
   delta=pseries->delta;

   /* --- charge l'image file dans p_tmp1---*/
   if (index==1) {
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->file);
      if ((msg=tt_imaloader(p_tmp1,fullname,firstelem,nelem_tmp))!=0) {
	 sprintf(message,"[tt_ima_series_registerfine_1] Problem concerning file %s",fullname);
	 tt_errlog(pseries->tmp_dir,msg,message);
	 return(msg);
      }
      if ((msg=tt_imacreater(p_tmp2,p_in->naxis1,p_in->naxis2))!=0) {
	 sprintf(message,"[tt_ima_series_registerfine_1] Can not initialize p_tmp2");
	 tt_errlog(pseries->tmp_dir,msg,message);
	 return(msg);
      }
   }

   /* --- verification des dimensions ---*/
   if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
      sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
      tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
      return(TT_ERR_IMAGES_NOT_SAME_SIZE);
   }

   /* --- allocation de l'image de sortie ---*/
   if ((msg=tt_imacreater(p_out,p_in->naxis1,p_in->naxis2))!=0) {
      sprintf(message,"[tt_ima_series_registerfine_1] Can not initialize p_out");
      tt_errlog(pseries->tmp_dir,msg,message);
      return(msg);
   }

   /* --- copie l'image initiale dans p_tmp2 ---*/
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk];
      p_tmp2->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- n sort si la zone d'exploration est impossible --- */
   if ((oversampling<=0)||(delta==0.)) {
      /* --- calcul des temps ---*/
      pseries->jj_stack=pseries->jj[index-1];
      pseries->exptime_stack=pseries->exptime[index-1];
      return(OK_DLL);
   }

   delta=fabs(delta);
   deltaint=(int)ceil(delta);
   dtrans=1./oversampling;
   /* --- calcul de la meilleure translation ---*/
   residumin=TT_MAX_DOUBLE;
   trans_x0=0.;
   trans_y0=0.;
   for (trans_x=0;trans_x<=delta/2;trans_x+=dtrans) {
      for (trans_y=0;trans_y<=delta/2;trans_y+=dtrans) {
         /* --- debut du calcul du residu ---*/
         for (kkk=0;kkk<(int)(nelem);kkk++) { value=p_tmp2->p[kkk]; p_in->p[kkk]=(TT_PTYPE)(value); }
         tt_util_transima1(pseries,trans_x,trans_y);
         residu=0.;
         for (kx=deltaint;kx<p_in->naxis1-deltaint;kx++) {
            for (ky=deltaint;ky<p_in->naxis2-deltaint;ky++) {
               kkk=kx*p_in->naxis2+ky;
               value=p_out->p[kkk]-p_tmp1->p[kkk]; 
               residu+=(value*value);
            }
         }
         if (residu<residumin) {
            residumin=residu;
            trans_x0=trans_x;
            trans_y0=trans_y;
         }
         /* --- fin du calcul du residu ---*/
         if (trans_y==0) { continue; }
         trans_y=-trans_y;
         /* --- debut du calcul du residu ---*/
         for (kkk=0;kkk<(int)(nelem);kkk++) { value=p_tmp2->p[kkk]; p_in->p[kkk]=(TT_PTYPE)(value); }
         tt_util_transima1(pseries,trans_x,trans_y);
         residu=0.;
         for (kx=deltaint;kx<p_in->naxis1-deltaint;kx++) {
            for (ky=deltaint;ky<p_in->naxis2-deltaint;ky++) {
               kkk=kx*p_in->naxis2+ky;
               value=p_out->p[kkk]-p_tmp1->p[kkk]; 
               residu+=(value*value);
            }
         }
         if (residu<residumin) {
            residumin=residu;
            trans_x0=trans_x;
            trans_y0=trans_y;
         }
         /* --- fin du calcul du residu ---*/
         trans_y=-trans_y;
      }
      if (trans_x==0) { continue; }
      trans_x=-trans_x;
      for (trans_y=0;trans_y<=delta/2;trans_y+=dtrans) {
         /* --- debut du calcul du residu ---*/
         for (kkk=0;kkk<(int)(nelem);kkk++) { value=p_tmp2->p[kkk]; p_in->p[kkk]=(TT_PTYPE)(value); }
         tt_util_transima1(pseries,trans_x,trans_y);
         residu=0.;
         for (kx=deltaint;kx<p_in->naxis1-deltaint;kx++) {
            for (ky=deltaint;ky<p_in->naxis2-deltaint;ky++) {
               kkk=kx*p_in->naxis2+ky;
               value=p_out->p[kkk]-p_tmp1->p[kkk]; 
               residu+=(value*value);
            }
         }
         if (residu<residumin) {
            residumin=residu;
            trans_x0=trans_x;
            trans_y0=trans_y;
         }
         /* --- fin du calcul du residu ---*/
         if (trans_y==0) { continue; }
         trans_y=-trans_y;
         /* --- debut du calcul du residu ---*/
         for (kkk=0;kkk<(int)(nelem);kkk++) { value=p_tmp2->p[kkk]; p_in->p[kkk]=(TT_PTYPE)(value); }
         tt_util_transima1(pseries,trans_x,trans_y);
         residu=0.;
         for (kx=deltaint;kx<p_in->naxis1-deltaint;kx++) {
            for (ky=deltaint;ky<p_in->naxis2-deltaint;ky++) {
               kkk=kx*p_in->naxis2+ky;
               value=p_out->p[kkk]-p_tmp1->p[kkk]; 
               residu+=(value*value);
            }
         }
         if (residu<residumin) {
            residumin=residu;
            trans_x0=trans_x;
            trans_y0=trans_y;
         }
         /* --- fin du calcul du residu ---*/
         trans_y=-trans_y;
      }
      trans_x=-trans_x;
   }

   /* --- effectue la meilleure translation ---*/
   for (kkk=0;kkk<(int)(nelem);kkk++) { value=p_tmp2->p[kkk]; p_in->p[kkk]=(TT_PTYPE)(value); }
   tt_util_transima1(pseries,trans_x0,trans_y0);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   /* --- calcule les nouveaux parametres de projection ---*/
   a[0]=1.;
   a[1]=0.;
   a[2]=-trans_x0;
   a[3]=0.;
   a[4]=1.;
   a[5]=-trans_y0;
   tt_util_update_wcs(p_in,p_out,a,2,NULL);

	/* --- nouveaux mots cles ---*/
   tt_imanewkey(p_out,"OPT_DX",&trans_x0,TDOUBLE,"TT Registerfine trans_x","pix");
   tt_imanewkey(p_out,"OPT_DY",&trans_y0,TDOUBLE,"TT Registerfine trans_y","pix");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_stat_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* statistiques sur une serie d'images                                     */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* pixelsat_value=(max de bitpix)                                          */
/* skylevel (pas d'arguments) pour indiquer le skylevel dans le header.    */
/* fwhm (pas d'arguments) pour calculer fwhm, nbstars                      */
/* objefile= nom du fichier fits qui enregistre la liste des objets.       */
/* pixefile= nom du fichier fits qui enregistre la liste des pixels.       */
/* NB : fwhm est automatiquement active si l'on a demande objefile ou      */
/*      pixefile.                                                          */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index,msg;
   double pixelsat_value;
   char value[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   float mipslo,mipshi;
   time_t ltime;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   pixelsat_value=pseries->pixelsat_value;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=(double)p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- raz des variables a calculer ---*/
   pseries->mean=0.;
   pseries->sigma=0.;
   pseries->mini=0.;
   pseries->maxi=0.;
   pseries->nbpixsat=0;
   pseries->bgmean=0.;
   pseries->bgsigma=0.;
   pseries->hicut=1.;
   pseries->locut=0.;
   pseries->contrast=0.;

   /* --- calcul des mini maxi mea sigma et nbpixsat ---*/
   tt_util_statima(p_out,pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
   tt_imanewkey(p_out,"MEAN",&(pseries->mean),TDOUBLE,"mean value for all pixels","adu");
   tt_imanewkey(p_out,"SIGMA",&(pseries->sigma),TDOUBLE,"std sigma value for all pixels","adu");
   tt_imanewkey(p_out,"DATAMAX",&(pseries->maxi),TDOUBLE,"maximum value for all pixels","adu");
   tt_imanewkey(p_out,"DATAMIN",&(pseries->mini),TDOUBLE,"minimum value for all pixels","adu");
   if (pseries->pixelsat_compute==TT_YES) {
      sprintf(comment,"nb of satur. pix. (>=%f adu)",pixelsat_value);
      tt_imanewkey(p_out,"NBPIXSAT",&(pseries->nbpixsat),TINT,comment,"");
   }

   /* --- Calcul des parametres de fond de ciel ---*/
   tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
   tt_imanewkey(p_out,"BGMEAN",&(pseries->bgmean),TDOUBLE,"mean value for background pixels","adu");
   tt_imanewkey(p_out,"BGSIGMA",&(pseries->bgsigma),TDOUBLE,"std sigma value for background pixels","adu");
   if (pseries->skylevel_compute==TT_YES) {
      tt_imanewkey(p_out,"SKYLEVEL",&(pseries->bgmean),TDOUBLE,"Sky level for photometric use","adu");
   }

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_cuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);
   mipshi=(float)(pseries->hicut);
   mipslo=(float)(pseries->locut);
   tt_imanewkey(p_out,"MIPS-HI",&(mipshi),TFLOAT,"High cut for visualisation for MiPS","adu");
   tt_imanewkey(p_out,"MIPS-LO",&(mipslo),TFLOAT,"Low cut for visualisation for MiPS","adu");
   /*
   sprintf(value,"%lf",pseries->hicut);
   tt_imanewkey(p_out,"HI_CUT",value,TSTRING,"High cut for visualisation","adu");
   sprintf(value,"%lf",pseries->locut);
   tt_imanewkey(p_out,"LO_CUT",value,TSTRING,"Low cut for visualisation","adu");
   */

   /* --- Calcul du critere de qualite planetaire ---*/
   tt_util_contrast(p_out,&(pseries->contrast));
   tt_imanewkey(p_out,"CONTRAST",&(pseries->contrast),TDOUBLE,"Pixel contrast","adu");

   /* --- Calcul des pixels et des objets au pixel pres ---*/
   if ((pseries->fwhm_compute==TT_YES)||(pseries->object_list==TT_YES)||(pseries->pixel_list==TT_YES)) {
      if ((msg=tt_util_listpixima(p_out,pseries))!=OK_DLL) {
	 return(msg);
      }
      tt_imanewkey(p_out,"NBSTARS",&(pseries->nbstars),TINT,"Number stars detected","");
      tt_imanewkey(p_out,"FWHM",&(pseries->fwhm),TDOUBLE,"Full Width at Half Maximum","pixels");
      tt_imanewkey(p_out,"D_FWHM",&(pseries->d_fwhm),TDOUBLE,"dispersion in FWHM","pixels");
   }

   /* --- Parametres des listes de pixels et d'objets ---*/
   time( &ltime );
   strftime(value,FLEN_VALUE,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
   srand( (unsigned)time( NULL ) );
   if (pseries->pixel_list==TT_YES) {
      sprintf(pseries->p_out->pixekey,"%s:%d",value,rand());
      tt_imanewkey(p_out,"PIXEKEY",pseries->p_out->pixekey,TSTRING,"Link key for pixefile","");
      if (strcmp(pseries->pixefile,"")!=0) {
	 strcpy(pseries->p_out->pixelist_fullname,pseries->pixefile);
      }
   }
   if (pseries->object_list==TT_YES) {
      sprintf(pseries->p_out->objekey,"%s:%d",value,rand());
      tt_imanewkey(p_out,"OBJEKEY",pseries->p_out->objekey,TSTRING,"Link key for objefile","");
      if (strcmp(pseries->objefile,"")!=0) {
	 strcpy(pseries->p_out->objelist_fullname,pseries->objefile);
      }
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_cuts_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Calcule les seuils de visu sur une serie d'images                       */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* keyhicut= mot cle FITS pour le seuil haut (MIPS-HI)                     */
/* keylocut= mot cle FITS pour le seuil bas (MIPS-LO)                      */
/* keytype= type de la valeur FITS (INT par defaut, FLOAT, STRING)         */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue,mode,mini,maxi;
   int kkk,index;
   char value[FLEN_VALUE];
   char commenthi[FLEN_COMMENT];
   char commentlo[FLEN_COMMENT];
   int hicut_int,locut_int;
   float hicut_float,locut_float,mode_float,mini_float,maxi_float,contrast_float;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   tt_strupr(pseries->keyhicut);
   tt_strupr(pseries->keylocut);
   tt_strupr(pseries->keytype);

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=(double)p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- raz des variables a calculer ---*/
   pseries->hicut=1.;
   pseries->locut=0.;

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_histocuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode,&maxi,&mini);

   /* --- complete l'entete FITS ---*/
   mode_float=(float)mode;
   tt_imanewkey(p_out,"CUTSMODE",&(mode_float),TFLOAT,"Mode from cuts analysis","adu");
   mini_float=(float)mini;
   tt_imanewkey(p_out,"CUTSMIN",&(mini_float),TFLOAT,"Min from cuts analysis","adu");
   maxi_float=(float)maxi;
   tt_imanewkey(p_out,"CUTSMAX",&(maxi_float),TFLOAT,"Max from cuts analysis","adu");
   contrast_float=(float)pseries->cutscontrast;
   tt_imanewkey(p_out,"CUTSCONT",&(contrast_float),TFLOAT,"Contrast for cuts analysis","adu");
   strcpy(commenthi,"High cut for visualisation");
   strcpy(commentlo,"Low cut for visualisation");
   if (strcmp(pseries->keytype,"INT")==0) {
      hicut_int=(int)(pseries->hicut);
      locut_int=(int)(pseries->locut);
	  tt_imanewkey(p_out,pseries->keyhicut,&(hicut_int),TINT,commenthi,"adu");
      tt_imanewkey(p_out,pseries->keylocut,&(locut_int),TINT,commentlo,"adu");
   } else if (strcmp(pseries->keytype,"FLOAT")==0) {
      hicut_float=(float)(pseries->hicut);
      locut_float=(float)(pseries->locut);
	  tt_imanewkey(p_out,pseries->keyhicut,&(hicut_float),TFLOAT,commenthi,"adu");
      tt_imanewkey(p_out,pseries->keylocut,&(locut_float),TFLOAT,commentlo,"adu");
   } else {
      sprintf(value,"%f",pseries->hicut);
      tt_imanewkey(p_out,pseries->keyhicut,value,TSTRING,commenthi,"adu");
      sprintf(value,"%f",pseries->locut);
      tt_imanewkey(p_out,pseries->keylocut,value,TSTRING,commentlo,"adu");
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_normgain_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* normalisation du gain sur une serie d'images                            */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* normgain_value=valeur de la nouvelle moyenne de l'image                 */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue,mult;
   int kkk,index;
   double normgain_value;
   float mipslo,mipshi;
   double xcenter,ycenter,radius,dx,dy,d2,dmax2;
   int ii,jj,kk,imax,jmax,kkkk;
   double valeur,i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   normgain_value=pseries->normgain_value;
   xcenter=pseries->xcenter-1;
   ycenter=pseries->ycenter-1;
   radius=fabs(pseries->radius);

   /* --- raz des variables a calculer ---*/
   pseries->mean=0.;
   pseries->sigma=0.;
   pseries->mini=0.;
   pseries->maxi=0.;
   pseries->nbpixsat=0;
   pseries->bgmean=0.;
   pseries->bgsigma=0.;
   pseries->hicut=1.;
   pseries->locut=0.;
   pseries->contrast=0.;

   /* --- calcul des mini maxi mea sigma et nbpixsat ---*/
   tt_util_bgk(p_in,&(pseries->bgmean),&(pseries->bgsigma));
   /*
   if (pseries->bgmean==0) {
	 mult=1;
   } else {
	 mult=(normgain_value)/(pseries->bgmean);
   }
   */
   tt_util_statima(p_in,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
   if (fabs(pseries->mean)<=TT_EPS_DOUBLE) {
	 mult=0.0;
   } else {
	 mult=(normgain_value)/(pseries->mean);
   }
   if (radius>=1) {
      imax=p_in->naxis1;
      jmax=p_in->naxis2;
      dmax2=radius*radius;
      sx_i=0;
      kkkk=0;
      for(ii=0;ii<imax;ii++) {
	 dx=ii-xcenter;
	 if (fabs(dx)>radius) {
	    continue;
	 }
	 for(jj=0;jj<jmax;jj++) {
	    dy=jj-ycenter;
	    if (fabs(dy)>radius) {
	       continue;
	    }
	    d2=dx*dx+dy*dy;
	    if (d2>dmax2) {
	       continue;
	    }
	    kk=jj*imax+ii;
	    /* --- algo de la valeur moy et ecart type de Miller ---*/
	    valeur=p_in->p[kk];
	    if (kkkk==0) {mu_i=valeur;}
	    i=(double) (kkkk+1);
	    delta=valeur-mu_i;
	    mu_ii=mu_i+delta/(i);
	    sx_ii=sx_i+delta*(valeur-mu_ii);
	    mu_i=mu_ii;
	    sx_i=sx_ii;
	    kkkk++;
	 }
      }
      if (mu_i<=TT_EPS_DOUBLE) {
	 mult=0.0;
      } else {
	 mult=(normgain_value)/(mu_i);
      }
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue*mult);
   }

   /* --- calcul des mini maxi mea sigma et nbpixsat ---*/
   tt_util_statima(p_out,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
   tt_imanewkey(p_out,"MEAN",&(pseries->mean),TDOUBLE,"mean value for all pixels","adu");
   tt_imanewkey(p_out,"SIGMA",&(pseries->sigma),TDOUBLE,"std sigma value for all pixels","adu");
   tt_imanewkey(p_out,"DATAMAX",&(pseries->maxi),TDOUBLE,"maximum value for all pixels","adu");
   tt_imanewkey(p_out,"DATAMIN",&(pseries->mini),TDOUBLE,"minimum value for all pixels","adu");

   /* --- Calcul des parametres de fond de ciel ---*/
   tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
   tt_imanewkey(p_out,"BGMEAN",&(pseries->bgmean),TDOUBLE,"mean value for background pixels","adu");
   tt_imanewkey(p_out,"BGSIGMA",&(pseries->bgsigma),TDOUBLE,"std sigma value for background pixels","adu");

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_cuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);
   mipshi=(float)(pseries->hicut);
   mipslo=(float)(pseries->locut);
   tt_imanewkey(p_out,"MIPS-HI",&(mipshi),TFLOAT,"High cut for visualisation for MiPS","adu");
   tt_imanewkey(p_out,"MIPS-LO",&(mipslo),TFLOAT,"Low cut for visualisation for MiPS","adu");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_normoffset_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* normalisation de l'offset sur une serie d'images                        */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* normoffset_value=valeur du nouveau fond de ciel de l'image              */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue,offset;
   int kkk,index;
   double normoffset_value;
   float mipslo,mipshi;
   double xcenter,ycenter,radius,dx,dy,d2,dmax2;
   int ii,jj,kk,imax,jmax,kkkk;
   double valeur,i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   normoffset_value=pseries->normoffset_value;
   xcenter=pseries->xcenter-1;
   ycenter=pseries->ycenter-1;
   radius=fabs(pseries->radius);

   /* --- raz des variables a calculer ---*/
   pseries->mean=0.;
   pseries->sigma=0.;
   pseries->mini=0.;
   pseries->maxi=0.;
   pseries->nbpixsat=0;
   pseries->bgmean=0.;
   pseries->bgsigma=0.;
   pseries->hicut=1.;
   pseries->locut=0.;
   pseries->contrast=0.;

   /* --- Calcul des parametres de fond de ciel ---*/
   tt_util_bgk(p_in,&(pseries->bgmean),&(pseries->bgsigma));
   offset=normoffset_value-(pseries->bgmean);
   if (radius>=1) {
      imax=p_in->naxis1;
      jmax=p_in->naxis2;
      dmax2=radius*radius;
      sx_i=0;
      kkkk=0;
      for(ii=0;ii<imax;ii++) {
	 dx=ii-xcenter;
	 if (fabs(dx)>radius) {
	    continue;
	 }
	 for(jj=0;jj<jmax;jj++) {
	    dy=jj-ycenter;
	    if (fabs(dy)>radius) {
	       continue;
	    }
	    d2=dx*dx+dy*dy;
	    if (d2>dmax2) {
	       continue;
	    }
	    kk=jj*imax+ii;
	    /* --- algo de la valeur moy et ecart type de Miller ---*/
	    valeur=p_in->p[kk];
	    if (kkkk==0) {mu_i=valeur;}
	    i=(double) (kkkk+1);
	    delta=valeur-mu_i;
	    mu_ii=mu_i+delta/(i);
	    sx_ii=sx_i+delta*(valeur-mu_ii);
	    mu_i=mu_ii;
	    sx_i=sx_ii;
	    kkkk++;
	 }
      }
      offset=normoffset_value-mu_i;
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue+offset);
   }

   /* --- calcul des mini maxi mea sigma et nbpixsat ---*/
   tt_util_statima(p_out,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
   tt_imanewkey(p_out,"MEAN",&(pseries->mean),TDOUBLE,"mean value for all pixels","adu");
   tt_imanewkey(p_out,"SIGMA",&(pseries->sigma),TDOUBLE,"std sigma value for all pixels","adu");
   tt_imanewkey(p_out,"DATAMAX",&(pseries->maxi),TDOUBLE,"maximum value for all pixels","adu");
   tt_imanewkey(p_out,"DATAMIN",&(pseries->mini),TDOUBLE,"minimum value for all pixels","adu");

   /* --- Calcul des parametres de fond de ciel ---*/
   tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
   tt_imanewkey(p_out,"BGMEAN",&(pseries->bgmean),TDOUBLE,"mean value for background pixels","adu");
   tt_imanewkey(p_out,"BGSIGMA",&(pseries->bgsigma),TDOUBLE,"std sigma value for background pixels","adu");

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_cuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);
   mipshi=(float)(pseries->hicut);
   mipslo=(float)(pseries->locut);
   tt_imanewkey(p_out,"MIPS-HI",&(mipshi),TFLOAT,"High cut for visualisation for MiPS","adu");
   tt_imanewkey(p_out,"MIPS-LO",&(mipslo),TFLOAT,"Low cut for visualisation for MiPS","adu");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_objects_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Calcul les parametres associes a des objets trouves dans l'image        */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_hough_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Transformee de Hough                                                    */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem2;
   int msg,k,kkk,x,y,adr,index;
   double value,*cost,*sint,rho,theta,rho_int;
   int naxis11,naxis12,naxis21,naxis22,nombre,taille,naxis222,naxis122;
   double threshold;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   naxis11=p_in->naxis1;
   naxis21=p_in->naxis2;
   naxis12=180;
   naxis22=(int)ceil(sqrt(naxis11*naxis11+naxis21*naxis21));
   naxis122=2*naxis12;
   naxis222=2*naxis22;
   nelem2=(long)(naxis12*naxis222);
   threshold=pseries->threshold;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,naxis12,naxis222);

   /* --- mise a zero de l'image de sortie ---*/
   for (kkk=0;kkk<(int)(nelem2);kkk++) {
      value=0.;
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- on trace une ligne mediane ---*/
   for(k=0;k<naxis12;k++) {
      rho_int=naxis22;
      adr=(int)(rho_int*naxis12+k);
      p_out->p[adr]+=(TT_PTYPE)(1);
   }

   /* --- table de cos, sin ---*/
   nombre=naxis12;
   taille=sizeof(double);
   cost=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cost,&nombre,&taille,"cost"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_1 for pointer cost");
      return(msg);
   }
   sint=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&sint,&nombre,&taille,"sint"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_1 for pointer sint");
      tt_free2((void**)&cost,"cost");
      return(msg);
   }
   for(k=0;k<naxis12;k++) {
      theta=(1.*k-90.)*(TT_PI)/180.;
      /*theta=(1.*k-0.)*(TT_PI)/180.;*/
      cost[k]=cos(theta);
      sint[k]=sin(theta);
   }

   /* --- balayage ---*/
   for(x=0;x<naxis11;x++) {
      for(y=0;y<naxis21;y++) {
         adr=y*naxis11+x;
         value=p_in->p[adr];
         if (value>=threshold) {
            for(k=0;k<naxis12;k++) {
               rho=-x*sint[k]+y*cost[k];
               rho_int=(int)rho;
               rho_int=naxis22+(int)rho;
               if ((rho_int>=0)&&(rho_int<naxis222)) {
                  adr=(int)(rho_int*naxis12+k);
                  if (pseries->binary_yesno==TT_NO) {
                     p_out->p[adr]+=(TT_PTYPE)(value);
                  } else {
                     p_out->p[adr]+=(TT_PTYPE)(1.);
                  }
               }
            }
         }
      }
   }

   /* --- on libere les pointeurs ---*/
   tt_free2((void**)&cost,"cost");
   tt_free2((void**)&sint,"sint");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_geostat_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* detecte les objets stellaires sur une image trainee                     */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* skylevel (pas d'arguments) pour indiquer le skylevel dans le header.    */
/* fwhmsat fwhm des satellites                                             */
/* threshold (ADU) seuil de detection au dessus du fond                    */
/* objefile= nom du fichier ASCII qui enregistre la liste des objets.      */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index;
   double fwhmsat,seuil;
   double xc,yc,radius;
   /*
   char value[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   */
   char filenamesat[FLEN_FILENAME];
   int nbsats;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   fwhmsat=pseries->fwhmsat;
   xc=pseries->xcenter;
   yc=pseries->ycenter;
   radius=pseries->radius;

   if (radius<=0) {
       xc=p_in->naxis1/2;
       yc=p_in->naxis2/2;
       radius=1.1*sqrt(xc*xc+yc*yc);
   }
   if (fwhmsat<=0) {
      fwhmsat=1.;
   }
   strcpy(filenamesat,pseries->objefile);
   if (strcmp(filenamesat,"")==0) {
      strcpy(filenamesat,"geostat.txt");
   }
   seuil=pseries->threshold;
   if (seuil<=0) {
      seuil=100.;
   }

   /* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=(double)p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- raz des variables a calculer ---*/
   nbsats=0;

   /* --- calcul ---*/
   tt_util_geostat(p_in,filenamesat,fwhmsat,seuil,xc,yc,radius,&nbsats,pseries->centroide);
   tt_imanewkey(p_out,"NB_SATEL",&(nbsats),TINT,"number of detected satellites","");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_corners_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Mosaique des 8 images de bord + le centre                               */
/* Useful to set the camera CCD plane in the optical plane                 */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int naxis1,naxis2,x,y,index,k;
	int naxis11,naxis22,w,h,xx0[9],xx1,yy0[9],yy1,xx,yy,x0[9],y0[9];

   /* --- IMA/SERIES ---*/
   index=pseries->index;
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;
   w=pseries->width;
   h=pseries->height;
	if (3*w>naxis1) {
		w=naxis1/3;
	}
	if (3*w>naxis2) {
		h=naxis2/3;
	}
   naxis11=3*w;
   naxis22=3*h;
   tt_imacreater(p_out,naxis11,naxis22);
	// 6 7 8
	// 3 4 5
	// 0 1 2
	k=-1;
	k++ ; xx0[k]=0;   yy0[k]=0;   x0[k]=0;            y0[k]=0;
	k++ ; xx0[k]=w;   yy0[k]=0;   x0[k]=naxis1/2-w/2; y0[k]=0;
	k++ ; xx0[k]=2*w; yy0[k]=0;   x0[k]=naxis1-1-w;   y0[k]=0;
	k++ ; xx0[k]=0;   yy0[k]=h;   x0[k]=0;            y0[k]=naxis2/2-h/2;
	k++ ; xx0[k]=w;   yy0[k]=h;   x0[k]=naxis1/2-w/2; y0[k]=naxis2/2-h/2;
	k++ ; xx0[k]=2*w; yy0[k]=h;   x0[k]=naxis1-1-w;   y0[k]=naxis2/2-h/2;
	k++ ; xx0[k]=0;   yy0[k]=2*h; x0[k]=0;            y0[k]=naxis2-1-h;
	k++ ; xx0[k]=w;   yy0[k]=2*h; x0[k]=naxis1/2-w/2; y0[k]=naxis2-1-h;
	k++ ; xx0[k]=2*w; yy0[k]=2*h; x0[k]=naxis1-1-w;   y0[k]=naxis2-1-h;
	// --- compute the new image
	for (k=0;k<9;k++) {
		xx1=xx0[k]+w ; yy1=yy0[k]+h;
		for(xx=xx0[k];xx<xx1;xx++) {
			x=xx-xx0[k];
			for(yy=yy0[k];yy<yy1;yy++) {
				y=yy-yy0[k];
				p_out->p[yy*naxis11+xx]=(TT_PTYPE)(p_in->p[(y+y0[k])*naxis1+x+x0[k]]);
			}
		}
	}
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];
   return(OK_DLL);
}

int tt_ima_series_coronasun_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Simulation de la courone solaire                                        */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int naxis1,naxis2,x,y,index;
	double xcenter,ycenter,radius,r,rr,dx,dy,dx2,dy2,normaflux,val,bias_level;
	double gain, readout_noise, pixelsat_value;

   int taille,nombre;
	double *repartitionps;
	double *repartitions;
	int nl=20,nk=500,lambdamax=10,kmax=50;
	int nrep=10000,msg;
	double sigmax=5;
	double noise;

   /* --- IMA/SERIES ---*/
   index=pseries->index;
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;
   xcenter=pseries->xcenter;
   ycenter=pseries->ycenter;
   radius=pseries->radius;
   normaflux=pseries->normaflux; // flux theorique ADU du centre du soleil sans eclipse
	bias_level=pseries->bias_level; // ADU
   gain = pseries->gain; /* gain de la chaine en electron/ADU */
	if (gain==0) {
		gain=1;
	}
   readout_noise = pseries->readout_noise; /* electrons */
   pixelsat_value = pseries->pixelsat_value; // ADU
	//
	normaflux *= gain; // e
	/* === prepare le generateur de bruit poissonien === */
	repartitionps=NULL;
	nombre=(nl+1)*(nk+1);
	taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&repartitionps,&nombre,&taille,"repartitionps"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer repartitionps)");
      return(TT_ERR_PB_MALLOC);
   }
	repartitions=NULL;
	nombre=nrep;
	taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&repartitions,&nombre,&taille,"repartitions"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer repartitions)");
      return(TT_ERR_PB_MALLOC);
   }
   srand( (unsigned)time( NULL ) );
	tt_poissonian_cdf(repartitionps,nk,kmax,nl,lambdamax);
	tt_gaussian_cdf(repartitions,nrep,sigmax);
	//
   tt_imacreater(p_out,naxis1,naxis2);
	// --- compute the new image
	for(x=0;x<naxis1;x++) {
		dx=x-xcenter;
		dx2=dx*dx;
		for(y=0;y<naxis2;y++) {
			dy=y-ycenter;
			dy2=dy*dy;
			r=sqrt(dx2+dy2);
			if (r>radius) {			
				rr = r/radius;
				// L. J. November, S. Koutchmy "White-Light Coronal Dark Threads and Density Fine Structure", Astrophysical Journal, 466, S. 512ff, Juli 1996
				val = normaflux*1e-6 * ( 3.670/pow(rr,18) + 1.939/pow(rr,7.8) + 0.0551/pow(rr,2.5) ); // e
				/* --- bruit de photons poissonien de la couronne (electrons) ---*/
				noise = tt_poissonian_rand(sqrt(val),repartitionps,nk,kmax,nl,lambdamax,repartitions,nrep,sigmax); // e
			} else {
				val = 0;
				/* --- bruit de readout poissonien du CCD (electrons) ---*/
				noise = tt_poissonian_rand(readout_noise,repartitionps,nk,kmax,nl,lambdamax,repartitions,nrep,sigmax); // e
			}
			if (r>radius) {			
				val += (p_in->p[y*naxis1+x] * gain); // e
			} else {
				val += (bias_level * gain); // e
			}
			// add photon noise and convert into ADU
			val = (val+noise)/gain; // adu
			if (val > pixelsat_value) {
				val = pixelsat_value ;
			}
			p_out->p[y*naxis1+x]=(TT_PTYPE)( val );
		}
	}
   tt_free2((void**)&repartitions,"repartitions");
   tt_free2((void**)&repartitionps,"repartitionps");
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];
   return(OK_DLL);
}
