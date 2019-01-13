/* camtcl.c
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

/*
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
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


//void AcqRead(ClientData clientData);
extern struct camini CAM_INI[];


int cmdAtikCoolerInformations(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    struct camprop *cam;
	/////////////////////////////////////////////////
	// Returns information on the Peltier cooler.
	// flags: b0-4 capabilities
	// b0 0 = no cooling 1=cooling
	// b1 0= always on 1= controllable
	// b2 0 = on/off control not available 1= on off cooling control
	// b3 0= no selectable power levels 1= selectable power levels
	// b4 0 = no temperature set point cooling 1= set point cooling
	// b5-7 report what’s actually happening
	// b5 0=normal control 1=warming up
	// b6 0=cooling off 1=cooling on
	// b7 0= no set point control 1=set point control
	// level is the current cooler power level.
	// minlvl is the minimum power level than can be set on order to prevent
	// rapid warming.
	// maxlvl is the maximum power level than can be set or returned, can be
	// used to scale power to a percentage.
	// setpoint is the current temperature setpoint, in degrees Celsius * 100
	// Error code on error
	char list[12048],elem[1024];
	cam = (struct camprop *) clientData;
	atik_cooler_informations(cam);
	strcpy(list,"");
	sprintf(elem,"{b0_cooling %d {0 = no cooling 1=cooling}} ",cam->b0_cooling);
	strcat(list,elem);
	sprintf(elem,"{b1_controllable %d {0= always on 1= controllable}} ",cam->b1_controllable);
	strcat(list,elem);
	sprintf(elem,"{b2_on_off_cooling_control %d {0 = on/off control not available 1= on/off cooling control}} ",cam->b2_on_off_cooling_control);
	strcat(list,elem);
	sprintf(elem,"{b3_selectable_power_levels %d {0= no selectable power levels 1= selectable power levels}} ",cam->b3_selectable_power_levels);
	strcat(list,elem);
	sprintf(elem,"{b4_set_point_cooling_available %d {0 = no temperature set point cooling 1= set point cooling}} ",cam->b4_set_point_cooling_available);
	strcat(list,elem);
	sprintf(elem,"{b5_state_warming_up %d {0=normal control 1=warming up}} ",cam->b5_state_warming_up);
	strcat(list,elem);
	sprintf(elem,"{b6_state_cooling_on %d {0=cooling off 1=cooling on}} ",cam->b6_state_cooling_on);
	strcat(list,elem);
	sprintf(elem,"{b7_state_set_point_control %d {0= no set point control 1=set point control}} ",cam->b7_state_set_point_control);
	strcat(list,elem);
	sprintf(elem,"{level %d {relative to maxlvl}} ",cam->cooler_power_level);
	strcat(list,elem);
	sprintf(elem,"{minlvl %d {ADU}} ",cam->minlvl);
	strcat(list,elem);
	sprintf(elem,"{maxlvl %d {ADU}} ",cam->maxlvl);
	strcat(list,elem);
	sprintf(elem,"{current_temperature_setpoint %.2f {Degree Celcius}} ",cam->current_temperature_setpoint);
	strcat(list,elem);
	Tcl_SetResult(interp,list,TCL_VOLATILE);
   return TCL_OK;
}

/***********************************************************************/
/*                                                                     */
/* INPUTS                                                              */
/* none                                                                */
/*                                                                     */
/* OUTPUT                                                              */
/* float : check temperature (deg. Celcius)                            */
/* float : CCD temperature (deg. Celcius)                              */
/* float : ambient temperature (deg. Celcius)                          */
/* int   : regulation, 1=on, 0=off                                     */
/* int   : Peltier power, (0-255=0-100%)                               */
/***********************************************************************/
int cmdAtikInfotemp(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	/*
	// setpoint = température de consigne
	// ccd = température du ccd
	// ambient = température ambiante
	// reg = régulation ?
	// power = puissance du peltier (0-255=0-100%)
	*/
	struct camprop *cam;
	double ambient=0;
	char s[256];
	cam = (struct camprop *) clientData;
	atik_cooler_informations(cam);
	sprintf(s, "%.2f %.2f %.2f %d %d", cam->current_temperature_setpoint,cam->temperature,ambient,cam->b2_on_off_cooling_control,cam->cooler_power_level);
	Tcl_SetResult(interp, s, TCL_VOLATILE);
	return TCL_OK;
}
