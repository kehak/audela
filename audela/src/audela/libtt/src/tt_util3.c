/* tt_util3.c
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

int tt_util_focas1(TT_IMA *p_ref,TT_IMA *p_in,double *a,double *b,int *nb,int flagtrans)
/*************************************************************************/
/* Interface de tt avec focas pour deux listes d'objets                  */
/*************************************************************************/
/* *nb est le nombre d'objets apparies.                                  */
/*   flagtrans     : flag interne permettant de choisir des options :    */
/*    =0 : pour effectuer un appariement simple (FOCAS)                  */
/*    =1 : pour contraindre des translations (AUTOTRANS)                 */
/*************************************************************************/
{
   int k,kk;
   FILE *fichier;
   char message_err[TT_MAXLIGNE];
   char texte[TT_MAXLIGNE];
   double transf_1vers2[20],transf_2vers1[20];
   int nbcom=0, msg;
   double flux,mag;
   char refname[TT_LEN_SHORTFILENAME];
   char inname[TT_LEN_SHORTFILENAME];
   char comname[TT_LEN_SHORTFILENAME];
   char difname[TT_LEN_SHORTFILENAME];

   sprintf(refname,"ref%s.lst",tt_tmpfile_ext);
   sprintf(inname,"in%s.lst",tt_tmpfile_ext);
   sprintf(comname,"com%s.lst",tt_tmpfile_ext);
   sprintf(difname,"dif%s.lst",tt_tmpfile_ext);
   a[0]=1.;a[1]=0.;a[2]=0.;a[3]=0.;a[4]=1.;a[5]=0.;
   b[0]=1.;b[1]=0.;b[2]=0.;b[3]=0.;b[4]=1.;b[5]=0.;
   /* --- fichier ref.lst de type 1 ---*/
   if ((fichier=fopen(refname, "wt") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file ref.lst in tt_util_focas1");
      tt_errlog("",msg,message_err);
      return(msg);
   }
   for (k=0,kk=0;k<p_ref->objelist->nrows;k++) {
      if (p_ref->objelist->ident[k]==TT_STAR) {
	 kk++;
	 flux=p_ref->objelist->flux[k];
	 mag=(flux>0)?-2.5*log(flux)/(TT_LN10):999.;
	 p_ref->objelist->mag[k]=mag;
	 sprintf(texte,"%f %f %f 0 0 0 %f 1 0\n",p_ref->objelist->x[k],p_ref->objelist->y[k],p_ref->objelist->mag[k],p_ref->objelist->mag[k]);
	 fwrite(texte,strlen(texte),1,fichier);
      }
   }
   fclose(fichier);
   /* --- fichier in.lst de type 1 ---*/
   if ((fichier=fopen(inname, "wt") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file in.lst in tt_util_focas1");
      tt_errlog("",msg,message_err);
      return(msg);
   }
   for (k=0,kk=0;k<p_in->objelist->nrows;k++) {
      if (p_in->objelist->ident[k]==TT_STAR) {
	 kk++;
	 flux=p_in->objelist->flux[k];
	 mag=(flux>0)?-2.5*log(flux)/(TT_LN10):999.;
	 p_in->objelist->mag[k]=mag;
	 sprintf(texte,"%f %f %f 0 0 0 %f 1 0\n",p_in->objelist->x[k],p_in->objelist->y[k],p_in->objelist->mag[k],p_in->objelist->mag[k]);
	 fwrite(texte,strlen(texte),1,fichier);
      }
   }
   fclose(fichier);
   /*-- appel a focas ---*/
   if ((msg=focas_main(refname,1,inname,1,flagtrans,1,0,comname,difname,&nbcom,transf_1vers2,transf_2vers1,NULL,NULL,NULL,0,0,0))!=OK) {
      return(PB_DLL);
   }
   *nb=nbcom;
   if (nbcom==0) {
      return(OK_DLL);
   }
   /* --- conversion de fichier vers les variables de tt ---*/
   for (k=0;k<6;k++) {
      a[k]=transf_1vers2[k+4];
      b[k]=transf_2vers1[k+4];
   }
   return(OK_DLL);
}

int tt_util_focas0(TT_IMA *p_in,double epsilon, double delta, double threshold, double *a,double *b,int *nb,double *cmag0,double *d_cmag0,double *a2,double *b2,int *nb2)
/*************************************************************************/
/* Interface de tt avec focas pour des listes objet - catalogue          */
/*************************************************************************/
/* *nb est le nombre d'objets apparies.                                  */
/*************************************************************************/
{
   int nombre,taille;
   int k,kk,nbcom1;
   FILE *fichier,*feq, *fic2;
   char message_err[TT_MAXLIGNE];
   char texte[TT_MAXLIGNE],ligne[TT_MAXLIGNE];
   double transf_1vers2[20],transf_2vers1[20],*cmag;
   double transf2_1vers2[40],transf2_2vers1[40];
   int nbcom=0,msg,nbcom2=0;
   double x1,y1,mag1,x2,y2,mag2,mag21,rien,ra,dec,cste,d_cste;
   char eqname[TT_LEN_SHORTFILENAME];
   char comname[TT_LEN_SHORTFILENAME];
   char difname[TT_LEN_SHORTFILENAME];
   char obsname[TT_LEN_SHORTFILENAME];
   char usnoname[TT_LEN_SHORTFILENAME];
   char pointzeroname[TT_LEN_SHORTFILENAME];
   TT_XYMAG *com=NULL, *all=NULL;
   double *voisins, *pointzero, *d_pointzero;
   int nbobs;
   int kkk, indice, k1, k2;
   double diff,somme;
   /*FILE *f;*/

   sprintf(eqname,"eq%s.lst",tt_tmpfile_ext);
   sprintf(obsname,"obs%s.lst",tt_tmpfile_ext);
   sprintf(usnoname,"usno%s.lst",tt_tmpfile_ext);
   sprintf(comname,"com%s.lst",tt_tmpfile_ext);
   sprintf(difname,"dif%s.lst",tt_tmpfile_ext);
   sprintf(pointzeroname,"pointzero%s.lst",tt_tmpfile_ext);

   a[0]=1.;a[1]=0.;a[2]=0.;a[3]=0.;a[4]=1.;a[5]=0.;
   b[0]=1.;b[1]=0.;b[2]=0.;b[3]=0.;b[4]=1.;b[5]=0.;

   if ((a2!=NULL)&&(b2!=NULL)) {
      for (k=0;k<40;k++) {
         a2[k]=0.;
         b2[k]=0.;
      }
      a2[0]=1.;
      b2[0]=1.;
   }

   /* --- fichier obs.lst de type 1 ---*/
   if ((fichier=fopen(obsname, "wt") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file obs.lst in tt_util_focas0");
      tt_errlog("",msg,message_err);
      return(msg);
   }
   for (k=0,kk=0;k<p_in->objelist->nrows;k++) {
      if (p_in->objelist->ident[k]==TT_STAR) {
	 kk++;
		  /*modif Yassine formatage
		  sprintf(texte,"%f %f %f 0 0 0 %f 1 0\n",p_in->objelist->x[k],p_in->objelist->y[k],p_in->objelist->mag[k],p_in->objelist->mag[k]);*/
	      sprintf(texte,"%8.3f %8.3f %7.4f 0 0 0 %7.4f 1 0\n",p_in->objelist->x[k],p_in->objelist->y[k],p_in->objelist->mag[k],p_in->objelist->mag[k]);
          /*fin*/
	 fwrite(texte,strlen(texte),1,fichier);
      }
   }
   fclose(fichier);
   nbobs=kk;

   /* - ecrit un fichier pour point zero egal a celui de obs.lst -*/
   /* - utile pour eviter un bug a l'ecriture de ascii.txt dans tt_util_fichs_comdif */
   if ((fichier=fopen(pointzeroname, "wt") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file pointzero.lst in tt_util_focas0");
      tt_errlog("",msg,message_err);
      return(msg);
   }
   for (k=0,kk=0;k<p_in->objelist->nrows;k++) {
      if (p_in->objelist->ident[k]==TT_STAR) {
	 kk++;
	 sprintf(texte,"%d %f %f %d %d %f %f %f %f\n",kk,p_in->objelist->x[k],p_in->objelist->y[k],0,0,0.,0.,0.,0.);
	 fwrite(texte,strlen(texte),1,fichier);
      }
   }
   fclose(fichier);

   /* --- fichier usno.lst de type 3 ---*/
   if ((fichier=fopen(usnoname, "wt") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file usno.lst in tt_util_focas0");
      tt_errlog("",msg,message_err);
      return(msg);
   }
   for (k=0,kk=0;k<p_in->catalist->nrows;k++) {
      if (p_in->catalist->ident[k]==TT_STAR) {
	 kk++;
	 /*Modif Yassine formatage
	 sprintf(texte,"%d %f %f %f %f %f %f 1 2 1\n",kk,*/
     sprintf(texte,"%5d %9.3f %9.3f %5.2f %10.6f %9.6f %5.2f 1 2 1\n",kk,
	 /*fin*/
	 p_in->catalist->x[k],p_in->catalist->y[k],p_in->catalist->magr[k],
	 p_in->catalist->ra[k],p_in->catalist->dec[k],p_in->catalist->magr[k]);
	 fwrite(texte,strlen(texte),1,fichier);
      }
   }
   fclose(fichier);

   /*-- appel a focas ---*/
   if ((msg=focas_main(obsname,1,usnoname,3,0,1,0,comname,difname,&nbcom,transf_1vers2,transf_2vers1,&nbcom2,transf2_1vers2,transf2_2vers1,epsilon,delta,threshold))!=OK) {
      return(PB_DLL);
   }

   *nb=nbcom;
   *cmag0=0.;
   *d_cmag0=0.;
   if (nbcom<=0) {
      return(OK_DLL);
   }
   /* --- conversion de fichier vers les variables de tt ---*/
   for (k=0;k<6;k++) {
      a[k]=transf_1vers2[k+4];
      b[k]=transf_2vers1[k+4];
   }
   if ((a2!=NULL)&&(b2!=NULL)) {
      for (k=0;k<22;k++) {
         /* 22 = 2*11 et 11 = 1+nb(PV1_*) */
         a2[k]=transf2_1vers2[k+11];
         b2[k]=transf2_2vers1[k+11];
      }
   }
   /*
   f=fopen("matrix.txt","wt");
   for (k=0;k<20;k++) {
      fprintf(f,"%02d %g \n",k,transf_1vers2[k]);
   }
   fprintf(f,"===============\n");
   for (k=0;k<30;k++) {
      fprintf(f,"%02d %g \n",k,transf2_1vers2[k]);
   }
   fclose(f);
   */
   nombre=nbcom;
   taille=sizeof(double);
   cmag=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cmag,&nombre,&taille,"cmag"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_focas0 for pointer cmag");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- scanne les fichiers com.lst eq.lst ---*/
   if ((fichier=fopen(comname, "rt") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      tt_errlog("",msg,"File com.lst not found in tt_util_focas0");
      tt_free2((void**)&cmag,"cmag");
      return(msg);
   }
   if ((feq=fopen(eqname, "rt") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      tt_errlog("",msg,"File eq.lst not found in tt_util_focas0");
      tt_free2((void**)&cmag,"cmag");
      fclose(fichier);
      return(msg);
   }

   /* --- Allocation des pointeurs com et all ---*/
   if (nbcom>0)
   {  com=NULL;
      nombre=nbcom;
      taille=sizeof(TT_XYMAG);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&com,&nombre,&taille,"com"))!=0)
	  {	tt_free2((void**)&cmag,"cmag");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in util_focas0 for pointer com");
        return(msg);
      }
   }

   if (nbobs>0)
   {  all=NULL;
      nombre=nbobs;
      taille=sizeof(TT_XYMAG);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&all,&nombre,&taille,"all"))!=0)
	  {	tt_free2((void**)&com,"com");
        tt_free2((void**)&cmag,"cmag");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_focas0 for pointer all");
        return(msg);
      }
   }

	/* --- Allocation des pointeurs voisins et pointzero et d_pointzero ---*/
   /*Rajout Thiebaut*/
   if (nbobs>0)
   {  voisins=NULL;
      pointzero=NULL;
      d_pointzero=NULL;
      nombre=nbobs;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&voisins,&nombre,&taille,"voisins"))!=0)
	  {
	  	tt_free2((void**)&com,"com");
                tt_free2((void**)&all,"all");
                tt_free2((void**)&cmag,"cmag");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_focas0 for pointer voisins");
        return(msg);
      }
	  if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pointzero,&nombre,&taille,"pointzero"))!=0)
	  {
	  	tt_free2((void**)&com,"com");
                tt_free2((void**)&all,"all");
                tt_free2((void**)&cmag,"cmag");
	  	tt_free2((void**)&voisins,"voisins");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_focas0 for pointer pointzero");
        return(msg);
      }
	  if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&d_pointzero,&nombre,&taille,"d_pointzero"))!=0)
	  {
	  	tt_free2((void**)&com,"com");
                tt_free2((void**)&all,"all");
                tt_free2((void**)&cmag,"cmag");
		tt_free2((void**)&voisins,"voisins");
	  	tt_free2((void**)&pointzero,"pointzero");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_focas0 for pointer d_pointzero");
        return(msg);
      }
   }
   /*Rajout Thiebaut*/

   kk=0;
   kkk=0;
   do {
      if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    /* X Y mag x y magr r r r*/
	    sscanf(ligne,"%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf",&x1,&y1,&mag1,&x2,&y2,&mag2,&mag21,&rien,&rien);
		(com+kkk)->x=x1;
		(com+kkk)->y=y1;
		(com+kkk)->mag=mag21;
		(com+kkk)->flag=(short)0;
		kkk++;
	 }
      }
      if (fgets(ligne,TT_MAXLIGNE,feq)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    /* ra dec mag*/
	    sscanf(ligne,"%lf %lf %lf",&ra,&dec,&rien);
	 }
	 for (k=0;k<p_in->objelist->nrows;k++) {
	    if (p_in->objelist->ident[k]==TT_STAR) {
	       if ((fabs(p_in->objelist->x[k]-x1)<1)&&(fabs(p_in->objelist->y[k]-y1)<1)) {
		  cmag[kk]=mag2-mag1;kk++;
                /*
		  newx1=b[0]*x2+b[1]*y2+b[2];
		  newy1=b[3]*x2+b[4]*y2+b[5];
                */
		  break;
	       }
	    }
	 }
      }
   } while (feof(fichier)==0);
   fclose(fichier);
   fclose(feq);
   if (tt_util_qsort_double(cmag,0,nbcom,NULL)!=OK_DLL) {
      tt_free2((void**)&com,"com");
      tt_free2((void**)&all,"all");
      tt_free2((void**)&cmag,"cmag");
      tt_free2((void**)&voisins,"voisins");
      tt_free2((void**)&pointzero,"pointzero");
      tt_free2((void**)&d_pointzero,"d_pointzero");
      return(TT_ERR_PB_MALLOC);
   }
   k=(int)(floor((double)nbcom/2.));
   cste=cmag[k];
   d_cste=TT_MAGNULL;
   if (cste!=TT_MAGNULL) {
      rien=0.;
      for (k=0,nbcom1=0;k<nbcom;k++) {
	 if (cmag[k]!=TT_MAGNULL) {
	    mag1=(cste-cmag[k]);
	    rien+=(mag1*mag1);
	    nbcom1++;
	 }
      }
      if (nbcom1!=0) {
	 d_cste=sqrt(rien/nbcom1);
      }
   }

   /*Rajout Thiebaut*/
   /* -- On remplit le pointeur all --*/
   for (k=0,k2=0;k<p_in->objelist->nrows;k++) {
	   if (p_in->objelist->ident[k]==TT_STAR) {
		   (all+k2)->x=p_in->objelist->x[k];
		   (all+k2)->y=p_in->objelist->y[k];
		   (all+k2)->mag=p_in->objelist->mag[k];
		   (all+k2)->flag=(short)0;
		   k2++;
	   }
   }

   if ((fic2=fopen(pointzeroname,"wt"))==NULL){
	   msg=TT_ERR_FILE_CANNOT_BE_WRITED;
       sprintf(message_err,"Writing error for file %s in tt_util_focas0",pointzeroname);
       tt_errlog("",msg,message_err);
      tt_free2((void**)&com,"com");
      tt_free2((void**)&all,"all");
      tt_free2((void**)&cmag,"cmag");
      tt_free2((void**)&voisins,"voisins");
      tt_free2((void**)&pointzero,"pointzero");
      tt_free2((void**)&d_pointzero,"d_pointzero");
       return(msg);
	}

   /* --- Mon calcul de Pointzero pour chaque objet ---*/
   for (k=0;k<nbobs;k++) {
			fprintf(fic2,"%d %f %f ",k+1,(all+k)->x,(all+k)->y);
			for (kk=0,kkk=0;kk<nbcom;kk++){
				if (sqrt(((all+k)->x-(com+kk)->x)*((all+k)->x-(com+kk)->x)+((all+k)->y-(com+kk)->y)*((all+k)->y-(com+kk)->y))<150){
					voisins[kkk]=-(com+kk)->mag;
					kkk++;
				}
			}
			fprintf(fic2,"%d %d ",kkk,150);

			/* Calcul de la mediane et erreur associee */
			if (tt_util_qsort_double(voisins,0,kkk,NULL)!=OK_DLL) {
      tt_free2((void**)&com,"com");
      tt_free2((void**)&all,"all");
      tt_free2((void**)&cmag,"cmag");
      tt_free2((void**)&voisins,"voisins");
      tt_free2((void**)&pointzero,"pointzero");
      tt_free2((void**)&d_pointzero,"d_pointzero");
				return(TT_ERR_PB_MALLOC);
			}
			indice=(int)(floor((double)kkk/2.));
			pointzero[k]=voisins[indice];
			diff=0;
			rien=0;
			for (k1=0;k1<kkk;k1++){
				diff=pointzero[k]-voisins[k1];
				rien+=(diff*diff);
			}
			if (kkk>1){
				d_pointzero[k]=sqrt(rien/kkk);
				fprintf(fic2,"%f %f ",pointzero[k],d_pointzero[k]);
			}
			else {
				pointzero[k]=cste;
				d_pointzero[k]=d_cste;
				fprintf(fic2,"%f %f ",pointzero[k],d_pointzero[k]);
			}
			/* Calcul de la moyenne et erreur associee */
			somme=0;
			for (k1=0;k1<kkk;k1++){
				somme+=voisins[k1];
			}
			if (kkk>1){
				pointzero[k]=somme/kkk;
				diff=0;
				rien=0;
				for (k1=0;k1<kkk;k1++){
					diff=pointzero[k]-voisins[k1];
					rien+=(diff*diff);
				}
				d_pointzero[k]=sqrt(rien/kkk);
				fprintf(fic2,"%f %f\n",pointzero[k],d_pointzero[k]);
			}
			else {
				pointzero[k]=cste;
				d_pointzero[k]=d_cste;
				fprintf(fic2,"%f %f\n",pointzero[k],d_pointzero[k]);
			}
   }

    /*Rajout Thiebaut*/
	fclose(fic2);
	tt_free2((void**)&all,"all");tt_free2((void**)&com,"com");
	tt_free2((void**)&cmag,"cmag");tt_free2((void**)&voisins,"voisins");tt_free2((void**)&pointzero,"pointzero");tt_free2((void**)&d_pointzero,"d_pointzero");
	*cmag0=cste;
	*d_cmag0=d_cste;

   return(OK_DLL);
}

