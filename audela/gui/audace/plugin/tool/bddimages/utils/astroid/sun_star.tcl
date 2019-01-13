
package require xml
package require dom
package require http

#
# catalog : I/289/out for UCAC2
# catalog : I/315/out for UCAC3
# catalog : I/239/hip_main for HIPPARCOS
# ra : 
# dec : signe obligatoire
# r : rayon
proc vo_cds_query { catalogname ra dec r } {

if {$catalogname == "UCAC3"}  then { set catalog "I/315/out" }
if {$catalogname == "UCAC2"}  then { set catalog "I/289/out" }
if {$catalogname == "UCAC2A"} then { set catalog "I/294A/ucac2bss" }
if {$catalogname == "HIP"}    then { set catalog "I/239/hip_main" }
if {$catalogname == "2MASS"}  then { set catalog "II/246/out" }
if {$catalogname == "TYCHO"}  then { set catalog "I/239/tyc_main" }


#http://vizier.u-strasbg.fr/viz-bin/votable?-out.max=10000&-c=0+%2B0&-c.eq=J2000&-oc.form=dec&-c.r=+10&-c.u=arcmin&-c.geom=r&-source=I%2F289%2Fout&-out.all=1

set url "http://vizier.u-strasbg.fr/viz-bin/votable"
set catalog [::http::formatQuery $catalog ]
set ra [::http::formatQuery $ra]
set dec [::http::formatQuery $dec]
set r [::http::formatQuery $r]
set query "-out.max=10000&-c=$ra+$dec&-c.eq=J2000&-oc.form=dec&-c.r=+$r&-c.u=arcmin&-c.geom=r&-source=$catalog%2Fout&-out.all=1"

#gren_info " query = $url?$query"

set token [ ::http::geturl $url -query $query ]
set votable [::dom::parse [::http::data $token]]
set fields {}
foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::name}] {
   lappend fields "[::dom::node stringValue $n]"
   }

#set idmagbmv [lsearch $fields "B-V"]

set rows {}
foreach tr [::dom::selectNode $votable {descendant::TR}] {
   set row {}
   foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
      lappend row [::dom::node stringValue $td]
      }
#      set magbnv [lindex $row $idmagbmv]
#   if {$magbnv > 0.5 && $magbnv < 0.9}  then {
#      gren_info " B-V = [lindex $row $idmagbmv]"
      lappend rows [list [list $catalogname $fields $row] ]
#      }
#   lappend rows [list $catalogname $fields $row]
   }

return $rows
}





proc extract_sun_star { starlist } {
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
