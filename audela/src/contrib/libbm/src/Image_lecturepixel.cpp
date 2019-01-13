/*----------------------------------------------*/
/*                 Classe Image                 */
/*           definition des fonctions           */
/*           fonctions lecture_pixel            */
/*----------------------------------------------*/


// inclusion fichiers d'en-t�te generaux
#include <iostream>

// inclusion fichiers d'en-t�te locaux
#include "Image.h"

using namespace std;

// fonctions de la classe Image

long double Image::Lecture(unsigned long coord1, unsigned long coord2, bool* result) {
  switch (adresse_type) {
  case 1 :
    return LectureBool(coord1,coord2,result);
    break;
  case 2 :
    return LectureChar(coord1,coord2,result);
    break;
  case 3 :
    return LectureUnsignedChar(coord1,coord2,result);
    break;
  case 4 :
    return LectureShort(coord1,coord2,result);
    break;
  case 5 :
    return LectureUnsignedShort(coord1,coord2,result);
    break;
  case 6 :
    return LectureLong(coord1,coord2,result);
    break;
  case 7 :
    return LectureUnsignedLong(coord1,coord2,result);
    break;
  case 8 :
    return LectureFloat(coord1,coord2,result);
    break;
  case 9 :
    return LectureDouble(coord1,coord2,result);
    break;
  case 10 :
    return LectureLongDouble(coord1,coord2,result);
    break;
  default :
    cerr << "Libbm, erreur dans Image::Lecture : essai de lecture d'un type de pixel inconnu.";
    *result = 1;
    return(1);
  }
}


bool Image::LectureBool(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 1) {
    cerr << "Libbm, erreur dans Image::LectureBool : essai de lecture d'une image de type " << adresse_type << " sous le format bool.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureBool : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_bool[coord2*naxis1+coord1];
  }
}


char Image::LectureChar(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 2) {
    cerr << "Libbm, erreur dans Image::LectureChar : essai de lecture d'une image de type " << adresse_type << " sous le format char.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureChar : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_char[coord2*naxis1+coord1];
  }
}


unsigned char Image::LectureUnsignedChar(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 3) {
    cerr << "Libbm, erreur dans Image::LectureUnsignedChar : essai de lecture d'une image de type " << adresse_type << " sous le format unsigned char.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureUnsignedChar : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_unsigned_char[coord2*naxis1+coord1];
  }
}


short Image::LectureShort(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 4) {
    cerr << "Libbm, erreur dans Image::LectureShort : essai de lecture d'une image de type " << adresse_type << " sous le format short.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, Eerreur dans Image::LectureShort : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_short[coord2*naxis1+coord1];
  }
}


unsigned short Image::LectureUnsignedShort(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 5) {
    cerr << "Libbm, erreur dans Image::LectureUnsignedShort : essai de lecture d'une image de type " << adresse_type << " sous le format unsigned short.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureUnsignedShort : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_unsigned_short[coord2*naxis1+coord1];
  }
}


long Image::LectureLong(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 6) {
    cerr << "Libbm, erreur dans Image::LectureLong : essai de lecture d'une image de type " << adresse_type << " sous le format long.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureLong : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_long[coord2*naxis1+coord1];
  }
}


unsigned long Image::LectureUnsignedLong(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 7) {
    cerr << "Libbm, erreur dans Image::LectureUnsignedLong : essai de lecture d'une image de type " << adresse_type << " sous le format unsigned long.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureUnsignedLong : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_unsigned_long[coord2*naxis1+coord1];
  }
}


float Image::LectureFloat(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 8) {
    cerr << "Libbm, erreur dans Image::LectureFloat : essai de lecture d'une image de type " << adresse_type << " sous le format bool.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureFloat : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_float[coord2*naxis1+coord1];
  }
}


double Image::LectureDouble(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 9) {
    cerr << "Libbm, erreur dans Image::LectureDouble : essai de lecture d'une image de type " << adresse_type << " sous le format double.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_double[coord2*naxis1+coord1];
  }
}


long double Image::LectureLongDouble(unsigned long coord1, unsigned long coord2, bool* result) {

  if (adresse_type != 10) {
    cerr << "Libbm, erreur dans Image::LectureLongDouble : essai de lecture d'une image de type " << adresse_type << " sous le format long double.";
    *result = 1;
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::LectureLongDouble : essai de lecture d'un pixel hors de l'image.";
    *result = 1;
    return 1;
  } else {
    *result = 0;
    return adresse_long_double[coord2*naxis1+coord1];
  }
}

