# -- Procedure
# Test: http://archive.stsci.edu/panstarrs/search.php?RA=117.194686&DEC=13.65451&SR=0.1&max_records=10
# get_panstarrs 117.194686 13.65451 1 -topnum 10
#set err [catch {get_panstarrs 117.194686 13.65451 1 -topnum 5} panstarrs]
#set panstarrs [::manage_source::set_common_fields $panstarrs PANSTARRS { gmeanapmag gmeanapmagerr } ]
#
# http://archive.stsci.edu/panstarrs/search.php?action=Search&RA=117.194686&DEC=13.65451&radius=3&max_records=10&outputformat=CSV
#

proc get_panstarrs { args } {

   global panstarrs_list

   # Rayon de recherche par defaut, en degres
   set LIMIT_RADIUS 0.5

   # Lecture arguments
   set argc [llength $args]
   if {$argc >= 3} {
      set url "http://archive.stsci.edu/panstarrs/search.php?"
      #set url "http://archive.stsci.edu/panstarrs/search.php?action=Search&outputformat=csv&"
      set ra [lindex $args 0]
      set dec [lindex $args 1]
      set radius [expr [lindex $args 2]/60.0]
      if {$radius > $LIMIT_RADIUS} {
         set radius $LIMIT_RADIUS
         gren_erreur "PANSTARRS: rayon maximum de recherche depasse -> valeur de radius ramenee a $radius deg\n"
      }
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
      append line "get_panstarrs ra dec radius ?-topnum n? ?-mag_limit_min mag? ?-mag_limit_max mag?\n"
      append line "# Parametres :\n"
      append line "#   ra       : RA du centre du FOV\n"
      append line "#   dec      : DEC du centre du FOV\n"
      append line "#   radius   : Rayon de recherche en arcmin\n"
      append line "# Parametres optionels :\n"
      append line "#   -topnum  : Nombre d'etoiles maximum (defaut = 10000)\n"
      append line "#   -mag_limit_min 0  : Magnitude minimum dans tous les filtres (GRIZY)\n"
      append line "#   -mag_limit_max 20 : Magnitude maximum dans tous les filtres (GRIZY)\n"
      error $line
      return -code 1
   }

   set no_answer 0
   set panstarrs_answered 0

   set query "${url}RA=${ra}&DEC=${dec}&SR=${radius}&max_records=${topnum}"

   gren_debug "  PANSTARRS-CONESEARCH: $ra $dec $radius \n"
   gren_debug "     query = $query\n"

   while {$panstarrs_answered == 0} {
      set err [catch {::http::geturl $query} token]
      if {$err} {
         gren_info "get_panstarrs: ERREUR 7\n"
         gren_info "get_panstarrs:    NUM : <$err>\n" 
         gren_info "get_panstarrs:    MSG : [::http::data $token]\n"
         incr no_answer
         if {$no_answer > 10} {
            break
         }
      } else {
         set panstarrs_answered 1
      }
   }

   set result [::http::data $token]
   set err [ catch { ::dom::parse $result } votable ]
   if { $err } {
      gren_erreur "  => Erreur d'analyse de la votable Panstarrs: $result\n"
   }

   # Verification du status de la reponse
   set status [::dom::node stringValue [::dom::selectNode $votable {descendant::INFO/attribute::name}]]
   if {[string tolower $status] == "error"} {
      set msg [::dom::node stringValue [::dom::selectNode $votable {descendant::INFO/attribute::value}]]
      gren_erreur "PANSTARRS: $msg\n"
      return -1
   }

   # -- Parse the votable and extract the data
   set panstarrs_fields {}
   foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::ID}] {
      lappend panstarrs_fields "[::dom::node stringValue $n]"
   }
   set voconf(fields) $panstarrs_fields

   set panstarrs_list {}
   set common_fields [list ra dec poserr mag magerr]
   set fields [list [list "PANSTARRS" $common_fields $panstarrs_fields] ] 

   set cpt 0
   foreach tr [::dom::selectNode $votable {descendant::TR}] {
      set row {}
      foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
        lappend row [::dom::node stringValue $td]
      }
      # Data pour le champ common
      set sra [lindex $row 2]
      set sdec [lindex $row 3]
      set serrpos [expr ([lindex $row 4] + [lindex $row 5])/2.0 ]
      set sgmag [lindex $row 28]
      set sgmagerr [lindex $row 29]
      if {$sgmag >= $maglimit_min && $sgmag <= $maglimit_max} {
         set common [list $sra $sdec $serrpos $sgmag $sgmagerr]
         set row [list [list "PANSTARRS" $common $row ] ]
         lappend panstarrs_list $row
         incr cpt
      }
   }

   set panstarrs_cata [list $fields $panstarrs_list]

   ::dom::destroy $votable

   if {$cpt == 0} {
      return -1
   } else {
      return $panstarrs_cata
   }

}
