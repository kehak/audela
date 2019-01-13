/************************************************************
 *
 * fvTcl.c
 *    
 *    This holds all the fv-specific Tcl commands
 *
 ***********************************************************/

#include "fitsTclInt.h"

/* 
 * ------------------------------------------------------------
 * 
 *    isFitsCmd
 *    check for fits file
 *    usage : isFits filename (1 is, 0 no)
 * 
 * ------------------------------------------------------------
 */

int isFitsCmd( ClientData clientData,
	       Tcl_Interp *interp,
	       int argc,
	       char *const argv[])
{
   char simple[10];
   int i;
   FILE *fitsPtr;
   
   if( argc != 2 ) {
      Tcl_SetResult(interp, "Usage: isFits filename", TCL_STATIC);
      return TCL_ERROR;
   }
   
   /* check if it's a remote file */
   if ( !strncmp(argv[1], "ftp://", 6)
	|| !strncmp(argv[1], "http://", 7) ) {
      Tcl_SetResult(interp, "2", TCL_STATIC);
      return TCL_OK;
   }
   
   /* also pass if it's a fv script file */
   if( strstr(argv[1], ".fv") ) {
      Tcl_SetResult(interp, "3", TCL_STATIC);
      return TCL_OK;
   }
   
   /* skip IRAF files end with .imh */
   if( strstr(argv[1], ".imh") ) {
      Tcl_SetResult(interp, "4", TCL_STATIC);
      return TCL_OK;
   }
   
   
   if( (fitsPtr = fopen(argv[1], "r")) == NULL ) {
      Tcl_AppendResult(interp, "File not found: ", argv[1], (char*)NULL );
      return TCL_ERROR;
   }

   fgets(simple, 7, fitsPtr);

   /* to catch a zero length file */
   /* if( strlen(simple) < 6 ) { */
   if( strlen(simple) <= 0 ) {
      Tcl_SetResult(interp, "0", TCL_STATIC);
      /* real FITS file */
   } else if( !strcmp(simple, "SIMPLE") ) {
      for ( i = 0; i< 100; i++) {
	 if ( (fgetc(fitsPtr) == '\n') || (fgetc(fitsPtr) == '\r') ) {
	    Tcl_SetResult(interp, "0", TCL_STATIC);
	    break;
	 }
	 Tcl_SetResult(interp, "1", TCL_STATIC);
      }
      /* compressed file. should check if its FITS */
   } else if( strncmp(simple, "\037\036", 2) == 0 || 
	      strncmp(simple, "\037\213", 2) == 0 || 
	      strncmp(simple, "\037\240", 2) == 0 || 
	      strncmp(simple, "\037\235", 2) == 0 || 
	      strncmp(simple, "\120\113", 2) == 0 ) {
      /* return 2 if the file is compressed files */
      Tcl_SetResult(interp, "2", TCL_STATIC);
   } else {
      Tcl_SetResult(interp, "0", TCL_STATIC);
   }
      
   fclose(fitsPtr); 
   return TCL_OK;
}

/* 
 * ------------------------------------------------------------
 * 
 *    getMaxCmd
 *    pick out the maximum
 *
 * ------------------------------------------------------------
 */

int getMaxCmd( ClientData clientData,
	       Tcl_Interp *interp,
	       int argc,
	       char *const argv[] )
{
   int i, numCount, j; 
   char **arrayPtr;
   double theMax, tmp;
   char theMaxStr[40];
   
   if( argc == 1 ) {
      Tcl_SetResult(interp, "getmax list ?list? ...", TCL_STATIC);
      return TCL_OK;
   }        
   
   theMaxStr[39]='\0';
   
   for (i=1; i<argc; i++) {
      if( Tcl_SplitList(interp, argv[i], &numCount,  &arrayPtr) != TCL_OK ) {
	 Tcl_SetResult(interp, "Error splitting list", TCL_STATIC);
	 return TCL_ERROR;
      }
      
      if ( i == 1 ) {
	 theMax = atof(arrayPtr[0]);
	 strncpy(theMaxStr, arrayPtr[0], 39);
      }
      
      for (j=0; j<numCount; j++) {
         tmp = atof(arrayPtr[j]);
         if ( tmp > theMax ) {
	    theMax = tmp;
	    strncpy(theMaxStr, arrayPtr[j], 39);
	 }
      }
      ckfree((char *) arrayPtr);
      
   }
   
   Tcl_SetResult(interp, theMaxStr, TCL_VOLATILE); 
   return TCL_OK;
}


/* 
 * ------------------------------------------------------------
 * 
 *    getMinCmd
 *    pick out the minimum
 *
 * ------------------------------------------------------------
 */

