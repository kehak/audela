/*
 *  fitsUtils.c --
 *
 *      This is a collection of utility routines for fitsTcl.
 *
 */

/*
 *------------------------------------------------------------
 *
 * MODIFICATION HISTORY:
 *        2007-01-24 Pan Chai
 *            rewrite sort routine - use standard qsort routine
 *        2004-02-06 Ziqin Pan
 *            Add the following routines:
 *            1. fitsParseRangeNum
 *
 *------------------------------------------------------------
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


/*
 * ------------------------------------------------------------
 *
 *  dumpFitsErrStack --
 *
 *     Dumps the FITSIO internal error stack onto the interp result
 *
 * ------------------------------------------------------------
 */

void dumpFitsErrStack( Tcl_Interp *interp, int status )
{
   Tcl_DString stack;
   char *res;
   long len;
   
   res = Tcl_GetStringResult( interp );
   len = strlen( res );
   if( len>0 && res[len-1]!='\n' )
      Tcl_AppendResult( interp, "\n", (char*)NULL );
   dumpFitsErrStackToDString( &stack, status );
   Tcl_AppendResult( interp, Tcl_DStringValue(&stack), (char*)NULL );
   Tcl_DStringFree(&stack);
}


/*
 * ------------------------------------------------------------
 *
 *  dumpFitsErrStackToDString --
 *
 *     Dumps the FITSIO internal error stack to a Tcl_DString
 *
 * ------------------------------------------------------------
 */

void dumpFitsErrStackToDString( Tcl_DString *stack, int status )
{
   char buffer[100];
   
   Tcl_DStringInit(stack);

   ffgerr(status, buffer);
   Tcl_DStringAppend(stack, buffer, -1);

   sprintf(buffer, ". (CFITSIO error status was %d)\n", status);
   Tcl_DStringAppend(stack, buffer, -1);
   
   /* get error stack messages */
   while( ffgmsg(buffer) ) {
      strcat(buffer, "\n");
      Tcl_DStringAppend(stack, buffer, -1);
   }

   return;
}

/*
 * ------------------------------------------------------------
 *
 *    fitsMakeRegExp --
 *
 *    Takes the argc - argv pair, and a pointer to a DString, and 
 *    gobbles them into a regexp.  If caseSen = 0, expression is case
 *    sensitive, if = 1 UC, if = -1 LC...
 *
 *    Results:
 *      Fills the DString
 *   
 *    Side Effects:
 *      None
 *
 * ------------------------------------------------------------
 *
 */  

int fitsMakeRegExp( Tcl_Interp *interp,
		    int argc,
		    char *const argv[],
		    Tcl_DString *regExp,
		    int caseSen )
{
   char **list;
   int  numElem,i;
   char *p,*pattern;
   
   Tcl_DStringInit(regExp);
   while ( argc-- ) {
      
      if( Tcl_SplitList(interp,*argv,&numElem,&list) != TCL_OK ) {
	 Tcl_AppendResult(interp,"Error parsing argument: ",argv,
			  " as a Tcl list.",(char *) NULL);
	 ckfree((char *) list);
	 return TCL_ERROR;
      }
      
      for ( i = 0; i < numElem; i++ ) {
	 Tcl_DStringAppend(regExp,list[i],-1);
	 Tcl_DStringAppend(regExp,"|",-1);
      }
      ckfree((char *) list);
      argv++;
   }
   
   /*  Strip off final "|"  */
   Tcl_DStringTrunc(regExp,Tcl_DStringLength(regExp) - 1);
   
   /* Make the match CASE INSENSITIVE -- All Keywds are UPPER CASE: */
   
   if( caseSen == 1 ) {
      pattern = Tcl_DStringValue(regExp);
      
      for (p = pattern; *p ; p++ ) {
	 if( islower((unsigned char) *p) ) {
	    *p = toupper(*p);
	 }
      }
   } else if ( caseSen == -1 ) {
      pattern = Tcl_DStringValue(regExp);
      
      for (p = pattern; *p ; p++ ) {
	 if( isupper((unsigned char) *p) ) {
	    *p = tolower(*p);
	 }
      }
   }
   return TCL_OK;
}

/*
 * ------------------------------------------------------------
 *
 *    fitsParseRange --
 *
 *    This parses a list, and passes back a 2-d array of the ranges.
 *    Returns TCL_OK for success.
 *
 *    Results:
 *    Sets numInt to the number of intervals found.
 *    Fills range with the ranges...
 *
 *    Side effects:
 *    None
 *
 * ------------------------------------------------------------
 */

int fitsParseRangeNum(char *rangeStr) {
      char *delim = ",";
      int count=0;
      char* strtmp=NULL;
     
      strtmp=strdup(rangeStr);
     

      if (strtok(strtmp,delim) !=NULL) {
         count++;
         while ( strtok(NULL,delim) !=NULL ) {
           count++;
         }
      }
     if(strtmp) free(strtmp);
   
      return count;
}




