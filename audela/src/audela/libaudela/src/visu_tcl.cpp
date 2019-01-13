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

#include "cpool.h"
#include "cbuffer.h"
#include "cvisu.h"

//------------------------------------------------------------------------------
// La variable globale est definie de maniere unique ici.
//
CPool *visu_pool;

//------------------------------------------------------------------------------
// Commande internes pour gerer les commandes d'une visu
//
int cmdVisuClear(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuCut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuDisp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuMirrorX(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuMirrorY(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuPal(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuPalDir(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuBuf(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuThickness(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuWindow(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdVisuZoom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);


static struct cmditem cmdlist[] = {
   {"clear", (Tcl_CmdProc *)cmdVisuClear},
   {"cut", (Tcl_CmdProc *)cmdVisuCut},
   {"disp", (Tcl_CmdProc *)cmdVisuDisp},
   {"pal", (Tcl_CmdProc *)cmdVisuPal},
   {"paldir", (Tcl_CmdProc *)cmdVisuPalDir},
   {"buf", (Tcl_CmdProc *)cmdVisuBuf},
   {"image", (Tcl_CmdProc *)cmdVisuImage},
   {"mirrorx", (Tcl_CmdProc *)cmdVisuMirrorX},
   {"mirrory", (Tcl_CmdProc *)cmdVisuMirrorY},
   {"thickness", (Tcl_CmdProc *)cmdVisuThickness},
   {"window", (Tcl_CmdProc *)cmdVisuWindow},
   {"zoom", (Tcl_CmdProc *)cmdVisuZoom},
   {NULL, NULL}
};

int CmdVisu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[1024],ss[50];
   int result = TCL_OK;
   int k;
   struct cmditem *cmd;

   if(argc==1) {
      sprintf(s,"%s choose sub-command among ",argv[0]);
      k=0;
      while (cmdlist[k].cmd!=NULL) {
	      sprintf(ss," %s",cmdlist[k].cmd);
			strcat(s,ss);
			k++;
		}
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      for(cmd=cmdlist;cmd->cmd!=NULL;cmd++) {
         if(strcmp(cmd->cmd,argv[1])==0) {
            result = (*cmd->func)(clientData, interp, argc, argv);
            break;
         }
      }
      if(cmd->cmd==NULL) {
         sprintf(s,"%s %s : sub-command not found among ",argv[0], argv[1]);
         k=0;
		   while (cmdlist[k].cmd!=NULL) {
			   sprintf(ss," %s",cmdlist[k].cmd);
			   strcat(s,ss);
			   k++;
		   }
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdVisuBuf(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   int buf;
   CVisu *visu;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?num?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      sprintf(ligne,"%d",visu->bufnum);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetInt(interp,argv[2],&buf)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?num?\nnum = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->CreateBuffer(buf);
      }
   }
   free(ligne);
   return result;
}

int cmdVisuClear(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CVisu *visu;

   ligne = (char*)calloc(200,sizeof(char));
   if(argc!=2) {
      sprintf(ligne,"Usage: %s %s ",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      visu = (CVisu*)clientData;
      sprintf(ligne,"%d",visu->ClearImage() );
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   free(ligne);
   return result;
}

int cmdVisuImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   int img;
   CVisu *visu;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?num?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      sprintf(ligne,"%d",visu->imgnum);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetInt(interp,argv[2],&img)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?num?\nnum = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->CreateImage(img);
      }
   }
   free(ligne);
   return result;
}

int cmdVisuPal(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   int res;

   ligne = (char*)calloc(1000,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?pal?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      switch(((CVisu*)clientData)->pal.typ) {
         case Pal_Grey :
            sprintf(ligne,"grey");
            break;
         case Pal_Red1 :
            sprintf(ligne,"red1");
            break;
         case Pal_Red2 :
            sprintf(ligne,"red2");
            break;
         case Pal_Green1 :
            sprintf(ligne,"green1");
            break;
         case Pal_Green2 :
            sprintf(ligne,"green2");
            break;
         case Pal_Blue1 :
            sprintf(ligne,"blue1");
            break;
         case Pal_Blue2 :
            sprintf(ligne,"blue2");
            break;
         case Pal_File :
            sprintf(ligne,((CVisu*)clientData)->pal.filename);
            break;
         case Pal_None :
         default :
            strcpy(ligne,"none");
            break;
     }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(strcmp(argv[2],"grey")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Grey);
      } else if(strcmp(argv[2],"red1")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Red1);
      } else if(strcmp(argv[2],"red2")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Red2);
      } else if(strcmp(argv[2],"green1")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Green1);
      } else if(strcmp(argv[2],"green2")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Green2);
      } else if(strcmp(argv[2],"blue1")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Blue1);
      } else if(strcmp(argv[2],"blue2")==0) {
         ((CVisu*)clientData)->CreatePalette(Pal_Blue2);
      } else {         
         // je traite les noms de repertoires contenant des caract�res accentu�s
         sprintf(ligne,"encoding convertfrom identity {%s}",argv[2]); 
         Tcl_Eval(interp,ligne); 
         res = ((CVisu*)clientData)->CreatePaletteFromFile(interp->result);
         if(res!=0) {
            Tcl_SetResult(interp,CError::message(res),TCL_VOLATILE);
            result = TCL_ERROR;
         }
      }
   }
   free(ligne);
   return result;
}

