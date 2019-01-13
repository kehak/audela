/* gp_api.c .
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

// $Id: gp_api.c,v 1.2 2006-06-07 18:22:41 michelpujol Exp $

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <fcntl.h>
#ifdef WIN32
#include <io.h>
#endif

#ifdef WIN32
#define SLEEP(t)  Sleep(t)
#else
#define SLEEP(t)  usleep(t*1000)
#endif

#include <gphoto2-camera.h>         // pour libgphoto
#include <gphoto2-abilities-list.h>
#include <gphoto2-context.h>
#include <gphoto2-port-log.h>
#ifdef WIN32
#include <usb.h>                    // pour libusb
#endif
#include "gp_api.h"

// =========== local definiton and types ===========
#define CR(result)       {int r=(result); if (r<0) return GPAPI_ERROR;}

#define MAX_FILE_LEN   1024

#ifndef MAX
#define MAX(x, y) (((x)>(y))?(x):(y))
#endif
#ifndef MIN
#define MIN(x, y) (((x)<(y))?(x):(y))
#endif

#ifdef WIN32
#define GP_SYSTEM_DIR_DELIM		'\\'
#else
#define GP_SYSTEM_DIR_DELIM		'/'
#endif


struct _GPParams {
   Camera *camera;
   GPContext *context;
   CameraAbilitiesList *abilities_list;
   GPPortInfoList *portList;
   CameraList *previousFileList;
   int debug_func_id;
   CameraWidget *config;
   char lastErrorMesssage[1024];
   
#ifdef WIN32
   char gphotoWinDllDir[1024];     // libgphoto2 DLL directory
#endif
};


// =========== local functions prototypes ===========
void ctx_status_func (GPContext *context, const char *format, va_list args, void *data);
void ctx_error_func (GPContext *context, const char *format, va_list args, void *data);
GPContextFeedback ctx_cancel_func (GPContext *context, void *data);
void ctx_message_func (GPContext *context, const char *format, va_list args, void *data);
//void debug_func (GPLogLevel level, const char *domain, const char *format, va_list args, void *data);

int action_camera_set_port (GPParams *params, const char *port);


/**
 * gpapi_init
 * reserve les ressources pour une connexion
 *    malloc GPARAM
 *		p->folder = "/"
 *		p->camera = malloc()
 *		p->context = malloc()
 *		p->abilities_list = malloc()
 */
int gpapi_init(GPParams **gpparams, char * gphotoWinDllDir)
{
   int count;
   GPParams *p;
   
   p = malloc(sizeof(GPParams));
   if (!p)
      return GPAPI_ERROR;
   
   memset (p, 0, sizeof (GPParams));
      
#ifdef WIN32   
   strcpy(p->gphotoWinDllDir, gphotoWinDllDir);
#endif
   
   gp_camera_new (&p->camera);
   
   // activation/desactivation des traces de deboggage de libgphoto2
   p->debug_func_id = -1;
   //p->debug_func_id = gp_log_add_func (GP_LOG_ALL, debug_func, NULL);
   
   // Create a context. Report progress only if users will see it.
   p->context = gp_context_new ();
   gp_context_set_cancel_func    (p->context, ctx_cancel_func,  NULL);
   gp_context_set_error_func     (p->context, ctx_error_func,   p->lastErrorMesssage);
   gp_context_set_status_func    (p->context, ctx_status_func,  NULL);
   gp_context_set_message_func   (p->context, ctx_message_func, NULL);
   
   // charge la liste dll des APN presentes( PTP, canon, ...)
   gp_abilities_list_new (&p->abilities_list);
#ifdef WIN32
   gp_abilities_list_load_dir (p->abilities_list, p->gphotoWinDllDir , p->context);
#else
   gp_abilities_list_load (p->abilities_list, p->context);
#endif
   count = gp_abilities_list_count(p->abilities_list);
   printf("Nombre de type de camera supportes = %d \n", count);
   
   // charge les dll des types de port (serial et usb)
   CR (gp_port_info_list_new (&p->portList));
#ifdef WIN32
   CR (gp_port_info_list_load_dir (p->portList, p->gphotoWinDllDir));
#else
   CR (gp_port_info_list_load (p->portList));
#endif
   count = gp_port_info_list_count(p->portList);
   printf("Nombre de type de port supporte = %d \n", count);
   
   CR (gp_list_new (&p->previousFileList)); 
   
   *gpparams = p;
   
   return GPAPI_OK;   
}



