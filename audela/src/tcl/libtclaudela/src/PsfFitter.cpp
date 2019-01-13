/**
 * Code file for profile fitting methods
 *
 * Author : Yassine Damerdji
 */
#include "PsfFitter.h"

const double PsfFitter::TWO_PI             = 2.*M_PI;
const int PsfFitter::BACKGROUND_FLUX_INDEX = 0;
const int PsfFitter::SCALE_FACTOR_INDEX    = 1;
const int PsfFitter::PHOTOCENTER_X_INDEX   = 2;
const int PsfFitter::PHOTOCENTER_Y_INDEX   = 3;
const int PsfFitter::THETA_INDEX           = 4;
const int PsfFitter::SIGMA_X_INDEX         = 5;
const int PsfFitter::SIGMA_Y_INDEX         = 6;
const double PsfFitter::HOW_MANY_SIGMAS    = 3.;
const int MoffatPsfFitter::BETA_INDEX      = 7;

/**
 * Class constructor
 */
PsfFitter::PsfFitter(const int inputNumberOfParameterFit,const int inputNumberOfParameterFitPreliminarySolution) :
			numberOfParameterFit(inputNumberOfParameterFit), numberOfParameterFitPreliminarySolution(inputNumberOfParameterFitPreliminarySolution) {

	xPixelsMaximumRadius              = NULL;
	yPixelsMaximumRadius              = NULL;
	fluxesMaximumRadius               = NULL;
	fluxErrorsMaximumRadius           = NULL;
	isUsedFlags                       = NULL;
	xPixels                           = NULL;
	yPixels                           = NULL;
	fluxes                            = NULL;
	fluxErrors                        = NULL;
	weights                           = NULL;
	nonLinearTerms                    = NULL;
	transformedFluxes                 = NULL;
	transformedFluxErrors             = NULL;
	numberOfPixelsMaximumRadius       = 0;
	numberOfPixelsOneRadius           = 0;
	sumOfWeights                      = 0.;
	theLinearAlgebraicSystemSolver    = NULL;
	theLevenbergMarquardtSystemSolver = NULL;
	initialSolutionParameters         = NULL;
	highestIntensityInWindow          = -1e100;
	numberOfTestedRadius              = -1;
	indexOfRadius                     = -1;
}

/**
 * Class destructor
 */
PsfFitter::~PsfFitter() {

	if(xPixels != NULL) {
		delete[] xPixels;
		xPixels = NULL;
	}

	if(yPixels != NULL) {
		delete[] yPixels;
		yPixels = NULL;
	}

	if(fluxes != NULL) {
		delete[] fluxes;
		fluxes = NULL;
	}

	if(transformedFluxes != NULL) {
		delete[] transformedFluxes;
		transformedFluxes = NULL;
	}

	if(fluxErrors != NULL) {
		delete[] fluxErrors;
		fluxErrors = NULL;
	}

	if(weights != NULL) {
		delete[] weights;
		weights = NULL;
	}

	if(nonLinearTerms != NULL) {
		delete[] nonLinearTerms;
		nonLinearTerms = NULL;
	}

	if(transformedFluxErrors != NULL) {
		delete[] transformedFluxErrors;
		transformedFluxErrors = NULL;
	}

	if(xPixelsMaximumRadius != NULL) {
		delete[] xPixelsMaximumRadius;
		xPixelsMaximumRadius = NULL;
	}

	if(yPixelsMaximumRadius != NULL) {
		delete[] yPixelsMaximumRadius;
		yPixelsMaximumRadius = NULL;
	}

	if(fluxesMaximumRadius != NULL) {
		delete[] fluxesMaximumRadius;
		fluxesMaximumRadius = NULL;
	}

	if(fluxErrorsMaximumRadius != NULL) {
		delete[] fluxErrorsMaximumRadius;
		fluxErrorsMaximumRadius = NULL;
	}

	if(isUsedFlags != NULL) {
		delete[] isUsedFlags;
		isUsedFlags = NULL;
	}

	if(theLinearAlgebraicSystemSolver != NULL) {
		delete theLinearAlgebraicSystemSolver;
		theLinearAlgebraicSystemSolver = NULL;
	}

	if(theLevenbergMarquardtSystemSolver != NULL) {
		delete theLevenbergMarquardtSystemSolver;
		theLevenbergMarquardtSystemSolver = NULL;
	}

	if(initialSolutionParameters != NULL) {
		delete [] initialSolutionParameters;
		initialSolutionParameters = NULL;
	}

	numberOfPixelsMaximumRadius = 0;
}

/**
 * Loop over radii to find the best fit
 */
void PsfFitter::fitProfile(abaudela::IBuffer* const theBufferImage, double xCenter, double yCenter, const int minimumRadius, const int maximumRadius,
		const double saturationLimit, const double readOutNoise,const double positionThreshold,const int numberOfSuccessiveErrors,
		const double confidenceLevel, const bool pureGaussianStatistics, const bool searchAround) {

	/* Allocate memory for outputs */
	numberOfTestedRadius              = maximumRadius - minimumRadius + 1;
	allocateArrayOfOutputParameters();

	/* Initialise values */
	numberOfPixelsOneRadius           = 0;
	sumOfWeights                      = 0.;
	bool doesDiverge;

	/* Extract the processing zone for the maximum radius */
	extractProcessingZoneMaximumRadius(theBufferImage, xCenter, yCenter, maximumRadius, readOutNoise, pureGaussianStatistics,searchAround);

	theLinearAlgebraicSystemSolver    = new LinearAlgebraicSystemSolver(this,numberOfParameterFitPreliminarySolution,numberOfPixelsMaximumRadius);
	theLevenbergMarquardtSystemSolver = new LevenbergMarquardtSystemSolver(this,numberOfParameterFit,numberOfPixelsMaximumRadius);
	initialSolutionParameters         = new double[numberOfParameterFit];

	indexOfRadius       = 0;
	int counterOfErrors = 0;

	for(int theRadius = minimumRadius; theRadius <= maximumRadius; theRadius++) {

		if(DEBUG) {
			printf("Radius =  %d\n",theRadius);
		}

		setRadius(theRadius);

		/* Extract pixels needed for the fit */
		extractProcessingZone(theRadius, saturationLimit);
		setHighestIntensityInWindow();

		try {

			/* Fit the profile*/
			fitProfilePerRadius(doesDiverge);
			copyParamtersInTheSolution(theLevenbergMarquardtSystemSolver->getArrayOfParameters(),theRadius, readOutNoise, positionThreshold,doesDiverge);

			if(doesDiverge) {

				counterOfErrors++;
				if(counterOfErrors >= numberOfSuccessiveErrors) {
					if(DEBUG) {
						printf("%d successive errors were encountered, we stop the processing\n",counterOfErrors);
					}
					break;
				}

			} else {

				doesDiverge = theLevenbergMarquardtSystemSolver->computeErrors();
				setErrorsInTheSolution(theLevenbergMarquardtSystemSolver->getArrayOfParameterErrors(),doesDiverge);

				if(doesDiverge) {
					counterOfErrors++;
					if(counterOfErrors >= numberOfSuccessiveErrors) {
						if(DEBUG) {
							printf("%d successive errors were encountered, we stop the processing\n",counterOfErrors);
						}
						break;
					}
				}

				updatePhotocenter(xCenter,yCenter);

				/* Reset counterOfErrors */
				counterOfErrors = 0;
			}

		} catch (ErrorException& theException) {

			if(DEBUG) {
				printf("Exception for radius = %d : %s\n",theRadius,theException.getTheMessage());
			}
			counterOfErrors++;
			if(counterOfErrors >= numberOfSuccessiveErrors) {
				if(DEBUG) {
					printf("%d successive errors were encountered, we stop the processing\n",counterOfErrors);
				}
				break;
			}
		}

		indexOfRadius++;
	}

	if(numberOfTestedRadius == 1) {
		cleanBadRadii();
		copySolutionParameters(0);
	} else {
		/* Clean the output array of parameters and find the best radius */
		const int indexOfBestRadius = findBestRadiusAndFlagBadSolutions(confidenceLevel);
		if(indexOfBestRadius       >= 0) {
			copySolutionParameters(indexOfBestRadius);
			fillBestSolution();
		} else {
			cleanBadRadii();
			copySolutionParameters(0);
		}
	}
}

int PsfFitter::findBestRadiusAndFlagBadSolutions(const double confidenceLevel) {

	int incrementalIndex;
	double theMeanOfBackGrounds;
	double theSigmaOfBackGrounds;
	double theMeanOfPhotocenterX;
	double theMeanOfPhotocenterY;
	double theMeanOfTotalFlux;
	double thresholdOfBackGrounds;

	/* Clean bad radii (with doesDiverge = true) */
	int numberOfFailedSolutions = cleanBadRadii();
	if(numberOfFailedSolutions == numberOfTestedRadius) {
		return -1;
	}

	//printf("numberOfFailedSolutions = %d\n",numberOfFailedSolutions);

	/* We use this array to store the 4 used parameters to clean bad solutions */
	indexedParameters* arrayOfRestrictedParameters = new indexedParameters[numberOfTestedRadius];
	if(arrayOfRestrictedParameters    == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (indexedParameters) for arrayOfRestrictedParameters\n",numberOfTestedRadius);
		throw InsufficientMemoryException(logMessage);
	}

	/* A first value of the backGroundFlux threshold */
	int numberOfGoodSolutions = fillArrayOfBackGrounds(arrayOfRestrictedParameters);
	/* If no valid solution, we stop */
	if(numberOfGoodSolutions == 0) {
		return -1;
	}

	//printf("0 / numberOfGoodSolutions = %d\n",numberOfGoodSolutions);

	qsort(arrayOfRestrictedParameters,numberOfGoodSolutions,sizeof(indexedParameters),compareBackGroundsAscending);

	if(numberOfGoodSolutions  > 1) {
		computeMeanAndSigma(arrayOfRestrictedParameters, numberOfGoodSolutions / 2, theMeanOfBackGrounds, theSigmaOfBackGrounds);
	} else {
		theMeanOfBackGrounds  = arrayOfRestrictedParameters[0].backGroundFlux;
		theSigmaOfBackGrounds = 0.;
	}

	thresholdOfBackGrounds = theMeanOfBackGrounds + 3 * theSigmaOfBackGrounds;

	/* Fill arrayOfRestrictedParameters to compute the means */
	numberOfGoodSolutions  = fillParameters(arrayOfRestrictedParameters,thresholdOfBackGrounds);
	//printf("1 / numberOfGoodSolutions = %d\n",numberOfGoodSolutions);

	computeMeans(arrayOfRestrictedParameters, numberOfGoodSolutions, theMeanOfBackGrounds, theMeanOfPhotocenterX, theMeanOfPhotocenterY, theMeanOfTotalFlux);

	/* Re Fill arrayOfRestrictedParameters with all solution */
	numberOfGoodSolutions  = fillParameters(arrayOfRestrictedParameters,1e100);
	//printf("2 / numberOfGoodSolutions = %d\n",numberOfGoodSolutions);

	/* Subtract the mean */
	for(int incrementalIndex = 0; incrementalIndex < numberOfGoodSolutions; incrementalIndex++) {
		arrayOfRestrictedParameters[incrementalIndex].backGroundFlux = fabs(arrayOfRestrictedParameters[incrementalIndex].backGroundFlux - theMeanOfBackGrounds);
		arrayOfRestrictedParameters[incrementalIndex].photocenterX   = fabs(arrayOfRestrictedParameters[incrementalIndex].photocenterX   - theMeanOfPhotocenterX);
		arrayOfRestrictedParameters[incrementalIndex].photocenterY   = fabs(arrayOfRestrictedParameters[incrementalIndex].photocenterY   - theMeanOfPhotocenterY);
		arrayOfRestrictedParameters[incrementalIndex].totalFlux      = fabs(arrayOfRestrictedParameters[incrementalIndex].totalFlux      - theMeanOfTotalFlux);
	}

	/* A first clean : remove numberOfCleanedSolutions bad solutions */
	const int numberOfCleanedSolutions = (int) (numberOfGoodSolutions * (1. - confidenceLevel / 100.));
	int counterOfRemoved               = 0;

	/* Sort the parameters and exclude bad radius */
	/* Clean with respect to backGroundFlux */
	if(counterOfRemoved < numberOfCleanedSolutions) {
		qsort(arrayOfRestrictedParameters,numberOfGoodSolutions,sizeof(indexedParameters),compareBackGroundsDescending);
	}
	incrementalIndex = 0;
	while((counterOfRemoved < numberOfCleanedSolutions) && (incrementalIndex < numberOfCleanedSolutions)) {
		counterOfRemoved += cleanSolution(arrayOfRestrictedParameters[incrementalIndex].index);
		incrementalIndex++;
	}

	/* Clean with respect to photocenterX */
	if(counterOfRemoved < numberOfCleanedSolutions) {
		qsort(arrayOfRestrictedParameters,numberOfGoodSolutions,sizeof(indexedParameters),comparePhotocenterXDescending);
	}
	incrementalIndex = 0;
	while((counterOfRemoved < numberOfCleanedSolutions) && (incrementalIndex < numberOfCleanedSolutions)) {
		counterOfRemoved += cleanSolution(arrayOfRestrictedParameters[incrementalIndex].index);
		incrementalIndex++;
	}

	/* Clean with respect to photocenterY */
	if(counterOfRemoved < numberOfCleanedSolutions) {
		qsort(arrayOfRestrictedParameters,numberOfGoodSolutions,sizeof(indexedParameters),comparePhotocenterYDescending);
	}
	incrementalIndex = 0;
	while((counterOfRemoved <= numberOfCleanedSolutions) && (incrementalIndex < numberOfCleanedSolutions)) {
		counterOfRemoved += cleanSolution(arrayOfRestrictedParameters[incrementalIndex].index);
		incrementalIndex++;
	}

	/* Clean with respect to total flux */
	if(counterOfRemoved < numberOfCleanedSolutions) {
		qsort(arrayOfRestrictedParameters,numberOfGoodSolutions,sizeof(indexedParameters),compareFluxDescending);
	}
	incrementalIndex = 0;
	while((counterOfRemoved <= numberOfCleanedSolutions) && (incrementalIndex < numberOfCleanedSolutions)) {
		counterOfRemoved += cleanSolution(arrayOfRestrictedParameters[incrementalIndex].index);
		incrementalIndex++;
	}

	/* Last cleaning : remove solutions with bad backoundFlux */
	numberOfGoodSolutions = fillArrayOfBackGrounds(arrayOfRestrictedParameters);
	//printf("3 / numberOfGoodSolutions = %d\n",numberOfGoodSolutions);
	qsort(arrayOfRestrictedParameters,numberOfGoodSolutions,sizeof(indexedParameters),compareBackGroundsAscending);

	if(numberOfGoodSolutions  > 1) {
		computeMeanAndSigma(arrayOfRestrictedParameters, numberOfGoodSolutions / 2, theMeanOfBackGrounds, theSigmaOfBackGrounds);
	} else {
		theMeanOfBackGrounds  = arrayOfRestrictedParameters[0].backGroundFlux;
		theSigmaOfBackGrounds = 0.;
	}

	thresholdOfBackGrounds = theMeanOfBackGrounds + 3 * theSigmaOfBackGrounds;

	counterOfRemoved = 0.;

	/* Filter out bad solutions with respect to bad solutions */
	for(int incrementalIndex = 0; incrementalIndex < numberOfGoodSolutions; incrementalIndex++) {
		if(arrayOfRestrictedParameters[incrementalIndex].backGroundFlux > thresholdOfBackGrounds) {
			counterOfRemoved += cleanSolution(arrayOfRestrictedParameters[incrementalIndex].index);
		}
	}

	/* Fill arrayOfRestrictedParameters to compute the means */
	numberOfGoodSolutions  = fillParameters(arrayOfRestrictedParameters,thresholdOfBackGrounds);

	computeMeans(arrayOfRestrictedParameters, numberOfGoodSolutions, theMeanOfBackGrounds, theMeanOfPhotocenterX, theMeanOfPhotocenterY, theMeanOfTotalFlux);

	//printf("4/ numberOfGoodSolutions = %d - theMeanOfTotalFlux = %f\n",numberOfGoodSolutions,theMeanOfTotalFlux);

	/* The best solution is the one with totalFlux just greater than theMeanOfTotalFlux */
	qsort(arrayOfRestrictedParameters,numberOfGoodSolutions,sizeof(indexedParameters),compareFluxAscending);

	int indexOfBestSolution  = -1;
	for(int incrementalIndex = 0; incrementalIndex < numberOfGoodSolutions; incrementalIndex++) {
		if(arrayOfRestrictedParameters[incrementalIndex].totalFlux >= theMeanOfTotalFlux) {
			indexOfBestSolution = arrayOfRestrictedParameters[incrementalIndex].index;
			break;
		}
	}

	delete[] arrayOfRestrictedParameters;

	return indexOfBestSolution;
}

