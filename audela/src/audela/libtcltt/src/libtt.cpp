/* tt.cpp
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

#ifdef WIN32 
#include <windows.h>

#else 
#   include <stdlib.h>
#   include <string.h>
#endif

#include <string>
#include <math.h>
#include <libtt.h>            // for TFLOAT, LONG_IMG, TT_PTR_...
#include "utf2Unicode_tcl.h"


#define NB_TT_PARAMS 7

#define TT_DIR_IN    0
#define TT_DIR_OUT   1
#define TT_EXT_IN    2
#define TT_EXT_OUT   3
#define TT_START_IN  4
#define TT_END_IN    5
#define TT_START_OUT 6

#define CMD_NGAIN2    1
#define CMD_SUB2      2
#define CMD_NOFFSET2  3
#define CMD_DIV2      4
#define CMD_OPT2      5
#define CMD_TRANS2    6
#define CMD_REGISTER  7
#define CMD_REGISTER2 8
#define CMD_SMEDIAN   9
#define CMD_SADD      10
#define CMD_SMEAN     11

#define CMD_OFFSET2   12
#define CMD_ADD2      13

//------------------------------------------------------------------------------
// Implementation de la libraire Libtt
//
//------------------------------------------------------------------------------
// Prototypes
//

char* getErrorMessage(int error);

class Ctt_params {
      protected:
   char *current_dir;
   void allocate(char**,const char*);
      public:
   char *parametres[NB_TT_PARAMS];
   Ctt_params(Tcl_Interp*);
   ~Ctt_params();
   char* Get(int);
   void Set(int,char*);
};

Ctt_params::Ctt_params(Tcl_Interp*interp)
{
   char *tmp;
   int i;

   for(i=0;i<NB_TT_PARAMS;i++) {
      *(parametres+i) = 0;
   }
   current_dir = 0;

   if((tmp=(char*)Tcl_GetVar(interp,"tt(dir_in)",TCL_GLOBAL_ONLY))==0) {
      Tcl_Eval(interp,"pwd");
      allocate(&current_dir,Tcl_GetStringResult(interp));
      allocate(parametres+TT_DIR_IN,Tcl_GetStringResult(interp));
   } else {
      allocate(parametres+TT_DIR_IN,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(dir_out)",TCL_GLOBAL_ONLY))==0) {
      if(current_dir==0) {
         Tcl_Eval(interp,"pwd");
         allocate(&current_dir,Tcl_GetStringResult(interp));
      }
      allocate(parametres+TT_DIR_OUT,current_dir);
   } else {
      allocate(parametres+TT_DIR_OUT,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(ext_in)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_EXT_IN,".fit");
   } else {
      allocate(parametres+TT_EXT_IN,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(ext_out)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_EXT_OUT,".fit");
   } else {
      allocate(parametres+TT_EXT_OUT,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(start_in)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_START_IN,"1");
   } else {
      allocate(parametres+TT_START_IN,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(start_out)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_START_OUT,"1");
   } else {
      allocate(parametres+TT_START_OUT,tmp);
   }
}

Ctt_params::~Ctt_params()
{
   int i;
   for(i=0;i<NB_TT_PARAMS;i++) {
      if(*(parametres+i)) free(*(parametres+i));
   }
   if(current_dir) free(current_dir);
}

void Ctt_params::allocate(char**s_to,const char*s_from)
{
   if(s_from==0) {
      if(*s_to) {
         free(*s_to);
         *s_to = 0;
      }
   } else {
      if(*s_to==0) {
         free(*s_to);
      }
      *s_to = (char*)calloc(strlen(s_from)+1,1);
      strcpy(*s_to,s_from);
   }
}

void Ctt_params::Set(int n,char*s)
{
   if((n>=0)&&(n<NB_TT_PARAMS)) {
      allocate(parametres+n,s);
   }
}

char* Ctt_params::Get(int n)
{
   return *(parametres+n);
}

//-------------------------------------------------------------------------
// CmdFits2ColorJpg --
// Charge trois fichiers FITS en memoire et les sauve en Jpeg Couleur.
//
// fits2colorjpg filenamergb filenamejpg ?quality? ?locutr hicutr locutg hicutg locutb hicutb?
// autorises : 3,4,10
// fits2colorjpg filenamer filenameg filenameb filenamejpg ?quality? ?locutr hicutr locutg hicutg locutb hicutb?
// autorises : 5,6,12
//-------------------------------------------------------------------------
int CmdFits2ColorJpg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char *name, *ext, *path2, *nom_fichier_r, *nom_fichier_g, *nom_fichier_b, *nom_fichier_jpg;
   char *ligne;
   char *s;
   int msg;
   int retour;
   int quality,sbsh,mode,indexr=0,indexg=0,indexb=0,indexjpg=0;
   double sbr,shr,sbg,shg,sbb,shb;
   int nb_keys,kkey;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   int datatype;                    // Type du pointeur de l'image
   int naxis1,naxis2,naxis10,naxis20;
   float *pr=NULL,*pg=NULL,*pb=NULL;

   ligne = new char[256];
   datatype=TFLOAT;

   mode=0;
   if ((argc==3)||(argc==4)||(argc==10)) {
      mode=1;
      indexr=indexg=indexb=1;
      indexjpg=2;
   }
   if ((argc==5)||(argc==6)||(argc==12)) {
      mode=2;
      indexr=1;
      indexg=2;
      indexb=3;
      indexjpg=4;
   }
   if (mode==0) {
      sprintf(ligne,"Usage: %s filenamer filenameg filenameb filenamejpg ?quality? ?locutr hicutr locutg hicutg locutb hicutb?",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      name = (char*)calloc(64,sizeof(char));
      ext = (char*)calloc(10,sizeof(char));
      path2 = (char*)calloc(256,sizeof(char));
      nom_fichier_r = (char*)calloc(1000,sizeof(char));
      nom_fichier_g = (char*)calloc(1000,sizeof(char));
      nom_fichier_b = (char*)calloc(1000,sizeof(char));
      nom_fichier_jpg = (char*)calloc(1000,sizeof(char));

      // Decodage du nom de fichier : chemin, nom du fichier, etc.
      // fichier r
      sprintf(ligne,"file dirname {%s}",argv[indexr]); Tcl_Eval(interp,ligne); strcpy(path2,Tcl_GetStringResult(interp));
      sprintf(ligne,"file tail {%s}",argv[indexr]); Tcl_Eval(interp,ligne); strcpy(name,Tcl_GetStringResult(interp));
      sprintf(ligne,"file extension {%s}",argv[indexr]); Tcl_Eval(interp,ligne);
      if(strcmp(Tcl_GetStringResult(interp),"")==0) strcpy(ext,".fit"); else strcpy(ext,"");
      sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_r,Tcl_GetStringResult(interp));

      if (mode==2) {
      	// Decodage du nom de fichier : chemin, nom du fichier, etc.
      	// fichier g
      	sprintf(ligne,"file dirname {%s}",argv[indexg]); Tcl_Eval(interp,ligne); strcpy(path2,Tcl_GetStringResult(interp));
      	sprintf(ligne,"file tail {%s}",argv[indexg]); Tcl_Eval(interp,ligne); strcpy(name,Tcl_GetStringResult(interp));
      	sprintf(ligne,"file extension {%s}",argv[indexg]); Tcl_Eval(interp,ligne);
      	if(strcmp(Tcl_GetStringResult(interp),"")==0) strcpy(ext,".fit"); else strcpy(ext,"");
      	sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_g,Tcl_GetStringResult(interp));
      	// Decodage du nom de fichier : chemin, nom du fichier, etc.
      	// fichier b
      	sprintf(ligne,"file dirname {%s}",argv[indexb]); Tcl_Eval(interp,ligne); strcpy(path2,Tcl_GetStringResult(interp));
      	sprintf(ligne,"file tail {%s}",argv[indexb]); Tcl_Eval(interp,ligne); strcpy(name,Tcl_GetStringResult(interp));
      	sprintf(ligne,"file extension {%s}",argv[indexb]); Tcl_Eval(interp,ligne);
      	if(strcmp(Tcl_GetStringResult(interp),"")==0) strcpy(ext,".fit"); else strcpy(ext,"");
      	sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_b,Tcl_GetStringResult(interp));
      } else {
         sprintf(nom_fichier_g,"%s;2",nom_fichier_r);
         sprintf(nom_fichier_b,"%s;3",nom_fichier_r);
      }

      // Decodage du nom de fichier : chemin, nom du fichier, etc.
      // fichier jpg
      sprintf(ligne,"file dirname {%s}",argv[indexjpg]); Tcl_Eval(interp,ligne); strcpy(path2,Tcl_GetStringResult(interp));
      sprintf(ligne,"file tail {%s}",argv[indexjpg]); Tcl_Eval(interp,ligne); strcpy(name,Tcl_GetStringResult(interp));
      sprintf(ligne,"file extension {%s}",argv[indexjpg]); Tcl_Eval(interp,ligne);
      if(strcmp(Tcl_GetStringResult(interp),"")==0) strcpy(ext,".jpg"); else strcpy(ext,"");
      sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_jpg,Tcl_GetStringResult(interp));

      // decodage du critere de qualite
      quality=75;
      if (((mode==1)&&(argc>=4))||((mode==2)&&(argc>=6))) {
         quality=(int)(fabs(atof(argv[indexjpg+1])));
      }
      if (quality<5) {quality=5;}
      if (quality>100) {quality=100;}

      // decodage des seuils
      sbsh=0;
      sbr=shr=sbg=shg=sbb=shb=0.0;
      if (((mode==1)&&(argc>=10))||((mode==2)&&(argc>=12))) {
         sbr=(double)atof(argv[indexjpg+2]);
         shr=(double)atof(argv[indexjpg+3]);
         sbg=(double)atof(argv[indexjpg+4]);
         shg=(double)atof(argv[indexjpg+5]);
         sbb=(double)atof(argv[indexjpg+6]);
         shb=(double)atof(argv[indexjpg+7]);
         sbsh=1;
      }

      // Charge l'image rouge
      msg = libtt_main(TT_PTR_LOADIMA,11,nom_fichier_r,&datatype,&pr,&naxis10,&naxis20,
   	   &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_r,s);
            delete s;
         } else {
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_r,getErrorMessage(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}
      // Decode les seuils rouges
      if (sbsh==0) {
         for (kkey=0;kkey<nb_keys;kkey++) {
            if (strcmp(keynames[kkey],"MIPS-LO")==0) {
               sbr=(double)atof(values[kkey]);
            }
            if (strcmp(keynames[kkey],"MIPS-HI")==0) {
               shr=(double)atof(values[kkey]);
            }
         }
      }
      // Liberation de la memoire allouee par libtt
      libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

      // Charge l'image verte
      msg = libtt_main(TT_PTR_LOADIMA,11,nom_fichier_g,&datatype,&pg,&naxis1,&naxis2,
   	   &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_g,s);
            delete s;
         } else {
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_g,getErrorMessage(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         libtt_main(TT_PTR_FREEPTR,1,&pr);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}
      // verifie les dimensions
      if ((naxis1!=naxis10)||(naxis2!=naxis20)) {
      	sprintf(ligne,"Error image formats are not the same");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         libtt_main(TT_PTR_FREEPTR,1,&pr);
         libtt_main(TT_PTR_FREEPTR,1,&pg);
         libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
      }
      // Decode les seuils verts
      if (sbsh==0) {
         for (kkey=0;kkey<nb_keys;kkey++) {
            if (strcmp(keynames[kkey],"MIPS-LO")==0) {
               sbg=(double)atof(values[kkey]);
            }
            if (strcmp(keynames[kkey],"MIPS-HI")==0) {
               shg=(double)atof(values[kkey]);
            }
         }
      }
      // Liberation de la memoire allouee par libtt
      libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

      // Charge l'image bleue
      msg = libtt_main(TT_PTR_LOADIMA,11,nom_fichier_b,&datatype,&pb,&naxis1,&naxis2,
   	   &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_b,s);
            delete s;
         } else {
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_b,getErrorMessage(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         libtt_main(TT_PTR_FREEPTR,1,&pr);
         libtt_main(TT_PTR_FREEPTR,1,&pg);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}
      // verifie les dimensions
      if ((naxis1!=naxis10)||(naxis2!=naxis20)) {
      	sprintf(ligne,"Error image formats are not the same");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         libtt_main(TT_PTR_FREEPTR,1,&pr);
         libtt_main(TT_PTR_FREEPTR,1,&pg);
         libtt_main(TT_PTR_FREEPTR,1,&pb);
         libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
      }
      // Decode les seuils bleus
      if (sbsh==0) {
         for (kkey=0;kkey<nb_keys;kkey++) {
            if (strcmp(keynames[kkey],"MIPS-LO")==0) {
               sbb=(double)atof(values[kkey]);
            }
            if (strcmp(keynames[kkey],"MIPS-HI")==0) {
               shb=(double)atof(values[kkey]);
            }
         }
      }
      // Liberation de la memoire allouee par libtt
      libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

      // Sauvegarde de l'image jpeg couleur
      msg=libtt_main(TT_PTR_SAVEJPGCOLOR,14,nom_fichier_jpg,pr,pg,pb,&datatype,
            &naxis1,&naxis2,&sbr,&shr,&sbg,&shg,&sbb,&shb,&quality);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while saveing %s : %s",nom_fichier_jpg,s);
            delete s;
         } else {
            sprintf(ligne,"Error while saveing %s : %s",nom_fichier_jpg,getErrorMessage(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         libtt_main(TT_PTR_FREEPTR,1,&pr);
         libtt_main(TT_PTR_FREEPTR,1,&pg);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}

      Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
      retour = TCL_OK;

      libtt_main(TT_PTR_FREEPTR,1,&pr);
      libtt_main(TT_PTR_FREEPTR,1,&pg);
      libtt_main(TT_PTR_FREEPTR,1,&pb);

      free(name);
      free(ext);
      free(path2);
      free(nom_fichier_r);
      free(nom_fichier_g);
      free(nom_fichier_b);
      free(nom_fichier_jpg);
   }

   delete ligne;
   return retour;
}

int CmdTtScript2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;
   char *ligne, *s;
   int nb_arg_min = 2;        // Nombre minimal d'arguments

   if(argc<nb_arg_min) {
      ligne = (char*)calloc(100,sizeof(char));
      sprintf(ligne,"Usage: %s ttscript_line",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   }

   msg = libtt_main(TT_SCRIPT_2,1,argv[1]);
   if(msg) {
      s = (char*)calloc(100,sizeof(char));
      ligne = (char*)calloc(100,sizeof(char));
      libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
      sprintf(ligne,"Erreur dans libtt : %s.",s);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(s);
      free(ligne);
      return TCL_ERROR;
   }

   Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
   return TCL_OK;
}


int CmdTtScript3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;
   char *ligne, *s;
   int nb_arg_min = 2;        // Nombre minimal d'arguments

   if(argc<nb_arg_min) {
      ligne = (char*)calloc(100,sizeof(char));
      sprintf(ligne,"Usage: %s ttscript_filename",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   }

   msg = libtt_main(TT_SCRIPT_3,1,argv[1]);
   if(msg) {
      s = (char*)calloc(100,sizeof(char));
      ligne = (char*)calloc(100,sizeof(char));
      libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
      sprintf(ligne,"Error while performing tt_script_3 : %s.",s);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(s);
      free(ligne);
      return TCL_ERROR;
   }

   Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
   return TCL_OK;
}

int CmdFitsHeader(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;                         // Code erreur de libtt
   int nbkeys,k;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   Tcl_DString dsptr;
   char ligne[1024];
   char s[1024];
   int nb_arg_min = 2;        // Nombre minimal d'arguments
   
   if(argc<nb_arg_min) {
      sprintf(ligne,"Usage: %s filename",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }

   // je convertis les caracteres accentues
   int length;
   Tcl_DString sourceFileName;
   Tcl_DStringInit(&sourceFileName);
   char * stringPtr = (char *) Tcl_GetByteArrayFromObj(Tcl_NewStringObj(argv[1],strlen(argv[1])), &length);
   Tcl_ExternalToUtfDString(Tcl_GetEncoding(interp, "identity"), stringPtr, length, &sourceFileName);

   msg=libtt_main(TT_PTR_LOADKEYS,7,sourceFileName.string,&nbkeys,&keynames,&values,
      &comments,&units,&datatypes);
   if(msg) {
      libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
      sprintf(ligne,"Error while loading header: %s.",s);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
	Tcl_DStringInit(&dsptr);
   for (k=0;k<nbkeys;k++) {
		Tcl_DStringStartSublist(&dsptr);
		Tcl_DStringAppendElement(&dsptr,keynames[k]);
      sprintf(ligne,"string trim \"%s\" \" \"",values[k]);
      Tcl_Eval(interp,ligne);
		sprintf(ligne,"%s",Tcl_GetStringResult(interp));
		Tcl_DStringAppendElement(&dsptr,ligne);
      if (datatypes[k]==TBIT) {
         strcpy(ligne,"bit");
      } else if (datatypes[k]==TBYTE_FITS) {
         strcpy(ligne,"byte");
      } else if (datatypes[k]==TLOGICAL) {
         strcpy(ligne,"logical");
      } else if (datatypes[k]==TSTRING) {
         strcpy(ligne,"string");
      } else if (datatypes[k]==TUSHORT) {
         strcpy(ligne,"ushort");
      } else if (datatypes[k]==TINT) {
         strcpy(ligne,"int");
      } else if (datatypes[k]==TULONG) {
         strcpy(ligne,"ulong");
      } else if (datatypes[k]==TLONG) {
         strcpy(ligne,"long");
      } else if (datatypes[k]==TFLOAT) {
         strcpy(ligne,"float");
      } else if (datatypes[k]==TDOUBLE) {
         strcpy(ligne,"double");
      } else if (datatypes[k]==TCOMPLEX) {
         strcpy(ligne,"complex");
      } else if (datatypes[k]==TDBLCOMPLEX) {
         strcpy(ligne,"dlbcomplex");
      }
		Tcl_DStringAppendElement(&dsptr,ligne);
		Tcl_DStringAppendElement(&dsptr,comments[k]);
		Tcl_DStringAppendElement(&dsptr,units[k]);
		Tcl_DStringEndSublist(&dsptr);
		/* --- code obsolete a effacer en 2012 si aucun bug n'est reporté
	   Tcl_DStringAppend(&dsptr,"{",-1);
      sprintf(ligne," \"%s\" ",keynames[k]);
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      sprintf(ligne,"string trim \"%s\" \" \"",values[k]);
      Tcl_Eval(interp,ligne);
		sprintf(ligne,"%s",Tcl_GetStringResult(interp));
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      if (datatypes[k]==TBIT) {
         strcpy(ligne," bit ");
      } else if (datatypes[k]==TBYTE) {
         strcpy(ligne," byte ");
      } else if (datatypes[k]==TLOGICAL) {
         strcpy(ligne," logical ");
      } else if (datatypes[k]==TSTRING) {
         strcpy(ligne," string ");
      } else if (datatypes[k]==TUSHORT) {
         strcpy(ligne," ushort ");
      } else if (datatypes[k]==TINT) {
         strcpy(ligne," int ");
      } else if (datatypes[k]==TULONG) {
         strcpy(ligne," ulong ");
      } else if (datatypes[k]==TLONG) {
         strcpy(ligne," long ");
      } else if (datatypes[k]==TFLOAT) {
         strcpy(ligne," float ");
      } else if (datatypes[k]==TDOUBLE) {
         strcpy(ligne," double ");
      } else if (datatypes[k]==TCOMPLEX) {
         strcpy(ligne," complex ");
      } else if (datatypes[k]==TDBLCOMPLEX) {
         strcpy(ligne," dlbcomplex ");
      }
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      sprintf(ligne," \"%s\" ",comments[k]);
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      sprintf(ligne," \"%s\" ",units[k]);
	   Tcl_DStringAppend(&dsptr,ligne,-1);
	   Tcl_DStringAppend(&dsptr,"} ",-1);
		*/
   }
   Tcl_DStringResult(interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   Tcl_DStringFree(&sourceFileName);
   msg=libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,
      &comments,&units,&datatypes);
   return TCL_OK;
}

