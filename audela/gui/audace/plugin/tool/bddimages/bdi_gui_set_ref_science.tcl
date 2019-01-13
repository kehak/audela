## @file bdi_gui_set_ref_science.tcl
# @brief     M&eacute;thodes d&eacute;di&eacute;es &agrave; la selection des sources de r&eacute;f&eacute;rence et de science en fonction des catalogues
# @author    Frederic Vachier and Jerome Berthier
# @version   1.0
# @date      2013
# @copyright GNU Public License.
# @par Ressource
# @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_set_ref_science.tcl]
# @endcode

# $Id: bdi_gui_set_ref_science.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_set_ref_science
# @brief M&eacute;thodes d&eacute;di&eacute;es &agrave; la selection des sources de r&eacute;f&eacute;rence et de science en fonction des catalogues
# @pre Requiert le fichier d'internationalisation \c bdi_gui_set_ref_science.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_set_ref_science {

   variable use_mask
   variable mask
   variable use_saturation
   variable saturation
   variable use_visu
   variable progress
   variable liste_cata

   variable cata_science
   variable cata_ref
   variable cata_type

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_set_ref_science.cap ]\""

}


#------------------------------------------------------------
## Initialisation des variables du namespace a partir de la conf Audace
# @return void
#
proc ::bdi_gui_set_ref_science::inittoconf { } {

   global conf

   ::bdi_gui_set_ref_science::clean

   set ::bdi_gui_set_ref_science::list_cata [list SKYBOT UCAC2 UCAC3 UCAC4 TYCHO2 NOMAD1 PPMX PPMXL USNOA2 2MASS WFIBC SDSS PANSTARRS GAIA1]
   set ::bdi_gui_set_ref_science::progress 0

   if {! [info exists ::bdi_gui_set_ref_science::use_mask] } {
      if {[info exists conf(bddimages,astrometry,set_ref_science,use_mask)]} {
         set ::bdi_gui_set_ref_science::use_mask $conf(bddimages,astrometry,set_ref_science,use_mask)
      } else {
         set ::bdi_gui_set_ref_science::use_mask 1
      }
   }
   if {! [info exists ::bdi_gui_set_ref_science::mask] } {
      if {[info exists conf(bddimages,astrometry,set_ref_science,mask)]} {
         set ::bdi_gui_set_ref_science::mask $conf(bddimages,astrometry,set_ref_science,mask)
      } else {
         set ::bdi_gui_set_ref_science::mask 10
      }
   }
   if {! [info exists ::bdi_gui_set_ref_science::use_saturation] } {
      if {[info exists conf(bddimages,astrometry,set_ref_science,use_saturation)]} {
         set ::bdi_gui_set_ref_science::use_saturation $conf(bddimages,astrometry,set_ref_science,use_saturation)
      } else {
         set ::bdi_gui_set_ref_science::use_saturation 0
      }
   }
   if {! [info exists ::bdi_gui_set_ref_science::saturation] } {
      if {[info exists conf(bddimages,astrometry,set_ref_science,saturation)]} {
         set ::bdi_gui_set_ref_science::saturation $conf(bddimages,astrometry,set_ref_science,saturation)
      } else {
         set ::bdi_gui_set_ref_science::saturation 65000
      }
   }
   if {! [info exists ::bdi_gui_set_ref_science::use_visu] } {
      if {[info exists conf(bddimages,astrometry,set_ref_science,use_visu)]} {
         set ::bdi_gui_set_ref_science::use_visu $conf(bddimages,astrometry,set_ref_science,use_visu)
      } else {
         set ::bdi_gui_set_ref_science::use_visu 0
      }
   }

}


#------------------------------------------------------------
## Enregistrement dans la conf Audace des variables du namespace
# @return void
#
proc ::bdi_gui_set_ref_science::closetoconf { } {

   global conf

   set conf(bddimages,astrometry,set_ref_science,use_mask)       $::bdi_gui_set_ref_science::use_mask
   set conf(bddimages,astrometry,set_ref_science,mask)           $::bdi_gui_set_ref_science::mask
   set conf(bddimages,astrometry,set_ref_science,use_saturation) $::bdi_gui_set_ref_science::use_saturation
   set conf(bddimages,astrometry,set_ref_science,saturation)     $::bdi_gui_set_ref_science::saturation
   set conf(bddimages,astrometry,set_ref_science,use_visu)       $::bdi_gui_set_ref_science::use_visu

}


