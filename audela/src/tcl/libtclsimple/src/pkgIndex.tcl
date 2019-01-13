
proc loadLibrary { dir } {
    set oldcwd [pwd]
    cd $dir
    load [file join $dir libabsimple_tcl[info sharedlibextension]]
    cd $oldcwd
}

package ifneeded absimple 1.0 [list loadLibrary $dir]

