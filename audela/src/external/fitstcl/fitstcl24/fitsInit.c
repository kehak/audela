/*
 *    fits_Init.c --
 *
 * This is the setup routine for the Fits extended Tcl.
 *
 */

#include "fitsTclInt.h"
static Tcl_HashTable interpTokenMap;
static int interpTokenMapInitialised = 0;

FitsFD FitsOpenFiles[FITS_MAX_OPEN_FILES];
Tcl_HashTable *FitsDataStore;
int FitsDS_numElems = 0;
int FitsDS_curAccess = 0;

fitsTclOptions userOptions;

Tcl_Command *
FitsTclInterpToTokens(
    Tcl_Interp *interp)
{
    int newEntry;
    Tcl_Command *cmdTokens;
    Tcl_HashEntry *entryPtr =
	    Tcl_CreateHashEntry(&interpTokenMap, (char *) interp, &newEntry);

    if (newEntry) {
	cmdTokens = (Tcl_Command *)
		Tcl_Alloc(sizeof(Tcl_Command) * (MAX_REGISTERED_COMMANDS+1));
	for (newEntry=0 ; newEntry<MAX_REGISTERED_COMMANDS+1 ; ++newEntry) {
	    cmdTokens[newEntry] = NULL;
	}
	Tcl_SetHashValue(entryPtr, (ClientData) cmdTokens);
    } else {
	cmdTokens = (Tcl_Command *) Tcl_GetHashValue(entryPtr);
    }
    return cmdTokens;
}

void
FitsTclFreeTokensHashTable(void)
{
    Tcl_HashSearch search;
    Tcl_HashEntry *entryPtr;

    for (entryPtr = Tcl_FirstHashEntry(&interpTokenMap, &search);
	    entryPtr != NULL; entryPtr = Tcl_NextHashEntry(&search)) {
	Tcl_Free((char *) Tcl_GetHashValue(entryPtr));
    }
    interpTokenMapInitialised = 0;
}

int
Fits_SafeInit (interp)
    Tcl_Interp *interp;     /* The Tcl Interpreter to initialize */
{
    return Fits_Init(interp);
}

void
FitsTclDeleteTokens(
    Tcl_Interp *interp)
{
    Tcl_HashEntry *entryPtr =
	    Tcl_FindHashEntry(&interpTokenMap, (char *) interp);

    if (entryPtr) {
	Tcl_Free((char *) Tcl_GetHashValue(entryPtr));
	Tcl_DeleteHashEntry(entryPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * FitsTcl_Unload --
 *
 *	This is a package unloading initialization procedure, which is called
 *	by Tcl when this package is to be unloaded from an interpreter.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

int
FitsTcl_Unload(
    Tcl_Interp *interp,		/* Interpreter from which the package is to be
				 * unloaded. */
    int flags)			/* Flags passed by the unloading mechanism */
{
    int code, cmdIndex;
    Tcl_Command *cmdTokens = FitsTclInterpToTokens(interp);

    for (cmdIndex=0 ; cmdIndex<MAX_REGISTERED_COMMANDS ; cmdIndex++) {
	if (cmdTokens[cmdIndex] == NULL) {
	    continue;
	}
	code = Tcl_DeleteCommandFromToken(interp, cmdTokens[cmdIndex]);
	if (code != TCL_OK) {
	    return code;
	}
    }

    FitsTclDeleteTokens(interp);

    Tcl_SetVar(interp, "::FitsTcl_detached", ".", TCL_APPEND_VALUE);

    if (flags == TCL_UNLOAD_DETACH_FROM_PROCESS) {
	/*
	 * Tcl is ready to detach this library from the running application.
	 * We should free all the memory that is not related to any
	 * interpreter.
	 */

	FitsTclFreeTokensHashTable();
	Tcl_SetVar(interp, "::FitsTcl_unloaded", ".", TCL_APPEND_VALUE);
    }
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * FitsTcl_SafeUnload --
 *
 *	This is a package unloading initialization procedure, which is called
 *	by Tcl when this package is to be unloaded from an interpreter.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

int
FitsTcl_SafeUnload(
    Tcl_Interp *interp,		/* Interpreter from which the package is to be
				 * unloaded. */
    int flags)			/* Flags passed by the unloading mechanism */
{
    return FitsTcl_Unload(interp, flags);
}

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



