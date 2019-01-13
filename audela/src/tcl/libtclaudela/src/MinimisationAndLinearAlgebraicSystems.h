/**
 * Header file for Levenberg-Marquardt minimisation and linear algebraic systems
 *
 * Author : Yassine Damerdji
 */

#ifndef __MINIMISATIONANDLINEARALGEBRAICSYSTEMS__
#define __MINIMISATIONANDLINEARALGEBRAICSYSTEMS__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "AllExceptions.h"

#define RATIO_DIAGONAL_EXTRAMUM_LIMIT 1e-15

#ifndef M_PI
# define M_PI 3.14159265358979323846
#endif

#ifndef NAN
static const unsigned long __nan[2] = {0xffffffff, 0x7fffffff};
#define NAN (*(const double *) __nan)
#endif

#define DEBUG false

/**
 *Interface for linear algebraic systems
 */
class LinearAlgebraicSystemInterface {

public:
	LinearAlgebraicSystemInterface() {};
	virtual ~LinearAlgebraicSystemInterface() {};
	virtual void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix) = 0;
	virtual void fillWeightedObservations(double* const weightedObservartions) = 0;
	virtual int getNumberOfMeasurements() = 0;
};

/**
 *Interface for linear algebraic systems
 */
class NonLinearAlgebraicSystemInterface {

public:
	NonLinearAlgebraicSystemInterface() {};
	virtual ~NonLinearAlgebraicSystemInterface() {};
	virtual void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters) = 0;
	virtual void fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters, double& chiSquare) = 0;
	virtual void fillArrayOfParameters(double* const arrayOfParameters) = 0;
	virtual void checkArrayOfParameters(double* const arrayOfParameters) = 0;
	virtual int getNumberOfMeasurements() = 0;
};

/**
 * Class to solve algebraic systems by Cholesky decomposition
 */
class AlgebraicSystemSolver {

protected:
	char logMessage[1024];
	int numberOfFitParameters;;
	int maximumNumberOfMeasurements;
	int numberOfMeasurements;
	double** weightedDesignMatrix;
	double** curvatureMatrix;
	double* projectedObservations;
	double* arrayOfParameters;
	double** choleskyMatrix;
	double** inverseOfCholeskyMatrix;
	double* intermediateArray;
	void computeCurvatureMatrix();
	virtual void computeProjectedObservations() = 0;
	void decomposeCurvatureMatrix(double** theCurvatureMatrix);
	void isMatrixBadlyConditionned(const double diagonalElement,double& minimumOfDiagonal,double& maximumOfDiagonal);
	void finishSolvingTheSystem(double* const theFitCoefficients);
	void computeInverseOfCholeskyMatrix();

public:
	AlgebraicSystemSolver(const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements);
	virtual ~AlgebraicSystemSolver();
	const double* getArrayOfParameters() const;
};

/**
 * Class to solve linear algebraic systems by Cholesky decomposition
 */
class LinearAlgebraicSystemSolver : public AlgebraicSystemSolver {

private:
	LinearAlgebraicSystemInterface* theLinearAlgebraicSystem;
	double* weightedObservations;

protected:
	void computeProjectedObservations();

public:
	LinearAlgebraicSystemSolver(LinearAlgebraicSystemInterface* const inputLinearAlgebraicSystem,
			const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements);
	virtual ~LinearAlgebraicSystemSolver();
	void solveSytem();
};

/**
 * Class to solve non linear algebraic systems using Levenberg-Marquardt algorithm
 */
class LevenbergMarquardtSystemSolver : public AlgebraicSystemSolver {

private:
	/** We need 3 successive convergences to stop iterating */
	static const int NUMBER_OF_NEEDED_CONVERGENCE;
	/** The maximum number of allowed iterations */
	static const int MAXIMUM_NUMBER_OF_ITERATIONS;
	/** The Marquardt scaling factor */
	static const double MARQUARDT_SCALE;
	/** Needed to stop iterating */
	static const double DELTA_CHI_SQUARE_LIMIT;
	/** Needed to stop iterating */
	static const double CHI_SQUARE_TOLERENCE;
	/** Marquardt's factor */
	double marquardtLambda;
	/** True if we want to recompute the matrix of derivatives in a given iteration */
	bool recomputeMatrix;
	/** Counts the number of convergences */
	int convergenceCounter;
	/** The chiSquare of the fit */
	double chiSquare;
	NonLinearAlgebraicSystemInterface* theNonLinearAlgebraicSystem;
	double** hessianMatrix;
	double** covarianceMatrix;
	double* weightedDeltaObservations;
	double* temporaryWeightedDeltaObservations;
	double* temporaryArrayOfParameters;
	double* arrayOfParameterErrors;
	void prepareAlgebraicSystem();
	void copyCurvatureMatrix();
	void computeDeltaParameters();
	void badStep();
	void swapSolutionParameters();
	void setDefaultErrors();
	void fillErrors();
	void inverseCurvatureMatrix();

protected:
	void computeProjectedObservations();

public:
	LevenbergMarquardtSystemSolver(NonLinearAlgebraicSystemInterface* const inputNonLinearAlgebraicSystem,
			const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements);
	virtual ~LevenbergMarquardtSystemSolver();
	bool optimise();
	bool computeErrors();
	double getChiSquare() const;
	const double* getArrayOfParameterErrors() const;
};

#endif // __MINIMISATIONANDLINEARALGEBRAICSYSTEMS__
