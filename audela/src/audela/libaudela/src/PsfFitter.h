/**
 * Header file for profile fitting methods
 *
 * Author : Yassine Damerdji
 */

#ifndef __PSFFITTERH__
#define __PSFFITTERH__

#include "MinimisationAndLinearAlgebraicSystems.h"
#include "cbuffer.h"

#define GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS 7
#define GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION 6
#define MOFFAT_PROFILE_NUMBER_OF_PARAMETERS 8
#define MOFFAT_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION 6
#define MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS 7
#define MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION 6

/**
 * Parent class for PSF parameters (container class)
 */
class PsfParameters {

protected:
	bool   doesDiverge;
	int    radius;
	double backGroundFlux;
	double backGroundFluxError;
	double intensity;
	double intensityError;
	double photoCenterX;
	double photoCenterXError;
	double photoCenterY;
	double photoCenterYError;
	double theta;
	double thetaError;
	double sigmaX;
	double sigmaXError;
	double sigmaY;
	double sigmaYError;
	double sigmaXY;
	double totalFlux;
	double totalFluxError;
	double maximumIntensity;
	double signalToNoiseRatio;
	bool   cleaned;

public:
	PsfParameters();
	virtual ~PsfParameters();
	double getBackGroundFlux() const;
	void setBackGroundFlux(const double backGroundFlux);
	double getIntensity() const;
	void setIntensity(const double intensity);
	double getIntensityError() const;
	void setIntensityError(const double scaleFactorError);
	double getBackGroundFluxError() const;
	void setBackGroundFluxError(const double backGroundFluxError);
	double getPhotoCenterX() const;
	void setPhotoCenterX(const double photoCenterX);
	double getPhotoCenterXError() const;
	void setPhotoCenterXError(const double photoCenterXError);
	double getPhotoCenterY() const;
	void setPhotoCenterY(const double photoCenterY);
	double getPhotoCenterYError() const;
	void setPhotoCenterYError(const double photoCenterYError);
	double getSigmaX() const;
	void setSigmaX(const double sigmaX);
	double getSigmaXError() const;
	void setSigmaXError(const double sigmaXError);
	double getSigmaY() const;
	void setSigmaY(const double sigmaY);
	double getSigmaYError() const;
	void setSigmaYError(const double sigmaYError);
	double getSigmaXY() const;
	void setSigmaXY(const double sigmaXY);
	double getTheta() const;
	void setTheta(const double theta);
	double getThetaError() const;
	void setThetaError(const double thetaError);
	int getRadius() const;
	void setRadius(const int radius);
	bool getDoesDiverge() const;
	void setDoesDiverge(const bool doesDiverge);
	double getMaximumIntensity() const;
	void setMaximumIntensity(const double maximumIntensity);
	double getSignalToNoiseRatio() const;
	void setSignalToNoiseRatio(const double signalToNoiseRatio);
	double getTotalFlux() const;
	void setTotalFlux(const double totalFlux);
	double getTotalFluxError() const;
	void setTotalFluxError(const double totalFluxError);
	bool getCleaned() const;
	void setCleaned(const bool inputCleaned);
	void copyParameters(const PsfParameters& anOtherParameters);
};

/**
 * Container class for Moffat PSF parameters
 */
class MoffatPsfParameters : public PsfParameters {

private:
	typedef PsfParameters super;
	double beta;
	double betaError;

public:
	MoffatPsfParameters();
	virtual ~MoffatPsfParameters();
	double getBeta() const;
	void setBeta(const double beta);
	double getBetaError() const;
	void setBetaError(const double betaError);
	void copyParameters(const MoffatPsfParameters& anOtherParameters);
};

typedef struct {
	int index;
	double backGroundFlux;
	double photocenterX;
	double photocenterY;
	double totalFlux;
} indexedParameters;

/**
 * Parent class for fitting different kind of profiles
 */
