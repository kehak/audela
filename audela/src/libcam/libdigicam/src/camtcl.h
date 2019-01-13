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

/*
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 */

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#define SPECIFIC_CMDLIST \
   {"autoload",            (Tcl_CmdProc *)cmdCamAutoLoadFlag}, \
   {"delete",              (Tcl_CmdProc *)cmdCamAutoDeleteFlag}, \
   {"drivemode",           (Tcl_CmdProc *)cmdCamDriveMode}, \
   {"quality",             (Tcl_CmdProc *)cmdCamQuality}, \
   {"systemservice",       (Tcl_CmdProc *)cmdCamSystemService}, \
   {"longuepose",          (Tcl_CmdProc *)cmdCamLonguePose}, \
   {"longueposelinkno",    (Tcl_CmdProc *)cmdCamLonguePoseLinkno}, \
   {"longueposelinkbit",   (Tcl_CmdProc *)cmdCamLonguePoseLinkbit}, \
   {"longueposestartvalue",(Tcl_CmdProc *)cmdCamLonguePoseStartValue}, \
   {"longueposestopvalue", (Tcl_CmdProc *)cmdCamLonguePoseStopValue},

 /* === Specific commands for that camera === */
int cmdCamAutoLoadFlag(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamAutoDeleteFlag(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamDriveMode(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamQuality(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamLonguePose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamLonguePoseLinkno(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamLonguePoseLinkbit(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamLonguePoseStartValue(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamLonguePoseStopValue(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdCamSystemService(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

 /* === Specific commands for that camera === */


#endif
