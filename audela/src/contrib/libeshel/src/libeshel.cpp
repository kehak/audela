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

#define DEVIDE_FLAT  1

// fonctions locales 


////////////////////////////////////////
////////////////////////////////////////
// Traitement de l'image "flat-field" //
////////////////////////////////////////
////////////////////////////////////////

void Eshel_processFlat(
   char *ledfileName,      // nom du fichier led (image pretraitee pour la calibration geometrique)
   char *tungstenFileName, // nom du fichier tungsten (image pretraitee pour le blaze)
   char *flatFileName,     // nom du fichier flat traitee  en sortie
   int ordre_ref_y,        // ordonnée du centre de l’ordre de référence
   int ordre_ref,          // numero de l’ordre de référence
   double lambda_ref,      // longueur d’onde de la raie de référence 
   int neon_ref_x,         // abscisse de la raie de référence 
   int wide_y,             // hauteur du binning 
   int seuil_ordre,        // seuil de détection
   ORDRE *ordre,           // table des ordre (avec la marge gauche, marge droit et slant renseignés)
   INFOSPECTRO &spectro,   // parametres du specto et de la caméra
   ::std::list<double> &lineList, // liste des raies
   int *nb_ordre,          // (OUT) nombre d'ordres trouvés
   double *dx_ref,         // (OUT) écart de l'abcisse de la raie de référence entre la position calculée et la position observée. 
   char *logFileName,      // nom du fichier de log
   char *returnMesssage)          // nom de l'image de controle
{

#ifdef _CRTDBG_MAP_ALLOC
_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
//_crtBreakAlloc = 2789812;
//_CrtMemState endState;
//_CrtMemState stateDiff;
_CrtMemState startState;
_CrtMemCheckpoint(&startState);
#endif

   INFOIMAGE *buffer = NULL;
   //FILE *hand_log = openLog(logFileName);
   CCfits::PFitsFile pLedFits = NULL;
   CCfits::PFitsFile pTungstenFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;


   try {
      PROCESS_INFO processInfo;
      double findTime;
      double trackTime;
      double extractTime;
      // ----------------
      // controle des ordres
      for(int n=0; n<MAX_ORDRE; n++ ) {         
         if (ordre[n].min_x < 0 || ordre[n].min_x > spectro.imax  ) {
            char message[1024];
            sprintf(message,"order %d : invalid min_x=%d , must be 0 < min_x < %d", n, ordre[n].min_x , spectro.imax);
            throw ::std::exception(message);
         }
         if (ordre[n].max_x < 0 || ordre[n].max_x > spectro.imax  ) {
            char message[1024];
            sprintf(message,"order %d : invalid max_x=%d , must be 0 < max_x < %d", n, ordre[n].max_x , spectro.imax);
            throw ::std::exception(message);
         }
         if (ordre[n].min_x > ordre[n].max_x   ) {
            char message[1024];
            sprintf(message,"order %d : invalid min_x=%d max_x=%d  must be min_x < max_x", n, ordre[n].min_x , ordre[n].max_x);
            throw ::std::exception(message);
         }
      }

      // -------------------------------------
      // Lecture de l'image LED 2D pretraitee
      // -------------------------------------  
      // je lis l'image stockee dans le PHDU du fichier d'entree 

      pLedFits = Fits_openFits(ledfileName, false); 
#ifdef _CRTDBG_MAP_ALLOC
_CrtMemCheckpoint(&startState);
#endif
      // je verifie si la table des ORDRES existe deja
      int ordersFound = 1;
      try { 
         Fits_getOrders(pLedFits, ordre, dx_ref);
         // la table des ordres existe
         ordersFound = 1;
         // je lis les autres informations
         Fits_getInfoSpectro(pLedFits, &spectro);
         Fits_getProcessInfo(pLedFits, &processInfo);
         Fits_closeFits(pLedFits);
         pLedFits = NULL;

         processInfo.bordure = 7;

      } catch( std::exception e ) {
         // la table des ordres n'existe pas 
         ordersFound = 0;
         Fits_closeFits(pLedFits);
         pLedFits = NULL;

         processInfo.referenceOrderNum = ordre_ref;
         processInfo.referenceOrderX =neon_ref_x;
         processInfo.referenceOrderY =ordre_ref_y;
         processInfo.referenceOrderLambda = lambda_ref; 
         processInfo.detectionThreshold = seuil_ordre;
         processInfo.calibrationIteration = 0; 
         processInfo.version = LIBESHEL_VERSION; 
         processInfo.bordure = 7;
      } 

      if ( ordersFound == 1 ) {
         pOutFits = Fits_createFits(ledfileName, flatFileName); 
      } else {
         pOutFits = Fits_createFits(ledfileName, flatFileName); 
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
         startTimer();
         find_y_pos(*buffer,processInfo,ordre,*nb_ordre,
            spectro.min_order,spectro.max_order);
         findTime = stopTimer("Flat find order");
         // ---------------------------------------------------------------------------------------
         // Détection de la ligne de crête des ordres dans l'image flat
         // et modélisation (polynômes de degré 4)
         // ---------------------------------------------------------------------------------------

         startTimer();
         for (int n=spectro.min_order;n<=spectro.max_order;n++)
         {
            if (ordre[n].flag==1)
            {
               //track_order(buffer,spectro.imax,spectro.jmax,wide_y,ordre,n);
               track_order(buffer,spectro.imax,spectro.jmax,8,ordre,n);
            }
         }
         trackTime = stopTimer("Flat track order");
         // ----------------------------------------------------------------------------------------------
         // Calcul de la position théorique de raies de calibration dans le profil spectral 
         // On s'appui sur la position observée de la raie Thorium 6584 A à l'ordre 34 
         // pour étalonner le calcul des autres raies. 
         // -----------------------------------------------------------------------------------------------
         double dx;
         if (calib_prediction(lambda_ref,ordre_ref,spectro.imax,spectro.jmax,neon_ref_x,&dx,spectro,lineList)) 
         {
            throw std::exception("calib_prediction error");
         } 
         *dx_ref = dx;
         if ( _isnan(dx) ) {
            *dx_ref = 0;
         }

         // ------------------------------------------------------------------------------------------------
         // Calcule la longueur d'onde du centre de chaque ordre (à imax/2)
         // ------------------------------------------------------------------------------------------------
         for (int n=0;n<MAX_ORDRE;n++)
         {
            if (ordre[n].flag==1)
            { 
               ordre[n].central_lambda=get_central_wave(spectro.imax,(double)spectro.imax/2.0,dx,n,spectro);
            }
         }

      }


      // ------------------------------------------------------------------------------------------------
      // Extraction de profils pour la fonction de blaze
      // 
      //  si le fichier ne contient pas les profils 1A
      //     si le fichier tungstenFileName est different de ledFileName
      //         j'ouvre le fichier tungstenFileName et je charge l'image 2D dans le buffer
      //         j'extrais les profils du buffer
      //     sinon
      //         j'extrais les profils du buffer déja charge
      //  sinon 
      //     si le fichier tungstenFileName est different de ledFileName
      //         je copie les profils 1A dans le FLAT
      //     sinon
      //         je copie les profils 1A dans le FLAT
      // ------------------------------------------------------------------------------------------------
      startTimer();
      // j'ouvre le fichier tungsten
      pTungstenFits = Fits_openFits(tungstenFileName, false); 

      try { 
         // Je copie les profils 1A  s'ils existent deja. 
         // Si les profils 1A sont absents une exception est retounee 
         // et je passe dans le catch pour les creer.
         for (int n=spectro.min_order;n<=spectro.max_order;n++) {
            if (ordre[n].flag==1) {
               int min_x;
               ::std::valarray<double> profile;
               Fits_getRawProfile(pTungstenFits, "P_1A_", n, profile, min_x);
               Fits_setRawProfile(pOutFits, "P_1A_", n, profile, min_x);
            }
         }
      } catch( std::exception e ) {
         if ( strcmp(ledfileName, tungstenFileName) != 0 ) {
            // j'ouvre le fichier TUNGSTEN s'il est different du fichier LED
            freeImage(buffer);
            buffer = NULL;
            // je lis l'image stockee dans le PHDU du fichier d'entree 
            Fits_getImage(pTungstenFits, &buffer);     
            // je contrôle que l'image de l'objet est de la meme taille que l'image de reference
            if (spectro.imax!=buffer->imax || spectro.jmax!=buffer->jmax) {
               char message[1024];
               sprintf(message,"TUNGSTEN image size (%d,%d) is different with LED image size (%d,%d)",
                  buffer->imax , buffer->jmax, spectro.imax, spectro.jmax);
               throw std::exception(message);
            }
         }
         // -----------------------------------------------------------------------------------------
         // Extraction de chaque ordre trouvé dans l'image TUNGSTEN et sauvegarde
         // du résultat dans des HDU P_1A_n distincts pour chaque ordre 
         // -----------------------------------------------------------------------------------------

         int cropHeight;
         if ( processInfo.referenceOrderNum < spectro.max_order ) {
            cropHeight = (int)(2.5 * (double)(ordre[processInfo.referenceOrderNum ].yc - ordre[processInfo.referenceOrderNum +1].yc)); 
         } else if ( processInfo.referenceOrderNum > spectro.min_order ) {
            cropHeight = (int)(2.5 * (double)(ordre[processInfo.referenceOrderNum -1 ].yc - ordre[processInfo.referenceOrderNum].yc));  
         } else {
            cropHeight = 60;
         }

         for (int n=spectro.min_order;n<=spectro.max_order;n++) {
            if (ordre[n].flag==1) {
               //int width = ordre[n].max_x - ordre[n].min_x +1;
               try {
               ::std::valarray<double> blazeProfile;
               std::valarray<PIC_TYPE> straightLineImage(spectro.imax * cropHeight);

               //  j'extrait le profil (en enlevant les bordures)
               extract_order(buffer, processInfo, n,ordre,spectro.imax,cropHeight,blazeProfile, straightLineImage,0);
               
               Fits_setRawProfile(pOutFits, "PTUNG_1A_", n, blazeProfile, ordre[n].min_x+processInfo.bordure);
               
               // j'ajoute l'image 2D des raies redressées dans le fichier de sortie
               //Fits_setStraightLineImage(pOutFits, n, straightLineImage , spectro.imax, cropHeight);
               
               // je lisse la fonction de blaze
               spectre_gauss(blazeProfile, 5, n);

               // j'enregistre le profil du blaze dans le fichier de sortie
               Fits_setRawProfile(pOutFits, "P_1A_", n, blazeProfile, ordre[n].min_x+processInfo.bordure);
               } catch( std::exception e ) {
                  char message[1024];
                  sprintf(message,"TUNGSTEN iallocation order=%d spectro.imax=%d cropHeight=%d min_x=%d max_x=%d bordure=%d", 
                     n,  spectro.imax, cropHeight, ordre[n].min_x, ordre[n].max_x, processInfo.bordure);                     
                  throw std::exception(message);
               }
            }
         }
      }
      extractTime = stopTimer("Flat extract order");
      // j'ajoute les infos du spectro, les parametres de traitement et la table des ordres dans le fichier de sortie
      Fits_setOrders(pOutFits, &spectro, &processInfo, ordre, *dx_ref);

      // je ferme le fichier tungsten
      Fits_closeFits(pTungstenFits);
      // je ferme le fichier de sortie
      Fits_closeFits( pOutFits);
      if ( buffer!= NULL) freeImage(buffer);
      //if ( hand_log != NULL) fclose(hand_log);

      sprintf(returnMesssage, "find=%0.3f track=%0.3f  extract=%0.3f ",findTime, trackTime, extractTime);
   } catch( std::exception e ) {
      if ( buffer!= NULL) freeImage(buffer);
      //if ( hand_log != NULL) fclose(hand_log);
      if ( pLedFits != NULL) Fits_closeFits(pLedFits);
      if ( pTungstenFits != NULL) Fits_closeFits( pTungstenFits);
      if ( pOutFits != NULL) Fits_closeFits( pOutFits);
      throw e;
   } 

#ifdef _CRTDBG_MAP_ALLOC
//_CrtDumpMemoryLeaks();
//_CrtMemCheckpoint(&endState);
//_CrtMemDifference(&stateDiff, &startState, &endState);
//_CrtMemDumpStatistics(&stateDiff);
_CrtMemDumpAllObjectsSince(&startState);
#endif
}

