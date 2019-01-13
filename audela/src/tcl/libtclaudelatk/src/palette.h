#ifndef __PALETTEH__
#define __PALETTEH__

typedef unsigned char Pal_Element;
typedef unsigned char Lut_Element;

enum Pal_Type { Pal_None, Pal_Grey, Pal_Red1, Pal_Red2, Pal_Green1, Pal_Green2, Pal_Blue1, Pal_Blue2, Pal_File };
enum Lut_Type { Lut_None, Lut_Lin, Lut_Log };
typedef float Lut_Cut;                           // Type des seuils de visu.

//------------------------------------------------------------------------------
// Structure representant une palette.
// pal : tableau des trois composantes.
//   pal[0] : rouge,
//   pal[1] : vert,
//   pal[2] : bleu.
//
typedef struct {
   Pal_Element *pal[3];
   Pal_Type typ;
   char *filename;
} Pal_Struct;

typedef struct {
   Lut_Element *lut;
   Lut_Type typ;
   Lut_Cut  locut;
   Lut_Cut  hicut;
} Lut_Struct;



#endif


