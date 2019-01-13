#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 9977 2013-08-17 16:48:07Z robertdelmas $
#

package ifneeded dslr 3.0 [ list source [ file join $dir dslr.tcl ] ]

