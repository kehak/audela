#include "CCatalog.h"
#include "csucac.h"

/*
 * csucac4.c
 *
 *  Created on: Nov 04, 2012
 *      Author: Y. Damerdji
 */

listOfStarsUcac4* CCatalog::csucac4(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	elementListUcac4* headOfList = NULL;
	arrayTwoDOfStarUcac4 unFilteredStars;

	/* Define search zone */
	const searchZoneUcac3And4& mySearchZoneUcac4   = findSearchZoneUcac3And4(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	const indexTableUcac* const * const indexTable = readIndexFileUcac4(pathToCatalog);

	/* Now read the catalog and retrieve stars */
	retrieveUnfilteredStarsUcac4(pathToCatalog,mySearchZoneUcac4,indexTable,unFilteredStars,&headOfList);

	/* Release the memory */
	releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION_UCAC4);

	listOfStarsUcac4* theStars = headOfList;

	/* Release the memory */
	releaseMemoryArrayTwoDOfStarUcac4(unFilteredStars);

	return (theStars);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarUcac4(const starUcac4& oneStar,const searchZoneUcac3And4& mySearchZoneUcac4) {

	const searchZoneRaSpdMas& subSearchZone  = mySearchZoneUcac4.subSearchZone;
	const magnitudeBoxMilliMag& magnitudeBox = mySearchZoneUcac4.magnitudeBox;

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
void retrieveUnfilteredStarsUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac4,
		const indexTableUcac* const * const indexTable,arrayTwoDOfStarUcac4& unFilteredStars, elementListUcac4** headOfList) {

	/* We retrieve the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd;
	int numberOfDecZones;

	const searchZoneRaSpdMas subSearchZone  = mySearchZoneUcac4.subSearchZone;

	retrieveIndexesUcac4(mySearchZoneUcac4,indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd);

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
	unFilteredStars.arrayTwoD     = (arrayOneDOfStarUcac4*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac4));
	if(unFilteredStars.arrayTwoD == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfUcacStar*\n",numberOfDecZones);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Retrieve the greatest number of stars per zone */
	int maximumNumberOfStarsPerZone = 0;
	allocateUnfiltredStarUcac4(unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, subSearchZone.isArroundZeroRa, maximumNumberOfStarsPerZone);

	/* Allocate a common array for reading */
	starUcac4* readStars = (starUcac4*)malloc(maximumNumberOfStarsPerZone * sizeof(starUcac4));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : treadStars out of memory %d starUcac4\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we read the un-filtered stars from the catalog */
	readUnfiltredStarUcac4(pathOfCatalog, mySearchZoneUcac4, unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, subSearchZone.isArroundZeroRa, headOfList, readStars);

	if(DEBUG) {
		printUnfilteredStarUcac4(unFilteredStars);
	}

	/* Release readStars */
	releaseSimpleArray(readStars);
}

/**
 * Release memory from one arrayTwoDOfUcacStarUcac4
 */
void releaseMemoryArrayTwoDOfStarUcac4(const arrayTwoDOfStarUcac4& theTwoDArray) {

	/* UCAC2 stop at dec = +42 deg*/
	if(theTwoDArray.length == 0) {
		return;
	}

	free(theTwoDArray.arrayTwoD);
}

/**
 * Read the stars from the catalog
 */
void readUnfiltredStarUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac4, const arrayTwoDOfStarUcac4& unFilteredStars,
		const indexTableUcac* const * const indexTable, const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,
		const char isArroundZeroRa, elementListUcac4** headOfList, starUcac4* readStars) {

	int indexDec;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			readUnfiltredStarForOneDecZoneUcac4(pathOfCatalog, mySearchZoneUcac4, unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexDec, indexZoneRaStart, headOfList, readStars);

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			readUnfiltredStarForOneDecZoneUcac4(pathOfCatalog, mySearchZoneUcac4, unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexDec, 0, headOfList, readStars);

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			readUnfiltredStarForOneDecZoneUcac4(pathOfCatalog, mySearchZoneUcac4, unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexDec, indexZoneRaStart, headOfList, readStars);

			counterDec++;
		}
	}
}

/**
 * read stars from the catalog for one Dec zone for the un-filtered stars : case of ra not around 0
 */
void readUnfiltredStarForOneDecZoneUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac4, arrayOneDOfStarUcac4& unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec,int indexDec, const int indexZoneRaStart, elementListUcac4** headOfList, starUcac4* readStars) {

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
	sprintf(completeFileName,ZONE_FILE_FORMAT_NAME_UCAC4,pathOfCatalog,indexDec);

	//printf("completeFileName = %s\n",completeFileName);
	FILE* myStream = fopen(completeFileName,"rb");

	if(myStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : unable to open file %s\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Move to starting position */
	if(fseek(myStream,sumOfStarBefore*sizeof(starUcac4),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : when moving inside %s\n",completeFileName);
		fclose(myStream);
		throw CanNotReadInStreamException(outputLogChar);
	}

	const int resultOfRead = (int)fread(readStars,sizeof(starUcac4),unFilteredStarsForOneDec.length,myStream);

	unFilteredStarsForOneDec.idOfFirstStarInArray = indexTableForOneDec[indexZoneRaStart].idOfFirstStarInZone;
	unFilteredStarsForOneDec.indexDec             = indexDec;

	fclose(myStream);

	if(resultOfRead != unFilteredStarsForOneDec.length) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : resultOfRead = %d != sumOfStarToRead = %d\n",resultOfRead,unFilteredStarsForOneDec.length);
		throw CanNotReadInStreamException(outputLogChar);
	}

	int idOfStar = unFilteredStarsForOneDec.idOfFirstStarInArray;
	elementListUcac4* currentElement;

	for(int index = 0; index <unFilteredStarsForOneDec.length; index++) {

		idOfStar++;

		if(isGoodStarUcac4(readStars[index],mySearchZoneUcac4)) {

			currentElement           = (elementListUcac4*)malloc(sizeof(elementListUcac4));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListUcac4) out of memory\n");
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
void allocateUnfiltredStarUcac4(const arrayTwoDOfStarUcac4& unFilteredStars, const indexTableUcac* const * const indexTable, const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa, int& maximumNumberOfStarsPerZone) {

	int indexDec;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			allocateUnfiltredStarForOneDecZoneUcac4(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexZoneRaStart, lastZoneRa, maximumNumberOfStarsPerZone);

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			allocateUnfiltredStarForOneDecZoneUcac4(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], 0, indexZoneRaEnd, maximumNumberOfStarsPerZone);

			counterDec++;

			//printf("1) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			allocateUnfiltredStarForOneDecZoneUcac4(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexZoneRaStart,indexZoneRaEnd, maximumNumberOfStarsPerZone);

			counterDec++;
			//printf("2) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}
	}
}

/**
 * Allocate memory for one Dec zone for the un-filtered stars
 */
void allocateUnfiltredStarForOneDecZoneUcac4(arrayOneDOfStarUcac4& unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
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
void retrieveIndexesUcac4(const searchZoneUcac3And4& mySearchZoneUcac4,int& indexZoneDecStart,int& indexZoneDecEnd,int& indexZoneRaStart,int& indexZoneRaEnd) {

	const searchZoneRaSpdMas& subSearchZone  = mySearchZoneUcac4.subSearchZone;

	/* dec start */
	indexZoneDecStart     = (int)((subSearchZone.spdStartInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC4);
	if(indexZoneDecStart  < 0) {
		indexZoneDecStart = 0;
	}

	/* dec end */
	indexZoneDecEnd       = (int)((subSearchZone.spdEndInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC4);
	if(indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION_UCAC4) {
		indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION_UCAC4 - 1;
	}

	/* ra start */
	indexZoneRaStart     = (int)((subSearchZone.raStartInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC4);
	if(indexZoneDecStart < 0) {
		indexZoneRaStart = 0;
	}

	/* ra end */
	indexZoneRaEnd     = (int)((subSearchZone.raEndInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC4);
	if(indexZoneRaEnd >= INDEX_TABLE_RA_DIMENSION_UCAC4) {
		indexZoneRaEnd = INDEX_TABLE_RA_DIMENSION_UCAC4 - 1;
	}
}

/**
 * Read the index file
 */
indexTableUcac** readIndexFileUcac4(const char* const pathOfCatalog) {

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

	sprintf(completeFileName,"%s%s",pathOfCatalog,INDEX_FILE_NAME_UCAC4);
	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTable    = (indexTableUcac**)malloc(INDEX_TABLE_DEC_DIMENSION_UCAC4 * sizeof(indexTableUcac*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC4;index++) {
		indexTable[index] = (indexTableUcac*)malloc(INDEX_TABLE_RA_DIMENSION_UCAC4 * sizeof(indexTableUcac));
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
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC4;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION_UCAC4;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2].numberOfStarsInZone);
			}
		}
	}

	return (indexTable);
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac4(const arrayTwoDOfStarUcac4& unFilteredStars) {

	arrayOneDOfStarUcac4* arrayTwoD = unFilteredStars.arrayTwoD;

	printf("The un-filtered stars are :\n");

	for(int indexDec = 0; indexDec < unFilteredStars.length; indexDec++) {

		arrayOneDOfStarUcac4& oneSetOfStar = arrayTwoD[indexDec];

		printf("	indexDec = %d - length = %d\n",indexDec,oneSetOfStar.length);
	}
}

void CCatalog::releaseListOfStarUcac4(listOfStarsUcac4* listOfStars) {

	elementListUcac4* currentElement = listOfStars;
	elementListUcac4* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}

