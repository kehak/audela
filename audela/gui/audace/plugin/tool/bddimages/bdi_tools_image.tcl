## @file bdi_tools_image.tcl
#  @brief     Outils de gestion des listes d'images dans bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_image.tcl]
#  @endcode

# $Id: bdi_tools_image.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_image
# @brief Outils de gestion des listes d'images dans bddimages
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_image {

   global audace
   global bddconf

}

#--------------------------------------------------
#
#  Structure de la liste image
#
# {               -- debut de liste
#
#   {             -- debut d une image
#
#     {ibddimg 1}
#     {ibddcata 2}
#     {filename toto.fits.gz}
#     {dirfilename /.../}
#     {filenametmp toto.fit}
#     {cataexist 1}
#     {cataloaded 1}
#     ...
#     {tabkey {{NAXIS1 1024} {NAXIS2 1024}} }
#     {cata {{{IMG {ra dec ...}{USNO {...]}}}} { { {IMG {4.3 -21.5 ...}} {USNOA2 {...}} } {source2} ... } } }
#
#   }             -- fin d une image
#
# }               -- fin de liste
#
#--------------------------------------------------
#
#  Structure du tabkey
#
# { {NAXIS1 1024} {NAXIS2 1024} etc ... }
#
#--------------------------------------------------
#
#  Structure du cata
#
# {               -- debut structure generale
#
#  {              -- debut des noms de colonne des catalogues
#
#   { IMG   {list field crossmatch} {list fields}} 
#   { TYC2  {list field crossmatch} {list fields}}
#   { USNO2 {list field crossmatch} {list fields}}
#
#  }              -- fin des noms de colonne des catalogues
#
#  {              -- debut des sources
#
#   {             -- debut premiere source
#
#    { IMG   {crossmatch} {fields}}  -> vue dans l image
#    { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#    { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#
#   }             -- fin premiere source
#
#  }              -- fin des sources
#
# }               -- fin structure generale
#
#--------------------------------------------------
#
#  Structure intellilist_i (dite inteligente)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist           { 
#                        { valide     ... }
#                        { condition  ... }
#                        { champ      ... }
#                        { valeur     ... }
#                      }
#
#   }
#
# }
#
#--------------------------------------------------
#
#  Structure intellilist_n (dite normale)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist            { 
#                         {image_34 {134 345 677}}
#                         {image_38 {135 344 679}}
#                       }
#
#   }
#
# }2	IM_20150420_214935_cdl_Camilla.fits.gz	t60_les_makes	2015-04-20T22:05:29.677	120	107_Camilla	R	1	1	9	9	4.869		CORR	IMG				W				?
#
#--------------------------------------------------

# Lecture du Tabkkey depuis le buffer
proc ::bdi_tools_image::get_tabkey_from_buffer {  } {

   global bddconf
   set bufno $bddconf(bufno)

   ::bddimagesAdmin::bdi_setcompat $bufno

   set list_bufkeyname [buf$bufno getkwds]
   set tabkey {}
   foreach bufkeyname $list_bufkeyname {
      set bufkey [buf$bufno getkwd $bufkeyname]
      set bufkey [lreplace $bufkey 1 1 [string trim [lindex $bufkey 1]]]
      set bufkey [lreplace $bufkey 3 3 [string trim [lindex $bufkey 3]]]
      set bufkey [lreplace $bufkey 4 4 [string trim [lindex $bufkey 4]]]
      lappend tabkey [list [bddimages_keywd_to_variable $bufkeyname] $bufkey ]
   }
   set result  [bddimages_entete_preminforecon $tabkey]
   set err     [lindex $result 0]
   
   if {$err} {
      return -code $err "Lecture du TABKEY impossible\n"
   }
  #foreach key [lindex $result 1] {
  #    set ty [lindex $key {1 2}]
  #    gren_info "[lindex $key 0] => \[$ty\]\n"
  #}
   
  return [lindex $result 1]

}

# Lecture du Tabkkey depuis le buffer
proc ::bdi_tools_image::set_tabkey_in_buffer { bufno tabkey } {

   set err [catch {buf$bufno delkwds} msg]
   if {$err} {
      return -code 1 "$msg"
   }

   foreach k $tabkey {
      set key [lindex $k 1]
      set err [catch {buf$bufno setkwd $key} msg]
      if {$err} {
         return -code 2 "$msg"
      }

   }
   return
}


