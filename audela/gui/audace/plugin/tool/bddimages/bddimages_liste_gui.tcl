## @file bddimages_liste_gui.tcl
#  @brief     GUI de gestion des listes de bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_liste_gui.tcl]
#  @endcode

# $Id: bddimages_liste_gui.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bddimages_liste_gui
# @brief GUI de gestion des listes de bddimages
# @pre Requiert \c bdi_tools_calendar .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_liste_gui {

   package require bdi_tools_calendar 1.0

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""

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
#   {idlist             {
#                         {34 {134 345 677}}
#                         {38 {135 344 679}}
#                       }
#
#   }
#
# }
#
#--------------------------------------------------

#--------------------------------------------------
# run { this }
#--------------------------------------------------
#
#    fonction  :
#        GUI de definition d'une liste intelligente
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_liste_gui::run { this {listname ?} } {
   variable This
   global entetelog

   set entetelog "liste"
   set This $this
   ::bddimages_liste_gui::createDialog $listname
   return
}




#--------------------------------------------------
# runnormal { this }
#--------------------------------------------------
#
#    fonction  :
#        GUI de definition d'une liste normale
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_liste_gui::runnormal { this } {

   global This
   global entetelog
   global color

   set entetelog "liste"
   set This $this

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      return
   }

   global getnamenewlist

   set getnamenewlist(result) 0
   set getnamenewlist(name) ""

   toplevel $This -class Toplevel
   wm title $This "Nouvelle liste normale"
   wm positionfrom $This user
   wm sizefrom $This user

   set framecurrent $This.framename

   frame $framecurrent -relief groove
   pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10

   # Frame du titre
   frame $framecurrent.title
   pack configure $framecurrent.title -side top -fill x
     label $framecurrent.title.e -text "Nom de la liste"
     pack configure $framecurrent.title.e -side left -anchor c

   # Frame de saisie du nom de la liste
   frame $framecurrent.lname
   pack configure $framecurrent.lname -side top -fill x
     entry $framecurrent.lname.v -textvariable getnamenewlist(name)
     pack configure $framecurrent.lname.v -side bottom -anchor c

   # Frame qui va contenir les boutons Cancel et Ok
   frame $framecurrent.buttons
   pack configure $framecurrent.buttons -side top -fill x -pady 2 -padx 2
     button $framecurrent.buttons.cancel -text Cancel -command "destroy $This"
     pack configure $framecurrent.buttons.cancel -side left
     button $framecurrent.buttons.ok -text Ok -command { set getnamenewlist(result) 1; ::bddimages_liste_gui::build_normallist; destroy $This }
     pack configure $framecurrent.buttons.ok -side right

   # Mise a jour dynamique des couleurs
   ::confColor::applyColor $This

   grab set $This
   tkwait window $This

   if {$getnamenewlist(result)} {
      return -code 0 $getnamenewlist(name)
   } else {
      return 1
   }

}






#--------------------------------------------------
# fermer { }
#--------------------------------------------------
#
#    fonction  :
#        Fonction appellee lors de l'appui
#        sur le bouton 'Fermer'
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_liste_gui::fermer { } {
   variable This

   ::bddimages_liste_gui::recup_position
   destroy $This
   return
}






#--------------------------------------------------
#  recup_position { }
#--------------------------------------------------
#
#    fonction  :
#       Permet de recuperer et de sauvegarder
#       la position de la fenetre
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_liste_gui::recup_position { } {
   variable This
   global audace
   global conf
   global bddconf

   set bddconf(list_geom_stat) [ wm geometry $This ]
   set deb [ expr 1 + [ string first + $bddconf(list_geom_stat) ] ]
   set fin [ string length $bddconf(list_geom_stat) ]
   set bddconf(list_pos_stat) "+[ string range $bddconf(list_geom_stat) $deb $fin ]"
   #---
   set conf(bddimages,list_pos_stat) $bddconf(list_pos_stat)
   return
}







#--------------------------------------------------
#  get_list_combobox { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des conditions de la requete
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste
#
#--------------------------------------------------
proc ::bddimages_liste_gui::get_list_combobox { } {
   global caption
   return [list "=" ">" "<" ">=" "<=" "!=" $caption(bddimages_liste,contient) $caption(bddimages_liste,notcontient)]
}






#--------------------------------------------------
#  affich_form_req { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des conditions de la requete
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste
#
#--------------------------------------------------
proc ::bddimages_liste_gui::affich_form_req { } {

  set jjdatemin [ mc_date2jd $::bddimages_liste_gui::form_req(datemin) ]
  set jjdatemax [ mc_date2jd $::bddimages_liste_gui::form_req(datemax) ]

  gren_debug "-- affich_form_req"
  gren_debug "datemin             = $::bddimages_liste_gui::form_req(datemin)\n"
  gren_debug "datemax             = $::bddimages_liste_gui::form_req(datemax)\n"
  gren_debug "midi                = $::bddimages_liste_gui::form_req(midi)\n"
  gren_debug "jjdatemin           = $jjdatemin\n"
  gren_debug "jjdatemax           = $jjdatemax\n"
  gren_debug "type_req_check      = $::bddimages_liste_gui::form_req(type_req_check)\n"
  gren_debug "type_requ           = $::bddimages_liste_gui::form_req(type_requ)\n"
  gren_debug "choix_limit_result  = $::bddimages_liste_gui::form_req(choix_limit_result)\n"
  gren_debug "limit_result        = $::bddimages_liste_gui::form_req(limit_result)\n"
  gren_debug "type_result         = $::bddimages_liste_gui::form_req(type_result)\n"
  gren_debug "type_select         = $::bddimages_liste_gui::form_req(type_select)\n"
  gren_debug "nbimg               = $::bddimages_liste_gui::form_req(nbimg)\n"

}







proc ::bddimages_liste_gui::get_val_intellilist { intellilist val } {

   set y ""
   foreach  l $intellilist  {
       set x [lsearch $l $val]
       if {$x!=-1} {
          set y [lindex $l 1]
          return $y
       }
   }
   return $y
}







proc ::bddimages_liste_gui::affiche_intellilist { intellilist } {

  gren_debug "-- affiche_intellilist\n"
  gren_debug "intellilist = $intellilist \n"
  gren_debug "name = [get_val_intellilist $intellilist "name"] \n"
  gren_debug "datemin = [get_val_intellilist $intellilist "datemin"]\n"
  gren_debug "datemax = [get_val_intellilist $intellilist "datemax"]\n"
  gren_debug "type_req_check = [get_val_intellilist $intellilist "type_req_check"]\n"
  gren_debug "type_requ = [get_val_intellilist $intellilist "type_requ"]\n"
  gren_debug "choix_limit_result = [get_val_intellilist $intellilist "choix_limit_result"]\n"
  gren_debug "limit_result = [get_val_intellilist $intellilist "limit_result"]\n"
  gren_debug "type_result = [get_val_intellilist $intellilist "type_result"]\n"
  gren_debug "type_select = [get_val_intellilist $intellilist "type_select"]\n"
  gren_debug "reqlist = [get_val_intellilist $intellilist "reqlist"]\n"
  gren_debug "--\n"

}




#--------------------------------------------------
#  get_intellilist_by_name { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des conditions de la requete
#
#    procedure externe :
#
#    variables en entree : name
#
#    variables en sortie : none
#
#--------------------------------------------------
proc ::bddimages_liste_gui::get_intellilist_by_name { name } {

   global nbintellilist
   global intellilisttotal

   set found 0
   for {set i 1} {$i<=$nbintellilist} {incr i} {
      set l $intellilisttotal($i)
      if { [get_val_intellilist $l "name"] eq "$name" } {
         set found 1
         break
      }
   }
   if {$found} {
      return $i
   } else {
      return -1
   }
}

#--------------------------------------------------
#  get_intellilist_by_id { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des conditions de la requete
#
#    procedure externe :
#
#    variables en entree : id
#
#    variables en sortie : none
#
#--------------------------------------------------
proc ::bddimages_liste_gui::get_intellilist_by_id { id } {

  global intellilisttotal

  return $intellilisttotal($id)
}