int fitsParseRange( char *rangeStr,
		    int  *numInt,
		    int  *range,
		    int  maxInt,
		    int  minval,
		    int  maxval,
		    char *errMsg )
{
   char *delim = ",";
   char *tok,*strptr,*tokstore;
   int result,count,tmpVal[2],**tmpArray,i,j;
   char *rangeCpy;

   
   if( *rangeStr=='\0' || !strcmp(rangeStr,"-") || !strcmp(rangeStr,"*") ) {
      *numInt = 1;
      range[0] = minval;
      range[1] = maxval;
      return TCL_OK;
   }
   
   rangeCpy = (char *)ckalloc( (strlen(rangeStr)+1) * sizeof(char) );
   strcpy(rangeCpy,rangeStr);
   tok = (char *) strtok(rangeCpy,delim);
   if ( ! tok ) {
      sprintf(errMsg,"No tokens found");
      return TCL_ERROR;
   }
   
   tmpArray = (int **) ckalloc( (maxInt+1) * sizeof(int *) );
   tmpArray[0] = (int *) ckalloc( 2 * (maxInt+1) * sizeof(int) );
   for(i = 1; i <= maxInt; i++ ) {
      tmpArray[i] = tmpArray[i-1] + 2;
   }
   
   /*
    *  This will be the sentinal...
    */
   
   tmpArray[0][0] = minval - 1;
   
   count = 1;
   
   do {
      
      while ( *tok == ' ') tok++;
      if ( *tok == '\0' ) {
	 sprintf(errMsg,"Null token in range");
         ckfree( (char*)rangeCpy );
	 return TCL_ERROR;
      }
      tokstore = tok;
      
      strptr = (char *) strchr(tok,'-');
      
      /* This translates the first token */
      
      if ( NULL == strptr ) {
	 result = sscanf( tok, "%d", &(tmpArray[count][0]) );
	 if ( 1 != result ) {
	    sprintf(errMsg,"Error converting token %s in element %s",
		   tok,tokstore);
            ckfree( (char*)rangeCpy );
	    return TCL_ERROR;
	 }
	 if ( tmpArray[count][0] > maxval ) {
	    tmpArray[count][0] = maxval;
	 }
	 if ( tmpArray[count][0] < minval ) {
	    tmpArray[count][0] = minval;
	 }
	 tmpArray[count][1] = tmpArray[count][0];
	 (count)++;
	 continue;
      } else if (tok == strptr) {
	 tmpArray[count][0] = minval;
      } else {
	 result = sscanf(tok,"%d",&(tmpArray[count][0]));
	 if ( result != 1 ) {
	    sprintf(errMsg,"Error converting token %s in element %s",
		   tok,tokstore);
            ckfree( (char*)rangeCpy );
	    return TCL_ERROR;
	 }
      }
      
      
      /* This translates the second token */
      
      while (' ' == *(++strptr) ) ;
      if ( '\0' == *strptr ) {
	 tmpArray[count][1] = maxval;
      } else {
	 result = sscanf(strptr,"%d",&(tmpArray[count][1]));
	 if ( result != 1 ) {
	    sprintf(errMsg,"Error converting token %s in element %s",
		   strptr,tokstore);
            ckfree( (char*)rangeCpy );
	    return TCL_ERROR;
	 }
      }
      
      /* Test for the sanity of the range... */
      if ( tmpArray[count][0] > tmpArray[count][1] ) {
	 sprintf(errMsg,"Range out of order in element %s",tokstore);
         ckfree( (char*)rangeCpy );
	 return TCL_ERROR;
      }
      
      if ( tmpArray[count][0] < minval ) {
	 tmpArray[count][0] = minval;
      }
      if ( tmpArray[count][0] > maxval ) {
	 tmpArray[count][0] = maxval;
      }
      if ( tmpArray[count][1] < minval ) {
	 tmpArray[count][1] = minval;
      }
      if ( tmpArray[count][1] > maxval ) {
	 tmpArray[count][1] = maxval;
      }
      
      (count)++;
   } while((tok = (char *) strtok(NULL,delim)) && count <= maxInt) ;
   
   if ( tok != NULL ) {
      sprintf(errMsg,"Too many ranges, maximum is %d",maxInt);
      ckfree( (char*)rangeCpy );
      return TCL_ERROR;
   }
   
   if ( count == 2 ) { 
      *numInt = 1; 
      range[0] = tmpArray[1][0];
      range[1] = tmpArray[1][1];
      ckfree( (char*)rangeCpy );
      return TCL_OK;
   }
   
   
   /*
    * Now sort: an insert sort is fine, there will never be that many,
    * and they should be almost in order...
    */
   
   
   for ( i = 1; i< count; i++ ) {
      tmpVal[0] = tmpArray[i][0];
      tmpVal[1] = tmpArray[i][1];
      j = i;
      
      while(tmpArray[j-1][0] > tmpVal[0]) {
	 tmpArray[j][0] = tmpArray[j-1][0];
	 tmpArray[j][1] = tmpArray[j-1][1];
	 j--;
      }
      tmpArray[j][0] = tmpVal[0];
      tmpArray[j][1] = tmpVal[1];
   }
   
   /*
    *  Now merge the ranges, and shift down to remove the sentinal...
    */
   
   *numInt = 0;
   range[0] = tmpArray[1][0];
   range[1] = tmpArray[1][1];
   
   for ( i = 2; i < count; i++) {
      if ( tmpArray[i][0] <= range[(*numInt)*2+1] ) {
	 if ( range[(*numInt)*2+1] < tmpArray[i][1] )
	    range[(*numInt)*2+1] = tmpArray[i][1];
      } else {
	 (*numInt)++;
	 range[(*numInt)*2] = tmpArray[i][0];
	 range[(*numInt)*2+1] = tmpArray[i][1];
      }
   }
   /*
    *  Remember to return number of elements, not index of the last element...
    */
   
   (*numInt)++;
   
   ckfree((char*)tmpArray[0]);
   ckfree((char*)tmpArray);
   ckfree((char*)rangeCpy);
   
   return TCL_OK;
}



/*
 * ------------------------------------------------------------
 *
 *    makeContigArray --
 *
 *    Allocates a contiguous array of type type {c,i,l,f,d}.  
 *
 *    For 'c' type, returns a char ** pointing to 1-D string array of 
 *    nrows strings of length ncols.
 *  
 *    For 'i' returns an int ** pointing to the 2-d array, or an int* 
 *    pointing to 1-d array if ncols == 1.  The same holds for f & d.
 *
 *    Results:
 *    Allocates Memory for the array
 *
 *    Side effects:
 *    None
 *
 * ------------------------------------------------------------
 */


