/* cvisu.h
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

#ifndef __CVISUH__
#define __CVISUH__

#include <tcl.h>
#include "palette.h"

#ifndef min
#define min(a, b)  (((a) <= (b)) ? (a) : (b))
#endif
#ifndef max
#define max(a, b)  (((a) >= (b)) ? (a) : (b))
#endif
//------------------------------------------------------------------------------
// Classe representant l'objet visualisation de lien entre un buffer et une
// Tk_Image. Descend de CVisu pour pouvoir etre chaine et manage par une
// CVisuPool.
//
class CVisu {

      protected:
   Tcl_Interp *interp;
   char *palette_dir;

   Lut_Cut locutRed;  //or locut for grey image
   Lut_Cut hicutRed;  //or hicut for grey image
   Lut_Cut locutGreen;
   Lut_Cut hicutGreen;
   Lut_Cut locutBlue;
   Lut_Cut hicutBlue;
   int thickness_1d ; // epaisseur de l'affichage d'une image 1D
   int mode ;


      public:
   int x1, y1, x2, y2;
   int full;
   int sh, sb;
   int bufnum;
   int imgnum;
   int box_set;
   double zoom;
   int mirrorX;
   int mirrorY;

   Pal_Struct pal;

   // pool
   CVisu *next;
   CVisu *prev;
   int no;
   

   CVisu(Tcl_Interp *Interp, int buf, int img);
   ~CVisu();
   int SetWindow(int xx1, int yy1, int xx2, int yy2);
   void SetWindowFull();
   int IsFull();
   int GetMirrorX();
   int GetMirrorY();

   int ClearImage();
   int CreateBuffer(int num);
   int CreateImage(int num);
   int CreatePaletteFromFile(const char *filename);
   int CreatePalette(Pal_Type t);
   Lut_Cut GetGrayHicut();
   Lut_Cut GetGrayLocut();
   int GetMode();
   char* GetPaletteDir();
   int GetThickness();
   int GetWindow(int *xx1, int *yy1, int *xx2, int *yy2);
   void GetRgbCuts(Lut_Cut *hcRed, Lut_Cut *lcRed, Lut_Cut *hcGreen, Lut_Cut *lcGreen, Lut_Cut *hcBlue, Lut_Cut *lcBlue);
   void GetZoom(double *zoom);

   void SetGrayCuts(Lut_Cut hc, Lut_Cut lc);
   void SetRgbCuts(Lut_Cut hcRed, Lut_Cut lcRed, Lut_Cut hcGreen, Lut_Cut lcGreen, Lut_Cut hcBlue, Lut_Cut lcBlue);
   double SetZoom(double z);
   void SetPaletteDir(const char *dir);
   void SetMirrorX( int val);
   void SetMirrorY( int val);
   void SetMode(int mode);
   void SetThickness(int val);
   int UpdateDisplay();
};

#endif


