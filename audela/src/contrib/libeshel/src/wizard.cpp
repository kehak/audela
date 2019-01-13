// wizard.cpp : fonctions du wizard

#include <string>
#include <sstream>

#include <gsl/gsl_poly.h>

#include "infoimage.h"
#include "order.h"
#include "linegap.h"
#include "fitsfile.h"

#include "processing.h"

// indluce libtt definitions
//#ifdef __cplusplus
//extern "C" {            /// Assume C declarations for C++ 
//#endif                  // __cplusplus 
//
//#define TINT         31
//#define TT_SCRIPT_2                     102
//#define TT_PTR_STATIMA                  204
//int __stdcall _libtt_main(int,...);
//
//#ifdef __cplusplus
//}                       // End of extern "C"
//#endif                  // __cplusplus 


void findMargin(INFOIMAGE *buffer,int imax, int jmax, int wide_y, 
                ORDRE *ordre,int n, double snNoise, ::std::list<REFERENCE_LINE> &tangenteList);
int calcPosY(PIC_TYPE *p,int imax,int jmax,int x,int y1,int y2,double &pos_y);
int verifyQuality(PIC_TYPE *imgPix,int imax,int jmax,int x,int y1,int y2);
int verifyQuality(PIC_TYPE *imgPix, int imax,int jmax, ORDRE *ordre,
                int orderNo, int x, int y, int wide_y, double snNoise);
void fitgauss1d(INFOIMAGE *buffer, int x1,int y1, int x2, int y2,double &fwhm);
void findHorizontalTangente(ORDRE *ordre, int orderNo, ::std::list<REFERENCE_LINE> &tangenteList) ;

int createImageFile (PIC_TYPE fwhm, int radius, PIC_TYPE threshin,
						   PIC_TYPE threshold, char *filename,
						   std::valarray<PIC_TYPE> &picture,
                     int x1, int y1, int width,int height, unsigned int maxLineNb,
                     ::std::list<REFERENCE_LINE> &imageLineList );
int createCatalogFile ( char * catalogLinefilename, int orderNo, INFOSPECTRO &spectro, 
                       double dx, ::std::list<double> &lineList, 
                       int cropHeight, 
                       ::std::list<REFERENCE_LINE> &catalogLineList);
int  createMatchFile ( char * outputFileName, double referenceLamba, double &refPosX, ::std::list<REFERENCE_LINE> &matchLineList,double &refDx);
void splitFilename(char *fileName, ::std::string &dir, ::std::string &root, ::std::string &ext);

////////////////////////////////////////
////////////////////////////////////////
// Traitement de l'image "flat-field" //
////////////////////////////////////////
////////////////////////////////////////