/**
 * Extract pixels needed for the fit
 */
void PsfFitter::extractProcessingZoneMaximumRadius(abaudela::IBuffer* const theBufferImage, int xCenter, int yCenter, const int theRadius,
			double readOutNoise, const bool pureGaussianStatistics, const bool searchAround) {

	const int naxis1 = theBufferImage->getWidth();
	const int naxis2 = theBufferImage->getHeight();

	if((xCenter < 1) || (xCenter > naxis1)) {
		throw FatalException("x0 is out of range");
	}
	if((yCenter < 1) || (yCenter > naxis2)) {
		throw FatalException("y0 is out of range");
	}

	// Starts buy taking the rectangle
	int xPixelStart  = xCenter - theRadius;
	if (xPixelStart  < 1) { // We are still starting counting from 1
		xPixelStart  = 1;
	}

	int xPixelEnd    = xCenter + theRadius;
	if (xPixelEnd    > naxis1) {
		xPixelEnd    = naxis1;
	}

	int yPixelStart  = yCenter - theRadius;
	if (yPixelStart  < 1) { // We are still starting counting from 1
		yPixelStart  = 1;
	}

	int yPixelEnd    = yCenter + theRadius;
	if (yPixelEnd    > naxis2) {
		yPixelEnd    = naxis2;
	}

	const int numberOfColumns   = xPixelEnd - xPixelStart + 1;
	const int numberOfRows      = yPixelEnd - yPixelStart + 1;
	numberOfPixelsMaximumRadius = numberOfRows * numberOfColumns;

	// Get the sub image
	abaudela::TYPE_PIXELS* allPixels      = new abaudela::TYPE_PIXELS[numberOfPixelsMaximumRadius];
	if(allPixels               == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (TYPE_PIXELS) for allPixels\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	theBufferImage->getPixels(xPixelStart - 1, yPixelStart - 1, xPixelEnd - 1, yPixelEnd - 1, abaudela::FORMAT_FLOAT, abaudela::PLANE_GREY, allPixels); // -1 because where are in C

	// For the maximum radius, we select the rectangle instead of the circle
	xPixelsMaximumRadius        = new int[numberOfPixelsMaximumRadius];
	if(xPixelsMaximumRadius    == NULL) {
		delete[] allPixels;
		sprintf(logMessage,"Error when allocating memory of %d (double) for xPixelsMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	xPixels                     = new int[numberOfPixelsMaximumRadius];
	if(xPixels                 == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for xPixels\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	yPixelsMaximumRadius        = new int[numberOfPixelsMaximumRadius];
	if(yPixelsMaximumRadius    == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		sprintf(logMessage,"Error when allocating memory of %d (double) for yPixelsMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	yPixels                     = new int[numberOfPixelsMaximumRadius];
	if(yPixels                 == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for yPixels\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	fluxesMaximumRadius         = new double[numberOfPixelsMaximumRadius];
	if(fluxesMaximumRadius     == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxesMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	fluxes                      = new double[numberOfPixelsMaximumRadius];
	if(fluxes                  == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxes\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	transformedFluxes           = new double[numberOfPixelsMaximumRadius];
	if(transformedFluxes       == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		sprintf(logMessage,"Error when allocating memory of %d (double) for transformedFluxes\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	fluxErrorsMaximumRadius     = new double[numberOfPixelsMaximumRadius];
	if(fluxErrorsMaximumRadius == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxErrorsMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	fluxErrors                  = new double[numberOfPixelsMaximumRadius];
	if(fluxErrors              == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxErrors\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	weights                    = new double[numberOfPixelsMaximumRadius];
	if(weights                == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		delete[] fluxErrors;
		sprintf(logMessage,"Error when allocating memory of %d (double) for weights\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	nonLinearTerms             = new double[numberOfPixelsMaximumRadius];
	if(nonLinearTerms         == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		delete[] fluxErrors;
		delete[] weights;
		sprintf(logMessage,"Error when allocating memory of %d (double) for nonLinearTerms\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	transformedFluxErrors       = new double[numberOfPixelsMaximumRadius];
	if(transformedFluxErrors   == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		delete[] fluxErrors;
		delete[] weights;
		delete[] nonLinearTerms;
		sprintf(logMessage,"Error when allocating memory of %d (double) for transformedFluxErrors\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	isUsedFlags     = new bool[numberOfPixelsMaximumRadius];
	if(isUsedFlags == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		delete[] fluxErrors;
		delete[] weights;
		delete[] nonLinearTerms;
		delete[] transformedFluxErrors;
		sprintf(logMessage,"Error when allocating memory of %d (double) for isUsedFlags\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	// Fill arrays
	int componentNumber;
	int counter                     = 0;

	if(pureGaussianStatistics) {

		/* Uses a gaussian noise */
		if(readOutNoise == 0.) {
			readOutNoise = 1.;
		}

		for (int xPixel = xPixelStart; xPixel <= xPixelEnd; xPixel++) {
			for (int yPixel = yPixelStart; yPixel <= yPixelEnd; yPixel++) {

				xPixelsMaximumRadius[counter]      = xPixel - xCenter;
				yPixelsMaximumRadius[counter]      = yPixel - yCenter;
				componentNumber                    = numberOfColumns * (yPixel - yPixelStart) + xPixel - xPixelStart;
				fluxesMaximumRadius[counter]       = (double)(allPixels[componentNumber]);
				//printf("pixel %d : flux = %f - componentNumber = %d\n",counter,fluxesMaximumRadius[counter],componentNumber);
				fluxErrorsMaximumRadius[counter]   = readOutNoise; // Photon noise + read out noise
				isUsedFlags[counter]               = false;

				counter++;
			}
		}

	} else {

		/* Include the photon noise */
		const double squareReadOutNoise = readOutNoise * readOutNoise;

		for (int xPixel = xPixelStart; xPixel <= xPixelEnd; xPixel++) {
			for (int yPixel = yPixelStart; yPixel <= yPixelEnd; yPixel++) {

				xPixelsMaximumRadius[counter]      = xPixel - xCenter;
				yPixelsMaximumRadius[counter]      = yPixel - yCenter;
				componentNumber                    = numberOfColumns * (yPixel - yPixelStart) + xPixel - xPixelStart;
				fluxesMaximumRadius[counter]       = (double)(allPixels[componentNumber]);
				//printf("xPixel = %d - yPixel = %d : flux = %f - componentNumber = %d\n",xPixel,yPixel,fluxesMaximumRadius[counter],componentNumber);
				fluxErrorsMaximumRadius[counter]   = sqrt(fluxesMaximumRadius[counter] + squareReadOutNoise); // Photon noise + read out noise
				isUsedFlags[counter]               = false;

				counter++;
			}
		}
	}

	if(searchAround) {

		double highestIntensity = -1;
		double newXCenter       = 0.;
		double newYCenter      = 0.;

		for(int counter = 0; counter < numberOfPixelsMaximumRadius; counter++) {

			if(highestIntensity  < fluxesMaximumRadius[counter]) {
				highestIntensity = fluxesMaximumRadius[counter];
				/* We change xCenter and yCenter */
				newXCenter       = xPixelsMaximumRadius[counter];
				newYCenter       = yPixelsMaximumRadius[counter];
			}
		}

		/* Update x and y */
		for(int counter = 0; counter < numberOfPixelsMaximumRadius; counter++) {
			xPixelsMaximumRadius[counter] -= newXCenter;
			yPixelsMaximumRadius[counter] -= newYCenter;
		}

		xCenter += newXCenter;
		yCenter += newYCenter;
	}

	delete[] allPixels;
}

/**
 * Extract pixels needed for the fit
 */
void PsfFitter::extractProcessingZone(const int theRadius, const double saturationLimit) {

	double distance;
	const double squareRadius = theRadius * theRadius;

	// We do not need to reset arrays, since we processing radii in ascending orders
	for (int pixel = 0; pixel < numberOfPixelsMaximumRadius; pixel++) {

		if(!isUsedFlags[pixel]) {

			distance                                    = xPixelsMaximumRadius[pixel] * xPixelsMaximumRadius[pixel] +
					yPixelsMaximumRadius[pixel] * yPixelsMaximumRadius[pixel];

			if(distance                                 < squareRadius) {

				if (fluxesMaximumRadius[pixel]          < saturationLimit) {
					isUsedFlags[pixel]                  = true;
					xPixels[numberOfPixelsOneRadius]    = xPixelsMaximumRadius[pixel];
					yPixels[numberOfPixelsOneRadius]    = yPixelsMaximumRadius[pixel];
					fluxes[numberOfPixelsOneRadius]     = fluxesMaximumRadius[pixel];
					fluxErrors[numberOfPixelsOneRadius] = fluxErrorsMaximumRadius[pixel];
					weights[numberOfPixelsOneRadius]    = 1. / (fluxErrors[numberOfPixelsOneRadius] * fluxErrors[numberOfPixelsOneRadius]);
					sumOfWeights                       += weights[numberOfPixelsOneRadius];
					numberOfPixelsOneRadius++;
				}

				if(fluxesMaximumRadius[pixel]           > highestIntensityInWindow) {
					highestIntensityInWindow            = fluxesMaximumRadius[pixel];
				}
			}
		}
	}
}

/**
 * Fit a PSF for a given pixel radius
 */
double PsfFitter::fitProfilePerRadius(bool& doesDiverge) {

	/* Find the initial solution */
	findInitialSolution();

	/* Refine the initial solution */
	const double unNormalisedChiSquare = refineSolution(doesDiverge);

	return unNormalisedChiSquare;
}

/**
 * Find the PSF preliminary solution for profiles
 */
void PsfFitter::findInitialSolution() {

	const double minimumOfFluxes                     = findMinimumOfFluxes();

	// The background flux
	initialSolutionParameters[BACKGROUND_FLUX_INDEX] = minimumOfFluxes - 1.;

	/* Transform fluxes for computing the preliminary solution */
	transformFluxesForPreliminarySolution(initialSolutionParameters[BACKGROUND_FLUX_INDEX]);

	/* Solve the system to find the preliminary solution */
	theLinearAlgebraicSystemSolver->solveSytem();

	/* Decode the fit coefficients */
	decodeFitCoefficients(theLinearAlgebraicSystemSolver->getArrayOfParameters());

	/* Set the initial solution */
	setIntialSolution();
}

/**
 * Transform fluxes for computing the preliminary solution
 */
void PsfFitter::transformFluxesForPreliminarySolution(const double theBackgroundFlux) {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		/* We subtract the background flux */
		transformedFluxes[pixel]     = fluxes[pixel] - theBackgroundFlux;

		/* The error bars */
		transformedFluxErrors[pixel] = fluxErrors[pixel] / transformedFluxes[pixel];

		/* We take the logarithm of fluxes */
		transformedFluxes[pixel]     = log(transformedFluxes[pixel]);
	}
}

/**
 * Fill the weighted observations (transformedFluxes / transformedFluxErrors) to find the preliminary solution
 */
void PsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix) {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		/* The constant element term */
		weightedDesignMatrix[5][pixel] = 1. / transformedFluxErrors[pixel];

		/* The xPixel term */
		weightedDesignMatrix[3][pixel] = xPixels[pixel] / transformedFluxErrors[pixel];

		/* The yPixel term */
		weightedDesignMatrix[4][pixel] = yPixels[pixel] / transformedFluxErrors[pixel];

		/* The xPixel^2 term */
		weightedDesignMatrix[0][pixel] = xPixels[pixel] * weightedDesignMatrix[3][pixel];

		/* The xPixel * yPixel term */
		weightedDesignMatrix[1][pixel] = yPixels[pixel] * weightedDesignMatrix[3][pixel];

		/* The yPixel * yPixel term */
		weightedDesignMatrix[2][pixel] = yPixels[pixel] * weightedDesignMatrix[4][pixel];
	}
}

void PsfFitter::decodeFitCoefficients(const double* const fitCoefficients) {

	const double coefficientA       = fitCoefficients[0];
	const double coefficientB       = fitCoefficients[1];
	const double coefficientC       = fitCoefficients[2];
	const double coefficientD       = fitCoefficients[3];
	const double coefficientE       = fitCoefficients[4];
	const double coefficientF       = fitCoefficients[5];

	if (coefficientA  == coefficientC) {
		initialSolutionParameters[THETA_INDEX] = M_PI / 4;
	} else {
		initialSolutionParameters[THETA_INDEX] = atan(coefficientB / (coefficientA - coefficientC)) / 2.;
	}

	const double cosTheta           = cos(initialSolutionParameters[THETA_INDEX]);
	const double sinTheta           = sin(initialSolutionParameters[THETA_INDEX]);
	const double squareCosTheta     = cosTheta * cosTheta;
	const double squareSinTheta     = sinTheta * sinTheta;

	const double coefficientSquareX = coefficientA * squareCosTheta + coefficientB * cosTheta * sinTheta + coefficientC * squareSinTheta;
	const double coefficientSquareY = coefficientA * squareSinTheta - coefficientB * cosTheta * sinTheta + coefficientC * squareCosTheta;
	const double coefficientX       = coefficientD * cosTheta + coefficientE * sinTheta;
	const double coefficientY       = -coefficientD * sinTheta + coefficientE * cosTheta;

	const double x0Tilde            = -coefficientX / coefficientSquareX;
	const double y0Tilde            = -coefficientY / coefficientSquareY;

	initialSolutionParameters[PHOTOCENTER_X_INDEX] = x0Tilde * cosTheta - y0Tilde * sinTheta;
	initialSolutionParameters[PHOTOCENTER_Y_INDEX] = x0Tilde * sinTheta + y0Tilde * cosTheta;

	const double squareSigmaX       = -0.5 / coefficientSquareX;
	if (squareSigmaX                < 0.) {
		// Default value
		initialSolutionParameters[SIGMA_X_INDEX] = 1.;
	} else {
		initialSolutionParameters[SIGMA_X_INDEX] = sqrt(squareSigmaX);
	}

	const double squareSigmaY       = -0.5 / coefficientSquareY;
	if (squareSigmaY                < 0.) {
		// Default value
		initialSolutionParameters[SIGMA_Y_INDEX] = 1.;
	} else {
		initialSolutionParameters[SIGMA_Y_INDEX] = sqrt(squareSigmaY);
	}

	const double scaleFactor                      = coefficientF + x0Tilde * x0Tilde / 2 / squareSigmaX + y0Tilde * y0Tilde / 2 / squareSigmaY;
	initialSolutionParameters[SCALE_FACTOR_INDEX] = exp(scaleFactor);
}

void PsfFitter::deduceLinearParameters(double& scaleFactor, double& backGroundFlux) {

	double weight;
	double weightedFlux;
	double weightedNonLinearTerm;
	double weightedMeanOfFluxes               = 0.;
	double weightedMeanOfNonLinearTerms       = 0.;
	double weightedMeanOfProduct              = 0.;
	double weightedMeanOfSquareNonLinearTerms = 0.;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		weight                                = weights[pixel];
		weightedFlux                          = weight * fluxes[pixel];
		weightedNonLinearTerm                 = weight * nonLinearTerms[pixel];
		weightedMeanOfFluxes                 += weightedFlux;
		weightedMeanOfNonLinearTerms         += weightedNonLinearTerm;
		weightedMeanOfProduct                += weightedFlux * nonLinearTerms[pixel];
		weightedMeanOfSquareNonLinearTerms   += weightedNonLinearTerm * nonLinearTerms[pixel];
	}

	weightedMeanOfFluxes                /= sumOfWeights;
	weightedMeanOfNonLinearTerms        /= sumOfWeights;
	weightedMeanOfProduct               /= sumOfWeights;
	weightedMeanOfSquareNonLinearTerms  /= sumOfWeights;

	/* Deduce scaleFacor and backGroundFlux which minimises the chiSquare */
	scaleFactor                          = (weightedMeanOfProduct - weightedMeanOfFluxes * weightedMeanOfNonLinearTerms) /
			(weightedMeanOfSquareNonLinearTerms - weightedMeanOfNonLinearTerms * weightedMeanOfNonLinearTerms);

	backGroundFlux                       = weightedMeanOfFluxes - scaleFactor * weightedMeanOfNonLinearTerms;
}

/**
 * Find the PSF refined solution
 */
double PsfFitter::refineSolution(bool& doesDiverge) {

	// Find the minimum of chiSquare with a Levenberg-Marquardt minimisation
	doesDiverge = theLevenbergMarquardtSystemSolver->optimise();

	const double chiSquare = theLevenbergMarquardtSystemSolver->getChiSquare();

	return chiSquare;
}

/**
 * Compute the minimum of fluxes
 */
double PsfFitter::findMinimumOfFluxes() {

	double minimumOfFluxes = fluxes[0];

	for(int pixel = 1; pixel < numberOfPixelsOneRadius; pixel++) {

		if(minimumOfFluxes  > fluxes[pixel]){
			minimumOfFluxes = fluxes[pixel];
		}
	}

	return minimumOfFluxes;
}

/**
 * Compute the total flux
 */
void PsfFitter::computeTotalFlux(PsfParameters& thePsfParameters, const double sigmaFactor) {

	const double maximumDistance = HOW_MANY_SIGMAS * sigmaFactor * thePsfParameters.getSigmaXY();
	//printf("maximumDistance = %f\n",maximumDistance);
	double deltaX;
	double deltaY;
	double totalFlux = 0.;

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		deltaX     = fabs(xPixels[pixel] - thePsfParameters.getPhotoCenterX());

		if(deltaX  > maximumDistance){
			continue;
		}

		deltaY     = fabs(yPixels[pixel] - thePsfParameters.getPhotoCenterY());

		if(deltaY  > maximumDistance){
			continue;
		}

		totalFlux += fluxes[pixel] - thePsfParameters.getBackGroundFlux();
	}

	thePsfParameters.setTotalFlux(totalFlux);
}

/**
 * Compute the total flux
 */
void PsfFitter::computeTotalFluxError(PsfParameters& thePsfParameters, const double sigmaFactor) {

	const double maximumDistance = HOW_MANY_SIGMAS * sigmaFactor * thePsfParameters.getSigmaXY();
	double deltaX;
	double deltaY;
	double fluxError = 0.;

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		deltaX     = fabs(xPixels[pixel] - thePsfParameters.getPhotoCenterX());

		if(deltaX  > maximumDistance){
			continue;
		}

		deltaY     = fabs(yPixels[pixel] - thePsfParameters.getPhotoCenterY());

		if(deltaY  > maximumDistance){
			continue;
		}

		fluxError += fluxErrors[pixel] * fluxErrors[pixel] + thePsfParameters.getBackGroundFluxError() * thePsfParameters.getBackGroundFluxError();
	}

	thePsfParameters.setTotalFluxError(sqrt(fluxError));
}

/**
 * Get the number of pixels for a given radius
 */
int PsfFitter::getNumberOfMeasurements() {
	return numberOfPixelsOneRadius;
}

/**
 * Fill the weighted observations (transformedFluxes / transformedFluxErrors) to find the preliminary solution
 */
void PsfFitter::fillWeightedObservations(double* const weightedObservartions) {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		weightedObservartions[pixel] = transformedFluxes[pixel] / transformedFluxErrors[pixel];
	}
}

/**
 * Fill the weighted delta observations (observation - fit) / sigma for the Levenberg-Marquardt minimisation
 */
void PsfFitter::fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters, double& chiSquare) {

	double scaleFactor;
	double backGroundFlux;

	fillNonLinearTerms(arrayOfParameters);
	deduceLinearParameters(scaleFactor, backGroundFlux);

	//	printf("new scaleFactor = %f - old scaleFactor = %f\n",scaleFactor,arrayOfParameters[SCALE_FACTOR_INDEX]);
	//	printf("new sky         = %f - old sky         = %f\n",backGroundFlux,arrayOfParameters[BACKGROUND_FLUX_INDEX]);

	if(scaleFactor     < 0.) {
		scaleFactor    = arrayOfParameters[SCALE_FACTOR_INDEX];
		if(scaleFactor < 0.) {
			throw InvalidDataException("Bad scale factor");
		}
	}
	arrayOfParameters[SCALE_FACTOR_INDEX]        = scaleFactor;

	if(backGroundFlux > 0.) {
		arrayOfParameters[BACKGROUND_FLUX_INDEX] = backGroundFlux;
	} else {
		arrayOfParameters[BACKGROUND_FLUX_INDEX] = 0.;
	}

	double fittedFlux;
	double deltaFlux;
	chiSquare = 0.;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		// The fitted flux can not be positive because we insure at every iteration that BACKGROUND_FLUX > 0. and SCALE_FACTOR > 0.
		fittedFlux                           = arrayOfParameters[BACKGROUND_FLUX_INDEX] + arrayOfParameters[SCALE_FACTOR_INDEX] * nonLinearTerms[pixel];
		deltaFlux                            = (fluxes[pixel] - fittedFlux) / fluxErrors[pixel];

		theWeightedDeltaObservartions[pixel] = deltaFlux;

		chiSquare                           += deltaFlux * deltaFlux;
	}
}

/**
 * Check the parameters of a given iteration
 */
void PsfFitter::checkArrayOfParameters(double* const arrayOfParameters) {

	if ((arrayOfParameters[SCALE_FACTOR_INDEX] <= 0.) || (arrayOfParameters[SIGMA_X_INDEX] <= 0.) || (arrayOfParameters[SIGMA_Y_INDEX] <= 0.)) {

		throw InvalidDataException("Bad array of parameters");
	}

	// Saturate back ground flux to 0.
	if (arrayOfParameters[BACKGROUND_FLUX_INDEX] < 0.) {
		arrayOfParameters[BACKGROUND_FLUX_INDEX] = 0.;
	}

	// Correct theta modulo 2 * pi
	correctTheta(arrayOfParameters[THETA_INDEX]);
}

/**
 * Correct theta modulo 2 * pi
 */
void PsfFitter::correctTheta(double& theta) {

	int ratio = (int)(theta / TWO_PI);
	if(theta  < 0.) {
		ratio--;
	}
	theta    -= ratio * TWO_PI;
}

/**
 * Class constructor
 */
Gaussian2DPsfFitter::Gaussian2DPsfFitter() : PsfFitter(GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS,GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION) {

	arrayOfPsfParameters = NULL;
}

/**
 * Class destructor
 */
Gaussian2DPsfFitter::~Gaussian2DPsfFitter() {

	if(arrayOfPsfParameters != NULL) {
		delete[] arrayOfPsfParameters;
		arrayOfPsfParameters = NULL;
	}
}

void Gaussian2DPsfFitter::allocateArrayOfOutputParameters() {

	arrayOfPsfParameters     = new PsfParameters[numberOfTestedRadius];
	if(arrayOfPsfParameters == NULL) {
		sprintf(logMessage,"arrayOfPsfParameters out of memory %d (PsfParameters*)",numberOfTestedRadius);
		throw InsufficientMemoryException(logMessage);
	}
}

void Gaussian2DPsfFitter::setRadius(const int radius) {

	arrayOfPsfParameters[indexOfRadius].setRadius(radius);
}

int Gaussian2DPsfFitter::fillArrayOfBackGrounds(indexedParameters* const arrayOfRestrictedParameters) {

	int numberOfGoodBackGrounds = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			arrayOfRestrictedParameters[numberOfGoodBackGrounds].backGroundFlux = arrayOfPsfParameters[index].getBackGroundFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].index          = index;
			numberOfGoodBackGrounds++;
		}
	}

	return numberOfGoodBackGrounds;
}

int Gaussian2DPsfFitter::fillParameters(indexedParameters* const arrayOfRestrictedParameters, const double backGroundFluxThreshold) {

	int numberOfGoodBackGrounds = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned() && (arrayOfPsfParameters[index].getBackGroundFlux() <= backGroundFluxThreshold)) {

			arrayOfRestrictedParameters[numberOfGoodBackGrounds].backGroundFlux  = arrayOfPsfParameters[index].getBackGroundFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].photocenterX    = arrayOfPsfParameters[index].getPhotoCenterX();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].photocenterY    = arrayOfPsfParameters[index].getPhotoCenterY();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].totalFlux       = arrayOfPsfParameters[index].getTotalFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].index           = index;
			numberOfGoodBackGrounds++;
		}
	}

	return numberOfGoodBackGrounds;
}

int Gaussian2DPsfFitter::cleanSolution(const int index) {

	/* Clean if not already cleaned */
	if(!arrayOfPsfParameters[index].getCleaned()) {
		arrayOfPsfParameters[index].setCleaned(true);
		return 1;
	} else {
		return 0;
	}
}

int Gaussian2DPsfFitter::cleanBadRadii() {

	int numberOfFailedSolutions = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(arrayOfPsfParameters[index].getDoesDiverge()) {
			arrayOfPsfParameters[index].setCleaned(true);
			numberOfFailedSolutions++;
		}
	}

	return numberOfFailedSolutions;
}

void Gaussian2DPsfFitter::copySolutionParameters(const int indexOfSolution) {

	bestPsfParameters.copyParameters(arrayOfPsfParameters[indexOfSolution]);
}

void Gaussian2DPsfFitter::fillBestSolution() {

	int numberOfGoodSolutions          = 0;
	double sumOfBackGroundFluxes       = 0.;
	double sumOfIntensities            = 0.;
	double sumOfTotalFlux              = 0.;
	double sumOfPhotoCenterX           = 0.;
	double sumOfPhotoCenterY           = 0.;
	double sumOfSigmaX                 = 0.;
	double sumOfSigmaY                 = 0.;
	double sumOfSigmaXY                = 0.;
	double sumOfTheta                  = 0.;
	double sumOfMaximumIntensity       = 0.;
	double sumOfSignalToNoise          = 0.;

	double modifiedTheta;
	double deltaValue;
	int ratio;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			numberOfGoodSolutions++;
			sumOfBackGroundFluxes       += arrayOfPsfParameters[index].getBackGroundFlux();
			sumOfIntensities            += arrayOfPsfParameters[index].getIntensity();
			sumOfTotalFlux              += arrayOfPsfParameters[index].getTotalFlux();
			sumOfPhotoCenterX           += arrayOfPsfParameters[index].getPhotoCenterX();
			sumOfPhotoCenterY           += arrayOfPsfParameters[index].getPhotoCenterY();
			sumOfSigmaX                 += arrayOfPsfParameters[index].getSigmaX();
			sumOfSigmaY                 += arrayOfPsfParameters[index].getSigmaY();
			sumOfSigmaXY                += arrayOfPsfParameters[index].getSigmaXY();
			sumOfSignalToNoise          += arrayOfPsfParameters[index].getSignalToNoiseRatio();
			modifiedTheta                = arrayOfPsfParameters[index].getTheta();
			if(modifiedTheta             > TWO_PI) {
				ratio                    = (int)(modifiedTheta / TWO_PI);
				modifiedTheta           -= ratio * TWO_PI;
			} else if (modifiedTheta     < -TWO_PI) {
				ratio                    = (int)(modifiedTheta / TWO_PI);
				modifiedTheta           += ratio * TWO_PI;
			}
			/* theta in [-pi, pi[ */
			if(modifiedTheta             > M_PI) {
				modifiedTheta           -= TWO_PI;
			} else if (modifiedTheta     < -M_PI) {
				modifiedTheta           += TWO_PI;
			}
			sumOfTheta                  += modifiedTheta;
			arrayOfPsfParameters[index].setTheta(modifiedTheta);
			sumOfMaximumIntensity       += arrayOfPsfParameters[index].getMaximumIntensity();
		}
	}

	sumOfBackGroundFluxes              /= numberOfGoodSolutions;
	sumOfIntensities                   /= numberOfGoodSolutions;
	sumOfTotalFlux                     /= numberOfGoodSolutions;
	sumOfPhotoCenterX                  /= numberOfGoodSolutions;
	sumOfPhotoCenterY                  /= numberOfGoodSolutions;
	sumOfSigmaX                        /= numberOfGoodSolutions;
	sumOfSigmaY                        /= numberOfGoodSolutions;
	sumOfSigmaXY                       /= numberOfGoodSolutions;
	sumOfSignalToNoise                 /= numberOfGoodSolutions;
	sumOfTheta                         /= numberOfGoodSolutions;
	sumOfMaximumIntensity              /= numberOfGoodSolutions;

	bestPsfParameters.setBackGroundFlux(sumOfBackGroundFluxes);
	bestPsfParameters.setIntensity(sumOfIntensities);
	bestPsfParameters.setTotalFlux(sumOfTotalFlux);
	bestPsfParameters.setPhotoCenterX(sumOfPhotoCenterX);
	bestPsfParameters.setPhotoCenterY(sumOfPhotoCenterY);
	bestPsfParameters.setSigmaX(sumOfSigmaX);
	bestPsfParameters.setSigmaY(sumOfSigmaY);
	bestPsfParameters.setSigmaXY(sumOfSigmaXY);
	bestPsfParameters.setSignalToNoiseRatio(sumOfSignalToNoise);
	bestPsfParameters.setTheta(sumOfTheta);
	bestPsfParameters.setMaximumIntensity(sumOfMaximumIntensity);

	double sumOfSquareBackGroundFluxes = 0.;
	double sumOfSquareIntensities      = 0.;
	double sumOfSquareTotalFlux        = 0.;
	double sumOfSquarePhotoCenterX     = 0.;
	double sumOfSquarePhotoCenterY     = 0.;
	double sumOfSquareSigmaX           = 0.;
	double sumOfSquareSigmaY           = 0.;
	double sumOfSquareTheta            = 0.;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			numberOfGoodSolutions++;
			deltaValue                   = arrayOfPsfParameters[index].getBackGroundFlux() - bestPsfParameters.getBackGroundFlux();
			sumOfSquareBackGroundFluxes += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getIntensity()      - bestPsfParameters.getIntensity();
			sumOfSquareIntensities      += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getTotalFlux()      - bestPsfParameters.getTotalFlux();
			sumOfSquareTotalFlux        += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getPhotoCenterX()   - bestPsfParameters.getPhotoCenterX();
			sumOfSquarePhotoCenterX     += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getPhotoCenterY()   - bestPsfParameters.getPhotoCenterY();
			sumOfSquarePhotoCenterY     += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getSigmaX()         - bestPsfParameters.getSigmaX();
			sumOfSquareSigmaX           += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getSigmaY()         - bestPsfParameters.getSigmaY();
			sumOfSquareSigmaY           += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getTheta()          - bestPsfParameters.getTheta();
			sumOfSquareTheta            += deltaValue * deltaValue;
		}
	}

	const int numberOfGoodSolutionsMinusOne = numberOfGoodSolutions - 1;

	if(numberOfGoodSolutionsMinusOne        > 0) {

		sumOfSquareBackGroundFluxes        /= numberOfGoodSolutionsMinusOne;
		sumOfSquareIntensities             /= numberOfGoodSolutionsMinusOne;
		sumOfSquareTotalFlux               /= numberOfGoodSolutionsMinusOne;
		sumOfSquarePhotoCenterX            /= numberOfGoodSolutionsMinusOne;
		sumOfSquarePhotoCenterY            /= numberOfGoodSolutionsMinusOne;
		sumOfSquareSigmaX                  /= numberOfGoodSolutionsMinusOne;
		sumOfSquareSigmaY                  /= numberOfGoodSolutionsMinusOne;
		sumOfSquareTheta                   /= numberOfGoodSolutionsMinusOne;

		bestPsfParameters.setBackGroundFluxError(3. * sqrt(sumOfSquareBackGroundFluxes));
		bestPsfParameters.setIntensityError(3. * sqrt(sumOfSquareIntensities));
		bestPsfParameters.setTotalFluxError(3. * sqrt(sumOfSquareTotalFlux));
		bestPsfParameters.setPhotoCenterXError(3. * sqrt(sumOfSquarePhotoCenterX));
		bestPsfParameters.setPhotoCenterYError(3. * sqrt(sumOfSquarePhotoCenterY));
		bestPsfParameters.setSigmaXError(3. * sqrt(sumOfSquareSigmaX));
		bestPsfParameters.setSigmaYError(3. * sqrt(sumOfSquareSigmaY));
		bestPsfParameters.setThetaError(3. * sqrt(sumOfSquareTheta));

	} else {

		/* Set negative errors instead of 0. */
		bestPsfParameters.setBackGroundFluxError(-1.);
		bestPsfParameters.setIntensityError(-1.);
		bestPsfParameters.setTotalFluxError(-1.);
		bestPsfParameters.setPhotoCenterXError(-1.);
		bestPsfParameters.setPhotoCenterYError(-1.);
		bestPsfParameters.setSigmaXError(-1.);
		bestPsfParameters.setSigmaYError(-1.);
		bestPsfParameters.setThetaError(-1.);
	}
}

