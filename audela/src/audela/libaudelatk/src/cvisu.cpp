/* cvisu.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#include <math.h>
#include <tk.h>
#include <string.h>
#include <stdlib.h>

#include "cvisu.h"
#include "libaudela.h"


CVisu::CVisu(Tcl_Interp *Interp, int buf, int img)
{
   interp = Interp;

   next = prev = NULL;
   no = 0;

   x1 = y1 = x2 = y2 = 0;
   full = 1;
   box_set = 0;
   mirrorX = 0;
   mirrorY = 0;
   zoom = 1.;
   locutRed = (Lut_Cut)0;
   hicutRed = (Lut_Cut)32767;
   locutGreen = (Lut_Cut)0;
   hicutGreen = (Lut_Cut)32767;
   locutBlue = (Lut_Cut)0;
   hicutBlue = (Lut_Cut)32767;
   palette_dir = NULL;
   thickness_1d = 20;
   mode = 1;

   // Initialisation eventuelle de la Tk_Image
   CreateImage(img);

   // Initialisation eventuelle du buffer
   CreateBuffer(buf);

   // Initialisation Palette
   pal.typ = Pal_None;
   pal.filename = NULL;
   (pal.pal)[0] = NULL;
   (pal.pal)[1] = NULL;
   (pal.pal)[2] = NULL;
   CreatePalette(Pal_Grey);

}


CVisu::~CVisu()
{
    for ( int i =0; i < 3; i++ )
        delete[] pal.pal[i];
}

int CVisu::ClearImage()
{
   Tk_PhotoHandle ph;
   char *ligne;

   ligne = new char[40];
   if ( mode == 1 ) {
      sprintf(ligne,"imagevisu%d",imgnum);
      ph = Tk_FindPhoto(interp,ligne);
      if(ph!=NULL) {
         sprintf(ligne,"image delete imagevisu%d",imgnum);
         Tcl_Eval(interp,ligne);
         sprintf(ligne,"image create photo imagevisu%d",imgnum);
         Tcl_Eval(interp,ligne);
         sprintf(ligne,"imagevisu%d",imgnum);
         ph = Tk_FindPhoto(interp,ligne);
         if(ph==NULL) {
            delete ligne;
            return 1;
         }
      }
   }

   delete[] ligne;
   return 0;
}

int CVisu::CreateBuffer(int num)
{
   char *ligne;


   if(ILibaudela::findBuffer(num)==NULL) {
      ligne = new char[256];
      sprintf(ligne,"::buf::create %d",num);
      Tcl_Eval(interp,ligne);
      delete[] ligne;
      if(ILibaudela::findBuffer(num)==NULL) {
         return ELIBSTD_CANNOT_CREATE_BUFFER;
      }
      // Creer ici le buffer.
   }
   bufnum = num;
   return 0;
}

int CVisu::CreateImage(int num)
{
   Tk_PhotoHandle ph;
   char *ligne;

   ligne = new char[40];
   sprintf(ligne,"imagevisu%d",num);
   ph = Tk_FindPhoto(interp,ligne);
   if(ph==NULL) {
      sprintf(ligne,"image create photo imagevisu%d",num);
      Tcl_Eval(interp,ligne);
      sprintf(ligne,"imagevisu%d",num);
      ph = Tk_FindPhoto(interp,ligne);
      if(ph==NULL) {
         delete ligne;
         return ELIBSTD_CANT_GETORCREATE_TKIMAGE;
      }
   }
   imgnum = num;

   delete[] ligne;
   return 0;
}


int CVisu::CreatePaletteFromFile(const char *filename)
{
   FILE *paletteFile = NULL;
   Pal_Element *palette[3] = {NULL, NULL, NULL};
   char inputBuffer[256], *charIndex;
   int i;
   float red, green, blue;
   int nb = 0;
   int index = 0;
   char *path = NULL;
   int palette_dir_len;

   // Charge le fichier de palette et verifie s'il est correct.
   // Le fichier de palette est un fichier texte de 256 lignes,
   // chacune faite de 4 nombres : l'index dans la palette (0..255),
   // suivi de l'intensite du rouge, du vert, et du bleu. Chaque
   // valeur doit etre comprise entre 0 (noir) et 255 (saturation).
   // Des commentaires peuvent etre ajoutes, apres le signe # (comme en TCL),
   // Exemple:
   // # Ce fichier definit une palette inversee
   // 0   255 255 255
   // 1   254 254 254
   // ...
   // 255 0   0   0

   // si %palettename% est nom passe en parametre, les fichiers recherches
   // sont par ordre de priorite :
   // ./%palettename%.pal
   // palette_dir/%palettename%.pal
   // audela_start_dir/../%palettename%.pal
   palette_dir_len = palette_dir==NULL ? 0 : strlen(palette_dir);
   //audela_start_dir_len = audela_start_dir==NULL ? 0 : strlen(audela_start_dir);
   //path = (char*)calloc(audela_start_dir_len+palette_dir_len+strlen(filename)+10,1);
   path = (char*)calloc(palette_dir_len+strlen(filename)+10,1);

   //sprintf(path,"./%s.pal",filename);
   sprintf(path,"%s/%s.pal",palette_dir,filename);
   paletteFile = fopen(path,"rt");
   if(paletteFile==NULL) {
      //if(palette_dir!=NULL) {
      //   sprintf(path,"%s/%s.pal",palette_dir,filename);
      //   paletteFile = fopen(path,"rt");
      //}
      //if(paletteFile==NULL) {
      //   if(audela_start_dir!=NULL) {
      //      sprintf(path,"%s/../%s.pal",audela_start_dir,filename);
      //      paletteFile = fopen(path,"rt");
      //   }
      //   if(paletteFile==NULL) {
            free(path);
            return ELIBSTD_PALETTE_CANT_FIND_FILE;
      //   }
      //}
   }
   free(path);

   // Lecture du fichier palette
   for(i=0;i<3;i++) palette[i] = new Pal_Element[256];
   while(fgets(inputBuffer,256,paletteFile) != NULL) {
      if((charIndex = strchr(inputBuffer,'#'))!=NULL)
         *charIndex = 0;
      if((inputBuffer[0]!=0)&&(index!=256)) {
         nb = sscanf(inputBuffer, "%f %f %f", &red, &green, &blue);
         if(nb != 3) {
            for(i=0;i<3;i++) delete palette[i];
            fclose(paletteFile);
            return ELIBSTD_PALETTE_MALFORMED_FILE;
         }
         palette[0][index] = (Pal_Element)red;
         palette[1][index] = (Pal_Element)green;
         palette[2][index] = (Pal_Element)blue;
         index++;
      }
   }
   fclose(paletteFile);

   // Si OK, alors recopier la palette.
   if (index==256) {
      // Si la palette existe deja, elle est detruite
      if((pal.pal)[0]!=NULL) {
         for(i=0;i<3;i++) {
            delete[] (pal.pal)[i];
         }
      }
      if(pal.filename!=NULL) {
         delete[] pal.filename;
      }
      // Recopie de la palette
      pal.typ = Pal_File;
      pal.filename = new char[strlen(filename)+1];
      strcpy(pal.filename,filename);
      for(i=0;i<3;i++) {
         (pal.pal)[i] = palette[i];
      }
      // Mise a jour de l'image
      return UpdateDisplay();
   } else {
      for(i=0;i<3;i++) delete palette[i];
      return ELIBSTD_PALETTE_NOTCOMPLETE;
   }

   return 0;
}


int CVisu::CreatePalette(Pal_Type t)
{
   int i;

   if(t==pal.typ) return 0;

   if((pal.pal)[0]==NULL) {
      for(i=0;i<3;i++) {
         (pal.pal)[i] = new Pal_Element[256];
      }
   }

   switch(t) {
      case Pal_Red1 :
         pal.typ = Pal_Red1;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i);
            (pal.pal)[1][i] = (Pal_Element)(2*i/3);
            (pal.pal)[2][i] = (Pal_Element)(i/3);
         };
         break;
      case Pal_Red2 :
         pal.typ = Pal_Red2;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i);
            (pal.pal)[1][i] = (Pal_Element)(i/3);
            (pal.pal)[2][i] = (Pal_Element)(2*i/3);
         };
         break;
      case Pal_Green1 :
         pal.typ = Pal_Green1;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(2*i/3);
            (pal.pal)[1][i] = (Pal_Element)(i);
            (pal.pal)[2][i] = (Pal_Element)(i/3);
         };
         break;
      case Pal_Green2 :
         pal.typ = Pal_Green2;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i/3);
            (pal.pal)[1][i] = (Pal_Element)(i);
            (pal.pal)[2][i] = (Pal_Element)(2*i/3);
         };
         break;
      case Pal_Blue1 :
         pal.typ = Pal_Blue1;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(2*i/3);
            (pal.pal)[1][i] = (Pal_Element)(i/3);
            (pal.pal)[2][i] = (Pal_Element)(i);
         };
         break;
      case Pal_Blue2 :
         pal.typ = Pal_Blue2;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i/3);
            (pal.pal)[1][i] = (Pal_Element)(2*i/3);
            (pal.pal)[2][i] = (Pal_Element)(i);
         };
         break;
      case Pal_Grey:
      default:
         pal.typ = Pal_Grey;
         for(i=0;i<256;i++) {
            (pal.pal)[0][i] = (Pal_Element)(i);
            (pal.pal)[1][i] = (Pal_Element)(i);
            (pal.pal)[2][i] = (Pal_Element)(i);
         };
         break;
   };

   return UpdateDisplay();
}



char* CVisu::GetPaletteDir()
{
   return palette_dir;
}

int CVisu::GetMirrorX()
{
   return mirrorX;
}

int CVisu::GetMirrorY()
{
   return mirrorY;
}

/*
 *----------------------------------------------------------------------
 *
 * CVisu::GetMode
 *
 * retourne le mode d'affichage
 *
 * Results:
 *	 1 = mode photo
 *	 2 = mode video
 *
 *----------------------------------------------------------------------
 */
