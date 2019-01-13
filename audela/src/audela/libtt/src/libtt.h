/* libtt.h
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

#pragma once 

#ifdef WIN32
#if defined(LIBTT_EXPORTS) // inside DLL
#   define LIBTT_API   __declspec(dllexport)
#else // outside DLL
#   define LIBTT_API   __declspec(dllimport)
#endif 

#else 

#if defined(LIBTT_EXPORTS) // inside DLL
#   define LIBTT_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define LIBTT_API 
#endif 

#endif


/***************************************************************************/
/************** variables utiles pour les fonctions de FITSIO **************/
/**************        utilisees par libtt                    **************/
/***************************************************************************/
/*                     ne pas changer ces valeurs                          */
/***************************************************************************/

#ifndef FLEN_FILENAME 
#define FLEN_FILENAME 1025 /* max length of a filename  */
/*#define FLEN_FILENAME 161*/ /* max length of a filename  */
#endif

#ifndef FLEN_KEYWORD 
#define FLEN_KEYWORD   72  /* max length of a keyword (HIERARCH convention) */
/*#define FLEN_KEYWORD    9*/  /* max length of a keyword */
#endif

#define FLEN_CARD      81  /* length of a FITS header card */
#define FLEN_VALUE     71  /* max length of a keyword value string */
#define FLEN_COMMENT   73  /* max length of a keyword comment string */
#define FLEN_ERRMSG    81  /* max length of a FITSIO error message */
#define FLEN_STATUS    31  /* max length of a FITSIO status text string */

#define TBIT          1  /* codes for FITS table data types */
#define TBYTE_FITS   11  // TBYTE is already defined in windows header (winnt.h) 
#define TLOGICAL     14
#define TSTRING      16
#define TUSHORT      20
#define TSHORT       21
#define TINT         31
#define TULONG       40
#define TLONG        41
#define TFLOAT       42
#define TDOUBLE      82
#define TCOMPLEX     83
#define TDBLCOMPLEX 163

#define BYTE_IMG      8  /* BITPIX code values for FITS image types */
#define SHORT_IMG    16
#define LONG_IMG     32
#define FLOAT_IMG   -32
#define DOUBLE_IMG  -64
			 /* The following 2 codes are not true FITS         */
			 /* datatypes; these codes are only used internally */
			 /* within cfitsio to make it easier for users      */
			 /* to deal with unsigned integers.                 */
#define USHORT_IMG   20
#define ULONG_IMG    40

//**************************************************************************
// error code 
//***************************************************************************
#define OK_DLL 0
#define PB_DLL -1
#define TT_ERR_SERVICE_NOT_FOUND -2
#define TT_ERR_PB_MALLOC -3
#define TT_ERR_HDUNUM_OVER -7
#define TT_ERR_REMOVE_FILE -10
#define TT_ERR_HDU_NOT_IMAGE -16
#define TT_ERR_PTR_ALREADY_ALLOC -17
#define TT_ERR_FILENAME_TOO_LONG -18
#define TT_ERR_NOT_ENOUGH_ARGUS -19
#define TT_ERR_NOT_ALLOWED_FILENAME -20
#define TT_ERR_DECREASED_INDEXES -21
#define TT_ERR_IMAGES_NOT_SAME_SIZE -22
#define TT_ERR_FCT_IS_NOT_AS_SERVICE -23
#define TT_ERR_FCT_NOT_FOUND_IN_IMASTACK -24
#define TT_ERR_FCT_NOT_FOUND_IN_IMASERIES -25
#define TT_ERR_FILE_NOT_FOUND -26
#define TT_ERR_OBJEFILE_NOT_FOUND -27
#define TT_ERR_PIXEFILE_NOT_FOUND -28
#define TT_ERR_CATAFILE_NOT_FOUND -29
#define TT_ERR_ALLOC_NUMBER_ZERO -30
#define TT_ERR_ALLOC_SIZE_ZERO -31
#define TT_ERR_FILE_CANNOT_BE_WRITED -32
#define TT_ERR_NULL_EIGENVALUE -33
#define TT_ERR_MATCHING_MATCH_TRIANG -34
#define TT_ERR_MATCHING_CALCUL_TRIANG -35
#define TT_ERR_MATCHING_CALCUL_DIST -36
#define TT_ERR_MATCHING_BEST_CORRESP -37
#define TT_ERR_MATCHING_REGISTER -38
#define TT_ERR_TBLDATATYPES -39
#define TT_ERR_PARAMRESAMPLE_NUMBER -40
#define TT_ERR_PARAMRESAMPLE_IRREGULAR -41
#define TT_ERR_MATCHING_NULL_DISTANCES -42
#define TT_ERR_NAXIS12_NULL -43
#define TT_ERR_NAXIS_NULL -44
#define TT_ERR_NAXISN_NULL -45
#define TT_ERR_BITPIX_NULL -46
#define TT_ERR_WCS_KEYWORD_NOT_FOUND -47
#define TT_ERR_NULL_PARAMETER -48

