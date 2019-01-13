#include "CCatalog.h"
#include "csucac.h"
/*
 * csucac2.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

listOfStarsUcac2* CCatalog::csucac2(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	elementListUcac2* headOfList = NULL;
	arrayTwoDOfStarUcac2 unFilteredStars;

	/* Define search zone */
	const searchZoneUcac2& mySearchZoneUcac2       = findSearchZoneUcac2(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	const indexTableUcac* const * const indexTable = readIndexFileUcac2(pathToCatalog);

	/* Now read the catalog and retrieve stars */
	const bool notEmpty = retrieveUnfilteredStarsUcac2(pathToCatalog,mySearchZoneUcac2,indexTable,unFilteredStars,&headOfList);

	if(!notEmpty) {
		return (headOfList);
	}

	/* Release the memory */
	releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION_UCAC2);

	listOfStarsUcac2* theStars = headOfList;

	/* Release the memory */
	releaseMemoryArrayTwoDOfStarUcac2(unFilteredStars);

	return (theStars);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
bool isGoodStarUcac2(const starUcac2& oneStar,const searchZoneUcac2& mySearchZoneUcac2) {

	const searchZoneRaDecMas& subSearchZone  = mySearchZoneUcac2.subSearchZone;
	const magnitudeBoxCentiMag& magnitudeBox = mySearchZoneUcac2.magnitudeBox;

	if(
			((subSearchZone.isArroundZeroRa && ((oneStar.raInMas >= subSearchZone.raStartInMas) || (oneStar.raInMas <= subSearchZone.raEndInMas))) ||
					(!subSearchZone.isArroundZeroRa && ((oneStar.raInMas >= subSearchZone.raStartInMas) && (oneStar.raInMas <= subSearchZone.raEndInMas)))) &&
					(oneStar.decInMas >= subSearchZone.decStartInMas) &&
					(oneStar.decInMas <= subSearchZone.decEndInMas) &&
					(oneStar.ucacMagInCentiMag >= magnitudeBox.magnitudeStartInCentiMag) &&
					(oneStar.ucacMagInCentiMag <= magnitudeBox.magnitudeEndInCentiMag)) {

		return(true);
	}

	return (false);
}

/**
 * Retrieve list of stars
 */
bool retrieveUnfilteredStarsUcac2(const char* const pathOfCatalog, const searchZoneUcac2& mySearchZoneUcac2,
		const indexTableUcac* const * const indexTable, arrayTwoDOfStarUcac2& unFilteredStars, elementListUcac2** headOfList) {

	/* We retrieve the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd;
	int numberOfDecZones;

	const searchZoneRaDecMas& subSearchZone  = mySearchZoneUcac2.subSearchZone;

	retrieveIndexesUcac2(mySearchZoneUcac2,indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd);

	numberOfDecZones      = indexZoneDecEnd - indexZoneDecStart + 1;

	/* If RA is around 0, we double the size of the array */
	if(subSearchZone.isArroundZeroRa) {
		numberOfDecZones *= 2;
	}

	unFilteredStars.length        = numberOfDecZones;
	if(numberOfDecZones == 0) {
		return false;
	}

	unFilteredStars.arrayTwoD     = (arrayOneDOfStarUcac2*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac2));
	if(unFilteredStars.arrayTwoD == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfucacStarUcac2*\n",numberOfDecZones);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Retrieve the greatest number of stars per zone */
	int maximumNumberOfStarsPerZone = 0;
	allocateUnfiltredStarUcac2(unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, subSearchZone.isArroundZeroRa, maximumNumberOfStarsPerZone);

	/* Allocate a common array for reading */
	starUcac2* readStars = (starUcac2*)malloc(maximumNumberOfStarsPerZone * sizeof(starUcac2));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : treadStars out of memory %d starUcac2\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we read the un-filtered stars from the catalog */
	readUnfiltredStarUcac2(pathOfCatalog, mySearchZoneUcac2, unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, subSearchZone.isArroundZeroRa, headOfList, readStars);

	if(DEBUG) {
		printUnfilteredStarUcac2(unFilteredStars);
	}

	/* Release readStars */
	releaseSimpleArray(readStars);

	return true;
}

