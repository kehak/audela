///@file tclCameraCmd.cpp
//
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author Michel Pujol
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// $Id: $

#include "sysexp.h"  //  pour definition de OS_* 
#include <stdlib.h>  //  pour _MAX_PATH
#include <cstring>
#include <string>
#include <sstream>  // pour ostringstream
using namespace ::std;
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */
#include <tcl.h>


#include <abcommon.h>
using namespace ::abcommon;
#include <tclcommon.h>
using namespace ::tclcommon;
#include <abaudela.h>  // pour ICamera
using namespace abaudela;
#include "utf2Unicode_tcl.h"
#include "tclCam.h"

typedef struct {
   ICamera *icamera; 
   Tcl_Interp *interp;
   Tcl_AsyncHandler cameraStatusAsyncHandle;
   ICamera::AcquisitionStatus acquisitionStatus; 
   std::string callbackTcl;
   CLogger m_log; 
} TclCam;

const char *cam_coolers[] = {
    "off",
    "on",
    "check",
    NULL
};

const char *cam_rgbs[] = {
    "none",
    "cfa",
    "rgb",
    "gbr",
    "brg",
    NULL
};

const char *cam_overscans[] = {
    "off",
    "on",
    NULL
};

//=============================================================================
// callback de synchonisation du status de la camera
//=============================================================================

static void cameraStatusCallback(void * clientData, ICamera::AcquisitionStatus status ) {
   TclCam * tclcam = (TclCam*)clientData;
   tclcam->acquisitionStatus = status;
   // j'execute la procedure setCameraStatusAsyncTclProc()  
   Tcl_AsyncMark(tclcam->cameraStatusAsyncHandle);
   Tcl_AsyncInvoke(tclcam->interp, TCL_OK);

}

// 
// met a jour le status dans les interpreteur
// cette fontion est declenchee par la commande Tcl_AsyncInvoke 
int setCameraStatusAsyncTclProc(ClientData clientData, Tcl_Interp *, int code) {
   TclCam * tclcam = (TclCam *)clientData;

   ICamera::AcquisitionStatus acquisitionStatus = tclcam->acquisitionStatus;
   char s[1024];
   // je memorise le status
   tclcam->acquisitionStatus = acquisitionStatus;
   // je transmets la nouvelle valeur du status a l'interpreteur TCL de la camera et à l'interpreteur TCL de l'IHM
   switch (tclcam->acquisitionStatus) {
   case ICamera::AcquisitionExp:
      sprintf(s, "set ::status_cam%d {exp} ;update", tclcam->icamera->getNo());
      break;
   case ICamera::AcquisitionRead:
      sprintf(s, "set ::status_cam%d {read} ;update", tclcam->icamera->getNo());
      break;
   case ICamera::AcquisitionStand:
   default:
      //sprintf(s, "set ::status_cam%d {stand} ;update; catch { lappend ::camera::private(A,eventList) {autovisu 10163} ; event generate . \"<<cameraEventA>>\" -when tail -data {autovisu 10163}; lappend ::camera::private(A,eventList) {acquisitionResult 0} ; event generate . \"<<cameraEventA>>\" -when tail -data {acquisitionResult 0} }", cam->camno);
      sprintf(s, "set ::status_cam%d {stand} ;update", tclcam->icamera->getNo());
      break;
   }
   tclcam->m_log.logDebug( "setCameraStatus %s", s);
   // je change l'etat de la variable dans le thread principal
   int r2 = Tcl_Eval(tclcam->interp, s);
   if (r2 == TCL_ERROR) {
      tclcam->m_log.logDebug( "Error setCameraStatus : %s", Tcl_GetStringResult(tclcam->interp));
      return code;
   }

   tclcam->m_log.logDebug( "setCameraStatus %s", Tcl_GetStringResult(tclcam->interp));

   // j'appelle la callback du TCL
   if (!tclcam->callbackTcl.empty()) {
      if (tclcam->acquisitionStatus == ICamera::AcquisitionStand) {
         sprintf(s, "%s autovisu ", tclcam->callbackTcl.c_str());
         int r3 = Tcl_Eval(tclcam->interp, s);
         if (r3 == TCL_ERROR) {
            tclcam->m_log.logDebug( "Errror %s autovisu: %s", tclcam->callbackTcl.c_str(), Tcl_GetStringResult(tclcam->interp));
            return code;
         }
         sprintf(s, "%s acquisitionResult 0", tclcam->callbackTcl.c_str());
         int r4 = Tcl_Eval(tclcam->interp, s);
         if (r4 == TCL_ERROR) {
            tclcam->m_log.logDebug( "Errror %s acquisitionResult : %s", tclcam->callbackTcl.c_str(), Tcl_GetStringResult(tclcam->interp));
            return code;
         }
      }
   }
   return code;
}

void unsetCameraStatus(TclCam * tclcam)
{
   char s[256];
   // je supprime la variable dans la thread principale
   sprintf(s, "unset ::status_cam%d", tclcam->icamera->getNo());
   Tcl_Eval(tclcam->interp, s);
}