int CVisu::GetMode()
{
   return mode;
}

/*
 *----------------------------------------------------------------------
 *
 * CVisu::GetThickness
 *
 * retourne l'epaisseur d'affichage d'une image 1D
 *
 * Results:
 *	 epaisseur
 *
 *----------------------------------------------------------------------
 */
int CVisu::GetThickness()
{
   return thickness_1d;
}

void CVisu::GetZoom(double *z)
{
   *z = zoom;
}


int CVisu::IsFull()
{
   return full;
}


int CVisu::GetWindow(int *xx1, int *yy1, int *xx2, int *yy2)
{
   IBuffer *buffer;
   int naxis1, naxis2;

   if(full==1) {
      buffer = ILibaudela::findBuffer(bufnum);
      if(buffer==NULL) {
         return ELIBSTD_BUF_EMPTY;
      }
      naxis1 = buffer->getWidth();
      naxis2 = buffer->getHeight();

      *xx1 = 1;
      *yy1 = 1;
      *xx2 = naxis1;
      *yy2 = naxis2;
   } else {
      *xx1 = x1;
      *yy1 = y1;
      *xx2 = x2;
      *yy2 = y2;
   }

   return 0;
}


/**
 *  GetGrayHicut()
 *  returns  hight cut for gray image
 */