/**
 * libere les ressources d'une connexion
 */
int gpapi_exit (GPParams *gpparams)
{
	if (!gpparams)
		return GPAPI_ERROR;

	if (gpparams->abilities_list)
		gp_abilities_list_free (gpparams->abilities_list);
	if (gpparams->portList)
		gp_port_info_list_free (gpparams->portList);
	if (gpparams->camera)
		gp_camera_unref (gpparams->camera);
	if (gpparams->context)
		gp_context_unref (gpparams->context);
	memset (gpparams, 0, sizeof (GPParams));

  	CR (gp_list_free (gpparams->previousFileList));

   free(gpparams);

    return GPAPI_OK;
}


int gpapi_detect(GPParams *gpparams, char *cameraModel, char *cameraPath)
{
	int count;
   int i;
	CameraList *cameraList;
   const char *model = NULL, *path = NULL;

 #ifdef WIN32
   // load libusb (for Windows)
   usb_init();
#endif

   // recherche des APN présents 
    CR (gp_list_new (&cameraList)); 
    CR (gp_abilities_list_detect(gpparams->abilities_list, gpparams->portList, cameraList, gpparams->context));
    count = gp_list_count (cameraList);
    printf("Detect : camera count = %d \n", count);

    if( count > 0 ) {
        for (i=0; i <count ; i++ ) {
   		 CR (gp_list_get_name (cameraList, i, &model));
		    CR (gp_list_get_value (cameraList, i, &path));
		    printf("Detect : cameraModel=%s, cameraPath=%s \n", model, path);		       
        }
    } else  {
        return GPAPI_ERROR;
    }
    
    // par defaut, je selectionne la camera numero 0
	CR (gp_list_get_name (cameraList, 0, &model));
   CR (gp_list_get_value (cameraList, 0, &path));
   strcpy(cameraModel, model);
   strcpy(cameraPath, path);
	
    // libere les listes temporaires
	CR (gp_list_free (cameraList));
   return GPAPI_OK;

}


int gpapi_open(GPParams *gpparams, char * cameraModel, char *path)
{
   CameraAbilities a;
	int m;

    // set camera model
	CR (m = gp_abilities_list_lookup_model (gpparams->abilities_list, cameraModel));
	CR (gp_abilities_list_get_abilities (gpparams->abilities_list, m, &a));
	CR (gp_camera_set_abilities (gpparams->camera, a));
	CR (action_camera_set_port (gpparams, path));             
	CR (gp_camera_init(gpparams->camera, gpparams->context));
   return GPAPI_OK;

}


int gpapi_getsummary (GPParams *gpparams)
{
	CameraText text;

	CR (gp_camera_get_summary (gpparams->camera, &text, gpparams->context));

	printf ("Camera summary:");
	printf ("\n%s\n", text.text);

    return GPAPI_OK;

}


int gpapi_close (GPParams *gpparams)
{

    return GPAPI_OK;

}



