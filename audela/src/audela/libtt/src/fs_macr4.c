/* fs_macr4.c
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

#include "tt.h"

METHODDEF(void) my_error_exit (j_common_ptr cinfo);

int macr_short2jpg(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7)
/***************************************************************************/
/* Convertit un pointeur short et sauve l'image en JPG                     */
/* L'image sera necessairement noir & blanc.							   */
/***************************************************************************/
/* arg1 : pointeur de short de l'image									   */
/*        (short *)														   */
/* arg2 : nom (dossier+nom+ext) du fichier Jpg en sortie                   */
/*        (char*)														   */
/* arg3 : qualite de l'image JPEG (en general on prend =75)                */
/*        (int*)														   */
/* arg4 : seuil bas (numerique ou mot cle)                                 */
/*        (double *)													   */
/* arg5 : seuil haut (numerique ou mot cle)                                */
/*        (double *)													   */
/* arg6 : valeur du nombre de points sur x                                 */
/*        (int *)														   */
/* arg7 : valeur du nombre de points sur y                                 */
/*        (int *)														   */
/***************************************************************************/
/* Exemple d'appel a ce concertisseur :                                    */
/* int msg=0;                                                              */
/* short *p;                 											   */
/* int qual=75,x=768,y=512;                                                */
/* double sb=1000,sh=2000;                                                 */
/* msg=libfiles_main(FS_MACR_SHORT2JPG,p,"i.jpg",&qual,&sb,&sh,&x,&y);     */
/***************************************************************************/
{
   int i,j;
   int imax,jmax;
	long nelements;
   unsigned char *buf,c;
   char *nom_fichier_jpg;
   int naxis1,naxis2,color_space,qualite;
   int k,kk;
   short *p;
   double seuil_bas,seuil_haut,delta_seuil;

   /* --- chargement des dimensions et du pointeur de l'image ---*/
   p=(short*)(arg1);
   imax=*(int*)(arg6);
   jmax=*(int*)(arg7);

   /* --- chargement des seuils ---*/
   seuil_bas=*(double*)(arg4);
   seuil_haut=*(double*)(arg5);
   /*
   printf("type=%d seuil bas=%f   seuil haut=%f\n",type_seuil,seuil_bas,seuil_haut);
   printf("imax=%d    jmax=%d\n",imax,jmax);
   */

   /* --- transformation de l'image sur 256 niveaux ---*/
   nelements=imax*jmax;
   if ((buf=(unsigned char *)calloc(3*nelements,sizeof(unsigned char)))==NULL) {
      return(FS_ERR_PB_MALLOC);
   }
   delta_seuil=seuil_haut-seuil_bas;
   if (delta_seuil==0) delta_seuil=1;
   for (i=0;i<imax;i++) {
      for (j=0;j<jmax;j++) {
	 /*
	 k=jmax*i+j;
	 kk=jmax*(imax-1-i)+j;
	 */
	 k=imax*j+i;
	 kk=imax*(jmax-1-j)+i;
	 if      (p[k]>=(short)(seuil_haut)) {buf[3*kk+0]=255;buf[3*kk+1]=255;buf[3*kk+2]=255;}
	 else if (p[k]<=(short)(seuil_bas))  {buf[3*kk+0]=0;buf[3*kk+1]=0;buf[3*kk+2]=0;}
	 else {
	    c=(unsigned char)(256*(p[k]-seuil_bas)/delta_seuil);
	    buf[3*kk+0]=c;buf[3*kk+1]=c;buf[3*kk+2]=c;
	 }
      }
   }

   /* --- image JPG ---*/
   nom_fichier_jpg=(char*)(arg2);
   color_space=JCS_RGB;
   naxis1=imax;
   naxis2=jmax;
   qualite=*(int*)(arg3);
   macr_write_jpg(nom_fichier_jpg,&color_space,buf,&naxis1,&naxis2,&qualite);

   free(buf);
   return(OK_DLL);
}


