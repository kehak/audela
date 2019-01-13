#include "CCatalog.h" 
#include "csgaia2.h"
/*
 * csgaia1.cpp
 *
 *  Created on: Sep 6, 2018
 *      Author: Y. Damerdji
 */

/**
 * Extract stars from Gaia2 catalog
 */
listOfStarsGaia2* CCatalog::csgaia2 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfDec;
	int indexOfRa;
	int counterOfDec;
	int counterOfRa;
	int maximumNumberOfStarsPerZone;
	int maximumNumberOfStarsPerZoneVrad;
	char catalogCompleteName[1024];
	char catalogVradCompleteName[1024];

	/* Define the search zone */
	searchZoneGaia2 mySearchZoneGaia2 = findSearchZoneGaia2(ra,dec,radius,magMin,magMax);

	//	clock_t begin = clock();

	/* Read the index files */
	const indexTableGaia2* const * const indexTable = readIndexFileGaia2(pathToCatalog, GAIA2_STAR_INDEX, mySearchZoneGaia2, maximumNumberOfStarsPerZone);
	const indexTableGaia2* const * const indexTableVrad = readIndexFileGaia2(pathToCatalog, GAIA2_VRAD_INDEX, mySearchZoneGaia2, maximumNumberOfStarsPerZoneVrad);

	//	clock_t end1 = clock();
	//	double time_spent_indices = (double)(end1 - begin) / CLOCKS_PER_SEC;
	//	printf("lis les indices en %f s\n",time_spent_indices);

	/* Allocate memory for an array in which we put the read stars */
	starGaia2* readStars = (starGaia2*)malloc(maximumNumberOfStarsPerZone * sizeof(starGaia2));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (starGaia2) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	vradGaia2* readStarsVrad = (vradGaia2*)malloc(maximumNumberOfStarsPerZone * sizeof(vradGaia2));
	if(readStarsVrad == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStarsVrad = %d (vradGaia2) out of memory\n",maximumNumberOfStarsPerZoneVrad);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Read the catalog of Vrads */
	sprintf(catalogVradCompleteName,GAIA2_VRAD_CATALOG,pathToCatalog);

	FILE* inputStreamVrad = fopen(catalogVradCompleteName,"rb");
	if (inputStreamVrad  == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Cannot open catalog : %s\n",catalogVradCompleteName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Now we loop over the concerned catalogs */
	elementListGaia2* headOfList = NULL;

	counterOfDec   = 0;
	for(indexOfDec = mySearchZoneGaia2.indexOfFirstDecZone; indexOfDec <= mySearchZoneGaia2.indexOfLastDecZone; indexOfDec++) {

		/* Read the catalog */
		sprintf(catalogCompleteName,GAIA2_CATALOG_FORMAT,pathToCatalog,indexOfDec + 1);

		FILE* inputStream = fopen(catalogCompleteName,"rb");
		if (inputStream  == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Cannot open catalog : %s\n",catalogCompleteName);
			throw FileNotFoundException(outputLogChar);
		}

		counterOfRa = 0;

		if(mySearchZoneGaia2.subSearchZone.isArroundZeroRa) {

			for(indexOfRa = mySearchZoneGaia2.indexOfFirstRightAscensionZone; indexOfRa < GAIA2_BINARY_NUMBER_RA_ZONES; indexOfRa++) {

				if(indexTable[counterOfDec][counterOfRa].numberOfStarsInZone > 0) {
					processOneZoneGaia2(inputStream,inputStreamVrad,indexTable[counterOfDec][counterOfRa],
							indexTableVrad[counterOfDec][counterOfRa],&headOfList,readStars,readStarsVrad,mySearchZoneGaia2);
				}
				counterOfRa++;
			}

			for(indexOfRa = 0; indexOfRa <= mySearchZoneGaia2.indexOfLastRightAscensionZone; indexOfRa++) {

				if(indexTable[counterOfDec][counterOfRa].numberOfStarsInZone > 0) {
					processOneZoneGaia2(inputStream,inputStreamVrad,indexTable[counterOfDec][counterOfRa],
							indexTableVrad[counterOfDec][counterOfRa],&headOfList,readStars,readStarsVrad,mySearchZoneGaia2);
				}
				counterOfRa++;
			}

		} else {

			for(indexOfRa = mySearchZoneGaia2.indexOfFirstRightAscensionZone; indexOfRa <= mySearchZoneGaia2.indexOfLastRightAscensionZone; indexOfRa++) {

				if(indexTable[counterOfDec][counterOfRa].numberOfStarsInZone > 0) {
					processOneZoneGaia2(inputStream,inputStreamVrad,indexTable[counterOfDec][counterOfRa],
							indexTableVrad[counterOfDec][counterOfRa],&headOfList,readStars,readStarsVrad,mySearchZoneGaia2);
				}
				counterOfRa++;
			}
		}

		/* Close the catalog file */
		fclose(inputStream);

		counterOfDec++;
	}

	releaseSimpleArray(readStars);
	releaseDoubleArray((void**)indexTable,mySearchZoneGaia2.indexOfLastDecZone - mySearchZoneGaia2.indexOfFirstDecZone + 1);

	listOfStarsGaia2* theStars = headOfList;

	//	clock_t end2 = clock();
	//	double time_spent_reste = (double)(end2 - end1) / CLOCKS_PER_SEC;
	//	printf("fais le reste en %f s\n",time_spent_reste);

	return (theStars);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
void processOneZoneGaia2(FILE* const inputStream, FILE* const inputStreamVrad,const indexTableGaia2& oneAccFile,
		const indexTableGaia2& oneAccFileVrad,elementListGaia2** headOfList,starGaia2* const redStars,
		vradGaia2* const redStarsVrad, const searchZoneGaia2& mySearchZoneGaia2) {

	int indexOfStar;

	/* Move to this position */
	const int resultOfSeek = fseek(inputStream,oneAccFile.numberOfAllStarsBefore * sizeof(starGaia2),SEEK_SET);
	if(resultOfSeek != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	const int resultOfSeekVrad = fseek(inputStreamVrad,oneAccFileVrad.numberOfAllStarsBefore * sizeof(vradGaia2),SEEK_SET);
	if(resultOfSeekVrad != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStreamVrad\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the amount of stars */
	const int resultOfRead = fread(redStars,sizeof(starGaia2),oneAccFile.numberOfStarsInZone,inputStream);
	if(resultOfRead !=  oneAccFile.numberOfStarsInZone) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (starGaia2)\n",oneAccFile.numberOfStarsInZone);
		throw CanNotReadInStreamException(outputLogChar);
	}

	const int resultOfReadVrad = fread(redStarsVrad,sizeof(vradGaia2),oneAccFileVrad.numberOfStarsInZone,inputStream);
	if(resultOfReadVrad !=  oneAccFileVrad.numberOfStarsInZone) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (vradGaia2)\n",oneAccFileVrad.numberOfStarsInZone);
		throw CanNotReadInStreamException(outputLogChar);
	}

	int correspondingIndex;

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile.numberOfStarsInZone; indexOfStar++) {

		if(isGoodStarBinaryGaia2(redStars[indexOfStar], mySearchZoneGaia2)) {

			correspondingIndex = findCorrespondingVrad(redStarsVrad,oneAccFileVrad.numberOfStarsInZone,
					redStars[indexOfStar].sourceId);

			elementListGaia2* currentElement   = (elementListGaia2*)malloc(sizeof(elementListGaia2));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListGaia2) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}

			currentElement->theStar.theStarGaia2  = redStars[indexOfStar];

			if(correspondingIndex >= 0) {

				currentElement->theStar.vRad = redStarsVrad[correspondingIndex].vRad;
				currentElement->theStar.vRadError = redStarsVrad[correspondingIndex].vRadError;
				currentElement->theStar.templateTeff = redStarsVrad[correspondingIndex].templateTeff;
				currentElement->theStar.templateLogg = redStarsVrad[correspondingIndex].templateLogg;
				currentElement->theStar.templateFeH = redStarsVrad[correspondingIndex].templateFeH;

			} else {

				currentElement->theStar.vRad = NAN;
				currentElement->theStar.vRadError = NAN;
				currentElement->theStar.templateTeff = NAN;
				currentElement->theStar.templateLogg = NAN;
				currentElement->theStar.templateFeH = NAN;
			}

			currentElement->nextStar = *headOfList;
			*headOfList              = currentElement;
		}
	}
}