/**
  ajoute un mot cle dans le tableau
  si le mot cle existe deja, remplace la valeur existant por la nouvelle valeur
  sinon ajoute le mot cle a la fin du tableau apres avoir redimensionne le tableau (nbkeys +1)

*/
int addKeywordToArray(
     const char *name, const void *value, const int datatype, const char *comment, const char *unit,
     int *nbkeys,
     char ***keynames,
     char ***values,
     char ***comments,
     char ***units,
     int **datatypes
     )
{
   bool found = false;

   for (int kk=0;kk<*nbkeys;kk++) {
      if (strcmp((*keynames)[kk],name)==0) { 
        switch(datatype) {
         case TFLOAT :
            if (fabs(*(float*)value)<0.1) {
               sprintf( (*values)[kk],"%e", *(float*)value);
            } else {
               sprintf( (*values)[kk],"%g", *(float*)value);
            }
            break;
         case TDOUBLE :
            sprintf( (*values)[kk],"%20.15g",*(double*)value);
            break;
         case TSTRING :
           strcpy( (*values)[kk], (char*)(value));
            break;
         default:
           sprintf( (*values)[kk],"%d",*(int*)value);
            break;
        }
        strcpy( (*comments)[kk], comment);
        strcpy( (*units)[kk],    unit);
        (*datatypes)[kk] = datatype; 
        found = true; 
         break;
      }
   }

   if ( ! found) {
      char **newkeynames=NULL;
      char **newvalues=NULL;
      char **newcomments=NULL;
      char **newunits=NULL;
      int *newdatatypes=NULL;

      // je crée un nouveau tableau avec un element de plus
      int newNbkeys = *nbkeys +1; 
      int msg = libtt_main(TT_PTR_ALLOKEYS,6,&newNbkeys,&newkeynames,&newvalues,&newcomments,&newunits,&newdatatypes);
      if(msg) {
         return msg;
      }
      // je copie les mots cles existants dans les nouveaux tableaux
      for (int kk=0;kk<*nbkeys;kk++) {
         strcpy( newkeynames[kk], (*keynames)[kk]);
         strcpy( newvalues[kk],   (*values)[kk]);
         strcpy( newcomments[kk], (*comments)[kk]);
         strcpy( newunits[kk],    (*units)[kk]);
         newdatatypes[kk] = (*datatypes)[kk];         
      }
      int last = *nbkeys;
      // j'ajoute le nouveau mot cle
      strcpy( newkeynames[last], name);
      strcpy( newcomments[last], comment);
      strcpy( newunits[last],    unit);
      newdatatypes[last] =       datatype; 
      switch(datatype) {
         case TFLOAT :
            if (fabs(*(float*)value)<0.1) {
               sprintf( newvalues[last],"%e", *(float*)value);
            } else {
               sprintf( newvalues[last],"%g", *(float*)value);
            }
            break;
         case TDOUBLE :
            sprintf( newvalues[last],"%20.15g",*(double*)value);
            break;
         case TSTRING :
           strcpy( newvalues[last], (char*)(value));
            break;
         default:
           sprintf( newvalues[last],"%d",*(int*)value);
            break;
      }


      // je libere les tableaux initiaux
      msg = libtt_main(TT_PTR_FREEKEYS,5 , keynames, values, comments, units, datatypes);
      if(msg) {
         return msg;
      }

      // je copie les poiteurs des nouveaux tableaux dans les variables de sortie 
      *nbkeys   = newNbkeys;
      *keynames = newkeynames;
      *values   = newvalues;
      *comments = newcomments;
      *units    = newunits;
      *datatypes = newdatatypes;
   }
   return 0;
}

