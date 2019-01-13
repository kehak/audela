## @file utils/ssp_yd/get_astrometric_catalog.tcl
# @brief  Methode ASTROID pour recuperer un catalogue d'etoiles astrometriques via VO VizieR
# @author Frederic Vachier and Jerome Berthier
# @version 1.0

proc get_astrometric_catalog {ra dec radius} {


   ::console::affiche_resultat "CDSQUERY=($ra, $dec, $radius, TYCHO2)\n"
   # Appel du catalogue TYCHO
   # {
   #  {I/239/tyc_main {The Hipparcos and Tycho Catalogues (ESA 1997)}} 
   #  {TYC RAhms DEdms Vmag RA(ICRS) DE(ICRS) BTmag VTmag B-V} 
   #  {{{ 170  2854 1} {07 00 48.04} {+03 54 53.5} 9.58 105.20017797 3.91485967 11.429 9.740 1.410}
   #   {{ 170  2509 1} {07 01 05.79} {+03 54 17.6} 9.60 105.27411183 3.90488073 11.004 9.718 1.092}
   #   {{ 170  2476 1} {07 01 07.94} {+03 52 20.2} 10.29 105.28309416 3.87228981 11.588 10.402 1.013}
   #  }I/259/tyc2 I/297/out
   # }
   # 2eme forme
   # {
   # {TYC1 TYC2 TYC3 pmRA pmDE BTmag VTmag HIP RA(ICRS) DE(ICRS)} 
   # {
   #  {170 2854 1 1.8 -0.7 11.432 9.716 {} 105.20018639 3.91485778} 
   #  {170 2607 1 -4.0 1.1 11.358 10.992 {} 105.25741056 3.99244917}}}



   set star_list [vo_vizier_query $ra $dec $radius arcmin I/315]

   #::console::affiche_resultat "$star_list\n"

   set tmp [lindex $star_list 0]
   set allfields [lindex $tmp 0]

   set cmfields  [list ra dec poserr mag magerr]
   set list_fields [list [list "TYCHO2" $cmfields $allfields] ]

   #::console::affiche_resultat "$list_fields\n"
   
   set list_sources {}
   set tmp [lindex $tmp 1]
   foreach star $tmp {
      #::console::affiche_resultat "star=$star\n"
      #set cmval [list [expr [ mc_angle2deg [lindex $star 1]]*15] [expr [ mc_angle2deg [lindex $star 2]]*1.] .2 [lindex $star 3] 0.2 ]
      set cmval [list [lindex $star 8] [lindex $star 9] .2 [lindex $star 6] 0.2 ]
      #::console::affiche_resultat "cmval=$cmval\n"
      lappend list_sources [list [list "TYCHO2" $cmval $star ] ] 
      continue
   }

   #::console::affiche_resultat "TYCHO2: [list $list_fields $list_sources]\n"

   return [list $list_fields $list_sources]

}