////////////////////////////////////////
////////////////////////////////////////
// Traitement de l'image "lamp"       //
////////////////////////////////////////
////////////////////////////////////////

void Eshel_processCalib(
   char *lampNameIn, 
   char *lampNameOut,
   char *flatName,                
   int ordre_ref, 
   double lambda_ref, 
   int neon_ref_x,
   int calibration_iteration,
   char *logFileName, 
   short *check,
   ::std::list<double> &lineList)  
{
#ifdef _CRTDBG_MAP_ALLOC
_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
_CrtMemState startStateThar;
_CrtMemCheckpoint(&startStateThar);
#endif

   INFOIMAGE *lampBuffer = NULL;
   CCfits::PFitsFile pFlatFits = NULL;
   //FILE *hand_log = openLog(logFileName);   
   ORDRE *ordre = NULL;
   INFOSPECTRO spectro;
   PROCESS_INFO processInfo;
   CCfits::PFitsFile pOutFits = NULL;
   double dx_ref= 0.0;

   try {
      ::std::list<LINE_GAP> lineGapList;
      // je lis les parametres spectro 
      pFlatFits = Fits_openFits(flatName, false);
      Fits_getInfoSpectro(pFlatFits, &spectro);

      //je complete les informations du traitement
      Fits_getProcessInfo(pFlatFits, &processInfo);
      processInfo.calibrationIteration = calibration_iteration;
      processInfo.bordure = 7;

      // je lis la table des ordres
      ordre = new ORDRE[MAX_ORDRE];
      memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
      Fits_getOrders(pFlatFits, ordre, &dx_ref);      
      // je cree le fichier de sortie
      pOutFits = Fits_createFits(lampNameIn, lampNameOut); 
      // j'ajoute le mot cle contenant la version de la librairie
      setSoftwareVersionKeyword(pOutFits);
      // je lis l'image 2D
      Fits_getImage(pOutFits, &lampBuffer); 

      // je contrôle que l'image de la lampe est de la meme taille que l'image de reference
      if (spectro.imax!=lampBuffer->imax || spectro.jmax!=lampBuffer->jmax) {
         char message[1024];
         sprintf(message,"La taille de l'image de la lampe %s (%d,%d) est de différente du flat %s (%d,%d)",
            lampNameIn, lampBuffer->imax , lampBuffer->jmax,flatName, spectro.imax, spectro.jmax);
         throw std::exception(message);
      }
      lineGapList.clear();

      int cropHeight;
      if ( processInfo.referenceOrderNum < spectro.max_order ) {
         cropHeight = (int)(2.5 * (double)(ordre[processInfo.referenceOrderNum ].yc - ordre[processInfo.referenceOrderNum +1].yc)); 
      } else if ( processInfo.referenceOrderNum > spectro.min_order ) {
         cropHeight = (int)(2.5 * (double)(ordre[processInfo.referenceOrderNum -1 ].yc - ordre[processInfo.referenceOrderNum].yc));  
      } else {
         cropHeight = 60;
      }

      startTimer();
      for (int n=spectro.min_order;n<=spectro.max_order;n++) {
         if (ordre[n].flag==1) {
            // -----------------------------------------------------------
            // Extraction des ordres de l'image de la lampe spectrale
            // -----------------------------------------------------------  
            int width = ordre[n].max_x - ordre[n].min_x +1;            
            ::std::valarray<double> calibRawProfile(width);
            std::valarray<PIC_TYPE> straightLineImage(spectro.imax * cropHeight);
            extract_order(lampBuffer, processInfo, n, ordre, spectro.imax, cropHeight, calibRawProfile, straightLineImage, 0 );
            
            // j'ajoute l'image 2D des raies redressées dans le fichier de sortie
            Fits_setStraightLineImage(pOutFits, n, straightLineImage , spectro.imax, straightLineImage.size()/spectro.imax);

            // ------------------------------------------------------------------------------
            // Division des profils de calibration par les profils "flat" (ordre après ordre)
            // ------------------------------------------------------------------------------
            std::valarray<double> blazeProfile;
            if ( DEVIDE_FLAT ) {
               int blaze_min_x;
               Fits_getRawProfile(pFlatFits, "P_1A_", n, blazeProfile, blaze_min_x); 
               for(unsigned int i = 0; i < blazeProfile.size(); i++ ) {
                  if (blazeProfile[i] !=0  ) {
                     calibRawProfile[i] /= blazeProfile[i];
                  } else {
                     calibRawProfile[i] = 0;
                  }
               }
               // J'enregistre le profil 1A du blaze dans le fichier de calibration 
               Fits_setRawProfile(pOutFits, "FLAT_1A_", n, blazeProfile, blaze_min_x);
            }

            // j'ajoute le profil 1A dans le fichier de sortie
            Fits_setRawProfile(pOutFits, "P_1A_", n, calibRawProfile, ordre[n].min_x+processInfo.bordure);
            
            // ------------------------------------------------------------------------------
            // calibration spectrale - calcul des coefficients des polynômes
            // ------------------------------------------------------------------------------            
            calib_spec(n,calibration_iteration, processInfo, spectro, calibRawProfile,ordre,
               lineList,lineGapList);

            
            // --------------------------------------------------------------------
            // Etalonnage spectral du spectre de  la lampe
            // au pas de 0,1 A/pixel (interpollation spline)
            // --------------------------------------------------------------------
            // je calcule le profil 1B du flat
            //std::valarray<double> objectProfile;
            //double lambda1;
            //make_interpol(calibRawProfile,ordre[n].a3,ordre[n].a2,ordre[n].a1,ordre[n].a0, step, objectProfile, &lambda1);   
            //// j'enregistre le profil 1B de la calibration dans le fichier de calibration
            //Fits_setLinearProfile(pOutFits, "P_1B_", n, objectProfile, lambda1, step) ;

            //// je calcule le profil 1B du flat
            //if ( DEVIDE_FLAT ) {
            //   std::valarray<double> flatLinearProfile;
            //   make_interpol(flatRawProfile,ordre[n].a3,ordre[n].a2,ordre[n].a1,ordre[n].a0, step, flatLinearProfile, &lambda1);
            //   // j'enregistre le profil 1B du flat dans le fichier de calibration
            //   Fits_setLinearProfile(pOutFits, "FLAT_1B_", n, flatLinearProfile, lambda1, step) ;
            //}
            
         }
      }
      stopTimer("Thar calib order ");
      // j'ajoute le nom du fichier du Flat dans les mots clefs du fichier de calibration
      char * shortFileName = strrchr(flatName,'/');  // je cherche le dernier slash dans le nom du fichier
      if ( shortFileName == NULL ) {
         shortFileName = strrchr(flatName,'\\');  // je cherche le dernier antislash dans le nom du fichier
         if ( shortFileName == NULL ) {
            // je prends la valeur enière s'il n'y a pas d'antislash
            shortFileName = flatName;
         } else {
            // je pointe le caractere suivant l'antislash
            shortFileName++;
         }
      } else {
         // je pointe le caractere suivant le slash
         shortFileName++;
      }
      // j'ajoute le mot clef contenant le nom du fichier du Flat
      Fits_setKeyword(pOutFits,"PRIMARY","FLATNAME",shortFileName,"FLAT file name");

      // j'enregistre la table des ordres dans le fichier de calibration
      Fits_setOrders(pOutFits,&spectro, &processInfo, ordre, dx_ref);
      // j'enregistre la table des raies de calibration dans le fichier de calibration
      Fits_setLineGap(pOutFits,lineGapList);
      // j'enregistre les profils calibrés dans le fichier de calibration
      //for (int n=spectro.min_order;n<=spectro.max_order;n++) {
      //   if (ordre[n].flag==1) {
      //      Fits_setLinearProfile(pOutFits, n, objectProfile[n], lambda1[n], step);
      //   }
      //}
      Fits_closeFits(pOutFits);
      freeImage(lampBuffer);
//      fclose(hand_log);
      delete [] ordre;      
      Fits_closeFits(pFlatFits);
      pFlatFits = NULL;

   } catch( std::exception e ) {
      Fits_closeFits(pFlatFits);
      Fits_closeFits(pOutFits);
      if ( ordre != NULL) delete [] ordre;
      if ( lampBuffer!= NULL) freeImage(lampBuffer);
      //if ( hand_log != NULL) fclose(hand_log);
      throw e;
   } 
#ifdef _CRTDBG_MAP_ALLOC
_CrtMemDumpAllObjectsSince(&startStateThar);
#endif
}

