/* eteltcl_1.c
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
/* Ce fichier contient du C pur et dur sans une seule goute de Tcl.        */
/* Ainsi, ce fichier peut etre utilise pour d'autres applications C sans   */
/* rapport avec le Tcl.                                                    */
/***************************************************************************/
/* Le include eteltcl.h ne contient pas d'infos concernant Tcl.            */
/***************************************************************************/
#include "eteltcl.h"

void etel_error(int axisno, int err)
{
   DSA_DRIVE *drv;
   drv=etel.drv[axisno];
   sprintf(etel.msg,"error %d: %s.\n", err, dsa_translate_error(err));
}

int etel_symbol2type(char *symbol)
{
	int k,kk=-1;
	for (k=0;k<NB_TYP;k++) {
		if (strcmp(typs[k].type_symbol,symbol)==0) {
			kk=k;
			break;
		}
	}
	return kk;
}

uint64_t atoi64(const char *str,int radix)
{
	// on estime que la base est de la forme 0123456789abcdefghi....
	uint64_t n=0;
	const char *c=str;
	while(*c) {
		if((*c)>='0' && (*c)<='9')
			n=n*radix+(*c)-'0';
		else if(radix>10 && (*c)>='a' && (*c)<=('a'+radix-11))
			n=n*radix+(*c)-'a'+10;
		else if(radix>10 && (*c)>='A' && (*c)<=('A'+radix-11))
			n=n*radix+(*c)-'A'+10;
		else
			return 0;
		c++;
	}
	return n;
} 