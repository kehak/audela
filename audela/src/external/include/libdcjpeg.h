
// File   :jpegdecompress.h .
// Date   :05/08/2005
// Author :Michel Pujol

#ifndef __LIBDCJEG_SRC_H__
#define __LIBDCJEG_SRC_H__

#ifdef __cplusplus
extern "C" {
#endif


int  libdcjpeg_decodeBuffer(unsigned char * inputData, long inputSize, unsigned char **outputData, long *outputSize, int *width, int *height);
int  libdcjpeg_loadFile(const char * fileName, unsigned char **outputData, long *outputSize, int *planes, int *width, int *height);
int  libdcjpeg_saveFile (const char * filename, unsigned char *inputData, int planes, int width,int height, int quality);
void libdcjpeg_freeBuffer(unsigned char *data);
void libdcjpeg_getLastErrorMessage( char *data);

#ifdef __cplusplus
}
#endif

#endif

