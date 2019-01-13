// wizard.cpp : fonctions du wizard

#include <string>
#include <sstream>

#include <gsl/gsl_poly.h>

#include "infoimage.h"
#include "order.h"
#include "linegap.h"
#include "fitsfile.h"

#include "processing.h"
#include "wizardthar.h"
#include "focas.h"

//#define USE_LIBTT 0
//
//#ifdef USE_LIBTT
//// include libtt definitions
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
//#endif


bool compareLineGapByLambda(LINE_GAP &first, LINE_GAP &second);
bool compareLineGapByPosx(LINE_GAP &first, LINE_GAP &second);
bool uniqueLineGap (LINE_GAP &first, LINE_GAP &second);

int translate_col_1(INFOIMAGE *buffer, int colonne, double delta_y, 
                    ORDRE *ordre, int n, int jmax_result, 
                    std::valarray<PIC_TYPE> &buf_result);

void computeBackground(std::valarray<PIC_TYPE> &p2, int imax2, int jmax2, ORDRE *ordre, int n);

int createImageFile (PIC_TYPE fwhm, int radius, PIC_TYPE threshin,
						   PIC_TYPE threshold, char *filename,
						   std::valarray<PIC_TYPE> &picture,
                     int minx, int maxx, int width, int height, unsigned int maxLineNb,
                     ::std::list<REFERENCE_LINE> &imageLineList );

int createCatalogFile ( char * cDummyfilename, int orderNo, INFOSPECTRO &spectro, 
                       double dx, ::std::list<double> &lineList, 
                       int cropHeight, int minx , int maxx,
                       ::std::list<REFERENCE_LINE> &catalogLineList);
#ifdef USE_LIBTT
int  createMatchFile ( char * outputFileName, double referenceLamba, double &refPosX, 
                      ::std::list<REFERENCE_LINE> &matchLineList,double &d0, double &d1);
#else
int matchLine ( ::std::list<REFERENCE_LINE> &imageLineList,  
                ::std::list<REFERENCE_LINE> &catalogLineList,
                double referenceLamba, double &refPosX, 
                ::std::list<REFERENCE_LINE> &matchLineList, 
                double &d0, double &d1);
#endif
void splitFilename(char *fileName, ::std::string &dir, ::std::string &root, ::std::string &ext);


// ---------------------------------------------------------------------------
// Eshel_findReferenceLine
//   recherche l'ordre correspondant 
//   double sigma=sqrt(1/n * sum(xi^2) - xmoy^2) ;
//   fwhm = 2.354 * sigma
// @param 
// @return void
// ---------------------------------------------------------------------------

