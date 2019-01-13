/* tt_user3.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Delphine VALLOT <delphine.vallot@free.fr>
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

/***** prototypes des fonctions internes du user3 ***********/
int tt_ima_series_rot(TT_IMA_SERIES *pseries);
int tt_ima_series_binx(TT_IMA_SERIES *pseries);
int tt_ima_series_biny(TT_IMA_SERIES *pseries);
int tt_ima_series_profile(TT_IMA_SERIES *pseries);
int tt_ima_series_matrix(TT_IMA_SERIES *pseries);
int tt_ima_series_window(TT_IMA_SERIES *pseries);
int tt_ima_series_log(TT_IMA_SERIES *pseries);
int tt_ima_series_medianx(TT_IMA_SERIES *pseries);
int tt_ima_series_mediany(TT_IMA_SERIES *pseries);
int tt_ima_series_rec2pol(TT_IMA_SERIES *pseries);
int tt_ima_series_pol2rec(TT_IMA_SERIES *pseries);
/* pour l'interpolation */
double interpol (TT_IMA_SERIES *pseries,double old_x,double old_y,int method);


int tt_user3_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"ROT")==0) { pseries->numfct=TT_IMASERIES_USER3_ROT; }
   else if (strcmp(keys10,"BINX")==0) { pseries->numfct=TT_IMASERIES_USER3_BINX; }
   else if (strcmp(keys10,"BINY")==0) { pseries->numfct=TT_IMASERIES_USER3_BINY; }
   else if (strcmp(keys10,"PROFILE")==0) { pseries->numfct=TT_IMASERIES_USER3_PROFILE; }
   else if (strcmp(keys10,"MATRIX")==0) { pseries->numfct=TT_IMASERIES_USER3_MATRIX; }
   else if (strcmp(keys10,"WINDOW")==0) { pseries->numfct=TT_IMASERIES_USER3_WINDOW; }
   else if (strcmp(keys10,"LOG")==0) { pseries->numfct=TT_IMASERIES_USER3_LOG; }
   else if (strcmp(keys10,"MEDIANX")==0) { pseries->numfct=TT_IMASERIES_USER3_MEDIANX; }
   else if (strcmp(keys10,"MEDIANY")==0) { pseries->numfct=TT_IMASERIES_USER3_MEDIANY; }
   else if (strcmp(keys10,"REC2POL")==0) { pseries->numfct=TT_IMASERIES_USER3_REC2POL; }
   else if (strcmp(keys10,"POL2REC")==0) { pseries->numfct=TT_IMASERIES_USER3_POL2REC; }
   return(OK_DLL);
}

int tt_user3_ima_series_builder2(TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   options->user3.x0=0.;
   options->user3.y0=0.;
   options->user3.angle=0.;
   options->user3.x1=1;
   options->user3.x2=1;
   options->user3.width=20;
   options->user3.y1=1;
   options->user3.y2=1;
   options->user3.height=20;
   options->user3.offset=0;
   /*options->user3.direction = (char*)calloc(2,1);*/
   strcpy(options->user3.direction,"x");
   /*options->user3.filename = (char*)calloc(11,1);*/
   strcpy(options->user3.filename,"profil.dat");
   /*options->user3.filematrix = (char*)calloc(11,1);*/
   strcpy(options->user3.filematrix,"matrix.dat");
   options->user3.offsetlog=0.;
   options->user3.coeff=32768. / log10(32768.);
   options->user3.scale_theta=1.;
   options->user3.scale_rho=1.;
   return(OK_DLL);
}

