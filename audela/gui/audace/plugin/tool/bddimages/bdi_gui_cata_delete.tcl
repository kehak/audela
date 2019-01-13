## @file bdi_gui_cata_delete.tcl
#  @brief     Effacement d'un ou plusieurs catalogues dans une ou plusieurs images
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cata_delete.tcl]
#  @endcode

# $Id: bdi_gui_cata_delete.tcl 9215 2013-03-15 15:36:44Z jberthier $

##
# @namespace bdi_gui_cata_delete
# @brief Effacement d'un ou plusieurs catalogues dans une ou plusieurs images
# @pre Requiert \c bdi_gui_cata .
# @pre Requiert \c tools_cata .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_cata_delete {

   variable fen
   variable frmtable

}


proc ::bdi_gui_cata_delete::inittoconf { } {

}

proc ::bdi_gui_cata_delete::fermer { } {
   
   if { [winfo exists ::bdi_gui_cata_gestion::fen] } {
      gren_info "Fenetre gestion des catalogues existe\n"
      ::bdi_gui_cata_gestion::charge_image_directaccess
   }
   destroy $::bdi_gui_cata_delete::fen
}


proc ::bdi_gui_cata_delete::cmdButton1Click { w args } {

}



proc ::bdi_gui_cata_delete::create_Tbl_sources { frmtable name_of_columns} {

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
      -selectmode extended \
      -activestyle none \
      -stripebackground #e0e8f0 \
      -showseparators 1


   #--- Gestion des popup

   #--- Menu pop-up associe a la table
   menu $popupTbl -title "Selection"

     $popupTbl add command -label "Supprimer" -command "::bdi_gui_cata_delete::popup_delete $tbl"

   #--- Gestion des evenements
   bind [$tbl bodypath] <Control-Key-a> [ list ::bdi_gui_cata_delete::selectall $tbl ]
   bind $tbl <<ListboxSelect>> [ list ::bdi_gui_cata_delete::cmdButton1Click %W ]
   bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

   pack  $tbl -in  $frmtable -expand yes -fill both
   
}




proc ::bdi_gui_cata_delete::popup_delete { tbl } {


   for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

      gren_info "Image $i / $::tools_cata::nb_img_list : "
      foreach select [$tbl curselection] {
         set cata [lindex [$tbl get $select] 0]      
         gren_info "$cata "
         set ::tools_cata::current_listsources [::manage_source::delete_catalog $::bdi_gui_cata::cata_list($i) $cata]
         set ::bdi_gui_cata::cata_list($i) $::tools_cata::current_listsources

         # chargement de la tklist sous forme de liste tcl. (pour affichage)
         ::tools_cata::current_listsources_to_tklist

         set ::bdi_gui_cata::tk_list($i,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
         set ::bdi_gui_cata::tk_list($i,tklist)          [array get ::bdi_gui_cata::tklist]
         set ::bdi_gui_cata::tk_list($i,cataname)        [array get ::bdi_gui_cata::cataname]



      }
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $::bdi_gui_cata::cata_list($i)]\n"

   }
   ::bdi_gui_cata_delete::reload
}




proc ::bdi_gui_cata_delete::reload {  } {

   array unset tab
   for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {
      set current_listsources $::bdi_gui_cata::cata_list($i)
      set fields [lindex $current_listsources 0]
      foreach x $fields {
         set x [lindex $x 0]
         set tab($x) 0
      }
   }

   $::bdi_gui_cata_delete::fen.appli.frmtable.tbl delete 0 end
   foreach {x y} [array get tab] {
      $::bdi_gui_cata_delete::fen.appli.frmtable.tbl insert end $x
   }

}





proc ::bdi_gui_cata_delete::run_from_recherche { img_list } {

  global bddconf

  catch {
      if { [ info exists ::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
      if { [ info exists ::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
      if { [ info exists ::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      if { [ info exists ::bdi_gui_cata::cata_list ] }        {unset ::bdi_gui_cata::cata_list}
   } 

   set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
   
   set ::tools_cata::id_current_image -1
   ::bdi_gui_cata_delete::run
}





proc ::bdi_gui_cata_delete::run {  } {

   global audace
   global bddconf

   ::bdi_gui_cata_delete::inittoconf
   
   set col_catas { 0 cata }

   #--- Creation de la fenetre
   set ::bdi_gui_cata_delete::fen .deletecata
   if { [winfo exists $::bdi_gui_cata_delete::fen] } {
      wm withdraw $::bdi_gui_cata_delete::fen
      wm deiconify $::bdi_gui_cata_delete::fen
      focus $::bdi_gui_cata_delete::fen
      return
   }
   toplevel $::bdi_gui_cata_delete::fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cata_delete::fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cata_delete::fen ] "+" ] 2 ]
   wm geometry $::bdi_gui_cata_delete::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_cata_delete::fen 1 1
   wm title $::bdi_gui_cata_delete::fen "Effacement de Catalogues"
   wm protocol $::bdi_gui_cata_delete::fen WM_DELETE_WINDOW "::bdi_gui_cata_delete::fermer"

   set frm $::bdi_gui_cata_delete::fen.appli

   #--- Cree un frame general
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cata_delete::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      set frmtable [frame $frm.frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
      pack $frmtable -in $frm -expand yes -fill both -padx 3 -pady 6 -side right -anchor e
      ::bdi_gui_cata_delete::create_Tbl_sources $frmtable $col_catas

      set actions [frame $frm.pied -borderwidth 0 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $actions.reload -text "Recharger" -borderwidth 2 -takefocus 1 \
                -command "::bdi_gui_cata_delete::reload" 
          pack $actions.reload -side top -anchor c -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
          button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::bdi_gui_cata_delete::fermer" 
          pack $actions.fermer -side top -anchor c -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   ::bdi_gui_cata_delete::reload

}
