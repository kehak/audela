/*
 * nomad1.c
 *
 *  Created on: 27/03/2013
 *      Author: Y. Damerdji
 */
#include "CCatalog.h"
#include "csnomad1.h"

char NOMAD1_HEADER_FORMAT[] = "NOMAD-1.0(%d) %d/N%d.bin %d-%d  pm=%d mag=%d Ep=%d xtra=%d,%d UCAC2=%d(%07d/%07d) Tyc2=%d";

/**
 * Cone search on PPMX catalog
 */
listOfStarsNomad1* CCatalog::csnomad1 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) {

	int indexOfFile;
	char binaryFileName[STRING_COMMON_LENGTH];

	/* Define the search zone */
	const searchZoneNOMAD1& mySearchZoneNOMAD1 = findSearchZoneNOMAD1(ra,dec,radius,magMin,magMax);
	if(mySearchZoneNOMAD1.numberOfBinaryFiles < 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"mySearchZoneNOMAD1.numberOfBinaryFiles = %d should be > 0\n",mySearchZoneNOMAD1.numberOfBinaryFiles);
		throw InvalidDataException(outputLogChar);
	}

	elementListNomad1* headOfList = NULL;

	/* No we loop over the binary files to be opened, we process them one by one */
	for(indexOfFile = 0; indexOfFile < mySearchZoneNOMAD1.numberOfBinaryFiles; indexOfFile++) {

		sprintf(binaryFileName,"%s%s",pathToCatalog,mySearchZoneNOMAD1.binaryFileNames[indexOfFile]);
		processOneFileNOMAD1(mySearchZoneNOMAD1,binaryFileName,&headOfList);
	}

	/* Release memory */
	releaseDoubleArray((void**)mySearchZoneNOMAD1.binaryFileNames,mySearchZoneNOMAD1.numberOfBinaryFiles);

	listOfStarsNomad1* theStars = headOfList;

	return (theStars);
}

/**
 * Process one binary file
 */
void processOneFileNOMAD1(const searchZoneNOMAD1& mySearchZoneNOMAD1, const char* const binaryFileName, elementListNomad1** headOfList) {

	int chunkNumber;
	headerInformationNOMAD1 headerInformation;
	int chunkStart;
	int chunkEnd;
	FILE* const inputStream = fopen(binaryFileName,"rb");

	if(inputStream == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"File %s not found",binaryFileName);
		throw FileNotFoundException(outputLogChar);
	}

	readHeaderNOMAD1(inputStream, headerInformation, binaryFileName);

	if(headerInformation.numberOfChunks == 1) {
		/* For regions near the poles, only one chunk in binary file : we process chunk 0, it contains all 360deg of RA */
		processChunksNOMAD1(mySearchZoneNOMAD1,inputStream,headerInformation,0, binaryFileName,headOfList);

	} else {

		/* Chunk number = ra >> 24 */
		chunkStart = mySearchZoneNOMAD1.subSearchZone.raStartInMas >> NOMAD1_CHUNK_SHIFT_RA;
		chunkEnd   = mySearchZoneNOMAD1.subSearchZone.raEndInMas >> NOMAD1_CHUNK_SHIFT_RA;

		if(mySearchZoneNOMAD1.subSearchZone.isArroundZeroRa) {

			/* From chunkStart to end */
			for(chunkNumber = chunkStart; chunkNumber < headerInformation.numberOfChunks; chunkNumber++) {
				processChunksNOMAD1(mySearchZoneNOMAD1,inputStream,headerInformation,chunkNumber, binaryFileName,headOfList);

			}

			/* From 0 to chunkEnd */
			for(chunkNumber = 0; chunkNumber <= chunkEnd; chunkNumber++) {
				processChunksNOMAD1(mySearchZoneNOMAD1,inputStream,headerInformation,chunkNumber, binaryFileName,headOfList);

			}

		} else {

			/* From chunkStart to chunkEnd */
			for(chunkNumber = chunkStart; chunkNumber <= chunkEnd; chunkNumber++) {
				processChunksNOMAD1(mySearchZoneNOMAD1,inputStream,headerInformation,chunkNumber, binaryFileName,headOfList);
			}
		}
	}

	/* Close inputStream */
	fclose(inputStream);
}

