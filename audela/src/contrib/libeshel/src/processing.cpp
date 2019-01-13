// echelle.cpp : Eshel main functions .
//
#ifdef _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#endif


#include <windows.h>
#include <math.h>
#include <float.h> // pour _isnan
#include <vector>
#include <limits.h> // pour INT_MAX et INT_MIN


#include <exception>
#define swab _swab  //  replace "swab" by "_swab" because "swab" is deprecaded

#include "libeshel.h"
#include "infoimage.h"
#include "order.h"
#include "linegap.h"
#include "fitsfile.h"
#include "processing.h"

// fonctions locales 
void SamplesToCoefficients(float *Image,		/* in-place processing */
                                 int Width,		    /* width of the image */
                                 int Height,		/* height of the image */
                                 int SplineDegree   /* degree of the spline model */
                                 );
double InterpolatedValue(float *Bcoeff,	  /* input B-spline array of coefficients */
                                int Width,		  /* width of the image */
                                int Height,		  /* height of the image */
                                double x,		  /* x coordinate where to interpolate */
                                double y,		  /* y coordinate where to interpolate */
                                int SplineDegree  /* degree of the spline model */
                                );
void l_opt(std::valarray<PIC_TYPE> &p, 
          int imax, int jmax, int lmin,int lmax,
          int xmin,int xmax,std::valarray<double> &profile);

void l_opt2(std::valarray<PIC_TYPE> &p,
            int imax, int jmax,
            int lmin, int lmax, int xmin, int xmax,
            std::valarray<double> &profile);

void MipsParaFit(int n, std::valarray<double> &y, double *p, double &ecart);

// definition des constantes et de macros
#define SGN(x) (x>=0?1:-1)
#define PI M_PI    // j'utilise la valeur de M_PI declaree dans math.h
#define SEUIL_ALPHA 0  // seuil de l'angle ALPHA pour distinguer les spectro echelle (alpha > 60 )

// fonctions locales
FILE * openLog(char *fileName);


/** 
 * setSoftwareVersionKeyword
 *  ajoute le mot cle 
 */

void setSoftwareVersionKeyword( CCfits::PFitsFile pFits ) {
   char value[70];

   sprintf(value,"libsehel-%1.1f", LIBESHEL_VERSION);
   Fits_setKeyword(pFits,"PRIMARY","SWCREATE",value,"Processing software");
}




// ---------------------------------------------------
// extractOrders
//    retourne les parametres d'un ordre
// Parameter:
//    fileName
//    orderValue
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
/*void extractOrders(char *fileName, ORDRE *orderValue )  {
   CCfits::PFitsFile pFits = NULL;

   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getOrders(pFits, orderValue);
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      Fits_closeFits(pFits);
      throw e;
   }

}

*/

// ---------------------------------------------------
// Création d'un fichier texte de trace
// ---------------------------------------------------
FILE * openLog(char *fileName) {
   FILE * hand_log;
   if ((hand_log=fopen("reduc.log","a+t"))==NULL) 
      {
 	   printf("Problème d'ouverture en ecriture du fichier %s",fileName);
 	   return NULL;
      }
   return hand_log;
}

// ---------------------------------------------------
// divise un profil par la reponse instrumenale          
// ---------------------------------------------------
void divideResponse(std::valarray<double> &profile1b, double lambda1b, double step, std::valarray<double> &responseProfile, double responseLambda, double responseStep) {
   unsigned int taille_num = profile1b.size();
   unsigned int taille_den = responseProfile.size();
   double * rx = new double[taille_den];
   double * ry = new double[taille_den];
   double * a = new double[taille_den];
   double * b = new double[taille_den];
   double * c = new double[taille_den];

   // Calcul des coefficients de spline (sur le dénominateur)
   for (unsigned int i = 0; i < taille_den; i++)
   {
      rx[i] = responseLambda + responseStep * i;
      ry[i] = responseProfile[i];
   }
   spline(taille_den, rx, ry, a, b, c);

   // Division 
   double responseLambdaMax = responseLambda + responseStep * (taille_den -1); 
   for (unsigned int i = 0; i < taille_num; i++)
   {
      double x = lambda1b + step * i;;
      if (x < responseLambda || x > responseLambdaMax )
      {
         profile1b[i] = 0.0;
      }
      else
      {
         double y = seval(taille_den, x, rx, ry, a, b, c, false);
         if (y != 0.0)
            profile1b[i] = profile1b[i] / y;
         else
            profile1b[i] = 0.0;
      }
   }

   delete [] rx;
   delete [] ry;
   delete [] a;
   delete [] b;
   delete [] c;
}

// ---------------------------------------------------
// divise un profil par la reponse instrumenale          
// ---------------------------------------------------
void divideResponsePerOrder(std::valarray<double> &profile1b, double lambda1b, double step, std::valarray<double> &responseProfile, double responseLambda, double responseStep) {
   unsigned int taille_num = profile1b.size();
   unsigned int taille_den = responseProfile.size();
   double * rx = new double[taille_den];
   double * ry = new double[taille_den];
   double * a = new double[taille_den];
   double * b = new double[taille_den];
   double * c = new double[taille_den];

   // On calcule la norme moyenne (au cas ou le fichier réponse est plus petit que l'ordre à traiter
   double norme = 0.0;
   norme = responseProfile.sum() / (double)taille_den;
   if (norme == 0.0) norme = 1.0;

   // Calcul des coefficients de spline (sur le dénominateur)
   for (unsigned int i = 0; i < taille_den; i++)
   {
      rx[i] = responseLambda + responseStep * i;
      ry[i] = responseProfile[i];
   }
   spline(taille_den, rx, ry, a, b, c);

   // Division 
   double responseLambdaMax = responseLambda + responseStep * (taille_den -1); 
   for (unsigned int i = 0; i < taille_num; i++)
   {
      double x = lambda1b + step * i;
      // je prends une mage de 1 angtrom car la RI generee par ISIS 
      if (x < (responseLambda - 1)|| x > (responseLambdaMax +1 ) )
      {
         // on divise 1B par la norme moyenne
         profile1b[i] = profile1b[i] / norme;
      }
      else
      {
         double y = seval(taille_den, x, rx, ry, a, b, c, false);
         if (y != 0.0)
            profile1b[i] = profile1b[i] / y;
         else
            profile1b[i] = profile1b[i] / norme;
      }
   }

   delete [] rx;
   delete [] ry;
   delete [] a;
   delete [] b;
   delete [] c;
}

// --------------------------------------------------------------------
// Normalisation de tous les ordres à la valeur de l'intensité moyenne
// trouvée entre les longueurs d'onde b1 et b2 A (compatibles avec l'ordre 34)   
// --------------------------------------------------------------------
void nomalise_all_spec (::std::valarray<::std::valarray<double>> &profile, double *lambda1, 
                        double lambdaBegin, double lambdaEnd, 
                        ORDRE *ordre, double step, int minOrder,int maxOrder) 
{
   double norme = getNorme(profile,lambda1,lambdaBegin, lambdaEnd, ordre, step);
   // j'applique la norme a tous les profils
   for (int n=minOrder; n<=maxOrder; n++) {
      if (ordre[n].flag==1) {
         profile[n] /=norme;
      }
   }
}

// --------------------------------------------------------------------
// retourne l'intensité moyenne 
// trouvée entre les longueurs d'onde b1 et b2 A (compatibles avec l'ordre 34)   
// --------------------------------------------------------------------
double getNorme(::std::valarray<::std::valarray<double>> &profile, double *lambda1,
                        double lambdaBegin, double lambdaEnd, ORDRE *ordre, double step) 
{
   int posBegin = (int)((lambdaBegin -lambda1[34])/step +0.5);
   int posEnd   = (int)((lambdaEnd   -lambda1[34])/step +0.5);
   double norme = 0.0;
   if (ordre[34].flag==1) {
      for(int pos=posBegin ; pos<=posEnd ; pos++) {
         norme += profile[34][pos];
      }
      if ( posEnd != posBegin) {
         // je calcule la norme
         norme = norme / (posEnd - posBegin +1);      
      } else {
         norme = 1;
      }
   } else {
      norme = 1;
   }
   return norme;
}



// Détourage des ordres 
void crop_lambda(::std::valarray<CROP_LAMBDA> &cropLambda, ::std::valarray<::std::valarray<double>> &profile, double *lambda1, 
                   ORDRE *ordre, double step, int minOrder,int maxOrder) 
{
   for (int n=minOrder; n<=maxOrder; n++) {
      if (ordre[n].flag==1) {
         if ( cropLambda[n].minLambda < cropLambda[n].maxLambda ) {
            // lambda max  -> le 0.5 est un patch pour éviter un artefact inter-ordre de 1 pixel lors de la division par la réponse ordre par ordre
                    // rappel, les fichiers de réponse individuels sont censé être calculé avec le même def_lampda
            int posBegin = (int)((cropLambda[n].minLambda -lambda1[n])/step +0.5);
            int posEnd   = (int)((cropLambda[n].maxLambda -lambda1[n])/step -0.5);
            if (posBegin < 0) {
               posBegin = 0;
            }
            if (posEnd >= (int) profile[n].size()) {
               posEnd = profile[n].size() -1;
            }
            ::std::valarray<double> cropProfile(posEnd- posBegin+1);
            for(int pos = posBegin ; pos <= posEnd; pos++ ) {
               cropProfile[pos-posBegin] = profile[n][pos];
            }
            profile[n] = cropProfile;
            lambda1[n] =  (posBegin * step) + lambda1[n];
         }
      }
   }
}

/*************************** FIND_Y_POS ****************************/
/* Recherche de la coordonnée Y de tous les ordres dont le         */
/* niveau est supérieur à seuil.                                   */
/* L'ordre de rang ordre0 est mesuré approximativement à la        */
/* coordonnée y0 dans l'image d'entrée.                            */
/* On rempli la structure ordre et on retourne le nombre           */
/* d'ordre trouvé (nb_ordre).                                      */
/* Le point central des ordres est marquée par un carré dans       */
/* l'image de vérification (check)                                 */
/*  retourne une exception conteant le message d'erreur            */
/*******************************************************************/
void find_y_pos(INFOIMAGE &buffer,PROCESS_INFO &processInfo,ORDRE *ordre,
               int &nb_ordre,int min_order,int max_order)
{
   int *profil = NULL;
   int step = 12; 

   try {
      int * profil = new int[buffer.jmax];
      PIC_TYPE * flat = buffer.pic;
      int x2 = buffer.imax / 2;
      for (int j = 0; j < buffer.jmax; j++) {
         int adr = j * buffer.imax + x2;
         double vf = (double)flat[adr] + (double)flat[adr - 1]
         + (double)flat[adr + 1] + (double)flat[adr - 2] + (double)flat[adr + 2];
         profil[j] = (int)(vf/5.0); // moyenne sur 5 colonnes
      }

      // Recherche de la coordonnée Y le plus proche de ordre_ref_y 
      int delta_y = 10000;
      int nb_ordre = 0;
      int rang = 0;
      for (int j = 3; j < buffer.jmax - 3; j++)
      {
         int v = profil[j - 2] - 2 * profil[j] + profil[j + 2]; // dérivée seconde
         if (v < -processInfo.detectionThreshold) // on a trouvé un ordre
         {
            nb_ordre++;
            if ( nb_ordre >= MAX_ORDRE ) {
               break;
            }
            
            if (abs(j - (processInfo.referenceOrderY - 1)) < delta_y)
            {
               delta_y = abs(j - (processInfo.referenceOrderY - 1));
               rang = nb_ordre; // rang de l'ordre le plus proche de la référence
            }
            j = j + step; // on saute d'un ordre (attention : l'incrément inter-ordre est codé en dur)
         }
      }

      // Deuxième passe, affectation des ordres
      delta_y = 10000;
      nb_ordre = 0;
      for (int j = 3; j < buffer.jmax - 3; j++)
      {
         int v = profil[j - 2] - 2 * profil[j] + profil[j + 2]; // dérivée seconde
         if (v < -processInfo.detectionThreshold) // on a trouvé un ordre
         {
            nb_ordre++;
            if ( nb_ordre >= MAX_ORDRE ) {
               break;
            }
            if (rang-nb_ordre + processInfo.referenceOrderNum >= min_order) // on ne calcule que les ordres au dessus de 31
            {
               int n = rang - nb_ordre + processInfo.referenceOrderNum ;
               if ( n >= min_order && n <= max_order ) {
                  ordre[n].yc = j;
                  ordre[n].flag = 1;
                  double yc = 0;
                  int cdgResult = calc_cdg_y(flat, buffer.imax, buffer.jmax, buffer.imax / 2, j - 5, j + 5, &yc);
                  if ( cdgResult == 0 ) {
                      ordre[n].yc = (int)(yc + 0.5);
                  }
               }
            }
            j = j + step;  // attention : l'incrément inter-ordre est codé en dur
         }
      }

      delete [] profil;

   } catch (std::exception e) {
      delete [] profil;
      throw e;
   }
}

/****************************** FIND_MAX ***********************************/
/* Retourne les coordonnées pixel (x,y) du point de plus grande intensité  */
/* dans l'image - utilisé pour trouver automatiquement la position         */ 
/* de la raie à 5852 A du néon.                                            */
/***************************************************************************/
int find_max(INFOIMAGE *buffer, int *x,int *y)
{
int i,j,imax,jmax;
PIC_TYPE max;
int px,py;
PIC_TYPE *p;

if (buffer->pic==NULL) return 1;

p=buffer->pic;
imax=buffer->imax;
jmax=buffer->jmax;

max=-32000;

for (j=0;j<jmax;j++)
   {
   for (i=0;i<imax;i++)
      {
      if (p[i+j*imax]>max)
         {
         px=i;
         py=j;
         max=p[i+j*imax]; 
         }
      }
   }

*x=px+1;  // on est en coordonnées image (origine 1,1)
*y=py+1;
return 0;
}

/******************** GAUSS_CONVOL *********************/
/* Convolution par une fonction gaussienne             */
/*******************************************************/
int gauss_convol(INFOIMAGE *buffer, double sigma)
{
int i,j,k,imax,jmax;
int i1,j1;
double val;
double somme;
int largeur,largeur2;
double filtre[130];
double reste,ilarg;
int longueur,adr,adr2;
PIC_TYPE *p;
double *buf;

if (buffer->pic==NULL) return 1;
 
if (sigma<=0.0) return 0; // on ne convolu pas !

if (sigma>25.0) sigma=25.0; 

largeur=(int)(5.0*sigma+1.0);
if (largeur<3) largeur=3;

reste=(double)fmod((double)largeur,2.0);
if (reste==0.0) largeur=largeur+1;

largeur2=(largeur-1)/2;    // contour de l'image

// ---------------------
// calcul du filtre 
// ---------------------
somme=0.0;
for (i=0;i<largeur;i++)
   {
   ilarg=(double)(i-largeur2);
   filtre[i]=exp(-ilarg*ilarg/2./sigma/sigma);
   somme=somme+filtre[i];
   }
for (i=0;i<largeur;i++) filtre[i]=filtre[i]/somme;

imax=buffer->imax;
jmax=buffer->jmax;
longueur=sizeof(double)*imax*jmax;

if ((buf=(double *)malloc((size_t)longueur))==NULL)
   {
   printf("\nPas assez de mémoire\n");
   return 1;
   }

p=buffer->pic;

// -----------------------------
// balayage suivant l'axe X 
// -----------------------------
for (j=0;j<jmax;j++)
   {
   adr=(int)j*imax;
   for (i=0;i<imax;i++)
      {
      val=0.0;
      for (k=0;k<largeur;k++)
	      {
	      i1=i+k-largeur2;
	      if (i1<0) i1=0;
	      if (i1>imax-1) i1=imax-1;
	      adr2=adr+i1;
	      val+=filtre[k]*(double)(*(p+adr2));
	      }
      *(buf+(adr+i))=val;
      }
   }

// -----------------------------
// balayage suivant l'axe Y 
// -----------------------------
for (i=0;i<imax;i++)
   {
   for (j=0;j<jmax;j++)
      {
      val=0.0;
      adr=j*imax+i;
      for (k=0;k<largeur;k++)
	      {
	      j1=j+k-largeur2;
	      if (j1<0) j1=0;
	      if (j1>jmax-1) j1=jmax-1;
	      adr2=j1*imax+i;
	      val+=filtre[k]*(*(buf+adr2));
	      }
      *(p+adr)=(PIC_TYPE)val;
      }
   }

free(buf);

return 0;
}

/********************* GRADY ***********************/
/* Gradient suivant l'axe Y                        */
/* flag (1 ou 2) = sens du gradient                */ 
/***************************************************/
int grady(INFOIMAGE *buffer, int flag)
{
int imax,jmax,i,j;
PIC_TYPE *buf,*p;
int longueur,adr;

if (buffer->pic==NULL) return 1;

imax=buffer->imax;
jmax=buffer->jmax;

longueur=sizeof(PIC_TYPE)*imax*jmax;
if ((buf=(PIC_TYPE *)calloc(longueur,1))==NULL)
   {
   printf("\nPas assez de memoire\n");
   return 1;
   }

p=buffer->pic;

for (i=0;i<imax;i++)
   {
   for (j=0;j<jmax-1;j++)
      {
      adr=(int)j*imax+(int)i;
      if (flag==1)
	     *(buf+adr)=*(p+adr)-*(p+(adr+imax));
      else
	     *(buf+adr)=*(p+(adr+imax))-*(p+adr);
      }
   }
memmove(p,buf,longueur);
free(buf);
return 0;
}


/********************* GRADY2 **********************/
/* Gradient suivant l'axe Y                        */
/* flag (1 ou 2) = sens du gradient                */
/* Fonction nouvelle V1.6 (dérivée mieux lissée    */
/* et centrée par rapport à grady)                 */
/***************************************************/
int grady2(INFOIMAGE *buffer, int flag)
{
int imax,jmax,i,j;
PIC_TYPE *buf,*p;
int longueur,adr;

if (buffer->pic==NULL) return 1;

imax=buffer->imax;
jmax=buffer->jmax;

longueur=sizeof(PIC_TYPE)*imax*jmax;
if ((buf=(PIC_TYPE *)calloc(longueur,1))==NULL)
   {
   printf("\nPas assez de memoire\n");
   return 1;
   }

p=buffer->pic;

for (i=0;i<imax;i++)
   {
   for (j=2;j<jmax-2;j++)
      {
      adr=(int)j*imax+(int)i;
      if (flag==1)
	     *(buf+adr)=(PIC_TYPE)(.5*(double)(*(p+adr-imax)-*(p+(adr+imax)))+.25*(double)(*(p+adr-2*imax)-*(p+(adr+2*imax))));
      else
	     *(buf+adr)=(PIC_TYPE)(.5*(double)(*(p+adr+imax)-*(p+(adr-imax)))+.25*(double)(*(p+adr+2*imax)-*(p+(adr-2*imax))));
      }
   }
memmove(p,buf,longueur);
free(buf);
return 0;
}

/******************************** CALC_CDG_Y *************************************/
/* Calcule le centre de gravité suivant l'axe colonne entre les bornes y1 et y2  */
/* dans l'image pointée par p (coordonnées mémoire - origine (0,0)).             */
/* La colonne analysée est de rang x.                                            */
/* La coordonnées y est retournée dans pos_y                                     */
/*********************************************************************************/
int calc_cdg_y(PIC_TYPE *p,int imax,int jmax,int x,int y1,int y2,double *pos_y)
{
   int j;
   double v;
   double s1=0.0;
   double s2=0.0;

   for (j=y1;j<=y2;j++) {
      if (j>=0 && j<jmax) {
         v=(double)p[x+j*imax];
         s1=s1+(double)j*v;
         s2=s2+v;
      }
      else {
         return 1;
      }
   }
   if (s2==0)
      *pos_y=0;
   else
      *pos_y=s1/s2;

   return 0;
}

/************************************* TRACK_ORDER ************************************/
/* Détecte la trace de l'ordre de rang n, puis la modélise par un polynôme de degré 4 */
/* wide_y doit être inférieur à l'écart minimal typique entre deux ordres             */
/* en pixels suivant l'axe Y.                                                         */
/**************************************************************************************/ 
void track_order(INFOIMAGE *buffer,int imax, int jmax, int wide_y,ORDRE *ordre,int n)
{
   int k,py,size;
   double pos_y;
   double *x = NULL;
   double *y = NULL;
   double *w = NULL;
   double *a = NULL;
   int ic=imax/2;

   try {      
      size=abs(ordre[n].max_x-ordre[n].min_x+1);

      // j'ajoute 1 par securite
      x = new double[size+1];
      y = new double[size+1];
      w = new double[size+1];

      // -------------------------------------------
      // Détection de la trace de l'ordre n
      // -------------------------------------------
      k=0;
      py=int(ordre[n].yc+.5);
      for (int i=ic;i<ordre[n].max_x && k <= size ;i++) {
         int cgdResult = calc_cdg_y(buffer->pic,imax,jmax,i,py-wide_y/2,py+wide_y/2,&pos_y);  // centre de gravité suivant Y
         if ( cgdResult == 1 ) {
            char message[1024];
            sprintf(message, "Error calc_cdg_y() in track_order ordernum: %d ",n);
            throw ::std::exception(message);
         }
         if (abs(int(pos_y)-py)>5) continue; // on a détecté un point aberrant

         x[k]=(double)i;
         y[k]=pos_y;
         w[k]=1.0;
         py=(int)(pos_y+.5);
         k++;
      } 

      py=int(ordre[n].yc+.5);
      for (int i=ic-1;i>=ordre[n].min_x-1 && k <= size ;i--) {
         calc_cdg_y(buffer->pic,imax,jmax,i,py-wide_y/2,py+wide_y/2,&pos_y); // centre de gravité suivant Y
         if (abs(int(pos_y)-py)>5) continue; // on a détecté un point aberrant
         x[k]=(double)i;
         y[k]=pos_y;
         w[k]=1.0;
         py=(int)(pos_y+.5);
         k++;
      } 

      // ---------------------------------------
      // Ajustement du polynôme
      // ---------------------------------------
      if ( k <= size) {
         double rms = 0.0;
         a = new double[POLY_ORDER_DEGREE + 1];
         k = size;
         for (int i=0; i<=POLY_ORDER_DEGREE; i++) a[i]=0.0;

         fitPoly(k,POLY_ORDER_DEGREE,x,y,w,a,&rms);
         for (int i=0;i<=POLY_ORDER_DEGREE;i++) {
            ordre[n].poly_order[i]=a[i];
         }
         ordre[n].rms_order=rms;
      } else {
         // cas ou la recherhe dépasse les bornes ordre[n].min_x , ordre[n].miax_x
         ordre[n].flag = 0;
      }
      delete [] x;
      delete [] y;
      delete [] w; 
      delete [] a;  

   } catch (std::exception e) {
      delete [] x;
      delete [] y;
      delete [] w; 
      delete [] a;  
      throw e;
   }
}

