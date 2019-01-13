/*----------------------------------------------*/
/*                 Classe Image                 */
/*           definition des fonctions           */
/*           fonctions de traitement            */
/*----------------------------------------------*/


// inclusion fichiers d'en-t�te generaux
#include <iostream>

// inclusion fichiers d'en-t�te locaux
#include "Image.h"

using namespace std;

// fonctions de la classe Image

// ******************* pixel_hard2visu *******************
// pixel_hard2visu
// convertit la valeur pixel brute en valeur pixel 
// "affichage" d'apr�s la fonction de transfert.
// *******************************************************

unsigned char pixel_hard2visu(double pixel_hard, double seuil_bas, double seuil_haut, Vecteur *fonction_transfert, double *pixel_visu)
{
  /* --- 1er cas : le pixel est compl�tement noir sur l'image */
  if (pixel_hard<=seuil_bas) {
    *pixel_visu=seuil_bas+((seuil_haut-seuil_bas) * (*fonction_transfert).LectureDouble(0))/255;
    return OK;
  } else {
    /* --- 2nd cas : le pixel est compl�tement blanc sur l'image */
    /* --- sa valeur n'est pas non plus modifiee */
    if (pixel_hard>=seuil_haut) {
      *pixel_visu=seuil_bas+((seuil_haut-seuil_bas) * (*fonction_transfert).LectureDouble(255))/255;
      return OK;
    } else {
      /* --- dernier cas : la valeur du pixel est modifiee par la */
      /* --- fonction de transfert. */
      int k = (int)(255*((pixel_hard-seuil_bas)/(seuil_haut-seuil_bas)));
      *pixel_visu=seuil_bas+((seuil_haut-seuil_bas) * (*fonction_transfert).LectureDouble(k))/255;
      return OK;
    }
  }
}

// ****************** image_hard2visu *********************
// Image::hard2visu
// transforme une image brute en image "affichage"
// d'apr�s la fonction de transfert.
// ********************************************************
int Image::hard2visu(double seuil_haut, double seuil_bas, Vecteur *fonction_transfert)
{
  /* --- variables locales */
  double pixel_hard,pixel_visu;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_hard = LectureFloat(x, y, &retour);
      pixel_hard2visu (pixel_hard, seuil_bas, seuil_haut, fonction_transfert, &pixel_visu);
      EcritureFloat(x, y, pixel_visu);
    }
  }
  return(retour);
}


// ****************** soustrait *********************
// soustrait
// Soustrait l'image 2 a l'image 1, le resultat ecrase l'image 1.
// ********************************************************
unsigned char Image::Soustrait(Image* image2)
{
  /* --- variables locales */
  float pixel_1,pixel_2,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_2 = (*image2).LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_result=pixel_1-pixel_2;
      if (EcritureFloat(x, y, pixel_result) > 0) return(1);
    }
  }
  return(0);
}


// ****************** ajoute *********************
// ajoute
// Ajoute l'image 2 a l'image 1, le resultat ecrase l'image 1.
// ********************************************************
unsigned char Image::Ajoute(Image* image2)
{
  /* --- variables locales */
  double pixel_1,pixel_2,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x,y,&retour);
      if (retour == 1) return(1);
      pixel_2 = (*image2).LectureFloat(x,y,&retour);
      if (retour == 1) return(1);
      pixel_result=pixel_1+pixel_2;
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// ****************** ajoute_facteur *********************
// ajoute_facteur
// image1 = image1 + facteur * image2
// ********************************************************
unsigned char Image::AjouteFacteur(Image* image2, double facteur)
{
  /* --- variables locales */
  double pixel_1,pixel_2,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_2 = (*image2).LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_result= pixel_1 + facteur * pixel_2;
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// *******************      abs      **********************
// abs
// image1 = abs(image1)
// ********************************************************
unsigned char Image::Abs()
{
  /* --- variables locales */
  float pixel_1,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_result= fabs(pixel_1);
      if (EcritureFloat(x, y, pixel_result) != 0) return(1);
    }
  }
  return(0);
}