//----------------------------------------------------------------------------
// Eshel_processObject
//
// Traitement de l'image d'un objet    
//   contrôle que l'image de l'objet est de la meme taille que l'image de reference
//   Pour chaque ordre :
//     Extraction des ordres de l'image de l'objet
//     ajoute le profil dans le fichier de sortie
//     Divise de profils 1A par le profil du flat 
//     Etalonnage spectral du spectre de l'objet et re-échantillonnage au pas de 
//        step=0,1 A/pixel (interpollation spline)
//     Si la reponse instrumentale est fournie, divise le profil 1B par la reponse 
//        instrumentale et enregsitre les profils 1C
//   Si la reponse instrumentale est fournie, aboute les profil 1C et enregistre le profil P_1C_FULL
//      sinon aboute les profil 1B et enregistre le profil P_1B_FULL
//   enregistre la table des ordres dans le fichier de sortie
//
//  @param objectFileNameIn nom du fichier contenant l'image 2D de l'objet
//  @param objectFileNameOut nom du fichier en sortie
//  @param calibName     nom du fichier contant l'image et les paramètres de calibration.
//  @param responseFileName nom du fichier de la réponse instrumentale (si le nom est vide 
//                          le profil P_1C n'est pas calculé
//  @param recordObjectImage  option d'enregistrament de l'image 2D de l'objet. 0=ne pas enregistrer, 1=enregistrer
//  @param logFileName  nom du fichier trace
//  @param check        pointeur de la zone memoire contenant l'image check
//  @return void
// 

