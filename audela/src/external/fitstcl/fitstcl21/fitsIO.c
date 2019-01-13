/*
 *  fitsIO.c --
 *
 *      This is the file-handling routines which use CFITSIO
 *
 */


/*
 *------------------------------------------------------------
 * 
 * MODIFICATION HISTORY:
 *           2004-02-06 Ziqin Pan:
 *           Added the following routines:
 *              1. fitsSelectRowsExpr
 *              2. fitsCalculaterngColumn
 *              3. fitsDeleteRowsRange
 *              4. fitsDeleteRowlist
 *           Updated the following routines:
 *              1. fitsSortTable:
 *                 return a list of row index which represents 
 *                  pre-sorted table row
 *
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


/* ------------------------------------------------------------
 * 
 *    fitsMoveHDU --
 *
 *    Given a FitsHD, move nmove.  
 *    If direction = 1, move forward
 *                 = -1, move backwards
 *                 = 0, move absolute                       
 *    If there is an error, then exit with status != 0 
 *     (>0 => FITSIO err stat...)
 *
 *    Results:
 *        Alters the CHDU
 * 
 *    Side Effects:
 *        None
 *
 * ------------------------------------------------------------
 */
int fitsMoveHDU( FitsFD *curFile,
		 int nmove,
		 int direction )
{
   if( fitsJustMoveHDU(curFile, nmove, direction) != TCL_OK ) {
      return TCL_ERROR;
   }
   
   if( fitsLoadHDU(curFile) != TCL_OK ) {
      return TCL_ERROR;
   }   
   
   return TCL_OK;
}


/**************************************************************
 * load the table and the rest
 **************************************************************/

int fitsLoadHDU( FitsFD *curFile )
{
   int i,status=0;
   int simple,extend;
   long pcount, gcount, rowlen, varidat;
   long tbcol[FITS_COLMAX];
   char tmpStr[80];
   char tmpKey[FLEN_KEYWORD];
   Tcl_HashEntry *thisEntry; 
   Keyword *tmpKwd;
   char testChar[1024];
   char numChar[1024];
   char *p, *n;
   long len;
   
   /* Now get the Header info for the CHDU */

   switch( curFile->hduType ) {

   case IMAGE_HDU:

      ffghpr(curFile->fptr,
	     FITS_MAXDIMS,
	     &simple,
	     &curFile->CHDUInfo.image.bitpix,
	     &curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     &pcount, &gcount, &extend, &status);
      strcpy(curFile->extname ,"Image");
      break;

   case ASCII_TBL:

      ffghtb(curFile->fptr,
	     FITS_COLMAX,
	     &curFile->CHDUInfo.table.rowLen,
	     &curFile->CHDUInfo.table.numRows,
	     &curFile->CHDUInfo.table.numCols,
	     curFile->CHDUInfo.table.colName,
	     tbcol,
	     curFile->CHDUInfo.table.colType,
	     curFile->CHDUInfo.table.colUnit,
	     curFile->extname, &status);
      break;
      
   case BINARY_TBL:
      
      ffghbn(curFile->fptr,
	     FITS_COLMAX,
	     &curFile->CHDUInfo.table.numRows,
	     &curFile->CHDUInfo.table.numCols,
             curFile->CHDUInfo.table.colName,
             curFile->CHDUInfo.table.colType,
             curFile->CHDUInfo.table.colUnit,
	     curFile->extname,
	     &varidat, &status);
      ffgkyj(curFile->fptr,"NAXIS1",&rowlen,
	     NULL,&status);
      curFile->CHDUInfo.table.rowLen = rowlen;
      break;
      
   default:

      sprintf(tmpStr, "Unrecognized Extension type: %d", curFile->hduType);
      Tcl_SetResult(curFile->interp, tmpStr, TCL_VOLATILE);
      return TCL_ERROR;

   }
   
   /* Now LOAD the kwds hash table... */    

   if( TCL_OK != fitsLoadKwds(curFile) ) { 
      fitsCloseFile((ClientData) curFile);
      return TCL_ERROR;
   }
   
   /*
    *  Also, search BZERO and BSCALE from keyword hash table for speed
    */

   if ( IMAGE_HDU == curFile->hduType ) {

      thisEntry = Tcl_FindHashEntry(curFile->kwds, "BZERO");
      if ( NULL == thisEntry ) {
	 curFile->CHDUInfo.image.bzero = 0.0;
	 curFile->CHDUInfo.image.bzflag = 0;
      } else {
	 tmpKwd = (Keyword *) Tcl_GetHashValue(thisEntry);
	 curFile->CHDUInfo.image.bzero = atof( tmpKwd->value );
	 curFile->CHDUInfo.image.bzflag = 1;
      }	 
      thisEntry = Tcl_FindHashEntry(curFile->kwds, "BSCALE");
      if ( NULL == thisEntry ) {       
	 curFile->CHDUInfo.image.bscale = 1.0;
	 curFile->CHDUInfo.image.bsflag = 0;
      } else if (status == 0) {
	 tmpKwd = (Keyword *) Tcl_GetHashValue(thisEntry);	  
	 curFile->CHDUInfo.image.bscale = atof( tmpKwd->value );
	 curFile->CHDUInfo.image.bsflag = 1;
      }
      thisEntry = Tcl_FindHashEntry(curFile->kwds, "BLANK");
      if ( NULL == thisEntry ) {       
	 strcpy(curFile->CHDUInfo.image.blank, " ");
      } else if (status == 0) {
	 tmpKwd = (Keyword *) Tcl_GetHashValue(thisEntry);	  
	 strcpy(curFile->CHDUInfo.image.blank, tmpKwd->value);
      }      

   } else {  /*  Table  */

      for (i=0; i < curFile->CHDUInfo.table.numCols; i++) {

	 sprintf(tmpKey,"TZERO%d",i+1);
	 thisEntry = Tcl_FindHashEntry(curFile->kwds, tmpKey);	 
	 if ( thisEntry == NULL ) {	 
	    curFile->CHDUInfo.table.colTzero[i]  = 0.0;
	    curFile->CHDUInfo.table.colTzflag[i] = 0;
	 } else {
	    tmpKwd = (Keyword *) Tcl_GetHashValue(thisEntry);
	    curFile->CHDUInfo.table.colTzero[i] = atof(tmpKwd->value);	   
	    curFile->CHDUInfo.table.colTzflag[i] = 1;
	 } 

	 sprintf(tmpKey,"TSCAL%d",i+1);
	 thisEntry = Tcl_FindHashEntry(curFile->kwds, tmpKey);	 
	 if ( thisEntry == NULL ) {	
	    curFile->CHDUInfo.table.colTscale[i]  = 1.0;
	    curFile->CHDUInfo.table.colTsflag[i] = 0;
	 } else {
	    tmpKwd = (Keyword *) Tcl_GetHashValue(thisEntry);
	    curFile->CHDUInfo.table.colTscale[i] = atof(tmpKwd->value );	
	    curFile->CHDUInfo.table.colTsflag[i] = 1;
	 }
	 
	 sprintf(tmpKey,"TDISP%d",i+1);
	 thisEntry = Tcl_FindHashEntry(curFile->kwds, tmpKey);	 
	 if ( thisEntry == NULL ) {	
	    strcpy(curFile->CHDUInfo.table.colDisp[i], " ");
	 } else {
	    tmpKwd = (Keyword *) Tcl_GetHashValue(thisEntry);
	    strcpy(curFile->CHDUInfo.table.colDisp[i], tmpKwd->value);
	 }
	 
	 sprintf(tmpKey,"TNULL%d",i+1);
	 thisEntry = Tcl_FindHashEntry(curFile->kwds, tmpKey);	 
	 if ( thisEntry == NULL ) {	
	    strcpy(curFile->CHDUInfo.table.colNull[i], "NULL");
	 } else {
	    tmpKwd = (Keyword *) Tcl_GetHashValue(thisEntry);
	    strcpy(curFile->CHDUInfo.table.colNull[i], tmpKwd->value);
	 }

      } 
   }

   /* Finally fill the dataType with the translation of the TTYPE keywords...
    * and set the variable traces on the columns...
    */
   
   if( IMAGE_HDU == curFile->hduType ) {
      switch ( curFile->CHDUInfo.image.bitpix ) {
      case 8:
	 curFile->CHDUInfo.image.dataType = TBYTE;
	 break;
      case 16:
	 curFile->CHDUInfo.image.dataType = TSHORT;
	 break;
      case 32:
	 curFile->CHDUInfo.image.dataType = TINT;
	 break;
      case 64:
         /* 11/01/2006: added to handle 64 bits fits file */
	 curFile->CHDUInfo.image.dataType = TLONGLONG;
	 break;
      case -32:
	 curFile->CHDUInfo.image.dataType = TFLOAT;
	 break;
      case -64:
	 curFile->CHDUInfo.image.dataType = TDOUBLE;
	 break;
      default:
	 Tcl_SetResult(curFile->interp,
		       "fitsTcl Error:  unknown image type", TCL_STATIC);
	 return TCL_ERROR;  
	 break;   
      }
      /* if BSCALE or BZERO exists, set type to double */
      if( curFile->CHDUInfo.image.bzflag || 
	  curFile->CHDUInfo.image.bsflag ) {
	 curFile->CHDUInfo.image.dataType = TDOUBLE;
      } 
      
   } else {  /*  Table  */

      for (i = 0; i < curFile->CHDUInfo.table.numCols; i++ ) {	  
	 /* judging for TDISP or TTYPE, load the column width and display format
	  */
	 
	 if ( TCL_ERROR == tdispGetFormat(curFile, i) ) { 
	    return TCL_ERROR;
	 }

	 /* See if it's a vector column */
	 
	 if (BINARY_TBL == curFile->hduType) {
	    if (strchr(curFile->CHDUInfo.table.colType[i],'P')) {
	       /* need to find the vector size */
	       curFile->CHDUInfo.table.vecSize[i] = -1;
               p = strchr(curFile->CHDUInfo.table.colType[i],'P');
               strcpy(testChar, p);

               /* find the number after xPA(nnnnnnn) */
               n = strpbrk(testChar, "0123456789");
               if ( n != (char *)NULL ) {
                  len = strspn(n, "0123456789");
                  memset (numChar, '\0', 1024);
                  strncpy(numChar, n, len);
	          sscanf (numChar, "%ld", &(curFile->CHDUInfo.table.vecSize[i]));
               } else {
		  curFile->CHDUInfo.table.vecSize[i] = -1;
               }
	    } else {
	       long tmp=0;
	       tmp = atol(curFile->CHDUInfo.table.colType[i]);
	       if (tmp < 1) {
                  if( curFile->CHDUInfo.table.colType[i][0]=='0' )
                     curFile->CHDUInfo.table.vecSize[i] = 0;
                  else
                     curFile->CHDUInfo.table.vecSize[i] = 1;
	       } else {  
		  curFile->CHDUInfo.table.vecSize[i] = tmp;
	       }
	    }
	 } else {
	    curFile->CHDUInfo.table.vecSize[i] = 1;
	 }
	 
	 /* init colMin and colMax */

	 curFile->CHDUInfo.table.colMin[i] = DBL_MIN;
	 curFile->CHDUInfo.table.colMax[i] = DBL_MAX;

	 /*
	  *  Now ascertain the colDataType
	  */	    

	 if ( strchr(curFile->CHDUInfo.table.colType[i],'A')) {
	    curFile->CHDUInfo.table.colDataType[i] = TSTRING;
	 } else if (strchr(curFile->CHDUInfo.table.colType[i],'I')) {
	    if( curFile->CHDUInfo.table.colTzflag[i] ||
		curFile->CHDUInfo.table.colTsflag[i] ) { 
	       curFile->CHDUInfo.table.colDataType[i] = TDOUBLE; 
	    } else {
	       /* in an ASCII table, an integer could be a long int */
	       if ( curFile->hduType == ASCII_TBL ) {
		  curFile->CHDUInfo.table.colDataType[i] = TLONG; 
	       } else { 
		  curFile->CHDUInfo.table.colDataType[i] = TSHORT; 
	       }
	    }
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'K')) {
	    if( curFile->CHDUInfo.table.colTzflag[i] ||
		curFile->CHDUInfo.table.colTsflag[i] ) { 
	       curFile->CHDUInfo.table.colDataType[i] = TDOUBLE; 
	    } else {
	       curFile->CHDUInfo.table.colDataType[i] = TLONGLONG; 
	    }
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'J')) {
	    if( curFile->CHDUInfo.table.colTzflag[i] ||
		curFile->CHDUInfo.table.colTsflag[i] ) { 
	       curFile->CHDUInfo.table.colDataType[i] = TDOUBLE; 
	    } else {
	       curFile->CHDUInfo.table.colDataType[i] = TLONG; 
	    }
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'X')) {
	    curFile->CHDUInfo.table.colDataType[i] = TBIT; 
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'L')) {
	    curFile->CHDUInfo.table.colDataType[i] = TLOGICAL; 
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'B')){
	    if( curFile->CHDUInfo.table.colTzflag[i] ||
		curFile->CHDUInfo.table.colTsflag[i] ) { 
	       curFile->CHDUInfo.table.colDataType[i] = TDOUBLE; 
	    } else {
	       curFile->CHDUInfo.table.colDataType[i] = TBYTE; 
	    }
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'E') ||
		     strchr(curFile->CHDUInfo.table.colType[i],'F') ) {
	    /* in an ASCII table , a float could be a double */
	    if ( curFile->hduType == ASCII_TBL ) {
	       curFile->CHDUInfo.table.colDataType[i] = TDOUBLE;
	    } else { 
	       curFile->CHDUInfo.table.colDataType[i] = TFLOAT;
	    }
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'D')){
	    curFile->CHDUInfo.table.colDataType[i] = TDOUBLE; 
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'C')){
	    curFile->CHDUInfo.table.colDataType[i] = TCOMPLEX; 
	 } else if ( strchr(curFile->CHDUInfo.table.colType[i],'M')){
	    curFile->CHDUInfo.table.colDataType[i] = TDBLCOMPLEX; 
	 } else {
	    Tcl_ResetResult(curFile->interp);
	    Tcl_AppendResult(curFile->interp,
			     "Unknown or unsupported TFORM: ",
			     curFile->CHDUInfo.table.colType[i],
			     " for column ",
			     curFile->CHDUInfo.table.colName[i],
			     (char*)NULL);
	    return TCL_ERROR;
	 }

	 /*
	  *  Now ascertain the default strSize's of the column
	  *  (Use minimum of 4 to handle "NULL" values)
	  */	    

	 if( curFile->hduType == BINARY_TBL ) {
	    switch( curFile->CHDUInfo.table.colDataType[i] ) {
	    case TSTRING:
	       /* If it's a variable size vector, it's
	          format could be 1PA, but it takes more than 1  */

	       if( strchr(curFile->CHDUInfo.table.colType[i],'P') ) {
                  p = strchr(curFile->CHDUInfo.table.colType[i],'P');
                  strcpy(testChar, p);

                  /* find the number after xPA(nnnnnnn) */
                  n = strpbrk(testChar, "0123456789");
                  len = strspn(n, "0123456789");
                  if ( n != (char *)NULL ) {
                     memset (numChar, '\0', 1024);
                     strncpy(numChar, n, len);
                     sscanf (numChar, "%d", &(curFile->CHDUInfo.table.strSize[i]));
                  } else {
                     curFile->CHDUInfo.table.strSize[i] = 80;
                  }
	       } else {
		  sscanf(curFile->CHDUInfo.table.colType[i],
			 "%dA",&(curFile->CHDUInfo.table.strSize[i]));
		  if( curFile->CHDUInfo.table.strSize[i] < 4 )
		     curFile->CHDUInfo.table.strSize[i] = 4;
	       }
	       break;
	    case TLOGICAL:
	       curFile->CHDUInfo.table.strSize[i] =  4;
	       break;
	    case TBIT:
	       curFile->CHDUInfo.table.strSize[i] =  4;
	       break;
	    case TBYTE:
	       curFile->CHDUInfo.table.strSize[i] =  4;
	       break;
	    case TSHORT:
	       curFile->CHDUInfo.table.strSize[i] =  8;
	       break;
	    case TINT:
	       curFile->CHDUInfo.table.strSize[i] = 12;
	       break;
	    case TLONG:
	       curFile->CHDUInfo.table.strSize[i] = 16;
	       break;
	    case TFLOAT:
	       curFile->CHDUInfo.table.strSize[i] = 16;
	       break;
	    case TLONGLONG:
	       curFile->CHDUInfo.table.strSize[i] = 24;
	       break;
	    case TDOUBLE:
	       curFile->CHDUInfo.table.strSize[i] = 24;
	       break;
	    case TCOMPLEX:
	       curFile->CHDUInfo.table.strSize[i] = 36;
	       break;
	    case TDBLCOMPLEX:
	       curFile->CHDUInfo.table.strSize[i] = 52;
	       break;
	    default:
	       curFile->CHDUInfo.table.strSize[i] = 24;
	       break;
	    }

	 } else {  /*  ASCII Table... Use actual column width  */

	    if( i+1 < curFile->CHDUInfo.table.numCols )
	       curFile->CHDUInfo.table.strSize[i] = tbcol[i+1] - tbcol[i];
	    else 
	       curFile->CHDUInfo.table.strSize[i] =
		  curFile->CHDUInfo.table.rowLen - tbcol[i] + 1;
	    if( curFile->CHDUInfo.table.strSize[i] < 4 )
	       curFile->CHDUInfo.table.strSize[i] = 4;
	    
	 }
      }
   }

   /* now set the hdu status */
   curFile->CHDUInfo.table.loadStatus = 1;
   return TCL_OK;
}  

/* just move the keyword and clean up all the data struct */
int fitsJustMoveHDU( FitsFD *curFile,
		     int    nmove,
		     int    direction )
{
   int status=0;
   int newHduType;
   char errMsg[80];
   
   /* move to the right hdu */
   if ( 1 == direction || -1 == direction ) {
      ffmrhd(curFile->fptr,nmove,&newHduType,&status); 
   } else {
      ffmahd(curFile->fptr,nmove,&newHduType,&status);
   }
   
   
   if ( curFile->CHDUInfo.table.loadStatus > 0 ) {
      /* clean up the old keywords hash table in the old header */
      if ( fitsFlushKeywords(curFile) ) {
	 Tcl_SetResult(curFile->interp,
		       "Error dumping altered keywords, proceed with caution",
		       TCL_STATIC);
      }
   }
   
   if( status ) {
      dumpFitsErrStack(curFile->interp,status);
      return TCL_ERROR;
   } 
   
   
   /* Should check here to see if you need
      to expand the column info blocks... */
   
   if( newHduType != IMAGE_HDU ) {
      if( curFile->CHDUInfo.table.numCols > FITS_COLMAX ) {
	 sprintf(errMsg,"Too many columns in Fits file, MAX is %d",
		 FITS_COLMAX);
	 Tcl_SetResult(curFile->interp, errMsg, TCL_VOLATILE);
	 return TCL_ERROR;
      }
   }
   
   if( fitsUpdateCHDU(curFile, newHduType) != TCL_OK ) {
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: Cannot update CHDU", TCL_STATIC);
      return TCL_ERROR;
   }

   return TCL_OK;
}

/*
 *  Update the CHDU 
 */