int cmdVisuPalDir(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CVisu *visu;

   if((argc!=2)&&(argc!=3)) {
      ligne = (char*)calloc(200,sizeof(char));
      sprintf(ligne,"Usage: %s %s ?path?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      free(ligne);
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      Tcl_SetResult(interp,visu->GetPaletteDir(),TCL_VOLATILE);
   } else {
      ligne = (char*)calloc(200,sizeof(char));
      visu = (CVisu*)clientData;

      // je traite les noms de repertoires contenant des caract�res accentu�s
      sprintf(ligne,"encoding convertfrom identity {%s}",argv[2]); 
      Tcl_Eval(interp,ligne); 
      visu->SetPaletteDir(interp->result);
      free(ligne);
   }
   return result;
}

int cmdVisuCut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   float fsh, fsb;
   double dSh, dSb;
   CVisu *visu;
   CBuffer *buffer;
   int listArgc;
   char **listArgv;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?cut?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;

      buffer = (CBuffer*)buf_pool->Chercher(visu->bufnum);
      if( buffer->GetNaxis() == 2 || buffer->GetNaxis() == 1) {
         fsh= visu->GetGrayHicut();
         fsb= visu->GetGrayLocut();

         sprintf(ligne,"%f %f",fsh,fsb);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else {
         float fshR, fsbR, fshG, fsbG, fshB, fsbB;
         visu->GetRgbCuts(&fshR, &fsbR, &fshG, &fsbG, &fshB, &fsbB);
         sprintf(ligne,"%f %f %f %f %f %f", fshR, fsbR, fshG, fsbG, fshB, fsbB);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }

   } else {
      if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
         sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else if (listArgc == 2 ){
         if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicut locut}\nhicut = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicut locut}\nlocut = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            fsh = (float)dSh;
            fsb = (float)dSb;            
            visu = (CVisu*)clientData;
            visu->SetGrayCuts(fsh, fsb);            
         }
         Tcl_Free((char*)listArgv);
      } else if (listArgc == 6 ){
         double dShR, dSbR, dShG, dSbG, dShB, dSbB;
         float fshR, fsbR, fshG, fsbG, fshB, fsbB;
         if(Tcl_GetDouble(interp,listArgv[0],&dShR)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutR locutR hicutG locutG hicutB locutB}\nhicutR = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else if(Tcl_GetDouble(interp,listArgv[1],&dSbR)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutR locutR hicutG locutG hicutB locutB}\nlocutR = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else if(Tcl_GetDouble(interp,listArgv[2],&dShG)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutR locutR hicutG locutG hicutB locutB}\nhicutG = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else if(Tcl_GetDouble(interp,listArgv[3],&dSbG)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutR locutR hicutG locutG hicutB locutB}\nlocutG = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else if(Tcl_GetDouble(interp,listArgv[4],&dShB)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutR locutR hicutG locutG hicutB locutB}\nhicutB = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else if(Tcl_GetDouble(interp,listArgv[5],&dSbB)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutR locutR hicutG locutG hicutB locutB}\nlocutB = must be a number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            fshR = (float)dShR;
            fsbR = (float)dSbR;
            fshG = (float)dShG;
            fsbG = (float)dSbG;
            fshB = (float)dShB;
            fsbB = (float)dSbB;
            visu = (CVisu*)clientData;
            visu->SetRgbCuts(fshR, fsbR, fshG, fsbG, fshB, fsbB);
         }
         Tcl_Free((char*)listArgv);
      } else {
         sprintf(ligne,"Threshold struct not valid: must be { hicut locut } or {hicutR locutR hicutG locutG hicutB locutB}");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   free(ligne);
   return result;
}

