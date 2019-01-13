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
listOfStarsTycho* CCatalog::cstycho2Fast (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfDec;
	int indexOfRa;
	int maximumNumberOfStarsPerZone;
	char catalogCompleteName[1024];

	/* Define the search zone */
	searchZoneBinaryTycho mySearchZoneTycho = findSearchZoneBinaryTycho(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	const indexTableTycho* const * const indexTable = readIndexFileTycho(pathToCatalog, maximumNumberOfStarsPerZone);

	/* Read the catalog */
	sprintf(catalogCompleteName,"%s/%s",pathToCatalog,BINARY_CATALOG_FILE_NAME_TYCHO);

	FILE* inputStream = fopen(catalogCompleteName,"rb");
	if (inputStream  == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Cannot open catalog : %s\n",catalogCompleteName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory for an array in which we put the read stars */
	starTycho* readStars = (starTycho*)malloc(maximumNumberOfStarsPerZone * sizeof(starTycho));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (starTycho) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	elementListTycho* headOfList = NULL;

	for(indexOfDec = mySearchZoneTycho.indexOfFirstDecZone; indexOfDec <= mySearchZoneTycho.indexOfLastDecZone; indexOfDec++) {

		if(mySearchZoneTycho.subSearchZone.isArroundZeroRa) {

			for(indexOfRa = mySearchZoneTycho.indexOfFirstRightAscensionZone; indexOfRa < INDEX_TABLE_RA_DIMENSION_TYCHO; indexOfRa++) {

                if(indexTable[indexOfDec][indexOfRa].numberOfStarsInZone > 0) {
				    processOneZoneTycho(inputStream,indexTable[indexOfDec][indexOfRa],&headOfList,readStars,mySearchZoneTycho);
                }
			}

			for(indexOfRa = 0; indexOfRa <= mySearchZoneTycho.indexOfLastRightAscensionZone; indexOfRa++) {

                if(indexTable[indexOfDec][indexOfRa].numberOfStarsInZone > 0) {
				    processOneZoneTycho(inputStream,indexTable[indexOfDec][indexOfRa],&headOfList,readStars,mySearchZoneTycho);
                }
			}

		} else {

			for(indexOfRa = mySearchZoneTycho.indexOfFirstRightAscensionZone; indexOfRa <= mySearchZoneTycho.indexOfLastRightAscensionZone; indexOfRa++) {

                if(indexTable[indexOfDec][indexOfRa].numberOfStarsInZone > 0) {
				    processOneZoneTycho(inputStream,indexTable[indexOfDec][indexOfRa],&headOfList,readStars,mySearchZoneTycho);
                }
			}
		}
	}

	/* Close the catalog file */
	fclose(inputStream);

	releaseSimpleArray(readStars);
	releaseDoubleArray((void**)indexTable,INDEX_TABLE_DEC_DIMENSION_TYCHO);

	listOfStarsTycho* theStars = headOfList;

	return (theStars);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
void processOneZoneTycho(FILE* const inputStream,const indexTableTycho& oneAccFile,elementListTycho** headOfList,starTycho* const redStars,
		const searchZoneBinaryTycho& mySearchZoneTycho) {

	unsigned int indexOfStar;

	/* Move to this position */
    const int resultOfSeek = fseek(inputStream,oneAccFile.idOfFirstStarInZone * sizeof(starTycho),SEEK_SET);
	if(resultOfSeek != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the amount of stars */
    const unsigned int resultOfRead = fread(redStars,sizeof(starTycho),oneAccFile.numberOfStarsInZone,inputStream);
	if(resultOfRead !=  oneAccFile.numberOfStarsInZone) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (starTycho)\n",oneAccFile.numberOfStarsInZone);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile.numberOfStarsInZone; indexOfStar++) {

		if(isGoodStarBinaryTycho(redStars[indexOfStar], mySearchZoneTycho)) {

			elementListTycho* currentElement   = (elementListTycho*)malloc(sizeof(elementListTycho));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListTycho) out of memory\n");
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
indexTableTycho** readIndexFileTycho(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone) {

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
	indexTableTycho** indexTable;

	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_TYCHO);
	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTable    = (indexTableTycho**)malloc(INDEX_TABLE_DEC_DIMENSION_TYCHO * sizeof(indexTableTycho*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_TYCHO;index++) {
		indexTable[index] = (indexTableTycho*)malloc(INDEX_TABLE_RA_DIMENSION_TYCHO * sizeof(indexTableTycho));
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
		sscanf(temporaryString,FORMAT_INDEX_FILE_TYCHO,&decZoneNumber,&raZoneNumber,&numberOfStars,&numberOfStarsInAllZones);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone = numberOfStars;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].idOfFirstStarInZone = numberOfStarsInAllZones - numberOfStars;

		if(maximumNumberOfStarsPerZone  < numberOfStars) {
			maximumNumberOfStarsPerZone = numberOfStars;
		}
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_TYCHO;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION_TYCHO;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2].numberOfStarsInZone);
			}
		}
	}

	return (indexTable);
}

