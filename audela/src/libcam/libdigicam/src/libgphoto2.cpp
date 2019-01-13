// libgphoto2.cpp : Defines the entry point for the DLL application.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
//#include <config.h>

#include <gphoto2/gphoto2-camera.h>         
#include <gphoto2/gphoto2-filesys.h>         
#include <gphoto2/gphoto2-abilities-list.h>
#include <gphoto2/gphoto2-context.h>
#include <gphoto2/gphoto2-port-log.h>
#include <gphoto2/gphoto2-port-result.h>



#include <libdcjpeg.h>      // decode jpeg  pictures
#include <libdcraw.h>         // decode raw  pictures
#include <libcam/util.h>      // pour libcam_log
#include "libgphoto2.h"
#include "libdigicam_canon.h"


// =========== local definiton and types ===========
#define CR(result)       {int r=(result); if (r<GP_OK) return result;}

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
   //GPPortInfoList *portList;
   //CameraList *previousFileList;
   int debug_func_id;
   //CameraWidget *config;
};

// =========== local functions prototypes ===========
void port_log_func (GPLogLevel level, const char *domain, const char *message, void *data);
void ctx_status_func (GPContext *context, const char *format, void *data);
void ctx_error_func (GPContext *context, const char *format, void *data);
GPContextFeedback ctx_cancel_func (GPContext *context, void *data);
void ctx_message_func (GPContext *context, const char *format, void *data);

int action_camera_set_port (GPhotoSession *params, const char *port);
int libgphoto_getConfigString (GPhotoSession *gphotoSession, const char * paramName, char * paramValue);
int libgphoto_setConfigString (GPhotoSession *gphotoSession, const char * paramName, const char * paramValue);


FILE* logFileHandle = NULL ;

/**
 * libgphoto_openSession
 * reserve les ressources pour une connexion
 *    malloc GPARAM
 *		p->folder = "/"
 *		p->camera = malloc()
 *		p->context = malloc()
 *		p->abilities_list = malloc()
 */
int libgphoto_openSession(GPhotoSession **gphotoSession, char * gphotoWinDllDir)
{
   GPhotoSession *p;   

   libcam_log(LOG_DEBUG, "libgphoto_openSession begin");
   p = (GPhotoSession *) malloc(sizeof(GPhotoSession));
   if (!p) {
      return LIBGPHOTO_MALLOC_ERROR;
   }
   memset (p, 0, sizeof (GPhotoSession));
   *gphotoSession = p;

   // Create a context. Report progress only if users will see it.
   p->context = gp_context_new ();
   gp_context_set_error_func     (p->context, ctx_error_func,   NULL);
   gp_context_set_status_func    (p->context, ctx_status_func,  NULL);
   //gp_context_set_cancel_func    (p->context, ctx_cancel_func,  NULL);
   gp_context_set_message_func   (p->context, ctx_message_func, NULL);

#ifdef _WIN32   
   gp_log_add_func(GP_LOG_DEBUG, (GPLogFunc) port_log_func,NULL);
#endif
#ifdef WIN32   
   gp_port_info_list_load_win ((const char*)gphotoWinDllDir);
#else
   // nothing todo
#endif

   return LIBGPHOTO_OK;
}

/**
 * libere les ressources d'une connexion
 */
int libgphoto_closeSession (GPhotoSession *gphotoSession)
{
   libcam_log(LOG_DEBUG, "libgphoto_closeSession begin");
   if (gphotoSession != NULL) {
      if (gphotoSession->abilities_list)
         gp_abilities_list_free (gphotoSession->abilities_list);
      //if (gphotoSession->portList)
      //   gp_port_info_list_free (gphotoSession->portList);
      if (gphotoSession->camera)
         gp_camera_unref (gphotoSession->camera);
      if (gphotoSession->context)
         gp_context_unref (gphotoSession->context);      
      //if (gphotoSession->previousFileList != NULL )
      //   gp_list_free (gphotoSession->previousFileList);

      free(gphotoSession);
      gphotoSession = NULL;

   }

   return LIBGPHOTO_OK;
}