void Eshel_processObject(char *objectFileNameIn, char *objectFileNameOut, 
                char *calibName,      // nom du fichier de calibration
                char *responseFileName,   // nom du fichier de reponse instrumentale
                int responsePerOrder,     // application de la réponse instrumentale O= partir du profil FULL 1= a partir des ordres inviduels de la RI
                int minOrder, int maxOrder, 
                int  recordObjectImage,   //  option d'enregistrament de l'image 2D de l'objet
                ::std::valarray<CROP_LAMBDA> &cropLambda,
                char *cosmicCleaning,        // methode de nettoyage des cosmiquess
                char *logFileName, short *check)  
{
#ifdef _CRTDBG_MAP_ALLOC
_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
_CrtMemState startStateObject;
_CrtMemCheckpoint(&startStateObject);
#endif

   CCfits::PFitsFile pInFits = NULL;
   CCfits::PFitsFile pCalibFits = NULL;
   CCfits::PFitsFile pOutFits = NULL;
   CCfits::PFitsFile pResponseFits = NULL;
   INFOIMAGE *objectBuffer = NULL;
   ORDRE *ordre = NULL;
   //FILE *hand_log = openLog(logFileName);
   
   try {

      INFOSPECTRO spectro;
      PROCESS_INFO processInfo;
      ::std::valarray<::std::valarray<double>> objectProfile(MAX_ORDRE);
      double lambda1[MAX_ORDRE]; 
      double step= 0.05;
      double dx_ref = 0.0;

      startTimer(); 
      // je lis les parametres du spectrographe et des traitements dans le fichier de calibration
      pCalibFits = Fits_openFits(calibName, false);
      Fits_getInfoSpectro(pCalibFits, &spectro);
      Fits_getProcessInfo(pCalibFits, &processInfo);
      processInfo.bordure = 7; 

      // je lis les parametres des ordres dans le fichier de calibration
      ordre = new ORDRE[MAX_ORDRE];
      memset(ordre,0,MAX_ORDRE*sizeof(ORDRE));
      Fits_getOrders(pCalibFits, ordre, &dx_ref);

      // je contrôle que la plage des ordres demandee est incluse dans la page des ordre de l'image de calibration
      if (minOrder < spectro.min_order || maxOrder > spectro.max_order ) {
         char message[1024];
         sprintf(message,"Required order range (%d to %d) is larger than order range (%d to %d) of calibration file",
            minOrder, maxOrder , spectro.min_order, spectro.max_order);
         throw std::exception(message);
      }
 
      // je cree le fichier de sortie        
      if ( recordObjectImage == 1 ) {
         // je copie l'image 2D dans le premier HDU
         pOutFits = Fits_createFits(objectFileNameIn, objectFileNameOut); 
         // je lis l'image 2D
         Fits_getImage(pOutFits, &objectBuffer);
      } else {
         // je lis l'image stockee dans le PHDU du fichier d'entree
         pInFits = Fits_openFits(objectFileNameIn, false); 
         Fits_getImage(pInFits, &objectBuffer);     
         // je cree le fichier de sortie 
        ::std::valarray<double> emptyProfile ;
        emptyProfile.resize(1);
        emptyProfile[0] = 1;
        // je cree le fichier de sortie avec un profil vide dans le premier HDU
        pOutFits = Fits_createFits(objectFileNameOut, emptyProfile, 0, step); 
        // je copie les mots dans le PHDU a partir de l'image pretraitee de l'objet
        Fits_setKeyword(pOutFits,pInFits);
        // je ferme l'image pretraitee de l'objet car il n'y en a plus besoin (cela libere la memoire) 
        Fits_closeFits(pInFits);
        pInFits = NULL;
      }
      
      // je contrôle que l'image de l'objet est de la meme taille que l'image de reference
      if (spectro.imax!=objectBuffer->imax || spectro.jmax!=objectBuffer->jmax) {
         char message[1024];
         sprintf(message,"La taille de l'image de la lampe %s (%d,%d) est de différente du flat %s (%d,%d)",
            objectFileNameIn, objectBuffer->imax , objectBuffer->jmax, calibName, spectro.imax, spectro.jmax);
         throw std::exception(message);
      }

      // j'ajoute le mot cle contenant la version de la librairie
      setSoftwareVersionKeyword(pOutFits);

      // j'ajoute l'indicateur de nettoyage des cosmiques
      if( cosmicCleaning != NULL) {
         Fits_setKeyword(pOutFits,"PRIMARY","BSS_COSM",(char *)cosmicCleaning,"Cosmics cleaning method");
      }
            
      // j'ajoute le mot clef FLATNAME contenant le nom du fichier Flat
      ::std::string fileName;
      Fits_getKeyword(pCalibFits,"PRIMARY","FLATNAME",fileName);
      Fits_setKeyword(pOutFits,"PRIMARY","FLATNAME",(char *)fileName.c_str(),"Flat file name");

      // j'ajoute le mot cle CALINAME contenant le nom du fichier de calibration 
      char * shortFileName = strrchr(calibName,'/');  // je cherche le dernier slash dans le nom du fichier
      if ( shortFileName == NULL ) {
         shortFileName = strrchr(calibName,'\\');  // je cherche le dernier antislash dans le nom du fichier
         if ( shortFileName == NULL ) {
            // je prends le nom entier s'il n'y a pas d'antislash
            shortFileName = calibName;
         } else {
            // je pointe le caractere suivant l'antislash
            shortFileName++;
         }
      } else {
         // je pointe le caractere suivant le slash
         shortFileName++;
      }
      Fits_setKeyword(pOutFits,"PRIMARY","CALINAME",shortFileName,"Calibration file name");
      
      int cropHeight;
      if ( processInfo.referenceOrderNum < maxOrder) {
         cropHeight = (int)(2.5 * (double)(ordre[processInfo.referenceOrderNum ].yc - ordre[processInfo.referenceOrderNum +1].yc)); 
      } else if ( processInfo.referenceOrderNum > minOrder ) {
         cropHeight = (int)(2.5 * (double)(ordre[processInfo.referenceOrderNum -1 ].yc - ordre[processInfo.referenceOrderNum].yc));  
      } else {
         cropHeight = 60;
      }
      stopTimer("Object load file ");

      for (int n=minOrder; n<=maxOrder; n++) {
         if (ordre[n].flag==1) {
            int width = ordre[n].max_x - ordre[n].min_x +1;
            ::std::valarray<double> object1AProfile(width);

            // -----------------------------------------------------------
            // Extraction des ordres de l'image de l'objet
            // -----------------------------------------------------------  
            startTimer(); 
            std::valarray<PIC_TYPE> straightLineImage(spectro.imax * cropHeight);
            extract_order(objectBuffer, processInfo, n, ordre, spectro.imax, cropHeight, object1AProfile, 
               straightLineImage, 1);
               
            // j'ajoute le profil 1A dans le fichier de sortie
            int min_x = ordre[n].min_x+processInfo.bordure;
            Fits_setRawProfile(pOutFits, "P_1A_", n, object1AProfile, min_x);
            stopTimer("Object extract_order %d",n);

            // -------------------------------------------
            // Divise le profil 1A par la fonction de blaze extraite du Flat 
            // -------------------------------------------
            startTimer(); 
            std::valarray<double> flatRawProfile;
            if ( DEVIDE_FLAT) {
               int blaze_min_x;
               // je recupere la fonction de blaze
               Fits_getRawProfile(pCalibFits, "FLAT_1A_", n, flatRawProfile, blaze_min_x); 
               // je divise le profil par la fonction de blaze
               for(unsigned i = 0; i < object1AProfile.size(); i++ ) {
                  if (flatRawProfile[i] !=0  ) {
                     object1AProfile[i] /= flatRawProfile[i + min_x - blaze_min_x];
                  } else {
                     object1AProfile[i] = 0;
                  }
               }
            }
            stopTimer("Object dive by blaze %d",n);
            
            // --------------------------------------------------------------------
            // Etalonnage spectral du spectre de l'objet et re-échantillonnage 
            // au pas de step=0,1 A/pixel (interpollation spline)
            // --------------------------------------------------------------------
            startTimer(); 
            make_interpol(object1AProfile, spectro, processInfo, ordre, n, dx_ref, step, objectProfile[n], lambda1[n]); 

            if ( _isnan(lambda1[n]) ) {
               char message[1024];
               sprintf(message,"make_interpol lambda1[%d]=%f", n, lambda1[n]);
               throw std::exception(message);
            }
            stopTimer("Object make_interpol %d",n);

            // j'enregistre le profil 1B
            Fits_setLinearProfile(pOutFits, "P_1B_", n, objectProfile[n], lambda1[n], step);

            // ---------------------------------------------------------------
            // Division éventuelle par la réponse individuelle de chaque ordre
            // ---------------------------------------------------------------
            if ( responseFileName != NULL && responsePerOrder == 1) {
               startTimer(); 
               ::std::valarray<double> responseProfile;
               double responseLambda1; 
               double responseStep; 

               // S'il n'est pas déjà ouvert, j'ouvre le fichier la réponse instrumentale a l'iteration du premier ordre
               if ( pResponseFits == NULL ) {
                  pResponseFits = Fits_openFits(responseFileName, false);
               }

               Fits_getLinearProfile(pResponseFits,(char *) "P_RESPONSE_", n, responseProfile,&responseLambda1,&responseStep);

               if ( responseProfile.size() > 0 ) {
                  divideResponsePerOrder(objectProfile[n], lambda1[n], step, responseProfile, responseLambda1, responseStep);                       
               }      
               stopTimer("Object divideResponsePerOrder %d",n);
            }

            // ----------------------------------------------------------------------------
            // Filtrage gaussien éventuel de chacun des profils spectraux (à xxx sigma)
            // ----------------------------------------------------------------------------
            //double sigma = 0;
            //if ( sigma != 0 ) {
            //   spectre_gauss(objectProfile[n], sigma, n);
            //}  

         }
      }
      

      if ( pResponseFits != NULL) {
         Fits_closeFits(pResponseFits);
         pResponseFits = NULL;
      }

      // --------------------------------------------------------------------
      // Normalisation de tous les ordres à la valeur de l'intensité moyenne
      // trouvée entre les longueurs d'onde b1 et b2 A (compatibles avec l'ordre 34)   
      // --------------------------------------------------------------------
      startTimer();
      double norme = getNorme(objectProfile, lambda1, 6620.0, 6635.0, ordre, step);
      for (int n=minOrder; n<=maxOrder; n++) {
         if (ordre[n].flag==1) {
            if ( objectProfile.size() > 0 ) {
               objectProfile[n] /=norme;
            }
         }
      }
      stopTimer("Normalisation 1B_n 6620.0, 6635.0"); 

      // ----------------------------------------------------------------------------
      // Détourage des ordres (si le fichier def_lambda.lst existe)
      // ----------------------------------------------------------------------------
      if ( cropLambda.size() != 0  ) {
         startTimer();
         crop_lambda(cropLambda, objectProfile, lambda1, ordre, step, minOrder, maxOrder);
         stopTimer("Object Détourage objet ");         
      }
      
      // --------------------------------------------------------------------
      // j'aboute les profils (profil 1B si pas de RI par ordre, ou profil 1C si déjà divisé par RI par ordre)
      // --------------------------------------------------------------------
      startTimer();
      std::valarray<double>  fullProfile;
      double fullLambda1;
      abut1bOrder(objectProfile, lambda1, minOrder, maxOrder,step, fullProfile, fullLambda1);
      stopTimer("Object abut1bOrder ");

      // j'enregistre le resultat dans le fichier de sortie
      //Fits_setFullProfile(pOutFits, "P_1B_FULL0", fullProfile, fullLambda1, step); 
      
      // --------------------------------------------------------------------
      // Correction de la fonction de Planck
      //  On corrige Planck sur le spectre global s'il n'y a pas de reponse ou si la réponse est aussi globale
      // --------------------------------------------------------------------
      if ( responseFileName == NULL || (responseFileName != NULL && responsePerOrder == 0) ) {
         startTimer();
         planck_correct(fullProfile, fullLambda1, step, 2750.0);
         Fits_setFullProfile(pOutFits, "P_1B_FULL", fullProfile, fullLambda1, step);
         stopTimer("Object planck correct ");
      }

      // je divise par la reponse instrumentale si cela n'a pas deja ete fait par ordre
      if ( responseFileName != NULL ) {           
         startTimer();
         
         if ( responsePerOrder == 0 ) {            
            ::std::valarray<double> responseProfile;
            double responseLambda1; 
            double responseStep; 
         
            // je lis la reponse instrumentale globale
            pResponseFits = Fits_openFits(responseFileName, false);
            Fits_getLinearProfile(pResponseFits,"PRIMARY", responseProfile, &responseLambda1, &responseStep);
            //je ferme de fichier de la réponse instrumentale globale
            Fits_closeFits(pResponseFits);
            pResponseFits = NULL;       


            // --------------------------------------------------------------------
            // je divise chaque profil P_1B_n par la reponse instrumentale globale
            // --------------------------------------------------------------------
            for (int n=minOrder; n<=maxOrder; n++) {
               if (ordre[n].flag==1) {
                  if ( responseProfile.size() > 0 ) {
                     divideResponse(objectProfile[n], lambda1[n], step, responseProfile, responseLambda1, responseStep);
                  } 
               }
            }         
         
            // --------------------------------------------------------------------
            // je divise le profile P_1B_FULL par la réponse instrumentale globale 
            // --------------------------------------------------------------------
            startTimer();
            divideResponse(fullProfile, fullLambda1, step, responseProfile, responseLambda1, responseStep); 
            
         } 

         // --------------------------------------------------------------------
         // j'enregistre les profils 1C
         // --------------------------------------------------------------------
         for (int n=minOrder; n<=maxOrder;n++) {
            if (ordre[n].flag==1) {
               Fits_setLinearProfile(pOutFits, "P_1C_", n, objectProfile[n], lambda1[n], step);
            }
         }


         // --------------------------------------------------------------------
         // je normalise le profil full1C
         // --------------------------------------------------------------------
         int posBegin = (int)((6620.0 -fullLambda1)/step +0.5);
         int posEnd   = (int)((6635.0 -fullLambda1)/step -0.5);
         norme = 0.0;
            for(int pos=posBegin ; pos<=posEnd ; pos++) {
               norme += fullProfile[pos];
            }
            if ( posEnd != posBegin) {
               // je calcule la norme
               norme = norme / (posEnd - posBegin +1);      
            } else {
               norme = 1;
            }
         // je divise par la norme
         fullProfile /=norme;


         // --------------------------------------------------------------------
         // j'enregistre le profil full1C
         // --------------------------------------------------------------------
         Fits_setFullProfile(pOutFits, "P_1C_FULL", fullProfile, fullLambda1, step);
         stopTimer("Object division 1B_full par RI");    

      } 

      // j'enregistre la table des ordres dans le fichier de sortie
      Fits_setOrders(pOutFits,&spectro, &processInfo, ordre, dx_ref);

      Fits_closeFits(pOutFits);
      Fits_closeFits(pCalibFits);
      delete [] ordre;
      freeImage(objectBuffer);
      //fclose(hand_log);
   } catch (std::exception &e) {
      Fits_closeFits(pInFits);
      Fits_closeFits(pOutFits);
      Fits_closeFits(pCalibFits);
      Fits_closeFits(pResponseFits);
      if ( ordre != NULL) delete ordre;
      if ( objectBuffer!= NULL) freeImage(objectBuffer);
      //if ( hand_log != NULL) fclose(hand_log);
      throw e;
   }
#ifdef _CRTDBG_MAP_ALLOC
_CrtMemDumpAllObjectsSince(&startStateObject);
#endif
}