void Eshel_findReferenceLine(
   char *ledfileName, 
   char *tharfileName,
   char *outputFileName,
   int ordre_ref_num, 
   double ordre_ref_lambda, 
   INFOSPECTRO &spectro,
   ::std::list<double> &lineList,
   int threshin,
   int fwhm,
   std::string &returnMessage)
{
   CCfits::PFitsFile pLedFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;
   ::std::list<REFERENCE_LINE> bestImageLineList;
   ::std::list<REFERENCE_LINE> bestMatchLineList;

   try {
      ORDRE ordre[MAX_ORDRE];
           
      PROCESS_INFO processInfo;
      INFOIMAGE *lampBuffer = NULL;
      double dx_ref = 0;

      memset(&processInfo,0,sizeof(PROCESS_INFO));

      pLedFits = Fits_openFits(ledfileName, false); 
      Fits_getOrders(pLedFits, ordre, &dx_ref);
      Fits_closeFits(pLedFits);
      pLedFits = NULL;

      {
         ORDRE newOrder[MAX_ORDRE]; 
         memset(newOrder,0,MAX_ORDRE*sizeof(ORDRE));
         int newOrderindex =0;
         for (int orderNo=0; orderNo< MAX_ORDRE ;orderNo++) {
            if (ordre[orderNo].flag==1) {
               memcpy(&newOrder[newOrderindex++],&ordre[orderNo],sizeof(ORDRE));        
            }
         }
         memcpy(ordre,newOrder,MAX_ORDRE*sizeof(ORDRE));    
      }

      
       
      pOutFits = Fits_openFits(tharfileName,false);
      // je lis l'image 2D
      Fits_getImage(pOutFits, &lampBuffer);
      Fits_closeFits(pOutFits);
      pOutFits = NULL;

      char *dummyfilename   = "./dummy.fit";
      char *iDummyfilename  = "./idummy.fit";
      char *cDummyfilename  = "./cdummy.fit";

      int cropHeight = 60;
      startTimer();
      std::valarray<std::valarray<PIC_TYPE>> straightLineImage(MAX_ORDRE);
      for (int orderNo=0; orderNo< MAX_ORDRE ;orderNo++) {
         if (ordre[orderNo].flag==1) {
            // -----------------------------------------------------------
            // Extraction des ordres de l'image de la lampe spectrale
            // -----------------------------------------------------------  
            //extract_order(lampBuffer, processInfo, orderNo, ordre, spectro.imax, cropHeight, (std::valarray<double>) NULL, straightLineImage, -1 ); 
            straightLineImage[orderNo].resize(spectro.imax * cropHeight);
            for (int i=ordre[orderNo].min_x-1;i<ordre[orderNo].max_x -1;i++) {
               double v=0.0;
               for (int k=0;k<=POLY_ORDER_DEGREE;k++){
                  v=v+ordre[orderNo].poly_order[k]*pow((double)i,(double)k);
               }
               double delta_y=v-ordre[orderNo].yc;
               // rectification géométrique colonne par colonne
               int splineDegre = 2; // choix entre 2 et 9 -> 9 meilleure qualité lors des corrections géométriques
               //translate_col(lampBuffer,i,-delta_y,ordre,orderNo, straightLineImage[orderNo], spectro.imax, cropHeight, splineDegre);
               translate_col_1(lampBuffer,i,-delta_y, ordre, orderNo, cropHeight, straightLineImage[orderNo]);
            }

            //calcul du fond du ciel entre chaque ordre
            computeBackground(straightLineImage[orderNo], spectro.imax, cropHeight, ordre, orderNo);
         }
      }
      stopTimer("wizard extract_order");

      // je recherche le meilleur ajustement des raies du catalogue sur l'ordre
      startTimer();
      int    approxMatchedLineNb = 0;
      double approxAlpha = 0;
      double approxD1 = 0;
      double approxRefPosX = 0;
 
      for ( double alpha = 62; alpha <= 65 ; alpha +=0.4) {
         spectro.alpha = alpha;

         // je cherche l'ordre 34
         for (int orderNo=0; orderNo< MAX_ORDRE ;orderNo++) {
            //for (int orderNo=4; orderNo< 6 ;orderNo++) {
            if (ordre[orderNo].flag==1) {
               // je cree le catalogue des raies des calibration pour l'ordre catalogOrderNum
               ::std::list<REFERENCE_LINE> catalogLineList;
               int nbCatalogLine = createCatalogFile ( cDummyfilename, ordre_ref_num, spectro, 0, lineList, cropHeight, ordre[orderNo].min_x, ordre[orderNo].max_x, catalogLineList);
               if ( nbCatalogLine > 5 ) {
#ifdef USE_LIBTT                  
                  // je cree le fichier de sortie
                  
                  CCfits::PFitsFile pDummyFits = Fits_createFits(dummyfilename, straightLineImage[orderNo], spectro.imax, cropHeight);
                  Fits_setKeyword(pDummyFits, "PRIMARY", "OBJEFILE",iDummyfilename,"");
                  Fits_setKeyword(pDummyFits, "PRIMARY", "CATAFILE",cDummyfilename,"");
                  Fits_setKeyword(pDummyFits, "PRIMARY", "OBJEKEY","test","");  
                  // je ferme le fichier de sortie
                  Fits_closeFits( pDummyFits);
                  pDummyFits = NULL;
#endif

                  // je cree le fichier avec le points detectes dans l'image
                  int radius = 5;
                  PIC_TYPE threshold =(int) ( ordre[orderNo].backgroundLevel+ ordre[orderNo].backgroundSigma * threshin);;
                  ::std::list<REFERENCE_LINE> imageLineList;
                  int nbImageLine = createImageFile (fwhm, radius, threshold,
                     threshold, iDummyfilename,
                     straightLineImage[orderNo],
                     ordre[orderNo].min_x, ordre[orderNo].max_x, 
                     spectro.imax, cropHeight,
                     int(catalogLineList.size() *1.5), 
                     imageLineList);

                  int nbMatchedLine = 0;
                  ::std::list<REFERENCE_LINE> matchLineList;
                  double refPosX = 0;                     
                  double d0, d1;                     
                  if ( nbImageLine > 5 ) {
                     // j'apparie les deux fichiers
#ifdef USE_LIBTT 
                     nbMatchedLine = createMatchFile(dummyfilename, ordre_ref_lambda, refPosX, matchLineList, d0, d1);
#else
                     nbMatchedLine = matchLine(imageLineList, catalogLineList, ordre_ref_lambda, refPosX, matchLineList, d0, d1); 
#endif
                  }

                  // je verifie si c'est le meilleur ajustement
                  if ( nbMatchedLine > 3  && nbMatchedLine >= approxMatchedLineNb -2 ) {
                     if ( d1 != 1 && fabs(d1 -1) < fabs(approxD1 -1) ) {
                        approxMatchedLineNb = nbMatchedLine;
                        approxAlpha = alpha;
                        approxD1 = d1;
                        approxRefPosX = refPosX;
                     }
                  }
               }
            }
         }        
      }

      int bestImageOrderNum = 0; 
      int bestImageLineNb = 0;
      int bestMatchedLineNb = 0;
      double bestRefPosX = approxRefPosX;
      int minOrder= MAX_ORDRE; 
      int maxOrder= -1;
      double bestAlpha = 0;
      double bestD1 = 0;
      for ( double alpha = approxAlpha -0.2; alpha <= approxAlpha +0.2 ; alpha +=0.1 ) {
         spectro.alpha = alpha;

         // je cherche l'ordre 34
         for (int orderNo=0; orderNo< MAX_ORDRE ;orderNo++) {
            //for (int orderNo=4; orderNo< 6 ;orderNo++) {
            if (ordre[orderNo].flag==1) {
               // j'identifie l'ordre min
               if ( orderNo < minOrder ) {
                  minOrder = orderNo;
               }
               // j'identifie l'ordre max
               if ( orderNo > maxOrder) {
                  maxOrder = orderNo;
               }

               // je cree le catalogue des raies des calibration pour l'ordre catalogOrderNum
               ::std::list<REFERENCE_LINE> catalogLineList;
               int nbCatalogLine = createCatalogFile ( cDummyfilename, ordre_ref_num, spectro, 0, lineList, cropHeight, ordre[orderNo].min_x, ordre[orderNo].max_x, catalogLineList);
               if ( nbCatalogLine > 5 ) {
#ifdef USE_LIBTT 
                  // je cree le fichier de sortie
                  CCfits::PFitsFile pDummyFits = Fits_createFits(dummyfilename, straightLineImage[orderNo], spectro.imax, cropHeight);
                  Fits_setKeyword(pDummyFits, "PRIMARY", "OBJEFILE",iDummyfilename,"");
                  Fits_setKeyword(pDummyFits, "PRIMARY", "CATAFILE",cDummyfilename,"");
                  Fits_setKeyword(pDummyFits, "PRIMARY", "OBJEKEY","test","");  
                  // je ferme le fichier de sortie
                  Fits_closeFits( pDummyFits);
                  pDummyFits = NULL;
#endif
                  // je cree le fichier avec le points detectes dans l'image
                  int radius = 5;
                  PIC_TYPE threshold =(int) ( ordre[orderNo].backgroundLevel+ ordre[orderNo].backgroundSigma * threshin);;
                  ::std::list<REFERENCE_LINE> imageLineList;
                  int nbImageLine = createImageFile (fwhm, radius, threshold,
                     threshold, iDummyfilename,
                     straightLineImage[orderNo],
                     ordre[orderNo].min_x, ordre[orderNo].max_x, 
                     spectro.imax, cropHeight,
                     int(catalogLineList.size() *1.5), 
                     imageLineList);

                  int nbMatchedLine = 0;
                  ::std::list<REFERENCE_LINE> matchLineList;
                  double refPosX = 0;                     
                  double d0, d1;                     
                  if ( nbImageLine > 5 ) {
                     // j'apparie les deux fichiers
#ifdef USE_LIBTT 
                     nbMatchedLine = createMatchFile(dummyfilename, ordre_ref_lambda, refPosX, matchLineList, d0, d1); 
#else
                     nbMatchedLine = matchLine(catalogLineList, imageLineList, ordre_ref_lambda, refPosX, matchLineList, d0, d1); 
#endif
                  }

                  // je verifie si c'est le meilleur ajustement
                  if ( nbMatchedLine >= bestMatchedLineNb -2 ) {
                     if ( d1 != 1 && fabs(d1 -1) < fabs(bestD1 -1) ) {
                        bestMatchedLineNb = nbMatchedLine;
                        bestImageLineNb = nbImageLine;
                        bestImageOrderNum = orderNo;
                        bestImageLineList = imageLineList;
                        bestMatchLineList = matchLineList;
                        bestRefPosX = refPosX;
                        bestAlpha = alpha;
                        bestD1 = d1;
                     }
                  }
               }
            }
         }        
      }

      //
      stopTimer("find best order");
      spectro.alpha = bestAlpha;
      
      startTimer();
      // je calcule le decalage horizontal de la raie de réference
      if (calib_prediction(ordre_ref_lambda,ordre_ref_num,spectro.imax,spectro.jmax,bestRefPosX,&dx_ref,spectro,lineList)) {
         throw std::exception("calib_prediction error");
      }       

      ::std::list<REFERENCE_LINE> catalogLineList;
      int nbCatalogLine = createCatalogFile ( cDummyfilename, ordre_ref_num, spectro, dx_ref, lineList, 
         cropHeight, 5, spectro.imax -5, catalogLineList);

      // je copie les ordres valides dans la nouvelle table des ordres
      ORDRE newOrder[MAX_ORDRE]; 
      memset(newOrder,0,MAX_ORDRE*sizeof(ORDRE));
      memcpy(&newOrder[minOrder + (ordre_ref_num - bestImageOrderNum)], 
         &ordre[minOrder],
         sizeof(ORDRE)*(maxOrder-minOrder+1));

      // je met à jour les infos du spectro
      spectro.min_order = minOrder + (ordre_ref_num - bestImageOrderNum);
      spectro.max_order = maxOrder + (ordre_ref_num - bestImageOrderNum);
      stopTimer("createCatlogFile");

      // je verifie les autres ordres
      startTimer();
      std::ostringstream orderMatchString;
      ::std::list<LINE_GAP> lineGapList;

      orderMatchString <<"{ ";
      
      for (int orderNo=spectro.min_order; orderNo< spectro.max_order ;orderNo++) {
         if (newOrder[orderNo].flag==1) {
             // je cree le fichier de sortie
            CCfits::PFitsFile pDummyFits = Fits_createFits(dummyfilename, straightLineImage[orderNo -(ordre_ref_num - bestImageOrderNum)], spectro.imax, cropHeight);
            Fits_setKeyword(pDummyFits, "PRIMARY", "OBJEFILE",iDummyfilename,"");
            Fits_setKeyword(pDummyFits, "PRIMARY", "CATAFILE",cDummyfilename,"");
            Fits_setKeyword(pDummyFits, "PRIMARY", "OBJEKEY","test","");  
            Fits_closeFits( pDummyFits);
            pDummyFits = NULL;
            
            // je cree le fichier catalogue
            ::std::list<REFERENCE_LINE> catalogLineList;
            nbCatalogLine = createCatalogFile ( cDummyfilename, orderNo, spectro, dx_ref, lineList, 
               cropHeight, newOrder[orderNo].min_x, newOrder[orderNo].max_x, catalogLineList);
            // je copie les lignes dans la liste de sortie
            for (::std::list<REFERENCE_LINE>::iterator iter=catalogLineList.begin(); iter != catalogLineList.end(); ++iter) {
               REFERENCE_LINE catalogLine = *iter;
               LINE_GAP lineGap;
               lineGap.order  = orderNo;
               lineGap.l_obs  = catalogLine.lambda; 
               lineGap.l_calc = catalogLine.posx;  // posx calcule a partir du catalogue
               lineGap.l_diff = 0;
               lineGap.valid  = 2;
               lineGap.l_posx = 0;                // posx mesure dans l'image 
               lineGap.l_posy = 0;
               for (int k=0;k<=POLY_ORDER_DEGREE;k++){
                  lineGap.l_posy=lineGap.l_posy+newOrder[orderNo].poly_order[k]*pow(catalogLine.posx,(double)k);
               }
               lineGapList.push_back(lineGap);
            }
            
            int nbImageLine   = 0;
            int nbMatchedLine = 0; 
            double d0 = 0;
            double d1 = 0;
            if ( nbCatalogLine > 5 ) {
               // je cree le fichier avec le points detectes dans l'image
               int radius = 6;
               PIC_TYPE threshold =(int) ( newOrder[orderNo].backgroundLevel+ newOrder[orderNo].backgroundSigma * threshin);;
               ::std::list<REFERENCE_LINE> imageLineList;
               nbImageLine = createImageFile (fwhm, radius, threshold,
				         threshold, iDummyfilename,
				         straightLineImage[orderNo -(ordre_ref_num - bestImageOrderNum)],
                     newOrder[orderNo].min_x, newOrder[orderNo].max_x, 
                     spectro.imax,cropHeight,
                     int(catalogLineList.size() *1.0), 
                     imageLineList);
               // je copie les lignes dans la liste de sortie
               for (::std::list<REFERENCE_LINE>::iterator iter=imageLineList.begin(); iter != imageLineList.end(); ++iter) {
                  REFERENCE_LINE imageLine = *iter;
                  LINE_GAP lineGap;
                  lineGap.order  = orderNo;
                  lineGap.l_obs  = 0; 
                  lineGap.l_calc = 0;                           // posx calcule a partir du catalogue
                  lineGap.l_diff = 0;
                  lineGap.valid  = 3;
                  lineGap.l_posx = imageLine.posx;                // posx mesure dans l'image 
                  lineGap.l_posy = 0;
                  for (int k=0;k<=POLY_ORDER_DEGREE;k++){
                     lineGap.l_posy=lineGap.l_posy+newOrder[orderNo].poly_order[k]*pow(imageLine.posx,(double)k);
                  }
                  lineGapList.push_back(lineGap);
               }
               

               if ( nbImageLine > 5 ) {
                  // j'apparie les deux fichiers
                  ::std::list<REFERENCE_LINE> matchLineList;
                  double refPosX = 0;
#ifdef USE_LIBTT 
                     nbMatchedLine = createMatchFile(dummyfilename, ordre_ref_lambda, refPosX, matchLineList, d0, d1); 
#else
                     nbMatchedLine = matchLine(imageLineList, catalogLineList, ordre_ref_lambda, refPosX, matchLineList, d0, d1); 
#endif

                  // je memorise la liste des raies de  l'ordre de reference
                  if (orderNo == ordre_ref_num) {
                     bestImageLineList = imageLineList;
                     bestMatchLineList = matchLineList;
                  }

                  // je copie les lignes dans la liste de sortie
                  for (::std::list<REFERENCE_LINE>::iterator iter=matchLineList.begin(); iter != matchLineList.end(); ++iter) {
                     REFERENCE_LINE matchLine = *iter;
     
                     LINE_GAP lineGap;
                     lineGap.order  = orderNo;
                     lineGap.l_obs  = matchLine.lambda;
                     lineGap.l_calc = matchLine.posy;  // valeur de x calcule a partir du catalogue
                     lineGap.l_diff = 0;
                     lineGap.valid  = 1;
                     lineGap.l_posx = matchLine.posx;
                     lineGap.l_posy = 0;
                     for (int k=0;k<=POLY_ORDER_DEGREE;k++){
                        lineGap.l_posy=lineGap.l_posy+newOrder[orderNo].poly_order[k]*pow(matchLine.posx,(double)k);
                     }
                     lineGapList.push_back(lineGap);
                  }
               }
            }

            orderMatchString << "{ " << orderNo << " " << nbImageLine << " " << nbCatalogLine<< " " << nbMatchedLine << " " << d0 << " " << d1 << "} " ;
         }
      }
      
      orderMatchString << "} ";
      stopTimer("Find other order");
      
      //je tri la liste finale 
      lineGapList.sort( compareLineGapByLambda );
      lineGapList.unique( uniqueLineGap);  
      lineGapList.sort( compareLineGapByPosx );
      lineGapList.unique( uniqueLineGap);  
      

      // je calcule la longueur d'onde du centre de chaque ordre (à imax/2)
      for (int orderNo=0;orderNo<MAX_ORDRE;orderNo++) {
         if (newOrder[orderNo].flag==1) { 
            newOrder[orderNo].central_lambda=get_central_wave(spectro.imax,(double)spectro.imax/2.0,dx_ref,orderNo,spectro);
         }
      }      
            
      pOutFits = Fits_createFits(tharfileName, outputFileName);
      // j'ajoute les infos du spectro, les parametres de traitement et la table des ordres dans le fichier de sortie
      Fits_setOrders(pOutFits, &spectro, &processInfo, newOrder, dx_ref);
      Fits_setLineGap(pOutFits,lineGapList);
      Fits_closeFits(pOutFits);
      pOutFits = NULL;

      // je retourne le nombre de raies trouvée
      std::ostringstream stringOrderNum;
      stringOrderNum << bestAlpha << " " <<  bestImageOrderNum << " " ;

      std::ostringstream bestRefCoord;
      if ( bestRefPosX != 0 ) {
         double posy = 0;
         for (int k=0;k<=POLY_ORDER_DEGREE;k++){
            posy=posy+ordre[bestImageOrderNum].poly_order[k]*pow(bestRefPosX,(double)k);
         }
         bestRefCoord << "{ " << bestRefPosX << " " << posy << "} ";         
      } else {
         bestRefCoord << "{ } ";
      }
      bestRefCoord << " " << dx_ref << " " ;
      
      std::ostringstream bestImageLineString;
      bestImageLineString << "{ ";
      for (::std::list<REFERENCE_LINE>::iterator iter=bestImageLineList.begin(); iter != bestImageLineList.end(); ++iter) {
         REFERENCE_LINE imageLine = *iter;
         // je calcule l'ordonnee dans l'image 2D originale
         double posy = 0; 
         for (int k=0;k<=POLY_ORDER_DEGREE;k++){
            posy=posy+ordre[bestImageOrderNum].poly_order[k]*pow(imageLine.posx,(double)k);
         }
         bestImageLineString << "{" << imageLine.posx << " " << posy << "} ";
      }
      bestImageLineString <<"} ";

      std::ostringstream catalogLineString;
      catalogLineString << "{";
      for (::std::list<REFERENCE_LINE>::iterator iter=catalogLineList.begin(); iter != catalogLineList.end(); ++iter) {
         REFERENCE_LINE catalogLine = *iter;
         // je calcule l'ordonnee dans l'image 2D originale
         double posy = 0; 
         for (int k=0;k<=POLY_ORDER_DEGREE;k++){
            posy=posy+ordre[bestImageOrderNum].poly_order[k]*pow(catalogLine.posx,(double)k);
         }
         // j'ajoute les ccordonnees dans la chaine de sortie
         catalogLineString << "{" << catalogLine.posx << " " << posy << " " << catalogLine.lambda << "} " ;
      }
      catalogLineString << "} ";

      std::ostringstream bestMatchLineString;
      bestMatchLineString << "{";
      for (::std::list<REFERENCE_LINE>::iterator iter=bestMatchLineList.begin(); iter != bestMatchLineList.end(); ++iter) {
         REFERENCE_LINE matchLine = *iter;
         // je calcule l'ordonnee dans l'image 2D originale
         double posy1 = 0; 
         for (int k=0;k<=POLY_ORDER_DEGREE;k++){
            posy1=posy1+ordre[bestImageOrderNum].poly_order[k]*pow(matchLine.posx,(double)k);
         }
         double posy2 = 0; 
         for (int k=0;k<=POLY_ORDER_DEGREE;k++){
            posy2=posy2+ordre[bestImageOrderNum].poly_order[k]*pow(matchLine.posy,(double)k);
         }
         bestMatchLineString << "{" << matchLine.posx << " " << posy1 << " " << matchLine.posy << " " << posy2 << "} "  ;
      }
      bestMatchLineString << "} ";
      remove(dummyfilename);
      remove(iDummyfilename);
      remove(cDummyfilename);


      returnMessage = stringOrderNum.str() + bestRefCoord.str() + bestImageLineString.str() + catalogLineString.str() + bestMatchLineString.str() + orderMatchString.str();
   } catch( std::exception e ) {
      if ( pLedFits != NULL) Fits_closeFits(pLedFits);
      if ( pOutFits != NULL) Fits_closeFits(pOutFits);
      throw e;
   } 
}

