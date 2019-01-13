/* cvisu.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>    // pour gmtime
//#include <tcl.h>     // pour TclInterp
#include <abcommon.h>
using namespace abcommon;

#include "cfile.h"
#include "cpixelsgray.h"
#include "cpixelsrgb.h"
#include "libtt.h"         // fichiers FITS
#include "cerrorlibtt.h"
#include "libdcjpeg.h"     // fichiers JPEG
#include "libdcraw.h"      // fichiers RAW

// initialisation des attributs statiques
//Tcl_Interp * CFile::interp = NULL; 

CFile::CFile()
{
}


CFile::~CFile()
{
}

/*
void CFile::setTclInterp( Tcl_Interp *interp)
{
   CFile::interp = interp;
}
*/

 /**
 *  getFormatFromHeader
 *  identifie le format du fichier
 *
 *  @param fileName : nom du fichier
 *  @return : format du fichier (voir l'enumeration CFileFormat) 
 */
CFileFormat CFile::getFormatFromHeader(const char * fileName)
{
   int result;
   FILE *fichier_in ;
   char line[11],*fileName0;
   CFileFormat fileFormat;
   struct libdcraw_DataInfo dataInfo;
   int n,k,kb=0;

#  define FitsHeader    "SIMPLE"
#  define JpgHeader     "\xff\xd8"
#  define GIF87aHeader  "\x47\x49\x46\x38\x37\x61" 
#  define GIF89aHeader  "\x47\x49\x46\x38\x39\x61"
#  define PNGHeader     "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a"
#  define BMPHeader     "BM"
#  define TIFHeader     "\x49\x49\x2A\x00"
#  define GzipHeader    "\x1f\x8b\x08"

   // je verifie le nom du fichier
   if ( fileName == NULL || strlen(fileName) == 0 ) {
      throw CError(CError::ErrorInput, "fileName is NULL or empty");
   }

   // je retire l'extension [ ou ; pour le format etendu de FITSIO
   n=strlen(fileName);
   kb=n;
   for (k=0;k<n;k++) {
      if ((fileName[k]=='[')||(fileName[k]==';')) {
         kb=k;
         break;
      }
   }
   fileName0=(char*)malloc((kb+1)*sizeof(char));
   if (fileName0==NULL) {
      throw CError(CError::ErrorMemory, "Filename0 for %s not allocated",fileName);
   }
   strncpy(fileName0,fileName,kb);
   fileName0[kb]='\0';

   // j'ouvre le fichier
   if ( (fichier_in=fopen(fileName0, "rb")) == NULL) {
      free(fileName0);
      throw CError(CError::ErrorGeneric, "File %s not found",fileName);
   }
   free(fileName0);

   // je lis les 10 premiers  octets
   result = fread( line, 1, 10, fichier_in );
   if ( result != 10 ) {
      fclose(fichier_in);
      throw CError(CError::ErrorGeneric, "File %s too small (less than 10 bytes)",fileName);
   }
   fclose(fichier_in);

   // identify file format
   if ( strncmp(line, FitsHeader , 6 ) == 0 ) {
      fileFormat = CFILE_FITS;
   } else if ( strncmp(line, GzipHeader , 3 ) == 0) {
      // fichier fits comresse
      fileFormat = CFILE_FITS;
   } else if ( strncmp(line, JpgHeader , 2 ) == 0 ) {
      fileFormat = CFILE_JPEG;
   } else if ( libdcraw_getInfoFromFile(fileName, &dataInfo) == 0 ) {
      fileFormat = CFILE_RAW;
   } else if ( strncmp(line, PNGHeader , 8 ) == 0 ) {
      fileFormat = CFILE_PNG;
   } else if ( strncmp(line, GIF87aHeader, 6 ) == 0 || strncmp(line, GIF87aHeader, 6 ) == 0 ) {
      fileFormat = CFILE_GIF;
   } else if ( strncmp(line, BMPHeader, 2 ) == 0 ) {
      fileFormat = CFILE_BMP;
   } else if ( strncmp(line, TIFHeader, 4 ) == 0 ) {
      fileFormat = CFILE_TIF;
   } else {
      fileFormat = CFILE_UNKNOWN;
   }

   return fileFormat;
}

/**
 * loadFile
 * charge une image
 *
 * @param fileName   nom du fichier.  
 *                      Le nom du fichier peut contenir le numero de HDU a charger sepre par un point virgule
 *                      exemple : m57.fit;2
 * @param iaxis3     numero du plan dans le HDU (IN) vaut 1, 2, 3, 4 , ..., n
 *                   si iaxis = 0 et naxis = 3 on charge tous les plans dans un buffer RGB
 * @param dataTypeOut type de donnees a mettre dans le fichier FITS . Inutilise par les autre formats. 
 * @param pixels     objet CPixels contenant les pixels lus dans le fichier
 * @param keywords   objet CFitsKeywords contenant les mots cles lus dans le fichier
 *
 * @return : format du fichier (voir l'enumeration CFileFormat) 
 * @exception  retourne une exception CError en cas d'erreur
 */