class PsfFitter : public LinearAlgebraicSystemInterface,NonLinearAlgebraicSystemInterface {

private:
	int numberOfParameterFit;
	int numberOfParameterFitPreliminarySolution;
	LinearAlgebraicSystemSolver* theLinearAlgebraicSystemSolver;
	LevenbergMarquardtSystemSolver* theLevenbergMarquardtSystemSolver;
	int findBestRadiusAndFlagBadSolutions(const double confidenceLevel);

protected:
	static const double TWO_PI;
	static const int BACKGROUND_FLUX_INDEX;
	static const int SCALE_FACTOR_INDEX;
	static const int PHOTOCENTER_X_INDEX;
	static const int PHOTOCENTER_Y_INDEX;
	static const int THETA_INDEX;
	static const int SIGMA_X_INDEX;
	static const int SIGMA_Y_INDEX;
	static const double HOW_MANY_SIGMAS;
	char    logMessage[1024];
	int     numberOfTestedRadius;
	int     indexOfRadius;
	int     numberOfPixelsMaximumRadius;
	int     numberOfPixelsOneRadius;
	double  sumOfWeights;
	int*    xPixelsMaximumRadius;
	int*    yPixelsMaximumRadius;
	double* fluxesMaximumRadius;
	double* fluxErrorsMaximumRadius;
	bool*   isUsedFlags;
	int*    xPixels;
	int*    yPixels;
	double* fluxes;
	double* fluxErrors;
	double* weights;
	double* nonLinearTerms;
	double* transformedFluxes;
	double* transformedFluxErrors;
	double* initialSolutionParameters;
	double  highestIntensityInWindow;

	void transformFluxesForPreliminarySolution(const double theBackGroundFlux);
	void extractProcessingZoneMaximumRadius(CBuffer* const theBufferImage, double& xCenter, double& yCenter, const int theRadius,
			double readOutNoise, const bool pureGaussianStatistics, const bool searchAround);
	void extractProcessingZone(const int theRadius, const double saturationLimit);
	double fitProfilePerRadius(bool& doesDiverge);
	void findInitialSolution();
	double refineSolution(bool& doesDiverge);
	void decodeFitCoefficients(const double* const fitCoefficients);
	void deduceLinearParameters(double& scaleFactor, double& backGroundFlux);
	double findMinimumOfFluxes();
	void correctTheta(double& theta);
	void computeTotalFlux(PsfParameters& thePsfParameters, const double sigmaFactor);
	void computeTotalFluxError(PsfParameters& thePsfParameters, const double sigmaFactor);

	virtual void allocateArrayOfOutputParameters() = 0;
	virtual void fillNonLinearTerms(const double* const arrayOfParameters) = 0;
	virtual void setIntialSolution() = 0;
	virtual void copyParamtersInTheSolution(const double* const arrayOfParameters, const int radius, const double readOutNoise, const double positionThreshold, bool& doesDiverge) = 0;
	virtual void setErrorsInTheSolution(const double* const arrayOfParameterErrors, const bool doesDiverge) = 0;
	virtual void updatePhotocenter(const int xCenter, const int yCenter) = 0;
	virtual void setHighestIntensityInWindow() = 0;
	virtual void setRadius(const int radius) = 0;
	virtual int fillArrayOfBackGrounds(indexedParameters* const arrayOfRestrictedParameter) = 0;
	virtual int fillParameters(indexedParameters* const arrayOfRestrictedParameter, const double backGroundFluxThreshold) = 0;
	virtual int cleanSolution(const int index) = 0;
	virtual int cleanBadRadii() = 0;
	virtual void copySolutionParameters(const int indexOfSolution) = 0;
	virtual void fillBestSolution() = 0;

public:
	PsfFitter(const int inputNumberOfParameterFit,const int inputNumberOfParameterFitPreliminarySolution);
	virtual ~PsfFitter();
	void fitProfile(CBuffer* const theBufferImage, double xCenter, double yCenter, const int minimumRadius, const int maximumRadius,
			const double saturationLimit, const double readOutNoise,const double positionThreshold,const int numberOfSuccessiveErrors,
			const double confidenceLevel, const bool pureGaussianStatistics, const bool searchAround);
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix);
	int getNumberOfMeasurements();
	void fillWeightedObservations(double* const weightedObservartions);
	void fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters, double& chiSquare);
	void checkArrayOfParameters(double* const arrayOfParameters);
};

/**
 * Class for fitting a 2D gaussian profile
 */
class Gaussian2DPsfFitter : public PsfFitter {

private:
	PsfParameters* arrayOfPsfParameters;
	PsfParameters bestPsfParameters;

protected:
	void setIntialSolution();
	void copyParamtersInTheSolution(const double* const arrayOfParameters, const int radius, const double readOutNoise, const double positionThreshold, bool& doesDiverge);
	void fillNonLinearTerms(const double* const arrayOfParameters);
	void setErrorsInTheSolution(const double* const arrayOfParameterErrors, const bool doesDiverge);
	void updatePhotocenter(const int xCenter, const int yCenter);
	void allocateArrayOfOutputParameters();
	void setHighestIntensityInWindow();
	void setRadius(const int radius);
	int fillArrayOfBackGrounds(indexedParameters* const arrayOfRestrictedParameter);
	int fillParameters(indexedParameters* const arrayOfRestrictedParameter, const double backGroundFluxThreshold);
	int cleanSolution(const int index);
	int cleanBadRadii();
	void copySolutionParameters(const int indexOfSolution);
	void fillBestSolution();

public:
	Gaussian2DPsfFitter();
	virtual ~Gaussian2DPsfFitter();
	const PsfParameters* getThePsfParameters() const;
	const PsfParameters& getBestPsfParameters() const;
	void fillArrayOfParameters(double* const arrayOfParameters);
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters);
};