int findCorrespondingVrad(const vradGaia2* const redStarsVrad,const int numberOfStars,
		const long long sourceId) {

	int correspondingIndex = -1;

	for(int index = 0; index < numberOfStars; index++) {

		if(redStarsVrad[index].sourceId == sourceId) {

			return index;
		}
	}

	return correspondingIndex;
}

/**
 * Read the index file
 */
indexTableGaia2** readIndexFileGaia2(const char* const pathOfCatalog, const char* const formatCatalog, const searchZoneGaia2& mySearchZoneGaia2, int& maximumNumberOfStarsPerZone) {

	char completeFileName[STRING_COMMON_LENGTH];
	int decZone;
	int counterOfDecZone;
	int raZone;
	int numberOfReadRaZones;
	int resultOfRead;
	int shiftNumberOfStars;
	maximumNumberOfStarsPerZone = 0;
	const int numberOfDecZones = mySearchZoneGaia2.indexOfLastDecZone - mySearchZoneGaia2.indexOfFirstDecZone + 1;
	indexTableGaia2** indexTable;
	indexTableGaia2* pointerToTable;
	int numberOfRaZones        = mySearchZoneGaia2.indexOfLastRightAscensionZone - mySearchZoneGaia2.indexOfFirstRightAscensionZone + 1;

	if(mySearchZoneGaia2.subSearchZone.isArroundZeroRa) {
		numberOfRaZones       += GAIA2_BINARY_NUMBER_RA_ZONES;
	}

	sprintf(completeFileName,formatCatalog,pathOfCatalog);
	FILE* tableStream = fopen(completeFileName,"rb");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTable    = (indexTableGaia2**)malloc(numberOfDecZones * sizeof(indexTableGaia2*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}

	counterOfDecZone = 0;
	for(decZone = mySearchZoneGaia2.indexOfFirstDecZone; decZone <= mySearchZoneGaia2.indexOfLastDecZone; decZone++) {

		indexTable[counterOfDecZone] = (indexTableGaia2*)malloc(numberOfRaZones * sizeof(indexTableGaia2));
		if(indexTable[counterOfDecZone] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Error : indexTable[%d] out of memory\n",counterOfDecZone);
			throw InsufficientMemoryException(outputLogChar);
		}

		if(mySearchZoneGaia2.subSearchZone.isArroundZeroRa) {

			/* From mySearchZoneGaia2.indexOfFirstRightAscensionZone to GAIA2_BINARY_NUMBER_RA_ZONES */
			pointerToTable     = indexTable[counterOfDecZone];
			shiftNumberOfStars = decZone * GAIA2_BINARY_NUMBER_RA_ZONES + mySearchZoneGaia2.indexOfFirstRightAscensionZone;
			if(fseek(tableStream, shiftNumberOfStars * sizeof(indexTableGaia2), SEEK_SET) != 0) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when moving in stream of indexes\n");
				throw CanNotReadInStreamException(outputLogChar);
			}

			numberOfReadRaZones = GAIA2_BINARY_NUMBER_RA_ZONES - mySearchZoneGaia2.indexOfFirstRightAscensionZone;
			resultOfRead        = fread(pointerToTable,sizeof(indexTableGaia2),numberOfReadRaZones,tableStream);
			if(resultOfRead    != numberOfReadRaZones) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when reading %d indexTableGaia2 in %s\n",numberOfReadRaZones,completeFileName);
				throw CanNotReadInStreamException(outputLogChar);
			}

			pointerToTable      = indexTable[counterOfDecZone] + numberOfReadRaZones;

			/* From 0 to mySearchZoneGaia2.indexOfLastRightAscensionZone */
			shiftNumberOfStars = decZone * GAIA2_BINARY_NUMBER_RA_ZONES;
			if(fseek(tableStream, shiftNumberOfStars * sizeof(indexTableGaia2), SEEK_SET) != 0) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when moving in stream of indexes\n");
				throw CanNotReadInStreamException(outputLogChar);
			}

			numberOfReadRaZones = mySearchZoneGaia2.indexOfLastRightAscensionZone + 1;
			resultOfRead        = fread(pointerToTable,sizeof(indexTableGaia2),numberOfReadRaZones,tableStream);
			if(resultOfRead    != numberOfReadRaZones) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when reading %d indexTableGaia2 in %s\n",numberOfReadRaZones,completeFileName);
				throw CanNotReadInStreamException(outputLogChar);
			}

		} else {

			shiftNumberOfStars = decZone * GAIA2_BINARY_NUMBER_RA_ZONES + mySearchZoneGaia2.indexOfFirstRightAscensionZone;
			if(fseek(tableStream, shiftNumberOfStars * sizeof(indexTableGaia2), SEEK_SET) != 0) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when moving in stream of indexes\n");
				throw CanNotReadInStreamException(outputLogChar);
			}

			resultOfRead = fread(indexTable[counterOfDecZone],sizeof(indexTableGaia2),numberOfRaZones,tableStream);
			if(resultOfRead != numberOfRaZones) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Error when reading %d indexTableGaia2 in %s\n",numberOfRaZones,completeFileName);
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