void *makeContigArray( int nrows, int ncols, char type ) 
{   
   int     i;
   char    *ctmpPtr, **ctmpHandle;
   int     *itmpPtr, **itmpHandle;
   long    *ltmpPtr, **ltmpHandle;
   float   *ftmpPtr, **ftmpHandle;
   double  *dtmpPtr, **dtmpHandle;
   
   if ( type == 'c' ) {

      ctmpHandle = (char **) ckalloc(nrows*sizeof(char *));
      if (ctmpHandle == NULL ) {
	 return (void *) NULL;
      }
      ctmpHandle[0] = (char *) ckalloc(nrows * ncols * sizeof(char));
      if (ctmpHandle[0] == NULL ) {
	 ckfree((char *)ctmpHandle);
	 return (void *) NULL;
      }
      ctmpPtr = ctmpHandle[0];
      for ( i = 1; i<nrows; i++ ) {
	 ctmpHandle[i] = (ctmpPtr += ncols );
      }
      memset(ctmpHandle[0],(unsigned char)'i',nrows * ncols);
      return ctmpHandle;

   } else if ( type == 'i' ) {

      if ( ncols == 1 ) {
	 itmpPtr = (int *) ckalloc(nrows * sizeof(int));
	 for( i = 0; i < nrows; i++ ) 
	    itmpPtr[i] = - 9918;
	 return itmpPtr;
      } else {
	 itmpHandle = (int **) ckalloc(nrows*sizeof(int *));
	 if (itmpHandle == NULL ) {
	    return (void *) NULL;
	 }
	 itmpHandle[0] = (int *) ckalloc(nrows * ncols * sizeof(int));
	 if (itmpHandle[0] == NULL ) {
	    ckfree((char *)itmpHandle);
	    return (void *) NULL;
	 }
	 itmpPtr = itmpHandle[0];
	 for ( i = 1; i<nrows; i++) {
	    itmpHandle[i] = (itmpPtr += ncols );
	 }
	 return itmpHandle;
      }

   } else if ( type == 'l' ) {

      if ( ncols == 1 ) {
	 return ltmpPtr = (long *) ckalloc(nrows * sizeof(long));
      } else {
	 ltmpHandle = (long **) ckalloc(nrows*sizeof(long *));
	 if (ltmpHandle == NULL ) {
	    return (void *) NULL;
	 }
	 ltmpHandle[0] = (long *) ckalloc(nrows * ncols * sizeof(long));
	 if (ltmpHandle[0] == NULL ) {
	    ckfree((char *)ltmpHandle);
	    return (void *) NULL;
	 }
	 ltmpPtr = ltmpHandle[0];
	 for ( i = 1; i<nrows; i++ ) {
	    ltmpHandle[i] = (ltmpPtr += ncols );
	 }
	 return ltmpHandle;
      }

   } else if ( type == 'f' ) {

      if ( ncols == 1 ) {
	 return ftmpPtr = (float *) ckalloc(nrows * sizeof(float));
      } else {
	 ftmpHandle = (float **) ckalloc(nrows*sizeof(float *));
	 if (ftmpHandle == NULL ) {
	    return (void *) NULL;
	 }
	 ftmpHandle[0] = (float *) ckalloc(nrows * ncols * sizeof(float));
	 if (ftmpHandle[0] == NULL ) {
	    ckfree((char *)ftmpHandle);
	    return (void *) NULL;
	 }
	 ftmpPtr = ftmpHandle[0];
	 for ( i = 1; i<nrows; i++ ) {
	    ftmpHandle[i] = (ftmpPtr += ncols );
	 }
	 return ftmpHandle;
      }

   } else if ( type == 'd' ) {

      if ( ncols == 1 ) {
	 return dtmpPtr = (double *) ckalloc(nrows * sizeof(double));
      } else {
	 dtmpHandle = (double **) ckalloc(nrows*sizeof(double *));
	 if (dtmpHandle == NULL ) {
	    return (void *) NULL;
	 }
	 dtmpHandle[0] = (double *) ckalloc(nrows * ncols * sizeof(double));
	 if (dtmpHandle[0] == NULL ) {
	    ckfree((char *)dtmpHandle);
	    return (void *) NULL;
	 }
	 dtmpPtr = dtmpHandle[0];
	 for ( i = 1; i<nrows; i++ ) {
	    dtmpHandle[i] = (dtmpPtr += ncols );
	 }
	 return dtmpHandle;
      }

   } else {

      return (void *) NULL;

   }
}


/*
 * ------------------------------------------------------------
 *
 * fitsTransColList --
 *
 * Translates the columns listed in colStr, into the column numbers
 * in the current HDU (put in colNums ).  Also records column types in 
 * colTypes.
 *
 * Results:
 * numCols, colNums, and colTypes.  Returns TCL_OK, or TCL_ERROR for column
 * not found.
 *
 * Side Effects:
 * None
 *
 * ------------------------------------------------------------
 */

int fitsTransColList( FitsFD   *curFile,
		      char     *colStr,
		      int      *numCols,
		      int       colNums[],
		      int       colTypes[],
		      int       strSize[] )
{
   char **colArray,*pattern;
   char *tmpstr;
   int foundIt,i,j;
   int colTotSize=0;
   
   if( !strcmp(colStr,"*") ) {
      
      for ( i = 0; i < curFile->CHDUInfo.table.numCols;i++)
	 colTotSize += strlen(curFile->CHDUInfo.table.colName[i])+1;
      
      colArray = (char **) ckalloc( (unsigned)curFile->CHDUInfo.table.numCols
				    * sizeof(char *) + colTotSize );
      colArray[0] = (char*)(colArray+curFile->CHDUInfo.table.numCols);
      for ( i = 0; i < curFile->CHDUInfo.table.numCols ; i++ ) {
	 colNums[i] = i;
	 if( i )
	    colArray[i] = colArray[i-1] + strlen(colArray[i-1]) + 1;
	 
	 strToUpper( curFile->CHDUInfo.table.colName[i], &tmpstr);
	 strcpy( colArray[i], tmpstr );
	 ckfree((char *) tmpstr);
      }
      *numCols = curFile->CHDUInfo.table.numCols;
      
   } else {
      
      /* Get the column list, -> UPC, match & translate to column number */
      strToUpper( colStr, &pattern );
      
      if( Tcl_SplitList(curFile->interp,pattern,numCols,&colArray) != TCL_OK ) {
	 Tcl_SetResult(curFile->interp,"Error parsing column list",TCL_STATIC);
	 ckfree(pattern);
	 return TCL_ERROR;
      }
      ckfree(pattern);

      if( *numCols >= FITS_COLMAX ) {
	 Tcl_SetResult(curFile->interp,"Too many columns in list",TCL_STATIC);
	 ckfree((char*)colArray);
	 return TCL_ERROR;
      }
   }
  
   for ( i = 0; i < *numCols; i++ ) {
      
      foundIt = 0;
      
      for ( j = 0; j < curFile->CHDUInfo.table.numCols; j++) {
	 
	 if( !strcasecmp(colArray[i], curFile->CHDUInfo.table.colName[j]) ) {
	    colNums[i]  = j+1;
	    colTypes[i] = curFile->CHDUInfo.table.colDataType[j];
	    strSize[i]  = curFile->CHDUInfo.table.strSize[j];
	    foundIt = 1;
	    break;
	 }
      }
      
      if ( ! foundIt ) {
         if( i==0 ) {
            /*  See if original colStr matches anything  */
            for ( j = 0; j < curFile->CHDUInfo.table.numCols; j++) {
               
               if( !strcasecmp(colStr, curFile->CHDUInfo.table.colName[j]) ) {
                  colNums[0]  = j+1;
                  colTypes[0] = curFile->CHDUInfo.table.colDataType[j];
                  strSize[0]  = curFile->CHDUInfo.table.strSize[j];
                  foundIt = 1;
                  break;
               }
            }
            if( foundIt ) {
               *numCols = 1;
               break;
            }
         }
	 Tcl_ResetResult(curFile->interp);
	 Tcl_AppendResult(curFile->interp,
			  "Column name was not found: ",colArray[i],
			  (char*)NULL);
	 ckfree((char*)colArray);
	 return TCL_ERROR;
      }
   }
   ckfree((char*)colArray);
   return TCL_OK;
}

int strToUpper( char *inStr, char **outStr ) 
{
   char *ptr;
   
   *outStr = (char *) ckalloc ( strlen(inStr) +1 );
   strcpy( *outStr, inStr);
   
   for ( ptr=*outStr; *ptr; ptr++ ) {
      if ( islower((unsigned char) *ptr) ) {
	 *ptr = toupper(*ptr);
      }
   }
   
   return TCL_OK;
}

