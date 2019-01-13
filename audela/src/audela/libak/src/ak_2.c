/* ak_2.c
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
/* C Functions for photometric parallax computations.                      */
/*                                                                         */
/* Theoretical background :                                                */
/*                                                                         */
/* These functions allow to create Av maps from near infrared photometry   */
/* in J, H and K bands. The principle is that (JHK) observed of a star is  */
/* related to its absolute intrinsic (JHK) by the followin formula :       */
/*                                                                         */
/* Jobs = Jabs + MD + E(J-V)*Av                                            */
/* Hobs = Habs + MD + E(H-V)*Av                                            */
/* Kobs = Kabs + MD + E(K-V)*Av                                            */
/*                                                                         */
/* Where:                                                                  */
/* Av is the Visual extinction in the V band produced by interstellar      */
/*    matter between star and Earth.                                       */
/* DM is the Distance modulus defined as 5-log10(Dist_parsec).             */
/*                                                                         */
/* E(J-V)=0.282 E(H-V)=0.175 E(K-V)=0.112 according to                     */
/* Rieke, & Lebofsky, 1985, ApJ, 288, 618                                  */
/* (these values can be changed easilly in the source file)                */
/*                                                                         */
/* (JHK)abs lie in the zero age main sequence (ZAMS) in color/color        */
/* (colcol) and in magnitude/color (colmag) diagrams.                      */
/*                                                                         */
/* In this software, only (colcol)=(J-H)/(H-K) and (colmag)=K/(H-K)        */
/* diagrams are considered.                                                */
/*                                                                         */
/* For a given star, many couples of (Av,DM) value can verify the (JHK)obs */
/* to (JHK)abs. If nearby other stars lie behind the same interstellar     */
/* matter content, they verify other many couples of (Av,DM).              */
/* The software method consists to choose Av value of a small sky zone as  */
/* the common value of the couples (Av,DM) for many stars lying in this    */
/* zone.                                                                   */
/*                                                                         */
/* The small zone considered are tiny spherical triangles. We choose the   */
/* Hierachical Triangular Mesh (HTM) fully described in                    */
/* Kunszt, P. Z., Szalay, A. S., Thakar, A. R., 2001, "Mining the Sky",    */
/* Proceedings of the MPA/ESO/MPE Workshop held at Garching,               */
/* Germany, 31 July-4 August, 2000.                                        */
/* Edited by A. J. Banday, S. Zaroubi, and M. Bartelmann. Heidelberg:      */
/* Springer-Verlag, 2001., p.631                                           */
/*                                                                         */
/* With the HTM level=11, the sky is sliced into 33554432 triangular       */
/* zones of about 2.1 arcmin side. The HTM level is an input parameter.    */
/* The HTM level=11 is well adapted for the 2MASS catalog.                 */
/*                                                                         */
/***************************************************************************/
/*                                                                         */
/* Using this software :                                                   */
/*                                                                         */
/* 1) Prepare the input file                                               */
/* =========================                                               */
/*                                                                         */
/* You must have an input file that contains at less                       */
/* (RA,DEC,J,dJ,H,dH,K,dK) values for each star.                           */
/*                                                                         */
/* RA  : Right Ascension [decimal degrees]                                 */
/* DEC : Declination [decimal degrees]                                     */
/* J   : J magnitude                                                       */
/* dJ  : root mean square error of J magnitude                             */
/* H   : H magnitude                                                       */
/* dH  : root mean square error of H magnitude                             */
/* K   : K magnitude                                                       */
/* dK  : root mean square error of K magnitude                             */
/*                                                                         */
/* These data can be accepted as the following formats:                    */
/* filetype=1 : custom ASCII format : ra dec J dJ H dH K dK                */
/* filetype=2 : 2MASS  ASCII format : ra dec - - - - J dJ - - H dH - - K dK - - ... */
/* filetype=3 : GCS    ASCII format : ra dec z Y J H K dz dY dJ dH dK...   */
/* filetype=4 : GPS    ASCII format : ra dec J H K dJ dH dK...             */
/*                                                                         */
/* 2) Generate the (Av,DM) couples for each HTM                            */
/* ============================================                            */
/*                                                                         */
/* Use the function "ak_photometric_parallax".                             */
/* The speed is about 0.015 seconde/star with a PC 3MHz                    */
/*                                                                         */
/* 3) Generate the Av map and the DM map as FITS files                     */
/* ===================================================                     */
/*                                                                         */
/* Use the function "ak_photometric_parallax_avmap".                       */
/*                                                                         */
/***************************************************************************/
/***************************************************************************/
#include "ak_2.h"

