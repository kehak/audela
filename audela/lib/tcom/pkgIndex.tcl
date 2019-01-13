# $Id: pkgIndex.tcl,v 1.2 2010-01-31 17:25:49 michelpujol Exp $
package ifneeded tcom 3.9 \
[list load [file join $dir tcom.dll]]\n[list source [file join $dir tcom.tcl]]