/*
 * Get the PSF parameters
 */
const PsfParameters* Gaussian2DPsfFitter::getThePsfParameters() const {
	return arrayOfPsfParameters;
}

/*
 * Get the best solution
 */
const PsfParameters& Gaussian2DPsfFitter::getBestPsfParameters() const {
	return bestPsfParameters;
}

/**
 *  Decode the fit coefficients
 */
void Gaussian2DPsfFitter::setIntialSolution() {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setPhotoCenterX(initialSolutionParameters[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterY(initialSolutionParameters[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setSigmaX(initialSolutionParameters[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaY(initialSolutionParameters[SIGMA_Y_INDEX]);
	thePsfParameters.setTheta(initialSolutionParameters[THETA_INDEX]);

	/* Find the scaleFactor and backGroundFlux which minimise the chi square */
	double scaleFactor;
	double backGroundFlux;

	fillNonLinearTerms(initialSolutionParameters);
	deduceLinearParameters(scaleFactor, backGroundFlux);

	if(scaleFactor <= 0.) {
		thePsfParameters.setIntensity(initialSolutionParameters[SCALE_FACTOR_INDEX]);
	} else {
		thePsfParameters.setIntensity(scaleFactor);
	}

	if(backGroundFlux < 0.) {
		thePsfParameters.setBackGroundFlux(0.);
	} else {
		thePsfParameters.setBackGroundFlux(backGroundFlux);
	}

	if(DEBUG) {
		printf("GAUSSIAN 2D PSF preliminary solution :\n");
		printf("Number of pixels = %d\n",numberOfPixelsOneRadius);
		printf("Background flux  = %.3f\n",thePsfParameters.getBackGroundFlux());
		printf("Scale factor     = %.3f\n",thePsfParameters.getIntensity());
		printf("PhotocenterX     = %.3f\n",thePsfParameters.getPhotoCenterX());
		printf("PhotocenterY     = %.3f\n",thePsfParameters.getPhotoCenterY());
		printf("Theta            = %.3f degrees\n",thePsfParameters.getTheta() * 180. / M_PI);
		printf("SigmaX           = %.3f\n",thePsfParameters.getSigmaX());
		printf("SigmaY           = %.3f\n",thePsfParameters.getSigmaY());
	}
}

void Gaussian2DPsfFitter::fillNonLinearTerms(const double* const arrayOfParameters) {

	const double cosTheta        = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTheta        = sin(arrayOfParameters[THETA_INDEX]);
	const double twoSquareSigmaX = 2. * arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX];
	const double twoSquareSigmaY = 2. * arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX];
	double xCentered;
	double yCentered;
	double xCenteredAndRotated;
	double yCenteredAndRotated;
	double theEllipse;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		computeCenteredAndRotatedCoordinates(xPixels[pixel], yPixels[pixel], arrayOfParameters[PHOTOCENTER_X_INDEX], arrayOfParameters[PHOTOCENTER_Y_INDEX],
				cosTheta, sinTheta, xCentered, yCentered, xCenteredAndRotated, yCenteredAndRotated);

		theEllipse            = xCenteredAndRotated * xCenteredAndRotated / twoSquareSigmaX + yCenteredAndRotated * yCenteredAndRotated / twoSquareSigmaY;

		// The fitted flux can not be positive because we insure at every iteration that BACKGROUND_FLUX > 0. and SCALE_FACTOR > 0.
		nonLinearTerms[pixel] = exp(-theEllipse);
	}
}

/**
 * Fill the array of parameters for the Levenberg-Marquardt minimisation
 */
void Gaussian2DPsfFitter::fillArrayOfParameters(double* const arrayOfParameters) {

	PsfParameters& thePsfParameters          = arrayOfPsfParameters[indexOfRadius];

	arrayOfParameters[BACKGROUND_FLUX_INDEX] = thePsfParameters.getBackGroundFlux();
	arrayOfParameters[SCALE_FACTOR_INDEX]    = thePsfParameters.getIntensity();
	arrayOfParameters[PHOTOCENTER_X_INDEX]   = thePsfParameters.getPhotoCenterX();
	arrayOfParameters[PHOTOCENTER_Y_INDEX]   = thePsfParameters.getPhotoCenterY();
	arrayOfParameters[THETA_INDEX]           = thePsfParameters.getTheta();
	arrayOfParameters[SIGMA_X_INDEX]         = thePsfParameters.getSigmaX();
	arrayOfParameters[SIGMA_Y_INDEX]         = thePsfParameters.getSigmaY();
}

/**
 * Fill the weighted design matrix for the Levenberg-Marquardt minimisation
 */
void Gaussian2DPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters) {

	const double cosTheta        = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTheta        = sin(arrayOfParameters[THETA_INDEX]);
	const double squareCosTheta  = cosTheta * cosTheta;
	const double squareSinTheta  = sinTheta * sinTheta;
	const double sinTwoTheta     = 2. * sinTheta * cosTheta;
	const double cosTwoTheta     = squareCosTheta - squareSinTheta;
	const double squareSigmaX    = arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX];
	const double squareSigmaY    = arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX];
	const double cubeSigmaX      = arrayOfParameters[SIGMA_X_INDEX] * squareSigmaX;
	const double cubeSigmaY      = arrayOfParameters[SIGMA_Y_INDEX] * squareSigmaY;
	const double twoSquareSigmaX = 2. * squareSigmaX;
	const double twoSquareSigmaY = 2. * squareSigmaY;
	const double diffOfInverseSquareSigmas = 1. / twoSquareSigmaX - 1. / twoSquareSigmaY;
	double xCentered;
	double yCentered;
	double xCenteredAndRotated;
	double yCenteredAndRotated;
	double theEllipse;
	double exponentialEllipse;
	double commonTerm;
	double commenTermScaled;
	double subDerivative;
	double subDerivative1;
	double subDerivative2;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		computeCenteredAndRotatedCoordinates(xPixels[pixel], yPixels[pixel], arrayOfParameters[PHOTOCENTER_X_INDEX], arrayOfParameters[PHOTOCENTER_Y_INDEX],
				cosTheta, sinTheta, xCentered, yCentered, xCenteredAndRotated, yCenteredAndRotated);
		theEllipse            = xCenteredAndRotated * xCenteredAndRotated / twoSquareSigmaX + yCenteredAndRotated * yCenteredAndRotated / twoSquareSigmaY;
		exponentialEllipse    = exp(-theEllipse);
		commonTerm            = exponentialEllipse / fluxErrors[pixel];
		commenTermScaled      = arrayOfParameters[SCALE_FACTOR_INDEX] * commonTerm;

		// Derivative with respect to the background flux is always one
		weightedDesignMatrix[BACKGROUND_FLUX_INDEX][pixel] = 1. / fluxErrors[pixel];

		// Derivative with respect to the scale factor
		weightedDesignMatrix[SCALE_FACTOR_INDEX][pixel]    = commonTerm;

		// Derivative with respect to x0
		subDerivative1                                     = - 2. * xCentered * (squareCosTheta / twoSquareSigmaX + squareSinTheta / twoSquareSigmaY);
		subDerivative2                                     = - sinTwoTheta * yCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[PHOTOCENTER_X_INDEX][pixel]   = -commenTermScaled * (subDerivative1 + subDerivative2);

		// Derivative with respect to y0
		subDerivative1                                     = - 2. * yCentered * (squareSinTheta / twoSquareSigmaX + squareCosTheta / twoSquareSigmaY);
		subDerivative2                                     = - sinTwoTheta * xCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[PHOTOCENTER_Y_INDEX][pixel]   = -commenTermScaled * (subDerivative1 + subDerivative2);

		// Derivative with respect to theta
		subDerivative1                                     = -2. * sinTwoTheta * diffOfInverseSquareSigmas * (xCentered * xCentered - yCentered * yCentered);
		subDerivative2                                     = 2. * cosTwoTheta * xCentered * yCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[THETA_INDEX][pixel]           = -commenTermScaled * (subDerivative1 + subDerivative2);

		// Derivative with respect to sigmaX
		subDerivative                                      = -xCenteredAndRotated * xCenteredAndRotated / cubeSigmaX;
		weightedDesignMatrix[SIGMA_X_INDEX][pixel]         = -commenTermScaled * subDerivative;

		// Derivative with respect to sigmaY
		subDerivative                                      = -yCenteredAndRotated * yCenteredAndRotated / cubeSigmaY;
		weightedDesignMatrix[SIGMA_Y_INDEX][pixel]         = -commenTermScaled * subDerivative;
	}
}

