## @file bdi_gui_verifcata.tcl
#  @brief     GUI de v&eacute;rification des sources dans les catas
#  @author    Frederic Vachier and Jerome Berthier 
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_verifcata.tcl]
#  @endcode

# $Id: bdi_gui_verifcata.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace gui_verifcata
# @brief GUI de v&eacute;rification des sources dans les catas
# @warning Outil en d&eacute;veloppement
#
namespace eval ::gui_verifcata {

   variable fen
   variable frmtable

}

#------------------------------------------------------------
## init to conf
#  @return void
#
proc ::gui_verifcata::inittoconf { } {

}

#------------------------------------------------------------
## Fermer
#  @return void
#
proc ::gui_verifcata::fermer { } {

   ::gui_verifcata::recup_position
   destroy $::gui_verifcata::fen

}


#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::gui_verifcata::recup_position { } {

   global conf bddconf

   set bddconf(geometry_verifcata) [wm geometry $::gui_verifcata::fen]
   set conf(bddimages,geometry_verifcata) $bddconf(geometry_verifcata)

}


#------------------------------------------------------------
## Cmde 1 click
#  @return void
#
proc ::gui_verifcata::cmdButton1Click { w args } {

}


#------------------------------------------------------------
## Creation de la table d'affichage
#  @return void
#
proc ::gui_verifcata::create_Tbl_sources { frmtable name_of_columns} {

   variable This
   global audace
   global caption
   global bddconf

   #--- Quelques raccourcis utiles
   set tbl $frmtable.tbl
   set popupTbl $frmtable.popupTbl

   #--- Table des objets
   tablelist::tablelist $tbl \
      -columns $name_of_columns \
      -labelcommand tablelist::sortByColumn \
      -xscrollcommand [ list $frmtable.hsb set ] \
      -yscrollcommand [ list $frmtable.vsb set ] \
      -selectmode extended \
      -activestyle none \
      -stripebackground #e0e8f0 \
      -showseparators 1

   scrollbar $frmtable.hsb -orient horizontal -command [list $tbl xview]
   pack $frmtable.hsb -in $frmtable -side bottom -fill x
   scrollbar $frmtable.vsb -orient vertical -command [list $tbl yview]
   pack $frmtable.vsb -in $frmtable -side right -fill y

   #--- Menu pop-up associe a la table
   menu $popupTbl -title "Selection"

     $popupTbl add command -label "Voir une source" -command "::gui_verifcata::popup_voir $tbl"
     $popupTbl add command -label "Psf"             -command "::gui_verifcata::popup_psf $tbl"
     $popupTbl add command -label "Unset"           -command "::gui_verifcata::popup_unset $tbl"

   #--- Gestion des evenements
   bind [$tbl bodypath] <Control-Key-a> [ list ::gui_verifcata::selectall $tbl ]
   bind $tbl <<ListboxSelect>> [ list ::gui_verifcata::cmdButton1Click %W ]
   bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

   pack $tbl -in $frmtable -expand yes -fill both

}


#------------------------------------------------------------
## Affichage des resultats
#  @return void
#
proc ::gui_verifcata::affich_results_tklist { send_source_list send_date_list } {

   upvar $send_source_list source_list
   upvar $send_date_list   date_list

   set onglets $::gui_verifcata::fen.appli.onglets
   set tbl1 $onglets.nb.f1.frmtable.tbl
   set tbl2 $onglets.nb.f2.frmtable.tbl
   catch { 
      $tbl1 delete 0 end
      $tbl2 delete 0 end
   }

   foreach line $source_list {
      $tbl1 insert end $line
   }
   foreach line $date_list {
      $tbl2 insert end $line
   }
   
   return

}


#------------------------------------------------------------
## Affichage de l'image courante
#  @return void
#
proc ::gui_verifcata::visu_image {  } {

   set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
   set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
   ::bdi_gui_cata::affiche_current_image

}



#------------------------------------------------------------
## Affichage d'une source dans une image
#  @return void
#
proc ::gui_verifcata::popup_voir { tbl } {

   foreach select [$tbl curselection] {
      set ids [lindex [$tbl get $select] 0]      
      set idd [lindex [$tbl get $select] 1]   
      set listsources $::bdi_gui_cata::cata_list($idd)
      set sources [lindex $listsources 1] 
      set s [lindex $sources [expr $ids-1]]
      break
   }
   
   if {$::tools_cata::id_current_image == $idd} {
      # L image est deja affichée
      
   } else {
      # L image affichée n est pas la bonne
      set ::tools_cata::id_current_image $idd
      ::gui_verifcata::visu_image
   }
   set s [lindex [lindex $::tools_cata::current_listsources 1] [expr $ids - 1] ]
   set r [::bdi_gui_gestion_source::grab_sources_getsource $ids $s ]
   set err   [lindex $r 0]
   set aff   [lindex $r 1]
   set id    [lindex $r 2]
   set xpass [lindex $r 3]
   set ypass [lindex $r 4]
   
   ::confVisu::setPos $::audace(visuNo) [list $xpass $ypass]
   affich_un_rond_xy $xpass $ypass green  10 1

}


#------------------------------------------------------------
## Mesure de PSF des sources selectionnees
#  @return void
#
proc ::gui_verifcata::popup_psf { tbl } {

   set worklist ""
   foreach select [$tbl curselection] {
      set ids [lindex [$tbl get $select] 0]      
      set idd [lindex [$tbl get $select] 1]   
      gren_info "ids = $ids ; idd = $idd \n"   
      lappend worklist [list $idd $ids]
   }
   set worklist [lsort -dictionary $worklist]
   ::bdi_gui_gestion_source::run $worklist
   return

}



