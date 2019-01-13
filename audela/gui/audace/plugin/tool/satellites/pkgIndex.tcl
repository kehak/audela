#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 13233 2016-02-20 14:43:03Z rzachantke $
#

package ifneeded satellites 1.0 [ list source [ file join $dir satellites.tcl ] ]

