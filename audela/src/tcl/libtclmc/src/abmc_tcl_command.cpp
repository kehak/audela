// abmc_tcl_mcpool.cpp : 
// manage mc intances 


#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>
#include <cstdlib> //pour malloc, free

#include <tcl.h>
#include <abcommon.h>  // pour CError
#include "abmc.h"
#include "abmc_tcl_command.h"
#include "abmc_tcl_common.h"
#include "abmc_tcl_angles.h"
#include "abmc_tcl_dates.h"
#include "abmc_tcl_obsoletes.h"


struct cmditem {
    const char *cmd;
    Tcl_CmdProc *func;
};

static struct cmditem cmdlist[] = {
   {"angle2deg", (Tcl_CmdProc *)Cmd_mctcl_angle2deg},
   {"angle2rad", (Tcl_CmdProc *)Cmd_mctcl_angle2rad},
   {"angle2sexa", (Tcl_CmdProc *)Cmd_mctcl_angle2sexagesimal},
   {"angles_computation", (Tcl_CmdProc *)Cmd_mctcl_angles_computation},
   {"angles_separation", (Tcl_CmdProc *)Cmd_mctcl_angles_separation},

   {"date2jd", (Tcl_CmdProc *)Cmd_mctcl_date2jd},
   {"date2iso8601", (Tcl_CmdProc *)Cmd_mctcl_date2iso8601},
   {"date2ymdhms", (Tcl_CmdProc *)Cmd_mctcl_date2ymdhms},
   {"date2tt", (Tcl_CmdProc *)Cmd_mctcl_date2tt},
   {"date2equinox", (Tcl_CmdProc *)Cmd_mctcl_date2equinox},
   {"date2lst", (Tcl_CmdProc *)Cmd_mctcl_date2lst},

   // --- Obsolete. For compatibility with old AudeLA versions
   {"angle2dms", (Tcl_CmdProc *)Cmd_mctcl_angle2dms},
   {"angle2hms", (Tcl_CmdProc *)Cmd_mctcl_angle2hms},
   {"anglescomp", (Tcl_CmdProc *)Cmd_mctcl_anglesep},
   {"sepangle", (Tcl_CmdProc *)Cmd_mctcl_sepangle},
   {"", NULL}
};


//=============================================================================
//  execute une commande TCL
//
//=============================================================================
int cmdMcCommand(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   const char *usage = "Usage: mc date2jd  ";
   if(argc < 2) {
      Tcl_SetResult(interp, (char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   }

   int result = TCL_OK;
   struct cmditem *cmd;
   for (cmd = cmdlist; cmd->cmd != NULL; cmd++) {
      if (strcmp(cmd->cmd, argv[1]) == 0) {
         result = (*cmd->func) (clientData, interp, argc, argv);
         break;
      }
   }

   if (cmd->cmd == NULL) {
      std::ostringstream message;
      message << argv[0] << " " << argv[1] << ": sub-command not found among";
      int k = 0;
      while (cmdlist[k].cmd != NULL) {
         message <<" " << cmdlist[k].cmd;
         k++;
      }
      Tcl_SetResult(interp, (char*)message.str().c_str(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}

//=============================================================================
//  convertit une ancienne commande MC appelée par Aud'Ace
//     mc_xxxx  argv1 argv2 argv3 ...
//  en une commande MC pour astrobrick
//     mc  xxxx  argv2 argv3 argv4 ... 
//=============================================================================
int cmdMcCompatibility(ClientData clientdata, Tcl_Interp *interp, int argc, const char *argv[]) {

   // je verifie que la commande commence par mc_
   const char* argv0 = argv[0];
   if (strncmp(argv0,"mc_",3)!=0) {
      std::ostringstream message ;
      message << "Unknown command" << argv0 << "(command must bebin with mc_ )";
      Tcl_SetResult(interp,(char*)message.str().c_str(),TCL_VOLATILE);
      return TCL_ERROR;
   }

   // je cree les deux premiers arguments ( mc  xxx )
   const char **argv2 =  (const char**) malloc( (argc+1) * sizeof(char*));  
   argv2[0]="mc";
   argv2[1]=&(argv[0][3]);
   
   // je copie les arguments suivants
   for(int i=1; i<argc; i++) {
      argv2[i+1]=argv[i];
   }
   // j'execute la commande
   int result = cmdMcCommand(clientdata , interp, argc+1, argv2);
   free(argv2);
   return result;

}

