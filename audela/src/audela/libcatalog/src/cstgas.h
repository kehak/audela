/*
 * cstagas.h
 *
 *  Created on: Oct 16, 2016
 *      Author: Y. Damerdji
 */

#ifndef CSTGAS_H_
#define CSTGAS_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

#define TGAS_CATALOGX_FILENAME       "TGAS.bin"
#define TGAS_INDEX_FILENAME          "TGAS.index"

#define TGAS_BINARY_STEP_DEC 1.
#define TGAS_BINARY_STEP_RA  2.
#define TGAS_BINARY_NUMBER_DEC_ZONES 180
#define TGAS_BINARY_NUMBER_RA_ZONES  180
#define TGAS_INDEX_LINE_FORMAT       "%d %d %d %d"

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag  magnitudeBox;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZoneTGAS;

typedef struct {
	unsigned int numberOfStarsInZone;
	int numberOfAllStarsBefore;
} indexTableTGAS;

/* Function prototypes */
searchZoneTGAS findSearchZoneTGAS(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax);
bool isGoodStarTGAS(const double raInCatalog, const double decInCatalog, double magnitudeInCatalog, const searchZoneTGAS& mySearchZoneTGAS);
bool isGoodStarBinaryTGAS(const starTGAS& theStar, const searchZoneTGAS& mySearchZoneTGAS);
indexTableTGAS** readIndexFileTGAS(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone);
void processOneZoneTGAS(FILE* const inputStream,const indexTableTGAS& oneAccFile,elementListTGAS** headOfList,starTGAS* const redStars,
		const searchZoneTGAS& mySearchZoneTGAS);

#endif /* CSTGAS_H_ */
