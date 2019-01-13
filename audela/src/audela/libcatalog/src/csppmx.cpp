/*
 * ppmx.c
 *
 *  Created on: 18/03/2013
 *      Author: Y. Damerdji
 */
#include "CCatalog.h"
#include "csppmx.h"

const char * const ppxZoneNames[] = {"0000", "0730", "1500", "2230", "3000", "3730",
		"4500", "5230", "6000", "6730", "7500", "8230" };
const char referenceCatalog[] = "AGHPST";
const char ppmxSet[] = "HOS";
char PPMX_HEADER_FORMAT[] = "PPMX(46)/%5s.bin N=%d Noff=%d n4=%d n2=%d oDE=%d";

/**
 * Cone search on PPMX catalog
 */
listOfStarsPpmx* CCatalog::csppmx (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfFile;
	char binaryFileName[STRING_COMMON_LENGTH];

	/* Define the search zone */
	const searchZonePPMX& mySearchZonePPMX = findSearchZonePPMX(ra,dec,radius,magMin,magMax);
	if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"mySearchZonePPMX.numberOfBinaryFiles = %d should be > 0\n",mySearchZonePPMX.numberOfBinaryFiles);
		throw InvalidDataException(outputLogChar);
	}

	elementListPpmx* headOfList = NULL;

	/* No we loop over the binary files to be opened, we process them one by one */
	for(indexOfFile = 0; indexOfFile < mySearchZonePPMX.numberOfBinaryFiles; indexOfFile++) {
		sprintf(binaryFileName,"%s%s",pathToCatalog,mySearchZonePPMX.binaryFileNames[indexOfFile]);
		processOneFilePPMX(mySearchZonePPMX,binaryFileName,&headOfList);
	}

	/* Release memory */
	releaseDoubleArray((void**)mySearchZonePPMX.binaryFileNames,mySearchZonePPMX.numberOfBinaryFiles);

	listOfStarsPpmx* theStars = headOfList;

	return (theStars);
}

/**
 * Process one binary file
 */
void processOneFilePPMX(const searchZonePPMX& mySearchZonePPMX,const char* const binaryFileName, elementListPpmx** headOfList) {

	headerInformationPPMX headerInformation;
	const int chunkStart    = mySearchZonePPMX.subSearchZone.raStartInMas >> PPMX_CHUNK_SHIFT_RA;
	const int chunkEnd      = mySearchZonePPMX.subSearchZone.raEndInMas >> PPMX_CHUNK_SHIFT_RA;
	FILE* const inputStream = fopen(binaryFileName,"rb");

	if(inputStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"File %s not found",binaryFileName);
		throw FileNotFoundException(outputLogChar);
	}

	readHeaderPPMX(inputStream, headerInformation, binaryFileName);

	if(mySearchZonePPMX.subSearchZone.isArroundZeroRa) {

		/* From chunkStart to end */
		processChunksPPMX(mySearchZonePPMX,inputStream,headerInformation,chunkStart,headerInformation.lengthOfAcceleratorTable - 1, binaryFileName, headOfList);

		/* From 0 to chunkEnd */
		processChunksPPMX(mySearchZonePPMX,inputStream,headerInformation,0,chunkEnd, binaryFileName, headOfList);

	} else {

		/* From chunkStart to chunkEnd */
		processChunksPPMX(mySearchZonePPMX,inputStream,headerInformation,chunkStart,chunkEnd, binaryFileName, headOfList);
	}

	/* Close all and release memory */
	fclose(inputStream);
	releaseSimpleArray(headerInformation.extraValues2);
	releaseSimpleArray(headerInformation.extraValues4);
	releaseSimpleArray(headerInformation.chunkOffsets);
	releaseSimpleArray(headerInformation.chunkNumberOfStars);
}

/**
 * Process a series of successive chunks of data
 */
