/* util.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

// $Id: util.c,v 1.1 2009-03-14 11:52:14 michelpujol Exp $


#include "util.h"

// Remarque : 
//   ces fonctions sont decrite dans un fichier . c (au lieu de .cpp) 
//   car  <asm/system.h>  provoque une erreur de compilation quand
//   il est inclu dans un fichier .cpps

/*
 * Sortie sur un port donne.
 */
void parallel_out(unsigned short a, unsigned char d)
{
#if defined(OS_WIN)
/* *INDENT-OFF* */
    _asm {
        mov dx, a 
        mov al, d 
        out dx, al
    }
/* *INDENT-ON* */
#elif defined(OS_LIN)
#if defined(OS_LIN_USE_PARRALLEL_OLD_STYLE)
printf("parallel_out OS_LIN_USE_PARRALLEL_OLD_STYLE %x\n", a);
    outb(d, a);
#else 
#endif
#endif
}


/*
 * Blocage des interruptions. Attention, sous Linux un appel systeme retablit
 * les interruptions (acces memoire, printf, etc...).
 */
void parallel_bloquer()
{
#if defined(OS_LIN)
    int permission;
    if ((permission = iopl(3)) != 0) {
        printf("Impossible d'acceder au port parallele.\n");
        exit(1);
    }
    AUDELA_CLI();
#endif
}


/*
 * Debloquage des interruptions.
 */
void parallel_debloquer()
{
#if defined(OS_LIN)
    AUDELA_STI();
#endif
}
