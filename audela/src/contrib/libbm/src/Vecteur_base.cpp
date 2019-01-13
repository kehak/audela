/*----------------------------------------------*/
/*                 Classe Vecteur                 */
/*           definition des fonctions           */
/*              fonctions de base               */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete generaux
#include <iostream>
#include <stdlib.h>

using namespace std;

// inclusion fichiers d'en-tete locaux
#include "Vecteur.h"


// fonctions de la classe Vecteur

Vecteur::Vecteur(void){
  adresse_type = 0;
  adresse_bool = NULL;
  adresse_char = NULL;
  adresse_unsigned_char = NULL;
  adresse_short = NULL;
  adresse_unsigned_short = NULL;
  adresse_long = NULL;
  adresse_unsigned_long = NULL;
  adresse_float = NULL;
  adresse_double = NULL;
  adresse_long_double = NULL;
  naxis1 = 0;
}


Vecteur::~Vecteur(void){
  switch (adresse_type) {
  case 0 :
    break;
  case 1 :
    if (adresse_bool != NULL) {
      delete [] adresse_bool;
      adresse_bool = NULL;
    }
    break;
  case 2 :
    if (adresse_char != NULL) {
      delete [] adresse_char;
      adresse_char = NULL;
    }
    break;
  case 3 :
    if (adresse_unsigned_char != NULL) {
      delete [] adresse_unsigned_char;
      adresse_unsigned_char = NULL;
    }
    break;
  case 4 :
    if (adresse_short != NULL) {
      delete [] adresse_short;
      adresse_short = NULL;
    }
    break;
  case 5 :
    if (adresse_unsigned_short != NULL) {
      delete [] adresse_unsigned_short;
      adresse_unsigned_short = NULL;
    }
    break;
  case 6 :
    if (adresse_long != NULL) {
      delete [] adresse_long;
      adresse_long = NULL;
    }
    break;
  case 7 :
    if (adresse_unsigned_long != NULL) {
      delete [] adresse_unsigned_long;
      adresse_unsigned_long = NULL;
    }
    break;
  case 8 :
    if (adresse_float != NULL) {
      delete [] adresse_float;
      adresse_float = NULL;
    }
    break;
  case 9 :
    if (adresse_double != NULL) {
      delete [] adresse_double;
      adresse_double = NULL;
    }
    break;
  case 10 :
    if (adresse_long_double != NULL) {
      delete [] adresse_long_double;
      adresse_long_double = NULL;
    }
    break;
  default:
    cerr << "Libbm, erreur dans Vecteur::~Vecteur : tentative de desallocation d'un vecteur de type inconnu.";
    exit(1);
  }
  naxis1 = 0;
}


unsigned char Vecteur::CreeVectVierge(unsigned char data_type, unsigned long val_naxis1){

  unsigned long x;

  if (adresse_type>0) {
    cerr << "Libbm, erreur dans Vecteur::CreeVectVierge : essai d'ecrasement d'un vecteur existant.";
    exit(1);
  } else {

    adresse_type = data_type;
    naxis1 = val_naxis1;

    switch (data_type) {
    case 1 :
      adresse_bool = new bool [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
	EcritureBool(x,0);
      }
      break;
    case 2 :
      adresse_char = new char [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureChar(x,0);
      }
      break;
    case 3 :
      adresse_unsigned_char = new unsigned char [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureUnsignedChar(x,0);
      }
      break;
    case 4 :
      adresse_short = new short [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureShort(x,0);
      }
      break;
    case 5 :
      adresse_unsigned_short = new unsigned short [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureUnsignedShort(x,0);
      }
      break;
    case 6 :
      adresse_long = new long [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureLong(x,0);
      }
      break;
    case 7 :
      adresse_unsigned_long = new unsigned long [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureUnsignedLong(x,0);
      }
      break;
    case 8 :
      adresse_float = new float [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureFloat(x,0);
      }
      break;
    case 9 :
      adresse_double = new double [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureDouble(x,0);
      }
      break;
    case 10 :
      adresse_long_double = new long double [val_naxis1];
      for (x=0 ; x<val_naxis1 ; x++) {
          EcritureLongDouble(x,0);
      }
      break;
    default:
      cerr << "Libbm, erreur dans Vecteur::CreeVectVierge : essai de creation d'un vecteur de type inconnu.";
      exit(1);
    }

    return(0);
  }
}


