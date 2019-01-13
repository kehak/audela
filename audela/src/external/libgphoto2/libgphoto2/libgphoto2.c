// libgphoto2.cpp : Defines the entry point for the DLL application.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <config.h>

#include <gphoto2/gphoto2-camera.h>         
#include <gphoto2/gphoto2-filesys.h>         
#include <gphoto2/gphoto2-abilities-list.h>
#include <gphoto2/gphoto2-context.h>
#include <gphoto2/gphoto2-port-log.h>
#include "libgphoto2.h"

// =========== local definiton and types ===========
#define CR(result)       {int r=(result); if (r<0) return result;}

#define MAX_FILE_LEN   1024

#ifdef WIN32
#define GP_SYSTEM_DIR_DELIM		'\\'
#else
#define GP_SYSTEM_DIR_DELIM		'/'
#endif


struct _GPhotoSession {
   Camera *camera;
   GPContext *context;
   CameraAbilitiesList *abilities_list;
   GPPortInfoList *portList;
   CameraList *previousFileList;
   int debug_func_id;
   CameraWidget *config;
   char lastErrorMesssage[1024];
};

// =========== local functions prototypes ===========
void ctx_status_func (GPContext *context, const char *format, void *data);
void ctx_error_func (GPContext *context, const char *format, void *data);
GPContextFeedback ctx_cancel_func (GPContext *context, void *data);
void ctx_message_func (GPContext *context, const char *format, void *data);
void debug_func (GPLogLevel level, const char *domain, const char *format, void *data);

int action_camera_set_port (GPhotoSession *params, const char *port);


FILE* logFileHandle = NULL ;
void debugstdout_func (GPLogLevel level, const char *domain, const char *format, void *data);
/**
 * libgphoto_init
 * reserve les ressources pour une connexion
 *    malloc GPARAM
 *		p->folder = "/"
 *		p->camera = malloc()
 *		p->context = malloc()
 *		p->abilities_list = malloc()
 */
int libgphoto_openSession(GPhotoSession **gphotoSession, char * gphotoWinDllDir, int debug, char * debugPath)
{
	int count;
   int result;
   GPhotoSession *p;   
   char line[1024];
   char logFileName[1024]; 
	
    p = malloc(sizeof(GPhotoSession));
    if (!p)
		return LIBGPHOTO_ERROR;

	memset (p, 0, sizeof (GPhotoSession));
   strcpy(logFileName,"");

#ifdef WIN32   
      sprintf(line,"CAMLIBS=%s",gphotoWinDllDir);
      _putenv(line);
      sprintf(line,"IOLIBS=%s",gphotoWinDllDir);
      _putenv(line);
#else
      setenv("CAMLIBS",gphotoWinDllDir,1);
      setenv("IOLIBS",gphotoWinDllDir,1);
      
#endif
   *gphotoSession = p;

   // activation/desactivation des traces de deboggage de libgphoto2
   if (debugPath != NULL ) {
      strcpy(logFileName,debugPath);
      if ( logFileName[strlen(logFileName)-1]!= '\\' && logFileName[strlen(logFileName)-1]!= '/' && strlen(logFileName)!=0 ) {
         strcat(logFileName,"/");
      }
#ifdef WIN32
      {
         char * cp;
         // je remplace les / par des \ si on est sur Windows
         for (cp=logFileName; *cp != 0 ; cp++) {
            if (*cp == '/') {
               *cp = '\\';
            }
         }
      }
#endif
   } 
   strcat(logFileName,"gphoto2.log");
      
   libgphoto_setDebugLog(p, debug, logFileName);

   // raz des messages d'erreur
   strcpy(p->lastErrorMesssage,"");

   // Create a context. Report progress only if users will see it.
   p->context = gp_context_new ();
   //TODO
   //gp_context_set_cancel_func    (p->context, ctx_cancel_func,  NULL);
   //gp_context_set_error_func     (p->context, ctx_error_func,   p->lastErrorMesssage);
   //gp_context_set_status_func    (p->context, ctx_status_func,  NULL);
   //gp_context_set_message_func   (p->context, ctx_message_func, NULL);

   // Je nettoie le dernier message d'erreur
   gp_context_error(p->context,"");

   // charge la liste dll des APN presentes( PTP, canon, ...)
   gp_abilities_list_new (&p->abilities_list);
   gp_abilities_list_load (p->abilities_list, p->context);
   gp_log (GP_LOG_DEBUG, "libgphoto_openSession", "Search camera library in '%s' ...", gphotoWinDllDir);
   count = gp_abilities_list_count(p->abilities_list);
   gp_log (GP_LOG_DEBUG, "libgphoto_openSession", "Nombre de modele de camera supportes = %d \n", count);
   
   // charge les dll des types de port (serial et usb)
   result = gp_port_info_list_new (&p->portList);
   if ( result <0 ) {
      gp_context_error(p->context,gp_port_result_as_string(result));
      return result;
   }
   result = gp_port_info_list_load (p->portList);
   if ( result <0 ) {
      gp_context_error(p->context,gp_port_result_as_string(result));
      return result;
   }
   count = gp_port_info_list_count(p->portList);
   if ( count == 0 ) {
      // libgphoto2_canon_usb n'a pas pu etre charge car il manque libusb
      gp_context_error(p->context,gp_port_result_as_string(GP_ERROR_IO_USB_FIND  ));
      return GP_ERROR_IO_USB_FIND;
   }

   gp_log (GP_LOG_DEBUG, "libgphoto_openSession", "Nombre de type de port supportes = %d \n", count);   
   CR (gp_list_new (&p->previousFileList)); 

   return LIBGPHOTO_OK;
}