proc ::bddimages_liste_gui::exec_intellilist { num } {

 gren_info "::bddimages_liste_gui::exec_intellilist $num\n"
 gren_info "- Affiche_listes\n"
 ::bddimages_recherche::Affiche_listes
 gren_info "- get_intellist\n"
 ::bddimages_recherche::get_intellist $num
 gren_info "- Affiche_Results\n"
 ::bddimages_recherche::Affiche_Results $num
 gren_info "- Fin\n"

}







proc ::bddimages_liste_gui::new_normallist { lid } {

   set imgtmplist     ""
   lappend imgtmplist [list "type"   "normal"]
   lappend imgtmplist [list "name"   "tmp"]
   lappend imgtmplist [list "idlist" ""]
   set imgtmplist [::bddimages_liste_gui::add_to_normallist $lid $imgtmplist]
   set imgtmplist [::bddimages_liste_gui::intellilist_to_imglist $imgtmplist]
   return $imgtmplist

}






proc ::bddimages_liste_gui::add_to_normallist { lid normallist {ibddlist -1} } {


   # Recupere la liste des idbddimg dans la liste des images affichees dans la GUI recherche
   set cpt 0
   if {$ibddlist == -1} {
      foreach i $lid {
         incr cpt
         set id [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
         if {$cpt == 1} {
            set l "$id"
         } else {
            set l "$l,$id"
         }
      }
   } else {
      foreach i $ibddlist {
         incr cpt
         if {$cpt == 1} {
            set l "$i"
         } else {
            set l "$l,$i"
         }
      }
   }

   if {$cpt == 0} {
      return
   }

   #recupere les tables images_idhd des idbddimg
   set sqlcmd "SELECT images.idheader,images.idbddimg FROM images
               WHERE images.idbddimg IN ($l)
               ORDER BY images.idheader ASC;"

   set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
   if {$err} {
      ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
      ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
      ::console::affiche_erreur "        err = $err\n"
      ::console::affiche_erreur "        msg = $msg\n"
      return
   }
   set nbresult [llength $resultcount]
   set result [lindex $resultcount 1]
   #::console::affiche_resultat "nbresult = $nbresult\n"
   #::console::affiche_resultat "result = $result\n"

   #met en forme la nouvelle liste d id
   set ltable ""
   foreach l $result {
      set table [lindex $l 0]
      set id [lindex $l 1]
      lappend ltable $table
      lappend comp($table) $id
   }

   #::console::affiche_resultat "comp = [array get comp]\n"

   set oldidlist [::bddimages_liste_gui::get_val_intellilist $normallist "idlist"]

   foreach l $oldidlist {
      set table [lindex $l 0]
      set li    [lindex $l 1]
      lappend ltable $table
      foreach id $li {
         lappend comp($table) $id
      }
   }

   #construit la nouvelle idlist
   set ltable [lsort -unique $ltable]
   foreach t $ltable {
      set comp($t) [lsort -unique $comp($t)]
   }


   set idlist ""
   foreach t $ltable {
      #::console::affiche_resultat "table = $t\n"
      set il ""
      foreach i $comp($t) {
         lappend il $i
         #::console::affiche_resultat "$i "
      }
      lappend idlist [list $t $il]
      #::console::affiche_resultat "\n"
   }
   #::console::affiche_resultat "idlist=$idlist\n"

   if { [::bddimages_liste_gui::get_val_intellilist $normallist "type"] != "normal"} {
      ::console::affiche_erreur "Ne peut etre associe a la liste $namelist\n"
      return
   }

   #::console::affiche_resultat "normallist=$normallist\n"

   set newl ""
   foreach val $normallist {
      if {[lindex $val 0] == "idlist"} {
         lappend newl [list "idlist" $idlist]
      } else {
         lappend newl $val
      }
   }

   return $newl
}







proc ::bddimages_liste_gui::delete_from_normallist { lid normallist } {

   set newl ""
   foreach val $normallist {
      if {[lindex $val 0] == "idlist"} {
         lappend newl [list "idlist" $idlist]
      } else {
         lappend newl $val
      }
   }

   return $newl
}




proc ::bddimages_liste_gui::purge_normallist { normallist } {

   set newl ""
   foreach val $normallist {
      if {[lindex $val 0] == "idlist"} {
         lappend newl [list "idlist" ""]
      } else {
         lappend newl $val
      }
   }

   return $newl
}



#-- not RZ : proc en doublon avec la precedente --> warning Doxygen
#proc ::bddimages_liste_gui::purge_normallist { normallist } {

#   set newl ""
#   foreach val $normallist {
#      if {[lindex $val 0] == "idlist"} {
#        lappend newl [list "idlist" ""]
#      } else {
#         lappend newl $val
#      }
#   }

#   return $newl
#}




proc ::bddimages_liste_gui::build_normallist { } {

   global getnamenewlist
   global nbintellilist intellilisttotal

   if {$getnamenewlist(name) != ""} {
      ::console::affiche_resultat "new list = $getnamenewlist(name)\n"
      set intellilist     ""
      lappend intellilist [list "type" "normal"]
      lappend intellilist [list "name" $getnamenewlist(name)]
      lappend intellilist [list "idlist" ""]
      incr nbintellilist
      set intellilisttotal($nbintellilist) $intellilist
      ::bddimages_liste_gui::exec_intellilist $nbintellilist
      conf_save_intellilists
   } else {
      gren_erreur "build_normallist: la liste normale n'a pas de nom, operation annullee"
   }

}






# Construit une intelliliste a partir du formulaire
proc ::bddimages_liste_gui::build_intellilist { name } {

   global indicereq
   global list_req
   global ::bddimages_liste_gui::form_req
   global caption
   global nbintellilist

   set intellilist ""
   lappend intellilist [list "type"               "intellilist"]
   lappend intellilist [list "name"               $name]
   lappend intellilist [list "datemin"            $::bddimages_liste_gui::form_req(datemin)]
   lappend intellilist [list "datemax"            $::bddimages_liste_gui::form_req(datemax)]
   lappend intellilist [list "midi"               $::bddimages_liste_gui::form_req(midi)]
   lappend intellilist [list "type_req_check"     $form_req(type_req_check)]
   lappend intellilist [list "type_requ"          $form_req(type_requ)]
   lappend intellilist [list "choix_limit_result" $form_req(choix_limit_result)]
   lappend intellilist [list "limit_result"       $form_req(limit_result)]
   lappend intellilist [list "type_result"        $form_req(type_result)]
   lappend intellilist [list "type_select"        $form_req(type_select)]

   set reqlist ""
   set y 0
   for {set x 1} {$x<=$indicereq} {incr x} {
      if {$list_req($x,valide)=="ok"&&$list_req($x,valeur)!=""} {
         incr y
         if {$list_req($x,condition)== $caption(bddimages_liste,contient)} {
            lappend reqlist [list $y $list_req($x,champ) "LIKE" "%$list_req($x,valeur)%"]
            continue
         }
         if {$list_req($x,condition)== $caption(bddimages_liste,notcontient)} {
            lappend reqlist [list $y $list_req($x,champ) "NOT LIKE" "%$list_req($x,valeur)%"]
            continue
         }
         lappend reqlist [list $y $list_req($x,champ) $list_req($x,condition) $list_req($x,valeur)]
      }
   }
   lappend intellilist [list "reqlist" $reqlist]
   return $intellilist
}







# Construit une intelliliste a partir du formulaire
proc ::bddimages_liste_gui::load_intellilist { intellilist } {

   global indicereq
   global list_req
   global ::bddimages_liste_gui::form_req

   set ::bddimages_liste_gui::form_req(name)               [get_val_intellilist $intellilist "name"]
   set ::bddimages_liste_gui::form_req(datemin)            [get_val_intellilist $intellilist "datemin"]
   set ::bddimages_liste_gui::form_req(datemax)            [get_val_intellilist $intellilist "datemax"]
   set ::bddimages_liste_gui::form_req(midi)               [get_val_intellilist $intellilist "midi"]
   set ::bddimages_liste_gui::form_req(type_req_check)     [get_val_intellilist $intellilist "type_req_check"]
   set ::bddimages_liste_gui::form_req(type_requ)          [get_val_intellilist $intellilist "type_requ"]
   set ::bddimages_liste_gui::form_req(choix_limit_result) [get_val_intellilist $intellilist "choix_limit_result"]
   set ::bddimages_liste_gui::form_req(limit_result)       [get_val_intellilist $intellilist "limit_result"]
   set ::bddimages_liste_gui::form_req(type_result)        [get_val_intellilist $intellilist "type_result"]
   set ::bddimages_liste_gui::form_req(type_select)        [get_val_intellilist $intellilist "type_select"]
   set ::bddimages_liste_gui::reqlist                      [get_val_intellilist $intellilist "reqlist"]

   set indicereq 0
   foreach req $::bddimages_liste_gui::reqlist {
      incr indicereq
      set list_req($indicereq,valide)    "ok"
      set list_req($indicereq,condition) [lindex $req 2]
      set list_req($indicereq,champ)     [lindex $req 1]
      set list_req($indicereq,valeur)    [lindex $req 3]
   }

}





proc ::bddimages_liste_gui::conf_save_intellilists { } {

   global bddconf

   set l ""
   for {set x 1} {$x<=$::nbintellilist} {incr x} {
      lappend l [list $::intellilisttotal($x)]
   }
   set ::conf(bddimages,$bddconf(current_config),intellilists) $l
}






#--------------------------------------------------
#  get_list_box_champs { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des champs
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste
#
#--------------------------------------------------
proc ::bddimages_liste_gui::get_list_box_champs { } {

   global list_key_to_var

   set list_box_champs [list ]
   set nbl1 0
   set sqlcmd "select distinct keyname,variable from header order by keyname;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
      return -code error "Erreur de lecture de la liste des header par SQL"
   }
   foreach line $resultsql {
      set key [lindex $line 0]
      set var [lindex $line 1]
      set list_key_to_var($key) $var
      if {$nbl1<[string length $key]} {
         set nbl1 [string length $key]
      }
      lappend list_box_champs $key
   }
   set nbl1 [expr $nbl1 + 3]
   return [list $nbl1 $list_box_champs]
}




