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
   /* === Specific commands for that telescope ===*/
   {"action", (Tcl_CmdProc *)cmdTelAction},\
   {"loopeval", (Tcl_CmdProc *)cmdTelLoopEval},\
   {"loopresult", (Tcl_CmdProc *)cmdTelLoopResult},\
   {"hexaeval", (Tcl_CmdProc *)cmdTelHexaEval},\
   {"hexaresult", (Tcl_CmdProc *)cmdTelHexaResult},\
   {"allcoord", (Tcl_CmdProc *)cmdTelAllCoord},\
   {"allcoordjd", (Tcl_CmdProc *)cmdTelAllCoordJd},\
   {"hadec", (Tcl_CmdProc *)cmdTelHaDec},\
   {"adu", (Tcl_CmdProc *)cmdTelAdu},\
   {"eeprom", (Tcl_CmdProc *)cmdTelEeprom},\
   /* === Last function terminated by NULL pointers ===*/
   {NULL, NULL}
};

#ifdef __cplusplus
}
#endif      // __cplusplus