int gpapi_setExternalRemoteCapture (GPParams *gpparams, int value)
{
   CameraWidget *driverWidget = NULL;
   CameraWidget *externalRemoteWidget = NULL;
   CameraWidget *transfertModeWidget = NULL;
   int ivalue;
   

   
   printf ("gpapi_prepareExternalRemoteCapture  debut");
   
   if ( gpparams->config == NULL)  {
      CR (gp_camera_get_config( gpparams->camera, &gpparams->config, gpparams->context));      
   }
   
   CR(gp_widget_get_child_by_label (gpparams->config, "Driver", &driverWidget));
   CR(gp_widget_get_child_by_label (driverWidget, "External remote", &externalRemoteWidget));
   ivalue = value;
   CR(gp_widget_set_value(externalRemoteWidget, &ivalue ));
   CR(gp_widget_get_child_by_label (driverWidget, "Transfert Mode", &transfertModeWidget));
   ivalue = 8;
   CR(gp_widget_set_value(transfertModeWidget, &ivalue ));
   CR(gp_camera_set_config(gpparams->camera, gpparams->config, gpparams->context));
   printf ("gpapi_prepareExternalRemoteCapture  FIN \n");
   return GPAPI_OK;
}

/** 
 *  gpapi_captureImage
 *
 *  parameters : 
 *     cameraFolder (OUT) :  current folder  in camera memory card
 *     fileName (OUT)     :  file name  in camera memory card
 */
int gpapi_captureImage (GPParams *gpparams,  char * cameraFolder, char *fileName)
{
   int result ;
   CameraFilePath path;
   
   result = gp_camera_capture (gpparams->camera, GP_CAPTURE_IMAGE, &path, gpparams->context);
   if( result == GP_OK) {
      strcpy(cameraFolder, path.folder);
      strcpy(fileName, path.name);
   }
   
   return result;
}

/** 
 *  gpapi_captureImageDirectToPC
 *
 *  parameters : 
 *     cameraFolder (IN) :  current folder  in camera memory card
 *     fileName     (IN):  file name  in camera memory card
 */
int gpapi_captureImageDirectToPC (GPParams *gpparams, char * cameraFolder, char *fileName)
{
   CameraFile  *cameraFile;

   CR (gp_file_new (&cameraFile));
   CR( gp_camera_capture_image(gpparams->camera, cameraFile, gpparams->context));
   CR (gp_file_save(cameraFile, fileName));
   CR (gp_file_unref(cameraFile));
   return (GPAPI_OK);
}

//  CameraFileType
//	    GP_FILE_TYPE_PREVIEW,
//	    GP_FILE_TYPE_NORMAL,
//	    GP_FILE_TYPE_RAW,
//	    GP_FILE_TYPE_AUDIO,
//	    GP_FILE_TYPE_EXIF


/**
  * loadImage
  *     load image from camera to disk
  */
int gpapi_loadImage (GPParams *gpparams,  char * cameraFolder, char *fileName, char **imageData, unsigned long *imageSize, char *mimeType)
{
    CameraFile *cameraFile;
    CameraFileType fileType;
    const char * data;
    const char * mime;
    unsigned long size;
    int result;

    

    fileType = GP_FILE_TYPE_NORMAL;

    gp_file_new (&cameraFile);
    result = gp_camera_file_get (gpparams->camera, cameraFolder, fileName, fileType, cameraFile, gpparams->context);
    if( result == GPAPI_OK ) {
       gp_file_get_data_and_size (cameraFile, &data, &size); 
       gp_file_get_mime_type(cameraFile, &mime);
       
       *imageData = malloc( size);
       if( *imageData != NULL) {
          memcpy(*imageData, data, size);
          *imageSize = size;
          strcpy(mimeType, mime);
          result = GPAPI_OK;
       } else {
          result = GPAPI_ERROR;
       }
       
    }
    gp_file_unref(cameraFile);        
    return result;
}

/**
  * loadImage
  *     load preview from camera to disk
  */
int gpapi_loadPreview (GPParams *gpparams,  char * cameraFolder, char * destinationFolder, char *fileName, char *prefix)
{
    CameraFile *cameraFile;
    CameraFileType fileType;
    char destPath[MAX_FILE_LEN];
    int result;

    fileType = GP_FILE_TYPE_PREVIEW;
    sprintf(destPath, "%s%c%s%s",destinationFolder, GP_SYSTEM_DIR_DELIM, prefix, fileName);

    // charge le fichier en memeoire
    CR (gp_file_new (&cameraFile));
    result = gp_camera_file_get (gpparams->camera, cameraFolder, fileName, fileType, cameraFile, gpparams->context);
    SLEEP(3000);

    // enregistre le fichier sur disque
    CR (gp_file_save(cameraFile, destPath));
    CR (gp_file_unref(cameraFile));
        
    return (GPAPI_OK);
}

