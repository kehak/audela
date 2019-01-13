/* teltcl.h
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

#ifndef __TELTCL_H__
#define __TELTCL_H__

#ifdef __cplusplus
extern "C" {      
#endif             // __cplusplus */

/* ----- defines specifiques aux fonctions de cette camera ----*/
int cmdTelTempo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelFirmware(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelInitZenith(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelDriftspeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelMechanicalplay(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelGetlatitude(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelGetTsl(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelEncoder(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelCorrectionSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelGerman(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelMotorState(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int cmdTelSolarTracking(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#ifdef __cplusplus
}      
#endif             // __cplusplus */

#endif