//
//int libgphoto_detectCamera(GPhotoSession *gphotoSession, char *cameraModel, char *cameraPath)
//{
//	int count;
//   int i;
//	CameraList *cameraList;
//   const char *model = NULL, *path = NULL;
//
//	printf("libgphoto_detectCamera debut \n");
// #ifdef WIN32
//   // load libusb for Windows only
////   usb_init();
//#endif
//
//   // recherche des APN pr�sents 
//    CR (gp_list_new (&cameraList)); 
//    CR (gp_abilities_list_detect(gphotoSession->abilities_list, gphotoSession->portList, cameraList, gphotoSession->context));
//    count = gp_list_count (cameraList);
//    //gp_log (GP_LOG_DEBUG, "libgphoto_detectCamera", "Detect : camera count = %d \n", count);
//    printf("libgphoto_detectCamera gp_list_count=%d \n", count);
//	
//    if( count > 0 ) {
//        for (i=0; i <count ; i++ ) {
//   		 CR (gp_list_get_name (cameraList, i, &model));
//		    CR (gp_list_get_value (cameraList, i, &path));
//		    printf("Detect : cameraModel=%s, cameraPath=%s \n", model, path);		       
//        }
//    } else  {
//       gp_context_error (gphotoSession->context, "No camera found");
//       return LIBGPHOTO_NO_CAMERA_FOUND;
//    }
//    
//   // par defaut, je selectionne la camera numero 0
//	CR (gp_list_get_name (cameraList, 0, &model));
//   CR (gp_list_get_value (cameraList, 0, &path));
//   strcpy(cameraModel, model);
//   strcpy(cameraPath, path);
//	
//    // libere les listes temporaires
//	CR (gp_list_free (cameraList));
//	
//	printf("libgphoto_detectCamera fin\n");
//   return LIBGPHOTO_OK;
//
//}


int libgphoto_openCamera(GPhotoSession *gphotoSession, char * cameraModel, char *path)
{
   int result;

   if( gphotoSession->camera == NULL ) {   
      libcam_log(LOG_DEBUG, "libgphoto_openCamera debut");
      gp_camera_new (&(gphotoSession->camera));
      // set camera model abilities and port
      //CR (m = gp_abilities_list_lookup_model (gphotoSession->abilities_list, cameraModel));
      //CR (gp_abilities_list_get_abilities (gphotoSession->abilities_list, m, &a));
      //CR (gp_camera_set_abilities (gphotoSession->camera, a));
      //CR (action_camera_set_port (gphotoSession, path));         
      // init camera
      libcam_log(LOG_DEBUG, "libgphoto_openCamera gp_camera_init");
      result = gp_camera_init(gphotoSession->camera, gphotoSession->context);
      if (result < GP_OK) {
         libcam_log(LOG_ERROR, "libgphoto_openCamera gp_camera_init ret=%d %s. No camera auto detected",result , gp_result_as_string(result));
         gp_camera_free (gphotoSession->camera);
         gphotoSession->camera = NULL;
      } else {
         libcam_log(LOG_DEBUG, "libgphoto_openCamera gp_camera_init OK");
         //result = gp_camera_get_config( gphotoSession->camera, &gphotoSession->config, gphotoSession->context); 
         //if (result < GP_OK) {
         //   printf("gp_camera_get_config error.\n");
         //   gp_camera_free (gphotoSession->camera);
         //   gphotoSession->camera = NULL;
         //}
      }
   } else {
      libcam_log(LOG_DEBUG, "libgphoto_openCamera Camera already opened");
      result = GP_OK;
   }

   return result;

}

