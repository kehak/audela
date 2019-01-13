#
# Fichier : obj_lune_1.tcl
# Description : Programme de calcul (ephemerides, etc.)
# Auteur : Robert DELMAS
# Mise à jour $Id: obj_lune_1.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::obj_lune {

   #
   # obj_lune::Lune_Ephemerides
   # Calcule les ephemerides de la Lune toutes les secondes
   #
   proc Lune_Ephemerides { } {
      global audace caption obj_lune

      if { [ winfo exists $obj_lune(onglet2).frame8.lab6 ] } {
         #--- Preparation de l'heure TU pour le calcul des ephemerides
         set now [::audace::date_sys2ut now]
         #--- Calcul des ephemerides de la Lune
         set obj_lune(ephemerides) [mc_ephem {Moon} [list [mc_date2tt $now]] {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM PHASE ALTITUDE AZIMUTH DELTA HA} -topo $audace(posobs,observateur,gps)]
         #--- Affichage de l'ascension droite et de la declinaison du centre du disque lunaire
         set obj_lune(ad) "[format "%02dh%02dm%04.2fs" [lindex [lindex $obj_lune(ephemerides) 0] 1] [lindex [lindex $obj_lune(ephemerides) 0] 2] [lindex [lindex $obj_lune(ephemerides) 0] 3] ]"
         set obj_lune(dec) "[format "%02dd%02dm%04.2fs" [lindex [lindex $obj_lune(ephemerides) 0] 4] [lindex [lindex $obj_lune(ephemerides) 0] 5] [lindex [lindex $obj_lune(ephemerides) 0] 6] ]"
         #--- Preparation et affichage de l'ascension droite et de la declinaison du site choisi sur la Lune
         if { ![info exists obj_lune(long_selene)] } {
            set a "0"
         } else {
            set a $obj_lune(long_selene)
         }
         set lon 0
         if { [set k [string first E $a]] >= "0" } { set lon [string range $a 0 [expr $k-1]] }
         if { [set k [string first W $a]] >= "0" } { set lon [string range $a 0 [expr $k-1]] }
         if { ![info exists obj_lune(lat_selene)] } {
            set a "0"
         } else {
            set a $obj_lune(lat_selene)
         }
         set lat 0
         if { [set k [string first S $a]] >= "0" } { set lat [string range $a 0 [expr $k-1]] }
         if { [set k [string first N $a]] >= "0" } { set lat [string range $a 0 [expr $k-1]] }
         set date [list [::audace::date_sys2ut now]]
         set res [lonlat2radec moon $lon $lat $date $audace(posobs,observateur,gps)]
         set obj_lune(ad_site) [mc_angle2hms [lindex $res 0] 360 zero 2 auto string]
         set obj_lune(dec_site) [mc_angle2dms [lindex $res 1] 90 zero 2 + string]
         #--- Verifie l'existance du widget
         if { [ winfo exists $obj_lune(onglet1) ] } {
            if { [ info exists obj_lune(long_selene) ] } {
               $obj_lune(onglet1).frame17.lab6a configure -text "$obj_lune(ad_site)"
               $obj_lune(onglet1).frame18.lab7a configure -text "$obj_lune(dec_site)"
            }
         }
         #--- Affichage de la hauteur et de l'azimut
         set obj_lune(hauteur) "[format "%05.2f$caption(obj_lune1,degre)" [lindex [lindex $obj_lune(ephemerides) 0] 10] ]"
         set obj_lune(azimut) "[format "%05.2f$caption(obj_lune1,degre)" [lindex [lindex $obj_lune(ephemerides) 0] 11] ]"
         #--- Affichage de l'angle horaire
         set obj_lune(anglehoraire) "[lindex [lindex $obj_lune(ephemerides) 0] 13]"
         set obj_lune(anglehoraire) [mc_angle2hms $obj_lune(anglehoraire) 360]
         set obj_lune(anglehoraire_sec) [lindex $obj_lune(anglehoraire) 2]
         set obj_lune(anglehoraire) [format "%02dh%02dm%02ds" [lindex $obj_lune(anglehoraire) 0] [lindex $obj_lune(anglehoraire) 1] [expr int($obj_lune(anglehoraire_sec))]]
         #--- Preparation et affichage du diametre apparent
         set diam_ap [lindex [lindex $obj_lune(ephemerides) 0] 8]
         set diam_ap [expr $diam_ap*60]
         set obj_lune(diam_ap) "[format "%04.2f$caption(obj_lune1,minute_arc)" $diam_ap]"
         #--- Affichage de la magnitude
         set obj_lune(mag) "[format "%-03.1f" [lindex [lindex $obj_lune(ephemerides) 0] 7] ]"
         #--- Affichage de la fraction illuminee
         set angle_phase [lindex [lindex $obj_lune(ephemerides) 0] 9]
         set angle_phase1 [mc_angle2rad $angle_phase]
         set obj_lune(fraction_illu_%) [expr int(100.0*(1+cos($angle_phase1))/2)]
         set obj_lune(fraction_illu_%) "[format "%3d" $obj_lune(fraction_illu_%)]$caption(obj_lune1,pourcentage)"
         set obj_lune(fraction_illu) [expr (1+cos($angle_phase1))/2]
         #--- Calcul des librations
         set libration_lune [mc_libration $now -topo $audace(posobs,observateur,gps)]
         #--- Affichage de la libration en longitude
         set obj_lune(Lib_longitude) [lindex $libration_lune 0]
         set obj_lune(Lib_long) "[format "%4.2f" $obj_lune(Lib_longitude) ]"
         if { $obj_lune(Lib_long) < "0.0" } {
            set obj_lune(Lib_long) "$obj_lune(Lib_long)$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))"
         } else {
            set obj_lune(Lib_long) "$obj_lune(Lib_long)$caption(obj_lune1,degre) ($caption(obj_lune1,est))"
         }
         #--- Affichage de la libration en latitude
         set obj_lune(Lib_latitude) [lindex $libration_lune 1]
         set obj_lune(Lib_lat) "[format "%4.2f" $obj_lune(Lib_latitude) ]"
         if { $obj_lune(Lib_lat) < "0.0" } {
            set obj_lune(Lib_lat) "$obj_lune(Lib_lat)$caption(obj_lune1,degre) ($caption(obj_lune1,sud))"
         } else {
            set obj_lune(Lib_lat) "$obj_lune(Lib_lat)$caption(obj_lune1,degre) ($caption(obj_lune1,nord))"
         }
         #--- Affichage de la longitude du terminateur
         set Long_terminateur [lindex $libration_lune 5]
         if { ($Long_terminateur >= "0.0") && ($Long_terminateur <= "90.0") } {
            set Long_terminateur [expr (0.0 - $Long_terminateur)]
         } elseif { ($Long_terminateur > "90.0") && ($Long_terminateur <= "180.0") } {
            set Long_terminateur [expr (180.0 - $Long_terminateur)]
         } elseif { ($Long_terminateur > "180.0") && ($Long_terminateur <= "270.0") } {
            set Long_terminateur [expr (0.0 - $Long_terminateur + 180.0)]
         } elseif { ($Long_terminateur > "270.0") && ($Long_terminateur <= "360.0") } {
            set Long_terminateur [expr (360.0 - $Long_terminateur)]
         }
         set obj_lune(Long_terminateur) "[format "%4.2f" $Long_terminateur ]"
         if { $obj_lune(Long_terminateur) < "0.0" } {
            set obj_lune(Long_terminateur) "$obj_lune(Long_terminateur)$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))"
         } else {
            set obj_lune(Long_terminateur) "$obj_lune(Long_terminateur)$caption(obj_lune1,degre) ($caption(obj_lune1,est))"
         }
         #--- Recuperation de l'age de la Lune actuel
         ::obj_lune::Age_Lune [::audace::date_sys2ut now]
         #--- Affichage de l'age de la Lune
         if { $obj_lune(age_lune) > "1" } {
            set obj_lune(age_lune) "[format "%4.1f" $obj_lune(age_lune)] $caption(obj_lune1,jours)"
         } else {
            set obj_lune(age_lune) "[format "%4.1f" $obj_lune(age_lune)] $caption(obj_lune1,jour)"
         }
         #--- Preparation et affichage de la distance a la Terre
         set dist_Terre_Lune [lindex [lindex $obj_lune(ephemerides) 0] 12]
         set dist_Terre_Lune [expr (149597870.*$dist_Terre_Lune)]
         set obj_lune(dist_Terre_Lune) "[format "%06.0f$caption(obj_lune1,km)" $dist_Terre_Lune]"
         #--- Dessine la phase de la Lune sur la photo de l'onglet Ephemerides
         ::obj_lune::Lune_Dessine_Phase
         #--- Permet un affichage des ephemerides toutes les secondes
         after 1000 ::obj_lune::Lune_Ephemerides
      }
   }

   #
   # obj_lune::Lune_Phases
   # Calcule les dates des phases de la Lune
   #
   proc Lune_Phases { } {
      global obj_lune

      #--- Calcul et affichage des dates des phases de la Lune pendant le mois courant
      set PI "3.141592653589793"
      set rad [expr $PI / 180.0]
      set annee_courante [lindex [::audace::date_sys2ut now] 0]
      set mois_courant [string trimleft [lindex [::audace::date_sys2ut now] 1] 0]
      set an [expr ($annee_courante + ($mois_courant + $obj_lune(indice_mois)) / 12.0 )]
      set k [expr ($an - 1900.0) * 12.3685]
      set rk [expr int($k)]
      set k [expr ($rk - 0.25)]
      if { $k < "0" } {
         set k [expr ($k-1)]
      }
      for { set i 0 } { $i <= "3" } { incr i } {
         #--- Boucle sur les 4 phases de la Lune
         set k  [expr ($k + 0.25)]
         set t  [expr ($k / 1236.85)]
         set t2 [expr $t * $t]
         set t3 [expr ($t * $t2)]
         #--- Date Julienne de la phase moyenne
         set j [expr 2415020.75933 + 29.5305888531*$k + 0.0001337*$t2 - 0.000000150*$t3 + 0.00033*sin($rad*(166.56 + 132.87*$t - 0.009*$t2))]
         #--- Anomalie moyenne du Soleil
         set m [expr $rad*(359.2242 + 29.10535608*$k - 0.0000333*$t2 - 0.00000347*$t3)]
         #--- Anomalie moyenne de la Lune
         set mp [expr $rad*(306.0253 + 385.81691806*$k + 0.0107306*$t2 + 0.00001236*$t3)]
         #--- Argument de la latitude
         set f [expr $rad*(21.2964 + 390.67050646*$k - 0.0016528*$t2 - 0.00000239*$t3)]
         if { ($i == "0") || ($i == "2") } {
            #--- Terme correctif pour la Nouvelle Lune et la Pleine Lune
            set j [expr $j + (0.1734 - 0.000393*$t)*sin($m) + 0.0021*sin(2*$m) - 0.4068*sin($mp) + 0.0161*sin(2*$mp) - 0.0004*sin(3*$mp)\
                  + 0.0104*sin(2*$f) - 0.0051*sin($m+$mp) - 0.0074*sin($m-$mp) + 0.0004*sin(2*$f+$m) - 0.0004*sin(2*$f-$m)\
                  - 0.0006*sin(2*$f+$mp) + 0.001*sin(2*$f-$mp) + 0.0005*sin($m+2*$mp)]
            set date_phase  $j
            if { $i == "0" } {
               #--- Pour la Nouvelle Lune
               set date_phase [mc_date2ymdhms [list [mc_date2tt $date_phase]]]
               set obj_lune(date_phase_NL) [format "%02d/%02d/%2s   %02dh %02dm TU" [lindex $date_phase 2]\
                  [lindex $date_phase 1] [string range [lindex $date_phase 0] 2 3] [lindex $date_phase 3] [lindex $date_phase 4]]
            } elseif { $i == "2" } {
               #--- Pour la Pleine Lune
               set date_phase [mc_date2ymdhms [list [mc_date2tt $date_phase]]]
               set obj_lune(date_phase_PL) [format "%02d/%02d/%2s   %02dh %02dm TU" [lindex $date_phase 2]\
                  [lindex $date_phase 1] [string range [lindex $date_phase 0] 2 3] [lindex $date_phase 3] [lindex $date_phase 4]]
        }
         } else {
            #--- Terme correctif pour le Premier Quartier et le Dernier Quartier
            set j [expr $j + (0.1721 - 0.0004*$t)*sin($m) + 0.0021*sin(2*$m) - 0.6280*sin($mp) + 0.0089*sin(2*$mp) - 0.0004*sin(3*$mp)\
                  + 0.0079*sin(2*$f) - 0.0119*sin($m+$mp) - 0.0047*sin($m-$mp) + 0.0003*sin(2*$f+$m) - 0.0004*sin(2*$f-$m)\
                  - 0.0006*sin(2*$f+$mp) + 0.0021*sin(2*$f-$mp) + 0.0003*sin($m+2*$mp) + 0.0004*sin($m-2*$mp) - 0.0003*sin(2*$m+$mp)]
            if { $i == "1" } {
               #--- Pour le Premier Quartier
               set date_phase [expr $j + 0.0028 - 0.0004*cos($m) + 0.0003*cos($mp)]
               set date_phase [mc_date2ymdhms [list [mc_date2tt $date_phase]]]
               set obj_lune(date_phase_PQ) [format "%02d/%02d/%2s   %02dh %02dm TU" [lindex $date_phase 2]\
                  [lindex $date_phase 1] [string range [lindex $date_phase 0] 2 3] [lindex $date_phase 3] [lindex $date_phase 4]]
            } else {
               #--- Pour le Dernier Quartier
               set date_phase [expr $j - 0.0028 + 0.0004*cos($m) - 0.0003*cos($mp)]
               set date_phase [mc_date2ymdhms [list [mc_date2tt $date_phase]]]
               set obj_lune(date_phase_DQ) [format "%02d/%02d/%2s   %02dh %02dm TU" [lindex $date_phase 2]\
                  [lindex $date_phase 1] [string range [lindex $date_phase 0] 2 3] [lindex $date_phase 3] [lindex $date_phase 4]]
            }
         }
      }
   }

   #
   # obj_lune::precedant_suivant
   # Permet de passer au mois precedant ou suivant pour le calcul des dates des phases de la Lune
   #
   proc precedant_suivant { } {
      global obj_lune

      if { $obj_lune(change_mois) == "+" } {
         set obj_lune(indice_mois) [expr $obj_lune(indice_mois) + 1]
      } elseif { $obj_lune(change_mois) == "-" } {
         set obj_lune(indice_mois) [expr $obj_lune(indice_mois) - 1]
      }
      ::obj_lune::Lune_Phases
   }

   #
   # obj_lune::Meilleures_Dates
   # Calcule la date du meilleur moment d'une lunaison pour observer un site
   #
   proc Meilleures_Dates { } {
      global audace caption color obj_lune

      #--- Recherche de la premiere meilleure date
      #--- Preparation de l'heure TU pour le calcul des ephemerides
      set now [::audace::date_sys2ut now]
      #--- Initialisation de l'ecart en longitude
      set Ecart "0.5"
      #--- Mise en forme de la longitude selene dans le meme repere que la longitude du terminateur
      if { [string trimright [string trimright $obj_lune(long_selene) " "] E] == [string trimright $obj_lune(long_selene) " "] } {
         set long_selene_site [string trimright [string trimright $obj_lune(long_selene) " "] W]
      } else {
         set long_selene_site [string trimright [string trimright $obj_lune(long_selene) " "] E]
      }
      set long_selene_site [expr (-1) * $long_selene_site]
      if { $long_selene_site < "0" } {
         set long_selene_site [expr 360.0 + $long_selene_site]
      }
      #--- Recherche du meilleur moment
      for {set i 1} {$i <= 1440} {incr i} {
         #--- Transformation de la date en jours juliens
         set now [mc_date2jd $now]
         #--- Calcule la longitude du terminateur
         set long_term_meilleure_date [lindex [mc_libration $now -topo $audace(posobs,observateur,gps)] 5]
         #--- Comparaison de la longitude du terminateur et du site lunaire
         set Ecart_site_terminateur [ expr abs($long_term_meilleure_date - $long_selene_site) ]
         if { $Ecart_site_terminateur < $Ecart } {
            set long_term_meilleure_date_0 $long_term_meilleure_date
            #--- Affichage de la longitude du terminateur au meilleur moment
            if { ($long_term_meilleure_date_0 >= "0.0") && ($long_term_meilleure_date_0 <= "90.0") } {
               set long_term_meilleure_date_0 [expr (0.0 - $long_term_meilleure_date_0)]
            } elseif { ($long_term_meilleure_date_0 > "90.0") && ($long_term_meilleure_date_0 <= "180.0") } {
               set long_term_meilleure_date_0 [expr (180.0 - $long_term_meilleure_date_0)]
            } elseif { ($long_term_meilleure_date_0 > "180.0") && ($long_term_meilleure_date_0 <= "270.0") } {
               set long_term_meilleure_date_0 [expr (0.0 - $long_term_meilleure_date_0 + 180.0)]
            } elseif { ($long_term_meilleure_date_0 > "270.0") && ($long_term_meilleure_date_0 <= "360.0") } {
               set long_term_meilleure_date_0 [expr (360.0 - $long_term_meilleure_date_0)]
            }
            set long_term_meilleure_date_0 "[format "%4.2f" $long_term_meilleure_date_0 ]"
            break
         } else {
            #--- Incrementation de la date
            set now [expr $now + 1.0/(2 * 24.0)]
         }
      }
      #--- Mise en forme de l'heure d'observation
      set now_0 [mc_date2ymdhms $now]
      set now_0_1 [format "%02d/%02d/%2s" [lindex $now_0 2] [lindex $now_0 1] [string range [lindex $now_0 0] 2 3]]
      set now_0_2 [format "%02dh %02dm" [lindex $now_0 3] [lindex $now_0 4]]
      #--- Calcul des ephemerides de la Lune pour la premiere date
      set obj_lune(ephemerides_0) [mc_ephem {Moon} [list [mc_date2tt $now_0]] {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM PHASE ALTITUDE AZIMUTH DELTA HA} -topo $audace(posobs,observateur,gps)]
      #--- Calcul de la fraction illuminee pour la premiere date
      set angle_phase_0 [lindex [lindex $obj_lune(ephemerides_0) 0] 9]
      set angle_phase1_0 [mc_angle2rad $angle_phase_0]
      set obj_lune(fraction_illu_%_0) [expr int(100.0*(1+cos($angle_phase1_0))/2)]
      set obj_lune(fraction_illu_0) [expr (1+cos($angle_phase1_0))/2]
      set fraction_illu_0 "$obj_lune(fraction_illu_0)"
      #--- Calcul de l'age de la Lune pour la premiere date
      ::obj_lune::Age_Lune $now_0
      set age_lune_now_0 "$obj_lune(age_lune)"
      #--- Calcul des librations pour la premiere date
      set libration_lune_0 [mc_libration $now_0 -topo $audace(posobs,observateur,gps)]
      set obj_lune(Lib_lat_0) [lindex $libration_lune_0 1]
      set obj_lune(Lib_lat_0) "[format "%4.2f" $obj_lune(Lib_lat_0) ]"
      set obj_lune(Lib_long_0) [lindex $libration_lune_0 0]
      set obj_lune(Lib_long_0) "[format "%4.2f" $obj_lune(Lib_long_0) ]"
      #--- Dessine le terminateur pour la premiere date
      ::obj_lune::Lune_Dessine_Phase_Meilleure_Date $fraction_illu_0 $age_lune_now_0 $color(red)
      #--- Recherche de la deuxieme meilleure date
      #--- Preparation de l'heure TU pour le calcul des ephemerides
      set now [::audace::date_sys2ut now]
      #--- Recherche de l'autre meilleur moment
      for {set i 1} {$i <= 1440} {incr i} {
         #--- Transformation de la date en jours juliens
         set now [mc_date2jd $now]
         #--- Calcule la longitude du terminateur oppose
         set long_term_meilleure_date [lindex [mc_libration $now -topo $audace(posobs,observateur,gps)] 5]
         set long_term_meilleure_date [expr $long_term_meilleure_date + 180.0]
         if { $long_term_meilleure_date >= 360.0 } {
            set long_term_meilleure_date [expr $long_term_meilleure_date - 360.0]
         }
         #--- Comparaison de la longitude du terminateur oppose et du site lunaire
         set Ecart_site_terminateur [ expr abs($long_term_meilleure_date - $long_selene_site) ]
         if { $Ecart_site_terminateur < $Ecart } {
            set long_term_meilleure_date_180 $long_term_meilleure_date
            #--- Affichage de la longitude du terminateur au meilleur moment
            if { ($long_term_meilleure_date_180 >= "0.0") && ($long_term_meilleure_date_180 <= "90.0") } {
               set long_term_meilleure_date_180 [expr (0.0 - $long_term_meilleure_date_180)]
            } elseif { ($long_term_meilleure_date_180 > "90.0") && ($long_term_meilleure_date_180 <= "180.0") } {
               set long_term_meilleure_date_180 [expr (180.0 - $long_term_meilleure_date_180)]
            } elseif { ($long_term_meilleure_date_180 > "180.0") && ($long_term_meilleure_date_180 <= "270.0") } {
               set long_term_meilleure_date_180 [expr (0.0 - $long_term_meilleure_date_180 + 180.0)]
            } elseif { ($long_term_meilleure_date_180 > "270.0") && ($long_term_meilleure_date_180 <= "360.0") } {
               set long_term_meilleure_date_180 [expr (360.0 - $long_term_meilleure_date_180)]
            }
            set long_term_meilleure_date_180 "[format "%4.2f" $long_term_meilleure_date_180 ]"
            break
         } else {
            #--- Incrementation de la date
            set now [expr $now + 1.0/(2 * 24.0)]
         }
      }
      #--- Mise en forme de l'heure d'observation
      set now_180 [mc_date2ymdhms $now]
      set now_180_1 [format "%02d/%02d/%2s" [lindex $now_180 2] [lindex $now_180 1] [string range [lindex $now_180 0] 2 3]]
      set now_180_2 [format "%02dh %02dm" [lindex $now_180 3] [lindex $now_180 4]]
      #--- Calcul des ephemerides de la Lune pour la deuxieme date
      set obj_lune(ephemerides_180) [mc_ephem {Moon} [list [mc_date2tt $now_180]] {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM PHASE ALTITUDE AZIMUTH DELTA HA} -topo $audace(posobs,observateur,gps)]
      #--- Calcul de la fraction illuminee pour la deuxieme date
      set angle_phase_180 [lindex [lindex $obj_lune(ephemerides_180) 0] 9]
      set angle_phase1_180 [mc_angle2rad $angle_phase_180]
      set obj_lune(fraction_illu_%_180) [expr int(100.0*(1+cos($angle_phase1_180))/2)]
      set obj_lune(fraction_illu_180) [expr (1+cos($angle_phase1_180))/2]
      set fraction_illu_180 "$obj_lune(fraction_illu_180)"
      #--- Calcul des librations pour la deuxieme date
      set libration_lune_180 [mc_libration $now_180 -topo $audace(posobs,observateur,gps)]
      set obj_lune(Lib_lat_180) [lindex $libration_lune_180 1]
      set obj_lune(Lib_lat_180) "[format "%4.2f" $obj_lune(Lib_lat_180) ]"
      set obj_lune(Lib_long_180) [lindex $libration_lune_180 0]
      set obj_lune(Lib_long_180) "[format "%4.2f" $obj_lune(Lib_long_180) ]"
      #--- Calcul de l'age de la Lune pour la deuxieme date
      ::obj_lune::Age_Lune $now_180
      set age_lune_now_180 "$obj_lune(age_lune)"
      #--- Dessine le terminateur pour la deuxieme date
      ::obj_lune::Lune_Dessine_Phase_Meilleure_Date $fraction_illu_180 $age_lune_now_180 $color(blue)
      #--- Affichage des dates d'observation, des longitudes des terminateurs, des librations et des fractions illuminees de la Lune
      if { $now_0 < $now_180 } {
         $obj_lune(onglet5).frame8.labURL4a configure -text "$now_0_1" -fg $color(red)
         $obj_lune(onglet5).frame9.labURL5a configure -text "$now_0_2" -fg $color(red)
         if { $long_term_meilleure_date_0 < "0.0" } {
            $obj_lune(onglet5).frame10.labURL6a configure -text "$long_term_meilleure_date_0$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(red)
         } else {
            $obj_lune(onglet5).frame10.labURL6a configure -text "$long_term_meilleure_date_0$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(red)
         }
         if { $obj_lune(Lib_lat_0) < "0.0" } {
           $obj_lune(onglet5).frame11.labURL7a configure -text "$obj_lune(Lib_lat_0)$caption(obj_lune1,degre) ($caption(obj_lune1,sud))" -fg $color(red)
         } else {
           $obj_lune(onglet5).frame11.labURL7a configure -text "$obj_lune(Lib_lat_0)$caption(obj_lune1,degre) ($caption(obj_lune1,nord))" -fg $color(red)
         }
         if { $obj_lune(Lib_long_0) < "0.0" } {
            $obj_lune(onglet5).frame12.labURL8a configure -text "$obj_lune(Lib_long_0)$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(red)
         } else {
            $obj_lune(onglet5).frame12.labURL8a configure -text "$obj_lune(Lib_long_0)$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(red)
         }
         $obj_lune(onglet5).frame13.labURL9a configure -text "[format "%3d" $obj_lune(fraction_illu_%_0)]$caption(obj_lune1,pourcentage)" -fg $color(red)
         $obj_lune(onglet5).frame15.labURL11a configure -text "$now_180_1" -fg $color(blue)
         $obj_lune(onglet5).frame16.labURL12a configure -text "$now_180_2" -fg $color(blue)
         if { $long_term_meilleure_date_180 < "0.0" } {
            $obj_lune(onglet5).frame17.labURL13a configure -text "$long_term_meilleure_date_180$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(blue)
         } else {
            $obj_lune(onglet5).frame17.labURL13a configure -text "$long_term_meilleure_date_180$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(blue)
         }
         if { $obj_lune(Lib_lat_180) < "0.0" } {
           $obj_lune(onglet5).frame18.labURL14a configure -text "$obj_lune(Lib_lat_180)$caption(obj_lune1,degre) ($caption(obj_lune1,sud))" -fg $color(blue)
         } else {
           $obj_lune(onglet5).frame18.labURL14a configure -text "$obj_lune(Lib_lat_180)$caption(obj_lune1,degre) ($caption(obj_lune1,nord))" -fg $color(blue)
         }
         if { $obj_lune(Lib_long_180) < "0.0" } {
            $obj_lune(onglet5).frame19.labURL15a configure -text "$obj_lune(Lib_long_180)$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(blue)
         } else {
            $obj_lune(onglet5).frame19.labURL15a configure -text "$obj_lune(Lib_long_180)$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(blue)
         }
         $obj_lune(onglet5).frame20.labURL16a configure -text "[format "%3d" $obj_lune(fraction_illu_%_180)]$caption(obj_lune1,pourcentage)" -fg $color(blue)
      } else {
         $obj_lune(onglet5).frame8.labURL4a configure -text "$now_180_1" -fg $color(blue)
         $obj_lune(onglet5).frame9.labURL5a configure -text "$now_180_2" -fg $color(blue)
         if { $long_term_meilleure_date_180 < "0.0" } {
            $obj_lune(onglet5).frame10.labURL6a configure -text "$long_term_meilleure_date_180$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(blue)
         } else {
            $obj_lune(onglet5).frame10.labURL6a configure -text "$long_term_meilleure_date_180$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(blue)
         }
         if { $obj_lune(Lib_lat_180) < "0.0" } {
           $obj_lune(onglet5).frame11.labURL7a configure -text "$obj_lune(Lib_lat_180)$caption(obj_lune1,degre) ($caption(obj_lune1,sud))" -fg $color(blue)
         } else {
           $obj_lune(onglet5).frame11.labURL7a configure -text "$obj_lune(Lib_lat_180)$caption(obj_lune1,degre) ($caption(obj_lune1,nord))" -fg $color(blue)
         }
         if { $obj_lune(Lib_long_180) < "0.0" } {
            $obj_lune(onglet5).frame12.labURL8a configure -text "$obj_lune(Lib_long_180)$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(blue)
         } else {
            $obj_lune(onglet5).frame12.labURL8a configure -text "$obj_lune(Lib_long_180)$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(blue)
         }
         $obj_lune(onglet5).frame13.labURL9a configure -text "[format "%3d" $obj_lune(fraction_illu_%_180)]$caption(obj_lune1,pourcentage)" -fg $color(blue)
         $obj_lune(onglet5).frame15.labURL11a configure -text "$now_0_1" -fg $color(red)
         $obj_lune(onglet5).frame16.labURL12a configure -text "$now_0_2" -fg $color(red)
         if { $long_term_meilleure_date_0 < "0.0" } {
            $obj_lune(onglet5).frame17.labURL13a configure -text "$long_term_meilleure_date_0$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(red)
         } else {
            $obj_lune(onglet5).frame17.labURL13a configure -text "$long_term_meilleure_date_0$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(red)
         }
         if { $obj_lune(Lib_lat_0) < "0.0" } {
           $obj_lune(onglet5).frame18.labURL14a configure -text "$obj_lune(Lib_lat_0)$caption(obj_lune1,degre) ($caption(obj_lune1,sud))" -fg $color(red)
         } else {
           $obj_lune(onglet5).frame18.labURL14a configure -text "$obj_lune(Lib_lat_0)$caption(obj_lune1,degre) ($caption(obj_lune1,nord))" -fg $color(red)
         }
         if { $obj_lune(Lib_long_0) < "0.0" } {
            $obj_lune(onglet5).frame19.labURL15a configure -text "$obj_lune(Lib_long_0)$caption(obj_lune1,degre) ($caption(obj_lune1,ouest))" -fg $color(red)
         } else {
            $obj_lune(onglet5).frame19.labURL15a configure -text "$obj_lune(Lib_long_0)$caption(obj_lune1,degre) ($caption(obj_lune1,est))" -fg $color(red)
         }
         $obj_lune(onglet5).frame20.labURL16a configure -text "[format "%3d" $obj_lune(fraction_illu_%_0)]$caption(obj_lune1,pourcentage)" -fg $color(red)
      }
   }

   #
   # obj_lune::Age_Lune
   # Calcule l'age de la Lune
   #
   proc Age_Lune { { date "" } } {
      global obj_lune

      #--- Initialisation
      set PI "3.141592653589793"
      set rad [expr $PI / 180.0]
      #--- Calcul de la date julienne
      set date [::audace::date_sys2ut $date]
      set date [mc_date2jd $date]
      #--- Correction du TU vers le TE
      set tt [expr ($date - 2415020.0)/36525.0]
      set dT [expr (24.349 + 72.318*$tt + 29.950*$tt*$tt)/86400.0]
      set JJ [expr $date + $dT]
      #--- Calcul de T en siecle julien
      set T [expr ($JJ - 2415020.0) / 36525.0]
      set T2 [expr $T*$T]
      set T3 [expr $T*$T2]
      #--- Longitude du noeud ascendant de la Lune
      set O [expr $rad*(259.183275 - 1934.1420*$T + 0.002078*$T2 + 0.0000022*$T3)]
      #--- Longitude moyenne de la Lune
      set LL [expr $rad*(270.434164 + 481267.8831*$T - 0.001133*$T2 + 0.0000019*$T3 + 0.000233*sin($rad*(51.2 + 20.2*$T)) + 0.003964*sin($rad*(346.560 + 132.870*$T - 0.0091731*$T2)) + 0.001964*sin($O))]
      #--- Anomalie moyenne du Soleil
      set MS [expr $rad*(358.475833 + 35999.04975*$T - 0.000150*$T2 - 0.0000033*$T3 - 0.001778*sin($rad*(51.2 + 20.2*$T)))]
      #--- Anomalie moyenne de la Lune
      set ML [expr $rad*(296.104608 + 477198.8491*$T + 0.009192*$T2+ 0.0000144*$T3 + 0.000817*sin($rad*(51.2 + 20.2*$T)) + 0.003964*sin($rad*(346.560 + 132.870*$T - 0.0091731*$T2)) + 0.002541*sin($O))]
      #--- Elongation moyenne de la Lune
      set D [expr $rad*(350.737486 + 445267.1142*$T - 0.001436*$T2 + 0.0000019*$T3 + 0.002011*sin($rad*(51.2 + 20.2*$T)) + 0.003964*sin($rad*(346.560 + 132.870*$T - 0.0091731*$T2)) + 0.001964*sin($O))]
      #--- Distance moyenne de la Lune a son noeud ascendant
      set F [expr $rad*(11.250889 + 483202.0251*$T - 0.003211*$T2 - 0.0000003*$T3 + 0.003964*sin($rad*(346.560 + 132.870*$T - 0.0091731*$T2)) - 0.024691*sin($O) - 0.004328*sin($O + $rad*(275.05 - 2.30*$T)))]
      #--- Termes correctifs
      set e [expr 1 - 0.002495*$T - 0.00000752*$T2]
      set e2 [expr $e*$e]
      #--- Calcul de la longitude geocentrique de la Lune
      set lambda [expr $LL/$rad + 6.288750*sin($ML) + 1.274018*sin(2*$D-$ML) + 0.658309*sin(2*$D) + 0.213616*sin(2*$ML) - $e*0.185596*sin($MS) - 0.114336*sin(2*$F) + 0.058793*sin(2*$D-2*$ML) + $e*0.057212*sin(2*$D-$MS-$ML)\
          + 0.053320*sin(2*$D+$ML) + $e*0.045874*sin(2*$D-$MS) + $e*0.041024*sin($ML-$MS) - 0.034718*sin($D) - $e*0.030465*sin($MS+$ML) + 0.015326*sin(2*$D-2*$F) - 0.012528*sin(2*$F+$ML) - 0.010980*sin(2*$F-$ML)\
          + 0.010674*sin(4*$D-$ML) + 0.010034*sin(3*$ML) + 0.008548*sin(4*$D-2*$ML) - $e*0.007910*sin($MS-$ML+2*$D) - $e*0.006783*sin(2*$D+$MS) + 0.005162*sin($ML-$D) + $e*0.005000*sin($MS+$D) + $e*0.004049*sin($ML-$MS+2*$D)\
          + 0.003996*sin(2*$ML+2*$D) + 0.003862*sin(4*$D) + 0.003665*sin(2*$D-3*$ML) + $e*0.002695*sin(2*$ML-$MS) + 0.002602*sin($ML-2*$F-2*$D) + $e*0.002396*sin(2*$D-$MS-2*$ML) - 0.002349*sin($ML+$D) + $e2*0.002249*sin(2*$D-2*$MS)\
          - $e*0.002125*sin(2*$ML+$MS) - $e2*0.002079*sin(2*$MS) + $e2*0.002059*sin(2*$D-$ML-2*$MS) - 0.001773*sin($ML+2*$D-2*$F) - 0.001595*sin(2*$F+2*$D) + $e*0.001220*sin(4*$D-$MS-$ML) - 0.001110*sin(2*$ML+2*$F)\
          + 0.000892*sin($ML-3*$D) - $e*0.000811*sin($MS+$ML+2*$D) + $e*0.000761*sin(4*$D-$MS-2*$ML) + $e2*0.000717*sin($ML-2*$MS) + $e2*0.000704*sin($ML-2*$MS-2*$D) + $e*0.000693*sin($MS-2*$ML+2*$D) + $e*0.000598*sin(2*$D-$MS-2*$F)\
          + 0.000550*sin($ML+4*$D) + 0.000538*sin(4*$ML) + $e*0.000521*sin(4*$D-$MS) + 0.000486*sin(2*$ML-$D)]
      set lambda [expr ($lambda/360.0 - int($lambda/360.0))*360.0]
      #--- Longitude moyenne du Soleil
      set LS [expr $rad*(279.69668 + 36000.76892*$T + 0.0003025*$T2)]
      #--- Equation du centre du Soleil
      set CS [expr $rad*((1.919460 - 0.004789*$T - 0.000014*$T2)*sin($MS) + (0.020094 - 0.000100*$T)*sin(2*$MS) + 0.000293*sin(3*$MS))]
      #--- Longitude vraie du Soleil
      set LVS [expr ($LS + $CS)/$rad]
      set LVS [expr ($LVS/360.0 - int($LVS/360.0))*360.0]
      #--- Age de la Lune
      set age_lune [expr  $lambda - $LVS]
      if { $age_lune < "0" } {
         set age_lune [expr $age_lune + 360.0]
      }
      set obj_lune(age_lune) [expr 29.53058868*$age_lune/360.0]
      return $obj_lune(age_lune)
   }

}