proc ::bddimages_liste_gui::conf_load_intellilists { } {

   global nbintellilist
   global intellilisttotal
   global bddconf

   set nbintellilist 0

   # hack pour initialisation
   if { [catch {::bddimages_liste_gui::get_list_box_champs} msg] } {
      return -code error $msg
   }
   if { ! [info exists ::conf(bddimages,$bddconf(current_config),intellilists) ] } then { return }
   foreach l $::conf(bddimages,$bddconf(current_config),intellilists) {
      incr nbintellilist
      set intellilisttotal($nbintellilist) [lindex $l 0]
   }
}




proc ::bddimages_liste_gui::accept { } {

   global indicereq
   global list_req
   global ::bddimages_liste_gui::form_req
   global caption
   global nbintellilist
   global intellilisttotal

   set idx [::bddimages_liste_gui::get_intellilist_by_name $form_req(name)]
   if { $idx == -1 } {
      incr nbintellilist
      set idx $nbintellilist
   }

   set intellilist [::bddimages_liste_gui::build_intellilist "$form_req(name)"]
   set intellilisttotal($idx) $intellilist

   # ::bddimages_recherche::Affiche_listes
   # ::bddimages_recherche::get_intellist $nbintellilist
   # ::bddimages_recherche::Affiche_Results $nbintellilist

   ::bddimages_liste_gui::exec_intellilist $idx
   ::bddimages_liste_gui::conf_save_intellilists
   ::bddimages_liste_gui::fermer
}

proc ::bddimages_liste_gui::save { } {

   global indicereq
   global list_req
   global ::bddimages_liste_gui::form_req
   global caption
   global nbintellilist
   global intellilisttotal

   set idx [::bddimages_liste_gui::get_intellilist_by_name $form_req(name)]
   if { $idx == -1 } {
      incr nbintellilist
      set idx $nbintellilist
   }

   set intellilist [::bddimages_liste_gui::build_intellilist "$form_req(name)"]
   set intellilisttotal($idx) $intellilist

   # ::bddimages_recherche::Affiche_listes
   # ::bddimages_recherche::get_intellist $nbintellilist
   # ::bddimages_recherche::Affiche_Results $nbintellilist

   ::bddimages_recherche::Affiche_listes
   ::bddimages_liste_gui::conf_save_intellilists
   ::bddimages_liste_gui::fermer
}



#--------------------------------------------------
#  get_sqlcritere { }
#--------------------------------------------------
#
#    fonction  :
#       construit la requete sql pour une table images_xxx
#
#    variables en entree : id header de la table
#
#    variables en sortie : requete sql
#
#--------------------------------------------------
proc ::bddimages_liste_gui::get_sqlcritere { intellilist table } {

   global indicereq
   global list_req
   global ::bddimages_liste_gui::form_req
   global caption
   global list_key_to_var

   set ilist(name)               [get_val_intellilist $intellilist "name"]
   set ilist(datemin)            [get_val_intellilist $intellilist "datemin"]
   set ilist(datemax)            [get_val_intellilist $intellilist "datemax"]
   set ilist(midi)               [get_val_intellilist $intellilist "midi"]
   set ilist(type_req_check)     [get_val_intellilist $intellilist "type_req_check"]
   set ilist(type_requ)          [get_val_intellilist $intellilist "type_requ"]
   set ilist(choix_limit_result) [get_val_intellilist $intellilist "choix_limit_result"]
   set ilist(limit_result)       [get_val_intellilist $intellilist "limit_result"]
   set ilist(type_result)        [get_val_intellilist $intellilist "type_result"]
   set ilist(type_select)        [get_val_intellilist $intellilist "type_select"]
   set reqlist                   [get_val_intellilist $intellilist "reqlist"]

   if { $ilist(type_requ)==$caption(bddimages_liste,toutes)} {
     set reqcond "AND"
     }
   if { $ilist(type_requ)==$caption(bddimages_liste,nimporte)} {
     set reqcond "OR"
     }

   set sqlcritere ""
   set cpt 0
   foreach req $reqlist {
      set key  [lindex $req 1]
      set cond [lindex $req 2]
      set val  [lindex $req 3]
      if {$cpt==0} {
         set sqlcritere "AND ( $sqlcritere (`$list_key_to_var($key)` $cond '$val') "
      } else {
         set sqlcritere "$sqlcritere $reqcond (`$list_key_to_var($key)` $cond '$val') "
      }
      incr cpt
   }
   if {$cpt!=0} {
      set sqlcritere "$sqlcritere ) "
   }

   set cond "AND"

   set jjdatemin [ mc_date2jd "$ilist(datemin)T$ilist(midi):00:00" ]
   set jjdatemax [ mc_date2jd "$ilist(datemax)T$ilist(midi):00:00" ]

   if { $ilist(datemin)!=""} {
      if { $ilist(datemax)!=""} {
      set sqlcritere "$sqlcritere AND (commun.datejj>$jjdatemin AND commun.datejj<$jjdatemax) "
      } else {
      set sqlcritere "$sqlcritere AND (commun.datejj>$jjdatemin) "
      }
   } else {
      if { $ilist(datemax)!=""} {
      set sqlcritere "$sqlcritere AND (commun.datejj<$jjdatemax) "
      }
   }

   if { $ilist(choix_limit_result)} {
      set sqlcritere "$sqlcritere LIMIT $ilist(limit_result) "
   }

   return $sqlcritere
}






proc ::bddimages_liste_gui::transform_tabkey { table } {

   set tableresult ""

   foreach img $table {
      set tabkey [::bddimages_liste::lget $img "tabkey"]
      set result [bddimages_entete_preminforecon $tabkey]
      set err [lindex $result 0]
      if {$err != 0} {
         continue
      }
      set tabkey [lindex $result 1]
      lappend tableresult [::bddimages_liste::lupdate $img "tabkey" $tabkey]
   }

   return $tableresult

}





#--------------------------------------------------
#  intellilist_to_imglist { }
#--------------------------------------------------
#
#    fonction  :
#       renvoit la liste des images et de leur contenu
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste des images
#
#--------------------------------------------------
proc ::bddimages_liste_gui::intellilist_to_imglist { intellilist } {

   #::console::affiche_resultat "intellilist = $intellilist\n"

   set type [::bddimages_liste_gui::get_val_intellilist $intellilist "type"]

   if {$type == "intellilist"} {
      set img_list [::bddimages_liste_gui::intellilist_to_imglist_i $intellilist]
      set img_list [::bddimages_liste_gui::transform_tabkey $img_list]
      #::console::affiche_resultat "intelli: img_list = $img_list\n"
   }

   if {$type == "normal"} {
      set img_list [::bddimages_liste_gui::intellilist_to_imglist_n $intellilist]
      set img_list [::bddimages_liste_gui::transform_tabkey $img_list]
      #::console::affiche_resultat "normal: img_list = $img_list\n"
   }

   return $img_list

}







