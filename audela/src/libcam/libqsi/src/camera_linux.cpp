/***
 * @file : camera_linux.c
 * @brief : routines d'usage général
 * @author : Jacques MICHELET <jacques.michelet@aquitania.org>
 *
 * Mise à jour $Id: camera_linux.cpp 13592 2016-04-03 15:40:37Z jacquesmichelet $
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
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

/***
 * QSI provides a different driver library for Windows and Linux.
 * Even if the API routines have some similar names, the way to call them
 * is a bit different. Also the Windows interface has some built-in functions that
 * are not provided for Linux. These are the reasons why there is a dedicated
 * camera_linux.cpp file.
 */

#include <iostream>
#include "sysexp.h"
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include "libcam/util.h"
#include "camera.h"
#include <qsiapi.h>


#ifdef __cplusplus
extern "C" {
#endif


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"QSI 632",          /* camera name 70 car maxi*/
     "qsi",              /* camera product */
     "KAF 3200",         /* ccd name */
     2184, 1472,         /* maxx maxy */
     14, 14,             /* overscans x */
     4, 4,               /* overscans y */
     9e-6, 9e-6,         /* photosite dim (m) */
     65535.,             /* observed saturation */
     1.,                 /* filling factor */
     2.0,                /* gain (e/adu) */
     10.0,               /* readnoise (e) */
     1, 1,               /* default bin x,y */
     1.,                 /* default exptime */
     1,                  /* default state of shutter (1=synchro) */
     0,                  /* default port index (0=lpt1) */
     1,                  /* default cooler index (1=on) */
     -15.,               /* default value for temperature checked */
     1,                  /* default color mask if exists (1=cfa) */
     0,                  /* default overscan taken in acquisition (0=no) */
     2.8                 /* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop * cam);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_ampli_on(struct camprop *cam);
static void cam_ampli_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
    cam_init,
    cam_close,
    cam_set_binning,
    cam_update_window,
    cam_start_exp,
    cam_stop_exp,
    cam_read_ccd,
    cam_shutter_on,
    cam_shutter_off,
    cam_ampli_on,
    cam_ampli_off,
    cam_measure_temperature,
    cam_cooler_on,
    cam_cooler_off,
    cam_cooler_check
};

struct _PrivateParams {
    QSICamera *qsicam;
    int abort;
    int debug;
};

#ifdef __cplusplus
}
#endif

#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */



/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init( struct camprop *cam, int argc, const char **argv )
{
    // niveau de trace par défaut dans le fichier libqsi.log
    debug_level = LOG_INFO;
    strcpy( logFileName,"libqsi.log" );

    //  Récuperation des paramètres optionnels
    if ( argc >= 5 )
    {
        for ( int kk = 3; kk < argc - 1; kk++ )
        {
            // fprintf( stderr, "param %s\n", argv[kk] );
            if ( strcmp( argv[kk], "-loglevel" ) == 0 )
                debug_level = atoi( argv[kk + 1] );
            if ( strcmp( argv[kk], "-debug_directory") == 0 ) {
                if ( kk + 1 <  argc ) {
                   char fileTempName[1024];
                   // je conserve le nom du fichier de log
                   strcpy( fileTempName, logFileName );
                   // je recupere le repertoire du fichier de traces
                    strcpy( logFileName, argv[kk + 1] );
                   // je concatene un "/" a la fin du repertoire s'il n'y est pas deja
                   if ( logFileName[strlen(logFileName)-1]!= '\\' && logFileName[strlen(logFileName)-1]!= '/' && strlen(logFileName)!=0 ) {
                      strcat(logFileName,"/");
                   }
                   // je concatene le nom du fichier de trace
                   strcat(logFileName, fileTempName);
                }
            }
        }
    }

    libcam_log( LOG_INFO, "*********************************************" );
    libcam_log( LOG_INFO, "*********************************************" );
    libcam_log( LOG_INFO, "*********************************************" );
    libcam_log( LOG_DEBUG, "cam_init : début. Version du %s", __TIMESTAMP__ );
    if ( ( cam->params != 0 ) && ( cam->params->qsicam != 0 ) ) {
        libcam_log( LOG_ERROR, "Caméra déjà initialisée" );
        return 0;
        libcam_log( LOG_DEBUG,"cam_init : fin OK" );
    }

    cam->params = (PrivateParams*) malloc( sizeof(PrivateParams) );
    cam->params->qsicam = new QSICamera();

    // Pour simplifier les écritures
    QSICamera * qsi = cam->params->qsicam;
    if ( qsi == 0 ) {
        sprintf( cam->msg, "Cannot create a camera handler" );
        libcam_log( LOG_ERROR, "Cannot create a camera handler" );
        return -1;
    }

    // Utilisation systématique des méthodes try/catch
    qsi->put_UseStructuredExceptions( true );
    try
    {
        std::string info("");
        qsi->get_DriverInfo( info );
        libcam_log( LOG_INFO, "qsiapi driver : version %s", info.c_str() );

        // Recherche des caméras QSI branchées
        int iNumFound;
        std::string camSerial[QSICamera::MAXCAMERAS];
        std::string camDesc[QSICamera::MAXCAMERAS];

        qsi->get_AvailableCameras( camSerial, camDesc, iNumFound );
        for ( int i = 0; i < iNumFound; i++ )
            libcam_log( LOG_INFO, "Caméras disponibles %s : %s", camSerial[i].c_str(), camDesc[i].c_str() );

        libcam_log( LOG_DEBUG, "cam_init : sélection de la 1ère caméra" );
        // On ne considère que la première. Bogue potentiel.
        qsi->put_SelectCamera( camSerial[0] );
        qsi->put_IsMainCamera( true );

        // Connect to the selected camera and retrieve camera parameters
        libcam_log( LOG_DEBUG, "cam_init  essai de connexion" );
        qsi->put_Connected( true );
        libcam_log( LOG_INFO, "cam_init caméra connectée" );

        // Get Model Number
        std::string modele("");
        qsi->get_ModelNumber( modele );
        strncpy( CAM_INI[cam->index_cam].product, modele.c_str(), sizeof( CAM_INI[cam->index_cam].product ) -1 );
        libcam_log( LOG_INFO, "Modèle : %s", modele.c_str() );

        // Get Camera Description
        std::string desc("");
        qsi->get_Description( desc );
        strncpy( CAM_INI[cam->index_cam].name, desc.c_str(), sizeof( CAM_INI[cam->index_cam].name ) -1 );
        libcam_log( LOG_INFO, "Descriptif : %s", desc.c_str() );

        // Configuration de la caméra
        // Bipeur activé
        qsi->put_SoundEnabled( true );
        // Voyant activé
        qsi->put_LEDEnabled( true );
        // Ventilateurs en mode auto
        qsi->put_FanMode( QSICamera::fanQuiet );
        // Nettoyage CCD
        qsi->put_PreExposureFlush( QSICamera::FlushNormal );

        // Gain
        bool can_set_gain;
        qsi->get_CanSetGain( &can_set_gain );
        if ( can_set_gain ) {
        	enum QSICamera::CameraGain gain;
        	qsi->get_CameraGain( &gain );
        	if ( gain == QSICamera::CameraGainLow )
        		libcam_log( LOG_INFO, "Gain par défaut 1.5e-/ADU (bas)" );
        	else
        		libcam_log( LOG_INFO, "Gain par défaut 0.75e-/ADU (haut)" );
            //qsi->put_CameraGain( QSICamera::CameraGainLow );
	        //libcam_log( LOG_INFO, "Gain initialisé à Low" );
	    }

        // Vitesse de lecture
        if ( modele.substr(0,1) == "6")
        {
            libcam_log( LOG_INFO, "Modèle de la série 600" );
        	enum QSICamera::ReadoutSpeed vitesse_lecture;
            qsi->get_ReadoutSpeed( vitesse_lecture );
            if ( vitesse_lecture == QSICamera::HighImageQuality )
        		libcam_log( LOG_INFO, "Vitesse de lecture par défaut : lente (haute_qualité)" );
			else
        		libcam_log( LOG_INFO, "Vitesse de lecture par défaut : rapide" );

            //qsi->put_ReadoutSpeed( QSICamera::HighImageQuality );
        }

        // Dimensions du capteur en binning 1x1
        qsi->get_CameraXSize( (long *)&cam->nb_photox );
        qsi->get_CameraYSize( (long *)&cam->nb_photoy );
        libcam_log( LOG_INFO, "Dimensions du capteur en b1x1 %d x %d", cam->nb_photox, cam->nb_photoy );

        // Dimensions des pixels en micromètres
        qsi->get_PixelSizeX( &cam->celldimx );
        qsi->get_PixelSizeY( &cam->celldimy );
        libcam_log( LOG_INFO, "Dimensions des pixels en um %f x %f", cam->celldimx, cam->celldimy );
        cam->celldimx *= 1e-6;
        cam->celldimy *= 1e-6;

        // Autres paramètres
        qsi->get_ElectronsPerADU( &CAM_INI[cam->index_cam].gain );
        libcam_log( LOG_INFO, "Gain (e/adu) = %.3f", CAM_INI[cam->index_cam].gain );
        qsi->get_FullWellCapacity( &cam->fillfactor );
        libcam_log( LOG_INFO, "Profondeur des pixels (e) = %.1f", cam->fillfactor );
        if ( modele.substr(0,1) == "6")
        {
            QSICamera::ReadoutSpeed vitesse_lecture;
            qsi->get_ReadoutSpeed( vitesse_lecture );
            libcam_log( LOG_INFO, "Vitesse de lecture (lente = 0, rapide = 1) : %d", vitesse_lecture );
        }
        cam->params->abort = 0;
    }
    catch (std::runtime_error &err)
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        sprintf( cam->msg, "%s\n", text.c_str() );
//        std::string last("");
//        cam->params->qsicam->get_LastError( last );
//        sprintf( cam->msg, "%s\n", last.c_str() );
//        libcam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
    cam->x1 = 0;
    cam->y1 = 0;
    cam->x2 = cam->nb_photox - 1;
    cam->y2 = cam->nb_photoy - 1;
    cam->binx = 1;
    cam->biny = 1;

    cam_update_window(cam);  // met a jour x1,y1,x2,y2,h,w dans cam
    strcpy( cam->date_obs, "2000-01-01T12:00:00" );
    strcpy( cam->date_end, cam->date_obs );
    cam->authorized = 1;
    libcam_log( LOG_DEBUG,"cam_init fin OK" );
    return 0;
}

int cam_close(struct camprop * cam)
{
    libcam_log(LOG_DEBUG,"cam_close debut");
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_close camera not initialized" );
         sprintf( cam->msg, "cam_close camera not initialized" );
         return -1;
    }

    try
    {
        // Déconnection de la caméra
        cam->params->qsicam->put_Connected( false ) ;
        // Suppression de la camera
        delete cam->params->qsicam;
        cam->params->qsicam = 0;
        libcam_log( LOG_DEBUG, "cam_close fin OK" );
        return 0;
    }
    catch (std::runtime_error &err)
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

void cam_update_window( struct camprop *cam )
{
    int maxx, maxy;
    maxx = cam->nb_photox;
    maxy = cam->nb_photoy;
    int x1, x2, y1, y2;

    if ( cam->x1 > cam->x2 ) {
        int x0 = cam->x2;
        cam->x2 = cam->x1;
        cam->x1 = x0;
    }

    if ( cam->x1 < 0 ) {
        cam->x1 = 0;
    }
   if ( cam->x2 > maxx - 1 ) {
      cam->x2 = maxx - 1;
   }

   if ( cam->y1 > cam->y2 ) {
      int y0 = cam->y2;
      cam->y2 = cam->y1;
      cam->y1 = y0;
   }
   if ( cam->y1 < 0 ) {
      cam->y1 = 0;
   }

   if ( cam->y2 > maxy - 1 ) {
      cam->y2 = maxy - 1;
   }

   // je prend en compte le binning
   cam->w = (cam->x2 - cam->x1 +1) / cam->binx;
   cam->h = (cam->y2 - cam->y1 +1) / cam->biny;
   x1 = cam->x1  / cam->binx;
   x2 = x1 + cam->w -1;
   y1 = cam->y1 / cam->biny;
   y2 = y1 + cam->h -1;

   if ( cam->mirrorv == 1 ) {
      // j'applique un miroir vertical en inversant les ordonnees de la fenetre
      x1 = ( maxx / cam->binx ) - x2 - 1;
   }

   if ( cam->mirrorh == 1 ) {
      // j'applique un miroir horizontal en inversant les abcisses de la fenetre
      // 0---y1-----y2---------------------(w-1)
      // 0---------------(w-y2)---(w-y1)---(w-1)
      y1 = ( maxy / cam->biny ) - y2 - 1;
   }

   // je configure la camera.
   // ATTENTION : The frame to be captured is defined by four properties, StartX, StartY, which define the upperleft
   // corner of the frame, and NumX and NumY the define the binned size of the frame.
   // If binning is active, value is in binned pixels, start position for the X and Y axis are 0 based.
   //
   // Restrictions on binning are:
   // The properties BinX and BinY specify the number of bits per bin for each axis.
   // If CanAsymmetricBin is False, BinX must equal BinY.
   // MaxXBin and MaxYBin specify the maximum number of bits per bin allowed by the camera for each axis.
   // Therefore, BinX <=MaxXBin and BinY <= MaxYBin.
   // The total number of bits in a image frame must not exceed the CCD dimension. Therefore,
   //    (StartX + NumX) * BinX <= CameraXSize and (StartY + NumY) * BinY <= CameraYSize
   // Attention , il faut d'abord mettre a jour l'origine (StartX,StartY) avant la taille de la nouvelle fenetre
   // car sinon on risque de provoquer une exception si l'ancienne origine hors de la nouvelle fenetre.
   libcam_log( LOG_DEBUG, "cam_update_window : x1=%d / y1=%d / largeur=%d / hauteur=%d", x1, y1, cam->w, cam->h );
   if ( cam->params->qsicam == 0 ) {
       libcam_log( LOG_ERROR, "cam_update_window camera not initialized");
       sprintf(cam->msg, "cam_update_window camera not initialized");
       return;
    }

   try
   {
   	   cam->params->qsicam->put_StartX( x1 );
   	   cam->params->qsicam->put_StartY( y1 );
   	   cam->params->qsicam->put_NumX( cam->w );
   	   cam->params->qsicam->put_NumY( cam->h );
   }
   catch ( std::runtime_error &err )
   {
   	   std::string text = err.what();
   	   libcam_log( LOG_ERROR, text.c_str() );
   	   std::string last("");
   	   cam->params->qsicam->get_LastError( last );
   	   sprintf( cam->msg, "%s\n", last.c_str() );
   	   libcam_log( LOG_ERROR, last.c_str() );
   }
}


void cam_start_exp( struct camprop *cam, const char *amplionoff )
{
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_start_exp camera not initialized" );
         sprintf( cam->msg, "cam_start_exp camera not initialized" );
         return;
    }

    if ( cam->authorized == 1 )
    {
        try
        {
            // Pour simplifier les écritures
            QSICamera * qsi = cam->params->qsicam;

            double exptime ;
            if ( cam->exptime <= 0.06f )
                exptime = 0.06f;
            else
                exptime = cam->exptime ;

            // je lance l'acquisition
            if ( cam->shutterindex == 0 )
            {
                // acquisition avec obturateur ferme
                libcam_log( LOG_INFO,"Début acquisition [obturateur: fermé, temps expo.: %.1f]", cam->exptime );
                libcam_log( LOG_DEBUG,"cam_start_exp avant StartExposure shutter=closed exptime=%f", cam->exptime );
                qsi->StartExposure( exptime, false );
            }
            else
            {
                // acquisition avec obturateur ouvert
                libcam_log( LOG_INFO, "Début acquisition [obturateur: synchro temps expo.: %.1f", cam->exptime );
                libcam_log( LOG_DEBUG, "cam_start_exp avant StartExposure shutter=synchro exptime=%f", cam->exptime );
                qsi->StartExposure( exptime, true );
            }
            libcam_log( LOG_DEBUG, "cam_start_exp apres StartExposure" );
            libcam_log( LOG_INFO, "Fin acquisition" );
            cam->params->abort = 0;
        }
        catch ( std::runtime_error &err )
        {
            std::string text = err.what();
            libcam_log( LOG_ERROR, text.c_str() );
            std::string last("");
            cam->params->qsicam->get_LastError( last );
            sprintf( cam->msg, "%s\n", last.c_str() );
            libcam_log( LOG_ERROR, last.c_str() );
        }
    }

}

