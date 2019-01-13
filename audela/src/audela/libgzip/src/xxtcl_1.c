/* xxtcl_1.c
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

/***************************************************************************/
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers xx_*.c.                              */
/***************************************************************************/
/* Le include xxtcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "xxtcl.h"

int Cmd_xxtcl_gzip(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* algo gzip                                                                */
/****************************************************************************/
/****************************************************************************/
{   
   int result,nb,errno,nbf,k,isfile;
   char lignetcl[50024];
   char **argvv=NULL;
   int argcc;

   /* --- extraction de l'argument de nom de fichiers ---*/
   if (argc==1) {
      strcpy(lignetcl,"set gzip_argv1 *");
   } else {
      sprintf(lignetcl,"set gzip_argv1 \"%s\"",argv[1]);
   }
   Tcl_Eval(interp,lignetcl);
   /* --- verifie que les fichiers existent ---*/
   sprintf(lignetcl,"set gzip_a [catch {set gzip_dir \"[glob $gzip_argv1]\"}]");
   Tcl_Eval(interp,lignetcl);
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&errno); 
   if (errno==1) {
      /* --- les fichiers n'existent pas ---*/
      /* --- verifie que les fichiers argv[1].gz existent ---*/
      strcpy(lignetcl,"set gzip_argv1 \"${gzip_argv1}.gz\"");
      Tcl_Eval(interp,lignetcl);
      sprintf(lignetcl,"set gzip_a \"[catch {set gzip_dir [glob $gzip_argv1]}]\"");
      Tcl_Eval(interp,lignetcl);
      Tcl_GetInt(interp,Tcl_GetStringResult(interp),&errno); 
      if (errno==1) {
         /* --- les fichiers n'existent pas. On arrete la ---*/
         strcpy(lignetcl,"0");
         Tcl_SetResult(interp,lignetcl,TCL_VOLATILE);
         return TCL_OK;
      }
   }
   /* --- on traite les fichiers qui existent ---*/
   strcpy(lignetcl,"llength $gzip_dir");
   Tcl_Eval(interp,lignetcl);
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&nbf); 
   nb=0;
   for (k=0;k<nbf;k++) {
      sprintf(lignetcl,"set gzip_name \"[lindex $gzip_dir %d]\"",k);
      Tcl_Eval(interp,lignetcl);
      strcpy(lignetcl,"set gzip_isfile [file isfile \"$gzip_name\"]");
      Tcl_Eval(interp,lignetcl);
      Tcl_GetInt(interp,Tcl_GetStringResult(interp),&isfile); 
      if (isfile==1) {
         strcpy(lignetcl,"set gzip_name");
         Tcl_Eval(interp,lignetcl);
	 if (argv[0][0]==':') {
	    sprintf(lignetcl,"%s \"%s\"",strndup(argv[0]+2,strlen(argv[0])),Tcl_GetStringResult(interp));
	 } else {
            sprintf(lignetcl,"%s \"%s\"",argv[0],Tcl_GetStringResult(interp));
	 }
         Tcl_SplitList(interp,lignetcl,&argcc,(char***)&argvv);
         result=gzipmain(argcc,argvv);
         if (result!=2) {
            nb++;
         }
         if (argvv!=NULL) {
            Tcl_Free((char *) argvv);
         }
      }
   }
   sprintf(lignetcl,"%d",nb);
   Tcl_SetResult(interp,lignetcl,TCL_VOLATILE);
   return TCL_OK;
}
