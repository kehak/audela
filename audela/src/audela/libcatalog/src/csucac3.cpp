#include "CCatalog.h"
#include "csucac.h"
/*
 * csucac3.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

listOfStarsUcac3* CCatalog::csucac3(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	elementListUcac3* headOfList = NULL;
	arrayTwoDOfStarUcac3 unFilteredStars;

	/* Define search zone */
	const searchZoneUcac3And4& mySearchZoneUcac3   = findSearchZoneUcac3And4(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	const indexTableUcac* const * const indexTable = readIndexFileUcac3(pathToCatalog);

	/* Now read the catalog and retrieve stars */
	retrieveUnfilteredStarsUcac3(pathToCatalog,mySearchZoneUcac3,indexTable,unFilteredStars,&headOfList);

	/* Release the memory */
	releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION_UCAC3);

	listOfStarsUcac3* theStars = headOfList;

	/* Release the memory */
	releaseMemoryArrayTwoDOfStarUcac3(unFilteredStars);

	return (theStars);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarUcac3(const starUcac3& oneStar,const searchZoneUcac3And4& mySearchZoneUcac3) {

	const searchZoneRaSpdMas& subSearchZone  = mySearchZoneUcac3.subSearchZone;
	const magnitudeBoxMilliMag& magnitudeBox = mySearchZoneUcac3.magnitudeBox;

	if(
			((subSearchZone.isArroundZeroRa && ((oneStar.raInMas >= subSearchZone.raStartInMas) || (oneStar.raInMas <= subSearchZone.raEndInMas))) ||
					(!subSearchZone.isArroundZeroRa && ((oneStar.raInMas >= subSearchZone.raStartInMas) && (oneStar.raInMas <= subSearchZone.raEndInMas)))) &&
					(oneStar.distanceToSouthPoleInMas  >= subSearchZone.spdStartInMas) &&
					(oneStar.distanceToSouthPoleInMas  <= subSearchZone.spdEndInMas) &&
					(oneStar.ucacApertureMagInMilliMag >= magnitudeBox.magnitudeStartInMilliMag) &&
					(oneStar.ucacApertureMagInMilliMag <= magnitudeBox.magnitudeEndInMilliMag)) {

		return (true);
	}

	return (false);
}

/**
 * Retrieve list of stars
 */
void retrieveUnfilteredStarsUcac3(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac3, const indexTableUcac* const * const indexTable,
		arrayTwoDOfStarUcac3& unFilteredStars, elementListUcac3** headOfList) {

	/* We retrieve the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd;
	int numberOfDecZones;

	const searchZoneRaSpdMas& subSearchZone  = mySearchZoneUcac3.subSearchZone;

	retrieveIndexesUcac3(mySearchZoneUcac3,indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd);

	numberOfDecZones      = indexZoneDecEnd - indexZoneDecStart + 1;
	/* If ra is around 0, we double the size of the array */
	if(subSearchZone.isArroundZeroRa) {
		numberOfDecZones *= 2;
	}

	unFilteredStars.length        = numberOfDecZones;
	if(numberOfDecZones == 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Warn : no stars in the selected zone\n");
		throw InvalidDataException(outputLogChar);
	}
	unFilteredStars.arrayTwoD     = (arrayOneDOfStarUcac3*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac3));
	if(unFilteredStars.arrayTwoD == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfUcacStar*\n",numberOfDecZones);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Retrieve the greatest number of stars per zone */
	int maximumNumberOfStarsPerZone = 0;
	allocateUnfiltredStarUcac3(unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, subSearchZone.isArroundZeroRa, maximumNumberOfStarsPerZone);

	/* Allocate a common array for reading */
	starUcac3* readStars = (starUcac3*)malloc(maximumNumberOfStarsPerZone * sizeof(starUcac3));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : treadStars out of memory %d starUcac3\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we read the un-filtered stars from the catalog */
	readUnfiltredStarUcac3(pathOfCatalog, mySearchZoneUcac3, unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, subSearchZone.isArroundZeroRa, headOfList, readStars);

	if(DEBUG) {
		printUnfilteredStarUcac3(unFilteredStars);
	}

	/* Release readStars */
	releaseSimpleArray(readStars);
}

/**
 * Release memory from one arrayTwoDOfUcacStarUcac3
 */
