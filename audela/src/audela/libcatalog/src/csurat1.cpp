#include "CCatalog.h"
#include "csurat1.h"
/*
 * csurat1.cpp
 *
 *  Created on: Jan 17, 2016
 *      Author: Y. Damerdji
 */
listOfStarsUrat1* CCatalog::csurat1 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int maximumNumberOfStarsPerZone;
	int indexOfRA;
	int indexOfDecZone;
	int counterOfDecZone;
	char shortName[1024];
	char fileName[1024];
	FILE* inputStream;

	/* Define search zone */
	const searchZoneUrat1& mySearchZoneUrat1 = findSearchZoneUrat1(ra,dec,radius,magMin,magMax);

	/* Read all catalog files to be able to deliver an ID for each star */
	int** numberOfStarsperZone               = readIndexFileUrat1(pathToCatalog,maximumNumberOfStarsPerZone);

	if(maximumNumberOfStarsPerZone <= 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"maximumNumberOfStarsPerZone = %d should be > 0\n",maximumNumberOfStarsPerZone);
		throw InvalidDataException(outputLogChar);
	}

	/* Allocate memory for an array in which we put the read stars */
	starUrat1Raw* readStars = (starUrat1Raw*)malloc(maximumNumberOfStarsPerZone * sizeof(starUrat1Raw));

	if(readStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"readStars = %d (starUrat1Raw) out of memory\n",maximumNumberOfStarsPerZone);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	elementListUrat1* headOfList = NULL;

	for(indexOfDecZone = mySearchZoneUrat1.indexOfFirstDistanceToPoleZone; indexOfDecZone <= mySearchZoneUrat1.indexOfLastDistanceToPoleZone; indexOfDecZone++) {

		counterOfDecZone = indexOfDecZone - URAT1_FIRST_ZONE_INDEX;

		/* Open the binary file */
		sprintf(shortName,URAT1_CATALOG_NAME_FORMAT,indexOfDecZone);
		sprintf(fileName,"%s%s",pathToCatalog,shortName);

		inputStream = fopen(fileName,"rb");
		if(inputStream == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"%s not found\n",fileName);
			throw FileNotFoundException(outputLogChar);
		}

		if(mySearchZoneUrat1.subSearchZone.isArroundZeroRa) {

			for(indexOfRA = mySearchZoneUrat1.indexOfFirstRightAscensionZone; indexOfRA < URAT1_NUMBER_OF_RA_ZONES; indexOfRA++) {

				processOneZoneUrat1(inputStream,numberOfStarsperZone[counterOfDecZone],
						&headOfList,readStars,mySearchZoneUrat1,indexOfDecZone,indexOfRA);
			}

			for(indexOfRA = 0; indexOfRA <= mySearchZoneUrat1.indexOfLastRightAscensionZone; indexOfRA++) {

				processOneZoneUrat1(inputStream,numberOfStarsperZone[counterOfDecZone],
						&headOfList,readStars,mySearchZoneUrat1,indexOfDecZone,indexOfRA);
			}

		} else {

			for(indexOfRA = mySearchZoneUrat1.indexOfFirstRightAscensionZone; indexOfRA <= mySearchZoneUrat1.indexOfLastRightAscensionZone; indexOfRA++) {

				processOneZoneUrat1(inputStream,numberOfStarsperZone[counterOfDecZone],
						&headOfList,readStars,mySearchZoneUrat1,indexOfDecZone,indexOfRA);
			}

		}

		fclose(inputStream);
	}

	/* Release memory */
	releaseDoubleArray((void**)numberOfStarsperZone,URAT1_NUMBER_OF_DEC_ZONES);
	releaseSimpleArray(readStars);

	listOfStarsUrat1* theStars  = headOfList;

	return (theStars);
}