int tdispGetFormat( FitsFD *curFile,
		    int colnum )
{
   int w;
   char *tokenPtr;
   char *TDispKey;
   char tmp[80];
   char rtFormat[80];
   int isDisp;
   int i, idx;
   
   /* make a copy of the display format */
   if ( strcmp(curFile->CHDUInfo.table.colDisp[colnum]," ") != 0 ) {
      strcpy(tmp, curFile->CHDUInfo.table.colDisp[colnum]); 
      isDisp = 1;  /*  TDISP exists, use for format  */
   } else {
      strcpy(tmp, curFile->CHDUInfo.table.colType[colnum]); 
      if( curFile->hduType == ASCII_TBL )
      {
	 isDisp = 1;  /*  Treat TFORM as TDISP for ASCII Tables  */
      }
      else
      {
	 isDisp = 0;  /*  TDISP does not exist, use default format  */
      }
   }
   
   /* take out the 's and spaces */
   if((TDispKey = strtok(tmp,"' "))==NULL) TDispKey = curFile->CHDUInfo.table.colType[colnum];

   if ( strpbrk(TDispKey, "Aa") ) {
      
      /* ASCII column , consider wA and Aw type */
      
      tokenPtr = strtok(TDispKey, "PApa");
      sprintf(rtFormat,"%%s");
      if( tokenPtr )
	 curFile->CHDUInfo.table.colWidth[colnum] = atoi(tokenPtr);
      else 
	 curFile->CHDUInfo.table.colWidth[colnum] = 8;
      if (curFile->CHDUInfo.table.colWidth[colnum] == 1) {
	 curFile->CHDUInfo.table.colWidth[colnum] = 8;
      }
      
   } else if ( strpbrk(TDispKey, "Ll") ) {
      
      /* Logic type */
      
      sprintf(rtFormat,"%%s");
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 curFile->CHDUInfo.table.colWidth[colnum] = 6;
      } else {
	 tokenPtr = strtok(TDispKey, "PLpl");
	 if ( tokenPtr == NULL ) {
	    curFile->CHDUInfo.table.colWidth[colnum] = 6;
	 } else {    
	    curFile->CHDUInfo.table.colWidth[colnum] = atoi(tokenPtr);
	 }
      }
      
   }  else if ( strpbrk(TDispKey, "Bb") ) {
      
      /*  Byte  */
      
      if ( (strcmp(curFile->CHDUInfo.table.colDisp[colnum], " ") ==0 )  &&
	   ( (curFile->CHDUInfo.table.colTzflag[colnum]==1) || 
	     (curFile->CHDUInfo.table.colTsflag[colnum]==1)) ) {
	 curFile->CHDUInfo.table.colWidth[colnum] = 13;
	 sprintf(rtFormat,"%%.8G");
      } else {
	 if ( !isDisp || atoi(TDispKey) != 0 ) {
	    sprintf(rtFormat,"%%u");
	    curFile->CHDUInfo.table.colWidth[colnum] = 6;
	 } else {
	    tokenPtr = strtok(TDispKey, "PBpb");
	    if ( tokenPtr == NULL ) {
	       sprintf(rtFormat,"%%u");
	       curFile->CHDUInfo.table.colWidth[colnum] = 6;
	    } else { 
	       w = atoi(tokenPtr);
	       sprintf(rtFormat,"%%%su", tokenPtr);
	       curFile->CHDUInfo.table.colWidth[colnum] = w;	
	    }
	 }
      }
      
   } else if ( strpbrk(TDispKey, "Kk") )  {
      
      /* Short Integer */
      
      if ( (strcmp(curFile->CHDUInfo.table.colDisp[colnum], " ") ==0 )  &&
	   ( (curFile->CHDUInfo.table.colTzflag[colnum]==1) || 
	     (curFile->CHDUInfo.table.colTsflag[colnum]==1)) ) {
	 curFile->CHDUInfo.table.colWidth[colnum] = 13;
	 sprintf(rtFormat,"%%.8G");
      } else {
	 if ( !isDisp || atoi(TDispKey) != 0 ) {
	    sprintf(rtFormat,"%%d");
	    curFile->CHDUInfo.table.colWidth[colnum] = 6;
	 } else {
	    tokenPtr = strtok(TDispKey, "PKpk");
	    if ( tokenPtr == NULL ) {
	       sprintf(rtFormat,"%%d");
	       curFile->CHDUInfo.table.colWidth[colnum] = 6;
	    } else {    
	       w = atoi (tokenPtr);
	       sprintf(rtFormat,"%%%sd", tokenPtr);
	       curFile->CHDUInfo.table.colWidth[colnum] = w; 
	    }
	 }
      }
      
   } else if ( strpbrk(TDispKey, "Ii") )  {
      
      /* Integer type */
      
      if ( (strcmp(curFile->CHDUInfo.table.colDisp[colnum], " ") ==0 )  &&
	   ( (curFile->CHDUInfo.table.colTzflag[colnum]==1) || 
	     (curFile->CHDUInfo.table.colTsflag[colnum]==1)) ) {
	 curFile->CHDUInfo.table.colWidth[colnum] = 13;
	 sprintf(rtFormat,"%%.8G");
      } else {
	 if ( !isDisp || atoi(TDispKey) != 0 ) {
	    sprintf(rtFormat,"%%d");
	    curFile->CHDUInfo.table.colWidth[colnum] = 6;
	 } else {
	    tokenPtr = strtok(TDispKey, "PIpi");
	    if ( tokenPtr == NULL ) {
	       sprintf(rtFormat,"%%d");
	       curFile->CHDUInfo.table.colWidth[colnum] = 6;
	    } else {    
	       w = atoi (tokenPtr);
	       sprintf(rtFormat,"%%%sd", tokenPtr);
	       curFile->CHDUInfo.table.colWidth[colnum] = w; 
	    }
	 }
      }
      
   } else if ( strpbrk(TDispKey, "Jj") ) {
      
      /*  Long Integer  */
      
      if ( (strcmp(curFile->CHDUInfo.table.colDisp[colnum], " ") ==0 )  &&
	   ( (curFile->CHDUInfo.table.colTzflag[colnum]==1) || 
	     (curFile->CHDUInfo.table.colTsflag[colnum]==1)) ) {
	 curFile->CHDUInfo.table.colWidth[colnum] = 13;
	 sprintf(rtFormat,"%%.8G");
      } else {
	 sprintf(rtFormat,"%%ld");
	 curFile->CHDUInfo.table.colWidth[colnum] = 11;
      }
      
   }  else if ( strpbrk(TDispKey, "E") ) {
      
      /*  Real  */
      
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 sprintf(rtFormat,"%%#.6E");
	 curFile->CHDUInfo.table.colWidth[colnum] = 13;
      } else {
	 tokenPtr = strtok(TDispKey, "PENSpens");
	 if (tokenPtr == NULL ) {
	    sprintf(rtFormat,"%%#.6E");
	    curFile->CHDUInfo.table.colWidth[colnum] = 13;
	 } else {
	    sprintf(rtFormat,"%%%sE", tokenPtr);
	    w = atoi(tokenPtr);
	    if ( w == 0 ) {
	       curFile->CHDUInfo.table.colWidth[colnum] = 13;
	    } else {
	       curFile->CHDUInfo.table.colWidth[colnum] = w;
	    }
	 }
      }
      
   } else if ( strpbrk(TDispKey, "Ff") ) {
      
      /*  4-byte real  */
      
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 sprintf(rtFormat,"%%#.6f");
	 curFile->CHDUInfo.table.colWidth[colnum] = 13;
      } else {
	 tokenPtr = strtok(TDispKey, "PFpf");
	 if ( tokenPtr == NULL ) {
	    sprintf(rtFormat,"%%#.6f");
	    curFile->CHDUInfo.table.colWidth[colnum] = 13;
	 } else {
	    w = atoi(tokenPtr);
	    sprintf(rtFormat,"%%%sf", tokenPtr);
	    if ( w == 0 ) {
	       curFile->CHDUInfo.table.colWidth[colnum] = 13;
	    } else {
	       curFile->CHDUInfo.table.colWidth[colnum] = w;
	    }
	 }
      } 
      
   }  else if ( strpbrk(TDispKey, "Dd") ) {
      
      /*  8-byte Real  */
      
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 sprintf(rtFormat,"%%.12E");
	 curFile->CHDUInfo.table.colWidth[colnum] = 19;
      } else {
	 tokenPtr = strtok(TDispKey, "PDEpde");
	 if (tokenPtr == NULL ) {
	    sprintf(rtFormat, "%%.12E");
	    curFile->CHDUInfo.table.colWidth[colnum] = 19;
	 } else {
	    sprintf(rtFormat,"%%%sf", tokenPtr);
	    w = atoi(tokenPtr);
	    if ( w == 0 ) {
	       curFile->CHDUInfo.table.colWidth[colnum] = 19;
	    } else {
	       curFile->CHDUInfo.table.colWidth[colnum] = w;
	    }
	 }
      }
      
   }  else if ( strpbrk(TDispKey, "Gg") ) {
      
      /*  Real  */
      
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 sprintf(rtFormat,"%%.6G");
	 curFile->CHDUInfo.table.colWidth[colnum] = 13;
      } else {
	 tokenPtr = strtok(TDispKey, "PGEpge");
	 if ( tokenPtr == NULL ) {
	    sprintf(rtFormat,"%%.6G");
	    curFile->CHDUInfo.table.colWidth[colnum] = 13;
	 } else {
	    sprintf(rtFormat,"%%%sG", tokenPtr);
	    w = atoi(tokenPtr);
	    if ( w == 0 ) {
	       curFile->CHDUInfo.table.colWidth[colnum] = 13;
	    } else {
	       curFile->CHDUInfo.table.colWidth[colnum] = w;
	    }
	 }
      }
      
   } else if ( strpbrk(TDispKey, "Cc") ) {
      
      /*  4-byte Complex  */
      
      sprintf(rtFormat,"%%#.6G");
      curFile->CHDUInfo.table.colWidth[colnum] = 30;
      
   } else if ( strpbrk(TDispKey, "Mm") ) {
      
      /*  8-byte Complex  */
      
      sprintf(rtFormat,"%%#.12G");
      curFile->CHDUInfo.table.colWidth[colnum] = 36;
      
   }  else if ( strpbrk(TDispKey, "Oo") ) {
      
      /*  Octal?  */
      
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 sprintf(rtFormat,"%%#o");
	 curFile->CHDUInfo.table.colWidth[colnum] = 8;
      } else {
	 tokenPtr = strtok(TDispKey, "POpo");
	 if ( tokenPtr == NULL ) {
	    sprintf(rtFormat,"%%#o");    
	    curFile->CHDUInfo.table.colWidth[colnum] = 8;
	 } else {
	    w = atoi(tokenPtr);
	    sprintf(rtFormat,"%%%so", tokenPtr);
	    curFile->CHDUInfo.table.colWidth[colnum] = w;
	 }
      }
      
   }  else if ( strpbrk(TDispKey, "Zz") ) {
      
      /*  ?  */
      
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 sprintf(rtFormat,"%%#x");
	 curFile->CHDUInfo.table.colWidth[colnum] = 8;
      } else {
	 tokenPtr = strtok(TDispKey, "PZpz");
	 if ( tokenPtr == NULL ) {
	    sprintf(rtFormat,"%%#x");
	    curFile->CHDUInfo.table.colWidth[colnum] = 8;
	 } else {    
	    w = atoi(tokenPtr);
	    sprintf(rtFormat,"%%%sx", tokenPtr);
	    curFile->CHDUInfo.table.colWidth[colnum] = w;
	 }
      }
      
   } else if ( strpbrk(TDispKey, "Xx") ) {
      
      /*  ?  */
      
      if ( !isDisp || atoi(TDispKey) != 0 ) {
	 sprintf(rtFormat,"%%#u");
	 curFile->CHDUInfo.table.colWidth[colnum] = 8;     
      } else {
	 tokenPtr = strtok(TDispKey, "PXpx");
	 if (tokenPtr == NULL ) {
	    sprintf(rtFormat,"%%#u");
	    curFile->CHDUInfo.table.colWidth[colnum] = 8;   
	 } else {
	    sprintf(rtFormat,"%%#u");
	    curFile->CHDUInfo.table.colWidth[colnum] = atoi(tokenPtr);
	 }
      }
      
   } else {
      
      /*  ERROR  */
      if (strlen(TDispKey) == 0) {
         return TCL_OK;
      }
      for (i=0; i<strlen(TDispKey); i++) 
      {  
         if ((TDispKey[i] >= '0' && TDispKey[i] <= '9') ||
             (TDispKey[i] >= 'A' && TDispKey[i] <= 'Z') ||
             (TDispKey[i] >= 'a' && TDispKey[i] <= 'z'))
         {
            /* check No.1 the TDIM keyword is a string */
            continue;

         } else {
            /* illegal TDISP keyword, ignored */
            return TCL_OK;
         }
      }

      /* check No.2 the TDISP keyword starts with A, L, I, B, O, Z, E, EN, ES, G or D */
      if ((TDispKey[0] == 'A') ||
          (TDispKey[0] == 'L') ||
          (TDispKey[0] == 'I') ||
          (TDispKey[0] == 'B') ||
          (TDispKey[0] == 'O') ||
          (TDispKey[0] == 'Z') ||
          (TDispKey[0] == 'F') ||
          (TDispKey[0] == 'E') ||
          (TDispKey[0] == 'G') ||
          (TDispKey[0] == 'D'))
      {
          /* check No.3 follow by a decimal digit */
          idx = 1;
          if ((TDispKey[0] == 'E' && TDispKey[1] == 'N') ||
              (TDispKey[0] == 'E' && TDispKey[1] == 'S')) 
          {
             idx = 2;
          }
       
          if (TDispKey[idx] >= '0' && TDispKey[idx] <= '9')
          {
             /* legal TDISP keyword */
             strcpy(curFile->CHDUInfo.table.colFormat[colnum], rtFormat);
             return TCL_OK;
          }
      }

      /* illegal TDISP keyword, ignored */
      return TCL_OK;
   }
   
   strcpy(curFile->CHDUInfo.table.colFormat[colnum], rtFormat);
   return TCL_OK;
}

