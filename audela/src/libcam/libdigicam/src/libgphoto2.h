// File   :libgphoto2.h
// Date   :05/08/2005
// Author :Michel Pujol

// Description : simple API for libgphoto2 library

#pragma once

#define LIBGPHOTO_OK 0

#define LIBGPHOTO_GENERIC_ERROR     -900
#define LIBGPHOTO_MALLOC_ERROR      -901
#define LIBGPHOTO_NO_CAMERA_FOUND   -902
#define LIBGPHOTO_NOT_IMPLEMENTED   -903
#define LIBGPHOTO_DECODE_IMAGE      -904
#define LIBGPHOTO_XXXX   -903


typedef struct _GPhotoSession GPhotoSession;

int libgphoto_openSession (GPhotoSession **gphotoSession, char * gphotoWinDllDir);
int libgphoto_closeSession (GPhotoSession *gphotoSession);
//int libgphoto_detectCamera(GPhotoSession *gphotoSession, char *cameraModel, char *cameraPath);
int libgphoto_openCamera(GPhotoSession *gphotoSession, char *cameraModel, char *cameraPath);
int libgphoto_closeCamera (GPhotoSession *gphotoSession);
int libgphoto_getsummary (GPhotoSession *gphotoSession);
int libgphoto_captureImage (GPhotoSession *gphotoSession, char * cameraFolder, char * cameraFile);
int libgphoto_captureImageWithoutCF (GPhotoSession *gphotoSession);
int libgphoto_captureAndLoadImageWithoutCF (GPhotoSession *gphotoSession, char * folder, char * file, 
           float **imageData, int * width, int * height, char *pixelClass, 
           char *rawFilter, char *rawColor, char *rawBlack, char *rawMaxi, 
           char *errorMessage);
int libgphoto_loadImage   (GPhotoSession *gphotoSession, char * cameraFolder, char * cameraFile, char **imageData, unsigned long *imageLenght, char **mimeType);
int libgphoto_loadPreview (GPhotoSession *gphotoSession, char * cameraFolder, char * cameraFile, char **imageData, unsigned long *imageLenght, char *mimeType);
int libgphoto_deleteImage (GPhotoSession *gphotoSession, char * cameraFolder, char *cameraFile);
int libgphoto_startLongExposure(GPhotoSession *gphotoSession, int transfertMode);

// accessors
int libgphoto_setTransfertMode (GPhotoSession *gphotoSession, int value);
int libgphoto_getExposureTime (GPhotoSession *gphotoSession, float * exposureTime);
int libgphoto_setExposureTime (GPhotoSession *gphotoSession, float exposureTime);
int libgphoto_getDriveMode (GPhotoSession *gphotoSession, int * driveMode);
int libgphoto_setDriveMode (GPhotoSession *gphotoSession, int driveMode);
int libgphoto_getQuality (GPhotoSession *gphotoSession, char * quality);
int libgphoto_setQuality (GPhotoSession *gphotoSession, const char * quality);
int libgphoto_getQualityList (GPhotoSession *gphotoSession, char * qualityList);

const char * libgphoto_getResultString(int result);
