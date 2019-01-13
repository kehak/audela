/* rgb_1.c
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
/* Le include rgb.h ne contient pas d'infos concernant Tcl.                */
/***************************************************************************/
#include "rgb.h"

void rgb_date2jd(double annee, double mois, double jour, double heure, double minute, double seconde, double *jj)
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

/*

int CVisu::UpdateDisplay()
{
   Tk_PhotoHandle ph;
   Tk_PhotoImageBlock pib;
   CBuffer *buffer;
   TYPE_PIXELS *pix, *ppix;
//   int width, height;
   int i, j;
   unsigned char *ptr, *pptr;
   char *ligne;
   int m, n;
   int toto;
   int ww, wh;              // window width, height multiplied by zoom
   int xx1, yy1, xx2, yy2;  // window coordinates
   int orgw, orgh;          // picture width, height
   int orgww, orgwh;        // original window width, height
   buffer = (CBuffer*)buf_pool->Chercher(bufnum);

   if(buffer==NULL) {
      return ELIBSTD_NO_ASSOCIATED_BUFFER;
   }

   pix = buffer->pix;
   if(pix==NULL) {
      return ELIBSTD_BUF_EMPTY;
   }

   orgw = buffer->GetW();
   if(orgw<0) {
      return orgw;
   }

   orgh = buffer->GetH();
   if(orgh<0) {
      return orgh;
   }

   if(full==1) {
      xx1 = 0;
      yy1 = 0;
      xx2 = orgw - 1;
      yy2 = orgh - 1;
   } else {
      xx1 = x1-1;
      yy1 = y1-1;
      xx2 = x2-1;
      yy2 = y2-1;
   }

   orgww = xx2 - xx1 + 1; // Largeur de la fenetre au depart
   orgwh = yy2 - yy1 + 1; // Hauteur ...
   ww = zoom * orgww;     // Largeur de la fenetre a l'arrivee, en pixels unitaires
   wh = zoom * orgwh;     // Hauteur ...

// MessageBox(NULL,"a","a",MB_OK);

   pptr = ptr = (unsigned char*)calloc(ww*wh*3,1);
   if(ptr==NULL) {
      return ELIBSTD_NO_MEMORY_FOR_DISPLAY;
   }

// MessageBox(NULL,"b","b",MB_OK);

   float val;
   float dyn;
   float fpix;
   float fsh = (float)lut.hicut;
   float fsb = (float)lut.locut;
   unsigned char ucval;

// Spécifique log
//   float a,b;
//   b = fsb - 1.;
//   a = 255. / log10(fsh-b);

   if(fsh==fsb) {
      dyn = -1e10;
   } else {
      dyn = 256. / (fsh - fsb);
   }

//   char machaine[256];
//   sprintf(machaine,"fsh=%f\nfsb=%f\ndyn=%f",fsh,fsb,dyn);
//   MessageBox(NULL,machaine,"Affichage",MB_OK);
   
   if(zoom==1) {
      ppix = pix + orgw * yy2 + xx1;
      for(j=yy1;j<=yy2;j++) {
         for(i=xx1;i<=xx2;i++) {
            fpix = *ppix++;
            val = (fpix-fsb)*dyn;
            ucval = min(max(val,0),255);
            *pptr++ = (pal.pal)[0][ucval];
            *pptr++ = (pal.pal)[1][ucval];
            *pptr++ = (pal.pal)[2][ucval];
         }
         ppix -= (orgw+ww);
      }
   } else {
      ppix = pix + orgw * yy2 + xx1;
      for(j=yy1;j<=yy2;j++) {
         for(n=0;n<zoom;n++) {
            for(i=xx1;i<=xx2;i++) {
               fpix = *ppix++;
               val = (fpix-fsb)*dyn;
               ucval = min(max(val,0),255);
               for(m=0;m<zoom;m++) {
                  *pptr++ = (pal.pal)[0][ucval];
                  *pptr++ = (pal.pal)[1][ucval];
                  *pptr++ = (pal.pal)[2][ucval];
               }
            }
            ppix -= orgww;
         }
         ppix -= orgw;
      }
   }

   // Preparation de la structure a passer a TCL/TK pour afficher l'image.
   pib.pixelPtr = ptr;
   pib.width = ww;
   pib.height = wh;
   pib.pitch = ww*3;
   pib.pixelSize = 3;
   pib.offset[0] = 0;
   pib.offset[1] = 1;
   pib.offset[2] = 2;

   // Bricolage pour mettre a jour la variable global picture
   // pour reperer la taille de l'image affichee.

   // Affichage de l'image dans 'image$imgnum'.
   ligne = new char[32];
   sprintf(ligne,"imagevisu%d",imgnum);
   ph = tk->FindPhoto(interp,ligne);
   delete ligne;

   if(ph==NULL) {
      free(ptr);
      return ELIBSTD_NO_TKPHOTO_HANDLE;
   }

   tk->PhotoPutBlock(ph,&pib,0,0,ww,wh);

   free(ptr);
   return 0;
}

*/