int fitsUpdateCHDU( FitsFD *curFile, int newHduType)
{    
   /*
    * Allocate space for the new CHDUInfo
    */

   if(makeNewCHDUInfo(curFile,newHduType) != TCL_OK ) {
      return TCL_ERROR;
   }
   /* reset the load status */
   curFile->CHDUInfo.table.loadStatus = 0;    
   
   /* Reset the CHDU field */
   ffghdn(curFile->fptr,&curFile->chdu); 
   
   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 * 
 *    fitsLoadKwds --
 *     
 *    Loads the keywords from a FitsFD struct.
 *
 *    Results:
 *        Creates the Hash Table... curFile->kwds
 *
 *    Side Effects:
 *        None
 *
 * ------------------------------------------------------------
 *
 */

int fitsLoadKwds( FitsFD *curFile )
{
   int status=0,i,new,nkwds;
   Keyword *newKwd;
   Tcl_HashEntry *newEntry;  
   Tcl_HashSearch search;
   FitsCardList *comCard,*hisCard;
   char Comment[FLEN_COMMENT], Name[FLEN_KEYWORD], Value[FLEN_VALUE];
   
   /* Delete the previous hash Table */
   
   newEntry = Tcl_FirstHashEntry(curFile->kwds,&search);
   while ( NULL != newEntry ) {
      ckfree((char *) Tcl_GetHashValue(newEntry));
      Tcl_DeleteHashEntry(newEntry);
      newEntry = Tcl_NextHashEntry(&search);
   }
   
   
   /* Now load the Current one */
   
   if( curFile->CHDUInfo.table.loadStatus != 1 ) 
      curFile->CHDUInfo.table.loadStatus = 2;
   
   curFile->numCom = 0;
   curFile->numHis = 0;
   hisCard = curFile->hisHead;
   comCard = curFile->comHead;
   
   ffghsp(curFile->fptr,&nkwds,&i,&status);
   if ( status ) {
      dumpFitsErrStack(curFile->interp,status);
      return TCL_ERROR;
   }
   
   for (i = 1;i <= nkwds; i++ ) {
      ffgkyn( curFile->fptr, i, Name, Value, Comment, &status);
      if( status ) {
	 dumpFitsErrStack(curFile->interp,status);
	 return TCL_ERROR;
      }
      if( !strcmp(Name,"HISTORY") ) {
	 if (hisCard->next == NULL ) {
	    hisCard->next = (FitsCardList *) ckalloc( sizeof (FitsCardList));
	    if ( hisCard->next == NULL ) {
	       Tcl_SetResult(curFile->interp,
			     "Error mallocing space for history card\n",
			     TCL_STATIC);
	       fitsCloseFile((ClientData)curFile);
	       return TCL_ERROR;
	    }
	    hisCard = hisCard->next;
	    hisCard->next = (FitsCardList *) NULL;
	    hisCard->pos = i;
	    strcpy(hisCard->value,Comment);
	 } else {
	    hisCard = hisCard->next;
	    hisCard->pos = i;
	    strcpy(hisCard->value,Comment);
	 }
	 curFile->numHis++;
      } else if( !strcmp(Name,"COMMENT") ) {
	 if (comCard->next == NULL ) {
	    comCard->next = (FitsCardList *) ckalloc( sizeof (FitsCardList));
	    if ( comCard->next == NULL ) {
	       Tcl_SetResult(curFile->interp,
			     "Error mallocing space for comment card\n",
			     TCL_STATIC);
	       fitsCloseFile((ClientData)curFile);
	       return TCL_ERROR;
	    }
	    comCard = comCard->next;
	    comCard->next = (FitsCardList *) NULL;
	    comCard->pos = i;
	    strcpy(comCard->value,Comment);
	 } else {
	    comCard = comCard->next;
	    comCard->pos = i;
	    strcpy(comCard->value,Comment);
	 }
	 curFile->numCom++;	  
      } else if( !strcmp(Name, "CONTINUE" ) ) {
      } else if( !strcmp(Name, "REFERENC" ) ) {
      } else if( !strcmp(Name,"") ) {
      } else {
	 newEntry = Tcl_CreateHashEntry(curFile->kwds,Name,&new);
	 newKwd = (Keyword *) ckalloc(sizeof(Keyword));
	 strcpy(newKwd->name,Name);
	 strcpy(newKwd->value,Value);
	 strcpy(newKwd->comment,Comment);
	 newKwd->pos = i;
	 Tcl_SetHashValue(newEntry,(ClientData) newKwd);
      }
      
   }
   curFile->numKwds = i;
   
   /*
    * Now clean up the remaining comment and history records...
    */
   
   deleteFitsCardList(comCard);
   deleteFitsCardList(hisCard);
   
   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 *
 *    deleteFitsCardList --
 *
 *    Takes an element in a Fits Card list, and deletes the rest of the list
 *    From this element on.
 *
 *    Results:
 *      Kills the rest of the string, and sets the next of comCard to NULL.
 *   
 *    Side Effects:
 *      None
 *
 * ------------------------------------------------------------
 *
 */

void deleteFitsCardList( FitsCardList *comCard )
{
   FitsCardList *tmpCard1,*tmpCard2;
   
   tmpCard1      = comCard->next;
   comCard->next = (FitsCardList *) NULL;
   while ( tmpCard1 ) {
      tmpCard2 = tmpCard1->next;
      ckfree( (char*)tmpCard1 );
      tmpCard1 = tmpCard2;
   }
   
   return;
}


/*
 * ------------------------------------------------------------
 * 
 *    fitsDumpHeader --
 *     
 *    Dump the header into a list of strings
 *
 *    Results:
 *        Returns the result
 *
 *    Side Effects:
 *        None
 *
 * ------------------------------------------------------------
 *
 */

int fitsDumpHeader( FitsFD *curFile )
{
   int status,i,nkwds;
   char record[FLEN_CARD];
   
   status = 0;
   ffghsp(curFile->fptr,&nkwds,&i,&status);

   for ( i = 1; i <= nkwds ; i++) {

      if( ffgrec(curFile->fptr,i,record,&status) ) {
	 sprintf(record,"Error dumping header: card #%d\n",i);
	 Tcl_SetResult(curFile->interp,record,TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;
      }
      Tcl_AppendElement(curFile->interp,record);

   }

   return TCL_OK;
}

/*
 * ------------------------------------------------------------
 * 
 *    fitsDumpHeaderToKV --
 *     
 *    Dump the header into a list of keyword and a list to value
 *
 *    Results:
 *        Returns the result
 *
 *    Side Effects:
 *        None
 *
 * ------------------------------------------------------------
 *
 */

int fitsDumpHeaderToKV( FitsFD *curFile )
{
   int status,i,nkwds;
   char key[FLEN_KEYWORD];
   char val[FLEN_VALUE];
   char com[FLEN_COMMENT];
   
   Tcl_DString kList;  
   Tcl_DString vList;  
   Tcl_DString cList;  
   Tcl_DString theList;    
   
   Tcl_DStringInit(&theList);
   Tcl_DStringInit(&kList);
   Tcl_DStringInit(&vList);
   Tcl_DStringInit(&cList);

   status = 0;
   ffghsp(curFile->fptr, &nkwds, &i, &status);

   for ( i = 1; i <= nkwds ; i++) {

      if( ffgkyn( curFile->fptr, i, key, val, com, &status) ) {
	 sprintf(key,"Error dumping header: card #%d\n",i);
	 Tcl_SetResult(curFile->interp, key, TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp, status);
	 Tcl_DStringFree(&kList);
	 Tcl_DStringFree(&vList);
	 Tcl_DStringFree(&cList);
	 return TCL_ERROR;
      }
      
      Tcl_DStringAppendElement(&kList, key);
      Tcl_DStringAppendElement(&vList, val);
      Tcl_DStringAppendElement(&cList, com);
      
   }
   
   Tcl_DStringAppendElement(&theList, Tcl_DStringValue(&kList));
   Tcl_DStringAppendElement(&theList, Tcl_DStringValue(&vList));
   Tcl_DStringAppendElement(&theList, Tcl_DStringValue(&cList));
   
   Tcl_DStringFree(&kList);
   Tcl_DStringFree(&vList);
   Tcl_DStringFree(&cList);

   Tcl_DStringResult(curFile->interp, &theList);
   return TCL_OK;
}

/*
 *   Just dump the keywords to a TCL list
 */

int fitsDumpKwdsToList( FitsFD *curFile )
{
   int status;
   int i,nkwds;
   char key[FLEN_KEYWORD];
   char val[FLEN_VALUE];
   Tcl_DString kList;  
   
   Tcl_DStringInit(&kList);
   
   status = 0;
   ffghsp(curFile->fptr,&nkwds,&i,&status);

   for ( i = 1; i <= nkwds ; i++) {

      if( ffgkyn( curFile->fptr, i, key, val, NULL, &status) ) {
	 sprintf(val,"Error dumping header: card #%d\n",i);
	 Tcl_SetResult(curFile->interp, val, TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp, status);
	 Tcl_DStringFree(&kList);
	 return TCL_ERROR;
      }
      
      Tcl_DStringAppendElement(&kList, key);
   }
   
   Tcl_DStringResult(curFile->interp, &kList);
   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 * 
 *    fitsDumpHeaderToCard --
 *     
 *    Dump the header into a list of keyword ended with a new line
 *
 *    Results:
 *        Returns the result
 *
 *    Side Effects:
 *        None
 *
 * ------------------------------------------------------------
 *
 */

int fitsDumpHeaderToCard( FitsFD *curFile )
{
   int status,i,nkwds;
   char record[FLEN_CARD+1];
   Tcl_DString theList;    
   
   Tcl_DStringInit(&theList);

   status = 0;
   ffghsp(curFile->fptr,&nkwds,&i,&status);

   for ( i = 1; i <= nkwds ; i++ ) {

      if( ffgrec(curFile->fptr, i, record, &status) ) {
	 sprintf(record,"Error dumping header: card #%d\n",i);
	 Tcl_SetResult(curFile->interp, record, TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp, status);
	 Tcl_DStringFree(&theList);
	 return TCL_ERROR;
      }

      strcat(record, "\n");
      
      Tcl_DStringAppend(&theList, record, -1);
      
   }
   
   Tcl_DStringResult(curFile->interp, &theList);
   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 *
 * makeNewCHDUInfo--
 *
 * This removes the current CHDU structure and replaces it with one 
 * suitable for an extension of type newHduType.  Returns TCL_OK for 
 * success.  If the old CHDUInfo is of the same type as newHduType,
 * just return.
 *
 * Results:
 * Deallocates the memory for the previous header type, allocates memory
 * for the new type.
 *
 * Side Effects:
 * None
 *
 * ------------------------------------------------------------
 */

int makeNewCHDUInfo( FitsFD *curFile,
		     int newHduType )
{
   /*
    * If the new and old files have the same HDUTYPE, no need to do anything
    */
   
   if(curFile->hduType == newHduType ) {
      return TCL_OK;
      
      /*
       * If going from IMAGE to anything, wipe all the space, and start over:
       * If going from nothing to BINARY or ASCII, skip the freeing:
       */
      
   } else if ( curFile->hduType == IMAGE_HDU || 
	       (curFile->hduType == NOHDU && newHduType != IMAGE_HDU)) {
      
      /*
       * First release the space from the previous header...
       */
      
      if( curFile->hduType != NOHDU ) {
	 freeCHDUInfo(curFile);
      }
      

      curFile->CHDUInfo.table.colName = 
	 (char **) makeContigArray(FITS_COLMAX,FLEN_VALUE,'c');
      if( NULL == curFile->CHDUInfo.table.colName ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colName", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colType = 
	 (char **) makeContigArray(FITS_COLMAX,FLEN_VALUE,'c');
      if( NULL == curFile->CHDUInfo.table.colType ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colType", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colDataType = 
	 (int *) makeContigArray(FITS_COLMAX,1,'i');
      if( NULL == curFile->CHDUInfo.table.colDataType ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colDataType", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colWidth = 
	 (int *) makeContigArray(FITS_COLMAX,1,'i');
      if( NULL == curFile->CHDUInfo.table.colWidth ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colWidth", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colUnit = 
	 (char **) makeContigArray(FITS_COLMAX,FLEN_VALUE,'c');
      if( NULL == curFile->CHDUInfo.table.colUnit ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colUnit", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colFormat = 
	 (char **) makeContigArray(FITS_COLMAX,FLEN_VALUE,'c');
      if( NULL == curFile->CHDUInfo.table.colFormat ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colFormat", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colDisp = 
	 (char **) makeContigArray(FITS_COLMAX,FLEN_VALUE,'c');
      if( NULL == curFile->CHDUInfo.table.colDisp ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colDisp", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colNull = 
	 (char **) makeContigArray(FITS_COLMAX,FLEN_VALUE,'c');
      if( NULL == curFile->CHDUInfo.table.colNull ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colNull", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.vecSize = 
	 (long *) makeContigArray(FITS_COLMAX,1,'l');
      if( NULL == curFile->CHDUInfo.table.vecSize ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for vecSize", TCL_STATIC);
	 return TCL_ERROR;
      }

      curFile->CHDUInfo.table.colTscale = 
	 (double *) makeContigArray(FITS_COLMAX,1,'d');
      if( NULL == curFile->CHDUInfo.table.colTscale ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colTscale", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colTzero = 
	 (double *) makeContigArray(FITS_COLMAX,1,'d');
      if( NULL == curFile->CHDUInfo.table.colTzero ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colTzero", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colTzflag = 
	 (int *) makeContigArray(FITS_COLMAX,1,'i');
      if( NULL == curFile->CHDUInfo.table.colTzflag ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colTzflag", TCL_STATIC);
	 return TCL_ERROR;
      }
      curFile->CHDUInfo.table.colTsflag = 
	 (int *) makeContigArray(FITS_COLMAX,1,'i');
      if( NULL == curFile->CHDUInfo.table.colTsflag ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colTsflag", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.table.colMin = 
	 (double *) makeContigArray(FITS_COLMAX,1,'d');
      if( NULL == curFile->CHDUInfo.table.colMin ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colMin", TCL_STATIC);
	 return TCL_ERROR;
      }	
      
      curFile->CHDUInfo.table.colMax = 
	 (double *) makeContigArray(FITS_COLMAX,1,'d');
      if( NULL == curFile->CHDUInfo.table.colMax ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for colMax", TCL_STATIC);
	 return TCL_ERROR;
      }

      curFile->CHDUInfo.table.strSize = 
	 (int *) makeContigArray(FITS_COLMAX,1,'i');
      if( NULL == curFile->CHDUInfo.table.strSize ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for strSize", TCL_STATIC);
	 return TCL_ERROR;
      }

      /*
       *  If you are going to Image HDU, then also wipe everything,
       *  and start over:
       */
      
   } else if ( newHduType == IMAGE_HDU ) {
      
      if (curFile->hduType != NOHDU ) {
	 freeCHDUInfo(curFile);
      }
      
      curFile->CHDUInfo.image.naxisn = 
	 (long *) makeContigArray(FITS_MAXDIMS,1,'l');
      if( NULL == curFile->CHDUInfo.image.naxisn ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for naxisn", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      curFile->CHDUInfo.image.axisUnit = 
	 (char **) makeContigArray(FITS_MAXDIMS,FLEN_VALUE,'c');
      if( NULL == curFile->CHDUInfo.image.axisUnit ) {
	 Tcl_SetResult(curFile->interp,
		       "Error malloc'ing space for axisUnit", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      
   } else if ( newHduType == ASCII_TBL || newHduType == BINARY_TBL ) {
      
      /*  Do Nothing  */
      
   } else {
      Tcl_SetResult(curFile->interp,
		    "In makeNewCHDUInfo - You should not get here...",
		    TCL_STATIC);
      return TCL_ERROR;
   }
   
   curFile->hduType = newHduType;
   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 *
 * freeCHDUInfo --
 *
 * This removes the current CHDU structure 
 *
 * Results:
 * Deallocates the memory for the previous header type.
 *
 * Side Effects:
 * None
 *
 * ------------------------------------------------------------
 */

int freeCHDUInfo( FitsFD * curFile )
{
   if (curFile->hduType == IMAGE_HDU ) {
      ckfree((char *) curFile->CHDUInfo.image.naxisn);
      ckfree((char *) curFile->CHDUInfo.image.axisUnit[0]);
      ckfree((char *) curFile->CHDUInfo.image.axisUnit);
   } else if (curFile->hduType == ASCII_TBL || curFile->hduType == BINARY_TBL) {
      ckfree((char *) curFile->CHDUInfo.table.colName[0]);
      ckfree((char *) curFile->CHDUInfo.table.colType[0]);
      ckfree((char *) curFile->CHDUInfo.table.colUnit[0]);
      ckfree((char *) curFile->CHDUInfo.table.colDisp[0]);
      ckfree((char *) curFile->CHDUInfo.table.colNull[0]);
      ckfree((char *) curFile->CHDUInfo.table.colFormat[0]);
      ckfree((char *) curFile->CHDUInfo.table.colDataType);
      ckfree((char *) curFile->CHDUInfo.table.colWidth);
      ckfree((char *) curFile->CHDUInfo.table.colName);
      ckfree((char *) curFile->CHDUInfo.table.colUnit);
      ckfree((char *) curFile->CHDUInfo.table.colType);
      ckfree((char *) curFile->CHDUInfo.table.colDisp);
      ckfree((char *) curFile->CHDUInfo.table.colNull);
      ckfree((char *) curFile->CHDUInfo.table.vecSize);
      ckfree((char *) curFile->CHDUInfo.table.colFormat);
      ckfree((char *) curFile->CHDUInfo.table.colMin);
      ckfree((char *) curFile->CHDUInfo.table.colMax);
      ckfree((char *) curFile->CHDUInfo.table.colTzero);
      ckfree((char *) curFile->CHDUInfo.table.colTscale);
      ckfree((char *) curFile->CHDUInfo.table.colTzflag);
      ckfree((char *) curFile->CHDUInfo.table.colTsflag);
      ckfree((char *) curFile->CHDUInfo.table.strSize);
      
   } else {

      char errMsg[80];
      sprintf(errMsg,"Unknown HDU Type: %d\n",curFile->hduType);
      Tcl_SetResult(curFile->interp,errMsg,TCL_VOLATILE);
      return TCL_ERROR;

   }

   return TCL_OK;
}


int imageRowsMeanToPtr( FitsFD *curFile,
			long fRow,
			long lRow,
			long slice )
{
   long fCol = 1;
   long nRows;
   long nCols;
   void *databuffer;
   int dataType;
   int dataLength;
   long tmpL;
   int i,j, offset;
   
   unsigned char *byteData;
   short *shortData;
   int   *intData;
   float *floatData;
   float *floatBack;
   double *dblData;
   double *dblBack;
   LONGLONG *longlongData;
   LONGLONG *longlongBack;
   void *backPtr;
   char result[80];
   
   nCols = curFile->CHDUInfo.image.naxisn[0];
   
   if ( fRow > lRow) {
      tmpL = lRow;
      lRow = fRow;
      fRow = tmpL;
   }
   
   if( fRow < 1 )
      fRow = 1;
   if( lRow < 1 )
      lRow = 1;
   
   if( curFile->CHDUInfo.image.naxes == 1 ) {
      nRows = 1;
   } else {
      nRows = curFile->CHDUInfo.image.naxisn[1];
   }
   
   if( lRow > nRows )
      lRow = nRows;
   if( fRow > nRows )
      fRow = nRows;
   
   nRows = lRow - fRow + 1;
   
   if ( TCL_OK != imageBlockLoad(curFile,"",fRow,nRows,fCol,nCols,slice,1) ) {
      return TCL_ERROR;
   }

   sscanf( Tcl_GetStringResult(curFile->interp),
	   PTRFORMAT " %d %d", &databuffer, &dataType, &dataLength);
   Tcl_ResetResult(curFile->interp);
   
   if ( dataLength != nRows*nCols ) {
      ckfree( (char*)databuffer );
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: data lengths don't match", TCL_STATIC);
      return TCL_ERROR;
   }
   
   switch( dataType ) {
   case BYTE_DATA:
      byteData = (unsigned char *) databuffer;
      floatBack = (float *) ckalloc( nCols * sizeof(float) );
      for (i=0; i< nCols; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nRows; j++) {
	    offset = i + j*nCols;
	    floatBack[i] += byteData[offset];
	 }
	 floatBack[i] /= nRows;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nCols);
      break;
   case SHORTINT_DATA:
      shortData = (short *) databuffer;
      floatBack = (float *) ckalloc( nCols * sizeof(float) );
      for (i=0; i< nCols; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nRows; j++) {
	    offset = i + j*nCols;
	    floatBack[i] += shortData[offset];
	 }
	 floatBack[i] /= nRows;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nCols);
      break;
   case INT_DATA:
      intData = (int *) databuffer;
      floatBack = (float *) ckalloc( nCols * sizeof(float) );
      for (i=0; i< nCols; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nRows; j++) {
	    offset = i + j*nCols;
	    floatBack[i] += intData[offset];
	 }
	 floatBack[i] /= nRows;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nCols);
      break; 
   case FLOAT_DATA:
      floatData = (float *) databuffer;
      floatBack = (float *) ckalloc( nCols * sizeof(float) );
      for (i=0; i< nCols; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nRows; j++) {
	    offset = i + j*nCols;
	    floatBack[i] += floatData[offset];
	 }
	 floatBack[i] /= nRows;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nCols);
      break; 
   case DOUBLE_DATA:
      dblData = (double *) databuffer;
      dblBack = (double *) ckalloc( nCols * sizeof(double) );
      for (i=0; i< nCols; i++ ) {
	 dblBack[i] = 0.0;
	 for ( j=0; j < nRows; j++) {
	    offset = i + j*nCols;
	    dblBack[i] += dblData[offset];
	 }
	 dblBack[i] /= nRows;
      }
      backPtr = dblBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, DOUBLE_DATA, nCols);
      break; 
   case LONGLONG_DATA:
      longlongData = (LONGLONG *) databuffer;
      longlongBack = (LONGLONG *) ckalloc( nCols * sizeof(LONGLONG) );
      for (i=0; i< nCols; i++ ) {
	 longlongBack[i] = 0;
	 for ( j=0; j < nRows; j++) {
	    offset = i + j*nCols;
	    longlongBack[i] += longlongData[offset];
	 }
	 longlongBack[i] /= nRows;
      }
      backPtr = longlongBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, LONGLONG_DATA, nCols);
      break; 
   default:
      ckfree((char *) databuffer);
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error:unknown data type in irows", TCL_STATIC);
      return TCL_ERROR;
   }
   
   ckfree((char *) databuffer);
   Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
   return TCL_OK;
}

int imageColsMeanToPtr( FitsFD *curFile,
			long fCol,
			long lCol,
			long slice )
{
   long fRow = 1;
   long nRows;
   long nCols;
   void *databuffer;
   int dataType;
   int dataLength;
   long tmpL;
   int i,j, offset;
   
   unsigned char *byteData;
   short *shortData;
   int   *intData;
   float *floatData;
   float *floatBack;
   double *dblData;
   double *dblBack;
   LONGLONG *longlongData;
   LONGLONG *longlongBack;
   void *backPtr;
   char result[80];
   
   if( curFile->CHDUInfo.image.naxes == 1 )
      nRows = 1;
   else
      nRows = curFile->CHDUInfo.image.naxisn[1];
   
   if ( fCol > lCol) {
      tmpL = lCol;
      lCol = fCol;
      fCol = tmpL;
   }
   
   if (fCol < 1) fCol = 1;
   
   if ( lCol > curFile->CHDUInfo.image.naxisn[0]) 
      lCol = curFile->CHDUInfo.image.naxisn[0];
   
   nCols = lCol-fCol + 1;
   
   if ( TCL_OK != imageBlockLoad(curFile,"",fRow,nRows,fCol,nCols,slice,1) ) {
      return TCL_ERROR;
   }

   sscanf( Tcl_GetStringResult(curFile->interp),
	   PTRFORMAT " %d %d", &databuffer, &dataType, &dataLength);
   Tcl_ResetResult(curFile->interp);
   
   if ( dataLength != nRows*nCols ) {
      ckfree( (char*) databuffer );
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: data lengths don't match", TCL_STATIC);
      return TCL_ERROR;
   }
   
   switch (dataType) {
   case BYTE_DATA:
      byteData = (unsigned char *) databuffer;
      floatBack = (float *) ckalloc( nRows * sizeof(float));
      for (i=0; i< nRows; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nCols; j++) {
	    offset = j + i*nCols;
	    floatBack[i] += byteData[offset];
	 }
	 floatBack[i] /= nCols;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nRows);
      break;
   case SHORTINT_DATA:
      shortData = (short *) databuffer;
      floatBack = (float *) ckalloc( nRows * sizeof(float) );
      for (i=0; i< nRows; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nCols; j++) {
	    offset = j + i*nCols;
	    floatBack[i] += shortData[offset];
	 }
	 floatBack[i] /= nCols;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nRows);
      break;
   case INT_DATA:
      intData = (int *) databuffer;
      floatBack = (float *) ckalloc( nRows * sizeof(float) );
      for (i=0; i< nRows; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nCols; j++) {
	    offset = j + i*nCols;
	    floatBack[i] += intData[offset];
	 }
	 floatBack[i] /= nCols;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nRows);
      break;
   case FLOAT_DATA:
      floatData = (float *) databuffer;
      floatBack = (float *) ckalloc( nRows * sizeof(float) );
      for (i=0; i< nRows; i++ ) {
	 floatBack[i] = 0.0;
	 for ( j=0; j < nCols; j++) {
	    offset = j + i*nCols;
	    floatBack[i] += floatData[offset];
	 }
	 floatBack[i] /= nCols;
      }
      backPtr = floatBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, FLOAT_DATA, nRows);
      break; 
   case DOUBLE_DATA:
      dblData = (double *) databuffer;
      dblBack = (double *) ckalloc( nRows * sizeof(double) );
      for (i=0; i< nRows; i++ ) {
	 dblBack[i] = 0.0;
	 for ( j=0; j < nCols; j++) {
	    offset = j + i*nCols;
	    dblBack[i] += dblData[offset];
	 }
	 dblBack[i] /= nCols;
      }
      backPtr = dblBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, DOUBLE_DATA, nRows);
      break;
   case LONGLONG_DATA:
      longlongData = (LONGLONG *) databuffer;
      longlongBack = (LONGLONG *) ckalloc( nRows * sizeof(LONGLONG) );
      for (i=0; i< nRows; i++ ) {
	 longlongBack[i] = 0;
	 for ( j=0; j < nCols; j++) {
	    offset = j + i*nCols;
	    longlongBack[i] += longlongData[offset];
	 }
	 longlongBack[i] /= nCols;
      }
      backPtr = longlongBack;
      sprintf(result, PTRFORMAT " %d %ld", backPtr, LONGLONG_DATA, nCols);
      break; 
   default:
      ckfree((char *) databuffer);
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: unknown data type in irows", TCL_STATIC);
      return TCL_ERROR;
   }
   
   ckfree((char *) databuffer);
   Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
   return TCL_OK;
}

/*
 * imageBlockLoad_1D
 *    assign a block of the image data to varName variable or return a pointer
 */

int imageBlockLoad_1D( FitsFD *curFile,
		       long fElem,
		       long nElem )
{
   long i;
   int anyNul, status;
   char *nullArray, tmpStr[80];
   void *imgData;
   Tcl_Obj *valObj, *nullObj, *listObj;

   listObj = Tcl_NewObj();
   nullObj = Tcl_NewStringObj( "NULL", -1 );

   status    = 0;
   nullArray = (char *) ckalloc(nElem*sizeof(char));
   switch ( curFile->CHDUInfo.image.dataType ) {

   case TDOUBLE:
   case TFLOAT:
      imgData = (double *) ckalloc(nElem*sizeof(double));
      ffgpfd(curFile->fptr, 
	     1,
	     fElem,
	     nElem,
	     imgData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) imgData );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      } 
      
      for ( i=0; i< nElem; i++ ) {
	 if ( nullArray[i] ) {
            valObj = nullObj;
	 } else {
            valObj = Tcl_NewDoubleObj( ((double*)imgData)[i] );
	 }
         Tcl_ListObjAppendElement( curFile->interp, listObj, valObj );
      }
      break;

   case TLONGLONG:
      imgData = (LONGLONG *) ckalloc(nElem*sizeof(LONGLONG));
      ffgpfjj(curFile->fptr, 
	      1,
	      fElem,
	      nElem,
	      imgData,
	      nullArray,
	      &anyNul,
	      &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) imgData );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      } 
      
      for ( i=0; i< nElem; i++ ) {
	 if ( nullArray[i] ) {
            valObj = nullObj;
	 } else {
#ifdef __WIN32__
            sprintf(tmpStr, "%I64d", ((LONGLONG *)imgData)[i]);
#else
            sprintf(tmpStr, "%lld", ((LONGLONG *)imgData)[i]);
#endif
            valObj = Tcl_NewStringObj( tmpStr, -1 );
	 }
         Tcl_ListObjAppendElement( curFile->interp, listObj, valObj );
      }
      break;

   case TLONG:
   case TINT:
   case TSHORT:
   case TBYTE:
      imgData = (long *) ckalloc(nElem*sizeof(long));
      ffgpfj(curFile->fptr, 
	     1,
	     fElem,
	     nElem,
	     imgData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) imgData );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      } 

      for ( i=0; i< nElem; i++ ) {
	 if ( nullArray[i] ) {
            valObj = nullObj;
	 } else {
            valObj = Tcl_NewLongObj( ((long*)imgData)[i] );
	 }
         Tcl_ListObjAppendElement( curFile->interp, listObj, valObj );
      }
      break;

   default:
      Tcl_SetResult(curFile->interp, "Unknown image type", TCL_STATIC);
      ckfree( (char *) nullArray );
      return TCL_ERROR;
   }
   
   ckfree( (char *) imgData  );
   ckfree( (char *) nullArray);
   Tcl_SetObjResult(curFile->interp,listObj);
   return TCL_OK;
}


/*
 * imageBlockLoad
 *    assign a block of the image data to varName variable or return a pointer
 */

int imageBlockLoad( FitsFD *curFile,
		    char *varName,
		    long fRow,
		    long nRow,
		    long fCol,
		    long nCol,
		    long slice,
                    long cslice)
{
   unsigned char *byteData;
   short *shortData;
   int   *intData;
   float *floatData;
   double *dblData;
   LONGLONG *longlongData;
   char *nullArray;
   double defaultDouble = 0.0;
   
   int ptrFlag, status;
   long tmpIndex, i,j;
   char tmpStr[80];
   char varIndex[80];
   int anyNul;        
   long blc[FITS_MAXDIMS], trc[FITS_MAXDIMS], incrc[FITS_MAXDIMS];
   int naxes, flip=0;
   long xDim, yDim;
   char result[80];
   char colFormat[80];
   Tcl_Obj *valObj;

   naxes = curFile->CHDUInfo.image.naxes;
   
/*
   if( naxes > 3 ) {
      for (i = 3; i < naxes; i++) {
	 if (curFile->CHDUInfo.image.naxisn[i] != 1) {
	    Tcl_SetResult(curFile->interp,
			  "Can only read L X M X N X 1 ... images",
			  TCL_STATIC);
	    return TCL_ERROR;
	 }
      }
   }
*/  

   if( naxes > FITS_MAXDIMS ) {
      sprintf(result,"Image exceeds %d dimensions", FITS_MAXDIMS);
      Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
      return TCL_ERROR;
   }

   xDim = curFile->CHDUInfo.image.naxisn[0];
   if( naxes>1 ) {
      yDim = curFile->CHDUInfo.image.naxisn[1];
   } else {
      yDim = 1;
      if( (fCol>1 && fRow>1) || (nRow>1 && nCol>1) ) {
	 Tcl_SetResult(curFile->interp,
		       "Cannot read 2D block from a 1D image",
		       TCL_STATIC);
	 return TCL_ERROR;
      }
      if( fRow>2 || nRow>2 ) {
	 /*  Interpret 1D image as a column  */
	 flip = 1;
	 yDim = xDim; xDim = 1;
      }
   }
   
   if ( fRow+nRow-1 > yDim ) {
      nRow = yDim - fRow +1;
   }
   if ( fCol+nCol-1 > xDim ) {
      nCol = xDim - fCol +1;
   }
   
   for (i=0; i < naxes; i++) {
       blc[i] = 1;
       trc[i] = 1;
       incrc[i] = 1;
   }

   if( flip ) {
      blc[0]   = fRow;
      trc[0]   = fRow+nRow-1;
      incrc[0] = 1;
   } else {
      blc[0]   = fCol;
      trc[0]   = fCol+nCol-1;
      incrc[0] = 1;
   }
   
   if( naxes>1 ) {
     if( flip ) {
        blc[1]   = fCol;
        trc[1]   = fCol+nCol-1;
        incrc[1] = 1;
     } else {
        blc[1]   = fRow;
        trc[1]   = fRow+nRow-1;
        incrc[1] = 1;
     }
/*
      blc[1]   = fRow;
      trc[1]   = fRow+nRow-1;
      incrc[1] = 1;
*/
      
      if( naxes>2 ) {
	 blc[2]   = slice;
	 trc[2]   = slice;
	 incrc[2] = 1;
	 
         if ( cslice > 1 ) {
	    blc[3] = cslice;
	    trc[3] = cslice;
	    incrc[i] = 1;
         }
      }
   }

   if( varName[0] == '\0' ) {
      ptrFlag=1;
   } else {
      ptrFlag=0;
   }

   status    = 0;
   nullArray = (char *) ckalloc(nCol*nRow*sizeof(char));
   switch ( curFile->CHDUInfo.image.dataType ) {

   case TDOUBLE:
      dblData = (double *) ckalloc(nCol*nRow*sizeof(double));
      memset (dblData, NULL, nCol*nRow*sizeof(double));

      ffgsfd(curFile->fptr, 
	     1,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     dblData,
	     nullArray,
	     &anyNul,
	     &status);

      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) dblData   );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      }	     
      
      if( ptrFlag ) {
	 sprintf(result, PTRFORMAT " %d %ld", dblData, 4, nCol*nRow);
	 Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
      } else {
	 for ( i=0; i< nCol; i++ ) {
	    for ( j=0; j< nRow; j++ ) {
	       tmpIndex = j*nCol + i;
	       sprintf(varIndex,"%ld,%ld", fCol+i-1, fRow+j-1);
	       if ( nullArray[tmpIndex] ) {
                  valObj = Tcl_NewStringObj("NULL",-1);
	       } else {
                  valObj = Tcl_NewDoubleObj( dblData[tmpIndex] );
	       }
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 ckfree( (char *) dblData);
      }
      break;

   case TLONGLONG:
      longlongData = (LONGLONG *) ckalloc(nCol*nRow*sizeof(LONGLONG));
      memset (longlongData, NULL, nCol*nRow*sizeof(LONGLONG));

      ffgsfjj(curFile->fptr, 
	      1,
	      curFile->CHDUInfo.image.naxes,
	      curFile->CHDUInfo.image.naxisn,
	      blc,
	      trc,
	      incrc,
	      longlongData,
	      nullArray,
	      &anyNul,
	      &status);

      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) longlongData   );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      }	     
      
      if( ptrFlag ) {
	 sprintf(result, PTRFORMAT " %d %ld", longlongData, 4, nCol*nRow);
	 Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
      } else {
	 for ( i=0; i< nCol; i++ ) {
	    for ( j=0; j< nRow; j++ ) {
	       tmpIndex = j*nCol + i;
	       sprintf(varIndex,"%ld,%ld", fCol+i-1, fRow+j-1);
	       if ( nullArray[tmpIndex] ) {
                  valObj = Tcl_NewStringObj("NULL",-1);
	       } else {
#ifdef __WIN32__
                  sprintf(tmpStr, "%I64d", longlongData[tmpIndex]);
#else
                  sprintf(tmpStr, "%lld", longlongData[tmpIndex]);
#endif
                  valObj = Tcl_NewStringObj( tmpStr, -1 );
	       }
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 ckfree( (char *) longlongData);
      }
      break;

   case TFLOAT:
      floatData = (float *) ckalloc(nCol*nRow*sizeof(float));
      memset (floatData, NULL, nCol*nRow*sizeof(float));

      ffgsfe(curFile->fptr, 
	     1,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     floatData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) floatData );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      } 
      
      if( ptrFlag ) {
	 sprintf(result, PTRFORMAT " %d %ld", floatData, 3, nCol*nRow);
	 Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
      } else {
	 for ( i=0; i< nCol; i++ ) {
	    for ( j=0; j< nRow; j++ ) {
	       tmpIndex = j*nCol + i;
	       sprintf(varIndex,"%ld,%ld", fCol+i-1, fRow+j-1);
	       if ( nullArray[tmpIndex] ) {
                  valObj = Tcl_NewStringObj("NULL",-1);
	       } else {
                  valObj = Tcl_NewDoubleObj( (double)floatData[tmpIndex] );
		  /* sprintf(tmpStr,"%#.5f", floatData[tmpIndex]); */
	       }
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 ckfree( (char *) floatData);
      }
      break;

   case TLONG:
   case TINT:
      intData = (int *) ckalloc(nRow*nCol*sizeof(int));
      memset (intData, NULL, nCol*nRow*sizeof(int));
      ffgsfk(curFile->fptr, 
	     1,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     intData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) intData   );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      } 

      if( ptrFlag ) {
	 sprintf(result, PTRFORMAT " %d %ld", intData, 2, nCol*nRow);
	 Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
      } else {
	 for ( i=0; i< nCol; i++ ) {
	    for ( j=0; j< nRow; j++ ) {
	       tmpIndex = j*nCol + i;
	       sprintf(varIndex,"%ld,%ld", fCol+i-1, fRow+j-1);
	       if ( nullArray[tmpIndex] ) {
                  valObj = Tcl_NewStringObj("NULL",-1);
	       } else {
                  valObj = Tcl_NewLongObj( (long)intData[tmpIndex] );
		  /* sprintf(tmpStr,"%d", intData[tmpIndex]);  */
	       }
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 ckfree( (char *) intData);
      }
      break;

   case TSHORT:
      shortData = (short *) ckalloc(nCol*nRow*sizeof(short));
      memset (shortData, NULL, nCol*nRow*sizeof(short));

      ffgsfi(curFile->fptr, 
	     1,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     shortData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) shortData );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      } 
      
      if( ptrFlag ) {
	 sprintf(result, PTRFORMAT " %d %ld", shortData, 1, nCol*nRow);
	 Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
      } else {
	 for ( i=0; i< nCol; i++ ) {
	    for ( j=0; j< nRow; j++ ) {
	       tmpIndex = j*nCol + i;
	       sprintf(varIndex,"%ld,%ld", fCol+i-1, fRow+j-1);
	       if ( nullArray[tmpIndex] ) {
                  valObj = Tcl_NewStringObj("NULL",-1);
	       } else {
                  valObj = Tcl_NewLongObj( (long)shortData[tmpIndex] );
		  /* sprintf(tmpStr,"%d", shortData[tmpIndex]); */
	       }
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 ckfree( (char *) shortData);
      }
      break;

   case TBYTE:
      byteData = (unsigned char *) ckalloc(nCol*nRow*sizeof(unsigned char));
      memset (byteData, NULL, nCol*nRow*sizeof(unsigned char));

      ffgsfb(curFile->fptr, 
	     1,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     byteData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,"Error reading image\n",TCL_VOLATILE);
	 dumpFitsErrStack(curFile->interp,status);
	 ckfree( (char *) byteData  );
	 ckfree( (char *) nullArray );
	 return TCL_ERROR;
      } 

      if( ptrFlag ) {
	 sprintf(result, PTRFORMAT " %d %ld", byteData, 0, nCol*nRow);
	 Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
      } else {
	 for ( i=0; i< nCol; i++ ) {
	    for ( j=0; j< nRow; j++ ) {
	       tmpIndex = j*nCol + i;
	       sprintf(varIndex,"%ld,%ld", fCol+i-1, fRow+j-1);
	       if ( nullArray[tmpIndex] ) {
                  valObj = Tcl_NewStringObj("NULL",-1);
	       } else {
                  valObj = Tcl_NewLongObj( (long)byteData[tmpIndex] );
		  /* sprintf(tmpStr,"%u", byteData[tmpIndex]); */
	       }
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }	
	 ckfree( (char *) byteData);
      }
      break;

   default:
      Tcl_SetResult(curFile->interp, "Unknown image type", TCL_STATIC);
      ckfree( (char *) nullArray );
      return TCL_ERROR;
   }
   
   ckfree( (char *) nullArray );
   return TCL_OK;
}


/*
 *  imageGetToPtr
 */

int imageGetToPtr( FitsFD *curFile,
		   long slice,
		   int  rotate )
{
   void *backPtr;
   long i, j;
   int anynul, status=0;
   double *dblValArray;
   double *dblTmpArray;
   LONGLONG *longlongValArray;
   LONGLONG *longlongTmpArray;
   float  *floatValArray;
   float  *floatTmpArray;
   short  *shortValArray;
   short  *shortTmpArray;
   int  *intValArray;
   int  *intTmpArray;
   unsigned char *byteValArray;
   unsigned char *byteTmpArray;
   char result[80];
   long tmpIndex;
   long offset; 
   long naxis1, naxis2, felem, nelem;

   naxis1 = curFile->CHDUInfo.image.naxisn[0];
   naxis2 = curFile->CHDUInfo.image.naxisn[1];
   if( curFile->CHDUInfo.image.naxes==1 || naxis2 < 1 ) naxis2 = 1;

   nelem = naxis1 * naxis2;
   felem = (slice-1) * nelem + 1;

   switch ( curFile->CHDUInfo.image.dataType ) {

   case TDOUBLE:
      dblValArray = (double *) ckalloc( nelem*sizeof(double) );
      ffgpvd(curFile->fptr,
	     1L,
	     felem,
	     nelem,
	     DBL_MAX,
	     dblValArray,
	     &anynul,
	     &status);
      if( status ) {
	 Tcl_SetResult(curFile->interp,
		       "fitsTcl Error: Cannot get image", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree((char *) dblValArray);
	 return TCL_ERROR;	   
      } 
      
      if (rotate == 0) {
	 backPtr = dblValArray;
      } else {
	 dblTmpArray = (double *) ckalloc( nelem*sizeof(double) );	
	 for (i=0; i < naxis1; i ++) {
	    for (j=0; j < naxis2; j ++) {
	       tmpIndex = j*naxis1 + i;
	       switch (rotate) {
	       case 1: /* 90 degree */
		  offset = (i+1)*naxis2 -j-1;
		  break;
	       case 2:
		  offset = (naxis2-j-1)*naxis1 +(naxis1-i-1);
		  break;
	       case 3:
		  offset = (naxis1-i-1)*naxis2 + j;
		  break;
	       default:
		  offset = tmpIndex;
		  break;
	       }
	       dblTmpArray[offset] = dblValArray[tmpIndex];
	    }
	 }
	 ckfree ((char *) dblValArray);
	 backPtr = dblTmpArray;
      }
      break;

   case TLONGLONG:
      longlongValArray = (LONGLONG *) ckalloc( nelem*sizeof(LONGLONG) );
      ffgpvjj(curFile->fptr,
	      1L,
	      felem,
	      nelem,
	      (LONGLONG)NULL,
	      longlongValArray,
	      &anynul,
	      &status);
      if( status ) {
	 Tcl_SetResult(curFile->interp,
		       "fitsTcl Error: Cannot get image", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree((char *) longlongValArray);
	 return TCL_ERROR;	   
      } 
      
      if (rotate == 0) {
	 backPtr = longlongValArray;
      } else {
	 longlongTmpArray = (LONGLONG *) ckalloc( nelem*sizeof(LONGLONG) );	
	 for (i=0; i < naxis1; i ++) {
	    for (j=0; j < naxis2; j ++) {
	       tmpIndex = j*naxis1 + i;
	       switch (rotate) {
	       case 1: /* 90 degree */
		  offset = (i+1)*naxis2 -j-1;
		  break;
	       case 2:
		  offset = (naxis2-j-1)*naxis1 +(naxis1-i-1);
		  break;
	       case 3:
		  offset = (naxis1-i-1)*naxis2 + j;
		  break;
	       default:
		  offset = tmpIndex;
		  break;
	       }
	       longlongTmpArray[offset] = longlongValArray[tmpIndex];
	    }
	 }
	 ckfree ((char *) longlongValArray);
	 backPtr = longlongTmpArray;
      }
      break;

   case TFLOAT:
      floatValArray = (float *) ckalloc( nelem*sizeof(float) );
      ffgpve(curFile->fptr,
	     1L,
	     felem,
	     nelem,
	     FLT_MAX,
	     floatValArray,
	     &anynul,
	     &status);
      if ( status ) {
	 Tcl_SetResult(curFile->interp,
		       "fitsTcl Error: Cannot get image", TCL_STATIC);
	 dumpFitsErrStack(curFile->interp, status);
	 ckfree((char *) floatValArray);
	 return TCL_ERROR;	   
      } 
      
      if (rotate == 0) {
	 backPtr = floatValArray;
      } else {
	 floatTmpArray = (float *) ckalloc( nelem*sizeof(float) );	
	 for (i=0; i < naxis1; i ++) {
	    for (j=0; j < naxis2; j ++) {
	       tmpIndex = j*naxis1 + i;
	       switch (rotate) {
	       case 1: /* 90 degree */
		  offset = (i+1)*naxis2 -j-1;
		  break;
	       case 2:
		  offset = (naxis2-j-1)*naxis1 +(naxis1-i-1);
		  break;
	       case 3:
		  offset = (naxis1-i-1)*naxis2 + j;
		  break;
	       default:
		  offset = tmpIndex;
		  break;
	       }
	       floatTmpArray[offset] = floatValArray[tmpIndex];
	    }
	 }
	 ckfree ((char *) floatValArray);
	 backPtr = floatTmpArray;
      }
      break;

   case TINT:
      intValArray = (int *) ckalloc( nelem*sizeof(int) );
      ffgpvk(curFile->fptr,
	     1L,
	     felem,
	     nelem,
	     INT_MAX,
	     intValArray,
	     &anynul,
	     &status);
      if ( status ) {
	 Tcl_SetResult(curFile->interp,
		       "fitsTcl Error: Cannot get image", TCL_STATIC);
	 dumpFitsErrStack(curFile->interp, status);
	 ckfree((char *) intValArray);
	 return TCL_ERROR;	   
      } 

      if (rotate == 0) {
	 backPtr = intValArray;
      } else {
	 intTmpArray = (int *) ckalloc(nelem*sizeof(int) );	
	 for (i=0; i < naxis1; i ++) {
	    for (j=0; j < naxis2; j ++) {
	       tmpIndex = j*naxis1 + i;
	       switch (rotate) {
	       case 1: /* 90 degree */
		  offset = (i+1)*naxis2 -j-1;
		  break;
	       case 2:
		  offset = (naxis2-j-1)*naxis1 +(naxis1-i-1);
		  break;
	       case 3:
		  offset = (naxis1-i-1)*naxis2 + j;
		  break;
	       default:
		  offset = tmpIndex;
		  break;
	       }
	       intTmpArray[offset] = intValArray[tmpIndex];
	    }
	 }
	 ckfree ((char *) intValArray);
	 backPtr = intTmpArray;
      }
      break;

   case TSHORT:
      shortValArray = (short *) ckalloc( nelem*sizeof(short) );
      ffgpvi(curFile->fptr,
	     1L,
	     felem,
	     nelem,
	     SHRT_MAX,
	     shortValArray,
	     &anynul,
	     &status);
      if ( status ) {
	 Tcl_SetResult(curFile->interp,
		       "fitsTcl Error: Cannot get image", TCL_STATIC);
	 dumpFitsErrStack(curFile->interp, status);
	 ckfree((char *) shortValArray);
	 return TCL_ERROR;	   
      } 

      if (rotate == 0) {
	 backPtr = shortValArray;
      } else {
	 shortTmpArray = (short *) ckalloc( nelem*sizeof(short) );	
	 for (i=0; i < naxis1; i ++) {
	    for (j=0; j < naxis2; j ++) {
	       tmpIndex = j*naxis1 + i;
	       switch (rotate) {
	       case 1: /* 90 degree */
		  offset = (i+1)*naxis2 -j-1;
		  break;
	       case 2:
		  offset = (naxis2-j-1)*naxis1 +(naxis1-i-1);
		  break;
	       case 3:
		  offset = (naxis1-i-1)*naxis2 + j;
		  break;
	       default:
		  offset = tmpIndex;
		  break;
	       }
	       shortTmpArray[offset] = shortValArray[tmpIndex];
	    }
	 }
	 ckfree ((char *) shortValArray);
	 backPtr = shortTmpArray;
      }
      break;

   case TBYTE:
      byteValArray = (unsigned char *) ckalloc( nelem*sizeof(unsigned char) );
      ffgpvb(curFile->fptr,
	     1L,
	     felem,
	     nelem,
	     UCHAR_MAX,
	     byteValArray,
	     &anynul,
	     &status);
      if ( status ) {
	 Tcl_SetResult(curFile->interp,
		       "fitsTcl Error: Cannot get image", TCL_STATIC);
	 dumpFitsErrStack(curFile->interp, status);
	 ckfree((char *) byteValArray);
	 return TCL_ERROR;	   
      } 

      if (rotate == 0) {
	 backPtr = byteValArray;
      } else {
	 byteTmpArray = (unsigned char *) ckalloc(nelem*sizeof(unsigned char) );
	 for (i=0; i < naxis1; i ++) {
	    for (j=0; j < naxis2; j ++) {
	       tmpIndex = j*naxis1 + i;
	       switch (rotate) {
	       case 1: /* 90 degree */
		  offset = (i+1)*naxis2 -j-1;
		  break;
	       case 2:
		  offset = (naxis2-j-1)*naxis1 +(naxis1-i-1);
		  break;
	       case 3:
		  offset = (naxis1-i-1)*naxis2 + j;
		  break;
	       default:
		  offset = tmpIndex;
		  break;
	       }
	       byteTmpArray[offset] = byteValArray[tmpIndex];
	    }
	 }
	 ckfree ((char *) byteValArray);
	 backPtr = byteTmpArray;
      }
      break;

   default:
      Tcl_SetResult(curFile->interp, "Unknown image type", TCL_STATIC);
      return TCL_ERROR;
   }

   sprintf(result, PTRFORMAT, backPtr);
   Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
   return TCL_OK;
}


/*
 *  vtableGetToPtr 
 *     return "address dataType numberElements"
 * 
 */

int vtableGetToPtr( FitsFD *curFile,
		    long colNum,
                    char *nulStr)
{
   void *backPtr;
   int retnType;
   int dataType;
   long numRows;
   int anynul;
   long dataSize, vecSize;
   char result[80];
   int status = 0;
   int useDefNull;

   double dblNul;
   LONGLONG longlongNul;
   float  fltNul;
   int    intNul;
   short  shtNul;
   unsigned char bytNul;
   void   *defNul;
   
   vecSize  = curFile->CHDUInfo.table.vecSize[ colNum-1 ];
   numRows  = curFile->CHDUInfo.table.numRows; 
   dataSize = numRows * vecSize;
   dataType = curFile->CHDUInfo.table.colDataType[ colNum-1 ];
   
   useDefNull = !strcmp(nulStr,"NULL");

   switch ( dataType ) {
   case TBYTE: case TBIT:
      retnType = BYTE_DATA;
      backPtr  = (void *) ckalloc (dataSize * sizeof(unsigned char));
      if( useDefNull ) {
        bytNul = UCHAR_MAX;
      } else {
        bytNul = atoi(nulStr);
      }
      defNul = &bytNul;
      break;
   case TSHORT:
      retnType = SHORTINT_DATA;
      backPtr  = (void *) ckalloc (dataSize * sizeof(short));
      if( useDefNull ) {
	 shtNul = SHRT_MAX;
      } else {
	 shtNul = atoi(nulStr);
      }
      defNul = &shtNul;
      break;
   case TINT: case TLONG:
      dataType = TINT;  /*  Cast TLONG to TINT  */
      retnType = INT_DATA;
      backPtr  = (void *) ckalloc (dataSize * sizeof(int));
      if( useDefNull ) {
	 intNul = INT_MAX;
      } else {
	 intNul = atoi(nulStr);
      }
      defNul = &intNul;
      break;
   case TFLOAT:
      retnType = FLOAT_DATA;
      backPtr  = (void *) ckalloc (dataSize * sizeof(float));
      if( useDefNull ) {
	 fltNul = FLT_MAX;
      } else {
	 fltNul = atof(nulStr);
      }
      defNul = &fltNul;
      break;
   case TDOUBLE:
      retnType = DOUBLE_DATA;
      backPtr  = (void *) ckalloc (dataSize * sizeof(double));
      if( useDefNull ) {
	 dblNul = DBL_MAX;
      } else {
	 dblNul = atof(nulStr);
      } 
      defNul = &dblNul;
      break;
   case TLONGLONG:
      retnType = LONGLONG_DATA;
      backPtr  = (void *) ckalloc (dataSize * sizeof(LONGLONG));
      if( useDefNull ) {
	 longlongNul = (LONGLONG)NULL;
      } else {
	 longlongNul = atof(nulStr);
      } 
      defNul = &longlongNul;
      break;
   default:
      Tcl_SetResult(curFile->interp,
		    "The data type is not suitable for making an image",
		    TCL_STATIC);
      return TCL_ERROR;
      break;
   }

   ffgcv( curFile->fptr, 
	  dataType,
	  colNum,
	  1,
	  1,
	  dataSize,
	  defNul,
	  backPtr,
	  &anynul,
	  &status);
   
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      ckfree( (char *) backPtr);
      return TCL_ERROR;	   
   } 
   
   sprintf(result, PTRFORMAT " %d %ld", backPtr, retnType, dataSize);
   Tcl_SetResult(curFile->interp,result,TCL_VOLATILE);
   return TCL_OK;	   
}

/* 
 * tableGetToPtr
 * return : "address dataType numberElements"
 * address can be recovered using sscanf(address, PTRFORMAT, &dataArray)
 *            where void *dataArray
 * dataType : 0 byte(unsigned char) , 1 short int, 2 int , 3 float , 4 double
 * numberElements : dimension of the array             
 *
 */

int tableGetToPtr( FitsFD *curFile,
		   long colNum,
		   char *nulStr,
		   long firstelem )
{
   void *backPtr;
   
   LONGLONG       *longlongArray;
   double         *dblArray;
   float          *fltArray;
   long           *lngArray;
   short          *shtArray;
   int            *intArray;
   unsigned char  *bytArray;
   
   LONGLONG longlongNul;
   double dblNul;
   float  fltNul;
   int    intNul;
   short  shtNul;
   unsigned char bytNul;
   char result[80];
   
   long numRows, vecSize, i;
   int anynul, dataType, colDataType;
   int status=0;
   
   numRows     = curFile->CHDUInfo.table.numRows; 
   vecSize     = curFile->CHDUInfo.table.vecSize[colNum-1];
   colDataType = curFile->CHDUInfo.table.colDataType[colNum-1];
   
   switch ( colDataType ) {

   case TSTRING:
      Tcl_SetResult(curFile->interp, "Cannot load string array", TCL_STATIC);
      return TCL_ERROR;

   case TBYTE:
      if( !strcmp(nulStr, "NULL") ) {
	 bytNul = UCHAR_MAX;
      } else {
	 bytNul = atoi(nulStr);
      }
      bytArray = (unsigned char *) ckalloc(numRows*sizeof(unsigned char));      
      ffgclb(curFile->fptr,
	     colNum,
	     1,
	     firstelem,
	     numRows,
	     vecSize,
	     1,
	     bytNul,
	     bytArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) bytArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = BYTE_DATA;
      backPtr = bytArray;	
      break;

   case TSHORT:
      if( !strcmp(nulStr, "NULL") ) {
	 shtNul = SHRT_MAX;
      } else {
	 shtNul = atoi(nulStr);
      }
      shtArray = (short *) ckalloc(numRows*sizeof(short));      
      ffgcli(curFile->fptr,
	     colNum,
	     1,
	     firstelem,
	     numRows,
	     vecSize,
	     1,
	     shtNul,
	     shtArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) shtArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = SHORTINT_DATA;
      backPtr = shtArray;
      break;

   case TINT: case TLONG:
      if( !strcmp(nulStr, "NULL") ) {
	 intNul = INT_MAX;
      } else {
	 intNul = atoi(nulStr);
      }
      intArray = (int  *) ckalloc(numRows*sizeof(int));      
      ffgclk(curFile->fptr,
	     colNum,
	     1,
	     firstelem,
	     numRows,
	     vecSize,
	     1,
	     intNul,
	     intArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) intArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = INT_DATA;
      backPtr = intArray;	
      break;

   case TFLOAT:
      if( !strcmp(nulStr, "NULL") ) {
	 fltNul = FLT_MAX;
      } else {
	 fltNul = atof(nulStr);
      }
      fltArray = (float *) ckalloc(numRows*sizeof(float));      
      ffgcle(curFile->fptr,
	     colNum,
	     1,
	     firstelem,
	     numRows,
	     vecSize,
	     1,
	     fltNul,
	     fltArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) fltArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = FLOAT_DATA;
      backPtr = fltArray;	
      break;

   case TDOUBLE:
      if( !strcmp(nulStr, "NULL") ) {
	 dblNul = DBL_MAX;
      } else {
	 dblNul = atof(nulStr);
      } 
      dblArray = (double *) ckalloc(numRows*sizeof(double));      
      ffgcld(curFile->fptr,
	     colNum,
	     1,
	     firstelem,
	     numRows,
	     vecSize,
	     1,
	     dblNul,
	     dblArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) dblArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = DOUBLE_DATA;
      backPtr = dblArray;	
      break;

   case TLONGLONG:
      if( !strcmp(nulStr, "NULL") ) {
	 longlongNul = (LONGLONG)NULL;
      } else {
	 longlongNul = atof(nulStr);
      } 
      longlongArray = (LONGLONG *) ckalloc(numRows*sizeof(LONGLONG));      
      ffgcljj(curFile->fptr,
	      colNum,
	      1,
	      firstelem,
	      numRows,
	      vecSize,
	      1,
	      longlongNul,
	      longlongArray,
	      (char*) NULL,
	      &anynul,
	      &status);
      if ( status ) {
	 ckfree((char *) longlongArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = LONGLONG_DATA;
      backPtr = longlongArray;	
      break;

   default:
      Tcl_SetResult(curFile->interp, 
		    "fitsTcl Error: cannot load this type of column",
		    TCL_STATIC);
      return TCL_ERROR;
   }
   
   sprintf(result, PTRFORMAT " %d %ld", backPtr, dataType, numRows);
   Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
   return TCL_OK;
}

/* 
 * tableRowGetToPtr
 * return : "address dataType numberElements"
 * address can be recovered using sscanf(address, PTRFORMAT, &dataArray)
 *            where void *dataArray
 * dataType : 0 byte(unsigned char) , 1 short int, 2 int , 3 float , 4 double
 * numberElements : dimension of the array             
 *
 */

int tableRowGetToPtr( FitsFD *curFile,
                      long rowNum,
                      long colNum,
                      long vecSize,
                      char *nulStr,
                      long firstelem )
{
   void *backPtr;
   
   LONGLONG       *longlongArray;
   double         *dblArray;
   float          *fltArray;
   long           *lngArray;
   short          *shtArray;
   int            *intArray;
   unsigned char  *bytArray;
   
   LONGLONG longlongNul;
   double dblNul;
   float  fltNul;
   int    intNul;
   short  shtNul;
   unsigned char bytNul;
   char result[80];
   
   long numRows, i;
   int anynul, dataType, colDataType;
   int status=0;
   
   numRows     = curFile->CHDUInfo.table.numRows; 
   /* vecSize     = curFile->CHDUInfo.table.vecSize[colNum-1]; */
   colDataType = curFile->CHDUInfo.table.colDataType[colNum-1];
   
   switch ( colDataType ) {

   case TSTRING:
      Tcl_SetResult(curFile->interp, "Cannot load string array", TCL_STATIC);
      return TCL_ERROR;

   case TBYTE:
      if( !strcmp(nulStr, "NULL") ) {
	 bytNul = UCHAR_MAX;
      } else {
	 bytNul = atoi(nulStr);
      }
      bytArray = (unsigned char *) ckalloc(vecSize*sizeof(unsigned char));      
      ffgclb(curFile->fptr,
	     colNum,
	     rowNum,
	     firstelem,
	     vecSize,
	     1,
	     1,
	     bytNul,
	     bytArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) bytArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = BYTE_DATA;
      backPtr = bytArray;	
      break;

   case TSHORT:
      if( !strcmp(nulStr, "NULL") ) {
	 shtNul = SHRT_MAX;
      } else {
	 shtNul = atoi(nulStr);
      }
/* fprintf(stdout, "shtArray size: %ld\n", vecSize*sizeof(short)); */
/* fprintf(stdout, "vecSize size: %ld\n", vecSize); */
/* fprintf(stdout, "short size: %ld\n", sizeof(short)); */
      shtArray = (short *) ckalloc(vecSize*sizeof(short));      
      ffgcli(curFile->fptr,
	     colNum,
	     rowNum,
	     firstelem,
	     vecSize,
	     1,
	     1,
	     shtNul,
	     shtArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) shtArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = SHORTINT_DATA;
      backPtr = shtArray;
      break;

   case TINT: case TLONG:
      if( !strcmp(nulStr, "NULL") ) {
	 intNul = INT_MAX;
      } else {
	 intNul = atoi(nulStr);
      }
      intArray = (int  *) ckalloc(vecSize*sizeof(int));      
      ffgclk(curFile->fptr,
	     colNum,
	     rowNum,
	     firstelem,
	     vecSize,
	     1,
	     1,
	     intNul,
	     intArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) intArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = INT_DATA;
      backPtr = intArray;	
      break;

   case TFLOAT:
      if( !strcmp(nulStr, "NULL") ) {
	 fltNul = FLT_MAX;
      } else {
	 fltNul = atof(nulStr);
      }
      fltArray = (float *) ckalloc(vecSize*sizeof(float));      
      ffgcle(curFile->fptr,
	     colNum,
	     rowNum,
	     firstelem,
	     vecSize,
	     1,
	     1,
	     fltNul,
	     fltArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) fltArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = FLOAT_DATA;
      backPtr = fltArray;	
      break;

   case TDOUBLE:
      if( !strcmp(nulStr, "NULL") ) {
	 dblNul = DBL_MAX;
      } else {
	 dblNul = atof(nulStr);
      } 
      dblArray = (double *) ckalloc(vecSize*sizeof(double));      
      ffgcld(curFile->fptr,
	     colNum,
	     rowNum,
	     firstelem,
	     vecSize,
	     1,
	     1,
	     dblNul,
	     dblArray,
	     (char*) NULL,
	     &anynul,
	     &status);
      if ( status ) {
	 ckfree((char *) dblArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = DOUBLE_DATA;
      backPtr = dblArray;	
      break;

   case TLONGLONG:
      if( !strcmp(nulStr, "NULL") ) {
	 longlongNul = (LONGLONG)NULL;
      } else {
	 longlongNul = atof(nulStr);
      } 
      longlongArray = (LONGLONG *) ckalloc(vecSize*sizeof(LONGLONG));      
      ffgcljj(curFile->fptr,
	      colNum,
	      rowNum,
	      firstelem,
	      vecSize,
	      1,
	      1,
	      longlongNul,
	      longlongArray,
	      (char*) NULL,
	      &anynul,
	      &status);
      if ( status ) {
	 ckfree((char *) longlongArray);
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;	   
      } 
      dataType = LONGLONG_DATA;
      backPtr = longlongArray;	
      break;


   default:
      Tcl_SetResult(curFile->interp, 
		    "fitsTcl Error: cannot load this type of column",
		    TCL_STATIC);
      return TCL_ERROR;
   }
   
   sprintf(result, PTRFORMAT " %d %ld", backPtr, dataType, numRows);
   Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
   return TCL_OK;
}

/*
 * ------------------------------------------------------------
 *
 * tableBlockLoad --
 *   a block of table is either set to an 2-D array varName(i_j)
 *   or placed within a TCL list and returned
 *
 * ------------------------------------------------------------
 */

int tableBlockLoad( FitsFD *curFile,
		    char *varName,
		    int felem,
		    int fRow,
		    int nRows,
		    int fCol,
		    int nCols,
		    int colNums[],
                    int format )
{
   int k,m;
   int anyf;
   char **cValue;
   short  shtValue[1];
   int    intValue[1];
   long   longValue[1];
   double dblValue[2];
   float  fValue[1];
   char   xValue[1];
   double dblComplex[2];
   float  fltComplex[2];
   char nullArray[1];
   char strNullVal[]="NULL";
   unsigned char binValue[1];
   char lValue[1];
   char colFormat[80];
   char cplxFormat[80];
   char tmpStr[80];
   char checkStr1[80];
   char checkStr2[80];
   int  tmpInt;
   char varIndex[80];
   int dataType;
   int status=0;
   char errMsg[160];
   int listFlag=0;
   Tcl_Obj *valObj, **colData, *valObj2[2];
   Tcl_Obj *cnstObj[5];
   int naxis;
   long naxes[3];
   char result1[80];
   char result2[80];

   LONGLONG longlongValue[1];

   enum { cnstNullObj=0, cnstTrueObj, cnstFalseObj, cnstUndefObj, cnstBlnkObj };
   
   if( varName[0] == '\0' ) {
      listFlag = 1;
      colData  = (Tcl_Obj**) ckalloc( nCols * sizeof( Tcl_Obj* ) );
   }
   cnstObj[cnstNullObj]  = Tcl_NewStringObj( "NULL", -1 );
   cnstObj[cnstTrueObj]  = Tcl_NewStringObj( "T", -1 );
   cnstObj[cnstFalseObj] = Tcl_NewStringObj( "F", -1 );
   cnstObj[cnstUndefObj] = Tcl_NewStringObj( "U", -1 );
   cnstObj[cnstBlnkObj]  = Tcl_NewStringObj( " ", -1 );

   for ( k = 0; k < nCols; k++ ) {

      if( listFlag )
	 colData[k] = Tcl_NewObj();

      strcpy(colFormat, curFile->CHDUInfo.table.colFormat[colNums[k]-1]);
      dataType = curFile->CHDUInfo.table.colDataType[colNums[k]-1];

      if( curFile->CHDUInfo.table.vecSize[ colNums[k]-1 ]==0 ) {
         valObj = cnstObj[ cnstBlnkObj ];
	 for (m=fRow; m < (fRow+nRows); m++ ) {
            if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
            } else {
               sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
               Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
            }
         }
         continue;
      }

      switch ( dataType ) {

      case TSTRING:
	 tmpInt = curFile->CHDUInfo.table.strSize[ colNums[k]-1 ]+1;
	 cValue = (char **) makeContigArray(2, tmpInt, 'c');
   
	 for (m=fRow; m < (fRow+nRows); m++ ) {
	    ffgcls(curFile->fptr,
		   colNums[k],
		   m,
		   felem,
		   1,
		   1,
		   strNullVal,
		   cValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
               valObj = cnstObj[ cnstBlnkObj ];
	       status = 0;
	       ffcmsg();
	    } else if( format ) {
	       sprintf(cValue[1], colFormat, cValue[0]);
               valObj = Tcl_NewStringObj(cValue[1], -1);
	    } else {
               valObj = Tcl_NewStringObj(cValue[0], -1);
            }

	    if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
	    } else {
	       sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 ckfree( (char *) cValue[0]);
	 ckfree( (char *) cValue);
	 break;

      case TLOGICAL:
	 for (m=fRow; m < (fRow+nRows); m++ ) {
	    ffgcfl(curFile->fptr,
		   colNums[k],
		   m,
		   felem,
		   1,
		   lValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
               valObj = cnstObj[ cnstBlnkObj ];
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
               valObj = cnstObj[ cnstUndefObj ];
	    } else {
	       if (lValue[0] == 1) {
                  valObj = cnstObj[ cnstTrueObj ];
	       } else {
                  valObj = cnstObj[ cnstFalseObj ];
	       }
	    }

	    if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
	    } else {
	       sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 break;

      case TBIT:
	 for (m=fRow; m < (fRow+nRows); m++ ) {
	    ffgcx(curFile->fptr,
		  colNums[k],
		  m,
		  felem,
		  1,
		  xValue,
		  &status);
	    if ( status > 0 ) {
               valObj = cnstObj[ cnstBlnkObj ];
	       status = 0;
	       ffcmsg();
	    } else if( format ) {
	       sprintf(tmpStr,colFormat,xValue[0]);
               valObj = Tcl_NewStringObj( tmpStr, -1 );
	    } else {
               valObj = Tcl_NewLongObj( (long)xValue[0] );
            }

	    if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
	    } else {
	       sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 break; 

      case TBYTE:
      case TSHORT:
      case TINT:
      case TLONG:

	 for (m=fRow; m < (fRow+nRows); m++ ) {
	    ffgcfj(curFile->fptr,
		   colNums[k],
		   m,
		   felem,
		   1,
		   longValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
               valObj = cnstObj[ cnstBlnkObj ];
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
               valObj = cnstObj[ cnstNullObj ];
	    } else if( format ) {
	       sprintf(tmpStr,colFormat,longValue[0]);
               valObj = Tcl_NewStringObj( tmpStr, -1 );
	    } else {
               valObj = Tcl_NewLongObj( longValue[0] );
	    }

	    if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
	    } else {
	       sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 break;

      case TFLOAT:
      case TDOUBLE:
	 for (m=fRow; m < (fRow+nRows); m++ ) {	  
	    ffgcfd(curFile->fptr,
		   colNums[k],
		   m,
		   felem,
		   1,
		   dblValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
               valObj = cnstObj[ cnstBlnkObj ];
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
               valObj = cnstObj[ cnstNullObj ];
	    } else if( format ) {
	       if( strchr(colFormat,'d') ) {
		  sprintf(tmpStr, "%.0f", dblValue[0]);
		  tmpInt = atoi(tmpStr);
		  sprintf(tmpStr,colFormat,tmpInt);
	       } else if( strchr(colFormat,'s') ) {
		  sprintf(tmpStr, "%f", dblValue[0]);
		  sprintf(tmpStr,colFormat,tmpStr);
	       } else {
		  sprintf(tmpStr,colFormat,dblValue[0]);
	       }
               valObj = Tcl_NewStringObj( tmpStr, -1 );
	    } else {
               valObj = Tcl_NewDoubleObj( dblValue[0] );
	    }

	    if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
	    } else {
	       sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 break;

      case TLONGLONG:
	 for (m=fRow; m < (fRow+nRows); m++ ) {	  
	    ffgcfjj(curFile->fptr,
		    colNums[k],
		    m,
		    felem,
		    1,
		    longlongValue,
		    nullArray,
		    &anyf,
		    &status);
	    if ( status > 0 ) {
               valObj = cnstObj[ cnstBlnkObj ];
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
               valObj = cnstObj[ cnstNullObj ];
	    } else {
#ifdef __WIN32__
               sprintf(tmpStr, "%I64d", longlongValue[0]);
#else
               sprintf(tmpStr, "%lld", longlongValue[0]);
#endif
               valObj = Tcl_NewStringObj( tmpStr, -1 );
	    }

	    if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
	    } else {
	       sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 break;

      case TCOMPLEX:
      case TDBLCOMPLEX:
         if( format ) {
            sprintf(cplxFormat,"%s, %s",colFormat,colFormat);
         }
            
	 for (m=fRow; m < (fRow+nRows); m++ ) {
	    ffgcfm(curFile->fptr,
		   colNums[k],
		   m,
		   felem,
		   1,
		   dblComplex,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
               valObj = cnstObj[ cnstBlnkObj ];
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
               if( format ) {
                  valObj = Tcl_NewStringObj( "NULL, NULL", -1 );
               } else {
                  valObj = cnstObj[ cnstNullObj ];
               }
	    } else if( format ) {
	       sprintf(tmpStr,cplxFormat,dblComplex[0],dblComplex[1]);
               valObj = Tcl_NewStringObj( tmpStr, -1 );
	    } else {
               valObj2[0] = Tcl_NewDoubleObj( dblComplex[0] );
               valObj2[1] = Tcl_NewDoubleObj( dblComplex[1] );
               valObj = Tcl_NewListObj(2, valObj2);
	    }

	    if( listFlag ) {
               Tcl_ListObjAppendElement(curFile->interp, colData[k], valObj);
	    } else {
	       sprintf(varIndex,"%d,%d", fCol-1+k, m-1);
	       Tcl_SetVar2Ex(curFile->interp, varName, varIndex, valObj, 0);
	    }
	 }
	 break;

      default:
	 sprintf(errMsg,"Unrecognized colType: %d for column %d",
		 dataType,colNums[k]);
	 Tcl_SetResult(curFile->interp,errMsg,TCL_VOLATILE);
	 if( listFlag ) {
	    ckfree( (char*)colData );
	 }
	 return TCL_ERROR;
      }
      
   }

   if( listFlag ) {
      Tcl_SetObjResult(curFile->interp, Tcl_NewListObj(nCols, colData) );
      ckfree( (char *)colData );
   }

   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 *
 * fitsFlushKeywords --
 *
 * Flushes the header of the CHDU to the output file.
 *
 * Results:
 *
 * Side Effects:
 * None
 *
 * ------------------------------------------------------------
 */

int fitsFlushKeywords( FitsFD *curFile )
{
   Tcl_HashEntry *newEntry;  
   Tcl_HashSearch search;    
   
   
   /* clean up the keyword  hash table */
   newEntry = Tcl_FirstHashEntry(curFile->kwds,&search);
   while ( NULL != newEntry ) {
      ckfree((char *) Tcl_GetHashValue(newEntry));
      Tcl_DeleteHashEntry(newEntry);
      newEntry = Tcl_NextHashEntry(&search);
   }
   return TCL_OK;
}


/*
 * ------------------------------------------------------------
 *
 * fitsPutReqKwds
 *
 *
 *  ERROR Returns through elem:
 *
 *  Results:
 *  Side Effects:
 *
 * ------------------------------------------------------------
 */

int fitsPutReqKwds( FitsFD *curFile,
		    int isPrImg,
		    int hduType,
		    int argc,
		    char *const argv[] )
{
   int nRows, nCols;
   int nElement, tmpInt, rowLen;
   char **cName, **cType, **cUnit, **cDims;
   char **cPost, *extname;
   long *tbcol;
   int status = 0;
   long *naxes;
   int i;
   int dataType, naxe;
   
   if ( hduType != IMAGE_HDU ) {
      /* parse the arg */
      if ( Tcl_GetInt(curFile->interp, argv[0], &nRows) != TCL_OK) {
	 Tcl_SetResult(curFile->interp, "Error getting nRows", TCL_STATIC);
	 return TCL_ERROR;
      }   
      
      /* col Name */
      if (TCL_OK != Tcl_SplitList(curFile->interp, 
				  argv[1], &nCols, &cName) ){
	 Tcl_SetResult(curFile->interp, "cannot split colName list",
		       TCL_STATIC);
	 return TCL_ERROR;
      }

      /* col Type */
      if (TCL_OK != Tcl_SplitList(curFile->interp, 
				  argv[2], &nElement, &cType) ){
	 Tcl_SetResult(curFile->interp, "cannot split colType list",
		       TCL_STATIC);
	 return TCL_ERROR;
      }
      if ( nElement != nCols ) {
	 Tcl_SetResult(curFile->interp, "colType list doesn't match nCols",
		       TCL_STATIC);
	 return TCL_ERROR; 
      }
      
      /* col Unit */
      if( argc>3 ) {
	 if (TCL_OK != Tcl_SplitList(curFile->interp, 
				     argv[3], &nElement, &cUnit)) {
	    Tcl_SetResult(curFile->interp,
			  "cannot split colUnit list", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 if( nElement>0 && nElement != nCols ) {
	    Tcl_SetResult(curFile->interp,
			  "colUnit list doesn't match nCols", TCL_STATIC);
	    return TCL_ERROR; 
	 }
      } else {
	 cUnit = NULL;
      }

   }
   
   
   switch ( hduType ) {

   case IMAGE_HDU:
      if( isPrImg && argc == 0 ) {

	 /*
             Write an empty primary array
	 */

	 ffphpr(curFile->fptr, 1, 16, 0, NULL, 0, 1, 1, &status);
	 
      } else {

         char *const *argvPtr; /*  Use this preserve argv's const status  */

	 if( argc == 1 ) {
	    if ( Tcl_SplitList(curFile->interp, argv[0], &nElement, &cPost )
		 != TCL_OK ) {
	       Tcl_SetResult(curFile->interp,
			     "Cannot split image parameter list",
			     TCL_STATIC);
	       return TCL_ERROR;
	    }
	 
	    if ( nElement != 3 ) {
	       ckfree( (char*)cPost );
	       Tcl_SetResult(curFile->interp,
			     "Wrong number of parameter list", TCL_STATIC);
	       return TCL_ERROR;
	    }
            argvPtr = cPost;
	 } else if( argc == 3 ) {
            argvPtr = argv;
	 } else {
	    Tcl_SetResult(curFile->interp,
			  "Wrong number of parameter list", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 
	 if ( TCL_OK != Tcl_GetInt(curFile->interp, argvPtr[0], &dataType)) {
	    if( argc==1 ) ckfree( (char*)cPost );
	    Tcl_SetResult(curFile->interp,
			  "The image data type is not an integer", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 if ( TCL_OK != Tcl_GetInt(curFile->interp, argvPtr[1], &naxe)) {
	    if( argc==1 ) ckfree( (char*)cPost );
	    Tcl_SetResult(curFile->interp,
			  "The image dimension is not an integer", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 
	 if ( Tcl_SplitList(curFile->interp, argvPtr[2],
			    &nElement, &cDims )
	      != TCL_OK ) {
	    if( argc==1 ) ckfree( (char*)cPost );
	    Tcl_SetResult(curFile->interp,
			  "Cannot split image dimension list", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 if( argc==1 ) ckfree( (char*)cPost );
	 
	 if ( nElement != naxe ) {
	    ckfree( (char*)cDims );
	    Tcl_SetResult(curFile->interp,
			  "The number of elements in the list "
			  "does not match naxes", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 
	 naxes = (long *)ckalloc(naxe * sizeof(long));
	 for ( i =0; i < nElement; i++) {
	    naxes[i] = atol(cDims[i]);
	 }
	 
	 if( isPrImg )
	    ffphpr(curFile->fptr, 1, dataType, naxe, naxes, 0, 1, 1, &status);
	 else
	    ffiimg(curFile->fptr, dataType, naxe, naxes, &status);
	 ckfree( (char *)naxes);
	 ckfree( (char *)cDims );

      }
      break;
      
   case ASCII_TBL: 
      /* get tbcol */
      if( argc>4 ) {
	 if ( Tcl_SplitList(curFile->interp, argv[4], &nElement, &cPost )
	      != TCL_OK ) {
	    Tcl_SetResult(curFile->interp,
			  "cannot split tbcol list\n", TCL_STATIC);
	    return TCL_ERROR;
	 }
	 if( nElement>0 && nElement != nCols ) {
	    ckfree( (char *) cPost);
	    ckfree( (char *) cName);
	    ckfree( (char *) cType);
	    if( cUnit ) ckfree( (char *) cUnit);
	    Tcl_SetResult(curFile->interp,
			  "tbcol list doesn't match nCols", TCL_STATIC);
	    return TCL_ERROR; 
	 }
      
	 if( nElement ) {
	    tbcol = (long *) ckalloc( nCols*sizeof(long) );
	    for (i=0; i < nCols; i++) {
	       if( Tcl_GetInt(curFile->interp, cPost[i], &tmpInt) != TCL_OK ) {
		  ckfree( (char *) cPost);
		  ckfree( (char *) cName);
		  ckfree( (char *) cType);
		  if( cUnit ) ckfree( (char *) cUnit);
		  Tcl_SetResult(curFile->interp,
				"Cannot get colPosition", TCL_STATIC);
		  return TCL_ERROR;
	       }
	       tbcol[i] = tmpInt;
	    }
	 } else {
	    tbcol = NULL;
	 }
	 ckfree( (char *) cPost );
      } else {
	 tbcol = NULL;
      }
      
      if( argc>5 )
	 extname = argv[5];
      else
	 extname = "";

      if( argc>6 )
	 Tcl_GetInt(curFile->interp, argv[6], &rowLen );
      else
	 rowLen = 0;
      
      ffitab(curFile->fptr, rowLen, nRows, nCols, cName, tbcol, cType,
	     cUnit, extname, &status);
      ckfree( (char *) cName);
      ckfree( (char *) cType);
      if( cUnit ) ckfree( (char *) cUnit);
      if( tbcol ) ckfree( (char *) tbcol);
      break;

   case BINARY_TBL:
      if( argc>4 )
	 extname = argv[4];
      else
	 extname = "";

      ffibin(curFile->fptr, nRows, nCols, cName, cType, cUnit,
	     extname, 0, &status);
      ckfree( (char *) cName);
      ckfree( (char *) cType);
      if( cUnit ) ckfree( (char *) cUnit);
      break;

   default:
      Tcl_SetResult(curFile->interp, "Unknown Type", TCL_STATIC);
      return TCL_ERROR;
   }

   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   }

   /*  now update */

   if ( TCL_OK != fitsUpdateCHDU(curFile, hduType) )  return TCL_ERROR;
   if ( TCL_OK != fitsLoadHDU(curFile)             )  return TCL_ERROR;

   return TCL_OK;
}


/* 
 *   Function for deleting keywords
 *
 */

int fitsDeleteKwds( FitsFD *curFile,
		    char *keyList )
{
   char *tokptr;
   int status = 0;
   char *keyName;
   int tmpInt;
   
   
   /* get the keywords from the list */
   tokptr = strtok(keyList, " ");
   while ( tokptr ) {
      if (TCL_OK == Tcl_GetInt(curFile->interp, tokptr, &tmpInt) ) {
	 ffdrec(curFile->fptr, tmpInt, &status);
      } else {
	 Tcl_ResetResult(curFile->interp);
	 strToUpper(tokptr, &keyName);
	 ffdkey(curFile->fptr, keyName, &status);
	 ckfree((char *) keyName);
      }
      if ( status ) {
	 dumpFitsErrStack(curFile->interp, status); 
	 return TCL_ERROR; 
      }
      tokptr = strtok(NULL, " ");
   }
   
   return fitsUpdateFile(curFile);
}

int fitsPutKwds( FitsFD *curFile,
		 int nkey,
		 char *inCard,
		 int ifFormat )
{
   char card[FLEN_CARD],orig[FLEN_CARD];
   char keyName[FLEN_KEYWORD];
   char keyword[FLEN_KEYWORD];
   char val[FLEN_VALUE];
   char comm[FLEN_COMMENT];
   int i, hdtype;
   int status = 0;
  
   if ( ifFormat == 1 ) {  
      if( !strncmp(inCard,"HIERARCH ",9) ) inCard+=9;
      ffgthd(inCard, card, &hdtype, &status);
      if( status ) {
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;
      }
   } else {
      strncpy(keyword, inCard, 8);
      keyword[8] = '\0';
      fftkey(keyword, &status);
      strncpy(card, inCard, 80);
      card[80] = '\0';
      ffpsvc(card, val, comm, &status);
      if( status ) {
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;
      } 
   }
   
   
   if ( nkey ) {
      ffgrec(curFile->fptr, nkey, orig, &status);
      ffmrec(curFile->fptr, nkey, card, &status);
   } else {
      for (i=0; i<8; i++) {
	 if ( card[i] == ' ' ) break;
	 keyName[i] = card[i];
      }
      keyName[i] = '\0';
      ffgcrd(curFile->fptr, keyName, orig, &status);
      if( status==KEY_NO_EXIST ) {
	 orig[0]='\0';
	 status=0;
	 ffcmsg();
      }
      ffucrd(curFile->fptr, keyName, card, &status);
   }
   
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   }

   Tcl_SetResult(curFile->interp, card, TCL_VOLATILE);
   
   if( fitsUpdateFile(curFile)==TCL_ERROR ) {
      if( nkey )
	 ffmrec(curFile->fptr, nkey, orig, &status);
      else {
	 /*  Reset location to start of header  */
	 ffgrec(curFile->fptr, 0, card, &status);
	 if( *orig )
	    ffucrd(curFile->fptr, keyName, orig, &status);
	 else
	    ffdkey(curFile->fptr, keyName, &status);
      }
      ffrhdu(curFile->fptr, &hdtype, &status);
      fitsUpdateFile(curFile);
      return TCL_ERROR;
   }
   
   return TCL_OK;
}


int fitsInsertKwds( FitsFD *curFile,
		    int index,
		    char *inCard,
		    int ifFormat )
{
   char card[FLEN_CARD];
   char keyword[FLEN_KEYWORD];
   char val[FLEN_VALUE];
   char comm[FLEN_COMMENT];
   long headend;
   int hdtype;
   int status = 0;
   
   if ( ifFormat == 1 ) {
      /* from the templet, get the card */
      if( strncmp(inCard,"HIERARCH ",9)==0 ) inCard+=9;
      ffgthd(inCard, card, &hdtype, &status);
      if( status ) {
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;
      }
   } else {
      strncpy(keyword, inCard, 8);
      keyword[8] = '\0';
      fftkey(keyword, &status);
      ffpsvc(inCard, val, comm, &status);
      if( status ) {
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;
      } 
      strcpy(card, inCard);
   }
   
   Tcl_SetResult(curFile->interp, card, TCL_VOLATILE);
   
   /* insert */
   ffirec(curFile->fptr, index, card, &status);
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   } 
   
   headend = curFile->fptr->Fptr->headend;
   if( fitsUpdateFile(curFile)==TCL_ERROR ) {
      /* Error recovery */
      curFile->fptr->Fptr->headend = headend;
      ffdrec(curFile->fptr, index, &status);
      ffrhdu(curFile->fptr, &hdtype, &status);
      fitsUpdateFile(curFile);
      return TCL_ERROR;
   }
   
   return TCL_OK;
}

/**********/
int fitsDeleteCols( FitsFD *curFile,
		    int *colList,
		    int numCols )
{
   int status = 0;
   int i,j,tmp;
   
   /*  Need to make sure colList is sorted, then delete in reverse  */

   for ( i = 1; i<numCols; i++ ) {
      tmp = colList[i];
      j = i;
      while( j && colList[j-1] > tmp ) {
	 colList[j] = colList[j-1];
	 j--;
      }
      colList[j] = tmp;
   }

   while( numCols-- ) {
      ffdcol(curFile->fptr, colList[numCols], &status);
      if ( status ) {
	 dumpFitsErrStack(curFile->interp, status); 
         return TCL_ERROR; 
      }
   }
   
   return fitsUpdateFile(curFile);
}

/**********/

int fitsDeleteRowlist ( FitsFD *curFile,
                    long* rowlist, 
                    int numRows )
{
   int status = 0;
   
   ffdrws(curFile->fptr, rowlist, numRows, &status);
   
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status); 
      return TCL_ERROR; 
   }
   
   return fitsUpdateFile(curFile);
}

/**********/
int fitsDeleteRowsRange( FitsFD *curFile,
		    char * rangelist)
{
   int status = 0;
   
   ffdrrg(curFile->fptr, rangelist, &status);
   
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status); 
      return TCL_ERROR; 
   }
   
   return fitsUpdateFile(curFile);
}

/**********/
int fitsDeleteRows( FitsFD *curFile,
		    int firstRow,
		    int numRows )
{
   int status = 0;
   
   ffdrow(curFile->fptr, firstRow, numRows, &status);
   
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status); 
      return TCL_ERROR; 
   }
   
   return fitsUpdateFile(curFile);
}

/***************/
int fitsDeleteCHdu( FitsFD *curFile )
{
   int status = 0;
   int newHduType;
   char result[80];
   
   ffdhdu(curFile->fptr, &newHduType, &status); 
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status); 
      return TCL_ERROR; 
   }

   sprintf(result, "%d", newHduType);
   Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
   return fitsUpdateFile(curFile);
}


/* all numbers are 1-based, including baseColNum */
int saveVectorTableToAscii( FitsFD *curFile,
			    char *filename,
			    char *fileStatus,
			    int fRow,
			    int nRows,
			    int fCol,
			    int nCols,
			    int baseColNum,
			    int ifCSV,
			    int ifPrintRow,
			    char *sepString,
			    int ifVariableVec)

{
  FILE *fPtr;
  char outFStr[80];
  LONGLONG k,m;
  int anyf;
  char **cValue;
  short  shtValue[1];
  int    intValue[1];
  long   longValue[1];
  LONGLONG longlongValue[1];
  double dblValue[1];
  float  fValue[1];
  char   xValue[1];
  double dblComplex[2];
  float  fltComplex[2];
  char nullArray[1];
  char strNullVal[]="NULL";
  unsigned char binValue[1];
  char lValue[1];
  char colFormat[80];
  char cplxFormat[80];
  char outputStr[80];
  int  tmpInt;
  char varIndex[80];
  int dataType;
  int status=0;
  char errMsg[160];
  int naxis;
  long naxes[3];
  
  if ( ifCSV == 1) {
    sepString = (char *) ckalloc(4);
    strcpy(sepString,"\",\"");
  }
  
  if( !strcmp(fileStatus,"0") ) {  /*  Create new file  */
    if ( ( fPtr = fopen(filename, "w")) == NULL ) {
      Tcl_ResetResult(curFile->interp);
      Tcl_AppendResult(curFile->interp,"Cannot open file ", filename,
		       (char*)NULL);
      return TCL_ERROR;
    }
  } else {  /*  Append data only to file  */
    if ( ( fPtr = fopen(filename, "a")) == NULL ) {
      Tcl_ResetResult(curFile->interp);
      Tcl_AppendResult(curFile->interp,"Cannot open file ", filename,
		       (char*)NULL);
      return TCL_ERROR;
    }
  }
  
  strcpy(colFormat, curFile->CHDUInfo.table.colFormat[baseColNum-1]);
  dataType = curFile->CHDUInfo.table.colDataType[baseColNum-1];

  for (m=fRow; m < (fRow+nRows); m++ ) {
    if ( ifCSV == 1 )
      fprintf(fPtr, "\"");
    if ( ifPrintRow == 1 ) {
      sprintf(outputStr, "%d", m);
      fprintf(fPtr, outputStr);
      fprintf(fPtr, sepString);
    }

    for ( k = fCol; k <= (fCol+nCols-1); k++ ) {
      
      switch ( dataType ) {
	
      case TSTRING:
	tmpInt = curFile->CHDUInfo.table.strSize[ baseColNum-1 ]+1;
	cValue = (char **) makeContigArray(2, tmpInt, 'c');
	
	ffgcls(curFile->fptr,
	       baseColNum,
	       m,
	       k,
	       1,
	       1,
	       strNullVal,
	       cValue,
	       nullArray,
	       &anyf,
	       &status);
	if ( status > 0 ) {
	  strcpy(outputStr," ");
	  status = 0;
	  ffcmsg();
	} else {
	  sprintf(outputStr, colFormat, cValue[0]);
	}
	ckfree( (char *) cValue[0]);
	ckfree( (char *) cValue);
	break;
      
	/* not implemented yet */
      case TLOGICAL:
	ffgcfl(curFile->fptr,
	       baseColNum,
	       m,
	       k,
	       1,
	       lValue,
	       nullArray,
	       &anyf,
	       &status);
	if ( status > 0 ) {
	  strcpy(outputStr," ");
	  status = 0;
	  ffcmsg();
	} else if( anyf ) {
	  /*	valObj = cnstObj[ cnstUndefObj ]; */
	} else {
	  if (lValue[0] == 1) {
	    /*	  valObj = cnstObj[ cnstTrueObj ]; */
	  } else {
	    /*	  valObj = cnstObj[ cnstFalseObj ]; */
	  }
	}
	break;
      
      case TBIT:
	ffgcx(curFile->fptr,
	      baseColNum,
	      m,
	      k,
	      1,
	      xValue,
	      &status);
	if ( status > 0 ) {
	  status = 0;
	  ffcmsg();
	} else {
	  sprintf(outputStr,colFormat,xValue[0]);
	} 
	break; 
	
      case TBYTE:
      case TSHORT:
      case TINT:
      case TLONG:
	ffgcfj(curFile->fptr,
	       baseColNum,
	       m,
	       k,
	       1,
	       longValue,
	       nullArray,
	       &anyf,
	       &status);
	if ( status > 0 ) {
	  strcpy(outputStr," ");
	  status = 0;
	  ffcmsg();
	} else if ( anyf ) {
	  strcpy(outputStr,"NULL");
	} else {
	  sprintf(outputStr,colFormat,longValue[0]);
	}
	break;
      
      case TFLOAT:
      case TDOUBLE:
	ffgcfd(curFile->fptr,
	       baseColNum,
	       m,
	       k,
	       1,
	       dblValue,
	       nullArray,
	       &anyf,
	       &status);
	if ( status > 0 ) {
	  strcpy(outputStr," ");
	  status = 0;
	  ffcmsg();
	} else if( anyf ) {
	  /* */
	} else {
	  if( strchr(colFormat,'d') ) {
	    sprintf(outputStr, "%.0f", dblValue[0]);
	    tmpInt = atoi(outputStr);
	    sprintf(outputStr,colFormat,tmpInt);
	  } else if( strchr(colFormat,'s') ) {
	    sprintf(outputStr, "%f", dblValue[0]);
	    sprintf(outputStr,colFormat,outputStr);
	  } else {
	    sprintf(outputStr,colFormat,dblValue[0]);
	  }
	} 
	break;
      
      case TLONGLONG:
	ffgcfjj(curFile->fptr,
	        baseColNum,
	        m,
	        k,
	        1,
	        longlongValue,
	        nullArray,
	        &anyf,
	        &status);
	if ( status > 0 ) {
	  strcpy(outputStr," ");
	  status = 0;
	  ffcmsg();
	} else if( anyf ) {
	  /* */
	} else {
	  strcpy(outputStr,longlongValue[0]);
	} 
	break;
      

      default:
	sprintf(errMsg,"ERROR");
	Tcl_SetResult(curFile->interp,errMsg,TCL_VOLATILE);
	return TCL_ERROR;
      }

      fprintf(fPtr, outputStr);
      if ( k != (fCol+nCols-1) )
	fprintf(fPtr, sepString);
    }
    if ( ifCSV == 1)
      fprintf(fPtr, "\"");
    fprintf(fPtr,"\n");
  }
  fclose(fPtr);
  return TCL_OK;
}










/***************/

/*
 *   save current table to an ascii file
 */

int saveTableToAscii( FitsFD *curFile,    
		      char *filename,
		      char *fileStatus,
		      int felem,
		      int fRow,
		      int   nRows,
		      int   nCols,
		      int   colTypes[],
		      int   colNums[],
		      int   strSize[],
		      int   ifFixedFormat,
		      int   ifCSV,
		      int   ifPrintRow,
		      char  *sepString)
{
   FILE *fPtr;
   int m, j, k;
   char rowFormatStr[10];
   char **outFStr;
   char **colFStr;
   char  **cValue;
   short shtValue[1];
   int  intValue[1];
   long longValue[1];
   LONGLONG longlongValue[1];
   double dblValue[1];
   float  fValue[1];
   double dblComplex[2];
   float  fltComplex[2];
   char nullArray[1];
   char strNullVal[]="NULL";
   unsigned char binValue[1];
   char lValue[1];
   char *outputStr;
   char errMsg[80];
   int  tmpInt;
   int  anyf;  
   int status=0;
   /* create a minimum large enough to encompass the row string */
   int maxWidth = 8;

   if ( ifCSV == 1) {
     sepString = (char *) ckalloc(4);
     strcpy(sepString,"\",\"");
   }

   /* outFStr pads columns with extra spaces in Fixed Format */
   outFStr = (char **) makeContigArray(nCols, 80, 'c');
   colFStr = (char **) makeContigArray(nCols, 80, 'c');
   for (k=0; k< nCols; k++) {
     if ( ifFixedFormat == 1) {
       sprintf(outFStr[k]," %%%ds", strSize[k]); 
       sprintf(rowFormatStr," %%%ds", 8);
     } else {
       strcpy(outFStr[k],"%s");
       strcpy(rowFormatStr,"%s");
     }
     strcpy(colFStr[k], curFile->CHDUInfo.table.colFormat[colNums[k]-1]);
     if( strSize[k] > maxWidth ) maxWidth = strSize[k];
   }
   cValue = (char **) makeContigArray(1, maxWidth+1, 'c');
   outputStr = (char *) ckalloc( (maxWidth+1) * sizeof(char) );
   
   if( !strcmp(fileStatus,"0") ) {  /*  Create new file  */

      if ( ( fPtr = fopen(filename, "w")) == NULL ) {
	 Tcl_ResetResult(curFile->interp);
	 Tcl_AppendResult(curFile->interp,"Cannot open file ", filename,
			  (char*)NULL);
	 return TCL_ERROR;
      }
      /* Don't print column names until we decide format */
      if ( ifFixedFormat == 1 ) {
	if ( ifPrintRow == 1 ) {
	  strcpy(outputStr,"Row");
	  fprintf(fPtr,rowFormatStr,outputStr);
	}
	for (k=0; k< nCols; k++)
	  fprintf(fPtr,outFStr[k],curFile->CHDUInfo.table.colName[colNums[k]-1]);
	fprintf(fPtr,"\n");

	if ( ifPrintRow == 1 ) {
	  strcpy(outputStr,"  ");
	  fprintf(fPtr,rowFormatStr,outputStr);
	}
	for (k=0; k< nCols; k++)
	  fprintf(fPtr,outFStr[k],curFile->CHDUInfo.table.colType[colNums[k]-1]);
	fprintf(fPtr,"\n");
	
	if ( ifPrintRow == 1 ) {
	  strcpy(outputStr,"  ");
	  fprintf(fPtr,rowFormatStr,outputStr);
	}
	for (k=0; k< nCols; k++)
	  fprintf(fPtr,outFStr[k],curFile->CHDUInfo.table.colUnit[colNums[k]-1]);
	fprintf(fPtr,"\n");
      }

   } else if( !strcmp(fileStatus,"1") ) {  /*  Append to file with header  */

      if ( ( fPtr = fopen(filename, "a")) == NULL ) {
	 Tcl_ResetResult(curFile->interp);
	 Tcl_AppendResult(curFile->interp,"Cannot open file ", filename,
			  (char*)NULL);
	 return TCL_ERROR;
      }
      fprintf(fPtr,"\n");

      for (k=0; k< nCols; k++)
	 fprintf(fPtr,outFStr[k],curFile->CHDUInfo.table.colName[colNums[k]-1]);
      fprintf(fPtr,"\n");

      for (k=0; k< nCols; k++)
	 fprintf(fPtr,outFStr[k],curFile->CHDUInfo.table.colType[colNums[k]-1]);
      fprintf(fPtr,"\n");

      for (k=0; k< nCols; k++)
	 fprintf(fPtr,outFStr[k],curFile->CHDUInfo.table.colUnit[colNums[k]-1]);
      fprintf(fPtr,"\n");

   } else {  /*  Append data only to file  */

      if ( ( fPtr = fopen(filename, "a")) == NULL ) {
	 Tcl_ResetResult(curFile->interp);
	 Tcl_AppendResult(curFile->interp,"Cannot open file ", filename,
			  (char*)NULL);
	 return TCL_ERROR;
      }

   }

   for (m= 0; m < nRows; m++ ) {
      if ( ifCSV == 1 )
	fprintf(fPtr, "\"");
      if ( ifPrintRow == 1 ) {
	int rowNum = fRow + m;
	sprintf(outputStr, "%d", rowNum);
	if ( ifFixedFormat == 1 ) {
	  /* pad the row number with blank spaces */
	  fprintf(fPtr, rowFormatStr, outputStr);
	} else {
	  /* don't pad */
	  fprintf(fPtr, outputStr);
	}
	fprintf(fPtr, sepString);
      }
      for (j=0; j< nCols; j++) {

	 switch (curFile->CHDUInfo.table.colDataType[colNums[j]-1]) {

	 case TSTRING:
	    ffgcls(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   1,
		   strNullVal,
		   cValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else {
	      sprintf(outputStr,colFStr[j],cValue[0]);
	    } 
	    break;

	 case TLOGICAL:
	    ffgcfl(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   lValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       sprintf(outputStr,colFStr[j],"U");
	    } else {
	      if( lValue[0] ) {
		sprintf(outputStr,colFStr[j],"T");
	      } else {
		sprintf(outputStr,colFStr[j],"F");
	      }
	    }
	    break;

	 case TBIT:
	    ffgcfb(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   binValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
	      sprintf(outputStr,colFStr[j],binValue[0]);
	    }
	    break;

	 case TBYTE:
	    ffgcfb(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   binValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
	       sprintf(outputStr,colFStr[j],binValue[0]);
	    }
	    break;

	 case TSHORT:
	    ffgcfi(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   1,
		   1,
		   shtValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
	       sprintf(outputStr,colFStr[j],shtValue[0]);
	    }
	    break;

	 case TINT:
	    ffgcfk(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   1,
		   1,
		   intValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
	       sprintf(outputStr,colFStr[j],intValue[0]);
	    }
	    break;

	 case TLONG:
	    ffgcfj(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   longValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
	       sprintf(outputStr,colFStr[j],longValue[0]);
	    }
	    break;

	 case TFLOAT:
	    ffgcfe(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   fValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
	       sprintf(outputStr,colFStr[j],fValue[0]);
	    }
	    break;

	 case TDOUBLE:
	    ffgcfd(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   dblValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
	       if (strchr(colFStr[j],'d') !=NULL) {
		  sprintf(outputStr, "%.0f", dblValue[0]);
		  tmpInt = atoi(outputStr);
		  sprintf(outputStr,colFStr[j],tmpInt);
	       } else  {
		  sprintf(outputStr,colFStr[j],dblValue[0]);
	       }
	    }
	    break;

         case TLONGLONG:
	    ffgcfjj(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   longlongValue,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL");
	    } else {
#ifdef __WIN32__
               sprintf(outputStr,"%I64d",longlongValue[0]);
#else
               sprintf(outputStr,"%lld",longlongValue[0]);
#endif
	       /* strcpy(outputStr,longlongValue[0]); */
	    }
	    break;

	 case TCOMPLEX:
	    ffgcfc(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   fltComplex,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL, NULL");
	    } else {
	       sprintf(outputStr,"%.5f, %.5f",fltComplex[0],fltComplex[1]);
	    }
	    break;

	 case TDBLCOMPLEX:
	    ffgcfm(curFile->fptr,
		   colNums[j],
		   m+fRow,
		   felem,
		   1,
		   dblComplex,
		   nullArray,
		   &anyf,
		   &status);
	    if ( status > 0 ) {
	       strcpy(outputStr," ");
	       status = 0;
	       ffcmsg();
	    } else if( anyf ) {
	       strcpy(outputStr,"NULL, NULL");
	    } else {
	       sprintf(outputStr,"%.8f, %.8f",dblComplex[0],
		       dblComplex[1]);
	    }
	    break;

	 default:
	    sprintf(errMsg,"Unrecognized colType: %d for column %d\n",
		    colTypes[j],colNums[j]);
	    Tcl_SetResult(curFile->interp,errMsg,TCL_VOLATILE);
	    ckfree( (char *) outFStr[0]);
	    ckfree( (char *) colFStr[0]);
	    ckfree( (char *) outFStr);
	    ckfree( (char *) colFStr);
	    ckfree( (char *) cValue[0]);
	    ckfree( (char *) cValue);
	    ckfree( (char *) outputStr );
	    fclose(fPtr);
	    return TCL_ERROR;
	 }
	 fprintf(fPtr, outFStr[j], outputStr);
	 if ( ifFixedFormat == 0 ) {
	   if ( j != nCols-1 )
	     /* print sepString if we're not on last column */
	     fprintf(fPtr, sepString);
	 }
      }
      if ( ifCSV == 1 ) {
	fprintf(fPtr, "\"");
      }
      fprintf(fPtr,"\n");
   }
   fclose(fPtr);

   ckfree( (char *) outFStr[0]);
   ckfree( (char *) outFStr);
   ckfree( (char *) colFStr[0]);
   ckfree( (char *) colFStr);
   ckfree( (char *) cValue[0]);
   ckfree( (char *) cValue);
   ckfree( (char *) outputStr );
   return TCL_OK;
}

/* save image table to an ascii file */

int saveImageToAscii( FitsFD *curFile,    
		      char *filename,
		      char *fileStatus,
		      int  fRow,
		      int  nRows,
		      int  fCol,
		      int  nCols,
		      int  cellSize,
		      int  ifCSV,
		      int  ifPrintRow,
		      char *sepString,
		      long slice )
{
   FILE *fPtr;
   char outFStr[80];
   int  i,j;
   unsigned char *byteData;
   short         *shortData;
   int           *intData;
   float         *floatData;
   double        *dblData;
   LONGLONG      *longlongData;
   char *nullArray;
   long tmpIndex;
   char outputStr[1024];
   long blc[FITS_MAXDIMS], trc[FITS_MAXDIMS], incrc[FITS_MAXDIMS];
   int anyNul;        
   int naxes, flip=0;
   int xDim, yDim;
   char result[80];
   int status=0;
   
   naxes = curFile->CHDUInfo.image.naxes;
   
   if( naxes > 3 ) {
      for (i = 3; i < naxes; i++) {
	 if (curFile->CHDUInfo.image.naxisn[i] != 1) {
	    Tcl_SetResult(curFile->interp,
			  "Can only read L X M X N X 1 ... images",
			  TCL_STATIC);
	    return TCL_ERROR;
	 }
      }
   }
   
   if( naxes > FITS_MAXDIMS ) {
      sprintf(result,"Image exceeds %d dimensions", FITS_MAXDIMS);
      Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
      return TCL_ERROR;
   }

   xDim = curFile->CHDUInfo.image.naxisn[0];
   if( naxes>1 ) {
      yDim = curFile->CHDUInfo.image.naxisn[1];
   } else {
      yDim = 1;
      if( (fCol>1 && fRow>1) || (nRows>1 && nCols>1) ) {
	 Tcl_SetResult(curFile->interp,
		       "Cannot read 2D block from a 1D image",
		       TCL_STATIC);
	 return TCL_ERROR;
      }
      if( fRow>2 || nRows>2 ) {
	 /*  Interpret 1D image as a column  */
	 flip = 1;
	 yDim = xDim; xDim = 1;
      }
   }
   
   if ( fRow+nRows > yDim ) {
      nRows = yDim - fRow +1;
   }
   if ( fCol+nCols > xDim ) {
      nCols = xDim - fCol +1;
   }
   
   if( flip ) {
      blc[0]   = fRow;
      trc[0]   = fRow+nRows-1;
      incrc[0] = 1;
   } else {
      blc[0]   = fCol;
      trc[0]   = fCol+nCols-1;
      incrc[0] = 1;
   }
   
   if( naxes>1 ) {
      blc[1]   = fRow;
      trc[1]   = fRow+nRows-1;
      incrc[1] = 1;
      
      if( naxes>2 ) {
	 blc[2]   = slice;
	 trc[2]   = slice;
	 incrc[2] = 1;
	 
	 for (i=3; i < naxes; i++) {
	    blc[i] = 1;
	    trc[i] = 1;
	    incrc[i] = 1;
	 }
      }
   }

   
   if( !strcmp(fileStatus,"0") ) {
      if ( ( fPtr = fopen(filename, "w")) == NULL ) {
	 Tcl_SetResult(curFile->interp, "Cannot open file ", TCL_STATIC);
	 Tcl_AppendResult(curFile->interp, filename, (char*)NULL);
	 return TCL_ERROR;
      }
   } else {
      if ( ( fPtr = fopen(filename, "a")) == NULL ) {
	 Tcl_SetResult(curFile->interp, "Cannot open file ", TCL_STATIC);
	 Tcl_AppendResult(curFile->interp, filename, (char*)NULL);
	 return TCL_ERROR;
      }
   }

   /* not used, we aren't using fixed format that uses padded spaces */
   sprintf(outFStr, "%%%ds", cellSize);

   nullArray = (char *) ckalloc(nCols*nRows*sizeof(char));

   if ( ifCSV == 1) {
     sepString = (char *) ckalloc(4);
     strcpy(sepString,"\",\"");
   }
   if( !strcmp(fileStatus,"0") ) {
     /* print columns, appropriately formatted */
   }

   switch( curFile->CHDUInfo.image.dataType ) {

   case TDOUBLE:
      dblData = (double *) ckalloc(nCols*nRows*sizeof(double));
      memset (dblData, NULL, nCols*nRows*sizeof(double));

      ffgsfd(curFile->fptr, 
	     0,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     dblData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,
		       "Error reading image\n", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree( (char *) dblData);
	 return TCL_ERROR;
      }	     
      
      for (j=nRows-1; j>=0; j-- ) {
	if ( ifCSV == 1 )
	  fprintf(fPtr, "\"");
	if ( ifPrintRow == 1 ) {
	  int rowNum = fRow + j;
	  sprintf(outputStr, "%d", rowNum);
	  fprintf(fPtr, outputStr);
	  fprintf(fPtr, sepString);
	}
	for (i=0; i<nCols ; i++ ) {
	  tmpIndex = j*nCols + i;
	  if ( nullArray[tmpIndex] ) {
	    strcpy(outputStr, "NULL");
	  } else {
	    sprintf(outputStr,"%#.10E", dblData[tmpIndex]);
	    /* sprintf(outputStr,"%s", dblData[tmpIndex]); */
	  }
	  fprintf(fPtr, outputStr);
	  if ( i != nCols-1 )
	    fprintf(fPtr, sepString);
	}
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	fprintf(fPtr,"\n");
      }
      ckfree( (char *) dblData);
      break;

   case TLONGLONG:
      longlongData = (LONGLONG *) ckalloc(nCols*nRows*sizeof(LONGLONG));
      memset (longlongData, NULL, nCols*nRows*sizeof(LONGLONG));

      ffgsfjj(curFile->fptr, 
	     0,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     longlongData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,
		       "Error reading image\n", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree( (char *) longlongData);
	 return TCL_ERROR;
      }	     
      
      for (j=nRows-1; j>=0; j-- ) {
	if ( ifCSV == 1 )
	  fprintf(fPtr, "\"");
	if ( ifPrintRow == 1 ) {
	  int rowNum = fRow + j;
	  sprintf(outputStr, "%d", rowNum);
	  fprintf(fPtr, outputStr);
	  fprintf(fPtr, sepString);
	}
	for (i=0; i<nCols ; i++ ) {
	  tmpIndex = j*nCols + i;
	  if ( nullArray[tmpIndex] ) {
	    strcpy(outputStr, "NULL");
	  } else {
#ifdef __WIN32__
	    sprintf(outputStr,"%I64d", longlongData[tmpIndex]);
#else
	    sprintf(outputStr,"%lld", longlongData[tmpIndex]);
#endif
	  }
	  fprintf(fPtr, outputStr);
	  if ( i != nCols-1 )
	    fprintf(fPtr, sepString);
	}
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	fprintf(fPtr,"\n");
      }
      ckfree( (char *) longlongData);
      break;

   case TFLOAT:
      floatData = (float *) ckalloc(nCols*nRows*sizeof(float));
      memset (floatData, NULL, nCols*nRows*sizeof(float));
      ffgsfe(curFile->fptr, 
	     0,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     floatData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,
		       "Error reading image\n", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree( (char *) floatData);
	 return TCL_ERROR;
      } 

      for (j=nRows-1; j>=0; j-- ) {
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	if ( ifPrintRow == 1) {
	  int rowNum = fRow + j;
	  sprintf(outputStr, "%d", rowNum);
	  fprintf(fPtr, outputStr);
	  fprintf(fPtr, sepString);
	}
	for (i=0; i<nCols ; i++ ) {
	  tmpIndex = j*nCols + i;
	  if ( nullArray[tmpIndex] ) {
	    strcpy(outputStr, "NULL");
	  } else {
	    sprintf(outputStr,"%#.5f", floatData[tmpIndex]); 
	  }
	  fprintf(fPtr, outputStr);
	  if ( i != nCols-1 )
	    fprintf(fPtr, sepString);
	}
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	fprintf(fPtr,"\n");
      }

      ckfree( (char *) floatData);
      break;

   case TINT:
      intData = (int *) ckalloc(nRows*nCols*sizeof(int));
      memset (intData, NULL, nCols*nRows*sizeof(int));
      ffgsfk(curFile->fptr, 
	     0,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     intData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,
		       "Error reading image\n", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree( (char *) intData);
	 return TCL_ERROR;
      } 
      
      for (j=nRows-1; j>=0; j-- ) {
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	if ( ifPrintRow == 1) {
	  int rowNum = fRow + j;
	  sprintf(outputStr, "%d", rowNum);
	  fprintf(fPtr, outputStr);
	  fprintf(fPtr, sepString);
	}
	for (i=0; i<nCols ; i++ ) {
	  tmpIndex = j*nCols + i;
	  if ( nullArray[tmpIndex] ) {
	    strcpy(outputStr, "NULL");
	  } else {
	    sprintf(outputStr,"%d", intData[tmpIndex]); 
	  }
	  fprintf(fPtr, outputStr);
	  if ( i != nCols-1 )
	    fprintf(fPtr, sepString);
	}
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	fprintf(fPtr,"\n");
      }

      ckfree( (char *) intData);
      break;

   case TSHORT:
      shortData = (short *) ckalloc(nCols*nRows*sizeof(short));
      memset (shortData, NULL, nCols*nRows*sizeof(short));
      ffgsfi(curFile->fptr, 
	     0,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     shortData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,
		       "Error reading image\n", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree( (char *) shortData);
	 return TCL_ERROR;
      } 

      for (j=nRows-1; j>=0; j-- ) {
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	if ( ifPrintRow == 1) {
	  int rowNum = fRow + j;
	  sprintf(outputStr, "%d", rowNum);
	  fprintf(fPtr, outputStr);
	  fprintf(fPtr, sepString);
	}
	for (i=0; i<nCols ; i++ ) {
	  tmpIndex = j*nCols + i;
	  if ( nullArray[tmpIndex] ) {
	    strcpy(outputStr, "NULL");
	  } else {
	    sprintf(outputStr,"%d", shortData[tmpIndex]); 
	  }
	  fprintf(fPtr, outputStr);
	  if ( i != nCols-1 )
	    fprintf(fPtr, sepString);
	}
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	fprintf(fPtr,"\n");
      }

      ckfree( (char *) shortData);
      break;

   case TBYTE:
      byteData = (unsigned char *) ckalloc(nCols*nRows*sizeof(unsigned char));
      memset (byteData, NULL, nCols*nRows*sizeof(unsigned char));
      ffgsfb(curFile->fptr, 
	     0,
	     curFile->CHDUInfo.image.naxes,
	     curFile->CHDUInfo.image.naxisn,
	     blc,
	     trc,
	     incrc,
	     byteData,
	     nullArray,
	     &anyNul,
	     &status);
      if ( status > 0 ) {
	 Tcl_SetResult(curFile->interp,
		       "Error reading image\n", TCL_STATIC);
	 dumpFitsErrStack( curFile->interp, status );
	 ckfree( (char *) byteData);
	 return TCL_ERROR;
      } 
      
      for (j=nRows-1; j>=0; j-- ) {
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	if ( ifPrintRow == 1) {
	  int rowNum = fRow + j;
	  sprintf(outputStr, "%d", rowNum);
	  fprintf(fPtr, outputStr);
	  fprintf(fPtr, sepString);
	}
	for (i=0; i<nCols ; i++ ) {
	  tmpIndex = j*nCols + i;
	  if ( nullArray[tmpIndex] ) {
	    strcpy(outputStr, "NULL");
	  } else {
	    sprintf(outputStr,"%u", byteData[tmpIndex]); 
	  }
	  fprintf(fPtr, outputStr);
	  if ( i != nCols-1 )
	    fprintf(fPtr, sepString);
	}
	if ( ifCSV == 1)
	  fprintf(fPtr, "\"");
	fprintf(fPtr,"\n");
      }

      ckfree( (char *) byteData);
      break;

   default:
      Tcl_SetResult(curFile->interp, "Unknown image type", TCL_STATIC);
      fclose(fPtr);
      return TCL_ERROR;
   }

   ckfree((char *)nullArray);
   fclose(fPtr);
   return TCL_OK;
}

/* save a column in memory to a table */

int varSaveToTable( FitsFD *curFile,
		    int     colNum,
		    long    firstRow,
		    long    firstElem,
		    long    numRows,
                    long    numElem,
		    Tcl_Obj **dataElems )
{
   int    status = 0;
   int    colDataType, colVecSize;
   int i;
   void      *dataArray;
   char      **strArray;
   char      *bitArray;
   long      *lngArray;
   double    *dblArray;
   LONGLONG  *longlongArray;
   char *tokenPtr;
   char *strPtr;
   char *nulFlag;
   int    iVal;
   long   lVal;
   double dVal;
   Tcl_Obj **cpxList;
   int    nCpx;

   /* check the number of the input array and the number specified */    

   colDataType = curFile->CHDUInfo.table.colDataType[colNum-1];

   colVecSize  = curFile->CHDUInfo.table.vecSize[colNum-1];
   if( colVecSize == 0 ) return TCL_OK;
   if( colVecSize == 1 || colDataType == TSTRING ) {
      /* this is not a vector column, do as usual */
      if ( numRows != numElem ) {
	 Tcl_SetResult(curFile->interp, "fitsTcl Error: "
		       "the number of the elements in the input "
		       "array does not match the specified row range.",
		       TCL_STATIC);
	 return TCL_ERROR;
      }
   } else { /* this is a vector column, write to the vector element */
      numRows = numElem;
   }

   nulFlag = (char *) ckalloc(numRows*sizeof(char));

   switch ( colDataType ) {

   case TSTRING:
      strArray = (char **) ckalloc(numRows * sizeof(char*));
      dataArray = strArray;
      for ( i = 0; i < numRows; i++ ) {
         strArray[i] = Tcl_GetStringFromObj( dataElems[i], NULL );
         if( !strcmp("NULL",strArray[i]) ) {
            nulFlag[i] = 1;
         } else {
            nulFlag[i] = 0;
         }
      }
      break;

   case TLOGICAL:
      bitArray = (char *) ckalloc(numRows * sizeof(char));
      dataArray = bitArray;    
      for ( i= 0; i < numRows; i++ ) {
         if( Tcl_GetBooleanFromObj( curFile->interp, dataElems[i], &iVal )
             != TCL_OK ) {
            bitArray[i] = 0;
            nulFlag[i]  = 1;
         } else {
            bitArray[i] = iVal;
            nulFlag[i]  = 0;
         }
      }
      break;

   case TBIT: 
      bitArray = (char *) ckalloc(numRows * sizeof(char));
      dataArray = bitArray;
      for ( i= 0; i < numRows; i++ ) {
         if( Tcl_GetLongFromObj( curFile->interp, dataElems[i], &lVal )
             != TCL_OK ) {
            strPtr = Tcl_GetStringFromObj( dataElems[i], NULL );
            if( !strcmp(strPtr,"NULL") ) {
               bitArray[i] = 0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)nulFlag   );
               ckfree( (char*)dataArray );
               return TCL_ERROR;
            }
	 } else {
	    bitArray[i] = lVal;
	    nulFlag[i]  = 0;
	 }
      }
      break;

   case TBYTE: 
   case TSHORT:
   case TINT: 
      colDataType = TLONG;
      /* Fallthrough */

   case TLONG:
      lngArray = (long *) ckalloc(numRows * sizeof(long));
      dataArray = lngArray;
      for ( i= 0; i < numRows; i++ ) {
         if( Tcl_GetLongFromObj( curFile->interp, dataElems[i], &lVal )
             != TCL_OK ) {
            if( Tcl_GetDoubleFromObj( curFile->interp, dataElems[i], &dVal )
                != TCL_OK ) {
               strPtr = Tcl_GetStringFromObj( dataElems[i], NULL );
               if( !strcmp(strPtr,"NULL") ) {
                  lngArray[i] = 0;
                  nulFlag[i]  = 1;
               } else {
                  ckfree( (char*)nulFlag   );
                  ckfree( (char*)dataArray );
                  return TCL_ERROR;
               }
            } else {
               lngArray[i] = dVal;
               nulFlag[i]  = 0;
            }
	 } else {
	    lngArray[i] = lVal;
	    nulFlag[i]  = 0;
	 }
      }
      break;

   case TFLOAT:
      colDataType = TDOUBLE;
      /* Fallthrough */

   case TDOUBLE: 
      dblArray = (double *) ckalloc(numRows * sizeof(double));
      dataArray = dblArray;
      for ( i= 0; i < numRows; i++ ) {
         if( Tcl_GetDoubleFromObj( curFile->interp, dataElems[i], &dVal )
             != TCL_OK ) {
            strPtr = Tcl_GetStringFromObj( dataElems[i], NULL );
            if( !strcmp(strPtr,"NULL") ) {
               dblArray[i] = 0.0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)nulFlag   );
               ckfree( (char*)dataArray );
               return TCL_ERROR;
            }
	 } else {
	    dblArray[i] = dVal;
	    nulFlag[i]  = 0;
	 }
      }
      break;

   case TLONGLONG:
      longlongArray = (LONGLONG *) ckalloc(numRows * sizeof(LONGLONG));
      dataArray = longlongArray;
      for ( i= 0; i < numRows; i++ ) {
          strPtr = Tcl_GetStringFromObj( dataElems[i], NULL );
          if ( !strcmp(strPtr,"NULL") ) {
            nulFlag[i]  = 1;
          } else {
            nulFlag[i]  = 0;
          }
          longlongArray[i] = fitsTcl_atoll(strPtr);
      }
      break;

   case TCOMPLEX:
      colDataType = TDBLCOMPLEX;
      /* Fallthrough */

   case TDBLCOMPLEX:
      dblArray = (double *) ckalloc(2 * numRows * sizeof(double));
      dataArray = dblArray;
      for ( i= 0; i < numRows; i++ ) {
         if( Tcl_ListObjGetElements( curFile->interp, dataElems[i],
                                     &nCpx, &cpxList )
             != TCL_OK ) {
            ckfree( (char*)nulFlag   );
            ckfree( (char*)dataArray );
            return TCL_ERROR;
         }
         if( nCpx < 0 || nCpx > 2 ) {
            Tcl_SetResult( curFile->interp, "Complex element did not contain "
                           "1 or 2 values", TCL_STATIC );
            ckfree( (char*)nulFlag   );
            ckfree( (char*)dataArray );
            return TCL_ERROR;
         }

         if( Tcl_GetDoubleFromObj( curFile->interp, cpxList[0], &dVal )
             != TCL_OK ) {
            strPtr = Tcl_GetStringFromObj( cpxList[0], NULL );
            if( !strncmp(strPtr,"NULL",4) ) {
               dblArray[i+i]   = 0.0;
               nulFlag[i]      = 1;
               nCpx = 1;
            } else if( strchr(strPtr, ',') ) {
               dblArray[i+i] = atof(strPtr);
               if( nCpx==1 ) {
                  strPtr = strchr(strPtr, ',') + 1;
                  dblArray[i+i+1] = atof(strPtr);
                  nCpx = 0;
               }
               nulFlag[i] = 0;
            } else {
               ckfree( (char*)nulFlag   );
               ckfree( (char*)dataArray );
               return TCL_ERROR;
            }
	 } else {
	    dblArray[i+i] = dVal;
	    nulFlag[i]    = 0;
	 }

         if( nCpx == 2 ) {
            if( Tcl_GetDoubleFromObj( curFile->interp, cpxList[1], &dVal )
                != TCL_OK ) {
               ckfree( (char*)nulFlag   );
               ckfree( (char*)dataArray );
               return TCL_ERROR;
            } else {
               dblArray[i+i+1] = dVal;
            }
         } else if( nCpx == 1 ) { /* Make explicit to allow fallthrough */
            dblArray[i+i+1] = 0.0;
         }
      }
      break;

   default:
      Tcl_SetResult(curFile->interp, 
		    "fitsTcl Error:  unknown column type", TCL_STATIC);
      ckfree( (char*)nulFlag    );
      return TCL_ERROR;  
   } 
   
   /*   Write Data   */

   ffpcl(curFile->fptr, colDataType, colNum, firstRow, 
	 firstElem, numRows, dataArray, &status);
   ckfree( (char*)dataArray );

   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      ckfree( (char*)nulFlag    );
      return TCL_ERROR;
   } 
   
   /*  Flag Nulls   */

   if ( colVecSize == 1 || colDataType == TSTRING ) {
      for (i=0; i< numRows; i++) {
	 if ( nulFlag[i] ) {
	    ffpclu(curFile->fptr, colNum, firstRow+i, firstElem, 1, &status);
	    if( status ) {
	       dumpFitsErrStack(curFile->interp, status);
	       ckfree( (char*)nulFlag    );
	       return TCL_ERROR;
	    }   
	 }
      }
   } else {
      for (i=0; i< numRows; i++) {
	 if ( nulFlag[i] ) {
	    ffpclu(curFile->fptr, colNum, firstRow, firstElem+i, 1, &status);
	    if( status ) {
	       dumpFitsErrStack(curFile->interp, status);
	       ckfree( (char*)nulFlag    );
	       return TCL_ERROR;
	    }   
	 }
      }
   }
   ckfree((char *) nulFlag);
   
   return fitsUpdateFile(curFile);
}

int addColToTable( FitsFD *curFile,
		   int     colNum,
		   char   *ttype,
		   char   *tform )
{
   int status = 0;
   
   fficol(curFile->fptr, colNum, ttype, tform, &status);
   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   }
   
   return fitsUpdateFile(curFile);
}

int addRowToTable( FitsFD *curFile,
		   int rowNum,
		   int nRows )
{
   int status = 0;
   
   ffirow(curFile->fptr, rowNum, nRows, &status);
   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   }
   
   return  fitsUpdateFile(curFile);
}

/* save to an image */

int varSaveToImage( FitsFD  *curFile,
		    long     firstElem,
		    long     numElem,
		    Tcl_Obj **listArray )
{
   int status = 0, i;
   void *dataArray;
   unsigned char *bytArray;
   short         *shtArray;
   int           *intArray;
   long          *lngArray;
   float         *fltArray;
   double        *dblArray;
   LONGLONG      *longlongArray;
   char *strPtr;
   char *nulFlag;
   char *objStr;
   long longVal;
   double dblVal;
   
   nulFlag = (char *) ckalloc(numElem*sizeof(char));
   
   switch ( curFile->CHDUInfo.image.dataType ) {

   case TBYTE: 
      bytArray = (unsigned char *) ckalloc(numElem * sizeof(unsigned char));
      for ( i= 0; i < numElem; i++, listArray++ ) {
         if( Tcl_GetLongFromObj( curFile->interp, *listArray, &longVal )
             != TCL_OK ) {
            objStr = Tcl_GetStringFromObj( *listArray, NULL );
            if( !strcmp(objStr, "NULL") ) {
               bytArray[i] = 0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)bytArray );
               ckfree( (char*)nulFlag  );
               return TCL_ERROR;
            }
	 } else {
	    bytArray[i] = longVal;
	    nulFlag[i]  = 0;
	 }
      }
      dataArray = bytArray;
      break;

   case TSHORT:
      shtArray = (short *) ckalloc(numElem * sizeof(short));
      for ( i= 0; i < numElem; i++, listArray++ ) {
         if( Tcl_GetLongFromObj( curFile->interp, *listArray, &longVal )
             != TCL_OK ) {
            objStr = Tcl_GetStringFromObj( *listArray, NULL );
            if( !strcmp(objStr, "NULL") ) {
               shtArray[i] = 0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)shtArray );
               ckfree( (char*)nulFlag  );
               return TCL_ERROR;
            }
	 } else {
	    shtArray[i] = longVal;
	    nulFlag[i]  = 0;
	 }
      }
      dataArray = shtArray;
      break;

   case TINT:
      intArray = (int *) ckalloc(numElem* sizeof(int));
      for ( i= 0; i < numElem; i++, listArray++ ) {
         if( Tcl_GetLongFromObj( curFile->interp, *listArray, &longVal )
             != TCL_OK ) {
            objStr = Tcl_GetStringFromObj( *listArray, NULL );
            if( !strcmp(objStr, "NULL") ) {
               intArray[i] = 0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)intArray );
               ckfree( (char*)nulFlag  );
               return TCL_ERROR;
            }
	 } else {
	    intArray[i] = longVal;
	    nulFlag[i]  = 0;
	 }
      }
      dataArray = intArray;
      break;

   case TLONG:
      lngArray = (long *) ckalloc(numElem* sizeof(long));
      for ( i= 0; i < numElem; i++, listArray++ ) {
         if( Tcl_GetLongFromObj( curFile->interp, *listArray, &longVal )
             != TCL_OK ) {
            objStr = Tcl_GetStringFromObj( *listArray, NULL );
            if( !strcmp(objStr, "NULL") ) {
               lngArray[i] = 0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)lngArray );
               ckfree( (char*)nulFlag  );
               return TCL_ERROR;
            }
	 } else {
	    lngArray[i] = longVal;
	    nulFlag[i]  = 0;
	 }
      }
      dataArray = lngArray;
      break;

   case TFLOAT:
      fltArray = (float *) ckalloc(numElem* sizeof(float));
      for ( i= 0; i < numElem; i++, listArray++ ) {
         if( Tcl_GetDoubleFromObj( curFile->interp, *listArray, &dblVal )
             != TCL_OK ) {
            objStr = Tcl_GetStringFromObj( *listArray, NULL );
            if( !strcmp(objStr, "NULL") ) {
               fltArray[i] = 0.0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)fltArray );
               ckfree( (char*)nulFlag  );
               return TCL_ERROR;
            }
	 } else {
	    fltArray[i] = dblVal;
	    nulFlag[i]  = 0;
	 }
      }
      dataArray = fltArray;
      break;

   case TDOUBLE: 
      dblArray = (double *) ckalloc(numElem* sizeof(double));
      for ( i= 0; i < numElem; i++, listArray++ ) {
         if( Tcl_GetDoubleFromObj( curFile->interp, *listArray, &dblVal )
             != TCL_OK ) {
            objStr = Tcl_GetStringFromObj( *listArray, NULL );
            if( !strcmp(objStr, "NULL") ) {
               dblArray[i] = 0.0;
               nulFlag[i]  = 1;
            } else {
               ckfree( (char*)dblArray );
               ckfree( (char*)nulFlag  );
               return TCL_ERROR;
            }
	 } else {
	    dblArray[i] = dblVal;
	    nulFlag[i]  = 0;
	 }
      }
      dataArray = dblArray;
      break; 

   case TLONGLONG:
      longlongArray = (LONGLONG *) ckalloc(numElem* sizeof(LONGLONG));
      for ( i= 0; i < numElem; i++, listArray++ ) {
          objStr = Tcl_GetStringFromObj( *listArray, NULL );
          if ( !strcmp(objStr, "NULL") ) {
             nulFlag[i]  = 1;
          } else {
             nulFlag[i]  = 0;
	  }
          longlongArray[i] = fitsTcl_atoll(objStr);
      }
      dataArray = longlongArray;
      break; 

   default:
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: unknown image type", TCL_STATIC);
      ckfree( (char*)nulFlag );
      return TCL_ERROR;  
   }
   
   /*   Write Data   */

   ffppr(curFile->fptr, curFile->CHDUInfo.image.dataType, 
	 firstElem, numElem, dataArray, &status); 
   ckfree((char *) dataArray);
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      ckfree((char *) nulFlag);
      return TCL_ERROR;
   } 

   /*   Flag Nulls   */
   
   for (i=0;i<numElem; i++) {
      if ( nulFlag[i] ) {
	 ffppru(curFile->fptr, 1, firstElem+i, 1, &status);
	 if( status ) {
	    dumpFitsErrStack(curFile->interp, status);
	    ckfree((char *) nulFlag);
	    return TCL_ERROR;
	 }     
      }
   }
   ckfree((char *) nulFlag);
   
   return fitsUpdateFile(curFile);
}

