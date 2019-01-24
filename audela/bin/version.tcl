#
# File : version.tcl
#
# This file is part of the AudeLA project : <http://software.audela.free.fr>
# Copyright (C) 1999-2010 The AudeLA Core Team
#
# Initial author : Denis MARCHAIS <denis.marchais@free.fr>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

global audela

set audela(major) "3"
set audela(minor) "0"
set audela(patch) "0"
set audela(extra) "b4" 		;#--- extra="" if stable, or "a1" if alpha, or "b1" if beta 
set audela(revision) "@REVISION@"  	;#--- svn revision
set audela(date) "17/04/2018"

#--- Normalized version number
#--- TCL Version numbers consist of one or more decimal numbers separated by dots, such as 2 or 1.162 or 3.1.13.1. 
#--- In addition, the letters “a” (alpha) and/or “b” (beta) may appear exactly once to replace a dot for separation. 
set audela(version) "$audela(major).$audela(minor).$audela(patch)$audela(extra)"

package provide audela $audela(version) 

namespace eval ::audela {
   global audela

   package provide audela $audela(version)
}

proc ::audela::getPluginType { } {
   return "audela"
}

proc ::audela::getPluginTitle { } {
   return "AudeLA"
}

