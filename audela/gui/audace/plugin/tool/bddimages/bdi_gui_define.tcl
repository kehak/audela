## @file bdi_gui_define.tcl
#  @brief     GUI de gestion des mots cl&eacute;s des ent&ecirc;tes FITS
#  @author    Frederic Vachier
#  @date      2016
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_define.tcl]
#  @endcode
#  @version   2.0

# $Id: bdi_gui_define.tcl 13886 2016-05-22 21:55:06Z jberthier $

##
# @defgroup bdi_notice_fr BDI
#
# @defgroup bdi_define_presentation Presentation
# Cet outil permet de gerer les mots cles des header fits dans les images
# @ingroup bdi_notice_fr
#
# @section bdi_define_presentation Presentation
# La modification de donnees ne s'effectue qu'apres avoir appuyer sur le bouton "Appliquer".
# Avant cela, l'outil permet de programmer
# toutes les actions qui devront etre effectuees. Les differentes parties de l'outil se distinguent comme suit :
#
# - <b> Liste des actions </b>: Au fur et a mesure que les actions sont choisies, il apparait
# dans cette liste le travail qui devra etre fait.
# Il y a la possibilite de supprimer tout ou une partie de cette liste par l'action d'un clic gauche.
#
# - <b> Selection </b>: permet de choisir les images dans la liste "Recherche" sur lesquelles
# seront appliquees les actions suivantes
#
# - <b> Onglets </b>: Permet de choisir le type d'action a effectuer : Ajout, Modification et
# Suppression d'un mot-cle. Mais aussi des actions rapide
# comme les mots-cles BDI, ou les champs necessaire au calcul du WCS.
#
# - <b> Boutons d'action </b>: Ferme l'application, ou applique les modifications.
#
# @todo Choses a faire
# - Onglet rapide concernant les donnees meteo
# - Modifier aussi les champs du cata s'il est disponible
# .

##
# @namespace bdi_gui_define
# @brief GUI de gestion des mots cl&eacute;s des ent&ecirc;tes FITS
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_define {

}

#------------------------------------------------------------
## @brief Mise a jour des scripts et de la GUI de cet outil
#
proc ::bdi_gui_define::recharge { } {
   ::bdi_gui_define::ressource
   ::bdi_gui_define::fermer
   ::bdi_gui_define::run
   return
}

#------------------------------------------------------------
## @brief Mise a jour des scripts de cet outil
#
proc ::bdi_gui_define::ressource { } {
   ::bddimages::ressource
   return
}

#------------------------------------------------------------
## @brief Fermeture de l'outil
#
proc ::bdi_gui_define::fermer { } {
   destroy $::bdi_gui_define::fen
   unset ::bdi_gui_define::fen
   return
}