int tt_user3_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"X0")==0) {
      options->user3.x0=(double)(atof(argu));
   } else if (strcmp(mot,"Y0")==0) {
      options->user3.y0=(double)(atof(argu));
   } else if (strcmp(mot,"ANGLE")==0) {
      options->user3.angle=(double)(atof(argu))*TT_PI/180.;
   } else if (strcmp(mot,"X1")==0) {
      options->user3.x1=(int)(atof(argu));
   } else if (strcmp(mot,"X2")==0) {
      options->user3.x2=(int)(atof(argu));
   } else if (strcmp(mot,"WIDTH")==0) {
      options->user3.width=(int)(atof(argu));
   } else if (strcmp(mot,"Y1")==0) {
      options->user3.y1=(int)(atof(argu));
   } else if (strcmp(mot,"Y2")==0) {
      options->user3.y2=(int)(atof(argu));
   } else if (strcmp(mot,"HEIGHT")==0) {
      options->user3.height=(int)(atof(argu));
   } else if (strcmp(mot,"OFFSET")==0) {
      options->user3.offset=(int)(atof(argu));
   } else if (strcmp(mot,"DIRECTION")==0) {
      /*
      free(options->user3.direction);
      options->user3.direction=(char*)malloc(strlen(argu)+1);
      */
      strcpy(options->user3.direction,argu);
   } else if (strcmp(mot,"FILENAME")==0) {
      /*
      free(options->user3.filename);
      options->user3.filename = (char*)malloc(strlen(argu)+1);
      */
      strcpy(options->user3.filename,argu);
   } else if (strcmp(mot,"FILEMATRIX")==0) {
      /*
      free(options->user3.filematrix);
      options->user3.filematrix = (char*)malloc(strlen(argu)+1);
      */
      strcpy(options->user3.filematrix,argu);
   } else if (strcmp(mot,"OFFSETLOG")==0) {
      options->user3.offsetlog=(double)(atof(argu));
   } else if (strcmp(mot,"COEFF")==0) {
      options->user3.coeff=(double)(atof(argu));
   } else if (strcmp(mot,"SCALE_THETA")==0) {
      options->user3.scale_theta=(double)(atof(argu));
   } else if (strcmp(mot,"SCALE_RHO")==0) {
      options->user3.scale_rho=(double)(atof(argu));
   }
   return(OK_DLL);
}