/****************************************************************************/
/* Process one RA-DEC zone centered on zero ra                              */
/****************************************************************************/
void processOneZoneUrat1(FILE* const inputStream,const int* const numberOfStarsPerZone,
		elementListUrat1** headOfList, starUrat1Raw* const readStars,
		const searchZoneUrat1& mySearchZoneUrat1, const int indexOfDecZone, const int indexOfRaZone) {

	bool goodStar;
	int numberOfStarsBefore;
	int starId;
	int index;
	int indexOfStar;

	numberOfStarsBefore = 0;
	if(indexOfRaZone > 0) {
		for(index = 0; index < indexOfRaZone; index++) {
			numberOfStarsBefore += numberOfStarsPerZone[index];
		}
	}

	/* Move to this position */
	if(fseek(inputStream,numberOfStarsBefore * sizeof(starUrat1Raw),SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not move in inputStream\n");
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the stars */
	if(fread(readStars,sizeof(starUrat1Raw),numberOfStarsPerZone[indexOfRaZone],inputStream) != (size_t)numberOfStarsPerZone[indexOfRaZone]) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"can not read %d (starUrat1Raw)\n",numberOfStarsPerZone[indexOfRaZone]);
		throw CanNotReadInStreamException(outputLogChar);
	}

	starId  = numberOfStarsBefore;

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < numberOfStarsPerZone[indexOfRaZone]; indexOfStar++) {

		/* Increment the star ID */
		starId++;

		starUrat1Raw& theStar = readStars[indexOfStar];

		goodStar              = isGoodStarUrat1(theStar, mySearchZoneUrat1);

		if (goodStar) {

			elementListUrat1* currentElement   = (elementListUrat1*)malloc(sizeof(elementListUrat1));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (elementListUrat1) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}

			sprintf(currentElement->theStar.id,URAT1_ID_FORMAT,indexOfDecZone,starId);
			currentElement->theStar.ra             = (double)theStar.ra / DEG2MAS;
			currentElement->theStar.dec            = (double)theStar.spd / DEG2MAS + DEC_SOUTH_POLE_DEG;
			currentElement->theStar.sigs           = (double)theStar.sigs / DEG2MAS;
			currentElement->theStar.sigm           = (double)theStar.sigm / DEG2MAS;
			currentElement->theStar.nst            = theStar.nst;
			currentElement->theStar.nsu            = theStar.nsu;
			currentElement->theStar.epoc           = (double)theStar.epoc / YEAR2MILLIYEAR;
			currentElement->theStar.magnitude      = (double)theStar.mmag / MAG2MILLIMAG;
			currentElement->theStar.sigmaMagnitude = (double)theStar.sigp / MAG2MILLIMAG;
			currentElement->theStar.nsm            = theStar.nsm;
			currentElement->theStar.ref            = theStar.ref;
			currentElement->theStar.nit            = theStar.nit;
			currentElement->theStar.niu            = theStar.niu;
			currentElement->theStar.ngt            = theStar.ngt;
			currentElement->theStar.ngu            = theStar.ngu;
			currentElement->theStar.pmr            = theStar.pmr;
			currentElement->theStar.pmd            = theStar.pmd;
			currentElement->theStar.pme            = theStar.pme;
			currentElement->theStar.mf2            = theStar.mf2;
			currentElement->theStar.mfa            = theStar.mfa;
			currentElement->theStar.id2            = theStar.id2;
			currentElement->theStar.jmag           = (double)theStar.jmag / MAG2MILLIMAG;
			currentElement->theStar.hmag           = (double)theStar.hmag / MAG2MILLIMAG;
			currentElement->theStar.kmag           = (double)theStar.kmag / MAG2MILLIMAG;
			currentElement->theStar.ejmag          = (double)theStar.ejmag / MAG2MILLIMAG;
			currentElement->theStar.ehmag          = (double)theStar.ehmag / MAG2MILLIMAG;
			currentElement->theStar.ekmag          = (double)theStar.ekmag / MAG2MILLIMAG;
			currentElement->theStar.iccj           = theStar.iccj;
			currentElement->theStar.icch           = theStar.icch;
			currentElement->theStar.icck           = theStar.icck;
			currentElement->theStar.phqj           = theStar.phqj;
			currentElement->theStar.phqh           = theStar.phqh;
			currentElement->theStar.phqk           = theStar.phqk;
			currentElement->theStar.abm            = (double)theStar.abm / MAG2MILLIMAG;
			currentElement->theStar.avm            = (double)theStar.avm / MAG2MILLIMAG;
			currentElement->theStar.agm            = (double)theStar.agm / MAG2MILLIMAG;
			currentElement->theStar.arm            = (double)theStar.arm / MAG2MILLIMAG;
			currentElement->theStar.aim            = (double)theStar.aim / MAG2MILLIMAG;
			currentElement->theStar.ebm            = (double)theStar.ebm / MAG2MILLIMAG;
			currentElement->theStar.evm            = (double)theStar.evm / MAG2MILLIMAG;
			currentElement->theStar.egm            = (double)theStar.egm / MAG2MILLIMAG;
			currentElement->theStar.erm            = (double)theStar.erm / MAG2MILLIMAG;
			currentElement->theStar.eim            = (double)theStar.eim / MAG2MILLIMAG;
			currentElement->theStar.ann            = theStar.ann;
			currentElement->theStar.ano            = theStar.ano;

			currentElement->nextStar               = *headOfList;
			*headOfList                            = currentElement;
		}
	}
}