CFileFormat CFile::loadFile(const char * fileName, int iaxis3, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{
   CFileFormat fileFormat;

   // je verifie le nom du fichier
   fileFormat = getFormatFromHeader(fileName);
   switch ( fileFormat ) {
   case CFILE_FITS :
      loadFits(fileName, iaxis3, dataTypeOut, pixels, keywords);
      break;

   case CFILE_JPEG :
      loadJpeg(fileName, pixels, keywords);
      break;

   case CFILE_RAW :
      loadRaw(fileName, pixels, keywords);
      break;

   //case CFILE_BMP :
   //case CFILE_GIF :
   //case CFILE_PNG :
   //case CFILE_TIF :
   //   loadTkimg(fileName, pixels, keywords);
   //   break;

   default :
      // unknown format
      //loadTkimg(fileName, pixels, keywords);
      loadFits(fileName, iaxis3, dataTypeOut, pixels, keywords);
      
   }

   return fileFormat;
}


//-------------------------------------------------------------------
//  loadFits
//    charge une image FITS avec libtt
//
//  @param fileName nom du fichier de l'image (IN)
//  @param iaxis3   numero du plan dans le HDU (IN) vaut 1, 2, 3, 4 , ..., n
//                  si iaxis = 0 et naxis = 3 on charge tous les plans dans un buffer RGB
//  @param dataTypeOut :  type de pixel en sortie (IN)
//       * FORMAT_BYTE 
//       * FORMAT_SHORT 
//       * FORMAT_USHORT 
//       * FORMAT_FLOAT
//  @param pixels   : objet de la classe CPixels contenant les pixels de l'image  (OUT)
//  @param keywords : objet de la classe CFitsKeywords contenant les mots cles de l'image  (OUT)
//  
//  @return void
//  @exception  retourne une exception CError en cas d'erreur
//-------------------------------------------------------------------
void CFile::loadFits(const char * fileName, int iaxis3, int dataTypeOut, CPixels **pixels, CFitsKeywords **keywords)
{
   int msg;                         // Code erreur de libtt
   int naxis,naxis1,naxis2,naxis3;
   int nb_keys;
   TPixelFormat pixelFormat;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   float *ppix=NULL;
   try {

      // si axis = 0 (l'utilisateur n'a pas precise le plan a charger)
      //    si l'image a 3 plans , je charge les 3 plans RGB
      //    sinon je charge le premier plan dans une image GRAY.

      // Pour savoir si l'image a 3 plan je demande a libtt de charger le 3ieme HDU. (iaxis=3)
      //   si Libtt_main retourne naxis3=3 le 3ieme HDU existe       => c'est une image RGB
      //   si Libtt_main retourne naxis3=1 le 3ieme HDU n'existe pas => c'est une image GRAY
      int iaxisTest;
      if ( iaxis3 == 0 ) {
         iaxisTest = 3;
      } else {
         iaxisTest = iaxis3;
      }
      msg = libtt_main(TT_PTR_LOADIMA3D,13,fileName,&dataTypeOut,&iaxisTest,&ppix,&naxis1,&naxis2,&naxis3,
         &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) throw CErrorLibtt(msg);
      switch (dataTypeOut) {
         case TBYTE_FITS :
            pixelFormat = FORMAT_BYTE;
            break;
         case TUSHORT :
            pixelFormat = FORMAT_SHORT;
            break;
         case TSHORT  :
            pixelFormat = FORMAT_USHORT;
            break;
         case TFLOAT  :
            pixelFormat = FORMAT_FLOAT;
            break;
         default :
            throw CError(CError::ErrorGeneric, "LoadFits error: format dataTypeOut=%d not supported.",dataTypeOut);
      }



      // je copie les mots cles dans la variable de sortie
      *keywords = new CFitsKeywords();
      (*keywords)->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);
      // je recupere le nombe d'axes NAXIS
      CFitsKeyword * naxisKey = (*keywords)->FindKeyword("NAXIS");
      if(naxisKey == NULL  ) {
         throw CError(CError::ErrorGeneric, "LoadFile error : keyword NAXIS not found");
      } 
      naxis = naxisKey->getIntValue();

      if ( naxis == 3 && naxis3 == 3 && iaxis3 == 0 ) {
         // s'il y a 3 plans et l'utisateur a demandé iaxis3=0, je charge les trois plans dans une image RGB
         TYPE_PIXELS * ppixR = NULL;
         TYPE_PIXELS * ppixG = NULL ;
         TYPE_PIXELS * ppixB = NULL ;  

         // je copie les mots cles dans la variable de sortie
         *keywords = new CFitsKeywords();
         (*keywords)->GetFromArray(nb_keys,&keynames,&values,&comments,&units,&datatypes);
         naxis3 = 3;
         (*keywords)->Add("NAXIS3",&naxis3,TINT,"","");

         iaxis3 = 1;
         msg = libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
         msg = libtt_main(TT_PTR_LOADIMA3D,13,fileName,&dataTypeOut,&iaxis3,&ppixR,&naxis1,&naxis2,&naxis3,
            &nb_keys,&keynames,&values,&comments,&units,&datatypes);
         iaxis3 = 2;
         msg = libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
         msg = libtt_main(TT_PTR_LOADIMA3D,13,fileName,&dataTypeOut,&iaxis3,&ppixG,&naxis1,&naxis2,&naxis3,
            &nb_keys,&keynames,&values,&comments,&units,&datatypes);
         iaxis3 = 3;
         msg = libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
         msg = libtt_main(TT_PTR_LOADIMA3D,13,fileName,&dataTypeOut,&iaxis3,&ppixB,&naxis1,&naxis2,&naxis3,
            &nb_keys,&keynames,&values,&comments,&units,&datatypes);

         // je copie les pixels dans la variable de sortie
         *pixels = new CPixelsRgb(naxis1, naxis2, pixelFormat, ppixR, ppixG, ppixB);

         msg = libtt_main(TT_PTR_FREEPTR,1,&ppixR);
         msg = libtt_main(TT_PTR_FREEPTR,1,&ppixG);
         msg = libtt_main(TT_PTR_FREEPTR,1,&ppixB);
      } else {
         // je charge un seul plan
         // je copie les pixels dans la variable de sortie
         *pixels = new CPixelsGray(naxis1, naxis2, pixelFormat, ppix, 0, 0);

         // si le fichier contient NAXIS=3 et qu'un seul plan est demandé
         //  on retourne une image a 2 dimensions (il faut donc focer naxis = 2)
         if ( naxis >= 3 ) {
            int naxistemp = 2;
            (*keywords)->Add("NAXIS",&naxistemp,TINT,"","");
         }
         // je supprime le naxis3 charge par libtt car maintenant c'est une image a 2 dimensions (naxis = 2)
         CFitsKeyword * naxis3Key = (*keywords)->FindKeyword("NAXIS3");
         if(naxis3Key != NULL  ) {
            (*keywords)->Delete("NAXIS3");
         }
      }
   } catch (const CError& e) {
      // Liberation de la memoire allouee par libtt
      libtt_main(TT_PTR_FREEPTR,1,&ppix);
      libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      // je transmet l'erreur
      throw e;
   }

   // Liberation de la memoire allouee par libtt (pas necessire de catcher les erreurs)
   msg = libtt_main(TT_PTR_FREEPTR,1,&ppix);
   msg = libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
}

