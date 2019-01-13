# -*- tcl -*- $Id: config_peg.tcl,v 1.1 2008-11-29 23:05:08 denismarchais Exp $

package provide page::config::peg 0.1

proc page_cdefinition {} {
    return {
	--reset
	--append
	--reader    peg
	--transform reachable
	--transform realizable
	--writer    me
    }
}
