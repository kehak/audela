/*----------------------------------------------*/
/*                 Classe Vecteur                 */
/*           definition des fonctions           */
/*           fonctions ecriture_pixel            */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete generaux
#include <iostream>
#include <stdlib.h>

using namespace std;

// inclusion fichiers d'en-tete locaux
#include "Vecteur.h"


// fonctions de la classe Vecteur

unsigned char Vecteur::EcritureBool(unsigned long coord1, bool valeur) {
  if (adresse_type != 1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureBool : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format bool.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureBool : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_bool[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureChar(unsigned long coord1, char valeur) {
  if (adresse_type != 2) {
    cerr << "Libbm, erreur dans Vecteur::EcritureChar : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format char.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureChar : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_char[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureUnsignedChar(unsigned long coord1, unsigned char valeur) {
  if (adresse_type != 3) {
    cerr << "Libbm, erreur dans Vecteur::EcritureUnsignedChar : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format unsigned char.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureUnsignedChar : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_unsigned_char[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureShort(unsigned long coord1, short valeur) {
  if (adresse_type != 4) {
    cerr << "Libbm, erreur dans Vecteur::EcritureShort : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format short.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureShort : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_short[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureUnsignedShort(unsigned long coord1, unsigned short valeur) {
  if (adresse_type != 5) {
    cerr << "Libbm, erreur dans Vecteur::EcritureUnsignedShort : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format unsigned short.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureUnsignedShort : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_unsigned_short[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureLong(unsigned long coord1, long valeur) {
  if (adresse_type != 6) {
    cerr << "Libbm, erreur dans Vecteur::EcritureLong : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format long.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureLong : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_long[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureUnsignedLong(unsigned long coord1, unsigned long valeur) {
  if (adresse_type != 7) {
    cerr << "Libbm, erreur dans Vecteur::EcritureUnsignedLong : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format unsigned long.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureUnsignedLong : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_unsigned_long[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureFloat(unsigned long coord1, float valeur) {
  if (adresse_type != 8) {
    cerr << "Libbm, erreur dans Vecteur::EcritureFloat : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format float.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureFloat : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_float[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureDouble(unsigned long coord1, double valeur) {
  if (adresse_type != 9) {
    cerr << "Libbm, erreur dans Vecteur::EcritureDouble : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format double.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureDouble : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_double[coord1] = valeur;
    return(0);
  }
}

unsigned char Vecteur::EcritureLongDouble(unsigned long coord1, long double valeur) {
  if (adresse_type != 10) {
    cerr << "Libbm, erreur dans Vecteur::EcritureLongDouble : essai d'ecriture dans un vecteur de type " << adresse_type << " sous le format long double.";
    exit(1);
  } else if (coord1 >= naxis1) {
    cerr << "Libbm, erreur dans Vecteur::EcritureLongDouble : essai d'ecriture d'un pixel hors de l'image.";
    exit(1);
  } else {
    adresse_long_double[coord1] = valeur;
    return(0);
  }
}