// @param fileName
// @param dataTypeOut  inutilisé
// @param pixels  
// @param keywords
void CFile::saveFits(const char * fileName, int , CPixels *pixels, CFitsKeywords *keywords)
{
   int msg;                         // Code erreur de libtt
   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   void *ppix;
   int nb_keys;
   int naxis1, naxis2;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   int datatype;

   // petir raccourci sur les dimensions
   naxis1 = pixels->getWidth();
   naxis2 = pixels->getHeight();

   switch( pixels->getPixelClass() ) {
      case CLASS_RGB :
         ppix = malloc(naxis1*naxis2*pixels->GetPlanes() * sizeof(TYPE_PIXELS_RGB));
         pixelsR = (TYPE_PIXELS_RGB *) ppix;
         pixelsG = pixelsR + naxis1*naxis2;
         pixelsB = pixelsR + naxis1*naxis2*2;

         // je recupere l'image RGB a traiter en séparant les 3 plans
         pixels->getPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_R, (void*) pixelsR);
         pixels->getPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_G, (void*) pixelsG);
         pixels->getPixels(0, 0, naxis1-1, naxis2-1, FORMAT_SHORT, PLANE_B, (void*) pixelsB);

         // format des pixels en entree de libtt
         datatype = TSHORT;
         break;
      default :
         // je recupere l'image GREY a traiter
         ppix = malloc(naxis1* naxis2 * sizeof(float));
         pixels->getPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (void*) ppix);

         // format des pixels en entree de libtt
         datatype = TFLOAT;
         break;
   }


   // Collecte de renseignements pour la suite
   nb_keys = keywords->GetKeywordNb();

   // Allocation de l'espace memoire pour les tableaux de mots-cles
   if (nb_keys>0) {
      msg = libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         free(ppix);
         throw CErrorLibtt(msg);
      }
   }

   // Conversion keywords vers tableaux 'Made in Klotz'
   keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);

   // j'enregistrement l'image.
   msg = libtt_main(TT_PTR_SAVEIMAKEYDIM,9,fileName,ppix,&datatype,&nb_keys,keynames,values,comments,units,datatypes);
   if(msg) {
      free(ppix);
      throw CErrorLibtt(msg);
   }

   // Liberation de la memoire allouee par libtt
   if (nb_keys>0) {
   msg = libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         free(ppix);
         throw CErrorLibtt(msg);
      }
   }
   free(ppix);
}

