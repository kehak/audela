/* tt_user2.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Benjamin MAUCLAIRE <bmauclaire@underlands.org>
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
/* definitions perso du user2 visibles de tout libtt.                      */
/***************************************************************************/
#ifndef __TTUSER2H__
#define __TTUSER2H__

/* --- autorized between 2001 and 2999 ---*/
#define TT_IMASERIES_USER2_PROFILE2       2001
#define TT_IMASERIES_USER2_LOPT           2002
#define TT_IMASERIES_USER2_SMOOTHSG       2003
#define TT_IMASERIES_USER2_COLOR_SPECTRUM 2004
#define TT_IMASERIES_USER2_LOPT5          2005

/* --- autorized between 2001 and 2999 ---*/
#define TT_IMASTACK_USER2_TUTU 2001

///* --- Ajout de parametres pour la classe ima/series --- */
//typedef struct {
//   int y1;
//   int y2;
//   int height;
//   char direction[2];
//   char filename[11];
//   int nl;
//   int nr;
//   int ld;
//   int m;
//   double wavelengthmin;
//   double wavelengthmax;
//   int xmin;
//   int xmax;
//} TT_USER2_IMA_SERIES;
//
///* --- Ajout de parametres pour la classe ima/stack --- */
//typedef struct {
//   double param1;
//} TT_USER2_IMA_STACK;

#endif
