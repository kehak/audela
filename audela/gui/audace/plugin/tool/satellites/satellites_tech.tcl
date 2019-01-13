#
## @file satellites_tech.tcl
#  @brief Procédures techniques pour les orbites de satellites artificiels
#  @author Raymond Zachantke
#  $Id: satellites_tech.tcl 13252 2016-02-21 22:54:55Z rzachantke $
#

#------------------------------------------------------------
#  @brief  lance mc_tle2ephem dans satel.tcl
#  @detail appelée par ::satellites::satelInfos et par ::satellites::getSatCoord
#  @param  datejd date JD
#  @return résultat de mc_tle2ephem
#  @detail  le résultat est une liste commme :
#  {{ISS (ZARYA)} {25544U} {98067A}} 295.314971775334870 3.606638078375271 8445039.44621498 111.607298702035050 68.396245471492549 1.0000 {GPS 174.758315 W 51.729348 409206.339635} 177.858508952084240 -37.646193636973962 1.416361350870819 178.301085427573810
# - l'élément d'index 0 commporte, avec des espaces à supprimer, le nom du satellite, l'ID Norad et un ID de classification
#  puis suivent :
# - l'AD en deg
# - DEC en deg
# - la distance au centre de la Terre en m
# - l'elongation par rapport au Soleil en deg
# - la phase en deg
# - l'illumination
# - les coordonnées GPS du satellite
# - l'azimuth
# - la hauteur
# - puis 2 paramètres ???? (CF satel_nearest_radec)
#
proc ::satellites::satel_ephem2 { datejd } {
   variable private

   #::console::disp "mc_tle2ephem $datejd \"$private(tlefile)\" \"$private(gps)\" -name \"$private(satname)\" -sgp 4\n"
   set res [mc_tle2ephem $datejd $private(tlefile) $private(gps) -name $private(satname) -sgp 4]
   set result [lindex $res 0]
   #::console::disp "satel_ephem2 result $result\n"
   return $result
}

#------------------------------------------------------------
#  brief   calcule les coordonnées corrigées
#  detail  processus presque identique a celui de astrocomputer
#  param   raDeg ascension droite en degrés
#  param   decDeg déclinaison en degrés
#  param   date date TU
#  param   gpsObs coordonnées GPS
#  return  coordonnées corrigées et formatées, si pas d'erreur dans hip2tel
#
proc ::satellites::getApparentCoords { raDeg decDeg date gpsObs } {

   set mura 0
   set mudec 0
   set plx 0
   set equinox J2000.0
   set epoch $equinox

   #--   calcule les coordonnees apparentes
   set hip [list 1 0 $raDeg $decDeg 90 $equinox $epoch $mura $mudec $plx]
   set result [mc_hip2tel $hip $date $gpsObs $::audace(meteo,obs,pressure) [ expr $::audace(meteo,obs,temperature) + 273.15 ] -humidity $::audace(meteo,obs,humidity)]

   if {[regexp -all {[(-1\./IND)|(1\.QNAN)].+} $result] eq "0"} {
      lassign $result ra dec ha az elev
   } else {
      #--   en cas d'erreur de hip2tel, renvoie les coordonnes non corrigees
      set ra $raDeg ; set dec $decDeg
      lassign [mc_radec2altaz $ra $dec $gpsObs $date] az elev ha
   }

   set ra [mc_angle2hms $ra 360 zero 0 auto string]
   set dec [mc_angle2dms $dec 90 zero 0 + string]
   set ha [mc_angle2hms $ha 360 zero 0 auto string]
   set az [format "%0.5f" $az]
   set elev [format "%0.5f" $elev]

   return [list $ra $dec $ha $az $elev]
}

#------------------------------------------------------------
#  brief    classe les orbites par type
#  param    revperday (révolution par jour)
#  param    distkm (distance en km)
#  param    inclindeg (inclinaison en degrés)
#  return   type d'orbite (basse, moyenne, lointaine, géostationnaire)
#
proc ::satellites::getOrbitType { revperday distkm inclindeg } {
      global caption

   set type "?"
   if {$distkm < 800} {
      set type "LEO basse"       ; #--   low earth orbit
   } elseif {$distkm >=800 && $distkm < 30000} {
      set type "MEO moyenne"     ; #--   mid earth orbit
   } elseif {$distkm > 35780} {
      set type "DSO lointaine"   ; #--   deep space orbit
   }

   if {$revperday > 0.9 && $revperday < 1.1} {
      set orbtype2 "$caption(satellites,geostat)"
   } else {
      if {$inclindeg > 0 && $inclindeg < 90} {
         set orbtype2 "$caption(satellites,retrograde)"
      } elseif {$inclindeg >= 90 && $inclindeg < 180} {
         set orbtype2 "$caption(satellites,direct)"
      }
   }

   return [list $type $orbtype2]
}

