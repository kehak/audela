
#ifndef _INC_LIBESHEL_INFO_IMAGE
#define _INC_LIBESHEL_INFO_IMAGE

typedef int PIC_TYPE;

typedef struct INFOIMAGE
   {int		imax;
    int		jmax;
    PIC_TYPE     *pic;
   } INFOIMAGE;


INFOIMAGE * createImage(int imax, int jmax);
INFOIMAGE * createImage(PIC_TYPE *values, int imax, int jmax);
int freeImage(INFOIMAGE *image);


#endif