void fitsSwap(colData *p, colData *q)
{
   colData temp;
   temp  = *p;
   *p    = *q;
   *q    = temp;
}

void fitsQSsetFlag(colData a[], int dataType, int strSize, int left, int right)
{
     /* dataType: 0: TSTRING                                    */
     /*           1: TSHORT, TINT, TBYTE, TLONG, TBIT, TLOGICAL */
     /*           2: TFLOAT, TDOUBLE                            */
     /*           3: TLONGLONG                                  */

     LONGLONG checkLongLong;
     long   checkInt;
     double checkDbl;
     char   *checkStr;

     int i;
     
     checkStr = (char *) ckalloc (strSize *sizeof(char ) + 1);
     for (i=left; i<=right; i++) {
        switch (dataType) {
            case 0 : 
              if (i == left) {
                 strcpy(checkStr, a[i].strData);
                 a[i].flag = 0;
              } else {
                 if (strcmp(checkStr, a[i].strData) == 0) {
                    a[i].flag = 1;
                 } else {
                    strcpy(checkStr, a[i].strData);
                    a[i].flag = 0;
                 }
              }
              break;
            case 1 : 
              if (i == left) {
                 checkInt = a[i].intData;
              } else {
                 if (checkInt == a[i].intData) {
                    a[i].flag = 1;
                 } else {
                    checkInt = a[i].intData;
                    a[i].flag = 0;
                 }
              }
              break; 
            case 2 : 
              if (i == left) {
                 checkDbl = a[i].dblData;
              } else {
                 if (checkDbl == a[i].dblData) {
                    a[i].flag = 1;
                 } else {
                    checkDbl = a[i].dblData;
                    a[i].flag = 0;
                 }
              }
              break; 
            case 3 : 
              if (i == left) {
                 checkLongLong = a[i].longlongData;
              } else {
                 if (checkLongLong == a[i].longlongData) {
                    a[i].flag = 1;
                 } else {
                    checkLongLong = a[i].longlongData;
                    a[i].flag = 0;
                 }
              }
              break; 
            default : 
              break; 
        }
     }
     ckfree((char *)checkStr);
}

