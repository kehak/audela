/* tt_user5.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <laas@obs-hp.fr>
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
/* definitions perso du user5 visibles de tout libtt.                      */
/***************************************************************************/
#ifndef __TTUSER5H__
#define __TTUSER5H__

typedef unsigned char uint8_t;
typedef double TYPE_PIXELS;


/* --- autorized between 5001 and 5999 ---*/
#define TT_IMASERIES_USER5_TRAINEE     5001
#define TT_IMASERIES_USER5_MORPHOMATH  5002
#define TT_IMASERIES_USER5_MASQUECATA  5003
#define TT_IMASERIES_USER5_GEOGTO	   5004
#define TT_IMASERIES_USER5_GTO		   5005
#define TT_IMASERIES_USER5_GEO		   5006
#define TT_IMASERIES_USER5_ROT		   5007

/* --- autorized between 5001 and 5999 ---*/
#define TT_IMASTACK_USER5_TUTU 5001

///* --- Ajout de parametres pour la classe ima/series --- */
//typedef struct {
//   double param1;
//   char filename[30];
//   double x0;
//   double y0;
//   double angle;
//} TT_USER5_IMA_SERIES;
//typedef double TYPE_PIXELS;
///* --- Ajout de parametres pour la classe ima/stack --- */
//typedef struct {
//   double param1;
//} TT_USER5_IMA_STACK;


#endif