int tt_util_fichs_comdif(TT_ASTROM *p_ast,double cmag, char *nomfic_all,char *nomfic_com,char *nomfic_dif,char *nomfic_ascii,char *typefic_com)
/*************************************************************************/
/* Ecrit un fichier ASCII d'objets en communs et differents              */
/*************************************************************************/
/*************************************************************************/
{
   TT_ASTROM p;
   int valid=TT_NO;
   FILE *fichier,*ficcom=NULL, *ficmag;
   char message_err[TT_MAXLIGNE];
   char texte[TT_MAXLIGNE],ligne[TT_MAXLIGNE];
   int msg,cas,riend;
   double x1,y1,mag1,x2,y2,mag2,rien;
   short flag1;
   double x_ra,x_dec,x_mag1,x_mag2,x_mag;
   char attrib[10],mise_enforme[]="%6d %2d %7.2f %7.2f %+8.3f %7.3f %11.1f %10.1f %9.5f %9.5f %+8.4f %+8.4f %7.4f %+8.4f %7.4f %3d %3d %10.1f %+10.2f %+10.2f %+10.2f %+10.2f %+10.2f %7.1f %7.2f %3d \n";
   char           mise_enforme0[]="%6d %2d %7.2lf %7.2lf %+8.3lf %7.3lf %11.1lf %10.1lf %9.5lf %9.5lf %+8.4lf %+8.4lf %7.4lf %+8.4lf %7.4lf %3d %3d %10.1lf %+10.2lf %+10.2lf %+10.2lf %+10.2lf %+10.2lf %7.1f %7.2lf %3d \n";
   int nl=225; /* nombres de caracteres sur une ligne (\n inclus) */
   int ni; /* nombres de caracteres pour l'indice (%5d) */
   char pointzeroname[TT_LEN_SHORTFILENAME];
   int nball,nbcom,taille,nombre,k,kk,ntot;
   TT_XYMAG *all=NULL,*com=NULL,*comusno=NULL;
   TT_LISTSEXT *liste=NULL;
   /*Modif Yassine
   double x,y,mag,errmag,flux,errflux,backgnd,xy,flag_sext,fwhm,classstar,theta,a_ellipse,b_ellipse;*/
   double x,y,mag,errmag,flux,errflux,backgnd,xy,fwhm,classstar,theta,a_ellipse,b_ellipse;
   int flag_sext;
   /*fin*/
   double diffmag1, err1, diffmag2, err2;
   int nbvois;
   double *ras=NULL;
   int *indexs=NULL;
   char *cars=NULL;
   /*rajout Yassine*/
   int *nb_carac_jus_fin_ligne=NULL;
   int kd2;
   int ni0;
   /*fin*/
   int casold,n,kd;
   int matchingindex;


   sprintf(pointzeroname,"pointzero%s.lst",tt_tmpfile_ext);

   /* --- Recherche des nouveaux parametres de la projection dans l'entete --*/
   /*
   tt_util_get_new_wcs_crval(p_in,a,&p,&valid);
   */
   if (p_ast!=NULL) {
	   p=*p_ast;
   }

   /* --- On compte le nombre total d'etoiles total (obs.lst ou catalog.cat) ---*/
   if ((fichier=fopen(nomfic_all, "rt") ) == NULL)
   {  msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in tt_util_fichs_comdif",nomfic_all);
      tt_errlog("",msg,message_err);
      return(msg);
   }
   nball=0;
   do
   {	if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL)
		{	strcpy(texte,"");
			sscanf(ligne,"%s",texte);
			if ((strcmp(texte,"")!=0) )
			{nball++;}
		}
   } while (feof(fichier)==0);
   fclose(fichier);

   /* --- On compte le nombre d'etoiles communes (com.lst) ---*/
   if ((fichier=fopen(nomfic_com,"rt")) == NULL)
   {  msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in tt_util_fichs_comdif",nomfic_com);
      tt_errlog("",msg,message_err);
      return(msg);
   }
   nbcom=0;
   do
   {	if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL)
		{	strcpy(texte,"");
			sscanf(ligne,"%s",texte);
			if ((strcmp(texte,"")!=0))
			{nbcom++;}
		}
   } while (feof(fichier)==0);
   fclose(fichier);

   /* --- Allocation des pointeurs sur les structures ---*/
   if (nball>0)
   {  all=NULL;
      nombre=nball;
      taille=sizeof(TT_XYMAG);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&all,&nombre,&taille,"all"))!=0)
	  {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_fichs_comdif for pointer all");
        return(msg);
      }
	  /* --Allocation du pointeur liste sextractor ---*/
	  /*Rajout Thiebaut*/
	  liste=NULL;
      nombre=nball;
	  taille=sizeof(TT_LISTSEXT);
	  if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&liste,&nombre,&taille,"liste"))!=0)
	  {
	    tt_free2((void**)&all,"all");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_fichs_comdif for pointer liste");
		return(msg);
	  }
   }
   if (nbcom>0)
   {  com=NULL;
      nombre=nbcom;
      taille=sizeof(TT_XYMAG);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&com,&nombre,&taille,"com"))!=0)
	  {	tt_free2((void**)&liste,"liste");
	    tt_free2((void**)&all,"all");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_fichs_comdif for pointer com");
        return(msg);
      }
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&comusno,&nombre,&taille,"comusno"))!=0)
	  {	tt_free2((void**)&liste,"liste");
	    tt_free2((void**)&all,"all");
	    tt_free2((void**)&com,"com");
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_fichs_comdif for pointer comusno");
        return(msg);
      }
   }

   /* --- Lecture des etoiles dans le fichier nomfic_all (obs.lst ou catalog.cat) ---*/
   if (nball>0) {
      if ((fichier=fopen(nomfic_all, "rt") ) == NULL) {
         tt_free2((void**)&all,"all");tt_free2((void**)&com,"com");tt_free2((void**)&liste,"liste");tt_free2((void**)&comusno,"comusno");
			msg=TT_ERR_FILE_NOT_FOUND;
			sprintf(message_err,"File %s not found in tt_util_fichs_comdif",nomfic_all);
			tt_errlog("",msg,message_err);
			return(msg);
		}
		k=0;
      if ((strcmp(nomfic_all,"obs.lst"))==0) {
         /* --- CAS : com.lst --- */
   		do {
            if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL) {
               strcpy(texte,"");
			   	sscanf(ligne,"%s",texte);
				   if ((strcmp(texte,"")!=0)) {
                  sscanf(ligne,"%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf",&x1,&y1,&mag1,&rien,&rien,&rien,&mag1,&rien,&rien);
						(all+k)->x=x1;
						(all+k)->y=y1;
						(all+k)->mag=mag1;
						(all+k)->flag=(short)0;
						k++;
					}
				}
   		} while (feof(fichier)==0);
	   	fclose(fichier);
      } else {
         if (strcmp(typefic_com,"TAROTCAT1")==0) {
            valid=0;
     		   do {
               if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL) {
                  strcpy(texte,"");
			   	   sscanf(ligne,"%s",texte);
				      if ((strcmp(texte,"")!=0)) {
                     if (strlen(texte)>15) {
                        texte[9]='\0';
                        if (strcmp(texte,"123456789")==0) {
                           valid=k; /* nb de lignes de l'entete a passer */
                        }
                     }
                     if (valid==0) { continue; }
                     /*&rien,&flux,&errflux,&mag,&errmag,&backgnd,&x,&y,&x2,&y2,&xy,&a_ellipse,&b_ellipse,&theta,&fwhm,&flag_sext,&classstar);*/
					      sscanf(ligne,mise_enforme0,
                        &rien,&matchingindex,&x,&y,&rien,
                        &rien,&flux,&rien,&rien,&rien,
                        &mag,&rien,&rien,&rien,&rien,
                        &rien,&rien,&backgnd,&rien,&rien,
                        &rien,&rien,&rien,&rien,&fwhm,
                        &rien);
                     /* ne prendre en compte que matchingindex=1,3 */
						   if (mag>=99.) {continue;}
						   errflux=0.;
						   errmag=0.;
						   x2=0.;
						   y2=0.;
						   xy=0.;
						   a_ellipse=0.;
						   b_ellipse=0.;
						   theta=0.;
						   flag_sext=0;
						   classstar=0;
						   (liste+k)->flag=(short)0;
						   (liste+k)->flux=flux;
						   (liste+k)->errflux=errflux;
						   (liste+k)->mag=mag;
						   (liste+k)->errmag=errmag;
						   (liste+k)->backgnd=backgnd;
						   (liste+k)->x=x-1.; /* -1 de sextractor */
						   (liste+k)->y=y-1.;
						   (liste+k)->x2=x2-1.;
						   (liste+k)->y2=y2-1.;
						   (liste+k)->xy=xy;
						   (liste+k)->a_ellipse=a_ellipse;
						   (liste+k)->b_ellipse=b_ellipse;
						   (liste+k)->theta=theta;
						   (liste+k)->fwhm=fwhm;
						   (liste+k)->flag_sext=flag_sext;
						   (liste+k)->classstar=classstar;
						   k++;
					   }
               }
		      } while (feof(fichier)==0);
		      fclose(fichier);
         } else {
     		   do {
               if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL) {
                  strcpy(texte,"");
			   	   sscanf(ligne,"%s",texte);
				      if ((strcmp(texte,"")!=0)) {
   					      /*Modif Yassine*/
						  /*sscanf(ligne,"%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf",&rien,&flux,&errflux,&mag,&errmag,&backgnd,&x,&y,&x2,&y2,&xy,&a_ellipse,&b_ellipse,&theta,&fwhm,&flag_sext,&classstar);*/
						  sscanf(ligne,"\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf %3d\t%lf",&rien,&flux,&errflux,&mag,&errmag,&backgnd,&x,&y,&x2,&y2,&xy,&a_ellipse,&b_ellipse,&theta,&fwhm,&flag_sext,&classstar);
						  /*fin*/
						   if (mag>=99.) {continue;}
						   (liste+k)->flag=(short)0;
						   (liste+k)->flux=flux;
						   (liste+k)->errflux=errflux;
						   (liste+k)->mag=mag;
						   (liste+k)->errmag=errmag;
						   (liste+k)->backgnd=backgnd;
						   (liste+k)->x=x-1.; /* -1 de sextractor */
						   (liste+k)->y=y-1.;
						   (liste+k)->x2=x2-1.;
						   (liste+k)->y2=y2-1.;
						   (liste+k)->xy=xy;
						   (liste+k)->a_ellipse=a_ellipse;
						   (liste+k)->b_ellipse=b_ellipse;
						   (liste+k)->theta=theta;
						   (liste+k)->fwhm=fwhm;
						   (liste+k)->flag_sext=flag_sext;
						   (liste+k)->classstar=classstar;
						   k++;
					   }
				   }
   		   } while (feof(fichier)==0);
	   	   fclose(fichier);
         }
      }
   }
   /*Rajout Thiebaut*/

   /* --- Lecture des etoiles dans le fichier com.lst (com) ---*/
   if (nbcom>0)
   {	if ((fichier=fopen(nomfic_com, "rt") ) == NULL)
		{	tt_free2((void**)&all,"all");tt_free2((void**)&com,"com");tt_free2((void**)&liste,"liste");tt_free2((void**)&comusno,"comusno");
			msg=TT_ERR_FILE_NOT_FOUND;
			sprintf(message_err,"File %s not found in tt_util_fichs_comdif",nomfic_com);
			tt_errlog("",msg,message_err);
			return(msg);
		}
		k=0;
		do
		{	if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL)
			{	strcpy(texte,"");
				sscanf(ligne,"%s",texte);
				if ( (strcmp(texte,"")!=0) )
				{	sscanf(ligne,"%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf",&x1,&y1,&mag1,&x2,&y2,&mag2,&rien,&rien,&rien);
					(com+k)->x=x1;
					(com+k)->y=y1;
					(com+k)->mag=mag1;
					(com+k)->flag=(short)0;
					(comusno+k)->x=x2;
					(comusno+k)->y=y2;
					(comusno+k)->mag=mag2;
					(comusno+k)->flag=(short)0;
					 k++;
					 /*if (k==45) break;*/
				 }
			}
		 } while (feof(fichier)==0);
      fclose(fichier);
   }

   /* --- Boucle sur les etoiles ---*/
   for (k=0;k<nball;k++)
   {  if ((strcmp(nomfic_all,"obs.lst"))==0)
		{	x1=(all+k)->x;
			y1=(all+k)->y;
			mag1=(all+k)->mag;
			/* --- par defaut l'etoile n'appartient qu'a l'image =1 ---*/
			(all+k)->flag=(short)1;
			if (mag1>=TT_MAGNULL)
			{continue;}
		}
		else
		{	x1=(liste+k)->x; /* -1 de sextractor */
			y1=(liste+k)->y;
			mag1=(liste+k)->mag;
			(liste+k)->flag=(short)1;
			/*if (mag1>=TT_MAGNULL) */
			if (mag1>=99.)
			{continue;}
		}
		for (kk=0;kk<nbcom;kk++)
		{	x2=(com+kk)->x;
			y2=(com+kk)->y;
			mag2=(com+kk)->mag;
			if ((x1==x2)&&(y1==y2))
			{  if (strcmp(nomfic_ascii,"")!=0)
				{	(all+k)->flag=(short)3;
					(liste+k)->flag=(short)3;
				}
			break;
			}
		}
   }

   /* --- On ouvre le fichier de sortie des communs et des differences ---*/
   strcpy(attrib,"wt");
   if (strcmp(nomfic_ascii,"")!=0)
   {	if ((ficcom=fopen(nomfic_ascii,attrib) ) == NULL) {
		tt_free2((void**)&all,"all");tt_free2((void**)&com,"com");tt_free2((void**)&liste,"liste");tt_free2((void**)&comusno,"comusno");
        msg=TT_ERR_FILE_CANNOT_BE_WRITED;
        sprintf(message_err,"Writing error for file %s in tt_util_fich_comdif",nomfic_ascii);
        tt_errlog("",msg,message_err);
        return(msg);
		}
   }

   /* --- On ouvre le fichier "pointzero.lst" ---*/
	if ((ficmag=fopen(pointzeroname,"rt"))==NULL) {
		tt_free2((void**)&all,"all");tt_free2((void**)&com,"com");tt_free2((void**)&liste,"liste");tt_free2((void**)&comusno,"comusno");
		msg=TT_ERR_FILE_NOT_FOUND;
        sprintf(message_err,"Writing error for file %s in tt_util_fich_comdif",pointzeroname);
        tt_errlog("",msg,message_err);
        if (strcmp(nomfic_ascii,"")!=0)
        {fclose(ficcom);}
        return(msg);
	}

	/* --- boucle sur les etoiles : cas=1 (etoile uniquement sur l'image) ---*/
   ntot=0;
   cas=1;
   k=0;
   if (nball>0) {
	   do
		 {
			 if (fgets(ligne,TT_MAXLIGNE,ficmag)!=NULL)
				{	strcpy(texte,"");
					sscanf(ligne,"%s",texte);
					if ( (strcmp(texte,"")!=0) )
					{ 	sscanf(ligne,"%d %lf %lf %d %d %lf %lf %lf %lf",&riend,&x1,&y1,&nbvois,&riend,&diffmag1,&err1,&diffmag2,&err2);
						if ((strcmp(nomfic_all,"obs.lst"))==0)
						{	x=(all+k)->x;
							y=(all+k)->y;
							mag=(all+k)->mag;
							flag1=(all+k)->flag;
							if ((flag1==1)&&(x1==x)&&(y1==y)&&(mag<TT_MAGNULL))
							{	ntot++;
								if (p_ast!=NULL) {
									tt_util_astrom_xy2radec(&p,x,y,&x_ra,&x_dec);
								} else {
									x_ra=0.;
									x_dec=0.;
								}
								x_mag=cmag+mag;
								/*Modif Yassine
								x_mag1=(diffmag1+mag)*0.;*/
                                x_mag1=diffmag1+mag;
								/*fin*/
								x_mag2=diffmag2+mag;
								rien=(short)0;
								fprintf(ficcom,mise_enforme,ntot,cas,x,y,mag,rien,rien,rien,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150,rien,rien,rien,rien,rien,rien,rien,rien,rien);
							}
						}
						else
						{	flux=(liste+k)->flux;
							errflux=(liste+k)->errflux;
							mag=(liste+k)->mag;
							errmag=(liste+k)->errmag;
							backgnd=(liste+k)->backgnd;
							x=(liste+k)->x;
							y=(liste+k)->y;
							x2=(liste+k)->x2;
							y2=(liste+k)->y2;
							xy=(liste+k)->xy;
							a_ellipse=(liste+k)->a_ellipse;
							b_ellipse=(liste+k)->b_ellipse;
							theta=(liste+k)->theta;
							fwhm=(liste+k)->fwhm;
							flag_sext=(int)(liste+k)->flag_sext;
							classstar=(liste+k)->classstar;
							flag1=(liste+k)->flag;
							if ((flag1==1)&&(x1==x)&&(y1==y)&&(mag<99.))
							{	ntot++;
								if (p_ast!=NULL) {
									tt_util_astrom_xy2radec(&p,x,y,&x_ra,&x_dec);
								} else {
									x_ra=0.;
									x_dec=0.;
								}
								x_mag=cmag+mag;
								/*Modif Yassine
								x_mag1=(diffmag1+mag)*0.;*/
								x_mag1=diffmag1+mag;
								/*fin*/
								x_mag2=diffmag2+mag;
                        /* -1 de sextractor */
								/*Modif Yassine
								fprintf(ficcom,mise_enforme,ntot,cas,x+1.,y+1.,mag,errmag,flux,errflux,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150,backgnd,x2,y2,xy,a_ellipse,b_ellipse,theta,fwhm,flag_sext,classstar);*/
								//sprintf(ligne,mise_enforme,ntot,cas,x+1.,y+1.,mag,errmag,flux,errflux,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150,backgnd,x2,y2,xy,a_ellipse,b_ellipse,theta,fwhm,flag_sext);
								fprintf(ficcom,mise_enforme,ntot,cas,x+1.,y+1.,mag,errmag,flux,errflux,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150,backgnd,x2,y2,xy,a_ellipse,b_ellipse,theta,fwhm,flag_sext);
								//fprintf(ficcom,"%s",ligne);
								/*fin*/
							}
						}
						k++;
					}
				}
		} while (feof(ficmag)==0);
   }
   fclose(ficmag);

   /* --- boucle sur les etoiles : cas=3 (etoile sur l'image et sur le catalogue) ---*/
   cas=3;

   /* --- On ouvre à nouveau le fichier "pointzero.lst" ---*/
	if ((ficmag=fopen(pointzeroname,"rt"))==NULL) {
		  tt_free2((void**)&all,"all");tt_free2((void**)&com,"com");tt_free2((void**)&liste,"liste");tt_free2((void**)&comusno,"comusno");
		msg=TT_ERR_FILE_NOT_FOUND;
        sprintf(message_err,"Writing error for file %s in tt_util_fich_comdif",pointzeroname);
        tt_errlog("",msg,message_err);
        if (strcmp(nomfic_ascii,"")!=0)
        {fclose(ficcom);}
        return(msg);
	}
   k=0;
   if(nbcom>0) {
	   do
	{	if (fgets(ligne,TT_MAXLIGNE,ficmag)!=NULL)
				{	strcpy(texte,"");
					sscanf(ligne,"%s",texte);
					if ( (strcmp(texte,"")!=0) )
					{ 	sscanf(ligne,"%d %lf %lf %d %d %lf %lf %lf %lf",&riend,&x1,&y1,&nbvois,&riend,&diffmag1,&err1,&diffmag2,&err2);
						if ((strcmp(nomfic_all,"obs.lst"))==0)
						{	x=(all+k)->x;
							y=(all+k)->y;
							mag=(all+k)->mag;
							flag1=(all+k)->flag;
							if ((flag1==3)&&(x1==x)&&(y1==y))
							{	ntot++;
								if (p_ast!=NULL) {
									tt_util_astrom_xy2radec(&p,x,y,&x_ra,&x_dec);
								} else {
									x_ra=0.;
									x_dec=0.;
								}
								x_mag=cmag+mag;
								/*Modif Yassine*/
								/*x_mag1=(diffmag1+mag)*0.;*/
                                x_mag1=diffmag1+mag;
								/*fin*/
								x_mag2=diffmag2+mag;
								rien=(short)0;
								/*fprintf(ficcom,"%4d %2d %7.2f %7.2f %+7.2f %10.6f %+10.6f %8.4f %+8.4f %6.4f %+8.4f %6.4f %d %d\n",ntot,cas,x,y,mag,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150);*/
								fprintf(ficcom,mise_enforme,ntot,cas,x,y,mag,rien,rien,rien,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150,rien,rien,rien,rien,rien,rien,rien,rien,rien);
							}
						}
						else
						{	flux=(liste+k)->flux;
							errflux=(liste+k)->errflux;
							mag=(liste+k)->mag;
							errmag=(liste+k)->errmag;
							backgnd=(liste+k)->backgnd;
							x=(liste+k)->x;
							y=(liste+k)->y;
							x2=(liste+k)->x2;
							y2=(liste+k)->y2;
							xy=(liste+k)->xy;
							a_ellipse=(liste+k)->a_ellipse;
							b_ellipse=(liste+k)->b_ellipse;
							theta=(liste+k)->theta;
							fwhm=(liste+k)->fwhm;
							flag_sext=(int)(liste+k)->flag_sext;
							classstar=(liste+k)->classstar;
							flag1=(liste+k)->flag;
							if ((flag1==3)&&(x1==x)&&(y1==y)&&(mag<99.))
							{	ntot++;
								if (p_ast!=NULL) {
									tt_util_astrom_xy2radec(&p,x,y,&x_ra,&x_dec);
								} else {
									x_ra=0.;
									x_dec=0.;
								}
								x_mag=cmag+mag;
								/*Modif Yassine
								x_mag1=(diffmag1+mag)*0.;*/
								x_mag1=diffmag1+mag;
								/*fin*/
								x_mag2=diffmag2+mag;
                        /* -1 de sextractor */
								/*Modif Yassine
								fprintf(ficcom,mise_enforme,ntot,cas,x+1.,y+1.,mag,errmag,flux,errflux,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150,backgnd,x2,y2,xy,a_ellipse,b_ellipse,theta,fwhm,flag_sext,classstar);*/
								fprintf(ficcom,mise_enforme,ntot,cas,x+1.,y+1.,mag,errmag,flux,errflux,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,x_mag1,err1,x_mag2,err2,nbvois,150,backgnd,x2,y2,xy,a_ellipse,b_ellipse,theta,fwhm,flag_sext);
								/*fin*/
							}
						}
						k++;
						}
				}
		} while (feof(ficmag)==0);
   }
   fclose(ficmag);

   /* --- boucle sur les etoiles cas=2 (etoiles uniquement sur le catalogue) ---*/
   cas=2;
   if ((fichier=fopen(nomfic_dif,"rt")) == NULL)
   {  msg=TT_ERR_FILE_NOT_FOUND;
		tt_free2((void**)&all,"all");tt_free2((void**)&com,"com");tt_free2((void**)&liste,"liste");tt_free2((void**)&comusno,"comusno");
	  sprintf(message_err,"File %s not found in tt_util_fichs_comdif",nomfic_dif);
      tt_errlog("",msg,message_err);
      if (strcmp(nomfic_ascii,"")!=0)
      {fclose(ficcom);}
      return(msg);
   }
   k=0;
   do
   { if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL)
	{   strcpy(texte,"");
        sscanf(ligne,"%s",texte);
		if ((strcmp(texte,"")!=0))
		{	sscanf(ligne,"%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf",&x1,&y1,&mag1,&x2,&y2,&mag2,&rien,&rien,&rien);
			if (mag1>=TT_MAGNULL) {continue;}
			ntot++;
            x_mag=mag1;
            mag1=(short)0;
			rien=(short)0;
			if (p_ast!=NULL) {
				tt_util_astrom_xy2radec(&p,x1,y1,&x_ra,&x_dec);
			} else {
				x_ra=0.;
				x_dec=0.;
			}
			fprintf(ficcom,mise_enforme,ntot,cas,x1+1.,y1+1.,mag1,rien,rien,rien,x_ra*180./(TT_PI),x_dec*180./(TT_PI),x_mag,rien,rien,rien,rien,rien,rien,rien,rien,rien,rien,rien,rien,rien,rien,rien);
		}
      }
   } while (feof(fichier)==0);
   fclose(fichier);

   if (strcmp(nomfic_ascii,"")!=0)
   {fclose(ficcom);}

    tt_free2((void**)&liste,"liste");
	tt_free2((void**)&all,"all");
	tt_free2((void**)&com,"com");
	tt_free2((void**)&comusno,"comusno");

   /* --- ici on trie la liste du fichier ASCII en ordre de RA croissant ---*/
   /*     en gardant les 1-3-2 pour les types d'appariements */
   strcpy(attrib,"rt");
   if (strcmp(nomfic_ascii,"")!=0) {
      if ((ficcom=fopen(nomfic_ascii,attrib) ) == NULL) {
        msg=TT_ERR_FILE_CANNOT_BE_WRITED;
        sprintf(message_err,"Writing error for file %s in tt_util_fich_comdif",nomfic_ascii);
        tt_errlog("",msg,message_err);
        return(msg);
		}
   }
	/* --- boucle sur les ntot etoiles */
   ras=NULL;
   nombre=ntot+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ras,&nombre,&taille,"ras"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in util_focas0 for pointer ras");
      fclose(ficcom);
      return(msg);
   }
   indexs=NULL;
   nombre=ntot+1;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&indexs,&nombre,&taille,"indexs"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in util_focas0 for pointer indexs");
      tt_free2((void**)&ras,"ras");
      fclose(ficcom);
      return(msg);
   }
   /*rajout yassine : je ne comprends pas pourquoi ntot+1*/
   nb_carac_jus_fin_ligne=NULL;
   nombre=ntot+1;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&nb_carac_jus_fin_ligne,&nombre,&taille,"nb_carac_jus_fin_ligne"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in util_focas0 for pointer indexs");
      tt_free2((void**)&ras,"ras");
      fclose(ficcom);
      return(msg);
   }
   /*je deplace aussi ces 2 ligne*/
   /*fin*/
   k=0;
   casold=1;
   n=0;kd=1;
   kd2=0;
   do {
      if (fgets(ligne,TT_MAXLIGNE,ficcom)!=NULL) {
         strcpy(texte,"");
			sscanf(ligne,"%s",texte);
			if ( (strcmp(texte,"")!=0) ) {
            k++;
            sscanf(ligne,"%d %d %lf %lf %lf %lf %lf %lf %lf",
               &riend,&cas,&rien,&rien,&rien,&rien,&rien,&rien,&x_ra);
            ras[k]=x_ra;
            indexs[k]=k;
#ifdef FILE_DOS
			/*rajout Yassine: +1 a cause de \n*/
			kd2=kd2+strlen(ligne)+1;
#else
			kd2=kd2+strlen(ligne);
#endif
			nb_carac_jus_fin_ligne[k]=kd2;
			/*fin*/
            if (cas==casold) {
               n++;
            } else {
               if (n>0) {
                  tt_util_qsort_double(ras,kd,n,indexs);
                  n=1;
               }
               kd=k;
               casold=cas;
            }
			}
      }
   } while (feof(ficcom)==0);
   fclose(ficcom);
   if (n>0) {
      tt_util_qsort_double(ras,kd,n,indexs);
   }
   tt_free2((void**)&ras,"ras");
   /* on lit tout le fichier ASCII en memoire */
   /* ntot lignes de nl char */
   strcpy(attrib,"rb");
   if (strcmp(nomfic_ascii,"")!=0) {
      if ((ficcom=fopen(nomfic_ascii,attrib) ) == NULL) {
        msg=TT_ERR_FILE_CANNOT_BE_WRITED;
        sprintf(message_err,"Writing error for file %s in tt_util_fich_comdif",nomfic_ascii);
        tt_errlog("",msg,message_err);
        tt_free2((void**)&indexs,"indexs");
		/*rajout yassine*/
		tt_free2((void**)&nb_carac_jus_fin_ligne,"nb_carac_jus_fin_ligne");
		/*fin*/
        return(msg);
	  }
   }
   cars=NULL;
   /*Modif yassine
   nombre=ntot*nl;*/
   nombre=nb_carac_jus_fin_ligne[ntot];
   /*fin*/
   taille=sizeof(char);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cars,&nombre,&taille,"cars"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in util_focas0 for pointer cars");
      tt_free2((void**)&indexs,"indexs");
      fclose(ficcom);
      return(msg);
   }
   n=fread(cars,sizeof(char),nombre,ficcom);
   n/=nl;
   fclose(ficcom);
   strcpy(attrib,"wb");
   if (strcmp(nomfic_ascii,"")!=0) {
      if ((ficcom=fopen(nomfic_ascii,attrib) ) == NULL) {
        msg=TT_ERR_FILE_CANNOT_BE_WRITED;
        sprintf(message_err,"Writing error for file %s in tt_util_fich_comdif",nomfic_ascii);
        tt_errlog("",msg,message_err);
        tt_free2((void**)&indexs,"indexs");
        tt_free2((void**)&cars,"cars");
		/*rajout yassine*/
		tt_free2((void**)&nb_carac_jus_fin_ligne,"nb_carac_jus_fin_ligne");
		/*fin*/
        return(msg);
		}
   }
   sprintf(ligne,"%c",mise_enforme[1]);
   ni=(int)(atoi(ligne));
   /*modif yassine
   for (k=1;k<=n;k++) {
      sprintf(texte,ligne,k);
      fwrite(texte,sizeof(char),ni,ficcom);
	  kd=(indexs[k]-1)*nl;
      fwrite(cars+kd+ni,sizeof(char),nl-ni,ficcom);
	  kd= (indexs[k]-1)*nl;
	  fwrite(cars+kd+ni,sizeof(char),nb_cara_avant_ligne[indexs[k]]-ni,ficcom);
   }*/
   ni0=(int)floor(log10(ntot))+1;
   if (ni<ni0) {ni=ni0;}
   sprintf(ligne,"%%%dd",ni);
   for (k=1;k<=ntot;k++) {
      sprintf(texte,ligne,k);
      fwrite(texte,sizeof(char),ni,ficcom);
	  kd = nb_carac_jus_fin_ligne[indexs[k]];
	  kd2= nb_carac_jus_fin_ligne[indexs[k]-1];
	  nombre = kd-kd2-ni;
	  fwrite(cars+kd2+ni,sizeof(char),nombre,ficcom);
   }
   fclose(ficcom);
   /*rajout yassine*/
   tt_free2((void**)&nb_carac_jus_fin_ligne,"nb_carac_jus_fin_ligne");
   /*fin*/
   tt_free2((void**)&cars,"cars");
   tt_free2((void**)&indexs,"indexs");
	return(OK_DLL);
}


