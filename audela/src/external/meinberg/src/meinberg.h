/* meinberg.h
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
/* - les includes communs a tous les fichiers xx_*.c                       */
/* - le include de la definition de l'operating system                     */
/* - les prototype des fonctions C pures (sans Tcl) de la librairie.       */
/***************************************************************************/

#ifndef __MEINBERGH__
#define __MEINBERGH__

/***************************************************************************/
/**        includes valides pour tous les fichiers de type xx_*.c         **/
/***************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/**             include qui permet de connaitre l'OS utilise              **/
/***************************************************************************/

#include "sysexp.h"

/***************************************************************************/
/**                  defines qui dependent de l'OS utilise                **/
/***************************************************************************/

#if defined(OS_WIN_VCPP_DLL)
#define FILE_DOS
#define LIBRARY_DLL
#endif

#if defined(OS_LINUX_GCC_SO)
#define FILE_UNIX
#define LIBRARY_SO
#endif

/***************************************************************************/
/***************************************************************************/
/**                DEFINITON DES STRUCTURES DE DONNEES                    **/
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/

#endif

