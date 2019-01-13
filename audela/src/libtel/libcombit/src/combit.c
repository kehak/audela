/* combit.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Kinder Pingui <pingui@greenland.org>
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

#include <stdlib.h>
#include <string.h>
#include <tcl.h>
#include <libtel/util.h>

//------------------------------------------------------------------------------
//
//
int CmdComBit(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char s[256], signal[256];
    int broche = 0, retour = TCL_OK;
    unsigned short comadress = 0x03F8;
    unsigned char bitvalue = 0x00, audelabyte = 0x00;
    unsigned short a = 0x0000;

    if (argc < 3) {
	sprintf(s, "usage : %s ComNumber PinNumber ?BitValue?", argv[0]);
	Tcl_SetResult(interp, s, TCL_VOLATILE);
	return TCL_ERROR;
    } else {
	broche = 0;
	broche = atoi(argv[1]);
	/*
	if ((broche <= 0) || (broche > 2)) {
	    strcpy(s, "ComNumber should be 1|2");
	    Tcl_SetResult(interp, s, TCL_VOLATILE);
	    return TCL_ERROR;
	}
	*/
	if (broche == 1) {
	    comadress = 0x03F8;
	} else if (broche == 2) {
	    comadress = 0x02F8;
	} else if (broche == 3) {
	    comadress = 0x5000;
	} else if (broche == 4) {
	    comadress = 0x5400;
	} else {
	    comadress = broche;
	}
	broche = 0;
	strcpy(signal, argv[2]);
	broche = atoi(signal);
	if (strcmp(signal, "DCD") == 0)
	    broche = 1;
	if (strcmp(signal, "RxD") == 0)
	    broche = 2;
	if (strcmp(signal, "TxD") == 0)
	    broche = 3;
	if (strcmp(signal, "DTR") == 0)
	    broche = 4;
	if (strcmp(signal, "GND") == 0)
	    broche = 5;
	if (strcmp(signal, "DSR") == 0)
	    broche = 6;
	if (strcmp(signal, "RTS") == 0)
	    broche = 7;
	if (strcmp(signal, "CTS") == 0)
	    broche = 8;
	if (strcmp(signal, "RI") == 0)
	    broche = 9;
	if ((broche <= 0) || (broche > 9)) {
	    strcpy(s, "PinNumber should be 1 to 9");
	    Tcl_SetResult(interp, s, TCL_VOLATILE);
	    return TCL_ERROR;
	}
	if ((broche == 3) || (broche == 4) || (broche == 7)) {
	    // sortie
	    if (argc >= 4) {
		bitvalue = (unsigned char) atoi(argv[3]);
		if (broche == 3) {
		    a = comadress + 3;
		    audelabyte = libtel_in(a);
		    if (bitvalue == 0)
			audelabyte = (audelabyte & 191);	/* 10111111 */
		    if (bitvalue == 1)
			audelabyte = (audelabyte | 64);	/* 01000000 */
		}
		if (broche == 4) {
		    a = comadress + 4;
		    audelabyte = libtel_in(a);
		    if (bitvalue == 0)
			audelabyte = (audelabyte & 254);	/* 11111110 */
		    if (bitvalue == 1)
			audelabyte = (audelabyte | 1);	/* 00000001 */
		}
		if (broche == 7) {
		    a = comadress + 4;
		    audelabyte = libtel_in(a);
		    if (bitvalue == 0)
			audelabyte = (audelabyte & 253);	/* 11111101 */
		    if (bitvalue == 1)
			audelabyte = (audelabyte | 2);	/* 00000010 */
		}
		libtel_out(a, audelabyte);
		strcpy(s, "");
		retour = TCL_OK;
	    } else {
		strcpy(s, "BitValue should be 0|1");
		retour = TCL_ERROR;
	    }
	    Tcl_SetResult(interp, s, TCL_VOLATILE);
	    return retour;
	} else if ((broche == 1) || (broche == 6) || (broche == 8) || (broche == 9)) {
	    // entree
	    a = comadress + 6;
	    audelabyte = libtel_in(a);
	    if (broche == 1)
		bitvalue = (audelabyte & 128) >> 7;	/* 10000000 */
	    if (broche == 6)
		bitvalue = (audelabyte & 32) >> 5;	/* 00100000 */
	    if (broche == 8)
		bitvalue = (audelabyte & 16) >> 4;	/* 00010000 */
	    if (broche == 9)
		bitvalue = (audelabyte & 64) >> 6;	/* 01000000 */
	    sprintf(s, "%u", bitvalue);
	    Tcl_SetResult(interp, s, TCL_VOLATILE);
	    return TCL_OK;
	} else {
	    // autres
	    Tcl_SetResult(interp, "", TCL_VOLATILE);
	    return TCL_OK;
	}
    }
    return TCL_OK;
}

extern int Combit_Init(Tcl_Interp * interp)
{
    if (interp == NULL)
	return TCL_ERROR;

    if (Tcl_InitStubs(interp, "8.3", 0) == NULL) {
	Tcl_SetResult(interp, "Tcl Stubs initialization failed in libaudela.", TCL_STATIC);
	return TCL_ERROR;
    }

    Tcl_CreateCommand(interp, "combit", (Tcl_CmdProc *) CmdComBit, NULL, NULL);

    return TCL_OK;
}
