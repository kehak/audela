#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"

#include "common.h"
/*
 * csgaia1.cpp
 *
 *  Created on: Oct 19, 2016
 *      Author: Y. Damerdji
 */
int cmd_tcl_csgaia1(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsGaia1* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog*  catalog = ICatalog_createInstance(NULL);

   try {

		theStars = catalog->csgaia1(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		catalog->release();
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { GAIA1 { } "
			"{ source_id ref_epoch ra ra_error dec dec_error parallax parallax_error "
			"pmra pmra_error pmdec pmdec_error astrometric_primary_flag astrometric_priors_used phot_g_mean_flux "
			"phot_g_mean_flux_error phot_g_mean_mag phot_variable_flag } } } ",-1);

	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListGaia1* currentElement = theStars;
	const char* variabilityFlag;
    int astrometricFlag;

	while(currentElement) {

		if(currentElement->theStar.variabilityFlag == '0') {
			variabilityFlag = "NOT_AVAILABLE";
		} else if (currentElement->theStar.variabilityFlag == '1') {
			variabilityFlag = "CONSTANT";
		} else if (currentElement->theStar.variabilityFlag == '2') {
			variabilityFlag = "VARIABLE";
		} else {
			sprintf(outputLogChar,"Bad variability flag = %c",currentElement->theStar.variabilityFlag);
			Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
			catalog->release();
			return (TCL_ERROR);
		}
        
        if(currentElement->theStar.astrometricPrimaryFlag == 'f') {
            astrometricFlag = 0;
        } else if (currentElement->theStar.astrometricPrimaryFlag == 't') {
            astrometricFlag = 1;
        } else {
			sprintf(outputLogChar,"Bad astrometricPrimaryFlag flag = %c",currentElement->theStar.astrometricPrimaryFlag);
			Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
			catalog->release();
			return (TCL_ERROR);
		}
        
        if(isinf(currentElement->theStar.parallax)) {

            sprintf(outputLogChar,"{ { GAIA1 { } {%lld %.1f %.10f %.10f %+.10f %.10f { } { } { } { } { } { } %d %c %.10f %.10f %.10f %s} } } ",
                    currentElement->theStar.sourceId,currentElement->theStar.referenceEpoch,
                    currentElement->theStar.ra,currentElement->theStar.raError,
                    currentElement->theStar.dec,currentElement->theStar.decError,
                    astrometricFlag,currentElement->theStar.astrometricPriorsUsed,
                    currentElement->theStar.meanFluxG,currentElement->theStar.meanFluxGError,
                    currentElement->theStar.meanMagnitudeG,variabilityFlag);
        } else {
            
            sprintf(outputLogChar,"{ { GAIA1 { } {%lld %.1f %.10f %.10f %+.10f %.10f %.10f %.10f %.10f %.10f %.10f %.10f %d %c %.10f %.10f %.10f %s} } } ",
                    currentElement->theStar.sourceId,currentElement->theStar.referenceEpoch,
                    currentElement->theStar.ra,currentElement->theStar.raError,
                    currentElement->theStar.dec,currentElement->theStar.decError,
                    currentElement->theStar.parallax,currentElement->theStar.parallaxError,
                    currentElement->theStar.pmRa,currentElement->theStar.pmRaError,
                    currentElement->theStar.pmDec,currentElement->theStar.pmDecError,
                    astrometricFlag,currentElement->theStar.astrometricPriorsUsed,
                    currentElement->theStar.meanFluxG,currentElement->theStar.meanFluxGError,
                    currentElement->theStar.meanMagnitudeG,variabilityFlag);
        }

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarGaia1(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
