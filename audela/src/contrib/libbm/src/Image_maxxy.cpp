/*----------------------------------------------*/
/*                 Classe Image                 */
/*           definition des fonctions           */
/*                fonctions maxxy               */
/*----------------------------------------------*/


// inclusion fichiers d'en-tête generaux
#include <iostream>

// inclusion fichiers d'en-tête locaux
#include "Image.h"


// fonctions de la classe Image

unsigned char Image::MaxXYBool(bool* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  bool tmp_max = LectureBool(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureBool(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureBool(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYChar(char* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  char tmp_max = LectureChar(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureChar(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureChar(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYUnsignedChar(unsigned char* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  unsigned char tmp_max = LectureUnsignedChar(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureUnsignedChar(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureUnsignedChar(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYShort(short* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  short tmp_max = LectureShort(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureShort(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureShort(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYUnsignedShort(unsigned short* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  unsigned short tmp_max = LectureUnsignedShort(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureUnsignedShort(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureUnsignedShort(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYLong(long* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  long tmp_max = LectureLong(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureLong(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureLong(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYUnsignedLong(unsigned long* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  unsigned long tmp_max = LectureUnsignedLong(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureUnsignedLong(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureUnsignedLong(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYFloat(float* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  float tmp_max = LectureFloat(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureFloat(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureFloat(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYDouble(double* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  double tmp_max = LectureDouble(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureDouble(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureDouble(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


unsigned char Image::MaxXYLongDouble(long double* max, unsigned long* x_max, unsigned long* y_max) 
{
  /* --- variables locales */
  bool retour = 0, retour_tmp = 0;

  long double tmp_max = LectureLongDouble(0,0,&retour);
  unsigned long tmp_x_max = 0;
  unsigned long tmp_y_max = 0;
  for (unsigned long x = 0 ; x<naxis1 ; x++) {
    for (unsigned long y = 0 ; y<naxis2 ; y++) {
      if (LectureLongDouble(x,y,&retour_tmp) > tmp_max) {
        tmp_max = LectureLongDouble(x,y,&retour_tmp);
        if (retour_tmp == 1) retour = 1;
        tmp_x_max = x;
        tmp_y_max = y;
      } else {
        if (retour_tmp == 1) retour = 1;
      }
    }
  }
  *max = tmp_max;
  *x_max = tmp_x_max;
  *y_max = tmp_y_max;
  return(retour);
}