int fitsCopyCHduToFile( FitsFD *curFile,
			char *newfilename )
{
   fitsfile *newFptr;
   int status = 0;
   
   remove(newfilename);
   ffinit(&newFptr, newfilename, &status);
   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   } 
   
   if ( curFile->hduType != IMAGE_HDU ) {
      ffphpr(newFptr, 1, 32, 0, NULL, 0, 1, 1, &status);
      ffcrhd(newFptr, &status);
      if( status ) {
	 dumpFitsErrStack(curFile->interp, status);
	 return TCL_ERROR;  
      }
   }
   
   ffcopy(curFile->fptr, newFptr, 0, &status);
   ffclos(newFptr, &status) ;
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   } 
   
   return TCL_OK;
}

int fitsAppendCHduToFile( FitsFD *curFile, char *targetfilename ) 
{
   fitsfile *targFptr;
   int status = 0;
   int nhdu, hdutype;
   
   /*  Do everything... then check status  */

   ffopen(&targFptr, targetfilename, 1, &status);
   ffthdu(targFptr, &nhdu, &status);
   ffmahd(targFptr, nhdu, &hdutype, &status);
   ffcrhd(targFptr, &status);
   ffcopy(curFile->fptr, targFptr, 0, &status);
   ffclos(targFptr, &status) ;

   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   } 
   
   return TCL_OK;
}

