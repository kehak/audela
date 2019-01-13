/*----------------------------------------------*/
/*                 Classe Image                 */
/*           definition des fonctions           */
/*            fonctions de conversion            */
/*----------------------------------------------*/


// inclusion fichiers d'en-t�te generaux
#include <stdlib.h>


// inclusion fichiers d'en-t�te locaux
#include "Image.h"

using namespace std;

// fonctions de la classe Image

unsigned char Image::ConvertitBool() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitBool : ne peut convertir un tampon image AudeLA.";
//     return(1);
//   } else {
    switch (adresse_type) {
    case 2 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 3 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 4 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 5 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 6 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 7 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 8 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = (bool)adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 9 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = (bool)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 1;
      return OK;
      break;
    case 10 :
      adresse_bool = new bool [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_bool[index] = (bool)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 1;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitBool : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    // }
}


unsigned char Image::ConvertitChar() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitChar : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 3 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 4 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 5 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 6 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 7 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 8 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = (char)adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 9 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = (char)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 2;
      return OK;
      break;
    case 10 :
      adresse_char = new char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_char[index] = (char)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 2;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitChar : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    // }
}


unsigned char Image::ConvertitUnsignedChar() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitUnsignedChar : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 2 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 4 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 5 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 6 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 7 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 8 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = (unsigned char)adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 9 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = (unsigned char)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 3;
      return OK;
      break;
    case 10 :
      adresse_unsigned_char = new unsigned char [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_char[index] = (unsigned char)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 3;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitUnsignedChar : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    // }
}


unsigned char Image::ConvertitShort() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitShort : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 2 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 3 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 5 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 6 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 7 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 8 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = (short)adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 9 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = (short)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 4;
      return OK;
      break;
    case 10 :
      adresse_short = new short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_short[index] = (short)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 4;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitShort : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    //  }
}


unsigned char Image::ConvertitUnsignedShort() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitUnsignedShort : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 2 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 3 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 4 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 6 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 7 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 8 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 9 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 5;
      return OK;
      break;
    case 10 :
      adresse_unsigned_short = new unsigned short [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_short[index] = (unsigned short)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 5;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitUnsignedShort : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    //  }
}


unsigned char Image::ConvertitLong() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitLong : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 6;
      return OK;
      break;
    case 2 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 6;
      return OK;
      break;
    case 3 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 6;
      return OK;
      break;
    case 4 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 6;
      return OK;
      break;
    case 5 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 6;
      return OK;
      break;
    case 7 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 6;
      return OK;
      break;
    case 8 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_float[index];
      }
      delete [] adresse_float;
      adresse_type = 6;
      return OK;
      break;
    case 9 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 6;
      return OK;
      break;
    case 10 :
      adresse_long = new long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long[index] = (long)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 6;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitLong : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    // }
}


unsigned char Image::ConvertitUnsignedLong() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitUnsignedLong : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 2 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 3 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 4 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 5 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 6 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 8 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 9 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 7;
      return OK;
      break;
    case 10 :
      adresse_unsigned_long = new unsigned long [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_unsigned_long[index] = (unsigned long)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 7;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitUnsignedLong : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    // }
}


unsigned char Image::ConvertitFloat() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitFloat : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 2 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 3 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 4 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 5 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 6 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 7 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 9 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 8;
      return OK;
      break;
    case 10 :
      adresse_float = new float [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_float[index] = (float)adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 8;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitFloat : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    //  }
}


unsigned char Image::ConvertitDouble() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitDouble : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 2 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 3 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 4 :
      adresse_bool = new bool [naxis1*naxis2];
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 5 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 6 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 7 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 8 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 9;
      return OK;
      break;
    case 10 :
      adresse_double = new double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_double[index] = adresse_long_double[index];
      }
      delete [] adresse_long_double;
      adresse_long_double = NULL;
      adresse_type = 9;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitDouble : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    //  }
}


unsigned char Image::ConvertitLongDouble() {

	unsigned long index;

//   if (tampon_audela > 0) {
//     cerr << "Libbm, erreur dans Image::ConvertitLongDouble : ne peut convertir un tampon image AudeLA.";
//     return 1;
//   } else {
    switch (adresse_type) {
    case 1 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_bool[index];
      }
      delete [] adresse_bool;
      adresse_bool = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 2 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_char[index];
      }
      delete [] adresse_char;
      adresse_char = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 3 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_unsigned_char[index];
      }
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 4 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_short[index];
      }
      delete [] adresse_short;
      adresse_short = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 5 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_unsigned_short[index];
      }
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 6 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_long[index];
      }
      delete [] adresse_long;
      adresse_long = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 7 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_unsigned_long[index];
      }
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 8 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_float[index];
      }
      delete [] adresse_float;
      adresse_float = NULL;
      adresse_type = 10;
      return OK;
      break;
    case 9 :
      adresse_long_double = new long double [naxis1*naxis2];
      for (index=0 ; index<naxis1*naxis2 ; index++) {
        adresse_long_double[index] = adresse_double[index];
      }
      delete [] adresse_double;
      adresse_double = NULL;
      adresse_type = 10;
      return OK;
      break;
    default :
      cerr << "Libbm, erreur dans Image::ConvertitLongDouble : tentative de conversion depuis un type inconnu.";
      return 1;
    }
    //  }
}


