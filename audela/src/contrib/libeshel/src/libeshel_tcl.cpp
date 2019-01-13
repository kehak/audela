/* libesheltcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol 
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <tcl.h>
#include <stdlib.h>  // pour calloc
#include <exception>
#include <string>
#include <sstream>   // pour ostringstream
#include "order.h"
#include "libeshel.h"
#include "wizard.h"
#include "wizardthar.h"
#include "InstrumentalResponse.h"

// fonctions locales
void makeCheck(char *fileName,::std::list<double> &lineList);


int cmdEshelInit(ClientData clientData, Tcl_Interp *interp,int argc, char *argv[]) {
   char s[200];

   if(argc!=1) {
      sprintf(s,"Usage: %s double l m ", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      //writeAscii();
      return TCL_OK;
   }
   return TCL_OK;
}

int cmdEshel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;
   char *usage = "Usage: eshel makerinull | makeri ";
   if(argc < 2) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
 
   try {
      char * command = argv[1];
      if ( strcmp(command, "makerinull") == 0) {
         if(argc != 4) {
            Tcl_SetResult(interp,usage,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            char * objectFileName = argv[2];
            char * reponseFileName = argv[3];
            CInstrumentalResponse::makeNullResponse(objectFileName, reponseFileName);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         }
      } else if ( strcmp(command, "response") == 0) {
         if(argc < 6) {
            char usage[1024]; 
            sprintf(usage,"%s %s genericDatName responseFileName minOrder maxOrder {keywordList}", argv[0], argv[1]);
            Tcl_SetResult(interp, usage ,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            char * objectFileName = argv[2];
            char * reponseFileName = argv[3];
            int minOrder; 
            int maxOrder; 
            ::std::list<CKeyword> keywordList;

            if(Tcl_GetInt(interp,argv[4],&minOrder)!=TCL_OK) {
               char s[1024];
               sprintf(s,"%s %s\n Invalid minOrder=%s", argv[0], argv[1],  argv[4]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }     

            if(Tcl_GetInt(interp,argv[5],&maxOrder)!=TCL_OK) {
               char s[1024];
               sprintf(s,"%s %s\n Invalid maxOrder=%s", argv[0], argv[1], argv[5]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }     

            if ( argc== 7) {
               int keywordArgc;
               char **keywordArgv;
      
               if(Tcl_SplitList(interp,argv[6],&keywordArgc,(const char***) &keywordArgv)!=TCL_OK) {
                  char s[1024];
                  sprintf(s,"%s\n keyword list=%s", usage, argv[6]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_ERROR;
               } else {
                  result = TCL_OK;
                  for (int i=0 ; i< keywordArgc && result!= TCL_ERROR; i++) {
                     int paramArgc;
                     char **paramArgv;
                     if(Tcl_SplitList(interp,keywordArgv[i],&paramArgc,(const char***) &paramArgv)!=TCL_OK) {
                        char s[1024];
                        sprintf(s,"%s\n Invalid ordre line %d value=%s", usage, i, keywordArgv[i]);
                        Tcl_SetResult(interp,s,TCL_VOLATILE);
                        result = TCL_ERROR;     
                        break;
                     } else if (paramArgc != 3 ){
                        char s[1024];
                        sprintf(s,"%s\n Invalid keyword %d value=%s .\nMust contain {name , value, comment}", usage, i, keywordArgv[i]);
                        Tcl_SetResult(interp,s,TCL_VOLATILE);
                        result = TCL_ERROR;       
                        break;
                     } else {
                        CKeyword keyword; 
                        keyword.name.assign(paramArgv[0]);
                        keyword.value.assign(paramArgv[1]);
                        keyword.comment.assign(paramArgv[2]);
                        keywordList.push_back(keyword);
                        Tcl_Free((char*)paramArgv);
                     }                     
                  } 
                  Tcl_Free((char*)keywordArgv);
               }

            }
            if ( result == TCL_ERROR) {
               return TCL_ERROR;
            }

            CInstrumentalResponse::makeResponse(objectFileName, minOrder, maxOrder, reponseFileName, keywordList);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         }

      } else {
         Tcl_SetResult(interp,usage,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   } catch(std::exception e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}

// ---------------------------------------------------------------------------
// cmdEshelFlat
//    traite un flat
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelProcessFlat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_flat ledFileName tungstenFileName flatFileName Out alpha beta gamma focale m pixel width height wide_x wide_y seuil_ordre min_order max_order neon_ref_x ordre_ref_y ordre_ref lambda_ref {def_ordres} {line_list} {distorsion_polynom}";
   if(argc!=24) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * ledfileName ;
      char * tungstenFileName;
      char * flatFileName;
      INFOSPECTRO spectro;
      int wide_x, wide_y, seuil_ordre;
      int neon_ref_x, ordre_ref_y, ordre_ref;
      double lambda_ref;
      ORDRE * ordre;
      ::std::list<double> lineList;

      int ordreArgc;
      char **ordreArgv;
      int paramArgc;
      char **paramArgv;
      int distorsionArgc;
      char **distorsionArgv;

      int nb_ordre = 0;

      ledfileName = argv[1];
      tungstenFileName = argv[2];
      flatFileName = argv[3];

      int paramNo  = 3;
      // parametres du specrographe
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.alpha)!=TCL_OK) {
         sprintf(s,"%s\n Invalid alpha=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.beta)!=TCL_OK) {
         sprintf(s,"%s\n Invalid beta=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.gamma)!=TCL_OK) {
         sprintf(s,"%s\n Invalid gamma=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.focale)!=TCL_OK) {
         sprintf(s,"%s\n Invalid focale=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.m)!=TCL_OK) {
         sprintf(s,"%s\n Invalid m=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.pixel)!=TCL_OK) {
         sprintf(s,"%s\n Invalid pixel=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.imax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid width=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }         
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.jmax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid height=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // parametres de detection des raies
      if(Tcl_GetInt(interp,argv[++paramNo],&wide_x)!=TCL_OK) {
         sprintf(s,"%s\n Invalid wide_x=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&wide_y)!=TCL_OK) {
         sprintf(s,"%s\n Invalid wide_y=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&seuil_ordre)!=TCL_OK) {
         sprintf(s,"%s\n Invalid seuil_ordre=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.min_order)!=TCL_OK) {
         sprintf(s,"%s\n Invalid min_order=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.max_order)!=TCL_OK) {
         sprintf(s,"%s\n Invalid max_order=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // parametre de calibration ( raie de réference)
      if(Tcl_GetInt(interp,argv[++paramNo],&neon_ref_x)!=TCL_OK) {
         sprintf(s,"%s\n Invalid neon_ref_x=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&ordre_ref_y)!=TCL_OK) {
         sprintf(s,"%s\n Invalid ordre_ref_y=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&ordre_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid ordre_ref=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&lambda_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid lambda_ref=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // liste des parametres des ordes (num, marge gauche, marge droit, slant)
      if(Tcl_SplitList(interp,argv[++paramNo],&ordreArgc,(const char***) &ordreArgv)!=TCL_OK) {
         sprintf(s,"%s\n ordre list=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         // On alloue la place pour 100 ordres
         if ((ordre=(ORDRE *)calloc(MAX_ORDRE,sizeof(ORDRE)))==NULL) {
            return NULL;
         }
         for (int i=0 ; i< ordreArgc && result!= TCL_ERROR; i++) {
            if(Tcl_SplitList(interp,ordreArgv[i],&paramArgc,(const char***) &paramArgv)!=TCL_OK) {
               sprintf(s,"%s\n Invalid ordre line %d value=%s", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;            
            } else if (paramArgc != 4 ){
               sprintf(s,"%s\n Invalid ordre line %d value=%s .\nMust contain {num_order min_x max_x slant}", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;            
            } else {
               int n;
               if(Tcl_GetInt(interp,paramArgv[0],&n)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d num_order=%s is not an integer", usage, i, paramArgv[0]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }

               if(Tcl_GetInt(interp,paramArgv[1],&ordre[n].min_x)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d=%s , min_x is not an integer", usage, i, paramArgv[1]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
               if(Tcl_GetInt(interp,paramArgv[2],&ordre[n].max_x)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d max_x=%s is not an integer", usage, i, paramArgv[2]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
               if(Tcl_GetDouble(interp,paramArgv[3],&ordre[n].slant)!=TCL_OK) {
                  sprintf(s,"%s\n Invalid ordre line %d slant=%s is not a float", usage, i, paramArgv[3]);
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
               Tcl_Free((char*)paramArgv);
            }
            if ( result == TCL_ERROR) {
               return TCL_ERROR;
            }
         } 
         Tcl_Free((char*)ordreArgv);
      }

      // liste des raies de calibration
      if(Tcl_SplitList(interp,argv[++paramNo],&ordreArgc,(const char***) &ordreArgv)!=TCL_OK) {
         sprintf(s,"%s\n invalid line list=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         double lambda;
         for (int i=0 ; i< ordreArgc && result!= TCL_ERROR; i++) {
            if(Tcl_GetDouble(interp,ordreArgv[i],&lambda)!=TCL_OK) {
               sprintf(s,"%s\n Invalid line %d lambda=%s is not an integer", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               lineList.push_back(lambda);
            }             
         }
         Tcl_Free((char*)ordreArgv);
      }

      // Polynome de correction de la distorsion optique  
      //spectro.distorsion.resize(4);
      //spectro.distorsion[0]=  26.4525309312253 ;
      //spectro.distorsion[1]=  0.951178287573155 ;
      //spectro.distorsion[2]=  0.0000346251616269773 ;
      //spectro.distorsion[3]=  -1.11329993513915e-08;
      if(Tcl_SplitList(interp,argv[++paramNo],&distorsionArgc,(const char***) &distorsionArgv)!=TCL_OK) {
         sprintf(s,"%s\n invalid distorsion polynom=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         spectro.distorsion.resize(distorsionArgc);
         double coefficient;
         for (int i=0 ; i< distorsionArgc && result!= TCL_ERROR; i++) {
            if(Tcl_GetDouble(interp,distorsionArgv[i],&coefficient)!=TCL_OK) {
               sprintf(s,"%s\n Invalid coefficient[%d]=%s is not a double ", usage, i, distorsionArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               spectro.distorsion[i]=coefficient;
            }             
         }
         Tcl_Free((char*)distorsionArgv);
      }
      
      // la largeur de la zone de binning et de calcul du ciel est la même pour tous les ordres (simplification)
      for (int i=0;i<MAX_ORDRE;i++) {
         ordre[i].wide_y=wide_y;
         ordre[i].wide_x=wide_x;      // largeur de la boite de recherche des raies du néon en pixels (en dur - param sensible)
      }

      try {
         double dx_ref;
         char returnMessage[1024];
         Eshel_processFlat(ledfileName, tungstenFileName, flatFileName,
            ordre_ref_y, ordre_ref, lambda_ref, neon_ref_x, 
            wide_y, seuil_ordre, ordre, 
            spectro,
            lineList,
            &nb_ordre, &dx_ref,
            "reduc.log",
            returnMessage);
         // je copie le nombre d'ordres trouves dans la reponse
         sprintf(s,"%d  %s", nb_ordre, returnMessage);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }
      
      return result;
   }
}

// ---------------------------------------------------------------------------
// cmdEshelCalib
//    traite un lampe de calibration
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelProcessCalib(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_processCalib calibIn calibOut flatIn lamp_ref_x ordre_ref_y ordre_ref lambda_ref iteration {line_list}";
   if(argc!=9) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * lampNameIn ;
      char * lampNameOut;
      char * flatName;
      int neon_ref_x, ordre_ref;
      double lambda_ref;
      ::std::list<double> lineList;
      int ordreArgc;
      char **ordreArgv;
      int nb_ordre = 0;
      int iteration;

      lampNameIn = argv[1];
      lampNameOut = argv[2];
      flatName = argv[3];

      // parametre de calibration ( raie de réference)
      if(Tcl_GetInt(interp,argv[4],&neon_ref_x)!=TCL_OK) {
         sprintf(s,"%s\n Invalid neon_ref_x=%s", usage, argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[5],&ordre_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid ordre_ref=%s", usage, argv[5]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[6],&lambda_ref)!=TCL_OK) {
         sprintf(s,"%s\n Invalid lambda_ref=%s", usage, argv[6]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[7],&iteration)!=TCL_OK) {
         sprintf(s,"%s\n Invalid neon_ref_x=%s", usage, argv[7]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }


      if(Tcl_SplitList(interp,argv[8],&ordreArgc,(const char***) &ordreArgv)!=TCL_OK) {
         sprintf(s,"%s\n invalid line list=%s", usage, argv[8]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         double lambda;
         for (int i=0 ; i< ordreArgc && result!= TCL_ERROR; i++) {
            if(Tcl_GetDouble(interp,ordreArgv[i],&lambda)!=TCL_OK) {
               sprintf(s,"%s\n Invalid line %d lambda=%s is not an integer", usage, i, ordreArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               lineList.push_back(lambda);
            }             
         }
         Tcl_Free((char*)ordreArgv);
      }

      
      try {
         Eshel_processCalib(lampNameIn, lampNameOut, flatName,
            ordre_ref, lambda_ref, neon_ref_x, iteration,
            "reduc.log",(short*)NULL, lineList);
         // je fabrique l'image check
         // makeCheck(lampNameOut, lineList);
         // je calibre flat
         //  Eshel_interpolProfile(flatName);
         Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }

      // je prepare la reponse
      return result;
   }
}

// ---------------------------------------------------------------------------
// cmdEshelProcessObject
//    traite l'image d'un objet :
//    
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelProcessObject(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_processObject fileIn fileOut calibFileName minOrder maxOrder {-merge 0|1} {-responseFileName responseFileName} {-responsePerOrder 0|1 } {-exportfull0 fullFileName} {-exportfull fullFileName} {-objectimage 0|1} {-cosmicCleaning none|removed|method}";
   if(argc<5) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * objectFileNameIn = NULL;
      char * objectFileNameOut = NULL;
      char * calibFileName = NULL;
      char * responseFileName = NULL;
      int responsePerOrder = 0;
      int minOrder = 0;
      int maxOrder = 0;
      char * fullFileName0 = NULL;
      char * fullFileName = NULL;
      int  useFlat = 1;
      int  recordObjectImage = 1; 
      ::std::valarray<CROP_LAMBDA> cropLambda(0);
      char *cosmicCleaning = NULL; 

      objectFileNameIn = argv[1];
      objectFileNameOut = argv[2];
      calibFileName = argv[3];

      if(Tcl_GetInt(interp,argv[4],&minOrder)!=TCL_OK) {
         sprintf(s,"%s\n Invalid minOrder=%s", usage, argv[4]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[5],&maxOrder)!=TCL_OK) {
         sprintf(s,"%s\n Invalid maxOrder=%s", usage, argv[5]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // je decode les parametres optionels
      for (int kk = 6; kk < argc ; kk++) {
         if (strcmp(argv[kk], "-merge") == 0 && kk+1 < argc ) {
            if(Tcl_GetInt(interp,argv[kk + 1],&useFlat)!=TCL_OK) {
               sprintf(s,"%s\n Invalid -merge=%s", usage, argv[kk]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }
         if (strcmp(argv[kk], "-exportfull") == 0 && kk+1 < argc ) {
            fullFileName = argv[kk + 1];
         }
         if (strcmp(argv[kk], "-exportfull0") == 0 && kk+1 < argc ) {
            fullFileName0 = argv[kk + 1];
         }
         if (strcmp(argv[kk], "-responseFileName") == 0 && kk+1 < argc ) {
            responseFileName = argv[kk + 1];
         }
         if (strcmp(argv[kk], "-responsePerOrder") == 0 && kk+1 < argc ) {
            if(Tcl_GetInt(interp,argv[kk + 1],&responsePerOrder)!=TCL_OK) {
               sprintf(s,"%s\n Invalid -responsePerOrder=%s", usage, argv[kk]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }

         if (strcmp(argv[kk], "-objectimage") == 0 && kk+1 < argc ) {
            if(Tcl_GetInt(interp,argv[kk + 1],&recordObjectImage)!=TCL_OK) {
               sprintf(s,"%s\n Invalid -objectimage=%s", usage, argv[kk]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            }
         }

         if (strcmp(argv[kk], "-cosmicCleaning") == 0 && kk+1 < argc ) {
            cosmicCleaning = argv[kk + 1];
         }
   
         if (strcmp(argv[kk], "-croplambda") == 0 && kk+1 < argc ) {
 
            int cropArgc;
            char **cropArgv;

            // liste des parametres des ordes (num, marge gauche, marge droit, slant)
            if(Tcl_SplitList(interp,argv[kk+1],&cropArgc,(const char***) &cropArgv)!=TCL_OK) {
               sprintf(s,"%s\n croplmabda list=%s", usage, argv[kk+1]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               result = TCL_OK;
               
               if ( cropArgc > 0 ) {
                  // j'alloue la place pour tous les ordres
                  cropLambda.resize(MAX_ORDRE);
                  // je copie les bornes de detrourage dans la table 
                  for (int i=0 ; i< cropArgc && result!= TCL_ERROR; i++) {
                     int paramArgc;
                     char **paramArgv;
                     if(Tcl_SplitList(interp,cropArgv[i],&paramArgc,(const char***) &paramArgv)!=TCL_OK) {
                        sprintf(s,"%s\n Invalid crop lambda %d value=%s", usage, i, cropArgv[i]);
                        Tcl_SetResult(interp,s,TCL_VOLATILE);
                        result = TCL_ERROR;            
                     } else if (paramArgc != 3 ){
                        sprintf(s,"%s\n Invalid crop lambda %d value=%s .\nMust contain {orderNum minLambda minLambda}", usage, i, cropArgv[i]);
                        Tcl_SetResult(interp,s,TCL_VOLATILE);
                        result = TCL_ERROR;            
                     } else {
                        int numOrder;
                        if(Tcl_GetInt(interp,paramArgv[0],&numOrder)!=TCL_OK) {
                           sprintf(s,"%s\n Invalid crop lambda %d num_order=%s is not an integer", usage, i, paramArgv[0]);
                           Tcl_SetResult(interp,s,TCL_VOLATILE);
                           result = TCL_ERROR;
                        }
                        if(Tcl_GetDouble(interp,paramArgv[1],&cropLambda[numOrder].minLambda)!=TCL_OK) {
                           sprintf(s,"%s\n Invalid crop lambda %d min lambda=%s is not a float", usage, i, paramArgv[1]);
                           Tcl_SetResult(interp,s,TCL_VOLATILE);
                           result = TCL_ERROR;
                        }
                        if(Tcl_GetDouble(interp,paramArgv[2],&cropLambda[numOrder].maxLambda)!=TCL_OK) {
                           sprintf(s,"%s\n Invalid crop lambda %d max lambda=%s is not a float", usage, i, paramArgv[2]);
                           Tcl_SetResult(interp,s,TCL_VOLATILE);
                           result = TCL_ERROR;
                        }
                        Tcl_Free((char*)paramArgv);
                     }
                  }
               } 
               Tcl_Free((char*)cropArgv);
               if ( result == TCL_ERROR) {
                  return TCL_ERROR;
               }
            }
         }
      }
    
      try {
         Eshel_processObject(objectFileNameIn, objectFileNameOut, calibFileName, 
            responseFileName, responsePerOrder, 
            minOrder, maxOrder, recordObjectImage,
            cropLambda, 
            cosmicCleaning,
            "reduc.log",(short*)NULL);

         //Eshel_joinSpectra(objectFileNameOut, calibFileName,
         //       fullFileName0, fullFileName,
         //       minOrder, maxOrder,
         //       useFlat, (short *) NULL)  ;
         Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);         
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }

      return result;
   }
}


// ---------------------------------------------------------------------------
// cmdEshelFindMargin
//    recherche les marges 
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelFindMargin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_findMargin ledFileName outputFileName width height seuil_ordre snnoise, min_order max_order";
   if(argc!=9) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * ledfileName ;
      char * outputFileName;
      INFOSPECTRO spectro;
      int seuil_ordre;
      double snNoise;
      
      ledfileName = argv[1];
      outputFileName = argv[2];

      int paramNo  = 2;
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.imax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid width=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }         
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.jmax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid height=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&seuil_ordre)!=TCL_OK) {
         sprintf(s,"%s\n Invalid seuil_ordre=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetDouble(interp,argv[++paramNo],&snNoise)!=TCL_OK) {
         sprintf(s,"%s\n Invalid snNoise=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.min_order)!=TCL_OK) {
         sprintf(s,"%s\n Invalid min_order=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.max_order)!=TCL_OK) {
         sprintf(s,"%s\n Invalid max_order=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      spectro.alpha = 0;
      spectro.beta = 0;
      spectro.distorsion.resize(0);
      spectro.focale = 0;
      spectro.gamma = 0;
      spectro.m = 0;
      spectro.pixel = 0; 
      spectro.version = LIBESHEL_VERSION;
      
      try {
         char returnMessage[1024];
         strcpy(returnMessage,"");
         Eshel_findMargin(
            ledfileName, 
            outputFileName,
            seuil_ordre, 
            snNoise,
            spectro,
            returnMessage);

         // je copie le nombre d'ordres trouves dans la reponse
         Tcl_SetResult(interp,returnMessage,TCL_VOLATILE);
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }
      
      return result;
   }
}

// ---------------------------------------------------------------------------
// cmdEshelFindReferenceLine
//    recherche la position de la raie de catalog
// return:
//   retourne TCL_OK ou TCL_ERROR 
// ---------------------------------------------------------------------------
int cmdEshelFindReferenceLine(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   int result;
   char *usage = "Usage: eshel_findReferenceLine ledfileName tharFileName outputFileName " \
                  "alpha beta gamma focale grating pixelSize width height " \
                  "refNum refLambda " \
                  "lineList threshin fwhm ";
   if(argc!=17) {
      Tcl_SetResult(interp,usage,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      char * ledFileName;
      char * tharFileName ;
      char * outputFileName;
      INFOSPECTRO spectro;
      int ordre_ref_num;
      double ordre_ref_lambda;
      ::std::list<double> lineList;
      int threshin; 
      int fwhm;      
      int nb_ordre = 0;

      int paramNo  = 1;
      ledFileName = argv[paramNo];
      tharFileName = argv[++paramNo];
      outputFileName = argv[++paramNo];

      // parametres du specrographe
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.alpha)!=TCL_OK) {
         sprintf(s,"%s\n Invalid alpha=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.beta)!=TCL_OK) {
         sprintf(s,"%s\n Invalid beta=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.gamma)!=TCL_OK) {
         sprintf(s,"%s\n Invalid gamma=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.focale)!=TCL_OK) {
         sprintf(s,"%s\n Invalid focale=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.m)!=TCL_OK) {
         sprintf(s,"%s\n Invalid m=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&spectro.pixel)!=TCL_OK) {
         sprintf(s,"%s\n Invalid pixel=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.imax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid width=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }         
      if(Tcl_GetInt(interp,argv[++paramNo],&spectro.jmax)!=TCL_OK) {
         sprintf(s,"%s\n Invalid height=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&ordre_ref_num)!=TCL_OK) {
         sprintf(s,"%s\n Invalid ordre_ref=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetDouble(interp,argv[++paramNo],&ordre_ref_lambda)!=TCL_OK) {
         sprintf(s,"%s\n Invalid lambda_ref=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // liste des raies de calibration
      int lineArgc;
      char **lineArgv;

      if(Tcl_SplitList(interp,argv[++paramNo],&lineArgc,(const char***) &lineArgv)!=TCL_OK) {
         sprintf(s,"%s\n invalid line list=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         result = TCL_OK;
         double lambda;
         for (int i=0 ; i< lineArgc && result!= TCL_ERROR; i++) {
            if(Tcl_GetDouble(interp,lineArgv[i],&lambda)!=TCL_OK) {
               sprintf(s,"%s\n Invalid line %d lambda=%s is not an integer", usage, i, lineArgv[i]);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               lineList.push_back(lambda);
            }             
         }
         Tcl_Free((char*)lineArgv);
      }

      if(Tcl_GetInt(interp,argv[++paramNo],&threshin)!=TCL_OK) {
         sprintf(s,"%s\n Invalid threshin=%s", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if(Tcl_GetInt(interp,argv[++paramNo],&fwhm)!=TCL_OK) {
         sprintf(s,"%s\n Invalid fwhm=%s. Must be integer.", usage, argv[paramNo]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      try {
         std::string returnMessage;
         Eshel_findReferenceLine(
            ledFileName, 
            tharFileName, 
            outputFileName,
            ordre_ref_num, 
            ordre_ref_lambda, 
            spectro,
            lineList,
            threshin,
            fwhm,
            returnMessage);
         // je copie le nombre d'ordres trouves dans la reponse
         Tcl_SetResult(interp,(char *) returnMessage.c_str(),TCL_VOLATILE);
         result = TCL_OK;
      } catch(std::exception e ) {
         Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
         result = TCL_ERROR;
      }
      
      return result;
   }
}


/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#ifdef WIN32
   int __cdecl Eshel_Init(Tcl_Interp *interp)
#else
   int Esheltcl_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.4",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization in libeshel_tcl.",TCL_STATIC);
      return TCL_ERROR;
   }

   /* ajouter ici les autres fonctions d'extension que vous allez creer */
   Tcl_CreateCommand(interp,"eshel",(Tcl_CmdProc *)cmdEshel,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"eshel_processFlat",(Tcl_CmdProc *)cmdEshelProcessFlat,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"eshel_processCalib",(Tcl_CmdProc *)cmdEshelProcessCalib,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"eshel_processObject",(Tcl_CmdProc *)cmdEshelProcessObject,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"eshel_findMargin",(Tcl_CmdProc *)cmdEshelFindMargin,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"eshel_findReferenceLine",(Tcl_CmdProc *)cmdEshelFindReferenceLine,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   
   Tcl_SetVar((Tcl_Interp*) interp, "libesheltcl_version", "1.0", TCL_GLOBAL_ONLY);


   return TCL_OK;
}
