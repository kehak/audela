#
#
#
#  Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil d'Alain KLOTZ <alain.klotz@free.fr>
#  Modifie/adapte par Jerome Berthier <berthier@imcce.fr>
#
#  Valide pour la AZ-EQ6 GT par Jerome Berthier <berthier@imcce.fr>
#  Valide pour la NEQ3-2 Pro GOTO par Jerome Berthier <berthier@imcce.fr>
#  Valide pour la HEQ5 Pro GOTO par Fred Vachier <fv@imcce.fr>
#
# source [file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl]
#

namespace eval eqmod {

   variable home
   variable telno

   # Parametres de la monture
   variable tel_a1
   variable tel_a2
   variable tel_b1
   variable tel_b2
   variable tel_g1
   variable tel_g2

   variable tel_d1
   variable tel_d2
   variable tel_e1
   variable tel_e2
   variable tel_s1
   variable tel_s2

   # Active ou non le log
   set ::eqmod::log 1

   # Delai minimum necessaire entre 2 commandes (ms)
   set ::eqmod::delay 15

   # Defini la valeur limite de separation entre mouvements lent et rapide (deg/sec)
   set ::eqmod::lowhigh_drift_limit 0.25

}

# Ressource le projet
proc ::eqmod::ressource { } {

   global audace

   uplevel #0 "source \"[file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl]\""
   uplevel #0 "source \"[file join $audace(rep_install) src libtel libeqmod extra src eqmod_control.tcl]\""

}

# Conversion hexadecimal -> decimal
# input: h code hexadecimal
#        algo choix de l'algo de decodage (0|1)
# return valeur decimale correspondante
proc ::eqmod::decode { h {algo 0} } {

   if {$algo == 0} {
      set i [string range $h 4 5][string range $h 2 3][string range $h 0 1]
      set d [expr int(0x${i})]
   } else {
      set n [string length [format %0X -1]]
      set sig [expr int(0x[string index $h 4])]
      set sym [expr {$sig<=7 ? 0 : F}]
      set comp [string repeat $sym [expr $n-6]]
      set d [expr int(0x${comp}[ string range $h 4 5 ][ string range $h 2 3 ][ string range $h 0 1 ])]
   }
   if {$::eqmod::log} { ::console::affiche_erreur "decode (HEX) $h => (DEC) $d\n" }

   return $d

}

# Conversion decimal -> hexadecimal
# input: d valeur decimale
# return code hexadecimal correspondant
proc ::eqmod::encode { d } {

   set s [string range [format %08X $d] end-5 end]
   set h [string range $s 4 5][string range $s 2 3][string range $s 0 1]

   if {$::eqmod::log} { ::console::affiche_erreur "encode (DEC) $d => (HEX) $h\n" }

   return $h

}

# Calcul le temps sideral local a l'instant de l'appel
# return t le temps sideral local en deg
proc ::eqmod::get_lst {} {
   
   set now [clock format [clock seconds] -gmt 1 -format "%Y %m %d %H %M %S"]
   set lst [mc_date2lst $now $::eqmod::home]
   set t [expr ([lindex $lst 0] + [lindex $lst 1]/60.0 + [lindex $lst 2]/3600.0)*15.0]

   if {$::eqmod::log} { ::console::affiche_resultat "LST (deg / hms) : $t / $lst\n" }

   return $t

}

# Direction E/W pointee, selon l'angle horaire: E (270o-360o) ou W (0o-180o)
# input: h_deg angle horaire en deg.
# return E | W
proc ::eqmod::get_direction { h_deg } {

   return [expr {($h_deg > 0.0 && $h_deg < 180.0) ? "W" : "E"}]

}

# Calcul les coordonnees equatoriales a partir des coordonnees horaires
# input: h_deg float angle horaire en deg
# input: dec_deg gloat declinaison en deg [-pi/2 .. +pi/2]
# return list coordonnees RA,DEC
proc ::eqmod::coord_hour_to_equatorial { h_deg dec_deg } {

   set t [::eqmod::get_lst]
   set ra_deg [expr $t - $h_deg]
   if {$ra_deg < 0.0} { set ra_deg [expr $ra_deg + 360.0] }
   return [list $ra_deg $dec_deg]

}

