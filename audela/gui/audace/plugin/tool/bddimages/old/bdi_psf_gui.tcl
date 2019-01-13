## \file bdi_psf_gui.tcl
#  \brief     Traitement des psf des images
#  \details   This class is used to demonstrate a number of section commands.
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2008
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_go.tcl]
#  \endcode
#  \todo      normaliser les noms des fichiers sources 

#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_psf_gui.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_psf_gui.tcl
# Description    : Traitement des psf des images
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_psf_gui.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace psf_gui
#
#--------------------------------------------------


## Declaration du namespace \c psf_gui .
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Pour developpeur seulement
#  @todo      faire en sorte que la psf s appelle depuis la recherche 
namespace eval psf_gui {



# Anciennement ::gui_cata::psf_fermer
# Ferme la boite de dialogue appellee
# depuis la gestion des cata pour faire l analyse des psf en mode manuel

   proc ::psf_gui::gestion_mode_manuel_fermer { } {

      if {[info exists ::psf_gui::visucrop]} {
         ::confVisu::close $::psf_gui::visucrop
         unset ::psf_gui::visucrop
      }
      ::psf_tools::closetoconf
      destroy $::psf_gui::fen
      ::cata_gestion_gui::charge_image_directaccess

   }


# Anciennement ::gui_cata::init_psf
# Initialise la boite de dialogue appellee
# depuis la gestion des cata pour faire l analyse des psf en mode manuel

   proc ::psf_gui::gestion_mode_manuel_init { sou } {

      ::psf_tools::inittoconf

      if {[info exists ::gui_cata::current_psf]} {unset ::gui_cata::current_psf}
      foreach key [list xsm ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta] {
         set ::gui_cata::current_psf($key) "-"
      }
      foreach key [ list xflux xcent xfwhm xfond yflux ycent yfwhm yfond ] {
         set ::gui_cata::current_psf($key) "-"
      }


      if { $sou == "" } {
         set ::gui_cata::psf_radius 15
         set ::gui_cata::psf_name_source "Unknown"
         set ::gui_cata::list_of_cata ""
      } else {
         
      }

      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
      set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      


   }



# Anciennement ::gui_cata::grab_sources_from_gui


   proc ::psf_gui::grab_sources {  } {
 

      set color red
      set width 2
      cleanmark

      set ambigue "no"

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
         return
      }
      set ::psf_gui::gui_catalogues_data ""


      gren_info "** GRAB SOURCE 136 : [::psf_gui::aff_catas [lindex $::tools_cata::current_listsources {1 136}]]\n"

      set sources [lindex $::tools_cata::current_listsources 1]


      set id 1
      set cpt_grab 0
      foreach s $sources {

         foreach cata $s {
            
            set namable [::manage_source::namable $s]
            if {$namable==""} {
               set name ""
            } else {
               set name [::manage_source::naming $s $namable]
            } 

            set pass "no"
            
            set ra  [lindex [lindex $cata 1] 0]
            set dec [lindex [lindex $cata 1] 1]
            set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
               set pass "yes"
               set xpass $x
               set ypass $y
            }

            if {$pass=="yes"} {

               #gren_info "**NAME = $name \n"
               incr cpt_grab
               if {$cpt_grab>1} { set ambigue "yes"}

               #gren_info "NAME = $name \n"
               #gren_info "xpass ypass  = $xpass $ypass\n"
               #gren_info "rect = $rect\n"
               affich_un_rond_xy $xpass $ypass green 60 1

               # gren_info "cpt_grab = $cpt_grab\n"

               gren_info "SOURCE FOUND : ID = $id NAME = $name CATAS = "
               set pos 0
               foreach cata $s {
                  gren_info "[lindex $cata 0] "
                  set ra0  [lindex [lindex $cata 1] 0]
                  set dec0 [lindex [lindex $cata 1] 1]
                  set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
                  set x [lindex $xy 0]
                  set y [lindex $xy 1]
                  lappend ::psf_gui::gui_catalogues_data [list $pos [lindex $cata 0] $id $x $y ]
                  incr pos
               }
               gren_info "\n"

               if {$ambigue == "yes" } {
                  set result [list 1 "Ambigue" $id $xpass $ypass $s]
               } else {
                  set result [list 0 "" $id $xpass $ypass $s]
               }
               break
            }
         }
         incr id
      }
      if {$cpt_grab==0} { return [list 1 "Unknown"] }
      return $result
   }
 
 
 
 
 
 


 
 




   proc ::psf_gui::grab_sourcesold {  } {
 

      set color red
      set width 2
      cleanmark

      set ambigue "no"

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
         return
      }
      set ::psf_gui::gui_catalogues_data ""


      gren_info "** GRAB SOURCE 136 : [::psf_gui::aff_catas [lindex $::tools_cata::current_listsources {1 136}]]\n"

      set sources [lindex $::tools_cata::current_listsources 1]


      set id 1
      set cpt_grab 0
      foreach s $sources {

         foreach cata $s {
            
            set namable [::manage_source::namable $s]
            if {$namable==""} {
               set name ""
            } else {
               set name [::manage_source::naming $s $namable]
            } 
            if {$id == 137} {
               gren_info "name = $name\n"
            }
            
            set x -100
            set y -100
            set pass "no"
            
            if {[lindex $cata 0] == "IMG"} {
               set ra [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
               #gren_info "IMG ra dec : $ra $dec \n"
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                  set pass "yes"
                  set xpass $x
                  set ypass $y
               }
            }
            
            if {[lindex $cata 0] == "ASTROID"} {
               set ra [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
               #gren_info "ASTROID ra dec ($id) : $ra $dec \n"
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



               #gren_info "**NAME = $name \n"
               incr cpt_grab
               if {$cpt_grab>1}  { set ambigue "yes"}

               #gren_info "NAME = $name \n"
               #gren_info "xpass ypass  = $xpass $ypass\n"
               #gren_info "rect = $rect\n"
               affich_un_rond_xy $xpass $ypass green 60 1

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


               # gren_info "cpt_grab = $cpt_grab\n"

               gren_info "SOURCE FOUND : ID = $id NAME = $name CATAS = "
               set pos 0
               foreach cata $s {
                  gren_info "[lindex $cata 0] "

                  set ra0  [lindex [lindex $cata 1] 0]
                  set dec0 [lindex [lindex $cata 1] 1]
                  set xy [ buf$::audace(bufNo) radec2xy [ list $ra0 $dec0 ] ]
                  set x [lindex $xy 0]
                  set y [lindex $xy 1]
                  lappend ::psf_gui::gui_catalogues_data [list $pos [lindex $cata 0] $id $x $y ]

                  if {[lindex $cata 0]==$namable} {
                     set ra  [lindex [lindex $cata 1] 0]
                     set dec [lindex [lindex $cata 1] 1]
                     #affich_un_rond $ra $dec $color $width
                  }
                  incr pos
               }
               gren_info "\n"

               if {$ambigue == "yes" } {
                  set result [list 1 "Ambigue" $id $xpass $ypass $s]
               } else {
                  set result [list 0 "" $id $xpass $ypass $s]
               }
               break
            }
         }
         incr id
      }
      if {$cpt_grab==0} { return [list 1 "Unknown"] }
      return $result
   }
 
 
 
 
