bool compareLineGapByLambda(LINE_GAP &first, LINE_GAP &second) {
   // lmabda contient l'intensité du point
   if (first.order < second.order) {
      return true;
   } else if (first.order > second.order) {
      return false;
   } else {
      if (fabs( first.l_obs - second.l_obs) < 0.01 ) {
         if (  first.l_obs != 0 ) {
            if ( first.valid < second.valid) {
               return true;
            } else {
               return false;
            }
         } else {
            if ( first.l_posx == second.l_posx ) {
               if ( first.valid < second.valid) {
                  return true;
               } else {
                  return false;
               }
            } else {
               if ( first.l_posx < second.l_posx ) {
                  return true;
               } else {
                  return false;
               }
            }
         }
      } else if (first.l_obs < second.l_obs ) {
         return true; 
      } else {
         return false; 
      } 
   } 
}

bool compareLineGapByPosx(LINE_GAP &first, LINE_GAP &second) {
   if (first.order < second.order) {
      return true;
   } else if (first.order > second.order) {
      return false;
   } else {
      if ( first.l_posx == second.l_posx ) {
         if (  first.l_posx != 0 ) {
            if ( first.valid < second.valid) {
               return true;
            } else {
               return false;
            }
         } else {
            if (fabs( first.l_obs - second.l_obs) < 0.01 ) {
               if ( first.valid < second.valid) {
                  return true;
               } else {
                  return false;
               }
            } else {
               if ( first.l_obs < second.l_obs ) {
                  return true;
               } else {
                  return false;
               }
            }
         }
      } else if (first.l_posx < second.l_posx ) {
         return true; 
      } else {
         return false; 
      } 
   } 
}