#define TT_WAR_ALLOC_NOTNULLPTR -1001
#define TT_WAR_FREE_NULLPTR -1002
#define TT_WAR_INDEX_OUTMAX -1003
#define TT_WAR_INDEX_OUTMIN -1004

//**************************************************************************
// TT  service code of libtt_main(service, .... )
//***************************************************************************
#define TT_ERROR_MESSAGE                100
#define TT_LAST_ERROR_MESSAGE           101
#define TT_SCRIPT_2                     102
#define TT_SCRIPT_3                     103

#define TT_PTR_LOADIMA                  201
#define TT_PTR_LOADKEYS                 202
#define TT_PTR_ALLOKEYS                 203
#define TT_PTR_STATIMA                  204
#define TT_PTR_SAVEIMA                  205
#define TT_PTR_SAVEKEYS                 206
#define TT_PTR_SAVEJPG                  207
#define TT_PTR_FREEPTR                  208
#define TT_PTR_FREEKEYS                 209
#define TT_PTR_SAVEJPGCOLOR             211
#define TT_PTR_CUTSIMA                  212
#define TT_PTR_SAVEIMA3D                213
#define TT_PTR_LOADIMA3D                214
#define TT_PTR_SAVEIMA1D                215
#define TT_PTR_SAVEIMAKEYDIM            216

#define TT_PTR_IMASERIES                210

#define TT_PTR_ALLOTBL                  220
#define TT_PTR_FREETBL                  221
#define TT_PTR_SAVETBL                  222

#define TT_UTIL_FREE_PTR              20203
#define TT_UTIL_CALLOC_PTRPTR_CHAR    20204
#define TT_UTIL_CALLOC_PTR            20205
#define TT_UTIL_TMP_DIR               20206

#define TT_FCT_IMA_STACK               1001
#define TT_FCT_IMA_SERIES              1002

//***************************************************************************
// types definition
//***************************************************************************
#define TT_PTYPE float
#define TT_PARAMRESAMPLE 500 /* longueur de la chaine des 6 parametres*/

//***************************************************************************
// user options
//***************************************************************************
/* --- Ajout de parametres pour la classe ima/series --- */
typedef struct {
   double param1;
} TT_USER1_IMA_SERIES;

/* --- Ajout de parametres pour la classe ima/stack --- */
typedef struct {
   double param1;
} TT_USER1_IMA_STACK;

/* --- Ajout de parametres pour la classe ima/series --- */
typedef struct {
   int y1;
   int y2;
   int height;
   char direction[2];
   char filename[11];
   int nl;
   int nr;
   int ld;
   int m;
   double wavelengthmin;
   double wavelengthmax;
   int xmin;
   int xmax;
} TT_USER2_IMA_SERIES;

/* --- Ajout de parametres pour la classe ima/stack --- */
typedef struct {
   double param1;
} TT_USER2_IMA_STACK;

/* --- Ajout de parametres pour la classe ima/series --- */
typedef struct {
    double param1;
  } TT_USER4_IMA_SERIES;