void cam_stop_exp( struct camprop *cam )
{
    libcam_log( LOG_DEBUG,"cam_stop_exp debut");
    libcam_log( LOG_INFO, "Arrêt acquisition" );
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_start_exp camera not initialized" );
         sprintf( cam->msg, "cam_start_exp camera not initialized" );
         return;
    }

    // Si la caméra ne supporte pas l 'arret brutal d'acquisition, il y aura une exception générée
    // Pas besoin donc de tester via camAbortExposure()
    try
    {
        cam->params->qsicam->AbortExposure();
        cam->params->abort = 1;
    }
    catch (std::runtime_error &err)
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
    }
}

void get_image( struct camprop *cam, float *p )
{
	/* The QSI API requires an integer array for grabbing an image */
	unsigned short *image = (unsigned short *)malloc(cam->w * cam->h * sizeof(unsigned short));
    cam->params->qsicam->get_ImageArray( image );

    /* Some conversion is required */
    for ( long u = 0; u < cam->w * cam->h; u++ )
    {
    	p[u] = (float)image[u];
    }

    free(image);

}

void cam_read_ccd( struct camprop *cam, float *p )
{
    libcam_log( LOG_DEBUG, "cam_read_ccd : debut" );
    libcam_log( LOG_INFO, "Début lecture CCD" );
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_read_ccd : camera not initialized" );
         sprintf( cam->msg, "camera not initialized" );
         return;
    }
    if ( p == NULL )
        return;

    if ( cam->params->abort == 1 )
    {
        cam->params->abort = 0;
        sprintf( cam->msg, "acq stopped by user" );
        return;
    }

    if ( cam->authorized == 1 )
    {
        try
        {
            // attente que l'image soit prete
            bool image_prete = false;
            cam->params->qsicam->get_ImageReady( &image_prete );
            while( !image_prete )
            {
                usleep( 5000 );
            	libcam_log( LOG_DEBUG, "cam_read_ccd : attente de 5 ms" );
                cam->params->qsicam->get_ImageReady( &image_prete );
            }
            double temps_exposition;
            cam->params->qsicam->get_LastExposureDuration( &temps_exposition );
            libcam_log( LOG_DEBUG, "cam_read_ccd : temps exposition réel : %f", temps_exposition );
            if ( debug_level == LOG_DEBUG )
            {
            	int x, y, z;
            	cam->params->qsicam->get_ImageArraySize( x, y, z );
            	libcam_log( LOG_DEBUG, "cam_read_ccd : taille %d x %d, profondeur en octet %d", x, y, z );
            	if ( ( x != cam->w ) || ( y != cam->h ) ) {
            		libcam_log( LOG_ERROR, "Image size not consistent : actual width %d / expected width %d / actual height %d / expected height %d", x, cam->w, y, cam->h );
            	}
            }

            QSICamera::CameraState etat;
            cam->params->qsicam->get_CameraState( &etat );
      		libcam_log( LOG_DEBUG, "cam_read_ccd : etat=%d", etat );

            get_image( cam, p );
            libcam_log( LOG_DEBUG, "cam_read_ccd OK" );
        }
        catch ( std::runtime_error &err )
        {
            std::string text = err.what();
            libcam_log( LOG_ERROR, text.c_str() );
            std::string last("");
            cam->params->qsicam->get_LastError( last );
            sprintf( cam->msg, "%s\n", last.c_str() );
            libcam_log( LOG_ERROR, last.c_str() );
        }
    }
    libcam_log( LOG_DEBUG, "cam_read_ccd fin" );
    libcam_log( LOG_INFO, "Fin lecture CCD" );
}

