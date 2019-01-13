/*
 *    fitsTcl.c --
 *
 *  This is the main file for defining the Fits objects in fitsTcl...
 *      > fits open, close, info
 *
 */

#include "fitsTclInt.h"
#include <limits.h>

/* on some systems, e.g. linux, SUNs DBL_MAX is in float.h */

#ifndef DBL_MAX
#  include <float.h>
#endif
#ifndef DBL_MIN
#  include <float.h>
#endif

#define LONGLONGDATA 257

/* 
 * ------------------------------------------------------------
 * 
 *    Fits_MainCommand --
 * 
 *    This dispatches all the fits ... commands
 *
 *    Results:
 *       Depends on command line arguments
 *
 *    Side Effects:
 *       Ditto
 *
 * ------------------------------------------------------------
 *
 */

int Fits_MainCommand( ClientData clientData,
		      Tcl_Interp *interp,
		      int argc,
		      Tcl_Obj *const argv[] )
{
   static char *infoString =
      "\n"
      "open    - opens a Fits file\n"
      "close   - closes ALL open Fits files\n"
      "info    - reports on open Fits files: {Handle Filename RWmode CHDU Hdutype}\n"
      "option  - manipulate behavior of fitsTcl\n"
      "version - reports the fitsTcl and cfitsio version numbers\n"
      "free    - free one or more pointers allocated (via load) by fitsTcl\n"
      ;

   int i;
   char *cmdStr;
   
   if ( argc == 1 ) {
      Tcl_SetResult(interp,infoString,TCL_STATIC);
      return TCL_OK;
   }

   cmdStr = Tcl_GetStringFromObj( argv[1], NULL );

   if( !strcmp(cmdStr,"info") ) {
      /*
       * ******************* INFO *******************
       */
      return FitsInfo(interp,argc,argv);

   } else if( !strcmp(cmdStr,"open") ) {
      /*
       * ******************* OPEN ********************
       */
      return FitsCreateObject(interp,argc,argv);

   } else if( !strcmp(cmdStr,"close") ) {
      /*
       * ******************* CLOSE ********************
       */
      for ( i = 0; i < FITS_MAX_OPEN_FILES ; i++ ) {
	 if( FitsOpenFiles[i].fptr ) {
	    if( TCL_OK != 
		Tcl_DeleteCommand(interp,FitsOpenFiles[i].handleName) ) {
	       return TCL_ERROR;
	    }
	    FitsOpenFiles[i].fptr = NULL;
	    FitsOpenFiles[i].handleName = NULL;
	 } 
      }

   } else if( !strcmp(cmdStr,"option") ) {
      /*
       * ******************* OPTION *****************
       */

      int val;
      char *optStr;
      Tcl_Obj *opt[2],*res;

      if( argc > 4 ) {
         Tcl_SetResult(interp, "option ?opt? ?value?", TCL_STATIC);
         return TCL_ERROR;
      }

      if( argc == 2 ) {

         /*  Return a list of all current options and values */
         res = Tcl_NewListObj(0,NULL);

         /*  Repeat these 3 lines for each new option added  */
         opt[0] = Tcl_NewStringObj("wcsSwap", -1);
         opt[1] = Tcl_NewBooleanObj( userOptions.wcsSwap );
         Tcl_ListObjAppendElement(interp, res, Tcl_NewListObj(2,opt));

         Tcl_SetObjResult(interp, res);

      } else if( argc==3 ) {

         /*  Return single option value  */
         optStr = Tcl_GetStringFromObj( argv[2], NULL );

         if( !strcmp(optStr,"wcsSwap") ) {
            res = Tcl_NewBooleanObj( userOptions.wcsSwap );
         } else {
            Tcl_SetResult(interp,"Unknown fits option",TCL_STATIC);
            return TCL_ERROR;
         }

         Tcl_SetObjResult(interp, res);

      } else {

         /*  Set an option  */
         optStr = Tcl_GetStringFromObj( argv[2], NULL );

         if( !strcmp(optStr,"wcsSwap") ) {
            Tcl_GetBooleanFromObj(interp, argv[3], &userOptions.wcsSwap);
         } else {
            Tcl_SetResult(interp,"Unknown fits option",TCL_STATIC);
            return TCL_ERROR;
         }
      }

   } else if( !strcmp(cmdStr,"version") ) {
      /*
       * ******************* VERSION *****************
       */
      float cfitsioVersion;
      char buffer[32];

      ffvers(&cfitsioVersion);
      sprintf(buffer,"%s %5.3f", FITSTCL_VERSION, cfitsioVersion);
      Tcl_SetResult(interp, buffer, TCL_VOLATILE);

   } else if( !strcmp(cmdStr,"free") ) {
      /*
       * ******************* FREE *****************
       */
      Tcl_Obj **addList;
      void *databuff;
      int nAdd;

      if( argc == 2 ) {
	 Tcl_SetResult(interp, "free addressList", TCL_STATIC);
	 return TCL_OK;
      }
   
      if( argc>3 ) {
	 Tcl_SetResult(interp, "Too many arguments to free", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      if( Tcl_ListObjGetElements(interp, argv[2], &nAdd, &addList)
	  != TCL_OK ) {
	 Tcl_SetResult(interp, "Cannot parse the address list", TCL_STATIC);
	 return TCL_ERROR;
      }

      while( nAdd-- ) {
	 databuff = fitsTcl_ReadPtrStr( addList[nAdd] );
	 if( !databuff ) {
	    Tcl_SetResult(interp,
			  "Error interpretting pointer address", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 ckfree( (char *) databuff);
      }
      
   } else {
      Tcl_SetResult(interp, "Unknown argument to fits command", TCL_STATIC);
      return TCL_ERROR;
   }
   
   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 *
 * FitsCreateObject --
 *
 *    This opens a new Fits file, and creates the associated command
 *
 *    Results:
 *       A Fits file argv[2] is opened with rwmode argv[3].  If argv[4]
 *       is provided, then an associated object is created named argv[4]
 *       otherwise the object is called fitsFile#, where # is incremented.
 *
 *    Side effects:
 *       Creates a new command, allocates the FPTR, opens the file
 *
 * ------------------------------------------------------------
 */

int FitsCreateObject( Tcl_Interp *interp,
		      int argc,
		      Tcl_Obj *const argv[] )
{
   FitsFD *newFile;
   int status,rwmode,i;
   int isConflict;
   char *objName,tmpStr[16],varHandle[255], *filename;
   fitsfile *fptr;
  
   static char *argList = "fits open filename ?rwmode? ?objName? ";
   static int objCounter=0;

   /* Deal with wrong # of arguments */
  
   if( argc==2 ) {
      Tcl_SetResult(interp, argList, TCL_STATIC);
      return TCL_OK;
   } else if( argc > 5 ) {
      Tcl_AppendResult(interp,"Wrong number of Arguments: expected ",
		       argList, (char *) NULL);
      return TCL_ERROR;
   }
  
   filename = Tcl_GetStringFromObj( argv[2], NULL );

   /* Convert the rwmode, or set to default */
  
   if ( 3 == argc ) {
      rwmode = READWRITE;   /*  1  */
   } else if ( 4 <= argc ) {
      if( Tcl_GetIntFromObj(interp,argv[3],&rwmode) != TCL_OK ) {
	 Tcl_AppendResult(interp,"\nWrong type for rwmode",(char *) NULL);
	 return TCL_ERROR;
      }
   }

   
   /*
    *  Generate an automatic name if one was not given.
    *  Check for conflicts...
    */

   do {
      if( argc == 5 ) {
	 objName = Tcl_GetStringFromObj(argv[4],NULL);
      } else {
	 sprintf(tmpStr,"fitsObj%d",objCounter++);
	 objName = tmpStr;
      }

      isConflict = 0;
      for( i = 0; i < FITS_MAX_OPEN_FILES; i++ ) {
	 if( FitsOpenFiles[i].handleName && 
	     !strcmp(FitsOpenFiles[i].handleName,objName) ) {
	    isConflict = 1;
	    break;
	 }
      }

      if( isConflict && argc==5 ) {
	 Tcl_AppendResult(interp, "Error: Fits Handle: ",
			  Tcl_GetStringFromObj(argv[4],NULL),
			  " already used.", (char*)NULL);
	 return TCL_ERROR;
      }
   } while( isConflict );


   /* Get a file pointer, and try to FFOPEN the file:  */

   status = 0;

   if( rwmode==2 ) {
      /* if file exists, remove it */
      remove( filename );
      /* Get a file pointer for an empty fits file */
      ffinit(&fptr, filename, &status);
      if ( status ) {
	 dumpFitsErrStack(interp, status);
	 return TCL_ERROR;
      }

   } else {
      /* Get a file pointer, if the fits file exists */
      ffopen(&fptr, filename, rwmode, &status);  
      if ( status ) {
	 dumpFitsErrStack(interp, status);
	 return TCL_ERROR;
      }
   }

   /* If we succeeded, then write the new FitsFD structure */

   i = 0;
   while( i<FITS_MAX_OPEN_FILES && FitsOpenFiles[i].fptr!=NULL ) i++;

   if( i>= FITS_MAX_OPEN_FILES ) {
      Tcl_SetResult(interp, "Too many open files.  Max is ", TCL_STATIC);
      sprintf(tmpStr,"%d", FITS_MAX_OPEN_FILES);
      Tcl_AppendResult(interp, tmpStr, (char*)NULL);
      ffclos(fptr,&status);
      return TCL_ERROR;
   }

   newFile           = &FitsOpenFiles[i] ;
   newFile->fileNum  = i;

   newFile->fileName = (char *) ckalloc(strlen(filename)+1);
   if( NULL == newFile->fileName ) {
      Tcl_SetResult(interp,"Error malloc'ing space for fileName",TCL_STATIC);
      return TCL_ERROR;
   }
   strcpy(newFile->fileName, filename);

   newFile->handleName = (char *) ckalloc( strlen(objName) + 1 );
   if ( NULL == newFile->handleName ) {
      Tcl_SetResult(interp,
		    "Error Malloc'ing space for Handle Name", TCL_STATIC);
      ckfree( (char*)newFile->fileName );
      return TCL_ERROR;
   }
   strcpy(newFile->handleName,objName);

   newFile->interp  = interp;
   newFile->fptr    = fptr;
   newFile->rwmode  = rwmode;
   newFile->chdu    = 1;
   newFile->hduType = NOHDU;
   newFile->CHDUInfo.table.loadStatus = 0;

   /*
    * Initialize the hash table for the keywords
    */

   Tcl_InitHashTable(newFile->kwds,TCL_STRING_KEYS);

   /*
    * Load the current extension by moving relative 0 HDUs
    */

   if( rwmode != 2 ) {
      if( fitsMoveHDU(newFile,0,1) != TCL_OK ) {
         fitsCloseFile((ClientData) newFile);
         return TCL_ERROR;
      }
   }

   /* Now create the new Tcl command for this object    */

   Tcl_CreateObjCommand( interp,
                         newFile->handleName,
                         (Tcl_ObjCmdProc*)fitsDispatch,
                         (ClientData) newFile,
                         fitsCloseFile );

   Tcl_SetResult(interp, newFile->handleName, TCL_STATIC);
   return TCL_OK;
}

/*
 * ------------------------------------------------------------
 *
 * fitsCloseFile --
 *
 *    This is the delete procedure for a Fits file object.  
 *
 *  Results: 
 *    It closes the file, unallocates the FPTR, and frees the FitsFD struc
 *
 *  Side Effects:
 *    The whole file is removed from Tcl.
 *
 * ------------------------------------------------------------
 *
 */

void fitsCloseFile(ClientData clientData) 
{
   int status;
   FitsFD *curFile = (FitsFD *) clientData;
   char result[256];
   
   /* Pan Chai, we already free this.. no need to do it again */
   if (curFile->fptr == NULL && curFile->handleName == NULL) return;

   status = 0;
   
   /* Flush the altered keywords */
   fitsFlushKeywords(curFile);
   
   /* now close the File */
   ffclos(curFile->fptr,&status);
   
   if ( status ) {
      sprintf(result, "Error closing Fits file %s\n", curFile->fileName);
      Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
   }
   
   ckfree((char *) curFile->fileName);
   ckfree((char *) curFile->handleName);
   curFile->fptr = NULL;
   curFile->handleName = NULL;
   
   deleteFitsCardList(curFile->comHead);
   deleteFitsCardList(curFile->hisHead);
   
   freeCHDUInfo(curFile);
}

/* 
 * ------------------------------------------------------------
 * 
 *    FitsInfo --
 * 
 *    This gives info on the open FITS files - the command fits info...
 *
 *    Results:
 *       For each file - HANDLE FILENAME RWMODE CHDU HDUTYPE
 *
 *    Side Effects:
 *       Ditto
 *
 * ------------------------------------------------------------
 *
 */

int FitsInfo( Tcl_Interp *interp,
	      int argc,
	      Tcl_Obj *const argv[] )
{
   int i, gotit = 0;
   int argc2;
   char **argv2;
   char strBuff[16];
   Tcl_DString resultStr,regExpStr;
   
   Tcl_DStringInit(&regExpStr);
   
   if( argc != 2 ) {
      argc2 = argc-2;
      argv2 = (char **) ckalloc( argc2 * sizeof( char *) );
      for( i=0; i<argc2; i++ )
	 argv2[i] = Tcl_GetStringFromObj( argv[i+2], NULL );
      if ( TCL_OK != fitsMakeRegExp(interp, argc2, argv2, &regExpStr, 0)) {
	 Tcl_DStringFree(&regExpStr);
	 ckfree( (char *)argv2 );
	 return TCL_ERROR;
      }
      ckfree( (char *)argv2 );
   }
   
   Tcl_DStringInit(&resultStr);
   for ( i = 0; i < FITS_MAX_OPEN_FILES; i++ ) {
      if( FitsOpenFiles[i].fptr != NULL &&
	  (argc==2 || Tcl_RegExpMatch( interp,FitsOpenFiles[i].handleName,
				       Tcl_DStringValue(&regExpStr) )==1) ) {
	 Tcl_DStringStartSublist(&resultStr);
	 Tcl_DStringAppendElement(&resultStr,FitsOpenFiles[i].handleName);
	 Tcl_DStringAppendElement(&resultStr,FitsOpenFiles[i].fileName);
	 sprintf(strBuff,"%-d",FitsOpenFiles[i].rwmode);
	 Tcl_DStringAppendElement(&resultStr,strBuff);
	 sprintf(strBuff,"%-d",FitsOpenFiles[i].chdu);
	 Tcl_DStringAppendElement(&resultStr,strBuff);
	 sprintf(strBuff,"%-d",FitsOpenFiles[i].hduType);
	 Tcl_DStringAppendElement(&resultStr,strBuff);
	 Tcl_DStringEndSublist(&resultStr);
	 gotit++;
      }
   }
   
   if (! gotit ) {
      if ( 2 == argc ) {
	 Tcl_SetResult(interp, "No open files found", TCL_STATIC);
      } else {
	 Tcl_DStringAppend(&regExpStr,
			   " does not match any open file handle",-1);
	 Tcl_DStringResult(interp,&regExpStr);
      }
      Tcl_DStringFree(&resultStr);
      Tcl_DStringFree(&regExpStr);
      return TCL_ERROR;
   }
   
   Tcl_DStringResult(interp,&resultStr);
   Tcl_DStringFree(&regExpStr);
   return TCL_OK;
}

/* 
 * ------------------------------------------------------------
 * 
 *    fitsPtr2Lst --
 * 
 *    This converts a pointer to an array to a TCL list
 *
 *    Results:
 *         dataList
 *
 * ------------------------------------------------------------
 */

int fitsPtr2Lst(ClientData clientData, Tcl_Interp *interp,
		int argc, Tcl_Obj *const argv[])
{
   Tcl_Obj *dataLst;
   int dataType, naxis;
   long nelem, naxes[10];
   void *thePtr;
   
   if( argc == 1 ) {
      Tcl_SetResult(interp, "ptr2lst addressPtr dataType naxes", TCL_STATIC);
      return TCL_OK;
   }
   
   if( argc != 4 ) {
      Tcl_SetResult(interp, "ptr2lst addressPtr dataType naxes", TCL_STATIC);
      return TCL_ERROR;
   }
   
   thePtr = fitsTcl_ReadPtrStr( argv[1] );
   if( !thePtr ) {
      Tcl_SetResult( interp, "Unable to interpret pointer string",
		     TCL_STATIC );
      return TCL_ERROR;
   }
   
   Tcl_GetIntFromObj( interp, argv[2], &dataType );
   
   fitsTcl_GetDims( interp, argv[3], &nelem, &naxis, naxes );
   
   dataLst = fitsTcl_Ptr2Lst( interp, thePtr, NULL, dataType, nelem );
   Tcl_SetObjResult( interp, dataLst );

   return TCL_OK;
}


/* 
 * ------------------------------------------------------------
 * 
 *    fitsLst2Ptr --
 * 
 *    Convert a TCL list to an array in memory
 *
 *    Results:
 *         dataPtr dataType Dims
 *
 * ------------------------------------------------------------
 */

int fitsLst2Ptr(ClientData clientData, Tcl_Interp *interp,
		int argc, Tcl_Obj *const argv[])
{
   void *dataPtr;
   int  dataType, naxis;
   long nelem, ntodo, naxes[10];
   char ptrStr[16];
   Tcl_Obj *res, *resElem[3];
   
   if( argc == 1 ) {
      Tcl_SetResult(interp, "lst2ptr dataList ?dataType? ?naxes?",
		    TCL_STATIC);
      return TCL_OK;
   }
   
   if( argc < 2 || argc > 4 ) {
      Tcl_SetResult(interp, "lst2ptr dataList ?dataType? ?naxes?",
		    TCL_STATIC);
      return TCL_ERROR;
   }
   
   if( argc>2 )
      Tcl_GetIntFromObj( interp, argv[2], &dataType );
   else
      dataType = DOUBLE_DATA;
   
   dataPtr = fitsTcl_Lst2Ptr( interp, argv[1], dataType, &ntodo, NULL );
   
   if( argc>3 ) {
      fitsTcl_GetDims( interp, argv[3], &nelem, &naxis, naxes );
      if( ntodo != nelem ) {
	 Tcl_SetResult(interp, "List dimensions not same size as list",
		       TCL_STATIC);
	 ckfree( (char *)dataPtr );
	 return TCL_ERROR;
      }
   } else {
      nelem    = ntodo;
      naxis    = 1;
      naxes[0] = ntodo;
   }
   
   sprintf(ptrStr, PTRFORMAT, dataPtr);
   resElem[0] = Tcl_NewStringObj( ptrStr, -1 );
   resElem[1] = Tcl_NewIntObj( dataType );
   fitsTcl_SetDims( interp, resElem+2, naxis, naxes );
   
   res = Tcl_NewListObj( 3, resElem );
   Tcl_SetObjResult(interp, res);

   return TCL_OK;
}

/***********************************************************************
 *                   Implement some utility routines
 ***********************************************************************/

int fitsRange( ClientData clientData,
               Tcl_Interp *interp,
               int argc,
               Tcl_Obj *const argv[] )
{
   char *rangeStr, errMsg[256], *opt;
   int numInt, *range, maxInt, i;
   long numElem;

   if( argc==2 ) {
      Tcl_SetResult( interp, "Usage: range count ranges maxValue",
                     TCL_STATIC );
      return TCL_OK;
   }

   opt = Tcl_GetStringFromObj( argv[1], NULL );
   if( !strcmp( "count", opt ) ) {

      if( argc!=4 ) {
         Tcl_SetResult( interp, "Usage: range count ranges maxValue",
                        TCL_STATIC );
         return TCL_ERROR;
      }

      rangeStr = Tcl_GetStringFromObj( argv[2], NULL );
      if( Tcl_GetIntFromObj( interp, argv[3], &maxInt )
          != TCL_OK ) {
         Tcl_AppendResult( interp,
                           "Unable to read maxValue parameter",
                           (char *)NULL );
         return TCL_ERROR;
      }

      numInt = fitsParseRangeNum(rangeStr)+1;
      range = (int *) malloc (numInt*2*sizeof(int));

      if( fitsParseRange( rangeStr, &numInt, range, numInt,
                          1, maxInt, errMsg )
          != TCL_OK ) {
         Tcl_SetResult(interp, "Error parsing range:\n", TCL_STATIC);
         Tcl_AppendResult(interp, errMsg, (char*)NULL);
         return TCL_ERROR;
      }

      numElem = 0;
      for( i=0; i<numInt; i++ ) {
         numElem += range[i*2+1] - range[i*2] + 1;
      }
      Tcl_SetObjResult( interp, Tcl_NewLongObj( numElem ) );

   } else {

      Tcl_SetResult(interp, "Unknown range option", TCL_STATIC);
      return TCL_ERROR;

   }
   return TCL_OK;
}


/***********************************************************************
 *                   Implement a vexpr command
 ***********************************************************************/

#include "eval_defs.h"

static struct {
   Tcl_Interp *interp;
   char       *callback;
   long       nrows;
} vexprInfo;

static int       fitsGetData   ( char *dataName, void *itslval );
static Tcl_Obj  *fitsGetTclData( char *dataName );
static int  fitsGetDataCallback( char *dataName, int *argc, Tcl_Obj ***argv );
static int  fitsEvaluateExpr( char *expr );
static void fitsExprCleanup ( void );

/* 
 * ------------------------------------------------------------
 * 
 *    fitsExpr --
 * 
 *    This performs vector arithmetic on a given expression
 *
 *    Results:
 *         dataList dataType Dims
 *    or   dataPtr  dataType Dims
 *
 * ------------------------------------------------------------
 */

int fitsExpr(ClientData clientData, Tcl_Interp *interp,
	     int argc, Tcl_Obj *const argv[])
{
   char *strArg, strBuff[80];
   long ntodo;
   int len, i, constant, dataType;
   int argPos;
   int returnList;
   Node *result;
   Tcl_Obj *answer, *res, *dims, *type;
   Tcl_DString expr;
   union {
      LONGLONG *Llong;
      double *Dbl;
      int    *Int;
      unsigned char *Byte;
   } ptr, ptr2;
   char *undef;

   if( argc == 1 ) {
      Tcl_SetResult(interp,"usage: vexpr ?-use dataFctn? get|load {expression}",
		    TCL_STATIC);
      return TCL_OK;
   }

   returnList         = 1;
   vexprInfo.interp   = interp;
   vexprInfo.callback = NULL;

   /*****************************************************************/
   /*  Check for any command options such as...                     */
   /*  ...a callback function is supplied for locating variables    */
   /*  ...flag to indicate that this should create/return a pointer */
   /*****************************************************************/

   argPos = 1;
   strArg = Tcl_GetStringFromObj( argv[argPos++], NULL );

   while( argPos<argc ) {
      if( !strcmp( strArg, "-use" ) && argPos+1<argc ) {
	 vexprInfo.callback = Tcl_GetStringFromObj( argv[argPos++], &len );
      } else if( !strcmp( strArg, "-ptr" ) ) {
	 returnList = 0;
      } else
	 break;
      strArg = Tcl_GetStringFromObj( argv[argPos++], NULL );
   }

   if( argPos > argc ) {
      Tcl_SetResult(interp,"usage: vexpr ?-ptr? ?-use dataFctn? expression",
		    TCL_STATIC);
      return TCL_ERROR;
   }

   /*******************************/
   /*   Read-in the expression    */
   /*******************************/

   Tcl_DStringInit  ( &expr );
   Tcl_DStringAppend( &expr, strArg, -1 );
   while( argPos<argc )
      Tcl_DStringAppend( &expr,
			 Tcl_GetStringFromObj(argv[argPos++], NULL),
			 -1 );

   /*******************************/
   /*   Evaluate the expression   */
   /*******************************/

   if( fitsEvaluateExpr( Tcl_DStringValue(&expr) ) != TCL_OK ) {
      Tcl_DStringFree( &expr );
      return TCL_ERROR;
   }
   Tcl_DStringFree( &expr );
   result = gParse.Nodes + gParse.resultNode;

   /*************************************/
   /*   Copy results into data array    */
   /*************************************/

   answer = Tcl_NewListObj(0,NULL);

   if( result->operation==CONST_OP ) {
      constant = 1; 
      ntodo    = 1;
      dims     = Tcl_NewIntObj( 1 );
   } else {
      constant = 0;
      ntodo    = result->value.nelem * vexprInfo.nrows;
      fitsTcl_SetDims( interp, &dims,
		       result->value.naxis, result->value.naxes );
      if( vexprInfo.nrows>1 )
	 Tcl_ListObjAppendElement( interp, dims,
				   Tcl_NewIntObj( vexprInfo.nrows ) );
   }

   /*  Identify the fitsTcl DataType of result  */

   switch( result->type ) {
   case LONGLONGDATA:
      dataType = LONGLONG_DATA;
      break;
   case DOUBLE:
      dataType = DOUBLE_DATA;
      break;
   case LONG:
      dataType = INT_DATA;
      if( !constant && sizeof(int) != sizeof(long) ) {
	 /*  Demote long array to int  */
	 long *lPtr;
	 lPtr    = (long *)result->value.data.ptr;
	 ptr.Int = (int  *)result->value.data.ptr;
	 for( i=0; i<ntodo; i++, lPtr++, ptr.Int++ )
	    *ptr.Int = ( *lPtr==LONG_MAX ? INT_MAX : (int)*lPtr );
      }
      break;
   case BOOLEAN:
      dataType = BYTE_DATA;
      break;
   default:
      Tcl_SetResult( interp, "Unsupported expression type", TCL_STATIC);
      fitsExprCleanup();
      return TCL_ERROR;
   }
   type = Tcl_NewIntObj( dataType );

   /*  Build answer in appropriate format  */

   if( returnList ) {

      if( constant ) {
	 switch( dataType ) {
	 case LONGLONG_DATA:
	    Tcl_ListObjAppendElement( interp, answer,
				      Tcl_NewStringObj( result->value.data.str, -1) );
	    break;

	 case DOUBLE_DATA:
	    Tcl_ListObjAppendElement( interp, answer,
				      Tcl_NewDoubleObj( result->value.data.dbl ) );
	    break;

	 case INT_DATA:
	    Tcl_ListObjAppendElement( interp, answer,
				      Tcl_NewIntObj( (int)result->value.data.lng ) );
	    break;

	 case BYTE_DATA:
	    Tcl_ListObjAppendElement( interp, answer,
				      Tcl_NewIntObj( (int)result->value.data.log ) );
	    break;
	 }
      } else {
	 answer = fitsTcl_Ptr2Lst( interp, result->value.data.ptr,
				   result->value.undef, dataType, ntodo );
      }

   } else {

      undef   = result->value.undef;
      ptr.Dbl = result->value.data.dblptr;

      switch( dataType ) {

      case LONGLONG_DATA:
	 ptr2.Llong = (LONGLONG *) ckalloc( ntodo * sizeof(LONGLONG) );
	 if( constant )
	    ptr2.Llong[0] = fitsTcl_atoll(result->value.data.str);
	 else
	    for( i=0; i<ntodo; i++ ) {
	       ptr2.Llong[i] = ( undef[i] ? LONGLONG_MAX : ptr.Llong[i] );
	    }
	 break;

      case DOUBLE_DATA:
	 ptr2.Dbl = (double *) ckalloc( ntodo * sizeof(double) );
	 if( constant )
	    ptr2.Dbl[0] = result->value.data.dbl;
	 else
	    for( i=0; i<ntodo; i++ ) {
	       ptr2.Dbl[i] = ( undef[i] ? DBL_MAX : ptr.Dbl[i] );
	    }
	 break;

      case INT_DATA:
	 ptr2.Int = (int *) ckalloc( ntodo * sizeof(int) );
	 if( constant )
	    ptr2.Int[0] = result->value.data.lng;
	 else
	    for( i=0; i<ntodo; i++ )
	       ptr2.Int[i] = ( undef[i] ? INT_MAX : ptr.Int[i] );
	 break;

      case BYTE_DATA:
	 ptr2.Byte = (unsigned char *) ckalloc( ntodo * sizeof(char) );
	 if( constant )
	    ptr2.Byte[0] = result->value.data.log;
	 else
	    for( i=0; i<ntodo; i++ )
	       ptr2.Byte[i] = ( undef[i] ? UCHAR_MAX : ptr.Byte[i] );
	 break;
      }

      sprintf(strBuff,PTRFORMAT, ptr2.Dbl);
      Tcl_ListObjAppendElement( interp, answer,
				Tcl_NewStringObj( strBuff, -1 ) );
   }

   if( result->operation>0 ) {
      free( result->value.data.ptr );
   }
   fitsExprCleanup();

   if( vexprInfo.callback || !returnList ) {
      res = Tcl_NewListObj( 0, NULL );
      Tcl_ListObjAppendElement( interp, res, answer );
      Tcl_ListObjAppendElement( interp, res, type   );
      Tcl_ListObjAppendElement( interp, res, dims   );
   } else {
      res = answer;
   }

   Tcl_SetObjResult(interp,res);
   return TCL_OK;
}

static void fitsExprCleanup( void )
{
   int i;

   for( i=0; i<gParse.nCols; i++ ) {
      ckfree( (char *)gParse.varData[i].data  );
      ckfree( (char *)gParse.varData[i].undef );
   }
   ckfree( (char *)gParse.varData );
   free  ( (char *)gParse.Nodes   );
   gParse.nCols = 0;
}

static int fitsEvaluateExpr( char *expr )
{
   int lexpr;
   Tcl_Interp *interp = vexprInfo.interp;

   /*************************************/
   /*  Initialize the Parser structure  */
   /*************************************/

   gParse.def_fptr   = NULL;
   gParse.compressed = 0;
   gParse.nCols      = 0;
   gParse.colData    = NULL;
   gParse.varData    = NULL;
   gParse.getData    = fitsGetData;
   gParse.loadData   = NULL;
   gParse.Nodes      = NULL;
   gParse.nNodesAlloc= 0;
   gParse.nNodes     = 0;
   gParse.status     = 0;

   /*  Copy expression into parser... read from file if necessary  */

   if( expr[0]=='@' ) {
      if( ffimport_file( expr+1, &gParse.expr, &gParse.status ) ) {
	 dumpFitsErrStack( interp, gParse.status );
	 return TCL_ERROR;
      }
      lexpr = strlen(gParse.expr);
   } else {
      lexpr = strlen(expr);
      gParse.expr = (char*)malloc( (lexpr+2)*sizeof(char));
      strcpy(gParse.expr,expr);
   }
   strcat(gParse.expr + lexpr,"\n");
   gParse.index    = 0;
   gParse.is_eobuf = 0;

   /*  Parse the expression, building the Nodes and determining  */
   /*  which columns are needed and what data type is returned   */

   vexprInfo.nrows = 0;
   ffrestart(NULL);
   if( ffparse() ) {
      dumpFitsErrStack( interp, PARSE_SYNTAX_ERR );
      free  ( gParse.expr );
      fitsExprCleanup();
      return TCL_ERROR;
   }
   free( gParse.expr );

   if( gParse.status ) {
      dumpFitsErrStack( interp, gParse.status );
      fitsExprCleanup();
      return TCL_ERROR;
   }

   if( !gParse.nNodes ) {
      Tcl_AppendResult(interp, "Empty expression", NULL);
      fitsExprCleanup();
      return TCL_ERROR;
   }

   if( vexprInfo.nrows==0 ) vexprInfo.nrows=1;

   gParse.firstDataRow = 1;
   gParse.nDataRows    = gParse.totalRows  = vexprInfo.nrows;

   Evaluate_Parser( 1L, vexprInfo.nrows );

   if( gParse.status ) {
      dumpFitsErrStack( interp, gParse.status );
      fitsExprCleanup();
      return TCL_ERROR;
   }

   return TCL_OK;
}

static int fitsGetData( char *dataName, void *itslval )
{
   FFSTYPE *thelval = (FFSTYPE*)itslval;
   Tcl_Interp *interp;
   Tcl_Obj **argv;
   int argc, nrows, datatype, naxis, i, nCol, type;
   int isPtr;
   long nelem, ntodo, naxes[MAXDIMS];
   union {
      unsigned char  *byte;
      short          *shrt;
      int            *iptr;
      long           *lng;
      float          *flt;
      double         *dbl;
      LONGLONG       *llong;
      void           *ptr;
   } ptrs;
   char *undef;
   DataInfo *variable;

   interp = vexprInfo.interp;

   /*  Get Data from Callback Function  */

   if( fitsGetDataCallback( dataName, &argc, &argv ) != TCL_OK )
      return pERROR;

   /*  Read and check list dimensions  */

   Tcl_GetIntFromObj( interp, argv[argc-2], &datatype             );
   fitsTcl_GetDims  ( interp, argv[argc-1], &nelem, &naxis, naxes );

   if( argc == 3 ) {
      isPtr = 0;
      ptrs.ptr = fitsTcl_Lst2Ptr( interp, argv[0], datatype, &ntodo, &undef );
   } else {
      isPtr = 1;
      ntodo = nelem;
      ptrs.ptr = fitsTcl_ReadPtrStr( argv[1] );
      if( !ptrs.ptr ) {
	 Tcl_SetResult( interp, "Unable to read pointer string", TCL_STATIC );
	 gParse.status = PARSE_SYNTAX_ERR;
	 return pERROR;
      }
      undef = (char *)ckalloc( ntodo * sizeof(char) );
   }

   if( nelem != ntodo ) {
      Tcl_ResetResult( interp );
      Tcl_AppendResult( interp, "Data dimensions of '", dataName,
			"' do not multiply out to its vector length\n", NULL );
      gParse.status = PARSE_SYNTAX_ERR;
      ckfree( (char *)ptrs.ptr );
      ckfree( (char *)undef    );
      return pERROR;
   }
   if( naxis==1 )
      nrows = 1;
   else
      nrows = naxes[--naxis];
   nelem /= nrows;

   if( ntodo == 1 ) {

      /*   Received a CONSTANT   */

      switch( datatype ) {

      case LONGLONG_DATA:
#ifdef __WIN32__
         sprintf(thelval->str, "%I64d", ptrs.llong[0]);
#else
         sprintf(thelval->str, "%lld", ptrs.llong[0]);
#endif
	 type = LONGLONGDATA;
	 break;

      case DOUBLE_DATA:
	 thelval->dbl = ptrs.dbl[0];
	 type = DOUBLE;
	 break;

      case FLOAT_DATA:
	 thelval->dbl = ptrs.flt[0];
	 type = DOUBLE;
	 break;

      case INT_DATA:
	 thelval->lng = ptrs.iptr[0];
	 type = LONG;
	 break;

      case SHORTINT_DATA:
	 thelval->lng = ptrs.shrt[0];
	 type = LONG;
	 break;

      case BYTE_DATA:
	 thelval->lng = ptrs.byte[0];
	 type = LONG;
	 break;
      }

      if( !isPtr )
	 ckfree( (char *)ptrs.ptr );
      ckfree(    (char *)undef    );

   } else {

      /*   Received a VECTOR   */

      if( vexprInfo.nrows==0 ) {
	 vexprInfo.nrows = nrows;
      } else if( nrows != vexprInfo.nrows ) {
	 Tcl_SetResult( interp, "Vectors of incompatible lengths", TCL_STATIC);
	 gParse.status = PARSE_SYNTAX_ERR;
	 return pERROR;
      }

      /*  Allocate an entry for this variable  */

      nCol = ++gParse.nCols;
      if( gParse.varData ) {
	 gParse.varData  = (DataInfo *) ckrealloc( (char *)gParse.varData,
						   nCol*sizeof(DataInfo) );
      } else {
	 gParse.varData  = (DataInfo *) ckalloc  ( nCol*sizeof(DataInfo) );
      }

      /*  Initialize Data Array for this variable  */

      variable = gParse.varData+(nCol-1);

      strncpy( variable->name, dataName, MAXVARNAME );
      variable->name[MAXVARNAME] = '\0';

      variable->nelem       = nelem;
      variable->naxis       = naxis;
      for( i=0; i<naxis; i++ )
	 variable->naxes[i] = naxes[i];
      variable->undef       = undef;
      variable->data        = ptrs.ptr;
      thelval->lng          = nCol - 1;

      switch( datatype ) {

      case LONGLONG_DATA:
	 variable->type  = LONGLONGDATA;
	 type = COLUMN;
	 if( isPtr ) {  /*  Must make copy and define undef  */
	    LONGLONG *llong = ptrs.llong;
	    ptrs.llong = (LONGLONG *)ckalloc( ntodo * sizeof(LONGLONG) );
	    for( i=0; i<ntodo; i++, llong++, undef++ )
	       ptrs.llong[i] = ( *llong ==LONGLONG_MAX ? (*undef=1, LONGLONG_MAX)
			       : (*undef=0, *llong ) );
	    variable->data = ptrs.ptr;
	 }
	 break;

      case DOUBLE_DATA:
	 variable->type  = DOUBLE;
	 type = COLUMN;
	 if( isPtr ) {  /*  Must make copy and define undef  */
	    double *dbl = ptrs.dbl;
	    ptrs.dbl    = (double *)ckalloc( ntodo * sizeof(double) );
	    for( i=0; i<ntodo; i++, dbl++, undef++ )
	       ptrs.dbl[i] = ( *dbl==DBL_MAX ? (*undef=1, DBL_MAX)
			       : (*undef=0, *dbl ) );
	    variable->data = ptrs.ptr;
	 }
	 break;

      case FLOAT_DATA:
	 variable->type  = DOUBLE;
	 type = COLUMN;
	 do {  /*  Promote array to double  */
	    float *flt = (float  *)ptrs.ptr;
	    ptrs.dbl   = (double *)ckalloc( ntodo * sizeof(double) );
	    if( isPtr ) {
	       for( i=0; i<ntodo; i++, flt++, undef++ )
		  ptrs.dbl[i] = ( *flt==FLT_MAX ? (*undef=1, DBL_MAX)
				  : (*undef=0, (double)*flt ) );
	    } else {
	       for( i=0; i<ntodo; i++, flt++ )
		  ptrs.dbl[i] = ( *flt==FLT_MAX ? DBL_MAX : (double)*flt );
	       ckfree( (char *) variable->data );
	    }
	    variable->data = ptrs.ptr;
	 } while( 0 );
	 break;

      case INT_DATA:
	 variable->type  = LONG;
	 type = COLUMN;
	 if( sizeof(int)!=sizeof(long) || isPtr ) {
	    /*  Promote array to long  */
	    int *iPtr = (int *)ptrs.ptr;
	    ptrs.lng  = (long *)ckalloc( ntodo * sizeof(long) );
	    if( isPtr ) {
	       for( i=0; i<ntodo; i++, iPtr++, undef++ )
		  ptrs.lng[i] = ( *iPtr==INT_MAX ? (*undef=1, LONG_MAX)
				  : (*undef=0, (long)*iPtr ) );
	    } else {
	       for( i=0; i<ntodo; i++, iPtr++ )
		  ptrs.lng[i] = ( *iPtr==INT_MAX ? LONG_MAX : (long)*iPtr );
	       ckfree( (char *) variable->data );
	    }

	    variable->data = ptrs.ptr;
	 }
	 break;

      case SHORTINT_DATA:
	 variable->type  = LONG;
	 type = COLUMN;
	 do {  /*  Promote array to long  */
	    short *sPtr = (short*)ptrs.ptr;
	    ptrs.lng    = (long *)ckalloc( ntodo * sizeof(long) );
	    if( isPtr ) {
	       for( i=0; i<ntodo; i++, sPtr++, undef++ )
		  ptrs.lng[i] = ( *sPtr==SHRT_MAX ? (*undef=1, LONG_MAX)
				  : (*undef=0, (long)*sPtr ) );
	    } else {
	       for( i=0; i<ntodo; i++, sPtr++ )
		  ptrs.lng[i] = ( *sPtr==SHRT_MAX ? LONG_MAX : (long)*sPtr );
	       ckfree( (char *) variable->data );
	    }
	    variable->data = ptrs.ptr;
	 } while( 0 );
	 break;

      case BYTE_DATA:
	 variable->type  = LONG;
	 type = COLUMN;
	 do {  /*  Promote array to long  */
	    unsigned char *bPtr;
	    bPtr     = (unsigned char *)ptrs.ptr;
	    ptrs.lng = (long *)ckalloc( ntodo * sizeof(long) );
	    if( isPtr ) {
	       for( i=0; i<ntodo; i++, bPtr++, undef++ )
		  ptrs.lng[i] = ( *bPtr==UCHAR_MAX ? (*undef=1, LONG_MAX)
				  : (*undef=0, (long)*bPtr ) );
	    } else {
	       for( i=0; i<ntodo; i++, bPtr++ )
		  ptrs.lng[i] = ( *bPtr==UCHAR_MAX ? LONG_MAX : (long)*bPtr );
	       ckfree( (char *) variable->data );
	    }
	    variable->data = ptrs.ptr;
	 } while( 0 );
	 break;
      }

   }
   Tcl_ResetResult( interp );
   return type;
}

static int fitsGetDataCallback( char *dataName, int *argc, Tcl_Obj ***argv)
{
   Tcl_Obj *res, *cmd;

   res = NULL;
   if( vexprInfo.callback ) {
      cmd = Tcl_NewStringObj(vexprInfo.callback, -1);
      Tcl_AppendToObj( cmd, " ", -1 );
      Tcl_AppendToObj( cmd, dataName, -1 );
      if( Tcl_EvalObj( vexprInfo.interp, cmd ) != TCL_OK ) {
	 gParse.status = PARSE_SYNTAX_ERR;
	 return TCL_ERROR;
      }
      res = Tcl_GetObjResult( vexprInfo.interp );
      Tcl_ListObjGetElements( vexprInfo.interp, res, argc, argv );
      if( *argc==0 ) res=NULL;
   }
   if( res==NULL ) {
      res = fitsGetTclData( dataName );
      if( res==NULL )
	 return TCL_ERROR;
      Tcl_ListObjGetElements( vexprInfo.interp, res, argc, argv );
   }

   if( (*argc < 3 || *argc > 4) ||
       (*argc == 4 && strcmp(Tcl_GetStringFromObj((*argv)[0],NULL),"-ptr") ) ) {
      gParse.status = PARSE_SYNTAX_ERR;
      Tcl_SetResult( vexprInfo.interp, "Bad callback function results",
		     TCL_STATIC );
      return TCL_ERROR;
   }

   return TCL_OK;
}

static Tcl_Obj *fitsGetTclData( char *dataName )
{
   /*  Locates TCL variable and returns "data dType dims"   */
   /*     ...  dims is just the length of the list, though  */

   Tcl_Interp *interp;
   Tcl_Obj *var, *name, *res;
   int nelem;

   interp = vexprInfo.interp;

   name = Tcl_NewStringObj( dataName, -1 );
   var  = Tcl_ObjGetVar2( interp, name, NULL, 0 );
   if( var==NULL ) {
      Tcl_SetResult( interp, "Unable to locate variable: ", TCL_STATIC);
      Tcl_AppendResult(interp, dataName, "\n", NULL);
      gParse.status = PARSE_SYNTAX_ERR;
      return NULL;
   }

   res = Tcl_NewListObj(1,&var);
   Tcl_ListObjLength(interp, var, &nelem);
   Tcl_ListObjAppendElement(interp, res, Tcl_NewIntObj(DOUBLE_DATA));
   Tcl_ListObjAppendElement(interp, res, Tcl_NewIntObj(nelem));
   return res;
}