int libgphoto_closeCamera (GPhotoSession *gphotoSession)
{
   int result ;

   if ( gphotoSession->camera != NULL ) {
      gp_camera_exit(gphotoSession->camera, gphotoSession->context);
      gp_camera_free(gphotoSession->camera);
      gphotoSession->camera = NULL;
      result = LIBGPHOTO_OK;
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

int libgphoto_getExposureTime (GPhotoSession *gphotoSession, float * exposureTime)
{
   char exposureTimeString[256];
   int result = libgphoto_getConfigString(gphotoSession, "shutterspeed", exposureTimeString);
   if( result == GP_OK) {
      *exposureTime = canonShutterValueLabelToTime(exposureTimeString);
   }
   return result;
}

int libgphoto_setExposureTime (GPhotoSession *gphotoSession, float exposureTime)
{
   const char* shutterSpeedString = canonShutterValueTimeToLabel(exposureTime);
   return libgphoto_setConfigString(gphotoSession, "shutterspeed", shutterSpeedString);
}

int libgphoto_getDriveMode (GPhotoSession *gphotoSession, int * pdriveMode)
{
   //CameraWidget *releaseWidget = NULL;
   //CameraWidget *driveModeWidget = NULL;
   //
   //CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   //CR(gp_widget_get_child_by_label (releaseWidget, "Drive mode", &driveModeWidget));
   //gp_widget_get_value(driveModeWidget, pdriveMode);
   //
   return LIBGPHOTO_OK;
}

int libgphoto_setDriveMode (GPhotoSession *gphotoSession, int driveMode)
{
   //CameraWidget *releaseWidget = NULL;
   //CameraWidget *driveModeWidget = NULL;
   //
   //CR(gp_widget_get_child_by_label (gphotoSession->config, "Release", &releaseWidget));
   //CR(gp_widget_get_child_by_label (releaseWidget, "Drive mode", &driveModeWidget));
   //gp_widget_set_value(driveModeWidget, &driveMode);
   //CR (gp_camera_set_config( gphotoSession->camera, driveModeWidget, gphotoSession->context)); 
   return LIBGPHOTO_OK;
}

int libgphoto_getQuality (GPhotoSession *gphotoSession, char * quality)
{
   return libgphoto_getConfigString(gphotoSession, "imageformat", quality);
}

int libgphoto_setQuality (GPhotoSession *gphotoSession, const char * quality)
{
   return libgphoto_setConfigString(gphotoSession, "imageformat", quality);
}

int libgphoto_getConfigString (GPhotoSession *gphotoSession, const char * paramName, char * paramValue)
{
   CameraWidget *cameraWidget;
   CameraWidget *qualityWidget;
   char *value;
       
   CR(gp_camera_get_config( gphotoSession->camera, &cameraWidget, gphotoSession->context));
   CR(gp_widget_get_child_by_name (cameraWidget, paramName, &qualityWidget));
   CR (gp_widget_get_value(qualityWidget, &value));  
   strcpy(paramValue, value);
   gp_widget_free (cameraWidget);
   return LIBGPHOTO_OK;
}

int libgphoto_setConfigString (GPhotoSession *gphotoSession, const char * paramName, const char * paramValue)  {
   CameraWidget *cameraWidget = NULL;
   CameraWidget *paramWidget = NULL;
   
   CR(gp_camera_get_config( gphotoSession->camera, &cameraWidget, gphotoSession->context));
   CR(gp_widget_get_child_by_name (cameraWidget, paramName, &paramWidget));
   CR(gp_widget_set_value(paramWidget, paramValue));
   CR (gp_camera_set_config( gphotoSession->camera, cameraWidget, gphotoSession->context)); 
   gp_widget_free (cameraWidget);
   return LIBGPHOTO_OK;
}

int libgphoto_getQualityList (GPhotoSession *gphotoSession, char * qualityList)
{
   return canon_getQualityList(qualityList);
}

int libgphoto_setLongExposure (GPhotoSession *gphotoSession, int value)
{
   //CameraWidget *driverWidget = NULL;
   //CameraWidget *externalRemoteWidget = NULL;
   //
   //CR(gp_widget_get_child_by_label (gphotoSession->config, "Driver", &driverWidget));
   //CR(gp_widget_get_child_by_label (driverWidget, "Long exposure", &externalRemoteWidget));
   //
   //CR(gp_widget_set_value(externalRemoteWidget, &value ));

   //// send values to camera
   //CR(gp_camera_set_config(gphotoSession->camera, gphotoSession->config, gphotoSession->context));

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
   
   // set bulb mode
   CR(libgphoto_setExposureTime(gphotoSession, -1));

   // start external remote command
   libgphoto_setLongExposure(gphotoSession, 1);

   return LIBGPHOTO_OK;
}


/** 
 *  libgphoto_ReadAndLoadImageWithoutCF
 *
 *  parameters : 
 *     cameraFolder (IN) :  current folder  in camera memory card
 *     fileName     (IN):  file name  in camera memory card
 */
int libgphoto_captureAndLoadImageWithoutCF (GPhotoSession *gphotoSession, char * folder, char * file, 
     float **imageData, int * imageWidth, int * imageHeight, char *pixelClass, 
     char *rawFilter, char *rawColor, char *rawBlack, char *rawMaxi,
     char *errorMessage)
{
   char * data;
   char * mime;
   unsigned long size;
   int result;

   CameraFile *cameraFile;
	CameraFilePath camera_file_path;

	printf("Capturing.\n");

	/* NOP: This gets overridden in the library to /capt0000.jpg */
	strcpy(camera_file_path.folder, "/");
	strcpy(camera_file_path.name, "audela.jpg");

	result = gp_camera_capture(gphotoSession->camera, GP_CAPTURE_IMAGE, &camera_file_path, gphotoSession->context);
	printf("gp_camera_capture result=%d\n", result);

	printf("Pathname on the camera: %s/%s\n", camera_file_path.folder, camera_file_path.name);

	result = gp_file_new(&cameraFile);
	printf("gp_file_new result=%d\n", result);
	result = gp_camera_file_get(gphotoSession->camera, camera_file_path.folder, camera_file_path.name,
		     GP_FILE_TYPE_NORMAL, cameraFile, gphotoSession->context);
	printf("gp_camera_file_get result=%d\n", result);
   if( result == GP_OK ) {
	   gp_file_get_data_and_size (cameraFile, (const char**)&data, &size);
      gp_file_get_mime_type(cameraFile, (const char**)&mime);
      strcpy(file, camera_file_path.name);
      strcpy(folder, camera_file_path.folder);

      printf("mime=%s\n", mime);

      if( strstr( camera_file_path.name, "jpg")  != NULL  ) {
    	  strcpy(mime, "image/jpeg");
      } else {
    	  strcpy(mime, "image/x-canon-raw");
      }

      if (strcmp(mime, "image/x-canon-raw" ) == 0 ) {         
         unsigned short * decodedData;
         struct libdcraw_DataInfo dataInfo;
         int bufferRaw2CfaResult = libdcraw_bufferRaw2Cfa((unsigned short*) data, size, &dataInfo, &decodedData);
         if (bufferRaw2CfaResult == 0 )  {
            strcpy(pixelClass, "CLASS_GRAY");
            *imageWidth = dataInfo.width;
            *imageHeight = dataInfo.height;
            *imageData = (float*) malloc(dataInfo.width * dataInfo.height * sizeof(float));
            long t = dataInfo.width * dataInfo.height;
            while(--t>=0) {
               *(*imageData+t) = (float)*((decodedData+t));
            }
            libdcraw_freeBuffer(decodedData);
            
            // j'ajoute les mots cles specifique a une image RAW
            sprintf(rawFilter, "%u",dataInfo.filters);
            sprintf(rawColor, "%d",dataInfo.colors);
            sprintf(rawBlack, "%d",dataInfo.black);
            sprintf(rawMaxi,  "%d",dataInfo.maximum);
         } else {
            sprintf(errorMessage, "error libdcraw_decodeBuffer result=%d", bufferRaw2CfaResult);
            result = LIBGPHOTO_GENERIC_ERROR;
         }
         result = LIBGPHOTO_OK;
      } else if ( strcmp(mime, "image/jpeg") == 0 ) {
         unsigned char * decodedData;
         long   decodedSize;
         int width;
         int height;
         int decodeBufferResult  = libdcjpeg_decodeBuffer((unsigned char*) data, size, &decodedData, &decodedSize, &width, &height);
         if (decodeBufferResult == 0 )  {
            strcpy(pixelClass, "CLASS_RGB");
            *imageWidth = width;
            *imageHeight = height;
            *imageData = (float*) malloc(width * height * 3 * sizeof(float));
            if( *imageData != NULL) {              
               float *pOut = *imageData  ;
               for(int y = 0; y < height; y++) {
						unsigned char *pIn = decodedData + y * width *3 ;
						for(int x= 0; x < width; x++) {
							*(pOut++)= *(pIn + x*3 +0);
							*(pOut++)= *(pIn + x*3 +1);
							*(pOut++)= *(pIn + x*3 +2);
						}
					}
               // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloue par cette meme librairie.
               libdcjpeg_freeBuffer(decodedData);
               result = LIBGPHOTO_OK;
            } else {
               // l'espace memoire decodedData cree par la librairie libdcjpeg doit etre desalloue par cette meme librairie.
               libdcjpeg_freeBuffer(decodedData);
               sprintf(errorMessage, "error malloc imageData=NULL");
               result = LIBGPHOTO_MALLOC_ERROR;
            }
         } else {
            sprintf(errorMessage, "error libdcjpeg_decodeBuffer result=%d", decodeBufferResult);
            result = LIBGPHOTO_DECODE_IMAGE;
         }
      } else {
         // je retourne un message d'erreur
         sprintf(errorMessage, "unknown mime format %s", mime);
         result = LIBGPHOTO_GENERIC_ERROR;
      }
         
	   printf("Deleting.\n");
	   result = gp_camera_file_delete(gphotoSession->camera, camera_file_path.folder, camera_file_path.name,
			   gphotoSession->context);
	   printf("gp_camera_file_delete result=%d\n", result);
   }

   return result;

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
   const char * data;
   unsigned long size;
   const char *mime;
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
      *imageData = (char*) data;
      *imageLenght = size;
      *mimeType = (char*) mime;
      
      
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
    const char * data;
    unsigned long size;
    const char *mime;
    int result;    

    fileType = GP_FILE_TYPE_PREVIEW;
    gp_file_new (&cameraFile);
    result = gp_camera_file_get (gphotoSession->camera, folder, file, fileType, cameraFile, gphotoSession->context);
    if( result == LIBGPHOTO_OK ) {
       gp_file_get_data_and_size (cameraFile, &data, &size); 
       gp_file_get_mime_type(cameraFile, &mime);
    
       *imageData = (char*) malloc( size);
       if( *imageData != NULL) {
          memcpy(*imageData, data, size);
          *imageLenght = size;
          gp_file_get_mime_type(cameraFile, &mime);
          strcpy(mimeType, mime);
          result = LIBGPHOTO_OK;
       } else {
          result = LIBGPHOTO_MALLOC_ERROR;
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
void port_log_func (GPLogLevel level, const char *domain, const char *message, void *data)
{
   if(level == GP_LOG_ERROR) {
      libcam_log(LOG_ERROR, "libgphoto2 %s %s", domain, message);
   } else {
      libcam_log(LOG_DEBUG, "libgphoto2 %s %s", domain, message);

   }
}

void ctx_status_func (GPContext *context, const char *str, void *data)
{
   fprintf  (stderr, "%s\n", str);
   fflush   (stderr);
   
	if (data != NULL) {
      //vsprintf ( data, format, args);
	  
   }
}

void ctx_error_func (GPContext *context, const char *message, void *data)
{
   libcam_log(LOG_ERROR, "libgphoto2 ERROR %s", message);
}

GPContextFeedback ctx_cancel_func (GPContext *context, void *data)
{
   //printf  ( "cancel_func : %s", data);
   //printf  ( "\n");
	return (GP_CONTEXT_FEEDBACK_OK);
}

void ctx_message_func (GPContext *context, const char *message, void *data)
{
   libcam_log(LOG_ERROR, "libgphoto2 MESSAGE %s", message);
}


int action_camera_set_port (GPhotoSession *params, const char *port)
{
	GPPortInfoList *il = NULL;
	int p, r;
	GPPortInfo info;
	char verified_port[1024];

	verified_port[sizeof (verified_port) - 1] = '\0';
	if (!strchr (port, ':')) {
		//gp_log (GP_LOG_DEBUG, "main", "Ports must look like "
		//	"'serial:/dev/ttyS0' or 'usb:', but '%s' is "
		//	"missing a colon so I am going to guess what you "
		//	"mean.", port);
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
		//gp_log (GP_LOG_DEBUG, "main", "Guessed port name. Using port "
		//	"'%s' from now on.", verified_port);
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

const char * libgphoto_getResultString(int result) {
   switch (result) {
   case LIBGPHOTO_MALLOC_ERROR:
      return "Malloc error";
   case LIBGPHOTO_NO_CAMERA_FOUND:
      return "No camera found";
   case LIBGPHOTO_NOT_IMPLEMENTED:
      return "Not implemented";
   case LIBGPHOTO_DECODE_IMAGE:
      return "Error decode image";
   default:     
      return gp_result_as_string (result);
   }
}
