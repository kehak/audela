/*
 * fitsTclInt.h -
 *
 *      This header file contains the definitions, structures, and
 *      function prototypes for fitsTcl's internal use.
 */

/*
 *-----------------------------------------------------------------
 * MODIFICATION HISTORY
 *        2004-02-06 Ziqin Pan
 *            1. Add long rowindex to colData structure
 *
 *----------------------------------------------------------------
 */

#ifndef FITSTCLINT
#define FITSTCLINT

#ifndef macintosh
#include <sys/types.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <ctype.h>
#include <math.h>
#include <string.h>

#ifdef HAVE_ALLOCA_H
#include <alloca.h>
#endif

#include "fitsTcl.h"
#include "fitsio2.h"

#define FITS_COLMAX 999
#define FITS_MAXDIMS 15
#define FITS_MAXRANGE 30
#define FITS_CHUNKSIZE 100

#define BYTE_DATA     0
#define SHORTINT_DATA 1
#define INT_DATA      2
#define FLOAT_DATA    3
#define DOUBLE_DATA   4
#define LONGLONG_DATA 5

#define NOHDU      -1

typedef struct {
   int    numCols;
   long   numRows;
   long   rowLen;
   char   **colName;
   char   **colType;
   int    *colDataType;
   char   **colUnit;
   char   **colDisp;
   char   **colNull;
   long   *vecSize;
   double *colTzero;
   double *colTscale;
   int    *colTzflag;
   int    *colTsflag;
   int    *strSize;
   int    loadStatus;
   int    *colWidth;
   char   **colFormat;
   double *colMin;
   double *colMax;
} TableHDUInfo;

typedef struct {
   int    bitpix;
   int    naxes;
   long   *naxisn;
   char   **axisUnit;
   double bscale;
   double bzero;
   long   bsflag;
   long   bzflag;
   char   blank[80];
   int    dataType;
} ImageHDUInfo;

typedef union {
   TableHDUInfo table;
   ImageHDUInfo image;
} HDUInfo;

