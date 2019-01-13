/*----------------------------------------------*/
/*                 Classe Image                 */
/*           definition des fonctions           */
/*              fonctions de base               */
/*----------------------------------------------*/


// inclusion fichiers d'en-t�te generaux


// inclusion fichiers d'en-t�te locaux
#include "Image.h"
#include "bm_c_tcl.h"

using namespace std;

// fonctions de la classe Image

Image::Image(void){
  adresse_type = 0;
  adresse_bool = NULL;
  adresse_char = NULL;
  adresse_unsigned_char = NULL;
  adresse_short = NULL;
  adresse_unsigned_short = NULL;
  adresse_long = NULL;
  adresse_unsigned_long = NULL;
  adresse_float = NULL;
  adresse_double = NULL;
  adresse_long_double = NULL;
  // tampon_audela = 0;
  naxis1 = 0;
  naxis2 = 0;
}


Image::~Image(void){
  // On ne desalloue la memoire utilisee par l'image que si c'est un tampon a usage interne et pas un tampon AudeLA
  //if (tampon_audela == 0){
    switch (adresse_type) {
    case 0 :
      break;
    case 1 :
      if (adresse_bool != NULL) {
        delete [] adresse_bool;
        adresse_bool = NULL;
      }
      break;
    case 2 :
      if (adresse_char != NULL) {
        delete [] adresse_char;
        adresse_char = NULL;
      }
      break;
    case 3 :
      if (adresse_unsigned_char != NULL) {
        delete [] adresse_unsigned_char;
        adresse_unsigned_char = NULL;
      }
      break;
    case 4 :
      if (adresse_short != NULL) {
        delete [] adresse_short;
        adresse_short = NULL;
      }
      break;
    case 5 :
      if (adresse_unsigned_short != NULL) {
        delete [] adresse_unsigned_short;
        adresse_unsigned_short = NULL;
      }
      break;
    case 6 :
      if (adresse_long != NULL) {
        delete [] adresse_long;
        adresse_long = NULL;
      }
      break;
    case 7 :
      if (adresse_unsigned_long != NULL) {
        delete [] adresse_unsigned_long;
        adresse_unsigned_long = NULL;
      }
      break;
    case 8 :
      if (adresse_float != NULL) {
        delete [] adresse_float;
        adresse_float = NULL;
      }
      break;
    case 9 :
      if (adresse_double != NULL) {
        delete [] adresse_double;
        adresse_double = NULL;
      }
      break;
    case 10 :
      if (adresse_long_double != NULL) {
        delete [] adresse_long_double;
        adresse_long_double = NULL;
      }
      break;
    default:
      cerr << "Libbm, erreur dans Image::~Image : tentative de desallocation d'un tampon image de type inconnu : " << adresse_type << ".";
    }
    // }
    // tampon_audela = 0;
  naxis1 = 0;
  naxis2 = 0;
}


// unsigned char Image::AttribueTamponAudela(Tcl_Interp *interp, unsigned short numbuf) {

//   unsigned char result,retour;
//   char keyname[10],s[50],lignetcl[50],value_char[100];
//   int ptr,datatype;

//   result = TCL_ERROR;
//   strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");

//   //adresse_type = 9;
//   adresse_type = 8;
//   tampon_audela = numbuf;

//   /* -- recherche l'adresse du pointeur de l'image --*/
//   sprintf(s,"buf%d pointer",numbuf);
//   Tcl_Eval(interp,s);
//   retour = Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptr);
//   if(retour!=TCL_OK) return retour;
//   adresse_float=(float*)ptr;
//   if (adresse_float == NULL) {
//     return(TCL_ERROR);
//   }
//   /* -- recherche le mot cle NAXIS1 dans l'entete FITS --*/
//   strcpy(keyname,"NAXIS1");
//   sprintf(s,lignetcl,numbuf,keyname);
//   Tcl_Eval(interp,s);
//   strcpy(value_char,Tcl_GetStringResult(interp));
//   if (strcmp(value_char,"")==0) {
//     datatype=0;
//   }
//   else {
//     datatype=1;
//   }
//   if (datatype==0) {
//     naxis1=0;
//   } else {
//     naxis1=atoi(value_char);
//   }
//   /* -- recherche le mot cle NAXIS2 dans l'entete FITS --*/
//   strcpy(keyname,"NAXIS2");
//   sprintf(s,lignetcl,numbuf,keyname);
//   Tcl_Eval(interp,s);
//   strcpy(value_char,Tcl_GetStringResult(interp));
//   if (strcmp(value_char,"")==0) {
//     datatype=0;
//   }
//   else {
//     datatype=1;
//   }
//   if (datatype==0) {
//     naxis2=0;
//   } else {
//     naxis2=atoi(value_char);
//   }
//   /* -- recherche le mot cle DATE-OBS dans l'entete FITS --*/
//   /*
//     strcpy(keyname,"DATE-OBS");
//     sprintf(s,lignetcl,numbuf,keyname);
//     Tcl_Eval(interp,s);
//     strcpy(value_char,Tcl_GetStringResult(interp));
//     if (strcmp(value_char,"")==0) {
//     datatype=0;
//     }
//     else {
//     datatype=1;
//     }
//     if (datatype==0) {
//     strcpy(image->dateobs,"");
//     } else {
//     strcpy(image->dateobs,value_char);
//     }
//   */

