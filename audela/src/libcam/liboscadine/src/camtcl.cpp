/* camtcl.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

extern struct camini CAM_INI[];

char *cam_shuttertypes[] = {
    "audine",
    NULL
};

/*
 * -----------------------------------------------------------------------------
 *  cmdOscadineShutterType()
 *
 * Setect the type of shutter. 1 shutter types are supported :
 *  audine : build by Raymond David (Essentiel Electronic)
 *
 * -----------------------------------------------------------------------------
 */
int cmdOscadineShutterType(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    return 0;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdOscadineAmpli()
 *
 * Setect the synchronisation of the CCD amplifier
 *
 * -----------------------------------------------------------------------------
 */
int cmdOscadineAmpli(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    return 0;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdOscadineDelayshutter()
 *
 * Delay between closure of shutter and CCD reading
 *
 * -----------------------------------------------------------------------------
 */
int cmdOscadineDelayshutter(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    return 0;
}


