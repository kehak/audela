/*
 * main.h
 *
 *  Created on: Dec 13, 2011
 *      Author: S. Vaillant
 */

#ifndef CSLONEOS_H_
#define CSLONEOS_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

#define LONEOS_STRING_COMMON_LENGTH      1024
#define LONEOS_DEC_ZONE_WIDTH            5.
#define LONEOS_RA_ZONE_WIDTH             5.
#define INDEX_TABLE_DEC_DIMENSION_LONEOS 36
#define INDEX_TABLE_RA_DIMENSION_LONEOS  72
#define LONEOS_INDEX_FORMAT              "%2d %2d %5d %5d\n"
#define LONEOS_INDEX_FILENAME            "index.txt"
#define LONEOS_CATALOG_FILENAME          "catalog.bin"

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag  magnitudeBox;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZoneLoneos;

/* Function prototypes */
searchZoneLoneos findSearchZoneLoneos(const double ra,const double dec,const double radius,const double magMin, const double magMax);
int** readIndexFileLoneos(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone);
void processOneZoneLoneos(FILE* const inputStream,const int* const numberOfStarsPerZone,
		elementListLoneos** headOfList, starLoneos* readStars,const searchZoneLoneos& mySearchZoneLoneos,
		const int indexOfDecZone, const int indexOfRA);
bool isGoodStarLoneos(const starLoneos& theStar, const searchZoneLoneos& mySearchZoneLoneos);
#endif /* CSLONEOS_H_ */
