/*******************************************************************************
**  fly:  On-the-fly image creation utility
**  Martin Gleeson, martin@gleeson.com
**  Copyright (c), Martin Gleeson and The University of Melbourne, 1994-2001
**  Created: 9 December 1994
**  Last Update: 28th February 2001
**
**  Uses the gd library by Thomas Boutell, boutell@boutell.com
**  gd: Copyright 1994-1999, Quest Protein Database Centre,
**     Cold Spring Harbour Labs
**
**  Contributions from:
**  Philip Warner
**     patches to gd to retain support for GIF images
**  Claus Hofmann <claush@ipfr.bau-verm.uni-karlsruhe.de>
**     addition of 'transparent' directive.
**     addtion of code to check if colour already allocated
**     addition of feature to copy whole image if all coords are -1
**  John Bowe <bowe@osf.org>
**     addition of better argument parsing
**  Ian Reid <ian@robots.ox.ac.uk>
**     addition of reading existing image file from external program output
**     fix for line number calculations
**  Shoji Mori <mori@moriken.com>
**     fix for win32 binmode weirdness
**  Anatoly A. Orehovsky <tolik@mpeks.tomsk.su>
**     fix for garbage input files
**
*******************************************************************************/

/******************************************************************************
**  Defines
******************************************************************************/

/* Uncomment the following line if your operating system doesn't support fork */
/* #define NO_FORK 1 */

#define NAMESIZE 1256

/******************************************************************************
**  Included Header Files
******************************************************************************/

#include "gd.h"
#include "gdfonts.h"
#include "gdfontl.h"
#include "gdfontmb.h"
#include "gdfontt.h"
#include "gdfontg.h"
#include "fly.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

#ifdef WIN32
#include <fcntl.h>
#include <io.h>
#endif

/******************************************************************************
**  Strings for usage and quick reference
******************************************************************************/

char *version = "2.0.0";
char *usage = "Usage : fly [-h] [-q] [-i inputfile] [-o outputfile]";

char *help = "See <URL:http://martin.gleeson.com/fly/> for documentation.\n\
\n\
Quick Reference to Directives: \n\
\n\
new\n\
size x,y\n\
name filename\n\
\n\
line    x1,y1,x2,y2,R,G,B             dline        x1,y1,x2,y2,R,G,B \n\
rect    x1,y1,x2,y2,R,G,B             frect        x1,y1,x2,y2,R,G,B \n\
square  x,y,s,R,G,B                   fsquare      x,y,s,R,G,B \n\
poly    R,G,B,x1,y1...,xn,yn          fpoly        R,G,B,x1,y1...,xn,yn \n\
fill    x,y,R,G,B                     filltoborder x,y,R1,G1,B1,R2,B2,G2 \n\
arc     x1,y1,w,h,start,finish,R,G,B  \n\
ellipse x1,y1,w,h,R,G,B  \n\
circle  x,y,d,R,G,B                   fcircle      x,y,d,R,G,B \n\
\n\
string   R,G,B,x,y,<size>,<string> \n\
stringup R,G,B,x,y,<size>,<string> \n\
(size = tiny, small, medium, large or giant) \n\
\n\
copy         x,y,x1,y1,x2,y2,filename \n\
copyresized  x1,y1,x2,y2,dx1,dy1,dx2,dy2,filename \n\
\n\
setpixel     x,y,R,G,B \n\
getpixel     x,y \n\
colourchange R1,G1,B1,R2,G2,B2 \n\
transparent  R,G,B \n\
interlace \n\
\n\
setbrush    filename                         killbrush \n\
settile     filename                         killtile \n\
setstyle    R1,G1,B1,R2,G2,B2,...,Rn,Bn,Gn       killstyle \n\n\
sizex \n\
sizey \n\
rotate      deg \n\
\n\
type        gif|png|jpeg\n\
quality     n (image quality when type = jpeg. Must be in the range 0-95)\n\
\n\
end\n";

/******************************************************************************
**  Internal Functions
******************************************************************************/

int         process_args(int argc, char *argv[]);
int         get_token(FILE *infile);
int         get_number(FILE *infile);
char        *get_string(FILE *infile);
void        sync_input(FILE *infile);
int         get_colour(FILE *infile, gdImagePtr img);
void        copy_to_img(FILE *infile, gdImagePtr img, int resize);
gdImagePtr  get_image(int type, int argc, char *argv[]);
void       *my_newmem(size_t size);
FILE       *get_file(int *line_number, char **filename);
void        swap(int *a, int *b);

/******************************************************************************
**  Global Variables 
******************************************************************************/

int   finished = FALSE,
          done = FALSE,
         quiet = FALSE,
   end_of_line = FALSE,
   written_out = FALSE,
          type = 0,
       imgtype = PNG,
   line_number = 1;

char     *input_file = NULL,
         *output_file = NULL;

FILE	 *outfile;
FILE	 *infile;
FILE	 *brushfile;
FILE	 *tilefile;
FILE     *verbose_out;

/******************************************************************************
** Main Program
******************************************************************************/