typedef struct {
   char name[FLEN_KEYWORD];
   char value[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   int pos;
} Keyword;

typedef struct FitsCardStruct{
   int pos;
   char value[FLEN_CARD];
   struct FitsCardStruct * next;
} FitsCardList;

typedef struct {
   Tcl_Interp *interp;
   fitsfile *fptr;
   int fileNum;
   char* fileName;
   char* handleName;
   int rwmode;
   int chdu;
   int hduType;
   char extname[FLEN_VALUE];
   int numKwds;
   int numHis;
   int numCom;
   Tcl_HashTable *kwds;
   FitsCardList *hisHead;
   FitsCardList *comHead;
   HDUInfo CHDUInfo;
} FitsFD;


typedef struct {
   LONGLONG longlongData;
   double dblData;
   long   intData;
   char   *strData;
   char   flag;
   long   rowindex;
   unsigned char *colBuffer;
} colData;

typedef struct {
   double min;
   double max;
   double mean;
   long fmin;
   long fmax;
   double stdiv;
   long numData;
} colStat;

/*
 * These are the function Prototypes:
 */

EXTERN void fitsCloseFile (ClientData clientData);

EXTERN void dumpFitsErrStackToDString( Tcl_DString *stack, int status );
EXTERN void dumpFitsErrStack         ( Tcl_Interp *interp, int status );

EXTERN int  fitsMoveHDU (FitsFD *curFile, int nmove, 
			 int direction);

EXTERN int  FitsCreateObject (Tcl_Interp *interp, 
			      int argc, Tcl_Obj *const argv[]);

EXTERN int  FitsInfo (Tcl_Interp *interp, 
		      int argc, Tcl_Obj *const argv[]);

EXTERN int  fitsLoadKwds (FitsFD *curFile);

EXTERN int  fitsLoadHDU (FitsFD *curFile);

EXTERN int  fitsMakeRegExp (Tcl_Interp *interp,
			    int argc, char *const argv[], 
			    Tcl_DString *concatList, 
			    int caseSen );

EXTERN int fitsDumpHeader (FitsFD *curFile);

EXTERN int fitsParseRangeNum (char* rangeStr);
EXTERN int fitsParseRange (char* rangeStr, int *numInt,
			   int *range,
			   int maxInt,
			   int minval, int maxval,
			   char *errMsg);

EXTERN void *makeContigArray (int nrows, int ncols, char type);

EXTERN int freeCHDUInfo (FitsFD * curFile);

EXTERN int makeNewCHDUInfo (FitsFD * curFile, int newHduType);

EXTERN int tableBlockLoad ( FitsFD * curFile,
			    char *varName,
			    int felem,
			    int fRow,				 
			    int nRows,
			    int fCol,
			    int nCols,
			    int colNums[],
                            int format);

EXTERN int freeDataPtr (FitsFD * curFile, char ptrAddress[]);

EXTERN int tableGetToPtr (FitsFD * curFile,
			  long colNum,
			  char *nulStr,
			  long firstelem);

EXTERN int tableRowGetToPtr (FitsFD * curFile,
                             long rowNum,
                             long colNum,
                             long vecSize,
                             char *nulStr,
                             long firstelem);

EXTERN int vtableGetToPtr (FitsFD *curFile, 
			   long colNum,
                           char *nulStr);

EXTERN void deleteFitsCardList ( FitsCardList *comCard);

EXTERN int fitsTransColList (FitsFD     *curFile,
			     char       *colStr,
			     int        *numCols,
			     int       colNums[],
			     int       colTypes[],
			     int       strSize[]);


EXTERN int fitsFlushKeywords (FitsFD *curFile);

EXTERN int strToUpper (char *inStr,
		       char **outStr);

EXTERN int fitsInsertKwds (FitsFD *curFile,
			   int index,
			   char *inCard,
			   int ifFormat);

EXTERN int fitsPutKwds (FitsFD *curFile,
			int nkey,
			char *inCard,
			int ifFormat);

EXTERN int fitsPutHisKwd ( FitsFD *curFile,
			   char *his);

EXTERN int fitsDeleteKwds (FitsFD *curFile,
			   char *keyList);

EXTERN int fitsDeleteCols (FitsFD *curFile,
			   int *colList,
			   int numCols);

EXTERN int fitsDeleteRows (FitsFD *curFile,
			   int firstRow,
			   int numRows);

EXTERN int fitsDeleteCHdu (FitsFD *curFile);

EXTERN int tdispGetFormat (FitsFD *curFile, int colnum);

EXTERN int saveTableToAscii (FitsFD *curFile,
			     char *filename,
			     char *fileStatus,
			     int felem,
			     int fRow,
			     int nRows,
			     int nCols,
			     int colTypes[],
			     int colNums[],
			     int strSize[],
			     int   ifFixedFormat,
			     int   ifCSV,
			     int   ifPrintRow,
			     char  *sepString);

EXTERN int saveImageToAscii( FitsFD *curFile,    
			     char *filename,
			     char *fileStatus,
			     int  fRow,
			     int  nRows,
			     int fCol,
			     int nCols,
			     int cellSize,
			     int ifCSV,
			     int ifPrintRow,
			     char *sepString,
			     long slice );

EXTERN int saveVectorTableToAscii( FitsFD *curFile,
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
				   int ifVariableVec);

EXTERN int varSaveToTable (FitsFD *curFile,
			   int     colNum,
			   long    firstRow,
			   long    firstElem,
			   long    numRows,
                           long    numElem,
			   Tcl_Obj **listArray);

EXTERN int varSaveToImage (FitsFD *curFile,
			   long    firstElem,
			   long    numElem,
			   Tcl_Obj **listArray);

EXTERN int addColToTable (FitsFD *curFile,
			  int     colNum,
			  char   *ttype,
			  char   *tform);

EXTERN int addRowToTable (FitsFD *curFile,
			  int     rowNum,
			  int     nRows);

EXTERN int fitsCopyCHduToFile (FitsFD *curFile,
			       char *newfilename);


EXTERN void fitsQSsetFlag (colData a[],
			   int dataType,
			   int strSize,
			   int fst,
			   int lst);

EXTERN void fitsQuickSort (colData a[],
			   int dataType,
			   int strSize,
			   int fst,
			   int lst,
			   int isAscend);
/*
EXTERN int fitsSplit (colData a[],
		      int dataType,
		      int strSize,
		      int f,
		      int l,
		      int isAscend);
*/
EXTERN int fitsSplit (colData a[],
		      int dataType,
		      int strSize,
		      int f,
		      int l,
		      int isAscend,
                      int * sp1,
                      int * sp2);

EXTERN void fitsSwap (colData *p,
		      colData *q);

EXTERN int fitsUpdateFile (FitsFD *curFile);

EXTERN void fitsGetSortRange (colData a[],
			      long n,
			      long *t,
			      long *b);

EXTERN void fitsGetSortRangeNum (colData a[],
				 long n,
				 long *nr);

EXTERN int fitsWriteRowsToFile (FitsFD *curFile, 
				long rowSize, 
				colData columndata[],
				int isMerge); 

EXTERN int fitsCalculateColumn (FitsFD *curFile,
				char *colName,
				char *colForm,
				char *expr);
EXTERN int fitsCalculaterngColumn ( FitsFD *curFile,
				char *colName,
				char *colForm,
			        char *expr,
                                int  numrange,
                                int  range[][2]);

EXTERN int fitsDeleteRowsExpr (FitsFD *curFile,
			       char *expr);

EXTERN int exprGetInfo ( FitsFD *curFile,
			 char *expr );

EXTERN int exprGetToPtr ( FitsFD *curFile,
			  char *expr,
			  char *nulStr,
                          int  numrange,
                          int  range[][2]);

EXTERN int fitsColumnGetToArray ( FitsFD *curFile,
				  int    colNum,
				  int    felem,
				  long   fRow,
				  long   lRow, 
				  double *array,
				  char   *flagArray);

EXTERN int fitsJustMoveHDU ( FitsFD *curFile,
			     int    nmove,
			     int    direction);

EXTERN int fitsUpdateCHDU( FitsFD *curFile, int newHduType);

EXTERN int fitsDumpHeaderToKV  ( FitsFD *curFile );
EXTERN int fitsDumpHeaderToCard( FitsFD *curFile );
EXTERN int fitsDumpKwdsToList  ( FitsFD *curFile );

EXTERN int imageRowsMeanToPtr( FitsFD *curFile,
			       long fRow,
			       long lRow,
			       long slice );

EXTERN int imageColsMeanToPtr( FitsFD *curFile,
			       long fCol,
			       long lCol,
			       long slice );

EXTERN int imageBlockLoad_1D( FitsFD *curFile,
			      long fElem,
			      long nElem );

EXTERN int imageBlockLoad( FitsFD *curFile,
			   char *varName,
			   long fRow,
			   long nRow,
			   long fCol,
			   long nCol,
			   long slice,
                           long cslice);

EXTERN int imageGetToPtr( FitsFD *curFile,
			  long slice,
			  int  rotate );

EXTERN int fitsPutReqKwds( FitsFD *curFile,
			   int isPrImg,
			   int hduType,
			   int argc,
			   char *const argv[] );

EXTERN int fitsAppendCHduToFile( FitsFD *curFile,
				 char *targetfilename );

EXTERN int fitsGetWcsMatrix( FitsFD *curFile,
                             int nDims,
                             int cols[],
                             char dest );

EXTERN int fitsFileGetWcsMatrix( FitsFD *curFile,
                                 fitsfile *dummyFile,
                                 int nDims,
                                 int cols[],
                                 char dest, Tcl_Obj *data[]);

EXTERN int fitsGetWcsPair( FitsFD *curFile,
                           int Col1,
                           int Col2,
                           char dest );

EXTERN int fitsTableGetWcsOld( FitsFD *curFile,
			       int RAColNum,
			       int DecColNum );

EXTERN int fitsReadColData( FitsFD *curFile,
			    int colNum,
			    int strSize,
			    colData columndata[],
			    int *dataType );

EXTERN int fitsReadRawColData( FitsFD *curFile,
			       colData columndata[],
			       LONGLONG *rowSize );

EXTERN int fitsSortTable( FitsFD *curFile,
			  int numCols,
			  int *colNum,
			  int *strSize,
			  int *isAscend,
			  int isMerge );

EXTERN int fitsColumnStatistics( FitsFD *curFile,
				 int colNum,
				 int felem,
				 int numrange,
				 int range[][2] );

EXTERN int fitsColumnMinMax( FitsFD *curFile,
			     int colNum,
			     int felem,
			     int numrange,
			     int range[][2] );

EXTERN int fitsColumnMinMaxToPtr( FitsFD *curFile,
				  int colNum,
				  int felem,
				  int fRow,
				  int lRow,
				  double *min,
				  double *max );

EXTERN int fitsColumnStatToPtr( FitsFD *curFile,
				int colNum,
				int felem,
				int numrange,
				int range[][2],
				colStat *colstat,
				int statFlag );

EXTERN void fitsRandomizeColData( colData columndata[], long numRows );
EXTERN void fitsFreeRawColData  ( colData columndata[], long numRows );

EXTERN Tcl_Obj *fitsTcl_Ptr2Lst( Tcl_Interp *interp, void *thePtr, char *undef,
				 int dataType, long nelem );

EXTERN void *fitsTcl_Lst2Ptr( Tcl_Interp *interp, Tcl_Obj *dataLst,
			      int dataType, long *nelem, char **undef );

EXTERN int fitsTcl_SetDims( Tcl_Interp *interp, Tcl_Obj **dimObj,
			    int naxis, long naxes[] );

EXTERN int fitsTcl_GetDims( Tcl_Interp *interp, Tcl_Obj *dimObj,
			    long *nelem, int *naxis, long naxes[] );

EXTERN void *fitsTcl_ReadPtrStr( Tcl_Obj *ptrObj );

/* Feb 18, 2004, Ziqin Pan add to support row selection */

EXTERN int fitsDeleteRowlist(FitsFD *curFile,long* rowlist,int numRows );

EXTERN int fitsDeleteRowsRange( FitsFD *curFile,char * rangelist);

EXTERN int fitsCalculaterngColumn( FitsFD *curFile,char *colName,char *colForm, char *expr, int numrange, 
           int range[][2] );

EXTERN int fitsSelectRowsExpr (FitsFD *curFile,char *expr,long firstrow,long nrows,
           long * n_good_rows,char * row_status);

EXTERN LONGLONG fitsTcl_atoll (char *inputStr);

/**********************************
 *    fitsTcl command handlers    *
 **********************************/

int fitsTcl_close   ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_move    ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_dump    ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_info    ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_get     ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_put     ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_insert  ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_delete  ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_select  ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_load    ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_free    ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_flush   ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_copy    ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_sascii  ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_sort    ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_add     ( FitsFD *curFile, int argc, char *const argv[] );
int fitsTcl_append  ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_histo   ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_create  ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_smooth  ( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );
int fitsTcl_checksum( FitsFD *curFile, int argc, Tcl_Obj *const argv[] );


#define FITS_MAX_OPEN_FILES  NIOBUF        /*  Set by CFITSIO  */

/*
 * This is the list of open Fits Files...
 */

EXTERN FitsFD FitsOpenFiles[FITS_MAX_OPEN_FILES];

typedef struct {
   int    wcsSwap;
} fitsTclOptions;

EXTERN fitsTclOptions userOptions;

#endif
