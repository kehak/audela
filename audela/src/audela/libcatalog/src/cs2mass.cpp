#include "CCatalog.h"
#include "cs2mass.h"
/*
 * cs2mass.c
 *
 *  Created on: Nov 05, 2012
 *      Author: Y. Damerdji
 */

listOfStars2Mass* CCatalog::cs2mass (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int maximumNumberOfStarsPerZone;
	int indexOfRA;
	int indexOfCatalog;
	int isBadAccFile;
	char shortName[1024];
	char fileName[1024];
	FILE* inputStream;

	/* Define search zone */
	const searchZone2Mass& mySearchZone2Mass = findSearchZone2Mass(ra,dec,radius,magMin,magMax);

	/* Read all catalog files to be able to deliver an ID for each star */
	const indexTable2Mass* const allAccFiles = readIndexFile2Mass(pathToCatalog,mySearchZone2Mass,maximumNumberOfStarsPerZone);

	if(maximumNumberOfStarsPerZone <= 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"maximumNumberOfStarsPerZone = %d should be > 0\n",maximumNumberOfStarsPerZone);
		throw InvalidDataException(outputLogChar);
	}

	/* Allocate memory for an array in which we put the read stars */
	star2MassRaw* readStars = (star2MassRaw*)malloc(maximumNumberOfStarsPerZone * sizeof(star2MassRaw));
	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (star2Mass) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	elementList2Mass* headOfList = NULL;

	for(indexOfCatalog = mySearchZone2Mass.indexOfFirstDecZone; indexOfCatalog <= mySearchZone2Mass.indexOfLastDecZone; indexOfCatalog++) {

		/* Open the CAT file (.acc) */
		sprintf(shortName,CATALOG_NAME_FORMAT,allAccFiles[indexOfCatalog].prefix,allAccFiles[indexOfCatalog].indexOfCatalog);
		sprintf(fileName,"%s%s%s",pathToCatalog,shortName,DOT_CAT_EXTENSION);

		inputStream = fopen(fileName,"rb");
		if(inputStream == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"%s not found\n",fileName);
			throw FileNotFoundException(outputLogChar);
		}

		/* The first and the last accelerator files are empty (m000TMASS.acc and p899TMASS.acc) : process one RA box only
		 * THIS ADDITIONAL CONDITION WILL BE REMOVED AFTER THE BAD ACC FILES WILL BE CORRECTED */
		isBadAccFile = ((allAccFiles[indexOfCatalog].prefix == SOUTH_HEMISPHERE_PREFIX) &&
				(allAccFiles[indexOfCatalog].indexOfCatalog == 0)) ||
						((allAccFiles[indexOfCatalog].prefix == NORTH_HEMISPHERE_PREFIX) &&
								(allAccFiles[indexOfCatalog].indexOfCatalog == HALF_NUMBER_OF_CATALOG_FILES_2MASS_MINUS_ONE));

		if(mySearchZone2Mass.subSearchZone.isArroundZeroRa) {

			/* process one RA box only */
			if(isBadAccFile) {

				processOneZone2MassCentredOnZeroRA(inputStream,allAccFiles[indexOfCatalog],&headOfList,readStars,mySearchZone2Mass,
						mySearchZone2Mass.indexOfFirstRightAscensionZone);

			} else {

				for(indexOfRA = mySearchZone2Mass.indexOfFirstRightAscensionZone; indexOfRA < ACC_FILE_NUMBER_OF_LINES; indexOfRA++) {

					processOneZone2MassCentredOnZeroRA(inputStream,allAccFiles[indexOfCatalog],&headOfList,readStars,mySearchZone2Mass,
							indexOfRA);
				}

				for(indexOfRA = 0; indexOfRA <= mySearchZone2Mass.indexOfLastRightAscensionZone; indexOfRA++) {

					processOneZone2MassCentredOnZeroRA(inputStream,allAccFiles[indexOfCatalog],&headOfList,readStars,mySearchZone2Mass,
							indexOfRA);
				}
			}

		} else {

			/* process one RA box only */
			if(isBadAccFile) {

				processOneZone2MassNotCentredOnZeroRA(inputStream,allAccFiles[indexOfCatalog],&headOfList,readStars,mySearchZone2Mass,
						mySearchZone2Mass.indexOfFirstRightAscensionZone);

			} else {

				for(indexOfRA = mySearchZone2Mass.indexOfFirstRightAscensionZone; indexOfRA <= mySearchZone2Mass.indexOfLastRightAscensionZone; indexOfRA++) {

					processOneZone2MassNotCentredOnZeroRA(inputStream,allAccFiles[indexOfCatalog],&headOfList,readStars,mySearchZone2Mass,
							indexOfRA);
				}
			}
		}

		fclose(inputStream);
	}

	/* Release memory */
	freeAll2MassCatalogFiles(allAccFiles,mySearchZone2Mass);
	releaseSimpleArray(readStars);

	listOfStars2Mass* theStars   = headOfList;

	return (theStars);
}

