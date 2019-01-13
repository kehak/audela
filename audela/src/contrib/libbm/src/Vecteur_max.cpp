/*----------------------------------------------*/
/*                 Classe Vecteur                 */
/*           definition des fonctions           */
/*                 fonctions max                */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete generaux
#include <iostream>

// inclusion fichiers d'en-tete locaux
#include "Vecteur.h"


// fonctions de la classe Vecteur

bool Vecteur::MaxBool() {
  bool tmp_max = LectureBool(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureBool(x) > tmp_max) {
        tmp_max = LectureBool(x);
      }
  }
  return tmp_max;
}


char Vecteur::MaxChar() {
  char tmp_max = LectureChar(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureChar(x) > tmp_max) {
        tmp_max = LectureChar(x);
      }
  }
  return tmp_max;
}


unsigned char Vecteur::MaxUnsignedChar() {
  unsigned char tmp_max = LectureUnsignedChar(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureUnsignedChar(x) > tmp_max) {
        tmp_max = LectureUnsignedChar(x);
      }
  }
  return tmp_max;
}


short Vecteur::MaxShort() {
  short tmp_max = LectureShort(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureShort(x) > tmp_max) {
        tmp_max = LectureShort(x);
      }
  }
  return tmp_max;
}


unsigned short Vecteur::MaxUnsignedShort() {
  unsigned short tmp_max = LectureUnsignedShort(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureUnsignedShort(x) > tmp_max) {
        tmp_max = LectureUnsignedShort(x);
      }
  }
  return tmp_max;
}


long Vecteur::MaxLong() {
  long tmp_max = LectureLong(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureLong(x) > tmp_max) {
        tmp_max = LectureLong(x);
      }
  }
  return tmp_max;
}


unsigned long Vecteur::MaxUnsignedLong() {
  unsigned long tmp_max = LectureUnsignedLong(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureUnsignedLong(x) > tmp_max) {
        tmp_max = LectureUnsignedLong(x);
      }
  }
  return tmp_max;
}


float Vecteur::MaxFloat() {
  float tmp_max = LectureFloat(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureFloat(x) > tmp_max) {
        tmp_max = LectureFloat(x);
      }
  }
  return tmp_max;
}


double Vecteur::MaxDouble() {
  double tmp_max = LectureDouble(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureDouble(x) > tmp_max) {
        tmp_max = LectureDouble(x);
      }
  }
  return tmp_max;
}


long double Vecteur::MaxLongDouble() {
  long double tmp_max = LectureLongDouble(0);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
      if (LectureLongDouble(x) > tmp_max) {
        tmp_max = LectureLongDouble(x);
      }
  }
  return tmp_max;
}