int fitsPutHisKwd( FitsFD *curFile, char *his )
{
   int status = 0;
   
   ffphis(curFile->fptr, his, &status);
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   } 
   
   return fitsUpdateFile(curFile);
}


/*********************************************************************/
/*                          W C S                                    */
/*                                                                   */
/* extract the world coordinate from a header, return in Matrix form */
/*                                                                   */
/*********************************************************************/

int fitsFileGetWcsMatrix( FitsFD *curFile, fitsfile *dummyFile, int naxis, int axes[], char dest, Tcl_Obj *data[])
{
   int status = 0;
   int foundCD= 0;
   int foundTp= 0;
   int foundBK= 0;
   int endBK= 0;
   int i = 0;

   double refVal[FITS_MAXDIMS], refPix[FITS_MAXDIMS];
   double delt[FITS_MAXDIMS], rot, tmp;
   double matrix[FITS_MAXDIMS][FITS_MAXDIMS];
   int row, col, axisNum[FITS_MAXDIMS];
   char keyword[FLEN_VALUE];
   char axisType[FITS_MAXDIMS][FLEN_VALUE];
   int isImage;
   static char *Keys[2][7] = {
      { "TCTYP", "TCUNI", "TCRVL", "TCRPX", "TCD", "TCDLT", "TCROT" },
      { "CTYPE", "CUNIT", "CRVAL", "CRPIX", "CD",  "CDELT", "CROTA" }
   };
   enum { cType=0, cUnit, cRefVal, cRefPix, cMatrix, cDelta, cRota };
   
   /* Init Variables */

   if( naxis ) {
      isImage = 1;
      for( row=0; row<naxis; row++ ) axisNum[row] = axes[row];
   }
   for( row=0; row<naxis; row++ ) {
      refVal[row] = refPix[row] = 0.0;
      for( col=0; col<naxis; col++ )
         matrix[row][col] = ( row==col ? 1.0 : 0.0 );
   }

   /*  Grab any existing WCS keywords.  Use defaults for missing values  */
   
   for( row=0; row<naxis; row++ ) {
      sprintf(keyword, "%s%d%c", Keys[isImage][cRefVal],axisNum[row], dest);
      ffgkyd(dummyFile, keyword, refVal+row, NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0;

      sprintf(keyword, "%s%d%c", Keys[isImage][cRefPix], axisNum[row], dest);
      ffgkyd(dummyFile, keyword, refPix+row, NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0;
   
      sprintf(keyword, "%s%d%c", Keys[isImage][cType], axisNum[row], dest);
      axisType[row][0] = '\0';
      ffgkys(dummyFile, keyword, axisType[row], NULL, &status);
      if( status==KEY_NO_EXIST ) {
         status = 0;
         memset(axisType[row], '\0', FITS_MAXDIMS * FITS_MAXDIMS );
         foundTp++;
      } else if( !status ) {
         /* Pan: find out if a break point "-" exist */
         foundBK = 0;
         for ( i=0; i< strlen(axisType[row]); i++) {
             if (axisType[row][i] == '-')
             {
                foundBK = 1;
                break;
             }
         }
         /* Pan: if( strlen(axisType[row])==8 && axisType[row][4]=='-' ) */
         /* if( strlen(axisType[row])==8 && foundBK == 1) */
         if( foundBK == 1)
            foundTp++;
      }

      for( col=0; col<naxis; col++ ) {
         sprintf(keyword,"%s%d_%d%c", Keys[isImage][cMatrix],
                 axisNum[row],axisNum[col],dest);
         ffgkyd(dummyFile, keyword, &matrix[row][col], NULL, &status);
         if( status==0 )
            foundCD = 1;
         else if( status==KEY_NO_EXIST )
            status = 0;
      }
   }

   if( !foundCD ) {
      rot = 0.0;
      if( naxis>1 ) {
         sprintf(keyword,"%s%d%c", Keys[isImage][cRota], axisNum[1], dest);
         ffgkyd(dummyFile, keyword, &rot,   NULL, &status);
         if( status==KEY_NO_EXIST ) {
            /*  Try other column  */
            status = 0;
            if( !isImage ) {
               sprintf(keyword,"%s%d%c", Keys[isImage][cRota], axisNum[0], dest);
               ffgkyd(dummyFile, keyword, &rot,NULL, &status);
               if( status==KEY_NO_EXIST ) status=0; else rot = -rot;
            }
         }
         rot *= 1.745329252e-2;
      }

      for( col=0; col<naxis; col++ ) {
         delt[col] = 1.0;
         sprintf(keyword, "%s%d%c", Keys[isImage][cDelta], axisNum[col], dest);
         ffgkyd(dummyFile, keyword, delt+col, NULL, &status);
         if( status==KEY_NO_EXIST ) status = 0;

         if( col<2 ) {
            for( row=0; row<naxis; row++ ) {
               if( row<2 ) {
                  /*  Do 2-D rotation  */
                  if( row==col ) {
                     matrix[row][col] = delt[col] * cos( rot );
                  } else {
                     matrix[row][col] = delt[col] * sin( rot );
                     if( row==0 )
                        matrix[row][col] = - matrix[row][col];
                  }
               }
            }
         } else {
            matrix[col][col] = delt[col];
         }
      }
   }
   
   data[0] = Tcl_NewListObj(0,NULL);
   data[1] = Tcl_NewListObj(0,NULL);
   data[2] = Tcl_NewListObj(0,NULL);
   data[3] = Tcl_NewListObj(0,NULL);
   /* if( foundTp != naxis ) { */
   if( foundTp <= 0) {
      data[4] = Tcl_NewStringObj("none",-1);
   } else {
      data[4] = Tcl_NewListObj(0,NULL);
   }

   for( row=0; row<naxis; row++ ) {
      Tcl_ListObjAppendElement(curFile->interp, data[0],
                               Tcl_NewDoubleObj(refVal[row]) );
      Tcl_ListObjAppendElement(curFile->interp, data[1],
                               Tcl_NewDoubleObj(refPix[row]) );
      for( col=0; col<naxis; col++ )
         Tcl_ListObjAppendElement(curFile->interp, data[2],
                                  Tcl_NewDoubleObj(matrix[row][col]) );
      /* if( foundTp == naxis ) { */
      if( foundTp > 0 ) {

         /* Pan: find out where the break point "-" is */
         foundBK = 0;
         endBK = -1;
         for ( i=0; i< strlen(axisType[row]); i++) {
             if (foundBK == 0 && axisType[row][i] == '-')
             {
                foundBK = 1;
             }
             if ( foundBK == 1 && axisType[row][i] != '-' ) {
                endBK = i - 1;
                break;
             }
         }

         if ( endBK >= 0 ) {
            Tcl_ListObjAppendElement(curFile->interp, data[4],
                                     Tcl_NewStringObj(axisType[row]+endBK,-1) );
         } else {
            Tcl_ListObjAppendElement(curFile->interp, data[4], Tcl_NewListObj(0,NULL));
         }

         for( col=endBK; col>0 && axisType[row][col]=='-'; )
            axisType[row][col--] = '\0';
      }
      Tcl_ListObjAppendElement(curFile->interp, data[3],
                               Tcl_NewStringObj(axisType[row],-1) );
   }


   Tcl_SetObjResult(curFile->interp, Tcl_NewListObj(5,data) );

   return TCL_OK;
}

int fitsGetWcsMatrix( FitsFD *curFile, int naxis, int axes[], char dest )
{
   int status = 0;
   int foundCD= 0;
   int foundTp= 0;
   int foundBK= 0;
   int endBK= 0;
   int i = 0;
   double refVal[FITS_MAXDIMS], refPix[FITS_MAXDIMS];
   double delt[FITS_MAXDIMS], rot, tmp;
   double matrix[FITS_MAXDIMS][FITS_MAXDIMS];
   int row, col, axisNum[FITS_MAXDIMS];
   char keyword[FLEN_VALUE];
   char axisType[FITS_MAXDIMS][FLEN_VALUE];
   Tcl_Obj *data[5];
   int isImage;
   static char *Keys[2][7] = {
      { "TCTYP", "TCUNI", "TCRVL", "TCRPX", "TCD", "TCDLT", "TCROT" },
      { "CTYPE", "CUNIT", "CRVAL", "CRPIX", "CD",  "CDELT", "CROTA" }
   };
   enum { cType=0, cUnit, cRefVal, cRefPix, cMatrix, cDelta, cRota };
   
   /* Init Variables */

   if( naxis ) {
      isImage = 0;
      for( row=0; row<naxis; row++ ) axisNum[row] = axes[row];
   } else {
      isImage = 1;
      naxis   = curFile->CHDUInfo.image.naxes;
      for( row=0; row<naxis; row++ ) axisNum[row] = row+1;
   }
   for( row=0; row<naxis; row++ ) {
      refVal[row] = refPix[row] = 0.0;
      for( col=0; col<naxis; col++ )
         matrix[row][col] = ( row==col ? 1.0 : 0.0 );
   }

   /*  Grab any existing WCS keywords.  Use defaults for missing values  */
   
   for( row=0; row<naxis; row++ ) {
      sprintf(keyword, "%s%d%c", Keys[isImage][cRefVal],axisNum[row], dest);
      ffgkyd(curFile->fptr, keyword, refVal+row, NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0;

      sprintf(keyword, "%s%d%c", Keys[isImage][cRefPix], axisNum[row], dest);
      ffgkyd(curFile->fptr, keyword, refPix+row, NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0;
   
      sprintf(keyword, "%s%d%c", Keys[isImage][cType], axisNum[row], dest);
      axisType[row][0] = '\0';
      ffgkys(curFile->fptr, keyword, axisType[row], NULL, &status);
      if( status==KEY_NO_EXIST ) {
         status = 0;
         memset(axisType[row], '\0', FITS_MAXDIMS * FITS_MAXDIMS );
         foundTp++;
      } else if( !status ) {
         /* Pan: find out if a break point "-" exist */
         foundBK = 0;
         for ( i=0; i< strlen(axisType[row]); i++) {
             if (axisType[row][i] == '-')
             {
                foundBK = 1;
                break;
             }
         }
         /* Pan: if( strlen(axisType[row])==8 && axisType[row][4]=='-' ) */
         /* if( strlen(axisType[row])==8 && foundBK == 1) */
         if( foundBK == 1)
            foundTp++;
      }

      for( col=0; col<naxis; col++ ) {
         sprintf(keyword,"%s%d_%d%c", Keys[isImage][cMatrix],
                 axisNum[row],axisNum[col],dest);
         ffgkyd(curFile->fptr, keyword, &matrix[row][col], NULL, &status);
         if( status==0 )
            foundCD = 1;
         else if( status==KEY_NO_EXIST )
            status = 0;
      }
   }

   if( !foundCD ) {
      rot = 0.0;
      if( naxis>1 ) {
         sprintf(keyword,"%s%d%c", Keys[isImage][cRota], axisNum[1], dest);
         ffgkyd(curFile->fptr, keyword, &rot,   NULL, &status);
         if( status==KEY_NO_EXIST ) {
            /*  Try other column  */
            status = 0;
            if( !isImage ) {
               sprintf(keyword,"%s%d%c", Keys[isImage][cRota], axisNum[0], dest);
               ffgkyd(curFile->fptr, keyword, &rot,NULL, &status);
               if( status==KEY_NO_EXIST ) status=0; else rot = -rot;
            }
         }
         rot *= 1.745329252e-2;
      }

      for( col=0; col<naxis; col++ ) {
         delt[col] = 1.0;
         sprintf(keyword, "%s%d%c", Keys[isImage][cDelta], axisNum[col], dest);
         ffgkyd(curFile->fptr, keyword, delt+col, NULL, &status);
         if( status==KEY_NO_EXIST ) status = 0;

         if( col<2 ) {
            for( row=0; row<naxis; row++ ) {
               if( row<2 ) {
                  /*  Do 2-D rotation  */
                  if( row==col ) {
                     matrix[row][col] = delt[col] * cos( rot );
                  } else {
                     matrix[row][col] = delt[col] * sin( rot );
                     if( row==0 )
                        matrix[row][col] = - matrix[row][col];
                  }
               }
            }
         } else {
            matrix[col][col] = delt[col];
         }
      }
   }
   
   data[0] = Tcl_NewListObj(0,NULL);
   data[1] = Tcl_NewListObj(0,NULL);
   data[2] = Tcl_NewListObj(0,NULL);
   data[3] = Tcl_NewListObj(0,NULL);
   /* if( foundTp != naxis ) { */
   if( foundTp <= 0) {
      data[4] = Tcl_NewStringObj("none",-1);
   } else {
      data[4] = Tcl_NewListObj(0,NULL);
   }
   for( row=0; row<naxis; row++ ) {
      Tcl_ListObjAppendElement(curFile->interp, data[0],
                               Tcl_NewDoubleObj(refVal[row]) );
      Tcl_ListObjAppendElement(curFile->interp, data[1],
                               Tcl_NewDoubleObj(refPix[row]) );
      for( col=0; col<naxis; col++ )
         Tcl_ListObjAppendElement(curFile->interp, data[2],
                                  Tcl_NewDoubleObj(matrix[row][col]) );
      /* if( foundTp == naxis ) { */
      if( foundTp > 0 ) {

         /* Pan: find out where the break point "-" is */
         foundBK = 0;
         endBK = -1;
         for ( i=0; i< strlen(axisType[row]); i++) {
             if (foundBK == 0 && axisType[row][i] == '-')
             {
                foundBK = 1;
             }
             if ( foundBK == 1 && axisType[row][i] != '-' ) {
                endBK = i - 1;
                break;
             }
         }

/*         Tcl_ListObjAppendElement(curFile->interp, data[4],
                                  Tcl_NewStringObj(axisType[row]+endBK,-1) ); */
         if ( endBK >= 0 ) {
            Tcl_ListObjAppendElement(curFile->interp, data[4],
                                     Tcl_NewStringObj(axisType[row]+endBK,-1) );
         } else {
            Tcl_ListObjAppendElement(curFile->interp, data[4], Tcl_NewListObj(0,NULL));
         }

         for( col=endBK; col>0 && axisType[row][col]=='-'; )
            axisType[row][col--] = '\0';
      }
      Tcl_ListObjAppendElement(curFile->interp, data[3],
                               Tcl_NewStringObj(axisType[row],-1) );
   }

   Tcl_SetObjResult(curFile->interp, Tcl_NewListObj(5,data) );
   
   ffcmsg();
   return TCL_OK;
}

/* extract the world coordinate from an image header */

int fitsGetWcsPair( FitsFD *curFile, int Col1, int Col2, char dest )
{
   int status = 0;
   int swap   = 0;
   double
      xrval = 0.0,
      yrval = 0.0,
      xrpix = 0.0,
      yrpix = 0.0,
      xinc  = 1.0,
      yinc  = 1.0,
      rot   = 0.0;
   char ctype[FLEN_VALUE], ctemp[FLEN_VALUE];
   char keyword[FLEN_VALUE];
   double matrix[FITS_MAXDIMS][FITS_MAXDIMS],temp;
   int anyKeysFnd;
   Tcl_Obj *data[9];
   int isImage;
   static char *Keys[2][7] = {
      { "TCTYP", "TCUNI", "TCRVL", "TCRPX", "TCD", "TCDLT", "TCROT" },
      { "CTYPE", "CUNIT", "CRVAL", "CRPIX", "CD",  "CDELT", "CROTA" }
   };
   enum { cType=0, cUnit, cRefVal, cRefPix, cMatrix, cDelta, cRota };
   
   if( Col1 && Col2 ) {
      isImage = 0;
   } else {
      isImage = 1;
      Col1 = 1;
      Col2 = 2;
   }

   /*  Grab any existing WCS keywords.  Use defaults for missing values  */
   
   sprintf(keyword, "%s%d%c", Keys[isImage][cRefVal], Col1, dest);
   ffgkyd(curFile->fptr, keyword, &xrval, NULL, &status);
   if( status==KEY_NO_EXIST ) status = 0;
   
   sprintf(keyword, "%s%d%c", Keys[isImage][cRefVal], Col2, dest);
   ffgkyd(curFile->fptr, keyword, &yrval, NULL, &status);
   if( status==KEY_NO_EXIST ) status = 0;
   
   sprintf(keyword, "%s%d%c", Keys[isImage][cRefPix], Col1, dest);
   ffgkyd(curFile->fptr, keyword, &xrpix, NULL, &status);
   if( status==KEY_NO_EXIST ) status = 0;
   
   sprintf(keyword, "%s%d%c", Keys[isImage][cRefPix], Col2, dest);
   ffgkyd(curFile->fptr, keyword, &yrpix, NULL, &status);
   if( status==KEY_NO_EXIST ) status = 0;
   
   anyKeysFnd = 0;
   sprintf(keyword, "%s%d%c", Keys[isImage][cDelta], Col1, dest);
   ffgkyd(curFile->fptr, keyword, &xinc,  NULL, &status);
   if( status==KEY_NO_EXIST ) status = 0; else anyKeysFnd++;
   
   sprintf(keyword, "%s%d%c", Keys[isImage][cDelta], Col2, dest);
   ffgkyd(curFile->fptr, keyword, &yinc,  NULL, &status);
   if( status==KEY_NO_EXIST ) status = 0; else anyKeysFnd++;
   
   sprintf(keyword, "%s%d%c", Keys[isImage][cRota], Col2, dest);
   ffgkyd(curFile->fptr, keyword, &rot,   NULL, &status);
   if( status==KEY_NO_EXIST ) {
      /*  Try other column  */
      status = 0;
      if( !isImage ) {
         sprintf(keyword, "%s%d%c", Keys[isImage][cRota], Col1, dest);
         ffgkyd(curFile->fptr, keyword, &rot, NULL, &status);
         if( status==KEY_NO_EXIST ) {
            status=0;
         } else {
            rot = -rot;
            anyKeysFnd++;
         }
      }
   } else
      anyKeysFnd++;
   
   if( ! anyKeysFnd ) { /* Couldn't find old-style keys; look for new-style */
      anyKeysFnd = 0;
      matrix[0][0] = 1.0;
      sprintf(keyword, "%s%d_%d%c", Keys[isImage][cMatrix], Col1, Col1, dest);
      ffgkyd(curFile->fptr, keyword, &matrix[0][0],  NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0; else anyKeysFnd++;

      matrix[1][1] = 1.0;
      sprintf(keyword, "%s%d_%d%c", Keys[isImage][cMatrix], Col2, Col2, dest);
      ffgkyd(curFile->fptr, keyword, &matrix[1][1],  NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0; else anyKeysFnd++;

      matrix[0][1] = 0.0;
      sprintf(keyword, "%s%d_%d%c", Keys[isImage][cMatrix], Col1, Col2, dest);
      ffgkyd(curFile->fptr, keyword, &matrix[0][1],  NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0; else anyKeysFnd++;

      matrix[1][0] = 0.0;
      sprintf(keyword, "%s%d_%d%c", Keys[isImage][cMatrix], Col2, Col1, dest);
      ffgkyd(curFile->fptr, keyword, &matrix[1][0],  NULL, &status);
      if( status==KEY_NO_EXIST ) status = 0; else anyKeysFnd++;

      if( anyKeysFnd ) {

         /* Modified from CFITSIO... compute old-style from new-style */

         double phia, phib;
         double pi = 3.1415926535897932;

         /* there are 2 ways to compute the angle: */
         phia = atan2( matrix[1][0], matrix[0][0]);
         phib = atan2(-matrix[0][1], matrix[1][1]);
         
         /* ensure that phia <= phib */
         temp = minvalue(phia, phib);
         phib = maxvalue(phia, phib);
         phia = temp;
         
         /* there is a possible 180 degree ambiguity in the angles */
         /* so add 180 degress to the smaller value if the values  */
         /* differ by more than 90 degrees = pi/2 radians.         */
         /* (Later, we may decide to take the other solution by    */
         /* subtracting 180 degrees from the larger value).        */
         
         if( (phib - phia) > (pi * 0.5) )
            phia += pi;
         
         if( fabs(phia - phib) > 0.0002 ) {
            /* angles don't agree, so looks like there is some skewness */
            /* between the axes.  Return with an error to be safe.      */
            /* PDW: Lets just ignore this and give the best estimate we can.
                    status = APPROX_WCS_KEY; */
         }
         
         phia = (phia + phib) * 0.5;  /* use the average of the 2 values */
         temp = cos(phia);
         if( fabs(temp)<0.1 ) {
            temp = sin(phia);
            xinc = matrix[1][0] / temp;
            yinc =-matrix[0][1] / temp;
         } else {
            xinc = matrix[0][0] / temp;
            yinc = matrix[1][1] / temp;
         }
         rot  = phia * 180. / pi;
         
         /* common usage is to have a positive yinc value.  If it is */
         /* negative, then subtract 180 degrees from rot and negate  */
         /* both xinc and yinc.  */
         
         if( yinc < 0 ) {
            xinc = -xinc;
            yinc = -yinc;
            rot -= 180.0;
         }

      } /* else keep default delt/rot = 1/0 */
         
   }

   /*  Read both RA and DEC CTYPs to check that they both exist and agree  */

   sprintf(keyword, "%s%d%c", Keys[isImage][cType], Col1, dest);
   ffgkys(curFile->fptr, keyword, ctype,  NULL, &status);
   sprintf(keyword, "%s%d%c", Keys[isImage][cType], Col2, dest);
   ffgkys(curFile->fptr, keyword, ctemp,  NULL, &status);
   if( status || strlen(ctype)<5 || strlen(ctemp)<5
       || strcmp(ctype+4,ctemp+4) ) {
      strcpy(ctype,"none"); status = 0;
   } else {
      if( !strncmp(ctype, "DEC-", 4) || !strncmp(ctype+1, "LAT", 3) ) {
         /*   RA/Dec are swapped!!!  */
         swap = 1;
      }
      /* copy the projection type string */
      strncpy(ctype, &ctype[4], 4);
      ctype[4] = '\0';
   }

   data[0] = Tcl_NewDoubleObj(xrval);
   data[1] = Tcl_NewDoubleObj(yrval);
   data[2] = Tcl_NewDoubleObj(xrpix);
   data[3] = Tcl_NewDoubleObj(yrpix);
   data[4] = Tcl_NewDoubleObj(xinc);
   data[5] = Tcl_NewDoubleObj(yinc);
   data[6] = Tcl_NewDoubleObj(rot);
   data[7] = Tcl_NewStringObj(ctype,-1);
   
   if( userOptions.wcsSwap ) {
      data[8] = Tcl_NewBooleanObj( swap );
      Tcl_SetObjResult(curFile->interp, Tcl_NewListObj(9,data) );
   } else {
      Tcl_SetObjResult(curFile->interp, Tcl_NewListObj(8,data) );
   }
   
   ffcmsg();
   return TCL_OK;
}


/* extract the world coordinate from a table  */
/*    (Old behavior... deprecated)            */

int fitsTableGetWcsOld( FitsFD *curFile,
			int RAColNum,
			int DecColNum )
{
   int status = 0;
   double xrval, yrval, xrpix, yrpix, xinc, yinc, rot;
   char ctype[5];
   Tcl_Obj *data[8];
   
   ffgtcs(curFile->fptr, 
	  RAColNum,
	  DecColNum,
	  &xrval,
	  &yrval,
	  &xrpix,
	  &yrpix,
	  &xinc,
	  &yinc,
	  &rot,
	  ctype,
	  &status);
   if ( status ) {
      /* if there is no wcs info , keep silent */
      Tcl_SetResult(curFile->interp, "", TCL_STATIC);
      ffcmsg();
      return TCL_OK;  
   }
   
   data[0] = Tcl_NewDoubleObj(xrval);
   data[1] = Tcl_NewDoubleObj(yrval);
   data[2] = Tcl_NewDoubleObj(xrpix);
   data[3] = Tcl_NewDoubleObj(yrpix);
   data[4] = Tcl_NewDoubleObj(xinc);
   data[5] = Tcl_NewDoubleObj(yinc);
   data[6] = Tcl_NewDoubleObj(rot);
   data[7] = Tcl_NewStringObj(ctype,-1);
   
   Tcl_SetObjResult(curFile->interp, Tcl_NewListObj(8,data) );
   
   return TCL_OK;
}

/***********************************************************************/
/*                                                                     */
/*                      End of  WCS  Routines                          */
/***********************************************************************/



int fitsReadColData( FitsFD *curFile,
		     int colNum,
		     int strSize,
		     colData columndata[],
		     int *dataType )
{
   long numRows, i, vecSize;
   int status = 0;
   char **tmpPtr;
   char *nullArray=NULL;
   int anyf;
   int colType;
   double *tmpDbl;
   LONGLONG *tmpLonglong;
   long *tmpLong;
   char *tmpChar;
   char *cPtr;
   
   colType = curFile->CHDUInfo.table.colDataType[colNum-1];
   vecSize = curFile->CHDUInfo.table.vecSize[colNum-1];
   numRows = curFile->CHDUInfo.table.numRows;
   
   nullArray = (char *) ckalloc(numRows*sizeof(char));
   switch ( colType ) {

   case TSTRING:
      tmpPtr = (char **) makeContigArray(1, strSize+1, 'c');
      for (i=0;i<numRows;i++){
	 ffgcls(curFile->fptr,
		colNum,
		i+1,
		1,
		1,
		1,
		"NULL",
		tmpPtr,
		nullArray,
		&anyf,
		&status);     
	 if ( status ) {
	    status = 0;
	    strcpy(tmpPtr[0], "");
	    ffcmsg();
	 }
	 columndata[i].strData = (char *)ckalloc( (strSize+1)*sizeof(char) );
	 cPtr = tmpPtr[0];
	 while ( *cPtr == ' ') cPtr++;
	 strcpy(columndata[i].strData, cPtr);
      }
      ckfree((char *) tmpPtr[0]);
      ckfree((char *) tmpPtr);
      *dataType  = 0;
      break;

   case TSHORT:
   case TINT:
   case TBYTE:
   case TLONG: 
      tmpLong = (long *) ckalloc(numRows*sizeof(long));
      ffgclj(curFile->fptr,
	     colNum,
	     1,
	     1,
	     numRows,
	     vecSize,
	     1,
	     LONG_MAX,
	     tmpLong,
	     nullArray,
	     &anyf,
	     &status);     
      for (i=0; i< numRows; i++) 
	 columndata[i].intData = tmpLong[i];
      *dataType = 1;
      ckfree((char *)tmpLong);
      break;
      
   case TBIT: 
      tmpChar = (char *) ckalloc(1*sizeof(char));
      for (i=0;i<numRows;i++){
	 ffgcx(curFile->fptr,
	       colNum,
	       i+1,
	       1,
	       1,
	       tmpChar,
	       &status);     
	 
	 columndata[i].intData = tmpChar[0];
      }
      *dataType = 1;
      ckfree((char *)tmpChar);
      break;  
      
   case TLOGICAL:
      tmpChar   = (char *) ckalloc(numRows*sizeof(char));
      ffgcfl(curFile->fptr,
	     colNum,
	     1,
	     1,
	     numRows,
	     tmpChar,
	     nullArray,
	     &anyf,
	     &status);     
      for (i=0; i< numRows; i++) {
	 if ( nullArray[i] ) {
	    columndata[i].intData = 2;
	 } else {
	    columndata[i].intData = tmpChar[i];
	 }
      }
      *dataType = 1;
      ckfree((char *)tmpChar  );
      break;

   case TFLOAT:
   case TDOUBLE:
      tmpDbl = (double *) ckalloc(numRows*sizeof(double));
      ffgcld(curFile->fptr,
	     colNum,
	     1,
	     1,
	     numRows,
	     vecSize,
	     1,
	     DBL_MAX,
	     tmpDbl,
	     nullArray,
	     &anyf,
	     &status);     
      for (i = 0; i < numRows; i++ ) 
	 columndata[i].dblData = tmpDbl[i];
      *dataType = 2;
      ckfree((char *) tmpDbl);
      break;    
      
   case TLONGLONG:
      tmpLonglong = (LONGLONG *) ckalloc(numRows*sizeof(LONGLONG));
      ffgcljj(curFile->fptr,
	      colNum,
	      1,
	      1,
	      numRows,
	      vecSize,
	      1,
	      (LONGLONG)NULL,
	      tmpLonglong,
	      nullArray,
	      &anyf,
	      &status);     
      for (i = 0; i < numRows; i++ ) 
	 columndata[i].longlongData = tmpLonglong[i];
      *dataType = 3;
      ckfree((char *) tmpLonglong);
      break;    
      
   default: 
      Tcl_SetResult(curFile->interp,
		    "fitsTcl ERROR: unknown column type", TCL_STATIC);
      return TCL_ERROR;
   }
   
   ckfree((char *)nullArray);
   return TCL_OK;
}


int fitsReadRawColData( FitsFD *curFile,
			colData columndata[],
			LONGLONG *rowSize )
{
   long numRows, i; 
   int status = 0;
   long *tbcol;
   
   numRows = curFile->CHDUInfo.table.numRows;
   
   if ( ASCII_TBL == curFile->hduType ) {
      /*
      tbcol = (long *) ckalloc(curFile->CHDUInfo.table.numCols*sizeof(long));
      ffgabc(curFile->CHDUInfo.table.numCols,
	     curFile->CHDUInfo.table.colType,
	     1,
	     rowSize,
	     tbcol,
	     &status);
      */
     *rowSize =curFile->CHDUInfo.table.rowLen;
   } else if ( BINARY_TBL == curFile->hduType) {
      /*
      ffgtbc(curFile->fptr, rowSize, &status);
      */
      *rowSize =curFile->CHDUInfo.table.rowLen;
   } else {
      Tcl_SetResult(curFile->interp,
		    "fitsTcl ERROR:unknown table type", TCL_STATIC);
      return TCL_ERROR; 
   }
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   }
   
   for (i = 0; i < numRows; i++ ) {
      columndata[i].rowindex = i+1; 
      columndata[i].colBuffer = (unsigned char *) 
	 ckalloc( *rowSize * sizeof(unsigned char) );
      ffgtbb(curFile->fptr, i+1, 1, *rowSize, columndata[i].colBuffer, &status);
      
      if ( status ) {
	 status = 0;
	 ffcmsg();
      }
      columndata[i].flag = 0;  /*  Init flag values  */
   }

   return TCL_OK;
}

int fitsSortTable( FitsFD *curFile,
		   int numCols,
		   int *colNum,
		   int *strSize,
		   int *isAscend,
		   int isMerge )
{
   int result, i, j, k;
   colData *columndata;
   int dataType;
   long *bottom;
   long *top;
   long nrange=0, numRows, uniqueNum;
   LONGLONG rowSize;

   char ** rowlist;

   
   numRows = curFile->CHDUInfo.table.numRows;
   columndata = (colData *) ckalloc(numRows*sizeof(colData));  
   /* read in raw table data in rows */
   result = fitsReadRawColData(curFile, columndata, &rowSize);
   if (result != TCL_OK) {
      ckfree((char *) columndata);
      return TCL_ERROR;
   }

   rowlist = (char **) ckalloc(numRows*sizeof(char*));
   for (i=0; i<numRows ; i++ ) {
        rowlist[i] = (char *) ckalloc(33*sizeof(char));
   }
   
   nrange = 1;
   for ( i=0; i<numCols && nrange>0 ; i++ ) {

      result = fitsReadColData(curFile, colNum[i], strSize[i], 
			       columndata, &dataType);
      if (result != TCL_OK) {
	 fitsFreeRawColData( columndata, numRows );
	 ckfree((char *) columndata);
	 return TCL_ERROR;
      }
      
      /* allocate top and bottom */
      top    = (long *)ckalloc(nrange*sizeof(long));
      bottom = (long *)ckalloc(nrange*sizeof(long));

      if( i ) {
	 fitsGetSortRange(columndata, numRows, top, bottom);
      } else {
	 fitsRandomizeColData( columndata, numRows );
	 top[0]    = numRows-1;
	 bottom[0] = 0;
      }
      
      /* do sorting when there are identical keys */
      for ( j=0; j < nrange; j++ ) {
	 for ( k=bottom[j]; k<=top[j]; k++ ) {
            if (dataType == 0 && (strcmp(columndata[k].strData,"NULL") == 0)) {
               strcpy(columndata[k].strData, "\0");
            } else {
	       columndata[k].flag = 0;
            }
	 }

         fitsQuickSort(columndata, dataType, strSize[i], bottom[j], top[j], isAscend[i]);
         fitsQSsetFlag(columndata, dataType, strSize[i], bottom[j], top[j]);
      }
      ckfree((char *) top);
      ckfree((char *) bottom);
      
      if (dataType == 0)
	 for ( j=0; j< numRows; j++)
	    ckfree((char *) columndata[j].strData);
      
      /* before read more keys, write the sorted buffer to file */
      result = fitsWriteRowsToFile(curFile, rowSize, columndata,
				   ( i+1 == numCols ? isMerge : 0 ) );
      if (result != TCL_OK) {
	 fitsFreeRawColData( columndata, numRows );
	 ckfree((char *) columndata);
	 return TCL_ERROR;
      }
      
      /* prepare for the next key */
      fitsGetSortRangeNum(columndata, numRows, &nrange);

   }

/*   numRows = curFile->CHDUInfo.table.numRows; */
   uniqueNum = 0;
   if (isMerge == 0  ) {
      for (i=0; i<numRows; i++) {
         sprintf(rowlist[i],"%d",columndata[i].rowindex);
      }
      
   } else {
      for (i=0; i<numRows; i++) {
         if ( columndata[i].flag == 0 ) {
         sprintf(rowlist[uniqueNum],"%d",columndata[i].rowindex);
         uniqueNum++;
         }
      }
   }


   if (isMerge == 1 ) { 
   Tcl_AppendElement(curFile->interp,Tcl_Merge(uniqueNum,rowlist));
   } else {
   Tcl_AppendElement(curFile->interp,Tcl_Merge(numRows,rowlist));
   }

   for ( i=0; i<numRows; i++) {
        ckfree(rowlist[i]);
   }
   ckfree(rowlist);

   
   
   /* clean up the columndata */
   fitsFreeRawColData( columndata, numRows );
   ckfree((char *) columndata);
   
   return TCL_OK;
}

int fitsWriteRowsToFile( FitsFD *curFile,
			 long rowSize,
			 colData columndata[],
			 int isMerge )
{
   long i;
   int status   = 0;
   long numRows = curFile->CHDUInfo.table.numRows ;
   long uniqNum = 0;
   
   /* write the buffer to file */
   if( isMerge ) {
      for (i=0; i< numRows; i++) {
	 if ( columndata[i].flag == 0) { 
	    uniqNum++;
	    ffptbb(curFile->fptr, uniqNum, 1, rowSize,
		   columndata[i].colBuffer, &status);
	    if ( status ) {
	       dumpFitsErrStack(curFile->interp, status);
	       return TCL_ERROR;
	    } 
	 }
      }
      if ( uniqNum != numRows) {
	 ffdrow(curFile->fptr, uniqNum+1, numRows-uniqNum, &status);
      }
   } else {
      for (i=0; i< numRows; i++) {
	 ffptbb(curFile->fptr, i+1, 1, rowSize,
		columndata[i].colBuffer, &status);
	 if( status ) {
	    dumpFitsErrStack(curFile->interp, status);
	    return TCL_ERROR;
	 } 
      }
   }
   return  fitsUpdateFile(curFile);
}

void fitsGetSortRangeNum( colData a[],
			  long n,
			  long *nr )
{
   long i, count = 0;
   unsigned char flag = 0;
   
   /* an identical key start with sequence of "0 1 1 1 ... 1"  */
   for (i=0; i<n; i++) {
      if( a[i].flag && !flag ) {
	 flag = 1;
      } else if( !a[i].flag && flag ) {
	 flag = 0;
	 count++;
      } 
   }
   /* if the last has the flag on, add one more */  
   if( flag ) 
      count++;
   
   /* total number keys which have identical entries */
   *nr = count;
}


void fitsGetSortRange( colData a[],
		       long n,
		       long t[],
		       long b[] )
{
   long i, count = 0;
   unsigned char flag = 0;
   
   /* same as in fitsGetSortRangeNum */
   for (i=0; i<n; i++) {
      if( a[i].flag && !flag ) {
	 flag = 1;
	 b[count] = i-1;
      } else if( !a[i].flag && flag ) {
	 flag = 0;
	 t[count] = i-1;	
	 count++;
      } 
   }
   
   if( flag ) {
      count++;
      t[count-1] = n-1;
   }
}

int fitsUpdateFile( FitsFD *curFile )
{
   
   int status = 0;
   
   /* write END keyword */
   ffflsh(curFile->fptr, 0, &status);
   ffchdu(curFile->fptr, &status);
   ffrdef(curFile->fptr, &status);
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;
   } 
   
   /* reload info */
   if ( TCL_OK != fitsUpdateCHDU(curFile, curFile->hduType) ) {
      Tcl_SetResult(curFile->interp,
		    "Cannot update current HDU", TCL_STATIC);
      return TCL_ERROR;
   }
   
   /* reload the hdu */
   
   return fitsLoadHDU(curFile);
}

int fitsColumnStatistics( FitsFD *curFile,
			  int colNum,
			  int felem,
			  int numrange,
			  int range[][2] )
{
   colStat colstat;
   char tmpStr[80];
   int statFlag = 1;

   if ( TCL_OK != fitsColumnStatToPtr(curFile, colNum, felem, numrange, 
				      range, &colstat, statFlag) ) 
      return TCL_ERROR;
   
   Tcl_ResetResult(curFile->interp);

   if (colstat.min < 0.000000100 || colstat.min > 999999999) {
     sprintf(tmpStr, "%16.8g", colstat.min);
   } else {
     sprintf(tmpStr, "%.10f",  colstat.min);
   }
   Tcl_AppendElement(curFile->interp, tmpStr); 

   sprintf(tmpStr, "%ld",  colstat.fmin);
   Tcl_AppendElement(curFile->interp, tmpStr); 

   if (colstat.max < 0.000000100 || colstat.max > 999999999) {
     sprintf(tmpStr, "%16.8g", colstat.max);
   } else {
     sprintf(tmpStr, "%.10f",  colstat.max);
   }
   Tcl_AppendElement(curFile->interp, tmpStr); 

   sprintf(tmpStr, "%ld",  colstat.fmax);
   Tcl_AppendElement(curFile->interp, tmpStr); 

   if (colstat.mean < 0.000000100 || colstat.mean > 999999999) {
     sprintf(tmpStr, "%16.8g", colstat.mean);
   } else {
     sprintf(tmpStr, "%.10f",  colstat.mean);
   }
   Tcl_AppendElement(curFile->interp, tmpStr); 

   if (colstat.stdiv < 0.000000100 || colstat.stdiv > 999999999) {
     sprintf(tmpStr, "%16.8g", colstat.stdiv);
   } else {
     sprintf(tmpStr, "%.10f",  colstat.stdiv);
   }
   Tcl_AppendElement(curFile->interp, tmpStr); 

   sprintf(tmpStr, "%ld",  colstat.numData);
   Tcl_AppendElement(curFile->interp, tmpStr); 

   return TCL_OK;
}

int fitsColumnMinMax( FitsFD *curFile,
		      int colNum,
		      int felem,
		      int numrange,
		      int range[][2] )
{
   colStat colstat;
   char tmpStr[80];
   int statFlag = 0;
   
   if ( TCL_OK != fitsColumnStatToPtr(curFile, colNum, felem, numrange, 
				      range, &colstat, statFlag) ) 
      return TCL_ERROR;
   
   sprintf(tmpStr, "%.10f", colstat.min);
   Tcl_SetResult(curFile->interp, tmpStr, TCL_VOLATILE);

   sprintf(tmpStr, "%.10f",  colstat.max);
   Tcl_AppendElement(curFile->interp, tmpStr); 
   
   return TCL_OK;
}

int fitsColumnMinMaxToPtr( FitsFD *curFile,
			   int colNum,
			   int felem,
			   int fRow,
			   int lRow,
			   double *min,
			   double *max )
{
   colStat colstat;
   int statFlag = 0;
   int range[1][2];
   
   range[0][0] = fRow;
   range[0][1] = lRow;
   if ( TCL_OK != fitsColumnStatToPtr(curFile, colNum, felem, 1, 
				      range, &colstat, statFlag) ) 
      return TCL_ERROR;
   
   *min = colstat.min;
   *max = colstat.max;
   return TCL_OK;
}

int fitsColumnStatToPtr( FitsFD *curFile,
			 int colNum,
			 int felem,
			 int numrange,
			 int range[][2],
			 colStat *colstat,
			 int statFlag )
{
   int m;
   int nRows, numRows;
   double *array;
   char *flagArray;
   int colType;
   int n;
   long fRow, lRow;
   
   double min = DBL_MAX;
   double max = -DBL_MAX;
   
   double d_total = 0.0;
   double s_total = 0.0;
   long   l_count = 0;
   
   colType = curFile->CHDUInfo.table.colDataType[colNum-1];
   
   if ( colType == TSTRING || colType == TLOGICAL || colType == TCOMPLEX
	|| colType == TDBLCOMPLEX || (colType == TBIT && statFlag) ) {
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: cannot work on this type of column",
		    TCL_STATIC);
      return TCL_ERROR;
   }
   
   nRows = curFile->CHDUInfo.table.numRows;
   
   /* check if is a vector column */
   if ( felem > curFile->CHDUInfo.table.vecSize[colNum-1] ) {
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: vector out of bound", TCL_STATIC);
      return TCL_ERROR;
   }
   
   /* if not a vector and colMin and colMax are loaded then skip calculation */
   if ( !statFlag ) {
      if ( curFile->CHDUInfo.table.vecSize[colNum-1] <= 1 &&
	   (curFile->CHDUInfo.table.colMin[colNum-1] != DBL_MIN  ||
	    curFile->CHDUInfo.table.colMax[colNum-1] != DBL_MAX  )) {
	 if ( range[0][0] == 1L && (range[0][1] ==  nRows) ) {
	    min = curFile->CHDUInfo.table.colMin[colNum-1] ; 
	    max = curFile->CHDUInfo.table.colMax[colNum-1] ; 
	    colstat->min = min;
	    colstat->max = max;
	    
	    return TCL_OK;
	 }
      }
   }
   
   for (n=0; n < numrange; n++) {
      fRow = range[n][0];
      lRow = range[n][1];
      numRows = lRow - fRow + 1;
      array = (double *) ckalloc(numRows*sizeof(double));
      flagArray = (char *) ckalloc(numRows*sizeof(char));
      
      if ( fitsColumnGetToArray(curFile, colNum, felem, fRow, lRow, 
				array, flagArray) != TCL_OK) {
	 ckfree((char *) array);
	 ckfree((char *) flagArray);
	 return TCL_ERROR;
      }
      
      if ( statFlag ) {
	 for (m=0; m < numRows; m++ ) {
	    if ( !flagArray[m] ) {
	       d_total += array[m];
	       s_total += array[m] * array[m];
	       l_count ++;
	       if (max < array[m])  {
		  max = array[m];
		  colstat->fmax = fRow + m;
	       }
	       if (min > array[m]) {
		  min = array[m];
		  colstat->fmin = fRow + m;
	       }
	    }
	 }
      } else {
	 for (m=0; m < numRows; m++ ) {
	    if ( !flagArray[m] ) {
	       if (max < array[m])  max = array[m];
	       if (min > array[m])  min = array[m];
	    }
	 }  
      }
      
      if ( fRow == 1 && lRow == nRows ) {
	 /* update curFile info */
	 curFile->CHDUInfo.table.colMin[colNum-1] = min; 
	 curFile->CHDUInfo.table.colMax[colNum-1] = max; 
      }
      
      ckfree((char *)array);
      ckfree((char *)flagArray);
   }
   
   colstat->min = min;
   colstat->max = max;
   
   if ( statFlag ) {    
      colstat->mean    = d_total/l_count;
      colstat->numData = l_count;
      if ( l_count-1 <= 0 ) {
	 colstat->stdiv = 0;
      } else {
	 s_total -= l_count * colstat->mean * colstat->mean;
	 colstat->stdiv = sqrt(s_total/(l_count-1));
      }
   }
   
   return TCL_OK; 
}


int fitsColumnGetToArray( FitsFD *curFile,
			  int    colNum,
			  int    felem,
			  long   fRow,
			  long   lRow, 
			  double *array,
			  char   *flagArray ) 
{
   int status = 0;
   long nRows, m;
   char cValue[1];
   double dblValue[1];
   LONGLONG longlongValue[1];
   int dataType;
   char nullArray[1];
   int anyf = 0;
   
   /* check the row range */
   if ( lRow > curFile->CHDUInfo.table.numRows) 
      lRow = curFile->CHDUInfo.table.numRows;
   
   if ( fRow < 1) fRow = 1;
   if ( lRow < 1) lRow = 1;
   
   nRows = lRow - fRow +1;
   
   dataType = curFile->CHDUInfo.table.colDataType[colNum-1];
   
   switch ( dataType ) {

   case TBIT:
      for (m=0; m < nRows; m++ ) {
	 ffgcfl(curFile->fptr,
		colNum,
		fRow+m,
		felem,
		1,
		cValue,
		nullArray,
		&anyf,
		&status);
	 if ( status > 0 ) {
	    flagArray[m] = 2;
	    array[m] = 0;
	    status = 0;
	    ffcmsg();
	 } else if ( nullArray[0] )  {
	    flagArray[m] = 1;
	    array[m] = 0;
	 } else {
	    flagArray[m] = 0;
	    array[m] = cValue[0];
	 }
      }
      break; 

   case TBYTE:  /*  CFITSIO does automatic type conversion for columns  */
   case TSHORT: /*  Don't know about the TBIT -> TDOUBLE conversion?    */
   case TINT:
   case TLONG:
   case TFLOAT:
   case TDOUBLE:
      for (m=0; m < nRows; m++ ) {
	 ffgcfd(curFile->fptr,
		colNum,
		fRow+m,
		felem,
		1,
		dblValue,
		nullArray,
		&anyf,
		&status);
	 if ( status > 0 ) {
	    flagArray[m] = 2;
	    array[m] = 0;
	    status = 0;
	    ffcmsg();
	 } else if ( nullArray[0] )  {
	    flagArray[m] = 1;
	    array[m] = 0;
	 } else {
	    flagArray[m] = 0;
	    array[m] = dblValue[0];
	 }
      }
      break;

   case TLONGLONG:
      for (m=0; m < nRows; m++ ) {
	 ffgcfjj(curFile->fptr,
	  	 colNum,
		 fRow+m,
		 felem,
		 1,
		 longlongValue,
		 nullArray,
		 &anyf,
		 &status);
	 if ( status > 0 ) {
	    flagArray[m] = 2;
	    array[m] = 0;
	    status = 0;
	    ffcmsg();
	 } else if ( nullArray[0] )  {
	    flagArray[m] = 1;
	    array[m] = 0;
	 } else {
	    flagArray[m] = 0;
	    array[m] = longlongValue[0];
	 }
      }
      break;

   default:
      Tcl_SetResult(curFile->interp,
		    "fitsTcl Error: Not a numerical column", TCL_STATIC);
      ckfree ((char *) flagArray);
      return TCL_ERROR;
   }
   
   return TCL_OK;
}

int fitsCalculaterngColumn( FitsFD *curFile,
			 char *colName,
			 char *colForm,
			 char *expr ,
                         int numrange, int range[][2] )
{
   int status=0;
   int i;

   long * firstrow;
   long * lastrow;

   firstrow = (long *) malloc(numrange*sizeof(long));
   lastrow = (long *) malloc(numrange*sizeof(long));

   for (i=0; i<numrange; i++) {
       firstrow[i] =range[i][0];
       lastrow[i] =range[i][1];
   }
   
   ffcalc_rng( curFile->fptr, expr, curFile->fptr, colName, colForm, numrange, 
               firstrow,lastrow, &status );
   free(firstrow);
   free(lastrow);
   
   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;  
   }	  
   
   return fitsUpdateFile(curFile);
}

int fitsCalculateColumn( FitsFD *curFile,
			 char *colName,
			 char *colForm,
			 char *expr )
{
   int status=0;
   
   ffcalc( curFile->fptr, expr, curFile->fptr, colName, colForm, &status );
   
   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;  
   }	  
   
   return fitsUpdateFile(curFile);
}


int fitsSelectRowsExpr (FitsFD *curFile,
                        char *expr,
                        long firstrow,
                        long nrows,
                        long * n_good_rows,
                        char * row_status)

{   
   int status=0;
   int i;
   fffrow( curFile->fptr, expr, firstrow, nrows,
           n_good_rows, row_status,&status );

   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;  
   }	  
      return TCL_OK;  
}
 




int fitsDeleteRowsExpr( FitsFD *curFile,
			char *expr )
{
   int status=0;
   char *negExpr;
   
   negExpr = (char*)ckalloc((strlen(expr)+15)*sizeof(char));
   sprintf(negExpr,"DEFNULL(!(%s),T)",expr);
   ffsrow( curFile->fptr, curFile->fptr, negExpr, &status );
   ckfree( negExpr );
   
   if( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;  
   }	  
   
   return fitsUpdateFile(curFile);
}


/*
 * ------------------------------------------------------------
 *
 * exprGetToPtr
 *
 * return : "address dataType numberElements"
 * address can be recovered using sscanf(address, PTRFORMAT, &dataArray)
 *            where void *dataArray
 * dataType : 0 uchar, 2 int, 4 double (No others allowed)
 * numberElements : dimension of the array             
 *
 * ------------------------------------------------------------
 */

int exprGetToPtr( FitsFD *curFile, char *expr, char *nulStr,
                  int numrange, int range[][2] )
{
   void *backPtr;
   
   LONGLONG       *longlongArray;
   double         *dblArray;
   int            *intArray;
   unsigned char  *bytArray;
   
   LONGLONG longlongNul;
   double dblNul;
   int    intNul;
   unsigned char bytNul;
   
   long numRows;
   int anynul=0;
   
   int dataType, naxis;
   long nelem, naxes[5], offset=0, ntodo;
   char result[80];
   int status = 0;
   int rngCnt;
   
   fftexp( curFile->fptr,
	   expr,
	   5,
	   &dataType,
	   &nelem,
	   &naxis,
	   naxes,
	   &status );
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;	   
   } 
   
   if( nelem < 0 ) nelem = -nelem;  /*  Flags a constant result  */
   
   /*  Count the number of rows  */
   numRows = 0;
   for( rngCnt=0; rngCnt<numrange; rngCnt++ )
      numRows += range[rngCnt][1]-range[rngCnt][0]+1;
   
   switch (dataType) {

   case TLOGICAL:
      if( !strcmp(nulStr, "NULL") ) {
	 bytNul = 255;
      } else {
	 bytNul = atoi(nulStr);
      }
      
      bytArray = (unsigned char *) ckalloc(numRows*nelem*sizeof(char));
      for( rngCnt=0; rngCnt<numrange && !status; rngCnt++ ) {
         ntodo = range[rngCnt][1]-range[rngCnt][0]+1;
         ffcrow( curFile->fptr,
                 TLOGICAL,
                 expr,
                 (long)range[rngCnt][0],
                 (long)nelem*ntodo,
                 &intNul,
                 bytArray+offset,
                 &anynul,
                 &status );
         offset += nelem*ntodo;
      }
      dataType = BYTE_DATA;
      backPtr  = bytArray;
      break;	

   case TLONG:
      if( !strcmp(nulStr, "NULL") ) {
	 intNul = INT_MAX;
      } else {
	 intNul = atol(nulStr);
      }
      /* pow/visu donot like long type array. convert to int */
      
      intArray = (int  *) ckalloc(numRows*nelem*sizeof(int));
      for( rngCnt=0; rngCnt<numrange && !status; rngCnt++ ) {
         ntodo = range[rngCnt][1]-range[rngCnt][0]+1;
         ffcrow( curFile->fptr,
                 TINT,
                 expr,
                 (long)range[rngCnt][0],
                 (long)nelem*ntodo,
                 &intNul,
                 intArray+offset,
                 &anynul,
                 &status );
         offset += nelem*ntodo;
      }
      dataType = INT_DATA;
      backPtr  = intArray;
      break;	

   case TDOUBLE:
      if( !strcmp(nulStr, "NULL") ) {
	 dblNul = DBL_MAX;
      } else {
	 dblNul = atof(nulStr);
      } 
      dblArray = (double *) ckalloc(numRows*nelem*sizeof(double));
      for( rngCnt=0; rngCnt<numrange && !status; rngCnt++ ) {
         ntodo = range[rngCnt][1]-range[rngCnt][0]+1;
         ffcrow( curFile->fptr,
                 TDOUBLE,
                 expr,
                 (long)range[rngCnt][0],
                 (long)nelem*ntodo,
                 &dblNul,
                 dblArray+offset,
                 &anynul,
                 &status );
         offset += nelem*ntodo;
      }
      dataType = DOUBLE_DATA;
      backPtr  = dblArray;	
      break;

   case TLONGLONG:
      if( !strcmp(nulStr, "NULL") ) {
	 longlongNul = (LONGLONG)NULL;
      } else {
	 longlongNul = atof(nulStr);
      } 
      longlongArray = (LONGLONG *) ckalloc(numRows*nelem*sizeof(LONGLONG));

      for( rngCnt=0; rngCnt<numrange && !status; rngCnt++ ) {
         ntodo = range[rngCnt][1]-range[rngCnt][0]+1;
         ffcrow( curFile->fptr,
                 TLONGLONG,
                 expr,
                 (long)range[rngCnt][0],
                 (long)nelem*ntodo,
                 &longlongNul,
                 longlongArray+offset,
                 &anynul,
                 &status );
         offset += nelem*ntodo;
      }
      dataType = LONGLONG_DATA;
      backPtr  = longlongArray;	
      break;

   default:
      Tcl_SetResult(curFile->interp, 
		    "fitsTcl Error: cannot load this type of expression",
		    TCL_STATIC);
      return TCL_ERROR;
   }
   
   if ( status ) {
      ckfree( (char *)backPtr );
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;	   
   } 

   sprintf( result, PTRFORMAT " %d %ld",
	    backPtr, dataType, numRows*nelem );
   Tcl_SetResult(curFile->interp, result, TCL_VOLATILE);
   return TCL_OK;
}

