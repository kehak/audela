/*----------------------------------------------*/
/*                 Classe Vecteur                 */
/*           definition des fonctions           */
/*           fonctions lecture_pixel            */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete generaux
#include <iostream>
#include <stdlib.h>

using namespace std;

// inclusion fichiers d'en-tete locaux
#include "Vecteur.h"


// fonctions de la classe Vecteur

long double Vecteur::Lecture(unsigned long coord1) {
  switch (adresse_type) {
  case 1 :
    return LectureBool(coord1);
    break;
  case 2 :
    return LectureChar(coord1);
    break;
  case 3 :
    return LectureUnsignedChar(coord1);
    break;
  case 4 :
    return LectureShort(coord1);
    break;
  case 5 :
    return LectureUnsignedShort(coord1);
    break;
  case 6 :
    return LectureLong(coord1);
    break;
  case 7 :
    return LectureUnsignedLong(coord1);
    break;
  case 8 :
    return LectureFloat(coord1);
    break;
  case 9 :
    return LectureDouble(coord1);
    break;
  case 10 :
    return LectureLongDouble(coord1);
    break;
  default :
    cerr << "Libbm, erreur dans Vecteur::Lecture : essai de lecture d'un type de pixel inconnu.";
    exit(1);
  }
}


bool Vecteur::LectureBool(unsigned long coord1) {
  if (adresse_type != 1) {
    cerr << "Libbm, erreur dans Vecteur::LectureBool : essai de lecture d'une image de type " << adresse_type << " sous le format bool.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureBool : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_bool[coord1];
  }
}


char Vecteur::LectureChar(unsigned long coord1) {
  if (adresse_type != 2) {
    cerr << "Libbm, erreur dans Vecteur::LectureChar : essai de lecture d'une image de type " << adresse_type << " sous le format char.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureChar : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_char[coord1];
  }
}


unsigned char Vecteur::LectureUnsignedChar(unsigned long coord1) {
  if (adresse_type != 3) {
    cerr << "Libbm, erreur dans Vecteur::LectureUnsignedChar : essai de lecture d'une image de type " << adresse_type << " sous le format unsigned char.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureUnsignedChar : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_unsigned_char[coord1];
  }
}


short Vecteur::LectureShort(unsigned long coord1) {
  if (adresse_type != 4) {
    cerr << "Libbm, erreur dans Vecteur::LectureShort : essai de lecture d'une image de type " << adresse_type << " sous le format short.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, Eerreur dans Vecteur::LectureShort : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_short[coord1];
  }
}


unsigned short Vecteur::LectureUnsignedShort(unsigned long coord1) {
  if (adresse_type != 5) {
    cerr << "Libbm, erreur dans Vecteur::LectureUnsignedShort : essai de lecture d'une image de type " << adresse_type << " sous le format unsigned short.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureUnsignedShort : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_unsigned_short[coord1];
  }
}


long Vecteur::LectureLong(unsigned long coord1) {
  if (adresse_type != 6) {
    cerr << "Libbm, erreur dans Vecteur::LectureLong : essai de lecture d'une image de type " << adresse_type << " sous le format long.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureLong : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_long[coord1];
  }
}


unsigned long Vecteur::LectureUnsignedLong(unsigned long coord1) {
  if (adresse_type != 7) {
    cerr << "Libbm, erreur dans Vecteur::LectureUnsignedLong : essai de lecture d'une image de type " << adresse_type << " sous le format unsigned long.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureUnsignedLong : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_unsigned_long[coord1];
  }
}


float Vecteur::LectureFloat(unsigned long coord1) {
  if (adresse_type != 8) {
    cerr << "Libbm, erreur dans Vecteur::LectureFloat : essai de lecture d'une image de type " << adresse_type << " sous le format bool.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureFloat : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_float[coord1];
  }
}


double Vecteur::LectureDouble(unsigned long coord1) {
  if (adresse_type != 9) {
    cerr << "Libbm, erreur dans Vecteur::LectureDouble : essai de lecture d'une image de type " << adresse_type << " sous le format double.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureDouble : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_double[coord1];
  }
}


long double Vecteur::LectureLongDouble(unsigned long coord1) {
  if (adresse_type != 10) {
    cerr << "Libbm, erreur dans Vecteur::LectureLongDouble : essai de lecture d'une image de type " << adresse_type << " sous le format long double.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::LectureLongDouble : essai de lecture d'un pixel hors de l'image.";
    exit(1);
  } else {
    return adresse_long_double[coord1];
  }
}