/**
 * libere les ressources d'une connexion
 */
int libgphoto_closeSession (GPhotoSession *gphotoSession)
{
   if (gphotoSession != NULL) {
      if (gphotoSession->abilities_list)
         gp_abilities_list_free (gphotoSession->abilities_list);
      if (gphotoSession->portList)
         gp_port_info_list_free (gphotoSession->portList);
      if (gphotoSession->camera)
         gp_camera_unref (gphotoSession->camera);
      if (gphotoSession->context)
         gp_context_unref (gphotoSession->context);      
      if (gphotoSession->previousFileList != NULL );
         gp_list_free (gphotoSession->previousFileList);

      // je desactive les traces
      libgphoto_closeLog(gphotoSession);
      //memset (gphotoSession, 0, sizeof (GPhotoSession));
      free(gphotoSession);
      gphotoSession = NULL;

   }

   return LIBGPHOTO_OK;
}


int libgphoto_detectCamera(GPhotoSession *gphotoSession, char *cameraModel, char *cameraPath)
{
	int count;
   int i;
	CameraList *cameraList;
   const char *model = NULL, *path = NULL;
   
 #ifdef WIN32
   // load libusb for Windows only
//   usb_init();
#endif

   // recherche des APN présents 
    CR (gp_list_new (&cameraList)); 
    CR (gp_abilities_list_detect(gphotoSession->abilities_list, gphotoSession->portList, cameraList, gphotoSession->context));
    count = gp_list_count (cameraList);
    gp_log (GP_LOG_DEBUG, "libgphoto_detectCamera", "Detect : camera count = %d \n", count);

    if( count > 0 ) {
        for (i=0; i <count ; i++ ) {
   		 CR (gp_list_get_name (cameraList, i, &model));
		    CR (gp_list_get_value (cameraList, i, &path));
		    printf("Detect : cameraModel=%s, cameraPath=%s \n", model, path);		       
        }
    } else  {
       gp_context_error (gphotoSession->context, "No camera found");
       return LIBGPHOTO_ERROR;
    }
    
   // par defaut, je selectionne la camera numero 0
	CR (gp_list_get_name (cameraList, 0, &model));
   CR (gp_list_get_value (cameraList, 0, &path));
   strcpy(cameraModel, model);
   strcpy(cameraPath, path);
	
    // libere les listes temporaires
	CR (gp_list_free (cameraList));
   return LIBGPHOTO_OK;

}


