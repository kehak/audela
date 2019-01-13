# pkgIndex.tcl                                                    -*- tcl -*-
# $Id: pkgIndex.tcl,v 1.1 2008-11-29 23:05:07 denismarchais Exp $
if { ![package vsatisfies [package provide Tcl] 8.3] } {
    # PRAGMA: returnok
    return 
}
package ifneeded irc 0.6 [list source [file join $dir irc.tcl]]
