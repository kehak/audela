#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"
/*
 * csucac4.c
 *
 *  Created on: Nov 04, 2012
 *      Author: Y. Damerdji
 */

int cmd_tcl_csucac4(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsUcac4* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csucac4(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}
   
	/* Print the filtered stars */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC4 { } "
			"{ ID ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf "
			"sigra_deg sigdc_deg na1 nu1 us1 cepra_year cepdc_year pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear "
			"id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho "
			"apassB_mag apassV_mag apassG_mag apassR_mag apassI_mag apassB_errmag apassV_errmag apassG_errmag apassR_errmag apassI_errmag "
			"catflg1 catflg2 catflg3 catflg4 starId zoneUcac2 idUcac2 } } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	elementListUcac4* currentElement = theStars;

	while(currentElement) {

		//				printf("%03d-%06d  %d %d %d %d\n",oneSetOfStar.indexDec,idOfStar,currentElement->theStar.errorOnUcacRaInMas + 128,currentElement->theStar.errorOnUcacDecInMas + 128,
		//						currentElement->theStar.errorOnRaProperMotionInOneTenthMasPerYear + 128,currentElement->theStar.errorOnDecProperMotionInOneTenthMasPerYear + 128);

		sprintf(outputLogChar,"{ { UCAC4 { } {%03d-%06d %.8f %+.8f %.3f %.3f %.3f %d %d "
				"%.8f %.8f %d %d %d %.8f %+.8f %+.8f %+.8f %.8f %.8f "
				"%d %.3f %.3f %.3f %d %d %d %.3f %.3f %.3f "
				"%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f "
				"%d %d %d %d %d %d %d} } } ",

				currentElement->indexDec,currentElement->id, // the ID %03d-%06d
				(double)currentElement->theStar.raInMas/DEG2MAS,
				(double)currentElement->theStar.distanceToSouthPoleInMas / DEG2MAS + DEC_SOUTH_POLE_DEG,
				(double)currentElement->theStar.ucacFitMagInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.ucacApertureMagInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.ucacErrorMagInCentiMag / MAG2CENTIMAG,
				currentElement->theStar.objectType,
				currentElement->theStar.doubleStarFlag,

				(double)(currentElement->theStar.errorOnUcacRaInMas + 128) / DEG2MAS,
				(double)(currentElement->theStar.errorOnUcacDecInMas + 128) / DEG2MAS,
				currentElement->theStar.numberOfCcdObservation,
				currentElement->theStar.numberOfUsedCcdObservation,
				currentElement->theStar.numberOfUsedCatalogsForProperMotion,
				1900. + (double)currentElement->theStar.centralEpochForMeanRaInCentiYear / 100.,
				1900. + (double)currentElement->theStar.centralEpochForMeanDecInCentiYear / 100.,
				(double)currentElement->theStar.raProperMotionInOneTenthMasPerYear / 10.,
				(double)currentElement->theStar.decProperMotionInOneTenthMasPerYear / 10.,
				(double)(currentElement->theStar.errorOnRaProperMotionInOneTenthMasPerYear + 128) / 10.,
				(double)(currentElement->theStar.errorOnDecProperMotionInOneTenthMasPerYear + 128) / 10.,

				currentElement->theStar.idFrom2Mass,
				(double)currentElement->theStar.jMagnitude2MassInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.hMagnitude2MassInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.kMagnitude2MassInMilliMag / MAG2MILLIMAG,
				currentElement->theStar.qualityFlag2Mass[0],
				currentElement->theStar.qualityFlag2Mass[1],
				currentElement->theStar.qualityFlag2Mass[2],
				(double)currentElement->theStar.errorMagnitude2MassInCentiMag[0] / MAG2CENTIMAG,
				(double)currentElement->theStar.errorMagnitude2MassInCentiMag[1] / MAG2CENTIMAG,
				(double)currentElement->theStar.errorMagnitude2MassInCentiMag[2] / MAG2CENTIMAG,

				(double)currentElement->theStar.magnitudeAPASSInMilliMag[0] / MAG2MILLIMAG,
				(double)currentElement->theStar.magnitudeAPASSInMilliMag[1] / MAG2MILLIMAG,
				(double)currentElement->theStar.magnitudeAPASSInMilliMag[2] / MAG2MILLIMAG,
				(double)currentElement->theStar.magnitudeAPASSInMilliMag[3] / MAG2MILLIMAG,
				(double)currentElement->theStar.magnitudeAPASSInMilliMag[4] / MAG2MILLIMAG,
				(double)currentElement->theStar.magnitudeErrorAPASSInCentiMag[0] / MAG2CENTIMAG,
				(double)currentElement->theStar.magnitudeErrorAPASSInCentiMag[1] / MAG2CENTIMAG,
				(double)currentElement->theStar.magnitudeErrorAPASSInCentiMag[2] / MAG2CENTIMAG,
				(double)currentElement->theStar.magnitudeErrorAPASSInCentiMag[3] / MAG2CENTIMAG,
				(double)currentElement->theStar.magnitudeErrorAPASSInCentiMag[4] / MAG2CENTIMAG,

				currentElement->theStar.gFlagYale,
				currentElement->theStar.fk6HipparcosTychoSourceFlag,
				currentElement->theStar.legaGalaxyMatchFlag,
				currentElement->theStar.extendedSource2MassFlag,
				currentElement->theStar.starIdentifier,
				currentElement->theStar.zoneNumberUcac2,
				currentElement->theStar.recordNumberUcac2);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarUcac4(theStars);
	catalog->release();

	// end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
