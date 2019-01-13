/*
 * cswfibc.c
 *
 *  Created on: 30/06/2013
 *      Author: Y. Damerdji
 */

#include "CCatalog.h" 
#include "cswfibc.h"

listOfStarsWfibc* CCatalog::cswfibc (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfZone;
	int numberOfZones;
	char fileName[1024];

	/* Define search zone */
	const searchZoneWfibc& mySearchZoneWfibc = findSearchZoneWfibc(ra,dec,radius,magMin,magMax);

	/* Read the accelerator file */
	numberOfZones    = (int)((RA_END - RA_START) / RA_STEP) + 1;

	raZone* raZones  = readAcceleratorFileWfbic(pathToCatalog,numberOfZones);

	/* Open the offset file */
	sprintf(fileName,"%s%s",pathToCatalog,OFFSET_TABLE);
	FILE* offsetFileStream = fopen(fileName,"rt");
	if(offsetFileStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"File %s not found\n",fileName);
		releaseSimpleArray(raZones);
		throw FileNotFoundException(outputLogChar);
	}

	/* Now we loop over the concerned catalog and fill the list of stars */
	elementListWfibc* headOfList = NULL;

	if(mySearchZoneWfibc.subSearchZone.isArroundZeroRa) {

		for(indexOfZone = mySearchZoneWfibc.indexOfFirstRightAscensionZone; indexOfZone < numberOfZones; indexOfZone++) {

			processOneZone(offsetFileStream,raZones[indexOfZone],mySearchZoneWfibc,pathToCatalog,&headOfList);
		}

		for(indexOfZone = 0; indexOfZone <= mySearchZoneWfibc.indexOfLastRightAscensionZone; indexOfZone++) {

			processOneZone(offsetFileStream,raZones[indexOfZone],mySearchZoneWfibc,pathToCatalog,&headOfList);
		}

	} else {

		for(indexOfZone = mySearchZoneWfibc.indexOfFirstRightAscensionZone; indexOfZone <= mySearchZoneWfibc.indexOfLastRightAscensionZone; indexOfZone++) {

			processOneZone(offsetFileStream,raZones[indexOfZone],mySearchZoneWfibc,pathToCatalog,&headOfList);
		}
	}

	listOfStarsWfibc* theStars  = headOfList;

	fclose(offsetFileStream);
	releaseSimpleArray(raZones);

	return (theStars);
}

/******************************************************************************/
/* Process one zone of RA                                                     */
/******************************************************************************/
void processOneZone(FILE* const offsetFileStream, const raZone& theRaZone, const searchZoneWfibc& mySearchZoneWfibc,
		const char* const pathToCatalog,elementListWfibc** headOfList) {

	char oneLine[1024];
	char catalogShortName[1024];
	char catalogFullName[1024];
	const double epsilon = 1e-6;
	double raStart, raEnd;
	int indexOfLine;
	int offset;
	int numberOfLines;

	if(theRaZone.numberOfLines == 0) {
		/* Nothing to do */
		return;
	}

	if(fseek(offsetFileStream,theRaZone.offset,SEEK_SET)) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Can not move by %d in %s\n",theRaZone.offset,OFFSET_TABLE);
		throw CanNotReadInStreamException(outputLogChar);
	}

	if(fgets(oneLine,1024,offsetFileStream) == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Can not read line from %s\n",OFFSET_TABLE);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Check the validity of data */
	if(oneLine[0] != '#') {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Line %s should start with #\n",oneLine);
		throw InvalidDataException(outputLogChar);
	}

	sscanf(oneLine,FORMAT_OFFSET_TABLE_COMMENT,&raStart,&raEnd);
	if((fabs(theRaZone.raStart - raStart) > epsilon) || (fabs(theRaZone.raEnd - raEnd) > epsilon)) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Line %s contains incompatible data\n",oneLine);
		throw InvalidDataException(outputLogChar);
	}

	/* Read the lines */
	for(indexOfLine = 0; indexOfLine < theRaZone.numberOfLines; indexOfLine++) {
		if(fgets(oneLine,1024,offsetFileStream) == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Can not read line from %s\n",OFFSET_TABLE);
			throw CanNotReadInStreamException(outputLogChar);
		}
		if(oneLine[0] == '#') {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Line %s should not start with #\n",oneLine);
			throw InvalidDataException(outputLogChar);
		}
		if(oneLine[0] != '\t') {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Line %s should start with tabulation\n",oneLine);
			throw InvalidDataException(outputLogChar);
		}
		sscanf(oneLine,FORMAT_OFFSET_TABLE_DATA,catalogShortName,&offset,&numberOfLines);
#ifdef WIN32
		sprintf(catalogFullName,"%scat\\%s",pathToCatalog,catalogShortName);
#else
		sprintf(catalogFullName,"%scat/%s",pathToCatalog,catalogShortName);
#endif

		processOneZoneInOneFile(catalogFullName,offset,numberOfLines,mySearchZoneWfibc,headOfList);
	}
}