int tt_user3_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pseries->numfct==TT_IMASERIES_USER3_ROT) {
      *msg=tt_ima_series_rot(pseries);
      *fct_found=TT_YES;
   }
   else if  (pseries->numfct==TT_IMASERIES_USER3_BINX) {
      *msg=tt_ima_series_binx(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_BINY) {
      *msg=tt_ima_series_biny(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_PROFILE) {
      *msg=tt_ima_series_profile(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_MATRIX) {
      *msg=tt_ima_series_matrix(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_WINDOW) {
      *msg=tt_ima_series_window(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_LOG) {
      *msg=tt_ima_series_log(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_MEDIANX) {
      *msg=tt_ima_series_medianx(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_MEDIANY) {
      *msg=tt_ima_series_mediany(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_REC2POL) {
      *msg=tt_ima_series_rec2pol(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER3_POL2REC) {
      *msg=tt_ima_series_pol2rec(pseries);
      *fct_found=TT_YES;
   }
   return(OK_DLL);
}

/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user3 pour IMA/STACK                   */
/**************************************************************************/
/**************************************************************************/

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user3_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   return(OK_DLL);
}

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user3_ima_stack_builder2(TT_IMA_STACK *pstack)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   return(OK_DLL);
}

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user3_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   return(OK_DLL);
}

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user3_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   return(OK_DLL);
}

/**************************************************************************/
/* Fonction Interpol                                                      */
/* arguments possibles : image,old_x,old_y,method,nullpixel               */
/**************************************************************************/
double interpol (TT_IMA_SERIES *pseries,double old_x,double old_y,int method)
{
   TT_IMA *p_in;
   int x1,y1,x2,y2;
   double value=0.;                    /* value of the pixel */
   double pix1, pix2, pix3, pix4;   /* pixels for the interpolation */
   double alpha, beta;              /* coeffs for the interpolation */
   double nullpixel;
   int w,h;

   p_in=pseries->p_in;
   w=p_in->naxis1;
   h=p_in->naxis2;
   nullpixel=pseries->nullpix_value;

    if (method == 1)
    {
    	if ((old_x >= 0) && (old_x < w-1) && (old_y >= 0) && (old_y < h-1))
    	{
            x1 = (int)old_x;
            x2 = x1 + 1;
            y1 = (int)old_y;
            y2 = y1 + 1;
            alpha = old_x - x1;
            beta = old_y - y1;
            // Valeurs des 4 pixels d'interpolation
            pix1 = p_in->p[x1+y1*w];
            pix2 = p_in->p[x2+y1*w];
            pix3 = p_in->p[x1+y2*w];
            pix4 = p_in->p[x2+y2*w];
            // Calcul de l'interpolation
            value = (1-alpha)*(1-beta)*pix1 +
                    alpha*(1-beta)*pix2 +
                    (1-alpha)*beta*pix3 +
                    alpha*beta*pix4;
      }
      else  value = nullpixel;
    } /* end of if_statement */
    return value;
}


/**************************************************************************/
/* Fonction Rotation                                                      */
/* arguments possibles : x0,y,angle,nullpixel                             */
/**************************************************************************/
int tt_ima_series_rot(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   double x0, y0, theta;
   int w, h;
   int x, y;

   double cos_theta,sin_theta;      /* cos theta,sin theta */
   double old_x,old_y;              /* old point */
   double value;                    /* value of the pixel */
   double a[6];

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;

   x0=pseries->user3.x0;
   y0=pseries->user3.y0;
   theta=pseries->user3.angle;
   w=p_in->naxis1;
   h=p_in->naxis2;

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   /* --- calcul de l'image retournee --- */
   cos_theta = cos(theta);
   sin_theta = sin(theta);

   for(x = 0;x < w;x++)
   {
      for(y = 0;y < h;y++)
      {
         old_x = cos_theta * (x - x0) + sin_theta * (y - y0) + x0;
         old_y = - sin_theta * (x - x0) + cos_theta * (y - y0) + y0;
         value = interpol(pseries,old_x,old_y,1);
         p_out->p[x+y*w]=(TT_PTYPE)(value);
      } /* end of y-loop */
   } /* end of x_loop */

   /* --- calcule les nouveaux parametres de projection ---*/
   a[0]=cos_theta;
   a[1]=sin_theta;
   a[2]=-cos_theta*x0-sin_theta*y0+x0;
   a[3]=-sin_theta;
   a[4]=cos_theta;
   a[5]=sin_theta*x0-cos_theta*y0+y0;
   tt_util_update_wcs(p_in,p_out,a,2,NULL);

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction BinX                                                          */
/* arguments possibles : x1,x2,width                                      */
/**************************************************************************/
int tt_ima_series_binx(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int width;
   int x1,x2;
   int x,y;              /* loop variable */
   double value;          /* temporary variable */
   int temp;             /* temporary variable */

   char message[TT_MAXLIGNE];

   /* --- initialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;

   w=p_in->naxis1;
   h=p_in->naxis2;
   width=pseries->user3.width;
   x1=pseries->user3.x1-1;
   x2=pseries->user3.x2-1;

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,width,p_in->naxis2);


   /* verification des donnees */
   if (width < 0)
   {
         sprintf(message,"width must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if ((x1 < 0) || (x2 < 0) || (x1 > w-1) || (x2 > w-1))
   {
         sprintf(message,"x1 and x2 must be contained between 1 and %d",w);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(x1 > x2)
   {
       temp = x2;
       x2 = x1;
       x1 = temp;
   } /* end of if-statement */

   /* bining */
   for(y = 0; y < h;y++)
   {
       value = 0.;
       for(x=x1;x<=x2;x++)
       {
          value += p_in->p[x+y*w];
       } /* end of x-loop */
       for(x=0;x<width;x++)
       {
          p_out->p[x+y*width]=(TT_PTYPE)(value);
       } /* end of x-loop */
   } /* end of y-loop */

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction BinY                                                          */
/* arguments possibles : y1,y2,height                                     */
/**************************************************************************/
int tt_ima_series_biny(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int height;
   int y1,y2;
   int x,y;              /* loop variable */
   double value;          /* temporary variable */
   int temp;             /* temporary variable */

   char message[TT_MAXLIGNE];


   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;


   w=p_in->naxis1;
   h=p_in->naxis2;
   height=pseries->user3.height;
   y1=pseries->user3.y1-1;
   y2=pseries->user3.y2-1;

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,height);


   /* verification des donnees */
   if (height < 0)
   {
         sprintf(message,"height must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);

   } /* end of if-statement */
   if ((y1 < 0) || (y2 < 0) || (y1 > h-1) || (y2 > h-1))
   {
         sprintf(message,"y1 and y2 must be contained between 1 and %d",h);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   } /* end of if-statement */


   /* bining */
   for(x = 0; x < w;x++)
   {
       value = 0.;
       for(y=y1;y<=y2;y++)
       {
          value += p_in->p[x+y*w];
       } /* end of y-loop */
       for(y=0;y<height;y++)
       {
          p_out->p[x+y*w]=(TT_PTYPE)(value);
       } /* end of y-loop */
   } /* end of x-loop */


   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction Profil                                                        */
/* arguments possibles:direction,nom du fichier,offset                    */
/**************************************************************************/
int tt_ima_series_profile(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int i,x,y;              /* loop variable */
   int offset;
   FILE *file;

   char message[TT_MAXLIGNE];


   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   w=p_in->naxis1;
   h=p_in->naxis2;
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for(x = 0; x < w;x++)
   {
       for(y = 0;y < h;y++)
       {
           p_out->p[x + y * w] =  p_in->p[x + y * w];
       } /* end of y-loop */
   } /* end of x-loop */
   index=pseries->index;
   offset=(int)pseries->offset-1;

    /* verification des donnees */
   if((strcmp(pseries->user3.direction,"x")!=0)&&(strcmp(pseries->user3.direction,"y")!=0))
   {
         sprintf(message,"direction must be x or y");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   }


   if(strcmp(pseries->user3.direction,"x")==0)
   {
   	if (offset < 0)
   	{
         sprintf(message,"offset must be contained between 1 and %d",w);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   	} /* end of if-statement */
   }
   else if (strcmp(pseries->user3.direction,"y")==0)
   	if (offset < 0)
   	{
         sprintf(message,"offset must be contained between 1 and %d",h);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   	} /* end of if-statement */

   /* write in a file */
   file = fopen(pseries->user3.filename,"wt");
/*   fprintf(file,"%s"\n","pixel            value of the pixel");*/
   fprintf(file,"%s\t%s\n","pixel","value of the pixel");
   if(strcmp(pseries->user3.direction,"x")==0)
   {
       for(i = 0;i < w;i++)
       fprintf(file,"%d\t%f\n",(i+1),p_in->p[i + offset * w]);
   }
   else
   {
       for(i = 0;i < h;i++)
       fprintf(file,"%d\t%f\n",(i+1),p_in->p[i * w + offset]);
   }
   fclose(file);


   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


/**************************************************************************/
/* Fonction Matrice                                                       */
/* arguments possibles: nom du fichier,x1,x2,y1,y2                        */
/**************************************************************************/
int tt_ima_series_matrix(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int x1,x2,y1,y2;
   int x,y;              /* loop variable */
   int temp;
   FILE *file;

   char message[TT_MAXLIGNE];

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   w=p_in->naxis1;
   h=p_in->naxis2;

   for(x = 0; x < w;x++)
   {
       for(y = 0;y < h;y++)
       {
           p_out->p[x + y * w] =  p_in->p[x + y * w];
       } /* end of y-loop */
   } /* end of x-loop */
   index=pseries->index;

   x1=pseries->user3.x1-1;
   x2=pseries->user3.x2-1;
   y1=pseries->user3.y1-1;
   y2=pseries->user3.y2-1;

   /* verification des valeurs */
   if ((y1 < 0) || (y2 < 0) || (y1 > h-1) || (y2 > h-1))
   {
         sprintf(message,"y1 and y2 must be contained between 1 and %d",h);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */
   if ((x1 < 0) || (x2 < 0) || (x1 > w-1) || (x2 > w-1))
   {
         sprintf(message,"x1 and x2 must be contained between 1 and %d",w);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   } /* end of if-statement */
   if(x1 > x2)
   {
       temp = x2;
       x2 = x1;
       x1 = temp;
   } /* end of if-statement */

   /* write in a file */
   file = fopen(pseries->user3.filematrix,"wt");
   fprintf(file,"%s\n","Value of the pixels");
   for(y = y1; y <= y2;y++)
   {
       for(x = x1; x <= x2;x++)
       {
          fprintf(file,"%s%d%s%d%s%f\n","x = ",x+1,"       y = ",y+1,"       value = ", p_in->p[x+y*w]);
       } /* end of x-loop */
   } /* end of y-loop */
   fclose(file);


   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


/**************************************************************************/
/* Fonction window                                                        */
/* arguments possibles:x1,x2,y1,y2                                        */
/**************************************************************************/
int tt_ima_series_window(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int x1,x2,y1,y2;
   int x,y;              /* loop variable */
   int temp;             /* temporary variable */
   int diff_x,diff_y;
   double a[6];

   char message[TT_MAXLIGNE];

   /* --- initialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;

   w=p_in->naxis1;
   h=p_in->naxis2;
   x1=pseries->user3.x1-1;
   x2=pseries->user3.x2-1;
   y1=pseries->user3.y1-1;
   y2=pseries->user3.y2-1;

   /* verification des donnees */
   if ((x1 < 0) || (x2 < 0) || (x1 > w-1) || (x2 > w-1))
   {
         sprintf(message,"x1 and x2 must be contained between 1 and %d",w);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */
   if ((y1 < 0) || (y2 < 0) || (y1 > h-1) || (y2 > h-1))
   {
         sprintf(message,"y1 and y2 must be contained between 1 and %d",h);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(x1 > x2)
   {
       temp = x1;
       x1 = x2;
       x2 = temp;
   }

   if(y1 > y2)
   {
       temp = y1;
       y1 = y2;
       y2 = temp;
   }

   diff_x = x2 - x1 + 1;
   diff_y = y2 - y1 + 1;

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,diff_x,diff_y);


   /* window */
   for(x = 0; x < diff_x;x++)
   {
       for(y = 0;y < diff_y;y++)
       {
         p_out->p[x + y * diff_x] =  p_in->p[(x1 + x) + (y1 + y) * w];
       } /* end of y-loop */
   } /* end of x-loop */

   /* --- calcule les nouveaux parametres de projection ---*/
   a[0]=1.;
   a[1]=0.;
   a[2]=x1;
   a[3]=0.;
   a[4]=1.;
   a[5]=y1;
   tt_util_update_wcs(p_in,p_out,a,2,NULL);

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction log                                                           */
/* arguments possibles:offset,coeff,nullpixel                             */
/**************************************************************************/
int tt_ima_series_log(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;
   int w, h;
   double offsetlog,coeff;
   int x,y;              /* loop variable */
   double value;          /* temporary variable */
   double nullpixel;

/*   char s[256]; */

   /* --- initialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;

   w=p_in->naxis1;
   h=p_in->naxis2;
   offsetlog=pseries->user3.offsetlog;
   coeff=pseries->user3.coeff;
   nullpixel=pseries->nullpix_value;

/*   sprintf(s,"coef=%f\noffset=%f",coeff,offsetlog); */
/*   MessageBox(NULL,s,"Libtt",MB_OK); */

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);


   /* log */
   for(x = 0; x < w;x++)
   {
       for(y = 0;y < h;y++)
       {
         value = p_in->p[x + y * w] - offsetlog;
         if (value <= 0)
         p_out->p[x + y * w] = (TT_PTYPE)nullpixel;
         else p_out->p[x + y * w] = (TT_PTYPE)(coeff *log10(value));
       } /* end of y-loop */
   } /* end of x-loop */

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction MedianX                                                      */
/* arguments possibles : x1,x2,width                                      */
/**************************************************************************/
int tt_ima_series_medianx(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int width;
   int x1,x2;
   int x,y;              /* loop variable */
   int temp;             /* temporary variable */
   int diff_x, diff_x_2;
   double *tab=NULL;
   double value;

   char message[TT_MAXLIGNE];
   int taille,msg;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;

   w=p_in->naxis1;
   h=p_in->naxis2;
   width=pseries->user3.width;
   x1=pseries->user3.x1-1;
   x2=pseries->user3.x2-1;


   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,width,p_in->naxis2);


   /* verification des donnees */
   if (width < 0)
   {
         sprintf(message,"width must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if ((x1 < 0) || (x2 < 0) || (x1 >w -1) || (x2 > w-1))
   {
         sprintf(message,"x1 and x2 must be contained between 1 and %d",w);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(x1 > x2)
   {
       temp = x2;
       x2 = x1;
       x1 = temp;
   } /* end of if-statement */

   diff_x = (x2 - x1) + 1;
   diff_x_2 = (int) (diff_x / 2);
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tab,&diff_x,&taille,"tab"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_medianx for pointer tab");
      return(TT_ERR_PB_MALLOC);
   }

   /* medianx */
   for(y = 0; y < h;y++)
   {
       for(x = 0;x < diff_x;x++)
       {
           *(tab + x) =
            p_in->p[(x1 + x) + (y * w)];
       } /* end of x-loop */
       tt_util_qsort_double(tab,0,diff_x,NULL);
       if ((diff_x % 2) == 1)
           value = *(tab + diff_x_2);
       else value =  (*(tab + diff_x_2) + *(tab + diff_x_2 - 1)) / 2;
       for(x = 0; x < width;x++)
       {
           p_out->p[x + y * width] = (TT_PTYPE)value;
       } /* end of x-loop */
   } /* end of y-loop */

   tt_free(tab,"tab");

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


/**************************************************************************/
/* Fonction MedianY                                                      */
/* arguments possibles : y1,y2,height                                     */
/**************************************************************************/
int tt_ima_series_mediany(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int height;
   int y1,y2;
   int x,y;              /* loop variable */
   double value;          /* temporary variable */
   int temp;             /* temporary variable */
   int diff_y,diff_y_2;
   double *tab=NULL;

   char message[TT_MAXLIGNE];
   int taille,msg;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;


   w=p_in->naxis1;
   h=p_in->naxis2;
   height=pseries->user3.height;
   y1=pseries->user3.y1-1;
   y2=pseries->user3.y2-1;

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,height);


   /* verification des donnees */
   if (height < 0)
   {
         sprintf(message,"height must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if ((y1 < 0) || (y2 < 0) || (y1 >h -1) || (y2 > h-1))
   {
         sprintf(message,"y1 and y2 must be contained between 1 and %d",h);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   } /* end of if-statement */


   /* mediany */
   diff_y = (y2 - y1) + 1;
   diff_y_2 = (int) (diff_y / 2);
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tab,&diff_y,&taille,"tab"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_mediany for pointer tab");
      return(TT_ERR_PB_MALLOC);
   }

   for(x = 0; x < w;x++)
   {
       for(y = 0;y < diff_y;y++)
       {
           *(tab + y) = p_in->p[x + ((y + y1) * w)];
       } /* end of x-loop */
       tt_util_qsort_double(tab,0,diff_y,NULL);
       if ((diff_y % 2) == 1)
           value = *(tab + diff_y_2);
       else value =  (*(tab + diff_y_2) + *(tab + diff_y_2 - 1)) / 2;
       for(y = 0; y < height;y++)
       {
           p_out->p[x + y * w] = (TT_PTYPE)value;
       } /* end of x-loop */
   } /* end of y-loop */

   tt_free(tab,"tab");

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction Rec2Pol                                                       */
/* arguments possibles : x0,y0,scale_rho,scale_theta                      */
/**************************************************************************/
int tt_ima_series_rec2pol(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   double scale_theta,scale_rho;
   int rho,theta;         /* loop variable */
   double value;           /* temporary variable */
   int x0,y0;
   double rho_max;
   int axis_theta,axis_rho;
   double old_x,old_y,temp;
   char message[TT_MAXLIGNE];

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;

   w=p_in->naxis1;
   h=p_in->naxis2;
   x0=(int)pseries->user3.x0-1;
   y0=(int)pseries->user3.y0-1;
   scale_theta=pseries->user3.scale_theta;
   scale_rho=pseries->user3.scale_rho;

   rho_max = sqrt(w * w + h * h);
   axis_theta = (int)(361. * scale_theta);
   axis_rho = (int)(rho_max * scale_rho + 1.);

   /* verification des donnees */
   if ((scale_theta < 0) || (scale_rho < 0))
   {
         sprintf(message,"scale must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,axis_theta,axis_rho);

   for(theta = 0;theta < axis_theta;theta++)
   {
   	for(rho = 0;rho < axis_rho;rho++)
      {
         temp = theta / scale_theta * (TT_PI/180.);
      	old_x = x0 + rho * cos(temp) / scale_rho;
         old_y = y0 + rho * sin(temp) / scale_rho;
         value = interpol(pseries,old_x,old_y,1);
         p_out->p[theta + rho * axis_theta] = (TT_PTYPE)value;
      } /* end of rho-loop */
   } /* end of theta_loop */

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction Pol2Rec                                                       */
/* arguments possibles : x0,y0,scale_rho,scale_theta,width,height         */
/**************************************************************************/
int tt_ima_series_pol2rec(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_out;
   int index;

   int width, height;
   double scale_theta,scale_rho;
   int x,y;               /* loop variable */
   double value;           /* temporary variable */
   int x0,y0;
   double old_rho,old_theta=0.;
   char message[TT_MAXLIGNE];

   /* --- intialisations ---*/
   p_out=pseries->p_out;
   index=pseries->index;

   width=pseries->user3.width;
   height=pseries->user3.height;
   x0=(int)(pseries->user3.x0-1);
   y0=(int)(pseries->user3.y0-1);
   scale_theta=pseries->user3.scale_theta;
   scale_rho=pseries->user3.scale_rho;


   /* verification des donnees */
   if ((scale_theta < 0) || (scale_rho < 0))
   {
         sprintf(message,"scale must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if ((width < 0) || (height < 0))
   {
         sprintf(message,"height and width must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,width,height);

   for(x = 0; x < width;x++)
   {
   	for(y = 0; y < height;y++)
      {
          if((x == x0) && (y == y0))
          {
          	old_rho = 0.;
            old_theta = 0.;
          }
          else
          {
          	old_rho = sqrt((x - x0) * (x - x0) + (y - y0) * (y - y0));
            if(y > y0)
          	old_theta = acos((x - x0) / old_rho) * 180. / TT_PI;
            else if (y < y0)
            old_theta = (360. - acos((x - x0) / old_rho) * 180. / TT_PI);
            else if ((y == y0) && (x < x0))
            old_theta = 180.;
            else if ((y == y0) && (x >= x0))
            old_theta = 0.;
          }
          value = interpol(pseries,old_theta * scale_theta,old_rho * scale_rho,1);
      	 p_out->p[x + y * width] = (TT_PTYPE)value;
      } /* end of y-loop */
   } /* end of x-loop */


   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


