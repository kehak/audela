// libcatalog.h 

#pragma once

//=============================================================================
// export/import directives
//=============================================================================
#ifdef WIN32
#if defined(LIBCATALOG_EXPORTS) // inside DLL
#   define LIBCATALOG_API   __declspec(dllexport)
#else // outside DLL
#   define LIBCATALOG_API   __declspec(dllimport)
#endif 

#else 

#if defined(LIBCATALOG_EXPORTS) // inside DLL
#   define LIBCATALOG_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define LIBCATALOG_API 
#endif 

#endif

//=============================================================================
/// \namespace libcatalog
/// \brief Star catalog browser
///
/// libcatalog : Star catalog browser
///===============================
namespace libcatalog {

//=============================================================================
// data declation interfaces
//=============================================================================

//=============================================================================
// 2MASS
//=============================================================================
typedef struct {
	char id[17];
	double ra;
	double dec;
	double errorRa;
	double errorDec;
	double magnitudeJ;
	double errorMagnitudeJ;
	double magnitudeH;
	double errorMagnitudeH;
	double magnitudeK;
	double errorMagnitudeK;
	double jd;
} star2Mass;

struct listOfStars2Mass {
	star2Mass theStar;
	struct listOfStars2Mass* nextStar;
};

typedef struct listOfStars2Mass elementList2Mass;

//=============================================================================
// PPMX
//=============================================================================

typedef struct {
	char origineAstro;
	char origineMagB;
	char origineMagV;
	char origineMagR;
	short int flagDistTYC;
	int zoneNOMAD;
	int idNOMAD;
	int idUCAC2;
	int idHIP;
	int idTYC1;
	int idTYC2;
	int idTYC3;
	double ra;
	double dec;
	double errorRa;
	double errorDec;
	double pmRa;
	double pmDec;
	double errorPmRa;
	double errorPmDec;
	double epochRa;
	double epochDec;
	double magnitudeB;
	double magnitudeV;
	double magnitudeR;
	double magnitudeJ;
	double magnitudeH;
	double magnitudeK;
} starNomad1;

struct listOfStarsNomad1 {
	starNomad1 theStar;
	struct listOfStarsNomad1* nextStar;
};

typedef struct listOfStarsNomad1 elementListNomad1;

//----------------------------------------------------------------------------
typedef struct {
	char fitFlag;
	char subsetFlag;
	char src;
	char jName[16];  /* IAU name HHMMSS.S+ddmmss	*/ /*=ID */
	int nObs;
	double ra;
	double dec;
	double errorRa;
	double errorDec;
	double pmRa;
	double pmDec;
	double errorPmRa;
	double errorPmDec;
	double magnitudeC;
	double magnitudeR;
	double magnitudeB;
	double magnitudeV;
	double magnitudeJ;
	double magnitudeH;
	double magnitudeK;
	double errorMagnitudeB;
	double errorMagnitudeV;
	double errorMagnitudeJ;
	double errorMagnitudeH;
	double errorMagnitudeK;
} starPpmx;

struct listOfStarsPpmx {
	starPpmx theStar;
	struct listOfStarsPpmx* nextStar;
};

typedef struct listOfStarsPpmx elementListPpmx;

//=============================================================================
// PPMXL
//=============================================================================

typedef struct {
	int nObs;
	long long id;
	double ra;
	double dec;
	double errorRa;
	double errorDec;
	double pmRa;
	double pmDec;
	double errorPmRa;
	double errorPmDec;
	double epochRa;
	double epochDec;
	double magnitudeB1;
	double magnitudeB2;
	double magnitudeR1;
	double magnitudeR2;
	double magnitudeI;
	double magnitudeJ;
	double magnitudeH;
	double magnitudeK;
	double errorMagnitudeJ;
	double errorMagnitudeH;
	double errorMagnitudeK;
} starPpmxl;

struct listOfStarsPpmxl {
	starPpmxl theStar;
	struct listOfStarsPpmxl* nextStar;
};

typedef struct listOfStarsPpmxl elementListPpmxl;


//=============================================================================
// Tycho
//=============================================================================

/// Tycho star
typedef struct {
	double ra;					///< ra
	double dec;					///< dec
	double pmRa;				///< ra proper motion
	double pmDec;				///< dec proper motion 
	double errorPmRa;			///< ra proper motion error
	double errorPmDec;			///< dec proper motion error
	double meanEpochRA;			///< ra mean epoch
	double meanEpochDec;		///< dec mean epoch
	double goodnessOfFitRa;		///< goodness of fit ra
	double goodnessOfFitDec;	///< goodness of fit dec
	double goodnessOfFitPmRa;	///< goodness of fit proper motion ra
	double goodnessOfFitPmDec;	///< goodness of fit proper motion dec
	double magnitudeB;			///< B magnitude
	double errorMagnitudeB;		///< B magnitude error
	double magnitudeV;			///< V magnitude
	double errorMagnitudeV;		///< V magnitudeerror
	double observedRa;			///< observed ra
	double observedDec;			///< observed dec
	double epoch1990Ra;			///< epoch 1990 Ra
	double epoch1990Dec;		///< epoch 1990 Dec
	double errorObservedRa;		///< error observed ra
	double errorObservedDec;	///< error observed dec
	double correlationRaDec;	///< correlation Ra Dec;
	int id;						///< id
	int idTycho1;				///< id tycho 1
	int idTycho2;				///< id tycho 2
	int numberOfUsedPositions;	///< number Of Used Positions
	int errorRa;				///< ra error
	int errorDec;				///< dec error
	int proximityIndicator;		///< proximity indicator
	int hipparcosId;			///< hipparcos id
	char isTycho1Star;			///< is Tycho1 Star
	char idTycho3;				///< Tycho3 id
	char pflag;					///< pflag
	char solutionType;			///< solution type
	char componentIdentifierHIP[4]; ///< HIP component identifier 
} starTycho;

/// Tycho star array
struct listOfStarsTycho {
	starTycho theStar;				///< Tycho star element
	struct listOfStarsTycho* nextStar;
};

typedef struct listOfStarsTycho elementListTycho;

//=============================================================================
// UCAC2
//=============================================================================

typedef struct {
	int   raInMas;
	int   decInMas;
	short ucacMagInCentiMag;
	char  errorRaInMas;
	char  errorDecInMas;
	char  numberOfObservations;
	char  errorOnUcacPositionInMas;
	char  numberOfCatalogsForPosition;
	char  majorCatalogIdForPosition;
	short centralEpochForMeanRaInMas;
	short centralEpochForMeanDecInMas;
	int   raProperMotionInOneTenthMasPerYear;
	int   decProperMotionInOneTenthMasPerYear;
	char  errorOnRaProperMotionInOneTenthMasPerYear;
	char  errorOnDecProperMotionInOneTenthMasPerYear;
	char  raProperMotionGoodnessOfFit;
	char  decProperMotionGoodnessOfFit;
	int   idFrom2Mass;
	short jMagnitude2MassInMilliMag;
	short hMagnitude2MassInMilliMag;
	short kMagnitude2MassInMilliMag;
	char  qualityFlag2Mass;
	char  ccFlag2Mass;
} starUcac2;

struct listOfStarsUcac2 {
	int id;
	starUcac2 theStar;
	struct listOfStarsUcac2* nextStar;
};
typedef struct listOfStarsUcac2 elementListUcac2;

//=============================================================================
// UCAC3
//=============================================================================

typedef struct {
	int   raInMas;
	int   distanceToSouthPoleInMas;
	short ucacFitMagInMilliMag;
	short ucacApertureMagInMilliMag;
	short ucacErrorMagInMilliMag;
	char  objectType;
	char  doubleStarFlag;
	short errorOnUcacRaInMas;
	short errorOnUcacDecInMas;
	char  numberOfCcdObservation;
	char  numberOfUsedCcdObservation;
	char  numberOfUsedCatalogsForProperMotion;
	char  numberOfMatchingCatalogs;
	short centralEpochForMeanRaInMas;
	short centralEpochForMeanDecInMas;
	int   raProperMotionInOneTenthMasPerYear;
	int   decProperMotionInOneTenthMasPerYear;
	short errorOnRaProperMotionInOneTenthMasPerYear;
	short errorOnDecProperMotionInOneTenthMasPerYear;
	int   idFrom2Mass;
	short jMagnitude2MassInMilliMag;
	short hMagnitude2MassInMilliMag;
	short kMagnitude2MassInMilliMag;
	char  jQualityFlag2Mass;
	char  hQualityFlag2Mass;
	char  kQualityFlag2Mass;
	char  jErrorMagnitude2MassInCentiMag;
	char  hErrorMagnitude2MassInCentiMag;
	char  kErrorMagnitude2MassInCentiMag;
	short bMagnitudeSCInMilliMag;
	short r2MagnitudeSCInMilliMag;
	short iMagnitudeSCInMilliMag;
	char  scStarGalaxieClass;
	char  bQualityFlagSC;
	char  r2QualityFlagSC;
	char  iQualityFlag2SC;
	char  hipparcosMatchFlag;
	char  tychoMatchFlag;
	char  ac2000MatchFlag;
	char  agk2bMatchFlag;
	char  agk2hMatchFlag;
	char  zaMatchFlag;
	char  byMatchFlag;
	char  lickMatchFlag;
	char  scMatchFlag;
	char  spmMatchFlag;
	char  yaleSpmObjectType;
	char  yaleSpmInputCatalog;
	char  ledaGalaxyMatchFlag;
	char  extendedSourceFlag2Mass;
	char  mposStarNumber;
} starUcac3;

struct listOfStarsUcac3 {
	int id;
	int indexDec;
	starUcac3 theStar;
	struct listOfStarsUcac3* nextStar;
};

typedef struct listOfStarsUcac3 elementListUcac3;

//=============================================================================
// UCAC4
//=============================================================================

/* Raw structures are read herein,  so the following structure  */
/* must be packed on byte boundaries:                           */
#pragma pack( 1)

typedef struct {
	int            raInMas;
	int            distanceToSouthPoleInMas;
	unsigned short ucacFitMagInMilliMag;
	unsigned short ucacApertureMagInMilliMag;
	unsigned char  ucacErrorMagInCentiMag;
	unsigned char  objectType;
	unsigned char  doubleStarFlag;
	char           errorOnUcacRaInMas;
	char           errorOnUcacDecInMas;
	unsigned char  numberOfCcdObservation;
	unsigned char  numberOfUsedCcdObservation;
	unsigned char  numberOfUsedCatalogsForProperMotion;
	unsigned short centralEpochForMeanRaInCentiYear;
	unsigned short centralEpochForMeanDecInCentiYear;
	short          raProperMotionInOneTenthMasPerYear;
	short          decProperMotionInOneTenthMasPerYear;
	char           errorOnRaProperMotionInOneTenthMasPerYear;
	char           errorOnDecProperMotionInOneTenthMasPerYear;
	unsigned int   idFrom2Mass;
	unsigned short jMagnitude2MassInMilliMag;
	unsigned short hMagnitude2MassInMilliMag;
	unsigned short kMagnitude2MassInMilliMag;
	unsigned char  qualityFlag2Mass[3];
	unsigned char  errorMagnitude2MassInCentiMag[3];
	unsigned short magnitudeAPASSInMilliMag[5];
	unsigned char  magnitudeErrorAPASSInCentiMag[5];
	unsigned char  gFlagYale;
	unsigned int   fk6HipparcosTychoSourceFlag;
	unsigned char  legaGalaxyMatchFlag;
	unsigned char  extendedSource2MassFlag;
	unsigned int   starIdentifier;
	unsigned short zoneNumberUcac2;
	unsigned int   recordNumberUcac2;
} starUcac4;
#pragma pack( )

struct listOfStarsUcac4 {
	int id;
	int indexDec;
	starUcac4 theStar;
	struct listOfStarsUcac4* nextStar;
};

typedef struct listOfStarsUcac4 elementListUcac4;

//=============================================================================
// USNOA2
//=============================================================================

typedef struct {
	int zoneId;
	int position;
	double ra;
	double dec;
	double magnitudeR;
	double magnitudeB;
	int sign;
	int qflag;
	int field;
} starUsno;

struct listOfStarsUsnoa2 {
	starUsno theStar;
	struct listOfStarsUsnoa2* nextStar;
};

typedef struct listOfStarsUsnoa2 elementListUsnoa2;

//=============================================================================
// WFBIC
//=============================================================================

typedef struct {
	double ra;
	double dec;
	double errorRa;
	double errorDec;
	double jd;
	double pmRa;
	double pmDec;
	double errorPmRa;
	double errorPmDec;
	double magnitudeR;
	double errorMagnitudeR;
} starWfibc;

struct listOfStarsWfibc {
	starWfibc theStar;
	struct listOfStarsWfibc* nextStar;
};

typedef struct listOfStarsWfibc elementListWfibc;

//=============================================================================
// BMK
//=============================================================================

typedef struct {
	char bibCode[20];
	char starName[28];
	char sourceOfCoordinates[2];
	char passBand[2];
	char spectralType[12];
	int id;
	double ra;
	double dec;
	double magnitude;
} starBmk;

struct listOfStarsBmk {
	starBmk theStar;
	struct listOfStarsBmk* nextStar;
};

typedef struct listOfStarsBmk elementListBmk;

//=============================================================================
// URAT1
//=============================================================================

typedef struct {
	char   id[11];         // ID zone(%3d)-id(%06d)
	double ra;             // mean RA on ICRF at URAT mean obs.epoch (degree)
	double dec;            // mean Dec (degree)
	double sigs;           // position error per coord. from scatter (degree)
	double sigm;           // position error per coord. from model (degree)
	char   nst;            // total number of sets the star is in
	char   nsu;            // number of sets used for mean position + flag
	double  epoc;          // mean URAT obs. epoch - 2000.0 (year)
	double magnitude;      // mean URAT model fit magnitude (magnitude)
	double sigmaMagnitude; // URAT photometry error (magnitude)
	char  nsm;             // number of sets used for URAT magnitude
	char  ref;             // largest reference star flag
	short nit;             // total number of images (observations)
	short niu;             // number of images used for mean position
	char  ngt;             // total number of 1st order grating obs.
	char  ngu;             // number of 1st order grating positions used
	short pmr;             // proper motion RA*cosDec (from 2MASS) (0.1mas/yr)
	short pmd;             // proper motion Dec (0.1mas/yr)
	short pme;             // proper motion error per coordinate (0.1mas/yr)
	char  mf2;             // match flag URAT with 2MASS
	char  mfa;             // match flag URAT with APASS
	int   id2;             // unique 2MASS star identification number
	double jmag;           // 2MASS J mag (magnitude)
	double hmag;           // 2MASS H mag (magnitude)
	double kmag;           // 2MASS K mag (magnitude)
	double ejmag;          // error 2MASS J mag (magnitude)
	double ehmag;          // error 2MASS H mag (magnitude)
	double ekmag;          // error 2MASS K mag (magnitude)
	char  iccj;            // CC flag 2MASS J
	char  icch;            // CC flag 2MASS H
	char  icck;            // CC flag 2MASS K
	char  phqj;            // photometry quality flag 2MASS J
	char  phqh;            // photometry quality flag 2MASS H
	char  phqk;            // photometry quality flag 2MASS K
	double abm;            // APASS B mag
	double avm;            // APASS V mag
	double agm;            // APASS g mag
	double arm;            // APASS r mag
	double aim;            // APASS i mag
	double ebm;            // error APASS B mag
	double evm;            // error APASS V mag
	double egm;            // error APASS g mag
	double erm;            // error APASS r mag
	double eim;            // error APASS i mag
	char  ann;             // APASS numb. of nights
	char  ano;             // APASS numb. of observ.
} starUrat1;

struct listOfStarsUrat1 {
	starUrat1 theStar;
	struct listOfStarsUrat1* nextStar;
};

typedef struct listOfStarsUrat1 elementListUrat1;

//=============================================================================
// LONEOS
//=============================================================================

#pragma pack( 1)
typedef struct {
	int  id;
	char starName[19];
	char nameInGSC[10];
	char sourceOfCoordinates;
	char isStandard;
	char uncertaintyColorBV;
	char uncertaintyColorUB;
	double ra;
	double dec;
	float magnitudeV;
	float colorBV;
	float colorUB;
	float colorVR;
	float colorVI;
} starLoneos;
#pragma pack( )

struct listOfStarsLoneos {
	starLoneos theStar;
	struct listOfStarsLoneos* nextStar;
};

typedef struct listOfStarsLoneos elementListLoneos;

//=============================================================================
// TGAS
//=============================================================================

/* In 64bit machines, the blocks = 8 bytes => we put referenceEpoch before sourceId to save space
 * without using pragma */
typedef struct {
	int    hipId;
	float  referenceEpoch;
	long long sourceId;
	double ra;
	double raError;
	double dec;
	double decError;
	double parallax;
	double parallaxError;
	double pmRa;
	double pmRaError;
	double pmDec;
	double pmDecError;
	double meanFluxG;
	double meanFluxGError;
	double meanMagnitudeG;
	char   astrometricPrimaryFlag;
	char   astrometricPriorsUsed;
	char   variabilityFlag;
	char   tycho2Id[13];
} starTGAS;

struct listOfStarsTGAS {
	starTGAS theStar;
	struct listOfStarsTGAS* nextStar;
};

typedef struct listOfStarsTGAS elementListTGAS;

//=============================================================================
// Gaia 1
//=============================================================================

#pragma pack( 1)
typedef struct {
	long long sourceId;
	double ra;
	double raError;
	double dec;
	double decError;
	double parallax;
	double parallaxError;
	double pmRa;
	double pmRaError;
	double pmDec;
	double pmDecError;
	double meanFluxG;
	double meanFluxGError;
	double meanMagnitudeG;
	float  referenceEpoch;
	char   astrometricPrimaryFlag;
	char   astrometricPriorsUsed;
	char   variabilityFlag;
} starGaia1;
#pragma pack( )

struct listOfStarsGaia1 {
	starGaia1 theStar;
	struct listOfStarsGaia1* nextStar;
};

typedef struct listOfStarsGaia1 elementListGaia1;

//=============================================================================
// Gaia 2
//=============================================================================

#define GAIA2_REFERENCE_EPOCH   2015.5

typedef struct {
	long long sourceId;
	double ra;
	double raError;
	double dec;
	double decError;
	double parallax;
	double parallaxError;
	double pmRa;
	double pmRaError;
	double pmDec;
	double pmDecError;
	double meanMagnitudeG;
    double meanMagnitudeGError;
    double meanMagnitudeBP;
    double meanMagnitudeBPError;
    double meanMagnitudeRP;
    double meanMagnitudeRPError;
    double colorBPRP;
    double apsisTeff;
    double apsisAg;
} starGaia2;

typedef struct {
	starGaia2 theStarGaia2;
	double vRad;
	float vRadError;
	float templateTeff;
	float templateLogg;
	float templateFeH;
} starGaia2WithVrad;

struct listOfStarsGaia2 {
	starGaia2WithVrad theStar;
	struct listOfStarsGaia2* nextStar;
};

typedef struct listOfStarsGaia2 elementListGaia2;

struct listOfStarsGaia2WithSize {
	int size;
	elementListGaia2* listOfStars;
};

//=============================================================================
// constants
//=============================================================================

/* dec at the south pole in deg */
#define DEC_SOUTH_POLE_DEG -90.
/* dec at the north pole in deg */
#define DEC_NORTH_POLE_DEG  90.
/* 1 deg = pi / 180. rad = 0.01745329251994329547 rad */
#define DEC2RAD 0.01745329251994329547


/* 1 mag = 10 deciimag */
#define MAG2DECIMAG   10.
/* 1 mag = 100 centimag */
#define MAG2CENTIMAG  100.
/* 1 mag = 1000 milli mag */
#define MAG2MILLIMAG  1000.
/* 1 hour = 15 deg */
#define HOUR2DEG      15.
/* 1 deg = 60 arcmin */
#define DEG2ARCMIN    60.

/* 1 deg = 3600000 mas (= milli arc second) */
#define DEG2MAS         3600000.
#define DEG2DECIMAS     36000000.
#define DEG2MICRODEG    1.e6

/* */
#define YEAR2MILLIYEAR  1000.

//=============================================================================
// IAllExceptions
//=============================================================================
class IAllExceptions {

public:
	virtual char* getTheMessage()=0;
	virtual unsigned long  getCode(void)=0;
	virtual ~IAllExceptions() {};

