/*
 * cs2mass.h
 *
 *  Created on: Nov 05, 2012
 *      Author: Y. Damerdji
 */

#ifndef CS2MASS_H_
#define CS2MASS_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

/* Number of ACC and CAT files*/
#define NUMBER_OF_CATALOG_FILES_2MASS                1800
#define HALF_NUMBER_OF_CATALOG_FILES_2MASS           900
#define HALF_NUMBER_OF_CATALOG_FILES_2MASS_MINUS_ONE 899

/* Extensions and format */
#define DOT_ACC_EXTENSION                       ".acc"
#define DOT_CAT_EXTENSION                       ".ast"
#define CATALOG_NAME_FORMAT                     "%c%03dTMASS"
#define SOUTH_HEMISPHERE_PREFIX                 'm'
#define NORTH_HEMISPHERE_PREFIX                 'p'
#define OUTPUT_ID_FORMAT                        "%02d%02d%04d%c%02d%02d%03d"
#define CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE 0.1
#define ACC_FILE_NUMBER_OF_LINES                360
#define ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE        1.

/* Number of stars in zones m000TMASS.acc and p899TMASS.acc : the accelerator files are empty ! */
#define NUMBER_OF_STARS_IN_M000                 322157
#define NUMBER_OF_STARS_IN_P899                 167

/* Format of the ACC file */
#define FORMAT_ACC "%d < RA =< %d %d %d %d"

/* 2MASS ACC files */
typedef struct {
	unsigned int* numberOfStarsInZone;
	unsigned int* idOfFirstStarInZone;
	int           indexOfCatalog;
	char          prefix;
} indexTable2Mass;

typedef struct {
	searchZoneRaDecMicroDeg subSearchZone;
	magnitudeBoxMilliMag  magnitudeBox;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZone2Mass;

/* Raw structures are read herein,  so the following structure  */
/* must be packed on byte boundaries:                           */
#pragma pack( 1)
typedef struct {
	int   raInMicroDegree;
	int   decInMicroDegree;
	short errorOnCoordinates;
	short jMagInMilliMag;
	char  jErrorMagInCentiMag;
	short hMagInMilliMag;
	char  hErrorMagInCentiMag;
	short kMagInMilliMag;
	char  kErrorMagInCentiMag;
	int   jd;
} star2MassRaw;


#pragma pack( )

/* Function prototypes for 2MASS */
const searchZone2Mass findSearchZone2Mass(const double ra,const double dec,const double radius,const double magMin, const double magMax);
indexTable2Mass* readIndexFile2Mass(const char* const pathOfCatalog, const searchZone2Mass& mySearchZone2Mass, int& maximumNumberOfStarsPerZone);
void freeAll2MassCatalogFiles(const indexTable2Mass* const allAccFiles, const searchZone2Mass& mySearchZone);
void processOneZone2MassNotCentredOnZeroRA(FILE* const inputStream,const indexTable2Mass& oneAccFile,elementList2Mass** headOfList,star2MassRaw* const redStars,
		const searchZone2Mass& mySearchZone2Mass, const int indexOfRA);
void processOneZone2MassCentredOnZeroRA(FILE* const inputStream,const indexTable2Mass& oneAccFile,elementList2Mass** headOfList,star2MassRaw* const redStars,
		const searchZone2Mass& mySearchZone2Mass, const int indexOfRA);
star2Mass convertStar2Mass(const star2MassRaw& theStar2Mass);
#endif /* CS2MASS_H_ */

