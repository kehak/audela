/* camtcl.h
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

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#define SPECIFIC_CMDLIST \
    {"shuttertype", (Tcl_CmdProc *) cmdOscadineShutterType}, \
    {"ampli", (Tcl_CmdProc *) cmdOscadineAmpli}, \
    {"delayshutter", (Tcl_CmdProc *) cmdOscadineDelayshutter},

/* ----- defines specifiques aux fonctions de cette camera ----*/
int cmdOscadineShutterType(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdOscadineAmpli(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdOscadineDelayshutter(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

#endif
