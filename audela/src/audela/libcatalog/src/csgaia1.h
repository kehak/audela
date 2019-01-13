/*
 * csgaia1.h
 *
 *  Created on: Oct 19, 2016
 *      Author: Y. Damerdji
 */

#ifndef CSGAIA1_H_
#define CSGAIA1_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

#define GAIA1_CATALOG_FORMAT     "%sdat/Gaia1_%04d.bin"
#define GAIA1_INDEX_FORMAT       "%sdat/Gaia1.index"

#define GAIA1_BINARY_STEP_DEC 0.1
#define GAIA1_BINARY_STEP_RA  0.1
#define GAIA1_BINARY_NUMBER_DEC_ZONES 1800
#define GAIA1_BINARY_NUMBER_RA_ZONES  3600
#define GAIA_INDEX_LINE_FORMAT       "%d %d %d %d %d"

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag  magnitudeBox;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZoneGaia1;

typedef struct {
	int numberOfStarsInZone;
	int numberOfAllStarsBefore;
} indexTableGaia1;

/* Function prototypes */
searchZoneGaia1 findSearchZoneGaia1(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax);
bool isGoodStarGaia1(const double raInCatalog, const double decInCatalog, double magnitudeInCatalog, const searchZoneGaia1& mySearchZoneGAIA);
bool isGoodStarBinaryGaia1(const starGaia1& theStar, const searchZoneGaia1& mySearchZoneGaia1);
indexTableGaia1** readIndexFileGaia1(const char* const pathOfCatalog, const searchZoneGaia1& mySearchZoneGaia1, int& maximumNumberOfStarsPerZone);
void processOneZoneGaia1(FILE* const inputStream,const indexTableGaia1& oneAccFile,elementListGaia1** headOfList,starGaia1* const redStars,
		const searchZoneGaia1& mySearchZoneGAIA);

#endif /* CSGAIA1_H_ */
