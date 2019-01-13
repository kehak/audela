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
   {"parameter",        (Tcl_CmdProc *)cmdCemesParam}, \
   {"stat_dina",     (Tcl_CmdProc *)cmdStatique_dinamique}, \
   {"balance",     (Tcl_CmdProc *)cmdBalance}, \
   {"setwin",     (Tcl_CmdProc *)cmdSetwindow}, \
   {"peltON",     (Tcl_CmdProc *)cmdPeltierMarche}, \
   {"peltOFF",     (Tcl_CmdProc *)cmdPeltierArret}, \
   {"settemp",     (Tcl_CmdProc *)cmdCemesSetTemp}, \
   {"gettemp",     (Tcl_CmdProc *)cmdCemesGetTemp}, \
   {"reset",     (Tcl_CmdProc *)cmdRESET}, \
   {"ampliobtu",     (Tcl_CmdProc *)cmdCemesObtu},    

/* === Specific commands for that camera === */
#ifdef __cplusplus
extern "C" {
#endif

int cmdPeltierMarche(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdPeltierArret(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCemesParam(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCemesObtu(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCemesGetTemp(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdStatique_dinamique(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdBalance(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdSetwindow(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCemesSetTemp(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdRESET(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

#ifdef __cplusplus
}
#endif

#endif