/**
 * Class for fitting a Moffat non radial profile
 */
class MoffatPsfFitter : public PsfFitter {

private:
	static const int BETA_INDEX;
	static const double LOWER_LIMIT_BETA;
	MoffatPsfParameters* arrayOfPsfParameters;
	MoffatPsfParameters bestPsfParameters;
	void deduceBestBeta();

protected:
	void setIntialSolution();
	void fillNonLinearTerms(const double* const arrayOfParameters);
	void copyParamtersInTheSolution(const double* const arrayOfParameters, const int radius, const double readOutNoise, const double positionThreshold, bool& doesDiverge);
	void setErrorsInTheSolution(const double* const arrayOfParameterErrors, const bool doesDiverge);
	void updatePhotocenter(const int xCenter, const int yCenter);
	void allocateArrayOfOutputParameters();
	void setHighestIntensityInWindow();
	void setRadius(const int radius);
	int fillArrayOfBackGrounds(indexedParameters* const arrayOfRestrictedParameter);
	int fillParameters(indexedParameters* const arrayOfRestrictedParameter, const double backGroundFluxThreshold);
	int cleanSolution(const int index);
	int cleanBadRadii();
	void copySolutionParameters(const int indexOfSolution);
	void fillBestSolution();

public:
	MoffatPsfFitter();
	virtual ~MoffatPsfFitter();
	const MoffatPsfParameters* getThePsfParameters() const;
	const MoffatPsfParameters& getBestPsfParameters() const;
	void fillArrayOfParameters(double* const arrayOfParameters);
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters);
	void checkArrayOfParameters(double* const arrayOfParameters);
};

/**
 * Class for fitting a Moffat non radial profile with beta = -3
 */
class MoffatFixedBetaPsfFitter : public PsfFitter {

private:
	double theBetaPower;
	PsfParameters* arrayOfPsfParameters;
	PsfParameters bestPsfParameters;

protected:
	void setIntialSolution();
	void fillNonLinearTerms(const double* const arrayOfParameters);
	void copyParamtersInTheSolution(const double* const arrayOfParameters, const int radius, const double readOutNoise, const double positionThreshold, bool& doesDiverge);
	void setErrorsInTheSolution(const double* const arrayOfParameterErrors, const bool doesDiverge);
	void updatePhotocenter(const int xCenter, const int yCenter);
	void allocateArrayOfOutputParameters();
	void setHighestIntensityInWindow();
	void setRadius(const int radius);
	int fillArrayOfBackGrounds(indexedParameters* const arrayOfRestrictedParameter);
	int fillParameters(indexedParameters* const arrayOfRestrictedParameter, const double backGroundFluxThreshold);
	int cleanSolution(const int index);
	int cleanBadRadii();
	void copySolutionParameters(const int indexOfSolution);
	void fillBestSolution();

public:
	MoffatFixedBetaPsfFitter(const double inputBetaPower);
	virtual ~MoffatFixedBetaPsfFitter();
	const PsfParameters* getThePsfParameters() const;
	const PsfParameters& getBestPsfParameters() const;
	void fillArrayOfParameters(double* const arrayOfParameters);
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters);
};

double findMaximum(const double* const arrayOfDoubles, const int lengthOfArray);
void computeCenteredAndRotatedCoordinates(const double x, const double y, const double x0, const double y0, const double cosTheta, const double sinTheta,
		double& xCentered, double& yCentered, double& xCenteredAndRotated, double& yCenteredAndRotated);
int compareBackGroundsAscending (const void * a, const void * b);
int compareBackGroundsDescending (const void * a, const void * b);
int comparePhotocenterXDescending (const void * a, const void * b);
int comparePhotocenterYDescending (const void * a, const void * b);
int compareFluxDescending (const void * a, const void * b);
int compareFluxAscending (const void * a, const void * b);
void computeMeanAndSigma(indexedParameters* const arrayOfIndexedParameters, const int length, double& theMeanOfBackGrounds, double& theSigmaOfBackGrounds);
void computeMeans(indexedParameters* const arrayOfIndexedParameters, const int length, double& theMeanOfBackGrounds, double& theMeanOfPhotocenterX,
		double& theMeanOfPhotocenterY, double& theMeanOfTotalFlux);

#endif // __PSFFITTERH__
