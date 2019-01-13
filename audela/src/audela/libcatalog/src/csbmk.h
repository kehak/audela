/*
 * csbmk.h
 *
 *  Created on: Jul 05, 2015
 *      Author: Y. Damerdji
 */

#ifndef CSBMK_H_
#define CSBMK_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

#define STRING_COMMON_LENGTH            1024
#define BINARY_CATALOG_FILE_NAME_BMK    "catalog.bin"
#define INDEX_FILE_NAME_BMK             "index.txt"
#define INDEX_TABLE_DEC_DIMENSION_BMK   180
#define INDEX_TABLE_RA_DIMENSION_BMK    180
#define FORMAT_INDEX_FILE_BMK           "%d %d %d %d"
#define BMK_DEC_ZONE_WIDTH              1.
#define BMK_RA_ZONE_WIDTH               2.

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag  magnitudeBox;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZoneBinaryBmk;

typedef struct {
	unsigned int numberOfStarsInZone;
	int idOfFirstStarInZone;
} indexTableBmk;

/* Function prototypes */
searchZoneBinaryBmk findSearchZoneBinaryBmk(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax);
bool isGoodStarBinaryBmk(const starBmk& theStar, const searchZoneBinaryBmk& mySearchZoneTycho);
indexTableBmk** readIndexFileBmk(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone);
void processOneZoneBmk(FILE* const inputStream,const indexTableBmk* const oneAccFile,elementListBmk** headOfList,starBmk* const redStars,
		const searchZoneBinaryBmk& mySearchZoneTycho, const int indexOfRa);
#endif /* CSBMK_H_ */