// ****************** multiplie *********************
// multiplie
// Multiplie l'image 2 par l'image 1, le resultat ecrase l'image 1.
// ********************************************************
unsigned char Image::Multiplie(Image* image2)
{
  /* --- variables locales */
  double pixel_1,pixel_2,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y ,&retour);
      if (retour == 1) return(1);
      pixel_2 = (*image2).LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_result=pixel_1*pixel_2;
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// ****************** multiplie_ajoute *********************
// multiplie_ajoute
// Multiplie l'image 2 par l'image 1, le resultat ecrase l'image courante.
// ********************************************************
unsigned char Image::MultiplieAjoute(Image* image1, Image* image2)
{
  /* --- variables locales */
  double pixel_1,pixel_2,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = (*image1).LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_2 = (*image2).LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_result=pixel_1*pixel_2;
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// ****************** divise *********************
// divise
// Divise l'image 1 par l'image 2, le resultat ecrase l'image 1.
// ********************************************************
unsigned char Image::Divise(Image* image2)
{
  /* --- variables locales */
  double pixel_1,pixel_2,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_2 = (*image2).LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_result=pixel_1/pixel_2;
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// ****************** carre *********************
// carre
// Prend le carre de l'image 1, le resultat ecrase l'image 1.
// ********************************************************
unsigned char Image::Carre()
{
  /* --- variables locales */
  double pixel_1,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y, &retour);
      pixel_result=pixel_1*pixel_1;
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// ****************** carre_ajoute *********************
// carre_ajoute
// Prend le carre de l'image 1, le resultat ecrase l'image courante.
// ********************************************************
unsigned char Image::CarreAjoute(Image* image1)
{
  /* --- variables locales */
  double pixel_1,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = (*image1).LectureFloat(x, y, &retour);
      pixel_result=pixel_1*pixel_1;
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// ****************** racine_carree *********************
// racine_carree
// Prend la racine carree de l'image 1, le resultat ecrase l'image 1.
// ********************************************************
unsigned char Image::RacineCarree()
{
  /* --- variables locales */
  double pixel_1,pixel_result;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y, &retour);
      pixel_result=sqrt(pixel_1);
      EcritureFloat(x, y, pixel_result);
    }
  }
  return(retour);
}


// ****************** marche *********************
// marche
// Retourne la fonction de Heavyside de l'image
// ********************************************************
unsigned char Image::Marche()
{
  /* --- variables locales */
  double pixel_1;
  bool retour = 0;

  /* --- procedure principale */
  for (unsigned long x=0 ; x<naxis1 ; x++) {
    for (unsigned long y=0 ; y<naxis2 ; y++) {

      pixel_1 = LectureFloat(x, y, &retour);
      if (pixel_1 > 0) 
        {
	  EcritureFloat(x, y, 1);
	} else {
	  EcritureFloat(x, y, -1);
        }
    }
  }
  return(retour);
}


// ****************** Dxx *********************
// Dxx
// Derivee seconde suivant l'axe 1
// ********************************************************
unsigned char Image::Dxx(Image* image1)
{
  /* --- variables locales */
  double pixel_1, pixel_2, pixel_3, pixel_result;
  bool retour = 0;
  unsigned long x, y;

  /* --- procedure principale */
  for (y=0 ; y<naxis2 ; y++) {
    pixel_2 = (*image1).LectureFloat(0, y, &retour);
    if (retour == 1) return 1;
    pixel_3 = (*image1).LectureFloat(1, y, &retour);
    if (retour == 1) return 1;
    pixel_result = pixel_3 - pixel_2;
    EcritureFloat(0, y, pixel_result);
  }

  for (x=1 ; x<(naxis1-1) ; x++) {
    for (y=0 ; y<naxis2 ; y++) {

      pixel_1 = (*image1).LectureFloat(x-1, y, &retour);
      if (retour == 1) return 1;
      pixel_2 = (*image1).LectureFloat(x, y, &retour);
      if (retour == 1) return 1;
      pixel_3 = (*image1).LectureFloat(x+1, y, &retour);
      if (retour == 1) return 1;
      pixel_result = pixel_3 - 2 * pixel_2 + pixel_1;
      EcritureFloat(x, y, pixel_result);
    }
  }

  for (y=0 ; y<naxis2 ; y++) {

    pixel_1 = (*image1).LectureFloat(naxis1 - 2, y, &retour);
    if (retour == 1) return 1;
    pixel_2 = (*image1).LectureFloat(naxis1 - 1, y, &retour);
    if (retour == 1) return 1;
    pixel_result = - pixel_2 + pixel_1;
    EcritureFloat(naxis1-1, y, pixel_result);
  }

  return retour;
}


