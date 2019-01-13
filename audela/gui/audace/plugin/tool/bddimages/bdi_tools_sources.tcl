## @file bdi_tools_sources.tcl
#  @brief     Outils de manipulation des sources dans bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_sources.tcl]
#  @endcode

# $Id: bdi_tools_sources.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_sources
# @brief Outils de manipulation des sources dans bddimages
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_sources {

}


#
# tools_sources::get_nb_sources
# Fournit le nombre de source
#
proc ::bdi_tools_sources::get_nb_sources { listsources } {

   set sources [lindex $listsources 1]
   set cpt 0
   foreach s $sources { 
      incr cpt
   }
   return $cpt

}


#
# tools_sources::get_nb_sources
# Fournit le nombre de source
#
proc ::bdi_tools_sources::get_nb_sources_by_cata { listsources catalog } {

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
# tools_sources::get_nb_sources
# Fournit le nombre de source
#
proc ::bdi_tools_sources::get_nb_sources_rollup { listsources } {

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
# tools_sources::get_cata_from_sources
# Fournit le nombre de source
#
proc ::bdi_tools_sources::get_cata_from_sources { listsources } {

   set catalist {}
   set fields  [lindex $listsources 0]
   foreach s $fields { 
      lappend catalist [lindex $s 0]
   }
   return $catalist

}

#
# tools_sources::get_fields_from_sources
# Fournit le nombre de source
#
proc ::bdi_tools_sources::get_fields_from_sources { listsources } {

   return [lindex $listsources 0]

}


#
# tools_sources::extract_sources_by_catalog
# Fournit le nombre de source
#
proc ::bdi_tools_sources::extract_sources_by_catalog { listsources catadem } {

   set fields  [lindex $listsources 0]
   foreach s $fields { 
      ::console::affiche_resultat "$s\n"
   }
   set newsources {}
   set sources [lindex $listsources 1]
   foreach s $sources {
      foreach cata $s {
         if {[lindex $cata 0] == $catadem} {
           lappend newsources $s
         }
      }
   }
   return [list $fields $newsources]

}


#
# tools_sources::extract_sources_by_catalog
# Fournit le nombre de source
#
proc ::bdi_tools_sources::imprim_all_sources { listsources } {

   ::console::affiche_resultat "** SOURCES = \n"
   ::console::affiche_resultat "FIELDS = \n"
   set fields  [lindex $listsources 0]
   foreach s $fields { 
      ::console::affiche_resultat "$s\n"
   }
   ::console::affiche_resultat "VALUES = \n"
   set sources [lindex $listsources 1]
   foreach s $sources { 
      ::console::affiche_resultat "$s\n"
   }

}


#
# tools_sources::extract_sources_by_catalog
# Fournit le nombre de source
#
proc ::bdi_tools_sources::imprim_3_sources { listsources { catalog } } {

   if { [info exists catalog]} {
      ::console::affiche_resultat "** IMPRIM_3_SOURCES $catalog= \n"
   } else {
      ::console::affiche_resultat "** IMPRIM_3_SOURCES = \n"
   } 
   set nb 0
   ::console::affiche_resultat "FIELDS = \n"
   set fields  [lindex $listsources 0]
   foreach s $fields { 
      ::console::affiche_resultat "$s\n"
   }
   ::console::affiche_resultat "VALUES = \n"
   set sources [lindex $listsources 1]
   foreach s $sources {
      if { [info exists catalog]} {
         foreach cata $s {
            if { [lindex $cata 0]==$catalog } {
               ::console::affiche_resultat "$s\n"
               incr nb
               if {$nb>2} {
                  return
               }
            }
         }
      } else {
         ::console::affiche_resultat "$s\n"
         incr nb
         if {$nb>2} {
            return
         }
      }
   }

}


#
# tools_sources::extract_sources_by_catalog
# Fournit le nombre de source
#
proc ::bdi_tools_sources::imprim_sources { listsources catalog } {

   set nb 0
   ::console::affiche_resultat "** SOURCES $catalog = \n"
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
         }
      }
   }

}


#
# tools_sources::extract_sources_by_catalog
# Fournit le nombre de source
#
proc ::bdi_tools_sources::imprim_sources_vrac { listsources } {

   ::console::affiche_resultat "$listsources\n"

}


#
# tools_sources::set_common_fields
# initialise les champ common de la liste
# 
#
# listsources : liste en entree
# catalog : ou il faut puiser l info
# fieldlist : les champs a utiliser
#
proc ::bdi_tools_sources::set_common_fields { listsources catalog fieldlist } {

   set cst 0
   foreach f $fieldlist {
      if {[string is double -strict $f]} {
         incr cst
      }
   }

   set idlist ""
   set fields [lindex $listsources 0]
   set exist "no"
   foreach cata $fields {
      #gren_info "cata = $cata \n"
      if { [lindex $cata 0] == $catalog } {
         if {$exist == "yes"} {break}
         set exist "yes"
         set cols [lindex $cata 2]
         foreach f $fieldlist {
            if {[string is double -strict $f]} {
               lappend idlist -1
            } else {
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

   if {$exist == "no"} {
      return $listsources
   }

   if {[llength $idlist] != 5} {
      #::console::affiche_erreur "listsources = $listsources \n"
      ::console::affiche_erreur "erreur nom des champs (::bdi_tools_sources::set_common_fields)\n"
      ::console::affiche_erreur "IDLIST $idlist\n"
      ::console::affiche_erreur "CATALOG $catalog\n"
      ::console::affiche_erreur "FIELDLIST demande = $fieldlist\n"
      ::console::affiche_erreur "cst = $cst\n"
      ::console::affiche_erreur "FIELDLIST existe = $cols\n"
      ::console::affiche_erreur "CATA = $cata\n"
      return $listsources
   }

   set sources [lindex $listsources 1]
   set ids 0
   foreach s $sources {
      set sa($ids,catalog) ""
      foreach cata $s {
         #gren_info "cata = $cata\n"
         lappend sa($ids,catalog) [lindex $cata 0]
         set sa($ids,[lindex $cata 0]) $cata
         if {$ids == -1 } {
            gren_info "catalog = $sa($ids,[lindex $cata 0])\n"
         } else {
            #gren_info "catalog = $sa($ids,[lindex $cata 0])\n"
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




proc ::bdi_tools_sources::set_common_fields_skybot { listsources } {
   
   set fields [lindex $listsources 0]
   set sources [lindex $listsources 1]

   set ids 0
   foreach s $sources {
      foreach cata $s {
         if {[lindex $cata 0] == "IMG" } {
            set sa($ids) [lindex $cata 1]
         }
      }
      incr ids
   }

   set ids 0
   set lsr ""
   foreach s $sources {
      set sr ""
      foreach cata $s {
         #gren_info "cata = $cata\n"
         if {[lindex $cata 0] == "SKYBOT" } {
            #gren_info "cata = $cata\n"
            set cata [lreplace $cata 1 1 $sa($ids)]
            #gren_info "cata p= $cata\n"
         } else {
            #gren_info "catalog = $sa($ids,[lindex $cata 0])\n"
         }
         lappend sr $cata
      }
      lappend lsr $sr
   incr ids
   }

   return  [list $fields $lsr]

}

# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/tools_sources.tcl
# ::bdi_tools_sources::set_common_fields $listsources IMG { id flag xpos ypos instr_mag }
# ::bdi_tools_sources::imprim_3_sources $listsources
# set l [::bdi_tools_sources::set_common_fields $listsources IMG { id flag xpos ypos instr_mag }]
# ::bdi_tools_sources::imprim_3_sources $l