// @param outputFileName
// @param keywords
// @param nbRow   inutilisé
// @param nbCol
// @param columnType
// @param columnTitle
// @param columnUnits
// @param columnData
void CFile::saveFitsTable(const char * outputFileName, CFitsKeywords *keywords, int , int nbCol, char *columnType, char **columnTitle, char **columnUnits, char **columnData )
{
   int msg = 0;                         // Code erreur de libtt
   int nb_keys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char binary[20];

   strcpy(binary,"ascii");
   nb_keys = keywords->GetKeywordNb();
   // Allocation de l'espace memoire pour les tableaux de mots-cles
   if (nb_keys>0) {
      msg = libtt_main(TT_PTR_ALLOKEYS,6,&nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         throw CErrorLibtt(msg);
      }
      // Conversion keywords vers tableaux 'Made in Klotz'
      keywords->SetToArray(&keynames,&values,&comments,&units,&datatypes);


      /**************************************************************************/
      /* Fonction d'interface pour sauver les tables (spectres...)              */
      /**************************************************************************/
      /* ------ entrees obligatoires                                            */
      /* arg1 : *fullname (char*)                                               */
      /* arg2 : *dtype (char* : datatypes des champs)                           */
      /*        short, int, float, double, un nombre de carateres               */
      /*        Permet de connaitre aussi le nombre de champs (tfields)         */
      /* arg3 : **tunit (char** : unite des champs)                             */
      /* arg4 : **ttype (char** : intitule des champs)                          */
      /*  A noter que **table, **tunit, **ttype ont ete dimensionnes par        */
      /*  tt_ptr_allotbl.                                                       */
      /* arg5 : "binary" ou "ascii" en fonction du format de sortie desire.     */
      /* ------ entrees facultatives pour l'entete                              */
      /* arg6 : *nbkeys (int*)                                                  */
      /* arg7 : **keynames (char**)                                             */
      /* arg8 : **values (char**)                                               */
      /* arg9 : **comments (char**)                                             */
      /* arg10 : **units (char**)                                               */
      /* arg11 : *datatype (int*)                                               */
      /* ------ entrees des donnees des colonnes                                */
      /* arg12 *char (char*) chaine de la premiere colonne.                     */
      /* arg13 *char (char*) chaine de la deuxieme colonne.                     */
      /* ...                                                                    */
      /**************************************************************************/

      // j'enregistrement la table
      if ( nbCol == 9 ) {
         msg = libtt_main(TT_PTR_SAVETBL,20,outputFileName,
            columnType, columnUnits, columnTitle, binary,
            &nb_keys,keynames,values,comments,units,datatypes,
            columnData[0],columnData[1],columnData[2],columnData[3],
            columnData[4],columnData[5],columnData[6],columnData[7],columnData[8]);
         if(msg) {
            libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            throw CErrorLibtt(msg);
         }
      }
      if ( nbCol == 13 ) {
         msg = libtt_main(TT_PTR_SAVETBL,24,outputFileName,
            columnType, columnUnits, columnTitle, binary,
            &nb_keys,keynames,values,comments,units,datatypes,
            columnData[0],columnData[1],columnData[2],columnData[3],
            columnData[4],columnData[5],columnData[6],columnData[7],columnData[8],
            columnData[9],columnData[10],columnData[11],columnData[12],columnData[13]);
         if(msg) {
            libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            throw CErrorLibtt(msg);
         }
      }

      // Liberation de la memoire allouee par libtt
      msg = libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
   }
}

