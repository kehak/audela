/*
 *    fits_Init.c --
 *
 * This is the setup routine for the Fits extended Tcl.
 *
 */

#include "fitsTclInt.h"

FitsFD FitsOpenFiles[FITS_MAX_OPEN_FILES];
Tcl_HashTable *FitsDataStore;
int FitsDS_numElems = 0;
int FitsDS_curAccess = 0;

fitsTclOptions userOptions;

int
Fits_Init (interp)
    Tcl_Interp *interp;     /* The Tcl Interpreter to initialize */
{
    static Tcl_HashTable FitsOpenKwds[FITS_MAX_OPEN_FILES];
    static FitsCardList hisCardList[FITS_MAX_OPEN_FILES];
    static FitsCardList comCardList[FITS_MAX_OPEN_FILES];

    int i;

    for ( i = 0; i < FITS_MAX_OPEN_FILES; i++) {
	FitsOpenFiles[i].fptr = NULL;
	FitsOpenFiles[i].kwds = FitsOpenKwds + i;
	FitsOpenFiles[i].hisHead = hisCardList + i;
	FitsOpenFiles[i].hisHead->next = (FitsCardList *) NULL;
	FitsOpenFiles[i].hisHead->pos = -1;
	FitsOpenFiles[i].comHead = comCardList + i;
	FitsOpenFiles[i].comHead->next = (FitsCardList *) NULL;
	FitsOpenFiles[i].comHead->pos = -1;
	FitsOpenFiles[i].handleName = NULL;
    }
    userOptions.wcsSwap = 0;

    FitsDataStore = (Tcl_HashTable *) ckalloc(sizeof(Tcl_HashTable));
    Tcl_InitHashTable(FitsDataStore,3);

    Tcl_CreateObjCommand(interp, "fits", Fits_MainCommand,( ClientData) NULL,
			 (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateObjCommand(interp, "lst2ptr", fitsLst2Ptr, (ClientData) NULL, 
			 (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateObjCommand(interp, "ptr2lst", fitsPtr2Lst, (ClientData) NULL, 
			 (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateObjCommand(interp, "vexpr", fitsExpr, (ClientData) NULL, 
			 (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateObjCommand( interp, "range", fitsRange,
                          (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);

    /* 
     *  Remaining commands are special commands used by fv.
     *  They are all located in fvTcl.c.
     */ 

    Tcl_CreateCommand(interp,"isFits",(Tcl_CmdProc*)isFitsCmd,
                      (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateCommand(interp,"getmax",(Tcl_CmdProc*)getMaxCmd,
                      (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateCommand(interp,"getmin",(Tcl_CmdProc*)getMinCmd,
                      (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateCommand(interp,"setarray",(Tcl_CmdProc*)setArray,
                      (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateCommand(interp,"sarray",(Tcl_CmdProc*)searchArray,
                      (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateCommand(interp,"updateFirst",(Tcl_CmdProc*)updateFirst,
                      (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateCommand(interp,"calAbsXPos",(Tcl_CmdProc*)Table_calAbsXPos,
                      (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand( interp, "updateCell",
                          (Tcl_ObjCmdProc*)Table_updateCell,
                          (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);

    return TCL_OK;
}



