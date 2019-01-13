#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 9990 2013-08-18 17:29:05Z robertdelmas $
#

package ifneeded serialport 2.0 [ list source [ file join $dir serialport.tcl ] ]

