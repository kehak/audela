/* tt_seri1.c
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





int tt_fct_ima_series(void *arg1)
/***************************************************************************/
/* Fonction generale pour les series d'images.                             */
/***************************************************************************/
/* Cette fonction sert a synthetiser une image a partir d'une serie        */
/* d'images de memes dimensions.                                           */
/*                                                                         */
/* # Pour la programmation :                                               */
/* -------------------------                                               */
/*                                                                         */
/* L'ajout d'une fonction consiste a effectuer un appel dans la partie :   */
/* 'Calcul de l'image finale pour la zone concernee'                       */
/*                                                                         */
/* # Pour l'utilisation :                                                  */
/* ----------------------                                                  */
/*                                                                         */
/* void *arg1 est une chaine de caracteres contenant un ligne de commandes */
/*  dont le codage doit etre realise ainsi :                               */
/*                                                                         */
/* Le codage est une suite d'arguments separes par des blancs. Si l'on ne  */
/* veut pas designer l'arguement, mettre un point.                         */
/* Les 11 premiers arguments sont obligatoires dans l'ordre suivant :      */
/*                                                                         */
/*  1) Obligatoirement IMA/SERIES, nom de la fonction.                     */
/*  2) Nom du chemin d'acces aux images a traiter. La barre finale est     */
/*     automatiquement rajoutee si elle manque.                            */
/*     Placer un point si on cherche les images a traiter dans le chemin   */
/*     courant.                                                            */
/*  3) Nom generique (sans indice) de l'image a traiter.                   */
/*  4) Valeur de l'indice de la 1ere image a traiter.                      */
/*     NB : s'il n'y a qu'une seule image qui n'a pas d'indice alors       */
/*     mettre un point pour les arguments 4) et 5).                        */
/*  5) Valeur de l'indice de la derniere image a traiter.                  */
/*     NB : si les indices sont precedes de ; alors cela signifie que      */
/*     l'on demande d'acceder au fichier de nom defini par l'argument 3)   */
/*     et que l'on va explorer les images contenues dans les entetes       */
/*     etendues (HDUs de la norme FITS) de numeros 4) a 5).                */
/*  6) Nom de l'extension du fichier. Le point n'est pas automatiquement   */
/*     rajoute. Ainsi pour l'image toto.fits, indiquer .fits pour 6).      */
/*     NB : si l'extension est .mt alors les indices sont formates selon   */
/*     la avec quatre digits de 0001 a 9999.                               */
/*  7) Nom du chemin d'acces aux images traitees. La barre finale est      */
/*     automatiquement rajoutee si elle manque.                            */
/*  8) Nom generique (sans indice) des images traitees.                    */
/*  9) Valeur de l'indice de la premiere image traitee.                    */
/*     NB : si les indices sont precedes de ; alors cela signifie que      */
/*     l'on demande d'acceder au fichier de nom defini par l'argument 3)   */
/*     et que l'on va ajouter l'image traitee apres l'entete de numero 9). */
/*     NB : si l'on ne veut pas d'indice alors mettre un point pour 9).    */
/* 10) Nom de l'extension des fichiers. Le point n'est pas automatiquement */
/*     rajoute. Ainsi pour l'image toto.fits, indiquer .fits pour 6).      */
/*     NB : si l'extension est .mt alors les indices sont formates selon   */
/*     la avec quatre digits de 0001 a 9999.                               */
/* 11) Nom de la sous-fonction a utiliser.                                 */
/*     SUB : soustrait une image a la serie                                */
/*                                                                         */
/* Les arguements suivants peuvent apparaitre dans n'importe quel ordre.   */
/*                                                                         */
/* Le parametre optionel 'bitpix' permet de choisir la valeur de BITPIX    */
/* pour les images de sortie :                                             */
/*  bitpix=8   pour (unsigned char)                                        */
/*  bitpix=16  pour (short)                                                */
/*  bitpix=+16 pour (unsigned short)                                       */
/*  bitpix=32  pour (int)                                                  */
/*  bitpix=+32 pour (unsigned int)                                         */
/*  bitpix=-32 pour (float)                                                */
/*  bitpix=-64 pour (double)                                               */
/*                                                                         */
/* Le parametre optionel 'jpegfile' permet de generer une image JPEG en    */
/* plus de l'image FITS de sortie (meme nom).                              */
/*                                                                         */
/* Le parametre optionel 'skylevel' permet de stocker la valeur du fond de */
/* avant traitement dans l'entete de l'image de sortie.                    */
/*                                                                         */
/* Les autres parametres dependent de la sous-fonction.                    */
/***************************************************************************/
{
   int msg;
   char **keys,*ligne,fonction[80];
   int nbkeys;
   int load_indice_fin,load_indice_deb,save_indice_deb;
   int load_level_index; /* =0 si pas d'indices */
   /* =1 pour un indice dans le nom */
   /* =2 pour un indice d'entete avec le meme nom */
   int save_level_index;
   int k;
   int pos;
   char *car;
   char mot[1000];
   char *argu = NULL;
   char tmp_dir[FLEN_FILENAME]=".";
   TT_IMA_SERIES_OPTION options;

   /* ======================================== */
   /* === decodage de la ligne d'arguments === */
   /* ======================================== */
   ligne=(char*)arg1;
   /*printf("<%s>\n",ligne);*/
   tt_decodekeys(ligne,(void***)&keys,&nbkeys);

   /* ============================================== */
   /* === decodage du parametre optionel tmp_dir === */
   /* ============================================== */
   /* --- tmp_dir pour les fichiers .log et .err --- */
   for (k=11;k<nbkeys;k++) {
      /* --- extrait le mot cle ( 999 caracteres au maximum )---*/
      strncpy(mot,keys[k], 999);
      tt_strupr(mot);
      car=strstr(mot,"=");
      pos=0;
      argu= malloc(strlen(keys[k]));
      if (argu!=NULL) {
         if (car!=NULL) {
            pos=(int)(car-mot);
            mot[pos]='\0';
            strcpy(argu,keys[k]+pos+1);
         } else {
            /* --- mot sans argument ---*/
            strcpy(argu,"");
         }
         if (strcmp(mot,"TMP_DIR")==0) {
            if (strcmp(argu,"")!=0) {
               strcpy(tmp_dir,argu);
            }
         }
         free(argu);
         argu = NULL;
      }
   }
   tt_util_tmp_dir(tmp_dir);

   /* ================================== */
   /* === verification des arguments === */
   /* ================================== */
   tt_writelog(tmp_dir,ligne);
   /* --- 0 :mot cle ---*/
   tt_strupr(keys[0]);
   if (strcmp(keys[0],"IMA/SERIES")!=0) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(tmp_dir,TT_ERR_FCT_IS_NOT_AS_SERVICE,NULL);
      return(TT_ERR_FCT_IS_NOT_AS_SERVICE);
   }
   if (nbkeys<11) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(tmp_dir,TT_ERR_NOT_ENOUGH_ARGUS,NULL);
      return(TT_ERR_NOT_ENOUGH_ARGUS);
   }
   /* --- 1 a 5 : fichiers in ---*/
   if ((msg=tt_verifargus_2indices(keys,1,&load_level_index,&load_indice_deb,&load_indice_fin))!=TT_YES) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(tmp_dir,msg,"Pb in input image indexes");
      return(msg);
   }
   if (load_level_index==0) { load_indice_fin=0; load_indice_deb=0; }

   /* --- 6 a 9 : fichiers out ---*/
   if ((msg=tt_verifargus_1indice(keys,6,&save_level_index,&save_indice_deb))!=TT_YES) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_errlog(tmp_dir,msg,"Pb in output image index");
      return(msg);
   }
   /* --- 10 : nom de la fonction de serie ---*/
   tt_strupr(keys[10]);
   strcpy(fonction,keys[10]);

   /*
   for (k=0;k<nbkeys;k++) {printf("keys[%d]=<%s>\n",k,keys[k]);}
   printf("load_level_index=%d load_indice_deb=%d load_indice_fin=%d\n",load_level_index,load_indice_deb,load_indice_fin);
   printf("save_level_index=%d save_indice_deb=%d\n",save_level_index,save_indice_deb);
   */

   /* --- 11 : options ---*/
   tt_ima_series_builder2(&options);
   tt_ima_series_builder3(nbkeys-11, &(keys[11]), tmp_dir, &options);

   msg = abtt_imageSeries(keys[1], keys[2], load_indice_deb, load_indice_fin, load_level_index, keys[5],  keys[6], keys[7], save_indice_deb, save_level_index, keys[9], fonction, &options);
   tt_util_free_ptrptr((void**)keys,"keys");


   return msg; 
}