#------------------------------------------------------------
#  brief   calcul approché du périgée et de l'apogée
#  detail selon http://www.satobs.org/seesat/Dec-2002/0197.html
#  param   revperday révolutions par jour
#  param   eccentricity excentricité
#  return  liste du périgée et de l'apogée en km
#
proc ::satellites::computeApoPerigee { revperday eccentricity } {

   set earthRadius 6371                ; #-- km
   set a [expr { 8681663.653/$revperday }]
   set coef [expr { 2./3 }]
   set sma [expr { pow($a,$coef) }]    ; #-- semi-major axis, km
   set eccent "0."
   append eccent $eccentricity
   set perigee [expr { round($sma*(1.-$eccent)-$earthRadius) }]
   set apogee [expr { round($sma*(1.+$eccent)-$earthRadius) }]

   return [list $perigee $apogee]
}

#------------------------------------------------------------
#  brief   calcule la magnitude du satellite
#  detail   adaptée de ::astrocomputer::astrocomputer_coord_satel_mag
#  param    norad
#  param    fracill
#  param    distkm
#  param    phasedeg
#  return   magnitude
#  detail La magnitude standard m0 est définie pour une distance de 1000 km et une illumination de 50%.
#  La formule suivante donne la magnitude visuelle connaissant la distance d et l'illumination I :
#  m = m0 - 15.75 + 2.5 log10 (d2 / I)
#  La lettre qui suit la magnitude standard est soit d,
#  la magnitude est calculée selon les dimensions du satellite,
#  soit v, la magnitude est déterminée visuellement.
#  25544  30.0 20.0  0.0 -0.5 v 404.00
#
proc ::satellites::computeMag { norad fracill distkm phasedeg } {
   variable private

   set mag "-"
   if {$fracill != 0} {
      if {[info exists private(norad,mags)] == 0} {
         set fname "[file join $::audace(rep_catalogues) satel_magnitudes.txt]"
         if {[file exists $fname] == 1} {
            set private(norad,mags) [split [K [read [set fi [open $fname]]] [close $fi]] "\n"]
            regsub -all {\{\}} $private(norad,mags) "" private(norad,mags)
         }
      }
      if {$private(norad,mags) ne ""} {
         foreach noradmags $private(norad,mags) {
            set noradid [lindex $noradmags 0]
            if {$noradid==$norad} {
               set m0 [lindex $noradmags 4]
               set d [expr $distkm/1000.]
               set i [expr $fracill*0.5*(1+cos($phasedeg*3.1416/180.))]
               #::console::affiche_resultat "MAG = expr $m0 - 2.5 * log10 (1. / 0.5) + 2.5 * log10 ($d*$d / $fracill)\n"
               set mag [expr $m0 - 2.5 * log10 (1. / 0.5) + 2.5 * log10 ($d*$d / $fracill)]
               set mag [format "%.2f" $mag]
               break
            }
         }
      }
   }

   return $mag
}

#------------------------------------------------------------
#  brief    calcule la vitesse de déplacement angulaire
#  detail   fonction appelée par satelInfos ;
#           adaptée de la proc satel_scene dans satel.tcl
#  param    date date TU
#  return   speed vitesse en degrés/sec
#
proc ::satellites::computeSpeed { date } {

   set dt 5.
   set date1 [mc_date2jd $date]
   set error [catch {
      lassign [satel_ephem2 $date1] -> ra1 dec1
      set date2 [mc_datescomp $date1 + [expr $dt/86400.]]
      lassign [satel_ephem2 $date2] -> ra2 dec2
      set sepangle [lindex [mc_sepangle $ra1 $dec1 $ra2 $dec2] 0]
      set speed [format "%0.5f" [expr { $sepangle/$dt }]]
   } msg]
   if {$error == 1} {
      ::console::affiche_erreur "$msg\n"
      set speed "-"
   }

   return $speed
}

#------------------------------------------------------------
#  brief    calcule le temps synodique du satellite
#  detail   invoque la proc ::satel_names2 dans satel.tcl
#           extrait des valeurs de la ligne N°2 du fichier TLE
#           utilisable pour identifier l'inclinaison, etc.
#           adaptée de satel_transit dans satel.tcl
#  param    selectedSat nom du satellite
#  return   principaux paramètres de la ligne 2 + temps synodique
#
proc ::satellites::computeTsyn { selectedSat } {

   set res ""
   lassign [lindex [satel_names2 "$selectedSat" 1000 1] 0] satName file line1 line2
   if {$line2 ne ""} {
      lassign [lrange $line2 2 end] inclinaison AD excentricite perigee anomaly revperday
      set daymin 1436.
      set tsat [expr $daymin/$revperday]
      if {$inclinaison < 90 } {
         set sign -1
      } else {
         set sign 1
      }
      set tsyn [expr { 1./(1./$tsat+1.*$sign/$daymin)/1440. }]
      #--   Rajoute tsyn
      set res [list $inclinaison $AD $excentricite $perigee $anomaly $revperday $tsyn]
   }

   #::console::disp "\ncomputeTsyn $selectedSat $satName\n$res\n"
   return $res
}

