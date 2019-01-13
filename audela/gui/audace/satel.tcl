##@file satel.tcl
# @brief Outil pour calculer les positions précises de satellites avec les TLE
# @author Alain KLOTZ
# $Id: satel.tcl 14165 2017-01-21 22:43:52Z rzachantke $
# @warning utiliser le temps UTC
#

# source "$audace(rep_install)/gui/audace/satel.tcl"
#

## @code
# --- Pour télécharger les TLEs   (voir aussi l'outil ::satellites) :
# ::satel_update
# @endcode
#
# @code
# --- Pour calculer une position d'un satellite (voir aussi l'outil ::satellites)
# ::satel_coords "jason 2"
# ::satel_coords "jason 2" 2010-05-23T20:12:31
# ::satel_coords "jason 2" 2010-05-23T20:12:31 {GPS 4 E 56 345}
#  En sortie : nom ra dec equinox eclairement gisement elevation
# @endcode
#
# @code
# --- Pour rechercher un satellite au voisinage d'une position (voir aussi l'outil ::satellites)
# ::satel_nearest_radec 22h07m34s25 +60d17m33s0 2010-05-23T20:12:31 $home
#  En sortie : nom distmin
# @endcode
#
# @code
# --- Pour calculer la scene d'un satellite
# ::satel_scene ROS1 "jason 2"
# ::satel_scene ROS1 "jason 2" 2010-05-23T20:12:31
# ::satel_scene ROS1 "jason 2" 2010-05-23T20:12:31 {GPS 4 E 56 345}
#  En sortie : Texte en clair dans la console
# @endcode
#

