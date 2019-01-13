/* mc_cart1.c
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
/* MC : Utilitaire de meca celeste                                         */
/* Auteur : Alain Klotz                                                    */
/***************************************************************************/
/* Cartographie a partir de catalogues ...                                 */
/***************************************************************************/
#include "mc.h"

int mc_ima_series_catchart_2(mc_ASTROM p,int *nbobjs, int nbobjmax, objetype *objs,char *outfilename)
/***************************************************************************/
/* Cree une carte a partir des donnees des images                          */
/* version Buil de mc_ima_series_catchart_1                                */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* path_astromcatalog :                                                    */
/*                                                                         */
/* Codes erreurs :                                                         */
/* 0 : pas de probleme.                                                    */
/* 1 : erreur calloc                                                       */
/* 2 : pb creation du fichier usno.lst                                     */
/* 3 : pb lecture fichier .acc du Tycho microcat.                          */
/* 4 : pb lecture fichier .cat du Tycho microcat.                          */
/* 5 : pb lecture fichier .acc du gsc microcat.                            */
/* 6 : pb lecture fichier .cat du gsc microcat.                            */
/* 7 : pb lecture fichier .acc de l'usno usno/microcat.                    */
/* 8 : pb lecture fichier .cat de l'usno usno/microcat.                    */
/* 9 : pb lecture fichier usno.lst                                         */
/* 10 : pb ligne non ecrite dans usno.lst                                  */
/* 12 : pb lecture fichier .acc du Loneos microcat.                        */
/* 13 : pb lecture fichier .cat du Loneos microcat.                        */
/* 14 : pb parametres astrometriques (dalpha=0 ddelta=0)                             */
/***************************************************************************/
{
   char *path_astromcatalog=NULL;
   /*int naxis1,naxis2;*/
   int k,nbtot=0;
   int typecat;
   /*double magr=0.,magv=0.,magb=0.;*/
   /*char texte[255],ligne[255];*/
   int taille,nombre;
   double XXXmin,XXXmax,YYYmin,YYYmax;
   /* --- ajout Buil */
   char name[256];
   double alpha1;
   double alpha2;
   double delta2;
   double delta1;
   double v,r;
   double l_alpha,l_delta;
   double lx,ly;
   double Trad=PI/180.0;
   double Tdeg=180.0/PI;
   FILE *out_file=NULL;
   int compteur=0,compteur_tyc=0;
   double ra,de=0.,mag_red=0.,mag_bleue=0.;
   double dalpha,ddelta,dalpha2;
   int indexSPD,indexRA;
   mc_USNO_INDEX *p_index;
   int i,j,first,flag;
   char nom[255];
   FILE *acc,*cat;
   char buf_acc[31];
   int offset,nbObjects;
   int raL,deL,magL;
   double XXX,YYY,rienf;
   int bordurex=0,bordurey=0;
   double ppx,ppy;
   unsigned char tmr,tmb;
   double a0,focale,dim_pixel_x,dim_pixel_y,d0;
   int nb_pixel_x,nb_pixel_y;
   char slash[2];
   short smu,smb,smv,smr,smi,smj,smh,smk;
   double mag_i=0.,mag_green=0.;
   /*FILE *ff;*/
   
   /*/////////////// debut N E W ////////////////////////////////*/
   /* --- intialisations ---*/
#ifdef FILE_DOS
   strcpy(slash,"\\");
#endif
#ifdef FILE_UNIX
   strcpy(slash,"/");
#endif
   p.bordure=0.;
   typecat=p.astromcatalog;
   path_astromcatalog=p.path_astromcatalog;
   
   mc_util_astrom_xy2radec(&p,0.5*p.naxis1,0.5*p.naxis2,&a0,&d0);
   a0=a0*180./PI;
   d0=d0*180./PI;
   if (p.foclen==0.) {
      p.px=10e-6; /* 10 microns arbitraire */
      p.py=p.px*fabs(p.cdelta2/p.cdelta1);
      p.foclen=fabs(p.px/2./tan(p.cdelta1/2.));
   }
   /* conversion en mm */
   focale=p.foclen*1e3;   
   
   /*/////////////// fin N E W ////////////////////////////////*/
   
   
   dim_pixel_x=p.px*1e3;
   dim_pixel_y=p.py*1e3;
   
   nb_pixel_x=p.naxis1;
   nb_pixel_y=p.naxis2;
   
   /*=== alpha en heures ===*/
   a0=a0/15.0;
   if (a0>24) {a0=23.999999;}
   if (a0<0) {a0=0.;}
   
   /* On calcul les bornes en alpha du champ
   Les bornes de recherches dependent du lieu dans le ciel ainsi que
   le rayon du champ */
   if (d0>=90.0) d0=89.9999;
   if (d0<=-90.0) d0=-89.9999;
   
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
   /*
   ff=fopen("a.txt","wt");
   fprintf(ff,"p.crval1=%lf a0=%lf H p.crval2=%lf d0=%lf degrees r=%lf\n",p.crval1,a0,p.crval2,d0,r);
   fprintf(ff,"dim_pixel_x=%lf nb_pixel_x=%ld lx=%lf focale=%lf alpha1=%lf alpha2=%lf \n",dim_pixel_x,nb_pixel_x,lx,focale,alpha1,alpha2);
   fprintf(ff,"ly=%lf focale=%lf delta1=%lf delta2=%lf \n",ly,focale,delta1,delta2);
   fclose(ff);
   */
   /*=== recherche les differentes zones presentes dans l'image ===*/
   /* on est a cheval sur 0 heure */
   if (alpha1>alpha2)
   {
      dalpha=(23.99999999-alpha1)/97.0;
      ddelta=(delta2-delta1)/25.0;
      j=0;
      for (ra=alpha1;ra<=23.99999999;ra+=dalpha)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            j++;
         }
      }
      dalpha2=alpha2/97.0;
      for (ra=0;ra<=alpha2;ra+=dalpha2)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            j++;
         }
      }
      nombre=j+5;
      taille=sizeof(mc_USNO_INDEX);
      p_index=NULL;
      if ((p_index=(mc_USNO_INDEX*)calloc(nombre,taille))==NULL) {
         return(1);
      }
      i=0;
      for (ra=alpha1;ra<=23.99999999;ra+=dalpha)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            p_index[i++].flag=-1;
         }
      }
      for (ra=0;ra<=alpha2;ra+=dalpha2)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            p_index[i++].flag=-1;
         }
      }
      
      p_index[i++].flag=-1;  // on complete pour bien borner la table
      p_index[i++].flag=-1;
      
      k=0;
      first=1;
      for (ra=alpha1;ra<=23.99999999;ra+=dalpha)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            mc_ComputeUsnoIndexs(mc_D2R(15.0*ra),mc_D2R(de),&indexSPD,&indexRA);
            if (first==1)
            {
               p_index[k].flag=1;
               p_index[k].indexRA=indexRA;
               p_index[k].indexSPD=indexSPD;
               first=0;
            }
            else
            {
               i=0;
               flag=0;
               while (p_index[i].flag!=-1)
               {
                  if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD)
                  {
                     flag=1;
                     break;
                  }
                  i++;
               }
               if (flag==0)
               {
                  k++;
                  p_index[k].flag=1;
                  p_index[k].indexRA=indexRA;
                  p_index[k].indexSPD=indexSPD;
               }
            }
         }
      }
      for (ra=0;ra<=alpha2;ra+=dalpha2)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            mc_ComputeUsnoIndexs(mc_D2R(15.0*ra),mc_D2R(de),&indexSPD,&indexRA);
            if (first==1)
            {
               p_index[k].flag=1;
               p_index[k].indexRA=indexRA;
               p_index[k].indexSPD=indexSPD;
               first=0;
            }
            else
            {
               i=0;
               flag=0;
               while (p_index[i].flag!=-1)
               {
                  if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD)
                  {
                     flag=1;
                     break;
                  }
                  i++;
               }
               if (flag==0)
               {
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
   else if (alpha1 < alpha2 )
   {
      dalpha=(alpha2-alpha1)/97.0;
      ddelta=(delta2-delta1)/25.0;
      j=0;
      for (ra=alpha1;ra<=alpha2;ra+=dalpha)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            j++;
         }
      }
      nombre=j+5;
      taille=sizeof(mc_USNO_INDEX);
      p_index=NULL;
      if ((p_index=(mc_USNO_INDEX*)calloc(nombre,taille))==NULL) {
         return(1);
      }
      i=0;
      for (ra=alpha1;ra<=alpha2;ra+=dalpha)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            p_index[i++].flag=-1;
         }
      }
      
      p_index[i++].flag=-1;  // on complete pour bien borner la table
      p_index[i++].flag=-1;
      
      k=0;
      first=1;
      for (ra=alpha1;ra<=alpha2;ra+=dalpha)
      {
         for (de=delta1;de<=delta2;de+=ddelta)
         {
            mc_ComputeUsnoIndexs(mc_D2R(15.0*ra),mc_D2R(de),&indexSPD,&indexRA);
            if (first==1)
            {
               p_index[k].flag=1;
               p_index[k].indexRA=indexRA;
               p_index[k].indexSPD=indexSPD;
               first=0;
            }
            else
            {
               i=0;
               flag=0;
               while (p_index[i].flag!=-1)
               {
                  if (p_index[i].indexRA==indexRA && p_index[i].indexSPD==indexSPD)
                  {
                     flag=1;
                     break;
                  }
                  i++;
               }
               if (flag==0)
               {
                  k++;
                  p_index[k].flag=1;
                  p_index[k].indexRA=indexRA;
                  p_index[k].indexSPD=indexSPD;
               }
            }
         }
      }
   } else {
      // alpha1 = alpha2
      return 14;
      
   }
   
   /* --- bordure est la zone d'exclusion au bord de l'image ---*/
   /* --- pseries->bordure s'exprime en pourcents ---*/
   if (p.bordure<0.) {p.bordure=0.; }
   if (p.bordure>90.) {p.bordure=90.; }
   bordurex=(int)(p.bordure/100.*p.naxis1/2.);
   bordurey=(int)(p.bordure/100.*p.naxis2/2.);
   XXXmin=bordurex;
   XXXmax=nb_pixel_x-bordurex;
   YYYmin=bordurey;
   YYYmax=nb_pixel_y-bordurey;
   
   /*==== ouverture d'un fichier liste ====*/
   if (outfilename!=NULL) {
      strcpy(name,outfilename);
      if ((out_file=fopen(name,"w"))==NULL) {
         free(p_index);
         return(2);
      }
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
   if (typecat==mc_USNOCOMP) {
      /* TYCHO */
      /*=== balayage des zones trouvees .ACC ===*/
      k=0;
      while (p_index[k].flag!=-1) {
         sprintf(nom,"%styc%sZON%04d.ACC",path_astromcatalog,slash,p_index[k].indexSPD*75);
         if ((acc=fopen(nom,"r"))==NULL) {
            free(p_index);
            return(3);
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
         if (typecat==mc_USNO) { offset=(offset-1)*12; }
         else { offset=(offset-1)*10; }
         p_index[k].offset=offset;
         p_index[k].nbObjects=nbObjects;
         fclose(acc);
         k++;
      }
      /*==== balayage des fichiers de catalogue .CAT ====*/
      k=0;
      while (p_index[k].flag!=-1) {
         sprintf(nom,"%styc%sZON%04d.CAT",path_astromcatalog,slash,p_index[k].indexSPD*75);
         if ((cat=fopen(nom,"rb"))==NULL) {
            free(p_index);
            if (outfilename!=NULL) {fclose(out_file);}
            return(4);
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
            mc_util_astrom_radec2xy(&p,ra/(180/(PI)),de/(180/(PI)),&XXX,&YYY);
            if ((XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax)&&(nbtot<nbobjmax)) {
               if ((mag_bleue>=p.magbinf)&&(mag_bleue<=p.magbsup)&&(mag_red>=p.magrinf)&&(mag_red<=p.magrsup)) {
                  /*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
                  ppx=(double)XXX;
                  ppy=(double)YYY;
                  compteur=compteur+1;
                  compteur_tyc=compteur_tyc+1;
                  if (outfilename!=NULL) {
                     if ((fprintf(out_file,"%f %f %2.1f %2.1f %.2f %.2f 1 \n",
                        ra,de,mag_bleue,mag_red,ppx,ppy))<0) {
                        fclose(cat);
                        if (outfilename!=NULL) {fclose(out_file);}
                        free(p_index);
                        return(10);
                     }
                  }
                  if (objs!=NULL) {
                     (objs+nbtot)->ra=(float)ra;
                     (objs+nbtot)->dec=(float)de;
                     (objs+nbtot)->magb=(short)(mag_bleue*100);
                     (objs+nbtot)->magr=(short)(mag_red*100);
                     (objs+nbtot)->x=(float)(ppx);
                     (objs+nbtot)->y=(float)(ppy);
                     (objs+nbtot)->origin='1';
                  }
                  j++;
                  nbtot++;
               }
            }
         }
         fclose(cat);
         k++;
      }
      
      /* GSC */
      /*=== balayage des zones trouvees .ACC ===*/
      k=0;
      if (p.tycho_only==0) {
         while (p_index[k].flag!=-1) {
            sprintf(nom,"%sgsc%sZON%04d.ACC",path_astromcatalog,slash,p_index[k].indexSPD*75);
            if ((acc=fopen(nom,"r"))==NULL) {
               free(p_index);
               if (outfilename!=NULL) {fclose(out_file);}
               return(5);
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
            if (typecat==mc_USNO) { offset=(offset-1)*12; }
            else { offset=(offset-1)*10; }
            p_index[k].offset=offset;
            p_index[k].nbObjects=nbObjects;
            fclose(acc);
            k++;
         }
         /*==== balayage des fichiers de catalogue .CAT ====*/
         k=0;
         while (p_index[k].flag!=-1) {
            sprintf(nom,"%sgsc%sZON%04d.CAT",path_astromcatalog,slash,p_index[k].indexSPD*75);
            if ((cat=fopen(nom,"rb"))==NULL) {
               free(p_index);
               if (outfilename!=NULL) {fclose(out_file);}
               return(6);
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
               mc_util_astrom_radec2xy(&p,ra/(180/(PI)),de/(180/(PI)),&XXX,&YYY);
               if ((XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax)&&(nbtot<nbobjmax)) {
                  if ((mag_bleue>=p.magbinf)&&(mag_bleue<=p.magbsup)&&(mag_red>=p.magrinf)&&(mag_red<=p.magrsup)) {
                     /*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
                     ppx=(double)XXX;
                     ppy=(double)YYY;
                     compteur=compteur+1;
                     if (outfilename!=NULL) {
                        if ((fprintf(out_file,"%f %f %2.1f %2.1f %.2f %.2f 2 \n",
                           ra,de,mag_bleue,mag_red,ppx,ppy))<0) {
                           fclose(cat);
                           if (outfilename!=NULL) {fclose(out_file);}
                           free(p_index);
                           return(10);
                        }
                     }
                     if (objs!=NULL) {
                        (objs+nbtot)->ra=(float)ra;
                        (objs+nbtot)->dec=(float)de;
                        (objs+nbtot)->magb=(short)(mag_bleue*100);
                        (objs+nbtot)->magr=(short)(mag_red*100);
                        (objs+nbtot)->x=(float)(ppx);
                        (objs+nbtot)->y=(float)(ppy);
                        (objs+nbtot)->origin='2';
                     }
                     j++;
                     nbtot++;
                  }
               }
            }
            fclose(cat);
            k++;
         }
      }
   }
   
   /* ============================================== */
   /* = On effectue ici le balayage sur le USNO    = */
   /* ============================================== */
   k=0;
   if ((typecat==mc_USNOCOMP)||(typecat==mc_USNO)) {   
      if (p.tycho_only==0) {
         while (p_index[k].flag!=-1) {
            /* --- ne lit pas l'USNO si le compteur de Tycho est > 200 ---*/
            /* --- (grand champ) ---*/
            if (compteur_tyc>200) { break; }
            
            /*=== balayage des zones trouvees .ACC ===*/
            k=0;
            while (p_index[k].flag!=-1) {
               if (typecat==mc_USNO) {
                  sprintf(nom,"%sZONE%04d.ACC",path_astromcatalog,p_index[k].indexSPD*75);
               } else {
                  sprintf(nom,"%susno%sZON%04d.ACC",path_astromcatalog,slash,p_index[k].indexSPD*75);
               }
               if ((acc=fopen(nom,"r"))==NULL) {
                  free(p_index);
                  if (outfilename!=NULL) {fclose(out_file);}
                  return(7);
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
               if (typecat==mc_USNO) { offset=(offset-1)*12; }
               else { offset=(offset-1)*10; }
               p_index[k].offset=offset;
               p_index[k].nbObjects=nbObjects;
               fclose(acc);
               k++;
            }
            
            /*=== balayage des zones trouvees .CAT ===*/
            k=0;
            while (p_index[k].flag!=-1) {
               
               if (typecat==mc_USNO) {
                  sprintf(nom,"%sZONE%04d.CAT",path_astromcatalog,p_index[k].indexSPD*75);
               } else {
                  sprintf(nom,"%susno%sZON%04d.CAT",path_astromcatalog,slash,p_index[k].indexSPD*75);
               }
               if ((cat=fopen(nom,"rb"))==NULL) {
                  free(p_index);
                  if (outfilename!=NULL) {fclose(out_file);}
                  return(8);
               }
               /* deplacement sur la premiere etoile */
               fseek(cat,p_index[k].offset,SEEK_SET);
               nbObjects=p_index[k].nbObjects;
               /* lecture de toute les etoiles de la zone */
               for (i=0;i<nbObjects;i++) {
                  if (typecat==mc_USNO) {
                     if (fread(&raL,1,4,cat)!=4) break;
                     if (fread(&deL,1,4,cat)!=4) break;
                     if (fread(&magL,1,4,cat)!=4) break;
                     raL=mc_Big2LittleEndianLong(raL);
                     deL=mc_Big2LittleEndianLong(deL);
                     magL=mc_Big2LittleEndianLong(magL);
                     ra=(double)raL/360000.0;
                     de=(double)deL/360000.0-90.0;
                     mag_red=mc_GetUsnoRedMagnitude(magL);
                     mag_bleue=mc_GetUsnoBleueMagnitude(magL);
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
                  mc_util_astrom_radec2xy(&p,ra/(180/(PI)),de/(180/(PI)),&XXX,&YYY);
                  if ((XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax)&&(nbtot<nbobjmax)) {
                     if ((mag_bleue>=p.magbinf)&&(mag_bleue<=p.magbsup)&&(mag_red>=p.magrinf)&&(mag_red<=p.magrsup)) {
                        /*if (XXX>=0.0 && XXX<(double)nb_pixel_x && YYY>=0.0 && YYY<(double)nb_pixel_y) {*/
                        /*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
                        ppx=(double)XXX;
                        ppy=(double)YYY;
                        compteur=compteur+1;
                        if (outfilename!=NULL) {
                           if ((fprintf(out_file,"%f %f %2.1f %2.1f %.2f %.2f 3 \n",
                              ra,de,mag_bleue,mag_red,ppx,ppy))<0) {
                              fclose(cat);
                              if (outfilename!=NULL) {fclose(out_file);}
                              free(p_index);
                              return(10);
                           }
                        }
                        if (objs!=NULL) {
                           (objs+nbtot)->ra=ra;
                           (objs+nbtot)->dec=de;
                           (objs+nbtot)->magb=(short)(mag_bleue*100);
                           (objs+nbtot)->magr=(short)(mag_red*100);
                           (objs+nbtot)->x=(float)(ppx);
                           (objs+nbtot)->y=(float)(ppy);
                           (objs+nbtot)->origin='3';
                        }
                        j++;
                        nbtot++;
                     }
                  }
               }
               fclose(cat);
               k++;
            }
         }
      }
   }
   
   
   /* ============================================== */
   /* = On effectue ici le balayage sur le LONEOS  = */
   /* ============================================== */
   k=0;
   if (typecat==mc_LONEOSCOMP) {   
      while (p_index[k].flag!=-1) {
         /*=== balayage des zones trouvees .ACC ===*/
         k=0;
         while (p_index[k].flag!=-1) {
            if (typecat==mc_LONEOSCOMP) {
               sprintf(nom,"%sloneos%sZONP%04d.ACC",path_astromcatalog,slash,p_index[k].indexSPD*75);
            }
            if ((acc=fopen(nom,"r"))==NULL) {
               free(p_index);
               if (outfilename!=NULL) {fclose(out_file);}
               return(12);
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
            if (typecat==mc_LONEOSCOMP) { offset=(offset-1)*24; }
            p_index[k].offset=offset;
            p_index[k].nbObjects=nbObjects;
            fclose(acc);
            k++;
         }
         
         /*=== balayage des zones trouvees .CAT ===*/
         k=0;
         while (p_index[k].flag!=-1) {
            
            if (typecat==mc_LONEOSCOMP) {
               sprintf(nom,"%sloneos%sZONP%04d.cat",path_astromcatalog,slash,p_index[k].indexSPD*75);
            }
            if ((cat=fopen(nom,"rb"))==NULL) {
               free(p_index);
               if (outfilename!=NULL) {fclose(out_file);}
               return(13);
            }
            /* deplacement sur la premiere etoile */
            fseek(cat,p_index[k].offset,SEEK_SET);
            nbObjects=p_index[k].nbObjects;
            /* lecture de toute les etoiles de la zone */
            for (i=0;i<nbObjects;i++) {
               if (typecat==mc_LONEOSCOMP) {
                  if (fread(&raL,1,4,cat)!=4) break;
                  if (fread(&deL,1,4,cat)!=4) break;
                  if (fread(&smu,1,2,cat)!=2) break;
                  if (fread(&smb,1,2,cat)!=2) break;
                  if (fread(&smv,1,2,cat)!=2) break;
                  if (fread(&smr,1,2,cat)!=2) break;
                  if (fread(&smi,1,2,cat)!=2) break;
                  if (fread(&smj,1,2,cat)!=2) break;
                  if (fread(&smh,1,2,cat)!=2) break;
                  if (fread(&smk,1,2,cat)!=2) break;
                  ra=(double)raL/360000.0;
                  de=(double)deL/360000.0-90.0;
                  mag_red=((double)smr)/1000.0;
                  mag_green=((double)smv)/1000.0;
                  mag_bleue=((double)smb)/1000.0;
                  mag_i=((double)smi)/1000.0;
               }
               mc_util_astrom_radec2xy(&p,ra/(180/(PI)),de/(180/(PI)),&XXX,&YYY);
               if ((XXX>=XXXmin && XXX<XXXmax && YYY>=YYYmin && YYY<YYYmax)&&(nbtot<nbobjmax)) {
                  if ((mag_bleue>=p.magbinf)&&(mag_bleue<=p.magbsup)&&(mag_red>=p.magrinf)&&(mag_red<=p.magrsup)) {
                     /*if (XXX>=0.0 && XXX<(double)nb_pixel_x && YYY>=0.0 && YYY<(double)nb_pixel_y) {*/
                     /*=== ecriture d'une ligne dans le fichier USNO.LST ===*/
                     ppx=(double)XXX;
                     ppy=(double)YYY;
                     compteur=compteur+1;
                     if (outfilename!=NULL) {
                        if ((fprintf(out_file,"%f %f %.3f %.3f %.3f %.3f %.2f %.2f 4 \n",
                           ra,de,mag_bleue,mag_green,mag_red,mag_i,ppx,ppy))<0) {
                           fclose(cat);
                           if (outfilename!=NULL) {fclose(out_file);}
                           free(p_index);
                           return(10);
                        }
                     }
                     if (objs!=NULL) {
                        (objs+nbtot)->ra=ra;
                        (objs+nbtot)->dec=de;
                        (objs+nbtot)->magb=(short)(smb);
                        (objs+nbtot)->magv=(short)(smv);
                        (objs+nbtot)->magr=(short)(smr);
                        (objs+nbtot)->magi=(short)(smi);
                        (objs+nbtot)->x=(float)(ppx);
                        (objs+nbtot)->y=(float)(ppy);
                        (objs+nbtot)->origin='4';
                     }
                     j++;
                     nbtot++;
                  }
               }
            }
            fclose(cat);
            k++;
         }
      }
   }
   
   /*==== fermeture du fichier liste ====*/
   if (outfilename!=NULL) {fclose(out_file);}
   free(p_index);
   
   /* --- fin de la routine de Christian ---*/
   
   *nbobjs=nbtot;
   return(0);
}

/*************** COMPUTEUSNOINDEXS ********************/
/* Calcul de la zone d'ascension droite et de la zone */
/* de South Polar Declination a partir de l'ascension */
/* droite et de la declinaison.                       */
/*====================================================*/
void mc_ComputeUsnoIndexs(double ra,double de,int *indexSPD,int *indexRA)
{
/*-------------------------------------------*/
/* On determine la bande de declinaison      */
/* Il y a 24 bandes de 7.5d a partir de -90d */
/*-------------------------------------------*/
if (de>=(PI)/2.-1.0e-9)
   *indexSPD=23;
else
   *indexSPD=(int)floor(mc_R2D(de+(PI)/2.)/7.5);

/*---------------------------------------------------*/
/* On determine l'index dans les 96 zones de 15' en  */
/* ascension droite. ((ra/15)*60)/15: transformation */
/* en heures puis en minutes puis calcul de l'index  */
/*---------------------------------------------------*/
*indexRA=(int)floor((4.0*mc_R2D(ra))/15.0);
}

/*************** R2D ***************/
/* Conversion de radiant en degres */
/***********************************/
double mc_R2D(double a)
{
return(a*57.29577951);
}

/*************** D2R ***************/
/* Conversion de radiant en degres */
/***********************************/
double mc_D2R(double a)
{
return(a/57.29577951);
}

/*=========================================================*/
/* Transformation de Big en Little Endian (et le contraire */
/* d'ailleurs...!!!). L'entier 32 bits ABCD est transforme */
/* en DCBA.                                                */
/*=========================================================*/
int mc_Big2LittleEndianLong(int l)
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
double mc_GetUsnoBleueMagnitude(int magL)
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
double mc_GetUsnoRedMagnitude(int magL)
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

int mc_util_astrom_radec2xy(mc_ASTROM *p,double ra,double dec, double *x,double *y)
/***************************************************************************/
/* Passage ra,dec -> x,y                                                   */
/***************************************************************************/
/* ra,dec en radians.                                                      */
/***************************************************************************/
{
   double sindec,cosdec,sindec0,cosdec0,cosrara0,sinrara0;
   double h,det;
   double dra,ddec;
   /* --- passage ra,dec -> x,y ---*/
   sindec=sin(dec);
   cosdec=cos(dec);
   sindec0=sin(p->crval2);
   cosdec0=cos(p->crval2);
   cosrara0=cos(ra-p->crval1);
   sinrara0=sin(ra-p->crval1);
   h=sindec*sindec0+cosdec*cosdec0*cosrara0;
   dra=cosdec*sinrara0/h;
   ddec=(sindec*cosdec0-cosdec*sindec0*cosrara0)/h;
   det=p->cd22*p->cd11-p->cd12*p->cd21;
   if (det==0) {*x=*y=0.;} else {
      *x=p->crpix1 - (p->cd12*ddec-p->cd22*dra) / det -.5;
      *y=p->crpix2 + (p->cd11*ddec-p->cd21*dra) / det -.5;
   }
   return(0);
}


int mc_util_astrom_xy2radec(mc_ASTROM *p, double x,double y,double *ra,double *dec)
/***************************************************************************/
/* Passage  x,y -> ra,dec                                                  */
/***************************************************************************/
/* ra,dec en radians.                                                      */
/***************************************************************************/
{
   double delta,gamma;
   double dra,ddec;
   /* --- passage x,y -> ra,dec ---*/
   x=x+.5;
   y=y+.5;
   dra=p->cd11*(x-p->crpix1)+p->cd12*(y-p->crpix2);
   ddec=p->cd21*(x-p->crpix1)+p->cd22*(y-p->crpix2);
   delta=cos(p->crval2)-ddec*sin(p->crval2);
   gamma=sqrt(dra*dra+delta*delta);
   *ra=p->crval1+atan(dra/delta);
   if (*ra<0) {*ra+=(2*PI);}
   if (*ra>(2*PI)) {*ra-=(2*PI);}
   *dec=atan((sin(p->crval2)+ddec*cos(p->crval2))/gamma);
   return(0);
}



