#ifdef _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#endif


#include <stdlib.h>  // pour calloc
#include <stdio.h>  // pour calloc
#include "infoimage.h"


/******************* createImage *********************/
/* cree une structure INFOIMAGE                      */
/*****************************************************/
INFOIMAGE * createImage(PIC_TYPE *values, int imax, int jmax) {
   INFOIMAGE * image;

   image = (INFOIMAGE *) calloc(1,sizeof(INFOIMAGE));
   if ( image == NULL ) {
      printf("\nPas assez de memoire pour INFOIMAGE.\n");
      return NULL;
   }
   image->imax = imax;
   image->jmax = jmax;
   image->pic  = values;
   return image;
}



/******************* createImage *********************/
/* cree une structure INFOIMAGE                      */
/*****************************************************/
INFOIMAGE * createImage(int imax, int jmax) {
   INFOIMAGE * image;

   image = (INFOIMAGE *) calloc(1,sizeof(INFOIMAGE));
   if ( image == NULL ) {
      printf("\nPas assez de memoire pour INFOIMAGE.\n");
      return NULL;
   }
   image->imax = imax;
   image->jmax = jmax;
   if ((image->pic=(PIC_TYPE *)calloc(imax*(jmax+1),sizeof(PIC_TYPE)))==NULL)
   {
      printf("\nPas assez de memoirepour INFOIMAGE->pic.\n");
      free(image);
      return NULL;
   }
   return image;
}

/******************* freeImage *********************/
/* supprime une structure INFOIMAGE                */
/***************************************************/
int freeImage(INFOIMAGE *image) {
   if ( image != NULL ) {
      if ( image->pic != NULL ) {
         free(image->pic);
      }
      free(image);
      return -1;
   }
   return 0;
}

