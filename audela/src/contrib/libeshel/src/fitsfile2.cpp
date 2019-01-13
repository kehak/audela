/* 
 * fitsfile2.cpp
 */

#include <algorithm>    // pour std::max()
#include <CCfits/CCfits>
#include "fitsfile2.h"
#include "libeshel.h"
#include "infoimage.h"
#include "order.h"
#include "linegap.h"


using namespace CCfits;
using namespace ::std;

CFitsFile::CFitsFile(void)
{
   pFits = NULL;
}

CFitsFile::~CFitsFile(void)
{
   close();
}

// ---------------------------------------------------------------------------
// Fits_createFits 
//      cree un fichier FITS "fileName" avec un PHU vide
// @return
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::create(const char *fileName)  {
   
   try {        
      // j'efface le fichier s'il existait deja
      remove(fileName);
      // prepare naxis array
      long naxis[2];
      naxis[0] = 1;
      naxis[1] = 1;
      // create a new FITS object 
      string stringFileName;
      stringFileName.assign(fileName);
      pFits = new CCfits::FITS(stringFileName, LONG_IMG, 2, naxis ); 
      PHDU& imageHDU = pFits->pHDU();
      std::valarray<PIC_TYPE> imageValue(1);
      imageValue[0]=0;
      imageHDU.write(1,1, imageValue);
      pFits->flush();
   }
   catch (CCfits::FitsException e) {
      close();
      char message[1024];
      sprintf(message,"Fits_createFits %s : size=0x0  %s ", fileName, e.message().c_str());
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_createFits 
//      cree un fichier FITS "fileName" et copie une image 2D dans le PHDU
// @return
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::create(const char *fileName, std::valarray<PIC_TYPE> &imageValue, int width, int height)  {
   
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
      pFits = new CCfits::FITS(stringFileName, LONG_IMG, 2, naxis ); 
      pFits->flush();
      // copy image to Primary HDU
      PHDU& imageHDU = pFits->pHDU();
      long firstElement = 1;
      imageHDU.write(firstElement,imageValue.size(), imageValue);
   }
   catch (CCfits::FitsException e) {
      close();
      char message[1024];
      sprintf(message,"Fits_createFits %s : size=%dx%d  %s ", fileName, width, height, e.message().c_str());
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// create 
//      cree un fichier FITS "fileName" et copie un profil 1D lineaire dans le PHDU
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::create(const char *fileName, std::valarray<double> &profile, double lambda1, double step)  {

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
      pFits = new CCfits::FITS(fileName, DOUBLE_IMG, 1, &naxis );
      PHDU& imageHDU = pFits->pHDU();
      long firstElement = 1;
      imageHDU.write(firstElement,profile.size(), profile);

      /*
      // sauvegarde en 32 bits
      pFits = new CCfits::FITS(fileName, FLOAT_IMG, 1, &naxis );
      PHDU& imageHDU = pFits->pHDU();
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
   }
   catch (CCfits::FitsException e) {
      close();
      char message[1024];
      sprintf(message,"createFits %s naxis1=%d: %s ", fileName, profile.size(), e.message().c_str());
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// Fits_openFits
//      ouvre un fichier FITS en lecture ou en écriture
// return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::open(const char *fileName, bool write = false) {

   try {  
      FITS::setVerboseMode(false);

      // j'ouvre le fichier en lecture
      if ( write == true) {
         pFits = new CCfits::FITS(fileName,CCfits::Write,false);
      } else {
         pFits = new CCfits::FITS(fileName,CCfits::Read,false);
      }
   }
   catch (CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"openFits %s : %s", fileName, e.message().c_str());
      throw std::exception(message);
   }
}


// ---------------------------------------------------------------------------
// Fits_closeFits 
//    ferme le fichier FITS 
// 
// @return
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::close(void)
{
   try { 
      if (pFits != NULL) {
         delete pFits;
         pFits = NULL;
      }
   } catch (CCfits::FitsException e) {
      char message[1024];
      sprintf(message,"closeFits %s : %s", pFits->name().c_str(), e.message().c_str());
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// getInfoSpectro 
//    retourne les parametres du spectro
// @return
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::getInfoSpectro ( INFOSPECTRO * infoSpectro)
{
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
// getOrders 
//    retourne la table des ordres a partir de l'extension "ORDERS" du fichier FITS
// @return
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::getOrders(ORDRE *orderValue, double *dx_ref )  {
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
// getLinearProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// @param hduName  "PRIMARY",  "P_1C_FULL" ...
// @param linearProfile output elements of profile
// @param lambda1
// @param step
// @return void
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::getLinearProfile(const char * hduName, valarray<double> &linearProfile, double *lambda1, double *step) 
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
      sprintf(message,"getLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// getLinearProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "prefix_<numOrder>" dans le fichier FITS
// @return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::getLinearProfile(const char * prefix, int numOrder, valarray<double> &linearProfile, double *lambda1, double *step) 
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
      sprintf(message,"getLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// setLinearProfile 
//    retourne les valeurs d'un profil 
//    cette extension s'appelle "PROFILE" dans le fichier FITS
// @return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::setLinearProfile(const char * prefix, int numOrder, ::std::valarray<double> &linearProfile, double lambda1, double step) 
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
      sprintf(message,"setLinearProfile %s : %s", pFits->name().c_str(), e.message().c_str());      
      throw std::exception(message);
   }
}

// ---------------------------------------------------------------------------
// setKeyword 
//    cree ou mdofie un mot cle dans un HDU 
// @return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::setKeyword(const char * hduName, string &name, string &stringValue, string &comment) {
   try {
      
      if ( hduName == NULL || strcmp(hduName,"")==0 || strcmp(hduName,"PRIMARY")==0) {
         // j'ajoute le mot clef dans le premier header
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

// ---------------------------------------------------------------------------
// getKeyword 
//    retourne la valeur d'un mot cle d'un HDU 
// @return:
//   retourne une std::exception en cas d'erreur
// ---------------------------------------------------------------------------
void CFitsFile::getKeyword(const char * hduName, const char* name, string &value) {
   try {
      
      if ( hduName == NULL || strcmp(hduName,"")==0 || strcmp(hduName,"PRIMARY")==0) {
         pFits->pHDU().readKey(name,value); 
      } else {
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



