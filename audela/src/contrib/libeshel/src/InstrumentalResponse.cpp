
#include <algorithm>    // pour std::max()
#include "InstrumentalResponse.h"
#include "order.h"
#include "fitsfile2.h"

CInstrumentalResponse::CInstrumentalResponse(void)
{
}

CInstrumentalResponse::~CInstrumentalResponse(void)
{
}

// ---------------------------------------------------------------------------
// makeNullResponse 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "prefix_<numOrder>" dans le fichier FITS
// @return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------

void CInstrumentalResponse::makeNullResponse( const char* objectFileName, const char * responseFileName ) {
   try {
      INFOSPECTRO infoSpectro;
      ORDRE ordre[MAX_ORDRE];
      double dx_ref;

      CFitsFile objectFits;
      CFitsFile responseFits;

      // j'ouvre le fichier de l'objet
      objectFits.open(objectFileName, false);
      objectFits.getInfoSpectro(&infoSpectro);
      objectFits.getOrders(ordre, &dx_ref);

      // je recherche le profil FULL 
      ::std::valarray<double> linearProfile;
      double lambda1 = 0; 
      double step = 0;
      try {
         objectFits.getLinearProfile("P_1C_FULL", linearProfile, &lambda1, &step); 
      } catch (std::exception e) {
         objectFits.getLinearProfile("PRIMARY", linearProfile, &lambda1, &step); 
      }

      // je force à 1 toutes les valeurs du profil P_1C_FULL
      linearProfile = 1;

      // je cree le fichier de la reponse avec le profil FULL dans le PRIMARY HDU
      responseFits.create(responseFileName, linearProfile, lambda1, step);
      /*responseFits.setKeyword("PRIMARY", "IMAGETYP", "RESPONSE","Image type");
      string keywordValue;
      objectFits.getKeyword("PRIMARY", "DETNAM", keywordValue);
      responseFits.setKeyword("PRIMARY", "DETNAM", keywordValue.c_str(), "");
      objectFits.getKeyword("PRIMARY", "TELESCOP", keywordValue);
      responseFits.setKeyword("PRIMARY", "TELESCOP", keywordValue.c_str(), "");
      objectFits.getKeyword("PRIMARY", "INSTRUME", keywordValue);
      responseFits.setKeyword("PRIMARY", "INSTRUME", keywordValue.c_str(), "");*/

      // je copie les profils P_1C_n dans le fichier de la réponse 
      for (int n=infoSpectro.min_order; n<=infoSpectro.max_order; n++) {
         if (ordre[n].flag==1) {
            objectFits.getLinearProfile("P_1C_", n, linearProfile, &lambda1, &step);
            // je force à 1 toutes les valeurs du profil P_1C_FULL
            linearProfile = 1;
            responseFits.setLinearProfile("P_RESPONSE_", n, linearProfile, lambda1, step);
         }
      }
      
   } catch (std::exception &e) {
      throw e;
   }

}

// ---------------------------------------------------------------------------
// makeResponse 
//    copie le contenu des fichiers .dat dans les HDU du fichier FITS de sortie
//    les HDU s'appellent "P_RESPONSE_<numOrder>" dans le fichier FITS
//
// @param  genericDatName nom generique des fichiers .dat
// @param  firstOrder      index du premier profil
// @param  lastOrder       index du dernier profil
// @param  responseFileName nom du fichier FITS en sortie
// @param  keywordList     list des mots cles de la réponse instrumentale.
//
// @return void, retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------

void CInstrumentalResponse::makeResponse( const char* genericDatName, int firstOrder , int lastOrder, const char * responseFileName, ::std::list<CKeyword> keywordList ) {
   try {
      char inputFileName[1024]; 
      CFitsFile responseFits;
      std::valarray<double> linearProfile;
      double lambda1;
      double step; 
      
      sprintf(inputFileName,"%sfull.dat",genericDatName);
      loadDatResponse(inputFileName, linearProfile, lambda1, step);

      // je cree le fichier de sortie en mettant le profil FULL dans le PHDU        
      responseFits.create(responseFileName, linearProfile, lambda1, step);
      
      // je copie les mots cles dans le PHDU
      for(::std::list<CKeyword>::iterator iter  = keywordList.begin() ; iter != keywordList.end(); ++iter ) {
         CKeyword keyword = *(iter);
         responseFits.setKeyword("PRIMARY", keyword.name,keyword.value,keyword.comment);
      }
            
      // j'ajoute les profils de chaque ordre dans les HDU suivants
      for(int n = firstOrder; n<= lastOrder; n++) {         
         sprintf(inputFileName,"%s%d.dat",genericDatName,n);
         loadDatResponse(inputFileName, linearProfile, lambda1, step);
         responseFits.setLinearProfile("P_RESPONSE_", n, linearProfile, lambda1, step);
      }

   } catch (std::exception &e) {
      throw e;
   }

}

// ---------------------------------------------------------------------------
// charge un fichier .dat en memoire 
//  
// @param  inputFileName  nom du fichier .dat
// @param  linearProfile  intensités du profil
// @param  lambda1        longueur d'onde du prermier point du profil
// @param  step           increment de la longueur d'onde
// @return void, retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CInstrumentalResponse::loadDatResponse( const char* inputFileName, std::valarray<double> &linearProfile, double &lambda1, double &step) {
   FILE *InputHandle;      
   if ((InputHandle=fopen(inputFileName,"r") ) == NULL) {
      char message[1024];
      sprintf(message,"File not found : %s",inputFileName);
      throw std::exception(message);
   }

   // je lis le fichier d'entrée
   double wave;
   double intensity;
   ::std::list<double> waveList;
   ::std::list<double> intensityList;
   while (fscanf(InputHandle,"%lf %lf",&wave,&intensity)!=EOF) {
      waveList.push_back(wave);
      intensityList.push_back(intensity);
   }
   fclose(InputHandle);

   // je copie les intensite dans un tableau 
   linearProfile.resize(intensityList.size());
   long i= 0;
   for(::std::list<double>::iterator iter  = intensityList.begin() ; iter != intensityList.end(); ++iter ) {
      linearProfile[i++]= *(iter);
   }

   if ( intensityList.size() <2 ) {      
      char message[1024];
      sprintf(message,"lines number must be >= 2 in %s",inputFileName);
      throw std::exception(message);
   }

   // je recupere la premiere abcisse
   ::std::list<double>::iterator iter = waveList.begin();
   lambda1 = *(iter);
   // je calcule le pas  
   step = *(++iter) -  lambda1;
}