#------------------------------------------------------------
## Fermeture de la GUI
# @return void
#
proc ::bdi_gui_set_ref_science::fermer { } {

   ::bdi_gui_set_ref_science::closetoconf
   destroy $::bdi_gui_set_ref_science::fen

}


#------------------------------------------------------------
## Efface les dessins dans la Visu
# @return void
#
proc ::bdi_gui_set_ref_science::clean { } {

   cleanmark
   efface_carre

}


#------------------------------------------------------------
## Selectionne les sources de reference et de science a partir des choix faits.
# @return void
#
proc ::bdi_gui_set_ref_science::apply { } {

   # Sanity check
   if {[string length $::bdi_gui_set_ref_science::cata_science] < 1 && [string length $::bdi_gui_set_ref_science::cata_ref] < 1} {
      tk_messageBox -message "$caption(bdi_gui_set_ref_science,noselect)" -type ok
      return
   }

   set ofs [expr {$::bdi_gui_set_ref_science::cata_type == "photom" ? 2 : 0}]
   ::bdi_gui_set_ref_science::clean

   # Log
   gren_info "Apply: nb images to process = $::tools_cata::nb_img_list\n"
   gren_info "  Type = $::bdi_gui_set_ref_science::cata_type\n"
   gren_info "  Science = $::bdi_gui_set_ref_science::cata_science\n"
   gren_info "  Reference = $::bdi_gui_set_ref_science::cata_ref\n"
   set msg "  Mask = $::bdi_gui_set_ref_science::use_mask"
   if {$::bdi_gui_set_ref_science::use_mask} {
      set msg "  $msg (border = $::bdi_gui_set_ref_science::mask pixels)"
   }
   gren_info "$msg\n"

   # Go
   for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image <= $::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {

      set current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      gren_info " -> processing image $::tools_cata::id_current_image / $::tools_cata::nb_img_list ([::bddimages_liste::lget $current_image filename])\n"
      ::bdi_gui_set_ref_science::set_progress $::tools_cata::id_current_image $::tools_cata::nb_img_list

      set current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)

      # Recupere les NAXISi de l'image courante
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      # Definition du mask
      set mx_min $::bdi_gui_set_ref_science::mask
      set mx_max [expr $naxis1 - $::bdi_gui_set_ref_science::mask]
      set my_min $::bdi_gui_set_ref_science::mask
      set my_max [expr $naxis2 - $::bdi_gui_set_ref_science::mask]

      # Defini les champs et les sources de l'image courante
      set fields [lindex $current_listsources 0]
      set sources [lindex $current_listsources 1]
      array set tklist $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)
      array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
      foreach {x y} [array get cataname] {
         set getid($y) $x
      }

      set ids 0
      foreach s $sources {
         incr ids
         set posastroid [lsearch -index 0 $s "ASTROID"]
         if {$posastroid != -1} {
            set astroid [lindex $s $posastroid]
            set othf [lindex $astroid 2]
            set px [::bdi_tools_psf::get_val othf "xsm"]
            set py [::bdi_tools_psf::get_val othf "ysm"]
            set pixmax [::bdi_tools_psf::get_val othf "pixmax"]

            set accept 1
            # Applique le mask si demande
            if {$::bdi_gui_set_ref_science::use_mask} {
               if {$::bdi_gui_set_ref_science::use_visu} {
                  affich_un_carre_xy $mx_min $my_min $mx_max $my_max blue
               }
               if {$px <= $mx_min || $px >= $mx_max || $py <= $my_min || $py >= $my_max} { set accept 0 }
            }
            # Applique la limite de saturation si demande
            if {$::bdi_gui_set_ref_science::use_saturation} {
               if {$pixmax > $::bdi_gui_set_ref_science::saturation} { set accept 0 }
            }

            if {$accept} {
               set change 0
               set p [lsearch -index 0 $s $::bdi_gui_set_ref_science::cata_science]
               #gren_info "$ids $p cata_science = $::bdi_gui_set_ref_science::cata_science\n"
               if {$p != -1} {
                  #gren_info "cata_science = $::bdi_gui_set_ref_science::cata_science\n"
                  set apr "S"
                  set apc $::bdi_gui_set_ref_science::cata_science
                  ::bdi_tools_psf::set_by_key othf "flag$::bdi_gui_set_ref_science::cata_type" $apr
                  ::bdi_tools_psf::set_by_key othf "cata$::bdi_gui_set_ref_science::cata_type" $apc
                  set change 1
               }

               set p [lsearch -index 0 $s $::bdi_gui_set_ref_science::cata_ref]
               if {$p != -1} {
                  set apr "R"
                  set apc $::bdi_gui_set_ref_science::cata_ref
                  ::bdi_tools_psf::set_by_key othf "flag$::bdi_gui_set_ref_science::cata_type" $apr
                  ::bdi_tools_psf::set_by_key othf "cata$::bdi_gui_set_ref_science::cata_type" $apc
                  set change 1
               }

               if {$change == 1} {
                  if {$::bdi_gui_set_ref_science::use_visu} {
                     affich_un_rond_xy $px $py green 4 2
                  }
                  #gren_info "othf = $othf\n"
                  set astroid [lreplace $astroid 2 2 $othf]
                  set s [lreplace $s $posastroid $posastroid $astroid]
                  set sources [lreplace $sources [expr $ids-1] [expr $ids-1] $s]
                  # Modif TKLIST
                  foreach {idcata cata} [array get cataname] {
                     set x [lsearch -index 0 $tklist($idcata) $ids]
                     if {$x != -1} {
                        set b [lindex $tklist($idcata) $x]
                        set b [lreplace $b [expr 1+$ofs] [expr 2+$ofs] $apr $apc]
                        if {$cata == "ASTROID" } {
                           set p1 [::bdi_gui_cata_gestion::get_id_astroid "flag$::bdi_gui_set_ref_science::cata_type"]
                           set p2 [::bdi_gui_cata_gestion::get_id_astroid "cata$::bdi_gui_set_ref_science::cata_type"]
                           set b [lreplace $b $p1 $p1 $apr]
                           set b [lreplace $b $p2 $p2 $apc]
                        }
                        set tklist($idcata) [lreplace $tklist($idcata) $x $x $b]
                     }
                  }
               } else {
                  if {$::bdi_gui_set_ref_science::use_visu} {
                     affich_un_rond_xy $px $py orange 4 2
                  }
               }
            } else {
               if {$::bdi_gui_set_ref_science::use_visu} {
                  affich_un_rond_xy $px $py red 4 2
               }
            }

         }
      }
      set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) [list $fields $sources]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get tklist]

   }

   ::bdi_gui_set_ref_science::set_progress 0 100
   ::bdi_gui_cata_gestion::charge_image_directaccess

}