Lut_Cut CVisu::GetGrayHicut()
{
   return hicutRed;
}

/**
 *  GetGrayLocut()
 *  returns  low cut for gray image
 */
Lut_Cut CVisu::GetGrayLocut()
{
   return locutRed;
}

void CVisu::GetRgbCuts(Lut_Cut *hcRed, Lut_Cut *lcRed, Lut_Cut *hcGreen, Lut_Cut *lcGreen, Lut_Cut *hcBlue, Lut_Cut *lcBlue)
{
   *hcRed = hicutRed;
   *lcRed = locutRed;
   *hcGreen = hicutGreen;
   *lcGreen = locutGreen;
   *hcBlue = hicutBlue;
   *lcBlue = locutBlue;
}

void CVisu::SetGrayCuts(Lut_Cut hc, Lut_Cut lc)
{
   hicutRed = hc;
   locutRed = lc;
   hicutGreen = hc;
   locutGreen = lc;
   hicutBlue = hc;
   locutBlue = lc;
}

void CVisu::SetRgbCuts(Lut_Cut hcRed, Lut_Cut lcRed, Lut_Cut hcGreen, Lut_Cut lcGreen, Lut_Cut hcBlue, Lut_Cut lcBlue)
{
   hicutRed = hcRed;
   locutRed = lcRed;
   hicutGreen = hcGreen;
   locutGreen = lcGreen;
   hicutBlue = hcBlue;
   locutBlue = lcBlue;
}


