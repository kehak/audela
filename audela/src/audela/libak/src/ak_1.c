/* ak_1.c
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
/* Le include ak.h ne contient pas d'infos concernant Tcl.                */
/***************************************************************************/
#include "ak.h"
#define AK_QSORT 2000
#include "ak_3.h"

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On prend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double ak_GetUsnoBleueMagnitude(int magL)
{
double mag;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+4,3); *(buf2+3)='\0';
mag = (double)atof(buf2)/10.0;
if (mag==0.0)
   {
   strncpy(buf2,buf+1,3);
   *(buf2+3)='\0';
   if ((double)atof(buf2)==0.0)
      {
      strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
      mag = (double)atof(buf2)/10.0;
      }
   }
return mag;
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On rpend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double ak_GetUsnoRedMagnitude(int magL)
{
double mag;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
mag=(double)atof(buf2)/10.0;
if (mag==999.0)
   {
   strncpy(buf2,buf+4,3); *(buf2+3) = '\0';
   mag=(double)atof(buf2)/10.0;
   }
return mag;
}

/************************************************************************************/
int Cmd_aktcl_cour_finalbis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   char s[200];
   int code;
   int i,j,n_obs,n_good,n_bad,n_arm,k=0,m_x;
	Tcl_DString dsptr;
   gsl_matrix *x;
   gsl_vector *coefs;
   gsl_vector_view jd;
   gsl_vector_view mag;
   gsl_vector *phases_obs,*mags_obs;
   gsl_vector *jds_good,*mags_good;
   gsl_vector *jds_bad,*mags_bad;
	double frequence=0,pi;
	gsl_matrix *A;
	gsl_vector *y,*mags_final;
   double total,mean,std,res,sigma;

	if(argc!=5) {
      sprintf(s,"Usage: %s ListMatrix_2cols:jd,mag frequence ListVector:coefs sigma", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      code=gsltcltcl_getgslmatrix(interp,argv[1],&x,&n_obs,&m_x);
		frequence =atof(argv[2]);
		code=gsltcltcl_getgslvector(interp,argv[3],&coefs,&k);
		sigma=atof(argv[4])/2.;
      /* --- nombre d'harmoniques ---*/
		n_arm=(k-1)/2;
		/*-----init---------*/		
	   /* 1+2*n_arm = nb de coefs a determiner */
	   mags_obs    =gsl_vector_calloc(n_obs);
	   phases_obs  =gsl_vector_calloc(n_obs);
	   y          =gsl_vector_calloc(n_obs+1);
		A          =gsl_matrix_calloc(n_obs+1,1+2*n_arm);
	   mags_final    =gsl_vector_calloc(n_obs+1);
		jd=gsl_matrix_column(x,0);
		mag=gsl_matrix_column(x,1);
      /* --- calcul du vecteur phases ---*/
      for (j=0;j<n_obs;j++) {
         res=jd.vector.data[m_x*j]*frequence;
         phases_obs->data[j]=res-floor(res);
         mags_obs->data[j]=mag.vector.data[m_x*j];
      }
      /* --- calcul de 'mag_final' correspondant aux 'phases_obs' ---*/      
	   pi=4*atan(1);
	   for (i=1;i<n_arm+1;i++) {
		   for (j=0;j<=n_obs;j++){
            if (j<n_obs) {
   			   y->data[j]=phases_obs->data[j];
            } else {
   			   y->data[j]=phases_obs->data[0];
            }
				gsl_matrix_set(A,j,2*i-1,sin(2*pi*i*y->data[j]));
			   gsl_matrix_set(A,j,2*i-2,cos(2*pi*i*y->data[j]));
			}
		}
      for (j=0;j<=n_obs;j++) {
		   gsl_matrix_set(A,j,2*n_arm,1.);
		}
	   /* A*y */
      gsl_blas_dgemv(CblasNoTrans,1.0,A,coefs,0.0,mags_final);
      /* --- ecart type de la difference des mags ---*/
		for (j=0;j<n_obs;j++){
			phases_obs->data[j]=mags_obs->data[j]-mags_final->data[j];
      }
      total=0.;
		for (j=0;j<n_obs;j++){
			total+=phases_obs->data[j];         
      }
      mean=total/n_obs;
      total=0.;
		for (j=0;j<n_obs;j++){
         std=phases_obs->data[j]-mean;
			total+=(std*std);         
      }
      if (n_obs>1) {
         std=sqrt(total/(n_obs-1));
      } else {
         std=sqrt(total);
      }
      /* --- on compte les bonnes et les mauvaises mesures ---*/
      n_good=0;
      n_bad=0;
		for (j=0;j<n_obs;j++){
			res=fabs(mags_obs->data[j]-mags_final->data[j]);
         if (res<sigma) {
            n_good++;
         } else {
            n_bad++;
         }
      }
      /* --- on remplit les vecteurs des bonnes et des mauvaises mesures ---*/
      if (n_good>0) {
   	   mags_good =gsl_vector_calloc(n_good);
	      jds_good  =gsl_vector_calloc(n_good);
      }
      if (n_bad>0) {
   	   mags_bad =gsl_vector_calloc(n_bad);
	      jds_bad  =gsl_vector_calloc(n_bad);
      }
      n_good=0;
      n_bad=0;
		for (j=0;j<n_obs;j++){
			res=fabs(mags_obs->data[j]-mags_final->data[j]);
         if (res<sigma) {
            jds_good->data[n_good]=jd.vector.data[m_x*j];
            mags_good->data[n_good]=mag.vector.data[m_x*j];
            n_good++;
         } else {
            jds_bad->data[n_bad]=jd.vector.data[m_x*j];
            mags_bad->data[n_bad]=mag.vector.data[m_x*j];
            n_bad++;
         }
      }


	   /* Sortie du résultat*/
	   Tcl_DStringInit(&dsptr);
      Tcl_DStringAppend(&dsptr,"{",-1);
      gsltcltcl_setgslvector(interp,&dsptr,y,n_obs+1);
      Tcl_DStringAppend(&dsptr,"} {",-1);
      gsltcltcl_setgslvector(interp,&dsptr,mags_final,n_obs+1);
      Tcl_DStringAppend(&dsptr,"} ",-1);
      sprintf(s,"%f {",std);
      Tcl_DStringAppend(&dsptr,s,-1);
      if (n_good>0) {
         gsltcltcl_setgslvector(interp,&dsptr,jds_good,n_good);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      if (n_good>0) {
         gsltcltcl_setgslvector(interp,&dsptr,mags_good,n_good);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      if (n_bad>0) {
         gsltcltcl_setgslvector(interp,&dsptr,jds_bad,n_bad);
      }
      Tcl_DStringAppend(&dsptr,"} {",-1);
      if (n_bad>0) {
         gsltcltcl_setgslvector(interp,&dsptr,mags_bad,n_bad);
      }
      Tcl_DStringAppend(&dsptr,"}",-1);


      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
      /* --- liberation de la memoire ---*/
      if (n_good>0) {
   	   gsl_vector_free(mags_good);
	      gsl_vector_free(jds_good);
      }
      if (n_bad>0) {
   	   gsl_vector_free(mags_bad);
	      gsl_vector_free(jds_bad);
      }	
   	gsl_vector_free(mags_obs);
   	gsl_vector_free(phases_obs);
   	gsl_vector_free(coefs);
   	gsl_vector_free(y);
	   gsl_vector_free(mags_final);
	   gsl_matrix_free(A);
	   gsl_matrix_free(x);
	}
	return TCL_OK;
}



int ak_htm_testin(double *v0, double *v1, double *v2, double *v)
/****************************************************************************/
/* Retourne 1 si v est l'interieur du triangle v0,v1,v2.                    */
/****************************************************************************/
/****************************************************************************/
{
   double p[4],res1,res2,res3;
   int res;
   /* res = (v0 x v1) . v */
   p[0]=v0[1]*v1[2]-v0[2]*v1[1];
   p[1]=v0[2]*v1[0]-v0[0]*v1[2];
   p[2]=v0[0]*v1[1]-v0[1]*v1[0];
   res1=p[0]*v[0]+p[1]*v[1]+p[2]*v[2];
   /* res = (v1 x v2) . v */
   p[0]=v1[1]*v2[2]-v1[2]*v2[1];
   p[1]=v1[2]*v2[0]-v1[0]*v2[2];
   p[2]=v1[0]*v2[1]-v1[1]*v2[0];
   res2=p[0]*v[0]+p[1]*v[1]+p[2]*v[2];
   /* res = (v2 x v0) . v */
   p[0]=v2[1]*v0[2]-v2[2]*v0[1];
   p[1]=v2[2]*v0[0]-v2[0]*v0[2];
   p[2]=v2[0]*v0[1]-v2[1]*v0[0];
   res3=p[0]*v[0]+p[1]*v[1]+p[2]*v[2];
   res=0;
   if ((res1>0)&&(res2>0)&&(res3>0)) {
      res=1;
   }
   return res;
}

int ak_radec2htm(double ra,double dec,int niter,char *htm)
/****************************************************************************/
/* Retourne le code Hierarchical Triangle Mesh.                             */
/****************************************************************************/
/****************************************************************************/
{
   int k,res,iter;
   double v[4],vv0[4],vv1[4],vv2[4],vv3[4],vv4[4],vv5[4];
   double vx0[4],vx1[4],vx2[4];
   double *v0,*v1,*v2;
   double w0[4],w1[4],w2[4];
   double w;
   v[0]=cos(ra)*cos(dec);
   v[1]=sin(ra)*cos(dec);
   v[2]=sin(dec);
   vv0[0]=0.;
   vv0[1]=0.;
   vv0[2]=1.;
   vv1[0]=1.;
   vv1[1]=0.;
   vv1[2]=0.;
   vv2[0]=0.;
   vv2[1]=1.;
   vv2[2]=0.;
   vv3[0]=-1.;
   vv3[1]=0.;
   vv3[2]=0.;
   vv4[0]=0.;
   vv4[1]=-1.;
   vv4[2]=0.;
   vv5[0]=0.;
   vv5[1]=0.;
   vv5[2]=-1.;
   /* === identification du premier noeud */
   v0=vv1;
   v1=vv5;
   v2=vv2;
   for (k=1;k<=8;k++) {
      if (k==1) {
         htm[0]='S';htm[1]='0';
         v0=vv1;
         v1=vv5;
         v2=vv2;
      }
      if (k==2) {
         htm[0]='S';htm[1]='1';
         v0=vv2;
         v1=vv5;
         v2=vv3;
      }
      if (k==3) {
         htm[0]='S';htm[1]='2';
         v0=vv3;
         v1=vv5;
         v2=vv4;
      }
      if (k==4) {
         htm[0]='S';htm[1]='3';
         v0=vv4;
         v1=vv5;
         v2=vv1;
      }
      if (k==5) {
         htm[0]='N';htm[1]='0';
         v0=vv1;
         v1=vv0;
         v2=vv4;
      }
      if (k==6) {
         htm[0]='N';htm[1]='1';
         v0=vv4;
         v1=vv0;
         v2=vv3;
      }
      if (k==7) {
         htm[0]='N';htm[1]='2';
         v0=vv3;
         v1=vv0;
         v2=vv2;
      }
      if (k==8) {
         htm[0]='N';htm[1]='3';
         v0=vv2;
         v1=vv0;
         v2=vv1;
      }
      res=ak_htm_testin(v0,v1,v2,v);
      if (res==1) {
         break;
      }
   }
   /* === identification des noeuds suivants */
   for (iter=1;iter<=niter;iter++) {
      for (k=0;k<3;k++) { vx0[k]=v0[k]; }
      for (k=0;k<3;k++) { vx1[k]=v1[k]; }
      for (k=0;k<3;k++) { vx2[k]=v2[k]; }
      /* --- vecteurs w0,w1,w2 */
      for (w=0.,k=0;k<3;k++) { w0[k]=vx1[k]+vx2[k]; w+=(w0[k]*w0[k]); }
      for (k=0;k<3;k++) { w0[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w1[k]=vx0[k]+vx2[k]; w+=(w1[k]*w1[k]); }
      for (k=0;k<3;k++) { w1[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w2[k]=vx0[k]+vx1[k]; w+=(w2[k]*w2[k]); }
      for (k=0;k<3;k++) { w2[k]/=sqrt(w); }
      /* --- boucle sur les 4 triangles */
      for (k=1;k<=4;k++) {
         if (k==1) {
            htm[1+iter]='0';
            v0=vx0;
            v1=w2;
            v2=w1;
         }
         if (k==2) {
            htm[1+iter]='1';
            v0=vx1;
            v1=w0;
            v2=w2;
         }
         if (k==3) {
            htm[1+iter]='2';
            v0=vx2;
            v1=w1;
            v2=w0;
         }
         if (k==4) {
            htm[1+iter]='3';
            v0=w0;
            v1=w1;
            v2=w2;
         }
         res=ak_htm_testin(v0,v1,v2,v);
         if (res==1) {
            break;
         }
      }
   }
   return 0;
}

int ak_htm2radec(char *htm,double *ra,double *dec,int *niter,double *ra0,double *dec0,double *ra1,double *dec1,double *ra2,double *dec2)
/****************************************************************************/
/* Retourne le ra,dec a paertir du code Hierarchical Triangle Mesh.         */
/****************************************************************************/
/*
set radec [ak_htm2radec N3300] ; ak_radec2htm [lindex $radec 0] [lindex $radec 1] [lindex $radec 2]
*/
/****************************************************************************/
{
   int k,iter;
   double v[4],vv0[4],vv1[4],vv2[4],vv3[4],vv4[4],vv5[4];
   double vx0[4],vx1[4],vx2[4];
   double *v0,*v1,*v2;
   double w0[4],w1[4],w2[4];
   double w,twopi;
   int n;
   n=(int)strlen(htm);
   vv0[0]=0.;
   vv0[1]=0.;
   vv0[2]=1.;
   vv1[0]=1.;
   vv1[1]=0.;
   vv1[2]=0.;
   vv2[0]=0.;
   vv2[1]=1.;
   vv2[2]=0.;
   vv3[0]=-1.;
   vv3[1]=0.;
   vv3[2]=0.;
   vv4[0]=0.;
   vv4[1]=-1.;
   vv4[2]=0.;
   vv5[0]=0.;
   vv5[1]=0.;
   vv5[2]=-1.;
   /* === identification du premier noeud */
   v0=vv1;
   v1=vv5;
   v2=vv2;
      if ((htm[0]=='S')&&(htm[1]=='0')) {
         v0=vv1;
         v1=vv5;
         v2=vv2;
      }
      if ((htm[0]=='S')&&(htm[1]=='1')) {
         v0=vv2;
         v1=vv5;
         v2=vv3;
      }
      if ((htm[0]=='S')&&(htm[1]=='2')) {
         v0=vv3;
         v1=vv5;
         v2=vv4;
      }
      if ((htm[0]=='S')&&(htm[1]=='3')) {
         v0=vv4;
         v1=vv5;
         v2=vv1;
      }
      if ((htm[0]=='N')&&(htm[1]=='0')) {
         v0=vv1;
         v1=vv0;
         v2=vv4;
      }
      if ((htm[0]=='N')&&(htm[1]=='1')) {
         v0=vv4;
         v1=vv0;
         v2=vv3;
      }
      if ((htm[0]=='N')&&(htm[1]=='2')) {
         v0=vv3;
         v1=vv0;
         v2=vv2;
      }
      if ((htm[0]=='N')&&(htm[1]=='3')) {
         v0=vv2;
         v1=vv0;
         v2=vv1;
      }
   /* === identification des noeuds suivants */
   *niter=n-2;
   for (iter=1;iter<=*niter;iter++) {
      for (k=0;k<3;k++) { vx0[k]=v0[k]; }
      for (k=0;k<3;k++) { vx1[k]=v1[k]; }
      for (k=0;k<3;k++) { vx2[k]=v2[k]; }
      /* --- vecteurs w0,w1,w2 */
      for (w=0.,k=0;k<3;k++) { w0[k]=vx1[k]+vx2[k]; w+=(w0[k]*w0[k]); }
      for (k=0;k<3;k++) { w0[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w1[k]=vx0[k]+vx2[k]; w+=(w1[k]*w1[k]); }
      for (k=0;k<3;k++) { w1[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w2[k]=vx0[k]+vx1[k]; w+=(w2[k]*w2[k]); }
      for (k=0;k<3;k++) { w2[k]/=sqrt(w); }
      /* --- boucle sur les 4 triangles */
         if (htm[1+iter]=='0') {
            v0=vx0;
            v1=w2;
            v2=w1;
         }
         if (htm[1+iter]=='1') {
            v0=vx1;
            v1=w0;
            v2=w2;
         }
         if (htm[1+iter]=='2') {
            v0=vx2;
            v1=w1;
            v2=w0;
         }
         if (htm[1+iter]=='3') {
            v0=w0;
            v1=w1;
            v2=w2;
         }
   }
   v[0]=(v0[0]+v1[0]+v2[0])/3.;
   v[1]=(v0[1]+v1[1]+v2[1])/3.;
   v[2]=(v0[2]+v1[2]+v2[2])/3.;
   twopi=8*atan(1.);
   *dec=asin(v[2]);
   *ra=atan2(v[1],v[0]); if (*ra<0.) *ra+=(twopi);
   *dec0=asin(v0[2]);
   *ra0=atan2(v0[1],v0[0]); if (*ra0<0.) *ra0+=(twopi);
   *dec1=asin(v1[2]);
   *ra1=atan2(v1[1],v1[0]); if (*ra1<0.) *ra1+=(twopi);
   *dec2=asin(v2[2]);
   *ra2=atan2(v2[1],v2[0]); if (*ra2<0.) *ra2+=(twopi);
   return 0;
}


void ak_date2jd(double annee, double mois, double jour, double heure, double minute, double seconde, double *jj)
/***************************************************************************/
/* Donne le jour juliene correspondant a la date                           */
/***************************************************************************/
/***************************************************************************/
{
   double a,m,j,aa,bb,jd;
   a=annee;
   m=mois;
   j=jour+((((seconde/60.)+minute)/60.)+heure)/24.;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   *jj=jd;
}

int ak_util_qsort_double(double *x,int kdeb,int n,int *index)
/***************************************************************************/
/* Quick sort pour un tableau de double                                    */
/***************************************************************************/
/* x est le tableau qui commence a l'indice 1                              */
/* kdeb la valeur de l'indice a partir duquel il faut trier                */
/* n est le nombre d'elements                                              */
/* index est le tableau des indices une fois le tri effectue (=NULL si on  */
/*  ne veut pas l'utiliser).                                               */
/***************************************************************************/
{
   double qsort_r[AK_QSORT],qsort_l[AK_QSORT];
   int s,l,r,i,j,kfin;
   double v,w;
   int wi;
   int kt1,kt2,kp;
   double m,a;
   int mi,ai;
   kfin=n+kdeb-1;
   /* --- retour immediat si n==1 ---*/
   if (n==1) { return(0); }
   if (index!=NULL) {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
	 for (kt1=kdeb;kt1<kfin;kt1++) {
	    m=x[kt1];
	    mi=index[kt1];
	    kp=kt1;
	    for (kt2=kt1+1;kt2<=kfin;kt2++) {
	       if (x[kt2]<m) {
		  m=x[kt2];
		  mi=index[kt2];
		  kp=kt2;
	       }
	    }
	    a=x[kt1];x[kt1]=m;x[kp]=a;
	    ai=index[kt1];index[kt1]=mi;index[kp]=ai;
	 }
	 return(0);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[ak_util_qsort_verif(kdeb)]=kdeb; qsort_r[ak_util_qsort_verif(kdeb)]=kfin;
      do {
	 l=(int)(qsort_l[ak_util_qsort_verif(s)]); r=(int)(qsort_r[ak_util_qsort_verif(s)]);
	 s=s-1;
	 do {
	    i=l; j=r;
	    v=x[(int) (floor((double)(l+r)/(double)2))];
	    do {
	       while (x[i]<v) {i++;}
	       while (v<x[j]) {j--;}
	       if (i<=j) {
		  w=x[i];x[i]=x[j];x[j]=w;
		  wi=index[i];index[i]=index[j];index[j]=wi;
		  i++; j--;
	       }
	    } while (i<=j);
	    if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[ak_util_qsort_verif(s)]=i ; qsort_r[ak_util_qsort_verif(s)]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[ak_util_qsort_verif(s)]=l ; qsort_r[ak_util_qsort_verif(s)]=j;} l=i; }
	 } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(0);
   } else {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
	 for (kt1=kdeb;kt1<kfin;kt1++) {
	    m=x[kt1];
	    kp=kt1;
	    for (kt2=kt1+1;kt2<=kfin;kt2++) {
	       if (x[kt2]<m) {
		  m=x[kt2];
		  kp=kt2;
	       }
	    }
	    a=x[kt1];x[kt1]=m;x[kp]=a;
	 }
	 return(0);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[ak_util_qsort_verif(kdeb)]=kdeb; qsort_r[ak_util_qsort_verif(kdeb)]=kfin;
      do {
	 l=(int)(qsort_l[ak_util_qsort_verif(s)]); r=(int)(qsort_r[ak_util_qsort_verif(s)]);
	 s=s-1;
	 do {
	    i=l; j=r;
	    v=x[(int) (floor((double)(l+r)/(double)2))];
	    do {
	       while (x[i]<v) {i++;}
	       while (v<x[j]) {j--;}
	       if (i<=j) {
		  w=x[i];x[i]=x[j];x[j]=w;
		  i++; j--;
	       }
	    } while (i<=j);
	    if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[ak_util_qsort_verif(s)]=i ; qsort_r[ak_util_qsort_verif(s)]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[ak_util_qsort_verif(s)]=l ; qsort_r[ak_util_qsort_verif(s)]=j;} l=i; }
	 } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(0);
   }
}

int ak_util_qsort_verif(int index)
/***************************************************************************/
/* Verifie que l'indice ne depasse pas le seuil maximal pour qsort_*       */
/***************************************************************************/
{
   static int indexout;
   if (index>=(int)(AK_QSORT)) {
	   index=(int)(AK_QSORT-1);
	}
   if (index<0) {
	   index=0;
	}
   indexout=index;
   return indexout;
}

int ak_util_meansigma(double *x,int kdeb,int n,double *mean,double *sigma)
/***************************************************************************/
/* Calcule moyenne et ecart type d'un vecteur.                             */
/***************************************************************************/
{
   int j=0,k;
   double i=0.,mu_i=0.,mu_ii=0.,sx_i=0.,sx_ii=0.,delta,val;
   /* --- algo de la valeur moy et ecart type de Miller ---*/
   for (k=kdeb;k<=kdeb+n-1;k++) {
      val=x[k];
      j++;
      if (j==1) {mu_i=val;}
      i=(double) (j+1-1);
      delta=val-mu_i;
      mu_ii=mu_i+delta/(i);
      sx_ii=sx_i+delta*(val-mu_ii);
      mu_i=mu_ii;
      sx_i=sx_ii;
   }
   *mean=mu_ii;
   *sigma=0.;
   /*Modif Yassine: pour avoir la meme chose que matlab
   if (i!=0.) {
      *sigma=sqrt(sx_ii/i);
   }*/
   if (i>1.) {
      *sigma=sqrt(sx_ii/(i-1));
   }
   /*fin*/
   return 0;
}