////////////////////////////////////////////
////////////////////////////////////////////
// joinSpectra : aboutement des spectres  //
////////////////////////////////////////////
////////////////////////////////////////////
/*
void Eshel_joinSpectra(char *nom_objet_fits, char *nom_calib_fits,
                char *nom_objet_full0_fits, char *nom_objet_full_fits,
                int min_order, int max_order,
                int useFlat,
                short *check)  
{
   if (useFlat==0) {
      aboute_spectres(max_order,min_order,nom_objet_fits,"",nom_objet_full0_fits,useFlat);
   } else {
      aboute_spectres(max_order,min_order,nom_objet_fits,nom_calib_fits,nom_objet_full0_fits,useFlat);
   }
   
   // -----------------------------------------------------------------------------------
   // Corrige la température de couleur de la lampe ayant servie à prendre le flat-field
   // -----------------------------------------------------------------------------------
   planck_correct(nom_objet_fits,nom_objet_full_fits,2800.0);
}
*/

// ---------------------------------------------------
// Eshel_freeData
//    supprime un bloc de donnees de la memoire
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_freeData(void *values) 
{
   if ( values != NULL) {
      free(values);
   }
}


// ---------------------------------------------------
// Eshel_getRawProfile
//    retourne les valeurs d'un profil brut (non calibre)
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getRawProfile(char *fileName, int numOrder, double **values, int &min_x, int &size)  {
   CCfits::PFitsFile pFits = NULL;
   ::std::valarray<double> rawProfile;

   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getRawProfile(pFits, "P_1A_", numOrder, rawProfile, min_x);
      *values = new double[rawProfile.size()];
      // je copie le valarray dans l'aarray
      for (size_t i=0; i<rawProfile.size(); i++) {
         (*values)[i] = rawProfile[i];
      }
      size = rawProfile.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      Fits_closeFits(pFits);
      throw e;
   }

}