int CmdFitsConvert3d(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;                         // Code erreur de libtt
   int nbkeys,nbkeys0,kk,k;
   char **keynames0=NULL;
   char **values0=NULL;
   char **comments0=NULL;
   char **units0=NULL;
   int *datatypes0=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char ligne[1000];
   char ligne2[1000];
   char filein[1000];
   char fileout[1000];
   int nb,naxis3;
   int naxis1=0,naxis2=0,naxis10,naxis20,datatype;
   int bitpix=0,bzero;
   float *ptot=NULL,*pixelPlan=NULL;
   int nelem,naxis=3;
   
   int nb_arg_min = 5;        // Nombre minimal d'arguments
   
   if(argc<nb_arg_min) {
      sprintf(ligne,"Usage: %s genericname nb extension filename3d",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   nb=atoi(argv[2]);
   if (nb<=0) {
      Tcl_SetResult(interp,(char*)"number of images must be positive",TCL_VOLATILE);
      return TCL_ERROR;
   }
   naxis10=1;
   naxis20=1;
   bzero=0;
   for (k=1;k<=nb;k++) {
      sprintf(filein,"%s%d%s",argv[1],k,argv[3]);
     // je convertis les caracteres accentues
      utf2Unicode(interp, filein, filein);
      if (k==1) {
         msg=libtt_main(TT_PTR_LOADKEYS,7,filein,&nbkeys0,&keynames0,&values0,
            &comments0,&units0,&datatypes0);
         if (msg) {
            libtt_main(TT_ERROR_MESSAGE,2,&msg,ligne2);
            sprintf(ligne,"Error while loading %s: %s.",filein,ligne2);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         }
         
         for (kk=0;kk<nbkeys0;kk++) {
            if (strcmp(keynames0[kk],"NAXIS1")==0) { naxis10=atoi(values0[kk]); }
            if (strcmp(keynames0[kk],"NAXIS2")==0) { naxis20=atoi(values0[kk]); }
            if (strcmp(keynames0[kk],"BITPIX")==0) { bitpix=atoi(values0[kk]); }
            if (strcmp(keynames0[kk],"BZERO")==0) { bzero=atoi(values0[kk]); }
         }

         if ( naxis10 <= 0 ) {
            sprintf(ligne,"FitsConvert3d error NAXIS1=% in %s", naxis10, filein);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0, &comments0,&units0,&datatypes0);
            return TCL_ERROR;
         }
         if ( naxis20 <= 0 ) {
            sprintf(ligne,"FitsConvert3d error NAXIS2=% in %s", naxis20, filein);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0, &comments0,&units0,&datatypes0);
            return TCL_ERROR;
         }
   
         ptot=(float*)calloc((unsigned int)sizeof(float),naxis10*naxis20*nb);
         if (ptot==NULL) {
            sprintf(ligne,"Not enough memory for a cubic image of %dx%dx%d pixels",naxis10,naxis20,nb);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            return TCL_ERROR;
         }         
      } else {
         msg=libtt_main(TT_PTR_LOADKEYS,7,filein,&nbkeys,&keynames,&values,
            &comments,&units,&datatypes);
         if (msg) {
            libtt_main(TT_ERROR_MESSAGE,2,&msg,ligne2);
            sprintf(ligne,"Error while loading %s: %s.",filein,ligne2);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            return TCL_ERROR;
         }
         for (kk=0;kk<nbkeys;kk++) {
            if (strcmp(keynames[kk],"NAXIS1")==0) { naxis1=atoi(values[kk]); }
            if (strcmp(keynames[kk],"NAXIS2")==0) { naxis2=atoi(values[kk]); }
         }
         if ((naxis1!=naxis10)) {
            sprintf(ligne,"Uncompatible format for %s: NAXIS1=%d instead of %d",filein,naxis1,naxis10);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            return TCL_ERROR;
         }
         if ((naxis2!=naxis20)) {
            sprintf(ligne,"Uncompatible format for %s: NAXIS2=%d instead of %d",filein,naxis2,naxis20);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            return TCL_ERROR;
         }
      }
      datatype=TFLOAT;
      msg=libtt_main(TT_PTR_LOADIMA,5,filein,&datatype,&pixelPlan,&naxis1,&naxis2);
      if (msg) {
            sprintf(ligne,"Error loading %s",filein);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            if (ptot != NULL ) { free(ptot);}
            return TCL_ERROR;         
      } else {
         nelem=naxis10*naxis20;
         for (kk=0;kk<nelem;kk++) {
            ptot[(k-1)*nelem+kk]=pixelPlan[kk];
         }
         libtt_main(TT_PTR_FREEPTR,1,&pixelPlan);
      }
   }
   // NAXIS=3 
   msg = addKeywordToArray("NAXIS", &naxis, TINT,"","", &nbkeys0,&keynames0,&values0,&comments0,&units0,&datatypes0);
   if (msg) {
      sprintf(ligne,"FitsConvert3d error add NAXIS=%d in %s", naxis, filein);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
      libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      return TCL_ERROR;
   }

   // NAXIS3=nb
   msg = addKeywordToArray("NAXIS3", &nb, TINT,"","", &nbkeys0,&keynames0,&values0,&comments0,&units0,&datatypes0);
   if (msg) {
      sprintf(ligne,"FitsConvert3d error add NAXIS3=%d in %s", nb, filein);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
      libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      return TCL_ERROR;
   }

   datatype=TFLOAT;
   if ((bitpix==SHORT_IMG)&&(bzero==32768)) {
      bitpix=USHORT_IMG;
   } else if ((bitpix==LONG_IMG)&&(bzero==-2e31)) {
      bitpix=ULONG_IMG;
   }
   naxis3=nb;
   sprintf(fileout,"%s%s",argv[4],argv[3]);
   utf2Unicode(interp, fileout, fileout);
   msg=libtt_main(TT_PTR_SAVEIMA3D,13,fileout,ptot,&datatype,&naxis1,
      &naxis2,&naxis3,&bitpix,&nbkeys0,keynames0,values0,
      comments0,units0,datatypes0);
   if (msg) {
      libtt_main(TT_ERROR_MESSAGE,2,&msg,ligne2);
      sprintf(ligne,"Error while saving %s: %s.",filein,ligne2);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
      libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      if (ptot != NULL ) { free(ptot);}
      return TCL_ERROR;
   }

   if (ptot != NULL ) { 
      free(ptot);
   }

   libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
   libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
   return TCL_OK;
   /*
fitsconvert3d d:/audela/images/j 10 .fit d:/audela/images/alain
fitsconvert3d d:/audela/images/m57- 3 .fit m57rgb
*/
}