/**
 * Release memory from one arrayTwoDOfucacStarUcac2
 */
void releaseMemoryArrayTwoDOfStarUcac2(const arrayTwoDOfStarUcac2& theTwoDArray) {

	/* UCAC2 stop at dec = +42 deg*/
	if(theTwoDArray.length == 0) {
		return;
	}

	free(theTwoDArray.arrayTwoD);
}

/**
 * Read the stars from the catalog
 */
void readUnfiltredStarUcac2(const char* const pathOfCatalog, const searchZoneUcac2& mySearchZoneUcac2, const arrayTwoDOfStarUcac2& unFilteredStars,
		const indexTableUcac* const * const indexTable, const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart, const char isArroundZeroRa,
		elementListUcac2** headOfList, starUcac2* readStars) {

	int indexDec;
	int counterDec = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, mySearchZoneUcac2, unFilteredStars.arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, indexZoneRaStart, headOfList, readStars);

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, mySearchZoneUcac2, unFilteredStars.arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, 0, headOfList, readStars);

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, mySearchZoneUcac2, unFilteredStars.arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, indexZoneRaStart, headOfList, readStars);

			counterDec++;
		}
	}
}

/**
 * read stars from the catalog for one Dec zone for the un-filtered stars : case of ra not around 0
 */
void readUnfiltredStarForOneDecZoneUcac2(const char* const pathOfCatalog, const searchZoneUcac2& mySearchZoneUcac2, arrayOneDOfStarUcac2& unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec, int indexDec, const int indexZoneRaStart, elementListUcac2** headOfList, starUcac2* readStars) {

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

	FILE* myStream = fopen(completeFileName,"rb");
	if(myStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : unable to open file %s\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Move to starting position */
	if(fseek(myStream,sumOfStarBefore*sizeof(starUcac2),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		fclose(myStream);
		sprintf(outputLogChar,"Error : when moving inside %s\n",completeFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	const int resultOfRead = (int)fread(readStars,sizeof(starUcac2),unFilteredStarsForOneDec.length,myStream);

	unFilteredStarsForOneDec.idOfFirstStarInArray = indexTableForOneDec[indexZoneRaStart].idOfFirstStarInZone;

	fclose(myStream);

	if(resultOfRead != unFilteredStarsForOneDec.length) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : resultOfRead = %d != sumOfStarToRead = %d\n",resultOfRead,unFilteredStarsForOneDec.length);
		throw CanNotReadInStreamException(outputLogChar);
	}

	int idOfStar = unFilteredStarsForOneDec.idOfFirstStarInArray;
	elementListUcac2* currentElement;

	for(int index = 0; index <unFilteredStarsForOneDec.length; index++) {

		idOfStar++;

		if(isGoodStarUcac2(readStars[index],mySearchZoneUcac2)) {

			currentElement           = (elementListUcac2*)malloc(sizeof(elementListUcac2));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListUcac2) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}
			currentElement->theStar  = readStars[index];
			currentElement->id       = idOfStar;
			currentElement->nextStar = *headOfList;
			*headOfList              = currentElement;
		}
	}
}

/**
 * Allocate memory for one Dec zone for the un-filtered stars : case of ra not around 0
 */
void allocateUnfiltredStarUcac2(arrayTwoDOfStarUcac2& unFilteredStars, const indexTableUcac* const * const indexTable, const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa, int& maximumNumberOfStarsPerZone) {

	int indexDec;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			allocateUnfiltredStarForOneDecZoneUcac2(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexZoneRaStart, lastZoneRa, maximumNumberOfStarsPerZone);

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			allocateUnfiltredStarForOneDecZoneUcac2(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], 0, indexZoneRaEnd, maximumNumberOfStarsPerZone);

			counterDec++;

			//printf("1) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			allocateUnfiltredStarForOneDecZoneUcac2(unFilteredStars.arrayTwoD[counterDec],indexTable[indexDec], indexZoneRaStart,indexZoneRaEnd, maximumNumberOfStarsPerZone);

			counterDec++;
			//printf("2) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}
	}
}

/**
 * Allocate memory for one Dec zone for the un-filtered stars
 */