// TODO : Il faut reorganiser cette fonction pour qu'elle adhere au style gloval,
// notamment en terme de gestion du resultat TCL.
int cmdVisuDisp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result;
   char *ligne;
   float sh=(float)0., sb=(float)0.;
   double dSh, dSb;
   float shRed=(float)0., sbRed=(float)0.;
   float shGreen=(float)0., sbGreen=(float)0.;
   float shBlue=(float)0., sbBlue=(float)0.;
   int listArgc;
   int i;
   char **listArgv;
   CVisu *visu;

   ligne = (char*)calloc(200,sizeof(char));
   if( argc!=2 && argc!=3 && argc!=5) {
      sprintf(ligne,"Usage: %s %s ?cut?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   } else {
      visu = (CVisu*)clientData;
      if(argc==2) {
         // rien a faire
      } else if(argc==3) {
         if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Threshold struct not valid: must be { hicut locut }");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nhicut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicut locut}\nlocut = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else {
               sh = (float)dSh;
               sb = (float)dSb;
            }
            Tcl_Free((char*)listArgv);
            visu->SetGrayCuts(sh, sb);
         }

      } else if(argc==5) {
         if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\ninvalid {hicutRed locutRed}");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\ninvalid {hicutRed locutRed}");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\nhicutRed = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\nlocutRed = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_OK;
            } else {
               shRed = (float)dSh;
               sbRed = (float)dSb;
            }
            Tcl_Free((char*)listArgv);
         }
         if(Tcl_SplitList(interp,argv[3],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\ninvalid {hicutGreen locutGreen}");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\ninvalid {hicutGreen locutGreen}");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\nhicutGreen = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\nlocutGreen = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else {
               shGreen = (float)dSh;
               sbGreen = (float)dSb;
            }
            Tcl_Free((char*)listArgv);
         }

         if(Tcl_SplitList(interp,argv[4],&listArgc,&listArgv)!=TCL_OK) {
            sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\ninvalid {hicutBlue locutBlue}");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else if(listArgc!=2) {
            sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\ninvalid {hicutBlue locutBlue}");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            free(ligne);
            return TCL_ERROR;
         } else {
            if(Tcl_GetDouble(interp,listArgv[0],&dSh)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\nhicutBlue = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_OK;
            } else if(Tcl_GetDouble(interp,listArgv[1],&dSb)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {hicutRed locutRed} {hicutGreen locutGreen} {hicutBlue locutBlue}\nlocutBlue = must be a number",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               free(ligne);
               return TCL_ERROR;
            } else {
               shBlue = (float)dSh;
               sbBlue = (float)dSb;
            }
            Tcl_Free((char*)listArgv);
         }

         visu->SetRgbCuts(shRed, sbRed, shGreen, sbGreen, shBlue, sbBlue);

      } else {
         // Ya un probleme
      }


      switch(i=visu->UpdateDisplay()) {
         case 0:
            result = TCL_OK;
            break;
         case 1:
            sprintf(ligne,"buf%d does not exist (abnormal error)",visu->bufnum);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
            break;
         case 2:
            sprintf(ligne,"buf%d is empty (abnormal error)",visu->bufnum);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
            break;
         case 3:
            sprintf(ligne,"Can not find mandatory NAXIS1 FITS keyword");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
            break;
         case 4:
            sprintf(ligne,"Can not find mandatory NAXIS2 FITS keyword");
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
            break;
         case ELIBSTD_X1X2_NOT_IN_1NAXIS1:
         case ELIBSTD_Y1Y2_NOT_IN_1NAXIS2:
            {
               int x1,y1,x2,y2;
               visu->GetWindow(&x1,&y1,&x2,&y2);
               sprintf(ligne,"current subwindow (x1,y1)-(x2,y2) (%d,%d)(%d,%d) is incompatible with the of this picture",x1,y1,x2,y2);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            }
            break;

         default:
            sprintf(ligne,"Error %d in UpdateDisplay",i);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
            break;
      };
   }
   free(ligne);
   return result;
}


