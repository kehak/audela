# Tcl package index file, version 1.0 for WINDOWS

proc Blt_MakePkgIndex { dir } {
    set suffix [info sharedlibextension]
    set version 2.4
    regsub {\.} $version {} version_no_dots
    foreach lib {  } {
	catch { load ${lib}${suffix} BLT }
    }
    # Determine whether to load the normal BLT library or
    # the "lite" tcl-only version.
    if { [info commands tk] == "tk" } {
        set library BLT${version_no_dots}${suffix}
    } else {
        set library BLTlite${version_no_dots}${suffix}
    }
    set library [file join $dir ${library}]
    #global tcl_platform
    #if { $tcl_platform(platform) == "unix" } {
    #	set library [file join [file dirname $dir] lib${library}]
    #}
    package ifneeded BLT ${version} [list load $library BLT]
}

Blt_MakePkgIndex $dir
rename Blt_MakePkgIndex ""

#set suffix [info sharedlibextension]
#package ifneeded BLT 2.4 [list load [file join $dir BLT24${suffix}]]
