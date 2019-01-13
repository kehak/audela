## @file bdi_gui_cata_gestion.tcl
#  @brief     GUI de gestion des catalogues
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cata_gestion.tcl]
#  @endcode

# $Id: bdi_gui_cata_gestion.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_cata_gestion
# @brief GUI de gestion des catalogues
# @pre Requiert \c bdi_gui_cata .
# @pre Requiert \c tools_cata .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_cata_gestion {

}



proc ::bdi_gui_cata_gestion::inittoconf {  } {

   ::bdi_gui_cata::inittoconf

}



# ferme la fenetre de gestion de catalogues

proc ::bdi_gui_cata_gestion::fermer { {answer ""} } {
   
   
   # sortie directement si la variable n existe pas
   if { ! [info exists ::bdi_gui_cata_gestion::fen] } {
      return
   }
   
   # sortie directement si la fenetre n a pas ete affichee   
   if { ! [winfo exists $::bdi_gui_cata_gestion::fen] } {
      return
   }
   
   if { $answer == ""} {
      set answer [tk_messageBox -message "Avez vous pensez a sauvegarder ?" -type yesno -parent $::bdi_gui_cata_gestion::fen]
   }
   
   switch -- $answer {
      yes {
         cleanmark
         efface_carre
         ::bdi_gui_cata_gestion::recup_position
         set ::bdi_gui_cata_gestion::state_gestion 0
         destroy $::bdi_gui_cata_gestion::fen
      }
   }
   return
}


#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::bdi_gui_cata_gestion::recup_position { } {

   global conf bddconf

   set bddconf(geometry_cata_gestion) [wm geometry $::bdi_gui_cata_gestion::fen]
   set conf(bddimages,geometry_cata_gestion) $bddconf(geometry_cata_gestion)

}



# Anciennement ::bdi_gui_cata::gestion_back

proc ::bdi_gui_cata_gestion::back { } {

   if {$::bdi_gui_cata_gestion::directaccess==1 } { return }
   incr ::bdi_gui_cata_gestion::directaccess -1
   ::bdi_gui_cata_gestion::charge_image_directaccess

}



# Anciennement ::bdi_gui_cata::gestion_next

proc ::bdi_gui_cata_gestion::next { } {

   if {$::bdi_gui_cata_gestion::directaccess==$::tools_cata::nb_img_list } { return }
   incr ::bdi_gui_cata_gestion::directaccess 
   ::bdi_gui_cata_gestion::charge_image_directaccess

}





# Anciennement ::bdi_gui_cata::gestion_go
# Charge une image en memoire dont l id est celui de la liste ::tools_cata::img_list
# l'id evolue de 1 a $::tools_cata::nb_img_list
# l image est chargée en memoire : ::tools_cata::current_image
# mais aussi dans la visu d audace

proc ::bdi_gui_cata_gestion::charge_image_directaccess { } {

   set ::tools_cata::id_current_image $::bdi_gui_cata_gestion::directaccess

   gren_info "image = $::tools_cata::id_current_image / $::tools_cata::nb_img_list\n"
   ::bdi_gui_cata_gestion::set_progress 0 100      

   set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image - 1]]
   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set ::tools_cata::current_image_date [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]

   set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
   set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)

   ::bdi_gui_cata_gestion::set_progress 25 100

   array set ::bdi_gui_cata::tklist_list_of_columns $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns)
   array set ::bdi_gui_cata::tklist                 $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)
   array set ::bdi_gui_cata::cataname               $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)

   ::bdi_gui_cata_gestion::set_progress 50 100

   ::bdi_gui_cata_gestion::affich_current_tklist

   ::bdi_gui_cata_gestion::set_progress 75 100

   ::bdi_gui_cata::affiche_current_image

   ::bdi_gui_cata_gestion::set_progress 100 100
   gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

}




# Anciennement ::bdi_gui_cata::affich_current_tklist


proc ::bdi_gui_cata_gestion::affich_current_tklist { } {


   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets

   # TODO ::bdi_gui_cata_gestion::affich_current_tklist : afficher l image ici

   set listsources $::tools_cata::current_listsources
   set fields [lindex $listsources 0]

   set nbcatadel [expr [llength [array get ::bdi_gui_cata::cataname]]/2]
   #gren_info "cataname = [array get ::bdi_gui_cata::cataname] \n"
   #gren_info "nbcatadel = $nbcatadel \n"

   foreach t [$onglets.nb tabs] {
      destroy $t
   }

   set idcata 0
   set select 0
   foreach field $fields {
      incr idcata
      
      set fc($idcata) [frame $onglets.nb.f$idcata]
      
      set c [lindex $field 0]
      
      $onglets.nb add $fc($idcata) -text $c
      if {$c=="IMG"} {
         set select $idcata
      }
   }
   set nbcata $idcata
   #gren_info "nbcata : $nbcata\n"

   if {$select >0} {$onglets.nb select $fc($select)}
   ttk::notebook::enableTraversal $onglets.nb

   for { set idcata 1 } { $idcata <= $nbcata} { incr idcata } {

      set ::bdi_gui_cata_gestion::frmtable($idcata) [frame $fc($idcata).frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
      pack $::bdi_gui_cata_gestion::frmtable($idcata) -expand yes -fill both -padx 3 -pady 6 -in $fc($idcata) -side right -anchor e

      #--- Cree un acsenseur vertical
      scrollbar $::bdi_gui_cata_gestion::frmtable($idcata).vsb -orient vertical \
         -command { $::bdi_gui_cata_gestion::frmtable($idcata).lst1 yview } -takefocus 1 -borderwidth 1
      pack $::bdi_gui_cata_gestion::frmtable($idcata).vsb -in $::bdi_gui_cata_gestion::frmtable($idcata) -side right -fill y

      #--- Cree un acsenseur horizontal
      scrollbar $::bdi_gui_cata_gestion::frmtable($idcata).hsb -orient horizontal \
         -command { $::bdi_gui_cata_gestion::frmtable($idcata).lst1 xview } -takefocus 1 -borderwidth 1
      pack $::bdi_gui_cata_gestion::frmtable($idcata).hsb -in $::bdi_gui_cata_gestion::frmtable($idcata) -side bottom -fill x

      #--- Creation de la table
      ::bdi_gui_cata_gestion::create_Tbl_sources $idcata
      pack  $::bdi_gui_cata_gestion::frmtable($idcata).tbl -in  $::bdi_gui_cata_gestion::frmtable($idcata) -expand yes -fill both


      catch { $::bdi_gui_cata_gestion::frmtable($idcata).tbl delete 0 end
              $::bdi_gui_cata_gestion::frmtable($idcata).tbl deletecolumns 0 end  
      }
     
      set nbcol [llength $::bdi_gui_cata::tklist_list_of_columns($idcata)]
      for { set j 0 } { $j < $nbcol} { incr j } {
         set current_columns [lindex $::bdi_gui_cata::tklist_list_of_columns($idcata) $j]
         $::bdi_gui_cata_gestion::frmtable($idcata).tbl insertcolumns end 0 [lindex $current_columns 1] left
         $::bdi_gui_cata_gestion::frmtable($idcata).tbl columnconfigure $j -sortmode real
      }

      #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
      if { [ $::bdi_gui_cata_gestion::frmtable($idcata).tbl columncount ] != "0" } {
         $::bdi_gui_cata_gestion::frmtable($idcata).tbl columnconfigure 0 -sortmode real
      }
      foreach col {5 6 7 8 9} {
          $::bdi_gui_cata_gestion::frmtable($idcata).tbl columnconfigure $col -background ivory -sortmode real
      }
      foreach col {1 2 3 4 } {
          $::bdi_gui_cata_gestion::frmtable($idcata).tbl columnconfigure $col -background ivory -sortmode ascii
      }

      foreach line $::bdi_gui_cata::tklist($idcata) {
         $::bdi_gui_cata_gestion::frmtable($idcata).tbl insert end $line
      }
      
      #gren_info "$::bdi_gui_cata::cataname($idcata) : [llength $::bdi_gui_cata::tklist($idcata)]\n"
      #gren_info "onglets : [$::bdi_gui_cata_gestion::fen.appli.onglets.nb tabs]\n"
      
      $::bdi_gui_cata_gestion::fen.appli.onglets.nb tab [expr $idcata - 1] -text "([llength $::bdi_gui_cata::tklist($idcata)])$::bdi_gui_cata::cataname($idcata)"
      
   }
}



# Anciennement ::bdi_gui_cata::set_progress

proc ::bdi_gui_cata_gestion::set_progress { cur max } {
   set ::bdi_gui_cata_gestion::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
   update
}
proc ::bdi_gui_cata_gestion::set_popupprogress { cur max } {
   set ::bdi_gui_cata_gestion::popupprogress [format "%0.0f" [expr $cur * 100. /$max ] ]
   update
}



# Anciennement ::bdi_gui_cata::charge_memory


proc ::bdi_gui_cata_gestion::charge_memory { { gui 1 } } {

   if {$gui} {
   
      set state [$::bdi_gui_cata_gestion::fen.appli.actions.charge cget -text]

      if  {$state == "Annuler"} {
          set ::bdi_gui_cata::annul 1
          return
      }

      set ::bdi_gui_cata::annul 0
      $::bdi_gui_cata_gestion::fen.appli.actions.charge configure -text "Annuler"
   }

   for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image<=$::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {
      
      if {$gui} {
         if {$::bdi_gui_cata::annul == 1} {
            gren_info "Chargement annulé...\n"
            break
         }
         ::bdi_gui_cata_gestion::set_progress $::tools_cata::id_current_image $::tools_cata::nb_img_list
      }

      ::bdi_gui_cata_gestion::charge_current_cata

   }

   if {$gui} { ::bdi_gui_cata_gestion::set_progress 0 $::tools_cata::nb_img_list 

      $::bdi_gui_cata_gestion::fen.appli.actions.charge configure -text "Charge"

      set ::bdi_gui_cata_gestion::directaccess 1
      ::bdi_gui_cata_gestion::charge_image_directaccess
   }

}




# Anciennement ::bdi_gui_cata::charge_current_cata

proc ::bdi_gui_cata_gestion::charge_current_cata { } {

   global bddconf

   #gren_info "charge_current_cata ::tools_cata::id_current_image = $::tools_cata::id_current_image\n"

   set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
   set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

   set ::tools_cata::current_image_date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
   set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
   set file        [file join $bddconf(dirbase) $dirfilename $::tools_cata::current_image_name]
   
   ::bdi_gui_cata::load_cata

   #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
   #gren_info "charge_current_catas ::tools_cata::id_current_image=$::tools_cata::id_current_image\n"

   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources

   # chargement de la tklist sous forme de liste tcl. (pour affichage)
   ::tools_cata::current_listsources_to_tklist

   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::bdi_gui_cata::tklist]
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::bdi_gui_cata::cataname]

}




# Anciennement ::bdi_gui_cata::charge_gestion_cata

