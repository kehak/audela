#include "CCatalog.h" 
#include "cstycho.h"
/*
 * main.c
 *
 *  Created on: Dec 13, 2011
 *      Author: S. Vaillant
 */

/**
 * Extract stars from Tycho catalog
 */
listOfStarsTycho* CCatalog::cstycho2 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {


	double raInCatalog;
	double decInCatalog;
	double magnitudeInCatalog;
	char catalogCompleteName[1024];
	char oneLine[256];

	/* Define the search zone */
	searchZoneTycho mySearchZoneTycho = findSearchZoneTycho(ra,dec,radius,magMin,magMax);

	/* Read the catalog */
	sprintf(catalogCompleteName,"%s/%s",pathToCatalog,CATALOG_FILE_NAME_TYCHO);

	FILE* inputStream = fopen(catalogCompleteName,"r");
	if (inputStream  == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Cannot open catalog : %s\n",catalogCompleteName);
		throw FileNotFoundException(outputLogChar);
	}

	elementListTycho* headOfList = NULL;
	elementListTycho* currentElement;

	int lineNumber = 0;
	while(feof(inputStream) == 0) {

		if(fgets(oneLine,sizeof(oneLine),inputStream) == NULL) {
			break;
		}
		lineNumber++;
		oneLine[206] = '\0';

		/* Check if Ra and Dec are provided */
		if(oneLine[13] == 'X') {
			// no mean position
			continue;
		}

		/* Check if V magnitude is provided */
		// 124-130   F6.3,1X  mag     VT        [1.905,15.193]? Tycho-2 VT magnitude (7)
		oneLine[129]       = '\0';
		if(fieldIsBlank(oneLine + 123)) {
			// no V magnitude
			continue;
		}
		magnitudeInCatalog = strtod(oneLine + 123, NULL);

		// 16- 28   F12.8,1X deg     mRAdeg    []? Mean Right Asc, ICRS, epoch J2000 (3)
		oneLine[27]  = '\0';
		raInCatalog  = strtod(oneLine + 15, NULL);

		// 29- 41   F12.8,1X deg     mDEdeg    []? Mean Decl, ICRS, at epoch J2000 (3)
		oneLine[40]  ='\0';
		decInCatalog = strtod(oneLine + 28, NULL);

		if(isGoodStarTycho(raInCatalog, decInCatalog, magnitudeInCatalog, mySearchZoneTycho)) {

			currentElement           = (elementListTycho*)malloc(sizeof(elementListTycho));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (oneStarTycho) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}

			currentElement->theStar.id                        = lineNumber;
			currentElement->theStar.ra                        = raInCatalog;
			currentElement->theStar.dec                       = decInCatalog;

			oneLine[4]                                        = '\0';
			currentElement->theStar.idTycho1                  = strtol(oneLine, NULL, 10);

			oneLine[10]                                       = '\0';
			currentElement->theStar.idTycho2                  = strtol(oneLine + 5, NULL, 10);
			currentElement->theStar.idTycho3                  = oneLine[11];
			currentElement->theStar.pflag                     = oneLine[13];

			oneLine[48]                                       = '\0';
			currentElement->theStar.pmRa                      = strtod(oneLine + 41, NULL);

			oneLine[56]                                       = '\0';
			currentElement->theStar.pmDec                     = strtod(oneLine + 49, NULL);

			oneLine[60]                                       = '\0';
			currentElement->theStar.errorRa                   = strtol(oneLine + 57, NULL, 10);

			oneLine[64]                                       = '\0';
			currentElement->theStar.errorDec                  = strtol(oneLine + 61, NULL, 10);

			oneLine[69]                                       = '\0';
			currentElement->theStar.errorPmRa                 = strtod(oneLine + 65, NULL);

			oneLine[74]                                       = '\0';
			currentElement->theStar.errorPmDec                = strtod(oneLine + 70, NULL);

			oneLine[82]                                       = '\0';
			currentElement->theStar.meanEpochRA               = strtod(oneLine + 75, NULL);

			oneLine[90]                                       = '\0';
			currentElement->theStar.meanEpochDec              = strtod(oneLine + 83, NULL);

			oneLine[93]                                       = '\0';
			currentElement->theStar.numberOfUsedPositions     = strtol(oneLine + 91, NULL,10);

			oneLine[97]                                       = '\0';
			currentElement->theStar.goodnessOfFitRa           = strtod(oneLine + 94, NULL);

			oneLine[101]                                      = '\0';
			currentElement->theStar.goodnessOfFitDec          = strtod(oneLine + 98, NULL);

			oneLine[105]                                      = '\0';
			currentElement->theStar.goodnessOfFitPmRa         = strtod(oneLine + 102, NULL);

			oneLine[109]                                      = '\0';
			currentElement->theStar.goodnessOfFitPmDec        = strtod(oneLine + 106, NULL);

			oneLine[116]                                      = '\0';
			currentElement->theStar.magnitudeB                = strtod(oneLine + 110, NULL);

			currentElement->theStar.magnitudeV                = magnitudeInCatalog;

			oneLine[122]                                      = '\0';
			currentElement->theStar.errorMagnitudeB           = strtod(oneLine + 117, NULL);

			oneLine[135]                                      = '\0';
			currentElement->theStar.errorMagnitudeV           = strtod(oneLine + 130, NULL);

			oneLine[139]                                      = '\0';
			currentElement->theStar.proximityIndicator        = strtol(oneLine + 136, NULL,10);

			currentElement->theStar.isTycho1Star              = oneLine[140];

			currentElement->theStar.componentIdentifierHIP[0] = oneLine[148];
			currentElement->theStar.componentIdentifierHIP[1] = oneLine[149];
			currentElement->theStar.componentIdentifierHIP[2] = oneLine[150];
			currentElement->theStar.componentIdentifierHIP[3] = '\0';
			oneLine[148]                                      = '\0';
			currentElement->theStar.hipparcosId               = strtol(oneLine + 142, NULL,10);
			if(currentElement->theStar.hipparcosId           == 0) {
				currentElement->theStar.hipparcosId           = -1;
			}

			oneLine[164]                                      = '\0';
			currentElement->theStar.observedRa                = strtod(oneLine + 152, NULL);

			oneLine[177]                                      = '\0';
			currentElement->theStar.observedDec               = strtod(oneLine + 165, NULL);

			oneLine[182]                                      = '\0';
			currentElement->theStar.epoch1990Ra               = strtod(oneLine + 178, NULL);

			oneLine[187]                                      = '\0';
			currentElement->theStar.epoch1990Dec              = strtod(oneLine + 183, NULL);

			oneLine[193]                                      = '\0';
			currentElement->theStar.errorObservedRa           = strtod(oneLine + 188, NULL);

			oneLine[199]                                      = '\0';
			currentElement->theStar.errorObservedDec          = strtod(oneLine + 194, NULL);

			currentElement->theStar.solutionType              = oneLine[200];

			currentElement->theStar.correlationRaDec          = strtod(oneLine + 202, NULL);

			currentElement->nextStar                          = headOfList;
			headOfList                                        = currentElement;
		}
	}

	/* Close the catalog file */
	fclose(inputStream);

	listOfStarsTycho* theStars         = headOfList;

	return (theStars);
}

