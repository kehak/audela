/*----------------------------------------------*/
/*                 Classe Vecteur                 */
/*           definition des fonctions           */
/*            fonctions de conversion            */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete generaux
#include <iostream>
#include <stdlib.h>

using namespace std;

// inclusion fichiers d'en-tete locaux
#include "Vecteur.h"


// fonctions de la classe Vecteur

unsigned char Vecteur::ConvertitBool() {

  unsigned long index;

  switch (adresse_type) {
  case 2 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 3 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 4 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 5 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 6 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 7 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 8 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = (bool)adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 9 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = (bool)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 1;
    return(0);
    break;
  case 10 :
    adresse_bool = new bool [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_bool[index] = (bool)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 1;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitBool : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitChar() {

  unsigned long index;
	
  switch (adresse_type) {
  case 1 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 3 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 4 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 5 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 6 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 7 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 8 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 9 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 2;
    return(0);
    break;
  case 10 :
    adresse_char = new char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_char[index] = (char)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 2;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitChar : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitUnsignedChar() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 2 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 4 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 5 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 6 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 7 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 8 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 9 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 3;
    return(0);
    break;
  case 10 :
    adresse_unsigned_char = new unsigned char [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_char[index] = (unsigned char)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 3;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitUnsignedChar : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitShort() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 2 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 3 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 5 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 6 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 7 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 8 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 9 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 4;
    return(0);
    break;
  case 10 :
    adresse_short = new short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_short[index] = (short)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 4;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitShort : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitUnsignedShort() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 2 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 3 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 4 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 6 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 7 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 8 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 9 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 5;
    return(0);
    break;
  case 10 :
    adresse_unsigned_short = new unsigned short [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_short[index] = (unsigned short)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 5;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitUnsignedShort : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitLong() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 6;
    return(0);
    break;
  case 2 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 6;
    return(0);
    break;
  case 3 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 6;
    return(0);
    break;
  case 4 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 6;
    return(0);
    break;
  case 5 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 6;
    return(0);
    break;
  case 7 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 6;
    return(0);
    break;
  case 8 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = (long)adresse_float[index];
    }
    delete [] adresse_float;
    adresse_type = 6;
    return(0);
    break;
  case 9 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = (long)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 6;
    return(0);
    break;
  case 10 :
    adresse_long = new long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long[index] = (long)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 6;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitLong : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitUnsignedLong() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 2 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 3 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 4 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 5 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 6 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 8 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = (unsigned long)adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 9 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = (unsigned long)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 7;
    return(0);
    break;
  case 10 :
    adresse_unsigned_long = new unsigned long [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_unsigned_long[index] = (unsigned long)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 7;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitUnsignedLong : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitFloat() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 2 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 3 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 4 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 5 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 6 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 7 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 9 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 8;
    return(0);
    break;
  case 10 :
    adresse_float = new float [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_float[index] = (float)adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 8;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitFloat : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitDouble() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 2 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 3 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 4 :
    adresse_bool = new bool [naxis1];
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 5 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 6 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 7 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 8 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 9;
    return(0);
    break;
  case 10 :
    adresse_double = new double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_double[index] = adresse_long_double[index];
    }
    delete [] adresse_long_double;
    adresse_long_double = NULL;
    adresse_type = 9;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitDouble : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


unsigned char Vecteur::ConvertitLongDouble() {

  unsigned long index;

  switch (adresse_type) {
  case 1 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_bool[index];
    }
    delete [] adresse_bool;
    adresse_bool = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 2 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_char[index];
    }
    delete [] adresse_char;
    adresse_char = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 3 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_unsigned_char[index];
    }
    delete [] adresse_unsigned_char;
    adresse_unsigned_char = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 4 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_short[index];
    }
    delete [] adresse_short;
    adresse_short = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 5 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_unsigned_short[index];
    }
    delete [] adresse_unsigned_short;
    adresse_unsigned_short = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 6 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_long[index];
    }
    delete [] adresse_long;
    adresse_long = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 7 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_unsigned_long[index];
    }
    delete [] adresse_unsigned_long;
    adresse_unsigned_long = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 8 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_float[index];
    }
    delete [] adresse_float;
    adresse_float = NULL;
    adresse_type = 10;
    return(0);
    break;
  case 9 :
    adresse_long_double = new long double [naxis1];
    for (index=0 ; index<naxis1 ; index++) {
      adresse_long_double[index] = adresse_double[index];
    }
    delete [] adresse_double;
    adresse_double = NULL;
    adresse_type = 10;
    return(0);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::ConvertitLongDouble : tentative de conversion depuis un type inconnu.";
    exit(1);
  }
}