# Calcul les coordonnees horaires a partir des coordonnees equatoriales
# input: ra_deg float ascension droite en deg
# input: dec_deg gloat declinaison en deg
# return list coordonnees H,DEC
proc ::eqmod::coord_equatorial_to_hour { ra_deg dec_deg } {

   set t [::eqmod::get_lst]
   set h_deg [expr $t - $ra_deg]
   if {$h_deg < 0.0} { set h_deg [expr $h_deg + 360.0] }
   return [list $h_deg $dec_deg]

}

# coordonnees celestes -> coordonnees monture
# input: h_deg float angle horaire en deg
# input: dec_deg float declinaison en deg
# return list coordonnes monture
proc ::eqmod::hour_to_mount { h_deg dec_deg } {

   if {$::eqmod::log} { ::console::affiche_erreur "hour->mount input: $h_deg $dec_deg\n" }

   set h_deg [expr 180.0 + $h_deg]
   while {$h_deg >= 360.0} {
      set h_deg [expr $h_deg - 360.0]
   }

   if {$dec_deg == 360.0} { set dec_deg 0.0 }

   if {$::eqmod::log} { ::console::affiche_erreur "hour->mount result: $h_deg $dec_deg\n" }

   return [list $h_deg $dec_deg]

}

# coordonnees monture -> coordonnees celestes
# input: m1_deg float coordonnee monture 1 en deg
# input: m2_deg float coordonnee monture 2 en deg
# return list coordonnes horaires
proc ::eqmod::mount_to_hour { m1_deg m2_deg } {

   if {$::eqmod::log} { ::console::affiche_erreur "mount->hour input: $m1_deg $m2_deg\n" }

   set m1_deg [expr $m1_deg + 180.0]
   while {$m1_deg >= 360.0} {
      set m1_deg [expr $m1_deg - 360.0]
   }

   if {$m2_deg == 360.0} { set m2_deg 0.0 }

   if {$m2_deg  > 90.0} { set m2_deg [expr 180.0-$m2_deg] }

   if {$::eqmod::log} { ::console::affiche_erreur "mount->hour result: $m1_deg $m2_deg\n" }

   return [list $m1_deg $m2_deg]

}

# Defini les valeurs des commandes de la monture
# return void
proc ::eqmod::get_mount_command_values {} {

   ::console::affiche_resultat "Get mount command values...\n"

   set ::eqmod::tel_a1 [::eqmod::decode [tel$::eqmod::telno putread :a1]]
   set ::eqmod::tel_a2 [::eqmod::decode [tel$::eqmod::telno putread :a2]]
   set ::eqmod::tel_b1 [::eqmod::decode [tel$::eqmod::telno putread :b1]]
   set ::eqmod::tel_b2 [::eqmod::decode [tel$::eqmod::telno putread :b2]]
   set ::eqmod::tel_d1 [::eqmod::decode [tel$::eqmod::telno putread :d1]]
   set ::eqmod::tel_d2 [::eqmod::decode [tel$::eqmod::telno putread :d2]]
   set ::eqmod::tel_e1 [::eqmod::decode [tel$::eqmod::telno putread :e1]]
   set ::eqmod::tel_e2 [::eqmod::decode [tel$::eqmod::telno putread :e2]]
   set ::eqmod::tel_g1 [tel$::eqmod::telno putread :g1]
   set ::eqmod::tel_g2 [tel$::eqmod::telno putread :g2]
   set ::eqmod::tel_s1 [::eqmod::decode [tel$::eqmod::telno putread :s1]]
   set ::eqmod::tel_s2 [::eqmod::decode [tel$::eqmod::telno putread :s2]]

}

# Affiche les valeurs des commandes de la monture
# return void
proc ::eqmod::display_mount_command_values {} {

   ::console::affiche_resultat "Mount command values:\n"
   if {[info exists ::eqmod::tel_a1]} {
      ::console::affiche_resultat "(a1) = $::eqmod::tel_a1\n"
      ::console::affiche_resultat "(a2) = $::eqmod::tel_a2\n"
      ::console::affiche_resultat "(b1) = $::eqmod::tel_b1\n"
      ::console::affiche_resultat "(b2) = $::eqmod::tel_b2\n"
      ::console::affiche_resultat "(d1) = $::eqmod::tel_d1\n"
      ::console::affiche_resultat "(d2) = $::eqmod::tel_d2\n"
      ::console::affiche_resultat "(e1) = $::eqmod::tel_e1\n"
      ::console::affiche_resultat "(e2) = $::eqmod::tel_e2\n"
      ::console::affiche_resultat "(g1) = $::eqmod::tel_g1\n"
      ::console::affiche_resultat "(g2) = $::eqmod::tel_g2\n"
      ::console::affiche_resultat "(s1) = $::eqmod::tel_s1\n"
      ::console::affiche_resultat "(s2) = $::eqmod::tel_s2\n"
   } else {
      ::console::affiche_erreur "Unknown values, initialize the mount\n"
   }

}