#------------------------------------------------------------
## @brief Lancement de la GUI de l'outil
#
proc ::bdi_gui_define::run { } {

   global conf
   global bddconf
   global caption

   if { ! [info exists conf(bddimages,define,geometry)] } { set conf(bddimages,define,geometry) "+165+55" }

   set ::bdi_gui_define::fen .define
   if { [winfo exists $::bdi_gui_define::fen] } {
      wm withdraw $::bdi_gui_define::fen
      wm deiconify $::bdi_gui_define::fen
      focus $::bdi_gui_define::fen
      return
   }

   toplevel $::bdi_gui_define::fen -class Toplevel
   wm geometry $::bdi_gui_define::fen $conf(bddimages,define,geometry)
   wm resizable $::bdi_gui_define::fen 1 1
   wm title $::bdi_gui_define::fen "Modification du header V2"
   wm protocol $::bdi_gui_define::fen WM_DELETE_WINDOW "::bdi_gui_define::fermer"

   set width_entry 25
   set width_bdi   25
   set ::bdi_gui_define::nb_sel 0

   set r [::bdi_tools_define::get_list_box_champs]
   set width_key       [lindex $r 0]
   set list_box_champs [lindex $r 1]

   set frm $::bdi_gui_define::fen.appli
   frame $frm  -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_define::fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5

      # Boutons dev
      set wa [frame $frm.wa ]
      pack $wa -in $frm -side bottom

         button $wa.rec -text "Recharge" -borderwidth 2 -takefocus 1 \
                      -command "::bdi_gui_define::recharge"
         pack   $wa.rec -side left -padx 3 -pady 3 -anchor w
         button $wa.res -text "Resource" -borderwidth 2 -takefocus 1 \
                      -command "::bdi_gui_define::ressource"
         pack   $wa.res -side left -padx 3 -pady 3 -anchor w
         button $wa.app -text "Appliquer" -borderwidth 2 -takefocus 1 \
                      -command "::bdi_tools_define::apply"
         pack   $wa.app -side left -padx 3 -pady 3 -anchor w
         button $wa.clo -text "Fermer" -borderwidth 2 -takefocus 1 \
                      -command "::bdi_gui_define::fermer"
         pack   $wa.clo -side left -padx 3 -pady 3 -anchor w

      # Table
      set wf [frame $frm.lst  -relief groove]
      pack $wf -in $frm -side top -expand yes -fill both

         set cols [list 0 "NbImg"   left  \
                        0 "Action"  left  \
                        0 "Key"     left  \
                        0 "Values"  left  \
                        0 "Type"    left  \
                        0 "Unit"    left  \
                        0 "Comment" left  \
                        0 "lsel"    left  \
                  ]

         set ::bdi_gui_define::worklist $wf.table
         tablelist::tablelist $::bdi_gui_define::worklist \
           -columns $cols \
           -width 0 \
           -xscrollcommand [ list $wf.hsb set ] \
           -yscrollcommand [ list $wf.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $wf.hsb -orient horizontal -command [list $::bdi_gui_define::worklist xview]
         pack $wf.hsb -in $wf -side bottom -fill x
         scrollbar $wf.vsb -orient vertical -command [list $::bdi_gui_define::worklist yview]
         pack $wf.vsb -in $wf -side right -fill y

         # Popup
         set popupTbl $::bdi_gui_define::worklist.popupTbl
         menu $popupTbl -title "Selection"
            $popupTbl add command -label "Supprimer" -command "::bdi_gui_define::worklist_del"
            $popupTbl add command -label "TOUT Supprimer" -command "::bdi_gui_define::worklist_del_all"

         # Pack la Table
         pack $::bdi_gui_define::worklist -in $wf -expand yes -fill both

         # Binding
         #bind $::bdi_gui_define::worklist <<ListboxSelect>> [ list ::constructions::cmdButton1Click %W ]
         bind [$::bdi_gui_define::worklist bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

         #    HIDE
         foreach ncol [list "lsel"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_define::worklist columnconfigure $pcol -hide yes
         }

      # Select
      set wf [frame $frm.sel -padx 5 -pady 5]
      pack $wf -in $frm -side top -anchor center -expand no -fill both

         button $wf.ap -text "Select" -borderwidth 2 -takefocus 1 -command "::bdi_gui_define::select_img"
         label  $wf.l1 -text "Nb img selectionnees : "
         label  $wf.l2 -textvariable ::bdi_gui_define::nb_sel
         grid   $wf.ap $wf.l1 $wf.l2 -in $wf -padx 5 -pady 2 -sticky nsew

      # Onglets
      set onglets [frame $frm.onglets] 
      pack $onglets -in $frm -side top -anchor center -expand yes -fill both
      pack [ttk::notebook $onglets.nb] -expand no

         set f_add [frame $onglets.nb.f_add]
         set f_mod [frame $onglets.nb.f_mod]
         set f_del [frame $onglets.nb.f_del]
         set f_img [frame $onglets.nb.f_img]
         set f_bdi [frame $onglets.nb.f_bdi]
         set f_cal [frame $onglets.nb.f_cal]

         $onglets.nb add $f_add -text "Ajout"
         $onglets.nb add $f_mod -text "Modification"
         $onglets.nb add $f_del -text "Suppression"
         $onglets.nb add $f_img -text "Img"
         $onglets.nb add $f_bdi -text "BDI"
         $onglets.nb add $f_cal -text "Calib"

         #$onglets.nb select $f_data_reference
         ttk::notebook::enableTraversal $onglets.nb

         # Ajouter
         set w [frame $f_add.w -borderwidth 1 -relief groove]
         pack $w -in $f_add -expand yes -fill both

            set left [frame $w.left ]
            pack $left -in $w -side left -expand yes -fill x

               label  $left.l1 -text "Clé"
               entry  $left.e1 -relief sunken -width $width_entry -textvariable ::bdi_gui_define::add_key

               label  $left.l2 -text "Valeur"
               entry  $left.e2 -relief sunken -width $width_entry -textvariable ::bdi_gui_define::add_val

               label  $left.l3 -text "Type"
               menubutton $left.m3 -relief raised -borderwidth 2 -textvariable ::bdi_gui_define::add_typ -menu $left.m3.lst

               set menuconfig [menu $left.m3.lst -tearoff 1]
               $menuconfig add radiobutton -label "string" -value "string" -variable ::bdi_gui_define::add_typ
               $menuconfig add radiobutton -label "int"    -value "int"    -variable ::bdi_gui_define::add_typ
               $menuconfig add radiobutton -label "float"  -value "float"  -variable ::bdi_gui_define::add_typ
               $menuconfig add radiobutton -label "double" -value "double" -variable ::bdi_gui_define::add_typ

               label  $left.l4 -text "Unit"
               entry  $left.e4 -relief sunken -width $width_entry -textvariable ::bdi_gui_define::add_uni

               label  $left.l5 -text "Comment"
               entry  $left.e5 -relief sunken -width $width_entry -textvariable ::bdi_gui_define::add_cmt

               grid  $left.l1 $left.e1 -in $left -sticky w -pady 1
               grid  $left.l2 $left.e2 -in $left -sticky w -pady 1
               grid  $left.l3 $left.m3 -in $left -sticky w -pady 1
               grid  $left.l4 $left.e4 -in $left -sticky w -pady 1
               grid  $left.l5 $left.e5 -in $left -sticky w -pady 1

            set right [frame $w.right ]
            pack $right -in $w -side left -expand yes -fill x

               button $right.ap -text "Ajouter" -borderwidth 2 -takefocus 1 \
                            -command "::bdi_gui_define::addmod A"
               button $right.cl -text "Efface" -borderwidth 2 -takefocus 1 \
                            -command "::bdi_gui_define::clear A"
               pack  $right.ap -in $right -padx 5 -fill x
               pack  $right.cl -in $right -padx 5 -fill x

         # Modifier
         set w [frame $f_mod.w  -borderwidth 1 -relief groove]
         pack $w -in $f_mod -expand yes -fill both


            set left [frame $w.left ]
            pack $left -in $w -side left -expand yes -fill x

               label  $left.l1 -text "Clé"
               ComboBox $left.c1 \
                  -width [expr $width_key -3] -height 15 \
                  -relief sunken -borderwidth 1 -editable 0 \
                  -textvariable ::bdi_gui_define::mod_key \
                  -modifycmd "::bdi_gui_define::mod_select_key" \
                  -values $list_box_champs

               label  $left.l2 -text "Valeur"
               entry  $left.e2 -relief sunken -width $width_entry -textvariable ::bdi_gui_define::mod_val

               label  $left.l3 -text "Type"
               menubutton $left.m3 -relief raised -borderwidth 2 -textvariable ::bdi_gui_define::mod_typ \
                                   -menu $left.m3.lst
               set menuconfig [menu $left.m3.lst -tearoff 1]
               $menuconfig add radiobutton -label "string" -value "string" -variable ::bdi_gui_define::mod_typ
               $menuconfig add radiobutton -label "int"    -value "int"    -variable ::bdi_gui_define::mod_typ
               $menuconfig add radiobutton -label "float"  -value "float"  -variable ::bdi_gui_define::mod_typ
               $menuconfig add radiobutton -label "double" -value "double" -variable ::bdi_gui_define::mod_typ

               label  $left.l4 -text "Unit"
               set ::bdi_gui_define::widget(mod,unit) [ ComboBox $left.c4 \
                  -width [expr $width_key -3] -height 15 \
                  -relief sunken -borderwidth 1 -editable 0 \
                  -textvariable ::bdi_gui_define::mod_uni \
                  -editable 1 \
                  -values "" ]

               label  $left.l5 -text "Comment"
               set ::bdi_gui_define::widget(mod,comment) [ ComboBox $left.c5 \
                  -width [expr $width_key -3] -height 15 \
                  -relief sunken -borderwidth 1 -editable 0 \
                  -textvariable ::bdi_gui_define::mod_cmt \
                  -editable 1 \
                  -values "" ]

               grid  $left.l1 $left.c1 -in $left -sticky w -pady 1
               grid  $left.l2 $left.e2 -in $left -sticky w -pady 1
               grid  $left.l3 $left.m3 -in $left -sticky w -pady 1
               grid  $left.l4 $left.c4 -in $left -sticky w -pady 1
               grid  $left.l5 $left.c5 -in $left -sticky w -pady 1

            set right [frame $w.right ]
            pack $right -in $w -side left -expand yes -fill x

               button $right.ap -text "Modifier" -borderwidth 2 -takefocus 1 \
                            -command "::bdi_gui_define::addmod M"
               button $right.cl -text "Efface" -borderwidth 2 -takefocus 1 \
                            -command "::bdi_gui_define::clear M"
               pack  $right.ap -in $right -padx 5 -fill x
               pack  $right.cl -in $right -padx 5 -fill x

        # Supprimer
         set w [frame $f_del.w  -borderwidth 1 -relief groove]
         pack $w -in $f_del -expand yes -fill both

            set left [frame $w.left ]
            pack $left -in $w -side left -expand yes -fill x

               label  $left.l1 -text "   Clé   "
               ComboBox $left.c1 \
                  -width [expr $width_key -3] -height 15 \
                  -relief sunken -borderwidth 1 -editable 0 \
                  -textvariable ::bdi_gui_define::del_key \
                  -values $list_box_champs

               grid  $left.l1 $left.c1 -in $left

            set right [frame $w.right ]
            pack $right -in $w -side left -expand yes -fill x

               button $right.ap -text "Supprimer" -borderwidth 2 -takefocus 1 \
                            -command "::bdi_gui_define::del"
               pack  $right.ap -in $right -padx 5 -fill x

         # Img
         set w [frame $f_img.w  -borderwidth 1 -relief groove]
         pack $w -in $f_img -expand yes -fill both

            label  $w.l1 -text "OBJECT = "
            entry  $w.e1 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::img_object
            label  $w.l2 -text "FILTER = "
            entry  $w.e2 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::img_filter

            button $w.ap -text "Modifier" -borderwidth 2 -takefocus 1 -command "::bdi_gui_define::img_modif"

            grid $w.l1 $w.e1 -in $w -padx 5 -pady 1
            grid $w.l2 $w.e2 -in $w -padx 5 -pady 1
            grid $w.ap -in $w -columnspan 2 -pady 5

         # BDI
         set w [frame $f_bdi.w  -borderwidth 1 -relief groove]
         pack $w -in $f_bdi -expand yes -fill both

            label  $w.l1 -text "TYPE = "
            entry  $w.e1 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::bdi_type
            label  $w.l2 -text "STATE = "
            entry  $w.e2 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::bdi_state
            label  $w.l3 -text "WCS = "
            entry  $w.e3 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::bdi_wcs
            label  $w.l4 -text "ASTROID = "
            entry  $w.e4 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::bdi_astroid

            button $w.ap -text "Modifier" -borderwidth 2 -takefocus 1 \
                         -command "::bdi_gui_define::bdi_modif"

            grid $w.l1 $w.e1 -in $w -sticky e -pady 1
            grid $w.l2 $w.e2 -in $w -sticky e -pady 1
            grid $w.l3 $w.e3 -in $w -sticky e -pady 1
            grid $w.l4 $w.e4 -in $w -sticky e -pady 1
            grid $w.ap -in $w -columnspan 2 -pady 5

         # Calib
         set w [frame $f_cal.w  -borderwidth 1 -relief groove]
         pack $w -in $f_cal -expand yes -fill both

            label  $w.l1 -text "RA = "
            entry  $w.e1 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::calib_ra
            label  $w.l2 -text "DEC = "
            entry  $w.e2 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::calib_dec
            label  $w.l3 -text "PIXSIZE1 = "
            entry  $w.e3 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::calib_pixsize1
            label  $w.l4 -text "PIXSIZE2 = "
            entry  $w.e4 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::calib_pixsize2
            label  $w.l5 -text "FOCLEN = "
            entry  $w.e5 -relief sunken -width $width_bdi -textvariable ::bdi_gui_define::calib_foclen

            button $w.ap -text "Modifier" -borderwidth 2 -takefocus 1 \
                         -command "::bdi_gui_define::calib_modif"

            grid $w.l1 $w.e1 -in $w -sticky e -pady 1
            grid $w.l2 $w.e2 -in $w -sticky e -pady 1
            grid $w.l3 $w.e3 -in $w -sticky e -pady 1
            grid $w.l4 $w.e4 -in $w -sticky e -pady 1
            grid $w.l5 $w.e5 -in $w -sticky e -pady 1
            grid $w.ap -in $w -columnspan 2 -pady 5

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_define::fen

   return
}


#------------------------------------------------------------
## @brief Suppression d'une action deja programmee
#
proc ::bdi_gui_define::worklist_del { } {
   set r [tk_messageBox -message "Voulez vous vraiment supprimer ces modifications ?" -type yesno]
   if {$r != "yes"} {return}
   set l [lsort -decreasing [$::bdi_gui_define::worklist curselection]]
   foreach i $l {
      $::bdi_gui_define::worklist delete $i $i
   }
   return
}


#------------------------------------------------------------
## @brief Suppression de toutes les actions deja programmees
#
proc ::bdi_gui_define::worklist_del_all { } {
   set r [tk_messageBox -message "Voulez vous vraiment supprimer toutes les modifications ?" -type yesno]
   if {$r != "yes"} {return}
   $::bdi_gui_define::worklist delete 0 end
   return
}


#------------------------------------------------------------
## @brief Selection de la liste d'image a traiter
#
proc ::bdi_gui_define::select_img { } {

   set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
   set ::bdi_gui_define::list_sel ""
   foreach i $l {
      lappend ::bdi_gui_define::list_sel [lindex [$::bddimages_recherche::This.frame6.result.tbl get $i] 0]
   }
   gren_info "change on list : $::bdi_gui_define::list_sel \n"
   set ::bdi_gui_define::nb_sel [llength $::bdi_gui_define::list_sel]
   return
}



#------------------------------------------------------------
## @brief Programmation de l'action ajout/modification de mot-cle
# @param am string type d'action : [A]jout ou [M]odification
#
proc ::bdi_gui_define::addmod { am } {

   # Verif
   if {![info exists ::bdi_gui_define::list_sel]} {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }
   if { $::bdi_gui_define::nb_sel == 0 } {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }

   # Verif
   if {$am == "A" && $::bdi_gui_define::add_typ==""} {
      tk_messageBox -message "Veuillez choisir un type de donnee" -type ok
      return
   }
   if {$am == "M" && $::bdi_gui_define::mod_typ==""} {
      tk_messageBox -message "Veuillez choisir un type de donnee" -type ok
      return
   }

   # Programmation
   if {$am == "A"} {
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel A \
                                                   $::bdi_gui_define::add_key \
                                                   $::bdi_gui_define::add_val \
                                                   $::bdi_gui_define::add_typ \
                                                   $::bdi_gui_define::add_uni \
                                                   $::bdi_gui_define::add_cmt \
                                                   $::bdi_gui_define::list_sel]
   }
   if {$am == "M"} {
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M \
                                                   $::bdi_gui_define::mod_key \
                                                   $::bdi_gui_define::mod_val \
                                                   $::bdi_gui_define::mod_typ \
                                                   $::bdi_gui_define::mod_uni \
                                                   $::bdi_gui_define::mod_cmt \
                                                   $::bdi_gui_define::list_sel]
   }
   $::bdi_gui_define::worklist see end
   return
}


