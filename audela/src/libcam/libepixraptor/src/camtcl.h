/* camtcl.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2013 The AudeLA Core Team
 *
 * Initial author : Matteo SCHIAVON <ilmona89@gmail.com>
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
	{"framerate", (Tcl_CmdProc *)cmdCamFrameRate}, \
	{"exposure", (Tcl_CmdProc *)cmdCamExposure}, \
	{"roi", (Tcl_CmdProc *)cmdCamRoi}, \
	{"dynamicrange", (Tcl_CmdProc *)cmdCamDynamicRange}, \
	{"getframebuffer", (Tcl_CmdProc *)cmdCamGetFrameBuffer}, \
	{"setframebuffer", (Tcl_CmdProc *)cmdCamSetFrameBuffer}, \
	{"reset", (Tcl_CmdProc *)cmdCamReset}, \
	{"digitalgain", (Tcl_CmdProc *)cmdCamDigitalGain}, \
	{"videostart", (Tcl_CmdProc *)cmdCamVideoStart}, \
	{"videostop", (Tcl_CmdProc *)cmdCamVideoStop}, \
	{"videopause", (Tcl_CmdProc *)cmdCamVideoPause}, \
	{"videomode", (Tcl_CmdProc *)cmdCamVideoMode}, \
	{"getbufferts", (Tcl_CmdProc *)cmdCamGetBufferTs}, \
	{"currentbuffer", (Tcl_CmdProc *)cmdCamCurrentBuffer}, \
	{"lastbuffer", (Tcl_CmdProc *)cmdCamLastBuffer}, \
	{"maxbuffer", (Tcl_CmdProc *)cmdCamMaxBuffer}, \
	{"maxframerate", (Tcl_CmdProc *)cmdCamMaxFrameRate}, \
	{"maxexposure", (Tcl_CmdProc *)cmdCamMaxExposure}, \
	{"livestart", (Tcl_CmdProc *)cmdCamLiveStart}, \
	{"livestop", (Tcl_CmdProc *)cmdCamLiveStop}, \
	{"pcbtemp", (Tcl_CmdProc *)cmdCamPcbTemp}, \


 /* === Specific commands for that camera === */
int cmdCamFrameRate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamExposure(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamRoi(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamDynamicRange(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamGetFrameBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamSetFrameBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamReset(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamDigitalGain(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamVideoStart(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamVideoStop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamVideoPause(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamVideoMode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamGetBufferTs(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamCurrentBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamLastBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamMaxBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamMaxFrameRate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamMaxExposure(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamLiveStart(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamLiveStop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdCamPcbTemp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#endif