unsigned char Vecteur::CopieDe(Vecteur vect) {

  unsigned long x;

  if (vect.AdresseType()>0) {
    cerr << "Libbm, erreur dans Vecteur::CopieDe : essai de copie d'un vecteur vide.";
    exit(1);
  } else {
    switch (vect.AdresseType()) {
    case 1 :
      adresse_bool = new bool [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureBool(x,vect.LectureBool(x));
      }
      break;
    case 2 :
      adresse_char = new char [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureChar(x,vect.LectureChar(x));
      }
      break;
    case 3 :
      adresse_unsigned_char = new unsigned char [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureUnsignedChar(x,vect.LectureUnsignedChar(x));
      }
      break;
    case 4 :
      adresse_short = new short [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureShort(x,vect.LectureShort(x));
      }
      break;
    case 5 :
      adresse_unsigned_short = new unsigned short [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureUnsignedShort(x,vect.LectureUnsignedShort(x));
      }
      break;
    case 6 :
      adresse_long = new long [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureLong(x,vect.LectureLong(x));
      }
      break;
    case 7 :
      adresse_unsigned_long = new unsigned long [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureUnsignedLong(x,vect.LectureUnsignedLong(x));
      }
      break;
    case 8 :
      adresse_float = new float [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureFloat(x,vect.LectureFloat(x));
      }
      break;
    case 9 :
      adresse_double = new double [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureDouble(x,vect.LectureDouble(x));
      }
      break;
    case 10 :
      adresse_long_double = new long double [vect.Naxis1()];
      for (x=0 ; x<vect.Naxis1() ; x++) {
          EcritureLongDouble(x,vect.LectureLongDouble(x));
      }
      break;
    default:
      cerr << "Libbm, erreur dans Vecteur::CopieDe : essai de creation d'un tampon de type inconnu.";
      exit(1);
    }

    adresse_type = vect.AdresseType();
    naxis1 = vect.Naxis1();
    return(0);
  }
}


unsigned char Vecteur::CopieVers(Vecteur vect) {

  unsigned long x;

  if (AdresseType()>0) {
    cerr << "Libbm, erreur dans Vecteur::CopieVers : essai de copie d'un vecteur vide.";
    exit(1);
  } else {
    switch (AdresseType()) {
    case 1 :
      vect.CreeVectVierge(1,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureBool(x,LectureBool(x));
      }
      break;
    case 2 :
      vect.CreeVectVierge(2,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureChar(x,LectureChar(x));
      }
      break;
    case 3 :
      vect.CreeVectVierge(3,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureUnsignedChar(x,LectureUnsignedChar(x));
      }
      break;
    case 4 :
      vect.CreeVectVierge(4,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureShort(x,LectureShort(x));
      }
      break;
    case 5 :
      vect.CreeVectVierge(5,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureUnsignedShort(x,LectureUnsignedShort(x));
      }
      break;
    case 6 :
      vect.CreeVectVierge(6,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureLong(x,LectureLong(x));
      }
      break;
    case 7 :
      vect.CreeVectVierge(7,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureUnsignedLong(x,LectureUnsignedLong(x));
      }
      break;
    case 8 :
      vect.CreeVectVierge(8,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureFloat(x,LectureFloat(x));
      }
      break;
    case 9 :
      vect.CreeVectVierge(9,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureDouble(x,LectureDouble(x));
      }
      break;
    case 10 :
      vect.CreeVectVierge(10,naxis1);
      for (x=0 ; x<vect.Naxis1() ; x++) {
          vect.EcritureLongDouble(x,LectureLongDouble(x));
      }
      break;
    default:
      cerr << "Libbm, erreur dans Vecteur::CreeVectVierge : essai de creation d'un tampon de type inconnu.";
      exit(1);
    }

    return(0);
  }
}