/**************************************** GET_CENTRAL_WAVE *******************************************/
/* Retourne la longueur d'onde centrale de l'ordre k (à la coordonnée imax/2)                        */    
/*****************************************************************************************************/
double get_central_wave(int imax,double posx,double dx,int k,INFOSPECTRO spectro)
{
   double alpha=spectro.alpha*PI/180.0;
   double m=spectro.m;
   double focale=spectro.focale;
   double pixel=spectro.pixel;
   double lambda;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      double gamma=spectro.gamma*PI/180.0;
      double beta=(posx-(double)imax/2-dx)*pixel/focale;
      lambda=cos(gamma)*(sin(alpha)+sin(beta+alpha))/m/(double)k*1.0e7;
   } else {
      double beta = spectro.beta*PI/180.0;;
      lambda=(sin(alpha)+sin(beta))/m/(double)k*1.0e7;
   }

   return lambda;
}

/********************************* FLAT_RECTIF ***********************************/
/* Division par le flat-field (au niveau profil spectral)                        */
/* Le nom du profil à divisé est n_objet, le nom du profil flat-field est n_flat */
/* La variable i contient le numéro de l'ordre traité                            */
/* Le résultat est un profil de nom générique n_objet_xxx                        */
/*********************************************************************************/
int flat_rectif(int i,char *n_objet,char *n_flat,ORDRE *ordre)
{
FILE *hand_objet0,*hand_flat,*hand_objet;
char nom_objet0[_MAX_PATH],nom_flat[_MAX_PATH],nom_objet[_MAX_PATH];
char ligne[256];
int pixel;
double objet0,flat,objet;

if (ordre[i].flag==1)
   {
   sprintf(nom_objet0,"%s0_%d.dat",n_objet,i);
   sprintf(nom_flat,"%s0_%d.dat",n_flat,i);
   sprintf(nom_objet,"%s_%d.dat",n_objet,i);

   if ((hand_objet0=fopen(nom_objet0,"r") ) == NULL) 
      {
      printf("\nLe fichier %s est introuvable.\n",nom_objet0);
      return 1;
      }

   if ((hand_flat=fopen(nom_flat,"r") ) == NULL) 
      {
      printf("\nLe fichier %s est introuvable.\n",nom_flat);
      return 1;
      }

   if ((hand_objet=fopen(nom_objet,"wt"))==NULL) 
      {
      printf("\nProblème d'écriture du fichier %s.\n",nom_objet);
      return 1;
      }

   int k=0;
   while (fscanf(hand_objet0,"%d %lf",&pixel,&objet0)!=EOF && k!=20000)
      {
      fscanf(hand_flat,"%d %lf",&pixel,&flat);
      if (flat==0)
         objet=0.0;
      else
         objet=(double)objet0/(double)flat;
      sprintf(ligne,"%d\t%lf\n",pixel,objet);
      fwrite(ligne,strlen(ligne),1,hand_objet);
      k++;
      }

   fclose(hand_objet0);
   fclose(hand_flat);
   fclose(hand_objet);
   }

return 0;
}

/********************************* FLAT_RECTIF ***********************************/
/* Division par le flat-field (au niveau profil spectral)                        */
/* Le nom du profil à divisé est n_objet, le nom du profil flat-field est n_flat */
/* La variable i contient le numéro de l'ordre traité                            */
/* Le résultat est un profil de nom générique n_objet_xxx                        */
/*********************************************************************************/
void flat_rectif(std::valarray<double> &object ,std::valarray<double> &flat, std::valarray<double> &out)
{
   for (unsigned i=0; i < object.size(); i++ ) { 
      if (flat[i]==0) {
         out[i]=0.0;
      } 
      else {
         out[i]=object[i]/flat[i];
      }
   }
}

/************************************* CALIB_PREDICTION **************************************/
/* Calcul de la position (en pixel) dans un ordre donné d'un longueur d'onde donnée.         */
/* Il faut fournir en entrée la position X de la raie de référence (posx0).                  */
/* lambda0 et ordre0 sont les longueurs d'onde de la raie de référence et l'ordre nominal    */
/* La fonction retourne le décalage en X entre la position thérorique attendue de cette      */
/* raie et la position effectivement observée (ddx).                                         */
/* La position théorique est marquée dans l'image de vérification par un carré en pointillé. */
/*********************************************************************************************/
int calib_prediction(double lambda0,int ordre0,int imax, int jmax,double posx0,
                     double *ddx,INFOSPECTRO spectro,::std::list<double> lineList )
{
   double k;
   k=(double)ordre0;
   double m=spectro.m;
   double focale=spectro.focale;
   double pixel=spectro.pixel;
   double alpha=spectro.alpha*PI/180.0;     
   double beta,beta2,posx;
   double x_mesure=posx0;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      double gamma=spectro.gamma*PI/180.0;
      beta=asin((k*m*lambda0/1.0e7-cos(gamma)*sin(alpha))/cos(gamma));
      beta2=beta-alpha;
      posx=focale*beta2/pixel+(double)imax/2.0;
   } else {
      double beta = spectro.beta*PI/180.0;       
      posx = (lambda0 - (sin(alpha)+sin(beta))*1.0e7/ (k*m)) / (pixel *1.0e7 *cos(beta)/(m *k * focale)) + imax/2.0;
   }
   double dx=x_mesure-posx;
   *ddx=dx;

   return(0);
}

/******************************************* COMPUTE_POS *****************************************/
/* Calcule la position d'une raie de longueur d'onde lam pour l'ordre k dans le profil spectral. */
/* Tiens compte du décalage dx trouvée avec la raie du Ne à 5852 A.                              */
/*************************************************************************************************/
double compute_pos(double k, double lambda, double dx, INFOSPECTRO &spectro)
{
   
   double alpha=spectro.alpha*PI/180.;
   int xc=spectro.imax/2;
   double beta,beta2,posx;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      double gamma=spectro.gamma*PI/180.0;
      beta=asin((k*spectro.m*lambda/1.0e7-cos(gamma)*sin(alpha))/cos(gamma));
      beta2=beta-alpha;
      posx=spectro.focale*beta2/spectro.pixel+(double)xc+dx;
   } else {
      beta = spectro.beta*PI/180.0;       
      posx = (lambda - (sin(alpha)+sin(beta))*1.0e7/(k*spectro.m)) / (spectro.pixel *1.0e7 *cos(beta)/(spectro.m *k * spectro.focale)) + (double) xc +dx;
   }
   return(posx);
}


/******************* TRANSLATE_LINE *******************/
/* Translation d'une ligne de l'image                 */
/* Line : numero de la ligne (en coordonnees mémoire) */
/* delta_x : valeur de la translation                 */
/******************************************************/
void translate_line(std::valarray<PIC_TYPE> &p, int imax, int jmax, int line,double delta_x, int spline_deg)
{
   int SplineDegree = spline_deg;

   int imax1 = imax;
   int jmax1 = 2; // important, sinon plantage
   float *buf_in = NULL;
   float *buf_out = NULL;

   try {
      int intueur=imax1*jmax1;
      buf_in = new float[intueur];  // le vecteur de calcul d'entrée (colonne à interpoler)
      buf_out = new float[intueur]; // le vecteur de calcul de sortie (colonne interpolée)

      //  TODO voir pourquoi il faut initiliser ces tableaux
      for (int j = 0; j < intueur; j++){
         buf_in[j] = 0; 
         buf_out[j] = 0;
      }
      
      int i,adr;
      int j=line; // rang de la ligne à translater

      // Génération du vecteur d'entrée (une ligne de longueur imax)
      for (i=0; i < imax; i++)
      {
         adr=j*imax+i;
         buf_in[i]=(float)p[adr];
         buf_out[i]=0.0F;
      }

      // Calcul des coefficients d'interpolation sur le vecteur d'entrée (taille imax x 2)
      SamplesToCoefficients(buf_in, imax1, jmax1, SplineDegree);

      // On visite les pixels du vecteur d'arrivée
      int x, y;
      for (y=0;y<1;y++)
      {
         for (x=0;x<imax1;x++)
         {
            double x1,y1;
            x1=(double)x-delta_x;
            y1=0.0;
            if (x1<0 || x1>(double)(imax-1) || y1<0 || y1>(double)(jmax-1))
               buf_out[x]=0.0F;
            else 
            {
               float v=(float)InterpolatedValue(buf_in,imax1,jmax1,
                  x1,y1,SplineDegree);
               buf_out[x] = v; 
            }
         }
      }

      // On copie la ligne translatée dans le buffer
      for (i=0; i<imax; i++)
      {
         adr=j*imax+i;
         p[adr]=(int)buf_out[i];
      }

      delete [] buf_in;
      delete [] buf_out;
      return;
   } catch (std::exception &e) {
      delete [] buf_in;
      delete [] buf_out;
      throw e;
   }

}


///////////////////////////////////////////////////////
#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif
///////////////////////////////////////////////////////

/***************** INTPOL_SPLINE16 ******************/
/* Fonction d'interpollation spline d'ordre 16      */
/****************************************************/
void intpol_spline16(double x,double *a,int ndim)
{ 
a[3] = ( ( 1.0/3.0  * x - 1.0/5.0 ) * x -   2.0/15.0 ) * x;	
a[2] = ( ( 6.0/5.0 - x     ) * x +   4.0/5.0 ) * x;				
a[1] = ( ( x - 9.0/5.0 ) * x -   1.0/5.0     ) * x + 1.0;		
a[0] = ( ( -1.0/3.0 * x + 4.0/5.0     ) * x -   7.0/15.0 ) * x ;
}

// Polynôme cubique avec paramètre A
// A = -1: traitement dur; A = - 0.5 traitement homogène (recommandé !)
// attention x >= 0
#define	A	(-0.5)
// 0 <= x < 1
static double cubic01( double x )
{
return	(( A + 2.0 )*x - ( A + 3.0 ))*x*x +1.0;
}
// 1 <= x < 2
static double cubic12( double x )
{
return	(( A * x - 5.0 * A ) * x + 8.0 * A ) * x - 4.0 * A;
}
#undef A

/****************** INTPOL_CUBIC *******************/
/* Fonction d'interpollation bicubique             */
/***************************************************/ 
void intpol_cubic(double x,double *a,int ndim)														
{											
a[3] = cubic12( 2.0 - x);
a[2] = cubic01( 1.0 - x);
a[1] = cubic01( x );
a[0] = cubic12( x + 1.0);
}

/////////////// SINC0  ///////////////////
double sinc0( double x )
{
x*=PI;
if(x != 0.0) return(sin(x) / x);
return(1.0);
}

/****************** INTPOL_SINC ********************/
/* Fonction d'interpollation sinc                  */
/***************************************************/
void intpol_sinc(double x,double *a,int ndim)														
{																
int idx;
double xadd;
for (idx=0,xadd=ndim/2-1.0+x;idx<ndim/2;xadd-=1.0)			
   {						
	a[idx++] = sinc0( xadd ) * sinc0( xadd / ( ndim / 2 ));	
	}				
for (xadd=1.0-x;idx<ndim;xadd+=1.0)
   {					
	a[idx++] = sinc0( xadd ) * sinc0( xadd / ( ndim / 2 ));	
   }
}

/******************* TRANSLATE_COL_1 *********************/
/* Translation d'une colonne de l'image                */
/* Colonne : numéro de la colonne (en coord. mémoire)  */
/* delta_y : valeur de la translation                  */
/* Version 1.6 (V1.6)                                  */
/* Plusieurs modes d'interpollation disponibles        */
/* via la variable interne mode :                      */
/* mode = 0 -> bilineaire simple                       */
/* mode = 1 -> bicubique (bon choix avec A = 0.5)      */
/* mode = 2 -> spline 32 pixels (bons résultats aussi) */
/* mode = 3 -> sinc (trop lent)                        */
/*******************************************************/