void CVisu::SetMirrorX(int val)
{
   mirrorX = val;
}

void CVisu::SetMirrorY(int val)
{
   mirrorY = val;
}

/*
 *----------------------------------------------------------------------
 *
 * CVisu::SetMode
 *
 * fixe le mode d'affichage
 *	 1 = mode photo
 *	 2 = mode video
 *
 * Results:
 *	   none
 *
 *----------------------------------------------------------------------
 */
void CVisu::SetMode(int mode)
{
   char ligne[256];
   int result;


   switch(mode) {
   case 1 :
      // je cree une image "photo"
      sprintf(ligne,"image delete imagevisu%d",imgnum);
      result = Tcl_Eval(interp,ligne);
      if ( result == TCL_OK) {
         sprintf(ligne,"image create photo imagevisu%d",imgnum);
         result = Tcl_Eval(interp,ligne);
      }
      break;
   case 2 :
      // je cree une image video
      sprintf(ligne,"image delete imagevisu%d",imgnum);
      result = Tcl_Eval(interp,ligne);
      if ( result == TCL_OK) {
         sprintf(ligne,"image create video imagevisu%d",imgnum);
         result = Tcl_Eval(interp,ligne);
      }
      break;
   default:
      result = TCL_ERROR;

   }

   if ( result == TCL_OK) {
      // j'enregistre le mode
      this->mode = mode ;
   }
}

void CVisu::SetPaletteDir(const char *dir)
{
   if(palette_dir!=NULL) {
      free(palette_dir);
   }
   palette_dir = (char*)malloc(strlen(dir)+1);
   palette_dir[0] = 0;
   strcpy(palette_dir,dir);
}

void CVisu::SetThickness(int val)
{
   thickness_1d = val;
}

int CVisu::SetWindow(int xx1, int yy1, int xx2, int yy2)
{
   IBuffer *buffer;

   buffer = ILibaudela::findBuffer(bufnum);
   if(buffer==NULL) {
      return ELIBSTD_NO_ASSOCIATED_BUFFER;
   }

   //petite protection pour eviter les cas tordus
   if( full == 0) {
      return ELIBSTD_SUB_WINDOW_ALREADY_EXIST;
   }

      x1 = xx1;
      x2 = xx2;
      y1 = yy1;
      y2 = yy2;

   full = 0;

   return 0;

}

void CVisu::SetWindowFull()
{
   full = 1;
}


double CVisu::SetZoom(double z)
{
   if((z!=.125)&&(z!=.25)&&(z!=.5)&&(z!=2)&&(z!=3)&&(z!=4)&&(z!=8)) {
      z = 1.;
   }
   zoom=z;

   return zoom;
}


/*
 *----------------------------------------------------------------------
 *
 * CVisu::UpdateDisplay
 *
 * si mode=1 (photo)
 *   re-affiche l'image en appliquant les changements de
 *
 * si mode=2 (video)
 *   applique les changements  palette, zoom , miroir et fenetrage
 *   sans reafficher
 *
 * Results:
 *	   0 si OK,
 *
 *----------------------------------------------------------------------
 */
