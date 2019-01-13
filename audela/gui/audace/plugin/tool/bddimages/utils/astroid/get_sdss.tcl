# -- Procedure 
proc get_sdss { args } {

   global sdss_list

   # Lecture arguments
   set argc [llength $args]
   if {$argc >= 3} {
      set url    "http://skyserver.sdss.org/dr9/en/tools/search/x_radial.asp"
      set ra     [lindex $args 0]
      set dec    [lindex $args 1]
      set radius [lindex $args 2]
      set topnum 10000
      set maglimit_min 0
      set maglimit_max 20
      if {$argc >= 4} {
         for {set k 3} {$k<$argc} {incr k} {
            set key [lindex $args $k]
            if {$key == "-topnum"} {
               set topnum [lindex $args [expr $k+1]]
            }
            if {$key == "-mag_limit_min"} {
               set maglimit_min [lindex $args [expr $k+1]]
            }
            if {$key == "-mag_limit_max"} {
               set maglimit_max [lindex $args [expr $k+1]]
            }
         }
      }
   } else {
      set line "Usage: \n"
      append line "get_sdss ra dec radius ?-topnum n? ?-mag_limit_min mag? ?-mag_limit_max mag?\n"
      append line "# Parametres :\n"
      append line "#   ra                : RA du centre du FOV\n"
      append line "#   dec               : DEC du centre du FOV\n"
      append line "#   radius            : Rayon de recherche en arcmin\n"
      append line "# Parametres optionels :\n"
      append line "#   -topnum 10000     : Nombre d'etoiles maximum\n"
      append line "#   -mag_limit_min 0  : Magnitude minimum dans tous les filtres (GRIZ)\n"
      append line "#   -mag_limit_max 20 : Magnitude maximum dans tous les filtres (GRIZ)\n"
      error $line
      return -code 1
   }

   set no_answer 0
   set sdss_answered 0

   set query "${url}?ra=${ra}&dec=${dec}&radius=${radius}&min_u=${maglimit_min}&max_u=${maglimit_max}&min_g=${maglimit_min}&max_g=${maglimit_max}&min_r=${maglimit_min}&max_r=${maglimit_max}&min_i=${maglimit_min}&max_i=${maglimit_max}&min_z=${maglimit_min}&max_z=${maglimit_max}&entries=top&topnum=${topnum}&format=csv"

   gren_debug "  SDSS-CONESEARCH: $ra $dec $radius \n"
   gren_debug "           query = $query\n"

   while {$sdss_answered == 0} {
      set err [catch {::http::geturl $query} token]
      if {$err} {
         gren_info "get_sdss: ERREUR 7\n"
         gren_info "get_sdss:    NUM : <$err>\n" 
         gren_info "get_sdss:    MSG : [::http::data $token]\n"
         incr no_answer
         if {$no_answer > 10} {
            break
         }
      } else {
         set sdss_answered 1
      }
   }

   if {[::http::data $token] == "No objects have been found"} {
      return -1
   }

   set sdss_result {}
   set sdss_error 0
   foreach r [::http::data $token] {
      if {$r == "ERROR"} { set sdss_error 1 }
      lappend sdss_result $r
   }

   if {$sdss_error == 1} {
      gren_erreur "SDSS: $sdss_result\n"
      return -1
   }

   set sdss_fields [split [lindex $sdss_result 0] ","]
   set common_fields [list ra dec poserr rmag rmagerr]
   set fields [list [list "SDSS" $common_fields $sdss_fields] ] 

   set cpt 0
   set sdss_val [lrange $sdss_result 1 end]
   foreach s $sdss_val {
      set row {}
      set val [split $s ","]

      # Data pour le champ common
      set ra [lindex $val 7]
      set dec [lindex $val 8]
      set poserr 0.5
      set rmag [lindex $val 11]
      set rmagerr [lindex $val 16]
      set common [list $ra $dec $poserr $rmag $rmagerr]

      set row [list [list "SDSS" $common $val]]
      lappend sdss_list $row
      incr cpt
   }

   set sdss_cata [list $fields $sdss_list]

   if {$cpt == 0} {
      return -1
   } else {
      return $sdss_cata
   }

}