int translate_col_1(INFOIMAGE *buffer, int colonne, double delta_y, 
                    ORDRE *ordre, int n, int jmax_result, 
                    std::valarray<PIC_TYPE> &buf_result)
{
int imax,jmax,i,j,adr;
PIC_TYPE *p,*p2,*tampon;
double x,y;

int mode=0;

if (buffer->pic==NULL) return 1;

int hauteur = jmax_result; // hauteur du crop dans le buffer d'entré
imax=buffer->imax;
int jmin =(int)(ordre[n].yc - hauteur/2);
jmax=(int)(ordre[n].yc + hauteur/2);
int imax1=imax-1;
int jmax1=jmax-1;


if ((tampon=(PIC_TYPE *)calloc(jmax,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

p=buffer->pic;
p2=&tampon[jmin];

i=colonne;

for (j=jmin;j<jmax;j++,p2++)
	{
   x=(double)i;
	y=(double)j-delta_y;
  
   if ((y>=0) && (y<(double)jmax))
      {
      if (mode==0) // bilinéaire standard
         {
         int ii,jj,ii1,jj1;
         double val1,val2,val3,val4,value;
         PIC_TYPE v1,v2,v3,v4;
 
	      ii=(int)x;
	      jj=(int)y;
	      ii1=min(ii+1,imax1);
	      jj1=min(jj+1,jmax1);
         val1=0.0;
         val2=1.0;
	      val3=y-(double)jj;
	      val4=1.0-val3;
 
         adr=(int)ii+(int)jj*imax;
	      v1=*(p+adr);
	      adr=(int)ii1+(int)jj*imax;
	      v2=*(p+adr);
	      adr=(int)ii+(int)jj1*imax;
	      v3=*(p+adr);
	      adr=(int)ii1+(int)jj1*imax;
	      v4=*(p+adr);
	      value=val2*(val4*(double)v1 + val3*(double)v3)
	            +val1*(val4*(double)v2 + val3*(double)v4);
	      if (value>INT_MAX)
	         *p2=INT_MAX;
	      else if (value<INT_MIN)
	         *p2=INT_MIN;
	      else
	         *p2=(PIC_TYPE)(value+.5);
         }
      else if (mode==1) // bicubique
         { 
         double Dx,Dy;
         double w[16],yr[16],rd;
         double weight;
         int xc,yc,xs,ys,n2;
         int k,kk,ii2,jj2;
         int ndim;

         ndim=4;
         n2=ndim/2;

  		   xc=(int)floor(x);
         Dx=0.0;
	 	   yc=(int)floor(y);
         Dy=y-(double)yc;
		   ys=yc+1-n2; 
		   xs=xc+1-n2; 
         intpol_cubic(Dx,w,ndim);
		   for (k=0;k<ndim;k++)										
		      {																
            rd=0.0;																		
			   for (kk=0;kk<ndim;kk++)										
			      {															
				   weight=w[kk];
               ii2=min(xs+kk,imax1);
					jj2=min(ys+k,jmax1);				
               ii2=max(ii2,0);
					jj2=max(jj2,0);				
	            adr=(int)ii2+(int)(jj2)*imax;
               rd+=(double)*(p+adr)*weight;
               }
            yr[k]=rd;
            }
         intpol_cubic(Dy,w,ndim);
		   rd=0.0;																												
		   for (kk=0;kk<ndim;kk++)											
		      {																
			   weight=w[kk];											
			   rd+=yr[kk]*weight;										
		      }
	      if (rd>INT_MAX)
	         *p2=INT_MAX;
	      else if (rd<INT_MIN)
	         *p2=INT_MIN;
	      else
	         *p2=(PIC_TYPE)(rd+.5);
         }
      else if (mode==2)  // spline 16 pixels
         {
         double Dx,Dy;
         double w[16],yr[16],rd;
         double weight;
         int xc,yc,xs,ys,n2;
         int k,kk,ii2,jj2;
         int ndim;

         ndim=4;
         n2=ndim/2;

         xc=(int)floor(x);
         Dx=0.0;
         yc=(int)floor(y);
         Dy=y-(double)yc;
         ys=yc+1-n2; 
         xs=xc+1-n2;
         intpol_spline16(Dx,w,ndim);
         for (k=0;k<ndim;k++)										
            {																
            rd=0.0;																		
            for (kk=0;kk<ndim;kk++)										
	            {															
	            weight=w[kk];
               ii2=min(xs+kk,imax1);
	            jj2=min(ys+k,jmax1);				
               ii2=max(ii2,0);
	            jj2=max(jj2,0);				
	            adr=(int)ii2+(int)(jj2)*imax;
               rd+=(double)*(p+adr)*weight;
               }
            yr[k]=rd;
            }
         intpol_spline16(Dy,w,ndim);
         rd=0.0;																												
         for (kk=0;kk<ndim;kk++)											
            {																
            weight=w[kk];											
            rd+=yr[kk]*weight;										
            }
         if (rd>INT_MAX)
         *p2=INT_MAX;
         else if (rd<INT_MIN)
         *p2=INT_MIN;
         else
         *p2=(PIC_TYPE)(rd+.5);
         }
      else if (mode==3)  // sinc
         {
         double Dx,Dy;
         double w[16],yr[16],rd;
         double weight;
         int xc,yc,xs,ys,n2;
         int k,kk,ii2,jj2;
         int ndim;

         ndim=16;
         n2=ndim/2;

  		   xc=(int)floor(x);
         Dx=0.0;
	 	   yc=(int)floor(y);
         Dy=y-(double)yc;
		   ys=yc+1-n2; // smallest y-index used for interpolation
		   xs=xc+1-n2; // smallest x-index used for interpolation
         intpol_sinc(Dx,w,ndim);
		   for (k=0;k<ndim;k++)										
		      {																
            rd=0.0;																		
			   for (kk=0;kk<ndim;kk++)										
			      {															
				   weight=w[kk];
               ii2=min(xs+kk,imax1);
					jj2=min(ys+k,jmax1);				
               ii2=max(ii2,0);
					jj2=max(jj2,0);				
	            adr=(int)ii2+(int)(jj2)*imax;
               rd+=(double)*(p+adr)*weight;
               }
            yr[k]=rd;
            }
         intpol_sinc(Dy,w,ndim);
		   rd=0.0;																												
		   for (kk=0;kk<ndim;kk++)											
		      {																
			   weight=w[kk];											
			   rd+=yr[kk]*weight;										
		      }
	      if (rd>INT_MAX)
	         *p2=INT_MAX;
	      else if (rd<INT_MIN)
	         *p2=INT_MIN;
	      else
	         *p2=(PIC_TYPE)(rd+.5);
         }
      }
	}

for (j=jmin;j<jmax;j++)
   {
   adr=(int)(j-jmin)*imax+(int)i;
   //*(p+adr)=tampon[j];
   buf_result[adr]=tampon[j];
   }

free(tampon);
return 0;
}


// /////////////////////////////////////////////
// InitialCausalCoefficient
// /////////////////////////////////////////////
inline double InitialCausalCoefficient(double *c,        /* coefficients */
                                int DataLength,   /* number of coefficients */
                                double z,         /* actual pole */
                                double Tolerance  /* admissible relative error */
                                )

{
   double Sum,zn,z2n,iz;
   int n,Horizon;

   // This initialization corresponds to mirror boundaries 
   Horizon=DataLength;
   if (Tolerance == DBL_EPSILON) {
      Horizon= 21; 
   } else {
      if (Tolerance > 0.0) {
         Horizon=(int)ceil(log(Tolerance)/log(fabs(z)));
      }
   }
   if (Horizon < DataLength) 
   {
      // Accelerated loop 
      zn=z;
      Sum=c[0];
      for (n = 1; n < Horizon; n++) 
      {
         Sum += zn * c[n];
         zn *= z;
      }
      return(Sum);
   }
   else 
   {
      // full loop 
      zn = z;
      iz = 1.0 / z;
      z2n = pow(z, (double)(DataLength - 1L));
      Sum = c[0] + z2n * c[DataLength - 1L];
      z2n *= z2n * iz;
      for (n = 1; n <= DataLength - 2; n++) 
      {
         Sum += (zn + z2n) * c[n];
         zn *= z;
         z2n *= iz;
      }
      return(Sum / (1.0-zn*zn));
   }
}

// //////////////////////////////////////////////////
// InitialAntiCausalCoefficient
// //////////////////////////////////////////////////
inline double InitialAntiCausalCoefficient(double *c,  		// coefficients 
                                    int	DataLength,	// number of samples or coefficients 
                                    double z		      // actual pole 
                                    )

{ 
   // this initialization corresponds to mirror boundaries 
   return((z / (z * z - 1.0)) * (z * c[DataLength - 2] + c[DataLength - 1]));
} 

        

inline void ConvertToInterpolationCoefficients(double *c,	      // input samples --> output coefficients 	
                                        int DataLength,  // number of samples or coefficients 
                                        double *z,       // poles 
                                        int NbPoles,     // number of poles 
                                        double Tolerance // admissible relative error 
                                        )
{
   double Lambda=1.0;
   int n,k;

   /* Special case required by mirror boundaries */
   if (DataLength==1) return;

   /* Compute the overall gain */
   for (k=0; k < NbPoles; k++) Lambda=Lambda*(1.0-z[k])*(1.0-1.0/z[k]);

   /* Apply the gain */
   for (n=0; n < DataLength; n++) c[n] *= Lambda;

   /* Loop over all poles */
   for (k=0; k< NbPoles; k++) 
   {
      /* Causal initialization */
      c[0]=InitialCausalCoefficient(c,DataLength,z[k],Tolerance);

      /* Causal recursion */
      for (n=1;n<DataLength;n++) c[n]+=z[k]*c[n-1];

      /* Anticausal initialization */
      c[DataLength-1]=InitialAntiCausalCoefficient(c,DataLength,z[k]);

      /* Anticausal recursion */
      for (n=DataLength-2;0<=n;n--) c[n]=z[k]*(c[n+1]-c[n]);
   }
}



// ///////////////////////////////////////////////////////////////////////
// SamplesToCoefficients
// //////////////////////////////////////////////////////////////////////
void SamplesToCoefficients(float *Image,		/* in-place processing */
                                 int Width,		    /* width of the image */
                                 int Height,		/* height of the image */
                                 int SplineDegree   /* degree of the spline model */
                                 )
{
   double *Line = NULL;
   double *Pole = NULL;
   int	NbPoles;

   Pole = new double[4];

   try {
      // recover the poles from a lookup table 
      switch (SplineDegree) {
              case 2:
                 NbPoles = 1;
                 Pole[0] = sqrt(8.0) - 3.0;
                 break;
              case 3:
                 NbPoles = 1;
                 Pole[0] = sqrt(3.0) - 2.0;
                 break;
              case 4:
                 NbPoles = 2;
                 Pole[0] = sqrt(664.0 - sqrt(438976.0)) + sqrt(304.0) - 19.0;
                 Pole[1] = sqrt(664.0 + sqrt(438976.0)) - sqrt(304.0) - 19.0;
                 break;
              case 5:
                 NbPoles = 2;
                 Pole[0] = sqrt(135.0 / 2.0 - sqrt(17745.0 / 4.0)) + sqrt(105.0 / 4.0)
                    - 13.0 / 2.0;
                 Pole[1] = sqrt(135.0 / 2.0 + sqrt(17745.0 / 4.0)) - sqrt(105.0 / 4.0)
                    - 13.0 / 2.0;
                 break;
              case 6:
                 NbPoles = 3;
                 Pole[0] = -0.48829458930304475513011803888378906211227916123938;
                 Pole[1] = -0.081679271076237512597937765737059080653379610398148;
                 Pole[2] = -0.0014141518083258177510872439765585925278641690553467;
                 break;
              case 7:
                 NbPoles = 3;
                 Pole[0] = -0.53528043079643816554240378168164607183392315234269;
                 Pole[1] = -0.12255461519232669051527226435935734360548654942730;
                 Pole[2] = -0.0091486948096082769285930216516478534156925639545994;
                 break;
              case 8:
                 NbPoles = 4;
                 Pole[0] = -0.57468690924876543053013930412874542429066157804125;
                 Pole[1] = -0.16303526929728093524055189686073705223476814550830;
                 Pole[2] = -0.023632294694844850023403919296361320612665920854629;
                 Pole[3] = -0.00015382131064169091173935253018402160762964054070043;
                 break;
              case 9:
                 NbPoles = 4;
                 Pole[0] = -0.60799738916862577900772082395428976943963471853991;
                 Pole[1] = -0.20175052019315323879606468505597043468089886575747;
                 Pole[2] = -0.043222608540481752133321142979429688265852380231497;
                 Pole[3] = -0.0021213069031808184203048965578486234220548560988624;
                 break;
              default:
                 //throw ::std::exception("Invalid spline degree") ;
                 break;
      }

      /* convert the image samples into interpolation coefficients */
      /* in-place separable process, aint x */
      Line = new double[Width];
      for (int y = 0; y < Height; y++)   
      {
         for (int x=0; x<Width;x++)  // GetRow
         {
            int adr=y*Width+x;
            Line[x]=(double)Image[adr];
         }
         // attention Christian a redefini DBL_EPSILON=0.0  (C++ a deja defini DBL_EPSILON dans float.h)
         //ConvertToInterpolationCoefficients(Line, Width, Pole, NbPoles, 1000.0 *DBL_EPSILON);
         ConvertToInterpolationCoefficients(Line, Width, Pole, NbPoles, 0.0);
         for (int x=0; x<Width;x++)  // PutRow
         {
            int adr=y*Width+x;
            Image[adr]=(float)Line[x];
         }
      }
      delete [] Line;

      // in-place separable process, aint y 
      Line = new double[Height];
      for (int x = 0; x < Width; x++) 
      {
         for (int y=0;y<Height;y++)   // GetColumm
         {
            int adr=y*Width+x;
            Line[y]=(double)Image[adr]; 
         }
         // attention Christian a redefini DBL_EPSILON=0.0  (C++ a deja defini DBL_EPSILON dans float.h)
         //ConvertToInterpolationCoefficients(Line, Height, Pole, NbPoles, 1000.0 *DBL_EPSILON);
         ConvertToInterpolationCoefficients(Line, Height, Pole, NbPoles, 0.0);
         for (int y=0;y<Height;y++)   // PutColumm
         {
            int adr=y*Width+x;
            Image[adr]=(float)Line[y]; 
         }
      }
      
      delete [] Pole;
      delete [] Line;
      return;
   } catch (std::exception &e) {
      delete [] Pole;
      delete [] Line;
      throw e;
   }

}

// //////////////////////////////////////////////////////////////
// InterpolatedValue
// (le degré 9 est recommandé pour un résultat optimal)
// //////////////////////////////////////////////////////////////
double InterpolatedValue(float *Bcoeff,	  /* input B-spline array of coefficients */
                                int Width,		  /* width of the image */
                                int Height,		  /* height of the image */
                                double x,		  /* x coordinate where to interpolate */
                                double y,		  /* y coordinate where to interpolate */
                                int SplineDegree  /* degree of the spline model */
                                )
{
   double *xWeight= NULL;
   double *yWeight=NULL;
   double interpolated;
   double w, w2, w4, t, t0, t1;
   int *xIndex=NULL;
   int *yIndex=NULL;
   int	Width2 = 2 * Width - 2, Height2 = 2 * Height - 2;
   int	i, j, k;

   xWeight=new double[10];
   yWeight=new double[10];
   xIndex=new int[10];
   yIndex=new int[10];

   try {
      /* compute the interpolation indexes */
      int b = SplineDegree & 1;
      if (b==1) 
      {
         i = (int)floor(x) - SplineDegree / 2;
         j = (int)floor(y) - SplineDegree / 2;
         for (k = 0; k <= SplineDegree; k++) 
         {
            xIndex[k] = i++;
            yIndex[k] = j++;
         }
      }
      else 
      {
         i = (int)floor(x + 0.5) - SplineDegree / 2;
         //j = (int)(floor(y + 0.5) - SplineDegree / 2);
         double j1 = floor(y + 0.5);
         double j2 = SplineDegree / 2;
         j = (int)(j1 - j2);
         for (k = 0; k <= SplineDegree; k++) 
         {
            xIndex[k] = i++;
            yIndex[k] = j++;
         }
      }

      /* compute the interpolation weights */
      switch (SplineDegree) {
              case 2:
                 /* x */
                 w = x - (double)xIndex[1];
                 xWeight[1] = 3.0 / 4.0 - w * w;
                 xWeight[2] = (1.0 / 2.0) * (w - xWeight[1] + 1.0);
                 xWeight[0] = 1.0 - xWeight[1] - xWeight[2];
                 /* y */
                 w = y - (double)yIndex[1];
                 yWeight[1] = 3.0 / 4.0 - w * w;
                 yWeight[2] = (1.0 / 2.0) * (w - yWeight[1] + 1.0);
                 yWeight[0] = 1.0 - yWeight[1] - yWeight[2];
                 break;
              case 3:
                 /* x */
                 w = x - (double)xIndex[1];
                 xWeight[3] = (1.0 / 6.0) * w * w * w;
                 xWeight[0] = (1.0 / 6.0) + (1.0 / 2.0) * w * (w - 1.0) - xWeight[3];
                 xWeight[2] = w + xWeight[0] - 2.0 * xWeight[3];
                 xWeight[1] = 1.0 - xWeight[0] - xWeight[2] - xWeight[3];
                 /* y */
                 w = y - (double)yIndex[1];
                 yWeight[3] = (1.0 / 6.0) * w * w * w;
                 yWeight[0] = (1.0 / 6.0) + (1.0 / 2.0) * w * (w - 1.0) - yWeight[3];
                 yWeight[2] = w + yWeight[0] - 2.0 * yWeight[3];
                 yWeight[1] = 1.0 - yWeight[0] - yWeight[2] - yWeight[3];
                 break;
              case 4:
                 /* x */
                 w = x - (double)xIndex[2];
                 w2 = w * w;
                 t = (1.0 / 6.0) * w2;
                 xWeight[0] = 1.0 / 2.0 - w;
                 xWeight[0] *= xWeight[0];
                 xWeight[0] *= (1.0 / 24.0) * xWeight[0];
                 t0 = w * (t - 11.0 / 24.0);
                 t1 = 19.0 / 96.0 + w2 * (1.0 / 4.0 - t);
                 xWeight[1] = t1 + t0;
                 xWeight[3] = t1 - t0;
                 xWeight[4] = xWeight[0] + t0 + (1.0 / 2.0) * w;
                 xWeight[2] = 1.0 - xWeight[0] - xWeight[1] - xWeight[3] - xWeight[4];
                 /* y */
                 w = y - (double)yIndex[2];
                 w2 = w * w;
                 t = (1.0 / 6.0) * w2;
                 yWeight[0] = 1.0 / 2.0 - w;
                 yWeight[0] *= yWeight[0];
                 yWeight[0] *= (1.0 / 24.0) * yWeight[0];
                 t0 = w * (t - 11.0 / 24.0);
                 t1 = 19.0 / 96.0 + w2 * (1.0 / 4.0 - t);
                 yWeight[1] = t1 + t0;
                 yWeight[3] = t1 - t0;
                 yWeight[4] = yWeight[0] + t0 + (1.0 / 2.0) * w;
                 yWeight[2] = 1.0 - yWeight[0] - yWeight[1] - yWeight[3] - yWeight[4];
                 break;
              case 5:
                 /* x */
                 w = x - (double)xIndex[2];
                 w2 = w * w;
                 xWeight[5] = (1.0 / 120.0) * w * w2 * w2;
                 w2 -= w;
                 w4 = w2 * w2;
                 w -= 1.0 / 2.0;
                 t = w2 * (w2 - 3.0);
                 xWeight[0] = (1.0 / 24.0) * (1.0 / 5.0 + w2 + w4) - xWeight[5];
                 t0 = (1.0 / 24.0) * (w2 * (w2 - 5.0) + 46.0 / 5.0);
                 t1 = (-1.0 / 12.0) * w * (t + 4.0);
                 xWeight[2] = t0 + t1;
                 xWeight[3] = t0 - t1;
                 t0 = (1.0 / 16.0) * (9.0 / 5.0 - t);
                 t1 = (1.0 / 24.0) * w * (w4 - w2 - 5.0);
                 xWeight[1] = t0 + t1;
                 xWeight[4] = t0 - t1;
                 /* y */
                 w = y - (double)yIndex[2];
                 w2 = w * w;
                 yWeight[5] = (1.0 / 120.0) * w * w2 * w2;
                 w2 -= w;
                 w4 = w2 * w2;
                 w -= 1.0 / 2.0;
                 t = w2 * (w2 - 3.0);
                 yWeight[0] = (1.0 / 24.0) * (1.0 / 5.0 + w2 + w4) - yWeight[5];
                 t0 = (1.0 / 24.0) * (w2 * (w2 - 5.0) + 46.0 / 5.0);
                 t1 = (-1.0 / 12.0) * w * (t + 4.0);
                 yWeight[2] = t0 + t1;
                 yWeight[3] = t0 - t1;
                 t0 = (1.0 / 16.0) * (9.0 / 5.0 - t);
                 t1 = (1.0 / 24.0) * w * (w4 - w2 - 5.0);
                 yWeight[1] = t0 + t1;
                 yWeight[4] = t0 - t1;
                 break;
              case 6:
                 /* x */
                 w = x - (double)xIndex[3];
                 xWeight[0] = 1.0 / 2.0 - w;
                 xWeight[0] *= xWeight[0] * xWeight[0];
                 xWeight[0] *= xWeight[0] / 720.0;
                 xWeight[1] = (361.0 / 192.0 - w * (59.0 / 8.0 + w
                    * (-185.0 / 16.0 + w * (25.0 / 3.0 + w * (-5.0 / 2.0 + w)
                    * (1.0 / 2.0 + w))))) / 120.0;
                 xWeight[2] = (10543.0 / 960.0 + w * (-289.0 / 16.0 + w
                    * (79.0 / 16.0 + w * (43.0 / 6.0 + w * (-17.0 / 4.0 + w
                    * (-1.0 + w)))))) / 48.0;
                 w2 = w * w;
                 xWeight[3] = (5887.0 / 320.0 - w2 * (231.0 / 16.0 - w2
                    * (21.0 / 4.0 - w2))) / 36.0;
                 xWeight[4] = (10543.0 / 960.0 + w * (289.0 / 16.0 + w
                    * (79.0 / 16.0 + w * (-43.0 / 6.0 + w * (-17.0 / 4.0 + w
                    * (1.0 + w)))))) / 48.0;
                 xWeight[6] = 1.0 / 2.0 + w;
                 xWeight[6] *= xWeight[6] * xWeight[6];
                 xWeight[6] *= xWeight[6] / 720.0;
                 xWeight[5] = 1.0 - xWeight[0] - xWeight[1] - xWeight[2] - xWeight[3]
                 - xWeight[4] - xWeight[6];
                 /* y */
                 w = y - (double)yIndex[3];
                 yWeight[0] = 1.0 / 2.0 - w;
                 yWeight[0] *= yWeight[0] * yWeight[0];
                 yWeight[0] *= yWeight[0] / 720.0;
                 yWeight[1] = (361.0 / 192.0 - w * (59.0 / 8.0 + w
                    * (-185.0 / 16.0 + w * (25.0 / 3.0 + w * (-5.0 / 2.0 + w)
                    * (1.0 / 2.0 + w))))) / 120.0;
                 yWeight[2] = (10543.0 / 960.0 + w * (-289.0 / 16.0 + w
                    * (79.0 / 16.0 + w * (43.0 / 6.0 + w * (-17.0 / 4.0 + w
                    * (-1.0 + w)))))) / 48.0;
                 w2 = w * w;
                 yWeight[3] = (5887.0 / 320.0 - w2 * (231.0 / 16.0 - w2
                    * (21.0 / 4.0 - w2))) / 36.0;
                 yWeight[4] = (10543.0 / 960.0 + w * (289.0 / 16.0 + w
                    * (79.0 / 16.0 + w * (-43.0 / 6.0 + w * (-17.0 / 4.0 + w
                    * (1.0 + w)))))) / 48.0;
                 yWeight[6] = 1.0 / 2.0 + w;
                 yWeight[6] *= yWeight[6] * yWeight[6];
                 yWeight[6] *= yWeight[6] / 720.0;
                 yWeight[5] = 1.0 - yWeight[0] - yWeight[1] - yWeight[2] - yWeight[3]
                 - yWeight[4] - yWeight[6];
                 break;
              case 7:
                 /* x */
                 w = x - (double)xIndex[3];
                 xWeight[0] = 1.0 - w;
                 xWeight[0] *= xWeight[0];
                 xWeight[0] *= xWeight[0] * xWeight[0];
                 xWeight[0] *= (1.0 - w) / 5040.0;
                 w2 = w * w;
                 xWeight[1] = (120.0 / 7.0 + w * (-56.0 + w * (72.0 + w
                    * (-40.0 + w2 * (12.0 + w * (-6.0 + w)))))) / 720.0;
                 xWeight[2] = (397.0 / 7.0 - w * (245.0 / 3.0 + w * (-15.0 + w
                    * (-95.0 / 3.0 + w * (15.0 + w * (5.0 + w
                    * (-5.0 + w))))))) / 240.0;
                 xWeight[3] = (2416.0 / 35.0 + w2 * (-48.0 + w2 * (16.0 + w2
                    * (-4.0 + w)))) / 144.0;
                 xWeight[4] = (1191.0 / 35.0 - w * (-49.0 + w * (-9.0 + w
                    * (19.0 + w * (-3.0 + w) * (-3.0 + w2))))) / 144.0;
                 xWeight[5] = (40.0 / 7.0 + w * (56.0 / 3.0 + w * (24.0 + w
                    * (40.0 / 3.0 + w2 * (-4.0 + w * (-2.0 + w)))))) / 240.0;
                 xWeight[7] = w2;
                 xWeight[7] *= xWeight[7] * xWeight[7];
                 xWeight[7] *= w / 5040.0;
                 xWeight[6] = 1.0 - xWeight[0] - xWeight[1] - xWeight[2] - xWeight[3]
                 - xWeight[4] - xWeight[5] - xWeight[7];
                 /* y */
                 w = y - (double)yIndex[3];
                 yWeight[0] = 1.0 - w;
                 yWeight[0] *= yWeight[0];
                 yWeight[0] *= yWeight[0] * yWeight[0];
                 yWeight[0] *= (1.0 - w) / 5040.0;
                 w2 = w * w;
                 yWeight[1] = (120.0 / 7.0 + w * (-56.0 + w * (72.0 + w
                    * (-40.0 + w2 * (12.0 + w * (-6.0 + w)))))) / 720.0;
                 yWeight[2] = (397.0 / 7.0 - w * (245.0 / 3.0 + w * (-15.0 + w
                    * (-95.0 / 3.0 + w * (15.0 + w * (5.0 + w
                    * (-5.0 + w))))))) / 240.0;
                 yWeight[3] = (2416.0 / 35.0 + w2 * (-48.0 + w2 * (16.0 + w2
                    * (-4.0 + w)))) / 144.0;
                 yWeight[4] = (1191.0 / 35.0 - w * (-49.0 + w * (-9.0 + w
                    * (19.0 + w * (-3.0 + w) * (-3.0 + w2))))) / 144.0;
                 yWeight[5] = (40.0 / 7.0 + w * (56.0 / 3.0 + w * (24.0 + w
                    * (40.0 / 3.0 + w2 * (-4.0 + w * (-2.0 + w)))))) / 240.0;
                 yWeight[7] = w2;
                 yWeight[7] *= yWeight[7] * yWeight[7];
                 yWeight[7] *= w / 5040.0;
                 yWeight[6] = 1.0 - yWeight[0] - yWeight[1] - yWeight[2] - yWeight[3]
                 - yWeight[4] - yWeight[5] - yWeight[7];
                 break;
              case 8:
                 /* x */
                 w = x - (double)xIndex[4];
                 xWeight[0] = 1.0 / 2.0 - w;
                 xWeight[0] *= xWeight[0];
                 xWeight[0] *= xWeight[0];
                 xWeight[0] *= xWeight[0] / 40320.0;
                 w2 = w * w;
                 xWeight[1] = (39.0 / 16.0 - w * (6.0 + w * (-9.0 / 2.0 + w2)))
                    * (21.0 / 16.0 + w * (-15.0 / 4.0 + w * (9.0 / 2.0 + w
                    * (-3.0 + w)))) / 5040.0;
                 xWeight[2] = (82903.0 / 1792.0 + w * (-4177.0 / 32.0 + w
                    * (2275.0 / 16.0 + w * (-487.0 / 8.0 + w * (-85.0 / 8.0 + w
                    * (41.0 / 2.0 + w * (-5.0 + w * (-2.0 + w)))))))) / 1440.0;
                 xWeight[3] = (310661.0 / 1792.0 - w * (14219.0 / 64.0 + w
                    * (-199.0 / 8.0 + w * (-1327.0 / 16.0 + w * (245.0 / 8.0 + w
                    * (53.0 / 4.0 + w * (-8.0 + w * (-1.0 + w)))))))) / 720.0;
                 xWeight[4] = (2337507.0 / 8960.0 + w2 * (-2601.0 / 16.0 + w2
                    * (387.0 / 8.0 + w2 * (-9.0 + w2)))) / 576.0;
                 xWeight[5] = (310661.0 / 1792.0 - w * (-14219.0 / 64.0 + w
                    * (-199.0 / 8.0 + w * (1327.0 / 16.0 + w * (245.0 / 8.0 + w
                    * (-53.0 / 4.0 + w * (-8.0 + w * (1.0 + w)))))))) / 720.0;
                 xWeight[7] = (39.0 / 16.0 - w * (-6.0 + w * (-9.0 / 2.0 + w2)))
                    * (21.0 / 16.0 + w * (15.0 / 4.0 + w * (9.0 / 2.0 + w
                    * (3.0 + w)))) / 5040.0;
                 xWeight[8] = 1.0 / 2.0 + w;
                 xWeight[8] *= xWeight[8];
                 xWeight[8] *= xWeight[8];
                 xWeight[8] *= xWeight[8] / 40320.0;
                 xWeight[6] = 1.0 - xWeight[0] - xWeight[1] - xWeight[2] - xWeight[3]
                 - xWeight[4] - xWeight[5] - xWeight[7] - xWeight[8];
                 /* y */
                 w = y - (double)yIndex[4];
                 yWeight[0] = 1.0 / 2.0 - w;
                 yWeight[0] *= yWeight[0];
                 yWeight[0] *= yWeight[0];
                 yWeight[0] *= yWeight[0] / 40320.0;
                 w2 = w * w;
                 yWeight[1] = (39.0 / 16.0 - w * (6.0 + w * (-9.0 / 2.0 + w2)))
                    * (21.0 / 16.0 + w * (-15.0 / 4.0 + w * (9.0 / 2.0 + w
                    * (-3.0 + w)))) / 5040.0;
                 yWeight[2] = (82903.0 / 1792.0 + w * (-4177.0 / 32.0 + w
                    * (2275.0 / 16.0 + w * (-487.0 / 8.0 + w * (-85.0 / 8.0 + w
                    * (41.0 / 2.0 + w * (-5.0 + w * (-2.0 + w)))))))) / 1440.0;
                 yWeight[3] = (310661.0 / 1792.0 - w * (14219.0 / 64.0 + w
                    * (-199.0 / 8.0 + w * (-1327.0 / 16.0 + w * (245.0 / 8.0 + w
                    * (53.0 / 4.0 + w * (-8.0 + w * (-1.0 + w)))))))) / 720.0;
                 yWeight[4] = (2337507.0 / 8960.0 + w2 * (-2601.0 / 16.0 + w2
                    * (387.0 / 8.0 + w2 * (-9.0 + w2)))) / 576.0;
                 yWeight[5] = (310661.0 / 1792.0 - w * (-14219.0 / 64.0 + w
                    * (-199.0 / 8.0 + w * (1327.0 / 16.0 + w * (245.0 / 8.0 + w
                    * (-53.0 / 4.0 + w * (-8.0 + w * (1.0 + w)))))))) / 720.0;
                 yWeight[7] = (39.0 / 16.0 - w * (-6.0 + w * (-9.0 / 2.0 + w2)))
                    * (21.0 / 16.0 + w * (15.0 / 4.0 + w * (9.0 / 2.0 + w
                    * (3.0 + w)))) / 5040.0;
                 yWeight[8] = 1.0 / 2.0 + w;
                 yWeight[8] *= yWeight[8];
                 yWeight[8] *= yWeight[8];
                 yWeight[8] *= yWeight[8] / 40320.0;
                 yWeight[6] = 1.0 - yWeight[0] - yWeight[1] - yWeight[2] - yWeight[3]
                 - yWeight[4] - yWeight[5] - yWeight[7] - yWeight[8];
                 break;
              case 9:
                 /* x */
                 w = x - (double)xIndex[4];
                 xWeight[0] = 1.0 - w;
                 xWeight[0] *= xWeight[0];
                 xWeight[0] *= xWeight[0];
                 xWeight[0] *= xWeight[0] * (1.0 - w) / 362880.0;
                 xWeight[1] = (502.0 / 9.0 + w * (-246.0 + w * (472.0 + w
                    * (-504.0 + w * (308.0 + w * (-84.0 + w * (-56.0 / 3.0 + w
                    * (24.0 + w * (-8.0 + w))))))))) / 40320.0;
                 xWeight[2] = (3652.0 / 9.0 - w * (2023.0 / 2.0 + w * (-952.0 + w
                    * (938.0 / 3.0 + w * (112.0 + w * (-119.0 + w * (56.0 / 3.0 + w
                    * (14.0 + w * (-7.0 + w))))))))) / 10080.0;
                 xWeight[3] = (44117.0 / 42.0 + w * (-2427.0 / 2.0 + w * (66.0 + w
                    * (434.0 + w * (-129.0 + w * (-69.0 + w * (34.0 + w * (6.0 + w
                    * (-6.0 + w))))))))) / 4320.0;
                 w2 = w * w;
                 xWeight[4] = (78095.0 / 63.0 - w2 * (700.0 + w2 * (-190.0 + w2
                    * (100.0 / 3.0 + w2 * (-5.0 + w))))) / 2880.0;
                 xWeight[5] = (44117.0 / 63.0 + w * (809.0 + w * (44.0 + w
                    * (-868.0 / 3.0 + w * (-86.0 + w * (46.0 + w * (68.0 / 3.0 + w
                    * (-4.0 + w * (-4.0 + w))))))))) / 2880.0;
                 xWeight[6] = (3652.0 / 21.0 - w * (-867.0 / 2.0 + w * (-408.0 + w
                    * (-134.0 + w * (48.0 + w * (51.0 + w * (-4.0 + w) * (-1.0 + w)
                    * (2.0 + w))))))) / 4320.0;
                 xWeight[7] = (251.0 / 18.0 + w * (123.0 / 2.0 + w * (118.0 + w
                    * (126.0 + w * (77.0 + w * (21.0 + w * (-14.0 / 3.0 + w
                    * (-6.0 + w * (-2.0 + w))))))))) / 10080.0;
                 xWeight[9] = w2 * w2;
                 xWeight[9] *= xWeight[9] * w / 362880.0;
                 xWeight[8] = 1.0 - xWeight[0] - xWeight[1] - xWeight[2] - xWeight[3]
                 - xWeight[4] - xWeight[5] - xWeight[6] - xWeight[7] - xWeight[9];
                 /* y */
                 w = y - (double)yIndex[4];
                 yWeight[0] = 1.0 - w;
                 yWeight[0] *= yWeight[0];
                 yWeight[0] *= yWeight[0];
                 yWeight[0] *= yWeight[0] * (1.0 - w) / 362880.0;
                 yWeight[1] = (502.0 / 9.0 + w * (-246.0 + w * (472.0 + w
                    * (-504.0 + w * (308.0 + w * (-84.0 + w * (-56.0 / 3.0 + w
                    * (24.0 + w * (-8.0 + w))))))))) / 40320.0;
                 yWeight[2] = (3652.0 / 9.0 - w * (2023.0 / 2.0 + w * (-952.0 + w
                    * (938.0 / 3.0 + w * (112.0 + w * (-119.0 + w * (56.0 / 3.0 + w
                    * (14.0 + w * (-7.0 + w))))))))) / 10080.0;
                 yWeight[3] = (44117.0 / 42.0 + w * (-2427.0 / 2.0 + w * (66.0 + w
                    * (434.0 + w * (-129.0 + w * (-69.0 + w * (34.0 + w * (6.0 + w
                    * (-6.0 + w))))))))) / 4320.0;
                 w2 = w * w;
                 yWeight[4] = (78095.0 / 63.0 - w2 * (700.0 + w2 * (-190.0 + w2
                    * (100.0 / 3.0 + w2 * (-5.0 + w))))) / 2880.0;
                 yWeight[5] = (44117.0 / 63.0 + w * (809.0 + w * (44.0 + w
                    * (-868.0 / 3.0 + w * (-86.0 + w * (46.0 + w * (68.0 / 3.0 + w
                    * (-4.0 + w * (-4.0 + w))))))))) / 2880.0;
                 yWeight[6] = (3652.0 / 21.0 - w * (-867.0 / 2.0 + w * (-408.0 + w
                    * (-134.0 + w * (48.0 + w * (51.0 + w * (-4.0 + w) * (-1.0 + w)
                    * (2.0 + w))))))) / 4320.0;
                 yWeight[7] = (251.0 / 18.0 + w * (123.0 / 2.0 + w * (118.0 + w
                    * (126.0 + w * (77.0 + w * (21.0 + w * (-14.0 / 3.0 + w
                    * (-6.0 + w * (-2.0 + w))))))))) / 10080.0;
                 yWeight[9] = w2 * w2;
                 yWeight[9] *= yWeight[9] * w / 362880.0;
                 yWeight[8] = 1.0 - yWeight[0] - yWeight[1] - yWeight[2] - yWeight[3]
                 - yWeight[4] - yWeight[5] - yWeight[6] - yWeight[7] - yWeight[9];
                 break;
              default:
                 throw ::std::exception("Error: Invalid spline degree") ;
      }

      /* apply the mirror boundary conditions */
      for (k = 0; k <= SplineDegree; k++) {
         xIndex[k] = (Width == 1) ? (0) : ((xIndex[k] < 0) ?
            (-xIndex[k] - Width2 * ((-xIndex[k]) / Width2))
            : (xIndex[k] - Width2 * (xIndex[k] / Width2)));
         if (Width <= xIndex[k]) {
            xIndex[k] = Width2 - xIndex[k];
         }
         yIndex[k] = (Height == 1) ? (0) : ((yIndex[k] < 0) ?
            (-yIndex[k] - Height2 * ((-yIndex[k]) / Height2))
            : (yIndex[k] - Height2 * (yIndex[k] / Height2)));
         if (Height <= yIndex[k]) {
            yIndex[k] = Height2 - yIndex[k];
         }
      }

      /* perform interpolation */
      interpolated = 0.0;
      for (j = 0; j <= SplineDegree; j++) 
      {
         int adr = yIndex[j] * Width;
         w = 0.0;
         for (i = 0; i <= SplineDegree; i++) 
         {
            w += xWeight[i] * Bcoeff[adr+xIndex[i]];
         }
         interpolated += yWeight[j] * w;
      }


      delete [] xWeight;
      delete [] yWeight;
      delete [] xIndex;
      delete [] yIndex;
      return(interpolated);

   } catch (std::exception &e) {
      delete [] xWeight;
      delete [] yWeight;
      delete [] xIndex;
      delete [] yIndex;
      throw e;
   }
}

// //////////////////////////////////////////////////////////
// Translation d'une colonne de l'image (rang "colonne")                 
// On utilise une interpolation spline de degré 9 pour une qualité maximale 
// Seul un crop de l'image d'entrée (buf_entree) est translaté, délimité
// par les coordonnées (mémoire) imax_result et jmax_result.
// La colonne de rang "colonne" dans le buffer resultat est remplacée par 
// la colonne translatée.
// delta_y : est la valeur de la translation en Y                    
// /////////////////////////////////////////////////////////
void translate_col(INFOIMAGE * buffer,
                          int colonne, double delta_y, ORDRE *ordre, int n,
                          std::valarray<PIC_TYPE> &buf_result, int imax_result, int jmax_result,
                          int spline_deg)
{
   int SplineDegree = spline_deg;  // degré d'interpolation spline (9 = meilleure qualité)

   int imax = buffer->imax;
   int jmax = buffer->jmax;
   
   int hauteur = jmax_result; // hauteur du crop dans le buffer d'entrée
   int imax1 = jmax;
   int jmax1 = 2;  // ne pas mettre 1, sinon plantage dans InterpolateValue (effet de bord)

   int intueur = imax1 * jmax1;
   float *buf_in = new float[intueur];  // le vecteur de calcul d'entrée (colonne à interpoler)
   float *buf_out = new float[intueur]; // le vecteur de calcul de sortie (colonne interpolée)
   //int j, adr;
   int i = colonne; // rang de la colonne à translater

   //  TODO voir pourquoi il faut initiliser ces tableaux
   memset(buf_in,0,intueur*sizeof(float));
   memset(buf_out,0,intueur*sizeof(float));

   
   try {
      // Génération du vecteur d'entrée (une colonne de longueur jmax)
      for (int j = 0; j < jmax; j++){
         int adr = j * imax + i;
         buf_in[j] = (float)buffer->pic[adr];
         buf_out[j] = 0.0F;
      }
      
      // Calcul des coefficients d'interpolation sur le vecteur d'entrée (taille imax x 2)
      try { 
         SamplesToCoefficients(buf_in, imax1, jmax1, SplineDegree);
      } catch (std::exception &e) {
         // j'enrichie le message d'erreur
         char message[1024];
         sprintf(message, "Error translate_col order=%d. %s",n,e.what());
         throw ::std::exception(message);
      } 
      
      int start_y = (int)(ordre[n].yc - hauteur/2);  // zone de crop dans le buffer d'entrée
      int end_y   = (int)(ordre[n].yc + hauteur/2);

      if ( start_y < 0 || start_y > jmax ) {
         char message[1024];
         sprintf(message, "Error translate_col order=%d. Crop zone is outside, start_y=%d",n,start_y);
         throw ::std::exception(message);
      }
      if ( end_y < 0 || end_y > jmax ) {
         char message[1024];
         sprintf(message, "Error translate_col order=%d. Crop zone is outside, end_y=%d",n,end_y);
         throw ::std::exception(message);
      }

      // On visite les pixels du vecteur d'arrivée (entre start_y et end_y pour optimiser la vitesse)
      for (int x = start_y; x < end_y; x++)
      {
         double x1, y1;
         x1 = (double)x - delta_y;  // transformation (translation du vecteur)
         y1 = 0.0;
         if (x1 < 0 || x1 > (double)(jmax - 1))
            buf_out[x] = 0.0F;
         else
         {
            float v = (float)InterpolatedValue(buf_in, imax1, jmax1,x1, y1, SplineDegree);
            buf_out[x] = v;
         }           
      }

      // Copie de la colonne translatée dans le buffer de sortie
      for (int j = start_y; j < end_y; j++) {
         int adr = (j - start_y) * imax_result + i;
         buf_result[adr] = (int)buf_out[j];
      }

      delete [] buf_in;
      delete [] buf_out;
      return;
   } catch (std::exception &e) {
      delete [] buf_in;
      delete [] buf_out;
      throw e;
   }
  
}

/************************************** L_SKY_SUB ****************************************/
/* Calcul de la médiane dans deux zones de part et d'autre de la trace du spectre,       */ 
/* puis soustraction de la moyenne de ces deux mesures (y1,y2,y3,y4 = coordonnées image) */
/*****************************************************************************************/
int l_sky_sub(INFOIMAGE *buffer,int y1,int y2,int y3,int y4)
{
PIC_TYPE *p;
int imax,jmax,adr,i,j,ptc;
PIC_TYPE *buf1,*buf2;
int nb_ligne1,nb_ligne2;
int tempo;
int m1,m2;
PIC_TYPE m;

if (buffer->pic==NULL) return 1;

p=buffer->pic;
imax=buffer->imax;
jmax=buffer->jmax;

// zone 1
if (y2<y1)
   {
   tempo=y2;
   y2=y1;
   y1=tempo;
   }
if (y2>jmax) y2=jmax;
if (y1<1) y1=1;
nb_ligne1=y2-y1+1;
if ((buf1=(PIC_TYPE *)calloc(nb_ligne1,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

// zone 2
if (y4<y3)
   {
   tempo=y4;
   y4=y3;
   y3=tempo;
   }
if (y4>jmax) y4=jmax;
if (y3<1) y3=1;
nb_ligne2=y4-y3+1;
if ((buf2=(PIC_TYPE *)calloc(nb_ligne2,sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

for (i=0;i<imax;i++)
   {
   // zone 1
   ptc=0;
   for (j=y1-1;j<y2;j++)
      {
      adr=j*imax+i;
      buf1[ptc]=p[j*imax+i];
      ptc++;
      }
   m1=(int)hmedian(buf1,nb_ligne1);

   // zone 2
   ptc=0;
   for (j=y3-1;j<y4;j++)
      {
      adr=j*imax+i;
      buf2[ptc]=p[j*imax+i];
      ptc++;
      }
   m2=(int)hmedian(buf2,nb_ligne2);

   m=(PIC_TYPE)(((double)m1+(double)m2)/2.0+.5);

   for (j=0;j<jmax;j++)
      {
      p[j*imax+i]=p[j*imax+i]-m; 
      }
   }

free(buf1);
free(buf2);
return 0;
}

/********************************* L_OPT ***********************************/
/* Calcul la somme normalisée et optimisé entre les lignes lmax et lmin    */
/* Version simpliflié sans réjection des pixels aberrants                  */
/* Variance constante (indépendante du signal)                             */
/* Dans ce cas                                                             */
/*    F = S(P.(D-ciel)) / S(P . P)                                         */
/*                                                                         */
/* Voir J. G. Robertson, PASP 98, 1220-1231, November 1986                 */
/* Le domaine de binning suivant l'axe spatial est donné par (lmin - lmax) */
/* (ligne min et ligne max ( origine 1,1).                                 */
/* Le calcul est fait entre les colonnes xmin et xmax (origine 1,1)        */
/* Le nom du profil spectral (extension .dat) est nom                      */
/***************************************************************************/
void l_opt(std::valarray<PIC_TYPE> &p, int imax, int jmax, int lmin,int lmax,
          int xmin,int xmax, int bordure, std::valarray<double> &profile)
{
   int i,j,k;
   int tempo;
   double somme,norme;
   double v,w,s;
   PIC_TYPE *vv=NULL;
   double *f = NULL;
   double *P = NULL;

   try {
      if (p.size() == 0) {
         char message[1024];
         sprintf(message, "Erreur l_opt p=NULL ");
         throw ::std::exception(message);
      }

      if (lmax<lmin) {
         tempo=lmax;
         lmax=lmin;
         lmin=tempo;
      }

      if (lmax>jmax || lmin<1 || (lmax - lmin) < 4) {
         char message[1024];
         sprintf(message, "Erreur l_opt lmax>jmax || lmin<1 ");
         throw ::std::exception(message);
      }

      if (xmax<xmin) {
         tempo=xmax;
         xmax=xmin;
         xmin=tempo;
      }

      if (xmax>imax) xmax=imax;
      if (xmin<1) xmin=1;

      // Profil spectral monodimentionnel (f)
      f = new double[imax];

      // Modèle profil spectral colonne (P)
      P = new double[lmax - lmin + 1];

      // ------------------------------------------------------------------------           
      // On gère les 4 premières colonnes (calcul simplifié du profil spatial)
      // ------------------------------------------------------------------------           
      for (i = xmin - 1; i < xmin + 3; i++)
      {
         somme = 0.0;
         k = 0;

         // Calcul de la fonction de poids
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = (double)p[j * imax + i];
         }

         // La fonction de poids est rendue strictement positive et normalisée
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            if (P[k] < 0) P[k] = 0;
            s = s + P[k];
         }
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = P[k] / s;
         }

         // Calcul de la norme
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            s = s + P[k] * P[k];
         }
         norme = s;

         // Calcul du profil optimisé
         if (norme != 0.0 && !_isnan(norme))
         {
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               v = (double)p[j * imax + i];
               w = P[k];
               somme += w * v;
            }
            f[i] = somme / norme;
         }
         else
            f[i] = 0.0;
      }

      // -----------------------------------------------------------------------
      // On gère les 4 dernières colonnes (calcul simplifié du profil spatial)
      // -----------------------------------------------------------------------
      for (i = xmax - 4; i < xmax; i++)
      {
         somme = 0.0;
         k = 0;

         // Calcul de la fonction de poids
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = (double)p[j * imax + i];
         }

         // La fonction de poids est rendue strictement positive et normalisée
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            if (P[k] < 0) P[k] = 0;
            s = s + P[k];
         }
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = P[k] / s;
         }

         // Calcul de la norme
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            s = s + P[k] * P[k];
         }
         norme = s;

         // Calcul du profil optimisé
         if (norme != 0.0 && !_isnan(norme))
         {
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               v = (double)p[j * imax + i];
               w = P[k];
               somme += w * v;
            }
            f[i] = somme / norme;
         }
         else
            f[i] = 0.0;
      }

      // -------------------------------------------------------------------------------------
      // On gère le reste du profil (le profil est estimé sur une somme médiane de 9 pixels)
      // -------------------------------------------------------------------------------------
      vv = new PIC_TYPE[9];
      for (i = xmin + 3; i < xmax - 4; i++)
      {
         somme = 0.0;
         k = 0;
         // Calcul de la fonction de poids = médiane sur 7 colonnes
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            vv[0] = p[j * imax + i - 4];
            vv[1] = p[j * imax + i - 3];
            vv[2] = p[j * imax + i - 2];
            vv[3] = p[j * imax + i - 1];
            vv[4] = p[j * imax + i];
            vv[5] = p[j * imax + i + 1];
            vv[6] = p[j * imax + i + 2];
            vv[7] = p[j * imax + i + 3];
            vv[8] = p[j * imax + i + 4];
            P[k] = (double)hmedian(vv, 9);
         }

         // La fonction de poids est rendue strictement positive et normalisée
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            if (P[k] < 0) P[k] = 0;
            s = s + P[k];
         }
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = P[k] / s;
         }

         // Calcul de la norme
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            s = s + P[k] * P[k];
         }
         norme = s;

         // Calcul du profil optimisé
         if (norme != 0.0 && !_isnan(norme))
         {
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               v = (double)p[j * imax + i];
               w = P[k];
               somme += w * v;
            }
            f[i] = somme / norme;
         }
         else
            f[i] = 0.0;
      }

      
      // -----------------------------------------------------
      // Sauvegarde du profil spectral (en comptes numériques)
      // -----------------------------------------------------
      /*
      k = 0;
      for (i = xmin - 1; i < xmax; i++, k++)
      {
         profil[0, k] = i + 1;
         profil[1, k] = f[i];
      }
      */
      profile.resize(xmax-xmin-2*bordure +1);
      for (i=xmin + bordure ; i<=xmax-bordure; i++) { 
         profile[i-xmin-bordure] = f[i-1];
      }

      delete [] f;
      delete [] P;
      delete [] vv;

   } catch (std::exception &e) {
      delete [] f;
      delete [] P;
      delete [] vv;
      throw e;
   }
}