proc ::bdi_tools_image::get_tabkey_from_sql { idbddimg } {

   set tabkey ""
   
   set erreur 0

   # set sqlcmd "SELECT idheader FROM images WHERE idbddimg=$idbddimg;"
   # set sqlcmd "SHOW COLUMNS FROM images_$idheader;"
   # set sqlcmd "SELECT * FROM images_$idheader WHERE idbddimg=$idbddimg;"
   # set sqlcmd "SELECT * FROM header WHERE idheader=$idheader;"

   # recupere le idheader
   set sqlcmd "SELECT idheader FROM images WHERE idbddimg=$idbddimg;"
   gren_info "sqlcmd=$sqlcmd\n"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'images', msg: $msg"
   }
   set nb [llength $data]
   set idheader [lindex $data 0]
   gren_info "idheader = $idheader\n"

   # recupere les noms des colonnes de la table images_xx
   set sqlcmd "SHOW COLUMNS FROM images_$idheader;"
   gren_info "sqlcmd=$sqlcmd\n"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'images_$idheader', msg: $msg"
   }
   set nb [llength $data]
   array unset tabvarname
   set listvarname ""
   set i 0
   foreach d $data {
      #gren_info "d=$d\n"
      set j [regexp -all {^([^ ]*) .*\}$} $d u var tmp]
      if {$j==1} {
         set tabvarname($i) $var
         lappend listvarname $var
         #gren_info "var=$var\n"
         incr i
      } else {
          gren_erreur "d=$d\n"
      }
   }
   gren_info "tabvarname = [array get tabvarname]\n"


   # recupere les valeurs de la table images_xx
   set sqlcmd "SELECT * FROM images_$idheader WHERE idbddimg=$idbddimg;"
   gren_info "sqlcmd=$sqlcmd\n"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'images_$idheader', msg: $msg"
   }
   set nb [llength $data]
   gren_info "nb = $nb\n"
   array unset tabvalue
   set i 0
   set d [lindex $data 0]
   foreach s $d {
      set tabvalue($tabvarname($i)) $s
      #gren_info "$tabvarname($i)=$s\n"
      incr i
      continue
   }
   gren_info "tabvalue = [array get tabvalue]\n"


      
   # recupere les champs du tabkey de la table header
   set sqlcmd "SELECT * FROM header WHERE idheader=$idheader;"
   gren_info "sqlcmd=$sqlcmd\n"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'header', msg: $msg"
   }
   set nb [llength $data]
   array unset tab
   array unset tab_id 
   foreach d $data {

      gren_info "d = $d\n"
      
      # set ::bdi_tools_image::line $d
      # set d $::bdi_tools_image::line
      
      # ligne hierarch
      set j [regexp -all {^(.*) \{(.*)\} (.*) (.*) \{(.*)\} \{(.*)\}$} $d u idheader bufname type var unit comment]
      if { $j == 0 } {
         # ligne normale
         set i [regexp -all {^(.*) (.*) (.*) (.*) \{(.*)\} \{(.*)\}$} $d u idheader bufname type var unit comment]
         if {$i == 0 } {
            set k [regexp -all {^(.*) (.*) (.*) (.*) (.*) \{(.*)\}$} $d u idheader bufname type var unit comment]
            if {$k == 0 } {
               set l [regexp -all {^(.*) (.*) (.*) (.*) \{(.*)\} (.*)$} $d u idheader bufname type var unit comment]
               if {$l == 0 } {
                  gren_erreur "d= $d\n"
                  incr erreur
                  continue
               }
            }
         }
      }
      #gren_info "\nidheader = $idheader \n"
      #gren_info "bufname = $bufname \n"
      #gren_info "type = $type \n"
      #gren_info "var = $var \n"
      #gren_info "unit = $unit \n"
      #gren_info "comment = $comment\n"
      if {[bddimages_keywd_to_variable $bufname]!=$var} {
         gren_erreur "[bddimages_keywd_to_variable $bufname]!=$var\n"
         incr erreur
         continue
      }
      

      #gren_info "$var = \[$tabvalue($var)\] [string is  ascii $tabvalue($var)] [string is  digit $tabvalue($var)] [string is  double $tabvalue($var)] [string is  integer $tabvalue($var)]\n"

      if {[string is  digit $tabvalue($var)]} { 
         set value $tabvalue($var)
      } else {
         set value "\{$tabvalue($var)\}"
      }
      set line [list $var "\{$bufname\} $value [bddimages_convert_type_variable_sql_to_buf $type] \{$comment\} \{$unit\}"]
      lappend tabkey $line
      #gren_erreur "line = $line\n"
      
      # bddimages_keywd_to_variable $buf
      continue         
   }
   gren_info "tabkey = $tabkey\n"


  foreach key $tabkey {
      set ty [lindex $key {1 2}]
      gren_info "[lindex $key 0] => \[$ty\]\n"
  }



   return $tabkey
}


proc ::bdi_tools_image::tabkey_is_not_equal { tabkey1 tabkey2 } {

   if {[string compare $tabkey1 $tabkey2]==0} { return 0 }
   array unset tab1 tab2
   foreach k $tabkey1 {
      set tab1([lindex $k 0])  [lindex $k 1]
   }
   foreach k $tabkey2 {
      set tab2([lindex $k 0])  [lindex $k 1]
   }

   # cles communes
   foreach { x y } [array get tab1] {
      if {! [info exists tab2($x)]} {
         gren_info "NOT EXIST IN 2 x = $x :: $y\n"
         continue
      }
      lassign $y        a b c d e
      lassign $tab2($x) f g h i j
      if {$a != $f} {
         gren_info "DIFF NAME x = $x :: ($a) != ($f)\n"
         continue
      }
      if {$b != $g} {
         gren_info "[string is double $b] && [string is double $g]"
         if {[string is double $b] && [string is double $g] } {
            set diff [expr $b - $g]
            gren_info "DIFF VALUE x = $x :: diff = $diff\n"
            continue
         } else {
            gren_info "DIFF VALUE x = $x :: ($b) != ($g)\n"
            continue
         }
      }
      if {$c != $h} {
         gren_info "DIFF UNIT x = $x :: ($c) != ($h)\n"
         continue
      }
      if {$d != $i} {
         gren_info "DIFF COMMENT x = $x :: ($d) != ($i)\n"
         continue
      }
      if {$e != $j} {
         gren_info "DIFF UNIT x = $x :: ($e) != ($j)\n"
         continue
      }
   }

   return [string compare $tabkey1 $tabkey2]

}