// ---------------------------------------------------
// Eshel_getLinearProfile
//    retourne les valeurs d'un profil calibré lineairement
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getLinearProfile(char *fileName, int order, double **values, double *lambda1, double *step, int *size) 
{
   CCfits::PFitsFile pFits = NULL;
   ::std::valarray<double> linearProfile;
   try {
      pFits = Fits_openFits(fileName, false);
      Fits_getLinearProfile(pFits, "P_1B_", order, linearProfile,lambda1,step);
      *values = new double[linearProfile.size()];
      for (size_t i=0; i<linearProfile.size(); i++) {
         (*values)[i] = linearProfile[i];
      }
      *size = linearProfile.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getProfile
//    retourne les valeurs d'un profil echantillone lineairement
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getProfile(char *fileName, char * hduName, double **values, double *lambda1, double *step, int *size) 
{
   CCfits::PFitsFile pFits = NULL;
   ::std::valarray<double> linearProfile;
   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getFullProfile(pFits, hduName, linearProfile,lambda1,step);
      *values = new double[linearProfile.size()];
      for (size_t i=0; i<linearProfile.size(); i++) {
         (*values)[i] = linearProfile[i];
      }
      *size = linearProfile.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getLineGap
//    retourne les ecarts
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getLineGap(char *fileName, LINE_GAP **lineGap, int *size) 
{
   CCfits::PFitsFile pFits = NULL;
   ::std::list<LINE_GAP> lineGapList;
   try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getLineGap(pFits, lineGapList);
      *lineGap = new LINE_GAP[lineGapList.size()];
      int i = 0; 
      for(::std::list<LINE_GAP>::iterator iter  = lineGapList.begin() ; iter != lineGapList.end(); ++iter ) {
         (*lineGap)[i].order = iter->order;
         (*lineGap)[i].l_obs = iter->l_obs;
         (*lineGap)[i].l_calc = iter->l_calc;
         (*lineGap)[i].l_diff = iter->l_diff;
         (*lineGap)[i].l_posx = iter->l_posx;
         (*lineGap)[i].valid = iter->valid;
         i++;
      }
      *size = lineGapList.size(); 
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getOrderTable
//    retourne la table des ordres
//    et l'abscisse de l'odre de reference
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getOrderTable(char *fileName, ORDRE **pOrders, double *pdx_ref) 
{
   CCfits::PFitsFile pFits = NULL;
   *pOrders = NULL;
   try {
      *pOrders = new ORDRE[MAX_ORDRE];
      memset(*pOrders,0,MAX_ORDRE*sizeof(ORDRE));
      pFits = Fits_openFits(fileName, false);   
      Fits_getOrders(pFits, *pOrders, pdx_ref);
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (*pOrders != NULL) delete [] (*pOrders );
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

// ---------------------------------------------------
// Eshel_getInfoSpectro
//   retourne les parametre du spectro contenu dans un fichier FITS
//   dans une structure INFOSPECTRO
// Parameters 
//   fileName : nom complet du fichier FITS
//   InfoSpectro : pointeur sur une structure INFOSPECTRO dejo alloue par le programme appelant
// Return
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------
void Eshel_getInfoSpectro(char *fileName, INFOSPECTRO *pInfoSpectro) 
{
   CCfits::PFitsFile pFits = NULL;
  try {
      pFits = Fits_openFits(fileName, false);   
      Fits_getInfoSpectro(pFits, pInfoSpectro);
      Fits_closeFits(pFits);
   } catch (std::exception e) {
      if (pFits!= NULL) Fits_closeFits(pFits);
      throw e;
   }
}

void log(const char *fmt, ...)
{
   FILE *f;   
   va_list mkr;
   va_start(mkr, fmt);

   f = fopen("reduc.log","at+");
   vfprintf(f,fmt, mkr);
   va_end(mkr);
   fclose(f);

}

#include <time.h>
#include <sys/timeb.h>		// pour timer 
double startTime;

void startTimer()
{

#if defined(WIN32)
    struct _timeb timebuffer;
    _ftime(&timebuffer);
#else
    struct timeb timebuffer;
    ftime(&timebuffer);
#endif
    startTime = ((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
}

double stopTimer(LPTSTR lpFormat, ...)
{
    double stopTime;
#if defined(WIN32)
    struct _timeb timebuffer;
    _ftime(&timebuffer);
#else
    struct timeb timebuffer;
    ftime(&timebuffer);
#endif
    stopTime =	((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
    double delay = stopTime - startTime;

    TCHAR szBuf[1024];
    va_list marker;
    va_start( marker, lpFormat );
    vsprintf( szBuf, lpFormat, marker );
    OutputDebugString( szBuf );
    log("%f s : %s \n", delay, szBuf);
    /*printf(szBuf);
    sprintf(szBuf," %f s\n",delay);
    OutputDebugString( szBuf );
    printf(szBuf);*/
    va_end( marker );
    return delay;
}
