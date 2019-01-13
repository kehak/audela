/* tt_seri5.c
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

int tt_ima_series_catchart_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Cree une carte a partir des donnees des images                          */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* path_astromcatalog :                                                    */
/* astromcatalog : "USNO.RA" pour designer le USNO reduit                  */
/* objefile= nom du fichier fits qui enregistre la liste des objets.       */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index,msg,passe;
   char *path_astromcatalog,*astromcatalog;
   char file[FLEN_FILENAME];
   char message[TT_MAXLIGNE],usnozone[10];
   int naxis1,naxis2;
   double ra,dec;
   TT_ASTROM p;
   float mipslo,mipshi;
   int *num_ligne,scan,k,kk;
   char **num_zone;
   FILE *fichier;
   int offset,nbstars,nbz,len,nbe,typecat;
   double magi=0.,magr=0.,magv=0.,magb=0.,x,y;
   usnocomptype etoile_usnocomp;
   usnotype etoile_usno;
   unsigned long iy,ix;
   int qualite,color_space,k0,k1,kk0,kk1,rayon;
   char value_char[FLEN_VALUE];
   unsigned char *pjpeg;
   time_t ltime;
   int taille,nombre;
   char * retour_char;
   int retour_int;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   astromcatalog=pseries->astromcatalog;
   path_astromcatalog=pseries->path_astromcatalog;

   /* --- choix du catalogue ---*/
   tt_strupr(astromcatalog);
   if (strcmp(astromcatalog,"USNO")==0) { typecat=TT_USNO; }
   else { typecat=TT_USNOCOMP;}

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   /* --- parametres par defaut ---*/
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;

   /* --- recherche des parametres de la projection dans l'entete ---*/
   tt_util_getkey_astrometry(p_in,&p);

   /* --- calcule les zones a couvrir ---*/
   /* --- calcule le nombre de points a calculer (9 + 1 tous les degres) ---*/
   nbz=9;
   nbz+=(int)(ceil(p.cdelta1*naxis1)*ceil(p.cdelta2*naxis2));
   len=5;
   num_zone=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,3,&num_zone,&nbz,&len))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_1 (pointer num_zone)");
      return(TT_ERR_PB_MALLOC);
   }
   taille=sizeof(int);
   num_ligne=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&num_ligne,&nbz,&taille,"num_ligne"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_1 (pointer num_ligne)");
      tt_util_free_ptrptr2((void***)&num_zone,"num_zone");
      return(TT_ERR_PB_MALLOC);
   }
   tt_util_astrom_xy2radec(&p,(double)(0),(double)(0),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[0],&num_ligne[0]);
   tt_util_astrom_xy2radec(&p,(double)(naxis1/2),(double)(0),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[1],&num_ligne[1]);
   tt_util_astrom_xy2radec(&p,(double)(naxis1),(double)(0),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[2],&num_ligne[2]);
   tt_util_astrom_xy2radec(&p,(double)(0),(double)(naxis2/2),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[3],&num_ligne[3]);
   tt_util_astrom_xy2radec(&p,(double)(naxis1/2),(double)(naxis2/2),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[4],&num_ligne[4]);
   tt_util_astrom_xy2radec(&p,(double)(naxis1),(double)(naxis2/2),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[5],&num_ligne[5]);
   tt_util_astrom_xy2radec(&p,(double)(0),(double)(naxis2),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[6],&num_ligne[6]);
   tt_util_astrom_xy2radec(&p,(double)(naxis1/2),(double)(naxis2),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[7],&num_ligne[7]);
   tt_util_astrom_xy2radec(&p,(double)(naxis1),(double)(naxis2),&ra,&dec);
   tt_util_astrom_zoneusno(ra,dec,num_zone[8],&num_ligne[8]);
   if (typecat==TT_USNO) { strcpy(usnozone,"zone"); }
   else { strcpy(usnozone,"zon"); }
   for (passe=1;passe<=2;passe++) {
      nbe=0;
      for (k=0;k<nbz;k++) {
	 /*printf("=== zone[%d]=%s ligne[%d]=%d\n",k,num_zone[k],k,num_ligne[k]);*/
	 if (atoi(num_zone[k])==0) {
	    continue;
	 }
	 scan=TT_YES;
	 for (kk=0;kk<k;kk++) {
	    if ((strcmp(num_zone[kk],num_zone[k])==0)&&(num_ligne[kk]==num_ligne[k])) {
	       scan=TT_NO;
	       break;
	    }
	 }
	 if (scan==TT_YES) {
	    /* --- genere la liste ---*/
	    sprintf(file,"%s%s%s.acc",path_astromcatalog,usnozone,num_zone[k]);
	    if ((fichier=fopen(file,"rt") ) == NULL) {
	       sprintf(message,"File %s from USNO catalog not found\n",file);
	       tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
	       tt_util_free_ptrptr2((void***)&num_zone,"num_zone");
	       tt_free2((void**)&num_ligne,"num_ligne");
	       return(TT_ERR_FILE_NOT_FOUND);
	    }
	    for (kk=0;kk<num_ligne[k]-1;kk++) {
	       retour_char = fgets(message,TT_MAXLIGNE,fichier);
	    }
	    strcpy(message,"");
	    retour_char = fgets(message,TT_MAXLIGNE,fichier);
#ifdef OS_LINUX_GCC_SO
	    sscanf(message,"%lf %d %d",&dvalue,&offset,&nbstars);
#else
	    sscanf(message,"%lf %ld %ld",&dvalue,&offset,&nbstars);
#endif
	    fclose(fichier);
	    sprintf(file,"%s%s%s.cat",path_astromcatalog,usnozone,num_zone[k]);
	    if ((fichier=fopen(file,"rb") ) == NULL) {
	       sprintf(message,"File %s from USNO catalog not found\n",file);
	       tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
	       tt_util_free_ptrptr2((void***)&num_zone,"num_zone");
	       tt_free2((void**)&num_ligne,"num_ligne");
	       return(TT_ERR_FILE_NOT_FOUND);
	    }
	    offset-=1;
	    if (typecat==TT_USNO) {
	       fseek(fichier,(long)(offset*sizeof(etoile_usno)),SEEK_SET);
	    } else {
	       /*fseek(fichier,(long)(offset*sizeof(etoile_usnocomp)),SEEK_SET);*/
	       fseek(fichier,(long)(offset*10),SEEK_SET);
	    }
	    for (kkk=0;kkk<nbstars;kkk++) {
	       if (typecat==TT_USNO) {
		  retour_int = fread(&etoile_usno,sizeof(etoile_usno),1,fichier);
		  tt_util_uswapbytes(&etoile_usno.ra,1);
		  tt_util_uswapbytes(&etoile_usno.dec,1);
		  tt_util_uswapbytes(&etoile_usno.divers,1);
		  ra=(double)(etoile_usno.ra)/(3600.*100);
		  dec=(double)(etoile_usno.dec)/(3600.*100)-90.;
		  iy=etoile_usno.divers;
		  ix=(unsigned long)((double)(iy)/1000)*1000;
		  magr=(iy-ix)/10.;
		  iy=iy/1000;
		  ix=(unsigned long)((double)(iy)/1000)*1000;
		  magb=(iy-ix)/10.;
	       } else {
		  /*fread(&etoile_usnocomp,sizeof(usnocomptype),1,fichier);*/
		  retour_int = fread(&etoile_usnocomp,10,1,fichier);
		  ra=(double)(etoile_usnocomp.ra)/(3600.*100);
		  dec=(double)(etoile_usnocomp.dec)/(3600.*100)-90.;
		  magr=(double)(etoile_usnocomp.magr)/10.-3.;
		  magb=(double)(etoile_usnocomp.magb)/10.-3.;
		  /* --- revoir les deux formules suivantes ---*/
		  magv=(magb+magr)/2.;
		  magi=magr;
	       }
	       /*printf("[%s %d %d/%d] ra=%f dec=%f magr=%f\n",num_zone[k],num_ligne[k],kkk,nbstars,ra,dec,magr);*/
	       tt_util_astrom_radec2xy(&p,ra/(180/(TT_PI)),dec/(180/(TT_PI)),&x,&y);
	       if ((x>=0)&&(x<naxis1)&&(y>=0)&&(y<naxis1)) {
		  if (passe==2) {
		     p_out->catalist->x[nbe]=(double)(x);
		     p_out->catalist->y[nbe]=(double)(y);
		     p_out->catalist->ra[nbe]=(double)(ra);
		     p_out->catalist->dec[nbe]=(double)(dec);
		     p_out->catalist->ident[nbe]=(short)(TT_STAR);
		     p_out->catalist->magb[nbe]=(double)(magb);
		     p_out->catalist->magv[nbe]=(double)(magv);
		     p_out->catalist->magr[nbe]=(double)(magr);
		     p_out->catalist->magi[nbe]=(double)(magi);
		  }
		  nbe++;
	       }
	    }
     	    fclose(fichier);
	 }
      }
      if (passe==1) {
	 if (nbe==0) {
	    tt_tblcatcreater(p_out->catalist,1);
	 } else {
	    tt_tblcatcreater(p_out->catalist,nbe);
	 }
      } else {
         if (nbe==0) {
	    p_out->catalist->x[nbe]=(double)(0.);
	    p_out->catalist->y[nbe]=(double)(0.);
	    p_out->catalist->ra[nbe]=(double)(0.);
	    p_out->catalist->dec[nbe]=(double)(0.);
	    p_out->catalist->ident[nbe]=(short)(TT_STAR);
	    p_out->catalist->magb[nbe]=(double)(0.);
	    p_out->catalist->magv[nbe]=(double)(0.);
	    p_out->catalist->magr[nbe]=(double)(0.);
	    p_out->catalist->magi[nbe]=(double)(0.);
	    nbe=1;
         }
      }
   }

   tt_util_free_ptrptr2((void***)&num_zone,"num_zone");
   tt_free2((void**)&num_ligne,"num_ligne");

   /* --- calcul de l'image de sortie ---*/
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- Calcul des parametres de fond de ciel ---*/
   tt_util_statima(p_out,TT_MAX_DOUBLE,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
   tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
   tt_imanewkey(p_out,"BGMEAN",&(pseries->bgmean),TDOUBLE,"mean value for background pixels","adu");
   tt_imanewkey(p_out,"BGSIGMA",&(pseries->bgsigma),TDOUBLE,"std sigma value for background pixels","adu");

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_cuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);
   mipshi=(float)(pseries->hicut);
   mipslo=(float)(pseries->locut);
   tt_imanewkey(p_out,"MIPS-HI",&(mipshi),TFLOAT,"High cut for visualisation for MiPS","adu");
   tt_imanewkey(p_out,"MIPS-LO",&(mipslo),TFLOAT,"Low cut for visualisation for MiPS","adu");

   /* --- Calcul des parametres de projection ---*/
   tt_util_putnewkey_astrometry(p_out,&p);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   /* --- calcul de l'image jpeg en couleur ---*/
   if ((pseries->jpegfile_chart_make==TT_NO)||(strcmp(pseries->jpegfile_chart,"")==0)) {
      return(OK_DLL);
   }
   naxis1=p_out->naxis1;
   naxis2=p_out->naxis2;
   color_space=JCS_RGB;
   qualite=(int)pseries->jpeg_qualite;
   if (qualite>100) {qualite=100;}
   if (qualite<5) {qualite=5;}
   pjpeg=NULL;
   nombre=3*naxis1*naxis2;
   taille=sizeof(unsigned char);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pjpeg,&nombre,&taille,"pjpeg"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_1 (pointer jpeg)");
      return(TT_ERR_PB_MALLOC);
   }
   for (k=0;k<(nbe+0);k++) {
      if (k<nbe) {
	 x=p_out->catalist->x[k];
	 y=naxis2-1-p_out->catalist->y[k];
	 magb=p_out->catalist->magb[k];
	 magv=p_out->catalist->magv[k];
	 magr=p_out->catalist->magr[k];
	 magi=p_out->catalist->magi[k];
      }
      if (k==nbe) {
	 ra=p.ra0;
	 dec=p.dec0;
	 tt_util_astrom_radec2xy(&p,ra,dec,&x,&y);
	 y=naxis2-1-y;
	 magr=99;
	 magv=0;
	 magb=99;
      }
      k0=(int)(x);
      k1=(int)(y);
      if (k0<0) {k0=0;} if (k0>=naxis1) {k0=naxis1-1;}
      if (k1<0) {k1=0;} if (k1>=naxis2) {k1=naxis2-1;}
      /* 255 pour mag8 => 1 pour mag16 */
      dvalue=(16-magr)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
      magr=dvalue;
      dvalue=(16-magv)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
      magv=dvalue;
      dvalue=(16-magb)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
      magb=dvalue;
      rayon=5;
      for (kk0=k0-rayon;kk0<=k0+rayon;kk0++) {
	 for (kk1=k1-rayon;kk1<=k1+rayon;kk1++) {
	    dvalue=(kk0-x)*(kk0-x)+(kk1-y)*(kk1-y);
	    if (dvalue<=rayon) {
	       if ((kk0>=0)&&(kk0<naxis1)&&(kk1>=0)&&(kk1<naxis2)) {
		  pjpeg[3*(naxis1*kk1+kk0)+0]=(unsigned char)(magr); /* rouge */
		  pjpeg[3*(naxis1*kk1+kk0)+1]=(unsigned char)(magv); /* vert */
		  pjpeg[3*(naxis1*kk1+kk0)+2]=(unsigned char)(magb); /* bleu */
	       }
	    }
	 }
      }
      /*--- indice de x,y dans le pointeur image FITS ---*/
      /*p_out->p[kk=xmax*y+x];*/
   }
   /* --- enregistrement de l'image RGB en format JPEG --- */
   if ((msg=libfiles_main(FS_MACR_WRITE_JPG,6,pseries->jpegfile_chart,&color_space,
    pjpeg,&naxis1,&naxis2,&qualite))!=0) {
       return(msg);
   }

   /* --- Parametres des listes de pixels et d'objets ---*/
   time( &ltime );
   strftime(value_char,FLEN_VALUE,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
   srand( (unsigned)time( NULL ) );
   if (pseries->catalog_list==TT_YES) {
      sprintf(pseries->p_out->catakey,"%s:%d",value_char,rand());
      tt_imanewkey(p_out,"CATAKEY",pseries->p_out->catakey,TSTRING,"Link key for catafile","");
      if (strcmp(pseries->catafile,"")!=0) {
	 strcpy(pseries->p_out->catalist_fullname,pseries->catafile);
      }
   }

   /* --- on libere le pointeur d'image jpeg---*/
   tt_free2((void**)&pjpeg,"pjpeg");
   msg=OK_DLL;
   return(msg);
}

