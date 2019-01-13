/*
 * main.h
 *
 *  Created on: Dec 13, 2011
 *      Author: S. Vaillant
 */

#ifndef CSTYCHO_H_
#define CSTYCHO_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

#define STRING_COMMON_LENGTH            1024
#define CATALOG_FILE_NAME_TYCHO         "catalog.dat"
#define BINARY_CATALOG_FILE_NAME_TYCHO  "catalog.bin"
#define INDEX_FILE_NAME_TYCHO           "index.txt"
#define INDEX_TABLE_DEC_DIMENSION_TYCHO 180
#define INDEX_TABLE_RA_DIMENSION_TYCHO  180
#define FORMAT_INDEX_FILE_TYCHO         "%d %d %d %d"
#define TYCHO_DEC_ZONE_WIDTH            1.
#define TYCHO_RA_ZONE_WIDTH             2.

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag  magnitudeBox;
} searchZoneTycho;

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag  magnitudeBox;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZoneBinaryTycho;

typedef struct {
	unsigned int numberOfStarsInZone;
	int idOfFirstStarInZone;
} indexTableTycho;

/* Function prototypes */
searchZoneTycho findSearchZoneTycho(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax);
searchZoneBinaryTycho findSearchZoneBinaryTycho(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax);
bool fieldIsBlank(char* p);
bool isGoodStarTycho(const double raInCatalog, const double decInCatalog, double magnitudeInCatalog, const searchZoneTycho& mySearchZoneTycho);
bool isGoodStarBinaryTycho(const starTycho& theStar, const searchZoneBinaryTycho& mySearchZoneTycho);
indexTableTycho** readIndexFileTycho(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone);
void processOneZoneTycho(FILE* const inputStream,const indexTableTycho& oneAccFile,elementListTycho** headOfList,starTycho* const redStars,
		const searchZoneBinaryTycho& mySearchZoneTycho);
#endif /* CSTYCHO_H_ */