# Anciennement ::gui_cata::psf_save
# sauve les resultats de la psf d'une source connue selectionnee dans l image
# appelee depuis l analyse des psf en mode manuel

   proc ::psf_gui::gestion_mode_manuel_save { } {

       gren_info "Maj id = $::gui_cata::psf_id_source \n"

       set current_image [ lindex  $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] ]
       set commundatejj  [::bddimages_liste::lget $current_image "commundatejj"]
       set dateiso       [ mc_date2iso8601 $commundatejj ]
       set ls            [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]

       set ls [lreplace $ls [expr $::gui_cata::psf_id_source - 1] [expr $::gui_cata::psf_id_source - 1] $::gui_cata::psf_source]
       set ::gui_cata::cata_list($::tools_cata::id_current_image) [lreplace $::gui_cata::cata_list($::tools_cata::id_current_image) 1 1 $ls]

       set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
       gren_info "new source = $::gui_cata::psf_source\n"

       ::tools_cata::current_listsources_to_tklist

       set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]

       $::psf_gui::fen.appli.actions.save  configure -state disabled
   
   }



# Anciennement ::gui_cata::psf_new
# sauve les resultats de la psf d'une source inconnue selectionnee dans l image
# appelee depuis l analyse des psf en mode manuel


   proc ::psf_gui::gestion_mode_manuel_new { } {

      # "ra" "dec" "poserr" "mag" "magerr"
      # "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux"
      # "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
      # "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" 
      # "name" "flagastrom" "flagphotom" "cataastrom" "cataphotom"

       #$::gui_cata::cata_list($::tools_cata::id_current_image)

       set current_image [ lindex  $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] ]
       set commundatejj  [::bddimages_liste::lget $current_image "commundatejj"]
       set dateiso       [ mc_date2iso8601 $commundatejj ]
       set ls            [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]
       lappend ls $::gui_cata::psf_source

       #gren_info "id_current_image = $::tools_cata::id_current_image\n"
       #gren_info "date = $dateiso\n"
       #gren_info "new source = $::gui_cata::psf_source\n"

       set ::gui_cata::cata_list($::tools_cata::id_current_image) [lreplace $::gui_cata::cata_list($::tools_cata::id_current_image) 1 1 $ls]
       gren_info "New id = [llength [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]]\n"

       set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

       ::tools_cata::current_listsources_to_tklist

       set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]

       $::psf_gui::fen.appli.actions.new  configure -state disabled


   }







# Anciennement ::gui_cata::psf_button_psf
# Effectue l analyse d'une psf pour un rayon donne
# appele depuis l analyse des psf en mode manuel


   proc ::psf_gui::one_psf { } {

      global bddconf

      if {$::gui_cata::psf_name_source=="Unknown"&&[info exists ::gui_cata::psf_best_sol]} {
         unset ::gui_cata::psf_best_sol
      }

      if {[info exists ::gui_cata::psf_best_sol]} {

         set xcent [expr int([lindex $::gui_cata::psf_best_sol 0])]
         set ycent [expr int([lindex $::gui_cata::psf_best_sol 1])]
         ::psf_tools::psf_box $xcent $ycent

      } else {
         set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
         if {$err>0 || $rect ==""} {
            cleanmark
            return -code 2
         }
         ::psf_tools::psf_box $rect
      }
      switch $::gui_cata::psf_name_source {
         "Erreur" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         "Unknown" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state normal
         }
         "Ambigue" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         default {
            $::psf_gui::fen.appli.actions.save configure -state normal
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
      }

#     AFFICHAGE DES RONDS

      catch {

         cleanmark
      
         set r $::gui_cata::current_psf(delta)
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green $r 2

         set r [expr 3.0*sqrt((pow($::gui_cata::current_psf(xfwhm),2)+pow($::gui_cata::current_psf(yfwhm),2))/2.0)]

         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) red 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) blue $r 2
      
      }
   }



# S applique a une nouvelle visu et un nouveau buffer

   proc ::psf_gui::one_psf_crop { } {



      if {[info exists ::gui_cata::psf_best_sol]} {

         set xcent [expr int([lindex $::gui_cata::psf_best_sol 0]-$::psf_gui::xref)]
         set ycent [expr int([lindex $::gui_cata::psf_best_sol 1]-$::psf_gui::yref)]
         gren_info "xcent ycent = $xcent $ycent \n"
         ::psf_tools::psf_box_crop $xcent $ycent

      } 


#     AFFICHAGE DES RONDS

      catch {

         clean_crop $::psf_gui::visucrop
      
         set r $::gui_cata::current_psf(delta)

         set xpm [expr  $::gui_cata::current_psf(xsm)   - $::psf_gui::xref]
         set ypm [expr  $::gui_cata::current_psf(ysm)   - $::psf_gui::yref]
         set xfg [expr  $::gui_cata::current_psf(xcent) - $::psf_gui::xref]
         set yfg [expr  $::gui_cata::current_psf(ycent) - $::psf_gui::yref]

         affich_un_rond_xy_crop $xpm $ypm green  0 1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xpm $ypm green $r 2 $::psf_gui::visucrop

         set r [expr 3.0*sqrt((pow($::gui_cata::current_psf(xfwhm),2)+pow($::gui_cata::current_psf(yfwhm),2))/2.0)]

         affich_un_rond_xy_crop $xfg $yfg  red 0  1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xfg $yfg blue $r 2 $::psf_gui::visucrop
      
      }
   }










