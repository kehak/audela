#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 9974 2013-08-17 15:21:44Z robertdelmas $
#

package ifneeded webcam 3.0 [ list source [ file join $dir webcam.tcl ] ]

