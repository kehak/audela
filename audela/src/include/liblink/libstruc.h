/* libstruc.h
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

#ifndef __LIBSTRUC_H__
#define __LIBSTRUC_H__

/*****************************************************************/
/*             This part is common for all link drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Structure interne pour la gestion du temps de pose.
 * Ne pas modifier.
 */

#define COMMON_LINKSTRUCT \
   char msg[2048];\
   int authorized;\
   Tcl_Interp *interp;\
   struct linkprop *next


/* --- structure qui accueille les initialisations des parametres---*/
/* Ne pas modifier. */
struct linkini {
    /* --- variables communes privees constantes --- */
    char name[256];
};

#define LINK_INI_NULL \
   {"",          /* link name */ \
    "",          /* ccd name */ \
   }


struct linkprop;

struct link_drv_t {
    int (*init) (struct linkprop * link, int argc, char **argv);
    int (*close) (struct linkprop * link);
};

extern struct link_drv_t LINK_DRV;

#ifdef __cplusplus
}
#endif

#endif
