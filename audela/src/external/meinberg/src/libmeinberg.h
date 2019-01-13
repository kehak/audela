/* libmeinberg.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille Laas-Bourez <Myrtille.Laas@oca.eu> 
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
/* Ce fichier d'inclusion contient                                         */
/* - l'interfacage avec Tcl/Tk et initialise                               */
/* - l'initialisation la librairie                                         */
/* - les fonctions d'interfacage entre Tcl et le C                         */
/***************************************************************************/

#ifndef __LIBMEINBERGH__
#define __LIBMEINBERGH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libxx.c     */
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#include "meinberg.h"

#include <mbgdevio.h>
#include <mbgtime.h>
#include <pcpslstr.h>
#include <pcpsutil.h>
//#include <toolutil.h>
#include <pcpsmktm.h>



#if defined(LIBRARY_SO)
#include <tcl.h>
#endif

/*--- Point d'entree de la librairie */
#if defined(LIBRARY_SO)
   extern int Meinberg_Init(Tcl_Interp *interp);
#endif

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers meinbergtcl_*.c */
/***************************************************************************/
/***************************************************************************/	

#include "meinbergtcl.h"

#endif