// ****************** Dyy *********************
// Dyy
// Derivee seconde suivant l'axe 2
// ********************************************************
unsigned char Image::Dyy(Image* image1)
{
  /* --- variables locales */
  double pixel_1, pixel_2, pixel_3, pixel_result;
  bool retour = 0;
  unsigned long x, y;

  /* --- procedure principale */
  for (x=0 ; x<naxis1 ; x++) {
    pixel_2 = (*image1).LectureFloat(x, 0, &retour);
    if (retour == 1) return(1);
    pixel_3 = (*image1).LectureFloat(x, 1, &retour);
    if (retour == 1) return(1);
    pixel_result = pixel_3 - pixel_2;
    EcritureFloat(x, 0, pixel_result);
  }

  for (x=0 ; x<naxis1 ; x++) {
    for (y=1 ; y<(naxis2-1) ; y++) {

      pixel_1 = (*image1).LectureFloat(x, y-1, &retour);
      if (retour == 1) return(1);
      pixel_2 = (*image1).LectureFloat(x, y, &retour);
      if (retour == 1) return(1);
      pixel_3 = (*image1).LectureFloat(x, y+1, &retour);
      if (retour == 1) return(1);
      pixel_result = pixel_3 - 2 * pixel_2 + pixel_1;
      EcritureFloat(x, y, pixel_result);
    }
  }

  for (x=0 ; x<naxis1 ; x++) {

    pixel_1 = (*image1).LectureFloat(x, naxis2 - 2, &retour);
    if (retour == 1) return(1);
    pixel_2 = (*image1).LectureFloat(x, naxis2 - 1, &retour);
    if (retour == 1) return(1);
    pixel_result = - pixel_2 + pixel_1;
    EcritureFloat(x, naxis2 - 1, pixel_result);
  }

  return(retour);
}


// ******** Convolue ***************

