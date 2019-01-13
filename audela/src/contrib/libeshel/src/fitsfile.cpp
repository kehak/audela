/* fitsfile.cpp
 *
 */
#ifdef _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#endif

#include <algorithm>    // pour std::max()
#include "libeshel.h"
#include <CCfits/CCfits>
#include "infoimage.h"
#include "order.h"
#include "linegap.h"
#include "fitsfile.h"

using namespace CCfits;

// ---------------------------------------------------------------------------
// Fits_openFits
//      ouvre un fichier FITS en lecture ou en écriture
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
FITS * Fits_openFits(char *fileName, bool write = false) {
   CCfits::FITS * pInfile; 

   try {  
      FITS::setVerboseMode(false);

      // j'ouvre le fichier en lecture
      if ( write == true) {
         pInfile = new CCfits::FITS(fileName,CCfits::Write,false);
      } else {
         pInfile = new CCfits::FITS(fileName,CCfits::Read,false);
      }
      return pInfile;
   }
   catch (CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"openFits %s : %s", fileName, e.message().c_str());
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_createFits 
//      cree un fichier FITS "fileName" et copie le PHDU du fichier source
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
CCfits::FITS * Fits_createFits(char *sourcefileName, char *fileName)  {
   CCfits::FITS * pInfile = NULL; 
   CCfits::FITS * pOutFits = NULL;

   try {        
      // j'ouvre le fichier en lecture
      pInfile = new CCfits::FITS(sourcefileName,CCfits::Read,false);
      // j'efface le fichier s'il existait deja
      remove(fileName);
      // create a new FITS object and corresponding file with copy of the primary header
      pOutFits = new CCfits::FITS(fileName,(const FITS&)*pInfile);
      Fits_closeFits(pInfile);
      pOutFits->flush();
      return pOutFits;
   }
   catch (CCfits::FitsException e) {
      Fits_closeFits(pInfile);
      Fits_closeFits(pOutFits);
      char message[1024];
      sprintf(message,"createFits %s : %s", fileName, e.message().c_str());
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_createFits 
//      cree un fichier FITS "fileName" et copie un profil 1D dans le PHDU
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
CCfits::FITS * Fits_createFits(char *fileName, std::valarray<double> &profile, double lambda1, double step)  {
   CCfits::FITS * pOutFits = NULL;

   try {        
      // j'efface le fichier s'il existait deja
      remove(fileName);
   }
   catch (CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"createFits remove %s : %s", fileName, e.message().c_str());
      throw std::exception(message);
   }

   try {  
      // create a new FITS object 
      long naxis = (long) profile.size();
      pOutFits = new CCfits::FITS(fileName, DOUBLE_IMG, 1, &naxis );
      PHDU& imageHDU = pOutFits->pHDU();
      long firstElement = 1;
      imageHDU.write(firstElement,profile.size(), profile);

      /*
      // sauvegarde en 32 bits
      pOutFits = new CCfits::FITS(fileName, FLOAT_IMG, 1, &naxis );
      PHDU& imageHDU = pOutFits->pHDU();
      long firstElement = 1;
      std::valarray<float> profileFloat(profile.size());
      for(size_t i= 0; i<profile.size(); i++) {
         profileFloat[i] = (float) profile[i];
      }
      imageHDU.write(firstElement,profileFloat.size(), profileFloat);
      */

      // j'enregistre les mots clefs de la calibration
      int crpix1 = 1;
      imageHDU.addKey("CRPIX1",(int) 1,""); 
      imageHDU.addKey("CRVAL1",lambda1,"[angstrom] angstrom"); 
      imageHDU.addKey("CDELT1",step,"[angstrom/pixel]"); 
      imageHDU.addKey("CTYPE1","Wavelength",""); 
      imageHDU.addKey("CUNIT1","angstrom","Wavelength unit"); 

      return pOutFits;
   }
   catch (CCfits::FitsException e) {
      Fits_closeFits(pOutFits);
      char message[1024];
      sprintf(message,"createFits %s naxis1=%d: %s ", fileName, profile.size(), e.message().c_str());
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_createFits 
//      cree un fichier FITS "fileName" et copie une image 2D dans le PHDU
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
CCfits::FITS * Fits_createFits(char *fileName, INFOIMAGE *pinfoImage)  {
   CCfits::FITS * pOutFits = NULL;

   std::valarray<PIC_TYPE> imageValue;

   try {        
      // j'efface le fichier s'il existait deja
      remove(fileName);
      // prepare naxis array
      long naxis[2];
      naxis[0] = (long) pinfoImage->imax;
      naxis[1] = (long) pinfoImage->jmax;
      // create a new FITS object 
      pOutFits = new CCfits::FITS(fileName, LONG_IMG, 2, naxis ); 
      // copy data to valarray
      std::valarray<PIC_TYPE> imageValue(pinfoImage->pic,pinfoImage->imax * pinfoImage->jmax);
      // copy image to Primary HDU
      PHDU& imageHDU = pOutFits->pHDU();
      long firstElement = 1;
      imageHDU.write(firstElement,imageValue.size(), imageValue);
      return pOutFits;
   }
   catch (CCfits::FitsException e) {
      Fits_closeFits(pOutFits);
      char message[1024];
      sprintf(message,"createFits %s : %s", fileName, e.message().c_str());
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_createFits 
//      cree un fichier FITS "fileName" et copie une image 2D dans le PHDU
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
CCfits::FITS * Fits_createFits(char *fileName, std::valarray<PIC_TYPE> &imageValue, int width, int height)  {
   CCfits::FITS * pOutFits = NULL;

   try {        
      // j'efface le fichier s'il existait deja
      remove(fileName);
      // prepare naxis array
      long naxis[2];
      naxis[0] = (long) width;
      //naxis[1] = (long) height;
      naxis[1] = (long) imageValue.size() / width;
      if ( width * height != imageValue.size() ) {
         char message[1024];
         sprintf(message,"Fits_createFits %s : size=%dx%d != %d", fileName, width, height, imageValue.size());
         throw std::exception(message);
      }
      // create a new FITS object 
      string stringFileName;
      stringFileName.assign(fileName);
      pOutFits = new CCfits::FITS(stringFileName, LONG_IMG, 2, naxis ); 
      pOutFits->flush();
      // copy image to Primary HDU
      PHDU& imageHDU = pOutFits->pHDU();
      long firstElement = 1;
      imageHDU.write(firstElement,imageValue.size(), imageValue);
      return pOutFits;
   }
   catch (CCfits::FitsException e) {
      Fits_closeFits(pOutFits);
      char message[1024];
      sprintf(message,"Fits_createFits %s : size=%dx%d  %s ", fileName, width, height, e.message().c_str());
      throw std::exception(message);
   }
}



// ---------------------------------------------------------------------------
// Fits_closeFits 
//    ferme le fichier FITS 
// 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_closeFits(FITS *pFits) {
   try { 
      if (pFits != NULL) {
         delete pFits;
      }
   } catch (CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"closeFits %s : %s", pFits->name().c_str(), e.message().c_str());
      throw std::exception(message);
   }

}

// ---------------------------------------------------------------------------
// Fits_setImage 
//   ajoute une image 2D dans le PHDU
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setImage(FITS *pFits, INFOIMAGE *pinfoImage)  {


   try {        
      std::vector<long> naxis(2);
      naxis[0] = (long) pinfoImage->imax;
      naxis[1] = (long) pinfoImage->jmax;
      ExtHDU * imageHDU = pFits->addImage("IMAGE",LONG_IMG,naxis);
      // copy data to valarray
      std::valarray<PIC_TYPE> imageValue(pinfoImage->pic,pinfoImage->imax * pinfoImage->jmax);
      long firstElement = 1;
      imageHDU->write(firstElement,imageValue.size(), imageValue);
   }
   catch (CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setImage %s : %s", pFits->name().c_str(), e.message().c_str());
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_setOrders 
//    ajoute la table des ordres et les parametres du spectro 
//    dans l'extension "ORDERS"
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setOrders (FITS *pFits, INFOSPECTRO *infoSpectro, PROCESS_INFO *processInfo, ORDRE *order,double dx_ref ) {

   string tableName("ORDERS");
   int nbOrder = infoSpectro->max_order - infoSpectro->min_order +1;
   std::vector<string> colName(25,"");
   std::vector<string> colForm(25,"");
   std::vector<string> colUnit(25,"");
   std::vector<string> colDisp(25,"");
   
   // titre des colonnes, format des colonnes, unites des colonnes, format d'affichage par defaut,  valeur des colonnes
   colName[0] = "order";
   colForm[0] = "1I";
   colUnit[0] = "";
   colDisp[0] = "I1.1";    // order
   std::vector<int>    num(nbOrder);

   colName[1] = "flag";
   colForm[1] = "1I";
   colUnit[1] = "";
   colDisp[1] = "I1.1";    // flag
   std::vector<int>    flag(nbOrder);
 
   colName[2] = "min_x";
   colForm[2] = "1I";
   colUnit[2] = "Pixel";
   colDisp[2] = "I1.1";    //min_x
    std::vector<int>    min_x(nbOrder);
  
   colName[3] = "max_x";
   colForm[3] = "1I";
   colUnit[3] = "Pixel";  
   colDisp[3] = "I1.1";    //man_x
   std::vector<int>    max_x(nbOrder);

   colName[4] = "P0";
   colForm[4] = "1D";
   colUnit[4] = "";  
   colDisp[4] = "E14.6E3"; //P0
   std::vector<double> P0(nbOrder);
   
   colName[5] = "P1";
   colForm[5] = "1D";
   colUnit[5] = "";  
   colDisp[5] = "E14.6E3"; //P1
   std::vector<double> P1(nbOrder);
   
   colName[6] = "P2";
   colForm[6] = "1D";
   colUnit[6] = "";
   colDisp[6] = "E14.6E3"; //P2
   std::vector<double> P2(nbOrder);

   colName[7] = "P3";
   colForm[7] = "1D";
   colUnit[7] = "";  
   colDisp[7] = "E14.6E3"; //P3
   std::vector<double> P3(nbOrder);

   colName[8] = "P4";
   colForm[8] = "1D";
   colUnit[8] = "";  
   colDisp[8] = "E14.6E3"; //P4
   std::vector<double> P4(nbOrder);

   colName[9] = "P5";
   colForm[9] = "1D";
   colUnit[9] = ""; 
   colDisp[9] = "E14.6E3"; //P5
   std::vector<double> P5(nbOrder);
   
   colName[10] = "yc";
   colForm[10] = "1D";
   colUnit[10] = "Pixel";  
   colDisp[10] = "F1.2";    //yc
   std::vector<double> yc(nbOrder);

   colName[11] = "wide_y";
   colForm[11] = "1I";
   colUnit[11] = "";  
   colDisp[11] = "I7.1";   //wide_y
    std::vector<int>    wide_y(nbOrder);
  
   colName[12] = "wide_x";
   colForm[12] = "1I";
   colUnit[12] = "";   
   colDisp[12] = "I7.1";   //wide_x
   std::vector<int>    wide_x(nbOrder);

   colName[13] = "slant";
   colForm[13] = "1D";
   colUnit[13] = "Degree";
   colDisp[13] = "F7.2";   //slant
   std::vector<double> slant(nbOrder);

   colName[14] = "rms_order";
   colForm[14] = "1D";
   colUnit[14] = "";
   colDisp[14] = "F1.4";   //rms_order
   std::vector<double> rms_order(nbOrder);

   colName[15] = "central";
   colForm[15] = "1D";
   colUnit[15] = "Angstrom";
   colDisp[15] = "F1.3";   //central
   std::vector<double> central(nbOrder);

   colName[16] = "A0";
   colForm[16] = "1D";
   colUnit[16] = "";
   colDisp[16] = "E14.6E3";  //A0
   std::vector<double> A0(nbOrder);

   colName[17] = "A1";
   colForm[17] = "1D";
   colUnit[17] = "";
   colDisp[17] = "E14.6E3";  //A1   
   std::vector<double> A1(nbOrder);

   colName[18] = "A2";
   colForm[18] = "1D";
   colUnit[18] = "";
   colDisp[18] = "E14.6E3";  //A2
   std::vector<double> A2(nbOrder);

   colName[19] = "A3";
   colForm[19] = "1D";
   colUnit[19] = "";
   colDisp[19] = "E14.6E3";  //A3
   std::vector<double> A3(nbOrder);

   colName[20] = "rms_cal";
   colForm[20] = "1D";
   colUnit[20] = "";
   colDisp[20] = "F7.4";   //rms_cal
   std::vector<double> rms_cal(nbOrder);

   colName[21] = "fwhm";
   colForm[21] = "1D";
   colUnit[21] = "Pixel";
   colDisp[21] = "F7.2";   //fwhm
   std::vector<double> fwhm(nbOrder);

   colName[22] = "disp";
   colForm[22] = "1D";
   colUnit[22] = "";
   colDisp[22] = "F7.3";   //disp
   std::vector<double> disp(nbOrder);

   colName[23] = "resolution";
   colForm[23] = "1D";
   colUnit[23] = "";
   colDisp[23] = "F7.1";   //resolution
   std::vector<double> resolution(nbOrder);

   colName[24] = "nb_lines";
   colForm[24] = "1I";
   colUnit[24] = "lines";
   colDisp[24] = "I4.1";   //nb_lines
   std::vector<int>    nb_lines(nbOrder);


   // je copie les valeurs dans les vecteurs
   int nbRow = 0; 
   for (short j = infoSpectro->min_order; j <= infoSpectro->max_order; j++) {
      num[nbRow] = j;
      flag[nbRow] = order[j].flag;
      min_x[nbRow] = order[j].min_x;
      max_x[nbRow] = order[j].max_x;
      P0[nbRow] = order[j].poly_order[0];
      P1[nbRow] = order[j].poly_order[1];
      P2[nbRow] = order[j].poly_order[2];
      P3[nbRow] = order[j].poly_order[3];
      P4[nbRow] = order[j].poly_order[4];
      P5[nbRow] = order[j].poly_order[5];
      yc[nbRow] = order[j].yc;
      wide_y[nbRow] = order[j].wide_y;
      wide_x[nbRow] = order[j].wide_x;
      slant[nbRow] = order[j].slant;
      rms_order[nbRow] = order[j].rms_order;
      central[nbRow] = order[j].central_lambda;
      A0[nbRow] = order[j].a0;
      A1[nbRow] = order[j].a1;
      A2[nbRow] = order[j].a2;
      A3[nbRow] = order[j].a3;
      rms_cal[nbRow] = order[j].rms_calib_spec;
      fwhm[nbRow] = order[j].fwhm;
      disp[nbRow] = order[j].disp;
      resolution[nbRow] = order[j].resolution;
      nb_lines[nbRow] = order[j].nb_lines;
      nbRow++;
   }

   try {
      ExtHDU *orderTable = NULL;
      try {
         orderTable = &(pFits->extension("ORDERS"));
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         // je cree la table si elle n'existait pas
         orderTable = pFits->addTable(tableName,nbRow,colName,colForm,colUnit);
         // j'ajoute les mots clefs decrivant l'affichage par defaut de chaque colonne de la table
         for(size_t c=0; c<colDisp.size(); c++ ) {
            char keyName[10];
            sprintf(keyName,"TDISP%d",c+1);
            orderTable->addKey(keyName,colDisp[c],"default display format"); 
         }
      }
  
      // j'ajoute les valeurs des colonnes
      orderTable->column(colName[0]).write(num,1);
      orderTable->column(colName[1]).write(flag,1);
      orderTable->column(colName[2]).write(min_x,1);
      orderTable->column(colName[3]).write(max_x,1);    
      orderTable->column(colName[4]).write(P0,1);    
      orderTable->column(colName[5]).write(P1,1);    
      orderTable->column(colName[6]).write(P2,1);    
      orderTable->column(colName[7]).write(P3,1);    
      orderTable->column(colName[8]).write(P4,1);  
      orderTable->column(colName[9]).write(P5,1); 
      orderTable->column(colName[10]).write(yc,1);    
      orderTable->column(colName[11]).write(wide_y,1);    
      orderTable->column(colName[12]).write(wide_x,1);    
      orderTable->column(colName[13]).write(slant,1); 
      orderTable->column(colName[14]).write(rms_order,1); 
      orderTable->column(colName[15]).write(central,1); 
      orderTable->column(colName[16]).write(A0,1); 
      orderTable->column(colName[17]).write(A1,1); 
      orderTable->column(colName[18]).write(A2,1); 
      orderTable->column(colName[19]).write(A3,1); 
      orderTable->column(colName[20]).write(rms_cal,1); 
      orderTable->column(colName[21]).write(fwhm,1); 
      orderTable->column(colName[22]).write(disp,1); 
      orderTable->column(colName[23]).write(resolution,1); 
      orderTable->column(colName[24]).write(nb_lines,1); 

      // j'ajoute les parametre du specrographe dans le header
      orderTable->addKey("WIDTH",infoSpectro->imax,"image width"); 
      orderTable->addKey("HEIGHT",infoSpectro->jmax,"image height"); 
      orderTable->addKey("MIN_ORDER",infoSpectro->min_order,"min order"); 
      orderTable->addKey("MAX_ORDER",infoSpectro->max_order,"max order"); 
      orderTable->addKey("ALPHA",infoSpectro->alpha,"alpha angle"); 
      orderTable->addKey("BETA",infoSpectro->beta,"beta angle"); 
      orderTable->addKey("GAMMA",infoSpectro->gamma,"gamma angle"); 
      orderTable->addKey("FOCLEN",infoSpectro->focale,"focale length"); 
      orderTable->addKey("M",infoSpectro->m,"grad"); 
      orderTable->addKey("PIXEL",infoSpectro->pixel,"pixel");       
      orderTable->addKey("DX_REF",dx_ref,"pixel");     

      for ( unsigned int i = 0 ; i < infoSpectro->distorsion.size() ; i++) {
         char keyName[9];
         sprintf(keyName, "DIST_P%d",i);
         orderTable->addKey(keyName,infoSpectro->distorsion[i],"pixel");  
      }

      // j'ajoute les parametre du traitement dans le header
      orderTable->addKey("REF_NUM",   processInfo->referenceOrderNum,"reference order num"); 
      orderTable->addKey("REF_X",     processInfo->referenceOrderX,"reference order x"); 
      orderTable->addKey("REF_Y",     processInfo->referenceOrderY,"reference order y"); 
      orderTable->addKey("REF_L",     processInfo->referenceOrderLambda,"reference order lambda"); 
      orderTable->addKey("THRESHOL",  processInfo->detectionThreshold,"dectection threshold"); 
      orderTable->addKey("CALIB_ITER",processInfo->calibrationIteration,"calibration iteration");       

      orderTable->addKey("HDUVERS",3,"ORDER HDU version"); 
      // je force l'ecriture sur le disque immediatement
      pFits->flush();
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"setOrders %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_getInfoSpectro 
//    retourne les parametres du spectro
//    l'extension s'appelle "ORDERS" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getInfoSpectro (FITS *pFits, INFOSPECTRO *infoSpectro) {
   std::vector<string> hdus(1);
   //hdus[0] = "ORDERS";
   string hduName = "ORDERS";
   try {  
      // je lis le numero du premier ordre disponible
      //ExtHDU& hduOrders = pFits->extension(hdus[0]);
      pFits->read(hduName,true);
      // je recupere les valeurs
      ExtHDU& hduOrders = pFits->extension(hduName);
      int value;

      hduOrders.readKey("WIDTH", value); infoSpectro->imax = value;      
      hduOrders.readKey("HEIGHT", value); infoSpectro->jmax= value;
      hduOrders.readKey("MIN_ORDER", value); infoSpectro->min_order= value;
      hduOrders.readKey("MAX_ORDER", value); infoSpectro->max_order= value;
      hduOrders.readKey("ALPHA", infoSpectro->alpha); //infoSpectro->alpha= value;
      try {
         hduOrders.readKey("BETA", infoSpectro->beta); //infoSpectro->beta= value;
      } catch ( CCfits::FitsException e) {
         // BETA est facultatif
         infoSpectro->beta = 0;
      }
      hduOrders.readKey("GAMMA", infoSpectro->gamma); //infoSpectro->gamma= value;
      hduOrders.readKey("FOCLEN", infoSpectro->focale); //infoSpectro->focale= value;
      hduOrders.readKey("M", infoSpectro->m); //infoSpectro->m= value;
      hduOrders.readKey("PIXEL", infoSpectro->pixel); //infoSpectro->pixel= value;
      // je recherche les coefficents du polynome de coorection de la distorsion
      ::std::list<double> coeffList; 
      try {
         unsigned int i = 0;
         do {
            char keyName[9];
            double coefficient;
            sprintf(keyName, "DIST_P%d",i);
            hduOrders.readKey(keyName,coefficient);
            coeffList.push_back(coefficient);
            i++;
         } while ( true );

      } catch ( HDU::NoSuchKeyword e) {
         // rien à  faire , on a atteint la fin de la liste des coefficients
      } catch ( FitsError e) {
         // rien à  faire , on a atteint la fin de la liste des coefficients
      }

      // je copie les coefficents dans infoSpectro->distorsio
      int i = 0;
      infoSpectro->distorsion.resize(coeffList.size());
      for(::std::list<double>::iterator iter  = coeffList.begin() ; iter != coeffList.end(); ++iter ) {
         infoSpectro->distorsion[i++] = *iter;
      }

   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"getInfoSpectro %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_getProcessInfo 
//    retourne les parametres du traitement
//    qui sont dans les mots clef du HDU "ORDERS" 
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getProcessInfo (FITS *pFits, PROCESS_INFO *processInfo) {
   std::vector<string> hdus(1);
   string hduName = "ORDERS";
   try {  
      // je lis le numero du premier ordre disponible
      pFits->read(hduName,true);
      // je recupere les valeurs
      ExtHDU& hduOrders = pFits->extension(hduName);
      int value;

      try {
         hduOrders.readKey("HDUVERS", processInfo->version);
      } catch ( CCfits::FitsException e) {
         // HDUVERS = 1.0 par defaut
         processInfo->version = 1.0;
      }
      hduOrders.readKey("REF_NUM",  value); processInfo->referenceOrderNum = value;      
      hduOrders.readKey("REF_X",    value); processInfo->referenceOrderX= value;
      hduOrders.readKey("REF_Y",    value); processInfo->referenceOrderY= value;
      hduOrders.readKey("REF_L",    processInfo->referenceOrderLambda); 
      hduOrders.readKey("THRESHOL", value); processInfo->detectionThreshold= value;
      hduOrders.readKey("CALIB_ITER", value); processInfo->calibrationIteration= value;
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_getProcessInfo %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_getOrders 
//    retourne les valeurs d'un profil a partir de l'extension "ORDERS" du fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getOrders(CCfits::PFitsFile pFits, ORDRE *orderValue,double *dx_ref )  {
   string hduName =  "ORDERS";
   double hduVersion = 1;
   try {  
      // je charge la table des ordres
      pFits->read(hduName,true);
      // je recupere les valeurs
      ExtHDU& hduOrders = pFits->extension(hduName);

      try {
         hduOrders.readKey("HDUVERS", hduVersion);
      } catch ( CCfits::FitsException e) {
         // HDUVERS = 1.0 par defaut
         hduVersion = 1.0;
      }

      // valeur des colonnes
      short nbOrder = hduOrders.rows();
      std::vector<int>    num(nbOrder);
      std::vector<int>    flag(nbOrder);
      std::vector<int>    min_x(nbOrder);
      std::vector<int>    max_x(nbOrder);
      std::vector<double> P0(nbOrder);
      std::vector<double> P1(nbOrder);
      std::vector<double> P2(nbOrder);
      std::vector<double> P3(nbOrder);
      std::vector<double> P4(nbOrder);
      std::vector<double> P5(nbOrder);
      std::vector<double> yc(nbOrder);
      std::vector<int>    wide_y(nbOrder);
      std::vector<int>    wide_x(nbOrder);
      std::vector<double> slant(nbOrder);
      std::vector<double> rms_order(nbOrder);
      std::vector<double> central(nbOrder);
      std::vector<double> A0(nbOrder);
      std::vector<double> A1(nbOrder);
      std::vector<double> A2(nbOrder);
      std::vector<double> A3(nbOrder);
      std::vector<double> rms_cal(nbOrder);
      std::vector<double> fwhm(nbOrder);
      std::vector<double> disp(nbOrder);
      std::vector<double> resolution(nbOrder);
      std::vector<int>    nb_lines(nbOrder);

      // je lis les colonnes
      hduOrders.column("order").read(num, 1, nbOrder);
      hduOrders.column("flag").read(flag, 1, nbOrder);
      hduOrders.column("min_x").read(min_x, 1, nbOrder);
      hduOrders.column("max_x").read(max_x, 1, nbOrder);
      hduOrders.column("P0").read(P0, 1, nbOrder);
      hduOrders.column("P1").read(P1, 1, nbOrder);
      hduOrders.column("P2").read(P2, 1, nbOrder);
      hduOrders.column("P3").read(P3, 1, nbOrder);
      hduOrders.column("P4").read(P4, 1, nbOrder);
      if ( hduVersion >= 2 ) {
         hduOrders.column("P5").read(P5, 1, nbOrder);
      } else {
         // le vecteur est deja initialisé avec des valeurs nulles
      }         
      hduOrders.column("yc").read(yc, 1, nbOrder);
      hduOrders.column("wide_y").read(wide_y, 1, nbOrder);
      hduOrders.column("wide_x").read(wide_x, 1, nbOrder);
      hduOrders.column("slant").read(slant, 1, nbOrder);
      hduOrders.column("rms_order").read(rms_order, 1, nbOrder);
      hduOrders.column("central").read(central, 1, nbOrder);
      hduOrders.column("A0").read(A0, 1, nbOrder);
      hduOrders.column("A1").read(A1, 1, nbOrder);
      hduOrders.column("A2").read(A2, 1, nbOrder);
      hduOrders.column("A3").read(A3, 1, nbOrder);

      hduOrders.column("rms_cal").read(rms_cal, 1, nbOrder);
      hduOrders.column("fwhm").read(fwhm, 1, nbOrder);
      hduOrders.column("disp").read(disp, 1, nbOrder);
      hduOrders.column("resolution").read(resolution, 1, nbOrder);
      hduOrders.column("nb_lines").read(nb_lines, 1, nbOrder);

      // je copie les valeurs dans la structure ORDRE
      for (short n=0; n<nbOrder; n++) {
         int numOrder = num[n];
         orderValue[numOrder].flag = flag[n];
         orderValue[numOrder].min_x = min_x[n];
         orderValue[numOrder].max_x = max_x[n];
         orderValue[numOrder].poly_order[0] = P0[n];
         orderValue[numOrder].poly_order[1] = P1[n];
         orderValue[numOrder].poly_order[2] = P2[n];
         orderValue[numOrder].poly_order[3] = P3[n];
         orderValue[numOrder].poly_order[4] = P4[n];
         orderValue[numOrder].poly_order[5] = P5[n];
         orderValue[numOrder].yc = yc[n];
         orderValue[numOrder].wide_y = wide_y[n];
         orderValue[numOrder].wide_x = wide_x[n];
         orderValue[numOrder].slant = slant[n];
         orderValue[numOrder].rms_order = rms_order[n];
         orderValue[numOrder].central_lambda = central[n];
         orderValue[numOrder].a0 = A0[n];
         orderValue[numOrder].a1 = A1[n];
         orderValue[numOrder].a2 = A2[n];
         orderValue[numOrder].a3 = A3[n];
         orderValue[numOrder].rms_calib_spec = rms_cal[n];
         orderValue[numOrder].fwhm = fwhm[n];
         orderValue[numOrder].disp = disp[n];
         orderValue[numOrder].resolution = resolution[n];
         orderValue[numOrder].nb_lines = nb_lines[n];
      }
      
      // je lis le motclefs DX_FREF
       hduOrders.readKey("DX_REF", *dx_ref); 

   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"getOrders %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_setLineGap 
//    ajoute la table des ecarts O-C dans l'extension "LINEGAP" d'un fichier FITS
//    
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setLineGap (FITS *pFits, ::std::list<LINE_GAP> &lineGapList ) {

   // j'initalise les mots clefs avec des chaines vides
   std::vector<string> colName(7,"");
   std::vector<string> colForm(7,"");
   std::vector<string> colUnit(7,"");
   std::vector<string> colDisp(7,"");

   int nbRow = lineGapList.size(); 

   // titre des colonnes
   colName[0] = "order";
   colName[1] = "lambda_obs";
   colName[2] = "lambda_calc";
   colName[3] = "lambda_diff";
   colName[4] = "lambda_posx";
   colName[5] = "lambda_posy";
   colName[6] = "valid";

   // format des colonnes
   colForm[0] = "1I";
   colForm[1] = "1D";
   colForm[2] = "1D";
   colForm[3] = "1D";
   colForm[4] = "1D";
   colForm[5] = "1D";
   colForm[6] = "1I";

   // unites des colonnes
   colUnit[0] = "";
   colUnit[1] = "Angstrom";
   colUnit[2] = "Angstrom";  
   colUnit[3] = "Angstrom";  
   colUnit[4] = "Pixels";  
   colUnit[5] = "Pixels";  
   colUnit[6] = "Boolean";  

   // format d'affichage par defaut
   colDisp[0] = "I1.2";   // format Iw.m  avec w=largeur max , m=largeur min
   colDisp[1] = "F1.3";   // format Fl.d  avec l=nombre de caracteres total, d=nombre de decimales
   colDisp[2] = "F1.3";    
   colDisp[3] = "F1.4"; 
   colDisp[4] = "F1.2"; 
   colDisp[5] = "F1.2"; 
   colDisp[6] = "I1.1"; 

   // valeur des colonnes
   std::vector<int>    num(nbRow);
   std::vector<double> l_obs(nbRow);
   std::vector<double> l_calc(nbRow);
   std::vector<double> l_diff(nbRow);
   std::vector<double> l_posx(nbRow);
   std::vector<double> l_posy(nbRow);
   std::vector<int>  valid(nbRow);
   
   int i = 0;
   for(::std::list<LINE_GAP>::iterator iter  = lineGapList.begin() ; iter != lineGapList.end(); ++iter ) {
      num[i]    = iter->order;
      l_obs[i]  = iter->l_obs;
      l_calc[i] = iter->l_calc;
      l_diff[i] = iter->l_diff;
      l_posx[i] = iter->l_posx;
      l_posy[i] = iter->l_posy;
      valid[i]  = iter->valid;
      i++;
   }

   try {
      ExtHDU *orderTable = NULL;
      string tableName("LINEGAP");
      try {
         orderTable = &(pFits->extension(tableName));
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         // je cree la table si elle n'existait pas
         orderTable = pFits->addTable(tableName,nbRow,colName,colForm,colUnit);
         // j'ajoute les mots clefs TDISPc decrivant l'affichage par defaut (car ces mots clefs ne sont pas ajoutes par pFits->addTable
         for(size_t c=0; c<colDisp.size(); c++ ) {
            char keyName[10];
            sprintf(keyName,"TDISP%d",c+1);
            orderTable->addKey(keyName,colDisp[c],"default display format"); 
         }
      }
  
      // j'ajoute les valeurs des colonnes
      if ( nbRow > 0 ) {
         orderTable->column(colName[0]).write(num,1);
         orderTable->column(colName[1]).write(l_obs,1);
         orderTable->column(colName[2]).write(l_calc,1);    
         orderTable->column(colName[3]).write(l_diff,1);    
         orderTable->column(colName[4]).write(l_posx,1);    
         orderTable->column(colName[5]).write(l_posy,1);    
         orderTable->column(colName[6]).write(valid,1);    
      }

   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"setOrderGap %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_getLineGap 
//    retourne les valeurs de la table des ecarts
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getLineGap(CCfits::PFitsFile pFits, ::std::list<LINE_GAP> &lineGapListe )  {
   std::vector<string> hdus(1);
   hdus[0] = "LINEGAP";
   try {  
      // je lis le numero du premier ordre disponible
      ExtHDU& hduOrders = pFits->extension(hdus[0]);
      // valeur des colonnes
      short nbRow = hduOrders.rows();
      std::vector<int>    order(nbRow);
      std::vector<double> l_obs(nbRow);
      std::vector<double> l_calc(nbRow);
      std::vector<double> l_diff(nbRow);
      std::vector<double> l_posx(nbRow);
      std::vector<double> l_posy(nbRow);
      std::vector<int>  valid(nbRow);
      
      // je lis les colonnes
      if ( nbRow > 0 ) {
         hduOrders.column("order").read(order, 1, nbRow);
         hduOrders.column("lambda_obs").read(l_obs, 1, nbRow);
         hduOrders.column("lambda_calc").read(l_calc, 1, nbRow);
         hduOrders.column("lambda_diff").read(l_diff, 1, nbRow);
         hduOrders.column("lambda_posx").read(l_posx, 1, nbRow);
         hduOrders.column("lambda_posy").read(l_posy, 1, nbRow);
         hduOrders.column("valid").read(valid, 1, nbRow);
      }
      // je copie les valeurs dans la structure LINE_GAP
      lineGapListe.clear();
      for (int n=0; n<nbRow; n++) {
         LINE_GAP lineGap;
         lineGap.order = order[n];
         lineGap.l_obs = l_obs[n];
         lineGap.l_calc = l_calc[n];
         lineGap.l_diff = l_diff[n];
         lineGap.l_posx = l_posx[n];
         lineGap.l_posy = l_posy[n];
         lineGap.valid = valid[n];
         lineGapListe.push_back(lineGap);
      }
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"getLineGap %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_setRawProfile 
//    ajoute une image contenant le profil dans le fichier FITS.
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setRawProfile(FITS * pFits, const char * prefix, int numOrder, ::std::valarray<double> &rawProfile, int min_x) {
   try {
      char hduName[256];
      sprintf(hduName,"%s%02d",prefix, numOrder);
      ExtHDU *imageHDU = NULL;
      try {
         imageHDU = &(pFits->extension(hduName));
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         std::vector<long> naxis(1);
         naxis[0] = (long) rawProfile.size();
         // je cree l'image si elle n'existait pas
         imageHDU = pFits->addImage(hduName,DOUBLE_IMG,naxis);
      }
      // j'enregistre l'image
      long  firstElement = 1;
      imageHDU->write(firstElement, rawProfile.size(), rawProfile);
      // j'enregistre les mots clefs de la calibration
      int crpix1 = 1;
      imageHDU->addKey("CRPIX1",(int) 1,""); 
      imageHDU->addKey("CRVAL1", min_x,"[pixel] abscisse origin"); 
      imageHDU->addKey("CDELT1",(int) 1,"[pixel]"); 
      imageHDU->addKey("CTYPE1","Wavelength",""); 
      imageHDU->addKey("CUNIT1","pixel","abscisse unit"); 
      // je force l'ecriture sur le disque immediatement
      pFits->flush();
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setRawProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_getRawProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// @param rawProfile  liste des valeurs
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getRawProfile(CCfits::PFitsFile pFits, const char * prefix, int numOrder, ::std::valarray<double> &rawProfile, int &min_x)  {
   try {  
      char hduName[256];
      sprintf(hduName,"%s%02d", prefix, numOrder);
      pFits->read(hduName,true);
      ExtHDU& imageHDU = pFits->extension(hduName);

      imageHDU.readKey("CRVAL1", min_x);
      // la taille de rawProfile est modifiee par imageHDU.read
      imageHDU.read(rawProfile);
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_getRawProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_setLinearProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setLinearProfile(CCfits::PFitsFile pFits, const char * prefix, int numOrder, ::std::valarray<double> &linearProfile, double lambda1, double step) 
{
   try {
      char hduName[256];
      sprintf(hduName,"%s%02d", prefix, numOrder);
      ExtHDU *imageHDU = NULL;
      try {
         imageHDU = &(pFits->extension(hduName));
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         std::vector<long> naxis(1);
         naxis[0] = (long) linearProfile.size();
         // je cree l'image si elle n'existait pas
         imageHDU = pFits->addImage(hduName,DOUBLE_IMG,naxis);
      }

       try {
      // j'enregistre l'image
      long  firstElement = 1;
      imageHDU->write(firstElement, linearProfile.size(), linearProfile);

      } catch ( CCfits::FitsException e) {
         char message[1024];
         sprintf(message,"Fits_setLinearProfile linearProfile : size=%d", linearProfile.size() );      
         throw std::exception(message);
      }

      // j'enregistre les mots clefs de la calibration
      int crpix1 = 1;
      imageHDU->addKey("CRPIX1","1","Reference pixel for the minimum wavelength"); 
      try {
         imageHDU->addKey("CRVAL1",lambda1,"[Angstrom] Minimum wavelength"); 
      } catch ( CCfits::FitsException e) {
         char message[1024];
         sprintf(message,"Fits_setLinearProfile %s : %s CRVAL1=%f", pFits->name().c_str(), e.message().c_str(),lambda1);      
         throw std::exception(message);
      }
      try {
         imageHDU->addKey("CDELT1",step,"[Angstrom/pixel] Dispersion"); 
      } catch ( CCfits::FitsException e) {
         char message[1024];
         sprintf(message,"Fits_setLinearProfile %s : %s CDELT1=%f", pFits->name().c_str(), e.message().c_str(),step);      
         throw std::exception(message);
      }

      imageHDU->addKey("CTYPE1","wavelength","Data type"); 
      imageHDU->addKey("CUNIT1","Angstrom","Wavelength unit"); 
      // je force l'ecriture sur le disque immediatement
      pFits->flush();
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}



// ---------------------------------------------------------------------------
// Fits_getLinearProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getLinearProfile(CCfits::PFitsFile pFits, const char * prefix, int numOrder, ::std::valarray<double> &linearProfile, double *lambda1, double *step) 
{
   try {  
      char hduName[256];
      sprintf(hduName,"%s%02d", prefix, numOrder);
      pFits->read(hduName,true);
      ExtHDU& imageHDU = pFits->extension(hduName);

      imageHDU.readKey("CRVAL1", *lambda1);
      imageHDU.readKey("CDELT1", *step);
      imageHDU.read(linearProfile);
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_getLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_getLinearProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getLinearProfile(CCfits::PFitsFile pFits, const char * hduName, ::std::valarray<double> &linearProfile, double *lambda1, double *step) 
{
   try {  
      if ( strcmp(hduName,"PRIMARY") ==0 ) {
         pFits->pHDU().read(linearProfile);
         pFits->pHDU().readKey("CRVAL1", *lambda1);
         pFits->pHDU().readKey("CDELT1", *step);
      } else {
         pFits->read(hduName,true);
         ExtHDU& imageHDU = pFits->extension(hduName);
         imageHDU.readKey("CRVAL1", *lambda1);
         imageHDU.readKey("CDELT1", *step);
         imageHDU.read(linearProfile);
      }  
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_getLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_getFullProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getFullProfile(CCfits::PFitsFile pFits, ::std::valarray<double> &linearProfile, double *lambda1, double *step) 
{
   try {  
      // je lis l'image du premier header
      pFits->pHDU().read(linearProfile);
      pFits->pHDU().readKey("CRVAL1", *lambda1);
      pFits->pHDU().readKey("CDELT1", *step);
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_getFullProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_setFullProfile 
//    ajoute un profil (image 1D) dans une extension d'un fichier FITS
//  
// Paramerters 
//    pFits    : pointeur de la structure CCfits du fichier FITS ( voir Fits_openFile())
//    hduName  :  nom de l'extension 
//    linearprofile : ordonnées du profil (
//    lambda1  :  abcisse de la première valeur (en angstrom)
//    step     :  dispersion (angstrom/pixel)
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setFullProfile(CCfits::PFitsFile pFits, const char * hduName, ::std::valarray<double> &linearProfile, double lambda1, double step) 
{
   try {  
      try {
         ExtHDU& imageHDU = pFits->extension(hduName);
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         std::vector<long> naxis(1);
         naxis[0] = (long) linearProfile.size();
         // je cree l'image si elle n'existait pas
         pFits->addImage(hduName,DOUBLE_IMG,naxis);
      }
      ExtHDU& imageHDU = pFits->extension(hduName);

      // j'enregistre l'image
      long  firstElement = 1;
      imageHDU.write(firstElement, linearProfile.size(), linearProfile);
      // j'enregistre les mots clefs de la calibration
      int crpix1 = 1;
      imageHDU.addKey("CRPIX1",(int) 1,"Reference pixel for the minimum wavelength"); 
      imageHDU.addKey("CRVAL1",lambda1,"[Angstrom] Minimum wavelength"); 
      imageHDU.addKey("CDELT1",step,"[Angstrom/pixel] Dispersion"); 
      imageHDU.addKey("CTYPE1","wavelength","Data type"); 
      imageHDU.addKey("CUNIT1","Angstrom","Wavelength unit"); 
      
/*      
      HDU * imageHDU = NULL; 
      long  firstElement = 1;
      long naxis1 = linearProfile.size();
      fitsfile *fptr = pFits->fitsPointer();
      int status ;


      // j'enregistre le profil dans le PHU
      pFits->resetPosition();
      //fits_movabs_hdu(fptr , 1, &exttype, &status); 
      fits_resize_img(fptr, DOUBLE_IMG, 1, &naxis1, &status);
      double *data = new double[naxis1];
      for(long i=0; i<naxis1; ++i) {data[i] = linearProfile[i]; }
      fits_write_img(fptr, TDOUBLE, firstElement, naxis1, data, &status);
      delete [] data;
         
      // j'enregistre les mots clefs de la calibration
      imageHDU = &(pFits->pHDU());
      imageHDU->addKey("CRPIX1",(int) 1,"Reference pixel for the minimum wavelength"); 
      imageHDU->addKey("CRVAL1",lambda1,"[Angstrom] Minimum wavelength"); 
      imageHDU->addKey("CDELT1",step,"[Angstrom/pixel] Dispersion"); 
      imageHDU->addKey("CTYPE1","wavelength","Data type"); 
      imageHDU->addKey("CUNIT1","Angstrom","Wavelength unit"); 
      imageHDU->addKey("NAXIS1",naxis1,""); 
*/      
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setFullLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_getFullProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getFullProfile(CCfits::PFitsFile pFits, const char * hduName, ::std::valarray<double> &linearProfile, double *lambda1, double *step) 
{
   try {
      
      if ( hduName == NULL || strcmp(hduName,"")==0 || strcmp(hduName,"PRIMARY")==0) {
         // je lis l'image du premier header
         pFits->pHDU().read(linearProfile);
         pFits->pHDU().readKey("CRVAL1", *lambda1);
         pFits->pHDU().readKey("CDELT1", *step);
      } else {
         pFits->read(hduName,true);
         ExtHDU& imageHDU = pFits->extension(hduName);
         imageHDU.read(linearProfile);
         imageHDU.readKey("CRVAL1", *lambda1);
         imageHDU.readKey("CDELT1", *step);
      }

   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_getFullLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_setStraightLineImage
//    ajoute une image 2D contenant les raies redressées dans un nouveau HDU
//  
// Paramerters 
//    pFits    : pointeur de la structure CCfits du fichier FITS ( voir Fits_openFile())
//    numOrder : numero de l'ordre
//    width    : nombre de colonnes
//    height   : nombre de lignes
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setStraightLineImage(FITS * pFits, int numOrder, ::std::valarray<int> &rawProfile, int width, int height) {
   try {
      char hduName[256];
      sprintf(hduName,"STRAIGHT_%02d",numOrder);
      ExtHDU *imageHDU = NULL;
      try {
         // je reccupere le HDU s'il existe dejà
         imageHDU = &(pFits->extension(hduName));
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         std::vector<long> naxis(2);
         naxis[0] = (long) width;
         naxis[1] = (long) height;
         // je cree l'image 2D si elle n'existait pas
         imageHDU = pFits->addImage(hduName,LONG_IMG,naxis);
      }
      // j'enregistre l'image
      long  firstElement = 1;
      imageHDU->write(firstElement, rawProfile.size(), rawProfile);
      // je force l'ecriture sur le disque immediatement
      pFits->flush();
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setStraightLineImage %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_getImage
//      retourne l'image du premier header
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_getImage(FITS *pFits, INFOIMAGE **pinfoImage ) {
   std::valarray<PIC_TYPE> imageValue;

   try {  
      // je lis l'image du premier header
      pFits->pHDU().read(imageValue);
      //imageValue /= 2;  //===========  Attention, ajout pour SBIG (non signé)

      // je caste "imageValue"  en un tableau de PIC_TYPE
      //CCfits::FITSUtil::CAarray<PIC_TYPE> convert;

      // je cree une structure INFOIMAGE
      //*pinfoImage = createImage( convert(imageValue), (int) pFits->pHDU().axis(0),(int) pFits->pHDU().axis(1));
      *pinfoImage = createImage((int) pFits->pHDU().axis(0),(int) pFits->pHDU().axis(1));
      if ( *pinfoImage == NULL ) {
         throw std::exception("cant'create infoImage");
	   }
      size_t size = imageValue.size();
      for(size_t i=0; i<size; ++i) { (*pinfoImage)->pic[i] = imageValue[i];}

   }
   catch (CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"read_fits %s : %s",  pFits->name().c_str(), e.message().c_str());
      throw std::exception(message);
   }
}

void Fits_setKeyword(FITS *pFits, const char * hduName, const char* name, char *stringValue, char *comment) {
   try {
      
      if ( hduName == NULL || strcmp(hduName,"")==0 || strcmp(hduName,"PRIMARY")==0) {
         // j'ajoute le mot clef dans le premier header
         //pFits->pHDU().addKey(name,stringValue,comment); 
         pFits->pHDU().addKey(name,::std::string(stringValue),comment); 
      } else {
         // j'ajoute le mot clef dans le header
         pFits->read(hduName,true);
         ExtHDU& extHDU = pFits->extension(hduName);
         extHDU.addKey(name,stringValue,comment); 
      }

   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setKeyword %s : %s keyword=%s", pFits->name().c_str(), e.message().c_str(),name);      
      throw std::exception(message);
   }
}

void Fits_getKeyword(FITS *pFits, const char * hduName, const char* name, ::std::string &value) {
   try {
      
      if ( hduName == NULL || strcmp(hduName,"")==0 || strcmp(hduName,"PRIMARY")==0) {
         // j'ajoute le mot clef dans le premier header
         //pFits->pHDU().addKey(name,stringValue,comment); 
         pFits->pHDU().readKey(name,value); 
      } else {
         // j'ajoute le mot clef dans le header
         pFits->read(hduName,true);
         ExtHDU& extHDU = pFits->extension(hduName);
         extHDU.readKey(name,value); 
      }

   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_getKeyword %s : %s keyword=%s", pFits->name().c_str(), e.message().c_str(),name);      
      throw std::exception(message);
   }
}

//----------------------------------------------------------------------------- 
// copie les mots cles du PHDU de pInFits dans le PHDU de pOutFits
//-----------------------------------------------------------------------------
void Fits_setKeyword(FITS *pOutFits, FITS *pInFits) {
   try {
      // 
      pInFits->pHDU().readAllKeys();
      pOutFits->pHDU().copyAllKeys( &(pInFits->pHDU()));


   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setKeyword %s : %s ", pOutFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_setImageLine 
//    ajoute la table des ordres et les parametres du spectro 
//    dans l'extension "ORDERS"
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setImageLine (FITS *pFits, ::std::list<REFERENCE_LINE> &imageLine ) {

   string tableName("ORDERS");
   int nbLine = imageLine.size();
   std::vector<string> colName(13,"");
   std::vector<string> colForm(13,"");
   std::vector<string> colUnit(13,"");
   std::vector<string> colDisp(13,"");
   
   // titre des colonnes, format des colonnes, unites des colonnes, format d'affichage par defaut,  valeur des colonnes
   colName[0] = "x_coordinate";
   colForm[0] = "1D";
   colUnit[0] = "pixel";
   colDisp[0] = "E14.6E3";    
   std::vector<double>    x(nbLine);

   colName[1] = "y_coordinate";
   colForm[1] = "1D";
   colUnit[1] = "pixel";
   colDisp[1] = "E14.6E3";   
   std::vector<double>    y(nbLine);
 
   colName[2] = "identification";
   colForm[2] = "1I";
   colUnit[2] = "symbol";
   colDisp[2] = "I1.1";    
   std::vector<int>    identification(nbLine);
  
   colName[3] = "flux";
   colForm[3] = "1D";
   colUnit[3] = "adu";  
   colDisp[3] = "E14.6E3";    
   std::vector<double>    flux(nbLine);

   colName[4] = "ra";
   colForm[4] = "1D";
   colUnit[4] = "deg";  
   colDisp[4] = "E14.6E3";    
   std::vector<double>    ra(nbLine);

   colName[5] = "dec";
   colForm[5] = "1D";
   colUnit[5] = "deg";  
   colDisp[5] = "E14.6E3"; 
   std::vector<double> dec(nbLine);
   
   colName[6] = "mag";
   colForm[6] = "1D";
   colUnit[6] = "mag";  
   colDisp[6] = "E14.6E3";
   std::vector<double> mag1(nbLine);
   
   colName[7] = "background";
   colForm[7] = "1D";
   colUnit[7] = "adu";
   colDisp[7] = "E14.6E3"; //P2
   std::vector<double> background(nbLine);

   colName[8] = "fwhmx";
   colForm[8] = "1D";
   colUnit[8] = "pixel";  
   colDisp[8] = "E14.6E3"; //P3
   std::vector<double> fwhmx(nbLine);

   colName[9] = "fwhmy";
   colForm[9] = "1D";
   colUnit[9] = "pixel";  
   colDisp[9] = "E14.6E3"; //P4
   std::vector<double> fwhmy(nbLine);

   colName[10] = "intensity";
   colForm[10] = "1D";
   colUnit[10] = "adu";  
   colDisp[10] = "E14.6E3"; //P4
   std::vector<double> intensity(nbLine);

   colName[11] = "abratio";
   colForm[11] = "1D";
   colUnit[11] = "deg";  
   colDisp[11] = "E14.6E3"; //P4
   std::vector<double> abratio(nbLine);

   colName[12] = "position angle";
   colForm[12] = "1D";
   colUnit[12] = "";  
   colDisp[12] = "E14.6E3"; //P4
   std::vector<double> angle(nbLine);


   // je copie les valeurs dans les vecteurs
   ::std::list<REFERENCE_LINE>::iterator iter;
   int nbRow = 0; 
   for (iter=imageLine.begin(); iter != imageLine.end(); ++iter) {
      REFERENCE_LINE line = *iter;
      x[nbRow] = line.posx;
      y[nbRow] = line.posy;
      identification[nbRow] = 1;
      flux[nbRow] = line.lambda;
      ra[nbRow] = line.lambda;
      dec[nbRow] = line.posy;
      mag1[nbRow] = 1.0;
      background[nbRow] = 1.0;
      fwhmx[nbRow] = 1.0;
      fwhmy[nbRow] = 1.0;
      intensity[nbRow] = 1.0;
      abratio[nbRow] = 1.0;
      angle[nbRow] = 1.0;

      nbRow++;
   }

   try {
      ExtHDU *orderTable = NULL;
      try {
         orderTable = &(pFits->extension("CATALIST"));
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         // je cree la table si elle n'existait pas
         orderTable = pFits->addTable(tableName,nbRow,colName,colForm,colUnit);
         // j'ajoute les mots clefs decrivant l'affichage par defaut de chaque colonne de la table
         for(size_t c=0; c<colDisp.size(); c++ ) {
            char keyName[10];
            sprintf(keyName,"TDISP%d",c+1);
            orderTable->addKey(keyName,colDisp[c],"default display format"); 
         }
      }
  
      // j'ajoute les valeurs des colonnes
      orderTable->column(colName[0]).write(x,1);
      orderTable->column(colName[1]).write(y,1);
      orderTable->column(colName[2]).write(identification,1);
      orderTable->column(colName[3]).write(flux,1); 
      orderTable->column(colName[4]).write(ra,1);    
      orderTable->column(colName[5]).write(dec,1);    
      orderTable->column(colName[6]).write(mag1,1);    
      orderTable->column(colName[7]).write(background,1);    
      orderTable->column(colName[8]).write(fwhmx,1);    
      orderTable->column(colName[9]).write(fwhmy,1);  
      orderTable->column(colName[10]).write(intensity,1);
      orderTable->column(colName[11]).write(abratio,1);
      orderTable->column(colName[12]).write(angle,1);
      
      // j'ajoute les parametre du specrographe dans le header
      orderTable->addKey("TTNAME","OBJELIST","name of this table"); 
      orderTable->addKey("OBJEKEY","test",""); 
      orderTable->addKey("CATASTAR",nbRow,""); 
      
      // je force l'ecriture sur le disque immediatement
      pFits->flush();
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"setOrders %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_setReferenceLine 
//    ajoute la table des ordres et les parametres du spectro 
//    dans l'extension "ORDERS"
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void Fits_setCatalogLine (FITS *pFits, ::std::list<REFERENCE_LINE> &catalogLine ) {

   string tableName("CATALIST");
   int nbLine = catalogLine.size();
   std::vector<string> colName(9,"");
   std::vector<string> colForm(9,"");
   std::vector<string> colUnit(9,"");
   std::vector<string> colDisp(9,"");
   
   // titre des colonnes, format des colonnes, unites des colonnes, format d'affichage par defaut,  valeur des colonnes
   colName[0] = "x_coordinate";
   colForm[0] = "1D";
   colUnit[0] = "pixel";
   colDisp[0] = "E14.6E3";    
   std::vector<double>    x(nbLine);

   colName[1] = "y_coordinate";
   colForm[1] = "1D";
   colUnit[1] = "pixel";
   colDisp[1] = "E14.6E3";   
   std::vector<double>    y(nbLine);
 
   colName[2] = "identification";
   colForm[2] = "1I";
   colUnit[2] = "symbol";
   colDisp[2] = "I1.1";    
   std::vector<int>    identification(nbLine);
  
   colName[3] = "ra";
   colForm[3] = "1D";
   colUnit[3] = "deg";  
   colDisp[3] = "E14.6E3";    
   std::vector<double>    ra(nbLine);

   colName[4] = "dec";
   colForm[4] = "1D";
   colUnit[4] = "deg";  
   colDisp[4] = "E14.6E3"; 
   std::vector<double> dec(nbLine);
   
   colName[5] = "magb";
   colForm[5] = "1D";
   colUnit[5] = "";  
   colDisp[5] = "E14.6E3";
   std::vector<double> magb(nbLine);
   
   colName[6] = "magv";
   colForm[6] = "1D";
   colUnit[6] = "";
   colDisp[6] = "E14.6E3"; 
   std::vector<double> magv(nbLine);

   colName[7] = "magr";
   colForm[7] = "1D";
   colUnit[7] = "";  
   colDisp[7] = "E14.6E3"; 
   std::vector<double> magr(nbLine);

   colName[8] = "magi";
   colForm[8] = "1D";
   colUnit[8] = "";  
   colDisp[8] = "E14.6E3"; //P4
   std::vector<double> magi(nbLine);

   // je copie les valeurs dans les vecteurs
   ::std::list<REFERENCE_LINE>::iterator iter;
   int nbRow = 0; 
   for (iter=catalogLine.begin(); iter != catalogLine.end(); ++iter) {
      REFERENCE_LINE line = *iter;
      x[nbRow] = line.posx;
      y[nbRow] = line.posy;
      identification[nbRow] = 1;
      ra[nbRow] = line.lambda;
      dec[nbRow] = line.posy;
      magb[nbRow] = 1.0;
      magv[nbRow] = 1.0;
      magr[nbRow] = line.lambda;
      magi[nbRow] = 1.0;
      nbRow++;
   }

   try {
      ExtHDU *orderTable = NULL;
      try {
         orderTable = &(pFits->extension("CATALIST"));
      } catch ( CCfits::FITS::NoSuchHDU e ) {
         // je cree la table si elle n'existait pas
         orderTable = pFits->addTable(tableName,nbRow,colName,colForm,colUnit);
         // j'ajoute les mots clefs decrivant l'affichage par defaut de chaque colonne de la table
         for(size_t c=0; c<colDisp.size(); c++ ) {
            char keyName[10];
            sprintf(keyName,"TDISP%d",c+1);
            orderTable->addKey(keyName,colDisp[c],"default display format"); 
         }
      }
  
      // j'ajoute les valeurs des colonnes
      orderTable->column(colName[0]).write(x,1);
      orderTable->column(colName[1]).write(y,1);
      orderTable->column(colName[2]).write(identification,1);
      orderTable->column(colName[3]).write(ra,1);    
      orderTable->column(colName[4]).write(dec,1);    
      orderTable->column(colName[5]).write(magb,1);    
      orderTable->column(colName[6]).write(magv,1);    
      orderTable->column(colName[7]).write(magr,1);    
      orderTable->column(colName[8]).write(magi,1);  
      
      // j'ajoute les parametre du specrographe dans le header
      orderTable->addKey("TTNAME","CATALIST","name of this table"); 
      orderTable->addKey("OBJEKEY","test",""); 
      orderTable->addKey("CATASTAR",nbRow,""); 
      
      // je force l'ecriture sur le disque immediatement
      pFits->flush();
   } catch ( CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"Fits_setCatalogLine %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