#------------------------------------------------------------------------------
##@brief rechercher un satellite au voisinage d'une position (voir aussi l'outil ::satellites)
#
# @code
# satel_nearest_radec 22h07m34s25 +60d17m33s0 2010-05-23T20:12:31 $home
#  En sortie : nom distmin
# @endcode
#
# @param ra    ascension droite
# @param dec   déclinaison
# @param date (facultatif)  date UTC au format ISO  (valeur par defaut date et heure courante)
# @param home (facultatif)  lieu d'observation  (valeur par defaut = \::audace(posobs,observateur,gps) )
# @param radius_deg (facultatif)
# @return  Texte en clair dans la console
#
proc satel_nearest_radec { ra dec {date now} {home ""} {radius_deg ""} } {
   set sepanglemin 360
   set satelnames [satel_names]
   set ra [mc_angle2deg $ra]
   set dec [mc_angle2deg $dec 90]
   set nsat [llength $satelnames]
   set k 0
   set ksat 0
   set resfinal ""
   if {$radius_deg==""} {
      foreach satelname $satelnames {
         if {$k==10} {
            if {[info exists resmin]==0} {
               catch {::console::affiche_resultat "$ksat / $nsat\n"}
            } else {
               catch {::console::affiche_resultat "$ksat / $nsat sepmin=$sepanglemin [string trim [lindex [lindex $resmin 0] 0]]\n"}
            }
            set k 0
         }
         incr k
         incr ksat
         set satname [lindex $satelname 0]
         set ficname [lindex $satelname 1]
         #::console::affiche_resultat "$ksat, satel_ephem \"$satname\" $date $home\n"
         set err [catch {satel_ephem \"$satname\" $date $home} res]
         #::console::affiche_resultat "$ksat, err=$err res=$res\n"
         if {$err==1} {
            continue
         }
         if {$res==""} {
            continue
         }
         set res [lindex $res 0]
         if {[info exists resmin]==0} {
            set resmin $res
         }
         set err [catch {expr [lindex $res 1]} msg]
         if {$err==1} {
            continue
         }
         set name [string trim [lindex [lindex $res 0] 0]]
         set rasat [lindex $res 1]
         set decsat [lindex $res 2]
         set ill [lindex $res 6]
         set azim [lindex $res 8]
         set gise [expr $azim+180]
         if {$gise>360} {
            set gise [expr $gise-360]
         }
         set elev [lindex $res 9]
         set err [catch {mc_sepangle $ra $dec $rasat $decsat} resang]
         if {$err==1} {
            continue
         }
         set sepangle [lindex $resang 0]
         #::console::affiche_resultat "       sepangle=$sepangle sepanglemin=$sepanglemin\n"
         if {$sepangle<$sepanglemin} {
            set resmin $res
            set sepanglemin $sepangle
         }
      }
      set name [string trim [lindex [lindex $resmin 0] 0]]
      set rasat [mc_angle2hms [lindex $resmin 1] 360 zero 2 auto string]
      set decsat [mc_angle2dms [lindex $resmin 2] 90 zero 1 + string]
      set ill [lindex $resmin 6]
      set azim [lindex $resmin 8]
      set gise [expr $azim+180]
      if {$gise>360} {
         set gise [expr $gise-360]
      }
      set elev [lindex $resmin 9]
      set resfinal "$sepanglemin \"$name\" $ra $dec J2000.0 $ill [format %.5f $gise] [format %+.5f $elev]\n"
   } else {
      #set satelnames [lrange $satelnames 258 end]
      #set satelnames [lrange $satelnames 0 2]
      foreach satelname $satelnames {
         if {$k==100} {
            catch {::console::affiche_resultat "$ksat / $nsat\n"}
            update
            set k 0
         }
         incr k
         incr ksat
         set satname [lindex $satelname 0]
         set ficname [lindex $satelname 1]
         #::console::affiche_resultat "$ksat, satel_ephem \"$satname\" $date $home\n"
         set err [catch {satel_ephem \"$satname\" $date $home} res]
         #::console::affiche_resultat "$ksat, err=$err res=$res\n"
         if {$err==1} {
            continue
         }
         if {$res==""} {
            continue
         }
         set res [lindex $res 0]
         set err [catch {expr [lindex $res 1]} msg]
         if {$err==1} {
            continue
         }
         set name [string trim [lindex [lindex $res 0] 0]]
         set id1 [string trim [lindex [lindex $res 0] 1]]
         set id2 [string trim [lindex [lindex $res 0] 2]]
         set rasat [lindex $res 1]
         set decsat [lindex $res 2]
         set ill [lindex $res 6]
         set azim [lindex $res 8]
         set gise [expr $azim+180]
         if {$gise>360} {
            set gise [expr $gise-360]
         }
         set elev [lindex $res 9]
         set err [catch {mc_sepangle $ra $dec $rasat $decsat} resang]
         if {$err==1} {
            continue
         }
         set sepangle [lindex $resang 0]
         #::console::affiche_resultat "       sepangle=$sepangle radius_deg=$radius_deg\n"
         if {$sepangle<$radius_deg} {
            set resmin $res
            set name [string trim [lindex [lindex $resmin 0] 0]]
            set rasat [mc_angle2hms [lindex $resmin 1] 360 zero 2 auto string]
            set decsat [mc_angle2dms [lindex $resmin 2] 90 zero 1 + string]
            set ill [lindex $resmin 6]
            set azim [lindex $resmin 8]
            set gise [expr $azim+180]
            if {$gise>360} {
               set gise [expr $gise-360]
            }
            set elev [lindex $resmin 9]
            #::console::affiche_resultat "ksat=$ksat, err=$err res=$res\n"
            set date2 [mc_datescomp $date + [expr 1./86400]]
            set err [catch {satel_ephem \"$satname\" $date2 $home} res]
            set res [lindex $res 0]
            set rasat2 [mc_angle2hms [lindex $res 1] 360 zero 2 auto string]
            set decsat2 [mc_angle2dms [lindex $res 2] 90 zero 1 + string]
            set dresang [mc_anglesep [list $rasat2 $decsat2 $rasat $decsat]]
            set dsepangle [lindex $dresang 0]
            set dangle [lindex $dresang 1]
            set res "$ksat $sepangle \"$name\" $id1 $id2 $rasat $decsat J2000.0 $ill [format %f $dsepangle] [format %.1f $dangle] [format %.5f $gise] [format %+.5f $elev]\n"
            catch {::console::affiche_resultat "$ksat / $nsat $res"}
            append resfinal $res
         }
      }
   }
   return $resfinal
}

#------------------------------------------------------------------------------
## @brief calcule la liste des transits et des conjonctions d'un satellite avec un objet
#  @code
#  satel_transit ISS sun now 10
#  @endcode
#  @param satelname nom du satellite
#  @param objename nom de l'objet (Sun, Moon, ...)
#  @param date1 date de début
#  @param dayrange amplitude de recherche en jours
#  @param home position GPS
#  @return Texte en clair dans la console et deux listes
proc satel_transit { satelname objename date1 dayrange {home ""} } {
   global audace

   if {$home==""} {
      set home $::audace(posobs,observateur,gps)
   }
   set date $date1
   set res [satel_ephem $satelname $date $home]
   if {$res==""} {
      error "$res"
   }
   # --- calcule le temps revolution synodique
   set satinfo [satel_names $satelname]
   set name [lindex [lindex $satinfo 0] 0]
   set tle [lindex [lindex $satinfo 0] 1]
   #set satfile [ file join $::audace(rep_userCatalog) tle $tle ]
   set satfile [ file join $::conf(rep_userCatalogTle) $tle ]
   set f [open $satfile r]
   set lignes [split [read $f] \n]
   set n [llength $lignes]
   set tle1 ""
   set tle2 ""
   for {set k 0} {$k<$n} {incr k} {
      set ligne [lindex $lignes $k]
      set nam [string trim $ligne]
      if {$nam!=$name} {
         continue
      }
      set tle1 [lindex $lignes [expr $k+1]]
      set tle2 [lindex $lignes [expr $k+2]]
   }
   ::console::affiche_resultat "tle1=$tle1\n"
   ::console::affiche_resultat "tle2=$tle2\n"
   set incl [lindex $tle2 2]
   set revperday [lindex $tle2 7]
   set daymin 1436.
   set tsat [expr $daymin/$revperday]
   set tter $daymin
   if {$incl<90} {
      set sign -1
   } else {
      set sign 1
   }
   set tsyn [expr 1./(1./$tsat+1.*$sign/$tter)/1440.]
   ::console::affiche_resultat "revperday=$revperday $tsyn $incl\n"
   # ---- recherche la premiere conjonction satel-sun
   set sun_conjonctions ""
   set sun_transits ""
   set date1 [mc_date2jd $date1]
   set date11 [mc_date2jd $date1]
   set date22 [expr $date1+$dayrange]
   set ddate1 [expr $tsyn*1.1]
   set supersortie 0
   while {$supersortie==0} {
      set date2 [expr $date1+$ddate1]
      for {set k 0} {$k<10} {incr k} {
         set date $date1
         set range [expr $date2-$date1]
         set dt [expr $range/10.]
         set sortie 0
         set datemin $date1
         set sepmin 360.
         set sepmax 0.
         #::console::affiche_resultat "----------------- $k\n[mc_date2iso8601 $date1] [mc_date2iso8601 $date2] [expr $dt*1440]\n"
         while {$sortie==0} {
            set res [mc_ephem $objename $date {ra dec altitude} -topo $home]
            set res_sun  [lindex $res 0]
            set ra_sun [lindex $res_sun 0]
            set dec_sun [lindex $res_sun 1]
            set elev_sun [lindex $res_sun 2]
            #::console::affiche_resultat "satel_ephem $satelname $date $home\n"
            set res [satel_ephem $satelname $date $home]
            #::console::affiche_resultat "OK \n"
            set res [lindex $res 0]
            set name [string trim [lindex [lindex $res 0] 0]]
            set ra [lindex $res 1]
            set dec [lindex $res 2]
            set elev [lindex $res 9]
            set sepangle_sun  [lindex [mc_sepangle $ra $dec $ra_sun $dec_sun] 0]
            #::console::affiche_resultat "[mc_date2iso8601 $date] $sepangle_sun $sepmin\n"
            if {$sepangle_sun<$sepmin} {
               set sepmin $sepangle_sun
               set datemin $date
               set elevmin $elev
            }
            if {$sepangle_sun>$sepmax} {
               set sepmax $sepangle_sun
            }
            #::console::affiche_resultat "A date=$date [mc_date2iso8601 $date]\n"
            set date [mc_datescomp $date + $dt]
            #::console::affiche_resultat "B date=$date [mc_date2iso8601 $date]\n"
            if {$date>$date2} {
               set sortie 1
               break
            }
         }
         #::console::affiche_resultat "*** [mc_date2iso8601 $datemin] $sepmin\n"
         set date1 [expr $datemin-2*$dt]
         set date2 [expr $datemin+2*$dt]
         set dsep [expr $sepmax-$sepmin]
         if {$dsep<0.5} {
            set sortie 2
            break
         }
         if {$dt<[expr 1./86400]} {
            set sortie 22
            break
         }
      }
      if {($sepmin<1.)&&($elevmin>0)} {
         lappend sun_transits "$datemin $sepmin $elevmin"
      }
      append sun_conjonctions "[mc_date2iso8601 $datemin] $sepmin ($elevmin)\n"
      ::console::affiche_resultat "Conjonction [mc_date2iso8601 $datemin] $sepmin ($elevmin)\n"
      set date1 [expr $datemin+$tsyn]
      set ddate1 [expr $tsyn*0.1]
      if {$datemin>$date22} {
         set sortie 3
         break
      }
   }
   return [list $sun_transits $sun_conjonctions]
}

#------------------------------------------------------------------------------
##@brief calculer la scene d'un satellite
#
# @code
# satel_scene ROS1 "jason 2"
# satel_scene ROS1 "jason 2" 2010-05-23T20:12:31
# satel_scene ROS1 "jason 2" 2010-05-23T20:12:31 {GPS 4 E 56 345}
# @endcode
#
# @param formatscene (facultatif)
#    - ROS1 : Format pour le formulaire CADOR (valeur par défaut)
#    - ROS2 : Format pour le formulaire de la page web de maintenance
#    - TEL1 : Format pour envoyer les commandes au telescope tel1
# @param satelname (facultatif)  nom du satellite (valeur par défaut = ISS)
# @param date (facultatif)  date UTC au format ISO  (valeur par defaut date et heure courante)
# @param home (facultatif)  lieu d'observation  (valeur par defaut = \::audace(posobs,observateur,gps) )
#
proc satel_scene { {formatscene ROS1} {satelname "ISS"} {date now} {home ""} } {
   global audace
   set texte ""
   if {$home==""} {
      set home $audace(posobs,observateur,gps)
   }
   set res [satel_ephem $satelname $date $home]
   if {$res==""} {
      error "$res"
   }
   set dateiso [mc_date2iso8601 $date]
   set r [string range $dateiso 0 18]
   regsub -all T $r " " dateiso
   set res [lindex $res 0]
   set name [string trim [lindex [lindex $res 0] 0]]
   regsub -all " " $name _ r
   regsub -all {[][]} $r "" name
   set ra1 [lindex $res 1]
   set ra [mc_angle2hms $ra1 360 zero 2 auto string]
   regsub -all \[h,m\] $ra : r
   regsub -all \[s\] $r . ra
   set dec1 [lindex $res 2]
   set dec [mc_angle2dms $dec1 90 zero 1 + string]
   regsub -all \[d,m\] $dec : r
   regsub -all \[s\] $r . dec
   set ill [lindex $res 6]
   set distkm [expr [lindex $res 3]*1e-3]
   set azim [lindex $res 8]
   set elev [lindex $res 9]
   set res [mc_radec2altaz $ra1 $dec1 $home $date]
   set ha1 [lindex $res 2]
   set drasid [expr 360./(23.9344696*3600)]
   set dt 5.
   set date [mc_datescomp $date + [expr $dt/86400.]]
   set res [satel_ephem $satelname $date $home]
   set res [lindex $res 0]
   set ra2 [lindex $res 1]
   set dec2 [lindex $res 2]
   set res [mc_radec2altaz $ra2 $dec2 $home $date]
   set ha2 [lindex $res 2]
   set dha [expr ($ha2-$ha1)/$dt]
   if {$dha> 180} { set dha [expr $dha-180] }
   if {$dha<-180} { set dha [expr $dha+180] }
   set dra [expr $drasid-($ra2-$ra1)/$dt]
   if {$dra> 180} { set dra [expr $dra-180] }
   if {$dra<-180} { set dra [expr $dra+180] }
   set ddec [expr ($dec2-$dec1)/$dt]
   set sepangle [lindex [mc_sepangle $ra1 $dec1 $ra2 $dec2] 0]
   set speed [expr $sepangle/$dt]
   append texte "=== Format $formatscene ===\n"
   if {$formatscene=="TEL1"} {
      append texte "Name $name\n"
      append texte "tel1 speedtrack [format %.7f $dra] [format %.7f $ddec]\n"
      append texte "tel1 radec goto \{[format %.5f $ra1] [format %.5f $dec1]\} -blocking 1\n"
   } elseif {$formatscene=="ROS2"} {
      append texte "Name $name\n"
      append texte "[format %.5f $ra1] [format %.5f $dec1] J2000.0 20 20 [format %.7f $dra] [format %.7f $ddec]\n"
   } else {
      append texte "Name $name\nRA $ra\nDEC $dec\ndra (deg/sec): [format %.7f $dra]\nddec (deg/sec): [format %.7f $ddec]\nDate $dateiso\n"
   }
   append texte "=== Other details ===\n"
   append texte "Illumination $ill\nDistance [format %.1f $distkm] km\n"
   append texte "Azimuth [format %.5f $azim] deg\nElevation [format %+.5f $elev] deg\n"
   append texte "HA speed [format %.5f $dha] deg/sec $ha1 $ha2\n"
   append texte "Speed [format %.5f $speed] deg/sec\n"
   return $texte
}

#------------------------------------------------------------------------------
## @brief calculer une position d'un satellite (voir aussi l'outil ::satellites)
#
# @code
# exemples :
# satel_coords "jason 2"
# satel_coords "jason 2" 2010-05-23T20:12:31
# satel_coords "jason 2" 2010-05-23T20:12:31 {GPS 4 E 56 345}
# @endcode
# @param satelname  (facultatif) nom du satellite (valeur par défaut = ISS)
# @param date (facultatif)  date UTC au format ISO  (valeur par defaut date et heure courante)
# @param home (facultatif)  lieu d'observation  (valeur par defaut = \::audace(posobs,observateur,gps) )
# @return nom ra dec equinox eclairement gisement elevation
proc satel_coords { {satelname "ISS"} {date now} {home ""} } {
   set res [satel_ephem $satelname $date $home]
   if {$res==""} {
      error "$res"
   }
   set res [lindex $res 0]
   set name [string trim [lindex [lindex $res 0] 0]]
   set ra [mc_angle2hms [lindex $res 1] 360 zero 2 auto string]
   set dec [mc_angle2dms [lindex $res 2] 90 zero 1 + string]
   set ill [lindex $res 6]
   set azim [lindex $res 8]
   set gise [expr $azim+180]
   if {$gise>360} {
      set gise [expr $gise-360]
   }
   set elev [lindex $res 9]
   set res "\"$name\" $ra $dec J2000.0 $ill [format %.5f $gise] [format %+.5f $elev]\n"
   return $res
}

#-----------------------------------
## @brief cette fonction retourne le résultat de mc_tle2ephem (fonction non documentée)
#  @param satelname nom du satellite
#  @param date date TU (now par défaut)
#  @param home position GPS (facultatif)
#  @param satfile nom du fichier TLE (facultatif)
#  @return une liste telle que {{ISS (ZARYA)} {25544U} {98067A}} 295.314971775334870 3.606638078375271 8445039.44621498 111.607298702035050 68.396245471492549 1.0000 {GPS 174.758315 W 51.729348 409206.339635} 177.858508952084240 -37.646193636973962 1.416361350870819 178.301085427573810
#- nom du satellite
#- identificateur Norad
#- idendificateur de classification
#- AD en degrés
#- DEC en degrés
#- la distance au centre de la Terre en m
#- l'élongation par rapport au Soleil en degrés
#- la phase en degrés
#- l'illumination
#- les coordonnées GPS du satellite
#- l'azimuth en degrés
#- la hauteur en degrés
#
proc satel_ephem { {satelname "ISS"} {date now} {home ""} {satfile ""} } {

   set res [lindex [satel_names \"$satelname\" 1] 0]
   if {$res==""} {
      error "Satellite \"$satelname\" not found in current TLEs."
   }
   set satname [lindex $res 0]
   #set satfile [ file join $::audace(rep_userCatalog) tle [lindex $res 1] ]
   set satfile [ file join $::audace(rep_userCatalogTle) [lindex $res 1] ]
   #set datfile [ file mtime [ file join $::audace(rep_userCatalog) tle [lindex $res 1] ] ]
   set datfile [ file mtime [ file join $::audace(rep_userCatalogTle) [lindex $res 1] ] ]
   set dt [expr ([clock seconds]-$datfile)/86400]
   #::console::affiche_resultat "Update = $dt jours\n"
   if {$home==""} {
      set home $::audace(posobs,observateur,gps)
   }
   #::console::affiche_resultat "mc_tle2ephem $date \"$satfile\" $home -name \"$satname\" -sgp 4\n"
   set res [mc_tle2ephem $date $satfile $home -name $satname -sgp 4 ] ; # -coord {ra dec}
   return $res
}

#-----------------------------------
## @brief cette fonction retourne le résultat de mc_tle2ephem (fonction non documentée)
#  @param date date TU (now par défaut)
#  @param home position GPS (facultatif)
#  @param fileout nom court du fichier dans \$audace(rep_images) (facultatif)
#  @return une liste de tous les atellites telle que {{ISS (ZARYA)} {25544U} {98067A}} 295.314971775334870 3.606638078375271 8445039.44621498 111.607298702035050 68.396245471492549 1.0000 {GPS 174.758315 W 51.729348 409206.339635} 177.858508952084240 -37.646193636973962 1.416361350870819 178.301085427573810
#- nom du satellite
#- identificateur Norad
#- idendificateur de classification
#- AD en degrés
#- DEC en degrés
#- la distance au centre de la Terre en m
#- l'élongation par rapport au Soleil en degrés
#- la phase en degrés
#- l'illumination
#- les coordonnées GPS du satellite
#- l'azimuth en degrés
#- la hauteur en degrés
#
proc satel_ephems { {date now} {home ""} {fileout ""} } {
   global audace
   set res [satel_names ""]
   if {$res==""} {
      error "No satellite was found in current TLEs."
   }
   set ephems ""
   set satnames $res
   foreach satname $satnames {
      set res $satname
      set satname [lindex $res 0]
      #set satfile [ file join $::audace(rep_userCatalog) tle [lindex $res 1] ]
      set satfile [ file join $::audace(rep_userCatalogTle) [lindex $res 1] ]
      #set datfile [ file mtime [ file join $::audace(rep_userCatalog) tle [lindex $res 1] ] ]
      set datfile [ file mtime [ file join $::audace(rep_userCatalogTle) [lindex $res 1] ] ]
      set dt [expr ([clock seconds]-$datfile)/86400]
      #::console::affiche_resultat "Update = $dt jours\n"
      if {$home==""} {
         set home $::audace(posobs,observateur,gps)
      }
      #::console::affiche_resultat "mc_tle2ephem $date \"$satfile\" $home -name \"$satname\" -sgp 4\n"
      set res [mc_tle2ephem $date $satfile $home -name $satname -sgp 4 ] ; # -coord {ra dec}
      lappend ephems [lindex $res 0]
   }
   set res ""
   foreach ephem $ephems {
      set names [lindex $ephem 0]
      if {$names==""} {
         continue
      }
      lappend res $ephem
   }
   set ephems $res
   set ephems [lsort -index 1 -real $ephems]
   if {$fileout!=""} {
      set lignes ""
      foreach ephem $ephems {
         set ra  [lindex $ephem 1]
         set dec [lindex $ephem 2]
         set names [lindex $ephem 0]
         if {$names==""} {
            continue
         }
         #::console::affiche_resultat "ra=$ra dec=$dec names=$names\n"
         set ligne "[format %9.5f $ra] [format %+9.5f $dec] $names"
         append lignes "${ligne}\n"
      }
      set f [open $audace(rep_images)/$fileout w]
      puts -nonewline $f $lignes
      close $f
   }
   return $res
}


#------------------------------------------------------------------------------
##@brief satel_names
#
# @param satelname (facultatif)
# @param nbmax     (facultatif)
# @param getelems (facultatif)  (valeur par defaut = 0)
#
# @return the list of NAMES+FILE for a given satelname if getelems=0 <br>
#      or the iste of NAMES+FILE+TLE data lines        if getelems=1
# @warning satelname=ISS returns several "ISS (ZARYA)"+"AISSAT"+"SWISSCUBE"
#
proc satel_names { {satelname ""} {nbmax ""} {getelems 0} } {
   global audace
   set server [satel_server]
   set tlefiles $audace(satel,tlefiles)
   set texte ""
   set nsat 0
   if {$nbmax==""} {
      set nbmax 100000
   }
   #set satelname [string trim [string trim [string toupper $satelname] \"]]
   set satelname [string trim [string trim $satelname \"]]
   foreach tlefile $tlefiles {
      #set tlefile [ file join $::audace(rep_userCatalog) tle $tlefile]
      set tlefile [ file join $::audace(rep_userCatalogTle) $tlefile]
      if {[file exists $tlefile]==0} {
         continue
      }
      set f [open $tlefile r]
      set lignes [split [read $f] \n]
      close $f
      set k 0
      set gk -1
      foreach ligne $lignes {
         incr gk
         if {[string length $ligne]>2} {
            if {$k==0} {
              set name [string trim $ligne]
               if {$satelname!=""} {
                  set k [string first $satelname $name]
                  #::console::affiche_resultat "k=$k\n"
                  #dddd
               } else {
                  set k 0
               }
               if {($k>=0)&&($nsat<=$nbmax)} {
                  if {$getelems==0} {
                     lappend texte [list $name [file tail $tlefile]]
                  } else {
                     lappend texte [list $name [file tail $tlefile] [lindex $lignes [expr $gk+1]] [lindex $lignes [expr $gk+2]] ]
                  }
                  incr nsat
               }
            }
            incr k
            if {$k==3} {
               set k 0
            }
         }
      }
   }
   return $texte
}

#  @return Return all TLE filenames stored in AudeLA
proc satel_tlefiles { } {
   #set tlefiles [ glob -nocomplain [ file join $::audace(rep_userCatalog) tle *.txt ] ]
   set tlefiles [ glob -nocomplain [ file join $::audace(rep_userCatalogTle) *.txt ] ]
   set texte ""
   foreach tlefile $tlefiles {
      append texte "[file tail $tlefile] "
   }
   return $texte
}

## @brief  Update TLE files in AudeLA (voir aussi l'outil ::satellites)
#
# @param server (facultatif) celestrack | spacetrack
# @param param1
# @param param2
# @return ntot nombre total de satellites
proc satel_update { { server "" } {param1 ""} {param2 ""} } {
   global audace
   set t0 [clock seconds]
   set server [lindex $server 0]
   set k [lsearch -exact [satel_server ?] $server]
   if {$k==-1} {
      set server celestrack
   }
   set server0 [satel_server]
   satel_server $server
   catch {::console::affiche_resultat "Server $server\n"}
   if {$server=="celestrack"} {
      set elemfiles $audace(satel,tlefiles)
      set ntot 0
      foreach elemfile $elemfiles {
         set url "http://celestrak.com/NORAD/elements/$elemfile"
         catch {::console::affiche_resultat "Download $url\n"}
         set err [catch {
            package require http
            set token [::http::geturl $url]
            upvar #0 $token state
            set html_text $state(body)
            # --- close the http connexion
            ::http::cleanup $token
         } msg]
         if {$err==0} {
            if {[string first "<!DOCTYPE" $html_text]>=0} {
               set err 1
               set msg "File not found in server"
            }
         }
         if {$err==1} {
            catch {::console::affiche_resultat " Problem: $msg.\n"}
         } else {
            set msg $html_text
            set texte ""
            set n 0
            set lignes [split $msg \n]
            foreach ligne $lignes {
               if {[string length $ligne]>2} {
                  append texte "$ligne\n"
               }
               incr n
            }
            set n [expr $n/3]
            incr ntot $n
            #file mkdir [ file join $::audace(rep_userCatalog) tle ]
            file mkdir $::audace(rep_userCatalogTle)
            set err [catch {
               #set fic [ file join $::audace(rep_userCatalog) tle $elemfile ]
               set fic [ file join $::audace(rep_userCatalogTle) $elemfile ]
               set f [open $fic w]
               puts -nonewline $f $texte
               close $f
            } msg]
            if {$err==1} {
               catch {::console::affiche_resultat " Problem: $msg.\n"}
            } else {
               catch {::console::affiche_resultat " $n satellites in $elemfile\n"}
            }
         }
      }
      #catch {::console::affiche_resultat "A total of $ntot satellites elements are downloaded in [ file join $::audace(rep_userCatalog) tle ]\n"}
      catch {::console::affiche_resultat "A total of $ntot satellites elements are downloaded in [ file join $::audace(rep_userCatalogTle) ]\n"}
   } elseif {$server=="spacetrack"} {
      set ntot 0
      set username [lindex $param1 0]
      set password [lindex $param2 0]
      # -- login & cookies
      package require http
      package require tls
      set url https://www.space-track.org/perl
      set login [::http::formatQuery _submitted 1 _sessionid "" _submit Submit username $username password $password]
      http::register https 443 ::tls::socket
      set tok [::http::geturl $url/login.pl -query $login]
      upvar \#0 $tok state
      set cookies [list]
      foreach {name value} $state(meta) {
         if { $name eq "Set-Cookie" } {
            lappend cookies [lindex [split $value {;}] 0]
         }
      }
      set res $state(body)
      ::http::cleanup $tok
      # --- download
      set tok [::http::geturl $url/dl.pl?ID=2 -headers [list Cookie [join $cookies {;}]]]
      upvar #0 $tok state
      if {[::http::status $tok]!="ok"} {
         catch {::console::affiche_resultat " Problem: $res.\n"}
         return ""
      }
      set data [::http::data $tok]
      if {[string first "<!DOCTYPE html" $data]>=0} {
         error "login and/or password problem\nUse https://www.space-track.org/perl/login.pl\n"
      }
      # --- save the TLE file
      #file mkdir [ file join $::audace(rep_userCatalog) tle ]
      file mkdir [ file join $::audace(rep_userCatalogTle) ]
      set elemfile spacetrack.txt
      set err [catch {
         #set fic [ file join $::audace(rep_userCatalog) tle $elemfile ]
         set fic [ file join $::audace(rep_userCatalogTle) $elemfile ]
         set f [open $fic w]
         close $f
      } msg]
      if {$err==1} {
         catch {::console::affiche_resultat " Problem: $msg.\n"}
      } else {
         # --- save the .gz file
         set f [open "${fic}.gz" w]
         fconfigure $f -translation binary
         puts -nonewline $f [::http::data $tok]
         close $f
         catch {file delete "$fic"}
         # --- unzip the .gz file
         gunzip "${fic}.gz"
         # --- close the http connexion
         ::http::cleanup $tok
         catch {::console::affiche_resultat " Spacetrack file download succes.\n"}
         # --- load the raw file
         set f [open $fic r]
         set lignes [split [read $f] \n]
         close $f
         # --- store the TLEs in a Tcl list
         set nl [llength $lignes]
         catch {unset tles}
         set ntot 0
         for {set k 0} {$k<$nl} {incr k 3} {
            set ligne [lindex $lignes [expr $k+0]]
            set name_cur [string trim $ligne]
            if {[string length $name_cur]<2} {
               continue
            }
            set ligne [lindex $lignes [expr $k+1]]
            set lig1 $ligne
            set ligne [lindex $lignes [expr $k+2]]
            set lig2 $ligne
            set tle [list $name_cur $lig1 $lig2]
            set tles($ntot) $tle
            incr ntot
         }
         catch {::console::affiche_resultat " Sort $ntot satellites...\n"}
         # --- sort TLE list
         set n $ntot
         set percent 0
         set percentot 0
         set k11 0
         for {set k1 0} {$k1<[expr $n-1]} {incr k1} {
            set name1 [lindex $tles($k1) 0]
            set percent [expr 100.*$k11/$n]
            if {$percent>10} {
               incr percentot 10
               catch {::console::affiche_resultat " $percentot percent sorted...\n"}
               set k11 0
            }
            for {set k2 [expr $k1+1]} {$k2<$n} {incr k2} {
               set name2 [lindex $tles($k2) 0]
               set k [string compare $name1 $name2]
               #catch {::console::affiche_resultat " k1=$k1 k2=$k2 name1=$name1 name2=$name2 k=$k \n"}
               if {$k==1} {
                  # --- swap
                  #catch {::console::affiche_resultat " Swap \n"}
                  set tle $tles($k1)
                  set tles($k1) $tles($k2)
                  set tles($k2) $tle
                  set name1 [lindex $tles($k1) 0]
               }
            }
            incr k11
         }
         set percentot 100
         catch {::console::affiche_resultat " $percentot percent sorted...\n"}
         catch {::console::affiche_resultat " Index for satellites of same names...\n"}
         # --- add index if name are the same
         set texte ""
         set n 0
         set name_prev ""
         for {set k 0} {$k<$ntot} {incr k} {
            set name_cur [lindex $tles($k) 0]
            set lig1 [lindex $tles($k) 1]
            set lig2 [lindex $tles($k) 2]
            if {$k==[expr $ntot-1]} {
               set name_next ""
            } else {
               set name_next [lindex $tles([expr $k+1]) 0]
            }
            if {($name_cur!=$name_prev)&&($name_cur==$name_next)} {
               set kname 1
            } elseif {($name_cur==$name_prev)} {
               incr kname
            } else {
               set kname 0
            }
            set name_prev $name_cur
            if {$kname>0} {
               append name_cur " #$kname"
            }
            append texte "$name_cur\n"
            append texte "$lig1\n"
            append texte "$lig2\n"
            incr n
         }
         set ntot $n
         set err [catch {
            set f [open $fic w]
            puts -nonewline $f $texte
            close $f
         } msg]
         if {$err==1} {
            catch {::console::affiche_resultat " Problem: $msg.\n"}
         } else {
            catch {::console::affiche_resultat " A total of $n satellites elements are downloaded in $elemfile\n"}
         }
      }
   } else {
      error "Server not known. Servers are: celestrack."
   }
   set dt [expr [clock seconds]-$t0]
   catch {::console::affiche_resultat "Done in $dt seconds.\n\n"}
   satel_server $server0
   return $ntot
}

## @brief liste les satellites dans une zone limitée par ra1 ra2 dec1 dec2 (voir aussi l'outil ::satellites)
#  @code
#  satel_zone_radec 0 120 +30d00m00s0 +60d00m00s 2012-07-24T20:12:31 $home
#  @endcode
#  @param ra1
#  @param ra2
#  @param dec1
#  @param dec2
#  @param date date TU, now par défaut
#  @param home
#  @return Texte en clair dans la console
proc satel_zone_radec { ra1 ra2 dec1 dec2 {date now} {home ""} } {

   set satelnames [satel_names]
   set ra1 [string trim [mc_angle2deg $ra1]]
   set dec1 [string trim [mc_angle2deg $dec1 90]]
   set ra2 [string trim [mc_angle2deg $ra2]]
   set dec2 [string trim [mc_angle2deg $dec2 90]]
   set nsat [llength $satelnames]
   set ksat 0
   set k 0

   ::console::affiche_resultat "nsat : $nsat , zone de recherche : $ra1 $dec1 $ra2 $dec2\n"
   foreach satelname $satelnames {
      incr ksat
      set satname [lindex $satelname 0]
      set ficname [lindex $satelname 1]
      #::console::affiche_resultat "$ksat, satel_ephem \"$satname\" $date $home\n"
      set err [catch {satel_ephem \"$satname\" $date $home} res]
      #::console::affiche_resultat "$ksat, err=$err res=$res\n"
      if {$err==1} {
         continue
      }
      if {$res==""} {
         continue
      }
      set res [lindex $res 0]
      if {[string compare [lindex $res 1] -nan]==0} {
         continue
      }
      set name [string trim [lindex [lindex $res 0] 0]]
      set rasat [string trim [lindex $res 1]]
      set decsat [string trim [lindex $res 2]]
      set ill [lindex $res 6]
      set azim [lindex $res 8]
      set gise [expr $azim+180]
      if {$gise>360} {
         set gise [expr $gise-360]
      }
      set elev [lindex $res 9]
      # test si le sat est dans la zone defini par ra1 dec1 ra2 dec2
      #catch {::console::affiche_resultat "---: $ksat / $nsat [string trim [lindex [lindex $res 0] 0]] $rasat $decsat [expr $rasat>$ra1] [expr $rasat<$ra2] [expr $decsat>$dec1] [expr $decsat<$dec2]\n"}
      if {($rasat>$ra1)&&($rasat<$ra2)&&($decsat>$dec1)&&($decsat<$dec2)} {
         incr k
         catch {::console::affiche_resultat "$k: $ksat / $nsat [string trim [lindex [lindex $res 0] 0]] $rasat $decsat\n"}
      }

   }
   return
}

# Download one TLE file and return the contents
# proc satel_download { {url http://celestrak.com/NORAD/elements/stations.txt} } {
#    set err [catch {
#       package require http
#       set token [::http::geturl $url]
#       upvar #0 $token state
#       set html_text $state(body)
#    } msg]
#    if {$err==0} {
#       if {[string first "<!DOCTYPE" $html_text]<0} {
#          return $html_text
#       } else {
#          error "File not found in server"
#       }
#    } else {
#       error $msg
#    }
# }

proc satel_server { { server "" } } {
   global audace
   set server [lindex $server 0]
   if {[info exists audace(satel,server)]==0} {
      set server "celestrack"
   }
   if {$server==""} {
      return $audace(satel,server)
   } elseif {$server=="?"} {
      return "celestrack spacetrack"
   } elseif {$server=="spacetrack"} {
      set audace(satel,server) "spacetrack"
      set audace(satel,tlefiles) { spacetrack.txt }
   } else {
      set audace(satel,server) "celestrack"
      set audace(satel,tlefiles) { amateur.txt classfd.txt cubesat.txt dmc.txt education.txt engineering.txt geo.txt geodetic.txt glo-ops.txt globalstar.txt goes.txt gorizont.txt gps-ops.txt intelsat.txt iridium.txt military.txt molniya.txt musson.txt nnss.txt noaa.txt orbcomm.txt other-comm.txt other.txt radar.txt raduga.txt resource.txt sarsat.txt science.txt stations.txt tdrss.txt tle-new.txt visual.txt weather.txt x-comm.txt }
   }
   return $audace(satel,server)
}

#--------------------------------------- ajout RZ -----------------------------------------------

#-----------------------------------
##@brief  variante de satel_names
#
# @code
#  Ex1 : satel_names2 "" "" 0 returns  a list of all satellites (name + short tlefile + noradID)
#        and create audace(satel,shortList) with (name)
#  Ex2 : satel_names2 "ISS" 1 1 returns  a list of satellite (name + short tlefile + 2 lines of data)
# @endcode
#
# @param satelname (facultatif)
# @param nbmax     (facultatif)  (valeur par defaut = 1)
# @param getelems (facultatif)  (valeur par defaut = 0)
#
# @return the list of NAMES+FILE+NORADID for a given satelname
#
proc satel_names2 { {satelname ""} {nbmax "1"} {getelems 0} } {
   package require struct::list

   set server [satel_server]
   set tlefiles $::audace(satel,tlefiles)

   set texte ""
   set nsat 0
   if {$satelname ne ""} {
      set nbmax 1
   } else {
      set nbmax 100000
   }

   set satelname [string trim $satelname \"]
   foreach satfile $tlefiles {

      #--   Arrete si le nombre max de satellites est atteint
      if {$nsat >= $nbmax} {
         break
      }

     #set tlefile [ file join $::audace(rep_userCatalog) tle $satfile]
      set tlefile [ file join $::audace(rep_userCatalogTle) $satfile]
      if {[file exists $tlefile] eq "0"} {
         continue
      }

      #--   Extrait le contenu du fichier
      regsub -all {\{\}} [split [K [read [set fi [open $tlefile]]] [close $fi]] "\n"] "" lignes

      foreach {name line1 line2} $lignes {
         #--   ote les scories comme [+] [?] [-]
         regsub -all {\[.+\]} $name "" name
         #--   Ote les espaces superflus
         set name [string trim $name]
         set noradID [string trim [lindex $line1 1]]
         if {$satelname eq ""} {
            #--   Option getelems 0
            lappend texte [list $name $satfile $noradID]
         } else {
            #--   Option getelems 1
            if {$getelems eq "1" && $nsat <= $nbmax && $satelname eq "$name"} {
               lappend texte [list $name $satfile $line1 $line2]
               incr nsat
            }
         }
      }
   }

   if {$getelems eq "0"} {

      #--   Tri sur la base du noradID
      set sortnorad [lsort -unique -index 2 $texte]

      #--   Tri alphabetique
      set texte [lsort -dictionary -index 0 $sortnorad]
      set ::audace(satel,satel_names) $texte ; #-- name+satfile+noradID

      #--   Extrait les noms
      set ::audace(satel,shortList) [::struct::list map $::audace(satel,satel_names) {extractIndex 0}]
   }

   #--   Retourne la liste des noms des satellites ou les donnees concernant un satellite
   return $texte
}

proc extractIndex {n list} {::lindex $list $n}
proc K {x y} {set x}


satel_server
return ""