/***************************************************************************/
/* @function ak_photometric_parallax                                       */
/*                                                                         */
/* Create an ASCII file that contains (Av,MD) for each HTM.                */
/***************************************************************************/
/*
 * @param path contains the folder name where the input file lie.
 * @param ascii_star contains the input filename (without the path).
 * @param filetype is the type of ascii_star file (see function ak_photometric_parallax_inputs).
 * @param rac is the RA center (degrees) of the map (=-1 if not needed)
 * @param decc is the DEC center (degrees) of the map (rac=-1 if not needed)
 * @param radius is the radius (degrees) form RA,DEC center of the map (rac=-1 if not needed)
 * @param htmlevel is the level of the HTM slicing (=11 for 2MASS)
 * @param savetmpfiles is a flag to generate temporary files (=0 by default)
 * @param ascii_htmav is the output file.
 * @param colcol is the filename of the colcol (J-H)/(H-K) ZAMS diagram
 * @param colmag is the filename of the colmag K/(H-K) ZAMS diagram
 * @param colcolmagtype is type of the filename contents for the ZAMS diagrams
 * @return stringresult = "" is no error. Else a text file that explains the problem.
*/
/***************************************************************************/
/*
 * colcol is filename to define the ZAMS (H-K) (J-H) diagram
 * colmag is filename to define the ZAMS (H-K) K diagram
 * colmag is filename files that each line gives couples " (H-K) K \n"
 * if colcolmagtype=0:
 *  colcol is an ASCII file. Each line gives couples " (H-K) (J-H) \n"
 *  colmag is an ASCII file. Each line gives couples " (H-K) K \n"
 * if colcolmagtype=1: colcol and colmag are generic filenames
 *  colcol_dat is a binary file. It contains the matrix of " (H-K) (J-H) \n"
 *  colcol_wcs is an ASCII file. It contains the WCS keywords of the matrix
 *     naxis1 crpix1 crval1 cdelt1 naxis2 crpix2 crval2 cdelt2
 *  colmag_dat is a binary file. It contains the matrix of " (H-K) K \n"
 *  colmag_wcs is an ASCII file. It contains the WCS keywords of the matrix
 *     naxis1 crpix1 crval1 cdelt1 naxis2 crpix2 crval2 cdelt2
 * ascii_htmav is the output file that each line gives: "HTM Av_min Av Av_max DM_min DM DM_max nStar \n"
 * where:
 * HTM is the HTM code as defined in 4 basis by Kunszt et al.
 * Av_min is the minimal Av value computed for the HTM
 * Av is the optimal Av value computed for the HTM
 * Av_max is the minimal Av value computed for the HTM
 * DM_min is the minimal DM value computed for the optimal Av value.
 * DM is the optimal DM value computed for the optimal Av value.
 * DM_max is the minimal DM value computed for the optimal Av value.
 * nStar is the number of stars used to compute (Av,MD)
*/
/***************************************************************************/
char *ak_photometric_parallax(char *path,char *ascii_star,int filetype, double rac, double decc, double radius, int htmlevel, int savetmpfiles, char *ascii_htmav, char *ascii_colcol,char *ascii_colmag,int colcolmagtype)
{
   static char stringresult[1024];
   char fullname[1024];
   int kdiag,n_diag=2;
   ak_phot_par_diag diags[2];
   ak_phot_par_mag *mags;
   ak_phot_par_diag avmds,avmdhtms;
   int n_star,kstar,kav,kmd;
   double avj,avh,avk;
   double av,md;
   double magj,magh,magk;
   double sigmagj,sigmagh,sigmagk;
   double sigmagjh,sigmaghk;
   double x0,y0,xa,ya;
   double x1,y1,xb,yb;
   int xi,yi;
   double total0,total1;
   int naxis1,naxis2;
   char line[1024];
   int level,khtm,k,lenlevel;
   char htm[20],htm0[20];
   ak_phot_par_htmsort *htmsort;
   double deg2rad;
   FILE *fout,*fstar;
   double *avprofile,*dmprofile;
   int n_star0;
   /*
   ak_phot_par_diag avmdins,avmdouts,avmdinouts;
   */
   double avmax,mdmax;
   int khtmm,kstarr;
   double magjj,maghh,magkk;
   int makeconv=1;
   int khtm1,khtm2;
   double cosrac,sinrac,cosdecc,sindecc;
   double ra,dec,c;

   strcpy(stringresult,"");
   if (strcmp(path,"")==0) {
      strcpy(path,".");
   }

   if (colcolmagtype==0) {
      /* --- colcol ---*/
      diags[0].cdelt1=0.01;
      diags[0].sigma1=0.05;
      diags[0].cdelt2=0.01;
      diags[0].sigma2=0.05;
      sprintf(fullname,"%s/%s",path,ascii_colcol);
      strcpy(stringresult,ak_photometric_parallax_diagram(fullname,"colcol",0.05,&diags[0]));
      if (strcmp(stringresult,"")!=0) {
         return stringresult;
      }
      /* --- colmag ---*/
      diags[1].cdelt1=0.01;
      diags[1].sigma1=0.05;
      diags[1].cdelt2=-0.1;
      diags[1].sigma2=0.5;
      sprintf(fullname,"%s/%s",path,ascii_colmag);
      strcpy(stringresult,ak_photometric_parallax_diagram(fullname,"colmag",0.5,&diags[1]));
      if (strcmp(stringresult,"")!=0) {
         free(diags[0].mat);
         free(diags[0].matconv);
         return stringresult;
      }
   } else {
      /* --- colcol ---*/
      sprintf(fullname,"%s/%s",path,ascii_colcol);
      strcpy(stringresult,ak_photometric_parallax_loaddiagram(fullname,&diags[0]));
      if (strcmp(stringresult,"")!=0) {
         return stringresult;
      }
      /* --- colmag ---*/
      sprintf(fullname,"%s/%s",path,ascii_colmag);
      strcpy(stringresult,ak_photometric_parallax_loaddiagram(fullname,&diags[1]));
      if (strcmp(stringresult,"")!=0) {
         free(diags[0].mat);
         free(diags[0].matconv);
         return stringresult;
      }
   }

   /* --- create an empty AVDM image for a star ---*/
   avmds.cdelt1=0.1;
   avmds.crpix1=0.;
   avmds.crval1=0.;
   avmds.naxis1=(int)fabs(30./avmds.cdelt1);
   avmds.cdelt2=0.1;
   avmds.crpix2=0.;
   avmds.crval2=0.;
   avmds.naxis2=(int)fabs(30./avmds.cdelt2);
   avmds.mat=(float*)calloc(avmds.naxis1*avmds.naxis2,sizeof(float));
   if (avmds.mat==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      strcpy(stringresult,"Error. Cannot allocate memory for avmds.mat");
      return stringresult;
   }

   /* --- create an empty AVDM image for a all stars of a same HTM ---*/
   avmdhtms.cdelt1=avmds.cdelt1;
   avmdhtms.crpix1=avmds.crpix1;
   avmdhtms.crval1=avmds.crval1;
   avmdhtms.naxis1=avmds.naxis1;
   avmdhtms.cdelt2=avmds.cdelt2;
   avmdhtms.crpix2=avmds.crpix2;
   avmdhtms.crval2=avmds.crval2;
   avmdhtms.naxis2=avmds.naxis2;
   avmdhtms.mat=(float*)calloc(avmds.naxis1*avmds.naxis2,sizeof(float));
   if (avmdhtms.mat==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      strcpy(stringresult,"Error. Cannot allocate memory for avmdhtms.mat");
      return stringresult;
   }

   /* --- create an empty AVDM image for a all stars of all extincted HTM ---*/
   /*
   avmdins.cdelt1=avmds.cdelt1;
   avmdins.crpix1=avmds.crpix1;
   avmdins.crval1=avmds.crval1;
   avmdins.naxis1=avmds.naxis1;
   avmdins.cdelt2=avmds.cdelt2;
   avmdins.crpix2=avmds.crpix2;
   avmdins.crval2=avmds.crval2;
   avmdins.naxis2=avmds.naxis2;
   avmdins.mat=(float*)calloc(avmds.naxis1*avmds.naxis2,sizeof(float));
   if (avmdins.mat==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      strcpy(stringresult,"Error. Cannot allocate memory for avmdins.mat");
      return stringresult;
   }
   avmdouts.cdelt1=avmds.cdelt1;
   avmdouts.crpix1=avmds.crpix1;
   avmdouts.crval1=avmds.crval1;
   avmdouts.naxis1=avmds.naxis1;
   avmdouts.cdelt2=avmds.cdelt2;
   avmdouts.crpix2=avmds.crpix2;
   avmdouts.crval2=avmds.crval2;
   avmdouts.naxis2=avmds.naxis2;
   avmdouts.mat=(float*)calloc(avmds.naxis1*avmds.naxis2,sizeof(float));
   if (avmdouts.mat==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      strcpy(stringresult,"Error. Cannot allocate memory for avmdouts.mat");
      return stringresult;
   }
   avmdinouts.cdelt1=avmds.cdelt1;
   avmdinouts.crpix1=avmds.crpix1;
   avmdinouts.crval1=avmds.crval1;
   avmdinouts.naxis1=avmds.naxis1;
   avmdinouts.cdelt2=avmds.cdelt2;
   avmdinouts.crpix2=avmds.crpix2;
   avmdinouts.crval2=avmds.crval2;
   avmdinouts.naxis2=avmds.naxis2;
   avmdinouts.mat=(float*)calloc(avmds.naxis1*avmds.naxis2,sizeof(float));
   if (avmdinouts.mat==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      strcpy(stringresult,"Error. Cannot allocate memory for avmdinouts.mat");
      return stringresult;
   }
   */

   /* --- extinction coefficients ---*/
   avj=0.282;
   avh=0.175;
   avk=0.112;

   /* --- read magnitude file ---*/
   n_star=0;
   sprintf(fullname,"%s/%s",path,ascii_star);
   strcpy(stringresult,ak_photometric_parallax_inputs(fullname,filetype,&mags,&n_star));
   if (strcmp(stringresult,"")!=0) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      free(avmdhtms.mat);
      return stringresult;
   }

   avprofile=(double*)calloc(avmdhtms.naxis1,sizeof(double));
   if (avprofile==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      free(avmdhtms.mat);
      free(mags);
      strcpy(stringresult,"Error. Cannot allocate memory for avprofile");
      return stringresult;
   }

   dmprofile=(double*)calloc(avmdhtms.naxis2,sizeof(double));
   if (dmprofile==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      free(avmdhtms.mat);
      free(mags);
      free(avprofile);
      strcpy(stringresult,"Error. Cannot allocate memory for dmprofile");
      return stringresult;
   }

   /* --- loop over stars to compute the HTM for each star ---*/
   level=htmlevel;
   lenlevel=level+3;
   htmsort=(ak_phot_par_htmsort*)calloc(n_star,sizeof(ak_phot_par_htmsort));
   if (htmsort==NULL) {
      free(diags[0].mat);
      free(diags[0].matconv);
      free(diags[1].mat);
      free(diags[1].matconv);
      free(avmds.mat);
      free(avmdhtms.mat);
      free(mags);
      free(avprofile);
      free(dmprofile);
      strcpy(stringresult,"Error. Cannot allocate memory for htmint");
      return stringresult;
   }
   deg2rad=(AK_PI)/180.;
   if (rac>=0) {
      cosrac=cos(rac*deg2rad);
      sinrac=sin(rac*deg2rad);
      cosdecc=cos(decc*deg2rad);
      sindecc=sin(decc*deg2rad);
      radius*=deg2rad;
   }
   for (kstar=0;kstar<n_star;kstar++) {
      /* --- check if the star is in the valid area ---*/
      ra=mags[kstar].ra*deg2rad;
      dec=mags[kstar].dec*deg2rad;
      htmsort[kstar].index=-1;
      if (rac>=0) {
         c=sindecc*sin(dec)+cosdecc*cos(dec)*cos(rac*deg2rad-ra);
         if (c<-1.) {c=-1.;}
         if (c>1.) {c=1.;}
         c=acos(c);
         if (c>radius) {
            continue;
         }
      }
      /* --- compute the hierarchical triangular mesh code --- */
      ak_photometric_parallax_radec2htm(ra,dec,level,htm);
      /* --- add an element to the vector of HTM codes --- */
      strcpy(htmsort[kstar].htm,htm);
      htmsort[kstar].index=kstar;
   }

   /* --- sort the HTM codes ---*/
   ak_photometric_parallax_quicksort_htmsort(htmsort,0,n_star-1);

   /* --- loop over HTMs to compute the diagrams---*/
   sprintf(fullname,"%s/%s",path,ascii_htmav);
   fout=fopen(fullname,"wt");
   strcpy(htm0,"-1");
   n_star0=0;
   khtm1=0;
   sprintf(fullname,"%s/deredened_stars.txt",path);
   fstar=fopen(fullname,"wt");
   for (khtm=0;khtm<n_star;khtm++) {
      kstar=htmsort[khtm].index;
      if (kstar<0) {
         continue;
      }
      strcpy(htm,htmsort[khtm].htm);
      if (strcmp(htm,htm0)!=0) {
         /* --- save the current AVDM_htm0.fit image ---*/
         if (strcmp(htm0,"-1")!=0) {
            if (savetmpfiles>0) {
               sprintf(line,"%s/avmd_%s.fit",path,htm0);
               ak_photometric_parallax_savefits(avmdhtms.mat,avmdhtms.naxis1,avmdhtms.naxis2,line,NULL);
            }
            /* --- Av of this HTM --- */
            ak_photometric_parallax_av_extraction(fout,path,avmdhtms,avprofile,dmprofile,htm0,n_star0,savetmpfiles,&avmax,&mdmax);
            /*
            if (avmax>=5) {
               for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
                  avmdins.mat[k]+=avmdhtms.mat[k]; 
               }
            } else if (avmax<=1){
               for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
                  avmdouts.mat[k]+=avmdhtms.mat[k]; 
               }
            } else {
               for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
                  avmdinouts.mat[k]+=avmdhtms.mat[k]; 
               }
            }
            */
            /* --- seconde passe sur les etoiles de ce triangle */
            khtm2=khtm;
            av=avmax;
            md=mdmax;
            for (khtmm=khtm1;khtmm<=khtm2;khtmm++) {
               kstarr=htmsort[khtmm].index;
               if (kstarr<0) {
                  continue;
               }
               /* --- apparent magnitudes ---*/
               magj=mags[kstarr].magj;
               magh=mags[kstarr].magh;
               magk=mags[kstarr].magk;
               /* --- absolute deredened magnitudes ---*/
               magjj=magj-(av*avj+md);
               maghh=magh-(av*avh+md);
               magkk=magk-(av*avk+md);
               /* --- */
               fprintf(fstar,"%9.5f %+9.5f %6.3f %6.3f %6.3f %4.2f %4.2f %6.3f %6.3f %6.3f\n",
                  mags[kstarr].ra,mags[kstarr].dec,
                  magj,magh,magk,
                  av,md,
                  magjj,maghh,magkk);
            }
            khtm1=khtm2+1;
         }

         /* --- clear the AVDM_htm0.fit image for a new HTM --- */
         for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
            avmdhtms.mat[k]=(float)0.; 
         }
         strcpy(htm0,htm);
         n_star0=0;
      }
      /* --- compute the AVDM image for this star ---*/
      /* --- read the magnitudes of this star ---*/
      magj=mags[kstar].magj;
      magh=mags[kstar].magh;
      magk=mags[kstar].magk;
      sigmagj=mags[kstar].sigmagj;
      sigmagh=mags[kstar].sigmagh;
      sigmagk=mags[kstar].sigmagk;
      sigmaghk=sqrt(sigmagh*sigmagh+sigmagk*sigmagk);
      sigmagjh=sqrt(sigmagj*sigmagj+sigmagh*sigmagh);
      /* --- convolve the diagrams by the uncetrtainties of this star ---*/
      if (makeconv==1) {
         ak_photometric_parallax_convgauss(&diags[0],sigmaghk,sigmagjh);
         ak_photometric_parallax_convgauss(&diags[1],sigmaghk,sigmagk);
      }
      /* --- compute the (x0,y0) in the colcol diag ---*/
      x0=diags[0].crpix1+((magh-magk)-diags[0].crval1)/diags[0].cdelt1;
      y0=diags[0].crpix2+((magj-magh)-diags[0].crval2)/diags[0].cdelt2;
      /* --- compute the (x1,y1) in the colmag diag ---*/
      x1=diags[1].crpix1+((magh-magk)-diags[1].crval1)/diags[1].cdelt1;
      y1=diags[1].crpix2+(magk-diags[1].crval2)/diags[1].cdelt2;      
      /* --- double loops on the Av,MD diagram ---*/
      /* --- loop over the Avs ---*/
      for (kav=0;kav<avmds.naxis1;kav++) {
         av=(kav-avmds.crpix1)*avmds.cdelt1+avmds.crval1;
         /* --- compute the deredded (xa,ya) in the colcol diag ---*/
         xa=x0-av*(avh-avk)/diags[0].cdelt1;
         ya=y0-av*(avj-avh)/diags[0].cdelt2;
         xi=(int)xa;
         yi=(int)ya;
         naxis1=diags[0].naxis1;
         naxis2=diags[0].naxis2;
         if (xi<0) continue;
         if (xi>=naxis1) continue;
         if (yi<0) continue;
         if (yi>=naxis2) continue;
         if (makeconv==1) {
            total0=diags[0].matconv[yi*naxis1+xi];
         } else {
            total0=diags[0].mat[yi*naxis1+xi];
         }
         if (total0==0.) continue;
         /* --- loop over the MDs ---*/
         for (kmd=0;kmd<avmds.naxis2;kmd++) {
            md=(kmd-avmds.crpix2)*avmds.cdelt2+avmds.crval2;
            /* --- compute the deredded and distance corrected (xb,yb) in the colmag diag ---*/
            xb=x1-av*(avh-avk)/diags[1].cdelt1;
            yb=y1-(av*avk+md)/diags[1].cdelt2;
            xi=(int)xb;
            yi=(int)yb;
            naxis1=diags[1].naxis1;
            naxis2=diags[1].naxis2;
            if (xi<0) continue;
            if (xi>=naxis1) continue;
            if (yi<0) continue;
            if (yi>=naxis2) continue;
            if (makeconv==1) {
               total1=diags[1].matconv[yi*naxis1+xi];
            } else {
               total1=diags[1].mat[yi*naxis1+xi];
            }
            avmds.mat[kmd*avmds.naxis1+kav]=(float)sqrt(total0*total1);
         }
      }
      /* --- add the AVDM image of this star to the current AVDM_htm0.fit image ---*/
      n_star0++;
      for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
         avmdhtms.mat[k]+=avmds.mat[k]; 
         avmds.mat[k]=(float)0.; 
      }
   }
   /* --- save the last HTM ---*/
   if (savetmpfiles>0) {
      sprintf(line,"%s/avmd_%s.fit",path,htm0); /* a parametrer avec level */
      ak_photometric_parallax_savefits(avmdhtms.mat,avmdhtms.naxis1,avmdhtms.naxis2,line,NULL);
   }
   /* --- Av of this HTM --- */
   ak_photometric_parallax_av_extraction(fout,path,avmdhtms,avprofile,dmprofile,htm0,n_star0,savetmpfiles,&avmax,&mdmax);
   /*
            if (avmax>=5) {
               for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
                  avmdins.mat[k]+=avmdhtms.mat[k]; 
               }
            } else if (avmax<=1) {
               for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
                  avmdouts.mat[k]+=avmdhtms.mat[k]; 
               }
            } else {
               for (k=0;k<avmds.naxis1*avmds.naxis2;k++) { 
                  avmdinouts.mat[k]+=avmdhtms.mat[k]; 
               }
            }
    */
   /* --- close the HTM, AV file */
   fclose(fout);
   fclose(fstar);

   /*
   sprintf(line,"%s/avmdin.fit",path);
   ak_photometric_parallax_savefits(avmdins.mat,avmdins.naxis1,avmdins.naxis2,line,NULL);
   sprintf(line,"%s/avmdout.fit",path);
   ak_photometric_parallax_savefits(avmdouts.mat,avmdins.naxis1,avmdins.naxis2,line,NULL);
   sprintf(line,"%s/avmdinout.fit",path);
   ak_photometric_parallax_savefits(avmdinouts.mat,avmdins.naxis1,avmdins.naxis2,line,NULL);
   */

   /* --- free vectors ---*/
   free(htmsort);
   /* --- loop to free the maps AvMD for each star ---*/
   for (kdiag=1;kdiag<n_diag;kdiag++) {
      free(diags[kdiag].mat);
      free(diags[kdiag].matconv);
   }
   free(avmds.mat);
   free(avmdhtms.mat);
   /*
   free(avmdins.mat);
   free(avmdouts.mat);
   free(avmdinouts.mat);
   */
   free(avprofile);
   free(dmprofile);
   free(mags);
   /* --- return the result ---*/
   return stringresult;
}

