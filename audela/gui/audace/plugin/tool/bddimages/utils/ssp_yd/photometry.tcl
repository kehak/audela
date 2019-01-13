proc add_sun_star { catalog listsources } {


   if { $catalog == "TYCHO2" } {
      set fields  [lindex $listsources 0]
      #gren_info "fields =  $fields \n"
      set fieldstmp  [lindex [lindex $fields 0] 2]
      #gren_info "fieldstmp =  $fieldstmp \n"
      set idmagb [lsearch $fieldstmp "BTmag"]
      set idmagv [lsearch $fieldstmp "VTmag"]
      #gren_info "idmagbmv =  $idmagbmv \n"
      set sources [lindex $listsources 1]
      set sourcespss {}
      foreach s $sources { 
         #gren_info "s =  $s \n"
         foreach cata $s {
            #gren_info "cata =  $cata \n"
            if { [lindex $cata 0]==$catalog } {
               set cm [lindex $cata 1]
               set ct [lindex $cata 2]
               #gren_info "ct =  $ct \n"
               set magbnv [expr [lindex $ct $idmagb] - [lindex $ct $idmagv]]
               #gren_info "magbnv =  $magbnv \n"
               if {$magbnv > 0.5 && $magbnv < 0.9} {
                  #gren_info "*** SOLAIRE *** \n"
                  lappend s [list "SUNLIKE" $cm]
                  }
               }
            }
         lappend sourcespss $s
         }
      }
   lappend fields [list "SUNLIKE" {ra dec poserr mag magerr}]
   set sourcespss [list $fields $sourcespss]
   #::console::affiche_resultat "sourcespss= $sourcespss\n"

   return $sourcespss
   }

proc extractold { listsources } {
set commonfields [list ra dec poserr mag magerr]
set rows {}
foreach star $starlist {
   set insert "no"
   foreach cata $star {
      set fields   [lindex $cata 1]
      set idmagbmv [lsearch $fields "B-V"]
      set magbnv   [lindex [lindex $cata 2] $idmagbmv]
      if {$magbnv > 0.5 && $magbnv < 0.9}  then {
         #gren_info " B-V = $magbnv"         
         set insert "yes"
         set ra      [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "RAhms"] ]
         set ra      [mc_angle2deg $ra]
         set ra      [expr $ra * 15.0]
         set dec     [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "DEdms"] ]
         set dec     [mc_angle2deg $dec]
         set e_RAdeg [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "e_RAdeg"] ]
         set e_DEdeg [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "e_DEdeg"] ]
         set mag     [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "Vmag"] ]
         set magerr  0.3
         #gren_info " field = [lindex $cata 1] "
         #gren_info " value = [lindex $cata 2] "
         #gren_info " tag =$ra $dec $e_RAdeg $e_DEdeg $mag $magerr"
         set poserr  0.3
         #gren_info " tag =$ra $dec $poserr $mag $magerr"
         }
      }
   if {$insert == "yes"} {
      lappend star [list "common" $commonfields [list $ra $dec $poserr $mag $magerr] ]
      lappend rows $star 
      }
   }
#gren_info "rows = $rows"
return $rows
}
