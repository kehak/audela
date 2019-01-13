#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 8659 2012-09-22 17:40:41Z robertdelmas  $
#

package ifneeded echip 1.0 [ list source [ file join $dir echip.tcl ] ]