searchZoneGaia2 findSearchZoneGaia2(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneGaia2 mySearchZoneGaia2;

	fillSearchZoneRaDecDeg(mySearchZoneGaia2.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneGaia2.magnitudeBox, magMin, magMax);

	mySearchZoneGaia2.indexOfFirstDecZone = (int) ((mySearchZoneGaia2.subSearchZone.decStartInDeg - DEC_SOUTH_POLE_DEG) / GAIA2_BINARY_STEP_DEC);
	mySearchZoneGaia2.indexOfLastDecZone  = (int) ((mySearchZoneGaia2.subSearchZone.decEndInDeg   - DEC_SOUTH_POLE_DEG) / GAIA2_BINARY_STEP_DEC);

	if(mySearchZoneGaia2.indexOfFirstDecZone >= GAIA2_BINARY_NUMBER_DEC_ZONES) {
		mySearchZoneGaia2.indexOfFirstDecZone = GAIA2_BINARY_NUMBER_DEC_ZONES - 1;
	}
	if(mySearchZoneGaia2.indexOfLastDecZone  >= GAIA2_BINARY_NUMBER_DEC_ZONES) {
		mySearchZoneGaia2.indexOfLastDecZone  = GAIA2_BINARY_NUMBER_DEC_ZONES - 1;
	}

	mySearchZoneGaia2.indexOfFirstRightAscensionZone = (int)(mySearchZoneGaia2.subSearchZone.raStartInDeg / GAIA2_BINARY_STEP_RA);
	mySearchZoneGaia2.indexOfLastRightAscensionZone  = (int)(mySearchZoneGaia2.subSearchZone.raEndInDeg   / GAIA2_BINARY_STEP_RA);

	if(mySearchZoneGaia2.indexOfFirstRightAscensionZone >= GAIA2_BINARY_NUMBER_RA_ZONES) {
		mySearchZoneGaia2.indexOfFirstRightAscensionZone = GAIA2_BINARY_NUMBER_RA_ZONES - 1;
	}
	if(mySearchZoneGaia2.indexOfLastRightAscensionZone  >= GAIA2_BINARY_NUMBER_RA_ZONES) {
		mySearchZoneGaia2.indexOfLastRightAscensionZone  = GAIA2_BINARY_NUMBER_RA_ZONES - 1;
	}


	if(DEBUG) {
		printf("mySearchZone.indexOfFirstDecZone            = %d\n",mySearchZoneGaia2.indexOfFirstDecZone);
		printf("mySearchZone.indexOfLastDecZone             = %d\n",mySearchZoneGaia2.indexOfLastDecZone);
		printf("mySearchZone.indexOfFirstRightAscensionZone = %d\n",mySearchZoneGaia2.indexOfFirstRightAscensionZone);
		printf("mySearchZone.indexOfLastRightAscensionZone  = %d\n",mySearchZoneGaia2.indexOfLastRightAscensionZone);
	}

	return (mySearchZoneGaia2);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarBinaryGaia2(const starGaia2& theStar, const searchZoneGaia2& mySearchZoneGaia2) {

	const searchZoneRaDecDeg subSearchZone  = mySearchZoneGaia2.subSearchZone;
	const magnitudeBoxMag magnitudeBox      = mySearchZoneGaia2.magnitudeBox;

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

void CCatalog::releaseListOfStarGaia2(listOfStarsGaia2* listOfStars) {

	elementListGaia2* currentElement = listOfStars;
	elementListGaia2* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
