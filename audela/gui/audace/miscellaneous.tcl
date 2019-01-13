#
## @file miscellaneous.tcl
#  @brief Procédures diverses
#  @author Alain KLOTZ
#  $Id: miscellaneous.tcl 13428 2016-03-19 14:11:01Z rzachantke $

#------------------------------------------------------------
## @brief écrit une liste tcl dans un fichier
#  @param tcllist une liste au format tcl
#  @param filename nom complet du fichier
#  @param attribut w pour l'écriture du fichier
#  @warning Il est préférable de ne pas donner l'atttribut
#
proc list2file { tcllist filename {attribut w} } {
   set f [open $filename $attribut]
   foreach ligne $tcllist {
      puts $f "$ligne"
   }
   close $f
}

#------------------------------------------------------------
## @brief calcule airmass sur une série d'images
#  @code
#  airmass2 in number ?first_index? ?ra dec? ?Home?"
#  @endcode
#  @param args liste d'arguments
#  @return liste des valeurs
#
proc airmass2 {args} {
   if {[llength $args] <2} {
      error "Usage: airmass2 in number ?first_index? ?ra dec? ?Home?"
   }
   set arg2s [lrange $args 3 5]
   set in [lindex $args 0]
   set nb [lindex $args 1]
   if {[llength $args] >= 3} {
      set first_index [lindex $args 2]
   } else {
      set first_index 1
   }
   #::console::affiche_resultat "$in $nb $first_index => $arg2s\n"
   set kfin [expr $first_index+$nb]
   for {set k $first_index} {$k<$kfin} { incr k } {
      loadima ${in}${k}
      set texte "airmass [split $arg2s]"
      set airmass [eval $texte]
      lappend airmasses $airmass
   }
   return $airmasses
}


#------------------------------------------------------------
## @brief calcule airmass
#  @param args liste de longueur variable d'arguments (ra dec home date)
#  @pre si la liste ne contient pas tous les arguments,
#  le script lit les mots clés dans l'en-tête de l'image dans le buffer
#  par défaut home=$audace(posobs,observateur,gps)
#  par défaut la date est calculée par rapport à la date d'exposition
#  @return liste de la date, de la valeur du paramètre airmass et élévation
#
proc airmass {args} {
   global audace

   if {[llength $args] >= 1} {
      set ra [lindex $args 0]
   } else {
      set ra [lindex [buf$::audace(bufNo) getkwd RA] 1]
      if {$ra==""} {
         error "Error: RA keyword not found. Usage: airmass ?ra dec? ?Home? ?Date?"
      }
   }
   if {[llength $args] >= 2} {
      set dec [lindex $args 1]
   } else {
      set dec [lindex [buf$::audace(bufNo) getkwd DEC] 1]
      if {$dec==""} {
         error "Error: DEC keyword not found. Usage: airmass ?ra dec? ?Home? ?Date?"
      }
   }
   if {[llength $args] >= 3} {
      set home [lindex $args 2]
   } else {
      set obs_elev [lindex [buf$::audace(bufNo) getkwd OBS-ELEV] 1]
      if {$obs_elev==""} {
         set obs_elev 0
      }
      set obs_lat  [lindex [buf$::audace(bufNo) getkwd OBS-LAT] 1]
      set obs_long [lindex [buf$::audace(bufNo) getkwd OBS-LONG] 1]
      if {($obs_lat=="")||($obs_long=="")} {
         set home $audace(posobs,observateur,gps)
      } else {
         if {$obs_long<0} {
            set obs_long [expr -1*$obs_long]
            set sens W
         } elseif {$obs_long>180} {
            set obs_long [expr 360.-$obs_long]
            set sens W
         } else {
            set sens E
         }
         set home [list GPS $obs_long $sens $obs_lat $obs_elev]
      }
   }
   if {[llength $args] >= 4} {
      set date [lindex $args 3]
   } else {
      set date [lindex [buf$::audace(bufNo) getkwd DATE-OBS] 1]
      if {$date==""} {
         error "Error: DATE-OBS keyword not found"
      }
      set exposure [lindex [buf$::audace(bufNo) getkwd EXPOSURE] 1]
      if {$exposure==""} {
         set exposure 0
      }
      set date [mc_datescomp $date + [expr 0.5*$exposure/86400]]
   }
   ::console::affiche_resultat "mc_radec2altaz $ra $dec $home [mc_date2iso8601 $date]\n"
   set altaz [mc_radec2altaz $ra $dec $home $date]
   set elevation [lindex $altaz 1]
   set elevrad [expr $elevation*4*atan(1)/180.]
   if {$elevation<=0} {
      set airmass 99999999
   } else {
      set airmass [expr 1./sin($elevrad)]
   }
   set response "$date $airmass $elevation"
   return $response
}

