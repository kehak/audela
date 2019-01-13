
#ifndef __CAMERA_H__
#define __CAMERA_H__


#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

#define START_DUMMY_PIXELS_40x_160x	10
#define END_DUMMY_PIXELS_40x_160x	2

#define START_DUMMY_PIXELS_320x		12
#define END_DUMMY_PIXELS_320x		3

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    /* --- pour Audine --- */
    /* --- pour l'amplificateur des Kaf-401 --- */
    int ampliindex;
    int nbampliclean;
    /* --- pour l'obturateur Audine --- */
    int shutteraudinereverse;
    /* --- pour le type de CAN --- */
    int cantypeindex;

	/* Dummy pixels present at the begining and at the end of each lines depending on the CCD */
	/* 10 + 2 for KAAF400 & KAF1600 for exemple */
	//int start_dummy_pixels;
	//int end_dummy_pixels;

};

#endif