/***************************************************************************/
/* @function ak_photometric_parallax_avmap                                 */
/*                                                                         */
/* Create Av and DM maps as two FITS files from an ASCII file (param       */
/* ascii_htmav) generated by the function ak_photometric_parallax.         */
/***************************************************************************/
/*
 * @param path contains the folder name where the input file lie.
 * @param ascii_htmav is the input file (without the path).
 * @param fitsnameav is the output FITS file of Av map (without the path).
 * @param fitsnamemd is the output FITS file of Av map (without the path).
 * @param naxis1 is the number of pixels along RA axis of the output maps.
 * @param naxis2 is the number of pixels along DEC axis of the output maps.
 * @param goconvolve=1 to convolve the map (else=0 not to convolve).
 * @return stringresult = "" is no error. Else a text file that explains the problem.
*/
/***************************************************************************/
/*
 * The maps are real FITS files (BITPIX=-32) including World Coordinates Keyword.
*/
/***************************************************************************/
char *ak_photometric_parallax_avmap(char *path,char *ascii_htmav, char *fitsnameav, char *fitsnamemd,int naxis1,int naxis2, int goconvolve)
{
   static char stringresult[1024];
   char fullname[1024];
   ak_phot_par_htmav *htmavs;
   ak_phot_par_wcs wcs;
   int n_htms,khtm;
   int niter,k,kk,n,nn,kx,ky;
   double ra,dec,ra0,dec0,ra1,dec1,ra2,dec2;
   double x,y,x0,y0,x1,y1,x2,y2;
   double ramin,ramax,decmin,decmax;
   double *ras,*decs,av=0.,md=0.;
   float *imgav,*imgmd,*imgconvav,*imgconvmd;
   char htm[20],htm0[20];
   double dx10,dy10,dx20,dy20,dx21,dy21;
   double dista,distb,distc,anga,angb,angc;
   double r;
   double r2,dx,dx2,dy,dy2,d2,avconv,mdconv;
   int rmax,kx1,kx2,ky1,ky2,kxx,kyy;

   /* --- read htm,Av file ---*/
   n_htms=0;
   sprintf(fullname,"%s/%s",path,ascii_htmav);
   strcpy(stringresult,ak_photometric_parallax_read_htmav(fullname,&htmavs,&n_htms));
   if (strcmp(stringresult,"")!=0) {
      return stringresult;
   }

   /* --- for each htm, we compute the triangle corner coordinates ---*/
   n=3*n_htms;
   ras=(double*)calloc(n,sizeof(double));
   if (ras==NULL) {
      free(htmavs);
      strcpy(stringresult,"Error. Cannot allocate memory for ras");
      return stringresult;
   }
   decs=(double*)calloc(n,sizeof(double));
   if (decs==NULL) {
      free(htmavs);
      free(ras);
      strcpy(stringresult,"Error. Cannot allocate memory for decs");
      return stringresult;
   }
   for (k=0,khtm=0;khtm<n_htms;khtm++) {
      ak_photometric_parallax_htm2radec(htmavs[khtm].htm,&ra,&dec,&niter,&ra0,&dec0,&ra1,&dec1,&ra2,&dec2);
      ras[k] =ra0;
      decs[k]=dec0;
      k++;
      ras[k] =ra1;
      decs[k]=dec1;
      k++;
      ras[k] =ra2;
      decs[k]=dec2;
      k++;
   }

   /* --- we compute the extrema for ra and dec ---*/
   ak_photometric_parallax_quicksort_double(ras,0,n-1);
   /* --- take account for the 23h->0h passage */
   for (k=1;k<n;k++) {
      if ((ras[k]-ras[k-1])>(AK_PI)) {
         nn=kk;
         for (kk=1;kk<nn;kk++) {
            ras[kk]+=2.*(AK_PI);
         }
      }
   }
   ak_photometric_parallax_quicksort_double(ras,0,n-1);
   ak_photometric_parallax_quicksort_double(decs,0,n-1);
   ramin=ras[0];
   ramax=ras[n-1];
   decmin=decs[0];
   decmax=decs[n-1];
   free(ras);
   free(decs);

   /* --- fill the WCS paramaters ---*/
   wcs.crpix1=naxis1/2.;
   wcs.crpix2=naxis2/2.;
   wcs.crval1=(ramax+ramin)/2.;
   if (wcs.crval1>=2.*(AK_PI)) { wcs.crval1-=2.*(AK_PI); }
   wcs.crval2=(decmax+decmin)/2.;
   wcs.cdelt1=-(ramax-ramin)/naxis1;
   wcs.cdelt2=(decmax-decmin)/naxis2;
   if (wcs.cdelt1>wcs.cdelt2) {
      wcs.cdelt2=-wcs.cdelt1;
   } else {
      wcs.cdelt1=-wcs.cdelt2;
   }
   wcs.crota2=0.;
   wcs.cd11=wcs.cdelt1*cos(wcs.crota2);
   wcs.cd12=fabs(wcs.cdelt2)*wcs.cdelt1/fabs(wcs.cdelt1)*sin(wcs.crota2);
   wcs.cd21=-fabs(wcs.cdelt1)*wcs.cdelt2/fabs(wcs.cdelt2)*sin(wcs.crota2);
   wcs.cd22=wcs.cdelt2*cos(wcs.crota2);

   /* --- create an empty image for Av map */
   n=naxis1*naxis2;
   imgav=(float*)calloc(n,sizeof(float));
   if (imgav==NULL) {
      free(htmavs);
      strcpy(stringresult,"Error. Cannot allocate memory for imgav");
      return stringresult;
   }

   /* --- create an empty image for DM map */
   n=naxis1*naxis2;
   imgmd=(float*)calloc(n,sizeof(float));
   if (imgmd==NULL) {
      free(htmavs);
      free(imgav);
      strcpy(stringresult,"Error. Cannot allocate memory for imgmd");
      return stringresult;
   }

   /* --- fill the image with Av values */
   strcpy(htm0,"-1");
   for (kx=0;kx<naxis1;kx++) {
      x=kx;
      for (ky=0;ky<naxis2;ky++) {
         y=ky;
         ak_photometric_parallax_xy2radec(wcs,x,y,&ra,&dec);
         ak_photometric_parallax_radec2htm(ra,dec,niter,htm);
         if (strcmp(htm,htm0)!=0) {
            /* --- This algorithm must be accelerated in the future */
            av=-1;
            md=-1;
            for (k=0;k<n_htms;k++) {
               if (strcmp(htm,htmavs[k].htm)==0) {
                  av=htmavs[k].av;
                  md=htmavs[k].md;
                  break;
               }
            }
            strcpy(htm0,htm);
         }
         imgav[ky*naxis1+kx]=(float)av;
         imgmd[ky*naxis1+kx]=(float)md;
      }
   }
   sprintf(fullname,"%s/%s",path,fitsnameav);
   ak_photometric_parallax_savefits(imgav,naxis1,naxis2,fullname,&wcs);
   sprintf(fullname,"%s/%s",path,fitsnamemd);
   ak_photometric_parallax_savefits(imgmd,naxis1,naxis2,fullname,&wcs);

   /* === convolution by a circle ===*/
   if (goconvolve==1) {
      /* --- coordinates of the center of images */
      x=naxis1/2.;
      y=naxis2/2.,
      ak_photometric_parallax_xy2radec(wcs,x,y,&ra,&dec);
      /* --- compute the hierachical triangular mesh code of the center --- */
      ak_photometric_parallax_radec2htm(ra,dec,niter,htm);
      /* --- search for the corners of the central triangle ---*/
      ak_photometric_parallax_htm2radec(htm,&ra,&dec,&niter,&ra0,&dec0,&ra1,&dec1,&ra2,&dec2);
      ak_photometric_parallax_radec2xy(wcs,ra0,dec0,&x0,&y0);
      ak_photometric_parallax_radec2xy(wcs,ra1,dec1,&x1,&y1);
      ak_photometric_parallax_radec2xy(wcs,ra2,dec2,&x2,&y2);
      /* --- compute r the radius of the max inside circle ---*/
      dx10=x1-x0;
      dx20=x2-x0;
      dx21=x2-x1;
      dy10=y1-y0;
      dy20=y2-y0;
      dy21=y2-y1;
      dista=sqrt(dx10*dx10+dy10*dy10);
      distb=sqrt(dx20*dx20+dy20*dy20);
      distc=sqrt(dx21*dx21+dy21*dy21);
      anga=acos((dx20*dx21+dy20*dy21)/distb/distc);
      angb=acos((dx10*dx21+dy10*dy21)/dista/distc);
      angc=acos((dx10*dx20+dy10*dy20)/dista/distb);
      r=dista*cos(angb/2.)*cos(angc/2.)/cos(anga/2.);
      /* --- create an empty image for Av map */
      n=naxis1*naxis2;
      imgconvav=(float*)calloc(n,sizeof(float));
      if (imgav==NULL) {
         free(htmavs);
         free(imgav);
         free(imgmd);
         strcpy(stringresult,"Error. Cannot allocate memory for imgconvav");
         return stringresult;
      }
      /* --- create an empty image for DM map */
      n=naxis1*naxis2;
      imgconvmd=(float*)calloc(n,sizeof(float));
      if (imgmd==NULL) {
         free(htmavs);
         free(imgav);
         free(imgmd);
         free(imgconvav);
         strcpy(stringresult,"Error. Cannot allocate memory for imgconvmd");
         return stringresult;
      }
      /* --- convolution ---*/
      r2=r*r;
      rmax=(int)ceil(r);
      for (kx=0;kx<naxis1;kx++) {
         kx1=kx-rmax;
         if (kx1<0) {kx1=0;}
         kx2=kx+rmax;
         if (kx2>=naxis1) {kx2=naxis1-1;}
         for (ky=0;ky<naxis2;ky++) {
            ky1=ky-rmax;
            if (ky1<0) {ky1=0;}
            ky2=ky+rmax;
            if (ky2>=naxis2) {ky2=naxis2-1;}
            avconv=0.;
            mdconv=0.;
            n=0;
            nn=0;
            for (kxx=kx1;kxx<=kx2;kxx++) {
               dx=kxx-kx;
               dx2=dx*dx;
               for (kyy=ky1;kyy<=ky2;kyy++) {
                  dy=kyy-ky;
                  dy2=dy*dy;
                  d2=dx2+dy2;
                  if (d2<r2) {
                     nn++;
                     av=imgav[kyy*naxis1+kxx];
                     if (av<0) {
                        continue;
                     }
                     n++;
                     md=imgmd[kyy*naxis1+kxx];
                     avconv+=av;
                     mdconv+=md;
                  }
               }
            }
            if (n>nn/2) {
               avconv/=n;
               mdconv/=n;
            } else {
               avconv=-1.;
               mdconv=-1.;
            }
            imgconvav[ky*naxis1+kx]=(float)avconv;
            imgconvmd[ky*naxis1+kx]=(float)mdconv;
         }
      }
      /* --- save convolved images ---*/
      sprintf(fullname,"%s/%s",path,fitsnameav);
      ak_photometric_parallax_savefits(imgconvav,naxis1,naxis2,fullname,&wcs);
      sprintf(fullname,"%s/%s",path,fitsnamemd);
      ak_photometric_parallax_savefits(imgconvmd,naxis1,naxis2,fullname,&wcs);
      free(imgconvav);
      free(imgconvmd);
   }

   free(imgav);
   free(imgmd);
   free(htmavs);
   /* --- return the result ---*/
   return stringresult;
}