# Initialisation de la monture
# return 0
proc ::eqmod::init_mount {} {

   global confgene

   # Initialisations
   set ::eqmod::telno 1
   set ::eqmod::home $confgene(posobs,observateur,gps)

   # Defini les coordonnees de l'observateur
   tel$::eqmod::telno home $::eqmod::home
   
   # Defini les valeurs des commandes de la monture
   ::eqmod::get_mount_command_values

   # Etat des moteurs
   if {$::eqmod::log} { ::console::affiche_resultat "Moteurs = [tel$::eqmod::telno radec state]\n" }

   return 0

}

# Defini les coordonnees de la monture a h, d
# input: h_deg float angle horaire en deg
# input: dec_deg float declinaison en deg [-pi/2 .. +pi/2]
# return 0
proc ::eqmod::init_mount_to_hour_coord { h_deg dec_deg } {

   set r [::eqmod::hour_to_mount $h_deg $dec_deg]
   set m1_deg [lindex $r 0]
   set m2_deg [lindex $r 1]

   set dec1 [expr int($::eqmod::tel_a1*$m1_deg/360.0)]
   set hex1 [::eqmod::encode $dec1]

   set dec2 [expr int($::eqmod::tel_a2*$m2_deg/360.0)]
   set hex2 [::eqmod::encode $dec2]

   if {$::eqmod::log} {
      ::console::affiche_resultat "Axe 1 (HEX / DEC) : $hex1 / $dec1\n"
      ::console::affiche_resultat "Axe 2 (HEX / DEC) : $hex2 / $dec2\n"
   }

   # Initialize encoders
   tel$::eqmod::telno put :E1$hex1
   tel$::eqmod::telno put :E2$hex2

   return 0

}

# Defini les coordonnees de la monture a RA,DEC
# input: ra_deg float ascension droite en deg
# input: dec_deg float declinaison en deg [-pi/2 .. +pi/2]
# return 0
proc ::eqmod::init_mount_to_equatorial_coord { ra_deg dec_deg } {

   set c [::eqmod::coord_equatorial_to_hour $ra_deg $dec_deg]
   ::eqmod::init_mount_to_hour_coord [lindex $c 0] [lindex $c 1]

   return 0

}

# Retourne l'etat d'un axe du telescope
# input: axe int numero de l'axe (1|2)
# return list type state status
proc ::eqmod::get_mount_state { axe } {
   
   set slewing_state [tel$::eqmod::telno putread :f$axe]
   set jog_type [string index $slewing_state 0]
   set jog_state [string index $slewing_state 1]
   set jog_status [string index $slewing_state 2]

   return [list $jog_type $jog_state $jog_status]

}

# Retourne les coordonnees courantes du telescope
# output: p_dec1 float coordonnee 1 decimale
# output: p_dec2 float coordonnee 2 decimale
# return 0
proc ::eqmod::get_mount_coord { p_dec1 p_dec2 } {

   upvar $p_dec1 dec1
   upvar $p_dec2 dec2

   set hex1 [tel$::eqmod::telno putread :j1]
   after $::eqmod::delay
   set hex2 [tel$::eqmod::telno putread :j2]

   set dec1 [::eqmod::decode $hex1]
   set dec2 [::eqmod::decode $hex2]

   if {$::eqmod::log} {
      ::console::affiche_resultat "Axe 1 (HEX / DEC) : $hex1 / $dec1\n"
      ::console::affiche_resultat "Axe 2 (HEX / DEC) : $hex2 / $dec2\n"
   }

   return 0

}

