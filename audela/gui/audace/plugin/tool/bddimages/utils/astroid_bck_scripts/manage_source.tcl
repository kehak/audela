#--------------------------------------------------
# source audace/plugin/tool/av4l/manage_source.tcl
#--------------------------------------------------
#
# Fichier        : manage_source.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id: manage_source.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::manage_source {



   #
   # manage_source::get_nb_sources
   # Fournit le nombre de source
   #
   proc ::manage_source::get_nb_sources { listsources } {

       set sources [lindex $listsources 1]
       set cpt 0
       foreach s $sources { 
             incr cpt
             }
   return $cpt
   }


   #
   # manage_source::get_nb_sources
   # Fournit le nombre de source
   #
   proc ::manage_source::get_nb_sources_by_cata { listsources catalog } {

       set sources [lindex $listsources 1]
       set cpt 0
       foreach s $sources { 
          foreach cata $s {
             if { [lindex $cata 0]==$catalog } {
                incr cpt
             }
          }
       }
   return $cpt
   }

   #
   # manage_source::get_nb_sources
   # Fournit le nombre de source
   #
   proc ::manage_source::get_nb_sources_rollup { listsources } {

       set sources [lindex $listsources 1]
       set cpt 0
       foreach s $sources { 
          incr cpt
          foreach cata $s {
             set namecata  [lindex $cata 0]
             if { [info exists nbcata($namecata)] } {
                incr nbcata($namecata)
             } else {
                set nbcata($namecata) 1
             }
          }
       }
       set result [array get nbcata]
       lappend  result "TOTAL" $cpt
       return $result
   }



   #
   # manage_source::get_cata_from_sources
   # Fournit le nombre de source
   #
   proc ::manage_source::get_cata_from_sources { listsources } {

       set catalist {}
       set fields  [lindex $listsources 0]
       foreach s $fields { 
          lappend catalist [lindex $s 0]
       }
   return $catalist
   }

   #
   # manage_source::get_fields_from_sources
   # Fournit le nombre de source
   #
   proc ::manage_source::get_fields_from_sources { listsources } {

   return [lindex $listsources 0]
   }


   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::extract_sources_by_catalog { listsources cata } {

       set fields  [lindex $listsources 0]
       foreach s $fields { 
             ::console::affiche_resultat "$s\n"
             }
       set newsources {}
       set sources [lindex $listsources 1]
       foreach s $sources { 
          ::console::affiche_resultat "$s\n"
          if {[lindex $s 0] == $cata} {
             lappend newsources $s
          }
       }
   return [list $fields $newsources]
   }



   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_all_sources { listsources } {

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

   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_3_sources { listsources } {

      set nb 0
      set fields  [lindex $listsources 0]
      foreach s $fields { 
         ::console::affiche_resultat "$s\n"
         }
      set sources [lindex $listsources 1]
      foreach s $sources { 
         ::console::affiche_resultat "$s\n"
         incr nb
         if {$nb>3} {
            return
         }
      }
   }

   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_sources { listsources catalog } {

       set nb 0
       ::console::affiche_resultat "SOURCES $catalog = \n"
       set fields  [lindex $listsources 0]
       foreach s $fields { 
          ::console::affiche_resultat "$s\n"
          }
       set sources [lindex $listsources 1]
       foreach s $sources { 
          foreach cata $s {
             if { [lindex $cata 0]==$catalog } {
                ::console::affiche_resultat "$s\n"
             }
          }
       }
   }
   
   #
   # manage_source::extract_sources_by_catalog
   # Fournit le nombre de source
   #
   proc ::manage_source::imprim_sources_vrac { listsources } {

      ::console::affiche_resultat "$listsources\n"
   }


}