//-------------------------------------------------------------------
//  loadJpeg
//    charge une image JPEG avec libdcjpeg
//
//  @param fileName nom du fichier de l'image (IN)
//  @param pixels   objet de la classe CPixels contenant les pixels de l'image  (OUT)
//  @param keywords objet de la classe CFitsKeywords contenant les mots cles de l'image  (OUT)
//  
//  @return void
//  @exception  retourne une exception CError en cas d'erreur
//-------------------------------------------------------------------
void CFile::loadJpeg(const char * fileName, CPixels **pixels, CFitsKeywords **keywords)
{
   unsigned char * decodedData;
   long   decodedSize;
   int   naxis, width, height, naxis3;
   float initialMipsLo, initialMipsHi;
   int result = -1;

   if( strlen(fileName) == 0 ) {
      throw new CError(CError::ErrorGeneric, "loadJpeg : fileName is empty");
   }

   // TODO : recuperer les donnees EXIF

   result  = libdcjpeg_loadFile(fileName, &decodedData, &decodedSize, &naxis3, &width, &height);
   if (result == 0 )  {

      // je copie les pixels dans la variable de sortie *pixels
      if ( naxis3 == 1 ) {
         *pixels = new CPixelsGray(width, height, FORMAT_BYTE, decodedData, 0, 0);
         naxis = 2;
      } else if ( naxis3 == 3 ) {
         *pixels = new CPixelsRgb(width, height, FORMAT_BYTE, decodedData, 0, 0);
         naxis = 3;
      } else {
         throw new CError(CError::ErrorGeneric, "loadJpeg : unsupported value naxis3=%d ", naxis3);
      }

      // je copie les mots cles dans la variable de sortie *keywords
      *keywords = new CFitsKeywords();
      initialMipsLo = 0.0 ;
      initialMipsHi = 255.0;

      (*keywords)->Add("NAXIS", &naxis,TINT,"","");
      (*keywords)->Add("NAXIS1",&width,TINT,"","");
      (*keywords)->Add("NAXIS2",&height,TINT,"","");
      if ( naxis3 == 3) (*keywords)->Add("NAXIS3",&naxis3,TINT,"","");
      (*keywords)->Add("MIPS-LO",&initialMipsLo,TFLOAT,"Low cut","ADU");
      (*keywords)->Add("MIPS-HI",&initialMipsHi,TFLOAT,"Hight cut","ADU");

      // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desallou� par cette meme librairie.
      libdcjpeg_freeBuffer(decodedData);
   } else {
      throw CError(CError::ErrorGeneric, "libjpeg_decodeBuffer error=%d", result);
   }
}


void CFile::saveJpeg(const char * fileName, unsigned char *dataIn, CFitsKeywords *, int planes,  int width, int height, int quality)
{

   // TODO : copier les motclesdans les donnees EXIF

   libdcjpeg_saveFile(fileName, dataIn, planes, width, height, quality);

}