/********************************* L_OPT2 **********************************/
/* Calcul la somme normalisée et optimisé entre les lignes lmax et lmin    */
/* Version avec réjection des pixels aberrants (algorithme de Hornes)      */
/* Voir Keith Horne, PASP, 98, 609-617, June 1986                          */
/*                                                                         */
/*    F = S(M . P . I / V) / S(M . P . P / V)                              */
/*                                                                         */
/* V = variance du bruit colonne                                           */ 
/* P = fonction de poids du profil                                         */
/* I = signal                                                              */
/* M = flag des cosmique                                                   */
/*                                                                         */ 
/* Voir aussi J. G. Robertson, PASP 98, 1220-1231, November 1986           */
/* Le domaine de binning suivant l'axe spatial est donné par (lmin - lmax) */
/* (ligne min et ligne max ( origine 1,1).                                 */
/* Le calcul est fait entre les colonnes xmin et xmax (origine 1,1)        */
/* Le nom du profil spectral (extension .dat) est nom                      */
/* Coordonnées écran (image)                                               */
/***************************************************************************/
void l_opt2(std::valarray<PIC_TYPE> &p, 
            int imax, int jmax,
            int lmin, int lmax, int xmin, int xmax,
            int bordure,
            std::valarray<double> &profile)
{
   int i, j, k;
   int tempo;
   double somme, norme;
   double v, w, s;
   PIC_TYPE *vv=NULL;
   double *f = NULL;
   double *P = NULL;
   double *V = NULL;
   int *M = NULL;

   double noise = 18.0;     // bruit RMS de lecture typique en ADU 
   noise = noise * noise;   // variance

   try {
      if (p.size() == 0) {
         char message[1024];
         sprintf(message, "Erreur l_opt p=NULL ");
         throw ::std::exception(message);
      }

      if (lmax < lmin) {
         tempo = lmax;
         lmax = lmin;
         lmin = tempo;
      }

      if (lmax > jmax || lmin < 1 || (lmax - lmin) < 4) {
         char message[1024];
         sprintf(message, "Erreur l_opt2 lmax>jmax || lmin<1 ");
         throw ::std::exception(message);
      }

      if (xmax < xmin) {
         tempo = xmax;
         xmax = xmin;
         xmin = tempo;
      }

      if (xmax > imax) xmax = imax;
      if (xmin < 1) xmin = 1;

      // Profil spectral monodimentionnel (f)
      f = new double[imax];

      // Modèle profil spectral colonne (P)
      P = new double[lmax - lmin + 1];

      // Bruit colonne (variance)
      V = new double[lmax - lmin + 1];

      // Table des rayons cosmiques détecté
      M = new int[lmax - lmin + 1];

      // ----------------------------------------------------
      // On gère les 4 premières colonnes
      // Algorithme simplifié (pas de détection de cosmique)
      // ----------------------------------------------------
      for (i = xmin - 1; i < xmin + 3; i++)
      {
         k = 0;
         // Calcul de la fonction de poids
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = (double)p[j * imax + i];
         }

         // La fonction de poids est rendue strictement positive et normalisée
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            if (P[k] < 0) P[k] = 0;
            s = s + P[k];
         }
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = P[k] / s;
         }

         // Calcul de la norme
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            s = s + P[k] * P[k];
         }
         norme = s;

         // Calcul du profil optimisé
         somme = 0;
         if (norme != 0.0 && !_isnan(norme))
         {
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               v = (double)p[j * imax + i];
               w = P[k];
               somme += w * v;
            }
            f[i] = somme / norme;
         }
         else
            f[i] = 0.0;
      }

      // ----------------------------------------------------
      // On gère les 4 dernières colonne
      // Algorithme simplifié (pas de détection de cosmique)
      // ----------------------------------------------------
      for (i = xmax - 4; i < xmax; i++)
      {
         k = 0;
         // Calcul de la fonction de poids
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = (double)p[j * imax + i];
         }

         // La fonction de poids est rendue strictement positive et normalisée
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            if (P[k] < 0) P[k] = 0;
            s = s + P[k];
         }
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            P[k] = P[k] / s;
         }

         // Calcul de la norme
         s = 0;
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            s = s + P[k] * P[k];
         }
         norme = s;

         // Calcul du profil optimisé
         somme = 0.0;
         if (norme != 0.0 && !_isnan(norme))
         {
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               v = (double)p[j * imax + i];
               w = P[k];
               somme += w * v;
            }
            f[i] = somme / norme;
         }
         else
            f[i] = 0.0;
      }

      // ------------------------------------------
      // On gère le reste du profil...
      // Algorithme de K. Korne complet
      // ------------------------------------------
      vv = new int[9];
      double E = 0.0;
      for (i = xmin + 3; i < xmax - 4; i++)
      {
         // Initialisation de la table des cosmiques
         k = 0;
         for (j = lmin - 1; j < lmax; j++, k++)
         {
            M[k] = 1;
         }

         // On itère 4 x
         for (int it = 0; it < 4; it++)
         {
            somme = 0.0;
            k = 0;
            // Calcul de la fonction de poids = médiane sur 9 colonnes
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               vv[0] = p[j * imax + i - 4];
               vv[1] = p[j * imax + i - 3];
               vv[2] = p[j * imax + i - 2];
               vv[3] = p[j * imax + i - 1];
               vv[4] = p[j * imax + i];
               vv[5] = p[j * imax + i + 1];
               vv[6] = p[j * imax + i + 2];
               vv[7] = p[j * imax + i + 3];
               vv[8] = p[j * imax + i + 4];
               P[k] = (double)hmedian(vv,9);
            }

            // La fonction de poids est rendue strictement positive et normalisée
            s = 0;
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               if (P[k] < 0) P[k] = 0;
               s = s + P[k];
            }
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               P[k] = P[k] / s;
            }

            // première passe (somme simple)
            if (it == 0)
            {
               k = 0;
               E = 0.0;
               for (j = lmin - 1; j < lmax; j++, k++)
               {
                  E = E + (double)p[j * imax + i] * (double)M[k];
               }
            }

            // Calcul du bruit colonne
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               V[k] = P[k] * E + noise;
            }

            // Calcul de la norme
            s = 0;
            k = 0;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               s = s + (double)M[k] * P[k] * P[k] / V[k];
            }
            norme = s;

            // Calcul du profil optimisé
            somme = 0.0;
            if (norme != 0.0 && !_isnan(norme))
            {
               k = 0;
               for (j = lmin - 1; j < lmax; j++, k++)
               {
                  v = (double)M[k] * P[k] * (double)p[j * imax + i] / V[k];
                  somme += v;
               }
               f[i] = E = somme / norme;
            }
            else
               f[i] = E = 0.0;

            // Détection des cosmiques (réjection en variance à (4.5 x sigma) * (4.5 x sigma = 20.2)
            k = 0;
            double max = -1e-10;
            int index = -1;
            for (j = lmin - 1; j < lmax; j++, k++)
            {
               if ((M[k] == 1) && (pow((double)p[j * imax + i] - E * P[k], 2.0) > 20.2 * V[k]))
               {
                  // Recherche du point le plus déviant par rapport au modèle
                  if (pow((double)p[j * imax + i] - E * P[k], 2.0) > max)
                  {
                     max = pow((double)p[j * imax + i] - E * P[k], 2.0);
                     index = k;
                  }
               }
            }
            if (index != -1) M[index] = 0;  // retrait d'un seul cosmique par boucle
         }
      }
      k = 0;

      
      //for (i=xmin;i<=xmax;i++) { 
      //   profile[i-xmin] = f[i-1];
      //}

      profile.resize(xmax-xmin-2*bordure +1);
      for (i=xmin + bordure ; i<=xmax-bordure; i++) { 
         profile[i-xmin-bordure] = f[i-1];
      }


      delete [] f;
      delete [] P;
      delete [] V;
      delete [] M;
      delete [] vv;

   } catch (std::exception &e) {
      delete [] f;
      delete [] P;
      delete [] V;
      delete [] M;
      delete [] vv;
      throw e;
   }
}


