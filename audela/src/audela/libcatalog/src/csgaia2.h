/*
 * csgaia1.h
 *
 *  Created on: Sep 6, 2018
 *      Author: Y. Damerdji
 */

#ifndef CSGAIA2_H_
#define CSGAIA2_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

#define GAIA2_CATALOG_FORMAT "%sdat/Gaia2_%04d.bin"
#define GAIA2_STAR_INDEX     "%sdat/Gaia2.index"
#define GAIA2_VRAD_CATALOG   "%sdat/Gaia2Vrad.bin"
#define GAIA2_VRAD_INDEX     "%sdat/Gaia2Vrad.index"

#define GAIA2_BINARY_STEP_DEC 0.1
#define GAIA2_BINARY_STEP_RA  0.1
#define GAIA2_BINARY_NUMBER_DEC_ZONES 1800
#define GAIA2_BINARY_NUMBER_RA_ZONES  3600

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag  magnitudeBox;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZoneGaia2;

typedef struct {
	long long sourceId;
	double vRad;
	float vRadError;
	float templateTeff;
	float templateLogg;
	float templateFeH;
} vradGaia2;

typedef struct {
	int numberOfStarsInZone;
	int numberOfAllStarsBefore;
} indexTableGaia2;

/* Function prototypes */
searchZoneGaia2 findSearchZoneGaia2(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax);
bool isGoodStarGaia2(const double raInCatalog, const double decInCatalog, double magnitudeInCatalog, const searchZoneGaia2& mySearchZoneGAIA);
bool isGoodStarBinaryGaia2(const starGaia2& theStar, const searchZoneGaia2& mySearchZoneGaia2);
indexTableGaia2** readIndexFileGaia2(const char* const pathOfCatalog, const char* const formatCatalog, const searchZoneGaia2& mySearchZoneGaia2, int& maximumNumberOfStarsPerZone);
void processOneZoneGaia2(FILE* const inputStream,FILE* const inputStreamVrad,const indexTableGaia2& oneAccFile,
		const indexTableGaia2& oneAccFileVrad, elementListGaia2** headOfList,starGaia2* const redStars, vradGaia2* const redStarsVrad,
		const searchZoneGaia2& mySearchZoneGAIA);
int findCorrespondingVrad(const vradGaia2* const redStarsVrad,const int numberOfStars,
		const long long sourceId);

#endif /* CSGAIA2_H_ */