//-------------------------------------------------------------------
//  loadRaw
//    charge une raw avec libdcraw
//
//  @param fileName nom du fichier de l'image (IN)
//  @param pixels   objet de la classe CPixels contenant les pixels de l'image  (OUT)
//  @param keywords objet de la classe CFitsKeywords contenant les mots cles de l'image  (OUT)
//  
//  @return void
//  @exception  retourne une exception CError en cas d'erreur
//-------------------------------------------------------------------
void CFile::loadRaw(const char * fileName, CPixels **pixels, CFitsKeywords **keywords)
{
   unsigned short * decodedData;
   int   width, height;
   float initialMipsLo, initialMipsHi;
   int result = -1;
   struct libdcraw_DataInfo dataInfo;
   struct tm *tmtime;
   char  gmtDate[70];
   char  camera[70];
   char  filter[70];

   if( strlen(fileName) == 0 ) {
      throw new CError(CError::ErrorGeneric, "loadRaw : fileName is empty");
   }

   result  = libdcraw_fileRaw2Cfa(fileName, &dataInfo, &decodedData);
   if (result == 0 )  {
      int naxis = 2;
      width  = dataInfo.width;
      height = dataInfo.height;
      // je recupere le seuil bas et le seuil haut
      initialMipsLo = (float)dataInfo.black ;
      initialMipsHi = (float)dataInfo.maximum;
      // je recupere la date et je la convertis en temps GMT
      tmtime = gmtime( (const time_t *)&dataInfo.timestamp);
      strftime( gmtDate, 70, "%Y-%m-%dT%H:%M:%S", tmtime );
      // je recupere le nom de la camera
      sprintf(camera, "%s %s",dataInfo.make,dataInfo.model);
      // je recupere le filtre
      // la valeur du filtre est convertie en chaine de caracteres Hexadecimale
      // car les mots cles ne supportent pas les entiers non signes sur 4 octets
      sprintf(filter, "%u",dataInfo.filters);

      // je copie les pixels dans la variable de sortie
      *pixels = new CPixelsGray(dataInfo.width, dataInfo.height, FORMAT_USHORT, decodedData, 0, 0);

      // je copie les mots cles dans la variable de sortie
      *keywords = new CFitsKeywords();
      (*keywords)->Add("NAXIS", &naxis,TINT,"","");
      (*keywords)->Add("NAXIS1",&width,TINT,"","");
      (*keywords)->Add("NAXIS2",&height,TINT,"","");
      (*keywords)->Add("MIPS-LO",&initialMipsLo,        TFLOAT,  "Low cut","ADU");
      (*keywords)->Add("MIPS-HI",&initialMipsHi,        TFLOAT,  "Hight cut","ADU");
      (*keywords)->Add("DATE-OBS", &gmtDate,            TSTRING, "", "");
      (*keywords)->Add("EXPOSURE", &dataInfo.shutter,   TFLOAT,  "","s");
      (*keywords)->Add("CAMERA",   &camera,             TSTRING, "" , "");
      (*keywords)->Add("RAWFILTE",  &filter,            TSTRING, "Raw bayer matrix keys", "" );
      (*keywords)->Add("RAWCOLOR",  &dataInfo.colors,   TINT,    "Raw color plane number", "" );
      (*keywords)->Add("RAWBLACK",   &dataInfo.black,   TINT,    "Raw low cut", "" );
      (*keywords)->Add("RAWMAXI", &dataInfo.maximum,    TINT,    "Raw hight cut", "" );

      // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloue par cette meme librairie.
      libdcraw_freeBuffer(decodedData);
   } else if (result == -2) {
      // c'est une image couleur
      result  = libdcraw_fileRaw2Rgb(fileName, &dataInfo, ADH, &decodedData);
      if (result == 0 )  {
         // je copie les pixels dans la variable de sortie (en inversant les Y)
         *pixels = new CPixelsRgb(dataInfo.width, dataInfo.height, FORMAT_USHORT, decodedData, 0, 1);

         // je cree les mots cles en sortie
         *keywords = new CFitsKeywords();
         
         int naxis = 3;
         int naxis3 = 3;
         // je recupere le seuil bas et le seuil haut
         initialMipsLo = (float)dataInfo.black ;
         initialMipsHi = (float)dataInfo.maximum;
         // je recupere la date et je la convertis en temps GMT
         tmtime = gmtime( (const time_t *)&dataInfo.timestamp);
         strftime( gmtDate, 70, "%Y-%m-%dT%H:%M:%S", tmtime );
         // je recupere le nom de la camera
         sprintf(camera, "%s %s",dataInfo.make,dataInfo.model);

         (*keywords)->Add("NAXIS",  &naxis,TINT,"","");
         (*keywords)->Add("NAXIS1", &dataInfo.width,TINT,"","");
         (*keywords)->Add("NAXIS2", &dataInfo.height,TINT,"","");
         (*keywords)->Add("NAXIS3", &naxis3,TINT,"","");
         (*keywords)->Add("MIPS-LO",&initialMipsLo,        TFLOAT,  "Low cut","ADU");
         (*keywords)->Add("MIPS-HI",&initialMipsHi,        TFLOAT,  "Hight cut","ADU");
         (*keywords)->Add("DATE-OBS", &gmtDate,            TSTRING, "", "");
         (*keywords)->Add("EXPOSURE", &dataInfo.shutter,   TFLOAT,  "","s");
         (*keywords)->Add("CAMERA",   &camera,             TSTRING, "" , "");

         // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloue par cette meme librairie.
         libdcraw_freeBuffer(decodedData);

      }
   
   }else {
      throw CError(CError::ErrorGeneric, "libdcraw_fileRaw2Cfa error=%d", result);
   }
}

// @param  cfaFileName
// @param  rgbFileName
// @param  interpolationMethod  inutilisé (interpolationMethod=1 )

void CFile::cfa2Rgb(char* cfaFileName, char* rgbFileName, int  )
{
   CPixels *cfaPixels = NULL;
   CPixels *rgbPixels = NULL;
   CFitsKeywords *cfaKeywords= NULL;
   CFitsKeywords *rgbKeywords= NULL;
   int saving_type = USHORT_IMG;

   try {

      // je charge le fichier CFA
      int iaxis3 = 1;
      CFile::loadFile(cfaFileName, iaxis3, TUSHORT, &cfaPixels, &cfaKeywords);

      // je convertis l'image CFA en RGB
      CFile::cfa2Rgb(cfaPixels, cfaKeywords, 1,  &rgbPixels, &rgbKeywords);

      // j'ajoute le mot cle BITPIX obligatoire
      rgbKeywords->Add("BITPIX",&saving_type,TINT,"","");

      // j'enregistre l'image dans le fichier FITS RGB
      CFile::saveFits(rgbFileName, TUSHORT, rgbPixels, rgbKeywords);

      if (cfaPixels!=NULL)    delete  cfaPixels;
      if (cfaKeywords!=NULL)  delete  cfaKeywords;
      if (rgbPixels!=NULL)    delete  rgbPixels;
      if (rgbKeywords!=NULL)  delete  rgbKeywords;
      
   } catch(CError) {
      if (cfaPixels!=NULL)    delete  cfaPixels;
      if (cfaKeywords!=NULL)  delete  cfaKeywords;
      if (rgbPixels!=NULL)    delete  rgbPixels;
      if (rgbKeywords!=NULL)  delete  rgbKeywords;
      
      // je transmets l'exception
      throw;
   }

}
   