#--------------------------------------------------
#  intellilist_to_imglist_n { }
#--------------------------------------------------
#
#    fonction  :
#       construit la requete sql generale pour une liste normale
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste des images
#
#--------------------------------------------------
proc ::bddimages_liste_gui::intellilist_to_imglist_n { intellilist } {

   #::console::affiche_resultat "intellilist = $intellilist\n"

   # Recupere la liste des id image et table header correspondante
   set idlist [::bddimages_liste_gui::get_val_intellilist $intellilist "idlist"]
   #::console::affiche_resultat "idlist = $idlist\n"
   if {[llength $idlist] == 0} {
      return
   }

   set img_list ""
   foreach val $idlist {

      set idhd [lindex $val 0]
      set lid [lindex $val 1]
      set cpt 0
      foreach id $lid {
         if {$cpt == 0} {
            set lsqlid "$id"
         } else {
            set lsqlid "$lsqlid,$id"
         }
         incr cpt
      }
      #::console::affiche_resultat " -> images_idhd = images_$idhd : $lsqlid\n"

      set sqlcmd "SELECT images.idbddimg,
                         images.idheader,
                         images.tabname,
                         images.filename,
                         images.dirfilename,
                         images.sizefich,
                         images.datemodif,
                         commun.datejj as commundatejj,
                         images_$idhd.*
                  FROM images,images_$idhd,commun
           WHERE images.idbddimg = images_$idhd.idbddimg
                  AND   commun.idbddimg = images_$idhd.idbddimg
                  AND   images.idbddimg IN ($lsqlid);"

      #::console::affiche_resultat "sqlcmd = $sqlcmd\n"
      set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
      if {[string first "Unknown column" $msg]==-1} {
         if {$err} {
            bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
            bddimages_sauve_fich "        sqlcmd = $sqlcmd"
            bddimages_sauve_fich "        err = $err"
            bddimages_sauve_fich "        msg = $msg"
            ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
            ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
            ::console::affiche_erreur "        err = $err\n"
            ::console::affiche_erreur "        msg = $msg\n"
            return
         }

         #::console::affiche_resultat "resultcount = $resultcount\n"
         if {[llength $resultcount] > 0} {

            set tabkey [::bddimages_liste_gui::idhd_to_tabkey $idhd]
            set colvar [lindex $resultcount 0]
            set rowvar [lindex $resultcount 1]
            set nbcol  [llength $colvar]

            foreach keyline $rowvar {

               set result_img ""

               # Common fields to manage BDI

               # idbddimg
               set key [lindex $colvar 8]
               set val [lindex $keyline 8]
               lappend result_img [list $key $val]
               #::console::affiche_resultat "$key -> $val\n"

               # others...
               for {set id 1} {$id<=7} {incr id} {
                  set key [lindex $colvar $id]
                  set val [lindex $keyline $id]
                  lappend result_img [list $key $val]
               }

               #  TABKEY

               for {set id 9} {$id<$nbcol} {incr id} {
                  set key [lindex $colvar $id]
                  set val [lindex $keyline $id]
                  if {[::bddimages_liste::lexist $tabkey $key ]} {
                     set inline [lreplace [::bddimages_liste::lget $tabkey $key] 1 1 $val]
                     set tabkey [::bddimages_liste::lupdate $tabkey $key $inline]
                  }
               }

               lappend result_img [list "tabkey" $tabkey]
               lappend img_list $result_img

            }
         }
      }
   }

   set img_list [::bddimages_liste_gui::add_info_cata_list $img_list]

   #::console::affiche_erreur " img_list = $img_list\n"
   return $img_list

}








proc ::bddimages_liste_gui::idhd_to_tabkey { idhd } {


   # lecture des infos de chaque champ
   set sqlcmd "SELECT variable,
                      keyname,
                      0 as value,
                      type,
                      comment,
                      unit
               FROM header
        WHERE idheader = $idhd
               ;"
   set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
   if {![string first "Unknown column" $msg]==-1||$err} {
         bddimages_sauve_fich "Erreur de lecture de la table des header par SQL"
         bddimages_sauve_fich "     sqlcmd = $sqlcmd"
         bddimages_sauve_fich "        err = $err"
         bddimages_sauve_fich "        msg = $msg"
         ::console::affiche_erreur "Erreur1 de lecture de la table des header par SQL\n"
         ::console::affiche_erreur "     sqlcmd = $sqlcmd\n"
         ::console::affiche_erreur "        err = $err\n"
         ::console::affiche_erreur "        msg = $msg\n"
         return
      }


   set nbresult [llength $resultcount]

   if {$nbresult>0} {

      set colvar [lindex $resultcount 0]
      set rowvar [lindex $resultcount 1]
      set nbcol  [llength $colvar]

      set tabkey ""
      foreach keyline $rowvar {

         set var     [lindex $keyline 0]
         set keyname [lindex $keyline 1]
         set value   [lindex $keyline 2]
         set type    [lindex $keyline 3]
         set comment [lindex $keyline 4]
         set unit    [lindex $keyline 5]

         lappend tabkey [list $var [list $keyname $value $type $comment $unit]]

      }
   }

   return $tabkey

}




proc ::bddimages_liste_gui::file_to_img { filename dirfilename } {

   set sqlcmd "SELECT images.idbddimg,
                      images.idheader
                 FROM images
                WHERE images.filename = \"$filename\"
                  AND images.dirfilename = \"$dirfilename\";"

   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "Erreur de lecture des images, commun par SQL"
      bddimages_sauve_fich "   sqlcmd = $sqlcmd"
      bddimages_sauve_fich "   err = $err"
      bddimages_sauve_fich "   msg = $msg"
      return
   }

   set img_list ""

   set pass "no"
   foreach line $resultsql {
      set idbddimg [lindex $line 0]
      set idhd     [lindex $line 1]
      set pass "ok"
      break
   }

   if {$pass=="no"} {
      gren_info "   sqlcmd = $sqlcmd \n"
      gren_info "   err = $err \n"
      gren_info "   msg = $msg \n"
      gren_info "   idbddimg = $idbddimg \n"
      gren_info "   idhd = $idhd \n"
   }

   set sqlcmd "SELECT images.idbddimg,
                      images.idheader,
                      images.tabname,
                      images.filename,
                      images.dirfilename,
                      images.sizefich,
                      images.datemodif,
                      commun.datejj as commundatejj,
                      images_$idhd.*
               FROM images,images_$idhd,commun
        WHERE images.idbddimg = images_$idhd.idbddimg
               AND   commun.idbddimg = images_$idhd.idbddimg
               AND   images.idbddimg = $idbddimg;"

   set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]

   if {[string first "Unknown column" $msg]==-1} {

      if {$err} {
         bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
         bddimages_sauve_fich "        sqlcmd = $sqlcmd"
         bddimages_sauve_fich "        err = $err"
         bddimages_sauve_fich "        msg = $msg"
         ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
         ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
         ::console::affiche_erreur "        err = $err\n"
         ::console::affiche_erreur "        msg = $msg\n"
         return
      }

      set nbresult [llength $resultcount]

      if {$nbresult>0} {

         set tabkey [::bddimages_liste_gui::idhd_to_tabkey $idhd]
         set colvar [lindex $resultcount 0]
         set rowvar [lindex $resultcount 1]
         set nbcol  [llength $colvar]

         foreach keyline $rowvar {

            set result_img ""

            # Common fields to manage BDI

                # idbddimg
                set key [lindex $colvar 8]
                set val [lindex $keyline 8]
                lappend result_img [list $key $val]

                # others...
                for {set id 1} {$id<=7} {incr id} {
                   set key [lindex $colvar $id]
                   set val [lindex $keyline $id]
                   lappend result_img [list $key $val]
                }

            #  TABKEY

                for {set id 9} {$id<$nbcol} {incr id} {
                   set key [lindex $colvar $id]
                   set val [lindex $keyline $id]
                   set inline [lreplace [::bddimages_liste::lget $tabkey $key] 1 1 $val]
                   set tabkey [::bddimages_liste::lupdate $tabkey $key $inline]
                }


            lappend result_img [list "tabkey" $tabkey]
            lappend img_list $result_img

         }

      }

   }

   set img_list [::bddimages_liste_gui::add_info_cata_list $img_list]

   return [lindex $img_list 0]
}