/**
 * Copy thePsfParameters in thePsfParameters
 */
void Gaussian2DPsfFitter::copyParamtersInTheSolution(const double* const arrayOfParameters, const int radius, const double readOutNoise, const double positionThreshold, bool& doesDiverge) {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];
	thePsfParameters.setBackGroundFlux(arrayOfParameters[BACKGROUND_FLUX_INDEX]);
	thePsfParameters.setIntensity(arrayOfParameters[SCALE_FACTOR_INDEX]);
	thePsfParameters.setPhotoCenterX(arrayOfParameters[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterY(arrayOfParameters[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setTheta(arrayOfParameters[THETA_INDEX]);
	thePsfParameters.setSigmaX(arrayOfParameters[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaY(arrayOfParameters[SIGMA_Y_INDEX]);
	thePsfParameters.setSigmaXY(sqrt((arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX] +
			arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX]) / 2.));

	/* We integrate the 2D gaussian from -inf to +inf : replaced by a simpler method */
	computeTotalFlux(thePsfParameters,1.);
	//const double theTotalFlux      = arrayOfParameters[SCALE_FACTOR_INDEX] * 2 * M_PI * arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_Y_INDEX];
	//thePsfParameters.setTotalFlux(theTotalFlux);
	const double signalToNoise     = thePsfParameters.getTotalFlux() / sqrt(thePsfParameters.getTotalFlux() + radius * (readOutNoise * readOutNoise * arrayOfParameters[BACKGROUND_FLUX_INDEX]));
	thePsfParameters.setSignalToNoiseRatio(signalToNoise);

	if((fabs(thePsfParameters.getPhotoCenterX()) > positionThreshold) || (fabs(thePsfParameters.getPhotoCenterY()) > positionThreshold)) {
		doesDiverge = true;
	}
	thePsfParameters.setDoesDiverge(doesDiverge);

	if(DEBUG) {
		printf("GAUSSIAN PSF current best refined solution :\n");
		printf("Background flux  = %.3f\n",thePsfParameters.getBackGroundFlux());
		printf("Scale factor     = %.3f\n",thePsfParameters.getIntensity());
		printf("PhotocenterX     = %.3f\n",thePsfParameters.getPhotoCenterX());
		printf("PhotocenterY     = %.3f\n",thePsfParameters.getPhotoCenterY());
		printf("Theta            = %.3f degrees\n",thePsfParameters.getTheta() * 180. / M_PI);
		printf("SigmaX           = %.3f\n",thePsfParameters.getSigmaX());
		printf("SigmaY           = %.3f\n",thePsfParameters.getSigmaY());
		printf("SigmaXY          = %.3f\n",thePsfParameters.getSigmaXY());
		printf("Total flux       = %.3f\n",thePsfParameters.getTotalFlux());
		printf("Signal to noise  = %.3f\n",thePsfParameters.getSignalToNoiseRatio());
		printf("doesDiverge      = %df\n",thePsfParameters.getDoesDiverge());
	}
}

/**
 * Copy arrayOfParameterErrors in thePsfParameters
 */
void Gaussian2DPsfFitter::setErrorsInTheSolution(const double* const arrayOfParameterErrors, const bool doesDiverge) {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setDoesDiverge(doesDiverge);
	thePsfParameters.setBackGroundFluxError(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX]);
	thePsfParameters.setIntensityError(arrayOfParameterErrors[SCALE_FACTOR_INDEX]);
	thePsfParameters.setPhotoCenterXError(arrayOfParameterErrors[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterYError(arrayOfParameterErrors[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setThetaError(arrayOfParameterErrors[THETA_INDEX]);
	thePsfParameters.setSigmaXError(arrayOfParameterErrors[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaYError(arrayOfParameterErrors[SIGMA_Y_INDEX]);

	/* The error on the total flux */
	computeTotalFluxError(thePsfParameters,1.);
//	const double squareScaleFactor = thePsfParameters.getIntensity() * thePsfParameters.getIntensity();
//	const double squareSigmaX      = thePsfParameters.getSigmaX() * thePsfParameters.getSigmaX();
//	const double squareSigmaY      = thePsfParameters.getSigmaY() * thePsfParameters.getSigmaY();
//	const double theTotalFluxError = 2 * M_PI * sqrt(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX] * arrayOfParameterErrors[BACKGROUND_FLUX_INDEX] * squareSigmaX * squareSigmaY +
//			squareScaleFactor * arrayOfParameterErrors[SIGMA_X_INDEX] * arrayOfParameterErrors[SIGMA_X_INDEX] * squareSigmaY +
//			squareScaleFactor * squareSigmaX * arrayOfParameterErrors[SIGMA_Y_INDEX] * arrayOfParameterErrors[SIGMA_Y_INDEX]);
//	thePsfParameters.setTotalFluxError(theTotalFluxError);
}

/**
 * Add the initial shifts to the photo-center
 */
void Gaussian2DPsfFitter::updatePhotocenter(const int xCenter, const int yCenter) {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setPhotoCenterX(thePsfParameters.getPhotoCenterX() + xCenter);
	thePsfParameters.setPhotoCenterY(thePsfParameters.getPhotoCenterY() + yCenter);
}

void Gaussian2DPsfFitter::setHighestIntensityInWindow() {

	arrayOfPsfParameters[indexOfRadius].setMaximumIntensity(highestIntensityInWindow);
}

/**
 * Class constructor
 */
MoffatPsfFitter::MoffatPsfFitter() : PsfFitter(MOFFAT_PROFILE_NUMBER_OF_PARAMETERS,MOFFAT_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION) {

	arrayOfPsfParameters = NULL;
}

/**
 * Class destructor
 */
MoffatPsfFitter::~MoffatPsfFitter() {

	void freeListOfPsfParameters();
}

void MoffatPsfFitter::allocateArrayOfOutputParameters() {

	arrayOfPsfParameters     = new MoffatPsfParameters[numberOfTestedRadius];
	if(arrayOfPsfParameters == NULL) {
		sprintf(logMessage,"arrayOfPsfParameters out of memory %d (PsfParameters*)",numberOfTestedRadius);
		throw InsufficientMemoryException(logMessage);
	}
}

void MoffatPsfFitter::setRadius(const int radius) {

	arrayOfPsfParameters[indexOfRadius].setRadius(radius);
}

int MoffatPsfFitter::fillArrayOfBackGrounds(indexedParameters* const arrayOfRestrictedParameters) {

	int numberOfGoodBackGrounds = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			arrayOfRestrictedParameters[numberOfGoodBackGrounds].backGroundFlux = arrayOfPsfParameters[index].getBackGroundFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].index          = index;
			numberOfGoodBackGrounds++;
		}
	}

	return numberOfGoodBackGrounds;
}

int MoffatPsfFitter::fillParameters(indexedParameters* const arrayOfRestrictedParameters, const double backGroundFluxThreshold) {

	int numberOfGoodBackGrounds = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned() && (arrayOfPsfParameters[index].getBackGroundFlux() <= backGroundFluxThreshold)) {

			arrayOfRestrictedParameters[numberOfGoodBackGrounds].backGroundFlux  = arrayOfPsfParameters[index].getBackGroundFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].photocenterX    = arrayOfPsfParameters[index].getPhotoCenterX();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].photocenterY    = arrayOfPsfParameters[index].getPhotoCenterY();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].totalFlux       = arrayOfPsfParameters[index].getTotalFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].index           = index;
			numberOfGoodBackGrounds++;
		}
	}

	return numberOfGoodBackGrounds;
}

int MoffatPsfFitter::cleanSolution(const int index) {

	/* Clean if not already cleaned */
	if(!arrayOfPsfParameters[index].getCleaned()) {
		arrayOfPsfParameters[index].setCleaned(true);
		return 1;
	} else {
		return 0;
	}
}

int MoffatPsfFitter::cleanBadRadii() {

	int numberOfFailedSolutions = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(arrayOfPsfParameters[index].getDoesDiverge()) {
			arrayOfPsfParameters[index].setCleaned(true);
			numberOfFailedSolutions++;
		}
	}

	return numberOfFailedSolutions;
}

void MoffatPsfFitter::copySolutionParameters(const int indexOfSolution) {

	bestPsfParameters.copyParameters(arrayOfPsfParameters[indexOfSolution]);
}