#------------------------------------------------------------
#  brief   recherche le nom du fichier TLE associé au satellite sélectionné
#  remark  proc activée par la combobox de sélection du satellite
#  details vérifie aussi l'ancienneté de la mise à jour du fichier
#
proc ::satellites::getTleFile { } {
   variable private
   global audace caption

   set res [lsearch -inline -index 0 $::audace(satel,satel_names) ${private(satname)}*]
   if {$res ne ""} {
      lassign $res satname satfile noradID
      set private(tlefile) [file join $::audace(rep_userCatalogTle) $satfile]
      set datfile [file mtime $private(tlefile)]
      set dt [expr ([clock seconds]-$datfile)/86400.]
      if {$dt >= 30} {
         ::console::affiche_erreur "[format $caption(satellites,update) \"$satfile\"]\n"
      }
   } else {
      ::console::affiche_erreur "[format $caption(satellites,pas_trouve) \"$private(satname)\"]\n"
   }
}

#------------------------------------------------------------
#  brief calcule les info concernant le satellite
#
proc ::satellites::getSatelInfos { } {
   variable private

   set gpsObs $private(gps)
   set date $private(tu)
   set selectedSat $private(satname)

   set error [catch { set res [::satellites::satel_ephem2 [mc_date2jd $private(tu)]]} msg]

   if {$error eq "0"} {

      lassign $res id raDeg decDeg distm elongDeg phaseDeg fracill sitezenith
      lassign $id satelName noradID

      #--   Distance au centre de la Terre
      set distkm [expr { $distm*1e-3 }]

      #--   Formate l'altitude des coordonnees gps du satellite
      set altitude [expr { int([lindex $sitezenith 4])}]
      set gpsSat [lreplace $sitezenith 4 4 $altitude]

      #--   Calcule la magnitude
      regsub "U" [string trim $noradID] "" norad
      set mag [::satellites::computeMag $norad $fracill $distkm $phaseDeg]

      #--   Calcule la vitesse de deplacement en deg/sec
      set speed [::satellites::computeSpeed $date]

      #--   Extrait des variables du fichier tle
      lassign [::satellites::computeTsyn $selectedSat] inclinaisonDeg AD eccentricity perigdeg anomaly private(revperday) private(tsyn)

      #--   Classifie l'orbite
      lassign [::satellites::getOrbitType $private(revperday) $distkm $inclinaisonDeg] orbitype1 orbitype2

      #--   Calcule le perigee et l'apogee
      lassign [::satellites::computeApoPerigee $private(revperday) $eccentricity] perigee apogee

      #--   Calcule les coordonnees apparentes
      lassign [::satellites::getApparentCoords $raDeg $decDeg $date $gpsObs] ra dec ha az elev

      set elongDeg [format "%.2f" $elongDeg]
      set distkm [format "%.2f" $distkm]
      set inclinDeg [format "%0.4f" $inclinaisonDeg]
      set rasat [mc_angle2hms $raDeg 360 zero 0 auto string]
      set decsat [mc_angle2dms $decDeg 90 zero 0 + string]

      set private(result) [list [mc_date2iso8601 $date] $satelName [lindex $orbitype1 1] $orbitype2 \
         $fracill $mag $elongDeg $inclinDeg $private(revperday) "$perigee x $apogee" \
         $private(tsyn) $speed "$gpsSat" $rasat $decsat $ra $dec $ha $az $elev]
   } else {
      ::console::affiche_erreur "[format $::caption(satellites,erreur) \"$selectedSat\" $msg]\n"
   }
}

#------------------------------------------------------------
#  brief édite les info dans la console (option "Console")
#
proc ::satellites::writeConsole {} {
   variable private
   global caption

   lassign $private(result) date satelName orbtype1 orbtype2 fracill mag \
      elongDeg inclinDeg revperday periapogee tsyn speed gpsSat \
      rasat decsat raapp decapp ha az elev

   ::console::disp  "\n\
      $caption(satellites,satellite) : $satelName\n\
      $caption(satellites,onglet_orbit) : $orbtype2\n\
      $caption(satellites,inclin) : $inclinDeg deg.\n\
      $caption(satellites,periapo) : $periapogee km\n\
      $caption(satellites,revperday) : $revperday\n\
      $caption(satellites,tsyn) : $tsyn\n\
      ------------------------------------------------\n\
      $caption(satellites,date) : $date\n\
      $caption(satellites,zenpos) : $gpsSat\n\
      $caption(satellites,elong) : $elongDeg deg.\n\
      $caption(satellites,ill) : $fracill\n\
      $caption(satellites,mag) : $mag\n\
      ------------------------------------------------\n\
      $caption(satellites,ra) J2000.0 : $rasat\n\
      $caption(satellites,dec) J2000.0 : $decsat\n\
      $caption(satellites,ra) : $raapp\n\
      $caption(satellites,dec) : $decapp\n\
      $caption(satellites,ha) : $ha\n\
      $caption(satellites,az) : $az deg.\n\
      $caption(satellites,elev) : $elev deg.\n\
      $caption(satellites,speed) : $speed deg/sec.\n\n"
}