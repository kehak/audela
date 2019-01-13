# $Id: pkgIndex.tcl,v 1.3 2011-01-18 20:16:11 jacquesmichelet Exp $

proc load_tkhtml { dir } {
    if { $::tcl_platform(os) == "Linux" } {
        set fso [file join $dir libTkhtml3.0[info sharedlibextension]]
        if {[file exists $fso]==1} {
            return [ load $fso ]
        } else {            
           if { $::tcl_platform(pointerSize) == 4 } {
               # Mode 32 bits
               return [ load [ file join $dir Tkhtml3_32[info sharedlibextension] ] ]
           } else {
               # Mode 64 bits
               return [ load [ file join $dir Tkhtml3_64[info sharedlibextension] ] ]
           }
        }
    } else {
        return [ load [ file join $dir Tkhtml3[info sharedlibextension] ] ]
    }
}

set err [catch {package present Tk} msg]
if {$err==0} {
   package ifneeded Tkhtml 3.0 [ load_tkhtml $dir ]
}