#------------------------------------------------------------
## Suppression des flag astrom et photom d'une liste de sources
#  @return void
#
proc ::gui_verifcata::popup_unset { tbl } {

   global bddconf
   
   set worklist ""
   foreach select [$tbl curselection] {
      set ids [lindex [$tbl get $select] 0]      
      set idd [lindex [$tbl get $select] 1]   
      
      set current_listsources $::bdi_gui_cata::cata_list($idd)
      set sources [lindex $current_listsources 1]
      set s [lindex $sources [expr $ids - 1] ]
      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
      ::bdi_tools_psf::set_by_key othf "flagastrom" ""
      ::bdi_tools_psf::set_by_key othf "cataastrom" ""
      ::bdi_tools_psf::set_astroid_in_source s othf
      set sources [lreplace $sources [expr $ids - 1] [expr $ids - 1] $s]
      set current_listsources [list [lindex $current_listsources 0] $sources]

      # @TODO
      set current_image [lindex $::tools_cata::img_list [expr $idd-1]]
      set tabkey         [::bddimages_liste::lget $current_image "tabkey"]
      set imgfilename    [::bddimages_liste::lget $current_image filename]
      set imgdirfilename [::bddimages_liste::lget $current_image dirfilename]
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"
      
      ::tools_cata::save_cata $current_listsources $tabkey $cataxml

   }
   return

}


#------------------------------------------------------------
## Execution de la verif depuis l'outil recherche
#  @return void
#
proc ::gui_verifcata::run_from_recherche { img_list } {

  catch {
      if { [ info exists ::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
      if { [ info exists ::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
      if { [ info exists ::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      if { [ info exists ::bdi_gui_cata::cata_list ] }            {unset ::bdi_gui_cata::cata_list}
   } 

   set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
   
   set ::tools_cata::id_current_image -1
   ::gui_verifcata::run

}



#------------------------------------------------------------
## Execution de la verif
#  @return void
#
proc ::gui_verifcata::verif {  } {

   ::tools_verifcata::verif source_list date_list
   ::gui_verifcata::affich_results_tklist source_list date_list 

}



#------------------------------------------------------------
## GUI Verif
#  @return void
#
proc ::gui_verifcata::run {  } {

   global audace
   global conf bddconf

   ::gui_verifcata::inittoconf
   
   set col_sources { 0 IdS  0 IdD 0 Date-Obs 0 Erreur     0 Name 0 Catas }
   set col_dates   { 0 IdS  0 IdD 0 Date-Obs 0 Star&Aster 0 CataDouble 0 CataAstrom }
  
   set ::tools_verifcata::rdiff 3

   #--- Geometry
   if { ! [info exists conf(bddimages,geometry_verifcata)] } { set conf(bddimages,geometry_verifcata) "+165+55" }
   set bddconf(geometry_verifcata) $conf(bddimages,geometry_verifcata)

   #--- Creation de la fenetre
   set ::gui_verifcata::fen .verifcata
   if { [winfo exists $::gui_verifcata::fen] } {
      wm withdraw $::gui_verifcata::fen
      wm deiconify $::gui_verifcata::fen
      focus $::gui_verifcata::fen
      return
   }
   toplevel $::gui_verifcata::fen -class Toplevel
   wm geometry $::gui_verifcata::fen $bddconf(geometry_verifcata)
   wm resizable $::gui_verifcata::fen 1 1
   wm title $::gui_verifcata::fen "Verification du CATA"
   wm protocol $::gui_verifcata::fen WM_DELETE_WINDOW "::gui_verifcata::fermer"

   set frm $::gui_verifcata::fen.appli

   #--- Cree un frame general
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::gui_verifcata::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      #--- Cree un frame pour les parametres
      set param [frame $frm.param -borderwidth 0 -cursor arrow -relief groove]
      pack $param -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         label $param.rdiff_lab -text "Dist. pixel :"
         spinbox $param.rdiff_val -from 1 -to 30 -increment 1 -width 3 \
                -textvariable ::tools_verifcata::rdiff
         
         grid $param.rdiff_lab $param.rdiff_val
         
      set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5

           pack [ttk::notebook $onglets.nb] -expand yes -fill both 
           set f1 [frame $onglets.nb.f1]
           set f2 [frame $onglets.nb.f2]

           $onglets.nb add $f1 -text "Sources"
           $onglets.nb add $f2 -text "Dates"

          $onglets.nb select $f1
          ttk::notebook::enableTraversal $onglets.nb

          set frmtable [frame $f1.frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
          pack $frmtable -in $f1 -expand yes -fill both -padx 3 -pady 6 -side right -anchor e
          ::gui_verifcata::create_Tbl_sources $frmtable $col_sources

          set frmtable [frame $f2.frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
          pack $frmtable -in $f2 -expand yes -fill both -padx 3 -pady 6 -side right -anchor e
          ::gui_verifcata::create_Tbl_sources $frmtable $col_dates

      #--- Cree un frame general
      set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor c -side top -expand 0 -fill x -padx 10 -pady 5

         set actionbut [frame $actions.but -borderwidth 0 -cursor arrow -relief groove]
         pack $actionbut -in $actions -anchor s -side top -expand 1 -padx 10 -pady 5

           button $actionbut.back -text "Verifier" -borderwidth 2 -takefocus 1 -command "::gui_verifcata::verif" 
           pack $actionbut.back -side left -anchor c -padx 5 -ipadx 5 -ipady 5 -expand 0

           button $actionbut.fermer -text "Fermer" -borderwidth 2 -takefocus 1 -command "::gui_verifcata::fermer" 
           pack $actionbut.fermer -side left -anchor c -padx 5 -ipadx 5 -ipady 5 -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::gui_verifcata::fen

}
