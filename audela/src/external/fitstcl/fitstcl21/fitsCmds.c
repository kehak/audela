/*
*  fitsCmds.c --
*
*     This holds the handlers for all of the fitsObj commands
*
*/

/*
* ------------------------------------------------------------
* MODIFICATION HISTORY:
*       2004-02-05  Ziqin Pan:
*            Add the following commands:
*             1.    delete row -rowrange rangelist   
*             2.    add column colName colForm ?expr? ?rowrange?
*             3.    select rows -expr expression firstrow nrow
*             
*
*/

#include "fitsTclInt.h"

#define ARGV_STR(x) Tcl_GetStringFromObj(argv[x],NULL)

/*
* ------------------------------------------------------------
*
* fitsDispatch --
*
*    This is the dispatch routine for the Fits objects
*
*   Results:
*      Depends on argv[1].
*
*   Side Effects:
*      Depends on argv[1].
*
* ------------------------------------------------------------
*
*/
int fitsDispatch( ClientData clientData,
                 Tcl_Interp *interp,
                 int argc,
                 Tcl_Obj *const argv[] )
{
   
   static char *commandList =
      "Available commands:\n"
      "close  - close the file and delete this object\n"
      "move ?+/-?n  - move to HDU #n or forward/backward +/-n HDUs\n"
      "dump ?-s/-e/-l?  - return contents of the CHDU's header in various formats\n"
      "info  - get information about the CHDU \n"
      "get   - get various data from CHDU\n"
      "put   - change contents of CHDU: keywords or extension data\n"
      "insert- insert KEYWORDs, COLUMNs, ROWs, or HDUs \n"
      "delete- delete KEYWORDs, COLUMNs, ROWs, or HDUs \n"
      "select- select ROWs \n"
      "load  - load image and table data into variables or pointers \n"
      "free  - free loaded data. **If the address is not the right one\n"
      "          returned from \"load xxx\", a core dump will occur** \n"
      "flush ?clear?  - flush dirty buffers to disk (also clear buffer contents?) \n"
      "copy filename - copy the CHDU to a new file\n"
      "sascii- save extension contents to an ascii file \n"
      "sort  - sort the CHDU according to supplied parameters \n"
      "add   - Append new columns and rows to table.  Column may be filled\n"
      "        with the results of a supplied arithmetic expression\n"
      "append filename - Append current HDU to indicated fits file\n"
      "histogram - Create N-D histogram from table columns\n"
      "smooth - Create a smoothed image from the original image.\n"
      "checksum update|verify - Update or verify checksum keywords of the\n"
      "                         current HDU.  Verify: 1=good, -1=bad, 0=none\n"
      ;
   
   int i, j, status;
   FitsFD *curFile = (FitsFD *) clientData;
   struct {
      char *cmd;
      int tclObjs;
      int (*fct)(FitsFD*,int,Tcl_Obj*const[]);
   } cmdLookup[] = {
      { "close",    1, fitsTcl_close    },
      { "move",     1, fitsTcl_move     },
      { "dump",     1, fitsTcl_dump     },
      { "info",     0, fitsTcl_info     },
      { "get",      0, fitsTcl_get      },
      { "put",      1, fitsTcl_put      },
      { "insert",   0, fitsTcl_insert   },
      { "delete",   0, fitsTcl_delete   },
      { "select",   0, fitsTcl_select   },
      { "load",     0, fitsTcl_load     },
      { "free",     1, fitsTcl_free     },
      { "flush",    1, fitsTcl_flush    },
      { "copy",     1, fitsTcl_copy     },
      { "sascii",   0, fitsTcl_sascii   },
      { "sort",     0, fitsTcl_sort     },
      { "add",      0, fitsTcl_add      },
      { "append",   1, fitsTcl_append   },
      { "histogram",1, fitsTcl_histo    },
      { "create",   1, fitsTcl_create   },
      { "smooth",   1, fitsTcl_smooth   },
      { "checksum", 1, fitsTcl_checksum },
      { "", 0, NULL }
   };
   char *cmd, **args;
   
   /*
   *  If there are no arguments, return the help string
   */
   
   if( argc==1 ) {
      Tcl_SetResult(interp,commandList,TCL_STATIC);
      return TCL_OK;
   }
   
   /*
   *  Search for the command and call its handler
   */
   
   
   cmd = Tcl_GetStringFromObj( argv[1], NULL );
   for( i=0; cmdLookup[i].cmd[0]; i++ ) {
      if( !strcmp( cmdLookup[i].cmd, cmd ) ) {
         
         if( cmdLookup[i].tclObjs ) {
            status = (*cmdLookup[i].fct)(curFile, argc, argv);
         } else {
            
         /*
         *  Convert TCL_OBJs to strings
            */
            
            args = (char **) ckalloc( argc * sizeof(char *) );
            for( j=0; j<argc; j++ ) {
               args[j] = Tcl_GetStringFromObj( argv[j], NULL );
            }
            status = (*cmdLookup[i].fct)(curFile, argc, (Tcl_Obj**)args);
            ckfree( (char*) args );
         }
         
         return status;
      }
   }
   
   /*
   *  NO SUCH COMMAND...  Error
   */
   
   Tcl_SetResult(interp, "Unrecognized command\n", TCL_STATIC);
   Tcl_AppendResult(interp, commandList);
   return TCL_ERROR;
}



/**********************
*
*   Command Handlers....
*
**********************/


/******************************************************************
*                             Close
******************************************************************/

int fitsTcl_close( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   if ( argc != 2 ) {
      Tcl_SetResult(curFile->interp,
         "Wrong number of args: expected fits close",TCL_STATIC);
      return TCL_ERROR;
   }
   if( Tcl_DeleteCommand( curFile->interp, curFile->handleName ) != TCL_OK ) {
      return TCL_ERROR;
   }
   curFile->fptr       = NULL;
   curFile->handleName = NULL;
   return TCL_OK;
}


/******************************************************************
*                             Move
******************************************************************/

int fitsTcl_move( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *moveList = "\n"
      "move nmove - moves the CHDU: \n"
      "             nmove = +- -> relative move, otherwise absolute\n"
      "             returns hdutype\n";
   
   char *pStr;
   int nmove;
   int mSilent=0;
   int status=0;
   
   if ( 3 > argc ) {
      Tcl_SetResult(curFile->interp, moveList, TCL_STATIC);
      return TCL_OK;
   } 
   
   /* Convert the nmove argument */
   
   if( Tcl_GetIntFromObj(curFile->interp,argv[2],&nmove) != TCL_OK ) {
      Tcl_SetResult(curFile->interp,"Wrong type for nmove",TCL_STATIC);
      return TCL_ERROR;
   }
   
   if( argc == 4 ) {
      pStr = Tcl_GetStringFromObj( argv[3], NULL );
      if( !strcmp(pStr, "-s") ) {
         mSilent = 1;
      } else {
         Tcl_SetResult(curFile->interp, "fitsTcl Error: "
            "unkown option: -s for load without read header", TCL_STATIC);
         return TCL_ERROR;
      }
   }
   
   pStr = Tcl_GetStringFromObj( argv[2], NULL );
   if( mSilent ) {
      
      if ( strchr(pStr,'+') ) {
         status = fitsJustMoveHDU(curFile, nmove, 1);
      } else if ( strchr(pStr,'-') ) {
         status = fitsJustMoveHDU(curFile, nmove,-1);
      } else {
         status = fitsJustMoveHDU(curFile, nmove, 0);
      }
      
   } else {
      
      if ( strchr(pStr,'+') ) {
         status = fitsMoveHDU(curFile, nmove, 1);
      } else if ( strchr(pStr,'-') ) {
         status = fitsMoveHDU(curFile, nmove,-1);
      } else {
         status = fitsMoveHDU(curFile, nmove, 0);
      }
      
   }
   
   if ( status ) {
      return TCL_ERROR;
   }
   
   /* Return the hdutype  */
   Tcl_SetObjResult(curFile->interp,
      Tcl_NewIntObj( curFile->hduType ) );
   return TCL_OK;
}


/******************************************************************
*                             Dump
******************************************************************/

int fitsTcl_dump( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   int status;
   char *option;
   
   if( argc == 2 ) {
      
      status = fitsDumpHeader(curFile);
      
   } else {
      
      option = Tcl_GetStringFromObj( argv[2], NULL );
      if( !strcmp("-l",option) ) {
         status = fitsDumpKwdsToList(curFile);
      } else if( !strcmp("-s",option) ) {
         status = fitsDumpHeaderToKV(curFile);
      } else if( !strcmp("-e",option) ) {
         status = fitsDumpHeaderToCard(curFile);
      } else {
         Tcl_SetResult(curFile->interp,
            "Usage: fitsFile dump ?-s/-e/-l?", TCL_STATIC);
         return TCL_ERROR;
      }
      
   }
   
   return status;
}


/******************************************************************
*                             Info
******************************************************************/

