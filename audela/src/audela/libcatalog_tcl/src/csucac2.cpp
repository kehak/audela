#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"
/*
 * csucac2.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

int cmd_tcl_csucac2(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsUcac2* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csucac2(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}

	/* Print the filtered stars */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC2 { } "
			"{ ID ra_deg dec_deg U2Rmag_mag e_RAm_deg e_DEm_deg nobs e_pos_deg ncat cflg "
			"EpRAm_deg EpDEm_deg pmRA_masperyear pmDEC_masperyear e_pmRA_masperyear e_pmDE_masperyear "
			"q_pmRA q_pmDE 2m_id 2m_J 2m_H 2m_Ks 2m_ph 2m_cc} } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	elementListUcac2* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,
				"{ { UCAC2 { } {%d %.8f %+.8f %.3f %.8f %.8f %d %.8f %d %d "
				"%.8f %.8f %.8f %.8f %.8f %.8f "
				"%.5f %.5f %d %.3f %.3f %.3f %d %d} } } ",

				currentElement->id,
				(double)currentElement->theStar.raInMas / DEG2MAS,
				(double)currentElement->theStar.decInMas / DEG2MAS,
				(double)currentElement->theStar.ucacMagInCentiMag / MAG2CENTIMAG,
				(double)currentElement->theStar.errorRaInMas / DEG2MAS,
				(double)currentElement->theStar.errorDecInMas / DEG2MAS,
				currentElement->theStar.numberOfObservations,
				(double)currentElement->theStar.errorOnUcacPositionInMas / DEG2MAS,
				currentElement->theStar.numberOfCatalogsForPosition,
				currentElement->theStar.majorCatalogIdForPosition,

				(double)currentElement->theStar.centralEpochForMeanRaInMas / DEG2MAS,
				(double)currentElement->theStar.centralEpochForMeanDecInMas / DEG2MAS,
				(double)currentElement->theStar.raProperMotionInOneTenthMasPerYear / 10.,
				(double)currentElement->theStar.decProperMotionInOneTenthMasPerYear / 10.,
				(double)currentElement->theStar.errorOnRaProperMotionInOneTenthMasPerYear / 10.,
				(double)currentElement->theStar.errorOnDecProperMotionInOneTenthMasPerYear / 10.,

				(double)currentElement->theStar.raProperMotionGoodnessOfFit * 0.05,
				(double)currentElement->theStar.decProperMotionGoodnessOfFit * 0.05,
				currentElement->theStar.idFrom2Mass,
				(double)currentElement->theStar.jMagnitude2MassInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.hMagnitude2MassInMilliMag / MAG2MILLIMAG,
				(double)currentElement->theStar.kMagnitude2MassInMilliMag / MAG2MILLIMAG,
				currentElement->theStar.qualityFlag2Mass,
				currentElement->theStar.ccFlag2Mass);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarUcac2(theStars);
	catalog->release();


	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
