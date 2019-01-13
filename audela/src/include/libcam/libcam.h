/* libcam.h
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

#ifndef __LIBCAM_H__
#define __LIBCAM_H__

/*****************************************************************/
/*             This part is common for all cam drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#include "libname.h"
#include "libstruc.h"

struct cmditem {
    const char *cmd;
    Tcl_CmdProc *func;
};

#define COMMON_CMDLIST \
   {"drivername", (Tcl_CmdProc *)cmdCamDrivername},\
   {"name", (Tcl_CmdProc *)cmdCamName},\
   {"product", (Tcl_CmdProc *)cmdCamProduct},\
   {"ccd", (Tcl_CmdProc *)cmdCamCcd},\
   {"dark", (Tcl_CmdProc *)cmdCamDark},\
   {"nbcells", (Tcl_CmdProc *)cmdCamNbcells},\
   {"nbpix", (Tcl_CmdProc *)cmdCamNbpix},\
   {"celldim", (Tcl_CmdProc *)cmdCamCelldim},\
   {"pixdim", (Tcl_CmdProc *)cmdCamPixdim},\
   {"maxdyn", (Tcl_CmdProc *)cmdCamMaxdyn},\
   {"fillfactor", (Tcl_CmdProc *)cmdCamFillfactor},\
   {"rgb", (Tcl_CmdProc *)cmdCamRgb},\
   {"info", (Tcl_CmdProc *)cmdCamInfo},\
   {"port", (Tcl_CmdProc *)cmdCamPort},\
   {"timer", (Tcl_CmdProc *)cmdCamTimer},\
   {"gain", (Tcl_CmdProc *)cmdCamGain},\
   {"readnoise", (Tcl_CmdProc *)cmdCamReadnoise},\
   {"bin", (Tcl_CmdProc *)cmdCamBin},\
   {"exptime", (Tcl_CmdProc *)cmdCamExptime},\
   {"buf", (Tcl_CmdProc *)cmdCamBuf},\
   {"window", (Tcl_CmdProc *)cmdCamWindow},\
   {"acq", (Tcl_CmdProc *)cmdCamAcq},\
   {"stop", (Tcl_CmdProc *)cmdCamStop},\
   {"tel", (Tcl_CmdProc *)cmdCamTel},\
   {"radecfromtel", (Tcl_CmdProc *)cmdCamRadecFromTel},\
   {"shutter", (Tcl_CmdProc *)cmdCamShutter},\
   {"cooler", (Tcl_CmdProc *)cmdCamCooler},\
   {"temperature", (Tcl_CmdProc *)cmdCamTemperature},\
   {"foclen", (Tcl_CmdProc *)cmdCamFoclen},\
   {"interrupt", (Tcl_CmdProc *)cmdCamInterrupt},\
   {"overscan", (Tcl_CmdProc *)cmdCamOverscan}, \
   {"close", (Tcl_CmdProc *)cmdCamClose}, \
   {"mirrorh", (Tcl_CmdProc *)cmdCamMirrorH},\
   {"mirrorv", (Tcl_CmdProc *)cmdCamMirrorV},\
   {"capabilities", (Tcl_CmdProc *)cmdCamCapabilities},\
   {"lasterror", (Tcl_CmdProc *)cmdCamLastError},\
   {"debug", (Tcl_CmdProc *)cmdCamLogLevel},\
   {"logLevel", (Tcl_CmdProc *)cmdCamLogLevel},\
   {"logfile", (Tcl_CmdProc *)cmdCamLogFile},\
   {"threadid", (Tcl_CmdProc *)cmdCamThreadId},\
   {"headerproc", (Tcl_CmdProc *)cmdCamHeaderProc},\
   {"stopmode", (Tcl_CmdProc *)cmdCamStopMode},\



/* --- Utilitaire C-Tcl ---*/


void libcam_GetCurrentFITSDate(Tcl_Interp * interp, char *s);
void libcam_GetCurrentFITSDate_function(Tcl_Interp * interp, char *s,
					char *function);
void libcam_get_tel_coord(Tcl_Interp * interp, double *ra, double *dec,
			  struct camprop *cam, int *status);

void setCameraStatus(struct camprop *cam, const char * status);
void unsetCameraStatus(struct camprop *cam);
void setScanResult(struct camprop *cam, const char * status);
void MainThreadEval(struct camprop *cam, const char * command);

#endif