/*
 * Codes d'erreur de libstd : ils sont negatifs alors que
 * ceux de libtt sont positifs.
 */
extern char* message(int error);
#define ELIBSTD_BUF_EMPTY                  -1
#define ELIBSTD_NO_MEMORY_FOR_PIXELS       -2
#define ELIBSTD_NO_MEMORY_FOR_KWDS         -3
#define ELIBSTD_NO_MEMORY_FOR_ASTROMPARAMS -4
#define ELIBSTD_NO_KWDS                    -5
#define ELIBSTD_NO_NAXIS1_KWD              -6
#define ELIBSTD_NO_NAXIS2_KWD              -7
#define ELIBSTD_DEST_BUF_NOT_FOUND         -8
#define ELIBSTD_NO_ASTROMPARAMS            -9
#define ELIBSTD_NO_MEMORY_FOR_LUT          -10
#define ELIBSTD_CANNOT_CREATE_BUFFER       -11
#define ELIBSTD_CANT_GETORCREATE_TKIMAGE   -12
#define ELIBSTD_NO_ASSOCIATED_BUFFER       -13
#define ELIBSTD_NO_TKPHOTO_HANDLE          -14
#define ELIBSTD_NO_MEMORY_FOR_DISPLAY      -15
#define ELIBSTD_WIDTH_POSITIVE             -16
#define ELIBSTD_X1X2_NOT_IN_1NAXIS1        -17
#define ELIBSTD_HEIGHT_POSITIVE            -18
#define ELIBSTD_Y1Y2_NOT_IN_1NAXIS2        -19