#------------------------------------------------------------
## Affiche le masque dans la visu
# @return void
#
proc ::bdi_gui_set_ref_science::view_mask { } {

   ::bdi_gui_set_ref_science::clean

   # Recupere les infos de la 1ere image
   set ::tools_cata::id_current_image 1
   set current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
   set current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
   # Recupere les NAXISi de l'image courante
   set tabkey [::bddimages_liste::lget $current_image "tabkey"]
   set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   # Definition du mask
   set mx_min $::bdi_gui_set_ref_science::mask
   set mx_max [expr $naxis1 - $::bdi_gui_set_ref_science::mask]
   set my_min $::bdi_gui_set_ref_science::mask
   set my_max [expr $naxis2 - $::bdi_gui_set_ref_science::mask]

   affich_un_carre_xy $mx_min $my_min $mx_max $my_max blue

}


#------------------------------------------------------------
## @brief Désélectionne les sources de référence et de science astrométrique ou photométrique
#  @param cata_type string astrom ou photom
#  @return void
#
proc ::bdi_gui_set_ref_science::unset { cata_type } {

   # Sanity check
   if {$cata_type != "astrom" && $cata_type != "photom"} {
      tk_messageBox -message "$caption(bdi_gui_set_ref_science,notype)" -type ok
      return
   }
   gren_info "Unset $cata_type flags ...\n"

   # init
   ::bdi_gui_set_ref_science::inittoconf
   set ofs [expr {$cata_type == "photom" ? 2 : 0}]

   # Log
   gren_info "Unset: nb images to process = $::tools_cata::nb_img_list\n"

   # Go
   for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image <= $::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {

      set current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      gren_info " -> processing image $::tools_cata::id_current_image / $::tools_cata::nb_img_list ([::bddimages_liste::lget $current_image filename])\n"

      set current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)

      # Defini les champs et les sources de l'image courante
      set fields [lindex $current_listsources 0]
      set sources [lindex $current_listsources 1]
      array set tklist $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)
      array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
      foreach {x y} [array get cataname] {
         set getid($y) $x
      }

      set ids 0
      foreach s $sources {
         incr ids
         set posastroid [lsearch -index 0 $s "ASTROID"]
         if {$posastroid != -1} {
            set astroid [lindex $s $posastroid]
            set othf [lindex $astroid 2]

            set change 0
            foreach cata $::bdi_gui_set_ref_science::list_cata {
               set p [lsearch -index 0 $s $cata]
               if {$p != -1} {
                  set apr ""
                  set apc ""
                  ::bdi_tools_psf::set_by_key othf "flag$cata_type" $apr
                  ::bdi_tools_psf::set_by_key othf "cata$cata_type" $apc
                  set change 1
               }
            }

            if {$change == 1} {
               set astroid [lreplace $astroid 2 2 $othf]
               set s [lreplace $s $posastroid $posastroid $astroid]
               set sources [lreplace $sources [expr $ids-1] [expr $ids-1] $s]
               # Modif TKLIST
               foreach {idcata cata} [array get cataname] {
                  set x [lsearch -index 0 $tklist($idcata) $ids]
                  if {$x != -1} {
                     set b [lindex $tklist($idcata) $x]
                     set b [lreplace $b [expr 1+$ofs] [expr 2+$ofs] $apr $apc]
                     if {$cata == "ASTROID" } {
                        #gren_info "poss :[::bdi_gui_cata::get_pos_col "flag$cata_type" $posastroid] [::bdi_gui_cata::get_pos_col "cata$cata_type" $posastroid]\n"
                        set p1 [::bdi_gui_cata_gestion::get_id_astroid "flag$cata_type"]
                        set p2 [::bdi_gui_cata_gestion::get_id_astroid "cata$cata_type"]
                        #gren_info "$p1 $p2\n"
                        set b [lreplace $b $p1 $p1 $apr]
                        set b [lreplace $b $p2 $p2 $apc]
                     }
                     set tklist($idcata) [lreplace $tklist($idcata) $x $x $b]

                  }
               }
            }

         }
      }
      set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) [list $fields $sources]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get tklist]

   }

   ::bdi_gui_cata_gestion::charge_image_directaccess

}