proc ::bdi_gui_cata_gestion::charge_gestion_cata { img_list } {

   global audace
   global bddconf

  catch {
      if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
      if { [ info exists $::tools_cata::nb_img_list ] }        {unset ::tools_cata::nb_img_list}
      if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
      if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
   }

   set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
   
   # fonction de transfert entre dateiso et id pour la variable cata_list (id commence a 1)
   set id 0
   foreach current_image $::tools_cata::img_list {
      incr id
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set date   [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set ::tools_cata::date2id($date) $id
      set ::tools_cata::id2date($id)   $date
   }
   

   # Chargement premiere image sans GUI
   set ::tools_cata::id_current_image 1
   set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]

   set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

   set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
   set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]
   set file        [file join $bddconf(dirbase) $dirfilename $filename]

   set ::tools_cata::current_image_name $filename
   set ::tools_cata::current_image_date $date

   #?Charge l image a l ecran
   buf$::audace(bufNo) load $file
   cleanmark

   set ::bdi_gui_cata::stateback disabled
   set ::tools_cata::nb_img       0
   set ::tools_cata::nb_usnoa2    0
   set ::tools_cata::nb_ucac2     0
   set ::tools_cata::nb_ucac3     0
   set ::tools_cata::nb_ucac4     0
   set ::tools_cata::nb_ppmx      0
   set ::tools_cata::nb_ppmxl     0
   set ::tools_cata::nb_tycho2    0
   set ::tools_cata::nb_nomad1    0
   set ::tools_cata::nb_2mass     0
   set ::tools_cata::nb_skybot    0
   set ::tools_cata::nb_sdss      0
   set ::tools_cata::nb_panstarrs 0
   set ::tools_cata::nb_gaia1     0
   set ::tools_cata::nb_wfibc     0
   set ::tools_cata::nb_astroid   0

   # Affiche l'image courante
   ::bdi_gui_cata::affiche_current_image

   # Affiche le cata
   # ::bdi_gui_cata::affiche_cata

   # Trace du repere E/N dans l'image
   set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   ::bdi_gui_cata::trace_repere [list $cdelt1 $cdelt2]

}




# Anciennement ::bdi_gui_cata::create_Tbl_sources


proc ::bdi_gui_cata_gestion::create_Tbl_sources { idcata } {

   variable This
   global audace
   global caption
   global bddconf

   #--- Quelques raccourcis utiles
   set tbl $::bdi_gui_cata_gestion::frmtable($idcata).tbl
   set popupTbl $::bdi_gui_cata_gestion::frmtable($idcata).popupTbl

   #--- Table des objets
   tablelist::tablelist $tbl \
      -labelcommand tablelist::sortByColumn \
      -xscrollcommand [ list $::bdi_gui_cata_gestion::frmtable($idcata).hsb set ] \
      -yscrollcommand [ list $::bdi_gui_cata_gestion::frmtable($idcata).vsb set ] \
      -selectmode extended \
      -activestyle none \
      -stripebackground #e0e8f0 \
      -showseparators 1

   #--- Scrollbars verticale et horizontale
   $::bdi_gui_cata_gestion::frmtable($idcata).vsb configure -command [ list $tbl yview ]
   $::bdi_gui_cata_gestion::frmtable($idcata).hsb configure -command [ list $tbl xview ]

   #--- Gestion des popup

   #--- Menu pop-up associe a la table
   menu $popupTbl -title "Selection"

     # Edite la liste selectionnee
     $popupTbl add command -label "Centrer la source" -command "::bdi_gui_cata_gestion::center_visu $tbl"

     # Edite la liste selectionnee
     $popupTbl add command -label "Grab les sources" -command "::bdi_gui_cata_gestion::grab_sources $tbl"

     # Edite la liste selectionnee
     $popupTbl add command -label "Propager les sources" -command "::bdi_gui_cata_gestion::propagation $tbl"

     # Separateur
     $popupTbl add separator

     # Edite la liste selectionnee
     $popupTbl add command -label "Editer la source" -command "::bdi_gui_cata_gestion::edit_source $tbl" -state disable

     # Edite la liste selectionnee
     $popupTbl add command -label "Sauver la source" -command "" -state disable

     # Supprime les sources selectionnees dans l'image courante
     $popupTbl add command -label "Supprimer dans l'image courante" -command "::bdi_gui_cata_gestion::delete_sources $tbl"

     # Supprime les sources selectionnees dans toutes les images
     $popupTbl add command -label "Supprimer dans toutes les images" -command "::bdi_gui_cata_gestion::delete_sources_allimg $tbl"

     # Separateur
     $popupTbl add separator

     # Edite la liste selectionnee
     $popupTbl add command -label "(u) Unset" -command "::bdi_gui_cata_gestion::unset_flag $tbl"

     # Separateur
     $popupTbl add separator

     # Edite la liste selectionnee
     $popupTbl add command -label "Set astrometric reference" -command "::bdi_gui_cata_gestion::set_astrom_ref $tbl"

     # Supprime la liste selectionnee
     $popupTbl add command -label "Set astrometric mesure" -command "::bdi_gui_cata_gestion::set_astrom_mes $tbl"

     # Separateur
     $popupTbl add separator

     # Edite la liste selectionnee
     $popupTbl add command -label "Set photometric reference" -command "::bdi_gui_cata_gestion::set_photom_ref $tbl"

     # Edite la liste selectionnee
     $popupTbl add command -label "Set photometric mesure" -command "::bdi_gui_cata_gestion::set_photom_mes $tbl"

     # Separateur
     $popupTbl add separator

     # Edite la liste selectionnee
     $popupTbl add command -label "PSF manuel : sources selectionnees pour 1 image" -command "::bdi_gui_cata_gestion::psf_popup_manuel $tbl" -state normal

     # Edite la liste selectionnee
     $popupTbl add command -label "PSF manuel : premiere selection sur toutes les images" -command "::bdi_gui_cata_gestion::psf_popup_manuel_1obj_allimg $tbl" -state normal

     # Edite la liste selectionnee
     $popupTbl add command -label "PSF Auto sur 1 image" -command "::bdi_gui_cata_gestion::psf_auto popup_gestion_current_image $tbl" -state normal

     # Edite la liste selectionnee
     $popupTbl add command -label "PSF Auto sur toutes images" -command "::bdi_gui_cata_gestion::psf_auto popup_gestion_all_image $tbl" -state normal

     # Edite la liste selectionnee
     $popupTbl add command -label "Console ASTROID" -command "::bdi_gui_cata_gestion::console_astroid $tbl" -state normal

     # Separateur
     $popupTbl add separator

     # Edite la liste selectionnee
     $popupTbl add command -label "Cataloguer la source" -command "" -state disable


   #--- Gestion des evenements
   bind [$tbl bodypath] <Control-Key-a> [ list ::bdi_gui_cata_gestion::selectall $tbl ]
   bind $tbl <<ListboxSelect>>          [ list ::bdi_gui_cata_gestion::cmdButton1Click %W ]
   bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
   bind [$tbl bodypath] <Key-u>         [ list ::bdi_gui_cata_gestion::unset_flag $tbl ]
   
}




# Anciennement ::bdi_gui_cata::grab_sources

proc ::bdi_gui_cata_gestion::grab_sources { { tbl "" } } {

   set log 0

   global audace

   set color red
   set width 2
   cleanmark
   if {$tbl!=""} {
      if {$log} {gren_info "grab_sources GUI\n"}
      $tbl selection clear 0 end
   }

   set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
   if {$err>0 || $rect==""} {
      tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
      return
   }

   if {$log} {gren_info "rect= $rect\n"}

   set sources [lindex $::tools_cata::current_listsources 1]
   set id 1
   set cpt_grab 0
   foreach s $sources {

      set x -100
      set y -100
      foreach cata $s {
      
         set x -100
         set y -100
         set pass "no"
                     
         if {[lindex $cata 0] == "IMG"} {
            set ra [lindex [lindex $cata 1] 0]
            set dec [lindex [lindex $cata 1] 1]
            set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            if {$log} {gren_info "IMG ?= $x $y $ra $dec\n"}
            if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
               set pass "yes"
               if {$log} {gren_info "IMG pass= $x $y\n"}
               set xpass $x
               set ypass $y
            }
         }
         if {[lindex $cata 0] == "ASTROID"} {
            set ra [lindex [lindex $cata 1] 0]
            set dec [lindex [lindex $cata 1] 1]
            set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
               set pass "yes"
               set xpass $x
               set ypass $y
            }
         }
         
         if {$pass=="yes"} {

            incr cpt_grab

            set pos [lsearch -index 0 $s "IMG"]
            if {$pos != -1} {
                set ra [lindex [lindex $cata 1] 0]
                set dec [lindex [lindex $cata 1] 1]
                set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
                set x [lindex $xy 0]
                set y [lindex $xy 1]
                affich_un_rond $ra $dec green 3 
                affich_un_rond_xy $x $y green 1 10
            }

            set pos [lsearch -index 0 $s "ASTROID"]         
            if {$pos != -1} {
               set cata [lindex $s $pos]
               affich_un_rond_xy  [lindex [lindex $cata 2] 0] [lindex [lindex $cata 2] 1] red 30 1
               set ra [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               affich_un_rond $ra $dec blue 2
               affich_un_rond_xy $x $y blue 1 5
            }

            # selection de la source
            set u 0
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            if {$tbl!=""} {
               foreach l [$tbl get 0 end] {
                  set idx [lindex $l 0]
                  if {$idx == $id} {
                     $tbl selection set $u
                     
                     set namable [::manage_source::namable $s]
                     if {$namable==""} {
                        set name ""
                     } else {
                        set name [::manage_source::naming $s $namable]
                     } 
                     
                     gren_info "NAME ($id) = $name "
                     foreach cata $s {
                        gren_info "[lindex $cata 0] "
                     }
                     gren_info "\n"
                     break
                  }
                  incr u
               }

            }
            break
         }
      }
      incr id
   }
   if {$cpt_grab==0} { return [list 1 "Unknown"] }
   return 
}



