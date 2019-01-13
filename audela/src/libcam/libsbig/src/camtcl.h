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

//    {"close", (Tcl_CmdProc *) cmdSbigClose},

#define SPECIFIC_CMDLIST \
    {"infotemp", (Tcl_CmdProc *) cmdSbigInfotemp}, \
    {"activaterelay", (Tcl_CmdProc *) cmdSbigActivateRelay}, \
    {"pulseout", (Tcl_CmdProc *) cmdSbigPulseOut}, \
    {"aotiptilt", (Tcl_CmdProc *) cmdSbigAOTipTilt}, \
    {"aodelay", (Tcl_CmdProc *) cmdSbigAODelay}, \
    {"buftrack", (Tcl_CmdProc *) cmdSbigBufTrack}, \
    {"acqtrack", (Tcl_CmdProc *) cmdSbigAcqTrack}, \
    {"stoptrack", (Tcl_CmdProc *) cmdSbigStopTrack}, \
    {"windowtrack", (Tcl_CmdProc *) cmdSbigWindowTrack}, \
    {"exptimetrack", (Tcl_CmdProc *) cmdSbigExptimeTrack}, \
    {"bintrack", (Tcl_CmdProc *) cmdSbigBinTrack},\
    {"cfw", (Tcl_CmdProc *) cmdSbigCFW},


 /* === Specific commands for that camera === */
//int cmdSbigClose(ClientData clientData, Tcl_Interp * interp, int argc,
//		 char *argv[]);
int cmdSbigInfotemp(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[]);
int cmdSbigActivateRelay(ClientData clientData, Tcl_Interp * interp,
			 int argc, char *argv[]);
int cmdSbigPulseOut(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[]);
int cmdSbigAOTipTilt(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[]);
int cmdSbigAODelay(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[]);
int cmdSbigBufTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[]);
//void AcqReadTrack(ClientData clientData);
int cmdSbigAcqTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[]);
int cmdSbigStopTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[]);
int cmdSbigWindowTrack(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdSbigExptimeTrack(ClientData clientData, Tcl_Interp * interp,
			int argc, char *argv[]);
int cmdSbigBinTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[]);
int cmdSbigCFW(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[]);

/* ----- defines specifiques aux fonctions de cette camera ----*/


#endif