#------------------------------------------------------------
## Affichage de la barre de progression
# @return void
#
proc ::bdi_gui_set_ref_science::set_progress { cur max } {

   set ::bdi_gui_set_ref_science::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
   update

}


#------------------------------------------------------------
## Affiche la GUI de sélection des sources de référence et de science astrométrique ou photométrique
#  @param cata_type string astrom ou photom
#  @return void
#
proc ::bdi_gui_set_ref_science::go { cata_type } {

   global audace caption

   # Sanity check
   if {$cata_type != "astrom" && $cata_type != "photom"} {
      tk_messageBox -message "$caption(bdi_gui_set_ref_science,notype)" -type ok
      return
   }
   set ::bdi_gui_set_ref_science::cata_type $cata_type

   # init
   ::bdi_gui_set_ref_science::inittoconf

   set list_cata [concat {" "} $::bdi_gui_set_ref_science::list_cata]
   set nb_cata [llength $list_cata]

   # Icon
   image create photo view
   view configure -file [file join $audace(rep_plugin) tool bddimages icons view_s.gif]

   #--- Creation de la fenetre
   set ::bdi_gui_set_ref_science::fen .set_ref_science
   if { [winfo exists $::bdi_gui_set_ref_science::fen] } {
      wm withdraw $::bdi_gui_set_ref_science::fen
      wm deiconify $::bdi_gui_set_ref_science::fen
      focus $::bdi_gui_set_ref_science::fen
      return
   }
   toplevel $::bdi_gui_set_ref_science::fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_set_ref_science::fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_set_ref_science::fen ] "+" ] 2 ]
   wm geometry $::bdi_gui_set_ref_science::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_set_ref_science::fen 1 1
   wm title $::bdi_gui_set_ref_science::fen "References / Sciences ($::bdi_gui_set_ref_science::cata_type)"
   wm protocol $::bdi_gui_set_ref_science::fen WM_DELETE_WINDOW "::bdi_gui_set_ref_science::fermer"

   set frm $::bdi_gui_set_ref_science::fen.appli

   frame $frm -borderwidth 0 -cursor arrow
   pack $frm -in $::bdi_gui_set_ref_science::fen -anchor c -side top -expand 1 -fill both -padx 10 -pady 5

      label $frm.lab -text "$caption(bdi_gui_set_ref_science,select)" -relief groove -borderwidth 1 -padx 10 -pady 7
      pack  $frm.lab -in $frm -side top -padx 5 -pady 5 -anchor c

      set sciences [frame $frm.sciences -borderwidth 0 -cursor arrow -relief groove]
      pack $sciences -in $frm -anchor s -side top -expand 1 -fill x -padx 10 -pady 5

          label $sciences.lab -width 15 -text "Sciences"
          pack  $sciences.lab -in $sciences -anchor e -side left -fill x -expand 0 -padx 5 -pady 0

          ComboBox $sciences.combo \
             -height $nb_cata \
             -relief sunken -borderwidth 1 -editable 0 \
             -textvariable ::bdi_gui_set_ref_science::cata_science \
             -values $list_cata
          pack $sciences.combo -anchor center -side left -fill x -expand 1

      set references [frame $frm.references -borderwidth 0 -cursor arrow -relief groove]
      pack $references -in $frm -anchor s -side top -expand 1 -fill x -padx 10 -pady 5

          label $references.lab -width 15  -text "References"
          pack  $references.lab -in $references -anchor e -side left -fill x -expand 0 -padx 5 -pady 0

          ComboBox $references.combo \
             -height $nb_cata \
             -relief sunken -borderwidth 1 -editable 0 \
             -textvariable ::bdi_gui_set_ref_science::cata_ref \
             -values $list_cata
          pack $references.combo -anchor center -side left -fill x -expand 1

      set options [frame $frm.options -borderwidth 1 -cursor arrow -relief groove]
      pack $options -in $frm -anchor c -side top -expand 1 -fill x -padx 10 -pady 5

         set mask [frame $options.mask -borderwidth 0 -cursor arrow -relief groove]
         pack $mask -in $options -anchor c -side top -expand 1 -fill x -padx 10 -pady 5

             checkbutton $mask.check -highlightthickness 0 -text "$caption(bdi_gui_set_ref_science,msgmask)" -variable ::bdi_gui_set_ref_science::use_mask
             pack $mask.check -in $mask -anchor c -side left -padx 5 -pady 0

             entry $mask.val -relief sunken -textvariable ::bdi_gui_set_ref_science::mask -borderwidth 2 -width 6 -justify center
             pack  $mask.val -in $mask -anchor c -side left -padx 5 -pady 0

             label $mask.lab -text "$caption(bdi_gui_set_ref_science,unimask)"
             pack  $mask.lab -in $mask -anchor c -side left -padx 5 -pady 0

             button $mask.voir -image view -borderwidth 1 -command "::bdi_gui_set_ref_science::view_mask"
             pack $mask.voir -in $mask -anchor c -side left -padx 5 -pady 0

         set satu [frame $options.satu -borderwidth 0 -cursor arrow -relief groove]
         pack $satu -in $options -anchor c -side top -expand 1 -fill x -padx 10 -pady 5

             checkbutton $satu.check -highlightthickness 0 -text "$caption(bdi_gui_set_ref_science,msgflux)" -variable ::bdi_gui_set_ref_science::use_saturation
             pack $satu.check -in $satu -anchor c -side left -padx 5 -pady 0

             entry $satu.val -relief sunken -textvariable ::bdi_gui_set_ref_science::saturation -borderwidth 1 -width 6 -justify center
             pack  $satu.val -in $satu -anchor c -side left -padx 5 -pady 0

             label $satu.lab -text "ADU"
             pack  $satu.lab -in $satu -anchor c -side left -padx 5 -pady 0

         set voir [frame $options.voir -borderwidth 0 -cursor arrow -relief groove]
         pack $voir -in $options -anchor c -side top -expand 1 -fill x -padx 10 -pady 5

             checkbutton $voir.check -highlightthickness 0 -text "$caption(bdi_gui_set_ref_science,voirsou)" -variable ::bdi_gui_set_ref_science::use_visu
             pack $voir.check -in $voir -anchor c -side left -padx 5 -pady 0

      set progressbar [frame $frm.progressbar -borderwidth 0 -cursor arrow -relief groove]
      pack $progressbar -in $frm -anchor c -side top -expand 1 -fill x -padx 10 -pady 5

          set pf [ ttk::progressbar $progressbar.p -variable ::bdi_gui_set_ref_science::progress -orient horizontal -length 300 -mode determinate]
          pack $pf -in $progressbar -side top -expand 0

      set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
      pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $boutonpied.fermer -text "$caption(bdi_gui_set_ref_science,fermer)" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_set_ref_science::fermer"
          pack $boutonpied.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $boutonpied.enregistrer -text "$caption(bdi_gui_set_ref_science,apply)" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_set_ref_science::apply"
          pack $boutonpied.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   # Bindings
   bind $::bdi_gui_set_ref_science::fen <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_set_ref_science::fen

}