int focas_main(char *nom_fichier1,int type_fichier1,
		 char *nom_fichier2,int type_fichier2,
		 int flag_focas,
		 int flag_sature1,
		 int flag_sature2,
		 char *nom_fichier_com,char *nom_fichier_dif,
		 int *nbcom,
		 double *transf_1vers2,double *transf_2vers1,
		 int *nbcom2,
		 double *transf2_1vers2,double *transf2_2vers1,
               double epsilon, double delta, double seuil_poids)
/*************************************************************************/
/* FOCAS_MAIN                                                            */
/* But : appariement de deux listes d'etoiles sorties de KAOPHOT         */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* 1) Charge les deux listes en memoire. La liste cible est NOM_FICHIER1 */
/*    et la liste de reference est NOM_FICHIER2.                         */
/* 2) Trie chaque liste selon les magnitudes croissantes.                */
/* 3) Extrait un lot des NOBJ premieres etoiles de chaque liste.         */
/* 4) Appel a FOCAS_MATCH. Cree une liste de correspondances.            */
/* 5) Si le nombre de meilleures correspondances est superieur ou        */
/*    egal a 4 alors on a trouve le bon l'appariement. Sinon, on         */
/*    revient au point 3) en prenant les NOBJ etoiles suivantes.         */
/* 6) On calcule la matrice de transformation des coordonnees des        */
/*    etoiles de la liste 1 dans le repere des coordonnees de la liste   */
/*    2. (appel a FOCAS_REGISTER).                                       */
/* 7) On effectue l'appariement des deux listes completes d'etoiles.     */
/*    L'appariement est bon lorsque la distance entre les deux etoiles   */
/*    est inferieure a "delta" pixel.                                    */
/* 8) On sauvegarde la liste commune des etoiles appariees dans le       */
/*    fichier NOM_FICHIER0.                                              */
/*                                                                       */
/* Parametres d'entree :                                                 */
/*   NOM_FICHIER1  : fichier d'etoiles (champ de reference).             */
/*   TYPE_FICHIER1 : flag indiquant le type de NOM_FICHIER1              */
/*                   =0 pour un ordre des colonnes type KAOPHOT 1        */
/*                      indice X Y fwhmx fwhmy I mag fond qualite        */
/*                   =1 pour un ordre des colonnes type NOM_FICHIER_COM: */
/*                      X1 Y1 mag1 X2 Y2 mag2 mag1-2 qualite1 qualite2   */
/*                      (lit l'indice 1)                                 */
/*                   =2 pour un ordre des colonnes type NOM_FICHIER_COM: */
/*                      X1 Y1 mag1 X2 Y2 mag2 mag1-2 qualite1 qualite2   */
/*                      (lit l'indice 2)                                 */
/*                   =3 pour un ordre des colonnes type KAOPHOT 2        */
/*                      indice X Y mag_relative AD DEC mag qualite fwhm  */
/*                      sharp                                            */
/*   NOM_FICHIER2  : fichier d'etoiles (champ a apparier).               */
/*   TYPE_FICHIER2 : flag indiquant le type de NOM_FICHIER2              */
/*   FLAG_FOCAS    : flag interne permettant de choisir des options :    */
/*    =0 : pour effectuer un appariement simple (FOCAS)                  */
/*    =1 : pour contraindre des translations (AUTOTRANS)                 */
/*    =2 : effectue l'appariement avec les coefs de *transf_1vers2 et    */
/*         *transf_2vers1 sans passer par FOCAS.                         */
/*   FLAG_SATURE1  : flag interne permettant de choisir des options :    */
/*    =0 : pour exclure les etoiles qui saturent dans le matching        */
/*    =1 : pour inclure les etoiles qui saturent dans le matching        */
/*   FLAG_SATURE2  : flag interne permettant de choisir des options :    */
/*    =0 : pour inclure les etoiles qui saturent dans les fichiers       */
/*         de sortie.                                                    */
/*    =1 : pour exclure les etoiles qui saturent dans les fichiers       */
/*         de sortie.                                                    */
/*                                                                       */
/* Parametres de sortie :                                                */
/* *NOM_FICHIER_COM : nom de fichier qui contiendra la liste des etoiles */
/*                    communes aux deux tableaux d'entree.               */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/* *NOM_FICHIER_DIF : nom de fichier qui contiendra la liste des etoiles */
/*                    differentes aux deux tableaux d'entree.            */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x2/1 y2/1 mag2/2 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/*                     (x1,y1) coordonnees (x2,y2) dans le repere 1      */
/*   *NBCOM         : nombre d'etoiles communes aux deux fichiers        */
/*   *TRANSF_1VERS2 : coefficients de transfert liste 1 vers la liste 2  */
/*     ce tableau comporte 12 elements dont 6 sont references ainsi :    */
/*     x1/2 = [1*3+1] * x1/1 + [1*3+2] * y1/1 + [1*3+3]                  */
/*     y1/2 = [2*3+1] * x1/1 + [2*3+2] * y1/1 + [2*3+3]                  */
/*   *TRANSF_2VERS1 : coefficients de transfert liste 2 vers la liste 1  */
/*     ce tableau comporte 12 elements dont 6 sont references ainsi :    */
/*     x2/1 = [1*3+1] * x2/2 + [1*3+2] * y2/2 + [1*3+3]                  */
/*     y2/1 = [2*3+1] * x2/2 + [2*3+2] * y2/2 + [2*3+3]                  */
/*   *NBCOM2        : nombre d'etoiles communes aux deux fichiers (2nd ordre ) */
/*   =NULL si l'on ne veut pas calculer les coefs du 2nd ordre.          */
/*   !=2 en entree si l'on veut calculer les coefs du 2nd ordre et que   */
/*     les correspondances soient calculees avec l'ordre 1.              */
/*   2 en entree si l'on veut calculer les coefs du 2nd ordre et que les */
/*     correspondances soient calculees avec l'ordre 2.                  */
/*   *TRANSF2_1VERS2 : coefficients de transfert liste 1 vers la liste 2 */
/*     ce tableau comporte 33 elements dont 20 sont references ainsi :   */
/*     x1/2 = [1*3+1] * x1/1 + [1*3+2] * y1/1 + [1*3+3] + [1*3+4] * x1/1 * y1/1 + [1*3+5] * x1/1 * x1/1 + [1*3+6] * y1/1 * y1/1  */
/*     y1/2 = [2*3+1] * x1/1 + [2*3+2] * y1/1 + [2*3+3] + [2*3+4] * x1/1 * y1/1 + [2*3+5] * x1/1 * x1/1 + [2*3+6] * y1/1 * y1/1  */
/*   =NULL si l'on ne veut pas calculer les coefs du 2nd ordre.          */
/*   *TRANSF2_2VERS1 : coefficients de transfert liste 2 vers la liste 1  */
/*     ce tableau comporte 33 elements dont 20 sont references ainsi :    */
/*     x2/1 = [1*3+1] * x2/2 + [1*3+2] * y2/2 + [1*3+3] + [1*3+4] * x2/2 * y2/2 + [1*3+5] * x2/2 * x2/2 + [1*3+6] * y2/2 * y2/2  */
/*     y2/1 = [2*3+1] * x2/2 + [2*3+2] * y2/2 + [2*3+3] + [2*3+4] * x2/2 * y2/2 + [2*3+5] * x2/2 * x2/2 + [2*3+6] * y2/2 * y2/2  */
/*   =NULL si l'on ne veut pas calculer les coefs du 2nd ordre.          */
/*                                                                       */
/*************************************************************************/
{
   int n1,nb1deb,nb1fin,n2,nb2deb,nb2fin,sortie0=0;
   int nb1,nb1tot;
   struct focas_tableau_entree *data_tab10=NULL;
   struct focas_tableau_entree *data_tab1=NULL;
   int nb2,nb2tot;
   struct focas_tableau_entree *data_tab20=NULL;
   struct focas_tableau_entree *data_tab2=NULL;
   struct focas_tableau_corresp *corresp=NULL;
   struct focas_tableau_corresp *differe=NULL;
   int nb,nbc=0,indice_cut1=0,indice_cut2=0,nobj;
   /*
   double epsilon,delta=1.0;
   */
   int poids_max;
   int nb_coef_a=3,total=0,nbcmax,flag_corresp,flag_tri,nbmax;
   int nombre,taille,msg;
   int ordre_corresp=1/*,nbc2=0*/;

   *nbcom=0;

   /*============================================================*/
   /*= lit les donnees completes des deux tables ASCII           */
   /*============================================================*/

   /*--- lecture des donnees dans le fichier #1.lst de autophot ---*/
   if ((msg=focas_compte_lignes(nom_fichier1,&nb1tot))!=OK) {
      return(msg);
   }
   nombre=nb1tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab10,&nombre,&taille,"data_tab10"))!=OK) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab10");
      return(PB);
   }
   if (focas_get_tab(nom_fichier1,type_fichier1,&nb1tot,data_tab10,flag_sature1)!=OK) {tt_free(data_tab10,"data_tab10");return(PB); }
   /*--- lecture des donnees dans le fichier #2.lst de autophot ---*/
   if ((msg=focas_compte_lignes(nom_fichier2,&nb2tot))!=OK) {
      tt_free(data_tab10,"data_tab10");
      return(msg);
   }
   nombre=nb2tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab20,&nombre,&taille,"data_tab20"))!=OK) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab20");
      tt_free2((void**)&data_tab10,"data_tab10");
      return(PB);
   }
   if (focas_get_tab(nom_fichier2,type_fichier2,&nb2tot,data_tab20,flag_sature1)!=OK) { tt_free(data_tab10,"data_tab10");tt_free(data_tab20,"data_tab20");return(PB); }
   /*
   printf("1. La liste %s comporte %d etoiles.\n",nom_fichier1,nb1tot);
   printf("2. La liste %s comporte %d etoiles.\n",nom_fichier2,nb2tot);
   */

   /* ============================================== */
   /* === effectue l'appariement des deux listes === */
   /* ============================================== */
   if (nbcom2!=NULL) { if (*nbcom2==2) { ordre_corresp=2;} }
   nbmax=(nb2tot>nb1tot)?nb2tot:nb1tot;
   if ((flag_focas==0)||(flag_focas==1)) {
      if ((nb1tot==0)||(nb2tot==0)) {
	 /* - cas : il n'y a pas d'etoiles dans les listes -*/
	 nbc=0;
	 sortie0=1;
	 nb1=nb2=1;
	 /* - allocation de corresp -*/
	 nombre=(nb1+1)*nb2+1;
	 taille=sizeof(struct focas_tableau_corresp);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&corresp,&nombre,&taille,"corresp"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer corresp");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    return(PB);
	 }
      } else {
	 sortie0=0;
      }
      /*============================================================*/
      /*= identifie l'accord entre des parties des deux listes      */
      /*============================================================*/
      nobj=FOCAS_NOBJINI;
      if (epsilon==0.) {
         epsilon=FOCAS_EPSIINI;
      }
      if (seuil_poids==0.) {
         seuil_poids=1./3.;
      }
      if (delta==0.) {
         delta=1.0;
      }
      /*nb_essais=1; ?*/
      while (sortie0==0) {
	 nb1deb=1;
	 nb2deb=1;
	 nb1=nb1fin= (nb1tot>nobj) ? nobj : nb1tot ;
	 nb2=nb2fin= (nb2tot>nobj) ? nobj : nb2tot ;

	 /*--- dimensionne les tableaux de pointeurs ---*/
	 nombre=nb1fin+2;
	 taille=sizeof(struct focas_tableau_entree);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab1,&nombre,&taille,"data_tab1"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab1");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    return(PB);
	 }
	 nombre=nb2fin+2;
	 taille=sizeof(struct focas_tableau_entree);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab2,&nombre,&taille,"data_tab2"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab2");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&data_tab1,"data_tab1");
	    return(PB);
	 }
	 nombre=nbmax+1;
	 taille=sizeof(struct focas_tableau_corresp);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&corresp,&nombre,&taille,"corresp"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer corresp");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&data_tab1,"data_tab1");tt_free2((void**)&data_tab2,"data_tab2");
	    return(PB);
	 }
	 n1=nb1deb;

	 /* --- extrait le lot LISTE 1 d'etoiles de #1.lst ---*/
	 do {
	    data_tab1[n1-nb1deb+1].x      =data_tab10[n1].x;
	    data_tab1[n1-nb1deb+1].y      =data_tab10[n1].y;
	    data_tab1[n1-nb1deb+1].mag    =data_tab10[n1].mag;
	    data_tab1[n1-nb1deb+1].qualite=data_tab10[n1].qualite;
	    data_tab1[n1-nb1deb+1].ad     =data_tab10[n1].ad;
	    data_tab1[n1-nb1deb+1].dec    =data_tab10[n1].dec;
	    data_tab1[n1-nb1deb+1].mag_gsc=data_tab10[n1].mag_gsc;
	    data_tab1[n1-nb1deb+1].type   =data_tab10[n1].type;
	    /*
	    // Ecrire une procedure qui recherche XXmin1,xxmax1,yymin1,yymax1
	    // en scannant *data_tab10
	    // if ((data_tab10[n1].x>=xxmin1)&&(data_tab10[n1].x<=xxmax1)&&
	    //     (data_tab10[n1].y>=yymin1)&&(data_tab10[n1].y<=yymax1) ) {
	    */
	    n1++;
	    /*// }*/
	 } while (n1<=nb1fin) ; /* revoir cette condition de sortie ##*/
	 n2=nb2deb;

	 /* --- extrait le lot LISTE 2 d'etoiles de #2.lst ---*/
	 do {
	    data_tab2[n2-nb2deb+1].x      =data_tab20[n2].x;
	    data_tab2[n2-nb2deb+1].y      =data_tab20[n2].y;
	    data_tab2[n2-nb2deb+1].mag    =data_tab20[n2].mag;
	    data_tab2[n2-nb2deb+1].qualite=data_tab20[n2].qualite;
	    data_tab2[n2-nb2deb+1].ad     =data_tab20[n2].ad;
	    data_tab2[n2-nb2deb+1].dec    =data_tab20[n2].dec;
	    data_tab2[n2-nb2deb+1].mag_gsc=data_tab20[n2].mag_gsc;
	    data_tab2[n2-nb2deb+1].type   =data_tab20[n2].type;
	    /*
	    // if ((data_tab20[n2].x>=xxmin2)&&(data_tab20[n2].x<=xxmax2)&&
	    //     (data_tab20[n2].y>=yymin2)&&(data_tab20[n2].y<=yymax2) ) {
	    */
	    n2++;
	    /*// }*/
	 } while (n2<=nb2fin) ;

	 /* --- On rentre ici dans le coeur de l'algo Focas ! ---*/
   	 if (focas_match(data_tab1,nb1,data_tab2,nb2,epsilon,seuil_poids,corresp,&nbc,&poids_max,&indice_cut1,&indice_cut2)!=OK) {
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&data_tab1,"data_tab1");tt_free2((void**)&data_tab2,"data_tab2");
	    tt_free2((void**)&corresp,"corresp");
	    return(PB);
	 }
   	 tt_free2((void**)&data_tab1,"data_tab1");
	 tt_free2((void**)&data_tab2,"data_tab2");

	 /*--- conditions de sortie ---*/
	 nb=(nb1<nb2) ? nb1 : nb2;
	 /*pmax=(nb*nb-3*nb+2)/2;*/
	 nb=(nb <4  ) ? nb  : 4  ;
	 if (nbc>=nb) {
	    /* - calcule les matrices de transformation -*/
	    if (focas_register(corresp,nbc,transf_1vers2,transf_2vers1)!=OK) {
	       tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
     	       tt_free2((void**)&corresp,"corresp");
	       return(PB);
	    }
   	    /*
	    printf("%f %f : %f\n",transf_1vers2[1*3+1],transf_1vers2[1*3+2],transf_1vers2[1*3+3]);
	    printf("%f %f : %f\n",transf_1vers2[2*3+1],transf_1vers2[2*3+2],transf_1vers2[2*3+3]);
	    */
	    /* - calcul le nombre total d'appariements -*/
   	    if (focas_liste_commune("","",data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,1,delta,&total,corresp,corresp,0)!=OK) {
	       tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
     	       tt_free2((void**)&corresp,"corresp");
	       return(PB);
	    }
   	 }
	 /*if ((nbc>=nb)&&(total>=nbc)) { sortie0=1; }*/
	 if (nbc>=nb) { sortie0=1; }
         else {sortie0=1; nbc=0;}
	 if (flag_focas==1) {
	    /* - cas : contraintes en translations -*/
	    if ((fabs(transf_2vers1[1*nb_coef_a+1]-1.0)>2e-2)||
		(fabs(transf_2vers1[1*nb_coef_a+2]    )>2e-2)||
		(fabs(transf_2vers1[2*nb_coef_a+1]    )>2e-2)||
		(fabs(transf_2vers1[2*nb_coef_a+2]-1.0)>2e-2)  ) {
	       sortie0=0;
	    }
	 }
	 if (sortie0==0) {
     	     tt_free2((void**)&corresp,"corresp");
	    /*boucle_old=boucle;*/
	 }
      }
      /* - Cas de non correspondance. On apparie alors les deux -*/
      /* - etoiles les plus brillantes. -*/
      if (nbc==0) {
	 if (nb1tot==0) {
	    data_tab10[0].x=0.;
	    data_tab10[0].y=0.;
	 }
	 if (nb2tot==0) {
	    data_tab20[0].x=0.;
	    data_tab20[0].y=0.;
	 }
	 corresp[1].indice1=0;
	 corresp[1].x1     =data_tab10[0].x;
	 corresp[1].y1     =data_tab10[0].y;
	 corresp[1].indice2=0;
	 corresp[1].x2     =data_tab20[0].x;
	 corresp[1].y2     =data_tab20[0].y;
	 if ((nb1tot==0)||(nb2tot==0)) {
	    transf_2vers1[1*nb_coef_a+1]=1.0;
	    transf_2vers1[1*nb_coef_a+2]=0.0;
	    transf_2vers1[2*nb_coef_a+1]=0.0;
	    transf_2vers1[2*nb_coef_a+2]=1.0;
	    transf_1vers2[1*nb_coef_a+1]=1.0;
	    transf_1vers2[1*nb_coef_a+2]=0.0;
	    transf_1vers2[2*nb_coef_a+1]=0.0;
	    transf_1vers2[2*nb_coef_a+2]=1.0;
	 } else {
   	    if (focas_register(corresp,1,transf_1vers2,transf_2vers1)!=OK) {
	       tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
     	       tt_free2((void**)&corresp,"corresp");
	       return(PB);
	    }
   	 }
      }
      tt_free2((void**)&corresp,"corresp");
   }

   /* =============================================================== */
   /* = Les matrices de tranformation sont deja calculees et on va  = */
   /* = maintenant etablir les tableaux de correspondance entre les = */
   /* = deux listes.                                                = */
   /* =============================================================== */
   nbcmax=(nb1tot>nb2tot)?nb1tot:nb2tot;

   /* --- on dimensionne les listes de correspondance et de differences ---*/
   nombre=nbcmax+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&corresp,&nombre,&taille,"corresp"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer corresp");
      tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
   return(PB);
   }
   nombre=nbcmax+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&differe,&nombre,&taille,"differe"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer differe");
      tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
      tt_free2((void**)&corresp,"corresp");
   return(PB);
   }

   /* --- On remplit les tableaux de correspondance et de difference   ---*/
   /* --- et l'on calcule une matrice de passage entre les deux listes ---*/
   flag_corresp=(flag_sature2==0)?1:2;
   if ((nbc!=0)&&((flag_focas==0)||(flag_focas==1))) {
      if (focas_liste_commune("","",data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,1,delta,&nbc,corresp,differe,1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
      /* - on calcule la matrice de passage d'ordre 1 d'une liste a l'autre  -*/
      if (focas_register(corresp,nbc,transf_1vers2,transf_2vers1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
      if ((transf2_1vers2!=NULL)&&(transf2_2vers1!=NULL)) {
         /* - on calcule la matrice de passage d'ordre 2 d'une liste a l'autre  -*/
         focas_register_2nd(corresp,nbc,transf2_1vers2,transf2_2vers1);
         /*
         if (focas_register_2nd(corresp,nbc,transf2_1vers2,transf2_2vers1)!=OK) {
   	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	    return(PB);
         }
         */
      }
   }

   flag_tri=1; /* a faire rentrer comme parametre de focas main...*/
   /* --- ? ---*/
   if (flag_tri==0) {
      if (focas_get_tab(nom_fichier1,type_fichier1,&nb1tot,data_tab10,flag_sature1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
      if (focas_get_tab(nom_fichier2,type_fichier2,&nb2tot,data_tab20,flag_sature1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
      flag_corresp+=10;
   }

   /* --- On remplit les tableaux de correspondance et de difference   ---*/
   if (focas_liste_commune(nom_fichier_com,nom_fichier_dif,data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,ordre_corresp,delta,&nbc,corresp,differe,flag_corresp)!=OK) {
      tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
      tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
      return(PB);
   }

   /* --- Cas de translations contraintes ---*/
   if ((nbc!=0)&&(flag_focas==1)&&((flag_focas==0)||(flag_focas==1))) {
      focas_transmoy(corresp,nbc,transf_1vers2,transf_2vers1);
   }

   tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
   tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
   *nbcom=nbc;

   return(OK);
}

int focas_match(struct focas_tableau_entree *data_tab1,int nb1,struct focas_tableau_entree *data_tab2,int nb2,double epsilon,double seuil_poids,struct focas_tableau_corresp *corresp,int *nbcorresp,
		  int *poids_max,int *indice_cut1,int *indice_cut2)
/*************************************************************************/
/* FOCAS_MATCH                                                           */
/* But : cree une liste de correspondance entre 2 listes *data_tab       */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* 1) Calcule toutes les distances entre les etoiles de chaque liste.    */
/* 2) Calcule tous les triangles (a,b,c) avec a>b>c dans chaque liste.   */
/*    Ne garde que les triangles qui verifient (b/a)<0.9.                */
/* 3) Trie les deux listes de triangles selon les ((b/a) croissants.     */
/* 4) Apparie les triangles en comparant les x=(b/a) et y=(c/a) entre    */
/*    les deux listes. L'appariement est bon lorsque la distance entre   */
/*    le point (xi1,yi1) est a une distance inferieure a EPSILON du      */
/*    point (xj2,yj2).                                                   */
/* 5) Pour chaque appariement, on ajoute 1 a une matrice de 'vote'       */
/*    donnant la correspondance entre les etoiles des deux listes.       */
/* 6) On trie la matrice de vote selon les valeurs croissantes de vote.  */
/* 7) On ne garde que les meilleures correspondances definies par :      */
/*     Attention, nouvelle methode en cours.                             */
/*     - un nombre de vote superieur a la moitie de la valeur du         */
/*       nombre de vote maximum.                                         */
/*     - l'etoile d'une correspondance ne doit pas deja apparaitre       */
/*       dans une correspandace qui a un nombre de votes plus eleve.     */
/*                                                                       */
/* ENTREES :                                                             */
/* *data_tab1 : tableau des entrees 1                                    */
/* nb1        : nombre d'entrees dans le tableau 1                       */
/* *data_tab2 : tableau des entrees 2                                    */
/* nb2        : nombre d'entrees dans le tableau 2                       */
/* epsilon    : cote du carre d'incertitude dans l'espace des triangles  */
/* seuil_poids: fraction du poids maximum autorise (entre 0 et 1) pour   */
/*              une correspondance acceptable (0.3 habituellement)       */
/*                                                                       */
/* SORTIES :                                                             */
/* *corresp   : tableau des correspondances                              */
/* *nbcorresp : nombre de correspondances                                */
/* *poids_max : poids de la valeur maximale de la matrice de vote        */
/* *indice_cut1 indice de la premiere correspondance aberrante           */
/* *indice_cut2 indice de coupure du critere seuil_poids                 */
/*************************************************************************/
{
   int nb11,nb111;
   struct focas_tableau_dist *dist1;
   struct focas_tableau_triang *triang1;
   int nb22,nb222;
   struct focas_tableau_dist *dist2;
   struct focas_tableau_triang *triang2;
   struct focas_tableau_vote *vote;
   int nbc=0;
   int nombre,taille,msg;

   /*--- dimensionne les tableaux de pointeurs ---*/
   dist1=NULL;
   dist2=NULL;
   triang1=NULL;
   triang2=NULL;
   vote=NULL;
   nb11 =(nb1*(nb1-1))/2;
   nb111=(nb1*(2+nb1*(nb1-3)))/6;
   nb22 =(nb2*(nb2-1))/2;
   nb222=(nb2*(2+nb2*(nb2-3)))/6;
   nombre=nb11+2;
   taille=sizeof(struct focas_tableau_dist);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&dist1,&nombre,&taille,"dist1"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_match for pointer dist1");
      return(PB);
   }
   nombre=nb111+2;
   taille=sizeof(struct focas_tableau_triang);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&triang1,&nombre,&taille,"triang1"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_match for pointer triang1");
      tt_free2((void**)&dist1,"dist1");
      return(PB);
   }
   nombre=nb22+2;
   taille=sizeof(struct focas_tableau_dist);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&dist2,&nombre,&taille,"dist2"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_match for pointer dist2");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      return(PB);
   }
   nombre=nb222+2;
   taille=sizeof(struct focas_tableau_triang);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&triang2,&nombre,&taille,"triang2"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_match for pointer triang2");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");
      return(PB);
   }
   nombre=nb1*nb2+2;
   taille=sizeof(struct focas_tableau_vote);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vote,&nombre,&taille,"vote"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_match for pointer vote");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
      return(PB);
   }

   /* --- calcul de la distance mutuelle entre deux etoiles LISTE 1---*/
   if (focas_calcul_dist(nb1,data_tab1,dist1)!=OK) {
      msg=TT_ERR_MATCHING_CALCUL_DIST;
      tt_errlog("",msg,"Pb calloc in focas_match when compute focas_calcul_dist for liste 1");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
      tt_free2((void**)&vote,"vote");
      return(msg);
   }

   /* --- calcul des triangles LISTE 1 ---*/
   if (focas_calcul_triang(nb11,&nb111,dist1,triang1)!=OK) {
      msg=TT_ERR_MATCHING_CALCUL_TRIANG;
      tt_errlog("",msg,"Pb in focas_match when compute focas_calcul_triang for liste 1");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
      tt_free2((void**)&vote,"vote");
      return(msg);
   }
   /* --- calcul de la distance mutuelle entre deux etoiles LISTE 2---*/
   if (focas_calcul_dist(nb2,data_tab2,dist2)!=OK) {
      msg=TT_ERR_MATCHING_CALCUL_DIST;
      tt_errlog("",msg,"Pb in focas_match when compute focas_calcul_dist for liste 2");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
      tt_free2((void**)&vote,"vote");
      return(msg);
   }
   /* --- calcul des triangles LISTE 2---*/
   if (focas_calcul_triang(nb22,&nb222,dist2,triang2)!=OK) {
      msg=TT_ERR_MATCHING_CALCUL_TRIANG;
      tt_errlog("",msg,"Pb in focas_match when compute focas_calcul_triang for liste 2");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
      tt_free2((void**)&vote,"vote");
      return(msg);
   }
   /* --- matching entre les deux listes ---*/
   if (focas_match_triang(triang1,nb111,triang2,nb222,nb1,nb2,vote,epsilon)!=OK) {
      msg=TT_ERR_MATCHING_MATCH_TRIANG;
      tt_errlog("",msg,"Pb in focas_match when compute focas_match_triang");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
      tt_free2((void**)&vote,"vote");
      return(msg);
   }
   /* --- selectionne les meilleures correspondances ---*/
   /*if (focas_best_corresp(nb1,data_tab1,nb2,data_tab2,seuil_poids,vote,&nbc,corresp,poids_max,indice_cut1,indice_cut2)!=OK) {*/
   if (focas_best_corresp2(nb1,data_tab1,nb2,data_tab2,seuil_poids,vote,&nbc,corresp,poids_max,indice_cut1,indice_cut2)!=OK) {
      msg=TT_ERR_MATCHING_BEST_CORRESP;
      tt_errlog("",msg,"Pb in focas_match when compute focas_best_corresp2");
      tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
      tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
      tt_free2((void**)&vote,"vote");
      return(msg);
   }

   *nbcorresp=nbc;
   tt_free2((void**)&dist1,"dist1");tt_free2((void**)&triang1,"triang1");
   tt_free2((void**)&dist2,"dist2");tt_free2((void**)&triang2,"triang2");
   tt_free2((void**)&vote,"vote");
   return(OK);
}