int main(int argc, char *argv[]){
	int colour = 0, colour1 = 0, colour2 = 0, type;
	int status, size, side, jp_quality = 75;
	int brush_on = 0, tile_on = 0, style_on = 0;
	int num_entries, up = 0;
	int i, n, c, x, y;
	int size_x, size_y;
	int arg[4096], style[1024];
	char *s;
	gdPoint points[2048];
	gdImagePtr img = NULL, brush = NULL, tile = NULL, new_img = NULL;
	gdFontPtr gdFont = gdFontSmall; /* just a default font */

	status = process_args(argc, argv);
	if (status == FALSE) exit(1);

START:	type = get_token(infile);
	while(((type == COMMENT) || (type == EMPTY) || (type == (int)NULL))) {
		sync_input(infile);
		type = get_token(infile);
		if(finished == TRUE) goto FINISH;
	}
	if(finished == TRUE) goto FINISH;
	if( type != NEW	 && type != EXISTING) {
		fprintf(stderr,"Error: Must use 'new' or 'existing' directive first in input.\n");
		exit(1);
	}
	img=get_image(type, argc, argv);

	/* while more lines to process */
	do{
		type = get_token(infile);
		switch(type){

		case LINE:      /*      gdImageLine()           */
			for(i=1;i<=4;i++) {
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out,"## Line ## drawn from %d,%d to %d,%d. (",
			    arg[1],arg[2],arg[3],arg[4]);
			if( brush_on ) {
				sync_input(infile);
				gdImageLine(img,arg[1],arg[2],arg[3],arg[4],gdBrushed);
				if (!quiet) fprintf(verbose_out,"colour = current brush");
			} else if ( style_on ) {
				sync_input(infile);
				gdImageLine(img,arg[1],arg[2],arg[3],arg[4],gdStyled);
				if (!quiet) fprintf(verbose_out,"colour = current style");
			} else {
				colour=get_colour(infile,img);
				gdImageLine(img,arg[1],arg[2],arg[3],arg[4],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;


		case DLINE:     /*      gdImageDashedLine()     */
			for(i=1;i<=4;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet)
				fprintf(verbose_out,"## Dashed Line ## drawn from %d,%d to %d,%d. (",
			    arg[1],arg[2],arg[3],arg[4]);
			if( brush_on ){
				sync_input(infile);
				gdImageDashedLine(img,arg[1],arg[2],arg[3],arg[4],gdBrushed);
				if (!quiet) fprintf(verbose_out,"colour = current brush");
			} else if ( style_on ) {
				sync_input(infile);
				gdImageDashedLine(img,arg[1],arg[2],arg[3],arg[4],gdStyled);
				if (!quiet) fprintf(verbose_out,"colour = current style");
			} else{
				colour=get_colour(infile,img);
				gdImageDashedLine(img,arg[1],arg[2],arg[3],arg[4],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case SQUARE:      /*      gdImageRectangle()      */
			for(i=1;i<=3;i++){
				arg[i]=get_number(infile);
			}
			side = arg[3];
			arg[3] = arg[1] + side; arg[4] = arg[2] + side;
			if (!quiet) fprintf(verbose_out,"## Square ## drawn at %d,%d, side %d (",
			    arg[1],arg[2],side);
			if( brush_on ){
				sync_input(infile);
				gdImageRectangle(img,arg[1],arg[2],arg[3],arg[4],gdBrushed);
				if (!quiet) fprintf(verbose_out,"colour = current brush");
			} else if ( style_on ) {
				sync_input(infile);
				gdImageRectangle(img,arg[1],arg[2],arg[3],arg[4],gdStyled);
				if (!quiet) fprintf(verbose_out,"colour = current style");
			} else{
				colour=get_colour(infile,img);
				gdImageRectangle(img,arg[1],arg[2],arg[3],arg[4],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case FSQUARE:     /*      gdImageFilledRectangle() */
			for(i=1;i<=3;i++){
				arg[i]=get_number(infile);
			}
			side = arg[3];
			arg[3] = arg[1] + side; arg[4] = arg[2] + side;
			if (!quiet)
				fprintf(verbose_out,"## Filled Square ## drawn from %d,%d, side %d. (",
			    arg[1],arg[2],side);
			if( tile_on ){
				sync_input(infile);
				gdImageFilledRectangle(img,arg[1],arg[2],arg[3],arg[4],gdTiled);
				if (!quiet) fprintf(verbose_out,"colour = current tile");
			} else{
				colour=get_colour(infile,img);
				gdImageFilledRectangle(img,arg[1],arg[2],arg[3],arg[4],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case RECT:      /*      gdImageRectangle()      */
			for(i=1;i<=4;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out,"## Rectangle ## drawn from %d,%d to %d,%d. (",
			    arg[1],arg[2],arg[3],arg[4]);

			/* Check location of vertices given and swap if necessary */
			if((arg[1] > arg[3]) && (arg[4] > arg[2])) {
				swap(&arg[1],&arg[3]);
			} else if((arg[1] > arg[3]) && (arg[2] > arg[4])) {
				swap(&arg[1],&arg[3]);
				swap(&arg[2],&arg[4]);
			} else if((arg[3] > arg[1]) && (arg[2] > arg[4])) {
				swap(&arg[2],&arg[4]);
			}

			if( brush_on ){
				sync_input(infile);
				gdImageRectangle(img,arg[1],arg[2],arg[3],arg[4],gdBrushed);
				if (!quiet) fprintf(verbose_out,"colour = current brush");
			} else if ( style_on ) {
				sync_input(infile);
				gdImageRectangle(img,arg[1],arg[2],arg[3],arg[4],gdStyled);
				if (!quiet) fprintf(verbose_out,"colour = current style");
			} else{
				colour=get_colour(infile,img);
				gdImageRectangle(img,arg[1],arg[2],arg[3],arg[4],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case FRECT:     /*      gdImageFilledRectangle() */
			for(i=1;i<=4;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out,"## Filled Rectangle ## drawn from %d,%d to %d,%d. (",
			    arg[1],arg[2],arg[3],arg[4]);

			/* Check location of vertices given and swap if necessary */
			if((arg[1] > arg[3]) && (arg[4] > arg[2])) {
				swap(&arg[1],&arg[3]);
			} else if((arg[1] > arg[3]) && (arg[2] > arg[4])) {
				swap(&arg[1],&arg[3]);
				swap(&arg[2],&arg[4]);
			} else if((arg[3] > arg[1]) && (arg[2] > arg[4])) {
				swap(&arg[2],&arg[4]);
			}

			if( tile_on ){
				sync_input(infile);
				gdImageFilledRectangle(img,arg[1],arg[2],arg[3],arg[4],gdTiled);
				if (!quiet) fprintf(verbose_out,"colour = current tile");
			} else{
				colour=get_colour(infile,img);
				gdImageFilledRectangle(img,arg[1],arg[2],arg[3],arg[4],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case POLY:      /* gdImagePolygon() */
			done = FALSE; i=0;

			if (!quiet) fprintf(verbose_out,"## Polygon ## (");
			colour=get_colour(infile,img);
			if (!quiet) fprintf(verbose_out,") ");

			arg[i++] = get_number(infile); /* get first point */
			arg[i++] = get_number(infile);

			while( ! done ){     /* get next point until EOL*/
				for(c=0; c<=1 ;c++){
					arg[i++]=get_number(infile);
				}
				if (!quiet) fprintf(verbose_out,"%d,%d to %d,%d; ",
					arg[i-4],arg[i-3],arg[i-2],arg[i -1]);
			}

			num_entries = i / 2;  i=0;
			for(n=0; n<num_entries; n++)
			{
				points[n].x = arg[i++];
				points[n].y = arg[i++];
			}
			if( brush_on ) {
				gdImagePolygon(img, points, num_entries, gdBrushed);
			} else if ( style_on ) {
				gdImagePolygon(img, points, num_entries, gdStyled);
			} else {
				gdImagePolygon(img, points, num_entries, colour);
			}

			done = FALSE;
			if (!quiet) fprintf(verbose_out,"\n");
			break;

		case FPOLY:      /* gdImageFilledPolygon() */
			done = FALSE; i=0;

			if (!quiet) fprintf(verbose_out,"## Filled Polygon ## (");
			colour=get_colour(infile,img);
			if (!quiet) fprintf(verbose_out,") ");

			arg[i++] = get_number(infile); /* get first point */
			arg[i++] = get_number(infile);

			while( ! done ){     /* get next point until EOL*/
				for(c=0; c<=1 ;c++){
					arg[i++]=get_number(infile);
				}
				if (!quiet) fprintf(verbose_out,"%d,%d to %d,%d; ",
					arg[i-4],arg[i-3],arg[i-2],arg[i -1]);
			}

			num_entries = i / 2;  i=0;
			for(n=0; n<num_entries; n++)
			{
				points[n].x = arg[i++];
				points[n].y = arg[i++];
			}

			if( tile_on )
			{
				gdImageFilledPolygon(img, points, num_entries, gdTiled);
			}
			else
			{
				gdImageFilledPolygon(img, points, num_entries, colour);
			}
			done = FALSE;
			if (!quiet) fprintf(verbose_out,"\n");
			break;

		case ARC:       /*      gdImageArc()            */
			for(i=1;i<7;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) {
				fprintf(verbose_out,"## Arc ## Centred at %d,%d, width %d, height %d,\n",
				    arg[1],arg[2],arg[3],arg[4]);
				fprintf(verbose_out,"          starting at %d deg, ending at %d deg. (",
				    arg[5],arg[6]);
			}
			if( brush_on ){
			sync_input(infile);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[4],arg[5],arg[6],gdBrushed);
			if(!quiet) fprintf(verbose_out,"colour = current brush");
			} else if ( style_on ) {
			sync_input(infile);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[4],arg[5],arg[6],gdStyled);
			if(!quiet) fprintf(verbose_out,"colour = current style");
			} else{
			colour=get_colour(infile,img);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[4],arg[5],arg[6],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case ELLIPSE:       /*      gdImageArc()            */
			for(i=1;i<5;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) {
				fprintf(verbose_out,"## Ellipse ## Centred at %d,%d, width %d, height %d. (",
				    arg[1],arg[2],arg[3],arg[4]);
			}
			if( brush_on ){
			sync_input(infile);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[4],0,360,gdBrushed);
			if(!quiet) fprintf(verbose_out,"colour = current brush");
			} else if ( style_on ) {
			sync_input(infile);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[4],0,360,gdStyled);
			if(!quiet) fprintf(verbose_out,"colour = current style");
			} else{
			colour=get_colour(infile,img);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[4],0,360,colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case CIRCLE:
		case FCIRCLE:
			for(i=1;i<4;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) {
				if (type == CIRCLE) {
					fprintf(verbose_out,"## Circle ## Centred at %d,%d, diameter %d (",
						arg[1],arg[2],arg[3]);
				}
				else {
					fprintf(verbose_out,"## Filled Circle ## Centred at %d,%d, diameter %d (",
						arg[1],arg[2],arg[3]);
				}
			}
			if( brush_on ){
			sync_input(infile);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[3],0,360,gdBrushed);
			if(!quiet) fprintf(verbose_out,"colour = current brush");
			} else if ( style_on ) {
			sync_input(infile);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[3],0,360,gdStyled);
			if(!quiet) fprintf(verbose_out,"colour = current style");
			} else{
			colour=get_colour(infile,img);
			gdImageArc(img,arg[1],arg[2],arg[3],arg[3],0,360,colour);
			}
			if (type == FCIRCLE) gdImageFillToBorder(img,arg[1],arg[2],colour,colour);
			if (!quiet) fprintf(verbose_out,")\n");
			break;


		case SETPIXEL:      /*	gdImageSetPixel  */
			for(i=1;i<=2;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out,"## Set Pixel ## at %d,%d to ",arg[1],arg[2]);
			colour=get_colour(infile,img);
			gdImageSetPixel(img,arg[1],arg[2],colour);
			if (!quiet) fprintf(verbose_out,".\n");
			break;

		case GETPIXEL:      /*	gdImageGetPixel  */
			for(i=1;i<=2;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out,"## Get Pixel ## at %d,%d:",arg[1],arg[2]);
			colour = gdImageGetPixel(img,arg[1],arg[2]);
			arg[3] = gdImageRed(img,colour);
			arg[4] = gdImageGreen(img,colour);
			arg[5] = gdImageBlue(img,colour);
			if (!quiet) fprintf(verbose_out," %d, %d, %d = %d.\n",
				arg[3],arg[4],arg[5],colour);
			break;

		case COLOURCHANGE:
			for(i=1;i<=6;i++){
				arg[i]=get_number(infile);
			}
			/* colour is new colour */
			colour = gdImageColorExact(img,arg[4],arg[5],arg[6]);
			if (colour == -1) {
				colour = gdImageColorAllocate(img,arg[4],arg[5],arg[6]);
			}
			/* colour1 is old colour */
			colour1 = gdImageColorExact(img,arg[1],arg[2],arg[3]);
			if (colour1 == -1) {
				colour1 = gdImageColorAllocate(img,arg[1],arg[2],arg[3]);
			}
			size_x = gdImageSX(img);
			size_y = gdImageSY(img);
			for(x=0; x < size_x; x++) {
				for(y=0; y < size_y; y++) {
					colour2 = gdImageGetPixel(img,x,y);
					if(colour2 == colour1) {
						gdImageSetPixel(img,x,y,colour);
					}
				}
			}
			if (!quiet) fprintf(verbose_out,"## Colour Change ## %d,%d,%d (%d) changed to %d,%d,%d (%d).\n",
				arg[1],arg[2],arg[3],colour1,arg[4],arg[5],arg[6],colour);

			break;
		case ROTATE:
			i=get_number(infile);
			if(! ((i == 90) || (i == 180) || (i == 270))) {
				fprintf(verbose_out,"Error: line %d. Rotation must be 90, 180 or 270.\n", line_number);
				break;
			}
			if (!quiet) fprintf(verbose_out,"## Rotate ## by %d degrees.\n",i);
			size_x = gdImageSX(img);
			size_y = gdImageSY(img);
			switch(i) {
				case 180:
					new_img = gdImageCreate(size_x,size_y);
					break;
				case 90:
				case 270:
					new_img = gdImageCreate(size_y,size_x);
					break;
			}
			for(x=0; x < size_x; x++) {
				for(y=0; y < size_y; y++) {
					int r, g, b;
					colour = gdImageGetPixel(img,x,y);
					r = gdImageRed(img,colour);
					g = gdImageGreen(img,colour);
					b = gdImageBlue(img,colour);
					colour1 = gdImageColorExact(new_img,r,g,b);
					if (colour1 == -1) { colour1 = gdImageColorAllocate(new_img,r,g,b); }
					switch(i) {
						case 90:
							gdImageSetPixel(new_img,(size_y - y - 1),x,colour1);
							break;
						case 180:
							gdImageSetPixel(new_img,(size_x - x - 1),(size_y - y - 1),colour1);
							break;
						case 270:
							gdImageSetPixel(new_img,y,(size_x - x - 1),colour1);
							break;
					}
				}
			}
			gdImageDestroy(img);
			img = new_img;
			break;

		case FILL:      /*      gdImageFill() */
			for(i=1;i<=2;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out,"## Fill ## from %d,%d. (", arg[1],arg[2]);
			if( tile_on ){
				sync_input(infile);
				gdImageFill(img,arg[1],arg[2],gdTiled);
			} else {
				colour=get_colour(infile,img);
				gdImageFill(img,arg[1],arg[2],colour);
			}
			if (!quiet) fprintf(verbose_out,")\n");
			break;

		case FILLTOBORDER:      /*	gdImageFillToBorder()	*/
			for(i=1;i<=2;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out,"## Fill ## from %d,%d. (", arg[1],arg[2]);
			colour=get_colour(infile,img);
			if (!quiet) fprintf(verbose_out,") to Border of ");
			if( tile_on ){
				if (!quiet)
					fprintf(verbose_out,"Line %d skipped: Cannot use tile with filltoborder.\n",line_number);
				sync_input(infile);
			} else {
				colour2=get_colour(infile,img);
				gdImageFillToBorder(img,arg[1],arg[2],colour,colour2);
			}
			if (!quiet) fprintf(verbose_out,".\n");
			break;

		case STRINGUP:
			up = TRUE;
		case STRING:
			if (!quiet && up) fprintf(verbose_out,"## String (Up) ## (");
			if (!quiet && !up) fprintf(verbose_out,"## String ## (");
			colour=get_colour(infile,img);
			if (!quiet) fprintf(verbose_out,") at location ");
			for(i=1;i<=2;i++){
				arg[i]=get_number(infile);
			}
			if (!quiet) fprintf(verbose_out," %d,%d, ",arg[1],arg[2]);
			i = get_token(infile);
			s = get_string(infile);
			switch(i) {
				case TINY:
					gdFont = gdFontTiny;
					if (!quiet) fprintf(verbose_out,"[size: tiny] contents: %s\n",s);
					break;
				case SMALL:
					gdFont = gdFontSmall;
					if (!quiet) fprintf(verbose_out,"[size: small] contents: %s\n",s);
					break;
				case MEDIUM:
					gdFont = gdFontMediumBold;
					if (!quiet) fprintf(verbose_out,"[size: medium-bold] contents: %s\n",s);
					break;
				case LARGE:
					gdFont = gdFontLarge;
					if (!quiet) fprintf(verbose_out,"[size: large] contents: %s\n",s);
					break;
				case GIANT:
					gdFont = gdFontGiant;
					if (!quiet) fprintf(verbose_out,"[size: giant] contents: %s\n",s);
					break;
				default:
					if (!quiet) fprintf(verbose_out,"Error: line %d. Incorrect font size specifier.\n",
						line_number);
					break;
			}
			if( !up ) {
				gdImageString(img, gdFont, arg[1],arg[2], (unsigned char *) s, colour);
			} else {
				gdImageStringUp(img, gdFont, arg[1],arg[2], (unsigned char *) s, colour);
			}
			up = FALSE;
			break;

		case SETBRUSH:
			s = get_string(infile);
			if ( (brushfile = fopen(s,"rb")) == NULL )
			{
				fprintf(stderr, "Failed to open brush file, %s\n",
					output_file);
				exit(1);
			}
			else
			{
				brush = gdImageCreateFromPng(brushfile);
				gdImageSetBrush(img,brush);
				brush_on = 1;
				if (!quiet) fprintf(verbose_out,"## Brush Set ## to: %s\n",s);
			}
			break;

		case KILLBRUSH:
			brush_on = 0;
			if (!quiet) fprintf(verbose_out,"## Brush Killed ##\n");
			break;

		case SETSTYLE:
			i=0;
			end_of_line = FALSE;
			if (!quiet) fprintf(verbose_out,"## Style Set ## Colours: (");
			while( ! end_of_line ){
				colour=get_colour(infile,img);
				if (!quiet && !end_of_line) fprintf(verbose_out,"), (");
				style[i++] = colour;
			}
			if (!quiet) fprintf(verbose_out,")\n");
			gdImageSetStyle(img, style, i-1);
			style_on = TRUE;
			end_of_line = FALSE;
			break;

		case KILLSTYLE:
			style_on = 0;
			if (!quiet) fprintf(verbose_out,"## Style Killed ##\n");
			break;

		case SETTILE:
			s = get_string(infile);
			if ( (tilefile = fopen(s,"rb")) == NULL )
			{
				fprintf(stderr, "Failed to open tile file, %s\n",
					output_file);
				exit(1);
			}
			else
			{
				tile = gdImageCreateFromPng(tilefile);
				gdImageSetTile(img,tile);
				tile_on = TRUE;
				if (!quiet) fprintf(verbose_out,"## Tile Set ## to: %s\n",s);
			}
			break;

		case KILLTILE:
			tile_on = 0;
			if (!quiet) fprintf(verbose_out,"## Tile Killed ##\n");
			break;

		case COPY:
			copy_to_img(infile, img, 0);
			break;

		case COPYRESIZED:
			copy_to_img(infile, img, 1);
			break;

		case TRANSPARENT:
			if (!quiet) fprintf(verbose_out,"## Make transparent ## [");
			colour=get_colour(infile,img);
			gdImageColorTransparent(img,colour);
			if (!quiet) fprintf(verbose_out,"]\n");
			break;

		case INTERLACE:
			gdImageInterlace(img,1);
			if (!quiet) fprintf(verbose_out,"## Image is interlaced ##\n");
			break;

		case SIZEX:
			size = gdImageSX(img);
			if (!quiet) fprintf(verbose_out,"## Size - X ## is %d\n",size);
			break;

		case SIZEY:
			size = gdImageSY(img);
			if (!quiet) fprintf(verbose_out,"## Size - Y ## is %d\n",size);
			break;

		case NAME:
			s = get_string(infile);
			if ( (outfile = fopen(s,"wb")) == NULL )
			{
				fprintf(stderr, "Failed to open output file, %s\n",
					output_file);
				exit(1);
			}
			else
			{
				if (!quiet) fprintf(verbose_out,"## Output to file %s ##\n",s);
			}
			break;

		case TYPE: 
			imgtype = get_token(infile);
			if(imgtype != JPEG && imgtype != PNG && imgtype != GIF){
				fprintf(verbose_out,"Error: line %d: Image type must be jpeg, gif or png.\n",line_number);
				exit(1);
			}
			break;

		case QUALITY:
			i=get_number(infile);
			jp_quality = i;
			if(imgtype != JPEG){
				fprintf(verbose_out,"Error: line %d: Cannot use quality directive unless type is set to jpeg first.\n",line_number);
				exit(1);
			}
			if(i < 0 || i > 95){
				fprintf(verbose_out,"Line %d skipped: Image quality must be within the range 0-95. %d is not an acceptable value.\n",line_number, i);
				exit(1);
			}
			
			break;

		case COMMENT:
			sync_input(infile);
			break;

		case EMPTY:
			break;

		case END:
			gdImagePng(img,outfile);
			fclose(outfile);
			gdImageDestroy(img);
			written_out = TRUE;
			if (!quiet) fprintf(verbose_out,"End of image directives.\n");
			if(!finished) { goto START; } else { goto FINISH; }
			
		default:
			if( ! finished ) {
				if (!quiet) fprintf(verbose_out,
					"Line %d skipped: bad directive or syntax error.\n",line_number);
			} else {
				if (!quiet) fprintf(verbose_out,"EOF: fly finished.\n");
			}
			sync_input(infile);
			break;
		}
	}	while( ! finished );

	/*  Write the gd to the image output file and exit */
FINISH:	if(!written_out && img) {
		if(imgtype == JPEG) {
			gdImageJpeg(img,outfile,jp_quality);
		} else if(imgtype == GIF) {
			gdImageGif(img,outfile);
		} else {
			gdImagePng(img,outfile);
		}
		fclose(outfile);
		gdImageDestroy(img);
	}
	exit(0);
}

/******************************************************************************
**
**  get_string
**
**  returns a string from the current input line: from the current point
**  to the end of line.
**
**  Used by:
**  string,stringup,chr,chrup,setbrush,settile
**
******************************************************************************/
char *get_string(FILE *infile){
	int     c,i=0;
	char    temp[1024], *string, *p;

	while(( (c=getc(infile)) != EOF ) && ( c != '\n') ){
		temp[i++]=c;
	}

	if( c == '\n' ) { line_number++; }
	if( c == EOF ) {
		finished = TRUE;
	}
	temp[i]='\0';
	p=temp;
	string=(char *)my_newmem(strlen(p));
	sprintf(string,"%s",temp);

	return string;
}

/******************************************************************************
**
**  get_token
**
**  Gets the next "token" from the input line.
**
**  Used by:
**  all
**
******************************************************************************/
int get_token(FILE *infile){
	int     c,i=0;
	char    temp[80], *input_type, *p;
	char    *line="line",
		*poly="poly",
		*fpoly="fpoly",
		*rect="rect",
		*frect="frect",
		*square="square",
		*fsquare="fsquare",
		*dline="dline",
		*arc="arc",
		*size="size",
		*new="new",
		*existing="existing",
		*setpixel="setpixel",
		*getpixel="getpixel",
		*filltoborder="filltoborder",
		*fill="fill",
		*string="string",
		*stringup="stringup",
		*copy="copy",
		*copyresized="copyresized",
		*transparent="transparent",
		*interlace="interlace",
		*sizex="sizex",
		*sizey="sizey",
		*setbrush="setbrush",
		*killbrush="killbrush",
		*settile="settile",
		*killtile="killtile",
		*setstyle="setstyle",
		*killstyle="killstyle",
		*tiny="tiny",
		*small="small",
		*medium="medium",
		*large="large",
		*giant="giant",
		*zero="0",
		*one="1",
		*circle="circle",
		*fcircle="fcircle",
		*comment="#",
		*name="name",
		*end="end",
		*ellipse="ellipse",
		*colourchange="colourchange",
		*rotate="rotate",
		*type="type",
		*quality="quality",
		*gif="gif",
		*png="png",
		*jpeg="jpeg";

	while(((c=getc(infile))!=EOF)&&(c!=' ')&&(c!='\n')&&(c!=',')&&(c!='=')&&(c!='\r'))
	{
		temp[i++]=c;
		if(temp[0] == '#') break;
	}
	if (c == EOF) finished = TRUE;

	if (c == '\n' || c == '\r') {
		line_number++;
		if (i == 0) { return EMPTY; }
	} else if (c == EOF) {
		return (int)NULL;
	}

	temp[i]='\0';
	p=temp;
	input_type=(char*)my_newmem(strlen(p));
	sprintf(input_type,"%s",temp);

	if( strcmp(input_type, line) == 0 ){
		free(input_type);
		return LINE;
	}
	if( strcmp(input_type, rect) == 0 ){
		free(input_type);
		return RECT;
	}
	if( strcmp(input_type, square) == 0 ){
		free(input_type);
		return SQUARE;
	}
	if( strcmp(input_type, fsquare) == 0 ){
		free(input_type);
		return FSQUARE;
	}
	if( strcmp(input_type, dline) == 0 ){
		free(input_type);
		return DLINE;
	}
	if( strcmp(input_type, frect) == 0 ){
		free(input_type);
		return FRECT;
	}
	if( strcmp(input_type, fcircle) == 0 ){
		free(input_type);
		return FCIRCLE;
	}
	if( strcmp(input_type, circle) == 0 ){
		free(input_type);
		return CIRCLE;
	}
	if( strcmp(input_type, arc) == 0 ){
		free(input_type);
		return ARC;
	}
	if( strcmp(input_type, poly) == 0 ){
		free(input_type);
		return POLY;
	}
	if( strcmp(input_type, fpoly) == 0 ){
		free(input_type);
		return FPOLY;
	}
	if( strcmp(input_type, size) == 0 ){
		free(input_type);
		return SIZE;
	}
	if( strcmp(input_type, new) == 0 ){
		free(input_type);
		return NEW;
	}
	if( strcmp(input_type, existing) == 0 ){
		free(input_type);
		return EXISTING;
	}
	if( strcmp(input_type, copyresized) == 0 ){
		free(input_type);
		return COPYRESIZED;
	}
	if( strcmp(input_type, copy) == 0 ){
		free(input_type);
		return COPY;
	}
	if( strcmp(input_type, fill) == 0 ){
		free(input_type);
		return FILL;
	}
	if( strcmp(input_type, filltoborder) == 0 ){
		free(input_type);
		return FILLTOBORDER;
	}
	if( strcmp(input_type, setpixel) == 0 ){
		free(input_type);
		return SETPIXEL;
	}
	if( strcmp(input_type, getpixel) == 0 ){
		free(input_type);
		return GETPIXEL;
	}
	if( strcmp(input_type, string) == 0 ){
		free(input_type);
		return STRING;
	}
	if( strcmp(input_type, stringup) == 0 ){
		free(input_type);
		return STRINGUP;
	}
	if( strcmp(input_type, sizex) == 0 ){
		free(input_type);
		return SIZEX;
	}
	if( strcmp(input_type, sizey) == 0 ){
		free(input_type);
		return SIZEY;
	}
	if( strcmp(input_type, setbrush) == 0 ){
		free(input_type);
		return SETBRUSH;
	}
	if( strcmp(input_type, killbrush) == 0 ){
		free(input_type);
		return KILLBRUSH;
	}
	if( strcmp(input_type, settile) == 0 ){
		free(input_type);
		return SETTILE;
	}
	if( strcmp(input_type, killtile) == 0 ){
		free(input_type);
		return KILLTILE;
	}
	if( strcmp(input_type, setstyle) == 0 ){
		free(input_type);
		return SETSTYLE;
	}
	if( strcmp(input_type, killstyle) == 0 ){
		free(input_type);
		return KILLSTYLE;
	}
	if( strcmp(input_type, interlace) == 0 ){
		free(input_type);
		return INTERLACE;
	}
	if( strcmp(input_type, transparent) == 0 ){
		free(input_type);
		return TRANSPARENT;
	}
	if( strcmp(input_type, tiny) == 0 ){
		free(input_type);
		return TINY;
	}
	if( strcmp(input_type, zero) == 0 ){
		free(input_type);
		return SMALL;
	}
	if( strcmp(input_type, small) == 0 ){
		free(input_type);
		return SMALL;
	}
	if( strcmp(input_type, medium) == 0 ){
		free(input_type);
		return MEDIUM;
	}
	if( strcmp(input_type, one) == 0 ){
		free(input_type);
		return LARGE;
	}
	if( strcmp(input_type, large) == 0 ){
		free(input_type);
		return LARGE;
	}
	if( strcmp(input_type, giant) == 0 ){
		free(input_type);
		return GIANT;
	}
	if( strcmp(input_type, name) == 0){
		free(input_type);
		return NAME;
	}
	if( strcmp(input_type, comment) == 0){
		free(input_type);
		return COMMENT;
	}
	if( strcmp(input_type, end) == 0){
		free(input_type);
		return END;
	}
	if( strcmp(input_type, ellipse) == 0){
		free(input_type);
		return ELLIPSE;
	}
	if( strcmp(input_type, colourchange) == 0){
		free(input_type);
		return COLOURCHANGE;
	}
	if( strcmp(input_type, rotate) == 0){
		free(input_type);
		return ROTATE;
	}
	if( strcmp(input_type, type) == 0){
		free(input_type);
		return TYPE;
	}
	if( strcmp(input_type, quality) == 0){
		free(input_type);
		return QUALITY;
	}
	if( strcmp(input_type, gif) == 0){
		free(input_type);
		return GIF;
	}
	if( strcmp(input_type, png) == 0){
		free(input_type);
		return PNG;
	}
	if( strcmp(input_type, jpeg) == 0){
		free(input_type);
		return JPEG;
	}
	free(input_type);
	ungetc(c,infile);
	return (int)NULL;
}

/******************************************************************************
**
**  get_number
**
**  grabs a number from the current input line. Reads up to a comma or newline.
**
**  Used by:
**  line, dline, rect, frect, poly, fpoly, arc, setpixel, fill, filltoborder,
**  string, stringup, chr, chrup.
**
******************************************************************************/
int get_number(FILE *infile){
	int     c,i=0;
	char    tmp[80];

	while(( (c=getc(infile)) != EOF ) && ( c != ',') && (c != '\n')){
		tmp[i++]=c;
	}
	if( c == '\n' ) { line_number++; }
	if( c != EOF ) {
		tmp[i]='\0';
		if( c == '\n') {
			done = TRUE;
		}
		return atoi(tmp);
	} else {
		tmp[i]='\0';
		finished = TRUE;
		return atoi(tmp);
	}
}

/******************************************************************************
**
**  get_colour
**
**  Gets a R,G,B colour value from the current input line.
**  Returns the integer colour index.
**
**  Used by:
**  line, dline, rect, frect, poly, fpoly, arc, setpixel, fill, filltoborder,
**  string, stringup, chr, chrup, setstyle, transparent.
**
******************************************************************************/
int get_colour(FILE *infile, gdImagePtr img){
	int     c,i,count,colourIndex, colour[3];
	char    temp[5];

	for(count=0;count<3;count++){
		i=0;
		while(( (c=getc(infile)) != EOF )&&( c !=',')&&(c !='\n')){
			temp[i++]=c;
		}
		if( c == '\n' ) { line_number++; }
		temp[i]='\0';
		if( c == '\n') end_of_line = TRUE;
		if( c == EOF ) finished = TRUE;
		colour[count]=atoi(temp);
	}
	if( (c=getc(infile)) != EOF )  { 
		ungetc(c,infile); 
	} else { 
		finished = TRUE; 
	}
	/* Original comments from Claus Hofmann. I don't have any idea what they
         * mean, but I'll put 'em here anyhow.
	 */
	/* zuerst nachschauen, ob es die gewuenschte Farbe schon in der 
	 * colortable gibt. Erst wenn es die Farbe nicht gibt einen neuen
	 * Index in der Tabelle allocieren.
	 */
	colourIndex=gdImageColorExact(img,colour[0],colour[1],colour[2]);
	if (colourIndex == -1) {
		colourIndex=gdImageColorAllocate(img,colour[0],colour[1],colour[2]);
	}
	if (!quiet)
		fprintf(verbose_out,"colour: %d, %d, %d = %d",
			colour[0],colour[1],colour[2], colourIndex);
	return colourIndex;

}

/******************************************************************************
**
**  copy_to_img
**
**  Copies a img to the current image. Location of img and coordinates are
**  specified on the input line.
**
**  Used by:
**  copy, copyresized.
**
******************************************************************************/
void copy_to_img(FILE *infile, gdImagePtr img, int resize){
	int     i=0,arg[8];
	char    *filename;
	FILE	*img_to_copy;
	gdImagePtr	img_file;

	/*	Get the coordinates	*/
	for(i=0;i<=5;i++){
		arg[i]=get_number(infile);
	}
	if( resize == 1 ){
		arg[i]=get_number(infile);
		i++;
		arg[i]=get_number(infile);
	}
	if((img_to_copy = get_file(&line_number, &filename)) == NULL) {
		fprintf(stderr,"Error: Cannot read existing image file \"%s\"\n",
			filename);
		exit(1);
	}
	if(imgtype == JPEG) {
		img_file = gdImageCreateFromJpeg(img_to_copy);
	} else if(imgtype == GIF) {
		img_file = gdImageCreateFromGif(img_to_copy);
	} else {
		img_file = gdImageCreateFromPng(img_to_copy);
	}
	fclose(img_to_copy);

	if( resize == 1 )
	{
		if((arg[0] == -1)&&(arg[1] == -1) &(arg[2] == -1)&&(arg[3] == -1)){
			if(!quiet) fprintf(verbose_out,"Copying %s (entire area) to area %d,%d - %d,%d.\n",
				filename,arg[4],arg[5],arg[6], arg[7]);
			gdImageCopyResized(img, img_file, arg[4], arg[5], 0, 0,
				(arg[6] - arg[4]), (arg[7] - arg[5]), img_file->sx, img_file->sy);
		}
		else {
			if(!quiet) fprintf(verbose_out,"Copying %s (area %d,%d - %d,%d) to area %d,%d - %d,%d.\n",
				filename,arg[4],arg[5],arg[6], arg[7],arg[0],arg[1],arg[2],arg[3]);
			gdImageCopyResized(img, img_file, arg[4], arg[5], arg[0], arg[1],
				(arg[6] - arg[4] + 1), (arg[7] - arg[5] + 1), (arg[2] - arg[0] + 1),
				(arg[3] - arg[1] + 1));
		}
	}
	else
	{
		if ((arg[2] == -1)&&(arg[3] == -1) &(arg[4] == -1)&&(arg[5] == -1)) {
			/* another comment from Claus Hofmann. I'm getting curious now. */
			/* gesamtes Bild 
			*/
			arg[2] = arg[3] = 0;
			arg[4] = img_file->sx;
			arg[5] = img_file->sy;
		}
		if(!quiet) fprintf(verbose_out,"Copying %s to coordinates %d,%d\n",filename,arg[0],arg[1]);
		gdImageCopy(img, img_file, arg[0], arg[1], arg[2], arg[3],
					arg[4] - arg[2], arg[5] - arg[3]);
	}
	gdImageDestroy(img_file);

	return;
}

/******************************************************************************
**
**  sync_input
**
**  synchronises input line - reads to end of line, leaving file pointer
**  at first character of next line.
**
**  Used by:
**  main program - error handling.
**
******************************************************************************/
void
sync_input(FILE *infile)
{
	int c = 0;

	if( c == '\n' ) return;
	while( ( (c=getc(infile)) != EOF ) && (c != '\n') && (c != '\r')) ;
	if( c == EOF ) finished = TRUE;
	if( c == '\n' || c == '\r') line_number++;
	return;
}

/******************************************************************************
**
**  process_args
**
**  processes the command line arguments
**
**  Used by:
**  main program.
**
******************************************************************************/
int
process_args(int argc, char *argv[])
{
	int c = 0, errflag=0;
	extern char *optarg;
	extern int optind;

	while ((c=getopt(argc, argv, "qhvi:o:")) != EOF) {
		switch (c) {
			case 'q': quiet = TRUE;
			        break;
			case 'v':
			case 'h': fprintf(stdout,"fly, version %s\n\n%s\n", version, help);
			          exit(0);
			        break;
			case 'o': output_file=(char *)my_newmem(strlen(optarg)*sizeof(char));
			          sprintf(output_file,"%s",optarg);
			        break;
			case 'i': input_file=(char *)my_newmem(strlen(optarg)*sizeof(char));
			          sprintf(input_file,"%s",optarg);
			        break;
			case '?': errflag = 1;
			        break;
		}
		if (errflag) {
			fprintf(stderr,"%s\n", usage);
			exit(1);
		}
	}
	if( input_file ) {
		if ( (infile = fopen(input_file,"r")) == NULL ) {
			fprintf(stderr, "Failed to open input file, %s.\n",
				input_file);
			return FALSE;
		}
	} else {
		infile = stdin;
	}
	if( output_file ) {
		if ( (outfile = fopen(output_file,"wb")) == NULL ) {
			fprintf(stderr, "Failed to open output file, %s.\n",
				output_file);
			return FALSE;
		}
		verbose_out = stdout;
	} else {
#ifdef WIN32
		_setmode( _fileno( stdout ), _O_BINARY ) ;
#endif
		outfile = stdout;
		verbose_out = stderr;
	}
	return TRUE;
}

/******************************************************************************
**
**  get_image
**
**  creates a new image or uses an existing one as a template.
**
**  Used by:
**  main program
**
******************************************************************************/
gdImagePtr get_image(int type, int argc, char *argv[]){


	FILE *in;
	int n=0, num[10];
	char *filename;
	gdImagePtr image = NULL;
	int newtype;

	if( type == EXISTING ) {
		/*  fprintf(stderr,"Creating image from existing file:"); */
		if ((in = get_file(&line_number, &filename)) == NULL ) {
			fprintf(stderr,"Error: Cannot read existing image file \"%s\"\n",
				filename);
			exit(1);
		}
		else {
			if(!quiet) fprintf(verbose_out,"Creating image from existing image <%s>\n",
			    filename);
			image = gdImageCreateFromPng(in);
			fclose(in);
		}
	}
	else if( type == NEW ){
		newtype = get_token(infile);
		while( (newtype == COMMENT) || (newtype == EMPTY) || (newtype != SIZE) ) {
			if(newtype != EMPTY) sync_input(infile);
			newtype = get_token(infile);
		}
		if( newtype != SIZE ) {
			if( argc == 2){
				fprintf(stderr,"Error: <stdin> second line ");
				fprintf(stderr,"must have a 'size' command\n");
			}
			else{
				fprintf(stderr,"Error: %s second line must ", argv[1]);
				fprintf(stderr,"have a 'size' command\n");
			}
			exit(1);
		}
		for( n=1; n<=2; n++ ){
			num[n]=get_number(infile);
		}
		if (!quiet)
		{
			if( output_file )
			{
				fprintf(verbose_out,"Creating new %d by %d image, <%s>\n",
					num[1],num[2],output_file);
			}
			else
			{
				fprintf(verbose_out,"Creating new %d by %d image\n",
					num[1],num[2]);
			}
		}
		image = gdImageCreate(num[1],num[2]);
	}
	written_out = FALSE;
	return image;
}

/******************************************************************************
**
**  my_newmem: grab some memory.
**
**  -  Concentrates memory error handling in one place.
**
**
**  Used by:
**  string,stringup,chr,chrup,setbrush,settile
**
******************************************************************************/
void *
my_newmem(size_t size)
{
	void	*p;

	if ((p = malloc(size +1)) == NULL)
	{
		fprintf(stderr, "fly: ran out of memory\n");
		exit(1);
	}

	return p;
}

/******************************************************************************
**
**  get_file
**
**  reads a file name and opens a file corresponding to the
**  name read.  if the name is back-quoted `...` then it is
**  interpreted as a shell command.
**
**  Contributed by Ian Reid <ian@robots.ox.ac.uk>
**
**  Bug fix to type of ch by John Mitchell <johnm@magnet.com>
**
**  Used by:
**  get_image
**  copy_to_img
**
******************************************************************************/

FILE *get_file(int *line_number, char **filename)
{
	FILE *in;
	int ch;
	char fname[NAMESIZE];
	int n=0;

	if ((fname[n++]=getc(infile)) == '`') {
		while (( (ch=getc(infile)) != EOF ) && ( ch != '`' ) && n<NAMESIZE) {
			fname[n++]=ch;
		}
	} else {
		while(( (ch=getc(infile)) != EOF ) && ( ch != ' ') && ( ch != '\n') && n<NAMESIZE){
			fname[n++]=ch;
		}
	}
	if (ch == '\n') { (*line_number)++; }
	if (ch==EOF || n==NAMESIZE) {
		fprintf(stderr, "Error: EOF or out space while reading filename (perhaps missing \"`\"?)\n");
		return NULL;
	}
	fname[n]='\0';
	if (fname[0]=='`') {
#ifndef NO_FORK
		/* open a pipe to get data from a shell command */
		int pid, p[2];

		*filename = (char *) my_newmem( n );
		strncpy(*filename, fname+1, n);

		if (pipe(p) < 0) {
			fprintf(stderr, "Error: pipe creation failed\n");
			return NULL;
		}
		if ((pid=fork()) < 0) {
			fprintf(stderr, "Error: fork failed\n");
			return NULL;
		} else if (pid>0) {
			/* child */
			close(p[0]); close(1); dup(p[1]); close(p[1]);
			exit( system (*filename) );
		}
		/* parent */
		close(p[1]);
		in = fdopen(p[0], "rb");
#else
	fprintf(stderr,"Error: Reading image from external command not supported on this Operating System\n");
	exit(1);
#endif
	} else {
		/* open an ordinary file */
		*filename = (char *) my_newmem( n+1 );
		sprintf(*filename,"%s",fname);
		in = fopen(*filename, "rb");
	}

	return in;
}
/******************************************************************************/
void swap(int *a, int *b) {
	int temp;

	temp = *b;
	*b = *a;
	*a = temp;
}
/******************************************************************************/