/****************************************************************************/
/* Filter the un-filtered stars with respect to restrictions                */
/****************************************************************************/
bool isGoodStarUrat1(const starUrat1Raw& theStar, const searchZoneUrat1& mySearchZoneUrat1) {

	const searchZoneRaSpdMas& subSearchZone  = mySearchZoneUrat1.subSearchZone;
	const magnitudeBoxMilliMag& magnitudeBox = mySearchZoneUrat1.magnitudeBox;

	if(
			((subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInMas) || (theStar.ra <= subSearchZone.raEndInMas))) ||
					(!subSearchZone.isArroundZeroRa && ((theStar.ra >= subSearchZone.raStartInMas) && (theStar.ra <= subSearchZone.raEndInMas)))) &&
					(theStar.spd >= subSearchZone.spdStartInMas) &&
					(theStar.spd <= subSearchZone.spdEndInMas) &&
					(theStar.mmag >= magnitudeBox.magnitudeStartInMilliMag) &&
					(theStar.mmag <= magnitudeBox.magnitudeEndInMilliMag)) {

		return(true);
	}

	return (false);
}

/****************************************************************************/
/* Read the catalog files which contain the search zones                    */
/****************************************************************************/
int** readIndexFileUrat1(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone) {

	char fileName[1024];
	char oneLine[128];
	FILE* inputStream;
	int zoneRa;
	int zoneDec;
	int indexOfDecZone;
	int indexOfRaZone;
	int indexInFile;
	int numberOfStars;
	int counterOfDecZone;
	int noting;
	maximumNumberOfStarsPerZone = 0;

	/* Allocate numberOfStarsPerZone */
	int** numberOfStarsPerZone = (int**)malloc(URAT1_NUMBER_OF_DEC_ZONES * sizeof(int*));
	if(numberOfStarsPerZone == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"numberOfStarsPerZone = %d (accFiles) out of memory\n",URAT1_NUMBER_OF_DEC_ZONES);
		throw InsufficientMemoryException(outputLogChar);
	}

	counterOfDecZone   = 0;
	for(indexOfDecZone = URAT1_FIRST_ZONE_INDEX; indexOfDecZone <= URAT1_LAST_ZONE_INDEX;indexOfDecZone++) {

		numberOfStarsPerZone[counterOfDecZone] = (int*)malloc(URAT1_NUMBER_OF_RA_ZONES * sizeof(int));
		if(numberOfStarsPerZone[counterOfDecZone] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"numberOfStarsPerZone[%d] = %d (int) out of memory\n",counterOfDecZone,URAT1_NUMBER_OF_RA_ZONES);
			throw InsufficientMemoryException(outputLogChar);
		}

		counterOfDecZone++;
	}

	/* Open the index file for reading */
	sprintf(fileName,"%s%s",pathOfCatalog,URAT1_INDEX_FILENAME);
	inputStream = fopen(fileName,"rt");
	if(inputStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"%s not found\n",fileName);
		throw FileNotFoundException(outputLogChar);
	}

	counterOfDecZone   = 0;
	for(indexOfDecZone = URAT1_FIRST_ZONE_INDEX; indexOfDecZone <= URAT1_LAST_ZONE_INDEX;indexOfDecZone++) {

		for(indexOfRaZone = 0; indexOfRaZone < URAT1_NUMBER_OF_RA_ZONES; indexOfRaZone++) {

			if ( fgets (oneLine, 128, inputStream) == NULL ) {

				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"%s : can not read the %d th line of the %d th dec zone\n",fileName,indexOfRaZone,indexOfDecZone);
				throw CanNotReadInStreamException(outputLogChar);

			} else {

				sscanf(oneLine,URAT1_FORMAT_ACC,&zoneDec,&zoneRa,&indexInFile,&numberOfStars,&noting,&noting);

				if(zoneDec != indexOfDecZone) {
					char outputLogChar[STRING_COMMON_LENGTH];
					sprintf(outputLogChar,"error in Dec zone in the %d th line of the %d th dec zone\n",indexOfRaZone,indexOfDecZone);
					throw InvalidDataException(outputLogChar);
				}

				if(zoneRa != indexOfRaZone + 1) {
					char outputLogChar[STRING_COMMON_LENGTH];
					sprintf(outputLogChar,"error in Ra zone in the %d th line of the %d th dec zone\n",indexOfRaZone,indexOfDecZone);
					throw InvalidDataException(outputLogChar);
				}

				numberOfStarsPerZone[counterOfDecZone][indexOfRaZone] = numberOfStars;

				if(maximumNumberOfStarsPerZone  < numberOfStars) {
					maximumNumberOfStarsPerZone = numberOfStars;
				}
			}
		}

		counterOfDecZone++;
	}

	fclose(inputStream);

	return (numberOfStarsPerZone);
}

