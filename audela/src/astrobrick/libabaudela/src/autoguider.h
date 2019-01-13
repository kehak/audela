/* autoguider.h
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

#pragma once 

#include <abaudela.h>
using namespace ::abaudela;

class CAutoguider  {

public:
   CAutoguider();
   ~CAutoguider();
   static void guideStart(int camNo, double exptime, AutoguiderDetectionType detection, 
                     double originX, double originY, double targetX, double targetY, double angle,
                     double targetBoxSize, 
                     int telNo,bool mountEnabled, double alphaSpeed, double deltaSpeed, bool alphaReverse, bool deltaReverse, bool declinaisonEnabled,
                     double seuilX, double seuilY, 
                     double slitWidth, double slitRatio, 
                     double intervalle, 
                     AutoguiderCallbackType guideCallback );
   static void guideStop(); 

   AutoguiderCallbackType guideCallback;
   ICamera* camera;

protected:
   
   
};