/***************************************************************************/
/***************************************************************************/
/*******    Other following functions are only internally used     *********/
/***************************************************************************/
/***************************************************************************/


/***************************************************************************/
/* Extract the most probable Av and MD from AVMD correlation diagram */
/***************************************************************************/
char *ak_photometric_parallax_av_extraction(FILE *fout, char *path, ak_phot_par_diag avmdhtms,double *avprofile,double *dmprofile,char *htm0,int n_star0,int savetmpfiles,double *avmaxi,double *mdmaxi)
{
   static char stringresult[1024];
   char fullname[1024];
   FILE *ftxt;
   int kavmax;
   double nbavtot,nbavmax;
   int kavmax1,kavmax2;
   double av1,av2,av;
   int kav,kmd;
   int kmdmax;
   double nbmdtot,nbmdmax;
   int kmdmax1,kmdmax2;
   double md1,md2,md;
   /* --- binning along MD for each Av */
   nbavmax=0.;
   kavmax=0;
   for (kav=0;kav<avmdhtms.naxis1;kav++) {
      nbavtot=0.;
      for (kmd=0;kmd<avmdhtms.naxis2;kmd++) {
         nbavtot+=avmdhtms.mat[kmd*avmdhtms.naxis1+kav];
      }
      avprofile[kav]=nbavtot;
      if (nbavtot>nbavmax) {
         nbavmax=nbavtot;
         kavmax=kav;
      }
   }
   if (savetmpfiles>0) {
      sprintf(fullname,"%s/av_%s.txt",path,htm0);
      ftxt=fopen(fullname,"wt");
      for (kav=0;kav<avmdhtms.naxis1;kav++) {
         av=(kav-avmdhtms.crpix1)*avmdhtms.cdelt1+avmdhtms.crval1;
         fprintf(ftxt,"%5.2f %f\n",av,avprofile[kav]/n_star0);
      }
      fclose(ftxt);
   }
   for (kav=kavmax;kav<avmdhtms.naxis1;kav++) {
      if (avprofile[kav]<nbavmax/2.) {
         break;
      }
   }
   kavmax2=kav;
   for (kav=kavmax;kav>=0;kav--) {
      if (avprofile[kav]<nbavmax/2.) {
         break;
      }
   }
   kavmax1=kav;
   /* --- md ---*/
   nbmdmax=0.;
   kmdmax=0;
   for (kmd=0;kmd<avmdhtms.naxis2;kmd++) {
      nbmdtot=avmdhtms.mat[kmd*avmdhtms.naxis1+kavmax];
      dmprofile[kmd]=nbmdtot;
      if (nbmdtot>nbmdmax) {
         nbmdmax=nbmdtot;
         kmdmax=kmd;
      }
   }
   if (savetmpfiles>0) {
      sprintf(fullname,"%s/dm_%s.txt",path,htm0);
      ftxt=fopen(fullname,"wt");
      for (kmd=0;kmd<avmdhtms.naxis2;kmd++) {
         md=(kmd-avmdhtms.crpix2)*avmdhtms.cdelt2+avmdhtms.crval2;
         fprintf(ftxt,"%6.3f %f\n",md,dmprofile[kmd]/n_star0);
      }
      fclose(ftxt);
   }
   for (kmd=kmdmax;kmd<avmdhtms.naxis2;kmd++) {
      if (dmprofile[kmd]<nbmdmax/2.) {
         break;
      }
   }
   kmdmax2=kmd;
   for (kmd=kmdmax;kmd>=0;kmd--) {
      if (dmprofile[kmd]<nbmdmax/2.) {
         break;
      }
   }
   kmdmax1=kmd;
   /* --- Av,DM of this HTM */
   av=(kavmax-avmdhtms.crpix1)*avmdhtms.cdelt1+avmdhtms.crval1;
   av1=(kavmax1-avmdhtms.crpix1)*avmdhtms.cdelt1+avmdhtms.crval1;
   av2=(kavmax2-avmdhtms.crpix1)*avmdhtms.cdelt1+avmdhtms.crval1;
   md=(kmdmax-avmdhtms.crpix2)*avmdhtms.cdelt2+avmdhtms.crval2;
   md1=(kmdmax1-avmdhtms.crpix2)*avmdhtms.cdelt2+avmdhtms.crval2;
   md2=(kmdmax2-avmdhtms.crpix2)*avmdhtms.cdelt2+avmdhtms.crval2;
   fprintf(fout,"%s %5.1f %5.1f %5.1f %6.3f %6.3f %6.3f %6d\n",htm0,av1,av,av2,md1,md,md2,n_star0);
   *avmaxi=av;
   *mdmaxi=md;
   return stringresult;
}

