if { $::tcl_platform(os) == "Linux" } {
   package ifneeded Memchan 2.2.1  [list load [file join $dir libMemchan2.2.1.so]]
} else {
   package ifneeded Memchan 2.2.1  [list load [file join $dir Memchan221.dll]]
}