/*
bool compareLineGapByLambda(LINE_GAP &first, LINE_GAP &second) {
   // lmabda contient l'intensité du point
   if (first.order < second.order) {
      return true;
   } else if (first.order > second.order) {
      return false;
   } else if (first.l_obs != 0.0 && second.l_obs != 0.0) {
      if (first.l_obs == second.l_obs ) {
         if ( first.valid < second.valid) {
            return true;
         } else {
            return false;
         }
      } else {
         if ( first.l_obs < second.l_obs ) {
            return true;
         } else {
            return false;
         }
      }
   } else {
      if ( first.l_posx == second.l_posx ) {
         if ( first.valid < second.valid) {
            return true;
         } else {
            return false;
         }
      } else {
         if ( first.l_posx < second.l_posx ) {
            return true;
         } else {
            return false;
         }
      }
   }
}
*/
bool uniqueLineGap (LINE_GAP &first, LINE_GAP &second) { 
   if ( first.order == second.order ) {
      if ( first.l_obs == 0 || second.l_obs == 0 ) {
         return ( first.l_posx == second.l_posx ); 
      } else {
        return ( fabs( first.l_obs - second.l_obs) < 0.01 );
      }
   } else {
      return false;
   }
}



void computeBackground(std::valarray<PIC_TYPE> &p2, int imax2, int jmax2, ORDRE *ordre, int n) {
   int k;


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
}