proc ::bdi_gui_cata_gestion::center_visu { { tbl "" } } {


   foreach select [$tbl curselection] {
      set id   [lindex [$tbl get $select] 0]
      break
   }
   
   set s [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
   
   ::confVisu::setPos $::audace(visuNo) [::bdi_tools_psf::get_xy s ]

}



proc ::bdi_gui_cata_gestion::console_astroid { { tbl "" } } {


      foreach select [$tbl curselection] {
         set id   [lindex [$tbl get $select] 0]
         break
      }
      
      gren_info "Id source = $id\n"
      set s [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      gren_info "s= $s\n"
      
      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
      ::bdi_tools_psf::gren_astroid othf
      
      

}


#------------------------------------------------------------
## Pour une cle donne, cette fonction fournit sa position 
# dans la liste ASTROID sous forme tklist. Cad qu il faut 
# ajouter les 10 champs supplementaires (Id, ar ,ac ,pr, pc,
# et common fields 
#  @warning   valable seulement pour les clés des otherfield.
# Ne fonctionne pas par exemple pour ra du champ common. Ce sera
# forcement celui du ra des otherfields. 
# @param key nom de la cle  (\sa get_fields_sources_astroid
# @return id sous forme d'un entier 
#
proc ::bdi_gui_cata_gestion::get_id_astroid { key } {
   
   set pos [lsearch [::bdi_tools_psf::get_otherfields_astroid] $key]
   return [expr $pos + 10]
     
}



# Anciennement ::bdi_gui_cata::propagation

proc ::bdi_gui_cata_gestion::propagation { tbl } {


   gren_info "set tbl $tbl  \n"

   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets

   set cataselect [lindex [split [$onglets.nb tab [expr [string range [lindex [split $tbl .] 5] 1 end] -1] -text] ")"] 1]
   set idcata [string range [lindex [split $tbl .] 5] 1 end]
   if {[string compare -nocase $cataselect "ASTROID"] == 0} {
      
      set propalist ""
      foreach select [$tbl curselection] {

         set id   [lindex [$tbl get $select] [::bdi_gui_cata::get_pos_col bdi_idc_lock $idcata]]
         set ar   [lindex [$tbl get $select] [::bdi_gui_cata::get_pos_col astrom_reference $idcata]]
         set ac   [lindex [$tbl get $select] [::bdi_gui_cata::get_pos_col astrom_catalog $idcata]]
         set pr   [lindex [$tbl get $select] [::bdi_gui_cata::get_pos_col photom_reference $idcata]]
         set pc   [lindex [$tbl get $select] [::bdi_gui_cata::get_pos_col photom_catalog $idcata]]
         set name [lindex [$tbl get $select] [::bdi_gui_cata::get_pos_col name $idcata]]
         #gren_info "PROPA: $id $ar $ac $pr $pc $name\n"
         set cata ""
         if {$ac != ""} {
            set cata $ac
         } elseif {$pc != ""} {
            set cata $pc
         }

         set s [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
         set namable [::manage_source::namable $s]

         #gren_info "namable = $namable\n"
         if {$namable==""} {
            set res [tk_messageBox -message "La source dont l'ID est $id ne peut pas etre propagee vers d'autres images car elle n est referencee dans aucun catalogue. Continuer quand meme ?" -type yesno]
            #gren_info "res = $res\n"
            if {$res=="no"} {
               return
            } else {
               continue
            }
         }
         
         #gren_info "\n*** s = $s \n\n"
         if {$cata!=""} {
            set name [::manage_source::naming $s $cata]
         } else {
            gren_info "\n***"
            set cata $namable
            set name [::manage_source::naming $s $cata]
         }
         gren_info "$id :: $ar $ac :: $pr $pc :: $name :: $cata\n"
         lappend propalist [list $cata $name $ar $ac $pr $pc]
      }
      
      if {[llength $propalist] > 0} {
         #gren_info "propalist =$propalist\n"
      } else {
         gren_info "Rien a faire ...\n"
         return
      }

      # on sauve les variables courantes
      set tklist_list_of_columns_sav [array get ::bdi_gui_cata::tklist_list_of_columns]
      
      # on boucle sur les images (sauf celle qui est courrante car rien a propager)
      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

         if {$i == $::tools_cata::id_current_image} { continue }
            
         #gren_info "Image =$i / $::tools_cata::nb_img_list\n"

         array set tklist                             $::bdi_gui_cata::tk_list($i,tklist)
         array set ::bdi_gui_cata::tklist_list_of_columns $::bdi_gui_cata::tk_list($i,list_of_columns)
         array set cataname                           $::bdi_gui_cata::tk_list($i,cataname)
         set current_listsources                      $::bdi_gui_cata::cata_list($i)
         set sources [lindex $current_listsources 1]

         #array set ::bdi_gui_cata::tklist                 $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)
         #array set ::bdi_gui_cata::tklist_list_of_columns $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns)
         #array set ::bdi_gui_cata::cataname               $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
         #set ::tools_cata::current_listsources        $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
         
         #gren_info "cataname = [array get cataname]\n"
         array unset getid
         foreach {x y} [array get cataname] {
            #gren_info "getid=$x $y\n"
            set getid($y) $x
         }

         set nbcol [array size ::bdi_gui_cata::tklist_list_of_columns]
#            gren_info "nbcol =$nbcol\n"

         # Ob boucle sur les sources a propager
         foreach c $propalist {
         
            set cata [lindex $c 0]
            set name [lindex $c 1]
            set ar   [lindex $c 2]
            set ac   [lindex $c 3]
            set pr   [lindex $c 4]
            set pc   [lindex $c 5]

            set err [catch {set idcata $getid($cata)} msg]
            if {$err} {
               continue
            }
            
#               gren_info "$cata ($idcata) :: $name :: $ar $ac :: $pr $pc\n"

            # on boucle sur les sources du cata
            set cpt 1
            set pass "no"
            foreach s $sources {
            
               foreach c $s {
                  if {[lindex $c 0]==$cata} {
                     set namesou [::manage_source::naming $s $cata]
                     if {$namesou==$name} {
                        set pass "ok"
                        break
                     }
                  }
               }
               
               if {$pass=="ok"} {break}
               incr cpt
            }

            if {$pass=="ok"} {

               #gren_info "source retrouvee $cpt $name\n"

               # Modif TKLIST
               foreach {idcata cata} [array get cataname] {

                  set pos [lsearch -index 0 $tklist($idcata) $cpt]
                  if {$pos != -1} {
                     set b [lindex $tklist($idcata) $pos]
                     #gren_info "*** $idcata $cata\n"
                     #gren_info "b = $b\n"
                     set col [::bdi_gui_cata::get_pos_col astrom_reference $idcata]
                     #gren_info "     ar = $ar , $col, [lindex $b $col]\n"
                     set b [lreplace $b $col $col $ar]
                     set col [::bdi_gui_cata::get_pos_col astrom_catalog $idcata]
                     #gren_info "     ac = $ac , $col, [lindex $b $col]\n"
                     set b [lreplace $b $col $col $ac]
                     set col [::bdi_gui_cata::get_pos_col photom_reference $idcata]
                     #gren_info "     pr = $pr , $col, [lindex $b $col]\n"
                     set b [lreplace $b $col $col $pr]
                     set col [::bdi_gui_cata::get_pos_col photom_catalog $idcata]
                     #gren_info "     pc = $pc , $col, [lindex $b $col]\n"
                     set b [lreplace $b $col $col $pc]
                     if {[string compare -nocase $cata "ASTROID"] == 0} {

                        #gren_info "tklist_list_of_columns =  $::bdi_gui_cata::tklist_list_of_columns($idcata)\n"

                        set col [::bdi_gui_cata::get_pos_col flagastrom $idcata]
                        #gren_info "     aar = $ar , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $ar]

                        set col [::bdi_gui_cata::get_pos_col cataastrom $idcata]
                        #gren_info "     aac = $ac , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $ac]

                        set col [::bdi_gui_cata::get_pos_col flagphotom $idcata]
                        #gren_info "     apr = $pr , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $pr]

                        set col [::bdi_gui_cata::get_pos_col cataphotom $idcata]
                        #gren_info "     apc = $pc , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $pc]
                     }
                     set tklist($idcata) [lreplace $tklist($idcata) $pos $pos $b]
                     #gren_info "a modif = [lindex $tklist($idcata) $pos]\n"



                  }
                  
               }
               
               # Modif CATALIST
               set s [lindex $sources [expr $cpt -1]]
               #gren_info "S = $s\n"
               set x  [lsearch -index 0 $s "ASTROID"]
               if {$x>=0} {
                  set a [lindex $s $x]
                  set othf [lindex $a 2]
                  ::bdi_tools_psf::set_by_key othf "flagastrom" $ar
                  ::bdi_tools_psf::set_by_key othf "cataastrom" $ac
                  ::bdi_tools_psf::set_by_key othf "flagphotom" $pr
                  ::bdi_tools_psf::set_by_key othf "cataphotom" $pc
                  set a [lreplace $a 2 2 $othf]
                  #gren_info "a modif = $a\n"
                  set s [lreplace $s $x $x $a]
                  #gren_info "S modif = $s\n"
                  set sources [lreplace $sources [expr $cpt -1] [expr $cpt -1] $s]
               }
            }
            
         }

         # Modification du tk_list
         set ::bdi_gui_cata::tk_list($i,tklist) [array get tklist]

         # Modification du cata_list
         set ::bdi_gui_cata::cata_list($i) [list [lindex $current_listsources 0] $sources]
          
         # break

      }

      # on recupere les variables courantes
      array set ::bdi_gui_cata::tklist_list_of_columns $tklist_list_of_columns_sav

   } else {
      tk_messageBox -message "Le catalogue selectionné doit etre ASTROID" -type ok
   }

}





# Anciennement ::bdi_gui_cata::edit_source

proc ::bdi_gui_cata_gestion::edit_source { tbl } {
# 
#      foreach select [$tbl curselection] {
#         $tbl cellconfigure $select, -text $flag
#      }
#      $tbl rowconfigure -editable yes
#
#   
}





# Anciennement ::bdi_gui_cata::delete_sources

proc ::bdi_gui_cata_gestion::delete_sources { tbl } {

   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets
   set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)

   # On boucle sur les selections (indice de la table affichée de 0 a end)
   set cpt 0
   foreach select [$tbl curselection] {
      
      set id [lindex [$tbl get $select] 0]

      # On boucle sur les onglets
      foreach t [$onglets.nb tabs] {

         set idcata [string range [lindex [split $t .] 5] 1 end]

         # modification de la tklist
         set x [lsearch -index 0 $::bdi_gui_cata::tklist($idcata) $id]
         if {$x != -1} {
            set ::bdi_gui_cata::tklist($idcata) [lreplace $::bdi_gui_cata::tklist($idcata) $x $x]
         }
      }

      # Modification du current_listsources
      set fields [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]
      set sources [lreplace $sources [expr $id - 1] [expr $id - 1]]
      set ::tools_cata::current_listsources [list $fields $sources]

   }
   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::bdi_gui_cata::tklist]
   ::bdi_gui_cata_gestion::charge_image_directaccess
   return

}




proc ::bdi_gui_cata_gestion::delete_sources_allimg { tbl } {

   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets
   set idcata [string range [lindex [split $tbl .] 5] 1 end]
   set cata $::bdi_gui_cata::cataname($idcata)

   if {[string compare -nocase $cata "IMG"] == 0} {
      tk_messageBox -message "Il n'est pas possible d'effacer une source du cata IMG dans toutes les images" -type ok
      return
   }

   set dellist ""
   foreach select [$tbl curselection] {
      set id [lindex [$tbl get $select] [::bdi_gui_cata::get_pos_col bdi_idc_lock $idcata]]
      set s [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set sname [::manage_source::naming $s $cata]
      lappend dellist [list $cata $sname]
   }

   # Si la liste est vide, rien a faire
   if {[llength $dellist] < 1} {
      gren_erreur "La source selectionnee n'a pas ete trouvee dans le cata ($cata) => pb de naming ?\n"
      return
   }

   # Boucle sur les images
   for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

      array set tklist $::bdi_gui_cata::tk_list($i,tklist)
      array set cataname $::bdi_gui_cata::tk_list($i,cataname)
      set current_listsources $::bdi_gui_cata::cata_list($i)
      set sources [lindex $current_listsources 1]

      # Boucle sur les sources a effacer
      foreach dl $dellist {
         # recherche de la source a effacer dans le cata (i.e. onglet courant)
         set idsource 1
         set pass "no"
         foreach s $sources {
            foreach c $s {
               if {[string compare -nocase [lindex $c 0] [lindex $dl 0]] == 0} {
                  set namesou [::manage_source::naming $s [lindex $dl 0]]
                  if {$namesou == [lindex $dl 1]} {
                     set pass "ok"
                     break
                  }
               }
            }
            if {$pass == "ok"} { break }
            incr idsource
         }

         # si la source a ete trouvee alors on l'efface
         if {$pass == "ok"} {
            # Modif TKLIST
            foreach {idcata cata} [array get cataname] {
               set x [lsearch -index 0 $tklist($idcata) $idsource]
               if {$x != -1} {
                  set tklist($idcata) [lreplace $tklist($idcata) $x $x]
               }
            }
            # Modif current_listsources
            set fields [lindex $current_listsources 0]
            set sources [lindex $current_listsources 1]
            set sources [lreplace $sources [expr $idsource-1] [expr $idsource-1]]
            set current_listsources [list $fields $sources]
         }

      }

      set ::bdi_gui_cata::cata_list($i) $current_listsources
      set ::bdi_gui_cata::tk_list($i,tklist) [array get tklist]

   }

   ::bdi_gui_cata_gestion::charge_image_directaccess
   return

} 