/***************************************************************************/
/* Save the *mat as a FITS file */
/***************************************************************************/
char *ak_photometric_parallax_savefits(float *mat,int naxis1, int naxis2,char *filename,ak_phot_par_wcs *wcs)
{
   static char stringresult[1024];
   FILE *f;
   char line[1024],car;
   float value0;
   char *cars0;
   int k,n,k0;
   double dx,deg2rad;
   long one= 1;
   int big_endian;
   f=fopen(filename,"wb");
   strcpy(line,"SIMPLE  =                    T / file does conform to FITS standard             ");
   fwrite(line,80,sizeof(char),f);
   strcpy(line,"BITPIX  =                  -32 / number of bits per data pixel                  ");
   fwrite(line,80,sizeof(char),f);
   strcpy(line,"NAXIS   =                    2 / number of data axes                            ");
   fwrite(line,80,sizeof(char),f);
   sprintf(line,"NAXIS1  =                  %3d / length of data axis 1                          ",naxis1);
   fwrite(line,80,sizeof(char),f);
   sprintf(line,"NAXIS2  =                  %3d / length of data axis 2                          ",naxis2);
   fwrite(line,80,sizeof(char),f);
   k0=7;
   if (wcs!=NULL) {
      deg2rad=(AK_PI)/180.;
      strcpy(line, "EQUINOX =               2000.0 / WCS keyword                                    ");
      fwrite(line,80,sizeof(char),f); k0++;
      strcpy(line, "CTYPE1  = 'RA---TAN'           / WCS keyword                                    ");
      fwrite(line,80,sizeof(char),f); k0++;
      strcpy(line, "CTYPE2  = 'DEC--TAN'           / WCS keyword                                    ");
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRPIX1  =           %10.5f / WCS keyword                                    ",wcs->crpix1);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRPIX2  =           %10.5f / WCS keyword                                    ",wcs->crpix2);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRVAL1  =           %10.6f / WCS keyword                                    ",wcs->crval1/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRVAL2  =           %10.6f / WCS keyword                                    ",wcs->crval2/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CROTA2  =           %10.6f / WCS keyword                                    ",wcs->crota2/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CDELT1  =      %15.10f / WCS keyword                                    ",wcs->cdelt1/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CDELT2  =      %15.10f / WCS keyword                                    ",wcs->cdelt2/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD11    =      %15.10f / WCS keyword                                    ",wcs->cd11/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD12    =      %15.10f / WCS keyword                                    ",wcs->cd12/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD21    =      %15.10f / WCS keyword                                    ",wcs->cd21/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD22    =      %15.10f / WCS keyword                                    ",wcs->cd22/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD1_1   =      %15.10f / WCS keyword                                    ",wcs->cd11/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD1_2   =      %15.10f / WCS keyword                                    ",wcs->cd12/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD2_1   =      %15.10f / WCS keyword                                    ",wcs->cd21/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD2_2   =      %15.10f / WCS keyword                                    ",wcs->cd22/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
   }
   strcpy(line,"END                                                                             ");
   fwrite(line,80,sizeof(char),f);
   strcpy(line,"                                                                                ");
   for (k=k0;k<=36;k++) {
      fwrite(line,80,sizeof(char),f);
   }
   /* byte order test */
   if (!(*((char *)(&one)))) {
      big_endian=1;
   } else {
      big_endian=0;
   }
   /* write data */
   for (k=0;k<naxis1*naxis2;k++) {
      value0=mat[k]; // 32=4*8bits
      if (big_endian==0) {
         cars0=(char*)&value0;
         car=cars0[0];
         cars0[0]=cars0[3];
         cars0[3]=car;
         car=cars0[1];
         cars0[1]=cars0[2];
         cars0[2]=car;
      }
      fwrite(&value0,1,sizeof(float),f);
   }
   dx=naxis1*naxis2/2880.;
   n=(int)(2880.*(dx-floor(dx)));
   value0=(float)0.;
   for (k=0;k<naxis1*naxis2;k++) {
      if (big_endian==0) {
         cars0=(char*)&value0;
         car=cars0[0];
         cars0[0]=cars0[3];
         cars0[3]=car;
         car=cars0[1];
         cars0[1]=cars0[2];
         cars0[2]=car;
      }
      fwrite(&value0,1,sizeof(float),f);
   }
   fclose(f);
   return stringresult;
}

/***************************************************************************/
/* Convolution of mat to give matconv */
/***************************************************************************/
char *ak_photometric_parallax_convgauss(ak_phot_par_diag *diags,double sigmagx, double sigmagy)
{
   static char stringresult[1024];
   int k1,k2,naxis1,naxis2;
   double sigma,sigma2;
   int largeur,largeur2,i,j,adr,k,i1,adr2,j1;
   double reste,somme,ilarg,val,*filtre;

   strcpy(stringresult,"");
   naxis1=diags->naxis1;
   naxis2=diags->naxis2;
   for (k1=0;k1<naxis1;k1++) {
      for (k2=0;k2<naxis2;k2++) {
         diags->matconv[k2*naxis1+k1]=0.;
      }
   }

   /* === convolve along the X axis ===*/
   sigma=fabs(sigmagx/diags->cdelt1);
   sigma2=sigma*sigma;
   /* --- compute the kernel width  ---*/
   largeur=(short)((float)5.*sigma+(float)1.);
   if (largeur<3) largeur=3;
   reste=fmod((double)largeur,2.);
   if (reste==(double)0.) largeur = largeur + 1;
   largeur2=(largeur-1)/2;     /* for the image border */
   /* --- compute the filter ---*/
   filtre=(double*)calloc(largeur,sizeof(double));
   somme=(double)0.;
   for (i=0;i<largeur;i++) {
      ilarg=(double)(i-largeur2);
      filtre[i]=exp(-ilarg*ilarg/2./sigma2);
      somme=somme+filtre[i];
   }
   /* --- normalize the filter to 1 ---*/
   for (i=0;i<largeur;i++) filtre[i]=filtre[i]/somme;
   /* --- convolution ---*/
   for (j=0;j<naxis2;j++) {
      adr=(int)j*naxis1;
      for (i=0;i<naxis1;i++) {
         val=0.;
         for (k=0;k<largeur;k++) {
            i1=i+k-largeur2;
            if (i1<0) i1=0;
            if (i1>naxis1-1) i1=naxis1-1;
            adr2=adr+(int)i1;
            val+=filtre[k]*(double)diags->mat[adr2];
         }
         diags->matconv[adr+(int)i]=(float)val;
      }
   }
   free(filtre);

   /* === convolve along the Y axis ===*/
   sigma=fabs(sigmagy/diags->cdelt2);
   sigma2=sigma*sigma;
   /* --- compute the kernel width  ---*/
   largeur=(short)((float)5.*sigma+(float)1.);
   if (largeur<3) largeur=3;
   reste=fmod((double)largeur,2.);
   if (reste==(double)0.) largeur = largeur + 1;
   largeur2=(largeur-1)/2;     /* for the image border */
   /* --- compute the filter ---*/
   filtre=(double*)calloc(largeur,sizeof(double));
   somme=(double)0.;
   for (i=0;i<largeur;i++) {
      ilarg=(double)(i-largeur2);
      filtre[i]=exp(-ilarg*ilarg/2./sigma2);
      somme=somme+filtre[i];
   }
   /* --- normalize the filter to 1 ---*/
   for (i=0;i<largeur;i++) filtre[i]=filtre[i]/somme;
   /* --- convolution ---*/
   for (i=0;i<naxis1;i++) {
      for (j=0;j<naxis2;j++) {
         val=0.;
         adr=(int)j*naxis1+(int)i;
         for (k=0;k<largeur;k++) {
            j1=j+k-largeur2;
            if (j1<0) j1=0;
            if (j1>naxis2-1) j1=naxis2-1;
            adr2=(int)j1*naxis1+(int)i;
            val+=filtre[k]*(double)diags->mat[adr2];
         }
         diags->matconv[adr]=(float)val;
      }
   }
   return stringresult;
}

