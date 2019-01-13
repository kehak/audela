#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 9612 2013-06-28 16:18:05Z robertdelmas $
#

package ifneeded acqfast 1.0 [ list source [ file join $dir acqfast.tcl ] ]

