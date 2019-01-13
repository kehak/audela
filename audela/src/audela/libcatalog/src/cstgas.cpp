#include "CCatalog.h" 
#include "cstgas.h"
/*
 * cstags.cpp
 *
 *  Created on: Oct 18, 2016
 *      Author: Y. Damerdji
 */

/**
 * Extract stars from TGAS catalog
 */
listOfStarsTGAS* CCatalog::cstgas (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfDec;
	int indexOfRa;
	int maximumNumberOfStarsPerZone;
	char catalogCompleteName[1024];

	/* Define the search zone */
	searchZoneTGAS mySearchZoneTGAS = findSearchZoneTGAS(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	const indexTableTGAS* const * const indexTable = readIndexFileTGAS(pathToCatalog, maximumNumberOfStarsPerZone);

	/* Read the catalog */
	sprintf(catalogCompleteName,"%s%s",pathToCatalog,TGAS_CATALOGX_FILENAME);

	FILE* inputStream = fopen(catalogCompleteName,"rb");
	if (inputStream  == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Cannot open catalog : %s\n",catalogCompleteName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory for an array in which we put the read stars */
	starTGAS* readStars = (starTGAS*)malloc(maximumNumberOfStarsPerZone * sizeof(starTGAS));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (starTGAS) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	elementListTGAS* headOfList = NULL;

	for(indexOfDec = mySearchZoneTGAS.indexOfFirstDecZone; indexOfDec <= mySearchZoneTGAS.indexOfLastDecZone; indexOfDec++) {

		if(mySearchZoneTGAS.subSearchZone.isArroundZeroRa) {

			for(indexOfRa = mySearchZoneTGAS.indexOfFirstRightAscensionZone; indexOfRa < TGAS_BINARY_NUMBER_RA_ZONES; indexOfRa++) {

                if(indexTable[indexOfDec][indexOfRa].numberOfStarsInZone > 0) {
				    processOneZoneTGAS(inputStream,indexTable[indexOfDec][indexOfRa],&headOfList,readStars,mySearchZoneTGAS);
                }
			}

			for(indexOfRa = 0; indexOfRa <= mySearchZoneTGAS.indexOfLastRightAscensionZone; indexOfRa++) {

                if(indexTable[indexOfDec][indexOfRa].numberOfStarsInZone > 0) {
				    processOneZoneTGAS(inputStream,indexTable[indexOfDec][indexOfRa],&headOfList,readStars,mySearchZoneTGAS);
                }
			}

		} else {

			for(indexOfRa = mySearchZoneTGAS.indexOfFirstRightAscensionZone; indexOfRa <= mySearchZoneTGAS.indexOfLastRightAscensionZone; indexOfRa++) {

                if(indexTable[indexOfDec][indexOfRa].numberOfStarsInZone > 0) {
				    processOneZoneTGAS(inputStream,indexTable[indexOfDec][indexOfRa],&headOfList,readStars,mySearchZoneTGAS);
                }
			}
		}
	}

	/* Close the catalog file */
	fclose(inputStream);

	releaseSimpleArray(readStars);
	releaseDoubleArray((void**)indexTable,TGAS_BINARY_NUMBER_DEC_ZONES);

	listOfStarsTGAS* theStars = headOfList;

	return (theStars);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
void processOneZoneTGAS(FILE* const inputStream,const indexTableTGAS& oneAccFile,elementListTGAS** headOfList,starTGAS* const redStars,
		const searchZoneTGAS& mySearchZoneTGAS) {

	unsigned int indexOfStar;

	/* Move to this position */
    const int resultOfSeek = fseek(inputStream,oneAccFile.numberOfAllStarsBefore * sizeof(starTGAS),SEEK_SET);
	if(resultOfSeek != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the amount of stars */
    const unsigned int resultOfRead = fread(redStars,sizeof(starTGAS),oneAccFile.numberOfStarsInZone,inputStream);
	if(resultOfRead !=  oneAccFile.numberOfStarsInZone) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (starTGAS)\n",oneAccFile.numberOfStarsInZone);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile.numberOfStarsInZone; indexOfStar++) {

		if(isGoodStarBinaryTGAS(redStars[indexOfStar], mySearchZoneTGAS)) {

			elementListTGAS* currentElement   = (elementListTGAS*)malloc(sizeof(elementListTGAS));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListTGAS) out of memory\n");
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
indexTableTGAS** readIndexFileTGAS(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone) {

	char completeFileName[STRING_COMMON_LENGTH];
	char temporaryString[STRING_COMMON_LENGTH];
	char* temporaryPointer;
	int index;
	int numberOfStars;
	int decZoneNumber;
	int raZoneNumber;
	int numberOfStarsInAllZones;
	int index2;
	maximumNumberOfStarsPerZone = 0;
	indexTableTGAS** indexTable;

	sprintf(completeFileName,"%s%s",pathOfCatalog,TGAS_INDEX_FILENAME);
	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTable    = (indexTableTGAS**)malloc(TGAS_BINARY_NUMBER_DEC_ZONES * sizeof(indexTableTGAS*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}
	for(index = 0; index < TGAS_BINARY_NUMBER_DEC_ZONES;index++) {
		indexTable[index] = (indexTableTGAS*)malloc(TGAS_BINARY_NUMBER_RA_ZONES * sizeof(indexTableTGAS));
		if(indexTable[index] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Error : indexTable[%d] out of memory\n",index);
			throw InsufficientMemoryException(outputLogChar);
		}
	}

	/* We read the content */
	while(!feof(tableStream)) {

		temporaryPointer = fgets(temporaryString , STRING_COMMON_LENGTH , tableStream);
		if(temporaryPointer == NULL) {
			break;
		}
		sscanf(temporaryString,TGAS_INDEX_LINE_FORMAT,&decZoneNumber,&raZoneNumber,&numberOfStars,&numberOfStarsInAllZones);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone    = numberOfStars;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfAllStarsBefore = numberOfStarsInAllZones;

		if(maximumNumberOfStarsPerZone  < numberOfStars) {
			maximumNumberOfStarsPerZone = numberOfStars;
		}
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < TGAS_BINARY_NUMBER_DEC_ZONES;index++) {
			for(index2 = 0; index2 < TGAS_BINARY_NUMBER_RA_ZONES;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2].numberOfStarsInZone);
			}
		}
	}

	return (indexTable);
}

searchZoneTGAS findSearchZoneTGAS(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneTGAS mySearchZoneTGAS;

	fillSearchZoneRaDecDeg(mySearchZoneTGAS.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneTGAS.magnitudeBox, magMin, magMax);

	mySearchZoneTGAS.indexOfFirstDecZone = (int) ((mySearchZoneTGAS.subSearchZone.decStartInDeg - DEC_SOUTH_POLE_DEG) / TGAS_BINARY_STEP_DEC);
	mySearchZoneTGAS.indexOfLastDecZone  = (int) ((mySearchZoneTGAS.subSearchZone.decEndInDeg   - DEC_SOUTH_POLE_DEG) / TGAS_BINARY_STEP_DEC);

	if(mySearchZoneTGAS.indexOfFirstDecZone >= TGAS_BINARY_NUMBER_DEC_ZONES) {
		mySearchZoneTGAS.indexOfFirstDecZone = TGAS_BINARY_NUMBER_DEC_ZONES - 1;
	}
	if(mySearchZoneTGAS.indexOfLastDecZone  >= TGAS_BINARY_NUMBER_DEC_ZONES) {
		mySearchZoneTGAS.indexOfLastDecZone  = TGAS_BINARY_NUMBER_DEC_ZONES - 1;
	}

	mySearchZoneTGAS.indexOfFirstRightAscensionZone = (int)(mySearchZoneTGAS.subSearchZone.raStartInDeg / TGAS_BINARY_STEP_RA);
	mySearchZoneTGAS.indexOfLastRightAscensionZone  = (int)(mySearchZoneTGAS.subSearchZone.raEndInDeg   / TGAS_BINARY_STEP_RA);

    if(mySearchZoneTGAS.indexOfFirstRightAscensionZone >= TGAS_BINARY_NUMBER_RA_ZONES) {
		mySearchZoneTGAS.indexOfFirstRightAscensionZone = TGAS_BINARY_NUMBER_RA_ZONES - 1;
	}
	if(mySearchZoneTGAS.indexOfLastRightAscensionZone  >= TGAS_BINARY_NUMBER_RA_ZONES) {
		mySearchZoneTGAS.indexOfLastRightAscensionZone  = TGAS_BINARY_NUMBER_RA_ZONES - 1;
	}

	return (mySearchZoneTGAS);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarBinaryTGAS(const starTGAS& theStar, const searchZoneTGAS& mySearchZoneTGAS) {

	const searchZoneRaDecDeg subSearchZone  = mySearchZoneTGAS.subSearchZone;
	const magnitudeBoxMag magnitudeBox      = mySearchZoneTGAS.magnitudeBox;

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

void CCatalog::releaseListOfStarTGAS(listOfStarsTGAS* listOfStars) {

	elementListTGAS* currentElement = listOfStars;
	elementListTGAS* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