/***************************************************************************/  
/*  2) Nom du chemin d'acces aux images a traiter. La barre finale est     */
/*     automatiquement rajoutee si elle manque.                            */
/*     Placer un point si on cherche les images a traiter dans le chemin   */
/*     courant.                                                            */
/*  3) Nom generique (sans indice) de l'image a traiter.                   */
/*  4) Valeur de l'indice de la 1ere image a traiter.                      */
/*     NB : s'il n'y a qu'une seule image qui n'a pas d'indice alors       */
/*     mettre un point pour les arguments 4) et 5).                        */
/*  5) Valeur de l'indice de la derniere image a traiter.                  */
/*     NB : si les indices sont precedes de ; alors cela signifie que      */
/*     l'on demande d'acceder au fichier de nom defini par l'argument 3)   */
/*     et que l'on va explorer les images contenues dans les entetes       */
/*     etendues (HDUs de la norme FITS) de numeros 4) a 5).                */
/*  6) Nom de l'extension du fichier. Le point n'est pas automatiquement   */
/*     rajoute. Ainsi pour l'image toto.fits, indiquer .fits pour 6).      */
/*     NB : si l'extension est .mt alors les indices sont formates selon   */
/*     la avec quatre digits de 0001 a 9999.                               */
/*  7) Nom du chemin d'acces aux images traitees. La barre finale est      */
/*     automatiquement rajoutee si elle manque.                            */
/*  8) Nom generique (sans indice) des images traitees.                    */
/*  9) Valeur de l'indice de la premiere image traitee.                    */
/*     NB : si les indices sont precedes de ; alors cela signifie que      */
/*     l'on demande d'acceder au fichier de nom defini par l'argument 3)   */
/*     et que l'on va ajouter l'image traitee apres l'entete de numero 9). */
/*     NB : si l'on ne veut pas d'indice alors mettre un point pour 9).    */
/* 10) Nom de l'extension des fichiers. Le point n'est pas automatiquement */
/*     rajoute. Ainsi pour l'image toto.fits, indiquer .fits pour 6).      */
/*     NB : si l'extension est .mt alors les indices sont formates selon   */
/*     la avec quatre digits de 0001 a 9999.                               */
/* 11) Nom de la sous-fonction a utiliser.                                 */
/*     SUB : soustrait une image a la serie                                */
/*                                                                         */
/* Les arguements suivants peuvent apparaitre dans n'importe quel ordre.   */
/*                                                                         */
/* Le parametre optionel 'bitpix' permet de choisir la valeur de BITPIX    */
/* pour les images de sortie :                                             */
/*  bitpix=8   pour (unsigned char)                                        */
/*  bitpix=16  pour (short)                                                */
/*  bitpix=+16 pour (unsigned short)                                       */
/*  bitpix=32  pour (int)                                                  */
/*  bitpix=+32 pour (unsigned int)                                         */
/*  bitpix=-32 pour (float)                                                */
/*  bitpix=-64 pour (double)                                               */
/*                                                                         */
/* Le parametre optionel 'jpegfile' permet de generer une image JPEG en    */
/* plus de l'image FITS de sortie (meme nom).                              */
/*                                                                         */
/* Le parametre optionel 'skylevel' permet de stocker la valeur du fond de */
/* avant traitement dans l'entete de l'image de sortie.                    */
/*                                                                         */
/* Les autres parametres dependent de la sous-fonction.                    */
/***************************************************************************/   

int abtt_imageSeries (char * load_path, 
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
                   ) 
{
   int msg;
   int kk;
   char fullname[(FLEN_FILENAME)+5];
   char fullname0[(FLEN_FILENAME)+5];
   int index_out;
   char message[TT_MAXLIGNE];
   char date_obs_stack[FLEN_VALUE];
   TT_IMA_SERIES pseries;
   int nbima;
   
   strcpy(pseries.tmp_dir,".");
   
   /* ======================= */
   /* === controle de parametres === */
   /* ======================= */
   if( load_path == NULL) {
      msg = TT_ERR_NULL_PARAMETER;
      tt_errlog(pseries.tmp_dir,msg,"load_path is null");
      return(msg);
   }
   if( load_file_name == NULL) {
      msg = TT_ERR_NULL_PARAMETER;
      tt_errlog(pseries.tmp_dir,msg,"load_file_name is null");
      return(msg);
   }
   if( load_extension == NULL) {
      msg = TT_ERR_NULL_PARAMETER;
      tt_errlog(pseries.tmp_dir,msg,"load_extension is null");
      return(msg);
   }
   if( save_path == NULL) {
      msg = TT_ERR_NULL_PARAMETER;
      tt_errlog(pseries.tmp_dir,msg,"save_path is null");
      return(msg);
   }
   if( save_file_name == NULL) {
      msg = TT_ERR_NULL_PARAMETER;
      tt_errlog(pseries.tmp_dir,msg,"save_file_name is null");
      return(msg);
   }
   if( save_extension == NULL) {
      msg = TT_ERR_NULL_PARAMETER;
      tt_errlog(pseries.tmp_dir,msg,"save_extension is null");
      return(msg);
   }
   if( fonction == NULL) {
      msg = TT_ERR_NULL_PARAMETER;
      tt_errlog(pseries.tmp_dir,msg,"fonction is null");
      return(msg);
   }
   
   
   /* ======================= */
   /* === initialisations === */
   /* ======================= */
   nbima=1+load_indice_fin-load_indice_deb;
   if ((msg=tt_ima_series_builder(fonction, nbima, options, &pseries))!=OK_DLL) {
      return(msg);
   }
  
   /* =================================== */
   /* === boucle de la premiere passe === */
   /* =================================== */

   /* --- boucle sur les images ---*/
   for (kk=load_indice_deb;kk<=load_indice_fin;kk++) {
      
      pseries.index=1+kk-load_indice_deb;
      /* --- cree le fullname in ---*/
      if (load_level_index==1) {
         strcpy(fullname,tt_indeximafilecater(load_path,load_file_name,kk,load_extension));
      } else if (load_level_index==2) {
         sprintf(fullname,"%s;%d",tt_imafilecater(load_path,load_file_name,load_extension),kk);
      } else if (load_level_index==3) {
         char filename[(FLEN_FILENAME)+5];
         if ( tt_verifargus_getFileName(load_file_name,kk,filename) == 1 ) {
            strcpy(fullname,tt_imafilecater(load_path,filename,load_extension));
         } else {
            tt_errlog(pseries.tmp_dir,msg,"bad file name");
            return(TT_ERR_NOT_ALLOWED_FILENAME);
         }
      } else {
         sprintf(fullname,"%s",tt_imafilecater(load_path,load_file_name,load_extension));
      }
      
      /* --- charge l'image ---*/
      if ((msg=tt_ima_series_loader_0(&pseries,fullname))!=0) {
         tt_ima_series_destroyer(&pseries);
         return(msg);
      }
      strcpy(fullname0,fullname);
      
      /* --- appel du dispatcher de fonctions et des calculs ---*/
      pseries.index_out=0;
      msg=tt_ima_series_dispatch(fonction, &pseries);
      
      /* --- traite les erreurs ---*/
      if (msg!=OK_DLL) {
         tt_ima_series_destroyer(&pseries);
         return(msg);
      }
      
      /* --- cree, calcule et sauve l'image finale ---*/
      if ((pseries.numfct!=0)&&(pseries.numfct!=TT_IMASERIES_DELETE)) {
         /* --- cree le fullname out ---*/
         if (pseries.index_out==0) {
            /* cas ou les indices de sortie sont dans l'ordre */
            index_out=kk-load_indice_deb+save_indice_deb;
         } else {
            /* cas ou les indices de sortie ne sont pas dans l'ordre */
            index_out=pseries.index_out-1+save_indice_deb;
         }
         if (save_level_index==0) {
            strcpy(fullname,tt_imafilecater(save_path,save_file_name,save_extension));
         } else if (save_level_index==1) {
            strcpy(fullname,tt_indeximafilecater(save_path,save_file_name,index_out,save_extension));
         } else if (save_level_index==2) {
            sprintf(fullname,"%s;%d",tt_imafilecater(save_path,save_file_name,save_extension),index_out);
         }
         /* --- complete l'entete de l'image a sauver ---*/
         tt_jd2dateobs(pseries.jj_stack,date_obs_stack);
         pseries.jj_stack-=2400000.5;
         tt_imanewkey(pseries.p_out,"MJD-OBS",&(pseries.jj_stack),TDOUBLE,"Start of exposure","d");
         pseries.jj_stack+=2400000.5;
         tt_imanewkey(pseries.p_out,"DATE-OBS",date_obs_stack,TSTRING,"Start of exposure. FITS standard","ISO 8601");
         tt_imanewkey(pseries.p_out,"EXPOSURE",&(pseries.exptime_stack),TDOUBLE,"Total time of exposure","s");
         
         /* --- complete l'entete avec celle de la premiere image ---*/
         if ((msg=tt_imarefheader(pseries.p_out,fullname0))!=0) {
            tt_ima_series_destroyer(&pseries);
            sprintf(message,"Problem concerning file %s for reference keywords",fullname);
            tt_errlog(pseries.tmp_dir,msg,message);
            return(msg);
         }
         
         /* --- complete l'entete avec l'historique de ce traitement ---*/
         if ((msg=tt_ima_series_history(fonction,&pseries))!=OK_DLL) {
            tt_ima_series_destroyer(&pseries);
            sprintf(message,"Problem concerning history");
            tt_errlog(pseries.tmp_dir,msg,message);
            return(msg);
         }
         /* --- sauve l'image et les tables eventuelles ---*/
         if ((msg=tt_ima_series_saver_end(&pseries,fullname))!=0) {
            tt_ima_series_destroyer(&pseries);
            return(msg);
         }
      }
      tt_imadestroyer(pseries.p_out);
      tt_imabuilder(pseries.p_out);
      /* --- on reinitialise l'objet associe a l'image d'entree ---*/
      tt_imadestroyer(pseries.p_in);
      tt_imabuilder(pseries.p_in);
   }
   
   /* ======================================= */
   /* === on libere la memoire et on sort === */
   /* ======================================= */
   tt_ima_series_destroyer(&pseries);
   return(OK_DLL);
}


