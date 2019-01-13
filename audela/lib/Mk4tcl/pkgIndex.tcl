if { $::tcl_platform(os) == "Linux" } {
   package ifneeded Mk4tcl 2.4.9.6 [list load [file join $dir Mk4tcl[info sharedlibextension]] Mk4tcl]
} else {
   package ifneeded Mk4tcl 2.4.9.5 [list load [file join $dir Mk4tcl[info sharedlibextension]] Mk4tcl]
}
