#include "CCatalog.h"
#include "csbmk.h"
/*
 * csbmk.cpp
 *
 *  Created on: Jul 05, 2015
 *      Author: Y. Damerdji
 */

/**
 * Extract stars from Bmk catalog
 */
listOfStarsBmk* CCatalog::csbmk (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfDec;
	int indexOfRa;
	int maximumNumberOfStarsPerZone;
	char catalogCompleteName[1024];

	/* Define the search zone */
	searchZoneBinaryBmk mySearchZoneBmk = findSearchZoneBinaryBmk(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	const indexTableBmk* const * const indexTable = readIndexFileBmk(pathToCatalog, maximumNumberOfStarsPerZone);

	/* Read the catalog */
	sprintf(catalogCompleteName,"%s/%s",pathToCatalog,BINARY_CATALOG_FILE_NAME_BMK);

	FILE* inputStream = fopen(catalogCompleteName,"rb");
	if (inputStream  == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Cannot open catalog : %s\n",catalogCompleteName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory for an array in which we put the read stars */
	starBmk* readStars = (starBmk*)malloc(maximumNumberOfStarsPerZone * sizeof(starBmk));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (starBmk) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	elementListBmk* headOfList = NULL;

	for(indexOfDec = mySearchZoneBmk.indexOfFirstDecZone; indexOfDec <= mySearchZoneBmk.indexOfLastDecZone; indexOfDec++) {

		if(mySearchZoneBmk.subSearchZone.isArroundZeroRa) {

			for(indexOfRa = mySearchZoneBmk.indexOfFirstRightAscensionZone; indexOfRa < INDEX_TABLE_RA_DIMENSION_BMK; indexOfRa++) {

				processOneZoneBmk(inputStream,indexTable[indexOfDec],&headOfList,readStars,mySearchZoneBmk,indexOfRa);
			}

			for(indexOfRa = 0; indexOfRa <= mySearchZoneBmk.indexOfLastRightAscensionZone; indexOfRa++) {

				processOneZoneBmk(inputStream,indexTable[indexOfDec],&headOfList,readStars,mySearchZoneBmk,indexOfRa);
			}

		} else {

			for(indexOfRa = mySearchZoneBmk.indexOfFirstRightAscensionZone; indexOfRa <= mySearchZoneBmk.indexOfLastRightAscensionZone; indexOfRa++) {

				processOneZoneBmk(inputStream,indexTable[indexOfDec],&headOfList,readStars,mySearchZoneBmk,indexOfRa);
			}
		}
	}

	/* Close the catalog file */
	fclose(inputStream);

	releaseSimpleArray(readStars);
	releaseDoubleArray((void**)indexTable,INDEX_TABLE_DEC_DIMENSION_BMK);

	listOfStarsBmk* theStars = headOfList;

	return (theStars);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
void processOneZoneBmk(FILE* const inputStream,const indexTableBmk* const oneAccFile,
		elementListBmk** headOfList,starBmk* const redStars,
		const searchZoneBinaryBmk& mySearchZoneBmk, const int indexOfRa) {

	unsigned int indexOfStar;

	/* Move to this position */
	if(fseek(inputStream,oneAccFile[indexOfRa].idOfFirstStarInZone * sizeof(starBmk),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the amount of stars */
	if(fread(redStars,sizeof(starBmk),oneAccFile[indexOfRa].numberOfStarsInZone,inputStream) !=  oneAccFile[indexOfRa].numberOfStarsInZone) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (star2Mass)\n",oneAccFile[indexOfRa].numberOfStarsInZone);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile[indexOfRa].numberOfStarsInZone; indexOfStar++) {

		if(isGoodStarBinaryBmk(redStars[indexOfStar], mySearchZoneBmk)) {

			elementListBmk* currentElement   = (elementListBmk*)malloc(sizeof(elementListBmk));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListBmk) out of memory\n");
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
indexTableBmk** readIndexFileBmk(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone) {

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
	indexTableBmk** indexTable;

	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_BMK);
	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTable    = (indexTableBmk**)malloc(INDEX_TABLE_DEC_DIMENSION_BMK * sizeof(indexTableBmk*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_BMK;index++) {
		indexTable[index] = (indexTableBmk*)malloc(INDEX_TABLE_RA_DIMENSION_BMK * sizeof(indexTableBmk));
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
		sscanf(temporaryString,FORMAT_INDEX_FILE_BMK,&decZoneNumber,&raZoneNumber,&numberOfStars,&numberOfStarsInAllZones);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone = numberOfStars;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].idOfFirstStarInZone = numberOfStarsInAllZones - numberOfStars;

		if(maximumNumberOfStarsPerZone  < numberOfStars) {
			maximumNumberOfStarsPerZone = numberOfStars;
		}
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_BMK;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION_BMK;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2].numberOfStarsInZone);
			}
		}
	}

	return (indexTable);
}

searchZoneBinaryBmk findSearchZoneBinaryBmk(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneBinaryBmk mySearchZoneBmk;

	fillSearchZoneRaDecDeg(mySearchZoneBmk.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneBmk.magnitudeBox, magMin, magMax);

	mySearchZoneBmk.indexOfFirstDecZone = (int) ((mySearchZoneBmk.subSearchZone.decStartInDeg - DEC_SOUTH_POLE_DEG) / BMK_DEC_ZONE_WIDTH);
	mySearchZoneBmk.indexOfLastDecZone  = (int) ((mySearchZoneBmk.subSearchZone.decEndInDeg   - DEC_SOUTH_POLE_DEG) / BMK_DEC_ZONE_WIDTH);

	if(mySearchZoneBmk.indexOfFirstDecZone >= INDEX_TABLE_DEC_DIMENSION_BMK) {
		mySearchZoneBmk.indexOfFirstDecZone = INDEX_TABLE_DEC_DIMENSION_BMK - 1;
	}
	if(mySearchZoneBmk.indexOfLastDecZone  >= INDEX_TABLE_DEC_DIMENSION_BMK) {
		mySearchZoneBmk.indexOfLastDecZone  = INDEX_TABLE_DEC_DIMENSION_BMK - 1;
	}

	mySearchZoneBmk.indexOfFirstRightAscensionZone = (int)(mySearchZoneBmk.subSearchZone.raStartInDeg / BMK_RA_ZONE_WIDTH);
	mySearchZoneBmk.indexOfLastRightAscensionZone  = (int)(mySearchZoneBmk.subSearchZone.raEndInDeg   / BMK_RA_ZONE_WIDTH);

	return (mySearchZoneBmk);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarBinaryBmk(const starBmk& theStar, const searchZoneBinaryBmk& mySearchZoneBmk) {

	const searchZoneRaDecDeg& subSearchZone  = mySearchZoneBmk.subSearchZone;
	const magnitudeBoxMag& magnitudeBox      = mySearchZoneBmk.magnitudeBox;

	if(
			((subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInDeg) || (theStar.ra <= subSearchZone.raEndInDeg))) ||
					(!subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInDeg) && (theStar.ra <= subSearchZone.raEndInDeg)))) &&
					(theStar.dec >= subSearchZone.decStartInDeg) &&
					(theStar.dec <= subSearchZone.decEndInDeg) &&
					(theStar.magnitude >= magnitudeBox.magnitudeStartInMag) &&
					(theStar.magnitude <= magnitudeBox.magnitudeEndInMag)) {

		return(true);
	}

	return (false);
}

void CCatalog::releaseListOfStarBmk(listOfStarsBmk* listOfStars) {

	elementListBmk* currentElement = listOfStars;
	elementListBmk* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}