int macr_fits2jpg(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8)
/***************************************************************************/
/* Lit une image Fits et sauve l'image en JPG                              */
/***************************************************************************/
/* arg1 : nom (dossier+nom+ext) du fichier Fits en entree                  */
/* arg2 : nom (dossier+nom+ext) du fichier Jpg en sortie                   */
/* arg3 : =0 si l'on veut lire les arguments de mots cles dans l'entete.   */
/*        =1 si l'on passe des seuils numeriques                           */
/* arg4 : seuil bas (numerique ou mot cle)                                 */
/* arg5 : seuil haut (numerique ou mot cle)                                */
/* arg6 : valeur retournee du nombre de points sur x                       */
/* arg7 : valeur retournee du nombre de points sur y                       */
/* arg8 : critere de qualite de Jpeg                                       */
/***************************************************************************/
/* Exemple d'appel a ce concertisseur :                                    */
/* int msg=0;                                                              */
/* int choix,x,y;                                                          */
/* double sb,sh;                                                           */
/* choix=1;                                                                */
/* sb=2000;                                                                */
/* sh=2300;                                                                */
/* msg=libfiles_main(FS_MACR_FITS2JPG,"i.fit","i.jpg",&choix,&sb,&sh,&x,&y);*/
/***************************************************************************/
{
   int i,j;
   int imax,jmax;
   unsigned char *buf,c;

   int naxis1,naxis2,color_space,qualite;

   int naxis,datatype,msg;
   long *naxes;
   float *p;
   char *nom_fichier_fits,*nom_fichier_jpg,*keyname,charvalue[FLEN_VALUE];
   int bitpix,typehdu,numhdu;
	long firstelem,nelements;
   int type_seuil,nbkeys,k,kk;
   double seuil_bas,seuil_haut,delta_seuil;
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];

   /* --- chargement de l'image ---*/
   nom_fichier_fits=(char*)(arg1);
   datatype=TFLOAT;
   typehdu=IMAGE_HDU;
   numhdu=1;
   firstelem=1;
   nelements=0;
   if ((msg=libfiles_main(FS_MACR_READ,10,nom_fichier_fits,&numhdu,&typehdu,&firstelem,&nelements,&naxis,&naxes,&bitpix,&datatype,&p))!=0) {
      return(msg);
   }
   if (naxis>=2) {
      imax=naxes[naxis-2];
      jmax=naxes[naxis-1];
      *(int*)(arg6)=imax;
      *(int*)(arg7)=jmax;
      nelements=imax*jmax;
   } else {
      /*
      free(p);
      free(naxes);
      */
      tt_free2((void**)&p,"p->p");
      tt_free2((void**)&naxes,"p->naxes");
      return(PB_DLL);
   }
   /*
   free(naxes);
   */
   tt_free2((void**)&naxes,"p->naxes");

   /* --- chargement des seuils ---*/
   type_seuil=*(int*)(arg3);
   if (type_seuil==1) {
      seuil_bas=*(double*)(arg4);
      seuil_haut=*(double*)(arg5);
   } else {
      nbkeys=1;
      keyname=(char*)(arg4);
      /*found=1;*/
      if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,nom_fichier_fits,&numhdu,&nbkeys,keyname,comment,unit,&datatype,charvalue))!=0) {
	 if (msg==202) {
	    /*found=0;*/
	    seuil_bas=0;
	 } else {
            tt_free2((void**)&p,"p->p");
            /*
	    free(p);
            */
	    return(msg);
	 }
      } else {
	 seuil_bas=atof(charvalue);
      }
      keyname=(char*)(arg5);
      /*found=1;*/
      if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,nom_fichier_fits,&numhdu,&nbkeys,keyname,comment,unit,&datatype,charvalue))!=0) {
	 if (msg==202) {
	    /*found=0;*/
	    seuil_haut=1;
	 } else {
            /*
	    free(p);
            */
            tt_free2((void**)&p,"p->p");
	    return(msg);
	 }
      } else {
	 seuil_haut=atof(charvalue);
      }
   }
   /*
   printf("type=%d seuil bas=%f   seuil haut=%f\n",type_seuil,seuil_bas,seuil_haut);
   printf("imax=%d    jmax=%d\n",imax,jmax);
   */

   /* --- transformation de l'image sur 256 niveaux ---*/
   if ((buf=(unsigned char *)calloc(3*nelements,sizeof(unsigned char)))==NULL) {
      return(FS_ERR_PB_MALLOC);
   }
   delta_seuil=seuil_haut-seuil_bas;
   if (delta_seuil==0) delta_seuil=1;

   for (i=0;i<imax;i++) {
      for (j=0;j<jmax;j++) {
	 /*
	 k=jmax*i+j;
	 kk=jmax*(imax-1-i)+j;
	 */
	 k=imax*j+i;
	 kk=imax*(jmax-1-j)+i;
	 if      (p[k]>=(float)(seuil_haut)) {buf[3*kk+0]=255;buf[3*kk+1]=255;buf[3*kk+2]=255;}
	 else if (p[k]<=(float)(seuil_bas))  {buf[3*kk+0]=0;buf[3*kk+1]=0;buf[3*kk+2]=0;}
	 else {
	    c=(unsigned char)(256*(p[k]-seuil_bas)/delta_seuil);
	    buf[3*kk+0]=c;buf[3*kk+1]=c;buf[3*kk+2]=c;
	 }
      }
   }

   /* --- image JPG ---*/
   nom_fichier_jpg=(char*)(arg2);
   color_space=JCS_RGB;
   naxis1=imax;
   naxis2=jmax;
   qualite=*(int*)(arg8);
   if (qualite<1) {qualite=1;}
   if (qualite>100) {qualite=100;}
   if ((msg=macr_write_jpg(nom_fichier_jpg,&color_space,buf,&naxis1,&naxis2,&qualite))!=OK_DLL) {
      return(msg);
   }
   free(buf);
   /*
   free(p);
   */
   tt_free2((void**)&p,"p->p");
   return(OK_DLL);
}