void fitsQuickSort(colData a[], int dataType, int strSize,
		   int left, int right, int isAscend)
{
   int pivot;

   pivot = fitsSplit(a, dataType, strSize, left, right, isAscend, &left, &right);

   if (left < pivot)
      fitsQuickSort(a, dataType, strSize, left, pivot - 1, isAscend);
   if (right > pivot)
      fitsQuickSort(a, dataType, strSize, pivot + 1, right, isAscend);
}

/* 
 * Split array in the following fashion: 
 * the left subarray has all the values less than the divider
 * the right subarray has all the values greater than the divider
 */

int fitsSplit(colData a[], int dataType, int strSize,
	      int left, int right, int isAscend,int *r_left, int *r_right)
{
   colData tmpData;

   int nullset = 0;
   
   int l_hold = left;
   int r_hold = right;
   
   if ( isAscend == 1) { 
      /* push all the smaller values to the left */
      switch (dataType) {
         case 0:
            /* 0: TSTRING */
            tmpData = a[left];
   
            while ( left < right ) {
   
         
               while ((strcmp(a[right].strData,tmpData.strData) >= 0) && (left < right))
                  right--;
   
               if (left != right) {
                  a[left] = a[right];
                  left++;
               }
   
               while ((strcmp(a[left].strData,tmpData.strData) <= 0) && (left < right))
                  left++;

               if (left != right) {
                  a[right] = a[left];
                  right--;
               }
           
            }
            
            a[left] = tmpData;
            break;

         case 1:
            /* 1: TSHORT, TINT, TBYTE, TLONG, TBIT, TLOGICAL */
            tmpData = a[left];
            while ( left < right ) {
                while ((a[right].intData >= tmpData.intData) && (left < right))
                   right--;
                if (left != right) {
                   a[left] = a[right];
                   left++;
                }

                while ((a[left].intData <= tmpData.intData) && (left < right))
                   left++;
                if (left != right) {
                   a[right] = a[left];
                   right--;
                }
            }

            a[left] = tmpData;
            break; 

         case 2:
            /* 2: TFLOAT, TDOUBLE                            */
            tmpData = a[left];
            while ( left < right ) {
                while ((a[right].dblData >= tmpData.dblData) && (left < right))
                   right--;
                if (left != right) {
                   a[left] = a[right];
                   left++;
                }

                while ((a[left].dblData <= tmpData.dblData) && (left < right))
                   left++;
                if (left != right) {
                   a[right] = a[left];
                   right--;
                }
            }

            a[left] = tmpData;
            break; 

         case 3:
            /* 3: TLONGLONG                                  */
            tmpData = a[left];
            while ( left < right ) {
                while ((a[right].longlongData >= tmpData.longlongData) && (left < right))
                   right--;
                if (left != right) {
                   a[left] = a[right];
                   left++;
                }

                while ((a[left].longlongData <= tmpData.longlongData) && (left < right))
                   left++;
                if (left != right) {
                   a[right] = a[left];
                   right--;
                }
            }

            a[left] = tmpData;
            break; 
      }
   } else {
      /* push all the smaller values to the RIGHT */
      switch (dataType) {
         case 0:
            /* 0: TSTRING */
            tmpData = a[left];
   
            while ( left < right ) {
   
               while ((strcmp(a[right].strData,tmpData.strData) >= 0) && (left < right))
                  right--;
   
               if (left != right) {
                  a[left] = a[right];
                  left++;
               }
   
               while ((strcmp(a[left].strData,tmpData.strData) <= 0) && (left < right))
                  left++;

               if (left != right) {
                  a[right] = a[left];
                  right--;
               }
           
            }
            
            a[left] = tmpData;
            break;

         case 1:
            /* 1: TSHORT, TINT, TBYTE, TLONG, TBIT, TLOGICAL */
            tmpData = a[left];
            while ( left < right ) {
                while ((a[right].intData <= tmpData.intData) && (left < right))
                   right--;
                if (left != right) {
                   a[left] = a[right];
                   left++;
                }

                while ((a[left].intData >= tmpData.intData) && (left < right))
                   left++;
                if (left != right) {
                   a[right] = a[left];
                   right--;
                }
            }

            a[left] = tmpData;
            break; 

         case 2:
            /* 2: TFLOAT, TDOUBLE                            */
            tmpData = a[left];
            while ( left < right ) {
                while ((a[right].dblData <= tmpData.dblData) && (left < right))
                   right--;
                if (left != right) {
                   a[left] = a[right];
                   left++;
                }

                while ((a[left].dblData >= tmpData.dblData) && (left < right))
                   left++;
                if (left != right) {
                   a[right] = a[left];
                   right--;
                }
            }

            a[left] = tmpData;
            break; 

         case 3:
            /* 3: TLONGLONG                                  */
            tmpData = a[left];
            while ( left < right ) {
                while ((a[right].longlongData <= tmpData.longlongData) && (left < right))
                   right--;
                if (left != right) {
                   a[left] = a[right];
                   left++;
                }

                while ((a[left].longlongData >= tmpData.longlongData) && (left < right))
                   left++;
                if (left != right) {
                   a[right] = a[left];
                   right--;
                }
            }

            a[left] = tmpData;
            break; 
      }
   }  
   
   *r_left = l_hold;
   *r_right = r_hold;
   
   return(left);
}

