/***
 * @file : horloge_tcl.cpp
 * @brief : interface TCL<->C pour la gestion de l'horloge système
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: horloge_tcl.cpp,v 1.4 2010-06-20 12:18:20 jacquesmichelet Exp $
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
#include <string.h>
#include <stdlib.h>     /*atoi, atof*/
#include "libjm.h"
#include "horloge.h"

namespace LibJM {

/******************************************/
/* Gestion de l'heure PC                  */
/******************************************/
int Horloge::CmdHeurePC(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  int annee, mois, jour, heure, minute, seconde, milli;
  int erreur;

  /* Vérifie que la commande a le bon nombre d'argument
   * --------------------------------------------------
   */
  if ((argc != 1) && (argc != 8))
    {
      sprintf(s, "Usage: %s ?yyyy MM dd hh mm ss lll?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }

  /* Lecture de l'heure
   * ------------------
   */
   if (argc == 1)
    {
      if (LitHeurePC(&annee, &mois, &jour, &heure, &minute, &seconde, &milli) == Generique::PB)
        {
          strcpy(s,"Erreur dans la fonction LitHeurePC");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }
      sprintf(s,"%04d %02d %02d %02d %02d %02d %03d", annee, mois, jour, heure, minute, seconde, milli);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
    }

  /* Lecture de l'heure */
  if (argc == 8)
    {
      erreur = EcritHeurePC(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]), atoi(argv[7]));

      if (erreur == Generique::PB)
        {
          strcpy(s,"Erreur dans la fonction EcritHeurePC");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }
      if (erreur == Generique::PB2)
        {
          strcpy(s,"Probl�me de droit d'acc�s pour la fonction EcritHeurePC");
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }

      sprintf(s,"%04d %02d %02d %02d %02d %02d %03d", atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]), atoi(argv[7]));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
    }
  return TCL_OK;
}

/******************************************/
/* Reglage de l'heure PC                  */
/******************************************/
int Horloge::CmdReglageHeurePC(ClientData clienData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
  long decalage;
  int erreur;

  if (argc != 2)
    {
      sprintf(s, "Usage: %s decalage en ms", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
    erreur = ReglageHeurePC(&decalage, atol(argv[1]));
  if (erreur == Generique::PB)
    {
      strcpy(s,"Erreur dans la fonction ReglageHeurePC");

      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
    }
  if (erreur == Generique::PB2)
    {
       strcpy(s,"Probl�me de droit d'acc�s pour la fonction ReglageHeurePC");
       Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
    }

  sprintf(s,"%ld", decalage);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;

}


}