#------------------------------------------------------------
## @brief Efface les champs dans le formulaire
# @param am string type d'action : [A]jout ou [M]odification
#
proc ::bdi_gui_define::clear { am } {

   # Programmation
   if {$am == "A"} {
      set ::bdi_gui_define::add_key ""
      set ::bdi_gui_define::add_val ""
      set ::bdi_gui_define::add_typ ""
      set ::bdi_gui_define::add_uni ""
      set ::bdi_gui_define::add_cmt ""
   }
   if {$am == "M"} {
      set ::bdi_gui_define::mod_key ""
      set ::bdi_gui_define::mod_val ""
      set ::bdi_gui_define::mod_typ ""
      set ::bdi_gui_define::mod_uni ""
      set ::bdi_gui_define::mod_cmt ""
   }
   return
}


#------------------------------------------------------------
## @brief Programmation de l'action de modification de mot-cle
#
proc ::bdi_gui_define::mod_select_key { } {

   gren_info "key : $::bdi_gui_define::mod_key\n"

   # Type
   set sqlcmd "SELECT DISTINCT type FROM header WHERE keyname = '$::bdi_gui_define::mod_key';"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      tk_messageBox -message "Erreur de lecture du type de la liste des header par SQL\n$msg" -type ok
      return
   }
   set l ""
   foreach line $resultsql {
      if {$line == "TEXT" }   {lappend l "string"}
      if {$line == "INT" }    {lappend l "int"}
      if {$line == "FLOAT" }  {lappend l "float"}
      if {$line == "DOUBLE" } {lappend l "double"}
   }
   if {[llength $l]!=1} {
      set ::bdi_gui_define::mod_typ ""
      gren_info "List type : $l\n"
   } else {
      set ::bdi_gui_define::mod_typ [lindex $l 0]
   }

   # Unit
   set sqlcmd "SELECT DISTINCT unit FROM header WHERE keyname = '$::bdi_gui_define::mod_key';"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      tk_messageBox -message "Erreur de lecture du unit de la liste des header par SQL\n$msg" -type ok
      return
   }
   set l ""
   foreach line $resultsql {
      regsub -all {\{} $line {}  line
      regsub -all {\}} $line {}  line
      lappend l $line
   }
   if {[llength $l]!=1} {
      set ::bdi_gui_define::mod_uni ""
   } else {
      set ::bdi_gui_define::mod_uni [lindex $l 0]
   }
   $::bdi_gui_define::widget(mod,unit) configure -values $l

   # Comment
   set sqlcmd "SELECT DISTINCT comment FROM header WHERE keyname = '$::bdi_gui_define::mod_key';"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      tk_messageBox -message "Erreur de lecture du unit de la liste des header par SQL\n$msg" -type ok
      return
   }
   set l ""
   foreach line $resultsql {
      regsub -all {\{} $line {}  line
      regsub -all {\}} $line {}  line
      lappend l $line
   }
   if {[llength $l]!=1} {
      set ::bdi_gui_define::mod_cmt ""
   } else {
      set ::bdi_gui_define::mod_cmt [lindex $l 0]
   }
   $::bdi_gui_define::widget(mod,comment) configure -values $l

   return
}