void setScanResult(TclCam * tclcam, const char * status)
{
   char s[256];
   sprintf(s, "set ::scan_result%d {%s}", tclcam->icamera->getNo(), status);
   Tcl_Eval(tclcam->interp, s);
}

/*
 * cmdCamAcq()
 * demarre une acquisition.
 */
static int cmdCamAcq(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[100];
   int result = TCL_OK;
   TclCam * tclcam = (TclCam*)clientData;
   tclcam->m_log.logDebug("cmdCamAcq debut");
   if (argc != 2 ) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      try {
         tclcam->icamera->acq();
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }      
   }
   tclcam->m_log.logDebug("cmdCamAcq fin");
   return result;
}


//=============================================================================
// command functions
//=============================================================================

/**
  get/set binning
*/
static int cmdCamBin(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   const char **listArgv;
   int listArgc;
   int i_binx, i_biny, result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?{binx biny}?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) { 
      int binx , biny;
      tclcam->icamera->getBinning(&binx, & biny);
      sprintf(ligne, "%d %d", binx, biny);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
         sprintf(ligne, "Binning struct not valid: must be {binx biny}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else if (listArgc != 2) {
         sprintf(ligne, "Binning struct not valid: must be {binx biny}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if (Tcl_GetInt(interp, listArgv[0], &i_binx) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {binx biny}\nbinx : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else if (Tcl_GetInt(interp, listArgv[1], &i_biny) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {binx biny}\nbiny : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            try {
               tclcam->icamera->setBinning(i_binx, i_biny); 
               // TODO
               // cam->update_window();
               int binx , biny;
               tclcam->icamera->getBinning(&binx, & biny);
               sprintf(ligne, "%d %d", binx, biny);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               result = TCL_OK;
            } catch(abcommon::IError& e) {
               // je copie le message d'erreur dans le resultat TCL
               Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
               return TCL_ERROR;		
            }
         }
         Tcl_Free((char *) listArgv);
      }
   }
   return result;
}

/*
 * cmdCamBuf
 * Lecture/ecriture du numero de buffer associe a la camera.
 */