int getMinCmd( ClientData clientData,
	       Tcl_Interp *interp,
	       int argc,
	       char *const argv[] )
{
   
   int i, numCount, j; 
   char **arrayPtr;
   double theMin, tmp;
   char theMinStr[40];
   
   if( argc == 1 ) {
      Tcl_SetResult(interp, "getmin list", TCL_STATIC);
      return TCL_OK;
   }        
   
   theMinStr[39] = '\0';
   
   for (i=1; i<argc; i++) {
      
      if( Tcl_SplitList(interp, argv[i], &numCount, &arrayPtr) != TCL_OK ) {
	 Tcl_SetResult(interp, "Error in splitting list", TCL_STATIC);
	 return TCL_ERROR;
      }
      if( i == 1 ) {
	 theMin = atof(arrayPtr[0]);
	 strncpy(theMinStr, arrayPtr[0], 39);
      }
      
      for (j=0; j<numCount; j++) {
         tmp = atof(arrayPtr[j]);
         if ( tmp < theMin ) {
	    theMin = tmp;
	    strncpy(theMinStr, arrayPtr[j], 39);
	 }
      }
      
      ckfree((char *) arrayPtr);
   }
   
   Tcl_SetResult(interp, theMinStr, TCL_VOLATILE);
   return TCL_OK;
}


/* 
 * ------------------------------------------------------------
 * 
 *    initialize an array 
 *    usage : setarray arrayName start end value
 *                        
 * ------------------------------------------------------------
 */

int setArray( ClientData clientData,
	      Tcl_Interp *interp,
	      int argc,
	      char *const argv[] )
{
   static char helpmsg[] = "usage: setarray arrayName start end status ";
   int start, end, i;
   char idxStr[80];
   
   if( argc != 5 ) {
      Tcl_SetResult(interp, helpmsg, TCL_STATIC);
      return TCL_ERROR;
   }
   
   if ( TCL_OK != Tcl_GetInt(interp, argv[2], &start) ) {
      Tcl_SetResult(interp, "Error reading start index", TCL_STATIC);
      return TCL_ERROR;
   }
   
   if ( TCL_OK != Tcl_GetInt(interp, argv[3], &end) ) {
      Tcl_SetResult(interp, "Error reading end index", TCL_STATIC);
      return TCL_ERROR;
   }
   
   for (i=start; i<=end ; i++) {
      sprintf(idxStr, "%d", i);    
      Tcl_SetVar2(interp, argv[1], idxStr, argv[4], 0);
   }

   return TCL_OK;
}

/* 
 * ------------------------------------------------------------
 * 
 *    search an array for a value. return 1 or 0
 *    usage : sarray arrayName start end value
 *                        
 * ------------------------------------------------------------
 */

int searchArray( ClientData clientData,
		 Tcl_Interp *interp,
		 int argc,
		 char *const argv[] )
{
   static char helpmsg[] = "usage: sarray arrayName start end value";
   int start, end ,i;
   char idxStr[80];
   char *arrayValue;
   
   if( argc != 5 ) {
      Tcl_SetResult(interp, helpmsg, TCL_STATIC);
      return TCL_ERROR;
   }
   
   if ( TCL_OK != Tcl_GetInt(interp, argv[2], &start) ) {
      Tcl_SetResult(interp, "Error reading start index", TCL_STATIC);
      return TCL_ERROR;
   }
   
   if ( TCL_OK != Tcl_GetInt(interp, argv[3], &end) ) {
      Tcl_SetResult(interp, "Error reading end index", TCL_STATIC);
      return TCL_ERROR;
   }
   
   for (i=start; i<=end ; i++) {
      sprintf(idxStr, "%d", i);    
      arrayValue = Tcl_GetVar2(interp, argv[1], idxStr, 0);
      if ( arrayValue == NULL ) {
	 Tcl_AppendResult(interp, "No such element in array ", argv[1],
			  "(", idxStr, ")", (char*)NULL);
	 return TCL_ERROR;
      } else if( !strcmp(argv[4],arrayValue) ) {
	 Tcl_SetResult(interp, "1", TCL_STATIC);
	 return TCL_OK;
      } else {
	 ;
      }
   }
   Tcl_SetResult(interp, "0", TCL_STATIC);
   return TCL_OK;
}


