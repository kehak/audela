// Projet      : AudeLA
// Librairie   : libbm
// Fichier     : bm_c_tcl.cpp 
// Description : Fonctions interfaces entre TCL et C
// =================================================

// inclusion fichiers d'en-t�te locaux
#include "bm_c_tcl.h"
#include "Image.h"


/***************************/
/* Version de la librairie */
/***************************/
int CmdVersionLib(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
  char s[256];
	
  strcpy(s, NUMERO_VERSION);
  Tcl_SetResult(interp,s,TCL_VOLATILE); 
  return TCL_OK;
}


// bool CmdBmLecturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
//   /****************************************************************************/
//   /* Retourne la valeur d'un pixel d'une image presente dans un buffer de AudeLA         */
//   /****************************************************************************/
//   /****************************************************************************/
// {
//   bool result,retour;
//   Tcl_DString dsptr;
//   char s[100];
//   Image image;
//   int numbuf;
//   int x,y;
//   //double valeur;

//   if(argc<4) {
//     sprintf(s,"Usage: %s numbuf x y", argv[0]);
//     Tcl_SetResult(interp,s,TCL_VOLATILE);
//     result = TCL_ERROR;
//   } else {
//     result = TCL_OK;
//     /* --- decode le premier parametre obligatoire ---*/
//     retour = Tcl_GetInt(interp,argv[1],&numbuf);
//     if(retour!=TCL_OK) return retour;
//     /* --- decode le second parametre obligatoire ---*/
//     retour = Tcl_GetInt(interp,argv[2],&x);
//     if(retour!=TCL_OK) return retour;
//     /* --- decode le troisi�me parametre obligatoire ---*/
//     retour = Tcl_GetInt(interp,argv[3],&y);
//     if(retour!=TCL_OK) return retour;
//     /*--- initialise la dynamic string ---*/
//     Tcl_DStringInit(&dsptr);
//     /* --- recherche les infos du tampon image---*/
//     retour = image.AudelaAImage(interp,numbuf);
//     if(retour!=TCL_OK) return retour;
//     /* --- recup�re la valeur du pixel---*/
//     double valeur = image.LectureFloat(x, y, &retour);
//     if(retour!=TCL_OK) return retour;
//     /* --- On met en forme le resultat dans une chaine de caracteres ---*/
//     sprintf(s,"%e",valeur);
//     /* --- on ajoute cette chaine a la dynamic string ---*/
//     Tcl_DStringAppend(&dsptr,s,-1);
//     /* --- a la fin, on envoie le contenu de la dynamic string dans */
//     /* --- le Result qui sera retourne a l'utilisateur. */
//     Tcl_DStringResult(interp,&dsptr);
//     /* --- desaloue la dynamic string. */
//     Tcl_DStringFree(&dsptr);
//   }
//   return result;
// }


// int CmdBmEcriturePixel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
//   /*********************************************/
//   /* Ecrit la valeur d'un pixel d'une image    */
//   /* presente dans un buffer de AudeLA         */
//   /*********************************************/
//   /*********************************************/
// {
//   int result,retour;
//   char s[100];
//   Image image;
//   int numbuf;
//   int x,y;
//   double valeur;

//   result=TCL_ERROR;
//   if(argc<5) {
//     sprintf(s,"Usage: %s numbuf x y valeur", argv[0]);
//     Tcl_SetResult(interp,s,TCL_VOLATILE);
//   } else {
//     /* --- decode le premier parametre obligatoire ---*/
//     retour = Tcl_GetInt(interp,argv[1],&numbuf);
//     if(retour!=TCL_OK) return retour;
//     /* --- decode le second parametre obligatoire ---*/
//     retour = Tcl_GetInt(interp,argv[2],&x);
//     if(retour!=TCL_OK) return retour;
//     /* --- decode le troisi�me parametre obligatoire ---*/
//     retour = Tcl_GetInt(interp,argv[3],&y);
//     if(retour!=TCL_OK) return retour;
//     /* --- decode le quatri�me parametre obligatoire ---*/
//     retour = Tcl_GetDouble(interp,argv[4],&valeur);
//     if(retour!=TCL_OK) return retour;
//     /* --- recherche les infos du tampon image---*/ 
//     image.AttribueTamponAudela(interp,numbuf);
//     /* --- enregistre la valeur du pixel---*/
//     retour = image.EcritureFloat(x, y, valeur);
//     if(retour!=0) return retour;
//     result = TCL_OK;
//   }
//   return result;
// }


