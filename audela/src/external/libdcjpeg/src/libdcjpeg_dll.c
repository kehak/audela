// libjpeg.cpp : Defines the entry point for the DLL application.
//


#ifdef WIN32
#include <windows.h>
#else 
#include <unistd.h>
#include <stdarg.h> // for va_list
#endif


#include "jinclude.h"
#include "jpeglib.h"  // genere "benign redefinition of type" TINT2
#include "jerror.h"

#include "jpegmemscr.h"
#include "malloc.h"

char gLastErrorMessage[1024];

void libdcjpeg_setLastErrorMessage(char * message,...);

#ifdef WIN32
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
    }
    return TRUE;
}

#endif

int libdcjpeg_decodeBuffer(unsigned char * inputData, long inputSize, unsigned char **outputData, long *outputSize, int *width, int *height)
{
 
  struct jpeg_decompress_struct cinfo; 
  struct jpeg_error_mgr jerr; 
  int i, rowSize;
  JSAMPROW rowData[1];

  cinfo.err = jpeg_std_error(&jerr); 
  jpeg_create_decompress(&cinfo); 
  jpeg_mem_src(&cinfo, inputData, inputSize);  
  jpeg_read_header(&cinfo, TRUE); 
  jpeg_start_decompress(&cinfo);

  rowSize= cinfo.output_width * cinfo.output_components;
  *outputSize=cinfo.output_width * cinfo.output_height * cinfo.output_components;
  *outputData=(unsigned char*)malloc(*outputSize);

  for (i=cinfo.output_height-1; i>=0; i--) {
    rowData[0] = (JSAMPROW)(*outputData + i*rowSize);
    jpeg_read_scanlines(&cinfo, rowData, 1);
  }
  jpeg_finish_decompress(&cinfo);
  jpeg_destroy_decompress(&cinfo);

  *width = cinfo.output_width;
  *height = cinfo.output_height;

  return 0;
}


int libdcjpeg_loadFile(const char *fileName, unsigned char **outputData, long *outputSize, int *planes, int *width, int *height)
{
   struct jpeg_decompress_struct cinfo;
   struct jpeg_error_mgr jerr;
   FILE *file;	
   int i, rowSize;
   JSAMPROW rowData[1];

   cinfo.err = jpeg_std_error(&jerr);
   jpeg_create_decompress(&cinfo);
   if ((file=fopen(fileName,"rb"))==NULL)
   {
      fprintf(stderr,"Erreur : impossible d'ouvrir le fichier texture.jpg\n");
      return -1;
   }
   jpeg_stdio_src(&cinfo, file);
   jpeg_read_header(&cinfo, TRUE);
   jpeg_start_decompress(&cinfo);
   
   rowSize= cinfo.output_width * cinfo.output_components;
   *outputSize=cinfo.output_width * cinfo.output_height * cinfo.output_components;
   *outputData=(unsigned char*)malloc(*outputSize);
   
   for (i=cinfo.output_height-1; i>=0; i--) {
      rowData[0] = (JSAMPROW)(*outputData + i*rowSize);
      jpeg_read_scanlines(&cinfo, rowData, 1);
   }
   jpeg_finish_decompress(&cinfo);
   fclose(file);
   jpeg_destroy_decompress(&cinfo);
   
   *width = cinfo.output_width;
   *height = cinfo.output_height;
   *planes = cinfo.output_components;

  return 0;
}

int libdcjpeg_saveFile (const char * filename, unsigned char *inputData, int planes, int width,int height, int quality)
{
   struct jpeg_compress_struct cinfo;
   struct jpeg_error_mgr jerr;
   FILE * outfile;               
   JSAMPROW row_pointer[1];      
   long row_stride;               
   int i;
       
   if (quality<1) {
      quality=1;
   } else if (quality>100) {
      quality=100;
   }
   
   // copie dans le fichier JPEG
   cinfo.err = jpeg_std_error(&jerr);
   i = sizeof(struct jpeg_compress_struct);
   jpeg_CreateCompress(&cinfo,JPEG_LIB_VERSION,i);
   
   if ((outfile = fopen(filename, "wb")) == NULL) {
      libdcjpeg_setLastErrorMessage("can't open %s", filename);
      return -1;
   }
   jpeg_stdio_dest(&cinfo, outfile);
   
   cinfo.image_width = width;      
   cinfo.image_height = height;
   if (planes == 3) {
      cinfo.input_components = 3;           // of color components per pixel 
      cinfo.in_color_space = JCS_RGB;       
   } else if (planes == 1 ) {
      cinfo.input_components = 1;           
      cinfo.in_color_space = JCS_GRAYSCALE; 
   } else {
      libdcjpeg_setLastErrorMessage("planes=%d not supported", planes);          
   }
   
   jpeg_set_defaults(&cinfo);
   jpeg_set_quality(&cinfo, quality, TRUE); // limit to baseline-JPEG 
   jpeg_start_compress(&cinfo, TRUE);

   row_stride = width  * cinfo.input_components; 
   
   while (cinfo.next_scanline < cinfo.image_height) {
      row_pointer[0] = & inputData[cinfo.next_scanline * row_stride];
      jpeg_write_scanlines(&cinfo, row_pointer, 1);
   }
   
   jpeg_finish_compress(&cinfo);
   fclose(outfile);
   jpeg_destroy_compress(&cinfo);
   libdcjpeg_setLastErrorMessage("");
   
   return 0;
}


void libdcjpeg_freeBuffer(unsigned char * data) {

   if( data != 0 ) {
      free( data);
   }
}

void libdcjpeg_setLastErrorMessage(char *message, ...)
{
   va_list va;
	va_start(va, message);
#ifdef WIN32
	_vsnprintf(gLastErrorMessage, sizeof gLastErrorMessage, message, va);
#else
	vsnprintf(gLastErrorMessage, sizeof gLastErrorMessage, message, va);
#endif
   va_end(va);
   gLastErrorMessage[sizeof gLastErrorMessage] = 0;
}

char * libdcjpeg_getLastErrorMessage()
{
   return gLastErrorMessage;

}
