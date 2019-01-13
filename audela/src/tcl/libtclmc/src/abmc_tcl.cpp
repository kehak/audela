// abmc_tcl.cpp : 
// import interface of abmc astrobrick


#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>

#ifdef WIN32 
#define sscanf sscanf_s
#endif

#include <tcl.h>
#include <abmc.h>       // pou IMc
#include "abmc_tcl.h"
#include "abmc_tcl_pool.h"
#include "abmc_tcl_obsoletes.h"
#include "abmc_tcl_angles.h"
#include "abmc_tcl_dates.h"
#include "abmc_tcl_common.h"
#include "abmc_tcl_command.h" // pour cmdMcCompatibility()

//=============================================================================
//                      Point d'entree de la librairie TCL                 
//=============================================================================
int Tclmc_Init(Tcl_Interp *interp)
{
   if(Tcl_InitStubs(interp,"8.6",0)==NULL) {
      Tcl_SetResult(interp, (char *) "Tcl Stubs initialization",TCL_STATIC);
      return TCL_ERROR;
   }
   Tcl_PkgProvide(interp,"abmc","1.0");

   // gestion du pool d'instances mc 
   Tcl_CreateCommand(interp,"mc::create", cmdMcCreate, NULL, NULL);   
   Tcl_CreateCommand(interp,"mc::delete", cmdMcDelete, NULL, NULL);   
   Tcl_CreateCommand(interp,"mc::list",   cmdMcList,   NULL, NULL); 

   // commande d'aide
   Tcl_CreateCommand(interp,"mc_help",(Tcl_CmdProc *)Cmd_mctcl_help, NULL,NULL);           


   // declaration des anciennes commandes utilisees par audace pour compatilite 
   // je cree une instance de mc ( cmdMcCreate cree en meme temps la commande mc1)
   cmdMcCreate(NULL, interp, 1, NULL);
   int mcNo ;
   Tcl_GetIntFromObj(interp, Tcl_GetObjResult(interp), &mcNo); 
   abmc::IMc* mc = abmc::IMcPool_getInstance(mcNo);

   // je declare les anciennes commandes
   Tcl_CreateCommand(interp,"mc_date2jd",             cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_date2iso8601",        cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_date2ymdhms",         cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_date2tt",             cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_date2equinox",        cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_date2lst",            cmdMcCompatibility, mc, NULL);           
   
	//
   Tcl_CreateCommand(interp,"mc_angle2deg",           cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_angle2sexa",          cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_angles_computation",  cmdMcCompatibility, mc, NULL);
   Tcl_CreateCommand(interp,"mc_angles_separation",   cmdMcCompatibility, mc, NULL);

	// --- Obsolete. For compatibility with old AudeLA versions
   Tcl_CreateCommand(interp,"mc_angle2dms",           cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_angle2hms",           cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_anglescomp",          cmdMcCompatibility, mc, NULL);
   Tcl_CreateCommand(interp,"mc_anglesep",            cmdMcCompatibility, mc, NULL);           
   Tcl_CreateCommand(interp,"mc_sepangle",            cmdMcCompatibility, mc, NULL);

   return TCL_OK;
}

/***************************************************************************/
/*                                                                         */
/***************************************************************************/