int focas_register(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1)
/*************************************************************************/
/* FOCAS_REGISTER                                                        */
/* But : calcule les coefficients de transformation de listes d'etoiles  */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* .)  A employer apres FOCAS_MATCH.                                     */
/* 1)  On calcule la matrice de transformation des coordonnees des       */
/*     etoiles de la liste 1 dans le repere des coordonnees de la liste  */
/*     2 et vice versa.                                                  */
/*                                                                       */
/* ENTREES :                                                             */
/* *corresp   : tableau des correspondances                              */
/* nbcorresp  : nombre de correspondances                                */
/*                                                                       */
/* SORTIES :                                                             */
/* *transf_1vers2 : tableau des six coefs de transformation pour une     */
/*                  etoile de la liste 1 dans le repere de la liste 2.   */
/* *transf_2vers1 : tableau des six coefs de transformation pour une     */
/*                  etoile de la liste 2 dans le repere de la liste 1.   */
/*                                                                       */
/*************************************************************************/
{
   int nbc;
   int nb_coef_a,lig,col,j;
   double *xx=NULL,*xy=NULL,*a=NULL,*vec_p=NULL,*val_p=NULL;
   int nombre,taille,msg;
   int *valid=NULL,kv;
   double *valeur=NULL;
   double x1,y1,x2,y2,dx,dy;
   double i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta,mean,sigma;
   /*
   FILE *f;
   */
   nbc=nbcorresp;
   nb_coef_a=3;
   /*
   f=fopen("matrix.txt","wt");
   fclose(f);
   */

   if (nbc>=3) {
      nombre=(nb_coef_a+1)*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&xx,&nombre,&taille,"xx"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer xx");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=3*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&xy,&nombre,&taille,"xy"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer xy");
	 tt_free2((void**)&xx,"xx");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=3*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&a,&nombre,&taille,"a"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer a");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=(nb_coef_a+1)*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec_p,&nombre,&taille,"vec_p"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer vec_p");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=nb_coef_a+1;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&val_p,&nombre,&taille,"val_p"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer val_p");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 tt_free2((void**)&vec_p,"vec_p");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=nbc+1;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&valid,&nombre,&taille,"valid"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer valid");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 tt_free2((void**)&vec_p,"vec_p");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=nbc+1;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&valeur,&nombre,&taille,"valeur"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer valeur");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 tt_free2((void**)&vec_p,"vec_p");
   	 tt_free2((void**)&valid,"valid");
	 return(TT_ERR_PB_MALLOC);
      }

      for (j=0;j<=nbc;j++) {
         valid[j]=TT_YES;
      }
      for (kv=0;kv<=1;kv++) {

         /***************************************************/
         /* ====== x1 = A*x2 + B*y2 + C (idem pur y1) ======*/
         /* --- a1 = A  et  x1j = x2                    --- */
         /* --- a2 = B  et  x2j = y2                    --- */
         /* --- a3 = C  et  x3j = 1                     --- */
         /***************************************************/
         /* === calcule les elements de matrice XX ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
   	    for (col=1;col<=nb_coef_a;col++) {
               xx[lig+nb_coef_a*col]=0;
               if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2);} } }
               if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2);} } }
               if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x2              );} } }
               if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].x2);} } }
               if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2);} } }
               if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y2              );} } }
               if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].x2);} } }
               if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].y2);} } }
               if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(            1.000          );} } }
            }
         }
         focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
         /* === inverse les valeurs propres de la matrice XX ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
	    if (*(val_p+lig)!=0) { *(val_p+lig)=1/ *(val_p+lig); } else {
	       msg=TT_ERR_NULL_EIGENVALUE;
	       tt_errlog("",msg,"irregular first transformation in focas_register ");
	       tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	       tt_free2((void**)&a,"a");
	       tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
   	       tt_free2((void**)&valid,"valid");tt_free2((void**)&valeur,"valeur");
	       return(msg);
            }
         }
         /* === calcul de la matrice XX-1 ===*/
         focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
         /* === calcule les elements de matrice XY pour x1 ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
	    xy[lig+1]=0;
            if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x1*corresp[j].x2);} } }
            if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x1*corresp[j].y2);} } }
            if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x1              );} } }
         }
         /* === calcule les coefficients de transformation pour x1 ===*/
         focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
         for (col=1;col<=nb_coef_a;col++) {
	    transf_2vers1[1*nb_coef_a+col]=a[1*1+col];
         }
         /* === calcule les elements de matrice XY pour y1 ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
	    xy[lig+1]=0;
            if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y1*corresp[j].x2);} } }
            if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y1*corresp[j].y2);} } }
            if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y1              );} } }
         }
         /* === calcule les coefficients de transformation pour y1 ===*/
         focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
         for (col=1;col<=nb_coef_a;col++) {
	    transf_2vers1[2*nb_coef_a+col]=a[1*1+col];
         }

         /* === verif des validites ===*/
         /* on elimine les distances > a 2 sigma */
         i=0.;mu_i=0.;mu_ii=0.;sx_ii=0.;
         sx_i=0;
         for (j=1;j<=nbc;j++) {
            x2=corresp[j].x2;
            y2=corresp[j].y2;
            x1=transf_2vers1[1*nb_coef_a+1]*x2+transf_2vers1[1*nb_coef_a+2]*y2+transf_2vers1[1*nb_coef_a+3];
            y1=transf_2vers1[2*nb_coef_a+1]*x2+transf_2vers1[2*nb_coef_a+2]*y2+transf_2vers1[2*nb_coef_a+3];
            dx=corresp[j].x1-x1;
            dy=corresp[j].y1-y1;
            valeur[j]=sqrt(dx*dx+dy*dy);
    	    /* --- algo de la valeur moy et ecart type de Miller ---*/
  	    if (j==1) {mu_i=valeur[j];}
	    i=(double) (j+1);
	    delta=valeur[j]-mu_i;
	    mu_ii=mu_i+delta/(i);
	    sx_ii=sx_i+delta*(valeur[j]-mu_ii);
	    mu_i=mu_ii;
	    sx_i=sx_ii;
         }
         mean=mu_ii;
         sigma=0.;
         if (i!=0.) {
            sigma=sqrt(sx_ii/i);
         }
         for (j=1;j<=nbc;j++) {
            if (fabs(valeur[j]-mean)>2.*sigma) {
               valid[j]=TT_NO;
            }
         }
         /*
         f=fopen("matrix.txt","at");
         fprintf(f,"%f %f %f\n",transf_2vers1[1*nb_coef_a+1],transf_2vers1[1*nb_coef_a+2],transf_2vers1[1*nb_coef_a+3]);
         fprintf(f,"%f %f %f\n",transf_2vers1[2*nb_coef_a+1],transf_2vers1[2*nb_coef_a+2],transf_2vers1[2*nb_coef_a+3]);
         fprintf(f,"\n");
         fclose(f);
         */
      }

      /***************************************************/
      /* ====== x2 = A*x1 + B*y1 + C (idem pur y2) ======*/
      /* --- a1 = A  et  x1j = x1                    --- */
      /* --- a2 = B  et  x2j = y1                    --- */
      /* --- a3 = C  et  x3j = 1                     --- */
      /***************************************************/
      /* === calcule les elements de matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
         for (col=1;col<=nb_coef_a;col++) {
	    xx[lig+nb_coef_a*col]=0;
            if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1);} } }
            if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1);} } }
            if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x1              );} } }
            if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].x1);} } }
            if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1);} } }
            if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y1              );} } }
            if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].x1);} } }
            if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].y1);} } }
            if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(            1.000          );} } }
         }
      }
      focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
      /* === inverse les valeurs propres de la matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
         if (*(val_p+lig)!=0) { *(val_p+lig)=1/ *(val_p+lig); } else {
	    msg=TT_ERR_NULL_EIGENVALUE;
	    tt_errlog("",msg,"irregular second transformation in focas_register ");
	    tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	    tt_free2((void**)&a,"a");
	    tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
   	    tt_free2((void**)&valid,"valid");tt_free2((void**)&valeur,"valeur");
	    return(msg);
         }
      }
      /* === calcul de la matrice XX-1 ===*/
      focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
      /* === calcule les elements de matrice XY pour x2 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
         xy[lig+1]=0;
         if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x2*corresp[j].x1);} } }
         if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x2*corresp[j].y1);} } }
         if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x2              );} } }
      }
      /* === calcule les coefficients de transformation pour x2 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
         transf_1vers2[1*nb_coef_a+col]=a[1*1+col];
      }
      /* === calcule les elements de matrice XY pour y2 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
         xy[lig+1]=0;
         if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y2*corresp[j].x1);} } }
         if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y2*corresp[j].y1);} } }
         if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y2              );} } }
      }
      /* === calcule les coefficients de transformation pour y2 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
         transf_1vers2[2*nb_coef_a+col]=a[1*1+col];
      }

      tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
      tt_free2((void**)&a,"a");
      tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
      tt_free2((void**)&valid,"valid");tt_free2((void**)&valeur,"valeur");
   } else if ((nbc<=2)&&(nbc>=1)) {
      transf_1vers2[1*nb_coef_a+1]=1.0;
      transf_1vers2[1*nb_coef_a+2]=0.0;
      transf_1vers2[1*nb_coef_a+3]=corresp[1].x2-corresp[1].x1;
      transf_1vers2[2*nb_coef_a+1]=0.0;
      transf_1vers2[2*nb_coef_a+2]=1.0;
      transf_1vers2[2*nb_coef_a+3]=corresp[1].y2-corresp[1].y1;
      transf_2vers1[1*nb_coef_a+1]=1.0;
      transf_2vers1[1*nb_coef_a+2]=0.0;
      transf_2vers1[1*nb_coef_a+3]=corresp[1].x1-corresp[1].x2;
      transf_2vers1[2*nb_coef_a+1]=0.0;
      transf_2vers1[2*nb_coef_a+2]=1.0;
      transf_2vers1[2*nb_coef_a+3]=corresp[1].y1-corresp[1].y2;
   }
   return(OK);
}

int focas_register_2nd(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1)
/*************************************************************************/
/* FOCAS_REGISTER                                                        */
/* But : calcule les coefficients de transformation de listes d'etoiles  */
/*       du second ordre                                                 */
/*                                                                       */
/* .)  A employer apres focas_register (ordre 1)                         */
/* 1)  On calcule la matrice de transformation des coordonnees des       */
/*     etoiles de la liste 1 dans le repere des coordonnees de la liste  */
/*     2 et vice versa.                                                  */
/*                                                                       */
/* ENTREES :                                                             */
/* *corresp   : tableau des correspondances                              */
/* nbcorresp  : nombre de correspondances                                */
/*                                                                       */
/* SORTIES :                                                             */
/* *transf2_1vers2 : tableau des 20 coefs de transformation pour une     */
/*                   etoile de la liste 1 dans le repere de la liste 2.  */
/* *transf2_2vers1 : tableau des 20 coefs de transformation pour une     */
/*                   etoile de la liste 2 dans le repere de la liste 1.  */
/*                                                                       */
/*************************************************************************/
{
   int nbc;
   int nb_coef_a,lig,col,j;
   double *xx=NULL,*xy=NULL,*a=NULL,*vec_p=NULL,*val_p=NULL;
   int nombre,taille,msg;
   int *valid=NULL,kv;
   double *valeur=NULL;
   double x1,y1,x2,y2,dx,dy;
   double i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta,mean,sigma;
   /*
   FILE *f;
   */
   nbc=nbcorresp;
   nb_coef_a=10;
   /*
   f=fopen("matrix.txt","wt");
   fclose(f);
   */

   if (nbc>=3) {
      nombre=(nb_coef_a+1)*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&xx,&nombre,&taille,"xx"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer xx");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=3*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&xy,&nombre,&taille,"xy"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer xy");
	 tt_free2((void**)&xx,"xx");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=3*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&a,&nombre,&taille,"a"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer a");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=(nb_coef_a+1)*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec_p,&nombre,&taille,"vec_p"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer vec_p");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=nb_coef_a+1;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&val_p,&nombre,&taille,"val_p"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer val_p");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 tt_free2((void**)&vec_p,"vec_p");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=nbc+1;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&valid,&nombre,&taille,"valid"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer valid");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 tt_free2((void**)&vec_p,"vec_p");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=nbc+1;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&valeur,&nombre,&taille,"valeur"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer valeur");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 tt_free2((void**)&vec_p,"vec_p");
   	 tt_free2((void**)&valid,"valid");
	 return(TT_ERR_PB_MALLOC);
      }

      for (j=0;j<=nbc;j++) {
         valid[j]=TT_YES;
      }
      for (kv=0;kv<=1;kv++) {

         /***************************************************/
         /* ====== x1 = A*x2 + B*y2 + C + D*x2*y2 + E*x2*x2 + F*y2*y2 + G*x2*x2*y2 + H*x2*y2*y2 + I*x2*x2*x2 + J*y2*y2*y2 (idem pour y1) ======*/
         /* --- a1 = A  et  x1j = x2                    --- */
         /* --- a2 = B  et  x2j = y2                    --- */
         /* --- a3 = C  et  x3j = 1                     --- */
	 /* --- a4 = D  et  x4j = x2*y2                 --- */
	 /* --- a5 = E  et  x5j = x2*x2                 --- */
	 /* --- a6 = F  et  x6j = y2*y2                 --- */
	 /* --- a7 = G  et  x7j = x2*x2*y2              --- */
	 /* --- a8 = H  et  x8j = x2*y2*y2              --- */
	 /* --- a9 = I  et  x9j = x2*x2*x2              --- */
	 /* --- a10= J  et  x10j= y2*y2*y2              --- */
         /***************************************************/
         /* === calcule les elements de matrice XX ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
   	    for (col=1;col<=nb_coef_a;col++) {
	       xx[lig+nb_coef_a*col]=0;
	       if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2); } }
	       if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2); } }
	       if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2              ); } }
	       if ((lig==1)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2);}}
	       if ((lig==1)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==1)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==1)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==1)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==1)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==1)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].x2); } }
	       if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2); } }
	       if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2              ); } }
   	       if ((lig==2)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].x2); } }
	       if ((lig==2)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==2)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==2)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==2)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==2)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==2)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

   	       if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].x2); } }
	       if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].y2); } }
	       if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(            1.000          ); } }
	       if ((lig==3)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2); } }
	       if ((lig==3)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2); } }
	       if ((lig==3)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2); } }
	       if ((lig==3)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==3)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==3)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==3)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==4)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==4)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==4)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2); } }
	       if ((lig==4)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==4)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==4)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==4)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==4)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==4)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==4)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==5)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
   	       if ((lig==5)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==5)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2); } }
               if ((lig==5)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==5)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==5)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==5)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==5)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==5)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==5)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==6)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==6)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==6)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2); } }
	       if ((lig==6)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==6)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==6)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==6)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==6)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==6)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==6)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==7)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].x2); } }
	       if ((lig==7)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==7)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==7)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==7)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==7)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==7)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==7)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==7)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==7)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==8)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].x2); } }
	       if ((lig==8)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==8)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==8)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==8)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==8)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==8)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==8)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==8)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==8)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==9)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==9)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==9)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==9)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==9)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==9)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==9)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==9)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==9)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==9)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	       if ((lig==10)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].x2); } }
	       if ((lig==10)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==10)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==10)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==10)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==10)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==10)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	       if ((lig==10)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	       if ((lig==10)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	       if ((lig==10)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
            }
         }
         focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
         /* === inverse les valeurs propres de la matrice XX ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
	    if (*(val_p+lig)!=0) { *(val_p+lig)=1/ *(val_p+lig); } else {
	       msg=TT_ERR_NULL_EIGENVALUE;
	       tt_errlog("",msg,"irregular first transformation in focas_register ");
	       tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	       tt_free2((void**)&a,"a");
	       tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
   	       tt_free2((void**)&valid,"valid");tt_free2((void**)&valeur,"valeur");
	       return(msg);
            }
         }
         /* === calcul de la matrice XX-1 ===*/
         focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
         /* === calcule les elements de matrice XY pour x1 ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
	    xy[lig+1]=0;
	    if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2); } }
	    if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].y2); } }
	    if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1              ); } }
	    if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2*corresp[j].y2); } }
	    if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2*corresp[j].x2); } }
	    if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].y2*corresp[j].y2); } }
	    if (lig==7) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	    if (lig==8) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	    if (lig==9) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	    if (lig==10){ for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
         }
         /* === calcule les coefficients de transformation pour x1 ===*/
         focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
         for (col=1;col<=nb_coef_a;col++) {
	    transf_2vers1[1*nb_coef_a+col]=a[1*1+col];
         }
         /* === calcule les elements de matrice XY pour y1 ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
   	    xy[lig+1]=0;
	    if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2); } }
	    if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].y2); } }
	    if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1              ); } }
	    if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2*corresp[j].y2); } }
	    if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2*corresp[j].x2); } }
	    if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].y2*corresp[j].y2); } }
	    if (lig==7) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	    if (lig==8) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	    if (lig==9) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	    if (lig==10){ for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
         }
         /* === calcule les coefficients de transformation pour y1 ===*/
         focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
         for (col=1;col<=nb_coef_a;col++) {
	    transf_2vers1[2*nb_coef_a+col]=a[1*1+col];
         }

         /* === verif des validites ===*/
         /* on elimine les distances > a 2 sigma */
         sx_i=0;
         for (j=1;j<=nbc;j++) {
            x2=corresp[j].x2;
            y2=corresp[j].y2;
            x1=transf_2vers1[1*nb_coef_a+1]*x2+transf_2vers1[1*nb_coef_a+2]*y2+transf_2vers1[1*nb_coef_a+3]+x2*y2*transf_2vers1[1*nb_coef_a+4]+x2*x2*transf_2vers1[1*nb_coef_a+5]+y2*y2*transf_2vers1[1*nb_coef_a+6]+x2*x2*y2*transf_2vers1[1*nb_coef_a+7]+x2*y2*y2*transf_2vers1[1*nb_coef_a+8]+x2*x2*x2*transf_2vers1[1*nb_coef_a+9]+y2*y2*y2*transf_2vers1[1*nb_coef_a+10];
            y1=transf_2vers1[2*nb_coef_a+1]*x2+transf_2vers1[2*nb_coef_a+2]*y2+transf_2vers1[2*nb_coef_a+3]+x2*y2*transf_2vers1[2*nb_coef_a+4]+x2*x2*transf_2vers1[2*nb_coef_a+5]+y2*y2*transf_2vers1[2*nb_coef_a+6]+x2*x2*y2*transf_2vers1[2*nb_coef_a+7]+x2*y2*y2*transf_2vers1[2*nb_coef_a+8]+x2*x2*x2*transf_2vers1[2*nb_coef_a+9]+y2*y2*y2*transf_2vers1[2*nb_coef_a+10];
            dx=corresp[j].x1-x1;
            dy=corresp[j].y1-y1;
            valeur[j]=sqrt(dx*dx+dy*dy);
    	    /* --- algo de la valeur moy et ecart type de Miller ---*/
  	    if (j==1) {mu_i=valeur[j];}
	    i=(double) (j+1);
	    delta=valeur[j]-mu_i;
	    mu_ii=mu_i+delta/(i);
	    sx_ii=sx_i+delta*(valeur[j]-mu_ii);
	    mu_i=mu_ii;
	    sx_i=sx_ii;
         }
         mean=mu_ii;
         sigma=0.;
         if (i!=0.) {
            sigma=sqrt(sx_ii/i);
         }
         for (j=1;j<=nbc;j++) {
            if (fabs(valeur[j]-mean)>2.*sigma) {
               valid[j]=TT_NO;
            }
         }
         /*
         f=fopen("matrix.txt","at");
         fprintf(f,"%f %f %f\n",transf_2vers1[1*nb_coef_a+1],transf_2vers1[1*nb_coef_a+2],transf_2vers1[1*nb_coef_a+3]);
         fprintf(f,"%f %f %f\n",transf_2vers1[2*nb_coef_a+1],transf_2vers1[2*nb_coef_a+2],transf_2vers1[2*nb_coef_a+3]);
         fprintf(f,"\n");
         fclose(f);
         */
      }

      /***************************************************/
      /* ====== x2 = A*x1 + B*y1 + C + D*x1*y1 + E*x1*x1 + F*y1*y1 + G*x1*x1*y1 + H*x1*y1*y1 + I*x1*x1*x1 + J*y1*y1*y1 (idem pour y2) ======*/
      /* --- a1 = A  et  x1j = x1                    --- */
      /* --- a2 = B  et  x2j = y1                    --- */
      /* --- a3 = C  et  x3j = 1                     --- */
      /* --- a4 = D  et  x4j = x1*y1                 --- */
      /* --- a5 = E  et  x5j = x1*x1                 --- */
      /* --- a6 = F  et  x6j = y1*y1                 --- */
      /* --- a7 = G  et  x7j = x1*x1*y1              --- */
      /* --- a8 = H  et  x8j = x1*y1*y1              --- */
      /* --- a9 = I  et  x9j = x1*x1*x1              --- */
      /* --- a10= J  et  x10j= y1*y1*y1              --- */
      /***************************************************/
      /* === calcule les elements de matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
         for (col=1;col<=nb_coef_a;col++) {
	    xx[lig+nb_coef_a*col]=0;
	       if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1); } }
	       if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1); } }
	       if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1              ); } }
	       if ((lig==1)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1);}}
	       if ((lig==1)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==1)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==1)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==1)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==1)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==1)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].x1); } }
	       if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1); } }
	       if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1              ); } }
   	       if ((lig==2)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].x1); } }
	       if ((lig==2)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==2)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==2)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==2)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==2)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==2)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

   	       if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].x1); } }
	       if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].y1); } }
	       if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(            1.000          ); } }
	       if ((lig==3)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1); } }
	       if ((lig==3)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1); } }
	       if ((lig==3)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1); } }
	       if ((lig==3)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==3)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==3)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==3)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==4)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==4)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==4)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1); } }
	       if ((lig==4)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==4)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==4)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==4)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==4)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==4)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==4)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==5)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
   	       if ((lig==5)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==5)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1); } }
               if ((lig==5)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==5)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==5)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==5)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==5)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==5)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==5)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==6)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==6)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==6)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1); } }
	       if ((lig==6)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==6)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==6)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==6)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==6)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==6)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==6)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==7)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].x1); } }
	       if ((lig==7)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==7)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==7)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==7)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==7)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==7)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==7)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==7)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==7)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==8)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].x1); } }
	       if ((lig==8)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==8)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==8)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==8)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==8)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==8)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==8)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==8)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==8)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==9)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==9)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==9)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==9)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==9)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==9)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==9)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==9)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==9)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==9)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }

	       if ((lig==10)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].x1); } }
	       if ((lig==10)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==10)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==10)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==10)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==10)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==10)&&(col==7)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	       if ((lig==10)&&(col==8)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	       if ((lig==10)&&(col==9)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	       if ((lig==10)&&(col==10)){ for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
         }
      }
      focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
      /* === inverse les valeurs propres de la matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
         if (*(val_p+lig)!=0) { *(val_p+lig)=1/ *(val_p+lig); } else {
	    msg=TT_ERR_NULL_EIGENVALUE;
	    tt_errlog("",msg,"irregular second transformation in focas_register ");
	    tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	    tt_free2((void**)&a,"a");
	    tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
   	    tt_free2((void**)&valid,"valid");tt_free2((void**)&valeur,"valeur");
	    return(msg);
         }
      }
      /* === calcul de la matrice XX-1 ===*/
      focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
      /* === calcule les elements de matrice XY pour x2 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 xy[lig+1]=0;
	 if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1); } }
	 if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].y1); } }
	 if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2              ); } }
	 if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1*corresp[j].y1); } }
	 if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1*corresp[j].x1); } }
	 if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].y1*corresp[j].y1); } }
	 if (lig==7) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	 if (lig==8) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	 if (lig==9) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	 if (lig==10){ for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
      }
      /* === calcule les coefficients de transformation pour x2 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
         transf_1vers2[1*nb_coef_a+col]=a[1*1+col];
      }
      /* === calcule les elements de matrice XY pour y2 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 xy[lig+1]=0;
	 if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1); } }
	 if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].y1); } }
	 if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2              ); } }
	 if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1*corresp[j].y1); } }
	 if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1*corresp[j].x1); } }
	 if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].y1*corresp[j].y1); } }
	 if (lig==7) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	 if (lig==8) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	 if (lig==9) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	 if (lig==10){ for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
      }
      /* === calcule les coefficients de transformation pour y2 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
         transf_1vers2[2*nb_coef_a+col]=a[1*1+col];
      }

      tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
      tt_free2((void**)&a,"a");
      tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
      tt_free2((void**)&valid,"valid");tt_free2((void**)&valeur,"valeur");
   } else if ((nbc<=2)&&(nbc>=1)) {
      for (col=1;col<=nb_coef_a/2;col++) {
         transf_1vers2[1*nb_coef_a+1]=0.0;
         transf_1vers2[2*nb_coef_a+1]=0.0;
         transf_2vers1[1*nb_coef_a+1]=0.0;
         transf_2vers1[2*nb_coef_a+1]=0.0;
      }
      transf_1vers2[1*nb_coef_a+1]=1.0;
      transf_1vers2[1*nb_coef_a+3]=corresp[1].x2-corresp[1].x1;
      transf_1vers2[2*nb_coef_a+2]=1.0;
      transf_1vers2[2*nb_coef_a+3]=corresp[1].y2-corresp[1].y1;
      transf_2vers1[1*nb_coef_a+1]=1.0;
      transf_2vers1[1*nb_coef_a+3]=corresp[1].x1-corresp[1].x2;
      transf_2vers1[2*nb_coef_a+2]=1.0;
      transf_2vers1[2*nb_coef_a+3]=corresp[1].y1-corresp[1].y2;
   }
   return(OK);
}

int focas_best_corresp(int nb1,struct focas_tableau_entree *data_tab1,int nb2,struct focas_tableau_entree *data_tab2,double seuil_poids,struct focas_tableau_vote *vote,int *nbc,struct focas_tableau_corresp *corresp,
		       int *poids_max,int *indice_cut1,int *indice_cut2)
/**************************************************************************/
/* Le tableau *corresp etablit la correspondance entre les donnees des    */
/* deux listes (x1,y1) et (x2,y2) pour les correspondances les plus       */
/* probables (poids du vote).                                             */
/* *nbc est modifie pour ne contenir que des 'vraies' correpondances.     */
/**************************************************************************/
{
   int i,j,k;
   int indice1,indice2;
   int indicemax,indicemaxmax;
   int /*poids0_max,*/poids0;
   double poids_seuil;
   /* char texte[81];*/
   *nbc=0;
   /*--- repere l'indice de coupure ---*/
   indicemaxmax = (nb1<=nb2) ? nb1 : nb2 ;
   /*poids0_max=(indicemaxmax*indicemaxmax-3*indicemaxmax+2)/2;*/ /*max theorique*/
   poids0    =vote[nb1*nb2].poids;
   *poids_max=poids0;
   if (seuil_poids<1e-2) {seuil_poids=1e-2;}
   poids_seuil=(1.0*poids0)*seuil_poids;
   if (indicemaxmax>2) {
      k=nb1*nb2;
      indicemax=0;
      while ((vote[k].poids>poids_seuil)&&(k>1)) {k--;}
      indicemax=nb1*nb2-k;
      if (indicemax>indicemaxmax) {indicemax=indicemaxmax;}
      *indice_cut2=indicemax;
   } else {
      indicemax=indicemaxmax;
   }
   /*--- cas de indicemax<=2 ---*/
   if (indicemax<=2) {
      for (i=1,k=nb1*nb2;k>=nb1*nb2-indicemax+1;k--,i++) {
	 indice1=i;
	 corresp[i].indice1=indice1;
	 corresp[i].x1     =data_tab1[indice1].x;
	 corresp[i].y1     =data_tab1[indice1].y;
	 indice2=i;
	 corresp[i].indice2=indice2;
	 corresp[i].x2     =data_tab2[indice2].x;
	 corresp[i].y2     =data_tab2[indice2].y;
	 corresp[i].ad     =data_tab2[indice2].ad;
	 corresp[i].dec    =data_tab2[indice2].dec;
	 corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
	 corresp[i].type1  =data_tab1[indice1].type;
	 corresp[i].type2  =data_tab2[indice2].type;
      }
      *nbc=indicemax;
      return(OK);
   }
   /*--- copie 'vote' dans le tableau 'corresp' ---*/
   for (i=1,k=nb1*nb2;k>=nb1*nb2-indicemax+1;k--,i++) {
      indice1=vote[k].indice1;
      corresp[i].indice1=indice1;
      corresp[i].x1     =data_tab1[indice1].x;
      corresp[i].y1     =data_tab1[indice1].y;
      indice2=vote[k].indice2;
      corresp[i].indice2=indice2;
      corresp[i].x2     =data_tab2[indice2].x;
      corresp[i].y2     =data_tab2[indice2].y;
      corresp[i].poids=vote[k].poids;
      corresp[i].ad     =data_tab2[indice2].ad;        /* GSC = liste 2 */
      corresp[i].dec    =data_tab2[indice2].dec;
      corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
      corresp[i].type1  =data_tab1[indice1].type;
      corresp[i].type2  =data_tab2[indice2].type;
   }
   /*--- coupe la liste 'corresp' a la premiere aberation ---*/
   i=1;
   do {
      indice1=corresp[i].indice1;
      indice2=corresp[i].indice2;
      j=i+1;
      do {
	 if ((indice1==corresp[j].indice1)||(indice2==corresp[j].indice2)) {
	    indicemax=j-1;
	    j=indicemax;
	 }
      } while (j++<indicemax);
   } while (i++<(indicemax-1));
   *indice_cut1=indicemax;
   *nbc=(indicemax==1) ? 0 : indicemax ;
   return(OK);
}

