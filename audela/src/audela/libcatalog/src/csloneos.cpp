#include "CCatalog.h" 
#include "csloneos.h"
/*
 * csloneos.cpp
 *
 *  Created on: Jan 26, 2016
 *      Author: Y. Damerdji
 */

/**
 * Extract stars from Loneos catalog
 */
listOfStarsLoneos* CCatalog::csloneos (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int maximumNumberOfStarsPerZone;
	int indexOfRA;
	int indexOfDecZone;
	char fileName[1024];
	FILE* inputStream;

	/* Define search zone */
	const searchZoneLoneos& mySearchZoneLoneos = findSearchZoneLoneos(ra,dec,radius,magMin,magMax);

	/* Read all catalog files to be able to deliver an ID for each star */
	int** numberOfStarsperZone                 = readIndexFileLoneos(pathToCatalog,maximumNumberOfStarsPerZone);

	if(maximumNumberOfStarsPerZone <= 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"maximumNumberOfStarsPerZone = %d should be > 0\n",maximumNumberOfStarsPerZone);
		throw InvalidDataException(outputLogChar);
	}

	/* Allocate memory for an array in which we put the read stars */
	starLoneos* readStars = (starLoneos*)malloc(maximumNumberOfStarsPerZone * sizeof(starLoneos));

	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (starLoneos) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Open the binary file */
	sprintf(fileName,"%s%s",pathToCatalog,LONEOS_CATALOG_FILENAME);

	inputStream = fopen(fileName,"rb");
	if(inputStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"%s not found\n",fileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	elementListLoneos* headOfList = NULL;

	for(indexOfDecZone = mySearchZoneLoneos.indexOfFirstDecZone; indexOfDecZone <= mySearchZoneLoneos.indexOfFirstDecZone; indexOfDecZone++) {

		if(mySearchZoneLoneos.subSearchZone.isArroundZeroRa) {

			for(indexOfRA = mySearchZoneLoneos.indexOfFirstRightAscensionZone; indexOfRA < INDEX_TABLE_RA_DIMENSION_LONEOS; indexOfRA++) {

				processOneZoneLoneos(inputStream,numberOfStarsperZone[indexOfDecZone],
						&headOfList,readStars,mySearchZoneLoneos,indexOfDecZone,indexOfRA);
			}

			for(indexOfRA = 0; indexOfRA <= mySearchZoneLoneos.indexOfLastRightAscensionZone; indexOfRA++) {

				processOneZoneLoneos(inputStream,numberOfStarsperZone[indexOfDecZone],
						&headOfList,readStars,mySearchZoneLoneos,indexOfDecZone,indexOfRA);
			}

		} else {

			for(indexOfRA = mySearchZoneLoneos.indexOfFirstRightAscensionZone; indexOfRA <= mySearchZoneLoneos.indexOfLastRightAscensionZone; indexOfRA++) {

				processOneZoneLoneos(inputStream,numberOfStarsperZone[indexOfDecZone],
						&headOfList,readStars,mySearchZoneLoneos,indexOfDecZone,indexOfRA);
			}

		}

		fclose(inputStream);
	}

	/* Release memory */
	releaseDoubleArray((void**)numberOfStarsperZone,INDEX_TABLE_DEC_DIMENSION_LONEOS);
	releaseSimpleArray(readStars);

	listOfStarsLoneos* theStars  = headOfList;

	return (theStars);
}