int fitsTcl_info( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *infoList = "\n"
      "Available Commands:\n"
      "\n"
      "info chdu    - returns the CHDU\n"
      "info nhdu    - returns the total number of hdu in the file\n"
      "info filesize- returns the size of the file(in unit of 2880 byte)\n"
      "info hdutype - returns the type of the CHDU\n"
      "info imgType - returns the image type of the CHDU \n"
      "info imgdim  - returns the image dimension of the CHDU \n"
      "info ncols   - returns the number of columns in the CHDU\n"
      "info nrows   - returns the number of rows in the CHDU\n"
      "info nkwds   - returns the number of keywords in the CHDU\n"
      "info column ?-exact? ?colNames? \n"
      "               with no argument, lists the columns,\n"
      "               otherwise gives more info about columns in colName\n"
      "            ?-minmax? colName firstElement ?rowRange? \n"
      "               min and max\n"
      "            ?-stat? colName firstElement ?rowRange? \n"
      "               statistics about the indicated column\n"
      "\n";
   
   int i, j, felem, numRange, *range=NULL; 
   int numCols, colTypes[FITS_COLMAX], colNums[FITS_COLMAX], strSize[FITS_COLMAX];
   int status = 0;
   char result[32];
   char tmpStr[3][FLEN_VALUE];  /*  Some general purpose string buffers  */
   char *mrgList[9], *pattern, *tmpStrPtr;
   char errMsg[256], **colList;
   Tcl_DString concatList;
   
   if( argc < 3 ) {
      Tcl_SetResult(curFile->interp, infoList, TCL_STATIC);
      return TCL_OK;
   }
   
   
   /* check if the chdu has been loaded or not */
   
   if( curFile->CHDUInfo.table.loadStatus != 1 ) {
      
      Tcl_SetResult(curFile->interp,
         "You need to load the CHDU first", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   if( !strcmp("chdu",argv[2] ) ) {
      
      sprintf(result,"%d",curFile->chdu);
      Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
      
   } else if( !strcmp("imgType",argv[2]) ) {
      int bitpix = 0;
      int naxis = 0;
      long naxes[9];
      
      fits_get_img_dim(curFile->fptr, &naxis, &status);
      
      status = 0;
      fits_get_img_size(curFile->fptr, naxis, naxes, &status);
      
      status = 0;
      fits_get_img_type(curFile->fptr, &bitpix, &status);
      
      sprintf(result,"%d", bitpix);
      Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
      
   } else if( !strcmp("filesize",argv[2]) ) {
      
      sprintf(result,"%ld",curFile->fptr->Fptr->filesize/2880);
      Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
      
   } else if( !strcmp("hdutype",argv[2]) ) {
      
      switch ( curFile->hduType ) {
      case IMAGE_HDU:
         if( curFile->chdu )
            tmpStrPtr = "Image extension";
         else
            tmpStrPtr = "Primary array";
         break;
      case ASCII_TBL:
         tmpStrPtr = "ASCII Table";
         break;
      case BINARY_TBL:
         tmpStrPtr = "Binary Table";
         break;
      default:
         Tcl_SetResult(curFile->interp, "Unsupported hdu type", TCL_STATIC);
         return TCL_ERROR;
      }
      
      Tcl_SetResult(curFile->interp, tmpStrPtr, TCL_STATIC);
      
   } else if( !strcmp("nhdu", argv[2]) ) {
      int nhdu;
      
      ffthdu(curFile->fptr, &nhdu, &status);
      if( status ) {
         dumpFitsErrStack(curFile->interp, status);
         return TCL_ERROR;
      }
      sprintf(result, "%d", nhdu);
      Tcl_SetResult( curFile->interp, result, TCL_VOLATILE );
      
   } else if( !strcmp("nkwds",argv[2] ) ) {
      
      sprintf(result, "%-d", curFile->numKwds);
      Tcl_SetResult( curFile->interp, result, TCL_VOLATILE );
      
   } else if( !strcmp("ncols",argv[2] ) ) {
      
      if (curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult( curFile->interp,
            "No columns for an Image extension", TCL_STATIC);
         return TCL_ERROR;
      }
      sprintf(result, "%d", curFile->CHDUInfo.table.numCols);
      Tcl_SetResult( curFile->interp, result, TCL_VOLATILE );
      
   } else if( !strcmp("nrows",argv[2] ) ) {
      
      if (curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult( curFile->interp,
            "No rows for an Image extension", TCL_STATIC );
         return TCL_ERROR;
      }
      sprintf(result,"%ld",curFile->CHDUInfo.table.numRows);
      Tcl_SetResult( curFile->interp, result, TCL_VOLATILE );
      
   } else if( !strcmp("column",argv[2] ) ) { 
      
      if( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult( curFile->interp,
            "No Columns in an image extension", TCL_STATIC );
         return TCL_ERROR;
      }
      
      if( argc == 3 ) {
         
      /***********************************
      *  Return a list of column names  *
         ***********************************/
         
         for ( i = 0; i < curFile->CHDUInfo.table.numCols; i++ ) {
            Tcl_AppendElement(curFile->interp,
               curFile->CHDUInfo.table.colName[i]);
         }
         
      } else {
         
      /*******************************************
      *  Return info about one or more columns  *
         *******************************************/
         
         if( !strcmp(argv[3], "-stat") ) {
            
            if ( argc < 5 ) {
               Tcl_SetResult(curFile->interp,
                  "Usage: info column -stat columnName ?felem? ?rows?",
                  TCL_STATIC);
               return TCL_ERROR;
            }
            
            if( argc == 5 ) { 
               felem = 1;
            } else if( Tcl_GetInt(curFile->interp, argv[5], &felem)
               != TCL_OK ) {
               return TCL_ERROR;
            }
            
            if( argc >= 7 ) {
               numRange = fitsParseRangeNum(argv[6])+1;
               range = (int*) malloc(numRange*2*sizeof(int));
               if( fitsParseRange(argv[6],&numRange,range,numRange,
                  1, curFile->CHDUInfo.table.numRows,errMsg) 
                  != TCL_OK ) {
                  Tcl_SetResult(curFile->interp,
                     "Error parsing row range:\n", TCL_STATIC);
                  Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
                  return TCL_ERROR;
               }
            } else {
               numRange = 1;
               range = (int*) malloc(numRange*2*sizeof(int));
               range[0] = 1;
               range[1] = curFile->CHDUInfo.table.numRows ;
            }    
            
            if( fitsTransColList( curFile, argv[4], &numCols,
               colNums, colTypes, strSize) != TCL_OK )
               return TCL_ERROR;	      
            
            if( fitsColumnStatistics(curFile,colNums[0],felem,
               numRange,range) != TCL_OK ) {
               return TCL_ERROR;
            }
            
         } else if( !strcmp(argv[3], "-minmax") ) {
            
            if ( argc < 5 ) {
               Tcl_SetResult(curFile->interp,
                  "Usage: info column -minmax "
                  "columnName ?felem? ?rows?", TCL_STATIC);
               return TCL_ERROR;
            }
            
            if( argc == 5 ) { 
               felem = 1;
            } else if( Tcl_GetInt(curFile->interp, argv[5], &felem)
               != TCL_OK ) {
               return TCL_ERROR;
            } 
            
            if( argc >= 7 ) {
               numRange = fitsParseRangeNum(argv[6])+1;
               range = (int*) malloc(numRange*2*sizeof(int));
               if( fitsParseRange(argv[6],&numRange,range,numRange,
                  1, curFile->CHDUInfo.table.numRows,errMsg) 
                  != TCL_OK ) {
                  Tcl_SetResult(curFile->interp,
                     "Error parsing row range:\n", TCL_STATIC);
                  Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
                  return TCL_ERROR;
               }
            } else {
               numRange = 1;
               range = (int*) malloc(numRange*2*sizeof(int));
               range[0] = 1;
               range[1] = curFile->CHDUInfo.table.numRows ;
            }    
            
            for ( i = 0; i < curFile->CHDUInfo.table.numCols; i++) {
               if( !strcasecmp(argv[4],curFile->CHDUInfo.table.colName[i]) ) {
                  if( fitsColumnMinMax(curFile, i+1, felem, numRange, range)
                     != TCL_OK ) {
                     return TCL_ERROR;
                  }
                  break;
               }
            }
            
         } else if( !strcmp(argv[3], "-exact") ) {
            
         /*************************************************************
         *  Return Info about Columns matching an exact column name  *
            *************************************************************/
            
            if( argc != 5 ) {
               Tcl_SetResult(curFile->interp,
                  "Usage: info column -exact columnNames",
                  TCL_STATIC);
               return TCL_ERROR;
            }
            if( fitsTransColList( curFile, argv[4], &numCols,
               colNums, colTypes, strSize) != TCL_OK )
               return TCL_ERROR;
            
            for ( i = 0; i < numCols; i++ ) {
               j = colNums[i]-1;
               mrgList[0] = curFile->CHDUInfo.table.colName[j];
               mrgList[1] = curFile->CHDUInfo.table.colType[j];
               mrgList[2] = curFile->CHDUInfo.table.colUnit[j];
               mrgList[3] = curFile->CHDUInfo.table.colDisp[j];
               mrgList[4] = curFile->CHDUInfo.table.colFormat[j];
               sprintf(tmpStr[0],  "%d",
                  curFile->CHDUInfo.table.colWidth[j]);
               mrgList[5] = tmpStr[0];
               sprintf(tmpStr[1], "%d",
                  curFile->CHDUInfo.table.colTzflag[j]);
               mrgList[6] = tmpStr[1];
               sprintf(tmpStr[2], "%d",
                  curFile->CHDUInfo.table.colTsflag[j]);
               mrgList[7] = tmpStr[2];
               mrgList[8] = curFile->CHDUInfo.table.colNull[j];
               Tcl_AppendElement(curFile->interp,Tcl_Merge(9,mrgList));
            }
            
         } else if( argc==4 ) {
            
         /***********************************************************
         *  Return Info about Columns matching regular expression  *
            ***********************************************************/
            
            Tcl_DStringInit(&concatList);
            
            if( Tcl_SplitList(curFile->interp, argv[3], &numCols,
               &colList) != TCL_OK ) {
               return TCL_ERROR;
            }
            
            if( fitsMakeRegExp(curFile->interp, numCols, colList,
               &concatList, 1)
               == TCL_ERROR ) {
               Tcl_SetResult(curFile->interp,
                  "Error making up reg expr", TCL_STATIC);
               Tcl_DStringFree(&concatList);
               ckfree((char*)colList);
               return TCL_ERROR;
            }
            ckfree((char*)colList);
            pattern = Tcl_DStringValue(&concatList);
            for ( i = 0; i < curFile->CHDUInfo.table.numCols; i++) {
               strToUpper(curFile->CHDUInfo.table.colName[i], &tmpStrPtr);
               status = Tcl_RegExpMatch(curFile->interp, tmpStrPtr, pattern);
               ckfree( (char*)tmpStrPtr );
               if( status == 1 ) {
                  mrgList[0] = curFile->CHDUInfo.table.colName[i];
                  mrgList[1] = curFile->CHDUInfo.table.colType[i];
                  mrgList[2] = curFile->CHDUInfo.table.colUnit[i];
                  mrgList[3] = curFile->CHDUInfo.table.colDisp[i];
                  mrgList[4] = curFile->CHDUInfo.table.colFormat[i];
                  sprintf(tmpStr[0],  "%d",
                     curFile->CHDUInfo.table.colWidth[i]);
                  mrgList[5] = tmpStr[0];
                  sprintf(tmpStr[1], "%d",
                     curFile->CHDUInfo.table.colTzflag[i]);
                  mrgList[6] = tmpStr[1];
                  sprintf(tmpStr[2], "%d",
                     curFile->CHDUInfo.table.colTsflag[i]);
                  mrgList[7] = tmpStr[2];
                  mrgList[8] = curFile->CHDUInfo.table.colNull[i];
                  Tcl_AppendElement(curFile->interp,Tcl_Merge(9,mrgList));
               } else if( status == -1 ) {
                  Tcl_AppendResult(curFile->interp,"Error, ", pattern,
                     " not a Regular Expression.",
                     (char *) NULL);
                  Tcl_DStringFree(&concatList);
                  return TCL_ERROR;
               }
            }
            Tcl_DStringFree(&concatList);
            
         } else {
            
            Tcl_SetResult(curFile->interp,
               "Usage:\n"
               "      info column ?-exact? colNames \n"
               "                  -minmax  colName firstElement ?rowRange? \n"
               "                  -stat    colName firstElement ?rowRange? \n",
               TCL_STATIC);
            return TCL_ERROR;
            
         }
      }
      
      /*  End of 'info column'  */
      
   } else if( !strcmp("expr", argv[2]) ) {
      
      if( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,"Not a table extension", TCL_STATIC);
         return TCL_ERROR;
      }
      if( argc != 4 ) {
         Tcl_SetResult(curFile->interp, 
            "Usage: info expr exprStr", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( exprGetInfo( curFile, argv[3] ) ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("imgdim", argv[2]) ) {
      
      if ( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image", TCL_STATIC);
         return TCL_ERROR;
      }
      
      Tcl_ResetResult(curFile->interp);
      for (i=0; i < curFile->CHDUInfo.image.naxes; i++) {
         sprintf(tmpStr[0], "%ld", curFile->CHDUInfo.image.naxisn[i]);
         Tcl_AppendElement(curFile->interp, tmpStr[0]);
      }
      
   } else {
      
      Tcl_SetResult(curFile->interp,
         "Unrecognized option to info", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   if (range) free(range); 
   return TCL_OK;
}


/******************************************************************
*                             Get
******************************************************************/

int fitsTcl_get( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *getList = "\n" 
      "Available Commands:\n"
      "get keyword ?keyName?   - displays the keyword(s) keyname\n"
      "                        - keywords are specified by reg. expression\n"
      "get keyword -num keyNum - displays the num th keyword in the CHDU\n"
      "get wcs ?RAcol DECcol?\n"
      "    - return a list of the WCS parameters for either a table or image:\n" 
      "        {xrval yrval xrpix yrpix xinc yinc rot ctype}\n" 
      "      For a table, supply RAcol and DECcol which are column names or \n"
      "      numbers of the RA column and DEC column\n"
      "get header2str          - get header and construct it into a string\n"
      "get dummy2str           - create dummy fits image file and get header and construct it into a string\n"
      "get image ?firstElem? ?numElem?\n"
      "                        - return elements of an image\n"
      "get table ?-c? ?-noformat? ?colList? ?rowList?\n"
      "                        - return the elements rowList from list colList\n"
      "                        - if no rowList is provided, give all rows\n"
      "                        - if no colList is provided, give all columns\n"
      "                        - use colList = * for all columns\n"
      "                        - -c means return each column as a seperate list.\n"
      "get vtable ?-noformat? colname firstelement ?rowList?\n"
      "                        - get the firstelement-th vector element\n"
      "\n";
   
   char Comment[FLEN_COMMENT], Name[FLEN_KEYWORD], Value[FLEN_VALUE];
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int numRange, *range=NULL; 
   Tcl_HashEntry *newEntry;
   Tcl_HashSearch search;
   Tcl_DString concatList, regExpList;
   Tcl_DString ** colDString;
   FitsCardList *curCard;
   Keyword *newKwd;
   char errMsg[256];
   int nmove,i,k,l,n;
   int bycol,niters,fRow;
   int ntodo,felem;
   char ***strValArray;
   char *pattern;
   int status = 0;
   char *header;
   int nkeys;
   
   Tcl_Obj *resObj, **valArray, *listObj, **listArray, *valObj;
   
   listObj = Tcl_NewObj();
   
   if ( argc == 2 ) {
      Tcl_SetResult(curFile->interp, getList, TCL_STATIC);
      return TCL_OK;
   }
   
   if( !strcmp("keyword", argv[2]) ) {
      
      /* GET KEYWORD */
      
      if( argc == 3 ) {
         
         Tcl_DStringInit(&concatList);
         
         newEntry = Tcl_FirstHashEntry(curFile->kwds,&search);
         while ( newEntry ) {
            newKwd = (Keyword *) Tcl_GetHashValue(newEntry);
            Tcl_DStringStartSublist(&concatList);
            Tcl_DStringAppendElement(&concatList,newKwd->name);
            Tcl_DStringAppendElement(&concatList,newKwd->value);
            Tcl_DStringAppendElement(&concatList,newKwd->comment);
            Tcl_DStringEndSublist(&concatList);
            newEntry = Tcl_NextHashEntry(&search);
         }
         Tcl_DStringResult(curFile->interp,&concatList);
         
      } else if( !strcmp(argv[3],"-num") ) {
         
         if ( 5 != argc ) {
            Tcl_SetResult(curFile->interp,
               "Wrong number of args, expected get keyword "
               "-num number", TCL_STATIC);
            return TCL_ERROR;
         }
         
         if( Tcl_GetInt(curFile->interp,argv[4],&nmove) != TCL_OK ) {
            Tcl_AppendResult(curFile->interp,
               "\nWrong type for nmove",(char *) NULL);
            return TCL_ERROR;
         }
         
         /*
         * First look through the comments and the history cards:
         * remember the first card is always a dummy...
         */
         
         curCard = (curFile->hisHead)->next;
         while( curCard ) {
            if ( curCard->pos == nmove ) {
               Tcl_AppendElement(curFile->interp,"HISTORY");
               Tcl_AppendElement(curFile->interp," ");
               Tcl_AppendElement(curFile->interp,curCard->value);
               return TCL_OK;
            }
            curCard = curCard->next;
         }
         
         curCard = (curFile->comHead)->next;
         while( curCard ) {
            if ( curCard->pos == nmove ) {
               Tcl_AppendElement(curFile->interp,"COMMENT");
               Tcl_AppendElement(curFile->interp," ");
               Tcl_AppendElement(curFile->interp,curCard->value);
               return TCL_OK;
            }
            curCard = curCard->next;
         }
         
         newEntry = Tcl_FirstHashEntry(curFile->kwds,&search);
         while( newEntry ) {
            newKwd = (Keyword *) Tcl_GetHashValue(newEntry);
            if ( newKwd->pos == nmove ) {
               Tcl_AppendElement(curFile->interp,newKwd->name);
               Tcl_AppendElement(curFile->interp,newKwd->value);
               Tcl_AppendElement(curFile->interp,newKwd->comment);
               return TCL_OK;
            }
            newEntry = Tcl_NextHashEntry(&search);
         }
         
         /*  The Hashes all failed (maybe duplicate keys in header.  */
         /*  Go directly to file.  */
         ffgkyn( curFile->fptr, nmove, Name, Value, Comment, &status);
         if( status ) {
            dumpFitsErrStack(curFile->interp,status);
            return TCL_ERROR;
         }
         Tcl_AppendElement(curFile->interp,Name);
         Tcl_AppendElement(curFile->interp,Value);
         Tcl_AppendElement(curFile->interp,Comment);
         
      } else {
         
         Tcl_DStringInit(&regExpList);
         
         if( fitsMakeRegExp(curFile->interp, argc-3, argv+3, &regExpList, 1)
            == TCL_ERROR ) {
            Tcl_SetResult(curFile->interp,
               "Error building regular expression", TCL_STATIC);
            Tcl_DStringFree(&regExpList);
            return TCL_ERROR;
         }
         
         pattern = Tcl_DStringValue(&regExpList);
         
         Tcl_DStringInit(&concatList);
         
         niters = 0;
         newEntry = Tcl_FirstHashEntry(curFile->kwds,&search);
         while ( NULL != newEntry ) {
            newKwd = (Keyword *) Tcl_GetHashValue(newEntry);
            status = Tcl_RegExpMatch(curFile->interp,newKwd->name,pattern);
            if ( status == 1 ) {
               niters = 1;
               Tcl_DStringStartSublist(&concatList);
               Tcl_DStringAppendElement(&concatList,newKwd->name);
               Tcl_DStringAppendElement(&concatList,newKwd->value);
               Tcl_DStringAppendElement(&concatList,newKwd->comment);
               Tcl_DStringEndSublist(&concatList);
               newEntry = Tcl_NextHashEntry(&search);
            } else if ( status == -1 ) {
               Tcl_AppendResult(curFile->interp,"The Pattern: ",pattern,
                  " is not a regular expression."
                  ,(char *) NULL);
               Tcl_DStringFree(&concatList);
               Tcl_DStringFree(&regExpList);
               return TCL_ERROR;
            } else {
               newEntry = Tcl_NextHashEntry(&search);
            }
         }
         
         if( !niters ) {
            Tcl_SetResult(curFile->interp,
               "No matching keywords found/or keyword not loaded",
               TCL_STATIC);
            Tcl_DStringFree(&concatList);
            return TCL_ERROR;
         }
         
         Tcl_DStringResult(curFile->interp,&concatList);
      }	
      
   } else if( !strcmp("wcs", argv[2]) ) {
      
      /*  Get WCS  */
      
      if ( curFile->hduType == IMAGE_HDU ) {
         
         /*  Get WCS from Image extension  */
         
         if( argc < 4 || argc > 5 ) {
            Tcl_SetResult(curFile->interp,
               "For image extension use, get wcs", TCL_STATIC);
            return TCL_ERROR;
         }
         
         if ( argc == 5 && !strcmp("-m", argv[3]) ) {
            if( fitsGetWcsMatrix(curFile, 0, NULL, argv[4][0]) != TCL_OK ) {
               return TCL_ERROR;
            }
         } else {
            if( fitsGetWcsPair(curFile,0,0, '\0') != TCL_OK ) {
               return TCL_ERROR;
            }
            
         }
         
      } else {
         
         /*  Get WCS from Table extension  */
         
         int i,j;
         int nCols = 0;
         int getMatrix = 0;
         int columns[FITS_MAXDIMS];
         
         if( argc>4 && !strcmp("-m", argv[3]) ) {
            getMatrix = 1;
            nCols = argc - 5;
            if( nCols<1 ) {
               Tcl_SetResult(curFile->interp,
                  "For table extension use, "
                  "get wcs -m dest Col1 ?Col2 ...?",
                  TCL_STATIC);
               return TCL_ERROR;
            } else if( nCols > FITS_MAXDIMS ) {
               Tcl_SetResult(curFile->interp,
                  "Too many columns to obtain WCS information",
                  TCL_STATIC);
               return TCL_ERROR;
            }
         } else {
            nCols = 2;
            if( argc != 7 ) {
               Tcl_SetResult(curFile->interp,
                  "For table extension use, get wcs -m dest RAcol DecCol",
                  TCL_STATIC);
               return TCL_ERROR;
            }
         }
         
         for( j=0, i=argc-nCols; i<argc; i++,j++ ) {
            
            if( Tcl_GetInt(curFile->interp, argv[i], columns+j) != TCL_OK ) {
               Tcl_ResetResult(curFile->interp);
               if( fitsTransColList( curFile, argv[i],
                  &numCols, colNums, colTypes, strSize)
                  != TCL_OK ) {
                  Tcl_SetResult(curFile->interp,
                     "Unable to read column specifier", TCL_STATIC);
                  return TCL_ERROR;
               }
               if( numCols != 1 ) {
                  Tcl_SetResult(curFile->interp,
                     "Can only have column value", TCL_STATIC);
                  return TCL_ERROR;
               }
               columns[j] = colNums[0];
            }
            
         }
         
         if( getMatrix ) {
            if( fitsGetWcsMatrix(curFile, nCols, columns, argv[4][0]) != TCL_OK ) {
               return TCL_ERROR;
            }
         } else {
            if( fitsGetWcsPair(curFile, columns[0], columns[1], argv[4][0]) != TCL_OK ) {
               return TCL_ERROR;
            }
         }
         
      }
      
   } else if( !strcmp("dummy2str", argv[2]) ) {
      fitsfile *dummyptr;
      int status = 0;
      int bitpix = 8;
      int naxis = 2;
      long naxes[2];
      int columns[FITS_MAXDIMS];
      int *nkeys;
      char **header;
      int i,j;
      int nCols = 0;
      
      Tcl_Obj *data[5];
      naxes[0] = 10;
      naxes[1] = 10;
      
      for( j=0, i=argc-nCols; i<argc; i++,j++ ) {
         
         if( Tcl_GetInt(curFile->interp, argv[i], columns+j) != TCL_OK ) {
            Tcl_ResetResult(curFile->interp);
            if( fitsTransColList( curFile, argv[i],
               &numCols, colNums, colTypes, strSize)
               != TCL_OK ) {
               Tcl_SetResult(curFile->interp,
                  "Unable to read column specifier", TCL_STATIC);
               return TCL_ERROR;
            }
            if( numCols != 1 ) {
               Tcl_SetResult(curFile->interp,
                  "Can only have column value", TCL_STATIC);
               return TCL_ERROR;
            }
            columns[j] = colNums[0];
         }
      }
      
      /* size of histogram is now known, so create temp output file */
      if (ffinit(&dummyptr, "mem://", &status) > 0)
      {
         ffpmsg("failed to create temp output file for dummy fits file");
         return(status);
      }
      
      status = 0;
      /* create output FITS image HDU */
      if (ffcrim(dummyptr, bitpix, naxis, naxes, &status) > 0)
      {
         ffpmsg("failed to create output dummy FITS image");
         return(status);
      }
      
      status = 0;
      /* copy header keywords, converting pixel list WCS keywords to image WCS form */
      if (fits_copy_pixlist2image(curFile->fptr, dummyptr, 9, naxis, columns, &status) > 0)
      {
         ffpmsg("failed to copy pixel list keywords to new dummy header");
         return(status);
      }
      
      status = 0;
      if ( ffhdr2str(dummyptr, 1, (char *)NULL, 0, &header, &nkeys, &status) > 0 ) {
         Tcl_SetResult(curFile->interp, "Failed to collect all the headers.", TCL_STATIC);
         return TCL_ERROR;
      }
      
      /* since this is a dummy header, all relative reference starts with 1 */
      for (i = 0; i < naxis; i++) {
         columns[i] = i + 1;
      }
      
      fitsFileGetWcsMatrix( curFile, dummyptr, naxis, columns, argv[3][0], data);
      
      Tcl_ListObjAppendElement( curFile->interp, listObj, Tcl_NewStringObj(header, -1));
      Tcl_ListObjAppendElement( curFile->interp, listObj, Tcl_NewIntObj( nkeys ) );
      Tcl_ListObjAppendElement( curFile->interp, listObj, Tcl_NewListObj(5,data) );
      Tcl_SetObjResult(curFile->interp, listObj);
      
      ckfree( (char*) header);
      return TCL_OK;
      
   } else if( !strcmp("header2str", argv[2]) ) {
      /* int ffhdr2str( fitsfile *fptr,     I - FITS file pointer                    */
      /*                int exclude_comm,   I - if TRUE, exclude commentary keywords */
      /*                char **exclist,     I - list of excluded keyword names       */
      /*                int nexc,           I - number of names in exclist           */
      /*                char **header,      O - returned header string               */
      /*                int *nkeys,         O - returned number of 80-char keywords  */
      /*                int  *status)       IO - error status                        */
      
      if ( ffhdr2str(curFile->fptr, 1, (char *)NULL, 0, &header, &nkeys, &status) > 0 ) {
         Tcl_SetResult(curFile->interp, "Failed to collect all the headers.", TCL_STATIC);
         return TCL_ERROR;
      }
      
      Tcl_ListObjAppendElement( curFile->interp, listObj, Tcl_NewStringObj(header, -1));
      Tcl_ListObjAppendElement( curFile->interp, listObj, Tcl_NewIntObj( nkeys ) );
      Tcl_SetObjResult(curFile->interp, listObj);
      
      ckfree( (char*) header);
      return TCL_OK;
      
   } else if( !strcmp("imgwcs", argv[2]) ) {
      
      /*  Get IMGWCS  */
      
      if ( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsGetWcsPair(curFile,0,0,'\0') != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("colwcs", argv[2]) ) {
      
      /*  Get COLWCS  */
      
      int ranum = 0;
      int decnum = 0;
      
      if( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      if( argc != 5 ) {
         Tcl_SetResult(curFile->interp,
            "get colwcs RAcol DECcol", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetInt(curFile->interp, argv[3], &ranum) != TCL_OK ) {
         Tcl_ResetResult(curFile->interp);
         if( fitsTransColList( curFile, argv[3],
            &numCols, colNums, colTypes, strSize)
            != TCL_OK ) {
            Tcl_SetResult(curFile->interp,
               "Unable to read RAcol", TCL_STATIC);
            return TCL_ERROR;
         }
         if( numCols != 1 ) {
            Tcl_SetResult(curFile->interp,
               "Can only have 1 RAcol value", TCL_STATIC);
            return TCL_ERROR;
         }
         ranum = colNums[0];
      }
      
      if( Tcl_GetInt(curFile->interp, argv[4], &decnum) != TCL_OK ) {
         Tcl_ResetResult(curFile->interp);
         if( fitsTransColList( curFile, argv[4],
            &numCols, colNums, colTypes, strSize)
            != TCL_OK ) {
            Tcl_SetResult(curFile->interp,
               "Unable to read DecCol", TCL_STATIC);
            return TCL_ERROR;
         }
         if( numCols != 1 ) {
            Tcl_SetResult(curFile->interp,
               "Can only have 1 DecCol value", TCL_STATIC);
            return TCL_ERROR;
         }
         decnum = colNums[0];
      }
      
      if( fitsTableGetWcsOld(curFile, ranum, decnum) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("image", argv[2]) ) {
      
      long fElem, nElem;
      
      if( argc < 3 || argc > 5 ) {
         Tcl_SetResult(curFile->interp,
            "get image firstElem numElem", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc>3 ) {
         fElem = atol( argv[3] );
         if( argc>4 ) {
            nElem = atol( argv[4] );
         } else {
            nElem = 1;
         }
      } else {
         fElem = 1;
         nElem = 1;
         i = curFile->CHDUInfo.image.naxes;
         while( i-- )
            nElem *= curFile->CHDUInfo.image.naxisn[i];
      }
      
      if( imageBlockLoad_1D(curFile, fElem, nElem) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if ( !strcmp("imageblock", argv[2]) ) {
      
      /*  GET IMAGE in blocks  */
      
      long slice = 1;
      long cslice = 1;
      
      if( argc < 8 || argc > 10 ) {
         Tcl_SetResult(curFile->interp,
            "FitsHandle get imageblock arrayName firstRow "
            "numRows firstCol numCols ?2D image slice? ?cube slice?", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image.", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc > 8 ) 
         slice = atol(argv[8]);
      
      if( argc > 9 ) 
         cslice = atol(argv[9]);
      
      if( imageBlockLoad(curFile, argv[3], atol(argv[4]), atol(argv[5]),
         atol(argv[6]), atol(argv[7]), slice, cslice )
         != TCL_OK ) {
         return TCL_ERROR;  /*  Sets own error message  */
      }
      
   } else if( !strcmp("table",argv[2] ) ) {
      
      int idx, format;
      
      /* GET TABLE */
      
      if ( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( curFile->CHDUInfo.table.loadStatus != 1 ) {
         Tcl_SetResult(curFile->interp,
            "Need to load the hdu first", TCL_STATIC);
         return TCL_ERROR;
      }
      
      /*
      * Strip off the "-c" flag if present... 
      */
      
      bycol = 0;
      format = 1;
      idx = 3;
      while( idx < argc && argv[idx][0]=='-' ) {
         if( !strcmp(argv[idx],"-c") ) {
            bycol = 1;
         } else if( !strcmp(argv[idx],"-noformat") ) {
            format = 0;
         } else {
            break;
         }
         idx++;
      }
      
      if( argc-idx > 2 ) {
         Tcl_SetResult(curFile->interp,
            "Wrong number of arguments, need "
            "'get table ?-c? ?-noformat? ?columns? ?rows?'",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      /* If no colList is given, or it is "*", use all the columns... */ 
      
      if( TCL_OK !=
         fitsTransColList( curFile, ( argc==idx ? "*" : argv[idx] ),
         &numCols, colNums, colTypes, strSize) )
         return TCL_ERROR;
      
         /* 
         * Get the Row range parameter 
      */
      
      idx++;
      if( argc <= idx ) { 
         numRange    = 1;
         range = (int*) malloc(numRange*2*sizeof(int));
         range[0] = 1;
         range[1] = curFile->CHDUInfo.table.numRows;
      } else {
         numRange =fitsParseRangeNum(argv[idx])+1;
         range = (int*) malloc(numRange*2*sizeof(int));
         if( fitsParseRange( argv[idx], &numRange, range, numRange,
            1, curFile->CHDUInfo.table.numRows, errMsg ) 
            != TCL_OK ) {
            Tcl_SetResult(curFile->interp,
               "Error parsing row range:\n", TCL_STATIC);
            Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
            return TCL_ERROR;
         }
      }
      
      /* Now get the rows... */
      
      if ( bycol ) {
         listArray = (Tcl_Obj**) ckalloc( numCols * sizeof(Tcl_Obj*) );
         for( k=0; k<numCols; k++ )
            listArray[k] = Tcl_NewListObj( 0, NULL );
      } else {
         valArray = (Tcl_Obj**) ckalloc( numCols * sizeof(Tcl_Obj*) );
         listObj = Tcl_NewListObj( 0, NULL );
      }
      
      for (i = 0; i < numRange; i++ ) {
         fRow  = range[i*2];
         while( fRow <= range[i*2+1] ) {
            ntodo  = range[i*2+1] - fRow + 1;
            if( ntodo>FITS_CHUNKSIZE ) ntodo = FITS_CHUNKSIZE;
            status = tableBlockLoad( curFile, "", 1, fRow, ntodo,
               -99, numCols, colNums, format );
            
            if( status != TCL_OK )
               break;
            fRow += ntodo;
            
            resObj = Tcl_GetObjResult( curFile->interp );
            if ( bycol ) {
               for( k = 0; k < numCols; k++) {
                  Tcl_ListObjIndex( curFile->interp, resObj,
                     k, &listObj );
                  Tcl_ListObjAppendList( curFile->interp,
                     listArray[k],
                     listObj );
               }
            } else {
               Tcl_ListObjGetElements( curFile->interp, resObj,
                  &n, &listArray );
               for ( l = 0; l < ntodo; l++) {
                  for( k = 0; k < numCols; k++) {
                     Tcl_ListObjIndex( curFile->interp, listArray[k], l,
                        valArray+k );
                  }
                  Tcl_ListObjAppendElement( curFile->interp, listObj,
                     Tcl_NewListObj(numCols, valArray) );
               }
            }
         }
      } 
      
      if( status ) {
         
         if ( bycol ) {
            ckfree( (char*) listArray );
         } else {
            ckfree( (char*) valArray );
         }
         
      } else {
         
         if ( bycol ) {
            Tcl_SetObjResult( curFile->interp,
               Tcl_NewListObj( numCols, listArray ) );
         } else {
            Tcl_SetObjResult( curFile->interp, listObj );
         }
         
      }
      
      if( status ) return TCL_ERROR;
      
   } else if( !strcmp("vtable",argv[2]) ) {
      
      int idx, format;
      
      /* GET vector from the TABLE */
      
      if( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( curFile->CHDUInfo.table.loadStatus != 1 ){
         Tcl_SetResult(curFile->interp,
            "Need to load the hdu first", TCL_STATIC);
         return TCL_ERROR;
      }
      
      idx = 3;
      format = 1;
      if( idx<argc && !strcmp("-noformat",argv[idx]) ) {
         format = 0;
         idx++;
      }
      
      if( argc-idx < 2 ) {
         Tcl_SetResult(curFile->interp,
            "Wrong number of arguments, need "
            "'get vtable ?-noformat? column felem ?rowList?'",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      
      if( fitsTransColList( curFile, argv[idx++],
         &numCols, colNums, colTypes, strSize )
         != TCL_OK )
         return TCL_ERROR;
      if( numCols != 1 ) {
         Tcl_SetResult(curFile->interp,
            "Can only read one vector column of a table at a time",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      felem = atoi(argv[idx++]);
      
      /* 
      * Get the Row range parameter 
      */
      
      if( argc <= idx ) { 
         numRange    = 1;
         range = (int*) malloc(numRange*2*sizeof(int));
         range[0] = 1;
         range[1] = curFile->CHDUInfo.table.numRows;
      } else {
         numRange = fitsParseRangeNum(argv[idx])+1;
         range = (int*) malloc(numRange*2*sizeof(int));
         if( fitsParseRange( argv[idx++], &numRange, range, numRange,
            1, curFile->CHDUInfo.table.numRows, errMsg ) 
            != TCL_OK ) {
            Tcl_SetResult(curFile->interp,
               "Error parsing row range:\n", TCL_STATIC);
            Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
            return TCL_ERROR;
         }
      }
      
      /* Now get the rows... */
      
      listObj = Tcl_NewListObj( 0, NULL );
      
      for (i = 0; i < numRange; i++ ) {
         fRow  = range[i*2];
         while( fRow <= range[i*2+1] ) {
            ntodo = range[i*2+1] - fRow + 1;
            if( ntodo>FITS_CHUNKSIZE ) ntodo = FITS_CHUNKSIZE;
            
            if( tableBlockLoad( curFile, "", felem, fRow, ntodo,
               -99, numCols, colNums, format )  != TCL_OK )
               return TCL_ERROR;
            
            fRow += ntodo;
            if( Tcl_ListObjIndex( curFile->interp,
               Tcl_GetObjResult( curFile->interp ), 0,
               &resObj )
               != TCL_OK )
               return TCL_ERROR;
            if( Tcl_ListObjAppendList( curFile->interp, listObj, resObj )
               != TCL_OK )
               return TCL_ERROR;
         }
      }
      
      Tcl_SetObjResult( curFile->interp, listObj );
      
   } else {
      
      Tcl_SetResult(curFile->interp,
         "ERROR: unrecognized command to get", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   if (range) free(range); 
   return TCL_OK;
}


/******************************************************************
*                             Put
******************************************************************/

int fitsTcl_put( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *putKeyList = "put keyword ?-num n? card ?formatFlag?";
   static char *putHisList = "put history string";
   static char *putTabList =
      "put table colName firstElem rowSpan listOfData\n";
   
   static char *putImgList = "put image firstElem listOfData\n";
   
   static char *putIhdList =
      "put ihd ?-p? ?bitpix naxis naxesList? \n"
      "             - -p primary extension \n";
   
   static char *putAhdList = 
      "put ahd numRows numCols {colName} {colType} {colUnit} {tbCol}\n"
      "                                            extname rowLength\n"
      "       - colType: L(logical), X(bit), I(16 bit integer), "
      "J(32 bit integer)\n"
      "                  An(n Character), En(Single with n format), \n"
      "                  Dn(Double with n format), B(Unsigned) \n"
      "                  C(Complex), M(Double complex)  ";
   
   static char *putBhdList = 
      "put bhd numRows numCols {colName} {colType} {colUnit} extname \n"
      "       - colType: nL(logical),nX(bit), nI(16 bit integer), "
      "nJ(32 bit integer)\n"
      "                  nA(Character), nE(Single), nD(Double), nB(Unsigned) \n"
      "                  nC(Complex), M(Double complex)  ";
   
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int numRange, *range=NULL;
   char errMsg[256], *argStr, *cmd, **args;
   int i;
   
   if ( argc == 2 ) {
      Tcl_SetResult(curFile->interp,"Available Commands:\n",TCL_STATIC);
      Tcl_AppendResult(curFile->interp, putKeyList,"\n", (char *)NULL);
      Tcl_AppendResult(curFile->interp, putTabList,"\n", (char *)NULL);
      Tcl_AppendResult(curFile->interp, putIhdList,"\n", (char *)NULL);
      Tcl_AppendResult(curFile->interp, putAhdList,"\n", (char *)NULL);
      Tcl_AppendResult(curFile->interp, putBhdList,"\n", (char *)NULL);
      return TCL_OK;
   }
   
   cmd = Tcl_GetStringFromObj( argv[2], NULL );
   if( !strcmp( "keyword", cmd ) ) {
      
      /* Write Keyword */
      
      int format, cardNum=0, recLoc=3;
      
      if( argc < 4 || argc > 7 ) {
         Tcl_SetResult(curFile->interp, putKeyList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( !strcmp(Tcl_GetStringFromObj(argv[3],NULL), "-num") ) {
         if( argc < 6 ) {
            Tcl_SetResult(curFile->interp, putKeyList, TCL_STATIC);
            return TCL_ERROR;
         }
         if( Tcl_GetIntFromObj(curFile->interp, argv[4], &cardNum) != TCL_OK ) {
            return TCL_ERROR;
         }
         recLoc += 2;
      }
      
      if( recLoc+1 < argc ) {
         if( Tcl_GetIntFromObj(curFile->interp, argv[recLoc+1], &format)
            != TCL_OK ) {
            return TCL_ERROR;
         }
      } else {
         format = 1;
      }
      
      if( fitsPutKwds(curFile, cardNum,
         Tcl_GetStringFromObj(argv[recLoc],NULL),
         format)
         != TCL_OK ) {
         return TCL_ERROR;
      } 	  
      
   } else if( !strcmp( "history", cmd ) ) {
      
      /*  Write History  */
      
      if( argc != 4 ) {
         Tcl_SetResult(curFile->interp, putHisList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsPutHisKwd(curFile, Tcl_GetStringFromObj(argv[3],NULL) )
         != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp ( "image", cmd ) ) {
      
      /*  Write Image  */
      
      int nElem;
      long fElem;
      Tcl_Obj **dataList;
      
      if( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image", TCL_STATIC);
         return TCL_ERROR;
      }
      if( argc < 5 || argc > 6 ) {
         Tcl_SetResult(curFile->interp, putImgList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetLongFromObj(curFile->interp, argv[3], &fElem) != TCL_OK ) {
         return TCL_ERROR;
      }
      
      /*  Skip to last argument... can get nElem directly from data list  */
      
      if( Tcl_ListObjGetElements( curFile->interp, argv[argc-1],
         &nElem, &dataList ) != TCL_OK ) {
         return TCL_ERROR;
      }
      
      if( varSaveToImage( curFile, fElem, (long)nElem, dataList ) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp( "table", cmd ) ) {
      
      /*  Write Table  */ 
      
      int  nElem;
      long fElem;
      Tcl_Obj **dataElems;
      
      if ( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if ( argc != 7 ) {
         Tcl_SetResult(curFile->interp, putTabList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      /* parse the column name */
      
      if( fitsTransColList(curFile, Tcl_GetStringFromObj(argv[3],NULL),
         &numCols,colNums,colTypes,strSize) != TCL_OK ) {
         return TCL_ERROR;
      }
      if( numCols != 1 ) {
         Tcl_SetResult(curFile->interp,
            "Can only write one column at a time", TCL_STATIC);
         return TCL_ERROR;
      }
      
      /* 
      * Get the Row range parameter 
      */
      
      argStr = Tcl_GetStringFromObj( argv[5], NULL );
      numRange =fitsParseRangeNum(argStr)+1;
      range =(int*) malloc(numRange*2*sizeof(int));
      if( fitsParseRange(argStr,&numRange,range,numRange,
         1, curFile->CHDUInfo.table.numRows,errMsg) 
         != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Error parsing row range:\n", TCL_STATIC);
         Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
         return TCL_ERROR;
      }     
      if( numRange != 1 ) {
         Tcl_SetResult(curFile->interp,
            "Can only write one row range at a time", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetLongFromObj(curFile->interp,argv[4],&fElem) != TCL_OK ) {
         return TCL_ERROR;
      }
      
      if ( Tcl_ListObjGetElements( curFile->interp, argv[6],
         &nElem, &dataElems ) != TCL_OK ) {
         return TCL_ERROR;
      }
      
      if( varSaveToTable(curFile, 
         colNums[0], 
         range[0], 
         fElem,
         range[1]-range[0]+1,
         (long)nElem,
         dataElems ) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp( "ihd", cmd ) ) {
      
      /*  Write Image Header  */
      
      int isPrimary;
      if ( argc < 4 || argc > 7 ) {
         Tcl_SetResult(curFile->interp, putIhdList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( !strcmp( ARGV_STR(3), "-p" ) ) {
         isPrimary = 1;
      } else {
         isPrimary = 0;
      }
      
      args = (char **) ckalloc( argc * sizeof(char *) );
      for( i=0; i<argc; i++ ) {
         args[i] = ARGV_STR(i);
      }
      
      if( fitsPutReqKwds(curFile, isPrimary, IMAGE_HDU,
         argc-3-isPrimary, args+3+isPrimary)
         !=TCL_OK ) {
         ckfree( (char*)args );
         return TCL_ERROR;
      }
      ckfree( (char*)args );
      
   } else if( !strcmp( "ahd", cmd ) ) {
      
      /*  Write ASCII Table Header  */
      
      char const *newArg[7];
      int j;
      
      if( argc != 11 ) {
         Tcl_SetResult(curFile->interp, putAhdList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      /*  Strip out the numCols[4] parameter... use colNames length instead  */
      
      for( j=0,i=3; i<11; i++ ) {
         if( i!=4 )
            newArg[j++] = ARGV_STR(i);
      }
      
      if( fitsPutReqKwds(curFile, 0, ASCII_TBL, 7, (char **)newArg)
         != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp( "bhd", cmd ) ) {
      
      /*  Write Binary Table Header  */
      
      char const *newArg[5];
      int j;
      
      if( argc != 9 ) {
         Tcl_SetResult(curFile->interp, putBhdList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      /*  Strip out the numCols[4] parameter... use colNames length instead  */
      
      for( j=0,i=3; i<9; i++ ) {
         if( i!=4 )
            newArg[j++] = ARGV_STR(i);
      }
      
      if( fitsPutReqKwds(curFile, 0, BINARY_TBL, 5, (char **)newArg)
         != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else {
      
      Tcl_SetResult(curFile->interp, "Unknown put function", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   if (range) free(range); 
   return TCL_OK;
}


/******************************************************************
*                             Insert
******************************************************************/

int fitsTcl_insert( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *insertList[] = {
      "insert keyword index record ?formatflag?",
         "insert column  index colName colForm",
         "insert row     index numRows",
         "insert image ?-p? ?bitpix naxis naxesList? \n"
         "             - -p primary extension, keywords optional if empty array",
         "insert table numRows {colNames} {colForms} ?{colUnits} extname?\n"
         "       - colForm: nL(logical),nX(bit), nI(16 bit integer), "
         "nJ(32 bit integer)\n"
         "                  nA(Character), nE(Single), nD(Double), nB(Unsigned) \n"
         "                  nC(Complex), M(Double complex) \n"
         "insert table -ascii numRows {colNames} {colForms} ?{colUnits}\n"
         "                                            {tbCols} extname rowWidth?\n"
         "       - colForm: L(logical), X(bit), I(16 bit integer), "
         "J(32 bit integer)\n"
         "                  An(n Character), En(Single with n format), \n"
         "                  Dn(Double with n format), B(Unsigned) \n"
         "                  C(Complex), M(Double complex)  " };
      
      int index, format, numRows, i;
      
      if( argc == 2 ) {
         Tcl_AppendResult(curFile->interp,
            "Available commands:\n",
            insertList[0], "\n",
            insertList[1], "\n",
            insertList[2], "\n",
            insertList[3], "\n",
            insertList[4], "\n",
            (char *)NULL);
         return TCL_ERROR;
      }
      
      if( !strcmp( "keyword", argv[2] ) ) { 
         
         if( argc < 5 || argc > 6 ) {
            Tcl_SetResult(curFile->interp, insertList[0], TCL_STATIC);
            return TCL_OK;
         }
         
         if( Tcl_GetInt(curFile->interp, argv[3], &index) != TCL_OK) {
            Tcl_SetResult(curFile->interp,
               "Failed to get integer index", TCL_STATIC);
            return TCL_ERROR;
         }
         
         if( argc==6 ) {
            if ( Tcl_GetInt(curFile->interp, argv[5], &format) != TCL_OK) {
               Tcl_SetResult(curFile->interp,
                  "Failed to get integer format flag", TCL_STATIC);
               return TCL_ERROR;
            }
         } else {
            format = 1;
         }
         
         if( fitsInsertKwds(curFile, index, argv[4], format) != TCL_OK ) {
            return TCL_ERROR;
         } 
         
      } else if( !strcmp( "column", argv[2] ) ) {
         
         if (argc != 6 ) {
            Tcl_SetResult(curFile->interp, insertList[1], TCL_STATIC);
            return TCL_ERROR;
         }
         
         if( Tcl_GetInt(curFile->interp, argv[3], &index) != TCL_OK) {
            Tcl_SetResult(curFile->interp,
               "Failed to get integer index", TCL_STATIC);
            return TCL_ERROR;
         }
         
         if( addColToTable(curFile,index,argv[4],argv[5]) != TCL_OK ) {
            return TCL_ERROR;
         }       
         
      } else if( !strcmp( "row", argv[2] ) ) {
         
         if( argc != 5 ) {
            Tcl_SetResult(curFile->interp, insertList[2], TCL_STATIC);
            return TCL_ERROR;
         }
         
         if( Tcl_GetInt(curFile->interp, argv[3], &index) != TCL_OK) {
            Tcl_SetResult(curFile->interp,
               "Failed to get integer index", TCL_STATIC);
            return TCL_ERROR;
         }
         
         if( Tcl_GetInt(curFile->interp, argv[4], &numRows) != TCL_OK) {
            Tcl_SetResult(curFile->interp,
               "Failed to get integer numRows", TCL_STATIC);
            return TCL_ERROR;
         }   
         if( addRowToTable(curFile,index-1,numRows) != TCL_OK ) {
            return TCL_ERROR;
         } 
         
      } else if( !strcmp( "image", argv[2] ) ) {
         
         /*  Write Image Header  */
         
         int isPrimary;
         if ( argc < 4 || argc > 7 ) {
            Tcl_SetResult(curFile->interp, insertList[3], TCL_STATIC);
            return TCL_ERROR;
         }
         
         /*
         *  Strip off the "-p" flag if present... 
         */
         
         if( !strcmp(argv[3],"-p") ) {
            isPrimary = 1;
         } else {
            isPrimary = 0;
         }
         
         if( fitsPutReqKwds(curFile, isPrimary, IMAGE_HDU,
            argc-3-isPrimary, argv+3+isPrimary)
            !=TCL_OK ) {
            return TCL_ERROR;
         }
         
      } else if( !strcmp( "table", argv[2] ) ) {
         
         /*  Write Table Header  */
         
         int tabType;
         
         if( argc>3 && !strcmp( "-ascii", argv[3] ) ) {
            
            tabType = ASCII_TBL;
            if( argc < 7 || argc > 11 ) {
               Tcl_SetResult(curFile->interp, insertList[4], TCL_STATIC);
               return TCL_ERROR;
            }
            
         } else {
            
            tabType = BINARY_TBL;
            if( argc < 6 || argc > 8 ) {
               Tcl_SetResult(curFile->interp, insertList[4], TCL_STATIC);
               return TCL_ERROR;
            }
            
         }
         
         if( fitsPutReqKwds(curFile, 0, tabType,
            argc-3-(tabType==ASCII_TBL?1:0),
            argv+3+(tabType==ASCII_TBL?1:0))
            != TCL_OK ) {
            return TCL_ERROR;
         }
         
      } else {
         
         Tcl_SetResult(curFile->interp, "No such insert command", TCL_STATIC);
         return TCL_ERROR;      
         
      }
      
      return TCL_OK;
}

/******************************************************************
*                             Select
******************************************************************/

int fitsTcl_select( FitsFD *curFile, int argc, char *const argv[] )
{
   
   static char *selRowList = 
      "select rows -expr expression firstrow nrow\n ";
   
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int fRow, nRows;
   char * row_status;
   long n_good_rows;
   int i;
   char result[32];
   Tcl_Obj *valObj, *listObj;
   
   
   if( argc == 2 ) {
      Tcl_AppendResult(curFile->interp, selRowList,(char *) NULL);
      return TCL_OK;
   }
   
   
   if( !strcmp("rows", argv[2]) ) {
      
      if( argc != 7 ) {
         Tcl_SetResult(curFile->interp, selRowList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( !strcmp("-expr", argv[3]) ) {
         if( Tcl_GetInt(curFile->interp, argv[5], &fRow) != TCL_OK ) {
            return TCL_ERROR;
         }
         if( Tcl_GetInt(curFile->interp, argv[6], &nRows) != TCL_OK ) {
            return TCL_ERROR;
         }
         row_status = (char*) malloc((nRows+1)*sizeof(char));
         listObj = Tcl_NewObj();
         
         if( fitsSelectRowsExpr(curFile, argv[4], fRow,nRows, &n_good_rows,row_status) == TCL_OK ) {
         /*               for ( i=0 ; i< nRows; i++ ) {
         #                  if ( row_status[i] == 1 ) {
         #                     sprintf(result,"%d",i+fRow);
         #                     Tcl_AppendElement(curFile->interp,result);
         #                   }
#               }*/
            if (n_good_rows ) {
               for (i=0; i < nRows; i++) {
                  if ( row_status[i] == 1 ) {
                     valObj = Tcl_NewLongObj( i+fRow );
                     Tcl_ListObjAppendElement( curFile->interp, listObj, valObj);
                  }
               }
               Tcl_SetObjResult( curFile->interp, listObj);
            }
            
         }
         else {
            if(row_status) free(row_status);
            return TCL_ERROR;
         }
      } else {
         Tcl_SetResult(curFile->interp, selRowList, TCL_STATIC);
         return TCL_ERROR;
      }
      
   } else { 
      Tcl_SetResult(curFile->interp,
         "Unrecognized option to select", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   
   if(row_status) free(row_status);
   return TCL_OK;
}



/******************************************************************
*                             Delete
******************************************************************/

int fitsTcl_delete( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *delKeyList = 
      "delete keyword KeyList\n"
      "       (KeyList can be a mix of keyword names and keyword numbers\n";
   
   static char *delHduList = 
      "delete chdu\n";
   
   static char *delTabList = 
      "delete cols colList\n ";
   
   static char *delRowList = 
      "delete rows -expr expression\n "
      "delete rows -range rangelist\n "    
      "delete rows firstRow numRows\n ";
   
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int fRow, nRows;
   
   if( argc == 2 ) {
      Tcl_AppendResult(curFile->interp, delKeyList, delHduList, delTabList,
		       delRowList, (char *) NULL);
      return TCL_OK;
   }
   
   if( !strcmp("keyword", argv[2]) ) {
      
      if( argc != 4 ) {
         Tcl_SetResult(curFile->interp, delKeyList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsDeleteKwds(curFile, argv[3] ) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("cols", argv[2]) ) {
      
      if( argc != 4 ) {
         Tcl_SetResult(curFile->interp, delTabList, TCL_STATIC);
         return TCL_ERROR;
      }
      if( fitsTransColList( curFile,argv[3],
         &numCols,colNums,colTypes,strSize) != TCL_OK )
         return TCL_ERROR;
      
      if( fitsDeleteCols(curFile, colNums, numCols) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("rows", argv[2]) ) {
      
      if( argc != 5 ) {
         Tcl_SetResult(curFile->interp, delRowList, TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( !strcmp("-expr", argv[3]) ) {
         if( fitsDeleteRowsExpr(curFile, argv[4]) != TCL_OK ) {
            return TCL_ERROR;
         }
      } else if (!strcmp("-range", argv[3]) ) {
         if( fitsDeleteRowsRange(curFile, argv[4]) != TCL_OK ) {
            return TCL_ERROR;
         }
      }
      else {
         if( Tcl_GetInt(curFile->interp, argv[3], &fRow) != TCL_OK ) {
            return TCL_ERROR;
         }
         if( Tcl_GetInt(curFile->interp, argv[4], &nRows) != TCL_OK ) {
            return TCL_ERROR;
         }
         if( fitsDeleteRows(curFile, fRow, nRows) != TCL_OK ) {
            return TCL_ERROR;
         }
      }
      
   } else if( !strcmp("chdu", argv[2]) ) {
      
      if( argc != 3 ) {
         Tcl_SetResult(curFile->interp, delHduList, TCL_STATIC);
         return TCL_ERROR;
      }
      if( fitsDeleteCHdu(curFile) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else {
      
      Tcl_SetResult(curFile->interp,
         "Unrecognized option to delete", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   return TCL_OK;
}


/******************************************************************
*                             Load
******************************************************************/

int fitsTcl_load( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *loadList = "\n"
      "load arrayRow colName ?defaultNull? ?firstElement? - Load a row\n"
      "load column colName ?defaultNull? ?firstElement? - Load a column\n"
      "load vtable colName - Load all elements of a vector column into memory\n"
      "load tblock arrayName colList firstRow numRows colIndex ?felem?\n"
      "             - load a chunk of table and set up an array \"arrayName\"\n"
      "               with indices of (colIndex-1,firstRow-1), etc \n"
      "load copyto filename taget\n"
      "load image ?slice? ?rotate? - Load a 2D slice of an image into memory\n"
      "                   (rotate: number of 90deg ccw rotations to perform)\n"
      "load irows firstRow lastRow ?slice?  - load mean value of rows\n"
      "load icols firstCol lastCol ?slice?  - load mean value of columns\n"
      "load iblock arrayName firstRow numRows fitsCol numCols ?slice?\n"
      "             - load 2d image slice into an array or memory\n"
      "               if arrayName is --, then a pointer is returned\n"
      "load expr expression ?defaultNull?\n"
      "load keyword -  load the header of CHDU into a hash table \n"
      "load chdu    -  load the CHDU (useful if you move to the CHDU with -s,\n"
      "                which does't load the HDUInfo) \n";
   
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int fRow, nRows;
   int fCol, felem=1;
   
   fitsfile *infptr, *outfptr;   /* FITS file pointers defined in fitsio.h */
   int status = 0, ii = 1, iteration = 0, single = 0, hdupos;
   int hdutype, bitpix, bytepix, naxis = 0, nkeys, datatype = 0, anynul;
   long naxes[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1};
   long first, totpix = 0, npix;
   double *array, bscale = 1.0, bzero = 0.0, nulval = 0.;
   char card[81];
   int i, j;
   
   if( argc == 2 ) {
      Tcl_SetResult(curFile->interp, loadList, TCL_STATIC);
      return TCL_OK;
   }
   
   if( !strcmp("keyword", argv[2]) ) {
      
      /* Now LOAD the kwds hash table... */
      
      if( fitsLoadKwds(curFile) != TCL_OK ) {
         fitsCloseFile((ClientData) curFile);
         return TCL_ERROR;
      }
      
   } else if( !strcmp("irows", argv[2]) ) {
      
      long slice;
      
      if( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc < 5 ) {
         Tcl_SetResult(curFile->interp,
            "FitsHandle load irows firstRow lastRows ?slice?",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc == 5 ) {
         slice = 1;
      } else {
         slice = atol(argv[5]);
      }
      
      if( imageRowsMeanToPtr(curFile,
         atol(argv[3]), /* first row */
         atol(argv[4]), /* last row*/
         slice ) != TCL_OK ) {
         Tcl_AppendResult(curFile->interp,
            "fitsTcl Error: cannot load irows", NULL);
         return TCL_ERROR;
      }	
      
   } else if( !strcmp("icols", argv[2]) ) {
      
      long slice;
      
      if( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc < 5 ) {
         Tcl_SetResult(curFile->interp,
            "FitsHandle load icols firstCol lastCols ?slice?",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc == 5 ) {
         slice = 1;
      } else {
         slice = atol(argv[5]);
      }
      
      if( imageColsMeanToPtr(curFile, atol(argv[3]),
         atol(argv[4]), slice) != TCL_OK ) {
         Tcl_AppendResult(curFile->interp,
            "\nfitsTcl Error: cannot load icols",
            NULL);
         return TCL_ERROR;
      }	
      
   } else if( !strcmp("iblock", argv[2]) ) {
      
      char *varName="\0";
      long slice  = 1;
      long cslice = 1;
      
      if ( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc < 8 || argc > 10 ) {
         Tcl_SetResult(curFile->interp,
            "FitsHandle load iblock varName firstRow numRows "
            "firstCol numCols ?slice?", TCL_STATIC); 
         return TCL_ERROR;
      }
      
      if( argc > 8 )
         slice = atol(argv[8]);
      
      if( argc > 9 )
         cslice = atol(argv[9]);
      
      if( strcmp( argv[3], "--" ) )
         varName = argv[3];
      
      if( imageBlockLoad(curFile, varName, atol(argv[4]),
         atol(argv[5]), atol(argv[6]),
         atol(argv[7]), slice, cslice )
         != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("tblock", argv[2]) ) {
      
      int format=1;
      int idx;
      int varIdx;
      
      if ( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if (argc < 8 || argc > 11) {
         Tcl_SetResult(curFile->interp, 
            "Usage: load tblock ?-noformat? arrayName colList "
            "firstRow numRows firstCol ?felem?", TCL_STATIC);
         return TCL_ERROR;
      }
      
      idx = 3;
      if( !strcmp("-noformat", argv[idx]) ) {
         idx++;
         format=0;
      }
      varIdx = idx++;
      
      /* parse column list */
      
      if( fitsTransColList( curFile,argv[idx++],
         &numCols,colNums,colTypes,strSize) != TCL_OK )
         return TCL_ERROR;
      
      /* get the firstRow and numRows */
      
      if( Tcl_GetInt(curFile->interp, argv[idx++], &fRow)  != TCL_OK )
         return TCL_ERROR;
      if( Tcl_GetInt(curFile->interp, argv[idx++], &nRows) != TCL_OK )
         return TCL_ERROR;
      if( Tcl_GetInt(curFile->interp, argv[idx++], &fCol)  != TCL_OK )
         return TCL_ERROR;
      
      /* Skip a possible obsolete value between fCol and last argument */
      
      if( argc>idx ) {  /*  Read felem from very last argument  */
         if( Tcl_GetInt(curFile->interp, argv[argc-1], &felem) != TCL_OK )
            return TCL_ERROR;
      }
      
      if( tableBlockLoad(curFile, argv[varIdx], felem, fRow, nRows,
         fCol, numCols, colNums, format)   != TCL_OK )
         return TCL_ERROR;
      
   } else if( !strcmp("image", argv[2]) ) {
      
      long slice  = 1; 
      int  rotate = 0;
      
      if ( curFile->hduType != IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not an image", TCL_STATIC);
         return TCL_ERROR;
      }
      
      /* starting element, increment of naxisn[0] x naxisn[1] 
      to get different frames of a 3d image */
      
      if( argc == 3 ) {
         ; /* default to the first frame to allow backward compatible */
      } else if( curFile->CHDUInfo.image.naxes <= 2 ) {
         ; /* two-d image */
      } else {
         
         slice = atol(argv[3]);
         if( slice < 1 ) {
            Tcl_SetResult(curFile->interp,
               "fitsTcl Error: slice starts at 1", TCL_STATIC);
            return TCL_ERROR;
         }
         /*
         if( slice > curFile->CHDUInfo.image.naxisn[2] ) {
         Tcl_SetResult(curFile->interp, 
         "fitsTcl Error: slice exceeds the 3rd dim",
         TCL_STATIC);
         return TCL_ERROR;
         }
         */
         
         if( argc == 5 ) {
            rotate = atoi(argv[4]);
            if( rotate<0 || rotate>3 ) {
               Tcl_SetResult(curFile->interp,
                  "fitsTcl Error: Illegal rotate value",
                  TCL_STATIC);
               return TCL_ERROR;
            }
         }
         
      }
      
      if( imageGetToPtr(curFile, slice, rotate) != TCL_OK ) {
         return TCL_ERROR;
      }
      
      
      
   } else if( !strcmp("copyto", argv[2]) ) {
      
      /* Open the input file and create output file */
      fits_open_file(&infptr, argv[3], READONLY, &status);
      fits_create_file(&outfptr, argv[4], &status);
      
      if (status != 0) {
         fits_report_error(stderr, status);
         return(status);
      }
      
      fits_get_hdu_num(infptr, &hdupos);  /* Get the current HDU position */
      
      /* Copy only a single HDU if a specific extension was given */
      if (hdupos != 1 || strchr(argv[3], '[')) single = 1;
      
      for (; !status; hdupos++)  /* Main loop through each extension */
      {
         
         fits_get_hdu_type(infptr, &hdutype, &status);
         
         if (hdutype == IMAGE_HDU) {
            
            /* get image dimensions and total number of pixels in image */
            for (ii = 0; ii < 9; ii++)
               naxes[ii] = 1;
            
            fits_get_img_param(infptr, 9, &bitpix, &naxis, naxes, &status);
            
            totpix = naxes[0] * naxes[1] * naxes[2] * naxes[3] * naxes[4]
               * naxes[5] * naxes[6] * naxes[7] * naxes[8];
         }
         
         if (hdutype != IMAGE_HDU || naxis == 0 || totpix == 0) {
            
            /* just copy tables and null images */
            fits_copy_hdu(infptr, outfptr, 0, &status);
            
         } else {
            
            /* Explicitly create new image, to support compression */
            fits_create_img(outfptr, bitpix, naxis, naxes, &status);
            
            /* copy all the user keywords (not the structural keywords) */
            fits_get_hdrspace(infptr, &nkeys, NULL, &status);
            
            for (ii = 1; ii <= nkeys; ii++) {
               fits_read_record(infptr, ii, card, &status);
               if (fits_get_keyclass(card) > TYP_CMPRS_KEY)
                  fits_write_record(outfptr, card, &status);
            }
            
            switch(bitpix) {
            case BYTE_IMG:
               datatype = TBYTE;
               break;
            case SHORT_IMG:
               datatype = TSHORT;
               break;
            case LONG_IMG:
               datatype = TLONG;
               break;
            case FLOAT_IMG:
               datatype = TFLOAT;
               break;
            case DOUBLE_IMG:
               datatype = TDOUBLE;
               break;
            case LONGLONG_IMG:
               datatype = TLONGLONG;
               break;
            }
            
            bytepix = abs(bitpix) / 8;
            
            npix = totpix;
            iteration = 0;
            
            /* try to allocate memory for the entire image */
            /* use double type to force memory alignment */
            array = (double *) calloc(npix, bytepix);
            
            /* if allocation failed, divide size by 2 and try again */
            while (!array && iteration < 10)  {
               iteration++;
               npix = npix / 2;
               array = (double *) calloc(npix, bytepix);
            }
            
            if (!array)  {
               fprintf(stdout,"Memory allocation error\n");
               return(0);
            }
            
            /* turn off any scaling so that we copy the raw pixel values */
            fits_set_bscale(infptr,  bscale, bzero, &status);
            fits_set_bscale(outfptr, bscale, bzero, &status);
            first = 1;
            while (totpix > 0 && !status)
            {
               /* read all or part of image then write it back to the output file */
               fits_read_img(infptr, datatype, first, npix,
                  &nulval, array, &anynul, &status);
               
               fits_write_img(outfptr, datatype, first, npix, array, &status);
               totpix = totpix - npix;
               first  = first  + npix;
            }
            free(array);
         }
         
         if (single) break;  /* quit if only copying a single HDU */
         fits_movrel_hdu(infptr, 1, NULL, &status);  /* try to move to next HDU */
      }
      
      if (status == END_OF_FILE)  status = 0; /* Reset after normal error */
      
      fits_close_file(outfptr,  &status);
      fits_close_file(infptr, &status);
      
   } else if( !strcmp("arrayRow", argv[2]) ) {
      
      char *nullPtr = "NULL";
      long rowNum;
      long nelem;
      
      if( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc < 4 || argc > 8 ) {
         Tcl_SetResult(curFile->interp,
            "fitsObj load arrayRow colName rowNumber numElement ?nulValue? ?firstelem?",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsTransColList( curFile, argv[3],
         &numCols, colNums, colTypes, strSize ) != TCL_OK )
         return TCL_ERROR;
      
      if( numCols != 1 ) {
         Tcl_SetResult(curFile->interp,
            "Can only load one column at a time", TCL_STATIC);
         return TCL_ERROR;
      }
      
      rowNum = atol(argv[4]);
      nelem  = atol(argv[5]);
      
      if( argc>6 )
         nullPtr = argv[6];
      
      if( argc>7 )
         felem = atol(argv[7]);
      
      if( tableRowGetToPtr(curFile, rowNum, colNums[0], nelem, nullPtr, felem) ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("column", argv[2]) ) {
      
      char *nullPtr = "NULL";
      
      if( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc < 4 || argc > 6 ) {
         Tcl_SetResult(curFile->interp,
            "load column colName ?nulValue? ?firstelem?",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsTransColList( curFile, argv[3],
         &numCols, colNums, colTypes, strSize ) != TCL_OK )
         return TCL_ERROR;
      
      if( numCols != 1 ) {
         Tcl_SetResult(curFile->interp,
            "Can only load one column at a time", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc>4 )
         nullPtr = argv[4];
      
      if( argc>5 )
         felem = atol(argv[5]);
      
      if( tableGetToPtr(curFile, colNums[0], nullPtr, felem) ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("vtable", argv[2]) ) {
      
      char *nullPtr = "NULL";
      
      if ( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc < 4 || argc > 5 ) {
         /* For backwards compatibility, allow for one extra parameter */
         /* ... formerly the vector size of column                     */
         /* PDW 12/06/99: Sacrifice backwards compat for adding defNull*/
         Tcl_SetResult(curFile->interp,
            "load vtable colName ?nulValue?", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsTransColList( curFile,argv[3],
         &numCols,colNums,colTypes,strSize) != TCL_OK )
         return TCL_ERROR;
      if( numCols != 1 ) {
         Tcl_SetResult( curFile->interp,
            "Can only load one column at a time", TCL_STATIC );
         return TCL_ERROR;
      }
      
      if( argc>4 )
         nullPtr = argv[4];
      
      if( vtableGetToPtr(curFile, colNums[0], nullPtr) ) {
         return TCL_ERROR;
      }	  
      
   } else if( !strcmp("expr", argv[2]) ) {
      
      char *nullPtr = "NULL", errMsg[256];
      int numRange, *range=NULL; 
      int argOff=0;
      
      if( curFile->hduType == IMAGE_HDU ) {
         Tcl_SetResult(curFile->interp,
            "Current extension is not a table", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( !strcmp("-rows", argv[3]) && argc>4 ) {
         numRange = fitsParseRangeNum(argv[4])+1;
         range = (int*) malloc(numRange*2*sizeof(int));
         if( fitsParseRange(argv[4],&numRange,range,numRange,
            1, curFile->CHDUInfo.table.numRows,errMsg) 
            != TCL_OK ) {
            Tcl_SetResult(curFile->interp,
               "Error parsing row range:\n", TCL_STATIC);
            Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
            return TCL_ERROR;
         }
         argOff = 2;
      } else {
         numRange = 1;
         range = (int*) malloc(numRange*2*sizeof(int));
         range[0] = 1;
         range[1] = curFile->CHDUInfo.table.numRows;
      }
      
      if( argc < 4+argOff || argc-argOff > 5+argOff ) {
         Tcl_SetResult(curFile->interp, 
            "Usage: load expr ?-rows range? exprStr ?nullVal?",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( argc > 4+argOff )
         nullPtr = argv[4+argOff];
      
      if( exprGetToPtr( curFile, argv[3+argOff], nullPtr, numRange, range ) ) {
         return TCL_ERROR;
      }
      
   } else if( !strcmp("all", argv[2]) || !strcmp("chdu", argv[2]) ) {
      
      /* load the current hdu */ 
      
      if( fitsUpdateCHDU(curFile, curFile->hduType) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "fitsTcl Error: Cannot update current HDU",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsLoadHDU(curFile) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else {
      
      Tcl_SetResult(curFile->interp,
         "Error in fitsTcl: unknown load function", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   return TCL_OK;
}


/******************************************************************
*                             Free
******************************************************************/

int fitsTcl_free( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   void *databuff;
   Tcl_Obj **addList;
   char *addStr;
   int nAdd;
   
   if( argc == 2 ) {
      Tcl_SetResult(curFile->interp,
         "free addressList",
         TCL_STATIC);
      return TCL_OK;
   }
   
   if( argc>4 ) {
      Tcl_SetResult(curFile->interp, "Too many arguments to free",
         TCL_STATIC);
      return TCL_ERROR;
   }      
   
   if( Tcl_ListObjGetElements(curFile->interp, argv[argc-1], &nAdd, &addList)
      != TCL_OK ) {
      Tcl_SetResult(curFile->interp,
         "Cannot parse the address list", TCL_STATIC);
      return TCL_ERROR;
   }
   
   while( nAdd-- ) {
      databuff = NULL;
      addStr = Tcl_GetStringFromObj( addList[nAdd], NULL );
      sscanf(addStr,PTRFORMAT,&databuff);
      if ( databuff == NULL) {
         Tcl_SetResult(curFile->interp,
            "Error interpretting pointer address", TCL_STATIC);
         return TCL_ERROR;
      }
      ckfree( (char *) databuff);
   }
   
   return TCL_OK;
}


/******************************************************************
*                             Flush
******************************************************************/

int fitsTcl_flush( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   int status = 0;
   
   if ( argc == 2 ) {
      ffflsh(curFile->fptr, 0, &status);
   } else if( argc == 3 ) {
      char *opt;
      opt = Tcl_GetStringFromObj( argv[2], NULL );
      if( !strcmp(opt, "clear") ) {
         ffflsh(curFile->fptr, 1, &status);
      } else {
         Tcl_SetResult(curFile->interp, "fitsFile flush ?clear?", TCL_STATIC);
         return TCL_ERROR;
      }
   } else {
      Tcl_SetResult(curFile->interp, "fitsFile flush ?clear?", TCL_STATIC);
      return TCL_ERROR;
   }
   
   if( status ) {
      Tcl_SetResult(curFile->interp, 
         "fitsTcl Error: cannot flush file\n", TCL_STATIC);
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   }
   
   return TCL_OK;
}


/******************************************************************
*                             Copy
******************************************************************/

int fitsTcl_copy( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *copyList = "\n"
      "copy filename\n";
   if( argc == 2 ) {
      Tcl_SetResult(curFile->interp, copyList, TCL_STATIC);
      return TCL_OK;
   }
   
   if( fitsCopyCHduToFile(curFile, Tcl_GetStringFromObj( argv[2], NULL ) )
      != TCL_OK ) {
      return TCL_ERROR; 
   }
   
   return TCL_OK;
}


/******************************************************************
*                             Sascii
******************************************************************/

int fitsTcl_sascii( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *sasciiList =
      "sascii table filename fileMode firstRow numRows colList widthList\n"
      "             ifFixedFormat ifCSV ifPrintRow sepString\n"
      "sascii image filename fileMode firstRow numRows firstCol\n"
      "             numCols cellSize ifCSV ifPrintRow sepString ?slice?\n";
   
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int fRow, nRows;
   int fCol, nCols, nWdths;
   int cellSize, i, baseColNum, ifVariableVec;
   int ifCSV, ifPrintRow, ifFixedFormat;
   char *sepString;
   char **listWid;
   
   char *errMsg;
   
   if( argc == 2 ) {
      Tcl_SetResult(curFile->interp, sasciiList, TCL_STATIC);
      return TCL_OK;
   }      
   
   if( !strcmp("table", argv[2]) ){
      
      if( argc < 13 || argc > 14 ) {
         Tcl_SetResult(curFile->interp,
            "Wrong # of args to 'sascii table'", TCL_STATIC);
         return TCL_ERROR;
      }  
      
      if( Tcl_GetInt(curFile->interp, argv[5], &fRow) != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot get first row", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[6], &nRows) != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot get number of rows", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsTransColList( curFile,argv[7],
         &numCols,colNums,colTypes,strSize) != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot parse the column list", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_SplitList(curFile->interp, argv[8], &nWdths, &listWid)
         != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot parse the width list", TCL_STATIC);
         ckfree( (char*)listWid );
         return TCL_ERROR;
      }
      
      if( nWdths != numCols ) {
         Tcl_SetResult(curFile->interp, "Cell width array and Column list have different sizes", TCL_STATIC);
         ckfree( (char*)listWid );
         return TCL_ERROR;
      }
      
      for( i=0; i< numCols; i++ ) {
         if( Tcl_GetInt(curFile->interp, listWid[i], strSize+i) != TCL_OK ) {
            Tcl_SetResult(curFile->interp, "Unable to parse the width list", TCL_STATIC);
            ckfree( (char*)listWid );
            return TCL_ERROR;
         }
      }
      ckfree( (char*)listWid );
      
      if( Tcl_GetInt(curFile->interp, argv[9], &ifFixedFormat) != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot get ifFixedFormat", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetInt(curFile->interp, argv[10], &ifCSV) != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot get ifCSV", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetInt(curFile->interp, argv[11], &ifPrintRow) != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot get ifPrintRow", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( saveTableToAscii( curFile, argv[3], argv[4], 1, fRow, nRows,
         numCols, colTypes, colNums, strSize,
         ifFixedFormat, ifCSV, ifPrintRow, argv[12]) )
         return TCL_ERROR;
      
   } else if( !strcmp("image", argv[2]) ) {
      
      long slice = 1;
      
      if( argc < 13 || argc > 14 ) {
         Tcl_SetResult(curFile->interp,
            "Wrong # of args to 'sascii image'", TCL_STATIC);
         return TCL_ERROR;
      }  
      
      if( argc == 14 ) 
         slice = atol(argv[13]);
      
      if( Tcl_GetInt(curFile->interp, argv[5], &fRow) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get first row", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[6], &nRows) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get number of rows", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[7], &fCol) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get first column", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[8], &nCols) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get number of columns", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[9], &cellSize) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get cellSize", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetInt(curFile->interp, argv[10], &ifCSV) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get ifCSV", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetInt(curFile->interp, argv[11], &ifPrintRow) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get ifPrintRow", TCL_STATIC);
         return TCL_ERROR;
      }
      
      /*
      do error checking later 
      sepString = argv[12];
      */
      
      if( saveImageToAscii( curFile, argv[3], argv[4], fRow, nRows,
         fCol, nCols, cellSize, 
         ifCSV, ifPrintRow, argv[12], slice ) )
         return TCL_ERROR;
      
   } else if( !strcmp("vector", argv[2]) ) {
      
      ifVariableVec = atol(argv[13]);
      
      if( Tcl_GetInt(curFile->interp, argv[5], &fRow) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get first row", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[6], &nRows) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get number of rows", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[7], &fCol) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get first column", TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[8], &nCols) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get number of columns", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( fitsTransColList( curFile,argv[9],
         &numCols,colNums,colTypes,strSize) != TCL_OK ) {
         Tcl_SetResult(curFile->interp, "Cannot parse the column list", TCL_STATIC);
         return TCL_ERROR;
      } 
      
      /* 1-based */
      baseColNum = colNums[0];
      
      if( Tcl_GetInt(curFile->interp, argv[10], &ifCSV) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get ifCSV", TCL_STATIC);
         return TCL_ERROR;
      }
      
      if( Tcl_GetInt(curFile->interp, argv[11], &ifPrintRow) != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot get ifPrintRow", TCL_STATIC);
         return TCL_ERROR;
      }
      
      /*
      do error checking later
      sepString = argv[12];
      */
      
      if( saveVectorTableToAscii( curFile, argv[3], argv[4], fRow, nRows,
         fCol, nCols, baseColNum,
         ifCSV, ifPrintRow, argv[12], ifVariableVec ) )
         return TCL_ERROR;
   } else {
      
      Tcl_SetResult(curFile->interp,
         "Unknown sascii command", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   return TCL_OK;
}


/******************************************************************
*                             Sort
******************************************************************/

int fitsTcl_sort( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *sortList =
      "sort ?-merge? colNameList ?isAscendFlagList? \n";
   
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int i;
   int *isAscend;
   char *const *argPtr;
   char **listPtr;
   int listNum;
   int isMerge = 0;
   
   if( argc == 2 ) { 
      Tcl_SetResult(curFile->interp, sortList, TCL_STATIC);
      return TCL_OK;
   }
   
   if( curFile->hduType == IMAGE_HDU ) {
      Tcl_SetResult(curFile->interp, "Cannot sort an image", TCL_STATIC);
      return TCL_ERROR;
   }      
   
   argc  -= 2;
   argPtr = argv + 2;
   
   if( !strcmp(argPtr[0], "-merge") ) {
      isMerge = 1;
      argc --;
      argPtr ++;
   }
   
   if( fitsTransColList( curFile,argPtr[0],
      &numCols,colNums,colTypes,strSize) != TCL_OK ) {
      return TCL_ERROR;
   }
   
   isAscend = (int *) ckalloc(numCols*sizeof(int));
   
   /* if no isAscend specified, set as default ascend */
   
   if (argc == 1) {
      
      for (i=0; i < numCols; i++) 
         isAscend[i] = 1;
      
   } else {
      
      if( Tcl_SplitList(curFile->interp, argPtr[1],
         &listNum, &listPtr) != TCL_OK ) {
         ckfree((char *) isAscend);
         return TCL_ERROR;
      }
      if( listNum != numCols ) {
         Tcl_SetResult(curFile->interp,
            "fitsTcl Error: number of flags and columns don't match",
            TCL_STATIC);
         ckfree((char *) isAscend);
         ckfree((char *) listPtr);
         return TCL_ERROR;
      }
      for (i=0; i< listNum; i++) {
         if( Tcl_GetInt(curFile->interp, listPtr[i], &isAscend[i]) != TCL_OK ) {
            ckfree((char*) isAscend);
            ckfree((char*) listPtr);
            Tcl_SetResult(curFile->interp,
               "fitsTcl Error: cannot parse sort flag", TCL_STATIC);
            return TCL_ERROR;
         }
      }
      ckfree((char *) listPtr);
      
   }
   
   if( fitsSortTable(curFile, numCols, colNums,  
      strSize, isAscend, isMerge) != TCL_OK ) {
      ckfree ((char *) isAscend);
      return TCL_ERROR;
   }
   
   ckfree ((char *) isAscend);
   return TCL_OK;
}


/******************************************************************
*                             Add
******************************************************************/

int fitsTcl_add( FitsFD *curFile, int argc, char *const argv[] )
{
   static char *addColList =
      "add column colName colForm ?expr?\n"
      "add column colName colForm ?expr? ?rowrange?\n"
      "    colForm: e.g.\n"
      "    ASCII  Table: A15, I10, E12.5, D20.10, F14.6 ... \n"
      "    BINARY Table: 15A, 1I, 1J, 1E, 1D, 1L, 1X, 1B, 1C, 1M\n";
   static char *addRowList = "add row numRows\n";
   char result[16];
   int numCols,colNums[FITS_COLMAX],colTypes[FITS_COLMAX],strSize[FITS_COLMAX];
   int numRange,rangeBlock, *range=NULL;  
   char errMsg[256];
   int i,j;
   
   /*   range = (int*) malloc(FITS_MAXRANGE*2*sizeof(int)); */
   if( argc == 2 ) {
      Tcl_AppendResult(curFile->interp, addColList, addRowList, (char*)NULL);
      return TCL_OK;
   } 
   
   if( !strcmp(argv[2], "column") ) {
      
      if( argc == 5 ) {
         
         if( addColToTable(curFile, FITS_COLMAX, argv[3], argv[4])
            != TCL_OK ) {
            return TCL_ERROR;
         }
         
      } else if( argc >= 6 ) {
         
         char *tmpColName;
         int isNew;
         
         strToUpper(argv[3], &tmpColName);
         if( fitsTransColList(curFile,tmpColName,
            &numCols,colNums,colTypes,strSize) != TCL_OK ) {
            
            /* column name doesn't exist, add a new column*/
            
            isNew = 1;
         } else if( numCols == 1 ) {
            isNew = 0;
         } else {
            Tcl_SetResult(curFile->interp,
               "Can only add one column at a time", TCL_STATIC);
            ckfree((char *) tmpColName);
            return TCL_ERROR;
         }
         ckfree((char *) tmpColName);
         
         /* Feb 2004, Ziqin Pan add  */
         if( argc >= 7 ) {
            numRange = fitsParseRangeNum(argv[6])+1;
            range = (int*) malloc(numRange*2*sizeof(int)); 
            if ( fitsParseRange(argv[6],&numRange,range,numRange, 1, curFile->CHDUInfo.table.numRows,errMsg)
               != TCL_OK ) {
               Tcl_SetResult(curFile->interp,
                  "Error parsing row range:\n", TCL_STATIC);
               Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
               return TCL_ERROR;
            }
            if ( fitsCalculaterngColumn(curFile, argv[3], ( strcmp(argv[4],"default") ? argv[4] : NULL ),
               argv[5],numRange,range) != TCL_OK ) {
               return TCL_ERROR;
            }
         } else {
            if ( fitsCalculateColumn(curFile, argv[3], ( strcmp(argv[4],"default") ? argv[4] : NULL ),
               argv[5]) != TCL_OK ) {
               return TCL_ERROR;
            }
         }
         
         sprintf(result,"%d",isNew);
         Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
         
      } else {
         
         Tcl_SetResult(curFile->interp, addColList, TCL_STATIC);
         return TCL_ERROR;
         
      }
      
   } else if( !strcmp(argv[2], "row") ) {
      
      int numRows;
      
      if( argc != 4 ) {
         Tcl_SetResult(curFile->interp, addRowList, TCL_STATIC);
         return TCL_ERROR;
      }
      if( Tcl_GetInt(curFile->interp, argv[3], &numRows) != TCL_OK) {
         Tcl_SetResult(curFile->interp,
            "Failed to get numRows parameter", TCL_STATIC);
         return TCL_ERROR;
      }       
      if( addRowToTable(curFile, curFile->CHDUInfo.table.numRows,  
         numRows) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else {
      
      Tcl_SetResult(curFile->interp, "Unknown add command", TCL_STATIC);
      return TCL_ERROR;
      
   }   
   
   if (range) free(range); 
   return TCL_OK;
}


/******************************************************************
*                             Append
******************************************************************/

int fitsTcl_append( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *appendList = "\n"
      "append filename \n"
      "       -- append the chdu to another file\n";
   
   if( argc < 3 ) {
      Tcl_SetResult(curFile->interp, appendList, TCL_STATIC);
      return TCL_OK;
   }
   
   if( fitsAppendCHduToFile(curFile, Tcl_GetStringFromObj( argv[2], NULL ) )
      != TCL_OK ) {
      return TCL_ERROR;
   } 
   
   return TCL_OK;
}


/******************************************************************
*                            Histogram
******************************************************************/

int fitsTcl_histo( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *histoList = "\n"
      "histogram ?-weight w? ?-rows rowSpan? filename {col min max bin} ... \n";
   
   int i, j, argNum, nRows;
   char *opt;
   int numRange, *range=NULL; 
   char errMsg[256];
   Tcl_Obj **binList;
   
   /*  Args to ffhist  */
   fitsfile *fptr;
   char *outfile;
   int imagetype = TINT;
   int naxis;
   char colname[4][FLEN_VALUE];
   double minin[4];
   double maxin[4];
   double binsizein[4];
   char minname[4][FLEN_VALUE];
   char maxname[4][FLEN_VALUE];
   char binname[4][FLEN_VALUE];
   double weightin;
   char wtcol[FLEN_VALUE];
   int recip=0;
   char *selectrow=NULL;
   int status=0;
   
   if( argc == 2 ) {
      Tcl_SetResult(curFile->interp, histoList, TCL_STATIC);
      return TCL_OK;
   }
   
   if( curFile->hduType == IMAGE_HDU ) {
      Tcl_SetResult(curFile->interp, "Cannot histogram an image", TCL_STATIC);
      return TCL_ERROR;
   }      
   
   /*  Zero out all the parameters  */
   
   for( i=0; i<4; i++ ) {
      colname[i][0] = '\0';
      minname[i][0] = '\0';  minin[i]     = DOUBLENULLVALUE;
      maxname[i][0] = '\0';  maxin[i]     = DOUBLENULLVALUE;
      binname[i][0] = '\0';  binsizein[i] = DOUBLENULLVALUE;
   }
   wtcol[0] = '\0';
   
   
   /*  Search for histogram options  */
   
   weightin = 1.0;
   nRows  = curFile->CHDUInfo.table.numRows;
   argNum = 2;
   do { /*  argc guaranteed to be at least 3  */
      
      opt = Tcl_GetStringFromObj( argv[argNum++], NULL );
      if( opt[0]!='-' ) break;
      
      if( !strcmp(opt,"-weight") ) {
         
         if( argNum == argc ) {
            Tcl_SetResult(curFile->interp, histoList, TCL_STATIC);
            if( selectrow ) ckfree( (char*)selectrow );
            return TCL_ERROR;
         }
         if( Tcl_GetDoubleFromObj( curFile->interp, argv[argNum], &weightin )
            != TCL_OK ) {
            strcpy( wtcol, Tcl_GetStringFromObj( argv[argNum], NULL ) );
         }
         imagetype = TFLOAT;
         argNum++;
         
      } else if( !strcmp(opt,"-inverse") ) {
         
         recip = 1;
         
      } else if( !strcmp(opt,"-rows") ) {
         
         if( argNum == argc ) {
            Tcl_SetResult(curFile->interp, histoList, TCL_STATIC);
            if( selectrow ) ckfree( (char*)selectrow );
            return TCL_ERROR;
         }
         opt = Tcl_GetStringFromObj( argv[argNum++], NULL );
         numRange = fitsParseRangeNum(opt)+1;
         range = (int*) malloc(numRange*2*sizeof(int));
         if( fitsParseRange( opt, &numRange, range, numRange,
            1, nRows, errMsg) 
            != TCL_OK ) {
            Tcl_SetResult(curFile->interp,
               "Error parsing row range:\n", TCL_STATIC);
            Tcl_AppendResult(curFile->interp, errMsg, (char*)NULL);
            if( selectrow ) ckfree( (char*)selectrow );
            return TCL_ERROR;
         }
         if( numRange>1 || range[0]!=1 || range[1]!=nRows ) {
            if( selectrow==NULL ) {
               selectrow = (char *)ckalloc( nRows * sizeof(char) );
               if( !selectrow ) {
                  Tcl_SetResult( curFile->interp,
                     "Unable to allocate row-selection array",
                     TCL_STATIC );
                  return TCL_ERROR;
               }
               for( i=0; i<nRows; i++ ) selectrow[i] = 0;
            }
            for( i=0; i<numRange; i++ ) {
               for( j=range[i*2]; j<=range[i*2+1]; j++ ) {
                  selectrow[j-1] = 1;
               }
            }
         }
         
      } else {
         break;
      }
      
      if( argNum >= argc ) {
         /*  Need at least a filename parameter  */
         Tcl_SetResult( curFile->interp, histoList, TCL_STATIC );
         if( selectrow ) ckfree( (char*)selectrow );
         return TCL_ERROR;
      }
      
   } while( 1 ); /*  Exit by one of breaks... found non option  */
   
   /*  opt should be pointing to the file name  */
   
   outfile = opt;
   
   naxis = argc - argNum;
   if( naxis < 1 ) {
      if( selectrow ) ckfree( (char*)selectrow );
      Tcl_SetResult( curFile->interp, "Missing binning arguments",
         TCL_STATIC );
      return TCL_ERROR;
   }
   if( naxis > 4 ) {
      if( selectrow ) ckfree( (char*)selectrow );
      Tcl_SetResult( curFile->interp, "Histograms are limited to 4 dimensions",
         TCL_STATIC );
      return TCL_ERROR;
   }      
   
   /*  Parse each of the binning lists  */
   
   for( i=0; i<naxis; i++, argNum++ ) {
      
      if( Tcl_ListObjGetElements(curFile->interp, argv[argNum], &j, &binList)
         != TCL_OK ) {
         Tcl_SetResult(curFile->interp,
            "Cannot parse the column binning parameters",
            TCL_STATIC);
         return TCL_ERROR;
      }
      if( j!=4 ) {
         if( selectrow ) ckfree( (char*)selectrow );
         Tcl_SetResult( curFile->interp,
            "Binning list should be {colName min max binsize}",
            TCL_STATIC );
         return TCL_ERROR;
      }
      
      /*  Get column name  */
      opt = Tcl_GetStringFromObj( binList[0], &j );
      if( j<FLEN_VALUE ) {
         strcpy( colname[i], opt );
      } else {
         j = FLEN_VALUE-1;
         strncpy( colname[i], opt, j );
         colname[i][j] = '\0';
      }
      
      /*  Get min parameter ... can be number, "-", or keyword name  */
      if( Tcl_GetDoubleFromObj( curFile->interp, binList[1], minin+i )
         != TCL_OK ) {
         opt = Tcl_GetStringFromObj( binList[1], &j );
         if( strcmp(opt,"-") ) {
            /*  Use supplied keyword name  */
            if( j<FLEN_VALUE ) {
               strcpy( minname[i], opt );
            } else {
               j = FLEN_VALUE-1;
               strncpy( minname[i], opt, j );
               minname[i][j] = '\0';
            }
         }
      }
      
      /*  Get max parameter ... can be number, "-", or keyword name  */
      if( Tcl_GetDoubleFromObj( curFile->interp, binList[2], maxin+i )
         != TCL_OK ) {
         opt = Tcl_GetStringFromObj( binList[2], &j );
         if( strcmp(opt,"-") ) {
            /*  Use supplied keyword name  */
            if( j<FLEN_VALUE ) {
               strcpy( maxname[i], opt );
            } else {
               j = FLEN_VALUE-1;
               strncpy( maxname[i], opt, j );
               maxname[i][j] = '\0';
            }
         }
      }
      
      /*  Get bin parameter ... can be number, "-", or keyword name  */
      if( Tcl_GetDoubleFromObj( curFile->interp, binList[3], binsizein+i )
         != TCL_OK ) {
         opt = Tcl_GetStringFromObj( binList[3], &j );
         if( strcmp(opt,"-") ) {
            /*  Use supplied keyword name  */
            if( j<FLEN_VALUE ) {
               strcpy( binname[i], opt );
            } else {
               j = FLEN_VALUE-1;
               strncpy( binname[i], opt, j );
               binname[i][j] = '\0';
            }
         }
      }
      
   }
   
   ffreopen( curFile->fptr, &fptr, &status );
   ffmahd( fptr, curFile->chdu, &j, &status );
   ffhist2( &fptr,
      outfile,
      imagetype,
      naxis,
      colname,
      minin,
      maxin,
      binsizein,
      minname,
      maxname,
      binname,
      weightin,
      wtcol,
      recip,
      selectrow,
      &status );
   ffclos( fptr, &status );
   
   if (range) free(range); 
   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   }
   
   Tcl_ResetResult(curFile->interp);
   return TCL_OK;
}


/******************************************************************
*                             Create
******************************************************************/

int fitsTcl_create( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *createList= "\n"
      "create 2dhisto filename {colList} {xmin xmax xbin} {ymin ymax ybin} ?rows?\n"
      "       1dhisto filename {colList} {xmin xmax xbin} ?row?\n"
      "       (DEPRECATED)  Use 'objName histogram' command instead\n";
   
   Tcl_Obj *newCmd[10];
   int newArgc, nelem, naxes, i;
   char *opt;
   
   if( argc == 2 ) {
      Tcl_SetResult(curFile->interp, createList, TCL_STATIC);
      return TCL_OK;
   }
   
   opt = Tcl_GetStringFromObj( argv[2], NULL );
   if( !strcmp("dhisto", opt+1) ) {
      
      naxes = *opt - '0';
      
      if( argc < 5 + naxes ) {
         Tcl_SetResult(curFile->interp, "Wrong # of args to 'create ndhisto'",
            TCL_STATIC);
         return TCL_ERROR;
      }
      
      newArgc=0;
      newCmd[newArgc++] = argv[0];
      newCmd[newArgc++] = Tcl_NewStringObj("histogram",-1);
      
      /*  Look for a row span  */
      if ( argc > 5 + naxes) {
         newCmd[newArgc++] = Tcl_NewStringObj("-rows",-1);
         newCmd[newArgc++] = argv[argc-1];
      }
      
      /*  Look for a weight argument  */
      Tcl_ListObjLength( curFile->interp, argv[4], &nelem );
      if( nelem<naxes || nelem>naxes+1 ) {
         Tcl_SetResult(curFile->interp, "Need 2-3 columns to produce histogram",
            TCL_STATIC);
         return TCL_ERROR;
      }
      if( nelem==naxes+1 ) {
         newCmd[newArgc++] = Tcl_NewStringObj("-weight",-1);
         Tcl_ListObjIndex( curFile->interp, argv[4], naxes, newCmd+newArgc );
         newArgc++;
      }
      
      /*  Grab filename argument  */
      newCmd[newArgc++] = argv[3];
      
      /*  Build axes bin parameter  */
      for( i=0; i<naxes; i++ ) {
         Tcl_ListObjLength( curFile->interp, argv[5+i], &nelem );
         if( nelem != 3 ) {
            Tcl_SetResult(curFile->interp,
               "Incorrect axis binning parameters",
               TCL_STATIC);
            return TCL_ERROR;
         }
         Tcl_ListObjIndex( curFile->interp, argv[4], i, newCmd+newArgc );
         newCmd[newArgc] = Tcl_NewListObj(1,newCmd+newArgc);
         Tcl_ListObjAppendList( curFile->interp, newCmd[newArgc], argv[5+i] );
         newArgc++;
      }
      
      if( fitsTcl_histo( curFile, newArgc, newCmd ) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else {
      Tcl_SetResult(curFile->interp, "Unknown 'create' command", TCL_STATIC);
      return TCL_ERROR;
   }
   
   return TCL_OK;
}


/******************************************************************
*                             Checksum
******************************************************************/

int fitsTcl_checksum( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *checksumList="\n"
      "checksum verify\n"
      "checksum update\n";
   
   char result[16], *opt;
   int datastatus = 0;
   int hdustatus  = 0;
   int status     = 0;
   
   if( argc < 3 ) {
      Tcl_SetResult(curFile->interp, checksumList, TCL_STATIC);
      return TCL_OK;
   } 
   
   opt = Tcl_GetStringFromObj( argv[2], NULL );
   
   if( !strcmp("verify", opt) ) {
      
      /* verify the checksum keyword. */
      /* return 1 OK, 0 checksum keyword not present, -1 wrong */
      
      if( ffvcks(curFile->fptr, &datastatus, &hdustatus, &status) ) {
         dumpFitsErrStack(curFile->interp, status);
         return TCL_ERROR;
      }
      /*  Return "minimum" checksum status  */
      Tcl_SetObjResult(curFile->interp,
         Tcl_NewIntObj( hdustatus<datastatus
         ? hdustatus : datastatus) );
      
   } else if( !strcmp("update", opt) ) {
      
      if( ffpcks(curFile->fptr, &status) ) {
         dumpFitsErrStack(curFile->interp, status);
         return TCL_ERROR;
      }
      
      if( fitsUpdateFile(curFile) != TCL_OK ) {
         return TCL_ERROR;
      }
      
   } else {
      
      Tcl_SetResult(curFile->interp, "Unknown checksum option", TCL_STATIC);
      return TCL_ERROR;
      
   }
   
   return TCL_OK;
}

/******************************************************************
*                            Smooth 
******************************************************************/

int fitsTcl_smooth( FitsFD *curFile, int argc, Tcl_Obj *const argv[] )
{
   static char *smoothList= "\n"
      "smooth {width height} filename ?inPrimary? \n";
   char *opt;
   int status = 0;
   int i,j,k,l;
   
   int xwin, ywin;
   Tcl_Obj **winList;
   int nwin,len;
   fitsfile *infptr;
   fitsfile *outfptr;
   int xd,yd;
   int xl,yl,xh,yh;
   
   char outfile[FLEN_FILENAME];   
   
   float  *data;      /* original data */
   float  *sdata;     /* smoothed data */
   int ndim;
   float  nullval = -999;    /* null value */
   int anynul = 0 ;
   int id;
   float  sum;
   int npix;
   
   int bitpix, naxis;
   int maxaxis = 4;
   long naxes[999];
   int canprimary = 0;
   
   int hdunum, hdutype;
   char strtemp[FLEN_FILENAME];
   
   
   /* help */
   if( argc == 2 ) {
      Tcl_SetResult(curFile->interp, smoothList, TCL_STATIC);
      return TCL_OK;
   }
   
   if( argc < 4 ) {
      Tcl_SetResult(curFile->interp, "Wrong # of args to 'smooth'",
		       TCL_STATIC);
      return TCL_ERROR;
   }
   
   if( curFile->hduType != IMAGE_HDU ) {
      Tcl_SetResult(curFile->interp, "Cannot smooth a table", TCL_STATIC);
      return TCL_ERROR;
   }      
   
   
   /* Get the width and height parameters */
   if( Tcl_ListObjGetElements(curFile->interp, argv[2], &nwin, &winList)
      != TCL_OK ) {
      Tcl_SetResult(curFile->interp,
         "Cannot parse the window parameters",
         TCL_STATIC);
      return TCL_ERROR;
   }
   
   if( nwin!=2 ) {
      Tcl_SetResult( curFile->interp,
         "Window list should be {xwin ywin}",
         TCL_STATIC );
      return TCL_ERROR;
   }
   
   /*  Get the width/height parameters */
   if( Tcl_GetIntFromObj( curFile->interp, winList[0], &xwin)
      != TCL_OK ) {
      Tcl_SetResult( curFile->interp,
         "Error reading the width parameter",
         TCL_STATIC );
      return TCL_ERROR;
   }
   if (xwin%2 == 0) { 
      Tcl_SetResult( curFile->interp,
         "The width must be a odd number",
         TCL_STATIC );
      return TCL_ERROR;
   }
   
   if( Tcl_GetIntFromObj( curFile->interp, winList[1], &ywin)
      != TCL_OK ) {
      Tcl_SetResult( curFile->interp,
         "Error reading the height parameter",
         TCL_STATIC );
      return TCL_ERROR;
   }
   if (ywin%2 == 0) { 
      Tcl_SetResult( curFile->interp,
         "The height must be a odd number",
         TCL_STATIC );
      return TCL_ERROR;
   }
   
   /*  Get the image output file name */
   opt = Tcl_GetStringFromObj( argv[3], NULL );
   len = strlen(opt);
   if( len < FLEN_FILENAME ) {
      strcpy(outfile, opt );
   } else {
      Tcl_SetResult( curFile->interp,
         "The length of filename is too long. ",
         TCL_STATIC );
      return TCL_ERROR;
   }
   
   if( argc == 5 ) {
      if ( Tcl_GetBooleanFromObj( curFile->interp, argv[4], &canprimary )
         != TCL_OK )
         return TCL_ERROR;
   }
   
   /* open the input file */
   ffreopen( curFile->fptr, &infptr, &status );
   ffmahd( infptr, curFile->chdu, &j, &status );
   
   /*get the image parameter */
   ffgipr(infptr, maxaxis, &bitpix, &naxis, naxes, &status);
   if (naxis < 2 ) {
      Tcl_SetResult( curFile->interp,
         "The smooth algorithm only supports 2-d images.",
         TCL_STATIC );
      return TCL_ERROR;
   }
   
   for (i = 2; i < naxis; i++) { 
      if (naxes[i] > 1 ) { 
         Tcl_SetResult( curFile->interp,
            "The smooth algorithm only supports 2-d images.",
            TCL_STATIC );
         return TCL_ERROR; 
      }
   }
   
   ndim = (int)(naxes[0]*naxes[1]);
   data =  (float  *) ckalloc(ndim*sizeof(float ));
   sdata = (float  *) ckalloc(ndim*sizeof(float ));
   
   ffgpv(infptr,TFLOAT,1, naxes[0]*naxes[1],&nullval, data, &anynul, &status);  
   xd = xwin / 2;
   yd = ywin / 2;
   
   
   /* iterate over y */
   yl = 0;
   yh = yd;
   for (i=0; i < naxes[1]; i++) {
      /* initialize the kernal for this row */
      sum = 0;
      npix = 0;
      xl = 0; 
      xh = xd;
      for (k = yl; k <= yh; k++) {
         for ( l = xl; l <= xh; l++) {
            id = k * naxes[0] + l;
            if(data[id]!=nullval) {
               npix++;
               sum += data[id];
            }
         }
      }
      
      /* iterate over x */
      for (j = 0; j < naxes[0]; j++) { 
         id = i*naxes[0]+j;
         if(npix == 0) { 
            sdata[id] = nullval; 
         } else {
            sdata[id] = sum/(float )npix;
         }
         
         /* increase the x by 1 */ 
         if(j - xl == xd ) {
            for ( k = yl;  k <= yh; k++) {
               id = k*naxes[0]+xl;
               if(data[id]!=nullval) {
                  npix--;
                  sum -= data[id];
               }
            }
            xl++;
         }
         if(xh + 1< naxes[0] ) {
            xh++;
            for ( k = yl;  k <= yh; k++) {
               id = k*naxes[0]+xh;
               if(data[id]!=nullval) {
                  npix++;
                  sum += data[id];
               }
            }
         }
      }
      
      /* increase the y by 1 */
      if (i - yl == yd ) yl++; 
      if (yh + 1 < naxes[1]) yh++; 
   }
   
   /* open the output file  */
   ffopen(&outfptr, outfile,READWRITE, &status);
   if(status == FILE_NOT_OPENED) {
      status = 0;
      ffinit(&outfptr,outfile,&status);
      if(!canprimary) 
         ffcrim(outfptr,FLOAT_IMG,0,NULL,&status);
   } else if (status) {
      strcpy(strtemp,"Error opening output file: ");
      strcat(strtemp,curFile->fileName);
      Tcl_SetResult( curFile->interp,
         strtemp,
         TCL_STATIC );
      return TCL_ERROR;
   }
   
   
   /* ffcrim(outfptr,FLOAT_IMG, naxis, naxes, &status); */
   ffcphd(infptr,outfptr,&status);
   
   /* Update keywords */
   ffghdn(outfptr, &hdunum);
   i = FLOAT_IMG;
   ffuky(outfptr,TINT, "BITPIX",&i, NULL, &status); 
   ffpky(outfptr,TINT, "XWIN",&xwin,"x-width of the smoothing window", &status);
   ffpky(outfptr,TINT, "YWIN",&ywin,"y-width of the smoothing window", &status);
   strcpy(strtemp,"Smoothed output of the image file: ");
   strcat(strtemp,curFile->fileName);
   ffpcom(outfptr,strtemp, &status);
   
   /* write data*/
   ffppn(outfptr,TFLOAT,1,naxes[0]*naxes[1],sdata,&nullval,&status); 
   
   ckfree(data);
   ckfree(sdata);
   
   /* close file */
   ffclos(infptr,&status);
   ffclos(outfptr,&status);
   
   return TCL_OK;
}