# Anciennement ::bdi_gui_cata::set_astrom_ref


proc ::bdi_gui_cata_gestion::set_astrom_ref { tbl } {

   set flag "R"
   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets
   set cataselect [lindex [split [$onglets.nb tab [expr [string range [lindex [split $tbl .] 5] 1 end] -1] -text] ")"] 1]
   set idcata [string range [lindex [split $tbl .] 5] 1 end]

   if {![::tools_cata::is_astrometric_catalog $cataselect]} {
      tk_messageBox -message "Le catalogue selectionné $cataselect n'est pas astrometrique" -type ok
      return
   }

   # On boucle sur les selections (indice de la table affichée de 0 a end)
   foreach select [$tbl curselection] {
      
      set id [lindex [$tbl get $select] 0]

      # On boucle sur les onglets
      foreach t [$onglets.nb tabs] {

         set idcata [string range [lindex [split $t .] 5] 1 end]
         set cata   $::bdi_gui_cata::cataname($idcata)
      
         # Modification du current_listsources
         if {[string compare -nocase $cata "ASTROID"] == 0} {

            set fields [lindex $::tools_cata::current_listsources 0]
            set sources [lindex $::tools_cata::current_listsources 1]

            set a [lindex $sources [expr $id - 1]]
            set cpt 0
            foreach c $a {
               if {[lindex $c 0]=="ASTROID"} {
                  set b [lindex $c 2]
                  set pos [expr [::bdi_gui_cata::get_pos_col flagastrom $idcata] - 10]
                  set b [lreplace $b $pos $pos $flag]
                  set pos [expr [::bdi_gui_cata::get_pos_col cataastrom $idcata] - 10]
                  set b [lreplace $b $pos $pos $cataselect]
                  set c [lreplace $c 2 2 $b]
                  set a [lreplace $a $cpt $cpt $c]
                  set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                  set ::tools_cata::current_listsources [list $fields $sources]
                  break
               }
               incr cpt
            }
            
         }

         # modification de la tklist
         set x [lsearch -index 0 $::bdi_gui_cata::tklist($idcata) $id]
         if {$x != -1} {
            set a [lindex $::bdi_gui_cata::tklist($idcata) $x]
            set b [lreplace $a [::bdi_gui_cata::get_pos_col astrom_reference] [::bdi_gui_cata::get_pos_col astrom_reference] $flag]
            set b [lreplace $b [::bdi_gui_cata::get_pos_col astrom_catalog] [::bdi_gui_cata::get_pos_col astrom_catalog] $cataselect]
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               set b [lreplace $b [::bdi_gui_cata::get_pos_col flagastrom $idcata] [::bdi_gui_cata::get_pos_col flagastrom $idcata] $flag]
               set b [lreplace $b [::bdi_gui_cata::get_pos_col cataastrom $idcata] [::bdi_gui_cata::get_pos_col cataastrom $idcata] $cataselect]
            }
            set ::bdi_gui_cata::tklist($idcata) [lreplace $::bdi_gui_cata::tklist($idcata) $x $x $b]
         }

         # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
         if {"$tbl" == "$t.frmtable.tbl"} {
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col astrom_reference] -text $flag
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col astrom_catalog]   -text $cataselect
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col flagastrom $idcata] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
            }
            continue
         }

         # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
         # l indice de la table.
         set u 0
         foreach x [$t.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col astrom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
               }
               break
            }
            incr u
         }

      }

   }
   #set a [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
   #set x [lsearch -index 0 $a "ASTROID"]
   #set a [lindex [lindex $a $x] 2]
   #gren_info "AV REF $a\n"

   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::bdi_gui_cata::tklist]

   #set a [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
   #set x [lsearch -index 0 $a "ASTROID"]
   #set a [lindex [lindex $a $x] 2]
   #gren_info "SET REF $a\n"

   return
}




# Anciennement ::bdi_gui_cata::set_astrom_mes


proc ::bdi_gui_cata_gestion::set_astrom_mes { tbl } {

   set flag "S"
   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets
   set cataselect [lindex [split [$onglets.nb tab [expr [string range [lindex [split $tbl .] 5] 1 end] -1] -text] ")"] 1]
   set idcata [string range [lindex [split $tbl .] 5] 1 end] 

   # On boucle sur les selections (indice de la table affichée de 0 a end)
   foreach select [$tbl curselection] {
      
      set id [lindex [$tbl get $select] 0]
      gren_info "id = $id\n"

      # On boucle sur les onglets
      set listtabs [lsort -unique [$onglets.nb tabs]]
      foreach t [$onglets.nb tabs] {

         gren_info "t = $t\n"
         set idcata [string range [lindex [split $t .] 5] 1 end]
         set cata   $::bdi_gui_cata::cataname($idcata)
         gren_info "cata = $idcata $cata\n"
         

         # Modification du cata_list_source
         if {[string compare -nocase $cata "ASTROID"] == 0} {

            set fields [lindex $::tools_cata::current_listsources 0]
            set sources [lindex $::tools_cata::current_listsources 1]

            set s [lindex $sources [expr $id - 1]]

            set othf [::bdi_tools_psf::get_astroid_othf_from_source $s] 
            ::bdi_tools_psf::set_by_key othf "flagastrom" $flag
            ::bdi_tools_psf::set_by_key othf "cataastrom" $cataselect
            ::bdi_tools_psf::set_astroid_in_source s othf            
            gren_info "$flag $cataselect\n"
            
            set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $s]
            set ::tools_cata::current_listsources [list $fields $sources]

         }
         
         # modification de la tklist
         set x [lsearch -index 0 $::bdi_gui_cata::tklist($idcata) $id]
         if {$x != -1} {
            set a [lindex $::bdi_gui_cata::tklist($idcata) $x]
            set b [lreplace $a [::bdi_gui_cata::get_pos_col astrom_reference] [::bdi_gui_cata::get_pos_col astrom_reference] $flag]
            set b [lreplace $b [::bdi_gui_cata::get_pos_col astrom_catalog]   [::bdi_gui_cata::get_pos_col astrom_catalog] $cataselect]
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               set b [lreplace $b [::bdi_gui_cata::get_pos_col flagastrom $idcata] [::bdi_gui_cata::get_pos_col flagastrom $idcata] $flag]
               set b [lreplace $b [::bdi_gui_cata::get_pos_col cataastrom $idcata] [::bdi_gui_cata::get_pos_col cataastrom $idcata] $cataselect]
            }
            set ::bdi_gui_cata::tklist($idcata) [lreplace $::bdi_gui_cata::tklist($idcata) $x $x $b]
         }

         # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
         if {"$tbl" == "$t.frmtable.tbl"} {
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col astrom_reference] -text $flag
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col astrom_catalog]   -text $cataselect
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col flagastrom $idcata] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
            }
            continue
         }
         
         # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
         # l indice de la table.
         set u 0
         foreach x [$t.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col astrom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
               }
               break
            }
            incr u
         }
         
         
      }
      
   }
   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::bdi_gui_cata::tklist]
   return
}




# Anciennement ::bdi_gui_cata::unset_flag

proc ::bdi_gui_cata_gestion::unset_flag { tbl } {

   set flag ""
   #gren_info "tbl=$tbl\n"
   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets
   set cataselect [lindex [split [$onglets.nb tab [expr [string range [lindex [split $tbl .] 5] 1 end] -1] -text] ")"] 1]
   set idcata [string range [lindex [split $tbl .] 5] 1 end]

   # On boucle sur les selections (indice de la table affichée de 0 a end)
   foreach select [$tbl curselection] {
      
      set id [lindex [$tbl get $select] 0]

      # On boucle sur les onglets
      foreach t [$onglets.nb tabs] {

         set idcata [string range [lindex [split $t .] 5] 1 end]
         set cata   $::bdi_gui_cata::cataname($idcata)


         # Modification du cata_list_source

         if {[string compare -nocase $cata "ASTROID"] == 0} {

            #gren_info "modif  current_listsources\n"
            set fields [lindex $::tools_cata::current_listsources 0]
            set sources [lindex $::tools_cata::current_listsources 1]

            set a [lindex $sources [expr $id - 1]]
            set x [lsearch -index 0 $a "ASTROID"]
            if {$x != -1} {
               set astroid [lindex $a $x]
               set astroid_oth [lindex $astroid 2]

               ::bdi_tools_psf::set_by_key astroid_oth "flagphotom" $flag
               ::bdi_tools_psf::set_by_key astroid_oth "cataphotom" $flag
               ::bdi_tools_psf::set_by_key astroid_oth "flagastrom" $flag
               ::bdi_tools_psf::set_by_key astroid_oth "cataastrom" $flag

               set astroid [lreplace $astroid 2 2 $astroid_oth]
               set a [lreplace $a $x $x $astroid]

               set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
               set ::tools_cata::current_listsources [list $fields $sources]                  
            }
            
         }

         # modification de la tklist
         set x [lsearch -index 0 $::bdi_gui_cata::tklist($idcata) $id]
         if {$x != -1} {
            set a [lindex $::bdi_gui_cata::tklist($idcata) $x]
            set b [lreplace $a [::bdi_gui_cata::get_pos_col astrom_reference] [::bdi_gui_cata::get_pos_col astrom_reference] $flag]
            set b [lreplace $b [::bdi_gui_cata::get_pos_col astrom_catalog]   [::bdi_gui_cata::get_pos_col astrom_catalog]   $flag]
            set b [lreplace $b [::bdi_gui_cata::get_pos_col photom_reference] [::bdi_gui_cata::get_pos_col photom_reference] $flag]
            set b [lreplace $b [::bdi_gui_cata::get_pos_col photom_catalog]   [::bdi_gui_cata::get_pos_col photom_catalog]   $flag]
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               set b [lreplace $b [::bdi_gui_cata::get_pos_col flagphotom $idcata] [::bdi_gui_cata::get_pos_col flagastrom $idcata] $flag]
               set b [lreplace $b [::bdi_gui_cata::get_pos_col cataphotom $idcata] [::bdi_gui_cata::get_pos_col cataastrom $idcata] $flag]
               set b [lreplace $b [::bdi_gui_cata::get_pos_col flagphotom $idcata] [::bdi_gui_cata::get_pos_col flagphotom $idcata] $flag]
               set b [lreplace $b [::bdi_gui_cata::get_pos_col cataphotom $idcata] [::bdi_gui_cata::get_pos_col cataphotom $idcata] $flag]
            }
            set ::bdi_gui_cata::tklist($idcata) [lreplace $::bdi_gui_cata::tklist($idcata) $x $x $b]
         }

         # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
         if {"$tbl" == "$t.frmtable.tbl"} {
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col astrom_reference] -text $flag
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col astrom_catalog]   -text $flag
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col photom_reference] -text $flag
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col photom_catalog]   -text $flag
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col flagastrom $idcata] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col cataastrom $idcata] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col flagphotom $idcata] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col cataphotom $idcata] -text $flag
            }
            continue
         }
         
         # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
         # l indice de la table.
         set u 0
         foreach x [$t.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col astrom_catalog]   -text $flag
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col photom_catalog]   -text $flag
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col cataastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col cataphotom $idcata] -text $flag
               }
               break
            }
            incr u
         }               

      }
      
   }
   set a [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
   set x [lsearch -index 0 $a "ASTROID"]
   set a [lindex [lindex $a $x] 2]
   #gren_info "AV UNSET $a\n"

   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   
   set a [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
   set x [lsearch -index 0 $a "ASTROID"]
   set a [lindex [lindex $a $x] 2]
   #gren_info "UNSET $a\n"
   
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::bdi_gui_cata::tklist]
   return
}