bool compareReferenceLineByLambda(REFERENCE_LINE &first, REFERENCE_LINE &second) {
   // lambda contient l'intensité du point
   if (first.lambda > second.lambda) {
      return true;
   } else {
      return false;
   }
}

bool compareReferenceLineByLambdaDescending(REFERENCE_LINE &first, REFERENCE_LINE &second) {
   // lambda contient l'intensité du point
   if (first.lambda < second.lambda) {
      return true;
   } else {
      return false;
   }
}


bool compareReferenceLineByPosx (REFERENCE_LINE &first, REFERENCE_LINE &second) {
   // lambda contient l'intensité du point
   if (first.posx > second.posx) {
      return true;
   } else {
      return false;
   }
}


bool uniqueReferenceLine (REFERENCE_LINE &first, REFERENCE_LINE &second) {
   if (int(first.posx) == int(second.posx)) {
      return true;
   } else {
      return false;
   }
}

int createImageFile (PIC_TYPE fwhm, int radius, PIC_TYPE threshin,
						   PIC_TYPE threshold, char *filename,
						   std::valarray<PIC_TYPE> &picture,
                     int minx, int maxx, 
                     int width, int height, 
                     unsigned int maxLineNb,
                     ::std::list<REFERENCE_LINE> &imageLineList )
{
   double sig = 0.4246*fwhm;
   double dsig2 = 2*sig*sig;
   double dpisig2 = 3.14159265358979*dsig2; //=2*pi*sig^2
   double summ = 0.0;
   int nbStar = 0; 
   int center = radius;
   int gmsize = 2*radius + 1;
   int border = radius + 2;

   double *temp_pic; 
   double *gauss_matrix;

   imageLineList.clear();
   
   if ( maxx - minx < 2 * border ) {
      //char line[1024]; 
      //sprintf( line, "createImageFile width %d < 2 * border %d", width, border);
      //throw std::exception(line);
      return imageLineList.size();
   }
   if ( height < 2 * border ) {
      //char line[1024]; 
      //sprintf( line, "createImageFile height %d < 2 * radius %d", height, border);
      //throw std::exception(line);
      return imageLineList.size();
   }

   if((temp_pic = (double *)calloc(width*height,sizeof(double)))==NULL) {
      throw ::std::exception("malloc temp_pic");
   }

   if((gauss_matrix = (double *)malloc(sizeof(double)*gmsize*gmsize))==NULL) {
      free(temp_pic);
      throw ::std::exception("malloc gauss_matrix");
   }

   // Creation of matrix with Gauss/normal distribution values 
   for (int y=0; y<gmsize; y++)
   {
      for (int x=0; x<gmsize; x++)
      {
         gauss_matrix[x+y*gmsize] = (double)(
            exp( -((x-center)*(x-center) + (y-center)*(y-center)) / dsig2)
            /dpisig2);
         summ += gauss_matrix[x+y*gmsize];
      }
   }

   double summa = 0.0;

   for (int y=0; y<gmsize; y++)
   {
      for (int x=0; x<gmsize; x++)
      {
         gauss_matrix[x+y*gmsize] = (double)(gauss_matrix[x+y*gmsize]/summ
            - (1.0 / (gmsize*gmsize)));
         summa += gauss_matrix[x+y*gmsize];
      }
   }

   for (int y=border; y < (height-border) ; y++) {
   //for (int y=height/2 -2; y < height/2 +2; y++) {
      for (int x=minx+border; x < maxx-border ; x++)
      {
         if ( picture[x+y*width] > threshin)
         {
            for (int j=0; j<gmsize; j++)
               for (int i=0; i<gmsize; i++)
               {
                  temp_pic[x+y*width] +=
                     picture[x-center+i+(y-center+j)*width]*gauss_matrix[i+j*gmsize];
               }
         }
         else temp_pic[x+y*width] = (PIC_TYPE)0.0;
      }
   }
   int border1 = border + 2;    // +1 because when searching for maksimum,

   //looking for stars (max. values), now is not very precise
   for (int y=border1; y < height-border1; y++) {
   //for (int y=height/2 -6; y < height/2 +6; y++) {
      for (int x=minx+border1; x < maxx-border1; x++)
      {
         double temp_p=temp_pic[x+y*width];
         if(
            (threshold < temp_p)
            && (temp_pic[x-1+y*width] < temp_p)
            && (temp_pic[x+1+y*width] < temp_p)
            && (temp_pic[x+(y-1)*width] < temp_p)
            && (temp_pic[x+(y+1)*width] < temp_p)
            && (temp_pic[x+1+(y+1)*width] < temp_p)
            && (temp_pic[x-1+(y+1)*width] < temp_p)
            && (temp_pic[x-1+(y-1)*width] < temp_p)
            && (temp_pic[x+1+(y-1)*width] < temp_p)
            )
         {
            REFERENCE_LINE imageLine;
            //imageLine.lambda = temp_p;
            imageLine.lambda = ( picture[x+y*width] 
               + picture[x-1+y*width] + picture[x+1+y*width] + picture[x+(y-1)*width] +picture[x+(y+1)*width]
               + picture[x+1+(y+1)*width] + picture[x-1+(y+1)*width] + picture[x-1+(y-1)*width] + picture[x+1+(y-1)*width]
               ) /9.0;
            //imageLine.posx = (double)x+x1 + 1;
            imageLine.posx = (double)x + 1;
            //imageLine.posy = (double)y+y1 + 1;
            imageLine.posy = height/2;
            imageLine.order = 0;
            imageLineList.push_back(imageLine);
         }
      }
   }

   if ( imageLineList.size() > 0 ) {
      imageLineList.sort(compareReferenceLineByLambdaDescending);
      if ( imageLineList.size() > maxLineNb) {
         imageLineList.resize(maxLineNb);
      }
      imageLineList.sort(compareReferenceLineByPosx);
      imageLineList.unique(uniqueReferenceLine);
      imageLineList.sort(compareReferenceLineByLambda);

#ifdef USE_LIBTT 
      INFOIMAGE * pinfoImage = createImage(1,1);
      CCfits::PFitsFile pImageLineFits = Fits_createFits(filename,pinfoImage);
      freeImage(pinfoImage);
      Fits_setImageLine(pImageLineFits, imageLineList );
      Fits_setKeyword(pImageLineFits, "PRIMARY", "OBJEKEY","test","");
      Fits_setKeyword(pImageLineFits, "PRIMARY", "TTNAME","OBJELIST","");
      Fits_closeFits( pImageLineFits);
      pImageLineFits = NULL;
#endif
   }  

   free(temp_pic);
   free(gauss_matrix);
   return imageLineList.size();  //number of stars
}