static int cmdCamBuf(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   try {
      if ((argc != 2) && (argc != 3)) {
         sprintf(ligne, "Usage: %s %s ?bufno?", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else if (argc == 2) {
         IBuffer* buffer = tclcam->icamera->getBuffer();
         if( buffer != NULL) {
            Tcl_SetObjResult(interp, Tcl_NewIntObj(buffer->getNo() ));
         } else {
            Tcl_SetObjResult(interp, Tcl_NewIntObj(0 ));
         }
      } else {
         int bufno = copyArgToInt(interp, argv[2], "bufno");
         if( bufno != 0 ) {
            IBuffer* buffer = IBuffer::getInstance(bufno);
            tclcam->icamera->setBuffer(buffer); 
         } else {
            tclcam->icamera->setBuffer(NULL);
         }

         Tcl_SetObjResult(interp, Tcl_NewIntObj(bufno) );
      }
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      return TCL_ERROR;		
   }
   return result;
}

/*
 * cmdCamBuf
 * Lecture/ecriture du numero de buffer associe a la camera.
 */
static int cmdCamCallback(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int result;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      char ligne[256];
      sprintf(ligne, "Usage: %s %s ?callback?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      Tcl_SetResult(interp, (char*) tclcam->callbackTcl.c_str(), TCL_VOLATILE);
      result = TCL_OK;
   } else {
      try {
         tclcam->callbackTcl=argv[2];
         Tcl_SetResult(interp, (char*) tclcam->callbackTcl.c_str(), TCL_VOLATILE);
         result = TCL_OK;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }
   }
   return result;
}

/**
 * get capabilities
*/
static int cmdCamCapabilities(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;

   bool expTimeCommand = tclcam->icamera->getCapability(ICamera::ExpTimeCommand);
   bool expTimeList = tclcam->icamera->getCapability(ICamera::ExpTimeList);
   bool videoMode = tclcam->icamera->getCapability(ICamera::VideoMode);

   sprintf(ligne, "expTimeCommand %d expTimeList %d videoMode %d",
      expTimeCommand,
      expTimeList,
      videoMode
      );
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/**
 *  get CCD name
 */
static int cmdCamCcd(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   const char * ccdName = tclcam->icamera->getCcd();
   sprintf(ligne, "%s", ccdName);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/**
 *  get cell dimension
 */
static int cmdCamCelldim(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int retour;
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 4)) {
      sprintf(ligne, "Usage: %s %s ?celldimx? ?celldimy?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else if (argc == 2) {
      double celldimx;
      double celldimy;
      tclcam->icamera->getCellDim(&celldimx, &celldimy);
      sprintf(ligne, "%g %g", celldimx, celldimy);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_OK;
   } else {
      try {
         //double celldimx, celldimy;
         //celldimx = copyArgToDouble(interp, argv[2], "celldimx");
         //celldimy = copyArgToDouble(interp, argv[3], "celldimy");
         //tclcam->icamera->setCellDim(celldimx, celldimy);
         //sprintf(ligne, "%g %g", celldimx, celldimy);
         //Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         //retour = TCL_OK;
         Tcl_SetResult(interp, "NOT IMPLEMENTED", TCL_VOLATILE);
         retour = TCL_ERROR;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }
   }
   return retour;
}


/**
 * close camera
*/
static int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   TclCam * tclcam = ( TclCam*) clientData;

   try {
      // icamera sera detuit ensuite par C::removeDevice
      //int result = tclcam->icamera->close();
      
      // je supprime le handler TCL du changement de status de la camera
      Tcl_AsyncDelete(tclcam->cameraStatusAsyncHandle);

      // je supprime la variable globale contenant le status de la camera
      // TODO
      //unsetCameraStatus(cam); 

      Tcl_ResetResult(interp);
      return TCL_OK;
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      return TCL_ERROR;		
   }
}


/**
 * get/set cooler 
*/
static int cmdCamCooler(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256], ligne2[50];
   int result = TCL_OK, pb = 0, k = 0;
   int coolerindex=0;
   TclCam * tclcam = ( TclCam*) clientData;
   try {
      if ((argc < 2) || (argc > 4)) {
         pb = 1;
      } else if (argc == 2) {
         pb = 0;
      } else {
         k = 0;
         pb = 1;

         while (cam_coolers[k] != NULL) {
            if (strcmp(argv[2], cam_coolers[k]) == 0) {
               coolerindex = k;
               pb = 0;
               break;
            }
            k++;
         }
         double check_temperature; 
         if (coolerindex == 2) {
           if (argc >= 4) {
               check_temperature = copyArgToDouble(interp, argv[3], "check_temperature");
               tclcam->icamera->setCoolerCheckTemperature(check_temperature);
           } else {
              // il manque argv[3] 
              pb =1;
           }
         }
         if (coolerindex == 0) {
            tclcam->icamera->setCooler(false);
         } else {
            tclcam->icamera->setCooler(true);
         }
      }
      if (pb == 1) {
         sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
         k = 0;
         while (cam_coolers[k] != NULL) {
            sprintf(ligne2, "%s", cam_coolers[k]);
            strcat(ligne, ligne2);
            if (cam_coolers[++k] != NULL) {
               strcat(ligne, "|");
            }
            strcat(ligne, " ?temperature?");
         }
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         sprintf(ligne, "%s", cam_coolers[coolerindex]);
         if (strcmp(cam_coolers[coolerindex], "check") == 0) {
            sprintf(ligne2, " %f", tclcam->icamera->getCoolerCheckTemperature());
            strcat(ligne, ligne2);
         }
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      }
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      return TCL_ERROR;		
   }
   return result;
}

static int cmdCamDebug(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1|2|3|4?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      sprintf(ligne, "%d", tclcam->icamera->getDebug());
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      try {
         int debug = copyArgToInt(interp, argv[2], "debug");
         tclcam->icamera->setDebug(debug);
         sprintf(ligne, "%d", debug);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         result = TCL_ERROR;      
      }
   }
   return result;
}



/**
 * get driverName 
*/
static int cmdCamDrivername(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   const char * driverName = tclcam->icamera->getDriverName();
   sprintf(ligne, "%s", driverName);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/**
 * get/set exposure time (in seconds) 
*/
static int cmdCamExptime(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int retour;
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?exptime?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else if (argc == 2) {
      sprintf(ligne, "%.2f", tclcam->icamera->getExptime());
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_OK;
   } else {
      try {
         double exptime = copyArgToDouble(interp, argv[2], "exptime");
         tclcam->icamera->setExptime(exptime);
         sprintf(ligne, "%.2f", exptime);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_OK;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;      
      }
   }
   return retour;
}


static int cmdCamFillfactor(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%f", tclcam->icamera->getFillFactor());
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamFoclen(ClientData , Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   //TclCam * tclcam = ( TclCam*) clientData;
   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?focal_length_(meters)?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      //sprintf(ligne, "%f", tclcam->icamera->getFocLen());
      //Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      Tcl_SetResult(interp, "NOT IMPLENTED", TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      try {
         //double foclen = copyArgToDouble(interp, argv[2], "foclen");
         //if (foclen <= 0.0 ) {
         //   throw CError( "Usage: %s %s ?focal_length_(meters)?\nfocal_length : must be an float > 0", argv[0], argv[1]);
         //}
         //tclcam->icamera->setFocLen(foclen);
         //sprintf(ligne, "%f", foclen);
         //Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         //result = TCL_OK;
         Tcl_SetResult(interp, "NOT IMPLENTED", TCL_VOLATILE);
         result = TCL_ERROR;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }
   }
   return result;
}

