libfitstcl 3340

Some minor modification were done from the original files:

In fitsCmds.c all "atoll" have been replaced by "fitsTcl_atoll"

In tclShared.c, following lines
   #ifdef __WIN32__
   int _external Fitstcl_Init (Tcl_Interp *interp);
have been replaced by
   #ifdef __WIN32__
   int Fitstcl_Init (Tcl_Interp *interp);