int macr_write_jpg(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6)
/***************************************************************************/
/* Ecrit une nouvelle image au format JPEG sur le disque.                  */
/***************************************************************************/
/* arg1 : Nom du fichier JPEG a creer (dossier+nom+ext)                    */
/*        (char)(*nom_fichier).                                            */
/* arg2 : Flag couleur / noir & blanc. (JCS_RGB / JCS_GRAYSCALE)           */
/*        (int)(color_space)                                               */
/* arg3 : Pointeur image 1*8bits (si JCS_GRAYSCALE), sinon 3*8bits RGB.    */
/*        (unsigned char)(*pointeur).                                      */
/* arg4 : Largeur de l'image (nombre de colonnes).                         */
/*        (int)(naxis1).                                                   */
/* arg5 : Hauteur de l'image (nombre de lignes).                           */
/*        (int)(naxis2).                                                   */
/* arg6 : Niveau de qualite. En general on prend =75.                      */
/*        (int)(quality).                                                  */
/***************************************************************************/
{
   char *nom_fichier;
   int color_space,naxis1,naxis2,quality;
   unsigned char *p;
   nom_fichier=(char*)(arg1);
   color_space=*(int*)(arg2);
   p=(unsigned char*)(arg3);
   naxis1=*(int*)(arg4);
   naxis2=*(int*)(arg5);
   quality=*(int*)(arg6);
   write_JPEG_file(nom_fichier,color_space,p,naxis1,naxis2,quality);
   return(OK_DLL);
}

int macr_read_jpg(void *arg1,void *arg2,void **arg3,void *arg4,void *arg5)
/***************************************************************************/
/* Ecrit une nouvelle image au format JPEG sur le disque.                  */
/***************************************************************************/
/* arg1 : Nom du fichier JPEG a creer (dossier+nom+ext)                    */
/*        (char)(*nom_fichier).                                            */
/* arg2 : Flag couleur / noir & blanc. (JCS_RGB / JCS_GRAYSCALE)           */
/*        (int)(color_space)                                               */
/* arg3 : Pointeur image 1*8bits (si JCS_GRAYSCALE), sinon 3*8bits RGB.    */
/*        (unsigned char)(**pointeur).                                     */
/* arg4 : Largeur de l'image (nombre de colonnes).                         */
/*        (int)(naxis1).                                                   */
/* arg5 : Hauteur de l'image (nombre de lignes).                           */
/*        (int)(naxis2).                                                   */
/***************************************************************************/
{
   char *nom_fichier;
   int *color_space,*naxis1,*naxis2;
   unsigned char **p;
   nom_fichier=(char*)(arg1);
   color_space=(int*)(arg2);
   p=(unsigned char**)(arg3);
   *p=NULL;
   /*printf("a  %d %p **=%p\n",p,*p,p);*/
   naxis1=(int*)(arg4);
   naxis2=(int*)(arg5);
   read_JPEG_file(nom_fichier,color_space,p,naxis1,naxis2);
   /*printf("aa %d %p **=%p\n",p,*p,p);*/
   return(OK_DLL);
}


