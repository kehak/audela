#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 12809 2016-01-22 17:11:30Z robertdelmas $
#

package ifneeded joystick 1.0 [ list source [ file join $dir joystick.tcl ] ]