# Anciennement ::gui_cata::psf_box_auto
# Effectue une analyse de psf, en methode globale
# cad qu il fait une statistique sur une multitude de rayon de recherche


   proc ::psf_gui::box_global { } {
   
      global bddconf

      #::gui_cata::psf_cataname
      #::gui_cata::psf_source
      #::gui_cata::psf_name_source
      #::gui_cata::psf_id_source 


      if {$::gui_cata::psf_name_source == "Unknown" } {
         set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
         if {$err>0 || $rect ==""} {
            cleanmark
            return
         }
         set result_fitgauss [buf$bddconf(bufno) fitgauss $rect]
         ::psf_tools::result_fitgauss $result_fitgauss
         set xcent  [lindex $result_fitgauss 1]  
         set ycent  [lindex $result_fitgauss 5]  

         set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]} msg ]
         if {$err} {
            ::console::affiche_erreur "$err $msg\n"
            return
         }
         set ra  [lindex $a 0]
         set dec [lindex $a 1]

         set othf [::tools_cata::get_img_null]
         set othf [lreplace $othf 0 3 0 1 $xcent $ycent]
         set othf [lreplace $othf 8 9 $ra $dec]
         set img_source [ list "IMG" [list $ra $dec 5 0 0] $othf ]
         set astroid_source [list "ASTROID" [list $ra $dec 5 0 0] [::analyse_source::get_astroid_null] ]
         set ::gui_cata::psf_source [list $img_source ]
      }

      set pass "no"
      # A decocher au cas ou on veut logger cette partie
      # set r [::psf_tools::method_global ::gui_cata::psf_source $::psf_tools::psf_threshold $::psf_tools::psf_limitradius $::psf_tools::psf_saturation $::audace(bufNo)]
      set err [ catch {set r [::psf_tools::method_global ::gui_cata::psf_source $::psf_tools::psf_threshold $::psf_tools::psf_limitradius $::psf_tools::psf_saturation $::audace(bufNo)]} msg ]
      if {$err} {
         ::console::affiche_erreur "ERREUR PSF no_gui: $msg\n"
      } else {
         set pass "yes"
      }

      switch $::gui_cata::psf_name_source {
         "Erreur" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         "Unknown" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state normal
         }
         "Ambigue" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         default {
            $::psf_gui::fen.appli.actions.save configure -state normal
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
      }
      
      if { $pass=="no" } { return }
      
      #gren_info "::gui_cata::psf_source = $::gui_cata::psf_source\n"

      #gren_info "*best PSF pour ($::gui_cata::psf_id_source) $::gui_cata::psf_name_source \n"
      set ::gui_cata::psf_best_sol        [lindex $r 0]
      set ::gui_cata::psf_radius          [lindex $r 1]
      set ::gui_cata::psf_add_astroid     [lindex $r 2]

      if {$::gui_cata::psf_name_source == "Unknown" } {
         gren_info "NEW SOURCE : ADD IMG = Success, ASTROID = $::gui_cata::psf_add_astroid \n"
      }
      #gren_info "psf_radius   = $::gui_cata::psf_radius \n"
      #gren_info "psf_best_sol = $::gui_cata::psf_best_sol   \n"

      set result [lindex $r 0]
      ::psf_tools::result_photom_methode $result

      set xcent [expr int([lindex $result 0])]
      set ycent [expr int([lindex $result 1])]
      set delta [lindex $r 1]
      set rect [list [expr $xcent - $delta] [expr $ycent - $delta] [expr $xcent + $delta]  [expr $ycent + $delta] ] 

      #     fit gauss
      set result_fitgauss [buf$bddconf(bufno) fitgauss $rect]
      ::psf_tools::result_fitgauss $result_fitgauss
 
      set xd [expr abs($::gui_cata::current_psf(xsm)-$::gui_cata::current_psf(xcent))]
      set yd [expr abs($::gui_cata::current_psf(ysm)-$::gui_cata::current_psf(ycent))]
      set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
      set ::gui_cata::current_psf(rdiff) [format "%.4f" $rdiff ]

      catch {

         cleanmark
      
         set r $::gui_cata::current_psf(delta)
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green $r 2

         set r [expr 3.0*sqrt((pow($::gui_cata::current_psf(xfwhm),2)+pow($::gui_cata::current_psf(yfwhm),2))/2.0)]

         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) red 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) blue $r 2
      
      }
      
   }








   proc ::psf_gui::box_global_crop { } {
   
      global bddconf


      #::gui_cata::psf_cataname
      #::gui_cata::psf_source
      #::gui_cata::psf_name_source
      #::gui_cata::psf_id_source 


      set pass "no"
      # A decocher au cas ou on veut logger cette partie
      # set r [::psf_tools::method_global ::gui_cata::psf_source $::psf_tools::psf_threshold $::psf_tools::psf_limitradius $::psf_tools::psf_saturation $::audace(bufNo)]
      set err [ catch {set r [::psf_tools::method_global ::gui_cata::psf_source $::psf_tools::psf_threshold $::psf_tools::psf_limitradius $::psf_tools::psf_saturation $::psf_gui::bufcrop]} msg ]
      if {$err} {
         ::console::affiche_erreur "ERREUR PSF no_gui: $msg\n"
      } else {
         set pass "yes"
      }
      
      if { $pass=="no" } { return }
      
      #gren_info "::gui_cata::psf_source = $::gui_cata::psf_source\n"

      #gren_info "*best PSF pour ($::gui_cata::psf_id_source) $::gui_cata::psf_name_source \n"
      set ::gui_cata::psf_best_sol        [lindex $r 0]
      set ::gui_cata::psf_radius          [lindex $r 1]
      set ::gui_cata::psf_add_astroid     [lindex $r 2]

      set result [lindex $r 0]
      ::psf_tools::result_photom_methode $result

      set xcent [expr int([lindex $result 0])]
      set ycent [expr int([lindex $result 1])]
      set delta [lindex $r 1]
      set rect [list [expr $xcent - $delta] [expr $ycent - $delta] [expr $xcent + $delta]  [expr $ycent + $delta] ] 

      #     fit gauss
      set result_fitgauss [buf$::psf_gui::bufcrop fitgauss $rect]
      ::psf_tools::result_fitgauss $result_fitgauss
 
      set xd [expr abs($::gui_cata::current_psf(xsm)-$::gui_cata::current_psf(xcent))]
      set yd [expr abs($::gui_cata::current_psf(ysm)-$::gui_cata::current_psf(ycent))]
      set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
      set ::gui_cata::current_psf(rdiff) [format "%.4f" $rdiff ]
      
      set ::gui_cata::current_psf(xsm)   [format "%.4f" [expr  $::gui_cata::current_psf(xsm)  + $::psf_gui::xref ] ]
      set ::gui_cata::current_psf(ysm)   [format "%.4f" [expr  $::gui_cata::current_psf(ysm)  + $::psf_gui::yref ] ]
      set ::gui_cata::current_psf(xcent) [format "%.4f" [expr  $::gui_cata::current_psf(xcent)+ $::psf_gui::xref ] ]
      set ::gui_cata::current_psf(ycent) [format "%.4f" [expr  $::gui_cata::current_psf(ycent)+ $::psf_gui::yref ] ]

      ::psf_gui::affichage_des_ronds_dans_imagette

      for {set radius 1} {$radius < $::psf_tools::psf_limitradius} {incr radius} {
         set ::psf_tools::graph_results($radius) [lreplace $::psf_tools::graph_results($radius) 0 0 [expr [lindex $::psf_tools::graph_results($radius) 0] + $::psf_gui::xref ]]
         set ::psf_tools::graph_results($radius) [lreplace $::psf_tools::graph_results($radius) 1 1 [expr [lindex $::psf_tools::graph_results($radius) 1] + $::psf_gui::yref ]]
      }

      set ::gui_cata::psf_best_sol [lreplace $::gui_cata::psf_best_sol 0 1 $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm)]

      #gren_info "new astroid source = $::gui_cata::psf_source\n "
      #gren_info "psf_name_source = $::gui_cata::psf_name_source\n "
      #gren_info "psf_best_sol = $::gui_cata::psf_best_sol\n "

      set flagastroid [::psf_tools::add_astroid ::gui_cata::psf_source ::gui_cata::psf_best_sol $::gui_cata::psf_name_source]
      gren_info "Astroid = $flagastroid\n"

      $::psf_gui::fen.appli.actions.save2 configure -state normal
      
   }



