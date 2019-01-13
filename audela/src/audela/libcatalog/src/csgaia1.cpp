#include "CCatalog.h" 
#include "csgaia1.h"
/*
 * csgaia1.cpp
 *
 *  Created on: Oct 19, 2016
 *      Author: Y. Damerdji
 */

/**
 * Extract stars from Gaia1 catalog
 */
listOfStarsGaia1* CCatalog::csgaia1 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfDec;
	int indexOfRa;
	int counterOfDec;
	int counterOfRa;
	int maximumNumberOfStarsPerZone;
	char catalogCompleteName[1024];

	/* Define the search zone */
	searchZoneGaia1 mySearchZoneGaia1 = findSearchZoneGaia1(ra,dec,radius,magMin,magMax);

//	clock_t begin = clock();

	/* Read the index file */
	const indexTableGaia1* const * const indexTable = readIndexFileGaia1(pathToCatalog, mySearchZoneGaia1, maximumNumberOfStarsPerZone);

//	clock_t end1 = clock();
//	double time_spent_indices = (double)(end1 - begin) / CLOCKS_PER_SEC;
//	printf("lis les indices en %f s\n",time_spent_indices);

	/* Allocate memory for an array in which we put the read stars */
	starGaia1* readStars = (starGaia1*)malloc(maximumNumberOfStarsPerZone * sizeof(starGaia1));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (starGaia1) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we loop over the concerned catalogs */
	elementListGaia1* headOfList = NULL;

	counterOfDec   = 0;
	for(indexOfDec = mySearchZoneGaia1.indexOfFirstDecZone; indexOfDec <= mySearchZoneGaia1.indexOfLastDecZone; indexOfDec++) {

		/* Read the catalog */
		sprintf(catalogCompleteName,GAIA1_CATALOG_FORMAT,pathToCatalog,indexOfDec + 1);

		FILE* inputStream = fopen(catalogCompleteName,"rb");
		if (inputStream  == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Cannot open catalog : %s\n",catalogCompleteName);
			throw FileNotFoundException(outputLogChar);
		}

		counterOfRa = 0;

		if(mySearchZoneGaia1.subSearchZone.isArroundZeroRa) {

			for(indexOfRa = mySearchZoneGaia1.indexOfFirstRightAscensionZone; indexOfRa < GAIA1_BINARY_NUMBER_RA_ZONES; indexOfRa++) {

				if(indexTable[counterOfDec][counterOfRa].numberOfStarsInZone > 0) {
					processOneZoneGaia1(inputStream,indexTable[counterOfDec][counterOfRa],&headOfList,readStars,mySearchZoneGaia1);
				}
				counterOfRa++;
			}

			for(indexOfRa = 0; indexOfRa <= mySearchZoneGaia1.indexOfLastRightAscensionZone; indexOfRa++) {

				if(indexTable[counterOfDec][counterOfRa].numberOfStarsInZone > 0) {
					processOneZoneGaia1(inputStream,indexTable[counterOfDec][counterOfRa],&headOfList,readStars,mySearchZoneGaia1);
				}
				counterOfRa++;
			}

		} else {

			for(indexOfRa = mySearchZoneGaia1.indexOfFirstRightAscensionZone; indexOfRa <= mySearchZoneGaia1.indexOfLastRightAscensionZone; indexOfRa++) {

				if(indexTable[counterOfDec][counterOfRa].numberOfStarsInZone > 0) {
					processOneZoneGaia1(inputStream,indexTable[counterOfDec][counterOfRa],&headOfList,readStars,mySearchZoneGaia1);
				}
				counterOfRa++;
			}
		}

		/* Close the catalog file */
		fclose(inputStream);

		counterOfDec++;
	}

	releaseSimpleArray(readStars);
	releaseDoubleArray((void**)indexTable,mySearchZoneGaia1.indexOfLastDecZone - mySearchZoneGaia1.indexOfFirstDecZone + 1);

	listOfStarsGaia1* theStars = headOfList;

//	clock_t end2 = clock();
//	double time_spent_reste = (double)(end2 - end1) / CLOCKS_PER_SEC;
//	printf("fais le reste en %f s\n",time_spent_reste);

	return (theStars);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
void processOneZoneGaia1(FILE* const inputStream,const indexTableGaia1& oneAccFile,elementListGaia1** headOfList,starGaia1* const redStars,
		const searchZoneGaia1& mySearchZoneGaia1) {

	int indexOfStar;

	/* Move to this position */
	const int resultOfSeek = fseek(inputStream,oneAccFile.numberOfAllStarsBefore * sizeof(starGaia1),SEEK_SET);
	if(resultOfSeek != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the amount of stars */
	const int resultOfRead = fread(redStars,sizeof(starGaia1),oneAccFile.numberOfStarsInZone,inputStream);
	if(resultOfRead !=  oneAccFile.numberOfStarsInZone) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (starGaia1)\n",oneAccFile.numberOfStarsInZone);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile.numberOfStarsInZone; indexOfStar++) {

		if(isGoodStarBinaryGaia1(redStars[indexOfStar], mySearchZoneGaia1)) {

			elementListGaia1* currentElement   = (elementListGaia1*)malloc(sizeof(elementListGaia1));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListGaia1) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}

			currentElement->theStar  = redStars[indexOfStar];

			currentElement->nextStar = *headOfList;
			*headOfList              = currentElement;
		}
	}
}