int cmdVisuWindow(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CBuffer *buffer;
   CVisu *visu;
   int listArgc;
   int x1, y1, x2, y2, i;
   char **listArgv;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?{x1 y1 x2 y2}?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      if(visu->IsFull()==1) {
         sprintf(ligne,"full");
      } else {
         visu->GetWindow(&x1,&y1,&x2,&y2);
         sprintf(ligne,"%d %d %d %d",x1,y1,x2,y2);
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_SplitList(interp,argv[2],&listArgc,&listArgv)!=TCL_OK) {
         sprintf(ligne,"Window struct not valid: must be { x1 y1 x2 y2 } or full");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if(listArgc==1) {
            if(strcmp(listArgv[0],"full")!=0) {
               sprintf(ligne,"Window struct not valid: must be { x1 y1 x2 y2 } or full");
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               visu = (CVisu*)clientData;
               visu->SetWindowFull();
            }
         } else if(listArgc==4) {
            if(Tcl_GetInt(interp,listArgv[0],&x1)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\nx1 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else if(Tcl_GetInt(interp,listArgv[1],&y1)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\ny1 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else if(Tcl_GetInt(interp,listArgv[2],&x2)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\nx2 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else if(Tcl_GetInt(interp,listArgv[3],&y2)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}\ny2 must be an integer",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               visu = (CVisu*)clientData;
               if(x1>x2) {
                  i = x2;
                  x2 = x1;
                  x1 = i;
               }
               buffer = (CBuffer*)buf_pool->Chercher(visu->bufnum);
               int naxis1 = buffer->GetW();
               int naxis2 = buffer->GetH();

               if( buffer->GetNaxis() == 1 ) {
                  naxis2 = visu->GetThickness();
               } else {
                  naxis2 = buffer->GetH();
               }

               if(y1>y2) {
                  i = y2;
                  y2 = y1;
                  y1 = i;
               }
               if((x1>0)&&(x1<=naxis1)&&
                  (y1>0)&&(y1<=naxis2)&&
                  (x2>0)&&(x2<=naxis1)&&
                  (y2>0)&&(y2<=naxis2)) {
                  switch( visu->SetWindow(x1,y1,x2,y2)) {
                  case 0:
                     result = TCL_OK;
                     break;
                  case ELIBSTD_SUB_WINDOW_ALREADY_EXIST:
                     Tcl_SetResult(interp,"a window already exists",TCL_VOLATILE);
                     result = TCL_ERROR;
                     break;
                  }
               } else {
                  sprintf(ligne,"Window not bound inside original picture");
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                  result = TCL_ERROR;
               }
            }
         } else {
            sprintf(ligne,"Usage: %s %s {x1 y1 x2 y2}/full\nneeds a 4 element list, or full",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
         Tcl_Free((char*)listArgv);
      }
   }
   free(ligne);
   return result;
}


int cmdVisuZoom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CVisu *visu;
   double zoom;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?zoom?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      visu->GetZoom(&zoom);
      if (zoom<1.) {
         sprintf(ligne,"%f",zoom);
      } else {
         sprintf(ligne,"%d",int(zoom));
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetDouble(interp,argv[2],&zoom)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?zoom?\nzoom must be a double in range 0 to 4",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->SetZoom(zoom);
      }
   }
   free(ligne);
   return result;
}

int cmdVisuMirrorX(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CVisu *visu;
   int mirror;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?0|1?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      sprintf(ligne,"%d",visu->GetMirrorX());
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetInt(interp,argv[2],&mirror)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?0|1?\nvlaue must be an integer in range 0 to 1",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->SetMirrorX(mirror);
      }
   }
   free(ligne);
   return result;
}

int cmdVisuMirrorY(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char *ligne;
   CVisu *visu;
   int mirror;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?0|1?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      visu = (CVisu*)clientData;
      sprintf(ligne,"%d",visu->GetMirrorY());
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      if(Tcl_GetInt(interp,argv[2],&mirror)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?0|1?\nvlaue must be an integer in range 0 to 1",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->SetMirrorY(mirror);
      }
   }
   free(ligne);
   return result;
}

//---------------------------------------------------------------------
/**
 * cmdThickness
 *   set or get thickness of 1D picture
 *   
 * Parameters: 
 *    value  : name  
 * Results:
 *    returns  ident or FORMAT_UNKNOWN if name is not found
 * Side effects:
 *    none
 */
int cmdVisuThickness(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
  int result = TCL_OK;
   char *ligne;
   CVisu *visu;

   ligne = (char*)calloc(200,sizeof(char));
   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?value?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      visu = (CVisu*)clientData;
      strcpy(ligne, "");
      sprintf(ligne, "%d", visu->GetThickness() );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      int thickness;
      visu = (CVisu*)clientData;
      if(Tcl_GetInt(interp,argv[2],&thickness)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?0|1?\nvalue must be an integer",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         visu = (CVisu*)clientData;
         visu->SetThickness(thickness);
      }
   }
   free(ligne);

   return result;
}