#    xsm,mean)          
#    ysm,mean)          
#    xsm,err3s)         
#    ysm,err3s)         
#    fwhmx,mean)        
#    fwhmy,mean)        
#    fwhm,mean)         
#    fluxintegre,mean)  
#    fluxintegre,err3s) 
#    pixmax,mean)       
#    intensite,mean)    
#    sigmafond,mean)    
#    snint,mean)        
#    snpx,mean)         
#    delta,mean)        
#    rdiff,mean)        
#    ra,mean)           
#    dec,mean)          
#

#   {xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec}

   proc ::psf_gui::get_list_col { } {
      return [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec ]
   }


   proc ::psf_gui::get_pos_col { key } {

      set list_of_columns [::psf_gui::get_list_col]

      set cpt 0
      foreach c $list_of_columns {
         if {$c==$key} {
            return $cpt
         }
         incr cpt
      }
      return -1
   }






   proc ::psf_gui::graph { key } {
    
      set ::psf_gui::graph_current_key $key
   
   
      set list_of_columns [::psf_gui::get_list_col]

      foreach c $list_of_columns {
         if {$c == $key} {
            $::psf_gui::fen.appli.results.photommethode.values.$key.setval configure -state active
         } else {
            catch {$::psf_gui::fen.appli.results.photommethode.values.$c.setval configure -state disabled}
         }
      }
   
      
      set id [::psf_gui::get_pos_col $key]

      if {$id == -1 } {
         ::console::affiche_erreur "$key (err $id) n'est pas definie dans la routine ::psf_gui::get_pos_col\n"
      }

      for {set i 0} {$i <= 5} {incr i} {

         set x($i) ""
         set y($i) ""

         for {set radius 1} {$radius < $::psf_tools::psf_limitradius} {incr radius} {
            
            if {$::psf_tools::graph_results($radius,err)==$i && [info exists ::psf_tools::graph_results($radius)]} {
                lappend x($i) $radius
                lappend y($i) [lindex $::psf_tools::graph_results($radius) $id]
            }

         }
            
      }
      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
     

      # Affichage de la valeur obtenue
      set x0 [ list 0 $::psf_tools::psf_limitradius ]
      set y0 [ list $::gui_cata::current_psf($key) $::gui_cata::current_psf($key)]
      set h [::plotxy::plot $x0 $y0 .]
      plotxy::sethandler $h [list -color black -linewidth 2]

      # Affichage des erreurs
      if {$key == "xsm" } {
         set delta $::gui_cata::current_psf(err_xsm)
         set y0    $::gui_cata::current_psf($key)
         #gren_info "$key = $y0 ; delta = $delta\n"
         set ymin  [list [expr $y0 - $delta] [expr $y0 - $delta] ]
         set ymax  [list [expr $y0 + $delta] [expr $y0 + $delta] ]
         set x0    [ list 0 $::psf_tools::psf_limitradius ]
         set h [::plotxy::plot $x0 $ymin .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
         set h [::plotxy::plot $x0 $ymax .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
      }
      # Affichage des erreurs
      if {$key == "ysm" } {
         set delta $::gui_cata::current_psf(err_ysm)
         set y0    $::gui_cata::current_psf($key)
         #gren_info "$key = $y0 ; delta = $delta\n"
         set ymin  [list [expr $y0 - $delta] [expr $y0 - $delta] ]
         set ymax  [list [expr $y0 + $delta] [expr $y0 + $delta] ]
         set x0    [ list 0 $::psf_tools::psf_limitradius ]
         set h [::plotxy::plot $x0 $ymin .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
         set h [::plotxy::plot $x0 $ymax .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
      }




      array set point [list 0 . 1 o 2 + 3 . 4 + 5 o ]
      array set color [list 0 "#18ad86" 1 yellow 2 green 3 blue 4 red 5 black ]
      array set line  [list 0 1 1 0 2 0 3 0 4 0 5 0 ]

      for {set i 0} {$i <= 5} {incr i} {
         if {$i==3||$i==2} {continue}
         set h [::plotxy::plot $x($i) $y($i) $point($i)]
         plotxy::sethandler $h [list -color $color($i) -linewidth $line($i)]
      }
      
   } 








   proc ::psf_gui::takall {  } {

      for {set radius 1} {$radius < $::psf_tools::psf_limitradius} {incr radius} {
         set ::psf_tools::graph_results($radius,err) 0
      }
      ::psf_gui::affichage_des_ronds_dans_imagette
       if { [winfo exists .audace.plotxy1] } {
          ::psf_gui::graph $::psf_gui::graph_current_key
       }

   } 




   proc ::psf_gui::fitgauss {  } {

      set err [ catch {set rect  [ ::confVisu::getBox $::psf_gui::visucrop ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
         return
      }
      set result_fitgauss [buf$::psf_gui::bufcrop fitgauss $rect]
      ::psf_tools::result_fitgauss $result_fitgauss
      set xcent  [lindex $result_fitgauss 1]  
      set ycent  [lindex $result_fitgauss 5]  

      set ::gui_cata::psf_radius [expr int(sqrt ( pow([lindex $rect 2] - [lindex $rect 0],2) +  \
                                       pow([lindex $rect 3] - [lindex $rect 1],2) ) / 2.0)]
      #gren_info "xcent ycent = $xcent $ycent \n"
      #gren_info "::gui_cata::psf_radius = $::gui_cata::psf_radius \n"
      ::psf_tools::psf_box_crop $xcent $ycent
      
      set ::gui_cata::psf_best_sol [lreplace $::gui_cata::psf_best_sol 0 1 $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent)]

      set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent)]]} msg ]
      if {$err} {
         ::console::affiche_erreur "$err $msg\n"
         return
      }
      set ra  [lindex $a 0]
      set dec [lindex $a 1]
      gren_info " ::gui_cata::psf_source = $::gui_cata::psf_source \n"
      set pos [lsearch -index 0 $::gui_cata::psf_source "ASTROID"]
      if {$pos != -1} {
         set astroid [lindex [lindex $::gui_cata::psf_source $pos] 2]
      } else {
         return
      }
   
               
      catch {

         clean_crop $::psf_gui::visucrop
      
         set r $::gui_cata::current_psf(delta)

         set xpm [expr  $::gui_cata::current_psf(xsm)   - $::psf_gui::xref]
         set ypm [expr  $::gui_cata::current_psf(ysm)   - $::psf_gui::yref]
         set xfg [expr  $::gui_cata::current_psf(xcent) - $::psf_gui::xref]
         set yfg [expr  $::gui_cata::current_psf(ycent) - $::psf_gui::yref]

         affich_un_rond_xy_crop $xpm $ypm green  0 1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xpm $ypm green $r 2 $::psf_gui::visucrop

         set r [expr 3.0*sqrt((pow($::gui_cata::current_psf(xfwhm),2)+pow($::gui_cata::current_psf(yfwhm),2))/2.0)]

         affich_un_rond_xy_crop $xfg $yfg  red 0  1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xfg $yfg blue $r 2 $::psf_gui::visucrop
      
      }
      
   } 



   proc ::psf_gui::setval { key } {

      set id [::psf_gui::get_pos_col $key]

      if {$id == -1 } {
         ::console::affiche_erreur "$key (err $id) n'est pas definie dans la routine ::psf_gui::get_pos_col\n"
      }

      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set x2 [lindex $rect 2]
      set y1 [lindex $rect 1]
      set y2 [lindex $rect 3]
      
      if {$x1>$x2} {
         set t $x1
         set x1 $x2
         set x2 $t
      }
      if {$y1>$y2} {
         set t $y1
         set y1 $y2
         set y2 $t
      }
 
      if {$x1 < 0 && $x2 > $::psf_tools::psf_limitradius} {
         # Astuce pour remettre a zero le graphe
         for {set radius 1} {$radius < $::psf_tools::psf_limitradius} {incr radius} {
            set ::psf_tools::graph_results($radius,err) 0
         }
      } else {

         # on crop
         set cpt 0
         for {set radius 1} {$radius < $::psf_tools::psf_limitradius} {incr radius} {
            if {$::psf_tools::graph_results($radius,err)==0} {
               incr cpt
               if {$radius < $x1 || $x2 < $radius } {
                  set ::psf_tools::graph_results($radius,err) 5
                  incr cpt -1
                  continue
               }
               set val [lindex $::psf_tools::graph_results($radius) $id] 
               if {$val < $y1 || $y2 < $val } {
                  set ::psf_tools::graph_results($radius,err) 5
                  incr cpt -1
               }
            }
         }
         gren_info "Nb radius stat crop = $cpt \n "

      }
      
      array set sol [::psf_tools::method_global_stat ::psf_tools::graph_results $::psf_tools::psf_limitradius 0]
      set ::gui_cata::psf_best_sol [::psf_tools::method_global_sol sol]

      set flagastroid [::psf_tools::add_astroid ::gui_cata::psf_source ::gui_cata::psf_best_sol $::gui_cata::psf_name_source]
      gren_info "Astroid = $flagastroid\n"
            
      set ::gui_cata::psf_add_astroid $flagastroid

      ::psf_tools::result_photom_methode $::gui_cata::psf_best_sol
      
      ::psf_gui::graph $key
      
      ::psf_gui::affichage_des_ronds_dans_imagette


   } 


   proc ::psf_gui::affichage_des_ronds_dans_imagette {  } {


      catch {

         set xpm [expr $::gui_cata::current_psf(xsm)   - $::psf_gui::xref]
         set ypm [expr $::gui_cata::current_psf(ysm)   - $::psf_gui::yref]
         set xfg [expr $::gui_cata::current_psf(xcent) - $::psf_gui::xref]
         set yfg [expr $::gui_cata::current_psf(ycent) - $::psf_gui::yref]

         clean_crop $::psf_gui::visucrop
         
         set r $::gui_cata::current_psf(delta)
         affich_un_rond_xy_crop $xpm $ypm green  0 1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xpm $ypm green $r 2 $::psf_gui::visucrop

         set r [expr 3.0*sqrt((pow($::gui_cata::current_psf(xfwhm),2)+pow($::gui_cata::current_psf(yfwhm),2))/2.0)]

         affich_un_rond_xy_crop $xfg $yfg  red 0  1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xfg $yfg blue $r 2 $::psf_gui::visucrop

         set rmax 0
         set rmin $::psf_tools::psf_limitradius
         for {set radius 1} {$radius < $::psf_tools::psf_limitradius} {incr radius} {

            if {$::psf_tools::graph_results($radius,err)==0} {
               if {$radius>$rmax} {set rmax $radius}
               if {$radius<$rmin} {set rmin $radius}
            }
         }
         affich_un_rond_xy_crop $xpm $ypm yellow $rmax 1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xpm $ypm yellow $rmin 1 $::psf_gui::visucrop
      } 
   } 
   

