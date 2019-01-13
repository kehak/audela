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

   #
   # manage_source::set_common_fields
   # initialise les champ common de la liste
   # 
   #
   # listsources : liste en entree
   # catalog : ou il faut puiser l info
   # fieldlist : les champs a utiliser
   #
   proc ::manage_source::set_common_fields { listsources catalog fieldlist } {


      set cst 0
      foreach f $fieldlist {
         if {[string is double -strict $f]} {
            incr cst
         }
      }
      #gren_info "cst = $cst \n"

      set idlist ""
      set fields [lindex $listsources 0]
      foreach cata $fields {
         if { [lindex $cata 0]==$catalog } {
            set cols [lindex $cata 2]
            foreach f $fieldlist {
               #gren_info "f = $f \n"
               if {[string is double -strict $f]} {
                  #gren_info "double \n"
                  lappend idlist -1
               } else {
                  #gren_info "char \n"
                  set cpt 0
                  foreach col $cols {
                     if {$f==$col} {
                         lappend idlist $cpt
                     }
                     incr cpt
                  }
               }
            }
         }
      }

      #gren_info "idlist = $idlist \n"
      if {[llength $idlist]!=5} {
          gren_info "erreur nom des champs\n"
          return $listsources
      }

      set sources [lindex $listsources 1]
      set ids 0
      foreach s $sources {
         set sa($ids,catalog) ""
         foreach cata $s {
            lappend sa($ids,catalog) [lindex $cata 0]
            set sa($ids,[lindex $cata 0]) $cata
               if {$ids == -1 } {
                  gren_info "catalog = $sa($ids,[lindex $cata 0])\n"
               }
         }
      incr ids
      }
      set nbs $ids
      #gren_info "idlist = $idlist\n"
      #gren_info "nbs = $nbs\n"
      
      for {set ids 0} {$ids<$nbs} {incr ids} {
         if {[info exists sa($ids,$catalog)] } {
               set data [lindex $sa($ids,$catalog) 2]
               
               if {[string is double -strict [lindex $fieldlist 0]]} {
                  set ra [lindex $fieldlist 0]
               } else {
                  set ra [lindex $data [lindex $idlist 0]]
               }
               
               
               if {[string is double -strict [lindex $fieldlist 1]]} {
                  set dec [lindex $fieldlist 1]
               } else {
                  set dec [lindex $data [lindex $idlist 1]]
               }
               
               
               if {[string is double -strict [lindex $fieldlist 2]]} {
                  set poserr [lindex $fieldlist 2]
               } else {
                  set poserr [lindex $data [lindex $idlist 2]]
               }
               
               if {[string is double -strict [lindex $fieldlist 3]]} {
                  set mag [lindex $fieldlist 3]
               } else {
                  set mag [lindex $data [lindex $idlist 3]]
               }
               
               if {[string is double -strict [lindex $fieldlist 4]]} {
                  set magerr [lindex $fieldlist 4]
               } else {
                  set magerr [lindex $data [lindex $idlist 4]]
               }
               
               
               
               set com [list $ra \
                             $dec \
                             $poserr \
                             $mag \
                             $magerr \
                       ]
               set sa($ids,$catalog) [lreplace $sa($ids,$catalog) 1 1 $com]
               if {$ids == -1 } {
                  gren_info "sa $catalog = $sa($ids,$catalog)\n"
                  gren_info "catalog = $catalog\n"
                  gren_info "data = $data\n"
               
                  gren_info "com = $com\n"
               }
         }
      }

      set sources ""       
      for {set ids 0} {$ids<$nbs} {incr ids} {
         set s ""
         foreach cata $sa($ids,catalog) {
            lappend s $sa($ids,$cata)
         }
         lappend sources $s
      }

      #gren_info "fin\n"
      
      return  [list $fields $sources]

   }


# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/manage_source.tcl
# ::manage_source::set_common_fields $listsources IMG { id flag xpos ypos instr_mag }
# ::manage_source::imprim_3_sources $listsources
# set l [::manage_source::set_common_fields $listsources IMG { id flag xpos ypos instr_mag }]
# ::manage_source::imprim_3_sources $l


}