void MoffatPsfFitter::fillBestSolution() {

	int numberOfGoodSolutions          = 0;
	double sumOfBackGroundFluxes       = 0.;
	double sumOfIntensities            = 0.;
	double sumOfTotalFlux              = 0.;
	double sumOfPhotoCenterX           = 0.;
	double sumOfPhotoCenterY           = 0.;
	double sumOfSigmaX                 = 0.;
	double sumOfSigmaY                 = 0.;
	double sumOfSigmaXY                = 0.;
	double sumOfTheta                  = 0.;
	double sumOfBeta                   = 0.;
	double sumOfMaximumIntensity       = 0.;
	double sumOfSignalToNoise          = 0.;

	double modifiedTheta;
	double deltaValue;
	int ratio;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			numberOfGoodSolutions++;
			sumOfBackGroundFluxes       += arrayOfPsfParameters[index].getBackGroundFlux();
			sumOfIntensities            += arrayOfPsfParameters[index].getIntensity();
			sumOfTotalFlux              += arrayOfPsfParameters[index].getTotalFlux();
			sumOfPhotoCenterX           += arrayOfPsfParameters[index].getPhotoCenterX();
			sumOfPhotoCenterY           += arrayOfPsfParameters[index].getPhotoCenterY();
			sumOfSigmaX                 += arrayOfPsfParameters[index].getSigmaX();
			sumOfSigmaY                 += arrayOfPsfParameters[index].getSigmaY();
			sumOfSigmaXY                += arrayOfPsfParameters[index].getSigmaXY();
			sumOfSignalToNoise          += arrayOfPsfParameters[index].getSignalToNoiseRatio();
			modifiedTheta                = arrayOfPsfParameters[index].getTheta();
			if(modifiedTheta             > TWO_PI) {
				ratio                    = (int)(modifiedTheta / TWO_PI);
				modifiedTheta           -= ratio * TWO_PI;
			} else if (modifiedTheta     < -TWO_PI) {
				ratio                    = (int)(modifiedTheta / TWO_PI);
				modifiedTheta           += ratio * TWO_PI;
			}
			/* theta in [-pi, pi[ */
			if(modifiedTheta             > M_PI) {
				modifiedTheta           -= TWO_PI;
			} else if (modifiedTheta     < -M_PI) {
				modifiedTheta           += TWO_PI;
			}
			sumOfTheta                  += modifiedTheta;
			sumOfBeta                   += arrayOfPsfParameters[index].getBeta();
			arrayOfPsfParameters[index].setTheta(modifiedTheta);
			sumOfMaximumIntensity       += arrayOfPsfParameters[index].getMaximumIntensity();
		}
	}

	sumOfBackGroundFluxes              /= numberOfGoodSolutions;
	sumOfIntensities                   /= numberOfGoodSolutions;
	sumOfTotalFlux                     /= numberOfGoodSolutions;
	sumOfPhotoCenterX                  /= numberOfGoodSolutions;
	sumOfPhotoCenterY                  /= numberOfGoodSolutions;
	sumOfSigmaX                        /= numberOfGoodSolutions;
	sumOfSigmaY                        /= numberOfGoodSolutions;
	sumOfSigmaXY                       /= numberOfGoodSolutions;
	sumOfSignalToNoise                 /= numberOfGoodSolutions;
	sumOfTheta                         /= numberOfGoodSolutions;
	sumOfBeta                          /= numberOfGoodSolutions;
	sumOfMaximumIntensity              /= numberOfGoodSolutions;

	bestPsfParameters.setBackGroundFlux(sumOfBackGroundFluxes);
	bestPsfParameters.setIntensity(sumOfIntensities);
	bestPsfParameters.setTotalFlux(sumOfTotalFlux);
	bestPsfParameters.setPhotoCenterX(sumOfPhotoCenterX);
	bestPsfParameters.setPhotoCenterY(sumOfPhotoCenterY);
	bestPsfParameters.setSigmaX(sumOfSigmaX);
	bestPsfParameters.setSigmaY(sumOfSigmaY);
	bestPsfParameters.setSigmaXY(sumOfSigmaXY);
	bestPsfParameters.setSignalToNoiseRatio(sumOfSignalToNoise);
	bestPsfParameters.setTheta(sumOfTheta);
	bestPsfParameters.setBeta(sumOfBeta);
	bestPsfParameters.setMaximumIntensity(sumOfMaximumIntensity);

	double sumOfSquareBackGroundFluxes = 0.;
	double sumOfSquareIntensities      = 0.;
	double sumOfSquareTotalFlux        = 0.;
	double sumOfSquarePhotoCenterX     = 0.;
	double sumOfSquarePhotoCenterY     = 0.;
	double sumOfSquareSigmaX           = 0.;
	double sumOfSquareSigmaY           = 0.;
	double sumOfSquareTheta            = 0.;
	double sumOfSquareBeta             = 0.;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			numberOfGoodSolutions++;
			deltaValue                   = arrayOfPsfParameters[index].getBackGroundFlux() - bestPsfParameters.getBackGroundFlux();
			sumOfSquareBackGroundFluxes += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getIntensity()      - bestPsfParameters.getIntensity();
			sumOfSquareIntensities      += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getTotalFlux()      - bestPsfParameters.getTotalFlux();
			sumOfSquareTotalFlux        += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getPhotoCenterX()   - bestPsfParameters.getPhotoCenterX();
			sumOfSquarePhotoCenterX     += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getPhotoCenterY()   - bestPsfParameters.getPhotoCenterY();
			sumOfSquarePhotoCenterY     += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getSigmaX()         - bestPsfParameters.getSigmaX();
			sumOfSquareSigmaX           += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getSigmaY()         - bestPsfParameters.getSigmaY();
			sumOfSquareSigmaY           += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getTheta()          - bestPsfParameters.getTheta();
			sumOfSquareTheta            += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getBeta()           - bestPsfParameters.getBeta();
			sumOfSquareBeta             += deltaValue * deltaValue;
		}
	}

	const int numberOfGoodSolutionsMinusOne = numberOfGoodSolutions - 1;

	if(numberOfGoodSolutionsMinusOne        > 0) {

		sumOfSquareBackGroundFluxes        /= numberOfGoodSolutionsMinusOne;
		sumOfSquareIntensities             /= numberOfGoodSolutionsMinusOne;
		sumOfSquareTotalFlux               /= numberOfGoodSolutionsMinusOne;
		sumOfSquarePhotoCenterX            /= numberOfGoodSolutionsMinusOne;
		sumOfSquarePhotoCenterY            /= numberOfGoodSolutionsMinusOne;
		sumOfSquareSigmaX                  /= numberOfGoodSolutionsMinusOne;
		sumOfSquareSigmaY                  /= numberOfGoodSolutionsMinusOne;
		sumOfSquareTheta                   /= numberOfGoodSolutionsMinusOne;
		sumOfSquareBeta                    /= numberOfGoodSolutionsMinusOne;

		bestPsfParameters.setBackGroundFluxError(3. * sqrt(sumOfSquareBackGroundFluxes));
		bestPsfParameters.setIntensityError(3. * sqrt(sumOfSquareIntensities));
		bestPsfParameters.setTotalFluxError(3. * sqrt(sumOfSquareTotalFlux));
		bestPsfParameters.setPhotoCenterXError(3. * sqrt(sumOfSquarePhotoCenterX));
		bestPsfParameters.setPhotoCenterYError(3. * sqrt(sumOfSquarePhotoCenterY));
		bestPsfParameters.setSigmaXError(3. * sqrt(sumOfSquareSigmaX));
		bestPsfParameters.setSigmaYError(3. * sqrt(sumOfSquareSigmaY));
		bestPsfParameters.setThetaError(3. * sqrt(sumOfSquareTheta));
		bestPsfParameters.setBetaError(3. * sqrt(sumOfSquareBeta));

	} else {

		/* Set negative errors instead of 0. */
		bestPsfParameters.setBackGroundFluxError(-1.);
		bestPsfParameters.setIntensityError(-1.);
		bestPsfParameters.setTotalFluxError(-1.);
		bestPsfParameters.setPhotoCenterXError(-1.);
		bestPsfParameters.setPhotoCenterYError(-1.);
		bestPsfParameters.setSigmaXError(-1.);
		bestPsfParameters.setSigmaYError(-1.);
		bestPsfParameters.setThetaError(-1.);
		bestPsfParameters.setBetaError(-1.);
	}
}


/*
 * Get the PSF parameters
 */
const MoffatPsfParameters* MoffatPsfFitter::getThePsfParameters() const{
	return arrayOfPsfParameters;
}

/*
 * Get the best solution
 */
const MoffatPsfParameters& MoffatPsfFitter::getBestPsfParameters() const {
	return bestPsfParameters;
}

/**
 *  Decode the fit coefficients (beta = -1)
 */
void MoffatPsfFitter::setIntialSolution() {

	MoffatPsfParameters& thePsfParameters     = arrayOfPsfParameters[indexOfRadius];

	const double sqrtOfTwo                    = sqrt(2.);
	initialSolutionParameters[SIGMA_X_INDEX] *= sqrtOfTwo;
	initialSolutionParameters[SIGMA_Y_INDEX] *= sqrtOfTwo;

	thePsfParameters.setPhotoCenterX(initialSolutionParameters[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterY(initialSolutionParameters[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setSigmaX(initialSolutionParameters[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaY(initialSolutionParameters[SIGMA_Y_INDEX]);
	thePsfParameters.setTheta(initialSolutionParameters[THETA_INDEX]);

	/* Deduce best beta */
	deduceBestBeta();

	if(initialSolutionParameters[BETA_INDEX] >= 0.) {
		initialSolutionParameters[BETA_INDEX] = -3.;
	}
	thePsfParameters.setBeta(initialSolutionParameters[BETA_INDEX]);

	/* Find the scaleFactor and backGroundFlux which minimise the chi square */
	double scaleFactor;
	double backGroundFlux;

	fillNonLinearTerms(initialSolutionParameters);
	deduceLinearParameters(scaleFactor, backGroundFlux);

	if(scaleFactor <= 0.) {
		thePsfParameters.setIntensity(initialSolutionParameters[SCALE_FACTOR_INDEX]);
	} else {
		thePsfParameters.setIntensity(scaleFactor);
	}

	if(backGroundFlux < 0.) {
		thePsfParameters.setBackGroundFlux(0.);
	} else {
		thePsfParameters.setBackGroundFlux(backGroundFlux);
	}

	if(DEBUG) {
		printf("MOFFAT PSF preliminary solution :\n");
		printf("Number of pixels = %d\n",numberOfPixelsOneRadius);
		printf("Background flux  = %.3f\n",thePsfParameters.getBackGroundFlux());
		printf("Scale factor     = %.3f\n",thePsfParameters.getIntensity());
		printf("PhotocenterX     = %.3f\n",thePsfParameters.getPhotoCenterX());
		printf("PhotocenterY     = %.3f\n",thePsfParameters.getPhotoCenterY());
		printf("Theta            = %.3f degrees\n",thePsfParameters.getTheta() * 180. / M_PI);
		printf("SigmaX           = %.3f\n",thePsfParameters.getSigmaX());
		printf("SigmaY           = %.3f\n",thePsfParameters.getSigmaY());
		printf("Beta             = %.3f\n",thePsfParameters.getBeta());
	}
}

void MoffatPsfFitter::deduceBestBeta() {

	const double cosTheta     = cos(initialSolutionParameters[THETA_INDEX]);
	const double sinTheta     = sin(initialSolutionParameters[THETA_INDEX]);
	const double squareSigmaX = initialSolutionParameters[SIGMA_X_INDEX] * initialSolutionParameters[SIGMA_X_INDEX];
	const double squareSigmaY = initialSolutionParameters[SIGMA_Y_INDEX] * initialSolutionParameters[SIGMA_Y_INDEX];
	double weight;
	double xCentered;
	double yCentered;
	double xCenteredAndRotated;
	double yCenteredAndRotated;
	double polynomialTerm;
	double logPolynomialTerm;
	double weightedFlux;
	double weightedPolynomialTerm;
	double sumOfWeights                    = 0.;
	double weightedMeanOfFluxes            = 0.;
	double weightedMeanOfPolynomialTerms   = 0.;
	double weightedMeanOfProduct           = 0.;
	double weightedMeanOfSquarePolynomials = 0.;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		computeCenteredAndRotatedCoordinates(xPixels[pixel], yPixels[pixel], initialSolutionParameters[PHOTOCENTER_X_INDEX],
				initialSolutionParameters[PHOTOCENTER_Y_INDEX], cosTheta, sinTheta, xCentered, yCentered, xCenteredAndRotated, yCenteredAndRotated);

		polynomialTerm                    = 1. + xCenteredAndRotated * xCenteredAndRotated / squareSigmaX + yCenteredAndRotated * yCenteredAndRotated / squareSigmaY;

		// The fitted flux can not be positive because we insure at every iteration that BACKGROUND_FLUX > 0. and SCALE_FACTOR > 0.
		logPolynomialTerm                 = log(polynomialTerm);

		weight                            = 1. / (transformedFluxErrors[pixel] * transformedFluxErrors[pixel]);
		sumOfWeights                     += weight;
		weightedFlux                      = weight * transformedFluxes[pixel];
		weightedPolynomialTerm            = weight * logPolynomialTerm;
		weightedMeanOfFluxes             += weightedFlux;
		weightedMeanOfPolynomialTerms    += weightedPolynomialTerm;
		weightedMeanOfProduct            += weightedFlux * logPolynomialTerm;
		weightedMeanOfSquarePolynomials  += weightedPolynomialTerm * logPolynomialTerm;
	}

	weightedMeanOfFluxes                 /= sumOfWeights;
	weightedMeanOfPolynomialTerms        /= sumOfWeights;
	weightedMeanOfProduct                /= sumOfWeights;
	weightedMeanOfSquarePolynomials      /= sumOfWeights;

	/* Deduce scaleFacor and backGroundFlux which minimises the chiSquare */
	initialSolutionParameters[BETA_INDEX] = (weightedMeanOfProduct - weightedMeanOfFluxes * weightedMeanOfPolynomialTerms) /
			(weightedMeanOfSquarePolynomials - weightedMeanOfPolynomialTerms * weightedMeanOfPolynomialTerms);

	//const double logOfScale              = weightedMeanOfFluxes - theBeta * weightedMeanOfPolynomialTerms;
	//printf("scale by beta = %.3f\n",exp(logOfScale));
}

void MoffatPsfFitter::fillNonLinearTerms(const double* const arrayOfParameters) {

	const double cosTheta     = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTheta     = sin(arrayOfParameters[THETA_INDEX]);
	const double squareSigmaX = arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX];
	const double squareSigmaY = arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX];
	double xCentered;
	double yCentered;
	double xCenteredAndRotated;
	double yCenteredAndRotated;
	double polynomialTerm;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		computeCenteredAndRotatedCoordinates(xPixels[pixel], yPixels[pixel], arrayOfParameters[PHOTOCENTER_X_INDEX], arrayOfParameters[PHOTOCENTER_Y_INDEX],
				cosTheta, sinTheta, xCentered, yCentered, xCenteredAndRotated, yCenteredAndRotated);

		polynomialTerm        = 1. + xCenteredAndRotated * xCenteredAndRotated / squareSigmaX + yCenteredAndRotated * yCenteredAndRotated / squareSigmaY;

		// The fitted flux can not be positive because we insure at every iteration that BACKGROUND_FLUX > 0. and SCALE_FACTOR > 0.
		nonLinearTerms[pixel] = exp(arrayOfParameters[BETA_INDEX] * log(polynomialTerm));
	}
}

/**
 * Fill the array of parameters for the Levenberg-Marquardt minimisation
 */
void MoffatPsfFitter::fillArrayOfParameters(double* const arrayOfParameters) {

	MoffatPsfParameters& thePsfParameters    = arrayOfPsfParameters[indexOfRadius];

	arrayOfParameters[BACKGROUND_FLUX_INDEX] = thePsfParameters.getBackGroundFlux();
	arrayOfParameters[SCALE_FACTOR_INDEX]    = thePsfParameters.getIntensity();
	arrayOfParameters[PHOTOCENTER_X_INDEX]   = thePsfParameters.getPhotoCenterX();
	arrayOfParameters[PHOTOCENTER_Y_INDEX]   = thePsfParameters.getPhotoCenterY();
	arrayOfParameters[THETA_INDEX]           = thePsfParameters.getTheta();
	arrayOfParameters[SIGMA_X_INDEX]         = thePsfParameters.getSigmaX();
	arrayOfParameters[SIGMA_Y_INDEX]         = thePsfParameters.getSigmaY();
	arrayOfParameters[BETA_INDEX]            = thePsfParameters.getBeta();
}

/**
 * Fill the weighted design matrix for the Levenberg-Marquardt minimisation
 */
void MoffatPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters) {

	const double cosTheta                  = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTheta                  = sin(arrayOfParameters[THETA_INDEX]);
	const double sigmaX                    = arrayOfParameters[SIGMA_X_INDEX];
	const double sigmaY                    = arrayOfParameters[SIGMA_Y_INDEX];
	const double squareCosTheta            = cosTheta * cosTheta;
	const double squareSinTheta            = sinTheta * sinTheta;
	const double sinTwoTheta               = 2. * sinTheta * cosTheta;
	const double cosTwoTheta               = cosTheta * cosTheta - sinTheta * sinTheta;
	const double squareSigmaX              = sigmaX * sigmaX;
	const double squareSigmaY              = sigmaY * sigmaY;
	const double diffOfInverseSquareSigmas = 1. / squareSigmaX - 1. / squareSigmaY;

	double xCentered;
	double yCentered;
	double xCenteredAndRotated;
	double yCenteredAndRotated;
	double xReduced;
	double yReduced;
	double subDerivative;
	double subDerivative1;
	double subDerivative2;
	double polynomialTerm;
	double logOfPolynomialTerm;
	double polynomialTermPowerBetaMinusOne;
	double polynomialTermPowerBeta;
	double betaPolynomialTermPowerBetaMinusOne;
	double scaledBetaPolynomialTermPowerBetaMinusOneByError;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		computeCenteredAndRotatedCoordinates(xPixels[pixel], yPixels[pixel], arrayOfParameters[PHOTOCENTER_X_INDEX], arrayOfParameters[PHOTOCENTER_Y_INDEX],
				cosTheta, sinTheta, xCentered, yCentered, xCenteredAndRotated, yCenteredAndRotated);

		xReduced                                          = xCenteredAndRotated / arrayOfParameters[SIGMA_X_INDEX];
		yReduced                                          = yCenteredAndRotated / arrayOfParameters[SIGMA_Y_INDEX];
		polynomialTerm                                    = 1. + xReduced * xReduced + yReduced * yReduced;
		logOfPolynomialTerm                               = log(polynomialTerm);
		polynomialTermPowerBeta                           = exp(arrayOfParameters[BETA_INDEX] * logOfPolynomialTerm);
		polynomialTermPowerBetaMinusOne                   = polynomialTermPowerBeta / polynomialTerm;

		betaPolynomialTermPowerBetaMinusOne               = arrayOfParameters[BETA_INDEX] * polynomialTermPowerBetaMinusOne;
		scaledBetaPolynomialTermPowerBetaMinusOneByError  = arrayOfParameters[SCALE_FACTOR_INDEX] * betaPolynomialTermPowerBetaMinusOne / fluxErrors[pixel];

		// Derivative with respect to the background flux is always one
		weightedDesignMatrix[BACKGROUND_FLUX_INDEX][pixel] = 1. / fluxErrors[pixel];

		// Derivative with respect to the scale
		weightedDesignMatrix[SCALE_FACTOR_INDEX][pixel]    = polynomialTermPowerBeta / fluxErrors[pixel];

		// Derivative with respect to x0
		subDerivative1                                    = - 2. * xCentered * (squareCosTheta / squareSigmaX + squareSinTheta / squareSigmaY);
		subDerivative2                                    = - sinTwoTheta * yCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[PHOTOCENTER_X_INDEX][pixel]   = scaledBetaPolynomialTermPowerBetaMinusOneByError * (subDerivative1 + subDerivative2);

		// Derivative with respect to y0
		subDerivative1                                    = - 2. * yCentered * (squareSinTheta / squareSigmaX + squareCosTheta / squareSigmaY);
		subDerivative2                                    = - sinTwoTheta * xCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[PHOTOCENTER_Y_INDEX][pixel]   = scaledBetaPolynomialTermPowerBetaMinusOneByError * (subDerivative1 + subDerivative2);

		// Derivative with respect to theta
		subDerivative1                                    = -2. * sinTwoTheta * diffOfInverseSquareSigmas * (xCentered * xCentered - yCentered * yCentered);
		subDerivative2                                    = 2. * cosTwoTheta * xCentered * yCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[THETA_INDEX][pixel]           = scaledBetaPolynomialTermPowerBetaMinusOneByError * (subDerivative1 + subDerivative2);

		// Derivative with respect to sigmaX
		subDerivative                                     = -2 * xReduced * xReduced / sigmaX;
		weightedDesignMatrix[SIGMA_X_INDEX][pixel]         = scaledBetaPolynomialTermPowerBetaMinusOneByError * subDerivative;

		// Derivative with respect to sigmaY
		subDerivative                                     = -2 * yReduced * yReduced / sigmaY;
		weightedDesignMatrix[SIGMA_Y_INDEX][pixel]         = scaledBetaPolynomialTermPowerBetaMinusOneByError * subDerivative;

		// Derivative with respect to beta
		weightedDesignMatrix[BETA_INDEX][pixel]            = arrayOfParameters[SCALE_FACTOR_INDEX] * polynomialTermPowerBeta * logOfPolynomialTerm / fluxErrors[pixel];
	}
}

