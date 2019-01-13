#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 12818 2016-01-22 22:31:41Z robertdelmas $
#

package ifneeded viseur_polaire 2.0 [ list source [ file join $dir viseur_polaire_go.tcl ] ]

