#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"
/*
 * csucac3.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

int cmd_tcl_csucac3(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsUcac3* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csucac3(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}
   
	/* Print the filtered stars */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC3 { } "
			"{ ID ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf sigra_deg sigdc_deg na1 nu1 us1 cn1 cepra_deg cepdc_deg "
			"pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho "
			"smB_mag smR2_mag smI_mag clbl qfB qfR2 qfI "
			"catflg1 catflg2 catflg3 catflg4 catflg5 catflg6 catflg7 catflg8 catflg9 catflg10 "
			"g1 c1 leda x2m rn } } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	elementListUcac3* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,"{ { UCAC3 { } {%03d-%06d %.8f %+.8f %.3f %.3f %.3f %d %d %.8f %.8f %d %d %d %d %.8f %+.8f "
				"%+.8f %+.8f %.8f %.8f %d %.3f %.3f %.3f %d %d %d %.3f %.3f %.3f "
				"%.3f %.3f %.3f %d %d %d %d "
				"%d %d %d %d %d %d %d %d %d %d "
				"%d %d %d %d %d} } } ",

				currentElement->indexDec,currentElement->id, // the ID %03d-%06d
				(double)currentElement->theStar.raInMas/DEG2MAS,
				(double)currentElement->theStar.distanceToSouthPoleInMas / DEG2MAS + DEC_SOUTH_POLE_DEG,
				(double)currentElement->theStar.ucacFitMagInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.ucacApertureMagInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.ucacErrorMagInMilliMag / MAG2MILLIMAG,
				currentElement->theStar.objectType,
				currentElement->theStar.doubleStarFlag,
				(double)currentElement->theStar.errorOnUcacRaInMas / DEG2MAS,
				(double)currentElement->theStar.errorOnUcacDecInMas / DEG2MAS,
				currentElement->theStar.numberOfCcdObservation,
				currentElement->theStar.numberOfUsedCcdObservation,
				currentElement->theStar.numberOfUsedCatalogsForProperMotion,
				currentElement->theStar.numberOfMatchingCatalogs,
				(double)currentElement->theStar.centralEpochForMeanRaInMas/ DEG2MAS,
				(double)currentElement->theStar.centralEpochForMeanDecInMas/ DEG2MAS,

				(double)currentElement->theStar.raProperMotionInOneTenthMasPerYear / 10.,
				(double)currentElement->theStar.decProperMotionInOneTenthMasPerYear / 10.,
				(double)currentElement->theStar.errorOnRaProperMotionInOneTenthMasPerYear / 10.,
				(double)currentElement->theStar.errorOnDecProperMotionInOneTenthMasPerYear / 10.,
				currentElement->theStar.idFrom2Mass,
				(double)currentElement->theStar.jMagnitude2MassInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.hMagnitude2MassInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.kMagnitude2MassInMilliMag / MAG2MILLIMAG,
				currentElement->theStar.jQualityFlag2Mass,
				currentElement->theStar.hQualityFlag2Mass,
				currentElement->theStar.kQualityFlag2Mass,
				(double)currentElement->theStar.jErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,
				(double)currentElement->theStar.hErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,
				(double)currentElement->theStar.kErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,

				(double)currentElement->theStar.bMagnitudeSCInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.r2MagnitudeSCInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.iMagnitudeSCInMilliMag / MAG2MILLIMAG,
				currentElement->theStar.scStarGalaxieClass,
				currentElement->theStar.bQualityFlagSC,
				currentElement->theStar.r2QualityFlagSC,
				currentElement->theStar.iQualityFlag2SC,

				currentElement->theStar.hipparcosMatchFlag,
				currentElement->theStar.tychoMatchFlag,
				currentElement->theStar.ac2000MatchFlag,
				currentElement->theStar.agk2bMatchFlag,
				currentElement->theStar.agk2hMatchFlag,
				currentElement->theStar.zaMatchFlag,
				currentElement->theStar.byMatchFlag,
				currentElement->theStar.lickMatchFlag,
				currentElement->theStar.scMatchFlag,
				currentElement->theStar.spmMatchFlag,

				currentElement->theStar.yaleSpmObjectType,
				currentElement->theStar.yaleSpmInputCatalog,
				currentElement->theStar.ledaGalaxyMatchFlag,
				currentElement->theStar.extendedSourceFlag2Mass,
				currentElement->theStar.mposStarNumber);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarUcac3(theStars);
	catalog->release();

	// end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