int updateFirst( ClientData clientData,
		 Tcl_Interp *interp,
		 int argc,
		 char *const argv[] )
{
   int i, first, newfirst, num, selCount=0;
   char varIndex[80];
   char *tmpPtr;
   char stateVar[20];
   
   if( argc != 4 ) {
      Tcl_SetResult(interp,
		    "updateFirst -r/-c oldFirstRow/Col oldNumRows/Cols",
		    TCL_STATIC);
      return TCL_ERROR;
   }

   if( !strcmp(argv[1], "-r") ) {
      sprintf(stateVar,"_rowState");
   } else if( !strcmp(argv[1], "-c") ) {
      sprintf(stateVar,"_colNotchedState");
   } else {
      Tcl_SetResult(interp, "In updateFirst: unknown option ", TCL_STATIC);
      return TCL_ERROR;
   }
   
   if( TCL_OK != Tcl_GetInt(interp, argv[2], &first) ) {
      return TCL_ERROR;
   }
   if( TCL_OK != Tcl_GetInt(interp, argv[3], &num) ) {
      return TCL_ERROR;
   }
   
   newfirst = num;
   
   for (i=0; i< first-1; i++) {
      sprintf(varIndex, "%d", i);
      tmpPtr = Tcl_GetVar2(interp, stateVar, varIndex, 0);
      if (tmpPtr == NULL) {
	 Tcl_AppendResult(interp, "Array ", stateVar,
			  "(", varIndex, ") does not exist", (char*)NULL);
	 return TCL_ERROR;
      } else if( !strcmp(tmpPtr, "1") ) {
	 selCount ++;
      } else {
	 ;
      }
   }
   
   for (i= first-1; i< num; i++) {
      sprintf(varIndex, "%d", i);
      tmpPtr = Tcl_GetVar2(interp, stateVar, varIndex, 0);    
      if (tmpPtr == NULL) {
	 Tcl_AppendResult(interp, "Array ", stateVar,
			  "(", varIndex, ") does not exist", (char*)NULL);
	 return TCL_ERROR;
      } else if( !strcmp(tmpPtr, "0") ) {
	 newfirst = i - selCount + 1;
	 break;
      } else {
	 selCount ++;
      }     
   }
   
   sprintf(varIndex, "%d", newfirst);
   Tcl_SetResult(interp, varIndex, TCL_VOLATILE);
   return TCL_OK;
}

/* one of the time consuming methods in C */

int Table_calAbsXPos( ClientData clientData,
		      Tcl_Interp *interp,
		      int argc,
		      char *const argv[] )
{
   int nCols, charPix, dc_lmar, dc_width, dc_rightspace, i;
   char index[40], valStr[40];
   char *tmpStr;
   int absXPos, cellPixWidth;
   
   if( argc != 1 ) {
      Tcl_SetResult(interp, "no argv needed", TCL_STATIC);
      return TCL_ERROR;
   }
   
   tmpStr=Tcl_GetVar2(interp,"_DC", "lmar",0);
   if (tmpStr == NULL) {
      Tcl_SetResult(interp, "Cannot read variable _DC(lmar)", TCL_STATIC);
      return TCL_ERROR;
   } else {
      dc_lmar = atoi(tmpStr);
   }

   tmpStr=Tcl_GetVar2(interp,"_DC", "width",0);
   if (tmpStr == NULL) {
      Tcl_SetResult(interp, "Cannot read variable _DC(width)", TCL_STATIC);
      return TCL_ERROR;
   } else {
      dc_width = atoi(tmpStr);
   }

   tmpStr=Tcl_GetVar2(interp,"_DC", "rightspace",0);
   if (tmpStr == NULL) {
      Tcl_SetResult(interp, "Cannot read variable _DC(rightspace)", TCL_STATIC);
      return TCL_ERROR;
   } else {
      dc_rightspace = atoi(tmpStr);
   }

   tmpStr=Tcl_GetVar(interp,"g_charPix",0);
   if (tmpStr == NULL) {
      Tcl_SetResult(interp, "Cannot read variable g_charPix", TCL_STATIC);
      return TCL_ERROR;
   } else {
      charPix = atoi(tmpStr);
   }

   tmpStr=Tcl_GetVar(interp,"_dispCols",0);
   if (tmpStr == NULL) {
      Tcl_SetResult(interp, "Cannot read variable _dispCols", TCL_STATIC);
      return TCL_ERROR;
   } else {
      nCols = atoi(tmpStr);
   }
   
   absXPos = dc_lmar+dc_width+dc_rightspace;
   sprintf(valStr, "%d", absXPos);
   if (NULL==Tcl_SetVar2(interp, "_absXPos_", "0", valStr, 0)) {
      Tcl_SetResult(interp, "failed to set _absXPos", TCL_STATIC);
      return TCL_ERROR;
   }
   
   strcpy(index, "0");
   for (i=0; i< nCols; i++) {
      tmpStr = Tcl_GetVar2(interp, "_cellWidth", index, 0);
      cellPixWidth = charPix*atoi(tmpStr)+8;

      sprintf(valStr, "%d", cellPixWidth);
      Tcl_SetVar2(interp, "_cellPixWidth", index, valStr, 0);

      absXPos += cellPixWidth + dc_rightspace;
      sprintf(index, "%d", i+1);
      sprintf(valStr, "%d", absXPos);
      Tcl_SetVar2(interp, "_absXPos", index, valStr, 0);
   }
   
   return TCL_OK;
}


