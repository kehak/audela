// CaptureListener.cpp: implementation of the CCapture class.
//
//////////////////////////////////////////////////////////////////////

#if defined(WIN32)
#include <windows.h>
#include <vfw.h>
#endif
#include <tcl.h>
#include <stdlib.h>
#include <string.h>
#include "CaptureListener.h"

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

//////////////////////////////////////////////////////////////////////
// CCaptureListener
//////////////////////////////////////////////////////////////////////


CCaptureListener::CCaptureListener(Tcl_Interp * interp, int camno)  {
   this->interp  = interp;
   this->camno   = camno;
   tclStatusVariable = NULL;
}

CCaptureListener::~CCaptureListener() {
   //if(tclEndProc)  free(tclEndProc);
}

void CCaptureListener::setTclStatusVariable(char * value) {
   if(tclStatusVariable != NULL ) free(tclStatusVariable);
   tclStatusVariable = strdup(value);
}



/**
 * startVideoCrop
 *    start cropped mode
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int  CCaptureListener::onNewStatus(int statusID, char * message) {
#if defined(WIN32)
   switch (statusID) {
   case IDS_CAP_BEGIN :

      break;
   case IDS_CAP_STAT_CAP_INIT:
   case IDS_CAP_SEQ_MSGSTOP :
      // rien a faire
      break;

   case IDS_CAP_STAT_VIDEOCURRENT:
      // nb de trames capturees en cours / nb trames ignorees

      // je mets a jour la variable TCL
      if( tclStatusVariable != NULL ) {
         if( Tcl_SetVar2(interp, tclStatusVariable, (char *) NULL, message, TCL_GLOBAL_ONLY) == NULL ) {
            // Traitement d'un erreur TCL dans un process en background :
            // En cas d'erreur dans la commande TCL, je force l'interpreteur
            // a signaler l'erreur par le process en foreground
            // pour eviter que l'erreur ne passe inapercue
            Tcl_BackgroundError(interp);
         }
         Tcl_Eval(interp, "update idletasks");
      }


      break;

   case IDS_CAP_STAT_VIDEOONLY :
      // bilan de la capture (nb trames capturees / nb trames ignorees)
      // je mets a jour la variable TCL
      if( tclStatusVariable != NULL ) {
         if( Tcl_SetVar2(interp, tclStatusVariable, (char *) NULL, message, TCL_GLOBAL_ONLY) == NULL ) {
            // Traitement d'un erreur TCL dans un process en background :
            // En cas d'erreur dans la commande TCL, je force l'interpreteur
            // a signaler l'erreur par le process en foreground
            // pour eviter que l'erreur ne passe inapercue
            Tcl_BackgroundError(interp);
         }
         Tcl_Eval(interp, "update idletasks");
      }

      break;

   //case IDS_CAP_STAT_CAP_FINI:
   case IDS_CAP_END :
      {
         char ligne [255];

         // je change le status de la camera
         sprintf(ligne, "status_cam%d", this->camno);
         Tcl_SetVar(this->interp, ligne, "stand", TCL_GLOBAL_ONLY);
      }

      /*
      // j'execute la commande TCL
      if( tclEndProc != NULL ) {
         result = Tcl_Eval(interp, tclEndProc);
         if( result == TCL_ERROR) {
            // Traitement d'un erreur TCL dans un process en background :
            // En cas d'erreur dans la commande TCL, je force l'interpreteur
            // a signaler l'erreur par le process en foreground
            // pour eviter que l'erreur ne passe inapercue
            Tcl_BackgroundError(interp);
         }
      }
      */
      break;

    }
#endif
   return TRUE;
}

int  CCaptureListener::onNewError(int errID, char * message) {
   int result = TRUE;
#if defined(OS_WIN)
   MessageBox(NULL, message, "capture", MB_OK | MB_ICONEXCLAMATION) ;
#endif
   return result;

}