int tt_ima_series_builder(char* fonction, int nbima, TT_IMA_SERIES_OPTION* options, TT_IMA_SERIES *pseries) {
/***************************************************************************/
/* build  ima/series.                                                      */
/***************************************************************************/
   int msg;
   int taille,nombre;
   int k1,k2;
   TT_IMA_SERIES_OPTION localOptions;

   if ((msg=tt_ima_series_builder1(fonction, pseries))!=OK_DLL) {
      return(msg);
   }
   
   /* --- options ---*/
   if( options== NULL) {
      // si options est nul , j'initialise les options avec les valeurs par defaut
      options = &localOptions;
      tt_ima_series_builder2(options);
   }
   strcpy(pseries->astromcatalog, options->astromcatalog);
   strcpy(pseries->bias, options->bias);
   strcpy(pseries->catafile, options->catafile);
   strcpy(pseries->centroide, options->centroide);
   strcpy(pseries->colfilter, options->colfilter);
   strcpy(pseries->dark, options->dark);
   strcpy(pseries->file, options->file);
   strcpy(pseries->file_ascii, options->file_ascii);
   strcpy(pseries->flat, options->flat);
   strcpy(pseries->jpegfile, options->jpegfile);
   strcpy(pseries->jpegfile_chart, options->jpegfile_chart);
   strcpy(pseries->jpegfile_chart2, options->jpegfile_chart2);
   strcpy(pseries->key_dexptime, options->key_dexptime);
   strcpy(pseries->key_exptime, options->key_exptime);
   strcpy(pseries->keyhicut, options->keyhicut);
   strcpy(pseries->keylocut, options->keylocut);
   strcpy(pseries->keytype, options->keytype);
   strcpy(pseries->nom_trait, options->nom_trait);
   strcpy(pseries->objefile, options->objefile);
   strcpy(pseries->objefiletype, options->objefiletype);
   strcpy(pseries->paramresample, options->paramresample);
   strcpy(pseries->path_astromcatalog, options->path_astromcatalog);
   strcpy(pseries->pixefile, options->pixefile);
   strcpy(pseries->struct_elem, options->struct_elem);

   pseries->angle=options->angle;
   pseries->back_kernel=options->back_kernel;
   pseries->back_threshold=options->back_threshold;
   pseries->background=options->background;
   pseries->bias_level=options->bias_level; /* ADU */
   pseries->binary_yesno=options->binary_yesno;
   pseries->bitpix=options->bitpix;
   pseries->bordure=options->bordure;
   pseries->catalog_list=options->catalog_list;
   pseries->coef_smile2=options->coef_smile2;
   pseries->coef_smile4=options->coef_smile4;
   pseries->coef_unsmearing=options->coef_unsmearing;
   pseries->constant=options->constant;
   pseries->cosmicThreshold=options->cosmicThreshold;
   pseries->cutscontrast=options->cutscontrast;
   pseries->dec=options->dec;
   pseries->delta=options->delta;
   pseries->detect_kappa=options->detect_kappa;
   pseries->div_yesno=options->div_yesno;
   pseries->elecmult=options->elecmult; /* EMCCD multiplicator factor */
   pseries->epsilon=options->epsilon;
   pseries->exposure=options->exposure;
   pseries->fitorder6543=options->fitorder6543;
   pseries->flat_type=options->flat_type; /* 0=no flat */
   pseries->fwhm_compute=options->fwhm_compute;
   pseries->fwhmsat=options->fwhmsat;
   pseries->fwhmx=options->fwhmx;
   pseries->fwhmy=options->fwhmy;
   pseries->gain=options->gain; /* gain de la chaine en electron/ADU */
   pseries->height=options->height;
   pseries->hifrac=options->hifrac;
   pseries->hotPixelList=options->hotPixelList;
   pseries->invert_flip=options->invert_flip;
   pseries->invert_mirror=options->invert_mirror;
   pseries->invert_xy=options->invert_xy;
   pseries->jpeg_qualite=options->jpeg_qualite;
   pseries->jpegfile_chart2_make=options->jpegfile_chart2_make;
   pseries->jpegfile_chart_make=options->jpegfile_chart_make;
   pseries->jpegfile_make=options->jpegfile_make;
   pseries->kernel_coef=options->kernel_coef;
   pseries->kernel_type=options->kernel_type;
   pseries->kernel_width=options->kernel_width;
   pseries->length=options->length;
   pseries->lofrac=options->lofrac;
   pseries->mag=options->mag;
   pseries->magblim=options->magblim;
   pseries->magrlim=options->magrlim;
   pseries->matchwcs=options->matchwcs;
   pseries->nbsubseries=options->nbsubseries;
   pseries->newstar=options->newstar;
   pseries->normaflux=options->normaflux;
   pseries->normgain_value=options->normgain_value;
   pseries->normoffset_value=options->normoffset_value;
   pseries->nullpix_exist=options->nullpix_exist;
   pseries->nullpix_value=options->nullpix_value;
   pseries->object_list=options->object_list;
   pseries->offset=options->offset;
   pseries->oversampling=options->oversampling;
   pseries->percent=options->percent;
   pseries->pixel_list=options->pixel_list;
   pseries->pixelsat_compute=options->pixelsat_compute;
   pseries->pixelsat_value=options->pixelsat_value;
   pseries->pixint=options->pixint;
   pseries->power=options->power;
   pseries->quantum_efficiency=options->quantum_efficiency; /* efficacite quantique d'un pixel en electron/photon */
   pseries->ra=options->ra;
   pseries->radius=options->radius;
   pseries->readout_noise=options->readout_noise; /* electrons */
   pseries->regitrans=options->regitrans;
   pseries->shutter_mode=options->shutter_mode; /* 1=synchro 0=closed 2=opened */
   pseries->sigma_given=options->sigma_given;
   pseries->sigma_value=options->sigma_value;
   pseries->simulimage=options->simulimage;
   pseries->sky_brightness=options->sky_brightness; /* brillance du ciel en mag/arcsec2 */
   pseries->skylevel_compute=options->skylevel_compute;
   pseries->sub_yesno=options->sub_yesno;
   pseries->tatm=options->tatm; /* atmospheric transmission at observed elevation */
   pseries->teldiam=options->teldiam; /* diametre du telescope en metres */
   pseries->therm_kappa=options->therm_kappa;
   pseries->thermic_response=options->thermic_response; /* reponse terminque moyenne en electron/sec/pixel */
   pseries->threshold=options->threshold;
   pseries->topt=options->topt; /* optic transmission */
   pseries->trans_x=options->trans_x;
   pseries->trans_y=options->trans_y;
   pseries->type_threshold=options->type_threshold;
   pseries->width=options->width;
   pseries->x1=options->x1;
   pseries->x2=options->x2;
   pseries->xcenter=options->xcenter;
   pseries->y1=options->y1;
   pseries->y2=options->y2;
   pseries->ycenter=options->ycenter;
   strcpy(pseries->colfilter,options->colfilter);
   
   /* --- user options ---*/
   memcpy(&(pseries->user1), &(options->user1), sizeof(TT_USER1_IMA_SERIES));
   memcpy(&(pseries->user2), &(options->user2), sizeof(TT_USER2_IMA_SERIES));
   memcpy(&(pseries->user3), &(options->user3), sizeof(TT_USER3_IMA_SERIES));
   memcpy(&(pseries->user4), &(options->user4), sizeof(TT_USER4_IMA_SERIES));
   memcpy(&(pseries->user5), &(options->user5), sizeof(TT_USER5_IMA_SERIES));
   
   /* --- valeurs des parametres non optionnels par defaut ---*/
   pseries->nbima = nbima;
   pseries->val_exptime=0.;
   pseries->val_dexptime=1.;
   pseries->outnaxis1=1;
   pseries->outnaxis2=1;
   //pseries->nbimages=0;	  
	pseries->p_ast.crota2=0.;
   pseries->p_ast.foclen=0.;
   pseries->p_ast.px=0.;    
   pseries->p_ast.py=0.;
   pseries->p_ast.crota2=0.;
   pseries->p_ast.cd11=0.;
   pseries->p_ast.cd12=0.;
   pseries->p_ast.cd21=0.;
   pseries->p_ast.cd22=0.;
   pseries->p_ast.crpix1=0.;
   pseries->p_ast.crpix2=0.;
   pseries->p_ast.crval1=0.;
   pseries->p_ast.crval2=0.;
   pseries->p_ast.cdelta1=0.;
   pseries->p_ast.cdelta2=0.;
   pseries->p_ast.dec0=-100.;
   pseries->p_ast.ra0=-100.;

   for (k1=1;k1<=2;k1++) {
      for (k2=0;k2<=6;k2++) {
         pseries->p_ast.pv[k1][k2]=0.;
      }
   }
   pseries->p_ast.pv[1][1]=1.;
   pseries->p_ast.pv[2][1]=1.;
   pseries->p_ast.pv_valid=TT_NO;   

   /* --- autres parametres internes (private) ---*/
   pseries->therm_mean=0.;
   pseries->therm_sigma=0.;
   pseries->coef_therm=0.;
   pseries->nbpix_therm=0;
   pseries->mean=0.;
   pseries->sigma=0.;
   pseries->mini=0.;
   pseries->maxi=0.;
   pseries->nbpixsat=0;
   pseries->bgmean=0.;
   pseries->bgsigma=0.;
   pseries->hicut=0.;
   pseries->locut=0.;
   pseries->contrast=0.;
   pseries->nbstars=0;
   pseries->fwhm=0.;
   pseries->d_fwhm=0.;
   pseries->nbmatched=0;
   
   /* --- initialise les pointeurs a allouer ---*/
   pseries->p_in=NULL;
   pseries->p_tmp1=NULL;
   pseries->p_tmp2=NULL;
   pseries->p_tmp3=NULL;
   pseries->p_tmp4=NULL;
   pseries->p_out=NULL;
   pseries->jj=NULL;
   pseries->exptime=NULL;
   pseries->poids=NULL;
   pseries->coefa=NULL;
   
   /* --- alloue de la place pour les images ---*/
   nombre=1;
   taille=sizeof(TT_IMA);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->p_in,&nombre,&taille,"pseries->p_in"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer p_in) nombre=%d taille=%d",nombre,taille);
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=tt_imabuilder(pseries->p_in))!=OK_DLL) {
      tt_errlog(pseries->tmp_dir,msg,"Pb alloc in tt_ima_series_builder (pointer pseries->p_in)");
      tt_ima_series_destroyer(pseries);
      return(msg);
   }
   
   nombre=1;
   taille=sizeof(TT_IMA);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->p_tmp1,&nombre,&taille,"pseries->p_tmp1"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer p_tmp1)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=tt_imabuilder(pseries->p_tmp1))!=OK_DLL) {
      tt_errlog(pseries->tmp_dir,msg,"Pb tt_imabuilder in tt_ima_series_builder (pointer pseries->p_tmp1)");
      tt_ima_series_destroyer(pseries);
      return(msg);
   }
   
   nombre=1;
   taille=sizeof(TT_IMA);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->p_tmp2,&nombre,&taille,"pseries->p_tmp2"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer p_tmp2)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=tt_imabuilder(pseries->p_tmp2))!=OK_DLL) {
      tt_errlog(pseries->tmp_dir,msg,"Pb tt_imabuilder in tt_ima_series_builder (pointer pseries->p_tmp2)");
      tt_ima_series_destroyer(pseries);
      return(msg);
   }
   
   nombre=1;
   taille=sizeof(TT_IMA);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->p_tmp3,&nombre,&taille,"pseries->p_tmp3"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer p_tmp3)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=tt_imabuilder(pseries->p_tmp3))!=OK_DLL) {
      tt_errlog(pseries->tmp_dir,msg,"Pb tt_imabuilder in tt_ima_series_builder (pointer pseries->p_tmp3)");
      tt_ima_series_destroyer(pseries);
      return(msg);
   }
   
   nombre=1;
   taille=sizeof(TT_IMA);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->p_tmp4,&nombre,&taille,"pseries->p_tmp4"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer p_tmp4)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=tt_imabuilder(pseries->p_tmp4))!=OK_DLL) {
      tt_errlog(pseries->tmp_dir,msg,"Pb tt_imabuilder in tt_ima_series_builder (pointer pseries->p_tmp4)");
      tt_ima_series_destroyer(pseries);
      return(msg);
   }
   
   nombre=1;
   taille=sizeof(TT_IMA);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->p_out,&nombre,&taille,"pseries->p_out"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer p_out)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=tt_imabuilder(pseries->p_out))!=OK_DLL) {
      tt_errlog(pseries->tmp_dir,msg,"Pb tt_imabuilder in tt_ima_series_builder (pointer pseries->p_out)");
      tt_ima_series_destroyer(pseries);
      return(msg);
   }
   
   /* --- alloue de la place pour les tableaux ---*/
   nombre=pseries->nbima;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->jj,&nombre,&taille,"pseries->jj"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer jj)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=pseries->nbima;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->exptime,&nombre,&taille,"pseries->exptime"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer exptime)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=pseries->nbima;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->poids,&nombre,&taille,"pseries->poids"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer poids)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=pseries->nbima;
   taille=sizeof(TT_COEFA);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries->coefa,&nombre,&taille,"pseries->coefa"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_builder (pointer coefa)");
      tt_ima_series_destroyer(pseries);
      return(TT_ERR_PB_MALLOC);
   }
   return(OK_DLL);
}