void allocateUnfiltredStarForOneDecZoneUcac2(arrayOneDOfStarUcac2& unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
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
void retrieveIndexesUcac2(const searchZoneUcac2& mySearchZoneUcac2,int& indexZoneDecStart,int& indexZoneDecEnd,	int& indexZoneRaStart,int& indexZoneRaEnd) {

	const searchZoneRaDecMas& subSearchZone = mySearchZoneUcac2.subSearchZone;

	/* dec start */
	indexZoneDecStart     = (int)((subSearchZone.decStartInMas - DEC_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC2AND3);
	if(indexZoneDecStart  < 0) {
		indexZoneDecStart = 0;
	}

	/* dec end */
	indexZoneDecEnd       = (int)((subSearchZone.decEndInMas - DEC_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC2AND3);
	if(indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION_UCAC2) {
		indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION_UCAC2 - 1;
	}

	/* Because UCAC2 is not covering the whole sky */
	if(indexZoneDecStart  > indexZoneDecEnd) {
		indexZoneDecStart = indexZoneDecEnd;
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
indexTableUcac** readIndexFileUcac2(const char* const pathOfCatalog) {

	int index;
	int numberOfStarsInZone;
	int numberOfStarsInPreviousZones;
	int numberOfAccumulatedStars;
	int decZoneNumber;
	int raZoneNumber;
	int index2;
	double tempDouble;
	char completeFileName[STRING_COMMON_LENGTH];
	char temporaryString[STRING_COMMON_LENGTH];
	char* temporaryPointer;

	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_UCAC2);

	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		throw FileNotFoundException(outputLogChar);
	}

	/* Allocate memory */
	indexTableUcac** indexTable = (indexTableUcac**)malloc(INDEX_TABLE_DEC_DIMENSION_UCAC2 * sizeof(indexTableUcac*));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC2; index++) {
		indexTable[index] = (indexTableUcac*)malloc(INDEX_TABLE_RA_DIMENSION_UCAC2AND3 * sizeof(indexTableUcac));
		if(indexTable[index] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Error : indexTable[%d] out of memory\n",index);
			throw InsufficientMemoryException(outputLogChar);
		}
	}

	/* Read the header file */
	for(index = 0; index < INDEX_FILE_HEADER_NUMBER_OF_LINES_UCAC2; index++) {
		if (fgets(temporaryString , STRING_COMMON_LENGTH , tableStream) == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Error : Can not read line from %s\n",completeFileName);
			throw CanNotReadInStreamException(outputLogChar);
		}
	}

	/* Now we read the remaining content */
	while(!feof(tableStream)) {

		temporaryPointer = fgets(temporaryString , STRING_COMMON_LENGTH , tableStream);
		if(temporaryPointer == NULL) {
			break;
		}
		sscanf(temporaryString,FORMAT_INDEX_FILE_UCAC2,&numberOfStarsInZone,&numberOfStarsInPreviousZones,
				&numberOfAccumulatedStars,&decZoneNumber,&raZoneNumber,&tempDouble,&tempDouble);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone = numberOfStarsInZone;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].idOfFirstStarInZone = numberOfAccumulatedStars - numberOfStarsInZone;
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC2; index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION_UCAC2AND3; index2++) {
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
searchZoneUcac2 findSearchZoneUcac2(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneUcac2 mySearchZoneUcac2;

	fillSearchZoneRaDecMas(mySearchZoneUcac2.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxCentiMag(mySearchZoneUcac2.magnitudeBox, magMin, magMax);

	return (mySearchZoneUcac2);
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac2(const arrayTwoDOfStarUcac2& unFilteredStars) {

	arrayOneDOfStarUcac2* arrayTwoD = unFilteredStars.arrayTwoD;

	printf("The un-filtered stars are :\n");

	for(int indexDec = 0; indexDec < unFilteredStars.length; indexDec++) {

		arrayOneDOfStarUcac2& oneSetOfStar = arrayTwoD[indexDec];

		printf("	indexDec = %d - length = %d\n",indexDec,oneSetOfStar.length);
	}
}

void CCatalog::releaseListOfStarUcac2(listOfStarsUcac2* listOfStars) {

	elementListUcac2* currentElement = listOfStars;
	elementListUcac2* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