/**
  * deleteImage
  *     delete image 
  *  parameters : 
  *     cameraFolder (IN) :  folder  in camera memory card
  *     fileName (IN)     :  file name  in camera memory card
  */
int gpapi_deleteImage (GPParams *gpparams,  char * cameraFolder, char *fileName)
{
    CR (gp_camera_file_delete (gpparams->camera, cameraFolder, fileName, gpparams->context))
        
    return (GPAPI_OK);
}

/**
  * gpapi_getTimeValue
  *     get release time value  ( 
  *  parameters : 
  *     timeValue (OUT) :  exposure  time ( "1/1000", "1/500" , ... "0.1", "1", ... )
  */
int gpapi_getTimeValue (GPParams *gpparams, float * timeValue, int *driveMode, char *quality)
{
   CameraWidget *releaseWidget = NULL;
   CameraWidget *timeValueWidget = NULL;
   CameraWidget *driveModeWidget = NULL;
   CameraWidget *qualityWidget = NULL;
   char *qualityPtr;

   if ( gpparams->config == NULL)  {
      CR (gp_camera_get_config( gpparams->camera, &gpparams->config, gpparams->context));      
   }
   
   CR(gp_widget_get_child_by_label (gpparams->config, "Release", &releaseWidget));
   CR(gp_widget_get_child_by_label (releaseWidget, "Time value", &timeValueWidget));
   CR(gp_camera_get_config( gpparams->camera, &timeValueWidget, gpparams->context)); 
   CR(gp_widget_get_value(timeValueWidget, &timeValue));
   
   CR(gp_widget_get_child_by_label (releaseWidget, "Drive mode", &driveModeWidget));
   CR (gp_camera_get_config( gpparams->camera, &driveModeWidget, gpparams->context)); 
   CR(gp_widget_get_value(driveModeWidget, &driveMode));

   CR(gp_widget_get_child_by_label (releaseWidget, "Quality", &qualityWidget));
   CR (gp_camera_get_config( gpparams->camera, &qualityWidget, gpparams->context)); 
   CR(gp_widget_get_value(qualityWidget, &qualityPtr));
   strcpy(quality,qualityPtr);

   return GPAPI_OK;
}


/**
  * gpapi_setTimeValue
  *     set release time value 
  *  parameters : 
  *     timeValue (IN) :  exposure  time ( "1/1000", "1/500" , ... "0.1", "1", ... )
  */

int gpapi_setTimeValue (GPParams *gpparams, float timeValue, int driveMode, char *quality)
{
   CameraWidget *releaseWidget = NULL;
   CameraWidget *timeValueWidget = NULL;
   CameraWidget *driveModeWidget = NULL;
   CameraWidget *qualityWidget = NULL;
   
   if ( gpparams->config == NULL)  {
      CR (gp_camera_get_config( gpparams->camera, &gpparams->config, gpparams->context));      
   }
   
   CR(gp_widget_get_child_by_label (gpparams->config, "Release", &releaseWidget));

   CR(gp_widget_get_child_by_label (releaseWidget, "Time value", &timeValueWidget));
   CR(gp_widget_set_value(timeValueWidget, &timeValue));
   CR(gp_camera_set_config( gpparams->camera, timeValueWidget, gpparams->context)); 

   CR(gp_widget_get_child_by_label (releaseWidget, "Drive mode", &driveModeWidget));
   CR(gp_widget_set_value(driveModeWidget, &driveMode));
   CR(gp_camera_set_config( gpparams->camera, driveModeWidget, gpparams->context)); 

   CR(gp_widget_get_child_by_label (releaseWidget, "Quality", &qualityWidget));
   CR(gp_widget_set_value(qualityWidget, quality));
   CR(gp_camera_set_config( gpparams->camera, qualityWidget, gpparams->context)); 
   return GPAPI_OK;
}