/******************************** EXTRACT_ORDER **************************************/
/* Corrige la courbure d'un ordre (le spectre est rendu rectiligne), puis            */
/* extraction du profil spectrale après l'opération de binning suivant l'axe spatial */
/* Le numéro de l'ordre traité est contenu dans la variable n.                       */                
/*************************************************************************************/
void extract_order(INFOIMAGE *buffer, PROCESS_INFO &processInfo, int n, ORDRE *ordre,int imax2, int jmax2, 
                   std::valarray<double> &profile, std::valarray<PIC_TYPE> &p2, 
                   int flag_opt)
{
   int k;
   double delta_y;
   double v;
   int splineDegre = 2; // choix entre 2 et 9 -> 9 meilleure qualité lors des corrections géométriques

   double * x = NULL;
   double * y = NULL;
   double * w = NULL;
   double * a1 = NULL;
   double * a2 = NULL;


   try {
      // ------------------------------------------------------------------------------
      // Rectification de la courbure des ordres suivant l'axe spectral (smile)
      // On utilise une fonction spline d'interpolation de degré 9
      // La calcul n'est fait que dans une zone centrée sur l'ordre courant 
      // de hauteur jmax2 (dans cette version, on ne croppe par suivant X (imax2=imax))
      // Le résultat est une sous image 2D du spectre rectifié pointée par p2 et
      // de dimension (imax2, jmax2)
      // ------------------------------------------------------------------------------
      for (int i=ordre[n].min_x-1;i<ordre[n].max_x -1;i++) {
         v=0.0;
         for (k=0;k<=POLY_ORDER_DEGREE;k++){
            v=v+ordre[n].poly_order[k]*pow((double)i,(double)k);
         }
         delta_y=v-ordre[n].yc;

         // rectification géométrique colonne par colonne
         translate_col(buffer,i,-delta_y,ordre,n, p2, imax2, jmax2, splineDegre);
      }

      // --------------------------------------------------------------------------
      // Soustraction du fond parasite
      // Calcul de la coordonnée Y des deux zones de calcul d'ajustement du fond
      // de part et d'autre l'ordre courant
      // (i.e. au niveau des coordonnées Y de l'inter-ordre)
      // On soustrait la moyenne trouvée des deux coté après
      // un ajustement polynomial de degré 5 le long de l'axe spectral
      // --------------------------------------------------------------------------
      int y1, y2;
      if (ordre[n + 1].flag == 1)   // position - par rapport à l'axe du spectre
         y1 = jmax2 / 2 - (ordre[n].yc - ordre[n + 1].yc) / 2;
      else
         y1 = jmax2 / 2 - (ordre[n - 1].yc - ordre[n].yc) / 2;
      if ( y1 < 0 ) {
         y1 = 0;
      }
      if ( y1 >= jmax2 ) {
         y1 = jmax2 -1;
      }


      if (ordre[n - 1].flag == 1)   // position + par rapport à l'axe du spectre
         y2 = jmax2 / 2 + (ordre[n-1].yc - ordre[n].yc) / 2;
      else
         y2 = jmax2 / 2 + (ordre[n].yc - ordre[n+1].yc) / 2;
      if ( y2 <= y1 ) {
         y2 = y1+1;
      }
      if ( y2 >= jmax2 ) {
         y2 = jmax2 -1;
      }

      // -------------------------------------------------------------
      // Le "fond de ciel" est déterminé par un ajustement
      // polynomial du signal inter-ordre (on utilise le degré 5)
      // -------------------------------------------------------------
      int taille = abs(ordre[n].max_x - ordre[n].min_x + 1);
      x = new double[taille];
      y = new double[taille];
      w = new double[taille];
      int degre2 = 5;
      double rms;

      // ---------------------------------------------------------
      // Calcul du niveau moyen du fond sous la trace 
      // (sera utilisé pour exclure les plus forts cosmiques)
      // ---------------------------------------------------------
      double moyenne1 = 0.0;
      k = 0;
      for (int i = ordre[n].min_x - 1; i < ordre[n].max_x - 1; i++, k++) {
         moyenne1 += p2[y1 * imax2 + i];
      }
      moyenne1 = moyenne1 / (double)k;

      // -------------------------------------------------------------
      // Calcul du fond sous le spectre (en dessous de la trace)
      // On exclue les points qui sont à 1000 ADU au desssus du fond
      // -------------------------------------------------------------
      double prev_i=0;
      double prev_mu_i = moyenne1;
      double prev_mu_ii=0;
      double prev_sx_i = 0;
      double prev_sx_ii=0;
      int prev_k = 1;
      double epsdouble=1.0e-300;

      k = 0;
      double cosmicLevel = moyenne1 + 1000.0;
      for (int i = ordre[n].min_x - 1; i < ordre[n].max_x - 1; i++) {
         if ((double)p2[y1 * imax2 + i] < cosmicLevel) {
            double valeur = (double)p2[y1 * imax2 + i];  // en dessous de la trace du spectre
            x[k] = (double)i;
            y[k] = valeur;  // en dessous de la trace du spectre
            w[k] = 1.0;
            k++;

            prev_i= (prev_k+1);
            prev_k++;
            double delta=valeur-prev_mu_i;
            if ( fabs(delta) < epsdouble) {
               if ( delta < 0 ) {
                  delta = -epsdouble ;
               } else {
                  delta = epsdouble ;
               }
            }
            prev_mu_ii=prev_mu_i+delta/(prev_i);
            prev_sx_ii=prev_sx_i+delta*(valeur-prev_mu_ii);
            if ( fabs(prev_sx_ii) < epsdouble) {
               if ( prev_sx_ii < 0 ) {
                  prev_sx_ii = -epsdouble ;
               } else {
                  prev_sx_ii = epsdouble ;
               }
            }
            prev_mu_i=prev_mu_ii;
            prev_sx_i=prev_sx_ii;
         }
      }

      rms = 0.0;
      a1 = new double[degre2 + 1];
      for (int i = 0; i <= degre2; i++) a1[i] = 0.0;
      try {
         fitPoly(k, degre2, x, y, w, a1, &rms);
      } catch (std::exception &e) {
         char message[1024];
         sprintf(message, "Erreur d'ajutement de l'ordre %n. %s",n,e.what());
         throw ::std::exception(message);
      }

      // ---------------------------------------------------------
      // Calcul du niveau moyen du fond sous la trace 
      // (sera utilisé pour exclure les plus forts cosmiques)
      // ---------------------------------------------------------
      double moyenne2 = 0.0;
      k = 0;
      for (int i = ordre[n].min_x - 1; i < ordre[n].max_x - 1; i++, k++)
      {
         moyenne2 += (double)p2[y2 * imax2 + i];
      }
      moyenne2 = moyenne2 / (double)k;

      // -------------------------------------------------------------
      // Calcul du fond sur le spectre (en dessus de la trace)
      // On exclue les points qui sont à 1000 ADU au desssus du fond
      // -------------------------------------------------------------
      double next_i=0;
      double next_mu_i = moyenne2;
      double next_mu_ii=0;
      double next_sx_i = 0;
      double next_sx_ii=0;
      int next_k = 1;

      k = 0;
      cosmicLevel = moyenne2 + 1000.0;  // seuil codé en dur
      for (int i = ordre[n].min_x - 1; i < ordre[n].max_x - 1; i++) {
         if ((double)p2[y2 * imax2 + i] < cosmicLevel) {
            double valeur = (double)p2[y2 * imax2 + i];  // au dessus de la trace du spectre
            x[k] = (double)i;
            y[k] = valeur; 
            w[k] = 1.0;
            k++;
            // calcul de sigma
            next_i= (next_k+1);
            next_k++;
            double delta=valeur-next_mu_i;
            if ( fabs(delta) < epsdouble) {
               if ( delta < 0 ) {
                  delta = -epsdouble ;
               } else {
                  delta = epsdouble ;
               }
            }
            next_mu_ii=next_mu_i+delta/(next_i);
            next_sx_ii=next_sx_i+delta*(valeur-next_mu_ii);
            if ( fabs(next_sx_ii) < epsdouble) {
               if ( next_sx_ii < 0 ) {
                  next_sx_ii = -epsdouble ;
               } else {
                  next_sx_ii = epsdouble ;
               }
            }
            next_mu_i=next_mu_ii;
            next_sx_i=next_sx_ii;
         }
      }

      double prev_sigma=((prev_sx_ii>=0)&&(prev_i>0.))?sqrt(prev_sx_ii/prev_i):0.0;
      double next_sigma=((next_sx_ii>=0)&&(next_i>0.))?sqrt(next_sx_ii/next_i):0.0;
      ordre[n].backgroundLevel = (moyenne1 + moyenne2  )/2;
      ordre[n].backgroundSigma = (prev_sigma + next_sigma)/2;

      rms = 0.0;
      a2 = new double[degre2 + 1];
      for (int i = 0; i <= degre2; i++) a2[i] = 0.0;
      try {
         fitPoly(k, degre2, x, y, w, a2, &rms);
      } catch (std::exception &e) {
         // j'enrichie le message d'erreur
         char message[1024];
         sprintf(message, "Erreur d'ajutement du fond du spectre de l'ordre %n. %s",n,e.what());
         throw ::std::exception(message);
      }

      // ----------------------------------------------------------------------------
      // Soustraction du fond parasite. 
      // On se contente de calculer la moyenne de l'ajustement 
      // entre le dessus et le dessous du spectre colonne par colonne.
      // ----------------------------------------------------------------------------
      for (int i = ordre[n].min_x-1; i < ordre[n].max_x; i++) {
         double v1 = 0.0;
         for (k = 0; k <= degre2; k++)
         {
            v1 = v1 + a1[k] * pow((double)i, (double)k);
         }

         double v2 = 0.0;
         for (k = 0; k <= degre2; k++)
         {
            v2 = v2 + a2[k] * pow((double)i, (double)k);
         }

         int vv = (int) ((v1 + v2) / 2.0);
         for (int j = 0; j < jmax2; j++)
         {
            int adr = j * imax2 + i;
            p2[adr] = p2[adr] - vv;
         }
      }

      // -------------------------------------------------------------
      // Correction de l'inclinaison des raies spectrales (slant)
      // On utilise une interpolation spline de degré 4
      // -------------------------------------------------------------
      double alpha = ordre[n].slant;
      double alpha_rd = alpha*M_PI/180.0;
      int y0 = jmax2 / 2;  // coordonnée de l'axe horizontal central de rotation
      for (int j = 0; j < jmax2; j++)
      {
         double dy = (double)((j+1)-y0);
         double dx = dy * tan(alpha_rd);
         try {
            translate_line(p2, imax2, jmax2, j, dx, 4);
         } catch (std::exception &e) {
            // j'enrichie le message d'erreur
            char message[1024];
            sprintf(message, "Erreur translate_line de l'ordre  %n. %s",n,e.what());
            throw ::std::exception(message);
         }
      }

      // -------------------------------------------------------------
      // Calcul du profil spectral optimal
      // -------------------------------------------------------------
      if ( flag_opt != -1) {
         int wide_y = ordre[n].wide_y;
         int biny1 = jmax2 / 2 - wide_y / 2;
         int biny2 = jmax2 / 2 + wide_y / 2;
         if (flag_opt == 0) {
            l_opt(p2, imax2, jmax2, biny1, biny2, ordre[n].min_x, ordre[n].max_x, processInfo.bordure, profile);
         } else {
            l_opt2(p2, imax2, jmax2, biny1, biny2, ordre[n].min_x, ordre[n].max_x, processInfo.bordure, profile);
         }
      }

      //stopTimer("extract %d ",n);
      delete [] x;
      delete [] y;
      delete [] w;
      delete [] a1;
      delete [] a2;

   } catch (std::exception &e) {
      delete [] x;
      delete [] y;
      delete [] w;
      delete [] a1;
      delete [] a2;
      throw e;
   }

}

/***************************** COMPUTE_SLANT *************************************/
/* Fait "glisser" différentiellement les lignes d'une image                      */
/* La ligne neutre est y0. Compense le tit des raies par rapport                 */ 
/* d'un angle alpha à l'axe de dispersion                                        */
/*********************************************************************************/
/*
int compute_slant(INFOIMAGE *buffer,int y0,double alpha)
{
int j,jmax;
double alpha_rd,dx,dy;

if (buffer->pic==NULL) return 1;
jmax=buffer->jmax;
alpha_rd=alpha*PI/180.0;

for (j=0;j<jmax;j++)
   {
   dy=(double)((j+1)-y0);
   dx=dy*tan(alpha_rd);
   if (translate_line(buffer,j,dx)==1) return 1;
   }

return 0;
}
*/

/************************************ PREDIC_POS **********************************/
/* Prédit la position d'une raie dans l'image                                     */
/* et retourne l'offset suivant X par rapport à la position effectivement mesurée */
/* (lambda, order) sont la longueur et l'ordre nominal de la raie                 */
/**********************************************************************************/
int predic_pos(double lambda, double x_mesure, PROCESS_INFO &processInfo,INFOSPECTRO &spectro, double *dx)
{
double k = processInfo.referenceOrderNum;
double imax = spectro.imax;


double gamma=spectro.gamma*PI/180.0;
double alpha=spectro.alpha*PI/180;
double beta,beta2,posx;

   if ( spectro.alpha > SEUIL_ALPHA ) {
      beta=asin((k*spectro.m*lambda/1e7-cos(gamma)*sin(alpha))/cos(gamma));
      beta2=beta-alpha;
      posx=spectro.focale*beta2/spectro.pixel+(double)imax/2.0;
   } else {      
      beta = spectro.beta*PI/180;
      posx = (lambda - (sin(alpha)+sin(beta))*1.0e7/ (k*spectro.m)) / (spectro.pixel *1.0e7 *cos(beta)/(spectro.m *k * spectro.focale)) + imax/2.0;
   }
   *dx=x_mesure-posx;

   return 0;
}



/************************ LINE_POS_APPROX *****************************/
/* Dans le vecteur buf, retourne la position du pixel d'intensité     */
/* maximale, recherchée dans une fenêtre                              */ 
/* de largeur wide (pixel) centrée sur la coordonnées pos.            */
/* La longueur du vecteur est taille.                                 */
/* Le resultat est retourné dans la variable posx                     */
/**********************************************************************/
void line_pos_approx(int pos,int wide,std::valarray<double> &buf,int &posx)
{
   int i;
   int x1,x2,wide2;

   wide2=wide/2;
   x1=pos-wide2;
   x2=pos+wide2;

   if (x1<0)
   {
      x1=0;
      x2=x1+wide;
   }

   if (x2>(int)buf.size()-1)
   {
      x2=(int)buf.size()-1;
      x1=x2-wide;
   }

   double max=-1e-10;
   for (i=x1;i<x2;i++)
   {
      if (buf[i]>max)
      {
         max=buf[i];
         posx=i;  // origine (0) 
      }
   } 
}

/***************************** SPEC_CDG ********************************/
/* Calcule le centre de gravité dans un profil                         */
/* La fenêtre de calcul est centrée sur pos et de la largeur wide      */
/* La taille du vecteur analysé est taille.                            */
/* Le vecteur est pointé par buf. Le résultat est retrourné dans pos_x */                        
/***********************************************************************/
int spec_cdg(int pos,int wide,int taille,double *buf,double *pos_x)
{
   int i;
   int x1,x2,wide2;
   double v;
   double s1=0.0;
   double s2=0.0;

   wide2=wide/2;
   x1=pos-wide2;
   x2=pos+wide2;

   if (x1<0)
   {
      x1=0;
      x2=x1+wide;
   }

   if (x2>taille-1)
   {
      x2=taille-1;
      x1=x2-wide;
   }

   for (i=x1;i<x2;i++)
   {
      if (i>=0 && i<taille)
      {
         v=buf[i];
         s1=s1+(double)i*v;
         s2=s2+v;
      }
      else
         return 1;
   }

   if (s2==0)
      *pos_x=0;
   else
      *pos_x=s1/s2;

   return 0;
}

// ///////////////////////////////////////////////////////////////////////////////
// Retourne la longueur d'onde théorique à partir de la position px dans l'image
// ///////////////////////////////////////////////////////////////////////////////
double compute_px2lambda(double px, double k, double dx, INFOSPECTRO &spectro)
{
   double gamma = spectro.gamma * PI / 180.0;
   double alpha = spectro.alpha * PI / 180.0;
   double beta, beta2;
   double xc = (double)spectro.imax / 2.0;

   beta2 = (px - xc - dx) * spectro.pixel / spectro.focale;
   beta = beta2 + alpha;
   double lambda = 1.0e7 * cos(gamma) * (sin(alpha) + sin(beta)) / k / spectro.m;
   return lambda;
}


