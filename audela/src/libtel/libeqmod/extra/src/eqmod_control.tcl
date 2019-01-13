#  Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil d'Alain KLOTZ <alain.klotz@free.fr>
#  Modifie/adapte pour l'AZEQ6-GT par Jerome Berthier <berthier@imcce.fr>

namespace eval eqmod_control {

   set ::eqmod_control::test_delay 500

}

#
#
#
proc ::eqmod_control::init { } {

   catch {tel::create eqmod /dev/ttyUSB0}

   ::eqmod::init_mount
   ::eqmod::init_mount_to_hour_coord 180 90

   after $::::eqmod_control::test_delay
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::park { } {

   ::console::affiche_erreur   "----------------------------------------------------------\n"
   ::console::affiche_resultat "  * Goto home position (0,+90)\n"
   ::console::affiche_erreur   "----------------------------------------------------------\n"
   
   # Goto
   ::eqmod::goto_hour_coord 180 90

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test1 { dec } {

   # Recupere les coordonnees horaires courantes
   ::eqmod::get_mount_hour_coord h_crte dec_crte

   ::console::affiche_resultat "TEST 1: mouvement de l'axe de declinaison\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Slewing to DEC = $dec deg. toward East\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   # Goto
   ::eqmod::goto_hour_coord $h_crte $dec

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test2 { h } {

   # Recupere les coordonnees horaires courantes
   ::eqmod::get_mount_hour_coord h_crte dec_crte

   ::console::affiche_resultat "TEST 2: mouvement de l'axe horaire\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Slewing to H = $h deg. toward [::eqmod::get_direction $h]\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   # Goto
   ::eqmod::goto_hour_coord $h $dec_crte

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test3 { h dec } {

   ::console::affiche_resultat "TEST 3: mouvements combines des axes horaire et de declinaison\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Slewing to H, DEC = $h $dec deg. toward [::eqmod::get_direction $h]\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   # Goto
   ::eqmod::goto_hour_coord $h $dec

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test4 { star } {

   ::console::affiche_resultat "TEST 4: pointage d'une etoile\n"

   # Get star hour coordinates
   set c [::eqmod_control::get_star_coords $star]
   set h [lindex $c 2]
   set dec [lindex $c 3]

   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Goto star = $star @ H, DEC = $h $dec deg.\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   ::eqmod::goto_hour_coord $h $dec

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test5 { } {

   ::console::affiche_resultat "TEST 5: suivi sideral\n"

   ::eqmod::start_drift [expr 360.0/86164.0] 1 0
   ::eqmod::stop_drift 1

}

#
#
#
proc ::eqmod_control::test6 { speed axe {sens 1} } {

   set d [expr {$sens == 0 ? "croissant" : "decroissant"}]
   ::console::affiche_resultat "TEST 6: suivi quelconque axe $axe a la vitesse x$speed (sens $d)\n"

   ::eqmod::start_drift [expr $speed*360.0/86164.0] $axe $sens
   ::eqmod::stop_drift $axe

}

#
#
#
proc ::eqmod_control::display_pos { } {

   ::console::affiche_erreur   "----------------------------------------------------------\n"
   ::console::affiche_resultat "  * Current position of the telescope\n"
   ::console::affiche_erreur   "----------------------------------------------------------\n"
   
   # Affiche les coordonnees pointees
   ::eqmod::get_mount_equatorial_coord ra dec
   ::eqmod::display_radec_coord $ra $dec
}

#
#
#
proc ::eqmod_control::get_star_coords { name } {

   switch $name {
      "altair"   {
                  #ALTAIR AR: 19h51m28.419s DE:+08°54'37.74" 
                  set ra "19h51m28.419s"
                  set dec  "+08d54m37.74s"
                 }
      "alpeg"    {
                  # Alp Peg : Apparente AR: 23h05m28.750s DE:+15°17'00.86" 
                  set ra "23h05m28.750s"
                  set dec  "+15d17m00.86s"
                 }
      "vega"     {
                  # Vega Apparente AR: 18h37m25.006s DE:+38°48'14.57" 
                  set ra  "18h37m25.006s"
                  set dec "+38d48m14.57"
                 }
      "arcturus" {
                  # Arcturus 14h16m16.622s DE:+19°06'52.06"
                  set ra  "14h16m16.622s"
                  set dec "+19d06m52.06"
                 }
      "capella"  {
                  # Capella J2000
                  set ra  "5h17m41.458s"
                  set dec "+45d59m46.87"
                 }
      default    {
                  set ra  "0h0m0s"
                  set dec "+90d0m0s"
                 }
   }

   set ra_deg  [mc_angle2deg $ra]
   set dec_deg [mc_angle2deg $dec]
   set hdec [::eqmod::coord_equatorial_to_hour $ra_deg $dec_deg]

   return [list $ra_deg $dec_deg [lindex $hdec 0] [lindex $hdec 1]]

}

#
#
#
proc ::eqmod_control::test_table_decimale { } {
   
   set v [::eqmod::decode FFFF7F] ; if {$v !=  8388607} { return -1}
   set v [::eqmod::decode 000100] ; if {$v !=      256} { return -1}
   set v [::eqmod::decode 100000] ; if {$v !=       16} { return -1}
   set v [::eqmod::decode 0F0000] ; if {$v !=       15} { return -1}
   set v [::eqmod::decode 010000] ; if {$v !=        1} { return -1}
   set v [::eqmod::decode 000000] ; if {$v !=        0} { return -1}
   set v [::eqmod::decode FFFFFF] ; if {$v !=       -1} { return -1}
   set v [::eqmod::decode F1FFFF] ; if {$v !=      -15} { return -1}
   set v [::eqmod::decode F0FFFF] ; if {$v !=      -16} { return -1}
   set v [::eqmod::decode 00FFFF] ; if {$v !=     -256} { return -1}
   set v [::eqmod::decode 000080] ; if {$v != -8388608} { return -1}
   
   set v [::eqmod::encode  8388607] ; if {$v != "FFFF7F"} { return -1}
   set v [::eqmod::encode      256] ; if {$v != "000100"} { return -1}
   set v [::eqmod::encode       16] ; if {$v != "100000"} { return -1}
   set v [::eqmod::encode       15] ; if {$v != "0F0000"} { return -1}
   set v [::eqmod::encode        1] ; if {$v != "010000"} { return -1}
   set v [::eqmod::encode        0] ; if {$v != "000000"} { return -1}
   set v [::eqmod::encode       -1] ; if {$v != "FFFFFF"} { return -1}
   set v [::eqmod::encode      -15] ; if {$v != "F1FFFF"} { return -1}
   set v [::eqmod::encode      -16] ; if {$v != "F0FFFF"} { return -1}
   set v [::eqmod::encode     -256] ; if {$v != "00FFFF"} { return -1}
   set v [::eqmod::encode -8388608] ; if {$v != "000080"} { return -1}

   set v [::eqmod::encode      620] ; if {$v != "6C0200"} { return -1}
   set v [::eqmod::decode   6C0200] ; if {$v !=      620} { return -1}

   return 0   
   
}

#
#
#
proc ::eqmod_control::test_table_decimale_compil { } {

   set v [tel1 decode FFFF7F] ; if {$v !=  8388607} { return -1}
   set v [tel1 decode 000100] ; if {$v !=      256} { return -1}
   set v [tel1 decode 100000] ; if {$v !=       16} { return -1}
   set v [tel1 decode 0F0000] ; if {$v !=       15} { return -1}
   set v [tel1 decode 010000] ; if {$v !=        1} { return -1}
   set v [tel1 decode 000000] ; if {$v !=        0} { return -1}
   set v [tel1 decode FFFFFF] ; if {$v !=       -1} { return -1}
   set v [tel1 decode F1FFFF] ; if {$v !=      -15} { return -1}
   set v [tel1 decode F0FFFF] ; if {$v !=      -16} { return -1}
   set v [tel1 decode 00FFFF] ; if {$v !=     -256} { return -1}
   set v [tel1 decode 000080] ; if {$v != -8388608} { return -1}
   
   set v [tel1 encode  8388607] ; if {$v != "FFFF7F"} { return -1}
   set v [tel1 encode      256] ; if {$v != "000100"} { return -1}
   set v [tel1 encode       16] ; if {$v != "100000"} { return -1}
   set v [tel1 encode       15] ; if {$v != "0F0000"} { return -1}
   set v [tel1 encode        1] ; if {$v != "010000"} { return -1}
   set v [tel1 encode        0] ; if {$v != "000000"} { return -1}
   set v [tel1 encode       -1] ; if {$v != "FFFFFF"} { return -1}
   set v [tel1 encode      -15] ; if {$v != "F1FFFF"} { return -1}
   set v [tel1 encode      -16] ; if {$v != "F0FFFF"} { return -1}
   set v [tel1 encode     -256] ; if {$v != "00FFFF"} { return -1}
   set v [tel1 encode -8388608] ; if {$v != "000080"} { return -1}
   
   set v [tel1 encode      620] ; if {$v != "6C0200"} { return -1}
   set v [tel1 decode   6C0200] ; if {$v !=      620} { return -1}
   
   return 0   

}

#
#
#
proc ::eqmod_control::test_mount_param { } {

   gren_info "a1 = [tel1 putread :a1] == [tel1 decode [tel1 putread :a1]]\n"
   gren_info "a2 = [tel1 putread :a2] == [tel1 decode [tel1 putread :a2]]\n"
   gren_info "b1 = [tel1 putread :b1] == [tel1 decode [tel1 putread :b1]]\n"
   gren_info "b2 = [tel1 putread :b2] == [tel1 decode [tel1 putread :b2]]\n"
   gren_info "d1 = [tel1 putread :d1] == [tel1 decode [tel1 putread :d1]]\n"
   gren_info "d2 = [tel1 putread :d2] == [tel1 decode [tel1 putread :d2]]\n"
   gren_info "e1 = [tel1 putread :e1] == [tel1 decode [tel1 putread :e1]]\n"
   gren_info "e2 = [tel1 putread :e2] == [tel1 decode [tel1 putread :e2]]\n"
   gren_info "s1 = [tel1 putread :s1] == [tel1 decode [tel1 putread :s1]]\n"
   gren_info "s2 = [tel1 putread :s2] == [tel1 decode [tel1 putread :s2]]\n"

}

proc ::eqmod_control::display_table_decimale { } {

   gren_info "FFFF7F = [::eqmod::decode "FFFF7F"]\n"
   gren_info "000100 = [::eqmod::decode "000100"]\n"
   gren_info "100000 = [::eqmod::decode "100000"]\n"
   gren_info "0F0000 = [::eqmod::decode "0F0000"]\n"
   gren_info "010000 = [::eqmod::decode "010000"]\n"
   gren_info "000000 = [::eqmod::decode "000000"]\n"
   gren_info "FFFFFF = [::eqmod::decode "FFFFFF"]\n"
   gren_info "F1FFFF = [::eqmod::decode "F1FFFF"]\n"
   gren_info "F0FFFF = [::eqmod::decode "F0FFFF"]\n"
   gren_info "00FFFF = [::eqmod::decode "00FFFF"]\n"
   gren_info "000080 = [::eqmod::decode "000080"]\n"

}

proc ::eqmod_control::display_table_decimale_compil { } {

   gren_info "FFFF7F = [tel1 decode "FFFF7F"]\n"
   gren_info "000100 = [tel1 decode "000100"]\n"
   gren_info "100000 = [tel1 decode "100000"]\n"
   gren_info "0F0000 = [tel1 decode "0F0000"]\n"
   gren_info "010000 = [tel1 decode "010000"]\n"
   gren_info "000000 = [tel1 decode "000000"]\n"
   gren_info "FFFFFF = [tel1 decode "FFFFFF"]\n"
   gren_info "F1FFFF = [tel1 decode "F1FFFF"]\n"
   gren_info "F0FFFF = [tel1 decode "F0FFFF"]\n"
   gren_info "00FFFF = [tel1 decode "00FFFF"]\n"
   gren_info "000080 = [tel1 decode "000080"]\n"

}

 proc test_eqmod { } {

      gren_info "a1 = HEX [tel1 putread :a1] = DEC [tel1 decode [tel1 putread :a1]]\n"
      gren_info "a2 = HEX [tel1 putread :a2] = DEC [tel1 decode [tel1 putread :a2]]\n"
      gren_info "b1 = HEX [tel1 putread :b1] = DEC [tel1 decode [tel1 putread :b1]]\n"
      gren_info "b2 = HEX [tel1 putread :b2] = DEC [tel1 decode [tel1 putread :b2]]\n"
      gren_info "d1 = HEX [tel1 putread :d1] = DEC [tel1 decode [tel1 putread :d1]]\n"
      gren_info "d2 = HEX [tel1 putread :d2] = DEC [tel1 decode [tel1 putread :d2]]\n"
      gren_info "e1 = HEX [tel1 putread :e1] = DEC [tel1 decode [tel1 putread :e1]]\n"
      gren_info "e2 = HEX [tel1 putread :e2] = DEC [tel1 decode [tel1 putread :e2]]\n"
      gren_info "s1 = HEX [tel1 putread :s1] = DEC [tel1 decode [tel1 putread :s1]]\n"
      gren_info "s2 = HEX [tel1 putread :s2] = DEC [tel1 decode [tel1 putread :s2]]\n"

      set l { {  "FFFF7F"   8388607 } \
              {  "000100"       256 } \
              {  "100000"        16 } \
              {  "0F0000"        15 } \
              {  "010000"         1 } \
              {  "000000"         0 } \
              {  "FFFFFF"        -1 } \
              {  "F1FFFF"       -15 } \
              {  "F0FFFF"       -16 } \
              {  "00FFFF"      -256 } \
              {  "000080"  -8388608 } }

      gren_erreur "HEX -> DEC\n"
      foreach c $l {
         set hex [lindex $c 0]
         set dec [lindex $c 1]
         set v [tel1 decode $hex]
         if {$v != $dec} { 
            gren_erreur "$hex => $v (doit etre $dec)\n"
         } else {
            gren_info "$hex => $v\n"
         }
      }

      gren_erreur "DEC -> HEX\n"
      foreach c $l {
         set hex [lindex $c 0]
         set dec [lindex $c 1]
         set v [tel1 encode $dec]
         if {$v != $hex} { 
            gren_erreur "$dec => $v (doit etre $hex)\n"
         } else {
            gren_info "$dec => $v\n"
         }

      }

   }