/*
 * Sample routine for JPEG compression.  We assume that the target file name
 * and a compression quality factor are passed in.
 */

GLOBAL(int) write_JPEG_file (char * filename, int color_space, JSAMPLE *image_buffer,int image_width,int image_height,int quality)
{
  /* This struct contains the JPEG compression parameters and pointers to
   * working space (which is allocated as needed by the JPEG library).
   * It is possible to have several such structures, representing multiple
   * compression/decompression processes, in existence at once.  We refer
   * to any one struct (and its associated working data) as a "JPEG object".
   */
  struct jpeg_compress_struct cinfo;
  /* This struct represents a JPEG error handler.  It is declared separately
   * because applications often want to supply a specialized error handler
   * (see the second half of this file for an example).  But here we just
   * take the easy way out and use the standard error handler, which will
   * print a message on stderr and call exit() if compression fails.
   * Note that this struct must live as long as the main JPEG parameter
   * struct, to avoid dangling-pointer problems.
   */
  struct jpeg_error_mgr jerr;
  /* More stuff */
  FILE * outfile;               /* target file */
  JSAMPROW row_pointer[1];      /* pointer to JSAMPLE row[s] */
  int row_stride;               /* physical row width in image buffer */
  int i;

  /* Step 1: allocate and initialize JPEG compression object */

  /* We have to set up the error handler first, in case the initialization
   * step fails.  (Unlikely, but it could happen if you are out of memory.)
   * This routine fills in the contents of struct jerr, and returns jerr's
   * address which we place into the link field in cinfo.
   */
  cinfo.err = jpeg_std_error(&jerr);
  i = sizeof(struct jpeg_compress_struct);
  /* Now we can initialize the JPEG compression object. */
/*  jpeg_create_compress(&cinfo);*/
  jpeg_CreateCompress(&cinfo,JPEG_LIB_VERSION,i);

  /* Step 2: specify data destination (eg, a file) */
  /* Note: steps 2 and 3 can be done in either order. */

  /* Here we use the library-supplied code to send compressed data to a
   * stdio stream.  You can also write your own code to do something else.
   * VERY IMPORTANT: use "b" option to fopen() if you are on a machine that
   * requires it in order to write binary files.
   */
  if ((outfile = fopen(filename, "wb")) == NULL) {
    fprintf(stderr, "can't open %s\n", filename);
    return(FS_ERR_JPEG_FILE_NOT_FOUND);
    /*exit(1);*/
  }
  jpeg_stdio_dest(&cinfo, outfile);

  /* Step 3: set parameters for compression */

  /* First we supply a description of the input image.
   * Four fields of the cinfo struct must be filled in:
   */
  cinfo.image_width = image_width;      /* image width and height, in pixels */
  cinfo.image_height = image_height;
  if (color_space==JCS_RGB) {
     cinfo.input_components = 3;           /* # of color components per pixel */
     cinfo.in_color_space = JCS_RGB;       /* colorspace of input image */
  } else if (color_space==JCS_GRAYSCALE) {
     cinfo.input_components = 3;           /* # of color components per pixel */
     cinfo.in_color_space = JCS_GRAYSCALE; /* colorspace of input image */
  } else {
     cinfo.input_components = 4;           /* # of color components per pixel */
     cinfo.in_color_space = color_space;       /* colorspace of input image */
  }

  /* Now use the library's routine to set default compression parameters.
   * (You must set at least cinfo.in_color_space before calling this,
   * since the defaults depend on the source color space.)
   */
  jpeg_set_defaults(&cinfo);
  /* Now you can set any non-default parameters you wish to.
   * Here we just illustrate the use of quality (quantization table) scaling:
   */
  jpeg_set_quality(&cinfo, quality, TRUE /* limit to baseline-JPEG values */);

  /* Step 4: Start compressor */

  /* TRUE ensures that we will write a complete interchange-JPEG file.
   * Pass TRUE unless you are very sure of what you're doing.
   */
  jpeg_start_compress(&cinfo, TRUE);

  /* Step 5: while (scan lines remain to be written) */
  /*           jpeg_write_scanlines(...); */

  /* Here we use the library's state variable cinfo.next_scanline as the
   * loop counter, so that we don't have to keep track ourselves.
   * To keep things simple, we pass one scanline per call; you can pass
   * more if you wish, though.
   */
  /*row_stride = image_width * 3; JSAMPLEs per row in image_buffer */
  row_stride = image_width * (int)(cinfo.input_components); /* rajoute par Alain */

  while (cinfo.next_scanline < cinfo.image_height) {
    /* jpeg_write_scanlines expects an array of pointers to scanlines.
     * Here the array is only one element long, but you could pass
     * more than one scanline at a time if that's more convenient.
     */
    row_pointer[0] = & image_buffer[cinfo.next_scanline * row_stride];
    (void) jpeg_write_scanlines(&cinfo, row_pointer, 1);
  }

  /* Step 6: Finish compression */

  jpeg_finish_compress(&cinfo);
  /* After finish_compress, we can close the output file. */
  fclose(outfile);

  /* Step 7: release JPEG compression object */

  /* This is an important step since it will release a good deal of memory. */
  jpeg_destroy_compress(&cinfo);

  /* And we're done! */
  return(OK_DLL);
}