/**
 * Read the index file
 */
indexTableGaia1** readIndexFileGaia1(const char* const pathOfCatalog, const searchZoneGaia1& mySearchZoneGaia1, int& maximumNumberOfStarsPerZone) {

	char completeFileName[STRING_COMMON_LENGTH];
	int decZone;
	int counterOfDecZone;
	int raZone;
	int numberOfReadRaZones;
	int resultOfRead;
	int shiftNumberOfStars;
	maximumNumberOfStarsPerZone = 0;
	const int numberOfDecZones = mySearchZoneGaia1.indexOfLastDecZone - mySearchZoneGaia1.indexOfFirstDecZone + 1;
	indexTableGaia1** indexTable;
	indexTableGaia1* pointerToTable;
	int numberOfRaZones        = mySearchZoneGaia1.indexOfLastRightAscensionZone - mySearchZoneGaia1.indexOfFirstRightAscensionZone + 1;

	if(mySearchZoneGaia1.subSearchZone.isArroundZeroRa) {
		numberOfRaZones       += GAIA1_BINARY_NUMBER_RA_ZONES;
	}

	sprintf(completeFileName,GAIA1_INDEX_FORMAT,pathOfCatalog);
	FILE* tableStream = fopen(completeFileName,"rb");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTable    = (indexTableGaia1**)malloc(numberOfDecZones * sizeof(indexTableGaia1*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}

	counterOfDecZone = 0;
	for(decZone = mySearchZoneGaia1.indexOfFirstDecZone; decZone <= mySearchZoneGaia1.indexOfLastDecZone; decZone++) {

		indexTable[counterOfDecZone] = (indexTableGaia1*)malloc(numberOfRaZones * sizeof(indexTableGaia1));
		if(indexTable[counterOfDecZone] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Error : indexTable[%d] out of memory\n",counterOfDecZone);
			throw InsufficientMemoryException(outputLogChar);
		}

		if(mySearchZoneGaia1.subSearchZone.isArroundZeroRa) {

			/* From mySearchZoneGaia1.indexOfFirstRightAscensionZone to GAIA1_BINARY_NUMBER_RA_ZONES */
			pointerToTable     = indexTable[counterOfDecZone];
			shiftNumberOfStars = decZone * GAIA1_BINARY_NUMBER_RA_ZONES + mySearchZoneGaia1.indexOfFirstRightAscensionZone;
			if(fseek(tableStream, shiftNumberOfStars * sizeof(indexTableGaia1), SEEK_SET) != 0) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when moving in stream of indexes\n");
				throw CanNotReadInStreamException(outputLogChar);
			}

			numberOfReadRaZones = GAIA1_BINARY_NUMBER_RA_ZONES - mySearchZoneGaia1.indexOfFirstRightAscensionZone;
			resultOfRead        = fread(pointerToTable,sizeof(indexTableGaia1),numberOfReadRaZones,tableStream);
			if(resultOfRead    != numberOfReadRaZones) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when reading %d indexTableGaia1 in %s\n",numberOfReadRaZones,completeFileName);
				throw CanNotReadInStreamException(outputLogChar);
			}

			pointerToTable      = indexTable[counterOfDecZone] + numberOfReadRaZones;

			/* From 0 to mySearchZoneGaia1.indexOfLastRightAscensionZone */
			shiftNumberOfStars = decZone * GAIA1_BINARY_NUMBER_RA_ZONES;
			if(fseek(tableStream, shiftNumberOfStars * sizeof(indexTableGaia1), SEEK_SET) != 0) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when moving in stream of indexes\n");
				throw CanNotReadInStreamException(outputLogChar);
			}

			numberOfReadRaZones = mySearchZoneGaia1.indexOfLastRightAscensionZone + 1;
			resultOfRead        = fread(pointerToTable,sizeof(indexTableGaia1),numberOfReadRaZones,tableStream);
			if(resultOfRead    != numberOfReadRaZones) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when reading %d indexTableGaia1 in %s\n",numberOfReadRaZones,completeFileName);
				throw CanNotReadInStreamException(outputLogChar);
			}

		} else {

			shiftNumberOfStars = decZone * GAIA1_BINARY_NUMBER_RA_ZONES + mySearchZoneGaia1.indexOfFirstRightAscensionZone;
			if(fseek(tableStream, shiftNumberOfStars * sizeof(indexTableGaia1), SEEK_SET) != 0) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when moving in stream of indexes\n");
				throw CanNotReadInStreamException(outputLogChar);
			}

			resultOfRead = fread(indexTable[counterOfDecZone],sizeof(indexTableGaia1),numberOfRaZones,tableStream);
			if(resultOfRead != numberOfRaZones) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when reading %d indexTableGaia1 in %s\n",numberOfRaZones,completeFileName);
				throw CanNotReadInStreamException(outputLogChar);
			}
		}

		for(int raZone = 0; raZone < numberOfRaZones; raZone++) {
			if(maximumNumberOfStarsPerZone  < indexTable[counterOfDecZone][raZone].numberOfStarsInZone) {
				maximumNumberOfStarsPerZone = indexTable[counterOfDecZone][raZone].numberOfStarsInZone;
			}
		}

		counterOfDecZone++;
	}

	fclose(tableStream);

	if(DEBUG) {
		for(decZone = 0; decZone < numberOfDecZones; decZone++) {
			for(raZone = 0; raZone < numberOfRaZones; raZone++) {
				printf("indexTable[%3d][%3d] = %d - %d\n",decZone,raZone,indexTable[decZone][raZone].numberOfStarsInZone,
						indexTable[decZone][raZone].numberOfAllStarsBefore);
			}
		}
	}

	return (indexTable);
}