void CFile::cfa2Rgb(CPixels *cfaPixels, CFitsKeywords *cfaKeywords, int interpolationMethod, CPixels **rgbPixels, CFitsKeywords **rgbKeywords )
{
   unsigned short * cfaData = NULL;
   unsigned short * rgbData = NULL;
   int   naxis, naxis3;
   int result = -1;
   TInterpolationMethod  method;
   struct libdcraw_DataInfo dataInfo;
   CFitsKeyword *kwd;

   // je verifie que la methode d'interpolation est connue
   switch ( interpolationMethod ) {
   case 1 :
      method = LINEAR;
      break;
   case 2 :
      method = VNG;
      break;
   case 3 :
      method = ADH;
      break;
   default:
       // methode inconue
      throw CError(CError::ErrorGeneric, "CFile::cfa2Rgb: interpolationMethod=%d unknown", interpolationMethod);
   }

   // je recupere les parametres indispensable a l'interpolation
   dataInfo.width =  cfaPixels->getWidth();
   dataInfo.height = cfaPixels->getHeight();
   if ( (kwd = cfaKeywords->FindKeyword("RAWCOLOR")) != NULL ) {
      dataInfo.colors = kwd->getIntValue();
   } else {
      throw CError(CError::ErrorGeneric, "CFile::cfa2Rgb: not a RAW image, keyword RAWCOLOR not found");

   }
   if ( (kwd = cfaKeywords->FindKeyword("RAWBLACK")) != NULL ) {
      dataInfo.black = kwd->getIntValue();
   } else {
      throw CError(CError::ErrorGeneric, "CFile::cfa2Rgb: not a RAW image, keyword RAWBLACK not found");
   }
   if ( (kwd = cfaKeywords->FindKeyword("RAWMAXI")) != NULL ) {
      dataInfo.maximum = kwd->getIntValue();
   } else {
      throw CError(CError::ErrorGeneric, "CFile::cfa2Rgb: not a RAW image, keyword RAWMAXI not found");
   }
   if ( (kwd = cfaKeywords->FindKeyword("RAWFILTE")) != NULL ) {
      sscanf(kwd->getStringValue(),"%u",&dataInfo.filters);
   } else {
      throw CError(CError::ErrorGeneric, "CFile::cfa2Rgb: not a RAW image, keyword RAWFILTE not found");
   }

   // je recupere les valeurs des pixels
   cfaData = (unsigned short*) malloc( cfaPixels->getWidth() * cfaPixels->getHeight() * sizeof (unsigned short) );
   if( cfaData == NULL ) {
      CError(CError::ErrorGeneric, "CFile::cfa2Rgb: enougth memory");
   }
   cfaPixels->getPixels(0, 0, cfaPixels->getWidth() -1,  cfaPixels->getHeight() -1, FORMAT_USHORT, PLANE_GREY, (void*) cfaData );

   // je convertis l'image CFA en RGB
   result = libdcraw_bufferCfa2Rgb(cfaData, &dataInfo, method, &rgbData);
   if (result == 0 )  {
      // je copie les pixels dans la variable de sortie (en inversant les Y)
      *rgbPixels = new CPixelsRgb(dataInfo.width, dataInfo.height, FORMAT_USHORT, rgbData, 0, 1);

      // je cree les mots cles en sortie
      *rgbKeywords = new CFitsKeywords();
      // je copie les mots cles de l'image CFA
      kwd = cfaKeywords->GetFirstKeyword();
      while( kwd != NULL ) {
         (*rgbKeywords)->Add( kwd->getName(), kwd->getPtrValue(), kwd->getDataType(),
            kwd->getComment(), kwd->getUnit());
         kwd = kwd->next;
      }
      // je modifie les mots cles NAXIS et NAXIS3
      naxis = 3;
      naxis3 = 3;

      (*rgbKeywords)->Add("NAXIS", &naxis,TINT,"","");
      (*rgbKeywords)->Add("NAXIS1", &dataInfo.width,TINT,"","");
      (*rgbKeywords)->Add("NAXIS2", &dataInfo.height,TINT,"","");
      (*rgbKeywords)->Add("NAXIS3",&naxis3,TINT,"","");

      // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desallou� par cette meme librairie.
      libdcraw_freeBuffer(rgbData);

      if (cfaData != NULL) free(cfaData);

   } else {
      if (cfaData != NULL) free(cfaData);
      if (rgbData != NULL) libdcraw_freeBuffer(rgbData);
      throw CError(CError::ErrorGeneric, "libdcraw_fileRaw2Cfa: error=%d", result);
   }

}