/****************************************************************************/
/* Process one RA-DEC zone centered on zero ra                              */
/****************************************************************************/
void processOneZoneLoneos(FILE* const inputStream,const int* const numberOfStarsPerZone,
		elementListLoneos** headOfList, starLoneos* const readStars,
		const searchZoneLoneos& mySearchZoneLoneos, const int indexOfDecZone, const int indexOfRaZone) {

	bool goodStar;
	int numberOfStarsBefore;
	int index;
	int indexOfStar;

	numberOfStarsBefore = 0;
	if(indexOfRaZone > 0) {
		for(index = 0; index < indexOfRaZone; index++) {
			numberOfStarsBefore += numberOfStarsPerZone[index];
		}
	}

	/* Move to this position */
	if(fseek(inputStream,numberOfStarsBefore * sizeof(starLoneos),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the stars */
	if(fread(readStars,sizeof(starLoneos),numberOfStarsPerZone[indexOfRaZone],inputStream) != (size_t)numberOfStarsPerZone[indexOfRaZone]) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (starLoneos)\n",numberOfStarsPerZone[indexOfRaZone]);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < numberOfStarsPerZone[indexOfRaZone]; indexOfStar++) {

		starLoneos& theStar   = readStars[indexOfStar];

		goodStar              = isGoodStarLoneos(theStar, mySearchZoneLoneos);

		if (goodStar) {

			elementListLoneos* currentElement  = (elementListLoneos*)malloc(sizeof(elementListLoneos));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListLoneos) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}

			currentElement->theStar  = theStar;
			currentElement->nextStar = *headOfList;
			*headOfList              = currentElement;
		}
	}
}

/****************************************************************************/
/* Read the catalog files which contain the search zones                    */
/****************************************************************************/
int** readIndexFileLoneos(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone) {

	char fileName[1024];
	char oneLine[128];
	FILE* inputStream;
	int zoneRa;
	int zoneDec;
	int indexOfDecZone;
	int indexOfRaZone;
	int totalNumberOfStars;
	int numberOfStars;
	maximumNumberOfStarsPerZone = 0;

	/* Allocate numberOfStarsPerZone */
	int** numberOfStarsPerZone = (int**)malloc(INDEX_TABLE_DEC_DIMENSION_LONEOS * sizeof(int*));
	if(numberOfStarsPerZone == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"numberOfStarsPerZone = %d (accFiles) out of memory\n",INDEX_TABLE_DEC_DIMENSION_LONEOS);
		throw InsufficientMemoryException(outputLogChar);
	}

	for(indexOfDecZone = 0; indexOfDecZone < INDEX_TABLE_DEC_DIMENSION_LONEOS;indexOfDecZone++) {

		numberOfStarsPerZone[indexOfDecZone] = (int*)malloc(INDEX_TABLE_RA_DIMENSION_LONEOS * sizeof(int));
		if(numberOfStarsPerZone[indexOfDecZone] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"numberOfStarsPerZone[%d] = %d (int) out of memory\n",indexOfDecZone,INDEX_TABLE_RA_DIMENSION_LONEOS);
			throw InsufficientMemoryException(outputLogChar);
		}
	}

	/* Open the index file for reading */
	sprintf(fileName,"%s%s",pathOfCatalog,LONEOS_INDEX_FILENAME);
	inputStream = fopen(fileName,"rt");
	if(inputStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"%s not found\n",fileName);
		throw FileNotFoundException(outputLogChar);
	}

	for(indexOfDecZone = 0; indexOfDecZone < INDEX_TABLE_DEC_DIMENSION_LONEOS;indexOfDecZone++) {

		for(indexOfRaZone = 0; indexOfRaZone < INDEX_TABLE_RA_DIMENSION_LONEOS; indexOfRaZone++) {

			if ( fgets (oneLine, 128, inputStream) == NULL ) {

				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"%s : can not read the %d th line of the %d th dec zone\n",fileName,indexOfRaZone,indexOfDecZone);
				throw CanNotReadInStreamException(outputLogChar);

			} else {

				sscanf(oneLine,LONEOS_INDEX_FORMAT,&zoneDec,&zoneRa,&numberOfStars,&totalNumberOfStars);

				if(zoneDec != indexOfDecZone + 1) {
					char outputLogChar[STRING_COMMON_LENGTH];
					sprintf(outputLogChar,"error in Dec zone in the %d th line of the %d th dec zone\n",indexOfRaZone,indexOfDecZone);
					throw InvalidDataException(outputLogChar);
				}

				if(zoneRa != indexOfRaZone + 1) {
					char outputLogChar[STRING_COMMON_LENGTH];
					sprintf(outputLogChar,"error in Ra zone in the %d th line of the %d th dec zone\n",indexOfRaZone,indexOfDecZone);
					throw InvalidDataException(outputLogChar);
				}

				numberOfStarsPerZone[indexOfDecZone][indexOfRaZone] = numberOfStars;

				if(maximumNumberOfStarsPerZone  < numberOfStars) {
					maximumNumberOfStarsPerZone = numberOfStars;
				}
			}
		}
	}

	fclose(inputStream);

	return (numberOfStarsPerZone);
}


