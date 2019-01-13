// processing.h : processing functions
//

#ifndef _INC_LIBESHEL_PROCESSING
#define _INC_LIBESHEL_PROCESSING

#include <windows.h>
#include <math.h>
#include <float.h> // pour _isnan
#include <vector>
#include <limits.h> // pour INT_MAX et INT_MIN


#include <exception>
#define swab _swab  //  replace "swab" by "_swab" because "swab" is deprecaded

#include "infoimage.h"
#include "order.h"
#include "linegap.h"


// definition des constantes et de macros
#define SGN(x) (x>=0?1:-1)
#define PI M_PI    // j'utilise la valeur de M_PI declaree dans math.h
#define SEUIL_ALPHA 0  // seuil de l'angle ALPHA pour distinguer les spectro echelle (alpha > 60 )



// fonctions locales
void setSoftwareVersionKeyword( CCfits::PFitsFile pFits );
FILE * openLog(char *fileName);

void correctDistorsion( );

int gauss_convol(INFOIMAGE *buffer,double sigma);
int grady(INFOIMAGE *buffer,int flag);
int grady2(INFOIMAGE *buffer, int flag);
int calc_cdg_y(PIC_TYPE *p,int imax,int jmax,int x,int y1,int y2,double *pos_y);
void find_y_pos(INFOIMAGE &buffer, PROCESS_INFO &processInfo,
               ORDRE *ordre, int &nb_ordre,int min_order,int max_order);
void track_order(INFOIMAGE *buffer,int imax,int jmax,int wide_y,ORDRE *ordre,int n);
void fitPoly(int numpts,int degree,double *x,double *y,double *wt,double *coeffs,double *rms);
int calib_prediction(double lambda0,int ordre0,int imax,int jmax,double posx0,
                     double *ddx,INFOSPECTRO spectro,::std::list<double> lineList);
void extract_order(INFOIMAGE *buffer, PROCESS_INFO &processInfo, int n,ORDRE *ordre,int cropWidth,int cropHeight,
                  std::valarray<double> &profile, std::valarray<PIC_TYPE> &straightLineImage, 
                  int flag_opt );
//PIC_TYPE hmedian(PIC_TYPE *ra,int n);
int hmedian(int data[], int length);
double hmedian(double data[], int length);
double compute_pos(double k,double lam,double dx,int imax, INFOSPECTRO spectro);
int compute_slant(INFOIMAGE *buffer,int y0,double alpha);
int flat_rectif(int i,char *n_objet,char *n_flat,ORDRE *ordre);
void flat_rectif(std::valarray<double> &object,std::valarray<double> &flat, std::valarray<double> &out);
void calib_spec(int n,int nb_iter,PROCESS_INFO &processInfo, INFOSPECTRO &spectro,
                std::valarray<double> &calibRawProfile, ORDRE *ordre,
                ::std::list<double> &lineList, ::std::list<LINE_GAP> &lineGapList);
int make_interpol(std::valarray<double> &table_in, 
                  INFOSPECTRO &spectro, PROCESS_INFO &processInfo,
                  ORDRE *ordre, int n, double dx, double step,
                  std::valarray<double> &table_out, double &lambda1);
double compute_px2lambda(double px, double k, double dx, INFOSPECTRO &spectro);
void interpol_2p(double xa, double ya, double xb, double yb, double x, double *y);
void line_pos_approx(int pos,int wide,std::valarray<double> &buf,int &posx);
int spline(int n,double *x,double *y,double *b,double *c,double *d);
double seval(int n,double u,double *x,double *y,double *b,double *c,double *d);
double seval(int n, double u, double *x, double *y, double *b, double *c, double *d, bool flag);
void aboute_spectres(int max_ordre,int min_ordre,char *nom_objet,char *nom_calib,char *nom_out,int useFlat);
int find_max(INFOIMAGE *buffer, int *x,int *y);
int spec_gauss(int pos,int wide,std::valarray<double> &buf,double &pos_x,double &fwhm,double &ecartType);
int find_continuum(char *n_spectre,char *n_continuum);
double get_central_wave(int imax,double posx,double dx,int k,INFOSPECTRO spectro);

void divideResponse(std::valarray<double> &profile1b, double lambda1b, double step, 
                    std::valarray<double> &responseProfile, double responseLambda, double responseStep);

void divideResponsePerOrder(std::valarray<double> &profile1b, double lambda1b, double step, 
                    std::valarray<double> &responseProfile, double responseLambda, double responseStep);

double getNorme (::std::valarray<::std::valarray<double>> &profile, double *lambda1, 
                    double lambdaBegin, double lambdaEnd,ORDRE *ordre, double step);

void nomalise_all_spec(::std::valarray<::std::valarray<double>> &profile, double *lambda1, 
                        double lambdaBegin, double lambdaEnd, 
                        ORDRE *ordre, double step, int minOrder,int maxOrder);
void crop_lambda(::std::valarray<CROP_LAMBDA> &cropLambda, ::std::valarray<::std::valarray<double>> &profile, double *lambda1, 
                   ORDRE *ordre, double step, int minOrder,int maxOrder);

void abut1bOrder(::std::valarray<::std::valarray<double>> &object1BProfile, double *lambda1, 
                 int min_ordre, int max_ordre, double step,
                 ::std::valarray<double> &full1BProfile, double &fullLambda1);

void planck_correct(std::valarray<double> &profile1b, double lambda1, double step, double temperature);

void spectre_gauss(::std::valarray<double> &profile, double sigma, int n);

void translate_col(INFOIMAGE * buffer,
                          int colonne, double delta_y, ORDRE *ordre, int n,
                          std::valarray<PIC_TYPE> &buf_result, int imax_result, int jmax_result,
                          int spline_deg);

#endif