void Eshel_findMargin(
   char *ledfileName,      // nom du fichier led (image pretraitee pour la calibration geometrique)
   char *outputFileName,   // nom du fichier flat traitee  en sortie
   int seuil_ordre,        // seuil de détection des ordres
   double snNoise,
   INFOSPECTRO &spectro,   // parametres du specto et de la caméra
   char *returnMesssage)   // nom de l'image de controle
{

   INFOIMAGE *buffer = NULL;
   CCfits::PFitsFile pLedFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;
   PROCESS_INFO processInfo;
   ORDRE ordre[MAX_ORDRE];
   memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
     
   try {
      double dx_ref = 0;

      processInfo.bordure = 0;
      processInfo.calibrationIteration = 0;
      processInfo.referenceOrderNum = 0;
      processInfo.referenceOrderX =0;
      processInfo.referenceOrderY = 0;
      processInfo.referenceOrderLambda = 0;
      processInfo.referenceOrderNum = 1;
      processInfo.referenceOrderY = spectro.jmax -3;
      processInfo.detectionThreshold = seuil_ordre;
      processInfo.version = LIBESHEL_VERSION; 

      // -------------------------------------
      // Lecture de l'image LED 2D pretraitee
      // -------------------------------------  
      pOutFits = Fits_createFits(ledfileName, outputFileName); 
      // j'ajoute le mot cle contenant la version de la librairie
      setSoftwareVersionKeyword(pOutFits);
      // je change le type d'image
      Fits_setKeyword(pOutFits,"PRIMARY","IMAGETYP","FLAT","");
      // je lis l'image 2D
      Fits_getImage(pOutFits, &buffer); 

      // je contrôle l'intégrité de la taille de l'image
      if (buffer->imax!=spectro.imax || buffer->jmax!=spectro.jmax) {
         char message[1024];
         sprintf(message, "La taille (%d,%d) de l'image %s est différente de (%d,%d) des parametres du spectrographe.",
            buffer->imax,buffer->jmax, ledfileName, spectro.imax, spectro.jmax);
         throw std::exception(message);
      }
      // ---------------------------------------------------------------------------------------------------
      // Recherche de la position Y des ordres suivant l'axe vertical central de l'image (imax/2)
      // ---------------------------------------------------------------------------------------------------
      int nb_ordre;
      find_y_pos(*buffer,processInfo,ordre, nb_ordre, spectro.min_order,spectro.max_order);
      
      // ---------------------------------------------------------------------------------------
      // Détection de la ligne de crête des ordres dans l'image flat
      // et modélisation (polynômes de degré 4)
      // ---------------------------------------------------------------------------------------
      ::std::list<REFERENCE_LINE> tangenteList;
      int nbOrdreOk = 0;
      for (int n=spectro.min_order;n<=spectro.max_order;n++)
      //for (int n=5;n<=6;n++)
      {
         if (ordre[n].flag==1)
         {
            // j'elemine les ordres pour lesquels yc=0
            if ( ordre[n].yc != 0 ) {
               //track_order(buffer,spectro.imax,spectro.jmax,wide_y,ordre,n);
               findMargin(buffer,spectro.imax,spectro.jmax, 8, ordre, n, snNoise, tangenteList);
               if ( ordre[n].rms_order > 100.0 ) {
                  ordre[n].flag = -2;
               }
               if (ordre[n].flag==1) {
                  // je calcule la FWHM verticale
                  fitgauss1d(buffer, spectro.imax/2 - 8, ordre[n].yc - 8, spectro.imax/2 + 8, ordre[n].yc + 8, ordre[n].fwhm );
                  nbOrdreOk++;
               }
            } else {
               ordre[n].flag = -4;
            }                        
         }
      }
       

      // j'ajoute les infos du spectro, les parametres de traitement et la table des ordres dans le fichier de sortie
      Fits_setOrders(pOutFits, &spectro, &processInfo, ordre, dx_ref);

      // je ferme le fichier de sortie
      Fits_closeFits(pOutFits);
      pOutFits = NULL;
      if ( buffer!= NULL) freeImage(buffer);

      double *tangentePosx = new double[tangenteList.size()];
      int tangentePosxCounter = 0;
      ::std::ostringstream tangenteString;
      tangenteString << nbOrdreOk ;
      tangenteString << " { ";
      for (::std::list<REFERENCE_LINE>::iterator iter=tangenteList.begin(); iter != tangenteList.end(); ++iter) {
         REFERENCE_LINE tangentePoint = *iter;
         // j'ajoute les ccordonnees dans la chaine de sortie
         //char coord[1024];
         //sprintf(coord,"{%lf %lf } ", tangentePoint.posx, tangentePoint.posy);
         //tangenteString.append(coord);
         tangenteString << "{ " << tangentePoint.posx << " " << tangentePoint.posy << "} ";
         tangentePosx[tangentePosxCounter++] = tangentePoint.posx;
      }
      tangenteString << "} ";

      double x1, y1, x2, y2; 
      if ( tangenteList.size() > 2 ) {
         // je calcule la mediane des abcisses des tangentes
         double medianPosx = hmedian(tangentePosx, tangenteList.size()); 
         delete []tangentePosx;
         //tangenteString << medianPosx;

         // je calcule l'abcisse de la droite miroir par rapport au milieu de l'image
         double cameraPosx = spectro.imax/2  - ( medianPosx - spectro.imax/2 );

         /*
         // je recherche une ligne au milieu
         //double hmedian2(double *ra,double *t2,int n)

         // je calcule la pente d'une ligne au milieu de l'image
         double xpos = spectro.imax/2;
         int lineNo = 13;
         double pente = ordre[lineNo].poly_order[1] 
            + ordre[lineNo].poly_order[2]*2 * xpos
            + ordre[lineNo].poly_order[3]*3 * xpos * xpos
            + ordre[lineNo].poly_order[4]*4 * xpos * xpos * xpos 
            + ordre[lineNo].poly_order[5]*5 * xpos * xpos * xpos * xpos ;

         // pente de la droite perpendiculaire 
         pente = -1/pente;
         // origine de la droite perpendiculaire y = ax+b  => b = y -ax;
         double origine = ordre[lineNo].yc - pente * cameraPosx;
         // droite y= ax+b    xmin = (ymin -b )/a      xmax = (ymax -b )/a

         // je calcule les extremités de la droite representant la rotation de la camera
         double x1, y1, x2, y2; 
         if ( pente != 0 ) {
            x1 = (1.0 - origine) / pente;
            y1 =  1.0;
            x2 = (spectro.jmax - origine) / pente;
            y2 = spectro.jmax;
         } else {
            x1 = cameraPosx;
            y1 = 1.0;
            x2 = cameraPosx;
            y2 = spectro.jmax;
         }
         */
         x1 = cameraPosx;
         y1 = 1.0;
         x2 = cameraPosx;
         y2 = spectro.jmax;
      } else {
         x1 = spectro.imax/2;
         y1 = 1.0;
         x2 = spectro.imax/2;
         y2 = spectro.jmax;
      }
      // coordonnes de l'axe de la camera
      tangenteString << "{ " << x1 << " " << y1 << " " << x2 << " " << y2 << " } ";
      // coordonnes de reference au centre de l'image
      tangenteString << "{ " << spectro.imax/2 << " " << y1 << " " << spectro.imax/2  << " " << y2 << " } ";
      strcpy ( returnMesssage, tangenteString.str().c_str());
   } catch( std::exception e ) {
      if ( buffer!= NULL) freeImage(buffer);
      if ( pLedFits != NULL) Fits_closeFits(pLedFits);
      if ( pOutFits != NULL) Fits_closeFits( pOutFits);
      throw e;
   } 

}


