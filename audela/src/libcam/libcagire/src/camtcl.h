/* camtcl.h
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

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#define SPECIFIC_CMDLIST \
   {"test",           (Tcl_CmdProc *)cmdCagireTest}, \
   {"channel",        (Tcl_CmdProc *)cmdCagireChannel}, \
   {"initialize",     (Tcl_CmdProc *)cmdCagireInitialize}, \
   {"put",            (Tcl_CmdProc *)cmdCagirePut}, \
   {"read",           (Tcl_CmdProc *)cmdCagireRead}, \
   {"putread",        (Tcl_CmdProc *)cmdCagirePutRead},

// ----- defines specifiques aux fonctions de cette camera ----
int cmdCagireTest(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
int cmdCagirePut(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
int cmdCagireRead(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
int cmdCagirePutRead(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
int cmdCagireChannel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
int cmdCagireInitialize(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);

#endif
