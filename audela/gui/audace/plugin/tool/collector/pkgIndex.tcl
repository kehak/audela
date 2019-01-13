#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 8779 2012-11-17 11:11:41Z robertdelmas  $
#

package ifneeded collector 1.0 [ list source [ file join $dir collector.tcl ] ]