star2Mass convertStar2Mass(const star2MassRaw& theStar2MassRaw) {

	star2Mass theStar2Mass;
	char sign;
	int raHour,raMinute,raSeconds;
	double raHourDouble,raMinuteDouble,raSecondsDouble;
	int decDegree,decMinute,decSeconds;
	double absDecInDegDouble,decMinuteDouble,decSecondsDouble;

	theStar2Mass.ra               = (double)theStar2MassRaw.raInMicroDegree  / DEG2MICRODEG;
	theStar2Mass.dec              = (double)theStar2MassRaw.decInMicroDegree / DEG2MICRODEG;
	theStar2Mass.magnitudeJ       = (double)theStar2MassRaw.jMagInMilliMag / MAG2MILLIMAG;
	theStar2Mass.magnitudeH       = (double)theStar2MassRaw.hMagInMilliMag / MAG2MILLIMAG;
	theStar2Mass.magnitudeK       = (double)theStar2MassRaw.kMagInMilliMag / MAG2MILLIMAG;
	theStar2Mass.errorMagnitudeJ  = (double)theStar2MassRaw.jErrorMagInCentiMag / MAG2CENTIMAG;
	theStar2Mass.errorMagnitudeH  = (double)theStar2MassRaw.hErrorMagInCentiMag / MAG2CENTIMAG;
	theStar2Mass.errorMagnitudeK  = (double)theStar2MassRaw.kErrorMagInCentiMag / MAG2CENTIMAG;
	theStar2Mass.jd               = (double)theStar2MassRaw.jd / 1.e4 + 2451.0e3;

	raHourDouble       = theStar2Mass.ra / HOUR2DEG;
	raHour             = (int) raHourDouble;
	raMinuteDouble     = (raHourDouble - raHour) * DEG2ARCMIN;
	raMinute           = (int) raMinuteDouble;
	raSecondsDouble    = (raMinuteDouble - raMinute) * DEG2ARCMIN;
	/* 2Mass Ids in Aladin are coded using the floor function instead of round */
	raSeconds          = (int) floor(100. * raSecondsDouble);

	absDecInDegDouble  = fabs(theStar2Mass.dec);
	decDegree          = (int) absDecInDegDouble;
	decMinuteDouble    = (absDecInDegDouble - decDegree) * DEG2ARCMIN;
	decMinute          = (int) decMinuteDouble;
	decSecondsDouble   = (decMinuteDouble - decMinute) * DEG2ARCMIN;
	/* 2Mass Ids in Aladin are coded using the floor function instead of round */
	decSeconds         = (int) floor(10. * decSecondsDouble);

	sign                       = '+';
	if(theStar2Mass.dec  < 0.) {
		sign                   = '-';
	}

	theStar2Mass.errorDec = (double)(theStar2MassRaw.errorOnCoordinates % 100) /100.;
	theStar2Mass.errorRa  = ((double)theStar2MassRaw.errorOnCoordinates - theStar2Mass.errorDec) / 10000.;

	sprintf(theStar2Mass.id,OUTPUT_ID_FORMAT,raHour,raMinute,raSeconds,sign,decDegree,decMinute,decSeconds);

	return (theStar2Mass);
}