//==================== local functions ======================
void ctx_status_func (GPContext *context, const char *format, va_list args, void *data)
{
   printf  ( "status : ");
        vprintf (format, args);
        printf  ( "\n");
}

void ctx_error_func (GPContext *context, const char *format, va_list args, void *data)
{
   if (data != NULL) {
      vsprintf ( data, format, args);
   }
}

/*
void debug_func (GPLogLevel level, const char *domain, const char *format, va_list args, void *data)
{

	printf ( "%s(%i): ", domain, level);
	vprintf (format, args);
    printf  ( "\n");
}
*/

GPContextFeedback ctx_cancel_func (GPContext *context, void *data)
{
	return (GP_CONTEXT_FEEDBACK_OK);
}

void ctx_message_func (GPContext *context, const char *format, va_list args, void *data)
{
        //int c;
        vprintf (format, args);
        putchar ('\n');

        /* Only ask for confirmation if the user can give it. */
        //printf ("Press any key to continue.\n");
        //c = getchar();
}


int action_camera_set_port (GPParams *params, const char *port)
{
	GPPortInfoList *il = NULL;
	int p, r;
	GPPortInfo info;
	char verified_port[1024];

	verified_port[sizeof (verified_port) - 1] = '\0';
	if (!strchr (port, ':')) {
		gp_log (GP_LOG_DEBUG, "main", "Ports must look like "
			"'serial:/dev/ttyS0' or 'usb:', but '%s' is "
			"missing a colon so I am going to guess what you "
			"mean.", port);
		if (!strcmp (port, "usb")) {
			strncpy (verified_port, "usb:",
				 sizeof (verified_port) - 1);
		} else if (strncmp (port, "/dev/", 5) == 0) {
			strncpy (verified_port, "serial:",
				 sizeof (verified_port) - 1);
			strncat (verified_port, port,
				 sizeof (verified_port)
				 	- strlen (verified_port) - 1);
		} else if (strncmp (port, "/proc/", 6) == 0) {
			strncpy (verified_port, "usb:",
				 sizeof (verified_port) - 1);
			strncat (verified_port, port,
				 sizeof (verified_port)
				 	- strlen (verified_port) - 1);
		}
		gp_log (GP_LOG_DEBUG, "main", "Guessed port name. Using port "
			"'%s' from now on.", verified_port);
	} else
		strncpy (verified_port, port, sizeof (verified_port) - 1);

	/* Create the list of ports and load it. */
	r = gp_port_info_list_new (&il);
	if (r < 0)
		return (r);
#ifdef WIN32
   r = gp_port_info_list_load_dir (il, params->gphotoWinDllDir);
#else   
   r = gp_port_info_list_load (il);
#endif

	if (r < 0) {
		gp_port_info_list_free (il);
		return (r);
	}

	/* Search our port in the list. */
	p = gp_port_info_list_lookup_path (il, verified_port);
	switch (p) {
	case GP_ERROR_UNKNOWN_PORT:
		printf ("The port you specified "
			"('%s') can not be found. Please "
			"specify one of the ports found by "
			"'gphoto2 --list-ports' and make "
			"sure the spelling is correct "
			"(i.e. with prefix 'serial:' or 'usb:').",
				verified_port);
		break;
	default:
		break;
	}
	if (p < 0) {
		gp_port_info_list_free (il);
		return (p);
	}

	/* Get info about our port. */
	r = gp_port_info_list_get_info (il, p, &info);
	gp_port_info_list_free (il);
	if (r < 0)
		return (r);

	/* Set the port of our camera. */
	r = gp_camera_set_port_info (params->camera, info);
	if (r < 0)
		return (r);

	return (GP_OK);
}


char * gpapi_getLastErrorMessage(GPParams *params)
{
   return params->lastErrorMesssage;

}