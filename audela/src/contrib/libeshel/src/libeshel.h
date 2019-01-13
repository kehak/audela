// echelle.h : prototype des focntions pricipales de la DLL
//

#ifndef _INC_LIBESHEL_MAIN
#define _INC_LIBESHEL_MAIN

#include <stdio.h>  // pour FILE
#include <list>
#include <string>
#include <valarray>
#include "order.h"
#include "linegap.h"

void Eshel_processFlat(
   char *ledfileName,      // nom du fichier led (image pretraitee pour la calibration geometrique)
   char *tungstenFileName, // nom du fichier tungsten (image pretraitee pour le blaze)
   char *flatFileName,     // nom du fichier flat traitee en sortie
   int ordre_ref_y, int ordre_ref, double lambda_ref, int neon_ref_x, 
   int wide_y, int seuil_ordre, ORDRE *ordre, 
   INFOSPECTRO &spectro,
   ::std::list<double> &lineList,
   int *nb_ordre, double *dx_ref,
   char *logFileName,
   char *message);          // message de retour

void Eshel_processCalib(char *lampNameIn, char *lampNameOut,char *flatName, 
                int ordre_ref, double lambda_ref, int neon_ref_x,
				    int calibration_iteration,
                char *logFileName, short * check, ::std::list<double> &lineList);

void Eshel_processObject(char *nom_objet_fits, char *nom_objet_out_fits, char *nom_calib, 
                char *responseFileName, int responsePerOrder, 
                int minOrder, int maxorder, int  recordObjectImage, 
                ::std::valarray<CROP_LAMBDA> &cropLambda,
                char *cosmicCleaning,
                char *logFileName, short *check);

void Eshel_joinSpectra(char *nom_objet_fits, char *nom_calib_fits, 
                 char *nom_objet_full0_fits, char *nom_objet_full_fits,
                 int min_order, int max_order,
                 int flag_merge,
                 short * check);

//void Eshel_findSpectroParameters(char *calibFileName, char *flatFileName, ::std::list<double> &lineList);


void Eshel_interpolProfile(char *fileName);
void Eshel_getRawProfile(char *fileName, int orderNum, double **values, int *min_x, int *size);
void Eshel_getLinearProfile(char *fileName, int orderNum, double **values, double *lambda1, double *step, int *size);
void Eshel_getProfile(char *fileName, char * hduName, double **values, double *lambda1, double *step, int *size);
void Eshel_getLineGap(char *fileName, LINE_GAP **lineGap, int *size);
void Eshel_getOrderTable(char *fileName, ORDRE **ordre, double *dx_ref);
void Eshel_getInfoSpectro(char *fileName, INFOSPECTRO *infoSpectro);
void Eshel_freeData(void *values);
#endif

/* 
 change log
 ==========

1.10 : 
 

 1.9 : 
   renomme LAMPNAME en CALINAME dans les mots clefs des images des objets
   renomme Eshel_processLamp en Eshel_processCalib dans libeshel.cpp
   Enregistre le profil 1B du flat dans le fichier calibration au lieu du fichier flat
   suppression de la modification du FLAT quand on traite la calibration (pas de mise à jour de la table des ordres, pas de profil 1B)
        

*/