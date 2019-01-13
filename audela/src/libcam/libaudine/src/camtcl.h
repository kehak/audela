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
   {"scan",           (Tcl_CmdProc *)cmdAudineScan}, \
   {"breakscan",      (Tcl_CmdProc *)cmdAudineBreakScan}, \
   {"scanloop",       (Tcl_CmdProc *)cmdAudineScanLoop}, \
   {"set0",           (Tcl_CmdProc *)cmdAudineSet0}, \
   {"set255",         (Tcl_CmdProc *)cmdAudineSet255}, \
   {"test",           (Tcl_CmdProc *)cmdAudineTest}, \
   {"test2",          (Tcl_CmdProc *)cmdAudineTest2}, \
   {"shuttertype",    (Tcl_CmdProc *)cmdAudineShutterType}, \
   {"obtupierre",     (Tcl_CmdProc *)cmdAudineObtupierre}, \
   {"obtupierretest", (Tcl_CmdProc *)cmdAudineObtupierreTest}, \
   {"outtime",        (Tcl_CmdProc *)cmdAudineOutTime}, \
   {"ampli",          (Tcl_CmdProc *)cmdAudineAmpli}, \
   {"portadress",     (Tcl_CmdProc *)cmdAudinePortAdress}, \
   {"updatelog",      (Tcl_CmdProc *)cmdAudineUpdateLog}, \
   {"wipe",           (Tcl_CmdProc *)cmdAudineWipe}, \
   {"read",           (Tcl_CmdProc *)cmdAudineRead}, \
   {"cantype",        (Tcl_CmdProc *)cmdAudineCantype}, \
   {"acqnormal",      (Tcl_CmdProc *)cmdAudineAcqNormal}, \
   {"acqspecial",     (Tcl_CmdProc *)cmdAudineAcqSpecial},

 /* === Specific commands for that camera === */
int cmdAudineScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineBreakScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineScanLoop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineSet0(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineSet255(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineTest(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineTest2(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineShutterType(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineObtupierre(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineObtupierreTest(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineOutTime(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineAmpli(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudinePortAdress(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineAcqNormal(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineAcqSpecial(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineUpdateLog(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineRead(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineWipe(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdAudineCantype(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

#endif