#--------------------------------------------------
#  intellilist_to_imglist_i { }
#--------------------------------------------------
#
#    fonction  :
#       construit la requete sql generale
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste des images
#
#--------------------------------------------------
proc ::bddimages_liste_gui::intellilist_to_imglist_i { intellilist } {

   # Itere sur les idhd
   set sqlcmd "SELECT DISTINCT idheader FROM header;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "Erreur de lecture de la table header par SQL"
      bddimages_sauve_fich "   sqlcmd = $sqlcmd"
      bddimages_sauve_fich "   err = $err"
      bddimages_sauve_fich "   msg = $msg"
      return
   }

   set img_list ""
   set nb_img_list [llength $resultsql]

   # LIMIT
   set choix_limit_result [get_val_intellilist $intellilist "choix_limit_result"]
   set limit_result       [get_val_intellilist $intellilist "limit_result"]


   set cpt 0
   foreach line $resultsql {

      incr cpt
      ::bddimages_recherche::set_progress $cpt $nb_img_list

      set idhd [lindex $line 0]

      # lecture des valeurs de chaque champ
      set sqlcritere [::bddimages_liste_gui::get_sqlcritere $intellilist "images_$idhd"]
      set sqlcmd "SELECT images.idbddimg,
                         images.idheader,
                         images.tabname,
                         images.filename,
                         images.dirfilename,
                         images.sizefich,
                         images.datemodif,
                         commun.datejj as commundatejj,
                         images_$idhd.*
                  FROM images, images_$idhd, commun
                  WHERE images.idbddimg = images_$idhd.idbddimg
                  AND   commun.idbddimg = images_$idhd.idbddimg
                  $sqlcritere;"


      set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
      if {![string first "Unknown column" $msg]==-1||$err} {
         continue
      }

      set nbresult [llength $resultcount]

      if {$nbresult>0} {

         set tabkey [::bddimages_liste_gui::idhd_to_tabkey $idhd]
         set colvar [lindex $resultcount 0]
         set rowvar [lindex $resultcount 1]
         set nbcol  [llength $colvar]

         foreach keyline $rowvar {

            set result_img ""

            # Common fields to manage BDI

                # idbddimg
                set key [lindex $colvar 8]
                set val [lindex $keyline 8]
                lappend result_img [list $key $val]

                # others...
                for {set id 1} {$id<=7} {incr id} {
                   set key [lindex $colvar $id]
                   set val [lindex $keyline $id]
                   lappend result_img [list $key $val]
                }

            #  TABKEY
                for {set id 9} {$id<$nbcol} {incr id} {
                   set key [lindex $colvar $id]
                   set val [lindex $keyline $id]
                   if {[::bddimages_liste::lexist $tabkey $key ]} {
                      set inline [lreplace [::bddimages_liste::lget $tabkey $key] 1 1 $val]
                      set tabkey [::bddimages_liste::lupdate $tabkey $key $inline]
                   }
                }


            lappend result_img [list "tabkey" $tabkey]
            lappend img_list $result_img

            # LIMIT
            if {$choix_limit_result} {
               if {[llength $img_list]==$limit_result} {
                  break
               }
            }

         # Boucle for
         }

      }

   # LIMIT
   if {$choix_limit_result} {
      if {[llength $img_list]==$limit_result} {
         break
      }
   }

   # Boucle for
   }

   set img_list [::bddimages_liste_gui::add_info_cata_list $img_list]

   #::console::affiche_erreur " img_list = $img_list\n"
   return $img_list
}








#--------------------------------------------------
#  add_info_cata_list { img_list }
#--------------------------------------------------
#
#    fonction  :
#       Ajoute les info de la base concernant les catas
#
#    procedure externe :
#
#    variables en entree :
#        img_list : liste image
#
#    variables en sortie :
#        img_list : liste image avec les champs cata en plus
#
#--------------------------------------------------
proc ::bddimages_liste_gui::add_info_cata_list { img_list } {


   set sqlcmd "SELECT cataimage.idbddimg,
                      catas.idbddcata,
                      catas.filename as catafilename,
                      catas.dirfilename as catadirfilename,
                      catas.sizefich as catasizefich,
                      catas.datemodif as catadatemodif
               FROM cataimage, catas
               WHERE cataimage.idbddcata = catas.idbddcata
               AND cataimage.idbddimg IN ("
   set cpt 0
   foreach img $img_list {
      set idbddimg [::bddimages_liste::lget $img "idbddimg"]
      if {$cpt == 0} {
         set sqlcmd "$sqlcmd $idbddimg"
      } else {
         set sqlcmd "$sqlcmd, $idbddimg"
      }
      incr cpt
   }
   set sqlcmd "$sqlcmd )"

   set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]

   #::console::affiche_erreur "SELECT $err $msg\n"

   if {$err} {
       # si l erreur est qu il n y a pas de table cata alors traiter ce cas special
       set resultcount 0
       set err 0
   }

   if {$err} {
      ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
      ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
      ::console::affiche_erreur "        err = $err\n"
      ::console::affiche_erreur "        msg = $msg\n"
      return
   }
   set nbresult [llength $resultcount]

   if {$nbresult > 0} {
      set colvar [lindex $resultcount 0]
      set rowvar [lindex $resultcount 1]
      set nbcol  [llength $colvar]
      set keys [list idbddcata catafilename catadirfilename catasizefich catadatemodif]
      foreach line $rowvar {
         set idbddimg [lindex $line 0]
         foreach key $keys  {
            set cata($idbddimg,$key) [lindex $line [lsearch $colvar $key]]
         }
      }
   }

   set result_img_list ""
   foreach img $img_list {
      set idbddimg [::bddimages_liste::lget $img "idbddimg"]
      if {[info exists cata($idbddimg,idbddcata)]} {
         set cata($idbddimg,cataexist) 1
         set cata($idbddimg,cataloaded) 0
         foreach key $keys  {
            set pos [lsearch -index 0 $img $key]
            if {$pos != -1 } {
               set img [lreplace $img $pos $pos [list $key $cata($idbddimg,$key)]]
            } else {
               lappend img [list $key $cata($idbddimg,$key)]
            }
         }
      } else {
         set cata($idbddimg,cataexist) 0
         set cata($idbddimg,cataloaded) 0
      }

      set pos [lsearch -index 0 $img cataexist]
      if {$pos != -1 } {
         set img [lreplace $img $pos $pos [list cataexist $cata($idbddimg,cataexist)]]
      } else {
         lappend img [list cataexist $cata($idbddimg,cataexist)]
      }
      set pos [lsearch -index 0 $img cataloaded]
      if {$pos != -1 } {
         set img [lreplace $img $pos $pos [list cataloaded $cata($idbddimg,cataloaded)]]
      } else {
         lappend img [list cataloaded $cata($idbddimg,cataloaded)]
      }

      lappend result_img_list $img
      incr cpt
   }


   return $result_img_list
}