void releaseMemoryArrayTwoDOfStarUcac3(const arrayTwoDOfStarUcac3& theTwoDArray) {

	/* UCAC2 stop at dec = +42 deg*/
	if(theTwoDArray.length == 0) {
		return;
	}

	free(theTwoDArray.arrayTwoD);
}

/**
 * Read the stars from the catalog
 */
void readUnfiltredStarUcac3(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac3, const arrayTwoDOfStarUcac3& unFilteredStars,
		const indexTableUcac* const * const indexTable, const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,
		const char isArroundZeroRa, elementListUcac3** headOfList, starUcac3* readStars) {

	int indexDec;
	int counterDec   = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, mySearchZoneUcac3, unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexDec, indexZoneRaStart, headOfList, readStars);

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, mySearchZoneUcac3, unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexDec, 0, headOfList, readStars);

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, mySearchZoneUcac3, unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexDec, indexZoneRaStart, headOfList, readStars);

			counterDec++;
		}
	}
}

/**
 * read stars from the catalog for one Dec zone for the un-filtered stars : case of ra not around 0
 */
void readUnfiltredStarForOneDecZoneUcac3(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac3, arrayOneDOfStarUcac3& unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec,int indexDec, const int indexZoneRaStart, elementListUcac3** headOfList, starUcac3* readStars) {

	char completeFileName[1024];
	int indexRa;
	int sumOfStarBefore;

	if(unFilteredStarsForOneDec.length == 0) {
		return;
	}

	sumOfStarBefore      = 0;
	for(indexRa          = 0; indexRa < indexZoneRaStart; indexRa++) {
		sumOfStarBefore += indexTableForOneDec[indexRa].numberOfStarsInZone;
	}

	/* Open the file */
	indexDec++; //Names start with 1 not 0
	sprintf(completeFileName,ZONE_FILE_FORMAT_NAME_UCAC2AND3,pathOfCatalog,indexDec);

	//printf("completeFileName = %s\n",completeFileName);
	FILE* myStream = fopen(completeFileName,"rb");

	if(myStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : unable to open file %s\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Move to starting position */
	if(fseek(myStream,sumOfStarBefore*sizeof(starUcac3),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : when moving inside %s\n",completeFileName);
		fclose(myStream);
		throw CanNotReadInStreamException(outputLogChar);
	}

	const int resultOfRead = (int)fread(readStars,sizeof(starUcac3),unFilteredStarsForOneDec.length,myStream);

	unFilteredStarsForOneDec.idOfFirstStarInArray = indexTableForOneDec[indexZoneRaStart].idOfFirstStarInZone;
	unFilteredStarsForOneDec.indexDec             = indexDec;

	fclose(myStream);

	if(resultOfRead != unFilteredStarsForOneDec.length) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : resultOfRead = %d != sumOfStarToRead = %d\n",resultOfRead,unFilteredStarsForOneDec.length);
		throw CanNotReadInStreamException(outputLogChar);
	}

	int idOfStar = unFilteredStarsForOneDec.idOfFirstStarInArray;
	elementListUcac3* currentElement;

	for(int index = 0; index <unFilteredStarsForOneDec.length; index++) {

		idOfStar++;

		if(isGoodStarUcac3(readStars[index],mySearchZoneUcac3)) {

			currentElement           = (elementListUcac3*)malloc(sizeof(elementListUcac3));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListUcac3) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}
			currentElement->theStar  = readStars[index];
			currentElement->id       = idOfStar;
			currentElement->indexDec = unFilteredStarsForOneDec.indexDec;
			currentElement->nextStar = *headOfList;
			*headOfList              = currentElement;
		}
	}
}

/**
 * Allocate memory for one Dec zone for the un-filtered stars : case of ra not around 0
 */
void allocateUnfiltredStarUcac3(arrayTwoDOfStarUcac3& unFilteredStars, const indexTableUcac* const * const indexTable, const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa, int& maximumNumberOfStarsPerZone) {

	int indexDec;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			allocateUnfiltredStarForOneDecZoneUcac3(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexZoneRaStart, lastZoneRa, maximumNumberOfStarsPerZone);

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			allocateUnfiltredStarForOneDecZoneUcac3(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], 0, indexZoneRaEnd, maximumNumberOfStarsPerZone);

			counterDec++;

			//printf("1) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			allocateUnfiltredStarForOneDecZoneUcac3(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexZoneRaStart,indexZoneRaEnd, maximumNumberOfStarsPerZone);

			counterDec++;
			//printf("2) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}
	}
}