int CVisu::UpdateDisplay()
{
   Tk_PhotoHandle ph;
   Tk_PhotoImageBlock pib;
   IBuffer *buffer;
   unsigned char *ptr;
   char imageName[32];
   int xx1, yy1, xx2, yy2;  // window coordinates
   int orgw, orgh;          // picture width, height
   int orgww, orgwh;        // original window width, height
   float cuts[6];


   if ( mode == 2 ) {
      char ligne[256];
      // je change le zoom de la video
      sprintf(ligne,"imagevisu%d configure -zoom %f",imgnum, this->zoom);
      Tcl_Eval(interp,ligne);
      return 0;
   }

   buffer = ILibaudela::findBuffer(bufnum);
   if(buffer==NULL) {
      return ELIBSTD_NO_ASSOCIATED_BUFFER;
   }

   orgw = buffer->getWidth();
   orgh = buffer->getHeight();

   // calcul des bornes en fonction du fentrage
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

   // calcul de largeur et de la hauteur d'affichage
   if( buffer->getHeight()==1) {
      // une image 1D est etalee sur plusieurs lignes
      orgww = xx2 - xx1 + 1; // Largeur
      orgwh = thickness_1d;
   } else {
      // image 2D
      orgww = xx2 - xx1 + 1; // Largeur
      orgwh = yy2 - yy1 + 1; // Hauteur
   }

   if ( zoom * zoom * orgww * orgwh > 16777216 ) {
      // Tk_PhotoPutBlock ne supporte pas les tailles d'image > 16Mo
      return ELIBSTD_NO_MEMORY_FOR_DISPLAY;
   }

   ptr = (unsigned char*)malloc(orgww*orgwh*4);
   if(ptr==NULL) {
      return ELIBSTD_NO_MEMORY_FOR_DISPLAY;
   }

   // calcul des seuils
   cuts[0] = hicutRed;
   cuts[1] = locutRed;
   cuts[2] = hicutGreen;
   cuts[3] = locutGreen;
   cuts[4] = hicutBlue;
   cuts[5] = locutBlue;

   // je recuperer les pixels
   buffer->getPixelsVisu(xx1,yy1,xx2,yy2, mirrorX, mirrorY,
      cuts,
      pal.pal, ptr);

   // s'il n'y a qu'une ligne , je duplique la ligne "thickness" fois a l'affichae
   if( buffer->getHeight()==1 ) {
      unsigned char *ptr2;
      ptr2 = (unsigned char*)malloc(orgww*thickness_1d*4);
      if(ptr2==NULL) {
         free(ptr);
         return ELIBSTD_NO_MEMORY_FOR_DISPLAY;
      }
      for(int y=0 ; y < thickness_1d; y++) {
         memcpy(ptr2+y*orgww*4, ptr, orgww*4);
      }
      free(ptr);
      // ptr pointe sur le nouveau buffer contenant la ligne dupliquee
      ptr = ptr2;
   }

   // Preparation de la structure a passer a TCL/TK pour afficher l'image.
   pib.pixelPtr = ptr;
   pib.width = orgww;
   pib.height = orgwh;
   pib.pitch = orgww*4;
   pib.pixelSize = 4;
   pib.offset[0] = 0;
   pib.offset[1] = 1;
   pib.offset[2] = 2;
   pib.offset[3] = 0;

   // Affichage de l'image dans 'image$imgnum'.
   sprintf(imageName,"imagevisu%d",imgnum);
   ph = Tk_FindPhoto(interp,imageName);

   if(ph==NULL) {
      free(ptr);
      return ELIBSTD_NO_TKPHOTO_HANDLE;
   }

   // affichage de l'image
   // remarque : si orgww==0 et orgwh==0 , il faut utiliser Tk_PhotoPutBlock car Tk_PhotoPutZoomedBlock
   //            ne supporte pas une image de taille nulle (boucle interne infinie)
   if( zoom == 1 || (orgww==0 && orgwh==0)) {
      // USE_COMPOSITELESS_PHOTO_PUT_BLOCK
      //Tk_PhotoPutBlock(ph,&pib,0,0, orgww,orgwh);
      Tk_PhotoPutBlock(interp, ph,&pib,0,0, orgww,orgwh, TK_PHOTO_COMPOSITE_SET);
   } else if( zoom > 1) {
      Tk_PhotoPutZoomedBlock(interp, ph, &pib, 0, 0, (int) (orgww*zoom), (int) (orgwh*zoom), (int) zoom, (int) zoom, 1, 1, TK_PHOTO_COMPOSITE_SET);
   } else {
      Tk_PhotoPutZoomedBlock(interp, ph, &pib, 0, 0, (int) (orgww*zoom+1), (int) (orgwh*zoom+1), 1, 1, (int) (1./zoom), (int) (1./zoom), TK_PHOTO_COMPOSITE_SET);
   }


   if(ptr != NULL) {
      free(ptr);
   }
   return 0;
}