void processChunksPPMX(const searchZonePPMX& mySearchZonePPMX,FILE* const inputStream,const headerInformationPPMX& headerInformation,const int chunkStart,const int chunkEnd,
		const char* const binaryFileName, elementListPpmx** headOfList) {

	unsigned char* pointerToBuffer;
	int resultOfFunction;
	int indexOfChunk;
	int indexOfStar;
	int raStart;
	int numberOfStars;

	/* We read all merged chunks to optimise access time to disk */
	const int totalNumberOfStars = sumNumberOfElements(headerInformation.chunkNumberOfStars,chunkStart,chunkEnd);
	const int sizeOfBuffer       = totalNumberOfStars * PPMX_RECORD_LENGTH;
	unsigned char* buffer        = (unsigned char*)malloc(sizeOfBuffer * sizeof(unsigned char));
	if(buffer == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Buffer = %d (unsigned char) out of memory",sizeOfBuffer);
		throw InsufficientMemoryException(outputLogChar);
	}

	if(fseek(inputStream,headerInformation.chunkOffsets[chunkStart],SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Can not move in inputStream by %d",headerInformation.chunkOffsets[chunkStart]);
		throw CanNotReadInStreamException(outputLogChar);
	}

	resultOfFunction = fread(buffer,sizeof(unsigned char),sizeOfBuffer,inputStream);
	if(resultOfFunction != sizeOfBuffer) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Can not read %d (char) from %s",sizeOfBuffer,binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	pointerToBuffer = buffer;

	for(indexOfChunk = chunkStart; indexOfChunk <= chunkEnd; indexOfChunk++) {

		numberOfStars = headerInformation.chunkNumberOfStars[indexOfChunk];
		raStart       = indexOfChunk << PPMX_CHUNK_SHIFT_RA;

		/* Loop over stars */
		for(indexOfStar = 0; indexOfStar <= numberOfStars; indexOfStar++) {
			processBufferedDataPPMX(mySearchZonePPMX,pointerToBuffer,headerInformation,raStart,headOfList);
			/* Move the buffer to read the next star */
			pointerToBuffer += PPMX_RECORD_LENGTH;
		}
	}

	releaseSimpleArray(buffer);
}

/**
 * Process stars in an allocated buffer
 * This method contains the method ed_rec from Francois's code
 */
void processBufferedDataPPMX(const searchZonePPMX& mySearchZonePPMX, unsigned char* buffer,const headerInformationPPMX& headerInformation, const int raStart,
		elementListPpmx** headOfList) {

	int o = 0, i;
	int raInMas;
	int decInMas;
	short int errorRa, errorDec;
	short int errorPmRa, errorPmDec;
	int epRa, epDec;
	int pmRa, pmDec;
	unsigned char nObs; /* Number of observations	*/
	short int magnitudes[7];	/* (mmag) B V J H K C r mags	*/
	short int errorMagnitudes[5];	/* (mmag) Error on magnitudes   */
	char subsetFlag;	/* subset flag			*/
	char fitFlag;		/* Bad fit flag [P]		*/
	char src;		/* source catalog  		*/

	const searchZoneRaDecMas& subSearchZone = mySearchZonePPMX.subSearchZone;

	/* Convert the compacted record */
	raInMas = getBits(buffer, 0, 23) + raStart; o += 23;
	if(
			(subSearchZone.isArroundZeroRa && (raInMas < subSearchZone.raStartInMas) && (raInMas > subSearchZone.raEndInMas)) ||
			(!subSearchZone.isArroundZeroRa && ((raInMas < subSearchZone.raStartInMas) || (raInMas > subSearchZone.raEndInMas)))
	) {
		/* The star is not accepted for output */
		return;
	}

	decInMas = getBits(buffer, o, 25) + headerInformation.decStartInMas; o += 25;
	if((decInMas  < subSearchZone.decStartInMas) || (decInMas > subSearchZone.decEndInMas)) {
		/* The star is not accepted for output */
		return;
	}

	errorRa    = getBits(buffer, o, 10); o += 10;
	errorDec   = getBits(buffer, o, 10); o += 10;
	epRa       = getBits(buffer, o, 14); o += 14;  epRa  += 190000;
	epDec      = getBits(buffer, o, 14); o += 14;  epDec += 190000;
	pmRa       = xget4(buffer, o, 20, 1000000, headerInformation.extraValues4)-500000; o += 20;
	pmDec      = xget4(buffer, o, 20, 1000000, headerInformation.extraValues4)-500000; o += 20;
	errorPmRa  = getBits(buffer, o, 10); o += 10;
	errorPmDec = getBits(buffer, o, 10); o += 10;

	subsetFlag = ppmxSet[getBits(buffer, o, 2)]; o += 2;
	fitFlag    = getBits(buffer, o, 1) ? 'P' : 'G'; o += 1;

	o += 1 /* +UNUSED */ + 4 /* Naming problems */;

	/* Magnitudes (mmag) B V J H K C R mags	*/
	magnitudes[5] = xget2(buffer, o, 14, 16000, headerInformation.extraValues2)+2000; o += 14;
	magnitudes[6] = xget2(buffer, o, 14, 16000, headerInformation.extraValues2)+2000; o += 14;

	/* We consider Rmag = magnitudes[6] for selection */
	if((magnitudes[6] < mySearchZonePPMX.magnitudeBox.magnitudeStartInMilliMag) || (magnitudes[6] > mySearchZonePPMX.magnitudeBox.magnitudeEndInMilliMag)) {
		/* The star is not accepted for output */
		return;
	}

	for (i=0; i<5; i++) {
		magnitudes[i]      = xget2(buffer, o, 14, 16000, headerInformation.extraValues2)+2000; o += 14;
		errorMagnitudes[i] = getBits(buffer, o, 10); o += 10;
		if (errorMagnitudes[i] == (1 << 10) - 1 ) {
			magnitudes[i]      = BAD_MAGNITUDE;
			errorMagnitudes[i] = BAD_MAGNITUDE;
		}
	}
	nObs = getBits(buffer, o, 5); o += 5;
	src  = referenceCatalog[getBits(buffer, o, 3)]; //o += 3;

	/* Add the result to the list of the extracted PPMX stars */
	elementListPpmx* currentElement  = (elementListPpmx*)malloc(sizeof(elementListPpmx));
	if(currentElement             == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : currentElement out of memory 1 oneStarPpmx\n");
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Write out the Declination part of Jname */
	sJname(currentElement->theStar.jName, raInMas, decInMas, (buffer[20] & 0xc0) >> 6);
	currentElement->theStar.ra              = (double)raInMas/DEG2MAS;
	currentElement->theStar.dec             = (double)decInMas / DEG2MAS;
	currentElement->theStar.errorRa         = (double)errorRa / DEG2MAS;
	currentElement->theStar.errorDec        = (double)errorDec / DEG2MAS;
	currentElement->theStar.pmRa            = (double)pmRa / DEG2MAS;
	currentElement->theStar.pmDec           = (double)pmDec / DEG2MAS;
	currentElement->theStar.errorPmRa       = (double)errorPmRa / DEG2MAS;
	currentElement->theStar.errorPmDec      = (double)errorPmDec / DEG2MAS;
	currentElement->theStar.magnitudeC      = (double)magnitudes[5] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeR      = (double)magnitudes[6] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeB      = (double)magnitudes[0] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeV      = (double)magnitudes[1] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeJ      = (double)magnitudes[2] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeH      = (double)magnitudes[3] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeK      = (double)magnitudes[4] / MAG2MILLIMAG;
	currentElement->theStar.errorMagnitudeB = (double)errorMagnitudes[0] / MAG2MILLIMAG;
	currentElement->theStar.errorMagnitudeV = (double)errorMagnitudes[1] / MAG2MILLIMAG;
	currentElement->theStar.errorMagnitudeJ = (double)errorMagnitudes[2] / MAG2MILLIMAG;
	currentElement->theStar.errorMagnitudeH = (double)errorMagnitudes[3] / MAG2MILLIMAG;
	currentElement->theStar.errorMagnitudeK = (double)errorMagnitudes[4] / MAG2MILLIMAG;
	currentElement->theStar.nObs            = nObs;
	currentElement->theStar.fitFlag         = fitFlag;
	currentElement->theStar.subsetFlag      = subsetFlag;
	currentElement->theStar.src             = src;

	currentElement->nextStar                = *headOfList;
	*headOfList                             = currentElement;
}

/*============================================================
 * Francois Ochsenbein's method (sJname)
 * PURPOSE  Convert a RA and Dec into J-name for PPMX
 * RETURNS  [0,max] = standard; >max => saved in header
 * REMARKS  modJ&1 ==> add 1 unit to DE ;
 *          modJ&2 ==> add 1 unit to RA ;
 *============================================================*/
void sJname(char * const str, const int ra, const int de, const int modJ) {

	int val;
	val = de;
	if (val<0) val = -val;
	val = val/1000;	   /* Value in arcsec */
	if (modJ&1) {
		val++;
	}
	str[14] = '0' + val%10;
	val /= 10;   str[13] = '0' + val%6;
	val /=  6;   str[12] = '0' + val%10;
	val /= 10;   str[11] = '0' + val%6;
	val /=  6;   str[10] = '0' + val%10;
	val /= 10;   str[ 9] = '0' + val;
	str[ 8] = de<0 ? '-' : '+';

	/* Write out the RA part of Jname */
	val  = ra - (ra/3);     /* RA in 1/10000s */
	val /= 1000;
	if (modJ&2) {
		val++;
	}
	str[7] = '0' + val%10;
	str[6] = '.';
	val /= 10;   str[5] = '0' + val%10;
	val /= 10;   str[4] = '0' + val%6;
	val /=  6;   str[3] = '0' + val%10;
	val /= 10;   str[2] = '0' + val%6;
	val /=  6;   str[1] = '0' + val%10;
	val /= 10;   str[0] = '0' + val;

	str[15] = '\0';
}


/**
 * Read the header information in the binary file
 */
void readHeaderPPMX(FILE* const inputStream, headerInformationPPMX& headerInformation,const char* const binaryFileName) {

	int index;
	int indexPlusOne;
	int sumOfStar;
	int lastIndex;
	char binaryHeaderPPMX[PPMX_HEADER_LENGTH];
	char fileNameInHeader[PPMX_HEADER_LENGTH];
	int totalNumberOfStars;
	int resultOfFunction = fread(binaryHeaderPPMX,sizeof(char),PPMX_HEADER_LENGTH,inputStream);

	if(resultOfFunction != PPMX_HEADER_LENGTH) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error when reading the header from the binary file %s",binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Check that this file is PPMX */
	index = strloc(PPMX_HEADER_FORMAT, '(');
	if (strncmp(binaryHeaderPPMX, PPMX_HEADER_FORMAT, index+1) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar, "File %s is not PPMX", binaryFileName);
		throw InvalidDataException(outputLogChar);
	}

	sscanf(binaryHeaderPPMX,PPMX_HEADER_FORMAT,fileNameInHeader,&totalNumberOfStars,
			&(headerInformation.lengthOfAcceleratorTable),&(headerInformation.numberOfExtra4),
			&(headerInformation.numberOfExtra2),&(headerInformation.decStartInMas));

	if(DEBUG) {
		printf("binaryHeaderPPMX                           = %s\n",binaryHeaderPPMX);
		printf("totalNumberOfStars                         = %d\n",totalNumberOfStars);
		printf("headerInformation.lengthOfAcceleratorTable = %d\n",headerInformation.lengthOfAcceleratorTable);
		printf("headerInformation.numberOfExtra4           = %d\n",headerInformation.numberOfExtra4);
		printf("headerInformation.numberOfExtra2           = %d\n",headerInformation.numberOfExtra2);
		printf("headerInformation.decStartInMas            = %d\n",headerInformation.decStartInMas);
	}

	/* Allocate memory */
	headerInformation.chunkOffsets = (int*)malloc(headerInformation.lengthOfAcceleratorTable * sizeof(int));
	if(headerInformation.chunkOffsets == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"headerInformation.chunkOffsets = %d(int) out of memory",headerInformation.lengthOfAcceleratorTable);
		throw InsufficientMemoryException(outputLogChar);
	}
	headerInformation.chunkNumberOfStars = (int*)malloc(headerInformation.lengthOfAcceleratorTable * sizeof(int));
	if(headerInformation.chunkNumberOfStars == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"headerInformation.chunkNumberOfStars = %d(int) out of memory",headerInformation.lengthOfAcceleratorTable);
		throw InsufficientMemoryException(outputLogChar);
	}
	headerInformation.extraValues2 = (short*)malloc(headerInformation.numberOfExtra2 * sizeof(short));
	if(headerInformation.extraValues2 == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"headerInformation.extraValues2 = %d(short) out of memory",headerInformation.numberOfExtra2);
		throw InsufficientMemoryException(outputLogChar);
	}
	headerInformation.extraValues4 = (int*)malloc(headerInformation.numberOfExtra4 * sizeof(int));
	if(headerInformation.extraValues4 == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"headerInformation.extraValues4 = %d(int) out of memory",headerInformation.numberOfExtra4);
		throw InsufficientMemoryException(outputLogChar);
	}

	/* Read from file */
	resultOfFunction = fread(headerInformation.chunkOffsets,sizeof(int),headerInformation.lengthOfAcceleratorTable,inputStream);
	if(resultOfFunction != headerInformation.lengthOfAcceleratorTable) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error when reading headerInformation.chunkOffsets from the binary file %s",binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}
	resultOfFunction = fread(headerInformation.extraValues2,sizeof(short),headerInformation.numberOfExtra2,inputStream);
	if(resultOfFunction != headerInformation.numberOfExtra2) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error when reading headerInformation.extraValues2 from the binary file %s",binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}
	resultOfFunction = fread(headerInformation.extraValues4,sizeof(int),headerInformation.numberOfExtra4,inputStream);
	if(resultOfFunction != headerInformation.numberOfExtra4) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error when reading headerInformation.extraValues4 from the binary file %s",binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Swap values because data is written in Big_endian */
	convertBig2LittleEndianForArrayOfInteger(headerInformation.chunkOffsets,headerInformation.lengthOfAcceleratorTable);
	convertBig2LittleEndianForArrayOfInteger(headerInformation.extraValues4,headerInformation.numberOfExtra4);
	convertBig2LittleEndianForArrayOfShort(headerInformation.extraValues2,headerInformation.numberOfExtra2);

	lastIndex      = headerInformation.lengthOfAcceleratorTable - 1;
	sumOfStar      = 0;
	index          = 0;
	indexPlusOne   = 1;
	while(index    < lastIndex) {
		headerInformation.chunkNumberOfStars[index] =
				(headerInformation.chunkOffsets[indexPlusOne] - headerInformation.chunkOffsets[index]) / PPMX_RECORD_LENGTH;
		sumOfStar += headerInformation.chunkNumberOfStars[index];
		index      = indexPlusOne;
		indexPlusOne++;
	}

	headerInformation.chunkNumberOfStars[lastIndex] = totalNumberOfStars - sumOfStar;
	if(headerInformation.chunkNumberOfStars[lastIndex] < 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"The number of stars is not coherent in %s",binaryFileName);
		releaseSimpleArray(headerInformation.extraValues2);
		releaseSimpleArray(headerInformation.extraValues4);
		releaseSimpleArray(headerInformation.chunkOffsets);
		releaseSimpleArray(headerInformation.chunkNumberOfStars);
		throw InvalidDataException(outputLogChar);
	}
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 */
searchZonePPMX findSearchZonePPMX(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax) {

	searchZonePPMX mySearchZonePPMX;
	int indexStarDec;
	int indexEndDec;
	int indexDec;
	int counter;

	fillSearchZoneRaDecMas(mySearchZonePPMX.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(mySearchZonePPMX.magnitudeBox, magMin, magMax);

	/* Now we find the binary files which will opened during this process */
	if ((mySearchZonePPMX.subSearchZone.decStartInMas < 0) && (mySearchZonePPMX.subSearchZone.decEndInMas > 0)) {

		/* (declinationStartInMas < 0) & (declinationEndInMas > 0) */
		indexStarDec = -mySearchZonePPMX.subSearchZone.decStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = mySearchZonePPMX.subSearchZone.decEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexStarDec + indexEndDec + 2;
		allocateMemoryForSearchZonePPMX(mySearchZonePPMX);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		/* South */
		for(indexDec = indexStarDec; indexDec >= 0; indexDec--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_SOUTH,ppxZoneNames[indexDec]);
			counter++;
		}
		/* North */
		for(indexDec = 0; indexDec <= indexEndDec; indexDec++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_NORTH,ppxZoneNames[indexDec]);
			counter++;
		}

	} else if (mySearchZonePPMX.subSearchZone.decStartInMas < 0) {

		/* (declinationStartInMas < 0) & (declinationEndInMas < 0) */
		indexStarDec = -mySearchZonePPMX.subSearchZone.decStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = -mySearchZonePPMX.subSearchZone.decEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexStarDec - indexEndDec + 1;
		allocateMemoryForSearchZonePPMX(mySearchZonePPMX);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		for(indexDec = indexStarDec; indexDec >= indexEndDec; indexDec--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_SOUTH,ppxZoneNames[indexDec]);
			counter++;
		}

	} else {

		/* (declinationStartInMas > 0) & (declinationEndInMas > 0) */
		indexStarDec = mySearchZonePPMX.subSearchZone.decStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = mySearchZonePPMX.subSearchZone.decEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexEndDec - indexStarDec + 1;
		allocateMemoryForSearchZonePPMX(mySearchZonePPMX);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		for(indexDec = indexStarDec; indexDec <= indexEndDec; indexDec++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_NORTH,ppxZoneNames[indexDec]);
			counter++;
		}
	}

	if(DEBUG) {
		printf("mySearchZonePPMX.numberOfBinaryFiles = %d\n",mySearchZonePPMX.numberOfBinaryFiles);
		for(counter = 0; counter < mySearchZonePPMX.numberOfBinaryFiles; counter++) {
			printf("mySearchZonePPMX.binaryFileNames[%d] = %s\n",counter,mySearchZonePPMX.binaryFileNames[counter]);
		}
	}

	return (mySearchZonePPMX);
}

