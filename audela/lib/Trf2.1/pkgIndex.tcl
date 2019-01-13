if { $::tcl_platform(os) == "Linux" } {
   package ifneeded Trf 2.1  [list load [file join $dir libTrf2.1.so]]
} else {
   package ifneeded Trf 2.1  [list load [file join $dir Trf21.dll]]
}
