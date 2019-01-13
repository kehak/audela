/* telcmd.h
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

#ifdef __cplusplus
extern "C" {      
#endif             // __cplusplus */


static struct cmditem cmdlist[] = {
   /* === Common commands for all telescopes ===*/
   COMMON_CMDLIST
   /* === Specific commands for that telescope ===*/
   {"tempo", (Tcl_CmdProc *)cmdTelTempo},\
   {"slewpath", (Tcl_CmdProc *)cmdTelSlewpath},\
   {"langage", (Tcl_CmdProc *)cmdTelLangage},\
   {"firmware", (Tcl_CmdProc *)cmdTelFirmware},\
   {"slewspeed", (Tcl_CmdProc *)cmdTelSlewspeed},\
   {"nbticks", (Tcl_CmdProc *)cmdTelNbticks},\
   {"boost", (Tcl_CmdProc *)cmdTelBoost},\
   {"driftspeed", (Tcl_CmdProc *)cmdTelDriftspeed},\
   {"pulse", (Tcl_CmdProc *)cmdTelPulse},\
   {"king", (Tcl_CmdProc *)cmdTelKing},\
   {"pec_period", (Tcl_CmdProc *)cmdTelPECPeriod},\
   {"pec_index", (Tcl_CmdProc *)cmdTelPECIndex},\
   {"pec_speed", (Tcl_CmdProc *)cmdTelPECSpeed},\
   {"focspeed", (Tcl_CmdProc *)cmdTelFocspeed},\
   {"initcoord", (Tcl_CmdProc *)cmdTelInitcoord},\
   {"reset", (Tcl_CmdProc *)cmdTelReset},\
   {"backlash",(Tcl_CmdProc *)cmdTelBacklash},\
   /* === Last function terminated by NULL pointers ===*/
   {NULL, NULL}
};

#ifdef __cplusplus
}
#endif      // __cplusplus