/* --- Ajout de parametres pour la classe ima/stack --- */
typedef struct {
   double param1;
} TT_USER4_IMA_STACK;

/* --- Ajout de parametres pour la classe ima/series --- */
typedef struct {
   double param1;
   char filename[30];
   double x0;
   double y0;
   double angle;
} TT_USER5_IMA_SERIES;

/* --- Ajout de parametres pour la classe ima/stack --- */
typedef struct {
   double param1;
} TT_USER5_IMA_STACK;

/* --- Ajout de parametres pour la classe ima/series --- */
typedef struct {
   double x0;
   double y0;
   double angle;
   int x1;
   int x2;
   int width;
   int y1;
   int y2;
   int height;
   /*char* direction;*/
   char direction[2];
   int offset;
   /*char* filename;*/
   char filename[11];
   /*char* filematrix;*/
   char filematrix[11];
   double offsetlog;
   double coeff;
   double scale_theta;
   double scale_rho;
} TT_USER3_IMA_SERIES;

/* --- Ajout de parametres pour la classe ima/stack --- */
typedef struct {
   double param1;
} TT_USER3_IMA_STACK;

//***************************************************************************
//  TT_IMA_SERIES_OPTION
//***************************************************************************
typedef struct {
   int bitpix;
   int jpegfile_make;
   char jpegfile[FLEN_FILENAME];
   int jpeg_qualite;
   double kappa;
   double drop_pixsize;
   int powernorm;
   
   double magrlim;
   double magblim;
   int matchwcs;
   double xcenter;
   double ycenter;
   double radius;
   double exposure;
   char nom_trait[20];
   char struct_elem[20];
   double angle;
   double background;
   int fitorder6543;
   char key_exptime[FLEN_KEYWORD];
   char key_dexptime[FLEN_KEYWORD];
   char keylocut[FLEN_KEYWORD];
   char keyhicut[FLEN_KEYWORD];
   char keytype[FLEN_KEYWORD];
   double lofrac;
   double hifrac;
   double cutscontrast;
   char file_ascii[FLEN_FILENAME];
   int skylevel_compute;
   int pixel_list;
   int object_list;
   int catalog_list;
   char catafile[FLEN_FILENAME];
   char objefile[FLEN_FILENAME];
   char objefiletype[50];
   char pixefile[FLEN_FILENAME];
   int pixint;
   double normaflux;
   double offset;
   int nbsubseries;
   int sigma_given;
   double sigma_value;
   double binary_yesno;
   int jpegfile_chart_make;
   int jpegfile_chart2_make;
   char jpegfile_chart[FLEN_FILENAME];
   char jpegfile_chart2[FLEN_FILENAME];
   char file[FLEN_FILENAME];
   char dark[FLEN_FILENAME];
   char bias[FLEN_FILENAME];
   char centroide[20];
   char flat[FLEN_FILENAME];
   char path_astromcatalog[FLEN_FILENAME];
   char astromcatalog[FLEN_FILENAME];
   int regitrans;
   double therm_kappa;
   char paramresample[TT_PARAMRESAMPLE];
   double detect_kappa;
   double power;
   double bordure;
   int pixelsat_compute;
   double pixelsat_value;
   int nullpix_exist;
   double nullpix_value;
   int fwhm_compute;
   double epsilon;
   double delta;
   double threshold;
   double trans_x;
   double trans_y;
   double constant;
   double normgain_value;
   double normoffset_value;
   double coef_unsmearing;
   double coef_smile2;
   double coef_smile4;
   int back_kernel;
   double back_threshold;
   int sub_yesno;
   int div_yesno;
   int invert_flip;
   int invert_mirror;
   int invert_xy;
   int x1;
   int y1;
   int x2;
   int y2;
   int width;
   int height;
   int length;
   int oversampling;
   double percent;
   double fwhmsat;
   int simulimage;
   char colfilter[20];
   double fwhmx;
   double fwhmy;
   double quantum_efficiency;
   double sky_brightness;
   double gain;  
   double teldiam;
   double readout_noise;
   double tatm;
   double topt;
   double elecmult;
   int shutter_mode;
   int flat_type;
   double bias_level;
   double thermic_response;
   int newstar;
   double ra;
   double dec;
   double mag;
   double kernel_coef;
   int type_threshold;
   int kernel_width;
   int kernel_type;
   int *hotPixelList;
   TT_PTYPE cosmicThreshold;
   TT_USER1_IMA_SERIES user1;
   TT_USER2_IMA_SERIES user2;
   TT_USER3_IMA_SERIES user3;
   TT_USER4_IMA_SERIES user4;
   TT_USER5_IMA_SERIES user5;
} TT_IMA_SERIES_OPTION;