# Anciennement ::gui_cata::psf
# Ouvre une boite de dialogue depuis la gestion des cata pour faire 
# l analyse des psf en mode manuel

   proc ::psf_gui::gestion_mode_manuel { { sou "" } } {

      ::psf_gui::gestion_mode_manuel_init $sou
      
      set spinlist ""
      for {set i 1} {$i<$::psf_tools::psf_limitradius} {incr i} {lappend spinlist $i}

      set ::psf_gui::fen .psf
      if { [winfo exists $::psf_gui::fen] } {
         wm withdraw $::psf_gui::fen
         wm deiconify $::psf_gui::fen
         focus $::psf_gui::fen
         return
      }
      toplevel $::psf_gui::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::psf_gui::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::psf_gui::fen ] "+" ] 2 ]
      wm geometry $::psf_gui::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::psf_gui::fen 1 1
      wm title $::psf_gui::fen "PSF"
      wm protocol $::psf_gui::fen WM_DELETE_WINDOW "::psf_gui::gestion_mode_manuel_fermer"

      set frm $::psf_gui::fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::psf_gui::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5


         set info  [frame $frm.info -borderwidth 0 -cursor arrow -relief groove]
         pack $info -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $info.lab1 -text "Source : " 
             pack  $info.lab1 -side left -padx 2 -pady 0
             
             label $info.labv -textvariable ::gui_cata::psf_name_source 
             pack  $info.labv -side left -padx 2 -pady 0

             #label $info.op -text "(" 
             #pack  $info.op -side left -padx 2 -pady 0

             label $info.loc -textvariable ::gui_cata::list_of_cata -fg darkblue
             pack  $info.loc -side left -padx 2 -pady 0

             #label $info.fp -text ")" 
             #pack  $info.fp -side left -padx 2 -pady 0

         set infoimg [frame $frm.infoimg -borderwidth 0 -cursor arrow ]
         pack $infoimg -in $frm -anchor c -side top -expand 1 

         set infodate [frame $frm.infodate -borderwidth 0 -cursor arrow ]
         pack $infodate -in $frm -anchor c -side top -expand 1 

         set actions [frame $frm.actions -borderwidth 1 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor c -side top -expand 1 

                 button $actions.grab -state active -text "Grab" -relief "raised" -command "::psf_gui::gestion_mode_manuel_grab"
                 pack   $actions.grab -side left -padx 0

                 button $actions.new -state disabled -text "New" -relief "raised" -command "::psf_gui::gestion_mode_manuel_new"
                 pack   $actions.new -side left -padx 0

                 button $actions.save -state disabled -text "Save" -relief "raised" -command "::psf_gui::gestion_mode_manuel_save"
                 pack   $actions.save -side left -padx 0
 
         set config [frame $frm.config -borderwidth 0 -cursor arrow -relief groove]
         pack $config -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set data  [frame $config.saturation -borderwidth 0 -cursor arrow -relief groove]
             pack $data -in $config -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                 label $data.l -text "Saturation (ADU): " 
                 pack  $data.l -side left -padx 2 -pady 0

                 entry $data.v -textvariable ::psf_tools::psf_saturation -relief sunken -width 5
                 pack  $data.v -side left -padx 2 -pady 0

             set data  [frame $config.threshold -borderwidth 0 -cursor arrow -relief groove]
             pack $data -in $config -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                 label $data.l -text "Threshold (arcsec): " 
                 pack  $data.l -side left -padx 2 -pady 0

                 entry $data.v -textvariable ::psf_tools::psf_threshold -relief sunken -width 5
                 pack  $data.v -side left -padx 2 -pady 0

             set data  [frame $config.limitradius -borderwidth 0 -cursor arrow -relief groove]
             pack $data -in $config -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                 label $data.l -text "Limite du Rayon : " 
                 pack  $data.l -side left -padx 2 -pady 0

                 entry $data.v -textvariable ::psf_tools::psf_limitradius -relief sunken -width 5
                 pack  $data.v -side left -padx 2 -pady 0

         set actions2 [frame $frm.actions2 -borderwidth 1 -cursor arrow -relief groove]
         pack $actions2 -in $frm -anchor c -side top

             spinbox $actions2.radius -values $spinlist -from 1 -to $::psf_tools::psf_limitradius -textvariable ::gui_cata::psf_radius -width 3 \
                 -command "::psf_gui::one_psf"
             pack  $actions2.radius -side left 
             $actions2.radius set 15

             button $actions2.psf -state active -text "PSF" -relief "raised" -command "::psf_gui::one_psf"
             pack   $actions2.psf -side left 
 
             button $actions2.psfauto -state active -text "Auto" -relief "raised" -command "::psf_gui::box_global"
             pack   $actions2.psfauto -side left 
 
         set results [frame $frm.results -borderwidth 0 -cursor arrow -relief groove]
         pack $results -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         set photommethode [frame $results.photommethode -borderwidth 0 -cursor arrow -relief groove]
         pack $photommethode -in $results -anchor n -side left -expand 0 -fill x -padx 10 -pady 5

             label $photommethode.lab1 -text "PhotomMethode :"
             pack  $photommethode.lab1 -in $photommethode -side top -padx 2 -pady 0

             set values [ frame $photommethode.values -borderwidth 0 -cursor arrow -relief groove ]
             pack $values -in $photommethode -anchor n -side top -expand 1 -fill both -padx 10 -pady 2

                    foreach key [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff] {

                         set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                         pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 2 -pady 2

                              if {$key=="err_xsm"||$key=="err_ysm"||$key=="errflux"||$key=="delta"} {
                                 set active disabled
                              } else {
                                 set active active
                              }
                              button $value.graph -state $active -text "@" -relief "raised" \
                                 -command "::psf_gui::graph $key" 
                              pack   $value.graph -side left -padx 0
                              button $value.setval -state $active -text "S" -relief "raised" \
                                 -command "::psf_gui::setval $key" 
                              pack   $value.setval -side left -padx 0
                              
                              label $value.lab1 -text "$key =" 
                              pack  $value.lab1 -side left -padx 2 -pady 0
                              label $value.lab2 -textvariable ::gui_cata::current_psf($key)
                              pack  $value.lab2 -side right -padx 2 -pady 0
                    }

         set fitgauss [frame $results.fitgauss -borderwidth 0 -cursor arrow -relief groove]
         pack $fitgauss -in $results -anchor n -side left -expand 0 -fill x -padx 2 -pady 2

             label $fitgauss.labfitgauss -text "FitGauss :"
             pack  $fitgauss.labfitgauss -in $fitgauss -side top -padx 2 -pady 0

             set values [ frame $fitgauss.values -borderwidth 0 -cursor arrow -relief groove ]
             pack $values -in $fitgauss -anchor n -side top -expand 1 -fill both -padx 2 -pady 2

                    foreach key [list xflux xcent xfwhm xfond yflux ycent yfwhm yfond] {

                         set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                         pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 2 -pady 2

                              label $value.lab1 -text "$key =" 
                              pack  $value.lab1 -side left -anchor sw -padx 5 -pady 0
                              label $value.lab2 -textvariable ::gui_cata::current_psf($key)
                              pack  $value.lab2 -side right -padx 5 -pady 0 -anchor se 
                    }

         set actionspied [frame $frm.actionspied -borderwidth 0 -cursor arrow -relief groove]
         pack $actionspied -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $actionspied.fermer -state active -text "Fermer" -relief "raised" -command "::psf_gui::gestion_mode_manuel_fermer"
             pack   $actionspied.fermer -in $actionspied -side right -anchor w -padx 0

   }














   #
   # ::analyse_source::psf
   # Mesure de PSF d'une source
   #
   # TODO ::psf_gui::psf_listsources_no_auto : faire en sorte que le threshold soit fournit en arcsec
   # TODO ::psf_gui::psf_listsources_no_auto : mettre en place le tri par saturation
   
   proc ::psf_gui::psf_listsources_no_auto { sent_listsources radius_threshold delta saturation} {
   
      upvar $sent_listsources listsources

      global bddconf

      set log 0
      set cpt 0
      set doute 0

      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set nbs [::manage_source::get_nb_sources_by_cata $listsources "IMG"]
      if {$log} {gren_info "nb sources to work : $nbs \n"}

      lappend fields [::analyse_source::get_fieldastroid]

      set cpts 0
      set newsources {}

      foreach s $sources {
         incr cpts
         if {$log} {gren_info "source #$cpts : "}
         
         set cptc 0
         foreach cata $s {
            incr cptc
            if {$log} {
               gren_info " -> cata : $cptc [lindex $cata 0] "
            }
            if { [lindex $cata 0]=="ASTROID" } { break }

            if { [lindex $cata 0]=="IMG" } {

               set ra     [lindex [lindex [lindex $s 0] 1] 0]
               set dec    [lindex [lindex [lindex $s 0] 1] 1]
               set poserr [lindex [lindex [lindex $s 0] 1] 2]
               set mag    [lindex [lindex [lindex $s 0] 1] 3]
               set magerr [lindex [lindex [lindex $s 0] 1] 4]
               set x      [lindex [lindex [lindex $s 0] 2] 2]
               set y      [lindex [lindex [lindex $s 0] 2] 3]
               set fwhm   [lindex [lindex [lindex $s 0] 2] 24]

               if {$log} {
                  affich_un_rond $ra $dec red 4
                  gren_info " -> RA,DEC,x,y : $ra $dec $x $y\n"
               }

               # Mesure de PSF de la source: 
               # result = {$xsm $ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta}
               set err [catch {set results [::tools_cdl::photom_methode $x $y $delta $bddconf(bufno)]} msg]
               if {$err} { 
                  gren_info "photom error ($err) ($msg)\n" 
                  set results -1
               } 

               if { $results == -1 } {
                  lappend newsources $s
               } else {
                  incr cpt
                  set xd [expr abs([lindex $results 0]-$x)]
                  set yd [expr abs([lindex $results 1]-$y)]
                  set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
                  if {$rdiff > $radius_threshold } {
                     lappend newsources $s
                     incr doute
                  } else {
                     # Ajoute rdiff, RA, DEC, res_ra, res_dec, omc_ra, omc_dec, mag, err_mag, name, flag*, cata* aux resultats
                     lappend results $rdiff $ra $dec $poserr $poserr 0.0 0.0 $mag $magerr "-" "-" "-" "-" "-"
                     # Reconstruit la liste des sources en ajoutant la source ASTROID
                     set ns {}
                     foreach cata $s {
                        if { [lindex $cata 0]!="ASTROID" } {
                           lappend ns $cata
                        }
                     }
                     lappend ns [list "ASTROID" {} $results]
                     lappend newsources $ns
                  }

               }
               break

            }

         }
         
      }

      if {$log} {gren_info "nb doute : $doute \n"}

   set listsources [list $fields $newsources]
   }
