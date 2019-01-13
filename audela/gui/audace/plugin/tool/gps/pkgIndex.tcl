#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

package ifneeded gps 3.8 [ list source [ file join $dir gps.tcl ] ]