void cam_shutter_on(struct camprop *cam)
{
}

void cam_shutter_off(struct camprop *cam)
{
}

void cam_ampli_on(struct camprop *cam)
{
}

void cam_ampli_off(struct camprop *cam)
{
}

void cam_measure_temperature( struct camprop *cam )
{
    libcam_log( LOG_DEBUG, "cam_measure_temperature début" );
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_measure_temperature camera not initialized" );
         sprintf( cam->msg, "cam_measure_temperature camera not initialized" );
         return;
    }
    cam->temperature = 0.0;
    try
    {
        cam->params->qsicam->get_CCDTemperature( &cam->temperature );
        libcam_log( LOG_DEBUG,"temperature = %.1f", cam->temperature );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
    }
    libcam_log( LOG_DEBUG,"cam_measure_temperature fin OK." );
}

void cam_cooler_on( struct camprop *cam )
{
    libcam_log( LOG_DEBUG,"cam_cooler_on debut" );
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_cooler_on camera not initialized" );
         sprintf( cam->msg, "cam_cooler_on camera not initialized" );
         return;
    }
    try
    {
        cam->params->qsicam->put_CoolerOn( true );
        libcam_log( LOG_DEBUG, "cam_cooler_on fin OK" );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
    }
}

void cam_cooler_off( struct camprop *cam )
{
    libcam_log( LOG_DEBUG,"cam_cooler_off debut" );
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_cooler_off camera not initialized" );
         sprintf( cam->msg, "cam_cooler_off camera not initialized" );
         return;
    }
    try
    {
        cam->params->qsicam->put_CoolerOn( false );
        libcam_log( LOG_DEBUG, "cam_cooler_off fin OK" );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
    }
}