# Retourne les coordonnees horaires courantes du telescope
# output: p_h float angle horaire du telescope en deg
# output: p_dec float declinaison du telescope en deg [-pi/2 .. +pi/2]
# return 0
proc ::eqmod::get_mount_hour_coord { p_h p_dec } {

   upvar $p_h h_deg
   upvar $p_dec dec_deg

   ::eqmod::get_mount_coord m1 m2

   set h_deg [expr $m1*360.0/$::eqmod::tel_a1]
   set dec_deg [expr $m2*360.0/$::eqmod::tel_a2]

   set m [::eqmod::mount_to_hour $h_deg $dec_deg]
   set h_deg [lindex $m 0]
   set dec_deg [lindex $m 1]

   set dir [::eqmod::get_direction $h_deg]
   set h [mc_angle2hms $h_deg 360 zero 1 auto string]
   set d [mc_angle2dms $dec_deg 90 zero 1 + string]

   if {$::eqmod::log} { ::console::affiche_resultat "H ; DEC (deg / hms) : $h_deg / $h ; $dec_deg / $d (direction: $dir)\n" }

   return 0

}

# Retourne les coordonnees equatoriales courantes du telescope
# output: p_ra float ascension droite en deg
# output: p_dec float declinaison en deg [-pi/2 .. +pi/2]
# return 0
proc ::eqmod::get_mount_equatorial_coord { p_ra p_dec } {

   upvar $p_ra ra_deg
   upvar $p_dec dec_deg

   ::eqmod::get_mount_hour_coord h_deg dec_deg
   set r [::eqmod::coord_hour_to_equatorial $h_deg $dec_deg]

   set ra_deg [lindex $r 0]
   set dec_deg [lindex $r 1]

   return 0

}

# Affiche les coordonnees equatoriales au format sexagesimal 
# input: ra_deg float ascension droite en deg
# input: dec_deg float declinaison en deg [-pi/2 .. +pi/2]
# return 0
proc ::eqmod::display_radec_coord { ra_deg dec_deg } {

   set ra  [mc_angle2hms $ra_deg 360 zero 1 auto string]
   set dec [mc_angle2dms $dec_deg 90 zero 1 + string]

   ::console::affiche_resultat "RA ; DEC (deg / hms) : $ra_deg / $ra ; $dec_deg / $dec\n"

}

# Deplacement du telescope aux coordonnees celestes RA,DEC
# input: ra_deg float ascension droite en deg
# input: dec_deg float declinaison en deg [-pi/2 .. +pi/2]
# return 0
proc ::eqmod::goto_equatorial_coord { ra_deg dec_deg } {

   set c [::eqmod::coord_equatorial_to_hour $ra_deg $dec_deg]
   ::eqmod::goto_hour_coord [lindex $c 0] [lindex $c 1]

   return 0

}

# Deplacement du telescope aux coordonnees celestes h, dec
# input: h_deg float angle horaire en deg
# input: dec_deg float declinaison en deg [-pi/2 .. +pi/2]
# return 0
proc ::eqmod::goto_hour_coord { h_deg dec_deg } {

   set r [::eqmod::hour_to_mount $h_deg $dec_deg]
   ::eqmod::goto_mount_coord [lindex $r 0] [lindex $r 1]

   return 0

}