/**
 * Check the parameters of a given iteration
 */
void MoffatPsfFitter::checkArrayOfParameters(double* const arrayOfParameters) {

	PsfFitter::checkArrayOfParameters(arrayOfParameters);

	if (arrayOfParameters[BETA_INDEX] >= 0.) {

		throw InvalidDataException("Bad beta parameter");
	}
}

/**
 * Copy thePsfParameters in thePsfParameters
 */
void MoffatPsfFitter::copyParamtersInTheSolution(const double* const arrayOfParameters, const int radius, const double readOutNoise, const double positionThreshold, bool& doesDiverge) {

	MoffatPsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setBackGroundFlux(arrayOfParameters[BACKGROUND_FLUX_INDEX]);
	thePsfParameters.setIntensity(arrayOfParameters[SCALE_FACTOR_INDEX]);
	thePsfParameters.setPhotoCenterX(arrayOfParameters[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterY(arrayOfParameters[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setTheta(arrayOfParameters[THETA_INDEX]);
	thePsfParameters.setSigmaX(arrayOfParameters[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaY(arrayOfParameters[SIGMA_Y_INDEX]);
	thePsfParameters.setBeta(arrayOfParameters[BETA_INDEX]);
	thePsfParameters.setSigmaXY(sqrt((arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX] +
			arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX]) / 2.));

	/* We integrate the Moffat profile from -inf to +inf*/
	const double theTotalFlux  = -arrayOfParameters[SCALE_FACTOR_INDEX] * M_PI * arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_Y_INDEX] / (1. + arrayOfParameters[BETA_INDEX]);
	thePsfParameters.setTotalFlux(theTotalFlux);
	const double signalToNoise = theTotalFlux / sqrt(theTotalFlux + radius * (readOutNoise * readOutNoise * arrayOfParameters[BACKGROUND_FLUX_INDEX]));
	thePsfParameters.setSignalToNoiseRatio(signalToNoise);

	if((fabs(thePsfParameters.getPhotoCenterX()) > positionThreshold) || (fabs(thePsfParameters.getPhotoCenterY()) > positionThreshold)) {
		doesDiverge = true;
	}
	thePsfParameters.setDoesDiverge(doesDiverge);

	if(DEBUG) {
		printf("MOFFAT PSF current best refined solution :\n");
		printf("Background flux  = %.3f\n",thePsfParameters.getBackGroundFlux());
		printf("Scale factor     = %.3f\n",thePsfParameters.getIntensity());
		printf("PhotocenterX     = %.3f\n",thePsfParameters.getPhotoCenterX());
		printf("PhotocenterY     = %.3f\n",thePsfParameters.getPhotoCenterY());
		printf("Theta            = %.3f degrees\n",thePsfParameters.getTheta() * 180. / M_PI);
		printf("SigmaX           = %.3f\n",thePsfParameters.getSigmaX());
		printf("SigmaY           = %.3f\n",thePsfParameters.getSigmaY());
		printf("SigmaXY          = %.3f\n",thePsfParameters.getSigmaXY());
		printf("Total flux       = %.3f\n",thePsfParameters.getTotalFlux());
		printf("Signal to noise  = %.3f\n",thePsfParameters.getSignalToNoiseRatio());
		printf("Beta             = %.3f\n",thePsfParameters.getBeta());
		printf("doesDiverge      = %df\n",thePsfParameters.getDoesDiverge());
	}
}

/**
 * Copy arrayOfParameterErrors in thePsfParameters
 */
void MoffatPsfFitter::setErrorsInTheSolution(const double* const arrayOfParameterErrors, const bool doesDiverge) {

	MoffatPsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setDoesDiverge(doesDiverge);
	thePsfParameters.setBackGroundFluxError(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX]);
	thePsfParameters.setIntensityError(arrayOfParameterErrors[SCALE_FACTOR_INDEX]);
	thePsfParameters.setPhotoCenterXError(arrayOfParameterErrors[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterYError(arrayOfParameterErrors[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setThetaError(arrayOfParameterErrors[THETA_INDEX]);
	thePsfParameters.setSigmaXError(arrayOfParameterErrors[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaYError(arrayOfParameterErrors[SIGMA_Y_INDEX]);
	thePsfParameters.setBetaError(arrayOfParameterErrors[BETA_INDEX]);

	const double squareScaleFactor = thePsfParameters.getIntensity() * thePsfParameters.getIntensity();
	const double squareSigmaX      = thePsfParameters.getSigmaX() * thePsfParameters.getSigmaX();
	const double squareSigmaY      = thePsfParameters.getSigmaY() * thePsfParameters.getSigmaY();
	double onePlusBeta             = 1 + arrayOfParameterErrors[BETA_INDEX];
	const double theTotalFluxError = M_PI / onePlusBeta *
			sqrt(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX] * arrayOfParameterErrors[BACKGROUND_FLUX_INDEX] * squareSigmaX * squareSigmaY +
					squareScaleFactor * arrayOfParameterErrors[SIGMA_X_INDEX] * arrayOfParameterErrors[SIGMA_X_INDEX] * squareSigmaY +
					squareScaleFactor * squareSigmaX * arrayOfParameterErrors[SIGMA_Y_INDEX] * arrayOfParameterErrors[SIGMA_Y_INDEX] +
					squareScaleFactor * squareSigmaX * squareSigmaY * arrayOfParameterErrors[BETA_INDEX] * arrayOfParameterErrors[BETA_INDEX] / onePlusBeta / onePlusBeta);
	thePsfParameters.setTotalFluxError(theTotalFluxError);
}

/**
 * Add the initial shifts to the photo-center
 */
void MoffatPsfFitter::updatePhotocenter(const int xCenter, const int yCenter) {

	MoffatPsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setPhotoCenterX(thePsfParameters.getPhotoCenterX() + xCenter);
	thePsfParameters.setPhotoCenterY(thePsfParameters.getPhotoCenterY() + yCenter);
}

void MoffatPsfFitter::setHighestIntensityInWindow() {

	arrayOfPsfParameters[indexOfRadius].setMaximumIntensity(highestIntensityInWindow);
}

/**
 * Class constructor
 */
MoffatFixedBetaPsfFitter::MoffatFixedBetaPsfFitter(const double inputBetaPower) : PsfFitter(MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS,MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION), theBetaPower(inputBetaPower) {

	arrayOfPsfParameters = NULL;
}

/**
 * Class destructor
 */
MoffatFixedBetaPsfFitter::~MoffatFixedBetaPsfFitter() {

	if(arrayOfPsfParameters != NULL) {
		delete[] arrayOfPsfParameters;
		arrayOfPsfParameters = NULL;
	}
}

void MoffatFixedBetaPsfFitter::allocateArrayOfOutputParameters() {

	arrayOfPsfParameters     = new PsfParameters[numberOfTestedRadius];
	if(arrayOfPsfParameters == NULL) {
		sprintf(logMessage,"arrayOfPsfParameters out of memory %d (PsfParameters*)",numberOfTestedRadius);
		throw InsufficientMemoryException(logMessage);
	}
}

void MoffatFixedBetaPsfFitter::setRadius(const int radius) {

	arrayOfPsfParameters[indexOfRadius].setRadius(radius);
}

int MoffatFixedBetaPsfFitter::fillArrayOfBackGrounds(indexedParameters* const arrayOfRestrictedParameters) {

	int numberOfGoodBackGrounds = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			arrayOfRestrictedParameters[numberOfGoodBackGrounds].backGroundFlux = arrayOfPsfParameters[index].getBackGroundFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].index          = index;
			numberOfGoodBackGrounds++;
		}
	}

	return numberOfGoodBackGrounds;
}

int MoffatFixedBetaPsfFitter::fillParameters(indexedParameters* const arrayOfRestrictedParameters, const double backGroundFluxThreshold) {

	int numberOfGoodBackGrounds = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned() && (arrayOfPsfParameters[index].getBackGroundFlux() <= backGroundFluxThreshold)) {

			arrayOfRestrictedParameters[numberOfGoodBackGrounds].backGroundFlux  = arrayOfPsfParameters[index].getBackGroundFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].photocenterX    = arrayOfPsfParameters[index].getPhotoCenterX();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].photocenterY    = arrayOfPsfParameters[index].getPhotoCenterY();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].totalFlux       = arrayOfPsfParameters[index].getTotalFlux();
			arrayOfRestrictedParameters[numberOfGoodBackGrounds].index           = index;
			numberOfGoodBackGrounds++;
		}
	}

	return numberOfGoodBackGrounds;
}

int MoffatFixedBetaPsfFitter::cleanSolution(const int index) {

	/* Clean if not already cleaned */
	if(!arrayOfPsfParameters[index].getCleaned()) {
		arrayOfPsfParameters[index].setCleaned(true);
		return 1;
	} else {
		return 0;
	}
}

int MoffatFixedBetaPsfFitter::cleanBadRadii() {

	int numberOfFailedSolutions = 0;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(arrayOfPsfParameters[index].getDoesDiverge()) {
			arrayOfPsfParameters[index].setCleaned(true);
			numberOfFailedSolutions++;
		}
	}

	return numberOfFailedSolutions;
}

void MoffatFixedBetaPsfFitter::copySolutionParameters(const int indexOfSolution) {

	bestPsfParameters.copyParameters(arrayOfPsfParameters[indexOfSolution]);
}

