proc correction_cador_list  { catalist magconst }  {

set result {} 

  foreach cata_source $catalist {

#       gren_info " cata_source = $cata_source"
    set row {}
    foreach cata $cata_source {
       set namecata [lindex $cata 0]
       if {$namecata == "cador_cata"} {
          set magcador [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "calib_mag"] ]
          set fields [lindex $cata 1] 
          set value  [lindex $cata 2] 
          set pos [lsearch [lindex $cata 1] "calib_mag"]
          set value  [lreplace $value $pos $pos [expr $magconst + $magcador]]
          lappend row [list $namecata $fields $value]
          } else {
          lappend row $cata
          }
           
       }
    
    lappend result $row
    }

return $result
}