searchZoneLoneos findSearchZoneLoneos(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneLoneos mySearchZoneLoneos;

	fillSearchZoneRaDecDeg(mySearchZoneLoneos.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneLoneos.magnitudeBox, magMin, magMax);

	mySearchZoneLoneos.indexOfFirstDecZone = (int) ((mySearchZoneLoneos.subSearchZone.decStartInDeg - DEC_SOUTH_POLE_DEG) / LONEOS_DEC_ZONE_WIDTH);
	mySearchZoneLoneos.indexOfLastDecZone  = (int) ((mySearchZoneLoneos.subSearchZone.decEndInDeg   - DEC_SOUTH_POLE_DEG) / LONEOS_DEC_ZONE_WIDTH);

	if(mySearchZoneLoneos.indexOfFirstDecZone >= INDEX_TABLE_DEC_DIMENSION_LONEOS) {
		mySearchZoneLoneos.indexOfFirstDecZone = INDEX_TABLE_DEC_DIMENSION_LONEOS - 1;
	}
	if(mySearchZoneLoneos.indexOfLastDecZone  >= INDEX_TABLE_DEC_DIMENSION_LONEOS) {
		mySearchZoneLoneos.indexOfLastDecZone  = INDEX_TABLE_DEC_DIMENSION_LONEOS - 1;
	}

	mySearchZoneLoneos.indexOfFirstRightAscensionZone = (int)(mySearchZoneLoneos.subSearchZone.raStartInDeg / LONEOS_RA_ZONE_WIDTH);
	mySearchZoneLoneos.indexOfLastRightAscensionZone  = (int)(mySearchZoneLoneos.subSearchZone.raEndInDeg   / LONEOS_RA_ZONE_WIDTH);

    if(mySearchZoneLoneos.indexOfFirstRightAscensionZone >= INDEX_TABLE_RA_DIMENSION_LONEOS) {
		mySearchZoneLoneos.indexOfFirstRightAscensionZone = INDEX_TABLE_RA_DIMENSION_LONEOS - 1;
	}
	if(mySearchZoneLoneos.indexOfLastRightAscensionZone  >= INDEX_TABLE_RA_DIMENSION_LONEOS) {
		mySearchZoneLoneos.indexOfLastRightAscensionZone  = INDEX_TABLE_RA_DIMENSION_LONEOS - 1;
	}

	return (mySearchZoneLoneos);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarLoneos(const starLoneos& theStar, const searchZoneLoneos& mySearchZoneLoneos) {

	const searchZoneRaDecDeg subSearchZone  = mySearchZoneLoneos.subSearchZone;
	const magnitudeBoxMag magnitudeBox      = mySearchZoneLoneos.magnitudeBox;

	if(
			((subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInDeg) || (theStar.ra <= subSearchZone.raEndInDeg))) ||
					(!subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInDeg) && (theStar.ra <= subSearchZone.raEndInDeg)))) &&
					(theStar.dec >= subSearchZone.decStartInDeg) &&
					(theStar.dec <= subSearchZone.decEndInDeg) &&
					(theStar.magnitudeV >= magnitudeBox.magnitudeStartInMag) &&
					(theStar.magnitudeV <= magnitudeBox.magnitudeEndInMag)) {

		return(true);
	}

	return (false);
}

void CCatalog::releaseListOfStarLoneos(listOfStarsLoneos* listOfStars) {

	elementListLoneos* currentElement = listOfStars;
	elementListLoneos* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
