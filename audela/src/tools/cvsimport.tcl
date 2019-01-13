#!/usr/local/bin/tclsh8.0
#
# Fichier : cvsimport.tcl
# Description : imoprtation d'un repertoire non cvs vers un repertoire cvs
# Auteur : Denis MARCHAIS
# Date de MAJ : 01 Fevrier 2005
#

global base base2

proc Log {args} {
	#::console::affiche_resultat "$f\n"
	eval puts $args
}

# Parcourt l'arborescence sous CVS pour effacer tous les fichiers, sauf
# les fichiers administratifs de CVS. (Etape 1)
proc recurs { subdir } {
	global base base2
	Log "Dir: $subdir"
	set files [glob -nocomplain [file join "$base" "$subdir" *] ]
	foreach f $files {
		#puts "$f"
		if {[ file isdirectory $f ]} {
			if {[string compare [file tail $f] cvs]} {
				Log "  Go to:subdir=$subdir, f=$f, [file join "$subdir" "[file tail $f]"]"
				recurs [file join "$subdir" "[file tail $f]"]
			}
		} else {
			file delete -force "$f"
			Log " file deleted : $f"
		}
	}
	Log "End dir: $subdir"
}

# Parcourt l'arvorescence non CVS, et copie les fichiers/cree les repertoires
# vers l'arborescence sous CVS. (Etape 2)
proc recurs2 { subdir } {
	global base base2
	Log "Dir: $subdir"
	set files [glob -nocomplain [file join "$base2" "$subdir" *] ]
	foreach f $files {
		#puts "$f"
		if {[ file isdirectory $f ]} {
			if { ![file exists [file join $base $subdir [file tail $f]]] } {
				set d "[file join $base $subdir [file tail $f]]"
				file mkdir $d
				Log " dir created: $d"
			}
			recurs2 [file join $subdir [file tail $f]]
		} else {
			set f2 [file join $base $subdir [file tail $f]]
			file copy -force $f $f2
			Log " file copied: $f -> $f2"
		}
	}
	Log "End dir: $subdir"
}


set base  "d:/tmp/tmp/audace"
set base2 "d:/tmp/tmp/audace_new"

