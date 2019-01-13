#
# Fichier : votable_example.tcl
# Description : Exemple d'ecriture d'une VOTable
#     source /usr/local/src/audela/gui/audace/plugin/tool/vo_tools/Examples/cata2votable.tcl
# Auteur : Jerome BERTHIER
# Mise à jour $Id: cata2votable.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
namespace import votable::*
uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""
namespace import votableUtil::*

set astroId [::votableUtil::cata2astroid "/surfer/Observations/telescopes/Tarot/test_cata.txt"]

# Premiere liste => entetes
set headerList [lindex $astroId 0]
foreach header $headerList {
   set tableName [lindex $header 0]
   set tableFields [lrange $header 1 2]
   set i 0
   foreach field $tableFields {
      if { $i == 0 } {
         set tableSubName "COMMON"
      } else {
         set tableSubName "DEDICATED"
      }
      foreach f $field {
         ::console::disp "ASTROID - $tableName - $tableSubName - FIELD: $f \n"
      }
      incr i
   }
}

# Deuxieme liste => data
set dataList [lindex $astroId 1]
::console::disp [concat "ASTROID DATA   : "  "\n\n"]

set votable [::votableUtil::astroid2votable $astroId]

#::console::disp $votable

