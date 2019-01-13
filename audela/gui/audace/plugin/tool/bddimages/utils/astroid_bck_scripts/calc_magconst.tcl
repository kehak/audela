proc calc_magconst { catalist } {

set magconst -1

  set magtycholist {}
  set magcadorlist {}

  foreach cata_source $catalist {

#       gren_info " cata_source = $cata_source"

    foreach cata $cata_source {

#       gren_info " cata = $cata"
       set namecata [lindex $cata 0]
#       gren_info " namecata = $namecata"
       if {$namecata == "common"} {
          set magtycho [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "mag"] ]
          lappend magtycholist $magtycho
          }
       if {$namecata == "cador_cata"} {
          set magcador [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "calib_mag"] ]
          lappend magcadorlist $magcador
          }
           
       }
    }

  set l [expr [llength $magtycholist] / 2.]
  if {$l > 2} {
     set j 1
     foreach i $magtycholist {
        if {$j>$l} {break}
        set j [expr $j + 1]
        }
     } else {
     set j 0
     }
  set medianetycho [lindex $magtycholist $j ]
  
  set l [expr [llength $magcadorlist] / 2.]
  if {$l > 2} {
     set j 1
     foreach i $magcadorlist {
        if {$j>$l} {break}
        set j [expr $j + 1]
        }
     } else {
     set j 0
     }
  set medianecador [lindex $magcadorlist $j ]

 gren_info " medianetycho = $medianetycho"
 gren_info " medianecador = $medianecador"

  set magconst [expr $medianetycho - $medianecador]
  return $magconst
  }