# Anciennement ::bdi_gui_cata::set_photom_ref

proc ::bdi_gui_cata_gestion::set_photom_ref { tbl } {

   set flag "R"
   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets
   set cataselect [lindex [split [$onglets.nb tab [expr [string range [lindex [split $tbl .] 5] 1 end] -1] -text] ")"] 1]
   set idcata [string range [lindex [split $tbl .] 5] 1 end]

   if {![::tools_cata::is_photometric_catalog $cataselect]} {
      tk_messageBox -message "Le catalogue selectionné $cataselect n'est pas photometrique" -type ok
      return
   }

   # On boucle sur les selections (indice de la table affichée de 0 a end)
   foreach select [$tbl curselection] {
      
      set id [lindex [$tbl get $select] 0]

      # On boucle sur les onglets
      foreach t [$onglets.nb tabs] {

         set idcata [string range [lindex [split $t .] 5] 1 end]
         set cata   $::bdi_gui_cata::cataname($idcata)

         # Modification du cata_list_source
         if {[string compare -nocase $cata "ASTROID"] == 0} {

            set fields [lindex $::tools_cata::current_listsources 0]
            set sources [lindex $::tools_cata::current_listsources 1]

            set a [lindex $sources [expr $id - 1]]
            set cpt 0
            foreach c $a {
               if {[lindex $c 0]=="ASTROID"} {
                  set b [lindex $c 2]
                  set pos [expr [::bdi_gui_cata::get_pos_col flagphotom $idcata] - 10]
                  set b [lreplace $b $pos $pos $flag]
                  set pos [expr [::bdi_gui_cata::get_pos_col cataphotom $idcata] - 10]
                  set b [lreplace $b $pos $pos $cataselect]
                  set c [lreplace $c 2 2 $b]
                  set a [lreplace $a $cpt $cpt $c]
                  set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                  set ::tools_cata::current_listsources [list $fields $sources]
                  break
               }
               incr cpt
            }
            
         }
         
         # modification de la tklist
         set x [lsearch -index 0 $::bdi_gui_cata::tklist($idcata) $id]
         if {$x != -1} {
            set a [lindex $::bdi_gui_cata::tklist($idcata) $x]
            set b [lreplace $a [::bdi_gui_cata::get_pos_col photom_reference] [::bdi_gui_cata::get_pos_col photom_reference] $flag]
            set b [lreplace $b [::bdi_gui_cata::get_pos_col photom_catalog] [::bdi_gui_cata::get_pos_col photom_catalog] $cataselect]
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               set b [lreplace $b [::bdi_gui_cata::get_pos_col flagphotom $idcata] [::bdi_gui_cata::get_pos_col flagphotom $idcata] $flag]
               set b [lreplace $b [::bdi_gui_cata::get_pos_col cataphotom $idcata] [::bdi_gui_cata::get_pos_col cataphotom $idcata] $cataselect]
            }
            set ::bdi_gui_cata::tklist($idcata) [lreplace $::bdi_gui_cata::tklist($idcata) $x $x $b]
         }

         # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
         if {"$tbl" == "$t.frmtable.tbl"} {
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col photom_reference] -text $flag
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col photom_catalog]   -text $cataselect
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col flagphotom $idcata] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
            }
            continue
         }
         
         # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
         # l indice de la table.
         set u 0
         foreach x [$t.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col photom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
               }
               break
            }
            incr u
         }
         
      }
      
   }
   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::bdi_gui_cata::tklist]
   return
}





# Anciennement ::bdi_gui_cata::set_photom_mes

proc ::bdi_gui_cata_gestion::set_photom_mes { tbl } {

   set flag "S"
   set onglets $::bdi_gui_cata_gestion::fen.appli.onglets
   set cataselect [lindex [split [$onglets.nb tab [expr [string range [lindex [split $tbl .] 5] 1 end] -1] -text] ")"] 1]
   set idcata [string range [lindex [split $tbl .] 5] 1 end]

   set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)

   #gren_info "Cata select = $cataselect\n"
   #gren_info "idCata select = $idcata\n"
   #gren_info "flag = $flag\n"

   # On boucle sur les selections (indice de la table affichée de 0 a end)
   foreach select [$tbl curselection] {
      
      set id [lindex [$tbl get $select] 0]

      #gren_info "select = $id ($select)\n"
      #gren_info "tbl = $tbl\n"
      
      # On boucle sur les onglets
      foreach t [$onglets.nb tabs] {

         set idcata [string range [lindex [split $t .] 5] 1 end]
         set cata   $::bdi_gui_cata::cataname($idcata)
         #gren_info "Cata   = $cata\n"
         #gren_info "idCata = $idcata\n"

         # Modification du cata_list_source
         if {[string compare -nocase $cata "ASTROID"] == 0} {

            set fields [lindex $::tools_cata::current_listsources 0]
            set sources [lindex $::tools_cata::current_listsources 1]

            set a [lindex $sources [expr $id - 1]]
            set cpt 0
            foreach c $a {
               if {[lindex $c 0]=="ASTROID"} {
                  set b [lindex $c 2]
                  set pos [expr [::bdi_gui_cata::get_pos_col flagphotom $idcata] - 10]
                  set b [lreplace $b $pos $pos $flag]
                  set pos [expr [::bdi_gui_cata::get_pos_col cataphotom $idcata] - 10]
                  set b [lreplace $b $pos $pos $cataselect]
                  set c [lreplace $c 2 2 $b]
                  set a [lreplace $a $cpt $cpt $c]
                  set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                  set ::tools_cata::current_listsources [list $fields $sources]
                  break
               }
               incr cpt
            }
            
         }

         # modification de la tklist
         set x [lsearch -index 0 $::bdi_gui_cata::tklist($idcata) $id]
         #gren_info "indice tklist($idcata)  =  $x\n"
         if {$x != -1} {
            set a [lindex $::bdi_gui_cata::tklist($idcata) $x]
            #gren_info "a =  $a\n"
            set b [lreplace $a [::bdi_gui_cata::get_pos_col photom_reference] [::bdi_gui_cata::get_pos_col photom_reference] $flag]
            set b [lreplace $b [::bdi_gui_cata::get_pos_col photom_catalog] [::bdi_gui_cata::get_pos_col photom_catalog] $cataselect]
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               set b [lreplace $b [::bdi_gui_cata::get_pos_col flagphotom $idcata] [::bdi_gui_cata::get_pos_col flagphotom $idcata] $flag]
               set b [lreplace $b [::bdi_gui_cata::get_pos_col cataphotom $idcata] [::bdi_gui_cata::get_pos_col cataphotom $idcata] $cataselect]
            }
            set ::bdi_gui_cata::tklist($idcata) [lreplace $::bdi_gui_cata::tklist($idcata) $x $x $b]
         }

         # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
         if {"$tbl" == "$t.frmtable.tbl"} {
            #gren_info "on est ici $t\n"
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col photom_reference] -text $flag
            $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col photom_catalog]   -text $cataselect
            # Rempli les champs correspondants dans le cata ASTROID
            if {[string compare -nocase $cata "ASTROID"] == 0} {
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col flagphotom $idcata] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::bdi_gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
            }
            continue
         }
         
         set u 0
         # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
         # l indice de la table.
         foreach x [$t.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               #gren_info "$id -> $u sur $t\n"
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col photom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::bdi_gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
               }
               break
            }
            incr u
         }

      }

   }
   #set a [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] 0] 
   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::bdi_gui_cata::tklist]
   return
}




# Anciennement ::bdi_gui_cata::psf_popup_auto

proc ::bdi_gui_cata_gestion::psf_popup_manuel { tbl } {

   #gren_info "psf_popup_auto tbl = $tbl \n"

   set worklist ""
   foreach select [$tbl curselection] {
      lappend worklist [list $::tools_cata::id_current_image [lindex [$tbl get $select] 0] ]
   }
   gren_info "worklist = $worklist \n"
   
   
   ::bdi_gui_gestion_source::run $worklist

}



proc ::bdi_gui_cata_gestion::psf_popup_manuel_1obj_allimg { tbl } {

   #gren_info "psf_popup_auto tbl = $tbl \n"

   set worklist ""
   foreach select [$tbl curselection] {
      set ids [lindex [$tbl get $select] 0]
      gren_info "ids = $ids \n"
      break
   }
   gren_info "id_current_image = $::tools_cata::id_current_image \n"
   
   
   set ar [lindex [$tbl get $select] 1]
   set ac [lindex [$tbl get $select] 2]
   set pr [lindex [$tbl get $select] 3]
   set pc [lindex [$tbl get $select] 4]

   # Source Photometrique
   if {$pr!=""&&$pc!=""} {
      gren_info "source taggee photometrique ($pr $pc)\n"

      set s [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) [list 1 [expr $ids - 1]]]
      
      set name [::manage_source::naming $s $pc ]
      gren_info "name=$name\n"
      
      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {
         set ids [::manage_source::name2ids $name ::bdi_gui_cata::cata_list($i)]
         incr ids
         gren_info "num cata = $i ; num source = $ids \n"
         if {$ids!=-1} { lappend worklist [list $i $ids ] }
      }

      if {$worklist!=""} { ::bdi_gui_gestion_source::run $worklist }
      return
   }   

   # Source Astrometrique
   if {$ar!=""&&$ac!=""} {

      gren_info "source taggee astrometrique ($ar $ac)\n"
      # si la source est taggee c est qu elle est dans ASTROID.
      # on recupere le nom de cette source dans le catalogue tagge AC.
      set s [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) [list 1 [expr $ids - 1]]]
      
      set name [::manage_source::naming $s $ac ]
      gren_info "name=$name\n"
      
      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {
         set ids [::manage_source::name2ids $name ::bdi_gui_cata::cata_list($i)]
         incr ids
         gren_info "num cata = $i ; num source = $ids \n"
         if {$ids!=-1} { lappend worklist [list $i $ids ] }
      }

      if {$worklist!=""} { ::bdi_gui_gestion_source::run $worklist }
      return
   }   

   # Source Non Taggee

   gren_info "source non taggee\n"

   # Recherche de l id du cata
   set sub $::bdi_gui_cata_gestion::fen.appli.onglets.nb
   set f [$::bdi_gui_cata_gestion::fen.appli.onglets.nb select]
   set f [split $f $sub]
   set idcata ""
   foreach c $f {
      if {$c==""} {continue}
      append idcata $c
   }
   set idcata  [string range $idcata 1 end]
   gren_info "idcata = $idcata\n"

   # Recherche du nom du cata
   set f [$::bdi_gui_cata_gestion::fen.appli.onglets.nb tab [expr $idcata -1] -text]
   set f [split $f ")"]
   set cataname [string trim [lindex $f 1] ]
   gren_info "cataname=$cataname\n"

   if {$cataname=="ASTROID"} {
      tk_messageBox -message "L identification d une source par le catalogue ASTROID n est pas possible. Veuillez selectionner un autre catalogue." -type ok
      return
   }
   
   # Recherche du nom de la source
   set s [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) [list 1 [expr $ids - 1]]]
   gren_info "s=$s\n"
   set name [::manage_source::naming $s $cataname]
   gren_info "name=$name\n"
   
   for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {
      set ids [::manage_source::name2ids $name ::bdi_gui_cata::cata_list($i)]
      incr ids
      gren_info "num cata = $i ; num source = $ids \n"
      if {$ids!=-1} { lappend worklist [list $i $ids ] }
   }

   if {$worklist!=""} { ::bdi_gui_gestion_source::run $worklist }
   return
}



