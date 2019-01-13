#! /usr/bin/tclsh
#
# print_package_deps.tcl
#
#   Ce script permet de lister les packets dont a besoin audela 
#   pour fonctionner sous Debian.
#

set DIRECTORY "audela-0.0.20080509/usr/lib/audela/20080509/bin"
set libs [ glob $DIRECTORY/*.so ]
lappend libs $DIRECTORY/audela

set res ""

foreach lib $libs {
	set execres [ exec objdump -p $lib | grep NEEDED ]
	foreach line [ split $execres "\n" ] {
		set libname [ lindex [ split $line " " ] end ]
		if { ! [ catch { exec dpkg -S $libname } m ] } {
			lappend res [ lindex [ split $m : ] 0 ]
		}
	}
}

puts [ lsort -unique $res ]

