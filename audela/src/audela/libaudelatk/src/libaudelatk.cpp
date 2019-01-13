/* visu_tcl.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#include <stdlib.h>
#include <string.h>
#include <tk.h>
#include "sysexp.h"  // pour LIBRARY_DLL , LIBRARY_SO
#include "cvisu.h"
#include "cvisupool.h"
//#include "cerror.h"


extern "C" int Tkimgvideo_Init(Tcl_Interp *interp);

#define VISU_PREFIXE "visu"

//------------------------------------------------------------------------------
// La variable globale est definie de maniere unique ici.
//
//  pool de visu
CVisuPool *visu_pool;


//------------------------------------------------------------------------------
// fonction pour gerer le pool de visu

int CmdCreateVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdListVisuItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdDeleteVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdLoadImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdFreeImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdSaveImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

//------------------------------------------------------------------------------
// fonction point d'entree pour gerer les commandes d'une visu
//

extern int CmdVisu(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);


#if defined(OS_WIN)
extern "C" int __cdecl Audelatk_Init(Tcl_Interp *interp)
#else
extern "C" int Audelatk_Init(Tcl_Interp *interp)
#endif
{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      return TCL_ERROR;
   }
   if(Tk_InitStubs(interp,(char*)"8.3",0)==NULL) {
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"libaudelatk","1.0");
   visu_pool = new CVisuPool(VISU_PREFIXE);
   Tcl_CreateCommand(interp,"::visu::create",(Tcl_CmdProc *)CmdCreateVisuItem,(void*)visu_pool,NULL);
   Tcl_CreateCommand(interp,"::visu::list",  (Tcl_CmdProc *)CmdListVisuItems,(void*)visu_pool,NULL);
   Tcl_CreateCommand(interp,"::visu::delete",(Tcl_CmdProc *)CmdDeleteVisuItem,(void*)visu_pool,NULL);
   Tcl_CreateCommand(interp,"::visu::loadImage",  (Tcl_CmdProc *)CmdLoadImage,(void*)visu_pool,NULL);
   Tcl_CreateCommand(interp,"::visu::freeImage",  (Tcl_CmdProc *)CmdFreeImage,(void*)visu_pool,NULL);
   Tcl_CreateCommand(interp,"::visu::saveImage",  (Tcl_CmdProc *)CmdSaveImage,(void*)visu_pool,NULL);

#if defined(WIN32)
   // create image type for video (webcam and video recorder)
   Tkimgvideo_Init(interp);
#endif
   return TCL_OK;
}


int CmdListVisuItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   CVisu *visu;
   char *ligne;
   char item[10];

   visu = ((CVisuPool*)clientData)->dev;
   ligne = (char*)calloc(200,sizeof(char));
   strcpy(ligne,"");
   if(argc==1) {
      while(visu) {
         sprintf(item,"%d ",visu->no);
         strcat(ligne,item);
         visu = visu->next;
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      sprintf(ligne,"Usage: %s",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   free(ligne);
   return TCL_OK;
}

int CmdDeleteVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int numero;
   char *ligne;
   CVisuPool *pool;
   CVisu *toto;
   char*classname;
   pool = (CVisuPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(200,sizeof(char));
   if(argc==2) {
      if(Tcl_GetInt(interp,argv[1],&numero)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %snum\n%snum must be an integer",argv[0],classname,classname);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_OK;
      }
      toto = pool->Chercher(numero);
      if(toto) {
         sprintf(ligne,"catch {%s%d close}",classname,numero);
         Tcl_Eval(interp,ligne);
         Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
         pool->RetirerDev(toto);
         sprintf(ligne,"%s%d",classname,numero);
			Tcl_DeleteCommand(interp,ligne);
      } else {
         sprintf(ligne,"%s%d does not exist.",classname,numero);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   } else {
      sprintf(ligne,"Usage: %s %snum",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   free(ligne);
   return TCL_OK;
}


int CmdCreateVisuItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int numero;
   char *ligne;
   CVisuPool *pool;
   CVisu *toto=NULL;
   char *classname;
   int bufno = 1;
   int imgno = 1;
   char s[256];
   int retour;

   pool = (CVisuPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(1000,sizeof(char));
   strcpy(s,"");


   if((argc<3)||(argc>4)) {
      sprintf(ligne,"Usage: %s bufno imgno ?%snum?",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else if(Tcl_GetInt(interp,argv[1],&bufno)!=TCL_OK) {
      sprintf(ligne,"Usage: %s bufno imgno ?%snum?\nbufno must be an integer > 0",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else if(Tcl_GetInt(interp,argv[2],&imgno)!=TCL_OK) {
      sprintf(ligne,"Usage: %s bufno imgno ?%snum?\nimgno must be an integer > 0",argv[0],classname);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else {
      numero = 0;
      if((argc==4)&&(Tcl_GetInt(interp,argv[3],&numero)!=TCL_OK)) {
         sprintf(ligne,"Usage: %s bufno imgno ?%snum?\n%snum must be an integer > 0",argv[0],classname,classname);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_ERROR;
      }
      toto = visu_pool->Ajouter(numero,new CVisu(interp,bufno,imgno));
      if(toto) {
         sprintf(ligne,"%s%d",classname,toto->no);
         Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)(CmdVisu),(ClientData)toto,(Tcl_CmdDeleteProc*)NULL);
      }
   }

   // termine la creation de l'objet.
   if(toto) {
      sprintf(ligne,"%d",toto->no);
      retour = TCL_OK;
   } else {
      sprintf(ligne,"Could not create the %s.\n%s",classname,s);
      retour = TCL_ERROR;
   }
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);

   free(ligne);
   return retour;
}

/**
 *  CmdLoadImage
 *    Charge une image dans une ressource temporaire 
 *    Apres utilisation, la procedure appelante doit supprimer l'image temporaire
 *    avec "::visu::freeImage"  qui utilise CmdFreeImage
 *    
 *  @param arg[1] : nom du fichier de l'image
 *  return : liste de parametres du l'image  
 *    result[0]  width
 *    result[1]  height
 *    result[2]  pixelSize
 *    result[3]  pitch
 *    result[4]  offset[0]
 *    result[5]  offset[1]
 *    result[6]  offset[2]
 *    result[7]  offset[3]
 *    result[8]  pixelPtr  de type long
 *    
 */

int CmdLoadImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[1024];
   int tclResult;

   if(argc!=2) {
      sprintf(ligne,"Usage: %s fileName",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      tclResult = TCL_ERROR;
   } else  {
      Tk_PhotoImageBlock pib;
      Tk_PhotoHandle ph ;

      // j'essaie de charger le package Img pour pouvoir reconnaitre plus de type d'image
      // Si le package n'existe , je continue quand meme en utilisant les types definis par TK
      Tcl_PkgRequire(interp, "Img", "1.3", 0);

      // je cree une image tk temporaire.
      sprintf(ligne,"image create photo temporaryImageVisu -file {%s} ", argv[1]); 
      tclResult = Tcl_Eval(interp,ligne);
      if ( tclResult == TCL_OK) {
         // je recupere le handle de l'image tk
         ph = Tk_FindPhoto(interp,"temporaryImageVisu");
         if(ph!=NULL) {
            // je charge les pixels dans l'image temporaire avec la librairie tkImg 
            tclResult = Tk_PhotoGetImage(ph,&pib);            
            if( pib.pixelPtr != NULL) {
               sprintf(ligne,"%d %d %d %d %d %d %d %d %ld", 
                  pib.width, pib.height, 
                  pib.pixelSize, pib.pitch,
                  pib.offset[0], pib.offset[1],pib.offset[2],pib.offset[3],
                  pib.pixelPtr );
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               tclResult = TCL_OK;
            } else {
               tclResult = TCL_ERROR;
            }
         } else {
            tclResult = TCL_ERROR;
         }
      }     
   }
  return tclResult;
}

/**
 *  CmdFreeImage
 *    supprime l'image cree par la commande CmdLoadImage
 *    
 *  @return TCL_OK ou  TCL_ERROR 
 *    
 */
int CmdFreeImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[1024];
   int tclResult;

   if(argc!=1) {
      sprintf(ligne,"Usage: %s ",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      tclResult = TCL_ERROR;
   } else  {
      // je supprime l'image
      tclResult = Tcl_Eval(interp,"image delete temporaryImageVisu");
   }
  return tclResult;
}


/**
 *  CmdSaveImage
 *    sauvegarde une image dans un fichier
 *    
 *  Si le parametre "format" n'est pas present, la fonction utilise l'extension
 *  du nom du fichier pour determiner le format du fichier. 
 *
 *  @param arg[1] : nom du fichier de l'image
 *  @param arg[2] : pointeur de l'objet CPixels contenant l'image a enregistrer
 *  @param arg[3] : format de l'image bmp|gif|png|tiff (parametre optionel) 
 *  @return TCL_OK ou  TCL_ERROR
 *    
 */
int CmdSaveImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[1024];
   int tclResult = TCL_OK;

   if(argc<6) {
      sprintf(ligne,"Usage: %s fileName pixelPtr width height planes",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      tclResult = TCL_ERROR;
   } 
   
   if (tclResult == TCL_OK) { 
      char fileName [1024];
      char errorMessage [1024];
      char format[10];
      unsigned char * pixelPtr;
      int width;
      int height;
      int planes;
      Tk_PhotoHandle ph ;
      Tk_PhotoImageBlock pib;

      strcpy(fileName,argv[1]);
      width = atoi(argv[3]);
      height= atoi(argv[4]);
      planes= atoi(argv[5]);

      //pixelPtr = (unsigned char *) malloc(width*height*4);
      //memcpy(pixelPtr,(unsigned char *) atol(argv[2]) ,width*height*4);
      pixelPtr = (unsigned char *) atol(argv[2]);
      
      if ( argc >= 7 ) {         
         strcmp(format,argv[3]);
         tclResult = TCL_OK;
      } else {
         sprintf(ligne,"string tolower [file extension {%s}]",fileName);
         tclResult = Tcl_Eval(interp,ligne);
         if (tclResult == TCL_OK) { 

            // j'identifie  le format de l'image ne fonction de l'extension du fichier
            if(strcmp(Tcl_GetStringResult(interp), ".bmp" )==0) {
               strcpy(format, "bmp");
            } else if(strcmp(Tcl_GetStringResult(interp), ".gif" )==0) {
               strcpy(format, "gif");
            } else if(strcmp(Tcl_GetStringResult(interp), ".jpg" )==0 || strcmp(Tcl_GetStringResult(interp), ".jpeg")==0) {
               strcpy(format, "jpeg");
            } else if(strcmp(Tcl_GetStringResult(interp), ".png" )==0) {
               strcpy(format, "png");
            } else if(strcmp(Tcl_GetStringResult(interp), ".ps"  )==0 || strcmp(Tcl_GetStringResult(interp), ".eps" )==0 ) {
               strcpy(format, "ps");
            } else if(strcmp(Tcl_GetStringResult(interp), ".tiff")==0 || strcmp(Tcl_GetStringResult(interp), ".tif" )==0) {
               strcpy(format, "tiff");
            } else if(strcmp(Tcl_GetStringResult(interp), ".xbm" )==0) {
               strcpy(format, "xbm");
            } else if(strcmp(Tcl_GetStringResult(interp), ".xpm" )==0) {
               strcpy(format, "xpm");
            } else {
               tclResult = TCL_ERROR;
            }
         }
      } 

      
      if (tclResult == TCL_OK) { 
         // j'essaie de charger le package Img pour pouvoir reconnaitre plus de type d'image
         // Si le package n'existe , je continue quand meme en utilisant les types definis par TK
         Tcl_PkgRequire(interp, "Img", "1.3", 0);

         // je cree une image tk temporaire.
         sprintf(ligne,"image create photo temporaryImageVisu");
         tclResult = Tcl_Eval(interp,ligne) ;
      }

      

      if (tclResult == TCL_OK) {
         // je recupere le handle de l'image tk
         ph = Tk_FindPhoto(interp,"temporaryImageVisu");
         if(ph==NULL) {
            sprintf( ligne, "CmdSaveImage : can not find temporaryImageVisu for file %s",fileName); 
             Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            tclResult = TCL_ERROR;
         }
      }

      if (tclResult == TCL_OK) {
         pib.width = width;
         pib.height = height;
         pib.pixelSize = 4;         // 4 octets par pixels
         pib.pitch  = pib.width * pib.pixelSize;    // taille d'une ligne
         pib.offset[0] = 0;
         pib.offset[1] = 1;
         pib.offset[2] = 2;
         pib.offset[3] = 0;          
         pib.pixelPtr = pixelPtr;
         tclResult = Tk_PhotoPutBlock(interp, ph, &pib, 0, 0, pib.width ,pib.height, TK_PHOTO_COMPOSITE_SET);
      }      
      if (tclResult == TCL_OK) {
         // j'enregistre l'image dans le fichier en utilisant la librairie tkimg ou tk
         sprintf(ligne,"temporaryImageVisu write \"%s\" -format %s", fileName, format); 
         tclResult = Tcl_Eval(interp,ligne) ;
      }
      if (tclResult == TCL_ERROR) {
         //je sauvegarde le message d'erreur
         strncpy(errorMessage, Tcl_GetStringResult(interp), sizeof(errorMessage) -1);       
      }
      // je supprime l'image temporaire  (sans tenir compte du resultat pour la suite)
      sprintf(ligne,"image delete temporaryImageVisu");
      Tcl_Eval(interp,ligne);

      if (tclResult == TCL_OK) {
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      } else {
         Tcl_SetResult(interp,errorMessage,TCL_VOLATILE);
      }
   }
   return tclResult;
}