proc ::bdi_gui_cata_gestion::psf_popup_auto { tbl } {

   set list_id ""
   foreach select [$tbl curselection] {
      lappend list_id [lindex [$tbl get $select] 0]
   }
   
   ::bdi_gui_cata_gestion::psf_auto_go "popup" $list_id

}




# Anciennement ::bdi_gui_cata_gestion::psf_auto_go_one

proc ::bdi_gui_cata_gestion::psf_auto_go_one { { worktype "oneimage" } { nd_sources "" } { current "" } } {

   #gren_info "id_current_image = $::tools_cata::id_current_image \n"
   gren_info "ASTROID sur l'image $::tools_cata::id_current_image\n"
   puts "ASTROID sur l'image $::tools_cata::id_current_image"

   set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)

   set fields  [lindex $::tools_cata::current_listsources 0]
   set sources [lindex $::tools_cata::current_listsources 1]

   set pass "no"
   set id 0
   set cpt 0

   if {$worktype == "oneimage" || $worktype == "flag" } {
      set current 0
   }

   set tt0 [clock clicks -milliseconds]
   #gren_info "Sources selectionnees ($nd_sources): \n"
   #set current 
   foreach s $sources {

      incr id
      
      if {$worktype == "flag" || $worktype == "all_flag" } {
         set pos [lsearch -index 0 $s "ASTROID"]
         if {$pos==-1} { continue }
         set othf [ lindex [lindex $s $pos] 2]
         set flag [::bdi_tools_psf::get_val othf "flagastrom"]
         if {$flag == ""} { continue }
      }
      if {$worktype == "list_id"} {
         set bpass "no"
         foreach mysource $::bdi_gui_cata_gestion::list_id {
            set mycata [::manage_source::name_cata $mysource]
            set name [::manage_source::naming $s $mycata]
            if {$name==$mysource} {
               set bpass "yes"
               break
            }
         }
         if {$bpass == "no"} { continue }
      }
      
      
      ::bdi_gui_cata_gestion::set_popupprogress $current $nd_sources

      #gren_info "S=$s\n"
      set err [ catch {set err_psf [::bdi_tools_psf::get_psf_source s "no" "no"] } msg ]
      
      if {$id==0} {
         gren_info "S=$s\n"
         set name [::manage_source::naming $s [::manage_source::namable $s] ]
         gren_erreur "$id ($name)-> ($err) ($err_psf) ($msg)\n"
      }
      #set name [::manage_source::naming $s [::manage_source::namable $s] ]

      #gren_erreur "$id ($name)-> ($err) ($err_psf) ($msg)\n"
      if {$err} {
         ::manage_source::delete_catalog_in_source s "ASTROID"
      } else {
         if { $err_psf != ""} {
            gren_erreur "*ERREUR PSF err_psf ($id): $err_psf\n"
         } else {
            set pass "yes"
         }
      }
      set sources [lreplace $sources [expr $id - 1 ] [expr $id - 1 ] $s]
      incr current
      
      incr cpt
      set tt [format "%.0f" [expr ([clock clicks -milliseconds] - $tt0)/$cpt/1000.*($nd_sources-$current)]]
      # gren_info "ID = $id $current (plus que $tt secondes)\n"

   }
   #gren_info "psf_auto_go_one : pass = $pass\n"
   if {$pass=="no"} { return $current }
   
   set ::tools_cata::current_listsources [lreplace $::tools_cata::current_listsources 1 1 $sources]
   ::bdi_tools_psf::set_fields_astroid ::tools_cata::current_listsources
   
   #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

   ::bdi_tools_psf::set_mag ::tools_cata::current_listsources
   
   #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

   # pack les resultats
   set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
   
   if {$worktype == "oneimage" || $worktype == "flag" || $worktype == "list_id" } {
      ::tools_cata::current_listsources_to_tklist
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::bdi_gui_cata::tklist]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::bdi_gui_cata::cataname]
      ::bdi_gui_cata_gestion::charge_image_directaccess
   }
   
   return $current
}



# nouvelle adaptation pour travailler sur des worklist

proc ::bdi_gui_cata_gestion::psf_auto_go_one2 { type nd_sources current } {

   #gren_info "id_current_image = $::tools_cata::id_current_image \n"
   gren_info "ASTROID sur l'image $::tools_cata::id_current_image\n"

   set fields  [lindex $::tools_cata::current_listsources 0]
   set sources [lindex $::tools_cata::current_listsources 1]

   set pass "no"
   set cpt 0

   #set tt0 [clock clicks -milliseconds]
   #gren_info "Sources selectionnees ($nd_sources): \n"

   foreach ids $::bdi_gui_cata_gestion::worklist($::tools_cata::id_current_image) {
      
      if {$::bdi_gui_cata_gestion::psf_auto_gui_annul_activ == 1} {break}
      
      set s [lindex $sources $ids]
      
      #gren_info "idcata = $::tools_cata::id_current_image\n"
      #gren_info "ids = $ids\n"
      #gren_info "list_of_name = [::manage_source::list_of_name $s]\n"
               
      set err [ catch {set err_psf [::bdi_tools_psf::get_psf_source s "no" "no"] } msg ]
      
      if {$err} {
         gren_erreur "**ERREUR PSF (ids=$ids): (Errnum:$err) (msg:$msg)\n"
         ::manage_source::delete_catalog_in_source s "ASTROID"
      } else {
         if { $err_psf != "-"} {
         gren_erreur "**WARNING PSF (ids=$ids): (Errnum:$err) (msg:$msg)\n"
         } else {
            set pass "yes"
         }
      }

      set sources [lreplace $sources $ids $ids $s]
      incr current
      
      incr cpt
      ::bdi_gui_cata_gestion::set_popupprogress $current $nd_sources
      #set tt [format "%.0f" [expr ([clock clicks -milliseconds] - $tt0)/$cpt/1000.*($nd_sources-$current)]]
      # gren_info "ID = $id $current (plus que $tt secondes)\n"
   }

   #gren_info "psf_auto_go_one : pass = $pass\n"
   if {$pass=="no"} { return $current }
   
   set ::tools_cata::current_listsources [lreplace $::tools_cata::current_listsources 1 1 $sources]
   ::bdi_tools_psf::set_fields_astroid ::tools_cata::current_listsources
   
   #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
   ::bdi_tools_psf::set_mag ::tools_cata::current_listsources
   
   #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
   return $current
}





proc ::bdi_gui_cata_gestion::psf_auto_go { type nd_sources } {
   
   $::bdi_gui_cata::fenpopuppsf.appli.boutons.fermer configure -state disabled
   
   set tt0 [clock clicks -milliseconds]
   set cpt 0
   set current 0
   foreach ::tools_cata::id_current_image $::bdi_gui_cata_gestion::worklist(list_id) {

      if {$::bdi_gui_cata_gestion::psf_auto_gui_annul_activ == 1} {break}

      set ::bdi_gui_cata_gestion::directaccess $::tools_cata::id_current_image
      ::bdi_gui_cata_gestion::charge_image_directaccess
      set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
      set current [::bdi_gui_cata_gestion::psf_auto_go_one2 $type $nd_sources $current]
      set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      ::tools_cata::current_listsources_to_tklist
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::bdi_gui_cata::tklist]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::bdi_gui_cata::cataname]
   }

   set ::bdi_gui_cata_gestion::directaccess 1
   ::bdi_gui_cata_gestion::charge_image_directaccess
   set tt [format "%.0f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   tk_messageBox -message "Traitements photometriques effectues en $tt secondes\nPensez a sauvegarder !" -type ok

   $::bdi_gui_cata::fenpopuppsf.appli.boutons.fermer configure -state active

}






proc ::bdi_gui_cata_gestion::psf_auto_go_all { type list_id nd_sources } {

   #gren_info "id_current_image = $::tools_cata::id_current_image \n"
   set cpt 0

   set current 0
  
   for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image<=$::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {

      set ::bdi_gui_cata_gestion::directaccess $::tools_cata::id_current_image
      ::bdi_gui_cata_gestion::charge_image_directaccess
      set current [::bdi_gui_cata_gestion::psf_auto_go_one $flag $nd_sources $current]
      
   }

   ::tools_cata::current_listsources_to_tklist
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::bdi_gui_cata::tklist]
   set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::bdi_gui_cata::cataname]

   set ::bdi_gui_cata_gestion::directaccess 1
   ::bdi_gui_cata_gestion::charge_image_directaccess


}




# Anciennement ::bdi_gui_cata::psf_auto

