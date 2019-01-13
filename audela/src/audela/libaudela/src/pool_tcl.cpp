/* pool_tcl.cpp
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

#include <string>
#include <string.h>   // strcat
#include <stdlib.h>   // atoi
#include "tcl.h"

#include "libstd.h"	// CmdBuf
#include "cpool.h"
#include "cbuffer.h"
#include "cerror.h"

//------------------------------------------------------------------------------
// Commandes externes TCL pour gerer des listes de devices
//
int CmdCreatePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdListPoolItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdDeletePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdAvailablePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdGetGenericNamePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

// fonctions locales 
void threadSendCommand(Tcl_Interp *interp, char * deviceThreadId, char* command) {
   std::string ligne;
   ligne.append("thread::send ").append((char*)deviceThreadId);
   ligne.append(" [list ").append(command).append("]");
   if ( Tcl_Eval(interp, ligne.c_str()) == TCL_ERROR) {
      // je retourne un message d'erreur
      std::string errorMessage;
      errorMessage.append("Command=").append(ligne);
      errorMessage.append("Error=").append(Tcl_GetStringResult(interp));
      throw CError(errorMessage.c_str());
   }
}

int threadAliasCommand(ClientData deviceThreadId, Tcl_Interp *interp, int argc, char *argv[]) {
   std::string ligne ;
   ligne.append("thread::send ").append((char*)deviceThreadId).append(" {");
   for (int i=0;i<argc;i++) {
      ligne.append(" {").append( argv[i]).append("}");
   }
   ligne.append(" }");
   return Tcl_Eval(interp, ligne.c_str());
}

int CmdListPoolItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   CDevice *device;
   char *ligne;
   char item[10];

   device = ((CPool*)clientData)->dev;
   ligne = (char*)calloc(200,sizeof(char));
   strcpy(ligne,"");
   if(argc==1) {
      while(device) {
         sprintf(item,"%d ",device->no);
         strcat(ligne,item);
         device = device->next;
      }
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      sprintf(ligne,"Usage: %s",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   free(ligne);
   return TCL_OK;
}

int CmdDeletePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int numero;
   char *ligne;
   CPool *pool;
   CDevice *toto;
   char*classname;
   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(200,sizeof(char));
   if(argc==2) {
      if(Tcl_GetInt(interp,argv[1],&numero)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %snum\n%snum must dbe an integer",argv[0],classname,classname);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_OK;
      }
      toto = pool->Chercher(numero);
      if(toto) {
         // je deconnecte le device
         if ( strcmp(classname,"buf") != 0 ) {
            sprintf(ligne,"catch {%s%d close}",classname,numero);
            Tcl_Eval(interp,ligne);
            Tcl_SetResult(interp,(char*)"",TCL_VOLATILE);
         } 
         // je supprime la commande TCL du device
         sprintf(ligne,"%s%d",classname,numero);
			Tcl_DeleteCommand(interp,ligne);
         // je supprime l'alias TCL de l'unique commande de la librairie
         if ( strlen(toto->libraryName) > 0 ) {
            Tcl_DeleteCommand(interp,toto->libraryName);
         }
         // je supprime le thread
         if ( strlen(toto->deviceThreadId) > 0 ) {
            sprintf(ligne,"thread::release %s", toto->deviceThreadId);
            Tcl_Eval(interp, ligne);                  
         }
         pool->RetirerDev(toto);
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

int CmdGetGenericNamePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result;
   char *ligne;
   CPool *pool;
   char*classname;
   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(200,sizeof(char));
   if(argc==2) {
      // chargement de la lib'argv[1]'
      sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"", Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY), argv[1]);
      if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
         sprintf(ligne,"Error: %s", Tcl_GetStringResult(interp));
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         free(ligne);
         return TCL_ERROR;
      } else {
         sprintf(ligne,"%s genericname",argv[1]);
         result = Tcl_Eval(interp,ligne);
      }
   } else {
      sprintf(ligne,"Usage: %s liblink_driver ?options?",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   free(ligne);
   return result;
}

int CmdAvailablePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int result;
   char *ligne;
   CPool *pool;
   char*classname;
   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   ligne = (char*)calloc(500,sizeof(char));
   if(argc==2) {
      // chargement de la lib'argv[1]'

      sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"", Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY), argv[1]);
      if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
         sprintf(ligne,"Error: %s", Tcl_GetStringResult(interp));
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         sprintf(ligne,"%s available",argv[1]);
         Tcl_Eval(interp,ligne);
         result = TCL_OK;
      }
   } else {
      sprintf(ligne,"Usage: %s driver_name ?options?",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   free(ligne);
   return result;
}



#define ENREGISTRER_CMD(cmd) {sprintf(ligne,"%s%d",classname,toto->no);\
 Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)(cmd),(ClientData)toto,(Tcl_CmdDeleteProc*)NULL);}

#define CASE_BUFFER    1
#define CASE_VISU      2
#define CASE_CAMERA    3
#define CASE_TELESCOPE 4
#define CASE_LINK      5

int CmdCreatePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int numero;
   char ligne[1024];
   CPool *pool;
   CDevice *toto=NULL;
   
   char *classname;
   int CASE=0;
   int dontCreateCommand = 0;
   int retour,kk;
   char s[256];

   pool = (CPool*)clientData;
   classname = pool->GetClassname();
   strcpy(s,"");

   if(strcmp(classname,BUF_PREFIXE)==0)         CASE = CASE_BUFFER;
   else if(strcmp(classname,CAM_PREFIXE)==0)    CASE = CASE_CAMERA;
   else if(strcmp(classname,TEL_PREFIXE)==0)    CASE = CASE_TELESCOPE;
   else if(strcmp(classname,LINK_PREFIXE)==0)   CASE = CASE_LINK;

   switch(CASE) {
      case CASE_BUFFER :
         if(argc>2) {
            sprintf(ligne,"Usage: %s ?%snum?",argv[0],classname);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            numero = 0;
            if((argc==2)&&(Tcl_GetInt(interp,argv[1],&numero)!=TCL_OK)) {
               sprintf(ligne,"Usage: %s ?%snum?\n%snum must be an integer > 0",argv[0],classname,classname);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            }
            CBuffer *newBuffer = CBuffer::createBuffer();
            toto = newBuffer;
            if(newBuffer)  {
               sprintf(ligne,"%s%d",classname,newBuffer->no);
               Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)(CmdBuf),(ClientData)toto,(Tcl_CmdDeleteProc*)NULL);
            }
         }
         break;

      case CASE_CAMERA :
         if(argc<2) {
            sprintf(ligne,"Usage: %s libcam_driver ?options?",argv[0]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            try {
               // Lecture du numero de camera voulu
               numero = 0;
               if (argc>=5) {
                  for (kk=3;kk<argc-1;kk++) {
                     if (strcmp(argv[kk],"-num")==0) {
                        numero=(int)atoi(argv[kk+1]);
                        if (numero<1) { numero=1; }
                     }
                  }
               }
               // Instancie de l'objet en fonction de la camera demandee
               toto = new CDevice();
               pool->Ajouter(numero,toto);
               dontCreateCommand = 1;

               // je cree le thread de la camera
               sprintf(ligne, "thread::create");
               if ( Tcl_Eval(interp, ligne) == TCL_ERROR) {
                  // je retourne un message d'erreur
                  char errorMessage[5000];
                  sprintf(errorMessage,"Error thread::create for %s : %s",argv[0], Tcl_GetStringResult(interp));
                  throw CError(errorMessage);
               }

               //je recupere l'identifiant du thread 
               strcpy(toto->deviceThreadId,Tcl_GetStringResult(interp));

               // je charge la librairie du telescope dans le thread de la camera
               sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"  ",  Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY), argv[1]);
               threadSendCommand(interp, toto->deviceThreadId, ligne);                
               // je charge la librairie libmc dans le thread
               sprintf(ligne,"load \"%s/libmc[info sharedlibextension]\"  ",  Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY));
               threadSendCommand(interp, toto->deviceThreadId, ligne);   

               // je cree la nouvelle commande par le biais de l'unique
               // commande exportee de la librairie libcam.
               sprintf(ligne,"%s cam%d {%s} ",argv[1],toto->no,argv[2]);
               for (kk=0;kk<argc;kk++) {
                  strcat(ligne," {");
                  strcat(ligne,argv[kk]);
                  strcat(ligne,"}");
               }
               // j'ajoute le numero du thread principal en dernier parametre
               strcat(ligne," mainThreadId ");
               Tcl_Eval(interp, "thread::id"); 
               strcat(ligne, Tcl_GetStringResult(interp));
               threadSendCommand(interp, toto->deviceThreadId, ligne);

               // Cree la nouvelle commande par le biais de l'unique
               // commande exportee de la librairie libcam.
               sprintf(ligne,"%s cam%d {%s} ",argv[1],toto->no,argv[2]);
               for (kk=0;kk<argc;kk++) {
                  strcat(ligne," {");
                  strcat(ligne,argv[kk]);
                  strcat(ligne,"}");
               }
               //if (Tcl_Eval(interp,ligne)==TCL_OK) {
               //   sprintf(ligne,"cam%d channel",toto->no);
               //   if (Tcl_Eval(interp,ligne)==TCL_OK) {
               //      strcpy(toto->channel,Tcl_GetStringResult(interp));
               //   } else {
               //      strcpy(toto->channel,"");
               //   }
               //   break;
               //} else {
               //   strcpy(s,Tcl_GetStringResult(interp));
               //   sprintf(ligne,"::cam::delete %d",toto->no);
               //   Tcl_Eval(interp,ligne);
               //   toto=NULL;
               //   break;
               //}

               // je cree une commande "libraryName" (=argv[1]) dans le thread principal 
               // qui appelle la commande "libraryName" argv[1] dans le thread du device
               strcpy(toto->libraryName, argv[1]);
               Tcl_CreateCommand(interp,argv[1],(Tcl_CmdProc *)threadAliasCommand,(ClientData)toto->deviceThreadId,NULL);
               // je cree une commande tel1 dans le thread principal qui appelle la commande tel1 dans le thread du telescope
               sprintf(ligne, "cam%d",toto->no); 
               Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)threadAliasCommand,(ClientData)toto->deviceThreadId,NULL);

            } catch(const CError& e) {
               // je libere les ressources
               if ( strlen(toto->deviceThreadId) > 0 ) {
                  // je supprime le thread
                  sprintf(ligne,"thread::release %s", toto->deviceThreadId);
                  Tcl_Eval(interp, ligne);                  
               }
               pool->RetirerDev(toto);

               // je copie le message d'erreur dans le resultat TCL
               Tcl_SetResult(interp,(char*) e.gets(),TCL_VOLATILE);
               return TCL_ERROR;		
            }
         }
         break;

      case CASE_TELESCOPE :
         if(argc<3) {
            sprintf(ligne,"Usage: %s libtel_driver ?options?",argv[0]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            
            try {
               // Lecture du numero de telescope voulu
               numero = 0;
               if (argc>=5) {
                  for (kk=3;kk<argc-1;kk++) {
                     if (strcmp(argv[kk],"-num")==0) {
                        numero=(int)atoi(argv[kk+1]);
                        if (numero<1) { numero=1; }
                     }
                  }
               }
               // Instancie de l'objet en fonction du telescope demande
               toto = new CDevice();
               pool->Ajouter(numero,toto);
               dontCreateCommand = 1;

               // je cree le thread  du telescope
               sprintf(ligne, "thread::create");
               if ( Tcl_Eval(interp, ligne) == TCL_ERROR) {
                  // je retourne un message d'erreur
                  char errorMessage[5000];
                  sprintf(errorMessage,"Error thread::create for %s : %s",argv[0], Tcl_GetStringResult(interp));
                  throw CError(errorMessage);
               }

               //je recupere l'identifiant du thread 
               strcpy(toto->deviceThreadId,Tcl_GetStringResult(interp));

               // je charge la librairie du telescope dans le thread de la camera
               sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"  ", Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY), argv[1]);
               threadSendCommand(interp, toto->deviceThreadId, ligne);                
               // je charge la librairie libmc dans le thread
               sprintf(ligne,"load \"%s/libmc[info sharedlibextension]\"  ", Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY));
               threadSendCommand(interp, toto->deviceThreadId, ligne);   

               // Cree la nouvelle commande par le biais de l'unique
               // commande exportee de la librairie libtel.
               sprintf(ligne,"%s tel%d {%s} ",argv[1],toto->no,argv[2]);
               for (kk=0;kk<argc;kk++) {
                  strcat(ligne," {");
                  strcat(ligne,argv[kk]);
                  strcat(ligne,"}");
               }
               // j'ajoute le numero du thread principal en dernier parametre
               strcat(ligne," mainThreadId ");
               Tcl_Eval(interp, "thread::id"); 
               strcat(ligne, Tcl_GetStringResult(interp));
               threadSendCommand(interp, toto->deviceThreadId, ligne);

               //if (Tcl_Eval(interp,ligne)==TCL_OK) {
               //   sprintf(ligne,"tel%d channel",toto->no);
               //   if (Tcl_Eval(interp,ligne)==TCL_OK) {
               //      strcpy(toto->channel,Tcl_GetStringResult(interp));
               //   } else {
               //      strcpy(toto->channel,"");
               //   }
               //   break;
               //} else {
               //   strcpy(s,Tcl_GetStringResult(interp));
               //   sprintf(ligne,"::tel::delete %d",toto->no);
               //   Tcl_Eval(interp,ligne);
               //   toto=NULL;
               //   break;
               //}

               // je cree une commande "libraryName" (=argv[1]) dans le thread principal 
               // qui appelle la commande "libraryName" argv[1] dans le thread du telescope
               strcpy(toto->libraryName, argv[1]);
               Tcl_CreateCommand(interp,argv[1],(Tcl_CmdProc *)threadAliasCommand,(ClientData)toto->deviceThreadId,NULL);
               // je cree une commande tel1 dans le thread principal qui appelle la commande tel1 dans le thread du telescope
               sprintf(ligne, "tel%d",toto->no); 
               Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)threadAliasCommand,(ClientData)toto->deviceThreadId,NULL);
               

            } catch(const CError& e) {
               // je libere les ressources
               if ( strlen(toto->deviceThreadId) > 0 ) {
                  // je supprime le thread
                  sprintf(ligne,"thread::release %s", toto->deviceThreadId);
                  Tcl_Eval(interp, ligne);                  
               }
               pool->RetirerDev(toto);

               // je copie le message d'erreur dans le resultat TCL
               Tcl_SetResult(interp,(char*)e.gets(),TCL_VOLATILE);
               return TCL_ERROR;		
            }

         }
         break;
      case CASE_LINK :
         if(argc<3) {
            sprintf(ligne,"Usage: %s liblink_driver devicename",argv[0]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            // chargement de la lib'argv[1]'
            sprintf(ligne,"load \"%s/lib%s[info sharedlibextension]\"",  Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY), argv[1]);
            if(Tcl_Eval(interp,ligne)==TCL_ERROR) {
               sprintf(ligne,"Error: %s", Tcl_GetStringResult(interp));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               toto = ((CPool*)clientData)->dev;
               // je cherche si le link est deja cree (link avec le meme nom)
               while(toto) {
                  sprintf(ligne,"::link%d name",toto->no);
                  if (Tcl_Eval(interp,ligne)==TCL_OK) {
                     if( strcmp(argv[2], Tcl_GetStringResult(interp))==0) {
                        // le link existe deja , je retourne son numero
                        sprintf(ligne,"%d", toto->no);
                        Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                        return TCL_OK;
                     }

                  }
                  toto = toto->next;
               }

               // je cherche le premier numero de link libre (certains link peuvent etre cree en TCL)
               int linkNo = -1; 
               while( linkNo == -1) {
                  sprintf(ligne,"lindex [::link%d drivername] 0",linkNo);
                  if (Tcl_Eval(interp,ligne)==TCL_ERROR ) {
                     // le link n'existe pas , je vais utiliser ce numero
                     break;
                  }
                  linkNo += 1;
               }

               // Instancie de l'objet en fonction du link demande
               toto = new CDevice();
               pool->Ajouter(0,toto);
               // Cree la nouvelle commande par le biais de l'unique
               // commande exportee de la librairie liblink.
               sprintf(ligne,"%s link%d {%s} ",argv[1],toto->no,argv[2]);
               for (kk=0;kk<argc;kk++) {
                  strcat(ligne," {");
                  strcat(ligne,argv[kk]);
                  strcat(ligne,"}");
               }
               if (Tcl_Eval(interp,ligne)==TCL_OK) {
                  sprintf(ligne,"link%d channel",toto->no);
                  if (Tcl_Eval(interp,ligne)==TCL_OK) {
                     strcpy(toto->channel,Tcl_GetStringResult(interp));
                  } else {
                     strcpy(toto->channel,"");
                  }
                  break;
               } else {
                  strcpy(s,Tcl_GetStringResult(interp));
                  sprintf(ligne,"::link::delete %d",toto->no);
                  Tcl_Eval(interp,ligne);
                  toto=NULL;
                  break;
               }
            }
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
   return retour;
}

#undef AJOUTER
#undef ENREGISTRER_CMD