void cam_cooler_check( struct camprop *cam )
{
    libcam_log( LOG_DEBUG, "cam_cooler_check debut" );
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_cooler_check camera not initialized" );
         sprintf( cam->msg, "cam_cooler_check camera not initialized" );
         return;
    }
    try
    {
        libcam_log( LOG_DEBUG, "Température de consigne = %.1f", cam->check_temperature );
        cam->params->qsicam->put_SetCCDTemperature( cam->check_temperature );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
    }
    libcam_log( LOG_DEBUG, "cam_cooler_check fin OK" );
}

void qsiGetTemperatureInfo( struct camprop *cam, double *setTemperature, double *ccdTemperature, double *ambientTemperature, int *regulationEnabled, int *power )
{
    libcam_log( LOG_DEBUG, "cam_get_info_temperature debut" );
    if ( cam->params->qsicam == 0 )
    {
         libcam_log( LOG_ERROR, "cam_get_info_temperature camera not initialized" );
         sprintf( cam->msg, "cam_get_info_temperature camera not initialized" );
         return;
    }

    try
    {
        // Temp. de consigne du capteur
        cam->params->qsicam->get_SetCCDTemperature( setTemperature );
        // Temp. réelle du capteur
        cam->params->qsicam->get_CCDTemperature( ccdTemperature );
        // Temp. du dissipateur
        cam->params->qsicam->get_HeatSinkTemperature( ambientTemperature );

        *regulationEnabled = 0;
        bool cooler_on = false;
        cam->params->qsicam->get_CoolerOn( &cooler_on );
        libcam_log( LOG_DEBUG, "Refroidissement = %d", cooler_on );
        if ( cooler_on )
            *regulationEnabled = 1;

        // La puissance de refroidissement est exprimée directement en pourcentage
        double puissance;
        cam->params->qsicam->get_CoolerPower( &puissance );
        *power = (int)puissance;
        libcam_log( LOG_INFO, "cam_get_info_temperature fin Temp. CCD=%.1f  Temp. consigne=%.1f Temp. dissipateur=%.1f puissance=%d regulation=%d",
            *ccdTemperature,
            *setTemperature,
            *ambientTemperature,
            *power,
            *regulationEnabled );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
    }
    libcam_log( LOG_DEBUG,"cam_get_info_temperature fin OK" );
}