unsigned char Image::Convolue(Image* filtre) {

  // Initialisation variables locales
  Image tmp_image;
  bool retour = 0, retour2 = 0;
  unsigned long i, j;

  // On teste que les deux images sont de m�me type
  if (adresse_type != (*filtre).AdresseType()) {
    cerr << "Libbm, erreur dans Image::Convolue : ne peut convoluer des images de types differents.";
    return(1);
  } else if ((double((*filtre).Naxis1())-1)/2 != ((*filtre).Naxis1()-1)/2) {
    cerr << "Libbm, erreur dans Image::Convolue : le filtre doit avoir une dimension en x impaire";
    return(1);
  } else if ((double((*filtre).Naxis2())-1)/2 != ((*filtre).Naxis2()-1)/2) {
    cerr << "Libbm, erreur dans Image::Convolue : le filtre doit avoir une dimension en y impaire";
    return(1);
  } else {
    if (CopieVers(&tmp_image) != 0) return(1);
    for (unsigned long x=((*filtre).Naxis1()-1)/2 ; x<naxis1-((*filtre).Naxis1()-1)/2 ; x++) {
      for (unsigned long y=((*filtre).Naxis2()-1)/2 ; y<naxis2-((*filtre).Naxis2()-1)/2 ; y++) {
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
            for (j=0 ; j<(*filtre).Naxis2() ; j++) {
              tmp_bool += (*filtre).LectureBool(i,j,&retour) * tmp_image.LectureBool((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
            }
          }
	  if (EcritureBool(x,y,tmp_bool) != 0) return(1);
          break;
        case 2:
          for (i=0 ; i<(*filtre).Naxis1() ; i++) {
            for (j=0 ; j<(*filtre).Naxis2() ; j++) {
              tmp_char += (*filtre).LectureChar(i,j,&retour) * tmp_image.LectureChar((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
          }
	  if (EcritureChar(x,y,tmp_char) != 0) return(1);
	  break;
	case 3:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_unsigned_char += (*filtre).LectureUnsignedChar(i,j,&retour) * tmp_image.LectureUnsignedChar((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureUnsignedChar(x,y,tmp_unsigned_char) != 0) return(1);
	  break;
	case 4:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_short += (*filtre).LectureShort(i,j,&retour) * tmp_image.LectureShort((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureShort(x,y,tmp_short) != 0) return(1);
	  break;
	case 5:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_unsigned_short += (*filtre).LectureUnsignedShort(i,j,&retour) * tmp_image.LectureUnsignedShort((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureUnsignedShort(x,y,tmp_unsigned_short) != 0) return(1);
	  break;
	case 6:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_long += (*filtre).LectureLong(i,j,&retour) * LectureLong((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureLong(x,y,tmp_long) != 0) return(1);
	  break;
	case 7:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_unsigned_long += (*filtre).LectureUnsignedLong(i,j,&retour) * tmp_image.LectureUnsignedLong((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureUnsignedLong(x,y,tmp_unsigned_long) != 0) return(1);
	  break;
	case 8:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_float += (*filtre).LectureFloat(i,j,&retour) * tmp_image.LectureFloat((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureFloat(x,y,tmp_float) != 0) return(1);
	  break;
	case 9:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_double += (*filtre).LectureDouble(i,j,&retour) * tmp_image.LectureDouble((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureDouble(x,y,tmp_double) != 0) return(1);
	  break;
	case 10:
	  for (i=0 ; i<(*filtre).Naxis1() ; i++) {
	    for (j=0 ; j<(*filtre).Naxis2() ; j++) {
	      tmp_long_double += (*filtre).LectureLongDouble(i,j,&retour) * tmp_image.LectureLongDouble((x+i)-((*filtre).Naxis1()-1)/2,(y+j)-((*filtre).Naxis2()-1)/2,&retour2);
              if (retour == 1) return(1);
              if (retour2 == 1) return(1);
	    }
	  }
	  if (EcritureLongDouble(x,y,tmp_long_double) != 0) return(1);
	  break;
	default :
	  cerr << "Libbm, erreur dans Image::Convolue : tentative de convolution avec un type de donnees inconnu.";
          return(1);
        }

      }
    }
    return(0);
  }
}


// ****************** Disque *********************
// disque
// L'image doit etre initialement binaire carree
// Alors cette fonction la transforme en un disque binaire
// ********************************************************
unsigned char Image::Disque()
{
  /* --- procedure principale */
  if (Naxis1() != Naxis2()) {
    cerr << "Libbm, erreur dans Image::Disque : il faut que l'image initiale soit carree.";
    return(1);
  } else if ((double(Naxis1())-1)/2 != (Naxis1()-1)/2) {
    cerr << "Libbm, erreur dans Image::Disque : il faut que l'image initiale ait des dimensions impaires.";
    return(1);
  } else {
    for (unsigned long x=0 ; x<naxis1 ; x++) {
      for (unsigned long y=0 ; y<naxis2 ; y++) {
        if ( (pow((double(x)-(double(Naxis1())-1)/2),2)+pow((double(y)-(double(Naxis2())-1)/2),2)) > (pow(((double(Naxis1())-1)/2),2)) ) {
        if (EcritureBool(x, y, 0) != 0) return(1);
	} else {
        if (EcritureBool(x, y, 1) != 0) return(1);
	}
      }
    }
    return(0);
  }
}