//***************************************************************************
//  TT_IMA_STACK_OPTION
//***************************************************************************
typedef struct {
   int bitpix;
   int nullpix_exist;
   double nullpix_value;
   double percent;
   int jpegfile_make;
   char jpegfile[FLEN_FILENAME];
   int jpeg_qualite;
   double kappa;
   double drop_pixsize;
   double oversampling;
   int powernorm;
   int *hotPixelList;
   TT_PTYPE cosmicThreshold;
   double xcenter;
   double ycenter;
   double radius;
   TT_USER1_IMA_STACK user1;
   TT_USER2_IMA_STACK user2;
   TT_USER3_IMA_STACK user3;
   TT_USER4_IMA_STACK user4;
   TT_USER5_IMA_STACK user5;
} TT_IMA_STACK_OPTION;

/***************************************************************************/
/* Ce programme permet l'acces aux fonctions de la bibliotheque de         */
/* traitement de donnees (images et autres) pour l'astronomie.             */
/***************************************************************************/
/* Ce programme peut etre compile selon diverses possibilites :            */
/***************************************************************************/
/* Il n'y a qu'un seul point d'entree pour acceder a l'ensemble des        */
/* fonctions. De cette facon, le programme appelant n'a besoin de definir  */
/* Uniquement que la fonction d'entree definie comme suit :                */
/*                                                                         */
/* int libtt_main(int service, ...)                                        */
/*                                                                         */
/* En entree :                                                             */
/*  service : est un nombre entier qui designe la fonction                 */
/* En entree/sortie                                                        */
/*  ... : une suite de parametres d'entree ou de sortie suivant le cas     */
/* En sortie :                                                             */
/*  int : retourne un code d'erreur ou zero si tout c'est bien passe       */
/***************************************************************************/

// note : extern "C" directive is not required in libtt_main declaration 
//        because libtt_main is defined in .c source file (not in .cpp source file).
//        But extern "C" directive is required when this header file is include in
//        C++ user project

#ifdef __cplusplus
extern "C" {  // only need to import C interface if used by C++ source code
#endif

LIBTT_API int libtt_main(int service, ...);

LIBTT_API int abtt_imageSeries (
                    char * load_path, 
                    char*  load_file_name, 
                    int    load_indice_deb,
                    int    load_indice_fin,
                    int    load_level_index,
                    char*  load_extension,
                    char*  save_path,
                    char*  save_file_name, 
                    int    save_indice_deb, 
                    int    save_level_index,
                    char*  save_extension,
                    char*  fonction,
                    TT_IMA_SERIES_OPTION* options
                   );

LIBTT_API int abtt_imageSeriesInitOption (TT_IMA_SERIES_OPTION* options);

LIBTT_API int abtt_imageStack (
                    char * load_path, 
                    char*  load_file_name, 
                    int    load_indice_deb,
                    int    load_indice_fin,
                    int    load_level_index,
                    char*  load_extension,
                    char*  save_path,
                    char*  save_file_name, 
                    int    save_indice_deb, 
                    int    save_level_index,
                    char*  save_extension,
                    char*  fonction,
                    TT_IMA_STACK_OPTION* options
                   );

LIBTT_API int abtt_imageStackInitOption (TT_IMA_STACK_OPTION* options);

#ifdef __cplusplus
}
#endif