# Deplacement du telescope aux coordonnees monture m1, m2
# input: m1 float coordonnee monture 1 en deg
# input: m2 float coordonnee monture 2 en deg
# return 0 si le statut des axes est OK, 1 sinon
proc ::eqmod::goto_mount_coord { m1 m2 } {

   set pi [expr 2*asin(1.0)]
   set debug 0

   #
   set r [::eqmod::mount_to_hour $m1 $m2]
   set hm1 [lindex $r 0]
   set hm2 [lindex $r 1]

   # Recupere les coordonnees horaires courantes du telescope
   ::eqmod::get_mount_hour_coord h_deg dec_deg

   # Direction courante du telescope, selon que l'on pointe vers un angle horaire W (270o-360o) ou E (0o-180o)
   set direction_crte [::eqmod::get_direction $h_deg]
   # Direction vers laquelle va pointer le telescope, selon que l'on pointe vers un angle horaire W (270o-360o) ou E (0o-180o)
   set direction_nxt [::eqmod::get_direction $hm1]

   ::console::affiche_resultat "Coordonnees horaires a pointer: $hm1 $hm2 (direction: $direction_nxt)\n"
   ::console::affiche_resultat "Coordonnees horaires actuelles du telescope (H,Dec): $h_deg $dec_deg (direction: $direction_crte)\n"

   # Calcul du deplacement a effectuer sur l'axe horaire
   # -- difference d'angle horaire (deg)
   set diff_ha [expr $hm1 - $h_deg]
gren_erreur "diff_ha = $diff_ha :: $direction_nxt != $direction_crte \n"
   if {$diff_ha < -180.0} { set diff_ha [expr $diff_ha + 360.0] }
   if {[expr $h_deg + $diff_ha] < 0.0} { set diff_ha [expr $diff_ha + 360.0] }
gren_erreur "  ==> diff_ha = $diff_ha\n"
   # -- traitement des cas particuliers
   #set sinhd [expr sin($h_deg*$pi/180.0)]
   #set sgn_sinhd 1.0
   #if {$sinhd != 0.0} { set sgn_sinhd [expr $sinhd/abs($sinhd)] }
   #set sinm1 [expr sin($m1*$pi/180.0)]
   #set sgn_sinm1 1.0
   #if {$sinm1 != 0.0} { set sgn_sinm1 [expr $sinm1/abs($sinm1)] }
   #if {$m1 == 180.0}  { set sgn_sinm1 $sgn_sinhd }
   #if {$sgn_sinm1 != $sgn_sinhd} {
   #   set diff_ha [expr ($m1 - $h_deg) + $sgn_sinm1*360.0]
   #}
   # -- calcul du deplacement
   set nxt_m1 [expr int($::eqmod::tel_a1*$diff_ha/360.0)]

   ::console::affiche_resultat "Deplacement a effectuer axe 1: $nxt_m1 ($diff_ha)\n"

   # Calcul du deplacement a effectuer sur l'axe de declinaison
   # -- difference de declinaison (deg)
   set diff_dec [expr $dec_deg - $hm2]
   # -- sens de la difference selon le quadrant
   set diff_dec [expr {$direction_nxt == "E" ? [expr -$diff_dec] : $diff_dec}]
gren_erreur "diff_dec = $diff_dec :: $direction_nxt != $direction_crte \n"
   # -- si on franchi le meridien ... retournement en delta ou non
   if {$direction_nxt != $direction_crte} {
      set coef 1.0
      if {$hm1 == 0.0 || $h_deg == 0.0} { set coef 0.0 }
      if {$direction_nxt == "E"} {
         set diff_dec [expr ($dec_deg-90.0)*($coef+1.0) + $diff_dec*$coef]
      } else {
         set diff_dec [expr (90.0-$dec_deg)*($coef+1.0) + $diff_dec*$coef]
      }
   }
gren_erreur "  ==> diff_dec = $diff_dec\n"
   # -- calcul du deplacement
   set nxt_m2 [expr int($::eqmod::tel_a2*$diff_dec/360.0)]

   ::console::affiche_resultat "Deplacement a effectuer axe 2: $nxt_m2 ($diff_dec)\n"
#return 0

   # Mouvement de l'axe 2
   if {$nxt_m2 != 0} {
      # Stop motor 2
      tel$::eqmod::telno put :K2
      after $::eqmod::delay
      # Define motion type and sense
      if {$nxt_m2 > 0} {
         tel$::eqmod::telno put :G200
         after $::eqmod::delay
      } else {
         set nxt_m2 [expr -$nxt_m2]
         tel$::eqmod::telno put :G201
         after $::eqmod::delay
      }
      # Define the next position increment to reach
      set hex2 [::eqmod::encode $nxt_m2]
      tel$::eqmod::telno put :H2$hex2
      after $::eqmod::delay
      # Start motion
      ::console::affiche_resultat "Start slewing axis #2...\n"
      tel$::eqmod::telno put :J2
      after $::eqmod::delay

      if {$::eqmod::log} {
         set err [catch {::eqmod::decode [tel$::eqmod::telno putread :i2]} i]
         if {$err == 1} {
            set i [tel$::eqmod::telno putread :g2]
            set s [expr 360.0*$::eqmod::tel_g2*$::eqmod::tel_b2/$i/$::eqmod::tel_a2]
            ::console::affiche_resultat "  Computed speedtrack from :g2 value = $s deg/sec\n"
         } else {
            set s [expr 360.0*$::eqmod::tel_g2*$::eqmod::tel_b2/$i/$::eqmod::tel_a2]
            ::console::affiche_resultat "  Computed speedtrack = $s deg/sec\n"
         }
      }
   }

   # Mouvement de l'axe 1
   if {$nxt_m1 != 0} {
      # Stop motor 1
      tel$::eqmod::telno put :K1
      after $::eqmod::delay
      # Define motion type and sense
      if {$nxt_m1 > 0} {
         tel$::eqmod::telno put :G100
         after $::eqmod::delay
      } else {
         set nxt_m1 [expr -$nxt_m1]
         tel$::eqmod::telno put :G101
         after $::eqmod::delay
      }
      # Define the next position increment to reach
      set hex1 [::eqmod::encode $nxt_m1]
      tel$::eqmod::telno put :H1$hex1
      after $::eqmod::delay
      # Start motion
      ::console::affiche_resultat "Start slewing axis #1...\n"
      tel$::eqmod::telno put :J1
      after $::eqmod::delay

      if {$::eqmod::log} {
         set err [catch {::eqmod::decode [tel$::eqmod::telno putread :i1]} i]
         if {$err == 1} {
            set i [tel$::eqmod::telno putread :g1]
            set s [expr 360.0*$::eqmod::tel_g1*$::eqmod::tel_b1/$i/$::eqmod::tel_a1]
            ::console::affiche_resultat "  Computed speedtrack from :g1 value = $s deg/sec\n"
         } else {
            set s [expr 360.0*$::eqmod::tel_g1*$::eqmod::tel_b1/$i/$::eqmod::tel_a1]
            ::console::affiche_resultat "  Computed speedtrack = $s deg/sec\n"
         }
      }
   }

   # Boucle d'attente de l'arret des axes
   set motor1 1
   set m1_log_state 1
   set m1_log_type 1
   set motor2 1
   set m2_log_state 1
   set m2_log_type 1
   set ok 1
   while {$ok == 1} {
      # Get slewing state of motor 2
      set m2_slewing_state [::eqmod::get_mount_state 2]
      set m2_jog_type [lindex $m2_slewing_state 0]
      set m2_jog_state [lindex $m2_slewing_state 1]
      set m2_jog_status [lindex $m2_slewing_state 2]
      if {$debug} { ::console::affiche_resultat "GOTO: $m2_jog_type $m2_jog_state $m2_jog_status\n" }

      if {$m2_jog_type == 1 || $m2_jog_type == 3} {
         if {$::eqmod::log == 1 && $m2_log_type == 1} { ::console::affiche_erreur "Mvt axe 2 termine\n" }
         set motor2 0
         set m2_log_type 0
      }

      if {$m2_jog_state == 0} {
         if {$::eqmod::log == 1 && $m2_log_state == 1} { ::console::affiche_erreur "Axe 2 a l'arret\n" }
         set motor2 0
         set m2_log_state 0
      }

      after $::eqmod::delay

      # Get slewing state of motor 1
      set m1_slewing_state [::eqmod::get_mount_state 1]
      set m1_jog_type [lindex $m1_slewing_state 0]
      set m1_jog_state [lindex $m1_slewing_state 1]
      set m1_jog_status [lindex $m1_slewing_state 2]

      if {$m1_jog_type == 1 || $m1_jog_type == 3} {
         if {$::eqmod::log == 1 && $m1_log_type == 1} { ::console::affiche_erreur "Mvt axe 1 termine\n" }
         set motor1 0
         set m1_log_type 0
      }

      if {$m1_jog_state == 0} {
         if {$::eqmod::log == 1 && $m1_log_state == 1} { ::console::affiche_erreur "Axe 1 a l'arret\n" }
         set motor1 0
         set m1_log_state 0
      }

      # Condition de sortie
      if {$motor1 == 0 && $motor2 == 0} { set ok 0 }
   }

   ::console::affiche_resultat "Ok, mouvements des axes termines avec le statut:\n"
   ::console::affiche_resultat "  axe 1: [expr {$m1_jog_status == 1 ? "OK" : "PB"}] \n"
   ::console::affiche_resultat "  axe 2: [expr {$m2_jog_status == 1 ? "OK" : "PB"}] \n"

   return [expr {($m1_jog_status == 0 || $m2_jog_status == 0) ? 1 : 0}]

}

