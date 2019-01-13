// Librairie : LIBBM
// Fichier : libbm.cpp
// Description : Point d'entree de la librairie
// ============================================

#define XTERN
#include "sysexp.h"
#include "libbm.h"

// *********** BM_Init **********
// Point d'entree de la librairie
// ******************************
#if defined(OS_WIN)
extern "C" int __cdecl Bm_Init(Tcl_Interp*interp)
#else
extern "C" int Bm_Init(Tcl_Interp*interp)
#endif
{
   if(Tcl_InitStubs(interp,"8.4",0)==NULL) {
      Tcl_SetResult(interp,(char*)"Tcl Stubs initialization failed in libbm.",TCL_STATIC);
      return TCL_ERROR;
   }

  // Si les deux DLLs ont bien �t� charg�es, on enregistre
  // les fonctions de la biblioth�que qui seront alors disponibles
  // depuis l'interpreteur TCL, de la meme maniere que toutes les
  // autres fonctions TCL.
  // Ajoutez ici les fonctions externes...
  // -------------------------------------------------------------

      Tcl_CreateCommand(interp,"bm_versionlib",(Tcl_CmdProc *)CmdVersionLib,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

//       Tcl_CreateCommand(interp,"bm_lecturepixel",(Tcl_CmdProc *)CmdBmLecturePixel,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
//       Tcl_CreateCommand(interp,"bm_ecriturepixel",(Tcl_CmdProc *)CmdBmEcriturePixel,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_max",(Tcl_CmdProc *)CmdBmMax,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

      Tcl_CreateCommand(interp,"bm_hard2visu",(Tcl_CmdProc *)CmdBmHard2Visu,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

      Tcl_CreateCommand(interp,"bm_soustrait",(Tcl_CmdProc *)CmdBmSoustrait,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_ajoute",(Tcl_CmdProc *)CmdBmAjoute,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_abs",(Tcl_CmdProc *)CmdBmAbs,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_multiplie",(Tcl_CmdProc *)CmdBmMultiplie,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_multiplie_ajoute",(Tcl_CmdProc *)CmdBmMultiplie_ajoute,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_divise",(Tcl_CmdProc *)CmdBmDivise,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_carre",(Tcl_CmdProc *)CmdBmCarre,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_carre_ajoute",(Tcl_CmdProc *)CmdBmCarre_ajoute,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_racine_carree",(Tcl_CmdProc *)CmdBmRacine_carree,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_marche",(Tcl_CmdProc *)CmdBmMarche,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_Dxx",(Tcl_CmdProc *)CmdBmDxx,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_Dyy",(Tcl_CmdProc *)CmdBmDyy,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_convolue",(Tcl_CmdProc *)CmdBmConvolue,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
      Tcl_CreateCommand(interp,"bm_disque",(Tcl_CmdProc *)CmdBmDisque,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

      Tcl_CreateCommand(interp,"bm_mediane",(Tcl_CmdProc *)CmdBmMediane,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);


  return TCL_OK;
}