/**
 * Process a series of successive chunks of data
 */
void processChunksNOMAD1(const searchZoneNOMAD1& mySearchZoneNOMAD1, FILE* const inputStream,
		headerInformationNOMAD1& headerInformation,const int chunkNumber, const char* const binaryFileName, elementListNomad1** headOfList) {

	unsigned char* buffer;
	unsigned char* pointerToBuffer;
	int resultOfFunction;
	int firstOffsetInChunk;
	int lengthOfRecord;
	int raStartSubChunk;
	int raEndSubChunk;
	int* acceleratorTable;
	int lengthOfAcceleratorTable;
	int sizeOfSubChunk;
	int indexOfSubChunk;
	int index;
	int numberOfSubChunks;
	int* arrayOfIntegers;
	short int* arrayOfShorts;
	const int indexInTable = chunkNumber << 1;
	const int sizeOfBuffer = headerInformation.chunkTable[indexInTable + 2] - headerInformation.chunkTable[indexInTable];

	if(sizeOfBuffer <= 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"chunk %d : sizeOfBuffer = %d is not valid",indexInTable,sizeOfBuffer);
		throw InvalidDataException(outputLogChar);
	}

	buffer    = (unsigned char*)malloc(sizeOfBuffer * sizeof(unsigned char));
	if(buffer == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Buffer = %d (unsigned char) out of memory",sizeOfBuffer);
		throw InsufficientMemoryException(outputLogChar);
	}

	if(fseek(inputStream,headerInformation.chunkTable[indexInTable],SEEK_SET) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Can not move by %d in inputStream",headerInformation.chunkTable[indexInTable]);
		throw CanNotReadInStreamException(outputLogChar);
	}


	resultOfFunction = fread(buffer,sizeof(unsigned char),sizeOfBuffer,inputStream);
	if(resultOfFunction != sizeOfBuffer) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Can not read %d (char) from %s",sizeOfBuffer,binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Read the preface of the chunk */
	pointerToBuffer  = buffer;
	arrayOfIntegers  = (int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfInteger(arrayOfIntegers,NOMAD1_CHUNK_HEADER_NUMBER_OF_INTEGERS);
	/* prefaceLength */
	headerInformation.theChunkHeader.prefaceLength = arrayOfIntegers[0];
	/* id0 */
	headerInformation.theChunkHeader.id0           = arrayOfIntegers[1];
	/* ra0 */
	headerInformation.theChunkHeader.ra0           = arrayOfIntegers[2];
	/* spd0 */
	headerInformation.theChunkHeader.spd0          = arrayOfIntegers[3];
	/* id1 */
	headerInformation.theChunkHeader.id1           = arrayOfIntegers[4];
	/* ra1 */
	headerInformation.theChunkHeader.ra1           = arrayOfIntegers[5];
	/* spd1 */
	headerInformation.theChunkHeader.spd1          = arrayOfIntegers[6];

	pointerToBuffer += NOMAD1_CHUNK_HEADER_NUMBER_OF_INTEGERS * sizeof(int);
	arrayOfShorts    = (short int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfShort(arrayOfShorts,NOMAD1_CHUNK_HEADER_NUMBER_OF_SHORTS);
	/* numberOfExtra2 */
	headerInformation.theChunkHeader.numberOfExtra2 = arrayOfShorts[0];
	/* numberOfExtra4 */
	headerInformation.theChunkHeader.numberOfExtra4 = arrayOfShorts[1];
	pointerToBuffer += NOMAD1_CHUNK_HEADER_NUMBER_OF_SHORTS * sizeof(short int);
	/* extra values 4 */
	headerInformation.theChunkHeader.extraValues4  = (int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfInteger(headerInformation.theChunkHeader.extraValues4,
			(int)headerInformation.theChunkHeader.numberOfExtra4);
	/* extra values 2 */
	pointerToBuffer += headerInformation.theChunkHeader.numberOfExtra4 * sizeof(int);
	headerInformation.theChunkHeader.extraValues2  = (short int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfShort(headerInformation.theChunkHeader.extraValues2,
			(int)headerInformation.theChunkHeader.numberOfExtra2);

	/* Now we read the accelerator table of the chunk
	 * Note that we have to move by at most 3 bytes after extraValues3 (multiple of 4bytes) */
	pointerToBuffer    = buffer + headerInformation.theChunkHeader.prefaceLength;
	acceleratorTable   = (int*)pointerToBuffer;
	firstOffsetInChunk = acceleratorTable[0];
	firstOffsetInChunk = convertBig2LittleEndianForInteger(firstOffsetInChunk);

	lengthOfAcceleratorTable = (firstOffsetInChunk - headerInformation.theChunkHeader.prefaceLength) / sizeof(int);
	numberOfSubChunks        = lengthOfAcceleratorTable / NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION;
	convertBig2LittleEndianForArrayOfInteger(acceleratorTable, lengthOfAcceleratorTable);

	if(DEBUG) {
		printf("binaryFileName           = %s\n",binaryFileName);
		printf("chunkNumber              = %d\n",chunkNumber);
		printf("chunk offset             = %d\n",headerInformation.chunkTable[indexInTable]);
		printf("prefaceLength            = %d\n",headerInformation.theChunkHeader.prefaceLength);
		printf("numberOfExtra2           = %d\n",headerInformation.theChunkHeader.numberOfExtra2);
		printf("numberOfExtra4           = %d\n",headerInformation.theChunkHeader.numberOfExtra4);
		printf("firstOffsetInChunk       = %d\n",firstOffsetInChunk);
		printf("numberOfSubChunks        = %d\n",numberOfSubChunks);
		for(indexOfSubChunk = 0; indexOfSubChunk < numberOfSubChunks; indexOfSubChunk++) {
			index = NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION * indexOfSubChunk;
			printf("offset[%d] = %d - id[%d] = %d - ra[%d] = %d\n",
					indexOfSubChunk,acceleratorTable[index],
					indexOfSubChunk,acceleratorTable[index + 1],
					indexOfSubChunk,acceleratorTable[index + 2]);
		}
	}

	/* We use the accelerator table : since it is a small table, we do not use dichotomy */
	for(indexOfSubChunk = 0; indexOfSubChunk < numberOfSubChunks - 1; indexOfSubChunk++) {
		/* Check if there is an intersection between what we search and the available */
		index           = NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION * indexOfSubChunk;
		raStartSubChunk = acceleratorTable[index + 2];
		raEndSubChunk   = acceleratorTable[index + 2 + NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION];

		if(
				((mySearchZoneNOMAD1.subSearchZone.raStartInMas >= raStartSubChunk) && (mySearchZoneNOMAD1.subSearchZone.raStartInMas <= raEndSubChunk))
				||
				((mySearchZoneNOMAD1.subSearchZone.raEndInMas >= raStartSubChunk) && (mySearchZoneNOMAD1.subSearchZone.raEndInMas <= raEndSubChunk))
		) {

			/* We process this sub-chunk : there is a common region of RA to explore */
			pointerToBuffer  = buffer + acceleratorTable[index];
			sizeOfSubChunk   = acceleratorTable[index + NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION] - acceleratorTable[index];
			headerInformation.theChunkHeader.id = acceleratorTable[index + 1];

			while(sizeOfSubChunk > 0) {

				processBufferedDataNOMAD1(mySearchZoneNOMAD1,pointerToBuffer,headerInformation,lengthOfRecord, headOfList);
				/* Move the buffer to read the next star */
				pointerToBuffer += lengthOfRecord;
				sizeOfSubChunk  -= lengthOfRecord;
				headerInformation.theChunkHeader.id++;
			}

			// sizeOfSubChunk should be equal to 0 at the end of this loop
			if(sizeOfSubChunk != 0) {
				char outputLogChar[STRING_COMMON_LENGTH];
				sprintf(outputLogChar,"Buffer = %d (unsigned char) : error when reading records",sizeOfSubChunk);
				throw InvalidDataException(outputLogChar);
			}
		}
	}

	/* Release the buffer */
	pointerToBuffer = buffer;
	releaseSimpleArray(buffer);
}

/**
 * Process stars in an allocated buffer
 * This method contains the method ed_rec from Francois's code
 */
void processBufferedDataNOMAD1(const searchZoneNOMAD1& mySearchZoneNOMAD1, unsigned char* buffer,
		const headerInformationNOMAD1& headerInformation, int& lengthOfRecord, elementListNomad1** headOfList) {

	unsigned char presence;
	int status, m, i;

	int zoneNOMAD, zoneUSNO;          /* Zones: NOMAD, and USNO-B	*/
	int idNOMAD, idUSNO;              /* Identifications: NOMAD USNO  */
	int flags;                        /* Flags as defined in read-me*/
	int raInMas, spdInMas ;           /* RA and S. Polar Dist. mas	*/
	short int errorRa, errorSpd;      /* sd Position RA/Dec, mas	*/
	int epochRa, epochDec;            /* The 2 epochs, in 0.1yr	*/
	int pmRa, pmDec;                  /* Proper Motions in 0.1mas/yr	*/
	short int errorPmRa, errorPmDec;  /* sd Proper Motions 0.1mas/yr	*/
	short int mag[6];                 /* Magnitudes B V R J H K	*/
	unsigned char abvr[4];            /* Refs. Astrometry B V R : 1..9 = USNO,2MASS,YB6,UCAC2,Tycho2,Hip,.,O,E */
	int  idUCAC2;                     /* UCAC2 Identifier */
	int idTYC1, idTYC2, idTYC3;       /* Identifiers */
	short int flagFarTYC;             /* Flag r>0.3(1), 1"(2), 3"(3) */
	int idHIP;                        /* Hipparcos number */

	const searchZoneRaSpdMas& subSearchZone = mySearchZoneNOMAD1.subSearchZone;

	lengthOfRecord = 0;

	/* Convert the compacted record */
	presence    = *buffer;			/* presence of mags and IDs */
	zoneNOMAD   = headerInformation.zoneNumber;
	zoneUSNO    = 0;
	idNOMAD     = headerInformation.theChunkHeader.id;

	/* USNO-B Name */
	idUSNO         = (buffer[1]<<16)|(buffer[2]<<8)|buffer[3];
	if (idUSNO) {
		zoneUSNO   = zoneNOMAD;
		if (idUSNO & 0x800000) {zoneUSNO -= 1;}
		if (idUSNO & 0x400000) {zoneUSNO += 1;}
		idUSNO    &= 0x3fffff;
	}

	raInMas       = (buffer[4]<<16) | (buffer[5]<<8) | buffer[6];
	if (headerInformation.numberOfChunks == 1) {
		++buffer;
		lengthOfRecord++;
		raInMas <<= 8;
		raInMas  |= buffer[6];
	}
	raInMas   += headerInformation.theChunkHeader.ra0;

	errorRa    = getBits(buffer+7, 0, 10);
	epochRa    = getBits(buffer+8, 2, 10) + headerInformation.ep;

	spdInMas   = getBits(buffer+9, 4, 20);
	spdInMas  += headerInformation.theChunkHeader.spd0;

	errorSpd   = getBits(buffer+12, 0, 10);
	epochDec   = getBits(buffer+13, 2, 10) + headerInformation.ep;

	pmRa       = getExtraValues(getBits(buffer+14, 4, 14), EXTRA_14_2, EXTRA_14_4,
			headerInformation.theChunkHeader.extraValues4, headerInformation.theChunkHeader.extraValues2) + headerInformation.pm;
	pmDec      = getExtraValues(getBits(buffer+16, 2, 14), EXTRA_14_2, EXTRA_14_4,
			headerInformation.theChunkHeader.extraValues4, headerInformation.theChunkHeader.extraValues2) + headerInformation.pm;
	errorPmRa  = getExtraValues(getBits(buffer+18, 0, 13), EXTRA_13_2, EXTRA_13_4,
			headerInformation.theChunkHeader.extraValues4, headerInformation.theChunkHeader.extraValues2);
	errorPmDec = getExtraValues(getBits(buffer+19, 5, 13), EXTRA_13_2, EXTRA_13_4,
			headerInformation.theChunkHeader.extraValues4, headerInformation.theChunkHeader.extraValues2);

	status     = ((buffer[21]&0x3f)<<24) | (buffer[22]<<16) | (buffer[23]<<8) | buffer[24];
	flags      = status >> 12;

	/* Fixed-length part done. */
	buffer         += NOMAD1_RECORD_LENGTH;
	lengthOfRecord += NOMAD1_RECORD_LENGTH;

	/* UCAC2 */
	idUCAC2             = 0;
	if (presence & 0x80) {
		idUCAC2         = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
		buffer         += 4;
		lengthOfRecord += 4;
	}

	flagFarTYC = 0;
	idHIP      = 0;
	idTYC1     = 0;
	idTYC2     = 0;
	idTYC3     = 0;
	/* Tycho */
	if (presence&0x40) {
		flagFarTYC = buffer[0] >> 7;
		idTYC3     = (int)getBits(buffer, 29, 3);
		if (idTYC3 == 0)
			idHIP  = (getBits(buffer, 1, 28)) % 1000000;
		else {
			idTYC1 = (int)getBits(buffer, 1, 14);
			idTYC2 = (int)getBits(buffer, 15, 14);
		}
		buffer         += 4;
		lengthOfRecord += 4;
	}

	/* Magnitudes */
	for (i=0, m = 0x20; i<6; i++, m >>= 1) {
		if (presence & m) {
			mag[i]          = ((buffer[0] << 8) | buffer[1]) + headerInformation.mag;
			buffer         += 2;
			lengthOfRecord += 2;
		} else {
			mag[i]  = (short)0x8000 ;	/* -32768 */
		}
	}

	/* Sources */
	abvr[0] = status & 7;
	abvr[1] = (status >> 3) & 7;	/* Blue photometry */
	abvr[2] = (status >> 6) & 7;	/* V    photometry */
	abvr[3] = (status >> 9) & 7;	/* Red  photometry */
	if (flags & NOMAD_OMAGBIT) {abvr[1] = 8;}
	if (flags & NOMAD_EMAGBIT) {abvr[3] = 9;}

	/* Unfortunately the conditions have to be after decoding all argument : we need to output the total record length ! */
	if(
			(subSearchZone.isArroundZeroRa && (raInMas < subSearchZone.raStartInMas) && (raInMas > subSearchZone.raEndInMas)) ||
			(!subSearchZone.isArroundZeroRa && ((raInMas < subSearchZone.raStartInMas) || (raInMas > subSearchZone.raEndInMas)))
	) {
		/* The star is not accepted for output */
		return;
	}

	if((spdInMas  < subSearchZone.spdStartInMas) || (spdInMas > subSearchZone.spdEndInMas)) {
		/* The star is not accepted for output */
		return;
	}

	/* We consider Rmag = mag[2] for selection */
	if((mag[2] < mySearchZoneNOMAD1.magnitudeBox.magnitudeStartInMilliMag) || (mag[2] > mySearchZoneNOMAD1.magnitudeBox.magnitudeEndInMilliMag)) {
		/* The star is not accepted for output */
		return;
	}

	/* Add the result to the list of the extracted NOMAD1 stars */
	elementListNomad1* currentElement  = (elementListNomad1*)malloc(sizeof(elementListNomad1));
	if(currentElement             == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : currentElement out of memory 1 elementListNomad1\n");
		throw InsufficientMemoryException(outputLogChar);
	}
	currentElement->theStar.zoneNOMAD      = zoneNOMAD;
	currentElement->theStar.idNOMAD        = idNOMAD;
	currentElement->theStar.origineAstro   = abvr[0];
	currentElement->theStar.ra             = (double)raInMas/DEG2MAS;
	currentElement->theStar.dec            = (double) (spdInMas + DEC_SOUTH_POLE_MAS) / DEG2MAS;
	currentElement->theStar.errorRa        = (double)errorRa / DEG2MAS;
	currentElement->theStar.errorDec       = (double)errorSpd / DEG2MAS;
	currentElement->theStar.pmRa           = (double)pmRa / DEG2DECIMAS;
	currentElement->theStar.pmDec          = (double)pmDec / DEG2DECIMAS;
	currentElement->theStar.errorPmRa      = (double)errorPmRa / DEG2DECIMAS;
	currentElement->theStar.errorPmDec     = (double)errorPmDec / DEG2DECIMAS;
	currentElement->theStar.epochRa        = epochRa / 10.;
	currentElement->theStar.epochDec       = epochDec / 10.;
	currentElement->theStar.origineMagB    = abvr[1];
	currentElement->theStar.magnitudeB     = (double)mag[0] / MAG2MILLIMAG;
	currentElement->theStar.origineMagV    = abvr[2];
	currentElement->theStar.magnitudeV     = (double)mag[1] / MAG2MILLIMAG;
	currentElement->theStar.origineMagR    = abvr[3];
	currentElement->theStar.magnitudeR     = (double)mag[2] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeJ     = (double)mag[3] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeH     = (double)mag[4] / MAG2MILLIMAG;
	currentElement->theStar.magnitudeK     = (double)mag[5] / MAG2MILLIMAG;
	currentElement->theStar.idUCAC2        = idUCAC2;
	currentElement->theStar.idHIP          = idHIP;
	currentElement->theStar.idTYC1         = idTYC1;
	currentElement->theStar.idTYC2         = idTYC2;
	currentElement->theStar.idTYC3         = idTYC3;
	currentElement->theStar.flagDistTYC    = flagFarTYC;
	//printf("currentElement = %d\n",currentElement);
	currentElement->nextStar               = *headOfList;
	*headOfList                            = currentElement;
}

/*==================================================================
		Convert the Input Record(s)
.PURPOSE  Retrieve a value from Index
.RETURNS  The Value
 *==================================================================*/
int getExtraValues(const int value, const int max, const int max2, const int* const extraValue4, const short int* const extraValue2) {

	if (value <= max) {
		return(value);
	}

	if(value > max2) {
		return (extraValue4[value-max2-1]);
	} else {
		return (extraValue2[value-max -1]);
	}
}

/**
 * Read the header information in the binary file
 */
void readHeaderNOMAD1(FILE* const inputStream, headerInformationNOMAD1& headerInformation, const char* const binaryFileName) {

	char binaryHeaderNOMAD1[NOMAD1_HEADER_LENGTH];
	int index;
	int resultOfFunction = fread(binaryHeaderNOMAD1,sizeof(char),NOMAD1_HEADER_LENGTH,inputStream);
	int temp;

	if(resultOfFunction != NOMAD1_HEADER_LENGTH) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error when reading the header from the binary file %s",binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Check that this file is NOMAD-1.0 */
	index = strloc(NOMAD1_HEADER_FORMAT, '(');
	if (strncmp(binaryHeaderNOMAD1, NOMAD1_HEADER_FORMAT, index+1) != 0) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar, "File %s is not NOMAD-1.0", binaryFileName);
		throw InvalidDataException(outputLogChar);
	}

	sscanf(binaryHeaderNOMAD1,NOMAD1_HEADER_FORMAT,&temp,&temp,&(headerInformation.zoneNumber),&temp,&temp,
			&(headerInformation.pm),&(headerInformation.mag),&(headerInformation.ep),
			&temp,&temp,&temp,&temp,&temp,&temp);

	/* Read from file */
	resultOfFunction = fread(headerInformation.chunkTable,sizeof(int),NOMAD1_LENTGH_ACCELERATOR_TABLE,inputStream);
	if(resultOfFunction != NOMAD1_LENTGH_ACCELERATOR_TABLE) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error when reading headerInformation.chunkTable from the binary file %s",binaryFileName);
		throw CanNotReadInStreamException(outputLogChar);
	}

	/* Swap values because data is written in Big_endian */
	convertBig2LittleEndianForArrayOfInteger(headerInformation.chunkTable,NOMAD1_LENTGH_ACCELERATOR_TABLE);

	/* Find the actual end of Chunks -- there may be zeroes */
	for (index = 2; (index  < NOMAD1_LENTGH_ACCELERATOR_TABLE) && (headerInformation.chunkTable[index]); index += 2) ;
	headerInformation.numberOfChunks = index >> 1;		/* 2 numbers (o,ID) per chunk   */
	headerInformation.numberOfChunks--;			/* Actually, last indicates EOF */

	if(DEBUG) {
		printf("binaryFileName                             = %s\n",binaryFileName);
		printf("binaryHeaderNOMAD1                         = %s\n",binaryHeaderNOMAD1);
		printf("headerInformation.pm                       = %d\n",headerInformation.pm);
		printf("headerInformation.mag                      = %d\n",headerInformation.mag);
		printf("headerInformation.ep                       = %d\n",headerInformation.ep);
		printf("headerInformation.numberOfChunks           = %d\n",headerInformation.numberOfChunks);
	}
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 */
searchZoneNOMAD1 findSearchZoneNOMAD1(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneNOMAD1 mySearchZoneNOMAD1;
	int indexStartSpd;
	int indexEndSpd;
	int indexSpd;
	int indexBigSpd;
	int counter;

	fillSearchZoneRaSpdMas(mySearchZoneNOMAD1.subSearchZone, raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(mySearchZoneNOMAD1.magnitudeBox, magMin, magMax);

	indexStartSpd = mySearchZoneNOMAD1.subSearchZone.spdStartInMas / NOMAD1_SPD_STEP;
	indexEndSpd   = mySearchZoneNOMAD1.subSearchZone.spdEndInMas / NOMAD1_SPD_STEP;

	mySearchZoneNOMAD1.numberOfBinaryFiles = indexEndSpd - indexStartSpd + 1;

	allocateMemoryForSearchZoneNOMAD1(mySearchZoneNOMAD1);
	if(mySearchZoneNOMAD1.numberOfBinaryFiles < 0) {
		return(mySearchZoneNOMAD1);
	}

	counter      = 0;
	for(indexSpd = indexStartSpd; indexSpd <= indexEndSpd; indexSpd++) {
		indexBigSpd = indexSpd / NOMAD1_NUMBER_OF_FILES_PER_SUBDIRECTORY;
		sprintf(mySearchZoneNOMAD1.binaryFileNames[counter],NOMAD1_BINARY_FILE_NAME_FORMAT,indexBigSpd,indexSpd);
		counter++;
	}

	if(DEBUG) {
		printf("mySearchZoneNOMAD1.numberOfBinaryFiles = %d\n",mySearchZoneNOMAD1.numberOfBinaryFiles);
		for(counter = 0; counter < mySearchZoneNOMAD1.numberOfBinaryFiles; counter++) {
			printf("mySearchZoneNOMAD1.binaryFileNames[%d] = %s\n",counter,mySearchZoneNOMAD1.binaryFileNames[counter]);
		}
	}

	return (mySearchZoneNOMAD1);
}

/**
 * Allocate file names in searchZoneNOMAD1
 */
void allocateMemoryForSearchZoneNOMAD1(searchZoneNOMAD1& mySearchZoneNOMAD1) {

	int index;

	mySearchZoneNOMAD1.binaryFileNames = (char**)malloc(mySearchZoneNOMAD1.numberOfBinaryFiles * sizeof(char*));
	if(mySearchZoneNOMAD1.binaryFileNames == NULL) {
		char outputLogChar[STRING_COMMON_LENGTH];
		sprintf(outputLogChar,"Error : mySearchZoneNOMAD1.binaryFileNames[%d] out of memory\n",mySearchZoneNOMAD1.numberOfBinaryFiles);
		mySearchZoneNOMAD1.numberOfBinaryFiles = -1;
		throw InsufficientMemoryException(outputLogChar);
	}

	for(index = 0; index < mySearchZoneNOMAD1.numberOfBinaryFiles; index++) {
		mySearchZoneNOMAD1.binaryFileNames[index] = (char*)malloc(NOMAD1_BINARY_FILE_NAME_LENGTH * sizeof(char));
		if(mySearchZoneNOMAD1.binaryFileNames[index] == NULL) {
			char outputLogChar[STRING_COMMON_LENGTH];
			sprintf(outputLogChar,"Error : mySearchZoneNOMAD1.binaryFileNames[%d] = %d (char) out of memory\n",index,NOMAD1_BINARY_FILE_NAME_LENGTH);
			mySearchZoneNOMAD1.numberOfBinaryFiles = -1;
			throw InsufficientMemoryException(outputLogChar);
		}
	}
}

void CCatalog::releaseListOfStarNomad1(listOfStarsNomad1* listOfStars) {

	elementListNomad1* currentElement = listOfStars;
	elementListNomad1* theNextElement;

	while(currentElement) {

		theNextElement = currentElement->nextStar;
		free(currentElement);
		currentElement = theNextElement;
	}

	listOfStars = NULL;
}
