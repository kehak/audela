// File   :gp_api.c .
// Date   :05/08/2005
// Author :Michel Pujol

// Description : simple API for libgphoto2 library


#ifndef __GP_SIMPLE_API_H__
#define __GP_SIMPLE_API_H__


#define GPAPI_OK 0
#define GPAPI_ERROR -1

typedef struct _GPParams GPParams;


int gpapi_init (GPParams **gpparams, char * gphotoWinDllDir);
int gpapi_exit (GPParams *gpparams);
int gpapi_detect(GPParams *gpparams, char *cameraModel, char *cameraPath);
int gpapi_open(GPParams *gpparams, char *cameraModel, char *cameraPath);
int gpapi_close (GPParams *gpparams);
int gpapi_getsummary (GPParams *gpparams);
int gpapi_captureImage (GPParams *gpparams, char * cameraFolder, char *fileName);
int gpapi_loadImage (GPParams *gpparams,  char * cameraFolder, char *fileName, char **imageData, unsigned long *imageSize, char *mimeType);
int gpapi_loadPreview (GPParams *gpparams, char * cameraFolder, char * destinationFolder, char *fileName, char *prefix);
int gpapi_deleteImage (GPParams *gpparams, char * cameraFolder, char *fileName);
int gpapi_setExternalRemoteCapture(GPParams *gpparams,int value);
int gpapi_getTimeValue (GPParams *gpparams, float * timeValue, int *driveMode, char *quality);
int gpapi_setTimeValue (GPParams *gpparams, float timeValue, int driverMode, char * quality);
char * gpapi_getLastErrorMessage(GPParams *gpparams);

#endif