/********************************* CALIB_SPEC *********************************/
/* Calibration spectrale de l'ordre n (calcul des polynomes de dispersion)    */
/* La position approximative des raies est calculée avec la formule du réseau */
/* V1.4 -> retourne le nombre de raies retenues + nombre itération            */
/******************************************************************************/
void calib_spec(int n,int nb_iter,PROCESS_INFO &processInfo, INFOSPECTRO &spectro,
                std::valarray<double> &calibRawProfile, ORDRE *ordre,
                ::std::list<double> &lineList, ::std::list<LINE_GAP> &lineGapList)
{

   double coef = 1.4;          // coefficient de réjection du sigma-clipping
   double position[MAX_LINES];
   double table_lambda[MAX_LINES];
   double delta_lambda[MAX_LINES];
   double result_lambda[MAX_LINES];    // table des longueur d'onde des raies analysees
   double result_position[MAX_LINES];   // table des positions des raies analysees
   int    result_flag[MAX_LINES];     // table des resultats d'analyse 1=OK 0=erreur 
   double w[MAX_LINES];
   double a[4]; 
   double rms = 0;
   double fwhm = 0.0;
   int wide_x=ordre[n].wide_x;  // largeur de la zone de recherche d'une raie (en pixels)

   double lambda;
   double alpha=spectro.alpha;
   double gamma=spectro.gamma;
   double m=spectro.m;
   double focale=spectro.focale;
   double pixel=spectro.pixel;

   try {
      memset(position,0,MAX_LINES*sizeof(double));
      memset(table_lambda,0,MAX_LINES*sizeof(double));
      memset(delta_lambda,0,MAX_LINES*sizeof(double));
      memset(result_lambda,0,MAX_LINES*sizeof(double));
      memset(result_position,0,MAX_LINES*sizeof(double));
      memset(result_flag,0,MAX_LINES*sizeof(int));
      memset(w,0,MAX_LINES*sizeof(double));
      memset(a,0,4*sizeof(double));

      double psf_posx;
      int pos2;
      double dx=0;
      double px;
      int calib_degre = 3;
      double sfwhm = 0;

      ordre[n].a0 = 0; 
      ordre[n].a1 = 0;
      ordre[n].a2 = 0; 
      ordre[n].a3 = 0; 

      // Calcul de l'écart (dx) entre la position fourni et la position mesurée de 
      // la raie du thorium à 6584 A
      predic_pos(processInfo.referenceOrderLambda, processInfo.referenceOrderX, processInfo,spectro,&dx);      

      int nb_analyse=0;
      int kk=0;
      for (int ni=0;ni<nb_iter;ni++) {
         sfwhm=0.0;
         nb_analyse=0;      // nombre de raies analysees dans l'ordre
         kk = 0;            // nombre de raies reconnues dans l'ordre
         
         ::std::list<double>::iterator iter;
         for (iter=lineList.begin(); iter != lineList.end(); ++iter) 
         {            
            lambda = *iter;
            double px0=compute_pos((double)n,lambda,dx, spectro);
            // correction de la distorsion;
            px = 0 ;
            if (spectro.distorsion.size() > 0 ) {
               for (unsigned int index = 0; index < spectro.distorsion.size(); index++) {
                  px = px + spectro.distorsion[index] * pow(px0, (double)index);
               }
            } else {
               px = px0;
            }
            
            // On vérifie que la position tombe dans l'intervalle spécifié
            if ((int)px>(ordre[n].min_x+(wide_x/2+1)+ processInfo.bordure) && 
                (int)px<(ordre[n].max_x-(wide_x/2+1)- processInfo.bordure)) 
            {                                                       
               pos2=(int)px-ordre[n].min_x-processInfo.bordure;
               int pos = 0;
               // je recherche la position approximative de la raie (pixel le plus intense) dans la zone de largeur wide_x 
               line_pos_approx(pos2,wide_x,calibRawProfile,pos);
               
               // ajustement gaussien 
               double ecartType;               
               if ( spec_gauss(pos,9,calibRawProfile,psf_posx,fwhm,ecartType) == 0 ) { 
                  if (ni!=0) { 
                     // sigma-clipping au-delà de la première itération
                     double calc = 0;
                     // je calcule la longueur d'onde correspondant à position observee
                     for (int index = 0; index <= calib_degre; index++) {
                        calc = calc + a[index] * pow(psf_posx, (double)index);     
                     }
                     double lambda_estime = compute_px2lambda(psf_posx + (double)ordre[n].min_x, n, dx, spectro) + calc;

                     if (fabs(lambda-lambda_estime) < coef*rms) { // sigma-clipping
                        sfwhm=sfwhm+fwhm; 
                        table_lambda[kk]=lambda;
                        position[kk]=psf_posx;
                        w[kk]=1.0;

                        double lambda_calcule = compute_px2lambda(position[kk] + (double)ordre[n].min_x, n, dx, spectro);
                        delta_lambda[kk] = table_lambda[kk] - lambda_calcule; // écart entre lambda_effectif et lambda calculé à partir de la position observée
                        
                        if (ni == nb_iter - 1)  // on ne trace et on ne conserve que les raies valides
                        {
                           result_lambda[nb_analyse]=lambda; 
                           result_position[nb_analyse]=psf_posx; 
                           result_flag[nb_analyse] = 1;
                        }
                        // je memorise le resultat de l'analyse
                        //result_lambda[nb_analyse]=lambda; 
                        //result_position[nb_analyse]=psf_posx; 
                        //result_flag[nb_analyse] = 1;

                        kk++;  
                        if (kk > MAX_LINES) {
                           kk--;
                           break;
                        }                        
                     } else {
                       // je memorise le resultat de l'analyse
                       result_lambda[nb_analyse]=lambda; 
                       result_position[nb_analyse]=psf_posx; 
                       result_flag[nb_analyse] = -2;
                     }
                  } else {   // première itération                  
                     sfwhm=sfwhm+fwhm; 
                     table_lambda[kk]=lambda;
                     position[kk]=psf_posx;
                     w[kk]=1.0; 

                     double lambda_calcule = compute_px2lambda(position[kk] + (double)ordre[n].min_x, n, dx, spectro);
                     delta_lambda[kk] = table_lambda[kk] - lambda_calcule; // écart entre lambda_effectif et lambda calculé à partir de la position observée
                     
                     if (nb_iter == 1)
                     {
                        result_lambda[nb_analyse]=lambda; 
                        result_position[nb_analyse]=psf_posx; 
                        result_flag[nb_analyse] = 1;
                     }
                     kk++;
                     if (kk > 500) {
                        kk--;
                        break;
                     }   
                  }
               } else {
                  // je memorise le resultat de l'analyse
                  result_lambda[nb_analyse]=lambda;
                  result_position[nb_analyse]=pos;
                  result_flag[nb_analyse] = 0; 
               }
               nb_analyse++;
            }
         }

         if ( kk < 2 ) {
            char message[1024];
            sprintf(message, " %d lines detected on order %d in iteration %d. Must be >=2 lines.",kk,n,nb_iter);
            throw ::std::exception(message);
         }
         // on ajuste le polynome
         for (int index = 0; index <= calib_degre; index++) a[index] = 0.0;
         if (kk<=2) {
            // on ajuste ordre 1
            fitPoly(kk,1,position,delta_lambda,w,a,&rms);            
         } else if (kk==3){
            // on ajuste ordre 2
            fitPoly(kk,2,position,delta_lambda,w,a,&rms); 
         } else {
            // on ajuste ordre 3 
            fitPoly(kk,3,position,delta_lambda,w,a,&rms); 
         }         
      }  // fin for nb_iter
      
      // je copie le polynome dans les parametres de l'ordre
      ordre[n].a0=a[0];
      ordre[n].a1=a[1];
      ordre[n].a2=a[2];
      ordre[n].a3=a[3];
      ordre[n].rms_calib_spec=rms;
      ordre[n].fwhm=sfwhm/(double)kk;
      // on reboucle sur la liste des raies pour trouver les ecarts O-C (observe - calcule)
      for (int i=0;i<nb_analyse;i++)
      {
         LINE_GAP lineGap;
         lineGap.order  = n;
         lineGap.l_obs  = result_lambda[i];
         lineGap.valid  = result_flag[i];

         double calc = 0.0;
         for (int index = 0; index <= calib_degre; index++) {
            calc = calc + a[index] * pow(result_position[i], (double)index);
         }
         lineGap.l_calc = compute_px2lambda(result_position[i] + (double)ordre[n].min_x, n, dx, spectro) + calc;
         lineGap.l_diff = result_lambda[i] - lineGap.l_calc;
         lineGap.l_posx = result_position[i]+ ordre[n].min_x + processInfo.bordure;
         
         double y=0.0;
         //for (int k=0;k<=POLY_ORDER_DEGREE;k++) {
         //   y=y+ordre[n].poly_order[k]*pow(lineGap.l_posx,(double)k);
         //}
         for (int k=POLY_ORDER_DEGREE;k>=0;k--) {
            y += ordre[n].poly_order[k];
            if (k > 0 ) y *= lineGap.l_posx;
         }
         lineGap.l_posy = y;
         lineGapList.push_back(lineGap);
      }
      
      // on calcule la dispersion moyenne ajustee a l'ordre 1
      fitPoly(kk,1,position,table_lambda,w,a,&rms); 
      ordre[n].disp=a[1];
      ordre[n].central_lambda = compute_px2lambda((double)(spectro.imax / 2), n, dx, spectro);
      // je calcule la resolution
      ordre[n].resolution = ordre[n].central_lambda/(ordre[n].disp*ordre[n].fwhm);
      // je stocke le nombre de raies reconnues
      ordre[n].nb_lines=kk;  // nouveauté v1.4
      
   } catch (std::exception &e) {
      // rien a desallouer
      throw e;
   } 

}


/********************************* CALIB_SPEC *********************************/
/* Calibration spectrale de l'ordre n (calcul des polynomes de dispersion)    */
/* La position approximative des raies est calculée avec la formule du réseau */
/* V1.4 -> retourne le nombre de raies retenues + nombre itération            */
/******************************************************************************/

/*************************** MAKE_INTERPOL *****************************/
/* On re-interpolle le spectre table_in avec un polynome de degré 3    */
/* dont les coefficient sont donné en paramètres. Le pas du spectres   */
/* résultat est donné par la variable pas. Le résutat est le profil    */
/* spectral nom_out.                                                   */
/* On normalise les intensité au point max.                            */
/***********************************************************************/
int make_interpol(std::valarray<double> &table_in, 
                  INFOSPECTRO &spectro, PROCESS_INFO &processInfo,
                  ORDRE *ordre, int n, double dx, double step,
                  std::valarray<double> &table_out, double &lambda1)
{
   double x;
   double *rx = NULL;
   double *ry = NULL;
   double *a = NULL;
   double *b = NULL;
   double *c = NULL;
   double *result = NULL;
   double *lamb = NULL;

   try {
      int taille0 = table_in.size();
      rx = new double[taille0];
      ry = new double[taille0];
      a  = new double[taille0];
      b  = new double[taille0];
      c  = new double[taille0];
      lamb = new double[taille0];

      // Associe une longueur d'onde à chaque pixel
      if ( processInfo.version < 2) {
         for (int i=0;i<taille0;i++) {
            x=(double)(i + processInfo.bordure);
            lamb[i]=ordre[n].a3*x*x*x + ordre[n].a2*x*x + ordre[n].a1*x + ordre[n].a0;
         }
      } else {
         for (int i=0;i<taille0;i++) {
            x=(double)i;  
            double v =(((ordre[n].a3*x) + ordre[n].a2)*x + ordre[n].a1)*x + ordre[n].a0;
            // la longueur d'onde du point x est égale au modèle théorique + l'écart donné par le polynôme
            lamb[i] = compute_px2lambda(x + ordre[n].min_x, n, dx, spectro) + v;
         }
      }

      // Calcul des coefficients de spline
      for (int i=0;i<taille0;i++)
      {
         rx[i]=lamb[i];
         ry[i]=table_in[i];
      }
      spline(taille0,rx,ry,a,b,c);

      // Calcul de la taille du profil de sortie
      int taille=int((lamb[taille0-1]-lamb[0])/step);

      result = new double[taille];

      // Interpollation spline 
      double lambda0=(double)((int)lamb[0]+1);  // on commence par un nombre entier (juste supérieur)
      for (int i=0;i<taille;i++)
      {
         x=lambda0+(double)i*step;
         if (x<lamb[0] || x>lamb[taille0-1]) {
            result[i]=0.0;
         } else {
            // modif isis 5.4.1
            //result[i]=seval(taille0,x,rx,ry,a,b,c);
            result[i]=seval(taille0,x,rx,ry,a,b,c,false);
         }
      }

      //  je calcule la taille du profil resultat
      //if ( taille-2 < (lamb[taille0-1]-lambda0)/step ) {
      //   table_out.resize(taille-2);
      //} else {
      //   table_out.resize(int((lamb[taille0-1]-lambda0)/step));
      //}

      // on compte le nombre de points dans le spectre
      int nb_out = 0;
      for (int i = 1; i < taille - 1; i++)
      {
         x = lambda0 + (double)i * step;
         if (x > lamb[taille0 - 1]) break;  // on ne couvre que le domaine spectral d'entrée
         nb_out++;
      }
      table_out.resize(nb_out);


      //  Sauvegarde du profil
      //  attention : l'abscisse démarre à 1
      for (int i=1;i<=nb_out;i++) {         
         x=lambda0+(double)i*step;
         //if (x>lamb[taille0-1]) break;  // on ne couvre que le domaine spectral d'entrée
         table_out[i-1]= result[i];
      }
      // lamba correspondant à l'abcisse 1
      lambda1 =lambda0+step;
      
      delete [] rx;
      delete [] ry;
      delete [] a;
      delete [] b;
      delete [] c;
      delete [] lamb;
      delete [] result;
   } catch (std::exception &e) {
      delete [] rx;
      delete [] ry;
      delete [] a;
      delete [] b;
      delete [] c;
      delete [] lamb;
      delete [] result;
      throw e;
   }

   return 0;
}

/*************************** INTERPOL_SPEC ****************************/
/* Interpolle un profil spectral à partir de coefficients de          */
/* dispersion polynomiaux (degrés 3).                                 */
/* L'ordre du profil traité est n.                                    */
/* Le profil d'entrée est n_entree, le profil de sortie est n_sortie. */
/**********************************************************************/
void Eshel_interpolProfile(char *fileName)
{
   CCfits::PFitsFile pFits = NULL;
   ORDRE *ordre = NULL;
   double *profile = NULL;
   INFOSPECTRO spectro;
   PROCESS_INFO processInfo;
   double dx_ref=0.0;

   try {
      pFits = Fits_openFits(fileName, true);
      // je lis les parametres spectro 
      Fits_getInfoSpectro(pFits, &spectro);
      Fits_getProcessInfo(pFits, &processInfo);
      // je lis les parametres des ordres
      int nbOrder = spectro.max_order - spectro.min_order +1;
      ordre = new ORDRE[MAX_ORDRE];
      memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
      Fits_getOrders(pFits, ordre,&dx_ref);

      for (int n=spectro.min_order;n<=spectro.max_order;n++) {
         if (ordre[n].flag==1) {
            double lambda1; 
            std::valarray<double> rawProfile;
            std::valarray<double> linProfile;
            double step=0.05;
            int min_x; 
            // je recupere le profil brut
            Fits_getRawProfile(pFits, "P_1A_",n,rawProfile, min_x); 
            // j'echantillone lineairement le profil
            make_interpol(rawProfile, spectro, processInfo, ordre , n, dx_ref, step,linProfile, lambda1);
            // j'enregistre le profil dans le fichier
            Fits_setLinearProfile(pFits, "P_1B_",n,linProfile, lambda1, step) ;
         }
      }
      delete [] ordre;
      delete [] profile;
      Fits_closeFits(pFits);
   } catch (std::exception &e) {
      delete [] ordre;
      delete [] profile;
      Fits_closeFits(pFits);
      throw e;
   }
}

/******************************** MERGE_SPECTRE *******************************/
/* Met bout à bout deux ordres contigues (nom1) et (nom2), et produit le       */
/* le profil spectral mosaïque (out).                                          */
/* La zone commun est utilisé pour harmoniser les intensités.                  */
/* On calcule une intensité pondérée dans les zones communes                   */
/*******************************************************************************/ 
void merge_spectre(::std::valarray<double> &value1, double lambda1, double step1, 
                    ::std::valarray<double> &value2, double lambda2, double step2, 
                    ::std::list<double> &mergeProfile, double &mergeLambda1)
{
   {
   int i,j;
   int nb1,nb2;
   double v;
   
   nb1 = value1.size();
   nb2 = value2.size();
 
   double *wave1 = new double[nb1];
   double *wave2 = new double[nb2];
   char   *flag1 = new char[nb1];
   char   *flag2 = new char[nb2];

   for(int i=0; i<nb1; i++ ) { 
      wave1[i] = lambda1 + step1*i;
      flag1[i] = 0;
   }
   for(int i=0; i<nb2; i++ ) { 
      wave2[i] = lambda2 + step2*i; 
      flag2[i] = 0;
   }

   // Calcul du ratio des deux spectres dans la zone de recouvrement
   double s1=0.0;
   double s2=0.0;

   int commun=0;
   int first1=0;
   int last1=0;
   int first2=0;
   int last2=0;
   int flag0=0;

   for (i=0;i<nb1;i++)
   {
      for (j=0;j<nb2;j++)
      {
         if ((int)(100.0*wave1[i])==(int)(100.0*wave2[j]))
         {
            if (flag0 == 0)
            {
               first1 = i;
               first2 = j;
               flag0 = 1;
            }

            last1 = i;
            last2 = j;           
            s1 = s1+value1[i];
            s2 = s2+value2[j];
            commun++;
         }       
      } 
   }

   // calcul du ratio 
   double coef=s1/s2;

   int flag;
   for (i=0;i<nb1;i++)
   {
      flag=0;
      for (j=0;j<nb2;j++)
      {
         if ((int)(100.0 * wave1[i])==(int)(100.0 * wave2[j]) && flag1[i]!= -1 && flag2[j] != -1 )  // zone commune
         {
            v=(value1[i]+value2[j]*coef)/2.0;
            flag1[i] = -1;
            flag2[j] = -1;
            flag=1;
         }
      }
      if (flag==0) { 
         mergeProfile.push_back(value1[i]); 
      } else { 
         mergeProfile.push_back(v); 
      }
   }
   for (i=0;i<nb2;i++)
   {
      if (flag2[i]!=-1)
      {
         mergeProfile.push_back(value2[i]*coef);
      }
   }

   delete [] wave1;
   delete [] wave2;
   delete [] flag1;
   delete [] flag2;
   }

// ==========================
   //{
   //int nb1 = value1.size();
   //int nb2 = value2.size();
 
   //double *wave1 = new double[nb1];
   //double *wave2 = new double[nb2];
   //double *dvalue1 = new double[nb1];
   //double *dvalue2 = new double[nb2];
   //
   //for(int i=0; i<nb1; i++ ) { 
   //   wave1[i] = lambda1 + step1*i;
   //   dvalue1[i] = value1[i];
   //}
   //for(int i=0; i<nb2; i++ ) { 
   //   wave2[i] = lambda2 + step2*i; 
   //   dvalue2[i] = value2[i];
   //}

   //// Calcul du ratio des deux spectres dans la zone de recouvrement
   //
   //   double num3 = (wave1[nb1 - 1] - wave1[0]) / (double) (nb1 - 1);
   //   int num4 = (int) ((wave2[0] - wave1[0]) / num3) + 4;
   //   double num5 = (double) num4 * num3 + wave1[0];
   //   int length = (int) ((wave2[nb2 - 4] - num5) / num3);
   //   double *numArray3 = new double[length];
   //   double *numArray4 = new double[length];
   //   double *b = new double[nb2];
   //   double *c = new double[nb2];
   //   double *d = new double[nb2];
   //   spline(nb2, wave2, dvalue2, b, c, d);
   //   for (int index = 0; index < length; ++index)
   //   {
   //     double u = (double) (num4 + index) * num3 + wave1[0];
   //     double num6 = seval(nb2, u, wave2, dvalue2, b, c, d);
   //     numArray3[index] = u;
   //     numArray4[index] = num6;
   //   }

   //   double s1 = 0.0;
   //   double s2 = 0.0;
   //   for (int index1 = 0; index1 < nb1; ++index1)
   //   {
   //     for (int index2 = 0; index2 < length; ++index2)
   //     {
   //       if ( ((int)((wave1[index1] * 10 + .5) / 10.0))  == ((int)((numArray3[index2] * 10 + .5) / 10.0)) 
   //             && value1[index1] != -32000.0 && numArray4[index2] != -32000.0)
   //       {
   //         s1 += value1[index1];
   //         s2 += numArray4[index2];
   //         break;
   //       }
   //     }
   //   }

   //// je memorise le ratio
   //double coef=s1/s2;

   //int commonWaveEnd = 0;
   //for (int i=0; i<nb1; i++)
   //{
   //   double v = 0.0;
   //   for (int j= 0; j < length; j++)
   //   {
   //      if ( ((int)((wave1[i] * 10 + .5) / 10.0))  == ((int)((numArray3[j] * 10 + .5) / 10.0))  
   //         && value1[i] != -32000.0 && numArray4[j] != -32000.0)  // zone commune
   //      {
   //         v = (value1[i]+numArray4[j]*coef)/2.0;
   //         commonWaveEnd = j;
   //         break;
   //      } else {
   //         v = value1[i];
   //      }
   //   }
   //   mergeProfile.push_back(v); 
   //}

   //for (int i=commonWaveEnd+1; i<length; i++)
   //{
   //   mergeProfile.push_back(numArray4[i]);
   //}

   //delete [] wave1;
   //delete [] wave2;
   //delete [] dvalue1;
   //delete [] dvalue2;

   //delete [] numArray3;
   //delete [] numArray4;
   //delete [] b;
   //delete [] c;
   //delete [] d;
   //
   //}
}





/*********************************** abutOrderWithFlat *************************************/
/* Aboute les ordres 32, 33, 34, 35, 36, 37 et 38 -> zone couverte par les raies du néon */
/*                         */
/*****************************************************************************************/
void abut1bOrder(::std::valarray<::std::valarray<double>> &object1BProfile, double *lambda1, 
                 int min_ordre, int max_ordre, double step,
                 ::std::valarray<double> &full1BProfile, double &fullLambda1)
{
   try {
      
      int firstOrder;

      // je recherche le premier ordre a traiter
      for ( firstOrder=max_ordre; firstOrder <= min_ordre; firstOrder-- ) {
         if ( object1BProfile[firstOrder].size() > 0 ) {
            break;
         }
      }

      if (object1BProfile[firstOrder].size() == 0 ) {
         // aucun profil n'existe
         char message [1024] ; 
         sprintf(message,"No profile found from min_order=%d to max_order=%d", min_ordre, max_ordre);
         throw ::std::exception(message);
      }

      if (firstOrder == min_ordre) {
         // il n'y a qu'un ordre
         full1BProfile = object1BProfile[firstOrder];
         fullLambda1   = lambda1[firstOrder];
         return;
      }

      // je copie le premier ordre dans la variable de travail
      ::std::valarray<double> value1 = object1BProfile[firstOrder];
      fullLambda1 = lambda1[firstOrder];
      ::std::list<double> mergeProfile;

      // je concatene les ordres suivants
      for (int n=firstOrder-1;n>=min_ordre;n--) {
         mergeProfile.clear();
         // j'aboute les 2 profils
         merge_spectre(value1, fullLambda1, step,
            object1BProfile[n], lambda1[n],  step,
            mergeProfile, fullLambda1);
         // je copie le resultat dans value1
         value1.resize(mergeProfile.size());
         ::std::list <double> ::iterator iter;
         size_t i = 0;
         for (iter= mergeProfile.begin(); iter != mergeProfile.end(); iter++ ) {
            value1[i++] = *iter; 
         }
      }
      full1BProfile = value1;
   }
   catch (::std::exception &e) {
      throw e;
   }
}



/********************** COMPUTE_BLACK_BODY ***********************/
/* Retourne l'émittance d'un corps noir en w/cm2/micron          */
/*****************************************************************/
double compute_black_body(double lambda,double temperature)
{
double c1=3.739876e4;
double c2=1.438769e4;
double v;

lambda=lambda/10000.0; // conversion des A en microns
v=c1/pow(lambda,5.0)*(1.0/(exp(c2/lambda/temperature)-1));
return v;
}

/********************************* PLANCK_CORRECT *********************************/
/* Mutiplie le profil d'entrée (in) par la courbe du corps noir pour              */
/* la température (en K) donné en paramètre. Le profil résultat est (out).        */
/* Utile pour compenser la température de couleur de la lampe tungstène utilisée  */
/* pour réaliser le flat-field.                                                   */
/**********************************************************************************/
void planck_correct(std::valarray<double> &profile1b, double lambda1, double step, double temperature)
{
   // Première passe pour calculer la norme à 6690 A 
   // (zone sans raies dans le spectre solaire)
   int nb = profile1b.size();
   double norme=0;
   double coef=0;
   int flag = 0; 

   for(int i=0; i<nb; i++ ) { 
      double wave = lambda1 + step*i; 
      if ((int)(100.0*wave)==669000) {
         coef=compute_black_body(wave,temperature);
         norme=profile1b[i]*coef;
         flag = 1;
      }
   }

   // La zone à 6690 A n'est pas trouvée (absence de l'ordre 34 dans la sélection traitée)
   if (flag == 0) norme = 1.0;

   // Deuxième passe 
   for(int i=0; i<nb; i++ ) { 
      double wave = lambda1 + step*i; 
      coef=compute_black_body(wave,temperature);
      profile1b[i] =  profile1b[i]*coef/norme;         
   }
}



//=====  Hmedian , quicksort ===========================

// ///////////////////////////////////////////////////////
// Routine utilisée par QuickSort
// ///////////////////////////////////////////////////////
int Partition(int a[], int p, int r)
{
   int x = a[p];
   int i = p - 1;
   int j = r + 1;
   int tmp = 0;
   while (true)
   {
      do
      {
         j--;
      } while (a[j] > x);
      do
      {
         i++;
      } while (a[i] < x);
      if (i < j)
      {
         tmp = a[i];
         a[i] = a[j];
         a[j] = tmp;
      }
      else return j;
   }
}

// ////////////////////////////////////////////////////
// Implémentation C# de QuickSort  
// (version intégrée : Array.Sort(a) - mais plus lente)
// ////////////////////////////////////////////////////
void QuickSort(int a[], int i, int j)
{
   if (i < j)
   {
      int q = Partition(a, i, j);
      QuickSort(a, i, q);
      QuickSort(a, q + 1, j);
   }
}

// ///////////////////////////////////////////////////////
// Routine utilisée par QuickSort
// ///////////////////////////////////////////////////////
int Partition(double a[], int p, int r)
{
   double x = a[p];
   int i = p - 1;
   int j = r + 1;
   double tmp = 0.0;
   while (true)
   {
      do
      {
         j--;
      } while (a[j] > x);
      do
      {
         i++;
      } while (a[i] < x);
      if (i < j)
      {
         tmp = a[i];
         a[i] = a[j];
         a[j] = tmp;
      }
      else return j;
   }
}

// ///////////////////////////////////////////////////////
// Implémentation C# de QuickSort  
// (version intégrée : Array.Sort(a) - mais plus lente)
// ///////////////////////////////////////////////////////
void QuickSort(double a[] , int i, int j)
{
   if (i < j)
   {
      int q = Partition(a, i, j);
      QuickSort(a, i, q);
      QuickSort(a, q + 1, j);
   }
}

