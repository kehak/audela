// Projet      : AudeLA 
// Librairie   : libbm
// Fichier     : bm_c_tcl.h
// Description : Prototype des fonctions interfaces Tcl et le C  
// ============================================================

#include <iostream>
#include "libbm.h"

#include <gsl/gsl_sort.h>
#include <gsl/gsl_statistics.h>


int CmdVersionLib(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
bool CmdBmLecturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmEcriturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmMax(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmHard2Visu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmSoustrait(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmAjoute(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmAbs(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmMultiplie(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmMultiplie_ajoute(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmDivise(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmCarre(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmCarre_ajoute(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmRacine_carree(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmMarche(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmDxx(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmDyy(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmConvolue(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdBmDisque(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int DecodeListeDouble(Tcl_Interp *interp, char *list, double *tableau, int *n);
int CmdBmMediane(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