int focas_best_corresp2(int nb1,struct focas_tableau_entree *data_tab1,int nb2,struct focas_tableau_entree *data_tab2,double seuil_poids,struct focas_tableau_vote *vote,int *nbc,struct focas_tableau_corresp *corresp,
		       int *poids_max,int *indice_cut1,int *indice_cut2)
/**************************************************************************/
/* NOUVELLE METHODE                                                       */
/* Le tableau *corresp etablit la correspondance entre les donnees des    */
/* deux listes (x1,y1) et (x2,y2) pour les correspondances les plus       */
/* probables (poids du vote).                                             */
/* *nbc est modifie pour ne contenir que des 'vraies' correpondances.     */
/**************************************************************************/
{
   int i,j,k,knext=0;
   int indice1,indice2,nbc6=0;
   int *best6=NULL;
   int *ibest6=NULL;
   int nombre,taille,msg;
   int nb_coef_a=3,compteur;
   double transf12[20],transf21[20];
   double dist1[37],dist2[37],disterr[37],disterr0[37];
   double xi,xj,yi,yj,dx,dy,x,y,x1,y1,x2,y2;
   double err,errtot,errsigma,seuil,d2;
   int ntot,sortie,maxi,imaxi;

   *nbc=0;
   /* --- initialise le tableau de selection des 6 etoiles qui vont */
   /* --- permettre le calcul des coef de transformation */
   nombre=nb1*nb2+1;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&best6,&nombre,&taille,"best6"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_best_corresp2 for pointer best6");
      return(TT_ERR_PB_MALLOC);
   }
   for (i=0,k=nb1*nb2;k>=1;k--) {
      if ((nb1*nb2-k)<6) {
         i++;
         best6[k]=1;
         knext=k-1;
      } else {
         best6[k]=0;
      }
   }
   nombre=i+1;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ibest6,&nombre,&taille,"ibest6"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_best_corresp2 for pointer ibest6");
      tt_free2((void**)&best6,"best6");
      return(TT_ERR_PB_MALLOC);
   }

   sortie=TT_NO;
   compteur=0;
   while (sortie==TT_NO) {
      /*--- copie 'vote' dans le tableau 'corresp' pour les 6 etoiles ---*/
      for (i=0,k=nb1*nb2;k>=1;k--) {
         if (best6[k]==1) {
            i++;
            ibest6[i]=k;
            indice1=vote[k].indice1;
            corresp[i].indice1=indice1;
            corresp[i].x1     =data_tab1[indice1].x;
            corresp[i].y1     =data_tab1[indice1].y;
            indice2=vote[k].indice2;
            corresp[i].indice2=indice2;
            corresp[i].x2     =data_tab2[indice2].x;
            corresp[i].y2     =data_tab2[indice2].y;
            corresp[i].poids=vote[k].poids;
            corresp[i].ad     =data_tab2[indice2].ad;        /* GSC = liste 2 */
            corresp[i].dec    =data_tab2[indice2].dec;
            corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
            /* --- ici on detourne le sens des .type pour les utiliser */
            /* --- au calcul des erreurs d'appariement ---*/
            corresp[i].type1  =0;
            corresp[i].type2  =0;
         }
         nbc6=i;
      }
      if (nbc6>=3) {
         if (focas_register(corresp,nbc6,transf12,transf21)!=OK) {
            msg=TT_ERR_MATCHING_REGISTER;
            tt_errlog("",msg,"Pb in focas_best_corresp2 when compute focas_register");
            tt_free2((void**)&best6,"best6");
            tt_free2((void**)&ibest6,"ibest6");
            return(msg);
        }
      } else {
         /* sortie avec trop peu d'etoile a faire ...*/
      }
      /* --- calcul des distances entre etoiles de la liste 1 ---*/
      for (i=0;i<37;i++) { dist1[i]=0.; dist2[i]=0.; disterr[i]=0.; }
      for (i=1;i<=nbc6-1;i++) {
         xi=corresp[i].x1;
         yi=corresp[i].y1;
         for (j=i+1;j<=nbc6;j++) {
            xj=corresp[j].x1;
            yj=corresp[j].y1;
            dx=(xi-xj);
            dy=(yi-yj);
            dist1[(i-1)*nbc6+j-1]=dx*dx+dy*dy;
         }
      }

      /* --- calcul des distances entre etoiles de la liste 2 ---*/
      /* --- corrigee de la transformation ---*/
      for (i=1;i<=nbc6-1;i++) {
         x=corresp[i].x2;
         y=corresp[i].y2;
         xi=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
         yi=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
         for (j=i+1;j<=nbc6;j++) {
            x=corresp[j].x2;
            y=corresp[j].y2;
            xj=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
            yj=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
            dx=(xi-xj);
            dy=(yi-yj);
            dist2[(i-1)*nbc6+j-1]=dx*dx+dy*dy;
         }
      }
      /* --- calcul de l'erreur de distance entre les deux listes ---*/
      errtot=0;
      ntot=0;
      for (i=0;i<37;i++) {
         err=sqrt(dist2[i])-sqrt(dist1[i]);
         disterr[i]=fabs(err);
         disterr0[i]=fabs(err);
         errtot+=(err*err);
         if ((dist2[i]!=0.)||(dist1[i]!=0.)) {
            ntot++;
         }
      }
      errsigma=(ntot==0)?0.:sqrt(errtot/ntot);

      /* --- condition de sortie ---*/
      if (errsigma<2.) {
         sortie=TT_YES;
         break;
      }
      if (++compteur>5) {
         sortie=TT_YES;
         break;
      }
      /* --- recherche la valeur seuil a 60 pourcent ---*/
      tt_util_qsort_double(disterr,0,37,NULL);
      for (i=0;i<37;i++) {
        if (disterr[i]!=0) { break; }
      }
      j=37-i; /* j valeurs non nulles */
      i=i+(int)(0.6*j);
	  if (i>36) {i=36;}
      seuil=disterr[i];
      /* --- recherche les mauvais appariements ---*/
      /* --- a partir des erreurs sur les distances ---*/
      for (i=1;i<=nbc6-1;i++) {
         for (j=i+1;j<=nbc6;j++) {
            if (disterr0[(i-1)*nbc6+j-1]>=seuil) {
            corresp[i].type1  +=1;
            corresp[j].type1  +=1;
            corresp[i].type2  +=1;
            corresp[j].type2  +=1;
            }
         }
      }
      /* --- on elimine le couple qui a le plus d'erreurs ---*/
      /* --- il suffit de le faire sur la liste 1 seulement ---*/
      maxi=0;
      imaxi=0;
      for (i=1;i<=nbc6;i++) {
         if (corresp[i].type1>maxi) {
            maxi=corresp[i].type1;
            imaxi=ibest6[i];
         }
      }
      /* --- on remplace le couple a eliminer par le suivant en ---*/
      /* --- ordre de vote decroissant ---*/
      best6[imaxi]=0;
      if (knext>=1) {
         best6[knext]=1;
      } else {
         sortie=TT_YES;
      }
      knext--;

   } /* --- fin de la grande boucle while ---*/

   /* --- dresse la liste des correspondances totales ---*/
   for (i=0,k=nb1*nb2;k>=1;k--) {
      indice1=vote[k].indice1;
      indice2=vote[k].indice2;
      x1     =data_tab1[indice1].x;
      y1     =data_tab1[indice1].y;
      x      =data_tab2[indice2].x;
      y      =data_tab2[indice2].y;
      x2=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
      y2=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
      dx=(x1-x2);
      dy=(y1-y2);
      d2=dx*dx+dy*dy;
      if (d2<4) {
         i++;
	 if ((i>nb1)||(i>nb2)) {
	    i--;
	    break;
	 }
         corresp[i].indice1=indice1;
         corresp[i].x1     =data_tab1[indice1].x;
         corresp[i].y1     =data_tab1[indice1].y;
         corresp[i].indice2=indice2;
         corresp[i].x2     =data_tab2[indice2].x;
         corresp[i].y2     =data_tab2[indice2].y;
         corresp[i].poids=vote[k].poids;
         corresp[i].ad     =data_tab2[indice2].ad;        /* GSC = liste 2 */
         corresp[i].dec    =data_tab2[indice2].dec;
         corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
	 corresp[i].type1  =data_tab1[indice1].type;
	 corresp[i].type2  =data_tab2[indice2].type;
      }
   }
   if (i==0) {
      k=nb1*nb2;
      i=1;
      indice1=vote[k].indice1;
      indice2=vote[k].indice2;
      corresp[i].indice1=indice1;
      corresp[i].x1     =data_tab1[indice1].x;
      corresp[i].y1     =data_tab1[indice1].y;
      corresp[i].indice2=indice2;
      corresp[i].x2     =data_tab2[indice2].x;
      corresp[i].y2     =data_tab2[indice2].y;
      corresp[i].poids=vote[k].poids;
      corresp[i].ad     =data_tab2[indice2].ad;        /* GSC = liste 2 */
      corresp[i].dec    =data_tab2[indice2].dec;
      corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
      corresp[i].type1  =data_tab1[indice1].type;
      corresp[i].type2  =data_tab2[indice2].type;
   }
   tt_free2((void**)&best6,"best6");
   tt_free2((void**)&ibest6,"ibest6");
   *nbc=i;
   return(OK);
}