bool fieldIsBlank(char* p) {
	while (*p == ' ') p++;
	return (*p == '\0');
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 */
searchZoneTycho findSearchZoneTycho(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneTycho mySearchZoneTycho;

	fillSearchZoneRaDecDeg(mySearchZoneTycho.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneTycho.magnitudeBox, magMin, magMax);

	return (mySearchZoneTycho);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarTycho(const double raInCatalog, const double decInCatalog, double magnitudeInCatalog, const searchZoneTycho& mySearchZoneTycho) {

	const searchZoneRaDecDeg subSearchZone  = mySearchZoneTycho.subSearchZone;
	const magnitudeBoxMag magnitudeBox      = mySearchZoneTycho.magnitudeBox;

	if(
			((subSearchZone.isArroundZeroRa && ((raInCatalog >= subSearchZone.raStartInDeg) || (raInCatalog <= subSearchZone.raEndInDeg))) ||
					(!subSearchZone.isArroundZeroRa && ((raInCatalog >= subSearchZone.raStartInDeg) && (raInCatalog <= subSearchZone.raEndInDeg)))) &&
					(decInCatalog >= subSearchZone.decStartInDeg) &&
					(decInCatalog <= subSearchZone.decEndInDeg) &&
					(magnitudeInCatalog >= magnitudeBox.magnitudeStartInMag) &&
					(magnitudeInCatalog <= magnitudeBox.magnitudeEndInMag)) {

		return(true);
	}

	return (false);
}

void CCatalog::releaseListOfStarTycho(listOfStarsTycho* listOfStars) {

	elementListTycho* currentElement = listOfStars;
	elementListTycho* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