/***************************************************************************/
/* Make an image of a diagrams from binary files */
/***************************************************************************/
/*
.wcs naxis1, crpix1, crval1, cdelt1, naxis2, crpix2, crval2, cdelt2
.bin matrix [naxis1][naxis2]
*/
char *ak_photometric_parallax_loaddiagram(char *bindiag,ak_phot_par_diag *diags)
{
   static char stringresult[1024];
   char line[1024];
   char filename[1024];
   int n,nn;
   double naxis1d,naxis2d;
   FILE *f;
   strcpy(stringresult,"");
   /* init */
   diags->crpix1=0;
   diags->crpix2=0;
   diags->crval1=0;
   diags->crval2=0;
   diags->naxis1=0;
   diags->naxis2=0;
   diags->cdelt1=0;
   diags->cdelt2=0;
   /* --- read the WCS ascii file ---*/
   sprintf(filename,"%s.wcs",bindiag);
   f=fopen(filename,"rt");
   if (f==NULL) {
      sprintf(stringresult,"diagram file %s not found",filename);
      return stringresult;
   }
   while (feof(f)==0) {
      if (fgets(line,1024,f)==NULL) {
         continue;
      }
      if (strlen(line)>2) {
         sscanf(line,"%lf %lf %lf %lf %lf %lf %lf %lf"
            ,&naxis1d,&diags->crpix1,&diags->crval1,&diags->cdelt1
            ,&naxis2d,&diags->crpix2,&diags->crval2,&diags->cdelt2
            );
         diags->naxis1=(int)naxis1d;
         diags->naxis2=(int)naxis2d;
         break;
      }
   }
   fclose(f);
   if (diags==NULL) {
      return stringresult;
   }
   /* --- memory allocation ---*/
   n=diags->naxis1*diags->naxis2;
   diags->mat=(float*)calloc(n,sizeof(float));
   if (diags->mat==NULL) {
      sprintf(stringresult,"error : mat pointer out of memory (%d elements)",n);
      return stringresult;
   }
   diags->matconv=(float*)calloc(n,sizeof(float));
   if (diags->mat==NULL) {
      sprintf(stringresult,"error : matconv pointer out of memory (%d elements)",n);
      return stringresult;
   }
   /* --- read the data binary file ---*/
   sprintf(filename,"%s.bin",bindiag);
   f=fopen(filename,"rb");
   if (f==NULL) {
      sprintf(stringresult,"diagram file %s not found",filename);
      return stringresult;
   }
   nn=fread(diags->mat,sizeof(float),n,f);
   fclose(f);
   /* --- save a fits file ---*/
   sprintf(line,"%s.fit",bindiag);
   ak_photometric_parallax_savefits(diags->mat,diags->naxis1,diags->naxis2,line,NULL);
   return stringresult;
}

/***************************************************************************/
/* Make an image of a diagram from an ascii file */
/***************************************************************************/
char *ak_photometric_parallax_diagram(char *ascii_diagram,char *tmpfile,double sigmagy, ak_phot_par_diag *diags)
{
   static char stringresult[1024];
   char line[1024],car;
   int n,n_star;
   FILE *f;
   double *x,*y;
   float *mat;
   double x1,y1,x2,y2;
   double xp,yp,dx,dy,dxa,dya;
   int k;
   int xi,yi,yi0,yimin,yimax;
   int naxis1;
   double crpix1,crval1,cdelt1;
   int naxis2;
   double crpix2,crval2,cdelt2;
   double maxx,minx,maxy,miny;

   strcpy(stringresult,"");
   /* --- count the number of points in the file ---*/
   f=fopen(ascii_diagram,"rt");
   if (f==NULL) {
      sprintf(stringresult,"ascii_star %s not found",ascii_diagram);
      return stringresult;
   }
   n=0;
   while (feof(f)==0) {
      if (fgets(line,1024,f)==NULL) {
         continue;
      }
      car=line[0];
      if ((strlen(line)>2)&&(car>=43)&&(car<57)&&(car!=44)&&(car!=47)) {
         n++;
      }
   }
   fclose(f);
   n_star=n;
   /* --- allocate memory to load points values ---*/
   x=(double*)calloc(n,sizeof(double));
   if (x==NULL) {
      sprintf(stringresult,"error : x pointer out of memory (%d elements)",n);
      return stringresult;
   }
   y=(double*)calloc(n,sizeof(double));
   if (y==NULL) {
      free(x);
      sprintf(stringresult,"error : y pointer out of memory (%d elements)",n);
      return stringresult;
   }
   /* --- load the point values from the file ---*/
   maxx=maxy=-2e30;
   minx=miny=-maxx;
   f=fopen(ascii_diagram,"rt");
   n=0;
   while (feof(f)==0) {
      if (fgets(line,1024,f)==NULL) {
         continue;
      }
      car=line[0];
      if ((strlen(line)>2)&&(car>=43)&&(car<57)&&(car!=44)&&(car!=47)) {
         sscanf(line,"%lf %lf",&x[n],&y[n]);
         if (x[n]<minx) minx=x[n];
         if (y[n]<miny) miny=y[n];
         if (x[n]>maxx) maxx=x[n];
         if (y[n]>maxy) maxy=y[n];
         n++;
      }
   }
   fclose(f);
   /* --- automatic scales ---*/
   minx=minx-5.*diags->sigma1;
   maxx=maxx+5.*diags->sigma1;
   miny=miny-5.*diags->sigma2;
   maxy=maxy+5.*diags->sigma2;
   crpix1=0.;
   crpix2=0.;
   cdelt1=diags->cdelt1;
   cdelt2=diags->cdelt2;
   if (cdelt1>0) {
      crval1=minx;
   } else {
      crval1=maxx;
   }
   if (cdelt2>0) {
      crval2=miny;
   } else {
      crval2=maxy;
   }
   naxis1=(int)fabs(ceil((maxx-minx)/cdelt1));
   naxis2=(int)fabs(ceil((maxy-miny)/cdelt2));
   diags->crpix1=crpix1;
   diags->crpix2=crpix2;
   diags->crval1=crval1;
   diags->crval2=crval2;
   diags->naxis1=naxis1;
   diags->naxis2=naxis2;
   /* --- allocate memory for the diagram image ---*/
   n=naxis1*naxis2;
   diags->mat=(float*)calloc(n,sizeof(float));
   if (diags->mat==NULL) {
      free(x);free(y);
      sprintf(stringresult,"error : mat pointer out of memory (%d elements)",n);
      return stringresult;
   }
   mat=diags->mat;
   diags->matconv=(float*)calloc(n,sizeof(float));
   if (diags->matconv==NULL) {
      free(x);free(y);free(mat);
      sprintf(stringresult,"error : matconv pointer out of memory (%d elements)",n);
      return stringresult;
   }
   /* --- trace line segments between adjascent points ---*/
   n=n_star;
   for (k=0;k<n-1;k++) {
      x1=x[k];
      y1=y[k];
      x2=x[k+1];
      y2=y[k+1];
      dx=(x2-x1)*cdelt1/1.5;
      dy=(y2-y1)*cdelt2/1.5;
      if ((dx==0)&&(dy==0)) {
         dx=1.;
      }
      dxa=fabs(dx);
      dya=fabs(dy);
      if (dxa>dya) {
         if (x2<x1) {
            xp=x1;x1=x2;x2=xp;
         }
         for (xp=x1;xp<=x2;xp+=dxa) {
            yp=y1+(xp-x1)/(x2-x1)*(y2-y1);
            xi=(int)(crpix1+(xp-crval1)/cdelt1);
            if (xi<0) break;
            if (xi>naxis1) break;
            yi=(int)(crpix2+(yp-crval2)/cdelt2);
            if (yi<0) break;
            if (yi>naxis2) break;
            mat[yi*naxis1+xi]=(float)1.;
            yi0=yi;
            yimin=(int)(crpix2+(yp+sigmagy-crval2)/cdelt2);
            yimax=(int)(crpix2+(yp-sigmagy-crval2)/cdelt2);
            if (yimax<yimin) {
               yi=yimin; yimin=yimax; yimax=yi;
            }
            if (yimin>=naxis2) yimin=naxis2-1;
            if (yimin<0) yimin=0;
            for (yi=yi0;yi<yimax;yi++) {
               mat[yi*naxis1+xi]=(float)1.;
            }
            if (yimax>=naxis2) yimax=naxis2-1;
            if (yimax<0) yimax=0;
            for (yi=yi0;yi>yimin;yi--) {
               mat[yi*naxis1+xi]=(float)1.;
            }
         }
      } else {
         if (y2<y1) {
            yp=y1;y1=y2;y2=yp;
         }
         for (yp=y1;yp<=y2;yp+=dya) {
            xp=x1+(yp-y1)/(y2-y1)*(x2-x1);
            xi=(int)(crpix1+(xp-crval1)/cdelt1);
            if (xi<0) break;
            if (xi>naxis1) break;
            yi=(int)(crpix2+(yp-crval2)/cdelt2);
            if (yi<0) break;
            if (yi>naxis2) break;
            mat[yi*naxis1+xi]=(float)1.;
            yi0=yi;
            yimin=(int)(crpix2+(yp+sigmagy-crval2)/cdelt2);
            yimax=(int)(crpix2+(yp-sigmagy-crval2)/cdelt2);
            if (yimax<yimin) {
               yi=yimin; yimin=yimax; yimax=yi;
            }
            if (yimin>=naxis2) yimin=naxis2-1;
            if (yimin<0) yimin=0;
            for (yi=yi0;yi<yimax;yi++) {
               mat[yi*naxis1+xi]=(float)1.;
            }
            if (yimax>=naxis2) yimax=naxis2-1;
            if (yimax<0) yimax=0;
            for (yi=yi0;yi>yimin;yi--) {
               mat[yi*naxis1+xi]=(float)1.;
            }
         }
      }
   }
   /* --- save a binary file ---*/
   sprintf(line,"%s.bin",tmpfile);
   f=fopen(line,"wb");
   fwrite(mat,naxis1*naxis2,sizeof(float),f);
   fclose(f);
   /* --- save a fits file ---*/
   sprintf(line,"%s.fit",tmpfile);
   ak_photometric_parallax_savefits(mat,naxis1,naxis2,line,NULL);
   free(x);free(y);
   return stringresult;
}

