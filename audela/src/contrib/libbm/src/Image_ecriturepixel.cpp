/*----------------------------------------------*/
/*                 Classe Image                 */
/*           definition des fonctions           */
/*           fonctions ecriture_pixel            */
/*----------------------------------------------*/


// inclusion fichiers d'en-t�te generaux
#include <iostream>

// inclusion fichiers d'en-t�te locaux
#include "Image.h"

using namespace std;

// fonctions de la classe Image

unsigned char Image::EcritureBool(unsigned long coord1, unsigned long coord2, bool valeur) {

  if (adresse_type != 1) {
    cerr << "Libbm, erreur dans Image::EcritureBool : essai d'ecriture dans une image de type " << adresse_type << " sous le format bool.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureBool : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_bool[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureChar(unsigned long coord1, unsigned long coord2, char valeur) {

  if (adresse_type != 2) {
    cerr << "Libbm, erreur dans Image::EcritureChar : essai d'ecriture dans une image de type " << adresse_type << " sous le format char.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureChar : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_char[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureUnsignedChar(unsigned long coord1, unsigned long coord2, unsigned char valeur) {

  if (adresse_type != 3) {
    cerr << "Libbm, erreur dans Image::EcritureUnsignedChar : essai d'ecriture dans une image de type " << adresse_type << " sous le format unsigned char.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureUnsignedChar : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_unsigned_char[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureShort(unsigned long coord1, unsigned long coord2, short valeur) {

  if (adresse_type != 4) {
    cerr << "Libbm, erreur dans Image::EcritureShort : essai d'ecriture dans une image de type " << adresse_type << " sous le format short.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureShort : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_short[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureUnsignedShort(unsigned long coord1, unsigned long coord2, unsigned short valeur) {

  if (adresse_type != 5) {
    cerr << "Libbm, erreur dans Image::EcritureUnsignedShort : essai d'ecriture dans une image de type " << adresse_type << " sous le format unsigned short.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureUnsignedShort : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_unsigned_short[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureLong(unsigned long coord1, unsigned long coord2, long valeur) {

  if (adresse_type != 6) {
    cerr << "Libbm, erreur dans Image::EcritureLong : essai d'ecriture dans une image de type " << adresse_type << " sous le format long.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureLong : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_long[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureUnsignedLong(unsigned long coord1, unsigned long coord2, unsigned long valeur) {

  if (adresse_type != 7) {
    cerr << "Libbm, erreur dans Image::EcritureUnsignedLong : essai d'ecriture dans une image de type " << adresse_type << " sous le format unsigned long.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureUnsignedLong : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_unsigned_long[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureFloat(unsigned long coord1, unsigned long coord2, float valeur) {

  if (adresse_type != 8) {
    cerr << "Libbm, erreur dans Image::EcritureFloat : essai d'ecriture dans une image de type " << adresse_type << " sous le format float.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureFloat : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_float[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureDouble(unsigned long coord1, unsigned long coord2, double valeur) {

  if (adresse_type != 9) {
    cerr << "Libbm, erreur dans Image::EcritureDouble : essai d'ecriture dans une image de type " << adresse_type << " sous le format double.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureDouble : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_double[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}

unsigned char Image::EcritureLongDouble(unsigned long coord1, unsigned long coord2, long double valeur) {

  if (adresse_type != 10) {
    cerr << "Libbm, erreur dans Image::EcritureLongDouble : essai d'ecriture dans une image de type " << adresse_type << " sous le format long double.";
    return 1;
  } else if ((coord1 >= naxis1) || (coord2 >= naxis2)) {
    cerr << "Libbm, erreur dans Image::EcritureLongDouble : essai d'ecriture d'un pixel hors de l'image.";
    return 1;
  } else {
    adresse_long_double[coord2*naxis1+coord1] = valeur;
    return 0;
  }
}