//   return(TCL_OK);
// }


unsigned char Image::AudelaAImage(Tcl_Interp *interp, unsigned short numbuf) {

  unsigned char result;
  char keyname[10],s[50],lignetcl[50],value_char[100];
  int datatype;

  result = TCL_ERROR;
  strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");

  //adresse_type = 9;
  adresse_type = 8;
  // tampon_audela = numbuf;

  /* -- recherche le mot cle NAXIS1 dans l'entete FITS --*/
  strcpy(keyname,"NAXIS1");
  sprintf(s,lignetcl,numbuf,keyname);
  Tcl_Eval(interp,s);
  strcpy(value_char,Tcl_GetStringResult(interp));
  if (strcmp(value_char,"")==0) {
    datatype=0;
  }
  else {
    datatype=1;
  }
  if (datatype==0) {
    naxis1=1; /* correction AK */
  } else {
    naxis1=atoi(value_char);
  }
  /* -- recherche le mot cle NAXIS2 dans l'entete FITS --*/
  strcpy(keyname,"NAXIS2");
  sprintf(s,lignetcl,numbuf,keyname);
  Tcl_Eval(interp,s);
  strcpy(value_char,Tcl_GetStringResult(interp));
  if (strcmp(value_char,"")==0) {
    datatype=0;
  }
  else {
    datatype=1;
  }
  if (datatype==0) {
    naxis2=1; /* correction AK */
  } else {
    naxis2=atoi(value_char);
  }

  /* -- on attribue un espace memoire pour les pixels de l'image */
  if ((adresse_float = new float [naxis1*naxis2]) == NULL) {
    cerr << "Libbm, erreur dans Image::AudelaAImage : echec d'allocation de memoire.";
    return(1);
  }
  /*-- on recupere les pixels --*/
  //Yassine
  //sprintf(lignetcl,"buf%d getpixels %d",numbuf, (int)adresse_float);
  sprintf(lignetcl,"buf%d getpixels %ld",numbuf, (long)adresse_float);
  if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

  /* -- recherche le mot cle DATE-OBS dans l'entete FITS --*/
  /*
    strcpy(keyname,"DATE-OBS");
    sprintf(s,lignetcl,numbuf,keyname);
    Tcl_Eval(interp,s);
    strcpy(value_char,Tcl_GetStringResult(interp));
    if (strcmp(value_char,"")==0) {
    datatype=0;
    }
    else {
    datatype=1;
    }
    if (datatype==0) {
    strcpy(image->dateobs,"");
    } else {
    strcpy(image->dateobs,value_char);
    }
  */

  return(TCL_OK);
}


unsigned char Image::ImageAAudela(Tcl_Interp *interp, unsigned short numbuf) {

  // unsigned char result,retour;
  char lignetcl[256];
  // char keyname[10],s[50],value_char[100];
  //int ptr,datatype;

  //result = TCL_ERROR;
  //strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");

  /*-- on copie le contenu de l'image dans un tampon AudeLA --*/
  //Yassine
  //sprintf(lignetcl,"buf%d setpixels CLASS_GRAY %d %d  FORMAT_FLOAT COMPRESS_NONE %d",numbuf ,(int)naxis1, (int)naxis2, (int)adresse_float);
  sprintf(lignetcl,"buf%d setpixels CLASS_GRAY %d %d  FORMAT_FLOAT COMPRESS_NONE %ld",numbuf ,(int)naxis1, (int)naxis2, (long)adresse_float);
  if( Tcl_Eval(interp,lignetcl) != TCL_OK  ) { return TCL_ERROR; }

  return(TCL_OK);
}