int focas_calcul_triang(int nbb, int *nbbb, struct focas_tableau_dist *dist, struct focas_tableau_triang *triang)
/**************************************************************************/
/* Calcule les parametres xt et yt pour chaque triangle a<b<c             */
/* nbb : nb de distances entre etoiles                                    */
/* nbbb: nb de triangles tels que a<b<c.                                  */
/**************************************************************************/
/*                          pp1                                           */
/*                         /   \                                          */
/*                    a  /       \  c                                     */
/*                     /     b     \                                      */
/*                   pp2 ---------- pp3                                   */
/**************************************************************************/
{
   int i,j,k,p1,p2,p11,p22,pp1=0,pp2=0,pp3,ii,jj,ppp1,ppp3;
   double a,b,c;
   int kk=0,nb;
   int n,s,l,r;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;
   int nombre,taille,msg;

   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_calcul_triang for pointer qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_calcul_triang for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   /*
   f=fopen("distances.txt","wt");
   for (i=nbb;i>=3;i--) {
      fprintf(f,"%d %f\n",dist[i].indice1,dist[i].indice2,dist[i].dist2);
   }
   fclose(f);
   */
   nb=(int)((1+sqrt(1+8*nbb))/2);
   for (i=nbb;i>=3;i--) {
      a=dist[i].dist2;
      p1=dist[i].indice1;
      p2=dist[i].indice2;
      for (j=i-1;j>=2;j--) {
	 b=dist[j].dist2;
	 p11=dist[j].indice1;
	 p22=dist[j].indice2;
	 pp3=0;
	 if (p11==p1) {pp1=p2; pp2=p1; pp3=p22;}
	 else if (p11==p2) {pp1=p1; pp2=p2; pp3=p22;}
	 else if (p22==p1) {pp1=p2; pp2=p1; pp3=p11;}
	 else if (p22==p2) {pp1=p1; pp2=p2; pp3=p11;}
	 if (pp3>0) {
	    if (pp1<pp3) {ppp1=pp1; ppp3=pp3;} else {ppp1=pp3; ppp3=pp1;}
	    k=j-1;
	    do {
	       ii=dist[k].indice1;
	       jj=dist[k].indice2;
	       if ((ii==ppp1)&&(jj==ppp3)) {
		  c=dist[k].dist2;
		  b=sqrt(b/a);
		  if ((b<0.9)||(nb==3)) {
		     kk++;
		     triang[kk].x=b;
		     triang[kk].y=sqrt(c/a);
		     triang[kk].indice1=pp1;
		     triang[kk].indice2=pp2;
		     triang[kk].indice3=pp3;
		  }
		  k=0;
	       } else {
		  k--;
	       }
	    } while (k!=0) ;
	 }
      }
   }
   *nbbb=kk;
   /*--- trie le tableau dans l'ordre croissant des x ---*/
   n=kk;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=triang[(int) (floor((l+r)/2))].x;
	 do {
	    while (triang[i].x<v) {i++;}
	    while (v<triang[j].x) {j--;}
	    if (i<=j) {
	       w=triang[i].x;       triang[i].x=triang[j].x;             triang[j].x=w;
	       w=triang[i].y;       triang[i].y=triang[j].y;             triang[j].y=w;
	       k=triang[i].indice1; triang[i].indice1=triang[j].indice1; triang[j].indice1=k;
	       k=triang[i].indice2; triang[i].indice2=triang[j].indice2; triang[j].indice2=k;
	       k=triang[i].indice3; triang[i].indice3=triang[j].indice3; triang[j].indice3=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   tt_free2((void**)&qsort_r,"qsort_r");
   tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_transmoy(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1)
/*************************************************************************/
/* FOCAS_TRANSMOY                                                        */
/*                                                                       */
/* Calcule la moyenne des translations entre les correspondances.        */
/* On elimine les translations en dehors de 1.5 fois l'ecart type.       */
/*************************************************************************/
{
   double stx,sty,etx,ety,seuil;
   int nb_coef_a,k,nbc;
   double *tx=NULL,*ty=NULL;
   int msg,taille,nombre;

   nb_coef_a=3;
   nombre=nbcorresp+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tx,&nombre,&taille,"tx"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_transmoy for pointer tx");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ty,&nombre,&taille,"ty"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_transmoy for pointer ty");
      tt_free2((void**)&tx,"tx");
      return(TT_ERR_PB_MALLOC);
   }
   stx=0;
   sty=0;
   for (k=1;k<=nbcorresp;k++) {
      tx[k]=corresp[k].x2-corresp[k].x1;
      ty[k]=corresp[k].y2-corresp[k].y1;
      stx+=tx[k];
      sty+=ty[k];
   }
   tx[0]=stx/nbcorresp;
   ty[0]=sty/nbcorresp;
   etx=0;
   ety=0;
   for (k=1;k<=nbcorresp;k++) {
      etx+=((tx[0]-tx[k])*(tx[0]-tx[k]));
      ety+=((ty[0]-ty[k])*(ty[0]-ty[k]));
   }
   etx=sqrt(etx/nbcorresp);
   ety=sqrt(ety/nbcorresp);
   stx=0;
   sty=0;
   seuil=1.5;
   for (nbc=0,k=1;k<=nbcorresp;k++) {
      if ((tx[k]>(tx[0]-seuil*etx))&&(tx[k]<(tx[0]+seuil*etx))&&(ty[k]>(ty[0]-seuil*ety))&&(ty[k]<(ty[0]+seuil*ety))) {
	 stx+=tx[k];
	 sty+=ty[k];
	 nbc++;
      }
   }
   if (nbc>=1) {
      tx[0]=stx/nbc;
      ty[0]=sty/nbc;
   }
   /* sprintf(texte,"dx=%f dy=%f",tx[0],ty[0]);*/
   transf_1vers2[1*nb_coef_a+1]=1.0;
   transf_1vers2[1*nb_coef_a+2]=0.0;
   transf_1vers2[1*nb_coef_a+3]=tx[0];
   transf_1vers2[2*nb_coef_a+1]=0.0;
   transf_1vers2[2*nb_coef_a+2]=1.0;
   transf_1vers2[2*nb_coef_a+3]=ty[0];
   transf_2vers1[1*nb_coef_a+1]=1.0;
   transf_2vers1[1*nb_coef_a+2]=0.0;
   transf_2vers1[1*nb_coef_a+3]=-tx[0];
   transf_2vers1[2*nb_coef_a+1]=0.0;
   transf_2vers1[2*nb_coef_a+2]=1.0;
   transf_2vers1[2*nb_coef_a+3]=-ty[0];
   tt_free2((void**)&tx,"tx");
   tt_free2((void**)&ty,"ty");
   return(OK);
}

int focas_compte_lignes (char *nom_fichier_in,int *nombre)
/**************************************************************************/
/* Retourne le nombre de lignes dans un fichier ASCII                     */
/**************************************************************************/
{
   FILE *fichier_in ;
   int iligne,msg;
   char texte[255],ligne[255];
   char message_err[TT_MAXLIGNE];

   /* ouvre le fichier d'entree */
   if (( fichier_in=fopen(nom_fichier_in, "r") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in focas_compte_lignes",nom_fichier_in);
      tt_errlog("",msg,message_err);
      return(msg);
   }
   iligne=0;
   do {
      if (fgets(ligne,255,fichier_in)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    iligne++;
	 }
      }
   } while ( feof(fichier_in)==0 );
   fclose(fichier_in );
   *nombre=iligne;
   return(OK);
}

int focas_stringcmp(char *chaine1,char *chaine2)
/*************************************************************************/
/* utilitaire pour assurer la compatibilite DOS/UNIX                     */
/*************************************************************************/
{
   /*
   if (strcmp(chaine1,chaine2)==NULL) { return(0); } else { return(1); }
   */
   if (strcmp(chaine1,chaine2)==0)    { return(0); } else { return(1); }
}

int focas_fileeof(FILE *fichier_in)
/*************************************************************************/
/* utilitaire pour assurer la compatibilite DOS/UNIX                     */
/*************************************************************************/
{
   if (feof(fichier_in)==0)       { return(0); } else { return(1); }
}

int focas_get_tab(char *nom_fichier_in,int type_fichier,int *nombre,struct focas_tableau_entree *data_tab,int flag_sature1)
/**************************************************************************/
/* Ordre de lecture des colonnes du fichier :                             */
/* type_fichier=0 :                                                       */
/*   type KAOPHOT 1                                                       */
/*   indice X Y fwhmx fwhmy I mag fond qualite                            */
/* type_fichier=1 :                                                       */
/*   type FOCAS NOM_LISTE_COM etoile 1                                    */
/*   X1 Y1 mag1 X2 Y2 mag2                                                */
/* type_fichier=2 :                                                       */
/*   type FOCAS NOM_LISTE_COM etoile 2                                    */
/*   X1 Y1 mag1 X2 Y2 mag2                                                */
/* type_fichier=3 :                                                       */
/*   type KAOPHOT 2                                                       */
/*   indice X Y I AD DEC mag qualite precision                            */
/*                                                                        */
/* - trie les etoiles selon la brillance decroissante                     */
/* - relegue les etoiles en fin de liste si  sature=1 (type_fichier=0)    */
/**************************************************************************/
{
   FILE *fichier_in ;
   int iligne,flag_comptelig,sature;
   char texte[255],ligne[255];
   double rien;
   int n,ii,msg;
   int irien;
   double mini,maxi;
   char message_err[TT_MAXLIGNE];

   mini=-1e20;
   maxi= 1e20;
   /* ouvre le fichier d'entree*/
   if (( fichier_in=fopen(nom_fichier_in, "r") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in focas_get_tab",nom_fichier_in);
      tt_errlog("",msg,message_err);
      return(msg);
   }
   if (*nombre==0) {flag_comptelig=0;} else {flag_comptelig=1;}
   if (type_fichier==0) {sature=1;} else {sature=0;}
   iligne=0;
   do {
      if (fgets(ligne,255,fichier_in)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    iligne++;
	    if (flag_comptelig>0) {
	       if (type_fichier==0) {
		  /* type KAOPHOT 1*/
		  /* indice X Y fwhmx fwhmy I mag fond qualite*/
		  sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %lf %lf",
		   &rien,&data_tab[iligne].x,&data_tab[iligne].y,
		   &rien,&rien,&rien,&data_tab[iligne].mag,&rien,
		   &data_tab[iligne].qualite);
		   if (data_tab[iligne].qualite==3) {
		      data_tab[iligne].type=-1;
		   } else {
		      data_tab[iligne].type=1;
		   }
	       }
	       if (type_fichier==1) {
		  /* type FOCAS NOM_LISTE_COM etoile 1*/
		  /* X1 Y1 mag1 X2 Y2 mag2              */
#ifdef OS_LINUX_GCC_SO
		  sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %d %d",
#else
		  sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %ld %ld",
#endif
		   &data_tab[iligne].x,&data_tab[iligne].y,
		   &data_tab[iligne].mag,&rien,&rien,&rien,
		   &rien,&data_tab[iligne].type,&irien);
		   data_tab[iligne].qualite=data_tab[iligne].type;
	       }
	       if (type_fichier==2) {
		  /* type FOCAS NOM_LISTE_COM etoile 2*/
		  /* X1 Y1 mag1 X2 Y2 mag2*/
#ifdef OS_LINUX_GCC_SO
		  sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %d %d",
#else
		  sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %ld %ld",
#endif
		   &rien,&rien,&rien,&data_tab[iligne].x,
		   &data_tab[iligne].y,&data_tab[iligne].mag,
		   &rien,&irien,&data_tab[iligne].type);
		   data_tab[iligne].qualite=data_tab[iligne].type;
	       }
	       if (type_fichier==3) {
		  /* type KAOPHOT 2*/
		  /*   indice X Y mag_relative AD DEC mag qualite fwhm sharp*/
#ifdef OS_LINUX_GCC_SO
		  sscanf(ligne,"%d %lf %lf %lf %lf %lf %lf %d %lf %lf",
#else
		  sscanf(ligne,"%ld %lf %lf %lf %lf %lf %lf %ld %lf %lf",
#endif
		   &irien,&data_tab[iligne].x,&data_tab[iligne].y,
		   &data_tab[iligne].mag,
		   &data_tab[iligne].ad,&data_tab[iligne].dec,
		   &data_tab[iligne].mag_gsc,&data_tab[iligne].type,&rien,&rien);
		  data_tab[iligne].qualite=1;
	       }
	    }
	 }
      }
   }
   /* while ( (feof(fichier_in)==0) || ((iligne<*nombre)&&(flag_comptelig>0)) ) ;*/
   while ( (feof(fichier_in)==0)) ;
   fclose(fichier_in );
   *nombre=iligne;
   /* --- trie les valeurs dans l'ordre croissant des mag */
   /* --- et stocke la plus brillante en indice 0 (pour cas nbc==0) */
   n=*nombre;
   if (focas_tri_tabm(data_tab,n)!=OK) { return(PB); }
   data_tab[0].mag=data_tab[1].mag;
   data_tab[0].x=data_tab[1].x;
   data_tab[0].y=data_tab[1].y;
   data_tab[0].qualite=data_tab[1].qualite;
   if ((sature==1)&&(flag_sature1==0)) {
      /* --- elimine les etoiles de mauvaise qualite */
      if (*nombre>=FOCAS_NOBJMAX) {
	 for (ii=1;ii<=*nombre;ii++) {
	    if (data_tab[ii].qualite<2) { if (data_tab[ii].mag>mini) {mini=data_tab[ii].mag;} }
	    else                        { if (data_tab[ii].mag<maxi) {maxi=data_tab[ii].mag;} }
	 }
	 for (ii=1;ii<=*nombre;ii++) {
	    if (data_tab[ii].qualite>1) { data_tab[ii].mag-=(maxi-mini-1.); }
	 }
      }
      /* --- trie les valeurs dans l'ordre croissant des mag */
      n=*nombre;
      if (focas_tri_tabm(data_tab,n)!=OK) { return(PB); }
      if (*nombre>=FOCAS_NOBJMAX) {
	 for (ii=1;ii<=*nombre;ii++) {
	    if (data_tab[ii].qualite>1) { data_tab[ii].mag+=(maxi-mini-1.); }
	 }
      }
   }
   return(OK);
}