proc ::bdi_gui_cata_gestion::psf_auto { type { tbl ""} } {

   array unset ::bdi_gui_cata_gestion::worklist
   set nd_sources 0
   
   switch $type {
      "current_image" {
         set nd_sources [llength [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1]]
         lappend ::bdi_gui_cata_gestion::worklist(list_id) $::tools_cata::id_current_image
         for {set ids 0} {$ids < $nd_sources} {incr ids} {
            lappend ::bdi_gui_cata_gestion::worklist($::tools_cata::id_current_image) $ids
         }
      }
      
      "srpt" {
         foreach select [$tbl curselection] {
            set name [lindex [$tbl get $select] 0]
            foreach date $::bdi_tools_astrometry::listref($name) {
               set idcata [::tools_cata::date2idcata $date]
               if {[info exists ::bdi_gui_cata_gestion::worklist(list_id)]} {
                  if {!($idcata in $::bdi_gui_cata_gestion::worklist(list_id))} {
                     lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
                  }
               } else {
                  lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
               }
               set ids [::manage_source::name2ids $name ::bdi_gui_cata::cata_list($idcata)]
               lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
               incr nd_sources
            }
         }
      }

      "sret" {
         # quel est l objet selectionne ?
         gren_info "Source selectionnee = $::bdi_tools_astrometry::srpt_selected \n"

         # recupere la liste des images selectionnes
         foreach select [$tbl curselection] {
            set ids [expr [lindex [$tbl get $select] 0] -1]
            set date [lindex [$tbl get $select] 1]
            set idcata [::tools_cata::date2idcata $date]
            lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
            lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
            incr nd_sources
         }
      }
      
      "sspt" {
         foreach select [$tbl curselection] {
            set name [lindex [$tbl get $select] 0]
            foreach date $::bdi_tools_astrometry::listscience($name) {
               set idcata [::tools_cata::date2idcata $date]
               if {[info exists ::bdi_gui_cata_gestion::worklist(list_id)]} {
                  if {!($idcata in $::bdi_gui_cata_gestion::worklist(list_id))} {
                     lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
                  }
               } else {
                  lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
               }
               set ids [::manage_source::name2ids $name ::bdi_gui_cata::cata_list($idcata)]
               lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
               incr nd_sources
            }
         }
      }

      "sset" {
         # quel est l objet selectionne ?
         gren_info "Source selectionnee = $::bdi_tools_astrometry::sspt_selected \n"

         # recupere la liste des images selectionnes
         foreach select [$tbl curselection] {
            set ids [expr [lindex [$tbl get $select] 0] -1]
            set date [lindex [$tbl get $select] 1]
            set idcata [::tools_cata::date2idcata $date]
            lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
            lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
            incr nd_sources
         }
      }

      "dspt" {
         foreach select [$tbl curselection] {
            set date [lindex [$tbl get $select] 0]
            foreach name $::bdi_tools_astrometry::listdate($date) {
               set idcata [::tools_cata::date2idcata $date]
               if {[info exists ::bdi_gui_cata_gestion::worklist(list_id)]} {
                  if {!($idcata in $::bdi_gui_cata_gestion::worklist(list_id))} {
                     lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
                  }
               } else {
                  lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
               }
               set ids [::manage_source::name2ids $name ::bdi_gui_cata::cata_list($idcata)]
               lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
               incr nd_sources
            }
         }
      }

      "dset" {
         # quel est l image selectionnee ?
         set date $::bdi_tools_astrometry::dspt_selected
         set idcata [::tools_cata::date2idcata $date]
         gren_info "Cata selectionne,id = $idcata, date = $date\n"
         lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
         # recupere la liste des sources selectionnes
         foreach select [$tbl curselection] {
            set ids [expr [lindex [$tbl get $select] 0] -1]
            lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
            incr nd_sources
         }
      }

      "all_flag" {
         gren_info "nb_img_list = $::tools_cata::nb_img_list\n"

         for {set idcata 1} {$idcata<=$::tools_cata::nb_img_list} {incr idcata} {
            set sources [lindex $::bdi_gui_cata::cata_list($idcata) 1]
            set ids -1
            foreach s $sources {
               incr ids
               set pos [lsearch -index 0 $s "ASTROID"]
               if {$pos==-1} { continue }
               set othf [ lindex [lindex $s $pos] 2]
               set flagastrom [::bdi_tools_psf::get_val othf "flagastrom"]
               set flagphotom [::bdi_tools_psf::get_val othf "flagphotom"]
               #gren_info "ids flagastrom flagphotom = $ids $flagastrom $flagphotom\n"
               
               if {$flagastrom == "" && $flagphotom == "" } { continue }

               # ok la source est flaguee S ou M
               #gren_info "ok la source est flaguee\n"

               if {[info exists ::bdi_gui_cata_gestion::worklist(list_id)]} {
                  if {!($idcata in $::bdi_gui_cata_gestion::worklist(list_id))} {
                     lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
                  }
               } else {
                  lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
               }
               lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
               incr nd_sources
            }
         }
      }
      
      "all" {
         for {set idcata 1} {$idcata<=$::tools_cata::nb_img_list} {incr idcata} {
            set nbs [llength [lindex $::bdi_gui_cata::cata_list($idcata) 1]]
            incr nd_sources $nbs
            lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
            for {set ids 0} {$ids < $nbs} {incr ids} {
               lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
            }
         }
      }
      
      "popup_gestion_current_image" {
         lappend ::bdi_gui_cata_gestion::worklist(list_id) $::tools_cata::id_current_image
         foreach select [$tbl curselection] {
            set ids [lindex [$tbl get $select] 0]
            lappend ::bdi_gui_cata_gestion::worklist($::tools_cata::id_current_image) $ids
            incr nd_sources
         }
      }
      "popup_gestion_all_image" {
          gren_erreur "A faire\n"
      }

      "current_image_flag" {
         lappend ::bdi_gui_cata_gestion::worklist(list_id) $::tools_cata::id_current_image
         set sources [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1]
         set ids -1
         foreach s $sources {
            incr ids
            set pos [lsearch -index 0 $s "ASTROID"]
            if {$pos==-1} { continue }
            set othf [ lindex [lindex $s $pos] 2]
            set flag [::bdi_tools_psf::get_val othf "flagastrom"]
            if {$flag == ""} { continue }
            # ok la source est flaguee S ou M
            lappend ::bdi_gui_cata_gestion::worklist($::tools_cata::id_current_image) $ids
            incr nd_sources
         }

      }
      "popup_photom_table" {
         foreach select [$::bdi_gui_cdl::data_source curselection] {
            set ids [expr [lindex [$::bdi_gui_cdl::data_source get $select] 2] -1]
            set idcata [lindex [$::bdi_gui_cdl::data_source get $select] 3]
            lappend ::bdi_gui_cata_gestion::worklist(list_id) $idcata
            lappend ::bdi_gui_cata_gestion::worklist($idcata) $ids
            incr nd_sources
         }
      }


   # fin du switch
   }


   gren_info "nd_sources = $nd_sources\n"
   if {$nd_sources==0} {return 1}
   ::bdi_gui_cata_gestion::psf_auto_gui $type $nd_sources $tbl
   
   return 0
}



proc ::bdi_gui_cata_gestion::psf_auto_gui { type nd_sources { tbl ""} } {
   
   global private

   ::audace::psf_init $::audace(visuNo)
   set private(psf_toolbox,$::audace(visuNo),duree) "***"
   
   set ::bdi_gui_cata_gestion::popupprogress 0

   set ::bdi_gui_cata::fenpopuppsf .popuppsf
   if { [winfo exists $::bdi_gui_cata::fenpopuppsf] } {
      wm withdraw $::bdi_gui_cata::fenpopuppsf
      wm deiconify $::bdi_gui_cata::fenpopuppsf
      focus $::bdi_gui_cata::fenpopuppsf
      return
   }
   toplevel $::bdi_gui_cata::fenpopuppsf -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cata::fenpopuppsf ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cata::fenpopuppsf ] "+" ] 2 ]
   wm geometry $::bdi_gui_cata::fenpopuppsf +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_cata::fenpopuppsf 1 1
   wm title $::bdi_gui_cata::fenpopuppsf "PSF"
   wm protocol $::bdi_gui_cata::fenpopuppsf WM_DELETE_WINDOW "destroy $::bdi_gui_cata::fenpopuppsf"

   set frm $::bdi_gui_cata::fenpopuppsf.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cata::fenpopuppsf -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      ::audace::psf_gui_methodes $::audace(visuNo) $frm
      #::bdi_gui_psf::gui_configuration $frm

      set center  [frame $frm.infocenter -borderwidth 0 -cursor arrow -relief groove]
      pack $center -in $frm -anchor c -side top -expand 0 -fill x -padx 10 -pady 5

      set info  [frame $center.info -borderwidth 1 -cursor arrow -relief groove]
      pack $info -in $center -anchor c -side top -expand 0 -padx 10 -pady 5

          label $info.l -text "Nb sources = $nd_sources" 
          pack  $info.l -side left -padx 2 -pady 0
          label $info.a -text " (1 source =" 
          pack  $info.a -side left -padx 2 -pady 0
          label $info.b -textvariable private(psf_toolbox,$::audace(visuNo),duree)
          pack  $info.b -side left -padx 2 -pady 0
          label $info.c -text " sec)" 
          pack  $info.c -side left -padx 2 -pady 0

      set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          set    pf [ ttk::progressbar $data.p -variable ::bdi_gui_cata_gestion::popupprogress -orient horizontal -length 200 -mode determinate]
          pack   $pf -in $data -side top

      set data  [frame $frm.boutons -borderwidth 1 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -padx 10 -pady 5

          button $data.fermer -state active -text "Fermer" -relief "raised" \
             -command "::bdi_gui_cata_gestion::psf_auto_gui_fermer"
#             pack   $data.fermer -side right -anchor e -padx 0 -padx 10 -pady 5

          button $data.annul -state active -text "Annuler" -relief "raised" \
             -command "::bdi_gui_cata_gestion::psf_auto_gui_annul"
#             pack   $data.annul -side top -anchor c -padx 0 -padx 10 -pady 5

          button $data.go -state active -text "Go" -relief "raised" \
             -command "::bdi_gui_cata_gestion::psf_auto_gui_go $type $nd_sources"
#             pack   $data.go -side left -anchor w -padx 0 -padx 10 -pady 5

          grid $data.go     -row 0 -column 0 -sticky nws  -padx 10 -pady 5
          grid $data.annul  -row 0 -column 1 -sticky news -padx 10 -pady 5
          grid $data.fermer -row 0 -column 2 -sticky nes  -padx 10 -pady 5
          # -columnspan 2 -ipadx 10 -ipady 10 -padx 10 -pady 10
}


proc ::bdi_gui_cata_gestion::psf_auto_gui_go { type nd_sources } {

   # Sauvegarde des parametres de mesure de psf
   ::audace::psf_close_to_conf $::audace(visuNo)

   set ::bdi_gui_cata_gestion::psf_auto_gui_annul_activ 0
   $::bdi_gui_cata::fenpopuppsf.appli.boutons.fermer configure -state disabled 
   ::bdi_gui_cata_gestion::psf_auto_go $type $nd_sources 
   $::bdi_gui_cata::fenpopuppsf.appli.boutons.fermer configure -state active
   ::bdi_gui_cata_gestion::psf_auto_gui_fermer 
}

proc ::bdi_gui_cata_gestion::psf_auto_gui_annul {  } {
   set ::bdi_gui_cata_gestion::psf_auto_gui_annul_activ 1
}
proc ::bdi_gui_cata_gestion::psf_auto_gui_fermer {  } {
   
   ::audace::psf_close_to_conf $::audace(visuNo)
   destroy $::bdi_gui_cata::fenpopuppsf
   set ::bdi_gui_cata_gestion::variable_cloture 0

}



# Anciennement ::bdi_gui_cata::selectall

 proc ::bdi_gui_cata_gestion::selectall { tbl } {
   
   # Selectionne toutes les sources
   $tbl selection set 0 end

   # Affiche les sources selectionnees
   cleanmark
   set selected [$tbl get 0 end]
   foreach s $selected {
      set id [lindex $s 0]
      set ra [lindex $s [::bdi_gui_cata::get_pos_col ra]]
      set dec [lindex $s [::bdi_gui_cata::get_pos_col dec]]
      affich_un_rond $ra $dec red 1
   }
   return

}



