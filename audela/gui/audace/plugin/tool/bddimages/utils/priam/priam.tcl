#--------------------------------------------------
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/priam/priam.tcl
#--------------------------------------------------
#
# Fichier        : priam.tcl
# Description    : Utilisation de Priam pour faire l astrometrie
# Auteur         : Frederic Vachier
# Mise à jour $Id: priam.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::priam {


# FIC.MES

# #? Centroid measures formatted for Priam
# #?   Source: Tasp/idl - mai 2004
# #? Object: 1446 Sillanpaa 
# #
# #> orientation: wn
# #
# #! Frame: /observ/ohp/T120/2009/test/n1/p68484f1.fits
# 2454908.5137460064   20.00 1013.500  35.0   0.57000
# S 2.618036E+02 6.804010E-02 6.224708E+02 8.501132E-02 4.471942E+00 3.288280E+00 1.769230E+01 NewObj
# R 6.797814E+02 3.830099E-03 8.745620E+02 4.537117E-03 3.725335E+00 4.525925E+00 1.185362E+01 Star_1

# LOCAL.CAT
# 2MASS_12585626+0052218    12 58 56.261520 +00 52 21.87840 0.00 0.00 2451545.50  100.0 100.0  0.00  0.00  16.083 ?    0.00 0.0

# {IMG {105.94394 4.34557 5 +14.0326 0.036} 
#      {4133 3 1455.26 1236.98 +12.432 0.036 2483.4 81.3 105.94394 4.34557 +14.0326 +13.8275 0.3848 +13.8527 0.3839 221 150 994.2 +0.63 -0.08 -0.16 +1.29 +0.94 -12.1 3.26 0}} 
#      {USNOA2 {105.94394 4.34557 5.0 +14.0326 0.3848} {}} 
#      {PHOTOM {} {1455.214748 1237.066546 2.946869 2.521896 2.7343825 1467.000000 0 1239.000000 227.0 38.759163 37.8491145436 5.85667961922 3.26 0.0976624473377}}
   

proc ::priam::create_file_oldformat { listsources stars listmesure } {

   global bddconf

   ::manage_source::imprim_3_sources $listsources

   # creation du fichier de mesures
   set filemes [file join $bddconf(dirtmp) aster.mes]
   set chan0 [open $filemes w]
   puts $chan0 "#? Centroid measures formatted for Priam"
   puts $chan0 "#?   Source: Audela - jan. 2012"
   puts $chan0 "#? Object: 234 Barbara"
   puts $chan0 "#"
   puts $chan0 "#> orientation: wn"
   puts $chan0 "#"
   puts $chan0 "#! Frame: ./IMG0.fits"
   puts $chan0 "2454908.5137460064   20.00 1013.500  35.0   0.57000"

   # creation du fichier stellaire
   set filelocal [file join $bddconf(dirtmp) local.cat]
   set chan1 [open $filelocal w]

   set fields  [lindex $listsources 0]
   foreach s $fields { 
      ::console::affiche_resultat "$s\n"
   }
   set index 0
   set newsources {}
   set sources [lindex $listsources 1]
   foreach s $sources {
      foreach cata $s {
         if {[lindex $cata 0] == $stars} {
            foreach u $s {
               if {[lindex $u 0] == "IMG"} {
                  set data [lindex $u 1]
                  set odata [lindex $u 2]
               }
            }
            incr index
            set px [lindex $odata 2]
            set py [lindex $odata 3]
            set ra [mc_angle2hms [lindex $data 0]] 
            set dec [mc_angle2dms [lindex $data 1]]
            set mag [lindex $data 3]
            puts $chan0 "R $px 0.01 $py 0.01 1.0 1.0 $mag USNOA2_$index"
            puts $chan1 "USNOA2_$index $ra $dec 0.00 0.00 2451545.50  100.0 100.0  0.00  0.00  $mag ?    0.00 0.0"
         }
      }
   }

   close $chan0
   close $chan1
}


}