void fitsFreeRawColData( colData columndata[], long numRows )
{
   long i;

   for(i=0; i<numRows; i++) {
      ckfree( (char*) columndata[i].colBuffer );
   }
}

void fitsRandomizeColData( colData columndata[], long numRows )
{
   long j, ntodo;
   long i1, i2;

   /* want to do some random shuffling to avoid the worst case ,e.g. the
    * table is already sorted, which will take a loooooooog time 
    * but that doesn't work on the WIN32 */
   
   ntodo = numRows/4;

   for ( j= 0;j < ntodo; j++) {
      /*  Use the best random number generator each machine has to offer  */
#ifdef __WIN32__
      i1 = (long) ( ( ((double)rand())/RAND_MAX ) * numRows );
      i2 = (long) ( ( ((double)rand())/RAND_MAX ) * numRows );
#else 
# ifdef macintosh
      i1 = (long) ( ( ((double)rand())/RAND_MAX ) * numRows );
      i2 = (long) ( ( ((double)rand())/RAND_MAX ) * numRows );
# else
#  ifdef __APPLE__
      i1 = (long) ( ( ((double)rand())/RAND_MAX ) * numRows );
      i2 = (long) ( ( ((double)rand())/RAND_MAX ) * numRows );
#  else
      i1 = (long) (drand48()*numRows);
      i2 = (long) (drand48()*numRows);
#  endif
# endif
#endif
      fitsSwap(&columndata[i1], &columndata[i2]);
   }
}   


Tcl_Obj *fitsTcl_Ptr2Lst( Tcl_Interp *interp, void *thePtr, char *undef,
			  int dataType, long nelem )
{
   union {
      unsigned char  *byte;
      short          *shrt;
      int            *lng;
      float          *flt;
      double         *dbl;
      LONGLONG       *llong;
      void           *ptr;
   } ptrs;
   Tcl_Obj *dataLst;
   int i;
   char tmpStr[126];

   ptrs.ptr = thePtr;

   dataLst = Tcl_NewListObj( 0, NULL );
   switch( dataType ) {

   case LONGLONG_DATA:
      for( i=0; i<nelem; i++, ptrs.llong++ ) {
	 if( (undef && undef[i]) || *ptrs.llong==LONGLONG_MAX )
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewStringObj( "NULL", -1 ) );
	 else {
#ifdef __WIN32__
            sprintf(tmpStr, "%I64d", *ptrs.llong);
#else
            sprintf(tmpStr, "%lld", *ptrs.llong);
#endif
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewStringObj( tmpStr, -1 ) );
         }
      }
      break;

   case DOUBLE_DATA:
      for( i=0; i<nelem; i++, ptrs.dbl++ ) {
	 if( (undef && undef[i]) || *ptrs.dbl==DBL_MAX )
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewStringObj( "NULL", -1 ) );
	 else
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewDoubleObj( *ptrs.dbl ) );
      }
      break;

   case FLOAT_DATA:
      for( i=0; i<nelem; i++, ptrs.flt++ ) {
	 if( (undef && undef[i]) || *ptrs.flt==FLT_MAX )
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewStringObj( "NULL", -1 ) );
	 else
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewDoubleObj( (double)*ptrs.flt ) );
      }
      break;

   case INT_DATA:
      for( i=0; i<nelem; i++, ptrs.lng++ ) {
	 if( (undef && undef[i]) || *ptrs.lng==INT_MAX )
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewStringObj( "NULL", -1 ) );
	 else
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewIntObj( (double)*ptrs.lng ) );
      }
      break;

   case SHORTINT_DATA:
      for( i=0; i<nelem; i++, ptrs.shrt++ ) {
	 if( (undef && undef[i]) || *ptrs.shrt==SHRT_MAX )
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewStringObj( "NULL", -1 ) );
	 else
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewIntObj( (int)*ptrs.shrt ) );
      }
      break;

   case BYTE_DATA:
      for( i=0; i<nelem; i++, ptrs.byte++ ) {
	 if( (undef && undef[i]) || *ptrs.byte==UCHAR_MAX )
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewStringObj( "NULL", -1 ) );
	 else
	    Tcl_ListObjAppendElement( interp, dataLst,
				      Tcl_NewIntObj( (int)*ptrs.byte ) );
      }
      break;
   }

   return dataLst;
}


