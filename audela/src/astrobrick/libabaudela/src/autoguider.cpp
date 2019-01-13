/* autoguider.cpp
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

#include <cstring>
#include <abcommon.h>
using namespace abcommon;
//#include <pthread.h>
#include "autoguider.h"


// local functions
void* executeGuideThread(void * clientData );

CAutoguider::CAutoguider()
{
}


CAutoguider::~CAutoguider()
{
}


/**
 *  guide
 *  lance une session guidage
 *
 *  @param exptime 
 *  @param detection 
 *  @param originCoord 
 *  @param targetCoord 
 *  @param angle 
 *  @param targetBoxSize 
 *  @param mountEnabled 
 *  @param alphaSpeed 
 *  @param deltaSpeed 
 *  @param alphaReverse 
 *  @param deltaReverse 
 *  @param seuilx 
 *  @param seuily 
 *  @param slitWidth 
 *  @param slitRatio 
 *  @param intervalle 
 *  @param declinaisonEnabled 

 *  @return none 
 */
//void CAutoguider::guideStart(int camNo, double exptime, AutoguiderDetectionType detection,
//   double originX, double originY, double targetX, double targetY, double angle,
//   double targetBoxSize,
//   int telNo, bool mountEnabled, double alphaSpeed, double deltaSpeed, bool alphaReverse, bool deltaReverse, bool declinaisonEnabled,
//   double seuilX, double seuilY,
//   double slitWidth, double slitRatio,
//   double intervalle,
//   AutoguiderCallbackType guideCallback)
void CAutoguider::guideStart(int camNo, double , AutoguiderDetectionType ,
                        double , double , double , double , double ,
                        double , 
                        int , bool , double , double , bool , bool , bool ,
                        double , double , 
                        double , double , 
                        double , 
                        AutoguiderCallbackType guideCallback)
{

   CAutoguider* autoguider = new CAutoguider();
   autoguider->guideCallback = guideCallback;

   autoguider->camera = abaudela::ICamera::getInstance(camNo);
   if( autoguider->camera == NULL ) {
      throw CError( CError::ErrorInput, "NO CAMERA with camNo=%d", camNo);
   }

   // je cree le thread
   //pthread_t autoguiderThread;
   //pthread_create(&autoguiderThread, NULL, executeGuideThread, (void *)autoguider);

}

void CAutoguider::guideStop() {

}



/**
 * executeGuideThread
 * lecture du CCD dans un thread dedié
 */
void* executeGuideThread(void * clientData )
{
   CAutoguider* autoguider = (CAutoguider* ) clientData;   

   const char* message = "tout ok";
   AutoguiderCallbackData autoguiderCallbackData; 
   autoguiderCallbackData.code = 1;
   autoguiderCallbackData.message = message;
   
   autoguider->guideCallback( &autoguiderCallbackData);

   //pthread_exit(NULL);
   return NULL;
}