static int cmdCamGain(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%f", tclcam->icamera->getGain());
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/**
 * get/set Interrupt 0 or 1  
*/
static int cmdCamInterrupt(ClientData , Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   //TclCam * tclcam = ( TclCam*) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      //pb = 1;
      //choix = copyArgToInt(interp, argv[2], "interrupt");
      //if (choix == 0) {
      //   tclcam->icamera->setInterrupt(0);
      //   pb = 0;
      //}
      //if (choix == 1) {
      //   tclcam->icamera->setInterrupt(1);
      //   pb = 0;
      //}
      Tcl_SetResult(interp, "NOT IMPLENTED", TCL_VOLATILE);
      result = TCL_ERROR;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      strcat(ligne, " 0|1");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      //sprintf(ligne, "%d", tclcam->icamera->getInterrupt());
      //Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      Tcl_SetResult(interp, "NOT IMPLENTED", TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}
/**
 * get/set mirror Horizontal 0 or 1  
 * 0= no reverse
 * 1= reverse y 
*/
static int cmdCamMirrorH(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      int mirrorh = tclcam->icamera->getMirrorH();
      sprintf(ligne, "%d", mirrorh);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      try {
         bool mirrorh = copyArgToBoolean(interp, argv[2], "mirrorh");
         tclcam->icamera->setMirrorH(mirrorh);
         sprintf(ligne, "%d", mirrorh);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }
   }
   return result;
}

/**
 * get/set mirror Horizontal 0 or 1  
 * 0= no reverse
 * 1= reverse y 
*/
static int cmdCamMirrorV(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      int mirrorv = tclcam->icamera->getMirrorV();
      sprintf(ligne, "%d", mirrorv);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      try {
         bool mirrorv = copyArgToBoolean(interp, argv[2], "mirrorv");
         tclcam->icamera->setMirrorV(mirrorv);
         sprintf(ligne, "%d", mirrorv);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }
   }
   return result;
}