/***************************************************************************/
/* Read the mags structure data from an ASCII file */
/* filetype=1 : custom ASCII format : ra dec J dJ H dH K dK */
/* filetype=2 : 2MASS  ASCII format : ra dec - - - - J dJ - - H dH - - K dK - - ... */
/* filetype=3 : GCS    ASCII format : ra dec z Y J H K dz dY dJ dH dK...   */
/* filetype=4 : GPS    ASCII format : ra dec J H K dJ dH dK...             */
/***************************************************************************/
char *ak_photometric_parallax_inputs(char *inputfile,int filetype, ak_phot_par_mag **mags,int *n_stars)
{
   static char stringresult[1024];
   char ligne[2000],texte[2000];
   FILE *f_in;
   int n;
   /*int nmax=1000; for tests only*/
   int nmax=2147483647;
//   int nmax=1;
   int riend;
   double rienf;
   char riens[255];
   ak_phot_par_mag *mag0s;
   strcpy(stringresult,"");
   if (*n_stars>0) {
      *mags=(ak_phot_par_mag*)calloc(*n_stars,sizeof(ak_phot_par_mag));
      return stringresult;
   }
   f_in=fopen(inputfile,"rt");
   if (f_in==NULL) {
      sprintf(stringresult,"File %s not found",inputfile);
      return stringresult;
   }
   n=0;
   do {
      if (fgets(ligne,255,f_in)!=NULL) {
	      strcpy(texte,"");
   	   sscanf(ligne,"%s",texte);
	      if ( (strcmp(texte,"")!=0) ) {
            n++;
         }
      }
      if (n>=nmax) break;
   } while (feof(f_in)==0) ;
   fclose(f_in);
   *n_stars=n;
   if (n<1) {
      return stringresult;
   }
   *mags=(ak_phot_par_mag*)calloc(n,sizeof(ak_phot_par_mag));
   mag0s=*mags;
   f_in=fopen(inputfile,"rt");
   n=0;
   do {
      if (fgets(ligne,255,f_in)!=NULL) {
	      strcpy(texte,"");
   	   sscanf(ligne,"%s",texte);
	      if ( (strcmp(texte,"")!=0) ) {
            if (filetype==1) {
   	         sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %lf",
                  &mag0s[n].ra,&mag0s[n].dec,
                  &mag0s[n].magj,&mag0s[n].sigmagj,
                  &mag0s[n].magh,&mag0s[n].sigmagh,
                  &mag0s[n].magk,&mag0s[n].sigmagk);
            }
            else if (filetype==2) {
   	         sscanf(ligne," %lf %lf %lf %lf %d %s %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %s %d %d %s %d %lf %d",
                  &mag0s[n].ra,&mag0s[n].dec,
                  &rienf,&rienf,&riend,&riens,
                  &mag0s[n].magj,&mag0s[n].sigmagj,
                  &rienf,&rienf,
                  &mag0s[n].magh,&mag0s[n].sigmagh,
                  &rienf,&rienf,
                  &mag0s[n].magk,&mag0s[n].sigmagk,
                  &rienf,&rienf,
                  &riens,&riend,&riend,&riens,&riend,&rienf,&riend);
            }
            else if (filetype==3) {
               if (ligne[0]=='#') {
                  continue;
               }
   	         sscanf(ligne," %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf",
                  &mag0s[n].ra,&mag0s[n].dec,
                  &rienf,
                  &rienf,
                  &mag0s[n].magj,
                  &mag0s[n].magh,                  
                  &mag0s[n].magk,
                  &rienf,
                  &rienf,
                  &mag0s[n].sigmagj,
                  &mag0s[n].sigmagh,                  
                  &mag0s[n].sigmagk);
            }
            else if (filetype==4) {
               if (ligne[0]=='#') {
                  continue;
               }
   	         sscanf(ligne," %lf %lf %lf %lf %lf %lf %lf %lf",
                  &mag0s[n].ra,&mag0s[n].dec,
                  &mag0s[n].magj,
                  &mag0s[n].magh,                  
                  &mag0s[n].magk,
                  &mag0s[n].sigmagj,
                  &mag0s[n].sigmagh,                  
                  &mag0s[n].sigmagk);
            }
            mag0s[n].flag_valid=1;
            n++;
         }
      }
      if (n>=nmax) break;
   } while (feof(f_in)==0) ;
   fclose(f_in);
   /* for tests only
   mag0s[0].magj=14.85;
   mag0s[0].magh=14.315;
   mag0s[0].magk=14.0;
   mag0s[0].sigmagj=0.05;
   mag0s[0].sigmagh=0.05;
   mag0s[0].sigmagk=0.05;
   */
   return stringresult;
}

/***************************************************************************/
/* Read the htm-av structure data from an ASCII file */
/***************************************************************************/
char *ak_photometric_parallax_read_htmav(char *inputfile,ak_phot_par_htmav **htmavs,int *n_htms)
{
   static char stringresult[1024];
   char ligne[2000],texte[2000];
   FILE *f_in;
   int n;
   int riend;
   ak_phot_par_htmav *htmav0s;
   strcpy(stringresult,"");
   if (*n_htms>0) {
      *htmavs=(ak_phot_par_htmav*)calloc(*n_htms,sizeof(ak_phot_par_htmav));
      return stringresult;
   }
   f_in=fopen(inputfile,"rt");
   if (f_in==NULL) {
      sprintf(stringresult,"File %s not found",inputfile);
      return stringresult;
   }
   n=0;
   do {
      if (fgets(ligne,255,f_in)!=NULL) {
	      strcpy(texte,"");
   	   sscanf(ligne,"%s",texte);
	      if ( (strcmp(texte,"")!=0) ) {
            n++;
         }
      }
   } while (feof(f_in)==0) ;
   fclose(f_in);
   *n_htms=n;
   if (n<1) {
      return stringresult;
   }
   *htmavs=(ak_phot_par_htmav*)calloc(n,sizeof(ak_phot_par_htmav));
   htmav0s=*htmavs;
   f_in=fopen(inputfile,"rt");
   n=0;
   do {
      if (fgets(ligne,255,f_in)!=NULL) {
	      strcpy(texte,"");
   	   sscanf(ligne,"%s",texte);
	      if ( (strcmp(texte,"")!=0) ) {
   	      sscanf(ligne,"%s %lf %lf %lf %lf %lf %lf %d",
               &htmav0s[n].htm,&htmav0s[n].av1,&htmav0s[n].av,&htmav0s[n].av2,&htmav0s[n].md1,&htmav0s[n].md,&htmav0s[n].md2,&riend);
            n++;
         }
      }
   } while (feof(f_in)==0) ;
   fclose(f_in);
   return stringresult;
}

/****************************************************************************/
/* HTM Tool.                                                                */
/****************************************************************************/
/* Returns 1 if v is inside the triangle v0,v1,v2.                          */
/****************************************************************************/
int ak_photometric_parallax_htm_testin(double *v0, double *v1, double *v2, double *v)
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

