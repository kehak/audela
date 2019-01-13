/*----------------------------------------------*/
/*                 Classe Vecteur                 */
/*           definition des fonctions           */
/*                fonctions maxxy               */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete generaux
#include <iostream>

// inclusion fichiers d'en-tete locaux
#include "Vecteur.h"


// fonctions de la classe Vecteur

unsigned char Vecteur::MaxXBool(bool* max, unsigned long* x_max) {
  bool tmp_max = LectureBool(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureBool(x) > tmp_max) {
      tmp_max = LectureBool(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXChar(char* max, unsigned long* x_max) {
  char tmp_max = LectureChar(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureChar(x) > tmp_max) {
      tmp_max = LectureChar(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXUnsignedChar(unsigned char* max, unsigned long* x_max) {
  unsigned char tmp_max = LectureUnsignedChar(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureUnsignedChar(x) > tmp_max) {
      tmp_max = LectureUnsignedChar(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXShort(short* max, unsigned long* x_max) {
  short tmp_max = LectureShort(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureShort(x) > tmp_max) {
      tmp_max = LectureShort(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXUnsignedShort(unsigned short* max, unsigned long* x_max) {
  unsigned short tmp_max = LectureUnsignedShort(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureUnsignedShort(x) > tmp_max) {
      tmp_max = LectureUnsignedShort(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXLong(long* max, unsigned long* x_max) {
  long tmp_max = LectureLong(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureLong(x) > tmp_max) {
      tmp_max = LectureLong(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXUnsignedLong(unsigned long* max, unsigned long* x_max) {
  unsigned long tmp_max = LectureUnsignedLong(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureUnsignedLong(x) > tmp_max) {
      tmp_max = LectureUnsignedLong(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXFloat(float* max, unsigned long* x_max) {
  float tmp_max = LectureFloat(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureFloat(x) > tmp_max) {
      tmp_max = LectureFloat(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXDouble(double* max, unsigned long* x_max) {
  double tmp_max = LectureDouble(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureDouble(x) > tmp_max) {
      tmp_max = LectureDouble(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


unsigned char Vecteur::MaxXLongDouble(long double* max, unsigned long* x_max) {
  long double tmp_max = LectureLongDouble(0);
  unsigned long tmp_x_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    if (LectureLongDouble(x) > tmp_max) {
      tmp_max = LectureLongDouble(x);
      tmp_x_max = x;
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  return(0);
}