#------------------------------------------------------------
## @brief Programmation de l'action suppression de mot-cle
#
proc ::bdi_gui_define::del { } {

   # Verif
   if {![info exists ::bdi_gui_define::list_sel]} {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }
   if { $::bdi_gui_define::nb_sel == 0 } {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }

   # Programmation
   $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel D \
                                                $::bdi_gui_define::del_key \
                                                "" \
                                                "" \
                                                "" \
                                                "" \
                                                $::bdi_gui_define::list_sel]

   $::bdi_gui_define::worklist see end
   return
}


#------------------------------------------------------------
## @brief Programmation de l'action de modification rapide des champs d'information principale de l'image
#
proc ::bdi_gui_define::img_modif { } {

   # Verif
   if {![info exists ::bdi_gui_define::list_sel]} {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }
   if { $::bdi_gui_define::nb_sel == 0 } {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }

   # Programmation
   if {$::bdi_gui_define::img_object!=""} {
      set type "string"
      set unit ""
      set comment "name of observed object"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "OBJECT" $::bdi_gui_define::img_object $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::img_filter!=""} {
      set type "string"
      set unit ""
      set comment "Filter Used"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "FILTER" $::bdi_gui_define::img_filter $type $unit $comment $::bdi_gui_define::list_sel]
   }
   $::bdi_gui_define::worklist see end
   return
}