/**
 * Allocate file names in searchZonePPMX
 */
void allocateMemoryForSearchZonePPMX(searchZonePPMX& mySearchZonePPMX) {

	int index;

	mySearchZonePPMX.binaryFileNames = (char**)malloc(mySearchZonePPMX.numberOfBinaryFiles * sizeof(char*));
	if(mySearchZonePPMX.binaryFileNames == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : mySearchZonePPMX.binaryFileNames[%d] out of memory\n",mySearchZonePPMX.numberOfBinaryFiles);
		mySearchZonePPMX.numberOfBinaryFiles = -1;
		return;
	}

	for(index = 0; index < mySearchZonePPMX.numberOfBinaryFiles; index++) {
		mySearchZonePPMX.binaryFileNames[index] = (char*)malloc(PPMX_BINARY_FILE_NAME_LENGTH * sizeof(char));
		if(mySearchZonePPMX.binaryFileNames[index] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Error : mySearchZonePPMX.binaryFileNames[%d] = %d (char) out of memory\n",index,PPMX_BINARY_FILE_NAME_LENGTH);
			mySearchZonePPMX.numberOfBinaryFiles = -1;
			return;
		}
	}
}

void CCatalog::releaseListOfStarPpmx(listOfStarsPpmx* listOfStars) {

	elementListPpmx* currentElement = listOfStars;
	elementListPpmx* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
