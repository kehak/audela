// File   :libdcraw.c .
// Date   :05/08/2005
// Author :Michel Pujol

#ifdef WIN32
#include <windows.h>
#include <io.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#include "dcraw.h"
#include "libdcraw.h"

// --- FOR WINDOWS ONLY
#ifdef WIN32
#include <windows.h>

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

#define FC(row,col) \
	(filters >> ((((row) << 1 & 14) + ((col) & 1)) << 1) & 3)

#define BAYER(row,col) \
	image[((row) >> shrink)*iwidth + ((col) >> shrink)][FC(row,col)]

/**---------------------------------------------------------------
 * scale_color_cb
 *
 * fonction interne qui remplace scale_color de dcraw.c
 *
 * Cette fonction copie les pixels a decoder la matrice "image"
 * sans modifier les couleurs comme le fait Christian Buil dans iris
 * La balance sera faite ultérieurement par l'utilisateur apres le decodage CFA->RGB
 *
 * parametres
 *   aucun
 * return
 *   void
 *---------------------------------------------------------------
 */

void scale_color_cb ()
{
   int row, col;

   for (row=0; row < height; row++) {
      for (col=0; col < width; col++) {
         image[row*width+col][0] = image[row*width+col][0] + image[row*width+col][1] +image[row*width+col][2] + +image[row*width+col][3];
         image[row*width+col][1] = image[row*width+col][0];
         image[row*width+col][2] = image[row*width+col][0];
         image[row*width+col][3] = image[row*width+col][0];
      }
   }
}

