/* libname.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2013 The AudeLA Core Team
 *
 * Initial author : Matteo SCHIAVON <ilmona89@gmail.com>
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

#ifndef __LIBNAME_H__
#define __LIBNAME_H__

/*
 * Nom du point d'entree de la librairie, doit etre Xx_Init pour une librairie libxx
 * (la majuscule est importante pour permettre un chargement par load libxx).
 */
#define CAM_ENTRYPOINT Epixowl_Init

/*
 * Informations sur le driver, le nom est celui qui apparait quand on fait "package names"
 * et la version apparait avec la commande Tcl "package require libxx"
 */
#define CAM_LIBNAME "libepixowl"
#define CAM_LIBVER "1.0"

/*
 * Initialisation d'informations indispensables pour la librairie xx.
 */
#define CAM_DRIVNAME "epixowl"

#define CAM_INI epixowl_cam_ini
#define CAM_DRV epixowl_cam_drv

#endif
