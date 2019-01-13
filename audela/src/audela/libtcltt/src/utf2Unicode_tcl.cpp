/* utf2Unicode_tcl.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL
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


#include "utf2Unicode_tcl.h"
#include "string.h"

void utf2Unicode(Tcl_Interp *interp, const char * inString, char * outString) {
   // je convertis les caracteres accentues
   int length;
   Tcl_DString sourceFileName;
   Tcl_DStringInit(&sourceFileName);
   char * stringPtr = (char *) Tcl_GetByteArrayFromObj(Tcl_NewStringObj(inString,strlen(inString)), &length);
   Tcl_ExternalToUtfDString(Tcl_GetEncoding(interp, "identity"), stringPtr, length, &sourceFileName);
   strcpy(outString, sourceFileName.string);
   Tcl_DStringFree(&sourceFileName);
}
