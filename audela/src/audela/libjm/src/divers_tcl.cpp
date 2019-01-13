/***
 * @file : divers_tcl.cpp
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: divers_tcl.cpp,v 1.4 2010-06-20 12:18:20 jacquesmichelet Exp $
 *
 * <pre>
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
 * </pre>
 */

#include <vector>

#include <string.h>
#include <stdlib.h>
#include "libjm.h"
#include "divers.h"


namespace LibJM {
/************************************************************/
/* Initialisation des parametres d'un tampon d'image        */
/************************************************************/
int Divers::CmdInitTamponImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    char s[256];
    sprintf (s, "Usage: %s has been obsoleted", argv[0]);
    Tcl_SetResult (interp, s, TCL_VOLATILE);
    return TCL_ERROR;
}

int Divers::CmdInfoImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
     /****************************************************************************/
     /* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
     /****************************************************************************/
     /****************************************************************************/
{
    int result = 0;
#if 0
    int result,retour;
  Tcl_DString dsptr;
  char s[100];
  descripteur_image image;
  int numbuf;

  CALAPHOT_DEBUG ("argc = %d\n", argc);

  if(argc<2) {
    sprintf(s,"Usage: %s numbuf", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf);
    if(retour!=TCL_OK) return retour;
    /*--- initialise la dynamic string ---*/
    Tcl_DStringInit(&dsptr);
    /* --- recherche les infos ---*/
    result=tcl_InfoImage(interp,numbuf,&image);
    /* --- met en forme le resultat dans une chaine de caracteres ---*/
    sprintf(s,"%p %d %d %s",(void*)image.ptr_audela,image.naxis1,image.naxis2,image.dateobs);
    /* --- on ajoute cette chaine a la dynamic string ---*/
    Tcl_DStringAppend(&dsptr,s,-1);
    /* --- a la fin, on envoie le contenu de la dynamic string dans */
    /* --- le Result qui sera retourne a l'utilisateur. */
    Tcl_DStringResult(interp,&dsptr);
    /* --- desaloue la dynamic string. */
    Tcl_DStringFree(&dsptr);
  }
#endif
  return result;
}


}
