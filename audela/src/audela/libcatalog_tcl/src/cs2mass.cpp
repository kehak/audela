#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"

/*
 *  Created on: Nov 05, 2012
 *      Author: Y. Damerdji
 */

int cmd_tcl_cs2mass(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStars2Mass* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars  = catalog->cs2mass(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		catalog->release();
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { 2MASS { } { ID ra_deg dec_deg err_ra err_dec jMag jMagError hMag hMagError kMag kMagError jd } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementList2Mass* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,"{ { 2MASS { } {%s %.6f %.6f %.6f %.6f %.3f %.3f %.3f %.3f %.3f %.3f %.6f} } } ",
				currentElement->theStar.id,currentElement->theStar.ra,currentElement->theStar.dec,currentElement->theStar.errorRa,currentElement->theStar.errorDec,
				currentElement->theStar.magnitudeJ,currentElement->theStar.errorMagnitudeJ,currentElement->theStar.magnitudeH,currentElement->theStar.errorMagnitudeH,
				currentElement->theStar.magnitudeK,currentElement->theStar.errorMagnitudeK,currentElement->theStar.jd);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		currentElement = currentElement->nextStar;
	}

	/* Release memory */
	catalog->releaseListOfStar2Mass(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);


	return (TCL_OK);
}