void cam_set_binning( int binx, int biny, struct camprop *cam )
{
    libcam_log( LOG_DEBUG, "cam_set_binning : debut. binx=%d biny=%d", binx, biny );
    if ( cam->params->qsicam == 0 ) {
        libcam_log( LOG_ERROR,"cam_set_binning camera not initialized" );
        sprintf( cam->msg, "cam_set_binning camera not initialized" );
        return;
    }
    try {
    	/* Vérification préalable */
    	short int binx_courant;
    	short int biny_courant;
        cam->params->qsicam->get_BinX( &binx_courant );
        cam->params->qsicam->get_BinY( &biny_courant );
        libcam_log( LOG_DEBUG, "cam_set_binning : ancien_binx = %d ancien_biny=%d", binx_courant, biny_courant );
		if ( ( binx_courant != cam->binx ) || ( biny_courant != cam->biny ) ) {
			libcam_log( LOG_ERROR, "Error : Inconsistent bin values : stored binx %d / actual binx %d / stored biny %d / actual biny %d", cam->binx, binx_courant, cam->biny, biny_courant );
		}

		long largeur_reelle, hauteur_reelle;
		long x_reel, y_reel;

        short max_binx;
        cam->params->qsicam->get_MaxBinX( &max_binx );
        if ( binx >  max_binx )
        {
            libcam_log( LOG_ERROR, "Error: binning X is greater than %d", max_binx );
            sprintf( cam->msg, "Error: binning X is greater than %d", max_binx );
            return;
        }

        short max_biny;
        cam->params->qsicam->get_MaxBinY( &max_biny );
        if ( biny > max_biny )
        {
            libcam_log( LOG_ERROR, "Error: binning Y is greater than %d", max_biny );
            sprintf( cam->msg, "Error: binning Y is greater than %d", max_biny );
            return;
        }
        cam->binx = binx;
        cam->biny = biny;
        cam->w = ( cam->x2 - cam->x1 + 1 ) / cam->binx;
        cam->h = ( cam->y2 - cam->y1 + 1 ) / cam->biny;
        libcam_log( LOG_DEBUG, "cam_set_binning : x1 = %d / y1 = %d / x2 = %d / y2 = %d", cam->x1, cam->y1, cam->x2, cam->y2 );
        libcam_log( LOG_DEBUG, "cam_set_binning : binx = %d / biny = %d", cam->binx, cam->biny );
        cam->params->qsicam->put_NumX( cam->w );
        cam->params->qsicam->put_NumY( cam->h );
        cam->params->qsicam->put_BinX( binx );
        cam->params->qsicam->put_BinY( biny );

        /* Vérifications */
        cam->params->qsicam->get_BinX( &binx_courant );
        cam->params->qsicam->get_BinY( &biny_courant );
        libcam_log( LOG_DEBUG, "cam_set_binning : binx_reel = %d biny_reel = %d", binx_courant, biny_courant );
		if ( ( binx_courant != cam->binx ) || ( biny_courant != cam->biny ) ) {
			libcam_log( LOG_ERROR, "Error : Inconsistent bin values : stored binx %d / actual binx %d / stored biny %d / actual biny %d", cam->binx, binx_courant, cam->biny, biny_courant );
		}
        cam->params->qsicam->get_NumX( &largeur_reelle );
        cam->params->qsicam->get_NumY( &hauteur_reelle );
        libcam_log( LOG_DEBUG, "cam_set_binning : largeur_reelle = %ld hauteur_reelle = %ld", largeur_reelle, hauteur_reelle );
		if ( ( largeur_reelle != cam->w ) || ( hauteur_reelle != cam->h ) ) {
			libcam_log( LOG_ERROR, "Error : Inconsistent dim values : stored width %ld / actual width %ld / stored height %ld / actual height %ld", cam->w, largeur_reelle, cam->h, hauteur_reelle );
		}
        cam->params->qsicam->get_StartX( &x_reel );
        cam->params->qsicam->get_StartY( &y_reel );
        libcam_log( LOG_DEBUG, "cam_set_binning : x_reel = %ld y_reel = %ld", x_reel, y_reel );
		if ( ( x_reel != cam->x1 ) || ( y_reel != cam->y1 ) ) {
			libcam_log( LOG_ERROR, "Error : Inconsistent start point : stored x %ld / actual x %ld / stored y %ld / actual y %ld", cam->x1, x_reel, cam->y1, y_reel );
		}

        libcam_log( LOG_DEBUG, "cam_set_binning apres : binx=%d biny=%d", binx, biny );
        libcam_log( LOG_DEBUG, "cam_set_binning : fin OK" );
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
    }
}