searchZoneGaia1 findSearchZoneGaia1(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneGaia1 mySearchZoneGaia1;

	fillSearchZoneRaDecDeg(mySearchZoneGaia1.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneGaia1.magnitudeBox, magMin, magMax);

	mySearchZoneGaia1.indexOfFirstDecZone = (int) ((mySearchZoneGaia1.subSearchZone.decStartInDeg - DEC_SOUTH_POLE_DEG) / GAIA1_BINARY_STEP_DEC);
	mySearchZoneGaia1.indexOfLastDecZone  = (int) ((mySearchZoneGaia1.subSearchZone.decEndInDeg   - DEC_SOUTH_POLE_DEG) / GAIA1_BINARY_STEP_DEC);

	if(mySearchZoneGaia1.indexOfFirstDecZone >= GAIA1_BINARY_NUMBER_DEC_ZONES) {
		mySearchZoneGaia1.indexOfFirstDecZone = GAIA1_BINARY_NUMBER_DEC_ZONES - 1;
	}
	if(mySearchZoneGaia1.indexOfLastDecZone  >= GAIA1_BINARY_NUMBER_DEC_ZONES) {
		mySearchZoneGaia1.indexOfLastDecZone  = GAIA1_BINARY_NUMBER_DEC_ZONES - 1;
	}

	mySearchZoneGaia1.indexOfFirstRightAscensionZone = (int)(mySearchZoneGaia1.subSearchZone.raStartInDeg / GAIA1_BINARY_STEP_RA);
	mySearchZoneGaia1.indexOfLastRightAscensionZone  = (int)(mySearchZoneGaia1.subSearchZone.raEndInDeg   / GAIA1_BINARY_STEP_RA);

	if(mySearchZoneGaia1.indexOfFirstRightAscensionZone >= GAIA1_BINARY_NUMBER_RA_ZONES) {
		mySearchZoneGaia1.indexOfFirstRightAscensionZone = GAIA1_BINARY_NUMBER_RA_ZONES - 1;
	}
	if(mySearchZoneGaia1.indexOfLastRightAscensionZone  >= GAIA1_BINARY_NUMBER_RA_ZONES) {
		mySearchZoneGaia1.indexOfLastRightAscensionZone  = GAIA1_BINARY_NUMBER_RA_ZONES - 1;
	}


	if(DEBUG) {
		printf("mySearchZone.indexOfFirstDecZone            = %d\n",mySearchZoneGaia1.indexOfFirstDecZone);
		printf("mySearchZone.indexOfLastDecZone             = %d\n",mySearchZoneGaia1.indexOfLastDecZone);
		printf("mySearchZone.indexOfFirstRightAscensionZone = %d\n",mySearchZoneGaia1.indexOfFirstRightAscensionZone);
		printf("mySearchZone.indexOfLastRightAscensionZone  = %d\n",mySearchZoneGaia1.indexOfLastRightAscensionZone);
	}

	return (mySearchZoneGaia1);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarBinaryGaia1(const starGaia1& theStar, const searchZoneGaia1& mySearchZoneGaia1) {

	const searchZoneRaDecDeg subSearchZone  = mySearchZoneGaia1.subSearchZone;
	const magnitudeBoxMag magnitudeBox      = mySearchZoneGaia1.magnitudeBox;

	if(
			((subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInDeg) || (theStar.ra <= subSearchZone.raEndInDeg))) ||
					(!subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInDeg) && (theStar.ra <= subSearchZone.raEndInDeg)))) &&
					(theStar.dec >= subSearchZone.decStartInDeg) &&
					(theStar.dec <= subSearchZone.decEndInDeg) &&
					(theStar.meanMagnitudeG >= magnitudeBox.magnitudeStartInMag) &&
					(theStar.meanMagnitudeG <= magnitudeBox.magnitudeEndInMag)) {

		return(true);
	}

	return (false);
}

void CCatalog::releaseListOfStarGaia1(listOfStarsGaia1* listOfStars) {

	elementListGaia1* currentElement = listOfStars;
	elementListGaia1* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
