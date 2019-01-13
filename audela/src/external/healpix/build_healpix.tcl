# This scripts build the single C file to include HEALPix in Tcl extension.
#
# source "$audace(rep_install)/src/external/healpix/build_healpix.tcl"
#

set comments ""
append comments "/* -----------------------------------------------------------------------------\n"
append comments " * This file is adapted from the HEALPix library to be used in Tcl extensions\n"
append comments " */\n"
append comments "/* -----------------------------------------------------------------------------\n"
append comments " *\n"
append comments " *  Copyright (C) 1997-2010 Krzysztof M. Gorski, Eric Hivon,\n"
append comments " *                          Benjamin D. Wandelt, Anthony J. Banday, \n"
append comments " *                          Matthias Bartelmann, \n"
append comments " *                          Reza Ansari & Kenneth M. Ganga \n"
append comments " *\n"
append comments " *\n"
append comments " *  This file is part of HEALPix.\n"
append comments " *\n"
append comments " *  HEALPix is free software; you can redistribute it and/or modify\n"
append comments " *  it under the terms of the GNU General Public License as published by\n"
append comments " *  the Free Software Foundation; either version 2 of the License, or\n"
append comments " *  (at your option) any later version.\n"
append comments " *\n"
append comments " *  HEALPix is distributed in the hope that it will be useful,\n"
append comments " *  but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
append comments " *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
append comments " *  GNU General Public License for more details.\n"
append comments " *\n"
append comments " *  You should have received a copy of the GNU General Public License\n"
append comments " *  along with HEALPix; if not, write to the Free Software\n"
append comments " *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA\n"
append comments " *\n"
append comments " *  For more information about HEALPix see http://healpix.jpl.nasa.gov\n"
append comments " *\n"
append comments " *----------------------------------------------------------------------------- */\n"

set pathin $audace(rep_install)/src/external/healpix/src/C/subs
set pathout $audace(rep_install)/src/external/healpix

# set fichiers [lsort [glob $pathin/*]]
# foreach fichier $fichiers {
# 	::console::affiche_resultat "[file tail $fichier]\n"
# }

# no FITS utils
set fics ""
lappend fics "ang2pix_nest.c"
lappend fics "ang2pix_ring.c"
lappend fics "ang2vec.c"
lappend fics "mk_pix2xy.c"
lappend fics "mk_xy2pix.c"
lappend fics "nest2ring.c"
lappend fics "npix2nside.c"
lappend fics "nside2npix.c"
lappend fics "pix2ang_nest.c"
lappend fics "pix2ang_ring.c"
lappend fics "pix2vec_nest.c"
lappend fics "pix2vec_ring.c"
lappend fics "ring2nest.c"
lappend fics "vec2ang.c"
lappend fics "vec2pix_nest.c"
lappend fics "vec2pix_ring.c"

set textout ""
set includes ""
foreach fic $fics {
	set fichier ${pathin}/${fic}
	::console::affiche_resultat "[file tail $fichier]\n"
	set f [open $fichier r]
	set lignes [split [read $f] \n]
	close $f
	set header 1
	foreach ligne $lignes {
		if {$header==1} {
			set k [string first "*/" $ligne]
			if {$k>=0} {
				set header 2
			}
			continue
		}		
		set k [string first "/* Standard Includes */" $ligne]
		if {$k>=0} {
			continue
		}
		set k [string first "/* Local Includes */" $ligne]
		if {$k>=0} {
			continue
		}
		set k [string first "#include" $ligne]		
		if {$k>=0} {
			lappend includes "$ligne"
			continue
		}
		append textout "$ligne\n"
	}
}
set includes [lsort $includes]
set textinc ""
set previnc ""
foreach include $includes {
	if {$include==$previnc} {
		continue
	}
	set previnc $include
	set k [string first "fitsio.h" $include]
	if {$k>=0} {
		continue
	}
	append textinc "$include\n"
}
	
set fichier ${pathout}/chealpix.c
::console::affiche_resultat "=> [file tail $fichier]\n"
set f [open $fichier w]
puts $f $comments
puts $f $textinc
puts $f "#define M_PI 3.1415926535897932384626434\n"
puts -nonewline $f $textout
close $f
file copy -force -- $pathin/chealpix.h $pathout/chealpix.h
