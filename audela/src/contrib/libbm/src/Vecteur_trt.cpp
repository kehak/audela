/*----------------------------------------------*/
/*                 Classe Vecteur                 */
/*           definition des fonctions           */
/*           fonctions de traitement            */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete generaux
#include <iostream>
#include <math.h>

using namespace std;

// inclusion fichiers d'en-tete locaux
#include "Vecteur.h"


// fonctions de la classe Vecteur

// ****************** soustrait *********************
// soustrait
// Soustrait le vecteur 2 au vecteur 1, le resultat ecrase le vecteur 1.
// ********************************************************
unsigned char Vecteur::Soustrait(Vecteur* vect2)
{
  /* --- variables locales */
  double element_1,element_2,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    element_2 = (*vect2).LectureDouble(x);
    element_result = element_1 - element_2;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** ajoute *********************
// ajoute
// Ajoute le vecteur 2 au vecteur 1, le resultat ecrase le vecteur 1.
// ********************************************************
unsigned char Vecteur::Ajoute(Vecteur* vect2)
{
  /* --- variables locales */
  double element_1,element_2,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    element_2 = (*vect2).LectureDouble(x);
    element_result=element_1+element_2;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** ajoute_facteur *********************
// ajoute_facteur
// vect1 = vect1 + facteur * vect2
// ********************************************************
unsigned char Vecteur::AjouteFacteur(Vecteur* vect2, double facteur)
{
  /* --- variables locales */
  double element_1,element_2,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    element_2 = (*vect2).LectureDouble(x);
    element_result= element_1 + facteur * element_2;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** multiplie *********************
// multiplie
// Multiplie le vecteur 2 par le vecteur 1, le resultat ecrase le vecteur 1.
// ********************************************************
unsigned char Vecteur::Multiplie(Vecteur* vect2)
{
  /* --- variables locales */
  double element_1,element_2,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    element_2 = (*vect2).LectureDouble(x);
    element_result=element_1*element_2;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** multiplie_ajoute *********************
// multiplie_ajoute
// Multiplie le vecteur 2 par le vecteur 1, le resultat ecrase le vecteur courante.
// ********************************************************
unsigned char Vecteur::MultiplieAjoute(Vecteur* vect1, Vecteur* vect2)
{
  /* --- variables locales */
  double element_1,element_2,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = (*vect1).LectureDouble(x);
    element_2 = (*vect2).LectureDouble(x);
    element_result=element_1*element_2;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** divise *********************
// divise
// Divise le vecteur 1 par le vecteur 2, le resultat ecrase le vecteur 1.
// ********************************************************
unsigned char Vecteur::Divise(Vecteur* vect2)
{
  /* --- variables locales */
  double element_1,element_2,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    element_2 = (*vect2).LectureDouble(x);
    element_result=element_1/element_2;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** carre *********************
// carre
// Prend le carre de le vecteur 1, le resultat ecrase le vecteur 1.
// ********************************************************
unsigned char Vecteur::Carre()
{
  /* --- variables locales */
  double element_1,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    element_result=element_1*element_1;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** carre_ajoute *********************
// carre_ajoute
// Prend le carre du vecteur 1, le resultat ecrase le vecteur courant.
// ********************************************************
unsigned char Vecteur::CarreAjoute(Vecteur* vect1)
{
  /* --- variables locales */
  double element_1,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = (*vect1).LectureDouble(x);
    element_result=element_1*element_1;
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** racine_carree *********************
// racine_carree
// Prend la racine carree du vecteur 1, le resultat ecrase le vecteur 1.
// ********************************************************
unsigned char Vecteur::RacineCarree()
{
  /* --- variables locales */
  double element_1,element_result;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    element_result=sqrt(element_1);
    EcritureDouble(x, element_result);
  }
  return(0);
}


// ****************** marche *********************
// marche
// Retourne la fonction de Heavyside du vecteur
// ********************************************************
unsigned char Vecteur::Marche()
{
  /* --- variables locales */
  double element_1;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {

    element_1 = LectureDouble(x);
    if (element_1 > 0) 
      {
	EcritureDouble(x, 1);
      } else {
	EcritureDouble(x, -1);
      }
  }
  return(0);
}


// ****************** Dxx *********************
// Dxx
// Derivee seconde
// ********************************************************
unsigned char Vecteur::Dxx(Vecteur* vect1)
{
  /* --- variables locales */
  double element_1, element_2, element_3, element_result;

  /* --- procedure principale */
  // premier element
  element_2 = (*vect1).LectureDouble(0);
  element_3 = (*vect1).LectureDouble(1);
  element_result = element_3 - element_2;
  EcritureDouble(0, element_result);

  // elements intermediaires
  for (unsigned long x=1 ; x<(naxis1-1) ; x++) {

    element_1 = (*vect1).LectureDouble(x-1);
    element_2 = (*vect1).LectureDouble(x);
    element_3 = (*vect1).LectureDouble(x+1);
    element_result = element_3 - 2 * element_2 + element_1;
    EcritureDouble(x, element_result);
  }

  // dernier element
  element_1 = (*vect1).LectureDouble(naxis1 - 2);
  element_2 = (*vect1).LectureDouble(naxis1 - 1);
  element_result = - element_2 + element_1;
  EcritureDouble(naxis1-1, element_result);

  return(0);
}


// ******** Convolue ***************

unsigned char Vecteur::Convolue(Vecteur *filtre) {
  // Initialisation variables locales
  Vecteur tmp_vect;
  unsigned long i;
  // On teste que les deux vects sont de m�me type
  if (adresse_type != (*filtre).AdresseType()) {
    cerr << "Libbm, erreur dans Vecteur::Convolue : ne peut convoluer des vecteurs de types differents.";
    return 1;
  } else {
    CopieVers(tmp_vect);
    for (unsigned long x=((*filtre).Naxis1()-1)/2 ; x<naxis1-((*filtre).Naxis1()-1)/2 ; x++) {
      bool tmp_bool = 0;
      char tmp_char = 0;
      unsigned char tmp_unsigned_char = 0;
      short tmp_short = 0;
      unsigned short tmp_unsigned_short = 0;
      long tmp_long = 0;
      unsigned long tmp_unsigned_long = 0;
      float tmp_float = 0;
      double tmp_double = 0;
      long double tmp_long_double = 0;
      switch (adresse_type) {
      case 1:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_bool += (*filtre).LectureBool(i) * tmp_vect.LectureBool(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureBool(x,tmp_bool);
	break;
      case 2:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_char += (*filtre).LectureChar(i) * tmp_vect.LectureChar(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureChar(x,tmp_char);
	break;
      case 3:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_unsigned_char += (*filtre).LectureUnsignedChar(i) * tmp_vect.LectureUnsignedChar(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureUnsignedChar(x,tmp_unsigned_char);
	break;
      case 4:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_short += (*filtre).LectureShort(i) * tmp_vect.LectureShort(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureShort(x,tmp_short);
	break;
      case 5:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_unsigned_short += (*filtre).LectureUnsignedShort(i) * tmp_vect.LectureUnsignedShort(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureUnsignedShort(x,tmp_unsigned_short);
	break;
      case 6:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_long += (*filtre).LectureLong(i) * LectureLong(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureLong(x,tmp_long);
	break;
      case 7:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_unsigned_long += (*filtre).LectureUnsignedLong(i) * tmp_vect.LectureUnsignedLong(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureUnsignedLong(x,tmp_unsigned_long);
	break;
      case 8:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_float += (*filtre).LectureFloat(i) * tmp_vect.LectureFloat(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureFloat(x,tmp_float);
	break;
      case 9:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_double += (*filtre).LectureDouble(i) * tmp_vect.LectureDouble(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureDouble(x,tmp_double);
	break;
      case 10:
	for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	  tmp_long_double += (*filtre).LectureLongDouble(i) * tmp_vect.LectureLongDouble(x+i-((*filtre).Naxis1()-1)/2);
	}
	EcritureLongDouble(x,tmp_long_double);
	break;
      default :
	cerr << "Libbm, erreur dans Vecteur::Convolue : tentative de convolution avec un type de donnees inconnu.";
      }

    }
    return(0);
  }
}

