#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"
/*
 * csloneos.cpp
 *
 *  Created on: Jan 26, 2016
 *      Author: Y. Damerdji
 */

int cmd_tcl_csloneos(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsLoneos* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csloneos(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}
   
	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { LONEOS { } { ID starName ra_deg dec_deg sourceOfCoordinates nameInGSC "
			" sourceOfCoordinates isStandard magnitudeV colorBV uncertaintyColorBV "
			" colorUB uncertaintyColorUB colorVR colorVI} } } ",-1);

	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListLoneos* currentElement = theStars;

	while(currentElement) {

		starLoneos& theStar           = currentElement->theStar;

		sprintf(outputLogChar,"{ { LONEOS { } {%d %s %.6f %+.6f %c "
				"%s %c %.3f %.3f %c "
				"%.3f %c %.3f %.3f} } } ",
				theStar.id, theStar.starName, theStar.ra,theStar.dec,theStar.sourceOfCoordinates,
				theStar.nameInGSC,theStar.isStandard,theStar.magnitudeV,theStar.colorBV,theStar.uncertaintyColorBV,
				theStar.colorUB,theStar.uncertaintyColorUB,theStar.colorVR,theStar.colorVI);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarLoneos(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