#------------------------------------------------------------
## @brief Programmation de l'action de modification rapide des champs BDI
#
proc ::bdi_gui_define::bdi_modif { } {

   # Verif
   if {![info exists ::bdi_gui_define::list_sel]} {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }
   if { $::bdi_gui_define::nb_sel == 0 } {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }

   # Programmation
   if {$::bdi_gui_define::bdi_type!=""} {
      set type "string"
      set unit ""
      set comment "IMG | FLAT | DARK | OFFSET | ?"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "BDDIMAGES TYPE" $::bdi_gui_define::bdi_type $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::bdi_state!=""} {
      set type "string"
      set unit ""
      set comment "RAW | CORR | CATA | ?"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "BDDIMAGES STATE" $::bdi_gui_define::bdi_state $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::bdi_wcs!=""} {
      set type "string"
      set unit ""
      set comment "WCS performed: Y|N|?"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "BDDIMAGES WCS" $::bdi_gui_define::bdi_wcs $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::bdi_astroid!=""} {
      set type "string"
      set unit ""
      set comment "ASTROID performed"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "BDDIMAGES ASTROID" $::bdi_gui_define::bdi_astroid $type $unit $comment $::bdi_gui_define::list_sel]
   }
   $::bdi_gui_define::worklist see end
   return
}