/****************************************************************************/
/* Process one RA-DEC zone centered on zero ra                              */
/****************************************************************************/
void processOneZone2MassCentredOnZeroRA(FILE* const inputStream,const indexTable2Mass& oneAccFile,elementList2Mass** headOfList,star2MassRaw* const redStars,
		const searchZone2Mass& mySearchZone2Mass, const int indexOfRA) {

	unsigned int indexOfStar;

	const searchZoneRaDecMicroDeg& subSearchZone = mySearchZone2Mass.subSearchZone;
	const magnitudeBoxMilliMag& magnitudeBox     = mySearchZone2Mass.magnitudeBox;

	/* Move to this position */
	if(fseek(inputStream,oneAccFile.idOfFirstStarInZone[indexOfRA] * sizeof(star2MassRaw),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the amount of stars */
	if(fread(redStars,sizeof(star2MassRaw),oneAccFile.numberOfStarsInZone[indexOfRA],inputStream) !=  oneAccFile.numberOfStarsInZone[indexOfRA]) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (star2Mass)\n",oneAccFile.numberOfStarsInZone[indexOfRA]);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile.numberOfStarsInZone[indexOfRA]; indexOfStar++) {

		star2MassRaw& theStar = redStars[indexOfStar];

		if ((theStar.raInMicroDegree < subSearchZone.raStartInMicroDegree) && (theStar.raInMicroDegree > subSearchZone.raEndInMicroDegree)) {
			continue;
		}

		if ((theStar.decInMicroDegree < subSearchZone.decStartInMicroDegree) || (theStar.decInMicroDegree > subSearchZone.decEndInMicroDegree)) {
			continue;
		}

		if((theStar.jMagInMilliMag < magnitudeBox.magnitudeStartInMilliMag) || (theStar.jMagInMilliMag > magnitudeBox.magnitudeEndInMilliMag)) {
			continue;
		}

		elementList2Mass* currentElement   = (elementList2Mass*)malloc(sizeof(elementList2Mass));
		if(currentElement == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"currentElement = 1 (oneStar2Mass) out of memory\n");
			throw InsufficientMemoryException(outputLogChar);
		}

		currentElement->theStar  = convertStar2Mass(theStar);

		currentElement->nextStar = *headOfList;
		*headOfList              = currentElement;
	}
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
void processOneZone2MassNotCentredOnZeroRA(FILE* const inputStream,const indexTable2Mass& oneAccFile,elementList2Mass** headOfList,star2MassRaw* const redStars,
		const searchZone2Mass& mySearchZone2Mass, const int indexOfRA) {

	unsigned int indexOfStar;

	const searchZoneRaDecMicroDeg& subSearchZone = mySearchZone2Mass.subSearchZone;
	const magnitudeBoxMilliMag& magnitudeBox     = mySearchZone2Mass.magnitudeBox;

	/* Move to this position */
	if(fseek(inputStream,oneAccFile.idOfFirstStarInZone[indexOfRA] * sizeof(star2MassRaw),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the amount of stars */
	if(fread(redStars,sizeof(star2MassRaw),oneAccFile.numberOfStarsInZone[indexOfRA],inputStream) !=  oneAccFile.numberOfStarsInZone[indexOfRA]) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (star2Mass)\n",oneAccFile.numberOfStarsInZone[indexOfRA]);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile.numberOfStarsInZone[indexOfRA]; indexOfStar++) {

		star2MassRaw& theStar = redStars[indexOfStar];

		if ((theStar.raInMicroDegree < subSearchZone.raStartInMicroDegree) || (theStar.raInMicroDegree > subSearchZone.raEndInMicroDegree)) {
			continue;
		}

		if ((theStar.decInMicroDegree < subSearchZone.decStartInMicroDegree) || (theStar.decInMicroDegree > subSearchZone.decEndInMicroDegree)) {
			continue;
		}

		if((theStar.jMagInMilliMag < magnitudeBox.magnitudeStartInMilliMag) || (theStar.jMagInMilliMag > magnitudeBox.magnitudeEndInMilliMag)) {
			continue;
		}

		elementList2Mass* currentElement   = (elementList2Mass*)malloc(sizeof(elementList2Mass));
		if(currentElement == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"currentElement = 1 (oneStar2Mass) out of memory\n");
			throw InsufficientMemoryException(outputLogChar);
		}

		currentElement->theStar  = convertStar2Mass(theStar);

		currentElement->nextStar = *headOfList;
		*headOfList              = currentElement;
	}
}

/****************************************************************************/
/* Free the all ACC files array */
/****************************************************************************/
void freeAll2MassCatalogFiles(const indexTable2Mass* const allAccFiles, const searchZone2Mass& mySearchZone) {

	int indexOfFile;

	if(allAccFiles != NULL) {

		for(indexOfFile = mySearchZone.indexOfFirstDecZone;
				indexOfFile <= mySearchZone.indexOfLastDecZone;indexOfFile++) {

			releaseSimpleArray((void*)(allAccFiles[indexOfFile].idOfFirstStarInZone));
			releaseSimpleArray((void*)(allAccFiles[indexOfFile].numberOfStarsInZone));
		}
	}

	releaseSimpleArray((void*)allAccFiles);
}

/**
 * Read the index file
 */
indexTable2Mass* readIndexFile2Mass(const char* const pathOfCatalog, const searchZone2Mass& mySearchZone2Mass,int& maximumNumberOfStarsPerZone) {

	char completeFileName[STRING_COMMON_LENGTH];
	char shortName[STRING_COMMON_LENGTH];
	char oneLine[STRING_COMMON_LENGTH];
	int indexOfFile;
	int indexOfLine;
	/* .acc are badly filled: when numberOfStarsInZone = 0, the fields indexInFile
	 * and totalNumberOfStars do not exist, so sscanf does not change them
	 * In this case indexInFile will be equal to 0 (0 is the value of numberOfStarsInZone)
	 * THIS IS THE BEHAVIOUR UNDER LINUX : NOT SURE TO BE THE SAME UNDER OTHER OSs
	 * So : we initialise totalNumberOfStars to 0 and indexInFile to -1 (indexInFile is not used hereafter)*/
	maximumNumberOfStarsPerZone = 0;
	int indexInFile             = -1;
	int totalNumberOfStars      = 0;
	int numberOfStarsInZone     = 0;
	int raZoneNumber;
	int raZoneNumberPlusOne;
	FILE* inputStream;

	/* Allocate memory */
	indexTable2Mass* indexTable = (indexTable2Mass*)malloc(NUMBER_OF_CATALOG_FILES_2MASS * sizeof(indexTable2Mass));
	if(indexTable == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		throw InsufficientMemoryException(outputLogChar);
	}

	for(indexOfFile = mySearchZone2Mass.indexOfFirstDecZone; indexOfFile <= mySearchZone2Mass.indexOfLastDecZone;indexOfFile++) {

		if(indexOfFile                            >= HALF_NUMBER_OF_CATALOG_FILES_2MASS) {
			/* North hemisphere */
			indexTable[indexOfFile].indexOfCatalog = indexOfFile - HALF_NUMBER_OF_CATALOG_FILES_2MASS;
			indexTable[indexOfFile].prefix         = NORTH_HEMISPHERE_PREFIX;
		} else {
			/* South hemisphere */
			indexTable[indexOfFile].indexOfCatalog = HALF_NUMBER_OF_CATALOG_FILES_2MASS_MINUS_ONE - indexOfFile;
			indexTable[indexOfFile].prefix         = SOUTH_HEMISPHERE_PREFIX;
		}

		/* Allocate memory for internal tables */
		indexTable[indexOfFile].idOfFirstStarInZone = (unsigned int*)malloc(ACC_FILE_NUMBER_OF_LINES * sizeof(unsigned int));
		if(indexTable[indexOfFile].idOfFirstStarInZone == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"indexTable[%d].idOfFirstStarInZone = %d (int) out of memory\n",indexOfFile,ACC_FILE_NUMBER_OF_LINES);
			throw InsufficientMemoryException(outputLogChar);
		}
		indexTable[indexOfFile].numberOfStarsInZone = (unsigned int*)malloc(ACC_FILE_NUMBER_OF_LINES * sizeof(unsigned int));
		if(indexTable[indexOfFile].numberOfStarsInZone == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"indexTable[%d].numberOfStarsInZone = %d (int) out of memory\n",indexOfFile,ACC_FILE_NUMBER_OF_LINES);
			throw InsufficientMemoryException(outputLogChar);
		}

		/* The first and the last accelerator files are empty (m000TMASS.acc and p899TMASS.acc) */
		if((indexTable[indexOfFile].prefix == SOUTH_HEMISPHERE_PREFIX) && (indexTable[indexOfFile].indexOfCatalog == 0)) {

			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {

				indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = 0;
				indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = NUMBER_OF_STARS_IN_M000;
			}

			if(maximumNumberOfStarsPerZone  < NUMBER_OF_STARS_IN_M000) {
				maximumNumberOfStarsPerZone = NUMBER_OF_STARS_IN_M000;
			}

		} else if ((indexTable[indexOfFile].prefix == NORTH_HEMISPHERE_PREFIX) &&
				(indexTable[indexOfFile].indexOfCatalog == HALF_NUMBER_OF_CATALOG_FILES_2MASS_MINUS_ONE)) {

			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {

				indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = 0;
				indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = NUMBER_OF_STARS_IN_P899;
			}

			if(maximumNumberOfStarsPerZone  < NUMBER_OF_STARS_IN_P899) {
				maximumNumberOfStarsPerZone = NUMBER_OF_STARS_IN_P899;
			}

		} else {

			/* Open the catalog ACC files */
			sprintf(shortName,CATALOG_NAME_FORMAT,indexTable[indexOfFile].prefix,indexTable[indexOfFile].indexOfCatalog);
			sprintf(completeFileName,"%s%s%s",pathOfCatalog,shortName,DOT_ACC_EXTENSION);
			inputStream = fopen(completeFileName,"rt");
			if(inputStream == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"%s not found\n",completeFileName);
				throw FileNotFoundException(outputLogChar);
			}

			/* Read the catalog ACC files */
			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {
				if ( fgets (oneLine, STRING_COMMON_LENGTH, inputStream) == NULL ) {
					char outputLogChar[STRING_COMMON_LENGTH];
					sprintf(outputLogChar,"%s : can not read the %d th line\n",completeFileName,indexOfLine);
					return (NULL);
				} else {
					sscanf(oneLine,FORMAT_ACC,&raZoneNumber,&raZoneNumberPlusOne,&indexInFile,&totalNumberOfStars,&numberOfStarsInZone);

					if(raZoneNumber != indexOfLine) {
						char outputLogChar[STRING_COMMON_LENGTH];
						sprintf(outputLogChar,"%s : error in Ra zone in the %d th line\n",completeFileName,indexOfLine);
						throw InvalidDataException(outputLogChar);
					}

					/* .acc are badly filled: when numberOfStarsInZone = 0, the fields indexInFile
					 * and totalNumberOfStars do not exist, so sscanf does not change them
					 * In this case indexInFile will be equal to 0 (0 is the value of numberOfStarsInZone) :
					 * THIS IS THE BEHAVIOUR UNDER LINUX : NOT SURE TO BE THE SAME UNDER OTHER OSs*/
					if(indexInFile == 0) {
						indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = totalNumberOfStars;
						indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = 0;
					} else {
						indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = totalNumberOfStars - numberOfStarsInZone;
						indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = numberOfStarsInZone;
					}

					if(maximumNumberOfStarsPerZone  < numberOfStarsInZone) {
						maximumNumberOfStarsPerZone = numberOfStarsInZone;
					}
				}
			}

			fclose(inputStream);
		}
	}

	return (indexTable);
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 *
 */