searchZoneBinaryTycho findSearchZoneBinaryTycho(const double raInDeg,const double decInDeg, const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneBinaryTycho mySearchZoneTycho;

	fillSearchZoneRaDecDeg(mySearchZoneTycho.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneTycho.magnitudeBox, magMin, magMax);

	mySearchZoneTycho.indexOfFirstDecZone = (int) ((mySearchZoneTycho.subSearchZone.decStartInDeg - DEC_SOUTH_POLE_DEG) / TYCHO_DEC_ZONE_WIDTH);
	mySearchZoneTycho.indexOfLastDecZone  = (int) ((mySearchZoneTycho.subSearchZone.decEndInDeg   - DEC_SOUTH_POLE_DEG) / TYCHO_DEC_ZONE_WIDTH);

	if(mySearchZoneTycho.indexOfFirstDecZone >= INDEX_TABLE_DEC_DIMENSION_TYCHO) {
		mySearchZoneTycho.indexOfFirstDecZone = INDEX_TABLE_DEC_DIMENSION_TYCHO - 1;
	}
	if(mySearchZoneTycho.indexOfLastDecZone  >= INDEX_TABLE_DEC_DIMENSION_TYCHO) {
		mySearchZoneTycho.indexOfLastDecZone  = INDEX_TABLE_DEC_DIMENSION_TYCHO - 1;
	}

	mySearchZoneTycho.indexOfFirstRightAscensionZone = (int)(mySearchZoneTycho.subSearchZone.raStartInDeg / TYCHO_RA_ZONE_WIDTH);
	mySearchZoneTycho.indexOfLastRightAscensionZone  = (int)(mySearchZoneTycho.subSearchZone.raEndInDeg   / TYCHO_RA_ZONE_WIDTH);

    if(mySearchZoneTycho.indexOfFirstRightAscensionZone >= INDEX_TABLE_RA_DIMENSION_TYCHO) {
		mySearchZoneTycho.indexOfFirstRightAscensionZone = INDEX_TABLE_RA_DIMENSION_TYCHO - 1;
	}
	if(mySearchZoneTycho.indexOfLastRightAscensionZone  >= INDEX_TABLE_RA_DIMENSION_TYCHO) {
		mySearchZoneTycho.indexOfLastRightAscensionZone  = INDEX_TABLE_RA_DIMENSION_TYCHO - 1;
	}

	return (mySearchZoneTycho);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarBinaryTycho(const starTycho& theStar, const searchZoneBinaryTycho& mySearchZoneTycho) {

	const searchZoneRaDecDeg subSearchZone  = mySearchZoneTycho.subSearchZone;
	const magnitudeBoxMag magnitudeBox      = mySearchZoneTycho.magnitudeBox;

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
