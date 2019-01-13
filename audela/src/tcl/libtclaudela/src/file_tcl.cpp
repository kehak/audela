/* file_tcl.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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

#include "sysexp.h"  //  pour definition de OS_* 
#include <stdlib.h>  //  pour _MAX_PATH
#include <string.h>
#include <tcl.h>

#include <abaudela.h>
using namespace abaudela;
#include "libtt.h"      // pour TFLOAT


#ifndef _MAX_PATH
#define _MAX_PATH 4096
#endif
//-------------------------------------------------------------------------
// CmdCfa2rgb --
// convertit un fichier CFA en fichier RGB.
//
// Usage : fits2colorjpg cfaFilename interpolation rgbFilename 
// Exemple :  cfa2rgb $::audace(rep_images)/b.crw 1 $::audace(rep_images)/b_rgb.fit
//-------------------------------------------------------------------------
int CmdCfa2rgb(ClientData , Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[_MAX_PATH+256];
   char cfaFileName[_MAX_PATH];
   char rgbFileName[_MAX_PATH];
   char interpolationMethod[256];
   int retour;
   int saving_type = USHORT_IMG;

   if ((argc!=4)) {
      sprintf(ligne,"Usage: %s cfaFilename interpolation rgbFilename",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {

      try {
         // Decodage du nom de fichier .CFA
         // "encoding convertfrom identity" sert a traiter coorectement les caracteres accentues
         sprintf(ligne,"encoding convertfrom identity {%s}",argv[1]); 
         Tcl_Eval(interp,ligne); 
         strcpy(cfaFileName,Tcl_GetStringResult(interp));

         strncpy(interpolationMethod, argv[2] , sizeof interpolationMethod);

         // Decodage du nom de fichier .CFA
         // "encoding convertfrom identity" sert a traiter correctement les caracteres accentues
         sprintf(ligne,"encoding convertfrom identity {%s}",argv[3]); 
         Tcl_Eval(interp,ligne); 
         strcpy(rgbFileName,Tcl_GetStringResult(interp));

         abaudela::ILibaudela::cfa2Rgb(cfaFileName, rgbFileName, 1);

         retour = TCL_OK;
         Tcl_ResetResult(interp);
      
      } catch(abcommon::IError& e) {
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }

   return retour;
}