proc ::bddimages_liste_gui::add_info_cata { img } {

   if {[::bddimages_liste::lexist $img "idbddimg" ] == 0} {
      return -code 1 "Champs idbddimg inexistant dans l image\n"
   }


   set idbddimg [::bddimages_liste::lget $img "idbddimg"]
   set sqlcmd "SELECT
                      catas.idbddcata,
                      catas.filename as catafilename,
                      catas.dirfilename as catadirfilename,
                      catas.sizefich as catasizefich,
                      catas.datemodif as catadatemodif
               FROM cataimage, catas
               WHERE cataimage.idbddcata = catas.idbddcata
               AND cataimage.idbddimg AND cataimage.idbddimg=$idbddimg"

   set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
   if {$err} {
      ::console::affiche_erreur "Erreur de lecture des infos du cata \n"
      ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
      ::console::affiche_erreur "        err = $err\n"
      ::console::affiche_erreur "        msg = $msg\n"
      ::console::affiche_erreur "        idbddimg = $idbddimg\n"
      return
   }

   set nbresult [expr [llength $resultcount]-1]

   #::console::affiche_erreur "RESULT $resultcount\n"
   #::console::affiche_erreur "ERR $err\n"
   #::console::affiche_erreur "MSG $msg\n"
   #::console::affiche_erreur "nb $nbresult\n"
   #::console::affiche_erreur "0=[lindex $resultcount 0]\n"
   #::console::affiche_erreur "1=[lindex $resultcount 1]\n"
   #::console::affiche_erreur "1=[lindex [lindex $resultcount 1] 0]\n"

   if {$err} {
       # si l erreur est qu il n y a pas de table cata alors traiter ce cas special
       set resultcount 0
       set err 0
   }

   if {$err} {
      ::console::affiche_erreur "Erreur de lecture de la liste des header par SQL\n"
      ::console::affiche_erreur "        sqlcmd = $sqlcmd\n"
      ::console::affiche_erreur "        err = $err\n"
      ::console::affiche_erreur "        msg = $msg\n"
      return
   }

   if {$nbresult > 0} {

      set r [lindex [lindex $resultcount 1] 0]
      set idbddcata       [lindex $r 0]
      set catafilename    [lindex $r 1]
      set catadirfilename [lindex $r 2]
      set catasizefich    [lindex $r 3]
      set catadatemodif   [lindex $r 4]
      set img [::bddimages_liste::ladd $img cataexist 1]
      set img [::bddimages_liste::ladd $img cataloaded 0]
      set img [::bddimages_liste::ladd $img idbddcata        $idbddcata]
      set img [::bddimages_liste::ladd $img catafilename     $catafilename]
      set img [::bddimages_liste::ladd $img catadirfilename  $catadirfilename]
      set img [::bddimages_liste::ladd $img catasizefich     $catasizefich]
      set img [::bddimages_liste::ladd $img catadatemodif    $catadatemodif]

   } else {

      lappend img [list cataexist 0]
      lappend img [list cataloaded 0]

   }

   return $img
}




#--------------------------------------------------
#  calcul_nbimg { }
#--------------------------------------------------
#
#    fonction  :
#       fournit la liste des conditions de la requete
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : liste
#
#--------------------------------------------------
proc ::bddimages_liste_gui::calcul_nbimg { } {

   global ::bddimages_liste_gui::form_req

   set intellilist [::bddimages_liste_gui::build_intellilist "calcul_nbimg"]

   set ::bddimages_liste_gui::form_req(nbimg) [llength [::bddimages_liste_gui::intellilist_to_imglist $intellilist]]
   #::console::affiche_resultat "Nb img = $form_req(nbimg) \n"
   return
}





#--------------------------------------------------
#  remove_requete { }
#--------------------------------------------------
#
#    fonction  :
#       efface une requete
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : none
#
#--------------------------------------------------
proc ::bddimages_liste_gui::remove_requete { } {

   variable This
   global indicereq
   global list_req
   global framereqcurrent

   set i $indicereq
   for {set x 1} {$x<=$indicereq} {incr x} {
      set err [catch {set a [$This.framereq.$x.sup cget -state]} msg ]
      if {!$err} {
         if {$a == "active" } {set i $x}
      }
   }

   set list_req($i,valide) "no"
   destroy $framereqcurrent.framereq.$i

}





#--------------------------------------------------
#  add_requete { }
#--------------------------------------------------
#
#    fonction  :
#       ajout d'une requete
#
#    procedure externe :
#
#    variables en entree : none
#
#    variables en sortie : none
#
#--------------------------------------------------
proc ::bddimages_liste_gui::add_requete { } {

   variable This
   global audace
   global caption
   global indicereq
   global list_req
   global framereqcurrent

   #--- Initialisation des combox
   set result [::bddimages_liste_gui::get_list_box_champs]
   set list_box_champs [lindex $result 1]
   set nbrows1 [ llength $list_box_champs ]
   set nbcols1 [lindex $result 0]
   set list_combobox [get_list_combobox]
   set nbrows2 [ llength $list_combobox ]
   set nbcols2 13

   #--- frame pour afficher les requetes
   set frch $framereqcurrent.framereq

   #--- Initialisation de la liste des requetes
   set indicereq [expr $indicereq + 1]

   if { [ info exists list_req($indicereq,champ) ] } {
      gren_debug "yes $list_req($indicereq,champ) $indicereq\n"
      set list_req($indicereq,valide) "ok"
      if { $list_req($indicereq,condition) eq "LIKE" } {
         set list_req($indicereq,condition) $caption(bddimages_liste,contient)
         set list_req($indicereq,valeur) [string trim $list_req($indicereq,valeur) %]
      } elseif { $list_req($indicereq,condition) eq "NOT LIKE" } {
         set list_req($indicereq,condition) $caption(bddimages_liste,notcontient)
         set list_req($indicereq,valeur) [string trim $list_req($indicereq,valeur) %]
      }
   } else {
      set list_req($indicereq,champ)     [lindex $list_box_champs 0]
      set list_req($indicereq,condition) [lindex $list_combobox 0]
      set list_req($indicereq,valeur) ""
      set list_req($indicereq,valide) "ok"
   }

   #--- Cree un frame pour la requete
   set frchch $frch.$indicereq
   frame $frchch -borderwidth 1 -relief solid
   pack $frchch -in $frch -anchor w -side top -expand 0 -padx 5 -pady 0

      #--- Cree la liste des champs
      ComboBox $frchch.combo1 \
         -width $nbcols1 -height 20 \
         -relief sunken -borderwidth 0 -editable 0 \
         -textvariable list_req($indicereq,champ) \
         -values $list_box_champs
      pack $frchch.combo1 -anchor center -side left -fill x -expand 1
      #--- Cree la liste des conditions
      ComboBox $frchch.combo \
         -width $nbcols2 -height $nbrows2 \
         -relief sunken -borderwidth 0 -editable 0 \
         -textvariable list_req($indicereq,condition) \
         -values $list_combobox
      pack $frchch.combo -anchor center -side left -fill x -expand 1
      #--- Cree une ligne d'entree pour la variable
      entry $frchch.dat -textvariable list_req($indicereq,valeur) -borderwidth 1 -relief groove -width 20 -justify left
      pack $frchch.dat -in $frchch -side left -anchor w -padx 1
      #--- Cree un bouton supprime requete
      button $frchch.sup -state normal -borderwidth 1 -relief groove -anchor c -text "-" \
         -command { ::bddimages_liste_gui::remove_requete }
      pack $frchch.sup -in $frchch -side left -anchor w -padx 1
      #--- Cree un bouton ajout requete
      button $frchch.add -state active -borderwidth 1 -relief groove -anchor c -text "+" \
         -command { ::bddimages_liste_gui::add_requete }
      pack $frchch.add -in $frchch -side left -anchor w -padx 1

   return
}






#--------------------------------------------------
#  ouvreCalendrier { }
#--------------------------------------------------
#
#    fonction  :
#       Ouverture d'un popup de selection d'une date
#
#    variables en entree :
#        x y         position de la fenetre du calendrier
#        clockformat format d'affichage de la date (e.g. "%Y.%m.%d")
#        wdate       nom de la variable contenant la date choisie dans le calendrier
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_liste_gui::ouvreCalendrier { x y clockformat wdate } {

   variable This
   global langage

   # Langage de l'utilisateur (defaut: en)
   set userLang "en"
   set calendarLang [list de en fr it nl ru sv pt]
   set ulang [string range $langage 0 1]
   foreach lang $calendarLang {
      if {[string compare $lang $ulang] == "0"} {
         set userLang $ulang
      }
   }

   # Fenetre du calendrier
   set w [toplevel $This.calendar]
   wm overrideredirect $w 1
   frame $w.f -borderwidth 2 -relief solid -takefocus 0
   ::bdi_tools_calendar::chooser $w.f.d -language $userLang -mon 0 \
          -command [list set ::SEMA close] \
          -textvariable $wdate -clockformat $clockformat
   pack $w.f.d $w.f
   lassign [winfo pointerxy .] x y
   wm geometry $w "+${x}+${y}"

   set _w [grab current]
   if {$_w ne {} } {
      grab release $_w
      grab set $w
   }

   set ::SEMA ""
   tkwait variable ::SEMA

   if {$_w ne {} } {
      grab release $w
      grab set $_w
   }
   destroy $w
}






