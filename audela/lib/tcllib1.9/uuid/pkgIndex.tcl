# pkgIndex.tcl - 
#
# uuid package index file
#
# $Id: pkgIndex.tcl,v 1.1 2008-11-29 23:05:09 denismarchais Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded uuid 1.0.1 [list source [file join $dir uuid.tcl]]