void *fitsTcl_Lst2Ptr( Tcl_Interp *interp, Tcl_Obj *dataLst, int dataType,
		       long *nelem, char **undef )
{
   union {
      unsigned char  *byte;
      short          *shrt;
      int            *lng;
      float          *flt;
      double         *dbl;
      LONGLONG       *llong;
      void           *ptr;
   } ptrs;
   double dbl;
   int lng;
   Tcl_Obj **dataObj;
   int i;
   char *tmpStr;
   
   Tcl_ListObjGetElements( interp, dataLst, &i, &dataObj );
   *nelem = i;

   switch( dataType ) {

   case LONGLONG_DATA:
      ptrs.llong  = (LONGLONG *)ckalloc( *nelem * sizeof(LONGLONG) );

      if( undef )
	 *undef = (char   *)ckalloc( *nelem * sizeof(char  ) );

      for( i=0; i<*nelem; i++, dataObj++ ) {
	 if( Tcl_GetDoubleFromObj( interp, *dataObj, ptrs.dbl+i ) != TCL_OK ) {
	   tmpStr = Tcl_GetStringFromObj( *dataObj, NULL );

	   if( !strcasecmp( tmpStr, "NULL" ) ) {
	     ptrs.llong[i] = LONGLONG_MAX;
	     if ( undef )
                (*undef)[i] = 1;
           }
	 } else if( undef ) {
            sprintf(tmpStr, "%f", ptrs.dbl[i]);
            ptrs.llong[i] = fitsTcl_atoll(tmpStr);
	    (*undef)[i] = 0;
         }
      }
      break;

   case DOUBLE_DATA:
      ptrs.dbl  = (double *)ckalloc( *nelem * sizeof(double) );
      if( undef )
	 *undef = (char   *)ckalloc( *nelem * sizeof(char  ) );
      for( i=0; i<*nelem; i++, dataObj++ ) {
	 if( Tcl_GetDoubleFromObj( interp, *dataObj, ptrs.dbl+i )
	     != TCL_OK ) {
	    tmpStr = Tcl_GetStringFromObj( *dataObj, NULL );
	    if( !strcasecmp( tmpStr, "NULL" ) ) {
	       ptrs.dbl[i] = DBL_MAX;
	       if( undef )
		  (*undef)[i] = 1;
	    }
	 } else if( undef )
	    (*undef)[i] = 0;
      }
      break;

   case FLOAT_DATA:
      ptrs.flt  = (float *)ckalloc( *nelem * sizeof(float) );
      if( undef )
	 *undef = (char  *)ckalloc( *nelem * sizeof(char ) );
      for( i=0; i<*nelem; i++, dataObj++ ) {
	 if( Tcl_GetDoubleFromObj( interp, *dataObj, &dbl )
	     != TCL_OK ) {
	    tmpStr = Tcl_GetStringFromObj( *dataObj, NULL );
	    if( !strcasecmp( tmpStr, "NULL" ) ) {
	       ptrs.flt[i] = FLT_MAX;
	       if( undef )
		  (*undef)[i] = 1;
	    }
	 } else {
	    ptrs.flt[i] = dbl;
	    if( undef )
	       (*undef)[i] = 0;
	 }
      }
      break;

   case INT_DATA:
      ptrs.lng  = (int  *)ckalloc( *nelem * sizeof(int ) );
      if( undef )
	 *undef = (char *)ckalloc( *nelem * sizeof(char) );
      for( i=0; i<*nelem; i++, dataObj++ ) {
	 if( Tcl_GetIntFromObj( interp, *dataObj, ptrs.lng+i )
	     != TCL_OK ) {
	    tmpStr = Tcl_GetStringFromObj( *dataObj, NULL );
	    if( !strcasecmp( tmpStr, "NULL" ) ) {
	       ptrs.lng[i] = INT_MAX;
	       if( undef )
		  (*undef)[i] = 1;
	    }
	 } else if( undef )
	    (*undef)[i] = 0;
      }
      break;

   case SHORTINT_DATA:
      ptrs.shrt = (short *)ckalloc( *nelem * sizeof(short) );
      if( undef )
	 *undef = (char  *)ckalloc( *nelem * sizeof(char ) );
      for( i=0; i<*nelem; i++, dataObj++ ) {
	 if( Tcl_GetIntFromObj( interp, *dataObj, &lng )
	     != TCL_OK ) {
	    tmpStr = Tcl_GetStringFromObj( *dataObj, NULL );
	    if( !strcasecmp( tmpStr, "NULL" ) ) {
	       ptrs.shrt[i] = SHRT_MAX;
	       if( undef )
		  (*undef)[i] = 1;
	    }
	 } else {
	    ptrs.shrt[i] = lng;
	    if( undef )
	       (*undef)[i] = 0;
	 }
      }
      break;

   case BYTE_DATA:
      ptrs.byte = (unsigned char *)ckalloc( *nelem * sizeof(char) );
      if( undef )
	 *undef = (char          *)ckalloc( *nelem * sizeof(char) );
      for( i=0; i<*nelem; i++, dataObj++ ) {
	 if( Tcl_GetIntFromObj( interp, *dataObj, &lng )
	     != TCL_OK ) {
	    tmpStr = Tcl_GetStringFromObj( *dataObj, NULL );
	    if( !strcasecmp( tmpStr, "NULL" ) ) {
	       ptrs.byte[i] = UCHAR_MAX;
	       if( undef )
		  (*undef)[i] = 1;
	    }
	 } else {
	    ptrs.byte[i] = lng;
	    if( undef )
	       (*undef)[i] = 0;
	 }
      }
      break;
   }

   return ptrs.ptr;
}

int fitsTcl_SetDims( Tcl_Interp *interp, Tcl_Obj **dimObj,
		     int naxis, long naxes[] )
{
   int i;

   *dimObj = Tcl_NewListObj( 0, NULL );
   for( i=0; i<naxis; i++ ) {
      if( Tcl_ListObjAppendElement( interp, *dimObj, Tcl_NewLongObj(*naxes++) )
	  != TCL_OK )
	 return TCL_ERROR;
   }

   return TCL_OK;
}

int fitsTcl_GetDims( Tcl_Interp *interp, Tcl_Obj *dimObj,
		     long *nelem, int *naxis, long naxes[] )
{
   int i;
   Tcl_Obj **dims;

   Tcl_ListObjGetElements( interp, dimObj, naxis, &dims );
   *nelem = 1;
   for( i=0; i<*naxis; i++ ) {
      if( Tcl_GetLongFromObj( interp, dims[i], naxes ) != TCL_OK )
	 return TCL_ERROR;
      *nelem *= *naxes++;
   }

   return TCL_OK;
}

void *fitsTcl_ReadPtrStr( Tcl_Obj *ptrObj )
{
   char *str;
   void *ptr;

   str = Tcl_GetStringFromObj(ptrObj, NULL);
   if( sscanf( str, PTRFORMAT, &ptr) == EOF )
      ptr = NULL;
   return ptr;
}

LONGLONG fitsTcl_atoll (char *inputStr) {

   LONGLONG ig=0;
   int      sign=1;

   /* test for prefixing white space */
   while (*inputStr == ' ' || *inputStr == '\t')
         inputStr++;

   /* check sign */
   if (*inputStr == '-')
      sign = -1; 

   /* convert string to int */
   while (*inputStr != '\0') 
      if (*inputStr >= '0' && *inputStr <= '9')
#ifdef __WIN32__
         ig = ig * 10I64 + *inputStr++ - '0';
#else
         ig = ig * 10LL + *inputStr++ - '0';
#endif
      else
         inputStr++;

   return (ig * (LONGLONG)sign);
}

