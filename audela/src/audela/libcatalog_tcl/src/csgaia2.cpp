#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"

#include "common.h"
/*
 * csgaia1.cpp
 *
 *  Created on: Sep 6, 2018
 *      Author: Y. Damerdji
 */
int cmd_tcl_csgaia2(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsGaia2* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	ICatalog*  catalog = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csgaia2(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		catalog->release();
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { GAIA2 { } "
			"{ source_id ref_epoch ra ra_error dec dec_error parallax parallax_error "
			"pmra pmra_error pmdec pmdec_error phot_g_mean_mag phot_g_mean_mag_error "
			"phot_bp_mean_mag phot_bp_mean_mag_error phot_rp_mean_mag phot_rp_mean_mag_error "
			"phot_bprp_color teff_val ag_val vRad vRadError templateTeff templateLogg  templateFeH } } } ",-1);

	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListGaia2* currentElement = theStars;
	char astrometricChar[STRING_COMMON_LENGTH];
	char photometricChar[STRING_COMMON_LENGTH];
	char apsisChar[STRING_COMMON_LENGTH];
	char vRadChar[STRING_COMMON_LENGTH];

	while(currentElement) {

		if(isinf(currentElement->theStar.theStarGaia2.parallax)) {

			sprintf(astrometricChar,"{ } { } { } { } { } { }");

		} else {

			sprintf(astrometricChar,"%.10f %.10f %.10f %.10f %.10f %.10f", currentElement->theStar.theStarGaia2.parallax,
					currentElement->theStar.theStarGaia2.parallaxError,
					currentElement->theStar.theStarGaia2.pmRa,currentElement->theStar.theStarGaia2.pmRaError,
					currentElement->theStar.theStarGaia2.pmDec,currentElement->theStar.theStarGaia2.pmDecError);
		}

		if(isinf(currentElement->theStar.theStarGaia2.meanMagnitudeBP)) {

			sprintf(photometricChar,"{ } { } { } { } { }");

		} else {

			sprintf(photometricChar,"%.6f %.6f %.6f %.6f %.6f", currentElement->theStar.theStarGaia2.meanMagnitudeBP,
					currentElement->theStar.theStarGaia2.meanMagnitudeBPError,
					currentElement->theStar.theStarGaia2.meanMagnitudeRP,currentElement->theStar.theStarGaia2.meanMagnitudeRPError,
					currentElement->theStar.theStarGaia2.colorBPRP);
		}

		if(isinf(currentElement->theStar.theStarGaia2.apsisTeff)) {

			sprintf(apsisChar,"{ } { }");

		} else {

			sprintf(apsisChar,"%.6f %.6f", currentElement->theStar.theStarGaia2.apsisTeff,currentElement->theStar.theStarGaia2.apsisAg);
		}

		if(isnan(currentElement->theStar.vRad)) {

			sprintf(vRadChar,"{ } { } { } { } { }");

		} else {

			sprintf(vRadChar,"%.6f %.6f %.2f %.2f %.2f", currentElement->theStar.vRad,currentElement->theStar.vRadError,
					currentElement->theStar.templateTeff, currentElement->theStar.templateLogg, currentElement->theStar.templateFeH);
		}

		sprintf(outputLogChar,"{ { GAIA2 { } {%lld %.1f %.10f %.10f %+.10f %.10f %s %.5f %.5f %s %s %s} } } ",
				currentElement->theStar.theStarGaia2.sourceId,GAIA2_REFERENCE_EPOCH,
				currentElement->theStar.theStarGaia2.ra,currentElement->theStar.theStarGaia2.raError,
				currentElement->theStar.theStarGaia2.dec,currentElement->theStar.theStarGaia2.decError,
				astrometricChar,currentElement->theStar.theStarGaia2.meanMagnitudeG,currentElement->theStar.theStarGaia2.meanMagnitudeGError,
				photometricChar,apsisChar, vRadChar);


		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarGaia2(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
