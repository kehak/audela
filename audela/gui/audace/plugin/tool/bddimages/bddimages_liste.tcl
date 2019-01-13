## @file bddimages_liste.tcl
#  @brief     Fonctions de gestion des listes de bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_liste.tcl]
#  @endcode

# $Id: bddimages_liste.tcl 13886 2016-05-22 21:55:06Z jberthier $

##
# @namespace bddimages_liste
# @brief Fonctions de gestion des listes de bddimages
# @pre Requiert le fichier d'internationalisation \c bddimages_liste.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_liste {

}

#--------------------------------------------------
#
#  Structure de la liste image
#
# {               -- debut de liste
#
#   {             -- debut d une image
#
#     {idbddimg 1}
#     {idbddcata 2}
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
# { {telescop          { {TELESCOP}          {TAROT CHILI} string {Observatory name}                    {} } }  
#   {naxis2            { {NAXIS2}            {1024}        int    {comment}                             {} } }  
#   {bddimages_version { {BDDIMAGES VERSION} 0             INT    {Compatibility version for bddimages} {} } }
#   etc ...
# }
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
#                         {34 {134 345 677}}
#                         {38 {135 344 679}}
#                       }
#
#   }
#
# }
#
#--------------------------------------------------


proc ::bddimages_liste::lget { tabkey inkey } {

   foreach keyval $tabkey {
      set key [lindex $keyval 0]
      set val [lindex $keyval 1]
      if { [string equal -nocase [ string trim $key ] [ string trim $inkey ]]} {
         return [string trim $val]
      }
   }
   return ""

}


proc ::bddimages_liste::lupdate { tabkey inkey inval } {

   set result_list ""
   foreach keyval $tabkey {
      set key [lindex $keyval 0]
      set val [lindex $keyval 1]
      if { [string equal -nocase [ string trim $key ] [ string trim $inkey ]]} {
         lappend result_list [list $inkey $inval]
      } else {
         lappend result_list [list $key $val]
      }
   }
   return $result_list

}


proc ::bddimages_liste::ladd { tabkey inkey inval } {

   if {[::bddimages_liste::lexist $tabkey $inkey]} {
      set tabkey [::bddimages_liste::lupdate $tabkey $inkey $inval]
   } else {
      lappend tabkey [list $inkey $inval]
   }
   return $tabkey

}

proc ::bddimages_liste::ldelete { tabkey inkey } {

   set result_list ""
   foreach keyval $tabkey {
      set key [lindex $keyval 0]
      set val [lindex $keyval 1]
      if { ! [string equal -nocase [ string trim $key ] [ string trim $inkey ]]} {
         lappend result_list [list $key $val]
      }
   }
   return $result_list

}


proc ::bddimages_liste::lexist { tabkey inkey } {

   foreach keyval $tabkey {
      set key [lindex $keyval 0]
      if { [string equal -nocase [ string trim $key ] [ string trim $inkey ]]} {
         return 1
      }
   }
   return 0

}


# Remove an element from a list
# source: 
#proc ::bddimages_liste::lremove {listVariable value} {
#
#   upvar 1 $listVariable var
#   set idx [lsearch -exact $var $value]
#   set var [lreplace $var $idx $idx]
#
#}