const searchZone2Mass findSearchZone2Mass(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax) {

	searchZone2Mass mySearchZone2Mass;

	const double catalogDistanceToPoleWidthInMicroDegree = DEG2MICRODEG * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE;
	const double accFileRaZoneWidthInMicroDegree         = DEG2MICRODEG * ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE;
	const int decSouthPoleInMicroDegree                  = (int) (DEG2MICRODEG * DEC_SOUTH_POLE_DEG);

	fillSearchZoneRaDecMicroDeg(mySearchZone2Mass.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(mySearchZone2Mass.magnitudeBox, magMin, magMax);

	mySearchZone2Mass.indexOfFirstDecZone = (int) ((mySearchZone2Mass.subSearchZone.decStartInMicroDegree - decSouthPoleInMicroDegree) / catalogDistanceToPoleWidthInMicroDegree);
	mySearchZone2Mass.indexOfLastDecZone  = (int) ((mySearchZone2Mass.subSearchZone.decEndInMicroDegree   - decSouthPoleInMicroDegree) / catalogDistanceToPoleWidthInMicroDegree);

	if(mySearchZone2Mass.indexOfFirstDecZone >= NUMBER_OF_CATALOG_FILES_2MASS) {
		mySearchZone2Mass.indexOfFirstDecZone = NUMBER_OF_CATALOG_FILES_2MASS - 1;
	}
	if(mySearchZone2Mass.indexOfLastDecZone  >= NUMBER_OF_CATALOG_FILES_2MASS) {
		mySearchZone2Mass.indexOfLastDecZone  = NUMBER_OF_CATALOG_FILES_2MASS - 1;
	}

	mySearchZone2Mass.indexOfFirstRightAscensionZone = (int)(mySearchZone2Mass.subSearchZone.raStartInMicroDegree / accFileRaZoneWidthInMicroDegree);
	mySearchZone2Mass.indexOfLastRightAscensionZone  = (int)(mySearchZone2Mass.subSearchZone.raEndInMicroDegree   / accFileRaZoneWidthInMicroDegree);

	return (mySearchZone2Mass);
}


void CCatalog::releaseListOfStar2Mass(listOfStars2Mass* listOfStars) {

	elementList2Mass* currentElement = listOfStars;
	elementList2Mass* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}