#--------------------------------------------------
#  ::bdi_gui_cata_gestion::cmdButton1Click { frame }
#--------------------------------------------------
#
#    fonction  : 
#    
#
#    variables en entree :
#        frame = reference de l'objet graphique de la selection
#
#    variables en sortie : void
#
#--------------------------------------------------

# Anciennement ::bdi_gui_cata::cmdButton1Click

proc ::bdi_gui_cata_gestion::cmdButton1Click { w args } {

   set color red
   set width 1
   cleanmark
   gren_info "Nbs selected images: [llength [$w curselection]]\n"
   foreach select [$w curselection] {
      set id [lindex [$w get $select] 0]
      set ra [lindex [$w get $select] [::bdi_gui_cata::get_pos_col ra]]
      set dec [lindex [$w get $select] [::bdi_gui_cata::get_pos_col dec]]
      #gren_info "line = [$w get $select]\n"
      #gren_info "pos ra dec = [::bdi_gui_cata::get_pos_col ra] [::bdi_gui_cata::get_pos_col dec]\n"
      #gren_info "ra dec = $ra $dec\n"
      if {$ra==""||$dec==""} {return}
      affich_un_rond $ra $dec $color $width
   }

   set s [lindex [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
   #gren_info "ls = [lindex $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 1]\n"
   #gren_info "fieldlist =[lindex  $::bdi_gui_cata::cata_list($::tools_cata::id_current_image) 0] \n"
   #gren_info "id = $id\n"
   #gren_info "s = $s\n"
   
   set xy [::bdi_tools_psf::get_xy s ]
   #gren_info "xy = $xy\n"
   ::confVisu::setPos $::audace(visuNo) $xy
   
   return

}



# Anciennement ::bdi_gui_cata::gestion_cata
# Gui de gestion des fichiers catalogues
# interface de gestion, selection de sources de reference pour 
# l astrometrie et photometrie.
# effacement des sources
# mesure des photocentre
# mode manuel de visualisation des sources dans l image.
# traitement par lot d images.

proc ::bdi_gui_cata_gestion::go { img_list } {

   global audace
   global conf bddconf

   set tt0 [clock clicks -milliseconds]

   set ::bdi_gui_cata_gestion::state_gestion 1
   set ::bdi_gui_cata_gestion::directaccess 1
   set ::bdi_gui_cata_gestion::progress 0
   set ::tools_cata::mem_use 0
   set ::tools_cata::mem_total 0

   ::bdi_gui_cata_gestion::inittoconf
   ::bdi_gui_cata_gestion::charge_gestion_cata $img_list 

   #--- Geometry
   if { ! [info exists conf(bddimages,geometry_cata_gestion)] } { set conf(bddimages,geometry_cata_gestion) "+100+100" }
   set bddconf(geometry_cata_gestion) $conf(bddimages,geometry_cata_gestion)

   #--- Creation de la fenetre
   set ::bdi_gui_cata_gestion::fen .gestion_cata
   if { [winfo exists ::bdi_gui_cata_gestion::fen] } {
      wm withdraw $::bdi_gui_cata_gestion::fen
      wm deiconify $::bdi_gui_cata_gestion::fen
      focus $::bdi_gui_cata_gestion::fen
      return
   }

   #--- GUI
   toplevel $::bdi_gui_cata_gestion::fen -class Toplevel
   wm geometry $::bdi_gui_cata_gestion::fen $bddconf(geometry_cata_gestion)
   wm resizable $::bdi_gui_cata_gestion::fen 1 1
   wm title $::bdi_gui_cata_gestion::fen "Gestion du CATA"
   wm protocol $::bdi_gui_cata_gestion::fen WM_DELETE_WINDOW "::bdi_gui_cata_gestion::fermer"

   set frm $::bdi_gui_cata_gestion::fen.appli

   #--- Cree un frame general
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cata_gestion::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      #--- Cree un frame general
      set menubar [frame $frm.menubar -cursor arrow -borderwidth 1 -relief raised]
      pack $menubar -in $frm -side top -fill x

        #--- menu Catalogues
        menubutton $menubar.catalog -text "Catalogues" -underline 0 -menu $menubar.catalog.menu
        pack $menubar.catalog -side left

        menu $menubar.catalog.menu -tearoff 0
         $menubar.catalog.menu add cascade -label "Astrometrie" -menu $menubar.catalog.menu.astrom
         $menubar.catalog.menu add cascade -label "Photometrie" -menu $menubar.catalog.menu.photom
         $menubar.catalog.menu add separator
         $menubar.catalog.menu add command -label "Verifier" -command "::gui_verifcata::run" -state normal
         $menubar.catalog.menu add command -label "Effacer" -command "::bdi_gui_cata_delete::run" -state normal
         $menubar.catalog.menu add command -label "Personnel" -command "" -state disabled
         $menubar.catalog.menu add command -label "Astroid" -command "" -state disabled
         $menubar.catalog.menu add separator
         $menubar.catalog.menu add command -label "Supprimer" -command "" -state disabled

            #--- Sous menu astrometrie
            menu $menubar.catalog.menu.astrom -tearoff 0
            $menubar.catalog.menu.astrom add command -label "Definir sciences et references" -accelerator "Ctrl-a" \
               -command "::bdi_gui_set_ref_science::go astrom" 
            $menubar.catalog.menu.astrom add command -label "Defaire tous les catalogues" \
               -command "::bdi_gui_set_ref_science::unset astrom"
            $menubar.catalog.menu.astrom add command -label "Effacer les marques" -accelerator "Ctrl-e" \
               -command "::bdi_gui_set_ref_science::clean"

            #--- Sous menu photometrie
            menu $menubar.catalog.menu.photom -tearoff 0
            $menubar.catalog.menu.photom add command -label "Definir sciences et references" -accelerator "Ctrl-p" \
               -command "::bdi_gui_set_ref_science::go photom" 
            $menubar.catalog.menu.photom add command -label "Defaire tous les catalogues" \
               -command "::bdi_gui_set_ref_science::unset photom"
            $menubar.catalog.menu.photom add command -label "Effacer les marques" -accelerator "Ctrl-e" \
               -command "::bdi_gui_set_ref_science::clean"


        #--- menu PSF
        menubutton $menubar.psf -text "PSF" -underline 0 -menu $menubar.psf.menu
        menu $menubar.psf.menu -tearoff 0

          $menubar.psf.menu add command -label "Manuel sur l'image" -command "::bdi_gui_gestion_source::run current"
          $menubar.psf.menu add command -label "Auto sur l'image" -command "::bdi_gui_cata_gestion::psf_auto current_image"
          $menubar.psf.menu add command -label "Auto toutes images" -command "::bdi_gui_cata_gestion::psf_auto all"
          $menubar.psf.menu add command -label "Auto sources Flag sur l'image" -command "::bdi_gui_cata_gestion::psf_auto current_image_flag"
          $menubar.psf.menu add command -label "Auto sources Flag toutes images" -command "::bdi_gui_cata_gestion::psf_auto all_flag"

          #$This.frame0.file.menu add command -label "$caption(bddimages_recherche,delete_list)" -command " ::bddimages_recherche::cmd_list_delete $This.frame6.liste.tbl "
          pack $menubar.psf -side left


      #--- Cree un frame general
      set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #----- 
          button $actions.charge -state active -text "Charge" -relief "raised" -command "::bdi_gui_cata_gestion::charge_memory"
          pack   $actions.charge -in $actions -side left -anchor w -padx 0

          set    pf [ ttk::progressbar $actions.p -variable ::bdi_gui_cata_gestion::progress -orient horizontal -length 200 -mode determinate]
          pack   $pf -in $actions -side left

          label $actions.lab1 -text "Img ("
          pack  $actions.lab1 -in $actions -side left -padx 5 -pady 0
          label $actions.lab2 -textvariable ::tools_cata::id_current_image
          pack  $actions.lab2 -in $actions -side left -padx 5 -pady 0
          label $actions.lab3 -text "/"
          pack  $actions.lab3 -in $actions -side left -padx 5 -pady 0
          label $actions.lab4 -textvariable ::tools_cata::nb_img_list
          pack  $actions.lab4 -in $actions -side left -padx 5 -pady 0
          label $actions.lab5 -text ")"
          pack  $actions.lab5 -in $actions -side left -padx 5 -pady 0

      set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5

         pack [ttk::notebook $onglets.nb] -expand yes -fill both 


      #--- Cree un frame pour afficher les boutons
      set infoimg [frame $frm.infoimg -borderwidth 0 -cursor arrow -relief groove]
      pack $infoimg -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un label
          label $infoimg.lab1 -textvariable ::tools_cata::id_current_image
          pack  $infoimg.lab1 -in $infoimg -side left -padx 5 -pady 0
          #--- Cree un label
          label $infoimg.lab2 -textvariable ::tools_cata::current_image_name
          pack  $infoimg.lab2 -in $infoimg -side left -padx 5 -pady 0
          #--- Cree un label
          label $infoimg.lab3 -textvariable ::tools_cata::current_image_date
          pack  $infoimg.lab3 -in $infoimg -side left -padx 5 -pady 0


     #--- Cree un frame pour afficher les boutons
     set navigation [frame $frm.navigation -borderwidth 0 -cursor arrow -relief groove]
     pack $navigation -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $navigation.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::bdi_gui_cata_gestion::back" 
          pack $navigation.back -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $navigation.next -text "Suivant" -borderwidth 2 -takefocus 1 \
                -command "::bdi_gui_cata_gestion::next" 
          pack $navigation.next -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          #--- Cree un label, une entree et un bouton
          label $navigation.lab -text "Access direct a l'image : "
          pack $navigation.lab -in $navigation -side left -padx 5 -pady 0
          entry $navigation.val -relief sunken \
             -textvariable ::bdi_gui_cata_gestion::directaccess -width 6 \
             -justify center
          pack $navigation.val -in $navigation -side left -pady 1 -anchor w
          button $navigation.go -text "Go" -borderwidth 1 -takefocus 1 \
                -command "::bdi_gui_cata_gestion::charge_image_directaccess" 
          pack $navigation.go -side left -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0


     #--- Cree un frame pour afficher bouton fermeture
     set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
     pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $boutonpied.annuler -text "Fermer" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cata_gestion::fermer"
          pack $boutonpied.annuler -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $boutonpied.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cata::save_cata"
          pack $boutonpied.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $boutonpied.aide -text "Aide" -borderwidth 2 -takefocus 1 \
             -command ""
          pack $boutonpied.aide -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          set ::bdi_gui_cata::gui_info [label $boutonpied.info -text ""]
          pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
          set ::bdi_gui_cata::gui_info2 [label $boutonpied.info2 -text ""]
          pack $::bdi_gui_cata::gui_info2 -in $boutonpied -side top -padx 3 -pady 3

   # Bindings
   bind $::bdi_gui_cata_gestion::fen <Key-F1> { ::console::GiveFocus }
   bind $::bdi_gui_cata_gestion::fen <Control-Key-a> { ::bdi_gui_set_ref_science::go astrom }
   bind $::bdi_gui_cata_gestion::fen <Control-Key-p> { ::bdi_gui_set_ref_science::go photom }
   bind $::bdi_gui_cata_gestion::fen <Control-Key-e> { ::bdi_gui_set_ref_science::clean }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_cata_gestion::fen

   ::bdi_gui_cata_gestion::charge_memory

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Gestion du CATA in $tt sec \n"

}