/*
 * ------------------------------------------------------------
 *
 * exprGetInfo
 *
 * return : "dataType numberElements naxes"
 * address can be recovered using sscanf(address, PTRFORMAT, &dataArray)
 *            where void *dataArray
 * dataType : CFITSIO datatype... TDOUBLE, TSTRING, etc
 *
 * ------------------------------------------------------------
 */

int exprGetInfo( FitsFD *curFile, char *expr )
{
   long i;
   char tmpStr[32];
   
   int dataType, naxis;
   long nelem, naxes[5];
   int status = 0;
   
   Tcl_ResetResult(curFile->interp);
   
   fftexp( curFile->fptr,
	   expr,
	   5,
	   &dataType,
	   &nelem,
	   &naxis,
	   naxes,
	   &status );
   if ( status ) {
      dumpFitsErrStack(curFile->interp, status);
      return TCL_ERROR;	   
   } 
   
   sprintf( tmpStr, "%d %ld {", dataType, nelem );
   Tcl_AppendResult( curFile->interp, tmpStr, (char*)NULL );
   for( i=0; i<naxis; i++ ) {
      sprintf( tmpStr, " %ld ", naxes[i] );
      Tcl_AppendResult( curFile->interp, tmpStr, (char *)NULL );
   }
   Tcl_AppendResult( curFile->interp, "}", (char *)NULL );
   return TCL_OK;
}
