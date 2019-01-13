// CaptureListener.h: interface for the GuidingCaptureListener class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __CAPTURE_LISTENER_H__
#define __CAPTURE_LISTENER_H__

#include <tcl.h>
//#include "ICaptureListener.h"

/**
 * class CCaptureListener
 *    implemente l'interface ICaptureListener pour traiter
 *    les erreurs et les messages signalant les changements d'�tat
 */
class CCaptureListener {

      public:
   CCaptureListener(Tcl_Interp * interp, int camno);
   ~CCaptureListener();
   int onNewStatus(int statusID, char *message);
   int onNewError(int errID, char *message);
   void setTclStatusVariable(char *value);

      protected:
   char *tclStatusVariable;
   Tcl_Interp *interp;
   int camno;

};

#endif