# source $audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex/main.tcl























   proc ::psf_gui::read_source { name l } {
   
      global bddconf
   
      #::gui_cata::current_psf
      set ::psf_gui::dateimg "???"
       
      gren_info "Source name=$name\n"
      
      gren_info "nb img == [llength $::tools_cata::img_list]\n"
      set ::gui_cata::psf_id_source [lindex $l 0]
      set dateimg  [lindex $l 1]

      gren_info "Id source = $::gui_cata::psf_id_source\n"
      gren_info "dateimg = $dateimg\n"
   
      set ::tools_cata::id_current_image 0
      foreach ::tools_cata::current_image $::tools_cata::img_list {
         incr ::tools_cata::id_current_image
         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         #gren_info "($::tools_cata::id_current_image) $date == $dateimg\n"
         if { [::bdi_tools::is_isodates_equal $date $dateimg] } {
            set ::psf_gui::dateimg $date
            break
         }
      }
      gren_info "($::tools_cata::id_current_image) $date == $dateimg\n"
      
      set filename      [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      set dirfilename   [::bddimages_liste::lget $::tools_cata::current_image "dirfilename"]
      set fileimg       [file join $bddconf(dirbase) $dirfilename $filename]
      if {![file exists $fileimg]} {
         gren_erreur "Attention le fichier n existe pas !\n"
      }
      
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
      set fields [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]
      set pass "no"

      set ::gui_cata::psf_source [lindex $sources [expr $::gui_cata::psf_id_source -1]]

      set pos [lsearch -index 0 $::gui_cata::psf_source "ASTROID"]
      if {$pos != -1} {
         set astroid [lindex [lindex $::gui_cata::psf_source $pos] 2]
      } else {
         return
      }

      if {[info exists ::gui_cata::current_psf]} {unset ::gui_cata::current_psf}
      set cpt -1
      foreach key [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff] {
         incr cpt
         set ::gui_cata::current_psf($key) [lindex $astroid $cpt]
      }

      set xcent $::gui_cata::current_psf(xsm)
      set ycent $::gui_cata::current_psf(ysm)
      
      gren_info "xcent ycent = $xcent $ycent\n"
      
      set radius 100
      set offset -2
      set ::psf_gui::xref [expr int($xcent - $radius) + $offset ]
      set ::psf_gui::yref [expr int($ycent - $radius) + $offset ]
      set rect [list [expr int($xcent - $radius)-1] [expr int($ycent - $radius)-1] \
                 [expr int($xcent + $radius)+1] [expr int($ycent + $radius)+1] ]
      gren_info "rect = $rect\n"
      set sizex [expr [lindex $rect 2]-[lindex $rect 0] +1]
      set sizey [expr [lindex $rect 3]-[lindex $rect 1] +1]

      set ::gui_cata::psf_best_sol [list [expr $xcent - $::psf_gui::xref] [expr $ycent - $::psf_gui::yref]]

      gren_info "fileimg = $fileimg\n"
      
      buf$::psf_gui::bufcrop load $fileimg
      buf$::psf_gui::bufcrop window $rect
      ::audace::autovisu $::psf_gui::visucrop
      
      
      catch {

         clean_crop $::psf_gui::visucrop

         set xpm [expr $::gui_cata::current_psf(xsm)   - $::psf_gui::xref]
         set ypm [expr $::gui_cata::current_psf(ysm)   - $::psf_gui::yref]
         set xfg [expr $::gui_cata::current_psf(xcent) - $::psf_gui::xref]
         set yfg [expr $::gui_cata::current_psf(ycent) - $::psf_gui::yref]

         set r $::gui_cata::current_psf(delta)
         affich_un_rond_xy_crop $xpm $ypm green  0 1 $::psf_gui::visucrop
         affich_un_rond_xy_crop $xpm $ypm green $r 2 $::psf_gui::visucrop

      }


      
      
      
   }






   proc ::psf_gui::next_img { } {
   
         if {$::psf_gui::id_img == 1} {
            $::psf_gui::fen.appli.actions.prev configure -state normal
         }
         if {$::psf_gui::id_img < $::psf_gui::nb_img} {
            incr ::psf_gui::id_img
            ::psf_gui::read_source $::gui_cata::psf_name_source [lindex $::psf_gui::date_id [expr $::psf_gui::id_img - 1] ]
            $::psf_gui::fen.appli.actions.save2 configure -state disabled
         }
         if {$::psf_gui::id_img == $::psf_gui::nb_img} {
            $::psf_gui::fen.appli.actions.next configure -state disabled
         }
   }






   proc ::psf_gui::prev_img { } {
   
         if {$::psf_gui::id_img == $::psf_gui::nb_img} {
            $::psf_gui::fen.appli.actions.next configure -state normal
         }
         if {$::psf_gui::id_img > 1} {
            incr ::psf_gui::id_img -1
            ::psf_gui::read_source $::gui_cata::psf_name_source [lindex $::psf_gui::date_id [expr $::psf_gui::id_img - 1] ]
            $::psf_gui::fen.appli.actions.save2 configure -state disabled
         }
         if {$::psf_gui::id_img == 1} {
            $::psf_gui::fen.appli.actions.prev configure -state disabled
         }
   }







   proc ::psf_gui::save_img { } {

         
       $::psf_gui::fen.appli.actions.save2 configure -state disabled
       set ls [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]
       set ls [lreplace $ls [expr $::gui_cata::psf_id_source - 1] [expr $::gui_cata::psf_id_source - 1] $::gui_cata::psf_source]

       set ::gui_cata::cata_list($::tools_cata::id_current_image) [lreplace $::gui_cata::cata_list($::tools_cata::id_current_image) 1 1 $ls]

       set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

       ::tools_cata::current_listsources_to_tklist

       set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]
         
   }


   proc ::psf_gui::nextauto_img { } {

      ::psf_gui::next_img
      ::psf_gui::box_global_crop
      
       if { [winfo exists .audace.plotxy1] } {
          ::psf_gui::graph $::psf_gui::graph_current_key
       }

   }

   proc ::psf_gui::savenextauto_img { } {

      ::psf_gui::save_img
      ::psf_gui::next_img
      ::psf_gui::box_global_crop
      
       if { [winfo exists .audace.plotxy1] } {
          ::psf_gui::graph $::psf_gui::graph_current_key
       }

   }



   proc ::psf_gui::from_astrometry { name cpt date_id } {

      global bddconf

      ::psf_tools::inittoconf

      set spinlist ""
      for {set i 1} {$i<$::psf_tools::psf_limitradius} {incr i} {lappend spinlist $i}

      ::psf_gui::gestion_mode_manuel

      set frm $::psf_gui::fen.appli

      

      set ::gui_cata::psf_name_source $name
      set ::psf_gui::id_img 1
      set ::psf_gui::nb_img $cpt
      set ::psf_gui::date_id $date_id

      set ::psf_gui::visucrop [::confVisu::create]
      set ::psf_gui::bufcrop  [::confVisu::getBufNo $::psf_gui::visucrop]
      gren_info "visu = $::psf_gui::visucrop\n"
      gren_info "buffer = $::psf_gui::bufcrop\n"

      gren_info "date_id = $date_id \n"
      
      ::psf_gui::read_source $name [lindex $date_id [expr $::psf_gui::id_img-1] ]
      

      pack forget $frm.actions.grab
      pack forget $frm.actions.new
      pack forget $frm.actions.save
      pack forget $frm.actions2.radius
      pack forget $frm.actions2.psf
      pack forget $frm.actions2.psfauto

      set infoimg $frm.infoimg

             label $infoimg.title -text "Image : "
             pack  $infoimg.title -side left -padx 2 -pady 0
             label $infoimg.id -textvariable ::psf_gui::id_img
             pack  $infoimg.id -side left -padx 2 -pady 0
             label $infoimg.lab -text "/"
             pack  $infoimg.lab -side left -padx 2 -pady 0
             label $infoimg.lab2 -text "$cpt"
             pack  $infoimg.lab2 -side left -padx 2 -pady 0

      set infodate $frm.infodate

             label $infodate.id -textvariable ::psf_gui::dateimg
             pack  $infodate.id -side left -padx 2 -pady 0

      set actions $frm.actions

         button $actions.prev -state disabled -text "Prev" -relief "raised" -command "::psf_gui::prev_img"
         pack   $actions.prev -side left -padx 0

         button $actions.save2 -state disabled -text "Save" -relief "raised" -command "::psf_gui::save_img"
         pack   $actions.save2 -side left -padx 0

         button $actions.next -state active -text "Next" -relief "raised" -command "::psf_gui::next_img"
         pack   $actions.next -side left -padx 0

         button $actions.nextauto -state active -text "Next & Auto" -relief "raised" -command "::psf_gui::nextauto_img"
         pack   $actions.nextauto -side left -padx 0

         button $actions.savenextauto -state active -text "Save & Next & Auto" -relief "raised" -command "::psf_gui::savenextauto_img"
         pack   $actions.savenextauto -side left -padx 0

       
      set actions2 $frm.actions2

             spinbox $actions2.radiusc -values $spinlist -from 1 -to $::psf_tools::psf_limitradius -textvariable ::gui_cata::psf_radius -width 3 \
                 -command "::psf_gui::one_psf_crop"
             pack  $actions2.radiusc -side left 
             $actions2.radiusc set 15
             button $actions2.psfc -state active -text "PSF" -relief "raised" -command "::psf_gui::one_psf_crop"
             pack   $actions2.psfc -side left 
             button $actions2.psfautoc -state active -text "Auto" -relief "raised" -command "::psf_gui::box_global_crop"
             pack   $actions2.psfautoc -side left 
             button $actions2.clean -state active -text "Clean" -relief "raised" -command "clean_crop $::psf_gui::visucrop"
             pack   $actions2.clean -side left 
             button $actions2.takall -state active -text "Select All Radius" -relief "raised" -command "::psf_gui::takall"
             pack   $actions2.takall -side left 
             button $actions2.fitgauss -state active -text "fitgauss" -relief "raised" -command "::psf_gui::fitgauss"
             pack   $actions2.fitgauss -side left 
      
   }











#- Fin du namespace -------------------------------------------------
}