int libgphoto_openCamera(GPhotoSession *gphotoSession, char * cameraModel, char *path)
{
   CameraAbilities a;
	int m;
   int result;

   if( gphotoSession->camera == NULL ) {   
      CR (gp_camera_new (&gphotoSession->camera));
      // set camera model abilities and port
      CR (m = gp_abilities_list_lookup_model (gphotoSession->abilities_list, cameraModel));
      CR (gp_abilities_list_get_abilities (gphotoSession->abilities_list, m, &a));
      CR (gp_camera_set_abilities (gphotoSession->camera, a));
      CR (action_camera_set_port (gphotoSession, path));         
      // init camera
      CR (gp_camera_init(gphotoSession->camera, gphotoSession->context));
      result = LIBGPHOTO_OK;
   } else {
      gp_context_error (gphotoSession->context, "Camera already opened");
      result = LIBGPHOTO_ERROR;
   }

   return LIBGPHOTO_OK;

}

int libgphoto_closeCamera (GPhotoSession *gphotoSession)
{
   int result ;

   if ( gphotoSession->camera != NULL ) {
      gp_camera_exit(gphotoSession->camera, gphotoSession->context);
      gp_camera_free(gphotoSession->camera);
      gphotoSession->camera = NULL;
      result = LIBGPHOTO_OK;
   } else {
      gp_context_error (gphotoSession->context, "No camera opened");
      result = LIBGPHOTO_ERROR;
   }
   return result;
}



int libgphoto_getsummary (GPhotoSession *gphotoSession)
{
	CameraText text;

	CR (gp_camera_get_summary (gphotoSession->camera, &text, gphotoSession->context));

	printf ("Camera summary:");
	printf ("\n%s\n", text.text);

    return LIBGPHOTO_OK;

}

int libgphoto_getTimeValue (GPhotoSession *gphotoSession, float * timeValue)
{
   CameraWidget *releaseWidget = NULL;
   CameraWidget *timeValueWidget = NULL;
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }
   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   CR(gp_widget_get_child_by_label (releaseWidget, "Time value", &timeValueWidget));
   CR (gp_camera_get_config( gphotoSession->camera, &timeValueWidget, gphotoSession->context)); 
   gp_widget_get_value(timeValueWidget, timeValue);
   
   return LIBGPHOTO_OK;
}

int libgphoto_setTimeValue (GPhotoSession *gphotoSession, float timeValue)
{
   CameraWidget *releaseWidget = NULL;
   CameraWidget *timeValueWidget = NULL;
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }
   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   CR(gp_widget_get_child_by_label (releaseWidget, "Time value", &timeValueWidget));
   gp_widget_set_value(timeValueWidget, &timeValue);
   CR (gp_camera_set_config( gphotoSession->camera, timeValueWidget, gphotoSession->context)); 
   return LIBGPHOTO_OK;
}

int libgphoto_getDriveMode (GPhotoSession *gphotoSession, int * pdriveMode)
{
   CameraWidget *releaseWidget = NULL;
   CameraWidget *driveModeWidget = NULL;
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   CR(gp_widget_get_child_by_label (releaseWidget, "Drive mode", &driveModeWidget));
   CR (gp_camera_get_config( gphotoSession->camera, &driveModeWidget, gphotoSession->context)); 
   gp_widget_get_value(driveModeWidget, pdriveMode);
   
   return LIBGPHOTO_OK;
}

int libgphoto_setDriveMode (GPhotoSession *gphotoSession, int driveMode)
{
   CameraWidget *releaseWidget = NULL;
   CameraWidget *driveModeWidget = NULL;
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }
   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   CR(gp_widget_get_child_by_label (releaseWidget, "Drive mode", &driveModeWidget));
   gp_widget_set_value(driveModeWidget, &driveMode);
   CR (gp_camera_set_config( gphotoSession->camera, driveModeWidget, gphotoSession->context)); 
   return LIBGPHOTO_OK;
}

int libgphoto_getQuality (GPhotoSession *gphotoSession, char * quality)
{
   char * value;
   CameraWidget *releaseWidget = NULL;
   CameraWidget *qualityWidget = NULL;
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   CR(gp_widget_get_child_by_label (releaseWidget, "Quality", &qualityWidget));
   CR (gp_camera_get_config( gphotoSession->camera, &qualityWidget, gphotoSession->context)); 
   CR (gp_widget_get_value(qualityWidget, &value));
   strcpy(quality, value);
   
   return LIBGPHOTO_OK;
}