/******************************************************************************/
/* Find the search zone having its center on (ra,dec) with a radius of radius */
/******************************************************************************/
searchZoneUrat1 findSearchZoneUrat1(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneUrat1 mySearchZoneUrat1;

	fillSearchZoneRaSpdMas(mySearchZoneUrat1.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(mySearchZoneUrat1.magnitudeBox, magMin, magMax);

	mySearchZoneUrat1.indexOfFirstDistanceToPoleZone    = (int) (mySearchZoneUrat1.subSearchZone.spdStartInMas / (URAT1_DISTANCE_TO_POLE_WIDTH_IN_DEGREE * DEG2MAS));
	mySearchZoneUrat1.indexOfLastDistanceToPoleZone     = (int) (mySearchZoneUrat1.subSearchZone.spdEndInMas / (URAT1_DISTANCE_TO_POLE_WIDTH_IN_DEGREE * DEG2MAS));

	if(mySearchZoneUrat1.indexOfFirstDistanceToPoleZone         > URAT1_LAST_ZONE_INDEX) {
		mySearchZoneUrat1.indexOfFirstDistanceToPoleZone        = URAT1_LAST_ZONE_INDEX;
	} else if (mySearchZoneUrat1.indexOfFirstDistanceToPoleZone < URAT1_FIRST_ZONE_INDEX) {
		mySearchZoneUrat1.indexOfFirstDistanceToPoleZone        = URAT1_FIRST_ZONE_INDEX;
	}

	if(mySearchZoneUrat1.indexOfLastDistanceToPoleZone          > URAT1_LAST_ZONE_INDEX) {
		mySearchZoneUrat1.indexOfLastDistanceToPoleZone         = URAT1_LAST_ZONE_INDEX;
	} else if (mySearchZoneUrat1.indexOfLastDistanceToPoleZone  < URAT1_FIRST_ZONE_INDEX) {
		mySearchZoneUrat1.indexOfLastDistanceToPoleZone         = URAT1_FIRST_ZONE_INDEX;
	}

	mySearchZoneUrat1.indexOfFirstRightAscensionZone     = (int) (mySearchZoneUrat1.subSearchZone.raStartInMas / (URAT1_INDEX_RA_ZONE_WIDTH_IN_DEGREE * DEG2MAS));
	mySearchZoneUrat1.indexOfLastRightAscensionZone      = (int) (mySearchZoneUrat1.subSearchZone.raEndInMas / (URAT1_INDEX_RA_ZONE_WIDTH_IN_DEGREE * DEG2MAS));

	if(mySearchZoneUrat1.indexOfFirstRightAscensionZone >= URAT1_NUMBER_OF_RA_ZONES) {
		mySearchZoneUrat1.indexOfFirstRightAscensionZone = URAT1_NUMBER_OF_RA_ZONES - 1;
	}
	if(mySearchZoneUrat1.indexOfLastRightAscensionZone  >= URAT1_NUMBER_OF_RA_ZONES) {
		mySearchZoneUrat1.indexOfLastRightAscensionZone  = URAT1_NUMBER_OF_RA_ZONES - 1;
	}

	if(DEBUG) {
		printf("mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone   = %d\n",mySearchZoneUrat1.indexOfFirstDistanceToPoleZone);
		printf("mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone    = %d\n",mySearchZoneUrat1.indexOfLastDistanceToPoleZone);
		printf("mySearchZoneUsnoa2.indexOfFirstRightAscensionZone   = %d\n",mySearchZoneUrat1.indexOfFirstRightAscensionZone);
		printf("mySearchZoneUsnoa2.indexOfLastRightAscensionZone    = %d\n",mySearchZoneUrat1.indexOfLastRightAscensionZone);
	}

	return (mySearchZoneUrat1);
}

void CCatalog::releaseListOfStarUrat1(listOfStarsUrat1* listOfStars) {

	elementListUrat1* currentElement = listOfStars;
	elementListUrat1* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