unsigned char Image::CreeTamponVierge(unsigned char data_type, unsigned long val_naxis1, unsigned long val_naxis2){

  if (adresse_type>0) {

    cerr << "Libbm, erreur dans Image::CreeTamponVierge : essai d'ecrasement d'un tampon image existant.";
    return(1);

  } else {

    adresse_type = data_type;
    // tampon_audela = 0; // superflu en theorie...
    naxis1 = val_naxis1;
    naxis2 = val_naxis2;

    switch (data_type) {
    case 1 :
      if ((adresse_bool = new bool [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureBool(x,y,0) != 0) return(1);
	  }
        }
      }
      break;
    case 2 :
      if ((adresse_char = new char [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureChar(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 3 :
      if ((adresse_unsigned_char = new unsigned char [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureUnsignedChar(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 4 :
      if ((adresse_short = new short [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureShort(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 5 :
      if ((adresse_unsigned_short = new unsigned short [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureUnsignedShort(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 6 :
      if ((adresse_long = new long [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureLong(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 7 :
      if ((adresse_unsigned_long = new unsigned long [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureUnsignedLong(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 8 :
      if ((adresse_float = new float [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureFloat(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 9 :
      if ((adresse_double = new double [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureDouble(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 10 :
      if ((adresse_long_double = new long double [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureLongDouble(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    default:
      cerr << "Libbm, erreur dans Image::CreeTamponVierge : essai de creation d'un tampon de type inconnu.";
      return(1);
    }

    return(0);
  }
}


unsigned char Image::CopieDe(Image* image) {

  bool retour = 0;
  unsigned long x;
  unsigned long y;

  if ((*image).AdresseType()==0) {

    cerr << "Libbm, erreur dans Image::CopieDe : essai de copie d'un tampon vide.";
    return(1);

  } else {

    if (CreeTamponVierge((*image).AdresseType(),(*image).Naxis1(),(*image).Naxis2()) != 0) return(1);

    //adresse_type = (*image).AdresseType();
    //tampon_audela = 0; // superflu en theorie...
    //naxis1 = (*image).Naxis1();
    //naxis2 = (*image).Naxis2();

    switch ((*image).AdresseType()) {
    case 1 :
      //if ((adresse_bool = new bool [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureBool(x,y,(*image).LectureBool(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	   }
	}
	//}
      break;
    case 2 :
      //if ((adresse_char = new char [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //	cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureChar(x,y,(*image).LectureChar(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 3 :
      //if ((adresse_unsigned_char = new unsigned char [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //	cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureUnsignedChar(x,y,(*image).LectureUnsignedChar(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 4 :
      //if ((adresse_short = new short [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureShort(x,y,(*image).LectureShort(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 5 :
      //if ((adresse_unsigned_short = new unsigned short [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureUnsignedShort(x,y,(*image).LectureUnsignedShort(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 6 :
      //if ((adresse_long = new long [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureLong(x,y,(*image).LectureLong(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 7 :
      //if ((adresse_unsigned_long = new unsigned long [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureUnsignedLong(x,y,(*image).LectureUnsignedLong(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 8 :
      //if ((adresse_float = new float [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureFloat(x,y,(*image).LectureFloat(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 9 :
      //if ((adresse_double = new double [(*image).Naxis1()*(*image).Naxis2()]) == NULL) { 
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    if (EcritureDouble(x,y,(*image).LectureDouble(x,y,&retour)) != 0) return(1);
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    case 10 :
      //if ((adresse_long_double = new long double [(*image).Naxis1()*(*image).Naxis2()]) == NULL) {
      //cerr << "Libbm, erreur dans Image::CopieDe : echec d'allocation de memoire.";
      //return(1);
      //} else {
	for (x=0 ; x<(*image).Naxis1() ; x++) {
	  for (y=0 ; y<(*image).Naxis2() ; y++) {
	    EcritureLongDouble(x,y,(*image).LectureLongDouble(x,y,&retour));
            if (retour == 1) return(1);
	  }
	}
	//}
      break;
    default:
      cerr << "Libbm, erreur dans Image::CopieDe : essai de creation d'un tampon de type inconnu.";
      return(1);
    }

    return(0);
  }
}


unsigned char Image::CopieVers(Image* image) {

  bool retour = 0;
  unsigned long x;
  unsigned long y;

  if (AdresseType()==0) {
    cerr << "Libbm, erreur dans Image::CopieVers : essai de copie d'un tampon vide.";
    return(1);
  } else {
    // si le tampon de destination est vide : il faut l'initialiser maintenant.
    if ((*image).AdresseType() == 0) {
      if ((*image).CreeTamponVierge(AdresseType(),naxis1,naxis2) != 0) return(1);
    }

    switch (AdresseType()) {
    case 1 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureBool(x,y,LectureBool(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 2 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureChar(x,y,LectureChar(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 3 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureUnsignedChar(x,y,LectureUnsignedChar(x,y,&retour)) != 0) return (1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 4 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureShort(x,y,LectureShort(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 5 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureUnsignedShort(x,y,LectureUnsignedShort(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 6 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureLong(x,y,LectureLong(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 7 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureUnsignedLong(x,y,LectureUnsignedLong(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 8 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureFloat(x,y,LectureFloat(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 9 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureDouble(x,y,LectureDouble(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    case 10 :
      for (x=0 ; x<(*image).Naxis1() ; x++) {
	for (y=0 ; y<(*image).Naxis2() ; y++) {
	  if ((*image).EcritureLongDouble(x,y,LectureLongDouble(x,y,&retour)) != 0) return(1);
	  if (retour == 1) return(1);
	}
      }
      break;
    default:
      cerr << "Libbm, erreur dans Image::CreeTamponVierge : essai de creation d'un tampon de type inconnu.";
      return(1);
    }

    return(0);
  }
}

/*
unsigned char Image::Fenetre(unsigned long x1, unsigned long x2, unsigned long y1, unsigned long y2){

  if (tampon_audela > 0) {

    cerr << "Libbm, erreur dans Image::Fenetre : impossible de fenetrer un tampon AudeLA.";
    return(1);

  } else {

    bool* tmp_adresse_bool;
    char* tmp_adresse_char;
    unsigned char* tmp_adresse_unsigned_char;
    short* tmp_adresse_short;
    unsigned short* tmp_adresse_unsigned_short;
    long* tmp_adresse_long;
    unsigned long* tmp_adresse_unsigned_long;
    float* tmp_adresse_float;
    double* tmp_adresse_double;
    long double* tmp_adresse_long_double;

    long double tmp_naxis1 = (double(x2)-x1)+1;
    long double tmp_naxis2 = (double(y2)-y1)+1;

    switch (data_type) {
    case 1 :
      if ((tmp_adresse_bool = new bool [tmp_naxis1*tmp_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::Fenetre : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<tmp_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<tmp_naxis2 ; y++) {



	    Programmation en cours ICI !!!!



	    if ((*)EcritureBool(x,y,0) != 0) return(1);
	  }
        }
      }
      break;
    case 2 :
      if ((adresse_char = new char [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureChar(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 3 :
      if ((adresse_unsigned_char = new unsigned char [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureUnsignedChar(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 4 :
      if ((adresse_short = new short [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureShort(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 5 :
      if ((adresse_unsigned_short = new unsigned short [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureUnsignedShort(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 6 :
      if ((adresse_long = new long [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureLong(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 7 :
      if ((adresse_unsigned_long = new unsigned long [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureUnsignedLong(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 8 :
      if ((adresse_float = new float [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureFloat(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 9 :
      if ((adresse_double = new double [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureDouble(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    case 10 :
      if ((adresse_long_double = new long double [val_naxis1*val_naxis2]) == NULL) {
      	cerr << "Libbm, erreur dans Image::CreeTamponVierge : echec d'allocation de memoire.";
	return(1);
      } else {
	for (unsigned long x=0 ; x<val_naxis1 ; x++) {
	  for (unsigned long y=0 ; y<val_naxis2 ; y++) {
	    if (EcritureLongDouble(x,y,0) != 0) return(1);
	  }
	}
      }
      break;
    default:
      cerr << "Libbm, erreur dans Image::CreeTamponVierge : essai de creation d'un tampon de type inconnu.";
      return(1);
    }

    return(0);
  }
}

*/