/**---------------------------------------------------------------
 * libdcraw_getInfoFromFile
 *
 * extrait les informations de l'image et les retourne dans une structure dataInfo
 *
 * parametres
 *   inputFileName (IN) nom du fichier RAW
 *   dataInfo      (OUT) information de l'image
 * return
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_getInfoFromFile (const char * inputFileName, struct libdcraw_DataInfo *dataInfo)
{
   int status=0, user_flip=-1;
   int half_size=0;

#if defined(WIN32) || defined(DJGPP) || defined(__CYGWIN__)
   if (setmode(1,O_BINARY) < 0) {
      perror("setmode()");
      return -1;
   }
#endif
   verbose = 0;
   status = 1;
   image = NULL;
   user_flip = 0;
   output_color = 0;
   half_size = 0;

   ifname = inputFileName;
   if( ifname == NULL) {
      return -1;
   }

   if (!(ifp = fopen (ifname, "rb"))) {
      perror (ifname);
      return -1;
   }

   status = (identify(),!is_raw);

   shrink = half_size && filters;
   iheight = (height + shrink) >> shrink;
   iwidth  = (width  + shrink) >> shrink;

   // je position le pointeur de fichier sur le debut des donnees de l'image
   height = iheight;
   width  = iwidth;
   fclose(ifp);


   dataInfo->width  = width;
   dataInfo->height = height;
   dataInfo->filters = filters;
   dataInfo->colors  = colors;
   dataInfo->black  = black;
   dataInfo->maximum = maximum;

   dataInfo->timestamp = timestamp;
   strcpy(dataInfo->make, make);
   strcpy(dataInfo->model, model);
   dataInfo->flash_used = flash_used;
   dataInfo->iso_speed = iso_speed;
   dataInfo->shutter   = shutter;
   dataInfo->aperture  = aperture;
   dataInfo->focal_len = focal_len;

   return status;
}

/**---------------------------------------------------------------
 * libdcraw_fileRaw2Rgb
 *
 * Decode et copie un fichier RAW dans un buffer RGB
 * Cette fonction cree le buffer dataOut.
 * le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 *
 * parametres
 *   inputFileName (IN) nom du fichier RAW
 *   pwidth        (OUT) largeur de l'image en pixels
 *   pheight       (OUT) hauteur de l'image en pixels
 *   dataOut       (OUT) pointeur du buffer de sortie RGB
 * return
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_fileRaw2Rgb (const char * inputFileName, struct libdcraw_DataInfo *dataInfo,  TInterpolationMethod method ,unsigned short ** dataOut)
{
   int status=0, user_flip=-1;
   int half_size=0;
   long row, col, c;


#if defined(WIN32) || defined(DJGPP) || defined(__CYGWIN__)
   if (setmode(1,O_BINARY) < 0) {
      perror("setmode()");
      return -1;
   }
#endif

   verbose = 0;
   status = 1;
   image = NULL;
   user_flip = 0;
   output_color = 0;
   half_size = 0;

   ifname = inputFileName;

   if( ifname == NULL) {
      return -1;
   }

   if (!(ifp = fopen (ifname, "rb"))) {
      perror (ifname);
      return -1;
   }

   status = (identify(),!is_raw);

   shrink = half_size && filters;
   iheight = (height + shrink) >> shrink;
   iwidth  = (width  + shrink) >> shrink;
   image = calloc (iheight*iwidth*sizeof *image + meta_length, 1);
   merror (image, "main()");
   meta_data = (char *) (image + iheight*iwidth);

   // je position le pointeur de fichier sur le debut des donnees de l'image
   fseek (ifp, data_offset, SEEK_SET);

   // je charge le fichier raw
   (*load_raw)();

   // je ferme le fichier
   fclose(ifp);

   //bad_pixels();
   height = iheight;
   width  = iwidth;
   //scale_colors();
   //cam_to_cielab (NULL,NULL);
   scale_color_cb();

   switch( method) {
   case LINEAR :
      lin_interpolate();
      break;
   case VNG :
      vng_interpolate();
      break;
   case ADH :
      ahd_interpolate();
      break;
   case FOVEON :
      free(image);
      printf("libdcraw_fileRaw2Rgb : FOVEON interpolation not implemented.\n");
      return -1;
   }

   if (shrink) filters = 0;
   //convert_to_rgb();

   dataInfo->width  = width;
   dataInfo->height = height;
   dataInfo->filters = filters;
   dataInfo->colors  = colors;
   dataInfo->black  = black;
   dataInfo->maximum = maximum;
   dataInfo->top_margin = top_margin;
   dataInfo->left_margin = left_margin;

   dataInfo->timestamp = timestamp;
   strcpy(dataInfo->make, make);
   strcpy(dataInfo->model, model);
   dataInfo->flash_used = flash_used;
   dataInfo->iso_speed = iso_speed;
   dataInfo->shutter   = shutter;
   dataInfo->aperture  = aperture;
   dataInfo->focal_len = focal_len;

   *dataOut = malloc(width * height *3 * sizeof(unsigned short));
   if( *dataOut == NULL) {
     fprintf(stderr,"insufficient memory.\n");
      return -1;
   }

   for (row=0; row < height; row++) {
      for (col=0; col < width; col++) {
         for (c=0; c < 3; c++) {
              *(*dataOut + (row*width +  col)*3 + c)  = (unsigned short) image[row*width+col][c];
         }
      }
   }


   free (image);
   return status;

}



/**---------------------------------------------------------------
 * libdcraw_fileRaw2Cfa
 *
 * copie un fichier RAW dans un buffer CFA
 * Cette fonction cree le buffer dataOut.
 * le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 *
 * parametres
 *   inputFileName (IN) nom du fichier RAW
 *   pwidth       (OUT) largeur de l'image en pixels
 *   pheight      (OUT) hauteur de l'image en pixels
 *   dataOut      (OUT) pointeur du buffer de sortie
 * return
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_fileRaw2Cfa (const char * inputFileName, struct libdcraw_DataInfo *dataInfo,  unsigned short ** dataOut)
{
   int status=0, user_flip=-1;
   int half_size=0;
   int row, col;
   long row2;

#if defined(WIN32) || defined(DJGPP) || defined(__CYGWIN__)
   if (setmode(1,O_BINARY) < 0) {
      perror("setmode()");
      return -1;
   }
#endif
   verbose = 0;
   status = 1;
   image = NULL;
   user_flip = 0;
   output_color = 0;
   half_size = 0;

   ifname = inputFileName;
   if( ifname == NULL) {
      return -1;
   }

   if (!(ifp = fopen (ifname, "rb"))) {
      perror (ifname);
      return -1;
   }

   status = (identify(),!is_raw);

   shrink = half_size && filters;
   iheight = (height + shrink) >> shrink;
   iwidth  = (width  + shrink) >> shrink;
   image = calloc (iheight*iwidth*sizeof *image + meta_length, 1);
   merror (image, "main()");
   meta_data = (char *) (image + iheight*iwidth);


   // je position le pointeur de fichier sur le debut des donnees de l'image
   fseek (ifp, data_offset, SEEK_SET);
   (*load_raw)();
   height = iheight;
   width  = iwidth;
   fclose(ifp);

   dataInfo->width  = width;
   dataInfo->height = height;
   dataInfo->filters = filters;
   dataInfo->colors  = colors;
   dataInfo->black  = black;
   dataInfo->maximum = maximum;

   dataInfo->timestamp = timestamp;
   strcpy(dataInfo->make, make);
   strcpy(dataInfo->model, model);
   dataInfo->flash_used = flash_used;
   dataInfo->iso_speed = iso_speed;
   dataInfo->shutter   = shutter;
   dataInfo->aperture  = aperture;
   dataInfo->focal_len = focal_len;

   *dataOut = malloc( width *  height * sizeof(unsigned short) );
if( *dataOut == NULL) {
      fprintf(stderr,"libdcraw_fileRaw2Cfa insufficient memory for %d bytes (width=%d, height=%d, pixsize=%d)\n", width *  height * sizeof(unsigned short) , width, height, sizeof(unsigned short) );
      free(image);
      return -1;
   }

   for (row=0; row < height; row++) {
      row2 = height-row-1;
      for (col=0; col < width; col++) {
         //*(*dataOut + row*width  +  col )  =  BAYER((height-row-1),col);
         *(*dataOut + row*width  +  col )  =  BAYER(row2,col);
      }
   }

   free (image);

   return status;
}

/**---------------------------------------------------------------
 * libdcraw_bufferRaw2Cfa
 *
 * Copie un buffer RAW dans un buffer CFA
 * Cette fonction cree le buffer de sortie dataOut.
 * Le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 *
 * parametres
 *   dataIn       (IN)  pointer du buffer RAW
 *   dataInSize   (IN)  taille du buffer en octets
 *   pwidth       (OUT) largeur de l'image en pixels
 *   pheight      (OUT) hauteur de l'image en pixels
 *   dataOut      (OUT) pointeur du buffer de sortie
 * return
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_bufferRaw2Cfa (unsigned short * dataIn, unsigned long dataInSize, struct libdcraw_DataInfo *dataInfo, unsigned short ** dataOut)
{

   char tempFileName[] ="tempfilename2.tmp";
   int result;
   size_t sizeWritten;
   FILE * ofp;

   ofp = fopen (tempFileName, "wb");
   if (ofp) {
      sizeWritten = fwrite (dataIn, dataInSize, 1, ofp);
      fclose(ofp);
      if( sizeWritten == 1 ) {
         result = libdcraw_fileRaw2Cfa (tempFileName, dataInfo, dataOut);
      }
      remove(tempFileName);
      result = 0;
   } else {
      result = -1;
   }

   return result;
}





/**---------------------------------------------------------------
 * libdcraw_bufferRaw2Rgb
 *
 * decode et copie un buffer RAW dans un buffer RGB
 * Cette fonction cree le buffer dataOut.
 * le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 *
 * parametres
 *   dataIn       (IN)  pointer du buffer RAW
 *   dataInSize   (IN)  taille du buffer en octets
 *   pwidth       (OUT) largeur de l'image en pixels
 *   pheight      (OUT) hauteur de l'image en pixels
 *   dataOut      (OUT) pointeur du buffer de sortie RGB
 * return
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_bufferRaw2Rgb (unsigned short * dataIn, unsigned long dataInSize, struct libdcraw_DataInfo *dataInfo, TInterpolationMethod method ,unsigned short **dataOut)
{

   char tempFileName[] ="tempfilename2.tmp";
   int result;
   size_t sizeWritten;
   FILE * ofp;

   ofp = fopen (tempFileName, "wb");
   if (ofp) {
      sizeWritten = fwrite (dataIn, dataInSize, 1, ofp);
      fclose(ofp);
      if( sizeWritten == 1 ) {
         result = libdcraw_fileRaw2Rgb(tempFileName, dataInfo, method, dataOut);
      }
      remove(tempFileName);
      result = 0;
   } else {
      result = -1;
   }

   return result;
}


/**---------------------------------------------------------------
 * libdcraw_bufferCfa2Rgb
 *
 * Copie un buffer RAW dans un buffer CFA
 * Cette fonction cree le buffer de sortie dataOut.
 * Le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 *
 * parametres
 *   dataIn       (IN)  pointer du buffer RAW
 *   dataInSize   (IN)  taille du buffer en octets
 *   pwidth       (OUT) largeur de l'image en pixels
 *   pheight      (OUT) hauteur de l'image en pixels
 *   dataOut      (OUT) pointeur du buffer de sortie
 * return
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_bufferCfa2Rgb (unsigned short * dataIn, struct libdcraw_DataInfo *dataInfo, TInterpolationMethod method , unsigned short **dataOut)
{
   int user_flip=-1;
   int half_size=0;
   long row, col, c, row2;

   verbose = 0;
   image = NULL;
   user_flip = 0;
   output_color = 0;
   half_size = 0;
   shrink = 0;
   //use_auto_wb = 0;
   //highlight = 0;

   width   = dataInfo->width;
   height  = dataInfo->height;
   filters = dataInfo->filters;
   colors  = dataInfo->colors;
   black   = dataInfo->black;
   maximum = dataInfo->maximum;

   //top_margin = dataInfo->top_margin;
   //left_margin = dataInfo->left_margin;

   top_margin = 0;
   left_margin = 0;

   shrink = half_size && filters;
   iheight = (height + shrink) >> shrink;
   iwidth  = (width  + shrink) >> shrink;


   // j'allloue la memoire de la zone de travail
   image = calloc (height * width * sizeof *image, 1);
   if( image == NULL) {
     fprintf(stderr,"insufficient memory.\n");
      return -1;
   }

   //meta_data = (char *) (image + iheight*iwidth);
   meta_data = NULL;

   // je copie les data dans la zone de travail
   // en faisant un mirroir Y
   // comme le fait scale_color_cb()

   for (row=0; row < height; row++) {
      row2 = (height-row-1)*width;
      for (col=0; col < width; col++) {
         //BAYER((height-row-1),col) = *(dataIn + row*width  +  col );
         //BAYER(row,col) = *(dataIn + row*width  +  col );
         image[row2+col][0] = *(dataIn + row*width  +  col );
         image[row2+col][1] = *(dataIn + row*width  +  col );
         image[row2+col][2] = *(dataIn + row*width  +  col );
         image[row2+col][3] = *(dataIn + row*width  +  col );
      }
   }

   //bad_pixels();
   //scale_colors();
   //cam_to_cielab (NULL,NULL);

   //
   pre_interpolate();

   switch( method) {
   case LINEAR :
      lin_interpolate();
      break;
   case VNG :
      vng_interpolate();
      break;
   case ADH :
      ahd_interpolate();
      break;
   case FOVEON :
      free(image);
      printf("libdcraw_fileRaw2Rgb : FOVEON interpolation not implemented.\n");
      return -1;
   }

   //if (shrink) filters = 0;
   //convert_to_rgb();

   *dataOut = malloc(width * height *3 * sizeof(unsigned short));
   if( *dataOut == NULL) {
     fprintf(stderr,"insufficient memory.\n");
      return -1;
   }

   for (row=0; row < height; row++) {
      for (col=0; col < width; col++) {
         for (c=0; c < 3; c++) {
              //*(*dataOut + row*width*3  +  col*3 + c)  = htons(image[row*width+col][c]);
              *(*dataOut + row*width*3  +  col*3 + c)  =  image[row*width+col][c];
         }
      }
   }

   free (image);
   return 0;

}

/**---------------------------------------------------------------
 * libdcraw_freeBuffer
 *
 * supprime un buffer alloue par une fonction de cette librairie
 *
 * parametres
 *   data       (IN)  pointer du buffer a supprimer
 * return
 *   none
 *---------------------------------------------------------------
 */
void libdcraw_freeBuffer (unsigned short * data)
{
   if( data != NULL) {
      free(data);
   }
}