#--------------------------------------------------
#  createDialog { }
#--------------------------------------------------
#
#    fonction  :
#       Creation de l'interface graphique
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_liste_gui::createDialog { listname } {

   variable This
   global audace
   global caption
   global color
   global conf
   global bddconf
   global intellilisttotal
   global indicereq
   global ::bddimages_liste_gui::form_req
   global list_req
   global framereqcurrent


   set list_comb1 [list $caption(bddimages_liste,toutes) $caption(bddimages_liste,nimporte)]
   set list_comb2 [list $caption(bddimages_liste,elem)]
   set list_comb3 [list $caption(bddimages_liste,alea) \
                        $caption(bddimages_liste,dateobs) \
                        $caption(bddimages_liste,telescope) \
                        $caption(bddimages_liste,plrecmod) \
                        $caption(bddimages_liste,morecmod) \
                        $caption(bddimages_liste,plrecajo) \
                        $caption(bddimages_liste,morecajo) ]

   set ::bddimages_liste_gui::form_req(name) "Newlist[ expr $::nbintellilist + 1 ]"
   set ::bddimages_liste_gui::form_req(type_req_check) ""
   set ::bddimages_liste_gui::form_req(datemin) ""
   set ::bddimages_liste_gui::form_req(datemax) ""
   set ::bddimages_liste_gui::form_req(midi) "12"
   set ::bddimages_liste_gui::form_req(type_req_check) 1
   set ::bddimages_liste_gui::form_req(type_requ) [lindex $list_comb1 0]
   set ::bddimages_liste_gui::form_req(choix_limit_result) 0
   set ::bddimages_liste_gui::form_req(limit_result) "25"
   set ::bddimages_liste_gui::form_req(type_result) [lindex $list_comb2 0]
   set ::bddimages_liste_gui::form_req(type_select) [lindex $list_comb3 0]
   set ::bddimages_liste_gui::form_req(nbimg) "?"

   set edit [expr {$listname eq "?" ? 0 : 1}]

   if { $edit } {

      set editname $listname
      set editid [::bddimages_liste_gui::get_intellilist_by_name $listname]
      ::bddimages_liste_gui::load_intellilist $intellilisttotal($editid)
      ::bddimages_liste_gui::affiche_intellilist $intellilisttotal($editid)
      ::bddimages_liste_gui::affich_form_req
      set indicereqinit [llength [get_val_intellilist $intellilisttotal($editid) "reqlist"]]
      #gren_info "\n ** indicereqinit= $indicereqinit\n"
      #gren_info "\n ** indicereq= $indicereq\n"
      #gren_info "\n ** list_req= [array get list_req]\n"
      #set l $intellilisttotal($editid)
      #::console::affiche_resultat "edit : $edit\n"
      #::console::affiche_resultat "l : $l\n"
      #::bddimages_liste_gui::load_intellilist $l
      #parray ::bddimages_liste_gui::form_req
      #if { [info exists list_req ] } then { parray list_req }

   } else {

      set indicereqinit 0
      array unset list_req

   }
   set indicereq 0

   #--- initConf
   if { ! [ info exists conf(bddimages,list_pos_stat) ] } { set conf(bddimages,list_pos_stat) "+80+40" }

   #--- confToWidget
   set bddconf(list_pos_stat) $conf(bddimages,list_pos_stat)

   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      return
   }

   #---
   if { [ info exists bddconf(list_geom_stat) ] } {
      set deb [ expr 1 + [ string first + $bddconf(list_geom_stat) ] ]
      set fin [ string length $bddconf(list_geom_stat) ]
      set bddconf(list_geom_stat) "+[ string range $bddconf(list_geom_stat) $deb $fin ]"
   }

   #---
   toplevel $This -class Toplevel
   wm geometry $This $bddconf(list_pos_stat)
   wm resizable $This 1 1
   wm title $This $caption(bddimages_liste,main_title)
   wm protocol $This WM_DELETE_WINDOW { ::bddimages_liste_gui::fermer }

   #--- Cree un frame pour le titre
   set framecurrent $This.title
   frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
   pack $framecurrent -in $This -anchor s -side top -expand 1 -fill x -padx 5 -pady 5
     #--- Cree un label
     label $framecurrent.titre -font $bddconf(font,arial_12_b) -text "$caption(bddimages_liste,title)"
     pack $framecurrent.titre -in $framecurrent -side top -padx 5 -pady 5

   #--- Cree un frame pour le nom de la liste
   set framecurrent $This.framename
   frame $framecurrent -borderwidth 1 -cursor arrow -relief flat
   pack $framecurrent -in $This -anchor c -side top -expand 0 -padx 5 -pady 5
     #--- Cree un label
     label $framecurrent.lab -text "$caption(bddimages_liste,nom)" -width 20
     pack $framecurrent.lab -in $framecurrent -side left -anchor w -padx 1
     #--- Cree une ligne d'entree pour la variable
     entry $framecurrent.dat -textvariable ::bddimages_liste_gui::form_req(name) -borderwidth 1 -relief groove -width 25 -justify left
     pack $framecurrent.dat -in $framecurrent -side left -anchor w -padx 1

   #--- Cree un frame pour le choix de date min et max
   image create photo icon_calendar
   icon_calendar configure -file [file join $audace(rep_plugin) tool bddimages icons calendar.gif]
   image create photo icon_clean
   icon_clean configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
   set clockformat "%Y-%m-%d"
   set framecurrent $This.datemindatemax
   frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
   pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

      # Date START
      frame $framecurrent.datemin -borderwidth 0 -cursor arrow
      pack $framecurrent.datemin -in $framecurrent -anchor w -side top -expand 0 -fill both -padx 3 -pady 3
         #--- Cree un label
         label $framecurrent.datemin.lab -text "DATE-OBS start" -width 20
         pack $framecurrent.datemin.lab -in $framecurrent.datemin -side left -anchor w -padx 1
         #--- Cree une ligne d'entree pour la variable ::bddimages_liste_gui::form_req(datemin)
         entry $framecurrent.datemin.date -textvariable ::bddimages_liste_gui::form_req(datemin) -borderwidth 1 -relief groove  -justify left
         pack $framecurrent.datemin.date -in $framecurrent.datemin -side left -anchor w -padx 1
         #--- Creation du bouton d'acces au calendrier graphique
         button $framecurrent.datemin.calstart -image icon_calendar -borderwidth 1 \
            -command [list ::bddimages_liste_gui::ouvreCalendrier %X %Y $clockformat ::bddimages_liste_gui::form_req(datemin)]
         pack $framecurrent.datemin.calstart -in $framecurrent.datemin -side left -anchor e -padx 2 -pady 2 -expand 0
         #--- Creation du bouton de remise a zero de ::bddimages_liste_gui::form_req(datemin)
         button $framecurrent.datemin.cleanstart -image icon_clean -borderwidth 1 \
            -command { set ::bddimages_liste_gui::form_req(datemin) "" }
         pack $framecurrent.datemin.cleanstart -in $framecurrent.datemin -side left -anchor e -padx 2 -pady 2 -expand 0

      # Date STOP
      frame $framecurrent.datemax -borderwidth 0 -cursor arrow
      pack $framecurrent.datemax -in $framecurrent -anchor w -side top -expand 0 -fill both -padx 3 -pady 3
         #--- Cree un label
         label $framecurrent.datemax.lab -text "DATE-OBS stop" -width 20
         pack $framecurrent.datemax.lab -in $framecurrent.datemax -side left -anchor w -padx 1
         #--- Cree une ligne d'entree pour la variable ::bddimages_liste_gui::form_req(datemax)
         entry $framecurrent.datemax.date -textvariable ::bddimages_liste_gui::form_req(datemax) -borderwidth 1 -relief groove -justify left
         pack $framecurrent.datemax.date -in $framecurrent.datemax -side left -anchor w -padx 1
         #--- Creation du bouton d'acces au calendrier graphique
         button $framecurrent.datemax.calstop -image icon_calendar -borderwidth 1 \
            -command [list ::bddimages_liste_gui::ouvreCalendrier %X %Y $clockformat ::bddimages_liste_gui::form_req(datemax)]
         pack $framecurrent.datemax.calstop -in $framecurrent.datemax -side left -anchor e -padx 2 -pady 2 -expand 0
         #--- Creation du bouton de remise a zero de ::bddimages_liste_gui::form_req(datemax)
         button $framecurrent.datemax.cleanstart -image icon_clean -borderwidth 1 \
            -command { set ::bddimages_liste_gui::form_req(datemax) "" }
         pack $framecurrent.datemax.cleanstart -in $framecurrent.datemax -side left -anchor e -padx 2 -pady 2 -expand 0

      # Midi
      frame $framecurrent.midi -borderwidth 0 -cursor arrow
      pack $framecurrent.midi -in $framecurrent -anchor w -side top -expand 0 -fill both -padx 3 -pady 3
         #--- Cree un label
         label $framecurrent.midi.lab -text "Heure UT du Midi local (h)" -width 20
         pack $framecurrent.midi.lab -in $framecurrent.midi -side left -anchor w -padx 1
         #--- Cree une ligne d'entree pour la variable ::bddimages_liste_gui::form_req(datemax)
         entry $framecurrent.midi.h -textvariable ::bddimages_liste_gui::form_req(midi) -borderwidth 1 -relief groove -justify left -width 4
         pack $framecurrent.midi.h -in $framecurrent.midi -side left -anchor w -padx 1

   #--- Cree un frame pour afficher le type de logique AND / OR
   set framecurrent $This.frame1
   frame $framecurrent -borderwidth 0 -cursor arrow
   pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

      #--- Bouton a cocher
      checkbutton $framecurrent.check -highlightthickness 0 -state normal -variable ::bddimages_liste_gui::form_req(type_req_check) -command { }
      pack $framecurrent.check -in $framecurrent -side left -anchor center -padx 5
      #--- Cree un label
      label $framecurrent.txt1 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,repondrea)"
      pack $framecurrent.txt1 -in $framecurrent -side left -anchor w -padx 1
      #--- Cree un combox pour le choix
      ComboBox $framecurrent.combo1 \
          -width 20 -height 2 -font $bddconf(font,arial_10_b)\
          -relief raised -borderwidth 1 -editable 0 \
          -textvariable ::bddimages_liste_gui::form_req(type_requ) \
          -values $list_comb1
      pack $framecurrent.combo1 -anchor center -side left -fill x -expand 0
      #--- Cree un label
      label $framecurrent.txt2 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,regles)"
      pack $framecurrent.txt2 -in $framecurrent -side left -anchor w -padx 1

   #--- Cree un frame pour ajouter des requetes
   set framereqcurrent $This.addreq
   frame $framereqcurrent -borderwidth 0 -cursor arrow
   pack $framereqcurrent -in $This -anchor s -side top -fill x -padx 5 -pady 5

      #--- Cree un bouton d'ajout de requete
      button $framereqcurrent.add -state active -borderwidth 1 -width 45 -text "$caption(bddimages_liste,addrule)" \
         -command { ::bddimages_liste_gui::add_requete }
      pack $framereqcurrent.add -in $framereqcurrent -side top -padx 5 -pady 5

      #--- Cree un frame pour afficher les requetes
      frame $framereqcurrent.framereq -borderwidth 0 -cursor arrow
      pack $framereqcurrent.framereq -in $framereqcurrent -anchor s -side top -expand 1 -fill both
      #--- Ajout des requetes
      for { set x 0 } { $x < $indicereqinit } { incr x } {
         ::bddimages_liste_gui::add_requete
      }

   #--- Cree un frame pour les options
   set framecurrent $This.frame2
   frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
   pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

      #--- Check button
      frame $framecurrent.1 -borderwidth 0 -cursor arrow
      pack $framecurrent.1 -in $framecurrent -anchor n -side left -expand 1 -fill x -padx 1 -pady 5
         #--- Bouton check
         checkbutton $framecurrent.1.check -highlightthickness 0 -state normal -variable ::bddimages_liste_gui::form_req(choix_limit_result) -command { }
         pack $framecurrent.1.check -in $framecurrent.1 -side left -anchor c -padx 5

      #--- Options:
      frame $framecurrent.2 -borderwidth 0 -cursor arrow
      pack $framecurrent.2 -in $framecurrent -anchor s -side left -expand 1 -fill x -padx 1 -pady 3

         #--- limite a
         frame $framecurrent.2.l -borderwidth 0 -cursor arrow
         pack $framecurrent.2.l -in $framecurrent.2 -anchor c -side top -expand 1 -fill x -padx 1 -pady 3
            #--- Cree un label
            label $framecurrent.2.l.txt1 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,limitera)"
            pack $framecurrent.2.l.txt1 -in $framecurrent.2.l -side left -anchor w -padx 2
            #--- Cree une ligne d'entree pour la variable
            entry $framecurrent.2.l.dat -textvariable ::bddimages_liste_gui::form_req(limit_result) -borderwidth 1 -relief groove -width 8 -justify center
            pack $framecurrent.2.l.dat -in $framecurrent.2.l -side left -anchor w -padx 2
            #--- Cree un combox pour le choix
            ComboBox $framecurrent.2.l.combo \
                -width 10 -height 1 \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::bddimages_liste_gui::form_req(type_result) \
                -values $list_comb2
            pack $framecurrent.2.l.combo -in $framecurrent.2.l -anchor center -side left -fill x -expand 0
         #--- selection
         frame $framecurrent.2.s -borderwidth 0 -cursor arrow
         pack $framecurrent.2.s -in $framecurrent.2 -anchor c -side top -expand 1 -fill x -padx 1 -pady 3
            #--- Cree un label
            label $framecurrent.2.s.txt2 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,selectpar)"
            pack $framecurrent.2.s.txt2 -in $framecurrent.2.s -side left -anchor w -padx 2
            #--- Cree un combox pour le choix
            ComboBox $framecurrent.2.s.combo2 \
                -width 27 -height 7 \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::bddimages_liste_gui::form_req(type_select) \
                -values $list_comb3
            pack $framecurrent.2.s.combo2 -in $framecurrent.2.s -anchor center -side left -fill x -expand 0

   #--- Cree un frame pour le calcul du nombre d images
   set framecurrent $This.frame3
   frame $framecurrent -borderwidth 0 -cursor arrow
   pack $framecurrent -in $This -anchor s -side top -expand 0 -padx 5 -pady 5

      #--- Cree un label
      label $framecurrent.txt1 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_liste,nbresreq)"
      pack $framecurrent.txt1 -in $framecurrent -side left -anchor w -padx 1
      #--- Cree une ligne d'entree pour la variable
      entry $framecurrent.dat -textvariable ::bddimages_liste_gui::form_req(nbimg) -state readonly -borderwidth 1 -relief groove -width 8 -justify center
      pack $framecurrent.dat -in $framecurrent -side left -anchor w -padx 1
      #--- Cree un bouton ajout requete
      button $framecurrent.calc -state active -borderwidth 1 -relief groove -anchor c -text "$caption(bddimages_liste,calcul)" \
         -command { ::bddimages_liste_gui::calcul_nbimg }
      pack $framecurrent.calc -in $framecurrent -side left -anchor w -padx 1

   #--- Cree un frame pour y mettre les boutons
   frame $This.frame11 -borderwidth 0 -cursor arrow
   pack $This.frame11 -in $This -anchor s -side bottom -expand 0 -fill x -pady 5

      #--- Creation du bouton annuler
      button $This.frame11.but_annuler -text "$caption(bddimages_liste,annuler)" -borderwidth 2 \
           -command { ::bddimages_liste_gui::fermer }
      pack $This.frame11.but_annuler -in $This.frame11 -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0
      #--- Creation du bouton annuler
      button $This.frame11.but_sauver -text "$caption(bddimages_liste,sauver)" -borderwidth 2 \
           -command { ::bddimages_liste_gui::save }
      pack $This.frame11.but_sauver -in $This.frame11 -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0
      #--- Creation du bouton ok
      button $This.frame11.but_ok -text "$caption(bddimages_liste,ok)" -borderwidth 2 \
           -command { ::bddimages_liste_gui::accept } -state disabled
      pack $This.frame11.but_ok -in $This.frame11 -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0
      #--- Creation du bouton aide
      button $This.frame11.but_aide -text "$caption(bddimages_liste,aide)" -borderwidth 2 \
           -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
      pack $This.frame11.but_aide -in $This.frame11 -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}
