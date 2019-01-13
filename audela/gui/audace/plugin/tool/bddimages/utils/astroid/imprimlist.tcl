

proc imprim_all_sources { listsources } {

    ::console::affiche_resultat "SOURCES = \n"
    set fields  [lindex $listsources 0]
    foreach s $fields { 
          ::console::affiche_resultat "$s\n"
          }
    set sources [lindex $listsources 1]
    foreach s $sources { 
          ::console::affiche_resultat "$s\n"
          }
   }

proc imprim_sources { listsources catalog } {

    set nb 0
    ::console::affiche_resultat "** SOURCES $catalog= \n"
    ::console::affiche_resultat "FIELDS = \n"
    set fields  [lindex $listsources 0]
    foreach s $fields { 
       ::console::affiche_resultat "$s\n"
       }
    ::console::affiche_resultat "VALUES = \n"
    set sources [lindex $listsources 1]
    foreach s $sources { 
       foreach cata $s {
          if { [lindex $cata 0]==$catalog } {
             ::console::affiche_resultat "$s\n"
             incr nb
             if {$nb>10} {
                return
                }
             }
          }
       }
    }
   
proc imprim_sources_vrac { listsources } {

   ::console::affiche_resultat "$listsources\n"
   }