int libgphoto_setQuality (GPhotoSession *gphotoSession, char * quality)
{
   CameraWidget *releaseWidget = NULL;
   CameraWidget *qualityWidget = NULL;
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }
   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   CR(gp_widget_get_child_by_label (releaseWidget, "Quality", &qualityWidget));
   CR(gp_widget_set_value(qualityWidget, quality));
   CR (gp_camera_set_config( gphotoSession->camera, qualityWidget, gphotoSession->context)); 
   return LIBGPHOTO_OK;
}

int libgphoto_setTransfertMode (GPhotoSession *gphotoSession, int value)
{
   int result;
   CameraWidget *driverWidget = NULL;
   CameraWidget *transfertModeWidget = NULL;
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }
   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Driver", &driverWidget));
   CR(gp_widget_get_child_by_label (driverWidget, "Transfert Mode", &transfertModeWidget));
   CR(gp_widget_set_value(transfertModeWidget, &value ));
   result = gp_camera_set_config(gphotoSession->camera, gphotoSession->config, gphotoSession->context);
   return result;
   //return LIBGPHOTO_OK;
}

int libgphoto_getTransfertMode (GPhotoSession *gphotoSession, int *pvalue)
{
   CameraWidget *driverWidget = NULL;
   CameraWidget *transfertModeWidget = NULL;
   
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }
   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Driver", &driverWidget));
   CR(gp_widget_get_child_by_label (driverWidget, "Transfert Mode", &transfertModeWidget));
   CR(gp_widget_get_value(transfertModeWidget, pvalue ));

   return LIBGPHOTO_OK;
}

int libgphoto_setLongExposure (GPhotoSession *gphotoSession, int value)
{
   CameraWidget *driverWidget = NULL;
   CameraWidget *externalRemoteWidget = NULL;
   
   
   if ( gphotoSession->config == NULL)  {
      CR (gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context));      
   }
   
   CR(gp_widget_get_child_by_label (gphotoSession->config, "Driver", &driverWidget));
   CR(gp_widget_get_child_by_label (driverWidget, "Long exposure", &externalRemoteWidget));
   
   CR(gp_widget_set_value(externalRemoteWidget, &value ));

   // send values to camera
   CR(gp_camera_set_config(gphotoSession->camera, gphotoSession->config, gphotoSession->context));

   return LIBGPHOTO_OK;
}

/** 
 *  libgphoto_startLongExposure
 *
 *  parameters : 
 *     cameraFolder (OUT) :  current folder  in camera memory card
 *     fileName (OUT)     :  file name  in camera memory card
 */
int libgphoto_startLongExposure (GPhotoSession *gphotoSession, int transfertMode)
{
   
   // set tranfert mode 
   CR (libgphoto_setTransfertMode(gphotoSession, transfertMode ));
   // set bulb mode
   CR(libgphoto_setTimeValue(gphotoSession, -1));

   // start external remote command
   libgphoto_setLongExposure(gphotoSession, 1);

   return LIBGPHOTO_OK;
}

/** 
 *  libgphoto_readImage
 *
 *  read image from to CF
 *  parameters : 
 *     cameraFolder (OUT) :  current folder  in camera memory card
 *     fileName (OUT)     :  file name  in camera memory card
 */
int libgphoto_captureImage (GPhotoSession *gphotoSession, char * cameraFolder, char * cameraFile)
{
   int result ;

   CameraFilePath path;
   CR(libgphoto_setTransfertMode(gphotoSession, 8 ));
   result = gp_camera_capture (gphotoSession->camera, GP_CAPTURE_IMAGE, &path, gphotoSession->context);
   if( result == GP_OK) {
      strcpy(cameraFolder, path.folder);
      strcpy(cameraFile, path.name);
   } 
   libgphoto_setLongExposure(gphotoSession, 0);
   return result;
}

/** 
 *  libgphoto_ReadAndLoadImageWithoutCF
 *
 *  parameters : 
 *     cameraFolder (IN) :  current folder  in camera memory card
 *     fileName     (IN):  file name  in camera memory card
 */
