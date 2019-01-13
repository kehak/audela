/*
 * csusno.h
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

#ifndef CSUSNO_H_
#define CSUSNO_H_

#include "libcatalog.h"
#include "useful.h"

/* Number of ACC and CAT files*/
#define NUMBER_OF_CATALOG_FILES_USNO            24
/* Extensions and format */
#define DOT_ACC_EXTENSION                       ".ACC"
#define DOT_CAT_EXTENSION                       ".CAT"
#define CATALOG_NAME_FORMAT                     "ZONE%04d"
#define CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE      7.5
#define CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE 75
#define ACC_FILE_NUMBER_OF_LINES                96
#define ACC_FILE_RA_ZONE_WIDTH_IN_HOUR          0.25
#define ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE        3.75
/* Format of the ACC file */
#ifdef _WIN32 /* For win32 and win64 */
#define FORMAT_ACC "%lf %ld %ld"
#else
#define FORMAT_ACC "%lf %d %d"
#endif

/* USNO2A ACC files */
typedef struct {
	unsigned int* arrayOfPosition;
	unsigned int* numberOfStars;
} indexTableUsno;

typedef struct {
	searchZoneRaSpdCas subSearchZone;
	magnitudeBoxDeciMag magnitudeBox;
	int    indexOfFirstDistanceToPoleZone;
	int    indexOfLastDistanceToPoleZone;
	int    indexOfFirstRightAscensionZone;
	int    indexOfLastRightAscensionZone;
} searchZoneUsnoa2;

typedef struct {
	int ra;
	int spd;
	int mags;
} starUsnoRaw;

searchZoneUsnoa2 findSearchZoneUsnoa2(const double ra,const double dec,const double radius,const double magMin, const double magMax);
indexTableUsno* readIndexFileUsno(const char* const pathOfCatalog, const searchZoneUsnoa2& mySearchZoneUsnoa2, int& maximumNumberOfStarsPerZone);
void freeAllUsnoCatalogFiles(const indexTableUsno* const allAccFiles,const searchZoneUsnoa2& mySearchZoneUsnoa2);
double usnoa2GetUsnoBleueMagnitudeInDeciMag(const int magL);
double usnoa2GetUsnoRedMagnitudeInDeciMag(const int magL);
int usnoa2GetUsnoSign(const int magL);
int usnoa2GetUsnoQflag(const int magL);
int usnoa2GetUsnoField(const int magL);
void processOneZoneUsnoNotCentredOnZeroRA(FILE* const inputStream,const indexTableUsno& oneAccFile,
		elementListUsnoa2** headOfList, starUsnoRaw* readStars,const searchZoneUsnoa2& mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA);
void processOneZoneUsnoCentredOnZeroRA(FILE* const inputStream,const indexTableUsno& oneAccFile,
		elementListUsnoa2** headOfList, starUsnoRaw* const readStars,const searchZoneUsnoa2& mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA);

#endif /* CSUSNO_H_ */

