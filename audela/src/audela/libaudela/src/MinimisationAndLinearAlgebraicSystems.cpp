/**
 * Source file for Levenberg-Marquardt minimisation and linear algebraic systems
 *
 * Author : Yassine Damerdji
 */

#include "MinimisationAndLinearAlgebraicSystems.h"

/** We need 3 successive convergences to stop iterating */
const int LevenbergMarquardtSystemSolver::NUMBER_OF_NEEDED_CONVERGENCE = 3;
/** The maximum number of allowed iterations */
const int LevenbergMarquardtSystemSolver::MAXIMUM_NUMBER_OF_ITERATIONS = 1000;
/** The Marquardt scaling factor */
const double LevenbergMarquardtSystemSolver::MARQUARDT_SCALE           = 10.;
/** Needed to stop iterating */
const double LevenbergMarquardtSystemSolver::DELTA_CHI_SQUARE_LIMIT    = 1e-3;
/** Needed to stop iterating */
const double LevenbergMarquardtSystemSolver::CHI_SQUARE_TOLERENCE      = 1e-8;

/**
 * Class constructor
 */
AlgebraicSystemSolver::AlgebraicSystemSolver(const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) :
		numberOfFitParameters(inputNumberOfFitParameters),maximumNumberOfMeasurements(inputMaximumNumberOfMeasurements) {

	numberOfMeasurements  = -1;

	weightedDesignMatrix     = new double*[numberOfFitParameters];
	if(weightedDesignMatrix == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for weightedDesignMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	curvatureMatrix          = new double*[numberOfFitParameters];
	if(curvatureMatrix      == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for curvatureMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	choleskyMatrix           = new double*[numberOfFitParameters];
	if(choleskyMatrix       == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for choleskyMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	inverseOfCholeskyMatrix     = new double*[numberOfFitParameters];
	if(inverseOfCholeskyMatrix == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for inverseOfCholeskyMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		weightedDesignMatrix[kParameter]     = new double[maximumNumberOfMeasurements];
		if(weightedDesignMatrix[kParameter] == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for choleskyMatrix[%d]\n",maximumNumberOfMeasurements,kParameter);
			throw InsufficientMemoryException(logMessage);
		}

		curvatureMatrix[kParameter]          = new double[numberOfFitParameters];
		if(curvatureMatrix[kParameter]      == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for curvatureMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}

		choleskyMatrix[kParameter]           = new double[numberOfFitParameters];
		if(choleskyMatrix[kParameter]       == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for choleskyMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}

		inverseOfCholeskyMatrix[kParameter]     = new double[numberOfFitParameters];
		if(inverseOfCholeskyMatrix[kParameter] == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for inverseOfCholeskyMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}
	}

	projectedObservations     = new double[numberOfFitParameters];
	if(projectedObservations == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for projectedObservations\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	intermediateArray         = new double[numberOfFitParameters];
	if(intermediateArray     == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for intermediateArray\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	arrayOfParameters           = new double[numberOfFitParameters];
	if(arrayOfParameters       == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for fitCoefficients\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}
}

/**
 * Class destructor
 */
AlgebraicSystemSolver::~AlgebraicSystemSolver() {

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		if(weightedDesignMatrix[kParameter] != NULL) {
			delete[] weightedDesignMatrix[kParameter];
			weightedDesignMatrix[kParameter] = NULL;
		}

		if(curvatureMatrix[kParameter]      != NULL) {
			delete[] curvatureMatrix[kParameter];
			curvatureMatrix[kParameter] = NULL;
		}

		if(choleskyMatrix[kParameter]      != NULL) {
			delete[] choleskyMatrix[kParameter];
			choleskyMatrix[kParameter] = NULL;
		}

		if(inverseOfCholeskyMatrix[kParameter] != NULL) {
			delete[] inverseOfCholeskyMatrix[kParameter];
			inverseOfCholeskyMatrix[kParameter] = NULL;
		}
	}

	if(weightedDesignMatrix != NULL) {
		delete[] weightedDesignMatrix;
		weightedDesignMatrix = NULL;
	}

	if(curvatureMatrix != NULL) {
		delete[] curvatureMatrix;
		curvatureMatrix = NULL;
	}

	if(choleskyMatrix != NULL) {
		delete[] choleskyMatrix;
		choleskyMatrix = NULL;
	}

	if(inverseOfCholeskyMatrix != NULL) {
		delete[] inverseOfCholeskyMatrix;
		inverseOfCholeskyMatrix = NULL;
	}

	if(projectedObservations != NULL) {
		delete[] projectedObservations;
		projectedObservations = NULL;
	}

	if(intermediateArray != NULL) {
		delete[] intermediateArray;
		intermediateArray = NULL;
	}

	if(arrayOfParameters   != NULL) {
		delete[] arrayOfParameters;
		arrayOfParameters   = NULL;
	}
}

/**
 *  Compute the curvature matrix = transpose(weightedDesignMatrix) * weightedDesignMatrix
 */
void AlgebraicSystemSolver::computeCurvatureMatrix() {

	double theSum;

	for(int kParameter1 = 0; kParameter1 < numberOfFitParameters; kParameter1++) {
		for(int kParameter2 = kParameter1; kParameter2 < numberOfFitParameters; kParameter2++) {

			theSum      = 0.;
			for(int kMes = 0; kMes < numberOfMeasurements; kMes++) {
				theSum += weightedDesignMatrix[kParameter1][kMes] * weightedDesignMatrix[kParameter2][kMes];
			}

			curvatureMatrix[kParameter1][kParameter2] = theSum;
			/* And its symmetric */
			curvatureMatrix[kParameter2][kParameter1] = theSum;

			//printf("curvatureMatrix[%d][%d] = %f\n",kParameter1,kParameter2,curvatureMatrix[kParameter1][kParameter2]);
		}
	}
}

/**
 * Decompose the curvature matrix using Cholesky decomposition
 */
void AlgebraicSystemSolver::decomposeCurvatureMatrix(double** theCurvatureMatrix) {

	int j,k;
	double theSum,theSquare;
	double minimumOfDiagonal = 1e100;
	double maximumOfDiagonal = -1e100;

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		j = 0;
		while (j < kParameter) {

			theSum      = 0.;
			k           = 0;
			while (k    < j) {
				theSum += choleskyMatrix[kParameter][k] * choleskyMatrix[j][k];
				k++;
			}

			choleskyMatrix[kParameter][j] = (theCurvatureMatrix[kParameter][j] - theSum) / choleskyMatrix[j][j];
			j++;
		}

		theSum      = 0.;
		k           = 0;
		while (k    < kParameter) {
			theSum += choleskyMatrix[kParameter][k] * choleskyMatrix[kParameter][k];
			k++;
		}

		theSquare         = theCurvatureMatrix[kParameter][kParameter] - theSum;

		if(theSquare      > 0.) {

			choleskyMatrix[kParameter][kParameter] = sqrt(theSquare);
			isMatrixBadlyConditionned(choleskyMatrix[kParameter][kParameter],minimumOfDiagonal,maximumOfDiagonal);

		} else {
			sprintf(logMessage,"The curvature matrix is not definite positive\n");
			throw NonDefinitePositiveMatrixException(logMessage);
		}
	}
}

/**
 * Finish solving the system
 */
void AlgebraicSystemSolver::finishSolvingTheSystem(double* const theFitCoefficients) {

	int k;
	double theSum;

	// Fill intermediateSolution
	for (int indexOfRow = 0; indexOfRow < numberOfFitParameters; indexOfRow++) {

		theSum      = 0.;
		k           = 0;
		while (k    < indexOfRow) {
			theSum += choleskyMatrix[indexOfRow][k] * intermediateArray[k];
			k++;
		}

		intermediateArray[indexOfRow] = (projectedObservations[indexOfRow] - theSum) / choleskyMatrix[indexOfRow][indexOfRow];
	}

	const int lastIndex = numberOfFitParameters - 1;

	for (int indexOfRow = lastIndex; indexOfRow >= 0; indexOfRow--) {
		theSum      = 0.;
		k           = lastIndex;
		while (k    > indexOfRow) {
			theSum += choleskyMatrix[k][indexOfRow] * theFitCoefficients[k];
			k--;
		}
		theFitCoefficients[indexOfRow] = (intermediateArray[indexOfRow] - theSum) / choleskyMatrix[indexOfRow][indexOfRow];
	}
}

/**
 * Check for badly conditionned curvature matrix
 */
void AlgebraicSystemSolver::isMatrixBadlyConditionned(const double diagonalElement,double& minimumOfDiagonal,double& maximumOfDiagonal) {

	if(minimumOfDiagonal  > diagonalElement) {
		minimumOfDiagonal = diagonalElement;
	}
	if(maximumOfDiagonal  < diagonalElement) {
		maximumOfDiagonal = diagonalElement;
	}

	/* This is only an estimate of the condition number */
	const double ratioOfExtrema = minimumOfDiagonal / maximumOfDiagonal;

	if(ratioOfExtrema < RATIO_DIAGONAL_EXTRAMUM_LIMIT) {
		/* The matrix is badly scaled : we consider it as singular */
		sprintf(logMessage,"The ratio of diagonal elements = %f : the curvature matrix is badly conditionned\n",ratioOfExtrema);
		throw BadlyConditionnedMatrixException(logMessage);
	}
}

/**
 * Get the fit coefficients
 */
const double* AlgebraicSystemSolver::getArrayOfParameters() const {
	return arrayOfParameters;
}

/**
 * Compute the inverse of the Cholesky matrix
 */
void AlgebraicSystemSolver::computeInverseOfCholeskyMatrix() {

	double theSum;
	int k;

	for(int indexOfRow = 0; indexOfRow < numberOfFitParameters; indexOfRow++) {

		inverseOfCholeskyMatrix[indexOfRow][indexOfRow] = 1. / choleskyMatrix[indexOfRow][indexOfRow];

		for(int indexOfColumn = indexOfRow - 1; indexOfColumn >= 0; indexOfColumn--) {

			theSum = 0.;
			k      = indexOfColumn;

			while(k < indexOfRow) {

				theSum += choleskyMatrix[indexOfRow][k] * inverseOfCholeskyMatrix[k][indexOfColumn];
				k++;
			}

			inverseOfCholeskyMatrix[indexOfRow][indexOfColumn] = -theSum / choleskyMatrix[indexOfRow][indexOfRow];
		}
	}
}

/**
 * Class constructor
 */
LinearAlgebraicSystemSolver::LinearAlgebraicSystemSolver(LinearAlgebraicSystemInterface* const inputLinearAlgebraicSystem,
		const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) :
				AlgebraicSystemSolver(inputNumberOfFitParameters,inputMaximumNumberOfMeasurements), theLinearAlgebraicSystem(inputLinearAlgebraicSystem) {

	weightedObservations      = new double[maximumNumberOfMeasurements];
	if(weightedObservations  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for weightedObservations\n",maximumNumberOfMeasurements);
		throw InsufficientMemoryException(logMessage);
	}
}

/**
 * Class destructor
 */
LinearAlgebraicSystemSolver::~LinearAlgebraicSystemSolver() {

	if(weightedObservations != NULL) {
		delete[] weightedObservations;
		weightedObservations = NULL;
	}
}

/**
 * Solve the algebraic system
 */
void LinearAlgebraicSystemSolver::solveSytem() {

	/* Retrieve the number of measurements */
	numberOfMeasurements = theLinearAlgebraicSystem->getNumberOfMeasurements();

	/* Fill the design matrix */
	theLinearAlgebraicSystem->fillWeightedDesignMatrix(weightedDesignMatrix);

	/* Fill the weighted observations */
	theLinearAlgebraicSystem->fillWeightedObservations(weightedObservations);

	/* Compute the curvature matrix = transpose(weightedDesignMatrix) * weightedDesignMatrix */
	computeCurvatureMatrix();

	/* Decompose the curvature matrix by the Cholesky decomposition */
	decomposeCurvatureMatrix(curvatureMatrix);

	/* Compute projectObservations = transpose(weightedDesignMatrix) * weightedObservations */
	computeProjectedObservations();

	/* Solve the system */
	finishSolvingTheSystem(arrayOfParameters);
}

/**
 * Compute projectObservations = transpose(weightedDesignMatrix) * weightedObservations
 */
void LinearAlgebraicSystemSolver::computeProjectedObservations() {

	double theSum;

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		theSum       = 0.;
		for(int kMes = 0; kMes < numberOfMeasurements; kMes++) {
			theSum  += weightedDesignMatrix[kParameter][kMes] * weightedObservations[kMes];
		}

		projectedObservations[kParameter] = theSum;

		//printf("projectedObservations[%d] = %f\n",kParameter,projectedObservations[kParameter]);
	}
}

/**
 * Class constructor
 */
LevenbergMarquardtSystemSolver::LevenbergMarquardtSystemSolver(NonLinearAlgebraicSystemInterface* const inputNonLinearAlgebraicSystem,
		const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) :
				AlgebraicSystemSolver(inputNumberOfFitParameters,inputMaximumNumberOfMeasurements), theNonLinearAlgebraicSystem(inputNonLinearAlgebraicSystem) {

	hessianMatrix          = new double*[numberOfFitParameters];
	if(hessianMatrix      == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for hessianMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	covarianceMatrix       = new double*[numberOfFitParameters];
	if(covarianceMatrix  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for covarianceMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		hessianMatrix[kParameter]          = new double[numberOfFitParameters];
		if(hessianMatrix[kParameter]      == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for hessianMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}

		covarianceMatrix[kParameter]          = new double[numberOfFitParameters];
		if(covarianceMatrix[kParameter]      == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for covarianceMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}
	}

	weightedDeltaObservations      = new double[maximumNumberOfMeasurements];
	if(weightedDeltaObservations  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for weightedDeltaObservations\n",maximumNumberOfMeasurements);
		throw InsufficientMemoryException(logMessage);
	}

	temporaryWeightedDeltaObservations      = new double[maximumNumberOfMeasurements];
	if(temporaryWeightedDeltaObservations  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for temporaryWeightedDeltaObservations\n",maximumNumberOfMeasurements);
		throw InsufficientMemoryException(logMessage);
	}

	temporaryArrayOfParameters      = new double[numberOfFitParameters];
	if(temporaryArrayOfParameters  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for temporaryFitCoefficients\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	arrayOfParameterErrors      = new double[numberOfFitParameters];
	if(arrayOfParameterErrors  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for arrayOfParameterErrors\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	marquardtLambda       = NAN;
	recomputeMatrix       = false;
	convergenceCounter    = -1;
	chiSquare             = NAN;
}

/**
 * Class destructor
 */
LevenbergMarquardtSystemSolver::~LevenbergMarquardtSystemSolver() {

	if(weightedDeltaObservations != NULL) {
		delete[] weightedDeltaObservations;
		weightedDeltaObservations = NULL;
	}

	if(temporaryWeightedDeltaObservations != NULL) {
		delete[] temporaryWeightedDeltaObservations;
		temporaryWeightedDeltaObservations = NULL;
	}

	if(temporaryArrayOfParameters != NULL) {
		delete[] temporaryArrayOfParameters;
		temporaryArrayOfParameters = NULL;
	}

	if(arrayOfParameterErrors != NULL) {
		delete[] arrayOfParameterErrors;
		arrayOfParameterErrors = NULL;
	}

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		if(hessianMatrix[kParameter]      != NULL) {
			delete[] hessianMatrix[kParameter];
			hessianMatrix[kParameter] = NULL;
		}

		if(covarianceMatrix[kParameter]      != NULL) {
			delete[] covarianceMatrix[kParameter];
			covarianceMatrix[kParameter] = NULL;
		}
	}

	if(hessianMatrix != NULL) {
		delete[] hessianMatrix;
		hessianMatrix = NULL;
	}

	if(covarianceMatrix != NULL) {
		delete[] covarianceMatrix;
		covarianceMatrix = NULL;
	}
}

/**
 * Perform the Levenberg-Marquardt minimisation
 */
bool LevenbergMarquardtSystemSolver::optimise() {

	/* Fill arrayOfNumberOfMeasurements */
	numberOfMeasurements  = theNonLinearAlgebraicSystem->getNumberOfMeasurements();

	/* Fill the array of parameters */
	theNonLinearAlgebraicSystem->fillArrayOfParameters(arrayOfParameters);

	/* Compute the weighted delta observations */
	theNonLinearAlgebraicSystem->fillWeightedDeltaObservations(weightedDeltaObservations,arrayOfParameters,chiSquare);

	if(DEBUG) {
		printf("Initial solution chiSquare = %f\n",chiSquare);
	}

	int iterationCounter = 0;
	convergenceCounter   = 0;
	marquardtLambda      = 0.001;
	recomputeMatrix      = true;
	double newChiSquare;
	double deltaChisquare;

	while ((iterationCounter < MAXIMUM_NUMBER_OF_ITERATIONS) && (convergenceCounter < NUMBER_OF_NEEDED_CONVERGENCE)) {

		// Compute the matrix of derivative and fill the projected velocities
		prepareAlgebraicSystem();

		// Copy initialCurvatureMatrix in modifiedCurvatureMatrix and add the constant to diagonal
		copyCurvatureMatrix();

		// Decompose hessianMatrix by a Cholesky decomposition
		try {
			decomposeCurvatureMatrix(hessianMatrix);

			// Find the delta parameters
			computeDeltaParameters();

			// Check the new parameters
			theNonLinearAlgebraicSystem->checkArrayOfParameters(temporaryArrayOfParameters);

			/* Compute the weighted delta observations */
			theNonLinearAlgebraicSystem->fillWeightedDeltaObservations(temporaryWeightedDeltaObservations,temporaryArrayOfParameters,newChiSquare);

//			printf("iteration %d : x0 = %.3f - y0 = %.3f - theta = %+.3f - sigmaX = %.3f - sigmaY = %.3f -chiSquare = %.3f\n",
//								iterationCounter,temporaryArrayOfParameters[0],temporaryArrayOfParameters[1],
//								temporaryArrayOfParameters[2],temporaryArrayOfParameters[3],temporaryArrayOfParameters[4],newChiSquare);

			deltaChisquare  = newChiSquare - chiSquare;
			if ((fabs(deltaChisquare) < DELTA_CHI_SQUARE_LIMIT) || (fabs(deltaChisquare) < chiSquare * CHI_SQUARE_TOLERENCE)) {
				convergenceCounter++;
			}

			if (deltaChisquare    < 0.) {

				// Accept the new solution
				chiSquare         = newChiSquare;
				marquardtLambda  /= MARQUARDT_SCALE;
				recomputeMatrix   = true;
				swapSolutionParameters();

			} else {

				badStep();
			}


		} catch (BadlyConditionnedMatrixException&) {

			badStep();

		} catch (NonDefinitePositiveMatrixException&) {

			badStep();

		} catch (InvalidDataException&) {

			badStep();
		}

		iterationCounter++;
	}

	if(DEBUG) {
		printf("The minimisation took %d iterations => chiSquare = %f\n",iterationCounter,chiSquare);
	}

	return iterationCounter == MAXIMUM_NUMBER_OF_ITERATIONS;
}

/**
 * Compute the errors for a given fit
 */
bool LevenbergMarquardtSystemSolver::computeErrors() {

	/* Fill arrayOfNumberOfMeasurements */
	numberOfMeasurements  = theNonLinearAlgebraicSystem->getNumberOfMeasurements();

	/* Fill the array of parameters */
	theNonLinearAlgebraicSystem->fillArrayOfParameters(arrayOfParameters);

	/* Ask the model to fill the matrix of derivatives */
	theNonLinearAlgebraicSystem->fillWeightedDesignMatrix(weightedDesignMatrix,arrayOfParameters);

	/* Fill the curvature matrix */
	computeCurvatureMatrix();

	try {

		// Compute the Cholesky decomposition of the curvature matrix
		decomposeCurvatureMatrix(curvatureMatrix);

		// Inverse the curvature matrix
		inverseCurvatureMatrix();

		// Fill the array of errors
		fillErrors();

		return false;

	} catch (BadlyConditionnedMatrixException&) {

		setDefaultErrors();

		return true;

	} catch (NonDefinitePositiveMatrixException&) {

		setDefaultErrors();

		return true;

	} catch (InvalidDataException&) {

		setDefaultErrors();

		return true;
	}
}

/**
 * Inverse the curvature matrix to obtain the covariance matrix
 */
void LevenbergMarquardtSystemSolver::inverseCurvatureMatrix() {

	/* Compute the inverse of the matrix L */
	computeInverseOfCholeskyMatrix();

	/* No we compute transpose(inverseOfMatrixL) * inverseOfMatrixL */
	double theSum;
	int k;

	for(int indexOfColumn1 = 0; indexOfColumn1 < numberOfFitParameters; indexOfColumn1++) {

		for(int indexOfColumn2 = indexOfColumn1; indexOfColumn2 < numberOfFitParameters; indexOfColumn2++) {

			theSum = 0.;
			/* Since inverseOfMatrixL is also a lower triangular matrix, the sum starts at indexOfColumn2*/
			k      = indexOfColumn2;

			while(k < numberOfFitParameters) {

				theSum += inverseOfCholeskyMatrix[k][indexOfColumn1] * inverseOfCholeskyMatrix[k][indexOfColumn2];
				k++;
			}

			/* varianceCovarianceMatrix is symmetric */
			covarianceMatrix[indexOfColumn1][indexOfColumn2] = theSum;
			covarianceMatrix[indexOfColumn2][indexOfColumn1] = theSum;
		}
	}
}

/**
 * Fill the errors with the diagonal elements of the covariance matrix
 */
void LevenbergMarquardtSystemSolver::fillErrors() {

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		if(covarianceMatrix[kParameter][kParameter] >= 0.) {

			arrayOfParameterErrors[kParameter] = sqrt(covarianceMatrix[kParameter][kParameter]);

		} else {

			throw InvalidDataException("Negative variance elements");
		}
	}
}

/**
 * Fill the errors with a default value
 */
void LevenbergMarquardtSystemSolver::setDefaultErrors() {

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {
		arrayOfParameterErrors[kParameter] = NAN;
	}
}

/**
 * In the case of new computation of the matrix of derivatives,
 * we recompute weightedDeltaVelocities and the curvatureMatrix
 */
void LevenbergMarquardtSystemSolver::prepareAlgebraicSystem() {

	if(recomputeMatrix) {

		/* Ask the model to fill the matrix of derivatives */
		theNonLinearAlgebraicSystem->fillWeightedDesignMatrix(weightedDesignMatrix,arrayOfParameters);

		/* Fill the curvature matrix */
		computeCurvatureMatrix();

		/* Fill projectedVelocities */
		computeProjectedObservations();
	}
}

/**
 * Swap the solution parameters
 */
void LevenbergMarquardtSystemSolver::swapSolutionParameters() {

	double* temporaryAdress    = arrayOfParameters;
	arrayOfParameters          = temporaryArrayOfParameters;
	temporaryArrayOfParameters = temporaryAdress;

	temporaryAdress                    = weightedDeltaObservations;
	weightedDeltaObservations          = temporaryWeightedDeltaObservations;
	temporaryWeightedDeltaObservations = temporaryAdress;
}

/**
 * Copy initialCurvatureMatrix in modifiedCurvatureMatrix and add the constant to diagonal
 */
void LevenbergMarquardtSystemSolver::copyCurvatureMatrix() {

	const double onePlusLambda  = 1 + marquardtLambda;

	for(int kParameter1 = 0; kParameter1 < numberOfFitParameters; kParameter1++) {

		hessianMatrix[kParameter1][kParameter1] = onePlusLambda * curvatureMatrix[kParameter1][kParameter1];

		for(int kParameter2 = kParameter1 + 1; kParameter2 < numberOfFitParameters; kParameter2++) {

			hessianMatrix[kParameter1][kParameter2] = curvatureMatrix[kParameter1][kParameter2];
			hessianMatrix[kParameter2][kParameter1] = curvatureMatrix[kParameter1][kParameter2];
		}
	}
}

/**
 * Compute projectObservations = transpose(weightedDesignMatrix) * weightedObservations
 */
void LevenbergMarquardtSystemSolver::computeProjectedObservations() {

	double theSum;

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		theSum       = 0.;
		for(int kMes = 0; kMes < numberOfMeasurements; kMes++) {
			theSum  += weightedDesignMatrix[kParameter][kMes] * weightedDeltaObservations[kMes];
		}

		projectedObservations[kParameter] = theSum;
	}
}

/**
 * Change variables when for a bad step
 */
void LevenbergMarquardtSystemSolver::badStep() {

	marquardtLambda *= MARQUARDT_SCALE;
	recomputeMatrix  = false;
}

/**
 * Find the delta parameters
 */
void LevenbergMarquardtSystemSolver::computeDeltaParameters() {

	finishSolvingTheSystem(temporaryArrayOfParameters);

	// We find the delta fit parameters, so we add the fitCoefficients to have the complete parameters
	for (int indexOfRow = 0; indexOfRow < numberOfFitParameters; indexOfRow++) {
		temporaryArrayOfParameters[indexOfRow] += arrayOfParameters[indexOfRow];
	}
}

/**
 * Get the chiSquare of the fit
 */
double LevenbergMarquardtSystemSolver::getChiSquare() const {
	return chiSquare;
}

/**
 * Get the errors on parameters
 */
const double* LevenbergMarquardtSystemSolver::getArrayOfParameterErrors() const {

	return arrayOfParameterErrors;
}