void MoffatFixedBetaPsfFitter::fillBestSolution() {

	int numberOfGoodSolutions          = 0;
	double sumOfBackGroundFluxes       = 0.;
	double sumOfIntensities            = 0.;
	double sumOfTotalFlux              = 0.;
	double sumOfPhotoCenterX           = 0.;
	double sumOfPhotoCenterY           = 0.;
	double sumOfSigmaX                 = 0.;
	double sumOfSigmaY                 = 0.;
	double sumOfSigmaXY                = 0.;
	double sumOfTheta                  = 0.;
	double sumOfMaximumIntensity       = 0.;
	double sumOfSignalToNoise          = 0.;

	double modifiedTheta;
	double deltaValue;
	int ratio;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			numberOfGoodSolutions++;
			sumOfBackGroundFluxes       += arrayOfPsfParameters[index].getBackGroundFlux();
			sumOfIntensities            += arrayOfPsfParameters[index].getIntensity();
			sumOfTotalFlux              += arrayOfPsfParameters[index].getTotalFlux();
			sumOfPhotoCenterX           += arrayOfPsfParameters[index].getPhotoCenterX();
			sumOfPhotoCenterY           += arrayOfPsfParameters[index].getPhotoCenterY();
			sumOfSigmaX                 += arrayOfPsfParameters[index].getSigmaX();
			sumOfSigmaY                 += arrayOfPsfParameters[index].getSigmaY();
			sumOfSigmaXY                += arrayOfPsfParameters[index].getSigmaXY();
			sumOfSignalToNoise          += arrayOfPsfParameters[index].getSignalToNoiseRatio();
			modifiedTheta                = arrayOfPsfParameters[index].getTheta();
			if(modifiedTheta             > TWO_PI) {
				ratio                    = (int)(modifiedTheta / TWO_PI);
				modifiedTheta           -= ratio * TWO_PI;
			} else if (modifiedTheta     < -TWO_PI) {
				ratio                    = (int)(modifiedTheta / TWO_PI);
				modifiedTheta           += ratio * TWO_PI;
			}
			/* theta in [-pi, pi[ */
			if(modifiedTheta             > M_PI) {
				modifiedTheta           -= TWO_PI;
			} else if (modifiedTheta     < -M_PI) {
				modifiedTheta           += TWO_PI;
			}
			sumOfTheta                  += modifiedTheta;
			arrayOfPsfParameters[index].setTheta(modifiedTheta);
			sumOfMaximumIntensity       += arrayOfPsfParameters[index].getMaximumIntensity();
		}
	}

	sumOfBackGroundFluxes              /= numberOfGoodSolutions;
	sumOfIntensities                   /= numberOfGoodSolutions;
	sumOfTotalFlux                     /= numberOfGoodSolutions;
	sumOfPhotoCenterX                  /= numberOfGoodSolutions;
	sumOfPhotoCenterY                  /= numberOfGoodSolutions;
	sumOfSigmaX                        /= numberOfGoodSolutions;
	sumOfSigmaY                        /= numberOfGoodSolutions;
	sumOfSigmaXY                       /= numberOfGoodSolutions;
	sumOfSignalToNoise                 /= numberOfGoodSolutions;
	sumOfTheta                         /= numberOfGoodSolutions;
	sumOfMaximumIntensity              /= numberOfGoodSolutions;

	bestPsfParameters.setBackGroundFlux(sumOfBackGroundFluxes);
	bestPsfParameters.setIntensity(sumOfIntensities);
	bestPsfParameters.setTotalFlux(sumOfTotalFlux);
	bestPsfParameters.setPhotoCenterX(sumOfPhotoCenterX);
	bestPsfParameters.setPhotoCenterY(sumOfPhotoCenterY);
	bestPsfParameters.setSigmaX(sumOfSigmaX);
	bestPsfParameters.setSigmaY(sumOfSigmaY);
	bestPsfParameters.setSigmaXY(sumOfSigmaXY);
	bestPsfParameters.setSignalToNoiseRatio(sumOfSignalToNoise);
	bestPsfParameters.setTheta(sumOfTheta);
	bestPsfParameters.setMaximumIntensity(sumOfMaximumIntensity);

	double sumOfSquareBackGroundFluxes = 0.;
	double sumOfSquareIntensities      = 0.;
	double sumOfSquareTotalFlux        = 0.;
	double sumOfSquarePhotoCenterX     = 0.;
	double sumOfSquarePhotoCenterY     = 0.;
	double sumOfSquareSigmaX           = 0.;
	double sumOfSquareSigmaY           = 0.;
	double sumOfSquareTheta            = 0.;

	for(int index = 0; index < numberOfTestedRadius; index++) {

		if(!arrayOfPsfParameters[index].getCleaned()) {

			numberOfGoodSolutions++;
			deltaValue                   = arrayOfPsfParameters[index].getBackGroundFlux() - bestPsfParameters.getBackGroundFlux();
			sumOfSquareBackGroundFluxes += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getIntensity()      - bestPsfParameters.getIntensity();
			sumOfSquareIntensities      += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getTotalFlux()      - bestPsfParameters.getTotalFlux();
			sumOfSquareTotalFlux        += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getPhotoCenterX()   - bestPsfParameters.getPhotoCenterX();
			sumOfSquarePhotoCenterX     += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getPhotoCenterY()   - bestPsfParameters.getPhotoCenterY();
			sumOfSquarePhotoCenterY     += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getSigmaX()         - bestPsfParameters.getSigmaX();
			sumOfSquareSigmaX           += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getSigmaY()         - bestPsfParameters.getSigmaY();
			sumOfSquareSigmaY           += deltaValue * deltaValue;
			deltaValue                   = arrayOfPsfParameters[index].getTheta()          - bestPsfParameters.getTheta();
			sumOfSquareTheta            += deltaValue * deltaValue;
		}
	}

	const int numberOfGoodSolutionsMinusOne = numberOfGoodSolutions - 1;

	if(numberOfGoodSolutionsMinusOne        > 0) {

		sumOfSquareBackGroundFluxes        /= numberOfGoodSolutionsMinusOne;
		sumOfSquareIntensities             /= numberOfGoodSolutionsMinusOne;
		sumOfSquareTotalFlux               /= numberOfGoodSolutionsMinusOne;
		sumOfSquarePhotoCenterX            /= numberOfGoodSolutionsMinusOne;
		sumOfSquarePhotoCenterY            /= numberOfGoodSolutionsMinusOne;
		sumOfSquareSigmaX                  /= numberOfGoodSolutionsMinusOne;
		sumOfSquareSigmaY                  /= numberOfGoodSolutionsMinusOne;
		sumOfSquareTheta                   /= numberOfGoodSolutionsMinusOne;

		bestPsfParameters.setBackGroundFluxError(3. * sqrt(sumOfSquareBackGroundFluxes));
		bestPsfParameters.setIntensityError(3. * sqrt(sumOfSquareIntensities));
		bestPsfParameters.setTotalFluxError(3. * sqrt(sumOfSquareTotalFlux));
		bestPsfParameters.setPhotoCenterXError(3. * sqrt(sumOfSquarePhotoCenterX));
		bestPsfParameters.setPhotoCenterYError(3. * sqrt(sumOfSquarePhotoCenterY));
		bestPsfParameters.setSigmaXError(3. * sqrt(sumOfSquareSigmaX));
		bestPsfParameters.setSigmaYError(3. * sqrt(sumOfSquareSigmaY));
		bestPsfParameters.setThetaError(3. * sqrt(sumOfSquareTheta));

	} else {

		/* Set negative errors instead of 0. */
		bestPsfParameters.setBackGroundFluxError(-1.);
		bestPsfParameters.setIntensityError(-1.);
		bestPsfParameters.setTotalFluxError(-1.);
		bestPsfParameters.setPhotoCenterXError(-1.);
		bestPsfParameters.setPhotoCenterYError(-1.);
		bestPsfParameters.setSigmaXError(-1.);
		bestPsfParameters.setSigmaYError(-1.);
		bestPsfParameters.setThetaError(-1.);
	}
}


/*
 * Get the PSF parameters
 */
const PsfParameters* MoffatFixedBetaPsfFitter::getThePsfParameters() const{
	return arrayOfPsfParameters;
}

/*
 * Get the best solution
 */
const PsfParameters& MoffatFixedBetaPsfFitter::getBestPsfParameters() const {
	return bestPsfParameters;
}

/**
 *  Decode the fit coefficients (beta = -1)
 */
