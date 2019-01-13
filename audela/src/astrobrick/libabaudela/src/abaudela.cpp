/* buf_tcl.cpp
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

#include <stdio.h>  	// pour NULL
#include <abaudela.h>
using namespace abaudela;
#include <abcommon.h>
#include "CBuffer.h"
#include "CCamera.h"
#include "CTelescope.h"
#include "CLink.h"
#include "cfile.h"
#include "autoguider.h"

//=============================================================================
// Buffer
//=============================================================================

int abaudela::IBuffer_getWidth(abaudela::IBuffer* buffer) {
   CATCH_ERROR( buffer->getWidth() , 0);
}

int abaudela::IBuffer_getHeight(abaudela::IBuffer* buffer) {
   CATCH_ERROR( buffer->getHeight(), 0 );
}
  

//=============================================================================
// IBufferPool
//=============================================================================

IBuffer*  abaudela::IBuffer_createInstance() {
   CATCH_ERROR( abaudela::IBuffer::createInstance() , NULL);
}

void abaudela::IBuffer_deleteInstance(IBuffer* buffer) {
   CATCH_ERROR_VOID(abaudela::IBuffer::deleteInstance(buffer) );
}

int abaudela::IBuffer_getInstanceNo(IBuffer* buffer) {
   CATCH_ERROR(abaudela::IBuffer::getInstanceNo(buffer) , 0 );
}

IBuffer* abaudela::IBuffer_getInstance(int bufferNo) {
   CATCH_ERROR(abaudela::IBuffer::getInstance(bufferNo) , NULL )
}

abcommon::IIntArray* abaudela::IBuffer_getIntanceNoList() {
   CATCH_ERROR(abaudela::IBuffer::getIntanceNoList() , NULL );
}

//=============================================================================
//  ICamera
//=============================================================================
abcommon::IStructArray*  abaudela::ICamera_getAvailableCamera(const char* librayPath, const char * libraryFileName) {
   CATCH_ERROR(ICamera::getAvailableCamera(librayPath, libraryFileName), NULL);
}

void abaudela::ICamera_acq(ICamera* camera) {
   CATCH_ERROR_VOID( camera->acq() ) ;
}

void abaudela::ICamera_getBinning(ICamera* camera, int* binx, int* biny) {
   CATCH_ERROR_VOID( camera->getBinning(binx, biny) );
}
void abaudela::ICamera_setBinning(ICamera* camera, int binx, int biny) {
   CATCH_ERROR_VOID( camera->setBinning(binx, biny) );
}

void abaudela::ICamera_setCallback(ICamera* camera, void *clientData, ICamera::CameraStatusCallbackType cameraCallback) {
   CATCH_ERROR_VOID( camera->setSatusCallback(clientData, cameraCallback) );
}

double abaudela::ICamera_getExptime(abaudela::ICamera* camera) {
   CATCH_ERROR( camera->getExptime() , 0); 
}

void abaudela::ICamera_setExptime(ICamera* camera, double exptime) {
   CATCH_ERROR_VOID(camera->setExptime(exptime) );
}

const char* abaudela::ICamera_getCameraName(ICamera* camera) {
   CATCH_ERROR( camera->getCameraName(), NULL ) ; 
}

//=============================================================================
// ICamera
//=============================================================================

ICamera*  abaudela::ICamera_createInstance(const char* librayPath, const char * libraryFileName, int argc, const char *argv[]) {
   CATCH_ERROR( abaudela::ICamera::createInstance(librayPath, libraryFileName, argc, argv) , NULL);
}

void abaudela::ICamera_deleteInstance(ICamera* camera) {
   CATCH_ERROR_VOID(abaudela::ICamera::deleteInstance(camera) );
}

int abaudela::ICamera_getInstanceNo(ICamera* camera) {
   CATCH_ERROR(abaudela::ICamera::getInstanceNo(camera) , 0 );
}

ICamera* abaudela::ICamera_getInstance(int cameraNo) {
   CATCH_ERROR(abaudela::ICamera::getInstance(cameraNo) , NULL )
}

abcommon::IIntArray* abaudela::ICamera_getIntanceNoList() {
   CATCH_ERROR(abaudela::ICamera::getIntanceNoList() , NULL );
}

//abcommon::IStructArray*  abaudela::ILibaudela::getAvailableCamera(const char* librayPath, const char * libraryFileName) {
//   return (abcommon::IStructArray*) CCamera::getAvailableCamera(librayPath, libraryFileName);
//}




//=============================================================================
//  ITelescope
//=============================================================================


//=============================================================================
// ITelescope Pool
//=============================================================================
ITelescope*  abaudela::ITelescope_createInstance(const char* librayPath, const char * libraryFileName, int argc, const char *argv[]) {
   CATCH_ERROR( abaudela::ITelescope::createInstance(librayPath, libraryFileName, argc, argv) , NULL);
}

void abaudela::ITelescope_deleteInstance(ITelescope* telescope) {
   CATCH_ERROR_VOID(abaudela::ITelescope::deleteInstance(telescope) );
}

int abaudela::ITelescope_getInstanceNo(ITelescope* telescope) {
   CATCH_ERROR(abaudela::ITelescope::getInstanceNo(telescope) , 0 );
}

ITelescope* abaudela::ITelescope_getInstance(int telescopeNo) {
   CATCH_ERROR(abaudela::ITelescope::getInstance(telescopeNo) , NULL )
}

abcommon::IIntArray* abaudela::ITelescope_getIntanceNoList() {
   CATCH_ERROR(abaudela::ITelescope::getIntanceNoList() , NULL );
}



//=============================================================================
// Link
//=============================================================================


//=============================================================================
// ILinkPool
//=============================================================================
ILink*  abaudela::ILink_createInstance(const char* librayPath, const char * libraryFileName, int argc, const char *argv[]) {
   CATCH_ERROR( abaudela::ILink::createInstance(librayPath, libraryFileName, argc, argv) , NULL);
}

void abaudela::ILink_deleteInstance(ILink* link) {
   CATCH_ERROR_VOID(abaudela::ILink::deleteInstance(link) );
}

int abaudela::ILink_getInstanceNo(ILink* link) {
   CATCH_ERROR(abaudela::ILink::getInstanceNo(link) , 0 );
}

ILink* abaudela::ILink_getInstance(int linkNo) {
   CATCH_ERROR(abaudela::ILink::getInstance(linkNo) , NULL )
}

abcommon::IIntArray* abaudela::ILink_getIntanceNoList() {
   CATCH_ERROR(abaudela::ILink::getIntanceNoList() , NULL );
}





//=============================================================================
// cfa2Rgb
//=============================================================================

// image file
void abaudela::abaudela_cfa2Rgb(char* cfaFileName, char* rgbFileName, int interpolationMethod) {
   CATCH_ERROR_VOID(ILibaudela::cfa2Rgb(cfaFileName, rgbFileName, interpolationMethod));
}

//=============================================================================
// file convert
//=============================================================================

// c++ prototype
void abaudela::ILibaudela::cfa2Rgb(char* cfaFileName, char* rgbFileName, int interpolationMethod) {
   CFile::cfa2Rgb(cfaFileName, rgbFileName, interpolationMethod);
}

//=============================================================================
// ILibaudela guide
//=============================================================================
void abaudela::ILibaudela::guideStart(int camNo, double exptime, AutoguiderDetectionType detection, 
                           double originX, double originY, double targetX, double targetY, double angle,
                           double targetBoxSize, 
                           int telNo, bool mountEnabled, double alphaSpeed, double deltaSpeed, bool alphaReverse, bool deltaReverse, bool declinaisonEnabled,
                           double seuilX, double seuilY, 
                           double slitWidth, double slitRatio, 
                           double intervalle, 
                           AutoguiderCallbackType guideCallback) {
   CAutoguider::guideStart( camNo, exptime,  detection, 
                         originX,  originY,  targetX,  targetY,  angle,
                         targetBoxSize, 
                         telNo, mountEnabled,  alphaSpeed,  deltaSpeed,  alphaReverse,  deltaReverse,  declinaisonEnabled,
                         seuilX,  seuilY, 
                         slitWidth,  slitRatio, 
                         intervalle,
                         guideCallback);
}

void abaudela::ILibaudela::guideStop() {
      CAutoguider::guideStop();
}




//autoguider
void abaudela::abaudela_guideStart(int camNo, double exptime, AutoguiderDetectionType detection, 
                           double originX, double originY, double targetX, double targetY, double angle,
                           double targetBoxSize, 
                           int telNo, bool mountEnabled, double alphaSpeed, double deltaSpeed, bool alphaReverse, bool deltaReverse, bool declinaisonEnabled,
                           double seuilX, double seuilY, 
                           double slitWidth, double slitRatio, 
                           double intervalle, 
                           AutoguiderCallbackType guideCallback) {
   CATCH_ERROR_VOID( ILibaudela::guideStart( camNo, exptime,  detection, 
                         originX,  originY,  targetX,  targetY,  angle,
                         targetBoxSize, 
                         telNo, mountEnabled,  alphaSpeed,  deltaSpeed,  alphaReverse,  deltaReverse,  declinaisonEnabled,
                         seuilX,  seuilY, 
                         slitWidth,  slitRatio, 
                         intervalle,
                         guideCallback) 
                         );
}


void abaudela::abaudela_guideStop() {
      CATCH_ERROR_VOID( ILibaudela::guideStop() );
}

//=============================================================================
// IError 
//=============================================================================
//const char * abaudela::abaudela_message(int errnum) {
//   return CError::message(errnum);
//}

//=============================================================================
// IArray 
//=============================================================================
// retourne le nombre d'elements d'un tableau
int abaudela::IArray_size(IArray* dataArray) {
   CATCH_ERROR(dataArray->size(), 0);
}

// detruit le tableau
void abaudela::IArray_deleteInstance(IArray* dataArray) {
   CATCH_ERROR_VOID(dataArray->release());
}


int abaudela::IIntArray_at(IIntArray* dataArray, int index) {
   CATCH_ERROR(dataArray->at(index), 0);

}

const char* abaudela::IStringArray_at(IStringArray* dataArray, int index) {
   CATCH_ERROR(dataArray->at(index), NULL);

}

void* abaudela::IStructArray_at(IStructArray* dataArray, int index) {
   CATCH_ERROR(dataArray->at(index), NULL);

}


