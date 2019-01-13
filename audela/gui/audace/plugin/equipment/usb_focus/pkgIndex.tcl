#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 9458 2013-05-20 13:53:03Z robertdelmas $
#

package ifneeded usb_focus 1.0 [ list source [ file join $dir usb_focus.tcl ] ]

