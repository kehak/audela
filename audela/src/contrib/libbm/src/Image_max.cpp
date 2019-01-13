/*----------------------------------------------*/
/*                 Classe Image                 */
/*           definition des fonctions           */
/*                 fonctions max                */
/*----------------------------------------------*/


// inclusion fichiers d'en-tête generaux
#include <iostream>


// inclusion fichiers d'en-tête locaux
#include "Image.h"


// fonctions de la classe Image

bool Image::MaxBool(bool* retour)
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  bool tmp_max = LectureBool(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureBool(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureBool(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


char Image::MaxChar(bool* retour) 
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  char tmp_max = LectureChar(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureChar(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureChar(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


unsigned char Image::MaxUnsignedChar(bool* retour)
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  unsigned char tmp_max = LectureUnsignedChar(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureUnsignedChar(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureUnsignedChar(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


short Image::MaxShort(bool* retour) 
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  short tmp_max = LectureShort(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureShort(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureShort(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


unsigned short Image::MaxUnsignedShort(bool* retour) 
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  unsigned short tmp_max = LectureUnsignedShort(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureUnsignedShort(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureUnsignedShort(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


long Image::MaxLong(bool* retour)
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  long tmp_max = LectureLong(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureLong(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureLong(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


unsigned long Image::MaxUnsignedLong(bool* retour)
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  unsigned long tmp_max = LectureUnsignedLong(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureUnsignedLong(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureUnsignedLong(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


float Image::MaxFloat(bool* retour)
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  float tmp_max = LectureFloat(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureFloat(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureFloat(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


double Image::MaxDouble(bool* retour)
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  double tmp_max = LectureDouble(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureDouble(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureDouble(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


long double Image::MaxLongDouble(bool* retour)
{
  /* --- variables locales */
  bool retour_tmp = 0;

  *retour = 0;
  long double tmp_max = LectureLongDouble(0,0,retour);
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureLongDouble(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureLongDouble(x,y,&retour_tmp);
        if (retour_tmp == 1) *retour = 1;
      } else {
        if (retour_tmp == 1) *retour = 1;
      }
    }
  }
  return tmp_max;
}