// ---------------------------------------------------------------------------
// qsiSetupDialog
//    affiche la fenetre de configuration fournie par le driver de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------

void qsiSetupDialog(struct camprop *cam) {}

// ---------------------------------------------------------------------------
// qsiSetWheelPosition
//    change la position de la roue a filtre
// @ param  pointeur des donnees de la camera
// @ param  position  Position is a  number between 0 and N-1, where N is the number of filter slots (see Filter.Names).
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiSetWheelPosition( struct camprop *cam, int position )
{
    libcam_log( LOG_DEBUG, "Changement filtre : position=%d", position );
    if ( cam->params->qsicam == 0 )
    {
        libcam_log( LOG_ERROR,"qsiSetWheelPosition camera not initialized" );
        sprintf( cam->msg, "qsiSetWheelPosition camera not initialized" );
        return -1;
    }
    try
    {
        bool has_filter_wheel;
        cam->params->qsicam->get_HasFilterWheel( &has_filter_wheel );
        if ( has_filter_wheel )
        {
            int filtres;
            cam->params->qsicam->get_FilterCount( filtres );
            // Position : Starts filter wheel rotation immediately when written.
            cam->params->qsicam->put_Position( (short)position );
            // Init à une valeur positive mais nécessairement fausse
            short retour_position = filtres + 10;
            while ( position != retour_position ) {
                cam->params->qsicam->get_Position( &retour_position );
                sleep(1);
            }
            libcam_log( LOG_INFO, "Roue à filtre en position %d", retour_position );
            return 0;
        }
        else
        {
            sprintf( cam->msg, "Camera has no filter wheel" );
            return -1;
        }
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

// ---------------------------------------------------------------------------
// qsiGetWheelPosition
//    récupère la position de la roue a filtre
// return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelPosition( struct camprop *cam, int *position )
{
    libcam_log( LOG_DEBUG, "qsiGetWheelPosition debut." );
    if ( cam->params->qsicam == 0 )
    {
        libcam_log( LOG_ERROR,"qsiGetWheelPosition camera not initialized" );
        sprintf( cam->msg, "qsiGetWheelPosition camera not initialized" );
        return -1;
    }
    try
    {
        bool has_filter_wheel;
        cam->params->qsicam->get_HasFilterWheel( &has_filter_wheel );
        if ( has_filter_wheel )
        {
            int filtres;
            cam->params->qsicam->get_FilterCount( filtres );
            // Init à une valeur positive mais nécessairement fausse
            *position = filtres + 10;
            // Reading the property gives current slot number (if wheel stationary)
            // or -1 if wheel is moving.
            cam->params->qsicam->get_Position( (short*)position );
            libcam_log( LOG_INFO, "Roue à filtre en position %d", *position );
            return 0;
        }
        else
        {
            *position = -1;
            sprintf( cam->msg, "Camera has no filter wheel" );
            return -1;
        }
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

// ---------------------------------------------------------------------------
// qsiGetWheelNames
//    retourne les noms des positions de la roue filtre
// @param **names  : pointeur de pointeur de chaine de caracteres
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelNames( struct camprop *cam, char **names )
{
    libcam_log( LOG_DEBUG, "qsiGetWheelNames debut" );
    if ( cam->params->qsicam == 0 ) {
        libcam_log( LOG_ERROR, "qsiGetWheelNames camera not initialized" );
        sprintf( cam->msg, "qsiGetWheelNames camera not initialized" );
       return -1;
    }
    try
    {
        bool has_filter_wheel;
        cam->params->qsicam->get_HasFilterWheel( &has_filter_wheel );
        if ( has_filter_wheel )
        {
            int filtres;
            cam->params->qsicam->get_FilterCount( filtres );
            libcam_log( LOG_INFO, "Nombre de positions de la roue à filtre : %d", filtres );
            std::string * noms = new std::string[filtres];
            long * dec_map = new long[filtres];
            /* Allocation. La libération sera faite dans la routine appelante */
            *names = (char*) calloc( filtres, 256 );
            libcam_log( LOG_DEBUG, "qsiGetWheelNames avant GetNames filter Wheel : noms = %p, dec_map = %p", noms, dec_map );
            cam->params->qsicam->get_Names( noms );
            cam->params->qsicam->get_FocusOffset( dec_map );
            for ( int i = 0; i < filtres ; i++ )
            {
                strcat( *names, "{ " );
                if ( noms[i].length() > 0 )
                {
                    strncat( *names, noms[i].c_str(), 253 );
                    libcam_log( LOG_DEBUG, "nom_filtre[%d] = %s", i, noms[i].c_str() );
                }
                else
                    libcam_log( LOG_DEBUG, "nom_filtre[%d] = <vide>" );
                strcat( *names, " } ");
            }
            libcam_log( LOG_INFO, "Nom des filtres=%s", *names );
            libcam_log( LOG_DEBUG, "qsiGetWheelNames fin" );
            delete[] noms;
            delete[] dec_map;
            return 0;
        }
        else
        {
            sprintf( cam->msg, "Camera has no filter wheel" );
            return -1;
        }
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}

// ---------------------------------------------------------------------------
// qsiPutWheelNames
//    fixe le noms d'une position de la roue filtre
// @param **names  : pointeur de pointeur de chaine de caracteres
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------
int qsiPutWheelNames( struct camprop *cam, int position, const char* nom_filtre )
{
    libcam_log( LOG_DEBUG, "qsiPutWheelNames debut" );
    if ( cam->params->qsicam == 0 ) {
        libcam_log( LOG_ERROR, "qsiPutWheelNames camera not initialized" );
        sprintf( cam->msg, "qsiPutWheelNames camera not initialized" );
       return -1;
    }
    try
    {
        bool has_filter_wheel;
        cam->params->qsicam->get_HasFilterWheel( &has_filter_wheel );
        if ( has_filter_wheel )
        {
            int filtres;
            cam->params->qsicam->get_FilterCount( filtres );
            libcam_log( LOG_INFO, "Nombre de positions de la roue à filtre : %d", filtres );
            if ( ( position >= 0 ) && ( position < filtres ) ) {
                std::string * noms = new std::string[filtres];
                libcam_log( LOG_DEBUG, "qsiPutWheelNames avant GetNames filter wheel : noms = %p", noms );
                cam->params->qsicam->get_Names( noms );
                noms[position].assign( nom_filtre );
                libcam_log( LOG_DEBUG, "qsiPutWheelNames avant PutNames filter wheel : noms = %p", noms );
                cam->params->qsicam->put_Names( noms );
                delete[] noms;
            }
            else
            {
                sprintf( cam->msg, "%d : Illegal position for the filter wheel", position );
                return -1;
            }
        }
        else
        {
            sprintf( cam->msg, "Camera has no filter wheel" );
            return -1;
        }
        libcam_log( LOG_DEBUG, "qsiPutWheelNames fin" );
        return 0;
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}


// ---------------------------------------------------------------------------
// qsiGetWheelNames
//    retourne les noms des positions de la roue filtre
// @param **names  : pointeur de pointeur de chaine de caracteres
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetProperty( struct camprop *cam, const char *propertyName, char *propertyValue )
{
    if ( cam->params->qsicam == 0 ) {
        libcam_log( LOG_ERROR, "qsiGetProperty camera not initialized");
        sprintf(cam->msg, "qsiGetProperty camera not initialized");
        return -1;
    }
    try
    {
        if ( strcmp( propertyName, "MaxBinX" ) == 0 ) {
            short max_binx;
            cam->params->qsicam->get_MaxBinX( &max_binx );
            sprintf( propertyValue,"%d", max_binx );
        }
        else if ( strcmp( propertyName, "MaxBinY" ) == 0 ) {
            short max_biny;
            cam->params->qsicam->get_MaxBinY( &max_biny );
            sprintf( propertyValue,"%d", max_biny );
        }
        return 0;
    }
    catch ( std::runtime_error &err )
    {
        std::string text = err.what();
        libcam_log( LOG_ERROR, text.c_str() );
        std::string last("");
        cam->params->qsicam->get_LastError( last );
        sprintf( cam->msg, "%s\n", last.c_str() );
        libcam_log( LOG_ERROR, last.c_str() );
        return -1;
    }
}