/******************************************************************************/
/* Process one zone of RA   in a catalog file                                 */
/******************************************************************************/
void processOneZoneInOneFile(const char* const catalogFullName, const int offset, const int numberOfLines, const searchZoneWfibc& mySearchZoneWfibc,elementListWfibc** headOfList) {

	int lineNumber;
	char oneLine[1024];
	int raDeg, raMin, decDeg, decMin;
	double raSec, decSec, ra, dec, errRa, errDec;
	double pmRa, pmDec, errPmRa, errPmDec, jd;
	double magR, errMagR;
	elementListWfibc* currentElement;

	FILE* const inputStream = fopen(catalogFullName,"rt");
	if(inputStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"File %s not found\n",catalogFullName);
		throw FileNotFoundException(outputLogChar);
	}

	if(fseek(inputStream,offset,SEEK_SET)) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Can not move by %d in %s\n",offset,catalogFullName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	//printf("Process %s\n",catalogFullName);

	/* Read numberOfLines and output those satisfying the search box */
	for(lineNumber = 0; lineNumber < numberOfLines; lineNumber++) {
		if(fgets(oneLine,1024,inputStream) == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Can not read line from %s\n",catalogFullName);
			throw CanNotReadInStreamException(outputLogChar);
		}
		//printf("oneLine = %s\n",oneLine);
		sscanf(oneLine,CATALOG_LINE_FORMAT,&raDeg, &raMin, &raSec, &decDeg, &decMin, &decSec, &errRa, &errDec,
				&jd, &pmRa, &pmDec, &errPmRa, &errPmDec, &magR, &errMagR);

		ra      = 15. * (raDeg + raMin / 60. + raSec / 3600.);
		if(decDeg < 0) {
			dec = decDeg - decMin / 60. - decSec / 3600.;
		} else {
			dec = decDeg + decMin / 60. + decSec / 3600.;
		}

		if(
				((mySearchZoneWfibc.subSearchZone.isArroundZeroRa && ((ra >= mySearchZoneWfibc.subSearchZone.raStartInDeg) || (ra <= mySearchZoneWfibc.subSearchZone.raEndInDeg))) ||
						(!mySearchZoneWfibc.subSearchZone.isArroundZeroRa && ((ra >= mySearchZoneWfibc.subSearchZone.raStartInDeg) && (ra <= mySearchZoneWfibc.subSearchZone.raEndInDeg)))) &&
						(dec  >= mySearchZoneWfibc.subSearchZone.decStartInDeg) &&
						(dec  <= mySearchZoneWfibc.subSearchZone.decEndInDeg) &&
						(magR >= mySearchZoneWfibc.magnitudeBox.magnitudeStartInMag) &&
						(magR <= mySearchZoneWfibc.magnitudeBox.magnitudeEndInMag)) {


			currentElement = (elementListWfibc*)malloc(sizeof(elementListWfibc));
			if(currentElement == NULL) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"currentElement = 1 (oneStarWfbic) out of memory\n");
				throw InsufficientMemoryException(outputLogChar);
			}

			currentElement->theStar.ra              = ra;
			currentElement->theStar.dec             = dec;
			currentElement->theStar.errorRa         = errRa;
			currentElement->theStar.errorDec        = errDec;
			currentElement->theStar.jd              = jd;
			currentElement->theStar.pmRa            = pmRa;
			currentElement->theStar.pmDec           = pmDec;
			currentElement->theStar.errorPmRa       = errPmRa;
			currentElement->theStar.errorPmDec      = errPmDec;
			currentElement->theStar.magnitudeR      = magR;
			currentElement->theStar.errorMagnitudeR = errMagR;

			currentElement->nextStar                = *headOfList;
			*headOfList                             = currentElement;
		}
	}

	fclose(inputStream);
}