	typedef enum {
		GenericError,
		MemoryError,
	} ErrorCode;

};

typedef void (* ErrorCallbackType)(int code, const char * message);
extern "C" LIBCATALOG_API void ICatalog_registerErrorCallback( ErrorCallbackType applicationCallback);

//=============================================================================
// ICatalog 
//=============================================================================
//  1) ICatalog class declaration for C++ users
/// catalog search 
class ICatalog
{
public:
	virtual void release()=0;
	virtual listOfStars2Mass*  cs2mass  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsNomad1* csnomad1 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsPpmx*   csppmx   (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsPpmxl*  csppmxl  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	/// returns TYCHO catalog stars which are near (ra,dec)  coordinates within radius , and beetwen magMin and magMax magnitudes
	virtual listOfStarsTycho*  cstycho2 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsUcac2*  csucac2  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsUcac3*  csucac3  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsUcac4*  csucac4  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsUsnoa2* csusnoa2(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsWfibc*  cswfibc  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsTycho*  cstycho2Fast(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsBmk*    csbmk(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsUrat1*  csurat1(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsLoneos* csloneos(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsTGAS*   cstgas(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsGaia1*  csgaia1(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;
	virtual listOfStarsGaia2*  csgaia2(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)=0;

	virtual void releaseListOfStar2Mass(listOfStars2Mass* listOfStars) = 0;
	virtual void releaseListOfStarNomad1(listOfStarsNomad1* listOfStars) = 0;
	virtual void releaseListOfStarPpmx(listOfStarsPpmx* listOfStars) = 0;
	virtual void releaseListOfStarPpmxl(listOfStarsPpmxl* listOfStars) = 0;
	virtual void releaseListOfStarTycho(listOfStarsTycho* listOfStars) = 0;
	virtual void releaseListOfStarUcac2(listOfStarsUcac2* listOfStars) = 0;
	virtual void releaseListOfStarUcac3(listOfStarsUcac3* listOfStars) = 0;
	virtual void releaseListOfStarUcac4(listOfStarsUcac4* listOfStars) = 0;
	virtual void releaseListOfStarUsnoa2(listOfStarsUsnoa2* listOfStars) = 0;
	virtual void releaseListOfStarWfibc(listOfStarsWfibc* listOfStars) = 0;
	virtual void releaseListOfStarBmk(listOfStarsBmk* listOfStars) = 0;
	virtual void releaseListOfStarUrat1(listOfStarsUrat1* listOfStars) = 0;
	virtual void releaseListOfStarLoneos(listOfStarsLoneos* listOfStars) = 0;
	virtual void releaseListOfStarTGAS(listOfStarsTGAS* listOfStars) = 0;
	virtual void releaseListOfStarGaia1(listOfStarsGaia1* listOfStars) = 0;
	virtual void releaseListOfStarGaia2(listOfStarsGaia2* listOfStars) = 0;

public:
	virtual void throwCallbackError(IAllExceptions &exception)=0;
	virtual ~ICatalog() {};
};

// 2) ICatalog "C" functions declaration for other langages than C++
extern "C" LIBCATALOG_API listOfStars2Mass*  ICatalog_cs2mass (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsNomad1* ICatalog_csnomad1(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsPpmx*   ICatalog_csppmx  (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsPpmxl*  ICatalog_csppmxl (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsTycho*  ICatalog_cstycho2(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsUcac2*  ICatalog_csucac2 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsUcac3*  ICatalog_csucac3 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsUcac4*  ICatalog_csucac4 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsUsnoa2* ICatalog_csusnoa2(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsWfibc*  ICatalog_cswfibc (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsTycho*  ICatalog_cstycho2Fast(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsBmk*    ICatalog_csbmk(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsUrat1*  ICatalog_csurat1(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsLoneos* ICatalog_csloneos(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsTGAS*   ICatalog_cstgas(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsGaia1*  ICatalog_csgaia1(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
extern "C" LIBCATALOG_API listOfStarsGaia2*  ICatalog_csgaia2(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);

/* Functions to release the retrieved stars */
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStar2Mass (ICatalog* catalog, listOfStars2Mass*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarNomad1(ICatalog* catalog, listOfStarsNomad1* listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarPpmx  (ICatalog* catalog, listOfStarsPpmx*   listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarPpmxl (ICatalog* catalog, listOfStarsPpmxl*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarTycho (ICatalog* catalog, listOfStarsTycho*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarUcac2 (ICatalog* catalog, listOfStarsUcac2*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarUcac3 (ICatalog* catalog, listOfStarsUcac3*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarUcac4 (ICatalog* catalog, listOfStarsUcac4*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarUsnoa2(ICatalog* catalog, listOfStarsUsnoa2* listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarWfibc (ICatalog* catalog, listOfStarsWfibc*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarBmk   (ICatalog* catalog, listOfStarsBmk*    listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarUrat1 (ICatalog* catalog, listOfStarsUrat1*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarLoneos(ICatalog* catalog, listOfStarsLoneos* listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarTGAS  (ICatalog* catalog, listOfStarsTGAS*   listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarGaia1 (ICatalog* catalog, listOfStarsGaia1*  listOfStars);
extern "C" LIBCATALOG_API void ICatalog_releaseListOfStarGaia2 (ICatalog* catalog, listOfStarsGaia2*  listOfStars);

// 3) ICatalog factory
extern "C" LIBCATALOG_API ICatalog* ICatalog_createInstance( ErrorCallbackType applicationCallback );
extern "C" LIBCATALOG_API void ICatalog_releaseInstance( ICatalog* catalog);

} // namespace end