/**
 * Allocate memory for one Dec zone for the un-filtered stars
 */
void allocateUnfiltredStarForOneDecZoneUcac3(arrayOneDOfStarUcac3& unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd, int& maximumNumberOfStarsPerZone) {

	int indexRa;
	int sumOfStars  = 0;

	for(indexRa     = indexZoneRaStart; indexRa <= indexZoneRaEnd; indexRa++) {
		sumOfStars += indexTableForOneDec[indexRa].numberOfStarsInZone;
	}

	unFilteredStarsForOneDec.length = sumOfStars;

	if(maximumNumberOfStarsPerZone  < sumOfStars) {
		maximumNumberOfStarsPerZone = sumOfStars;
	}
}

/**
 * We retrive the index of all used file zones
 */
void retrieveIndexesUcac3(const searchZoneUcac3And4& mySearchZoneUcac3,int& indexZoneDecStart,int& indexZoneDecEnd, int& indexZoneRaStart,int& indexZoneRaEnd) {

	const searchZoneRaSpdMas& subSearchZone  = mySearchZoneUcac3.subSearchZone;

	/* dec start */
	indexZoneDecStart     = (int)((subSearchZone.spdStartInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC2AND3);
	if(indexZoneDecStart  < 0) {
		indexZoneDecStart = 0;
	}

	/* dec end */
	indexZoneDecEnd       = (int)((subSearchZone.spdEndInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC2AND3);
	if(indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION_UCAC3) {
		indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION_UCAC3 - 1;
	}

	/* ra start */
	indexZoneRaStart     = (int)((subSearchZone.raStartInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC2AND3);
	if(indexZoneDecStart < 0) {
		indexZoneRaStart = 0;
	}

	/* ra end */
	indexZoneRaEnd     = (int)((subSearchZone.raEndInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC2AND3);
	if(indexZoneRaEnd >= INDEX_TABLE_RA_DIMENSION_UCAC2AND3) {
		indexZoneRaEnd = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	}
}

/**
 * Read the index file
 */
indexTableUcac** readIndexFileUcac3(const char* const pathOfCatalog) {

	char completeFileName[STRING_COMMON_LENGTH];
	char temporaryString[STRING_COMMON_LENGTH];
	char* temporaryPointer;
	int index;
	int numberOfStars;
	int decZoneNumber;
	int raZoneNumber;
	int numberOfStarsInPreviousZones;
	int index2;
	double tempDouble;
	indexTableUcac** indexTable;

	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_UCAC3);
	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTable    = (indexTableUcac**)malloc(INDEX_TABLE_DEC_DIMENSION_UCAC3 * sizeof(indexTableUcac*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC3;index++) {
		indexTable[index] = (indexTableUcac*)malloc(INDEX_TABLE_RA_DIMENSION_UCAC2AND3 * sizeof(indexTableUcac));
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
		sscanf(temporaryString,FORMAT_INDEX_FILE_UCAC3AND4,&numberOfStarsInPreviousZones,&numberOfStars,&decZoneNumber,&raZoneNumber,&tempDouble);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone = numberOfStars;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].idOfFirstStarInZone = numberOfStarsInPreviousZones;
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC3;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION_UCAC2AND3;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2].numberOfStarsInZone);
			}
		}
	}

	return (indexTable);
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 *
 */
searchZoneUcac3And4 findSearchZoneUcac3And4(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneUcac3And4 mySearchZoneUcac3;

	fillSearchZoneRaSpdMas(mySearchZoneUcac3.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(mySearchZoneUcac3.magnitudeBox, magMin, magMax);

	return (mySearchZoneUcac3);
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac3(const arrayTwoDOfStarUcac3& unFilteredStars) {

	arrayOneDOfStarUcac3* arrayTwoD = unFilteredStars.arrayTwoD;

	printf("The un-filtered stars are :\n");

	for(int indexDec = 0; indexDec < unFilteredStars.length; indexDec++) {

		arrayOneDOfStarUcac3& oneSetOfStar = arrayTwoD[indexDec];

		printf("	indexDec = %d - length = %d\n",indexDec,oneSetOfStar.length);
	}
}

void CCatalog::releaseListOfStarUcac3(listOfStarsUcac3* listOfStars) {

	elementListUcac3* currentElement = listOfStars;
	elementListUcac3* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