void MoffatFixedBetaPsfFitter::setIntialSolution() {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	const double sqrtOfTwo                    = sqrt(2.);
	initialSolutionParameters[SIGMA_X_INDEX] *= sqrtOfTwo;
	initialSolutionParameters[SIGMA_Y_INDEX] *= sqrtOfTwo;

	thePsfParameters.setPhotoCenterX(initialSolutionParameters[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterY(initialSolutionParameters[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setSigmaX(initialSolutionParameters[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaY(initialSolutionParameters[SIGMA_Y_INDEX]);
	thePsfParameters.setTheta(initialSolutionParameters[THETA_INDEX]);

	/* Find the scaleFactor and backGroundFlux which minimise the chi square */
	double scaleFactor;
	double backGroundFlux;

	fillNonLinearTerms(initialSolutionParameters);
	deduceLinearParameters(scaleFactor, backGroundFlux);

	if(scaleFactor <= 0.) {
		thePsfParameters.setIntensity(initialSolutionParameters[SCALE_FACTOR_INDEX]);
	} else {
		thePsfParameters.setIntensity(scaleFactor);
	}

	if(backGroundFlux < 0.) {
		thePsfParameters.setBackGroundFlux(0.);
	} else {
		thePsfParameters.setBackGroundFlux(backGroundFlux);
	}

	if(DEBUG) {
		printf("MOFFAT Beta = %.1f PSF preliminary solution :\n",theBetaPower);
		printf("Number of pixels = %d\n",numberOfPixelsOneRadius);
		printf("Background flux  = %.3f\n",thePsfParameters.getBackGroundFlux());
		printf("Scale factor     = %.3f\n",thePsfParameters.getIntensity());
		printf("PhotocenterX     = %.3f\n",thePsfParameters.getPhotoCenterX());
		printf("PhotocenterY     = %.3f\n",thePsfParameters.getPhotoCenterY());
		printf("Theta            = %.3f degrees\n",thePsfParameters.getTheta() * 180. / M_PI);
		printf("SigmaX           = %.3f\n",thePsfParameters.getSigmaX());
		printf("SigmaY           = %.3f\n",thePsfParameters.getSigmaY());
	}
}

void MoffatFixedBetaPsfFitter::fillNonLinearTerms(const double* const arrayOfParameters) {

	const double cosTheta     = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTheta     = sin(arrayOfParameters[THETA_INDEX]);
	const double squareSigmaX = arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX];
	const double squareSigmaY = arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX];
	double xCentered;
	double yCentered;
	double xCenteredAndRotated;
	double yCenteredAndRotated;
	double polynomialTerm;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		computeCenteredAndRotatedCoordinates(xPixels[pixel], yPixels[pixel], arrayOfParameters[PHOTOCENTER_X_INDEX], arrayOfParameters[PHOTOCENTER_Y_INDEX],
				cosTheta, sinTheta, xCentered, yCentered, xCenteredAndRotated, yCenteredAndRotated);

		polynomialTerm        = 1. + xCenteredAndRotated * xCenteredAndRotated / squareSigmaX + yCenteredAndRotated * yCenteredAndRotated / squareSigmaY;

		// The fitted flux can not be positive because we insure at every iteration that BACKGROUND_FLUX > 0. and SCALE_FACTOR > 0.
		nonLinearTerms[pixel] = exp(theBetaPower * log(polynomialTerm));
	}
}

/**
 * Fill the array of parameters for the Levenberg-Marquardt minimisation
 */
void MoffatFixedBetaPsfFitter::fillArrayOfParameters(double* const arrayOfParameters) {

	PsfParameters& thePsfParameters          = arrayOfPsfParameters[indexOfRadius];

	arrayOfParameters[BACKGROUND_FLUX_INDEX] = thePsfParameters.getBackGroundFlux();
	arrayOfParameters[SCALE_FACTOR_INDEX]    = thePsfParameters.getIntensity();
	arrayOfParameters[PHOTOCENTER_X_INDEX]   = thePsfParameters.getPhotoCenterX();
	arrayOfParameters[PHOTOCENTER_Y_INDEX]   = thePsfParameters.getPhotoCenterY();
	arrayOfParameters[THETA_INDEX]           = thePsfParameters.getTheta();
	arrayOfParameters[SIGMA_X_INDEX]         = thePsfParameters.getSigmaX();
	arrayOfParameters[SIGMA_Y_INDEX]         = thePsfParameters.getSigmaY();
}

/**
 * Fill the weighted design matrix for the Levenberg-Marquardt minimisation
 */
void MoffatFixedBetaPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters) {

	const double cosTheta                  = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTheta                  = sin(arrayOfParameters[THETA_INDEX]);
	const double sigmaX                    = arrayOfParameters[SIGMA_X_INDEX];
	const double sigmaY                    = arrayOfParameters[SIGMA_Y_INDEX];
	const double squareCosTheta            = cosTheta * cosTheta;
	const double squareSinTheta            = sinTheta * sinTheta;
	const double sinTwoTheta               = 2. * sinTheta * cosTheta;
	const double cosTwoTheta               = cosTheta * cosTheta - sinTheta * sinTheta;
	const double squareSigmaX              = sigmaX * sigmaX;
	const double squareSigmaY              = sigmaY * sigmaY;
	const double diffOfInverseSquareSigmas = 1. / squareSigmaX - 1. / squareSigmaY;

	double xCentered;
	double yCentered;
	double xCenteredAndRotated;
	double yCenteredAndRotated;
	double xReduced;
	double yReduced;
	double subDerivative;
	double subDerivative1;
	double subDerivative2;
	double polynomialTerm;
	double polynomialTermPowerBetaMinusOne;
	double polynomialTermPowerBeta;
	double betaPolynomialTermPowerBetaMinusOne;
	double scaledBetaPolynomialTermPowerBetaMinusOneByError;

	for (int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		computeCenteredAndRotatedCoordinates(xPixels[pixel], yPixels[pixel], arrayOfParameters[PHOTOCENTER_X_INDEX], arrayOfParameters[PHOTOCENTER_Y_INDEX],
				cosTheta, sinTheta, xCentered, yCentered, xCenteredAndRotated, yCenteredAndRotated);

		xReduced                                          = xCenteredAndRotated / arrayOfParameters[SIGMA_X_INDEX];
		yReduced                                          = yCenteredAndRotated / arrayOfParameters[SIGMA_Y_INDEX];
		polynomialTerm                                    = 1. + xReduced * xReduced + yReduced * yReduced;
		polynomialTermPowerBeta                           = exp(theBetaPower * log(polynomialTerm));
		polynomialTermPowerBetaMinusOne                   = polynomialTermPowerBeta / polynomialTerm;

		betaPolynomialTermPowerBetaMinusOne               = theBetaPower * polynomialTermPowerBetaMinusOne;
		scaledBetaPolynomialTermPowerBetaMinusOneByError  = arrayOfParameters[SCALE_FACTOR_INDEX] * betaPolynomialTermPowerBetaMinusOne / fluxErrors[pixel];

		// Derivative with respect to the background flux is always one
		weightedDesignMatrix[BACKGROUND_FLUX_INDEX][pixel] = 1. / fluxErrors[pixel];

		// Derivative with respect to the scale
		weightedDesignMatrix[SCALE_FACTOR_INDEX][pixel]    = polynomialTermPowerBeta / fluxErrors[pixel];

		// Derivative with respect to x0
		subDerivative1                                    = - 2. * xCentered * (squareCosTheta / squareSigmaX + squareSinTheta / squareSigmaY);
		subDerivative2                                    = - sinTwoTheta * yCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[PHOTOCENTER_X_INDEX][pixel]   = scaledBetaPolynomialTermPowerBetaMinusOneByError * (subDerivative1 + subDerivative2);

		// Derivative with respect to y0
		subDerivative1                                    = - 2. * yCentered * (squareSinTheta / squareSigmaX + squareCosTheta / squareSigmaY);
		subDerivative2                                    = - sinTwoTheta * xCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[PHOTOCENTER_Y_INDEX][pixel]   = scaledBetaPolynomialTermPowerBetaMinusOneByError * (subDerivative1 + subDerivative2);

		// Derivative with respect to theta
		subDerivative1                                    = -2. * sinTwoTheta * diffOfInverseSquareSigmas * (xCentered * xCentered - yCentered * yCentered);
		subDerivative2                                    = 2. * cosTwoTheta * xCentered * yCentered * diffOfInverseSquareSigmas;
		weightedDesignMatrix[THETA_INDEX][pixel]           = scaledBetaPolynomialTermPowerBetaMinusOneByError * (subDerivative1 + subDerivative2);

		// Derivative with respect to sigmaX
		subDerivative                                     = -2 * xReduced * xReduced / sigmaX;
		weightedDesignMatrix[SIGMA_X_INDEX][pixel]         = scaledBetaPolynomialTermPowerBetaMinusOneByError * subDerivative;

		// Derivative with respect to sigmaY
		subDerivative                                     = -2 * yReduced * yReduced / sigmaY;
		weightedDesignMatrix[SIGMA_Y_INDEX][pixel]         = scaledBetaPolynomialTermPowerBetaMinusOneByError * subDerivative;
	}
}

/**
 * Copy arrayOfParameters in thePsfParameters
 */
void MoffatFixedBetaPsfFitter::copyParamtersInTheSolution(const double* const arrayOfParameters, const int radius, const double readOutNoise, const double positionThreshold, bool& doesDiverge) {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setBackGroundFlux(arrayOfParameters[BACKGROUND_FLUX_INDEX]);
	thePsfParameters.setIntensity(arrayOfParameters[SCALE_FACTOR_INDEX]);
	thePsfParameters.setPhotoCenterX(arrayOfParameters[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterY(arrayOfParameters[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setTheta(arrayOfParameters[THETA_INDEX]);
	thePsfParameters.setSigmaX(arrayOfParameters[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaY(arrayOfParameters[SIGMA_Y_INDEX]);
	thePsfParameters.setSigmaXY(sqrt((arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX] +
			arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX]) / 2.));

	/* We integrate the Moffat profile from -inf to +inf*/
	const double theTotalFlux  = -arrayOfParameters[SCALE_FACTOR_INDEX] * M_PI * arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_Y_INDEX] / (1. + theBetaPower);
	thePsfParameters.setTotalFlux(theTotalFlux);
	const double signalToNoise = theTotalFlux / sqrt(theTotalFlux + radius * (readOutNoise * readOutNoise * arrayOfParameters[BACKGROUND_FLUX_INDEX]));
	thePsfParameters.setSignalToNoiseRatio(signalToNoise);

	if((fabs(thePsfParameters.getPhotoCenterX()) > positionThreshold) || (fabs(thePsfParameters.getPhotoCenterY()) > positionThreshold)) {
		doesDiverge = true;
	}
	thePsfParameters.setDoesDiverge(doesDiverge);

	if(DEBUG) {
		printf("MOFFAT (beta = %f) PSF current best refined solution :\n",theBetaPower);
		printf("Background flux  = %.3f\n",thePsfParameters.getBackGroundFlux());
		printf("Scale factor     = %.3f\n",thePsfParameters.getIntensity());
		printf("PhotocenterX     = %.3f\n",thePsfParameters.getPhotoCenterX());
		printf("PhotocenterY     = %.3f\n",thePsfParameters.getPhotoCenterY());
		printf("Theta            = %.3f degrees\n",thePsfParameters.getTheta() * 180. / M_PI);
		printf("SigmaX           = %.3f\n",thePsfParameters.getSigmaX());
		printf("SigmaY           = %.3f\n",thePsfParameters.getSigmaY());
		printf("SigmaXY          = %.3f\n",thePsfParameters.getSigmaXY());
		printf("Total flux       = %.3f\n",thePsfParameters.getTotalFlux());
		printf("Signal to noise  = %.3f\n",thePsfParameters.getSignalToNoiseRatio());
		printf("doesDiverge      = %df\n",thePsfParameters.getDoesDiverge());
	}
}

/**
 * Copy arrayOfParameterErrors in thePsfParameters
 */
void MoffatFixedBetaPsfFitter::setErrorsInTheSolution(const double* const arrayOfParameterErrors, const bool doesDiverge) {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setDoesDiverge(doesDiverge);
	thePsfParameters.setBackGroundFluxError(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX]);
	thePsfParameters.setIntensityError(arrayOfParameterErrors[SCALE_FACTOR_INDEX]);
	thePsfParameters.setPhotoCenterXError(arrayOfParameterErrors[PHOTOCENTER_X_INDEX]);
	thePsfParameters.setPhotoCenterYError(arrayOfParameterErrors[PHOTOCENTER_Y_INDEX]);
	thePsfParameters.setThetaError(arrayOfParameterErrors[THETA_INDEX]);
	thePsfParameters.setSigmaXError(arrayOfParameterErrors[SIGMA_X_INDEX]);
	thePsfParameters.setSigmaYError(arrayOfParameterErrors[SIGMA_Y_INDEX]);

	const double squareScaleFactor = thePsfParameters.getIntensity() * thePsfParameters.getIntensity();
	const double squareSigmaX      = thePsfParameters.getSigmaX() * thePsfParameters.getSigmaX();
	const double squareSigmaY      = thePsfParameters.getSigmaY() * thePsfParameters.getSigmaY();
	const double theTotalFluxError = -M_PI / (1 + theBetaPower) *
			sqrt(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX] * arrayOfParameterErrors[BACKGROUND_FLUX_INDEX] * squareSigmaX * squareSigmaY +
					squareScaleFactor * arrayOfParameterErrors[SIGMA_X_INDEX] * arrayOfParameterErrors[SIGMA_X_INDEX] * squareSigmaY +
					squareScaleFactor * squareSigmaX * arrayOfParameterErrors[SIGMA_Y_INDEX] * arrayOfParameterErrors[SIGMA_Y_INDEX]);
	thePsfParameters.setTotalFluxError(theTotalFluxError);
}

/**
 * Add the initial shifts to the photo-center
 */
void MoffatFixedBetaPsfFitter::updatePhotocenter(const int xCenter, const int yCenter) {

	PsfParameters& thePsfParameters = arrayOfPsfParameters[indexOfRadius];

	thePsfParameters.setPhotoCenterX(thePsfParameters.getPhotoCenterX() + xCenter);
	thePsfParameters.setPhotoCenterY(thePsfParameters.getPhotoCenterY() + yCenter);
}

void MoffatFixedBetaPsfFitter::setHighestIntensityInWindow() {

	arrayOfPsfParameters[indexOfRadius].setMaximumIntensity(highestIntensityInWindow);
}

/**
 * Class constructor
 */
PsfParameters::PsfParameters() {

	doesDiverge         = true;
	radius              = -1;
	backGroundFlux      = -1.;
	backGroundFluxError = -1.;
	intensity           = -1.;
	intensityError      = -1.;
	photoCenterX        = NAN;
	photoCenterXError   = -1.;
	photoCenterY        = NAN;
	photoCenterYError   = -1.;
	sigmaX              = -1.;
	sigmaXError         = -1.;
	sigmaY              = -1.;
	sigmaYError         = -1.;
	sigmaXY             = -1.;
	theta               = NAN;
	thetaError          = -1.;
	totalFlux           = -1.;
	totalFluxError      = -1.;
	maximumIntensity    = -1.;
	signalToNoiseRatio  = -1.;
	cleaned             = false;
}

/**
 * Class destructor
 */
PsfParameters::~PsfParameters() {}

bool PsfParameters::getDoesDiverge() const {
	return doesDiverge;
}

void PsfParameters::setDoesDiverge(const bool inputDoesDiverge) {
	doesDiverge = inputDoesDiverge;
}

bool PsfParameters::getCleaned() const {
	return cleaned;
}

void PsfParameters::setCleaned(const bool inputCleaned) {
	cleaned = inputCleaned;
}

double PsfParameters::getBackGroundFlux() const {
	return backGroundFlux;
}

void PsfParameters::setBackGroundFlux(const double inputBackGroundFlux) {
	backGroundFlux = inputBackGroundFlux;
}

double PsfParameters::getIntensity() const {
	return intensity;

}

void PsfParameters::setIntensity(const double inputIntensity) {
	intensity = inputIntensity;
}

double PsfParameters::getIntensityError() const {
	return intensityError;

}

void PsfParameters::setIntensityError(const double inputIntensityError) {
	intensityError = inputIntensityError;
}

double PsfParameters::getBackGroundFluxError() const {
	return backGroundFluxError;
}

void PsfParameters::setBackGroundFluxError(const double inputBackGroundFluxError) {
	backGroundFluxError = inputBackGroundFluxError;
}

double PsfParameters::getPhotoCenterX() const {
	return photoCenterX;
}

void PsfParameters::setPhotoCenterX(const double inputPhotoCenterX) {
	photoCenterX = inputPhotoCenterX;
}

double PsfParameters::getPhotoCenterXError() const {
	return photoCenterXError;
}

void PsfParameters::setPhotoCenterXError(const double inputPhotoCenterXError) {
	photoCenterXError = inputPhotoCenterXError;
}

double PsfParameters::getPhotoCenterY() const {
	return photoCenterY;
}

void PsfParameters::setPhotoCenterY(const double inputPhotoCenterY) {
	photoCenterY = inputPhotoCenterY;
}

double PsfParameters::getPhotoCenterYError() const {
	return photoCenterYError;
}

void PsfParameters::setPhotoCenterYError(const double inputPhotoCenterYError) {
	photoCenterYError = inputPhotoCenterYError;
}

double PsfParameters::getSigmaX() const {
	return sigmaX;
}

void PsfParameters::setSigmaX(const double inputSigmaX) {
	sigmaX = inputSigmaX;
}

double PsfParameters::getSigmaXError() const {
	return sigmaXError;
}

void PsfParameters::setSigmaXError(const double inputSigmaXError) {
	sigmaXError = inputSigmaXError;
}

double PsfParameters::getSigmaY() const {
	return sigmaY;
}

void PsfParameters::setSigmaY(const double inputSigmaY) {
	sigmaY = inputSigmaY;
}

double PsfParameters::getSigmaYError() const {
	return sigmaYError;
}

void PsfParameters::setSigmaYError(const double inputSigmaYError) {
	sigmaYError = inputSigmaYError;
}

double PsfParameters::getSigmaXY() const {
	return sigmaXY;
}

void PsfParameters::setSigmaXY(const double inputSigmaXY) {
	sigmaXY = inputSigmaXY;
}

double PsfParameters::getTheta() const {
	return theta;
}

void PsfParameters::setTheta(const double inputTheta) {
	theta = inputTheta;
}

double PsfParameters::getThetaError() const {
	return thetaError;
}

void PsfParameters::setThetaError(const double inputThetaError) {
	thetaError = inputThetaError;
}

double PsfParameters::getMaximumIntensity() const {
	return maximumIntensity;
}

void PsfParameters::setMaximumIntensity(const double inputMaximumIntensity) {
	maximumIntensity = inputMaximumIntensity;
}

double PsfParameters::getSignalToNoiseRatio() const {
	return signalToNoiseRatio;
}

void PsfParameters::setSignalToNoiseRatio(const double inputSignalToNoiseRatio) {
	signalToNoiseRatio = inputSignalToNoiseRatio;
}

double PsfParameters::getTotalFlux() const {
	return totalFlux;
}

void PsfParameters::setTotalFlux(const double inputTotalFlux) {
	totalFlux = inputTotalFlux;
}

double PsfParameters::getTotalFluxError() const {
	return totalFluxError;
}

void PsfParameters::setTotalFluxError(const double inputTotalFluxError) {
	totalFluxError = inputTotalFluxError;
}

int PsfParameters::getRadius() const {
	return radius;
}

void PsfParameters::setRadius(const int inputRadius) {
	radius = inputRadius;
}

void PsfParameters::copyParameters(const PsfParameters& anOtherParameters) {

	doesDiverge         = anOtherParameters.doesDiverge;
	radius              = anOtherParameters.radius;
	backGroundFlux      = anOtherParameters.backGroundFlux;
	backGroundFluxError = anOtherParameters.backGroundFluxError;
	intensity           = anOtherParameters.intensity;
	intensityError      = anOtherParameters.intensityError;
	photoCenterX        = anOtherParameters.photoCenterX;
	photoCenterXError   = anOtherParameters.photoCenterXError;
	photoCenterY        = anOtherParameters.photoCenterY;
	photoCenterYError   = anOtherParameters.photoCenterYError;
	theta               = anOtherParameters.theta;
	thetaError          = anOtherParameters.thetaError;
	sigmaX              = anOtherParameters.sigmaX;
	sigmaXError         = anOtherParameters.sigmaXError;
	sigmaY              = anOtherParameters.sigmaY;
	sigmaYError         = anOtherParameters.sigmaYError;
	sigmaXY             = anOtherParameters.sigmaXY;
	totalFlux           = anOtherParameters.totalFlux;
	totalFluxError      = anOtherParameters.totalFluxError;
	maximumIntensity    = anOtherParameters.maximumIntensity;
	signalToNoiseRatio  = anOtherParameters.signalToNoiseRatio;
	cleaned             = anOtherParameters.cleaned;
}

/**
 * Class constructor
 */
MoffatPsfParameters::MoffatPsfParameters() {

	super();
	beta      = NAN;
	betaError = -1.;
}

void MoffatPsfParameters::copyParameters(const MoffatPsfParameters& anOtherParameters) {

	super::copyParameters(anOtherParameters);
	beta      = anOtherParameters.beta;
	betaError = anOtherParameters.betaError;
}

/**
 * Class destructor
 */
MoffatPsfParameters::~MoffatPsfParameters() {}

double MoffatPsfParameters::getBeta() const {
	return beta;
}

void MoffatPsfParameters::setBeta(const double inputBeta) {
	beta = inputBeta;
}

double MoffatPsfParameters::getBetaError() const {
	return betaError;
}

void MoffatPsfParameters::setBetaError(const double inputBetaError) {
	betaError = inputBetaError;
}

/**
 * Find the maximum of an array
 */
double findMaximum(const double* const arrayOfDoubles, const int lengthOfArray) {

	double theMaximum = arrayOfDoubles[0];

	for(int index = 1; index < lengthOfArray; index++) {

		if(theMaximum  < arrayOfDoubles[index]) {
			theMaximum = arrayOfDoubles[index];
		}
	}

	return theMaximum;
}

void computeCenteredAndRotatedCoordinates(const double x, const double y, const double x0, const double y0, const double cosTheta, const double sinTheta,
		double& xCentered, double& yCentered, double& xCenteredAndRotated, double& yCenteredAndRotated) {

	xCentered           = x - x0;
	yCentered           = y - y0;

	xCenteredAndRotated = cosTheta * xCentered + sinTheta * yCentered;
	yCenteredAndRotated = -sinTheta * xCentered + cosTheta * yCentered;
}

int compareBackGroundsAscending (const void * a, const void * b) {

	if ((*(indexedParameters*)a).backGroundFlux < (*(indexedParameters*)b).backGroundFlux) {

		return -1;

	} else if ((*(indexedParameters*)a).backGroundFlux == (*(indexedParameters*)b).backGroundFlux) {

		return 0;

	} else {

		return 1;
	}
}

int compareBackGroundsDescending (const void * a, const void * b) {

	if ((*(indexedParameters*)a).backGroundFlux < (*(indexedParameters*)b).backGroundFlux) {

		return 1;

	} else if ((*(indexedParameters*)a).backGroundFlux == (*(indexedParameters*)b).backGroundFlux) {

		return 0;

	} else {

		return -1;
	}
}

int comparePhotocenterXDescending (const void * a, const void * b) {

	if ((*(indexedParameters*)a).photocenterX < (*(indexedParameters*)b).photocenterX) {

		return 1;

	} else if ((*(indexedParameters*)a).photocenterX == (*(indexedParameters*)b).photocenterX) {

		return 0;

	} else {

		return -1;
	}
}

int comparePhotocenterYDescending (const void * a, const void * b) {

	if ((*(indexedParameters*)a).photocenterY < (*(indexedParameters*)b).photocenterY) {

		return 1;

	} else if ((*(indexedParameters*)a).photocenterY == (*(indexedParameters*)b).photocenterY) {

		return 0;

	} else {

		return -1;
	}
}

int compareFluxDescending (const void * a, const void * b) {

	if ((*(indexedParameters*)a).totalFlux < (*(indexedParameters*)b).totalFlux) {

		return 1;

	} else if ((*(indexedParameters*)a).totalFlux == (*(indexedParameters*)b).totalFlux) {

		return 0;

	} else {

		return -1;
	}
}

int compareFluxAscending (const void * a, const void * b) {

	if ((*(indexedParameters*)a).totalFlux < (*(indexedParameters*)b).totalFlux) {

		return -1;

	} else if ((*(indexedParameters*)a).totalFlux == (*(indexedParameters*)b).totalFlux) {

		return 0;

	} else {

		return +1;
	}
}

void computeMeans(indexedParameters* const arrayOfIndexedParameters, const int length, double& theMeanOfBackGrounds, double& theMeanOfPhotocenterX,
		double& theMeanOfPhotocenterY, double& theMeanOfTotalFlux) {

	double theSumOfBackGroundFlux  = 0.;
	double theSumOfPhotocenterX    = 0.;
	double theSumOfPhotocenterY    = 0.;
	double theSumOfTotalFlux       = 0.;

	for(int index = 0; index < length; index++) {
		theSumOfBackGroundFlux    += arrayOfIndexedParameters[index].backGroundFlux;
		theSumOfPhotocenterX      += arrayOfIndexedParameters[index].photocenterX;
		theSumOfPhotocenterY      += arrayOfIndexedParameters[index].photocenterY;
		theSumOfTotalFlux         += arrayOfIndexedParameters[index].totalFlux;
	}

	theMeanOfBackGrounds           = theSumOfBackGroundFlux / length;
	theMeanOfPhotocenterX          = theSumOfPhotocenterX / length;
	theMeanOfPhotocenterY          = theSumOfPhotocenterY / length;
	theMeanOfTotalFlux             = theSumOfTotalFlux / length;
}

void computeMeanAndSigma(indexedParameters* const arrayOfIndexedParameters, const int length, double& theMeanOfBackGrounds, double& theSigmaOfBackGrounds) {

	double theSumOfBackGroundFlux        = 0.;
	double theSumOfSquaresBackGroundFlux = 0.;

	for(int index = 0; index < length; index++) {
		theSumOfBackGroundFlux        += arrayOfIndexedParameters[index].backGroundFlux;
		theSumOfSquaresBackGroundFlux += arrayOfIndexedParameters[index].backGroundFlux * arrayOfIndexedParameters[index].backGroundFlux;
	}

	const int lengthMinusOne            = length - 1;
	const double lengthByLengthMinusOne = (double)length / lengthMinusOne;
	theMeanOfBackGrounds                = theSumOfBackGroundFlux / length;
	theSumOfSquaresBackGroundFlux      /= lengthMinusOne;
	theSigmaOfBackGrounds               = sqrt(theSumOfSquaresBackGroundFlux - theMeanOfBackGrounds * theMeanOfBackGrounds * lengthByLengthMinusOne);
}