int  createCatalogFile ( char * cDummyfilename, int orderNo, INFOSPECTRO &spectro, 
                        double dx, ::std::list<double> &lineList, int cropHeight,
                        int minx , int maxx,
                        ::std::list<REFERENCE_LINE> &catalogLineList) {
   ::std::list<double>::iterator iter;
   catalogLineList.clear();
   for (iter=lineList.begin(); iter != lineList.end(); ++iter) 
   {            
      double lambda = *iter;

      double m=spectro.m;
      double focale=spectro.focale;
      double pixel=spectro.pixel;
      double alpha=spectro.alpha*PI/180.0;
      double gamma=spectro.gamma*PI/180.0;
      double imax = spectro.imax;
      double jmax = spectro.jmax;
      double beta,beta2;

      // prediction posx
      beta=asin((orderNo*m*lambda/1.0e7-cos(gamma)*sin(alpha))/cos(gamma));
      beta2=beta-alpha;
      double posx=focale*beta2/pixel+imax/2.0+ dx;

      if ( posx < minx || posx > ( maxx -5) || _isnan(posx) ) {
         continue;
      }

      REFERENCE_LINE catalogLine;
      catalogLine.lambda = lambda;
      catalogLine.posx = posx;
      catalogLine.posy = cropHeight/2;
      catalogLine.order = orderNo;
      catalogLineList.push_back(catalogLine);
   } // for lambdaIter
   catalogLineList.sort(compareReferenceLineByLambda);

#ifdef USE_LIBTT 
   if ( catalogLineList.size() > 0 ) {
      INFOIMAGE * pinfoImage = createImage(1,1);
      CCfits::PFitsFile pCatalogLineFits = Fits_createFits(cDummyfilename,pinfoImage);
      freeImage(pinfoImage);
      Fits_setCatalogLine (pCatalogLineFits, catalogLineList );
      Fits_setKeyword(pCatalogLineFits, "PRIMARY", "TTNAME","CATALIST","");
      Fits_setKeyword(pCatalogLineFits, "PRIMARY", "OBJEKEY","test","");
      Fits_closeFits( pCatalogLineFits);
      pCatalogLineFits = NULL;
   }
#endif
   return catalogLineList.size();
}

