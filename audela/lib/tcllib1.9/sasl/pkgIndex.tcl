# pkgIndex.tcl                                                -*- tcl -*-
# Copyright (C) 2005 Pat Thoyts <patthoyts@users.sourceforge.net>
# $Id: pkgIndex.tcl,v 1.1 2008-11-29 23:05:08 denismarchais Exp $
if {![package vsatisfies [package provide Tcl] 8.2]} {
    # PRAGMA: returnok
    return
}
package ifneeded SASL 1.3.1 [list source [file join $dir sasl.tcl]]
package ifneeded SASL::NTLM 1.1.0 [list source [file join $dir ntlm.tcl]]
package ifneeded SASL::XGoogleToken 1.0.0 [list source [file join $dir gtoken.tcl]]
