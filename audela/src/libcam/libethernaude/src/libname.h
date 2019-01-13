/* libname.h
 * 
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 * 
 * Mettre ici le texte de la license.
 *
 */

#ifndef __LIBNAME_H__
#define __LIBNAME_H__

/*
 * Nom du point d'entree de la librairie, doit etre Xx_Init pour une librairie libxx
 * (la majuscule est importante pour permettre un chargement par load libxx).
 */
#define CAM_ENTRYPOINT Ethernaude_Init

/*
 * Informations sur le driver, le nom est celui qui apparait quand on fait "package names"
 * et la version apparait avec la commande Tcl "package require libxx"
 */
#define CAM_LIBNAME "libethernaude"
#define CAM_LIBVER "1.0"

/*
 * Initialisation d'informations indispensables pour la librairie xx.
 */
#define CAM_DRIVNAME "ethernaude"

#define CAM_INI ethernaude_cam_ini
#define CAM_DRV ethernaude_cam_drv

#endif