#ifdef USE_LIBTT 
int  createMatchFile ( char * outputFileName, double referenceLamba, double &refPosX, ::std::list<REFERENCE_LINE> &matchLineList, double &d0, double &d1) {
   ::std::string directory;
   ::std::string root;
   ::std::string extension;
   splitFilename(outputFileName, directory, root, extension);

   matchLineList.clear();
   
   // je lance le traitement d'astrometrie FOCAS
   char command[2048];
   sprintf(command,"IMA/SERIES . \"%s\" . . .fit . \"%s\" . .fit ASTROMETRY delta=5 epsilon=0.0002",
      root.c_str(), root.c_str());
   int ttResult = 1;
   //ttResult = _libtt_main(TT_SCRIPT_2,1,command);
   if(ttResult) {
      return 0;
   };

   // je lis le resultat dans le fichier com.lst
   FILE * hCom = fopen ("com.lst", "rt");
   int nbLine = 0;
   double ymean = 0;
   while (!feof(hCom)) {
      char ligne[1024];
      if (fgets(ligne,1024,hCom)==NULL) {
         continue;
      }
      //--- je lis les coordonnees
      // colonnes de com.lst                                             
      //   x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2 mag1-2 qualite1 qualite2    
      //  avec  qualite=1= ok  , qualite=-1 =sature                         

      double xima;
      double yima;
      double mag;
      double xcat;
      double ycat;
      double lambda;
      if (sscanf(ligne,"%lf %lf %lf %lf %lf %lf", &xima, &yima, &mag, &xcat, &ycat, &lambda) != 6 ) {
         continue;
      }
      REFERENCE_LINE matchLine;
      matchLine.posx = xima;
      matchLine.posy = xcat;
      matchLine.lambda = lambda;
      matchLineList.push_back(matchLine);
      ymean += ycat;
      if ( fabs(lambda - referenceLamba) < 0.01 ) {
         refPosX = xima;
      }

      nbLine++;
   }
   fclose(hCom);
   if ( nbLine != 0 ) {
      ymean /= nbLine;
   } 

   // je lis le resultat dans le fichier matrix.txt
   FILE * hmatrix = fopen ("matrix.txt", "rt");
   if ( hmatrix == NULL ) {
      throw std::exception("matrix.txt not found in function createMatchFile");
   }
   if (!feof(hmatrix)) {
      char ligne[1024];
      if (fgets(ligne,1024,hCom)!=NULL) {
         //--- je lis les coordonnees
         // colonnes de matrix.lst                                             
         //   x2 = a0* x1 + a11 * y1 + a0 
         double a1 = 1;
         double a11 = 0;
         double a0 = 0;
         if (sscanf(ligne,"%lf %lf %lf", &a1, &a11, &a0) == 3 ) {
             d0 = a0 + ymean * a11;
             d1 = a1;
         }
      }
   }
   fclose(hmatrix);
   
   return nbLine;
}
#endif