int libgphoto_captureImageWithoutCF (GPhotoSession *gphotoSession)
{
   
   //CameraFile *cameraFile;
   //int result;
   //
   //// set TransfertMode = REMOTE_CAPTURE_FULL_TO_PC
   //CR (libgphoto_setTransfertMode(gphotoSession, 0 ));
   //gp_file_new (&cameraFile);
   //result = gp_camera_capture_without_cf(gphotoSession->camera, cameraFile, gphotoSession->context);
   //
   //CR (gp_file_unref(cameraFile));
   //libgphoto_setLongExposure(gphotoSession, 0);
   //
   //return (result);
   return (LIBGPHOTO_ERROR);
}

/** 
 *  libgphoto_ReadAndLoadImageWithoutCF
 *
 *  parameters : 
 *     cameraFolder (IN) :  current folder  in camera memory card
 *     fileName     (IN):  file name  in camera memory card
 */
int libgphoto_captureAndLoadImageWithoutCF (GPhotoSession *gphotoSession, char * folder, char * file, char **imageData, unsigned long *imageLenght, char **mimeType)
{
   
   //CameraFile *cameraFile;
   //char emptyFolder[] = "/";
   //char * name;
   //char * data;
   //char * mime;
   //unsigned long size;
   //int result;
   //
   //// set TransfertMode = REMOTE_CAPTURE_FULL_TO_PC
   //CR (libgphoto_setTransfertMode(gphotoSession, 2 ));
   //gp_file_new (&cameraFile);
   //result = gp_camera_capture_without_cf(gphotoSession->camera, cameraFile, gphotoSession->context);
   //if( result == LIBGPHOTO_OK ) {
   //   gp_file_get_name(cameraFile, &name);
   //   gp_file_get_data_and_size (cameraFile, &data, &size); 
   //   gp_file_get_mime_type(cameraFile, &mime);
   //   
   //   *imageData = data;
   //   *imageLenght = size;
   //   *mimeType = mime;
   //   strcpy(file, name);
   //   strcpy(folder, emptyFolder);

   //   // add this cameraFile in virtual folder and keep a reference
   //   gp_filesystem_put_virtual_file(gphotoSession->camera->fs, cameraFile, gphotoSession->context);
   //} 
   //
   //CR (gp_file_unref(cameraFile));
   //libgphoto_setLongExposure(gphotoSession, 0);

   //return (result);
   return LIBGPHOTO_ERROR;
}

//  CameraFileType
//	    GP_FILE_TYPE_PREVIEW,
//	    GP_FILE_TYPE_NORMAL,
//	    GP_FILE_TYPE_RAW,
//	    GP_FILE_TYPE_AUDIO,
//	    GP_FILE_TYPE_EXIF


/**
  * loadImage
  *     load image from camera CF
  */
int libgphoto_loadImage (GPhotoSession *gphotoSession, char * folder, char * file,char **imageData, unsigned long *imageLenght, char **mimeType)
{
   CameraFile *cameraFile;
   CameraFileType fileType;
   char * data;
   unsigned long size;
   char *mime;
   int result;    
   
   fileType = GP_FILE_TYPE_NORMAL;
   gp_file_new (&cameraFile);
   result = gp_camera_file_get (gphotoSession->camera, folder, file, fileType, cameraFile, gphotoSession->context);
   if( result == LIBGPHOTO_OK ) {
      gp_file_get_data_and_size (cameraFile, &data, &size); 
      gp_file_get_mime_type(cameraFile, &mime);
      
      //*imageData = malloc( size);
      //if( *imageData != NULL) {
      //   memcpy(*imageData, data, size);
      //   *imageLenght = size;
      //   gp_file_get_mime_type(cameraFile, &mime);
      //   strcpy(mimeType, mime);
      //   result = LIBGPHOTO_OK;
      //} else {
      //   result = LIBGPHOTO_ERROR;
      //}
      *imageData = data;
      *imageLenght = size;
      *mimeType = mime;
      
      
   }
   if( strcmp(folder, "/")!=0){
      gp_file_unref(cameraFile);  
   }
   return result;
}

/**
  * libgphoto_loadPreview
  *     load preview from camera CF
  */