int abtt_imageSeriesInitOption (TT_IMA_SERIES_OPTION* options) {
/**********************************************************************************/
/* Initialise les champs de la structure TT_IMA_SERIES avec les valeurs par defaut */
/**********************************************************************************/
   return tt_ima_series_builder2(options);
}


int tt_ima_series_dispatch(char *fonction,TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Dispatcher des fonctions de ima/series.                                 */
/***************************************************************************/
{
   int msg,fct_found;
   char message[TT_MAXLIGNE];
   /* --- Creation eventuelle des images temporaires p_tmp* ---*/
   /* --- Creation eventuelle de l'image finale p_out ---*/
   /* --- Calcul de l'image finale p_out---*/
   fct_found=TT_NO;
   msg=OK_DLL;
   if (pseries->numfct==TT_IMASERIES_SUB) {
      msg=tt_ima_series_sub_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_ADD) {
      msg=tt_ima_series_add_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_OFFSET) {
      msg=tt_ima_series_offset_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_COPY) {
      msg=tt_ima_series_copy_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_DIV) {
      msg=tt_ima_series_div_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_FILTER) {
      msg=tt_ima_series_filter_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_OPT) {
      msg=tt_ima_series_opt_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_TRANS) {
      msg=tt_ima_series_trans_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_STAT) {
      msg=tt_ima_series_stat_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_NORMGAIN) {
      msg=tt_ima_series_normgain_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_NORMOFFSET) {
      msg=tt_ima_series_normoffset_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_OBJECTS) {
      msg=tt_ima_series_objects_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_CATCHART) {
      msg=tt_ima_series_catchart_2(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_HEADERFITS) {
      msg=tt_ima_series_headerfits_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_REGISTER) {
      msg=tt_ima_series_register_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_ASTROMETRY) {
      msg=tt_ima_series_astrometry_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_UNSMEARING) {
      msg=tt_ima_series_unsmearing_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_INVERT) {
      msg=tt_ima_series_invert_2(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_CONV) {
      msg=tt_ima_series_conv_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_SUBDARK) {
      msg=tt_ima_series_subdark_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_RGRADIENT) {
      msg=tt_ima_series_rgradient_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_HOUGH) {
      msg=tt_ima_series_hough_1(pseries);
      fct_found=TT_YES;
   }  else if (pseries->numfct==TT_IMASERIES_BACK) {
      msg=tt_ima_series_back_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_TEST) {
      msg=tt_ima_series_test_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_RESAMPLE) {
      msg=tt_ima_series_resample_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_CUTS) {
      msg=tt_ima_series_cuts_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_MULT) {
      msg=tt_ima_series_mult_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_SORTX) {
      msg=tt_ima_series_sortx_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_SORTY) {
      msg=tt_ima_series_sorty_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_UNTRAIL) {
      msg=tt_ima_series_untrail_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_GEOSTAT) {
      msg=tt_ima_series_geostat_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_TILT) {
      msg=tt_ima_series_tilt_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_RADIAL) {
      msg=tt_ima_series_radial_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_SMILEX) {
      msg=tt_ima_series_smilex_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_SMILEY) {
      msg=tt_ima_series_smiley_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_REGISTERFINE) {
      msg=tt_ima_series_registerfine_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_PROD) {
      msg=tt_ima_series_prod_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_FITELLIP) {
      msg=tt_ima_series_fitellip_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_RESIZE) {
      msg=tt_ima_series_resize_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_DELETE) {
      msg=OK_DLL;
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_REPAIR_HOTPIXEL) {
      msg=tt_ima_series_hotpixel_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_REPAIR_COSMIC) {
      msg=tt_ima_series_cosmic_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_CORNERS) {
      msg=tt_ima_series_corners_1(pseries);
      fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_CORONASUN) {
      msg=tt_ima_series_coronasun_1(pseries);
      fct_found=TT_YES;
   } else {
      tt_user1_ima_series_dispatch1(pseries,&fct_found,&msg);
      tt_user2_ima_series_dispatch1(pseries,&fct_found,&msg);
      tt_user3_ima_series_dispatch1(pseries,&fct_found,&msg);
      tt_user4_ima_series_dispatch1(pseries,&fct_found,&msg);
      tt_user5_ima_series_dispatch1(pseries,&fct_found,&msg);
   }

   if (fct_found==TT_NO) {
      sprintf(message,"Function %s is not implemented in IMA/SERIES",fonction);
      tt_errlog(pseries->tmp_dir,TT_ERR_FCT_NOT_FOUND_IN_IMASERIES,message);
      return(TT_ERR_FCT_NOT_FOUND_IN_IMASERIES);
   }
   return(msg);
}

int tt_ima_series_history(char* fonction, TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Ajoute un/des mot(s) cle pour completer l'historique de traitement.     */
/***************************************************************************/
{
   char xvalue[FLEN_VALUE];

   /* --- complete l'entete avec l'historique de ce traitement ---*/
   sprintf(xvalue,"IMA/SERIES %s", fonction);
   tt_imanewkeytt(pseries->p_out,xvalue,"TT History","");
   if (pseries->numfct==TT_IMASERIES_OPT) {
      sprintf(xvalue," coef=%f nbpix=%d",pseries->coef_therm,pseries->nbpix_therm);
      tt_imanewkeytt(pseries->p_out,xvalue,"TT History","");
   }
   if (pseries->numfct==TT_IMASERIES_REGISTER) {
      sprintf(xvalue," %f %f %f",pseries->coefa[pseries->index-1].a[0],pseries->coefa[pseries->index-1].a[1],pseries->coefa[pseries->index-1].a[2]);
      tt_imanewkeytt(pseries->p_out,xvalue,"TT History","pixels");
      sprintf(xvalue," %f %f %f",pseries->coefa[pseries->index-1].a[3],pseries->coefa[pseries->index-1].a[4],pseries->coefa[pseries->index-1].a[5]);
      tt_imanewkeytt(pseries->p_out,xvalue,"TT History","pixels");
      sprintf(xvalue," %d objects matched",pseries->nbmatched);
      tt_imanewkeytt(pseries->p_out,xvalue,"TT History","");
   }
   return(OK_DLL);
}


int tt_ima_series_builder1(char* fonction, TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Decode la fonction dans la structure TT_IMA_SERIES                      */
/***************************************************************************/
/* A completer pour tout ajout d'une fonction de type IMA/SERIES           */
/* au minimum en ajoutant un 'else if' dans la premiere serie.             */
/***************************************************************************/
{
   //double valsat=(double)(TT_MAX_DOUBLE);

   pseries->numfct=0;
   pseries->index_out=0;
   
   tt_strupr(fonction);
   if (strcmp(fonction,"SUB")==0) { pseries->numfct=TT_IMASERIES_SUB; }
   else if (strcmp(fonction,"ADD")==0) { pseries->numfct=TT_IMASERIES_ADD; }
   else if (strcmp(fonction,"OFFSET")==0) { pseries->numfct=TT_IMASERIES_OFFSET; }
   else if (strcmp(fonction,"COPY")==0) { pseries->numfct=TT_IMASERIES_COPY; }
   else if (strcmp(fonction,"DIV")==0) { pseries->numfct=TT_IMASERIES_DIV; }
   else if (strcmp(fonction,"FILTER")==0) { pseries->numfct=TT_IMASERIES_FILTER; }
   else if (strcmp(fonction,"OPT")==0) { pseries->numfct=TT_IMASERIES_OPT; }
   else if (strcmp(fonction,"TRANS")==0) { pseries->numfct=TT_IMASERIES_TRANS; }
   else if (strcmp(fonction,"STAT")==0) { pseries->numfct=TT_IMASERIES_STAT; }
   else if (strcmp(fonction,"DELETE")==0) { pseries->numfct=TT_IMASERIES_DELETE; }
   else if (strcmp(fonction,"NORMGAIN")==0) { pseries->numfct=TT_IMASERIES_NORMGAIN; }
   else if (strcmp(fonction,"NORMOFFSET")==0) { pseries->numfct=TT_IMASERIES_NORMOFFSET; }
   else if (strcmp(fonction,"OBJECTS")==0) { pseries->numfct=TT_IMASERIES_OBJECTS; }
   else if (strcmp(fonction,"CATCHART")==0) { pseries->numfct=TT_IMASERIES_CATCHART; }
   else if (strcmp(fonction,"HEADERFITS")==0) { pseries->numfct=TT_IMASERIES_HEADERFITS; }
   else if (strcmp(fonction,"REGISTER")==0) { pseries->numfct=TT_IMASERIES_REGISTER; }
   else if (strcmp(fonction,"ASTROMETRY")==0) { pseries->numfct=TT_IMASERIES_ASTROMETRY; }
   else if (strcmp(fonction,"UNSMEARING")==0) { pseries->numfct=TT_IMASERIES_UNSMEARING; }
   else if (strcmp(fonction,"INVERT")==0) { pseries->numfct=TT_IMASERIES_INVERT; }
   else if (strcmp(fonction,"CONV")==0) { pseries->numfct=TT_IMASERIES_CONV; }
   else if (strcmp(fonction,"SUBDARK")==0) { pseries->numfct=TT_IMASERIES_SUBDARK; }
   else if (strcmp(fonction,"RGRADIENT")==0) { pseries->numfct=TT_IMASERIES_RGRADIENT; }
   else if (strcmp(fonction,"HOUGH")==0) { pseries->numfct=TT_IMASERIES_HOUGH; }
   else if (strcmp(fonction,"HOUGH_MYRTILLE")==0) { pseries->numfct=TT_IMASERIES_HOUGH_MYRTILLE; }
   else if (strcmp(fonction,"BACK")==0) { pseries->numfct=TT_IMASERIES_BACK; }
   else if (strcmp(fonction,"TEST")==0) { pseries->numfct=TT_IMASERIES_TEST; }
   else if (strcmp(fonction,"RESAMPLE")==0) { pseries->numfct=TT_IMASERIES_RESAMPLE; }
   else if (strcmp(fonction,"CUTS")==0) { pseries->numfct=TT_IMASERIES_CUTS; }
   else if (strcmp(fonction,"MULT")==0) { pseries->numfct=TT_IMASERIES_MULT; }
   else if (strcmp(fonction,"SORTX")==0) { pseries->numfct=TT_IMASERIES_SORTX; }
   else if (strcmp(fonction,"SORTY")==0) { pseries->numfct=TT_IMASERIES_SORTY; }
   else if (strcmp(fonction,"UNTRAIL")==0) { pseries->numfct=TT_IMASERIES_UNTRAIL; }
   else if (strcmp(fonction,"GEOSTAT")==0) { pseries->numfct=TT_IMASERIES_GEOSTAT; }
   else if (strcmp(fonction,"TILT")==0) { pseries->numfct=TT_IMASERIES_TILT; }
   else if (strcmp(fonction,"SMILEX")==0) { pseries->numfct=TT_IMASERIES_SMILEX; }
   else if (strcmp(fonction,"SMILEY")==0) { pseries->numfct=TT_IMASERIES_SMILEY; }
   else if (strcmp(fonction,"RADIAL")==0) { pseries->numfct=TT_IMASERIES_RADIAL; }
   else if (strcmp(fonction,"REGISTERFINE")==0) { pseries->numfct=TT_IMASERIES_REGISTERFINE; }
   else if (strcmp(fonction,"PROD")==0) { pseries->numfct=TT_IMASERIES_PROD; }
   else if (strcmp(fonction,"FITELLIP")==0) { pseries->numfct=TT_IMASERIES_FITELLIP; }
   else if (strcmp(fonction,"HOTPIXEL")==0) { pseries->numfct=TT_IMASERIES_REPAIR_HOTPIXEL; }
   else if (strcmp(fonction,"COSMIC")==0)   { pseries->numfct=TT_IMASERIES_REPAIR_COSMIC; }
   else if (strcmp(fonction,"RESIZE")==0)   { pseries->numfct=TT_IMASERIES_RESIZE; }
   else if (strcmp(fonction,"CORNERS")==0)   { pseries->numfct=TT_IMASERIES_CORNERS; }
   else if (strcmp(fonction,"CORONASUN")==0)   { pseries->numfct=TT_IMASERIES_CORONASUN; }
   
   tt_user1_ima_series_builder1(fonction,pseries);
   tt_user2_ima_series_builder1(fonction,pseries);
   tt_user3_ima_series_builder1(fonction,pseries);
   tt_user4_ima_series_builder1(fonction,pseries);
   tt_user5_ima_series_builder1(fonction,pseries);

   return(OK_DLL);
}

int tt_ima_series_destroyer(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Destructeur des valeurs de la structure TT_IMA_SERIES                   */
/***************************************************************************/
{

   /* --- Libere la place des images ---*/
   if (pseries->p_in!=NULL) {
      tt_imadestroyer(pseries->p_in);
      tt_free(pseries->p_in,"pseries->p_in");
   }
   pseries->p_in=NULL;
   if (pseries->p_tmp1!=NULL) {
      tt_imadestroyer(pseries->p_tmp1);
      tt_free(pseries->p_tmp1,"pseries->p_tmp1");
   }
   pseries->p_tmp1=NULL;
   if (pseries->p_tmp2!=NULL) {
      tt_imadestroyer(pseries->p_tmp2);
      tt_free(pseries->p_tmp2,"pseries->p_tmp2");
   }
   pseries->p_tmp2=NULL;
   if (pseries->p_tmp3!=NULL) {
      tt_imadestroyer(pseries->p_tmp3);
      tt_free(pseries->p_tmp3,"pseries->p_tmp3");
   }
   pseries->p_tmp3=NULL;
   if (pseries->p_tmp4!=NULL) {
      tt_imadestroyer(pseries->p_tmp4);
      tt_free(pseries->p_tmp4,"pseries->p_tmp4");
   }
   pseries->p_tmp4=NULL;
   if (pseries->p_out!=NULL) {
      tt_imadestroyer(pseries->p_out);
      tt_free(pseries->p_out,"pseries->p_out");
   }
   pseries->p_out=NULL;

   /* --- Libere la place des tableaux ---*/
   if (pseries->jj!=NULL) {
      tt_free(pseries->jj,"pseries->jj");
   }
   pseries->jj=NULL;
   if (pseries->exptime!=NULL) {
      tt_free(pseries->exptime,"pseries->exptime");
   }
   pseries->exptime=NULL;
   if (pseries->poids!=NULL) {
      tt_free(pseries->poids,"pseries->poids");
   }
   pseries->poids=NULL;
   if (pseries->coefa!=NULL) {
      tt_free(pseries->coefa,"pseries->coefa");
   }
   pseries->coefa=NULL;

   if (pseries->hotPixelList!=NULL) {
      tt_free(pseries->hotPixelList,"pseries->hotPixelList");
   }
   pseries->hotPixelList = NULL;
   return(OK_DLL);
}

int tt_ima_series_builder2(TT_IMA_SERIES_OPTION* options) {
/*******************************************************************************************/
/* Initialise les champs de la structure TT_IMA_SERIES_OPTIONS avec les valeurs par defaut */
/*******************************************************************************************/
   strcpy(options->astromcatalog,"USNO");
   strcpy(options->bias,"bias.fit");
   strcpy(options->catafile,"");
   strcpy(options->centroide,"gauss");
   strcpy(options->colfilter,"R");
   strcpy(options->dark,"dark.fit");
   strcpy(options->file,"file.fit");
   strcpy(options->file_ascii,"");
   strcpy(options->flat,"flat.fit");
   strcpy(options->jpegfile,"");
   strcpy(options->jpegfile_chart,"");
   strcpy(options->jpegfile_chart2,"");
   strcpy(options->key_dexptime,"EXPTIME");
   strcpy(options->key_exptime,"EXPTIME");
   strcpy(options->keyhicut,"MIPS-HI");
   strcpy(options->keylocut,"MIPS-LO");
   strcpy(options->keytype,"INT");
   strcpy(options->nom_trait,"DILATE");
   strcpy(options->objefile,"");
   strcpy(options->objefiletype,"SEXTRACTOR1");
   strcpy(options->paramresample,"1 0 0 0 1 0");
   strcpy(options->path_astromcatalog,"");
   strcpy(options->pixefile,"");
   strcpy(options->struct_elem,"RECTANGLE");

   options->angle=0.;
   options->background=0.;
   options->back_kernel=8;
   options->back_threshold=.1;
   options->bias_level=0; /* ADU */
   options->binary_yesno=TT_NO;
   options->bitpix=0;
   options->bordure=0.;
   options->catalog_list=TT_NO;
   options->coef_smile2=0.;
   options->coef_smile4=0.;
   options->coef_unsmearing=0.;
   options->constant=0.;
   options->cosmicThreshold = 0.;
   options->cutscontrast=1.0;
   options->dec=0;
   options->delta=0.0;
   options->detect_kappa=3.;
   options->div_yesno=TT_NO;
   options->elecmult=0; /* EMCCD multiplicator factor */
   options->epsilon=0.0;
   options->exposure=0.;
   options->fitorder6543=0;
   options->flat_type=TT_FLAT_TYPE_NONE; /* 0=no flat */
   options->fwhm_compute=TT_NO;
   options->fwhmsat=0.;
   options->fwhmx=2.5;
   options->fwhmy=2.5;
   options->gain=2.5; /* gain de la chaine en electron/ADU */
   options->height=20;
   options->hifrac=0.97;
   options->hotPixelList = NULL;
   options->invert_flip=TT_NO;
   options->invert_mirror=TT_NO;
   options->invert_xy=TT_NO;
   options->jpegfile_chart2_make=TT_NO;
   options->jpegfile_chart_make=TT_NO;
   options->jpegfile_make=TT_NO;
   options->jpeg_qualite=75;
   options->kernel_coef=0.;
   options->kernel_type=TT_KERNELTYPE_FB;
   options->kernel_width=3;
   options->length=0;
   options->lofrac=0.05;
   options->mag=12;
   options->magblim=99.;
   options->magrlim=99.;
   options->matchwcs=0;
   options->nbsubseries=1;
   options->newstar=TT_NEWSTAR_NONE;
   options->normaflux=0.;
   options->normgain_value=1.;
   options->normoffset_value=0.;
   options->nullpix_exist=TT_NO;
   options->nullpix_value=0.;
   options->object_list=TT_NO;
   options->offset=0.;
   options->oversampling=4;
   options->percent=50.;
   options->pixelsat_compute=TT_NO;
   options->pixelsat_value=TT_MAX_DOUBLE;
   options->pixel_list=TT_NO;
   options->pixint=TT_NO;
   options->power=2.;
   options->quantum_efficiency=1.; /* efficacite quantique d'un pixel en electron/photon */
   options->ra=0;
   options->radius=0.;
   options->readout_noise=0; /* electrons */
   options->regitrans=TT_REGITRANS_BEFORE;
   options->shutter_mode=TT_SHUTTER_MODE_SYNCHRO; /* 1=synchro 0=closed 2=opened */
   options->sigma_given=TT_NO;
   options->sigma_value=2.0;
   options->simulimage=0;
   options->skylevel_compute=TT_NO;
   options->sky_brightness=20.9; /* brillance du ciel en mag/arcsec2 */
   options->sub_yesno=TT_NO;
   options->tatm=0.6; /* atmospheric transmission at observed elevation */
   options->teldiam=1; /* diametre du telescope en metres */
   options->thermic_response=0; /* reponse terminque moyenne en electron/sec/pixel */
   options->therm_kappa=0.25;
   options->threshold=0;
   options->topt=0.85; /* optic transmission */
   options->trans_x=0.;
   options->trans_y=0.;
   options->type_threshold=0;
   options->width=20;
   options->x1=1;
   options->x2=1;
   options->xcenter=0.;
   options->y1=1;
   options->y2=1;
   options->ycenter=0.;

   
   // initialise les options des users
   tt_user1_ima_series_builder2(options);
   tt_user2_ima_series_builder2(options);
   tt_user3_ima_series_builder2(options);
   tt_user4_ima_series_builder2(options);
   tt_user5_ima_series_builder2(options);

   return(OK_DLL);
}


int tt_ima_series_builder3(int nbkeys, char **keys, char* tmp_dir, TT_IMA_SERIES_OPTION* options)

/***************************************************************************/
/* Decode les options dans la structure TT_IMA_SERIES_OPTION               */
/* C'est ici que l'on decode les mots optionels de fin de ligne.           */
/***************************************************************************/
{
   int k,valint;
   int pos;
   char *car;
   char mot[1000];
   char *argu = NULL;
   double valsat=(double)(TT_MAX_DOUBLE);

   
   /* --- decodage des parametres optionels ---*/
   for (k=0;k<(nbkeys);k++) {
      /* --- extrait le mot cle ( 999 caracteres au maximum )---*/
      strncpy(mot,keys[k], 999);
      tt_strupr(mot);
      car=strstr(mot,"=");
      pos=0;
      
      argu= malloc(strlen(keys[k]));
      if (car!=NULL) {
         pos=(int)(car-mot);
         mot[pos]='\0';
         strcpy(argu,keys[k]+pos+1);
      } else {
         /* --- mot sans argument ---*/
         strcpy(argu,"");
      }
      
      /* --- extrait la valeur de l'argument ---*/
      if (strcmp(mot,"BITPIX")==0) {
         if (strcmp(argu,"8")==0) {
            options->bitpix=BYTE_IMG;
            valsat=(double)(TT_MAX_UNSIGNEDCHAR);
         } else if (strcmp(argu,"16")==0) {
            options->bitpix=SHORT_IMG;
            valsat=(double)(TT_MAX_SHORT);
         } else if (strcmp(argu,"+16")==0) {
            options->bitpix=USHORT_IMG;
            valsat=(double)(TT_MAX_UNSIGNEDSHORT);
         } else if (strcmp(argu,"32")==0) {
            options->bitpix=LONG_IMG;
            valsat=(double)(TT_MAX_INT);
         } else if (strcmp(argu,"+32")==0) {
            options->bitpix=ULONG_IMG;
            valsat=(double)(TT_MAX_UNSIGNEDINT);
         } else if (strcmp(argu,"-32")==0) {
            options->bitpix=FLOAT_IMG;
            valsat=(double)(TT_MAX_FLOAT);
         } else if (strcmp(argu,"-64")==0) {
            options->bitpix=DOUBLE_IMG;
            valsat=(double)(TT_MAX_DOUBLE);
         } else {
            options->bitpix=0;
            valsat=(double)(TT_MAX_DOUBLE);
         }
      }
      else if (strcmp(mot,"JPEGFILE")==0) {
         options->jpegfile_make=TT_YES;
         if (strcmp(argu,"")!=0) {
            strcpy(options->jpegfile,argu);
         }
      }
      else if (strcmp(mot,"MAGRLIM")==0) {
         if (strcmp(argu,"")!=0) {
            options->magrlim=(double)atof(argu);
         }
      }
      else if (strcmp(mot,"MAGBLIM")==0) {
         if (strcmp(argu,"")!=0) {
            options->magblim=(double)atof(argu);
         }
      }
      else if (strcmp(mot,"MATCHWCS")==0) {
         options->matchwcs=(int)1;
      }
      else if (strcmp(mot,"XCENTER")==0) {
         if (strcmp(argu,"")!=0) {
            options->xcenter=(double)atof(argu);
         }
      }
      else if (strcmp(mot,"YCENTER")==0) {
         if (strcmp(argu,"")!=0) {
            options->ycenter=(double)atof(argu);
         }
      }
      else if (strcmp(mot,"RADIUS")==0) {
         if (strcmp(argu,"")!=0) {
            options->radius=(double)atof(argu);
         }
      }
      else if (strcmp(mot,"EXPOSURE")==0) {
         if (strcmp(argu,"")!=0) {
            options->exposure=(double)atof(argu);
         }
      }else if (strcmp(mot,"NOM_TRAIT")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->nom_trait,argu);
         }
      }
      else if (strcmp(mot,"STRUCT_ELEM")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->struct_elem,argu);
         }
      }
      else if (strcmp(mot,"ANGLE")==0) {
         if (strcmp(argu,"")!=0) {
            options->angle=(double)atof(argu);
         }
      }
      else if (strcmp(mot,"BACKGROUND")==0) {
         if (strcmp(argu,"")!=0) {
            options->background=(double)atof(argu);
         }
      }
      else if (strcmp(mot,"FITORDER6543")==0) {
         if (strcmp(argu,"")!=0) {
            options->fitorder6543=(int)atoi(argu);
         }
      }
      else if (strcmp(mot,"EXPTIME")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->key_exptime,argu);
         }
      }
      else if (strcmp(mot,"DEXPTIME")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->key_dexptime,argu);
         }
      }
      else if (strcmp(mot,"LOCUT")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->keylocut,argu);
         }
      }
      else if (strcmp(mot,"HICUT")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->keyhicut,argu);
         }
      }
      else if (strcmp(mot,"KEYTYPE")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->keytype,argu);
         }
      }
      else if (strcmp(mot,"LOFRAC")==0) {
         if (strcmp(argu,"")!=0) {
            options->lofrac=(double)(atof(argu));
         }
      }
      else if (strcmp(mot,"HIFRAC")==0) {
         if (strcmp(argu,"")!=0) {
            options->hifrac=(double)(atof(argu));
         }
      }
      else if (strcmp(mot,"CUTSCONTRAST")==0) {
         if (strcmp(argu,"")!=0) {
            options->cutscontrast=(double)(atof(argu));
         }
      }
      else if (strcmp(mot,"FILE_ASCII")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->file_ascii,argu);
         }
      }
      else if (strcmp(mot,"SKYLEVEL")==0) {
         options->skylevel_compute=TT_YES;
      }
      else if (strcmp(mot,"CATAFILE")==0) {
         options->catalog_list=TT_YES;
         strcpy(options->catafile,argu);
      }
      else if (strcmp(mot,"OBJEFILE")==0) {
         options->object_list=TT_YES;
         options->fwhm_compute=TT_YES;
         strcpy(options->objefile,argu);
      }
      else if (strcmp(mot,"OBJEFILETYPE")==0) {
         strcpy(options->objefiletype,argu);
      }
      else if (strcmp(mot,"PIXEFILE")==0) {
         options->pixel_list=TT_YES;
         options->fwhm_compute=TT_YES;
         strcpy(options->pixefile,argu);
      }
      else if (strcmp(mot,"PIXINT")==0) {
         options->pixint=TT_YES;
      }
      else if (strcmp(mot,"NORMAFLUX")==0) {
         if (strcmp(argu,"")!=0) {
            options->normaflux=(double)(atof(argu));
         }
      }
      else if (strcmp(mot,"OFFSET")==0) {
         if (strcmp(argu,"")!=0) {
            options->offset=(double)(atof(argu));
         }
      }
      else if (strcmp(mot,"JPEG_QUALITY")==0) {
         if (strcmp(argu,"")!=0) {
            options->jpeg_qualite=(int)(atoi(argu));
         }
      }
      else if (strcmp(mot,"NBSUBSERIES")==0) {
         if (strcmp(argu,"")!=0) {
            options->nbsubseries=(int)(atoi(argu));
         }
      }
      else if (strcmp(mot,"SIGMA")==0) {
         options->sigma_given=TT_YES;
         options->sigma_value=atof(argu);
      }
      else if (strcmp(mot,"BINARY")==0) {
         options->binary_yesno=TT_YES;
      }
      else if (strcmp(mot,"JPEGFILE_CHART")==0) {
         options->jpegfile_chart_make=TT_YES;
         if (strcmp(argu,"")!=0) {
            strcpy(options->jpegfile_chart,argu);
         }
      }
      else if (strcmp(mot,"JPEGFILE_CHART2")==0) {
         options->jpegfile_chart2_make=TT_YES;
         if (strcmp(argu,"")!=0) {
            strcpy(options->jpegfile_chart2,argu);
         }
      }
      else if (strcmp(mot,"FILE")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->file,argu);
         }
      }
      else if (strcmp(mot,"DARK")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->dark,argu);
         }
      }
      else if (strcmp(mot,"BIAS")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->bias,argu);
         }
      }
      else if (strcmp(mot,"CENTROIDE")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->centroide,argu);
         }
      }
      else if (strcmp(mot,"FLAT")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->flat,argu);
         }
      }
      else if (strcmp(mot,"PATH_ASTROMCATALOG")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->path_astromcatalog,argu);
         }
      }
      else if (strcmp(mot,"ASTROMCATALOG")==0) {
         if (strcmp(argu,"")!=0) {
            strcpy(options->astromcatalog,argu);
         }
      }
      else if (strcmp(mot,"TRANSLATE")==0) {
         tt_strupr(argu);
         if (strcmp(argu,"ONLY")==0) { options->regitrans=TT_REGITRANS_ONLY;}
         else if (strcmp(argu,"BEFORE")==0) { options->regitrans=TT_REGITRANS_BEFORE;}
         else if (strcmp(argu,"AFTER")==0) { options->regitrans=TT_REGITRANS_AFTER;}
         else if (strcmp(argu,"NEVER")==0) { options->regitrans=TT_REGITRANS_NEVER;}
      }
      else if (strcmp(mot,"THERM_KAPPA")==0) {
         options->therm_kappa=(double)(atof(argu));
      }
      else if (strcmp(mot,"PARAMRESAMPLE")==0) {
         strcpy(options->paramresample,argu);
      }
      else if (strcmp(mot,"DETECT_KAPPA")==0) {
         options->detect_kappa=(double)(atof(argu));
      }
      else if (strcmp(mot,"POWER")==0) {
         options->power=(double)(atof(argu));
      }
      else if (strcmp(mot,"BORDER")==0) {
         options->bordure=(double)(atof(argu));
      }
      else if (strcmp(mot,"PIXSAT_VALUE")==0) {
         options->pixelsat_compute=TT_YES;
         if (strcmp(argu,"")!=0) {
            options->pixelsat_value=(double)(atof(argu));
         } else {
            options->pixelsat_value=TT_MIN_DOUBLE;
         }
      }
      else if (strcmp(mot,"NULLPIXEL")==0) {
         options->nullpix_exist=TT_YES;
         options->nullpix_value=(double)(atof(argu));
      }
      else if (strcmp(mot,"FWHM")==0) {
         options->fwhm_compute=TT_YES;
      }
      else if (strcmp(mot,"EPSILON")==0) {
         options->epsilon=(double)(atof(argu));
      }
      else if (strcmp(mot,"DELTA")==0) {
         options->delta=(double)(atof(argu));
      }
      else if (strcmp(mot,"THRESHOLD")==0) {
         options->threshold=(double)(atof(argu));
      }
      else if (strcmp(mot,"TRANS_X")==0) {
         options->trans_x=(double)(atof(argu));
      }
      else if (strcmp(mot,"TRANS_Y")==0) {
         options->trans_y=(double)(atof(argu));
      }
      else if (strcmp(mot,"CONSTANT")==0) {
         options->constant=atof(argu);
      }
      else if (strcmp(mot,"NORMGAIN_VALUE")==0) {
         options->normgain_value=atof(argu);
      }
      else if (strcmp(mot,"NORMOFFSET_VALUE")==0) {
         options->normoffset_value=atof(argu);
      }
      else if (strcmp(mot,"UNSMEARING")==0) {
         options->coef_unsmearing=atof(argu);
      }
      else if (strcmp(mot,"COEF_SMILE2")==0) {
         options->coef_smile2=atof(argu);
      }
      else if (strcmp(mot,"COEF_SMILE4")==0) {
         options->coef_smile4=atof(argu);
      }
      else if (strcmp(mot,"BACK_KERNEL")==0) {
         options->back_kernel=(int)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"BACK_THRESHOLD")==0) {
         options->back_threshold=fabs(atof(argu));
      }
      else if (strcmp(mot,"SUB")==0) {
         options->sub_yesno=TT_YES;
      }
      else if (strcmp(mot,"DIV")==0) {
         options->div_yesno=TT_YES;
      }
      else if (strcmp(mot,"FLIP")==0) {
         options->invert_flip=TT_YES;
      }
      else if (strcmp(mot,"MIRROR")==0) {
         options->invert_mirror=TT_YES;
      }
      else if (strcmp(mot,"XY")==0) {
         options->invert_xy=TT_YES;
      }
      else if (strcmp(mot,"X1")==0) {
         options->x1=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"Y1")==0) {
         options->y1=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"X2")==0) {
         options->x2=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"Y2")==0) {
         options->y2=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"WIDTH")==0) {
         options->width=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"HEIGHT")==0) {
         options->height=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"LENGTH")==0) {
         options->length=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"OVERSAMPLING")==0) {
         options->oversampling=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"PERCENT")==0) {
         options->percent=(double)(fabs(atof(argu)));
      }      
      else if (strcmp(mot,"FWHMSAT")==0) {
         options->fwhmsat=(double)(fabs(atof(argu)));
      }      
      else if (strcmp(mot,"SIMULIMAGE")==0) {
         options->simulimage=(int)1;
      }
      else if (strcmp(mot,"COLFILTER")==0) {
         strcpy(options->colfilter,argu);
      }
      else if (strcmp(mot,"FWHMX")==0) {
         options->fwhmx=(double)(fabs(atof(argu)));
      }      
      else if (strcmp(mot,"FWHMY")==0) {
         options->fwhmy=(double)(fabs(atof(argu)));
      }      
      else if (strcmp(mot,"QE")==0) {
         options->quantum_efficiency=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"SKY_BRIGHTNESS")==0) {
         options->sky_brightness=(double)(atof(argu));
      }      
      else if (strcmp(mot,"GAIN")==0) {
         options->gain=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"TELDIAM")==0) {
         options->teldiam=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"READOUT_NOISE")==0) {
         options->readout_noise=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"TATM")==0) {
         options->tatm=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"TOPT")==0) {
         options->topt=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"ELECMULT")==0) {
         options->elecmult=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"SHUTTER_MODE")==0) {
         options->shutter_mode=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"FLAT_TYPE")==0) {
         options->flat_type=(int)(fabs(atoi(argu)));
      }
      else if (strcmp(mot,"BIAS_LEVEL")==0) {
         options->bias_level=(double)(atof(argu));
      }
      else if (strcmp(mot,"THERMIC_RESPONSE")==0) {
         options->thermic_response=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"NEWSTAR")==0) {
	      tt_strupr(argu);
			if (strcmp(argu,"NONE")==0) { options->newstar=TT_NEWSTAR_NONE; }
			if (strcmp(argu,"ADD")==0) { options->newstar=TT_NEWSTAR_ADD; }
			if (strcmp(argu,"REPLACE")==0) { options->newstar=TT_NEWSTAR_REPLACE; }
      }
      else if (strcmp(mot,"RA")==0) {
         options->ra=(double)(atof(argu));
      }
      else if (strcmp(mot,"DEC")==0) {
         options->dec=(double)(atof(argu));
      }
      else if (strcmp(mot,"MAG")==0) {
         options->mag=(double)(atof(argu));
      }
      else if (strcmp(mot,"KERNEL_COEF")==0) {
         options->kernel_coef=(double)(fabs(atof(argu)));
      }
      else if (strcmp(mot,"TYPE_THRESHOLD")==0) {
         if (atof(argu)>0) {
            options->type_threshold=1;
         } else if (atof(argu)<0) {
            options->type_threshold=-1;
         } else {
            options->type_threshold=0;
         }
      }
      else if (strcmp(mot,"KERNEL_WIDTH")==0) {
         valint=atoi(argu);
         if (valint>2) {
            if ((valint%2)==0) {valint++;}
            options->kernel_width=valint;
         }
      }
      else if (strcmp(mot,"KERNEL_TYPE")==0) {
         tt_strupr(argu);
         if (strcmp(argu,"FH")==0) {
            options->kernel_type=TT_KERNELTYPE_FH;
         } else if (strcmp(argu,"FB")==0) {
            options->kernel_type=TT_KERNELTYPE_FB;
         } else if (strcmp(argu,"MED")==0) {
            options->kernel_type=TT_KERNELTYPE_MED;
         } else if (strcmp(argu,"MIN")==0) {
            options->kernel_type=TT_KERNELTYPE_MIN;
         } else if (strcmp(argu,"MAX")==0) {
            options->kernel_type=TT_KERNELTYPE_MAX;
         } else if (strcmp(argu,"MEAN")==0) {
            options->kernel_type=TT_KERNELTYPE_MEAN;
         } else if ((strcmp(argu,"GRADLEFT")==0)||(strcmp(argu,"LAP")==0)) {
            options->kernel_type=TT_KERNELTYPE_GRAD_LEFT;
         } else if (strcmp(argu,"GRADRIGHT")==0) {
            options->kernel_type=TT_KERNELTYPE_GRAD_RIGHT;
         } else if (strcmp(argu,"GRADUP")==0) {
            options->kernel_type=TT_KERNELTYPE_GRAD_UP;
         } else if (strcmp(argu,"GRADDOWN")==0) {
            options->kernel_type=TT_KERNELTYPE_GRAD_DOWN;
         } else if (strcmp(argu,"MORLET")==0) {
            options->kernel_type=TT_KERNELTYPE_MORLET;
         } else if (strcmp(argu,"MEXICAN")==0) {
            options->kernel_type=TT_KERNELTYPE_MEXICAN;
         } else if (strcmp(argu,"GAUSSIAN")==0) {
            options->kernel_type=TT_KERNELTYPE_GAUSSIAN;
         } 
      } else if (strcmp(mot,"HOT_PIXEL_LIST")==0) {
            tt_parseHotPixelList(argu, &options->hotPixelList);
      } else if (strcmp(mot,"COSMIC_THRESHOLD")==0) {
            options->cosmicThreshold=(TT_PTYPE)fabs(atof(argu));
      }

      // decodage des options des users
      tt_user1_ima_series_builder3(mot,argu,options);
      tt_user2_ima_series_builder3(mot,argu,options);
      tt_user3_ima_series_builder3(mot,argu,options);
      tt_user4_ima_series_builder3(mot,argu,options);
      tt_user5_ima_series_builder3(mot,argu,options);

      if (argu != NULL ) {
         free(argu);
         argu = NULL;
      }
   }
   if ((options->pixelsat_compute==TT_YES)&&(options->pixelsat_value==TT_MIN_DOUBLE)&&(options->bitpix!=0)) {
      options->pixelsat_value=valsat;
   }

   return(OK_DLL);
}