#ifndef USE_LIBTT 
int matchLine ( ::std::list<REFERENCE_LINE> &imageLineList,  ::std::list<REFERENCE_LINE> &catalogLineList, 
                double referenceLamba, double &refPosX, 
                ::std::list<REFERENCE_LINE> &matchLineList, double &d0, double &d1) {

   ::std::vector<focas_tableau_entree> data_tab10;
   ::std::vector<focas_tableau_entree> data_tab20;
   int flag_focas = 0;
   int flag_sature1 = 1;
   int flag_sature2 = 0;
   ::std::valarray<focas_tableau_corresp> corresp;
   ::std::valarray<focas_tableau_corresp> differe;
   int nbcom = 0;
   double *transf_1vers2 = new double[20];
   double *transf_2vers1 = new double[20];
   int nbcom2 = 0;
   double *transf2_1vers2 = new double[40];
   double *transf2_2vers1 = new double[40];
   double epsilon = 0.0002;
   double delta = 5;
   double seuil_poids = 0; 

   data_tab10.resize( imageLineList.size());

   int nbRow = 0;
   ::std::list<REFERENCE_LINE>::iterator iter;
   for (iter=imageLineList.begin(); iter != imageLineList.end(); ++iter) {
      REFERENCE_LINE line = *iter;
      data_tab10[nbRow].x = line.posx;
      data_tab10[nbRow].y = line.posy;
      data_tab10[nbRow].ad = line.lambda;
      data_tab10[nbRow].dec = line.posy;
      data_tab10[nbRow].mag = line.lambda;
      data_tab10[nbRow].mag_gsc = 1;
      data_tab10[nbRow].qualite = 1;
      data_tab10[nbRow].type = 0;
      nbRow++;
   }

   data_tab20.resize( catalogLineList.size());
   nbRow = 0;
   for (iter=catalogLineList.begin(); iter != catalogLineList.end(); ++iter) {
      REFERENCE_LINE line = *iter;
      data_tab20[nbRow].x = line.posx;
      data_tab20[nbRow].y = line.posy;
      data_tab20[nbRow].ad = line.lambda;
      data_tab20[nbRow].dec = line.posy;
      data_tab20[nbRow].mag = line.lambda;
      data_tab20[nbRow].mag_gsc = 1;
      data_tab20[nbRow].qualite = 1;
      data_tab20[nbRow].type = 0;
      nbRow++;
   }

   focas_main(data_tab10, data_tab20,
               flag_focas,
               flag_sature1,
               flag_sature2,
               corresp, 
               differe,
               &nbcom,
               transf_1vers2,
               transf_2vers1,
               &nbcom2,
               transf2_1vers2,
               transf2_2vers1,
               epsilon, delta, seuil_poids);

   // get result
   double ymean = 0;
   matchLineList.clear();
   for (int lineNo =0  ; lineNo <nbcom; lineNo++) {
      REFERENCE_LINE line;
      line.posx = corresp[lineNo].x1; // abscisse dans l'image
      line.posy = corresp[lineNo].y2; // abacisse dans le catalogue
      line.lambda = corresp[lineNo].mag2;
      if ( fabs(line.lambda - referenceLamba) < 0.01 ) {
         refPosX = line.posx;
      }
      // moyenne des y du catalogue
      ymean+=corresp[lineNo].y2;
      matchLineList.push_back(line);
   }

   if ( nbcom != 0 ) {
      ymean /= nbcom;
   } 

   //x2 = a0* x1 + a11 * y1 + a0
   int nb_coef_a = 3;
   double a1  = transf_2vers1[1*nb_coef_a+1];
   double a11 = transf_2vers1[1*nb_coef_a+2];
   double a0  = transf_2vers1[1*nb_coef_a+3];
   d0 = a0 + ymean * a11;
   d1 = a1;
   
   delete [] transf_1vers2;
   delete [] transf_2vers1;
   delete [] transf2_1vers2;
   delete [] transf2_2vers1;

   return nbcom;
}
#endif

void splitFilename(char *fileName, ::std::string &dir, ::std::string &root, ::std::string &ext) {
   // je cherche le dernier slash dans le nom du fichier
   char * shortFileName = strrchr(fileName,'/');  
   if ( shortFileName == NULL ) {
      // je cherche le dernier antislash dans le nom du fichier
      shortFileName = strrchr(fileName,'\\');  
      if ( shortFileName == NULL ) {
         dir.assign("");
         // je prends le nom entier s'il n'y a pas d'antislash
         shortFileName = fileName;
      } else {
         dir.assign(fileName, shortFileName-fileName);
         // je pointe le caractere suivant l'antislash
         shortFileName++;
      }
   } else {
      dir.assign(fileName, shortFileName-fileName);
      // je pointe le caractere suivant le slash
      shortFileName++;
   }

   char * extFileName = strrchr(shortFileName,'.'); 
   if ( extFileName == NULL ) {
      ext.assign("");
      root.assign(shortFileName);
   } else {
      ext.assign(extFileName);
      root.assign(shortFileName, extFileName - shortFileName);
   }



}