/* one of the time consuming methods in C */

int Table_updateCell( ClientData clientData,
		      Tcl_Interp *interp,
		      int argc,
		      Tcl_Obj *const argv[] )
{
   int showCols, showRows, firstCol, firstRow, numRows, i, j;
   char *tmpStr;
   char index1[80];
   char index2[80];
   char index3[80];
   int  tmpWidth, imageTable;
   Tcl_Obj *idxObj, *valObj, *overflowObj;
   
   valObj = Tcl_GetVar2Ex(interp, "_firstCol", NULL, 0);
   if (valObj == NULL) {
      Tcl_SetResult(interp, "Cannot get _firstCol", TCL_STATIC);
      return TCL_ERROR;
   } else {
      Tcl_GetIntFromObj(interp, valObj, &firstCol);
   }

   valObj = Tcl_GetVar2Ex(interp, "_firstRow", NULL, 0);
   if (valObj == NULL) {
      Tcl_SetResult(interp, "Cannot get _firstRow", TCL_STATIC);
      return TCL_ERROR;
   } else {
      Tcl_GetIntFromObj(interp, valObj, &firstRow);
   }

   valObj = Tcl_GetVar2Ex(interp, "_showCols", NULL, 0);
   if (valObj == NULL) {
      Tcl_SetResult(interp, "Cannot get _showCols", TCL_STATIC);
      return TCL_ERROR;
   } else {
      Tcl_GetIntFromObj(interp, valObj, &showCols);
   }

   valObj = Tcl_GetVar2Ex(interp, "_showRows", NULL, 0);
   if (valObj == NULL) {
      Tcl_SetResult(interp, "Cannot get _showRows", TCL_STATIC);
      return TCL_ERROR;
   } else {
      Tcl_GetIntFromObj(interp, valObj, &showRows);
   }

   valObj = Tcl_GetVar2Ex(interp, "_numRows", NULL, 0);
   if (valObj == NULL) {
      Tcl_SetResult(interp, "Cannot get _numRows", TCL_STATIC);
      return TCL_ERROR;
   } else {
      Tcl_GetIntFromObj(interp, valObj, &numRows);
   }

   valObj = Tcl_GetVar2Ex(interp, "_tableType", NULL, 0);
   if (valObj == NULL) {
      Tcl_SetResult(interp, "Cannot get _tableType", TCL_STATIC);
      return TCL_ERROR;
   }
   imageTable = ( !strcmp( Tcl_GetStringFromObj(valObj,NULL), "Image") );
   
   if( imageTable )
      firstRow = numRows - (firstRow + showRows - 2);
   
   overflowObj = Tcl_NewStringObj("*",-1);

   for (i=0; i< showCols; i++) {
      sprintf(index2, "%d", (firstCol+i-1));
      valObj = Tcl_GetVar2Ex(interp, "_cellWidth", index2, 0);
      Tcl_GetIntFromObj(interp, valObj, &tmpWidth);

      for (j=0; j < showRows; j++) {

	 sprintf(index3,"%d,%d", (firstCol+i-1), (firstRow+j-1));
	 valObj = Tcl_GetVar2Ex(interp, "_tableData", index3, 0);
	 if (valObj == NULL) {
	    Tcl_SetResult(interp, "Cannot get _tableData: ", TCL_STATIC);
	    Tcl_AppendResult(interp, index3, NULL);
	    return TCL_ERROR;
	 } 

	 /* if it's an image, flip Y */
	 if ( imageTable ) {
	    sprintf(index1, "%d_%d", i, showRows-j-1);
	 } else {
	    sprintf(index1, "%d_%d", i, j);
	 }

	 if ( Tcl_GetCharLength(valObj) > tmpWidth ) {
	    Tcl_SetVar2Ex(interp, "_numEntry", index1,
                          overflowObj, TCL_NAMESPACE_ONLY);
	 } else {
	    Tcl_SetVar2Ex(interp, "_numEntry", index1,
                          valObj, TCL_NAMESPACE_ONLY);
	 }

      }
   }

   return TCL_OK;
}