/*
 * SOME FINE POINTS:
 *
 * In the above loop, we ignored the return value of jpeg_write_scanlines,
 * which is the number of scanlines actually written.  We could get away
 * with this because we were only relying on the value of cinfo.next_scanline,
 * which will be incremented correctly.  If you maintain additional loop
 * variables then you should be careful to increment them properly.
 * Actually, for output to a stdio stream you needn't worry, because
 * then jpeg_write_scanlines will write all the lines passed (or else exit
 * with a fatal error).  Partial writes can only occur if you use a data
 * destination module that can demand suspension of the compressor.
 * (If you don't know what that's for, you don't need it.)
 *
 * If the compressor requires full-image buffers (for entropy-coding
 * optimization or a multi-scan JPEG file), it will create temporary
 * files for anything that doesn't fit within the maximum-memory setting.
 * (Note that temp files are NOT needed if you use the default parameters.)
 * On some systems you may need to set up a signal handler to ensure that
 * temporary files are deleted if the program is interrupted.  See libjpeg.doc.
 *
 * Scanlines MUST be supplied in top-to-bottom order if you want your JPEG
 * files to be compatible with everyone else's.  If you cannot readily read
 * your data in that order, you'll need an intermediate array to hold the
 * image.  See rdtarga.c or rdbmp.c for examples of handling bottom-to-top
 * source data using the JPEG code's internal virtual-array mechanisms.
 */



/******************** JPEG DECOMPRESSION SAMPLE INTERFACE *******************/

/* This half of the example shows how to read data from the JPEG decompressor.
 * It's a bit more refined than the above, in that we show:
 *   (a) how to modify the JPEG library's standard error-reporting behavior;
 *   (b) how to allocate workspace using the library's memory manager.
 *
 * Just to make this example a little different from the first one, we'll
 * assume that we do not intend to put the whole image into an in-memory
 * buffer, but to send it line-by-line someplace else.  We need a one-
 * scanline-high JSAMPLE array as a work buffer, and we will let the JPEG
 * memory manager allocate it for us.  This approach is actually quite useful
 * because we don't need to remember to deallocate the buffer separately: it
 * will go away automatically when the JPEG object is cleaned up.
 */