int tt_catchart_idx(int index,int nelem) {
	if (index>=nelem) {
		/*printf("Depassement de pointeur %d>=%d\n",index,nelem);*/
		index=nelem-1;
	}
	if (index<0) {
		/*printf("Depassement de pointeur %d<0\n",index);*/
		index=0;
	}
	return index;
}

int tt_ima_series_catchart_2(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Cree une carte a partir des donnees des images                          */
/* version Buil de tt_ima_series_catchart_1                                */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* path_astromcatalog :                                                    */
/* astromcatalog : "USNO.RA" pour designer le USNO reduit                  */
/* objefile= nom du fichier fits qui enregistre la liste des objets.       */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kk,kkk,index,msg,nn;
   char *path_astromcatalog,*astromcatalog,message[TT_MAXLIGNE];
   int naxis1,naxis2;
   double dec;
   TT_ASTROM p;
   float mipslo,mipshi;
   int k;
   int nbe,typecat;
   double magi,magr=0.,magv=0.,magb=0.,x,y;
   int qualite,color_space,k0,k1,kk0,kk1,rayon;
   char value_char[FLEN_VALUE],ligne[TT_MAXLIGNE],texte[TT_MAXLIGNE];
   unsigned char *pjpeg;
   time_t ltime;
   int taille,nombre;
   double XXXmin,XXXmax,YYYmin,YYYmax;
	int nl=20,nk=500,lambdamax=10,kmax=50;
	double *repartitionps;
	int simulimage,nrep=10000;
	double *repartitions,gain,pi,f_sky;
   double fo,lambda,dlambda,f_Jy,f,teldiam,exposure,quantum_efficiency;
	double fwhmx,fwhmy,sigx,sigy,f_pic,sigx2,sigy2;
	int rayonx,rayony;
	double sigmax=5,sky_brightness,omega,readout_noise;
	double signal_star,noise_star,signal_readout;
	double signal_sky,noise_sky,noise_readout;
	char colfilters[]="UBVRIJHKgriz";
	double lambdas[]={0.36, 0.44, 0.55, 0.64, 0.79, 1.26, 1.60, 2.22, 0.52, 0.67, 0.79, 0.91};
	double dlambdas[]={0.15, 0.22, 0.16, 0.23, 0.19, 0.16, 0.23, 0.23, 0.14, 0.14, 0.16, 0.13};
	double fos[]={1810, 4260, 3640, 3080, 2550, 1600, 1080, 670, 3730, 4490, 4760, 4810};
	int shuttermode=1; // 0=CLOSED (filter=DARK) 1=SYNCHRO
	double tatm,topt,elecmult,rayon2,flimit,fex;
   /* --- ajout Buil */
   char name[FLEN_FILENAME];
   double alpha1;
   double alpha2;
   double delta2;
   double delta1;
   double v,r;
   double l_alpha,l_delta;
   double lx,ly;
   double Trad=TT_PI/180.0;
   double Tdeg=180.0/TT_PI;
   FILE *out_file;
   int compteur=0,compteur_tyc=0;
   double ra,de,mag_red,mag_bleue;
   double dalpha,ddelta,dalpha2;
   int indexSPD,indexRA;
   TT_USNO_INDEX *p_index;
   int i,j,first,flag;
   char nom[FLEN_FILENAME];
   FILE *acc,*cat;
   char buf_acc[31];
   int offset,nbObjects;
   int raL,deL,magL;
   double XXX,YYY,rienf;
   int bordurex=0,bordurey=0;
   int np_index=0;
	double newstar_ra,newstar_dec,newstar_mag,newstar_x,newstar_y;
   /*
   double sind0;
   double cosd0;
   double sind,X,Y;
   double cosd;
   double a;
   double d;
   double H;
   double focale_x,focale_y;
   */
   double ppx,ppy;
   unsigned char tmr,tmb;
   double a0,focale,dim_pixel_x,dim_pixel_y,d0;
   int nb_pixel_x,nb_pixel_y;
   char slash[2];
   double magrlim,magblim;
	int type_objet=1;

   /* --- intialisations ---*/
#ifdef FILE_DOS
   strcpy(slash,"\\");
#endif
#ifdef FILE_UNIX
   strcpy(slash,"/");
#endif
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   magrlim=pseries->magrlim;
   magblim=pseries->magblim;
   astromcatalog=pseries->astromcatalog;
   path_astromcatalog=pseries->path_astromcatalog;
	simulimage=pseries->simulimage; /* 0=normal 1=clear the image and replace it by a simulated image */

   /* ajout d'un separateur a la fin du chemin s'il le separateur est absent */
   if ( strlen(path_astromcatalog) > 0 ) {
	   if ( path_astromcatalog[strlen(path_astromcatalog)-1] != slash[0] ) {
		   strcat(path_astromcatalog,slash);
	   }
   }

   /* --- choix du catalogue ---*/
   tt_strupr(astromcatalog);
   if (strcmp(astromcatalog,"USNO")==0) { typecat=TT_USNO; }
   else if (strcmp(astromcatalog,"MICROCAT")==0) { typecat=TT_USNOCOMP; }
   else { typecat=TT_USNOPERSO;}

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   /* --- parametres par defaut ---*/
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;

   /* --- recherche des parametres de la projection dans l'entete ---*/
   tt_util_getkey_astrometry(p_in,&p);

   /* --- debut de l'algo de Christian ---*/
   /*
   a0=p.crval1*180./TT_PI;
   d0=p.crval2*180./TT_PI;
   */
   tt_util_astrom_xy2radec(&p,0.5*naxis1,0.5*naxis2,&a0,&d0);
   a0=a0*180./TT_PI;
   d0=d0*180./TT_PI;
   if (fabs(p.foclen)<=TT_EPS_DOUBLE) {
      p.px=10e-6; /* 10 microns arbitraire */
      p.py=p.px*fabs(p.cdelta2/p.cdelta1);
      p.foclen=fabs(p.px/2./tan(p.cdelta1/2.));
   }
   /* conversion en mm */
   focale=p.foclen*1e3;
   dim_pixel_x=p.px*1e3;
   dim_pixel_y=p.py*1e3;

   nb_pixel_x=naxis1;
   nb_pixel_y=naxis2;

   /*=== alpha en heures ===*/
   a0=a0/15.0;

   /* On calcul les bornes en alpha du champ
   Les bornes de recherches dependent du lieu dans le ciel ainsi que
   le rayon du champ */
   if (d0==90.0) d0=89.9999;
   if (d0==-90.0) d0=-89.9999;

   lx=(double)nb_pixel_x*dim_pixel_x;
   ly=(double)nb_pixel_y*dim_pixel_y;
   l_alpha=2.0*atan(lx/focale/2.0)*Tdeg;
   l_delta=2.0*atan(ly/focale/2.0)*Tdeg;

   r=l_alpha/2.0;
   v=sin(r*Trad)/cos(d0*Trad);
   if (v>=1.0) {
      /* Si le pole est dans le champ alors on lit de 0 a 24 heures */
      alpha1=0.0;
      alpha2=23.99999999;
   } else {
      /* Si le pole n'est pas dans le champ */
      v=asin(v);
      v*=Tdeg/15.0;
      alpha1=a0-v;
      alpha2=a0+v;
      if (alpha1<0.0) alpha1+=24.0;
      if (alpha2>24.0) alpha2-=24.0;
   }

   r=l_delta/2.0;
   delta2=d0+r;
   delta1=d0-r;
   if (delta2>90.0) delta2=90.0;
   if (delta1<-90.0) delta1=-90.0;

   /*=== recherche les differentes zones presentes dans l'image ===*/
   /* on est a cheval sur 0 heure */
   if (alpha1>alpha2) {
      dalpha=(23.99999999-alpha1)/97.0;
      ddelta=(delta2-delta1)/25.0;
		nombre=3000; /* nombre entier > a ce que vaudra nombre en sortie de boucle */
		taille=sizeof(TT_USNO_INDEX);
		p_index=NULL;
		if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p_index,&nombre,&taille,"p_index"))!=0) {
			tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer p_index)");
			return(TT_ERR_PB_MALLOC);
		}
      j=0;
      for (ra=alpha1;ra<=23.99999999;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[tt_catchart_idx(j++,nombre)].flag=-1;
				/*p_index[j++].flag=-1;*/
			}
		}
		dalpha2=alpha2/97.0;
		for (ra=0;ra<=alpha2;ra+=dalpha2) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[tt_catchart_idx(j++,nombre)].flag=-1;
				/*p_index[j++].flag=-1;*/
			}
		}
		nombre=j+5;
		taille=sizeof(TT_USNO_INDEX);
		tt_free2((void**)&p_index,"p_index");
		p_index=NULL;
		if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p_index,&nombre,&taille,"p_index"))!=0) {
			tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer p_index)");
			return(TT_ERR_PB_MALLOC);
		}
		i=0;
		for (ra=alpha1;ra<=23.99999999;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[i++].flag=-1;
			}
		}
		for (ra=0;ra<=alpha2;ra+=dalpha2) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[i++].flag=-1;
			}
		}

      p_index[i++].flag=-1;  // on complete pour bien borner la table
      p_index[i++].flag=-1;
      np_index=i;

      k=0;
      first=1;
      for (ra=alpha1;ra<=23.99999999;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				tt_ComputeUsnoIndexs(tt_D2R(15.0*ra),tt_D2R(de),&indexSPD,&indexRA);
				if (first==1) {
					p_index[k].flag=1;
					p_index[k].indexRA=indexRA;
					p_index[k].indexSPD=indexSPD;
					first=0;
				} else {
					flag=0;
					for (i=0;i<np_index;i++) {
						if (p_index[i].flag==-1) {
							break;
						}
						if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD) {
							flag=1;
							break;
						}
					}
					if (flag==0) {
						k++;
						p_index[k].flag=1;
						p_index[k].indexRA=indexRA;
						p_index[k].indexSPD=indexSPD;
					}
				}
			}
		}
		for (ra=0;ra<=alpha2;ra+=dalpha2) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				tt_ComputeUsnoIndexs(tt_D2R(15.0*ra),tt_D2R(de),&indexSPD,&indexRA);
				if (first==1) {
					p_index[k].flag=1;
					p_index[k].indexRA=indexRA;
					p_index[k].indexSPD=indexSPD;
					first=0;
				} else {
					flag=0;
					for (i=0;i<np_index;i++) {
						if (p_index[i].flag==-1) {
							break;
						}
						if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD) {
							flag=1;
							break;
						}
					}
					if (flag==0) {
						k++;
						p_index[k].flag=1;
						p_index[k].indexRA=indexRA;
						p_index[k].indexSPD=indexSPD;
					}
				}
			}
		}
	}
   /*=== recherche les differentes zones presentes dans l'image ===*/
   /* on n'est pas a cheval sur 0 heure */
   else {
		dalpha=(alpha2-alpha1)/97.0;
		ddelta=(delta2-delta1)/25.0;
		nombre=3000; /* nombre entier > a ce que vaudra nombre en sortie de boucle */
		taille=sizeof(TT_USNO_INDEX);
		p_index=NULL;
		if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p_index,&nombre,&taille,"p_index"))!=0) {
			tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer p_index)");
			return(TT_ERR_PB_MALLOC);
		}
		j=0;
		for (ra=alpha1;ra<=alpha2;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[tt_catchart_idx(j++,nombre)].flag=-1;
			}
		}
		nombre=j+5;
		taille=sizeof(TT_USNO_INDEX);
		tt_free2((void**)&p_index,"p_index");
		p_index=NULL;
		if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p_index,&nombre,&taille,"p_index"))!=0) {
			tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer p_index)");
			return(TT_ERR_PB_MALLOC);
		}
		i=0;
		for (ra=alpha1;ra<=alpha2;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				p_index[i++].flag=-1;
			}
		}
      p_index[i++].flag=-1;  // on complete pour bien borner la table
      p_index[i++].flag=-1;
      np_index=i;
      k=0;
      first=1;
      for (ra=alpha1;ra<=alpha2;ra+=dalpha) {
			for (de=delta1;de<=delta2;de+=ddelta) {
				tt_ComputeUsnoIndexs(tt_D2R(15.0*ra),tt_D2R(de),&indexSPD,&indexRA);
				if (first==1) {
					p_index[k].flag=1;
					p_index[k].indexRA=indexRA;
					p_index[k].indexSPD=indexSPD;
					first=0;
				} else {
					flag=0;
					for (i=0;i<np_index;i++) {
						if (p_index[i].flag==-1) {
							break;
						}
						if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD) {
							flag=1;
							break;
						}
					}
					if (flag==0) {
						k++;
						p_index[k].flag=1;
						p_index[k].indexRA=indexRA;
						p_index[k].indexSPD=indexSPD;
					}
				}
			}
		}
   }

   /* --- bordure est la zone d'exclusion au bord de l'image ---*/
   /* --- pseries->bordure s'exprime en pourcents ---*/
   if (pseries->bordure<0.) {pseries->bordure=0.; }
   if (pseries->bordure>90.) {pseries->bordure=90.; }
   bordurex=(int)(pseries->bordure/100.*p_in->naxis1/2.);
   bordurey=(int)(pseries->bordure/100.*p_in->naxis2/2.);
   XXXmin=bordurex;
   XXXmax=nb_pixel_x-bordurex;
   YYYmin=bordurey;
   YYYmax=nb_pixel_y-bordurey;

	/*=== remplacement d'une eventuelle etoile perso ===*/
	newstar_ra=pseries->ra;
	newstar_dec=pseries->dec;
	newstar_mag=pseries->mag;
	newstar_x=-100;
	newstar_y=-100;
	if (pseries->newstar!=TT_NEWSTAR_NONE) {
  		tt_util_astrom_radec2xy(&p,newstar_ra/(180/(TT_PI)),newstar_dec/(180/(TT_PI)),&XXX,&YYY);
		if (XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax) {
			newstar_x=XXX;
			newstar_y=YYY;
		} else {
			pseries->newstar=TT_NEWSTAR_NONE;
		}
	}

   /*==== ouverture d'un fichier liste ====*/
   sprintf(name,"usno%s.lst",tt_tmpfile_ext);
   if ((out_file=fopen(name,"w"))==NULL) {
      sprintf(message,"File %s cannot be created\n",name);
      tt_errlog(pseries->tmp_dir,TT_ERR_FILE_CANNOT_BE_WRITED,message);
      tt_free2((void**)&p_index,"p_index");
      return(PB_DLL);
   }

   /*==== balayage des fichiers des catalogues .CAT ====*/

   a0*=15.0*Trad;
   d0*=Trad;
   j=0;
   compteur=0;
   compteur_tyc=0;

   /* ===================================================== */
   /* = On effectue ici le balayage sur le TYCHO et GSC   = */
   /* ===================================================== */
   if (typecat==TT_USNOCOMP) {
      /* TYCHO */
      /*=== balayage des zones trouvees .ACC ===*/
		for (k=0;k<np_index;k++) {
			if (p_index[k].flag==-1) {
				break;
			}
			sprintf(nom,"%styc%sZON%04d.ACC",path_astromcatalog,slash,p_index[k].indexSPD*75);
         if ((acc=fopen(nom,"r"))==NULL) {
            sprintf(message,"File %s from USNO catalog not found\n",nom);
				tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
				fclose(out_file);
				tt_free2((void**)&p_index,"p_index");
				return(PB_DLL);
			}
         /*=== on lit 30 caracteres dans le fichier .acc ===*/
         for (i=0;i<=p_index[k].indexRA;i++) {
				if (fread(buf_acc,1,30,acc)!=30) break;
         }
#ifdef OS_LINUX_GCC_SO
			sscanf(buf_acc,"%lf %d %d",&rienf,&offset,&nbObjects);
#else
			sscanf(buf_acc,"%lf %ld %ld",&rienf,&offset,&nbObjects);
#endif
         if (typecat==TT_USNO) { offset=(offset-1)*12; }
         else { offset=(offset-1)*10; }
         p_index[k].offset=offset;
         p_index[k].nbObjects=nbObjects;
         fclose(acc);
      }
      /*==== balayage des fichiers de catalogue .CAT ====*/
		for (k=0;k<np_index;k++) {
			if (p_index[k].flag==-1) {
				break;
			}
         sprintf(nom,"%styc%sZON%04d.CAT",path_astromcatalog,slash,p_index[k].indexSPD*75);
         if ((cat=fopen(nom,"rb"))==NULL) {
				sprintf(message,"File %s not found\n",nom);
				tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
				fclose(out_file);
				tt_free2((void**)&p_index,"p_index");
				return(PB_DLL);
         }
         /* deplacement sur la premiere etoile */
         fseek(cat,p_index[k].offset,SEEK_SET);
         nbObjects=p_index[k].nbObjects;
         /* lecture de toute les etoiles de la zone */
         for (i=0;i<nbObjects;i++) {
				if (fread(&raL,1,4,cat)!=4) break;
				if (fread(&deL,1,4,cat)!=4) break;
				if (fread(&tmr,1,1,cat)!=1) break;
				if (fread(&tmb,1,1,cat)!=1) break;
				ra=(double)raL/360000.0;
				de=(double)deL/360000.0-90.0;
				mag_red=((double)tmr)/10.0-3.0;
				mag_bleue=((double)tmb)/10.0-3.0;
  				tt_util_astrom_radec2xy(&p,ra/(180/(TT_PI)),de/(180/(TT_PI)),&XXX,&YYY);
				if (XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax && mag_red<=magrlim && mag_bleue<=magblim ) {
					if ((pseries->newstar==TT_NEWSTAR_REPLACE)&&(fabs(XXX-newstar_x)<2)&&(fabs(XXX-newstar_x)<2)) {
						/*=== on insere pas l'etoile du catalogue car elle est trop proche de celle a inserer perso ==*/
					} else {
						/*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
						ppx=(double)XXX;
						ppy=(double)YYY;
						compteur=compteur+1;
						compteur_tyc=compteur_tyc+1;
						if ((fprintf(out_file,"%d %f %f %f %f %f %f %f\n",compteur,ppx,ppy,mag_red,ra,de,mag_red,mag_bleue))<0) {
							sprintf(message,"A line in file %s cannot be created\n",name);
							tt_errlog(pseries->tmp_dir,TT_ERR_FILE_CANNOT_BE_WRITED,message);
							fclose(cat);
							fclose(out_file);
							tt_free2((void**)&p_index,"p_index");
							return(PB_DLL);
						}
						j++;
					}
            }
			}
         fclose(cat);
      }
      /* GSC */
      /*=== balayage des zones trouvees .ACC ===*/
		for (k=0;k<np_index;k++) {
			if (p_index[k].flag==-1) {
				break;
			}
			sprintf(nom,"%sgsc%sZON%04d.ACC",path_astromcatalog,slash,p_index[k].indexSPD*75);
         if ((acc=fopen(nom,"r"))==NULL) {
				sprintf(message,"File %s from USNO catalog not found\n",nom);
				tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
				fclose(out_file);
				tt_free2((void**)&p_index,"p_index");
				return(PB_DLL);
			}
         /*=== on lit 30 caracteres dans le fichier .acc ===*/
         for (i=0;i<=p_index[k].indexRA;i++) {
				if (fread(buf_acc,1,30,acc)!=30) break;
         }
#ifdef OS_LINUX_GCC_SO
			sscanf(buf_acc,"%lf %d %d",&rienf,&offset,&nbObjects);
#else
			sscanf(buf_acc,"%lf %ld %ld",&rienf,&offset,&nbObjects);
#endif
         if (typecat==TT_USNO) { offset=(offset-1)*12; }
         else { offset=(offset-1)*10; }
         p_index[k].offset=offset;
         p_index[k].nbObjects=nbObjects;
         fclose(acc);
      }
      /*==== balayage des fichiers de catalogue .CAT ====*/
		for (k=0;k<np_index;k++) {
			if (p_index[k].flag==-1) {
				break;
			}
         sprintf(nom,"%sgsc%sZON%04d.CAT",path_astromcatalog,slash,p_index[k].indexSPD*75);
         if ((cat=fopen(nom,"rb"))==NULL) {
     			sprintf(message,"File %s not found\n",nom);
				tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
				fclose(out_file);
				tt_free2((void**)&p_index,"p_index");
				return(PB_DLL);
         }
         /* deplacement sur la premiere etoile */
         fseek(cat,p_index[k].offset,SEEK_SET);
         nbObjects=p_index[k].nbObjects;
         /* lecture de toute les etoiles de la zone */
         for (i=0;i<nbObjects;i++) {
				if (fread(&raL,1,4,cat)!=4) break;
				if (fread(&deL,1,4,cat)!=4) break;
				if (fread(&tmr,1,1,cat)!=1) break;
				if (fread(&tmb,1,1,cat)!=1) break;
				ra=(double)raL/360000.0;
				de=(double)deL/360000.0-90.0;
				mag_red=((double)tmr)/10.0-3.0;
				mag_bleue=((double)tmb)/10.0-3.0;
				tt_util_astrom_radec2xy(&p,ra/(180/(TT_PI)),de/(180/(TT_PI)),&XXX,&YYY);
				if (XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax && mag_red<=magrlim && mag_bleue<=magblim ) {
					if ((pseries->newstar==TT_NEWSTAR_REPLACE)&&(fabs(XXX-newstar_x)<2)&&(fabs(XXX-newstar_x)<2)) {
						/*=== on insere pas l'etoile du catalogue car elle est trop proche de celle a inserer perso ==*/
					} else {
						/*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
						ppx=(double)XXX;
						ppy=(double)YYY;
						compteur=compteur+1;
						if ((fprintf(out_file,"%d %f %f %f %f %f %f %f\n",compteur,ppx,ppy,mag_red,ra,de,mag_red,mag_bleue))<0) {
							sprintf(message,"A line in file %s cannot be created\n",name);
							tt_errlog(pseries->tmp_dir,TT_ERR_FILE_CANNOT_BE_WRITED,message);
							fclose(cat);
							fclose(out_file);
							tt_free2((void**)&p_index,"p_index");
							return(PB_DLL);
						}
						j++;
					}
            }
			}
         fclose(cat);
      }
   }

   /* ============================================== */
   /* = On effectue ici le balayage sur le USNO    = */
   /* ============================================== */
   if ((typecat==TT_USNO)||(typecat==TT_USNOCOMP)) {
      /* --- ne lit pas l'USNO si le compteur de Tycho est > 200 ---*/
      /* --- (grand champ) ---*/
      if (compteur_tyc<=200) {

         /*=== balayage des zones trouvees .ACC ===*/
			for (k=0;k<np_index;k++) {
				if (p_index[k].flag==-1) {
					break;
				}
            if (typecat==TT_USNO) {
               sprintf(nom,"%sZONE%04d.ACC",path_astromcatalog,p_index[k].indexSPD*75);
            } else {
               sprintf(nom,"%susno%sZON%04d.ACC",path_astromcatalog,slash,p_index[k].indexSPD*75);
            }
            if ((acc=fopen(nom,"r"))==NULL) {
               sprintf(message,"File %s from USNO catalog not found\n",nom);
               tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
               tt_free2((void**)&p_index,"p_index");
       	       fclose(out_file);
               return(PB_DLL);
            }
            /*=== on lit 30 caracteres dans le fichier .acc ===*/
            for (i=0;i<=p_index[k].indexRA;i++) {
               if (fread(buf_acc,1,30,acc)!=30) break;
            }
#ifdef OS_LINUX_GCC_SO
            sscanf(buf_acc,"%lf %d %d",&rienf,&offset,&nbObjects);
#else
            sscanf(buf_acc,"%lf %ld %ld",&rienf,&offset,&nbObjects);
#endif
            if (typecat==TT_USNO) { offset=(offset-1)*12; }
            else { offset=(offset-1)*10; }
            p_index[k].offset=offset;
            p_index[k].nbObjects=nbObjects;
            fclose(acc);
         }

         /*=== balayage des zones trouvees .CAT ===*/
			for (k=0;k<np_index;k++) {

				if (p_index[k].flag==-1) {
					break;
				}
            if (typecat==TT_USNO) {
               sprintf(nom,"%sZONE%04d.CAT",path_astromcatalog,p_index[k].indexSPD*75);
            } else {
               sprintf(nom,"%susno%sZON%04d.CAT",path_astromcatalog,slash,p_index[k].indexSPD*75);
            }
            if ((cat=fopen(nom,"rb"))==NULL) {
               sprintf(message,"File %s not found\n",nom);
               tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
               fclose(out_file);
               tt_free2((void**)&p_index,"p_index");
               return(PB_DLL);
            }
            /* deplacement sur la premiere etoile */
            fseek(cat,p_index[k].offset,SEEK_SET);
            nbObjects=p_index[k].nbObjects;
            /* lecture de toute les etoiles de la zone */
            for (i=0;i<nbObjects;i++) {
               if (typecat==TT_USNO) {
                  if (fread(&raL,1,4,cat)!=4) break;
                  if (fread(&deL,1,4,cat)!=4) break;
                  if (fread(&magL,1,4,cat)!=4) break;
                  raL=tt_Big2LittleEndianLong(raL);
                  deL=tt_Big2LittleEndianLong(deL);
                  magL=tt_Big2LittleEndianLong(magL);
                  ra=(double)raL/360000.0;
                  de=(double)deL/360000.0-90.0;
                  mag_red=tt_GetUsnoRedMagnitude(magL);
                  mag_bleue=tt_GetUsnoBleueMagnitude(magL);
               } else {
                  if (fread(&raL,1,4,cat)!=4) break;
                  if (fread(&deL,1,4,cat)!=4) break;
                  if (fread(&tmr,1,1,cat)!=1) break;
                  if (fread(&tmb,1,1,cat)!=1) break;
                  ra=(double)raL/360000.0;
                  de=(double)deL/360000.0-90.0;
                  mag_red=((double)tmr)/10.0-3.0;
                  mag_bleue=((double)tmb)/10.0-3.0;
               }
               tt_util_astrom_radec2xy(&p,ra/(180/(TT_PI)),de/(180/(TT_PI)),&XXX,&YYY);
			      if (XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax && mag_red<=magrlim && mag_bleue<=magblim ) {
						if ((pseries->newstar==TT_NEWSTAR_REPLACE)&&(fabs(XXX-newstar_x)<2)&&(fabs(XXX-newstar_x)<2)) {
							/*=== on insere pas l'etoile du catalogue car elle est trop proche de celle a inserer perso ==*/
						} else {
							/*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
							ppx=(double)XXX;
							ppy=(double)YYY;
							compteur=compteur+1;
							if ((fprintf(out_file,"%d %f %f %f %f %f %f %f\n",compteur,ppx,ppy,mag_red,ra,de,mag_red,mag_bleue))<0) {
								sprintf(message,"A line in file %s cannot be created\n",name);
								tt_errlog(pseries->tmp_dir,TT_ERR_FILE_CANNOT_BE_WRITED,message);
								fclose(cat);
								fclose(out_file);
								tt_free2((void**)&p_index,"p_index");
								return(PB_DLL);
							}
		               j++;
						}
               }
            }
            fclose(cat);
         }
      }
   }

   /* ================================================= */
   /* = On effectue ici le balayage sur le USNOPERSO  = */
   /* ================================================= */
   /* ra(deg) dec(deg) magred */
   if (typecat==TT_USNOPERSO) {
      k=0;
      sprintf(nom,"%s%s%s",path_astromcatalog,slash,astromcatalog);
      if ((cat=fopen(nom,"rt"))==NULL) {
         sprintf(message,"File %s of personal catalog not found\n",nom);
         tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
         fclose(out_file);
         tt_free2((void**)&p_index,"p_index");
         return(PB_DLL);
      }
      do {
         if (fgets(ligne,TT_MAXLIGNE,cat)!=NULL) {
            strcpy(texte,"");
            sscanf(ligne,"%s",texte);
            if ( (strcmp(texte,"")!=0) ) {
               k++;
               sscanf(ligne,"%lf %lf %lf",&ra,&dec,&mag_red);
               mag_bleue=mag_red;
               tt_util_astrom_radec2xy(&p,ra/(180/(TT_PI)),de/(180/(TT_PI)),&XXX,&YYY);
               if (XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax && mag_red<=magrlim && mag_bleue<=magblim ) {
						if ((pseries->newstar==TT_NEWSTAR_REPLACE)&&(fabs(XXX-newstar_x)<2)&&(fabs(XXX-newstar_x)<2)) {
							/*=== on insere pas l'etoile du catalogue car elle est trop proche de celle a inserer perso ==*/
						} else {
							/*if (XXX>=0.0 && XXX<(double)nb_pixel_x && YYY>=0.0 && YYY<(double)nb_pixel_y) {*/
							/*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
							ppx=(double)XXX;
							ppy=(double)YYY;
							compteur=compteur+1;
							if ((fprintf(out_file,"%d %f %f %f %f %f %f %f\n",
								compteur,ppx,ppy,mag_red,ra,de,mag_red,mag_bleue))<0) {
								sprintf(message,"A line in file %s cannot be created\n",name);
								tt_errlog(pseries->tmp_dir,TT_ERR_FILE_CANNOT_BE_WRITED,message);
								fclose(cat);
								fclose(out_file);
								tt_free2((void**)&p_index,"p_index");
								return(PB_DLL);
							}
							j++;
						}
               }
            }
            k++;
         }
      } while (feof(cat)==0);
	//} else {
      fclose(cat);
   }

	/* --- etoile perso --- */
	if (pseries->newstar!=TT_NEWSTAR_NONE) {
		compteur=compteur+1;
		if ((fprintf(out_file,"%d %f %f %f %f %f %f %f\n",
			compteur,newstar_x,newstar_y,newstar_mag,newstar_ra,newstar_dec,newstar_mag,newstar_mag))<0) {
			sprintf(message,"A line in file %s cannot be created\n",name);
			tt_errlog(pseries->tmp_dir,TT_ERR_FILE_CANNOT_BE_WRITED,message);
			fclose(cat);
			fclose(out_file);
			tt_free2((void**)&p_index,"p_index");
			return(PB_DLL);
		}
		j++;
	}

   /*==== fermeture du fichier liste ====*/
   fclose(out_file);
   tt_free2((void**)&p_index,"p_index");

   /* --- fin de la routine de Christian ---*/

   /* --- on reprend le fichier usno.lst en memoire ---*/
   nbe=j;

   if (nbe==0) {
      tt_tblcatcreater(p_out->catalist,1);
      p_out->catalist->x[nbe]=(double)(0.);
      p_out->catalist->y[nbe]=(double)(0.);
      p_out->catalist->ra[nbe]=(double)(0.);
      p_out->catalist->dec[nbe]=(double)(0.);
      p_out->catalist->ident[nbe]=(short)(TT_STAR);
      p_out->catalist->magb[nbe]=(double)(0.);
      p_out->catalist->magv[nbe]=(double)(0.);
      p_out->catalist->magr[nbe]=(double)(0.);
      p_out->catalist->magi[nbe]=(double)(0.);
      nbe=1;
   } else {
      tt_tblcatcreater(p_out->catalist,nbe);
      sprintf(name,"usno%s.lst",tt_tmpfile_ext);
      if ((out_file=fopen(name,"r"))==NULL) {
         sprintf(message,"File %s not found\n",name);
         tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
         return(PB_DLL);
      }
      j=0;
      do {
         if (fgets(ligne,TT_MAXLIGNE,out_file)!=NULL) {
            strcpy(texte,"");
            sscanf(ligne,"%s",texte);
            if ( (strcmp(texte,"")!=0) ) {
#ifdef OS_LINUX_GCC_SO
               sscanf(ligne,"%d %lf %lf %lf %lf %lf %lf %lf",
                  &compteur,&ppx,&ppy,&mag_red,&ra,&de,&mag_red,&mag_bleue);
#else
               sscanf(ligne,"%ld %lf %lf %lf %lf %lf %lf %lf",
                  &compteur,&ppx,&ppy,&mag_red,&ra,&de,&mag_red,&mag_bleue);
#endif
               if (j<nbe) {
                  magv=(mag_bleue+mag_red)/2.;
                  magi=mag_red;
                  p_out->catalist->x[j]=(double)(ppx);
                  p_out->catalist->y[j]=(double)(ppy);
                  p_out->catalist->ra[j]=(double)(ra);
                  p_out->catalist->dec[j]=(double)(de);
                  p_out->catalist->ident[j]=(short)(TT_STAR);
                  p_out->catalist->magb[j]=(double)(mag_bleue);
                  p_out->catalist->magv[j]=(double)(magv);
                  p_out->catalist->magr[j]=(double)(mag_red);
                  p_out->catalist->magi[j]=(double)(magi);
               }
               j++;
            }
         }
      } while (feof(out_file)==0);
      fclose(out_file);
   }

   /* --- calcul de l'image de sortie ---*/
   if (simulimage==0) {
		for (kkk=0;kkk<(int)(nelem);kkk++) {
			dvalue=p_in->p[kkk];
			p_out->p[kkk]=(TT_PTYPE)(dvalue);
		}
	} else {
		for (kkk=0;kkk<(int)(nelem);kkk++) {
			p_out->p[kkk]=(TT_PTYPE)(0);
		}
      naxis1=p_out->naxis1;
      naxis2=p_out->naxis2;
		/* === parametres photometriques ===*/
		/* --- filter --- */
		kkk=3;
		nn=(int)strlen(colfilters);
		for (kk=0;kk<nn;kk++) {
			if (pseries->colfilter[0]==colfilters[k]) {
				kkk=k;
				break;
			}
		}
		fo=fos[kkk]; /* flux a m=0 en Jansky */
		lambda=lambdas[kkk]; /* centre de la bande spectrale en microns */
		dlambda=dlambdas[kkk]; /* largeur de la bande spectrale en microns */
		quantum_efficiency=pseries->quantum_efficiency; /* efficacite quantique d'un pixel en electron/photon */
		if (quantum_efficiency<1e-9) {
			quantum_efficiency=1;
		}
		sky_brightness=pseries->sky_brightness;  /* brillance du ciel en mag/arcsec2 */
		gain=pseries->gain; /* gain de la chaine en electron/ADU */
		if (gain<1e-9) {
			gain=2.5;
		}
		teldiam=pseries->teldiam; /* diametre du telescope en metres */
		if (teldiam<=1e-9) {
			teldiam=1;
		}
		exposure=pseries->exposure; /* temps de pose en secondes */
		if (exposure<=0) {
			exposure=1;
		}
		readout_noise=pseries->readout_noise; /* fwhm sur y en pixel */
		if (readout_noise<0) {
			readout_noise=0;
		}
		tatm=pseries->tatm;
		if (tatm>1) {
			tatm=1;
		}
		topt=pseries->topt;
		if (topt>1) {
			topt=1;
		}
		elecmult=pseries->elecmult;
		if (elecmult<1) {
			elecmult=1;
		}
		fex=1;
		if (elecmult>1) {
			fex = 1 + pow( 2/(TT_PI) * atan( (elecmult-1)*3 ) ,3);
		}
		fwhmx=pseries->fwhmx; /* fwhm sur x en pixel */
		if (fwhmx<=1e-3) {
			fwhmx=2.5;
		}
		fwhmy=pseries->fwhmy; /* fwhm sur y en pixel */
		if (fwhmy<=1e-3) {
			fwhmy=2.5;
		}
		sigx=fwhmx / (2*sqrt(2*log(2)));
		sigy=fwhmy / (2*sqrt(2*log(2)));
		sigx2=sigx*sigx;
		sigy2=sigy*sigy;
		pi=4*atan(1);
		/* === signal thermique ===*/
		if (pseries->thermic_response>0) {
			tt_thermic_signal(p_out->p,nelem,pseries->thermic_response*exposure);
		}
		/* === boucle sur les etoiles ===*/
		if ((pseries->shutter_mode!=TT_SHUTTER_MODE_CLOSED)&&(pseries->shutter_mode!=TT_SHUTTER_MODE_SYNCHRO_WITHOUT_STARS)) {
			for (k=0;k<(nbe+0);k++) {
				if (k<nbe) {
					x=p_out->catalist->x[k];
      			/*y=naxis2-1-p_out->catalist->y[k];*/
      			y=p_out->catalist->y[k];
					magb=p_out->catalist->magb[k];
					magv=p_out->catalist->magv[k];
					magr=p_out->catalist->magr[k];
					magi=p_out->catalist->magi[k];
				}
				if (k==nbe) {
					if ((p.ra0!=-100)&&(p.dec0!=-100)) {
      				 ra=p.ra0;
      				 dec=p.dec0;
					} else {
      				 ra=p.crval1;
      				 dec=p.crval2;
					}
					tt_util_astrom_radec2xy(&p,ra,dec,&x,&y);
					/*y=naxis2-1-y;*/
					/*y=naxis2-y;*/
					magr=99;
					magv=0;
					magb=99;
				}
				k0=(int)(x);
				k1=(int)(y);
				if (k0<0) {k0=0;} if (k0>=naxis1) {k0=naxis1-1;}
				if (k1<0) {k1=0;} if (k1>=naxis2) {k1=naxis2-1;}
				/* === etoile === */
				/* 1) calculer le flux (en Jansky) : f_Jy= fo * 10^ (-0.4*V) */
				f_Jy= fo * pow(10,-0.4*magv);
				/*2) calculer le flux en photons/s/m2 : f = f_Jy * 1.51 e7 * (dlambda/lambda) */
				f = f_Jy * 1.51e7 * (dlambda/lambda);
				/*3) calculer le flux en photons : f*pi*teldiam*teldiam/4*exposure */
				f = f*(TT_PI)*teldiam*teldiam/4*tatm*topt*exposure;
				/*4) calculer le flux integre en electrons : f*quantum_efficiency */
				f = f*quantum_efficiency;
				/*5) calculer le flux pic en electrons :  */
				f_pic = f/sigx/sigy/2/(TT_PI);
				/* rayon d'action de la gaussienne > bruit */
				rayon2=1;
				flimit=1;
				if (readout_noise>flimit) { flimit=readout_noise; }
				if (f_pic>1e-3) {
					dvalue=sqrt(f_pic)*elecmult;
					if (dvalue>flimit) { flimit=dvalue; }
					rayon2=2*log(f_pic/flimit);
					if (rayon2<0) {rayon2=0; }
					rayon2=sqrt(sigx*sigy*rayon2);
					if (rayon2>30) { rayon2=30*(fwhmx+fwhmy)/2 ; } // on limite a 30 fwhm pour eviter les lenteurs
					if (rayon2<1) { rayon2=1 ; }
				}
				/*  */
				rayonx=(int)(5*fwhmx);
				rayony=(int)(5*fwhmy);
				if (rayon2>rayonx) { rayonx = (int)rayon2; }
				if (rayon2>rayony) { rayony = (int)rayon2; }
				if (type_objet==1) {
					// --- imagery
					for (kk0=k0-rayonx;kk0<=k0+rayonx;kk0++) {
						if (kk0<0) { continue; }
						if (kk0>=naxis1) { continue; }
						for (kk1=k1-rayony;kk1<=k1+rayony;kk1++) {
							if (kk1<0) { continue; }
							if (kk1>=naxis2) { continue; }
							dvalue=(kk0-x)*(kk0-x)/2/sigx2+(kk1-y)*(kk1-y)/2/sigy2;
							dvalue=f_pic*exp(-dvalue);
							dvalue*=tt_flat_response(naxis1,naxis2,kk0,kk1,pseries->flat_type);
							/*--- indice de x,y dans le pointeur image FITS ---*/
							p_out->p[naxis1*kk1+kk0]+=(TT_PTYPE)dvalue;
						}
					}
				} else {
					// --- specra
					int spec_l=20;
					double spec_lambda;
					double spec_response;
					for (kk0=k0-rayonx;kk0<=k0+spec_l+rayonx;kk0++) {
						if (kk0<0) { continue; }
						if (kk0>=naxis1) { continue; }
						spec_lambda=400.+500.*(kk0-k0)/spec_l;
						spec_response=1.*exp(-(spec_lambda-600)*(spec_lambda-600)/200/200);
						spec_response*=1-0.5*exp(-(spec_lambda-650)*(spec_lambda-650)/60/60);
						for (kk1=k1-rayony;kk1<=k1+rayony;kk1++) {
							if (kk1<0) { continue; }
							if (kk1>=naxis2) { continue; }
							if ((kk0-x)<0) {
								dvalue=(kk0-x)*(kk0-x)/2/sigx2+(kk1-y)*(kk1-y)/2/sigy2;
							} else if ((kk0-spec_l-x)>0) {
								dvalue=(kk0-spec_l-x)*(kk0-spec_l-x)/2/sigx2+(kk1-y)*(kk1-y)/2/sigy2;
							} else {
								dvalue=(kk1-y)*(kk1-y)/2/sigy2;
							}
							dvalue=f_pic*exp(-dvalue)*spec_response;
							dvalue*=tt_flat_response(naxis1,naxis2,kk0,kk1,pseries->flat_type);
							/*--- indice de x,y dans le pointeur image FITS ---*/
							p_out->p[naxis1*kk1+kk0]+=(TT_PTYPE)dvalue;
						}
					}
				}
			}
		}
		if (pseries->shutter_mode!=TT_SHUTTER_MODE_CLOSED) {
			/* === fond de ciel === */
			/* 0) Corrige de l'angle solide du pixel */
			omega=fabs(p.cdelta1*180/TT_PI*3600*p.cdelta2*180/TT_PI*3600);
			magv=sky_brightness-2.5*log10(omega);
			/* 1) calculer le flux (en Jansky) : f_Jy= fo * 10^ (-0.4*V) */
			f_Jy= fo * pow(10,-0.4*magv);
			/*2) calculer le flux en photons/s/m2 : f = f_Jy * 1.51 e7 * (dlambda/lambda) */
			f = f_Jy * 1.51e7 * (dlambda/lambda);
			/*3) calculer le flux en photons : f*pi*teldiam*teldiam/4*exposure */
			f = f*pi*teldiam*teldiam/4*topt*exposure;
			/*4) calculer le flux integre en electrons : f*quantum_efficiency */
			f_sky = f*quantum_efficiency;
		}
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
		/* === boucle sur les pixels ===*/
		for (kkk=0;kkk<(int)(nelem);kkk++) {
			/* --- signal de photons de l'etoile (electrons) + thermic enventuel ---*/
			dvalue=p_out->p[kkk];
			signal_star=dvalue;
			/* --- bruit de photons + thermique poissonien de l'etoile (electrons) ---*/
			noise_star=tt_poissonian_rand(signal_star,repartitionps,nk,kmax,nl,lambdamax,repartitions,nrep,sigmax);
			if (pseries->shutter_mode!=TT_SHUTTER_MODE_CLOSED) {
				/* --- signal de photons du ciel (electrons) ---*/
				dvalue=f_sky;
				kk1=kkk/naxis1;
				kk0=kkk-naxis1*kk1;
				dvalue*=tt_flat_response(naxis1,naxis2,kk0,kk1,pseries->flat_type);
				signal_sky=dvalue;
				/* --- bruit de photons du ciel (electrons) ---*/
				noise_sky=tt_poissonian_rand(signal_sky,repartitionps,nk,kmax,nl,lambdamax,repartitions,nrep,sigmax);
			} else {
				signal_sky=0;
				noise_sky=0;
			}
			/* --- signal de lecture = bias (electrons) ---*/
			signal_readout=pseries->bias_level*gain;
			/* --- bruit de lecture = bruit de bias (electrons) ---*/
			noise_readout=tt_poissonian_rand(readout_noise,repartitionps,nk,kmax,nl,lambdamax,repartitions,nrep,sigmax);
			/* --- additionne tous les electrons (tient compte si EMCCD) ---*/
			p_out->p[kkk]=(TT_PTYPE)((signal_star*elecmult+signal_sky*elecmult+signal_readout+noise_star*elecmult*fex+noise_sky*elecmult*fex+noise_readout)/gain);
		}
      tt_free2((void**)&repartitions,"repartitions");
      tt_free2((void**)&repartitionps,"repartitionps");
	}

   /* --- Calcul des parametres de fond de ciel ---*/
   tt_util_statima(p_out,TT_MAX_DOUBLE,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
   tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
   tt_imanewkey(p_out,"BGMEAN",&(pseries->bgmean),TDOUBLE,"mean value for background pixels","adu");
   tt_imanewkey(p_out,"BGSIGMA",&(pseries->bgsigma),TDOUBLE,"std sigma value for background pixels","adu");

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_cuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);
   mipshi=(float)(pseries->hicut);
   mipslo=(float)(pseries->locut);
   tt_imanewkey(p_out,"MIPS-HI",&(mipshi),TFLOAT,"High cut for visualisation for MiPS","adu");
   tt_imanewkey(p_out,"MIPS-LO",&(mipslo),TFLOAT,"Low cut for visualisation for MiPS","adu");

   /* --- Calcul des parametres de projection ---*/
   tt_util_putnewkey_astrometry(p_out,&p);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   /* --- calcul de l'image jpeg de la carte seule en couleur ---*/
   if ((simulimage==0)&&(pseries->jpegfile_chart_make==TT_YES)&&(strcmp(pseries->jpegfile_chart,"")!=0)) {
      naxis1=p_out->naxis1;
      naxis2=p_out->naxis2;
      color_space=JCS_RGB;
      qualite=(int)pseries->jpeg_qualite;
      if (qualite>100) {qualite=100;}
      if (qualite<5) {qualite=5;}
      pjpeg=NULL;
      nombre=3*naxis1*naxis2;
      taille=sizeof(unsigned char);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pjpeg,&nombre,&taille,"pjpeg"))!=0) {
         tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer jpeg)");
         return(TT_ERR_PB_MALLOC);
      }
      for (k=0;k<(nbe+0);k++) {
         if (k<nbe) {
				x=p_out->catalist->x[k];
      		/*y=naxis2-1-p_out->catalist->y[k];*/
      		y=naxis2-p_out->catalist->y[k];
				magb=p_out->catalist->magb[k];
				magv=p_out->catalist->magv[k];
				magr=p_out->catalist->magr[k];
				magi=p_out->catalist->magi[k];
         }
         if (k==nbe) {
            if ((p.ra0!=-100)&&(p.dec0!=-100)) {
      	       ra=p.ra0;
      	       dec=p.dec0;
            } else {
      	       ra=p.crval1;
      	       dec=p.crval2;
            }
				tt_util_astrom_radec2xy(&p,ra,dec,&x,&y);
				/*y=naxis2-1-y;*/
				y=naxis2-y;
				magr=99;
				magv=0;
				magb=99;
         }
         k0=(int)(x);
         k1=(int)(y);
         if (k0<0) {k0=0;} if (k0>=naxis1) {k0=naxis1-1;}
         if (k1<0) {k1=0;} if (k1>=naxis2) {k1=naxis2-1;}
         /* 255 pour mag8 => 1 pour mag16 */
         dvalue=(16-magr)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
         magr=dvalue;
         dvalue=(16-magv)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
         magv=dvalue;
         dvalue=(16-magb)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
         magb=dvalue;
         rayon=5;
         for (kk0=k0-rayon;kk0<=k0+rayon;kk0++) {
				for (kk1=k1-rayon;kk1<=k1+rayon;kk1++) {
					dvalue=(kk0-x)*(kk0-x)+(kk1-y)*(kk1-y);
					if (dvalue<=rayon) {
						if ((kk0>=0)&&(kk0<naxis1)&&(kk1>=0)&&(kk1<naxis2)) {
							pjpeg[3*(naxis1*kk1+kk0)+0]=(unsigned char)(magr); /* rouge */
							pjpeg[3*(naxis1*kk1+kk0)+1]=(unsigned char)(magv); /* vert */
							pjpeg[3*(naxis1*kk1+kk0)+2]=(unsigned char)(magb); /* bleu */
						}
					}
				}
         }
         /*--- indice de x,y dans le pointeur image FITS ---*/
         /*p_out->p[kk=xmax*y+x];*/
      }
      /* --- enregistrement de l'image RGB en format JPEG --- */
      if ((msg=libfiles_main(FS_MACR_WRITE_JPG,6,pseries->jpegfile_chart,&color_space,
      pjpeg,&naxis1,&naxis2,&qualite))!=0) {
          return(msg);
      }
      /* --- on libere le pointeur d'image jpeg---*/
      tt_free2((void**)&pjpeg,"pjpeg");
   }

   /* --- calcul de l'image jpeg de la carte overlay catalogue en couleur ---*/
   if ((simulimage==0)&&(pseries->jpegfile_chart2_make==TT_YES)&&(strcmp(pseries->jpegfile_chart2,"")!=0)) {
      naxis1=p_out->naxis1;
      naxis2=p_out->naxis2;
      color_space=JCS_RGB;
      qualite=(int)pseries->jpeg_qualite;
      if (qualite>100) {qualite=100;}
      if (qualite<5) {qualite=5;}
      pjpeg=NULL;
      nombre=3*naxis1*naxis2;
      taille=sizeof(unsigned char);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pjpeg,&nombre,&taille,"pjpeg"))!=0) {
         tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_catchart_2 (pointer jpeg)");
         return(TT_ERR_PB_MALLOC);
      }
		if (pseries->hicut!=pseries->locut) {
         for (kk0=0;kk0<naxis1;kk0++) {
            for (kk1=0;kk1<naxis2;kk1++) {
               dvalue=p_out->p[naxis1*(naxis2-1-kk1)+kk0];
               magr=256.*(dvalue-pseries->locut)/(pseries->hicut-pseries->locut);
               if (magr>=255.) {magr=255.;}
               else if (magr<=0) {magr=0.;}
               else {
                  magr=magr;
               }
               pjpeg[3*(naxis1*kk1+kk0)+0]=(unsigned char)(magr); /* rouge */
					pjpeg[3*(naxis1*kk1+kk0)+1]=(unsigned char)(magr); /* vert */
					pjpeg[3*(naxis1*kk1+kk0)+2]=(unsigned char)(magr); /* bleu */
           }
         }
      }
      for (k=0;k<(nbe+0);k++) {
         if (k<nbe) {
   			x=p_out->catalist->x[k];
   			/*y=naxis2-1-p_out->catalist->y[k];*/
   			y=naxis2-p_out->catalist->y[k];
   			magb=p_out->catalist->magb[k];
   			magv=p_out->catalist->magv[k];
   			magr=p_out->catalist->magr[k];
   			magi=p_out->catalist->magi[k];
         }
         if (k==nbe) {
				ra=p.ra0;
				dec=p.dec0;
				tt_util_astrom_radec2xy(&p,ra,dec,&x,&y);
				/*y=naxis2-1-y;*/
				y=naxis2-y;
         }
         k0=(int)(x);
         k1=(int)(y);
         if (k0<0) {k0=0;} if (k0>=naxis1) {k0=naxis1-1;}
         if (k1<0) {k1=0;} if (k1>=naxis2) {k1=naxis2-1;}
         /* 255 pour mag8 => 1 pour mag16 */
         dvalue=(16-magr)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
         magr=dvalue;
         dvalue=(16-magv)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
         magv=dvalue*0.;
         dvalue=(16-magb)/(16-8)*155+100;if (dvalue<0) {dvalue=0;}if (dvalue>254) {dvalue=255;}
			magb=dvalue*0.;
         if (k==nbe) {
				magr=99;
				magv=0;
				magb=99;
         }
         rayon=10;
         for (kk0=k0-rayon;kk0<=k0+rayon;kk0++) {
				for (kk1=k1-rayon;kk1<=k1+rayon;kk1++) {
					dvalue=(kk0-x)*(kk0-x)+(kk1-y)*(kk1-y);
					if (dvalue<=rayon) {
						if ((kk0>=0)&&(kk0<naxis1)&&(kk1>=0)&&(kk1<naxis2)) {
							pjpeg[3*(naxis1*kk1+kk0)+0]=(unsigned char)(magr); /* rouge */
							pjpeg[3*(naxis1*kk1+kk0)+1]=(unsigned char)(magv); /* vert */
							pjpeg[3*(naxis1*kk1+kk0)+2]=(unsigned char)(magb); /* bleu */
						}
					}
				}
			}
         /*--- indice de x,y dans le pointeur image FITS ---*/
			/*p_out->p[kk=xmax*y+x];*/
      }
      /* --- enregistrement de l'image RGB en format JPEG --- */
      if ((msg=libfiles_main(FS_MACR_WRITE_JPG,6,pseries->jpegfile_chart2,&color_space,
		 pjpeg,&naxis1,&naxis2,&qualite))!=0) {
			return(msg);
      }
      /* --- on libere le pointeur d'image jpeg---*/
      tt_free2((void**)&pjpeg,"pjpeg");
   }

   /* --- Parametres des listes de pixels et d'objets ---*/
   time( &ltime );
   strftime(value_char,FLEN_VALUE,"%Y-%m-%dT%H:%M:%S",localtime( &ltime ));
   srand( (unsigned)time( NULL ) );
   if (pseries->catalog_list==TT_YES) {
      sprintf(pseries->p_out->catakey,"%s:%d",value_char,rand());
      tt_imanewkey(p_out,"CATAKEY",pseries->p_out->catakey,TSTRING,"Link key for catafile","");
      if (strcmp(pseries->catafile,"")!=0) {
			strcpy(pseries->p_out->catalist_fullname,pseries->catafile);
      }
   }

   return(OK_DLL);
}


/*************** COMPUTEUSNOINDEXS ********************/
/* Calcul de la zone d'ascension droite et de la zone */
/* de South Polar Declination a partir de l'ascension */
/* droite et de la declinaison.                       */
/*====================================================*/
void tt_ComputeUsnoIndexs(double ra,double de,int *indexSPD,int *indexRA)
{
/*-------------------------------------------*/
/* On determine la bande de declinaison      */
/* Il y a 24 bandes de 7.5d a partir de -90d */
/*-------------------------------------------*/
if (de>=(TT_PI)/2.-1.0e-9)
   *indexSPD=23;
else
   *indexSPD=(int)floor(tt_R2D(de+(TT_PI)/2.)/7.5);

/*---------------------------------------------------*/
/* On determine l'index dans les 96 zones de 15' en  */
/* ascension droite. ((ra/15)*60)/15: transformation */
/* en heures puis en minutes puis calcul de l'index  */
/*---------------------------------------------------*/
*indexRA=(int)floor((4.0*tt_R2D(ra))/15.0);
}

/*************** R2D ***************/
/* Conversion de radiant en degres */
/***********************************/
double tt_R2D(double a)
{
return(a*57.29577951);
}

/*************** D2R ***************/
/* Conversion de radiant en degres */
/***********************************/
double tt_D2R(double a)
{
return(a/57.29577951);
}

/*=========================================================*/
/* Transformation de Big en Little Endian (et le contraire */
/* d'ailleurs...!!!). L'entier 32 bits ABCD est transforme */
/* en DCBA.                                                */
/*=========================================================*/
int tt_Big2LittleEndianLong(int l)
{
return(l << 24) | ((l << 8) & 0x00FF0000) |
      ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On prend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double tt_GetUsnoBleueMagnitude(int magL)
{
double mag;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+4,3); *(buf2+3)='\0';
mag = (double)atof(buf2)/10.0;
if (mag<=TT_EPS_DOUBLE)
   {
   strncpy(buf2,buf+1,3);
   *(buf2+3)='\0';
   if ((double)atof(buf2)<=TT_EPS_DOUBLE)
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
double tt_GetUsnoRedMagnitude(int magL)
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

int tt_ima_series_headerfits_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Ajoute, remplace des mots cle dans l'entete FITS                        */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* file : fichier texte contenant les donnees.                             */
/*  ligne 1 : mot cle                                                      */
/*  ligne 2 : valeur                                                       */
/*  ligne 3 : type de valeur (short, int, double, string)                  */
/*  ligne 4 : commentaire                                                  */
/*  ligne 5 : unites                                                       */
/*  ligne 6 : mot cle ....                                                 */
/*  ...                                                                    */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index,compteur;
   char *file;
   FILE *fichier;
   char message[TT_MAXLIGNE];
   char typedata[TT_MAXLIGNE];
   char keyname[FLEN_KEYWORD];
   char value_char[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];
   char *punit,*pcomment;
   int datatype;
   short datashort;
   int dataint;
   float datafloat;
   double datadouble;
   char * retour_char;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   file=pseries->file;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- ajoute les nouveaux mot cle ---*/
   if ((fichier=fopen(file,"rt") ) == NULL) {
      sprintf(message,"File %s for new header keys not found\n",file);
      tt_errlog(pseries->tmp_dir,TT_ERR_FILE_NOT_FOUND,message);
      return(TT_ERR_FILE_NOT_FOUND);
   }
   compteur=0;
   do {
      compteur++;
      if (compteur>=TT_MAXKEYS) { break; }
      strcpy(keyname,"");
      strcpy(message,"");
      retour_char = fgets(message,(TT_MAXLIGNE),fichier);
      tt_util_dellastchar(message);
      sscanf(message,"%s",keyname);
      keyname[(FLEN_KEYWORD-1)]='\0';
      if (strcmp(keyname,"")==0) {
	 break;
      } else {
	 tt_strupr(keyname);
        strcpy(value_char,"");
        strcpy(message,"");
        retour_char = fgets(message,(TT_MAXLIGNE),fichier);
        tt_util_dellastchar(message);
        strcpy(value_char,message);
        value_char[(FLEN_VALUE-1)]='\0';
	 if (strcmp(value_char,"")==0) {
	    break;
	 } else {
	    strcpy(message,"");
        strcpy(typedata,"");
        retour_char = fgets(message,TT_MAXLIGNE,fichier);
	    tt_util_dellastchar(message);
        sscanf(message,"%s",typedata);
	    strcpy(comment,"");
	    retour_char = fgets(comment,FLEN_COMMENT,fichier);
	    tt_util_dellastchar(comment);
	    if (strcmp(comment,"")==0) {pcomment=NULL;} else {pcomment=comment;}
	    strcpy(unit,"");
	    retour_char = fgets(unit,FLEN_COMMENT,fichier);
	    tt_util_dellastchar(unit);
	    if (strcmp(unit,"")==0) {punit=NULL;} else {punit=unit;}
	    if (strcmp(message,"short")==0) {
	       datatype=TSHORT;
	       datashort=(short)(atoi(value_char));
	       tt_imanewkey(p_out,keyname,&datashort,datatype,pcomment,punit);
	    } else if (strcmp(message,"int")==0) {
	       datatype=TINT;
	       dataint=(int)(atoi(value_char));
	       tt_imanewkey(p_out,keyname,&dataint,datatype,pcomment,punit);
	    } else if (strcmp(message,"float")==0) {
	       datatype=TFLOAT;
	       datafloat=(float)(atof(value_char));
	       tt_imanewkey(p_out,keyname,&datafloat,datatype,pcomment,punit);
	    } else if (strcmp(message,"double")==0) {
	       datatype=TDOUBLE;
	       datadouble=(double)(atof(value_char));
	       tt_imanewkey(p_out,keyname,&datadouble,datatype,pcomment,punit);
	    } else {
	       datatype=TSTRING;
	       tt_imanewkey(p_out,keyname,value_char,datatype,pcomment,punit);
	    }
	 }
      }
   } while (feof(fichier)==0) ;
   fclose(fichier);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