int CmdBmMax(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  /****************************************************************************/
  /* Retourne la valeur du mamimum d'une image presente dans un buffer de AudeLA, et ses coordonnees.         */
  /****************************************************************************/
  /****************************************************************************/
{
  unsigned char result, retour;
  Tcl_DString dsptr;
  char s[100];
  Image image;
  int numbuf;
  unsigned long x,y;
  float valeur;

  if(argc<2) {
    sprintf(s,"Usage: %s numbuf", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf);
    if(retour!=TCL_OK) return retour;
    /*--- initialise la dynamic string ---*/
    Tcl_DStringInit(&dsptr);
    /* --- recherche les infos du tampon image---*/ 
    image.AudelaAImage(interp,numbuf);
    /* --- recup�re la valeur du pixel---*/
    retour = image.MaxXYFloat(&valeur, &x, &y);
    if(retour!=0) return retour;
    /* --- On met en forme le resultat dans une chaine de caracteres ---*/
    sprintf(s,"%f",valeur);
    /* --- on ajoute cette chaine a la dynamic string ---*/
    Tcl_DStringAppend(&dsptr,s,-1);
    /* --- On met en forme un espace dans une chaine de caracteres ---*/
    sprintf(s,"%c",' ');
    /* --- on ajoute cette chaine a la dynamic string ---*/
    Tcl_DStringAppend(&dsptr,s,-1);
    /* --- On met en forme le resultat dans une chaine de caracteres ---*/
    sprintf(s,"%lu",x);
    /* --- on ajoute cette chaine a la dynamic string ---*/
    Tcl_DStringAppend(&dsptr,s,-1);
    /* --- On met en forme un espace dans une chaine de caracteres ---*/
    sprintf(s,"%c",' ');
    /* --- on ajoute cette chaine a la dynamic string ---*/
    Tcl_DStringAppend(&dsptr,s,-1);
    /* --- On met en forme le resultat dans une chaine de caracteres ---*/
    sprintf(s,"%lu",y);
    /* --- on ajoute cette chaine a la dynamic string ---*/
    Tcl_DStringAppend(&dsptr,s,-1);
    /* --- a la fin, on envoie le contenu de la dynamic string dans */
    /* --- le Result qui sera retourne a l'utilisateur. */
    Tcl_DStringResult(interp,&dsptr);
    /* --- desaloue la dynamic string. */
    Tcl_DStringFree(&dsptr);
  }
  return result;
}


int CmdBmHard2Visu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Transforme une image par sa fonction de transfert
  //
  // *************************************************
{
  // Variables locales
  int result,retour;
  char s[100];
  Image image;
  int numbuf;
  double seuil_haut,seuil_bas;
  //double *fonction_transfert;
  Vecteur fonction_transfert;
  //int k;
  const char **argvv; // Liste fonction de transfert.
  int argcc; // Nombre d'elements dans la liste de fonction transfert.

  // Procedure principale
  if(argc<5) {
    sprintf(s,"Usage: %s numbuf seuil_haut seuil_bas fonction_transfert", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetDouble(interp,argv[2],&seuil_haut);
    if(retour!=TCL_OK) return retour;
    /* --- decode le troisi�me parametre obligatoire ---*/
    retour = Tcl_GetDouble(interp,argv[3],&seuil_bas);
    if(retour!=TCL_OK) return retour;
    /* --- decode le quatri�me parametre obligatoire ---*/
    // attention, il s'agit d'une liste !
    if(Tcl_SplitList(interp,argv[4],&argcc,&argvv)!=TCL_OK) {
      // sprintf(ligne,"Position struct not valid: must be {x y}");
      retour = TCL_ERROR;
      return retour;
    } else if(argcc!=256) {
      // sprintf(ligne,"Position struct not valid: must be {x y}");
      retour = TCL_ERROR;
      return retour;
    } else {
         
      // On attribue la memoire necessaire au tableau "fonction_transfert"
      fonction_transfert.CreeVectVierge(9,256);

      //if ( (fonction_transfert=new double [257])==NULL) {
      //  retour = TCL_ERROR;
      // a verifier
      //  return retour;
      //  }
      // On remplit ce tableau
      for (int k=0 ; k<256 ; k++) {
        fonction_transfert.EcritureDouble(k,atof(argvv[k]));
      }
    }

    // On renvoie �a sous forme de liste.
    // DecodeListeDouble(interp,liste,fonction_transfert,llength);
    /* --- recherche les infos du tampon image---*/
    //result=tcl_InfoImage(interp,numbuf,&image);
    image.AudelaAImage(interp,numbuf);
    //if(retour!=TCL_OK) return retour;
    /* --- enregistre la valeur du pixel---*/
    //retour=image_hard2visu(image, seuil_haut, seuil_bas, fonction_transfert);
    retour=image.hard2visu(seuil_haut, seuil_bas, &fonction_transfert);
    // On lib�re la memoire necessaire au tableau "fonction_transfert"
    //delete [] fonction_transfert;
    if(retour!=0) return retour;
    /*-- on renvoie le resultat dans le tampon AudeLA --*/
    image.ImageAAudela(interp,numbuf);
  }
  return result;
}


int CmdBmSoustrait(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Soustraction entre deux tampons images
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  Image image1,image2;
  char s[100];

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos des tampons images---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result = image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result = image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;
    /* --- soustraction (image1 = image1 - image2)---*/
    if (image1.Soustrait(&image2) > 0) return(1);
    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmAjoute(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Addition entre deux tampons images
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  Image image1,image2;
  double facteur;
  char s[100];

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos des tampons images---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result=image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- si troisi�me param�tre optionnel ---*/
    if(argc>3) {
      /* --- decode le troisi�me parametre optionnel ---*/
      retour = Tcl_GetDouble(interp,argv[3],&facteur);
      if(retour!=TCL_OK) return retour;
      /* --- somme (image1 = image1 + facteur * image2)---*/
      //retour=ajoute_facteur(image1, image2, facteur);
      retour=image1.AjouteFacteur(&image2, facteur);
    } else {
      /* --- somme (image1 = image1 + image2)---*/
      //retour=ajoute(image1, image2);
      retour=image1.Ajoute(&image2);
    }

    if(retour!=0) return retour;
    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmAbs(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Valeur absolue du tampon image
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,result,retour;
  Image image1;
  char s[100];

  // Procedure principale
  if(argc<2) {
    sprintf(s,"Usage: %s buffer", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- valeur absolue (image1)---*/
    //retour=ajoute(image1, image2);
    retour=image1.Abs();

    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmMultiplie(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Multiplication entre deux tampons images
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  Image image1,image2;
  char s[100];

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos des tampons images---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result=image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;
    /* --- multiplication (image1 = image1 * image2)---*/
    //retour=multiplie(image1, image2);
    retour=image1.Multiplie(&image2);
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmMultiplie_ajoute(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Multiplication entre deux tampons images
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,numbuf3,result,retour;
  Image image1,image2,image3;
  char s[100];

  // Procedure principale
  if(argc<4) {
    sprintf(s,"Usage: %s buffer1 buffer2 buffer3", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;
    /* --- decode le troisi�me parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[3],&numbuf3);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos des tampons images---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result=image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;
    //result=tcl_InfoImage(interp,numbuf3,&image3);
    result=image3.AudelaAImage(interp,numbuf3);
    if(retour!=TCL_OK) return retour;
    /* --- multiplication (image3 = image1 * image2)---*/
    retour=image3.MultiplieAjoute(&image1, &image2);
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmDivise(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Division entre deux tampons images
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  Image image1,image2;
  char s[100];

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos des tampons images---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result=image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;
    /* --- division (image1 = image1 / image2)---*/
    //retour=divise(image1, image2);
    retour=image1.Divise(&image2);
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmCarre(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Carre d'une image
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,result,retour;
  Image image1;
  char s[100];

  // Procedure principale
  if(argc<2) {
    sprintf(s,"Usage: %s buffer", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- carre (image1 = image1 * image1)---*/
    retour=image1.Carre();
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmCarre_ajoute(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Carre d'une image
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  Image image1,image2;
  char s[100];

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos des tampons image---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result=image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- carre (image2 = image1 * image1)---*/
    //retour=carre_ajoute(image1, image2);
    retour=image2.CarreAjoute(&image1);
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmRacine_carree(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Racine carree d'une image
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,result,retour;
  Image image1;
  char s[100];

  // Procedure principale
  if(argc<2) {
    sprintf(s,"Usage: %s buffer", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image---*/
    ///result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- carre (image1 = image1 * image1)---*/
    //retour=racine_carree(image1);
    retour=image1.RacineCarree();
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmMarche(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Fonction de Heavyside sur une image
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,result,retour;
  Image image1;
  char s[100];

  // Procedure principale
  if(argc<2) {
    sprintf(s,"Usage: %s buffer", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- les pixels positifs sont mis � 1 et les negatifs � -1 ---*/
    //retour=marche(image1);
    retour=image1.Marche();
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmDxx(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Derivee seconde suivant l'axe x
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  Image image1,image2;
  char s[100];

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image n�1---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
    
    /* --- recherche les infos du tampon image n�2---*/
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result=image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- derivation ---*/
    //retour=Dxx(image1,image2);
    retour=image2.Dxx(&image1);
    if(retour!=0) return retour;

    /*-- retourne les infos vers le tampon memoire AudeLA --*/
    result=image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmDyy(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Derivee seconde suivant l'axe y
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,result,retour;
  Image image1,image2;
  char s[100];

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s buffer1 buffer2", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;
    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image n�1---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image n�2---*/
    //result=tcl_InfoImage(interp,numbuf2,&image2);
    result=image2.AudelaAImage(interp,numbuf2);
    if(retour!=TCL_OK) return retour;

    /* --- derivation ---*/
    //retour=Dyy(image1,image2);
    retour=image2.Dyy(&image1);
    if(retour!=0) return retour;

    /*-- renvoie le resultat dans AudeLA --*/
    result = image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;
  }
  return result;
}


int CmdBmConvolue(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Convolution de deux images
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,numbuf2,data_type;
  Image image1,image1bis,image2,image2bis;
  char s[100];

  // Procedure principale
  if(argc<4) {
    sprintf(s,"Usage: %s buffer_image buffer_filtre data_type", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    return(TCL_ERROR);
  } else {
    /* --- decode le premier parametre obligatoire ---*/
    if (Tcl_GetInt(interp,argv[1],&numbuf1) != TCL_OK) return(TCL_ERROR);
    /* --- decode le second parametre obligatoire ---*/
    if (Tcl_GetInt(interp,argv[2],&numbuf2) != TCL_OK) return(TCL_ERROR);
    /* --- decode le troisi�me parametre obligatoire ---*/
    if (Tcl_GetInt(interp,argv[3],&data_type) != TCL_OK) return(TCL_ERROR);

    /* --- recherche les infos du tampon image n�1---*/
    if (image1.AudelaAImage(interp,numbuf1) != 0) return(TCL_ERROR);

    /* --- recherche les infos du tampon image n�2---*/
    if (image2.AudelaAImage(interp,numbuf2) != 0) return(TCL_ERROR);

    /* --- convolution ---*/
    switch (data_type) {
    case 8 :
      if (image1.Convolue(&image2) != 0) return(1);
      break;
    case 1 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitBool() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitBool() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    case 2 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitChar() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitChar() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    case 3 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitUnsignedChar() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitUnsignedChar() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    case 4 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitShort() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitShort() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    case 5 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitUnsignedShort() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitUnsignedShort() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    case 6 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitLong() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitLong() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    case 7 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitUnsignedLong() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitUnsignedLong() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    case 9 :
      if (image1bis.CopieDe(&image1) != 0) return(TCL_ERROR);
      if (image2bis.CopieDe(&image2) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitDouble() != 0) return(TCL_ERROR);
      if (image2bis.ConvertitDouble() != 0) return(TCL_ERROR);
      if (image1bis.Convolue(&image2bis) != 0) return(TCL_ERROR);
      if (image1bis.ConvertitFloat() != 0) return(TCL_ERROR);
      if (image1bis.ImageAAudela(interp,numbuf1) != 0) return(TCL_ERROR);
      break;
    default :
      std::cerr << "Libbm, erreur dans CmdBmConvolue : tentative de convolution par un type incorrect";
      return(TCL_ERROR);
    }
  }
  return(TCL_OK);
}


int CmdBmDisque(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Met un disque sur le tampon image (qui doit etre carre)
  //
  // *************************************************
{
  // Variables locales
  int numbuf1,result,retour;
  Image image1,imagetmp;
  char s[100];

  // Procedure principale
  if(argc<2) {
    sprintf(s,"Usage: %s buffer", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[1],&numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- recherche les infos du tampon image---*/
    //result=tcl_InfoImage(interp,numbuf1,&image1);
    result=image1.AudelaAImage(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

    /* --- disque ---*/
    if (imagetmp.CreeTamponVierge(1,image1.Naxis1(),image1.Naxis2()) != 0) return(1);
    retour=imagetmp.Disque();
    if(retour!=0) return retour;
    if (imagetmp.ConvertitFloat() != 0) return(1);
    if (imagetmp.CopieVers(&image1) != 0) return(1);

    /*-- on reecrit les infos dans l'image de destination  --*/
    result=image1.ImageAAudela(interp,numbuf1);
    if(retour!=TCL_OK) return retour;

  }
  return result;
}


/**************************************************/
/* Fonction utilitaires pour interfacer C <-> TCL */
/**************************************************/

int DecodeListeInt(Tcl_Interp *interp, char *list, int *tableau, int *n)
  /*****************************************************************************/
  /* retourne un pointeur (int*) sur les valeurs contenues par la liste Tcl.   */
  /* retourne n, le nombre d'elements.                                         */
  /*                                                                           */
  /*****************************************************************************/
{
  const char **argv=NULL;
  int argc,code;
  int nn,k;
  
  *n=0;
  code=Tcl_SplitList(interp,list,&argc,&argv);
  if (argc<=0) {	 
    return TCL_OK;
  }
  nn=argc;
  for (k=0;k<nn;k++) {
    tableau[k]=atoi(argv[k]);
  }
  Tcl_Free((char *) argv);
  *n=nn;
  return TCL_OK;
}

int DecodeListeDouble(Tcl_Interp *interp, char *list, double *tableau, int *n)
  /*****************************************************************************/
  /* retourne un pointeur (double*) sur les valeurs contenues par la liste Tcl.*/
  /* retourne n, le nombre d'elements.                                         */
  /*                                                                           */
  /*****************************************************************************/
{
  const char **argv=NULL;
  int argc,code;
  int nn,k;
  
  *n=0;
  code=Tcl_SplitList(interp,list,&argc,&argv);
  if (argc<=0) {	 
    return TCL_OK;
  }
  nn=argc;
  for (k=0;k<nn;k++) {
    tableau[k]=atof(argv[k]);
  }
  Tcl_Free((char *) argv);
  *n=nn;
  return TCL_OK;
}


int CmdBmMediane(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
  // *************************************************
  // Calcule la mediane d'une serie d'images
  //
  // *************************************************
{
  // Variables locales
  bool retour;
  int result;
  char s[100];
  const char **argvv; // Liste des buffers.
  int argcc; // Nombre d'elements dans la liste precitee.
  int *liste_numbuf; // Liste des numeros de buffers de la serie d'images.
  int numbuf_mediane;
  Image* liste_images; // Liste des param�tres de la serie d'images.
  Image image_mediane,image_tmp;
  int k;
  double *liste_pixels;
  double valeur;

  // Procedure principale
  if(argc<3) {
    sprintf(s,"Usage: %s liste_buffers numbuf_mediane", argv[0]);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    result = TCL_ERROR;
  } else {
    result = TCL_OK;
    /* --- decode le premier parametre obligatoire ---*/
    // attention, il s'agit d'une liste !
    if(Tcl_SplitList(interp,argv[1],&argcc,&argvv)!=TCL_OK) {
      // sprintf(ligne,"Position struct not valid: must be {x y}");
      retour = TCL_ERROR;
      return retour;
    } else {
      // On attribue la memoire necessaire au tableau "liste_num_buf"
      if ( (liste_numbuf=(int*)calloc(argcc,sizeof(int)))==NULL) {
        retour = TCL_ERROR;
        // a verifier
        return retour;
      }
      // On remplit ce tableau
      for (k=0;k<argcc;k++) {
        liste_numbuf[k]=atoi(argvv[k]);
      }
    }

    /* --- decode le second parametre obligatoire ---*/
    retour = Tcl_GetInt(interp,argv[2],&numbuf_mediane);
    if(retour!=TCL_OK) return retour;


    // On attribue la memoire necessaire au tableau "liste_images"
    if ( (liste_images=(Image*)calloc(argcc,sizeof(Image)))==NULL) {
      retour = TCL_ERROR;
      // a verifier
      return retour;
    }
    // On remplit ce tableau
    for (k=0;k<argcc;k++) {
      result=image_tmp.AudelaAImage(interp,liste_numbuf[k]);
      if(retour!=TCL_OK) return retour;
      liste_images[k]=image_tmp;
    }

    /* --- recherche les infos du tampon image de destination --- */
    /* --- on initialise le tampon image de destination --- */
    // sprintf(s,"buf%d format %lu %lu",numbuf_mediane,liste_images[0].Naxis1(),liste_images[0].Naxis2());
    // Tcl_Eval(interp,s);

    // result=image_mediane.AudelaAImage(interp,numbuf_mediane);
    result=image_mediane.AudelaAImage(interp,liste_numbuf[0]);
    if(retour!=TCL_OK) return retour;

    /* --- procedure principale---*/
    /* --- creation d'une liste des valeurs de pixels --- */
    if ( (liste_pixels=(double*)calloc(argcc,sizeof(double)))==NULL) {
      retour = TCL_ERROR;
      // a verifier
      return retour;
    }

    for (unsigned long x=0 ; x<liste_images[0].Naxis1() ; x++) {
      for (unsigned long y=0 ; y<liste_images[0].Naxis2() ; y++) {        
        for (k=0;k<argcc;k++) {
          valeur = liste_images[k].LectureDouble(x,y,&retour);
          if(retour!=0) return retour;
          liste_pixels[k]=valeur;
	}
        /* --- on calcule la mediane --*/
        gsl_sort(liste_pixels,1,argcc);
        valeur=gsl_stats_median_from_sorted_data(liste_pixels,1,argcc);
        image_mediane.EcritureDouble(x,y,valeur);
      }
    }

    /*-- on reecrit le resultat dans le tampon image AudeLA --*/
    image_mediane.ImageAAudela(interp,numbuf_mediane);

    // On lib�re la memoire utilisee par le tableau "liste_pixels"
    free(liste_pixels);
    // On lib�re la memoire utilisee par le tableau "liste_images"
    free(liste_images);
    // On lib�re la memoire necessaire au tableau "liste_numbuf"
    free(liste_numbuf);
    if(retour!=0) return retour;
  }
  return result;
}