int focas_calcul_dist(int nb, struct focas_tableau_entree *data_tab, struct focas_tableau_dist *dist)
/**************************************************************************/
/* Calcule la distance au carre entre deux etoiles :                      */
/* Effectue le calcul pour tous les couples d'etoiles.                    */
/* Place le resultat dans le tableau *dist                                */
/**************************************************************************/
{
   int i,j,k;
   double x0,y0,x,y;
   int n=nb*(nb-1)/2,s,l,r;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;
   int nombre,taille,msg;

   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_calcul_dist for pointer qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_calcul_dist for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   for (k=1,i=1;i<=nb-1;i++) {
      x0=(data_tab+i)->x;
      y0=(data_tab+i)->y;
      for (j=i+1;j<=nb;j++,k++) {
		x=x0-(data_tab+j)->x;
		y=y0-(data_tab+j)->y;
         if ((x==0.)&&(y==0.)) {
            tt_errlog("",TT_ERR_MATCHING_NULL_DISTANCES,"Pb of null distance in focas_calcul_dist (check files .lst)");
            tt_free2((void**)&qsort_r,"qsort_r");
            tt_free2((void**)&qsort_l,"qsort_l");
            return(TT_ERR_MATCHING_NULL_DISTANCES);
		}
		(dist+k)->indice1=i;
		(dist+k)->indice2=j;
		(dist+k)->dist2=(x*x+y*y);
      }
   }
   /*--- trie le tableau dans l'ordre croissant des distances ---*/
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=dist[(int) (floor((l+r)/2))].dist2;
	 do {
	    while (dist[i].dist2<v) {i++;}
	    while (v<dist[j].dist2) {j--;}
	    if (i<=j) {
	       w=dist[i].dist2;   dist[i].dist2=dist[j].dist2;     dist[j].dist2=w;
	       k=dist[i].indice1; dist[i].indice1=dist[j].indice1; dist[j].indice1=k;
	       k=dist[i].indice2; dist[i].indice2=dist[j].indice2; dist[j].indice2=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   tt_free2((void**)&qsort_r,"qsort_r");
   tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_match_triang(struct focas_tableau_triang *triang1, int nb111, struct focas_tableau_triang *triang2, int nb222, int nb1, int nb2, struct focas_tableau_vote *vote,double epsilon)
/**************************************************************************/
/* Calcule les poids de probabilite d'associer deux etoiles des deux      */
/* listes.                                                                */
/* le poids se trouve dans le tableau de 'vote'                           */
/**************************************************************************/
{
   int i1,i2,i2deb;
   double x1,x2,y1,y2,x1mini,x1maxi,y1mini,y1maxi;
   int indice11,indice21,indice31,indice12,indice22,indice32;
   int i,j,k;
   int n,s,l=0,r=0;
   int v,w;
   int nombre,taille,msg;
   double *qsort_r=NULL,*qsort_l=NULL;

   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_match_triang for pointer qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_match_triang for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   i2deb=1;
   for (i1=1;i1<=nb111;i1++) {
      x1=triang1[i1].x;
      y1=triang1[i1].y;
      x1mini=x1-epsilon;
      x1maxi=x1+epsilon;
      y1mini=y1-epsilon;
      y1maxi=y1+epsilon;
      i2=i2deb;
      do {
	 x2=triang2[i2].x;
	 if (x2<x1mini) { i2deb=i2; }
	 else if (x2>x1maxi) { i2=nb222+1; }
	 else {
	    y2=triang2[i2].y;
	    if ((y2>y1mini)&&(y2<y1maxi)) {
	       indice11=triang1[i1].indice1; indice12=triang2[i2].indice1;
	       vote[(indice11-1)*nb2+indice12].poids++;
	       indice21=triang1[i1].indice2; indice22=triang2[i2].indice2;
	       vote[(indice21-1)*nb2+indice22].poids++;
	       indice31=triang1[i1].indice3; indice32=triang2[i2].indice3;
	       vote[(indice31-1)*nb2+indice32].poids++;
	    }
	 }
	 i2++;
      } while (i2<=nb222) ;
   }
   for (i1=1;i1<=nb1;i1++) {
      for (i2=1;i2<=nb2;i2++) {
	 vote[(i1-1)*nb2+i2].indice1=i1;
	 vote[(i1-1)*nb2+i2].indice2=i2;
      }
   }
   /*--- trie le tableau de vote dans l'ordre croissant des poids ---*/
   n=nb1*nb2;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=vote[(int) (floor((l+r)/2))].poids;
	 do {
	    while (vote[i].poids<v) {i++;}
	    while (v<vote[j].poids) {j--;}
	    if (i<=j) {
	       w=vote[i].poids;   vote[i].poids  =vote[j].poids;   vote[j].poids=w;
	       k=vote[i].indice1; vote[i].indice1=vote[j].indice1; vote[j].indice1=k;
	       k=vote[i].indice2; vote[i].indice2=vote[j].indice2; vote[j].indice2=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   tt_free2((void**)&qsort_r,"qsort_r");
   tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_mat_vdtv(double *a,double *d,double *v,int n)
/***************************************************************************/
/*                                                                         */
/*  BUT ET ALGORITHME : A.Klotz 11/4/94                                    */
/*   calcul la matrice A = V * D * tV a partir des vecteurs propres V et   */
/*   des valeurs prores D                                                  */
/*                                                                         */
/*  ENTREES                                                                */
/*   La dimension n de la matrice                                          */
/*   Le vecteur contenant les valeurs propres non triees defini par :      */
/*    d = (double *) tt_calloc((n+1),sizeof(double));                           */
/*   La matrice V a pour dimension n*n et contient les vecteurs propres    */
/*    dans ses colonnes                                                    */
/*   La matrice V est definie par le pointeur *matrice definit par :       */
/*    v = (double *)tt_calloc((n+1)*(n+1),sizeof(double));                      */
/*                                                                         */
/*  SORTIES                                                                */
/*   La matrice A a pour dimension n*n                                     */
/*   La matrice A est definie par le pointeur *matrice definit par :       */
/*    a=(double *)tt_calloc((n+1)*(n+1),sizeof(double));                        */
/*                                                                         */
/***************************************************************************/
{
   double *aa=NULL;
   int ligne,colonne,k;
   int nombre,taille,msg;

   nombre=(n+1)*(n+1);
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&aa,&nombre,&taille,"aa"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_mat_vdtv for pointer aa");
      return(TT_ERR_PB_MALLOC);
   }
   for (ligne=1;ligne<=n;ligne++) {
      for (colonne=1;colonne<=n;colonne++) {
	 *(aa+n*ligne+colonne)=*(v+n*ligne+colonne)*(*(d+colonne)) ;
      }
   }
   for (ligne=1;ligne<=n;ligne++) {
      for (colonne=1;colonne<=n;colonne++) {
	 *(a+n*ligne+colonne)=0;
	 for (k=1;k<=n;k++) {
	    *(a+n*ligne+colonne)+=*(aa+n*ligne+k)*(*(v+n*colonne+k));
	 }
      }
   }
   tt_free2((void**)&aa,"aa");
   return(OK);
}

int focas_mat_givens(double *a,double *d,double *v,int n)
/***************************************************************************/
/*                                                                         */
/*  BUT ET ALGORITHME : A.Klotz 31/3/94                                    */
/*   calcul des valeurs propres et les vecteurs propres d'une matrice par  */
/*   l'algo de Givens                                                      */
/*   Dans un premier temps on transforme la matrice de depart en une       */
/*   matrice trigonale                                                     */
/*   Dans un deuxieme temps on reduit cette matrice trigonale              */
/*   source : Numerical Recipes (ISBN 0 521 30811 9) Cambridge Press 1986  */
/*            W.H.Press, B.P.Flannery, S.A.Teukolsky, W.T.Vetterling       */
/*                                                                         */
/*  ENTREES                                                                */
/*   La matrice A a pour dimension n*n                                     */
/*   La matrice A est definie par le pointeur *matrice definit par :       */
/*    a=(double *)tt_calloc((n+1)*(n+1),sizeof(double));                        */
/*   La dimension n de la matrice a diagonaliser                           */
/*                                                                         */
/*  SORTIES                                                                */
/*   Le vecteur contenant les valeurs propres non triees defini par :      */
/*    d = (double *) tt_calloc((n+1),sizeof(double));                           */
/*   La matrice V a pour dimension n*n et contient les vecteurs propres    */
/*    dans ses colonnes                                                    */
/*   La matrice V est definie par le pointeur *matrice definit par :       */
/*    v = (double *)tt_calloc((n+1)*(n+1),sizeof(double));                      */
/*   La matrice d'entree *a n'est pas changee                              */
/*                                                                         */
/***************************************************************************/
{
   double *e=NULL,*aa=NULL;
   int i,j,k,l,iter,m;
   double h,scale,f,g,hh,dd,r,s,c,b,p;
   int nombre,taille,msg;

   nombre=(n+1);
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&e,&nombre,&taille,"e"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_mat_givens for pointer e");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=(n+1)*(n+1);
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&aa,&nombre,&taille,"aa"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_mat_givens for pointer aa");
      tt_free2((void**)&e,"e");
      return(TT_ERR_PB_MALLOC);
   }
   /*--- initialise la matrice aa ---*/
   for (i=1;i<=n;i++) {
      for (j=1;j<=n;j++) {
	 *(aa+n*i+j)=*(a+n*i+j);
      }
   }
   if (n>1) {
      for (i=n;i>=2;i--) {
	 l=i-1;
	 h=0;
	 scale=0;
	 if (l>1) {
	    for (k=1;k<=l;k++) { scale+=fabs(*(aa+n*i+k)); }
	    if (scale==0) { *(e+i)=*(aa+n*i+l); }
	    else {
	       for (k=1;k<=l;k++) {
		  *(aa+n*i+k)/=scale;
		  h+=*(aa+n*i+k)*(*(aa+n*i+k));
	       }
	       f=*(aa+n*i+l);
	       g=((f>=0) ? -fabs(sqrt(h)) : fabs(sqrt(h))) ;
	       *(e+i)=scale*g;
	       h-=f*g;
	       *(aa+n*i+l)=f-g;
	       f=0;
	       for (j=1;j<=l;j++) {
		  *(aa+n*j+i)=*(aa+n*i+j)/h;
		  g=0.;
		  for (k=1;k<=j;k++) {
		     g+=*(aa+n*j+k)*(*(aa+n*i+k));
		  }
		  if (l>j) {
		     for (k=j+1;k<=l;k++) {
			g+=*(aa+n*k+j)*(*(aa+n*i+k));
		     }
		  }
		  *(e+j)=g/h;
		  f+=*(e+j)*(*(aa+n*i+j));
	       }
	       hh=f/(h+h);
	       for (j=1;j<=l;j++) {
		  f=*(aa+n*i+j);
		  g=*(e+j)-hh*f;
		  *(e+j)=g;
		  for (k=1;k<=j;k++) {
		     *(aa+n*j+k)-=f*(*(e+k))+g*(*(aa+n*i+k));
		  }
	       }
	    } /* endif */
	 }
	 else {
	    *(e+i)=*(aa+n*i+l);
	 }
	 *(d+i)=h;
      } /* i */
   }
   *(d+1)=0.;
   *(e+1)=0.;
   for (i=1;i<=n;i++) {
      l=i-1;
      if (*(d+i)!=0) {
	 for (j=1;j<=l;j++) {
	    g=0;
	    for (k=1;k<=l;k++) {
	       g+=*(aa+n*i+k)*(*(aa+n*k+j));
	    }
	    for (k=1;k<=l;k++) {
	       *(aa+n*k+j)-=*(aa+n*k+i)*g;
	    }
	 }
      }
      *(d+i)=*(aa+n*i+i);
      *(aa+n*i+i)=1.;
      if (l>=1) {
	 for (j=1;j<=l;j++) {
	    *(aa+n*i+j)=0.;
	    *(aa+n*j+i)=0.;
	 }
      }
   }
   if (n>1) {
      for (i=2;i<=n;i++) {
	 *(e+i-1)=*(e+i);
      }
      *(e+n)=0;
      for (l=1;l<=n;l++) {
	 iter=0;
	 n1 : for (i=0,m=l;m<=n-1;m++) {
	    dd=fabs(*(d+m))+fabs(*(d+m+1));
	    if ((fabs(*(e+m))+dd)==dd) { i=1; break; }
	 }
	 if (i==0) { m=n; }
	 if (m!=l) {
	    if (iter==30) { printf("trop d'iteration dans focas_mat_givens\n"); }
	    iter++;
	    g=(*(d+l+1)-*(d+l))/(2.*(*(e+l)));
	    r=sqrt(g*g+1.);
	    g=*(d+m)-*(d+l)+*(e+l)/(g+ ((g>=0) ? fabs(r) : -fabs(r)) );
	    s=1.;
	    c=1.;
	    p=0.;
	    for (i=m-1;i>=l;i--) {
	       f=*(e+i)*s;
	       b=*(e+i)*c;
	       if (fabs(f)>=fabs(g)) {
		  c=g/f;
		  r=sqrt(c*c+1.);
		  *(e+i+1)=f*r;
		  s=1./r;
		  c*=s;
	       }
	       else {
		  s=f/g;
		  r=sqrt(s*s+1.);
		  *(e+i+1)=g*r;
		  c=1./r;
		  s*=c;
	       }
	       g=*(d+i+1)-p;
	       r=(*(d+i)-g)*s+2.*c*b;
	       p=s*r;
	       *(d+i+1)=g+p;
	       g=c*r-b;
	       for (k=1;k<=n;k++) {
		  f=*(aa+n*k+i+1);
		  *(aa+n*k+i+1)=*(aa+n*k+i)*s+c*f;
		  *(aa+n*k+i)=*(aa+n*k+i)*c-s*f;
	       }
	    }
	    *(d+l)-=p;
	    *(e+l)=g;
	    *(e+m)=0.;
	    goto n1;
	 }
      }
   }
   for (i=1;i<=n;i++) {
      for (j=1;j<=n;j++) {
	 *(v+n*i+j)=*(aa+n*i+j);
      }
   }
   tt_free2((void**)&e,"e");
   tt_free2((void**)&aa,"aa");
   return(OK);
}

int focas_mat_mult(double *a,double *b,double *c,int n,int m,int p)
/***************************************************************************/
/*                                                                         */
/*  BUT ET ALGORITHME : A.Klotz 3/4/94                                     */
/*   calcul la matrice C= A * B a partir des matrices A(m,n) et B(n,p)     */
/*   la matrice C a pour dimension C(lignes=m,colonnes=p)                  */
/*                                                                         */
/*  ENTREES                                                                */
/*   Les dimensions n,m,p des matrices A(m,n) B(n,p) et C(m,p)             */
/*   La matrice A est definie par le pointeur *a definit par :             */
/*    a = (double *)tt_calloc((m+1)*(n+1),sizeof(double));                      */
/*   La matrice B est definie par le pointeur *b definit par :             */
/*    b = (double *)tt_calloc((n+1)*(p+1),sizeof(double));                      */
/*                                                                         */
/*  SORTIES                                                                */
/*   La matrice C est definie par le pointeur *c definit par :             */
/*    c = (double *)tt_calloc((m+1)*(p+1),sizeof(double));                      */
/*    il est possible d'avoir le nom de C comme celui de A ou B            */
/*                                                                         */
/***************************************************************************/
{
   int ligne,colonne,k;
   double *cc=NULL;
   int nombre,taille,msg;

   nombre=(m+1)*(p+1);
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cc,&nombre,&taille,"cc"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_mat_mult for pointer cc");
      return(TT_ERR_PB_MALLOC);
   }
   for (ligne=1;ligne<=m;ligne++) {
      for (colonne=1;colonne<=p;colonne++) {
	 *(cc+p*ligne+colonne)=0;
	 for (k=1;k<=n;k++) {
	    *(cc+p*ligne+colonne)+=*(a+n*ligne+k)*(*(b+p*k+colonne));
	 }
      }
   }
   for (ligne=1;ligne<=m;ligne++) {
      for (colonne=1;colonne<=p;colonne++) {
	 *(c+p*ligne+colonne)=*(cc+p*ligne+colonne);
      }
   }
   tt_free2((void**)&cc,"cc");
   return(OK);
}

int focas_tri_tabx(struct focas_tableau_entree *data_tab,int nbtot)
/**************************************************************************/
/**************************************************************************/
{
   int n,s,l,r,i,j;
   int k;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;
   int nombre,taille,msg;

   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_tabx for pointer qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_tabx for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   /*--- trie les valeurs dans l'ordre croissant des x ---*/
   n=nbtot;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=data_tab[(int) (floor((l+r)/2))].x;
	 do {
	    while (data_tab[i].x<v) {i++;}
	    while (v<data_tab[j].x) {j--;}
	    if (i<=j) {
	       w=data_tab[i].x;       data_tab[i].x=data_tab[j].x;             data_tab[j].x=w;
	       w=data_tab[i].y;       data_tab[i].y=data_tab[j].y;             data_tab[j].y=w;
	       w=data_tab[i].mag;     data_tab[i].mag=data_tab[j].mag;         data_tab[j].mag=w;
	       w=data_tab[i].qualite; data_tab[i].qualite=data_tab[j].qualite; data_tab[j].qualite=w;
	       w=data_tab[i].ad;      data_tab[i].ad=data_tab[j].ad;           data_tab[j].ad=w;
	       w=data_tab[i].dec;     data_tab[i].dec=data_tab[j].dec;         data_tab[j].dec=w;
	       w=data_tab[i].mag_gsc; data_tab[i].mag_gsc=data_tab[j].mag_gsc; data_tab[j].mag_gsc=w;
	       k=data_tab[i].type;    data_tab[i].type=data_tab[j].type;       data_tab[j].type=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   tt_free2((void**)&qsort_r,"qsort_r");
   tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_tri_taby(struct focas_tableau_entree *data_tab,int nbtot)
/**************************************************************************/
/**************************************************************************/
{
   int n,s,l,r,i,j;
   int k;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;
   int nombre,taille,msg;

   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_taby for pointer qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_taby for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   /*--- trie les valeurs dans l'ordre croissant des y ---*/
   n=nbtot;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=data_tab[(int) (floor((l+r)/2))].y;
	 do {
	    while (data_tab[i].y<v) {i++;}
	    while (v<data_tab[j].y) {j--;}
	    if (i<=j) {
	       w=data_tab[i].x;       data_tab[i].x=data_tab[j].x;             data_tab[j].x=w;
	       w=data_tab[i].y;       data_tab[i].y=data_tab[j].y;             data_tab[j].y=w;
	       w=data_tab[i].mag;     data_tab[i].mag=data_tab[j].mag;         data_tab[j].mag=w;
	       w=data_tab[i].qualite; data_tab[i].qualite=data_tab[j].qualite; data_tab[j].qualite=w;
	       w=data_tab[i].ad;      data_tab[i].ad=data_tab[j].ad;           data_tab[j].ad=w;
	       w=data_tab[i].dec;     data_tab[i].dec=data_tab[j].dec;         data_tab[j].dec=w;
	       w=data_tab[i].mag_gsc; data_tab[i].mag_gsc=data_tab[j].mag_gsc; data_tab[j].mag_gsc=w;
	       k=data_tab[i].type;    data_tab[i].type=data_tab[j].type;       data_tab[j].type=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   tt_free2((void**)&qsort_r,"qsort_r");
   tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_tri_tabm(struct focas_tableau_entree *data_tab,int nbtot)
/**************************************************************************/
/**************************************************************************/
{
   int n,s,l,r,i,j;
   int k;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;
   int nombre,taille,msg;

   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_tabm for pointer qsort_r");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_tabm for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(TT_ERR_PB_MALLOC);
   }

   /*--- trie les valeurs dans l'ordre croissant des mag ---*/
   n=nbtot;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=data_tab[(int) (floor((l+r)/2))].mag;
	 do {
	    while (data_tab[i].mag<v) {i++;}
	    while (v<data_tab[j].mag) {j--;}
	    if (i<=j) {
	       w=data_tab[i].x;       data_tab[i].x=data_tab[j].x;             data_tab[j].x=w;
	       w=data_tab[i].y;       data_tab[i].y=data_tab[j].y;             data_tab[j].y=w;
	       w=data_tab[i].mag;     data_tab[i].mag=data_tab[j].mag;         data_tab[j].mag=w;
	       w=data_tab[i].qualite; data_tab[i].qualite=data_tab[j].qualite; data_tab[j].qualite=w;
	       w=data_tab[i].ad;      data_tab[i].ad=data_tab[j].ad;           data_tab[j].ad=w;
	       w=data_tab[i].dec;     data_tab[i].dec=data_tab[j].dec;         data_tab[j].dec=w;
	       w=data_tab[i].mag_gsc; data_tab[i].mag_gsc=data_tab[j].mag_gsc; data_tab[j].mag_gsc=w;
	       k=data_tab[i].type;    data_tab[i].type=data_tab[j].type;       data_tab[j].type=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   tt_free2((void**)&qsort_r,"qsort_r");
   tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_liste2(char *nom_fichier_in,int nbtot,FILE *hand_dif,int indice,int nb_coef_a,double *transform,int xmin,int xmax,int ymin,int ymax)
/**************************************************************************/
/* ajoute les etoiles de la liste *nom_fichier_in dans la liste des       */
/* etoiles 'differentes' du fichier ouvert avec le handler hand_dif       */
/* seulement si les etoiles sont dans la zone delimitee par xmin,xmax     */
/* et ymin,ymax.                                                          */
/**************************************************************************/
{
   int k;
   double x,y,mag;
   FILE *fichier_in ;
   int iligne;
   char texte[255],ligne[255];
   double rien;
   struct focas_tableau_entree *data_tab=NULL;
   int nombre,taille,msg;
   char message_err[TT_MAXLIGNE];

   nombre=nbtot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab,&nombre,&taille,"data_tab"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste2 for pointer data_tab");
      return(TT_ERR_PB_MALLOC);
   }
   if (( fichier_in=fopen(nom_fichier_in, "r") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in focas_liste2",nom_fichier_in);
      tt_errlog("",msg,message_err);
      tt_free2((void**)&data_tab,"data_tab");
      return(msg);
   }
   if (nbtot>0) {
      /*nb=0;*/
      iligne=0;
      do {
	 if (fgets(ligne,255,fichier_in)!=NULL) {
	    strcpy(texte,"");
	    sscanf(ligne,"%s",texte);
	    if ( (strcmp(texte,"")!=0) ) {
	       iligne++;
	       /* X1 Y1 mag1 X2 Y2 mag2*/
	       sscanf(ligne,"%lf %lf %lf %lf %lf %lf",&data_tab[iligne].x,&data_tab[iligne].y,&data_tab[iligne].mag,&rien,&rien,&rien);
	    }
	 }
      } while ( (feof(fichier_in)==0) && (iligne<nbtot) ) ;
   }
   fclose(fichier_in );
   /*nb=iligne;*/
   sprintf(ligne,"======= image d'indice #%d\n",indice);
   /*
   if (LG==FR) { sprintf(ligne,"======= image d'indice #%d\n",indice); }
   else   {      sprintf(ligne,"======= index image is #%d\n",indice); }
   */
   fwrite(ligne,strlen(ligne),1,hand_dif);
   /* write(hand_dif,ligne,strlen(ligne));*/
   if (nbtot>0) {
      for (k=1;k<=nbtot;k++) {
	 x=data_tab[k].x;
	 y=data_tab[k].y;
	 mag=data_tab[k].mag;
	 if ((x>=xmin)&&(x<=xmax)&&(y>=ymin)&&(y<=ymax)) {
	    data_tab[k].x=transform[1*nb_coef_a+1]*x+transform[1*nb_coef_a+2]*y+transform[1*nb_coef_a+3];
	    data_tab[k].y=transform[2*nb_coef_a+1]*x+transform[2*nb_coef_a+2]*y+transform[2*nb_coef_a+3];
	    sprintf(ligne,"%f %f %f %f %f\n",x,y,mag,data_tab[k].x,data_tab[k].y);
	    fwrite(ligne,strlen(ligne),1,hand_dif);
	    /* write(hand_dif,ligne,strlen(ligne));*/
	 }
      }
   }
   tt_free2((void**)&data_tab,"data_tab");
   return(OK);
}

int focas_liste_commune(char *nom_fichier_com,char *nom_fichier_dif,
			struct focas_tableau_entree *data_tab10,int nb1tot,
			struct focas_tableau_entree *data_tab20,int nb2tot,
			double *transf12,double *transf21,int nb_coef_a,
                        int ordre_corresp,
			double delta,
			int *total,
			struct focas_tableau_corresp *corresp,
			struct focas_tableau_corresp *differe,
			int flag_corresp)
/*************************************************************************/
/* FOCAS_LISTE_COMMUNE                                                   */
/* But : cree une liste de correspondance entre 2 listes *data_tab       */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* 1) Compte (et eventuellement assigne dans le tableau *corresp si      */
/*    flag_corresp==1) les correspondances entre les deux tableaux       */
/*    d'entrees en connaissant les coefficients de transformation.       */
/* Si flag_corresp==1 alors on peut avoir 2 :                            */
/* 2) Compte et Assigne la liste des etoiles qui different dans la zone  */
/*    commune aux deux images (tableau *differe).                        */
/* Si flag_corresp==1 et *nom_fichier_com!="" alors on peut avoir 3 :    */
/* 3) Trie le tableau *corresp dans l'ordre des plus grands vers les     */
/*    plus petits ecarts par rapport a la moyenne des ecarts en          */
/*    magnitude. Puis, ecrit la liste dans le fichier *nom_fichier_com.  */
/* Si flag_corresp==1 et *nom_fichier_dif!="" alors on peut avoir 4 :    */
/* 4) Trie le tableau *differe dans l'ordre des plus grandes vers les    */
/*    plus petites brillances d'etoiles.                                 */
/*    Puis, ecrit la liste dans le fichier *nom_fichier_dif.             */
/*                                                                       */
/* ENTREES :                                                             */
/* *NOM_FICHIER_COM : nom de fichier qui contiendra la liste des etoiles */
/*                    communes aux deux tableaux d'entree.               */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/* *NOM_FICHIER_DIF : nom de fichier qui contiendra la liste des etoiles */
/*                    differentes aux deux tableaux d'entree.            */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x2/1 y2/1 mag2/2 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/*                     (x1,y1) coordonnees (x2,y2) dans le repere 1      */
/* *data_tab10 : tableau des entrees 1.                                  */
/* nb1tot      : nombre d'entrees dans le tableau 1.                     */
/* *data_tab20 : tableau des entrees 2.                                  */
/* nb2tot      : nombre d'entrees dans le tableau 2.                     */
/* *transf12   : coefficients de transformation 1 vers 2.                */
/* *transf21   : coefficients de transformation 2 vers 1.                */
/* nb_coef_a   : dimension des tableaux des coefficients de              */
/*               transformation (=3 pour ordre 1 =6 pour ordre deux).    */
/* ordre_corresp : =1 pour faire les correspondances avec l'ordre 1      */
/*                 =2 pour faire les correspondances avec l'ordre 1      */
/* delta       : dimension, en pixels, du cote du carre d'incertitude    */
/*               pour l'appariement de deux etoiles (=1.0).              */
/* flag_corresp: =0 compte uniquement le nombre d'etoiles en commun.     */
/*                  Ne modifie pas les tableaux *corresp et *differe.    */
/*                  A employer ave les noms de fichiers = "".            */
/*               =1 modifie les tableaux *corresp et *differe et inclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et trie les listes en magnitudes.                    */
/*               =2 modifie les tableaux *corresp et *differe et exclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et trie les listes en magnitudes.                    */
/*              =11 modifie les tableaux *corresp et *differe et inclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et ne trie pas les listes en magnitudes.             */
/*              =12 modifie les tableaux *corresp et *differe et exclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et ne trie pas les listes en magnitudes.             */
/*                                                                       */
/* SORTIES :                                                             */
/* *total   : nombre total d'etoiles en correspondance.                  */
/* *corresp : tableau des correspondances entre les deux listes.         */
/*            non affecte si flag_corresp==0.                            */
/* *differe : tableau des differences entre les deux listes.             */
/*            non affecte si flag_corresp==0.                            */
/*************************************************************************/
{
   int fichier_com;
   FILE *hand_com;
   int fichier_dif;
   FILE *hand_dif;
   int i,totall_cor=0,totall_dif=0,accord;
   int i1,i2,nbdmin,flag_tri;
   double x1,x2,y1,y2;
   double x=0.,y=0.,poids,delta2,dist2,*dmin,m;
   double xmin,xmax,ymin,ymax,bordure;
   char ligne[255];
   struct focas_tableau_entree *data_tab100;
   struct focas_tableau_entree *data_tab200;
   int *deja_pris,*dminindex;
   int nombre,taille,msg;
   char message_err[TT_MAXLIGNE];
   char name[TT_LEN_SHORTFILENAME];
   double val0,val;
   int ibeg,iend,imed;
   int sortie;

   flag_tri=1;
   if (flag_corresp==11) {flag_corresp=1; flag_tri=0;}
   if (flag_corresp==12) {flag_corresp=2; flag_tri=0;}

   /* --- initialisation des listes d'etoiles et des tableaux ---*/
   data_tab100=NULL;
   data_tab200=NULL;
   deja_pris=NULL;
   dmin=NULL;
   dminindex=NULL;
   nombre=nb1tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab100,&nombre,&taille,"data_tab100"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer data_tab100");
      return(PB);
   }
   nombre=nb2tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab200,&nombre,&taille,"data_tab200"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer data_tab200");
      tt_free2((void**)&data_tab100,"data_tab100");
      return(PB);
   }
   nombre=nb1tot+1;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&deja_pris,&nombre,&taille,"deja_pris"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer deja_pris");
      tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
      return(PB);
   }
   for (i=0;i<nombre;i++) { deja_pris[i]=0; }
   nbdmin=(nb1tot>nb2tot)?nb1tot:nb2tot;
   nombre=nbdmin+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&dmin,&nombre,&taille,"dmin"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer dmin");
      tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
      tt_free2((void**)&deja_pris,"deja_pris");
      return(PB);
   }
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&dminindex,&nombre,&taille,"dminindex"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer dminindex");
      tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
      tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
      return(PB);
   }

   if (strcmp(nom_fichier_com,"")==0) {fichier_com=0;} else {fichier_com=1;}
   if (strcmp(nom_fichier_dif,"")==0) {fichier_dif=0;} else {fichier_dif=1;}

   /* --- On remplit les listes d'etoiles ---*/
   for (i=1;i<=nb1tot;i++) {
      data_tab100[i].x=data_tab10[i].x;
      data_tab100[i].y=data_tab10[i].y;
      data_tab100[i].mag=data_tab10[i].mag;
      data_tab100[i].ad=data_tab10[i].ad;
      data_tab100[i].dec=data_tab10[i].dec;
      data_tab100[i].mag_gsc=data_tab10[i].mag_gsc;
      data_tab100[i].type=data_tab10[i].type;
   }
   if (focas_tri_tabx(data_tab100,nb1tot)!=OK) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer dmin");
      tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
      tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
      return(PB);
   }
   for (i=1;i<=nb2tot;i++) {
      x=data_tab20[i].x;
      y=data_tab20[i].y;
      if (ordre_corresp==1) {
         data_tab200[i].x=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
         data_tab200[i].y=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
      } else {
         data_tab200[i].x=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3]+transf21[1*nb_coef_a+4]*x*y+transf21[1*nb_coef_a+5]*x*x+transf21[1*nb_coef_a+6]*y*y;
         data_tab200[i].y=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3]+transf21[2*nb_coef_a+4]*x*y+transf21[2*nb_coef_a+5]*x*x+transf21[2*nb_coef_a+6]*y*y;
      }
      data_tab200[i].mag=data_tab20[i].mag;
      data_tab200[i].ad=data_tab20[i].ad;
      data_tab200[i].dec=data_tab20[i].dec;
      data_tab200[i].mag_gsc=data_tab20[i].mag_gsc;
      data_tab200[i].type=data_tab20[i].type;
   }

   if (delta<=0) {delta=1;}
   delta2=delta*delta;
   bordure=3; /* pixels*/
   if (nb1tot==0) {
      ymax=1e9;
      ymin=0;
      xmax=1e9;
      xmin=0;
   } else {
      ymin=1e9;
      ymax=0;
      xmin=1e9;
      xmax=0;
   }
   /* boucle de recherche des bornes de l'image commune */
   for (i1=1;i1<=nb1tot;i1++) {
      x1=data_tab100[i1].x;
      y1=data_tab100[i1].y;
      dmin[i1]=1e9;
      if (x1<xmin) {xmin=x1;}
      if (x1>xmax) {xmax=x1;}
      if (y1<ymin) {ymin=y1;}
      if (y1>ymax) {ymax=y1;}
   }
   xmin+=bordure;
   ymin+=bordure;
   xmax-=bordure;
   ymax-=bordure;
   /* Calcul des distances minimales*/
   /* vieil algo lent
   for (i2=1;i2<=nb2tot;i2++) {
      x2=data_tab200[i2].x;
      y2=data_tab200[i2].y;
      dmin[i2]=1e9;
      dminindex[i2]=-1;
      for (i1=1;i1<=nb1tot;i1++) {
	 x1=data_tab100[i1].x;
	 y1=data_tab100[i1].y;
	 dist2=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
	 if ((dist2<dmin[i2])&&(dist2<=delta2)) {
	    dmin[i2]=dist2;
	    dminindex[i2]=i1;
	 }
      }
   }
   */
   /* nouvel algo rapide */
   for (i2=1;i2<=nb2tot;i2++) {
      x2=data_tab200[i2].x;
      y2=data_tab200[i2].y;
      /* recherche l'indice i1 pour que data_tab200[i2].x */
      /* soit le plus proche de data_tab100[i1].x-delta */
      /* On procede par dichotomie car data_tab100 est trie en x */
      val0=x2-delta;
      ibeg=1;
      iend=nb1tot;
      sortie=0;
      while (sortie==0) {
         imed=(int)floor((iend+ibeg)/2.);
         val=data_tab100[imed].x;
         if (val0>val) {
            ibeg=imed;
         } else {
            iend=imed;
         }
         if ((iend-ibeg)<20) {
            sortie=1;
            break;
         }
      }
      ibeg-=20;
      if (ibeg<1) {ibeg=1;}
      if (ibeg>=nb1tot) {ibeg=nb1tot;}
      dmin[i2]=1e9;
      dminindex[i2]=-1;
      for (i1=ibeg;i1<=nb1tot;i1++) {
	 x1=data_tab100[i1].x;
         if (x1>(x2+delta)) {
            break;
         }
	 y1=data_tab100[i1].y;
	 dist2=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
	 if ((dist2<dmin[i2])&&(dist2<=delta2)) {
	    dmin[i2]=dist2;
	    dminindex[i2]=i1;
	 }
      }
   }

   /* grande boucle des assignations pbtt */
   totall_cor=0;
   totall_dif=0;
   for (i2=1;i2<=nb2tot;i2++) {
      x2=data_tab200[i2].x;
      y2=data_tab200[i2].y;
      accord=0;
      if (dminindex[i2]>=0) {
      /*for (i1=1;i1<=nb1tot;i1++) {*/
         i1=dminindex[i2];
	 x1=data_tab100[i1].x;
	 y1=data_tab100[i1].y;
         /*
	 dist2=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
	 if ((dist2==dmin[i2])&&(deja_pris[i1]==(int)(0))&&(dist2<=delta2)) {
         */
	 if (deja_pris[i1]==(int)(0)) {
	    totall_cor++;accord=1;
	    deja_pris[i1]=(int)(1);
	    if ((data_tab100[i1].type==-1)&&(flag_corresp==2)) {
	       totall_cor--;
	    } else {
	       /*
	       if (totall_cor>nbdmin) {
		  totall_cor=nbdmin;
	       }
	       */
	       corresp[totall_cor].indice1=i1;
	       corresp[totall_cor].x1=x1;
	       corresp[totall_cor].y1=y1;
	       corresp[totall_cor].mag1=data_tab100[i1].mag;
	       x=data_tab200[i2].x;
	       y=data_tab200[i2].y;
	       corresp[totall_cor].indice2=i2;
               if (ordre_corresp==1) {
   	          corresp[totall_cor].x2=transf12[1*nb_coef_a+1]*x+transf12[1*nb_coef_a+2]*y+transf12[1*nb_coef_a+3];
	          corresp[totall_cor].y2=transf12[2*nb_coef_a+1]*x+transf12[2*nb_coef_a+2]*y+transf12[2*nb_coef_a+3];
               } else {
   	          corresp[totall_cor].x2=transf12[1*nb_coef_a+1]*x+transf12[1*nb_coef_a+2]*y+transf12[1*nb_coef_a+3]+transf12[1*nb_coef_a+4]*x*y+transf12[1*nb_coef_a+5]*x*x+transf12[1*nb_coef_a+6]*y*y;
	          corresp[totall_cor].y2=transf12[2*nb_coef_a+1]*x+transf12[2*nb_coef_a+2]*y+transf12[2*nb_coef_a+3]+transf12[2*nb_coef_a+4]*x*y+transf12[2*nb_coef_a+5]*x*x+transf12[2*nb_coef_a+6]*y*y;
               }
	       corresp[totall_cor].mag2=data_tab200[i2].mag;
	       x-=x1;
	       y-=y1;
	       poids=1-(x*x+y*y)/(2*delta2);
	       corresp[totall_cor].poids=poids;
	       corresp[totall_cor].ad=data_tab200[i2].ad;
	       corresp[totall_cor].dec=data_tab200[i2].dec;
	       corresp[totall_cor].mag_gsc=data_tab200[i2].mag_gsc;
	       corresp[totall_cor].type1=data_tab100[i1].type;
	       corresp[totall_cor].type2=data_tab200[i2].type;
	    }
	 }
      }
      if (accord==0) {
	 if (flag_corresp>=1) {
	    if ((x2>xmin)&&(x2<xmax)&&(y2>ymin)&&(y2<ymax)) {
	       totall_dif++;
	       /*
	       if (totall_dif>nbdmin) {
		  totall_dif=nbdmin;
	       }
	       */
	       differe[totall_dif].indice2=i2;
	       differe[totall_dif].x1=x2;
	       differe[totall_dif].y1=y2;
	       differe[totall_dif].mag1=data_tab200[i2].mag;
               if (ordre_corresp==1) {
  	          differe[totall_dif].x2=transf12[1*nb_coef_a+1]*x2+transf12[1*nb_coef_a+2]*y2+transf12[1*nb_coef_a+3];
	          differe[totall_dif].y2=transf12[2*nb_coef_a+1]*x2+transf12[2*nb_coef_a+2]*y2+transf12[2*nb_coef_a+3];
               } else {
  	          differe[totall_dif].x2=transf12[1*nb_coef_a+1]*x2+transf12[1*nb_coef_a+2]*y2+transf12[1*nb_coef_a+3]+transf12[1*nb_coef_a+4]*x*y+transf12[1*nb_coef_a+5]*x*x+transf12[1*nb_coef_a+6]*y*y;
	          differe[totall_dif].y2=transf12[2*nb_coef_a+1]*x2+transf12[2*nb_coef_a+2]*y2+transf12[2*nb_coef_a+3]+transf12[2*nb_coef_a+4]*x*y+transf12[2*nb_coef_a+5]*x*x+transf12[2*nb_coef_a+6]*y*y;
               }
	       differe[totall_dif].mag2=data_tab200[i2].mag;
	       differe[totall_dif].ad=data_tab200[i2].ad;
	       differe[totall_dif].dec=data_tab200[i2].dec;
	       differe[totall_dif].mag_gsc=data_tab200[i2].mag_gsc;
	       differe[totall_dif].type1=data_tab200[i2].type;
	       differe[totall_dif].type2=data_tab200[i2].type;
	    }
	 }
      }
   }

   /* --- ecrit les fichiers de correspondance ---*/
   if ((fichier_com==1)&&(flag_corresp>=1)) {
      if (flag_tri==1) {
	 /* trie dans l'ordre des x decroissant*/
	 for (i=1;i<=totall_cor;i++) {
	    poids=corresp[i].x1;
	    corresp[i].poids=poids;
	 }
	 if (focas_tri_corresp(corresp,totall_cor)!=OK) {
	    tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	    tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
	    return(PB);
	 }
	 /* retrie dans l'ordre des brillances decroissantes (mag croissantes)*/
	 for (i=1;i<=totall_cor;i++) {
	    poids=corresp[i].mag1;
	    corresp[i].poids=poids;
	 }
	 if (focas_tri_corresp(corresp,totall_cor)!=OK) {
	    tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	    tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
	    return(PB);
	 }
      }
      /* sortie dans le fichier commun*/
      if ((hand_com=fopen(nom_fichier_com,"wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file %s in focas_liste_commune",nom_fichier_com);
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
	 return(PB);
      }
      for (i=1;i<=totall_cor;i++) {
	  /*Modif Yassine formatage
	  sprintf(ligne,"%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\n",corresp[i].x1,corresp[i].y1,corresp[i].mag1,	  
	  corresp[i].x2,corresp[i].y2,corresp[i].mag2,corresp[i].mag1-corresp[i].mag2,corresp[i].type1,corresp[i].type2);*/
	  sprintf(ligne,"%8.3f %8.3f %7.4f %8.3f %8.3f %7.4f %+8.4f %2d %2d\n",corresp[i].x1,corresp[i].y1,corresp[i].mag1,	  
	  corresp[i].x2,corresp[i].y2,corresp[i].mag2,corresp[i].mag1-corresp[i].mag2,corresp[i].type1,corresp[i].type2);
	  /*fin*/
	 fwrite(ligne,strlen(ligne),1,hand_com);
      }
      fclose(hand_com);
      /* sortie dans le fichier commun XY.LST*/
	  sprintf(name,"xy%s.lst",tt_tmpfile_ext);
      if ((hand_com=fopen(name,"wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file xy.lst in focas_liste_commune");
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
	 return(PB);
      }
      for (i=1;i<=totall_cor;i++) {
	 /* if (corresp[i].type1>0) {   // ### */
	    m=pow(10.0,(-corresp[i].mag1/2.5));
	    /*Modif Yassine formatage
		sprintf(ligne,"%f\t%f\t%f\n",corresp[i].x1,corresp[i].y1,m);*/
		sprintf(ligne,"%8.3f %8.3f %9.6f\n",corresp[i].x1,corresp[i].y1,m);
		/*fin*/
	    fwrite(ligne,strlen(ligne),1,hand_com);
	 /* }*/
      }
      fclose(hand_com);
      /* sortie dans le fichier commun EQ.LST */
	  sprintf(name,"eq%s.lst",tt_tmpfile_ext);
      if ((hand_com=fopen(name,"wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file eq.lst in focas_liste_commune");
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
	 return(PB);
      }
      for (i=1;i<=totall_cor;i++) {
	 /* if (corresp[i].type1>0) {   // ###*/
	    /*Modif Yassine formatage
	    sprintf(ligne,"%f\t%f\t%f\n",corresp[i].ad,corresp[i].dec,corresp[i].mag_gsc);*/
	    sprintf(ligne,"%11.6f %11.6f %6.3f\n",corresp[i].ad,corresp[i].dec,corresp[i].mag_gsc);
		/*fin*/
	    fwrite(ligne,strlen(ligne),1,hand_com);
	 /* }*/
      }
      fclose(hand_com);
   }

   /* --- ecrit le fichier des differences ---*/
   if ((fichier_dif==1)&&(flag_corresp>=1)) {
      if (flag_tri==1) {
	 /* trie dans l'ordre des brillances decroissantes (mag croissantes)*/
	 for (i=1;i<=totall_dif;i++) {
	    poids=differe[i].mag2;
	    differe[i].poids=poids;
	 }
	 if (focas_tri_corresp(differe,totall_dif)!=OK) {
	    tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	    tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
	    return(PB);
	 }
      }
      /* sortie dans le fichier differe*/
      if ((hand_dif=fopen(nom_fichier_dif,"wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file %s in focas_liste_commune",nom_fichier_dif);
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
	 return(PB);
      }
      for (i=1;i<=totall_dif;i++) {
	  /*Modif Yassine formatage
	  sprintf(ligne,"%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\n",differe[i].x1,differe[i].y1,differe[i].mag2,
	  differe[i].x2,differe[i].y2,differe[i].mag2,differe[i].mag1-differe[i].mag2,differe[i].type1,differe[i].type2);*/
      sprintf(ligne,"%8.3f %8.3f %6.3f %8.3f %8.3f %6.3f %+7.3f %2d %2d\n",differe[i].x1,differe[i].y1,differe[i].mag2,
	  differe[i].x2,differe[i].y2,differe[i].mag2,differe[i].mag1-differe[i].mag2,differe[i].type1,differe[i].type2);
	  /*fin*/
	  fwrite(ligne,strlen(ligne),1,hand_dif);
      }
      fclose(hand_dif);
   }
   *total=totall_cor;
   tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
   tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");tt_free2((void**)&dminindex,"dminindex");
   return(OK);
}

int focas_tri_corresp(struct focas_tableau_corresp *corresp,int nbtot)
/**************************************************************************/
/* trie *corresp dans l'ordre croissant de poids                          */
/**************************************************************************/
{
   int n,s,l,r,i,j;
   int k;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;
   int nombre,taille,msg;

   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_corresp for pointer qsort_r");
      return(PB);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_corresp for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(PB);
   }

   /*--- trie les valeurs dans l'ordre croissant des poids ---*/
   n=nbtot;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=corresp[(int) (floor((l+r)/2))].poids;
	 do {
	    while (corresp[i].poids<v) {i++;}
	    while (v<corresp[j].poids) {j--;}
	    if (i<=j) {
	       w=corresp[i].x1;      corresp[i].x1=corresp[j].x1;           corresp[j].x1=w;
	       w=corresp[i].y1;      corresp[i].y1=corresp[j].y1;           corresp[j].y1=w;
	       w=corresp[i].mag1;    corresp[i].mag1=corresp[j].mag1;       corresp[j].mag1=w;
	       w=corresp[i].x2;      corresp[i].x2=corresp[j].x2;           corresp[j].x2=w;
	       w=corresp[i].y2;      corresp[i].y2=corresp[j].y2;           corresp[j].y2=w;
	       w=corresp[i].mag2;    corresp[i].mag2=corresp[j].mag2;       corresp[j].mag2=w;
	       w=corresp[i].poids;   corresp[i].poids=corresp[j].poids;     corresp[j].poids=w;
	       w=corresp[i].ad;      corresp[i].ad=corresp[j].ad;           corresp[j].ad=w;
	       w=corresp[i].dec;     corresp[i].dec=corresp[j].dec;         corresp[j].dec=w;
	       w=corresp[i].mag_gsc; corresp[i].mag_gsc=corresp[j].mag_gsc; corresp[j].mag_gsc=w;
	       k=corresp[i].type1;   corresp[i].type1=corresp[j].type1;     corresp[j].type1=k;
	       k=corresp[i].type2;   corresp[i].type2=corresp[j].type2;     corresp[j].type2=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
    tt_free2((void**)&qsort_r,"qsort_r");
    tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_detec_dist(struct focas_tableau_corresp *data1,int nbdif1,struct focas_tableau_corresp *data2,int nbdif2,struct focas_tableau_dist *dist12,int nbdist12)
{
   int m0,n0,k,m,n;
   double x1,x2,y1,y2;
   int s,l,r,i,j;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;
   int nombre,taille,msg;

   m0=nbdif1;
   n0=nbdif2;
   for (k=0,m=1;m<=m0;m++) {
      x1=data1[m].x1;
      y1=data1[m].y1;
      for (n=1;n<=n0;n++) {
	 x2=data2[n].x1;
	 y2=data2[n].y1;
	 k++;
	 dist12[k].indice1=m;
	 dist12[k].indice2=n;
	 dist12[k].dist2=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
      }
   }
   /* trier les dist12 dans l'ordre croissant de .dist2*/
   nombre=FOCAS_SORT;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_r,&nombre,&taille,"qsort_r"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_corresp for pointer qsort_r");
      return(PB);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&qsort_l,&nombre,&taille,"qsort_l"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_corresp for pointer qsort_l");
      tt_free2((void**)&qsort_r,"qsort_r");
      return(PB);
   }
   n=nbdist12;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=dist12[(int) (floor((l+r)/2))].dist2;
	 do {
	    while (dist12[i].dist2<v) {i++;}
	    while (v<dist12[j].dist2) {j--;}
	    if (i<=j) {
	       w=dist12[i].dist2;   dist12[i].dist2=dist12[j].dist2;     dist12[j].dist2=w;
	       k=dist12[i].indice1; dist12[i].indice1=dist12[j].indice1; dist12[j].indice1=k;
	       k=dist12[i].indice2; dist12[i].indice2=dist12[j].indice2; dist12[j].indice2=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
    tt_free2((void**)&qsort_r,"qsort_r");
    tt_free2((void**)&qsort_l,"qsort_l");
   return(OK);
}

int focas_transcom(char *nom_fichier,double *transf21)
/**************************************************************************/
/* lit un fichier de correspondances d'etoiles. Ordre des colonnes :      */
/*                    L'odre des colonnes est :                           */
/*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                  */
/*                     mag1-2 qualite1 qualite2                           */
/*                     (qualite=-1 si sature sinon =1)                    */
/* Modifie des valeurs X2 et Y2 en appliquant transf_2vers1 sur X2,Y2     */
/* et resauve sous le meme nom.                                           */
/**************************************************************************/
{
   int i,j,nbcom,nb_coef_a=3;
   FILE *hand_com;
   struct focas_tableau_corresp *data0=NULL;
   double x22,y22;
   char ligne[255];
   char message_err[TT_MAXLIGNE];
   int msg,nombre,taille;

   nbcom=0;
   nombre=nbcom+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data0,&nombre,&taille,"data0"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_corresp for pointer data0");
      return(TT_ERR_PB_MALLOC);
   }
   if (focas_get_tab2(nom_fichier,&nbcom,data0)!=OK) {
      tt_free2((void**)&data0,"data0");
      return(PB);
   }
   tt_free2((void**)&data0,"data0");
   nombre=nbcom+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data0,&nombre,&taille,"data0"))!=OK) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_tri_corresp for pointer data0");
      tt_free2((void**)&data0,"data0");
      return(TT_ERR_PB_MALLOC);
   }
   if (focas_get_tab2(nom_fichier,&nbcom,data0)!=OK) {
      tt_free2((void**)&data0,"data0");
      return(PB);
   }
   for (j=1;j<=nbcom;j++) {
      x22=data0[j].x2;
      y22=data0[j].y2;
      data0[j].x2=transf21[1*nb_coef_a+1]*x22+transf21[1*nb_coef_a+2]*y22+transf21[1*nb_coef_a+3];
      data0[j].y2=transf21[2*nb_coef_a+1]*x22+transf21[2*nb_coef_a+2]*y22+transf21[2*nb_coef_a+3];
   }
   if ((hand_com=fopen(nom_fichier,"wt"))==NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file %s in focas_transcom",nom_fichier);
      tt_errlog("",msg,message_err);
      tt_free2((void**)&data0,"data0");
      return(msg);
   }
   for (i=1;i<=nbcom;i++) {
      sprintf(ligne,"%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\n",
      data0[i].x1,data0[i].y1,data0[i].mag1,
      data0[i].x2,data0[i].y2,data0[i].mag2,
      data0[i].mag1-data0[i].mag2,
      data0[i].type1,data0[i].type2);
      fwrite(ligne,strlen(ligne),1,hand_com);
   }
   fclose(hand_com);
   tt_free2((void**)&data0,"data0");
   return(OK);
}

int focas_get_tab3(char *nom_fichier_in,int *nblignes,struct focas_tableau_dist *data)
/**************************************************************************/
/* lit un fichier de correspondances d'etoiles. Ordre des colonnes :      */
/*   indice1 indice2 distance                                             */
/*                                                                        */
/* *nom_fichier_in : nom complet du fichier a ouvrir.                     */
/* *nblignes : nombre de lignes non nulles dans le fichier.               */
/*             Si *nblignes=0 en entree, la fonction ne fait que de       */
/*             de retourner la valeur de *nblignes et rien d'autre.       */
/* data : est une structure qui renvoie les donnees lues sur le fichier.  */
/**************************************************************************/
{
   FILE *fichier_in ;
   int iligne,flag_comptelig,msg;
   char texte[81],ligne[81];
   char message_err[TT_MAXLIGNE];

   /* ouvre le fichier d'entree*/
   if (( fichier_in=fopen(nom_fichier_in, "r") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in focas_get_tab3",nom_fichier_in);
      tt_errlog("",msg,message_err);
      return(msg);
   }
   if (*nblignes==0) {flag_comptelig=0;} else {flag_comptelig=1;}
   iligne=0;
   do {
      if (fgets(ligne,80,fichier_in)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    iligne++;
	    if (flag_comptelig>0) {
#ifdef OS_LINUX_GCC_SO
	       sscanf(ligne,"%d %d %lf",&data[iligne].indice1,&data[iligne].indice2,&data[iligne].dist2);
#else
	       sscanf(ligne,"%ld %ld %lf",&data[iligne].indice1,&data[iligne].indice2,&data[iligne].dist2);
#endif
	    }
	 }
      }
   } while ( (feof(fichier_in)==0) || ((iligne<*nblignes)&&(flag_comptelig>0)) ) ;
   fclose(fichier_in );
   /* --- on sort de la fonction et modifie *nombre*/
   *nblignes=iligne;
   return(OK);
}

int focas_get_tab2(char *nom_fichier_in,int *nblignes,struct focas_tableau_corresp *data)
/**************************************************************************/
/* lit un fichier de correspondances d'etoiles. Ordre des colonnes :      */
/*                    L'odre des colonnes est :                           */
/*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                  */
/*                     mag1-2 qualite1 qualite2                           */
/*                     (qualite=-1 si sature sinon =1)                    */
/*                                                                        */
/* *nom_fichier_in : nom complet du fichier a ouvrir.                     */
/* *nblignes : nombre de lignes non nulles dans le fichier.               */
/*             Si *nblignes=0 en entree, la fonction ne fait que de       */
/*             de retourner la valeur de *nblignes et rien d'autre.       */
/* data : est une structure qui renvoie les donnees lues sur le fichier.  */
/**************************************************************************/
{
   FILE *fichier_in ;
   int iligne,flag_comptelig,msg;
   char texte[81],ligne[256];
   double rien;
   char message_err[TT_MAXLIGNE];

   /* ouvre le fichier d'entree*/
   if (( fichier_in=fopen(nom_fichier_in, "r") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in focas_get_tab2",nom_fichier_in);
      tt_errlog("",msg,message_err);
      return(msg);
   }
   if (*nblignes==0) {flag_comptelig=0;} else {flag_comptelig=1;}
   iligne=0;
   do {
      if (fgets(ligne,255,fichier_in)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    iligne++;
	    if (flag_comptelig>0) {
#ifdef OS_LINUX_GCC_SO
	       sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %d %d",
#else
	       sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %ld %ld",
#endif
	       &data[iligne].x1,&data[iligne].y1,&data[iligne].mag1,
	       &data[iligne].x2,&data[iligne].y2,&data[iligne].mag2,
	       &rien,&data[iligne].type1,&data[iligne].type2);
	       data[iligne].indice1=data[iligne].indice2=iligne;
	       data[iligne].poids=0;
	    }
	 }
      }
   } while ( (feof(fichier_in)==0) || ((iligne<*nblignes)&&(flag_comptelig>0)) ) ;
   fclose(fichier_in );
   /* --- on sort de la fonction et modifie *nombre*/
   *nblignes=iligne;
   return(OK);
}

int focas_getput_tab(char *nom_fichier_ref,char *nom_fichier_in,char *nom_fichier_out)
/**************************************************************************/
/* convertit fichier de correspondances d'etoiles. Ordre des colonnes :   */
/*                    L'odre des colonnes est :                           */
/*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                  */
/*                     mag1-2 qualite1 qualite2                           */
/*                     (qualite=-1 si sature sinon =1)                    */
/*                                                                        */
/* *nom_fichier_in : nom complet du fichier a ouvrir.                     */
/**************************************************************************/
{
   FILE *fichier_in ;
   FILE *fichier_out;
   char texte[81],ligne[256],fich_tmp[81];
   double rien,x,y;
   int irien;
   int nbcom,k,memefich=0;
   struct focas_tableau_corresp *data0;
   char message_err[TT_MAXLIGNE];
   int msg,nombre,taille;

   nbcom=0;
   nombre=nbcom+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data0,&nombre,&taille,"data0"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_getput_tab for pointer data0");
      return(TT_ERR_PB_MALLOC);
   }
   if (focas_get_tab2(nom_fichier_ref,&nbcom,data0)!=OK) {
      tt_free2((void**)&data0,"data0");
      return(PB);
   }
   tt_free2((void**)&data0,"data0");
   nombre=nbcom+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data0,&nombre,&taille,"data0"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_getput_tab for pointer data0");
      return(TT_ERR_PB_MALLOC);
   }
   if (focas_get_tab2(nom_fichier_ref,&nbcom,data0)!=OK) {
      tt_free2((void**)&data0,"data0");
      return(PB);
   }
   /* ouvre le fichier d'entree*/
   if (( fichier_in=fopen(nom_fichier_in, "r") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message_err,"File %s not found in focas_getput_tab",nom_fichier_in);
      tt_errlog("",msg,message_err);
      tt_free2((void**)&data0,"data0");
      return(msg);
   }
   /* ouvre le fichier de sortie*/
   strcpy(fich_tmp,nom_fichier_out);
   if (strcmp(nom_fichier_in,nom_fichier_out)==0) {
      memefich=1;
      sprintf(fich_tmp,"#%s.lst",tt_tmpfile_ext);
   }
   if (( fichier_out=fopen(fich_tmp, "w") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file %s in focas_getput_tab",fich_tmp);
      tt_errlog("",msg,message_err);
      tt_free2((void**)&data0,"data0");
      return(msg);
   }
   do {
      if (fgets(ligne,255,fichier_in)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
#ifdef OS_LINUX_GCC_SO
	    sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %d %d",&x,&y,&rien,&rien,&rien,&rien,&rien,&irien,&irien);
#else
	    sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %ld %ld",&x,&y,&rien,&rien,&rien,&rien,&rien,&irien,&irien);
#endif
	    for (k=1;k<=nbcom;k++) {
	       if ((x==data0[k].x1)&&(y==data0[k].y1)) {
		  fwrite(ligne,1,strlen(ligne),fichier_out);
	       }
	    }
	 }
      }
   } while (feof(fichier_in)==0);
   fclose(fichier_in );
   fclose(fichier_out);
   if (memefich==1) {
      strcpy(fich_tmp,fich_tmp);
      remove(nom_fichier_out);
      rename(fich_tmp,nom_fichier_out);
   }
   tt_free2((void**)&data0,"data0");
   return(OK);
}