# Start the drift motion on one axe
# input: speed float speedtrack in deg/sec
# input: axe int axe on which to apply drift (1: hour (default) | 2: declinaison)
# input: sense int increasing (0) or decreasing (1, default) motion
# return 0
proc ::eqmod::start_drift { speed {axe 1} {sense 1} } {

   set debug 0
   if {$::eqmod::log} { ::console::affiche_resultat "Speed = $speed deg/sec\n" }

   # Command values
   set a [expr {$axe == 1 ? $::eqmod::tel_a1 : $::eqmod::tel_a2}]
   set b [expr {$axe == 1 ? $::eqmod::tel_b1 : $::eqmod::tel_b2}]
   set g [expr {$axe == 1 ? $::eqmod::tel_g1 : $::eqmod::tel_g2}]

   # Define speed motion
   set fast_coef [expr {$speed <= $::eqmod::lowhigh_drift_limit ? 1 : $g}]
   set drift_speed [expr int(360.0*$fast_coef*$b/$speed/$a)]
   if {$::eqmod::log} { ::console::affiche_resultat "Drift speed = $drift_speed (fast coef = $fast_coef)\n" }

   # Kill motor motion
   tel$::eqmod::telno put :K$axe

   # Wait for motor halt
   set m_state [::eqmod::get_mount_state $axe]
   while {[lindex $m_state 1] != 0} {
      set m_state [::eqmod::get_mount_state $axe]
   }

   # Define motion type (1: slow_infinite ou 3: fast_infinite)
   set motion_type [expr {$speed <= $::eqmod::lowhigh_drift_limit ? 1 : 3}]
   # Define motion sense (increasing motion)
   set motion_sense $sense

   if {$::eqmod::log} {
      ::console::affiche_resultat "Define motion: :G$axe$motion_type$motion_sense\n"
      ::console::affiche_resultat "Define drift speed: :I$axe[::eqmod::encode $drift_speed]\n"
   }

   # Set the drift speed
   tel$::eqmod::telno put :G$axe$motion_type$motion_sense
   after $::eqmod::delay
   tel$::eqmod::telno put :I$axe[::eqmod::encode $drift_speed]
   after $::eqmod::delay

   # Start jog
   set t0 [clock clicks -milliseconds]
   set j0 [::eqmod::decode [tel$::eqmod::telno putread :j$axe]]
   tel$::eqmod::telno put :J$axe
   after $::eqmod::delay

   if {$::eqmod::log} {
      set i [expr int(360.0*$fast_coef*$b/$speed/$a)]
      set s [expr 360.0*$fast_coef*$b/$i/$a]
      ::console::affiche_resultat "Required speedtrack = $s deg/sec\n"

      set err [catch {::eqmod::decode [tel$::eqmod::telno putread :i$axe]} i]
      if {$err == 1} {
         set i [tel$::eqmod::telno putread :g$axe]
         set s [expr 360.0*$fast_coef*$b/$i/$a]
         ::console::affiche_resultat "Computed speedtrack from :g$axe value = $s deg/sec\n"
      } else {
         set s [expr 360.0*$fast_coef*$b/$i/$a]
         ::console::affiche_resultat "Computed speedtrack = $s deg/sec\n"
      }
   }

   set ok 1
   set i 0
   while {$ok == 1} {
      # Get slewing state of motor 2
      set slewing_state [::eqmod::get_mount_state $axe]
      set jog_type [lindex $slewing_state 0]
      set jog_state [lindex $slewing_state 1]
      set jog_status [lindex $slewing_state 2]
      if {$debug} { ::console::affiche_resultat "DRIFTING $i: $jog_type $jog_state $jog_status\n" }

      # Condition de sortie
      set i [expr $i+1]
      if {$i == 100} { set ok 0 }
   }

   ::eqmod::stop_drift $axe
   
   set t1 [clock clicks -milliseconds]
   set j1 [::eqmod::decode [tel$::eqmod::telno putread :j$axe]]
   set dt [expr ($t1-$t0)/1000.0]
   set mes_speed [expr (($j0-$j1)*360.0/$a) / $dt]
   ::console::affiche_resultat "Measured speedtrack = $mes_speed deg/sec ($dt sec) \n"

   return 0

}

# Stop the drift motion on one axe
# input: 
#
proc ::eqmod::stop_drift { axe } {

   set debug 0

   tel$::eqmod::telno put :K$axe
   after $::eqmod::delay

   # Wait for motor halt
   set m_state [::eqmod::get_mount_state $axe]
   if {$::eqmod::log} { ::console::affiche_resultat "STOPPING: [lindex $m_state 0] [lindex $m_state 1] [lindex $m_state 2]\n" }
   while {[lindex $m_state 1] != 0} {
      set m_state [::eqmod::get_mount_state $axe]
      if {$debug} { ::console::affiche_resultat "STOPPING: [lindex $m_state 0] [lindex $m_state 1] [lindex $m_state 2]\n" }
   }

   return 0
   
}