// ---------------------------------------------------------------------------
// findYOrder
//   traite un flat
//   double sigma=sqrt(py[2]/2.0);
//   fwhm = 2.354 * sigma
// @param 
// @return void
// ---------------------------------------------------------------------------
void findMargin(INFOIMAGE *buffer,int imax, int jmax, int wide_y, ORDRE *ordre,
                int n, double snNoise, ::std::list<REFERENCE_LINE> &tangenteList )
{
   int i,k,py,size;
   double *x = NULL;
   double *y = NULL;
   double *w = NULL;
   double *a = NULL;
   int ic=imax/2;

   try {
      size=imax;
      // marge par defaut a 5 pixels des bords gauche et droite
      ordre[n].min_x = 5 ;
      ordre[n].max_x = imax-5 ;

      x = new double[size];
      y = new double[size];
      w = new double[size];

      // -------------------------------------------
      // Détection de la trace de l'ordre n
      // -------------------------------------------
      k=0;
      py=int(ordre[n].yc+.5);
      int quality = 1;
      for (i=ic;i<imax-wide_y && quality == 1;i++) {
         //quality = verifyQuality(buffer->pic,imax,jmax,i,py-wide_y,py+wide_y);
         quality = verifyQuality(buffer->pic,imax,jmax, ordre, n, i, py, wide_y, snNoise);         
         if (quality == 0 ) {
               ordre[n].max_x = i-1;
               break;
         }
         double pos_y;  
         int cgdResult = calcPosY(buffer->pic,imax,jmax,i,py-wide_y/2,py+wide_y/2,pos_y);  // centre de gravité suivant Y
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
      quality = 1;
      for (i=ic-1;i>=5 && quality == 1 ;i--) {
         //quality = verifyQuality(buffer->pic,imax,jmax,i,py-wide_y,py+wide_y); 
         quality = verifyQuality(buffer->pic,imax,jmax, ordre, n, i, py, wide_y, snNoise);
         if (quality == 0 ) {
               ordre[n].min_x = i+1;
               break;
         }
         double pos_y;
         int cgdResult = calcPosY(buffer->pic,imax,jmax,i,py-wide_y/2,py+wide_y/2,pos_y); // centre de gravité suivant Y
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

      // ---------------------------------------
      // Ajustement du polynôme
      // ---------------------------------------
      try {
         double rms = 0.0;
         a = new double[POLY_ORDER_DEGREE + 1];         
         if ( k > 10 ) {
            for (i=0; i<=POLY_ORDER_DEGREE; i++) a[i]=0.0;

            fitPoly(k,POLY_ORDER_DEGREE,x,y,w,a,&rms);
            for (i=0;i<=POLY_ORDER_DEGREE;i++) {
               ordre[n].poly_order[i]=a[i];
            }
            ordre[n].rms_order=rms;
         } else {
            ordre[n].flag = -3 ;
         }
      } catch (std::exception e) {
         ordre[n].flag = -4; 
         for (i=0;i<=POLY_ORDER_DEGREE;i++) {
               ordre[n].poly_order[i]=0;
         }
         ordre[n].rms_order=0;
      }

      // ---------------------------------------
      // tangente horizontale
      // ---------------------------------------
      findHorizontalTangente ( ordre, n, tangenteList );
      

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

void findHorizontalTangente(ORDRE *order, int orderNo, ::std::list<REFERENCE_LINE> &tangenteList ) {

   double a[5] ;  
   double z[8];

   a[0] = order[orderNo].poly_order[1];
   a[1] = order[orderNo].poly_order[2]*2;
   a[2] = order[orderNo].poly_order[3]*3;
   a[3] = order[orderNo].poly_order[4]*4;
   a[4] = order[orderNo].poly_order[5]*5;

   if ( a[0]==0 && a[1]==0 && a[2]==0 && a[3]==0 && a[4]==0 ) {
      // libgsl ne supporte pas tous les coefficients nuls
      return;
   }

   // GSL
   //gsl_poly_complex_workspace * w = gsl_poly_complex_workspace_alloc (5);
   //gsl_poly_complex_solve (a, 5, w, z);
   //gsl_poly_complex_workspace_free (w);

   //&& z[2*i+1] >= order[orderNo].yc - 60 && z[2*i+1] <= order[orderNo].yc + 60
   // je recupere la position du point tangent de l'ordre precedent
   double prevPosx ;
   if ( tangenteList.empty() == FALSE ) {
      prevPosx = (tangenteList.back()).posx;
   } else {
      // je choisi milieu de l'image s'il n'y a pas d'odre précédent
      prevPosx = (order[orderNo].min_x + order[orderNo].max_x) /2;
   }
   REFERENCE_LINE tangentePoint ;
   tangentePoint.posx = 0;
   tangentePoint.posy = 0;
   tangentePoint.lambda = -1;
   for (int i = 0; i < 5; i++) {
      if ( z[2*i] >= order[orderNo].min_x && z[2*i] <= order[orderNo].max_x ) {
         if ( fabs( z[2*i] - prevPosx) < fabs( tangentePoint.posx  - prevPosx) ) {
            tangentePoint.posx  = z[2*i];
            //tangentePoint.posy = z[2*i+1];
            double posy = 0; 
            for (int k=0;k<=POLY_ORDER_DEGREE;k++){
               posy=posy+order[orderNo].poly_order[k]*pow(tangentePoint.posx,(double)k);
            }
            tangentePoint.posy = posy;
            tangentePoint.order = orderNo;
            tangentePoint.lambda = 0;
         }
      } 
   }
   if ( tangentePoint.lambda == 0) {
      tangenteList.push_back(tangentePoint);
   }
}



// ---------------------------------------------------------------------------
// calcPosY
//  calcule le centre de gravité suivant l'axe colonne entre les bornes y1 et y2 
// dans l'image pointée par p (coordonnées mémoire - origine (0,0)).             
// La colonne analysée est de rang x.                                           
// La coordonnées y est retournée dans pos_y
// @param 
// @return void
// ---------------------------------------------------------------------------
int calcPosY(PIC_TYPE *p,int imax,int jmax, int x,int y1,int y2,double &pos_y)
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
   if (s2==0) {
      pos_y=0;
   } else {
      pos_y=s1/s2;
   }
   return 0;
}

// ---------------------------------------------------------------------------
// fitgauss1d
// calcule la FWHM verticale 
// dans l'image pointée par p (coordonnées mémoire - origine (0,0)).             
// La colonne analysée est de rang x.                                           
// La coordonnées y est retournée dans pos_y
// @param 
// @return void
// ---------------------------------------------------------------------------

void fitgauss1d(INFOIMAGE *buffer, int x1,int y1, int x2, int y2,double &fwhm)
{
   int l,nbmax,m;
   double l1,l2=0.,a0;
   double e,er1,x,y0;
   double m0,m1;
   double e1[4];
   
   int height = y2-y1+1;

   // je cree les variables de travail pour l'ajustement de la gaussienne
   PIC_TYPE * iY = new PIC_TYPE[height];
   PIC_TYPE * y = new PIC_TYPE[height];
   memset(iY,0,sizeof(PIC_TYPE)*height);
   memset(y,0,sizeof(PIC_TYPE)*height);

   // je calcule iY[]
   for(int j=y1;j<=y2;j++) {
      PIC_TYPE *imgOffset  = buffer->pic  + j * buffer->imax;
      for(int i=x1;i<=x2;i++) {
         PIC_TYPE *imgPtr  = imgOffset+i;
         // je calcule les histogrammes pour la Fwhm
         *(iY+j-y1) += *imgPtr;
      }
   }
   // je calcule y[]
   for(int j=0;j<height;j++) *(y+j) = *(iY+j);

   // Ajuste une gaussienne :                         
   // ENTREES :                                       
   //  y()=tableau des points                         
   //  n=nombre de points dans le tableau y           
   // SORTIES                                         
   //  p()=tableau des variables:                     
   //     p[0]=intensite maximum de la gaussienne     
   //     p[1]=indice du maximum de la gaussienne     
   //     p[2]=fwhm                                   
   //     p[3]=fond                                   
   //  ecart=ecart-type                               

   int n = height;
   double p[4];
   p[0]=y[0];
   p[1]=0.;
   p[3]=1e9;
   for (int i=1;i<n;i++) {
      if (y[i]>p[0]) {p[0]=y[i]; p[1]=1.*i; }
      if (y[i]<p[3]) {p[3]=y[i]; }
   }
   p[0]-=p[3];
   if (p[0]<=0.) {p[0]=10.;}
   p[2]=2.;
   double ecart=1.0;
   l=4;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=250;         /* nombre maximum d'iterations */
   for (int i=0;i<l;i++) {
      e1[i]=er1;
   }
   m=0;
   l1=(double)1e10;
fitgauss1d_b1:
   for (int i=0;i<l;i++) {
      a0=p[i];
fitgauss1d_b2:
      l2=0;
      for (int j=0;j<n;j++) {
         x=(double)j;
         if(fabs(p[2])>1e-3) {
            y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
         } else {
            y0=1e10;
         }
         l2=l2+(y[j]-y0)*(y[j]-y0);
      }
      m0=l2;
      p[i]=a0*(1-e1[i]);
      l2=0;
      for (int j=0;j<n;j++) {
         x=(float)j;
         if(fabs(p[2])>1e-3) {
            y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
         } else {
            y0=1e10;
         }
         l2=l2+(y[j]-y0)*(y[j]-y0);
      }
      ecart=sqrt((double)l2/(n-l));
      m1=l2;
      if (m1>m0) e1[i]=-e1[i]/2;
      if (m1<m0) e1[i]=(float)1.2*e1[i];
      if (m1>m0) p[i]=a0;
      if (m1>(m0*(1.+1e-15)) ) goto fitgauss1d_b2;
   }
   m++;
   if (m==nbmax) {p[2]=sqrt(p[2])/.601; goto fitgauss1d_return ; }
   if (l2==0) {p[2]=sqrt(p[2])/.601; goto fitgauss1d_return ; }
   if (fabs((l1-l2)/l2)<e) {p[2]=sqrt(p[2])/.601; goto fitgauss1d_return ; }
   l1=l2;
   goto fitgauss1d_b1;

fitgauss1d_return:
   fwhm = p[2];

   delete [] iY;
   delete [] y;

}


// ---------------------------------------------------------------------------
// verifyQuality
//   veirie le qualite du signal dans la fentre 
//   algo de la valeur moy et ecart type de Miller;
//   
// @param 
// @return 1=OK  0=bad quality
// ---------------------------------------------------------------------------
int verifyQuality(PIC_TYPE *imgPix, int imax,int jmax, ORDRE *ordre,
                int orderNo, int posx, int posy, int wide_y, double snNoise)
{
   int naxis1 = imax;
   int x1 = posx-5;
   int x2 = posx+5;
   int width =  x2-x1+1;
   int height = wide_y/2;
   
   int prevBgY;
   int nextBgY;
   int bgMargin = int(1.5*wide_y + 0.5);

   if ( posy <= height ) {
      return 0;
   }
   if ( posy >= jmax - height ) {
      return 0;
   }

   // je calcule les coordonnée des 2 zones de background
   if ( orderNo > 0 && orderNo < MAX_ORDRE -1 ) {
      if ( ordre[orderNo - 1].yc != 0 ) {
         // le  centre de la fentre de fond du ciel est placé au milieu de l'espace avec l'ordre précédent
         if ( (ordre[orderNo -1].yc - ordre[orderNo].yc) / 2 >  bgMargin ) {
            prevBgY = posy + (ordre[orderNo -1].yc - ordre[orderNo].yc) / 2;
         } else {
            prevBgY = posy + bgMargin;
         }         
      } else {
         prevBgY = posy + bgMargin;
      }

      if ( ordre[orderNo + 1].yc != 0 ) {
         // le centre de la fentre de fond du ciel est placé au milieu de l'espace avec l'ordre suivant                
         if ( (ordre[orderNo].yc - ordre[orderNo+1].yc ) / 2 > bgMargin ) {
            nextBgY = posy - (ordre[orderNo].yc - ordre[orderNo+1].yc ) / 2;
         } else {
            nextBgY = posy - bgMargin;
         }
      } else {
         nextBgY = posy - bgMargin;
      }
   } 

   if ( prevBgY < bgMargin) {
      prevBgY = bgMargin;
   }
   if ( prevBgY >= jmax - bgMargin) {
      prevBgY = jmax - bgMargin -1;
   }

   if ( nextBgY < wide_y) {
      nextBgY = 2*wide_y;
   }
   if ( nextBgY >= jmax - bgMargin) {
      nextBgY = jmax - bgMargin -1;
   }         

   // je calcule le fond du ciel entre 
   double mean = 0;


   /*
   double prevBg = 0;
   double nextBg = 0;

   for(x=x1;x<=x2;x++) {
      for(int y=prevBgY - height; y<=prevBgY + height; y++) {
         prevBg += (PIC_TYPE) *(imgPix+naxis1*y+x);
      }
      for(int y=nextBgY - height; y<=nextBgY + height; y++) {
         nextBg += (PIC_TYPE) *(imgPix+naxis1*y+x);
      }
      for(int y=ordre[orderNo].yc - height; y<=ordre[orderNo].yc + height; y++) {
         mean += (PIC_TYPE) *(imgPix+naxis1*y+x);
      }
   }
   //prevBg = prevBg / (width * wide_y * 2);
   //nextBg = nextBg / (width * wide_y * 2);
   //double  background = (prevBg + nextBg) / 2;
   
   */

   double prev_i=0;
   double prev_mu_i = *(imgPix+naxis1*(prevBgY - height)+x1);
   double prev_mu_ii=0;
   double prev_sx_i = 0;
   double prev_sx_ii=0;
   int prev_k = 1;

   double next_i=0;
   double next_mu_i = *(imgPix+naxis1*(nextBgY - height)+x1);
   double next_mu_ii=0;
   double next_sx_i = 0;
   double next_sx_ii=0;
   int next_k = 1;

   double epsdouble=1.0e-300;
   
   
   for(int x=x1;x<=x2;x++) {
      for(int y=prevBgY - height; y<=prevBgY + height; y++) {
         double valeur = *(imgPix+naxis1*y+x);
         // j'exclue les valeurs qui sont à plus de 1000 
         if ( fabs (valeur - prev_mu_i) > 1000 ) {
            valeur = prev_mu_i;
         }

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
      for(int y=nextBgY - height; y<=nextBgY + height; y++) {
         double valeur = *(imgPix+naxis1*y+x);
         if ( fabs (valeur - next_mu_i) > 1000 ) {
            valeur = next_mu_i;
         }
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
      for(int y=posy - height; y<=posy + height; y++) {
         mean += (PIC_TYPE) *(imgPix+naxis1*y+x);
      }
   }

   
   double prev_sigma=((prev_sx_ii>=0)&&(prev_i>0.))?sqrt(prev_sx_ii/prev_i):0.0;
   double next_sigma=((next_sx_ii>=0)&&(next_i>0.))?sqrt(next_sx_ii/next_i):0.0;
   mean = mean / (width * height * 2);

   if ( (mean > ( prev_mu_ii + snNoise * prev_sigma)) && (mean > ( next_mu_ii + snNoise * next_sigma)) ) {
      return 1; 
   } else {
      return 0; 
   }
}


// ---------------------------------------------------------------------------
// verifyQuality
//   veirie le qualite du signal dans la fentre 
//   double sigma=sqrt(1/n * sum(xi^2) - xmoy^2) ;
//   fwhm = 2.354 * sigma
// @param 
// @return void
// ---------------------------------------------------------------------------
int verifyQuality(PIC_TYPE *imgPix,int imax,int jmax,int x,int y1,int y2)
{

#ifdef USE_LIBTT 
   double dlocut, dhicut, dmaxi, dmini, dmean, dsigma, dbgmean,dbgsigma,dcontrast;
   int naxis1 = imax;

   int x1 = x-2;
   int x2 = x+2;
   int width =  x2-x1+1;
   int height = y2-y1+1;

   PIC_TYPE *imgTemp = new PIC_TYPE[width*height];

   for(int y=y1;y<=y2;y++) {
      for(x=x1;x<=x2;x++) {
         *(imgTemp+width*(y-y1)+(x-x1)) = (PIC_TYPE) *(imgPix+naxis1*y+x);
      }
   }

   int datatype = TINT;
   int ttResult = 1;
   //int ttResult = _libtt_main(TT_PTR_STATIMA,13,imgTemp,&datatype,&width,&height,
   //   &dlocut,&dhicut,&dmaxi,&dmini,&dmean,&dsigma,&dbgmean,&dbgsigma,&dcontrast);
   if(ttResult) {
      delete []imgTemp;
      char message[1024];
      sprintf(message, "TT_PTR_STATIMA error %d",ttResult);
      throw std::exception(message);
   }
   delete []imgTemp;
   if ( dmean > ( dbgsigma * 1.0 + dbgmean) ) {
      return 1; 
   } else {
      return 0; 
   }
#else 
   return 0;
#endif
}



