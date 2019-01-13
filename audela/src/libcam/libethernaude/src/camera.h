/* camera.h
 * 
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 * 
 * Mettre ici le texte de la license.
 *
 */

#ifndef __CAMERA_H__
#define __CAMERA_H__

#include <math.h>

// Includes standard libcam
#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

// Includes specifiques driver
#include "ethernaude_user.h"
#include "ethernaude_util.h"
#include "direct_driver.h"

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    /* --- pour Ethernaude --- */
    char channel[1024];
    ethernaude_var ethvar;
    int ipsetting;
    char ipsetting_filename[1024];
    char ip[50];
    int CCDStatus;
    /* --- pour l'obturateur Audine --- */
    int shutteraudinereverse;
    /* --- pour l'obturateur a Pierre Thierry --- */
    int shuttertypeindex;	/* 0=audine 1=thierry */
    /* --- vitesse de lecture --- */
    int canspeed;
    /* --- inp params --- */
    struct new_ethernaude_inp inparams;
    /* --- direct driver --- */
    int direct;
    float exptime_when_acq_stopped;
};

/* DIRECT DRIVER */
int test_driver();
int direct_driver();


#endif
