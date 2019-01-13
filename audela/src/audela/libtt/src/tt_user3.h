/* tt_user3.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Delphine VALLOT <delphine.vallot@free.fr>
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

#ifndef __TT_USER3_H__
#define __TT_USER3_H__

/* --- autorized between 3001 and 3999 ---*/
#define TT_IMASERIES_USER3_ROT 3000
#define TT_IMASERIES_USER3_BINX 3001
#define TT_IMASERIES_USER3_BINY 3002
#define TT_IMASERIES_USER3_PROFILE 3003
#define TT_IMASERIES_USER3_MATRIX 3004
#define TT_IMASERIES_USER3_WINDOW 3005
#define TT_IMASERIES_USER3_LOG 3006
#define TT_IMASERIES_USER3_MEDIANX 3007
#define TT_IMASERIES_USER3_MEDIANY 3008
#define TT_IMASERIES_USER3_REC2POL 3009
#define TT_IMASERIES_USER3_POL2REC 3010

#define TT_ERR_WRONG_VALUE -50


///* --- Ajout de parametres pour la classe ima/series --- */
//typedef struct {
//   double x0;
//   double y0;
//   double angle;
//   int x1;
//   int x2;
//   int width;
//   int y1;
//   int y2;
//   int height;
//   /*char* direction;*/
//   char direction[2];
//   int offset;
//   /*char* filename;*/
//   char filename[11];
//   /*char* filematrix;*/
//   char filematrix[11];
//   double offsetlog;
//   double coeff;
//   double scale_theta;
//   double scale_rho;
//} TT_USER3_IMA_SERIES;
//
///* --- Ajout de parametres pour la classe ima/stack --- */
//typedef struct {
//   double param1;
//} TT_USER3_IMA_STACK;

#endif
