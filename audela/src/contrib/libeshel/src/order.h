
#include <valarray>

#ifndef _INC_LIBESHEL_ORDER
#define _INC_LIBESHEL_ORDER

#define LIBESHEL_VERSION 2.4

#define MAX_ORDRE 100
#define MAX_LINES 400 
#define POLY_ORDER_DEGREE 5

typedef struct ORDRE
   {
   int flag;
   int min_x;
   int max_x;
   int yc;
   double poly_order[POLY_ORDER_DEGREE+1];   // 
   double rms_order;
   int wide_y;
   int wide_x;             // largeur d'incertitude pour recherche raies néon
   double slant;
   double a0;              //
   double a1;
   double a2;
   double a3;
   double rms_calib_spec;
   double fwhm;            // largeur à mi-hauteur moyenne en pixel
   double central_lambda;  // longueur centrale d'un ordre
   double disp;            // dispersion moyenne en A/pixel
   double resolution;      // 
   int nb_lines;           // nombre de raies utilisées pour la calibration spectrale (v1.4) 
   //int position_lines[MAX_LINES];  
      //double dx;              // position théorique de raie de calibration dans le profil spectral  
   double backgroundLevel;
   double backgroundSigma;
} ORDRE;

typedef struct INFOSPECTRO {
   double alpha;  // angle d'incidence (en degrès)
   double beta;   // angle de difraction (en degrès)
   double gamma;  // angle d'échappement (en degrès)
   double m;      // nombre de traits par millimètre de la gravure du réseau
   double focale; // distance focale de la caméra (en millimètres)
   double pixel;  // taille des pixels (en millimètres)
   int imax;      // nombre de pixels suivant X (axe spatial)
   int jmax;      // nombre de pixels suivant Y (axe spatial)
   int min_order; // numéro du premier ordre à détecter
   int max_order; // numéro du dernier ordre à détecter
   ::std::valarray<double> distorsion;  // polynome de correction de la distorsion optique
   double version; //version du header de la table des ordres
} INFOSPECTRO;



typedef struct PROCESS_INFO {
    int referenceOrderNum;    // reference order num
    int referenceOrderX;      // reference order x
    int referenceOrderY;      // reference order y
    double referenceOrderLambda; //reference order lambda 
    int detectionThreshold;   // dectection threshold
    int calibrationIteration; // nombre d'iteration du traitement de la calibration
    int bordure;              // Valeur du crop des bords de spectre après la correction géométrique
    double version;           // version du header
} PROCESS_INFO;

typedef struct CROP_LAMBDA {
    double minLambda;    // min wave length
    double maxLambda;      //  max wave length
} CROP_LAMBDA;

typedef struct REFERENCE_LINE {
    int    order;     
    double lambda;    
    double posx;      
    double posy;      
} REFERENCE_LINE;


void startTimer();
double stopTimer(char * lpFormat, ...);

#endif