//-------------------------------------------------------------------
//  loadTkimg
//    charge une image d'un autre format  avec libaudelatk  (PNG, TIFF, ... )
//  
//  Remarque : 
//    On utilise la commande ::visu::loadImage qui est dans libaudelatk.dll car libaudela.dll 
//    ne peut pas utiliser les fonctions du TK (libaudela.dll doit pourvoir etre chargee sans 
//    TK quand on lance audela avec l'option --console)
//
//  @param fileName nom du fichier de l'image (IN)
//  @param pixels   objet de la classe CPixels contenant les pixels de l'image  (OUT)
//  @param keywords objet de la classe CFitsKeywords contenant les mots cles de l'image  (OUT)
//  
//  @return void
//  @exception  retourne une exception CError en cas d'erreur
//-------------------------------------------------------------------
/*
void CFile::loadTkimg(const char * fileName, CPixels **pixels, CFitsKeywords **keywords)
{
   char ligne[1024]; 
   int tclResult;

   if( strlen(fileName) == 0 ) {
      throw new CError("loadTkimg : fileName is empty");
   }

   // je charge l'image
   sprintf(ligne, "::visu::loadImage {%s}", fileName);
   tclResult = Tcl_Eval(interp,ligne);

   // je copie l'image dans CPixels et CFitsKeywords
   if ( tclResult == TCL_OK) {
      int listArgc;
      const char **listArgv;
      tclResult = Tcl_SplitList(interp,Tcl_GetStringResult(interp),&listArgc,&listArgv);
      if( tclResult==TCL_OK) {
         if ( listArgc == 9 ) {
            int   naxis, width, height, naxis3;
            float initialMipsLo, initialMipsHi;
            int pixelSize; 
            int pitch;
            int offset[4];
            long pixelPtr;

            width = atoi(listArgv[0]);
            height= atoi(listArgv[1]);
            pixelSize = atoi(listArgv[2]);
            pitch = atoi(listArgv[3]);
            offset[0] = atoi(listArgv[4]);
            offset[1] = atoi(listArgv[5]);
            offset[2] = atoi(listArgv[6]);
            offset[3] = atoi(listArgv[7]);
            pixelPtr  = atol(listArgv[8]);

            // je copie les pixels dans la variable de sortie *pixels      
            *pixels = new CPixelsRgb(width, height, pixelSize, offset, pitch, (unsigned char*)pixelPtr);
            
            // je copie les mots cles dans la variable de sortie *keywords
            *keywords = new CFitsKeywords();
            naxis = 3;
            naxis3= 3;
            initialMipsLo = 0.0 ;
            initialMipsHi = 255.0;

            (*keywords)->Add("NAXIS", &naxis,TINT,"","");
            (*keywords)->Add("NAXIS1",&width,TINT,"","");
            (*keywords)->Add("NAXIS2",&height,TINT,"","");
            (*keywords)->Add("NAXIS3",&naxis3,TINT,"","");
            (*keywords)->Add("MIPS-LO",&initialMipsLo,TFLOAT,"Low cut","ADU");
            (*keywords)->Add("MIPS-HI",&initialMipsHi,TFLOAT,"Hight cut","ADU");

         } else {
            tclResult = TCL_ERROR;
         }
      }

      // je supprime l'image temporaire 
      Tcl_Eval(interp,"::visu::freeImage");
   }

   if (tclResult == TCL_ERROR) {
      throw CError("CFile::loadTkimg: %s", Tcl_GetStringResult(interp));
   }
}
*/

//-------------------------------------------------------------------
//  saveTkimg
//    charge une image d'un autre format  avec libaudelatk  (PNG, TIFF, ... )
//  
//  Remarque : 
//    On utilise la commande ::visu::loadImage qui est dans libaudelatk.dll car libaudela.dll 
//    ne peut pas utiliser les fonctions du TK (libaudela.dll doit pourvoir etre chargee sans 
//    TK quand on lance audela avec l'option --console)
//
//  @param fileName nom du fichier de l'image (IN)
//  @param pixels   objet de la classe CPixels contenant les pixels de l'image  (IN)
//  @param width    largeur de l'images en pixel
//  @param height   hauteur de l'images en pixel
//  @param planes   nombre de plans : 1=image en niveau de gris  3=image RGB
//  
//  @return void
//  @exception  retourne une exception CError en cas d'erreur
//-------------------------------------------------------------------
/*
void CFile::saveTkimg(const char * fileName, unsigned char *pixels, int width, int height, int planes)
{
   char ligne[1024]; 
   int tclResult;
   
   if( strlen(fileName) == 0 ) {
      throw new CError("loadTkimg : fileName is empty");
   }
   
   // je sauvegarde l'image 
   sprintf(ligne, "::visu::saveImage  {%s} %ld %d %d %d", fileName, (long) pixels, width, height, planes );
   tclResult = Tcl_Eval(interp,ligne);
   if (tclResult == TCL_ERROR) {
      throw CError("CFile::saveTkimg: %s", Tcl_GetStringResult(interp));
   }
}
*/


