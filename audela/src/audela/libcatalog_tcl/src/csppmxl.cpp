/*
 * ppmxl.c
 *
 *  Created on: 18/03/2013
 *      Author: Y. Damerdji
 */
#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"

/**
 * Cone search on PPMX catalog
 */
int cmd_tcl_csppmxl(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsPpmxl* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csppmxl(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}
   
	/* Print theStars */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { PPMXL { } { ID RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec epochRa epochDec magB1 magB2 magR1 magR2 magI magJ errMagJ magH errMagH magK errMagK Nobs} } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListPpmxl* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,"{ { PPMXL { } {%lld %.8f %+.8f %.8f %.8f %+.8f %+.8f %.8f %.8f %.2f %.2f "
				"%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %d} } } ",
				currentElement->theStar.id,
				currentElement->theStar.ra,
				currentElement->theStar.dec,
				currentElement->theStar.errorRa,
				currentElement->theStar.errorDec,
				currentElement->theStar.pmRa,
				currentElement->theStar.pmDec,
				currentElement->theStar.errorPmRa,
				currentElement->theStar.errorPmDec,
				currentElement->theStar.epochRa, currentElement->theStar.epochDec,
				currentElement->theStar.magnitudeB1,
				currentElement->theStar.magnitudeB2,
				currentElement->theStar.magnitudeR1,
				currentElement->theStar.magnitudeR2,
				currentElement->theStar.magnitudeI,
				currentElement->theStar.magnitudeJ, currentElement->theStar.errorMagnitudeJ,
				currentElement->theStar.magnitudeH, currentElement->theStar.errorMagnitudeH,
				currentElement->theStar.magnitudeK, currentElement->theStar.errorMagnitudeK,
				currentElement->theStar.nObs);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarPpmxl(theStars);
	catalog->release();

	// end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