/******************************************************************************/
/* Read the accelerator table                                                 */
/******************************************************************************/
raZone* readAcceleratorFileWfbic(const char* const pathToCatalog, const int numberOfZones) {

	const double epsilon = 1e-6;
	char fileFullName[1024];
	char oneLine[1024];
	int indexOfZone;
	FILE* inputStream;
	raZone* raZones   = (raZone*)malloc(numberOfZones * sizeof(raZone));
	if(raZones == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"raZones out of memory (%d raZone)\n",numberOfZones);
		return (NULL);
	}

	/* Read the file */
	sprintf(fileFullName,"%s%s",pathToCatalog,ACCELERATOR_TABLE);
	inputStream = fopen(fileFullName,"rt");
	if(inputStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"File %s not found\n",fileFullName);
		free(raZones);
		printf("numberOfZones3 = %d\n",numberOfZones);
		return (NULL);
	}

	for(indexOfZone = 0; indexOfZone < numberOfZones; indexOfZone++) {

		if(fgets(oneLine,1024,inputStream) == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Can not read line from %s\n",fileFullName);
			free(raZones);
			fclose(inputStream);
			return(NULL);
		}

		sscanf(oneLine,"%lf %lf %d %d", &(raZones[indexOfZone].raStart), &(raZones[indexOfZone].raEnd),
				&(raZones[indexOfZone].offset), &(raZones[indexOfZone].numberOfLines));

		/* Check the compatibility of data */
		if((fabs(raZones[indexOfZone].raStart - RA_START - indexOfZone * RA_STEP) > epsilon) ||
				(fabs(raZones[indexOfZone].raEnd - RA_START - (indexOfZone + 1) * RA_STEP) > epsilon)) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Line %s contains incompatible data\n",oneLine);
			free(raZones);
			fclose(inputStream);
			return(NULL);
		}
	}

	fclose(inputStream);
	return(raZones);
}

/******************************************************************************/
/* Find the search zone having its center on (ra,dec) with a radius of radius */
/******************************************************************************/
searchZoneWfibc findSearchZoneWfibc(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneWfibc mySearchZoneWfibc;

	fillSearchZoneRaDecDeg(mySearchZoneWfibc.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(mySearchZoneWfibc.magnitudeBox, magMin, magMax);

	mySearchZoneWfibc.indexOfFirstRightAscensionZone = (int) ((mySearchZoneWfibc.subSearchZone.raStartInDeg - RA_START) / RA_STEP);
	mySearchZoneWfibc.indexOfLastRightAscensionZone  = (int) ((mySearchZoneWfibc.subSearchZone.raEndInDeg   - RA_START) / RA_STEP);

	if(DEBUG) {
		printf("mySearchZoneWfibc.indexOfFirstRightAscensionZone   = %d\n",mySearchZoneWfibc.indexOfFirstRightAscensionZone);
		printf("mySearchZoneWfibc.indexOfLastRightAscensionZone    = %d\n",mySearchZoneWfibc.indexOfLastRightAscensionZone);
	}

	return (mySearchZoneWfibc);
}

void CCatalog::releaseListOfStarWfibc(listOfStarsWfibc* listOfStars) {

	elementListWfibc* currentElement = listOfStars;
	elementListWfibc* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}

