/* rgbtcl_1.c
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
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers rgb_*.c.                              */
/***************************************************************************/
/* Le include rgbtcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "rgbtcl.h"


int Cmd_rgbtcl_save(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* sauve les buffers RGB                                                    */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[100];
   char lignetcl[2000];
   char extension[1024];
   char **argvv=NULL;
   int k,argcc,code,numbufr=1001,numbufg=1002,numbufb=1003,nbimages=0;

   if(argc<2) {
      sprintf(s,"Usage: %s filename ?filenameg filenameb? ?-buffer {Nobufr Nobufg Nobufb}?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      result = TCL_OK;
      nbimages=argc-1;
      if (nbimages>3) {nbimages=3;}
      /* --- decode les parametres d'option ---*/
      for (k=2;k<argc;k++) {
         if (strcmp(argv[k],"-buffer")==0) {
            if (k<4) {nbimages=1;}
            argvv=NULL;
            code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
            if (code==TCL_OK) {
               if (argcc!=3) {
                  Tcl_Free((char *) argvv);
                  strcpy(s,"Three elements required in parameter {Nobufr Nobufg Nobufb}");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_ERROR;
               } else {
                  numbufr=(int)atoi(argvv[0]);
                  numbufg=(int)atoi(argvv[1]);
                  numbufb=(int)atoi(argvv[2]);
                  Tcl_Free((char *) argvv);
               }
            } else {
               strcpy(s,"Decode problem");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
      }
   }

   /* --- verifie l'existence des buffers ---*/
   sprintf(s,"lsearch [::buf::list] %d",numbufr);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"Buffer %d not created",numbufr);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   sprintf(s,"lsearch [::buf::list] %d",numbufg);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"Buffer %d not created",numbufg);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   sprintf(s,"lsearch [::buf::list] %d",numbufb);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"Buffer %d not created",numbufb);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }

   sprintf(lignetcl,"buf%d extension",numbufr);
   Tcl_Eval(interp,lignetcl);
   strcpy(extension,Tcl_GetStringResult(interp));
   /* --- commence a sauver le buffer R ---*/
   sprintf(lignetcl,"file extension %s",argv[1]);
   Tcl_Eval(interp,lignetcl);
   strcpy(s,Tcl_GetStringResult(interp));
   if (strcmp(s,"")==0) { strcpy(s,extension); }
   sprintf(lignetcl,"buf%d save [file rootname %s]%s",numbufr,argv[1],s);
   Tcl_Eval(interp,lignetcl);
   /*
   sprintf(lignetcl,"%s",lignetcl);
   Tcl_SetResult(interp,lignetcl,TCL_VOLATILE);
   */
   /* --- sauver les buffers G et B ---*/
   if (nbimages==3) {
      /* --- les images sont sauvees individuellement ---*/
      sprintf(lignetcl,"buf%d save %s",numbufg,argv[2]);
      Tcl_Eval(interp,lignetcl);
      sprintf(lignetcl,"buf%d save %s",numbufb,argv[3]);
      Tcl_Eval(interp,lignetcl);
   } else {
      /* --- les images sont sauvees dans le meme fichier ---*/
      sprintf(lignetcl,"buf%d save [file rootname %s]%s\\;2",numbufg,argv[1],s);
      Tcl_Eval(interp,lignetcl);
      sprintf(lignetcl,"buf%d save [file rootname %s]%s\\;3",numbufb,argv[1],s);
      Tcl_Eval(interp,lignetcl);
   }
   return TCL_OK;
}

int Cmd_rgbtcl_load(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* charge les buffers RGB                                                   */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[100];
   char lignetcl[2000];
   char extension[1024];
   char **argvv=NULL;
   int k,argcc,code,numbufr=1001,numbufg=1002,numbufb=1003,nbimages=0;
   float *pixels;
   int naxis1, naxis2;
   int numbufdisp = 1000;

   if(argc<2) {
      sprintf(s,"Usage: %s filename ?filenameg filenameb? ?-buffer {Nobufr Nobufg Nobufb NoBufDisp}?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result = TCL_OK;
      nbimages=argc-1;
      if (nbimages>3) {nbimages=3;}
      /* --- decode les parametres d'option ---*/
      for (k=2;k<argc;k++) {
         if (strcmp(argv[k],"-buffer")==0) {
            if (k<4) {nbimages=1;}
            argvv=NULL;
            code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
            if (code==TCL_OK) {
               if (argcc!=4) {
                  Tcl_Free((char *) argvv);
                  strcpy(s,"Three elements required in parameter {Nobufr Nobufg Nobufb}");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_ERROR;
               } else {
                  numbufr=(int)atoi(argvv[0]);
                  numbufg=(int)atoi(argvv[1]);
                  numbufb=(int)atoi(argvv[2]);
                  numbufdisp=(int)atoi(argvv[3]);
                  Tcl_Free((char *) argvv);
               }
            } else {
               strcpy(s,"Decode problem");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
      }
   }

   /* --- verifie l'existence des buffers ---*/

   sprintf(lignetcl,"lsearch [::buf::list] %d",numbufdisp);
   Tcl_Eval(interp,lignetcl);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(lignetcl,"::buf::create %d",numbufdisp);
      Tcl_Eval(interp,lignetcl);
   }

   sprintf(lignetcl,"lsearch [::buf::list] %d",numbufr);
   Tcl_Eval(interp,lignetcl);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(lignetcl,"::buf::create %d",numbufr);
      Tcl_Eval(interp,lignetcl);
   }
   sprintf(lignetcl,"lsearch [::buf::list] %d",numbufg);
   Tcl_Eval(interp,lignetcl);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(lignetcl,"::buf::create %d",numbufg);
      Tcl_Eval(interp,lignetcl);
   }
   sprintf(lignetcl,"lsearch [::buf::list] %d",numbufb);
   Tcl_Eval(interp,lignetcl);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(lignetcl,"::buf::create %d",numbufb);
      Tcl_Eval(interp,lignetcl);
   }

   sprintf(lignetcl,"buf%d extension",numbufr);
   Tcl_Eval(interp,lignetcl);
   strcpy(extension,Tcl_GetStringResult(interp));
   /* --- commence a charger le buffer R ---*/
   sprintf(lignetcl,"file extension %s",argv[1]);
   Tcl_Eval(interp,lignetcl);
   strcpy(s,Tcl_GetStringResult(interp));
   if (strcmp(s,"")==0) { strcpy(s,extension); }
   sprintf(lignetcl,"buf%d load [file rootname %s]%s",numbufr,argv[1],s);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) {
      return TCL_ERROR;
   }
   /* --- charger les buffers G et B ---*/
   if (nbimages==3) {
      /* --- les images sont chargees individuellement ---*/
      sprintf(lignetcl,"buf%d load %s",numbufg,argv[2]);
      Tcl_Eval(interp,lignetcl);
      sprintf(lignetcl,"buf%d load %s",numbufb,argv[3]);
      Tcl_Eval(interp,lignetcl);
   } else {
      /* --- les images sont chargees dans le meme fichier ---*/
      if (strcmp(s,"")==0) { strcpy(s,extension); }
      sprintf(lignetcl,"buf%d load [file rootname %s]%s\\;2",numbufg,argv[1],s);
      if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) {
         return TCL_ERROR;
      }

      sprintf(lignetcl,"buf%d load [file rootname %s]%s\\;3",numbufb,argv[1],s);
      if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) {
         return TCL_ERROR;
      }
   }

   // je recupere les dimensions de l'image
   sprintf(lignetcl,"lindex [buf%d getkwd NAXIS1] 1", numbufr);
   Tcl_Eval(interp,lignetcl);
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&naxis1);
   sprintf(lignetcl,"lindex [buf%d getkwd NAXIS2] 1", numbufr);
   Tcl_Eval(interp,lignetcl);
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&naxis2);

   // je charge l'image dans le buffer d'affichage

   // je reserve la place des pixels dans le buffer d'affichage
   sprintf(lignetcl,"buf%d setpixels CLASS_RGB %d %d  FORMAT_FLOAT COMPRESS_NONE %lu",
      numbufdisp ,naxis1, naxis2, 0);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

   // je prepare une zone mÃ©moire de transfert
   pixels = (float*)calloc(naxis1*naxis2,sizeof(float));
   if(pixels==NULL) { return TCL_ERROR; }

   // je recupere les pixels du plan RED
   sprintf(lignetcl,"buf%d getpixels %lu PLANE_RED",numbufr, pixels);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

   // je copie les pixel RED dans le buffer numbuf d'affichage
   sprintf(lignetcl,"buf%d mergepixels PLANE_RED %lu", numbufdisp, pixels);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

   // je recupere les pixels du plan GREEN
   sprintf(lignetcl,"buf%d getpixels %lu PLANE_GREEN",numbufg, pixels);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

   // je copie les pixel GREEN dans le buffer numbuf d'affichage
   sprintf(lignetcl,"buf%d mergepixels PLANE_GREEN %lu",numbufdisp, pixels);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

   // je recupere les pixels du plan BLUE
   sprintf(lignetcl,"buf%d getpixels %lu PLANE_BLUE",numbufb, pixels);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

   // je copie les pixel BLUE dans le buffer numbuf d'affichage
   sprintf(lignetcl,"buf%d mergepixels PLANE_BLUE %lu", numbufdisp, pixels);
   if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

   return TCL_OK;
}