#define ELIBSTD_PALETTE_CANT_FIND_FILE     -20
#define ELIBSTD_PALETTE_MALFORMED_FILE     -21
#define ELIBSTD_PALETTE_NOTCOMPLETE        -22
#define ELIBSTD_SUB_WINDOW_ALREADY_EXIST   -23
#define ELIBSTD_PIXEL_FORMAT_UNKNOWN       -24
#define ELIBSTD_CANT_OPEN_FILE				 -25
#define ELIBSTD_NO_NAXIS_KWD               -26

#define ELIBSTD_LIBTT_ERROR    				 -29

#define ELIBSTD_NOT_IMPLEMENTED				 -30

#define EFITSKW 								0x00010000

#define EFITSKW_NO_KWDS						(EFITSKW+1)
#define EFITSKW_INTERNAL_INVALID_ARG0  (EFITSKW+2)
#define EFITSKW_NO_SUCH_KWD				(EFITSKW+3)

//------------------------------------------------------------------------------
// Messages d'erreur.
//
char* getErrorMessage(int error)
{
   switch(error) {
      case ELIBSTD_BUF_EMPTY :
         return (char*)"buffer is empty";
      case ELIBSTD_NO_MEMORY_FOR_PIXELS :
         return (char*)"not enough memory for pixel allocation";
      case ELIBSTD_NO_MEMORY_FOR_KWDS :
         return (char*)"not enough memory for keywords allocation";
      case ELIBSTD_NO_MEMORY_FOR_ASTROMPARAMS :
         return (char*)"not enough memory for astrometric parameters allocation";
      case ELIBSTD_NO_NAXIS_KWD :
         return (char*)"image does not have mandatory FITS NAXIS1 keyword";
      case ELIBSTD_NO_NAXIS1_KWD :
         return (char*)"image does not have mandatory FITS NAXIS1 keyword";
      case ELIBSTD_NO_NAXIS2_KWD :
         return (char*)"image does not have mandatory FITS NAXIS2 keyword";
      case ELIBSTD_DEST_BUF_NOT_FOUND :
         return (char*)"destination buffer does not exist";
      case ELIBSTD_NO_ASTROMPARAMS :
         return (char*)"can not find astrometric parameters";
      case ELIBSTD_NO_MEMORY_FOR_LUT :
         return (char*)"not enough memory for LUT allocation";
      case ELIBSTD_CANNOT_CREATE_BUFFER :
         return (char*)"visu can not create buffer";
      case ELIBSTD_CANT_GETORCREATE_TKIMAGE :
         return (char*)"visu can not get or create TkImage";
      case ELIBSTD_NO_ASSOCIATED_BUFFER :
         return (char*)"visu has no associated buffer";
      case ELIBSTD_NO_TKPHOTO_HANDLE :
         return (char*)"can not find TkPhotoHandle";
      case ELIBSTD_NO_MEMORY_FOR_DISPLAY :
         return (char*)"not enough memory for image transformation";
      case ELIBSTD_WIDTH_POSITIVE :
         return (char*)"width must be positive";
      case ELIBSTD_X1X2_NOT_IN_1NAXIS1 :
         return (char*)"x1 and x2 must be contained between 1 and naxis1";
      case ELIBSTD_HEIGHT_POSITIVE :
         return (char*)"height must be positive";
      case ELIBSTD_Y1Y2_NOT_IN_1NAXIS2 :
         return (char*)"y1 and y2 must be contained between 1 and naxis2";
      case ELIBSTD_PALETTE_CANT_FIND_FILE:
         return (char*)"can't find palette file";
      case ELIBSTD_PALETTE_MALFORMED_FILE:
         return (char*)"the palette file doesn't contain 3 numbers per line";
      case ELIBSTD_PALETTE_NOTCOMPLETE:
         return (char*)"the palette file doesn't contain 256 entries";
      case ELIBSTD_NO_KWDS:
         return (char*)"image does not contain any keyword";
      case ELIBSTD_CANT_OPEN_FILE:
	   	return (char*)"can't open file";
      case ELIBSTD_NOT_IMPLEMENTED:
	   	return (char*)"not implemented";
      case EFITSKW_NO_SUCH_KWD:
	   	return (char*)"no such keyword";
      default :
         return (char*)"unknown error code";
   }
}