// ////////////////////////////////////////////////////////////
// HEMDIAN : retourne la valeur médiane de la table data 
// Attention : la table est triée aprés execution      
// ////////////////////////////////////////////////////////////
int hmedian(int data[], int length)
{
   QuickSort(data, 0, length- 1);
   return data[length / 2];
}

// ////////////////////////////////////////////////////////////
// HMEDIAN : Retourne la valeur médiane de la table data 
// Attention : la table est est triée aprés excecution      
// ////////////////////////////////////////////////////////////
double hmedian( double data[], int length)
{
   QuickSort(data, 0, length - 1);
   return data[length / 2];
}

/************************ HMEDIAN ****************************/
/* Retourne la valeur médiane d'un échantillon RA de n point */
/* Attention : l'échantillon est trie aprés excecution       */
/*************************************************************/
/*
PIC_TYPE hmedian(PIC_TYPE *ra,int n)
{
int l,j,ir,i;
PIC_TYPE rra;

if (n<2)
   return *ra;
ra--;
for (l=((ir=n)>>1)+1;;)
   {
   if (l>1)
      rra=ra[--l];
   else
      {
      rra=ra[ir];
      ra[ir]=ra[1];
      if (--ir==1)
	 {
	 ra[1]=rra;
	 return n&1? ra[n/2+1] : (PIC_TYPE)(((double)ra[n/2]+(double)ra[n/2+1])/2.0);
	 }
      }
   for (j=(i=l)<<1;j<=ir;)
     {
     if (j<ir && ra[j]<ra[j+1]) ++j;
     if (rra<ra[j])
	{
	ra[i]=ra[j];
	j+=(i=j);
	}
     else
	j=ir+1;
     }
   ra[i]=rra;
   }
// (le 'return' n'est pas à la fin de la boucle et c'est normal !) 
}
*/

/******************* INTPOWER ********************/
/* Calcule x à la puissance d'un nombre entier   */
/*************************************************/
double intPower(double x,int const_val)
{
double sum;
int i;
int neg;

neg=(const_val < 0 ? 1 : 0);
const_val*=(neg ? -1 : 1);

sum=1.0;
for (i=0;i<const_val;++i) sum*=x;
return (neg ? 1 / sum : sum);
}

/*************************** LINCHOLESKYDECOMP *************************/
/* Résoud le système Ax = b via une décomposition de Cholesky          */
/*                                                                     */
/* Retourne  0 = si succès,                                            */
/*           k = la kth colonne où une singularitée est trouvée.       */
/*                                                                     */ 
/* Maxdim => Max. dimension de la matrice "A" declared in main.        */
/* order => order de la matrice matrix "A".                            */
/*                   a => matrice symétrique positive                  */
/*                   b => vecteur de droite                            */
/* En sortie :                                                         */
/*                   b => vecteur solution (calculé en place)          */
/***********************************************************************/
#undef A
#define A(X,Y) *(a+(X)*dim+(Y))

int linCholeskyDecomp(int dim,int order,double *a,double *b)
{
   double t,s,temp2;
   int info,l,j,jm1,k,kb;

   if (order>dim) return 1;

   for (j=0;j<order;++j)
   {
      info=j+1;
      s=0.0;
      jm1=j-1;
      if (jm1>=0)
      {
         for (k=0;k<=jm1;++k)
         {
            temp2=0.0;
            for (l=0;l<=k-1;++l)
            {
               if ( l >4 ) { 
                  printf( "linCholeskyDecomp l=%d\n",l);
               }
               temp2+=A(l,k)*A (l,j);
            }
            if ( j >4 ) { 
               printf( "linCholeskyDecomp j=%d\n",j);
            }
            if ( k >4 ) { 
               printf( "linCholeskyDecomp k=%d\n",k);
            }

            t=A(k,j)-temp2;
            if ( A(k,k) == 0 ) { 
               printf( "linCholeskyDecomp 1a A(%d,%d)=0\n",k,k);
            }

            t/=A(k,k);
            A(k,j)=t;
            s+=t*t;
         }
      }
      s=A(j,j)-s;
      if (s<=0.0) return info;
      A(j,j)=sqrt(s);
   }

   for (k=0;k<order;++k)
   {
      temp2=0.0;
      for (l=0;l<=k-1;++l)
      {
         temp2+=A(l,k)*b[l];
      }
      t=temp2;
      if ( A(k,k) == 0 ) { 
         printf( "linCholeskyDecomp 1 A(%d,%d)=0\n",k,k);
      }

      b[k]=(b[k]-t)/A(k,k);
   }

   //printf( "linCholeskyDecomp a[3]=%d ",b[3]);
   for (kb=0;kb<order;++kb)
   {
      k=order-kb-1;
      if ( A(k,k) == 0 ) { 
         printf( "linCholeskyDecomp 2 A(%d,%d)=0",k,k);
      }

      b[k]/=A(k,k);
      t=-b[k];
      for (l=0;l<=k-1;++l) b[l]+=t*A(l,k);
   }
   //printf( "  %d\n",b[3]);
   return 0;
}

/**************************** FITPOLY ****************************/
/* Régression polynomiale                                        */
/*                                                               */
/* On donne le jeu de points (x,y) et le poids de chaque point.  */
/* Retourne les coefficients (a0,a1) de l'équation :             */
/*             y[i] = a0 + a1 * x[i] + a2 * x[i]^2               */
/* et l'erreur RMS de la régression                              */
/*                                                               */ 
/* Paramètres d'entrée :                                         */
/*                  n     => nombre de paires (x,y)              */
/*                 degree => degré du polynôme                   */
/*                  (x,y) => tableau de données                  */
/*                  w     => poids de chaque points              */
/* Paramètres de sortie :                                        */ 
/*                  a[i]  => tableau des coefficients            */
/*                  rms   => erreur RMS                          */
/*****************************************************************/
#undef A
#define A(I,J) *(a+(I)*degplus1+(J))

void fitPoly(int numpts,int degree,double *x,double *y,double *wt,double *coeffs,double *rms)
{
   int i,j,k,flag;
   double *a;
   int degplus1;
   double valu1,valu2,linBasisFunc (),ypred,err;

   degplus1=degree+1;
   if ((a=(double *)calloc(degplus1*degplus1,sizeof(double)))==NULL)
   {
      throw std::exception("Pas assez de memoire pour fitPoly()");
   }

   for (i=0;i<=degree;++i)
   {
      for (j=i;j<=degree;++j) A(i,j)=0.0;
      coeffs[i]=0.0;
   }

   for (i=0;i<numpts;++i)
   {
      for (j=0;j<= degree;++j)
      {
         valu1=intPower(x[i],j);
         for (k=j;k<=degree;++k)
         {
            valu2=intPower(x[i],k);
            if ( j >degree ) { 
               printf( "fitPoly j=%d\n",j);
            }
            if ( k >degree ) { 
               printf( "fitPoly k=%d\n",k);
            }
            A(j,k)+=valu1*valu2*wt[i];
         }
         coeffs[j]+=y[i]*valu1*wt[i];
      }
   }

   flag=linCholeskyDecomp(degplus1,degplus1,a,coeffs);
   if (flag==1) 
   {
      throw std::exception("Erreur linCholeskyDecomp");
   }

   *rms=0.0;
   for (i=0;i<numpts;++i)
   {
      ypred = coeffs[0];
      for (j=1;j<=degree;++j) ypred+=coeffs[j]*intPower(x[i],j);
      err=ypred-y[i];
      *rms+=err*err;
   }

   if (numpts<=degplus1)
      *rms=sqrt(*rms/numpts);
   else
      *rms=sqrt(*rms/(numpts-(degplus1)));

   free(a);
}

/******************** SPLINE ***********************/
/* Calcul des coefficients de spline               */
/* A utiliser avec SEVAL pour faire                */
/* l'interpolation spline                          */
/* Les data sont dans (x,y) (premier indice est 0) */
/* Les tables b, c, d contiennent les              */
/* coefficients de spline                          */
/***************************************************/
int spline(int n,double *x,double *y,double *b,double *c,double *d)
{
   int ip1,nm1,nm2,nm3,nm4;
   double t;

   memset(b, 0, n*sizeof(double));
   memset(c, 0, n*sizeof(double));
   memset(d, 0, n*sizeof(double));

   nm1=n-1;
   nm2=n-2;
   nm3=n-3;
   nm4=n-4;
   if (n<2) return 1;
   if (n<3) goto L50;
   d[0]=x[1]-x[0];
   c[1]=(y[1]-y[0])/d[0];
   for (int i=1;i<nm1;i++)
   {
      ip1=i+1;
      d[i]=x[ip1]-x[i];
      b[i]=2.0*(d[i-1]+d[i]);
      c[ip1]=(y[ip1]-y[i])/d[i];
      c[i]=c[ip1]-c[i];
   }
   b[0]=-d[0];
   b[nm1]=-d[nm2];
   c[0]=0.0;
   c[nm1]=0.0;
   if (n!=3)
   {
      c[0]=c[2]/(x[3]-x[1])-c[1]/(x[2]-x[0]);
      c[nm1]=c[nm2]/(x[nm1]-x[nm3])-c[nm3]/(x[nm2]-x[nm4]);
      c[0]*=d[0]*d[0]/(x[3]-x[0]);
      c[nm1]*=-d[nm2]*d[nm2]/(x[nm1]-x[nm4]);
   }
   for (int i=0;i<nm1;i++)
   {
      ip1=i+1;
      t=d[i]/b[i];
      b[ip1]-=t*d[i];
      c[ip1]-=t*c[i];
   }
   c[nm1]/=b[nm1];
   for (int ib=1;ib<=nm1;ib++)
   {
      int i=n-ib-1;
      c[i]=(c[i]-d[i]*c[i+1])/b[i];
   }
   b[nm1]=(y[nm1]-y[nm2])/d[nm2]+d[nm2]*(c[nm2]+2.0*c[nm1]);
   for (int i=0;i<nm1;i++)
   {
      ip1=i+1;
      b[i]=(y[ip1]-y[i])/d[i]-d[i]*(c[ip1]+2.0*c[i]);
      d[i]=(c[ip1]-c[i])/d[i];
      c[i]=3.0*c[i];
   }
   c[nm1]*=3.0;
   d[nm1]=d[nm2];
   return 0;
L50: ;
   b[0]=(y[1]-y[0])/(x[1]-x[0]);
   c[0]=0.0;
   d[0]=0.0;
   b[1]=b[0];
   c[1]=0.0;
   d[1]=0.0;
   return 0;
}

/****************** SEVAL *******************/
/* Interpolation spline                     */
/* u = coordonnée du point à interpoler     */
/* Retourne la valeur interpolée            */
/********************************************/
double seval(int n,double u,double *x,double *y,double *b,double *c,double *d)
{
   int j,k,im1,i;
   double s,dx;

   i=1;
   if (i>=n) i=1;
   if (u<x[i-1]) goto L10;
   if(u<=x[i]) goto L30;

L10: ;
   i=1;
   j=n+1;
   do
   {
      k=(i+j) >> 1;
      if (u<x[k-1]) j=k;
      if (u>=x[k-1]) i=k;
   } while(j>(i+1));

L30: ;
   im1=i-1;
   dx=u-x[im1];
   s=y[im1]+dx*(b[im1]+dx*(c[im1]+dx*d[im1]));
   return(s);
}

/************************** SEVAL ************************/
/* Interpolation spline si flag = true, sinon bilinéaire */
/* u = coordonnée du point à interpoler                  */
/* Retourne la valeur interpolée                         */
/*********************************************************/
double seval(int n, double u, double *x, double *y, double *b, double *c, double *d, bool flag)
{
   double y1 = 0.0;
   int index1 = 1;
   if (index1 >= n)
      index1 = 1;
   if (u < x[index1 - 1] || u > x[index1])
   {
      index1 = 1;
      int num1 = n + 1;
      do
      {
         int num2 = (index1 + num1) >> 1;
         if (u < x[num2 - 1])
            num1 = num2;
         if (u >= x[num2 - 1])
            index1 = num2;
      }
      while (num1 > index1 + 1);
   }
   int index2 = index1 - 1;
   if (flag)
   {
      double num = u - x[index2];
      y1 = y[index2] + num * (b[index2] + num * (c[index2] + num * d[index2]));
   }
   else if (index2 >= 0 && index2 + 1 < n - 1)
   {
      double xa = x[index2];
      double xb = x[index2 + 1];
      double ya = y[index2];
      double yb = y[index2 + 1];
      interpol_2p(xa, ya, xb, yb, u, &y1);
   }
   else
      y1 = 0.0;
   return y1;
}

// ------------------------------------------------------------------------
// Interpolation linéaire entre deux points
// ------------------------------------------------------------------------
void interpol_2p(double xa, double ya, double xb, double yb, double x, double *y)
{
   *y = ya + (x - xa) * (yb - ya) / (xb - xa);
}


/***************************** SPEC_GAUSS ******************************/
/* Ajuste le profil par une gaussienne dans un profil                  */
/* La fenêtre de calcul est centrée sur pos et de la largeur wide      */
/* La taille du vecteur analysé est taille.                            */
/* Le vecteur est pointé par buf. Le résultat est retrourné dans pos_x */                        
/***********************************************************************/
int spec_gauss(int pos,int wide,std::valarray<double> &buf,double &pos_x,double &fwhm,double &ecartType)
{
   std::valarray<double> profil(wide);
   double py[4];
   double ecarty = 0;


   int w2=wide/2;

   int n=0;
   for (int i=pos-w2;i<pos+w2;i++,n++)
   {
      if (i<0 || i>(int)buf.size()-1) return(-1);       
      profil[n]=buf[i];
   }

   py[0]=-32000.0;
   py[1]=0;
   for (int i=0;i<n;i++)
   {
      if (profil[i]>py[0])
      {
         py[0]=profil[i];
         py[1]=i;
      }
   }
   py[2]=2.0; // équivalent à un FWHM de 3.32 pixel
   py[3]=(profil[0]+profil[n-1])/2;
   py[0]=py[0]-py[3];

   MipsParaFit(n, profil, py, ecarty);

   double sigy=sqrt(py[2]/2.0);
   fwhm=2.3548*sigy;       // constante = 2 x sqr(2*ln(2)) -> profil 1D
   ecartType = ecarty;
   // i0=py[0];
   pos_x=py[1]+(double)(pos-w2);

   return(0);
}

// ////////////////////////////////////////////////////////////////////////////////
// Filtrage gaussien du spectre d'ordre n (utilisé, par exemple,
// pour calcul de la fonction de blaze ou pour lisser le spectre final)
// ////////////////////////////////////////////////////////////////////////////////
void spectre_gauss(::std::valarray<double> &profile, double sigma, int n)
{
   try
   {
      int nb_point = profile.size();
      
      ::std::valarray<double> filtre(500);
      int largeur=(int)(5.0*sigma+1.0);
      if (largeur < 3) largeur = 3;
      int reste = largeur % 2;
      if (reste == 0) largeur = largeur + 1;

      int largeur2 = (largeur-1)/2;    
      if (largeur2 < 2) largeur2 = 2;
      ::std::valarray<double> buf(nb_point);

      // calcul du filtre 
      double somme = 0.0;
      for (int i=0; i < largeur; i++)
      {
         double ilarg=(double)(i-largeur2);
         filtre[i] = exp(-ilarg*ilarg/2.0/sigma/sigma);
         somme = somme + filtre[i];
      }
      for (int i=0; i < largeur; i++) {
         filtre[i] = filtre[i] / somme;
      }

      //::std::valarray<double> buf(nb_point);

      // Application du filtre
      for (int i = 0; i < nb_point; i++)
      {
         double val=0.0;
         for (int k = 0; k < largeur; k++)
         {
            int i1 = i + k - largeur2;
            if (i1 < 0) i1 = 0;
            if (i1 > nb_point - 1) i1 = nb_point - 1;
            val += filtre[k] * profile[i1];
         }
         buf[i] = val;
      }
// je supprime un conflit avec la macro max qui est dans stdlib
#undef max 
      // je recupere la valeur max 
      double max = buf.max();
      // Normalisation
      profile = buf / max;

   }
   catch (std::exception e)
   {
      throw e;
   }
}                                       

/******************* MipsParaFit *******************/
/* Fittage de l'équation S=I0*exp(-r2/sigma2)+fond */
/* n=nombre de points à fitter                     */
/* y()=tableau des points                          */
/* p()=tableau des variables:                      */
/*     p[0]=I0                                     */
/*     p[1]=r                                      */
/*     p[2]=sigma2                                 */
/*     p[3]=fond                                   */
/* ecart=ecart-type                                */
/***************************************************/
void MipsParaFit(int n, std::valarray<double> &y, double *p, double &ecart)
{
int l=0,nbmax=0,m=0;
double l1=0,l2=0,a0=0;
double e=0,er1=0,x=0,y0=0;
double m0=0,m1=0;
double e1[4];
int i,j;

ecart=1.0;

l=4;        /* nombre d'inconnues */
e=.0001;     /* erreur maxi. */
er1=0.5;     /* dumping factor */
nbmax=250;  /* nombre maximum d'itérations */

for (i=0;i<l;i++)
   {
   e1[i]=er1;
   }
m=0;
l1=1.0e10;

b1:
for (i=0;i<l;i++)
   {
   a0=p[i];
b2:
   l2=0;
   for (j=0;j<n;j++)
      {
      x=(double)j;
      if (p[2]<.05) return; // contrôle débordement à cause d'un petit sigma
      y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
      l2=l2+(y[j]-y0)*(y[j]-y0);
      }
   m0=l2;
   p[i]=a0*(1-e1[i]);
   l2=0;
   for (j=0;j<n;j++)
      {
      x=(double)j;
      if (p[2]<.05) return; // contrôle débordement à cause d'un petit sigma
      y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
      l2=l2+(y[j]-y0)*(y[j]-y0);
      }
   ecart=sqrt((double)l2/(n-l));
   m1=l2;
   if (m1>m0) e1[i]= -e1[i]/2;
   if (m1<m0) e1[i]= 1.2*e1[i];
   if (m1>m0) p[i]=a0;
   if (m1>m0) goto b2;
   }
m++;
if (m==nbmax) return;
if (l2==0) return;
if (fabs((l1-l2)/l2)<e) return;

l1=l2;
goto b1;
}

//=== fin du source 1.2


/********************************************************************
 * Function: polynomialCoefficients                                 *
 *                                                                  * *                                                                  *
 * Purpose:  Given a set of data points, this function determines   *
 *           the coefficients of an Nth-order polynomial :          *
 *                                                                  *
 *           y = a0 + a1*x + a2*x*x + a3*x*x*x + ........           *
 *                                                                  *
 * Returns:  point evaluated at middle of numpts.                   *
 *                                                                  *
 * Call:     y = polynomialCoefficients ( n, d, x, y, w ) where:    *
 *                                                                  *
 *           input :                                                *
 *                   n => number of data points                     *
 *                   d => degree of regression                      *
 *                   x => one-dimensional x-array                   *
 *                   y => one-dimensional y-array                   *
 *                   w => one-dimensional weights per x-y point     *
 *           output :                                               *
 *                   none                                           *
 ********************************************************************/
#undef  A
#define A(I,J) *(a+(I)*degplus1+(J))
double polynomialCoefficients (int numpts, int degree,
                               double *x,double *y,double *wt)

{
int i,j,k,flag,degplus1;
double *a,*coeffs;
double valu1,valu2,xval,yval;

degplus1 = degree + 1;

if ((a = (double *) calloc (degplus1 * degplus1, sizeof (double))) == NULL) 
   {
   printf("\nPas assez de memoire.\n");
   return 0.0;
   }

if ((coeffs = (double *) calloc (degplus1, sizeof (double))) == NULL) 
   {
   printf("\nPas assez de memoire.\n");
   return 0.0;
   }

for (i = 0; i <= degree; ++i) 
   {
   for (j = i; j <= degree; ++j) 
      {
		A (i, j) = 0.0;
      }
   coeffs[i] = 0.0;
   }

for (i = 0; i < numpts; ++i) 
   {
   for (j = 0; j <= degree; ++j) 
      {
	   valu1 = intPower (x[i], j);
      for (k = j; k <= degree; ++k) 
         {
		   valu2 = intPower (x[i], k);
		   A (j, k) += valu1 * valu2 * wt[i];
	      }
	   coeffs[j] += y[i] * valu1 * wt[i];
      }
   }

flag = linCholeskyDecomp (degplus1, degplus1, a, coeffs);

/* evaluate y at middle of span */
xval = x[numpts / 2];
yval = 0;
for (i = 0; i < degplus1; ++i) 
   {
   yval += coeffs[i] * intPower (xval, i);
   }

free(a);
free(coeffs);
return yval;
}

/********************************************************************
 * Function: smthPolyAverage                                        *
 *                                                                  *
 * Purpose:  Smoothing via Nth-order polynomial(least-squares)      *
 *                                                                  *
 * Call:                                                            *
 *           smthPolyAverage( numpts, span, degree, x, y, ynew, wt )*
 *                                                                  *
 *           input :                                                *
 *              numpts => number of data points                     *
 *                span => portion of x,y vector to fit (must be odd)*
 *              degree => degree of fit desired (2 = parabolic)     *
 *                   x => one-dimensional x-array                   *
 *                   y => one-dimensional y-array                   *
 *                  wt => one-dimensional weights per x-y point     *
 *           output :                                               *
 *                 ynew=> predicted y-values based on smooth        *
 ********************************************************************/
int smthPolyAverage(int numpts,int span,int degree, 
                    double *x, double *y, double *ynew, double *wt)
{
int i,startspan,midspan,numloops;

if (span % 2 == 0) 
   {
	printf ("smthPolyAverage:The span can't be an even number.\n");
	return 1;
   }

if (span > numpts)
   {
	printf ("smthPolyAverage:The span can't be greater than numpts.\n");
   return 1;
   }

if (degree + 2 > numpts) 
   {
	printf ("smthPolyAverage:Degree+2 can't be greater than numpts");
   return 1;
   }

startspan = 0;
midspan = span / 2;
numloops = numpts - span + 1;

/* fill in all of ynew array */
for (i = 0; i < numpts; ++i) 
   {
	ynew[i] = y[i];
   }
    
for (i = 0; i < numloops; ++i) 
   {
	ynew[midspan] = polynomialCoefficients (span, degree, &x[startspan],
				     &y[startspan], &wt[startspan]);
	++startspan;
	++midspan;
   }

return 0;
}

/********************************************************************
 *  Function: smthMovingAverage                                     *
 *                                                                  *
 *  Purpose:  Perform a n-point moving average on the data array    *
 *            passed to the function. The average is done in-place  *
 *            so the original data is lost. Nothing is done to the  *
 *            end points.                                           *
 *                                                                  *
 *  Call:     smthMovingAverage ( pts, n, data )                    *
 *                                                                  *
 *       input:                                                     *
 *            pts = number of data points in array data[].          *
 *              n = number of points used in average, must be odd.  *
 *           data = array of data to be averaged.                   *
 *                                                                  *
 *       output:                                                    *
 *           data = contains the averaged data. The n/2 end points  *
 *                  are not changed. The original data is lost.     *
 ********************************************************************/
