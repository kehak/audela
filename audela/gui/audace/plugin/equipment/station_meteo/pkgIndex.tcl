#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 9831 2013-07-24 17:19:11Z robertdelmas $
#

package ifneeded station_meteo 1.0 [ list source [ file join $dir station_meteo.tcl ] ]