/*
 * ERROR HANDLING:
 *
 * The JPEG library's standard error handler (jerror.c) is divided into
 * several "methods" which you can override individually.  This lets you
 * adjust the behavior without duplicating a lot of code, which you might
 * have to update with each future release.
 *
 * Our example here shows how to override the "error_exit" method so that
 * control is returned to the library's caller when a fatal error occurs,
 * rather than calling exit() as the standard error_exit method does.
 *
 * We use C's setjmp/longjmp facility to return control.  This means that the
 * routine which calls the JPEG library must first execute a setjmp() call to
 * establish the return point.  We want the replacement error_exit to do a
 * longjmp().  But we need to make the setjmp buffer accessible to the
 * error_exit routine.  To do this, we make a private extension of the
 * standard JPEG error handler object.  (If we were using C++, we'd say we
 * were making a subclass of the regular error handler.)
 *
 * Here's the extended error handler struct:
 */

struct my_error_mgr {
  struct jpeg_error_mgr pub;    /* "public" fields */

  jmp_buf setjmp_buffer;        /* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

/*
 * Here's the routine that will replace the standard error_exit method:
 */

METHODDEF(void)
my_error_exit (j_common_ptr cinfo)
{
  /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
  my_error_ptr myerr = (my_error_ptr) cinfo->err;

  /* Always display the message. */
  /* We could postpone this until after returning, if we chose. */
  (*cinfo->err->output_message) (cinfo);

  /* Return control to the setjmp point */
  longjmp(myerr->setjmp_buffer, 1);
}


/*
 * Sample routine for JPEG decompression.  We assume that the source file name
 * is passed in.  We want to return 1 on success, 0 on error.
 */


GLOBAL(int) read_JPEG_file (char * filename, int *color_space, JSAMPLE **image_buffer,int *image_width,int *image_height)
{
  /* This struct contains the JPEG decompression parameters and pointers to
   * working space (which is allocated as needed by the JPEG library).
   */
  struct jpeg_decompress_struct cinfo;
  /* We use our private extension JPEG error handler.
   * Note that this struct must live as long as the main JPEG parameter
   * struct, to avoid dangling-pointer problems.
   */
  struct my_error_mgr jerr;
  /* More stuff */
  FILE * infile;                /* source file */
  JSAMPARRAY buffer;            /* Output row buffer */
  int row_stride;               /* physical row width in output buffer */
  int kk,kkk; /* Ajoutes par alain */
  unsigned char *pointeur;

  /* In this example we want to open the input file before doing anything else,
   * so that the setjmp() error recovery below can assume the file is open.
   * VERY IMPORTANT: use "b" option to fopen() if you are on a machine that
   * requires it in order to read binary files.
   */
   /*printf("q   %d %p **=%p ***=%p\n",image_buffer,*image_buffer,image_buffer,&image_buffer);*/

  if ((infile = fopen(filename, "rb")) == NULL) {
    fprintf(stderr, "can't open %s\n", filename);
    return(FS_ERR_JPEG_FILE_NOT_FOUND);
  }

  /* Step 1: allocate and initialize JPEG decompression object */

  /* We set up the normal JPEG error routines, then override error_exit. */
  cinfo.err = jpeg_std_error(&jerr.pub);
  jerr.pub.error_exit = my_error_exit;
  /* Establish the setjmp return context for my_error_exit to use. */
  if (setjmp(jerr.setjmp_buffer)) {
    /* If we get here, the JPEG code has signaled an error.
     * We need to clean up the JPEG object, close the input file, and return.
     */
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);
    return(FS_ERR_JPEG_READ);
  }
  /* Now we can initialize the JPEG decompression object. */
  jpeg_create_decompress(&cinfo);

  /* Step 2: specify data source (eg, a file) */

  jpeg_stdio_src(&cinfo, infile);

  /* Step 3: read file parameters with jpeg_read_header() */

  (void) jpeg_read_header(&cinfo, TRUE);
  /* We can ignore the return value from jpeg_read_header since
   *   (a) suspension is not possible with the stdio data source, and
   *   (b) we passed TRUE to reject a tables-only JPEG file as an error.
   * See libjpeg.doc for more info.
   */

   /* infos de retour */
   *image_width=((int)cinfo.image_width);      /* image width and height, in pixels */
   *image_height=((int)cinfo.image_height);
   *color_space=((int)cinfo.jpeg_color_space);