static int cmdCamName(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%s", tclcam->icamera->getCameraName());
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamMaxdyn(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%f", tclcam->icamera->getMaxDyn());
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamNbcells(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   int cellx, celly; 
   tclcam->icamera->getPixNb(&cellx, &celly);
   sprintf(ligne, "%d %d", cellx, celly);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamNbpix(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   int pixx, pixy; 
   tclcam->icamera->getPixNb(&pixx, &pixy);
   sprintf(ligne, "%d %d", pixx, pixy);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamOverScan(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256], ligne2[50];
   int result = TCL_OK, pb = 0, k = 0;
   TclCam * tclcam = ( TclCam*) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      k = 0;
      pb = 1;
      int overscanindex = 0;
      while (cam_overscans[k] != NULL) {
         if (strcmp(argv[2], cam_overscans[k]) == 0) {
            overscanindex = k;
            pb = 0;
            break;
         }
         k++;
      }
      if (pb == 0) {
         if (overscanindex == 0) {
            tclcam->icamera->setOverScan(false);
         } else {
            tclcam->icamera->setOverScan(true);
         }
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      k = 0;
      while (cam_overscans[k] != NULL) {
         sprintf(ligne2, "%s", cam_overscans[k]);
         strcat(ligne, ligne2);
         if (cam_overscans[++k] != NULL) {
            strcat(ligne, "|");
         }
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne, "%s", cam_overscans[tclcam->icamera->getOverScan()]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

static int cmdCamPixdim(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   double dimx, dimy; 
   tclcam->icamera->getPixDim(&dimx, &dimy);
   sprintf(ligne, "%g %g", dimx, dimy);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamPort(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%s", tclcam->icamera->getPortName() );
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamProduct(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%s", tclcam->icamera->getProduct());
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

// ---------------------------------------------------------------------------
// retourne une propriete de la camera
// 
// 
// ---------------------------------------------------------------------------
int cmdAscomcamProperty(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[1024];
   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc < 2) || (argc > 4)) {
      sprintf(ligne, "Usage: %s %s hasShutter|maxbin", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      try {
         if (strcmp(argv[2], "maxbin") == 0) {
            int maxBinX , maxBinY; 
            tclcam->icamera->getBinningMax(&maxBinX, &maxBinY);
            sprintf(ligne, "%d", maxBinX);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_OK;
         } else if (strcmp(argv[2], "hasShutter") == 0) {
            bool capability = tclcam->icamera->getCapability(ICamera::Shutter);
            sprintf(ligne, "%d", capability);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_OK;
         }
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         result = TCL_ERROR;		
      }     
   }
   return result;
}

/*
 * cmdCamTel
 * Lecture/ecriture de l'incateur pour recuperer ou non les coordonnee du telescope
 */
static int cmdCamRadecFromTel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      sprintf(ligne, "%d", (int) tclcam->icamera->getRadecFromTel());
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      
      try {
         bool radecFromTel = copyArgToBoolean(interp, argv[2], "radecFromTel");
         tclcam->icamera->setRadecFromTel(radecFromTel);
         sprintf(ligne, "%d", radecFromTel);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }      
   }
   return result;
}


static int cmdCamReadnoise(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%f", tclcam->icamera->getReadNoise());
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamRgb(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   sprintf(ligne, "%s", cam_rgbs[tclcam->icamera->getRgb() ] );
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

const char *cam_shutters[] = {
    "closed",
    "synchro",
    "opened",
    NULL
};

static int cmdCamShutter(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256], ligne2[50];
   int result = TCL_OK, pb = 0, k = 0;
   int shutterindex =0;
   TclCam * tclcam = ( TclCam*) clientData;
   if ((argc != 2) && (argc != 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      k = 0;
      pb = 1;
      while (cam_shutters[k] != NULL) {
         if (strcmp(argv[2], cam_shutters[k]) == 0) {
            shutterindex = k;
            pb = 0;
            break;
         }
         k++;
      }
      try {
         if ( shutterindex == 0 ) {
            tclcam->icamera->setShutterClosed();
         } else if ( shutterindex == 1 ) {
            tclcam->icamera->setShutterSyncho();
         } else {
            tclcam->icamera->setShutterOpened();
         }
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      k = 0;
      while (cam_shutters[k] != NULL) {
         sprintf(ligne2, "%s", cam_shutters[k]);
         strcat(ligne, ligne2);
         if (cam_shutters[++k] != NULL) {
            strcat(ligne, "|");
         }
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne, "%s", cam_shutters[tclcam->icamera->getShutterMode()]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

/*
 * cmdCamStop()
 * Commande d'arret d'une acquisition.
 */
static int cmdCamStop(ClientData clientData, Tcl_Interp * , int , const char *[])
{
    TclCam * tclcam = ( TclCam*) clientData;

    // j'envoie la commande d'arret à la camera
    tclcam->icamera->stopExposure();
    
    return TCL_OK;
}

/*
 * cmdCamStopMode() 
 * configure le mode d'acquisition apres une commande stop 
 * 0= ne pas lire le CCD (abort exposure) 
 * 1= lire le CCD
 */

static int cmdCamStopMode(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int  result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      bool stopmode = tclcam->icamera->getStopMode();
      Tcl_SetObjResult(interp, Tcl_NewBooleanObj(stopmode));
      result = TCL_OK;
   } else {
      try {
         bool stopmode = copyArgToBoolean(interp, argv[2], "stopmode");
         tclcam->icamera->setStopMode(stopmode);
         Tcl_SetObjResult(interp, Tcl_NewBooleanObj(stopmode));
         result = TCL_OK;
      } catch(abcommon::IError& e) {
         // je copie le message d'erreur dans le resultat TCL
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;		
      }
   }
   return result;
}


static int cmdCamThreadId(ClientData , Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   sprintf(ligne, "");
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamTemperature(ClientData clientData, Tcl_Interp * interp, int , const char *[])
{
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   try {
      double temperature = tclcam->icamera->getCoolerCcdTemperature();

      sprintf(ligne, "%f", temperature);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_OK;
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      return TCL_ERROR;		
   }
}



/*
 * cmdCamTel
 * Lecture/ecriture du numero de telescope associe a la camera.
 */
static int cmdCamTel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   try {
      if ((argc != 2) && (argc != 3)) {
         sprintf(ligne, "Usage: %s %s ?telno?", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else if (argc == 2) {
         ITelescope* telescope = tclcam->icamera->getTelescope();
         if( telescope != NULL) {
            Tcl_SetObjResult(interp, Tcl_NewIntObj(telescope->getNo() ));
         } else {
            Tcl_SetObjResult(interp, Tcl_NewIntObj(0 ));
         }
      } else {
         int telno = copyArgToInt(interp, argv[2], "telno");
         if( telno != 0 ) {
            ITelescope* telescope = ITelescope::getInstance(telno);
            tclcam->icamera->setTelescope(telescope); 
         } else {
            tclcam->icamera->setTelescope(NULL);
         }

         Tcl_SetObjResult(interp, Tcl_NewIntObj(telno) );
      }
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      return TCL_ERROR;		
   }
   return result;
}


static int cmdCamTimer(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   /* --- renvoie le nombre de secondes ecoulees depuis le debut de pose --- */
   char ligne[256];
   TclCam * tclcam = ( TclCam*) clientData;
   bool countDown = false;
   if (argc >= 3) {
      if (strcmp(argv[2], "-countdown") == 0) {
         countDown = true;
      }
      if (strcmp(argv[2], "-1") == 0) {
         countDown = true;
      }
   }

   int sec = tclcam->icamera->getTimer(countDown);
   sprintf(ligne, "%d", sec);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   tclcam->m_log.logDebug("cmdCamTimer sec=%d",sec);   
   return TCL_OK;
}


static int cmdCamWindow(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   const char **listArgv;
   int listArgc;

   int result = TCL_OK;
   TclCam * tclcam = ( TclCam*) clientData;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?{x1 y1 x2 y2}?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      int x1, y1, x2, y2;
      tclcam->icamera->getWindow(&x1, &y1, &x2, &y2);
      sprintf(ligne, "%d %d %d %d", x1, y1, x2, y2);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
         sprintf(ligne, "Window struct not valid: must be {x1 y1 x2 y2}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else if (listArgc != 4) {
         sprintf(ligne, "Window struct not valid: must be {x1 y1 x2 y2}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         try {
            int x1 = copyArgToInt(interp, listArgv[0], "x1");
            int y1 = copyArgToInt(interp, listArgv[1], "y1");
            int x2 = copyArgToInt(interp, listArgv[2], "x2");
            int y2 = copyArgToInt(interp, listArgv[3], "y2");
            tclcam->icamera->setWindow(x1, y1, x2, y2);
            sprintf(ligne, "%d %d %d %d", x1, y1, x2, y2);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_OK;
         } catch(abcommon::IError& e) {
            // je copie le message d'erreur dans le resultat TCL
            Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
            result = TCL_ERROR;	
         }
         Tcl_Free((char *) listArgv);
      }
   }
   return result;
}







struct cmditem {
    const char *cmd;
    Tcl_CmdProc *func;
};

static struct cmditem commonCmdList[] = {
   {"acq", (Tcl_CmdProc *)cmdCamAcq},
   {"bin", (Tcl_CmdProc *)cmdCamBin},
   {"buf", (Tcl_CmdProc *)cmdCamBuf},
   {"callback", (Tcl_CmdProc *)cmdCamCallback},
   {"capabilities", (Tcl_CmdProc *)cmdCamCapabilities},
   {"ccd", (Tcl_CmdProc *)cmdCamCcd},
   {"celldim", (Tcl_CmdProc *)cmdCamCelldim},
   {"close", (Tcl_CmdProc *)cmdCamClose}, 
   {"cooler", (Tcl_CmdProc *)cmdCamCooler},
   {"debug", (Tcl_CmdProc *)cmdCamDebug},
   {"drivername", (Tcl_CmdProc *)cmdCamDrivername},
   {"exptime", (Tcl_CmdProc *)cmdCamExptime},
   {"fillfactor", (Tcl_CmdProc *)cmdCamFillfactor},
   {"foclen", (Tcl_CmdProc *)cmdCamFoclen},
   {"gain", (Tcl_CmdProc *)cmdCamGain},
   {"interrupt", (Tcl_CmdProc *)cmdCamInterrupt},
   {"maxdyn", (Tcl_CmdProc *)cmdCamMaxdyn},
   {"mirrorh", (Tcl_CmdProc *)cmdCamMirrorH},
   {"mirrorv", (Tcl_CmdProc *)cmdCamMirrorV},
   {"name", (Tcl_CmdProc *)cmdCamName},
   {"nbcells", (Tcl_CmdProc *)cmdCamNbcells},
   {"nbpix", (Tcl_CmdProc *)cmdCamNbpix},
   {"overscan", (Tcl_CmdProc *)cmdCamOverScan}, 
   {"pixdim", (Tcl_CmdProc *)cmdCamPixdim},
   {"port", (Tcl_CmdProc *)cmdCamPort},
   {"product", (Tcl_CmdProc *)cmdCamProduct},
   {"property", (Tcl_CmdProc *)cmdAscomcamProperty},   
   {"radecfromtel", (Tcl_CmdProc *)cmdCamRadecFromTel},
   {"readnoise", (Tcl_CmdProc *)cmdCamReadnoise},
   {"rgb", (Tcl_CmdProc *)cmdCamRgb},
   {"shutter", (Tcl_CmdProc *)cmdCamShutter},
   {"stop", (Tcl_CmdProc *)cmdCamStop},
   {"stopmode", (Tcl_CmdProc *)cmdCamStopMode},
   {"tel", (Tcl_CmdProc *)cmdCamTel},
   {"temperature", (Tcl_CmdProc *)cmdCamTemperature},
   {"threadid", (Tcl_CmdProc *)cmdCamThreadId},
   {"timer", (Tcl_CmdProc *)cmdCamTimer},
   {"window", (Tcl_CmdProc *)cmdCamWindow},

   /* === Last function terminated by NULL pointers === */
   {NULL, NULL}
};


/**
 *  execute une commande qui peut être 
 *    - une commande generique 
 *    - une commande specifique C
 *    - une commande specifique TCL 
 */ 
int tclCameraCmd(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char s[1024], ss[50];
   int retour = TCL_OK, k, i;
   TclCam * tclcam = (TclCam*)clientData;


   if (argc == 1) {
     sprintf(s, "%s choose sub-command among ", argv[0]);
      k = 0;
      while (commonCmdList[k].cmd != NULL) {
         sprintf(ss, " %s", commonCmdList[k].cmd);
         strcat(s, ss);
         k++;
      }
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {

      // je trace les parametres si le niveau debug est active
      if (tclcam->m_log.getLogLevel() > 0) {
         char s1[1024], *s2;
         s2 = s1;
         s2 += sprintf(s2,"Enter cmdCam (argc=%d", argc);
         for (i = 0; i < argc; i++) {
            s2 += sprintf(s2, ",argv[%d]=%s", i, argv[i]);
         }
         s2 += sprintf(s2, ")");
         tclcam->m_log.logInfo( "%s", s1);
         //tclcam->m_log.log(ILogger::LOG_INFO,"%s", s1);
         
      }

      // commande generique 
      struct cmditem *genericCmd;
      for (genericCmd = commonCmdList; genericCmd->cmd != NULL; genericCmd++) {
         if (strcmp(genericCmd->cmd, argv[1]) == 0) {
            retour = (*genericCmd->func) (clientData, interp, argc, argv);
            break;
         }
      }

      // j'execute la  command specifique C
      int specificCommandResult = 1;
      if (genericCmd->cmd == NULL) {
         char * result; 
         specificCommandResult = tclcam->icamera->executeSpecificCommand(&result, argc, argv);
         if (specificCommandResult == 0) {
            Tcl_SetResult(interp, result, TCL_VOLATILE);
            retour = TCL_OK;
            tclcam->icamera->freeSpecificCommandResult();
         } else if( specificCommandResult == 0) {
            Tcl_SetResult(interp, result, TCL_VOLATILE);
            retour = TCL_ERROR;
            tclcam->icamera->freeSpecificCommandResult();
         }
      }

      // j'execute la  command specifique TCL
      int specificTclCommandResult = 1;
      if (genericCmd->cmd == NULL && specificCommandResult== -1) {
         specificTclCommandResult = tclcam->icamera->executeTclSpecificCommand(interp, argc, argv);
         if( specificTclCommandResult == -1 ) {
            retour = TCL_ERROR;
         } else {
            retour = specificTclCommandResult;
         }
      }

      // je trace la fin d'execution de la commande
      if (tclcam->m_log.getLogLevel() > 0) {
         char s1[1024], *s2;
         s2 = s1;
         s2 += sprintf(s2,"EXIT  cmdCam (argc=%d", argc);
         for (i = 0; i < argc; i++) {
            s2 += sprintf(s2, ",argv[%d]=%s", i, argv[i]);
         }
         s2 += sprintf(s2, ")");
         tclcam->m_log.logInfo( "%s", s1);
         //tclcam->m_log.log(ILogger::LOG_INFO, "%s", s1);
      }

      // je trace une erreur si la commande n'a pas ete trouvee
      if (genericCmd->cmd == NULL && specificCommandResult == -1 && specificTclCommandResult == -1) {
         sprintf(s, "%s %s : sub-command not found among ", argv[0], argv[1]);
         k = 0;
         while (commonCmdList[k].cmd != NULL) {
            sprintf(ss, " %s", commonCmdList[k].cmd);
            strcat(s, ss);
            k++;
         }
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
}


/*
///
//  cree la camera 
//    - cree la structure icamera  (contruit par libaudela)
//    - cree une struture camprop contenant les pointeurs vers icamera et vers interp
// 
int CamCreate(ICamera *icamera, Tcl_Interp * interp, int argc, const char *argv[])
{
   TclCam * tclcam = new TclCamProp();
   tclcam->icamera = icamera;
   tclcam->interp = interp;

   if (argc < 3) {
      char s[1024];   
      sprintf(s, "%s driver port ?options?", argv[0]);
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      

#ifdef CMD_CAM_SETUP
      if (argc == 3 && strcmp(argv[1],"setup") == 0) {
         return cmdAscomcamSetupDialog(clientData, interp, argc, argv);
      }
#endif
           
      // Cree la commmande TCL "cam1" exportee de la librairie lbcam.
      char camCommand[10]; 
      sprintf(camCommand, "cam%d", icamera->getNo());
      Tcl_CreateCommand(interp, camCommand, (Tcl_CmdProc *) tclCameraCmd, (ClientData) tclcam, NULL);

      icamera->setCallback(cameraStatusCallback, (void*) tclcam);

      // j'intialise le handle pour mettre a jour le status dans les interpreteurs TCL en mode asynchone
      tclcam->cameraStatusAsyncHandle = Tcl_AsyncCreate(setCameraStatusAsyncTclProc, tclcam);
      
      // set TCL global status_camNo
      setCameraStatus(tclcam,ICamera::AcquisitionStand);

      tclcam->m_log.logDebug( "cmdCamCreate: create camera data at %p\n", tclcam);
   }
   return TCL_OK;
}
*/


//=============================================================================
// gestion du pool des caméras
//=============================================================================

///@brief cree une instance de Camera
// implemente la commande ::cam::create
//   
// @return retourne camNo
//
int tclCameraCreate(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   

   try {
      TclCam * tclcam = new TclCam();
      tclcam->m_log.set("camera.log", argc, argv);
 
      if(argc < 3) {
         throw CError(CError::ErrorInput, "%s driver cameraName ?options?", argv[0]);
      } 
     
      // je recupere le nom du repertoire des librairies
      auto_ptr<string> libraryPath = tclcommon::getLibraryPath(interp);
      
      // je cree l'instance C++ en passant les parametres arg[2] ... argv[n]
      ICamera* icamera = abaudela::ICamera::createInstance(libraryPath->c_str(), argv[1], argc - 2, &argv[2]);

      tclcam->icamera = icamera;
      tclcam->interp = interp;

      // je cree la commande TCL "cam1"
      int camNo = icamera->getNo();
      std::ostringstream instanceName ;
      instanceName << "cam" << camNo;
      Tcl_CreateCommand(interp, instanceName.str().c_str(), (Tcl_CmdProc *)tclCameraCmd, (ClientData)tclcam,(Tcl_CmdDeleteProc *)NULL);
      
#ifdef CMD_CAM_SETUP
      if (argc == 3 && strcmp(argv[1],"setup") == 0) {
         return cmdAscomcamSetupDialog(clientData, interp, argc, argv);
      }
#endif
           
      // je configure la callback
      icamera->setSatusCallback(tclcam, cameraStatusCallback);

      // j'intialise le handle pour mettre a jour le status dans les interpreteurs TCL en mode asynchone
      tclcam->cameraStatusAsyncHandle = Tcl_AsyncCreate(setCameraStatusAsyncTclProc, tclcam);      
      tclcam->m_log.logDebug( "cmdCamCreate: create camera data at %p\n", tclcam);
   
      // je retourne camNo
      Tcl_SetObjResult(interp, Tcl_NewIntObj(camNo));
      result = TCL_OK; 
   } catch(IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

///@brief supprime un camera 
// implemente la commande ::cam::delete
//
// @param argc
// @param argv arv[1] contient le numero de l'instance a supprimer
//
int tclCameraDelete(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 2) {
         throw CError(CError::ErrorInput, "Usage: %s cameraNo", argv[0]);
      } 
      // je recupere le nom de la commande 
      int camNo = copyArgToInt(interp, argv[1], "cameraNo");
      std::string commandName = "cam" + std::to_string(camNo);
      
      // je recupere telData 
      Tcl_CmdInfo cmdInfo;
      result = Tcl_GetCommandInfo(interp, commandName.c_str(), &cmdInfo);
      if (result == 0) {
         throw CError(CError::ErrorGeneric, "tclTelescopeDelete: Tcl_GetCommandInfo: %s not found", commandName.c_str());
      }
      TclCam * tclcam = (TclCam*)cmdInfo.clientData;

      // je supprime le handle asynchone
      Tcl_AsyncDelete(tclcam->cameraStatusAsyncHandle);

      // je supprime la commande TCL
      Tcl_DeleteCommand(interp, commandName.c_str());

      // je supprime l'instance C++
      abaudela::ICamera* camera = abaudela::ICamera::getInstance(camNo);
      abaudela::ICamera::deleteInstance(camera);

      // je supprime tclcam
      delete tclcam;

      Tcl_ResetResult(interp);
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}


///@brief liste des camNo
// implemente la commande ::cam::list
//   
// @return la liste des camNo
//
int tclCameraList(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 1) {
         throw CError(CError::ErrorInput, "Usage: %s", argv[0]);
      } 
      abcommon::IIntArray* instanceNoList = abaudela::ICamera::getIntanceNoList();
      Tcl_Obj *  listObj = Tcl_NewListObj( 0, NULL );
      for(int i=0; i< instanceNoList->size(); i++ ) {
         Tcl_ListObjAppendList(interp, listObj, Tcl_NewIntObj(instanceNoList->at(i)) );
      }
      Tcl_SetObjResult(interp, listObj );
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

///@brief liste des camera disponibles 
// implemente la commande ::cam::available
//   
// @return la liste des camNo
//
int tclCameraAvailable (ClientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if (argc < 2) {
         throw CError(CError::ErrorInput, "Usage: %s cameraName", argv[0]);
      }

      // je recupere le nom du repertoire des librairies
      auto_ptr<string> libraryPath = tclcommon::getLibraryPath(interp);

      abcommon::IStructArray* availableList = abaudela::ICamera::getAvailableCamera(libraryPath->c_str(), argv[1]);
      Tcl_Obj *  listObj = Tcl_NewListObj(0, NULL);
      for (int i = 0; i< availableList->size(); i++) {
         abcommon::SAvailable*  available = (abcommon::SAvailable*) availableList->at(i);
         Tcl_Obj *  availableObj = Tcl_NewListObj(0, NULL);
         Tcl_ListObjAppendElement(interp, availableObj, Tcl_NewStringObj(available->getId(), -1));
         Tcl_ListObjAppendElement(interp, availableObj, Tcl_NewStringObj(available->getName(), -1));
         Tcl_ListObjAppendElement(interp, listObj, availableObj );
      }
      Tcl_SetObjResult(interp, listObj);
      result = TCL_OK;
   }
   catch (abcommon::IError &e) {
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}