int smthMovingAverage (int pts, int n,double *data)
{
int i,halfn,j;
double *work,worksum,datasum;

if ((n % 2 == 0) || (n < 3) || (n > pts)) 
   {
   printf ("smthMovingAverage: Invalid smoothing parameter.");
   return 1;
   }

if ((work = (double *) calloc ((n / 2 + 1), sizeof (double))) == NULL) 
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }

halfn = (n - 1) / 2;
    
for (i = 0; i < halfn; ++i) 
   {
	work[i] = data[halfn - i - 1];
   }

for (i = halfn; i < pts - halfn; ++i) 
   {
	worksum = 0.0;
	datasum = data[i];
	for (j = 0; j < halfn; ++j) 
      {
	   worksum += work[j];
	   datasum += data[i + j + 1];
	   }

   for (j = halfn - 1; j > 0; --j) 
      {
	   work[j] = work[j - 1];
   	}
   work[0] = data[i];

   data[i] = (worksum + datasum) / n;
   }

free(work);

return 0;
} 

/********************************************************************
 *      Function: crvLinearLeastSqr                                 *
 *                                                                  *
 *      Purpose:  Given a set of x, y data points, and a weight     *
 *                at each point, two coefficients, a0 and           *
 *                a1 are calculated such that                       *
 *                    y[i] = a0 + a1 * x[i]                         *
 *                in the least squares sense.                       *
 *                The root-mean-square-error of regression is also  *
 *                calculated.                                       *
 *                                                                  *
 *      Returns:  status (0 = sucessful, 1 = failure)               *
 *                                                                  *
 *      Call:     status = crvLinearLeastSqr			                 *
 *				( n, x, y, w, &a0, &a1, &rms )                          *
 *                                                                  *
 *                input :                                           *
 *                        n => number of x, y data pairs,           *
 *                        x => x-values data array,                 *
 *                        y => y-values data array,                 *
 *                        w => weight at each point.                *
 *                output :                                          *
 *                       a0 => slope,                               *
 *                       a1 => y-intercept.                         *
 *                      rms => root-mean-square-error of regression *
 ********************************************************************/
int crvLinearLeastSqr(int numpts,double *xarray,double *yarray,double *wt,
                      double *a0,double *a1,double *rms)
{
int  i;
double y1sum,x1sum,y2sum,x2sum,x1y1sum,determ;
double *x,*y,sum,err,ypred;

sum = y1sum = x1sum = y2sum = x2sum = x1y1sum = 0.0;

x = xarray;
y = yarray;

for (i = 0; i < numpts; ++i, ++x, ++y, ++wt)
   {
	sum += (*wt);
	y1sum += (*y) * (*wt);
	x1sum += (*x) * (*wt);
	y2sum += (*y) * (*y) * (*wt);
	x2sum += (*x) * (*x) * (*wt);
	x1y1sum += (*y) * (*x) * (*wt);
   }

/* calculate determinant */
determ = sum * x2sum - x1sum * x1sum;
if (determ == 0.0) 
   {
	return 1;
   }

/* find regression coefficients */
(*a0) = (y1sum * x2sum - x1y1sum * x1sum) / determ;
(*a1) = (sum * x1y1sum - x1sum * y1sum) / determ;

/* re-initialize pointers */
x = xarray;
y = yarray;

/* calculate rms */
(*rms) = 0.0;
for (i = 0; i < numpts; ++i, ++x, ++y) 
   {
	ypred = (*a0) + (*a1) * (*x);
	err = ypred - (*y);
	(*rms) += err * err;
   }

if (numpts <= 2) 
   {
	(*rms) = sqrt ((*rms) / numpts);
   }
else 
   {
	(*rms) = sqrt ((*rms) / (numpts - 2.0));
   }

return 0;
}

/*************************** HMEDIAN2 *************************/
/* Retourne la valeur médiane d'un échantillon RA de n point  */
/* Le trie croissant est effectué sur ra et t2 est déplace    */
/* simultanément.                                             */
/**************************************************************/
double hmedian2(double *ra,double *t2,int n)
{
int l,j,ir,i;
double rra,rt2;

if (n<2)
   return *ra;
ra--;
t2--;
for (l=((ir=n)>>1)+1;;)
   {
   if (l>1)
      {
      rra=ra[--l];
      rt2=t2[l];
      }
   else
      {
      rra=ra[ir];
      rt2=t2[ir];
      ra[ir]=ra[1];
      t2[ir]=t2[1];
      if (--ir==1)
	     {
	     ra[1]=rra;
	     t2[1]=rt2;
	     return n&1? ra[n/2+1] : (short)(((double)ra[n/2]+(double)ra[n/2+1])/2.0);
	     }
      }
   for (j=(i=l)<<1;j<=ir;)
     {
     if (j<ir && ra[j]<ra[j+1]) ++j;
     if (rra<ra[j])
	    {
	    ra[i]=ra[j];
	    t2[i]=t2[j];
	    j+=(i=j);
	    }
     else
	 j=ir+1;
     }
   ra[i]=rra;
   t2[i]=rt2;
   }
/* (le 'return' n'est pas à la fin de la boucle et c'est normal !) */
}

/********************************* FIND_CONTINUUM ********************************/
// Détection automantique du continuum             
// V1.3
/*********************************************************************************/
int find_continuum(char *n_spectre,char *n_continuum)
{
FILE *hand_spectre,*hand_out;
char nom_spectre[_MAX_PATH];
char ligne[256];
double lambda,value;
double *x,*y,*yref,*a,*wt;
double *xx,*yy,*wwt;
double *xxx,*yyy;
int i,it;

sprintf(nom_spectre,"%s.dat",n_spectre);

if ((hand_spectre=fopen(nom_spectre,"r") ) == NULL) 
   {
   printf("\nLe fichier %s est introuvable.\n",nom_spectre);
   return 1;
   }

// On compte le nombre de lignes   
int k=0;
while (fscanf(hand_spectre,"%lf %lf",&lambda,&value)!=EOF && k!=50000)
   {
   k++;
   }
fclose(hand_spectre);

// Allocations mémoire
if ((x=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   return 1;
   }
if ((y=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   return 1;
   }
if ((yref=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   return 1;
   }
if ((wt=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   return 1;
   }
if ((a=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt); 
   return 1;
   }
if ((xx=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   return 1;
   }
if ((yy=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   return 1;
   }
if ((wwt=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   return 1;
   }
if ((xxx=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   return 1;
   }
if ((yyy=(double *)calloc(k,sizeof(double)))==NULL)
   {
   printf("\nPas assez de memoire.\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   return 1;
   }

// Lecture du spectre
hand_spectre=fopen(nom_spectre,"r");
k=0;
while (fscanf(hand_spectre,"%lf %lf",&lambda,&value)!=EOF && k!=50000)
   {
   x[k]=lambda;
   yref[k]=y[k]=value;
   wt[k]=1.0;
   k++;
   }
fclose(hand_spectre);

// Ellimination de certaines zones (elles correspondes aux grosses raies dans une étoile de type B, A)
double pos1,pos2,p1,p2,p3,p4;
int n,nn;
int n2;
double a0,a1,rms;

// --------------------------------
// Exemple de la zone Halpha ...
// --------------------------------
pos1=6501.0;
pos2=6620.0;

p1=pos1-10.0;
p2=pos1;
p3=pos2;
p4=pos2+10.0;

// Traitement de la partie gauche de la zone
n=0;
nn=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p2))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne sélectionne que la moitié supérieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++) // on en profite pour elliminer les points le plus déviants
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// Traitement de la partie droite de la zone
n=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p3 && x[i]<p4))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne sélectionne que la moitié supérieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// fit linéaire de la zone marquée
crvLinearLeastSqr(nn,xxx,yyy,wwt,&a0,&a1,&rms);
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p4))
      {
      y[i]=a1*x[i]+a0;
      }
   } 

// --------------------------------
// Exemple de la zone Hbeta ...
// --------------------------------
pos1=4785.0;
pos2=4940.0;

p1=pos1-10.0;
p2=pos1;
p3=pos2;
p4=pos2+10.0;

// Traitement de la partie gauche de la zone
n=0;
nn=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p2))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne sélectionne que la moitié supérieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++) // on en profite pour elliminer les points le plus déviants
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// Traitement de la partie droite de la zone
n=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p3 && x[i]<p4))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne sélectionne que la moitié supérieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// fit linéaire de la zone marquée
crvLinearLeastSqr(nn,xxx,yyy,wwt,&a0,&a1,&rms);
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p4))
      {
      y[i]=a1*x[i]+a0;
      }
   } 

// --------------------------------
// Exemple de la zone H2O ...
// --------------------------------
pos1=5860.0;
pos2=6000.0;

p1=pos1-10.0;
p2=pos1;
p3=pos2;
p4=pos2+10.0;

// Traitement de la partie gauche de la zone
n=0;
nn=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p2))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne sélectionne que la moitié supérieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++) // on en profite pour elliminer les points le plus déviants
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// Traitement de la partie droite de la zone
n=0;
for (i=0;i<k;i++)
   {
   if ((x[i]>p3 && x[i]<p4))
      {
      xx[n]=x[i];
      yy[n]=y[i];
      n++; 
      }
   }
hmedian2(yy,xx,n);
n2=n/2;
// on ne sélectionne que la moitié supérieure
if (n2>5)
   {
   for (i=n2;i<n-3;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }
else
   {
   for (i=n2;i<n;i++)
      {
      xxx[nn]=xx[i];
      yyy[nn]=yy[i];
      wwt[nn]=1.0;
      nn++; 
      }
   }

// fit linéaire de la zone marquée
crvLinearLeastSqr(nn,xxx,yyy,wwt,&a0,&a1,&rms);
for (i=0;i<k;i++)
   {
   if ((x[i]>p1 && x[i]<p4))
      {
      y[i]=a1*x[i]+a0;
      }
   } 

// --------------------------------------------------
// Ajustement principal
// --------------------------------------------------
// int w=191; // paramètres d'ajustement polynomial
int w=231; // paramètres d'ajustement polynomial
int degre=2;

double start=x[0];
for (i=0;i<k;i++)
   {
   x[i]=x[i]-start;
   }

// Ajustement par polynome glissant...
if (smthPolyAverage(k,w,degre,x,y,a,wt))
   {
   printf("\nErreur d'ajutement\n");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   free(yyy);
   return 1;
   }

// itérations...
for (it=0;it<29;it++)
   {
   for (i=0;i<k;i++)
      {
      if (y[i]<a[i]) y[i]=a[i];
      }

   // Ajustement par polynome (ou moyenne...) glissant...
   for (i=0;i<=k;++i) a[i]=y[i];

   if (smthMovingAverage(k,w,a))
   // if (smthPolyAverage(k,w,degre,x,y,a,wt))
      {
      printf("\nErreur d'ajutement\n");
      free(x);
      free(y);
      free(yref);
      free(wt);
      free(a); 
      free(xx); 
      free(yy);
      free(wwt); 
      free(xxx);
      free(yyy);
      return 1;
      }
   }

// Sauvegarde du continuum
sprintf(nom_spectre,"%s.dat",n_continuum);

if ((hand_out=fopen(nom_spectre,"wt"))==NULL)
   {
   printf("Sauvegarde du fichier impossible.");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   free(yyy);
   return 1;
   }

for (i=0;i<k;i++)
   {
   sprintf(ligne,"%lf\t%lf\n",x[i]+start,a[i]);
   fwrite(ligne,strlen(ligne),1,hand_out);
   }
fclose(hand_out);

// Sauvegarde du profil / continuum (provisoire - pour vérif
if ((hand_out=fopen("div.dat","wt"))==NULL)
   {
   printf("Sauvegarde du fichier impossible.");
   free(x);
   free(y);
   free(yref);
   free(wt);
   free(a); 
   free(xx); 
   free(yy);
   free(wwt); 
   free(xxx);
   free(yyy);
   return 1;
   }

for (i=0;i<k;i++)
   {
   sprintf(ligne,"%lf\t%lf\n",x[i]+start,yref[i]/a[i]);
   fwrite(ligne,strlen(ligne),1,hand_out);
   }
fclose(hand_out);

free(x);
free(y);
free(yref);
free(wt);
free(a); 
free(xx); 
free(yy);
free(wwt); 
free(xxx);
free(yyy);

return 0;
}

///////////////////////////////////////////////////////////////
//  Traitement des cosmiques 
///////////////////////////////////////////////////////////////



/************************* MEDIAN_LIBRE *****************************/
/* Calcul de la médiane dans une matrice de dimension quelconque    */
/* (la dimension de la matrice est tout au plus la moitié de la     */
/* plus petite dimension de l'image - la largeur de la matrice est  */
/* impaire - sont format est carré)                                 */
/********************************************************************/
int median_libre(PIC_TYPE *image, int imax, int jmax, int dimension, double parametre)
{
PIC_TYPE i,j,k,v_median;
PIC_TYPE *p0,*p1,*ptr0,*ptr1,*ptr;
PIC_TYPE *d,*ker,*buf;
PIC_TYPE l_kernel,dim_kernel,largeur2;
int longueur,adr;

/* la dimension du kernel doit être impaire */
if (dimension%2==0)
   {
   printf("\nFiltre median : la dimension de la matrice doit être impaire\n");
   return 1;
   }

l_kernel=dimension;
dim_kernel=l_kernel*l_kernel;

longueur=sizeof(PIC_TYPE)*imax*jmax;

if (imax<2*l_kernel || jmax<2*l_kernel)
   {
   printf("\nFiltre median : kernel trop grand\n");
   return 1;
   }

if ((buf=(PIC_TYPE *)malloc(longueur))==NULL)
   {
   printf("\nFiltre median : pas assez de memoire\n");
   return 1;
   }

if ((d=(PIC_TYPE *)malloc(dim_kernel*sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nFiltre median : pas assez de memoire\n");
   free(buf);
   return 1;
   }

if ((ker=(PIC_TYPE *)malloc(dim_kernel*sizeof(PIC_TYPE)))==NULL)
   {
   printf("\nFiltre median : pas assez de memoire\n");
   free(buf);
   free(d);
   return 1;
   }

largeur2=l_kernel/2;
for (i=0;i<l_kernel;i++)
  {
  for (k=0;k<l_kernel;k++)
     {
     d[i+k*l_kernel]=(largeur2-k)*imax+i-largeur2;
     }
  }

p0=image;
p1=buf;
memset(buf,0,longueur);

for (j=largeur2;j<(jmax-largeur2);j++)
   {
   adr=j*imax;
   ptr0=p0+adr;
   ptr1=p1+adr;
   ptr=ptr0+largeur2;
   for (i=largeur2;i<(imax-largeur2);i++,ptr++)
      {
      for (k=0;k<dim_kernel;k++) ker[k]=*(ptr+d[k]);
      v_median=hmedian(ker,dim_kernel);
      if (parametre>0)
	     {
	     if (abs(*ptr-v_median) > (PIC_TYPE)(parametre*(double)(ker[dim_kernel-2]-ker[1])))
	        *(ptr1+i)=v_median;
	     else
	        *(ptr1+i)=*ptr;
	     }
      else
	     {
	     *(ptr1+i)=v_median;
	     }
      }
   }
memmove(p0,buf,longueur);

free(buf);
free(d);
free(ker);

return 0;
}

/************************ COSMIC_MED ************************/
/* Détection des rayons cosmiques.                          */
/* La carte des rayons (map) est un buffer                  */
/* qui a la taille de l'image traitée.                      */
/* La position des cosmiques est marquée par la valeur      */
/* 32767 dans cette carte (c'est un wildcard)               */
/* Algorithme :                                             */
/* (1) on charge l'image à traiter                          */
/* (2) on réalise un filtre médian 5x5 pondéré              */
/* (3) on soutrait à l'image traitée l'image filtrée        */
/* (4) dans l'image différence, les cosmiques sont          */
/*     les points au dessus d'un seuil (passé en paramètre) */
/* La fonction retourne le nombre de cosmique trouvé        */
/************************************************************/
int cosmic_med(INFOIMAGE *buffer, PIC_TYPE *map, double coef, PIC_TYPE seuil, int *nb)
{
int i,j,adr;
int imax=buffer->imax;
int jmax=buffer->jmax;
PIC_TYPE *p=buffer->pic;

PIC_TYPE *tampon = new PIC_TYPE[imax * jmax];
memmove(tampon, p, imax * jmax * sizeof(PIC_TYPE));

if (median_libre(tampon, imax, jmax, 5, coef) == 1) return 1;

int k=0;
for (j=0;j<jmax;j++)
   {
   for (i=0;i<imax;i++,k++)
      {
      tampon[k]=p[k]-tampon[k];
      }
   }

int nbb=0;

for (j=3; j<jmax-3; j++)
   {
   for (i=3; i<imax-3; i++)
      {
      adr=i+j*imax;
      if (p[adr]>seuil)
         {
         map[adr]=32767;
         nbb++; 
         }
      else
         map[adr]=0;
      }
   }

*nb=nbb;

delete [] tampon;
return 0; 
}

/********************** COSMIC_REPAIR ********************/
/* Réparation des rayons cosmiques                       */
/* Un cosmique dans l'image map est flaggé par           */
/* la valeur 32767                                       */
/* Le cosmique est bouché par la valeur médiane          */
/* des 8 plus proches voisins (sauf si c'est un cosmiqe) */
/*********************************************************/
int cosmic_repair(INFOIMAGE *buffer, PIC_TYPE *map)
{
int i,j,adr;
PIC_TYPE table[8];

int imax=buffer->imax;
int jmax=buffer->jmax;
PIC_TYPE *p=buffer->pic;

for (j=3; j<jmax-3; j++)
   {
   for (i=3; i<imax-3; i++)
      {
      adr=i+j*imax;
      if (map[adr]==32767)
         {         
         int n=0;
         if (map[adr-imax-1]!=32767)
            {
            table[n]=p[adr-imax-1];
            n++;
            }
         if (map[adr     -1]!=32767)
            {
            table[n]=p[adr     -1];
            n++;
            }
         if (map[adr+imax-1]!=32767)
            {   
            table[n]=p[adr+imax-1];
            n++;
            }
         if (map[adr-imax  ]!=32767)
            { 
            table[n]=p[adr-imax  ];
            n++;
            }
         if (map[adr+imax  ]!=32767)
            {
            table[n]=p[adr+imax  ];
            n++;
            }
         if (map[adr-imax+1]!=32767)
            {
            table[n]=p[adr-imax+1];
            n++;
            }
         if (map[adr     +1]!=32767)
            {  
            table[n]=p[adr     +1];
            n++;
            }
         if (map[adr+imax+1]!=32767)
            { 
            table[n]=p[adr+imax+1];
            n++;
            } 
         p[adr]=hmedian(table,n);    
         }
      }
   }
return 0;
}

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
// Détection automatique et retrait des rayons cosmiques dans l'image 'buffer'
// cosmic2_med -> détection des cosmiques             
// cosmic2_repair -> réparation des cosmiques         
// On passe le seuil de détection des cosmiques (valeur typiquement entre 100 et 500)                     
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
void Eshel_cosmic_removal(char *name_in, char *name_out, int seuil)
{
   PIC_TYPE *map;           // carte des cosmiques (à l'itération courante)
   PIC_TYPE *map_total;     // carte cumulée
   int adr;
   int nb=0;
   int nb_total=0;
   int i,j,k;
   int nb_iter=5;   // nombre d'itérations (fixée par l'expérience)

   CCfits::PFitsFile pInFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;
   CCfits::PFitsFile pMapFits = NULL;
   INFOIMAGE *buffer = NULL;
   INFOIMAGE *bufTotal = NULL;

   try {
      // Lecture de l'image
      pOutFits = Fits_openFits(name_in, false); 
      Fits_getImage(pOutFits, &buffer); 

      int imax=buffer->imax;
      int jmax=buffer->jmax;
      PIC_TYPE *p=buffer->pic;

      map = new PIC_TYPE[imax*jmax];
      map_total = new PIC_TYPE[imax*jmax];

      // Boucle de calcul...
      for (k=0;k<nb_iter;k++)
      {
         if (cosmic_med(buffer,map,0.6,seuil,&nb)!=0) {
            throw std::exception("Eshel_cosmic_removal : erreur dans cosmic_med");
         }
         if (cosmic_repair(buffer,map)!=0) {
            throw std::exception("Eshel_cosmic_removal : erreur dans cosmic_repair");
         }
         for (j=3; j<jmax-3; j++)
         {
            for (i=3; i<imax-3; i++)
            {
               adr=i+j*imax;
               if (map_total[adr]==0 && map[adr]==32767) // si un point n'est pas déjà flaggé, il est ajouté dans la carte de cumul 
               {
                  map_total[adr]=32767;
                  nb_total++;
               }
            } 
         }
      }

      // Sauvegarde de l'image filtrée (buffer) ??
      pOutFits = Fits_createFits(name_out, buffer ); 
      Fits_closeFits( pOutFits);


      // .......
      // .......
      // sauvegarde de la carte des cosmiques (map_total)      
      // A ce stade il faudrait sauvegarder la table map_total comme une
      // image de vérification (fichier FITS 2D comme check). Je lui donne dans Iris le nom @map
      // sur le disque, mais on peut choisir ce qu'on veut...
      bufTotal = createImage(map_total, imax, jmax);
      pMapFits = Fits_createFits("@map.fit", bufTotal ); 
      Fits_closeFits( pMapFits);
      freeImage(bufTotal);

      printf("\nNombre de cosmiques trouvé : %d\n",nb_total);

      freeImage(buffer);
      delete [] map;
      delete [] map_total;
   } catch (std::exception &e) {
      // je desalloue tout ce qui a pu etre alloue dynamiquement
      Fits_closeFits(pInFits);
      Fits_closeFits(pOutFits);
      Fits_closeFits(pMapFits);
      freeImage(bufTotal);
      freeImage(buffer);
      delete [] map;
      delete [] map_total;
      // je transmets l'exception a la fonction appelante
      throw e;
   }
}

void correctDistorsion( ) {

   int nbElement = 10;
   int polynomOrder = 3;
   double positionIn[] = {
      324.39,
      537.16 ,
      596.94 ,
      632.75 ,
      789.57 ,
      963.5 ,
      1109.3 ,
      1254.66 ,
      1418.21 ,
      1431.64 
   } ;
   double positionOut[] = {
      337.96 ,
      546.89 ,
      603.96 ,
      639.04 ,
      793 ,
      964.99  ,
      1109.21 ,
      1252.72 ,
      1413.17 ,
      1426.42
   };
   double *w; 
   double *a; 
   double rms = 0;
   
   w = new double[nbElement];
   a = new double[polynomOrder+1];
   
   for (int i=0 ; i< nbElement; i++) {
     w[i] = 1.0;
   }
 
   fitPoly(nbElement,polynomOrder,positionIn,positionOut,w,a,&rms);

   delete [] w;
   delete [] a;

}