int libgphoto_loadPreview(GPhotoSession *gphotoSession, char * folder, char * file,char **imageData, unsigned long *imageLenght, char *mimeType)
{
    CameraFile *cameraFile;
    CameraFileType fileType;
    char * data;
    unsigned long size;
    char *mime;
    int result;    

    fileType = GP_FILE_TYPE_PREVIEW;
    gp_file_new (&cameraFile);
    result = gp_camera_file_get (gphotoSession->camera, folder, file, fileType, cameraFile, gphotoSession->context);
    if( result == LIBGPHOTO_OK ) {
       gp_file_get_data_and_size (cameraFile, &data, &size); 
       gp_file_get_mime_type(cameraFile, &mimeType);
    
       *imageData = malloc( size);
       if( *imageData != NULL) {
          memcpy(*imageData, data, size);
          *imageLenght = size;
          gp_file_get_mime_type(cameraFile, &mime);
          strcpy(mimeType, mime);
          result = LIBGPHOTO_OK;
       } else {
          result = LIBGPHOTO_ERROR;
       }
     
    }
    gp_file_unref(cameraFile);        
    

    return result;
}

/**
 * libgphoto_deleteImage
 *     delete image in CF
 *  parameters : 
 *     cameraFolder (IN) :  folder  in camera memory card
 *     fileName (IN)     :  file name  in camera memory card
 */
int libgphoto_deleteImage (GPhotoSession *gphotoSession,  char * cameraFolder, char *fileName)
{
   CR(gp_camera_file_delete (gphotoSession->camera, cameraFolder, fileName, gphotoSession->context))
   return (LIBGPHOTO_OK);
}

//==================== local functions ======================
void ctx_status_func (GPContext *context, const char *format, void *data)
{
   if (data != NULL) {
      //vsprintf ( data, format, args);
   }
}

void ctx_error_func (GPContext *context, const char *format, void *data)
{
   if (data != NULL) {
      //vsprintf ( data, format, args);
   }
}

void debug_func (GPLogLevel level, const char *domain, const char *format, void *data)
{
   if ( logFileHandle != NULL ) {
      fprintf ( logFileHandle, "%s(%i): ", domain, level);
      //vfprintf( logFileHandle, format, args);
      fprintf ( logFileHandle,"\n");
      fflush  ( logFileHandle);
   } else {
      printf  ( "%s(%i): ", domain, level);
      //vprintf (format, args);
      printf  ( "\n");
   }
}

void debugstdout_func (GPLogLevel level, const char *domain, const char *format, void *data)
{
   printf ( "%s(%i): ", domain, level);
   //vprintf( format, args);
   printf ( "\n");
}

GPContextFeedback ctx_cancel_func (GPContext *context, void *data)
{
   //printf  ( "cancel_func : %s", data);
   //printf  ( "\n");
	return (GP_CONTEXT_FEEDBACK_OK);
}

void ctx_message_func (GPContext *context, const char *format, void *data)
{
   printf  ( "cancel_func : ");
   //vprintf (format, args);
   putchar ('\n');
   printf  ( "\n");
}


int action_camera_set_port (GPhotoSession *params, const char *port)
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
//#ifdef WIN32
//   r = gp_port_info_list_load_dir (il, params->gphotoWinDllDir);
//#else   
	r = gp_port_info_list_load (il);
//#endif

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

void libgphoto_setDebugLog(GPhotoSession *gphotoSession, int level, char *logFileName) {
   if ( level == 1 ) {
      logFileHandle=fopen(logFileName, "w");
      gphotoSession->debug_func_id = gp_log_add_func (GP_LOG_ALL, debug_func, NULL);
   } else {
      libgphoto_closeLog(gphotoSession);
   }
}

void libgphoto_closeLog(GPhotoSession *gphotoSession) {
   gp_log_remove_func(gphotoSession->debug_func_id) ;
   gphotoSession->debug_func_id = -1;

   if ( logFileHandle != NULL) {
      fclose(logFileHandle);
      logFileHandle = NULL;
   }
}


char * libgphoto_getLastErrorMessage(GPhotoSession *gphotoSession) {
   return gphotoSession->lastErrorMesssage;

}