int Cmd_rgbtcl_visu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Visu couleur avec trois buffers 1001 a 1003                              */
/****************************************************************************/
/****************************************************************************/
{
   Tk_PhotoHandle ph;
   Tk_PhotoImageBlock pib;
   double fsh_r,fsb_r,dyn_r,fpix_r;
   double fsh_g,fsb_g,dyn_g,fpix_g;
   double fsh_b,fsb_b,dyn_b,fpix_b;
   double val_r,val_g,val_b;
   unsigned char ucval_r,ucval_g,ucval_b;
   float *pix_r, *ppix_r;
   float *pix_g, *ppix_g;
   float *pix_b, *ppix_b;
   //int ptri;
   int pbsize=0;
   int i, j,result,k;
   unsigned char *ptr, *pptr;
   int x1=-1,x2=-1,y1=-1,y2=-1;
   rgb_image image;
   /* window width, height multiplied by zoom */
   int ww, wh;
   /* window coordinates */
   int xx1, yy1, xx2, yy2;
   /* picture width, height */
   int orgw, orgh;
   /* original window width, height */
   int orgww, orgwh;
   char s[100];
   double zoom=1;
   char **argvv=NULL;
   int m,n,numimage=1000;
   int argcc,code,numbufr=1001,numbufg=1002,numbufb=1003;
   int tzoom;

   /* --- decode les arguments de la ligne de commande ---*/
   if(argc<4) {
      sprintf(s,"Usage: %s {hicutr locutr} {hicutg locutg} {hicutb locutb} ?-zoom valzoom? ?-window {x1 y1 x2 y2}? ?-buffer {Nobufr Nobufg Nobufb}? ?-image Noimage?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   result = TCL_OK;
   argvv=NULL;
   code=Tcl_SplitList(interp,argv[1],&argcc,&argvv);
   if (code==TCL_OK) {
      if (argcc!=2) {
         Tcl_Free((char *) argvv);
         strcpy(s,"Two elements required in parameter {hicutr locutr}");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         fsh_r=atof(argvv[0]);
         fsb_r=atof(argvv[1]);
         Tcl_Free((char *) argvv);
      }
   } else {
      strcpy(s,"Decode problem");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   argvv=NULL;
   code=Tcl_SplitList(interp,argv[2],&argcc,&argvv);
   if (code==TCL_OK) {
      if (argcc!=2) {
         Tcl_Free((char *) argvv);
         strcpy(s,"Two elements required in parameter {hicutg locutg}");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         fsh_g=atof(argvv[0]);
         fsb_g=atof(argvv[1]);
         Tcl_Free((char *) argvv);
      }
   } else {
      strcpy(s,"Decode problem");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   argvv=NULL;
   code=Tcl_SplitList(interp,argv[3],&argcc,&argvv);
   if (code==TCL_OK) {
      if (argcc!=2) {
         Tcl_Free((char *) argvv);
         strcpy(s,"Two elements required in parameter {hicutb locutb}");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         fsh_b=atof(argvv[0]);
         fsb_b=atof(argvv[1]);
         Tcl_Free((char *) argvv);
      }
   } else {
      strcpy(s,"Decode problem");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   /* --- decode les parametres d'option ---*/
   for (k=4;k<argc;k++) {
      if (strcmp(argv[k],"-zoom")==0) {
         zoom=atof(argv[k+1]);
         if((zoom!=.125)&&(zoom!=.25)&&(zoom!=.5)&&(zoom!=2)&&(zoom!=4)&&(zoom!=8)) {
            zoom = 1.;
         }
      }
      if (strcmp(argv[k],"-window")==0) {
         argvv=NULL;
         code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
         if (code==TCL_OK) {
            if (argcc!=4) {
               Tcl_Free((char *) argvv);
               strcpy(s,"Two elements required in parameter {hicutb locutb}");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               x1=atoi(argvv[0]);
               y1=atoi(argvv[1]);
               x2=atoi(argvv[2]);
               y2=atoi(argvv[3]);
               Tcl_Free((char *) argvv);
            }
         } else {
            strcpy(s,"Decode problem");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
      if (strcmp(argv[k],"-buffer")==0) {
         argvv=NULL;
         code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
         if (code==TCL_OK) {
            if (argcc!=3) {
               Tcl_Free((char *) argvv);
               strcpy(s,"Three elements required in parameter {Nobufr Nobufg Nobufb}");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               numbufr=(int)atoi(argvv[0]);
               numbufg=(int)atoi(argvv[1]);
               numbufb=(int)atoi(argvv[2]);
               Tcl_Free((char *) argvv);
            }
         } else {
            strcpy(s,"Decode problem");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
      if (strcmp(argv[k],"-image")==0) {
         numimage=(int)atoi(argv[k+1]);
      }
   }

   /* --- verifie l'existence des buffers ---*/
   sprintf(s,"lsearch [::buf::list] %d",numbufr);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"Buffer %d not created",numbufr);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   sprintf(s,"lsearch [::buf::list] %d",numbufg);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"Buffer %d not created",numbufg);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   sprintf(s,"lsearch [::buf::list] %d",numbufb);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"Buffer %d not created",numbufb);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }

   /* --- recherche les infos sur l'image R ---*/
   result=rgbtcl_getinfoimage(interp,numbufr,&image);

   if( image.naxis1 * image.naxis2  == 0 )
      return TCL_OK;

   /* --- recupere les dimensions ---*/
   orgw=image.naxis1;
   orgh=image.naxis2;
   /* --- recherche les infos sur l'image G ---*/
   result=rgbtcl_getinfoimage(interp,numbufg,&image);
   pbsize=0;
   if (orgw!=image.naxis1) { pbsize=1; }
   if (orgh!=image.naxis2) { pbsize=1; }
   /* --- recherche les infos sur l'image G ---*/
   result=rgbtcl_getinfoimage(interp,numbufb,&image);
   pbsize=0;
   if (orgw!=image.naxis1) { pbsize=1; }
   if (orgh!=image.naxis2) { pbsize=1; }
   if (pbsize==1) {
      strcpy(s,"Problem of different image size");
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   /* --- fenetre de visu en coordonnees utilisateur ---*/
   if (x1==-1) {
      x1=1;
      x2=orgw;
      y1=1;
      y2=orgh;
   } else {
      if (x1<1) {x1=1;}
      if (x1>orgw) {x1=orgw;}
      if (y1<1) {y1=1;}
      if (y1>orgh) {y1=orgh;}
      if (x2<1) {x2=1;}
      if (x2>orgw) {x2=orgw;}
      if (y2<1) {y2=1;}
      if (y2>orgh) {y2=orgh;}
      if (x1>x2) { xx1=x1; x1=x2; x2=xx1; }
      if (y1>y2) { yy1=y1; y1=y2; y2=yy1; }
   }

   /* --- fenetre de visu en coordonnees pointeur ---*/
   xx1 = x1-1;
   yy1 = y1-1;
   xx2 = x2-1;
   yy2 = y2-1;
   /* --- recupere les 3 pointeurs RGB ---*/
/*
   sprintf(s,"buf%d pointer",numbufr);
   Tcl_Eval(interp,s);
   pix_r=NULL;
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptri);
   pix_r=(float*)ptri;
   sprintf(s,"buf%d pointer",numbufg);
   Tcl_Eval(interp,s);
   pix_g=NULL;
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptri);
   pix_g=(float*)ptri;
   sprintf(s,"buf%d pointer",numbufb);
   Tcl_Eval(interp,s);
   pix_b=NULL;
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptri);
   pix_b=(float*)ptri;
*/

   pix_r = (float*)calloc(orgw*orgh,sizeof(float));
   if(pix_r==NULL) { return TCL_ERROR; }
   sprintf(s,"buf%d getpixels %d",numbufr, (int) pix_r);
   Tcl_Eval(interp,s);

   pix_g = (float*)calloc(orgw*orgh,sizeof(float));
   if(pix_g==NULL) { return TCL_ERROR; }
   sprintf(s,"buf%d getpixels %d",numbufg, (int)pix_g);
   Tcl_Eval(interp,s);

   pix_b = (float*)calloc(orgw*orgh,sizeof(float));
   if(pix_b==NULL) { return TCL_ERROR; }
   sprintf(s,"buf%d getpixels %d",numbufb, (int) pix_b);
   Tcl_Eval(interp,s);

   /* --- Largeur et hauteur de la fenetre au depart ---*/
   orgww = xx2 - xx1 + 1;
   orgwh = yy2 - yy1 + 1;
   /* --- Largeur et hauteur de la fenetre a l'arrivee, en pixels unitaires ---*/
   ww = (int)(zoom * orgww);     /* Largeur de la fenetre a l'arrivee, en pixels unitaires*/
   wh = (int)(zoom * orgwh);     /* Hauteur ...*/

   pptr = ptr = (unsigned char*)calloc(ww*wh*3,1);
   if(ptr==NULL) {
      return TCL_ERROR;
   }

   /* --- calcul de la dynamique ---*/
   if(fsh_r==fsb_r) { dyn_r = -1e10; } else { dyn_r = 256. / (fsh_r - fsb_r); }
   if(fsh_g==fsb_g) { dyn_g = -1e10; } else { dyn_g = 256. / (fsh_g - fsb_g); }
   if(fsh_b==fsb_b) { dyn_b = -1e10; } else { dyn_b = 256. / (fsh_b - fsb_b); }

   if(zoom==1.) {
      ppix_r = pix_r + orgw * yy2 + xx1;
      ppix_g = pix_g + orgw * yy2 + xx1;
      ppix_b = pix_b + orgw * yy2 + xx1;
      for(j=yy1;j<=yy2;j++) {
         for(i=xx1;i<=xx2;i++) {
            /* --- rouge --- */
            fpix_r = (double)*ppix_r++;
            val_r  = (fpix_r-fsb_r)*dyn_r;
            ucval_r = min(max((int)val_r,0),255);
            *pptr++ = ucval_r;
            /* --- vert --- */
            fpix_g = (double)*ppix_g++;
            val_g  = (fpix_g-fsb_g)*dyn_g;
            ucval_g = min(max((int)val_g,0),255);
            *pptr++ = ucval_g;
            /* --- bleu --- */
            fpix_b = (double)*ppix_b++;
            val_b  = (fpix_b-fsb_b)*dyn_b;
            ucval_b = min(max((int)val_b,0),255);
            *pptr++ = ucval_b;
         }
         ppix_r -= (orgw+ww);
         ppix_g -= (orgw+ww);
         ppix_b -= (orgw+ww);
      }
   } else if (zoom>1) {
      tzoom=(int)zoom;
      ppix_r = pix_r + orgw * yy2 + xx1;
      ppix_g = pix_g + orgw * yy2 + xx1;
      ppix_b = pix_b + orgw * yy2 + xx1;
      for(j=yy1;j<=yy2;j++) {
         for(n=0;n<tzoom;n++) {
            for(i=xx1;i<=xx2;i++) {
               /* --- rouge --- */
               fpix_r = (double)*ppix_r++;
               val_r  = (fpix_r-fsb_r)*dyn_r;
               ucval_r = min(max((int)val_r,0),255);
               /* --- vert --- */
               fpix_g = (double)*ppix_g++;
               val_g  = (fpix_g-fsb_g)*dyn_g;
               ucval_g = min(max((int)val_g,0),255);
               /* --- bleu --- */
               fpix_b = (double)*ppix_b++;
               val_b  = (fpix_b-fsb_b)*dyn_b;
               ucval_b = min(max((int)val_b,0),255);
               for(m=0;m<tzoom;m++) {
                  *pptr++ = ucval_r;
                  *pptr++ = ucval_g;
                  *pptr++ = ucval_b;
               }
            }
            ppix_r -= orgw;
            ppix_g -= orgw;
            ppix_b -= orgw;
         }
         ppix_r -= orgw;
         ppix_g -= orgw;
         ppix_b -= orgw;
      }
   } else {
      tzoom=(int)(1./zoom);
      ppix_r = pix_r + orgw * yy2 + xx1;
      ppix_g = pix_g + orgw * yy2 + xx1;
      ppix_b = pix_b + orgw * yy2 + xx1;
      for(j=yy1;j<=yy2;j+=tzoom) {
         for(i=xx1;i<=xx2;i+=tzoom) {
            /*fpix = *ppix++;*/
            /*ppix = pix + orgw * (yy2-j) + i;*/
            /*fpix = *ppix;*/
            /* --- rouge --- */
            ppix_r = pix_r + orgw * (yy2-j) + i;
            fpix_r = (double)*ppix_r;
            val_r  = (fpix_r-fsb_r)*dyn_r;
            ucval_r = min(max((int)val_r,0),255);
            /* --- vert --- */
            ppix_g = pix_g + orgw * (yy2-j) + i;
            fpix_g = (double)*ppix_g;
            val_g  = (fpix_g-fsb_g)*dyn_g;
            ucval_g = min(max((int)val_g,0),255);
            /* --- bleu --- */
            ppix_b = pix_b + orgw * (yy2-j) + i;
            fpix_b = (double)*ppix_b;
            val_b  = (fpix_b-fsb_b)*dyn_b;
            ucval_b = min(max((int)val_b,0),255);
            *pptr++ = ucval_r;
            *pptr++ = ucval_g;
            *pptr++ = ucval_b;
         }
         ppix_r -= orgw;
         ppix_g -= orgw;
         ppix_b -= orgw;
      }
   }

   /* Preparation de la structure a passer a TCL/TK pour afficher l'image. */
   pib.pixelPtr = ptr;
   pib.width = ww;
   pib.height = wh;
   pib.pitch = ww*3;
   pib.pixelSize = 3;
   pib.offset[0] = 0;
   pib.offset[1] = 1;
   pib.offset[2] = 2;

   /* Affichage de l'image dans 'image1000' */
   sprintf(s,"catch {image delete imagevisu%d}",numimage);
   Tcl_Eval(interp,s);
   sprintf(s,"image create photo imagevisu%d",numimage);
   Tcl_Eval(interp,s);
   sprintf(s,"imagevisu%d",numimage);
   ph = Tk_FindPhoto(interp,s);

   if(ph==NULL) {
      if(ptr) free(ptr);
      if(pix_r) free(pix_r);
      if(pix_g) free(pix_g);
      if(pix_b) free(pix_b);
      return TCL_ERROR;
   }

   Tk_PhotoPutBlock(interp,ph,&pib,0,0,ww,wh,TK_PHOTO_COMPOSITE_SET);

   if(ptr) free(ptr);
   if(pix_r) free(pix_r);
   if(pix_g) free(pix_g);
   if(pix_b) free(pix_b);

   return TCL_OK;

}

int Cmd_rgbtcl_split(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Separe l'image d'un KAF-400 couleur en trois buffers 1001 a 1003         */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   rgb_image image;
   int numbuf;
   int naxis1=0,naxis2=0,naxis1c=0,naxis2c,i,j,ki,kj;
   //int ptri;
   float *ptr,*ptr_r,*ptr_g,*ptr_b,*ptr_c,*ptr_m,*ptr_y,val1,val2,val3;
   char lignetcl[100];
   char **argvv=NULL;
   int k,argcc,code,numbufr=1001,numbufg=1002,numbufb=1003;
   int offsetx=0,offsety=0;
   int typecodage=1;

   if(argc<2) {
      sprintf(s,"Usage: %s numbuf ?-buffer {Nobufr Nobufg Nobufb}? ?-rgb type?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result = TCL_OK;
      /* --- decode les parametres obligatoires ---*/
      retour = Tcl_GetInt(interp,argv[1],&numbuf);
      if(retour!=TCL_OK) return retour;
      /* --- decode les parametres d'option ---*/
      for (k=2;k<argc-1;k++) {
         if (strcmp(argv[k],"-buffer")==0) {
            argvv=NULL;
            code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
            if (code==TCL_OK) {
               if (argcc!=3) {
                  Tcl_Free((char *) argvv);
                  strcpy(s,"Three elements required in parameter {Nobufr Nobufg Nobufb}");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_ERROR;
               } else {
                  numbufr=(int)atoi(argvv[0]);
                  numbufg=(int)atoi(argvv[1]);
                  numbufb=(int)atoi(argvv[2]);
                  Tcl_Free((char *) argvv);
               }
            } else {
               strcpy(s,"Decode problem");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
         if (strcmp(argv[k],"-offset")==0) {
            argvv=NULL;
            code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
            if (code==TCL_OK) {
               if (argcc!=2) {
                  Tcl_Free((char *) argvv);
                  strcpy(s,"Two elements required in parameter {OffsetX OffsetY}");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_ERROR;
               } else {
                  offsetx=(int)atoi(argvv[0]);
                  offsety=(int)atoi(argvv[1]);
                  Tcl_Free((char *) argvv);
               }
            } else {
               strcpy(s,"Decode problem");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
         if (strcmp(argv[k],"-rgb")==0) {
            argvv=NULL;
            code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
            if (code==TCL_OK) {
			   /* de base :
			   "none", 0
               "cfa", 1
	           "rgb", 2
	           "gbr", 3
	           "brg", 4
			   "bgr", 5
			   "cmy", 6
               */
               if (strcmp(argvv[0],"cfa")==0) {
				   typecodage=1;
			   }
               if (strcmp(argvv[0],"rgb")==0) {
				   typecodage=2;
			   }
               if (strcmp(argvv[0],"bgr")==0) {
				   typecodage=5;
			   }
               if (strcmp(argvv[0],"cmy")==0) {
				   typecodage=6;
			   }
               Tcl_Free((char *) argvv);
            } else {
               strcpy(s,"Decode problem");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
      }

      /*--- initialise la dynamic string ---*/
      Tcl_DStringInit(&dsptr);
      /* --- recherche les infos ---*/
      result=rgbtcl_getinfoimage(interp,numbuf,&image);
      /* --- cree les 3 images de type CFA ---*/
	  if ((typecodage==1) || (typecodage==6)) {
         naxis1=image.naxis1;
         naxis2=image.naxis2;
         naxis1c=naxis1;
         naxis2c=naxis2;
         /**/
         /*
         sprintf(lignetcl,"if {[lsearch [buf::list] %ld]==-1} {::buf::create %ld}",numbufr,numbufr);
         Tcl_Eval(interp,lignetcl);
         */
         sprintf(lignetcl,"buf%d copyto %d\n",numbuf,numbufr);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d setkwd [list \"RGBFILTR\" \"R\" string \"Color extracted (Red)\" \"\"]\n",numbufr);
         Tcl_Eval(interp,lignetcl);
         /**/
         /*
         sprintf(lignetcl,"if {[lsearch [buf::list] %ld]==-1} {::buf::create %ld}",numbufg,numbufg);
         Tcl_Eval(interp,lignetcl);
         */
         sprintf(lignetcl,"buf%d copyto %d\n",numbuf,numbufg);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d setkwd [list \"RGBFILTR\" \"G\" string \"Color extracted (Green)\" \"\"]\n",numbufg);
         Tcl_Eval(interp,lignetcl);
         /**/
         /*
         sprintf(lignetcl,"if {[lsearch [buf::list] %ld]==-1} {::buf::create %ld}",numbufb,numbufb);
         Tcl_Eval(interp,lignetcl);
         */
         sprintf(lignetcl,"buf%d copyto %d\n",numbuf,numbufb);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d setkwd [list \"RGBFILTR\" \"B\" string \"Color extracted (Blue)\" \"\"]\n",numbufb);
         Tcl_Eval(interp,lignetcl);
      }
      /* --- cree les 3 images de type RGB ---*/
	  if ((typecodage>=2)&&(typecodage<=5)) {
         naxis1=image.naxis1;
         naxis2=image.naxis2;
         naxis1c=naxis1/3;
         naxis2c=naxis2;
         /**/
         sprintf(lignetcl,"::buf::create %d",numbufr);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d copykwd %d\n",numbuf,numbufr);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d setkwd {\"RGBFILTR\" \"R\" string \"Color extracted (Red)\" \"\"}\n",numbufr);
         Tcl_Eval(interp,lignetcl);
         /**/
         sprintf(lignetcl,"::buf::create %d",numbufg);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d copykwd %d\n",numbuf,numbufg);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d setkwd {\"RGBFILTR\" \"G\" string \"Color extracted (Green)\" \"\"}\n",numbufg);
         Tcl_Eval(interp,lignetcl);
         /**/
         sprintf(lignetcl,"::buf::create %d",numbufb);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d copykwd %d\n",numbuf,numbufb);
         Tcl_Eval(interp,lignetcl);
         sprintf(lignetcl,"buf%d setkwd {\"RGBFILTR\" \"B\" string \"Color extracted (Blue)\" \"\"}\n",numbufb);
         Tcl_Eval(interp,lignetcl);
     }


      /* -- recherche les adresses de pointeur des images --*/
      /*
      sprintf(s,"buf%d pointer",numbuf);
      Tcl_Eval(interp,s);
      ptr=NULL;
      Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptri);
      ptr=(float*)ptri;

      sprintf(s,"buf%d pointer",numbufr);
      Tcl_Eval(interp,s);
      ptr_r=NULL;
      Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptri);
      ptr_r=(float*)ptri;

      sprintf(s,"buf%d pointer",numbufg);
      Tcl_Eval(interp,s);
      ptr_g=NULL;
      Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptri);
      ptr_g=(float*)ptri;

      sprintf(s,"buf%d pointer",numbufb);
      Tcl_Eval(interp,s);
      ptr_b=NULL;
      Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptri);
      ptr_b=(float*)ptri;
      */

     ptr_r = (float*)calloc(naxis1*naxis2,sizeof(float));
     if(ptr_r==NULL) { return TCL_ERROR; }
     ptr_g = (float*)calloc(naxis1*naxis2,sizeof(float));
     if(ptr_g==NULL) { return TCL_ERROR; }
     ptr_b = (float*)calloc(naxis1*naxis2,sizeof(float));
     if(ptr_b==NULL) { return TCL_ERROR; }


	  if ((typecodage==1) || (typecodage==6)) {
         // je recupere les pixels
         ptr = (float*)calloc(naxis1*naxis2*3,sizeof(float));
         if(ptr_r==NULL) { return TCL_ERROR; }
         sprintf(s,"buf%d getpixels %lu PLANE_RGB",numbuf, ptr);
         Tcl_Eval(interp,s);

         /*--- separation des plans de couleur CFA --- */
	     offsetx=(int)fmod((double)offsetx,2.);
	     offsety=(int)fmod((double)offsety,2.);
         for (kj=offsety,j=0;j<naxis2;j++) {
            for (ki=offsetx,i=0;i<naxis1;i++) {
               val1=ptr[j*naxis1+i];
               if (kj==0) {
                  if (ki==0) {
                     ptr_r[j*naxis1+i]=val1;
                     ki=1;
                  } else {
                     ptr_g[j*naxis1+i]=val1;
                     ki=0;
                  }
               } else {
                  if (ki==0) {
                     ptr_g[j*naxis1+i]=val1;
                     ki=1;
                  } else {
                     ptr_b[j*naxis1+i]=val1;
                     ki=0;
                  }
               }
            }
            kj=(kj==0)?1:0;
         }
         /* --- interpolation pour l'image rouge ---*/
         for (j=0;j<naxis2;j+=2) {
            for (i=1;i<naxis1-1;i+=2) {
               val1=ptr_r[j*naxis1+i-1];
               val2=ptr_r[j*naxis1+i+1];
               ptr_r[j*naxis1+i]=(float)((val1+val2)/2.);
            }
         }
         for (j=1;j<naxis2-1;j+=2) {
            for (i=0;i<naxis1;i++) {
               val1=ptr_r[(j-1)*naxis1+i];
               val2=ptr_r[(j+1)*naxis1+i];
               ptr_r[j*naxis1+i]=(float)((val1+val2)/2.);
            }
         }
         /* --- interpolation pour l'image bleue ---*/
         for (j=1;j<naxis2;j+=2) {
            for (i=2;i<naxis1-1;i+=2) {
               val1=ptr_b[j*naxis1+i-1];
               val2=ptr_b[j*naxis1+i+1];
               ptr_b[j*naxis1+i]=(float)((val1+val2)/2.);
            }
         }
         for (j=2;j<naxis2-1;j+=2) {
            for (i=0;i<naxis1;i++) {
               val1=ptr_b[(j-1)*naxis1+i];
               val2=ptr_b[(j+1)*naxis1+i];
               ptr_b[j*naxis1+i]=(float)((val1+val2)/2.);
            }
         }
         /* --- interpolation pour l'image verte ---*/
         for (kj=0,j=0;j<naxis2;j++) {
            if (kj==0) {ki=2;kj=1;}
            else {ki=1;kj=0;}
            for (i=ki;i<naxis1-1;i+=2) {
               val1=ptr_g[j*naxis1+i-1];
               val2=ptr_g[j*naxis1+i+1];
               ptr_g[j*naxis1+i]=(float)((val1+val2)/2.);
            }
         }
         free(ptr);
      }

	  if (typecodage==2) {
         // je recupere les pixels
         ptr = (float*)calloc(naxis1*naxis2*3,sizeof(float));
         if(ptr_r==NULL) { return TCL_ERROR; }
         sprintf(s,"buf%d getpixels %lu PLANE_RGB",numbuf, ptr);
         Tcl_Eval(interp,s);
         /*--- separation des plans de couleur RGB --- */
         for (j=0;j<naxis2;j++) {
            for (i=0,ki=0;i<naxis1;i+=3,ki++) {
               val1=ptr[j*naxis1+i];
               val2=ptr[j*naxis1+i+1];
               val3=ptr[j*naxis1+i+2];
               ptr_r[j*naxis1c+ki]=(float)(val1);
               ptr_g[j*naxis1c+ki]=(float)(val2);
               ptr_b[j*naxis1c+ki]=(float)(val3);
            }
         }
         free(ptr);
     }

	  if (typecodage==5) {
         /*--- separation des plans de couleur BGR --- */
         /*
         for (j=0;j<naxis2;j++) {
            for (i=0,ki=0;i<naxis1;i+=3,ki++) {
               val1=ptr[j*naxis1+i];
               val2=ptr[j*naxis1+i+1];
               val3=ptr[j*naxis1+i+2];
               ptr_b[j*naxis1c+ki]=(float)(val1);
               ptr_g[j*naxis1c+ki]=(float)(val2);
               ptr_r[j*naxis1c+ki]=(float)(val3);
            }
         }
         */
         // je recupere les pixels du plan RED
         sprintf(s,"buf%d getpixels %lu PLANE_RED",numbuf, ptr_r);
         Tcl_Eval(interp,s);

         // je recupere les pixels du plan GREEN
         sprintf(s,"buf%d getpixels %lu PLANE_GREEN",numbuf, ptr_g);
         Tcl_Eval(interp,s);

         // je recupere les pixels du plan BLUE
         sprintf(s,"buf%d getpixels %lu PLANE_BLUE",numbuf, ptr_b);
         Tcl_Eval(interp,s);

     }

	  if (typecodage==6) {
         // je recupere les pixels du plan RED
         sprintf(s,"buf%d getpixels %lu PLANE_RED",numbuf, ptr_r);
         Tcl_Eval(interp,s);

         // je recupere les pixels du plan GREEN
         sprintf(s,"buf%d getpixels %lu PLANE_GREEN",numbuf, ptr_g);
         Tcl_Eval(interp,s);

         // je recupere les pixels du plan BLUE
         sprintf(s,"buf%d getpixels %lu PLANE_BLUE",numbuf, ptr_b);
         Tcl_Eval(interp,s);

         /* --- conversion CMY en RGB ---*/
  		   ptr_c=ptr_r;
         ptr_m=ptr_b;
         ptr_y=ptr_g;
         for (j=0;j<naxis2-1;j++) {
            for (i=0;i<naxis1-1;i++) {
               val1=ptr_c[j*naxis1+i];
               val2=ptr_m[j*naxis1+i];
               val3=ptr_y[j*naxis1+i];
               ptr_r[j*naxis1+i]=(val2+val3)/2;
               ptr_g[j*naxis1+i]=(val3+val1)/2;
               ptr_b[j*naxis1+i]=(val1+val2)/2;
            }
         }
      }

      /* --- desaloue la dynamic string. --- */
      Tcl_DStringFree(&dsptr);
   }

   // je copie les pixels RED dans le buffer numbufr
   sprintf(lignetcl,"buf%d setpixels CLASS_GRAY %d %d  FORMAT_FLOAT COMPRESS_NONE %lu",
      numbufr ,naxis1, naxis2, ptr_r);
   Tcl_Eval(interp,lignetcl);

   // je copie les pixels GREEN dans le buffer numbufg
   sprintf(lignetcl,"buf%d setpixels CLASS_GRAY %d %d  FORMAT_FLOAT COMPRESS_NONE %lu",
      numbufg ,naxis1, naxis2, ptr_g);
   Tcl_Eval(interp,lignetcl);

   // je copie les pixels BLUE dans le buffer numbufb
   sprintf(lignetcl,"buf%d setpixels CLASS_GRAY %d %d FORMAT_FLOAT COMPRESS_NONE %lu",
      numbufb ,naxis1, naxis2, ptr_b);
   Tcl_Eval(interp,lignetcl);


   free(ptr_r);
   free(ptr_g);
   free(ptr_b);

   return TCL_OK;
}

int Cmd_rgbtcl_txt2buf(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* transforme une liste ASCII de position et magnitudes RGB d'etoiles       */
/* en trois images dans les buffers RGB                                     */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[100];
   char lignetcl[2000],texte[2000];
   char extension[1024];
   char **argvv=NULL;
   int k,argcc,code,numbufr=1001,numbufg=1002,numbufb=1003,nbimages=0;
   FILE *fichier;
   double xmini=0.,xmaxi=0.,ymini=0.,ymaxi=0.;
   double rmini=0.,rmaxi=0.,gmini=0.,gmaxi=0.,bmini=0.,bmaxi=0.;
   double magb,magg,magr,x,y;
   double fluxb,fluxg,fluxr;
   double fwhm;
   int naxis1,naxis2;

   if(argc<3) {
      sprintf(s,"Usage: %s filename fwhm ?-buffer {Nobufr Nobufg Nobufb}?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      result = TCL_OK;
      nbimages=argc-1;
      if (nbimages>1) {nbimages=1;}
	  fwhm=fabs(atof(argv[2]));
	  if (fwhm==0) fwhm=1;
      /* --- decode les parametres d'option ---*/
      for (k=2;k<argc;k++) {
         if (strcmp(argv[k],"-buffer")==0) {
            if (k<4) {nbimages=1;}
            argvv=NULL;
            code=Tcl_SplitList(interp,argv[k+1],&argcc,&argvv);
            if (code==TCL_OK) {
               if (argcc!=3) {
                  Tcl_Free((char *) argvv);
                  strcpy(s,"Three elements required in parameter {Nobufr Nobufg Nobufb}");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_ERROR;
               } else {
                  numbufr=(int)atoi(argvv[0]);
                  numbufg=(int)atoi(argvv[1]);
                  numbufb=(int)atoi(argvv[2]);
                  Tcl_Free((char *) argvv);
               }
            } else {
               strcpy(s,"Decode problem");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
      }
   }
   /* - decode le fichier ASCII (x y r g b) -*/
   /* - on cherche ici les bornes -*/
   if ((fichier=fopen(argv[1],"rt")) == NULL) {
      sprintf(s,"ASCII file %s not found",argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   k=0;
   do {
      if (fgets(lignetcl,2000,fichier)!=NULL) {
         strcpy(texte,"");
		 sscanf(lignetcl,"%s",texte);
         if ((strcmp(texte,"")!=0)) {
            sscanf(lignetcl,"%lf %lf %lf %lf %lf",&x,&y,&magr,&magg,&magb);
         }
		 k=k+1;
		 if (k==1) {
            xmini=x,xmaxi=x,ymini=y,ymaxi=y;
            rmini=magr,rmaxi=magr,gmini=magg,gmaxi=magg,bmini=magb,bmaxi=magb;
         } else {
            if (x<xmini) xmini=x;
            if (x>xmaxi) xmaxi=x;
            if (y<ymini) ymini=y;
            if (y>ymaxi) ymaxi=y;
            if (magr<rmini) rmini=magr;
            if (magr>rmaxi) rmaxi=magr;
            if (magg<gmini) gmini=magg;
            if (magg>gmaxi) gmaxi=magg;
            if (magb<bmini) bmini=magb;
            if (magb>bmaxi) bmaxi=magb;
         }
      }
   } while (feof(fichier)==0);
   fclose(fichier);
   naxis1=(int)ceil(xmaxi-xmini+2);
   naxis2=(int)ceil(ymaxi-ymini+2);
   /* --- verifie l'existence des buffers ---*/
   sprintf(s,"lsearch [::buf::list] %d",numbufr);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"::buf::create %d",numbufr);
      Tcl_Eval(interp,s);
   }
   //   sprintf(lignetcl,"buf%d format {%d %d}\n",numbufr,naxis1,naxis2);
   //   Tcl_Eval(interp,lignetcl);
   sprintf(lignetcl,"buf%d setkwd {\"RGBFILTR\" \"R\" string \"Color extracted (Red)\" \"\"}\n",numbufr);
   Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS\" 2 int \"number of data axes\" \"\"}\n",numbufr);
   //Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS1\" %d int \"length of data axis 1\" \"\"}\n",numbufr,naxis1);
   //Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS2\" %d int \"length of data axis 2\" \"\"}\n",numbufr,naxis2);
   //Tcl_Eval(interp,lignetcl);
   sprintf(s,"lsearch [::buf::list] %d",numbufg);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"::buf::create %d",numbufg);
      Tcl_Eval(interp,s);
   }
   //   sprintf(lignetcl,"buf%d format {%d %d}\n",numbufg,naxis1,naxis2);
   //   Tcl_Eval(interp,lignetcl);
   sprintf(lignetcl,"buf%d setkwd {\"RGBFILTR\" \"G\" string \"Color extracted (Green)\" \"\"}\n",numbufg);
   Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS\" 2 int \"number of data axes\" \"\"}\n",numbufg);
   //Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS1\" %d int \"length of data axis 1\" \"\"}\n",numbufg,naxis1);
   //Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS2\" %d int \"length of data axis 2\" \"\"}\n",numbufg,naxis2);
   //Tcl_Eval(interp,lignetcl);
   sprintf(s,"lsearch [::buf::list] %d",numbufb);
   Tcl_Eval(interp,s);
   if (strcmp(Tcl_GetStringResult(interp),"-1")==0) {
      sprintf(s,"::buf::create %d",numbufb);
      Tcl_Eval(interp,s);
   }
   //   sprintf(lignetcl,"buf%d format {%d %d}\n",numbufb,naxis1,naxis2);
   //   Tcl_Eval(interp,lignetcl);
   sprintf(lignetcl,"buf%d setkwd {\"RGBFILTR\" \"B\" string \"Color extracted (Blue)\" \"\"}\n",numbufb);
   Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS\" 2 int \"number of data axes\" \"\"}\n",numbufb);
   //Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS1\" %d int \"length of data axis 1\" \"\"}\n",numbufb,naxis1);
   //Tcl_Eval(interp,lignetcl);
   //sprintf(lignetcl,"buf%d setkwd {\"NAXIS2\" %d int \"length of data axis 2\" \"\"}\n",numbufb,naxis2);
   //Tcl_Eval(interp,lignetcl);
   sprintf(lignetcl,"buf%d extension",numbufr);
   Tcl_Eval(interp,lignetcl);
   strcpy(extension,Tcl_GetStringResult(interp));
   /* - decode le fichier ASCII (x y r g b) -*/
   /* - on calcule ici les etoiles -*/
   if ((fichier=fopen(argv[1],"rt")) == NULL) {
      sprintf(s,"ASCII file %s not found",argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   k=0;
   do {
      if (fgets(lignetcl,2000,fichier)!=NULL) {
         strcpy(texte,"");
		 sscanf(lignetcl,"%s",texte);
         if ((strcmp(texte,"")!=0)) {
            sscanf(lignetcl,"%lf %lf %lf %lf %lf",&x,&y,&magr,&magg,&magb);
   		    k=k+1;
		    x=x-xmini+1;
		    y=y-ymini+1;
		    fluxr=0.;
		    fluxg=0.;
		    fluxb=0.;
            if (magr!=0.) fluxr=pow(10,(rmaxi-magr)/2.5);
            if (magg!=0.) fluxg=pow(10,(gmaxi-magg)/2.5);
            if (magb!=0.) fluxb=pow(10,(bmaxi-magb)/2.5);
		    sprintf(lignetcl,"buf%d synthegauss {%f %f %f %f %f}\n",numbufr,x,y,fluxr,fwhm,fwhm);
            Tcl_Eval(interp,lignetcl);
		    sprintf(lignetcl,"buf%d synthegauss {%f %f %f %f %f}\n",numbufg,x,y,fluxg,fwhm,fwhm);
            Tcl_Eval(interp,lignetcl);
		    sprintf(lignetcl,"buf%d synthegauss {%f %f %f %f %f}\n",numbufb,x,y,fluxb,fwhm,fwhm);
            Tcl_Eval(interp,lignetcl);
         }
      }
   } while (feof(fichier)==0);
   fclose(fichier);
   return TCL_OK;
}

int Cmd_rgbtcl_bugbias(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Ajoute le mot cle END a la fin de l'entete FITS d'images mal ecrites     */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[100];
   char ligne[2000],filename_in[1024],filename_out[1024];
   FILE *f_in,*f_out;
   int sortie,n;
   unsigned char c;

   if(argc<3) {
      sprintf(s,"Usage: %s filename_in filename_out", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      strcpy(filename_in,argv[1]);
      strcpy(filename_out,argv[2]);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wb");
      if (f_out==NULL) {
         sprintf(s,"filename_out %s cannot be created",filename_out);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      result = TCL_OK;
      sortie=0;
      while (sortie==0) {
         n=fread(ligne,sizeof(char),80,f_in);
         if (n<80) {
            break;
         }
         if (ligne[0]==' ') {
            ligne[0]='E';
            ligne[1]='N';
            ligne[2]='D';
            sortie=1;
         }
         fwrite(ligne,sizeof(char),80,f_out);
      }
      sortie=0;
      while (sortie==0) {
         n=fread(&c,sizeof(unsigned char),1,f_in);
         if (n<1) {
            break;
         }
         fwrite(&c,sizeof(unsigned char),1,f_out);
      }
      fclose(f_in);
      fclose(f_out);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_rgbtcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le jour julien a partir des la date en clair.                   */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   double y=0.,m=0.,d=0.,hh=0.,mm=0.,ss=0.,jd=0.;

   if(argc<4) {
      sprintf(s,"Usage: %s year month day ?hour min sec?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les parametres obligatoires ---*/
      retour = Tcl_GetDouble(interp,argv[1],&y);
      if(retour!=TCL_OK) return retour;
      retour = Tcl_GetDouble(interp,argv[2],&m);
      if(retour!=TCL_OK) return retour;
      retour = Tcl_GetDouble(interp,argv[3],&d);
      if(retour!=TCL_OK) return retour;
      /* --- decode les parametres facultatifs ---*/
      if (argc>=5) {
         retour = Tcl_GetDouble(interp,argv[4],&hh);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=6) {
         retour = Tcl_GetDouble(interp,argv[5],&mm);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=7) {
         retour = Tcl_GetDouble(interp,argv[6],&ss);
         if(retour!=TCL_OK) return retour;
      }
      /* --- le type DString (dynamic string) est une fonction de */
      /* --- l'interpreteur Tcl. Elle est tres utile pour remplir */
      /* --- une chaine de caracteres dont on ne connait pas longueur */
      /* --- a l'avance. On s'en sert ici pour stocker le resultat */
      /* --- qui sera retourne. */
      Tcl_DStringInit(&dsptr);
      /* --- calcule le jour julien ---*/
      rgb_date2jd(y,m,d,hh,mm,ss,&jd);
      /* --- met en forme le resultat dans une chaine de caracteres ---*/
      sprintf(s,"%f",jd);
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
      /* --- retourne le code de succes a l'interpreteur Tcl */
      result = TCL_OK;
   }
   return result;
}

int Cmd_rgbtcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   rgb_image image;
   int numbuf;

   if(argc<2) {
      sprintf(s,"Usage: %s numbuf", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result = TCL_OK;
      /* --- decode le parametre obligatoire ---*/
      retour = Tcl_GetInt(interp,argv[1],&numbuf);
      if(retour!=TCL_OK) return retour;
      /*--- initialise la dynamic string ---*/
      Tcl_DStringInit(&dsptr);
      /* --- recherche les infos ---*/
      result=rgbtcl_getinfoimage(interp,numbuf,&image);
      /* --- met en forme le resultat dans une chaine de caracteres ---*/
      sprintf(s,"%p %d %d %s",image.ptr_audela,image.naxis1,image.naxis2,image.dateobs);
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
   }
   return result;
}

int rgbtcl_getinfoimage(Tcl_Interp *interp,int numbuf, rgb_image *image)
/****************************************************************************/
/* Retourne les infos d'une image presente dans le buffer numero numbuf     */
/* de AudeLA                                                                */
/****************************************************************************/
/* Note : ce type de fonction utilitaire est indispensable dans une         */
/* extension pour AudeLA.                                                   */
/****************************************************************************/
{
   char keyname[10],s[50],lignetcl[50],value_char[100];
   //int ptr;
   int datatype;
   int result;

   strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");
   image->naxis1=0;
   image->naxis2=0;
   strcpy(image->dateobs,"");
   /* -- recherche l'adresse du pointeur de l'image --*/
   /*
   sprintf(s,"buf%d pointer",numbuf);
   Tcl_Eval(interp,s);
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptr);
   image->ptr_audela=(float*)ptr;
   if (image->ptr_audela==NULL) {
      return(TCL_OK);
   }
   */

   sprintf(s,"buf%d imageready", numbuf);
   Tcl_Eval(interp,s);
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&result);
   if( result == 0 ) {
      return(TCL_OK);
   }


   /* -- recherche le mot cle NAXIS1 dans l'entete FITS --*/
   strcpy(keyname,"NAXIS1");
   sprintf(s,lignetcl,numbuf,keyname);
   Tcl_Eval(interp,s);
   strcpy(value_char,Tcl_GetStringResult(interp));
   if (strcmp(value_char,"")==0) {
      datatype=0;
   } else {
      datatype=1;
   }
   if (datatype==0) {
      image->naxis1=0;
   } else {
      image->naxis1=atoi(value_char);
   }
   /* -- recherche le mot cle NAXIS2 dans l'entete FITS --*/
   strcpy(keyname,"NAXIS2");
   sprintf(s,lignetcl,numbuf,keyname);
   Tcl_Eval(interp,s);
   strcpy(value_char,Tcl_GetStringResult(interp));
   if (strcmp(value_char,"")==0) {
      datatype=0;
   } else {
      datatype=1;
   }
   if (datatype==0) {
      image->naxis2=0;
   } else {
      image->naxis2=atoi(value_char);
   }
   /* -- recherche le mot cle DATE-OBS dans l'entete FITS --*/
   strcpy(keyname,"DATE-OBS");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      strcpy(image->dateobs,"");
   } else {
      strcpy(image->dateobs,value_char);
   }
   return(TCL_OK);
}

