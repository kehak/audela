# Tcl package index file - handcrafted
#
# $Id: pkgIndex.tcl.in,v 1.12 2002/10/28 10:54:14 balls Exp $

package ifneeded xml::c       2.6 [list load   [file join $dir Tclxml26.dll]]
package ifneeded xml::tcl     2.6 [list source [file join $dir xml__tcl.tcl]]
package ifneeded sgmlparser   1.0       [list source [file join $dir sgmlparser.tcl]]
package ifneeded xpath        1.0       [list source [file join $dir xpath.tcl]]
package ifneeded xmldep       1.0       [list source [file join $dir xmldep.tcl]]

# The C parsers are provided through their own packages and indices,
# and thus do not have to be listed here. This index may require them
# in certain places, but does not provide them. This is part of the
# work refactoring the build system of TclXML to create clean
# packages, and not require a jumble (jungle?) of things in one Makefile.
#
#package ifneeded xml::expat  2.6 [list load   [file join $dir @expat_TCL_LIB_FILE@]]
#package ifneeded xml::xerces 2.0       [list load   [file join $dir @xerces_TCL_LIB_FILE@]]


namespace eval ::xml {}

# Requesting a specific package means we want it to be the default parser class.
# This is achieved by loading it last.

# expat and xerces packages must have xml::c package loaded
package ifneeded expat 2.6 {
    package require xml::c 2.6
    package require xmldefs
    package require xml::tclparser 2.6
    package require xml::expat     2.6
    package provide expat          2.6
}

# tclparser works with either xml::c or xml::tcl
package ifneeded tclparser 2.6 {
    if {[catch {package require xml::c 2.6}]} {
	# No point in trying to load expat
	package require xml::tcl       2.6
	package require xmldefs
	package require xml::tclparser 2.6
    } else {
	package require xmldefs
	catch {package require xml::expat 2.6}
	package require xml::tclparser
    }
    package provide tclparser 2.6
}

# use tcl only (mainly for testing)
package ifneeded puretclparser 2.6 {
    package require xml::tcl       2.6
    package require xmldefs
    package require xml::tclparser 2.6
    package provide puretclparser  2.6
}                                        

# Requesting the generic package leaves the choice of default parser automatic

package ifneeded xml 2.6 {
    if {[catch {package require xml::c 2.6}]} {
	package require xml::tcl       2.6
	package require xmldefs
	# Only choice is tclparser
	package require xml::tclparser 2.6
    } else {
	package require xmldefs
	package require xml::tclparser    2.6
	catch {package require xml::expat 2.6}
    }
    package provide xml 2.6
}

if {[info tclversion] <= 8.0} {
    package ifneeded sgml           1.9       [list source [file join $dir sgml-8.0.tcl]]
    package ifneeded xmldefs        2.6 [list source [file join $dir xml-8.0.tcl]]
    package ifneeded xml::tclparser 2.6 [list source [file join $dir tclparser-8.0.tcl]]
} else {
    package ifneeded sgml           1.9       [list source [file join $dir sgml-8.1.tcl]]
    package ifneeded xmldefs        2.6 [list source [file join $dir xml-8.1.tcl]]
    package ifneeded xml::tclparser 2.6 [list source [file join $dir tclparser-8.1.tcl]]
}