/****************************************************************************/
/* HTM Tool.                                                                */
/****************************************************************************/
/* Returns the Hierarchical Triangle Mesh code from (ra,dec).               */
/****************************************************************************/
int ak_photometric_parallax_radec2htm(double ra,double dec,int niter,char *htm)
{
   int k,res,iter;
   double v[4],vv0[4],vv1[4],vv2[4],vv3[4],vv4[4],vv5[4];
   double vx0[4],vx1[4],vx2[4];
   double *v0,*v1,*v2;
   double w0[4],w1[4],w2[4];
   double w;
   char north='0'; /* N */
   char south='1'; /* S */
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
   /* === identification of the first node */
   v0=vv1;
   v1=vv5;
   v2=vv2;
   for (k=1;k<=8;k++) {
      if (k==1) {
         htm[0]=south;htm[1]='0';
         v0=vv1;
         v1=vv5;
         v2=vv2;
      }
      if (k==2) {
         htm[0]=south;htm[1]='1';
         v0=vv2;
         v1=vv5;
         v2=vv3;
      }
      if (k==3) {
         htm[0]=south;htm[1]='2';
         v0=vv3;
         v1=vv5;
         v2=vv4;
      }
      if (k==4) {
         htm[0]=south;htm[1]='3';
         v0=vv4;
         v1=vv5;
         v2=vv1;
      }
      if (k==5) {
         htm[0]=north;htm[1]='0';
         v0=vv1;
         v1=vv0;
         v2=vv4;
      }
      if (k==6) {
         htm[0]=north;htm[1]='1';
         v0=vv4;
         v1=vv0;
         v2=vv3;
      }
      if (k==7) {
         htm[0]=north;htm[1]='2';
         v0=vv3;
         v1=vv0;
         v2=vv2;
      }
      if (k==8) {
         htm[0]=north;htm[1]='3';
         v0=vv2;
         v1=vv0;
         v2=vv1;
      }
      res=ak_photometric_parallax_htm_testin(v0,v1,v2,v);
      if (res==1) {
         break;
      }
   }
   /* === identification of next nodes */
   for (iter=1;iter<=niter;iter++) {
      for (k=0;k<3;k++) { vx0[k]=v0[k]; }
      for (k=0;k<3;k++) { vx1[k]=v1[k]; }
      for (k=0;k<3;k++) { vx2[k]=v2[k]; }
      /* --- vectors w0,w1,w2 */
      for (w=0.,k=0;k<3;k++) { w0[k]=vx1[k]+vx2[k]; w+=(w0[k]*w0[k]); }
      for (k=0;k<3;k++) { w0[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w1[k]=vx0[k]+vx2[k]; w+=(w1[k]*w1[k]); }
      for (k=0;k<3;k++) { w1[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w2[k]=vx0[k]+vx1[k]; w+=(w2[k]*w2[k]); }
      for (k=0;k<3;k++) { w2[k]/=sqrt(w); }
      /* --- lopp over the 4 triangles */
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
         res=ak_photometric_parallax_htm_testin(v0,v1,v2,v);
         if (res==1) {
            break;
         }
      }
   }
   htm[1+iter]='\0';
   return 0;
}

/****************************************************************************/
/* HTM Tool.                                                                */
/****************************************************************************/
/* Returns (ra,dec) from the Hierarchical Triangle Mesh code.               */
/****************************************************************************/
int ak_photometric_parallax_htm2radec(char *htm,double *ra,double *dec,int *niter,double *ra0,double *dec0,double *ra1,double *dec1,double *ra2,double *dec2)
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
   /* === identification of the first node */
   v0=vv1;
   v1=vv5;
   v2=vv2;
      if (((htm[0]=='S')||(htm[0]=='1'))&&(htm[1]=='0')) {
         v0=vv1;
         v1=vv5;
         v2=vv2;
      }
      if (((htm[0]=='S')||(htm[0]=='1'))&&(htm[1]=='1')) {
         v0=vv2;
         v1=vv5;
         v2=vv3;
      }
      if (((htm[0]=='S')||(htm[0]=='1'))&&(htm[1]=='2')) {
         v0=vv3;
         v1=vv5;
         v2=vv4;
      }
      if (((htm[0]=='S')||(htm[0]=='1'))&&(htm[1]=='3')) {
         v0=vv4;
         v1=vv5;
         v2=vv1;
      }
      if (((htm[0]=='N')||(htm[0]=='0'))&&(htm[1]=='0')) {
         v0=vv1;
         v1=vv0;
         v2=vv4;
      }
      if (((htm[0]=='N')||(htm[0]=='0'))&&(htm[1]=='1')) {
         v0=vv4;
         v1=vv0;
         v2=vv3;
      }
      if (((htm[0]=='N')||(htm[0]=='0'))&&(htm[1]=='2')) {
         v0=vv3;
         v1=vv0;
         v2=vv2;
      }
      if (((htm[0]=='N')||(htm[0]=='0'))&&(htm[1]=='3')) {
         v0=vv2;
         v1=vv0;
         v2=vv1;
      }
   /* === identification of the next nodes */
   *niter=n-2;
   for (iter=1;iter<=*niter;iter++) {
      for (k=0;k<3;k++) { vx0[k]=v0[k]; }
      for (k=0;k<3;k++) { vx1[k]=v1[k]; }
      for (k=0;k<3;k++) { vx2[k]=v2[k]; }
      /* --- vectors w0,w1,w2 */
      for (w=0.,k=0;k<3;k++) { w0[k]=vx1[k]+vx2[k]; w+=(w0[k]*w0[k]); }
      for (k=0;k<3;k++) { w0[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w1[k]=vx0[k]+vx2[k]; w+=(w1[k]*w1[k]); }
      for (k=0;k<3;k++) { w1[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w2[k]=vx0[k]+vx1[k]; w+=(w2[k]*w2[k]); }
      for (k=0;k<3;k++) { w2[k]/=sqrt(w); }
      /* --- loop over the 4 triangles */
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

/****************************************************************************/
/* Sort Tool.                                                               */
/****************************************************************************/
/**	Tools to sort an array of (ak_phot_par_htmsort)
 * @param htmsort contains the array of (ak_phot_par_htmsort) to sort.
 * @param low is the first index of the array.
 * @param high is the last index of the array.
*/
/****************************************************************************/
void ak_photometric_parallax_quicksort_htmsort(ak_phot_par_htmsort *htmsort, int low, int high) {
   ak_phot_par_htmsort y; // =0
   int i,j;
   ak_phot_par_htmsort z;
   i=low;
   j=high;
   /* compare value */
   z = htmsort[(low + high) / 2];
   /* partition */
   do {
      /* find member above ... */
      while(strcmp(htmsort[i].htm,z.htm) < 0) i++;
      /* find element below ... */
      while(strcmp(htmsort[j].htm,z.htm) > 0) j--;
      if(i <= j) {
         /* swap two elements */
         y = htmsort[i];
         htmsort[i] = htmsort[j];
         htmsort[j] = y;
         i++;
         j--;
      }
   } while(i <= j);
   /* recurse */
   if(low < j) {
      ak_photometric_parallax_quicksort_htmsort(htmsort, low, j);
   }
   if(i < high) {
      ak_photometric_parallax_quicksort_htmsort(htmsort, i, high);
   }
}

/****************************************************************************/
/* Sort Tool.                                                               */
/****************************************************************************/
/**	Tools to sort an array of (double)
 * @param htmsort contains the array of (double) to sort.
 * @param low is the first index of the array.
 * @param high is the last index of the array.
*/
/****************************************************************************/
void ak_photometric_parallax_quicksort_double(double *arr, int low, int high) {
   double y;
   int i,j;
   double z;
   y=0.;
   i=low;
   j=high;
   /* compare value */
   z = arr[(low + high) / 2];
   /* partition */
   do {
      /* find member above ... */
      while(arr[i] < z) i++;
      /* find element below ... */
      while(arr[j] > z) j--;
      if(i <= j) {
         /* swap two elements */
         y = arr[i];
         arr[i] = arr[j];
         arr[j] = y;
         i++;
         j--;
      }
   } while(i <= j);
   /* recurse */
   if(low < j) {
      ak_photometric_parallax_quicksort_double(arr, low, j);
   }
   if(i < high) {
      ak_photometric_parallax_quicksort_double(arr, i, high);
   }
}

/***************************************************************************/
/* WCS Tool                                                                */
/***************************************************************************/
/* x,y -> ra,dec                                                           */
/* ra,dec expressed in radians.                                            */
/***************************************************************************/
char *ak_photometric_parallax_xy2radec(ak_phot_par_wcs wcs, double x,double y,double *ra,double *dec)
{
   static char stringresult[1024];
   double delta,gamma;
   double dra,ddec;
   /* --- x,y -> ra,dec ---*/
   x+=0.5;
   y+=0.5;
   dra=wcs.cd11*(x-wcs.crpix1)+wcs.cd12*(y-wcs.crpix2);
   ddec=wcs.cd21*(x-wcs.crpix1)+wcs.cd22*(y-wcs.crpix2);
   delta=cos(wcs.crval2)-ddec*sin(wcs.crval2);
   gamma=sqrt(dra*dra+delta*delta);
   *ra=wcs.crval1+atan(dra/delta);
   if (*ra<0) {*ra+=(2*AK_PI);}
   if (*ra>(2*AK_PI)) {*ra-=(2*AK_PI);}
   *dec=atan((sin(wcs.crval2)+ddec*cos(wcs.crval2))/gamma);
   return stringresult;
}

/***************************************************************************/
/* WCS Tool                                                                */
/***************************************************************************/
/* ra,dec -> x,y                                                           */
/* ra,dec expressed in radians.                                            */
/***************************************************************************/
char *ak_photometric_parallax_radec2xy(ak_phot_par_wcs wcs, double ra,double dec,double *x,double *y)
{
   static char stringresult[1024];
   double sindec,cosdec,sindec0,cosdec0,cosrara0,sinrara0;
   double h,det;
   double dra,ddec;
   /* --- ra,dec -> x,y ---*/
   sindec=sin(dec);
   cosdec=cos(dec);
   sindec0=sin(wcs.crval2);
   cosdec0=cos(wcs.crval2);
   cosrara0=cos(ra-wcs.crval1);
   sinrara0=sin(ra-wcs.crval1);
   h=sindec*sindec0+cosdec*cosdec0*cosrara0;
   dra=cosdec*sinrara0/h;
   ddec=(sindec*cosdec0-cosdec*sindec0*cosrara0)/h;
   det=wcs.cd22*wcs.cd11-wcs.cd12*wcs.cd21;
   if (det==0) {*x=*y=0.;} else {
      *x=wcs.crpix1 - (wcs.cd12*ddec-wcs.cd22*dra) / det -0.5;
      *y=wcs.crpix2 + (wcs.cd11*ddec-wcs.cd21*dra) / det -0.5;
   }
   return stringresult;
}