  /* Step 4: set parameters for decompression */

  /* In this example, we don't need to change any of the defaults set by
   * jpeg_read_header(), so we do nothing here.
   */

  /* Step 5: Start decompressor */

  (void) jpeg_start_decompress(&cinfo);
  /* We can ignore the return value since suspension is not possible
   * with the stdio data source.
   */

  /* We may need to do some setup of our own at this point before reading
   * the data.  After jpeg_start_decompress() we have the correct scaled
   * output image dimensions available, as well as the output colormap
   * if we asked for color quantization.
   * In this example, we need to make an output work buffer of the right size.
   */
  /* JSAMPLEs per row in output buffer */
  row_stride = cinfo.output_width * cinfo.output_components;
  kkk=cinfo.output_width * cinfo.output_height * cinfo.output_components;
  pointeur=(unsigned char*)malloc(kkk*sizeof(unsigned char));

  /* Make a one-row-high sample array that will go away when done with image */
  buffer = (*cinfo.mem->alloc_sarray)
		((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);

  /* Step 6: while (scan lines remain to be read) */
  /*           jpeg_read_scanlines(...); */

  /* Here we use the library's state variable cinfo.output_scanline as the
   * loop counter, so that we don't have to keep track ourselves.
   */
  kk=0;
  while (cinfo.output_scanline < cinfo.output_height) {
    /* jpeg_read_scanlines expects an array of pointers to scanlines.
     * Here the array is only one element long, but you could ask for
     * more than one scanline at a time if that's more convenient.
     */
    (void) jpeg_read_scanlines(&cinfo, buffer, 1);
    /* Assume put_scanline_someplace wants a pointer and sample count. */
    /* put_scanline_someplace(buffer[0], row_stride);*/
    for (kkk=0;kkk<row_stride;kkk++) {
       pointeur[kk]=(unsigned char)(*buffer[kkk]);
    }
    kk=kk+kkk+1;
  }

  /* Step 7: Finish decompression */

  (void) jpeg_finish_decompress(&cinfo);
  /* We can ignore the return value since suspension is not possible
   * with the stdio data source.
   */

  /* --- on assigne le pointeur de retour a celui de l'image chargee ---*/
  *image_buffer=(unsigned char*)(pointeur);

  /* Step 8: Release JPEG decompression object */

  /* This is an important step since it will release a good deal of memory. */
  jpeg_destroy_decompress(&cinfo);

  /* After finish_decompress, we can close the input file.
   * Here we postpone it until after no more JPEG errors are possible,
   * so as to simplify the setjmp error logic above.  (Actually, I don't
   * think that jpeg_destroy can do an error exit, but why assume anything...)
   */
  fclose(infile);

  /* At this point you may want to check to see whether any corrupt-data
   * warnings occurred (test whether jerr.pub.num_warnings is nonzero).
   */

  /* And we're done! */
  return(OK_DLL);
}


/*
 * SOME FINE POINTS:
 *
 * In the above code, we ignored the return value of jpeg_read_scanlines,
 * which is the number of scanlines actually read.  We could get away with
 * this because we asked for only one line at a time and we weren't using
 * a suspending data source.  See libjpeg.doc for more info.
 *
 * We cheated a bit by calling alloc_sarray() after jpeg_start_decompress();
 * we should have done it beforehand to ensure that the space would be
 * counted against the JPEG max_memory setting.  In some systems the above
 * code would risk an out-of-memory error.  However, in general we don't
 * know the output image dimensions before jpeg_start_decompress(), unless we
 * call jpeg_calc_output_dimensions().  See libjpeg.doc for more about this.
 *
 * Scanlines are returned in the same order as they appear in the JPEG file,
 * which is standardly top-to-bottom.  If you must emit data bottom-to-top,
 * you can use one of the virtual arrays provided by the JPEG memory manager
 * to invert the data.  See wrbmp.c for an example.
 *
 * As with compression, some operating modes may require temporary files.
 * On some systems you may need to set up a signal handler to ensure that
 * temporary files are deleted if the program is interrupted.  See libjpeg.doc.
 */