#------------------------------------------------------------
## @brief Programmation de l'action de modification rapide
#         des champs pour la calibration WCS pour les methodes
#         calibwcs et calibwcs_new
#
proc ::bdi_gui_define::calib_modif { } {

   # Verif
   if {![info exists ::bdi_gui_define::list_sel]} {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }
   if { $::bdi_gui_define::nb_sel == 0 } {
      tk_messageBox -message "Selectionner des images dans la liste" -type ok
      return
   }

   # Programmation
   if {$::bdi_gui_define::calib_ra!=""} {
      set type "double"
      set unit "deg"
      set comment "R.A. of the observation"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "RA" $::bdi_gui_define::calib_ra $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::calib_dec!=""} {
      set type "double"
      set unit "deg"
      set comment "declination of the observed object"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "DEC" $::bdi_gui_define::calib_dec $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::calib_pixsize1!=""} {
      set type "float"
      set unit "um"
      set comment "X Pixel size after binning"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "PIXSIZE1" $::bdi_gui_define::calib_pixsize1 $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::calib_pixsize2!=""} {
      set type "float"
      set unit "um"
      set comment "Y Pixel size after binning"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "PIXSIZE2" $::bdi_gui_define::calib_pixsize2 $type $unit $comment $::bdi_gui_define::list_sel]
   }
   if {$::bdi_gui_define::calib_foclen!=""} {
      set type "float"
      set unit "m"
      set comment "Equivalent focal length"
      $::bdi_gui_define::worklist insert end [list $::bdi_gui_define::nb_sel M "FOCLEN" $::bdi_gui_define::calib_foclen $type $unit $comment $::bdi_gui_define::list_sel]
   }
   $::bdi_gui_define::worklist see end
   return
}
